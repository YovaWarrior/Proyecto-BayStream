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
import 'package:flutter_test/flutter_test.dart';

/// Solo lee el corpus externo. No crea fuentes, almacenes ni temporales.
void main() {
  const corpus = String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');
  for (final name in ['A08', 'A08v_VGM']) {
    for (final approved in [true, false]) {
      test(
          'T-80 $name: ${approved ? 'aprobación en tres órdenes y T-77' : 'rechazo conserva dos fuera de plan'}',
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
                .map((p) =>
                    p.kind == EquivalenceKind.type && p.listCode == '40RF'
                        ? p.choose('45R1')
                        : p)
                .toList()));
        final events = ((jsonDecode(
                    File('$corpus/CASO_A08_EVENTOS.json').readAsStringSync())
                as Map)['eventos'] as List)
            .cast<Map<String, dynamic>>();
        expect(events, hasLength(177));
        var sequence = 0;
        Movement move(MovementDraft d, {bool office = false}) {
          sequence++;
          return Movement(
              id: 't80-$sequence',
              operationId: 'op',
              type: d.type,
              target: d.target,
              payload: d.payload,
              author: MovementAuthor(
                  name: office ? 'Oficina prueba' : 'Muelle prueba',
                  role: office ? OperatorRole.office : OperatorRole.dock),
              deviceId: 't80',
              sequence: sequence,
              createdAt:
                  DateTime.utc(2026, 10, 11).add(Duration(seconds: sequence)));
        }

        final initial = LoadingOperation.build(
            operationId: 'op', loading: loading, list: list);
        final change =
            events.firstWhere((e) => e['tipo'] == 'cambio_de_posicion');
        final batch = [
          for (final order in (change['ordenes'] as List).cast<int>())
            PositionChange('C:${list.byOrder(order)!.containerId}',
                change['plan']['$order'], change['nuevo']['$order'])
        ];
        final operation = Operation(
            id: 'op',
            vesselName: loading.vessel.name,
            voyageNumber: loading.voyageNumber,
            portOfCall: 'GTSTC',
            createdAt: DateTime.utc(2026),
            published: true);
        final request = move(const ChangeRequests().request(
            operation,
            const Operator(
                uid: 'prueba-muelle',
                name: 'Muelle prueba',
                role: OperatorRole.dock),
            initial,
            batch,
            'Intercambio 128 y 145'));
        final loads = <Movement>[];
        for (final event
            in events.where((e) => e['tipo'] != 'cambio_de_posicion')) {
          final position = (event['posicion'] ?? event['celda']) as String;
          loads.add(move(event['tipo'] == 'asignar_vacio' &&
                  initial.plan.loading.containsKey('R:$position')
              ? MovementDraft.assignEmpty('op', position, event['contenedor'],
                  (event['tara_kg'] as num).toDouble(), order: event['orden'])
              : MovementDraft.loadFull('op', event['contenedor'], position,
                  order: event['orden'])));
        }
        // La decisión se registra DESPUÉS de las 176 cargas. También llega
        // primero, última o mezclada: ningún orden de llegada cambia el resultado.
        final beforeDecision = LoadingOperation.build(
            operationId: 'op',
            loading: loading,
            list: list,
            movements: [request, ...loads]);
        final decision = move(
            const ChangeRequests().decide(
                operation,
                const Operator(
                    uid: 'prueba-oficina',
                    name: 'Oficina prueba',
                    role: OperatorRole.office),
                beforeDecision,
                request.id,
                approved ? 'Aprobado por oficina' : 'No procede',
                approve: approved),
            office: true);
        final chronological = [request, ...loads, decision];
        final mixed = [...chronological]..shuffle(Random(80));
        final expected = {
          for (final row in File('$corpus/CASO_A08_ESTADO_FINAL.csv')
              .readAsLinesSync()
              .skip(1)
              .where((l) => l.trim().isNotEmpty)
              .map((l) => l.split(',')))
            row[0]: row[1]
        };
        expect(expected, hasLength(460));
        for (final order in [
          chronological,
          chronological.reversed.toList(),
          mixed
        ]) {
          final derived = LoadingOperation.build(
              operationId: 'op',
              loading: loading,
              list: list,
              movements: order);
          expect(derived.state.occupancy, expected);
          expect(derived.progress.total, 0);
          expect(derived.state.notDerived, isEmpty);
          expect(
              derived.state.requests.single.status,
              approved
                  ? ChangeRequestStatus.approved
                  : ChangeRequestStatus.rejected);
          if (approved) {
            expect(derived.state.conflicts, isEmpty);
          } else {
            expect(derived.state.conflicts, hasLength(2));
            expect(derived.state.conflicts.map((c) => c.kind),
                everyElement(ConflictKind.outOfPlan));
          }
        }
        if (approved) {
          final replay = <Movement>[request, decision];
          for (final event
              in events.where((e) => e['tipo'] != 'cambio_de_posicion')) {
            final data = LoadingOperation.build(
                operationId: 'op',
                loading: loading,
                list: list,
                movements: replay);
            final row = list.byOrder(event['orden'])!;
            final position = (event['posicion'] ?? event['celda']) as String;
            expect(data.check(row, position).issues, isEmpty);
            replay.add(move(data.draft(row, position)));
          }
        }
        stdout.writeln(
            'T-80 $name: 177 eventos + decisión; 460/460 posiciones en tres órdenes; ${approved ? 0 : 2} conflictos; ${approved ? 'T-77 sin avisos en las 176 cargas' : 'rechazo conserva el plan publicado'}.');
      });
    }
  }
}
