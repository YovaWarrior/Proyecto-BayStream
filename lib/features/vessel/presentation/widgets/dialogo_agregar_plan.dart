import 'package:flutter/material.dart';

import '../../../../core/utils/fecha_corta.dart';
import '../../../../core/utils/voyage_number.dart';
import '../../domain/entities/entities.dart';
import '../../domain/services/operation_sources.dart';

/// T-130 (10.90) · «Agregar el plan de carga a la operación publicada»: la
/// confirmación explícita de la oficina antes de que el plan que falta suba a
/// la nube (3.5 del diseño). Dice cuándo se publicó la operación (ajuste 2),
/// las cifras del plan (los mismos conteos del diálogo «Tipo de BAPLIE») y,
/// si difiere, el viaje que declara el archivo. Devuelve `true` solo con
/// «Agregar a la operación …»; «Cancelar» o cerrar deja el previo como estaba.
Future<bool> confirmarAgregarPlan(
  BuildContext context, {
  required VesselVoyage plan,
  required String port,
  required OperationSourceKind kind,
  required AttachablePlan lookup,
  required String fileName,
}) async {
  final operation = lookup.operation;
  final nombre = OperationSources.sourceName(kind);
  final cargo = plan.cargoCountsFor(port);
  final reservas = plan.reservedCountsFor(port);
  final publishedAt = lookup.publishedAt;
  final cuando = publishedAt == null
      ? 'guardada el ${fechaCorta(operation.createdAt)}'
      : 'publicada el ${fechaCorta(publishedAt)}';
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      key: const ValueKey('attach-plan-dialog'),
      title: Text('Agregar el $nombre a la operación publicada'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  '${operation.vesselName} · '
                  '${voyageNumberLabel(operation.voyageNumber)} · '
                  '${operation.portOfCall}, $cuando, abierta, sin $nombre.',
                  key: const ValueKey('attach-plan-published-at')),
              if (plan.voyageNumber != operation.voyageNumber) ...[
                const SizedBox(height: 8),
                Text(
                    '«$fileName» declara el viaje '
                    '${voyageNumberLabel(plan.voyageNumber)}. La operación '
                    'publicada es el viaje '
                    '${voyageNumberLabel(operation.voyageNumber)}.',
                    key: const ValueKey('attach-plan-voyage')),
              ],
              const SizedBox(height: 8),
              Text(
                  'Se cargan ${cargo.loaded} contenedores y '
                  '${reservas.loaded} celdas reservadas; se descargan '
                  '${cargo.discharged + reservas.discharged}.',
                  key: const ValueKey('attach-plan-counts')),
              const SizedBox(height: 8),
              const Text('El muelle lo recibe solo. Los movimientos '
                  'registrados no se pierden ni cambian.'),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar')),
        FilledButton(
            key: const ValueKey('attach-plan-confirm'),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Agregar a la operación '
                '${voyageNumberLabel(operation.voyageNumber)}')),
      ],
    ),
  );
  return confirmed == true;
}
