import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/load_check.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/t76_fixture.dart';

const swap = [
  PositionChange('C:FULL0001234', '0030282', '0030682'),
  PositionChange('C:FULL0005678', '0030682', '0030282'),
];
Movement request() =>
    t76Movement(MovementDraft.requestChange('op', swap, 'Intercambio'), 1);
Movement approval(Movement r, [int sequence = 2]) =>
    t76Movement(MovementDraft.approveChange('op', r, 'Aprobado'), sequence);

void main() {
  test('solicitar no altera el plan y queda pendiente', () {
    final op = t76Operation([request()]);
    expect(
        op.plan.loading[swap.first.target]!.plannedPosition, swap.first.from);
    expect(op.state.requests.single.status, ChangeRequestStatus.pending);
    expect(op.state.notDerived, isEmpty);
  });
  test('intercambio atómico y T-77 contra el plan efectivo', () {
    final r = request();
    final op = t76Operation([r, approval(r)]);
    expect(op.state.conflicts, isEmpty);
    expect(op.plan.loading[swap.first.target]!.plannedPosition, swap.first.to);
    expect(op.loading.containers.first.stowagePosition!.toIsoCode(),
        swap.first.to);
    expect(
        op
            .check(t76List.byOrder(1)!, swap.first.to)
            .issues
            .where((i) => i.kind == LoadIssueKind.outOfPlan),
        isEmpty);
    expect(
        op
            .check(t76List.byOrder(1)!, swap.first.from)
            .issues
            .where((i) => i.kind == LoadIssueKind.outOfPlan),
        hasLength(1));
    expect(op.state.requests.single.status, ChangeRequestStatus.approved);
  });
  test('aprobación posterior a las cargas, en tres órdenes de llegada', () {
    final r = request(), a = approval(request(), 10);
    final loads = [
      t76Movement(
          MovementDraft.loadFull('op', 'FULL0001234', swap.first.to), 3),
      t76Movement(MovementDraft.loadFull('op', 'FULL0005678', swap.last.to), 4),
      for (var i = 0; i < 2; i++)
        t76Movement(
            MovementDraft.discharge(
                'op', 'INCOMING${i + 1}', i == 0 ? '0030282' : '0030482'),
            5 + i),
    ];
    for (final events in [
      [r, ...loads, a],
      [a, ...loads.reversed, r],
      [loads[1], a, r, loads[0], ...loads.skip(2)]
    ]) {
      final op = t76Operation(events);
      expect(op.state.conflicts, isEmpty);
      expect(op.state['C:FULL0001234']!.position, swap.first.to);
      expect(op.state['C:FULL0005678']!.position, swap.last.to);
    }
  });
  test('rechazo conserva el plan y los dos fuera de plan', () {
    final r = request();
    final op = t76Operation([
      r,
      t76Movement(MovementDraft.rejectChange('op', r.id, 'No procede'), 2),
      t76Movement(MovementDraft.discharge('op', 'INCOMING1', '0030282'), 3),
      t76Movement(
          MovementDraft.loadFull('op', 'FULL0001234', swap.first.to), 4),
      t76Movement(MovementDraft.loadFull('op', 'FULL0005678', swap.last.to), 5),
    ]);
    expect(op.state.requests.single.status, ChangeRequestStatus.rejected);
    expect(op.state.conflicts.map((c) => c.kind),
        everyElement(ConflictKind.outOfPlan));
    expect(op.state.conflicts, hasLength(2));
  });
  test('origen obsoleto no aplica ninguna parte del lote', () {
    final r = request();
    final stale = t76Movement(
        MovementDraft.raw('op', MovementType.changePosition, null, {
          'changes': swap.map((c) => c.toJson()).toList(),
          'reason': 'Viejo'
        }),
        3);
    final op = t76Operation([r, approval(r), stale]);
    expect(op.state.conflicts.single.kind, ConflictKind.invalidChange);
    expect(op.plan.loading[swap.first.target]!.plannedPosition, swap.first.to);
  });
  test('anular aprobación restaura plan y solicitud pendiente', () {
    final r = request(), a = approval(request());
    final op = t76Operation(
        [r, a, t76Movement(MovementDraft.annul('op', a.id, 'Revisar'), 3)]);
    expect(op.state.requests.single.status, ChangeRequestStatus.pending);
    expect(
        op.plan.loading[swap.first.target]!.plannedPosition, swap.first.from);
  });
  test('una aprobación distinta de lo solicitado queda en conflicto', () {
    final r = request();
    final op = t76Operation([
      r,
      t76Movement(
          MovementDraft.raw('op', MovementType.changePosition, null, {
            'request': r.id,
            'changes': [
              const PositionChange('C:FULL0001234', '0030282', '0050482')
                  .toJson()
            ],
            'reason': 'Distinto'
          }),
          2)
    ]);
    expect(op.state.requests.single.status, ChangeRequestStatus.conflict);
    expect(op.state.conflicts.single.kind, ConflictKind.invalidChange);
  });
  test('reserva conserva su clave publicada después de cambiar de celda', () {
    final op = t76Operation([
      t76Movement(
          MovementDraft.raw('op', MovementType.changePosition, null, {
            'changes': [
              const PositionChange('R:0050282', '0050282', '0050482').toJson()
            ],
            'reason': 'Cambio'
          }),
          1)
    ]);
    expect(op.plan.loading['R:0050282']!.plannedPosition, '0050482');
    final row = t76List.byOrder(12)!;
    final draft = op.draft(row, '0050482');
    expect(draft.target, 'R:0050282');
  });
  test('forma de cambios: 1 a 4, motivo, sin objetos ni destinos repetidos',
      () {
    expect(
        MovementDraft.requestChange('op', swap, 'Motivo').validate(), isNull);
    expect(MovementDraft.requestChange('op', swap, '').validate(), isNotNull);
    final four = [
      for (var i = 0; i < 4; i++)
        PositionChange('C:BOX$i', '0030${i}82', '0050${i}82')
    ];
    expect(
        MovementDraft.requestChange('op', four, 'Motivo').validate(), isNull);
    expect(
        MovementDraft.requestChange(
                'op',
                [...four, const PositionChange('C:BOX4', '0030482', '0050482')],
                'Motivo')
            .validate(),
        isNotNull);
    expect(
        MovementDraft.requestChange('op', [swap.first, swap.first], 'Motivo')
            .validate(),
        isNotNull);
  });
}
