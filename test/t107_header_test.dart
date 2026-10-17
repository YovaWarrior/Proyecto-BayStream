import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/pages/change_requests_page.dart';
import 'package:baystream/features/vessel/presentation/pages/operation_progress_page.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_operation_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_plan_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/bay_plan_view.dart';
import 'package:baystream/features/vessel/presentation/widgets/loading_plan_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/local_profile_test_support.dart';
import 'support/t75_memory_log.dart';
import 'support/t76_fixture.dart';
import 't105_preview_test.dart' show t105Data;
import 't81_office_changes_test.dart' as f;

/// T-107, parte A · El encabezado del plano, compacto por debajo de 600 dp.
/// Datos sintéticos de T-75 (llegada) y de T-76/T-105 (carga), con Roboto.

/// El plano de llegada sintético de T-75: tres bajan en GTSTC en la 03, uno
/// en la bodega de la 14 y un 40 sigue a PAMIT.
const _arrivalText = "UNH+1+BAPLIE:D:95B:UN:SMDG20'"
    "TDT+20+V01N+++NV2:172:20+++9000003:146:11:BUQUE ALFA'"
    "LOC+5+HNPCR:139:6'LOC+61+GTSTC:139:6'"
    "LOC+147+0030282::5'LOC+9+HNPCR:139:6'LOC+11+GTSTC:139:6'"
    "EQD+CN+TEST0000011+22G1+++5'"
    "LOC+147+0030482::5'LOC+9+HNPCR:139:6'LOC+11+GTSTC:139:6'"
    "EQD+CN+TEST0000012+22G1+++5'"
    "LOC+147+0030202::5'LOC+9+HNPCR:139:6'LOC+11+GTSTC:139:6'"
    "EQD+CN+TEST0000013+22G1+++5'"
    "LOC+147+0140202::5'LOC+9+HNPCR:139:6'LOC+11+GTSTC:139:6'"
    "EQD+CN+TEST0000014+45G1+++5'"
    "LOC+147+0140282::5'LOC+9+HNPCR:139:6'LOC+11+PAMIT:139:6'"
    "EQD+CN+TEST0000015+45G1+++5'";

final _arrival = () {
  final voyage = BaplieParserService().parse(_arrivalText);
  return voyage.withGeometry(VesselProfile.proposeFrom(voyage).geometry,
      portOfCall: 'GTSTC');
}();

const _phone = Size(360, 780);
const _desk = Size(1280, 800);

void _view(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
}

Widget _app(double scale, Widget body) => MaterialApp(
    theme: ThemeData(fontFamily: 'Roboto', useMaterial3: true),
    builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: child!),
    home: Scaffold(body: body));

Future<void> _mode(WidgetTester tester, String mode) async {
  await tester.tap(find.byKey(const ValueKey('bay-plan-display-mode')));
  await tester.pumpAndSettle();
  await tester.tap(find.text(mode).last);
  await tester.pumpAndSettle();
}

/// La oficina con sesión, la operación publicada y el plan de carga de T-105.
Future<(T75MemoryLog, ProviderContainer)> _loading(
    WidgetTester tester, Size size, double scale) async {
  _view(tester, size);
  final log = T75MemoryLog();
  final scope = ProviderContainer(overrides: [
    movementLogRepositoryProvider.overrideWith((ref) async => log),
    vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
    operatorProvider.overrideWith((ref) => Stream.value(f.office)),
    activeOperationProvider.overrideWith((ref) async => f.operation),
    loadingOperationProvider(t76Loading).overrideWith((ref) async* {
      await for (final records in log.watch('op')) {
        yield t105Data(records.map((r) => r.movement).toList());
      }
    }),
    loadingPlanProgressProvider(t76Loading).overrideWith((ref) async* {
      await for (final records in log.watch('op')) {
        yield t105Data(records.map((r) => r.movement).toList()).progress;
      }
    }),
  ]);
  addTearDown(scope.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
      container: scope, child: _app(scale, BayPlanView(voyage: t76Loading))));
  await tester.pumpAndSettle();
  await _mode(tester, 'Carga');
  return (log, scope);
}

/// El plano de llegada de T-75 en el modo Descarga, con su operación guardada.
Future<void> _discharge(WidgetTester tester, Size size, double scale) async {
  _view(tester, size);
  final log = T75MemoryLog();
  await log.saveOperation(Operation(
      id: 'op-t107',
      vesselName: _arrival.vessel.name,
      voyageNumber: _arrival.voyageNumber,
      portOfCall: 'GTSTC',
      createdAt: DateTime.utc(2026, 10, 16)));
  final scope = ProviderContainer(overrides: [
    movementLogRepositoryProvider.overrideWith((ref) async => log),
    vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
  ]);
  addTearDown(scope.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
      container: scope, child: _app(scale, BayPlanView(voyage: _arrival))));
  await tester.pumpAndSettle();
  await _mode(tester, 'Descarga');
}

