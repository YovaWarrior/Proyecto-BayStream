// T-114 · Fase 2 del rediseño: las fuentes empaquetadas con su licencia y su
// procedencia, como web/fonts/ en T-92. Si un TTF cambia sin actualizar
// provenance.json, esta prueba lo dice.
import 'dart:convert';
import 'dart:io';

import 'package:baystream/core/design/design.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

/// El mismo texto tal cual, con LF y con CRLF.
List<List<int>> _finesDeLinea(List<int> bytes) {
  final texto = utf8.decode(bytes);
  final lf = texto.replaceAll('\r\n', '\n');
  return <List<int>>[bytes, utf8.encode(lf), utf8.encode(lf.replaceAll('\n', '\r\n'))];
}

void main() {
  // La laptop escribe CRLF: se normaliza para buscar líneas enteras.
  final pubspec = File('pubspec.yaml').readAsStringSync().replaceAll('\r\n', '\n');
  final carpeta = Directory('assets/fonts/plex');

  test('pubspec declara las familias que usa el tema, y Roboto de respaldo', () {
    for (final familia in [
      BsFuentes.sans,
      BsFuentes.condensada,
      BsFuentes.mono,
      ...BsFuentes.respaldo,
    ]) {
      expect(pubspec, contains('- family: $familia\n'), reason: familia);
    }
  });

  test('cada asset de fuente declarado en pubspec existe', () {
    final rutas = RegExp(r'- asset: (assets/fonts/\S+\.ttf)')
        .allMatches(pubspec)
        .map((m) => m.group(1)!)
        .toList();
    expect(rutas, hasLength(9));
    for (final ruta in rutas) {
      expect(File(ruta).existsSync(), isTrue, reason: ruta);
    }
  });

  test('provenance.json cubre los siete TTF y la licencia, con SHA-256 exacto',
      () {
    final entradas = (jsonDecode(
            File('${carpeta.path}/provenance.json').readAsStringSync())
        as List<dynamic>)
        .cast<Map<String, dynamic>>();
    expect(entradas, hasLength(8));
    final archivos = <String>{};
    for (final entrada in entradas) {
      final archivo = File('${carpeta.path}/${entrada['file']}');
      expect(archivo.existsSync(), isTrue, reason: entrada['file'] as String);
      final bytes = archivo.readAsBytesSync();
      // La licencia es texto y git la escribe con el fin de línea del equipo
      // (CRLF en la laptop, LF en una copia de `git archive`): vale cualquiera
      // de las dos formas (10.16). Los TTF son binarios y se comparan tal cual.
      final variantes = (entrada['file'] as String).endsWith('.txt')
          ? _finesDeLinea(bytes)
          : <List<int>>[bytes];
      expect(variantes.map((b) => b.length), contains(entrada['bytes']),
          reason: entrada['file'] as String);
      expect(
          variantes.map((b) => sha256.convert(b).toString().toUpperCase()),
          contains(entrada['sha256']),
          reason: entrada['file'] as String);
      expect(entrada['url'] as String, startsWith('https://raw.githubusercontent.com/IBM/plex/'));
      expect(entrada['commit'], isNotEmpty);
      archivos.add(entrada['file'] as String);
    }
    expect(archivos, containsAll(<String>[
      'IBMPlexSans-Regular.ttf',
      'IBMPlexSans-Medium.ttf',
      'IBMPlexSans-SemiBold.ttf',
      'IBMPlexSansCondensed-Medium.ttf',
      'IBMPlexSansCondensed-SemiBold.ttf',
      'IBMPlexMono-Regular.ttf',
      'IBMPlexMono-Medium.ttf',
      'LICENSE-IBMPlex.txt',
    ]));
  });

  test('la licencia es la SIL Open Font License de IBM Plex', () {
    final licencia =
        File('${carpeta.path}/LICENSE-IBMPlex.txt').readAsStringSync();
    expect(licencia, contains('SIL Open Font License, Version 1.1'));
    expect(licencia, contains('IBM Corp.'));
    expect(licencia, contains('Reserved Font Name "Plex"'));
  });
}
