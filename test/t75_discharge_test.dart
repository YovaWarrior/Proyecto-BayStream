import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/discharge_progress.dart';
import 'package:baystream/features/vessel/domain/services/loading_plan_progress.dart';
import 'package:baystream/features/vessel/domain/services/operation_state_deriver.dart';
import 'package:baystream/features/vessel/presentation/providers/discharge_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/bay_plan_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/local_profile_test_support.dart';
import 'support/t75_memory_log.dart';

/// Plano de llegada sintético: emitido en HNPCR rumbo a GTSTC. Tres bajan en
/// GTSTC en la bahía 03 (dos en cubierta y uno en bodega), uno baja en la
/// bodega de la 14 y uno de 40 pies sigue a PAMIT en la cubierta de la 14.
const _arrival = "TDT+20+V01N+++NV2:172:20+++9000003:146:11:BUQUE ALFA'"
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

VesselVoyage arrival() {
  final voyage = BaplieParserService().parse(_arrival);
  return voyage.withGeometry(VesselProfile.proposeFrom(voyage).geometry,
      portOfCall: 'GTSTC');
}

Movement movement(MovementDraft draft, int sequence) => Movement(
    id: 'evento-$sequence',
    operationId: 'op',
    type: draft.type,
    target: draft.target,
    payload: draft.payload,
    author: const MovementAuthor(name: 'Prueba', role: OperatorRole.dock),
    deviceId: 'prueba',
    sequence: sequence,
    createdAt: DateTime.utc(2026, 1, 1).add(Duration(minutes: sequence)));

DischargeProgress progress(List<Movement> events) {
  final voyage = arrival();
  final plan = OperationPlan.build(
      portOfCall: 'GTSTC', arrival: voyage, geometry: voyage.geometry);
  return DischargeProgress.build(
      plan, const OperationStateDeriver().derive(plan, events),
      operationId: 'op', movements: events);
}

