import 'dart:io';

import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/entities/stowage_validation_result.dart';
import 'package:baystream/features/vessel/domain/services/stack_weight_validator.dart';
import 'package:baystream/features/vessel/presentation/widgets/voyage_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Corpus externo: flutter test tool/t69_corpus_test.dart
/// --dart-define=BAYSTREAM_CORPUS_DIRECTORY=CARPETA_DEL_CORPUS
/// Las posiciones son las publicadas en S3-CASO-MAGELLAN-STAR.md, sección 4.
/// No se copia ningún archivo ni número de contenedor del corpus al repositorio.
const _expectedPositions = {
  '0030984',
  '0031082',
  '0250804',
  '0270806',
  '0270604',
  '0250604',
  '0030982',
  '0031084',
  '0250806',
  '0260606',
  '0261082',
  '0260284',
  '0260484',
  '0260608',
  '0260408',
  '0260486',
  '0260882',
  '0261084',
  '0260482',
  '0260810',
  '0260884',
  '0260286',
  '0260686',
  '0260682',
  '0260208',
  '0260282',
  '0260684',
  '0260808',
  '0260610',
  '0070202',
  '0050202',
  '0070402',
  '0070604',
  '0070404',
  '0070808',
  '0050404',
  '0060284',
  '0061084',
  '0060286',
  '0060210',
  '0060608',
  '0060810',
  '0060482',
  '0060282',
  '0061082',
  '0060610',
  '0060682',
  '0060484',
  '0060684',
  '0060410',
  '0060884',
  '0060486',
  '0060882',
  '0060208',
  '0060408',
};
const _expectedGroups = {
  '22G1/JMKWL/LNA': 9,
  '45G1/JMKWL/LNA': 20,
  '22G1/PAMIT/LNC': 7,
  '45G1/PAMIT/LNC': 17,
  '45R1/PAMIT/LNC': 2,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final font = FontLoader('Roboto')
      ..addFont(rootBundle.load('assets/fonts/Roboto-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Roboto-Medium.ttf'));
    await font.load();
  });
  const corpus = String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');
  VesselVoyage open(String name) {
    expect(corpus, isNotEmpty,
        reason: 'Indica el directorio del corpus externo');
    return BaplieParserService()
        .parse(File('$corpus/CORPUS_$name.edi').readAsStringSync());
  }

  VesselVoyage declared(String name) {
    final voyage = open(name);
    return voyage.withGeometry(
        VesselProfile.proposeFrom(voyage)
            .geometry
            .copyWith(stackWeightLimitKg: 90000),
        portOfCall: 'GTSTC');
  }

  for (final name in ['A08', 'A08v_VGM']) {
    test('T-69 $name: 405 contenedores, 55 reservas y posiciones exactas', () {
      final voyage = open(name);
      expect(voyage.totalContainers, 405);
      expect(voyage.totalReservedSlots, 55);
      expect(_expectedPositions, hasLength(55));
      expect(
          voyage.reservedSlots
              .map((s) => s.stowagePosition.toIsoCode())
              .toSet(),
          _expectedPositions);
      expect(voyage.reservedSlots.map((s) => s.key).toSet(), hasLength(55));
      expect(voyage.reservedSlots.any((s) => s.key == 'R:0060204'), isFalse);
      expect(
          voyage.containers
              .any((c) => c.stowagePosition?.toIsoCode() == '0060204'),
          isTrue,
          reason: 'esa posición ya trae número de contenedor');
      final groups = <String, int>{};
      for (final slot in voyage.reservedSlots) {
        final group =
            '${slot.isoSizeType}/${slot.portOfDischarge}/${slot.operatorCode}';
        groups[group] = (groups[group] ?? 0) + 1;
        expect(slot.portOfLoading, 'GTSTC');
        expect(slot.status, ContainerStatus.empty);
        expect(slot.nominalWeight, greaterThan(0));
      }
      expect(groups, _expectedGroups);
      expect(voyage.totalWeight, 6899700);
      expect(voyage.cargoCountsFor('GTSTC'),
          (loaded: 121, discharged: 0, transit: 284));
      expect(voyage.reservedCountsFor('GTSTC'),
          (loaded: 55, discharged: 0, transit: 0));
      final again = open(name);
      expect(again.reservedSlots, voyage.reservedSlots,
          reason: 'las reservas no llevan UUID ni identidad variable');
      stdout.writeln('T-69 $name: 405 contenedores · 55 reservas · '
          '460 posiciones · 6 899 700 kg · 121 + 55 = 176 cargas');
      stdout.writeln('  Grupos de reservas: $groups');
    });

    test('T-69 $name: reservas no añaden peso, ocupación ni alertas de pila',
        () {
      final voyage = declared(name);
      final withoutReservations = voyage.copyWith(reservedSlots: const []);
      expect(voyage.totalWeight, withoutReservations.totalWeight);
      expect(voyage.neighborOccupiedSlots(),
          withoutReservations.neighborOccupiedSlots());
      final containerOnly =
          VesselVoyage.fromJson(withoutReservations.toJson(includeBays: false));
      for (final entry in voyage.bays.entries) {
        final old = containerOnly.bays[entry.key];
        expect(entry.value.totalWeight, old?.totalWeight ?? 0);
        expect(
            entry.value.occupiedSlotKeys, old?.occupiedSlotKeys ?? <String>{});
        expect(entry.value.occupancyRate, old?.occupancyRate ?? 0);
      }
      final profile =
          VesselProfile.proposeFrom(voyage).copyWith(geometry: voyage.geometry);
      final alerts = const StackWeightValidator().validate(voyage, profile);
      expect(alerts,
          const StackWeightValidator().validate(containerOnly, profile));
      expect(alerts, hasLength(10));
      expect(alerts.every((r) => r.status == ValidationStatus.nonConforming),
          isTrue);
      expect(alerts.where((r) => r.status == ValidationStatus.notEvaluated),
          isEmpty);
      stdout
          .writeln('T-69 $name: 10 alertas con 90 000 kg (límite de prueba) · '
              'reservas excluidas de peso y ocupación');
    });

    testWidgets('T-69 $name: ficha a 360 dp cuenta la carga por separado',
        (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(
          theme: ThemeData(fontFamily: 'Roboto'),
          home: Scaffold(
              body: SingleChildScrollView(
                  child: VoyageSummaryCard(voyage: declared(name))))));
      expect(
          find.text(
              'Se cargan 121 contenedores y 55 reservas (176 movimientos)'),
          findsOneWidget);
      expect(
          find.text('Se descargan 0 contenedores y 0 reservas (0 movimientos)'),
          findsOneWidget);
      expect(
          find.text('De paso 284 contenedores y 0 reservas'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  for (var number = 1; number <= 7; number++) {
    final name = 'A${number.toString().padLeft(2, '0')}';
    test('T-69 $name: el corpus anterior conserva cero reservas', () {
      final voyage = open(name);
      expect(voyage.totalContainers, greaterThan(0));
      expect(voyage.reservedSlots, isEmpty);
      expect(voyage.totalReservedSlots, 0);
      stdout.writeln(
          'T-69 $name: ${voyage.totalContainers} contenedores · 0 reservas');
    });
  }
  test('T-69 WT y VGM conservan las mismas 55 reservas y las mismas 10 alertas',
      () {
    final wt = declared('A08');
    final vgm = declared('A08v_VGM');
    expect(vgm.reservedSlots, wt.reservedSlots);
    final profile =
        VesselProfile.proposeFrom(wt).copyWith(geometry: wt.geometry);
    expect(const StackWeightValidator().validate(vgm, profile),
        const StackWeightValidator().validate(wt, profile));
    for (final voyage in [wt, vgm]) {
      final restored = VesselVoyage.fromJson(voyage.toJson(includeBays: false));
      expect(restored.reservedSlots, voyage.reservedSlots);
      expect(restored.totalContainers, 405);
      expect(restored.totalReservedSlots, 55);
      expect(restored.reservedSlots.map((s) => s.key).toSet(),
          _expectedPositions.map((p) => 'R:$p').toSet());
      expect(restored.totalWeight, 6899700);
    }
  });
}
