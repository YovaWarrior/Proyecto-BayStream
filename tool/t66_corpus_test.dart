import 'dart:io';

import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/bay_plan_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// T-66 · Aceptación contra el corpus real anonimizado.
/// Uso: flutter test tool/t66_corpus_test.dart
///        --dart-define=BAYSTREAM_CORPUS_DIRECTORY=CARPETA_DEL_CORPUS
void main() {
  const corpus = String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');

  VesselVoyage open(String name) {
    expect(corpus, isNotEmpty, reason: 'Indica el directorio del corpus real');
    final parsed = BaplieParserService()
        .parse(File('$corpus/CORPUS_$name.edi').readAsStringSync());
    return parsed.withGeometry(VesselProfile.proposeFrom(parsed).geometry);
  }

  // Cifras de la ficha T-66 de SPRINT-3.md.
  const expected = {
    'A07': (398, 6940578.0),
    'A05': (736, 11210489.0),
    'A08': (405, 6899700.0),
    'A08v_VGM': (405, 6899700.0),
    'A01': (977, 8366089.0),
  };

  for (final entry in expected.entries) {
    test('T-66 ${entry.key}: ${entry.value.$1} contenedores, '
        '${entry.value.$2.toStringAsFixed(0)} kg y ninguno sin peso', () {
      final voyage = open(entry.key);
      expect(voyage.totalContainers, entry.value.$1);
      // A05 trae decimales de kilo (11 210 489.02): se compara al kilo.
      expect(voyage.totalWeight.round(), entry.value.$2.round());
      final bays = voyage.bays.values
          .fold<double>(0, (sum, bay) => sum + bay.totalWeight);
      expect(bays.round(), entry.value.$2.round(),
          reason: 'las bahías suman lo mismo que el viaje');
      expect(voyage.containers.where((c) => c.effectiveWeight == null),
          isEmpty, reason: 'ninguno saldría «N/A kg»');
      stdout.writeln('T-66 ${entry.key}: ${voyage.totalContainers} contenedores · '
          '${voyage.totalWeight.toStringAsFixed(2)} kg · '
          'VGM ${voyage.containers.where((c) => c.weightSource == WeightSource.vgm).length} · '
          'WT ${voyage.containers.where((c) => c.weightSource == WeightSource.gross).length}');
    });
  }

  for (final name in ['A07', 'A08v_VGM']) {
    testWidgets('T-66 $name: cada celda con contenedor muestra su peso',
        (tester) async {
      final voyage = open(name);
      tester.view.physicalSize = const Size(1600, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final scope = ProviderContainer();
      addTearDown(scope.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
          container: scope,
          child: MaterialApp(
              home: Scaffold(body: BayPlanView(voyage: voyage)))));
      var cells = 0;
      final numbers = voyage.bays.keys.toList()..sort();
      for (final number in numbers) {
        scope.read(selectedBayProvider.notifier).select(number);
        await tester.pumpAndSettle();
        final shown = find.byKey(const ValueKey('peso-celda'));
        expect(shown, findsNWidgets(voyage.bays[number]!.containers.length),
            reason: 'bahía $number');
        cells += shown.evaluate().length;
        expect(find.textContaining('N/A'), findsNothing);
        expect(tester.takeException(), isNull);
      }
      expect(cells, voyage.totalContainers);
      stdout.writeln('T-66 $name: $cells celdas con peso en ${numbers.length} bahías');
    });
  }
}
