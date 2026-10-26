import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/design.dart';
import 'plan_drag_confirmation.dart' show PlanZoomScope;
import '../../../../core/utils/iso_coordinate_parser.dart';
import '../../domain/entities/entities.dart';
import '../../domain/services/load_check.dart';
import '../../domain/services/loading_operation.dart';
import '../formatters/vessel_error_message.dart';
import '../formatters/operation_text.dart';
import '../pages/change_requests_page.dart';
import '../providers/discharge_provider.dart';
import '../providers/loading_operation_provider.dart';
import '../providers/movement_log_provider.dart';
import '../providers/sync_providers.dart';
import '../providers/vessel_providers.dart';
import 'avisos_del_viaje.dart';
import 'discharge_controls.dart';
import 'office_plan_controls.dart';
import 'hatch_operation_controls.dart';
import 'voice_search_field.dart';

String loadingPosition(String value) => value.length == 7
    ? '${value.substring(0, 3)}-${value.substring(3, 5)}-${value.substring(5)}'
    : value;

Future<void> onLoadingContainerTap(BuildContext context, WidgetRef ref,
    VesselVoyage voyage, ContainerUnit container,
    {int? selectedBay, required VoidCallback openDetails}) async {
  final data = ref.read(loadingOperationProvider(voyage)).value;
  if (data?.plan.loading['C:${container.containerId}']?.role != PlanRole.load) {
    openDetails();
    return;
  }
  final listed = data!.list?.byContainer(container.containerId);
  // La oficina no registra cargas: mira y aprueba cambios (10.51).
  if (listed == null &&
      ref.read(operatorProvider).value?.role == OperatorRole.office) {
    await showLoadingDetails(context, voyage, 'C:${container.containerId}');
    return;
  }
  // T-122 (H4): en el muelle, un lleno del plan sin fila en el listado se
  // carga por su número de contenedor; el OR ayuda, pero no es la llave.
  final row = listed ?? data.unlistedRow(container.containerId);
  if (row == null) {
    ScaffoldMessenger.of(context).showSnackBar(avisoDelViaje(
        texto: '${container.containerId} no está en el plan de carga de esta '
            'escala: revisa el plan o importa el listado.',
        corto: 'No está en el plan de carga.'));
    return;
  }
  await openLoadingRow(context, ref, voyage, row, selectedBay: selectedBay);
}

class LoadingControls extends ConsumerWidget {
  final VesselVoyage voyage;
  final int? selectedBay;
  /// T-107 · En pantallas angostas el resumen va en una línea, junto a
  /// «OR / últimos dígitos»; «Asignar vacío» pasa a «Acciones».
  final bool compact;

  /// En el teléfono bajo (13.8) «OR / últimos dígitos» va en la tira del pie
  /// con los demás controles ([busquedaDeCarga]); aquí queda solo la línea
  /// del resumen.
  final bool busquedaEnLaTira;
  const LoadingControls(
      {super.key,
      required this.voyage,
      this.selectedBay,
      this.compact = false,
      this.busquedaEnLaTira = false});

  /// El botón de buscar por OR, el mismo de la línea del resumen, para la
  /// tira del pie del teléfono bajo. Desde T-122 (H4) no necesita el
  /// listado: sin él busca los llenos del plan por sus últimos dígitos.
  static Widget busquedaDeCarga(BuildContext context, WidgetRef ref,
          VesselVoyage voyage, int? selectedBay,
          {required bool disponible}) =>
      TextButton.icon(
          key: const ValueKey('load-search'),
          onPressed: !disponible
              ? null
              : () => chooseLoadingRow(context, ref, voyage,
                  selectedBay: selectedBay),
          icon: const Icon(Icons.search),
          label: const Text('OR / últimos dígitos'));
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ref.watch(loadingOperationProvider(voyage)).when(
            loading: () => const Text('Leyendo el plan combinado…'),
            error: (error, stack) => Text(vesselErrorMessage(
                error, stack, 'leer el plan de carga de la operación')),
            data: (data) {
              final bay = selectedBay == null
                  ? null
                  : data.progress.forBay(selectedBay!);
              final summary = [
                Text(
                    'Carga: ${operationCount(data.progress.total, 'pendiente', 'pendientes')} '
                    '(${operationCount(data.progress.full, 'lleno', 'llenos')} / ${operationCount(data.progress.empty, 'vacío', 'vacíos')}).',
                    key: const ValueKey('loading-operation-totals')),
                if (bay != null)
                  Text(
                      'Bahía ${bay.label}: cubierta ${bay.deck} · bodega ${bay.hold}.'),
                // T-107 · Con U+2011, «re‑estibas» no se parte en el guion.
                Text('Descarga: ${operationCount(data.discharge.pending, 'pendiente', 'pendientes')} '
                    '${pendingZones(data.discharge.deckPending, data.discharge.holdPending)} · '
                    '${operationCount(data.discharge.restows, 're‑estiba', 're‑estibas')}.'),
                if (data.list == null)
                  const Text(
                      'Sin listado de agencia: los llenos se cargan por su '
                      'número; los vacíos esperan el listado.'),
              ];
              final search = busquedaDeCarga(context, ref, voyage, selectedBay,
                  disponible: true);
              if (compact) {
                return PlanSummaryLine(
                    trailing: busquedaEnLaTira ? null : search,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: summary));
              }
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...summary,
                    Wrap(spacing: 8, children: [
                      search,
                      TextButton.icon(
                          key: const ValueKey('empty-search'),
                          onPressed: data.list == null
                              ? null
                              : () => chooseLoadingRow(context, ref, voyage,
                                  selectedBay: selectedBay, empties: true),
                          icon: const Icon(BsIconos.vacio),
                          label: const Text('Asignar vacío')),
                    ]),
                  ]);
            },
          );
}

