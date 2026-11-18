import 'package:flutter/foundation.dart' show immutable;

import '../../domain/entities/container_unit.dart';
import 'consulta_de_busqueda.dart';

/// T-120 · Los filtros de la Lista (`DESIGN.md` 18): la naviera, el destino y
/// la carga especial que están elegidos.
@immutable
class FiltrosDeLaLista {
  /// Crea los filtros.
  const FiltrosDeLaLista({
    this.naviera,
    this.destino,
    this.cargas = const <CargaEspecial>{},
  });

  /// La clave de «Sin destino»: el contenedor sin `LOC+11`, o con el código
  /// en blanco. Nunca «N/A» (regla 4).
  static const String sinDestino = '';

  /// El rótulo de [sinDestino], el mismo en la Lista y en Estadísticas (D6 de
  /// la 10.148).
  static const String rotuloSinDestino = 'Sin destino';

  /// La naviera elegida, o `null` para todas.
  final String? naviera;

  /// El destino elegido ([sinDestino] para los que no traen), o `null` para
  /// todos.
  final String? destino;

  /// Las cargas especiales elegidas: cualquiera de ellas (D7). Vacío, todas.
  final Set<CargaEspecial> cargas;

  /// Si hay algún filtro.
  bool get activos => naviera != null || destino != null || cargas.isNotEmpty;

  /// La clave de destino de [contenedor].
  static String claveDeDestino(ContainerUnit contenedor) =>
      contenedor.portOfDischarge?.trim() ?? sinDestino;

  bool _porNaviera(ContainerUnit c) =>
      naviera == null || c.operatorCode == naviera;
  bool _porDestino(ContainerUnit c) =>
      destino == null || claveDeDestino(c) == destino;
  bool _porCarga(ContainerUnit c) =>
      cargas.isEmpty || cargas.any((CargaEspecial k) => k.en(c));

  /// Si [contenedor] pasa los tres filtros.
  bool coincide(ContainerUnit contenedor) =>
      _porNaviera(contenedor) &&
      _porDestino(contenedor) &&
      _porCarga(contenedor);
}

/// Un chip de una fila: su clave, cuántos hay con los otros filtros (la cuenta
/// cruzada) y cuántos hay en el viaje.
@immutable
class CuentaDeFicha<T> {
  const CuentaDeFicha(
      {required this.clave, required this.cuenta, required this.delViaje});

  /// El código de la naviera o del puerto ([FiltrosDeLaLista.sinDestino] para
  /// «Sin destino»), o la carga especial.
  final T clave;

  /// Con los otros dos filtros: la cifra del chip. En cero, va apagado.
  final int cuenta;

  /// En todo lo que va a bordo: lo que fija el orden.
  final int delViaje;
}

/// T-120 · Las cuentas cruzadas de las tres filas de la Lista, en una sola
/// pasada por lo que va a bordo (P10 de la 10.38; 10.147, punto 1).
///
/// - Cada chip cuenta lo que pasa **los otros dos** filtros: con una naviera
///   elegida, cada destino cuenta los de esa naviera, y al revés.
/// - «Todas» y «Todos» llevan el total de los otros dos filtros.
/// - **El orden no cambia al elegir:** se ordena por el total del viaje, de
///   más a menos, y a igual cuenta por código. «Sin destino» va al final, y
///   las cargas en el orden de [CargaEspecial]. Solo salen los que el viaje
///   tiene: un chip que se queda en cero con los otros filtros se apaga.
@immutable
class CuentasDeLosFiltros {
  const CuentasDeLosFiltros._({
    required this.navieras,
    required this.destinos,
    required this.cargas,
    required this.todasLasNavieras,
    required this.todosLosDestinos,
    required this.todasLasCargas,
    required this.filtrados,
  });

  /// Los chips de las navieras.
  final List<CuentaDeFicha<String>> navieras;

