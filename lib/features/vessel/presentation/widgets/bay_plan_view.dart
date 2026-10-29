import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/design.dart';
import '../../../../core/utils/iso_coordinate_parser.dart';
import '../../domain/entities/entities.dart';
import '../../domain/services/discharge_progress.dart';
import '../../domain/services/loading_operation.dart';
import '../../domain/services/loading_plan_progress.dart';
import '../formatters/operation_text.dart';
import '../pages/operation_progress_page.dart';
import '../pages/stowage_alerts_page.dart';
import '../providers/discharge_provider.dart';
import '../providers/loading_operation_provider.dart';
import '../providers/loading_plan_provider.dart';
import '../providers/plano_providers.dart';
import '../providers/sync_providers.dart';
import '../providers/vessel_providers.dart';
import 'cifras_del_viaje.dart';
import 'detalle_contenedor.dart';
import 'discharge_controls.dart';
import 'franjas_del_plano.dart';
import 'hatch_cover_diagram.dart';
import 'hatch_operation_controls.dart';
import 'avisos_del_viaje.dart';
import 'barra_de_la_rejilla.dart';
import 'iconos_del_dominio.dart';
import 'loading_controls.dart';
import 'loading_plan_controls.dart';
import 'navegacion_del_viaje.dart';
import 'plan_drag_confirmation.dart';
import 'puente_del_plano.dart';
import 'reserved_slot_details.dart';
import 'silueta_del_viaje.dart';
import 'zoom_del_plano.dart';

/// El plano por bahía en la dirección C «Puente de mando» (`DESIGN.md` 13):
/// la silueta del buque como selector, las tarjetas de cifra con la
/// operación real, la rejilla dibujada como el ícono (celdas de radio 8, la
/// tapa, el casco que cierra la bodega), «Colorear por» con las fichas y la
/// regla del naranja para lo que se acaba de mover. Conserva el zoom, el
/// arrastre, los modos de T-74/T-75/T-81 y las claves de prueba de antes.
class BayPlanView extends ConsumerStatefulWidget {
  final VesselVoyage voyage;

  const BayPlanView({super.key, required this.voyage});

  @override
  ConsumerState<BayPlanView> createState() => _BayPlanViewState();
}

class _BayPlanViewState extends ConsumerState<BayPlanView> {
  int? _selectedBayNumber;
  final ScrollController _bayScrollController = ScrollController();

  /// La silueta compacta del panel del buque de la oficina (14.2): mientras
  /// se arrastra el borde se arman las dos alturas a la vez, cada una con su
  /// desplazamiento.
  final ScrollController _bayScrollControllerCompacto = ScrollController();

  @override
  void initState() {
    super.initState();
    // Respetar una selección hecha antes de construir esta pestaña. Sin
    // ella, la primera bahía con carga propia: una impar que solo trae la
    // sombra de los 40 de sus pares vecinas (T-110) no es por donde se
    // empieza a mirar un plano.
    if (widget.voyage.bays.isNotEmpty) {
      final sortedBayNumbers = widget.voyage.bays.keys.toList()..sort();
      final requestedBay = ref.read(selectedBayProvider);
      _selectedBayNumber =
          requestedBay != null && widget.voyage.bays.containsKey(requestedBay)
              ? requestedBay
              : sortedBayNumbers.firstWhere(
                  (n) => widget.voyage.bays[n]!.containers.isNotEmpty,
                  orElse: () => sortedBayNumbers.first);
    }
  }

  @override
  void dispose() {
    _bayScrollController.dispose();
    _bayScrollControllerCompacto.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(voyageNotifierProvider);
    final profile = ref.read(voyageNotifierProvider.notifier).currentProfile;
    final hatches = profile?.key ==
            (widget.voyage.vesselProfileKey ?? widget.voyage.vessel.profileKey)
        ? profile?.hatchCovers
        : null;
    final mode = ref.watch(bayPlanModeProvider);
    final vistas = ref.watch(colorearPorProvider);
    final vista = vistas[mode] ?? colorearPorOmision(mode);
    final porCarga = mode == BayPlanMode.loading || mode == BayPlanMode.order;
    final loading = porCarga && widget.voyage.portOfCall != null
        ? ref.watch(loadingOperationProvider(widget.voyage)).value
        : null;
    final displayedVoyage = loading?.loading ?? widget.voyage;
    final sortedBayNumbers = displayedVoyage.bays.keys.toList()..sort();
    final highlightedContainerId = ref.watch(highlightedContainerProvider);
    final activeTypeFilter = ref.watch(selectedTypeFilterProvider);
    final reservedNeighbors = displayedVoyage.neighborReservedSlots();
    final progress = widget.voyage.portOfCall == null
        ? null
        : ref.watch(loadingPlanProgressProvider(widget.voyage)).value;
    // T-75: la bitácora de descarga solo se abre en el modo Descarga.
    final dischargeMode =
        mode == BayPlanMode.discharge && offersDischarge(widget.voyage);
    final discharge = dischargeMode
        ? ref.watch(dischargeProgressProvider(widget.voyage)).value
        : null;
    // T-106: en Carga se ve lo que todavía baja aquí, con la marca de T-75.
    final arriving = <int, Map<String, ContainerUnit>>{};
    for (final item in loading?.plan.arrival.values ?? const <PlanItem>[]) {
      final status = loading!.state[item.key];
      final at = status?.position;
      if (item.role != PlanRole.discharge ||
          item.container == null ||
          status?.state != ItemState.planned ||
          at == null) {
        continue;
      }
      final p = IsoCoordinateParser.parse(at);
      arriving.putIfAbsent(p.bay, () => {})['${p.row}-${p.tier}'] =
          item.container!.copyWith(stowagePosition: p);
    }
    final twenties = _selectedBayNumber == null
        ? const <String, int>{}
        : _neighborTwenties(displayedVoyage, _selectedBayNumber!, arriving);

    // 13.3: lo que llega a la bitácora (lo propio y lo de la nube) enciende
    // el naranja de la celda; la primera lectura solo aprende lo que ya había.
    if (widget.voyage.portOfCall != null) {
      final operacion = loadingOperationProvider(widget.voyage);
      ref.listen(operacion, (previo, actual) {
        final movimientos = actual.value?.movements;
        if (movimientos != null) {
          ref.read(recienMovidoProvider.notifier).observar(movimientos);
        }
      });
      // Lo que ya está al construir se aprende sin destello; observar otra
      // vez lo mismo no hace nada.
      final yaLeidos = ref.read(operacion).value?.movements;
      if (yaLeidos != null) {
        ref.read(recienMovidoProvider.notifier).observar(yaLeidos);
      }
    }
    final recien = ref.watch(recienMovidoProvider);

    // Escuchar cambios en la bahía seleccionada desde búsqueda o perfil.
    ref.listen<int?>(selectedBayProvider, (previous, next) {
      if (next != null &&
          next != _selectedBayNumber &&
          displayedVoyage.bays.containsKey(next)) {
        setState(() {
          _selectedBayNumber = next;
        });
      }
    });

    if (sortedBayNumbers.isEmpty) {
      return const Center(
        child: Text('No hay bahías disponibles'),
      );
    }
    final medidas = BsMedidas.de(context);
    final bay = displayedVoyage.bays[_selectedBayNumber] ??
        displayedVoyage.bays[sortedBayNumbers.first]!;
    final enOperacion = dischargeMode ||
        (mode == BayPlanMode.loading && widget.voyage.portOfCall != null);

    // La oficina o el teléfono los decide la página (desde 600 dp de
    // ventana); el plano suelto, su ancho. Con la ventana entre 600 y unos
    // 720 dp, el plano mide menos de 600 y se armaba como teléfono dentro de
    // la oficina, con un segundo selector de modo.
    final enLaOficina = PanelLateralDisponible.enLaOficina(context);
    return LayoutBuilder(builder: (context, constraints) {
      final ancha =
          enLaOficina ?? constraints.maxWidth >= AnchosDeNavegacion.riel;
      // El teléfono bajo: con menos de 560 dp de alto útil (360 × 640 dp,
      // menos la banda y la barra inferior) la rejilla no cabe debajo de la
      // banda, la silueta y la leyenda; en 360 × 800 sí.
      final anidar = !ancha && constraints.maxHeight < alturaParaAnidar;
      // Los relojes del naranja (13.3) viven en la página, no aquí.
      // En el teléfono bajo (13.8, 10.21 H4) lo primero es la rejilla: los
      // controles del plano no van sobre la silueta sino al pie, en la línea
      // de la leyenda o de la barra de la operación, y el resumen del modo
      // justo encima del pie; así la primera fila se ve sin desplazar.
      LoadingPlanControls controlesDelPlano(ParteDeLosControles parte,
              {bool orSoloIcono = false, bool accionesSoloIcono = false}) =>
          LoadingPlanControls(
              voyage: widget.voyage,
              selectedBay: _selectedBayNumber,
              mode: mode,
              parte: parte,
              orSoloIcono: orSoloIcono,
              accionesSoloIcono: accionesSoloIcono,
              // El chip del zoom va aquí y no sobre la rejilla (10.20).
              zoom: const ZoomDelPlano(),
              onOperationCell: (cell) {
                final bayNumber = IsoCoordinateParser.parse(cell.position).bay;
                ref.read(bayPlanModeProvider.notifier).elegir(
                    cell.role == PlanRole.discharge
                        ? BayPlanMode.discharge
                        : BayPlanMode.loading);
                setState(() => _selectedBayNumber = bayNumber);
                ref.read(selectedBayProvider.notifier).select(bayNumber);
                ref.read(highlightedContainerProvider.notifier).highlight(
                    cell.role == PlanRole.discharge && cell.key.startsWith('C:')
                        ? cell.key.substring(2)
                        : cell.displayKey);
                ref.read(selectedTypeFilterProvider.notifier).clear();
              },
              onModeChanged: (value) =>
                  ref.read(bayPlanModeProvider.notifier).elegir(value));
      // La bahía elegida, con zoom y desplazamiento. En la oficina, a su alto
      // natural: la desplaza la columna (14.1).
      final rejilla = _selectedBayNumber != null
                ? _BayGridWidget(
                    desplazamientoPrimario: anidar,
                    compacta: anidar,
                    alturaNatural: ancha,
                    hatchCovers: hatches?[_selectedBayNumber],
                    bay: bay,
                    vista: vista,
                    recienMovidoId: recien?.containerId,
                    loading: loading,
                    dragVoyage: loading == null ? null : widget.voyage,
                    onContainerTap: loading != null
                        ? (container) => onLoadingContainerTap(
                            context, ref, widget.voyage, container,
                            selectedBay: _selectedBayNumber,
                            openDetails: () => _showContainerDetails(container))
                        : dischargeMode
                            ? (container) => _tocarEnDescarga(container, discharge)
                            : _showContainerDetails,
                    reservedSlots: displayedVoyage
                        .getReservedSlotsInBay(_selectedBayNumber!),
                    reservedNeighbors:
                        reservedNeighbors[_selectedBayNumber] ?? const {},
                    // En el modo Descarga, una reserva no se opera.
                    onReservedSlotTap: loading != null
                        ? (slot) => ref.read(operatorProvider).value?.role ==
                                    OperatorRole.office ||
                                loading.movementOf(loading.plan
                                        .loadingItemAt(
                                            slot.stowagePosition.toIsoCode())!
                                        .key) !=
                                    null
                            ? showLoadingDetails(
                                context,
                                widget.voyage,
                                loading.plan
                                    .loadingItemAt(
                                        slot.stowagePosition.toIsoCode())!
                                    .key)
                            : chooseLoadingRow(context, ref, widget.voyage,
                                empties: true,
                                selectedBay: _selectedBayNumber,
                                slot: slot)
                        : dischargeMode
                            ? (_) {}
                            : (slot) => showReservedSlotDetails(context, slot,
                                voyage: widget.voyage),
                    highlightedContainerId: highlightedContainerId,
                    activeTypeFilter: activeTypeFilter,
                    isInTransit: displayedVoyage.isInTransit,
                    orderMode: mode == BayPlanMode.order,
                    discharge: discharge,
                    progress: loading?.progress ?? progress,
                    portOfCall: widget.voyage.portOfCall,
                    arriving: arriving[_selectedBayNumber] ?? const {},
                    neighborTwenties: twenties,
                    onDetailsTap: _showContainerDetails,
                  )
                : const Center(child: Text('Selecciona una bahía'));
      if (ancha) {
        return _columnaDeOficina(
          displayedVoyage: displayedVoyage,
          bay: bay,
          sortedBayNumbers: sortedBayNumbers,
          mode: mode,
          vista: vista,
          porCarga: porCarga,
          dischargeMode: dischargeMode,
          enOperacion: enOperacion,
          loading: loading,
          discharge: discharge,
          twenties: twenties,
          hatchDeclarada: hatches?[bay.bayNumber] != null,
          rejilla: rejilla,
          controlesDelPlano: controlesDelPlano,
        );
      }
      final controles = controlesDelPlano(
          anidar ? ParteDeLosControles.barra : ParteDeLosControles.todo);
      final resumen =
          anidar ? controlesDelPlano(ParteDeLosControles.resumen) : null;
      final selector = _buildBaySelector(displayedVoyage, mode,
          porCarga: porCarga, compacta: anidar);
      // Abajo: en el muelle, operando, la barra de la operación; si no,
      // la leyenda de la vista. En el teléfono bajo, con los controles del
      // plano al principio de esa línea. Lo que los avisos de la página no
      // deben tapar se mide (10.29, H2; `avisos_del_viaje.dart`): la fila de
      // controles de la barra, dentro de `_barraDeOperacion`, o la leyenda
      // entera, que es toda controles. La barra entera también se mide: su
      // borde de arriba es el tope de los avisos (10.31).
      final pie = medidas.esMuelle && enOperacion
          ? _barraDeOperacion(dischargeMode, loading, discharge,
              tira: anidar ? controles : null)
          : MideElPieDelPlano(
              sinFranja: true,
              child: _buildLegend(displayedVoyage, bay, vista,
                  discharge: discharge,
                  twenties: twenties.isNotEmpty,
                  tira: anidar ? controles : null),
            );
      if (anidar) {
        // Teléfono bajo (13.8): arriba solo la silueta compacta, que se va
        // hacia arriba al desplazar la rejilla y vuelve al desplazarla hacia
        // abajo; la primera fila de la rejilla ya se ve sin desplazar. La
        // banda, el resumen, el pie con los controles y la barra inferior no
        // se mueven.
        return Column(children: [
          Expanded(
            child: NestedScrollView(
              key: const ValueKey('plano-anidado'),
              headerSliverBuilder: (context, _) => [
                SliverToBoxAdapter(
                  child: Column(children: [
                    selector,
                    const Divider(height: 1),
                  ]),
                ),
              ],
              body: rejilla,
            ),
          ),
          if (resumen != null) resumen,
          pie,
        ]);
      }
      return Column(children: [
        controles,
        selector,
        const Divider(height: 1),
        Expanded(child: rejilla),
        pie,
      ]);
    });
  }