/// T-107 · El resumen del modo en una sola línea, para pantallas angostas, con
/// [trailing] al lado («OR / últimos dígitos» en Carga). Un toque lo abre
/// completo, a todo el ancho y con un alto máximo para que la rejilla no se
/// quede sin espacio; otro lo recoge. Recogido, el resumen sigue en el árbol,
/// recortado a su primera línea, así que sus textos y sus claves de prueba no
/// cambian.
class PlanSummaryLine extends StatefulWidget {
  final Widget child;
  final Widget? trailing;
  const PlanSummaryLine({super.key, required this.child, this.trailing});
  @override
  State<PlanSummaryLine> createState() => _PlanSummaryLineState();
}

class _PlanSummaryLineState extends State<PlanSummaryLine> {
  bool open = false;

  @override
  Widget build(BuildContext context) {
    // El alto de una línea con la letra y la escala que usará el resumen.
    final painter = TextPainter(
        text: TextSpan(text: 'Ág', style: DefaultTextStyle.of(context).style),
        textDirection: TextDirection.ltr,
        textScaler: MediaQuery.textScalerOf(context),
        maxLines: 1)
      ..layout();
    final line = painter.height;
    painter.dispose();
    void toggle() => setState(() => open = !open);
    final icon = Icon(open ? Icons.expand_less : Icons.expand_more,
        size: line,
        semanticLabel: open ? 'Recoger el resumen' : 'Ver el resumen completo');
    if (!open) {
      return Row(key: const ValueKey('plan-summary-line'), children: [
        Expanded(
            child: InkWell(
                key: const ValueKey('plan-summary-toggle'),
                onTap: toggle,
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                      child: ClipRect(
                          child: SizedBox(
                              height: line,
                              child: OverflowBox(
                                  alignment: AlignmentDirectional.topStart,
                                  maxHeight: double.infinity,
                                  child: DefaultTextStyle.merge(
                                      maxLines: 1,
                                      softWrap: false,
                                      overflow: TextOverflow.ellipsis,
                                      child: widget.child))))),
                  icon,
                ]))),
        if (widget.trailing != null) widget.trailing!,
      ]);
    }
    final detail = ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * .3),
        child: SingleChildScrollView(child: widget.child));
    return Column(
        key: const ValueKey('plan-summary-line'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.trailing != null)
            Row(children: [
              Expanded(
                  child: InkWell(
                      key: const ValueKey('plan-summary-toggle'),
                      onTap: toggle,
                      child: Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: icon))),
              widget.trailing!,
            ]),
          InkWell(
              key: widget.trailing == null
                  ? const ValueKey('plan-summary-toggle')
                  : null,
              onTap: toggle,
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: detail),
                if (widget.trailing == null) icon,
              ])),
        ]);
  }
}

Future<void> chooseLoadingRow(
    BuildContext context, WidgetRef ref, VesselVoyage voyage,
    {int? selectedBay, bool empties = false, ReservedSlot? slot}) async {
  final row = await showModalBottomSheet<ExportListRow>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          _LoadingPicker(voyage: voyage, empties: empties, slot: slot));
  if (row == null || !context.mounted) return;
  await openLoadingRow(context, ref, voyage, row,
      selectedBay: selectedBay, slot: slot);
}

