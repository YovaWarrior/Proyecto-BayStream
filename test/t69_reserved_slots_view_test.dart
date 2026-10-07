import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/bay_plan_view.dart';
import 'package:baystream/features/vessel/presentation/widgets/reserved_slots_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _geometry = VesselGeometry(
    portRows: 1, starboardRows: 1, holdTiers: [2], deckTiers: [82, 84]);

ReservedSlot _slot(String position, {String type = '22G1'}) => ReservedSlot(
    stowagePosition: IsoCoordinateParser.parse(position),
    isoSizeType: type,
    status: ContainerStatus.empty,
    portOfLoading: 'GTSTC',
    portOfDischarge: 'PAMIT',
    operatorCode: 'LNC',
    nominalWeight: type == '22G1' ? 2100 : 3800);

VesselVoyage _voyage(List<ReservedSlot> slots,
    {List<ContainerUnit> containers = const []}) {
  final bays = <int, Bay>{};
  for (final container in containers) {
    final number = container.stowagePosition!.bay;
    bays[number] =
        (bays[number] ?? Bay(bayNumber: number, is40FtBay: number.isEven))
            .addContainer(container);
  }
  return VesselVoyage(
          id: 't69-vista-viaje',
          vessel: const Vessel(id: 't69-vista-buque', name: 'Buque sintético'),
          voyageNumber: 'T69',
          containers: containers,
          bays: bays,
          reservedSlots: slots)
      .withGeometry(_geometry, portOfCall: 'GTSTC');
}

