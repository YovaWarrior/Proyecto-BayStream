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

import '../../tool/t120_buque.dart';
import 't117_oficina_support.dart';

// El generador del buque vive en tool/t120_buque.dart, que también lo escribe
// a un archivo para mirarlo en un banco (corrección 1, R4): uno solo.
export '../../tool/t120_buque.dart'
    show t120Baplie, t120Navieras, t120Numero, t120Puertos;

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
