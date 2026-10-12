import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/entities.dart';
import '../../domain/services/change_requests.dart';
import '../../domain/services/loading_operation.dart';
import '../formatters/vessel_error_message.dart';
import '../providers/loading_operation_provider.dart';
import '../providers/movement_log_provider.dart';
import '../providers/sync_providers.dart';
import '../widgets/sync_status_chip.dart';

String _position(String value) => value.length == 7
    ? '${value.substring(0, 3)}-${value.substring(3, 5)}-${value.substring(5)}'
    : value;
String _status(ChangeRequestStatus value) => switch (value) {
      ChangeRequestStatus.pending => 'Pendiente',
      ChangeRequestStatus.approved => 'Aprobada',
      ChangeRequestStatus.rejected => 'Rechazada',
      ChangeRequestStatus.conflict => 'En conflicto',
    };
String _name(LoadingOperation data, String key) {
  final order = data.list?.byContainer(key.substring(2))?.order;
  return '${order == null ? '' : 'OR $order · '}${key.substring(2)}';
}

class ChangeRequestsButton extends ConsumerWidget {
  final VesselVoyage voyage;
  const ChangeRequestsButton({super.key, required this.voyage});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actor = ref.watch(operatorProvider).value;
    final operation = ref.watch(activeOperationProvider).value;
    if (actor?.authorized != true || operation?.published != true) {
      return const SizedBox.shrink();
    }
    final office = actor!.role == OperatorRole.office;
    final requests =
        ref.watch(loadingOperationProvider(voyage)).value?.state.requests ??
            const <ChangeRequest>[];
    final pending =
        requests.where((r) => r.status == ChangeRequestStatus.pending).length;
    return TextButton.icon(
        key: const ValueKey('change-requests-button'),
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ChangeRequestsPage(voyage: voyage))),
        icon: Icon(office ? Icons.inbox_outlined : Icons.swap_vert),
        label: Text(
            '${office ? 'Bandeja de cambios' : 'Solicitudes de cambio'} ($pending)'));
  }
}

class ChangeRequestsPage extends ConsumerStatefulWidget {
  final VesselVoyage voyage;
  const ChangeRequestsPage({super.key, required this.voyage});
  @override
  ConsumerState<ChangeRequestsPage> createState() => _ChangeRequestsPageState();
}

class _ChangeRequestsPageState extends ConsumerState<ChangeRequestsPage> {
  bool busy = false;
  String? error;
  Future<void> decide(ChangeRequest request, bool approve) async {
    final reason = await showDialog<String>(
        context: context, builder: (_) => _DecisionReason(approve: approve));
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
        throw StateError('La operación no está disponible.');
      }
      final draft = const ChangeRequests().decide(
          operation, actor, data, request.movement.id, reason,
          approve: approve);
      final result = await repository.append(draft, actor!.author);
      result.fold((failure) => throw StateError(failure.message), (_) {});
    } catch (failure) {
      if (mounted) {
        setState(
            () => error = failure is StateError ? failure.message : '$failure');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final actor = ref.watch(operatorProvider).value;
    final operation = ref.watch(activeOperationProvider).value;
    final allowed = actor?.authorized == true && operation?.published == true;
    final office = actor?.role == OperatorRole.office;
    return Scaffold(
        appBar: AppBar(
            title:
                Text(office ? 'Bandeja de cambios' : 'Solicitudes de cambio')),
        body: ref.watch(loadingOperationProvider(widget.voyage)).when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text(vesselErrorMessage(e, s))),
            data: (data) =>
                ListView(padding: const EdgeInsets.all(16), children: [
                  const Align(
                      alignment: Alignment.centerLeft, child: SyncStatusChip()),
                  Text(
                      '${widget.voyage.vessel.name} · ${widget.voyage.voyageNumber}'),
                  Text(
                      'Plan efectivo · ${data.state.conflicts.length} conflictos',
                      key: const ValueKey('changes-conflicts')),
                  if (!allowed)
                    const Text(
                        'Se necesita una cuenta autorizada y una operación publicada.')
                  else if (operation!.closed)
                    const Text('Operación cerrada.')
                  else if (!office)
                    Align(
                        alignment: Alignment.centerLeft,
                        child: FilledButton.icon(
                            key: const ValueKey('new-change-request'),
                            onPressed: busy
                                ? null
                                : () =>
                                    showChangeRequest(context, widget.voyage),
                            icon: const Icon(Icons.swap_vert),
                            label: const Text('Pedir cambio'))),
                  if (error != null)
                    Text(error!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                  if (data.state.requests.isEmpty)
                    const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No hay solicitudes.')),
                  for (final request in data.state.requests.reversed)
                    Card(
                        child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_status(request.status),
                                      key: ValueKey(
                                          'request-status-${request.movement.id}'),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                  Text(
                                      'Solicita ${request.movement.author.name} · ${request.movement.createdAt.toLocal()}'),
                                  for (final change in request.changes)
                                    Text(
                                        '${_name(data, change.target)}: ${_position(change.from)} → ${_position(change.to)}'),
                                  Text(
                                      'Motivo: ${request.movement.reason ?? ''}'),
                                  if (request.decision != null)
                                    Text(
                                        '${request.decision!.author.name}: ${request.decision!.reason}'),
                                  if (allowed &&
                                      office &&
                                      !operation!.closed &&
                                      request.status ==
                                          ChangeRequestStatus.pending)
                                    Wrap(spacing: 8, children: [
                                      FilledButton(
                                          key: ValueKey(
                                              'approve-${request.movement.id}'),
                                          onPressed: busy
                                              ? null
                                              : () => decide(request, true),
                                          child: const Text('Aprobar')),
                                      OutlinedButton(
                                          key: ValueKey(
                                              'reject-${request.movement.id}'),
                                          onPressed: busy
                                              ? null
                                              : () => decide(request, false),
                                          child: const Text('Rechazar')),
                                    ]),
                                ]))),
                ])));
  }
}

