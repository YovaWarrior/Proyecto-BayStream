import 'dart:convert';
import 'dart:io';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/data/services/export_list_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/export_list_cross_checker.dart';
import 'package:baystream/features/vessel/domain/services/load_check.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';
import 'package:flutter_test/flutter_test.dart';

/// T-77: validación antes de confirmar, contra el caso real. Lee la carpeta
/// externa del corpus y no escribe nada: la bitácora vive en memoria.
/// flutter test tool/t77_corpus_test.dart
/// --dart-define=BAYSTREAM_CORPUS_DIRECTORY=CARPETA_EXTERNA
void main() {
  const corpus = String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');

  VesselVoyage read(String name, {double? limit}) {
    final parsed = BaplieParserService()
        .parse(File('$corpus/CORPUS_$name.edi').readAsStringSync());
    var geometry = VesselProfile.proposeFrom(parsed).geometry;
    if (limit != null) geometry = geometry.copyWith(stackWeightLimitKg: limit);
    return parsed.withGeometry(geometry, portOfCall: 'GTSTC');
  }

  ExportList listFor(VesselVoyage loading) {
    final raw = const ExportListParserService().parseXlsx(
        File('$corpus/LISTADO_A08.xlsx').readAsBytesSync(),
        fileName: 'LISTADO_A08.xlsx');
    final proposals =
        ExportListCrossChecker.propose(raw, loading, portOfCall: 'GTSTC')
            .map((p) => p.kind == EquivalenceKind.type && p.listCode == '40RF'
                ? p.choose('45R1')
                : p)
            .toList();
    return raw.normalized(ExportListCrossChecker.tableOf(proposals));
  }

  List<Map<String, dynamic>> events() => ((jsonDecode(
              File('$corpus/CASO_A08_EVENTOS.json').readAsStringSync())
          as Map)['eventos'] as List)
      .cast<Map<String, dynamic>>()
      .where((e) => e['tipo'] != 'cambio_de_posicion')
      .toList();

  var sequence = 0;
  Movement movement(MovementDraft draft) {
    sequence++;
    return Movement(
        id: 'm$sequence',
        operationId: draft.operationId,
        type: draft.type,
        target: draft.target,
        payload: draft.payload,
        author: const MovementAuthor(name: 'Aceptación T77', role: OperatorRole.dock),
        deviceId: 't77',
        sequence: sequence,
        createdAt: DateTime.utc(2026, 1, 1).add(Duration(minutes: sequence)));
  }

  /// Valida cada evento contra el estado que dejan los anteriores y lo
  /// registra como lo haría la pantalla: con motivo si lo pide, y con la
  /// descarga del ocupante si la celda la ocupa algo que baja aquí.
  ({
    List<String> warnings,
    int blocked,
    int dischargeFirst,
    LoadingOperation last,
    Map<int, LoadCheck> checks
  }) replay(VesselVoyage loading, VesselVoyage? arrival, ExportList list,
      {List<MovementDraft> before = const []}) {
    final movements = [for (final d in before) movement(d)];
    final warnings = <String>[];
    final checks = <int, LoadCheck>{};
    var blocked = 0;
    var dischargeFirst = 0;
    LoadingOperation build() => LoadingOperation.build(
        operationId: 'op',
        loading: loading,
        arrival: arrival,
        list: list,
        movements: movements);
    var data = build();
    for (final event in events()) {
      final row = list.byOrder(event['orden'] as int)!;
      final position = (event['posicion'] ?? event['celda']) as String;
      final check = data.check(row, position);
      checks[row.order] = check;
      if (check.blocked) blocked++;
      if (check.warns) {
        warnings.add('OR ${row.order}: '
            '${check.issues.map((i) => i.kind.name).join('+')}');
      }
      if (check.dischargeFirst != null) {
        dischargeFirst++;
        movements.add(movement(data.dischargeDraft(check.dischargeFirst!)));
      }
      movements.add(movement(data.draft(row, position,
          reason: check.needsReason ? 'Intercambio 128-145 (T-80)' : null,
          dischargeOccupant: check.dischargeFirst != null)));
      data = build();
    }
    return (
      warnings: warnings,
      blocked: blocked,
      dischargeFirst: dischargeFirst,
      last: data,
      checks: checks
    );
  }

  Map<String, String> expected() => {
        for (final row in File('$corpus/CASO_A08_ESTADO_FINAL.csv')
            .readAsLinesSync()
            .skip(1)
            .where((line) => line.trim().isNotEmpty)
            .map((line) => line.split(',')))
          row[0]: row[1]
      };

  for (final name in ['A08', 'A08v_VGM']) {
    test('T-77 $name: los 176 eventos dan exactamente 2 avisos (OR 128 y 145)',
        () {
      expect(corpus, isNotEmpty);
      final loading = read(name);
      final list = listFor(loading);
      final run = replay(loading, null, list);
      expect(run.warnings, ['OR 128: outOfPlan', 'OR 145: outOfPlan']);
      expect(run.blocked, 0);
      expect(run.dischargeFirst, 0);
      expect(run.last.state.occupancy, expected());
      expect(run.last.state.conflicts.map((c) => c.kind).toSet(),
          {ConflictKind.outOfPlan});
      // Sin límite en el perfil, el peso de la pila no se evalúa ni bloquea.
      expect(
          run.checks.values.every(
              (c) => c.stack!.status == StackWeightStatus.notEvaluated),
          isTrue);
      stdout.writeln('T-77 $name sin llegada: ${run.warnings.join(' · ')}; '
          '0 bloqueados; 460 posiciones iguales al CSV.');
    });

    test('T-77 $name con A07: las 54 celdas que bajan ofrecen su descarga',
        () {
      final loading = read(name);
      final arrival = read('A07');
      final list = listFor(loading);
      // Sin marcar las descargas: 2 avisos y 54 «Marcar su descarga y cargar».
      final pending = replay(loading, arrival, list);
      expect(pending.warnings, ['OR 128: outOfPlan', 'OR 145: outOfPlan']);
      expect(pending.dischargeFirst, 54);
      // Siguen a bordo las 60 descargas que no ocupan una celda de carga.
      expect(pending.last.discharge.pending, 60);
      final occupancy = pending.last.state.occupancy;
      expect({for (final k in expected().keys) k: occupancy[k]}, expected());
      expect(pending.last.state.conflicts.map((c) => c.kind).toSet(),
          {ConflictKind.outOfPlan});
      expect(pending.last.state.conflicts.length, 2);
      // Con las 114 descargas marcadas antes: los mismos 2 avisos y ninguna oferta.
      final initial = LoadingOperation.build(
          operationId: 'op', loading: loading, arrival: arrival, list: list);
      final discharges = [
        for (final item in initial.plan.arrival.values)
          if (item.role == PlanRole.discharge) initial.dischargeDraft(item)
      ];
      expect(discharges.length, 114);
      final done = replay(loading, arrival, list, before: discharges);
      expect(done.warnings, ['OR 128: outOfPlan', 'OR 145: outOfPlan']);
      expect(done.dischargeFirst, 0);
      expect(done.last.state.occupancy, expected());
      expect(done.last.discharge.pending, 0);
      stdout.writeln('T-77 $name con A07: 2 avisos; 54 celdas con «Marcar su '
          'descarga y cargar» sin descargas previas, 0 con ellas.');
    });
  }

  test('T-77 OR 12 en otro grupo, 40 en 20 y celda inexistente', () {
    final loading = read('A08');
    final list = listFor(loading);
    final data = LoadingOperation.build(
        operationId: 'op', loading: loading, list: list);
    final twelve = list.byOrder(12)!;
    // R:0060284 es 45G1 · PAMIT · LNC: tipo, puerto y línea distintos, y
    // además par. R:0070202 es 22G1 · PAMIT · LNC: solo cambia el grupo.
    final other = data.check(twelve, '0070202');
    expect(other.issues.map((i) => i.kind), [LoadIssueKind.otherGroup]);
    expect(() => data.draft(twelve, '0070202'), throwsStateError);
    final draft = data.draft(twelve, '0070202', reason: 'Prueba de grupo');
    expect(draft.payload['reason'], 'Prueba de grupo');
    final assigned = LoadingOperation.build(
        operationId: 'op',
        loading: loading,
        list: list,
        movements: [movement(draft)]);
    expect(assigned.state['R:0070202']!.state, ItemState.moved);
    expect(assigned.state.conflicts.single.kind, ConflictKind.otherGroup);
    expect(assigned.candidateSlots(list.byOrder(13)!, otherGroups: true),
        isNot(contains(assigned.plan.loading['R:0070202']!.reservedSlot)));
    // Un 20 en una reserva de 40 no se registra, ni con motivo.
    final even = data.check(twelve, '0060284');
    expect(even.blocked, isTrue);
    expect(() => data.draft(twelve, '0060284', reason: 'Lo intento'),
        throwsStateError);
    // Un 40 pies (OR 1, 45G1) en una posición de 20, ni con motivo.
    final one = list.byOrder(1)!;
    expect(one.type, '45G1');
    final size = data.check(one, '0250602');
    expect(size.issues.single.kind, LoadIssueKind.size);
    expect(() => data.draft(one, '0250602', reason: 'Lo intento'),
        throwsStateError);
    // Una celda fuera de la geometría o de una bahía que no existe.
    expect(data.check(one, '0229902').issues.single.kind,
        LoadIssueKind.unknownCell);
    expect(data.check(one, '0980282').issues.single.kind,
        LoadIssueKind.unknownCell);
    stdout.writeln('T-77 OR 12 en 007-02-02: ${other.issues.single.message}');
    stdout.writeln('T-77 OR 1 en 025-06-02: ${size.issues.single.message}');
  });

  test('T-77 límite de prueba de 90 000 kg: la pila 014, bodega, fila 01', () {
    final loading = read('A08', limit: 90000);
    final list = listFor(loading);
    final run = replay(loading, null, list);
    final stack = [
      for (final e in run.checks.entries)
        if (e.value.position.startsWith('01401') &&
            int.parse(e.value.position.substring(5)) < 80)
          (e.key, e.value)
    ];
    for (final (order, check) in stack) {
      stdout.writeln('T-77 90 t · OR $order en ${check.position}: '
          '${check.stack!.message}');
    }
    expect(stack.length, 4);
    expect(
        stack.any((s) => s.$2.issues
            .any((i) => i.kind == LoadIssueKind.stackWeight)),
        isTrue);
    final exceeded = run.checks.values
        .where((c) => c.issues.any((i) => i.kind == LoadIssueKind.stackWeight))
        .toList();
    stdout.writeln('T-77 90 t: ${exceeded.length} cargas avisan por peso de pila '
        'en ${exceeded.map((c) => '${c.stack!.bay}-${c.stack!.row}-${c.stack!.deck ? 'cub' : 'bod'}').toSet().length} pilas.');
    // Sin límite, la misma pila sale «no evaluado» y no bloquea.
    final free = LoadingOperation.build(
        operationId: 'op', loading: read('A08'), list: list);
    final first = stack.first;
    final again = free.check(list.byOrder(first.$1)!, first.$2.position);
    expect(again.stack!.status, StackWeightStatus.notEvaluated);
    expect(again.issues.map((i) => i.kind), isNot(contains(LoadIssueKind.stackWeight)));
  });
}