  /// T-106: en una bahía par, cuántos 20 de sus impares vecinas ocupan cada
  /// «fila-nivel». Es la huella física de T-95 y 10.63, sin calcular pares:
  /// una par toca sus dos impares. Cuenta contenedores, reservas y lo que
  /// todavía baja; es solo dibujo.
  static Map<String, int> _neighborTwenties(VesselVoyage voyage, int bay,
      Map<int, Map<String, ContainerUnit>> arriving) {
    if (bay.isOdd) return const {};
    final counts = <String, int>{};
    void add(IsoCoordinate? p) {
      if (p == null || (p.bay != bay - 1 && p.bay != bay + 1)) return;
      final key = '${p.row}-${p.tier}';
      counts[key] = (counts[key] ?? 0) + 1;
    }

    for (final c in voyage.containers) {
      add(c.stowagePosition);
    }
    for (final s in voyage.reservedSlots) {
      add(s.stowagePosition);
    }
    for (final b in [bay - 1, bay + 1]) {
      for (final c in arriving[b]?.values ?? const <ContainerUnit>[]) {
        add(c.stowagePosition);
      }
    }
    return counts;
  }

  /// La columna central de la oficina (`DESIGN.md` 14.1): se desplaza entera.
  /// Arriba el panel del buque en tres alturas (14.2), la franja de la bahía
  /// fijada al desplazar (14.8), la rejilla a su alto natural por el zoom y
  /// la leyenda, que envuelve; abajo, fija, la franja de cifras, donde viven
  /// los avisos (14.5), o la barra de la operación en el muelle operando.
  Widget _columnaDeOficina({
    required VesselVoyage displayedVoyage,
    required Bay bay,
    required List<int> sortedBayNumbers,
    required BayPlanMode mode,
    required ColorearPor vista,
    required bool porCarga,
    required bool dischargeMode,
    required bool enOperacion,
    required LoadingOperation? loading,
    required DischargeProgress? discharge,
    required Map<String, int> twenties,
    required bool hatchDeclarada,
    required Widget rejilla,
    required LoadingPlanControls Function(ParteDeLosControles parte,
            {bool orSoloIcono, bool accionesSoloIcono})
        controlesDelPlano,
  }) {
    final medidas = BsMedidas.de(context);
    final puente = PuenteDelPlano(
      completo: _buildBaySelector(displayedVoyage, mode,
          porCarga: porCarga, oficina: true),
      compacto: _buildBaySelector(displayedVoyage, mode,
          porCarga: porCarga,
          oficina: true,
          compacta: true,
          controlador: _bayScrollControllerCompacto),
    );
    // Las cifras de la bahía van en la franja de cifras, que empieza por la
    // bahía (10.40); con la barra de la operación del muelle, en la franja
    // de la bahía.
    final cifras = FranjaDeLaBahia.cifrasDe(bay,
        reservas: displayedVoyage.getReservedSlotsInBay(bay.bayNumber).length,
        tapasDeclaradas: hatchDeclarada);
    final conBarra = medidas.esMuelle && enOperacion;
    final franja = FranjaDeLaBahia(
      bahia: bay.bayNumber,
      numeros: sortedBayNumbers,
      onBahia: (numero) {
        setState(() => _selectedBayNumber = numero);
        ref.read(selectedBayProvider.notifier).select(numero);
      },
      cifras: conBarra ? cifras : null,
      colorear: (forma) =>
          _colorearPor(mode, vista, dischargeMode: dischargeMode, forma: forma),
      controles: (
              {required bool orSoloIcono, required bool accionesSoloIcono}) =>
          controlesDelPlano(ParteDeLosControles.franja,
              orSoloIcono: orSoloIcono, accionesSoloIcono: accionesSoloIcono),
    );
    final leyenda = _buildLegend(displayedVoyage, bay, vista,
        discharge: discharge, twenties: twenties.isNotEmpty, envuelve: true);
    final pie = conBarra
        ? _barraDeOperacion(dischargeMode, loading, discharge)
        : FranjaDeCifras(
            voyage: widget.voyage,
            modo: mode,
            bahia: _selectedBayNumber,
            cifrasDeLaBahia: cifras);
    final partes = <Widget>[
      SliverToBoxAdapter(child: puente),
      FranjaFijadaSiCabe(child: franja),
      SliverToBoxAdapter(child: rejilla),
      SliverToBoxAdapter(child: leyenda),
    ];
    // T-119 (16.1 a 16.4): la barra horizontal de la rejilla va abajo de la
    // columna; el pestillo deja la rueda con la columna mientras se desplaza;
    // y la columna no se mueve mientras dura un pellizco del touchpad.
    return Column(children: [
      Expanded(
        child: BarraDeLaRejilla(
          child: BsPestilloDeLaRueda(
            child: Consumer(
              builder: (context, ref, _) => CustomScrollView(
                key: const ValueKey('columna-del-plano'),
                physics: ref.watch(pellizcoDelPlanoProvider)
                    ? const NeverScrollableScrollPhysics()
                    : null,
                slivers: partes,
              ),
            ),
          ),
        ),
      ),
      pie,
    ]);
  }

