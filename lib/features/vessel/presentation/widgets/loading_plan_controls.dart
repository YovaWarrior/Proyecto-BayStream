import 'package:flutter/material.dart';
import '../../../../core/design/design.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/entities.dart';
import '../../domain/services/operation_progress.dart';
import '../formatters/vessel_error_message.dart';
import '../formatters/operation_text.dart';
import '../pages/export_list_import_page.dart';
import '../pages/operation_progress_page.dart';
import '../pages/change_requests_page.dart';
import '../providers/discharge_provider.dart';
import '../providers/loading_plan_provider.dart';
import '../providers/loading_operation_provider.dart';
import '../providers/plano_providers.dart';
import '../providers/sync_providers.dart';
import '../providers/voyage_ui_state.dart';
import 'discharge_controls.dart';
import 'loading_controls.dart';
import 'navegacion_del_viaje.dart';
import 'resumen_del_modo.dart';
import 'sync_status_chip.dart';
import '../../../../core/utils/voyage_number.dart';

/// Modos de vista del plano. «Descarga» (T-75) solo existe en un plano de
/// llegada; fuera de ese modo, tocar una celda abre el detalle, como siempre.
enum BayPlanMode { content, order, discharge, loading }

/// Qué parte de los controles del plano se dibuja (`DESIGN.md` 13.8 y 14.8).
/// En el teléfono bajo la barra (el modo, «Acciones», el zoom) va al pie, en
/// la línea de la leyenda o de la barra de la operación, y el resumen del
/// modo justo encima del pie; en los demás teléfonos, todo junto sobre la
/// silueta. En la oficina, solo la parte de la franja de la bahía.
enum ParteDeLosControles {
  /// La barra y el resumen, sobre la silueta (T-107).
  todo,

  /// Solo la barra, en una tira que se desplaza: sin aire propio ni la nube,
  /// que en el teléfono ya está en la banda o en la barra superior.
  barra,

  /// Solo el resumen del modo, en su línea de T-107.
  resumen,

  /// La franja de la bahía de la oficina (14.8): el zoom, «OR / últimos
  /// dígitos» en Carga y «Acciones». El modo va en la cabecera y el resumen
  /// en la franja de cifras.
  franja,
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

  /// Qué se dibuja: todo, o solo la barra, el resumen o la franja.
  final ParteDeLosControles parte;

  /// En la franja de la bahía, «OR / últimos dígitos» solo con su icono y su
  /// descripción emergente, cuando con el rótulo no cabe en una línea (10.40).
  final bool orSoloIcono;

  /// En la franja de la bahía, «Acciones» solo con su icono, cuando ni así
  /// cabe en una línea (10.42, H3).
  final bool accionesSoloIcono;
  const LoadingPlanControls(
      {super.key,
      required this.voyage,
      required this.selectedBay,
      required this.mode,
      required this.onModeChanged,
      this.onOperationCell,
      this.zoom,
      this.parte = ParteDeLosControles.todo,
      this.orSoloIcono = false,
      this.accionesSoloIcono = false});

  bool get orderMode => mode == BayPlanMode.order;