Future<void> showChangeRequest(BuildContext context, VesselVoyage voyage,
        {String? target}) =>
    Navigator.of(context).push<void>(MaterialPageRoute(
        builder: (_) => _RequestForm(voyage: voyage, target: target)));

class _RequestForm extends ConsumerStatefulWidget {
  final VesselVoyage voyage;
  final String? target;
  const _RequestForm({required this.voyage, this.target});
  @override
  ConsumerState<_RequestForm> createState() => _RequestFormState();
}

class _RequestFormState extends ConsumerState<_RequestForm> {
  late final queries = [
    TextEditingController(text: widget.target?.substring(2)),
    TextEditingController()
  ];
  final destinations = [TextEditingController(), TextEditingController()];
  final reason = TextEditingController();
  bool swap = true, busy = false;
  String? error;
  @override
  void dispose() {
    for (final c in [...queries, ...destinations, reason]) {
      c.dispose();
    }
    super.dispose();
  }

  PlanItem? resolve(LoadingOperation data, String input) {
    final value = input.trim().toUpperCase();
    if (value.isEmpty) return null;
    final order = int.tryParse(value.replaceFirst(RegExp(r'^OR\s*'), ''));
    final row = order == null ? null : data.list?.byOrder(order);
    return data.plan.loading[row == null
            ? (data.plan.loading.containsKey(value) ? value : 'C:$value')
            : 'C:${row.containerId}'] ??
        data.plan.loading['R:${value.replaceAll('-', '').padLeft(7, '0')}'];
  }

  List<PositionChange> changes(LoadingOperation data) {
    final items = queries.map((q) => resolve(data, q.text)).toList();
    if (items.any((i) => i == null)) return const [];
    if (swap) {
      return [
        PositionChange(items[0]!.key, items[0]!.plannedPosition,
            items[1]!.plannedPosition),
        PositionChange(items[1]!.key, items[1]!.plannedPosition,
            items[0]!.plannedPosition),
      ];
    }
    return [
      for (var i = 0; i < items.length; i++)
        PositionChange(
            items[i]!.key,
            items[i]!.plannedPosition,
            destinations[i]
                .text
                .replaceAll(RegExp(r'[\s-]'), ''))
    ];
  }

