// T-141 · Fuzzing del lector BAPLIE de la 1.0.0 (sección 5, entrada).
//
// Dart puro, sin Flutter: toma los archivos sintéticos de test/fixtures/ y les
// aplica mutaciones (truncar, duplicar segmentos, separadores rotos, caracteres
// fuera de ASCII, campos vacíos, longitudes absurdas y azar determinista), y
// pasa cada mutante por BaplieParserService.parse.
//
// Lo que exige cada caso: ninguna excepción sin capturar (solo
// BaplieParsingException, que el producto traduce a un mensaje con causa y
// acción), ningún cuelgue (límite de 5 s por caso, medidos) y siempre un
// mensaje de falla con contenido.
//
// Uso, con la luz verde de Carlos (un comando de Dart a la vez):
//
//     dart run tool/t141_fuzz_baplie.dart [--detalle]
//
// Escribe build/t141/fuzz-baplie.json y sale con 0 si ningún mutante falló,
// 1 si alguno falló y 2 si no encontró los fixtures.

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:baystream/core/errors/exceptions.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';

const fixtureDir = 'test/fixtures';
const limite = Duration(seconds: 5);

final parser = BaplieParserService();
final resultados = <Map<String, Object?>>[];
final mensajes = <String>{};

void main(List<String> args) {
  final detalle = args.contains('--detalle');
  final archivos = Directory(fixtureDir)
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.edi'))
      .map((f) => f.path)
      .toList()
    ..sort();
  if (archivos.isEmpty) {
    stderr.writeln('No hay fixtures en $fixtureDir');
    exit(2);
  }

  var fallas = 0;
  for (final archivo in archivos) {
    final original = File(archivo).readAsStringSync();
    for (final (nombre, mutante) in mutaciones(original, archivo)) {
      final r = _correr(archivo, nombre, mutante);
      resultados.add(r);
      if (r['clase'] == 'FALLA') fallas++;
      if (detalle || r['clase'] == 'FALLA') {
        print('${r['clase'].toString().padRight(9)} · ${r['caso']}'
            '${r['clase'] == 'FALLA' ? ' · ${r['detalle']}' : ''}');
      }
    }
  }

  final porClase = <String, int>{};
  for (final r in resultados) {
    porClase.update(r['clase'].toString(), (v) => v + 1, ifAbsent: () => 1);
  }
  print('');
  print('Mutantes: ${resultados.length} · '
      'leidos bien: ${porClase['ok'] ?? 0} · '
      'rechazo con mensaje: ${porClase['controlada'] ?? 0} · '
      'fallas: ${porClase['FALLA'] ?? 0}');
  print('Mensajes de rechazo distintos: ${mensajes.length}');
  for (final m in mensajes.toList()..sort()) {
    print('  - $m');
  }

  Directory('build/t141').createSync(recursive: true);
  File('build/t141/fuzz-baplie.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert({
        'fecha': DateTime.now().toIso8601String(),
        'mutantes': resultados.length,
        'porClase': porClase,
        'mensajes': mensajes.toList()..sort(),
        'resultados': resultados,
      }));
  exit(fallas == 0 ? 0 : 1);
}

Map<String, Object?> _correr(String archivo, String nombre, String mutante) {
  final inicio = DateTime.now();
  try {
    final viaje = parser.parse(mutante);
    final ms = DateTime.now().difference(inicio).inMilliseconds;
    return {
      'caso': '${archivo.split('/').last}/$nombre',
      'clase': ms > limite.inMilliseconds ? 'FALLA' : 'ok',
      'ms': ms,
      'detalle': ms > limite.inMilliseconds ? 'tardó ${ms}ms' : null,
      'contenedores': viaje.containers.length,
    };
  } on BaplieParsingException catch (e) {
    final ms = DateTime.now().difference(inicio).inMilliseconds;
    final mensaje = e.message.trim();
    final decente =
        mensaje.isNotEmpty && mensaje.length >= 10 && !mensaje.contains(r'$');
    if (decente) mensajes.add(mensaje);
    return {
      'caso': '${archivo.split('/').last}/$nombre',
      'clase': decente && ms <= limite.inMilliseconds ? 'controlada' : 'FALLA',
      'ms': ms,
      'detalle': decente ? null : 'mensaje sin causa ni acción: «$mensaje»',
    };
  } catch (e, s) {
    final ms = DateTime.now().difference(inicio).inMilliseconds;
    return {
      'caso': '${archivo.split('/').last}/$nombre',
      'clase': 'FALLA',
      'ms': ms,
      'detalle': '${e.runtimeType}: $e (primera línea: ${s.toString().split('\n').first})',
    };
  }
}

