import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/current_profile_parameters.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_overview_page.dart';
import 'package:baystream/features/vessel/presentation/providers/stack_weight_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/local_profile_test_support.dart';

/// Un 40 pies de 30 000 kg en cubierta (fila 02) y otro en la fila 00 de bodega.
const _ediWithCenterRowCargo =
    "TDT+20+V01N+++NV2:172:20+++9000003:146:11:BUQUE ALFA'"
    "LOC+147+0020182:::5'MEA+WT++KGM:30000'EQD+CN+TEST0000001+42G1+++5'"
    "LOC+147+0020002:::5'MEA+WT++KGM:30000'EQD+CN+TEST0000002+42G1+++5'";

void main() {
  group('T-61 · parámetros del perfil vigente al reabrir', () {
    const voyageGeometry = VesselGeometry(
        portRows: 2,
        starboardRows: 2,
        holdTiers: [2, 4],
        deckTiers: [82, 84],
        stackWeightLimitKg: 62500.5);
    const profileGeometry = VesselGeometry(
        portRows: 6,
        starboardRows: 6,
        holdTiers: [2, 4, 6, 8],
        deckTiers: [82, 84, 86],
        centerRowOnDeck: false,
        centerRowInHold: false,
        firstHoldTier: 4,
        firstDeckTier: 84);
    final cargo = [
      IsoCoordinateParser.parse('0020182'),
      IsoCoordinateParser.parse('0010104'),
    ];

    test('toma los seis parámetros del perfil y conserva las dimensiones', () {
      final result = applyCurrentProfileParameters(
          voyageGeometry: voyageGeometry,
          profileGeometry: profileGeometry,
          positions: cargo);
      final g = result.geometry;
      expect(result.keptFromVoyage, isEmpty);
      expect([g.portRows, g.starboardRows, g.holdTiers, g.deckTiers],
          [2, 2, [2, 4], [82, 84]]);
      expect(g.centerRowOnDeck, isFalse);
      expect(g.centerRowInHold, isFalse);
      expect(g.firstHoldTier, 4);
      expect(g.firstDeckTier, 84);
      expect(g.deckTierFloor, 80);
      expect(g.stackWeightLimitKg, isNull,
          reason: '«No lo tengo» en el perfil quita el límite del viaje');
      expect(g.coversAll(cargo), isTrue);
    });

    test('un límite declarado en el perfil reemplaza el guardado', () {
      final result = applyCurrentProfileParameters(
          voyageGeometry: voyageGeometry,
          profileGeometry: profileGeometry.copyWith(stackWeightLimitKg: 75000),
          positions: cargo);
      expect(result.geometry.stackWeightLimitKg, 75000);
    });

    test('la fila 00 declarada inexistente no oculta carga en la 00', () {
      final withCenter = [...cargo, IsoCoordinateParser.parse('0020002')];
      final stored = voyageGeometry.copyWith(centerRowInHold: true);
      final result = applyCurrentProfileParameters(
          voyageGeometry: stored,
          profileGeometry: profileGeometry,
          positions: withCenter);
      expect(result.keptFromVoyage, [VesselParameter.centerRowInHold]);
      expect(result.geometry.centerRowInHold, isTrue);
      expect(result.geometry.coversAll(withCenter), isTrue);
      // El resto sí se aplica.
      expect(result.geometry.centerRowOnDeck, isFalse);
      expect(result.geometry.stackWeightLimitKg, isNull);
    });

    test('una frontera que cambia de zona un nivel con carga se conserva', () {
      final result = applyCurrentProfileParameters(
          voyageGeometry: voyageGeometry,
          profileGeometry: profileGeometry.copyWith(deckTierFloor: 84),
          positions: cargo);
      expect(result.keptFromVoyage, [VesselParameter.deckTierFloor]);
      expect(result.geometry.deckTierFloor, 80);
      expect(result.geometry.coversAll(cargo), isTrue);
    });

    test('sin diferencias devuelve la misma geometría', () {
      final result = applyCurrentProfileParameters(
          voyageGeometry: voyageGeometry,
          profileGeometry: voyageGeometry.copyWith(portRows: 9),
          positions: cargo);
      expect(result.geometry, voyageGeometry);
      expect(result.keptFromVoyage, isEmpty);
    });
  });

  group('T-61 · reabrir desde Recientes', () {
    test('sin perfil guardado el viaje se reabre intacto', () async {
      final store = await testProfileStore();
      final parsed = BaplieParserService().parse(profileTestEdi);
      final stored = parsed.withGeometry(
          VesselProfile.proposeFrom(parsed)
              .geometry
              .copyWith(stackWeightLimitKg: 62500.5));
      await store.repository.saveVoyage(stored);
      final scope = ProviderContainer(overrides: [
        localVesselRepositoryProvider
            .overrideWith((ref) async => store.repository),
      ]);
      try {
        final notifier = scope.read(voyageNotifierProvider.notifier);
        expect(await notifier.openRecentVoyage(stored.id), isNull);
        expect(notifier.publishedVoyage, stored);
        expect(notifier.currentProfile!.geometry, stored.geometry);
        expect(notifier.reopenKeptParameters, isEmpty);
      } finally {
        scope.dispose();
        await store.repository.close();
        await store.directory.delete(recursive: true);
      }
    });

    test('el panel se recalcula al reabrir tras editar solo el perfil',
        () async {
      final store = await testProfileStore();
      final first = ProviderContainer(overrides: [
        localVesselRepositoryProvider
            .overrideWith((ref) async => store.repository),
        vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
      ]);
      final notifier = first.read(voyageNotifierProvider.notifier);
      await notifier.parseBaplieContent(_ediWithCenterRowCargo);
      await notifier.confirmGeometry(
          notifier.currentProfile!.geometry.withoutStackWeightLimit());
      final voyage = notifier.publishedVoyage!;
      final profile = notifier.currentProfile!;
      expect(voyage.geometry!.centerRowInHold, isTrue,
          reason: 'la propuesta registra la 00 ocupada');
      final subscription =
          first.listen(stackWeightResultsProvider, (previous, next) {});
      try {
        expect(first.read(stackWeightResultsProvider), isEmpty);
        // Edición desde «Perfiles guardados» con el viaje cerrado: límite de
        // 20 000 kg y fila 00 de bodega declarada inexistente.
        notifier.clearVoyage();
        await store.repository.saveProfile(profile.copyWith(
            stackWeightLimitKg: 20000,
            geometry: profile.geometry.copyWith(
                stackWeightLimitKg: 20000, centerRowInHold: false)));
        expect(await notifier.openRecentVoyage(voyage.id), isNull);
        expect(first.read(stackWeightResultsProvider), hasLength(2),
            reason: 'dos pilas de 30 000 kg superan 20 000 kg');
        expect(notifier.reopenKeptParameters,
            [VesselParameter.centerRowInHold]);
        final reopened = notifier.publishedVoyage!;
        expect(reopened.geometry!.centerRowInHold, isTrue);
        expect(reopened.geometry!.coversAll(reopened.stowagePositions), isTrue);
        // Volver a «No lo tengo» y reabrir: el panel vuelve a cero.
        await store.repository.saveProfile(profile.copyWith(
            stackWeightLimitKg: null,
            geometry: profile.geometry.withoutStackWeightLimit()));
        expect(await notifier.openRecentVoyage(voyage.id), isNull);
        expect(first.read(stackWeightResultsProvider), isEmpty);
        expect(notifier.reopenKeptParameters, isEmpty);
      } finally {
        subscription.close();
        first.dispose();
        await store.repository.close();
        await store.directory.delete(recursive: true);
      }
    });

    testWidgets('Recientes dice qué parámetro del perfil no se aplicó',
        (tester) async {
      await tester.runAsync(() async {
        final store = await testProfileStore();
        final parsed = BaplieParserService().parse(_ediWithCenterRowCargo);
        final proposal = VesselProfile.proposeFrom(parsed);
        final voyage = parsed
            .withGeometry(proposal.geometry)
            .copyWith(vesselProfileKey: proposal.key);
        await store.repository.saveVoyage(voyage);
        await store.repository.saveProfile(proposal.copyWith(
            geometry: proposal.geometry.copyWith(centerRowInHold: false)));
        final container = ProviderContainer(overrides: [
          localVesselRepositoryProvider
              .overrideWith((ref) async => store.repository),
          vesselRepositoryProvider.overrideWith(
              (ref) => throw StateError('Reabrir no lee archivos')),
        ]);
        try {
          await tester.pumpWidget(UncontrolledProviderScope(
              container: container,
              child: const MaterialApp(home: VesselOverviewPage())));
          await tester.tap(find.byKey(const ValueKey('recent-voyages')));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(ValueKey('recent-${voyage.id}')));
          await tester.pumpAndSettle();
          expect(find.byKey(const ValueKey('reopen-kept-parameters')),
              findsOneWidget);
          expect(find.textContaining('fila 00 en bodega'), findsOneWidget);
          expect(container.read(voyageNotifierProvider).value!.containers,
              hasLength(2));
          await tester.pump(const Duration(seconds: 11));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        } finally {
          await tester.pumpWidget(const SizedBox.shrink());
          container.dispose();
          await store.repository.close();
          await store.directory.delete(recursive: true);
        }
      });
    });
  });
}
