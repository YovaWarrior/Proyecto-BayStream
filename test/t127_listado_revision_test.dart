import 'dart:convert';
import 'dart:io';

import 'package:baystream/core/errors/failures.dart';
import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/data/datasources/hive_movement_data_source.dart';
import 'package:baystream/features/vessel/data/repositories/movement_log_repository_impl.dart';
import 'package:baystream/features/vessel/data/repositories/source_revisions.dart';
import 'package:baystream/features/vessel/data/repositories/sync_engine.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/operation_sync_repository.dart';
import 'package:baystream/features/vessel/domain/repositories/session_repository.dart';
import 'package:baystream/features/vessel/domain/services/export_list_cross_checker.dart';
import 'package:baystream/features/vessel/domain/services/operation_sources.dart';
import 'package:baystream/features/vessel/domain/services/operation_state_deriver.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t75_memory_log.dart';
import 'support/t79_fake_cloud.dart';

/// T-127 (10.78) · El listado de la agencia en una operación publicada (H2
/// del piloto, 10.50): el motor recibe una revisión nueva con y sin
/// movimientos, sin red se queda con el anterior, `join` arma la última
/// revisión, la oficina sube por `replaceSource` y el cruce dice lo que
/// cambia. El motor corre contra la nube falsa de T-79 sobre la bitácora
/// real en Hive, en una carpeta temporal por prueba.
void main() {
  const dock = Operator(uid: 'uid-muelle', name: 'Tarjador 1', role: OperatorRole.dock);
  const operationId = '8d3b0f52-1e6a-4b8f-a2c4-5e9d7f1a0b36';
  late Directory directory;
  late String namespace;
  late DateTime now;
  DateTime clock() => now;

  // Filas sintéticas: llenos y un vacío de 22G1 · JMKWL · LNA.
  ExportListRow row(int order, String id,
          {bool empty = false,
          String type = '22G1',
          String pod = 'JMKWL',
          String line = 'LNA'}) =>
      ExportListRow(
        sheetRow: order + 1,
        order: order,
        containerId: id,
        status: empty ? ContainerStatus.empty : ContainerStatus.full,
        listType: type,
        listPod: pod,
        listLine: line,
        tareKg: 2185,
        vgmKg: empty ? null : 12000,
      );
  String listJson(List<ExportListRow> rows) =>
      jsonEncode(ExportList(fileName: 'listado.xlsx', rows: rows).toJson());
  final rows1 = [row(1, 'TSTU0000014'), row(2, 'TSTU0000020', empty: true)];
  final rows2 = [
    row(7, 'TSTU0000014'),
    row(8, 'TSTU0000020', empty: true, line: 'LNB'),
    row(9, 'TSTU0000035'),
  ];
  OperationSource listSource(String content, {int? revision}) => OperationSource(
      kind: OperationSourceKind.exportList,
      fileName: 'listado.xlsx',
      content: content,
      revision: revision);
  const planSource = OperationSource(
      kind: OperationSourceKind.loadingBaplie, fileName: 'plan.edi', content: 'UNB+A');
  Operation published({Iterable<OperationSource> sources = const [planSource]}) =>
      Operation(
        id: operationId,
        vesselName: 'BUQUE PRUEBA',
        voyageNumber: 'V001',
        portOfCall: 'GTSTC',
        createdAt: DateTime.utc(2026, 10, 9, 7),
        sources: sources,
        published: true,
      );

  // El plan de carga: dos llenos que suben en GTSTC y una reserva del grupo
  // 22G1 · JMKWL · LNA.
  ContainerUnit unit(String id, String position) => ContainerUnit(
      id: 'uuid-$id',
      containerId: id,
      isoSizeType: '22G1',
      status: ContainerStatus.full,
      stowagePosition: IsoCoordinateParser.parse(position),
      portOfLoading: 'GTSTC',
      portOfDischarge: 'JMKWL',
      operatorCode: 'LNA');
  ReservedSlot reserve(String position) => ReservedSlot(
      stowagePosition: IsoCoordinateParser.parse(position),
      isoSizeType: '22G1',
      status: ContainerStatus.empty,
      portOfLoading: 'GTSTC',
      portOfDischarge: 'JMKWL',
      operatorCode: 'LNA',
      nominalWeight: 2100);
  VesselVoyage loadingPlan() => VesselVoyage(
      id: 'v',
      vessel: const Vessel(id: 'b', name: 'BUQUE PRUEBA'),
      voyageNumber: 'V001',
      containers: [unit('TSTU0000014', '0030102'), unit('TSTU0000035', '0030104')],
      reservedSlots: [reserve('0050102')],
      portOfCall: 'GTSTC');
  OperationState derive(Operation operation, Iterable<MovementRecord> records) {
    final source = operation.source(OperationSourceKind.exportList);
    final list = source == null
        ? null
        : ExportList.fromJson(jsonDecode(source.content) as Map<String, dynamic>);
    return const OperationStateDeriver().derive(
        OperationPlan.build(portOfCall: 'GTSTC', loading: loadingPlan(), list: list),
        records.map((r) => r.movement));
  }

  // Un movimiento de otro dispositivo, que el servidor hace llegar.
  final fromOther = Movement(
    id: '2f0c1d7e-3a94-4c55-9b7e-6a1f0e2d8c41',
    operationId: operationId,
    type: MovementType.loadFull,
    target: 'C:TSTU0000035',
    payload: const {'position': '0030104'},
    author: const MovementAuthor(uid: 'uid-otro', name: 'Tarjador 2', role: OperatorRole.dock),
    deviceId: 'otro-dispositivo',
    sequence: 1,
    createdAt: DateTime.utc(2026, 10, 29, 8, 30),
  );

  Future<MovementLogRepositoryImpl> open() async => MovementLogRepositoryImpl(
      await HiveMovementDataSource.open(
          directory: directory.path, namespace: namespace),
      clock: () {
        now = now.add(const Duration(seconds: 1));
        return now;
      });
  Future<Operation?> local(MovementLogRepositoryImpl log) async =>
      (await log.getOperation(operationId)).getOrElse(() => null);
  Future<List<MovementRecord>> records(MovementLogRepositoryImpl log) async =>
      (await log.records(operationId)).getOrElse(() => const []);

  /// Espera a que la cola y Hive terminen: son escrituras de disco reales.
  Future<void> until(Future<bool> Function() condition) async {
    for (var i = 0; i < 300; i++) {
      if (await condition()) return;
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    fail('No se cumplió a tiempo');
  }

  Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 80));

  SyncEngine engine(MovementLogRepositoryImpl log, FakeCloud cloud, Operation operation) =>
      SyncEngine(
          log: log,
          remote: cloud,
          operation: operation,
          clock: clock,
          tick: const Duration(hours: 1));

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('t127_listado_');
    namespace = 't127_${DateTime.now().microsecondsSinceEpoch}';
    now = DateTime.utc(2026, 10, 29, 8);
  });

  tearDown(() async {
    if (directory.existsSync()) await directory.delete(recursive: true);
  });

  group('el motor: la revisión llega al muelle', () {
    test('la revisión 1 llega sin movimientos previos: la operación local guarda el listado y el estado lo dice',
        () async {
      final log = await open();
      await log.saveOperation(published());
      final cloud = FakeCloud(clock: clock)..authorization[dock.uid] = RemoteAuthorization.active;
      final sync = engine(log, cloud, published());
      await sync.start(dock);
      await until(() async => sync.current.state == SyncState.upToDate);
      expect(sync.current.listArrival, isNull);
      expect((await local(log))!.exportListRevision, 0);

      cloud.server.reviseList(listJson(rows1));
      await until(() async => (await local(log))?.exportListRevision == 1);
      final source = (await local(log))!.source(OperationSourceKind.exportList)!;
      expect(source.content, listJson(rows1));
      expect(source.fileName, 'listado.xlsx');
      expect(source.revision, 1);
      expect((await local(log))!.source(OperationSourceKind.loadingBaplie), planSource,
          reason: 'el plan de carga no cambia');
      await until(() async =>
          sync.current.listArrival == const ListArrival(revision: 1, rows: 2));
      expect(cloud.listPartsRequests, 1);

      // El mismo manifiesto otra vez (el servidor lo repite al reconectar) no
      // vuelve a bajar nada.
      cloud.goOnline();
      await settle();
      expect(cloud.listPartsRequests, 1);
      await sync.stop();
      await log.close();
    });

    test('la revisión 2 llega con movimientos: se conservan y el estado se vuelve a derivar con el listado nuevo',
        () async {
      final log = await open();
      final before = published(sources: [planSource, listSource(listJson(rows1), revision: 1)]);
      await log.saveOperation(before);
      final cloud = FakeCloud(clock: clock)..authorization[dock.uid] = RemoteAuthorization.active;
      // La nube ya tiene la revisión 1, la misma del dispositivo.
      cloud.server.reviseList(listJson(rows1));
      final sync = engine(log, cloud, before);
      await sync.start(dock);
      final loaded = (await log.append(
              MovementDraft.loadFull(operationId, 'TSTU0000014', '0030102', order: 1),
              dock.author))
          .getOrElse(() => throw StateError('no se anexó'));
      final assigned = (await log.append(
              MovementDraft.assignEmpty(operationId, '0050102', 'TSTU0000020', 2185, order: 2),
              dock.author))
          .getOrElse(() => throw StateError('no se anexó'));
      await until(() async =>
          (await records(log)).every((r) => r.state == SendState.confirmed));
      expect(cloud.listPartsRequests, 0, reason: 'la revisión 1 ya estaba en el dispositivo');
      final stateBefore = derive((await local(log))!, await records(log));
      expect(stateBefore['R:0050102']!.assignedContainer, 'TSTU0000020');
      expect(stateBefore.conflicts, isEmpty, reason: 'con el listado 1 el vacío es de su grupo');

      cloud.server.reviseList(listJson(rows2));
      await until(() async => (await local(log))?.exportListRevision == 2);
      final kept = await records(log);
      expect(kept.map((r) => r.movement.id),
          unorderedEquals([loaded.movement.id, assigned.movement.id]));
      expect(kept.map((r) => r.state).toSet(), {SendState.confirmed});
      expect(cloud.docs, hasLength(2), reason: 'la nube no recibió ni perdió movimientos');
      final after = derive((await local(log))!, kept);
      expect(after['C:TSTU0000014']!.state, ItemState.moved);
      expect(after['C:TSTU0000014']!.position, '0030102');
      expect(after['R:0050102']!.state, ItemState.moved);
      expect(after['R:0050102']!.assignedContainer, 'TSTU0000020');
      // El listado nuevo pone el vacío en otra línea: lo mismo que se ve al
      // importarlo antes de publicar, un «vacío de otro grupo» a la vista.
      expect(after.effectivePlan!.emptyGroups['TSTU0000020']!.line, 'LNB');
      expect(after.conflicts.map((c) => c.kind), contains(ConflictKind.otherGroup));
      await until(() async =>
          sync.current.listArrival == const ListArrival(revision: 2, rows: 3));
      await sync.stop();
      await log.close();
    });

    test('sin red, el muelle se queda con el listado anterior y baja el nuevo al reconectar',
        () async {
      final log = await open();
      final before = published(sources: [planSource, listSource(listJson(rows1), revision: 1)]);
      await log.saveOperation(before);
      final cloud = FakeCloud(clock: clock)..authorization[dock.uid] = RemoteAuthorization.active;
      cloud.server.reviseList(listJson(rows1));
      final sync = engine(log, cloud, before);
      await sync.start(dock);
      await until(() async => sync.current.state == SyncState.upToDate);

      cloud.goOffline();
      cloud.server.reviseList(listJson(rows2));
      await settle();
      await until(() async => sync.current.state == SyncState.offline);
      expect((await local(log))!.exportListRevision, 1);
      expect((await local(log))!.source(OperationSourceKind.exportList)!.content,
          listJson(rows1));
      expect(sync.current.listArrival, isNull);
      expect(cloud.listPartsRequests, 0);

      cloud.goOnline();
      await until(() async => (await local(log))?.exportListRevision == 2);
      expect((await local(log))!.source(OperationSourceKind.exportList)!.content,
          listJson(rows2));
      await until(() async =>
          sync.current.listArrival == const ListArrival(revision: 2, rows: 3));
      await sync.stop();
      await log.close();
    });

    test('si los trozos no bajan a la primera, el motor lo reintenta con el siguiente contacto con el servidor',
        () async {
      final log = await open();
      await log.saveOperation(published());
      final cloud = FakeCloud(clock: clock)..authorization[dock.uid] = RemoteAuthorization.active;
      final sync = engine(log, cloud, published());
      await sync.start(dock);
      await until(() async => sync.current.state == SyncState.upToDate);

      cloud.listPartsFailures = 1;
      cloud.server.reviseList(listJson(rows1));
      await until(() async => cloud.listPartsRequests == 1);
      await settle();
      expect((await local(log))!.exportListRevision, 0);
      expect(sync.current.listArrival, isNull);

      // Llega un movimiento de otro dispositivo: el servidor contesta y el
      // motor vuelve a pedir los trozos.
      cloud.receiveWithoutAck(fromOther);
      await until(() async => (await local(log))?.exportListRevision == 1);
      expect(cloud.listPartsRequests, 2);
      await until(() async => (await records(log)).length == 1);
      await sync.stop();
      await log.close();
    });

    test('una revisión cuyos trozos no cuadran con el manifiesto se ignora: el muelle sigue con su listado',
        () async {
      final log = await open();
      final before = published(sources: [planSource, listSource(listJson(rows1), revision: 1)]);
      await log.saveOperation(before);
      final cloud = FakeCloud(clock: clock)..authorization[dock.uid] = RemoteAuthorization.active;
      cloud.server.reviseList(listJson(rows1));
      final sync = engine(log, cloud, before);
      await sync.start(dock);
      await until(() async => sync.current.state == SyncState.upToDate);

      // La revisión 2 llega con un trozo cuyo texto no es el de su huella.
      cloud.goOffline();
      cloud.server.reviseList(listJson(rows2));
      final index = cloud.server.sourceParts.indexWhere((p) => p.revision == 2);
      final part = cloud.server.sourceParts[index];
      cloud.server.sourceParts[index] = SourcePart(
          id: part.id,
          kind: part.kind,
          part: part.part,
          parts: part.parts,
          sha256: part.sha256,
          content: '${part.content} ',
          revision: part.revision);
      cloud.goOnline();
      await until(() async => cloud.listPartsRequests == 1);
      await settle();
      expect((await local(log))!.exportListRevision, 1);
      expect((await local(log))!.source(OperationSourceKind.exportList)!.content,
          listJson(rows1));
      expect(sync.current.listArrival, isNull);

      // Otro contacto con el servidor no vuelve a pedir esa revisión.
      cloud.receiveWithoutAck(fromOther);
      await until(() async => (await records(log)).length == 1);
      await settle();
      expect(cloud.listPartsRequests, 1);
      await sync.stop();
      await log.close();
    });

    test('el dispositivo que acaba de revisar el listado no lo recibe como novedad',
        () async {
      final log = await open();
      await log.saveOperation(published());
      final cloud = FakeCloud(clock: clock)..authorization[dock.uid] = RemoteAuthorization.active;
      final sync = engine(log, cloud, published());
      await sync.start(dock);
      await until(() async => sync.current.state == SyncState.upToDate);

      // `replaceSource` guardó la revisión 1 en local antes de que el eco del
      // manifiesto llegue al motor que ya corría.
      await log.saveOperation(
          published(sources: [planSource, listSource(listJson(rows1), revision: 1)]));
      cloud.server.reviseList(listJson(rows1));
      await settle();
      await settle();
      expect(cloud.listPartsRequests, 0);
      expect(sync.current.listArrival, isNull);
      expect((await local(log))!.exportListRevision, 1);
      await sync.stop();
      await log.close();
    });
  });

  group('unirse toma la última revisión (lo que join arma con assembleSource)', () {
    test('con revisión en el manifiesto, solo los trozos de esa revisión, aunque queden los anteriores',
        () {
      final server = FakeServer()..publishList(listJson(rows1));
      server.reviseList(listJson(rows2));
      final third = [...rows2, row(10, 'TSTU0000040')];
      server.reviseList(listJson(third));
      expect(server.listManifest!.revision, 2);
      expect(server.sourceParts.map((p) => p.id),
          ['export_list-0', 'export_list-r1-0', 'export_list-r2-0']);
      final joined = assembleSource(server.listManifest!, server.sourceParts)!;
      expect(joined.content, listJson(third));
      expect(joined.revision, 2);
      expect(exportListRows(joined.content), 4);
      // La revisión 1, si el manifiesto la declarara.
      final first = assembleSource(
          packSource(listSource(listJson(rows2)), revision: 1).entry, server.sourceParts)!;
      expect(first.content, listJson(rows2));
      expect(first.revision, 1);
    });

    test('una operación sin revisión se sigue uniendo: el manifiesto sin revisión toma los trozos publicados con ella',
        () {
      final server = FakeServer()..publishList(listJson(rows1));
      final entry = SourceManifestEntry.read(OperationSourceKind.exportList, {
        'fileName': 'listado.xlsx',
        'sha256': sourceHash(listJson(rows1)),
        'parts': 1,
        'length': listJson(rows1).length,
      })!;
      expect(entry.revision, isNull);
      final joined = assembleSource(entry, server.sourceParts)!;
      expect(joined.revision, isNull);
      expect(joined.content, listJson(rows1));
      // Un trozo de una revisión posterior no se cuela en un manifiesto sin
      // revisión.
      server.reviseList(listJson(rows2));
      expect(assembleSource(entry, server.sourceParts)!.content, listJson(rows1));
      // Lo que no es una entrada del manifiesto, no se lee.
      expect(SourceManifestEntry.read(OperationSourceKind.exportList, null), isNull);
      expect(SourceManifestEntry.read(OperationSourceKind.exportList, {'parts': 'x'}), isNull);
    });

    test('trozos que no cuadran con el manifiesto no arman la fuente', () {
      final server = FakeServer()..reviseList(listJson(rows1));
      final entry = server.listManifest!;
      final part = server.sourceParts.single;
      SourcePart altered({String? content, int? parts, String? sha256}) => SourcePart(
          id: part.id,
          kind: part.kind,
          part: part.part,
          parts: parts ?? part.parts,
          sha256: sha256 ?? part.sha256,
          content: content ?? part.content,
          revision: part.revision);
      expect(assembleSource(entry, [altered(content: 'otro')]), isNull,
          reason: 'la huella del texto unido no es la del manifiesto');
      expect(assembleSource(entry, [altered(sha256: 'f' * 64)]), isNull,
          reason: 'la huella del trozo no es la del manifiesto');
      expect(assembleSource(entry, const []), isNull, reason: 'falta el trozo');
      expect(assembleSource(entry, [part, part]), isNull, reason: 'sobra un trozo');
      expect(assembleSource(entry, [part]), isNotNull);
      expect(SourcePart.read(null), isNull);
      expect(SourcePart.read({'kind': 'otro', 'part': 0}), isNull);
    });

    test('la fuente guarda su revisión y una guardada antes de T-127 se lee sin ella', () {
      final source = listSource(listJson(rows1), revision: 3);
      final back = OperationSource.fromJson(
          jsonDecode(jsonEncode(source.toJson())) as Map<String, dynamic>);
      expect(back, source);
      expect(back.revision, 3);
      final old = OperationSource.fromJson(
          {'kind': 'export_list', 'fileName': 'l.xlsx', 'content': '{}'});
      expect(old.revision, isNull);
      expect(old.toJson().containsKey('revision'), isFalse);
      expect(published(sources: [planSource, source]).exportListRevision, 3);
      expect(published().exportListRevision, 0);
      expect(sourcePartId(OperationSourceKind.exportList, 0, revision: 2), 'export_list-r2-0');
      expect(sourcePartId(OperationSourceKind.loadingBaplie, 1), 'loading_baplie-1');
      final packed = packSource(source, revision: 3);
      expect(packed.entry.toMap(), {
        'fileName': 'listado.xlsx',
        'sha256': sourceHash(source.content),
        'parts': 1,
        'length': source.content.length,
        'revision': 3,
      });
      expect(packed.parts.single.toMap()['id'], 'export_list-r3-0');
      expect(packed.parts.single.toMap()['revision'], 3);
      expect(packSource(planSource).parts.single.toMap().containsKey('revision'), isFalse);
    });
  });

  group('la oficina: OperationSources.save en una operación publicada', () {
    const voyage = VesselVoyage(
      id: 'v',
      vessel: Vessel(id: 'b', name: 'BUQUE PRUEBA'),
      voyageNumber: 'V001',
      containers: [],
      bays: {},
      portOfCall: 'GTSTC',
    );

    test('el listado nuevo sube por replaceSource y lo que la nube devuelve queda en la operación',
        () async {
      final log = T75MemoryLog();
      await log.saveOperation(published());
      final sync = _RecordingSync(log);
      final updated = await OperationSources.save(
          log, voyage, 'GTSTC', listSource(listJson(rows1)),
          sync: sync);
      expect(sync.calls.map((s) => s.kind), [OperationSourceKind.exportList]);
      expect(updated.exportListRevision, 1);
      expect(updated.source(OperationSourceKind.exportList)!.content, listJson(rows1));
      expect(updated.source(OperationSourceKind.loadingBaplie), planSource);
      expect(log.operations.single.exportListRevision, 1);
      // Volver a guardar el mismo listado no sube nada.
      final same = await OperationSources.save(
          log, voyage, 'GTSTC', listSource(listJson(rows1)),
          sync: sync);
      expect(same.exportListRevision, 1);
      expect(sync.calls, hasLength(1));
      // Otro listado: la revisión 2.
      final again = await OperationSources.save(
          log, voyage, 'GTSTC', listSource(listJson(rows2)),
          sync: sync);
      expect(again.exportListRevision, 2);
      expect(sync.calls, hasLength(2));
    });

    test('si la nube no acepta la revisión, se lanza su fallo y nada local cambia', () async {
      final log = T75MemoryLog();
      await log.saveOperation(published());
      final sync = _RecordingSync(log,
          failure: const FirestoreFailure(
              code: 'permission-denied', message: 'La nube no aceptó el listado.'));
      await expectLater(
          OperationSources.save(log, voyage, 'GTSTC', listSource(listJson(rows1)), sync: sync),
          throwsA(isA<FirestoreFailure>()));
      expect(sync.calls, hasLength(1));
      expect(log.operations.single, published());
    });

    test('un BAPLIE distinto, una operación cerrada o una compilación sin nube no cambian nada',
        () async {
      final log = T75MemoryLog();
      await log.saveOperation(published());
      final sync = _RecordingSync(log);
      await expectLater(
          OperationSources.save(
              log,
              voyage,
              'GTSTC',
              const OperationSource(
                  kind: OperationSourceKind.loadingBaplie, fileName: 'B.edi', content: 'UNB+B'),
              sync: sync),
          throwsA(isA<ValidationFailure>()));
      await expectLater(
          OperationSources.save(log, voyage, 'GTSTC', listSource(listJson(rows1))),
          throwsA(isA<ValidationFailure>()),
          reason: 'sin la nube no hay por dónde subir la revisión');
      await log.saveOperation(published().copyWith(closedAt: DateTime.utc(2026, 10, 29)));
      await expectLater(
          OperationSources.save(log, voyage, 'GTSTC', listSource(listJson(rows1)), sync: sync),
          throwsA(isA<ValidationFailure>()));
      expect(sync.calls, isEmpty);
      expect(log.operations.single.source(OperationSourceKind.exportList), isNull);
    });
  });

  group('el cruce dice lo que el listado nuevo cambia en lo ya operado', () {
    test('cuenta los cargados que no están en el listado nuevo y los vacíos asignados que cambian de grupo',
        () {
      var sequence = 0;
      Movement mv(MovementType type, String target, Map<String, Object?> payload) {
        sequence++;
        return Movement(
          id: 'm$sequence',
          operationId: operationId,
          type: type,
          target: target,
          payload: payload,
          author: dock.author,
          deviceId: 'd',
          sequence: sequence,
          createdAt: DateTime.utc(2026, 10, 29, 9, sequence),
        );
      }

      final movements = [
        mv(MovementType.loadFull, 'C:TSTU0000014', {'position': '0030102', 'order': 1}),
        // H4: un lleno cargado por su número, sin fila en el listado.
        mv(MovementType.loadFull, 'C:TSTU0000035', {'position': '0030104'}),
        mv(MovementType.assignEmpty, 'R:0050102',
            {'container': 'TSTU0000020', 'tareKg': 2185, 'order': 2}),
      ];
      final previous = ExportList(fileName: 'l', rows: rows1);
      final state = const OperationStateDeriver().derive(
          OperationPlan.build(portOfCall: 'GTSTC', loading: loadingPlan(), list: previous),
          movements);
      final next = ExportList(fileName: 'l', rows: [
        row(7, 'TSTU0000014'),
        row(8, 'TSTU0000020', empty: true, line: 'LNB'),
      ]);
      final impact = ExportListCrossChecker.revisionImpact(state, previous, next);
      expect(impact.loadedNotListed, ['TSTU0000035']);
      expect(impact.emptiesRegrouped, ['TSTU0000020']);
      expect(impact.isEmpty, isFalse);

      // Con todas las filas y el mismo grupo, nada que avisar.
      final same = ExportList(fileName: 'l', rows: [...rows1, row(3, 'TSTU0000035')]);
      expect(ExportListCrossChecker.revisionImpact(state, previous, same).isEmpty, isTrue);

      // Sin listado anterior, el grupo se compara con el de la reserva.
      final without = const OperationStateDeriver()
          .derive(OperationPlan.build(portOfCall: 'GTSTC', loading: loadingPlan()), movements);
      expect(ExportListCrossChecker.revisionImpact(without, null, next).emptiesRegrouped,
          ['TSTU0000020']);
      expect(ExportListCrossChecker.revisionImpact(without, null, same).emptiesRegrouped,
          isEmpty);
      // Un vacío ya asignado que el listado nuevo no trae cuenta como cargado
      // sin fila, no como cambio de grupo.
      final onlyFulls = ExportList(fileName: 'l', rows: [row(1, 'TSTU0000014'), row(3, 'TSTU0000035')]);
      final gone = ExportListCrossChecker.revisionImpact(state, previous, onlyFulls);
      expect(gone.loadedNotListed, ['TSTU0000020']);
      expect(gone.emptiesRegrouped, isEmpty);
    });
  });
}

/// La nube de la oficina en las pruebas del dominio: anota cada
/// `replaceSource` y, si no se le pide fallar, hace lo que hace Firestore:
/// la fuente con la revisión siguiente queda en la operación local.
class _RecordingSync implements OperationSyncRepository {
  _RecordingSync(this.log, {this.failure});

  final T75MemoryLog log;
  final Failure? failure;
  final calls = <OperationSource>[];

  @override
  Future<Either<Failure, Operation>> replaceSource(
      Operation operation, OperationSource source) async {
    calls.add(source);
    final failure = this.failure;
    if (failure != null) return Left(failure);
    final updated = operation.copyWith(sources: [
      ...operation.sources.where((s) => s.kind != source.kind),
      source.withRevision(operation.exportListRevision + 1),
    ]);
    await log.saveOperation(updated);
    return Right(updated);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
