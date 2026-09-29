import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_overview_page.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/empty_state_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/local_profile_test_support.dart';

void main() {
  test('publicar guarda y reabrir conserva geometría histórica sin parser ni nube', () async {
    final store = await testProfileStore();
    final first = ProviderContainer(overrides: [
      localVesselRepositoryProvider.overrideWith((ref) async => store.repository),
      vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
    ]);
    final notifier = first.read(voyageNotifierProvider.notifier);
    await notifier.parseBaplieContent(profileTestEdi);
    expect((await store.repository.getAllVoyages()).getOrElse(() => []), isEmpty);
    await notifier.confirmGeometry(notifier.currentProfile!.geometry, portOfCall: 'GTPBR');
    final original = notifier.publishedVoyage!;
    final profile = notifier.currentProfile!;
    expect(original.vesselProfileKey, profile.key);
    first.dispose();
    // El perfil puede cambiar entre viajes: reabrir conserva la instantánea.
    await store.repository.saveProfile(profile.copyWith(stackWeightLimitKg: 75000));
    final offline = ProviderContainer(overrides: [
      localVesselRepositoryProvider.overrideWith((ref) async => store.repository),
      vesselRepositoryProvider.overrideWith((ref) => throw StateError('Sin archivo ni red')),
    ]);
    try {
      final reader = offline.read(voyageNotifierProvider.notifier);
      expect(await reader.openRecentVoyage(original.id), isNull);
      expect(reader.publishedVoyage, original);
      expect(reader.publishedVoyage!.portOfCall, 'GTPBR');
      expect(reader.currentProfile!.key, profile.key);
      expect(reader.currentProfile!.geometry, original.geometry);
      expect(await reader.openRecentVoyage('no-existe'), isNotNull);
      expect(reader.publishedVoyage, original);
      expect(await reader.deleteRecentVoyage(original.id), isNull);
      expect((await store.repository.getAllVoyages()).getOrElse(() => []), isEmpty);
      expect((await store.repository.getAllProfiles()).getOrElse(() => []).single.key, profile.key);
    } finally {
      offline.dispose();
      await store.repository.close();
      await store.directory.delete(recursive: true);
    }
  });

  testWidgets('recientes abre, confirma borrado y reutiliza el estado vacío', (tester) async {
    await tester.runAsync(() async {
      final store = await testProfileStore();
      final parsed = BaplieParserService().parse(profileTestEdi);
      final profile = VesselProfile.proposeFrom(parsed);
      final voyage = parsed.withGeometry(profile.geometry).copyWith(vesselProfileKey: profile.key);
      await store.repository.saveProfile(profile);
      await store.repository.saveVoyage(voyage);
      final container = ProviderContainer(overrides: [
        localVesselRepositoryProvider.overrideWith((ref) async => store.repository),
        vesselRepositoryProvider.overrideWith((ref) => throw StateError('El listado no lee archivos')),
      ]);
      try {
        await tester.pumpWidget(UncontrolledProviderScope(container: container,
            child: const MaterialApp(home: VesselOverviewPage())));
        await tester.tap(find.byKey(const ValueKey('recent-voyages')));
        await tester.pumpAndSettle();
        expect(find.textContaining('últimos 5 viajes'), findsOneWidget);
        await tester.tap(find.byKey(ValueKey('recent-${voyage.id}')));
        await tester.pumpAndSettle();
        expect(container.read(voyageNotifierProvider).value, voyage);
        await tester.tap(find.byKey(const ValueKey('recent-voyages')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(ValueKey('delete-${voyage.id}')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();
        expect(find.byKey(ValueKey('recent-${voyage.id}')), findsOneWidget);
        await tester.tap(find.byKey(ValueKey('delete-${voyage.id}')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Eliminar'));
        // Deja que el flush real del archivo termine fuera del reloj de widgets.
        for (var attempt = 0; attempt < 100; attempt++) {
          if ((await store.repository.getAllVoyages()).getOrElse(() => []).isEmpty) break;
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }
        await Future<void>.delayed(const Duration(milliseconds: 20));
        await tester.pumpAndSettle();
        expect(find.byType(EmptyStateWidget), findsOneWidget);
        expect((await store.repository.getAllProfiles()).getOrElse(() => []), [profile]);
        expect(tester.takeException(), isNull);
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        container.dispose();
        await store.repository.close();
        await store.directory.delete(recursive: true);
      }
    });
  });
}
