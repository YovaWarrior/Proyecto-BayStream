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
    const source = "UNH+1+BAPLIE:D:95B:UN:SMDG20'"
        "TDT+20+V+1++NV:172:20+++9000003:146::PRUEBA'"
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
  test('T-85 reemplaza la submatriz por 17 clases simetricas', () {
    expect(SegregationRules.classes.length, 17);
    for (final a in SegregationRules.classes) {
      for (final b in SegregationRules.classes) {
        expect(SegregationRules.code(a, b), SegregationRules.code(b, a));
        expect(SegregationRules.code(a, b), isNotNull);
      }
    }
    expect(SegregationRules.code('10', '3'), isNull);
  });
  test('T-85 reemplaza perfiles ONU por la clase declarada', () {
    expect(
        pair(dangerous('1203', '3', '0010182'),
                dangerous('9999', '5.1', '0050182'))
            .status,
        ValidationStatus.conforming);
    expect(
        pair(dangerous('1170', '8', '0010182'),
                dangerous('9999', '5.1', '0010382'))
            .status,
        ValidationStatus.nonConforming);
  });
  test('T-85 barrido de codigos numericos sin huecos no aprueba 2 a 4', () {
    for (final a in SegregationRules.classes) {
      for (final b in SegregationRules.classes) {
        final code = SegregationRules.code(a, b)!;
        if (SegregationRules.requirement(code) >= 2) {
          expect(
              pair(dangerous('0001', a, '0010182'),
                      dangerous('0002', b, '0010382'))
                  .status,
              ValidationStatus.nonConforming,
              reason: '$a/$b');
        }
      }
    }
  });
  test('T-85 clase ausente regulacion o etiqueta desconocida no aprueban', () {
    final b = dangerous('0002', '5.1', '0010982');
    for (final hazard in ['', '10', '2.4']) {
      expect(pair(dangerous('0001', hazard, '0010182'), b).status,
          ValidationStatus.notEvaluated);
    }
    expect(pair(dangerous('0001', '3', '0010182', labels: ['10']), b).status,
        ValidationStatus.notEvaluated);
    final d = DangerousGoods(hazardClass: '3', regulation: 'ADR');
    final a = dangerous('0001', '3', '0010182');
    expect(
        validator
            .evaluatePair(a, d, b, b.dangerousGoods!.single, testGeometry)
            .status,
        ValidationStatus.notEvaluated);
  });
  test('T-85 UN3084 no infiere 5.1 cuando DGS solo declara 8', () {
    expect(
        pair(dangerous('3084', '8', '0140784', iso: '42G1'),
                dangerous('1993', '3', '0140984', iso: '42G1'))
            .status,
        ValidationStatus.notEvaluated);
  });
  test('T-85 UN1950 conserva clase 2.1 y no excepcion ONU de otra norma', () {
    expect(
        pair(dangerous('1950', '2.1', '0260186', iso: '42G1'),
                dangerous('3085', '5.1', '0260184', iso: '42G1'))
            .status,
        ValidationStatus.nonConforming);
  });
  test('T-85 UN1950 con 1.4 aplica 2 de 7.2.4', () {
    final r = pair(dangerous('1950', '2.1', '0270184'),
        dangerous('0303', '1.4', '0270182'));
    expect(r.status, ValidationStatus.nonConforming);
    expect(r.description, contains('Exigencia 2'));
  });
  test('T-85 1.4S con 1.4G remite a 7.2.7.1 incluso misma unidad', () {
    final r = pair(dangerous('0012', '1.4S', '0270182', id: 'same'),
        dangerous('0303', '1.4G', '0270182', id: 'same'));
    expect(r.status, ValidationStatus.notEvaluated);
    expect(r.references, contains('IMDG 42-24, 7.2.7.1'));
  });
  test('T-85 numero ONU no decide la clase ni limita las 17 filas', () {
    expect(
        pair(dangerous('9999', '6.1', '0010182'),
                dangerous('1993', '4.2', '0010382'))
            .status,
        ValidationStatus.conforming);
    expect(
        pair(dangerous('9999', '9', '0010182'),
                dangerous('1993', '3', '0050182'))
            .status,
        ValidationStatus.notEvaluated);
  });
  test('T-85 acido alcali sin lista queda X aunque haya distancia', () {
    final r = pair(
        dangerous('1719', '8', '0010182'), dangerous('3265', '8', '0410182'));
    expect(r.status, ValidationStatus.notEvaluated);
    expect(r.description, contains('Lista de mercancías peligrosas'));
  });
  test('T-85 mismo principal con secundario aplica la mayor exigencia', () {
    expect(
        pair(dangerous('3084', '8', '0010182', labels: ['5.1']),
                dangerous('3084', '8', '0010184'))
            .status,
        ValidationStatus.nonConforming);
  });
  test('T-85 tipo desconocido no se supone cerrado', () {
    for (final iso in ['22K2', '22Z1', '']) {
      expect(
          pair(dangerous('1993', '3', '0010182', iso: iso),
                  dangerous('0002', '5.1', '0050182'))
              .status,
          ValidationStatus.notEvaluated);
    }
  });
  test('T-85 codigo 1 permite cerradas distintas pero no misma unidad', () {
    final a = dangerous('3175', '4.1', '0010182');
    final b = dangerous('3084', '8', '0010184');
    expect(pair(a, b).status, ValidationStatus.conforming);
    expect(
        pair(a, b.copyWith(id: a.id)).status, ValidationStatus.nonConforming);
  });
  test('T-85 codigo 2 usa bordes de 40 pies y no centros', () {
    final a = dangerous('0303', '1.4', '0020182', iso: '42G1');
    expect(pair(a, dangerous('1993', '3', '0060182', iso: '42G1')).status,
        ValidationStatus.nonConforming);
    expect(pair(a, dangerous('1993', '3', '0080182', iso: '42G1')).status,
        ValidationStatus.conforming);
  });
  test('T-85 filas pares impares y 00 mantienen orden fisico', () {
    final a = dangerous('0303', '1.4', '0010282');
    final b = dangerous('1993', '3', '0010182');
    expect(pair(a, b).status, ValidationStatus.nonConforming);
    expect(
        pair(a, b, geometry: testGeometry.copyWith(centerRowOnDeck: true))
            .status,
        ValidationStatus.conforming);
  });
  test('T-85 02 y 01 sin fila 00 no crean hueco en cubierta o bodega', () {
    for (final tier in ['82', '04']) {
      final a = dangerous('1170', '3', '00202$tier', iso: '45G1');
      final b = dangerous('0012', '1.4', '00201$tier', iso: '45G1');
      expect(
          pair(a, b).status,
          tier == '82'
              ? ValidationStatus.nonConforming
              : ValidationStatus.notEvaluated);
    }
  });
  test('T-85 00 observada solo prueba hueco en bahia y zona del par', () {
    final a = dangerous('1170', '3', '0260284', iso: '45G1');
    final b = dangerous('0012', '1.4', '0260184', iso: '45G1');
    ContainerUnit center(String p) => ContainerUnit(
        id: 'center',
        containerId: 'center',
        isoSizeType: '45G1',
        stowagePosition: IsoCoordinateParser.parse(p));
    for (final p in ['0360084', '0260004']) {
      expect(validator.validate([a, b, center(p)], testGeometry).single.status,
          ValidationStatus.nonConforming);
    }
    final r =
        validator.validate([a, b, center('0260084')], testGeometry).single;
    expect(r.status, ValidationStatus.conforming);
    expect(r.description, contains('fila 00 ocupada en este viaje'));
    expect(
        validator
            .validate([a, b, center('0260084')],
                testGeometry.copyWith(centerRowOnDeck: false))
            .single
            .status,
        ValidationStatus.nonConforming);
  });
  test('T-85 secundario numerico prevalece sobre asterisco con aviso', () {
    final a = dangerous('0012', '1.4', '0020182', iso: '45G1', labels: ['3']);
    final b = dangerous('0303', '1.4', '0020382', iso: '45G1');
    expect(pair(a, b).status, ValidationStatus.nonConforming);
    expect(pair(b, a).status, ValidationStatus.nonConforming);
    expect(pair(a, b).references, contains('IMDG 42-24, 7.2.7.1'));
  });
  test('T-85 tanque y todos los tipos cerrados de Carlos se evaluan', () {
    for (final type in ['G', 'R', 'T', 'B', 'V', 'H']) {
      expect(
          pair(dangerous('1170', '3', '0010182', iso: '22${type}1'),
                  dangerous('0012', '1.4', '0030182'))
              .status,
          ValidationStatus.nonConforming);
    }
  });
  test('T-85 entre zonas usa tapa para 2 y mamparo sigue desconocido', () {
    final a = dangerous('0303', '1.4', '0010182');
    final r = pair(a, dangerous('1993', '3', '0010102'));
    expect(r.status, ValidationStatus.conforming);
    expect(r.description, contains('IMDG 7.4.2.2'));
    expect(
        pair(dangerous('0303', '1.4', '0010102'),
                dangerous('1993', '3', '0030102'))
            .status,
        ValidationStatus.notEvaluated);
  });
  test('T-85 respeta frontera de zona declarada', () {
    final a = dangerous('0303', '1.4', '0010180');
    final b = dangerous('1993', '3', '0010182');
    expect(pair(a, b).status, ValidationStatus.nonConforming);
    expect(
        pair(a, b,
            geometry: testGeometry.copyWith(
                deckTierFloor: 82,
                holdTiers: [2, 80],
                deckTiers: [82, 84])).status,
        ValidationStatus.conforming);
  });
  test('T-85 posicion longitud o paridad no conocidas no se aprueban', () {
    final b = dangerous('1993', '3', '0010182');
    for (final p in ['0013182', '0020182', '0030198']) {
      expect(pair(dangerous('0303', '1.4', p), b).status,
          ValidationStatus.notEvaluated);
    }
  });
  test('T-85 secundarios declarados no convierten la clase 9 en conforme', () {
    final a = dangerous('1993', '3', '0010182', labels: ['3', '5.1']);
    expect(pair(a, dangerous('3082', '9', '0030182')).status,
        ValidationStatus.notEvaluated);
    expect(pair(a, dangerous('3175', '4.1', '0010184')).description,
        contains('Exigencia 1'));
  });
  test('T-85 peligro desconocido solitario e historico sigue visible', () {
    expect(
        validator
            .validate([dangerous('9999', '10', '0010182')], testGeometry)
            .single
            .status,
        ValidationStatus.notEvaluated);
    const legacy = ContainerUnit(
        id: 'old',
        containerId: 'OLD',
        isDangerous: true,
        imdgClass: '3',
        unNumber: '1993',
        isoSizeType: '22G1');
    expect(validator.validate([legacy], testGeometry).single.description,
        contains('lista completa'));
  });
  test('T-41 parser conserva cada DGS, C236 y el roundtrip JSON/Hive', () {
    const source = "UNH+1+BAPLIE:D:95B:UN:SMDG20'"
        "TDT+20+V+1++NV:172:20+++9000003:146::PRUEBA'"
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
