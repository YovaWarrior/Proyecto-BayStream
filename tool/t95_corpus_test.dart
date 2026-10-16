import 'dart:io';
import 'dart:math' as math;

import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/discharge_sequence.dart';
import 'package:flutter_test/flutter_test.dart';

import 't86_corpus_support.dart';

/// Corpus externo: flutter test tool/t95_corpus_test.dart
/// --dart-define=BAYSTREAM_CORPUS_DIRECTORY=CARPETA_DEL_CORPUS
///
/// Solo lee el corpus. Las tapas de A07 son declaraciones PROVISIONALES de esta
/// prueba: ningún buque del corpus declara tapas reales (T-83).
void main() {
  const corpus = String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');
  String raw(String code) {
    expect(corpus, isNotEmpty);
    return File('$corpus/CORPUS_$code.edi').readAsStringSync();
  }

  VesselVoyage read(String code) => code == 'A06'
      ? readA06WithNotice(raw(code))
      : BaplieParserService().parse(raw(code));

  const sources = [
    'A01', 'A02', 'A03', 'A03v_VGM', 'A04', 'A05', 'A06', 'A07', 'A08',
    'A08v_VGM',
  ];

  Set<String> columnPositions(DischargeSequence s) => {
        for (final cell in s.cells)
          for (final step in cell.steps)
            if (step.kind == DischargeStepKind.restowOut &&
                step.reason == RestowReason.column)
              step.position,
      };

  test('T-95 A07 en GTSTC: 114 descargas, 66 en cubierta y 48 en bodega', () {
    final a07 = read('A07');
    final s = DischargeSequence.build(a07, 'GTSTC',
        geometry: VesselGeometry.proposeFrom(a07.stowagePositions));
    expect((s.discharges, s.deckDischarges, s.holdDischarges), (114, 66, 48));
    expect(s.withoutPosition, isEmpty);
    // Cotejo sin el lector de BayStream: LOC+147 y LOC+11 de cada grupo.
    final rawColumn = _rawColumnRestows(raw('A07'), 'GTSTC');
    expect(columnPositions(s), rawColumn);
    stdout.writeln('T-95 A07 GTSTC sin tapas: ${s.discharges} descargas '
        '(${s.deckDischarges} cub. / ${s.holdDischarges} bod.) · '
        '${s.columnRestows} re-estibas por columna (cotejo crudo ${rawColumn.length}) · '
        '${s.holdWithoutCover.length} en bodega sin tapa declarada · '
        '${s.cells.length} celdas · ${s.movesOnBoard} a bordo / ${s.movesByQuay} por muelle');
  });

  for (final code in sources) {
    test('T-95 $code: invariantes en cada puerto de descarga', () {
      final voyage = read(code);
      final geometry = VesselGeometry.proposeFrom(voyage.stowagePositions);
      final ports = DischargeSequence.dischargePorts(voyage);
      if (code == 'A06') {
        // La 1.5 trae el destino en LOC+12, no en LOC+11, y se lee con las
        // reglas 2.x (T-103): ningún contenedor tiene puerto de descarga.
        expect(ports, isEmpty);
        expect(RegExp(r"'LOC\+11\+").hasMatch(raw(code)), isFalse);
        final s = DischargeSequence.build(voyage, 'COCTG', geometry: geometry);
        expect((s.discharges, s.withoutDischargePort), (0, voyage.totalContainers));
        stdout.writeln('T-95 A06: sin LOC+11, ${s.withoutDischargePort} '
            'contenedores sin puerto de descarga y ninguna descarga');
        return;
      }
      expect(ports, isNotEmpty);
      final lines = <String>[];
      for (final port in ports) {
        final s = DischargeSequence.build(voyage, port, geometry: geometry);
        _expectInvariants(voyage, port, s, geometry);
        if (code != 'A06') {
          expect(columnPositions(s), _rawColumnRestows(raw(code), port),
              reason: '$code $port: cotejo crudo');
        }
        lines.add('$port ${s.discharges}/${s.columnRestows}');
      }
      stdout.writeln('T-95 $code: ${ports.length} puertos · '
          'descargas/re-estibas por columna: ${lines.join(' · ')}');
    });
  }

  test('T-95 A07 con tapas PROVISIONALES en las 21 bahías: pares o copiadas, igual',
      () {
    final a07 = read('A07');
    final a08 = read('A08');
    // La geometría del caso, como T-56: los dos planos de la escala.
    final geometry = VesselGeometry.proposeFrom(
        [...a07.stowagePositions, ...a08.stowagePositions]);
    const holdBays = [
      1, 2, 3, 5, 6, 7, 9, 10, 11, 13, 14, 15, 17, 18, 19, 21, 22, 23, 25, 26, 27
    ];
    expect(
        {...observedHoldBays(a07, geometry), ...observedHoldBays(a08, geometry)}
            .toList()
          ..sort(),
        holdBays);
    final holdRows = [
      for (final row in geometry.orderedRows)
        if (geometry.covers(IsoCoordinate(
            bay: 1, row: row, tier: geometry.holdTiers.first, rawCode: '')))
          row,
    ];
    // Tres tapas de grúa por bahía, de babor a estribor: PROVISIONALES.
    final third = (holdRows.length / 3).ceil();
    final declaration = HatchCoverDeclaration(kind: HatchCoverKind.crane, covers: [
      for (var i = 0; i < holdRows.length; i += third)
        holdRows.sublist(i, math.min(i + third, holdRows.length)).toSet(),
    ]);
    final onlyEven = {
      for (final bay in holdBays)
        if (bay.isEven || !holdBays.any((b) => b.isEven && footprintsTouch(b, bay)))
          bay: declaration,
    };
    final copied = {for (final bay in holdBays) bay: declaration};
    for (final d in {...onlyEven.entries, ...copied.entries}) {
      expect(d.value.validate(geometry, hasHold: true), isNull);
    }
    final even =
        DischargeSequence.build(a07, 'GTSTC', geometry: geometry, hatchCovers: onlyEven);
    final all =
        DischargeSequence.build(a07, 'GTSTC', geometry: geometry, hatchCovers: copied);
    _expectInvariants(a07, 'GTSTC', even, geometry);
    _expectInvariants(a07, 'GTSTC', all, geometry);
    List<String> trace(DischargeSequence s) => [
          for (final cell in s.cells)
            '${cell.bays.join('/')}: ${[
              for (final x in cell.steps) '${x.kind.name}@${x.position}'
            ].join(' ')}',
        ];
    expect(trace(all), trace(even));
    expect(
        (all.discharges, all.columnRestows, all.coverRestows, all.craneCovers,
            all.movesOnBoard, all.movesByQuay),
        (even.discharges, even.columnRestows, even.coverRestows, even.craneCovers,
            even.movesOnBoard, even.movesByQuay));
    expect(all.outsideCoverRows, even.outsideCoverRows);
    expect(all.holdWithoutCover, even.holdWithoutCover);
    expect(even.mergedCoverDeclarations, 0);
    expect(all.mergedCoverDeclarations, copied.length * 3 - onlyEven.length * 3);
    expect(all.holdWithoutCover, isEmpty);
    stdout.writeln('T-95 A07 GTSTC con tapas PROVISIONALES (${onlyEven.length} '
        'declaradas en las pares, ${copied.length} copiadas; '
        '${all.mergedCoverDeclarations} declaraciones unidas; filas de bodega '
        '${holdRows.map((r) => r.toString().padLeft(2, '0')).join(',')} en '
        '${declaration.covers.length} tapas): ${all.discharges} descargas · '
        '${all.restows} re-estibas (${all.columnRestows} por columna, '
        '${all.coverRestows} por tapa) · ${all.craneCovers} tapas de grúa · '
        '${all.movesOnBoard} movimientos a bordo, ${all.movesByQuay} por muelle · '
        '${all.outsideCoverRows.length} en filas fuera de las tapas · '
        '${all.cells.length} celdas; la primera ${all.cells.first.bays.join('/')} '
        'con ${all.cells.first.movesByQuay} por muelle');
  });
}

