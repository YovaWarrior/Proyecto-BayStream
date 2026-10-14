import 'dart:async';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/formatters/operation_text.dart';
import 'package:baystream/features/vessel/presentation/pages/operation_progress_page.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_overview_page.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_operation_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/detail_text_row.dart';
import 'package:baystream/features/vessel/presentation/widgets/sync_status_chip.dart';
import 'package:baystream/features/vessel/domain/repositories/operation_sync_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t91_toolbar_support.dart';
import 'support/t76_fixture.dart';

final t97Parsed = BaplieParserService().parse("UNH+1+BAPLIE:D:95B:UN:SMDG22'"
    "TDT+20+T97+++TST:172:20+++9000097:146:11:BUQUE PRUEBA'"
    "LOC+5+HNPCR:139:6'LOC+61+GTSTC:139:6'"
    "LOC+147+0010182::5'LOC+9+HNPCR:139:6'LOC+11+GTSTC:139:6'"
    "MEA+AAE+VGM+KGM:20000'EQD+CN+TSTU0000097+22G1+++5'");
final t97Voyage = t97Parsed.withGeometry(
    VesselProfile.proposeFrom(t97Parsed).geometry,
    portOfCall: 'GTSTC');

void completeText(WidgetTester tester, Finder finder) {
  expect(finder, findsOneWidget);
  final text = tester.widget<Text>(finder);
  expect(text.overflow, isNot(TextOverflow.ellipsis));
  final paragraph = tester.renderObject<RenderParagraph>(finder);
  expect(paragraph.didExceedMaxLines, isFalse);
  final rect = tester.getRect(finder);
  expect(rect.width, greaterThan(0));
  expect(rect.left, greaterThanOrEqualTo(0));
  expect(rect.right, lessThanOrEqualTo(360.01));
}

/// Misma pantalla y misma comprobación para el fixture y el A07 externo.
Future<void> checkT97Plan(
    WidgetTester tester, VesselVoyage voyage, Brightness brightness) async {
  await pumpT91Plan(tester, voyage, T91MemorySettings(), brightness);
  tester.view.physicalSize = const Size(360, 800);
  tester.platformDispatcher.textScaleFactorTestValue = 2;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await tester.pumpAndSettle();
  completeText(tester, find.text('BayStream'));
  expect(tester.takeException(), isNull);
  await tester.tap(find.byTooltip('Desplegar acciones'));
  await tester.pumpAndSettle();
  completeText(tester, find.text('BayStream'));
  final selector = tester.getRect(find.byKey(const ValueKey('bay-selector')));
  for (final element in find
      .descendant(
          of: find.byKey(const ValueKey('bay-selector')),
          matching: find.byType(Text))
      .evaluate()) {
    final rect = tester.getRect(find.byWidget(element.widget));
    expect(rect.top, greaterThanOrEqualTo(selector.top));
    expect(rect.bottom, lessThanOrEqualTo(selector.bottom));
  }
  expect(tester.takeException(), isNull);
  await tester.tap(find.byTooltip('Plegar acciones'));
  await tester.pumpAndSettle();
  final unit = voyage
      .bays[voyage.bays.keys.reduce((a, b) => a < b ? a : b)]!.containers.first;
  final pos = unit.stowagePosition!;
  final cell = find.byKey(ValueKey('cell-${pos.row}-${pos.tier}'));
  await tester.ensureVisible(cell);
  await tester.tap(cell);
  await tester.pumpAndSettle();
  final row = find.byWidgetPredicate(
      (w) => w is DetailTextRow && w.label == 'Puerto Descarga');
  await tester.ensureVisible(row);
  await tester.pumpAndSettle();
  completeText(
      tester, find.descendant(of: row, matching: find.text('Puerto Descarga')));
  completeText(
      tester,
      find.descendant(
          of: row, matching: find.text(unit.portOfDischarge ?? 'N/A')));
  expect(tester.takeException(), isNull);
  await tester.pumpWidget(const SizedBox());
  tester.platformDispatcher.clearTextScaleFactorTestValue();
  await tester.pump();
}

