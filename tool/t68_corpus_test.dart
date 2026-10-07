import 'dart:io';

import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_geometry_page.dart';
import 'package:baystream/features/vessel/presentation/widgets/voyage_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Corpus externo: flutter test tool/t68_corpus_test.dart
/// --dart-define=BAYSTREAM_CORPUS_DIRECTORY=CARPETA_DEL_CORPUS
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    // La tipografía cuadrada Ahem del runner no representa la ficha del cliente.
    final font = FontLoader('Roboto')
      ..addFont(rootBundle.load('assets/fonts/Roboto-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Roboto-Medium.ttf'));
    await font.load();
  });
  const corpus = String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');
  VesselVoyage open(String name) {
    expect(corpus, isNotEmpty);
    return BaplieParserService()
        .parse(File('$corpus/CORPUS_$name.edi').readAsStringSync());
  }

  const cases = {
    'A07': (port: 'GTSTC', loaded: 0, discharged: 114, transit: 284),
    'A02': (port: 'GTSTC', loaded: 0, discharged: 303, transit: 503),
    'A08': (port: 'GTSTC', loaded: 121, discharged: 0, transit: 284),
    'A01': (port: 'GTPBR', loaded: 325, discharged: 0, transit: 652),
  };
  for (final entry in cases.entries) {
    testWidgets('T-68 ${entry.key}: cifras en diálogo y ficha a 360 dp',
        (tester) async {
      final expected = entry.value;
      final parsed = open(entry.key);
      final geometry = VesselProfile.proposeFrom(parsed).geometry;
      final voyage = parsed.withGeometry(geometry, portOfCall: expected.port);
      expect(voyage.cargoCountsFor(expected.port), (
        loaded: expected.loaded,
        discharged: expected.discharged,
        transit: expected.transit
      ));
      expect(voyage.containersInTransit, expected.transit);
      final split = '${expected.discharged} se descargan · '
          '${expected.loaded} se cargan · ${expected.transit} de paso';
      // T-69 conserva las cifras de cajas y muestra las reservas por separado.
      final reserved = parsed.reservedCountsFor(expected.port);
      final displayed = parsed.reservedSlots.isEmpty ? split :
          'Se cargan ${expected.loaded} contenedores y ${reserved.loaded} '
          'reservas (${expected.loaded + reserved.loaded} movimientos)';
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(
          theme: ThemeData(fontFamily: 'Roboto'),
          home: VesselGeometryPage(
              proposal: geometry,
              initial: geometry,
              voyage: parsed,
              declaredPort: parsed.portOfOrigin,
              loadingPorts: parsed.loadingPortCounts,
              initialPortOfCall: expected.port)));
      await tester.scrollUntilVisible(
          find.byKey(const ValueKey('port-split')), 300,
          scrollable: find.byType(Scrollable).first, maxScrolls: 30);
      expect(find.text(displayed), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(MaterialApp(
          theme: ThemeData(fontFamily: 'Roboto'),
          home: Scaffold(
              body: SingleChildScrollView(
                  child: VoyageSummaryCard(voyage: voyage)))));
      expect(find.text(displayed), findsOneWidget);
      expect(tester.takeException(), isNull);
      stdout.writeln('T-68 ${entry.key} ${expected.port}: $split');
    });
  }
  test('T-68 A04 y A06 tienen LOC+61 enmascarado', () {
    for (final file in ['A04', 'A06']) {
      expect(open(file).portOfNextCall, isNull);
    }
  });
  test('T-68 A08 seguido de A07 propone GTSTC', () {
    final previous = open('A08');
    expect(previous.portOfOrigin, 'GTSTC');
    expect(open('A07').suggestPortOfCall(previous.portOfOrigin), 'GTSTC');
  });
}
