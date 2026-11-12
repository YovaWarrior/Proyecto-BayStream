import 'dart:convert';
import 'dart:io';

import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/data/services/export_service.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

import 't86_corpus_support.dart';

/// T-144 · El volcado de T-140 otra vez, con el lector de T-144, para que Yov
/// repita el cotejo de H1.
///
/// Lee los diez archivos del corpus y guarda en `build/t144/h1/` el CSV que
/// exporta la app, uno por archivo, y `resumen.json`. Antes de leer compara
/// la huella SHA-256 de cada `.edi` con `build/t140/resumen.json` y se detiene
/// si alguna no coincide. Además compara cada CSV con el de `build/t140/`,
/// celda por celda y sin la columna `id` (un UUID), y anota en el resumen
/// cuántas celdas cambiaron en cada columna. Aquí no se juzga nada.
///
/// Ejecución (un solo comando de Flutter):
///
/// ```
/// flutter test tool/t144_volcado_test.dart --no-pub
///   --dart-define=BAYSTREAM_CORPUS_DIRECTORY=<carpeta del corpus>
///   --dart-define=BAYSTREAM_CORPUS_A07_A08_DIRECTORY=<carpeta de A07 y A08>
/// ```
///
/// Del corpus no entra nada al repositorio: `build/` está en `.gitignore`.
const _files = [
  'CORPUS_A01',
  'CORPUS_A02',
  'CORPUS_A03',
  'CORPUS_A03v_VGM',
  'CORPUS_A04',
  'CORPUS_A05',
  'CORPUS_A06',
  'CORPUS_A07',
  'CORPUS_A08',
  'CORPUS_A08v_VGM',
];

/// Desde el 11-nov, A07 y A08 no están en la carpeta del corpus (10.123).
const _apart = {'CORPUS_A07', 'CORPUS_A08'};

/// Un CSV con comillas a la RFC 4180, como lo escribe [ExportService].
List<List<String>> _csv(String text) {
  final rows = <List<String>>[];
  var row = <String>[];
  final field = StringBuffer();
  var quoted = false;
  final body = text.startsWith('﻿') ? text.substring(1) : text;
  for (var i = 0; i < body.length; i++) {
    final c = body[i];
    if (quoted) {
      if (c == '"') {
        if (i + 1 < body.length && body[i + 1] == '"') {
          field.write('"');
          i++;
        } else {
          quoted = false;
        }
      } else {
        field.write(c);
      }
    } else if (c == '"') {
      quoted = true;
    } else if (c == ',') {
      row.add(field.toString());
      field.clear();
    } else if (c == '\r' && i + 1 < body.length && body[i + 1] == '\n') {
      row.add(field.toString());
      field.clear();
      rows.add(row);
      row = <String>[];
      i++;
    } else {
      field.write(c);
    }
  }
  if (field.isNotEmpty || row.isNotEmpty) {
    row.add(field.toString());
    rows.add(row);
  }
  return rows;
}