  /// «Colorear por» en la franja de la bahía (14.8): el mismo selector que el
  /// modo, sin iconos; Estado solo en Descarga, la única vista que lo pinta.
  Widget _colorearPor(BayPlanMode mode, ColorearPor vista,
          {required bool dischargeMode, required BsFormaDelSelector forma}) =>
      BsSelectorDeModo<ColorearPor>(
        key: const ValueKey('colorear-por'),
        nombre: 'Colorear por',
        forma: forma,
        elegido: vista,
        onElegir: (valor) =>
            ref.read(colorearPorProvider.notifier).elegir(mode, valor),
        // En menú, como el del modo: Atrás de Android lo cierra (10.42).
        alAbrirElMenu: ref.read(cerrablesDeAtrasProvider.notifier).anotar,
        alCerrarElMenu: ref.read(cerrablesDeAtrasProvider.notifier).olvidar,
        entradas: [
          if (dischargeMode)
            const BsEntradaDeModo(
                valor: ColorearPor.estado,
                rotulo: 'Estado',
                ayuda: 'Por bajar, bajado, de paso o recién movido'),
          const BsEntradaDeModo(
              valor: ColorearPor.destino,
              rotulo: 'Destino',
              ayuda: 'El puerto de descarga de cada contenedor'),
          const BsEntradaDeModo(
              valor: ColorearPor.tipo,
              rotulo: 'Tipo de vacío',
              ayuda: 'El tipo ISO de los vacíos; los llenos en papel'),
        ],
      );