/// El encabezado ocupa dos líneas: el modo, «Acciones» y la nube arriba, y el
/// resumen abajo. La rejilla se queda con al menos [share] del alto.
void _twoLines(WidgetTester tester, double share, {required String reason}) {
  final header = tester.getRect(find.byType(LoadingPlanControls));
  final mode = tester.getRect(find.byKey(const ValueKey('bay-plan-display-mode')));
  final actions = tester.getRect(find.byKey(const ValueKey('bay-plan-actions')));
  final cloud = tester.getRect(find.byKey(const ValueKey('sync-status-chip')));
  final summary = tester.getRect(find.byKey(const ValueKey('plan-summary-line')));
  // En Carga, «OR / últimos dígitos» va en la misma segunda línea.
  final search = find.byKey(const ValueKey('load-search'));
  final second = [
    summary,
    if (search.evaluate().isNotEmpty) tester.getRect(search),
  ];
  for (final r in [actions, cloud]) {
    expect((r.center.dy - mode.center.dy).abs(), lessThan(1), reason: reason);
  }
  final first = [mode, actions, cloud].map((r) => r.bottom).reduce(
      (a, b) => a > b ? a : b);
  for (final r in second) {
    expect(r.top, greaterThanOrEqualTo(first - 1), reason: reason);
    expect(r.top, lessThan(summary.bottom), reason: reason);
  }
  // Debajo de la segunda línea solo queda el margen de 4 dp del encabezado.
  final last = second.map((r) => r.bottom).reduce((a, b) => a > b ? a : b);
  expect(header.bottom - last, lessThanOrEqualTo(8), reason: reason);
  expect(mode.top - header.top, lessThanOrEqualTo(8), reason: reason);
  for (final r in [mode, actions, cloud, ...second]) {
    expect(r.left, greaterThanOrEqualTo(0), reason: reason);
    expect(r.right, lessThanOrEqualTo(_phone.width), reason: reason);
  }
  // La rejilla: el Expanded del plano, el ancestro más lejano de una celda.
  final cell = find.byWidgetPredicate((w) =>
      w.key is ValueKey<String> &&
      (w.key! as ValueKey<String>).value.startsWith('cell-'));
  final grid = tester.getRect(
      find.ancestor(of: cell.first, matching: find.byType(Expanded)).last);
  expect(grid.height, greaterThanOrEqualTo(_phone.height * share),
      reason: '$reason · rejilla ${grid.height.round()} dp');
}

/// Cada «re‑estiba» que se ve lleva U+2011 y queda en una sola línea.
int _unbroken(WidgetTester tester) {
  var seen = 0;
  for (final paragraph
      in tester.renderObjectList<RenderParagraph>(find.byType(RichText))) {
    final text = paragraph.text.toPlainText();
    expect(text, isNot(contains(RegExp('[Rr]e-estiba'))), reason: text);
    for (final match in RegExp('[Rr]e‑estibas?').allMatches(text)) {
      seen++;
      final lines = paragraph
          .getBoxesForSelection(
              TextSelection(baseOffset: match.start, extentOffset: match.end))
          .map((box) => box.top.round())
          .toSet();
      expect(lines, hasLength(1), reason: text);
    }
  }
  return seen;
}

double _height(WidgetTester tester, String key) =>
    tester.getRect(find.byKey(ValueKey(key))).height;

