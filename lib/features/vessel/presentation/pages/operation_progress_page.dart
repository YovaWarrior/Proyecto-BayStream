import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/entities.dart';
import '../../domain/services/load_check.dart';
import '../../domain/services/loading_operation.dart';
import '../../domain/services/operation_progress.dart';
import '../formatters/vessel_error_message.dart';
import '../providers/loading_operation_provider.dart';
import '../widgets/discharge_controls.dart' show formatMovementTime;
import '../widgets/loading_controls.dart' show loadingPosition;

class OperationProgressPage extends ConsumerWidget {
  final VesselVoyage voyage;
  const OperationProgressPage({super.key, required this.voyage});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(title: const Text('Avance de la operación')),
        body: ref.watch(loadingOperationProvider(voyage)).when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  Center(child: Text(vesselErrorMessage(error, stack))),
              data: (operation) => _content(context, operation),
            ),
      );

  Widget _content(BuildContext context, LoadingOperation operation) {
    final data = OperationProgress.build(operation);
    final colors = Theme.of(context).colorScheme;
    final limit = operation.loading.geometry?.stackWeightLimitKg;
    final exceeded = data.stacks
        .where((s) => s.status == StackWeightStatus.exceeded)
        .toList();
    final unknown = data.stacks
        .where((s) => s.status == StackWeightStatus.notEvaluated)
        .length;
    return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
              key: const ValueKey('operation-progress-scroll'),
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        '${voyage.vessel.name} · ${voyage.voyageNumber} · ${voyage.portOfCall}',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    if (!operation.plan.hasArrival)
                      const Text('Sin plano de llegada: descarga no evaluada.'),
                    if (operation.list == null)
                      const Text(
                          'Sin listado de agencia: llenos y vacíos según el plan.'),
                    const Text(
                        'Hechos y pendientes según el estado de la operación. Las re-estibas se muestran aparte.'),
                    const SizedBox(height: 12),
                    if (constraints.maxWidth >= 1000)
                      SizedBox(
                          width: double.infinity,
                          child: DataTable(
                            horizontalMargin: 12,
                            columnSpacing: 24,
                            dataRowMinHeight: 68,
                            dataRowMaxHeight: 100,
                            columns: [
                              for (final label in [
                                'Bahía',
                                'Descarga',
                                'Carga · llenos',
                                'Carga · vacíos',
                                'Cancelados',
                                'Conflictos',
                                'Último movimiento'
                              ])
                                DataColumn(label: Text(label))
                            ],
                            rows: [
                              for (final row in [data.total, ...data.bays])
                                DataRow(
                                    key: ValueKey('progress-bay-${row.bay}'),
                                    color: row.bay == 0
                                        ? WidgetStatePropertyAll(
                                            colors.surfaceContainerHighest)
                                        : null,
                                    cells: [
                                      DataCell(Text(
                                          row.bay == 0 ? 'TOTAL' : row.label)),
                                      DataCell(Text(_discharge(row))),
                                      DataCell(Text(
                                          '${row.fullLoaded} cargados\n${row.fullPending} pendientes')),
                                      DataCell(Text(
                                          '${row.emptyLoaded} asignados\n${row.emptyPending} pendientes')),
                                      DataCell(Text('${row.cancelled}')),
                                      DataCell(Text('${row.conflicts}')),
                                      DataCell(SizedBox(
                                          width: 230,
                                          child: Text(_last(row.last)))),
                                    ]),
                            ],
                          ))
                    else ...[
                      for (final row in [data.total, ...data.bays])
                        Card(
                          key: ValueKey('progress-bay-${row.bay}'),
                          color: row.bay == 0
                              ? colors.surfaceContainerHighest
                              : null,
                          child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      row.bay == 0
                                          ? 'TOTAL'
                                          : 'Bahía ${row.label}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                  Text('Descarga: ${_discharge(row)}'),
                                  Text(
                                      'Llenos: ${row.fullLoaded} cargados · ${row.fullPending} pendientes'),
                                  Text(
                                      'Vacíos: ${row.emptyLoaded} asignados · ${row.emptyPending} pendientes'),
                                  Text(
                                      'Cancelados: ${row.cancelled} · Conflictos: ${row.conflicts}'),
                                  Text('Último movimiento: ${_last(row.last)}'),
                                ],
                              )),
                        )
                    ],
                    const SizedBox(height: 16),
                    Text('Conflictos · ${data.conflicts.length}',
                        style: Theme.of(context).textTheme.titleLarge),
                    if (data.conflicts.isEmpty)
                      const Text('Sin conflictos.')
                    else ...[
                      for (final item in data.conflicts)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.conflict.message,
                                    style: TextStyle(color: colors.error)),
                                if (item.movement?.reason != null)
                                  Text('Motivo: ${item.movement!.reason}'),
                                if (item.position != null)
                                  TextButton.icon(
                                    key: ValueKey(
                                        'progress-conflict-${item.conflict.movementId}'),
                                    icon: const Icon(Icons.grid_view),
                                    label: Text(
                                        'Ir a ${loadingPosition(item.position!)}'),
                                    onPressed: () => Navigator.pop(
                                        context,
                                        OperationCellLink(
                                            item.conflict.key,
                                            item.position!,
                                            operation.state[item.conflict.key]
                                                    ?.role ??
                                                PlanRole.load,
                                            displayKey: operation.plan
                                                .loadingItemAt(item.position!)
                                                ?.key)),
                                  ),
                              ]),
                        )
                    ],
                    const SizedBox(height: 16),
                    Text('Peso de las pilas',
                        style: Theme.of(context).textTheme.titleLarge),
                    if (limit == null)
                      const Text(
                          'No evaluado: el perfil no declara límite de pila.')
                    else ...[
                      Text(
                          'Límite del perfil: ${(limit / 1000).toStringAsFixed(1)} t. '
                          '${exceeded.length} pilas sobre su límite.'),
                      if (unknown > 0)
                        Text(
                            '$unknown pilas no evaluadas por pesos faltantes.'),
                    ],
                    for (final stack in exceeded)
                      Text(
                          '${stack.label}: ${(stack.knownKg / 1000).toStringAsFixed(1)} t '
                          '/ ${(stack.limitKg! / 1000).toStringAsFixed(1)} t'
                          '${stack.missing > 0 ? ' · ${stack.missing} pesos faltantes; el peso real es mayor' : ''}.',
                          key: ValueKey(
                              'progress-stack-${stack.bay}-${stack.row}-${stack.deck}'),
                          style: TextStyle(color: colors.error)),
                    const Text(
                        'Peso actual a bordo; una pila sobre su límite se informa aparte de los conflictos.'),
                    if (operation.state.notDerived.isNotEmpty)
                      Text(
                          '${operation.state.notDerived.length} movimientos todavía sin derivar (cambios y tapas).'),
                    if (operation.state.duplicates.isNotEmpty)
                      Text(
                          '${operation.state.duplicates.length} movimientos repetidos; no suman dos veces.'),
                    const SizedBox(height: 24),
                  ]),
            ));
  }

  String _discharge(BayOperationProgress row) =>
      '${row.discharged} descargados · '
      '${row.dischargePending} pendientes\n'
      '(${row.dischargeDeck.pending} cub. / ${row.dischargeHold.pending} bod.) · '
      '${row.restows} re-estibas';

  String _last(Movement? movement) {
    if (movement == null) return 'Sin movimientos';
    final label = switch (movement.type) {
      MovementType.discharge =>
        movement.payload['restow'] == true ? 'Re-estiba' : 'Descarga',
      MovementType.loadFull => 'Carga',
      MovementType.assignEmpty => 'Asignación de vacío',
      MovementType.annul => 'Anulación',
      MovementType.cancelItem => 'Cancelación',
      MovementType.requestChange => 'Solicitud de cambio',
      MovementType.changePosition => 'Cambio de posición',
      MovementType.rejectChange => 'Cambio rechazado',
      MovementType.hatchCover => 'Tapa',
    };
    return '$label · ${formatMovementTime(movement.createdAt)}\n${movement.author.name}';
  }
}
