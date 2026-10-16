import 'dart:io';

import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/entities/stowage_validation_result.dart';
import 'package:baystream/features/vessel/domain/services/reefer_socket_validator.dart';
import 'package:baystream/features/vessel/presentation/widgets/voyage_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 't86_corpus_support.dart';

/// Corpus externo: flutter test tool/t56_corpus_test.dart
/// --dart-define=BAYSTREAM_CORPUS_DIRECTORY=CARPETA_DEL_CORPUS
///
/// Los inventarios «declarados» de aquí son escenarios construidos desde la
/// propuesta del archivo, no datos de un buque.
void main() {
  const corpus = String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');
  String raw(String code) {
    expect(corpus, isNotEmpty);
    return File('$corpus/CORPUS_$code.edi').readAsStringSync();
  }

  VesselVoyage read(String code) => code == 'A06'
      ? readA06WithNotice(raw(code))
      : BaplieParserService().parse(raw(code));

  const holdBays = [
    1, 2, 3, 5, 6, 7, 9, 10, 11, 13, 14, 15, 17, 18, 19, 21, 22, 23, 25, 26, 27
  ];

  for (final loadingPlan in ['A08', 'A08v_VGM']) {
    test('T-56 las 21 bahías con bodega de A07 ∪ $loadingPlan', () {
      final arrival = read('A07');
      final loading = read(loadingPlan);
      final geometry = VesselGeometry.proposeFrom(
          [...arrival.stowagePositions, ...loading.stowagePositions]);
      final observed = {
        ...observedHoldBays(arrival, geometry),
        ...observedHoldBays(loading, geometry)
      };
      final profile = VesselProfile.proposeFrom(loading).copyWith(
          geometry: geometry, observedHoldBayNumbers: observed);
      expect(profile.observedHoldBayNumbers.toList()..sort(), holdBays);
      // Cotejo sin el lector: LOC+147 de bodega y la sombra de cada 40 o 45.
      expect(
          {..._rawHoldBays(raw('A07')), ..._rawHoldBays(raw(loadingPlan))}
              .toList()
            ..sort(),
          holdBays);
      stdout.writeln('T-56 A07 ∪ $loadingPlan: ${holdBays.length} bahías '
          'con bodega: ${holdBays.map((b) => b.toString().padLeft(2, '0')).join(', ')}');
    });
  }

  const sources = [
    'A01', 'A02', 'A03', 'A03v_VGM', 'A04', 'A05', 'A06', 'A07', 'A08',
    'A08v_VGM'
  ];
  test('T-56 regla de tomas antes y después, fuentes con perfil propuesto', () {
    for (final code in sources) {
      final parsed = read(code);
      final proposal = VesselProfile.proposeFrom(parsed);
      final voyage = parsed.withGeometry(proposal.geometry);
      for (final origin in [
        VesselProfileOrigin.proposedFromFile,
        VesselProfileOrigin.declaredByUser
      ]) {
        final profile = proposal.copyWith(reeferSlotsOrigin: origin);
        final diff = _compare(voyage.containers, profile);
        stdout.writeln('T-56 $code ${origin.name}: '
            '${voyage.containers.where((c) => c.isReefer).length} refrigerados, '
            '${profile.reeferSlots.length} tomas; antes ${diff.before} '
            'alertas, después ${diff.after}');
        // La propuesta lleva la toma exacta de cada refrigerado ubicado.
        expect(diff.after, diff.before, reason: code);
      }
    }
  });

  // Mismo buque, otro viaje: el inventario de uno contra la carga del otro.
  const crosses = [
    ('A05', 'A06'), ('A06', 'A05'), ('A07', 'A08'), ('A08', 'A07'),
    ('A07', 'A08v_VGM')
  ];
  for (final (inventory, cargo) in crosses) {
    test('T-56 tomas de $inventory contra la carga de $cargo', () {
      final from = read(inventory);
      final to = read(cargo);
      final geometry = VesselGeometry.proposeFrom(
          [...from.stowagePositions, ...to.stowagePositions]);
      final profile = VesselProfile.proposeFrom(from).copyWith(
          geometry: geometry,
          reeferSlotsOrigin: VesselProfileOrigin.declaredByUser);
      final diff = _compare(to.withGeometry(geometry).containers, profile);
      stdout.writeln('T-56 $inventory → $cargo: antes ${diff.before}, '
          'después ${diff.after}; resueltas por celda ${diff.resolved}, '
          'pasan a aviso de extremo ${diff.toEndWarning}');
    });
  }

  test('T-56 escenario de T-55 en A01: 82 avisos de extremo y 9 conformes', () {
    final parsed = read('A01');
    final proposal = VesselProfile.proposeFrom(parsed);
    final voyage = parsed.withGeometry(proposal.geometry);
    final declared = proposal.copyWith(
        reeferSlotsOrigin: VesselProfileOrigin.declaredByUser);
    final reefers = voyage.containers.where((c) => c.isReefer).toList();
    ContainerUnit moved(ContainerUnit c, String iso, int bay) {
      final p = c.stowagePosition!;
      return c.copyWith(
          id: '${c.id}-t56-$bay',
          containerId: '${c.containerId}@$bay',
          isoSizeType: iso,
          stowagePosition: IsoCoordinateParser.fromValues(
              bay: bay, row: p.row, tier: p.tier));
    }

    // La misma construcción de tool/t55_tomas_paridad.dart.
    final twenties = [
      for (final c in reefers.where((c) => (c.sizeInFeet ?? 0) >= 40))
        for (final b in [c.stowagePosition!.bay - 1, c.stowagePosition!.bay + 1])
          moved(c, '22R1', b),
    ];
    final forties = [
      for (final c in reefers.where((c) => c.sizeInFeet == 20))
        moved(c, '45R1', c.stowagePosition!.bay % 4 == 1
            ? c.stowagePosition!.bay + 1
            : c.stowagePosition!.bay - 1),
    ];
    expect((twenties.length, forties.length), (82, 9));
    final d20 = _compare(twenties, declared);
    final d40 = _compare(forties, declared);
    expect((d20.before, d40.before), (82, 9));
    expect(d20.after, 82);
    expect(d20.toEndWarning, 82);
    expect(d40.after, 0);
    expect(d40.resolved, 9);
    stdout.writeln('T-56 escenario T-55 en A01: 91 errores → '
        '${d20.toEndWarning} avisos de extremo y ${d40.resolved} conformes');
  });

  testWidgets('T-56 A06 en GTPBR: 717 sin puerto de carga en el archivo',
      (tester) async {
    final parsed = read('A06');
    final voyage = parsed.withGeometry(
        VesselProfile.proposeFrom(parsed).geometry,
        portOfCall: 'GTPBR');
    expect(voyage.cargoCountsFor('GTPBR'),
        (loaded: 0, discharged: 0, transit: 0));
    expect(voyage.withoutLoadingPortAt('GTPBR'),
        (containers: 717, reserved: 0));
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
                child: VoyageSummaryCard(voyage: voyage)))));
    const text = '0 se descargan · 0 se cargan · 0 de paso · '
        '717 sin puerto de carga en el archivo';
    expect(find.text(text), findsOneWidget);
    expect(tester.takeException(), isNull);
    stdout.writeln('T-56 A06 GTPBR: $text');
  });

  test('T-56 las demás fuentes no cambian su resumen', () {
    for (final code in sources.where((c) => c != 'A06')) {
      final v = read(code);
      final port = v.proposedPortOfCall;
      final unknown = v.withoutLoadingPortAt(port);
      stdout.writeln('T-56 $code en $port: ${unknown.containers} contenedores '
          'y ${unknown.reserved} reservas sin puerto de carga');
      expect(unknown, (containers: 0, reserved: 0), reason: code);
    }
  });
}