Future<void> openLoadingRow(
    BuildContext context, WidgetRef ref, VesselVoyage voyage, ExportListRow row,
    {int? selectedBay, ReservedSlot? slot}) async {
  final data = ref.read(loadingOperationProvider(voyage)).value;
  if (data == null) return;
  final numbered = data.numbered(row);
  final key = numbered?.key ??
      (slot == null
          ? null
          : data.plan.loadingItemAt(slot.stowagePosition.toIsoCode())?.key);
  if (key != null && data.movementOf(key) != null) {
    await showLoadingDetails(context, voyage, key);
    return;
  }
  if (numbered != null) {
    ref
        .read(selectedBayProvider.notifier)
        .select(data.bayOf(numbered.plannedPosition));
    ref.read(highlightedContainerProvider.notifier).highlight(row.containerId);
  }
  await showDialog<void>(
      context: context,
      builder: (_) => _LoadingEntry(
          voyage: voyage,
          row: row,
          selectedBay: selectedBay,
          position:
              numbered?.plannedPosition ?? slot?.stowagePosition.toIsoCode()));
}

class _LoadingPicker extends ConsumerStatefulWidget {
  final VesselVoyage voyage;
  final bool empties;
  final ReservedSlot? slot;
  const _LoadingPicker(
      {required this.voyage, required this.empties, this.slot});
  @override
  ConsumerState<_LoadingPicker> createState() => _LoadingPickerState();
}

class _LoadingPickerState extends ConsumerState<_LoadingPicker> {
  String? query = '';
  @override
  Widget build(BuildContext context) {
    final data = ref.watch(loadingOperationProvider(widget.voyage)).value;
    // T-77: desde una reserva se ofrecen primero los vacíos de su grupo; los
    // de otros grupos van después y piden motivo al confirmar.
    final slot = widget.slot;
    final rows = query == null ? <ExportListRow>[] : data
            ?.search(query!, empties: widget.empties)
            .where((row) =>
                slot == null ||
                data
                    .candidateSlots(row, otherGroups: true)
                    .any((s) => s.key == slot.key))
            .toList() ??
        [];
    if (slot != null) {
      rows.sort((a, b) =>
          (_sameGroup(slot, a) ? 0 : 1).compareTo(_sameGroup(slot, b) ? 0 : 1));
    }
    return SafeArea(
        child: SizedBox(
            height: MediaQuery.sizeOf(context).height * .8,
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  Text(
                      widget.empties
                          ? 'Vacíos del listado'
                          : 'Confirmar carga por OR o contenedor',
                      style: Theme.of(context).textTheme.titleMedium),
                  VoiceSearchField(onQuery: (value) => setState(() => query = value)),
                  if (rows.isEmpty && query != null)
                    const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No hay coincidencias disponibles.')),
                  Expanded(
                      child: ListView.builder(
                          itemCount: rows.length,
                          itemBuilder: (context, index) {
                            final row = rows[index];
                            final item = data!.numbered(row);
                            final current = item == null
                                ? data.state.items.values
                                    .where((s) =>
                                        s.assignedContainer == row.containerId)
                                    .firstOrNull
                                : data.state[item.key];
                            final operated = current?.state == ItemState.moved;
                            return ListTile(
                                key: ValueKey(row.unlisted
                                    ? 'loading-id-${row.containerId}'
                                    : 'loading-or-${row.order}'),
                                title: Text(row.label),
                                subtitle: Text(
                                    '${row.type} · ${row.pod} · ${row.line}'
                                    '${row.isEmpty ? '\nTara ${row.tareKg.toStringAsFixed(0)} kg' : ''}'
                                    '${slot != null && !_sameGroup(slot, row) ? '\nOtro grupo: pide motivo' : ''}'
                                    '${operated ? '\nYa cargado' : ''}'),
                                trailing: operated
                                    ? const Icon(Icons.check_circle_outline)
                                    : null,
                                onTap: () async {
                                  if (operated && current != null) {
                                    await showLoadingDetails(
                                        context, widget.voyage, current.key);
                                  } else {
                                    Navigator.pop(context, row);
                                  }
                                });
                          })),
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cerrar')),
                ]))));
  }
}

class _LoadingEntry extends ConsumerStatefulWidget {
  final VesselVoyage voyage;
  final ExportListRow row;
  final String? position;
  final int? selectedBay;
  final Movement? correcting;
  const _LoadingEntry(
      {required this.voyage,
      required this.row,
      this.position,
      this.selectedBay,
      this.correcting});
  @override
  ConsumerState<_LoadingEntry> createState() => _LoadingEntryState();
}

