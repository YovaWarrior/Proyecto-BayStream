import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/domain/entities/dangerous_goods.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/voyage_comparison.dart';
import 'package:flutter_test/flutter_test.dart';

/// T-96 · Datos sintéticos; el corpus va en tool/t96_corpus_test.dart.
ContainerUnit _unit(
  String id, {
  String position = '0010182',
  String? iso = '22G1',
  ContainerStatus status = ContainerStatus.full,
  String? pol = 'HNPCR',
  String? pod = 'PAMIT',
  String? line = 'LNA',
  double? wt,
  double? vgm = 20000,
  List<DangerousGoods>? dg,
  double? temp,
}) =>
    ContainerUnit(
      id: 'id-$id',
      containerId: id,
      stowagePosition: IsoCoordinateParser.parse(position),
      isoSizeType: iso,
      status: status,
      portOfLoading: pol,
      portOfDischarge: pod,
      operatorCode: line,
      grossWeight: wt,
      vgmWeight: vgm,
      dangerousGoods: dg,
      isDangerous: dg != null && dg.isNotEmpty,
      temperature: temp,
      temperatureUnit: temp == null ? null : 'CEL',
    );

VesselVoyage _voyage(List<ContainerUnit> units,
        {String? imo = '9000096',
        String? callSign,
        String name = 'BUQUE T96',
        List<ReservedSlot> reserved = const []}) =>
    VesselVoyage(
      id: 'v',
      vessel: Vessel(id: 'b', name: name, imoNumber: imo, callSign: callSign),
      voyageNumber: 'T96',
      containers: units,
      bays: const {},
      reservedSlots: reserved,
    );

ReservedSlot _slot(String position) => ReservedSlot(
    stowagePosition: IsoCoordinateParser.parse(position),
    isoSizeType: '22G1',
    status: ContainerStatus.empty);

