import 'dart:io';
import 'dart:math';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';
import 'package:baystream/features/vessel/domain/services/operation_progress.dart';
import 'package:baystream/features/vessel/data/datasources/hive_movement_data_source.dart';
import 'package:baystream/features/vessel/data/repositories/movement_log_repository_impl.dart';
import 'package:baystream/features/vessel/data/repositories/sync_engine.dart';
import 'package:baystream/features/vessel/data/repositories/firestore_operation_sync.dart';
import 'package:baystream/features/vessel/domain/repositories/session_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/t76_fixture.dart';
import 'support/t79_fake_cloud.dart';

final t84Covers = {
  3: HatchCoverDeclaration(kind: HatchCoverKind.crane, covers: [
    {2, 4},
    {6}
  ]),
  5: HatchCoverDeclaration(kind: HatchCoverKind.automatic, covers: [
    {2}
  ])
};
final t84Arrival =
    t76Voyage([t76Unit('TSTU0000001', '0030202', incoming: true)]);
final t84Loading = t76Voyage(
    [t76Unit('TSTU0000002', '0030202'), t76Unit('TSTU0000003', '0030402')]);
LoadingOperation t84Operation(Iterable<Movement> events,
        {bool declared = true}) =>
    LoadingOperation.build(
        operationId: 'op',
        arrival: t84Arrival,
        loading: t84Loading,
        list: ExportList(
            fileName: 'prueba',
            rows: [t76Row(1, 'TSTU0000002'), t76Row(2, 'TSTU0000003')]),
        movements: events,
        hatchCovers: declared ? t84Covers : const {});