  Future<void> save() async {
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
        throw StateError('La operación no está disponible.');
      }
      final draft = const ChangeRequests()
          .request(operation, actor, data, changes(data), reason.text);
      (await repository.append(draft, actor!.author))
          .fold((failure) => throw StateError(failure.message), (_) {});
      if (mounted) Navigator.pop(context);
    } catch (failure) {
      if (mounted) {
        setState(
            () => error = failure is StateError ? failure.message : '$failure');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(loadingOperationProvider(widget.voyage)).value;
    final batch = data == null ? <PositionChange>[] : changes(data);
    return Scaffold(
        appBar: AppBar(title: const Text('Pedir cambio')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          const Text(
              'La oficina revisará la solicitud. El plan cambia cuando la apruebe.'),
          SwitchListTile(
              key: const ValueKey('change-swap'),
              contentPadding: EdgeInsets.zero,
              title: const Text('Intercambiar dos contenedores'),
              value: swap,
              onChanged: busy
                  ? null
                  : (value) => setState(() {
                        swap = value;
                        while (queries.length > (swap ? 2 : 1)) {
                          queries.removeLast().dispose();
                          destinations.removeLast().dispose();
                        }
                        while (queries.length < (swap ? 2 : 1)) {
                          queries.add(TextEditingController());
                          destinations.add(TextEditingController());
                        }
                      })),
          for (var i = 0; i < queries.length; i++) ...[
            TextField(
                key: ValueKey('change-object-$i'),
                controller: queries[i],
                enabled: !busy,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                    labelText: 'Objeto ${i + 1}: OR, contenedor o reserva',
                    helperText: data == null ||
                            resolve(data, queries[i].text) == null
                        ? 'Escribe el OR o el número completo.'
                        : '${_name(data, resolve(data, queries[i].text)!.key)} · desde ${_position(resolve(data, queries[i].text)!.plannedPosition)}',
                    helperMaxLines: 2)),
            if (!swap)
              TextField(
                  key: ValueKey('change-destination-$i'),
                  controller: destinations[i],
                  enabled: !busy,
                  onChanged: (_) => setState(() {}),
                  decoration:
                      const InputDecoration(labelText: 'Destino BBB-RR-TT')),
          ],
          if (!swap)
            Wrap(children: [
              TextButton(
                  onPressed: busy || queries.length >= 4
                      ? null
                      : () => setState(() {
                            queries.add(TextEditingController());
                            destinations.add(TextEditingController());
                          }),
                  child: const Text('Agregar cambio')),
              if (queries.length > 1)
                TextButton(
                    onPressed: busy
                        ? null
                        : () => setState(() {
                              queries.removeLast().dispose();
                              destinations.removeLast().dispose();
                            }),
                    child: const Text('Quitar último')),
            ]),
          for (final c in batch)
            Text('${_position(c.from)} → ${_position(c.to)}'),
          TextField(
              key: const ValueKey('change-reason'),
              controller: reason,
              maxLength: 300,
              minLines: 2,
              maxLines: 4,
              enabled: !busy,
              onChanged: (_) => setState(() {}),
              decoration:
                  const InputDecoration(labelText: 'Motivo obligatorio')),
          if (error != null)
            Text(error!,
                key: const ValueKey('change-error'),
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          FilledButton(
              key: const ValueKey('send-change-request'),
              onPressed: busy ||
                      reason.text.trim().isEmpty ||
                      PositionChange.readAll(
                              batch.map((c) => c.toJson()).toList()) ==
                          null
                  ? null
                  : save,
              child: Text(busy ? 'Guardando…' : 'Enviar solicitud')),
        ]));
  }
}

class _DecisionReason extends StatefulWidget {
  final bool approve;
  const _DecisionReason({required this.approve});
  @override
  State<_DecisionReason> createState() => _DecisionReasonState();
}

class _DecisionReasonState extends State<_DecisionReason> {
  final reason = TextEditingController();
  @override
  void dispose() {
    reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
          title: Text(widget.approve ? 'Aprobar cambio' : 'Rechazar cambio'),
          content: TextField(
              key: const ValueKey('decision-reason'),
              controller: reason,
              autofocus: true,
              maxLength: 300,
              minLines: 2,
              maxLines: 4,
              onChanged: (_) => setState(() {}),
              decoration:
                  const InputDecoration(labelText: 'Motivo obligatorio')),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar')),
            FilledButton(
                key: const ValueKey('confirm-change-decision'),
                onPressed: reason.text.trim().isEmpty
                    ? null
                    : () => Navigator.pop(context, reason.text.trim()),
                child: Text(widget.approve ? 'Aprobar' : 'Rechazar'))
          ]);
}