void main() {
  test('T-75 pendientes por bahía, cubierta y bodega, sin contar lo de paso',
      () {
    final data = progress(const []);
    expect((data.pending, data.deckPending, data.holdPending), (4, 2, 2));
    expect({
      for (final b in data.bays.values) b.label: (b.deckPending, b.holdPending)
    }, {
      '03': (2, 1),
      '14': (0, 1)
    });
    expect(data.markOf('TEST0000011'), DischargeMark.pending);
    expect(data.markOf('TEST0000015'), DischargeMark.transit);
    expect(data.markOf('NOESTA0000'), isNull);
  });

  test('T-75 marcar baja el pendiente; deshacer con annul lo devuelve', () {
    final mark =
        movement(MovementDraft.discharge('op', 'TEST0000011', '0030282'), 1);
    final undo = movement(
        MovementDraft.annul('op', mark.id, markedByMistake,
            target: mark.target),
        2);
    final marked = progress([mark]);
    expect((marked.pending, marked.discharged), (3, 1));
    expect(marked.markOf('TEST0000011'), DischargeMark.discharged);
    expect(marked.movementOf('TEST0000011')!.author.name, 'Prueba');
    final undone = progress([mark, undo]);
    expect((undone.pending, undone.discharged), (4, 0));
    expect(undone.markOf('TEST0000011'), DischargeMark.pending);
    // Anular la anulación restaura la descarga; la bitácora conserva los tres.
    final redo = movement(
        MovementDraft.annul('op', undo.id, 'Sí bajó', target: mark.target), 3);
    expect(progress([mark, undo, redo]).pending, 3);
  });

  test('T-75 re-estiba: restow true, cuenta aparte y no entre los que bajan',
      () {
    final restow = movement(
        MovementDraft.discharge('op', 'TEST0000015', '0140282',
            restow: true, reason: 'Despejar la bodega'),
        1);
    expect(restow.payload['restow'], isTrue);
    final data = progress([restow]);
    expect((data.pending, data.discharged, data.restows), (4, 0, 1));
    expect(data.forBay(14)!.deckRestows, 1);
    expect(data.markOf('TEST0000015'), DischargeMark.restowed);
    expect(data.conflicts, isEmpty);
    // Sin restow, un contenedor de paso que baja es un conflicto a la vista.
    final wrong =
        movement(MovementDraft.discharge('op', 'TEST0000015', '0140282'), 1);
    expect(progress([wrong]).markOf('TEST0000015'), DischargeMark.conflict);
    expect(progress([wrong]).conflicts.single.kind, ConflictKind.outOfPlan);
  });

  test('T-75 annul exige motivo y la descarga exige posición', () {
    expect(MovementDraft.annul('op', 'x', '  ').validate(), isNotNull);
    expect(MovementDraft.annul('op', 'x', markedByMistake).validate(), isNull);
    expect(
        MovementDraft.discharge('op', 'TEST0000011', '').validate(), isNotNull);
  });

  test('T-75 la carga de T-74 deja fuera descargas y sus anulaciones', () {
    final d = movement(MovementDraft.discharge('op', 'A', '0030282'), 1);
    final a1 = movement(MovementDraft.annul('op', d.id, 'error'), 2);
    final a2 = movement(MovementDraft.annul('op', a1.id, 'sí bajó'), 3);
    final load = movement(MovementDraft.loadFull('op', 'B', '0030284'), 4);
    final a3 = movement(MovementDraft.annul('op', load.id, 'error'), 5);
    expect(
        LoadingPlanProgress.loadingMovements([d, a1, a2, load, a3])
            .map((m) => m.id),
        [load.id, a3.id]);
  });

  test('T-75 el modo Descarga solo existe en un plano de llegada', () {
    expect(offersDischarge(arrival()), isTrue);
    expect(offersDischarge(arrival().copyWith(portOfCall: 'PAMIT')), isTrue);
    expect(offersDischarge(arrival().copyWith(portOfCall: 'HNPCR')), isFalse);
  });

  for (final brightness in Brightness.values) {
    testWidgets('T-75 Descarga a 360 dp, tema ${brightness.name}',
        (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final voyage = arrival();
      final log = T75MemoryLog();
      await log.saveOperation(Operation(
          id: 'op-t75',
          vesselName: voyage.vessel.name,
          voyageNumber: voyage.voyageNumber,
          portOfCall: 'GTSTC',
          createdAt: DateTime.utc(2026, 10, 7)));
      final scope = ProviderContainer(overrides: [
        movementLogRepositoryProvider.overrideWith((ref) async => log),
        vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
      ]);
      addTearDown(scope.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
          container: scope,
          child: MaterialApp(
              theme: ThemeData(brightness: brightness, useMaterial3: true),
              home: Scaffold(body: BayPlanView(voyage: voyage)))));
      await tester.pumpAndSettle();
      // El detalle tiene filas previas a T-75 que con la fuente de prueba
      // (cada letra es un cuadrado) no caben en 360: se abre en ancho de
      // escritorio y a 360 dp se mira en el Honor, con la fuente real.
      void wide(bool on) =>
          tester.view.physicalSize = Size(on ? 900 : 360, 800);
      String summary() => tester
          .widget<Text>(find.byKey(const ValueKey('bay-discharge-pending')))
          .data!;

      // Fuera del modo, tocar abre el detalle: no registra nada.
      wide(true);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('cell-2-82')));
      await tester.pumpAndSettle();
      expect(find.text('Cerrar'), findsOneWidget);
      expect(find.textContaining('En GTSTC: por descargar'), findsOneWidget);
      await tester.tap(find.text('Cerrar'));
      await tester.pumpAndSettle();
      expect(log.of('op-t75'), isEmpty);
      wide(false);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('bay-plan-display-mode')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Descarga').last);
      await tester.pumpAndSettle();
      expect(summary(), contains('cubierta 2 · bodega 1 · descargados 0'));
      expect(find.byKey(const ValueKey('discharge-pending')), findsNWidgets(3));
      expect(find.text('BAJA'), findsNWidgets(3));

      // Un toque marca; el «Deshacer» inmediato lo anula con motivo.
      await tester.tap(find.byKey(const ValueKey('cell-2-82')));
      await tester.pumpAndSettle();
      expect(summary(), contains('cubierta 1 · bodega 1 · descargados 1'));
      expect(find.text('DESC.'), findsOneWidget);
      expect(find.textContaining('Descargado · TEST0000011'), findsOneWidget);
      await tester.tap(find.text('Deshacer'));
      await tester.pumpAndSettle();
      expect(summary(), contains('cubierta 2 · bodega 1 · descargados 0'));
      final undo = log.of('op-t75').last.movement;
      expect((undo.type, undo.reason), (MovementType.annul, markedByMistake));

      // Más tarde, desde el detalle, con quién y cuándo y texto libre.
      await tester.tap(find.byKey(const ValueKey('cell-2-82')));
      await tester.pumpAndSettle();
      expect(find.text('DESC.'), findsOneWidget);
      wide(true);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('cell-2-82')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('discharge-detail')), findsOneWidget);
      expect(find.textContaining('Muelle (sin cuenta)'), findsOneWidget);
      expect(find.textContaining('En GTSTC: descargado'), findsOneWidget);
      await tester
          .ensureVisible(find.byKey(const ValueKey('discharge-undo-detail')));
      await tester.tap(find.byKey(const ValueKey('discharge-undo-detail')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('annul-with-reason')), findsOneWidget);
      await tester.enterText(
          find.byKey(const ValueKey('annul-reason')), 'Era la de al lado');
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('annul-with-reason')));
      await tester.pumpAndSettle();
      expect(log.of('op-t75').last.movement.reason, 'Era la de al lado');
      await tester.tap(find.text('Cerrar'));
      await tester.pumpAndSettle();
      wide(false);
      await tester.pumpAndSettle();
      expect(summary(), contains('cubierta 2 · bodega 1 · descargados 0'));

      // Una celda vacía no registra nada en el modo Descarga.
      final before = log.of('op-t75').length;
      await tester.tap(find.byKey(const ValueKey('cell-0-82')),
          warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(log.of('op-t75'), hasLength(before));

      // Bahía 14: el de paso pide confirmar la re-estiba.
      scope.read(selectedBayProvider.notifier).select(14);
      await tester.pumpAndSettle();
      expect(summary(), contains('cubierta 0 · bodega 1 · descargados 0'));
      expect(find.text('PASO'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('cell-2-82')));
      await tester.pumpAndSettle();
      expect(find.textContaining('no se descarga en GTSTC'), findsOneWidget);
      await tester.enterText(
          find.byKey(const ValueKey('restow-reason')), 'Despejar la bodega');
      await tester.tap(find.byKey(const ValueKey('confirm-restow')));
      await tester.pumpAndSettle();
      final restow = log.of('op-t75').last.movement;
      expect((restow.type, restow.payload['restow'], restow.reason),
          (MovementType.discharge, true, 'Despejar la bodega'));
      expect(summary(), contains('re-estibas 1'));
      expect(find.text('RE-EST.'), findsOneWidget);
      expect(
          tester
              .widget<Text>(
                  find.byKey(const ValueKey('operation-discharge-totals')))
              .data,
          contains(
              '4 por descargar (2 cub. / 2 bod.) · 0 descargados · 1 re-estibas'));

      // La tabla de la operación.
      await tester.tap(find.byKey(const ValueKey('discharge-table-button')));
      await tester.pumpAndSettle();
      expect(find.textContaining('2 bahías · 4 pendientes'), findsOneWidget);
      expect(find.text('Re-est.'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
