import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/t98_catalogo_invalidos.dart';
import '../tool/t98_estandares_corpus.dart';
import '../tool/t98_support.dart';

void main() {
  test('T98 oráculo ISO6346 contra vector conocido CSQU3054383', () {
    expect(t98CheckDigit('CSQU305438'), 3);
    expect(t98ValidId('CSQU3054383'), isTrue);
    expect(t98ValidId('CSQU3054384'), isFalse);
  });
  for (final bad in ['', 'TEST', 'ABCU12345', '123U123456', 'ABCA123456']) {
    test('T98 oráculo rechaza prefijo mal formado: $bad', () {
      expect(() => t98CheckDigit(bad), throwsArgumentError);
      expect(t98ValidId(bad), isFalse);
    });
  }
  test('T98 catálogo ocho casos reproducibles, vacío y bytes corruptos', () {
    final a = t98Invalids(t98Message());
    final b = t98Invalids(t98Message());
    expect(a, hasLength(8));
    expect(a, b);
    expect(a['08_vacio.edi'], isEmpty);
    expect(a['01_bytes_aleatorios.edi'], hasLength(256));
    expect(utf8.decode(a['04_sin_unt_unz.edi']!), isNot(contains('UNT+')));
    expect(utf8.decode(a['05_sin_tdt.edi']!), isNot(contains('TDT+')));
    expect(utf8.decode(a['06_coprar.edi']!), contains('COPRAR:'));
    expect(utf8.decode(a['07_version_no_admitida.edi']!), contains('SMDG31'));
  });
  test('T98 catálogo exige fuente reconocible', () {
    expect(() => t98Invalids('texto'), throwsArgumentError);
  });
  test('T98 segmentación respeta liberación y UNA', () {
    expect(t98Segments("FTX+AAI+++DATO?'PROTEGIDO'UNZ+1+X'"),
        ["FTX+AAI+++DATO?'PROTEGIDO", 'UNZ+1+X']);
    expect(t98Segments('UNA:+.? ~UNH+1+BAPLIE~UNZ+1+1~'),
        ['UNH+1+BAPLIE', 'UNZ+1+1']);
  });
  test('T98 CSV UNECE conserva comas y comillas en nombres', () {
    expect(t98Csv(',GT,STC,"Nombre, ""puerto"""\r\n'), [
      ['', 'GT', 'STC', 'Nombre, "puerto"']
    ]);
    expect(() => t98Csv('"sin cierre'), throwsFormatException);
  });
  test('T98 cobertura distingue FTX, NAD y LOC por grupo', () {
    final covered = t98Coverage([
      'UNH+1',
      'NAD+CA+X',
      'TDT+20',
      'LOC+5+GTSTC',
      'LOC+147+0020182',
      'FTX+AAA',
      'LOC+11+PAMIT',
      'EQD+CN+TEST',
      'NAD+CA+X',
      'DGS+IMD+3',
      'FTX+AAD',
    ]);
    expect(
        covered,
        containsAll([
          'cabecera/NAD',
          'SG1/LOC',
          'SG2/LOC',
          'SG2/FTX',
          'SG3/NAD',
          'SG4/FTX'
        ]));
  });
  test('T98 salida solo temporal y huella estable', () async {
    final output = await Directory.systemTemp.createTemp('t98_test_');
    addTearDown(() => output.delete(recursive: true));
    expect(t98Output(output.path).existsSync(), isTrue);
    expect(
        () => t98Output(Directory.systemTemp.parent.path), throwsArgumentError);
    expect(t98Hash(utf8.encode('abc')),
        'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad');
  });
}
