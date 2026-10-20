import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 't98_support.dart';

Map<String, List<int>> t98Invalids(String a01) {
  final segments = t98Segments(a01);
  final middle = segments.indexWhere((s) => s.startsWith('EQD+'));
  if (middle < 0 || !segments.any((s) => s.startsWith('UNH+'))) {
    throw ArgumentError('A01 no contiene UNH/EQD.');
  }
  final random = Random(98);
  return {
    '01_bytes_aleatorios.edi': List.generate(256, (_) => random.nextInt(256)),
    '02_texto_sin_edifact.edi': utf8.encode('Esto no es un mensaje EDIFACT.'),
    '03_segmento_cortado.edi': utf8.encode(
        "${segments.take(middle).join("'\n")}'\n${segments[middle].substring(0, segments[middle].length ~/ 2)}"),
    '04_sin_unt_unz.edi': utf8.encode(segments
        .where((s) => !s.startsWith('UNT+') && !s.startsWith('UNZ+'))
        .map((s) => "$s'\n")
        .join()),
    '05_sin_tdt.edi': utf8.encode(segments
        .where((s) => !s.startsWith('TDT+'))
        .map((s) => "$s'\n")
        .join()),
    '06_coprar.edi':
        utf8.encode(t98Message().replaceFirst('BAPLIE:', 'COPRAR:')),
    '07_version_no_admitida.edi': utf8.encode(t98Message()
        .replaceFirst('BAPLIE:D:95B:UN:SMDG22', 'BAPLIE:D:13B:UN:SMDG31')),
    '08_vacio.edi': [],
  };
}

void main(List<String> args) {
  const corpus = String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');
  if (args.length != 1 || corpus.isEmpty) {
    throw ArgumentError(
        'Declarar BAYSTREAM_CORPUS_DIRECTORY por --define y pasar SALIDA_TEMP.');
  }
  final source = File('$corpus/CORPUS_A01.edi');
  final output = t98Output(args[0]);
  final cases = t98Invalids(source.readAsStringSync());
  // Control válido para la UI, leído por la misma definición del corpus.
  final control = Directory('${output.path}/control')..createSync();
  final controlFile = File('${control.path}/A01.edi');
  if (controlFile.existsSync()) throw StateError('No sobrescribir el control.');
  source.copySync(controlFile.path);
  final manifest = <Object>[];
  var i = 0;
  for (final entry in cases.entries) {
    final target = File('${output.path}/${entry.key}');
    if (target.existsSync()) {
      throw StateError('No sobrescribir un catálogo existente.');
    }
    target.writeAsBytesSync(entry.value);
    manifest.add({
      'caso': entry.key,
      'clase': [
        'corrupto',
        'corrupto',
        'incompleto',
        'incompleto',
        'incompleto',
        'no soportado',
        'no soportado',
        'no soportado'
      ][i++],
      'bytes': entry.value.length,
      'sha256': t98Hash(entry.value)
    });
  }
  t98Json(File('${output.path}/catalogo.json'), {
    'fase': 'A: instrumento; no es medición',
    'sintetico': true,
    'semilla': 98,
    'origen': 'A01 anonimizado',
    'origenSha256': t98Hash(source.readAsBytesSync()),
    'casos': manifest,
  });
  stdout.writeln('T-98: ocho entradas sintéticas en TEMP; sin dictamen.');
}
