import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/entities.dart';
import '../formatters/vessel_error_message.dart';
import '../providers/discharge_provider.dart';
import '../providers/loading_operation_provider.dart';
import '../providers/movement_log_provider.dart';
import '../providers/sync_providers.dart';
import 'discharge_controls.dart';

/// null cancela; false continúa con la tapa puesta; true registra quitarla.
Future<bool?> confirmClosedHatch(
    BuildContext context, HatchCoverStatus? cover) async {
  if (cover == null) return false;
  return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
            title: Text('Tapa puesta · ${cover.label}'),
            content: SingleChildScrollView(
                child: Text('Bahía ${cover.bay} · ${cover.label} '
                    'cubre esta fila de bodega y sigue puesta. Declaración PROVISIONAL: '
                    'puedes continuar sin quitarla.')),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar')),
              TextButton(
                  key: const ValueKey('hatch-continue'),
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Seguir sin quitarla')),
              FilledButton(
                  key: const ValueKey('hatch-remove-continue'),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Quitar tapa y continuar')),
            ],
          ));
}

/// Hechos observados por quien opera, sin solicitud ni aprobación.
class HatchOperationPage extends ConsumerStatefulWidget {
  final VesselVoyage voyage;
  final int? initialBay;
  const HatchOperationPage({super.key, required this.voyage, this.initialBay});
  @override
  ConsumerState<HatchOperationPage> createState() => _HatchOperationPageState();
}

class _HatchOperationPageState extends ConsumerState<HatchOperationPage> {
  late int? _bay = widget.initialBay;
  bool _busy = false;
  String? _error;
  Future<void> _register(MovementDraft draft) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final repository = await ref.read(movementLogRepositoryProvider.future);
    final author = ref.read(movementAuthorProvider);
    final result = await appendMovement(repository, draft, author);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = result.error;
    });
    if (result.record != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Movimiento de tapa registrado'),
          action: SnackBarAction(
              label: 'Deshacer',
              onPressed: () async {
                final error = await annulMovement(repository,
                    result.record!.movement, markedByMistake, author);
                if (mounted && error != null) setState(() => _error = error);
              })));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Tapas en la operación')),
        body: ref.watch(loadingOperationProvider(widget.voyage)).when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                  child: Text(vesselErrorMessage(
                      error, stack, 'leer las tapas de la operación'))),
              data: (operation) {
                final bays = {
                  ...operation.loading.bays.keys,
                  ...operation.plan.hatchCovers.keys
                }.toList()
                  ..sort();
                final selected = bays.contains(_bay) ? _bay : bays.firstOrNull;
                final declaration = operation.plan.hatchCovers[selected];
                return ListView(padding: const EdgeInsets.all(16), children: [
                  const Text(
                      'PROVISIONAL · Estado derivado de la bitácora. Registra lo observado en muelle u oficina.'),
                  DropdownButton<int>(
                      key: const ValueKey('hatch-operation-bay'),
                      value: selected,
                      isExpanded: true,
                      items: [
                        for (final bay in bays)
                          DropdownMenuItem(
                              value: bay,
                              child: Text(
                                  'Bahía ${bay.toString().padLeft(2, '0')}'))
                      ],
                      onChanged: _busy
                          ? null
                          : (value) => setState(() => _bay = value)),
                  if (declaration == null)
                    const Text('Tapas sin declarar. No se generan avisos.')
                  else if (declaration.kind == HatchCoverKind.openHold)
                    const Text('Sin tapa · bodega abierta.'),
                  if (_error != null)
                    Text(_error!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                  for (final cover in operation.state.hatchCovers.values
                      .where((c) => c.bay == selected))
                    Card(
                        child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      '${cover.label} · ${cover.removed ? 'quitada' : cover.movementId == null ? 'puesta' : 'repuesta'}',
                                      key: ValueKey('hatch-state-${cover.key}'),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                  Text(
                                      'Filas ${(cover.rows.toList()..sort()).map((r) => r.toString().padLeft(2, '0')).join(', ')}'),
                                  if (cover.movementId != null) ...[
                                    for (final m in operation.movements
                                        .where((m) => m.id == cover.movementId))
                                      Text(
                                          '${m.author.name} · ${formatMovementTime(m.createdAt)}'),
                                  ],
                                  Wrap(spacing: 8, children: [
                                    for (final remove in [true, false])
                                      OutlinedButton(
                                          key: ValueKey(
                                              'hatch-${remove ? 'remove' : 'replace'}-${cover.key}'),
                                          onPressed: _busy ||
                                                  operation.operationId == null
                                              ? null
                                              : () => _register(
                                                  MovementDraft.hatchCover(
                                                      operation.operationId!,
                                                      cover.bay,
                                                      cover.number,
                                                      remove: remove)),
                                          child: Text(
                                              remove ? 'Quitar' : 'Reponer')),
                                    if (cover.movementId != null)
                                      for (final m in operation.movements.where(
                                          (m) => m.id == cover.movementId))
                                        if (ref
                                                    .watch(operatorProvider)
                                                    .value
                                                    ?.role !=
                                                OperatorRole.dock ||
                                            m.author.role == OperatorRole.dock)
                                          TextButton(
                                              onPressed: _busy
                                                  ? null
                                                  : () async {
                                                      final reason =
                                                          await askAnnulReason(
                                                              context,
                                                              cover.label);
                                                      if (reason != null) {
                                                        await _register(
                                                            MovementDraft.annul(
                                                                m.operationId,
                                                                m.id,
                                                                reason,
                                                                target:
                                                                    m.target));
                                                      }
                                                    },
                                              child: const Text('Deshacer')),
                                  ]),
                                ]))),
                  for (final conflict in operation.state.conflicts
                      .where((c) => c.key.startsWith('T:')))
                    Card(
                        child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(conflict.message),
                                  if (ref.watch(operatorProvider).value?.role !=
                                          OperatorRole.dock ||
                                      operation.movements
                                              .firstWhere((m) =>
                                                  m.id == conflict.movementId)
                                              .author
                                              .role ==
                                          OperatorRole.dock)
                                    TextButton(
                                        onPressed: _busy
                                            ? null
                                            : () async {
                                                final reason =
                                                    await askAnnulReason(
                                                        context, conflict.key);
                                                if (reason != null) {
                                                  await _register(
                                                      MovementDraft.annul(
                                                          operation
                                                              .operationId!,
                                                          conflict.movementId,
                                                          reason,
                                                          target:
                                                              conflict.key));
                                                }
                                              },
                                        child:
                                            const Text('Deshacer conflicto')),
                                ]))),
                ]);
              },
            ),
      );
}
