import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/data/services/export_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

/// T-112 · El CSV exportado, con encabezados y valores en español. Lo guardado
/// y el JSON no cambian.
void main() {
  const service = ExportService();

  VesselVoyage voyage(List<ContainerUnit> containers) => VesselVoyage(
        id: 'voyage-112',
        vessel: const Vessel(id: 'vessel-112', name: 'Buque Prueba'),
        voyageNumber: 'V112',
        containers: containers,
      );

  List<List<String>> rows(String csv) => csv
      .substring(1) // BOM
      .split('\r\n')
      .where((line) => line.isNotEmpty)
      .map((line) => line.split(','))
      .toList();

  test('T-112 los encabezados del CSV están en español, en el orden de antes', () {
    expect(ExportService.csvHeaders, [
      'id',
      'Contenedor',
      'Tipo ISO',
      'Estado',
      'Posición',
      'Peso bruto (kg)',
      'Peso VGM (kg)',
      'Tara (kg)',
      'Puerto de carga',
      'Puerto de descarga',
      'Destino final',
      'Operador',
      'Peligroso',
      'Clase IMDG',
      'Número ONU',
      'Refrigerado',
      'Temperatura',
      'Unidad de temperatura',
      'Sobredimensionado',
      'Sobrealtura (cm)',
      'Sobreancho izquierdo (cm)',
      'Sobreancho derecho (cm)',
      'Sobrelongitud frontal (cm)',
      'Sobrelongitud trasera (cm)',
    ]);
    final header = rows(service.serializeCsv(voyage(const []))).single;
    expect(header, ExportService.csvHeaders);
    for (final english in ['containerId', 'status', 'grossWeight', 'isReefer']) {
      expect(header, isNot(contains(english)), reason: english);
    }
  });

  test('T-112 estado y banderas salen en español: lleno, vacío, desconocido, sí, no', () {
    const full = ContainerUnit(
      id: '1',
      containerId: 'TSTU1120001',
      status: ContainerStatus.full,
      isDangerous: true,
      isReefer: true,
      stowagePosition: IsoCoordinate(bay: 2, row: 1, tier: 82, rawCode: '0020182'),
    );
    const empty = ContainerUnit(
        id: '2', containerId: 'TSTU1120002', status: ContainerStatus.empty);
    const unknown = ContainerUnit(
        id: '3', containerId: 'TSTU1120003', status: ContainerStatus.unknown);

    final table = rows(service.serializeCsv(voyage(const [full, empty, unknown])));
    final status = ExportService.csvHeaders.indexOf('Estado');
    final dangerous = ExportService.csvHeaders.indexOf('Peligroso');
    final reefer = ExportService.csvHeaders.indexOf('Refrigerado');
    final oog = ExportService.csvHeaders.indexOf('Sobredimensionado');

    expect([for (final row in table.skip(1)) row[status]], ['lleno', 'vacío', 'desconocido']);
    expect(table[1][dangerous], 'sí');
    expect(table[1][reefer], 'sí');
    expect(table[1][oog], 'no');
    expect(table[2][dangerous], 'no');
    final csv = service.serializeCsv(voyage(const [full, empty, unknown]));
    for (final english in [',full,', ',empty,', ',unknown,', ',true,', ',false,']) {
      expect(csv, isNot(contains(english)), reason: english);
    }
  });

  test('T-112 el JSON del viaje no cambia: sigue siendo VesselVoyage.toJson', () {
    const full = ContainerUnit(
        id: '1', containerId: 'TSTU1120001', status: ContainerStatus.full);
    final value = voyage(const [full]);
    expect(service.serializeJson(value).contains('"status": "full"'), isTrue);
  });
}
