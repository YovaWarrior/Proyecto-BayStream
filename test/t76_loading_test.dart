import 'dart:io';
import 'package:baystream/features/vessel/data/datasources/hive_movement_data_source.dart';
import 'package:baystream/features/vessel/data/repositories/movement_log_repository_impl.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/t76_fixture.dart';

void main() {
  final full = MovementDraft.loadFull('op', 'FULL0001234', '0030282', order: 1);
  final empty = MovementDraft.assignEmpty('op', '0030482', 'EMPTY0000012', 2185,
      order: 12);
  final discharge1 = MovementDraft.discharge('op', 'INCOMING1', '0030282');
  final discharge2 = MovementDraft.discharge('op', 'INCOMING2', '0030482');
  for (final (name, drafts) in [
    ('cargas primero', [full, empty, discharge1, discharge2]),
    ('descargas primero', [discharge1, discharge2, full, empty]),
    ('intercalados', [empty, discharge1, full, discharge2]),
  ]) {
    test('T-76 $name: carga y vacío ocupan celdas liberadas por llegada', () {
      final events = [
        for (var i = 0; i < drafts.length; i++) t76Movement(drafts[i], i + 1)
      ];
      for (final delivered in [events, events.reversed.toList()]) {
        final data = t76Operation(delivered);
        expect(data.state.conflicts, isEmpty);
        expect(data.state.occupancy,
            {'0030282': 'FULL0001234', '0030482': 'EMPTY0000012'});
        expect(data.discharge.pending, 0);
        expect(data.state['R:0030482']!.tareKg, 2185);
      }
    });
  }
  test('T-76 sin descarga hay celda ocupada; se resuelve al llegar la descarga',
      () {
    final load = t76Movement(full, 1);
    final start = t76Operation([load]);
    expect(start.state.conflicts.single.kind, ConflictKind.cellTaken);
    expect(start.state['C:FULL0001234']!.state, ItemState.planned);
    expect(start.movementOf('C:FULL0001234'), load);
    expect(t76Operation([load, t76Movement(discharge1, 2)]).state.conflicts,
        isEmpty);
  });
  test('T-76 annul de descarga restaura ocupación y anular annul la libera',
      () {
    final load = t76Movement(full, 1);
    final discharge = t76Movement(discharge1, 2);
    final undo =
        t76Movement(MovementDraft.annul('op', discharge.id, 'Error'), 3);
    expect(t76Operation([load, discharge, undo]).state.conflicts.single.kind,
        ConflictKind.cellTaken);
    final redo = t76Movement(MovementDraft.annul('op', undo.id, 'Sí bajó'), 4);
    expect(
        t76Operation([load, discharge, undo, redo]).state.conflicts, isEmpty);
  });
  test('T-76 una descarga cancelada no libera la celda', () {
    final data = t76Operation([
      t76Movement(full, 1),
      t76Movement(MovementDraft.cancelItem('op', 'C:INCOMING1', 'No baja'), 2),
      t76Movement(discharge1, 3)
    ]);
    expect(data.state.conflicts.map((c) => c.kind),
        contains(ConflictKind.cellTaken));
    expect(data.state.occupancy['0030282'], 'INCOMING1');
  });
  test('T-76 liberar llegada no elimina el choque entre dos cargas nuevas', () {
    final data = t76Operation([
      t76Movement(full, 1),
      t76Movement(MovementDraft.loadFull('op', 'FULL0005678', '0030282'), 2),
      t76Movement(discharge1, 3),
      t76Movement(discharge1, 4)
    ]);
    expect(data.state.occupancy['0030282'], 'FULL0001234');
    expect(data.state.conflicts.single.kind, ConflictKind.cellTaken);
    expect(data.state.duplicates, ['m4']);
  });
  test(
      'T-76 buscar OR y sufijo; una búsqueda ambigua conserva todas las coincidencias',
      () {
    final data = t76Operation();
    expect(data.search('1').single.order, 1);
    expect(data.search('1234').single.order, 1);
    expect(data.search('OR 2').single.order, 2);
    expect(data.search('').length, 2);
    expect(data.search('12', empties: true).single.tareKg, 2185);
    expect(data.search('NO_EXISTE'), isEmpty);
  });
  test('T-76 solo reservas libres del grupo, primero la bahía seleccionada',
      () {
    final data = t76Operation();
    final row = t76List.byOrder(12)!;
    expect(data.slots(row, selectedBay: 5).map((s) => s.key),
        ['R:0050282', 'R:0030882']);
    for (final position in ['0030482', '0030182', '0030382', '0030582']) {
      expect(() => data.draft(row, position), throwsStateError);
    }
    final freed = t76Operation([t76Movement(discharge2, 1)]);
    expect(freed.slots(row).map((s) => s.key), contains('R:0030482'));
    final draft = freed.draft(row, '0030482',
        seal: 'PRUEBA', operatedAt: DateTime.utc(2026, 1, 1, 8, 15));
    expect(draft.type, MovementType.assignEmpty);
    expect(draft.payload['tareKg'], 2185);
    expect(draft.payload['order'], 12);
    expect(draft.payload['seal'], 'PRUEBA');
    expect(draft.payload['operatedAt'], '2026-01-01T08:15:00.000Z');
  });
  test(
      'T-76 lleno solo en la posición publicada; cancelado y duplicado se rechazan',
      () {
    final row = t76List.byOrder(2)!;
    expect(() => t76Operation().draft(row, '0030282'), throwsStateError);
    final load = t76Movement(t76Operation().draft(row, '0030682'), 1);
    expect(() => t76Operation([load]).draft(row, '0030682'), throwsStateError);
    final cancel = t76Movement(
        MovementDraft.cancelItem('op', 'C:FULL0005678', 'No sube'), 1);
    expect(
        () => t76Operation([cancel]).draft(row, '0030682'), throwsStateError);
  });
  test(
      'T-76 corrección de vacío ocupa la reserva una vez y annul restaura el original',
      () {
    final row = t76List.byOrder(12)!;
    final first = t76Movement(t76Operation().draft(row, '0030882'), 1);
    final data = t76Operation([first]);
    expect(data.slots(row), isEmpty);
    final next = data.draft(t76List.byOrder(13)!, '0030882',
        correcting: first, reason: 'OR equivocado', seal: 'NUEVO');
    expect(next.payload['corrects'], first.id);
    final correction = t76Movement(next, 2);
    final corrected = t76Operation([first, correction]);
    expect(corrected.state.occupancy['0030882'], 'EMPTY0000013');
    expect(corrected.state['R:0030882']!.tareKg, 2300);
    expect(corrected.state.conflicts, isEmpty);
    final undo =
        t76Movement(MovementDraft.annul('op', correction.id, 'Restaurar'), 3);
    expect(t76Operation([first, correction, undo]).state.occupancy['0030882'],
        'EMPTY0000012');
  });
  test('T-76 el vacío numerado sigue load_full y no puede consumir una reserva',
      () {
    final emptyRow = t76Row(85, 'NUMBERED85', empty: true);
    final data = LoadingOperation.build(
        operationId: 'op',
        loading: t76Voyage([t76Unit('NUMBERED85', '0030282')],
            slots: [t76Slot('0030482')]),
        list: ExportList(fileName: 'sintetico', rows: [emptyRow]));
    expect(data.slots(emptyRow), isEmpty);
    expect(data.draft(emptyRow, '0030282').type, MovementType.loadFull);
  });
  test('T-76 buscar una carga par selecciona la bahía real, no su agrupación',
      () {
    final data = LoadingOperation.build(
        operationId: 'op',
        loading: t76Voyage([
          t76Unit('SHORT', '0030282'),
          t76Unit('LONG', '0040482').copyWith(isoSizeType: '45G1'),
        ]));
    expect(data.displayBay(4), 3);
    expect(data.bayOf('0040482'), 4);
  });
  test('T-76 una segunda corrección permite dejar vigente el último marchamo',
      () {
    final row = t76List.byOrder(2)!;
    final first =
        t76Movement(t76Operation().draft(row, '0030682', seal: 'A'), 1);
    final second = t76Movement(
        t76Operation([first]).draft(row, '0030682',
            seal: 'B', correcting: first, reason: 'Primer ajuste'),
        2);
    final third = t76Movement(
        t76Operation([first, second]).draft(row, '0030682',
            seal: 'C', correcting: second, reason: 'Segundo ajuste'),
        3);
    final data = t76Operation([first, second, third]);
    expect(data.state['C:FULL0005678']!.seal, 'C');
    expect(data.state.conflicts, isEmpty);
    final undo =
        t76Movement(MovementDraft.annul('op', third.id, 'Volver a B'), 4);
    final redo =
        t76Movement(MovementDraft.annul('op', undo.id, 'Restaurar C'), 5);
    for (final events in [
      [first, second, third, undo],
      [undo, third, first, second],
    ]) {
      final restored = t76Operation(events);
      expect(restored.state['C:FULL0005678']!.seal, 'B');
      expect(restored.state.conflicts, isEmpty);
      expect(restored.state.duplicates, isEmpty);
      expect(t76Operation([...events, redo]).state['C:FULL0005678']!.seal, 'C');
    }
  });
  test(
      'T-76 hora omitida igual a registro; hora explícita y marchamo persisten al reabrir',
      () async {
    final dir = await Directory.systemTemp.createTemp('baystream_t76_test_');
    final now = DateTime.utc(2026, 1, 1, 10);
    Future<MovementLogRepositoryImpl> open() async => MovementLogRepositoryImpl(
        await HiveMovementDataSource.open(
            directory: dir.path, namespace: 't76test'),
        clock: () => now);
    var repo = await open();
    try {
      const author = MovementAuthor(name: 'Prueba', role: OperatorRole.dock);
      final first = (await repo.append(full, author))
          .getOrElse(() => throw StateError('append'));
      final explicit = now.subtract(const Duration(hours: 1));
      await repo.append(
          MovementDraft.assignEmpty('op', '0030882', 'EMPTY0000012', 2185,
              operatedAt: explicit, seal: 'TEST'),
          author);
      await repo.close();
      repo = await open();
      final records = (await repo.records('op')).getOrElse(() => []);
      expect(records.length, 2);
      expect(first.movement.payload['operatedAt'], now.toIso8601String());
      expect(records.last.movement.payload['operatedAt'],
          explicit.toIso8601String());
      expect(records.last.movement.payload['seal'], 'TEST');
    } finally {
      await repo.close();
      await dir.delete(recursive: true);
    }
  });
}
