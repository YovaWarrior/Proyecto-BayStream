import 'dart:convert';
import 'dart:io';

import 'package:baystream/features/vessel/data/datasources/hive_movement_data_source.dart';
import 'package:baystream/features/vessel/data/repositories/movement_log_repository_impl.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/operation_state_deriver.dart';
import 'package:flutter_test/flutter_test.dart';

/// T-72 · Aceptación contra el caso real anonimizado (SPRINT-3 T-72, decisión
/// de Carlos del 7-oct): reproducir CASO_A08_EVENTOS.json sin el intercambio
/// 128 ↔ 145, que deriva T-80. Las 460 posiciones de CASO_A08_ESTADO_FINAL.csv
/// salen igual, y 014-01-02 y 014-01-08 quedan en conflicto «fuera de plan».
/// Uso: flutter test tool/t72_corpus_test.dart
///        --dart-define=BAYSTREAM_CORPUS_DIRECTORY=CARPETA_DEL_CORPUS
void main() {
  const corpus = String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');
  const author = MovementAuthor(name: 'Tarjador (reproducción)', role: OperatorRole.dock);

  // Sección 2 de docs/S3-CASO-MAGELLAN-STAR.md: movimientos por bahía del papel.
  const expectedByBay = {
    '03': (deck: 5, hold: 0),
    '05/06': (deck: 26, hold: 26),
    '07': (deck: 0, hold: 11),
    '13/14': (deck: 14, hold: 18),
    '15': (deck: 0, hold: 4),
    '22': (deck: 6, hold: 16),
    '25/26': (deck: 13, hold: 17),
    '27': (deck: 0, hold: 2),
    '29/30': (deck: 18, hold: 0),
  };

  for (final name in ['A08', 'A08v_VGM']) {
    test('T-72 $name: los 176 eventos dejan las 460 posiciones del estado final', () async {
      expect(corpus, isNotEmpty, reason: 'Indica el directorio del corpus real');
      final loading =
          BaplieParserService().parse(File('$corpus/CORPUS_$name.edi').readAsStringSync());
      final geometry = VesselProfile.proposeFrom(loading).geometry;
      final plan = OperationPlan.build(portOfCall: 'GTSTC', loading: loading, geometry: geometry);
      final events = ((jsonDecode(File('$corpus/CASO_A08_EVENTOS.json').readAsStringSync())
              as Map<String, dynamic>)['eventos'] as List)
          .cast<Map<String, dynamic>>();

      // T-75: el almacén temporal lleva contenido del corpus; vive en el
      // directorio temporal del sistema, nunca en el build/ del repositorio.
      final directory = await Directory.systemTemp.createTemp('baystream_t72_caso_');
      final namespace = 't72_corpus_${DateTime.now().microsecondsSinceEpoch}';
      var minute = 0;
      DateTime clock() => DateTime.utc(2025, 10, 4, 8).add(Duration(minutes: minute++));
      Future<MovementLogRepositoryImpl> open() async => MovementLogRepositoryImpl(
          await HiveMovementDataSource.open(directory: directory.path, namespace: namespace),
          clock: clock);

      var repository = await open();
      var skipped = 0;
      var emptyWithNumber = 0;
      try {
        await repository.saveOperation(Operation(
          id: 'caso-a08',
          vesselName: loading.vessel.name,
          voyageNumber: loading.voyageNumber,
          portOfCall: 'GTSTC',
          createdAt: DateTime.utc(2025, 10, 4),
        ));
        for (final e in events) {
          final MovementDraft draft;
          switch (e['tipo']) {
            case 'confirmar_lleno':
              draft = MovementDraft.loadFull('caso-a08', e['contenedor'] as String,
                  e['posicion'] as String, order: e['orden'] as int);
            case 'asignar_vacio':
              final cell = e['celda'] as String;
              final container = e['contenedor'] as String;
              if (plan.loading.containsKey('R:$cell')) {
                draft = MovementDraft.assignEmpty('caso-a08', cell, container,
                    (e['tara_kg'] as num).toDouble(), order: e['orden'] as int);
              } else {
                // Orden 85: el vacío ya viene con número en el plan (006-02-04),
                // así que no es una reserva: se carga el contenedor del plan.
                expect(plan.loading['C:$container']?.plannedPosition, cell);
                emptyWithNumber++;
                draft = MovementDraft.loadFull('caso-a08', container, cell,
                    order: e['orden'] as int);
              }
            case 'cambio_de_posicion':
              skipped++; // lo deriva T-80
              continue;
            default:
              fail('Evento desconocido: ${e['tipo']}');
          }
          (await repository.append(draft, author))
              .fold((f) => fail('${e['n']}: ${f.message}'), (_) {});
        }
        // Cerrar y reabrir antes de derivar: la bitácora vive en el almacén.
        await repository.close();
        repository = await open();

        final records = (await repository.records('caso-a08')).getOrElse(() => []);
        expect(records, hasLength(176));
        expect(skipped, 1);
        expect(emptyWithNumber, 1);
        final state =
            const OperationStateDeriver().derive(plan, records.map((r) => r.movement));

        // 1. Las 460 posiciones del estado final.
        final expected = {
          for (final row in File('$corpus/CASO_A08_ESTADO_FINAL.csv')
              .readAsLinesSync()
              .skip(1)
              .where((l) => l.trim().isNotEmpty)
              .map((l) => l.split(',')))
            row[0]: row[1]
        };
        expect(expected, hasLength(460));
        expect(state.occupancy, expected);

        // 2. Solo las dos posiciones del intercambio quedan en conflicto.
        expect(state.conflicts.map((c) => (c.kind, c.key)).toSet(), {
          (ConflictKind.outOfPlan, 'C:XQDU0060080'),
          (ConflictKind.outOfPlan, 'C:XRFU2642829'),
        });
        final inConflict = {
          for (final item in state.items.values)
            if (item.inConflict) item.position!: item.plannedPosition
        };
        expect(inConflict, {'0140108': '0140102', '0140102': '0140108'});

        // 3. Estados: 284 de paso, 176 movidos, nada pendiente ni cancelado.
        final byState = <(PlanRole, ItemState), int>{};
        for (final item in state.items.values) {
          byState.update((item.role, item.state), (n) => n + 1, ifAbsent: () => 1);
        }
        expect(byState, {
          (PlanRole.transit, ItemState.planned): 284,
          (PlanRole.load, ItemState.moved): 176,
        });
        expect(state.duplicates, isEmpty);
        expect(state.voided, isEmpty);

        // 4. Movimientos por bahía y sección, como al pie de cada bahía del papel.
        final progress = state.progress(role: PlanRole.load);
        int moved(List<int> bays, bool deck) => bays
            .map((b) => progress[(bay: b, deck: deck)]?.moved ?? 0)
            .fold(0, (a, b) => a + b);
        final byBay = {
          for (final entry in expectedByBay.entries)
            entry.key: (
              deck: moved(entry.key.split('/').map(int.parse).toList(), true),
              hold: moved(entry.key.split('/').map(int.parse).toList(), false),
            )
        };
        expect(byBay, expectedByBay);

        // 5. La exportación lleva los 176 movimientos.
        final exported = jsonDecode((await repository.exportJson('caso-a08')).getOrElse(() => '{}'))
            as Map<String, dynamic>;
        expect((exported['movements'] as List), hasLength(176));

        stdout.writeln('T-72 $name: ${records.length} movimientos · '
            '${state.occupancy.length} posiciones ocupadas, iguales al estado final · '
            'conflictos: ${state.conflicts.map((c) => '${c.kind.name} ${c.key}').join('; ')}');
        for (final c in state.conflicts) {
          stdout.writeln('  ${c.message}');
        }
        stdout.writeln('  por bahía (cubierta/bodega): '
            '${byBay.entries.map((e) => '${e.key} ${e.value.deck}/${e.value.hold}').join(' · ')}');
      } finally {
        await repository.close();
        await directory.delete(recursive: true);
      }
    });
  }
}
