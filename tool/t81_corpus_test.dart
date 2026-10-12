import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/data/services/export_list_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/session_repository.dart';
import 'package:baystream/features/vessel/domain/services/change_requests.dart';
import 'package:baystream/features/vessel/domain/services/export_list_cross_checker.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';
import 'package:baystream/features/vessel/domain/services/operation_progress.dart';
import 'package:flutter_test/flutter_test.dart';

/// Lee las fuentes externas; no crea almacenes ni copia datos al repositorio.
void main() {
  const corpus = String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');
  const office = Operator(
      uid: 'test-office', name: 'Oficina prueba', role: OperatorRole.office);
  const service = ChangeRequests();
  for (final name in ['A08', 'A08v_VGM']) {
    test('T-81 $name: OR 5 cancelado, OR 1 movido y annul, en tres órdenes',
        () {
      expect(corpus, isNotEmpty);
      final parsed = BaplieParserService()
          .parse(File('$corpus/CORPUS_$name.edi').readAsStringSync());
      final loading = parsed.withGeometry(
          VesselProfile.proposeFrom(parsed).geometry,
          portOfCall: 'GTSTC');
      final raw = const ExportListParserService().parseXlsx(
          File('$corpus/LISTADO_A08.xlsx').readAsBytesSync(),
          fileName: 'LISTADO_A08.xlsx');
      final list = raw.normalized(ExportListCrossChecker.tableOf(
          ExportListCrossChecker.propose(raw, loading, portOfCall: 'GTSTC')
              .map((p) => p.kind == EquivalenceKind.type && p.listCode == '40RF'
                  ? p.choose('45R1')
                  : p)
              .toList()));
      final events =
          ((jsonDecode(File('$corpus/CASO_A08_EVENTOS.json').readAsStringSync())
                  as Map)['eventos'] as List)
              .cast<Map<String, dynamic>>();
      final expected = {
        for (final row in File('$corpus/CASO_A08_ESTADO_FINAL.csv')
            .readAsLinesSync()
            .skip(1)
            .where((l) => l.trim().isNotEmpty)
            .map((l) => l.split(',')))
          row[0]: row[1]
      };
      final operation = Operation(
          id: 'op',
          vesselName: loading.vessel.name,
          voyageNumber: loading.voyageNumber,
          portOfCall: 'GTSTC',
          createdAt: DateTime.utc(2026),
          published: true);
      var sequence = 0;
      Movement record(MovementDraft draft) => Movement(
          id: 't81-${++sequence}',
          operationId: 'op',
          type: draft.type,
          target: draft.target,
          payload: draft.payload,
          author: office.author,
          deviceId: 't81',
          sequence: sequence,
          createdAt:
              DateTime.utc(2026, 10, 11).add(Duration(seconds: sequence)));
      LoadingOperation derive(Iterable<Movement> moves) =>
          LoadingOperation.build(
              operationId: 'op',
              loading: loading,
              list: list,
              movements: moves);
      final initial = derive([]);
      expect(initial.progress.total, 176);
      final first = initial.numbered(list.byOrder(1)!)!;
      final fifth = initial.numbered(list.byOrder(5)!)!;
      String? destination;
      for (final bay in loading.bays.keys) {
        for (final row in loading.geometry!.orderedRows) {
          for (final tier in [
            ...loading.geometry!.holdTiers,
            ...loading.geometry!.deckTiers
          ]) {
            final cell =
                '${bay.toString().padLeft(3, '0')}${row.toString().padLeft(2, '0')}${tier.toString().padLeft(2, '0')}';
            try {
              service.move(
                  operation,
                  office,
                  initial,
                  [PositionChange(first.key, first.plannedPosition, cell)],
                  'Celda libre compatible');
              destination = cell;
              break;
            } on StateError {/* Se elige únicamente una celda válida. */}
          }
          if (destination != null) break;
        }
        if (destination != null) break;
      }
      expect(destination, isNotNull);
      final moved = record(service.move(
          operation,
          office,
          initial,
          [PositionChange(first.key, first.plannedPosition, destination!)],
          'Celda libre compatible'));
      final cancelled = record(
          service.cancel(operation, office, initial, fifth.key, 'No embarca'));
      final edited = derive([moved, cancelled]);
      expect(edited.progress.total, 175);
      expect(OperationProgress.build(edited).total.cancelled, 1);
      expect(edited.check(list.byOrder(5)!, fifth.plannedPosition).blocked,
          isTrue);
      final undoMove = record(service.undo(
          operation, office, edited, first.key, moved.id, 'Restaurar plan'));
      final undoCancel = record(service.undo(
          operation, office, edited, fifth.key, cancelled.id, 'Sí embarca'));
      final swap = events.firstWhere((e) => e['tipo'] == 'cambio_de_posicion');
      final changes = [
        for (final order in (swap['ordenes'] as List).cast<int>())
          PositionChange('C:${list.byOrder(order)!.containerId}',
              swap['plan']['$order'], swap['nuevo']['$order'])
      ];
      final interchange = record(service.move(
          operation, office, initial, changes, 'Intercambio del caso 128-145'));
      for (final restored in [false, true]) {
        final history = [
          moved,
          cancelled,
          if (restored) ...[undoMove, undoCancel],
          interchange
        ];
        Movement? movedLoad;
        for (final event
            in events.where((e) => e['tipo'] != 'cambio_de_posicion')) {
          if (!restored && event['orden'] == 5) continue;
          final cell = !restored && event['orden'] == 1
              ? destination
              : (event['posicion'] ?? event['celda']) as String;
          final draft = event['tipo'] == 'asignar_vacio' &&
                  initial.plan.loading.containsKey('R:$cell')
              ? MovementDraft.assignEmpty('op', cell, event['contenedor'],
                  (event['tara_kg'] as num).toDouble(), order: event['orden'])
              : MovementDraft.loadFull('op', event['contenedor'], cell,
                  order: event['orden']);
          final movement = record(draft);
          if (event['orden'] == 1) movedLoad = movement;
          history.add(movement);
        }
        final target = {...expected};
        if (!restored) {
          target.remove(fifth.plannedPosition);
          target.remove(first.plannedPosition);
          target[destination] = first.container!.containerId;
        }
        for (final order in [
          history,
          history.reversed.toList(),
          [...history]..shuffle(Random(81))
        ]) {
          final finalState = derive(order);
          expect(finalState.state.occupancy, target);
          expect(finalState.state.conflicts, isEmpty);
          expect(finalState.progress.total, 0);
          expect(OperationProgress.build(finalState).total.cancelled,
              restored ? 0 : 1);
        }
        if (!restored) {
          // Deshacer después de cargar cambia el plan, no mueve físicamente la
          // carga: la oficina ve ese fuera de plan y el muelle lo corrige.
          final afterUndo = derive([...history, undoMove, undoCancel]);
          expect(afterUndo.progress.total, 1);
          expect(afterUndo.state.conflicts.single.kind, ConflictKind.outOfPlan);
          final correction = record(MovementDraft.loadFull(
              'op', first.container!.containerId, first.plannedPosition,
              order: 1,
              corrects: movedLoad!.id,
              reason: 'Vuelve a su posición original'));
          final recovered = [
            ...history,
            undoMove,
            undoCancel,
            correction,
            record(afterUndo.draft(list.byOrder(5)!, fifth.plannedPosition))
          ];
          for (final order in [
            recovered,
            recovered.reversed.toList(),
            [...recovered]..shuffle(Random(182))
          ]) {
            expect(derive(order).state.occupancy, expected);
            expect(derive(order).state.conflicts, isEmpty);
          }
        }
      }
      stdout.writeln(
          'T-81 $name: cancelar OR 5 -> 175 pendientes y 459 posiciones al final; OR 1 en celda libre sin conflicto; annul previo a cargar -> 460/460; recuperación posterior con corrects -> 460/460; tres órdenes iguales.');
    });
  }
}