/// Bahías con bodega leídas del texto, sin el lector de BayStream: el nivel de
/// cada LOC+147 por debajo de 80, y las dos impares vecinas de un 40 o 45.
Set<int> _rawHoldBays(String edi) {
  final bays = <int>{};
  String? position;
  for (final segment in edi.split("'")) {
    final s = segment.trim();
    final loc = RegExp(r'^LOC\+147\+(\d{6,7})').firstMatch(s);
    if (loc != null) {
      position = loc.group(1)!.padLeft(7, '0');
      continue;
    }
    final eqd = RegExp(r'^EQD\+CN\+[^+]*\+([^+:]*)').firstMatch(s);
    if (eqd == null || position == null) continue;
    final bay = int.parse(position.substring(0, 3));
    final tier = int.parse(position.substring(5, 7));
    position = null;
    if (tier >= 80) continue;
    bays.add(bay);
    final type = eqd.group(1)!;
    if (bay.isEven && (type.startsWith('4') || type.startsWith('L'))) {
      bays.addAll([bay - 1, bay + 1].where((b) => b >= 1));
    }
  }
  return bays;
}

/// La regla de antes (código exacto) contra la de T-56 (celda física).
({int before, int after, int resolved, int toEndWarning}) _compare(
    List<ContainerUnit> containers, VesselProfile profile) {
  final reefers = containers.where((c) => c.isReefer).toList();
  final before = reefers
      .where((c) =>
          c.stowagePosition == null ||
          !profile.geometry.covers(c.stowagePosition!) ||
          !profile.hasReeferSocket(c.stowagePosition!.toIsoCode()))
      .map((c) => c.containerId)
      .toSet();
  final results = const ReeferSocketValidator().validate(reefers, profile);
  final after = {for (final r in results) r.containerIds.single: r};
  // Ninguna alerta nueva.
  expect(after.keys.toSet().difference(before), isEmpty);
  var resolved = 0, toEndWarning = 0;
  for (final id in before) {
    final c = reefers.firstWhere((c) => c.containerId == id);
    final p = c.stowagePosition;
    String code(int bay) =>
        '${bay.toString().padLeft(3, '0')}${p!.rowPadded}${p.tierPadded}';
    final neighborSocket = p != null &&
        [p.bay - 1, p.bay + 1].any((b) => b >= 1 && profile.hasReeferSocket(code(b)));
    final result = after[id];
    if (result == null) {
      // Desaparece: un 40 en par con la toma de una impar vecina.
      expect(p!.bay.isEven && neighborSocket, isTrue, reason: id);
      resolved++;
    } else if (result.description.contains('no consta en qué extremo')) {
      // Pasa a aviso: un 20 en impar con la toma de una par vecina.
      expect(p!.bay.isOdd && neighborSocket, isTrue, reason: id);
      expect(result.severity, ValidationSeverity.warning);
      toEndWarning++;
    }
  }
  return (
    before: before.length,
    after: after.length,
    resolved: resolved,
    toEndWarning: toEndWarning,
  );
}
