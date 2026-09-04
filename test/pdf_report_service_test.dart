import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/data/services/pdf_report_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const holdContainer = ContainerUnit(
    id: '2',
    containerId: 'HOLD0000002',
    isoSizeType: '22G1',
    status: ContainerStatus.full,
    grossWeight: 21000,
    stowagePosition: IsoCoordinate(
      bay: 1,
      row: 2,
      tier: 6,
      rawCode: '0010206',
    ),
  );
  const deckContainer = ContainerUnit(
    id: '1',
    containerId: 'DECK0000001',
    isoSizeType: '45R1',
    status: ContainerStatus.full,
    grossWeight: 28000,
    vgmWeight: 28500,
    portOfLoading: 'Santo Tomás',
    portOfDischarge: 'Puerto Quetzal',
    operatorCode: 'Línea Águila',
    isReefer: true,
    stowagePosition: IsoCoordinate(
      bay: 1,
      row: 1,
      tier: 82,
      rawCode: '0010182',
    ),
  );
  const bay = Bay(
    bayNumber: 1,
    containers: [deckContainer, holdContainer],
  );
  const voyage = VesselVoyage(
    id: 'voyage-1',
    vessel: Vessel(id: 'vessel-1', name: 'Buque Águila'),
    voyageNumber: 'V001',
    direction: VoyageDirection.import_,
    containers: [deckContainer, holdContainer],
    bays: {1: bay},
  );
  const service = PdfReportService();

  test('genera un documento PDF con contenido', () async {
    final bytes = await service.generate(voyage);

    expect(bytes.length, greaterThan(1000));
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });

  test('ordena la tabla por coordenada de estiba', () {
    final sorted = service.sortedContainers(voyage);

    expect(sorted.map((container) => container.containerId), [
      'DECK0000001',
      'HOLD0000002',
    ]);
  });

  test('cuenta cada contenedor L5G1 como 2 TEU', () {
    final containers = List.generate(
      22,
      (index) => ContainerUnit(
        id: 'l5g1-$index',
        containerId: 'L5G1-$index',
        isoSizeType: 'L5G1',
      ),
    );
    final l5g1Voyage = VesselVoyage(
      id: 'voyage-l5g1',
      vessel: const Vessel(id: 'vessel-l5g1', name: 'Buque L5G1'),
      voyageNumber: 'V-L5G1',
      containers: containers,
    );

    expect(service.totalTeu(l5g1Voyage), 44);
  });
}
