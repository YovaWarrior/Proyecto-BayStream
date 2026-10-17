import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';
import 'package:baystream/features/vessel/domain/services/operation_state_deriver.dart';
import 'package:baystream/features/vessel/presentation/pages/operation_progress_page.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_operation_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_plan_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/bay_plan_view.dart';
import 'package:baystream/features/vessel/presentation/widgets/loading_controls.dart';
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

/// T-107, parte B · Los textos: la etiqueta de accesibilidad de las celdas de
/// carga y los avisos del deriver nombran el objeto como lo ve el planner
/// (formato de T-106), sin `C:` ni `R:`, y «re‑estiba» lleva U+2011.

/// Llegada: INCOMING1 baja en GTSTC (0030282) y TRANSIT1 sigue a PAMIT
/// (0010182). Carga: el plan sintético de T-76 con su listado.
final _plan = OperationPlan.build(
  portOfCall: 'GTSTC',
  arrival: t76Voyage([
    t76Unit('INCOMING1', '0030282', incoming: true),
    ContainerUnit(
        id: 'uuid-TRANSIT1',
        containerId: 'TRANSIT1',
        isoSizeType: '22G1',
        status: ContainerStatus.full,
        stowagePosition: IsoCoordinateParser.parse('0010182'),
        operatorCode: 'TEST',
        portOfLoading: 'HNPCR',
        portOfDischarge: 'PAMIT'),
  ]),
  loading: t76Loading,
  list: t76List,
);

List<String> _messages(List<MovementDraft> drafts) => const OperationStateDeriver()
    .derive(_plan, [
      for (var i = 0; i < drafts.length; i++) t76Movement(drafts[i], i + 1)
    ])
    .conflicts
    .map((c) => c.message)
    .toList();

MovementDraft _load(String id, String position, [int? order]) =>
    MovementDraft.loadFull('op', id, position, order: order);
MovementDraft _assign(String position, String id, [int? order]) =>
    MovementDraft.assignEmpty('op', position, id, 2185, order: order);
MovementDraft _cancel(String target) =>
    MovementDraft.cancelItem('op', target, 'No embarca');
MovementDraft _change(String target, String from, String to) =>
    MovementDraft.changePosition(
        'op', [PositionChange(target, from, to)], 'Cambio de prueba');

/// El plano de llegada sintético de T-75 (el mismo de la parte A).
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

void _phone(WidgetTester tester) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(360, 780);
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

Future<void> _openActions(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('bay-plan-actions')));
  await tester.pumpAndSettle();
}

/// La oficina con la operación de T-105, en el modo Carga.
Future<void> _loading(WidgetTester tester, double scale) async {
  _phone(tester);
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
}

