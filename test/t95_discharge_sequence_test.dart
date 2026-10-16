import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/discharge_sequence.dart';
import 'package:flutter_test/flutter_test.dart';

/// T-95 · Datos sintéticos; el corpus va en tool/t95_corpus_test.dart.
/// Las tapas son PROVISIONALES: ningún buque del corpus las declara (T-83).
const _port = 'GTSTC';

ContainerUnit _c(String id, String? position,
        {String? pod = 'PAMIT', String iso = '22G1'}) =>
    ContainerUnit(
      id: 'id-$id',
      containerId: id,
      stowagePosition:
          position == null ? null : IsoCoordinateParser.parse(position),
      isoSizeType: iso,
      status: ContainerStatus.full,
      portOfLoading: 'HNPCR',
      portOfDischarge: pod,
      operatorCode: 'LNA',
      vgmWeight: 20000,
    );

ContainerUnit _down(String id, String position, {String iso = '22G1'}) =>
    _c(id, position, pod: _port, iso: iso);

const _geometry = VesselGeometry(
    portRows: 4,
    starboardRows: 3,
    holdTiers: [2, 4, 6],
    deckTiers: [82, 84, 86],
    centerRowOnDeck: true,
    centerRowInHold: true);

VesselVoyage _voyage(List<ContainerUnit> units) => VesselVoyage(
      id: 'v',
      vessel: const Vessel(id: 'b', name: 'BUQUE T95', imoNumber: '9000095'),
      voyageNumber: 'T95',
      containers: units,
      bays: const {},
      portOfCall: _port,
    );

DischargeSequence _seq(List<ContainerUnit> units,
        [Map<int, HatchCoverDeclaration> covers = const {}]) =>
    DischargeSequence.build(_voyage(units), _port,
        geometry: _geometry, hatchCovers: covers);

HatchCoverDeclaration _crane(List<Set<int>> rows) =>
    HatchCoverDeclaration(kind: HatchCoverKind.crane, covers: rows);

Set<String> _restowed(DischargeSequence s) => {
      for (final cell in s.cells)
        for (final step in cell.steps)
          if (step.kind == DischargeStepKind.restowOut) step.container!.containerId,
    };

List<(DischargeStepKind, String)> _steps(DischargeCell cell) =>
    [for (final s in cell.steps) (s.kind, s.position)];