Future<void> _openActions(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('bay-plan-actions')));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final font = FontLoader('Roboto')
      ..addFont(rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    await font.load();
  });

  for (final (scale, share) in [(1.0, .5), (1.45, 1 / 3)]) {
    testWidgets('T-107 Carga a 360×780 dp con letra $scale: dos líneas, '
        'la rejilla, el resumen que se abre y «re‑estibas» entera',
        (tester) async {
      await _loading(tester, _phone, scale);
      _twoLines(tester, share, reason: 'Carga $scale');
      // Lo que antes eran botones ya no está en la línea; OR sí, a la vista.
      expect(find.text('Pendientes por bahía'), findsNothing);
      expect(find.byKey(const ValueKey('empty-search')), findsNothing);
      final search = tester.getRect(find.byKey(const ValueKey('load-search')));
      expect(search.right, lessThanOrEqualTo(_phone.width));
      expect(find.text('OR / últimos dígitos'), findsOneWidget);
      // El resumen, en una línea; con un toque, completo; con otro, recogido.
      final closed = _height(tester, 'plan-summary-line');
      await tester.tap(find.byKey(const ValueKey('plan-summary-toggle')));
      await tester.pumpAndSettle();
      expect(_height(tester, 'plan-summary-line'), greaterThan(closed + 20));
      expect(find.textContaining('Descarga: 0 pendientes'), findsOneWidget);
      expect(_unbroken(tester), greaterThan(0));
      await tester.tap(find.byKey(const ValueKey('plan-summary-toggle')));
      await tester.pumpAndSettle();
      expect(_height(tester, 'plan-summary-line'), closed);
      expect(tester.takeException(), isNull);
    });

    testWidgets('T-107 Descarga a 360×780 dp con letra $scale: dos líneas y '
        'la tabla desde «Acciones»', (tester) async {
      await _discharge(tester, _phone, scale);
      _twoLines(tester, share, reason: 'Descarga $scale');
      expect(find.text('Pendientes de descarga'), findsNothing);
      // El resumen recogido sigue en el árbol: sus claves no cambian.
      expect(find.byKey(const ValueKey('bay-discharge-pending')), findsOneWidget);
      await _openActions(tester);
      await tester.tap(find.byKey(const ValueKey('discharge-table-button')));
      await tester.pumpAndSettle();
      expect(find.textContaining('2 bahías · 4 pendientes'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('T-107 a 360 dp con letra $scale: cada entrada de «Acciones» '
        'abre lo mismo que su botón, y la cuenta se ve en «Acciones»',
        (tester) async {
      final (log, _) = await _loading(tester, _phone, scale);
      // Pendientes por bahía.
      await _openActions(tester);
      await tester.tap(find.text('Pendientes por bahía'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('operation-loading-totals')),
          findsOneWidget);
      await tester.tap(find.text('Cerrar').last);
      await tester.pumpAndSettle();
      // Avance de la operación.
      await _openActions(tester);
      await tester.tap(find.byKey(const ValueKey('operation-progress-button')));
      await tester.pumpAndSettle();
      expect(find.byType(OperationProgressPage), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      // Asignar vacío abre el mismo selector que «OR / últimos dígitos».
      await _openActions(tester);
      await tester.tap(find.byKey(const ValueKey('empty-search')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('loading-query')), findsOneWidget);
      expect(find.byKey(const ValueKey('loading-or-12')), findsOneWidget);
      expect(find.byKey(const ValueKey('loading-or-1')), findsNothing);
      await tester.tap(find.text('Cerrar').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('load-search')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('loading-or-1')), findsOneWidget);
      await tester.tap(find.text('Cerrar').last);
      await tester.pumpAndSettle();
      // La bandeja, con la cuenta en la entrada y en «Acciones».
      expect(find.byType(Badge), findsOneWidget);
      expect(tester.widget<Badge>(find.byType(Badge)).isLabelVisible, isFalse);
      await log.append(
          MovementDraft.requestChange(
              'op',
              const [PositionChange(f.key, '0030282', '0030082')],
              'Solicitud remota'),
          f.dock.author);
      await tester.pumpAndSettle();
      expect(tester.widget<Badge>(find.byType(Badge)).isLabelVisible, isTrue);
      expect(
          find.descendant(
              of: find.byType(Badge), matching: find.text('1')),
          findsOneWidget);
      await _openActions(tester);
      expect(
          find.descendant(
              of: find.byKey(const ValueKey('change-requests-button')),
              matching: find.text('Bandeja de cambios (1)')),
          findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('change-requests-button')));
      await tester.pumpAndSettle();
      expect(find.byType(ChangeRequestsPage), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      // La nube, como ícono, con su clave y su estado en la ayuda.
      final cloud = tester.widget<IconButton>(
          find.byKey(const ValueKey('sync-status-chip')));
      expect(cloud.tooltip, startsWith('Nube y cuenta · '));
      expect(cloud.onPressed, isNotNull);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('T-107 a 1280 dp el encabezado de Carga es el de antes',
      (tester) async {
    await _loading(tester, _desk, 1);
    expect(find.byKey(const ValueKey('bay-plan-actions')), findsNothing);
    expect(find.byKey(const ValueKey('plan-summary-line')), findsNothing);
    expect(find.text('Pendientes por bahía'), findsOneWidget);
    expect(find.byKey(const ValueKey('operation-progress-button')),
        findsOneWidget);
    expect(tester.widget(find.byKey(const ValueKey('sync-status-chip'))),
        isA<ActionChip>());
    expect(find.text('Bandeja de cambios (0)'), findsOneWidget);
    expect(find.byKey(const ValueKey('load-search')), findsOneWidget);
    expect(find.byKey(const ValueKey('empty-search')), findsOneWidget);
    expect(find.textContaining('Descarga: 0 pendientes'), findsOneWidget);
    expect(_unbroken(tester), greaterThan(0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('T-107 a 1280 dp el encabezado de Descarga es el de antes',
      (tester) async {
    await _discharge(tester, _desk, 1);
    expect(find.byKey(const ValueKey('bay-plan-actions')), findsNothing);
    expect(find.byKey(const ValueKey('plan-summary-line')), findsNothing);
    expect(find.text('Pendientes de descarga'), findsOneWidget);
    expect(find.byKey(const ValueKey('operation-discharge-totals')),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
