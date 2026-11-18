// T-120 · El buque de las pruebas de la Lista y del buscador (BUQUE LISTA),
// escrito a un archivo para mirarlo en un banco (corrección 1, R4; 10.149).
//
// Es CARGA DE PRUEBA, no un viaje (AGENTS.md: no inventar datos). Trae lo que
// ni `T99_SINTETICO_977.edi` ni el corpus traen: nueve puertos (más de siete,
// para «Otros N puertos» y «Ver los n destinos»), tres contenedores sin
// `LOC+11` («Sin destino»), cuatro navieras, refrigerados con y sin `TMP`,
// peligrosas de dos clases (3 y 2.1), fuera de medida (`DIM`) y contenedores
// con dos cargas (un refrigerado peligroso, para «reefer imo»).
//
// El generador es uno solo: las pruebas lo usan desde
// `test/support/t120_lista_support.dart`, y este script lo escribe a un
// archivo de %TEMP% y lo verifica con el lector real; si no abre o da otra
// cuenta, falla.
//
//   dart tool/t120_buque.dart "$env:TEMP\t120-buque" [977]
import 'dart:io';

import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';

import 't99_comun.dart';

/// Los puertos de descarga, con el peso de cada uno en el reparto: el primero
/// lleva la mitad, como GTSTC en el corpus.
const t120Puertos = <String>[
  'GTSTC', 'GTSTC', 'GTSTC', 'GTSTC', 'GTSTC', 'GTSTC', 'GTSTC', 'GTSTC',
  'USHOU', 'USHOU', 'USHOU', 'USHOU',
  'PAMIT', 'PAMIT',
  'JMKIN', 'COCTG', 'USMSY', 'VELAG', 'PACCT', 'JMKCT',
];

/// Las navieras, repartidas de más a menos.
const t120Navieras = <String>['LNA', 'LNA', 'LNA', 'LNB', 'LNB', 'LNC', 'LND'];

/// Un número de contenedor sintético de once posiciones (no se valida el
/// dígito de control en la Lista).
String t120Numero(int i) => 'TSTU${i.toString().padLeft(7, '0')}';

/// El BAPLIE 2.2 de un buque de [n] contenedores, en bahías pares de 48
/// celdas (8 filas, 6 niveles de cubierta). Cada 10.º es refrigerado (con
/// temperatura salvo cada 30.º, que no trae `TMP`), cada 15.º peligroso de
/// clase 3 (UN 1993) y cada 40.º de clase 2.1, cada 50.º fuera de medida, y
/// los tres primeros múltiplos de 97 vienen sin `LOC+11` (Sin destino). Los
/// múltiplos de 30 son a la vez refrigerados y peligrosos.
String t120Baplie(int n, {List<String> puertos = t120Puertos}) {
  final grupos = StringBuffer();
  for (var i = 1; i <= n; i++) {
    final celda = (i - 1) % 48;
    final bahia = 2 + 4 * ((i - 1) ~/ 48);
    final fila = (celda % 8 + 1).toString().padLeft(2, '0');
    final nivel = 82 + 2 * (celda ~/ 8);
    final posicion = '${bahia.toString().padLeft(3, '0')}$fila$nivel';
    final sinDestino = i % 97 == 0 && i <= 291;
    final puerto = puertos[i % puertos.length];
    final naviera = t120Navieras[i % t120Navieras.length];
    final refrigerado = i % 10 == 0;
    final iso = refrigerado ? '45R1' : (i.isEven ? '42G1' : '22G1');
    grupos
      ..write("LOC+147+$posicion::5'")
      ..write("MEA+AAE+VGM+KGM:${18000 + i % 7 * 1000}'")
      ..write("LOC+9+HNPCR:139:6'")
      ..write(sinDestino ? '' : "LOC+11+$puerto:139:6'")
      ..write("EQD+CN+${t120Numero(i)}+$iso+++5'")
      ..write("NAD+CA+$naviera:172:20'");
    if (refrigerado && i % 30 != 0) grupos.write("TMP+2+-18:CEL'");
    if (i % 15 == 0) grupos.write("DGS+IMD+3+1993'");
    if (i % 40 == 0) grupos.write("DGS+IMD+2.1+1950'");
    if (i % 50 == 0) grupos.write("DIM+5+CMT:30'DIM+9+CMT:::25'");
  }
  return "UNB+UNOA:2+TEST+TEST+261117:1200+T120'UNH+T120+BAPLIE:D:95B:UN:SMDG22'"
      "BGM++T120+9'TDT+20+V120+++TEST:172:20+++:::BUQUE LISTA'"
      "LOC+5+HNPCR:139:6'LOC+61+GTSTC:139:6'$grupos"
      "UNT+1+T120'UNZ+1+T120'";
}

/// Escribe `T120_BUQUE_LISTA_<n>.edi` en una carpeta nueva de %TEMP% y lo
/// verifica con el lector del producto.
void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('Uso: dart tool/t120_buque.dart <carpeta nueva en %TEMP%> [n]');
    exit(64);
  }
  exigirSalidaEnTemp(args[0], repo: Directory.current.path);
  final n = args.length > 1 ? int.parse(args[1]) : 977;
  final carpeta = carpetaNueva(args[0]);
  final texto = t120Baplie(n);
  final archivo = File('${carpeta.path}${Platform.pathSeparator}T120_BUQUE_LISTA_$n.edi')
    ..writeAsStringSync(texto);
  final viaje = BaplieParserService().parse(texto);
  final leidos = viaje.containers.length;
  if (leidos != n) {
    throw StateError('El lector leyó $leidos de $n contenedores.');
  }
  final puertos = viaje.containers.map((c) => c.portOfDischarge).toSet();
  final sinDestino = viaje.containers.where((c) => c.portOfDischarge == null);
  final dobles =
      viaje.containers.where((c) => c.isReefer && c.isDangerous).length;
  stdout
    ..writeln('${archivo.path}: $leidos leídos de $n, '
        '${puertos.whereType<String>().length} puertos, '
        '${sinDestino.length} sin destino, '
        '${viaje.containers.where((c) => c.isReefer).length} refrigerados, '
        '${viaje.containers.where((c) => c.isDangerous).length} peligrosos, '
        '${viaje.containers.where((c) => c.isOverDimension).length} fuera de medida, '
        '$dobles refrigerados peligrosos')
    ..writeln('Carga de prueba sintética, no un viaje.');
}
