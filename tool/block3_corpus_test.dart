import 'dart:io';

import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test/support/local_profile_test_support.dart';

void main() {
  test('PRUEBA_NIVEL_80 real conserva el descenso con ancla declarada 84',
      () async {
    const directory = String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');
    expect(directory, isNotEmpty);
    final source = await File('$directory/PRUEBA_NIVEL_80.edi').readAsBytes();
    final voyage = BaplieParserService().parse(String.fromCharCodes(source));
    const parameters = VesselGeometry(
        portRows: 0,
        starboardRows: 0,
        holdTiers: [],
        deckTiers: [],
        firstHoldTier: 4,
        firstDeckTier: 84);
    final profile = VesselProfile.proposeFrom(voyage, parameters: parameters);
    expect(voyage.stowagePositions.any((p) => p.tier == 80), isTrue);
    expect(profile.geometry.deckTiers, contains(80));
    expect(profile.geometry.holdTiers, isNot(contains(80)));
    expect(profile.geometry.coversAll(voyage.stowagePositions), isTrue);
    expect(profile.firstDeckTier, 84);
    stdout.writeln(
        'BLOQUE3_NIVEL80_OK: ancla 84; nivel 80 en cubierta; coversAll=true');
  });
  test(
      'T-26 a T-28 con CORPUS_A01 real y perfil persistido entre contenedores de providers',
      () async {
    const corpusDirectory =
        String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');
    expect(corpusDirectory, isNotEmpty);
    final content = String.fromCharCodes(
        await File('$corpusDirectory/CORPUS_A01.edi').readAsBytes());
    final parsed = BaplieParserService().parse(content);
    final store = await testProfileStore();
    ProviderContainer open() => ProviderContainer(overrides: [
          vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
          localVesselRepositoryProvider
              .overrideWith((ref) async => store.repository),
        ]);
    var container = open();
    try {
      var notifier = container.read(voyageNotifierProvider.notifier);
      expect(
          (await notifier.parseBaplieContent(content)).needsGeometry, isTrue);
      expect(notifier.pendingVoyage!.totalContainers, 977);
      final geometry = notifier.currentProfile!.geometry.copyWith(
          starboardRows: 7,
          firstHoldTier: 4,
          firstDeckTier: 84,
          deckTiers: [...notifier.currentProfile!.geometry.deckTiers, 92]);
      expect(await notifier.confirmGeometry(geometry), isNull);
      final originalProfile = notifier.currentProfile!;
      container.dispose();
      container = open();
      notifier = container.read(voyageNotifierProvider.notifier);
      final result = await notifier.parseBaplieContent(content);
      expect(result.needsGeometry, isFalse);
      expect(notifier.currentProfile, originalProfile);
      final restored = notifier.publishedVoyage!;
      expect(restored.containers.map((c) => c.toJson()..remove('id')),
          parsed.containers.map((c) => c.toJson()..remove('id')));
      expect(restored.totalContainers, 977);
      expect(restored.bays, hasLength(34));
      expect(restored.geometry, geometry);
      final shadows =
          restored.bays.values.where((b) => b.containers.isEmpty).toList();
      expect(shadows, hasLength(7));
      expect(shadows.every((b) => b.occupancyRate! > 0), isTrue);
      final raw = parsed.stowagePositions.first.rawCode;
      final outside = '${raw.substring(0, 3)}1996';
      final expandedContent =
          content.replaceFirst('LOC+147+$raw', 'LOC+147+$outside');
      expect(expandedContent, isNot(content));
      expect((await notifier.parseBaplieContent(expandedContent)).needsGeometry,
          isTrue);
      expect(notifier.outsideProfilePositions, contains(outside));
      notifier.discardPendingVoyage();
      expect(notifier.currentProfile, originalProfile);
      expect(notifier.publishedVoyage, restored);
      stdout.writeln(
          'BLOQUE3_CORPUS_OK: 977 contenedores; 34 bahías; 7 con vecinos; '
          'perfil recuperado sin preguntar; posición $outside bloqueada sin ampliar.');
    } finally {
      container.dispose();
      await store.repository.close();
      await store.directory.delete(recursive: true);
    }
  });
}
