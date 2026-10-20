import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/entities.dart';
import '../../domain/services/change_requests.dart';
import '../formatters/vessel_error_message.dart';
import '../pages/change_requests_page.dart';
import '../providers/loading_operation_provider.dart';
import '../providers/movement_log_provider.dart';
import '../providers/sync_providers.dart';

/// T-81: acciones del detalle, sobre la proyección vigente del plan de carga.
class OfficePlanActions extends ConsumerStatefulWidget {
  final VesselVoyage voyage;
  final String itemKey;
  const OfficePlanActions(
      {super.key, required this.voyage, required this.itemKey});
  @override
  ConsumerState<OfficePlanActions> createState() => _OfficePlanActionsState();
}

class _OfficePlanActionsState extends ConsumerState<OfficePlanActions> {
  bool busy = false;
  String? error;

  Future<void> save({Movement? undo}) async {
    final reason = await showDialog<String>(
        context: context, builder: (_) => _OfficeReason(undo: undo != null));
    if (reason == null || !mounted) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final repository = await ref.read(movementLogRepositoryProvider.future);
      final operation = await ref.read(activeOperationProvider.future);
      final data = ref.read(loadingOperationProvider(widget.voyage)).value;
      final actor = ref.read(operatorProvider).value;
      if (operation == null || data == null) {
        throw StateError(operationUnavailable);
      }
      final draft = undo == null
          ? const ChangeRequests()
              .cancel(operation, actor, data, widget.itemKey, reason)
          : const ChangeRequests()
              .undo(operation, actor, data, widget.itemKey, undo.id, reason);
      (await repository.append(draft, actor!.author))
          .fold((failure) => throw StateError(failure.message), (_) {});
    } catch (failure, stack) {
      if (mounted) {
        setState(() => error = failure is StateError
            ? failure.message
            : vesselErrorMessage(failure, stack, 'guardar la acción de la oficina'));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(loadingOperationProvider(widget.voyage)).value;
    final item = data?.plan.loading[widget.itemKey];
    if (data == null || item?.role != PlanRole.load) {
      return const SizedBox.shrink();
    }
    final status = data.state[widget.itemKey];
    final actor = ref.watch(operatorProvider).value;
    final operation = ref.watch(activeOperationProvider).value;
    final allowed = actor?.authorized == true &&
        actor?.role == OperatorRole.office &&
        operation?.published == true &&
        operation?.closed == false;
    final changes = const ChangeRequests().undoable(data, widget.itemKey);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (status?.state == ItemState.cancelled)
        const Text(
            'Cancelado por la oficina. Debe deshacer la cancelación antes de cargar.',
            key: ValueKey('office-cancelled')),
      if (allowed)
        Wrap(spacing: 8, children: [
          if (const ChangeRequests().pending(data, widget.itemKey)) ...[
            TextButton(
                key: const ValueKey('office-move'),
                onPressed: busy
                    ? null
                    : () => showOfficeMove(context, widget.voyage,
                        target: widget.itemKey),
                child: const Text('Mover')),
            TextButton(
                key: const ValueKey('office-cancel'),
                onPressed: busy ? null : () => save(),
                child: const Text('Cancelar embarque')),
          ],
          for (final movement in changes)
            TextButton(
                key: ValueKey('office-undo-${movement.id}'),
                onPressed: busy ? null : () => save(undo: movement),
                child: Text(movement.type == MovementType.cancelItem
                    ? 'Deshacer cancelación'
                    : 'Deshacer movimiento')),
        ]),
      if (error != null)
        Text(error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error)),
    ]);
  }
}

class _OfficeReason extends StatefulWidget {
  final bool undo;
  const _OfficeReason({required this.undo});
  @override
  State<_OfficeReason> createState() => _OfficeReasonState();
}

class _OfficeReasonState extends State<_OfficeReason> {
  final controller = TextEditingController();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(
            widget.undo ? 'Deshacer cambio de oficina' : 'Cancelar embarque'),
        content: TextField(
            key: const ValueKey('office-reason'),
            controller: controller,
            autofocus: true,
            maxLength: 300,
            minLines: 2,
            maxLines: 4,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(labelText: 'Motivo obligatorio')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Volver')),
          FilledButton(
              key: const ValueKey('office-confirm'),
              onPressed: controller.text.trim().isEmpty
                  ? null
                  : () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Confirmar')),
        ],
      );
}
