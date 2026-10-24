import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/design.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/operation_sync_repository.dart';
import '../providers/loading_operation_provider.dart';
import '../providers/plano_providers.dart';
import '../providers/sync_providers.dart';
import 'sync_status_chip.dart';

/// El panel «En vivo» de la oficina (`DESIGN.md` 13.6 y 13.8): los últimos
/// movimientos de la bitácora de la escala, los propios y los que llegan por
/// la sincronización, con el rol del equipo (Muelle u Oficina, nunca un
/// nombre) y el estado de la nube como resumen. El que se acaba de mover va
/// en grúa y dice «ahora».
class EnVivoDelViaje extends ConsumerWidget {
  const EnVivoDelViaje({super.key, required this.voyage, this.maximo = 8});

  /// El viaje publicado con escala.
  final VesselVoyage voyage;

  /// Cuántos eventos se listan.
  final int maximo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (voyage.portOfCall == null) return const SizedBox.shrink();
    final operacion = ref.watch(loadingOperationProvider(voyage));
    final estado = visibleSyncStatus(ref.watch(syncStatusProvider));
    final enLinea = estado.state == SyncState.upToDate ||
        estado.state == SyncState.sending;
    final recien = ref.watch(recienMovidoProvider);
    final movimientos = operacion.value?.movements ?? const <Movement>[];
    return BsPanelEnVivo(
      key: const ValueKey('en-vivo'),
      eventos: eventosEnVivo(movimientos, DateTime.now(),
          recienMovidoId: recien?.movimientoId, maximo: maximo),
      resumen: operacion.hasValue
          ? syncStatusText(estado)
          : 'Leyendo la operación…',
      enLinea: enLinea,
    );
  }
}

/// El anuncio accesible del movimiento cuando no hay panel lateral
/// (`DESIGN.md` 13.3, punto 5; 10.21, H3): una región en vivo sin dibujo que
/// dice lo mismo que la fila más reciente de «En vivo» (qué pasó, el rol del
/// equipo, el contenedor y la celda, «ahora»), para quien tiene el foco en
/// otro control. No lleva el panel de la oficina al teléfono: solo el
/// anuncio. Mientras el toque local todavía no está en la bitácora no hay
/// nada que anunciar; el anuncio llega con el movimiento registrado.
class AnuncioDelMovimiento extends ConsumerWidget {
  const AnuncioDelMovimiento({super.key, required this.voyage});

  /// El viaje publicado con escala.
  final VesselVoyage voyage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (voyage.portOfCall == null) return const SizedBox.shrink();
    final recien = ref.watch(recienMovidoProvider);
    final movimientos =
        ref.watch(loadingOperationProvider(voyage)).value?.movements;
    if (recien == null || movimientos == null) return const SizedBox.shrink();
    Movement? movimiento;
    for (final m in movimientos) {
      if (m.id == recien.movimientoId) {
        movimiento = m;
        break;
      }
    }
    if (movimiento == null) return const SizedBox.shrink();
    final evento =
        eventoEnVivo(movimiento, DateTime.now(), recienMovidoId: movimiento.id);
    return Semantics(
      key: const ValueKey('anuncio-del-movimiento'),
      container: true,
      liveRegion: true,
      label: evento.etiqueta,
      child: const SizedBox.shrink(),
    );
  }
}