void main() {
  test('T-84 perfil publicado no contiene arrays anidados y conserva todas las tapas', () {
    final profile = VesselProfile.proposeFrom(t84Loading).copyWith(hatchCovers: t84Covers);
    final wire = FirestoreProfileCodec.encode(profile);
    void inspect(Object? value) {
      if (value is List) {
        expect(value.any((e) => e is List), isFalse, reason: 'Firestore Standard');
        for (final entry in value) { inspect(entry); }
      } else if (value is Map) {
        for (final entry in value.values) { inspect(entry); }
      }
    }
    inspect(wire);
    expect(FirestoreProfileCodec.decode(wire), profile);
  });
  test('T-84 codec publicado sigue leyendo perfiles históricos y JSON local', () {
    final profile = VesselProfile.proposeFrom(t84Loading);
    final old = profile.toJson()..remove('hatchCovers')..remove('observedHoldBayNumbers');
    expect(FirestoreProfileCodec.decode(old).hatchCovers, isEmpty);
    final withCovers = profile.copyWith(hatchCovers: t84Covers);
    expect(FirestoreProfileCodec.decode(withCovers.toJson()), withCovers);
  });
  test('T-84 codec conserva T1 y T2 sin depender del orden del mapa y rechaza huecos', () {
    final profile = VesselProfile.proposeFrom(t84Loading).copyWith(hatchCovers: t84Covers);
    final wire = FirestoreProfileCodec.encode(profile);
    final declaration = (wire['hatchCovers'] as Map)['3'] as Map;
    declaration['covers'] = {'2': [6], '1': [2, 4]};
    expect(FirestoreProfileCodec.decode(wire), profile);
    declaration['covers'] = {'2': [6]};
    expect(() => FirestoreProfileCodec.decode(wire), throwsFormatException);
  });
  Movement cover(bool remove, int sequence) => t76Movement(
      MovementDraft.hatchCover('op', 3, 1, remove: remove), sequence);
  test('T-84 inicialmente puestas, automática y sin tapas inventadas', () {
    final state = t84Operation([]).state;
    expect(state.hatchCovers, hasLength(3));
    expect(
        state.hatchCovers.values
            .every((c) => !c.removed && c.movementId == null),
        isTrue);
    expect(state.hatchCovers['T:5-1']!.label, 'Automática');
    expect(t84Operation([], declared: false).state.hatchCovers, isEmpty);
  });
  test('T-84 aviso solo para fila cubierta de bodega y tapa puesta', () {
    final state = t84Operation([]).state;
    expect(state.closedCoverAt('0030202')!.label, 'T1');
    expect(state.closedCoverAt('0030602')!.label, 'T2');
    expect(state.closedCoverAt('0030802'), isNull);
    expect(state.closedCoverAt('0030282'), isNull);
    expect(state.closedCoverAt('0070202'), isNull);
    expect(
        t84Operation([cover(true, 1)]).state.closedCoverAt('0030202'), isNull);
    expect(t84Operation([], declared: false).state.closedCoverAt('0030202'),
        isNull);
  });
  test('T-84 quitar y reponer no alteran contenedores', () {
    final initial = t84Operation([]).state.occupancy;
    expect(t84Operation([cover(true, 1)]).state.occupancy, initial);
    final after = t84Operation([cover(true, 1), cover(false, 2)]).state;
    expect(after.occupancy, initial);
    expect(after.hatchCovers['T:3-1']!.removed, isFalse);
    expect(after.conflicts, isEmpty);
  });
  test('T-84 quitar dos veces conserva primero y segundo queda en conflicto',
      () {
    final state = t84Operation([cover(true, 1), cover(true, 2)]).state;
    expect(state.conflicts.single.kind, ConflictKind.invalidHatchCover);
    expect(state.conflicts.single.movementId, 'm2');
    expect(state.hatchCovers['T:3-1']!.movementId, 'm1');
    expect(state.duplicates, isEmpty);
  });
  test('T-84 reponer sin quitar queda en conflicto y no modifica estado', () {
    final state = t84Operation([cover(false, 1)]).state;
    expect(state.conflicts.single.kind, ConflictKind.invalidHatchCover);
    expect(state.hatchCovers['T:3-1']!.movementId, isNull);
  });
  test('T-84 annul de quitar, reponer, conflicto y anulación restaura', () {
    final remove = cover(true, 1);
    final replace = cover(false, 2);
    final annul = t76Movement(
        MovementDraft.annul('op', replace.id, 'Error', target: replace.target),
        3);
    expect(
        t84Operation([remove, replace, annul])
            .state
            .hatchCovers['T:3-1']!
            .removed,
        isTrue);
    final annulAnnul =
        t76Movement(MovementDraft.annul('op', annul.id, 'Restaurar'), 4);
    expect(
        t84Operation([remove, replace, annul, annulAnnul])
            .state
            .hatchCovers['T:3-1']!
            .removed,
        isFalse);
    final undoRemove =
        t76Movement(MovementDraft.annul('op', remove.id, 'Error'), 5);
    expect(
        t84Operation([remove, undoRemove])
            .state
            .hatchCovers['T:3-1']!
            .movementId,
        isNull);
    final duplicate = cover(true, 6);
    final undoConflict =
        t76Movement(MovementDraft.annul('op', duplicate.id, 'Error'), 7);
    expect(t84Operation([remove, duplicate, undoConflict]).state.conflicts,
        isEmpty);
  });
  test('T-84 tres órdenes de llegada convergen con conflictos y annul', () {
    final history = [
      cover(true, 1),
      cover(true, 2),
      cover(false, 3),
      t76Movement(MovementDraft.annul('op', 'm2', 'Error'), 4)
    ];
    final expected = t84Operation(history).state;
    for (final events in [
      history.reversed,
      [...history]..shuffle(Random(84))
    ]) {
      final state = t84Operation(events).state;
      expect(state.hatchCovers, expected.hatchCovers);
      expect(state.conflicts, expected.conflicts);
      expect(state.occupancy, expected.occupancy);
    }
  });
  test('T-84 avance cuenta estados de tapas y último movimiento en cada paso',
      () {
    final history = [cover(true, 1), cover(false, 2), cover(true, 3)];
    for (var i = 0; i <= history.length; i++) {
      final progress = OperationProgress.build(t84Operation(history.take(i)));
      final row = progress.bays.firstWhere((b) => b.bay == 3);
      expect(row.coversDeclared, 2);
      expect(progress.total.coversDeclared, 3);
      expect(row.coversRemoved, i.isOdd ? 1 : 0);
      expect(row.coversReplaced, i == 2 ? 1 : 0);
      expect(row.last?.id, i == 0 ? null : 'm$i');
    }
    final progress =
        OperationProgress.build(t84Operation([cover(true, 1), cover(true, 2)]));
    expect(progress.bays.firstWhere((b) => b.bay == 3).conflicts, 1);
    expect(progress.total.coversRemoved, 1);
  });
  test('T-84 payload mantiene forma publicada y rechaza extras', () {
    for (final remove in [true, false]) {
      final draft = MovementDraft.hatchCover('op', 14, 1, remove: remove);
      expect(draft.validate(), isNull);
      expect(draft.target, 'T:14-1');
      expect(draft.payload.keys, ['action']);
    }
    expect(
        MovementDraft.raw('op', MovementType.hatchCover, 'T:3-1',
            {'action': 'remove', 'bay': 3}).validate(),
        isNotNull);
    expect(MovementDraft.hatchCover('op', 3, 0, remove: true).validate(),
        isNotNull);
  });
  test(
      'T-84 cola real durable, ida y vuelta entre dos clientes; sin cuenta local',
      () async {
    final dir = await Directory.systemTemp.createTemp('t84-cola-');
    final op = Operation(
        id: 'op',
        vesselName: 'PRUEBA T-84',
        voyageNumber: 'V1',
        portOfCall: 'GTSTC',
        createdAt: DateTime.now(),
        published: true);
    const dock =
        Operator(uid: 'test-dock', name: 'Muelle', role: OperatorRole.dock);
    const office = Operator(
        uid: 'test-office', name: 'Oficina', role: OperatorRole.office);
    Future<MovementLogRepositoryImpl> open(String ns) async =>
        MovementLogRepositoryImpl(await HiveMovementDataSource.open(
            directory: dir.path, namespace: ns));
    var a = await open('t84a');
    final b = await open('t84b');
    await a.saveOperation(op);
    await b.saveOperation(op);
    final record = (await a.append(
            MovementDraft.hatchCover('op', 3, 1, remove: true), dock.author))
        .getOrElse(() => throw StateError('append'));
    expect(record.state, SendState.pending);
    await a.close();
    a = await open('t84a');
    final server = FakeServer();
    server.authorization.addAll({
      'test-dock': RemoteAuthorization.active,
      'test-office': RemoteAuthorization.active
    });
    final ea =
        SyncEngine(log: a, remote: FakeCloud(server: server), operation: op);
    final eb =
        SyncEngine(log: b, remote: FakeCloud(server: server), operation: op);
    await ea.start(dock);
    await eb.start(office);
    Future<void> until(bool Function(List<MovementRecord>) check,
        MovementLogRepositoryImpl log) async {
      for (var i = 0; i < 300; i++) {
        if (check((await log.records('op')).getOrElse(() => []))) return;
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      fail('La cola no convergió');
    }

    await until(
        (r) => r.length == 1 && r.every((e) => e.state == SendState.confirmed),
        b);
    await b.append(
        MovementDraft.hatchCover('op', 3, 1, remove: false), office.author);
    await until(
        (r) => r.length == 2 && r.every((e) => e.state == SendState.confirmed),
        a);
    final local = (await a.append(
            MovementDraft.hatchCover('op', 3, 2, remove: true),
            const MovementAuthor(name: 'Sin cuenta', role: OperatorRole.dock)))
        .getOrElse(() => throw StateError('append'));
    expect(local.state, SendState.localOnly);
    expect(server.docs, hasLength(2));
    await ea.stop();
    await eb.stop();
    await a.close();
    await b.close();
    await dir.delete(recursive: true);
  });
}
