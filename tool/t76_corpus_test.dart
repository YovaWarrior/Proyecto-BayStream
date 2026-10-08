import 'dart:convert';
import 'dart:io';
import 'package:baystream/features/vessel/data/datasources/hive_movement_data_source.dart';
import 'package:baystream/features/vessel/data/repositories/movement_log_repository_impl.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/data/services/export_list_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/export_list_cross_checker.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';
import 'package:flutter_test/flutter_test.dart';

/// T-76: datos y almacenes exclusivamente fuera del repositorio.
/// flutter test tool/t76_corpus_test.dart
/// --dart-define=BAYSTREAM_CORPUS_DIRECTORY=CARPETA_EXTERNA
void main() {
  const corpus = String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');
  for (final name in ['A08', 'A08v_VGM']) {
    for (final order in [
      'solo cargas',
      'cargas primero',
      'descargas primero',
      'intercalados'
    ]) {
      test('T-76 $name: $order, 460 posiciones, OR 12 y persistencia',
          () async {
        expect(corpus, isNotEmpty);
        VesselVoyage read(String name) {
          final parsed = BaplieParserService()
              .parse(File('$corpus/CORPUS_$name.edi').readAsStringSync());
          return parsed.withGeometry(VesselProfile.proposeFrom(parsed).geometry,
              portOfCall: 'GTSTC');
        }

        final loading = read(name);
        final arrival = order == 'solo cargas' ? null : read('A07');
        final rawList = const ExportListParserService().parseXlsx(
            File('$corpus/LISTADO_A08.xlsx').readAsBytesSync(),
            fileName: 'LISTADO_A08.xlsx');
        final proposals = ExportListCrossChecker.propose(rawList, loading,
                portOfCall: 'GTSTC')
            .map((p) => p.kind == EquivalenceKind.type && p.listCode == '40RF'
                ? p.choose('45R1')
                : p)
            .toList();
        expect(proposals.any((p) => p.needsUser), isFalse);
        final list =
            rawList.normalized(ExportListCrossChecker.tableOf(proposals));
        final initial = LoadingOperation.build(
            operationId: 'op', loading: loading, arrival: arrival, list: list);
        final events = ((jsonDecode(
                    File('$corpus/CASO_A08_EVENTOS.json').readAsStringSync())
                as Map)['eventos'] as List)
            .cast<Map<String, dynamic>>();
        final loads = <MovementDraft>[];
        for (final event in events) {
          if (event['tipo'] == 'cambio_de_posicion') continue;
          final position = (event['posicion'] ?? event['celda']) as String;
          loads.add(event['tipo'] == 'asignar_vacio' &&
                  initial.plan.loading.containsKey('R:$position')
              ? MovementDraft.assignEmpty('op', position, event['contenedor'],
                  (event['tara_kg'] as num).toDouble(), order: event['orden'])
              : MovementDraft.loadFull('op', event['contenedor'], position,
                  order: event['orden']));
        }
        final discharges = [
          for (final item in initial.plan.arrival.values)
            if (item.role == PlanRole.discharge)
              MovementDraft.discharge(
                  'op', item.container!.containerId, item.plannedPosition)
        ];
        expect(loads.length, 176);
        expect(discharges.length, arrival == null ? 0 : 114);
        final drafts = switch (order) {
          'descargas primero' => [...discharges, ...loads],
          'intercalados' => [
              for (var i = 0; i < loads.length; i++) ...[
                loads[loads.length - 1 - i],
                if (i < discharges.length) discharges[i]
              ]
            ],
          _ => [...loads, ...discharges],
        };
        final dir =
            await Directory.systemTemp.createTemp('baystream_t76_corpus_');
        var minute = 0;
        Future<MovementLogRepositoryImpl>
            open() async => MovementLogRepositoryImpl(
                await HiveMovementDataSource.open(
                    directory: dir.path, namespace: 't76acc'),
                clock: () =>
                    DateTime.utc(2026, 1, 1).add(Duration(minutes: minute++)));
        var log = await open();
        try {
          const author =
              MovementAuthor(name: 'Aceptación T76', role: OperatorRole.dock);
          for (final draft in drafts) {
            (await log.append(draft, author))
                .fold((failure) => fail(failure.message), (_) {});
          }
          await log.close();
          log = await open();
          final records = (await log.records('op')).getOrElse(() => []);
          expect(records.length, arrival == null ? 176 : 290);
          final finalData = LoadingOperation.build(
              operationId: 'op',
              loading: loading,
              arrival: arrival,
              list: list,
              movements: records.map((r) => r.movement));
          final expected = {
            for (final row in File('$corpus/CASO_A08_ESTADO_FINAL.csv')
                .readAsLinesSync()
                .skip(1)
                .where((line) => line.trim().isNotEmpty)
                .map((line) => line.split(',')))
              row[0]: row[1]
          };
          expect(expected.length, 460);
          expect(finalData.state.occupancy, expected);
          expect(
              finalData.state.conflicts
                  .where((c) => c.kind == ConflictKind.cellTaken),
              isEmpty);
          expect(finalData.state.conflicts.length, 2);
          expect(
              finalData.state.conflicts
                  .every((c) => c.kind == ConflictKind.outOfPlan),
              isTrue);
          expect({
            for (final s in finalData.state.items.values)
              if (s.inConflict) s.position
          }, {
            '0140102',
            '0140108'
          });
          expect(finalData.progress.total, 0);
          expect(finalData.discharge.pending, 0);
          final twelve = finalData.state['R:0030984']!;
          expect((twelve.order, twelve.tareKg, twelve.assignedContainer),
              (12, 2185, list.byOrder(12)!.containerId));
          expect(
              records.every((r) =>
                  r.movement.type == MovementType.discharge ||
                  r.movement.payload['operatedAt'] ==
                      r.movement.createdAt.toUtc().toIso8601String()),
              isTrue);
          // La UI usa el listado real: solo reservas de su grupo, sin otras.
          final row12 = list.byOrder(12)!;
          final offered = initial.slots(row12, selectedBay: 3);
          expect(offered.any((s) => s.key == 'R:0030984'), isTrue);
          expect(
              offered.every((s) =>
                  s.isoSizeType == row12.type &&
                  s.portOfDischarge == row12.pod &&
                  s.operatorCode == row12.line),
              isTrue);
          expect(initial.draft(row12, '0030984').payload['tareKg'], 2185);
          final fullRow = list.fulls.first;
          expect(initial.search('${fullRow.order}'), contains(fullRow));
          expect(
              initial.search(fullRow.containerId
                  .substring(fullRow.containerId.length - 5)),
              contains(fullRow));
          stdout.writeln(
              'T-76 $name / $order: ${records.length} registros persistidos; '
              '460 posiciones iguales al CSV; 0 celda ocupada; 2 fuera de plan del intercambio; '
              'carga y descarga pendientes 0; OR 12 en R:0030984, 2185 kg.');
        } finally {
          await log.close();
          await dir.delete(recursive: true);
        }
      });
    }
  }
}
