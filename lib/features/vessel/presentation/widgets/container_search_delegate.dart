import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/entities.dart';
import '../providers/vessel_providers.dart';

/// SearchDelegate para buscar contenedores por ID o puerto de descarga
class ContainerSearchDelegate extends SearchDelegate<ContainerUnit?> {
  final List<ContainerUnit> containers;
  final WidgetRef ref;
  final TabController? tabController;

  ContainerSearchDelegate({
    required this.containers,
    required this.ref,
    this.tabController,
  }) : super(
          searchFieldLabel: 'Buscar contenedor o puerto...',
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
    if (query.isEmpty) {
      return _buildEmptyState(context);
    }

    final normalizedQuery = query.toUpperCase().trim();
    
    // Buscar por ID de contenedor o puerto de descarga
    final results = containers.where((container) {
      final matchesId = container.containerId.toUpperCase().contains(normalizedQuery);
      final matchesPod = container.portOfDischarge?.toUpperCase().contains(normalizedQuery) ?? false;
      final matchesPol = container.portOfLoading?.toUpperCase().contains(normalizedQuery) ?? false;
      final matchesOperator = container.operatorCode?.toUpperCase().contains(normalizedQuery) ?? false;
      return matchesId || matchesPod || matchesPol || matchesOperator;
    }).toList();

    if (results.isEmpty) {
      return _buildNoResults(context);
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final container = results[index];
        return _ContainerSearchResultTile(
          container: container,
          query: normalizedQuery,
          onTap: () => _onContainerSelected(context, container),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Obtener estadísticas reales del viaje para mostrar sugerencias útiles
    final operators = containers
        .map((c) => c.operatorCode)
        .where((o) => o != null && o.isNotEmpty)
        .cast<String>()
        .toSet()
        .take(5)
        .toList();
    
    final ports = containers
        .map((c) => c.portOfDischarge)
        .where((p) => p != null && p.isNotEmpty)
        .cast<String>()
        .toSet()
        .take(5)
        .toList();

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
              color: colorScheme.primaryContainer.withOpacity(0.3),
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
                  'Busca por ID, puerto de descarga o naviera',
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
              children: operators.map((op) {
                final count = containers.where((c) => c.operatorCode == op).length;
                return ActionChip(
                  avatar: CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Text(
                      count.toString(),
                      style: TextStyle(fontSize: 10, color: colorScheme.onPrimaryContainer),
                    ),
                  ),
                  label: Text(op),
                  onPressed: () {
                    query = op;
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
                final count = containers.where((c) => c.portOfDischarge == port).length;
                return ActionChip(
                  avatar: CircleAvatar(
                    backgroundColor: colorScheme.secondaryContainer,
                    child: Text(
                      count.toString(),
                      style: TextStyle(fontSize: 10, color: colorScheme.onSecondaryContainer),
                    ),
                  ),
                  label: Text(port),
                  onPressed: () {
                    query = port;
                    showResults(context);
                  },
                );
              }).toList(),
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
                    'Tip: Escribe parte del ID del contenedor (ej: "MSKU123") para encontrarlo rápidamente',
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
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Sin resultados para "$query"',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta con otro término de búsqueda',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
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
      
      // Cambiar a la pestaña Bay Plan si hay TabController
      if (tabController != null) {
        tabController!.animateTo(1); // Índice 1 = Bay Plan
      }
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

  const _ContainerSearchResultTile({
    required this.container,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return ListTile(
      onTap: onTap,
      leading: _buildLeadingIcon(colorScheme),
      title: _buildHighlightedText(
        context,
        container.containerId,
        query,
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
          if (container.grossWeight != null)
            Text(
              '${(container.grossWeight! / 1000).toStringAsFixed(1)}t',
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLeadingIcon(ColorScheme colorScheme) {
    IconData icon;
    Color color;

    if (container.isDangerous) {
      icon = Icons.warning_amber;
      color = Colors.red;
    } else if (container.isReefer) {
      icon = Icons.ac_unit;
      color = Colors.cyan;
    } else if (container.status == ContainerStatus.full) {
      icon = Icons.inventory_2;
      color = Colors.green;
    } else {
      icon = Icons.inventory_2_outlined;
      color = Colors.orange;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(icon, color: color, size: 20),
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
    
    if (!normalizedText.contains(normalizedQuery)) {
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
              backgroundColor: Colors.yellow.withOpacity(0.4),
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: text.substring(endIndex)),
        ],
      ),
    );
  }
}