/// Los invariantes de la ficha, comprobados sin reutilizar el servicio.
void _expectInvariants(VesselVoyage voyage, String port, DischargeSequence s,
    VesselGeometry geometry) {
  final placed = voyage.containers.where((c) => c.stowagePosition != null).toList();
  final down = placed.where((c) => c.portOfDischarge == port).toList();
  final steps = [for (final cell in s.cells) ...cell.steps];
  // Por número y posición: dos entidades iguales no deben contarse como una.
  String key(ContainerUnit c) =>
      '${c.containerId}@${c.stowagePosition!.toIsoCode()}';
  List<ContainerUnit> of(DischargeStepKind kind) =>
      [for (final x in steps) if (x.kind == kind) x.container!];
  final discharged = of(DischargeStepKind.discharge);
  final out = of(DischargeStepKind.restowOut);
  // Cada contenedor del puerto aparece una sola vez como descarga.
  expect(discharged.length, down.length, reason: port);
  expect(discharged.map(key).toSet(), down.map(key).toSet(), reason: port);
  expect(discharged.map(key).toSet().length, discharged.length, reason: port);
  expect(down.length + s.withoutPosition.length,
      voyage.containers.where((c) => c.portOfDischarge == port).length);
  // Cada re-estiba no baja, sale una vez y vuelve una vez.
  expect(out.map(key).toSet().length, out.length, reason: port);
  expect(of(DischargeStepKind.restowBack).map(key).toSet(), out.map(key).toSet(),
      reason: port);
  bool deck(ContainerUnit c) => geometry.isDeckTier(c.stowagePosition!.tier);
  bool samePileAbove(ContainerUnit upper, ContainerUnit lower) {
    final a = upper.stowagePosition!, b = lower.stowagePosition!;
    return a.row == b.row &&
        deck(upper) == deck(lower) &&
        footprintsTouch(a.bay, b.bay) &&
        a.tier > b.tier;
  }

  final removed = [
    for (final x in steps)
      if (x.kind == DischargeStepKind.coverOff) x.cover!,
  ];
  for (final r in out) {
    expect(r.portOfDischarge, isNot(port));
    final overDischarge = down.any((d) => samePileAbove(r, d));
    final p = r.stowagePosition!;
    final onRemovedCover = deck(r) &&
        removed.any((k) => k.rows.contains(p.row) && k.touches(p.bay));
    expect(overDischarge || onRemovedCover, isTrue, reason: '$port ${p.toIsoCode()}');
  }
  // Ninguna descarga queda debajo de algo que no baja y no figura como re-estiba.
  final outSet = out.map(key).toSet();
  for (final d in down) {
    for (final c in placed) {
      if (c.portOfDischarge != port && samePileAbove(c, d)) {
        expect(outSet.contains(key(c)), isTrue,
            reason: '$port ${c.stowagePosition!.toIsoCode()} sobre '
                '${d.stowagePosition!.toIsoCode()}');
      }
    }
  }
  // Los totales suman.
  expect(s.discharges, discharged.length);
  expect(s.deckDischarges + s.holdDischarges, s.discharges);
  expect(s.restows, out.length);
  expect(s.columnRestows + s.coverRestows, s.restows);
  expect(removed.length, s.craneCovers + s.automaticCovers);
  expect(s.movesOnBoard, s.discharges + s.restows + 2 * s.craneCovers);
  expect(s.movesByQuay, s.discharges + 2 * s.restows + 2 * s.craneCovers);
  for (final cell in s.cells) {
    expect([for (final x in cell.steps) x.number],
        List.generate(cell.steps.length, (i) => i + 1));
  }
  for (var i = 1; i < s.cells.length; i++) {
    final a = s.cells[i - 1], b = s.cells[i];
    expect(
        a.movesByQuay > b.movesByQuay ||
            (a.movesByQuay == b.movesByQuay && a.bays.first < b.bays.first),
        isTrue);
  }
}