void main() {
  test('T-144 · volcado del lector sobre los diez archivos del corpus',
      () async {
    const corpusDirectory =
        String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');
    const apartDirectory =
        String.fromEnvironment('BAYSTREAM_CORPUS_A07_A08_DIRECTORY');
    expect(corpusDirectory, isNotEmpty,
        reason:
            'Indica la carpeta real con --dart-define=BAYSTREAM_CORPUS_DIRECTORY=...');
    expect(apartDirectory, isNotEmpty,
        reason: 'Indica la carpeta de A07 y A08 con '
            '--dart-define=BAYSTREAM_CORPUS_A07_A08_DIRECTORY=...');

    final reference = File('build/t140/resumen.json');
    expect(reference.existsSync(), isTrue,
        reason: 'Falta build/t140/resumen.json, la referencia de las huellas.');
    final t140 = jsonDecode(reference.readAsStringSync()) as Map<String, dynamic>;
    final expectedHash = {
      for (final f in t140['files'] as List<dynamic>)
        (f as Map<String, dynamic>)['file'] as String: f['sha256'] as String,
    };
    final t140Headers = (t140['csvHeaders'] as List<dynamic>).cast<String>();

    // Primero todas las huellas: si alguna no coincide, no se lee ninguno.
    final sources = <String, List<int>>{};
    for (final name in _files) {
      final folder = _apart.contains(name) ? apartDirectory : corpusDirectory;
      final file = File('$folder/$name.edi');
      expect(file.existsSync(), isTrue, reason: 'Falta ${file.path}');
      final bytes = await file.readAsBytes();
      final hash = sha256.convert(bytes).toString();
      expect(hash, expectedHash['$name.edi'],
          reason: 'La huella de $name.edi no es la de build/t140/resumen.json');
      sources[name] = bytes;
    }

    final output = Directory('build/t144/h1');
    if (output.existsSync()) output.deleteSync(recursive: true);
    output.createSync(recursive: true);

    final parser = BaplieParserService();
    const exporter = ExportService();
    final summary = <Map<String, Object?>>[];

    for (final name in _files) {
      final bytes = sources[name]!;
      // Misma lectura que la app: bytes a código de carácter, sin decodificar.
      final source = String.fromCharCodes(bytes);
      final voyage = name == 'CORPUS_A06'
          ? readA06WithNotice(source)
          : parser.parse(source);

      final csv = exporter.serializeCsv(voyage);
      await File('${output.path}/$name.csv').writeAsString(csv, flush: true);
      final rows = _csv(csv);
      expect(rows.length, voyage.totalContainers + 1);

      // La comparación con T-140, columna por columna, sin `id`.
      final before = _csv(
          File('build/t140/$name.csv').readAsStringSync(encoding: utf8));
      expect(before.length, rows.length,
          reason: '$name: T-140 y T-144 deben tener las mismas filas');
      final changes = <String, int>{};
      for (var r = 1; r < rows.length; r++) {
        for (var c = 1; c < t140Headers.length; c++) {
          final header = t140Headers[c];
          final now = rows[r][ExportService.csvHeaders.indexOf(header)];
          if (now != before[r][c]) changes[header] = (changes[header] ?? 0) + 1;
        }
      }

      summary.add({
        'file': '$name.edi',
        'sha256': sha256.convert(bytes).toString(),
        'bytes': bytes.length,
        'messageVersion': voyage.metadata?.messageVersion,
        'readWithV2Rules': voyage.metadata?.readWithV2Rules ?? false,
        'containers': voyage.totalContainers,
        'reservedSlots': voyage.reservedSlots.length,
        'csv': '$name.csv',
        'csvRows': rows.length - 1,
        'containersWithTwoOrMoreDgs': voyage.containers
            .where((c) => (c.dangerousGoods?.length ?? 0) > 1)
            .length,
        'containersWithFinalDestination':
            voyage.containers.where((c) => c.finalDestination != null).length,
        'containersWithPortOfLoading':
            voyage.containers.where((c) => c.portOfLoading != null).length,
        'containersWithPortOfDischarge':
            voyage.containers.where((c) => c.portOfDischarge != null).length,
        'containersOverDimension':
            voyage.containers.where((c) => c.isOverDimension).length,
        'cellsChangedSinceT140': changes,
        'notices': [
          for (final notice in voyage.readNotices)
            {
              'kind': notice.kind.name,
              'count': notice.details.length,
              'details': notice.details,
            },
        ],
      });
      stdout.writeln('T144 $name.edi: ${voyage.totalContainers} contenedores, '
          '${voyage.readNotices.length} avisos, cambios $changes');
    }

    await File('${output.path}/resumen.json').writeAsString(
      const JsonEncoder.withIndent('  ').convert({
        'task': 'T-144',
        'generatedAt': DateTime.now().toUtc().toIso8601String(),
        'reference': 'build/t140/resumen.json',
        'csvHeaders': ExportService.csvHeaders,
        'files': summary,
      }),
      flush: true,
    );
    stdout.writeln('T144_VOLCADO_OK ${summary.length} archivos en ${output.path}');
  });
}
