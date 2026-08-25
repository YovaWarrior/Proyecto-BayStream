import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/baplie_constants.dart';
import '../../domain/entities/entities.dart';
import '../providers/vessel_providers.dart';

/// Widget que muestra el Bay Plan como un grid visual de contenedores
/// Permite navegar entre bahías y ver la disposición de contenedores
/// Soporta zoom/pan con InteractiveViewer y resaltado de contenedores
class BayPlanView extends ConsumerStatefulWidget {
  final VesselVoyage voyage;

  const BayPlanView({super.key, required this.voyage});

  @override
  ConsumerState<BayPlanView> createState() => _BayPlanViewState();
}

class _BayPlanViewState extends ConsumerState<BayPlanView> {
  int? _selectedBayNumber;
  final ScrollController _bayScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Respetar una selección hecha antes de construir esta pestaña.
    if (widget.voyage.bays.isNotEmpty) {
      final sortedBayNumbers = widget.voyage.bays.keys.toList()..sort();
      final requestedBay = ref.read(selectedBayProvider);
      _selectedBayNumber = requestedBay != null &&
              widget.voyage.bays.containsKey(requestedBay)
          ? requestedBay
          : sortedBayNumbers.first;
    }
  }

  @override
  void dispose() {
    _bayScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sortedBayNumbers = widget.voyage.bays.keys.toList()..sort();
    final highlightedContainerId = ref.watch(highlightedContainerProvider);
    final activeTypeFilter = ref.watch(selectedTypeFilterProvider);

    // Escuchar cambios en la bahía seleccionada desde búsqueda o perfil.
    ref.listen<int?>(selectedBayProvider, (previous, next) {
      if (next != null &&
          next != _selectedBayNumber &&
          widget.voyage.bays.containsKey(next)) {
        setState(() {
          _selectedBayNumber = next;
        });
      }
    });
    
    if (sortedBayNumbers.isEmpty) {
      return const Center(
        child: Text('No hay bahías disponibles'),
      );
    }

    return Column(
      children: [
        // Selector de bahías
        _buildBaySelector(sortedBayNumbers),
        const Divider(height: 1),
        
        // Grid de la bahía seleccionada con scroll normal
        Expanded(
          child: _selectedBayNumber != null
              ? _BayGridWidget(
                  bay: widget.voyage.bays[_selectedBayNumber]!,
                  onContainerTap: _showContainerDetails,
                  highlightedContainerId: highlightedContainerId,
                  activeTypeFilter: activeTypeFilter,
                )
              : const Center(child: Text('Selecciona una bahía')),
        ),
        
        // Leyenda
        _buildLegend(),
      ],
    );
  }

  Widget _buildBaySelector(List<int> bayNumbers) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Flecha izquierda
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              _bayScrollController.animateTo(
                (_bayScrollController.offset - 200).clamp(0, _bayScrollController.position.maxScrollExtent),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            tooltip: 'Anterior',
          ),
          // Lista de bahías
          Expanded(
            child: ListView.builder(
              controller: _bayScrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: bayNumbers.length,
              itemBuilder: (context, index) {
                final bayNumber = bayNumbers[index];
                final bay = widget.voyage.bays[bayNumber]!;
                final isSelected = bayNumber == _selectedBayNumber;
                
                final occupancyPct = bay.occupancyRate.toStringAsFixed(0);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'BAY ${bayNumber.toString().padLeft(2, '0')} ($occupancyPct%)',
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${bay.containers.length}',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (_) {
                      ref
                          .read(selectedBayProvider.notifier)
                          .select(bayNumber);
                    },
                  ),
                );
              },
            ),
          ),
          // Flecha derecha
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              _bayScrollController.animateTo(
                (_bayScrollController.offset + 200).clamp(0, _bayScrollController.position.maxScrollExtent),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            tooltip: 'Siguiente',
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    final activeFilter = ref.watch(selectedTypeFilterProvider);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(Colors.green, 'Lleno', LegendFilterType.full, activeFilter),
            const SizedBox(width: 16),
            _buildLegendItem(Colors.orange, 'Vacío / OOG', LegendFilterType.empty, activeFilter),
            const SizedBox(width: 16),
            _buildLegendItem(Colors.red, 'IMO', LegendFilterType.imo, activeFilter),
            const SizedBox(width: 16),
            _buildLegendItem(Colors.cyan, 'Reefer', LegendFilterType.reefer, activeFilter),
            const SizedBox(width: 16),
            _buildLegendItem(Colors.deepOrange, 'OOG', LegendFilterType.oog, activeFilter),
            const SizedBox(width: 16),
            _buildLegendItem(Colors.grey.shade300, 'Sin contenedor', null, activeFilter),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(
    Color color,
    String label,
    LegendFilterType? type,
    LegendFilterType? activeFilter,
  ) {
    final isActive = type != null && type == activeFilter;
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: () {
        if (type == null) {
          // ignore: avoid_print
          print('[BayPlan] Leyenda "Sin contenedor" no es filtrable');
          return;
        }
        ref.read(selectedTypeFilterProvider.notifier).toggle(type);
        // ignore: avoid_print
        print('[BayPlan] Toggle filtro leyenda: ${type.name}');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                  color: isActive ? Colors.black : Colors.black26,
                  width: isActive ? 2 : 1,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                decoration: isActive ? TextDecoration.underline : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContainerDetails(ContainerUnit container) {
    ref.read(highlightedContainerProvider.notifier).clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra de arrastre
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Título con indicadores
              Row(
                children: [
                  Expanded(
                    child: Text(
                      container.containerId,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  if (container.operatorCode != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        container.operatorCode!,
                        style: const TextStyle(
                          color: Colors.indigo,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Detalles
              _buildDetailRow('Posición', container.stowagePosition?.displayFormat ?? 'N/A'),
              _buildDetailRow('Tipo ISO', '${container.isoSizeType ?? "N/A"} (${container.sizeInFeet ?? "?"}ft)'),
              _buildDetailRow('Estado', container.status == ContainerStatus.full ? 'LLENO' : 
                             container.status == ContainerStatus.empty ? 'VACÍO' : 'Desconocido'),
              _buildDetailRow('Peso Bruto', '${container.grossWeight?.toStringAsFixed(0) ?? "N/A"} kg'),
              _buildDetailRow('Puerto Carga', container.portOfLoading ?? 'N/A'),
              _buildDetailRow('Puerto Descarga', container.portOfDischarge ?? 'N/A'),
              
              // IMO
              if (container.isDangerous) ...[
                const Divider(height: 24),
                Row(
                  children: [
                    const Icon(Icons.warning_amber, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      'CARGA PELIGROSA - IMO ${container.imdgClass ?? ""}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (container.unNumber != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('UN: ${container.unNumber}'),
                  ),
              ],
              
              // Reefer
              if (container.isReefer) ...[
                const Divider(height: 24),
                Row(
                  children: [
                    const Icon(Icons.ac_unit, color: Colors.cyan),
                    const SizedBox(width: 8),
                    Text(
                      'REFRIGERADO: ${container.temperature?.toStringAsFixed(1) ?? "?"}°${container.temperatureUnit ?? "C"}',
                      style: const TextStyle(
                        color: Colors.cyan,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

/// Widget que muestra el grid de una bahía específica
class _BayGridWidget extends StatelessWidget {
  static const double _tierLabelWidth = 40;
  static const double _tierWeightWidth = 88;

  final Bay bay;
  final Function(ContainerUnit) onContainerTap;
  final String? highlightedContainerId;
  final LegendFilterType? activeTypeFilter;

  const _BayGridWidget({
    required this.bay,
    required this.onContainerTap,
    this.highlightedContainerId,
    this.activeTypeFilter,
  });

  @override
  Widget build(BuildContext context) {
    // Calcular filas y tiers para el grid
    final containers = bay.containers;
    
    // Obtener rangos de rows y tiers
    int minRow = 99, maxRow = 0;
    int minTier = 99, maxTier = 0;
    
    for (final container in containers) {
      final pos = container.stowagePosition;
      if (pos != null) {
        if (pos.row < minRow) minRow = pos.row;
        if (pos.row > maxRow) maxRow = pos.row;
        if (pos.tier < minTier) minTier = pos.tier;
        if (pos.tier > maxTier) maxTier = pos.tier;
      }
    }
    
    // Si no hay contenedores con posición válida
    if (minRow > maxRow || minTier > maxTier) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Bay ${bay.bayNumber.toString().padLeft(2, '0')}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              '${bay.containers.length} contenedores',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }
    
    // Crear mapa de posiciones para búsqueda rápida
    final positionMap = <String, ContainerUnit>{};
    for (final container in containers) {
      final pos = container.stowagePosition;
      if (pos != null) {
        positionMap['${pos.row}-${pos.tier}'] = container;
      }
    }
    
    // Generar filas de rows (de izquierda a derecha: 02, 04, 06... 01, 03, 05...)
    // En BAPLIE: pares a babor (izquierda), impares a estribor (derecha), 00/01 centro
    final evenRows = <int>[];
    final oddRows = <int>[];
    for (int r = minRow; r <= maxRow; r++) {
      if (r % 2 == 0) {
        evenRows.add(r);
      } else {
        oddRows.add(r);
      }
    }
    evenRows.sort((a, b) => b.compareTo(a)); // Pares descendente (babor)
    oddRows.sort(); // Impares ascendente (estribor)
    final rows = [...evenRows, ...oddRows];
    
    // Tiers de arriba a abajo (mayor tier arriba)
    // Separar en cubierta (deck: tier >= 80) y bodega (hold: tier < 80)
    final deckTiers = <int>[];
    final holdTiers = <int>[];
    for (int t = maxTier; t >= minTier; t -= 2) {
      if (t >= 80) {
        deckTiers.add(t);
      } else {
        holdTiers.add(t);
      }
    }
    
    // Scroll vertical y horizontal para conservar la alineación en pantallas angostas
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth > 32 ? constraints.maxWidth - 32 : 0,
            ),
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          // Título de la bahía
          Text(
            'BAY ${bay.bayNumber.toString().padLeft(2, '0')}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${bay.containers.length} contenedores | ${(bay.totalWeight / 1000).toStringAsFixed(1)} ton',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          
          // Header de rows
          _buildRowHeader(rows),
          const SizedBox(height: 4),
          
          // CUBIERTA (DECK) - Tiers >= 80
          if (deckTiers.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '▲ CUBIERTA (DECK)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 4),
            ...deckTiers.map((tier) => _buildTierRow(
              context, tier, rows, positionMap, highlightedContainerId, activeTypeFilter,
            )),
          ],
          
          // Separador visual entre cubierta y bodega
          if (deckTiers.isNotEmpty && holdTiers.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                color: Colors.brown.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
          ],
          
          // BODEGA (HOLD) - Tiers < 80
          if (holdTiers.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.brown.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '▼ BODEGA (HOLD)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
            ),
            const SizedBox(height: 4),
            ...holdTiers.map((tier) => _buildTierRow(
              context, tier, rows, positionMap, highlightedContainerId, activeTypeFilter,
            )),
          ],
          ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRowHeader(List<int> rows) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: _tierLabelWidth),
        ...rows.map((row) => Container(
          width: 50,
          alignment: Alignment.center,
          child: Text(
            row.toString().padLeft(2, '0'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        )),
        const SizedBox(width: _tierWeightWidth),
      ],
    );
  }

  Widget _buildTierRow(
    BuildContext context,
    int tier,
    List<int> rows,
    Map<String, ContainerUnit> positionMap,
    String? highlightedContainerId,
    LegendFilterType? activeTypeFilter,
  ) {
    final tierWeight = bay.weightByTier[tier];
    final exceedsLimit = tierWeight != null && tierWeight > kStackWeightLimitKg;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Label de tier
        SizedBox(
          width: _tierLabelWidth,
          child: Text(
            tier.toString().padLeft(2, '0'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        // Celdas de contenedores
        ...rows.map((row) {
          final key = '$row-$tier';
          final container = positionMap[key];
          final isHighlighted = container != null &&
              highlightedContainerId != null &&
              container.containerId == highlightedContainerId;
          return _ContainerCell(
            container: container,
            onTap: container != null ? () => onContainerTap(container) : null,
            isHighlighted: isHighlighted,
            activeTypeFilter: activeTypeFilter,
          );
        }),
        SizedBox(
          width: _tierWeightWidth,
          child: tierWeight == null || tierWeight <= 0
              ? null
              : Container(
                  margin: const EdgeInsets.only(left: 6),
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                  decoration: BoxDecoration(
                    color: exceedsLimit ? colorScheme.errorContainer : null,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${(tierWeight / 1000).toStringAsFixed(1)} t',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: exceedsLimit
                              ? colorScheme.onErrorContainer
                              : colorScheme.onSurfaceVariant,
                          fontWeight: exceedsLimit ? FontWeight.bold : FontWeight.normal,
                        ),
                  ),
                ),
        ),
      ],
    );
  }
}

/// Determina si un contenedor coincide con el filtro de leyenda activo
bool _containerMatchesFilter(ContainerUnit container, LegendFilterType filter) {
  switch (filter) {
    case LegendFilterType.full:
      return container.status == ContainerStatus.full;
    case LegendFilterType.empty:
      return container.status == ContainerStatus.empty;
    case LegendFilterType.imo:
      return container.isDangerous;
    case LegendFilterType.reefer:
      return container.isReefer;
    case LegendFilterType.oog:
      return container.isOverDimension;
  }
}

/// Widget de celda individual de contenedor (optimizado para rendimiento)
class _ContainerCell extends StatelessWidget {
  final ContainerUnit? container;
  final VoidCallback? onTap;
  final bool isHighlighted;
  final LegendFilterType? activeTypeFilter;

  const _ContainerCell({
    this.container,
    this.onTap,
    this.isHighlighted = false,
    this.activeTypeFilter,
  });

  @override
  Widget build(BuildContext context) {
    if (container == null) {
      // Celda vacía
      return Container(
        width: 50,
        height: 40,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade300),
        ),
      );
    }

    // Determinar color según estado y tipo
    Color cellColor;
    Color borderColor;
    IconData? icon;

    if (container!.isDangerous) {
      cellColor = Colors.red.shade100;
      borderColor = Colors.red;
      icon = Icons.warning_amber;
    } else if (container!.isReefer) {
      cellColor = Colors.cyan.shade100;
      borderColor = Colors.cyan;
      icon = Icons.ac_unit;
    } else if (container!.isOverDimension) {
      // RF-008: indicador visual para carga OOG (Out of Gauge)
      cellColor = Colors.orange.shade100;
      borderColor = Colors.orange;
      icon = Icons.open_in_full;
    } else if (container!.status == ContainerStatus.full) {
      cellColor = Colors.green.shade100;
      borderColor = Colors.green;
    } else if (container!.status == ContainerStatus.empty) {
      cellColor = Colors.orange.shade100;
      borderColor = Colors.orange;
    } else {
      cellColor = Colors.grey.shade100;
      borderColor = Colors.grey;
    }

    // RF-011: atenuar contenedores que no coinciden con el filtro activo
    final bool isDimmedByFilter = activeTypeFilter != null &&
        !_containerMatchesFilter(container!, activeTypeFilter!);

    final cell = Container(
      width: 50,
      height: 40,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isHighlighted ? Colors.yellow.shade100 : cellColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isHighlighted ? Colors.yellow.shade700 : borderColor,
          width: isHighlighted ? 3 : 2,
        ),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: Colors.yellow.withOpacity(0.5),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
            Icon(icon, size: 12, color: borderColor)
          else
            Text(
              container!.sizeInFeet?.toString() ?? '',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: borderColor,
              ),
            ),
          if (container!.operatorCode != null)
            Text(
              container!.operatorCode!,
              style: TextStyle(
                fontSize: 8,
                color: borderColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isDimmedByFilter ? 0.25 : 1.0,
        child: cell,
      ),
    );
  }
}
