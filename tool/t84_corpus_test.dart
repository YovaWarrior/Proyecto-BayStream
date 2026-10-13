import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/data/services/export_list_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/export_list_cross_checker.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';
import 'package:baystream/features/vessel/domain/services/operation_progress.dart';
import 'package:flutter_test/flutter_test.dart';

/// Corpus externo de solo lectura; sin copiar fuentes ni crear salidas.
void main() {
  const corpus = String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');
  for (final name in ['A08', 'A08v_VGM']) {
    test(
        'T-84 $name: tapas PROVISIONALES, 460/460 y avance por prefijo en tres órdenes',
        () {
      final parser = BaplieParserService();
      final arrival = parser
          .parse(File('$corpus/CORPUS_A07.edi').readAsStringSync())
          .copyWith(portOfCall: 'GTSTC');
      final rawLoading =
          parser.parse(File('$corpus/CORPUS_$name.edi').readAsStringSync());
      final geometry = VesselGeometry.proposeFrom(
          [...arrival.stowagePositions, ...rawLoading.stowagePositions]);
      final loading = rawLoading.withGeometry(geometry, portOfCall: 'GTSTC');
      final raw = const ExportListParserService().parseXlsx(
          File('$corpus/LISTADO_A08.xlsx').readAsBytesSync(),
          fileName: 'LISTADO_A08.xlsx');
      final list = raw.normalized(ExportListCrossChecker.tableOf(
          ExportListCrossChecker.propose(raw, loading, portOfCall: 'GTSTC')
              .map((p) => p.kind == EquivalenceKind.type && p.listCode == '40RF'
                  ? p.choose('45R1')
                  : p)
              .toList()));
      final bays = {
        ...observedHoldBays(arrival, geometry),
        ...observedHoldBays(loading, geometry)
      }.toList()
        ..sort();
      final rows = geometry.orderedRows
          .where((r) => r != 0 || geometry.centerRowInHold != false)
          .toList();
      // Distribución de prueba: no se atribuye al buque del caso.
      final declarations = {
        for (var i = 0; i < bays.length; i++)
          bays[i]: HatchCoverDeclaration(
              kind: i.isEven ? HatchCoverKind.crane : HatchCoverKind.automatic,
              covers: i.isEven
                  ? [
                      rows.take(4).toSet(),
                      rows.skip(4).take(4).toSet(),
                      rows.skip(8).toSet()
                    ]
                  : [rows.toSet()])
      };
      final events =
          ((jsonDecode(File('$corpus/CASO_A08_EVENTOS.json').readAsStringSync())
                  as Map)['eventos'] as List)
              .cast<Map<String, dynamic>>();
      final drafts = <MovementDraft>[];
      for (final e in events) {
        if (e['tipo'] == 'cambio_de_posicion') {
          drafts.add(MovementDraft.changePosition(
              't84',
              [
                for (final n in (e['ordenes'] as List).cast<int>())
                  PositionChange('C:${list.byOrder(n)!.containerId}',
                      e['plan']['$n'], e['nuevo']['$n'])
              ],
              'Intercambio del caso'));
        } else {
          final pos = (e['posicion'] ?? e['celda']) as String;
          drafts.add(e['tipo'] == 'asignar_vacio' &&
                  loading.reservedSlots.any((s) => s.key == 'R:$pos')
              ? MovementDraft.assignEmpty(
                  't84', pos, e['contenedor'], (e['tara_kg'] as num).toDouble(),
                  order: e['orden'])
              : MovementDraft.loadFull('t84', e['contenedor'], pos,
                  order: e['orden']));
        }
      }
      drafts.addAll([
        for (final c
            in arrival.containers.where((c) => c.portOfDischarge == 'GTSTC'))
          MovementDraft.discharge(
              't84', c.containerId, c.stowagePosition!.toIsoCode())
      ]);
      final expected = {
        for (final r in File('$corpus/CASO_A08_ESTADO_FINAL.csv')
            .readAsLinesSync()
            .skip(1)
            .where((r) => r.isNotEmpty)
            .map((r) => r.split(',')))
          r[0]: r[1]
      };
      LoadingOperation derive(Iterable<Movement> moves) =>
          LoadingOperation.build(
              operationId: 't84',
              arrival: arrival,
              loading: loading,
              list: list,
              hatchCovers: declarations,
              movements: moves);
      var sequence = 0;
      Movement record(MovementDraft d) => Movement(
          id: 't84-${++sequence}',
          operationId: 't84',
          type: d.type,
          target: d.target,
          payload: d.payload,
          author: const MovementAuthor(
              name: 'Prueba T-84', role: OperatorRole.office),
          deviceId: 't84',
          sequence: sequence,
          createdAt:
              DateTime.utc(2026, 10, 12).add(Duration(seconds: sequence)));
      final changes = drafts
          .where((d) => d.type == MovementType.changePosition)
          .map(record)
          .toList();
      final working = <int, List<MovementDraft>>{};
      for (final d
          in drafts.where((d) => d.type != MovementType.changePosition)) {
        final at = d.payload['position'] as String? ?? d.target!.substring(2);
        final bay = int.parse(at.substring(0, 3));
        working.putIfAbsent(bay, () => []).add(d);
      }
      // Tres órdenes reales de trabajo por bahía, además de tres entregas de cada bitácora.
      final workBays = working.keys.toList()..sort();
      for (final order in [
        workBays,
        workBays.reversed.toList(),
        [...workBays]..shuffle(Random(84))
      ]) {
        final history = [...changes];
        final removed = <String>{};
        final replaced = <String>{};
        void check() {
          final operation = derive(history);
          final progress = OperationProgress.build(operation);
          expect(progress.total.coversDeclared,
              declarations.values.fold<int>(0, (n, d) => n + d.covers.length));
          expect(progress.total.coversRemoved, removed.length);
          expect(progress.total.coversReplaced, replaced.length);
          for (final row in progress.bays) {
            final covers = operation.state.hatchCovers.values
                .where((c) => operation.displayBay(c.bay) == row.bay);
            expect(row.coversDeclared, covers.length);
            expect(row.coversRemoved,
                covers.where((c) => removed.contains(c.key)).length);
            expect(row.coversReplaced,
                covers.where((c) => replaced.contains(c.key)).length);
          }
        }

        for (final bay in order) {
          final declaration = declarations[bay];
          for (var n = 1; n <= (declaration?.covers.length ?? 0); n++) {
            final before = derive(history).state.occupancy;
            history.add(
                record(MovementDraft.hatchCover('t84', bay, n, remove: true)));
            removed.add('T:$bay-$n');
            expect(derive(history).state.occupancy, before);
            check();
          }
          for (final draft in working[bay]!) {
            history.add(record(draft));
            check();
          }
          for (var n = 1; n <= (declaration?.covers.length ?? 0); n++) {
            final before = derive(history).state.occupancy;
            history.add(
                record(MovementDraft.hatchCover('t84', bay, n, remove: false)));
            removed.remove('T:$bay-$n');
            replaced.add('T:$bay-$n');
            expect(derive(history).state.occupancy, before);
            check();
          }
        }
        for (final delivery in [
          history,
          history.reversed.toList(),
          [...history]..shuffle(Random(184))
        ]) {
          final operation = derive(delivery);
          expect(operation.state.occupancy, expected);
          expect(operation.state.occupancy, hasLength(460));
          expect(operation.state.conflicts, isEmpty);
          expect(operation.progress.total, 0);
          expect(operation.discharge.pending, 0);
        }
      }
      stdout.writeln(
          'T-84 $name: 460/460; ${bays.length} bahías con tapas PROVISIONALES; tres órdenes de trabajo y tres de llegada; avance cotejado en cada paso.');
    }, timeout: const Timeout(Duration(minutes: 3)));
  }
}