class _LoadingEntryState extends ConsumerState<_LoadingEntry> {
  late ExportListRow row = widget.row;
  late String? position = widget.position;
  late final _seal = TextEditingController(
      text: widget.correcting?.payload['seal'] as String?);
  final _hour = TextEditingController();
  final _reason = TextEditingController();

  /// T-77: un lleno que quedó en otra celda que la planificada.
  final _cell = TextEditingController();

  /// T-77: ofrecer también reservas de otros grupos, que piden motivo.
  bool otherGroups = false;
  DateTime date = DateTime.now();
  bool busy = false;
  String? error;
  @override
  void initState() {
    super.initState();
    final data = ref.read(loadingOperationProvider(widget.voyage)).value;
    final start = widget.position;
    final numbered = data?.numbered(row);
    if (numbered != null &&
        start != null &&
        start != numbered.plannedPosition) {
      _cell.text = loadingPosition(start);
    }
    final slot = start == null ? null : data?.plan.loadingItemAt(start);
    if (numbered == null &&
        slot?.reservedSlot != null &&
        !_sameGroup(slot!.reservedSlot!, row)) {
      otherGroups = true;
    }
    final previous = widget.correcting;
    if (previous != null) {
      date =
          (DateTime.tryParse(previous.payload['operatedAt'] as String? ?? '') ??
                  previous.createdAt)
              .toLocal();
      _hour.text =
          '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  void dispose() {
    _seal.dispose();
    _hour.dispose();
    _reason.dispose();
    _cell.dispose();
    super.dispose();
  }

  /// La celda que se va a registrar: para un lleno, la planificada salvo que
  /// se escriba otra; para un vacío, la reserva elegida.
  String? target(LoadingOperation? data) {
    final numbered = data?.numbered(row);
    if (numbered == null) return position;
    final typed = _cell.text.replaceAll(RegExp(r'[\s-]'), '');
    return typed.isEmpty ? numbered.plannedPosition : typed;
  }

  Future<void> save() async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final input = _hour.text.trim();
      DateTime? operatedAt;
      if (input.isNotEmpty) {
        final match = RegExp(r'^([01]?\d|2[0-3]):([0-5]\d)$').firstMatch(input);
        if (match == null) {
          throw StateError('Hora no válida: escríbela como HH:mm (00:00 a 23:59).');
        }
        operatedAt = DateTime(date.year, date.month, date.day,
            int.parse(match[1]!), int.parse(match[2]!));
      }
      final data = ref.read(loadingOperationProvider(widget.voyage)).value!;
      final at = target(data) ?? '';
      final occupant =
          data.check(row, at, correcting: widget.correcting).dischargeFirst;
      // Se arma antes de escribir: si la carga no pasa, no queda la descarga.
      final draft = data.draft(row, at,
          operatedAt: operatedAt,
          seal: _seal.text.trim().isEmpty ? null : _seal.text.trim(),
          correcting: widget.correcting,
          reason: _reason.text.trim(),
          dischargeOccupant: occupant != null);
      final repository = await ref.read(movementLogRepositoryProvider.future);
      final author = ref.read(movementAuthorProvider);
      if (!mounted) return;
      final cover = data.state.closedCoverAt(at);
      final remove = await confirmClosedHatch(context, cover);
      if (remove == null) return;
      MovementRecord? removed;
      if (remove && cover != null) {
        final first = await appendMovement(repository, MovementDraft.hatchCover(
            data.operationId!, cover.bay, cover.number, remove: true), author);
        if (first.error != null) throw StateError(first.error!);
        removed = first.record;
      }
      // T-77: «Marcar su descarga y cargar» son dos movimientos, en orden.
      MovementRecord? discharged;
      if (occupant != null) {
        final first = await appendMovement(
            repository, data.dischargeDraft(occupant), author);
        if (first.error != null) throw StateError(first.error!);
        discharged = first.record;
      }
      final result = await appendMovement(repository, draft, author);
      if (result.error != null) throw StateError(result.error!);
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(avisoDelViaje(
            key: const ValueKey('loading-undo-snackbar'),
            duracion: const Duration(seconds: 6),
            texto:
                '${discharged != null ? 'Descarga y carga registradas' : widget.correcting == null ? 'Carga registrada' : 'Carga corregida'} · ${row.name}',
            // Con la letra grande, si el entero no cabe sobre las cifras.
            corto:
                '${discharged != null ? 'Descarga y carga' : widget.correcting == null ? 'Cargado' : 'Corregido'} · ${row.name}',
            accion: 'Deshacer',
            onAccion: () async {
              var error = await annulMovement(repository,
                  result.record!.movement, markedByMistake, author);
              if (error == null && discharged != null) {
                error = await annulMovement(repository, discharged.movement,
                    markedByMistake, author);
              }
              if (error == null && removed != null) {
                error = await annulMovement(repository, removed.movement,
                    markedByMistake, author);
              }
              if (error != null) {
                messenger.showSnackBar(avisoDelViaje(
                    texto: 'No se deshizo: $error', corto: 'No se deshizo.'));
              }
            }));
    } catch (failure, stack) {
      if (mounted) {
        setState(() => error = failure is StateError
            ? failure.message
            : vesselErrorMessage(failure, stack, 'registrar la carga'));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(loadingOperationProvider(widget.voyage)).value;
    final numbered = data?.numbered(row);
    final slots = data?.candidateSlots(row,
            selectedBay: widget.selectedBay,
            correcting: widget.correcting,
            otherGroups: otherGroups) ??
        [];
    final validPosition = numbered != null
        ? target(data)
        : (slots.any((s) => s.stowagePosition.toIsoCode() == position)
            ? position
            : null);
    // T-77: la revisión se hace antes de escribir, con cada cambio del diálogo.
    final review = data == null || validPosition == null
        ? null
        : data.check(row, validPosition, correcting: widget.correcting);
    final needsReason =
        widget.correcting != null || (review?.needsReason ?? false);
    final occupant = review?.dischargeFirst;
    final alternatives = widget.correcting?.type == MovementType.assignEmpty
        ? data?.list?.empties
                .where((r) =>
                    data.available(r, correcting: widget.correcting) &&
                    data.numbered(r) == null)
                .toList() ??
            <ExportListRow>[]
        : <ExportListRow>[];
    return AlertDialog(
        title: Text(widget.correcting != null
            ? 'Corregir carga'
            : numbered == null
                ? 'Asignar vacío'
                : 'Confirmar carga'),
        content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(row.label,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('${row.type} · ${row.pod} · ${row.line}'),
                  if (row.isEmpty)
                    Text('Tara real: ${row.tareKg.toStringAsFixed(0)} kg'),
                  if (alternatives.isNotEmpty)
                    DropdownButtonFormField<ExportListRow>(
                        key: const ValueKey('loading-correct-or'),
                        isExpanded: true,
                        initialValue: alternatives.contains(row) ? row : null,
                        decoration:
                            const InputDecoration(labelText: 'OR del vacío'),
                        items: [
                          for (final r in alternatives)
                            DropdownMenuItem(
                                value: r,
                                child: Text('OR ${r.order} · ${r.containerId}'))
                        ],
                        onChanged: busy
                            ? null
                            : (r) {
                                if (r != null) {
                                  setState(() {
                                    row = r;
                                    position = null;
                                  });
                                }
                              }),
                  if (numbered != null) ...[
                    Text(
                        'Posición planificada: ${loadingPosition(numbered.plannedPosition)}'),
                    TextField(
                        key: const ValueKey('loading-cell'),
                        controller: _cell,
                        enabled: !busy,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                            labelText: 'Celda donde quedó (opcional)',
                            helperText:
                                'Vacío: la planificada. Otra celda (BBB-RR-TT) pide motivo.',
                            helperMaxLines: 2)),
                  ] else ...[
                    Text(otherGroups
                        ? 'Reservas libres: primero las de su grupo.'
                        : 'Reservas libres del mismo tipo, puerto y línea.'),
                    // Cambiar «otros grupos» cambia las opciones: el campo
                    // se reinicia para no conservar una celda que ya no está.
                    KeyedSubtree(
                        key: ValueKey('loading-slots-$otherGroups'),
                        child: DropdownButtonFormField<String>(
                            key: ValueKey('loading-position-${row.order}'),
                            isExpanded: true,
                            initialValue: validPosition,
                            decoration: const InputDecoration(
                                labelText: 'Celda reservada'),
                            items: [
                              for (final slot in slots)
                                DropdownMenuItem(
                                    value: slot.stowagePosition.toIsoCode(),
                                    child: Text(
                                        '${loadingPosition(slot.stowagePosition.toIsoCode())}'
                                        '${_sameGroup(slot, row) ? '' : ' · otro grupo'}'
                                        '${data?.state.occupancy.containsKey(slot.stowagePosition.toIsoCode()) == true ? ' · ocupada, baja aquí' : ''}'))
                            ],
                            onChanged: busy
                                ? null
                                : (value) {
                                    setState(() => position = value);
                                    if (value != null && data != null) {
                                      ref
                                          .read(selectedBayProvider.notifier)
                                          .select(data.bayOf(value));
                                      ref
                                          .read(highlightedContainerProvider
                                              .notifier)
                                          .highlight('R:$value');
                                    }
                                  })),
                    SwitchListTile(
                        key: const ValueKey('loading-other-groups'),
                        contentPadding: EdgeInsets.zero,
                        value: otherGroups,
                        onChanged: busy
                            ? null
                            : (value) => setState(() {
                                  otherGroups = value;
                                  final chosen = position == null
                                      ? null
                                      : data?.plan
                                          .loadingItemAt(position!)
                                          ?.reservedSlot;
                                  if (!value &&
                                      chosen != null &&
                                      !_sameGroup(chosen, row)) {
                                    position = null;
                                  }
                                }),
                        title: const Text('Mostrar reservas de otros grupos'),
                        subtitle: const Text('Piden motivo escrito.')),
                    if (slots.isEmpty)
                      const Text('No quedan reservas libres de este grupo.'),
                  ],
                  if (review != null)
                    _LoadCheckPanel(
                        check: review, portOfCall: widget.voyage.portOfCall),
                  const SizedBox(height: 12),
                  TextField(
                      key: const ValueKey('loading-hour'),
                      controller: _hour,
                      enabled: !busy,
                      keyboardType: TextInputType.datetime,
                      decoration: const InputDecoration(
                          labelText: 'Hora HH:mm (opcional)',
                          helperText: 'Sin hora: se usa la del registro.')),
                  TextButton(
                      onPressed: busy
                          ? null
                          : () async {
                              final picked = await showDatePicker(
                                  context: context,
                                  initialDate: date,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100));
                              if (picked != null && mounted) {
                                setState(() => date = picked);
                              }
                            },
                      child: Text(
                          'Fecha: ${date.day}/${date.month}/${date.year}')),
                  TextField(
                      key: const ValueKey('loading-seal'),
                      controller: _seal,
                      enabled: !busy,
                      decoration: const InputDecoration(
                          labelText: 'Marchamo (opcional)')),
                  if (needsReason)
                    TextField(
                        key: ValueKey(widget.correcting != null
                            ? 'loading-correction-reason'
                            : 'loading-reason'),
                        controller: _reason,
                        enabled: !busy,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                            labelText: widget.correcting != null
                                ? 'Motivo de la corrección'
                                : 'Motivo (obligatorio)',
                            helperText: review?.needsReason == true
                                ? 'Viaja con el movimiento y deja el conflicto a la vista.'
                                : null,
                            helperMaxLines: 2)),
                  if (error != null)
                    Text(error!,
                        key: const ValueKey('loading-error'),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                  if (widget.correcting == null && numbered != null)
                    OfficePlanActions(
                        voyage: widget.voyage, itemKey: numbered.key),
                ]))),
        actions: [
          if (numbered != null &&
              ref.watch(operatorProvider).value?.authorized == true &&
              ref.watch(operatorProvider).value?.role == OperatorRole.dock &&
              ref.watch(activeOperationProvider).value?.published == true)
            TextButton(
                key: const ValueKey('request-change-loading-detail'),
                onPressed: busy
                    ? null
                    : () => showChangeRequest(context, widget.voyage,
                        target: numbered.key),
                child: const Text('Pedir cambio')),
          TextButton(
              onPressed: busy ? null : () => Navigator.pop(context),
              child: const Text('Cancelar')),
          FilledButton(
              key: const ValueKey('loading-confirm'),
              onPressed: busy ||
                      validPosition == null ||
                      (review?.blocked ?? false) ||
                      (needsReason && _reason.text.trim().isEmpty)
                  ? null
                  : save,
              child: Text(busy
                  ? 'Guardando…'
                  : occupant != null
                      ? 'Marcar su descarga y cargar'
                      : widget.correcting != null
                          ? 'Guardar corrección'
                          : 'Confirmar carga'))
        ]);
  }
}

