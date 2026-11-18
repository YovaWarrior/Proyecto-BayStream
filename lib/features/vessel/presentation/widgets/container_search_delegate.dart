import 'package:flutter/material.dart';
import 'iconos_del_dominio.dart';
import '../../../../core/design/design.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/entities.dart';
import '../../domain/services/container_number.dart';
import '../formatters/consulta_de_busqueda.dart';
import '../providers/vessel_providers.dart';

/// SearchDelegate para buscar contenedores por matrícula, puerto, naviera o
/// carga especial (T-120, RF-018: `ConsultaDeBusqueda`, `DESIGN.md` 18.6).
class ContainerSearchDelegate extends SearchDelegate<ContainerUnit?> {
  final List<ContainerUnit> containers;
  final WidgetRef ref;
  /// Cómo ir al Plano al elegir un resultado; sin esto, solo selecciona.
  final VoidCallback? onIrAlPlano;

  ContainerSearchDelegate({
    required this.containers,
    required this.ref,
    this.onIrAlPlano,
  }) : super(
          searchFieldLabel: 'Buscar contenedor, puerto o carga…',
          searchFieldStyle: const TextStyle(fontSize: 16),
        );

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: theme.colorScheme.surface,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          tooltip: 'Limpiar',
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      tooltip: 'Volver',
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    // T-144, corrección 1 (10.125): una consulta que queda vacía al quitarle
    // los espacios (también la tabulación y el espacio duro) es una consulta
    // vacía. Si no, los filtros de puerto y naviera harían `contains('')`,
    // que es verdadero para cualquier valor.
    if (numeroDeContenedor(query).isEmpty) {
      return _buildEmptyState(context);
    }

    // T-120 (RF-018): los términos de carga especial se separan del resto,
    // que se busca como siempre (T-144: la matrícula sin espacios). Sin
    // términos, `coincide` es la búsqueda de antes.
    final consulta = ConsultaDeBusqueda.interpretar(query);
    final results = containers.where(consulta.coincide).toList();

    if (results.isEmpty) {
      return _buildNoResults(context);
    }

