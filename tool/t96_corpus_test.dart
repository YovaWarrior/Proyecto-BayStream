import 'dart:convert';
import 'dart:io';

import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/data/services/export_list_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/departure_baplie_writer.dart';
import 'package:baystream/features/vessel/domain/services/export_list_cross_checker.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';
import 'package:baystream/features/vessel/domain/services/voyage_comparison.dart';
import 'package:flutter_test/flutter_test.dart';

import 't86_corpus_support.dart';

/// Corpus externo: flutter test tool/t96_corpus_test.dart
/// --dart-define=BAYSTREAM_CORPUS_DIRECTORY=CARPETA_DEL_CORPUS
///
/// Solo lee el corpus; la salida generada vive en memoria.
void main() {
  const corpus = String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');
  final parser = BaplieParserService();
  String raw(String code) {
    expect(corpus, isNotEmpty);
    return File('$corpus/CORPUS_$code.edi').readAsStringSync();
  }

  VesselVoyage read(String code) =>
      code == 'A06' ? readA06WithNotice(raw(code)) : parser.parse(raw(code));

  Map<String, int> fields(VoyageComparison c) => {
        for (final e in c.changesByField.entries) e.key.label: e.value,
      };
  String summary(VoyageComparison c) =>
      '${c.discharged.length} descargados · ${c.loaded.length} cargados · '
      '${c.permanent.length} permanentes, ${c.withChanges} con cambios · '
      'reservas ${c.reservedFirst}/${c.reservedSecond} · ${fields(c)}';

  void expectTenTwenty(VoyageComparison c) {
    final f = c.changesByField;
    expect(f[ComparedField.portOfLoading], 127);
    expect(f[ComparedField.portOfDischarge], 189);
    expect(f[ComparedField.operator], 58);
    expect(f[ComparedField.weight], 113);
    expect(f[ComparedField.position], 0);
    expect(f[ComparedField.isoType], 0);
    expect(f[ComparedField.status], 0);
  }

  test('T-96 A07 → A08: 114, 121 + 55 reservas, 284 y las cifras de 10.20',
      () {
    final arrival = read('A07');
    final plan = read('A08');
    final c = VoyageComparison.compare(arrival, plan);
    expect(c.discharged, hasLength(114));
    expect(c.loaded, hasLength(121));
    expect(c.permanent, hasLength(284));
    expect((c.reservedFirst, c.reservedSecond), (0, 55));
    expect(c.duplicatesFirst, isEmpty);
    expect(c.duplicatesSecond, isEmpty);
    expect(c.vesselNotice, isNull);
    expectTenTwenty(c);
    // El ejemplo de 10.20: 0020310, 24 260 kg en la llegada y 24 200 en el plan.
    final example = c.permanent.singleWhere(
        (p) => p.first.stowagePosition?.toIsoCode() == '0020310');
    final weight =
        example.changes.singleWhere((x) => x.field == ComparedField.weight);
    expect((weight.before, weight.after), (24260.0, 24200.0));
    // Lo descargado es lo que A07 deja en GTSTC; lo cargado, lo que A08 sube.
    expect(c.discharged.every((x) => x.portOfDischarge == 'GTSTC'), isTrue);
    expect(c.loaded.every((x) => x.portOfLoading == 'GTSTC'), isTrue);
    stdout.writeln('T-96 A07 → A08: ${summary(c)}');
    stdout.writeln('T-96 ejemplo ${example.containerId} en 0020310: peso '
        '${weight.before} → ${weight.after}');
  });

  test('T-96 A08 → A07: las mismas cifras, intercambiadas', () {
    final forward = VoyageComparison.compare(read('A07'), read('A08'));
    final back = VoyageComparison.compare(read('A08'), read('A07'));
    expect(back.discharged.map((x) => x.containerId),
        forward.loaded.map((x) => x.containerId));
    expect(back.loaded.map((x) => x.containerId),
        forward.discharged.map((x) => x.containerId));
    expect((back.reservedFirst, back.reservedSecond), (55, 0));
    expect(back.changesByField, forward.changesByField);
    for (var i = 0; i < back.permanent.length; i++) {
      final f = forward.permanent[i], b = back.permanent[i];
      expect(b.containerId, f.containerId);
      expect([for (final x in b.changes) (x.field, x.before, x.after)],
          [for (final x in f.changes) (x.field, x.after, x.before)]);
    }
    stdout.writeln('T-96 A08 → A07: ${summary(back)}');
  });

  test('T-96 A07 → A08v_VGM: la misma clasificación', () {
    final arrival = read('A07');
    final plan = read('A08');
    final vgm = read('A08v_VGM');
    final c = VoyageComparison.compare(arrival, vgm);
    expect((c.discharged.length, c.loaded.length, c.permanent.length),
        (114, 121, 284));
    expect((c.reservedFirst, c.reservedSecond), (0, 55));
    expectTenTwenty(c);
    final wtVsVgm = VoyageComparison.compare(plan, vgm);
    expect((wtVsVgm.discharged.length, wtVsVgm.loaded.length),
        (0, 0));
    stdout.writeln('T-96 A07 → A08v_VGM: ${summary(c)}');
    stdout.writeln('T-96 A08 → A08v_VGM: ${summary(wtVsVgm)}; '
        'con VGM en A08v: ${vgm.containers.where((x) => x.vgmWeight != null).length}, '
        'con WT: ${vgm.containers.where((x) => x.grossWeight != null).length}');
  });

  test('T-96 un archivo consigo mismo: todo permanente y sin cambios', () {
    for (final code in ['A07', 'A08', 'A01']) {
      final v = read(code);
      final c = VoyageComparison.compare(v, v);
      expect((c.discharged.length, c.loaded.length, c.withChanges), (0, 0, 0));
      expect(c.permanent, hasLength(v.totalContainers));
      expect(c.reservedFirst, c.reservedSecond);
    }
  });

  test('T-96 A05 → A06: solo cuentas, y el aviso de la 1.5', () {
    final a05 = read('A05');
    final a06 = read('A06');
    expect(a06.metadata!.readWithV2Rules, isTrue);
    final c = VoyageComparison.compare(a05, a06);
    stdout.writeln('T-96 A05 → A06: ${summary(c)}; aviso de buque: '
        '${c.vesselNotice ?? 'ninguno'}; duplicados '
        '${c.duplicatesFirst.length}/${c.duplicatesSecond.length}');
  });

  test('T-96 la salida de la operación de 177 eventos contra A07: 114, 176, 284',
      () {
    final generated = _departureOfTheCase(corpus, parser);
    final arrival = read('A07');
    final departure = parser.parse(generated);
    final c = VoyageComparison.compare(arrival, departure);
    expect(c.discharged, hasLength(114));
    expect(c.loaded, hasLength(176));
    expect(c.permanent, hasLength(284));
    // Por origen: los 121 números del plan y las 55 celdas reservadas.
    final plan = read('A08');
    final planned = {for (final x in plan.containers) x.containerId};
    final reservedCells = {
      for (final s in plan.reservedSlots) s.stowagePosition.toIsoCode()
    };
    expect(c.loaded.where((x) => planned.contains(x.containerId)),
        hasLength(121));
    expect(
        c.loaded.where(
            (x) => reservedCells.contains(x.stowagePosition?.toIsoCode())),
        hasLength(55));
    // Por estado, como los eventos del caso: 120 llenos y 56 vacíos.
    final full = c.loaded.where((x) => x.status == ContainerStatus.full).length;
    final empty =
        c.loaded.where((x) => x.status == ContainerStatus.empty).length;
    expect((full, empty), (120, 56));
    expect(c.reservedSecond, 0);
    expectTenTwenty(c);
    stdout.writeln('T-96 A07 → salida de la operación: ${summary(c)}; '
        'cargados por estado $full llenos y $empty vacíos');
  });
}

