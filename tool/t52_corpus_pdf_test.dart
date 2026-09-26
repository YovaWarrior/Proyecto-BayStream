import 'dart:convert';
import 'dart:io';

import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/data/services/pdf_report_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

// Ejecutar con flutter test y BAYSTREAM_CORPUS_DIRECTORY. No usa Firebase.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('T-52 genera evidencia con A01 real y rejillas declaradas', () async {
    const directory = String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');
    expect(directory, isNotEmpty);
    final file = File('$directory/CORPUS_A01.edi');
    final parsed = BaplieParserService()
        .parse(String.fromCharCodes(await file.readAsBytes()));
    final seed = VesselGeometry.proposeFrom(parsed.stowagePositions);
    // Declaración de prueba deliberadamente mayor que la propuesta mínima.
    // No pretende ser una especificación técnica del buque anonimizado.
    final declared = seed.copyWith(
      portRows: seed.portRows + 2,
      starboardRows: seed.starboardRows + 2,
      holdTiers: [
        ...seed.holdTiers,
        seed.holdTiers.last + 2,
        seed.holdTiers.last + 4
      ],
      deckTiers: [
        ...seed.deckTiers,
        seed.deckTiers.last + 2,
        seed.deckTiers.last + 4
      ],
    );
    final voyage = parsed.withGeometry(declared);
    expect(voyage.totalContainers, 977);
    expect(voyage.bays, hasLength(34));
    final out = await Directory('output/pdf').create(recursive: true);
    const service = PdfReportService();
    await File('${out.path}/T52-CORPUS_A01.pdf')
        .writeAsBytes(await service.generate(voyage, geometry: declared));

    // Fila central vacía, niveles vacíos y huecos explícitos: C-2 y C-4.
    final cargo = ContainerUnit(
        id: 'c',
        containerId: 'PRUEBA',
        isoSizeType: '22G1',
        stowagePosition: IsoCoordinateParser.parse('0010284'));
    final sparse = VesselVoyage(
        id: 'v',
        vessel: const Vessel(id: 's', name: 'Prueba de rejilla'),
        voyageNumber: 'T52',
        containers: [
          cargo
        ],
        bays: {
          1: const Bay(bayNumber: 1).addContainer(cargo),
          3: const Bay(bayNumber: 3)
        });
    const shape = VesselGeometry(
        portRows: 2,
        starboardRows: 2,
        holdTiers: [4, 8],
        deckTiers: [84, 88, 92],
        deckTierFloor: 84);
    await File('${out.path}/T52-regresion.pdf').writeAsBytes(
        await service.generate(sparse.withGeometry(shape), geometry: shape));
    // Activa ambos mínimos del clamp para verificar el escalado a la página.
    final large = shape.copyWith(
        portRows: 25,
        starboardRows: 25,
        holdTiers: [for (var t = 2; t < 80; t += 2) t],
        deckTiers: [for (var t = 84; t <= 98; t += 2) t]);
    await File('${out.path}/T52-rejilla-amplia.pdf').writeAsBytes(
        await service.generate(sparse.withGeometry(large), geometry: large));
    final bays = voyage.bays.keys.toList()..sort();
    final metrics = {
      'containers': voyage.totalContainers,
      'bays': bays,
      'geometry': declared.toJson(),
      'rows': declared.orderedRows,
      'deckTiers': declared.deckTierNumbers,
      'holdTiers': declared.holdTierNumbers,
      'emptyBays': voyage.bays.values
          .where((b) => b.containers.isEmpty)
          .map((b) => b.bayNumber)
          .toList(),
    };
    await Directory('build/t52').create(recursive: true);
    await File('build/t52/metrics.json').writeAsString(jsonEncode(metrics));
    stdout.writeln('T52_CORPUS ${jsonEncode(metrics)}');
  });
}
