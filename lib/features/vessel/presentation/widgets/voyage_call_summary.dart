import 'package:flutter/material.dart';

import '../../domain/entities/vessel_voyage.dart';
import '../formatters/operation_text.dart';

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
    // 10.57: cada cifra concuerda con su palabra, también en 1.
    String boxes(int n) => operationCount(n, 'contenedor', 'contenedores');
    String slots(int n) => operationCount(n, 'reserva', 'reservas');
    String moves(int n) => operationCount(n, 'movimiento', 'movimientos');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Se cargan ${boxes(containers.loaded)} y ${slots(reserved.loaded)} '
          '(${moves(containers.loaded + reserved.loaded)})',
          style: style,
        ),
        const SizedBox(height: 4),
        Text(
          'Se descargan ${boxes(containers.discharged)} y '
          '${slots(reserved.discharged)} '
          '(${moves(containers.discharged + reserved.discharged)})',
          style: style,
        ),
        const SizedBox(height: 4),
        Text(
          'De paso ${boxes(containers.transit)} y ${slots(reserved.transit)}',
          style: style,
        ),
        if (unknown.containers + unknown.reserved > 0) ...[
          const SizedBox(height: 4),
          Text(
            'Sin puerto de carga en el archivo: ${boxes(unknown.containers)} '
            'y ${slots(unknown.reserved)}',
            key: const ValueKey('call-without-loading-port'),
            style: style,
          ),
        ],
      ],
    );
  }
}
