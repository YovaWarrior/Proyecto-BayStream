import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';
import 't76_fixture.dart' show t76Movement;

const t82Header = "UNB+UNOA:2+TEST+TEST+260101:0000+OLD'"
    "UNH+OLDM+BAPLIE:D:95B:UN:SMDG20'BGM++OLDDOC+9'"
    "DTM+137:2601010000:201'TDT+20+VTEST+++TEST:172:20+++:::BUQUE PRUEBA'"
    "LOC+5+GTSTC:139:6'RFF+VON:VTEST'";
const t82Transit = "LOC+147+0010282::5'FTX+AAA+++DATO CONSERVADO'"
    "MEA+VGM++KGM:7266.59'MEA+T++KGM:3900'LOC+9+HNPCR:139:6'"
    "LOC+11+PAMIT:139:6'EQD+CN+TSTU0000105+22G1+++5'NAD+CA+TEST:172:20'"
    "DGS+IMD+9+3077+++++++9:0:0'";
const t82ArrivalEdi = '$t82Header$t82Transit'
    "LOC+147+0030984::5'MEA+WT++KGM:17000'LOC+9+HNPCR:139:6'LOC+11+GTSTC:139:6'"
    "EQD+CN+TSTU0000110+22G1+++5'UNT+1+OLDM'UNZ+1+OLD'";
const t82LoadingEdi = '$t82Header$t82Transit'
    "LOC+147+0030282::5'MEA+WT++KGM:7200'LOC+9+GTSTC:139:6'LOC+11+PAMIT:139:6'"
    "EQD+CN+TSTU0000014+22G1+++5'NAD+CA+TEST:172:20'"
    "LOC+147+0030984::5'MEA+WT++KGM:2100'LOC+9+GTSTC:139:6'LOC+11+JMKWL:139:6'"
    "EQD+CN++22G1+++4'NAD+CA+TEST:172:20'UNT+1+OLDM'UNZ+1+OLD'";
final t82Loading =
    BaplieParserService().parse(t82LoadingEdi).copyWith(portOfCall: 'GTSTC');
final t82Arrival =
    BaplieParserService().parse(t82ArrivalEdi).copyWith(portOfCall: 'GTSTC');
final t82List = ExportList(fileName: 'sintetico.xlsx', rows: [
  ExportListRow(
      sheetRow: 2,
      order: 5,
      containerId: 'TSTU0000014',
      status: ContainerStatus.full,
      listType: '22G1',
      listPod: 'PAMIT',
      listLine: 'TEST',
      tareKg: 3900,
      vgmKg: 7266.59,
      imdgClass: '9',
      unNumbers: ['3082', '3077']),
  ExportListRow(
      sheetRow: 3,
      order: 12,
      containerId: 'TSTU0000020',
      status: ContainerStatus.empty,
      listType: '22G1',
      listPod: 'JMKWL',
      listLine: 'TEST',
      tareKg: 2185),
]);
final t82Operation = Operation(
    id: 'op',
    vesselName: 'BUQUE PRUEBA',
    voyageNumber: 'VTEST',
    portOfCall: 'GTSTC',
    createdAt: DateTime.utc(2026),
    sources: [
      const OperationSource(
          kind: OperationSourceKind.arrivalBaplie,
          fileName: 'llegada.edi',
          content: t82ArrivalEdi),
      const OperationSource(
          kind: OperationSourceKind.loadingBaplie,
          fileName: 'carga.edi',
          content: t82LoadingEdi),
    ]);
Movement t82Move(MovementDraft draft, int sequence) =>
    t76Movement(draft, sequence);
final t82Loads = [
  t82Move(MovementDraft.discharge('op', 'TSTU0000110', '0030984'), 1),
  t82Move(MovementDraft.loadFull('op', 'TSTU0000014', '0030282', order: 5), 2),
  t82Move(
      MovementDraft.assignEmpty('op', '0030984', 'TSTU0000020', 2185,
          order: 12),
      3),
];
LoadingOperation t82Derive([Iterable<Movement> moves = const []]) =>
    LoadingOperation.build(
        operationId: 'op',
        arrival: t82Arrival,
        loading: t82Loading,
        list: t82List,
        movements: moves);
