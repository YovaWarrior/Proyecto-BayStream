import 'package:baystream/core/errors/exceptions.dart';
import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../tool/t98_support.dart';

// Sin skips ni expectativas invertidas: una aceptación negativa hace FALLAR
// el caso de conformidad. No autoriza a corregir lib/ ni es medición de Fase B.
void main() {
  final parser = BaplieParserService();
  for (final position in ['0010002', '0020182', '9999999']) {
    test('T98 BBBRRTT positivo $position', () {
      expect(parseIsoCoordinates(position).toIsoCode(), position);
      expect(
          parser
              .parse(t98Message(position: position))
              .containers
              .single
              .stowagePosition!
              .toIsoCode(),
          position);
    });
  }
  for (final position in ['01234', '01200000', '012A082', '-120082']) {
    test('T98 BBBRRTT negativo $position', () {
      expect(() => parseIsoCoordinates(position),
          throwsA(isA<InvalidIsoCoordinateException>()));
      expect(() => parser.parse(t98Message(position: position)),
          throwsA(isA<BaplieParsingException>()),
          reason: 'No debe aceptar silenciosamente una posición inválida.');
    });
  }
  for (final prefix in ['CSQU305438', 'TSTU000098', 'ABCU123456']) {
    final valid = '$prefix${t98CheckDigit(prefix)}';
    test('T98 ISO6346 positivo $prefix', () {
      expect(t98ValidId(valid), isTrue);
      expect(parser.parse(t98Message(id: valid)).containers.single.containerId,
          valid);
    });
    test('T98 ISO6346 negativo $prefix', () {
      final invalid = '$prefix${(t98CheckDigit(prefix) + 1) % 10}';
      expect(t98ValidId(invalid), isFalse);
      expect(() => parser.parse(t98Message(id: invalid)),
          throwsA(isA<BaplieParsingException>()),
          reason:
              'ID alterado aceptado sin aviso = caso de conformidad fallido.');
    });
  }
  test('T98 peso WT en KGM conserva 24000 kg', () {
    expect(parser.parse(t98Message()).containers.single.grossWeight, 24000);
  });
  test('T98 VGM en KGM conserva masa verificada', () {
    expect(
        parser.parse(t98Message(qualifier: 'VGM')).containers.single.vgmWeight,
        24000);
  });
  for (final unit in ['LBR', 'TNE']) {
    test('T98 peso negativo en $unit', () {
      expect(() => parser.parse(t98Message(unit: unit)),
          throwsA(isA<BaplieParsingException>()),
          reason: 'No debe presentar otra unidad como kilogramos sin aviso.');
    });
  }
  test('T98 estructura positiva SMDG22 y grupos 1, 2 y 3', () {
    expect(parser.parse(t98Message()).containers, hasLength(1));
  });
  test('T98 grupo 4 positivo conserva clase IMDG y número ONU', () {
    final source = t98Message().replaceFirst('UNT+13+', "DGS+IMD+3+1993'\nUNT+14+");
    final goods = parser.parse(source).containers.single.dangerousGoods!.single;
    expect(goods.hazardClass, '3');
    expect(goods.unNumber, '1993');
  });
  for (final tag in ['UNB', 'UNH', 'BGM', 'TDT', 'UNT', 'UNZ']) {
    test('T98 estructura negativa sin $tag obligatorio', () {
      final source = t98Segments(t98Message())
          .where((s) => !s.startsWith('$tag+'))
          .map((s) => "$s'")
          .join();
      expect(() => parser.parse(source), throwsA(isA<BaplieParsingException>()),
          reason: 'Segmento obligatorio ausente aceptado sin aviso.');
    });
  }
  for (final pair in [
    ['BAPLIE:D:95B:UN:SMDG22', 'COPRAR:D:95B:UN:SMDG22'],
    ['BAPLIE:D:95B:UN:SMDG22', 'BAPLIE:D:13B:UN:SMDG31'],
    ['TDT+20+', 'TDT+99+'],
  ]) {
    test('T98 calificador/tipo negativo ${pair[1]}', () {
      expect(() => parser.parse(t98Message().replaceFirst(pair[0], pair[1])),
          throwsA(isA<BaplieParsingException>()));
    });
  }
}