void _at360(WidgetTester tester) {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _pumpPlan(WidgetTester tester, VesselVoyage voyage,
    ProviderContainer scope, int bay) async {
  _at360(tester);
  scope.read(selectedBayProvider.notifier).select(bay);
  await tester.pumpWidget(UncontrolledProviderScope(
      container: scope,
      child: MaterialApp(
          theme: ThemeData(fontFamily: 'Roboto'),
          home: Scaffold(body: BayPlanView(voyage: voyage)))));
  await tester.pumpAndSettle();
}

BoxDecoration _cellDecoration(WidgetTester tester, Finder cell) => tester
    .widget<Container>(
        find.descendant(of: cell, matching: find.byType(Container)).first)
    .decoration! as BoxDecoration;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final font = FontLoader('Roboto')
      ..addFont(rootBundle.load('assets/fonts/Roboto-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Roboto-Medium.ttf'));
    await font.load();
  });

  testWidgets(
      'T-69 reserva de 20 pies muestra tipo y puerto sin relleno de naviera',
      (tester) async {
    final scope = ProviderContainer();
    addTearDown(scope.dispose);
    final voyage = _voyage([_slot('0030184')]);
    await _pumpPlan(tester, voyage, scope, 3);
    final cell = find.byKey(const ValueKey('reserved-R:0030184'));
    expect(cell, findsOneWidget);
    expect(
        find.descendant(of: cell, matching: find.text('22G1')), findsOneWidget);
    expect(find.descendant(of: cell, matching: find.text('PAMIT')),
        findsOneWidget);
    final decoration = _cellDecoration(tester, cell);
    expect(decoration.color, isNull);
    expect((decoration.border! as Border).top.width, 2);
    expect(voyage.bays[3]!.occupancyRate, 0);
    expect(voyage.bays[3]!.totalWeight, 0);
    await tester.ensureVisible(cell);
    await tester.pumpAndSettle();
    await tester.tap(cell);
    await tester.pumpAndSettle();
    expect(find.text('22G1 · PAMIT · LNC · vacío · 2.1 t nominal'),
        findsOneWidget);
    expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('reserved-slot-key')))
            .data,
        'R:0030184');
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'T-69 proyección de 40 pies abre la reserva original sin duplicarla',
      (tester) async {
    final scope = ProviderContainer();
    addTearDown(scope.dispose);
    final voyage = _voyage([_slot('0060284', type: '45G1')]);
    await _pumpPlan(tester, voyage, scope, 6);
    expect(find.byKey(const ValueKey('reserved-R:0060284')), findsOneWidget);
    expect(voyage.totalReservedSlots, 1);
    expect(voyage.getReservedSlotsInBay(6), hasLength(1));
    for (final neighbor in [5, 7]) {
      scope.read(selectedBayProvider.notifier).select(neighbor);
      await tester.pumpAndSettle();
      final shadow =
          find.byKey(ValueKey('reserved-shadow-$neighbor-0284-R:0060284'));
      expect(shadow, findsOneWidget);
      expect(find.descendant(of: shadow, matching: find.text("40' reserva")),
          findsOneWidget);
      expect(_cellDecoration(tester, shadow).color, isNull);
      expect(voyage.getReservedSlotsInBay(neighbor), isEmpty);
      expect(voyage.bays[neighbor]!.occupancyRate, 0);
      expect(voyage.totalReservedSlots, 1);
    }
    final shadow =
        find.byKey(const ValueKey('reserved-shadow-7-0284-R:0060284'));
    await tester.ensureVisible(shadow);
    await tester.pumpAndSettle();
    await tester.tap(shadow);
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('reserved-slot-key')))
            .data,
        'R:0060284');
    expect(find.text('45G1 · PAMIT · LNC · vacío · 3.8 t nominal'),
        findsOneWidget);
    expect(find.text('R:0070284'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final filter in LegendFilterType.values) {
    testWidgets(
        'T-69 filtro de contenedores ${filter.name} conserva la reserva',
        (tester) async {
      final scope = ProviderContainer();
      addTearDown(scope.dispose);
      scope.read(selectedTypeFilterProvider.notifier).toggle(filter);
      scope.read(selectedCarrierProvider.notifier).select('LNA');
      await _pumpPlan(tester, _voyage([_slot('0030184')]), scope, 3);
      final cell = find.byKey(const ValueKey('reserved-R:0030184'));
      expect(cell, findsOneWidget);
      expect(find.descendant(of: cell, matching: find.text('22G1')),
          findsOneWidget);
      expect(find.descendant(of: cell, matching: find.text('PAMIT')),
          findsOneWidget);
      expect(_cellDecoration(tester, cell).color, isNull);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('T-69 lista de reservas a 360 dp abre el detalle por posición',
      (tester) async {
    _at360(tester);
    await tester.pumpWidget(MaterialApp(
        theme: ThemeData(fontFamily: 'Roboto'),
        home: Scaffold(
            body: SingleChildScrollView(
                child: ReservedSlotsListView(
                    reservedSlots: [_slot('0030184')])))));
    await tester.tap(find.text('Celdas reservadas (1)'));
    await tester.pumpAndSettle();
    final entry = find.byKey(const ValueKey('reserved-list-R:0030184'));
    expect(entry, findsOneWidget);
    expect(find.text('22G1 · PAMIT · LNC'), findsOneWidget);
    expect(find.text('0030184 · Vacío'), findsOneWidget);
    await tester.tap(entry);
    await tester.pumpAndSettle();
    expect(find.text('22G1 · PAMIT · LNC · vacío · 2.1 t nominal'),
        findsOneWidget);
    expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('reserved-slot-key')))
            .data,
        'R:0030184');
    expect(tester.takeException(), isNull);
  });

  test('T-69 estadísticas excluyen bahías que solo tienen reservas', () {
    final voyage = _voyage([
      _slot('0030184'),
      _slot('0060284', type: '45G1'),
    ]);
    final scope = ProviderContainer(overrides: [
      voyageNotifierProvider.overrideWith(() => _FixedVoyage(voyage)),
    ]);
    addTearDown(scope.dispose);
    expect(voyage.bays.keys.toSet(), {3, 5, 6, 7});
    final stats = scope.read(voyageStatsProvider)!;
    expect(stats.totalContainers, 0);
    expect(stats.totalBays, 0);
    expect(stats.totalWeight, 0);
  });
  test('T-69 estadísticas conservan bahías ocupadas por contenedores y sombras',
      () {
    final container = ContainerUnit(
        id: 't69-contenedor',
        containerId: 'SINT0000001',
        isoSizeType: '45G1',
        status: ContainerStatus.full,
        grossWeight: 18000,
        stowagePosition: IsoCoordinateParser.parse('0020182'));
    final voyage = _voyage([
      _slot('0090184'),
      _slot('0060284', type: '45G1'),
    ], containers: [
      container
    ]);
    final scope = ProviderContainer(overrides: [
      voyageNotifierProvider.overrideWith(() => _FixedVoyage(voyage)),
    ]);
    addTearDown(scope.dispose);
    expect(voyage.bays.keys.toSet(), {1, 2, 3, 5, 6, 7, 9});
    final stats = scope.read(voyageStatsProvider)!;
    expect(stats.totalContainers, 1);
    expect(stats.totalBays, 3,
        reason: 'cuenta la bahía 002 y las dos impares ocupadas por esa caja');
    expect(stats.totalWeight, 18000);
    expect(stats.fullContainers, 1);
    expect(stats.emptyContainers, 0);
  });
}

class _FixedVoyage extends VoyageNotifier {
  final VesselVoyage voyage;
  _FixedVoyage(this.voyage);
  @override
  AsyncValue<VesselVoyage?> build() => AsyncValue.data(voyage);
}
