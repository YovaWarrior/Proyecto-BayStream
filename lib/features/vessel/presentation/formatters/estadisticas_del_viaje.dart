import 'package:flutter/foundation.dart' show immutable;

import '../../../../core/design/design.dart';
import '../../domain/entities/entities.dart';

/// Un código con su cuenta: un puerto de descarga o una naviera. Sin código,
/// el rótulo dice que falta («Sin puerto», «Sin naviera») o junta el resto
/// («Otros 3 puertos»).
@immutable
class CuentaPorCodigo {
  /// Crea la cuenta.
  const CuentaPorCodigo({
    required this.codigo,
    required this.rotulo,
    required this.cuenta,
  });

  /// El código, si lo hay («GTSTC»).
  final String? codigo;

  /// Cómo se escribe: el código, o «Sin puerto», «Otros 3 puertos».
  final String rotulo;

  /// Cuántos contenedores.
  final int cuenta;
}

/// Las cifras de Estadísticas (`DESIGN.md`, 15), derivadas del viaje en Dart
/// puro: el total, los llenos, los vacíos y los sin estado, el peso, las
/// bahías con carga, cada bahía con sus dos zonas, los puertos, las navieras,
/// los tamaños y la carga especial. Los contenedores sin posición de estiba
/// van aparte, para que las cifras cuadren por construcción: el total es la
/// suma de los llenos, los vacíos y los sin estado; de los puertos; de las
/// navieras; de los tamaños; y de las bahías más los sin posición.
///
/// La zona (cubierta o bodega) la decide la geometría declarada del viaje;
/// sin geometría, la numeración ISO (la banda de los 80 es cubierta,
/// `VesselGeometry.deckTierFloor`), como la silueta del plano.
@immutable
class EstadisticasDelViaje {
  /// Crea las cifras.
  const EstadisticasDelViaje({
    required this.total,
    required this.llenos,
    required this.vacios,
    required this.sinEstado,
    required this.pesoKg,
    required this.bahiasConCarga,
    required this.bahias,
    required this.sinPosicion,
    required this.pesoSinPosicionKg,
    required this.puertos,
    required this.navieras,
    required this.de20,
    required this.de40,
    required this.de45,
    required this.otroTamano,
    required this.peligrosas,
    required this.refrigerados,
    required this.fueraDeMedida,
  });

  /// Las cifras de [voyage].
  factory EstadisticasDelViaje.de(VesselVoyage voyage) {
    final geometria = voyage.geometry;
    var llenos = 0;
    var vacios = 0;
    var sinEstado = 0;
    var de20 = 0;
    var de40 = 0;
    var de45 = 0;
    var otroTamano = 0;
    var peligrosas = 0;
    var refrigerados = 0;
    var fueraDeMedida = 0;
    var sinPosicion = 0;
    var pesoKg = 0.0;
    var pesoSinPosicionKg = 0.0;
    final porBahia = <int, _Zonas>{};
    final puertos = <String?, int>{};
    final navieras = <String?, int>{};

    for (final contenedor in voyage.containers) {
      switch (contenedor.status) {
        case ContainerStatus.full:
          llenos++;
        case ContainerStatus.empty:
          vacios++;
        case ContainerStatus.unknown:
          sinEstado++;
      }
      switch (contenedor.sizeInFeet) {
        case 20:
          de20++;
        case 40:
          de40++;
        case 45:
          de45++;
        default:
          otroTamano++;
      }
      if (contenedor.isDangerous) peligrosas++;
      if (contenedor.isReefer) refrigerados++;
      if (contenedor.isOverDimension) fueraDeMedida++;
      final peso = contenedor.effectiveWeight ?? 0;
      pesoKg += peso;
      puertos.update(contenedor.portOfDischarge, (int v) => v + 1,
          ifAbsent: () => 1);
      navieras.update(contenedor.operatorCode, (int v) => v + 1,
          ifAbsent: () => 1);

      final posicion = contenedor.stowagePosition;
      if (posicion == null) {
        sinPosicion++;
        pesoSinPosicionKg += peso;
        continue;
      }
      final enCubierta =
          geometria?.isDeckTier(posicion.tier) ?? posicion.tier >= 80;
      final zonas = porBahia.putIfAbsent(posicion.bay, _Zonas.new);
      if (enCubierta) {
        zonas.cubierta++;
        zonas.pesoCubiertaKg += peso;
      } else {
        zonas.bodega++;
        zonas.pesoBodegaKg += peso;
      }
    }

    // Las bahías del viaje (con las reservas y las vecinas de los de 40, como
    // en la silueta del plano) y, si el viaje no las trae, las de las
    // posiciones.
    final numeros = <int>{...voyage.bays.keys, ...porBahia.keys}.toList()
      ..sort();
    final bahias = <BsBahiaEnCorte>[
      for (final numero in numeros)
        BsBahiaEnCorte(
          numero: numero,
          contenedoresCubierta: porBahia[numero]?.cubierta ?? 0,
          contenedoresBodega: porBahia[numero]?.bodega ?? 0,
          pesoCubiertaKg: porBahia[numero]?.pesoCubiertaKg ?? 0,
          pesoBodegaKg: porBahia[numero]?.pesoBodegaKg ?? 0,
        ),
    ];

    return EstadisticasDelViaje(
      total: voyage.totalContainers,
      llenos: llenos,
      vacios: vacios,
      sinEstado: sinEstado,
      pesoKg: pesoKg,
      bahiasConCarga: bahias.where((b) => b.contenedores > 0).length,
      bahias: bahias,
      sinPosicion: sinPosicion,
      pesoSinPosicionKg: pesoSinPosicionKg,
      puertos: _ordenadas(puertos, sinPuerto),
      navieras: _ordenadas(navieras, sinNaviera),
      de20: de20,
      de40: de40,
      de45: de45,
      otroTamano: otroTamano,
      peligrosas: peligrosas,
      refrigerados: refrigerados,
      fueraDeMedida: fueraDeMedida,
    );
  }