bool _sameGroup(ReservedSlot slot, ExportListRow row) =>
    slot.isoSizeType == row.type &&
    slot.portOfDischarge == row.pod &&
    slot.operatorCode == row.line;

/// T-77 · La revisión antes de confirmar. Cada línea lleva icono y texto,
/// no solo color, y se ajusta al ancho para leerse a 360 dp.
class _LoadCheckPanel extends StatelessWidget {
  final LoadCheck check;
  final String? portOfCall;
  const _LoadCheckPanel({required this.check, this.portOfCall});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget line(Key key, IconData icon, Color color, String text) => Padding(
        key: key,
        padding: const EdgeInsets.only(top: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: TextStyle(color: color))),
        ]));
    final stack = check.stack;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (final issue in check.issues)
        line(
            ValueKey('load-issue-${issue.kind.name}'),
            issue.blocks ? Icons.block : Icons.warning_amber,
            issue.blocks ? scheme.error : scheme.tertiary,
            '${issue.blocks ? 'No se registra' : 'Pide motivo'}: ${issue.message}'),
      if (check.dischargeFirst != null)
        line(
            const ValueKey('load-discharge-first'),
            BsIconos.descarga,
            scheme.primary,
            'La celda la ocupa ${check.dischargeFirst!.container?.containerId}, '
            'que baja en ${portOfCall ?? 'esta escala'} y no se ha marcado. '
            '«Marcar su descarga y cargar» registra las dos cosas.'),
      if (stack != null && stack.status != StackWeightStatus.exceeded)
        line(const ValueKey('load-stack'), BsIconos.pesoPila,
            scheme.onSurfaceVariant, stack.message),
      if (check.issues.isEmpty && check.dischargeFirst == null)
        line(
            const ValueKey('load-clean'),
            Icons.check_circle,
            scheme.onSurfaceVariant,
            'Revisado: tipo, celda y grupo coinciden con el plan.'),
    ]);
  }
}

