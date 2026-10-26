import 'package:flutter/material.dart';
import '../../../../core/design/design.dart';
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
import '../../../../core/utils/voyage_number.dart';

/// Modos de vista del plano. «Descarga» (T-75) solo existe en un plano de
/// llegada; fuera de ese modo, tocar una celda abre el detalle, como siempre.
enum BayPlanMode { content, order, discharge, loading }

/// Qué parte de los controles del plano se dibuja (`DESIGN.md` 13.8). En el
/// teléfono bajo la barra (el modo, «Acciones», el zoom) va al pie, en la
/// línea de la leyenda o de la barra de la operación, y el resumen del modo
/// justo encima del pie; en los demás tamaños, todo junto sobre la silueta.
enum ParteDeLosControles {
  /// La barra y el resumen, sobre la silueta (T-107).
  todo,

  /// Solo la barra, en una tira que se desplaza: sin aire propio ni la nube,
  /// que en el teléfono ya está en la banda o en la barra superior.
  barra,

  /// Solo el resumen del modo, en su línea de T-107.
  resumen,
}

class LoadingPlanControls extends ConsumerWidget {
  final VesselVoyage voyage;
  final int? selectedBay;
  final BayPlanMode mode;
  final ValueChanged<BayPlanMode> onModeChanged;
  final ValueChanged<OperationCellLink>? onOperationCell;

  /// El chip del zoom del plano, que desde 10.20 va en esta línea y no sobre
  /// la rejilla (`ZoomDelPlano`); al final de la fila, antes de la nube.
  final Widget? zoom;

  /// Qué se dibuja: todo, o solo la barra o el resumen (el teléfono bajo).
  final ParteDeLosControles parte;
  const LoadingPlanControls(
      {super.key,
      required this.voyage,
      required this.selectedBay,
      required this.mode,
      required this.onModeChanged,
      this.onOperationCell,
      this.zoom,
      this.parte = ParteDeLosControles.todo});

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

