import 'dart:io';

import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';

/// Plan de carga sintético que acompaña a test/fixtures/t73_listado_sintetico.xlsx
/// (tool/t73_listado_sintetico.py). Mismas rarezas que el caso real: el plan
/// trunca un VGM, dice COSPC donde el listado dice COMNG, LINB donde dice LNB,
/// trae un solo UN donde el listado declara dos y un vacío ya numerado.
const t73PlanEdi = "TDT+20+T73+++LNX:172:20+++ZZG0073:103:ZZZ:BUQUE PRUEBA'"
    "LOC+5+GTSTC:139:6'"
    "LOC+147+0140282::5'MEA+WT++KGM:20800'LOC+9+GTSTC:139:6'LOC+11+COSPC:139:6'"
    "EQD+CN+TSTU0000014+45G1+++5'NAD+CA+LNX:172:20'"
    "LOC+147+0030282::5'MEA+WT++KGM:7200'LOC+9+GTSTC:139:6'LOC+11+JMKWL:139:6'"
    "EQD+CN+TSTU0000020+22G1+++5'NAD+CA+LNX:172:20'"
    "LOC+147+0140384::5'MEA+WT++KGM:20100'LOC+9+GTSTC:139:6'LOC+11+JMKCT:139:6'"
    "EQD+CN+TSTU0000035+45G1+++5'NAD+CA+LINB:172:20'DGS+IMD+9+3077++3'"
    "LOC+147+0060204::5'MEA+WT++KGM:3700'LOC+9+GTSTC:139:6'LOC+11+PAMIT:139:6'"
    "EQD+CN+TSTU0000061+42G1+++4'NAD+CA+LNX:172:20'"
    "LOC+147+0070402::5'MEA+WT++KGM:2200'LOC+9+GTSTC:139:6'LOC+11+PAMIT:139:6'"
    "EQD+CN++22G1+++4'NAD+CA+LNX:172:20'"
    "LOC+147+0060208::5'MEA+WT++KGM:4600'LOC+9+GTSTC:139:6'LOC+11+PAMIT:139:6'"
    "EQD+CN++45R1+++4'NAD+CA+LNX:172:20'"
    "LOC+147+0140184::5'MEA+WT++KGM:7700'LOC+9+GTSTC:139:6'LOC+11+JMKCT:139:6'"
    "EQD+CN+TSTU0000090+45G1+++5'NAD+CA+LINB:172:20'"
    "LOC+147+0300282::5'MEA+WT++KGM:10000'LOC+9+HNPCR:139:6'LOC+11+PAMIT:139:6'"
    "EQD+CN+TSTU0000105+45G1+++5'NAD+CA+LNX:172:20'";

VesselVoyage t73Plan() =>
    BaplieParserService().parse(t73PlanEdi).copyWith(portOfCall: 'GTSTC');

List<int> t73ListBytes() => File('test/fixtures/t73_listado_sintetico.xlsx').readAsBytesSync();

/// La misma lista en la forma en que la guarda Excel: sharedStrings.xml,
/// números como double y PESO NETO con valor en caché (uno desactualizado).
List<int> t73ExcelListBytes() =>
    File('test/fixtures/t73_listado_sintetico_excel.xlsx').readAsBytesSync();
