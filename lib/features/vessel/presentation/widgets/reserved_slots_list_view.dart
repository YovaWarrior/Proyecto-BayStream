import 'package:flutter/material.dart';

import '../../domain/entities/entities.dart';
import 'reserved_slot_details.dart';

/// Las reservas se consultan aparte de la lista y los filtros de contenedores.
class ReservedSlotsListView extends StatelessWidget {
  final List<ReservedSlot> reservedSlots;

  const ReservedSlotsListView({super.key, required this.reservedSlots});

  @override
  Widget build(BuildContext context) {
    if (reservedSlots.isEmpty) return const SizedBox.shrink();
    return ExpansionTile(
      key: const ValueKey('reserved-slots-list'),
      leading:
          Icon(Icons.crop_square, color: Theme.of(context).colorScheme.primary),
      title: Text('Celdas reservadas (${reservedSlots.length})'),
      children: [
        for (final slot in reservedSlots)
          ListTile(
            key: ValueKey('reserved-list-${slot.key}'),
            leading: const Icon(Icons.crop_square),
            title: Text([
              slot.isoSizeType ?? 'ISO no indicado',
              slot.portOfDischarge ?? 'Puerto no indicado',
              if (slot.operatorCode != null) slot.operatorCode!,
            ].join(' · ')),
            subtitle: Text(
              '${slot.stowagePosition.toIsoCode()} · ${_status(slot.status)}',
            ),
            onTap: () => showReservedSlotDetails(context, slot),
          ),
      ],
    );
  }

  String _status(ContainerStatus status) => switch (status) {
        ContainerStatus.full => 'Lleno',
        ContainerStatus.empty => 'Vacío',
        ContainerStatus.unknown => 'Estado no indicado',
      };
}