/// El plano de llegada de T-75 en el modo Descarga, con su operación guardada.
Future<void> _discharge(WidgetTester tester, double scale) async {
  _phone(tester);
  final log = T75MemoryLog();
  await log.saveOperation(Operation(
      id: 'op-t107',
      vesselName: _arrival.vessel.name,
      voyageNumber: _arrival.voyageNumber,
      portOfCall: 'GTSTC',
      createdAt: DateTime.utc(2026, 10, 17)));
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

/// Cada «re‑estiba» que se ve lleva U+2011 y queda en una sola línea; ningún
/// texto lleva el guion normal. Lo que corta el «…» de un resumen recogido no
/// se dibuja y no cuenta. Devuelve cuántas vio.
int _unbroken(WidgetTester tester) {
  var seen = 0;
  for (final paragraph
      in tester.renderObjectList<RenderParagraph>(find.byType(RichText))) {
    final text = paragraph.text.toPlainText();
    expect(text, isNot(contains(RegExp('re-est', caseSensitive: false))),
        reason: text);
    for (final match
        in RegExp('re‑est[a-z]*\\.?', caseSensitive: false).allMatches(text)) {
      final lines = paragraph
          .getBoxesForSelection(
              TextSelection(baseOffset: match.start, extentOffset: match.end))
          .map((box) => box.top.round())
          .toSet();
      if (lines.isEmpty) continue;
      seen++;
      expect(lines, hasLength(1), reason: text);
    }
  }
  return seen;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final font = FontLoader('Roboto')
      ..addFont(rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    await font.load();
  });

  group('T-107 los avisos del deriver, sin claves internas', () {
    final cases = <(String, List<MovementDraft>, String)>[
      (
        'descarga fuera del plano de llegada',
        [MovementDraft.discharge('op', 'NOPE0000001', '0030282')],
        'NOPE0000001 no está en el plano de llegada de esta escala.'
      ),
      (
        'descarga de uno de paso, con «re‑estiba» en U+2011',
        [MovementDraft.discharge('op', 'TRANSIT1', '0010182')],
        'TRANSIT1 no descarga en GTSTC; si sale para volver a subir, es una '
            're‑estiba.'
      ),
      (
        'la celda la ocupa lo que llegó',
        [_load('FULL0001234', '0030282', 1)],
        '0030282 ya la ocupa INCOMING1.'
      ),
      (
        'la celda la ocupa un lleno con orden',
        [_load('FULL0005678', '0030682', 2), _load('FULL0001234', '0030682', 1)],
        '0030682 ya la ocupa OR 2 · FULL0005678.'
      ),
      (
        'la celda la ocupa un vacío asignado: se nombra el contenedor',
        [_assign('0030882', 'EMPTY0000012', 12), _load('FULL0005678', '0030882', 2)],
        '0030882 ya la ocupa OR 12 · EMPTY0000012.'
      ),
      (
        'cargado fuera de su celda',
        [_load('FULL0005678', '0031082', 2)],
        'OR 2 · FULL0005678: planificado en 0030682, registrado en 0031082.'
      ),
      (
        'cargado dos veces',
        [_load('FULL0005678', '0030682', 2), _load('FULL0005678', '0031082', 2)],
        'OR 2 · FULL0005678 ya se cargó en 0030682.'
      ),
      (
        'se carga lo que no sube aquí',
        [_load('INCOMING1', '0031282')],
        'INCOMING1 no se carga en GTSTC.'
      ),
      (
        'se carga lo que no está en el plan',
        [_load('NOPE0000001', '0031282', 9)],
        'OR 9 · NOPE0000001 no está en el plan de carga de GTSTC.'
      ),
      (
        'se carga lo cancelado',
        [_cancel('C:FULL0005678'), _load('FULL0005678', '0030682', 2)],
        'FULL0005678 está cancelado y se cargó.'
      ),
      (
        'se asigna un vacío a un contenedor',
        [
          MovementDraft.raw('op', MovementType.assignEmpty, 'C:FULL0005678',
              {'container': 'EMPTY0000012', 'tareKg': 2185})
        ],
        'FULL0005678 no es una celda reservada del plan.'
      ),
      (
        'el mismo vacío en dos reservas',
        [_assign('0050282', 'EMPTY0000012'), _assign('0030882', 'EMPTY0000012')],
        'EMPTY0000012 ya está en la reserva 005 02 82.'
      ),
      (
        'la reserva ya tiene vacío',
        [_assign('0050282', 'EMPTY0000012'), _assign('0050282', 'EMPTY0000013')],
        'La reserva 005 02 82 ya tiene asignado EMPTY0000012.'
      ),
      (
        'se asigna una reserva cancelada',
        [_cancel('R:0050282'), _assign('0050282', 'EMPTY0000012')],
        'La reserva 005 02 82 está cancelada y se asignó.'
      ),
      (
        'se cancela lo que no está en el plan',
        [_cancel('C:NOPE0000001')],
        'NOPE0000001 no está en el plan de esta escala.'
      ),
      (
        'se cancela lo que ya se movió',
        [_load('FULL0005678', '0030682', 2), _cancel('C:FULL0005678')],
        'OR 2 · FULL0005678 ya se movió; para cancelarlo, anula antes ese '
            'movimiento.'
      ),
      (
        'el cambio cita lo que no está en el plan',
        [_change('C:NOPE0000001', '0031082', '0031282')],
        'NOPE0000001 no está en el plan de carga.'
      ),
      (
        'el cambio parte de un origen obsoleto',
        [_change('C:FULL0005678', '0031082', '0031282')],
        'FULL0005678: origen obsoleto; plan efectivo 0030682, cambio desde '
            '0031082.'
      ),
      (
        'el cambio de una reserva parte de un origen obsoleto',
        [_change('R:0050282', '0050482', '0050682')],
        'La reserva 005 02 82: origen obsoleto; plan efectivo 0050282, cambio '
            'desde 0050482.'
      ),
    ];
    for (final (name, drafts, expected) in cases) {
      test(name, () {
        final messages = _messages(drafts);
        expect(messages, contains(expected));
        for (final message in messages) {
          expect(message, isNot(matches(RegExp('[CR]:'))), reason: message);
          expect(message, isNot(contains('re-estiba')), reason: message);
        }
      });
    }
  });

  group('T-107 la etiqueta de accesibilidad de las celdas de carga', () {
    test('un lleno con orden: «OR 1 · FULL0001234, sube», y su estado', () {
      expect(loadingCellSemantics(t105Data(), 'C:FULL0001234'),
          'OR 1 · FULL0001234, sube');
      expect(
          loadingCellSemantics(
              t105Data([
                t76Movement(
                    MovementDraft.loadFull('op', 'FULL0001234', '0030282'), 1)
              ]),
              'C:FULL0001234'),
          'OR 1 · FULL0001234, cargado');
      expect(
          loadingCellSemantics(
              t105Data([t76Movement(_cancel('C:FULL0001234'), 1)]),
              'C:FULL0001234'),
          'OR 1 · FULL0001234, cancelado');
      expect(
          loadingCellSemantics(
              t105Data([t76Movement(_load('FULL0001234', '0031082'), 1)]),
              'C:FULL0001234'),
          'OR 1 · FULL0001234, revisar');
    });

    test('sin listado, el número solo', () {
      final operation = LoadingOperation.build(
          operationId: 'op', loading: t76Loading, movements: const []);
      expect(loadingCellSemantics(operation, 'C:FULL0005678'),
          'FULL0005678, sube');
    });

    test('una reserva: su posición, su grupo o su vacío', () {
      final free = loadingCellSemantics(t105Data(), 'R:0050282');
      expect(free, startsWith('Reserva 005 02 82'));
      expect(free, endsWith(', sube'));
      expect(free, isNot(contains('\n')));
      expect(free, isNot(contains('R:')));
      expect(
          loadingCellSemantics(
              t105Data([
                t76Movement(_assign('0050282', 'EMPTY0000012', 12), 1)
              ]),
              'R:0050282'),
          'Reserva 005 02 82 · OR 12 · EMPTY0000012, cargada');
    });
  });

  for (final scale in [1.0, 1.45]) {
    testWidgets(
        'T-107 Carga a 360×780 dp con letra $scale: las celdas se leen como '
        'las ve el planner y el avance dice «re‑estibas» entera',
        (tester) async {
      final semantics = tester.ensureSemantics();
      await _loading(tester, scale);
      // Solo la etiqueta, sin el OR y la marca repetidos, y se puede tocar.
      expect(
          tester.getSemantics(find.bySemanticsLabel('OR 1 · FULL0001234, sube')),
          matchesSemantics(
              label: 'OR 1 · FULL0001234, sube',
              isButton: true,
              hasTapAction: true));
      expect(find.bySemanticsLabel(RegExp('[CR]:')), findsNothing);
      await _openActions(tester);
      await tester.tap(find.byKey(const ValueKey('operation-progress-button')));
      await tester.pumpAndSettle();
      expect(find.byType(OperationProgressPage), findsOneWidget);
      expect(find.textContaining('Las re‑estibas se muestran aparte.'),
          findsOneWidget);
      expect(_unbroken(tester), greaterThan(0));
      expect(tester.takeException(), isNull);
      semantics.dispose();
    });

    testWidgets(
        'T-107 Descarga a 360×780 dp con letra $scale: el resumen y la tabla '
        'dicen «re‑estibas» con U+2011 y sin partirse', (tester) async {
      await _discharge(tester, scale);
      expect(
          tester
              .widget<Text>(
                  find.byKey(const ValueKey('operation-discharge-totals')))
              .data,
          endsWith('0 re‑estibas'));
      await _openActions(tester);
      await tester.tap(find.byKey(const ValueKey('discharge-table-button')));
      await tester.pumpAndSettle();
      expect(
          tester
              .widget<Text>(
                  find.byKey(const ValueKey('operation-discharge-table-totals')))
              .data,
          endsWith('0 re‑estibas'));
      expect(find.text('Re‑est.'), findsOneWidget);
      // La tabla, el resumen recogido y la explicación de la columna.
      expect(_unbroken(tester), greaterThanOrEqualTo(4));
      expect(tester.takeException(), isNull);
    });
  }
}
