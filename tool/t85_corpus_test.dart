import 'dart:io';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/stowage_validation_result.dart';
import 'package:baystream/features/vessel/domain/entities/vessel_geometry.dart';
import 'package:baystream/features/vessel/domain/services/dangerous_goods_validator.dart';
import 'package:flutter_test/flutter_test.dart';
import 't86_corpus_support.dart';

/// Corpus externo; sin archivos privados IMDG ni EDI embebidos.
void main() {
  const directory = String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');
  const counts = <String, (int, int, int)>{
    'A01': (0, 6, 0),
    'A02': (0, 1, 2),
    'A03': (4, 154, 95),
    'A03v_VGM': (4, 154, 95),
    'A04': (0, 1, 0),
    'A05': (0, 1, 0),
    'A06': (0, 1, 0),
    'A07': (0, 120, 0),
    'A08': (0, 1, 0),
    'A08v_VGM': (0, 1, 0),
  };
  for (final source in counts.entries) {
    test(
        'T85 ${source.key}: resultados IMDG y todas las referencias explicitas',
        () {
      expect(directory, isNotEmpty);
      final text =
          File('$directory/CORPUS_${source.key}.edi').readAsStringSync();
      final v = source.key == 'A06'
          ? readA06WithNotice(text)
          : BaplieParserService().parse(text);
      final g = VesselGeometry.proposeFrom(v.stowagePositions);
      final results = const DangerousGoodsValidator().validate(v.containers, g);
      int count(ValidationStatus s) =>
          results.where((r) => r.status == s).length;
      expect((
        count(ValidationStatus.nonConforming),
        count(ValidationStatus.notEvaluated),
        count(ValidationStatus.conforming)
      ), source.value);
      for (final r in results) {
        expect(r.references, isNotEmpty);
        expect(r.references.every((s) => s.startsWith('IMDG 42-24')), isTrue);
        expect(r.description, isNotEmpty);
        expect(r.description, isNot(contains('49 CFR')));
        expect(r.containerIds, isNotEmpty);
      }
      stdout.writeln(
          'T85 ${source.key}: ${source.value} (no conformes / no evaluados / conformes evaluados)');
    });
  }
}
