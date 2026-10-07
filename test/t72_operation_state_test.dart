import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/operation_state_deriver.dart';
import 'package:flutter_test/flutter_test.dart';

/// T-72 · Derivación del estado de la escala (T-79a 2.7) con un plan mínimo.
///
/// Escala GTSTC. Llegada: A1 baja aquí (0010102) y T1 sigue a bordo (0010104).
/// Carga: L1 (0030102) y L2 (0030104) suben aquí, T1 sigue, y hay dos
/// reservas en 0050102 y 0050104.
void main() {
  ContainerUnit unit(String id, String position, {String pol = 'HNPCR', String pod = 'GTSTC'}) =>
      ContainerUnit(
          id: 'uuid-$id',
          containerId: id,
          isoSizeType: '22G1',
          status: ContainerStatus.full,
          stowagePosition: IsoCoordinateParser.parse(position),
          portOfLoading: pol,
          portOfDischarge: pod);
  ReservedSlot reserve(String position) => ReservedSlot(
      stowagePosition: IsoCoordinateParser.parse(position),
      isoSizeType: '22G1',
      status: ContainerStatus.empty,
      portOfLoading: 'GTSTC',
      portOfDischarge: 'JMKWL',
      operatorCode: 'LNA',
      nominalWeight: 2100);
  VesselVoyage voyage(List<ContainerUnit> cargo, {List<ReservedSlot> reserved = const []}) =>
      VesselVoyage(
          id: 'v',
          vessel: const Vessel(id: 'b', name: 'BUQUE PRUEBA'),
          voyageNumber: 'V1',
          containers: cargo,
          reservedSlots: reserved);

  final transit = unit('T1', '0010104', pod: 'JMKCT');
  final plan = OperationPlan.build(
    portOfCall: 'GTSTC',
    arrival: voyage([unit('A1', '0010102'), transit]),
    loading: voyage([
      unit('L1', '0030102', pol: 'GTSTC', pod: 'PAMIT'),
      unit('L2', '0030104', pol: 'GTSTC', pod: 'PAMIT'),
      transit,
    ], reserved: [reserve('0050102'), reserve('0050104')]),
  );

  var sequence = 0;
  Movement mv(MovementType type, String? target, Map<String, Object?> payload,
      {String device = 'dispositivo-a', int? minute}) {
    sequence++;
    return Movement(
      id: 'm${sequence.toString().padLeft(3, '0')}',
      operationId: 'op',
      type: type,
      target: target,
      payload: payload,
      author: const MovementAuthor(name: 'Tarjador', role: OperatorRole.dock),
      deviceId: device,
      sequence: sequence,
      createdAt: DateTime.utc(2025, 10, 4, 10, minute ?? sequence),
    );
  }

  Movement load(String id, String position) =>
      mv(MovementType.loadFull, 'C:$id', {'position': position, 'order': 7});
  Movement discharge(String id, String position, {bool restow = false}) =>
      mv(MovementType.discharge, 'C:$id', {'position': position, 'restow': restow});
  Movement assign(String position, String container, {String? corrects}) => mv(
      MovementType.assignEmpty,
      'R:$position',
      {'container': container, 'tareKg': 2185, if (corrects != null) 'corrects': corrects});
  Movement annul(String id) =>
      mv(MovementType.annul, null, {'annuls': id, 'reason': 'Error de registro'});
  Movement cancel(String target) =>
      mv(MovementType.cancelItem, target, {'reason': 'No embarca'});

  const deriver = OperationStateDeriver();
  OperationState derive(List<Movement> movements) => deriver.derive(plan, movements);

  setUp(() => sequence = 0);

  test('plan combinado: papeles y lo que está a bordo antes de operar', () {
    final state = derive([]);
    expect(state.items.length, 6, reason: 'A1, T1, L1, L2 y dos reservas');
    expect(state['C:A1']!.role, PlanRole.discharge);
    expect(state['C:T1']!.role, PlanRole.transit);
    expect(state['C:L1']!.role, PlanRole.load);
    expect(state['R:0050102']!.kind, PlanItemKind.reservedSlot);
    expect(state.items.values.every((s) => s.state == ItemState.planned), isTrue);
    expect(state.occupancy, {'0010102': 'A1', '0010104': 'T1'},
        reason: 'lo que se carga aquí todavía no está a bordo');
  });

  test('descarga: baja del buque y libera la celda', () {
    final state = derive([discharge('A1', '0010102')]);
    expect(state['C:A1']!.state, ItemState.moved);
    expect(state['C:A1']!.position, isNull);
    expect(state.occupancy.containsKey('0010102'), isFalse);
    expect(state.conflicts, isEmpty);
  });

  test('descarga de un contenedor de paso: conflicto sin re-estiba; con ella, se recarga', () {
    var state = derive([discharge('T1', '0010104')]);
    expect(state.conflicts.single.kind, ConflictKind.outOfPlan);
    expect(state['C:T1']!.state, ItemState.moved, reason: 'lo que registró el muelle cuenta');

    sequence = 0;
    state = derive([discharge('T1', '0010104', restow: true), load('T1', '0030202')]);
    expect(state.conflicts, isEmpty);
    expect(state['C:T1']!.restow, isTrue);
    expect(state['C:T1']!.position, '0030202');
    expect(state.occupancy['0030202'], 'T1');
  });

  test('carga en su celda, fuera de su celda y de un contenedor que no está en el plan', () {
    final state = derive([load('L1', '0030102'), load('L2', '0030204'), load('X9', '0030304')]);
    expect(state['C:L1']!.state, ItemState.moved);
    expect(state['C:L1']!.order, 7);
    expect(state['C:L1']!.inConflict, isFalse);

    expect(state['C:L2']!.position, '0030204', reason: 'queda donde lo registró el muelle');
    expect(state['C:L2']!.conflicts, [ConflictKind.outOfPlan]);

    expect(state['C:X9']!.conflicts, [ConflictKind.notInPlan]);
    expect(state.occupancy['0030304'], 'X9');
    expect(state.conflicts.map((c) => c.kind),
        unorderedEquals([ConflictKind.outOfPlan, ConflictKind.notInPlan]));
  });

  test('cargar un contenedor que va de paso no se aplica', () {
    final state = derive([load('T1', '0030302')]);
    expect(state.conflicts.single.kind, ConflictKind.notInPlan);
    expect(state['C:T1']!.position, '0010104');
  });

  test('celda ocupada: vale el primero en el orden y el segundo queda en conflicto', () {
    final state = derive([load('L1', '0030102'), load('L2', '0030102')]);
    expect(state.occupancy['0030102'], 'L1');
    expect(state['C:L2']!.state, ItemState.planned);
    final conflict = state.conflicts.single;
    expect(conflict.kind, ConflictKind.cellTaken);
    expect(conflict.key, 'C:L2');
    expect(conflict.otherMovementId, state['C:L1']!.movementId);
  });

  test('el mismo lleno dos veces: misma celda es duplicado, otra celda es conflicto', () {
    var state = derive([load('L1', '0030102'), load('L1', '0030102')]);
    expect(state.duplicates, hasLength(1));
    expect(state.conflicts, isEmpty);

    state = derive([load('L1', '0030102'), load('L1', '0030304')]);
    expect(state.conflicts.single.kind, ConflictKind.movedTwice);
    expect(state['C:L1']!.position, '0030102');
  });

  test('vacío: se asigna a su reserva con la tara real; los choques quedan en conflicto', () {
    final state = derive([
      assign('0050102', 'EMPT0000001'),
      assign('0050102', 'EMPT0000002'),
      assign('0050104', 'EMPT0000001'),
      mv(MovementType.assignEmpty, 'R:0030102', {'container': 'EMPT0000003', 'tareKg': 2200}),
    ]);
    final slot = state['R:0050102']!;
    expect(slot.state, ItemState.moved);
    expect(slot.assignedContainer, 'EMPT0000001');
    expect(slot.tareKg, 2185);
    expect(state['R:0050104']!.state, ItemState.planned);
    expect(state.conflicts.map((c) => c.kind), [
      ConflictKind.cellTaken,
      ConflictKind.containerTwice,
      ConflictKind.notInPlan,
    ]);
    expect(state.occupancy['0050102'], 'EMPT0000001');
  });

  test('anular devuelve a planificado; anular la anulación lo restaura', () {
    final loaded = load('L1', '0030102');
    final undo = annul(loaded.id);
    var state = derive([loaded, undo]);
    expect(state['C:L1']!.state, ItemState.planned);
    expect(state.voided, {loaded.id});

    final redo = annul(undo.id);
    state = derive([loaded, undo, redo]);
    expect(state['C:L1']!.state, ItemState.moved);
    expect(state.voided, {undo.id});
  });

  test('corregir reemplaza en una escritura: el caso de 007-08-08', () {
    final wrong = assign('0050102', 'EMPT0000009');
    final right = assign('0050102', 'EMPT0000064', corrects: wrong.id);
    final state = derive([wrong, right]);
    expect(state['R:0050102']!.assignedContainer, 'EMPT0000064');
    expect(state['R:0050102']!.movementId, right.id);
    expect(state.voided, {wrong.id});
    expect(state.conflicts, isEmpty, reason: 'la corrección no choca con lo corregido');
  });

  test('cancelar: sale del plan; operarlo después o cancelarlo movido es conflicto', () {
    final cancelled = cancel('C:L2');
    var state = derive([cancelled, load('L2', '0030104')]);
    expect(state['C:L2']!.state, ItemState.cancelled);
    expect(state.conflicts.single.kind, ConflictKind.cancelledItem);

    state = derive([load('L1', '0030102'), cancel('C:L1')]);
    expect(state['C:L1']!.state, ItemState.moved);
    expect(state.conflicts.single.kind, ConflictKind.cancelledItem);

    final again = cancel('C:L2');
    state = derive([again, annul(again.id)]);
    expect(state['C:L2']!.state, ItemState.planned);
  });

  test('el estado no depende del orden de llegada', () {
    final a = load('L1', '0030102');
    final b = load('L2', '0030102'); // choca con a
    final c = assign('0050102', 'EMPT0000001');
    final d = discharge('A1', '0010102');
    final e = annul(c.id);
    final f = mv(MovementType.loadFull, 'C:L2', {'position': '0030104'},
        device: 'dispositivo-b', minute: 3);
    final orders = [
      [a, b, c, d, e, f],
      [f, e, d, c, b, a],
      [c, f, a, e, b, d],
    ];
    final states = orders.map(derive).toList();
    for (final s in states.skip(1)) {
      expect(s.items, states.first.items);
      expect(s.conflicts.toSet(), states.first.conflicts.toSet());
      expect(s.occupancy, states.first.occupancy);
    }
  });

  test('cambios de posición y tapas se guardan, pero se derivan en T-80 y T-84', () {
    final state = derive([
      mv(MovementType.changePosition, null, {'changes': [], 'reason': 'x'}),
      mv(MovementType.hatchCover, 'T:3-1', {'action': 'remove'}),
    ]);
    expect(state.notDerived, hasLength(2));
    expect(state.items.values.every((s) => s.state == ItemState.planned), isTrue);
  });

  test('avance por bahía y zona: lo previsto en su celda, lo movido donde quedó', () {
    final state = derive([load('L1', '0030182'), discharge('A1', '0010102')]);
    final load3hold = state.progress(role: PlanRole.load)[(bay: 3, deck: false)]!;
    expect(load3hold, const ProgressCount(pending: 1),
        reason: 'L2 sigue pendiente en bodega; L1 subió a cubierta');
    expect(state.progress(role: PlanRole.load)[(bay: 3, deck: true)],
        const ProgressCount(moved: 1));
    expect(state.progress(role: PlanRole.discharge)[(bay: 1, deck: false)],
        const ProgressCount(moved: 1));
  });

  group('movimiento y borrador', () {
    test('ida y vuelta por JSON con los nombres de Firestore', () {
      final m = assign('0050102', 'EMPT0000001');
      final json = m.toJson();
      expect(json['type'], 'assign_empty');
      expect(json['target'], 'R:0050102');
      expect(Movement.fromJson(json), m);
    });

    test('el borrador valida la forma como las reglas propuestas', () {
      expect(MovementDraft.annul('op', 'm1', ' ').validate(), contains('motivo'));
      expect(MovementDraft.cancelItem('op', 'C:L1', '').validate(), contains('motivo'));
      expect(MovementDraft.assignEmpty('op', '0050102', 'EMPT1', 0).validate(),
          contains('Tara'));
      expect(MovementDraft.loadFull('op', 'L1', '30102X').validate(), contains('posición'));
      expect(MovementDraft.raw('op', MovementType.cancelItem, 'C:L1',
              {'reason': 'x', 'corrects': 'm1'}).validate(),
          contains('corrección'));
      expect(MovementDraft.loadFull('op', 'L1', '0030102', order: 1).validate(), isNull);
      expect(MovementDraft.loadFull('op', 'L1', '0030102').payload.containsKey('seal'),
          isFalse, reason: 'los opcionales vacíos no se guardan');
    });
  });
}