    final loadingMode = mode == BayPlanMode.loading && voyage.portOfCall != null;
    switch (parte) {
      case ParteDeLosControles.barra:
        // La tira del pie del teléfono bajo (13.8): el modo, «Acciones» y el
        // zoom, sin aire propio, en una línea que se desplaza.
        return _CompactPlanBar(
            voyage: voyage,
            selectedBay: selectedBay,
            modeSelector: _modeSelector(discharge),
            dischargeMode: dischargeMode,
            loadingMode: loadingMode,
            onPendingTable: pendingTable,
            onProgress: voyage.portOfCall == null ? null : openProgress,
            zoom: zoom,
            tira: true);
      case ParteDeLosControles.resumen:
        // El resumen del modo encima del pie. Sin escala no hay resumen: la
        // banda del previo ya dice qué falta por confirmar.
        if (voyage.portOfCall == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _summaryArea(context, dischargeMode, progress, true)),
        );
      case ParteDeLosControles.todo:
        break;
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
                loadingMode: loadingMode,
                onPendingTable: pendingTable,
                onProgress: voyage.portOfCall == null ? null : openProgress,
                zoom: zoom)
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
                      icon: const Icon(Icons.table_chart),
                      label: const Text('Pendientes de descarga'),
                    )
                  else
                    TextButton.icon(
                      onPressed: pendingTable,
                      icon: const Icon(Icons.table_chart),
                      label: const Text('Pendientes por bahía'),
                    ),
                  if (voyage.portOfCall != null)
                    TextButton.icon(
                      key: const ValueKey('operation-progress-button'),
                      onPressed: openProgress,
                      icon: const Icon(Icons.assignment),
                      label: const Text('Avance de la operación'),
                    ),
                  if (voyage.portOfCall != null) const SyncStatusChip(),
                  if (voyage.portOfCall != null)
                    ChangeRequestsButton(voyage: voyage),
                  if (zoom != null) zoom!,
                ]),
          ..._summaryArea(context, dischargeMode, progress, compact),
        ]),
      );
    });
  }

  Widget _modeSelector(bool discharge, {bool compact = false}) {
    // El nombre del modo se lee entero: en la línea angosta se parte en dos
    // líneas antes que recortarse (10.8, 10.16), y los elementos del menú
    // crecen con la letra del sistema.
    // La elipsis es solo una red: con la letra del sistema el nombre cabe
    // (a 2.0 el selector pasa a su propia línea).
    Text label(String text) => Text(text,
        maxLines: compact ? 2 : 1, overflow: TextOverflow.ellipsis);
    return DropdownButton<BayPlanMode>(
      key: const ValueKey('bay-plan-display-mode'),
      isExpanded: compact,
      itemHeight: null,
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
            voyage: voyage,
            selectedBay: selectedBay,
            compact: compact,
            busquedaEnLaTira: parte == ParteDeLosControles.resumen)
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
      return [
        Text(vesselErrorMessage(progress.error!, progress.stackTrace,
            'calcular los pendientes de carga'))
      ];
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
                  Center(
                      child: Text(vesselErrorMessage(
                          error, stack, 'calcular los pendientes de carga'))),
              data: (data) {
                final bays = data.bays.values.toList()
                  ..sort((a, b) => a.bay.compareTo(b.bay));
                return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Pendientes de carga · ${voyage.vessel.name} · ${voyageNumberLabel(voyage.voyageNumber)} · ${voyage.portOfCall}',
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

  /// El chip del zoom (10.20), al final de la línea.
  final Widget? zoom;

  /// La tira del pie del teléfono bajo (13.8): el modo, «Acciones» y el zoom
  /// uno tras otro, a su ancho, sin la nube (ya está en la banda o en la
  /// barra superior) y sin repartir el ancho: la línea se desplaza.
  final bool tira;
  const _CompactPlanBar(
      {required this.voyage,
      required this.selectedBay,
      required this.modeSelector,
      required this.dischargeMode,
      required this.loadingMode,
      required this.onPendingTable,
      required this.onProgress,
      this.zoom,
      this.tira = false});

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
    // En la tira del pie, «Acciones» va solo con su icono y su descripción
    // emergente, para que la leyenda asome a la derecha en 360 dp.
    final rotuloDeAcciones = Row(mainAxisSize: MainAxisSize.min, children: [
      Badge(
          isLabelVisible: pending > 0,
          label: Text('$pending'),
          child: Icon(Icons.more_vert, color: colors.primary)),
      if (!tira) ...[
        const SizedBox(width: 4),
        Text('Acciones', style: TextStyle(color: colors.primary)),
      ],
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
                Icons.table_chart,
                dischargeMode
                    ? 'Pendientes de descarga'
                    : 'Pendientes por bahía')),
        if (onProgress != null)
          PopupMenuItem(
              key: const ValueKey('operation-progress-button'),
              value: () => onProgress!(),
              child: entry(Icons.assignment, 'Avance de la operación')),
        if (requests)
          PopupMenuItem(
              key: const ValueKey('change-requests-button'),
              value: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ChangeRequestsPage(voyage: voyage))),
              child: entry(
                  BsIconos.pedirCambio,
                  '${office ? 'Bandeja de cambios' : 'Solicitudes de cambio'} ($pending)')),
        if (loadingMode)
          PopupMenuItem(
              key: const ValueKey('empty-search'),
              enabled: data?.list != null,
              value: () => chooseLoadingRow(context, ref, voyage,
                  selectedBay: selectedBay, empties: true),
              child: entry(BsIconos.vacio, 'Asignar vacío')),
      ],
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: tira ? 12 : 8, vertical: 12),
        child: rotuloDeAcciones,
      ),
    );
    final nube = status == null
        ? null
        : IconButton(
            key: const ValueKey('sync-status-chip'),
            icon: Icon(syncStatusIcon(status),
                color: syncStatusNeedsAction(status)
                    ? colors.error
                    : colors.primary),
            tooltip: 'Nube y cuenta · ${syncStatusText(status)}',
            onPressed: () => openCloudPage(context),
          );
    if (tira) {
      // El modo, el zoom, «Acciones» y, en Carga, la búsqueda por OR, que
      // así queda al alcance del pulgar (13.8).
      return Row(mainAxisSize: MainAxisSize.min, children: [
        modeSelector,
        const SizedBox(width: 4),
        if (zoom != null) zoom!,
        actions,
        if (loadingMode)
          LoadingControls.busquedaDeCarga(context, ref, voyage, selectedBay,
              disponible: data != null),
      ]);
    }
    // Con la letra del sistema muy grande (10.8: a 2.0 «Contenido» no cabe
    // junto a «Acciones» en 360 dp), el selector va en su propia línea.
    final escala = MediaQuery.textScalerOf(context).scale(10) / 10;
    if (escala > 1.5) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        modeSelector,
        Row(children: [
          Expanded(child: Align(alignment: Alignment.centerLeft, child: actions)),
          if (zoom != null) zoom!,
          if (nube != null) nube,
        ]),
      ]);
    }
    return Row(children: [
      Expanded(
          child: Row(children: [
        Flexible(child: IntrinsicWidth(child: modeSelector)),
        const SizedBox(width: 8),
        actions,
      ])),
      if (zoom != null) zoom!,
      if (nube != null) nube,
    ]);
  }
}
