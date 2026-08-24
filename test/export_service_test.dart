import 'dart:convert';

import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/data/services/export_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const container = ContainerUnit(
    id: '1',
    containerId: 'MSCU1234567',
    isoSizeType: '45R1',
    status: ContainerStatus.full,
    stowagePosition: IsoCoordinate(
      bay: 12,
      row: 1,
      tier: 82,
      rawCode: '0120182',
    ),
    grossWeight: 25000.5,
    vgmWeight: 25500,
    tareWeight: 3800,
    portOfLoading: 'Santo Tomás',
    portOfDischarge: 'Puerto Quetzal, Guatemala',
    finalDestination: 'Ciudad de Panamá',
    operatorCode: 'Línea "Águila", S.A.',
    isDangerous: true,
    imdgClass: '3',
    unNumber: '1203',
    isReefer: true,
    temperature: -18.5,
    temperatureUnit: 'C',
    isOverDimension: true,
    overHeight: 10,
    overWidthLeft: 2,
    overWidthRight: 3,
    overLengthFront: 4,
    overLengthRear: 5,
  );
  const voyage = VesselVoyage(
    id: 'voyage-1',
    vessel: Vessel(id: 'vessel-1', name: 'Buque Águila'),
    voyageNumber: 'V/001',
    containers: [container],
  );
  const service = ExportService();

  test('CSV incluye BOM, todas las columnas y campos escapados', () {
    final csv = service.serializeCsv(voyage);

    expect(csv.codeUnitAt(0), 0xfeff);
    expect(csv, startsWith('\ufeff${ExportService.csvHeaders.join(',')}\r\n'));
    expect(ExportService.csvHeaders.length, 24);
    expect(csv, contains('Santo Tomás'));
    expect(csv, contains('"Puerto Quetzal, Guatemala"'));
    expect(csv, contains('"Línea ""Águila"", S.A."'));
    expect(csv, contains('25000.5'));
  });

  test('JSON reutiliza exactamente VesselVoyage.toJson', () {
    final decoded = jsonDecode(service.serializeJson(voyage));

    expect(decoded, voyage.toJson());
  });

  test('bytes CSV conservan BOM UTF-8 y nombre seguro', () {
    final bytes = service.bytesFor(voyage, VoyageExportFormat.csv);

    expect(bytes.take(3), [0xef, 0xbb, 0xbf]);
    expect(
      service.buildFileName(voyage, VoyageExportFormat.csv),
      'BayStream_Buque Águila_V_001.csv',
    );
  });
}
