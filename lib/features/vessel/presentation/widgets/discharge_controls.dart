import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/entities.dart';
import '../../domain/services/discharge_progress.dart';
import '../formatters/vessel_error_message.dart';
import '../providers/discharge_provider.dart';
import '../providers/movement_log_provider.dart';
import '../providers/sync_providers.dart';

/// T-75 · Resumen del modo Descarga: la bahía elegida y la escala completa.
class DischargeSummary extends ConsumerWidget {
  final VesselVoyage voyage;
  final int? selectedBay;
  const DischargeSummary(
      {super.key, required this.voyage, required this.selectedBay});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(dischargeProgressProvider(voyage));
    if (progress.hasError) {
      return Text(vesselErrorMessage(progress.error!, progress.stackTrace));
    }
    if (!progress.hasValue) {
      return const Text('Leyendo el estado de la operación…');
    }
    final data = progress.value!;
    final bay = selectedBay == null ? null : data.forBay(selectedBay!);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
          bay == null
              ? 'Pendientes de descarga: 0 en esta bahía.'
              : 'Bahía ${bay.label} · pendientes de descarga: '
                  'cubierta ${bay.deckPending} · bodega ${bay.holdPending} · '
                  'descargados ${bay.discharged}'
                  '${bay.restows == 0 ? '' : ' · re-estibas ${bay.restows}'}',
          key: const ValueKey('bay-discharge-pending')),
      Text(
          'Escala ${voyage.portOfCall}: ${data.pending} por descargar '
          '(${data.deckPending} cub. / ${data.holdPending} bod.) · '
          '${data.discharged} descargados · ${data.restows} re-estibas',
          key: const ValueKey('operation-discharge-totals')),
      if (!data.canRegister)
        const Text('Esta escala todavía no tiene operación guardada: vuelve a '
            'abrir el BAPLIE de llegada y confirma la escala para registrar.')
      else
        const Text('Toca un contenedor para marcarlo como descargado.'),
    ]);
  }
}

/// Tabla de pendientes de descarga por bahía, con las re-estibas aparte.
void showDischargeTable(BuildContext context, VesselVoyage voyage) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
          child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .8,
        child: Consumer(builder: (context, ref, _) {
          final progress = ref.watch(dischargeProgressProvider(voyage));
          return progress.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) =>
                Center(child: Text(vesselErrorMessage(error, stack))),
            data: (data) {
              final bays = data.bays.values.toList()
                ..sort((a, b) => a.bay.compareTo(b.bay));
              return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Pendientes de descarga · ${voyage.vessel.name} · ${voyage.voyageNumber} · ${voyage.portOfCall}',
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(
                          '${bays.length} bahías · ${data.pending} pendientes · '
                          '${data.deckPending} en cubierta / ${data.holdPending} en bodega · '
                          '${data.discharged} descargados · ${data.restows} re-estibas',
                          key: const ValueKey(
                              'operation-discharge-table-totals')),
                      const Text('Cub. y Bod. = pendientes en cubierta y '
                          'bodega; Desc. = descargados; Re-est. = re-estibas, '
                          'que no cuentan entre los pendientes.'),
                      SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            horizontalMargin: 8,
                            columnSpacing: 12,
                            columns: [
                              for (final label in [
                                'Bahía',
                                'Cub.',
                                'Bod.',
                                'Total',
                                'Desc.',
                                'Re-est.'
                              ])
                                DataColumn(label: Text(label))
                            ],
                            rows: [
                              for (final bay in bays)
                                DataRow(cells: [
                                  DataCell(Text(bay.label)),
                                  for (final count in [
                                    bay.deckPending,
                                    bay.holdPending,
                                    bay.pending,
                                    bay.discharged,
                                    bay.restows
                                  ])
                                    DataCell(Text('$count')),
                                ])
                            ],
                          )),
                      if (data.conflicts.isNotEmpty)
                        Text('${data.conflicts.length} conflictos sobre el '
                            'plano de llegada; los pendientes respetan el '
                            'estado derivado.'),
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cerrar')),
                    ],
                  ));
            },
          );
        }),
      )),
    );