void main() {
  test(
      'T-97 al cambiar de plano no conserva el offline anterior mientras averigua',
      () async {
    final updates = StreamController<SyncStatus>.broadcast();
    var subscriptions = 0;
    final scope = ProviderContainer(overrides: [
      syncStatusProvider.overrideWith((ref) => subscriptions++ == 0
          ? Stream.value(const SyncStatus(SyncState.offline))
          : updates.stream),
    ]);
    final subscription = scope.listen(syncStatusProvider, (previous, next) {});
    try {
      expect((await scope.read(syncStatusProvider.future)).state,
          SyncState.offline);
      scope.invalidate(syncStatusProvider);
      final loading = scope.read(syncStatusProvider);
      expect(loading.isLoading, isTrue);
      expect(visibleSyncStatus(loading).state, SyncState.connecting);
      await Future<void>.delayed(Duration.zero);
      updates.add(const SyncStatus(SyncState.upToDate));
      expect((await scope.read(syncStatusProvider.future)).state,
          SyncState.upToDate);
    } finally {
      subscription.close();
      scope.dispose();
      await updates.close();
    }
  });
  test('T-97 cero, uno y varios concuerdan; las zonas dicen pendientes', () {
    expect(operationCount(0, 'cargado', 'cargados'), '0 cargados');
    expect(operationCount(1, 'cargado', 'cargados'), '1 cargado');
    expect(operationCount(2, 'cargado', 'cargados'), '2 cargados');
    expect(pendingZones(0, 1),
        '(0 pendientes en cubierta / 1 pendiente en bodega)');
    expect(rejectionText('Rechazo..'), 'Rechazo.');
    expect(rejectionText('Rechazo.'), 'Rechazo.');
    expect(
        syncStatusText(const SyncStatus(SyncState.connecting)), 'Conectando…');
    expect(syncStatusText(const SyncStatus(SyncState.offline)), 'Sin conexión');
  });
  for (final brightness in Brightness.values) {
    testWidgets(
        'T-97 selector con escala no lineal de Android ${brightness.name}',
        (tester) async {
      final scope =
          await pumpT91Plan(tester, t97Voyage, T91MemorySettings(), brightness);
      await tester.pumpWidget(UncontrolledProviderScope(
          container: scope,
          child: MaterialApp(
              theme: ThemeData(brightness: brightness, fontFamily: 'Roboto'),
              builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: const _AndroidLargeText()),
                  child: child!),
              home: const VesselOverviewPage())));
      tester.view.physicalSize = const Size(360, 800);
      await tester.pumpAndSettle();
      final selector = find.byKey(const ValueKey('bay-selector'));
      final rect = tester.getRect(selector);
      final chip = find
          .descendant(of: selector, matching: find.byType(FilterChip))
          .first;
      expect(tester.getRect(chip).right, lessThanOrEqualTo(312));
      for (final element in find
          .descendant(of: chip, matching: find.byType(Text))
          .evaluate()) {
        final bounds = tester.getRect(find.byWidget(element.widget));
        expect(bounds.bottom, lessThanOrEqualTo(rect.bottom));
        expect(bounds.right, lessThanOrEqualTo(tester.getRect(chip).right));
        expect(
            tester
                .renderObject<RenderParagraph>(find.byWidget(element.widget))
                .didExceedMaxLines,
            isFalse);
      }
      expect(tester.takeException(), isNull);
    });
    testWidgets(
        'T-97 titulo, selector y detalle a 360 dp y escala 2.0 ${brightness.name}',
        (tester) async {
      await checkT97Plan(tester, t97Voyage, brightness);
    });
    testWidgets('T-97 Total Contenedores completo a 360 dp ${brightness.name}',
        (tester) async {
      await pumpT91Plan(tester, t97Voyage, T91MemorySettings(), brightness);
      tester.view.physicalSize = const Size(360, 800);
      await tester.tap(find.text('Estadísticas'));
      await tester.pumpAndSettle();
      completeText(tester, find.text('Total Contenedores'));
      expect(tester.takeException(), isNull);
    });
    testWidgets(
        'T-97 Avance muestra un cargado y un pendiente ${brightness.name}',
        (tester) async {
      final operation = t76Operation([
        t76Movement(MovementDraft.loadFull('op', 'FULL0005678', '0030682'), 1)
      ]);
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(ProviderScope(
          overrides: [
            loadingOperationProvider(t76Loading)
                .overrideWith((ref) => Stream.value(operation)),
          ],
          child: MaterialApp(
              theme: ThemeData(brightness: brightness),
              home: OperationProgressPage(voyage: t76Loading))));
      await tester.pumpAndSettle();
      expect(find.text('Llenos: 1 cargado · 1 pendiente'), findsWidgets);
      expect(find.textContaining('pendientes en cubierta'), findsWidgets);
      completeText(tester, find.text('Avance de la operación'));
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpAndSettle();
      completeText(tester, find.text('Avance de la operación'));
      expect(tester.takeException(), isNull);
    });
  }
}

class _AndroidLargeText extends TextScaler {
  const _AndroidLargeText();
  @override
  double scale(double fontSize) => fontSize * (fontSize <= 14 ? 2 : 1.3);
  @override
  double get textScaleFactor => 2;
}
