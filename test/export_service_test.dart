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

  group('C-6 · la posición conserva los siete dígitos en Excel', () {
    test('la posición se exporta protegida y con sus ceros a la izquierda', () {
      const conCeros = ContainerUnit(
        id: '2',
        containerId: 'TEST0000001',
        stowagePosition: IsoCoordinate(
          bay: 3,
          row: 4,
          tier: 10,
          rawCode: '0030410',
        ),
      );
      const viaje = VesselVoyage(
        id: 'voyage-2',
        vessel: Vessel(id: 'vessel-2', name: 'Buque Prueba'),
        voyageNumber: 'V002',
        containers: [conCeros],
      );

      final csv = service.serializeCsv(viaje);

      // Los siete dígitos completos, no los cinco que deja Excel al leerlo
      // como número.
      expect(csv, contains('"\t0030410"'));
      expect(csv, isNot(contains(',30410,')));
    });

    test('no se usa la forma de fórmula para forzar el texto', () {
      const conCeros = ContainerUnit(
        id: '3',
        containerId: 'TEST0000002',
        stowagePosition: IsoCoordinate(
          bay: 6,
          row: 6,
          tier: 88,
          rawCode: '0060688',
        ),
      );
      const viaje = VesselVoyage(
        id: 'voyage-3',
        vessel: Vessel(id: 'vessel-3', name: 'Buque Prueba'),
        voyageNumber: 'V003',
        containers: [conCeros],
      );

      final csv = service.serializeCsv(viaje);

      // `="0060688"` resolvería los ceros creando el defecto 5.4.
      expect(csv, contains('0060688'));
      expect(csv, isNot(contains('="')));
    });
  });

  group('Defecto 5.4 · inyección de fórmulas', () {
    VesselVoyage voyageConTexto(String texto) => VesselVoyage(
          id: 'voyage-x',
          vessel: const Vessel(id: 'vessel-x', name: 'Buque Prueba'),
          voyageNumber: 'V004',
          containers: [
            ContainerUnit(
              id: '9',
              containerId: 'TEST0000009',
              operatorCode: texto,
            ),
          ],
        );

    test('neutraliza los prefijos =, + y @ que vienen del archivo', () {
      for (final ataque in [
        '=cmd|\'/c calc\'!A1',
        '+1+1',
        '@SUM(1+1)',
      ]) {
        final csv = service.serializeCsv(voyageConTexto(ataque));

        expect(csv, contains('"\t$ataque"'), reason: ataque);
      }
    });

    test('neutraliza el menos solo cuando no forma un número', () {
      final ataque = service.serializeCsv(voyageConTexto('-2+3+cmd|x'));

      expect(ataque, contains('"\t-2+3+cmd|x"'));
    });

    test('un número negativo legítimo sigue siendo número', () {
      // La temperatura del contenedor de referencia es -18.5: protegerla la
      // volvería texto en Excel y dejaría de poder promediarse.
      final csv = service.serializeCsv(voyage);

      expect(csv, contains(',-18.5,'));
      expect(csv, isNot(contains('\t-18.5')));
    });

    test('los pesos y medidas no se protegen sin necesidad', () {
      final csv = service.serializeCsv(voyage);

      expect(csv, contains('25000.5'));
      expect(csv, isNot(contains('"\t25000.5"')));
    });
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
