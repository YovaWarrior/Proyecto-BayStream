import 'dart:convert';
import 'dart:io';

import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';

/// Cronómetro auxiliar del parser Dart; no representa el APK ni el cliente UI.
/// Uso: dart run tool/t44_corpus_parse.dart build/t44
void main(List<String> args) {
  if (args.length != 1) {
    stderr.writeln('Uso: dart run tool/t44_corpus_parse.dart DIRECTORIO');
    exitCode = 64;
    return;
  }
  const names = [
    'A01',
    'A02',
    'A03',
    'A03v_VGM',
    'A04',
    'A05',
    'A06',
  ];
  final results = <String, Object>{};
  for (final name in names) {
    final raw = File('${args.single}/CORPUS_$name.edi').readAsStringSync();
    final timesUs = <int>[];
    var containers = 0;
    var bays = 0;
    for (var repetition = 0; repetition < 5; repetition++) {
      final timer = Stopwatch()..start();
      final voyage = BaplieParserService().parse(raw);
      timer.stop();
      timesUs.add(timer.elapsedMicroseconds);
      containers = voyage.totalContainers;
      bays = voyage.bays.length;
    }
    final sorted = [...timesUs]..sort();
    results[name] = {
      'containers': containers,
      'bays': bays,
      'fiveParseTimesUs': timesUs,
      'medianUs': sorted[2],
      'maximumUs': sorted.last,
    };
  }
  stdout.writeln(const JsonEncoder.withIndent('  ').convert(results));
}
