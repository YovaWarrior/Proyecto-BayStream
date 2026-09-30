import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/entities/stowage_validation_result.dart';
import 'package:baystream/features/vessel/presentation/pages/stowage_alerts_page.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_overview_page.dart';
import 'package:baystream/features/vessel/presentation/providers/segregation_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/stack_weight_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/stowage_validation_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/bay_plan_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

StowageValidationResult result(StowageRule rule, ValidationStatus status,
        ValidationSeverity severity, String reason,
        {List<String> positions = const ['0010182']}) =>
    StowageValidationResult(
        rule: rule,
        status: status,
        severity: severity,
        description: reason,
        positions: positions.map(IsoCoordinateParser.parse),
        containerIds: const ['TEST0000001'],
        references: const ['Fuente explícita']);

void main() {
  final error = result(StowageRule.reeferSocket, ValidationStatus.nonConforming,
      ValidationSeverity.error, 'Inventario declarado: falta toma');
  final unknown = result(
      StowageRule.dangerousGoodsSegregation,
      ValidationStatus.notEvaluated,
      ValidationSeverity.warning,
      'ONU fuera de matriz: no evaluado');
  final conforming = result(
      StowageRule.dangerousGoodsSegregation,
      ValidationStatus.conforming,
      ValidationSeverity.information,
      'Regla evaluada conforme');

  test('T-42 reúne cuatro validadores y ordena error, aviso, información', () {
    final stack = result(
        StowageRule.twentyOverForty,
        ValidationStatus.nonConforming,
        ValidationSeverity.error,
        'Apilamiento');
    final weight = result(StowageRule.stackWeight,
        ValidationStatus.nonConforming, ValidationSeverity.error, 'Peso');
    final scope = ProviderContainer(overrides: [
      stackWeightResultsProvider.overrideWithValue([weight]),
      reeferSocketResultsProvider.overrideWithValue([error]),
      containerStackingResultsProvider.overrideWithValue([stack]),
      segregationResultsProvider.overrideWithValue([conforming, unknown]),
    ]);
    addTearDown(scope.dispose);
    final all = scope.read(stowageValidationResultsProvider);
    expect(all, [weight, error, stack, unknown, conforming]);
    scope.read(selectedCarrierProvider.notifier).select('SIN_CARGA');
    scope
        .read(selectedTypeFilterProvider.notifier)
        .toggle(LegendFilterType.reefer);
    expect(scope.read(stowageValidationResultsProvider), all);
    expect(() => all.clear(), throwsUnsupportedError);
  });
  test('T-42 desempate sitúa incumplimiento antes de no evaluado', () {
    final lower = result(
        StowageRule.reeferSocket,
        ValidationStatus.nonConforming,
        ValidationSeverity.warning,
        'Advertencia comprobada');
    expect(compareValidationResults(lower, unknown), lessThan(0));
    expect(compareValidationResults(unknown, lower), greaterThan(0));
  });
  testWidgets('T-42 motivo no evaluado visible y contadores separados en móvil',
      (tester) async {
    tester.view.physicalSize = const Size(360, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ProviderScope(overrides: [
      stowageValidationResultsProvider.overrideWithValue([unknown]),
    ], child: const MaterialApp(home: StowageAlertsPage())));
    expect(
        find.textContaining(
            '0 posibles incumplimientos · 1 no evaluados · 0 conformes'),
        findsOneWidget);
    expect(find.text('Aviso · No evaluado'), findsOneWidget);
    expect(find.text(unknown.description), findsOneWidget);
    expect(find.textContaining('No es el Código IMDG'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('T-42 vacío no certifica conformidad', (tester) async {
    await tester.pumpWidget(ProviderScope(overrides: [
      stowageValidationResultsProvider.overrideWithValue([]),
    ], child: const MaterialApp(home: StowageAlertsPage())));
    expect(find.textContaining('Esto no declara el viaje conforme'),
        findsOneWidget);
  });
  testWidgets('T-42 sin posición explica por qué no puede navegar',
      (tester) async {
    await tester.pumpWidget(ProviderScope(overrides: [
      stowageValidationResultsProvider.overrideWithValue([
        result(StowageRule.reeferSocket, ValidationStatus.notEvaluated,
            ValidationSeverity.warning, 'Posición ausente',
            positions: []),
      ]),
    ], child: const MaterialApp(home: StowageAlertsPage())));
    expect(find.textContaining('Posición no disponible:'), findsOneWidget);
    expect(find.byIcon(Icons.location_on_outlined), findsNothing);
  });
  testWidgets('T-42 segunda posición abre bahía, limpia filtros y revela celda',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(650, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final pos = IsoCoordinateParser.parse('0031902');
    final c = ContainerUnit(
        id: 'internal',
        containerId: 'TARGET',
        isoSizeType: '22G1',
        stowagePosition: pos);
    final voyage = VesselVoyage(
            id: 't',
            vessel: const Vessel(id: 'v', name: 'PRUEBA'),
            voyageNumber: 'V1',
            containers: [c],
            bays: {3: const Bay(bayNumber: 3).addContainer(c)})
        .withGeometry(const VesselGeometry(
            portRows: 10,
            starboardRows: 10,
            holdTiers: [2, 4, 6, 8, 10],
            deckTiers: [82, 84, 86, 88, 90]));
    final scope = ProviderContainer(overrides: [
      voyageNotifierProvider.overrideWith(() => _Voyage(voyage)),
      stowageValidationResultsProvider.overrideWithValue([
        result(StowageRule.twentyOverForty, ValidationStatus.nonConforming,
            ValidationSeverity.error, 'Dos posiciones',
            positions: ['0021982', '0031902']),
      ]),
    ]);
    addTearDown(scope.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: scope,
        child: const MaterialApp(home: VesselOverviewPage())));
    final button = find.text('Alertas de estiba');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    scope.read(selectedCarrierProvider.notifier).select('OTRA');
    scope
        .read(selectedTypeFilterProvider.notifier)
        .toggle(LegendFilterType.reefer);
    await tester.ensureVisible(find.text('Ver 0031902'));
    await tester.tap(find.text('Ver 0031902'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(scope.read(selectedBayProvider), 3);
    expect(scope.read(highlightedContainerProvider), 'TARGET');
    expect(scope.read(selectedCarrierProvider), isNull);
    expect(scope.read(selectedTypeFilterProvider), isNull);
    expect(find.byType(BayPlanView), findsOneWidget);
    expect(
        find.byKey(const ValueKey('cell-19-2')).hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _Voyage extends VoyageNotifier {
  final VesselVoyage voyage;
  _Voyage(this.voyage);
  @override
  AsyncValue<VesselVoyage?> build() => AsyncValue.data(voyage);
}
