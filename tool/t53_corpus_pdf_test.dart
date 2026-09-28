import 'dart:convert';
import 'dart:io';
import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/data/services/pdf_report_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('T-53 A01 real, sombras por posición y prioridad de carga propia', () async {
    const directory = String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');
    expect(directory, isNotEmpty);
    final voyage = BaplieParserService().parse(String.fromCharCodes(
        await File('$directory/CORPUS_A01.edi').readAsBytes()));
    final seed = VesselProfile.proposeFrom(voyage).geometry;
    final geometry = seed.copyWith(portRows: seed.portRows + 2, starboardRows: seed.starboardRows + 2,
      holdTiers: [...seed.holdTiers, seed.holdTiers.last + 2, seed.holdTiers.last + 4],
      deckTiers: [...seed.deckTiers, seed.deckTiers.last + 2, seed.deckTiers.last + 4]);
    final declared = voyage.withGeometry(geometry);
    final bays = declared.bays.keys.toList()..sort();
    final shadows = <String, List<String>>{};
    // Oráculo desde la carga par de 40/45, sin leer el conjunto derivado de Bay.
    for (final bay in bays) {
      final own = declared.bays[bay]!.containers.map((c) => c.stowagePosition?.toIsoCode().substring(3)).toSet();
      shadows['$bay'] = {for (final c in declared.containers)
        if (c.stowagePosition != null && c.stowagePosition!.bay.isEven &&
            (c.sizeInFeet == 40 || c.sizeInFeet == 45) &&
            (c.stowagePosition!.bay - bay).abs() == 1 &&
            !own.contains(c.stowagePosition!.toIsoCode().substring(3)))
          c.stowagePosition!.toIsoCode().substring(3)}.toList()..sort();
    }
    expect(declared.totalContainers, 977);
    expect(bays.length, 34);
    for (final bay in [5, 13, 15, 35, 39, 43, 45]) {
      expect(shadows['$bay'], isNotEmpty);
    }
    await Directory('build/t53').create(recursive: true);
    await Directory('output/pdf').create(recursive: true);
    const service = PdfReportService();
    await File('output/pdf/T53-CORPUS_A01.pdf').writeAsBytes(await service.generate(declared, geometry: geometry));
    await File('build/t53/metrics.json').writeAsString(jsonEncode({
      'containers': declared.totalContainers, 'weight': declared.totalGrossWeight,
      'bays': bays, 'shadows': shadows, 'rows': geometry.orderedRows,
      'tiers': [...geometry.deckTierNumbers, ...geometry.holdTierNumbers],
    }));
    final empty = ContainerUnit(id: 'empty', containerId: 'VACIO', isoSizeType: '22G1',
      status: ContainerStatus.empty, stowagePosition: IsoCoordinateParser.parse('0010282'));
    final oog = ContainerUnit(id: 'oog', containerId: 'OOG', isoSizeType: '22G1',
      status: ContainerStatus.empty, isOverDimension: true,
      stowagePosition: IsoCoordinateParser.parse('0010082'));
    const small = VesselGeometry(portRows: 1, starboardRows: 1, holdTiers: [], deckTiers: [82]);
    final comparison = VesselVoyage(id: 'comparison', vessel: const Vessel(id: 'qa', name: 'Contraste T-53'),
      voyageNumber: 'QA', containers: [empty, oog], bays: {1: Bay(bayNumber: 1,
        containers: [empty, oog], geometry: small, slotsOccupiedByNeighbors: const {'0282', '0182'})});
    // 0282 tiene carga propia y sombra: el PDF debe dibujar el contenedor.
    await File('output/pdf/T53-contraste.pdf').writeAsBytes(await service.generate(comparison, geometry: small));
    expect(comparison.totalContainers, 2);
    expect(service.sortedContainers(declared).length, 977);
  });
}
