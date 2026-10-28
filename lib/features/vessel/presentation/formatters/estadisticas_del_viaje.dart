import 'package:flutter/foundation.dart' show immutable;

import '../../../../core/design/design.dart';
import '../../domain/entities/entities.dart';
import '../../domain/services/reference_bay.dart';

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
///
/// T-124 (10.53, 10.56 y 10.65) · Las bahías siguen la regla de Carlos, la
/// misma del avance: **la par es la bahía de referencia.** Cada impar se
/// cuenta con la par vecina que la cubre, si esa par es una bahía del viaje
/// (`referenceBay`), y el grupo lleva el número de la par: la 21 y la 23 van
/// en la 22. Una impar sin par vecina en el viaje queda sola.
///
/// T-125 (10.68) · En un plan de carga, lo que va a bordo es lo que leen la
/// Lista y las búsquedas (`aboardContainersProvider`): el archivo más los
/// vacíos que el muelle asignó a una reserva, que el archivo trae sin número.
/// Cada vacío asignado suma un contenedor, con su tara y su tipo, en su bahía
/// de referencia, su puerto y su naviera; [delArchivo] y [vaciosAsignados]
/// dicen de dónde sale cada uno.
@immutable
class EstadisticasDelViaje {
  /// Crea las cifras.
  const EstadisticasDelViaje({
    required this.total,
    required this.delArchivo,
    required this.vaciosAsignados,
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

  /// Las cifras de [voyage] y, si los hay, de los [asignados]: los vacíos
  /// asignados a una reserva (`LoadingOperation.assignedEmpties`).
  factory EstadisticasDelViaje.de(
    VesselVoyage voyage, {
    List<ContainerUnit> asignados = const <ContainerUnit>[],
  }) {
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

    for (final contenedor in <ContainerUnit>[
      ...voyage.containers,
      ...asignados,
    ]) {
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
    // posiciones. Cada una se cuenta con su bahía de referencia (T-124): la
    // impar, con la par vecina que la cubre.
    final delViaje = <int>{...voyage.bays.keys, ...porBahia.keys};
    final grupos = <int, _Zonas>{};
    for (final numero in delViaje) {
      final referencia = referenceBay(numero, hasBay: delViaje.contains);
      final grupo = grupos.putIfAbsent(referencia, _Zonas.new);
      final zonas = porBahia[numero];
      if (zonas == null) continue;
      grupo
        ..cubierta += zonas.cubierta
        ..bodega += zonas.bodega
        ..pesoCubiertaKg += zonas.pesoCubiertaKg
        ..pesoBodegaKg += zonas.pesoBodegaKg;
    }
    final numeros = grupos.keys.toList()..sort();
    final bahias = <BsBahiaEnCorte>[
      for (final numero in numeros)
        BsBahiaEnCorte(
          numero: numero,
          contenedoresCubierta: grupos[numero]!.cubierta,
          contenedoresBodega: grupos[numero]!.bodega,
          pesoCubiertaKg: grupos[numero]!.pesoCubiertaKg,
          pesoBodegaKg: grupos[numero]!.pesoBodegaKg,
        ),
    ];

    return EstadisticasDelViaje(
      total: voyage.totalContainers + asignados.length,
      delArchivo: voyage.totalContainers,
      vaciosAsignados: asignados.length,
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

  /// El rótulo de la ficha de los vacíos asignados (`DESIGN.md` 15.2).
  static const String rotuloDeLosAsignados = 'Incluye';

  /// Los contenedores a bordo: [delArchivo] más [vaciosAsignados].
  final int total;

  /// Los que trae el archivo.
  final int delArchivo;

  /// Los vacíos asignados a una reserva, que el archivo no trae (T-125).
  final int vaciosAsignados;

  /// El dato de la ficha que dice cuántos vacíos asignados incluyen las
  /// cifras, o `null` sin ninguno: entonces la ficha no sale.
  String? get fichaDeLosAsignados => switch (vaciosAsignados) {
        0 => null,
        1 => '1 vacío asignado a una celda reservada, que el archivo no trae',
        final n =>
          '$n vacíos asignados a celdas reservadas, que el archivo no trae',
      };

  /// Los llenos, los vacíos y los que el archivo no dice.
  final int llenos;
  final int vacios;
  final int sinEstado;

  /// El peso de todo lo que va a bordo, en kilos (el efectivo: VGM o bruto).
  final double pesoKg;

  /// Las bahías con algún contenedor, contadas por su bahía de referencia
  /// (la 21, la 22 y la 23 son una).
  final int bahiasConCarga;

  /// Cada bahía de referencia, de proa a popa, con sus dos zonas: la par con
  /// las impares que cubre (T-124).
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
