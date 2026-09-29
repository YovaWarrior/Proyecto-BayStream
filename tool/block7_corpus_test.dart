import 'dart:convert';
import 'dart:io';
import 'package:baystream/features/vessel/data/datasources/hive_vessel_data_source.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'block7_checks.dart';

void main() {
  test('T-38/T-41 seis archivos reales, regresiones A03 y persistencia Hive',
      () async {
    const corpus = String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');
    expect(corpus, isNotEmpty);
    final sources = <String, String>{};
    for (var n = 1; n <= 6; n++) {
      final name = 'A0$n';
      sources[name] = await File('$corpus/CORPUS_$name.edi').readAsString();
    }
    final root = await Directory('build/block7').create(recursive: true);
    final directory = await root.createTemp('corpus_');
    try {
      final metrics = await checkBlock7(
          sources,
          () async => LocalVesselRepositoryImpl(await HiveVesselDataSource.open(
              directory: directory.path, namespace: 'block7')));
      await File('${root.path}/corpus-results.json')
          .writeAsString(const JsonEncoder.withIndent('  ').convert(metrics));
    } finally {
      await directory.delete(recursive: true);
    }
  });
}
