import 'dart:convert';
import 'dart:io';

import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/data/services/pdf_report_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/bay_plan_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const corpus = String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');
  for (final name in ['A07', 'A08', 'A08v_VGM']) {
    testWidgets('T-102 $name: PDF y todas las pilas completas a 360 dp',
        (tester) async {
      expect(corpus, isNotEmpty);
      final parsed = BaplieParserService()
          .parse(File('$corpus/CORPUS_$name.edi').readAsStringSync());
      final voyage =
          parsed.withGeometry(VesselProfile.proposeFrom(parsed).geometry);
      expect(voyage.totalWeight, name == 'A07' ? 6940578 : 6899700);
      expect(voyage.totalContainers, name == 'A07' ? 398 : 405);
      expect(
          voyage.containers.where((c) => c.effectiveWeight == null), isEmpty);
      final font = FontLoader('Roboto')
        ..addFont(rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
      await font.load();
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final scope = ProviderContainer();
      addTearDown(scope.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
          container: scope,
          child: MaterialApp(
              theme: ThemeData(fontFamily: 'Roboto'),
              home: Scaffold(body: BayPlanView(voyage: voyage)))));
      final bays = voyage.bays.keys.toList()..sort();
      for (final bay in bays) {
        scope.read(selectedBayProvider.notifier).select(bay);
        await tester.pumpAndSettle();
        expect(find.textContaining('+?'), findsNothing, reason: 'Bahía $bay');
        expect(tester.takeException(), isNull, reason: 'Bahía $bay a 360 dp');
      }
      final bytes = await const PdfReportService()
          .generate(voyage, geometry: voyage.geometry!);
      late Directory out;
      await tester.runAsync(() async {
        out = await Directory.systemTemp.createTemp('t102-$name-');
        await File('${out.path}/$name.pdf').writeAsBytes(bytes);
        await File('${out.path}/manifest.json').writeAsString(jsonEncode({
          'name': name,
          'totalKg': voyage.totalWeight,
          'bays': [
            for (final bay in bays)
              {
                'bay': bay,
                'cells': [
                  for (final c in voyage.bays[bay]!.containers)
                    {
                      'position': c.stowagePosition!.toIsoCode(),
                      'tons': (c.effectiveWeight! / 1000).toStringAsFixed(1),
                    }
                ],
              }
          ],
        }));
      });
      stdout.writeln(
          'T-102 $name: ${voyage.totalContainers} celdas; ${voyage.totalWeight} kg; ${bays.length} bahías sin +? a 360 dp; PDF ${out.path}/$name.pdf');
    });
  }
}
