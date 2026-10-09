import 'dart:convert';
import 'dart:io';
import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/data/services/export_list_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/export_list_cross_checker.dart';
import 'package:baystream/features/vessel/domain/services/load_check.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';
import 'package:baystream/features/vessel/domain/services/operation_progress.dart';
import 'package:flutter_test/flutter_test.dart';

/// Corpus privado: solo lecturas externas y cálculo en memoria. Ninguna salida
/// ni dato del caso se escribe en el repositorio.
void main() {
  const corpus = String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');
  for (final name in ['A08', 'A08v_VGM']) {
    for (final order in [
      'cargas primero',
      'descargas primero',
      'intercalados'
    ]) {
      test('T-78 $name / $order: 290 pasos contra bitácora independiente', () {
        expect(corpus, isNotEmpty);
        VesselVoyage read(String file) {
          final raw = BaplieParserService()
              .parse(File('$corpus/CORPUS_$file.edi').readAsStringSync());
          return raw.withGeometry(
              VesselProfile.proposeFrom(raw)
                  .geometry
                  .copyWith(stackWeightLimitKg: 90000),
              portOfCall: 'GTSTC');
        }

        final arrival = read('A07');
        final loading = read(name);
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
        final rawEvents = ((jsonDecode(
                    File('$corpus/CASO_A08_EVENTOS.json').readAsStringSync())
                as Map)['eventos'] as List)
            .cast<Map<String, dynamic>>();
        final reserves = {
          for (final r in loading.reservedSlots) r.stowagePosition.toIsoCode()
        };
        final loads = <MovementDraft>[
          for (final e in rawEvents)
            if (e['tipo'] != 'cambio_de_posicion')
              e['tipo'] == 'asignar_vacio' && reserves.contains(e['celda'])
                  ? MovementDraft.assignEmpty('op', e['celda'], e['contenedor'],
                      (e['tara_kg'] as num).toDouble(), order: e['orden'])
                  : MovementDraft.loadFull('op', e['contenedor'],
                      (e['posicion'] ?? e['celda']) as String,
                      order: e['orden'])
        ];
        final discharges = [
          for (final c in arrival.containers)
            if (c.portOfDischarge == 'GTSTC')
              MovementDraft.discharge(
                  'op', c.containerId, c.stowagePosition!.toIsoCode())
        ];
        expect((loads.length, discharges.length), (176, 114));
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
        final records = <Movement>[];
        OperationProgress projection() =>
            OperationProgress.build(LoadingOperation.build(
                arrival: arrival,
                loading: loading,
                list: list,
                movements: records));
        final initial = projection().total;
        expect(vector(initial), [66, 48, 0, 120, 56, 0, 0, 0, 0, 0]);
        for (var i = 0; i < drafts.length; i++) {
          final d = drafts[i];
          records.add(Movement(
              id: 'event-$i',
              operationId: 'op',
              type: d.type,
              target: d.target,
              payload: d.payload,
              author: const MovementAuthor(
                  name: 'Aceptación T78', role: OperatorRole.dock),
              deviceId: 't78',
              sequence: i,
              createdAt: DateTime.utc(2026, 1, 1).add(Duration(minutes: i))));
          final data = projection();
          final expected = independent(arrival, loading, list, records);
          expect(vector(data.total), expected[0],
              reason: '$name / $order / paso ${i + 1} / total');
          final actual = {for (final bay in data.bays) bay.bay: vector(bay)};
          // Las filas sin operación pueden seguir mostrando el último movimiento.
          for (final bay in {...actual.keys, ...expected.keys}..remove(0)) {
            expect(actual[bay] ?? List.filled(10, 0),
                expected[bay] ?? List.filled(10, 0),
                reason: '$name / $order / paso ${i + 1} / bahía $bay');
          }
          expect(data.last!.id, records.last.id);
        }
        final finalData = projection();
        expect(vector(finalData.total), [0, 0, 114, 0, 0, 120, 56, 0, 0, 2]);
        expect(finalData.conflicts.map((c) => c.position).toSet(),
            {'0140102', '0140108'});
        final stack = finalData.stacks
            .singleWhere((s) => s.bay == 14 && s.row == 1 && !s.deck);
        expect(stack.status, StackWeightStatus.exceeded);
        expect(stack.knownKg, greaterThan(90000));
        stdout.writeln(
            'T-78 $name / $order: 290/290 pasos, totales y bahías iguales; '
            '114/120/56 hechos; 0 pendientes; 2 conflictos; pila 014-01 bodega '
            '${stack.knownKg.toStringAsFixed(0)} kg > 90000 kg.');
      });
    }
  }
}