/// Re-estibas por columna desde el texto crudo: cada grupo LOC+147 con su
/// LOC+11 y un EQD+CN con número. Sin el lector, sin geometría: cubierta es el
/// nivel 80 o más, y la huella sale del número de bahía.
Set<String> _rawColumnRestows(String edi, String port) {
  final groups = <(String, String?, bool)>[];
  String? position;
  String? pod;
  var container = false;
  void close() {
    if (position != null && container) groups.add((position, pod, true));
  }

  for (final segment in edi.split("'")) {
    final s = segment.trim();
    if (s.startsWith('LOC+147+')) {
      close();
      position = s.substring(8).split(RegExp('[:+]')).first;
      pod = null;
      container = false;
    } else if (s.startsWith('LOC+11+')) {
      pod = s.substring(7).split(RegExp('[:+]')).first;
    } else if (s.startsWith('EQD+CN+')) {
      container = s.substring(7).split('+').first.isNotEmpty;
    }
  }
  close();
  Set<int> foot(int bay) => bay.isOdd ? {bay} : {bay - 1, bay + 1};
  // BBBRRTT o BBRRTT: la fila y el nivel son siempre los cuatro últimos dígitos.
  (int, int, int) parse(String p) => (
        int.parse(p.substring(0, p.length - 4)),
        int.parse(p.substring(p.length - 4, p.length - 2)),
        int.parse(p.substring(p.length - 2)),
      );
  String code((int, int, int) p) => '${p.$1.toString().padLeft(3, '0')}'
      '${p.$2.toString().padLeft(2, '0')}${p.$3.toString().padLeft(2, '0')}';
  final down = [for (final g in groups) if (g.$2 == port) parse(g.$1)];
  final result = <String>{};
  for (final g in groups) {
    if (g.$2 == port) continue;
    final (bay, row, tier) = parse(g.$1);
    final over = down.any((d) =>
        d.$2 == row &&
        (d.$3 >= 80) == (tier >= 80) &&
        foot(d.$1).intersection(foot(bay)).isNotEmpty &&
        tier > d.$3);
    if (over) result.add(code((bay, row, tier)));
  }
  return result;
}
