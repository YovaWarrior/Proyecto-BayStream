import 'dart:io';

import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_impl.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/local_profile_test_support.dart';

void main() {
  late ProviderContainer container;
  late VoyageNotifier notifier;
  late ({Directory directory, LocalVesselRepositoryImpl repository}) store;
  setUp(() async {
    store = await testProfileStore();
    container = ProviderContainer(overrides: [
      vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
      localVesselRepositoryProvider
          .overrideWith((ref) async => store.repository),
    ]);
    notifier = container.read(voyageNotifierProvider.notifier);
  });
  tearDown(() async {
    container.dispose();
    await store.repository.close();
    await store.directory.delete(recursive: true);
  });

  test('primera carga propone; confirmar guarda; segunda carga dibuja directo',
      () async {
    final first = await notifier.parseBaplieContent(profileTestEdi);
    expect(first.needsGeometry, isTrue);
    expect(notifier.publishedVoyage, isNull);
    expect(
        notifier.currentProfile!.origin, VesselProfileOrigin.proposedFromFile);
    final geometry = notifier.currentProfile!.geometry;
    expect(
        await notifier.confirmGeometry(geometry, portOfCall: 'GTPBR'), isNull);
    final previousId = notifier.publishedVoyage!.id;
    expect(notifier.currentProfile!.origin, VesselProfileOrigin.declaredByUser);
    final second = await notifier.parseBaplieContent(profileTestEdi);
    expect(second.success, isTrue);
    expect(second.needsGeometry, isFalse);
    expect(second.needsIdentity, isFalse);
    expect(notifier.publishedVoyage!.geometry, geometry);
    expect(notifier.publishedVoyage!.id, isNot(previousId));
    expect(
        notifier.publishedVoyage!.bays.values
            .every((b) => b.geometry == geometry),
        isTrue);
    expect(notifier.publishedVoyage!.portOfCall, isNull,
        reason: 'el puerto es de la escala, no se hereda del perfil');
  });

  test('carga fuera del perfil queda pendiente y cancelar no ensancha ni borra',
      () async {
    await notifier.parseBaplieContent(profileTestEdi);
    await notifier.confirmGeometry(notifier.currentProfile!.geometry);
    final original = notifier.publishedVoyage;
    final profile = notifier.currentProfile;
    final result = await notifier
        .parseBaplieContent(profileTestEdi.replaceAll('0020182', '0020386'));
    expect(result.needsGeometry, isTrue);
    expect(notifier.outsideProfilePositions, ['0020386']);
    expect(notifier.publishedVoyage, original);
    expect(notifier.currentProfile, profile);
    expect(await notifier.confirmGeometry(profile!.geometry), isNotNull);
    notifier.discardPendingVoyage();
    expect(notifier.publishedVoyage, original);
    final stored = await store.repository.getAllProfiles();
    expect(stored.getOrElse(() => <VesselProfile>[]), [profile]);
  });

  test('ampliar requiere confirmar y recién entonces se persiste', () async {
    await notifier.parseBaplieContent(profileTestEdi);
    await notifier.confirmGeometry(notifier.currentProfile!.geometry);
    await notifier
        .parseBaplieContent(profileTestEdi.replaceAll('0020182', '0020386'));
    final proposal = VesselProfile.proposeFrom(notifier.pendingVoyage!,
        parameters: notifier.currentProfile!.geometry);
    expect(await notifier.confirmGeometry(proposal.geometry), isNull);
    expect(notifier.publishedVoyage!.geometry!.starboardRows, 2);
    expect(notifier.publishedVoyage!.geometry!.deckTiers, [82, 84, 86]);
    expect(
        (await notifier.parseBaplieContent(
                profileTestEdi.replaceAll('0020182', '0020386')))
            .needsGeometry,
        isFalse);
  });

  test('A05/A06 preguntan por identidad y no publican ni crean homónimo solos',
      () async {
    const a05 =
        "TDT+20++++NV4:172:ZZZ+++ZZC5603:103::BUQUE ECO:kingston JM++LINEA-A:LR'";
    const a06 = "TDT+20+VIAJE004A++9000039:146::BUQUE ECO++NV3:172:20'";
    await notifier.parseBaplieContent(a05);
    await notifier.confirmGeometry(notifier.currentProfile!.geometry);
    final original = notifier.publishedVoyage;
    final result = await notifier.parseBaplieContent(a06);
    expect(result.needsIdentity, isTrue);
    expect(notifier.publishedVoyage, original);
    expect(await notifier.confirmGeometry(notifier.currentProfile!.geometry),
        isNotNull);
    expect(notifier.resolveIdentity(null).needsGeometry, isTrue);
    await notifier.confirmGeometry(notifier.currentProfile!.geometry);
    expect(
        (await store.repository.getAllProfiles())
            .getOrElse(() => <VesselProfile>[]),
        hasLength(2));
  });

  test('elegir homónimo existente lo usa sin duplicar el perfil', () async {
    await notifier.parseBaplieContent(profileTestEdi);
    await notifier.confirmGeometry(notifier.currentProfile!.geometry);
    final saved = notifier.currentProfile!;
    final otherId = profileTestEdi.replaceAll('9000003:146', 'ZZALFA:103');
    expect((await notifier.parseBaplieContent(otherId)).needsIdentity, isTrue);
    expect(notifier.resolveIdentity(saved).needsGeometry, isFalse);
    expect(notifier.publishedVoyage!.vessel.callSign, 'ZZALFA');
    expect(notifier.currentProfile, saved);
    expect(
        (await store.repository.getAllProfiles())
            .getOrElse(() => <VesselProfile>[]),
        [saved]);
  });

  test(
      'fallo de escritura conserva pendiente y no publica una falsa confirmación',
      () async {
    await notifier.parseBaplieContent(profileTestEdi);
    final proposed = notifier.currentProfile!;
    await store.repository.close();
    expect(await notifier.confirmGeometry(proposed.geometry), isNotNull);
    expect(notifier.publishedVoyage, isNull);
    expect(notifier.pendingVoyage, isNotNull);
    expect(
        notifier.currentProfile!.origin, VesselProfileOrigin.proposedFromFile);
  });

  test('perfil con frontera y anclas distintas se usa sin recalcularlo',
      () async {
    final voyage = BaplieParserService().parse(profileTestEdi);
    final profile = VesselProfile.proposeFrom(voyage).copyWith(
        geometry: const VesselGeometry(
            portRows: 3,
            starboardRows: 3,
            holdTiers: [4, 82],
            deckTiers: [84, 88],
            deckTierFloor: 84,
            firstHoldTier: 4,
            firstDeckTier: 84),
        origin: VesselProfileOrigin.declaredByUser);
    await store.repository.saveProfile(profile);
    expect((await notifier.parseBaplieContent(profileTestEdi)).needsGeometry,
        isFalse);
    expect(notifier.publishedVoyage!.geometry, profile.geometry);
    expect(notifier.publishedVoyage!.bays[2]!.holdWeightByRow.keys, [1]);
    expect(notifier.publishedVoyage!.bays[2]!.deckWeightByRow, isEmpty);
  });

  test('homónimos sin identificador no se sobrescriben como otro buque',
      () async {
    final nameOnly = profileTestEdi.replaceAll('9000003:146:11:', ':::');
    await notifier.parseBaplieContent(nameOnly);
    await notifier.confirmGeometry(notifier.currentProfile!.geometry);
    expect((await notifier.parseBaplieContent(nameOnly)).needsIdentity, isTrue);
    expect(notifier.resolveIdentity(null).success, isFalse);
    expect(notifier.pendingVoyage, isNotNull);
  });
}
