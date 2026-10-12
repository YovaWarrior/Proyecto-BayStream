import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/data/services/export_list_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/departure_baplie_writer.dart';
import 'package:baystream/features/vessel/domain/services/export_list_cross_checker.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';
import 'package:baystream/features/vessel/domain/services/operation_state_deriver.dart';
import 'package:flutter_test/flutter_test.dart';

/// T-82 · Solo lee el corpus externo; las salidas viven en el temporal del
/// sistema. El oráculo es el CSV, el listado y la llegada, no el escritor.
void main() {
  const corpus = String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');
  final clock = DateTime.utc(2026, 10, 11, 22);
  const writer = DepartureBaplieWriter();
  for (final name in ['A08', 'A08v_VGM']) {
    test('T-82 $name: 177 eventos, 460 posiciones, cancelación e ida y vuelta',
        () {
      final source = File('$corpus/CORPUS_$name.edi').readAsStringSync();
      final arrivalSource = File('$corpus/CORPUS_A07.edi').readAsStringSync();
      final parser = BaplieParserService();
      final arrival = parser.parse(arrivalSource).copyWith(portOfCall: 'GTSTC');
      final loading = parser.parse(source).copyWith(portOfCall: 'GTSTC');
      final raw = const ExportListParserService().parseXlsx(
          File('$corpus/LISTADO_A08.xlsx').readAsBytesSync(),
          fileName: 'LISTADO_A08.xlsx');
      final list = raw.normalized(ExportListCrossChecker.tableOf(
          ExportListCrossChecker.propose(raw, loading, portOfCall: 'GTSTC')
              .map((p) => p.kind == EquivalenceKind.type && p.listCode == '40RF'
                  ? p.choose('45R1')
                  : p)
              .toList()));
      final operation = Operation(
          id: 't82',
          vesselName: loading.vessel.name,
          voyageNumber: loading.voyageNumber,
          portOfCall: 'GTSTC',
          createdAt: clock,
          sources: [
            OperationSource(
                kind: OperationSourceKind.arrivalBaplie,
                fileName: 'A07.edi',
                content: arrivalSource),
            OperationSource(
                kind: OperationSourceKind.loadingBaplie,
                fileName: '$name.edi',
                content: source),
          ]);
      final events =
          ((jsonDecode(File('$corpus/CASO_A08_EVENTOS.json').readAsStringSync())
                  as Map)['eventos'] as List)
              .cast<Map<String, dynamic>>();
      expect(events, hasLength(177));
      var sequence = 0;
      Movement record(MovementDraft d) => Movement(
          id: 't82-${++sequence}',
          operationId: 't82',
          type: d.type,
          target: d.target,
          payload: d.payload,
          author: const MovementAuthor(
              name: 'Prueba T-82', role: OperatorRole.office),
          deviceId: 't82',
          sequence: sequence,
          createdAt: clock.add(Duration(seconds: sequence)));
      final discharges = [
        for (final c
            in arrival.containers.where((c) => c.portOfDischarge == 'GTSTC'))
          record(MovementDraft.discharge(
              't82', c.containerId, c.stowagePosition!.toIsoCode()))
      ];
      expect(discharges, hasLength(114));
      final movements = <Movement>[];
      for (final e in events) {
        if (e['tipo'] == 'cambio_de_posicion') {
          movements.add(record(MovementDraft.changePosition(
              't82',
              [
                for (final or in (e['ordenes'] as List).cast<int>())
                  PositionChange('C:${list.byOrder(or)!.containerId}',
                      e['plan']['$or'], e['nuevo']['$or'])
              ],
              'Intercambio 128 y 145')));
        } else {
          final pos = (e['posicion'] ?? e['celda']) as String;
          movements.add(record(e['tipo'] == 'asignar_vacio' &&
                  loading.reservedSlots.any((s) => s.key == 'R:$pos')
              ? MovementDraft.assignEmpty(
                  't82', pos, e['contenedor'], (e['tara_kg'] as num).toDouble(),
                  order: e['orden'])
              : MovementDraft.loadFull('t82', e['contenedor'], pos,
                  order: e['orden'])));
        }
      }
      final expected = File('$corpus/CASO_A08_ESTADO_FINAL.csv')
          .readAsLinesSync()
          .skip(1)
          .where((l) => l.isNotEmpty)
          .map((l) => l.split(','))
          .toList();
      expect(expected, hasLength(460));
      final planned = {for (final c in loading.containers) c.containerId: c};
      final through = expected.where((r) => r[8] == 'a_bordo').toList();
      expect(through, hasLength(284));
      for (final row in through) {
        final c = planned[row[1]]!;
        expect(c.stowagePosition!.toIsoCode(), row[0]);
        expect(c.containerId, row[1]);
        expect(c.isoSizeType, row[2]);
        expect(c.portOfLoading, row[4]);
        expect(c.portOfDischarge, row[5]);
        expect(c.operatorCode, row[6]);
        expect(c.effectiveWeight, double.parse(row[7]));
      }
      LoadingOperation derive(Iterable<Movement> moves) =>
          LoadingOperation.build(
              operationId: 't82',
              arrival: arrival,
              loading: loading,
              list: list,
              movements: moves);
      final history = [...discharges, ...movements];
      final finalData = derive(history);
      expect(finalData.state.conflicts, isEmpty);
      final generated = writer.generate(
          operation: operation,
          state: finalData.state,
          list: list,
          movements: history,
          now: clock);
      final temp = Directory.systemTemp.createTempSync('baystream-t82-');
      final output = File('${temp.path}/$name-salida.edi')
        ..writeAsStringSync(generated.text);
      final reread = parser.parse(output.readAsStringSync());
      final byPosition = {
        for (final c in reread.containers) c.stowagePosition!.toIsoCode(): c
      };
      expect(byPosition, hasLength(460));
      final byNumber = {for (final c in loading.containers) c.containerId: c};
      final rows = {for (final row in list.rows) row.containerId: row};
      var transit = 0;
      for (final row in expected) {
        final c = byPosition[row[0]]!;
        expect(c.containerId, row[1]);
        expect(c.isoSizeType, row[2]);
        expect(c.portOfLoading, row[4]);
        expect(c.portOfDischarge, row[5]);
        expect(c.operatorCode, row[6]);
        expect(c.effectiveWeight, double.parse(row[7]));
        if (row[8] == 'a_bordo') {
          transit++;
          final original = byNumber[c.containerId]!;
          expect(c.grossWeight, original.grossWeight);
          expect(c.vgmWeight, original.vgmWeight);
          expect(c.tareWeight, original.tareWeight);
          expect(c.status, original.status);
          expect(c.dangerousGoods, original.dangerousGoods);
          expect(c.temperature, original.temperature);
        } else {
          final item = rows[c.containerId]!;
          expect(c.status, item.status);
          expect(c.tareWeight, item.tareKg);
          expect(c.vgmWeight, item.vgmKg);
          expect(c.isDangerous, item.isDangerous);
          expect(
              c.dangerousGoods!
                  .map((d) => d.unNumber)
                  .whereType<String>()
                  .toList()
                ..sort(),
              [...item.unNumbers]..sort());
          expect(
              c.dangerousGoods!.every((d) => d.hazardClass == item.imdgClass),
              isTrue);
        }
      }
      expect(transit, 284);
      expect(byPosition['0030984']!.tareWeight, 2185);
      expect(generated.pendingLoads + generated.pendingDischarges, 0);
      for (final order in [
        history.reversed.toList(),
        [...history]..shuffle(Random(82))
      ]) {
        expect(
            writer
                .generate(
                    operation: operation,
                    state: derive(order).state,
                    list: list,
                    movements: order,
                    now: clock)
                .text,
            generated.text);
      }
      final reparsedOperation = operation.copyWith(sources: [
        OperationSource(
            kind: OperationSourceKind.loadingBaplie,
            fileName: 'salida.edi',
            content: generated.text),
        OperationSource(
            kind: OperationSourceKind.arrivalBaplie,
            fileName: 'salida.edi',
            content: generated.text),
      ]);
      expect(
          writer
              .generate(
                  operation: reparsedOperation,
                  now: clock,
                  state: const OperationStateDeriver().derive(
                      OperationPlan.build(
                          portOfCall: 'ZZZZZ',
                          arrival: reread,
                          loading: reread),
                      []))
              .text,
          generated.text);
      // Cancelar antes de cargar. El intento de carga cancelada permanece en
      // la historia y el derivador lo excluye; annul lo habilita otra vez.
      final cancel = Movement(
          id: 'cancel',
          operationId: 't82',
          type: MovementType.cancelItem,
          target: 'C:${list.byOrder(5)!.containerId}',
          payload: const {'reason': 'No embarca: prueba T-82'},
          author: const MovementAuthor(
              name: 'Oficina prueba', role: OperatorRole.office),
          deviceId: 't82',
          sequence: 0,
          createdAt: clock.subtract(const Duration(seconds: 1)));
      final cancelledHistory = [cancel, ...history];
      final cancelled = writer.generate(
          operation: operation,
          state: derive(cancelledHistory).state,
          list: list,
          movements: cancelledHistory,
          now: clock);
      expect(parser.parse(cancelled.text).containers, hasLength(459));
      expect(cancelled.text,
          isNot(contains('EQD+CN+${list.byOrder(5)!.containerId}+')));
      expect(cancelled.cancelledText, contains('OR 5'));
      expect(cancelled.cancelledText, contains('No embarca: prueba T-82'));
      final restoredHistory = [
        ...cancelledHistory,
        record(MovementDraft.annul('t82', 'cancel', 'Sí embarca'))
      ];
      final restored = writer.generate(
          operation: operation,
          state: derive(restoredHistory).state,
          list: list,
          movements: restoredHistory,
          now: clock);
      expect(restored.text, generated.text);
      expect(restored.cancelled, isEmpty);
      stdout.writeln(
          'T-82 $name: 460/460 (7 columnas), 284 con declaraciones del plan vigente, 176 del listado, OR 12=2185 kg; cancelado 459, annul 460; reloj fijo y tres órdenes estables. Salida: ${output.path}');
    });
  }
  for (final name in [
    'A01',
    'A02',
    'A03',
    'A03v_VGM',
    'A04',
    'A05',
    'A06',
    'A07',
    'A08',
    'A08v_VGM'
  ]) {
    test('T-82 $name: conserva cabecera 2.x o rechaza versión 1.5', () {
      final source = File('$corpus/CORPUS_$name.edi').readAsStringSync();
      final voyage = BaplieParserService().parse(source);
      final op = Operation(
          id: 'test',
          vesselName: voyage.vessel.name,
          voyageNumber: voyage.voyageNumber,
          portOfCall: 'ZZZZZ',
          createdAt: clock,
          sources: [
            OperationSource(
                kind: OperationSourceKind.loadingBaplie,
                fileName: '$name.edi',
                content: source)
          ]);
      final state = const OperationStateDeriver().derive(
          OperationPlan.build(portOfCall: 'ZZZZZ', loading: voyage), []);
      if (name == 'A06') {
        expect(() => writer.generate(operation: op, state: state, now: clock),
            throwsStateError);
      } else {
        final output = writer.generate(operation: op, state: state, now: clock);
        final id =
            RegExp(r'UNH\+[^+]+\+([^\x27]+)').firstMatch(source)!.group(1);
        expect(output.text, contains('+$id\''));
        expect(BaplieParserService().parse(output.text).containers,
            hasLength(voyage.containers.length));
      }
    });
  }
}