  /// La silueta del buque como selector y, en la oficina, las tarjetas
  /// cortas a su derecha (`DESIGN.md` 14.2): por fila, las que caben junto a
  /// una silueta de 400 dp; en una fila si caben todas y si no en dos, y la
  /// compacta solo en una. Si no caben dos por fila (una, en la compacta),
  /// ninguna: las cifras siguen en la franja de cifras.
  Widget _buildBaySelector(VesselVoyage displayedVoyage, BayPlanMode mode,
      {required bool porCarga,
      bool compacta = false,
      bool oficina = false,
      ScrollController? controlador}) {
    final medidas = BsMedidas.de(context);
    final esquema = Theme.of(context).colorScheme;
    final paleta = BsPaleta.de(Theme.of(context).brightness);
    final silueta = SiluetaDelViaje(
      voyage: widget.voyage,
      displayedVoyage: displayedVoyage,
      seleccionada: _selectedBayNumber,
      porCarga: porCarga,
      controlador: controlador ?? _bayScrollController,
      compacta: compacta,
      onSeleccion: (bayNumber) =>
          ref.read(selectedBayProvider.notifier).select(bayNumber),
    );
    final tapas = widget.voyage.portOfCall == null
        ? null
        : IconButton(
            key: const ValueKey('hatch-operation-button'),
            tooltip: 'Tapas en la operación',
            icon: const Icon(BsIconos.tapaEscotilla),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => HatchOperationPage(
                    voyage: widget.voyage, initialBay: _selectedBayNumber))));
    final panelDeSilueta = Material(
      color: paleta.hoja,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(medidas.radioPanel),
        side: BorderSide(color: esquema.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(child: silueta),
          if (tapas != null) tapas,
        ],
      ),
    );
    final tarjetas = oficina && !medidas.esMuelle
        ? CifrasDelViaje.tarjetas(context, ref,
            voyage: widget.voyage,
            modo: mode,
            bahia: _selectedBayNumber,
            onAlertas: _abrirAlertas,
            corta: true)
        : const <Widget>[];
    return Container(
      key: const ValueKey('bay-selector'),
      padding: EdgeInsets.fromLTRB(medidas.espacioM, medidas.espacioXs,
          medidas.espacioM, compacta ? medidas.espacioXs : medidas.espacioS),
      child: tarjetas.isEmpty
          ? panelDeSilueta
          : LayoutBuilder(builder: (context, constraints) {
              // El ancho de la tarjeta crece con la letra (14.2): con 224 cabe
              // «120 de 150» a 28 junto al anillo de 40.
              final escala = MediaQuery.textScalerOf(context).scale(10) / 10;
              final ancho = BsTarjetaCifra.anchoCorta * escala;
              final hueco = medidas.espacioM;
              final caben = ((constraints.maxWidth - siluetaMinima) /
                      (ancho + hueco))
                  .floor();
              final filas = compacta ? 1 : 2;
              final minimo = compacta ? 1 : math.min(2, tarjetas.length);
              if (caben < minimo) return panelDeSilueta;
              final porFilaQueCabe = math.min(caben, tarjetas.length);
              final filasUsadas = math.min(
                  filas, (tarjetas.length / porFilaQueCabe).ceil());
              final mostradas =
                  math.min(tarjetas.length, porFilaQueCabe * filasUsadas);
              // Repartidas: con cuatro en dos filas, dos y dos.
              final porFila = (mostradas / filasUsadas).ceil();
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: panelDeSilueta),
                  SizedBox(width: hueco),
                  SizedBox(
                    width: porFila * ancho + (porFila - 1) * hueco,
                    child: Wrap(
                      spacing: hueco,
                      runSpacing: hueco,
                      children: [
                        for (final tarjeta in tarjetas.take(mostradas))
                          SizedBox(width: ancho, child: tarjeta),
                      ],
                    ),
                  ),
                ],
              );
            }),
    );
  }

  /// Lo que la silueta conserva junto a las tarjetas del panel del buque.
  static const double siluetaMinima = 400;

  Future<void> _abrirAlertas() async {
    final position = await Navigator.of(context).push<IsoCoordinate>(
      MaterialPageRoute(builder: (_) => const StowageAlertsPage()),
    );
    if (!mounted || position == null) return;
    ref.read(selectedTypeFilterProvider.notifier).clear();
    ref.read(selectedBayProvider.notifier).select(position.bay);
    final matches = widget.voyage.containers
        .where((c) => c.stowagePosition == position);
    if (matches.isNotEmpty) {
      ref
          .read(highlightedContainerProvider.notifier)
          .highlight(matches.first.containerId);
    }
  }

  /// La leyenda de la vista (`DESIGN.md` 5.4 y 13.4): las fichas con su
  /// cuenta y «Resaltar» (RF-011), con la muestra del mismo relleno y
  /// contorno que la celda. En el teléfono va en una línea que se desplaza;
  /// en la oficina ([envuelve]) envuelve al final de la columna y nunca se
  /// corta (14.9).
  Widget _buildLegend(VesselVoyage displayedVoyage, Bay bay, ColorearPor vista,
      {DischargeProgress? discharge,
      bool twenties = false,
      Widget? tira,
      bool envuelve = false}) {
    final activeFilter = ref.watch(selectedTypeFilterProvider);
    final semanticos = BsColoresSemanticos.de(context);
    final medidas = BsMedidas.de(context);
    final contenedores = bay.containers;
    final porVista = <BsEntradaDeLeyenda>[];
    switch (vista) {
      case ColorearPor.destino:
        final cuentas = <String, int>{};
        for (final c in contenedores) {
          final pod = c.portOfDischarge;
          if (pod != null) cuentas[pod] = (cuentas[pod] ?? 0) + 1;
        }
        final orden = cuentas.keys.toList()
          ..sort((a, b) => cuentas[b]!.compareTo(cuentas[a]!));
        for (final pod in orden.take(8)) {
          porVista.add(BsEntradaDeLeyenda(
              rotulo: pod, rol: semanticos.categorico(pod), cuenta: cuentas[pod]));
        }
      case ColorearPor.tipo:
        final cuentas = <String, int>{};
        for (final c in contenedores) {
          final iso = c.isoSizeType;
          if (iso != null && c.status == ContainerStatus.empty) {
            cuentas[iso] = (cuentas[iso] ?? 0) + 1;
          }
        }
        for (final slot in displayedVoyage.getReservedSlotsInBay(bay.bayNumber)) {
          final iso = slot.isoSizeType;
          if (iso != null) cuentas[iso] = (cuentas[iso] ?? 0) + 1;
        }
        final orden = cuentas.keys.toList()
          ..sort((a, b) => cuentas[b]!.compareTo(cuentas[a]!));
        for (final iso in orden.take(8)) {
          porVista.add(BsEntradaDeLeyenda(
              rotulo: '$iso vacío',
              rol: semanticos.categorico(iso),
              cuenta: cuentas[iso]));
        }
      case ColorearPor.estado:
        if (discharge != null) {
          final pendiente = discharge.forBay(bay.bayNumber);
          porVista.addAll([
            BsEntradaDeLeyenda(
                rotulo: 'Por bajar',
                rol: semanticos.porBajarCubierta,
                cuenta: pendiente?.pending ?? 0),
            BsEntradaDeLeyenda(
                rotulo: 'Bajado',
                rol: semanticos.bajado,
                cuenta: pendiente?.discharged ?? 0),
            BsEntradaDeLeyenda(rotulo: 'De paso', rol: semanticos.dePaso),
            if ((pendiente?.restows ?? 0) > 0)
              BsEntradaDeLeyenda(
                  rotulo: 'Re‑estiba',
                  rol: semanticos.enMovimiento,
                  cuenta: pendiente!.restows),
          ]);
        }
    }
    int cuenta(bool Function(ContainerUnit) prueba) =>
        contenedores.where(prueba).length;
    BsEntradaDeLeyenda resaltar(String rotulo, LegendFilterType tipo,
            {BsRol? rol, IconData? icono, required int cuenta}) =>
        BsEntradaDeLeyenda(
          rotulo: rotulo,
          rol: rol,
          icono: icono,
          cuenta: cuenta,
          activa: activeFilter == tipo,
          onTap: () => ref.read(selectedTypeFilterProvider.notifier).toggle(tipo),
        );
    final resaltares = <BsEntradaDeLeyenda>[
      resaltar('Lleno', LegendFilterType.full,
          icono: Icons.inventory_2,
          cuenta: cuenta((c) => c.status == ContainerStatus.full)),
      resaltar('Vacío', LegendFilterType.empty,
          icono: BsIconos.vacio,
          cuenta: cuenta((c) => c.status == ContainerStatus.empty)),
      resaltar('IMO', LegendFilterType.imo,
          rol: semanticos.peligrosa, cuenta: cuenta((c) => c.isDangerous)),
      resaltar('Refrigerado', LegendFilterType.reefer,
          rol: semanticos.refrigerado, cuenta: cuenta((c) => c.isReefer)),
      resaltar('OOG', LegendFilterType.oog,
          rol: semanticos.oog, cuenta: cuenta((c) => c.isOverDimension)),
      if (widget.voyage.portOfCall != null)
        resaltar('De paso', LegendFilterType.transit,
            rol: semanticos.dePaso,
            cuenta: cuenta(displayedVoyage.isInTransit)),
    ];
    final huecos = <BsEntradaDeLeyenda>[
      // C-5b: el hueco tomado por un 40 de la par vecina se declara siempre.
      const BsEntradaDeLeyenda(
          rotulo: 'Ocupado por 40 pies', icono: Icons.view_week),
      // T-106: la sombra de los 20 vecinos solo aparece en una par.
      if (twenties)
        const BsEntradaDeLeyenda(
            rotulo: 'Ocupado por 20 pies', icono: Icons.view_week),
      if (displayedVoyage.totalReservedSlots > 0)
        BsEntradaDeLeyenda(
            rotulo: 'Celda reservada', rol: semanticos.reservado),
    ];
    final cartela = BsCartela(
      key: const ValueKey('leyenda-del-plano'),
      titulo: 'Leyenda · ${vista.rotulo}',
      leyenda: [
        // La vista va de primera, como ficha sin tocar.
        BsEntradaDeLeyenda(rotulo: vista.rotulo, icono: Icons.palette),
        ...porVista,
        ...resaltares,
        ...huecos,
      ],
      compacta: true,
    );
    if (envuelve) {
      return Padding(
        padding: EdgeInsets.fromLTRB(medidas.espacioM, medidas.espacioS,
            medidas.espacioM, medidas.espacioL),
        child: cartela,
      );
    }
    // En el teléfono, en una línea que se desplaza: la rejilla se queda con
    // el alto. En el teléfono bajo, los controles del plano van delante de
    // la leyenda, en la misma línea, con el aire justo (13.8).
    final vertical = tira == null ? medidas.espacioS : medidas.espacioXs;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          medidas.espacioM, vertical, medidas.espacioM, vertical),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: tira == null
            ? cartela
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [tira, SizedBox(width: medidas.espacioS), cartela],
              ),
      ),
    );
  }

  /// La barra de la operación del muelle (`DESIGN.md` 9.3 y 13.8): las cifras
  /// del modo y la acción; el aviso con «Deshacer» sigue siendo el de T-75.
  Widget _barraDeOperacion(bool dischargeMode, LoadingOperation? loading,
      DischargeProgress? discharge,
      {Widget? tira}) {
    final semanticos = BsColoresSemanticos.de(context);
    final medidas = BsMedidas.de(context);
    final contadores = <BsContador>[];
    Widget? accion;
    if (dischargeMode && discharge != null) {
      contadores.addAll([
        BsContador(valor: '${discharge.pending}', rotulo: 'por bajar'),
        BsContador(
            valor: '${discharge.discharged}',
            rotulo: discharge.discharged == 1 ? 'hecha' : 'hechas',
            rol: semanticos.hecho),
        BsContador(valor: '${discharge.restows}', rotulo: 're‑estibas'),
      ]);
      accion = TextButton.icon(
        key: const ValueKey('barra-pendientes'),
        onPressed: () => showDischargeTable(context, widget.voyage),
        icon: const Icon(Icons.table_chart),
        label: const Text('Pendientes de descarga'),
      );
    } else if (loading != null) {
      contadores.addAll([
        BsContador(valor: '${loading.progress.total}', rotulo: 'pendientes'),
        BsContador(valor: '${loading.progress.full}', rotulo: 'llenos'),
        BsContador(valor: '${loading.progress.empty}', rotulo: 'vacíos'),
      ]);
      accion = TextButton.icon(
        key: const ValueKey('barra-avance'),
        onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => OperationProgressPage(voyage: widget.voyage))),
        icon: const Icon(Icons.assignment),
        label: const Text('Avance de la operación'),
      );
    }
    if (contadores.isEmpty) return const SizedBox.shrink();
    // En el teléfono bajo, los controles del plano van en la línea de la
    // acción, que se desplaza (13.8).
    final fila = tira == null
        ? accion
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                tira,
                if (accion != null) ...[
                  SizedBox(width: medidas.espacioS),
                  accion,
                ],
              ],
            ),
          );
    // Los avisos de la página flotan por encima de la fila de controles y
    // del aire de abajo de la barra (su `espacioM`), sobre las cifras, que no
    // se tocan (10.29, H2); y no pasan del borde de arriba de la barra, donde
    // termina la rejilla, sea cual sea su alto (10.31).
    return MideLaFranja(
      child: BsBarraDeOperacion(
        key: const ValueKey('barra-de-operacion'),
        contadores: contadores,
        accion: fila == null
            ? null
            : MideElPieDelPlano(
                key: const ValueKey('controles-de-la-franja'),
                ajuste: medidas.espacioM,
                child: fila,
              ),
      ),
    );
  }

  /// Un toque en Descarga (T-75) que, antes de registrar, saca la celda de
  /// su sitio en naranja (13.3): el planificador ve qué tocó mientras la
  /// bitácora escribe; cuando el movimiento llega, el naranja sigue desde él.
  Future<void> _tocarEnDescarga(
      ContainerUnit container, DischargeProgress? discharge) async {
    final position = container.stowagePosition;
    if (discharge != null &&
        position != null &&
        discharge.canRegister &&
        discharge.markOf(container.containerId) == DischargeMark.pending) {
      final rol = ref.read(movementAuthorProvider).role;
      ref.read(recienMovidoProvider.notifier).marcar(RecienMovido(
            containerId: container.containerId,
            bahia: position.bay,
            movimientoId: 'local:${container.containerId}',
            quien: rol == OperatorRole.office ? BsEquipo.oficina : BsEquipo.muelle,
          ));
    }
    await onDischargeTap(context, ref, widget.voyage, container,
        openDetails: () => _showContainerDetails(container));
  }

  /// El detalle: en la oficina con panel lateral va al panel; si no, una hoja
  /// (`DESIGN.md` 8). Una sola hoja de detalle para los dos.
  void _showContainerDetails(ContainerUnit container) {
    ref.read(highlightedContainerProvider.notifier).clear();
    if (PanelLateralDisponible.of(context)) {
      ref.read(celdaSeleccionadaProvider.notifier).elegir(container);
      return;
    }
    BsHojaDeDetalle.mostrar<void>(
      context,
      constructor: (context, controlador) => DetalleContenedor(
        voyage: widget.voyage,
        container: container,
        controlador: controlador,
      ),
    );
  }
}

/// La rejilla de una bahía, dibujada como el ícono (`DESIGN.md` 13.2).
/// Alto útil del plano por debajo del cual los controles y la silueta se
/// desplazan con la rejilla (`NestedScrollView`): 360 × 640 dp da unos 460;
/// 360 × 800, unos 620, y ahí la rejilla cabe debajo de la silueta.
const double alturaParaAnidar = 560;

class _BayGridWidget extends StatelessWidget {
  final Bay bay;
  final HatchCoverDeclaration? hatchCovers;
  final ColorearPor vista;
  final String? recienMovidoId;
  final bool orderMode;
  final LoadingPlanProgress? progress;
  final LoadingOperation? loading;
  final VesselVoyage? dragVoyage;