void main() {
  test('T-95 la huella: la impar es ella misma y la par sus dos impares', () {
    expect(bayFootprint(1), {1});
    expect(bayFootprint(2), {1, 3});
    expect(bayFootprint(44), {43, 45});
    expect(bayFootprint(41), {41});
    expect(footprintsTouch(2, 1), isTrue);
    expect(footprintsTouch(3, 1), isFalse);
    expect(footprintsTouch(44, 41), isFalse);
  });

  test('T-95 un 40 que no baja sobre un 20 que baja (02 sobre 01): re-estiba',
      () {
    final s = _seq([_down('DOWN1', '0010282'), _c('STAY40', '0020284', iso: '45G1')]);
    expect(s.discharges, 1);
    expect(s.columnRestows, 1);
    expect(_restowed(s), {'STAY40'});
    expect(s.cells.single.bays, [1, 2]);
  });

  test('T-95 un 20 en la 03 sobre un 20 en la 01: no es la misma pila', () {
    final s = _seq([_down('DOWN1', '0010282'), _c('STAY3', '0030284')]);
    expect(s.restows, 0);
    expect(s.cells.single.bays, [1]);
  });

  test('T-95 un 20 que no baja sobre un 40 que baja: re-estiba', () {
    final s = _seq([_down('DOWN40', '0020282', iso: '45G1'), _c('STAY1', '0010284')]);
    expect(s.columnRestows, 1);
    expect(_restowed(s), {'STAY1'});
  });

  test('T-95 ALFA sin fórmula: la 044 sobre la 043 y la 045, y la 041 sola', () {
    final s = _seq([
      _down('D43', '0430282'),
      _down('D45', '0450282'),
      _c('S44', '0440284', iso: '45G1'),
      _down('D41', '0410282'),
    ]);
    expect(s.columnRestows, 1, reason: 'la 044 estorba a dos y cuenta una');
    expect(_restowed(s), {'S44'});
    expect({for (final c in s.cells) c.bays.join(',')}, {'43,44,45', '41'});
  });

  test('T-95 una re-estiba que estorba dos veces, y de las dos clases, cuenta una',
      () {
    final s = _seq([
      _down('D1', '0010282'),
      _down('D3', '0030282'),
      _down('H1', '0010202'),
      _c('S40', '0020284', iso: '45G1'),
    ], {
      2: _crane([{2}])
    });
    expect(s.restows, 1);
    expect(s.columnRestows, 1, reason: 'sale primero, en la cubierta');
    expect(s.coverRestows, 0);
    expect(s.cells.single.steps.where((x) => x.container?.containerId == 'S40'),
        hasLength(2), reason: 'sale y vuelve, una sola vez');
  });

  group('T-95 la tapa', () {
    final units = [
      _down('H', '0010202'),
      _c('ON', '0010282'),
      _c('OUT', '0010882'),
    ];
    test('la cubierta de paso sobre su tapa es re-estiba; la fila de afuera no',
        () {
      final s = _seq(units, {
        1: _crane([{2, 4}])
      });
      expect(s.coverRestows, 1);
      expect(_restowed(s), {'ON'});
      expect(s.outsideCoverRows, ['0010882']);
      expect(s.craneCovers, 1);
      expect(_steps(s.cells.single), [
        (DischargeStepKind.restowOut, '0010282'),
        (DischargeStepKind.coverOff, '001'),
        (DischargeStepKind.discharge, '0010202'),
        (DischargeStepKind.coverOn, '001'),
        (DischargeStepKind.restowBack, '0010282'),
      ]);
      expect((s.movesOnBoard, s.movesByQuay), (4, 5));
    });

    test('la automática despeja la cubierta y cuenta 0', () {
      final s = _seq(units, {
        1: HatchCoverDeclaration(kind: HatchCoverKind.automatic, covers: [
          {2, 4}
        ])
      });
      expect(s.coverRestows, 1);
      expect((s.craneCovers, s.automaticCovers), (0, 1));
      expect((s.movesOnBoard, s.movesByQuay), (2, 3));
      expect(s.cells.single.steps.where((x) => x.kind == DischargeStepKind.coverOff),
          hasLength(1));
    });

    test('la bodega abierta no tiene tapa', () {
      final s = _seq(units, {1: HatchCoverDeclaration(kind: HatchCoverKind.openHold)});
      expect(s.restows, 0);
      expect(s.holdWithoutCover, isEmpty);
      expect(s.cells.single.steps.map((x) => x.kind), [DischargeStepKind.discharge]);
    });

    test('la tapa sin declarar da un aviso, sin movimientos de tapa', () {
      final s = _seq(units);
      expect(s.holdWithoutCover, ['0010202']);
      expect((s.restows, s.craneCovers), (0, 0));
      expect(s.movesByQuay, 1);
    });

    test('una fila de bodega que ninguna tapa cubre también avisa', () {
      final s = _seq([_down('H8', '0010802')], {
        1: _crane([{2, 4}])
      });
      expect(s.holdWithoutCover, ['0010802']);
      expect(s.craneCovers, 0);
    });
  });

  test('T-95 las copias en la 01, la 02 y la 03 se unen en una tapa', () {
    final units = [
      _down('H1', '0010202'),
      _down('H3', '0030402'),
      _c('ON1', '0010282'),
      _c('ON3', '0030482'),
      _c('ON2', '0020484', iso: '45G1'),
    ];
    final onlyEven = _seq(units, {
      2: _crane([{2, 4}])
    });
    final copied = _seq(units, {
      1: _crane([{2, 4}]),
      2: _crane([{2, 4}]),
      3: _crane([{2, 4}]),
    });
    expect(copied.mergedCoverDeclarations, 2);
    expect(onlyEven.mergedCoverDeclarations, 0);
    expect(copied.craneCovers, 1);
    expect(_steps(copied.cells.single), _steps(onlyEven.cells.single));
    expect((copied.restows, copied.movesByQuay),
        (onlyEven.restows, onlyEven.movesByQuay));
    expect(onlyEven.coverRestows, 3);
  });

  test('T-95 la secuencia completa: cubierta, tapa, bodega y las vueltas', () {
    final s = _seq([
      _down('D', '0010282'),
      _c('S', '0010284'),
      _c('C', '0010482'),
      _down('H', '0010402'),
      _c('HS', '0010404'),
    ], {
      1: _crane([{4}])
    });
    expect(_steps(s.cells.single), [
      (DischargeStepKind.restowOut, '0010284'),
      (DischargeStepKind.discharge, '0010282'),
      (DischargeStepKind.restowOut, '0010482'),
      (DischargeStepKind.coverOff, '001'),
      (DischargeStepKind.restowOut, '0010404'),
      (DischargeStepKind.discharge, '0010402'),
      (DischargeStepKind.restowBack, '0010404'),
      (DischargeStepKind.coverOn, '001'),
      (DischargeStepKind.restowBack, '0010482'),
      (DischargeStepKind.restowBack, '0010284'),
    ]);
    expect([for (final x in s.cells.single.steps) x.number],
        List.generate(10, (i) => i + 1));
    final cell = s.cells.single;
    expect((cell.discharges, cell.columnRestows, cell.coverRestows, cell.craneCovers),
        (2, 2, 1, 1));
    expect((cell.movesOnBoard, cell.movesByQuay), (7, 10));
  });

  test('T-95 las celdas, de más a menos movimientos, con el empate de proa a popa',
      () {
    final s = _seq([
      _down('A', '0010282'),
      _down('B1', '0050282'),
      _down('B2', '0050482'),
      _down('B3', '0050682'),
      _down('C', '0130282'),
      _down('D', '0090282'),
    ]);
    expect([for (final c in s.cells) c.bays.first], [5, 1, 9, 13]);
    expect([for (final c in s.cells) c.movesByQuay], [3, 1, 1, 1]);
  });

  test('T-95 los dos totales suman por celda', () {
    final s = _seq([
      _down('D1', '0010282'),
      _c('S40', '0020284', iso: '45G1'),
      _down('H5', '0050202'),
      _c('ON5', '0050282'),
    ], {
      5: _crane([{2}])
    });
    expect(s.discharges, 2);
    expect((s.columnRestows, s.coverRestows, s.craneCovers), (1, 1, 1));
    expect(s.movesOnBoard, 2 + 2 + 2);
    expect(s.movesByQuay, 2 + 4 + 2);
    expect(s.movesOnBoard, s.cells.fold(0, (t, c) => t + c.movesOnBoard));
    expect(s.movesByQuay, s.cells.fold(0, (t, c) => t + c.movesByQuay));
  });

  test('T-95 sin posición y sin puerto de descarga se cuentan aparte', () {
    final s = _seq([
      _down('D1', '0010282'),
      _c('NOWHERE', null, pod: _port),
      _c('NOPOD', '0010284', pod: null),
    ]);
    expect(s.discharges, 1);
    expect(s.withoutPosition.single.containerId, 'NOWHERE');
    expect(s.withoutDischargePort, 1);
    expect(_restowed(s), {'NOPOD'}, reason: 'no baja, así que estorba');
  });

  test('T-95 los puertos: la escala primero y después del más frecuente', () {
    final voyage = _voyage([
      _down('A', '0010282'),
      _c('B', '0010482', pod: 'PAMIT'),
      _c('C', '0010682', pod: 'PAMIT'),
      _c('D', '0010882', pod: 'JMKIN'),
      _c('E', '0030282', pod: null),
    ]);
    expect(DischargeSequence.dischargePorts(voyage), ['GTSTC', 'PAMIT', 'JMKIN']);
    final pamit = DischargeSequence.build(voyage, 'PAMIT', geometry: _geometry);
    expect(pamit.discharges, 2);
  });

  test('T-95 las reservas no son contenedores y no entran', () {
    final voyage = _voyage([_down('D1', '0010282')]).copyWith(reservedSlots: [
      ReservedSlot(
          stowagePosition: IsoCoordinateParser.parse('0010284'),
          isoSizeType: '22G1',
          status: ContainerStatus.empty,
          portOfDischarge: 'PAMIT')
    ]);
    final s = DischargeSequence.build(voyage, _port, geometry: _geometry);
    expect((s.discharges, s.restows), (1, 0));
  });
}
