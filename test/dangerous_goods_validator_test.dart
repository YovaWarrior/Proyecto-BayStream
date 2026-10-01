import 'dart:convert';

import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/data/datasources/local_vessel_codec.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/dangerous_goods.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/entities/stowage_validation_result.dart';
import 'package:baystream/features/vessel/domain/services/dangerous_goods_validator.dart';
import 'package:baystream/features/vessel/domain/services/segregation_rules.dart';
import 'package:flutter_test/flutter_test.dart';

const testGeometry = VesselGeometry(
    portRows: 6,
    starboardRows: 6,
    holdTiers: [2, 4, 6, 8, 10, 12, 14],
    deckTiers: [80, 82, 84, 86, 88, 90]);

ContainerUnit dangerous(String un, String hazard, String position,
        {String iso = '22G1', List<String> labels = const [], String? id}) =>
    ContainerUnit(
        id: id ?? '$un-$position',
        containerId: id ?? '$un-$position',
        isoSizeType: iso,
        isDangerous: true,
        unNumber: un,
        imdgClass: hazard,
        stowagePosition: IsoCoordinateParser.parse(position),
        dangerousGoods: [
          DangerousGoods(unNumber: un, hazardClass: hazard, labels: labels)
        ]);

void main() {
  const validator = DangerousGoodsValidator();
  test('T-41 DGS truncado conserva el peligro y produce no evaluado', () {
    const source = "TDT+20+V+1++NV:172:20+++9000003:146::PRUEBA'"
      "LOC+147+0010182:::5'EQD+CN+TEST0000001+22G1+++5'DGS+IMD'UNT+5+1'";
    final voyage = BaplieParserService().parse(source);
    expect(voyage.containers.single.isDangerous, isTrue);
    expect(voyage.containers.single.dangerousGoods, hasLength(1));
    expect(validator.validate(voyage.containers, testGeometry).single.status,
      ValidationStatus.notEvaluated);
  });
  StowageValidationResult pair(ContainerUnit a, ContainerUnit b,
          {VesselGeometry geometry = testGeometry}) =>
      validator.evaluatePair(
          a, a.dangerousGoods!.single, b, b.dangerousGoods!.single, geometry);

  test(
      'T-41 la submatriz contiene 28 pares citados, simétricos, sin valor por omisión',
      () {
    const expected = ['*22222X', 'X2121X', 'XX2XX', 'X11X', 'X2X', 'XX', 'X'];
    const codes = {
      '*': SegregationCode.compatibility,
      '2': SegregationCode.separated,
      '1': SegregationCode.away,
      'X': SegregationCode.substance
    };
    for (var i = 0; i < 7; i++) {
      for (var j = i; j < 7; j++) {
        final a = SegregationRules.classes[i], b = SegregationRules.classes[j];
        expect(SegregationRules.code(a, b), codes[expected[i][j - i]],
            reason: '$a/$b');
        expect(SegregationRules.code(b, a), SegregationRules.code(a, b));
      }
    }
    expect(SegregationRules.code('6.1', '3'), isNull);
    expect(SegregationRules.unProfiles, hasLength(17));
  });
  test('T-58 conserva las 17 entradas ONU contrastadas en t55_tabla_segregacion', () {
    const expected = <String, (String, List<String>, String?, bool, List<int>)>{
      '0012': ('1.4', [], 'S', false, []),
      '0303': ('1.4', [], 'G', false, []),
      '1950': ('2.1', [], null, true, []),
      '1170': ('3', [], null, false, []),
      '1263': ('3', [], null, false, []),
      '1266': ('3', [], null, false, []),
      '1993': ('3', [], null, false, []),
      '3065': ('3', [], null, false, []),
      '3175': ('4.1', [], null, false, []),
      '3085': ('5.1', ['8'], null, false, [56, 58, 138]),
      '1719': ('8', [], null, false, [52]),
      '2735': ('8', [], null, false, [52]),
      '2794': ('8', [], null, false, [53, 58]),
      '3084': ('8', ['5.1'], null, false, []),
      '3265': ('8', [], null, false, [53, 58]),
      '3077': ('9', [], null, false, []),
      '3082': ('9', [], null, false, []),
    };
    expect(SegregationRules.unProfiles.keys, unorderedEquals(expected.keys));
    for (final entry in expected.entries) {
      final actual = SegregationRules.unProfiles[entry.key]!;
      expect(actual.primary, entry.value.$1, reason: entry.key);
      expect(actual.subsidiary, entry.value.$2, reason: entry.key);
      expect(actual.compatibilityGroup, entry.value.$3, reason: entry.key);
      expect(actual.asClassNine, entry.value.$4, reason: entry.key);
      expect(actual.groupCodes, entry.value.$5, reason: entry.key);
    }
  });
  test('T-58 barrido T-55: ningún código 2 ni grupo queda conforme sin hueco', () {
    const source = <String, String>{
      '1.4/1.4': '*', '1.4/2.1': '2', '1.4/3': '2',
      '1.4/4.1': '2', '1.4/5.1': '2', '1.4/8': '2',
      '1.4/9': 'X', '2.1/2.1': 'X', '2.1/3': '2',
      '2.1/4.1': '1', '2.1/5.1': '2', '2.1/8': '1',
      '2.1/9': 'X', '3/3': 'X', '3/4.1': 'X',
      '3/5.1': '2', '3/8': 'X', '3/9': 'X',
      '4.1/4.1': 'X', '4.1/5.1': '1', '4.1/8': '1',
      '4.1/9': 'X', '5.1/5.1': 'X', '5.1/8': '2',
      '5.1/9': 'X', '8/8': 'X', '8/9': 'X', '9/9': 'X',
    };
    const profiles = SegregationRules.unProfiles;
    Set<String> classes(String un) {
      final p = profiles[un]!;
      return {p.asClassNine ? '9' : p.primary, ...p.subsidiary};
    }
    bool needsTwo(String a, String b) {
      for (final x in classes(a)) {
        for (final y in classes(b)) {
          if (source[([x, y]..sort()).join('/')] == '2') return true;
        }
      }
      return false;
    }
    const cases = <(String, String, bool)>[
      ('0020182', '0020382', false),
      ('0020182', '0020184', false),
      ('0020104', '0020304', false),
      ('0020104', '0020182', false),
      ('0020182', '0020582', true),
    ];
    final uns = profiles.keys.toList();
    for (final (left, right, spaced) in cases) {
      for (var i = 0; i < uns.length; i++) {
        for (var j = i; j < uns.length; j++) {
          final a = dangerous(uns[i], profiles[uns[i]]!.primary, left,
              iso: '45G1');
          final b = dangerous(uns[j], profiles[uns[j]]!.primary, right,
              iso: '45G1');
          final result = pair(a, b);
          final hasGroups = profiles[uns[i]]!.groupCodes.isNotEmpty ||
              profiles[uns[j]]!.groupCodes.isNotEmpty;
          if ((!spaced && needsTwo(uns[i], uns[j])) || hasGroups) {
            expect(result.status, isNot(ValidationStatus.conforming),
                reason: 'UN${uns[i]}/UN${uns[j]} en $left/$right');
          }
        }
      }
    }
  });
  test('T-58 casos sin regla de t55_tabla_segregacion no se aprueban', () {
    final partnerGoods = DangerousGoods(unNumber: '0012', hazardClass: '1.4');
    final partner = ContainerUnit(
      id: 'P', containerId: 'P', isoSizeType: '45G1', isDangerous: true,
      stowagePosition: const IsoCoordinate(
          bay: 2, row: 9, tier: 82, rawCode: '0020982'),
      dangerousGoods: [partnerGoods],
    );
    final valid = DangerousGoods(unNumber: '1170', hazardClass: '3');
    final cases = <(String, String?, String, DangerousGoods, bool)>[
      ('control', '45G1', '0020182', valid, true),
      ('ONU fuera', '45G1', '0020182',
          DangerousGoods(unNumber: '1203', hazardClass: '3'), false),
      ('ONU ausente', '45G1', '0020182',
          DangerousGoods(hazardClass: '3'), false),
      ('clase contradictoria', '45G1', '0020182',
          DangerousGoods(unNumber: '1170', hazardClass: '8'), false),
      ('clase ausente', '45G1', '0020182',
          DangerousGoods(unNumber: '1170'), false),
      ('etiqueta no cubierta', '45G1', '0020182',
          DangerousGoods(unNumber: '1170', hazardClass: '3',
              labels: ['6.1']), false),
      ('regulación no IMD', '45G1', '0020182',
          DangerousGoods(unNumber: '1170', hazardClass: '3',
              regulation: 'ADR'), false),
      ('techo abierto', '42U1', '0020182', valid, false),
      ('plataforma', '42P1', '0020182', valid, false),
      ('22K2', '22K2', '0010182', valid, false),
      ('ventilado', '22V1', '0010182', valid, false),
      ('sin ISO', null, '0020182', valid, false),
      ('20 en par', '22G1', '0020182', valid, false),
      ('40 en impar', '45G1', '0010182', valid, false),
      ('fuera de geometría', '45G1', '0021482', valid, false),
      ('sin posición', '45G1', 'XXXXXXX', valid, false),
    ];
    for (final (name, iso, position, goods, control) in cases) {
      final unit = ContainerUnit(
        id: 'U', containerId: 'U', isoSizeType: iso,
        stowagePosition: IsoCoordinateParser.tryParse(position),
        isDangerous: true, dangerousGoods: [goods],
      );
      final result = validator.evaluatePair(
          unit, goods, partner, partnerGoods, testGeometry);
      expect(result.status, control
          ? ValidationStatus.conforming : ValidationStatus.notEvaluated,
          reason: name);
    }
  });
  test('T-41 UN3084 incorpora 5.1 aunque DGS solo declare 8: no falso conforme',
      () {
    final result = pair(dangerous('3084', '8', '0140784', iso: '42G1'),
        dangerous('1993', '3', '0140984', iso: '42G1'));
    expect(result.status, ValidationStatus.nonConforming);
    expect(result.description, contains('5.1'));
    expect(result.references, contains('49 CFR §176.83(a)(6)'));
  });
  test('T-41 UN1950 sobre UN3085 no genera la falsa alarma de 2.1/5.1', () {
    final result = pair(dangerous('1950', '2.1', '0260186', iso: '42G1'),
        dangerous('3085', '5.1', '0260184', iso: '42G1'));
    expect(result.status, ValidationStatus.notEvaluated);
    expect(result.description, contains('código 126'));
    expect(result.description, contains('Grupos de segregación no evaluados'));
    expect(result.severity, ValidationSeverity.warning);
  });
  test('T-41 UN1950 y 1.4G se resuelven por la excepción ONU', () {
    final result = pair(dangerous('1950', '2.1', '0270184'),
        dangerous('0303', '1.4', '0270182'));
    expect(result.status, ValidationStatus.conforming);
    expect(result.description, contains('código 87'));
  });
  test('T-41 1.4S/1.4G se obtiene por ONU, también dentro de la misma unidad',
      () {
    final result = pair(dangerous('0012', '1.4', '0270182', id: 'same'),
        dangerous('0303', '1.4', '0270182', id: 'same'));
    expect(result.status, ValidationStatus.conforming);
    expect(result.references, contains('49 CFR §176.144(a),(e)'));
    expect(result.description, contains('S/G'));
  });
  test(
      'T-41 ONU desconocido, clase contradictoria y etiqueta no cubierta no aprueban',
      () {
    final b = dangerous('1993', '3', '0010182');
    for (final a in [
      dangerous('9999', '3', '0050182'),
      dangerous('0012', '1.4G', '0050182'),
      dangerous('1993', '6.1', '0050182'),
      dangerous('1993', '3', '0050182', labels: ['3', '6.1'])
    ]) {
      expect(pair(a, b).status, ValidationStatus.notEvaluated);
    }
  });
  test('T-41 ácido/álcali queda no evaluado aunque haya mucha distancia', () {
    final result = pair(
        dangerous('1719', '8', '0010182'), dangerous('3265', '8', '0410182'));
    expect(result.status, ValidationStatus.notEvaluated);
    expect(result.description, contains('confirmar con el embarcador'));
    expect(result.references, contains('49 CFR §176.83(m)(1)-(2)'));
  });
  test(
      'T-41 misma ONU con secundario no implica reacción peligrosa ni compatibilidad',
      () {
    final result = pair(
        dangerous('3084', '8', '0010182'), dangerous('3084', '8', '0010184'));
    expect(result.status, ValidationStatus.notEvaluated);
    expect(result.references, contains('49 CFR §176.83(a)(8)'));
  });
  test('T-41 22K2, abierto y tipo ausente no se consideran unidades cerradas',
      () {
    for (final iso in ['22K2', '22U1', '22P1', '']) {
      final result = pair(dangerous('1993', '3', '0010182', iso: iso),
          dangerous('3077', '9', '0030182'));
      expect(result.status, ValidationStatus.notEvaluated);
      expect(result.description, contains('cerrada no confirmado'));
    }
  });
  test(
      'T-41 code 1 permite unidades cerradas distintas pero no la misma unidad',
      () {
    final a = dangerous('3175', '4.1', '0010182');
    final b = dangerous('3084', '8', '0010184');
    expect(pair(a, b).status, ValidationStatus.conforming);
    final result = pair(a, b.copyWith(id: a.id));
    expect(result.status, ValidationStatus.nonConforming);
    expect(result.references, contains('49 CFR §176.83(d)'));
  });
  test('T-41 code 2 usa huellas de 40 pies, no distancia entre centros', () {
    final a = dangerous('0303', '1.4', '0020182', iso: '42G1');
    expect(pair(a, dangerous('1993', '3', '0060182', iso: '42G1')).status,
        ValidationStatus.nonConforming);
    final result = pair(a, dangerous('1993', '3', '0080182', iso: '42G1'));
    expect(result.status, ValidationStatus.conforming);
    expect(result.description, contains('Derivación por huecos, no medición'));
  });
  test('T-41 filas pares e impares se comparan por orden físico e incluyen 00',
      () {
    final a = dangerous('0303', '1.4', '0010282');
    expect(pair(a, dangerous('1993', '3', '0010082')).status,
        ValidationStatus.nonConforming);
    expect(pair(a, dangerous('1993', '3', '0010182'),
        geometry: testGeometry.copyWith(centerRowOnDeck: true)).status,
        ValidationStatus.conforming);
  });

  test('T-58 caso T-55: 02/01 sin fila 00 no queda conforme', () {
    final a = dangerous('1170', '3', '0020282', iso: '45G1');
    final b = dangerous('0012', '1.4', '0020182', iso: '45G1');
    expect(pair(a, b).status, ValidationStatus.nonConforming);
    expect(pair(a, b, geometry: testGeometry.copyWith(centerRowOnDeck: false))
        .status, ValidationStatus.nonConforming);
    expect(pair(a, b, geometry: testGeometry.copyWith(centerRowOnDeck: true))
        .status, ValidationStatus.conforming);

    final holdA = dangerous('1170', '3', '0020204', iso: '45G1');
    final holdB = dangerous('0012', '1.4', '0020104', iso: '45G1');
    expect(pair(holdA, holdB).status, ValidationStatus.notEvaluated);
    expect(pair(holdA, holdB,
        geometry: testGeometry.copyWith(centerRowInHold: true)).status,
        ValidationStatus.conforming);

    final controlled = <(String, String, ValidationStatus)>[
      ('0020182', '0020382', ValidationStatus.nonConforming),
      ('0020282', '0020482', ValidationStatus.nonConforming),
      ('0020082', '0020182', ValidationStatus.nonConforming),
      ('0020282', '0020382', ValidationStatus.conforming),
      ('0020104', '0020304', ValidationStatus.notEvaluated),
    ];
    for (final (left, right, expected) in controlled) {
      expect(pair(dangerous('1170', '3', left, iso: '45G1'),
          dangerous('0012', '1.4', right, iso: '45G1')).status, expected,
          reason: '$left / $right, casos controlados de t55_fila_central');
    }
  });

  test('T-58 caso T-55: etiqueta 3 o 5.1 impone código 2 al par 1.4', () {
    final b = dangerous('0303', '1.4', '0020382', iso: '45G1');
    final pure = dangerous('0012', '1.4', '0020182', iso: '45G1');
    expect(pair(pure, b).status, ValidationStatus.conforming);
    expect(pair(dangerous('1170', '3', '0020182', iso: '45G1'), b).status,
        ValidationStatus.nonConforming);
    expect(pair(dangerous('0012', '1.4', '0020182',
        iso: '45G1', labels: ['3']),
        dangerous('1170', '3', '0020382', iso: '45G1')).status,
        ValidationStatus.nonConforming);
    for (final label in ['3', '5.1']) {
      final withLabel = dangerous('0012', '1.4', '0020182',
          iso: '45G1', labels: [label]);
      expect(pair(withLabel, b).status, ValidationStatus.nonConforming,
          reason: 'etiqueta $label');
      expect(pair(b, withLabel).status, ValidationStatus.nonConforming,
          reason: 'orden inverso, etiqueta $label');
    }
  });

  test('T-58 tanque ISO T se evalúa como unidad cerrada', () {
    final tank = dangerous('1170', '3', '0010182', iso: '22T1');
    final other = dangerous('0012', '1.4', '0030182');
    final result = pair(tank, other);
    expect(result.status, ValidationStatus.nonConforming);
    expect(result.description, isNot(contains('cerrada no confirmado')));
  });
  test('T-41 misma vertical entre zonas y mamparo desconocido no se aprueban',
      () {
    expect(
        pair(dangerous('0303', '1.4', '0010182'),
                dangerous('1993', '3', '0010102'))
            .status,
        ValidationStatus.notEvaluated);
    expect(
        pair(dangerous('0303', '1.4', '0010102'),
                dangerous('1993', '3', '0030102'))
            .status,
        ValidationStatus.notEvaluated);
    expect(
        pair(dangerous('0303', '1.4', '0010182'),
                dangerous('1993', '3', '0010184'))
            .status,
        ValidationStatus.nonConforming);
  });
  test('T-41 usa frontera declarada y no clasifica tier 80 con otra constante',
      () {
    final a = dangerous('0303', '1.4', '0010180'),
        b = dangerous('1993', '3', '0010182');
    expect(pair(a, b).status, ValidationStatus.nonConforming);
    final geometry = testGeometry
        .copyWith(deckTierFloor: 82, holdTiers: [2, 80], deckTiers: [82, 84]);
    expect(
        pair(a, b, geometry: geometry).status, ValidationStatus.notEvaluated);
  });
  test(
      'T-41 posición no cubierta, longitud desconocida o bay incompatible: no evaluado',
      () {
    final b = dangerous('1993', '3', '0010182');
    for (final a in [
      dangerous('0303', '1.4', '0013182'),
      dangerous('0303', '1.4', '0020182'),
      dangerous('0303', '1.4', '0030198')
    ]) {
      expect(pair(a, b).status, ValidationStatus.notEvaluated);
    }
  });
  test('T-41 etiquetas secundarias recibidas también restringen la evaluación',
      () {
    final a = dangerous('1993', '3', '0010182', labels: ['3', '5.1']);
    expect(pair(a, dangerous('3082', '9', '0030182')).status,
        ValidationStatus.conforming);
    expect(pair(a, dangerous('3175', '4.1', '0010184')).description,
        contains('Código 1'));
  });
  test(
      'T-41 un peligro desconocido solitario o histórico no desaparece por falta de pares',
      () {
    final unknown = dangerous('9999', '3', '0010182');
    expect(validator.validate([unknown], testGeometry).single.status,
        ValidationStatus.notEvaluated);
    const legacy = ContainerUnit(
        id: 'old',
        containerId: 'OLD',
        isDangerous: true,
        imdgClass: '3',
        unNumber: '1993',
        isoSizeType: '22G1');
    expect(validator.validate([legacy], testGeometry).single.description,
        contains('histórico'));
  });
  test('T-41 parser conserva cada DGS, C236 y el roundtrip JSON/Hive', () {
    const source = "TDT+20+V+1++NV:172:20+++9000003:146::PRUEBA'"
        "LOC+147+0010182:::5'EQD+CN+TEST0000001+22G1+++5'"
        "DGS+IMD+3+1993++I+++++3:5.1:0'DGS+IMD+9+3082++III'"
        "LOC+147+0030182:::5'EQD+CN+TEST0000002+22G1+++5'UNT+8+1'";
    final voyage =
        BaplieParserService().parse(source).withGeometry(testGeometry);
    expect(voyage.containers.first.dangerousGoods, hasLength(2));
    expect(voyage.containers.first.dangerousGoods!.first.labels, ['3', '5.1']);
    expect(voyage.containers.last.dangerousGoods, isEmpty);
    final decoded = const LocalVesselCodec()
        .decodeVoyage(const LocalVesselCodec().encodeVoyage(voyage));
    expect(decoded.containers, voyage.containers);
    final old = jsonDecode(jsonEncode(voyage.containers.first.toJson()))
        as Map<String, dynamic>;
    old.remove('dangerousGoods');
    expect(ContainerUnit.fromJson(old).dangerousGoods, isNull);
  });
}
