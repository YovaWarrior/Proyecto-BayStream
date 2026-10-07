import 'dart:io';

import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/data/datasources/hive_vessel_data_source.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_impl.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/entities/stowage_validation_result.dart';
import 'package:baystream/features/vessel/domain/services/stack_weight_validator.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_geometry_page.dart';
import 'package:baystream/features/vessel/presentation/widgets/voyage_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _header = "TDT+20+V01N+++NV2:172:20+++9000003:146:11:BUQUE ALFA'"
    "LOC+5+GTSTC:139:6'";
const _first = "LOC+147+0030182::5'LOC+9+HNPCR:139:6'"
    "LOC+11+GTSTC:139:6'MEA+WT++KGM:10000'"
    "EQD+CN+TEST0000001+22G1+++5'NAD+CA+LNA:172:20'";
const _last = "LOC+147+0030186::5'LOC+9+GTSTC:139:6'"
    "LOC+11+JMKWL:139:6'EQD+CN+TEST0000002+22G1+++5'"
    "MEA+VGM++KGM:20000'NAD+CA+LNB:172:20'";
const _reservation = "LOC+147+0030984::5'LOC+9+GTSTC:139:6'"
    "LOC+11+PAMIT:139:6'MEA+WT++KGM:2100'"
    "EQD+CN++22G1+++4'NAD+CA+LNC:172:20'";
const _geometry = VesselGeometry(
    portRows: 6,
    starboardRows: 6,
    holdTiers: [2, 4, 6, 8, 10, 12, 14],
    deckTiers: [82, 84, 86, 88, 90],
    stackWeightLimitKg: 90000);

ReservedSlot _slot(String position,
        {String? type = '22G1',
        String? loading = 'GTSTC',
        String? discharge = 'PAMIT',
        double? weight = 2100}) =>
    ReservedSlot(
        stowagePosition: IsoCoordinateParser.parse(position),
        isoSizeType: type,
        status: ContainerStatus.empty,
        portOfLoading: loading,
        portOfDischarge: discharge,
        operatorCode: 'LNC',
        nominalWeight: weight);

VesselVoyage _reservedOnly(List<ReservedSlot> slots) => VesselVoyage(
    id: 't69-viaje',
    vessel: const Vessel(id: 't69-buque', name: 'Buque sintético'),
    voyageNumber: 'T69',
    reservedSlots: slots);

