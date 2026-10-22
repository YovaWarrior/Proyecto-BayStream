import 'package:flutter/material.dart';

import '../../../../core/design/design.dart';

/// La cabecera del inicio (`DESIGN.md` 9.1): qué hace la app y su única
/// acción, «Seleccionar archivo», en un botón de 56 dp. También es el estado
/// vacío de los viajes recientes, cuando no hay ninguno guardado.
///
/// El título y el botón no repiten el mismo texto (T-98, `con01`): el título
/// dice qué se abre y el botón, qué se hace.
class EmptyStateWidget extends StatelessWidget {
  /// Callback cuando el usuario presiona el botón de cargar archivo
  final VoidCallback onPickFile;

  const EmptyStateWidget({
    super.key,
    required this.onPickFile,
  });

  @override
  Widget build(BuildContext context) {
    final medidas = BsMedidas.de(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Abre un plano de estiba', style: textTheme.titleLarge),
        SizedBox(height: medidas.espacioS),
        // La versión se valida por la cabecera, no por el nombre del archivo
        // (T-104: sin importar la extensión).
        Text(
          'Se valida por su contenido, sin importar la extensión.',
          style: textTheme.bodyMedium
              ?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        Text(
          'Contenido compatible: BAPLIE 2.x, y la 1.5 con aviso.',
          style: textTheme.bodyMedium
              ?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        SizedBox(height: medidas.espacioL),
        FilledButton.icon(
          key: const ValueKey('select-file'),
          onPressed: onPickFile,
          icon: const Icon(Icons.folder_open),
          label: const Text('Seleccionar archivo'),
          style: FilledButton.styleFrom(
            minimumSize: Size.fromHeight(medidas.alturaBotonPrincipal),
          ),
        ),
      ],
    );
  }
}
