import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/change_requests.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t76_fixture.dart';
import 't81_office_changes_test.dart' as f;

/// T-106 · Los avisos de review() en palabras: el objeto como lo ve el planner
/// y la segunda frase solo si aplica. Las reglas no cambian (T-105, 10.63).
const _service = ChangeRequests();

/// El plan de T-76 sin plano de llegada: FULL0001234 (OR 1) en 0030282 y
/// FULL0005678 (OR 2) en 0030682, con sus reservas.
LoadingOperation _plan([List<Movement> movements = const []]) =>
    LoadingOperation.build(
        operationId: 'op', loading: t76Loading, list: t76List, movements: movements);

/// Una carga propia: el plan y, si hace falta, un plano de llegada.
LoadingOperation _own(List<ContainerUnit> loading,
        {List<ContainerUnit> arrival = const []}) =>
    LoadingOperation.build(
        operationId: 'op',
        arrival: arrival.isEmpty ? null : t76Voyage(arrival),
        loading: t76Voyage(loading),
        list: t76List);

void _expectMessage(LoadingOperation data, List<PositionChange> changes,
    String expected) {
  final error = _service.review(data, changes);
  expect(error, expected);
  expect(error, isNot(contains('C:')));
  expect(error, isNot(contains('R:')));
  for (final actor in [f.office, f.dock]) {
    expect(_service.preview(data, actor, changes).error, expected);
  }
  final same = throwsA(
      isA<StateError>().having((e) => e.message, 'mismo aviso', expected));
  expect(() => _service.move(f.operation, f.office, data, changes, 'Peso'),
      same);
  expect(() => _service.request(f.operation, f.dock, data, changes, 'Peso'),
      same);
}

void main() {
  const one = 'C:FULL0001234';
  const two = 'C:FULL0005678';

  test('T-106 no cabe: el contenedor por su orden y la reserva por su celda', () {
    _expectMessage(_plan(), [const PositionChange(one, '0030282', '0040282')],
        'OR 1 · FULL0001234 no cabe en la bahía 4.');
    _expectMessage(
        _plan(),
        [const PositionChange('R:0030182', '0030182', '0050482')],
        'La reserva 003 01 82 no cabe en la bahía 5.');
  });

  test('T-106 el origen cambió y el objeto que no está en el plan', () {
    _expectMessage(_plan(), [const PositionChange(one, '0030682', '0030082')],
        'El origen de OR 1 · FULL0001234 cambió; revisa la solicitud.');
    _expectMessage(_plan(), [const PositionChange('C:NOPE0000001', '0030282', '0030082')],
        'NOPE0000001 no está en el plan.');
  });

  test('T-106 una descarga pendiente a bordo: «marca primero su descarga»', () {
    _expectMessage(
        t76Operation(),
        [
          const PositionChange(one, '0030282', '0030682'),
          const PositionChange(two, '0030682', '0030282'),
        ],
        '0030282 choca con INCOMING1 en 0030282. '
        'La celda está ocupada a bordo; marca primero su descarga.');
  });

  test('T-106 carga de paso a bordo: «no se descarga aquí»', () {
    final transit = t76Unit('TRANSIT0000001', '0050482', incoming: true)
        .copyWith(portOfDischarge: 'PAMIT');
    final data = _own([t76Unit('FULL0001234', '0030282'), transit],
        arrival: [transit]);
    expect(data.state['C:TRANSIT0000001']!.role, PlanRole.transit);
    _expectMessage(data, [const PositionChange(one, '0030282', '0050482')],
        '0050482 choca con TRANSIT0000001 en 0050482. '
        'Es carga de paso: no se descarga aquí.');
  });

  test('T-106 un 20 y un 40: no se intercambian, en los dos sentidos', () {
    final data = _own([
      t76Unit('FULL0001234', '0030282'),
      t76Unit('FORTY0000001', '0040182').copyWith(isoSizeType: '45G1'),
    ]);
    _expectMessage(data, [const PositionChange(one, '0030282', '0030182')],
        '0030182 choca con FORTY0000001 en 0040182: un 40 ocupa las dos '
        'mitades de la celda. Un 20 y un 40 no se intercambian.');
    _expectMessage(
        data,
        [const PositionChange('C:FORTY0000001', '0040182', '0040282')],
        '0040282 choca con OR 1 · FULL0001234 en 0030282: un 40 ocupa las dos '
        'mitades de la celda. Un 20 y un 40 no se intercambian.');
  });

  test('T-106 otro pendiente del mismo tamaño: «inclúyelo en el intercambio»',
      () {
    _expectMessage(_plan(), [const PositionChange(one, '0030282', '0030682')],
        '0030682 choca con OR 2 · FULL0005678 en 0030682. '
        'La celda está prevista para otro objeto; inclúyelo en el intercambio.');
    _expectMessage(_plan(), [const PositionChange(one, '0030282', '0030482')],
        '0030482 choca con la reserva 003 04 82 en 0030482. '
        'La celda está prevista para otro objeto; inclúyelo en el intercambio.');
  });

  test('T-106 una reserva reubicada se nombra por su celda de origen', () {
    // Como la pide la página de solicitudes (T-80): por su celda del BAPLIE;
    // «en» dice dónde está prevista ahora.
    final moved = _plan([
      t76Movement(
          MovementDraft.changePosition(
              'op',
              const [
                PositionChange('R:0030882', '0030882', '0050282'),
                PositionChange('R:0050282', '0050282', '0030882'),
              ],
              'Mismo grupo'),
          1),
    ]);
    expect(moved.plan.loading['R:0030882']!.plannedPosition, '0050282');
    _expectMessage(moved, [const PositionChange(one, '0030282', '0050282')],
        '0050282 choca con la reserva 003 08 82 en 0050282. '
        'La celda está prevista para otro objeto; inclúyelo en el intercambio.');
  });

  test('T-106 lo ya cargado del mismo tamaño: sin segunda frase', () {
    final loaded = _plan([
      t76Movement(MovementDraft.loadFull('op', 'FULL0005678', '0030682'), 1),
    ]);
    _expectMessage(loaded, [const PositionChange(one, '0030282', '0030682')],
        '0030682 choca con OR 2 · FULL0005678 en 0030682.');
  });

  test('T-106 los textos cambian, las reglas no: lo válido sigue válido', () {
    expect(_service.review(_plan(), [const PositionChange(one, '0030282', '0050482')]),
        isNull);
    expect(
        _service.review(_plan(), [
          const PositionChange(one, '0030282', '0030682'),
          const PositionChange(two, '0030682', '0030282'),
        ]),
        isNull);
  });
}