/// Las mutaciones, deterministas: el azar lleva semilla fija.
Iterable<(String, String)> mutaciones(String original, String archivo) sync* {
  final rng = Random(141);
  final medio = original.length ~/ 2;

  // 1 · Truncados (4)
  yield ('truncado al 10 %', original.substring(0, original.length * 10 ~/ 100));
  yield ('truncado al 50 %', original.substring(0, medio));
  yield ('truncado al 90 %', original.substring(0, original.length * 90 ~/ 100));
  final dentroDeSegmento = original.indexOf('LOC+147') + 5;
  yield ('truncado dentro de un segmento (LOC+147)',
      original.substring(0, dentroDeSegmento));

  // 2 · Segmentos duplicados (3)
  final idx147 = original.indexOf('LOC+147');
  final fin147 = original.indexOf("'", idx147) + 1;
  yield ('bloque LOC/EQD/MEA duplicado',
      original.substring(0, fin147) + original.substring(idx147, fin147) + original.substring(fin147));
  yield ('archivo entero dos veces', original + original);
  final unhFin = original.indexOf("'") + 1;
  yield ('encabezado UNB/UNH duplicado',
      original.substring(0, unhFin) + original.substring(0, unhFin) + original.substring(unhFin));

  // 3 · Separadores rotos (4)
  yield ("sin terminador de segmento", original.replaceAll("'", ''));
  yield ("terminador ';'", original.replaceAll("'", ';'));
  yield ("sin separador de elemento", original.replaceAll('+', ''));
  final sinUnb = original.replaceFirst("UNB+UNOA:2+SENDERID+RECEIVERID+231015:0900+000001'", '');
  yield ("cabecera UNA con otros separadores", "UNA+:.? ='$sinUnb");

  // 4 · Fuera de ASCII (5)
  yield ('emoji en medio',
      original.replaceRange(medio, medio, '🚢📦'));
  yield ('caracter de control NUL', original.replaceRange(medio, medio, '\x00'));
  yield ('byte 0xFF crudo',
      original.replaceRange(medio, medio, String.fromCharCode(0xFF)));
  yield ('acentos y ñ en medio',
      original.replaceRange(medio, medio, 'ÁÉÍÓÚÑü'));
  yield ('CJK en el número de contenedor',
      original.replaceFirst(RegExp(r'EQD\+CN\+[A-Z]{4}'), 'EQD+CN+货柜编号'));

  // 5 · Campos vacíos (3)
  yield ('posición vacía en LOC+147',
      original.replaceFirst(RegExp(r'LOC\+147\+[0-9:]+'), 'LOC+147+:::'));
  yield ('número de contenedor vacío',
      original.replaceFirst(RegExp(r'EQD\+CN\+[A-Z0-9]+'), 'EQD+CN+'));
  yield ('valores de peso vacíos',
      original.replaceAll(RegExp(r'MEA\+AAE\+[A-Z]+\+KGM:[0-9]+'), 'MEA+AAE+WT+KGM:'));

  // 6 · Longitudes absurdas (5)
  yield ('contenedor de 10000 caracteres',
      original.replaceFirst(RegExp(r'EQD\+CN\+[A-Z0-9]+'), 'EQD+CN+${'A' * 10000}'));
  yield ('un segmento de 1 MB',
      "BGM+129+${'X' * 1000000}+9'$original");
  yield ('5000 segmentos LOC repetidos',
      'LOC+147+0100102:::5\'' * 5000 + original);
  yield ('TDT con viaje de 100000 caracteres',
      original.replaceFirst(RegExp(r'TDT\+20\+[^+]+'), 'TDT+20+${'V' * 100000}'));
  yield ('fixture repetido hasta 2 MB', original * (2 * 1024 * 1024 ~/ original.length + 1));

  // 7 · Azar determinista (20 por archivo)
  const alfabeto = "+:'?*🚢Á\x00xFF货";
  for (var i = 0; i < 20; i++) {
    var b = original;
    for (var j = 0; j < 1 + rng.nextInt(8); j++) {
      final pos = rng.nextInt(b.length);
      switch (rng.nextInt(4)) {
        case 0: // borrar un caracter
          b = b.replaceRange(pos, pos + 1, '');
        case 1: // insertar uno raro
          b = b.replaceRange(pos, pos, alfabeto[rng.nextInt(alfabeto.length)]);
        case 2: // duplicar una rebanada
          final largo = 1 + rng.nextInt(50);
          final fin = pos + largo > b.length ? b.length : pos + largo;
          b = b.replaceRange(fin, fin, b.substring(pos, fin));
        default: // cambiar un caracter
          b = b.replaceRange(pos, pos + 1, alfabeto[rng.nextInt(alfabeto.length)]);
      }
    }
    yield ('azar determinista #$i', b);
  }

  // El propio archivo original, como control (debe leerse bien).
  yield ('CONTROL original', original);
}