/// Un toque en el modo Descarga. Un contenedor que baja aquí se marca
/// directo; uno de paso pide confirmar la re-estiba; lo ya operado abre el
/// detalle, donde se deshace. Las celdas vacías y las reservas no llegan aquí.
Future<void> onDischargeTap(BuildContext context, WidgetRef ref,
    VesselVoyage voyage, ContainerUnit container,
    {required VoidCallback openDetails}) async {
  final progress = ref.read(dischargeProgressProvider(voyage)).value;
  final mark = progress?.markOf(container.containerId);
  final position = container.stowagePosition?.toIsoCode();
  if (progress == null || mark == null || position == null) return;
  if (mark != DischargeMark.pending && mark != DischargeMark.transit) {
    openDetails();
    return;
  }
  final messenger = ScaffoldMessenger.of(context);
  if (!progress.canRegister) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(
          content: Text('Esta escala no tiene operación guardada: vuelve a '
              'abrir el BAPLIE de llegada y confirma la escala.')));
    return;
  }
  var restow = false;
  String? reason;
  if (mark == DischargeMark.transit) {
    final answer = await confirmRestow(context, container, voyage.portOfCall!);
    if (answer == null) return;
    restow = true;
    reason = answer.isEmpty ? null : answer;
  }
  final repository = await ref.read(movementLogRepositoryProvider.future);
  final author = ref.read(movementAuthorProvider);
  final result = await appendMovement(
      repository,
      MovementDraft.discharge(
          progress.operationId!, container.containerId, position,
          restow: restow, reason: reason),
      author);
  final record = result.record;
  messenger.hideCurrentSnackBar();
  if (record == null) {
    messenger.showSnackBar(
        SnackBar(content: Text('No se registró: ${result.error}')));
    return;
  }
  messenger.showSnackBar(SnackBar(
    key: const ValueKey('discharge-undo-snackbar'),
    duration: const Duration(seconds: 6),
    persist: false,
    content: Text('${restow ? 'Re-estiba registrada' : 'Descargado'} · '
        '${container.containerId} · ${_cell(position)}'),
    action: SnackBarAction(
        label: 'Deshacer',
        onPressed: () async {
          final error = await annulMovement(
              repository, record.movement, markedByMistake, author);
          if (error != null) {
            messenger
                .showSnackBar(SnackBar(content: Text('No se deshizo: $error')));
          }
        }),
  ));
}

/// Aviso de re-estiba. Devuelve el motivo (vacío si no se escribió) o nulo
/// si el usuario cancela.
Future<String?> confirmRestow(
        BuildContext context, ContainerUnit container, String port) =>
    showDialog<String>(
      context: context,
      builder: (context) => _ReasonDialog(
        title: 'Re-estiba',
        message: '${container.containerId} no se descarga en $port: va a '
            '${container.portOfDischarge ?? 'un puerto no declarado'}. '
            'Si sale del buque para volver a estibarlo, se registra como '
            're-estiba y no cuenta entre los que bajan aquí.',
        fieldKey: const ValueKey('restow-reason'),
        fieldLabel: 'Motivo (opcional)',
        confirmKey: const ValueKey('confirm-restow'),
        confirmLabel: 'Registrar re-estiba',
        requiresText: false,
      ),
    );

/// Motivo de `annul`: «Marcado por error» con un toque, o texto libre.
Future<String?> askAnnulReason(BuildContext context, String containerId) =>
    showDialog<String>(
      context: context,
      builder: (context) => _ReasonDialog(
        title: 'Deshacer · $containerId',
        message: 'El movimiento no se borra: queda en la bitácora con su '
            'anulación y el motivo.',
        quickReason: markedByMistake,
        fieldKey: const ValueKey('annul-reason'),
        fieldLabel: 'Otro motivo',
        confirmKey: const ValueKey('annul-with-reason'),
        confirmLabel: 'Deshacer con este motivo',
        requiresText: true,
      ),
    );

class _ReasonDialog extends StatefulWidget {
  final String title;
  final String message;
  final String? quickReason;
  final Key fieldKey;
  final String fieldLabel;
  final Key confirmKey;
  final String confirmLabel;
  final bool requiresText;

  const _ReasonDialog({
    required this.title,
    required this.message,
    this.quickReason,
    required this.fieldKey,
    required this.fieldLabel,
    required this.confirmKey,
    required this.confirmLabel,
    required this.requiresText,
  });

  @override
  State<_ReasonDialog> createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<_ReasonDialog> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = _reason.text.trim();
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.message),
              if (widget.quickReason != null) ...[
                const SizedBox(height: 12),
                FilledButton.tonal(
                  key: const ValueKey('annul-by-mistake'),
                  onPressed: () => Navigator.pop(context, widget.quickReason),
                  child: Text(widget.quickReason!),
                ),
              ],
              const SizedBox(height: 12),
              TextField(
                key: widget.fieldKey,
                controller: _reason,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(labelText: widget.fieldLabel),
              ),
            ]),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar')),
        TextButton(
            key: widget.confirmKey,
            onPressed: widget.requiresText && text.isEmpty
                ? null
                // Se lee al pulsar, no el texto del último cuadro dibujado.
                : () => Navigator.pop(context, _reason.text.trim()),
            child: Text(widget.confirmLabel)),
      ],
    );
  }
}