  /// Los chips de los destinos, con «Sin destino» al final si lo hay.
  final List<CuentaDeFicha<String>> destinos;

  /// Los chips de la carga especial, solo los que el viaje tiene.
  final List<CuentaDeFicha<CargaEspecial>> cargas;

  /// La cifra de «Todas», «Todos» y de la fila de carga sin elegir.
  final int todasLasNavieras;
  final int todosLosDestinos;
  final int todasLasCargas;

  /// Lo que pasa los tres filtros: lo que lista la Lista.
  final List<ContainerUnit> filtrados;

  /// Las cuentas de [aBordo] con [filtros].
  factory CuentasDeLosFiltros.de(
      List<ContainerUnit> aBordo, FiltrosDeLaLista filtros) {
    final navieraViaje = <String, int>{};
    final navieraCruzada = <String, int>{};
    final destinoViaje = <String, int>{};
    final destinoCruzado = <String, int>{};
    final cargaViaje = <CargaEspecial, int>{};
    final cargaCruzada = <CargaEspecial, int>{};
    var todasLasNavieras = 0;
    var todosLosDestinos = 0;
    var todasLasCargas = 0;
    final filtrados = <ContainerUnit>[];
    for (final c in aBordo) {
      final naviera = c.operatorCode;
      final destino = FiltrosDeLaLista.claveDeDestino(c);
      final n = filtros._porNaviera(c);
      final d = filtros._porDestino(c);
      final k = filtros._porCarga(c);
      if (naviera != null && naviera.isNotEmpty) {
        navieraViaje.update(naviera, (int v) => v + 1, ifAbsent: () => 1);
        if (d && k) {
          navieraCruzada.update(naviera, (int v) => v + 1, ifAbsent: () => 1);
        }
      }
      destinoViaje.update(destino, (int v) => v + 1, ifAbsent: () => 1);
      if (n && k) {
        destinoCruzado.update(destino, (int v) => v + 1, ifAbsent: () => 1);
      }
      for (final carga in CargaEspecial.values) {
        if (!carga.en(c)) continue;
        cargaViaje.update(carga, (int v) => v + 1, ifAbsent: () => 1);
        if (n && d) {
          cargaCruzada.update(carga, (int v) => v + 1, ifAbsent: () => 1);
        }
      }
      if (d && k) todasLasNavieras++;
      if (n && k) todosLosDestinos++;
      if (n && d) todasLasCargas++;
      if (n && d && k) filtrados.add(c);
    }

    List<CuentaDeFicha<String>> ordenadas(
        Map<String, int> viaje, Map<String, int> cruzada) {
      final claves = viaje.keys.toList()
        ..sort((String a, String b) {
          if (a == FiltrosDeLaLista.sinDestino) return 1;
          if (b == FiltrosDeLaLista.sinDestino) return -1;
          final porCuenta = viaje[b]!.compareTo(viaje[a]!);
          return porCuenta != 0 ? porCuenta : a.compareTo(b);
        });
      return <CuentaDeFicha<String>>[
        for (final clave in claves)
          CuentaDeFicha<String>(
              clave: clave, cuenta: cruzada[clave] ?? 0, delViaje: viaje[clave]!),
      ];
    }

    return CuentasDeLosFiltros._(
      navieras: ordenadas(navieraViaje, navieraCruzada),
      destinos: ordenadas(destinoViaje, destinoCruzado),
      cargas: <CuentaDeFicha<CargaEspecial>>[
        for (final carga in CargaEspecial.values)
          if (cargaViaje.containsKey(carga))
            CuentaDeFicha<CargaEspecial>(
                clave: carga,
                cuenta: cargaCruzada[carga] ?? 0,
                delViaje: cargaViaje[carga]!),
      ],
      todasLasNavieras: todasLasNavieras,
      todosLosDestinos: todosLosDestinos,
      todasLasCargas: todasLasCargas,
      filtrados: filtrados,
    );
  }
}
