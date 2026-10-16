import 'package:flutter/material.dart';
import '../../domain/entities/entities.dart';
import 'voyage_call_summary.dart';

/// T-103 · Aviso de un viaje leído desde una 1.5 (SMDG15), decisión 10.35.
const smdg15Notice =
    'Versión 1.5, leída con las reglas de 2.x; revisa pesos y peligrosas';

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
      color: colorScheme.primaryContainer.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // T-103: fijo mientras el viaje esté abierto, también desde Recientes.
            if (voyage.metadata?.readWithV2Rules ?? false) ...[
              Container(
                key: const ValueKey('voyage-smdg15-notice'),
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber,
                        color: colorScheme.onErrorContainer, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        smdg15Notice,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onErrorContainer,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
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
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildInfoChip(
                            context,
                            Icons.tag,
                            'Viaje: ${voyage.voyageNumber}',
                          ),
                          if (voyage.vessel.flag != null) ...[
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
            
            // A letra grande cada indicador dispone del ancho completo.
            LayoutBuilder(builder: (context, constraints) {
              final stacked = constraints.maxWidth < 480 &&
                  MediaQuery.textScalerOf(context).scale(12) > 18;
              final width = stacked ? constraints.maxWidth : (constraints.maxWidth - 32) / 3;
              return Wrap(spacing: 16, runSpacing: 16, children: [
                SizedBox(width: width, child: _buildStatItem(
                    context,
                    Icons.inventory_2,
                    voyage.totalContainers.toString(),
                    'Contenedores',
                    colorScheme.primary,
                  ),
                ),
                SizedBox(width: width, child: _buildStatItem(
                    context,
                    Icons.view_module,
                    voyage.bays.length.toString(),
                    'Bahías',
                    colorScheme.secondary,
                  ),
                ),
                SizedBox(width: width, child: _buildStatItem(
                    context,
                    Icons.scale,
                    _formatWeight(voyage.totalWeight),
                    'Peso Total',
                    colorScheme.tertiary,
                  ),
                ),
              ]);
            }),
            
            if (voyage.reservedSlots.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                '${voyage.totalContainers} contenedores · '
                '${voyage.totalReservedSlots} celdas reservadas',
                key: const ValueKey('voyage-reserved-count'),
              ),
            ],
            // Información adicional si está disponible
            if (voyage.portOfCall != null) ...[
              const SizedBox(height: 16),
              Text('Escala: ${voyage.portOfCall}',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              VoyageCallSummary(
                voyage: voyage,
                port: voyage.portOfCall,
                key: const ValueKey('voyage-call-split'),
              ),
            ],
            if (voyage.metadata != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
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
          // T-56: a letra grande el texto envuelve dentro de su fondo.
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
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
            color: color.withValues(alpha: 0.1),
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
      return '${(weightKg / 1000).toStringAsFixed(1)} t';
    }
    return '${weightKg.toStringAsFixed(0)} kg';
  }
}