  /// El rótulo de los contenedores sin puerto de descarga.
  static const String sinPuerto = 'Sin puerto';

  /// El rótulo de los contenedores sin código de naviera.
  static const String sinNaviera = 'Sin naviera';

  /// Los contenedores a bordo.
  final int total;

  /// Los llenos, los vacíos y los que el archivo no dice.
  final int llenos;
  final int vacios;
  final int sinEstado;

  /// El peso de todo lo que va a bordo, en kilos (el efectivo: VGM o bruto).
  final double pesoKg;

  /// Las bahías con algún contenedor propio.
  final int bahiasConCarga;

  /// Cada bahía, de proa a popa, con sus dos zonas.
  final List<BsBahiaEnCorte> bahias;

  /// Los contenedores sin posición de estiba, que no están en ninguna bahía,
  /// y su peso.
  final int sinPosicion;
  final double pesoSinPosicionKg;

  /// Los puertos de descarga, de más a menos (y por código a igual cuenta).
  final List<CuentaPorCodigo> puertos;

  /// Las navieras, de más a menos.
  final List<CuentaPorCodigo> navieras;

  /// Por tamaño: 20, 40 y 45 pies, y lo que el tipo ISO no dice.
  final int de20;
  final int de40;
  final int de45;
  final int otroTamano;

  /// La carga especial.
  final int peligrosas;
  final int refrigerados;
  final int fueraDeMedida;

  /// La parte de [cuenta] en el total, de 0 a 1.
  double parte(int cuenta) => total <= 0 ? 0 : cuenta / total;

  /// Las primeras [cuantas] filas y el resto juntas en una sola, con el
  /// rótulo que da [rotuloDelResto] para cuántas quedaron. Si sobra una sola,
  /// se muestra ella: «Otros 1 puertos» no se escribe.
  static List<CuentaPorCodigo> conElResto(
    List<CuentaPorCodigo> filas,
    int cuantas,
    String Function(int cuantasMas) rotuloDelResto,
  ) {
    if (filas.length <= cuantas + 1) return filas;
    final resto = filas.skip(cuantas).toList();
    return <CuentaPorCodigo>[
      ...filas.take(cuantas),
      CuentaPorCodigo(
        codigo: null,
        rotulo: rotuloDelResto(resto.length),
        cuenta: resto.fold<int>(0, (int suma, CuentaPorCodigo f) => suma + f.cuenta),
      ),
    ];
  }

  static List<CuentaPorCodigo> _ordenadas(
      Map<String?, int> cuentas, String sinCodigo) {
    final filas = <CuentaPorCodigo>[
      for (final entrada in cuentas.entries)
        CuentaPorCodigo(
          codigo: entrada.key,
          rotulo: entrada.key ?? sinCodigo,
          cuenta: entrada.value,
        ),
    ];
    filas.sort((CuentaPorCodigo a, CuentaPorCodigo b) {
      final porCuenta = b.cuenta.compareTo(a.cuenta);
      return porCuenta != 0 ? porCuenta : a.rotulo.compareTo(b.rotulo);
    });
    return filas;
  }
}

class _Zonas {
  int cubierta = 0;
  int bodega = 0;
  double pesoCubiertaKg = 0;
  double pesoBodegaKg = 0;
}
