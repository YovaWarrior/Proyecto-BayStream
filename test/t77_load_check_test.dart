import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/load_check.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t76_fixture.dart';

/// T-77 · Validación antes de confirmar, con el fixture sintético de T-76:
/// llenos FULL0001234 (003-02-82, celda que ocupa INCOMING1, que baja aquí)
/// y FULL0005678 (003-06-82); reservas 22G1 · PAMIT · TEST en 003-04-82
/// (ocupada por INCOMING2, que baja aquí), 003-08-82 y 005-02-82, y tres de
/// otro grupo: 003-01-82 (45G1), 003-03-82 (JMKCT) y 003-05-82 (OTHER).
void main() {
  final full = t76List.byOrder(2)!;
  final twelve = t76List.byOrder(12)!;
  final thirteen = t76List.byOrder(13)!;

  LoadingOperation build(List<Movement> events,
          {VesselVoyage? loading, VesselVoyage? arrival, ExportList? list}) =>
      LoadingOperation.build(
          operationId: 'op',
          arrival: arrival ?? t76Arrival,
          loading: loading ?? t76Loading,
          list: list ?? t76List,
          movements: events);

  test('T-77 el plan tal cual no avisa', () {
    final data = t76Operation();
    final check = data.check(full, '0030682');
    expect(check.issues, isEmpty);
    expect(check.dischargeFirst, isNull);
    expect(check.stack!.status, StackWeightStatus.notEvaluated);
    expect(check.stack!.message, contains('el perfil no declara límite'));
    expect(data.check(twelve, '0030882').warns, isFalse);
  });

  test('T-77 un lleno fuera de su posición pide motivo y queda fuera de plan',
      () {
    final data = t76Operation();
    final check = data.check(full, '0030882');
    expect(check.issues.map((i) => i.kind), [LoadIssueKind.outOfPlan]);
    expect(check.issues.single.message, contains('003-06-82'));
    expect(check.needsReason, isTrue);
    expect(() => data.draft(full, '0030882'), throwsStateError);
    expect(() => data.draft(full, '0030882', reason: '   '), throwsStateError);
    final draft = data.draft(full, '0030882', reason: 'Lo puso la grúa ahí');
    expect(draft.payload['reason'], 'Lo puso la grúa ahí');
    final state = t76Operation([t76Movement(draft, 1)]).state;
    expect(state['C:FULL0005678']!.position, '0030882');
    expect(state.conflicts.single.kind, ConflictKind.outOfPlan);
  });

  test('T-77 un vacío en una reserva de otro grupo pide motivo y queda en conflicto',
      () {
    final data = t76Operation();
    for (final (position, word) in [
      ('0030382', 'puerto JMKCT'),
      ('0030582', 'línea OTHER'),
    ]) {
      final check = data.check(twelve, position);
      expect(check.issues.single.kind, LoadIssueKind.otherGroup);
      expect(check.issues.single.message, contains(word));
      expect(() => data.draft(twelve, position), throwsStateError);
    }
    final draft = data.draft(twelve, '0030382', reason: 'Sin reservas libres');
    final state = t76Operation([t76Movement(draft, 1)]).state;
    expect(state['R:0030382']!.state, ItemState.moved);
    expect(state.conflicts.single.kind, ConflictKind.otherGroup);
    expect(state.conflicts.single.message, contains('EMPTY0000012'));
    // Sin listado no se conoce el grupo del vacío: la derivación no inventa.
    final unknown = LoadingOperation.build(
            operationId: 'op',
            arrival: t76Arrival,
            loading: t76Loading,
            movements: [t76Movement(draft, 1)])
        .state;
    expect(unknown.conflicts, isEmpty);
  });

  test('T-77 las reservas que se ofrecen: libres, luego ocupadas que bajan, luego otros grupos',
      () {
    final data = t76Operation();
    expect(data.candidateSlots(twelve).map((s) => s.key),
        ['R:0030882', 'R:0050282', 'R:0030482']);
    expect(data.candidateSlots(twelve, otherGroups: true).map((s) => s.key), [
      'R:0030882',
      'R:0050282',
      'R:0030482',
      'R:0030182',
      'R:0030382',
      'R:0030582'
    ]);
    // Un lleno no tiene reservas que elegir.
    expect(data.candidateSlots(full, otherGroups: true), isEmpty);
  });

  test('T-77 20/40: un 40 en una posición de 20, o al revés, no se registra ni con motivo',
      () {
    // Una reserva de 45G1 en la bahía 003, impar, no recibe un 20 por ser
    // de otro grupo, pero sí por largo: el 20 cabe en la bahía impar.
    expect(t76Operation().check(twelve, '0030182').blocked, isFalse);
    final long = t76Row(3, 'LONG0000001')
        .copyWithForTest(listType: '45G1');
    final list = ExportList(fileName: 'sintetico', rows: [...t76List.rows, long]);
    final loading = t76Voyage([
      t76Unit('FULL0001234', '0030282'),
      t76Unit('FULL0005678', '0030682'),
      t76Unit('LONG0000001', '0040482').copyWith(isoSizeType: '45G1'),
    ]);
    final data = build(const [], loading: loading, list: list);
    expect(data.check(long, '0040482').issues, isEmpty);
    final odd = data.check(long, '0030682');
    expect(odd.issues.single.kind, LoadIssueKind.size);
    expect(odd.issues.single.message, contains('40 pies (45G1)'));
    expect(() => data.draft(long, '0030682', reason: 'Lo intento'),
        throwsStateError);
    final even = data.check(full, '0040282');
    expect(even.issues.single.kind, LoadIssueKind.size);
    expect(() => data.draft(full, '0040282', reason: 'Lo intento'),
        throwsStateError);
    expect(nominalLength('22G1'), 20);
    expect(nominalLength('L5G1'), 40);
    expect(nominalLength('9999'), isNull);
  });

  test('T-77 una celda que no existe no se registra ni con motivo', () {
    final data = t76Operation();
    for (final position in ['0039982', '0030898', '0990282', 'ABC', '']) {
      final check = data.check(full, position);
      expect(check.issues.single.kind, LoadIssueKind.unknownCell,
          reason: position);
      expect(() => data.draft(full, position, reason: 'Lo intento'),
          throwsStateError);
    }
  });

  test('T-77 celda ocupada por un contenedor que baja aquí: su descarga y la carga, sin conflicto',
      () {
    final row = t76List.byOrder(1)!;
    final data = t76Operation();
    final check = data.check(row, '0030282');
    expect(check.issues, isEmpty);
    expect(check.dischargeFirst!.container!.containerId, 'INCOMING1');
    expect(() => data.draft(row, '0030282'), throwsStateError);
    final discharge = t76Movement(data.dischargeDraft(check.dischargeFirst!), 1);
    final load =
        t76Movement(data.draft(row, '0030282', dischargeOccupant: true), 2);
    expect((discharge.type, discharge.target, discharge.position),
        (MovementType.discharge, 'C:INCOMING1', '0030282'));
    final after = t76Operation([discharge, load]);
    expect(after.state.conflicts, isEmpty);
    expect(after.state.occupancy['0030282'], 'FULL0001234');
    expect(after.discharge.pending, 1);
    // Lo mismo para una reserva: el vacío de su grupo espera esa descarga.
    final slot = data.check(twelve, '0030482');
    expect(slot.dischargeFirst!.container!.containerId, 'INCOMING2');
  });

  test('T-77 celda ocupada de verdad: lo que no baja aquí pide motivo y queda en conflicto',
      () {
    final arrival = t76Voyage([
      t76Unit('INCOMING1', '0030282', incoming: true),
      t76Unit('INCOMING2', '0030482', incoming: true),
      t76Unit('STAYS00001', '0030882'),
    ]);
    final data = build(const [], arrival: arrival);
    final check = data.check(twelve, '0030882');
    expect(check.dischargeFirst, isNull);
    expect(check.issues.single.kind, LoadIssueKind.cellTaken);
    expect(check.issues.single.message, contains('STAYS00001'));
    expect(() => data.draft(twelve, '0030882'), throwsStateError);
    final draft = data.draft(twelve, '0030882', reason: 'Revisar a bordo');
    final state = build([t76Movement(draft, 1)], arrival: arrival).state;
    expect(state.conflicts.single.kind, ConflictKind.cellTaken);
  });

  test('T-77 peso de la pila: avisa sobre el límite, «no evaluado» sin límite o sin pesos',
      () {
    final base = t76Voyage([t76Unit('FULL0001234', '0030282')],
        slots: [t76Slot('0030882'), t76Slot('0030884')]);
    final limited = base.withGeometry(
        base.geometry!.copyWith(stackWeightLimitKg: 4000),
        portOfCall: 'GTSTC');
    final first = build(const [], loading: limited, arrival: t76Voyage([]));
    final alone = first.check(twelve, '0030882');
    expect(alone.stack!.status, StackWeightStatus.withinLimit);
    expect(alone.stack!.message, 'Pila de cubierta 003, fila 08: 2.2 t de 4.0 t.');
    final assigned = t76Movement(first.draft(twelve, '0030882'), 1);
    final second = build([assigned], loading: limited, arrival: t76Voyage([]));
    final over = second.check(thirteen, '0030884');
    expect(over.stack!.knownKg, 2185 + 2300);
    expect(over.issues.single.kind, LoadIssueKind.stackWeight);
    expect(over.issues.single.message, contains('quedaría en 4.5 t'));
    expect(() => second.draft(thirteen, '0030884'), throwsStateError);
    expect(second.draft(thirteen, '0030884', reason: 'Plano aprobado').type,
        MovementType.assignEmpty);
    // Sin límite no se bloquea.
    final free = build([assigned], loading: base, arrival: t76Voyage([]));
    expect(free.check(thirteen, '0030884').issues, isEmpty);
    expect(free.check(thirteen, '0030884').stack!.status,
        StackWeightStatus.notEvaluated);
    // Un contenedor a bordo sin peso deja la pila «no evaluado».
    final unweighed = build(const [],
        loading: limited, arrival: t76Voyage([t76Unit('ABOARD0001', '0030886')]));
    final unknown = unweighed.check(twelve, '0030882');
    expect(unknown.stack!.status, StackWeightStatus.notEvaluated);
    expect(unknown.stack!.missing, 1);
    expect(unknown.stack!.message, contains('1 contenedor de la pila no trae peso'));
    expect(unknown.warns, isFalse);
  });

  test('T-77 corregir revisa la celda nueva sin contar la carga corregida', () {
    final first = t76Movement(t76Operation().draft(twelve, '0030882'), 1);
    final data = t76Operation([first]);
    final check = data.check(twelve, '0030382', correcting: first);
    expect(check.issues.single.kind, LoadIssueKind.otherGroup);
    final moved = t76Movement(
        data.draft(twelve, '0030382',
            correcting: first, reason: 'Quedó en la de al lado'),
        2);
    final state = t76Operation([first, moved]).state;
    expect(state['R:0030882']!.state, ItemState.planned);
    expect(state.conflicts.single.kind, ConflictKind.otherGroup);
  });
}

extension on ExportListRow {
  ExportListRow copyWithForTest({required String listType}) => ExportListRow(
      sheetRow: sheetRow,
      order: order,
      containerId: containerId,
      status: status,
      listType: listType,
      listPod: listPod,
      listLine: listLine,
      tareKg: tareKg);
}
