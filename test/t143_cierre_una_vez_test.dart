import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:baystream/core/errors/failures.dart';
import 'package:baystream/features/vessel/data/datasources/hive_movement_data_source.dart';
import 'package:baystream/features/vessel/data/repositories/movement_log_repository_impl.dart';
import 'package:baystream/features/vessel/data/repositories/sync_engine.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/session_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t79_fake_cloud.dart';
import 'support/t82_fixture.dart';

/// T-143, corrección 1 (T143-ACC-01; 10.119) · El cierre se guarda una sola
/// vez, y las escrituras del motor sobre la operación local no se pisan.
///
/// La primera prueba es la sonda de la aceptación de Codex
/// (`build/t143acc/single_save_test.dart` en su carpeta), hecha permanente:
/// sin red, el documento cerrado y dos rechazos al volver la red. La entrega
/// guardaba la operación cerrada tres veces. Las otras dos llevan a la vez el
/// cierre y una fuente nueva (el plan de carga agregado o una revisión del
/// listado): las dos cosas quedan guardadas.
///
/// Contra la nube falsa de T-79 y la bitácora real en Hive. La bitácora solo
/// cuenta los guardados de la operación cerrada y, para abrir la ventana de
/// la carrera, puede demorar las lecturas de la operación; no cambia lo que
/// lee ni lo que guarda.
class _Bitacora extends MovementLogRepositoryImpl {
  _Bitacora(super.source, {required super.clock});

  int guardadosCerrada = 0;
  Duration demoraDeLectura = Duration.zero;

  @override
  Future<Either<Failure, void>> saveOperation(Operation operation) {
    if (operation.closed) guardadosCerrada++;
    return super.saveOperation(operation);
  }

  @override
  Future<Either<Failure, Operation?>> getOperation(String id) async {
    final leida = await super.getOperation(id);
    if (demoraDeLectura > Duration.zero) await Future<void>.delayed(demoraDeLectura);
    return leida;
  }
}

void main() {
  const dock =
      Operator(uid: 'uid-muelle', name: 'Muelle sintético', role: OperatorRole.dock);
  const operationId = '7c4e1a92-3b5d-4f60-9e21-8a0d6c3f5b14';
  final now = DateTime.utc(2026, 11, 11, 7);
  late Directory directory;
  late _Bitacora log;

  final abierta = Operation(
    id: operationId,
    vesselName: 'BUQUE MANUAL',
    voyageNumber: 'A143Q',
    portOfCall: 'GTSTC',
    createdAt: now.subtract(const Duration(hours: 1)),
    published: true,
    sources: const [
      OperationSource(
          kind: OperationSourceKind.arrivalBaplie,
          fileName: 'llegada.edi',
          content: t82ArrivalEdi),
    ],
  );

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('t143_una_vez_');
    log = _Bitacora(
        await HiveMovementDataSource.open(
            directory: directory.path,
            namespace: 't143uv_${DateTime.now().microsecondsSinceEpoch}'),
        clock: () => now);
    await log.saveOperation(abierta);
  });

  tearDown(() async {
    await log.close();
    if (directory.existsSync()) await directory.delete(recursive: true);
  });

  Future<Operation> local() async =>
      (await log.getOperation(operationId)).getOrElse(() => null)!;

  Future<void> until(FutureOr<bool> Function() condicion) async {
    for (var i = 0; i < 300; i++) {
      if (await condicion()) return;
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    fail('No se cumplió a tiempo');
  }

  SyncEngine motor(FakeCloud cloud) => SyncEngine(
      log: log,
      remote: cloud,
      operation: abierta,
      clock: () => now,
      tick: const Duration(hours: 1));

  test('sin red, el documento cerrado y dos rechazos al volver la red guardan '
      'el cierre una sola vez (la sonda de T143-ACC-01)', () async {
    final cloud = FakeCloud(clock: () => now)
      ..authorization[dock.uid] = RemoteAuthorization.active;
    cloud.online = false;
    final sync = motor(cloud);
    addTearDown(sync.stop);
    await sync.start(dock);
    await log.append(
        MovementDraft.loadFull(operationId, 'TSTU0000001', '0140102', order: 1),
        dock.author);
    await log.append(
        MovementDraft.loadFull(operationId, 'TSTU0000002', '0140302', order: 2),
        dock.author);
    cloud.server.closeOperation(now.subtract(const Duration(seconds: 1)));
    cloud.goOnline();
    await until(() => sync.current.rejected == 2);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(log.guardadosCerrada, 1, reason: 'una sola persistencia del cierre');
    expect((await local()).closed, isTrue);
    expect(sync.current.closed, isTrue);
  });

  test('lo mismo con las lecturas lentas: el cierre se guarda una vez', () async {
    log.demoraDeLectura = const Duration(milliseconds: 15);
    final cloud = FakeCloud(clock: () => now)
      ..authorization[dock.uid] = RemoteAuthorization.active;
    cloud.online = false;
    final sync = motor(cloud);
    addTearDown(sync.stop);
    await sync.start(dock);
    for (var i = 1; i <= 3; i++) {
      await log.append(
          MovementDraft.loadFull(operationId, 'TSTU000000$i', '01401${i}2', order: i),
          dock.author);
    }
    cloud.server.closeOperation(now.subtract(const Duration(seconds: 1)));
    cloud.goOnline();
    await until(() => sync.current.rejected == 3);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(log.guardadosCerrada, 1);
  });

  for (final (nombre, agregar, tiene) in <(String, void Function(FakeServer),
      bool Function(Operation))>[
    (
      'el plan de carga agregado',
      (server) => server.addPlan(OperationSourceKind.loadingBaplie, t82LoadingEdi,
          fileName: 'carga.edi'),
      (o) => o.source(OperationSourceKind.loadingBaplie)?.content == t82LoadingEdi,
    ),
    (
      'una revisión del listado',
      (server) => server.reviseList(jsonEncode(t82List.toJson())),
      (o) => o.exportListRevision == 1,
    ),
  ]) {
    test('$nombre que llega a la vez que el cierre: los dos quedan guardados',
        () async {
      // Las lecturas lentas abren la ventana en la que, sin la cola, el
      // guardado de la fuente se hacía sobre la operación todavía abierta y
      // borraba el cierre, o al revés.
      log.demoraDeLectura = const Duration(milliseconds: 15);
      final cloud = FakeCloud(clock: () => now)
        ..authorization[dock.uid] = RemoteAuthorization.active;
      cloud.online = false;
      final sync = motor(cloud);
      addTearDown(sync.stop);
      await sync.start(dock);
      await log.append(
          MovementDraft.loadFull(operationId, 'TSTU0000001', '0140102', order: 1),
          dock.author);
      agregar(cloud.server);
      cloud.server.closeOperation(now.subtract(const Duration(seconds: 1)));
      cloud.goOnline();
      await until(() async {
        final o = await local();
        return o.closed && tiene(o) && sync.current.rejected == 1;
      });
      await Future<void>.delayed(const Duration(milliseconds: 200));
      final despues = await local();
      expect(despues.closed, isTrue, reason: 'el cierre no se pierde');
      expect(tiene(despues), isTrue, reason: 'la fuente nueva no se pierde');
      expect(despues.source(OperationSourceKind.arrivalBaplie)?.content,
          t82ArrivalEdi);
      expect(log.guardadosCerrada, lessThanOrEqualTo(2),
          reason: 'el cierre una vez, y la fuente sobre la operación ya cerrada');
    });
  }
}
