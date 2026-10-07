import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_overview_page.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/empty_state_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/local_profile_test_support.dart';
import 'support/t74_movement_log_support.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';

void main() {
  // Reescrita en T-61: antes afirmaba que reabrir conservaba toda la geometría
  // guardada aunque el perfil hubiera cambiado. Ahora se conservan las
  // dimensiones y la carga, y los parámetros del buque salen del perfil vigente.
  test('publicar guarda y reabrir conserva dimensiones y aplica el perfil vigente sin parser ni nube', () async {
    final store = await testProfileStore();
    final first = ProviderContainer(overrides: [
      movementLogRepositoryProvider.overrideWith((ref) async => T74MemoryLog()),
      localVesselRepositoryProvider.overrideWith((ref) async => store.repository),
      vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
    ]);
    final notifier = first.read(voyageNotifierProvider.notifier);
    await notifier.parseBaplieContent(profileTestEdi);
    expect((await store.repository.getAllVoyages()).getOrElse(() => []), isEmpty);
    await notifier.confirmGeometry(notifier.currentProfile!.geometry, portOfCall: 'GTPBR', sourceKind: OperationSourceKind.loadingBaplie);
    final original = notifier.publishedVoyage!;
    final profile = notifier.currentProfile!;
    expect(original.vesselProfileKey, profile.key);
    first.dispose();
    // El perfil puede cambiar entre viajes: reabrir toma el límite vigente.
    await store.repository.saveProfile(profile.copyWith(stackWeightLimitKg: 75000));
    final offline = ProviderContainer(overrides: [
      movementLogRepositoryProvider.overrideWith((ref) async => T74MemoryLog()),
      localVesselRepositoryProvider.overrideWith((ref) async => store.repository),
      vesselRepositoryProvider.overrideWith((ref) => throw StateError('Sin archivo ni red')),
    ]);
    try {
      final reader = offline.read(voyageNotifierProvider.notifier);
      expect(await reader.openRecentVoyage(original.id), isNull);
      final reopened = reader.publishedVoyage!;
      expect(reopened.id, original.id);
      expect(reopened.containers, original.containers);
      expect(reopened.portOfCall, 'GTPBR');
      expect(reopened.geometry,
          original.geometry!.copyWith(stackWeightLimitKg: 75000));
      expect(reader.reopenKeptParameters, isEmpty);
      expect(reader.currentProfile!.key, profile.key);
      expect(reader.currentProfile!.geometry, reopened.geometry);
      expect(await reader.openRecentVoyage('no-existe'), isNotNull);
      expect(reader.publishedVoyage, reopened);
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
      movementLogRepositoryProvider.overrideWith((ref) async => T74MemoryLog()),
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
        for (var attempt = 0; attempt < 500; attempt++) {
          if (container.read(recentVoyagesProvider).value?.isEmpty == true) break;
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }
        expect(container.read(recentVoyagesProvider).value, isEmpty);
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

