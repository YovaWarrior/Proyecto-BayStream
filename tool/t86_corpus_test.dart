import 'dart:convert';
import 'dart:io';

import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 't86_corpus_support.dart';

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

/// Corpus externo; referencia anterior opcional, exclusivamente en %TEMP%.
/// flutter test tool/t86_corpus_test.dart
/// --dart-define=BAYSTREAM_CORPUS_DIRECTORY=...
/// --dart-define=T86_BASELINE=.../t86_baseline.json
void main() {
  const corpus = String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');
  const baselinePath = String.fromEnvironment('T86_BASELINE');
  final baseline = baselinePath.isEmpty
      ? null
      : jsonDecode(File(baselinePath).readAsStringSync())
          as Map<String, dynamic>;
  const expected = {
    'A01': (977, 0, 8366089.0),
    'A02': (806, 0, 10719976.0),
    'A03': (369, 0, 7419486.99),
    'A03v_VGM': (369, 0, 7419486.99),
    'A04': (979, 0, 12267702.0),
    'A05': (736, 0, 11210489.02),
    'A07': (398, 0, 6940578.0),
    'A08': (405, 55, 6899700.0),
    'A08v_VGM': (405, 55, 6899700.0),
  };
  for (final entry in expected.entries) {
    test('T-86 ${entry.key}: lectura 2.x sin diferencias', () {
      expect(corpus, isNotEmpty);
      final v = BaplieParserService()
          .parse(File('$corpus/CORPUS_${entry.key}.edi').readAsStringSync());
      expect(v.totalContainers, entry.value.$1);
      expect(v.totalReservedSlots, entry.value.$2);
      expect(v.totalWeight, closeTo(entry.value.$3, 0.000001));
      expect(v.metadata!.readWithV2Rules, isFalse, reason: 'T-103: sin aviso');
      if (baseline != null) {
        expect(_withoutIds(v.toJson()), baseline[entry.key],
            reason:
                'todos los campos, reservas y bahías, salvo los UUID nuevos');
      }
      stdout.writeln(
          '${entry.key}: ${v.totalContainers} + ${v.totalReservedSlots} reservas; '
          '${v.totalWeight.toStringAsFixed(2)} kg; '
          '${baseline == null ? 'conteos/pesos' : 'todos los campos anteriores'} sin diferencias');
    });
  }
  // T-103: A06 deja de ser el espécimen del rechazo y se lee con aviso.
  test('T-86 A06 real: SMDG15 se lee como 1.5 con aviso', () {
    expect(corpus, isNotEmpty);
    expect(
        readA06WithNotice(File('$corpus/CORPUS_A06.edi').readAsStringSync())
            .metadata!
            .readWithV2Rules,
        isTrue);
  });
}
