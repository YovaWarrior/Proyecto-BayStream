import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/change_requests.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t76_fixture.dart';
import 't81_office_changes_test.dart' as f;

const _service = ChangeRequests();

// Geometría sintética PROVISIONAL: las bahías de estos casos existen;
// se aísla la colisión física de las restricciones de geometría y tamaño.
LoadingOperation _data(
  List<ContainerUnit> planned, {
  List<ContainerUnit> aboard = const [],
  List<ReservedSlot> slots = const [],
  List<Movement> movements = const [],
}) {
  final anchors = [
    for (final code in ['0010684', '0040684', '0410684', '0440684'])
      _unit('ANCHOR$code', code,
              forty: int.parse(code.substring(0, 3)).isEven)
          .copyWith(portOfLoading: 'HNPCR')
  ];
  final loading = t76Voyage([...planned, ...anchors], slots: slots).withGeometry(
    const VesselGeometry(
      portRows: 3,
      starboardRows: 3,
      holdTiers: [],
      deckTiers: [82, 84],
    ),
    portOfCall: 'GTSTC',
  );
  return LoadingOperation.build(
    operationId: 'op',
    arrival: aboard.isEmpty ? null : t76Voyage(aboard),
    loading: loading,
    movements: movements,
  );
}

ContainerUnit _unit(String id, String position, {bool forty = false}) =>
    t76Unit(id, position).copyWith(isoSizeType: forty ? '45G1' : '22G1');

void _blocked(
  LoadingOperation data,
  List<PositionChange> changes, {
  required String name,
  required String position,
}) {
  final error = _service.review(data, changes);
  expect(error, isNotNull);
  expect(error, contains('${changes.first.to} choca con'));
  expect(error, contains(name));
  expect(error, contains('en $position'));
  if (changes.first.to.substring(0, 3) != position.substring(0, 3)) {
    expect(error, contains('un 40 ocupa las dos mitades de la celda.'));
  }
  for (final actor in [f.office, f.dock]) {
    expect(_service.preview(data, actor, changes).error, error);
  }
  final sameError = throwsA(
    isA<StateError>().having((e) => e.message, 'mismo mensaje', error),
  );
  expect(
    () => _service.move(f.operation, f.office, data, changes, 'Peso'),
    sameError,
  );
  expect(
    () => _service.request(f.operation, f.dock, data, changes, 'Peso'),
    sameError,
  );
}

void _allowed(LoadingOperation data, List<PositionChange> changes) {
  expect(_service.review(data, changes), isNull);
  for (final actor in [f.office, f.dock]) {
    expect(_service.preview(data, actor, changes).valid, isTrue);
  }
  expect(
    _service.move(f.operation, f.office, data, changes, 'Peso').validate(),
    isNull,
  );
  expect(
    _service.request(f.operation, f.dock, data, changes, 'Peso').validate(),
    isNull,
  );
}