/// En el detalle de la celda: estado en la escala, quién y cuándo, y
/// «Deshacer» para lo ya descargado o re-estibado.
class DischargeDetailSection extends ConsumerWidget {
  final VesselVoyage voyage;
  final ContainerUnit container;
  const DischargeDetailSection(
      {super.key, required this.voyage, required this.container});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dischargeProgressProvider(voyage)).value;
    final mark = data?.markOf(container.containerId);
    if (data == null || mark == null) return const SizedBox.shrink();
    final movement = data.movementOf(container.containerId);
    final status = data.statusOf(container.containerId);
    final undoable = movement != null &&
        movement.type == MovementType.discharge &&
        (mark == DischargeMark.discharged ||
            mark == DischargeMark.restowed ||
            mark == DischargeMark.conflict);
    final scheme = Theme.of(context).colorScheme;
    return Column(
      key: const ValueKey('discharge-detail'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 24),
        Row(children: [
          Icon(dischargeMarkIcon(mark), color: scheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text('En ${voyage.portOfCall}: ${dischargeMarkText(mark)}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ]),
        if (movement != null) ...[
          const SizedBox(height: 4),
          Text('Registrado ${formatMovementTime(movement.createdAt)} · '
              '${movement.author.name} · dispositivo '
              '${movement.deviceId.length > 8 ? movement.deviceId.substring(0, 8) : movement.deviceId}'),
          if (movement.reason != null) Text('Motivo: ${movement.reason}'),
        ],
        for (final conflict in data.conflicts
            .where((c) => c.key == 'C:${container.containerId}'))
          Text(conflict.message, style: TextStyle(color: scheme.error)),
        if (status != null && status.restow && status.position == null)
          const Text('Fuera del buque, para volver a estibarlo (T-76).'),
        if (undoable)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: OutlinedButton.icon(
              key: const ValueKey('discharge-undo-detail'),
              icon: const Icon(Icons.undo),
              label: Text(mark == DischargeMark.restowed
                  ? 'Deshacer la re-estiba'
                  : 'Deshacer la descarga'),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final repository =
                    await ref.read(movementLogRepositoryProvider.future);
                if (!context.mounted) return;
                final reason =
                    await askAnnulReason(context, container.containerId);
                if (reason == null) return;
                final error = await annulMovement(repository, movement, reason,
                    ref.read(movementAuthorProvider));
                messenger
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                      content: Text(error == null
                          ? 'Deshecho · ${container.containerId} · $reason'
                          : 'No se deshizo: $error')));
              },
            ),
          ),
      ],
    );
  }
}

String dischargeMarkText(DischargeMark mark) => switch (mark) {
      DischargeMark.pending => 'por descargar',
      DischargeMark.discharged => 'descargado',
      DischargeMark.transit => 'de paso, sigue a bordo',
      DischargeMark.restowed => 're-estiba',
      DischargeMark.cancelled => 'cancelado',
      DischargeMark.conflict => 'en conflicto',
    };

/// Rótulo corto de la celda. Junto con el icono, distingue la marca sin
/// depender del color.
String dischargeMarkLabel(DischargeMark mark) => switch (mark) {
      DischargeMark.pending => 'BAJA',
      DischargeMark.discharged => 'DESC.',
      DischargeMark.transit => 'PASO',
      DischargeMark.restowed => 'RE-EST.',
      DischargeMark.cancelled => 'CANC.',
      DischargeMark.conflict => 'REVISAR',
    };

IconData dischargeMarkIcon(DischargeMark mark) => switch (mark) {
      DischargeMark.pending => Icons.south,
      DischargeMark.discharged => Icons.check_circle,
      DischargeMark.transit => Icons.directions_boat_outlined,
      DischargeMark.restowed => Icons.swap_vert,
      DischargeMark.cancelled => Icons.block,
      DischargeMark.conflict => Icons.error_outline,
    };

/// Hora local del dispositivo, como la columna HORA del listado.
String formatMovementTime(DateTime instant) {
  final t = instant.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(t.day)}/${two(t.month)}/${t.year} ${two(t.hour)}:${two(t.minute)}';
}

/// `0140282` → `014-02-82`, como el plano impreso.
String _cell(String position) => position.length == 7
    ? '${position.substring(0, 3)}-${position.substring(3, 5)}-${position.substring(5)}'
    : position;
