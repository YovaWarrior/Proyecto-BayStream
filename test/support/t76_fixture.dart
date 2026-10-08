import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';

ContainerUnit t76Unit(String id, String position, {bool incoming = false}) =>
    ContainerUnit(
        id: 'uuid-$id',
        containerId: id,
        isoSizeType: '22G1',
        status: ContainerStatus.full,
        stowagePosition: IsoCoordinateParser.parse(position),
        operatorCode: 'TEST',
        portOfLoading: incoming ? 'HNPCR' : 'GTSTC',
        portOfDischarge: incoming ? 'GTSTC' : 'PAMIT');

ReservedSlot t76Slot(String position,
        {String type = '22G1', String pod = 'PAMIT', String line = 'TEST'}) =>
    ReservedSlot(
        stowagePosition: IsoCoordinateParser.parse(position),
        isoSizeType: type,
        status: ContainerStatus.empty,
        portOfLoading: 'GTSTC',
        portOfDischarge: pod,
        operatorCode: line,
        nominalWeight: 2000);

VesselVoyage t76Voyage(List<ContainerUnit> units,
    {List<ReservedSlot> slots = const []}) {
  final voyage = VesselVoyage(
      id: 'synthetic',
      vessel: const Vessel(id: 'test', name: 'BUQUE PRUEBA'),
      voyageNumber: 'VTEST',
      portOfCall: 'GTSTC',
      containers: units,
      reservedSlots: slots,
      bays: {
        for (final bay in units.map((u) => u.stowagePosition!.bay).toSet())
          bay: Bay(
              bayNumber: bay,
              containers:
                  units.where((u) => u.stowagePosition!.bay == bay).toList())
      });
  return voyage.withGeometry(VesselProfile.proposeFrom(voyage).geometry,
      portOfCall: 'GTSTC');
}

final t76Arrival = t76Voyage([
  t76Unit('INCOMING1', '0030282', incoming: true),
  t76Unit('INCOMING2', '0030482', incoming: true)
]);
final t76Loading = t76Voyage([
  t76Unit('FULL0001234', '0030282'),
  t76Unit('FULL0005678', '0030682')
], slots: [
  t76Slot('0030482'),
  t76Slot('0030882'),
  t76Slot('0050282'),
  t76Slot('0030182', type: '45G1'),
  t76Slot('0030382', pod: 'JMKCT'),
  t76Slot('0030582', line: 'OTHER')
]);

ExportListRow t76Row(int order, String container,
        {bool empty = false, double tare = 2100}) =>
    ExportListRow(
        sheetRow: order,
        order: order,
        containerId: container,
        status: empty ? ContainerStatus.empty : ContainerStatus.full,
        listType: '22G1',
        listPod: 'PAMIT',
        listLine: 'TEST',
        tareKg: tare);
final t76List = ExportList(fileName: 'sintetico.xlsx', rows: [
  t76Row(1, 'FULL0001234'),
  t76Row(2, 'FULL0005678'),
  t76Row(12, 'EMPTY0000012', empty: true, tare: 2185),
  t76Row(13, 'EMPTY0000013', empty: true, tare: 2300),
]);

Movement t76Movement(MovementDraft draft, int sequence) => Movement(
    id: 'm$sequence',
    operationId: draft.operationId,
    type: draft.type,
    target: draft.target,
    payload: draft.payload,
    author: const MovementAuthor(name: 'Prueba', role: OperatorRole.dock),
    deviceId: 'test',
    sequence: sequence,
    createdAt: DateTime.utc(2026, 1, 1).add(Duration(minutes: sequence)));

LoadingOperation t76Operation([List<Movement> events = const []]) =>
    LoadingOperation.build(
        operationId: 'op',
        arrival: t76Arrival,
        loading: t76Loading,
        list: t76List,
        movements: events);
