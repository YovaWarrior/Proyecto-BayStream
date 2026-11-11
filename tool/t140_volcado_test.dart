import 'dart:convert';
import 'dart:io';

import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/data/services/export_service.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

import 't86_corpus_support.dart';

/// T-140 · Volcado del lector de la 1.0.0 para medir H1.
///
/// Lee los diez archivos del corpus con [BaplieParserService] (A06 con la
/// lectura con aviso de la 1.5, como en `block2_corpus_test.dart`) y guarda
/// por archivo el CSV que exporta la app ([ExportService.serializeCsv], con
/// los encabezados de [ExportService.csvHeaders]). Además deja en
/// `build/t140/resumen.json` la huella SHA-256 de cada `.edi`, el número de
/// contenedores leídos y los avisos del lector. La comparación contra los
/// `.edi` la hace Yov; aquí no se juzga nada.
///
/// Ejecución (un solo comando de Flutter):
///
/// ```
/// flutter test tool/t140_volcado_test.dart --no-pub
///   --dart-define=BAYSTREAM_CORPUS_DIRECTORY=<carpeta del corpus>
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

void main() {
  test('T-140 · volcado del lector sobre los diez archivos del corpus',
      () async {
    const corpusDirectory =
        String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');
    expect(corpusDirectory, isNotEmpty,
        reason:
            'Indica la carpeta real con --dart-define=BAYSTREAM_CORPUS_DIRECTORY=...');
    final output = Directory('build/t140');
    if (output.existsSync()) output.deleteSync(recursive: true);
    output.createSync(recursive: true);

    final parser = BaplieParserService();
    const exporter = ExportService();
    final summary = <Map<String, Object?>>[];

    for (final name in _files) {
      final file = File('$corpusDirectory/$name.edi');
      expect(file.existsSync(), isTrue, reason: 'Falta ${file.path}');
      final bytes = await file.readAsBytes();
      // Misma lectura que la app: bytes a código de carácter, sin decodificar.
      final source = String.fromCharCodes(bytes);
      // A06 es la 1.5 y se lee con aviso (T-103), como en block2.
      final voyage = name == 'CORPUS_A06'
          ? readA06WithNotice(source)
          : parser.parse(source);

      final csv = exporter.serializeCsv(voyage);
      final csvFile = File('${output.path}/$name.csv');
      await csvFile.writeAsString(csv, flush: true);
      final csvLines = csv.split('\r\n').where((l) => l.isNotEmpty).length;
      // Una fila por contenedor más el encabezado: el CSV no omite ninguno.
      expect(csvLines, voyage.totalContainers + 1);

      summary.add({
        'file': '$name.edi',
        'sha256': sha256.convert(bytes).toString(),
        'bytes': bytes.length,
        'messageVersion': voyage.metadata?.messageVersion,
        'readWithV2Rules': voyage.metadata?.readWithV2Rules ?? false,
        'containers': voyage.totalContainers,
        'reservedSlots': voyage.reservedSlots.length,
        'csv': '$name.csv',
        'csvRows': csvLines - 1,
        'notices': [
          for (final notice in voyage.readNotices)
            {
              'kind': notice.kind.name,
              'count': notice.details.length,
              'details': notice.details,
            },
        ],
      });
      stdout.writeln(
          'T140 $name.edi: ${voyage.totalContainers} contenedores, '
          '${voyage.readNotices.length} avisos');
    }

    final summaryFile = File('${output.path}/resumen.json');
    await summaryFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert({
        'task': 'T-140',
        'generatedAt': DateTime.now().toUtc().toIso8601String(),
        'csvHeaders': ExportService.csvHeaders,
        'files': summary,
      }),
      flush: true,
    );
    stdout.writeln('T140_VOLCADO_OK ${summary.length} archivos en ${output.path}');
  });
}
