import 'dart:async';

import 'package:baystream/core/errors/failures.dart';
import 'package:baystream/features/vessel/data/repositories/firestore_operation_sync.dart';
import 'package:baystream/features/vessel/data/repositories/source_revisions.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/operation_sync_repository.dart';
import 'package:baystream/features/vessel/domain/repositories/session_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t129_fake_firestore.dart';
import 'support/t75_memory_log.dart';
import 'support/t82_fixture.dart';

/// T-130 (10.90) · El adaptador de Firestore contra la nube falsa de T-129, en
/// la capa de plataforma: `addSource` escribe en un lote los trozos y solo la
/// entrada `sources.{tipo}` del manifiesto, con `voyage` si el archivo declara
/// otro viaje; lee del servidor antes y no agrega lo que ya está ni a una
/// operación cerrada; con la nube en contra, nada local cambia. Y la carrera
/// del ajuste 3, en los dos órdenes: con el motor de esta misma oficina
/// escuchando la operación, el eco del manifiesto llega antes o después del
/// acuse del lote, y en los dos la fuente se guarda en local una sola vez,
/// `follow` no avisa `planArrival` (ni `listArrival` con `replaceSource`) y
/// nadie pide los trozos. También la negativa de `publish` ante una segunda
/// operación abierta del mismo buque, viaje y puerto (ajuste 1).
void main() {
  const office =
      Operator(uid: 'uid-oficina', name: 'Oficina 1', role: OperatorRole.office);
  const operationId = '7d1b4e92-3a6c-4f58-b0e7-9c2d5a8f1e34';
  const path = 'operations/$operationId';
  final createdAt = DateTime.utc(2026, 11, 1, 14, 5);
  final serverNow = DateTime.utc(2026, 11, 2, 21, 30, 10);

  late T129FakeFirestore db;
  late _CountingLog log;
  late FirestoreOperationSync sync;

  const arrivalSource = OperationSource(
      kind: OperationSourceKind.arrivalBaplie,
      fileName: 'llegada.edi',
      content: t82ArrivalEdi);
  const loadingSource = OperationSource(
      kind: OperationSourceKind.loadingBaplie,
      fileName: 'carga.edi',
      content: t82LoadingEdi);
  const listJson = '{"fileName":"l.xlsx","rows":[]}';
  const listSource = OperationSource(
      kind: OperationSourceKind.exportList, fileName: 'l.xlsx', content: listJson);

  Operation published({Iterable<OperationSource> sources = const [arrivalSource]}) =>
      Operation(
        id: operationId,
        vesselName: 'BUQUE PRUEBA',
        voyageNumber: 'VTEST',
        portOfCall: 'GTSTC',
        createdAt: createdAt,
        published: true,
        sources: sources,
      );

  /// La operación en la nube, publicada con el plano de llegada, como la
  /// escribe `publish`: el manifiesto con la entrada y el trozo.
  void seedRemote({String status = 'open'}) {
    final packed = packSource(arrivalSource);
    db.server[path] = <String, Object?>{
      'id': operationId,
      'schema': 1,
      'vessel': 'BUQUE PRUEBA',
      'voyage': 'VTEST',
      'portOfCall': 'GTSTC',
      'status': status,
      'createdBy': office.uid,
      'createdAt': Timestamp.fromDate(createdAt),
      'profile': <String, Object?>{'vesselName': 'BUQUE PRUEBA'},
      'sources': <String, Object?>{'arrival_baplie': packed.entry.toMap()},
    };
    db.server['$path/sources/${packed.parts.single.id}'] = <String, Object?>{
      ...packed.parts.single.toMap(),
      'createdBy': office.uid,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Future<void> vuelta() => Future<void>.delayed(Duration.zero);
  Future<void> vueltas([int n = 6]) async {
    for (var i = 0; i < n; i++) {
      await vuelta();
    }
  }

  setUp(() {
    db = T129FakeFirestore(clock: () => serverNow);
    log = _CountingLog();
    sync = FirestoreOperationSync(db.instance, log, const _Session(office));
    seedRemote();
  });

  tearDown(() => sync.dispose());

  group('addSource', () {
    test('escribe en un lote los trozos y solo la entrada del manifiesto, con voyage, y guarda en local',
        () async {
      await log.saveOperation(published());
      final result = await sync.addSource(published(), loadingSource.withVoyage('VTESTN'));
      await vueltas();
      final updated = result.fold<Operation?>((_) => null, (o) => o);
      expect(updated, isNotNull,
          reason: 'addSource contestó: ${result.fold((f) => '${f.code}: ${f.message}', (_) => '')}');
      // La nube: el trozo sin revisión y la entrada con voyage; la llegada intacta.
      final part = db.server['$path/sources/loading_baplie-0']!;
      expect(part['kind'], 'loading_baplie');
      expect(part['content'], t82LoadingEdi);
      expect(part.containsKey('revision'), isFalse);
      expect(part['createdBy'], office.uid);
      expect(part['createdAt'], isA<Timestamp>());
      final sources = db.server[path]!['sources'] as Map;
      expect(sources.keys, unorderedEquals(['arrival_baplie', 'loading_baplie']));
      expect((sources['loading_baplie'] as Map)['voyage'], 'VTESTN');
      expect((sources['loading_baplie'] as Map)['sha256'], sourceHash(t82LoadingEdi));
      expect(sources['arrival_baplie'], packSource(arrivalSource).entry.toMap());
      expect(db.server[path]!['voyage'], 'VTEST', reason: 'la operación conserva su viaje');
      // Lo local: una sola escritura, con la fuente y su viaje.
      expect(log.saves, 2, reason: 'la de la prueba y la de addSource');
      final local = log.operations.single;
      expect(local.source(OperationSourceKind.loadingBaplie)!.voyage, 'VTESTN');
      expect(local.sources, hasLength(2));
      expect(updated, local);
    });

    test('no agrega lo que ya está ni a una operación cerrada; sin red o sin aceptar, nada local cambia',
        () async {
      await log.saveOperation(published());
      // Ya tiene el plano de llegada: no se reemplaza.
      final has = await sync.addSource(published(), arrivalSource.withVoyage(null));
      expect(has.fold((f) => f.code, (_) => ''), 'already_has');
      expect(has.fold((f) => f.message, (_) => ''),
          contains('ya tiene el plano de llegada («llegada.edi»)'));
      // El listado no va por aquí.
      final list = await sync.addSource(published(), listSource);
      expect(list.isLeft(), isTrue);
      // Cerrada en la nube.
      seedRemote(status: 'closed');
      final closed = await sync.addSource(published(), loadingSource);
      expect(closed.fold((f) => f.code, (_) => ''), 'closed');
      // Retirada de la nube.
      db.server.remove(path);
      final gone = await sync.addSource(published(), loadingSource);
      expect(gone.fold((f) => f.code, (_) => ''), 'not_found');
      expect(log.saves, 1, reason: 'nada local cambió');
      expect(log.operations.single.sources, hasLength(1));
      expect(db.server.containsKey('$path/sources/loading_baplie-0'), isFalse);
    });

    test('exige sesión de oficina', () async {
      final dock = FirestoreOperationSync(db.instance, log,
          const _Session(Operator(uid: 'uid-muelle', name: 'Muelle', role: OperatorRole.dock)));
      addTearDown(dock.dispose);
      final result = await dock.addSource(published(), loadingSource);
      expect(result.fold((f) => f.code, (_) => ''), 'not_office');
      final nobody = FirestoreOperationSync(db.instance, log, const _Session(null));
      addTearDown(nobody.dispose);
      expect((await nobody.addSource(published(), loadingSource)).fold((f) => f.code, (_) => ''),
          'no_session');
    });
  });

  group('el eco antes que el acuse (ajuste 3): la oficina que agrega no se avisa a sí misma ni guarda dos veces',
      () {
    for (final echoFirst in [false, true]) {
      final orden = echoFirst ? 'el eco antes que el acuse' : 'el acuse antes que el eco';

      test('addSource con $orden', () async {
        db.echoBeforeAck = echoFirst;
        await log.saveOperation(published());
        // La oficina sigue la operación: su motor escucha el manifiesto.
        final statuses = <SyncStatus>[];
        final following = sync.follow(published()).listen(statuses.add);
        addTearDown(following.cancel);
        await vueltas();
        expect(db.document(path).listeners, greaterThanOrEqualTo(1),
            reason: 'el motor de T-127 escucha el documento de la operación');

        final result = await sync.addSource(published(), loadingSource);
        await vueltas(10);
        expect(result.isRight(), isTrue,
            reason: 'addSource contestó: ${result.fold((f) => '${f.code}: ${f.message}', (_) => '')}');
        expect(db.server[path]!['sources'], containsPair('loading_baplie', isA<Map>()));
        expect(log.saves, 2, reason: 'la fuente se guardó en local una sola vez');
        expect(log.operations.single.sources, hasLength(2));
        expect(statuses.where((s) => s.planArrival != null), isEmpty,
            reason: 'la oficina no se avisa a sí misma');
        expect(db.queryGets, 0, reason: 'nadie pidió los trozos del plan');
      });

      test('replaceSource (T-127) con $orden', () async {
        db.echoBeforeAck = echoFirst;
        await log.saveOperation(published());
        final statuses = <SyncStatus>[];
        final following = sync.follow(published()).listen(statuses.add);
        addTearDown(following.cancel);
        await vueltas();

        final result = await sync.replaceSource(published(), listSource);
        await vueltas(10);
        expect(result.isRight(), isTrue,
            reason: 'replaceSource contestó: ${result.fold((f) => '${f.code}: ${f.message}', (_) => '')}');
        expect(log.saves, 2, reason: 'el listado se guardó en local una sola vez');
        expect(log.operations.single.exportListRevision, 1);
        expect(statuses.where((s) => s.listArrival != null), isEmpty,
            reason: 'la oficina no se avisa a sí misma');
        expect(db.queryGets, 0, reason: 'nadie pidió los trozos de la revisión');
      });
    }
  });

  group('publish no publica una segunda operación abierta igual (ajuste 1)', () {
    test('con una abierta del mismo buque, viaje y puerto en la nube, se niega y nombra la que hay',
        () async {
      final another = Operation(
          id: 'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c5d',
          vesselName: 'BUQUE PRUEBA',
          voyageNumber: 'VTEST',
          portOfCall: 'GTSTC',
          createdAt: DateTime.utc(2026, 11, 2),
          sources: const [loadingSource]);
      await log.saveOperation(another);
      final result = await sync.publish(another, VesselProfile.proposeFrom(t82Loading));
      expect(result.fold((f) => f.code, (_) => ''), 'duplicate');
      final message = result.fold((f) => f.message, (_) => '');
      expect(message, startsWith('Ya hay una operación publicada y abierta de BUQUE PRUEBA · VTEST · GTSTC, publicada el '));
      expect(message, endsWith('No se publica otra: únete a ella desde «Operaciones abiertas en la nube».'));
      expect(db.server.containsKey('operations/${another.id}'), isFalse);
      expect(log.operations.single.published, isFalse);
    });

    test('otro viaje o la misma operación no son una segunda', () async {
      final otherVoyage = Operation(
          id: 'b2c3d4e5-f6a7-4b8c-9d0e-1f2a3b4c5d6e',
          vesselName: 'BUQUE PRUEBA',
          voyageNumber: 'VNEXT',
          portOfCall: 'GTSTC',
          createdAt: DateTime.utc(2026, 11, 2),
          sources: const [loadingSource]);
      await log.saveOperation(otherVoyage);
      final result = await sync.publish(otherVoyage, VesselProfile.proposeFrom(t82Loading));
      await vueltas();
      expect(result.isRight(), isTrue,
          reason: 'publish contestó: ${result.fold((f) => '${f.code}: ${f.message}', (_) => '')}');
      expect(db.server.containsKey('operations/${otherVoyage.id}'), isTrue);
      // La misma operación, ya publicada, solo se vuelve a marcar.
      await log.saveOperation(published());
      final same = await sync.publish(published(), VesselProfile.proposeFrom(t82Arrival));
      expect(same.isRight(), isTrue);
    });
  });
}

/// La bitácora en memoria de T-75, con lo que el motor toca al seguir la
/// operación (sin pendientes propios ni ecos que aceptar) y contando cuántas
/// veces se guarda una operación: la fuente agregada tiene que guardarse una
/// sola vez.
class _CountingLog extends T75MemoryLog {
  int saves = 0;

  @override
  Future<Either<Failure, void>> saveOperation(Operation operation) {
    saves++;
    return super.saveOperation(operation);
  }

  @override
  Future<Either<Failure, Operation?>> getOperation(String id) async =>
      Right(operations.where((o) => o.id == id).firstOrNull);

  @override
  Future<Either<Failure, List<MovementRecord>>> pendingOf(
          String operationId, String uid) async =>
      const Right([]);

  @override
  Future<Either<Failure, void>> acceptRemote(Iterable<Movement> movements) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> markConfirmed(String id, {DateTime? receivedAt}) async =>
      const Right(null);

  /// La bitácora de T-75 implementa `watch` como un generador `async*` que
  /// espera en un `await for` sobre un flujo que nunca emite, y cancelar un
  /// generador así no termina: el motor se colgaba al parar. Aquí, lo que hay
  /// al suscribirse y un cierre limpio al cancelar, como la bitácora de Hive.
  @override
  Stream<List<MovementRecord>> watch(String operationId) {
    late final StreamController<List<MovementRecord>> controller;
    controller = StreamController<List<MovementRecord>>(
        onListen: () => controller.add(of(operationId)),
        onCancel: () => controller.close());
    return controller.stream;
  }
}

class _Session implements SessionRepository {
  const _Session(this.operator);
  final Operator? operator;

  @override
  Operator? get current => operator;

  @override
  Stream<Operator?> watchOperator() => Stream.value(operator);

  @override
  Future<void> verify() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