void main() {
  for (final aboard in [false, true]) {
    final where = aboard ? 'a bordo' : 'previsto en el plan';
    for (final bay in ['003', '005']) {
      test(
        '10.63 un 20 en $bay choca con la sombra de un 40 en 004 $where',
        () {
          final blocker = _unit('FORTY', '0040282', forty: true);
          final data = _data(
            [_unit('TWENTY', '0030482'), if (!aboard) blocker],
            aboard: [if (aboard) blocker],
          );
          _blocked(
            data,
            [PositionChange('C:TWENTY', '0030482', '${bay}0282')],
            name: 'FORTY',
            position: '0040282',
          );
        },
      );
      test('10.63 un 40 en 004 choca con un 20 en $bay $where', () {
        final blocker = _unit('TWENTY', '${bay}0282');
        final data = _data(
          [_unit('FORTY', '0040482', forty: true), if (!aboard) blocker],
          aboard: [if (aboard) blocker],
        );
        _blocked(
          data,
          [const PositionChange('C:FORTY', '0040482', '0040282')],
          name: 'TWENTY',
          position: '${bay}0282',
        );
      });
    }
    for (final bay in ['043', '045']) {
      test(
        '10.63 ALFA: un 20 en $bay choca con 044 $where sin calcular pares',
        () {
          final blocker = _unit('ALFA40', '0440282', forty: true);
          final data = _data(
            [_unit('ALFA20', '0410482'), if (!aboard) blocker],
            aboard: [if (aboard) blocker],
          );
          _blocked(
            data,
            [PositionChange('C:ALFA20', '0410482', '${bay}0282')],
            name: 'ALFA40',
            position: '0440282',
          );
        },
      );
    }
    test('10.63 ALFA: la 041 sola no choca con 044 $where', () {
      final blocker = _unit('ALFA40', '0440282', forty: true);
      final data = _data(
        [_unit('ALFA20', '0410482'), if (!aboard) blocker],
        aboard: [if (aboard) blocker],
      );
      _allowed(data, [const PositionChange('C:ALFA20', '0410482', '0410282')]);
    });
  }

  for (final destination in ['0030482', '0030284', '0010282']) {
    test(
      '10.63 un 40 no bloquea $destination fuera de su fila, nivel o huella',
      () {
        final data = _data(
          [_unit('TWENTY', '0030682')],
          aboard: [_unit('FORTY', '0040282', forty: true)],
        );
        _allowed(data, [PositionChange('C:TWENTY', '0030682', destination)]);
      },
    );
  }
  test('10.63 las impares 003 y 005 son mitades distintas', () {
    _allowed(_data([_unit('A', '0030482')], aboard: [_unit('B', '0050282')]), [
      const PositionChange('C:A', '0030482', '0030282'),
    ]);
  });
  test('10.63 dos pares también chocan si sus huellas se tocan', () {
    _blocked(
      _data(
        [_unit('A', '0020482', forty: true)],
        aboard: [_unit('B', '0040282', forty: true)],
      ),
      [const PositionChange('C:A', '0020482', '0020282')],
      name: 'B',
      position: '0040282',
    );
  });
  test(
    '10.63 un ocupante de código exacto también identifica quién y dónde',
    () {
      _blocked(
        _data([_unit('A', '0030482')], aboard: [_unit('B', '0030282')]),
        [const PositionChange('C:A', '0030482', '0030282')],
        name: 'B',
        position: '0030282',
      );
    },
  );
  test('10.63 una reserva de 40 prevista bloquea ambas mitades', () {
    final data = _data(
      [_unit('A', '0030482')],
      slots: [t76Slot('0040282', type: '45G1')],
    );
    _blocked(
      data,
      [const PositionChange('C:A', '0030482', '0030282')],
      name: 'la reserva 004 02 82',
      position: '0040282',
    );
  });
  test('10.63 la reserva ya asignada identifica el contenedor a bordo', () {
    final data = _data(
      [_unit('A', '0030482')],
      slots: [t76Slot('0040282', type: '45G1')],
      movements: [
        t76Movement(
          MovementDraft.assignEmpty('op', '0040282', 'EMPTY40', 2100),
          1,
        ),
      ],
    );
    expect(data.state['R:0040282']!.assignedContainer, 'EMPTY40');
    _blocked(
      data,
      [const PositionChange('C:A', '0030482', '0030282')],
      name: 'EMPTY40',
      position: '0040282',
    );
  });
  test('10.63 un 40 que baja bloquea hasta registrar su descarga', () {
    final leaving = _unit(
      'LEAVING',
      '0040282',
      forty: true,
    ).copyWith(portOfLoading: 'HNPCR', portOfDischarge: 'GTSTC');
    final planned = [_unit('A', '0030482'), leaving];
    const changes = [PositionChange('C:A', '0030482', '0050282')];
    _blocked(
      _data(planned, aboard: [leaving]),
      changes,
      name: 'LEAVING',
      position: '0040282',
    );
    _allowed(
      _data(
        planned,
        aboard: [leaving],
        movements: [
          t76Movement(MovementDraft.discharge('op', 'LEAVING', '0040282'), 1),
        ],
      ),
      changes,
    );
  });
  for (final forty in [false, true]) {
    final first = forty ? '0040282' : '0030282';
    final second = forty ? '0040482' : '0050282';
    test(
      '10.63 intercambio atómico de ${forty ? 40 : 20} excluye su propio lote',
      () {
        final data = _data([
          _unit('A', first, forty: forty),
          _unit('B', second, forty: forty),
        ]);
        final changes = [
          PositionChange('C:A', first, second),
          PositionChange('C:B', second, first),
        ];
        _allowed(data, changes);
        expect(_service.preview(data, f.office, changes).isSwap, isTrue);
      },
    );
  }
  test('10.63 los destinos del mismo lote no pueden solaparse físicamente', () {
    final data = _data([
      _unit('A', '0030482'),
      _unit('B', '0040682', forty: true),
    ]);
    _blocked(
      data,
      [
        const PositionChange('C:A', '0030482', '0030282'),
        const PositionChange('C:B', '0040682', '0040282'),
      ],
      name: 'B',
      position: '0040282',
    );
  });
  for (final load in [false, true]) {
    test(
      '10.63 aprobar revisa otra vez la celda ${load ? 'ocupada' : 'prevista'}',
      () {
        final planned = [
          _unit('A', '0030682'),
          _unit('B', '0040482', forty: true),
        ];
        const changes = [PositionChange('C:A', '0030682', '0050282')];
        final initial = _data(planned);
        final request = t76Movement(
          _service.request(f.operation, f.dock, initial, changes, 'Peso'),
          1,
        );
        final pending = _data(planned, movements: [request]);
        expect(
          _service
              .decide(
                f.operation,
                f.office,
                pending,
                request.id,
                'Aprobar',
                approve: true,
              )
              .validate(),
          isNull,
        );
        final otherMove = t76Movement(
          _service.move(
              f.operation,
              f.office,
              pending,
              [
                const PositionChange('C:B', '0040482', '0040282'),
              ],
              'Peso'),
          2,
        );
        final current = _data(
          planned,
          movements: [
            request,
            otherMove,
            if (load)
              t76Movement(MovementDraft.loadFull('op', 'B', '0040282'), 3),
          ],
        );
        expect(current.state.conflicts, isEmpty);
        expect(
          current.state.requests.single.status,
          ChangeRequestStatus.pending,
        );
        _blocked(current, changes, name: 'B', position: '0040282');
        expect(
          () => _service.decide(
            f.operation,
            f.office,
            current,
            request.id,
            'Aprobar',
            approve: true,
          ),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'mismo mensaje',
              _service.review(current, changes),
            ),
          ),
        );
        expect(
          _service
              .decide(
                f.operation,
                f.office,
                current,
                request.id,
                'No procede',
                approve: false,
              )
              .validate(),
          isNull,
        );
      },
    );
  }
  test(
    '10.63 aprobar conserva la regularización de la propia carga del lote',
    () {
      final planned = [_unit('A', '0030482')];
      const changes = [PositionChange('C:A', '0030482', '0030282')];
      final request = t76Movement(
        _service.request(f.operation, f.dock, _data(planned), changes, 'Peso'),
        1,
      );
      final current = _data(
        planned,
        movements: [
          request,
          t76Movement(MovementDraft.loadFull('op', 'A', '0030282'), 2),
        ],
      );
      expect(current.state['C:A']!.position, '0030282');
      expect(
        _service
            .decide(
              f.operation,
              f.office,
              current,
              request.id,
              'Regularizar',
              approve: true,
            )
            .validate(),
        isNull,
      );
    },
  );
}