  /// T-107 · Por debajo de este ancho (el teléfono) el encabezado se compacta
  /// en dos líneas. Desde aquí, la oficina (`DESIGN.md` 14.1).
  static const compactWidth = 600.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medidas = BsMedidas.de(context);
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
    // T-74: sin listado, «Importar listado» en «Acciones» del Número de orden.
    final importarListado = orderMode && progress?.value?.list == null &&
        progress?.hasValue == true;
    // En el muelle operando, Descarga y Carga están en la banda (14.6) y la
    // barra de la operación cuenta el modo (14.7).
    final enOperacion =
        voyage.portOfCall != null && ref.watch(voyageUiStateProvider) is Publicado;
    final conBanda = medidas.esMuelle && enOperacion;
    final conBarra = medidas.esMuelle && (dischargeMode || loadingMode);
    final acciones = AccionesDelPlano(
        voyage: voyage,
        selectedBay: selectedBay,
        dischargeMode: dischargeMode,
        loadingMode: loadingMode,
        onPendingTable: pendingTable,
        onProgress: voyage.portOfCall == null ? null : openProgress,
        importarListado: importarListado,
        // En el teléfono, «Acciones» va solo con su icono (0.6.2: «⋮»): la
        // línea de 360 dp lleva el modo, el zoom y la nube.
        soloIcono: parte != ParteDeLosControles.franja || accionesSoloIcono);
    Widget selector() => SelectorDelModo(
        voyage: voyage,
        forma: BsFormaDelSelector.menu,
        conBanda: conBanda,
        onModeChanged: onModeChanged);
    switch (parte) {
      case ParteDeLosControles.barra:
        // La tira del pie del teléfono bajo (13.8): el modo, «Acciones» y el
        // zoom, sin aire propio, en una línea que se desplaza.
        return _CompactPlanBar(
            voyage: voyage,
            selectedBay: selectedBay,
            modeSelector: selector(),
            actions: acciones,
            loadingMode: loadingMode,
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
              children: _summaryArea(dischargeMode, soloLaBahia: conBarra)),
        );
      case ParteDeLosControles.franja:
        // T-122 (H4): «OR / últimos dígitos» no necesita el listado; solo
        // espera a que el plan esté leído.
        final plan = loadingMode
            ? ref.watch(loadingOperationProvider(voyage)).value
            : null;
        return Row(mainAxisSize: MainAxisSize.min, children: [
          if (zoom != null) zoom!,
          if (loadingMode)
            LoadingControls.busquedaDeCarga(context, ref, voyage, selectedBay,
                disponible: plan != null, soloIcono: orSoloIcono),
          acciones,
        ]);
      case ParteDeLosControles.todo:
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _CompactPlanBar(
            voyage: voyage,
            selectedBay: selectedBay,
            modeSelector: selector(),
            actions: acciones,
            loadingMode: loadingMode,
            zoom: zoom),
        ..._summaryArea(dischargeMode, soloLaBahia: conBarra),
      ]),
    );
  }

  /// El resumen del modo en fichas (`DESIGN.md` 14.7), en la línea de T-107
  /// que se abre con un toque.
  List<Widget> _summaryArea(bool dischargeMode, {required bool soloLaBahia}) {
    if (mode == BayPlanMode.loading && voyage.portOfCall != null) {
      return [
        LoadingControls(
            voyage: voyage,
            selectedBay: selectedBay,
            compact: true,
            busquedaEnLaTira: parte == ParteDeLosControles.resumen,
            soloLaBahia: soloLaBahia)
      ];
    }
    return [
      _ResumenEnLinea(
          voyage: voyage,
          modo: dischargeMode ? BayPlanMode.discharge : mode,
          selectedBay: selectedBay,
          soloLaBahia: soloLaBahia)
    ];
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

/// El selector de modo del plano (`DESIGN.md` 14.6): `BsSelectorDeModo` con
/// los modos que la escala ofrece, sus iconos, sus cuentas y su ayuda. Lleva
/// la clave `bay-plan-display-mode`. Con la banda del muelle ([conBanda]),
/// Descarga y Carga solo aparecen si son el modo vigente: ya están en la
/// banda.
class SelectorDelModo extends ConsumerWidget {
  const SelectorDelModo({
    super.key,
    required this.voyage,
    required this.forma,
    this.conBanda = false,
    this.onModeChanged,
  });

  final VesselVoyage voyage;
  final BsFormaDelSelector forma;
  final bool conBanda;

  /// Qué pasa al elegir; sin él, el modo del plano cambia en su provider.
  final ValueChanged<BayPlanMode>? onModeChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(bayPlanModeProvider);
    final discharge = offersDischarge(voyage);
    final conEscala = voyage.portOfCall != null;
    // Un modo que esta escala no ofrece se ve como «Contenido», como antes.
    final elegido = (!discharge && mode == BayPlanMode.discharge) ||
            (!conEscala && mode == BayPlanMode.loading)
        ? BayPlanMode.content
        : mode;
    String? cuentaDeDescarga;
    String? cortaDeDescarga;
    if (discharge) {
      final progreso = ref.watch(dischargeProgressProvider(voyage)).value;
      if (progreso != null) {
        cuentaDeDescarga =
            '${progreso.pending} por bajar en ${voyage.portOfCall}';
        cortaDeDescarga = '${progreso.pending}';
      }
    }
    String? cuentaDeCarga;
    String? cortaDeCarga;
    String? cuentaDeOrden;
    if (conEscala) {
      final carga = ref.watch(loadingOperationProvider(voyage)).value?.progress;
      if (carga != null) {
        cuentaDeCarga =
            '${operationCount(carga.total, 'pendiente', 'pendientes')}: '
            '${operationCount(carga.full, 'lleno', 'llenos')}, '
            '${operationCount(carga.empty, 'vacío', 'vacíos')}';
        cortaDeCarga = '${carga.total}';
      }
      final plan = ref.watch(loadingPlanProgressProvider(voyage)).value;
      if (plan != null) {
        cuentaDeOrden = plan.list == null
            ? 'Sin listado de la agencia'
            : '${plan.labels.length} OR del listado';
      }
    }
    void elegir(BayPlanMode valor) {
      final cambio = onModeChanged;
      if (cambio != null) {
        cambio(valor);
      } else {
        ref.read(bayPlanModeProvider.notifier).elegir(valor);
      }
    }

    // El menú no es una ruta: abierto, se anota para que Atrás de Android lo
    // cierre antes que nada y ese Atrás no cuente como primer toque (10.42,
    // H2). El registro se toma aquí: el menú puede olvidarse al desmontarse,
    // cuando `ref` ya no se puede usar.
    final atras = ref.read(cerrablesDeAtrasProvider.notifier);
    return BsSelectorDeModo<BayPlanMode>(
      key: const ValueKey('bay-plan-display-mode'),
      forma: forma,
      elegido: elegido,
      onElegir: elegir,
      alAbrirElMenu: atras.anotar,
      alCerrarElMenu: atras.olvidar,
      entradas: [
        const BsEntradaDeModo(
          valor: BayPlanMode.content,
          rotulo: 'Contenido',
          icono: BsIconos.contenedor40,
          ayuda: 'El destino de cada contenedor',
        ),
        BsEntradaDeModo(
          valor: BayPlanMode.order,
          rotulo: 'Número de orden',
          rotuloCorto: 'Orden',
          icono: BsIconos.orden,
          cuenta: cuentaDeOrden,
          ayuda: 'Los OR del listado de la agencia',
        ),
        if (discharge && (!conBanda || elegido == BayPlanMode.discharge))
          BsEntradaDeModo(
            valor: BayPlanMode.discharge,
            rotulo: 'Descarga',
            icono: BsIconos.descarga,
            cuenta: cuentaDeDescarga,
            cuentaCorta: cortaDeDescarga,
            ayuda: 'Toca un contenedor para marcarlo como descargado',
          ),
        if (conEscala && (!conBanda || elegido == BayPlanMode.loading))
          BsEntradaDeModo(
            valor: BayPlanMode.loading,
            rotulo: 'Carga',
            icono: BsIconos.carga,
            cuenta: cuentaDeCarga,
            cuentaCorta: cortaDeCarga,
            ayuda: 'Toca un contenedor o busca su OR para cargarlo',
          ),
      ],
    );
  }
}

