import 'package:flutter/material.dart';

import '../../domain/entities/vessel_voyage.dart';

/// T-56: cola del resumen corto cuando el archivo no trae `LOC+9` de algunos
/// contenedores; vacía si no hay ninguno. Las demás cuentas no cambian.
String withoutLoadingPortSuffix(VesselVoyage voyage, String? port) {
  final count = voyage.withoutLoadingPortAt(port).containers;
  return count == 0 ? '' : ' · $count sin puerto de carga en el archivo';
}

/// Cuenta por separado las cajas y las reservas de la escala seleccionada.
class VoyageCallSummary extends StatelessWidget {
  final VesselVoyage voyage;
  final String? port;
  final TextStyle? style;

  const VoyageCallSummary({
    super.key,
    required this.voyage,
    required this.port,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final containers = voyage.cargoCountsFor(port);
    if (voyage.reservedSlots.isEmpty) {
      return Text(
        '${containers.discharged} se descargan · '
        '${containers.loaded} se cargan · ${containers.transit} de paso'
        '${withoutLoadingPortSuffix(voyage, port)}',
        style: style,
      );
    }
    final reserved = voyage.reservedCountsFor(port);
    final unknown = voyage.withoutLoadingPortAt(port);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Se cargan ${containers.loaded} contenedores y ${reserved.loaded} '
          'reservas (${containers.loaded + reserved.loaded} movimientos)',
          style: style,
        ),
        const SizedBox(height: 4),
        Text(
          'Se descargan ${containers.discharged} contenedores y '
          '${reserved.discharged} reservas '
          '(${containers.discharged + reserved.discharged} movimientos)',
          style: style,
        ),
        const SizedBox(height: 4),
        Text(
          'De paso ${containers.transit} contenedores y ${reserved.transit} reservas',
          style: style,
        ),
        if (unknown.containers + unknown.reserved > 0) ...[
          const SizedBox(height: 4),
          Text(
            'Sin puerto de carga en el archivo: ${unknown.containers} '
            'contenedores y ${unknown.reserved} reservas',
            key: const ValueKey('call-without-loading-port'),
            style: style,
          ),
        ],
      ],
    );
  }
}
