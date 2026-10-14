import 'dart:io';

import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/data/services/export_list_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/container_voice_query.dart';
import 'package:baystream/features/vessel/domain/services/export_list_cross_checker.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const corpus = String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');
  const digits = [
    'cero',
    'uno',
    'dos',
    'tres',
    'cuatro',
    'cinco',
    'seis',
    'siete',
    'ocho',
    'nueve'
  ];
  const letters = [
    'a',
    'be',
    'ce',
    'de',
    'e',
    'efe',
    'ge',
    'hache',
    'i',
    'jota',
    'ka',
    'ele',
    'eme',
    'ene',
    'o',
    'pe',
    'cu',
    'erre',
    'ese',
    'te',
    'u',
    'uve',
    'doble uve',
    'equis',
    'ye',
    'zeta'
  ];
  for (final name in ['A08', 'A08v_VGM']) {
    test(
        'T-94 $name: 121 números completos y sufijos dictados encuentran las filas originales',
        () {
      expect(corpus, isNotEmpty);
      final parsed = BaplieParserService()
          .parse(File('$corpus/CORPUS_$name.edi').readAsStringSync());
      final loading = parsed.withGeometry(
          VesselProfile.proposeFrom(parsed).geometry,
          portOfCall: 'GTSTC');
      final raw = const ExportListParserService().parseXlsx(
          File('$corpus/LISTADO_A08.xlsx').readAsBytesSync(),
          fileName: 'LISTADO_A08.xlsx');
      final proposals =
          ExportListCrossChecker.propose(raw, loading, portOfCall: 'GTSTC')
              .map((p) => p.kind == EquivalenceKind.type && p.listCode == '40RF'
                  ? p.choose('45R1')
                  : p)
              .toList();
      final list = raw.normalized(ExportListCrossChecker.tableOf(proposals));
      final data = LoadingOperation.build(
          operationId: 't94', loading: loading, list: list);
      final rows =
          list.rows.where((row) => data.numbered(row) != null).toList();
      expect(rows, hasLength(121));
      for (final row in rows) {
        String speak(String text) => text
            .split('')
            .map((c) => int.tryParse(c) != null
                ? digits[int.parse(c)]
                : letters[c.codeUnitAt(0) - 65])
            .join(' ');
        final full = normalizeContainerVoiceQuery(speak(row.containerId));
        expect(full, row.containerId);
        expect(data.search(full), [row]);
        final suffix = row.containerId.substring(row.containerId.length - 4);
        expect(data.search(normalizeContainerVoiceQuery(speak(suffix))),
            data.search(suffix));
        expect(data.search(suffix), contains(row),
            reason: 'La búsqueda conserva posibles ambigüedades.');
      }
      expect(data.movements, isEmpty);
      expect(data.progress.total, 176);
    });
  }
}
