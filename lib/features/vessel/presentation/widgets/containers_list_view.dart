import 'package:flutter/material.dart';
import 'iconos_del_dominio.dart';
import '../../../../core/design/design.dart';
import '../../domain/entities/entities.dart';
import 'detail_text_row.dart';
import '../formatters/carga_especial.dart';

/// Widget que muestra la lista de contenedores en tarjetas
class ContainersListView extends StatelessWidget {
  /// Lista de contenedores a mostrar
  final List<ContainerUnit> containers;

  const ContainersListView({
    super.key,
    required this.containers,
  });

  @override
  Widget build(BuildContext context) {
    if (containers.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('No hay contenedores en este viaje'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: containers.length,
      itemBuilder: (context, index) {
        final container = containers[index];
        return _ContainerCard(container: container);
      },
    );
  }
}

/// Tarjeta individual para mostrar un contenedor
class _ContainerCard extends StatelessWidget {
  final ContainerUnit container;

  const _ContainerCard({required this.container});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _getStatusColor(container.status, colorScheme);
    final iconColor = _getIconColor(container, colorScheme);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showContainerDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila superior: ID y estado
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // El ícono principal del contenedor: la regla única de
                  // `condicionDelContenedor` (DESIGN.md 13.11; O1 de 10.23),
                  // con su nombre como etiqueta y descripción emergente (H1).
                  IconoDelContenedor(
                    container,
                    tamano: 20,
                    color: iconColor,
                    marco: (Widget icono) => Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: icono,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // ID del contenedor y naviera
                  Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              container.containerId,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                            if (container.operatorCode != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: colorScheme.outlineVariant),
                                ),
                                child: Text(
                                  container.operatorCode!,
                                  style: TextStyle(
                                    color: colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (container.isoSizeType != null)
                          Text(
                            'Tipo: ${container.isoSizeType} (${container.sizeInFeet ?? "?"}ft)',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                  ),
                  
                  // Indicadores especiales (IMO, Reefer)
                  if (container.isDangerous)
                    // T-144: «IMO 3 +1» con más declaraciones; el lector de
                    // pantalla oye todas las clases.
                    Semantics(
                      label: etiquetaAccesibleDePeligrosa(container),
                      excludeSemantics: true,
                      child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: colorScheme.error),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(BsIconos.peligrosa, color: colorScheme.onErrorContainer, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              etiquetaDePeligrosa(container),
                              style: TextStyle(
                                color: colorScheme.onErrorContainer,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ),
                  if (container.isReefer)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: colorScheme.primary),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(BsIconos.refrigerado, color: colorScheme.onPrimaryContainer, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '${container.temperature?.toStringAsFixed(0) ?? "?"}°${container.temperatureUnit ?? "C"}',
                              style: TextStyle(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Estado (lleno/vacío)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      _getStatusText(container.status),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              
              // Fila inferior: Posición y peso
              LayoutBuilder(builder: (context, constraints) {
                final items = <Widget>[
                  // Posición de estiba
                  _buildInfoItem(
                      context,
                      BsIconos.bahia,
                      'Posición',
                      container.stowagePosition?.displayFormat ?? 'Sin asignar',
                  ),
                  
                  // Peso efectivo (T-66): el rótulo dice de qué segmento viene
                  _buildInfoItem(
                      context,
                      container.weightSource == WeightSource.vgm
                          ? BsIconos.vgm
                          : Icons.scale,
                      container.weightSource == WeightSource.vgm
                          ? 'Peso (VGM)'
                          : container.weightSource == WeightSource.gross
                              ? 'Peso bruto'
                              : 'Peso',
                      container.effectiveWeight != null
                          ? '${container.effectiveWeight!.toStringAsFixed(0)} kg'
                          : 'Sin peso',
                  ),
                  
                  // Puerto destino
                  if (container.portOfDischarge != null)
                    _buildInfoItem(
                        context,
                        Icons.location_on,
                        'Destino',
                        container.portOfDischarge!,
                    ),
                ];
                // Las etiquetas pequeñas crecen más que los títulos en Android.
                final stacked = constraints.maxWidth < 480 &&
                    MediaQuery.textScalerOf(context).scale(12) > 18;
                return stacked
                    ? Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [for (final item in items)
                          Padding(padding: const EdgeInsets.only(bottom: 8), child: item)])
                    : Row(children: [for (final item in items) Expanded(child: item)]);
              }),
              
              // Indicadores especiales
              if (container.isDangerous || container.isReefer || container.isOverDimension) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    if (container.isDangerous)
                      _buildWarningChip(context, BsIconos.peligrosa, 'IMDG', colorScheme.error),
                    if (container.isReefer)
                      _buildWarningChip(context, BsIconos.refrigerado, 'Refrigerado', colorScheme.primary),
                    if (container.isOverDimension)
                      _buildWarningChip(context, BsIconos.fueraDeMedida, 'OOG', colorScheme.tertiary),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Construye un item de información
  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Construye un chip de advertencia para cargas especiales
  Widget _buildWarningChip(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Obtiene el color según el estado del contenedor
  Color _getStatusColor(ContainerStatus status, ColorScheme scheme) {
    switch (status) {
      case ContainerStatus.full:
        return scheme.primary;
      case ContainerStatus.empty:
        return scheme.secondary;
      case ContainerStatus.unknown:
        return scheme.onSurfaceVariant;
    }
  }

  /// Obtiene el texto del estado, en tipo oración (T-143, O-139-2; regla 3
  /// de DESIGN.md 11). Las exportaciones no lo usan.
  String _getStatusText(ContainerStatus status) {
    switch (status) {
      case ContainerStatus.full:
        return 'Lleno';
      case ContainerStatus.empty:
        return 'Vacío';
      case ContainerStatus.unknown:
        // T-143: sin «N/A» (regla 4 de DESIGN.md 11).
        return 'Sin dato';
    }
  }

  /// Obtiene el color según el tipo de contenedor
  Color _getTypeColor(ContainerType? type, ColorScheme scheme) {
    switch (type) {
      case ContainerType.reefer:
        return scheme.primary;
      case ContainerType.tank:
        return scheme.tertiary;
      case ContainerType.openTop:
        return scheme.secondary;
      case ContainerType.flatRack:
        return scheme.tertiary;
      case ContainerType.generalPurpose:
      default:
        return scheme.onSurfaceVariant;
    }
  }

  /// El color del ícono principal: el de la condición que manda, como los
  /// chips de la tarjeta (IMDG, refrigerado, OOG, vacío); si no, el del tipo.
  Color _getIconColor(ContainerUnit container, ColorScheme scheme) {
    if (container.isDangerous) return scheme.error;
    if (container.isReefer) return scheme.primary;
    if (container.isOverDimension) return scheme.tertiary;
    if (container.status == ContainerStatus.empty) return scheme.secondary;
    return _getTypeColor(container.containerType, scheme);
  }

  /// Muestra el diálogo con detalles completos del contenedor
  void _showContainerDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
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
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Título
              Text(
                container.containerId,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 24),
              
              // Detalles en lista
              _buildDetailRow(context, 'Naviera', container.operatorCode ?? 'N/A'),
              _buildDetailRow(context, 'Tipo ISO', container.isoSizeType ?? 'N/A'),
              _buildDetailRow(context, 'Tamaño', '${container.sizeInFeet ?? "?"} pies'),
              _buildDetailRow(context, 'Estado', _getStatusText(container.status)),
              _buildDetailRow(context, 'Posición', container.stowagePosition?.displayFormat ?? 'Sin asignar'),
              // T-66: cada peso con su fuente; si vienen los dos, los dos.
              if (container.vgmWeight != null)
                _buildDetailRow(context, 'Peso (VGM)', '${container.vgmWeight!.toStringAsFixed(0)} kg'),
              if (container.grossWeight != null)
                _buildDetailRow(context, 'Peso bruto', '${container.grossWeight!.toStringAsFixed(0)} kg'),
              if (container.effectiveWeight == null)
                _buildDetailRow(context, 'Peso', 'El archivo no trae peso'),
              _buildDetailRow(context, 'Puerto Carga', container.portOfLoading ?? 'N/A'),
              _buildDetailRow(context, 'Puerto Descarga', container.portOfDischarge ?? 'N/A'),
              
              // Información de mercancías peligrosas
              if (container.isDangerous) ...[
                const Divider(height: 24),
                Row(
                  children: [
                    Icon(BsIconos.peligrosa, color: Theme.of(context).colorScheme.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(
                      'MERCANCÍA PELIGROSA',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                  ],
                ),
                const SizedBox(height: 8),
                // T-144: con dos o más DGS, una fila por declaración.
                if ((container.dangerousGoods?.length ?? 0) > 1)
                  for (final (i, d) in container.dangerousGoods!.indexed)
                    _buildDetailRow(
                        context, 'Declaración ${i + 1}', lineaDeDeclaracion(d))
                else ...[
                  _buildDetailRow(context, 'Clase IMO', container.imdgClass ?? 'N/A'),
                  _buildDetailRow(context, 'Número ONU', container.unNumber ?? 'N/A'),
                ],
              ],
              
              // Información de reefer
              if (container.isReefer) ...[
                const Divider(height: 24),
                Row(
                  children: [
                    Icon(BsIconos.refrigerado, color: Theme.of(context).colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(
                      'CONTENEDOR REFRIGERADO',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                  ],
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  context, 
                  'Temperatura', 
                  '${container.temperature?.toStringAsFixed(1) ?? "N/A"}°${container.temperatureUnit ?? "C"}',
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Botón cerrar
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

  /// Construye una fila de detalle
  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return DetailTextRow(label: label, value: value, verticalPadding: 8);
  }
}
