import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/design.dart';
import '../../domain/entities/entities.dart';
import '../../domain/services/discharge_progress.dart';
import '../../domain/services/operation_progress.dart';
import '../providers/discharge_provider.dart';
import '../providers/loading_operation_provider.dart';
import '../providers/plano_providers.dart';

/// La silueta del buque como selector de bahías (`DESIGN.md` 13.6 y 13.8):
/// cada bahía es una pila con los niveles ocupados de cubierta y bodega; con
/// una escala, debajo de cada número va el avance de la descarga (o de la
/// carga, en ese modo) y las bahías sin trabajo quedan apagadas. La bahía
/// donde se acaba de mover algo destella (13.3).
class SiluetaDelViaje extends ConsumerWidget {
  const SiluetaDelViaje({
    super.key,
    required this.voyage,
    required this.displayedVoyage,
    required this.seleccionada,
    required this.onSeleccion,
    this.porCarga = false,
    this.controlador,
  });

  /// El viaje publicado o en previo.
  final VesselVoyage voyage;

  /// El viaje que se dibuja: en Carga, el plan combinado.
  final VesselVoyage displayedVoyage;

  /// La bahía elegida.
  final int? seleccionada;

  /// Qué hacer al tocar una bahía.
  final ValueChanged<int> onSeleccion;

  /// Verdadero en los modos de carga: el avance es el de la carga.
  final bool porCarga;

  /// El desplazamiento horizontal, para llevar la seleccionada a la vista.
  final ScrollController? controlador;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final numeros = displayedVoyage.bays.keys.toList()..sort();
    final conEscala = voyage.portOfCall != null;
    final descarga = conEscala && !porCarga && offersDischarge(voyage)
        ? ref.watch(dischargeProgressProvider(voyage)).value
        : null;
    final porBahia = <int, BayOperationProgress>{};
    if (conEscala && porCarga) {
      final operacion = ref.watch(loadingOperationProvider(voyage)).value;
      if (operacion != null) {
        for (final fila in OperationProgress.build(operacion).bays) {
          porBahia[fila.bay] = fila;
        }
      }
    }
    final recien = ref.watch(recienMovidoProvider);

    final bahias = <BsBahiaDeSilueta>[
      for (final numero in numeros)
        _bahia(displayedVoyage.bays[numero]!, descarga, porBahia[numero],
            conEscala: conEscala),
    ];
    return BsSiluetaBuque(
      key: const ValueKey('silueta-del-viaje'),
      bahias: bahias,
      seleccionada: seleccionada,
      recienMovida: recien?.bahia,
      controlador: controlador,
      onSeleccion: onSeleccion,
      rotuloDeAvance: descarga != null
          ? 'avance de la descarga en ${voyage.portOfCall} bajo cada bahía'
          : porBahia.isNotEmpty
              ? 'avance de la carga en ${voyage.portOfCall} bajo cada bahía'
              : null,
    );
  }

  static BsBahiaDeSilueta _bahia(
      Bay bay, DischargeProgress? descarga, BayOperationProgress? carga,
      {required bool conEscala}) {
    final geometria = bay.geometry;
    final cubierta = <int>{};
    final bodega = <int>{};
    for (final contenedor in bay.containers) {
      final posicion = contenedor.stowagePosition;
      if (posicion == null) continue;
      // Sin geometría (documentos anteriores a C-3), la banda de los 80 es
      // cubierta por la numeración ISO (`VesselGeometry.deckTierFloor`).
      final enCubierta =
          geometria?.isDeckTier(posicion.tier) ?? posicion.tier >= 80;
      (enCubierta ? cubierta : bodega).add(posicion.tier);
    }
    double? avance;
    var conTrabajo = !conEscala && bay.containers.isNotEmpty;
    if (descarga != null) {
      final pendiente = descarga.forBay(bay.bayNumber);
      final total = (pendiente?.pending ?? 0) + (pendiente?.discharged ?? 0);
      conTrabajo = total > 0;
      avance = total == 0 ? null : (pendiente!.discharged / total);
    } else if (carga != null) {
      final hechas = carga.fullLoaded + carga.emptyLoaded;
      final total = hechas + carga.fullPending + carga.emptyPending;
      conTrabajo = total > 0;
      avance = total == 0 ? null : hechas / total;
    }
    return BsBahiaDeSilueta(
      numero: bay.bayNumber,
      nivelesCubierta: cubierta.length,
      nivelesBodega: bodega.length,
      avance: avance,
      conTrabajo: conTrabajo,
    );
  }
}
