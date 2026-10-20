import 'dart:convert';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/presentation/pages/hatch_covers_page.dart';
import 'package:baystream/features/vessel/presentation/widgets/hatch_cover_diagram.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/bay_plan_view.dart';
import 'support/local_profile_test_support.dart';

const geometry = VesselGeometry(
    portRows: 2,
    starboardRows: 2,
    holdTiers: [2, 4],
    deckTiers: [82],
    centerRowInHold: false);
HatchCoverDeclaration crane(List<Set<int>> rows) =>
    HatchCoverDeclaration(kind: HatchCoverKind.crane, covers: rows);
VesselProfile profile() =>
    VesselProfile.proposeFrom(BaplieParserService().parse(profileTestEdi))
        .copyWith(geometry: geometry, observedHoldBayNumbers: {1, 2, 3});

class _PlanNotifier extends VoyageNotifier {
  final VesselProfile profile;
  _PlanNotifier(this.profile);
  @override
  VesselProfile? get currentProfile => profile;
}

void main() {
  test('T83 sin tapa y automática son declaraciones explícitas diferentes', () {
    final open = HatchCoverDeclaration(kind: HatchCoverKind.openHold);
    final auto = HatchCoverDeclaration(kind: HatchCoverKind.automatic, covers: [
      {4, 2, 1, 3}
    ]);
    expect(open.validate(geometry, hasHold: true), isNull);
    expect(auto.validate(geometry, hasHold: true), isNull);
    expect(open, isNot(auto));
  });
  for (var n = 1; n <= 3; n++) {
    test('T83 admite $n tapas de grúa con filas propias', () {
      expect(
          crane([
            {4},
            if (n > 1) {2},
            if (n > 2) {1, 3}
          ]).validate(geometry, hasHold: true),
          isNull);
    });
  }
  test('T83 rechaza filas solapadas', () {
    expect(
        crane([
          {4, 2},
          {2}
        ]).validate(geometry, hasHold: true),
        contains('solapa'));
  });
  test('T83 rechaza fila ajena y fila central físicamente ausente', () {
    expect(
        crane([
          {6}
        ]).validate(geometry, hasHold: true),
        contains('no pertenece'));
    expect(
        crane([
          {0}
        ]).validate(geometry, hasHold: true),
        contains('no pertenece'));
    expect(
        crane([
          {0}
        ]).validate(geometry.copyWith(centerRowInHold: true), hasHold: true),
        isNull);
  });
  test(
      'T83 rechaza bodega inexistente, conjuntos vacíos y cantidades inválidas',
      () {
    expect(
        crane([
          {2}
        ]).validate(geometry, hasHold: false),
        contains('sin bodega'));
    expect(crane([{}]).validate(geometry, hasHold: true),
        contains('al menos una fila'));
    expect(crane([]).validate(geometry, hasHold: true), contains('una a tres'));
    expect(
        crane([
          {4},
          {2},
          {1},
          {3}
        ]).validate(geometry, hasHold: true),
        contains('una a tres'));
    expect(
        HatchCoverDeclaration(kind: HatchCoverKind.automatic, covers: [
          {2},
          {1}
        ]).validate(geometry, hasHold: true),
        contains('exactamente una'));
    expect(
        HatchCoverDeclaration(kind: HatchCoverKind.openHold, covers: [
          {2}
        ]).validate(geometry, hasHold: true),
        contains('no lleva'));
  });
  test('T83 perfil histórico no inventa tapas ni bahías', () {
    final json = profile().toJson()
      ..remove('hatchCovers')
      ..remove('observedHoldBayNumbers');
    final old = VesselProfile.fromJson(json);
    expect(old.hatchCovers, isEmpty);
    expect(old.observedHoldBayNumbers, isEmpty);
  });
  test(
      'T83 colecciones inmutables y plantilla no transfiere tapas a otro buque',
      () {
    final rows = <int>{2};
    final d = crane([rows]);
    rows.add(4);
    expect(d.covers.single, {2});
    expect(() => d.covers.single.add(4), throwsUnsupportedError);
    final p = profile().copyWith(hatchCovers: {2: d});
    expect(() => p.hatchCovers.clear(), throwsUnsupportedError);
    expect(
        p
            .cloneFor(const Vessel(
                id: 'test', name: 'BUQUE TEST', imoNumber: '9000015'))
            .hatchCovers,
        isEmpty);
  });
  test('T83 JSON preserva declaraciones, filas, inventario y geometría', () {
    final p = profile().copyWith(hatchCovers: {
      1: HatchCoverDeclaration(kind: HatchCoverKind.openHold),
      2: HatchCoverDeclaration(kind: HatchCoverKind.automatic, covers: [
        {4, 2, 1, 3}
      ]),
      3: crane([
        {4},
        {2},
        {1, 3}
      ])
    });
    expect(
        VesselProfile.fromJson(
            jsonDecode(jsonEncode(p.toJson())) as Map<String, dynamic>),
        p);
  });
  test('T83 almacén real de prueba conserva perfil y rechaza edición inválida',
      () async {
    final store = await testProfileStore();
    final p = profile().copyWith(hatchCovers: {
      2: crane([
        {2},
        {1}
      ])
    });
    expect((await store.repository.saveProfile(p)).isRight(), isTrue);
    final invalid = p.copyWith(hatchCovers: {
      2: crane([
        {2},
        {2}
      ])
    });
    expect(
        (await store.repository.saveProfile(invalid))
            .fold((f) => f.message, (_) => ''),
        contains('solapa'));
    expect((await store.repository.getAllProfiles()).getOrElse(() => []).single,
        p);
    await store.repository.close();
    await store.directory.delete(recursive: true);
  });
  test('T83 huella de 40 pies identifica bodega en las dos vecinas', () {
    final v = BaplieParserService()
        .parse(profileTestEdi.replaceAll('0020182', '0020102'));
    expect(observedHoldBays(v, geometry), {1, 2, 3});
    expect(
        observedHoldBays(BaplieParserService().parse(profileTestEdi), geometry),
        isEmpty);
  });

  Future<void> editor(WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        home: HatchCoversPage(geometry: geometry, holdBays: {
      1,
      2,
      3
    }, initial: {
      1: crane([
        {4, 2},
        {1, 3}
      ])
    })));
  }

  testWidgets('T83 editor a 360 dp rechaza solape y fila ajena con mensaje',
      (tester) async {
    await editor(tester);
    await tester.enterText(find.byKey(const ValueKey('hatch-rows-1')), '02');
    await tester.tap(find.byKey(const ValueKey('hatch-apply')));
    await tester.pump();
    expect(find.textContaining('se solapa'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('hatch-rows-1')), '06');
    // T-56: el desplegable ya no tiene altura fija y el botón queda más abajo.
    // T-112: el mensaje con su acción ocupa más líneas; se arrastra la lista.
    await tester.dragUntilVisible(find.byKey(const ValueKey('hatch-apply')),
        find.byType(ListView), const Offset(0, -100));
    await tester.ensureVisible(find.byKey(const ValueKey('hatch-apply')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('hatch-apply')));
    await tester.pump();
    expect(find.textContaining('no pertenece'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('T83 copiar declaración y mostrar contornos a 360 dp',
      (tester) async {
    await editor(tester);
    await tester.scrollUntilVisible(
        find.byKey(const ValueKey('hatch-copy')), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.byKey(const ValueKey('hatch-copy')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('hatch-target-2')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('hatch-copy-confirm')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
        find.byKey(const ValueKey('hatch-bay-1')), -200,
        scrollable: find.byType(Scrollable).first);
    await tester.drag(find.byType(ListView).first, const Offset(0, 800));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('hatch-bay-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bahía 02').last);
    await tester.pumpAndSettle();
    expect(find.text('T1 · filas 04, 02'), findsOneWidget);
    expect(find.text('T2 · filas 01, 03'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('T83 perfil histórico muestra sin declarar en diagrama',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: HatchCoverDiagram(declaration: null, rows: [2, 0, 1]))));
    expect(find.text('Tapas: sin declarar'), findsOneWidget);
  });
  testWidgets(
      'T83 contorno alineado con las celdas reales sin cambiar la rejilla',
      (tester) async {
    final v = BaplieParserService()
        .parse(profileTestEdi.replaceAll('0020182', '0020102'))
        .withGeometry(geometry);
    final p = profile().copyWith(hatchCovers: {
      2: crane([
        {4, 2},
        {1, 3}
      ])
    });
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final scope = ProviderContainer(overrides: [
      voyageNotifierProvider.overrideWith(() => _PlanNotifier(p))
    ]);
    addTearDown(scope.dispose);
    scope.read(selectedBayProvider.notifier).select(2);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: scope,
        child: MaterialApp(home: Scaffold(body: BayPlanView(voyage: v)))));
    await tester.pumpAndSettle();
    for (final row in geometry.orderedRows) {
      expect(
          tester.getCenter(find.byKey(ValueKey('hatch-outline-0-$row'))).dx,
          closeTo(
              tester.getCenter(find.byKey(ValueKey('cell-$row-2'))).dx, .01));
    }
    final cells = find.byWidgetPredicate((w) =>
        w.key is ValueKey<String> &&
        (w.key as ValueKey<String>).value.startsWith('cell-'));
    expect(cells, findsNWidgets(geometry.slotsPerBay));
    expect(tester.takeException(), isNull);
    tester.view.physicalSize = const Size(360, 800);
    await tester.pumpAndSettle();
    final compact = find.byKey(const ValueKey('hatch-compact-plan'));
    expect(compact, findsOneWidget);
    for (final row in geometry.orderedRows) {
      final rect = tester.getRect(find.descendant(
          of: compact, matching: find.byKey(ValueKey('hatch-outline-0-$row'))));
      expect(rect.left, greaterThanOrEqualTo(16));
      expect(rect.right, lessThanOrEqualTo(344));
    }
    expect(tester.takeException(), isNull);
  });
}
