import 'package:flutter/material.dart';
import '../../domain/entities/entities.dart';

/// Tarjeta que muestra el resumen del viaje cargado
/// Incluye información del buque, número de viaje y estadísticas
class VoyageSummaryCard extends StatelessWidget {
  /// Datos del viaje a mostrar
  final VesselVoyage voyage;

  const VoyageSummaryCard({
    super.key,
    required this.voyage,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      elevation: 0,
      color: colorScheme.primaryContainer.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con icono y nombre del buque
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.directions_boat,
                    color: colorScheme.onPrimary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        voyage.vessel.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildInfoChip(
                            context,
                            Icons.tag,
                            'Viaje: ${voyage.voyageNumber}',
                          ),
                          if (voyage.vessel.flag != null) ...[
                            const SizedBox(width: 8),
                            _buildInfoChip(
                              context,
                              Icons.flag,
                              voyage.vessel.flag!,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            
            // Estadísticas en grid
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    Icons.inventory_2,
                    voyage.totalContainers.toString(),
                    'Contenedores',
                    colorScheme.primary,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    Icons.view_module,
                    voyage.bays.length.toString(),
                    'Bahías',
                    colorScheme.secondary,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    Icons.scale,
                    _formatWeight(voyage.totalGrossWeight),
                    'Peso Total',
                    colorScheme.tertiary,
                  ),
                ),
              ],
            ),
            
            // Información adicional si está disponible
            if (voyage.metadata != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Mensaje: ${voyage.metadata!.messageReference ?? "N/A"}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (voyage.metadata!.messageType != null) ...[
                    const SizedBox(width: 16),
                    Text(
                      'Tipo: ${voyage.metadata!.messageType}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Construye un chip de información pequeño
  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye un item de estadística
  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// Formatea el peso en toneladas o kilogramos
  String _formatWeight(double weightKg) {
    if (weightKg >= 1000) {
      return '${(weightKg / 1000).toStringAsFixed(1)}t';
    }
    return '${weightKg.toStringAsFixed(0)}kg';
  }
}
