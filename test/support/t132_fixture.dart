import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/departure_baplie_writer.dart';
import 'package:baystream/features/vessel/domain/services/departure_baplie_review.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';
import 't82_fixture.dart' show t82Header, t82Move;

const t132Dgs = 'DGS+IMD+6.1:35+2902:INFO+23:CEL+II+EMS+MFAG+TREM+MP+6.1:3:0';
const t132Auxiliary =
    "FTX+AAA+++CARGA ESPECIAL?' CON TILDE á'LOC+83+SERVICIO:139:6'RNG+5+CEL:-20:-16'";
String t132Group(
  int number, {
  String extra = '',
  String pol = 'GTSTC',
  String type = '22G1',
}) =>
    "LOC+147+0030${number}82::5'${extra}MEA+WT++KGM:17000'"
    "LOC+9+$pol:139:6'LOC+11+PAMIT:139:6'RFF+BM:ABC'"
    "EQD+CN+TSTU000132$number+$type:102:5++2+5'NAD+CA+OLD:172:20'";

ExportListRow t132Row(
  int number, {
  String? temperature,
  String? hazard,
  List<String> uns = const [],
  double weight = 18837.129999999997,
  double tare = 3900.5,
  String? pot = 'PAMIT',
  String line = 'TEST',
  String contents = '',
}) =>
    ExportListRow(
      sheetRow: number + 5,
      order: number,
      containerId: 'TSTU000132$number',
      status: ContainerStatus.full,
      listType: '22G1',
      listPod: 'PAMIT',
      listPot: pot,
      listLine: line,
      tareKg: tare,
      vgmKg: weight,
      reeferTemperature: temperature,
      imdgClass: hazard,
      unNumbers: uns,
      contents: contents,
    );

class T132Fixture {
  final String source;
  final ExportList list;
  late final voyage =
      BaplieParserService().parse(source).copyWith(portOfCall: 'GTSTC');
  late final operation = Operation(
    id: 't132',
    vesselName: 'BUQUE SINTETICO',
    voyageNumber: 'V132',
    portOfCall: 'GTSTC',
    createdAt: DateTime.utc(2026),
    sources: [
      OperationSource(
        kind: OperationSourceKind.loadingBaplie,
        fileName: 't132.edi',
        content: source,
      ),
    ],
  );
  late final List<Movement> movements;
  late final LoadingOperation data;
  T132Fixture({
    required String cargo,
    required List<ExportListRow> rows,
    List<int> loaded = const [1],
    String charset = 'UNOC',
    List<Movement> extraMovements = const [],
  })  : source = "${t82Header.replaceFirst('UNOA', charset)}$cargo"
            "UNT+1+OLDM'UNZ+1+OLD'",
        list = ExportList(fileName: 't132.xlsx', rows: rows) {
    movements = [
      for (var i = 0; i < loaded.length; i++)
        t82Move(
          MovementDraft.loadFull(
            't132',
            'TSTU000132${loaded[i]}',
            '0030${loaded[i]}82',
            order: loaded[i],
          ),
          i + 1,
        ),
      ...extraMovements,
    ];
    data = LoadingOperation.build(
      operationId: 't132',
      loading: voyage,
      list: list,
      movements: movements,
    );
  }
  DepartureBaplie output({
    bool preview = false,
    Map<String, DepartureChoice> choices = const {},
  }) =>
      const DepartureBaplieWriter().generate(
        operation: operation,
        state: data.state,
        list: list,
        movements: movements,
        now: DateTime.utc(2026, 11, 3),
        preview: preview,
        choices: choices,
      );
}
