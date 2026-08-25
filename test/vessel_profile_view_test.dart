import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_overview_page.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/bay_plan_view.dart';
import 'package:baystream/features/vessel/presentation/widgets/vessel_profile_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('al tocar una bahía informa su número', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    int? selectedBay;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VesselProfileView(
            voyage: _createVoyage(3),
            onBaySelected: (bayNumber) => selectedBay = bayNumber,
          ),
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey('vessel-profile-bay-3')),
    );

    expect(selectedBay, 3);
  });

  testWidgets(
    'permite desplazamiento horizontal y se adapta al redimensionar',
    (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final voyage = _createVoyage(20);

      await tester.binding.setSurfaceSize(const Size(360, 700));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VesselProfileView(
              voyage: voyage,
              onBaySelected: (_) {},
            ),
          ),
        ),
      );

      var scrollView = tester.widget<SingleChildScrollView>(
        find.byKey(const ValueKey('vessel-profile-scroll')),
      );
      expect(scrollView.controller!.position.maxScrollExtent, greaterThan(0));
      expect(tester.takeException(), isNull);

      await tester.binding.setSurfaceSize(const Size(800, 700));
      await tester.pumpAndSettle();
      scrollView = tester.widget<SingleChildScrollView>(
        find.byKey(const ValueKey('vessel-profile-scroll')),
      );
      expect(scrollView.controller!.position.maxScrollExtent, greaterThan(0));

      await tester.drag(
        find.byKey(const ValueKey('vessel-profile-scroll')),
        const Offset(-400, 0),
      );
      await tester.pumpAndSettle();
      expect(scrollView.controller!.offset, greaterThan(0));
      expect(tester.takeException(), isNull);

      await tester.binding.setSurfaceSize(const Size(1440, 900));
      await tester.pumpAndSettle();
      scrollView = tester.widget<SingleChildScrollView>(
        find.byKey(const ValueKey('vessel-profile-scroll')),
      );
      expect(scrollView.controller!.position.maxScrollExtent, 0);
      expect(scrollView.controller!.offset, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('selecciona la bahía y abre su rejilla en Bay Plan',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final voyage = _createVoyage(3);
    final container = ProviderContainer(
      overrides: [
        voyageNotifierProvider.overrideWith(
          () => _TestVoyageNotifier(voyage),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: VesselOverviewPage()),
      ),
    );

    await tester.tap(find.text('Estadísticas'));
    await tester.pumpAndSettle();
    final bayTarget = find.byKey(const ValueKey('vessel-profile-bay-3'));
    await tester.ensureVisible(bayTarget);
    await tester.pumpAndSettle();
    await tester.tap(bayTarget);
    await tester.pumpAndSettle();

    expect(container.read(selectedBayProvider), 3);
    expect(find.byType(BayPlanView), findsOneWidget);

    final selectedBayChip = find.ancestor(
      of: find.text('BAY 03 (0%)'),
      matching: find.byType(FilterChip),
    );
    expect(selectedBayChip, findsOneWidget);
    expect(tester.widget<FilterChip>(selectedBayChip).selected, isTrue);

    await tester.tap(find.text('BAY 05 (0%)'));
    await tester.pumpAndSettle();
    expect(container.read(selectedBayProvider), 5);

    await tester.tap(find.text('Estadísticas'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(bayTarget);
    await tester.pumpAndSettle();
    await tester.tap(bayTarget);
    await tester.pumpAndSettle();

    final reopenedBayChip = find.ancestor(
      of: find.text('BAY 03 (0%)'),
      matching: find.byType(FilterChip),
    );
    expect(container.read(selectedBayProvider), 3);
    expect(tester.widget<FilterChip>(reopenedBayChip).selected, isTrue);
  });
}

VesselVoyage _createVoyage(int bayCount) {
  final bays = <int, Bay>{
    for (var index = 0; index < bayCount; index++)
      index * 2 + 1: Bay(bayNumber: index * 2 + 1),
  };

  return VesselVoyage(
    id: 'viaje-prueba',
    vessel: const Vessel(id: 'buque-prueba', name: 'Buque Prueba'),
    voyageNumber: 'V001',
    bays: bays,
  );
}

class _TestVoyageNotifier extends VoyageNotifier {
  final VesselVoyage voyage;

  _TestVoyageNotifier(this.voyage);

  @override
  AsyncValue<VesselVoyage?> build() => AsyncValue.data(voyage);
}
