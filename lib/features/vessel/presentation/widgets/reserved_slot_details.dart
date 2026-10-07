import 'package:flutter/material.dart';

import '../../domain/entities/entities.dart';

/// Detalle de la posición reservada del plan, sin número de contenedor.
void showReservedSlotDetails(BuildContext context, ReservedSlot slot) {
  showModalBottomSheet<void>(
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
      builder: (context, scrollController) {
        final colorScheme = Theme.of(context).colorScheme;
        final state = switch (slot.status) {
          ContainerStatus.full => 'lleno',
          ContainerStatus.empty => 'vacío',
          ContainerStatus.unknown => 'estado no declarado',
        };
        final weight = slot.nominalWeight == null
            ? 'sin peso nominal'
            : '${(slot.nominalWeight! / 1000).toStringAsFixed(1)} t nominal';
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Celda reservada',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
              const SizedBox(height: 8),
              Text(
                '${slot.isoSizeType ?? 'Tipo no declarado'} · '
                '${slot.portOfDischarge ?? 'Puerto no declarado'} · '
                '${slot.operatorCode ?? 'Línea no declarada'} · $state · $weight',
                key: const ValueKey('reserved-slot-description'),
              ),
              const SizedBox(height: 8),
              Text(slot.key,
                  key: const ValueKey('reserved-slot-key'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                        color: colorScheme.onSurfaceVariant,
                      )),
              const SizedBox(height: 20),
              _detailRow(
                  context, 'Posición', slot.stowagePosition.displayFormat),
              _detailRow(
                  context, 'Tipo ISO', slot.isoSizeType ?? 'No declarado'),
              _detailRow(
                  context,
                  'Tamaño',
                  slot.sizeInFeet == null
                      ? 'No declarado'
                      : '${slot.sizeInFeet} pies'),
              _detailRow(context, 'Estado', state),
              _detailRow(context, 'Línea', slot.operatorCode ?? 'No declarada'),
              _detailRow(context, 'Puerto de carga',
                  slot.portOfLoading ?? 'No declarado'),
              _detailRow(context, 'Puerto de descarga',
                  slot.portOfDischarge ?? 'No declarado'),
              _detailRow(context, 'Peso nominal', weight),
              const SizedBox(height: 8),
              Text(
                'La reserva no suma peso ni ocupación hasta que se asigne el contenedor.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              if (slot.isReefer || slot.temperature != null) ...[
                const Divider(height: 24),
                _detailRow(context, 'Refrigerada', slot.isReefer ? 'Sí' : 'No'),
                _detailRow(
                    context,
                    'Temperatura',
                    slot.temperature == null
                        ? 'No declarada'
                        : '${slot.temperature!.toStringAsFixed(1)}°${slot.temperatureUnit ?? 'C'}'),
              ],
              if (slot.isDangerous) ...[
                const Divider(height: 24),
                Text('Mercancía peligrosa',
                    style: Theme.of(context).textTheme.titleSmall),
                if (slot.dangerousGoods.isEmpty) ...[
                  _detailRow(
                      context, 'Clase IMO', slot.imdgClass ?? 'No declarada'),
                  _detailRow(
                      context, 'Número ONU', slot.unNumber ?? 'No declarado'),
                ],
                for (final goods in slot.dangerousGoods) ...[
                  _detailRow(context, 'Reglamento', goods.regulation),
                  _detailRow(context, 'Clase IMO',
                      goods.hazardClass ?? 'No declarada'),
                  _detailRow(
                      context, 'Número ONU', goods.unNumber ?? 'No declarado'),
                  if (goods.labels.isNotEmpty)
                    _detailRow(context, 'Etiquetas', goods.labels.join(', ')),
                ],
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
        );
      },
    ),
  );
}

Widget _detailRow(BuildContext context, String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 108,
            child: Text(label,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
