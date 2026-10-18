// Corpus externo por --dart-define; huellas y avisos agregados solo en TEMP.
import 'dart:convert';
import 'dart:io';

import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 't98_support.dart';

Object? _stable(Object? value) {
  if (value is Map) {
    return {
      for (final entry in value.entries)
        if (entry.key != 'id' && entry.key != 'readNotices')
          entry.key: _stable(entry.value),
    };
  }
  if (value is List) return value.map(_stable).toList();
  return value;
}

void main() {
  const corpus = String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');
  const destination = String.fromEnvironment('T108_OUTPUT');
  const capture = bool.fromEnvironment('T108_CAPTURE_BASELINE');
  final output = t98Output(destination);
  final baselineFile = File('${output.path}/baseline.json');
  final rows = <Map<String, Object?>>[];
  final baseline = capture
      ? <String, dynamic>{}
      : jsonDecode(baselineFile.readAsStringSync()) as Map<String, dynamic>;
  for (final name in [
    'A01',
    'A02',
    'A03',
    'A04',
    'A05',
    'A06',
    'A07',
    'A08',
    'A03v_VGM',
    'A08v_VGM',
  ]) {
    test('T108 $name todos los campos anteriores sin cambios', () {
      final file = File('$corpus/CORPUS_$name.edi');
      final voyage = BaplieParserService().parse(file.readAsStringSync());
      final fingerprint =
          t98Hash(utf8.encode(jsonEncode(_stable(voyage.toJson()))));
      final facts = {
        'sourceSha256': t98Hash(file.readAsBytesSync()),
        'parsedSha256WithoutUuidOrNotices': fingerprint,
        'containers': voyage.totalContainers,
        'reservedSlots': voyage.totalReservedSlots,
        'weightKg': voyage.totalWeight,
      };
      if (capture) {
        baseline[name] = facts;
      } else {
        expect(facts, baseline[name],
            reason: '$name: solo pueden variar avisos');
      }
      // Se usa JSON para que este instrumento también compile sobre HEAD,
      // donde todavía no existe la propiedad de avisos en la entidad.
      final notices = (voyage.toJson()['readNotices'] as List<dynamic>?) ?? [];
      rows.add({
        'file': file.uri.pathSegments.last,
        ...facts,
        'smdg15Notice': voyage.metadata?.readWithV2Rules ?? false,
        'notices': [
          for (final notice in notices)
            {
              'kind': notice['kind'],
              'count': (notice['details'] as List).length
            },
        ],
      });
    });
  }
  tearDownAll(() {
    if (capture) {
      if (baselineFile.existsSync()) {
        throw StateError('No sobrescribir referencia.');
      }
      baselineFile.writeAsStringSync(jsonEncode(baseline));
    } else {
      t98Json(File('${output.path}/corpus-notices.json'), rows);
    }
    stdout.writeln('T108: ${rows.length} archivos; '
        '${capture ? 'referencia HEAD' : 'cotejo completo y avisos agregados'} en TEMP.');
  });
}