Future<void> showLoadingDetails(
        BuildContext context, VesselVoyage voyage, String key) =>
    showDialog<void>(
        context: context,
        builder: (_) => Consumer(builder: (context, ref, _) {
              final data = ref.watch(loadingOperationProvider(voyage)).value;
              final state = data?.state[key];
              final movement = data?.movementOf(key);
              final container = state?.assignedContainer ??
                  (movement?.payload['container'] as String?) ??
                  key.substring(2);
              // H4: un lleno cargado sin fila también se corrige, por número.
              final row = data?.list?.byContainer(container) ??
                  (key.startsWith('C:') ? data?.unlistedRow(container) : null);
              return AlertDialog(
                  title: Text(row == null ? 'Carga' : row.label),
                  content: SingleChildScrollView(
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(state?.state == ItemState.moved
                            ? 'Cargado'
                            : state?.state == ItemState.cancelled
                                ? 'Cancelado'
                                : 'Pendiente'),
                        OfficePlanActions(voyage: voyage, itemKey: key),
                        if (state?.plannedPosition != null)
                          Text(
                              'Celda: ${loadingPosition(state!.plannedPosition!)}'),
                        if (state?.tareKg != null)
                          Text(
                              'Tara real: ${state!.tareKg!.toStringAsFixed(0)} kg'),
                        if (movement != null) ...[
                          Text(
                              'Registrado ${formatMovementTime(movement.createdAt)} · ${movement.author.name}'),
                          Text(
                              'Hora operada: ${formatMovementTime(DateTime.tryParse(movement.payload['operatedAt'] as String? ?? '') ?? movement.createdAt)}'),
                          Text(
                              'Marchamo: ${movement.payload['seal'] ?? 'Sin indicar'}'),
                          if (movement.reason?.isNotEmpty == true)
                            Text('Motivo: ${movement.reason}'),
                        ],
                        for (final conflict in data?.state.conflicts
                                .where((c) => c.key == key) ??
                            <OperationConflict>[])
                          Text(conflict.message,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error)),
                      ])),
                  actions: [
                    if (ref.watch(operatorProvider).value?.authorized == true &&
                        ref.watch(operatorProvider).value?.role ==
                            OperatorRole.dock &&
                        ref.watch(activeOperationProvider).value?.published ==
                            true)
                      TextButton(
                          key: const ValueKey('request-change-detail'),
                          onPressed: () =>
                              showChangeRequest(context, voyage, target: key),
                          child: const Text('Pedir cambio')),
                    if (movement != null &&
                        (movement.type == MovementType.loadFull ||
                            movement.type == MovementType.assignEmpty)) ...[
                      TextButton(
                          key: const ValueKey('loading-undo-detail'),
                          onPressed: () async {
                            final reason = await askAnnulReason(
                                context, row?.containerId ?? key);
                            if (reason == null || !context.mounted) return;
                            final repository = await ref
                                .read(movementLogRepositoryProvider.future);
                            final error = await annulMovement(
                                repository,
                                movement,
                                reason,
                                ref.read(movementAuthorProvider));
                            if (!context.mounted) return;
                            if (error != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  avisoDelViaje(
                                      texto: 'No se deshizo: $error',
                                      corto: 'No se deshizo.'));
                            } else {
                              Navigator.pop(context);
                            }
                          },
                          child: Text(movement.corrects == null
                              ? 'Deshacer carga'
                              : 'Deshacer corrección')),
                      if (row != null)
                        TextButton(
                            key: const ValueKey('loading-correct'),
                            onPressed: () async {
                              await showDialog<void>(
                                  context: context,
                                  builder: (_) => _LoadingEntry(
                                      voyage: voyage,
                                      row: row,
                                      position: movement.position ??
                                          state?.plannedPosition,
                                      selectedBay: state?.plannedPosition ==
                                              null
                                          ? null
                                          : data!
                                              .bayOf(state!.plannedPosition!),
                                      correcting: movement));
                            },
                            child: const Text('Corregir')),
                    ],
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cerrar')),
                  ]);
            }));

