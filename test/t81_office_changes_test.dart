import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/session_repository.dart';
import 'package:baystream/features/vessel/domain/services/change_requests.dart';
import 'package:baystream/features/vessel/domain/services/operation_progress.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/t76_fixture.dart';

const office =
    Operator(uid: 'test-office', name: 'Oficina', role: OperatorRole.office);
const dock =
    Operator(uid: 'test-dock', name: 'Muelle', role: OperatorRole.dock);
final operation = Operation(
    id: 'op',
    vesselName: 'PRUEBA',
    voyageNumber: 'VTEST',
    portOfCall: 'GTSTC',
    createdAt: DateTime.utc(2026),
    published: true);
const service = ChangeRequests();
const key = 'C:FULL0001234';
const move = [PositionChange(key, '0030282', '0050482')];

void main() {
  test('T-81 cambio directo, cancelación, carga nueva y annul en tres órdenes',
      () {
    final initial = t76Operation();
    final changed = t76Movement(
        service.move(operation, office, initial, move, 'Nueva celda'), 1);
    final cancelled = t76Movement(
        service.cancel(
            operation, office, initial, 'C:FULL0005678', 'No embarca'),
        2);
    final events = [
      changed,
      cancelled,
      t76Movement(
          MovementDraft.loadFull('op', 'FULL0001234', move.single.to), 3)
    ];
    for (final order in [
      events,
      events.reversed.toList(),
      [events[1], events[0], events[2]]
    ]) {
      final data = t76Operation(order);
      expect(changed.payload.containsKey('request'), isFalse);
      expect(data.state[key]!.position, move.single.to);
      expect(data.state.conflicts, isEmpty);
      expect(OperationProgress.build(data).total.cancelled, 1);
    }
    final beforeLoad = t76Operation([changed, cancelled]);
    final undo = t76Movement(
        service.undo(
            operation, office, beforeLoad, key, changed.id, 'Restaurar'),
        4);
    final undoCancel = t76Movement(
        service.undo(operation, office, beforeLoad, 'C:FULL0005678',
            cancelled.id, 'Sí embarca'),
        5);
    final restored = t76Operation([undoCancel, changed, undo, cancelled]);
    expect(restored.plan.loading[key]!.plannedPosition, move.single.from);
    expect(restored.progress.total, initial.progress.total);
    expect(OperationProgress.build(restored).total.cancelled, 0);
    expect(restored.movements, hasLength(4));
  });
  test('T-81 exige oficina activa, operación abierta y motivo acotado', () {
    for (final actor in [
      null,
      dock,
      const Operator(
          uid: 'off', name: 'Off', role: OperatorRole.office, authorized: false)
    ]) {
      expect(
          () => service.move(operation, actor, t76Operation(), move, 'Motivo'),
          throwsStateError);
      expect(
          () => service.cancel(operation, actor, t76Operation(), key, 'Motivo'),
          throwsStateError);
    }
    for (final op in [
      operation.copyWith(published: false),
      operation.copyWith(closedAt: DateTime.utc(2026, 10, 11))
    ]) {
      expect(() => service.move(op, office, t76Operation(), move, 'Motivo'),
          throwsStateError);
      expect(() => service.cancel(op, office, t76Operation(), key, 'Motivo'),
          throwsStateError);
    }
    for (final reason in ['', ' ' * 3, 'x' * 301]) {
      expect(
          () => service.move(operation, office, t76Operation(), move, reason),
          throwsStateError);
      expect(
          () => service.cancel(operation, office, t76Operation(), key, reason),
          throwsStateError);
    }
  });
  test('T-81 no mueve ni cancela cargados, cancelados, descargas ni tránsito',
      () {
    for (final draft in [
      MovementDraft.loadFull('op', 'FULL0001234', '0050482'),
      MovementDraft.cancelItem('op', key, 'No embarca')
    ]) {
      final data = t76Operation([t76Movement(draft, 1)]);
      expect(() => service.move(operation, office, data, move, 'Motivo'),
          throwsStateError);
      expect(() => service.cancel(operation, office, data, key, 'Motivo'),
          throwsStateError);
    }
    expect(
        () => service.cancel(
            operation, office, t76Operation(), 'C:INCOMING1', 'Motivo'),
        throwsStateError);
  });
  test('T-81 revisa geometría, 20/40, ocupación y orígenes vigentes', () {
    for (final change in [
      const PositionChange(key, '0030282', '0040282'),
      const PositionChange(key, '0030282', '0990282'),
      const PositionChange(key, '0030282', '0030482'),
      const PositionChange(key, '0030282', '0030682'),
      const PositionChange(key, '0030682', '0050482'),
    ]) {
      expect(
          () => service.move(
              operation, office, t76Operation(), [change], 'Motivo'),
          throwsStateError);
    }
    // Ocupante de llegada, aunque no haya otro objeto planificado allí.
    final data = t76Operation([
      t76Movement(
          MovementDraft.changePosition(
              'op',
              const [PositionChange('R:0030482', '0030482', '0050482')],
              'Reserva reubicada'),
          1)
    ]);
    expect(
        () => service.move(operation, office, data,
            const [PositionChange(key, '0030282', '0030482')], 'Ocupada'),
        throwsStateError);
    expect(
        () => service.move(operation, office, data,
            const [PositionChange(key, '030282', '030482')], 'Ocupada con seis cifras'),
        throwsStateError);
  });
  test('T-81 intercambio atómico, hasta cuatro objetos y grupo de reservas',
      () {
    final draft = service.move(
        operation,
        office,
        t76Operation(),
        const [
          PositionChange('R:0030882', '0030882', '0050282'),
          PositionChange('R:0050282', '0050282', '0030882')
        ],
        'Mismo grupo');
    final data = t76Operation([t76Movement(draft, 1)]);
    expect(data.plan.loading['R:0030882']!.plannedPosition, '0050282');
    expect(data.state.conflicts, isEmpty);
    expect(
        () => service.move(
            operation,
            office,
            t76Operation(),
            const [
              PositionChange('R:0030882', '0030882', '0030382'),
              PositionChange('R:0030382', '0030382', '0030882')
            ],
            'Otro puerto'),
        throwsStateError);
    final four = service.move(
        operation,
        office,
        t76Operation(),
        const [
          PositionChange(key, '0030282', '0050482'),
          PositionChange('C:FULL0005678', '0030682', '0050682'),
          PositionChange('R:0030882', '0030882', '0050882'),
          PositionChange('R:0050282', '0050282', '0050182')
        ],
        'Cuatro cambios');
    expect(four.validate(), isNull);
  });
  test(
      'T-81 T-77 impide cargar contenedor y reserva cancelados, incluso con motivo',
      () {
    final events = [
      t76Movement(
          service.cancel(operation, office, t76Operation(), key, 'No embarca'),
          1),
      t76Movement(
          service.cancel(
              operation, office, t76Operation(), 'R:0050282', 'No embarca'),
          2)
    ];
    final data = t76Operation(events);
    for (final pair in [
      (t76List.byOrder(1)!, '0030282'),
      (t76List.byOrder(12)!, '0050282')
    ]) {
      expect(data.check(pair.$1, pair.$2).blocked, isTrue);
      expect(data.check(pair.$1, pair.$2).issues.single.message,
          contains('Cancelado por la oficina'));
      expect(() => data.draft(pair.$1, pair.$2, reason: 'Forzado'),
          throwsStateError);
    }
    expect(data.slots(t76List.byOrder(12)!).map((s) => s.key),
        isNot(contains('R:0050282')));
    final undo = service.undo(
        operation, office, data, key, events.first.id, 'Restaurar');
    expect(
        () => service.undo(
            operation, dock, data, key, events.first.id, 'Forzado'),
        throwsStateError);
    expect(
        t76Operation([...events, t76Movement(undo, 3)])
            .available(t76List.byOrder(1)!),
        isTrue);
  });
}
