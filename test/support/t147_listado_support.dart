// T-147 · El caso sintético del listado con POT, con las formas del caso A09
// (10.151, hallazgos 3 y 5): las columnas POT y POD llenas, con el destino
// final en el POD; un separador de agencia con «COD.» y otro con «CODIGO»;
// las secciones «TRANSBORDOS», «VACIOS» y «AGREGADOS», y un plan de carga
// con llenos numerados y celdas reservadas. Todo inventado.
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/data/services/export_list_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/iso6346_check_digit.dart';

/// Una matrícula sintética con su dígito de control correcto.
String t147Matricula(int n) {
  final base = 'TSTU${n.toString().padLeft(6, '0')}';
  for (var digito = 0; digito < 10; digito++) {
    if (Iso6346CheckDigit.isValid('$base$digito') ?? false) {
      return '$base$digito';
    }
  }
  throw StateError('Sin dígito de control para $base');
}

String _grupo(String posicion, String numero, String tipo, String descarga,
        String linea,
        {String carga = 'GTSTC', int peso = 20000, String estado = '5'}) =>
    "LOC+147+$posicion::5'MEA+VGM++KGM:$peso'"
    "LOC+9+$carga:139:6'LOC+11+$descarga:139:6'RFF+BM:1'"
    "EQD+CN+$numero+$tipo+++$estado'NAD+CA+$linea:172:20'";

/// El plan de carga: cuatro llenos que suben en GTSTC, cuatro celdas
/// reservadas (con el número en blanco) y uno de paso.
final t147PlanEdi = "UNB+UNOA:2+EMISOR+RECEPTOR+261118:2200+REF147'"
    "UNH+M147+BAPLIE:D:95B:UN:SMDG20'BGM++DOC147+9'"
    "DTM+137:2611182200:201'"
    "TDT+20+VIAJE147+++LNH:172:20+++9000147:146:11:BUQUE SINTETICO'"
    "LOC+5+GTSTC:139:6'LOC+61+COTRB:139:6'RFF+VON:VIAJE147'"
    '${_grupo('0100282', t147Matricula(1), '45G1', 'COCTG', 'LNH')}'
    '${_grupo('0100482', t147Matricula(2), '45G1', 'COCTG', 'LNH')}'
    '${_grupo('0110282', t147Matricula(3), '22G1', 'COTRB', 'LNH')}'
    '${_grupo('0140282', t147Matricula(4), '45R1', 'JMKIN', 'LNJ')}'
    '${_grupo('0180082', '', '45G1', 'COTRB', 'LNH', peso: 3800, estado: '4')}'
    '${_grupo('0180282', '', '45G1', 'COTRB', 'LNH', peso: 3800, estado: '4')}'
    '${_grupo('0180084', '', '45R1', 'JMKIN', 'LNH', peso: 4700, estado: '4')}'
    '${_grupo('0190682', '', '22G1', 'JMKIN', 'LNJ', peso: 2100, estado: '4')}'
    '${_grupo('0300282', t147Matricula(90), '45G1', 'USHOU', 'LNK', carga: 'HNPCR')}'
    "UNT+1+M147'UNZ+1+REF147'";

VesselVoyage t147Plan() =>
    BaplieParserService().parse(t147PlanEdi).copyWith(portOfCall: 'GTSTC');

const _encabezado = <Object?>[
  'OR', 'CONTENEDOR', 'TIPO', 'POT', 'POD', 'TARA', 'PESO NETO', 'PESO VGM',
  'REEFER TEMP', 'ORIG', 'F', 'E', 'CONTENIDO ', 'HORA', 'MARCHAMO', 'OPR',
];

List<Object?> _fila(int orden, int numero, String tipo, String? pot,
        String pod, String linea,
        {bool vacio = false}) =>
    [
      orden, t147Matricula(numero), tipo, pot, pod, vacio ? 3900 : 3800,
      null, vacio ? null : 20000.4, null, 'GT', vacio ? null : 'X',
      vacio ? 'X' : null, vacio ? 'VACIO EN PATIO' : 'GENERAL CARGO', null,
      null, linea,
    ];

/// La hoja, con las siete formas de fila sin OR del caso: dos agencias (una
/// dice «COD.» y la otra «CODIGO»), «TRANSBORDOS», «VACIOS» y «AGREGADOS».
/// El POD es el destino final: coincide con el POT en la mitad de las filas.
List<List<Object?>> t147Hoja({bool conPot = true}) {
  List<Object?> fila(int orden, int numero, String tipo, String pot,
          String pod, String linea,
          {bool vacio = false}) =>
      _fila(orden, numero, tipo, conPot ? pot : null, pod, linea,
          vacio: vacio);
  return [
    ['BUQUE SINTETICO V. VIAJE147'],
    ['LISTADO DE EXPORTACION'],
    ['E.T.A. 18/11/2026'],
    _encabezado,
    ['AGENCIA UNO S.A.   COD. 00-000-001'],
    fila(1, 1, '40HC', 'COCTG', 'INMUN', 'LGH'),
    fila(2, 2, '40HC', 'COCTG', 'COCTG', 'LGH'),
    ['TRANSBORDOS'],
    fila(3, 3, '20ST', 'COTRB', 'ITLIV', 'LGH'),
    ['VACIOS'],
    fila(5, 11, '40HC', 'COTRB', 'COTRB', 'LGH', vacio: true),
    fila(6, 12, '40HC', 'COTRB', 'COTRB', 'LGH', vacio: true),
    fila(7, 13, '40RH', 'JMKIN', 'CNTAO', 'LGH', vacio: true),
    ['AGENCIA DOS S.A. CODIGO 00-000-002'],
    fila(4, 4, '40RH', 'JMKIN', 'JMKIN', 'LNJ'),
    ['AGREGADOS'],
    fila(8, 14, '20ST', 'JMKIN', 'JMKIN', 'LNJ', vacio: true),
  ];
}

ExportList t147Listado({bool conPot = true}) =>
    const ExportListParserService().parseGrid(t147Hoja(conPot: conPot),
        fileName: 'sintetico-t147.xlsx');