/// T-107 · La etiqueta de accesibilidad nombra el objeto como lo ve el
/// planner, igual que los avisos de T-106, nunca con su clave interna:
/// «OR 3 · TSTU0000003, sube», el número solo si no tiene orden, o
/// «Reserva 005 02 82 · 22G1 · GTSTC · MSK, sube».
String loadingCellSemantics(LoadingOperation operation, String itemKey) {
  final status = operation.state[itemKey];
  String container(String id, int? order) {
    final listed = operation.list?.byContainer(id)?.order ?? order;
    return listed == null ? id : 'OR $listed · $id';
  }

  final reserve = itemKey.startsWith('R:');
  final String name;
  if (reserve) {
    final p = IsoCoordinateParser.tryParse(itemKey.substring(2));
    final assigned = status?.assignedContainer;
    final group = operation.progress.label(itemKey);
    name = 'Reserva ${p == null ? itemKey.substring(2) : '${p.bayPadded} ${p.rowPadded} ${p.tierPadded}'}'
        '${assigned != null ? ' · ${container(assigned, status?.order)}' : group == '—' ? '' : ' · ${group.replaceAll('\n', ' · ')}'}';
  } else {
    name = container(
        itemKey.startsWith('C:') ? itemKey.substring(2) : itemKey,
        status?.order);
  }
  final mark = status?.inConflict == true
      ? 'revisar'
      : status?.state == ItemState.cancelled
          ? (reserve ? 'cancelada' : 'cancelado')
          : status?.state == ItemState.moved
              ? (reserve ? 'cargada' : 'cargado')
              : 'sube';
  return '$name, $mark';
}