VesselVoyage _summaryVoyage() {
  final containers = [
    for (var i = 0; i < 405; i++)
      ContainerUnit(
          id: 't69-$i',
          containerId: 'SINT${i.toString().padLeft(7, '0')}',
          grossWeight: 10000,
          portOfLoading: i < 121 ? 'GTSTC' : 'HNPCR',
          portOfDischarge: 'PAMIT')
  ];
  return _reservedOnly([
    for (var i = 1; i <= 55; i++) _slot('003${i.toString().padLeft(2, '0')}84')
  ]).copyWith(containers: containers, portOfCall: 'GTSTC');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final font = FontLoader('Roboto')
      ..addFont(rootBundle.load('assets/fonts/Roboto-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Roboto-Medium.ttf'));
    await font.load();
  });
  final parser = BaplieParserService();

  test(
      'T-69 conserva una reserva entre dos contenedores sin contaminar vecinos',
      () {
    final voyage = parser.parse('$_header$_first$_reservation$_last');
    expect(voyage.totalContainers, 2);
    expect(voyage.totalReservedSlots, 1);
    final first = voyage.containers.first;
    final last = voyage.containers.last;
    expect(first.containerId, 'TEST0000001');
    expect(first.effectiveWeight, 10000);
    expect(first.portOfLoading, 'HNPCR');
    expect(first.portOfDischarge, 'GTSTC');
    expect(first.operatorCode, 'LNA');
    expect(last.containerId, 'TEST0000002');
    expect(last.effectiveWeight, 20000);
    expect(last.portOfLoading, 'GTSTC');
    expect(last.portOfDischarge, 'JMKWL');
    expect(last.operatorCode, 'LNB');
    expect(
        voyage.containers.every((c) => !c.isDangerous && !c.isReefer), isTrue);
    final slot = voyage.reservedSlots.single;
    expect(slot.key, 'R:0030984');
    expect(slot.isoSizeType, '22G1');
    expect(slot.status, ContainerStatus.empty);
    expect(slot.portOfLoading, 'GTSTC');
    expect(slot.portOfDischarge, 'PAMIT');
    expect(slot.operatorCode, 'LNC');
    expect(slot.nominalWeight, 2100);
    expect(slot.isDangerous, isFalse);
    expect(slot.isReefer, isFalse);
    expect(voyage.totalWeight, 30000);
  });

  for (final beforeEqd in [true, false]) {
    test(
        'T-69 pesos, TMP, NAD y DGS ${beforeEqd ? 'antes' : 'después'} del EQD',
        () {
      const details = "MEA+WT++KGM:4600'MEA+VGM++KGM:4700'"
          "TMP+2+-18:CEL'NAD+CA+LNC:172:20'"
          "DGS+IMD+3+1993'DGS+IMD+8+1760'";
      const eqd = "EQD+CN++45R1+++4'";
      final group = "LOC+147+0060208::5'LOC+9+GTSTC:139:6'"
          "LOC+11+PAMIT:139:6'${beforeEqd ? details + eqd : eqd + details}";
      final voyage = parser.parse('$_header$_first$group$_last');
      final slot = voyage.reservedSlots.single;
      expect(slot.nominalWeight, 4700, reason: 'VGM prevalece sobre WT');
      expect(slot.isReefer, isTrue);
      expect(slot.temperature, -18);
      expect(slot.temperatureUnit, 'C');
      expect(slot.operatorCode, 'LNC');
      expect(slot.isDangerous, isTrue);
      expect(slot.dangerousGoods.map((d) => d.hazardClass), ['3', '8']);
      expect(slot.dangerousGoods.map((d) => d.unNumber), ['1993', '1760']);
      expect(ReservedSlot.fromJson(slot.toJson()), slot,
          reason: 'temperatura y cada DGS sobreviven a la persistencia');
      for (final neighbor in voyage.containers) {
        expect(neighbor.isDangerous, isFalse);
        expect(neighbor.dangerousGoods, isEmpty);
        expect(neighbor.isReefer, isFalse);
        expect(neighbor.temperature, isNull);
      }
      expect(voyage.containers.map((c) => c.operatorCode), ['LNA', 'LNB']);
    });
  }

  for (final trailer in ['', "UNT+12+T69'"]) {
    test(
        'T-69 conserva la reserva final ${trailer.isEmpty ? 'sin UNT' : 'con UNT'}',
        () {
      final voyage = parser.parse('$_header$_first$_reservation$trailer');
      expect(voyage.totalContainers, 1);
      expect(voyage.reservedSlots.map((s) => s.key), ['R:0030984']);
    });
  }

  for (final position in ['BAD', '003098', '003A984', '']) {
    test('T-69 posición inválida «$position» no fabrica una reserva', () {
      final invalid = _reservation.replaceFirst('0030984', position);
      final voyage = parser.parse('$_header$_first$invalid$_last');
      expect(voyage.totalContainers, 2);
      expect(voyage.reservedSlots, isEmpty);
      expect(voyage.containers.map((c) => c.operatorCode), ['LNA', 'LNB']);
    });
  }
  test('T-69 EQD sin LOC de estiba no recibe una posición inventada', () {
    final voyage = parser.parse("${_header}EQD+CN++22G1+++4'$_first");
    expect(voyage.reservedSlots, isEmpty);
    expect(voyage.totalContainers, 1);
  });
  test('T-69 solo EQD de equipo CN genera una reserva', () {
    final voyage = parser.parse('$_header$_first'
        '${_reservation.replaceFirst('EQD+CN', 'EQD+CH')}$_last');
    expect(voyage.reservedSlots, isEmpty);
    expect(voyage.totalContainers, 2);
  });
  test('T-69 la reserva con número real sigue siendo un contenedor', () {
    final numbered =
        _reservation.replaceFirst('EQD+CN++22G1', 'EQD+CN+TEST0000003+22G1');
    final voyage = parser.parse('$_header$_first$numbered$_last');
    expect(voyage.totalContainers, 3);
    expect(voyage.reservedSlots, isEmpty);
    expect(voyage.totalWeight, 32100);
  });
  test('T-69 identifica la misma reserva por posición en cada lectura', () {
    final first = parser.parse('$_header$_reservation');
    final second = parser.parse('$_header$_reservation');
    expect(second.reservedSlots.single, first.reservedSlots.single);
    expect(second.reservedSlots.single.key, 'R:0030984');
    final json = first.reservedSlots.single.toJson();
    expect(json.containsKey('containerId'), isFalse);
    expect(json.containsKey('id'), isFalse);
    expect(ReservedSlot.fromJson(json), first.reservedSlots.single);
  });
  test('T-69 conserva estado lleno y estado desconocido sin suponer vacío', () {
    final full =
        parser.parse('$_header${_reservation.replaceFirst('+++4', '+++5')}');
    final unknown =
        parser.parse('$_header${_reservation.replaceFirst('+++4', '+++')}');
    expect(full.reservedSlots.single.status, ContainerStatus.full);
    expect(unknown.reservedSlots.single.status, ContainerStatus.unknown);
  });
  test(
      'T-69 una reserva sin peso o tipo conserva esos datos como no declarados',
      () {
    final voyage = parser.parse("${_header}LOC+147+0030984::5'EQD+CN+++++4'");
    expect(voyage.reservedSlots.single.isoSizeType, isNull);
    expect(voyage.reservedSlots.single.nominalWeight, isNull);
    expect(voyage.reservedSlots.single.sizeInFeet, isNull);
  });

  for (final entry
      in {'22G1': 20, '45G1': 40, '45R1': 40, 'L5G1': 45}.entries) {
    test('T-69 tamaño ${entry.key} usa la misma longitud ${entry.value} pies',
        () {
      expect(_slot('0060284', type: entry.key).sizeInFeet, entry.value);
    });
  }

  test(
      'T-69 geometría y bahías incluyen reservas y sus proyecciones de 40 pies',
      () {
    final voyage = _reservedOnly([
      _slot('0060284', type: '45G1'),
      _slot('0030984'),
    ]);
    expect(voyage.stowagePositions.map((p) => p.toIsoCode()).toSet(),
        {'0060284', '0030984'});
    final proposed = VesselProfile.proposeFrom(voyage).geometry;
    expect(proposed.coversAll(voyage.stowagePositions), isTrue);
    expect(voyage.neighborReservedSlots().keys.toSet(), {5, 7});
    expect(voyage.neighborReservedSlots()[5]!['0284']!.key, 'R:0060284');
    final declared = voyage.withGeometry(_geometry);
    expect(declared.bays.keys.toSet(), {3, 5, 6, 7});
    expect(declared.getReservedSlotsInBay(3).single.key, 'R:0030984');
    expect(declared.getReservedSlotsInBay(6).single.key, 'R:0060284');
    expect(declared.getReservedSlotsInBay(5), isEmpty,
        reason: 'una proyección no duplica la reserva');
    for (final bay in declared.bays.values) {
      expect(bay.geometry, _geometry);
      expect(bay.occupancyRate, 0);
      expect(bay.totalWeight, 0);
      expect(bay.occupiedSlotKeys, isEmpty);
    }
    expect(declared.neighborOccupiedSlots(), isEmpty);
  });

  for (final includeBays in [true, false]) {
    test('T-69 JSON con includeBays=$includeBays reconstruye las reservas', () {
      final voyage = parser
          .parse('$_header$_first$_reservation$_last')
          .withGeometry(_geometry, portOfCall: 'GTSTC');
      final json = voyage.toJson(includeBays: includeBays);
      final restored = VesselVoyage.fromJson(json);
      expect(restored, voyage);
      expect(restored.reservedSlots.single.key, 'R:0030984');
      expect(restored.totalWeight, 30000);
      expect(restored.cargoCountsFor('GTSTC'),
          (loaded: 1, discharged: 1, transit: 0));
    });
  }
  test('T-69 JSON histórico sin reservedSlots abre con una lista vacía', () {
    final voyage =
        parser.parse('$_header$_first$_last').withGeometry(_geometry);
    final old = voyage.toJson()..remove('reservedSlots');
    expect(VesselVoyage.fromJson(old).reservedSlots, isEmpty);
    expect(VesselVoyage.fromJson(old).containers, voyage.containers);
  });
  test('T-69 JSON sin bahías recupera una bahía con solo reservas', () {
    final voyage =
        _reservedOnly([_slot('0060284', type: '45G1')]).withGeometry(_geometry);
    final restored = VesselVoyage.fromJson(voyage.toJson(includeBays: false));
    expect(restored.bays.keys.toSet(), {5, 6, 7});
    expect(restored.neighborReservedSlots()[7]!['0284']!.key, 'R:0060284');
    expect(restored.totalContainers, 0);
    expect(restored.totalReservedSlots, 1);
  });
  test(
      'T-69 conteos de reservas por puertos permanecen separados de contenedores',
      () {
    final base = parser.parse('$_header$_first$_last');
    final voyage = base.copyWith(reservedSlots: [
      _slot('0030984'),
      _slot('0031084', loading: 'HNPCR', discharge: 'GTSTC'),
      _slot('0030986', loading: 'HNPCR', discharge: 'PAMIT'),
      _slot('0031086', loading: null),
    ]);
    expect(voyage.cargoCountsFor('GTSTC'), base.cargoCountsFor('GTSTC'));
    expect(voyage.reservedCountsFor('GTSTC'),
        (loaded: 1, discharged: 1, transit: 1));
    expect(
        voyage.reservedCountsFor(null), (loaded: 0, discharged: 0, transit: 0));
    expect(voyage.totalContainers, 2);
    expect(voyage.totalReservedSlots, 4);
  });
  test(
      'T-69 peso nominal no cambia ocupación, pilas ni alertas de contenedores',
      () {
    final base = parser.parse('$_header$_first$_last').withGeometry(_geometry);
    final extra = base.copyWith(reservedSlots: [
      _slot('0030184', weight: 1000000),
      _slot('0060284', type: '45G1', weight: null),
    ]).withGeometry(_geometry);
    expect(extra.totalWeight, base.totalWeight);
    expect(extra.totalGrossWeight, base.totalGrossWeight);
    expect(extra.totalVgmWeight, base.totalVgmWeight);
    expect(extra.bays[3]!.occupancyRate, base.bays[3]!.occupancyRate);
    expect(extra.bays[3]!.occupiedSlotKeys, base.bays[3]!.occupiedSlotKeys);
    expect(extra.bays[3]!.deckWeightByRow, base.bays[3]!.deckWeightByRow);
    expect(extra.bays[3]!.holdWeightByRow, base.bays[3]!.holdWeightByRow);
    expect(extra.bays[6]!.occupancyRate, 0);
    final profile =
        VesselProfile.proposeFrom(base).copyWith(geometry: _geometry);
    final alerts = const StackWeightValidator().validate(extra, profile);
    expect(alerts, const StackWeightValidator().validate(base, profile));
    expect(alerts.where((r) => r.status == ValidationStatus.notEvaluated),
        isEmpty);
  });
  test('T-69 almacén real conserva reservas al cerrar y reabrir Hive',
      () async {
    final root =
        await Directory('build/t69/test-stores').create(recursive: true);
    final directory = await root.createTemp('reserved_');
    final namespace = 't69_${DateTime.now().microsecondsSinceEpoch}';
    Future<LocalVesselRepositoryImpl> open() async =>
        LocalVesselRepositoryImpl(await HiveVesselDataSource.open(
            directory: directory.path, namespace: namespace));
    var repository = await open();
    final voyage = parser
        .parse('$_header$_first$_reservation$_last')
        .withGeometry(_geometry, portOfCall: 'GTSTC');
    Future<void> removeTemporaryStore() async {
      final resolvedRoot = await root.resolveSymbolicLinks();
      final resolvedDirectory = await directory.resolveSymbolicLinks();
      if (!resolvedDirectory
          .startsWith('$resolvedRoot${Platform.pathSeparator}')) {
        throw StateError('El almacén temporal salió de build/t69/test-stores');
      }
      await directory.delete(recursive: true);
    }

    try {
      expect((await repository.saveVoyage(voyage)).isRight(), isTrue);
      await repository.close();
      repository = await open();
      final restored =
          (await repository.getVoyageById(voyage.id)).getOrElse(() => null);
      expect(restored, voyage);
      expect(restored!.reservedSlots.single.key, 'R:0030984');
      expect(restored.totalReservedSlots, 1);
      expect(restored.totalContainers, 2);
      expect(restored.totalWeight, 30000);
    } finally {
      await repository.close();
      await removeTemporaryStore();
    }
  });

  testWidgets('T-69 ficha a 360 dp separa 121 contenedores y 55 reservas',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        theme: ThemeData(fontFamily: 'Roboto'),
        home: Scaffold(
            body: SingleChildScrollView(
                child: VoyageSummaryCard(voyage: _summaryVoyage())))));
    expect(
        find.text('Se cargan 121 contenedores y 55 reservas (176 movimientos)'),
        findsOneWidget);
    expect(find.text('De paso 284 contenedores y 0 reservas'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'T-69 diálogo a 360 dp conserva el conteo independiente de reservas',
      (tester) async {
    final voyage = _summaryVoyage();
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        theme: ThemeData(fontFamily: 'Roboto'),
        home: VesselGeometryPage(
            proposal: VesselProfile.proposeFrom(voyage).geometry,
            voyage: voyage,
            initialPortOfCall: 'GTSTC')));
    await tester.scrollUntilVisible(
        find.byKey(const ValueKey('port-split')), 300,
        scrollable: find.byType(Scrollable).first, maxScrolls: 30);
    expect(
        find.text('Se cargan 121 contenedores y 55 reservas (176 movimientos)'),
        findsOneWidget);
    expect(find.text('De paso 284 contenedores y 0 reservas'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
