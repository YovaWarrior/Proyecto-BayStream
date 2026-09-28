import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/data/datasources/hive_vessel_data_source.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_impl.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_overview_page.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/local_profile_test_support.dart';

void main() {
  testWidgets('T-34 editar sin viaje, cancelar y guardar; recupera después de reabrir Hive', (tester) async {
    await tester.runAsync(() async {
    final store = await testProfileStore();
    // Namespace conocido para cerrar y reabrir exactamente las mismas cajas.
    await store.repository.close();
    var local = LocalVesselRepositoryImpl(await HiveVesselDataSource.open(directory: store.directory.path, namespace: 'editor'));
    var scope = ProviderContainer(overrides: [localVesselRepositoryProvider.overrideWith((ref) async => local)]);
    final original = VesselProfile.proposeFrom(BaplieParserService().parse(profileTestEdi))
      .copyWith(stackWeightLimitKg: 62500.5, reeferSlots: {'0020182'}, origin: VesselProfileOrigin.declaredByUser);
    await local.saveProfile(original);
    tester.view.physicalSize = const Size(1000, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    try {
      await tester.pumpWidget(UncontrolledProviderScope(container: scope, child: const MaterialApp(home: VesselOverviewPage())));
      await tester.tap(find.byKey(const ValueKey('saved-profiles')));
      await tester.pumpAndSettle();
      Future<void> edit() async {
        await tester.tap(find.byKey(ValueKey('edit-profile-${original.key}')));
        await tester.pumpAndSettle();
      }
      await edit();
      expect(find.text('Perfil sin cambios.'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('geometry-confirm')));
      await tester.pumpAndSettle();
      expect((await local.getAllProfiles()).getOrElse(() => []).single, original);
      await edit();
      await tester.enterText(find.byKey(const ValueKey('geometry-port-rows')), '4');
      await tester.tap(find.byKey(const ValueKey('geometry-cancel')));
      await tester.pumpAndSettle();
      expect((await local.getAllProfiles()).getOrElse(() => []).single, original);
      await edit();
      await tester.tap(find.byKey(const ValueKey('geometry-anchors')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('geometry-floor')), '78');
      await tester.enterText(find.byKey(const ValueKey('geometry-first-hold')), '4');
      await tester.enterText(find.byKey(const ValueKey('geometry-first-deck')), '80');
      await tester.tap(find.byKey(const ValueKey('profile-sockets')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('socket-input')), '0040182');
      await tester.tap(find.byKey(const ValueKey('socket-add')));
      await tester.tap(find.byKey(const ValueKey('sockets-declare')));
      await tester.tap(find.byKey(const ValueKey('geometry-no-limit')));
      await tester.ensureVisible(find.byKey(const ValueKey('geometry-confirm')));
      await tester.tap(find.byKey(const ValueKey('geometry-confirm')));
      await tester.pumpAndSettle();
      expect(scope.read(voyageNotifierProvider.notifier).publishedVoyage, isNull);
      await tester.pumpWidget(const SizedBox());
      scope.dispose();
      await local.close();
      local = LocalVesselRepositoryImpl(await HiveVesselDataSource.open(directory: store.directory.path, namespace: 'editor'));
      scope = ProviderContainer();
      final restored = (await local.getAllProfiles()).getOrElse(() => []).single;
      expect(restored.deckTierFloor, 78);
      expect(restored.firstHoldTier, 4);
      expect(restored.firstDeckTier, 80);
      expect(restored.stackWeightLimitKg, isNull);
      expect(restored.reeferSlots, {'0020182', '0040182'});
      expect(restored.reeferSlotsOrigin, VesselProfileOrigin.declaredByUser);
    } finally {
      scope.dispose();
      await local.close();
      await store.directory.delete(recursive: true);
    }
    });
  });

  test('T-34 guardar un perfil rechaza otra identidad o perder carga del viaje visible', () async {
    final store = await testProfileStore();
    final scope = ProviderContainer(overrides: [
      localVesselRepositoryProvider.overrideWith((ref) async => store.repository),
      vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
    ]);
    try {
      final notifier = scope.read(voyageNotifierProvider.notifier);
      await notifier.parseBaplieContent(profileTestEdi);
      await notifier.confirmGeometry(notifier.currentProfile!.geometry);
      final saved = notifier.currentProfile!;
      expect(await notifier.saveEditedProfile(saved, saved.copyWith(vesselName: 'OTRO')), isNotNull);
      expect(await notifier.saveEditedProfile(saved, saved.copyWith(geometry: saved.geometry.copyWith(deckTiers: []))), isNotNull);
      expect(notifier.publishedVoyage!.geometry, saved.geometry);
      final edited = saved.copyWith(stackWeightLimitKg: 80000, reeferSlots: {'0020182'}, updatedAt: DateTime.now());
      expect(await notifier.saveEditedProfile(saved, edited), isNull);
      expect(notifier.publishedVoyage!.geometry!.stackWeightLimitKg, 80000);
      expect(await notifier.saveEditedProfile(saved, saved.copyWith(stackWeightLimitKg: 50000)), isNotNull);
      expect(notifier.currentProfile, edited);
    } finally {
      scope.dispose();
      await store.repository.close();
      await store.directory.delete(recursive: true);
    }
  });
}
