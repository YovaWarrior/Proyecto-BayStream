import 'package:baystream/features/vessel/data/repositories/local_only_operation_sync.dart';
import 'package:baystream/core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/local_vessel_repository.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_overview_page.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/plan_toolbar_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/bay_plan_view.dart';
import 'package:baystream/features/vessel/presentation/widgets/loading_plan_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'local_profile_test_support.dart';
import 't74_movement_log_support.dart';

class _Voyage extends VoyageNotifier {
  final VesselVoyage voyage;
  _Voyage(this.voyage);
  @override
  AsyncValue<VesselVoyage?> build() => AsyncData(voyage);
}

class T91MemorySettings implements LocalVesselRepository {
  bool collapsed = true;
  @override
  Future<Either<Failure, bool>> getPlanToolbarCollapsed() async =>
      Right(collapsed);
  @override
  Future<Either<Failure, void>> setPlanToolbarCollapsed(bool value) async {
    collapsed = value;
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const t91ActionTooltips = [
  'Viajes recientes',
  'Perfiles guardados',
  'Nube y cuenta · Solo este dispositivo',
  'Buscar contenedor',
  'Exportar viaje',
  'Parámetros',
  'Cargar archivo BAPLIE',
  'Limpiar datos',
];

/// Pantalla completa del producto, sin nube ni almacén personal.
Future<ProviderContainer> pumpT91Plan(WidgetTester tester, VesselVoyage voyage,
    LocalVesselRepository local, Brightness brightness) async {
  final font = FontLoader('Roboto')
    ..addFont(rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
  await font.load();
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1200, 900);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final scope = ProviderContainer(overrides: [
    voyageNotifierProvider.overrideWith(() => _Voyage(voyage)),
    localVesselRepositoryProvider.overrideWith((ref) async => local),
    vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
    movementLogRepositoryProvider.overrideWith((ref) async => T74MemoryLog()),
    sessionRepositoryProvider
        .overrideWith((ref) async => const LocalSessionRepository()),
  ]);
  addTearDown(scope.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: scope,
    child: MaterialApp(
      theme: ThemeData(
          useMaterial3: true, brightness: brightness, fontFamily: 'Roboto'),
      home: const VesselOverviewPage(),
    ),
  ));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Bay Plan'));
  await tester.pumpAndSettle();
  await scope.read(planToolbarCollapsedProvider.future);
  await tester.pumpAndSettle();
  return scope;
}

Future<void> checkT91Toggle(WidgetTester tester, ProviderContainer scope,
    VesselVoyage voyage, BayPlanMode mode) async {
  // Se usa el control del producto para cambiar el modo.
  await tester.tap(find.byKey(const ValueKey('bay-plan-display-mode')));
  await tester.pumpAndSettle();
  final label = switch (mode) {
    BayPlanMode.content => 'Contenido',
    BayPlanMode.discharge => 'Descarga',
    BayPlanMode.loading => 'Carga',
    BayPlanMode.order => 'Número de orden',
  };
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
  final bays = voyage.bays.keys.toList()..sort();
  scope.read(selectedBayProvider.notifier).select(bays.last);
  await tester.pumpAndSettle();
  final plan = find.byType(BayPlanView);
  final planState = tester.state(plan);
  final before = scope.read(voyageNotifierProvider);
  final scrollables =
      find.descendant(of: plan, matching: find.byType(Scrollable));
  final positions = tester
      .stateList<ScrollableState>(scrollables)
      .map((s) => s.position)
      .toList();
  for (final position in positions) {
    if (position.maxScrollExtent > 0) {
      position.jumpTo(position.maxScrollExtent / 2);
    }
  }
  await tester.pumpAndSettle();
  final offsets = positions.map((p) => p.pixels).toList();
  for (var i = 0; i < 2; i++) {
    await tester.tap(find.byKey(const ValueKey('toggle-plan-toolbar')));
    await tester.pumpAndSettle();
    expect(tester.state(plan), same(planState));
    expect(scope.read(voyageNotifierProvider), same(before));
    expect(scope.read(selectedBayProvider), bays.last);
    expect(
        tester
            .widget<DropdownButton<BayPlanMode>>(
                find.byKey(const ValueKey('bay-plan-display-mode')))
            .value,
        mode);
    expect(positions.map((p) => p.pixels).toList(), offsets);
    expect(tester.takeException(), isNull);
  }
}