    // El resaltado sigue al resto, no a la consulta entera: en «reefer
    // GTSTC» se resalta GTSTC.
    final resto = consulta.resto.toUpperCase().trim();
    final resumen = consulta.resumen(results.length);
    final arriba = resumen == null ? 0 : 1;
    return ListView.builder(
      itemCount: results.length + arriba,
      itemBuilder: (context, index) {
        if (index < arriba) {
          return Padding(
            key: const ValueKey<String>('busqueda-resumen'),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Semantics(
              liveRegion: true,
              child: Text(
                resumen!,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          );
        }
        final container = results[index - arriba];
        return _ContainerSearchResultTile(
          container: container,
          query: resto,
          motivos: consulta.motivos(container),
          onTap: () => _onContainerSelected(context, container),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Obtener estadísticas reales del viaje para mostrar sugerencias útiles
    final operatorCounts = <String, int>{};
    final portCounts = <String, int>{};
    for (final container in containers) {
      final operator = container.operatorCode;
      if (operator != null && operator.isNotEmpty) {
        operatorCounts.update(
          operator,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }

      final port = container.portOfDischarge;
      if (port != null && port.isNotEmpty) {
        portCounts.update(
          port,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }
    }

    int compareByFrequency(
      MapEntry<String, int> first,
      MapEntry<String, int> second,
    ) {
      final byCount = second.value.compareTo(first.value);
      return byCount != 0 ? byCount : first.key.compareTo(second.key);
    }

    final operators = (operatorCounts.entries.toList()
          ..sort(compareByFrequency))
        .take(5)
        .toList();

    final ports = (portCounts.entries.toList()..sort(compareByFrequency))
        .take(5)
        .toList();

    // T-120 (RF-018): cuántos hay de cada carga especial, para sugerirla.
    final cargas = <CargaEspecial, int>{
      for (final carga in CargaEspecial.values)
        carga: containers.where(carga.en).length,
    }..removeWhere((_, int cuenta) => cuenta == 0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con estadísticas
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.search,
                  size: 48,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  '${containers.length} contenedores disponibles',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Busca por matrícula, puerto, naviera o carga especial',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Sección de navieras
          if (operators.isNotEmpty) ...[
            Text(
              'Navieras en este viaje',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: operators.map((operator) {
                return ActionChip(
                  avatar: CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Text(
                      operator.value.toString(),
                      style: TextStyle(fontSize: 10, color: colorScheme.onPrimaryContainer),
                    ),
                  ),
                  label: Text(operator.key),
                  onPressed: () {
                    query = operator.key;
                    showResults(context);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
          
          // Sección de puertos
          if (ports.isNotEmpty) ...[
            Text(
              'Puertos de descarga',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ports.map((port) {
                return ActionChip(
                  avatar: CircleAvatar(
                    backgroundColor: colorScheme.secondaryContainer,
                    child: Text(
                      port.value.toString(),
                      style: TextStyle(fontSize: 10, color: colorScheme.onSecondaryContainer),
                    ),
                  ),
                  label: Text(port.key),
                  onPressed: () {
                    query = port.key;
                    showResults(context);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
          
          // T-120 (RF-018): la carga especial, como atajos que escriben el
          // término de la especificación.
          if (cargas.isNotEmpty) ...[
            Text(
              'Carga especial',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final MapEntry(key: carga, value: cuenta)
                    in cargas.entries)
                  ActionChip(
                    key: ValueKey<String>('sugerencia-${carga.name}'),
                    avatar: Icon(switch (carga) {
                      CargaEspecial.peligrosa => BsIconos.peligrosa,
                      CargaEspecial.refrigerado => BsIconos.refrigerado,
                      CargaEspecial.fueraDeMedida => BsIconos.fueraDeMedida,
                    }),
                    label: Text('${carga.rotulo} $cuenta'),
                    onPressed: () {
                      query = carga.termino;
                      showResults(context);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 20),
          ],

          // Tip de búsqueda
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, size: 20, color: colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Escribe parte de la matrícula, como «MSKU123», o «reefer», «imo» u «oog».',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 13.11: «ningún contenedor coincide», con la ilustración del paquete.
          const BsIlustracion(
            key: ValueKey('busqueda-sin-resultados'),
            datos: BsIlustraciones.vacioBusqueda,
            ancho: 240,
          ),
          const SizedBox(height: 16),
          Text(
            'Sin resultados para "$query"',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          // Tinta suave entera: con el 70 % de opacidad quedaba en 3.3:1.
          Text(
            'Intenta con otro término de búsqueda',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  void _onContainerSelected(BuildContext context, ContainerUnit container) {
    // Obtener la bahía del contenedor
    final bayNumber = container.stowagePosition?.bay;
    
    if (bayNumber != null) {
      // Seleccionar la bahía y resaltar el contenedor
      ref.read(selectedBayProvider.notifier).select(bayNumber);
      ref.read(highlightedContainerProvider.notifier).highlight(container.containerId);
      
      // Ir al Plano, si quien abrió la búsqueda dijo cómo.
      onIrAlPlano?.call();
    }
    
    // Cerrar la búsqueda
    close(context, container);
  }
}

/// Tile de resultado de búsqueda para un contenedor
class _ContainerSearchResultTile extends StatelessWidget {
  final ContainerUnit container;
  final String query;
  final VoidCallback onTap;

  /// T-120 (RF-018): por qué salió, una línea por carga pedida
  /// («Refrigerado, −18 °C»).
  final List<String> motivos;

  const _ContainerSearchResultTile({
    required this.container,
    required this.query,
    required this.onTap,
    this.motivos = const <String>[],
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return ListTile(
      onTap: onTap,
      leading: _buildLeadingIcon(colorScheme),
      // T-146 (O-144-1): la matrícula se resalta con la consulta sin
      // espacios, la misma con la que se filtró; el puerto, con la consulta.
      title: _buildHighlightedText(
        context,
        container.containerId,
        numeroDeContenedor(query),
        style: const TextStyle(
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (container.operatorCode != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    container.operatorCode!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (container.portOfDischarge != null)
                _buildHighlightedText(
                  context,
                  'POD: ${container.portOfDischarge}',
                  query,
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                ),
            ],
          ),
          if (container.stowagePosition != null)
            Text(
              'Posición: ${container.stowagePosition!.displayFormat}',
              style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
            ),
          for (final motivo in motivos)
            Text(
              motivo,
              key: const ValueKey<String>('busqueda-motivo'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            container.isoSizeType ?? '',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (container.effectiveWeight != null)
            Text(
              '${(container.effectiveWeight! / 1000).toStringAsFixed(1)}t',
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLeadingIcon(ColorScheme colorScheme) {
    Color background;
    Color foreground;

    // T-112: los mismos colores del esquema que las celdas y la leyenda del
    // plano (bay_plan_view.dart), en vez de colores fijos.
    if (container.isDangerous) {
      background = colorScheme.errorContainer;
      foreground = colorScheme.onErrorContainer;
    } else if (container.isReefer) {
      background = colorScheme.primaryContainer;
      foreground = colorScheme.onPrimaryContainer;
    } else if (container.status == ContainerStatus.full) {
      background = colorScheme.secondaryContainer;
      foreground = colorScheme.onSecondaryContainer;
    } else {
      background = colorScheme.surfaceContainerHighest;
      foreground = colorScheme.onSurfaceVariant;
    }

    // 10.23 (H1): el glifo lleva el nombre de su condición como etiqueta
    // accesible y como descripción emergente, que cubre el círculo entero.
    return IconoDelContenedor(
      container,
      tamano: 20,
      color: foreground,
      marco: (Widget icono) => CircleAvatar(
        backgroundColor: background,
        child: icono,
      ),
    );
  }

  Widget _buildHighlightedText(
    BuildContext context,
    String text,
    String query, {
    TextStyle? style,
  }) {
    final normalizedText = text.toUpperCase();
    final normalizedQuery = query.toUpperCase();

    // T-120: una consulta de solo carga especial no resalta nada.
    if (normalizedQuery.isEmpty || !normalizedText.contains(normalizedQuery)) {
      return Text(text, style: style);
    }

    final startIndex = normalizedText.indexOf(normalizedQuery);
    final endIndex = startIndex + normalizedQuery.length;

    return RichText(
      text: TextSpan(
        style: style ?? DefaultTextStyle.of(context).style,
        children: [
          TextSpan(text: text.substring(0, startIndex)),
          TextSpan(
            text: text.substring(startIndex, endIndex),
            style: TextStyle(
              backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
              color: Theme.of(context).colorScheme.onTertiaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: text.substring(endIndex)),
        ],
      ),
    );
  }
}