/// El resumen de Contenido, Número de orden y Descarga en la línea de T-107
/// (`PlanSummaryLine`), en fichas (`DESIGN.md` 14.7).
class _ResumenEnLinea extends ConsumerWidget {
  const _ResumenEnLinea({
    required this.voyage,
    required this.modo,
    required this.selectedBay,
    required this.soloLaBahia,
  });

  final VesselVoyage voyage;
  final BayPlanMode modo;
  final int? selectedBay;
  final bool soloLaBahia;

  @override
  Widget build(BuildContext context, WidgetRef ref) => PlanSummaryLine(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: fichasDelResumen(context, ref,
              voyage: voyage,
              modo: modo,
              bahia: selectedBay,
              soloLaBahia: soloLaBahia),
        ),
      );
}

/// «Acciones» del plano (T-107; `DESIGN.md` 14.7): las tablas de pendientes,
/// el avance de la operación, las solicitudes de cambio, «Asignar vacío» en
/// Carga e «Importar listado» en Número de orden sin listado. Cada entrada
/// hace lo mismo que su botón de antes y conserva su clave de prueba; la
/// cuenta de solicitudes pendientes se ve también en el botón.
class AccionesDelPlano extends ConsumerWidget {
  final VesselVoyage voyage;
  final int? selectedBay;
  final bool dischargeMode;
  final bool loadingMode;
  final VoidCallback? onPendingTable;
  final Future<void> Function()? onProgress;

