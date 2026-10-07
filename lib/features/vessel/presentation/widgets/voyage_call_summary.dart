import 'package:flutter/material.dart';

import '../../domain/entities/vessel_voyage.dart';

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
        '${containers.loaded} se cargan · ${containers.transit} de paso',
        style: style,
      );
    }
    final reserved = voyage.reservedCountsFor(port);
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
      ],
    );
  }
}
