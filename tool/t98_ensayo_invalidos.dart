import 'dart:io';

import 'package:baystream/core/errors/exceptions.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';

import 't98_support.dart';

void main(List<String> args) {
  if (args.length != 2) throw ArgumentError('Uso: CATALOGO SALIDA_TEMP');
  final output = t98Output(args[1]);
  final files = Directory(args[0])
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.edi'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  if (files.length != 8) throw StateError('Se requieren los ocho casos.');
  final rows = <Object>[];
  for (final file in files) {
    var outcome = 'aceptado_sin_excepcion';
    String? segment;
    try {
      BaplieParserService().parse(file.readAsStringSync());
    } on BaplieParsingException catch (error) {
      outcome = 'rechazado_por_lector';
      segment = RegExp(r'^[A-Z]{3}$').hasMatch(error.segment ?? '')
          ? error.segment
          : null;
    } on FileSystemException {
      outcome = 'no_decodificable_utf8';
    } on FormatException {
      outcome = 'no_decodificable_utf8';
    } catch (_) {
      outcome = 'otra_excepcion_no_volcada';
    }
    rows.add({
      'archivo': file.uri.pathSegments.last,
      'sha256': t98Hash(file.readAsBytesSync()),
      'lector': outcome,
      'segmento': segment
    });
  }
  t98Json(File('${output.path}/ensayo-invalidos.json'), {
    'fase': 'A; ensayo de lector, no recuperación UI ni medición RNF',
    'casos': rows,
  });
  stdout.writeln(
      'T98: catálogo ensayado sin cronometrar ni volcar mensajes/datos.');
}