  /// Número de orden sin listado: la entrada para importarlo.
  final bool importarListado;

  /// En el teléfono, solo el icono, con su nombre en la descripción
  /// emergente: en la tira del pie, para que la leyenda asome en 360 dp; en
  /// la línea de los controles, para que quepa el modo con su icono. Con el
  /// icono o con el rótulo, el lector de pantalla oye lo mismo: el botón
  /// «Acciones» (10.44).
  final bool soloIcono;
  const AccionesDelPlano(
      {super.key,
      required this.voyage,
      required this.selectedBay,
      required this.dischargeMode,
      required this.loadingMode,
      required this.onPendingTable,
      required this.onProgress,
      this.importarListado = false,
      this.soloIcono = false});

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
    Widget entry(IconData icon, String text) => Row(children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Flexible(child: Text(text)),
        ]);
    final rotulo = Row(mainAxisSize: MainAxisSize.min, children: [
      Badge(
          isLabelVisible: pending > 0,
          label: Text('$pending'),
          child: Icon(Icons.more_vert, color: colors.primary)),
      if (!soloIcono) ...[
        const SizedBox(width: 4),
        Text('Acciones', style: TextStyle(color: colors.primary)),
      ],
    ]);
    // Un botón con su nombre, dicho una vez (10.44, H4). Con un hijo propio,
    // `PopupMenuButton` no da el rol de botón, y Windows toma el nombre de la
    // etiqueta y le suma la descripción emergente: solo con el icono, el nodo
    // quedaba sin nombre y fuera del árbol; con el rótulo, «Acciones.
    // Acciones», como texto. El nombre lleva la cuenta del distintivo; la
    // descripción emergente sigue para el mouse, fuera de la semántica.
    final nombre = pending > 0
        ? 'Acciones, ${operationCount(pending, 'solicitud pendiente', 'solicitudes pendientes')}'
        : 'Acciones';
    return Tooltip(
      message: 'Acciones',
      excludeFromSemantics: true,
      child: Semantics(
        container: true,
        button: true,
        label: nombre,
        child: PopupMenuButton<VoidCallback>(
          key: const ValueKey('bay-plan-actions'),
          // Sin mensaje no pone el suyo: la descripción emergente es la de
          // fuera.
          tooltip: '',
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
            if (importarListado)
              PopupMenuItem(
                  key: const ValueKey('import-export-list'),
                  value: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const ExportListImportPage())),
                  child: entry(BsIconos.listadoAgencia, 'Importar listado')),
          ],
          child: ExcludeSemantics(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: soloIcono ? 12 : 8, vertical: 12),
              child: rotulo,
            ),
          ),
        ),
      ),
    );
  }
}

/// T-107 · La primera línea del encabezado en pantallas angostas: el modo,
/// «Acciones» con lo que en pantallas anchas son botones, y la nube como
/// ícono.
class _CompactPlanBar extends ConsumerWidget {
  final VesselVoyage voyage;
  final int? selectedBay;
  final Widget modeSelector;
  final Widget actions;
  final bool loadingMode;

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
      required this.actions,
      required this.loadingMode,
      this.zoom,
      this.tira = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final data = loadingMode
        ? ref.watch(loadingOperationProvider(voyage)).value
        : null;
    final status = voyage.portOfCall == null
        ? null
        : visibleSyncStatus(ref.watch(syncStatusProvider));
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
        Align(alignment: Alignment.centerLeft, child: modeSelector),
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
        Flexible(child: modeSelector),
        const SizedBox(width: 8),
        actions,
      ])),
      if (zoom != null) zoom!,
      if (nube != null) nube,
    ]);
  }
}