void main() {
  test('T-96 clasifica por número: descargados, cargados y permanentes', () {
    final c = VoyageComparison.compare(
        _voyage([_unit('AAAU0000001'), _unit('AAAU0000002')]),
        _voyage([_unit('AAAU0000002'), _unit('AAAU0000003')]));
    expect(c.discharged.map((u) => u.containerId), ['AAAU0000001']);
    expect(c.loaded.map((u) => u.containerId), ['AAAU0000003']);
    expect(c.permanent.single.containerId, 'AAAU0000002');
    expect(c.permanent.single.changed, isFalse);
    expect(c.withChanges, 0);
    expect(c.vesselNotice, isNull);
  });

  test('T-96 cada campo que cambia se reporta con antes y después', () {
    final before = _unit('AAAU0000001',
        dg: [DangerousGoods(unNumber: '1170', hazardClass: '3')],
        temp: -18);
    final cases = <ComparedField, ContainerUnit>{
      ComparedField.position: _unit('AAAU0000001',
          position: '0030182',
          dg: [DangerousGoods(unNumber: '1170', hazardClass: '3')],
          temp: -18),
      ComparedField.isoType: _unit('AAAU0000001',
          iso: '45G1',
          dg: [DangerousGoods(unNumber: '1170', hazardClass: '3')],
          temp: -18),
      ComparedField.status: _unit('AAAU0000001',
          status: ContainerStatus.empty,
          dg: [DangerousGoods(unNumber: '1170', hazardClass: '3')],
          temp: -18),
      ComparedField.portOfLoading: _unit('AAAU0000001',
          pol: 'GTSTC',
          dg: [DangerousGoods(unNumber: '1170', hazardClass: '3')],
          temp: -18),
      ComparedField.portOfDischarge: _unit('AAAU0000001',
          pod: 'USLAX',
          dg: [DangerousGoods(unNumber: '1170', hazardClass: '3')],
          temp: -18),
      ComparedField.operator: _unit('AAAU0000001',
          line: 'LNB',
          dg: [DangerousGoods(unNumber: '1170', hazardClass: '3')],
          temp: -18),
      ComparedField.weight: _unit('AAAU0000001',
          vgm: 19500,
          dg: [DangerousGoods(unNumber: '1170', hazardClass: '3')],
          temp: -18),
      ComparedField.dangerousGoods: _unit('AAAU0000001',
          dg: [DangerousGoods(unNumber: '1263', hazardClass: '3')],
          temp: -18),
      ComparedField.temperature: _unit('AAAU0000001',
          dg: [DangerousGoods(unNumber: '1170', hazardClass: '3')],
          temp: -20),
    };
    expect(cases.keys, ComparedField.values);
    for (final entry in cases.entries) {
      final c = VoyageComparison.compare(
          _voyage([before]), _voyage([entry.value]));
      final change = c.permanent.single.changes.single;
      expect(change.field, entry.key);
      expect(change.before, VoyageComparison.valueOf(before, entry.key));
      expect(change.after, VoyageComparison.valueOf(entry.value, entry.key));
      expect(change.before, isNot(change.after));
      expect(c.changesByField[entry.key], 1);
      expect(c.changesByField.values.reduce((a, b) => a + b), 1);
    }
  });

  test('T-96 el peso es el efectivo de T-66: VGM si lo hay, si no WT', () {
    // Mismo VGM y distinto WT: el peso que usa la app no cambia.
    var c = VoyageComparison.compare(
        _voyage([_unit('AAAU0000001', wt: 21000, vgm: 20000)]),
        _voyage([_unit('AAAU0000001', wt: 22000, vgm: 20000)]));
    expect(c.permanent.single.changed, isFalse);
    // De VGM a solo WT con otra cifra: cambia, de 20 000 a 20 500.
    c = VoyageComparison.compare(
        _voyage([_unit('AAAU0000001', vgm: 20000)]),
        _voyage([_unit('AAAU0000001', wt: 20500, vgm: null)]));
    final w = c.permanent.single.changes.single;
    expect((w.field, w.before, w.after),
        (ComparedField.weight, 20000.0, 20500.0));
  });

  test('T-96 un campo que falta en uno de los dos cuenta como cambio', () {
    final c = VoyageComparison.compare(
        _voyage([_unit('AAAU0000001', pol: 'HNPCR', vgm: 20000)]),
        _voyage([
          _unit('AAAU0000001',
              pol: null, vgm: null, status: ContainerStatus.unknown)
        ]));
    final byField = {
      for (final x in c.permanent.single.changes) x.field: x
    };
    expect(byField[ComparedField.portOfLoading]!.after, isNull);
    expect(byField[ComparedField.weight]!.after, isNull);
    expect(byField[ComparedField.status]!.after, isNull);
    expect(byField[ComparedField.status]!.before, ContainerStatus.full);
  });

  test('T-96 las peligrosas se comparan sin importar el orden de los DGS', () {
    final a = DangerousGoods(unNumber: '1170', hazardClass: '3');
    final b = DangerousGoods(unNumber: '3077', hazardClass: '9');
    final c = VoyageComparison.compare(
        _voyage([_unit('AAAU0000001', dg: [a, b])]),
        _voyage([_unit('AAAU0000001', dg: [b, a])]));
    expect(c.permanent.single.changed, isFalse);
    expect(VoyageComparison.valueOf(c.permanent.single.first,
        ComparedField.dangerousGoods), 'UN1170 3, UN3077 9');
  });

  test('T-96 las reservas se cuentan aparte y no se clasifican', () {
    final c = VoyageComparison.compare(
        _voyage([_unit('AAAU0000001')]),
        _voyage([_unit('AAAU0000001')],
            reserved: [_slot('0010282'), _slot('0010284')]));
    expect((c.reservedFirst, c.reservedSecond), (0, 2));
    expect(c.loaded, isEmpty);
    expect(c.permanent, hasLength(1));
  });

  test('T-96 un número repetido no se clasifica y se reporta con su cuenta',
      () {
    final c = VoyageComparison.compare(
        _voyage([
          _unit('AAAU0000001'),
          _unit('AAAU0000001', position: '0030182'),
          _unit('AAAU0000002'),
        ]),
        _voyage([_unit('AAAU0000001'), _unit('AAAU0000002')]));
    expect(c.duplicatesFirst, {'AAAU0000001': 2});
    expect(c.duplicatesSecond, isEmpty);
    expect(c.permanent.map((p) => p.containerId), ['AAAU0000002']);
    expect(c.discharged, isEmpty);
    expect(c.loaded, isEmpty);
  });

  test('T-96 distinto buque: se compara igual, con el aviso', () {
    final c = VoyageComparison.compare(
        _voyage([_unit('AAAU0000001')], imo: '9000096'),
        _voyage([_unit('AAAU0000001')], imo: '9000097'));
    expect(c.permanent, hasLength(1));
    expect(c.vesselNotice, startsWith('No parece el mismo buque: '));
    expect(c.vesselNotice, contains('imo:9000096'));
    expect(c.vesselNotice, contains('imo:9000097'));
  });

  // 10.61: el aviso sigue a Vessel.matchIdentity y al tipo de las dos claves.
  const confirm = 'No se puede confirmar que sea el mismo buque: ';
  const different = 'No parece el mismo buque: ';
  final identityCases = <(String, VesselVoyage, VesselVoyage, String?)>[
    (
      'mismo nombre, indicativo e IMO: pide confirmar',
      _voyage([], imo: null, callSign: 'ZZC5603'),
      _voyage([], imo: '9000039'),
      confirm
    ),
    (
      'mismo nombre, los dos solo por nombre: pide confirmar',
      _voyage([], imo: null),
      _voyage([], imo: null),
      confirm
    ),
    (
      'mismo nombre y dos indicativos distintos: otro buque',
      _voyage([], imo: null, callSign: 'ZZC5603'),
      _voyage([], imo: null, callSign: 'ZZC5604'),
      different
    ),
    (
      'nombres distintos, indicativo e IMO: otro buque',
      _voyage([], imo: null, callSign: 'ZZC5603'),
      _voyage([], imo: '9000039', name: 'BUQUE OTRO'),
      different
    ),
    (
      'el mismo IMO con otro nombre: sin aviso',
      _voyage([], imo: '9000039'),
      _voyage([], imo: '9000039', name: 'BUQUE RENOMBRADO'),
      null
    ),
    (
      'el mismo indicativo: sin aviso',
      _voyage([], imo: null, callSign: 'ZZC5603'),
      _voyage([], imo: null, callSign: 'zzc5603'),
      null
    ),
  ];
  for (final (name, first, second, expected) in identityCases) {
    test('T-96 aviso de buque, $name', () {
      for (final (a, b) in [(first, second), (second, first)]) {
        final notice = VoyageComparison.compare(a, b).vesselNotice;
        if (expected == null) {
          expect(notice, isNull);
        } else {
          expect(notice, startsWith(expected));
        }
      }
    });
  }

  test('T-96 aviso de confirmar: nombra las dos claves y pide confirmar', () {
    final c = VoyageComparison.compare(
        _voyage([_unit('AAAU0000001')], imo: null, callSign: 'ZZC5603'),
        _voyage([_unit('AAAU0000001')], imo: '9000039'));
    expect(c.permanent, hasLength(1));
    expect(
        c.vesselNotice,
        'No se puede confirmar que sea el mismo buque: BUQUE T96 se '
        'identifica por indicativo ZZC5603 y BUQUE T96, por IMO 9000039. '
        'Confirma que es el mismo buque antes de usar la comparación.');
    expect(
        VoyageComparison.compare(_voyage([], imo: null), _voyage([], imo: null))
            .vesselNotice,
        'No se puede confirmar que sea el mismo buque: los dos archivos '
        'identifican a BUQUE T96 solo por su nombre. Confirma que es el mismo '
        'buque antes de usar la comparación.');
  });

  test('T-96 es simétrica: B contra A intercambia descargados y cargados', () {
    final a = _voyage([
      _unit('AAAU0000001'),
      _unit('AAAU0000002', pol: 'HNPCR', vgm: 20000),
    ]);
    final b = _voyage([
      _unit('AAAU0000002', pol: 'GTSTC', vgm: 19000),
      _unit('AAAU0000003'),
    ]);
    final ab = VoyageComparison.compare(a, b);
    final ba = VoyageComparison.compare(b, a);
    expect(ba.discharged.map((u) => u.containerId),
        ab.loaded.map((u) => u.containerId));
    expect(ba.loaded.map((u) => u.containerId),
        ab.discharged.map((u) => u.containerId));
    expect(ba.changesByField, ab.changesByField);
    expect([
      for (final x in ba.permanent.single.changes) (x.field, x.before, x.after)
    ], [
      for (final x in ab.permanent.single.changes) (x.field, x.after, x.before)
    ]);
  });
}
