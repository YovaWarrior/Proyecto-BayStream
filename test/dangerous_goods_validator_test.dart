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
    expect(pair(a, dangerous('1993', '3', '0010182')).status,
        ValidationStatus.conforming);
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