/// La celda de carga en la dirección C (`DESIGN.md` 13): el OR como código,
/// el estado como rol (pendiente, hecho) y, en la oficina, como segunda
/// línea («Sube», «Cargado»); el conflicto y la cancelación van como marca,
/// con icono y rótulo. La etiqueta accesible sigue siendo la de T-107.
class LoadingCell extends StatelessWidget {
  final String itemKey;
  final LoadingOperation operation;
  final VoidCallback onTap;
  final bool highlighted;

  /// La curva del casco en las celdas de los extremos de la bodega (13.2).
  final BsCurvaDeCelda curva;

  /// Verdadero cuando este embarque es lo que se acaba de mover (13.3): la
  /// celda sale en naranja 1.5 s, sea un lleno o una reserva con su vacío
  /// asignado. Lo decide el plano con `recienMovidoProvider` (10.21, H2).
  final bool recienMovida;
  const LoadingCell(
      {super.key,
      required this.itemKey,
      required this.operation,
      required this.onTap,
      this.highlighted = false,
      this.curva = BsCurvaDeCelda.ninguna,
      this.recienMovida = false});
  @override
  Widget build(BuildContext context) {
    final status = operation.state[itemKey];
    final loaded = status?.state == ItemState.moved;
    final conflict = status?.inConflict == true;
    final cancelled = status?.state == ItemState.cancelled;
    final semanticos = BsColoresSemanticos.de(context);
    final label = status?.order == null
        ? operation.progress.label(itemKey)
        : 'OR ${status!.order}';
    final marca = conflict
        ? BsMarcaDeCelda.revisar
        : cancelled
            ? BsMarcaDeCelda.cancelado
            : BsMarcaDeCelda.ninguna;
    return BsCelda(
      codigo: label.replaceAll('\n', ' '),
      etiqueta: loadingCellSemantics(operation, itemKey),
      categoria: loaded ? semanticos.hecho : semanticos.pendiente,
      estado: recienMovida
          ? BsEstadoDeCelda.recienMovido
          : BsEstadoDeCelda.ninguno,
      linea2: loaded ? 'Cargado' : 'Sube',
      marca: marca,
      curva: curva,
      resaltada: highlighted,
      zoom: PlanZoomScope.of(context),
      onTap: onTap,
    );
  }
}
