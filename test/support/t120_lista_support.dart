// T-120 · Lo común a las pruebas de la Lista y del buscador: un buque
// sintético del tamaño que se pida, leído por el lector del producto, y la
// página del viaje en la pestaña pedida.
//
// Buque y números sintéticos (BUQUE LISTA, TSTU); sin nube ni almacén real.
// Solo usa piezas que ya existían antes de T-120, para que las pruebas de la
// página compilen también contra el código de antes (las rojas).
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/widgets/navegacion_del_viaje.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 't117_oficina_support.dart';

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
/// los tres primeros múltiplos de 97 vienen sin `LOC+11` (Sin destino).
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

final Map<int, VesselVoyage> _leidos = <int, VesselVoyage>{};

/// El buque de [n] contenedores, publicado sin escala, con su geometría.
VesselVoyage t120Viaje([int n = 120]) => _leidos.putIfAbsent(n, () {
      final leido = BaplieParserService().parse(t120Baplie(n));
      return leido.withGeometry(VesselProfile.proposeFrom(leido).geometry);
    });

/// Un buque de [n] contenedores con solo GTSTC, USHOU y PAMIT: en
/// Estadísticas, «Sin destino» tiene su propia barra (no cae en «Otros»).
VesselVoyage t120ViajeDePocosPuertos([int n = 120]) {
  final leido = BaplieParserService()
      .parse(t120Baplie(n, puertos: const ['GTSTC', 'GTSTC', 'USHOU', 'PAMIT']));
  return leido.withGeometry(VesselProfile.proposeFrom(leido).geometry);
}

/// La página del viaje en [pestana], con [tamano] y [letra].
Future<ProviderContainer> t120Pump(
  WidgetTester tester, {
  Size tamano = const Size(1366, 690),
  double letra = 1.0,
  VesselVoyage? voyage,
  bool oscuro = false,
  DestinoDelViaje pestana = DestinoDelViaje.lista,
}) async {
  final scope = await t117Pump(tester,
      tamano: tamano, letra: letra, voyage: voyage ?? t120Viaje(), oscuro: oscuro);
  scope.read(destinoDelViajeProvider.notifier).ir(pestana);
  await tester.pumpAndSettle();
  return scope;
}

/// Las tarjetas de la Lista que están construidas ahora.
Finder t120Tarjetas() => find.byWidgetPredicate((Widget w) =>
    w.runtimeType.toString() == '_ContainerCard');

/// El chip de filtro de [fila] («naviera», «destino», «carga») con [clave].
Finder t120Chip(String fila, String clave) =>
    find.byKey(ValueKey<String>('filtro-$fila-$clave'));
