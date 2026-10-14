import 'dart:io';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../test/t97_text_test.dart' show checkT97Plan;

void main() {
  const corpus = String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');
  for (final brightness in Brightness.values) {
    testWidgets('T-97 A07 a 360 dp, escala 2.0, ${brightness.name}',
        (tester) async {
      final parsed = await tester.runAsync(() async => BaplieParserService()
          .parse(await File('$corpus/CORPUS_A07.edi').readAsString()));
      final voyage = parsed!.withGeometry(
          VesselProfile.proposeFrom(parsed).geometry,
          portOfCall: 'GTSTC');
      expect(voyage.totalContainers, 398);
      expect(voyage.bays.length, 21);
      expect(voyage.totalWeight, 6940578);
      expect(
          voyage.containers.where((c) => c.portOfDischarge == 'GTSTC').length,
          114);
      await checkT97Plan(tester, voyage, brightness);
    });
  }
}