  /// T-75: solo en el modo Descarga; marca cada contenedor del plano de llegada.
  final DischargeProgress? discharge;
  final String? portOfCall;
  final Function(ContainerUnit) onContainerTap;
  final List<ReservedSlot> reservedSlots;
  final Map<String, ReservedSlot> reservedNeighbors;
  final void Function(ReservedSlot) onReservedSlotTap;
  final String? highlightedContainerId;
  final LegendFilterType? activeTypeFilter;

  /// Predicado del dominio: no se reimplementa la regla aqui.
  final bool Function(ContainerUnit) isInTransit;

  /// T-106: en Carga, lo que todavía baja en esta bahía, por «fila-nivel».
  final Map<String, ContainerUnit> arriving;

  /// T-106: en una par, cuántos 20 de sus impares vecinas ocupan cada celda.
  final Map<String, int> neighborTwenties;

  /// Solo abre los detalles: lo que baja no se opera desde el modo Carga.
  final void Function(ContainerUnit)? onDetailsTap;
  /// En el teléfono la rejilla es el desplazamiento primario del
  /// `NestedScrollView` del plano: al bajar por ella se va la silueta (la
  /// cabecera) y vuelve al subir. Se declara en vez de heredarlo, para que
  /// Windows y la Web hagan lo mismo que Android.
  final bool desplazamientoPrimario;

  /// El teléfono bajo (13.8): menos aire sobre el título y los pesos por
  /// pila debajo de la bodega, como en 9.2 bis, para que la primera fila se
  /// vea sin desplazar.
  final bool compacta;

  /// La oficina (14.1): la rejilla a su alto natural, sin desplazamiento
  /// vertical propio, y sin el título ni el resumen de la bahía, que van en
  /// la franja de la bahía.
  final bool alturaNatural;