List<int> vector(BayOperationProgress b) => [
      b.dischargeDeck.pending,
      b.dischargeHold.pending,
      b.discharged,
      b.fullPending,
      b.emptyPending,
      b.fullLoaded,
      b.emptyLoaded,
      b.restows,
      b.cancelled,
      b.conflicts
    ];

/// Oráculo del caso, construido con contenedores, reservas y registros crudos.
/// No usa OperationPlan, OperationState ni sus contadores/derivador. Las
/// descargas presentes liberan primero sus celdas (regla T-76), y una carga
/// retenida por ocupación sigue pendiente hasta que aparezca esa descarga.
Map<int, List<int>> independent(VesselVoyage arrival, VesselVoyage loading,
    ExportList list, List<Movement> events) {
  final outgoing = {
    for (final c in loading.containers.where((c) => c.portOfLoading == 'GTSTC'))
      'C:${c.containerId}': c
  };
  final reservations = {
    for (final r
        in loading.reservedSlots.where((r) => r.portOfLoading == 'GTSTC'))
      r.key: r
  };
  final incoming = {
    for (final c
        in arrival.containers.where((c) => c.portOfDischarge == 'GTSTC'))
      'C:${c.containerId}': c
  };
  final departed = events
      .where((m) => m.type == MovementType.discharge)
      .map((m) => m.target)
      .toSet();
  final occupied = {
    for (final c in arrival.containers)
      if (!departed.contains('C:${c.containerId}'))
        c.stowagePosition!.toIsoCode(): 'C:${c.containerId}'
  };
  final loaded = <String, String>{};
  final conflicts = <String>[];
  for (final e in events.where((e) =>
      e.type == MovementType.loadFull || e.type == MovementType.assignEmpty)) {
    final position = e.position ?? e.target!.substring(2);
    if (occupied.containsKey(position) && occupied[position] != e.target) {
      conflicts.add(position);
      continue;
    }
    loaded[e.target!] = position;
    occupied[position] = e.target!;
    if (e.type == MovementType.loadFull &&
        outgoing[e.target]!.stowagePosition!.toIsoCode() != position) {
      conflicts.add(position);
    }
  }
  final result = <int, List<int>>{0: List.filled(10, 0)};
  void count(String position, int index) {
    final c = IsoCoordinateParser.parse(position);
    final grouped =
        c.bay.isEven && loading.bays.containsKey(c.bay - 1) ? c.bay - 1 : c.bay;
    final row = result.putIfAbsent(grouped, () => List.filled(10, 0));
    row[index]++;
    result[0]![index]++;
  }

  for (final entry in incoming.entries) {
    final p = entry.value.stowagePosition!;
    count(
        p.toIsoCode(),
        departed.contains(entry.key)
            ? 2
            : loading.geometry!.isDeckTier(p.tier)
                ? 0
                : 1);
  }
  for (final entry in outgoing.entries) {
    final empty = list.byContainer(entry.value.containerId)!.isEmpty;
    count(
        loaded[entry.key] ?? entry.value.stowagePosition!.toIsoCode(),
        loaded.containsKey(entry.key)
            ? empty
                ? 6
                : 5
            : empty
                ? 4
                : 3);
  }
  for (final entry in reservations.entries) {
    count(loaded[entry.key] ?? entry.value.stowagePosition.toIsoCode(),
        loaded.containsKey(entry.key) ? 6 : 4);
  }
  for (final p in conflicts) {
    count(p, 9);
  }
  return result;
}