/// La operación del caso, como en tool/t82_corpus_test.dart: A07 de llegada,
/// A08 de plan, el listado y los 177 eventos. Devuelve el texto de salida.
String _departureOfTheCase(String corpus, BaplieParserService parser) {
  final clock = DateTime.utc(2026, 10, 11, 22);
  final source = File('$corpus/CORPUS_A08.edi').readAsStringSync();
  final arrivalSource = File('$corpus/CORPUS_A07.edi').readAsStringSync();
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
      id: 't96',
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
            fileName: 'A08.edi',
            content: source),
      ]);
  final events =
      ((jsonDecode(File('$corpus/CASO_A08_EVENTOS.json').readAsStringSync())
              as Map)['eventos'] as List)
          .cast<Map<String, dynamic>>();
  expect(events, hasLength(177));
  var sequence = 0;
  Movement record(MovementDraft d) => Movement(
      id: 't96-${++sequence}',
      operationId: 't96',
      type: d.type,
      target: d.target,
      payload: d.payload,
      author:
          const MovementAuthor(name: 'Prueba T-96', role: OperatorRole.office),
      deviceId: 't96',
      sequence: sequence,
      createdAt: clock.add(Duration(seconds: sequence)));
  final history = [
    for (final c
        in arrival.containers.where((c) => c.portOfDischarge == 'GTSTC'))
      record(MovementDraft.discharge(
          't96', c.containerId, c.stowagePosition!.toIsoCode())),
  ];
  for (final e in events) {
    if (e['tipo'] == 'cambio_de_posicion') {
      history.add(record(MovementDraft.changePosition(
          't96',
          [
            for (final or in (e['ordenes'] as List).cast<int>())
              PositionChange('C:${list.byOrder(or)!.containerId}',
                  e['plan']['$or'], e['nuevo']['$or'])
          ],
          'Intercambio 128 y 145')));
    } else {
      final pos = (e['posicion'] ?? e['celda']) as String;
      history.add(record(e['tipo'] == 'asignar_vacio' &&
              loading.reservedSlots.any((s) => s.key == 'R:$pos')
          ? MovementDraft.assignEmpty(
              't96', pos, e['contenedor'], (e['tara_kg'] as num).toDouble(),
              order: e['orden'])
          : MovementDraft.loadFull('t96', e['contenedor'], pos,
              order: e['orden'])));
    }
  }
  final data = LoadingOperation.build(
      operationId: 't96',
      arrival: arrival,
      loading: loading,
      list: list,
      movements: history);
  expect(data.state.conflicts, isEmpty);
  return const DepartureBaplieWriter()
      .generate(
          operation: operation,
          state: data.state,
          list: list,
          movements: history,
          now: clock)
      .text;
}
