import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/entities.dart';
import '../../domain/services/loading_plan_progress.dart';
import '../../domain/services/operation_progress.dart';
import '../formatters/vessel_error_message.dart';
import '../formatters/operation_text.dart';
import '../pages/export_list_import_page.dart';
import '../pages/operation_progress_page.dart';
import '../pages/change_requests_page.dart';
import '../providers/discharge_provider.dart';
import '../providers/loading_plan_provider.dart';
import '../providers/loading_operation_provider.dart';
import '../providers/sync_providers.dart';
import 'discharge_controls.dart';
import 'loading_controls.dart';
import 'sync_status_chip.dart';

/// Modos de vista del plano. «Descarga» (T-75) solo existe en un plano de
/// llegada; fuera de ese modo, tocar una celda abre el detalle, como siempre.
enum BayPlanMode { content, order, discharge, loading }

class LoadingPlanControls extends ConsumerWidget {
  final VesselVoyage voyage;
  final int? selectedBay;
  final BayPlanMode mode;
  final ValueChanged<BayPlanMode> onModeChanged;
  final ValueChanged<OperationCellLink>? onOperationCell;
  const LoadingPlanControls(
      {super.key,
      required this.voyage,
      required this.selectedBay,
      required this.mode,
      required this.onModeChanged,
      this.onOperationCell});

  bool get orderMode => mode == BayPlanMode.order;

  /// T-107 · Por debajo de este ancho (el teléfono) el encabezado se compacta
  /// en dos líneas. Windows y la Web, más anchos, quedan como estaban.
  static const compactWidth = 600.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discharge = offersDischarge(voyage);
    final dischargeMode = discharge && mode == BayPlanMode.discharge;
    final progress = voyage.portOfCall == null
        ? null
        : mode == BayPlanMode.loading
            ? ref.watch(loadingOperationProvider(voyage)).whenData((d) => d.progress)
            : ref.watch(loadingPlanProgressProvider(voyage));
    final VoidCallback? pendingTable = dischargeMode
        ? () => showDischargeTable(context, voyage)
        : progress?.hasValue == true
            ? () => _table(context)
            : null;
    Future<void> openProgress() async {
      final cell = await Navigator.of(context).push<OperationCellLink>(
          MaterialPageRoute(builder: (_) => OperationProgressPage(voyage: voyage)));
      if (cell != null) onOperationCell?.call(cell);
    }

