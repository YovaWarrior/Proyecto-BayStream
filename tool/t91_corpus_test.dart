import 'dart:io';

import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/widgets/loading_plan_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test/support/t91_toolbar_support.dart';

void main() {
  const corpus = String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');
  for (final brightness in Brightness.values) {
    testWidgets(
        'T-91 A07 barra plegada a 360 dp y vista conservada, ${brightness.name}',
        (tester) async {
      expect(corpus, isNotEmpty);
      final parsed = BaplieParserService()
          .parse(File('$corpus/CORPUS_A07.edi').readAsStringSync());
      final voyage = parsed.withGeometry(
          VesselProfile.proposeFrom(parsed).geometry,
          portOfCall: 'GTSTC');
      expect(voyage.totalContainers, 398);
      expect(voyage.totalWeight, 6940578);
      expect(voyage.bays.length, 21);
      expect(voyage.cargoCountsFor('GTSTC'),
          (loaded: 0, discharged: 114, transit: 284));
      final scope =
          await pumpT91Plan(tester, voyage, T91MemorySettings(), brightness);
      tester.view.physicalSize = const Size(360, 800);
      await tester.pumpAndSettle();
      expect(tester.widget<AppBar>(find.byType(AppBar)).actions, hasLength(1));
      expect(tester.takeException(), isNull);
      tester.view.physicalSize = const Size(1200, 900);
      await tester.pumpAndSettle();
      for (final mode in BayPlanMode.values) {
        await checkT91Toggle(tester, scope, voyage, mode);
      }
    });
  }
}