  const _BayGridWidget({
    required this.bay,
    this.hatchCovers,
    required this.vista,
    this.recienMovidoId,
    required this.onContainerTap,
    required this.reservedSlots,
    required this.reservedNeighbors,
    required this.onReservedSlotTap,
    required this.isInTransit,
    this.orderMode = false,
    this.desplazamientoPrimario = false,
    this.compacta = false,
    this.alturaNatural = false,
    this.progress,
    this.loading,
    this.dragVoyage,
    this.discharge,
    this.portOfCall,
    this.highlightedContainerId,
    this.activeTypeFilter,
    this.arriving = const {},
    this.neighborTwenties = const {},
    this.onDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    // La rejilla sale de la geometría declarada del buque, nunca del contenido
    // de la bahía. Interpolar del mínimo al máximo cargado generaba 45 filas de
    // nivel por bahía de las que solo 13 podían tener carga.
    final geometry = bay.geometry;
    if (geometry == null) {
      return _buildMissingGeometryState(context);
    }

    // El código de cinco letras entero con la letra del sistema (10.8): si a
    // esta escala no cabe en la celda de la densidad, la celda se ensancha y
    // con ella la columna; la medida vive en el tema para que BsCelda la lea.
    final tema = Theme.of(context);
    final medidasBase = BsMedidas.de(context);
    final textos =
        tema.extension<BsTextos>() ?? BsTextos.de(BsPaleta.de(tema.brightness));
    final escalador = MediaQuery.textScalerOf(context);
    final pintor = TextPainter(
      // Las letras más anchas: «USMSY» no cabía a 1.45 medido con «GTSTC».
      text: TextSpan(text: 'WWWWW', style: textos.celda),
      textDirection: TextDirection.ltr,
      textScaler: escalador,
    )..layout();
    // Lo que el código mide con la fuente, y nunca más que lo que creció la
    // letra: a 1.0 la celda de la densidad alcanza (9.2); a 2.0 crece con el
    // texto y no más (una fuente de prueba más ancha no la dispara).
    final tope = medidasBase.anchoCelda * escalador.scale(10) / 10;
    final medido = pintor.width + 2 * (medidasBase.grosorContornoCelda + 3);
    final anchoNecesario = (medido < tope ? medido : tope).ceilToDouble();
    final medidas = anchoNecesario > medidasBase.anchoCelda
        ? medidasBase.copyWith(anchoCelda: anchoNecesario)
        : medidasBase;
    final rejilla = _Rejilla(
      grid: this,
      geometry: geometry,
      medidas: medidas,
    );
    if (identical(medidas, medidasBase)) return rejilla;
    // El tema con las medidas ensanchadas; las demás extensiones siguen.
    final extensiones = Map<Object, ThemeExtension<dynamic>>.of(tema.extensions)
      ..[BsMedidas] = medidas;
    return Theme(
      data: tema.copyWith(extensions: extensiones.values),
      child: rejilla,
    );
  }

  /// Estado para un viaje sin geometría declarada.
  ///
  /// Solo alcanzable con documentos anteriores a C-3: el flujo de carga no
  /// publica un viaje hasta que el usuario confirma los parámetros. No se
  /// dibuja una rejilla inferida del contenido, que es justamente el defecto
  /// que C-3 corrigió.
  Widget _buildMissingGeometryState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.straighten, size: 48, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            // En la oficina el título va en la franja de la bahía (14.1).
            if (!alturaNatural) ...[
              Text(
                'Bahía ${bay.bayNumber.toString().padLeft(2, '0')}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              'Este viaje no trae la geometría del buque declarada, así que no '
              'hay rejilla contra la cual dibujarlo. Declara los parámetros del '
              'buque para ver el plano.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

/// La rejilla con sus medidas ya resueltas.
class _Rejilla extends StatelessWidget {
  const _Rejilla({
    required this.grid,
    required this.geometry,
    required this.medidas,
  });

  final _BayGridWidget grid;
  final VesselGeometry geometry;
  final BsMedidas medidas;

  Bay get bay => grid.bay;

  /// El ancho de una columna: la celda con su hueco.
  double get columna => medidas.anchoCelda + medidas.huecoCelda;

  /// El alto de una fila de celdas.
  double get fila => medidas.altoCelda + medidas.huecoCelda;

  @override
  Widget build(BuildContext context) {
    final containers = bay.containers;
    final tema = Theme.of(context);
    final esquema = tema.colorScheme;
    final textos = tema.textTheme;

    // Crear mapa de posiciones para búsqueda rápida
    final positionMap = <String, ContainerUnit>{};
    for (final container in containers) {
      final pos = container.stowagePosition;
      if (pos != null) {
        positionMap['${pos.row}-${pos.tier}'] = container;
      }
    }
    final reservedPositionMap = <String, ReservedSlot>{
      for (final slot in grid.reservedSlots)
        '${slot.stowagePosition.row}-${slot.stowagePosition.tier}': slot,
    };

    // C-2 · Orden fijo de columnas: pares descendentes hacia babor, la fila 00
    // en el centro, e impares ascendentes hacia estribor. La fila 00 se dibuja
    // aunque este viaje no la traiga ocupada.
    final rows = geometry.orderedRows;

    // C-4 · Cubierta y bodega se calculan por separado, como ya hace el PDF.
    final deckTiers = geometry.deckTierNumbers;
    final holdTiers = geometry.holdTierNumbers;
    // T-102: solo la carga propia sin peso vuelve incompleta una pila.
    final missingDeckRows = <int>{};
    final missingHoldRows = <int>{};
    for (final container in containers) {
      final position = container.stowagePosition;
      if (position == null || container.effectiveWeight != null) continue;
      (geometry.isDeckTier(position.tier) ? missingDeckRows : missingHoldRows)
          .add(position.row);
    }

    // Ningún contenedor puede desaparecer en silencio: los que no caen en
    // ninguna celda dibujada se cuentan y se muestran encima de la rejilla.
    final drawnRows = rows.toSet();
    final drawnTiers = <int>{...deckTiers, ...holdTiers};
    final outsideGeometry = containers.where((container) {
      final pos = container.stowagePosition;
      if (pos == null) return true;
      return !drawnRows.contains(pos.row) || !drawnTiers.contains(pos.tier);
    }).toList();
    final outsideReserved = grid.reservedSlots.where((slot) {
      final pos = slot.stowagePosition;
      return !drawnRows.contains(pos.row) || !drawnTiers.contains(pos.tier);
    }).toList();

    final anchoDeFilas = rows.length * columna;

    Widget bloque(List<int> tiers, {required bool bodega}) {
      final etiquetas = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final tier in tiers)
            SizedBox(
              width: medidas.anchoEtiquetaNivel,
              height: fila,
              child: Center(
                child: Text(
                  tier.toString().padLeft(2, '0'),
                  style: textos.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontFeatures: cifrasTabulares),
                ),
              ),
            ),
        ],
      );
      final celdas = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final tier in tiers)
            SizedBox(
              height: fila,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: _celdasDeNivel(
                  context,
                  tier,
                  rows,
                  positionMap,
                  reservedPositionMap,
                  enCubierta: !bodega,
                  ultimaFila: bodega && tier == tiers.last,
                ),
              ),
            ),
        ],
      );
      final pesos = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final tier in tiers)
            SizedBox(
              width: medidas.anchoColumnaPesos,
              height: fila,
              child: _pesoDeNivel(context, tier),
            ),
        ],
      );
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          etiquetas,
          bodega
              ? BsCascoBodega(
                  radio: medidas.radioCasco * 2,
                  child: celdas,
                )
              : celdas,
          pesos,
        ],
      );
    }

    // Scroll vertical y horizontal para conservar la alineación en pantallas
    // angostas; en la oficina, la columna desplaza en vertical y el
    // horizontal va por fuera del zoom, con la barra de la columna (16.4).
    return LayoutBuilder(
      builder: (context, outer) => PlanZoomViewport(
        key: ValueKey('plan-zoom-${bay.bayNumber}'),
        alturaNatural: grid.alturaNatural,
        horizontal: grid.alturaNatural
            ? BarraDeLaRejilla.controladorDe(context)
            : null,
        // T-106: dentro del zoom el ancho es el de la vista lógica. A 300 % la
        // rejilla queda a la vista, sin un lienzo en blanco tan ancho como la
        // pantalla, y el margen de 16 dp se compensa para no ampliarse. En la
        // oficina el ancho no tiene tope (el desplazamiento está fuera) y la
        // vista lógica llega como el ancho mínimo.
        child: LayoutBuilder(builder: (context, constraints) {
          final margin = PlanZoomViewport.margen / PlanZoomScope.of(context);
          final vista = constraints.hasBoundedWidth
              ? constraints.maxWidth
              : constraints.minWidth;
          final inner = vista > 2 * margin ? vista - 2 * margin : 0.0;
          // C-7 · Peso de cada pila, como el plano impreso: dos líneas
          // alineadas con las columnas. Van arriba, donde el límite de
          // apilamiento aplica de verdad; en el teléfono bajo, debajo de la
          // bodega (9.2 bis), para que la primera fila se vea sin desplazar.
          final pesosPorPila = <Widget>[
            _buildStackWeights(
              context,
              rows: rows,
              weights: bay.deckWeightByRow,
              missingRows: missingDeckRows,
              zona: 'cub.',
              limitKg: geometry.stackWeightLimitKg,
            ),
            _buildStackWeights(
              context,
              rows: rows,
              weights: bay.holdWeightByRow,
              missingRows: missingHoldRows,
              zona: 'bod.',
              limitKg: geometry.stackWeightLimitKg,
            ),
            SizedBox(height: medidas.espacioXs),
          ];
          final contenido = Column(mainAxisSize: MainAxisSize.min, children: [
              if (grid.hatchCovers != null && outer.maxWidth < 600) ...[
                SizedBox(
                    width: inner,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Tapas · bahía ${bay.bayNumber.toString().padLeft(2, '0')}'),
                          HatchCoverDiagram(
                              key: const ValueKey('hatch-compact-plan'),
                              declaration: grid.hatchCovers,
                              rows: rows),
                        ])),
                const SizedBox(height: 12),
              ],
              // El título y el resumen de la bahía van al ancho de la vista,
              // no al de la rejilla: a 360 dp la rejilla es más ancha que la
              // pantalla y, centrado sobre ella, el título salía cortado. En
              // la oficina van en la franja de la bahía (14.1).
              if (!grid.alturaNatural) ...[
                SizedBox(
                  width: inner,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Bahía ${bay.bayNumber.toString().padLeft(2, '0')}'
                        '${grid.hatchCovers == null ? ' · tapas sin declarar' : ''}',
                        style: textos.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '${operationCount(bay.containers.length, 'contenedor', 'contenedores')}'
                        '${grid.reservedSlots.isEmpty ? '' : ' · ${operationCount(grid.reservedSlots.length, 'celda reservada', 'celdas reservadas')}'}'
                        ' · ${formatearToneladas(bay.totalWeight)}',
                        style: textos.bodyMedium
                            ?.copyWith(color: esquema.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                    height:
                        grid.compacta ? medidas.espacioXs : medidas.espacioS),
              ],
              _horizontalSiHaceFalta(
                minimo: inner,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Carga que la geometría declarada no alcanza a representar
                    if (outsideGeometry.isNotEmpty) ...[
                      _buildOutsideGeometryNotice(context, outsideGeometry),
                      SizedBox(height: medidas.espacioL),
                    ],
                    if (outsideReserved.isNotEmpty) ...[
                      _buildOutsideReservedNotice(context, outsideReserved),
                      SizedBox(height: medidas.espacioL),
                    ],

                    if (!grid.compacta) ...pesosPorPila,

                    // Header de rows
                    _buildRowHeader(context, rows),
                    SizedBox(height: medidas.espacioXs),

                    // Cubierta: los niveles sobre la tapa. La zona la dicen
                    // la tapa y el casco (13.2), no un rótulo.
                    if (deckTiers.isNotEmpty) bloque(deckTiers, bodega: false),

                    // La tapa de escotilla: la línea de 2 dp entre cubierta y
                    // bodega (13.2), en tinta.
                    if (deckTiers.isNotEmpty && holdTiers.isNotEmpty) ...[
                      SizedBox(height: medidas.espacioS),
                      Container(
                        key: const ValueKey('linea-de-tapa'),
                        width: anchoDeFilas,
                        height: 2,
                        margin: EdgeInsets.only(
                            left: medidas.anchoEtiquetaNivel,
                            right: medidas.anchoColumnaPesos),
                        decoration: BoxDecoration(
                          color: esquema.onSurface,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      SizedBox(height: medidas.espacioS),
                    ],

                    // Las tapas declaradas, con el ancho de las columnas.
                    if (grid.hatchCovers != null) ...[
                      Padding(
                          padding: EdgeInsets.only(
                              left: medidas.anchoEtiquetaNivel,
                              right: medidas.anchoColumnaPesos),
                          child: HatchCoverDiagram(
                              declaration: grid.hatchCovers,
                              rows: rows,
                              columnWidth: columna)),
                      SizedBox(height: medidas.espacioS),
                    ],

                    // Bodega: dentro del casco (13.2)
                    if (holdTiers.isNotEmpty) bloque(holdTiers, bodega: true),
                    SizedBox(height: medidas.espacioS),
                    if (grid.compacta) ...pesosPorPila,
                  ],
                ),
              ),
            ]);
          if (grid.alturaNatural) {
            return Padding(padding: EdgeInsets.all(margin), child: contenido);
          }
          return SingleChildScrollView(
            primary: grid.desplazamientoPrimario ? true : null,
            padding: grid.compacta
                ? EdgeInsets.fromLTRB(margin, margin / 2, margin, margin)
                : EdgeInsets.all(margin),
            child: contenido,
          );
        }),
      ),
    );
  }

  /// La rejilla, al menos tan ancha como la vista y centrada en ella. En el
  /// teléfono, dentro de su desplazamiento horizontal, que va en el zoom; en
  /// la oficina el desplazamiento va por fuera (`PlanZoomViewport`, 16.4) y
  /// la rejilla dice su ancho natural, para el punto fijo del zoom (16.3).
  /// Centrarla con `Align` mide lo mismo que la columna con ancho mínimo.
  Widget _horizontalSiHaceFalta(
          {required double minimo, required Widget child}) =>
      grid.alturaNatural
          ? ConstrainedBox(
              constraints: BoxConstraints(minWidth: minimo),
              child: Align(
                  alignment: Alignment.topCenter,
                  child: PlanZoomContenido(child: child)))
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: minimo), child: child));

  Widget _buildOutsideReservedNotice(
      BuildContext context, List<ReservedSlot> outside) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      key: const ValueKey('outside-reserved-geometry-notice'),
      constraints: const BoxConstraints(maxWidth: 520),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${outside.length} celdas reservadas fuera de la geometría declarada: '
        '${outside.take(6).map((slot) => slot.stowagePosition.toIsoCode()).join(', ')}'
        '${outside.length > 6 ? ' y ${outside.length - 6} más' : ''}. Amplía la '
        'geometría en Parámetros del buque.',
        style: TextStyle(color: colorScheme.onErrorContainer),
      ),
    );
  }

  /// Avisa de la carga que no cae en ninguna celda de la rejilla declarada.
  ///
  /// Un contenedor cuya coordenada quede fuera de la geometría no puede
  /// desaparecer sin más: la bahía mostraría menos carga de la que tiene y
  /// nadie se enteraría.
  Widget _buildOutsideGeometryNotice(
    BuildContext context,
    List<ContainerUnit> outside,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final positions = outside
        .map((container) =>
            container.stowagePosition?.rawCode ?? container.containerId)
        .toList();
    final shown = positions.take(6).join(', ');
    final rest = positions.length - 6;

    return Container(
      key: const ValueKey('outside-geometry-notice'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      // Ancho acotado a mano: este aviso vive dentro del scroll horizontal de
      // la rejilla, donde el ancho entrante es infinito y un hijo flexible no
      // puede repartirse el espacio.
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.report_outlined, color: colorScheme.onErrorContainer),
          const SizedBox(width: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  outside.length == 1
                      ? '1 contenedor fuera de la geometría declarada'
                      : '${outside.length} contenedores fuera de la geometría '
                          'declarada',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: colorScheme.onErrorContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'No se dibujan en la rejilla porque su posición no existe en '
                  'el buque declarado: ${rest > 0 ? '$shown y $rest más' : shown}. '
                  'Amplía la geometría en Parámetros del buque.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onErrorContainer,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Una línea de pesos por pila, alineada con las columnas de la rejilla.
  ///
  /// El límite de apilamiento se compara **aquí**, contra la pila vertical, y
  /// no contra la suma horizontal de un nivel. Sin límite declarado no se
  /// marca nada: la aplicación no inventa un umbral.
  Widget _buildStackWeights(
    BuildContext context, {
    required List<int> rows,
    required Map<int, double> weights,
    required Set<int> missingRows,
    required String zona,
    required double? limitKg,
  }) {
    final tema = Theme.of(context);
    final colorScheme = tema.colorScheme;
    final semanticos = BsColoresSemanticos.de(context);
    final estilo = tema.textTheme.labelSmall?.copyWith(
        color: colorScheme.onSurfaceVariant, fontFeatures: cifrasTabulares);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: medidas.anchoEtiquetaNivel,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(zona, textAlign: TextAlign.center, style: estilo),
          ),
        ),
        ...rows.map((row) {
          final weight = weights[row] ?? 0;
          final excede = limitKg != null && weight > limitKg;
          return Container(
            width: columna - 2,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 2),
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: excede
                ? BoxDecoration(
                    color: semanticos.error.relleno,
                    borderRadius: BorderRadius.circular(medidas.radioControl),
                  )
                : null,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                // Como el plano impreso: toneladas con un decimal, sin unidad.
                '${(weight / 1000).toStringAsFixed(1)}${missingRows.contains(row) ? '+?' : ''}',
                key: ValueKey('peso-pila-$zona-$row'),
                style: estilo?.copyWith(
                  fontWeight: excede ? FontWeight.w700 : FontWeight.w400,
                  color: excede ? semanticos.error.texto : null,
                ),
              ),
            ),
          );
        }),
        SizedBox(width: medidas.anchoColumnaPesos),
      ],
    );
  }

  Widget _buildRowHeader(BuildContext context, List<int> rows) {
    final estilo = Theme.of(context).textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w600, fontFeatures: cifrasTabulares);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: medidas.anchoEtiquetaNivel),
        ...rows.map((row) => SizedBox(
              width: columna,
              child: Text(
                row.toString().padLeft(2, '0'),
                textAlign: TextAlign.center,
                style: estilo,
              ),
            )),
        SizedBox(width: medidas.anchoColumnaPesos),
      ],
    );
  }

  /// C-7: el peso por nivel es la suma horizontal de las filas, no una pila.
  /// Se queda como dato informativo; el limite de apilamiento se compara
  /// arriba, contra cada pila, que es la magnitud que el nombre describe.
  Widget _pesoDeNivel(BuildContext context, int tier) {
    final tierWeight = bay.weightByTier[tier];
    if (tierWeight == null || tierWeight <= 0) return const SizedBox.shrink();
    final tema = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(left: medidas.espacioS),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          formatearToneladas(tierWeight),
          style: tema.textTheme.labelSmall?.copyWith(
            color: tema.colorScheme.onSurfaceVariant,
            fontFeatures: cifrasTabulares,
          ),
        ),
      ),
    );
  }

  /// Las celdas de un nivel, de babor a estribor.
  List<Widget> _celdasDeNivel(
    BuildContext context,
    int tier,
    List<int> rows,
    Map<String, ContainerUnit> positionMap,
    Map<String, ReservedSlot> reservedPositionMap, {
    required bool enCubierta,
    required bool ultimaFila,
  }) {
    final loading = grid.loading;
    final dragVoyage = grid.dragVoyage;
    final celdas = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      // 13.2: las celdas de los extremos de cada fila de bodega llevan la
      // curva del casco en su esquina exterior; la fila con una sola, las dos.
      final curva = enCubierta
          ? BsCurvaDeCelda.ninguna
          : rows.length == 1
              ? BsCurvaDeCelda.ambas
              : i == 0
                  ? BsCurvaDeCelda.babor
                  : i == rows.length - 1
                      ? BsCurvaDeCelda.estribor
                      : BsCurvaDeCelda.ninguna;
      final position = '${bay.bayNumber.toString().padLeft(3, '0')}'
          '${row.toString().padLeft(2, '0')}${tier.toString().padLeft(2, '0')}';
      Widget target(Widget cell, {String? itemKey}) =>
          dragVoyage == null || loading == null
              ? cell
              : PlanDragCell(
                  key: ValueKey('plan-cell-$position'),
                  voyage: dragVoyage,
                  data: loading,
                  position: position,
                  itemKey: itemKey,
                  enableDrag: !grid.orderMode,
                  child: cell);
      final key = '$row-$tier';
      final container = positionMap[key];
      final isHighlighted = container != null &&
          grid.highlightedContainerId != null &&
          container.containerId == grid.highlightedContainerId;
      final slotKey = '${row.toString().padLeft(2, '0')}'
          '${tier.toString().padLeft(2, '0')}';
      final reservation = reservedPositionMap[key];
      final reservedNeighbor = grid.reservedNeighbors[slotKey];
      final loadSlot = reservation ?? reservedNeighbor;
      final loadKey = container == null
          ? (loadSlot == null
              ? null
              : loading?.plan
                      .loadingItemAt(loadSlot.stowagePosition.toIsoCode())
                      ?.key ??
                  loadSlot.key)
          : 'C:${container.containerId}';
      if (loading != null &&
          loadKey != null &&
          loading.plan.loading[loadKey]?.role == PlanRole.load) {
        // T-122 (H6): la búsqueda general también resalta la reserva por el
        // número del vacío que se le asignó.
        final loadHighlighted = isHighlighted ||
            grid.highlightedContainerId == loadKey ||
            (grid.highlightedContainerId != null &&
                loading.state[loadKey]?.assignedContainer ==
                    grid.highlightedContainerId);
        // 13.3: lo recién movido también enciende la celda de carga, sea el
        // lleno del listado (C:) o la reserva con el vacío que se le asignó.
        final recien = grid.recienMovidoId;
        final recienMovida = recien != null &&
            (loadKey == 'C:$recien' ||
                loading.state[loadKey]?.assignedContainer == recien);
        final cell = LoadingCell(
            key: ValueKey('loading-$loadKey'),
            itemKey: loadKey,
            operation: loading,
            highlighted: loadHighlighted,
            curva: curva,
            recienMovida: recienMovida,
            onTap: container == null
                ? () => grid.onReservedSlotTap(loadSlot!)
                : () => grid.onContainerTap(container));
        celdas.add(target(
            loadHighlighted
                ? _RevealPosition(key: ValueKey(loadKey), child: cell)
                : cell,
            itemKey: loadKey));
        continue;
      }
      if (container == null && reservation != null) {
        celdas.add(target(_reserva(
          context,
          reservation,
          key: ValueKey('reserved-${reservation.key}'),
          orderLabel: grid.orderMode && reservation.portOfLoading == grid.portOfCall
              ? grid.progress?.label(reservation.key) ?? '—'
              : null,
          curva: curva,
          onTap: () => grid.onReservedSlotTap(reservation),
        )));
        continue;
      }
      if (container == null &&
          !bay.slotsOccupiedByNeighbors.contains(slotKey) &&
          reservedNeighbor != null) {
        celdas.add(target(_reserva(
          context,
          reservedNeighbor,
          key: ValueKey(
              'reserved-shadow-${bay.bayNumber}-$slotKey-${reservedNeighbor.key}'),
          orderLabel:
              grid.orderMode && reservedNeighbor.portOfLoading == grid.portOfCall
                  ? grid.progress?.label(reservedNeighbor.key) ?? '—'
                  : null,
          isNeighbor: true,
          curva: curva,
          onTap: () => grid.onReservedSlotTap(reservedNeighbor),
        )));
        continue;
      }
      // T-106: la descarga pendiente se ve ocupada, con la marca de T-75.
      // No se arrastra; soltar ahí sigue dando el rojo del dominio.
      final arrival = container == null ? grid.arriving[key] : null;
      if (arrival != null) {
        celdas.add(target(_contenedor(
            context,
            arrival,
            clave: ValueKey('pending-discharge-${arrival.containerId}'),
            mark: DischargeMark.pending,
            enCubierta: enCubierta,
            curva: curva,
            onTap: grid.onDetailsTap == null
                ? null
                : () => grid.onDetailsTap!(arrival),
        )));
        continue;
      }
      if (container == null) {
        celdas.add(target(_hueco(
          context,
          position: position,
          key: ValueKey('cell-$row-$tier'),
          ocupadaPorVecino: bay.slotsOccupiedByNeighbors.contains(slotKey),
          veintes: grid.neighborTwenties[key] ?? 0,
          curva: curva,
        )));
        continue;
      }
      final cell = _contenedor(
        context,
        container,
        clave: ValueKey('cell-$row-$tier'),
        orderLabel: grid.orderMode && container.portOfLoading == grid.portOfCall
            ? grid.progress?.label('C:${container.containerId}') ?? '—'
            : null,
        mark: grid.discharge?.markOf(container.containerId),
        isHighlighted: isHighlighted,
        isInTransit: grid.isInTransit(container),
        enCubierta: enCubierta,
        curva: curva,
        onTap: () => grid.onContainerTap(container),
      );
      celdas.add(target(isHighlighted
          ? _RevealPosition(key: ValueKey(container.containerId), child: cell)
          : cell));
    }
    return celdas;
  }

  /// Una celda con contenedor (`DESIGN.md` 5.4, 13.2 y 13.3): el código y el
  /// color según la vista, la insignia de carga especial, la marca de T-75 y
  /// el estado de la vista Estado; recién movida si es la que se acaba de
  /// mover.
  Widget _contenedor(
    BuildContext context,
    ContainerUnit container, {
    required Key clave,
    String? orderLabel,
    DischargeMark? mark,
    bool isHighlighted = false,
    bool isInTransit = false,
    required bool enCubierta,
    required BsCurvaDeCelda curva,
    VoidCallback? onTap,
  }) {
    final semanticos = BsColoresSemanticos.de(context);
    final esMuelle = medidas.esMuelle;
    final pod = container.portOfDischarge;
    final iso = container.isoSizeType;
    final pies = container.sizeInFeet?.toString() ?? '';
    final posicion = container.stowagePosition?.toIsoCode();
    final esRecien = grid.recienMovidoId != null &&
        container.containerId == grid.recienMovidoId;

    // Qué dice la celda y de qué color va, según «Colorear por».
    String codigo;
    BsRol? categoria;
    switch (grid.vista) {
      case ColorearPor.destino:
        codigo = pod ?? iso ?? pies;
        categoria = pod == null ? null : semanticos.categorico(pod);
      case ColorearPor.tipo:
        // Los vacíos por tipo; los llenos en papel.
        codigo = iso ?? pies;
        categoria = iso != null && container.status == ContainerStatus.empty
            ? semanticos.categorico(iso)
            : null;
      case ColorearPor.estado:
        codigo = pod ?? iso ?? pies;
        categoria = null;
    }
    // Número de orden (T-74): el número grande y «OR» como segunda línea.
    String? linea2 = container.effectiveWeight == null
        ? null
        : (container.effectiveWeight! / 1000).toStringAsFixed(1);
    if (orderLabel != null) {
      codigo = orderLabel.replaceFirst('OR ', '');
      linea2 = orderLabel.startsWith('OR ') ? 'OR' : null;
    }

    final insignia = container.isDangerous
        ? BsInsigniaDeCelda.peligrosa
        : container.isReefer
            ? BsInsigniaDeCelda.refrigerado
            : container.isOverDimension
                ? BsInsigniaDeCelda.oog
                : BsInsigniaDeCelda.ninguna;

    // El estado de la vista Estado manda en el relleno (13.2); la marca de
    // T-75 pone icono y rótulo en el muelle («Baja», «Hecho», «Paso») y en
    // las demás vistas; en la oficina, la vista Estado deja el código y el
    // peso a la vista, salvo la re‑estiba y el conflicto, que se nombran.
    var estado = BsEstadoDeCelda.ninguno;
    var marca = BsMarcaDeCelda.ninguna;
    if (mark != null) {
      if (grid.vista == ColorearPor.estado) {
        estado = switch (mark) {
          DischargeMark.pending => enCubierta
              ? BsEstadoDeCelda.porBajarCubierta
              : BsEstadoDeCelda.porBajarBodega,
          DischargeMark.transit => BsEstadoDeCelda.dePaso,
          DischargeMark.discharged => BsEstadoDeCelda.bajado,
          DischargeMark.restowed ||
          DischargeMark.cancelled ||
          DischargeMark.conflict =>
            BsEstadoDeCelda.ninguno,
        };
      }
      final conRotulo = esMuelle ||
          grid.vista != ColorearPor.estado ||
          mark == DischargeMark.restowed ||
          mark == DischargeMark.cancelled ||
          mark == DischargeMark.conflict;
      if (conRotulo) {
        marca = switch (mark) {
          DischargeMark.pending => BsMarcaDeCelda.baja,
          DischargeMark.discharged => BsMarcaDeCelda.hecho,
          DischargeMark.transit => BsMarcaDeCelda.paso,
          DischargeMark.restowed => BsMarcaDeCelda.reestiba,
          DischargeMark.cancelled => BsMarcaDeCelda.cancelado,
          DischargeMark.conflict => BsMarcaDeCelda.revisar,
        };
      }
    } else if (isInTransit) {
      // C-5a: la carga de paso se apaga en todas las vistas, como lo que el
      // planificador tacha a mano en el plano impreso: «lo que opero» contra
      // «lo que sigue a bordo».
      estado = BsEstadoDeCelda.dePaso;
      categoria = null;
    }
    if (esRecien) estado = BsEstadoDeCelda.recienMovido;

    // RF-011: atenuar contenedores que no coinciden con el filtro activo.
    final atenuada = grid.activeTypeFilter != null &&
        !_containerMatchesFilter(container, grid.activeTypeFilter!,
            isInTransit: isInTransit);

    // 10.23: la celda nombra lo que su insignia y su color señalan y el
    // lector no ve: la carga peligrosa, el refrigerado, el fuera de medida y
    // el vacío, con los nombres del ícono principal (`CondicionDelContenedor`),
    // en las tres vistas de «Colorear por». `BsCelda` excluye el resto.
    final condicion = condicionDelContenedor(container);
    final etiqueta = <String>[
      formatearContenedor(container.containerId),
      if (posicion != null) formatearPosicion(posicion),
      if (mark != null) dischargeMarkText(mark),
      if (condicion.enLaCelda) condicion.nombre,
      if (orderLabel != null) orderLabel.replaceAll('\n', ' '),
      if (isInTransit && mark == null) 'de paso',
    ].join(', ');

    final celda = BsCelda(
      // Sin marca, la clave va en la celda; con marca, por fuera.
      key: mark == null ? clave : null,
      codigo: codigo,
      etiqueta: etiqueta,
      categoria: categoria,
      // Peso en toneladas con un decimal, como el plano impreso («28.7»).
      linea2: linea2,
      insignia: insignia,
      marca: marca,
      estado: estado,
      curva: curva,
      resaltada: isHighlighted,
      atenuada: atenuada,
      zoom: PlanZoomScope.of(context),
      onTap: onTap,
    );
    if (mark == null) return celda;
    // La clave de la celda por fuera y la de la marca de T-75
    // («discharge-pending»), que las pruebas buscan, como única hija: dos
    // hermanas con la misma clave no se permiten.
    return KeyedSubtree(
      key: clave,
      child: KeyedSubtree(
        key: ValueKey('discharge-${mark.name}'),
        child: celda,
      ),
    );
  }

  /// Una reserva conserva el contorno y el destino, sin fingir carga ni peso.
  Widget _reserva(
    BuildContext context,
    ReservedSlot slot, {
    required Key key,
    String? orderLabel,
    bool isNeighbor = false,
    required BsCurvaDeCelda curva,
    required VoidCallback onTap,
  }) {
    final semanticos = BsColoresSemanticos.de(context);
    final tipo = slot.isoSizeType;
    final codigo = orderLabel ?? (isNeighbor ? "40′" : tipo ?? '?');
    return BsCelda(
      key: key,
      codigo: codigo,
      etiqueta:
          '${isNeighbor ? 'Extensión de 40 pies de la reserva' : 'Celda reservada'} '
          '${slot.key}, ${tipo ?? 'tipo no declarado'}, '
          '${slot.portOfDischarge ?? 'puerto no declarado'}',
      categoria: grid.vista == ColorearPor.tipo && tipo != null && !isNeighbor
          ? semanticos.categorico(tipo)
          : null,
      linea2: orderLabel != null ? null : slot.portOfDischarge,
      reservada: true,
      curva: curva,
      zoom: PlanZoomScope.of(context),
      onTap: onTap,
    );
  }

  /// Una celda sin contenedor: libre, tomada por un 40 de la par vecina
  /// (C-5b) o por 20 de las impares vecinas (T-106). Mostrarla libre cuando
  /// no lo está sería mentirle al planificador.
  Widget _hueco(
    BuildContext context, {
    required String position,
    required Key key,
    required bool ocupadaPorVecino,
    required int veintes,
    required BsCurvaDeCelda curva,
  }) {
    if (!ocupadaPorVecino && veintes > 0) {
      // Una clave por celda (O-124-1): fuera de Carga las celdas no llevan el
      // envoltorio del arrastre y dos sombras de la misma fila son hermanas.
      return KeyedSubtree(
        key: ValueKey('neighbor-twenty-$position'),
        child: BsCelda(
          key: key,
          codigo: veintes == 1 ? "20′" : "2×20′",
          etiqueta:
              'Celda ${formatearPosicion(position)}, ocupada por ${veintes == 1 ? 'un contenedor de 20 pies' : 'dos contenedores de 20 pies'} de las bahías vecinas',
          atenuada: true,
          curva: curva,
          zoom: PlanZoomScope.of(context),
        ),
      );
    }
    return BsCelda(
      key: key,
      codigo: ocupadaPorVecino ? "40′" : '',
      etiqueta: ocupadaPorVecino
          ? 'Celda ${formatearPosicion(position)}, ocupada por un contenedor de 40 pies de la bahía vecina'
          : 'Celda ${formatearPosicion(position)}, libre',
      atenuada: ocupadaPorVecino,
      curva: curva,
      zoom: PlanZoomScope.of(context),
    );
  }
}

/// Espera la transición de pestaña y desplaza ambos ejes hasta la posición.
class _RevealPosition extends StatefulWidget {
  final Widget child;
  const _RevealPosition({super.key, required this.child});

  @override
  State<_RevealPosition> createState() => _RevealPositionState();
}

class _RevealPositionState extends State<_RevealPosition> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      await Scrollable.ensureVisible(context,
          alignment: 0.5, duration: const Duration(milliseconds: 200));
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Determina si un contenedor coincide con el filtro de leyenda activo
bool _containerMatchesFilter(
  ContainerUnit container,
  LegendFilterType filter, {
  required bool isInTransit,
}) {
  switch (filter) {
    case LegendFilterType.full:
      return container.status == ContainerStatus.full;
    case LegendFilterType.empty:
      return container.status == ContainerStatus.empty;
    case LegendFilterType.imo:
      return container.isDangerous;
    case LegendFilterType.reefer:
      return container.isReefer;
    case LegendFilterType.oog:
      return container.isOverDimension;
    case LegendFilterType.transit:
      return isInTransit;
  }
}