    return LayoutBuilder(builder: (context, constraints) {
      final compact = constraints.maxWidth < compactWidth;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (compact)
            _CompactPlanBar(
                voyage: voyage,
                selectedBay: selectedBay,
                modeSelector: _modeSelector(discharge, compact: true),
                dischargeMode: dischargeMode,
                loadingMode:
                    mode == BayPlanMode.loading && voyage.portOfCall != null,
                onPendingTable: pendingTable,
                onProgress: voyage.portOfCall == null ? null : openProgress)
          else
            Wrap(
                spacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _modeSelector(discharge),
                  if (dischargeMode)
                    TextButton.icon(
                      key: const ValueKey('discharge-table-button'),
                      onPressed: pendingTable,
                      icon: const Icon(Icons.table_chart_outlined),
                      label: const Text('Pendientes de descarga'),
                    )
                  else
                    TextButton.icon(
                      onPressed: pendingTable,
                      icon: const Icon(Icons.table_chart_outlined),
                      label: const Text('Pendientes por bahía'),
                    ),
                  if (voyage.portOfCall != null)
                    TextButton.icon(
                      key: const ValueKey('operation-progress-button'),
                      onPressed: openProgress,
                      icon: const Icon(Icons.assignment_outlined),
                      label: const Text('Avance de la operación'),
                    ),
                  if (voyage.portOfCall != null) const SyncStatusChip(),
                  if (voyage.portOfCall != null)
                    ChangeRequestsButton(voyage: voyage),
                ]),
          ..._summaryArea(context, dischargeMode, progress, compact),
        ]),
      );
    });
  }

  Widget _modeSelector(bool discharge, {bool compact = false}) {
    // En la línea angosta el nombre del modo se recorta antes que desbordar.
    Text label(String text) => compact
        ? Text(text, maxLines: 1, overflow: TextOverflow.ellipsis)
        : Text(text);
    return DropdownButton<BayPlanMode>(
      key: const ValueKey('bay-plan-display-mode'),
      isExpanded: compact,
      value: (!discharge && mode == BayPlanMode.discharge) ||
              (voyage.portOfCall == null && mode == BayPlanMode.loading)
          ? BayPlanMode.content
          : mode,
      items: [
        DropdownMenuItem(value: BayPlanMode.content, child: label('Contenido')),
        DropdownMenuItem(
            value: BayPlanMode.order, child: label('Número de orden')),
        if (discharge)
          DropdownMenuItem(
              value: BayPlanMode.discharge, child: label('Descarga')),
        if (voyage.portOfCall != null)
          DropdownMenuItem(value: BayPlanMode.loading, child: label('Carga')),
      ],
      onChanged: (value) {
        if (value != null) onModeChanged(value);
      },
    );
  }

  /// El resumen del modo. En pantallas angostas va en una línea que se abre
  /// con un toque (T-107); en las anchas, completo, como antes.
  List<Widget> _summaryArea(BuildContext context, bool dischargeMode,
      AsyncValue<LoadingPlanProgress>? progress, bool compact) {
    if (mode == BayPlanMode.loading && voyage.portOfCall != null) {
      return [
        LoadingControls(
            voyage: voyage, selectedBay: selectedBay, compact: compact)
      ];
    }
    if (dischargeMode) {
      final summary = DischargeSummary(voyage: voyage, selectedBay: selectedBay);
      return [compact ? PlanSummaryLine(child: summary) : summary];
    }
    if (voyage.portOfCall == null) {
      return [const Text('Confirma la escala para ver el plan de carga.')];
    }
    if (progress!.hasError) {
      return [Text(vesselErrorMessage(progress.error!, progress.stackTrace))];
    }
    if (!progress.hasValue) {
      return [const Text('Leyendo el estado de la operación…')];
    }
    final lines = [
      _summary(progress.value!, selectedBay),
      if (orderMode && progress.value!.list == null)
        Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
          const Text('Esta operación todavía no tiene listado de agencia.'),
          TextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const ExportListImportPage())),
              child: const Text('Importar listado')),
        ])
      else if (orderMode)
        Text('${operationCount(progress.value!.unmatched, 'celda de carga sin cruce', 'celdas de carga sin cruce')} (—).'),
    ];
    return compact
        ? [
            PlanSummaryLine(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: lines))
          ]
        : lines;
  }

  Widget _summary(LoadingPlanProgress progress, int? selected) {
    final bay = selected == null ? null : progress.forBay(selected);
    return Text(
        bay == null
            ? 'Pendientes de carga: 0 en esta bahía.'
            : 'Bahía ${bay.label} · pendientes de carga: '
                'cubierta ${bay.deck} (${operationCount(bay.deckFull, 'lleno', 'llenos')} / ${operationCount(bay.deckEmpty, 'vacío', 'vacíos')}) · '
                'bodega ${bay.hold} (${operationCount(bay.holdFull, 'lleno', 'llenos')} / ${operationCount(bay.holdEmpty, 'vacío', 'vacíos')})',
        key: const ValueKey('bay-loading-pending'));
  }

  void _table(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (context) => SafeArea(
            child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .8,
          child: Consumer(builder: (context, ref, _) {
            final progress = mode == BayPlanMode.loading
                ? ref.watch(loadingOperationProvider(voyage)).whenData((d) => d.progress)
                : ref.watch(loadingPlanProgressProvider(voyage));
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
                            'Pendientes de carga · ${voyage.vessel.name} · ${voyage.voyageNumber} · ${voyage.portOfCall}',
                            style: Theme.of(context).textTheme.titleMedium),
                        Text(
                            '${operationCount(bays.length, 'bahía', 'bahías')} · ${operationCount(data.total, 'pendiente', 'pendientes')} · '
                            '${data.deck} en cubierta / ${data.hold} en bodega · '
                            '${operationCount(data.full, 'lleno', 'llenos')} / ${operationCount(data.empty, 'vacío', 'vacíos')}',
                            key: const ValueKey('operation-loading-totals')),
                        if (data.list == null)
                          const Text('Sin listado: F/E según el plan.'),
                        const Text(
                            'Cub. = cubierta; Bod. = bodega; L = llenos; V = vacíos.'),
                        SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              horizontalMargin: 8,
                              columnSpacing: 12,
                              columns: [
                                for (final label in [
                                  'Bahía',
                                  'Cub. L',
                                  'Cub. V',
                                  'Bod. L',
                                  'Bod. V',
                                  'Total'
                                ])
                                  DataColumn(label: Text(label))
                              ],
                              rows: [
                                for (final bay in bays)
                                  DataRow(cells: [
                                    DataCell(Text(bay.label)),
                                    for (final count in [
                                      bay.deckFull,
                                      bay.deckEmpty,
                                      bay.holdFull,
                                      bay.holdEmpty,
                                      bay.deck + bay.hold
                                    ])
                                      DataCell(Text('$count')),
                                  ])
                              ],
                            )),
                        if (data.state.conflicts.isNotEmpty)
                          Text(
                              '${data.state.conflicts.length} conflictos en la bitácora; los pendientes respetan el estado derivado.'),
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
}

