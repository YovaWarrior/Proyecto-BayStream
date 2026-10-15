import 'dart:convert';
import 'dart:io';

import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:flutter_test/flutter_test.dart';

Object? _withoutIds(Object? value) {
  if (value is Map) {
    return {
      for (final e in value.entries)
        if (e.key != 'id') e.key: _withoutIds(e.value)
    };
  }
  if (value is List) return value.map(_withoutIds).toList();
  return value;
}

/// T-103 · Referencia de las nueve fuentes 2.x, tomada antes de tocar el
/// lector y guardada solo en %TEMP%. Se coteja con T86_BASELINE en
/// tool/t86_corpus_test.dart.
/// flutter test tool/t103_baseline.dart
/// --dart-define=BAYSTREAM_CORPUS_DIRECTORY=...
/// --dart-define=T103_BASELINE_OUT=%TEMP%/t103_baseline.json
void main() {
  const corpus = String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');
  const out = String.fromEnvironment('T103_BASELINE_OUT');
  test('T-103 referencia de las nueve fuentes 2.x', () {
    expect(corpus, isNotEmpty);
    expect(out, isNotEmpty);
    final reference = <String, Object?>{
      for (final name in const [
        'A01', 'A02', 'A03', 'A03v_VGM', 'A04', 'A05', 'A07', 'A08',
        'A08v_VGM',
      ])
        name: _withoutIds(BaplieParserService()
            .parse(File('$corpus/CORPUS_$name.edi').readAsStringSync())
            .toJson()),
    };
    File(out).writeAsStringSync(jsonEncode(reference));
    stdout.writeln('${reference.length} fuentes guardadas en $out');
  });
}
