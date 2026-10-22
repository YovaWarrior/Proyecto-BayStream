import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/design.dart';
import '../../../../core/utils/voyage_number.dart';
import '../../domain/entities/entities.dart';
import '../formatters/operation_text.dart';
import '../formatters/vessel_error_message.dart';
import '../pages/cloud_page.dart';
import '../pages/recent_voyages_page.dart';
import '../pages/vessel_profiles_page.dart';
import '../providers/sync_providers.dart';
import '../providers/vessel_providers.dart';
import 'empty_state_widget.dart';

/// El inicio (`DESIGN.md` 9.1): «Seleccionar archivo» como acción única, los
/// viajes recientes de este dispositivo, los perfiles guardados y, con cuenta,
/// las operaciones abiertas en la nube.
///
/// Por debajo de 840 dp va en una columna; a partir de ahí, la cabecera a la
/// izquierda y las listas a la derecha, dentro del ancho máximo del tema.
class InicioView extends ConsumerWidget {
  const InicioView({
    super.key,
    required this.onPickFile,
    required this.onOpenRecent,
  });

  /// Abre el selector de archivos.
  final VoidCallback onPickFile;

  /// Reabre un viaje guardado en este dispositivo.
  final ValueChanged<VesselVoyage> onOpenRecent;

  /// Desde este ancho la cabecera y las listas van lado a lado.
  static const double anchoDeDosColumnas = 840;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medidas = BsMedidas.de(context);
    final cabecera = Padding(
      padding: EdgeInsets.only(bottom: medidas.entreBloques),
      child: EmptyStateWidget(onPickFile: onPickFile),
    );
    final listas = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _Recientes(onOpenRecent: onOpenRecent),
        SizedBox(height: medidas.entreBloques),
        const _Perfiles(),
        const _Nube(),
      ],
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final dosColumnas = constraints.maxWidth >= anchoDeDosColumnas;
        return SingleChildScrollView(
          padding: EdgeInsets.all(medidas.espacioL),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: medidas.anchoMaximo),
              child: dosColumnas
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: cabecera),
                        SizedBox(width: medidas.espacioXxl),
                        Expanded(flex: 3, child: listas),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [cabecera, listas],
                    ),
            ),
          ),
        );
      },
    );
  }
}

/// El título de un bloque del inicio, con una acción a la derecha.
class _Titulo extends StatelessWidget {
  const _Titulo(this.texto, {this.accion});

  final String texto;
  final Widget? accion;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Text(texto, style: Theme.of(context).textTheme.titleMedium),
          ),
          if (accion != null) accion!,
        ],
      );
}

/// Los últimos viajes de este dispositivo, listos para abrirse sin archivo.
class _Recientes extends ConsumerWidget {
  const _Recientes({required this.onOpenRecent});

  final ValueChanged<VesselVoyage> onOpenRecent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recientes = ref.watch(recentVoyagesProvider);
    final medidas = BsMedidas.de(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final Widget cuerpo;
    if (recientes.isLoading) {
      cuerpo = const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (recientes.hasError) {
      cuerpo = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(vesselErrorMessage(
              recientes.error!, null, 'leer los viajes recientes')),
          TextButton(
            onPressed: () => ref.invalidate(recentVoyagesProvider),
            child: const Text('Reintentar'),
          ),
        ],
      );
    } else {
      final viajes = recientes.value ?? const <VesselVoyage>[];
      cuerpo = viajes.isEmpty
          ? Padding(
              padding: EdgeInsets.symmetric(vertical: medidas.espacioS),
              child: Text(
                'Todavía no hay viajes guardados en este dispositivo. '
                'El primero se guarda al confirmar su perfil.',
                style: textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            )
          : Card(
              margin: EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < viajes.length; i++) ...[
                    if (i > 0) const Divider(height: 1),
                    _FilaDeReciente(
                      viaje: viajes[i],
                      onTap: () => onOpenRecent(viajes[i]),
                    ),
                  ],
                ],
              ),
            );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _Titulo(
          'Recientes en este dispositivo',
          accion: TextButton(
            key: const ValueKey('recent-voyages'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<bool>(builder: (_) => const RecentVoyagesPage()),
            ),
            child: const Text('Ver todos'),
          ),
        ),
        SizedBox(height: medidas.espacioS),
        cuerpo,
      ],
    );
  }
}

/// Una fila de 72 dp: buque y viaje, la cuenta y la escala.
class _FilaDeReciente extends StatelessWidget {
  const _FilaDeReciente({required this.viaje, required this.onTap});

  final VesselVoyage viaje;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final escala = viaje.portOfCall == null
        ? 'Sin escala'
        : 'Escala ${viaje.portOfCall}';
    return ListTile(
      key: ValueKey('inicio-reciente-${viaje.id}'),
      leading: const Icon(Icons.directions_boat_outlined),
      title: Text(
        '${viaje.vessel.name} · ${voyageNumberLabel(viaje.voyageNumber)}',
        style: textTheme.titleMedium,
      ),
      subtitle: Text(
        '${operationCount(viaje.totalContainers, 'contenedor', 'contenedores')}, '
        '${operationCount(viaje.bays.length, 'bahía', 'bahías')}\n$escala',
        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
      ),
      isThreeLine: true,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

/// Los perfiles guardados, con su cuenta, hacia la pantalla que los edita.
class _Perfiles extends ConsumerWidget {
  const _Perfiles();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perfiles = ref.watch(savedVesselProfilesProvider).value;
    final cuenta = perfiles == null ? '' : ' (${perfiles.length})';
    return ListTile(
      key: const ValueKey('saved-profiles'),
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.straighten),
      title: Text('Perfiles guardados$cuenta'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const VesselProfilesPage()),
      ),
    );
  }
}

/// Con cuenta autorizada: las operaciones abiertas en la nube, para unirse.
class _Nube extends ConsumerWidget {
  const _Nube();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final operador = ref.watch(operatorProvider).value;
    if (operador == null || !operador.authorized) return const SizedBox.shrink();
    final abiertas = ref.watch(openOperationsProvider).value;
    final cuenta = abiertas == null ? '' : ' (${abiertas.length})';
    return ListTile(
      key: const ValueKey('cloud-operations'),
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.cloud_outlined),
      title: Text('Operaciones abiertas en la nube$cuenta'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const CloudPage()),
      ),
    );
  }
}