/// T-107 · La primera línea del encabezado en pantallas angostas: el modo,
/// «Acciones» con lo que en pantallas anchas son botones, y la nube como
/// ícono. Cada entrada hace lo mismo que su botón y conserva su clave de
/// prueba; la cuenta de solicitudes pendientes se ve también en «Acciones».
class _CompactPlanBar extends ConsumerWidget {
  final VesselVoyage voyage;
  final int? selectedBay;
  final Widget modeSelector;
  final bool dischargeMode;
  final bool loadingMode;
  final VoidCallback? onPendingTable;
  final Future<void> Function()? onProgress;
  const _CompactPlanBar(
      {required this.voyage,
      required this.selectedBay,
      required this.modeSelector,
      required this.dischargeMode,
      required this.loadingMode,
      required this.onPendingTable,
      required this.onProgress});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    // Las mismas condiciones que ChangeRequestsButton y SyncStatusChip.
    final actor = ref.watch(operatorProvider).value;
    final operation = ref.watch(activeOperationProvider).value;
    final requests = voyage.portOfCall != null &&
        actor?.authorized == true &&
        operation?.published == true;
    final office = actor?.role == OperatorRole.office;
    final data = requests || loadingMode
        ? ref.watch(loadingOperationProvider(voyage)).value
        : null;
    final pending = requests
        ? (data?.state.requests ?? const <ChangeRequest>[])
            .where((r) => r.status == ChangeRequestStatus.pending)
            .length
        : 0;
    final status = voyage.portOfCall == null
        ? null
        : visibleSyncStatus(ref.watch(syncStatusProvider));
    Widget entry(IconData icon, String text) => Row(children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Flexible(child: Text(text)),
        ]);
    final actions = PopupMenuButton<VoidCallback>(
      key: const ValueKey('bay-plan-actions'),
      tooltip: 'Acciones',
      onSelected: (action) => action(),
      // Las acciones usan el contexto del plano: el del menú ya se cerró.
      itemBuilder: (_) => [
        PopupMenuItem(
            key: dischargeMode
                ? const ValueKey('discharge-table-button')
                : null,
            enabled: onPendingTable != null,
            value: onPendingTable,
            child: entry(
                Icons.table_chart_outlined,
                dischargeMode
                    ? 'Pendientes de descarga'
                    : 'Pendientes por bahía')),
        if (onProgress != null)
          PopupMenuItem(
              key: const ValueKey('operation-progress-button'),
              value: () => onProgress!(),
              child: entry(Icons.assignment_outlined, 'Avance de la operación')),
        if (requests)
          PopupMenuItem(
              key: const ValueKey('change-requests-button'),
              value: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ChangeRequestsPage(voyage: voyage))),
              child: entry(
                  office ? Icons.inbox_outlined : Icons.swap_vert,
                  '${office ? 'Bandeja de cambios' : 'Solicitudes de cambio'} ($pending)')),
        if (loadingMode)
          PopupMenuItem(
              key: const ValueKey('empty-search'),
              enabled: data?.list != null,
              value: () => chooseLoadingRow(context, ref, voyage,
                  selectedBay: selectedBay, empties: true),
              child: entry(Icons.add_box_outlined, 'Asignar vacío')),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Badge(
              isLabelVisible: pending > 0,
              label: Text('$pending'),
              child: Icon(Icons.more_vert, color: colors.primary)),
          const SizedBox(width: 4),
          Text('Acciones', style: TextStyle(color: colors.primary)),
        ]),
      ),
    );
    return Row(children: [
      Expanded(
          child: Row(children: [
        Flexible(child: IntrinsicWidth(child: modeSelector)),
        const SizedBox(width: 8),
        actions,
      ])),
      if (status != null)
        IconButton(
          key: const ValueKey('sync-status-chip'),
          icon: Icon(syncStatusIcon(status),
              color: syncStatusNeedsAction(status)
                  ? colors.error
                  : colors.primary),
          tooltip: 'Nube y cuenta · ${syncStatusText(status)}',
          onPressed: () => openCloudPage(context),
        ),
    ]);
  }
}
