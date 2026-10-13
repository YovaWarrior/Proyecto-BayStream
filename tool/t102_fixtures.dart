import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';

/// Solo datos sintéticos. Completar los faltantes permite comparar las pilas.
String t102Baplie({bool complete = false}) => '''UNH+1+BAPLIE:D:95B:UN:SMDG22'
TDT+20+T102+1++TST:172:20+++9999999:146::BUQUE PRUEBA T102'
LOC+147+0010282::5'
MEA+VGM++KGM:28700'
EQD+CN+TSTU0000010+22G1:102:5++2+5'
NAD+CA+TST'
LOC+147+0010284::5'
${complete ? "MEA+WT++KGM:1000'" : ''}
EQD+CN+TSTU0000025+22G1:102:5++2+5'
LOC+147+0010182::5'
MEA+WT++KGM:21000'
EQD+CN+TSTU0000030+22G1:102:5++2+5'
LOC+147+0010102::5'
MEA+WT++KGM:25000'
MEA+VGM++KGM:30000'
EQD+CN+TSTU0000046+45R1:102:5++2+5'
LOC+147+0010002::5'
${complete ? "MEA+WT++KGM:2000'" : ''}
EQD+CN+TSTU0000051+22G1:102:5++2+5'
LOC+147+0010202::5'
MEA+WT++KGM:0'
EQD+CN+TSTU0000067+22G1:102:5++2+4'
LOC+147+0010184::5'
EQD+CN++22G1:102:5++2+4'
UNT+1+1' ''';

VesselVoyage t102Voyage({bool complete = false}) {
  final parsed = BaplieParserService().parse(t102Baplie(complete: complete));
  return parsed.withGeometry(const VesselGeometry(
    portRows: 1,
    starboardRows: 1,
    holdTiers: [2],
    deckTiers: [82, 84],
  ));
}
