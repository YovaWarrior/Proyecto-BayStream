import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/design.dart';
import '../../../../core/utils/iso_coordinate_parser.dart';
import '../../../../core/utils/voyage_number.dart';
import '../../data/services/export_service.dart';
import '../../data/services/pdf_report_service.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/operation_sync_repository.dart';
import '../../domain/services/discharge_sequence.dart';
import '../../domain/services/operation_progress.dart';
import '../../domain/services/operation_sources.dart';
import '../providers/vessel_providers.dart';
import '../providers/discharge_provider.dart' show offersDischarge;
import '../providers/plano_providers.dart';
import '../providers/sync_providers.dart';
import '../providers/voyage_ui_state.dart';
import '../formatters/vessel_error_message.dart';
import '../widgets/voyage_summary_card.dart';
import '../widgets/reserved_slots_list_view.dart';
import '../widgets/containers_list_view.dart';
import '../widgets/inicio_view.dart';
import '../widgets/bay_plan_view.dart';
import '../widgets/container_search_delegate.dart';
import '../widgets/detalle_contenedor.dart';
import '../widgets/en_vivo_del_viaje.dart';
import '../widgets/hatch_operation_controls.dart';
import '../widgets/loading_plan_controls.dart' show BayPlanMode;
import '../widgets/navegacion_del_viaje.dart';
import '../widgets/voyage_stats_view.dart';
import '../widgets/sync_status_chip.dart';
import 'export_list_import_page.dart';
import 'departure_baplie_page.dart';
import 'operation_progress_page.dart';
import 'vessel_geometry_page.dart';
import 'vessel_profiles_page.dart';
import 'recent_voyages_page.dart';
import 'stowage_alerts_page.dart';
import 'parameters_page.dart';
import 'voyage_comparison_page.dart';
import 'discharge_sequence_page.dart';

/// Página principal de la aplicación BayStream
///
/// Sin viaje es el inicio (`DESIGN.md` 9.1). Con un archivo leído, el plano
/// abre en previo («ver primero, confirmar después», `DESIGN.md` 7): se mira,
/// se busca y se colorea; para operar, publicar o exportar hay que confirmar
/// el perfil y la escala desde la banda. Confirmado, es lo de siempre.
///
/// Con un viaje, la navegación es adaptable (`DESIGN.md` 8 y 13.7): por
/// debajo de 600 dp la barra inferior (Plano · Lista · Avance · Estadísticas
/// · Más) y, en el muelle con una escala, la banda de la marca arriba; desde
/// 600 dp el riel con la marca encima y la cabecera de la oficina; desde
/// 1200 dp, además, el panel lateral de 360 con el detalle de la celda y
/// «En vivo». «Más» abre una hoja con lo que antes eran las ocho acciones
/// de la barra.
class VesselOverviewPage extends ConsumerStatefulWidget {
  const VesselOverviewPage({super.key});

  @override
  ConsumerState<VesselOverviewPage> createState() => _VesselOverviewPageState();
}

class _VesselOverviewPageState extends ConsumerState<VesselOverviewPage> {
  @override
  Widget build(BuildContext context) {
    final ui = ref.watch(voyageUiStateProvider);
    final voyage = switch (ui) {
      Previo(:final voyage) => voyage,
      Publicado(:final voyage) => voyage,
      _ => null,
    };
    final preview = ui is Previo;

    final parametersButton = IconButton(
      key: const ValueKey('edit-geometry'),
      icon: const Icon(Icons.straighten),
      tooltip: 'Parámetros',
      onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => ParametersPage(
          onVesselParameters:
              voyage != null ? () => _askForGeometry(context) : null,
        ),
      )),
    );

    if (voyage == null) {
      return Scaffold(
        appBar: AppBar(
          title: const FittedBox(
            fit: BoxFit.scaleDown,
            child: Text('BayStream', maxLines: 2),
          ),
          centerTitle: true,
          // El inicio solo lleva Parámetros y Nube (DESIGN.md 9.1): la
          // carga, los recientes y los perfiles están en el cuerpo.
          actions: [parametersButton, const SyncAppBarButton()],
        ),
        body: switch (ui) {
          Leyendo(:final fileName) => _Leyendo(fileName: fileName),
          Fallo(:final mensaje) => _Fallo(
              mensaje: mensaje,
              onRetry: () => _loadBaplieFile(context),
            ),
          _ => InicioView(
              onPickFile: () => _loadBaplieFile(context),
              onOpenRecent: (recent) => _openRecent(context, recent),
            ),
        },
      );
    }

    final destino = ref.watch(destinoDelViajeProvider);
    final destinos = <DestinoDelViaje>[
      DestinoDelViaje.plano,
      DestinoDelViaje.lista,
      if (voyage.portOfCall != null) DestinoDelViaje.avance,
      DestinoDelViaje.estadisticas,
      DestinoDelViaje.mas,
    ];
    final alertas = ref.watch(cuentaDeAlertasProvider);
    final critica = ref.watch(alertaCriticaProvider);
    final medidas = BsMedidas.de(context);
    final ancho = MediaQuery.sizeOf(context).width;
    final conRiel = ancho >= AnchosDeNavegacion.riel;
    final conPanel = ancho >= AnchosDeNavegacion.panel;
    final enOperacion = ui is Publicado && voyage.portOfCall != null;
    // Qué modos ofrece la escala: Descarga solo en un plano de llegada
    // (T-75), Carga siempre que haya escala.
    final modos = <BsModoDeOperacion>{
      if (offersDischarge(voyage)) BsModoDeOperacion.descarga,
      BsModoDeOperacion.carga,
    };
    final mode = ref.watch(bayPlanModeProvider);
    final modoDeOperacion = switch (mode) {
      BayPlanMode.discharge => BsModoDeOperacion.descarga,
      BayPlanMode.loading => BsModoDeOperacion.carga,
      _ => null,
    };
    void elegirModo(BsModoDeOperacion modo) =>
        ref.read(bayPlanModeProvider.notifier).elegir(
            modo == BsModoDeOperacion.descarga
                ? BayPlanMode.discharge
                : BayPlanMode.loading);
    void irA(DestinoDelViaje d) {
      if (d == DestinoDelViaje.mas) {
        _abrirMas(voyage, preview: preview, conRiel: conRiel, alertas: alertas);
        return;
      }
      ref.read(destinoDelViajeProvider.notifier).ir(d);
    }

    final buscar = IconButton(
      key: const ValueKey('buscar-contenedor'),
      icon: const Icon(Icons.search),
      tooltip: 'Buscar contenedor',
      onPressed: () => _openSearch(context, voyage),
    );

    final contenido = Column(
      children: [
        const RelojDelNaranja(),
        if (ui is Previo) ...[
          BsBanda(
            key: const ValueKey('preview-banner'),
            texto: ui.texto,
            icono: Icons.info_outline,
            accion: 'Confirmar',
            onAccion: () => _confirmPreview(context),
          ),
          const _SinEvaluar(),
        ],
        Expanded(
          child: switch (destino) {
            DestinoDelViaje.plano ||
            DestinoDelViaje.mas =>
              BayPlanView(voyage: voyage),
            DestinoDelViaje.lista => _buildContainersListTab(context, voyage),
            DestinoDelViaje.avance => voyage.portOfCall == null
                ? BayPlanView(voyage: voyage)
                : OperationProgressBody(
                    voyage: voyage, onCelda: (cell) => _irACelda(cell)),
            DestinoDelViaje.estadisticas => VoyageStatsView(
                voyage: voyage,
                onBaySelected: _openBayPlan,
              ),
          },
        ),
      ],
    );

    if (!conRiel) {
      // El teléfono: la barra inferior y, operando en el muelle, la banda de
      // la marca con Descarga / Carga en vez de la barra superior (13.8).
      final bandaDelMuelle = medidas.esMuelle && enOperacion;
      return Scaffold(
        appBar: bandaDelMuelle
            ? null
            : AppBar(
                title: _TituloDelViaje(voyage: voyage),
                actions: [buscar, const SyncAppBarButton()],
              ),
        body: PanelLateralDisponible(
          disponible: false,
          child: Column(
            children: [
              if (bandaDelMuelle)
                _BandaDelMuelle(
                  voyage: voyage,
                  modo: modoDeOperacion,
                  modos: modos,
                  onModo: elegirModo,
                  acciones: [buscar],
                ),
              Expanded(child: contenido),
            ],
          ),
        ),
        bottomNavigationBar: BarraDelViaje(
          destinos: destinos,
          activo: destino,
          onDestino: irA,
          alertas: alertas,
          alertaCritica: critica,
        ),
      );
    }

    // La oficina: el riel con la marca, la cabecera y, con sitio, el panel.
    return Scaffold(
      body: PanelLateralDisponible(
        disponible: conPanel,
        child: Row(
          children: [
            RielDelViaje(
              destinos: destinos,
              activo: destino,
              onDestino: irA,
              alertas: alertas,
              alertaCritica: critica,
              onAlertas: conPanel ? () => _openAlerts(voyage) : null,
              pie: [const SyncAppBarButton(), parametersButton],
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: Column(
                children: [
                  _CabeceraDeOficina(
                    voyage: voyage,
                    publicado: ui is Publicado,
                    enOperacion: enOperacion,
                    modo: modoDeOperacion,
                    modos: modos,
                    onModo: elegirModo,
                    buscar: buscar,
                  ),
                  Expanded(child: contenido),
                ],
              ),
            ),
            if (conPanel) ...[
              const VerticalDivider(width: 1),
              SizedBox(
                width: medidas.anchoPanelLateral,
                child: _PanelLateral(voyage: voyage, enOperacion: enOperacion),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// «Más» (`DESIGN.md` 8): la hoja con las alertas primero y, después, lo
  /// que antes eran las acciones de la barra. Nube y Parámetros solo aquí
  /// cuando no hay riel que los lleve al pie.
  Future<void> _abrirMas(VesselVoyage voyage,
      {required bool preview,
      required bool conRiel,
      required int alertas}) async {
    final loadedAtCall = voyage.portOfCall == null
        ? 0
        : voyage.cargoCountsFor(voyage.portOfCall).loaded +
            voyage.reservedCountsFor(voyage.portOfCall).loaded;
    final entradas = <_EntradaDeMas>[
      _EntradaDeMas(
        clave: 'mas-alertas',
        icono: Icons.fact_check_outlined,
        titulo: 'Alertas de estiba',
        cuenta: alertas,
        onTap: () => _openAlerts(voyage),
      ),
      if (voyage.portOfCall != null)
        _EntradaDeMas(
          clave: 'mas-tapas',
          icono: Icons.layers_outlined,
          titulo: 'Tapas en la operación',
          onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => HatchOperationPage(voyage: voyage))),
        ),
      if (voyage.geometry != null &&
          DischargeSequence.dischargePorts(voyage).isNotEmpty)
        _EntradaDeMas(
          clave: 'mas-orden',
          icono: Icons.low_priority,
          titulo: 'Orden de descarga',
          onTap: () => _openDischargeSequence(voyage),
        ),
      if (loadedAtCall > 0)
        _EntradaDeMas(
          clave: 'mas-listado',
          icono: Icons.table_view,
          titulo: 'Listado de la agencia',
          onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => const ExportListImportPage())),
        ),
      _EntradaDeMas(
        clave: 'mas-comparar',
        icono: Icons.compare_arrows,
        titulo: 'Comparar con otro BAPLIE…',
        onTap: () => compareWithAnotherBaplie(context, ref, voyage),
      ),
      // Único punto de exportación para PDF, CSV y JSON. En previo, exportar
      // cuenta como operar: la entrada dice que falta confirmar (10.4).
      if (preview)
        _EntradaDeMas(
          clave: 'export-preview',
          icono: Icons.download,
          titulo: 'Exportar viaje',
          subtitulo: 'Primero confirma el perfil y la escala',
          onTap: () => _avisar(context, exportarSinConfirmar),
        )
      else
        for (final format in VoyageExportFormat.values)
          _EntradaDeMas(
            clave: 'export-${format.name}',
            icono: switch (format) {
              VoyageExportFormat.pdf => Icons.picture_as_pdf,
              VoyageExportFormat.csv => Icons.table_view,
              VoyageExportFormat.json => Icons.data_object,
            },
            titulo: 'Exportar ${format.label}',
            onTap: () => _exportVoyage(context, voyage, format),
          ),
      if (!conRiel) ...[
        _EntradaDeMas(
          clave: 'mas-nube',
          icono: Icons.cloud_outlined,
          titulo: 'Nube y cuenta',
          onTap: () => openCloudPage(context),
        ),
        _EntradaDeMas(
          clave: 'edit-geometry',
          icono: Icons.straighten,
          titulo: 'Parámetros',
          onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => ParametersPage(
                  onVesselParameters: () => _askForGeometry(context)))),
        ),
      ],
      _EntradaDeMas(
        clave: 'mas-cargar',
        icono: Icons.upload_file,
        titulo: 'Cargar archivo BAPLIE',
        onTap: () => _loadBaplieFile(context),
      ),
      _EntradaDeMas(
        clave: 'recent-voyages',
        icono: Icons.history,
        titulo: 'Viajes recientes',
        onTap: () => _openRecentVoyages(context),
      ),
      _EntradaDeMas(
        clave: 'saved-profiles',
        icono: Icons.directions_boat_outlined,
        titulo: 'Perfiles guardados',
        onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const VesselProfilesPage())),
      ),
      _EntradaDeMas(
        clave: 'mas-cerrar',
        icono: Icons.close,
        titulo: 'Cerrar el plano',
        subtitulo: preview
            ? 'Descarta el previo sin guardar nada'
            : 'Limpia los datos cargados en este dispositivo',
        onTap: () => _clear(context, preview: preview),
      ),
    ];
    final elegida = await showModalBottomSheet<_EntradaDeMas>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _HojaMas(entradas: entradas),
    );
    if (!mounted || elegida == null) return;
    elegida.onTap();
  }

  /// Desde «Avance», una celda en conflicto lleva al plano, con su modo y su
  /// bahía (T-78).
  void _irACelda(OperationCellLink cell) {
    final bay = IsoCoordinateParser.parse(cell.position).bay;
    ref.read(bayPlanModeProvider.notifier).elegir(
        cell.role == PlanRole.discharge
            ? BayPlanMode.discharge
            : BayPlanMode.loading);
    ref.read(selectedBayProvider.notifier).select(bay);
    ref.read(highlightedContainerProvider.notifier).highlight(
        cell.role == PlanRole.discharge && cell.key.startsWith('C:')
            ? cell.key.substring(2)
            : cell.displayKey);
    ref.read(selectedTypeFilterProvider.notifier).clear();
    ref.read(destinoDelViajeProvider.notifier).ir(DestinoDelViaje.plano);
  }

  void _openDischargeSequence(VesselVoyage voyage) {
    final profile = ref.read(voyageNotifierProvider.notifier).currentProfile;
    final covers =
        profile?.key == (voyage.vesselProfileKey ?? voyage.vessel.profileKey)
            ? profile!.hatchCovers
            : const <int, HatchCoverDeclaration>{};
    Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) =>
            DischargeSequencePage(voyage: voyage, hatchCovers: covers)));
  }

  /// Un aviso corto, con el mismo texto en todas partes.
  void _avisar(BuildContext context, String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(texto),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
    ));
  }

  /// Abre el buscador de contenedores
  void _openSearch(BuildContext context, VesselVoyage voyage) {
    // Limpiar resaltado anterior
    ref.read(highlightedContainerProvider.notifier).clear();

    showSearch<ContainerUnit?>(
      context: context,
      delegate: ContainerSearchDelegate(
        containers: voyage.containers,
        ref: ref,
        onIrAlPlano: () => ref
            .read(destinoDelViajeProvider.notifier)
            .ir(DestinoDelViaje.plano),
      ),
    );
  }

  /// Selecciona una bahía desde el perfil y abre su rejilla en el Plano.
  void _openBayPlan(int bayNumber) {
    ref.read(highlightedContainerProvider.notifier).clear();
    ref.read(selectedBayProvider.notifier).select(bayNumber);
    ref.read(destinoDelViajeProvider.notifier).ir(DestinoDelViaje.plano);
  }

  Future<void> _openAlerts(VesselVoyage voyage) async {
    final position = await Navigator.of(context).push<IsoCoordinate>(
      MaterialPageRoute(builder: (_) => const StowageAlertsPage()),
    );
    if (!mounted || position == null) return;
    ref.read(selectedCarrierProvider.notifier).clear();
    ref.read(selectedTypeFilterProvider.notifier).clear();
    _openBayPlan(position.bay);
    final matches =
        voyage.containers.where((c) => c.stowagePosition == position);
    if (matches.isNotEmpty) {
      ref
          .read(highlightedContainerProvider.notifier)
          .highlight(matches.first.containerId);
    }
  }

  /// Exporta el viaje desde el punto de entrada compartido por todos los formatos.
  Future<void> _exportVoyage(
    BuildContext context,
    VesselVoyage voyage,
    VoyageExportFormat format,
  ) async {
    try {
      Uint8List? pdfBytes;
      if (format == VoyageExportFormat.pdf) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Generando reporte PDF...'),
            duration: Duration(minutes: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Deja que el aviso se dibuje antes de generar el PDF.
        await WidgetsBinding.instance.endOfFrame;
        pdfBytes = await const PdfReportService().generate(
          voyage,
          geometry: voyage.geometry!,
        );
      }

      final path = await const ExportService().saveVoyage(
        voyage,
        format,
        pdfBytes: pdfBytes,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (path == null && !kIsWeb) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exportación ${format.label} completada'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error, stack) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              vesselErrorMessage(error, stack, 'exportar ${format.label}')),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Pregunta antes de perder un previo (DESIGN.md 7.2, punto 5). Devuelve
  /// `true` si se descartó o si no había previo.
  Future<bool> _discardPreviewIfAny(BuildContext context) async {
    final notifier = ref.read(voyageNotifierProvider.notifier);
    if (!notifier.isPreview) return true;
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Descartar el plano sin confirmar?'),
        content: const Text(
            'No se guardó nada. Podrás volver a abrir el archivo cuando quieras.'),
        actions: [
          TextButton(
              key: const ValueKey('preview-keep'),
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Seguir mirando')),
          FilledButton(
              key: const ValueKey('preview-discard'),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Descartar')),
        ],
      ),
    );
    if (discard != true) return false;
    notifier.discardPreview();
    ref.read(highlightedContainerProvider.notifier).clear();
    ref.read(selectedBayProvider.notifier).clear();
    return true;
  }

  /// «Cerrar el plano»: con un previo pregunta; publicado, limpia como siempre.
  Future<void> _clear(BuildContext context, {required bool preview}) async {
    if (preview) {
      await _discardPreviewIfAny(context);
      return;
    }
    ref.read(voyageNotifierProvider.notifier).clearVoyage();
    ref.read(highlightedContainerProvider.notifier).clear();
    ref.read(selectedBayProvider.notifier).clear();
  }

  /// «Viajes recientes» desde la barra; un previo se descarta antes.
  Future<void> _openRecentVoyages(BuildContext context) async {
    if (!await _discardPreviewIfAny(context)) return;
    if (!context.mounted) return;
    final loadFile = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const RecentVoyagesPage()));
    if (context.mounted && loadFile == true) {
      await _loadBaplieFile(context);
    }
  }

  /// Reabre un viaje guardado desde el inicio, sin parser ni archivo.
  Future<void> _openRecent(BuildContext context, VesselVoyage recent) async {
    final notifier = ref.read(voyageNotifierProvider.notifier);
    final error = await notifier.openRecentVoyage(recent.id);
    if (!context.mounted) return;
    if (error != null) {
      _avisar(context, error);
      return;
    }
    final kept = notifier.reopenKeptParameters;
    if (kept.isNotEmpty) {
      // T-61: el perfil vigente no se aplica si oculta carga; se dice cuál.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          key: const ValueKey('reopen-kept-parameters'),
          duration: const Duration(seconds: 10),
          content: Text('No se aplicó del perfil vigente: '
              '${kept.map((p) => p.label).join(', ')}. Dejaría contenedores '
              'de este viaje fuera del plano; se conserva el valor guardado '
              'con el viaje. Revisa el perfil del buque.')));
    }
  }

  /// Carga un archivo BAPLIE usando el VoyageNotifier
  ///
  /// El plano abre en previo con el perfil propuesto o el guardado; la banda
  /// guía la confirmación. Solo con perfil guardado que cubre la carga y la
  /// escala de siempre abre publicado (DESIGN.md 7.2).
  Future<void> _loadBaplieFile(BuildContext context) async {
    if (!await _discardPreviewIfAny(context)) return;
    if (!context.mounted) return;
    final notifier = ref.read(voyageNotifierProvider.notifier);
    final result = await notifier.loadVesselFromFile();

    if (!context.mounted) return;

    // No mostrar nada si el usuario canceló el selector de archivos
    if (result.isCancelled) return;

    // En previo (también con homónimos) la banda dice qué falta.
    if (result.preview || result.needsIdentity) return;

    // Mostrar SnackBar según el resultado
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.success
              ? 'Archivo "${result.fileName}" cargado correctamente'
              : result.errorMessage ?? unexpectedErrorMessage('cargar el archivo'),
        ),
        backgroundColor: result.success ? null : Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// «Confirmar» en la banda del previo: identidad si hay homónimos, plantilla
  /// si el buque es nuevo y los parámetros del buque. Cancelar en cualquier
  /// paso deja el previo como estaba: se sigue mirando, sin operar.
  Future<void> _confirmPreview(BuildContext context) async {
    final notifier = ref.read(voyageNotifierProvider.notifier);
    final fileName = notifier.loadedFileName;
    if (notifier.identityCandidates.isNotEmpty) {
      final candidates = notifier.identityCandidates;
      final selection = await showDialog<int>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirma la identidad del buque'),
          content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                      'Hay perfiles con el mismo nombre. El nombre por sí solo '
                      'no identifica al buque. Selecciona uno solo si corresponde.'),
                  for (var i = 0; i < candidates.length; i++)
                    ListTile(
                      title: Text(candidates[i].vesselName),
                      subtitle: Text(candidates[i].key),
                      onTap: () => Navigator.pop(context, i),
                    ),
                ],
              ))),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar')),
            TextButton(
                onPressed: () => Navigator.pop(context, -1),
                child: const Text('Es otro buque')),
          ],
        ),
      );
      if (!context.mounted || selection == null) return;
      final result = await notifier
          .resolveIdentity(selection < 0 ? null : candidates[selection]);
      if (!context.mounted) return;
      if (!result.success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result.errorMessage ??
              unexpectedErrorMessage('aplicar el perfil del buque')),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ));
        return;
      }
      if (!result.needsGeometry) {
        // El homónimo elegido cubre la carga y la escala es la de siempre.
        _avisar(context, 'Archivo "$fileName" cargado correctamente');
        return;
      }
    }
    if (notifier.canChooseTemplate && !await _chooseTemplate(context)) return;
    if (!context.mounted) return;
    await _askForGeometry(context, fileName: fileName);
  }

  Future<bool> _chooseTemplate(BuildContext context) async {
    final notifier = ref.read(voyageNotifierProvider.notifier);
    try {
      final profiles = await ref.read(savedVesselProfilesProvider.future);
      if (!context.mounted) return false;
      if (profiles.isEmpty) return true;
      final selection = await showDialog<int>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Perfil del buque nuevo'),
          content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                      'Elige un punto de partida. Revisarás sus parámetros antes de guardar.'),
                  ListTile(
                      key: const ValueKey('profile-from-file'),
                      title: const Text('Proponer desde el archivo'),
                      onTap: () => Navigator.pop(context, -1)),
                  for (var i = 0; i < profiles.length; i++)
                    ListTile(
                        key: ValueKey('profile-template-${profiles[i].key}'),
                        title: Text('Plantilla: ${profiles[i].vesselName}'),
                        subtitle: Text(profiles[i].key),
                        onTap: () => Navigator.pop(context, i)),
                ],
              ))),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'))
          ],
        ),
      );
      if (!context.mounted) return false;
      // Cancelar deja el previo como estaba.
      if (selection == null) return false;
      if (selection >= 0) notifier.useTemplate(profiles[selection]);
      return true;
    } catch (error, stack) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(vesselErrorMessage(
                error, stack, 'aplicar la plantilla del buque'))));
      }
      return false;
    }
  }

  /// Abre la pantalla de parámetros del buque con la propuesta deducida.
  ///
  /// Cancelar deja el previo como estaba: nada publicado, el plano a la
  /// vista. Confirmar publica y se queda en el Plano (10.2 a).
  Future<void> _askForGeometry(
    BuildContext context, {
    String? fileName,
  }) async {
    final notifier = ref.read(voyageNotifierProvider.notifier);
    final target = notifier.pendingVoyage ?? notifier.publishedVoyage;
    if (target == null) return;

    final isEditing = notifier.pendingVoyage == null;
    var profile = notifier.currentProfile ?? VesselProfile.proposeFrom(target);
    final proposal =
        VesselProfile.proposeFrom(target, parameters: profile.geometry)
            .geometry;
    var initial =
        isEditing || profile.origin != VesselProfileOrigin.proposedFromFile
            ? profile.geometry
            : null;
    final outside = notifier.outsideProfilePositions;
    if (outside.isNotEmpty) {
      final expand = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('La carga excede el perfil guardado'),
          content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                  child: Text(
                '${outside.length} posiciones fuera del perfil:\n${outside.join(', ')}\n\n'
                'Puedes revisar una ampliación. Solo se guardará al confirmar.',
              ))),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar')),
            FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Revisar ampliación')),
          ],
        ),
      );
      if (!context.mounted) return;
      if (expand != true) return;
      // Solo un borrador después de aceptar revisar; no se modifica el perfil.
      final saved = profile.geometry;
      initial = saved.copyWith(
        portRows: saved.portRows > proposal.portRows
            ? saved.portRows
            : proposal.portRows,
        starboardRows: saved.starboardRows > proposal.starboardRows
            ? saved.starboardRows
            : proposal.starboardRows,
        holdTiers: {...saved.holdTiers, ...proposal.holdTiers}.toList()..sort(),
        deckTiers: {...saved.deckTiers, ...proposal.deckTiers}.toList()..sort(),
      );
    }
    while (context.mounted) {
      final result = await Navigator.of(context).push<VesselCallParameters>(
        MaterialPageRoute(
          builder: (_) => VesselGeometryPage(
            proposal: proposal,
            positions: target.stowagePositions.toList(),
            loadingPorts: target.loadingPortCounts,
            voyage: target,
            lastConfirmedPortOfCall: notifier.lastConfirmedPortOfCall,
            declaredPort: target.portOfOrigin,
            initialPortOfCall: target.portOfCall,
            initial: initial,
            profile: profile,
            fileName: fileName,
            proposedReeferSocketCount: profile.reeferSlotsOrigin ==
                    VesselProfileOrigin.proposedFromFile
                ? profile.reeferSlots.length
                : null,
          ),
        ),
      );

      if (!context.mounted) return;

      // Cancelar deja el árbol como estaba: nada publicado, el previo a la vista.
      if (result == null) return;

      OperationSourceKind? sourceKind;
      if (!isEditing &&
          result.portOfCall != null &&
          OperationSources.baplieKind(target, result.portOfCall!) == null) {
        final counts = target.cargoCountsFor(result.portOfCall);
        final slots = target.reservedCountsFor(result.portOfCall);
        sourceKind = await showDialog<OperationSourceKind>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Tipo de BAPLIE'),
            content: Text('En ${result.portOfCall} hay '
                '${counts.loaded + slots.loaded} cargas y '
                '${counts.discharged + slots.discharged} descargas. '
                'Indica qué plano representa este archivo.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar')),
              TextButton(
                  onPressed: () =>
                      Navigator.pop(context, OperationSourceKind.arrivalBaplie),
                  child: const Text('Llegada')),
              FilledButton(
                  onPressed: () =>
                      Navigator.pop(context, OperationSourceKind.loadingBaplie),
                  child: const Text('Carga')),
            ],
          ),
        );
        if (!context.mounted) return;
        if (sourceKind == null) return;
      }
      final error = await notifier.confirmGeometry(result.geometry,
          sourceKind: sourceKind,
          portOfCall: result.portOfCall,
          hatchCovers: result.hatchCovers,
          observedHoldBayNumbers: result.observedHoldBayNumbers,
          reeferSlots: result.reeferSlots,
          reeferSlotsOrigin: result.reeferSlotsOrigin);
      if (!context.mounted) return;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
        initial = result.geometry;
        profile = profile.copyWith(
            hatchCovers: result.hatchCovers,
            observedHoldBayNumbers: result.observedHoldBayNumbers,
            reeferSlots: result.reeferSlots,
            reeferSlotsOrigin: result.reeferSlotsOrigin);
        continue;
      }

      if (!isEditing) {
        ref.read(destinoDelViajeProvider.notifier).ir(DestinoDelViaje.plano);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Parámetros del buque actualizados'
                : 'Archivo "$fileName" cargado correctamente',
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }
  }

  /// Construye la pestaña de lista de contenedores
  Widget _buildContainersListTab(BuildContext context, VesselVoyage voyage) {
    final carriers = ref.watch(carriersListProvider);
    final selectedCarrier = ref.watch(selectedCarrierProvider);
    final filteredContainers = ref.watch(filteredContainersProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjeta resumen del viaje
          VoyageSummaryCard(voyage: voyage),
          Wrap(
            children: [
              if (voyage.portOfCall != null)
                DepartureBaplieButton(voyage: voyage),
              TextButton.icon(
                icon: const Icon(Icons.fact_check_outlined),
                label: const Text('Alertas de estiba'),
                onPressed: () => _openAlerts(voyage),
              ),
              // T-96: el segundo archivo se lee sin el flujo de carga.
              TextButton.icon(
                key: const ValueKey('compare-baplie'),
                icon: const Icon(Icons.compare_arrows),
                label: const Text('Comparar con otro BAPLIE…'),
                onPressed: () => compareWithAnotherBaplie(context, ref, voyage),
              ),
              // T-95: el orden sugerido, con las tapas del perfil vigente.
              if (voyage.geometry != null &&
                  DischargeSequence.dischargePorts(voyage).isNotEmpty)
                TextButton.icon(
                  key: const ValueKey('open-discharge-sequence'),
                  icon: const Icon(Icons.low_priority),
                  label: const Text('Orden de descarga'),
                  onPressed: () => _openDischargeSequence(voyage),
                ),
              // T-73: el listado de la agencia se cruza con lo que se carga aquí.
              if (voyage.portOfCall != null &&
                  voyage.cargoCountsFor(voyage.portOfCall).loaded +
                          voyage.reservedCountsFor(voyage.portOfCall).loaded >
                      0)
                TextButton.icon(
                  key: const ValueKey('open-export-list'),
                  icon: const Icon(Icons.table_view),
                  label: const Text('Listado de la agencia'),
                  onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                          builder: (_) => const ExportListImportPage())),
                ),
            ],
          ),
          const SizedBox(height: 24),

          if (voyage.reservedSlots.isNotEmpty) ...[
            ReservedSlotsListView(reservedSlots: voyage.reservedSlots),
            const SizedBox(height: 16),
          ],
          // Filtro por naviera
          if (carriers.isNotEmpty) ...[
            Text(
              'Filtrar por Naviera',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Chip "Todas"
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text('Todas (${voyage.totalContainers})'),
                      selected: selectedCarrier == null,
                      onSelected: (_) {
                        ref.read(selectedCarrierProvider.notifier).clear();
                      },
                    ),
                  ),
                  // Chips por naviera
                  ...carriers.map((carrier) {
                    final count = voyage.containers
                        .where((c) => c.operatorCode == carrier)
                        .length;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text('$carrier ($count)'),
                        selected: selectedCarrier == carrier,
                        onSelected: (_) {
                          ref.read(selectedCarrierProvider.notifier).select(
                              selectedCarrier == carrier ? null : carrier);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Título de la lista de contenedores
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Contenedores (${filteredContainers.length})',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              // Chip con estadísticas rápidas
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatChip(
                    context,
                    '${filteredContainers.where((c) => c.status == ContainerStatus.full).length} llenos',
                    Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  _buildStatChip(
                    context,
                    '${filteredContainers.where((c) => c.status == ContainerStatus.empty).length} vacíos',
                    Theme.of(context).colorScheme.secondary,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Lista de contenedores filtrados
          ContainersListView(containers: filteredContainers),
        ],
      ),
    );
  }

  /// Construye un chip con estadísticas
  Widget _buildStatChip(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .labelMedium
            ?.copyWith(color: color, fontWeight: FontWeight.w500),
      ),
    );
  }
}

/// El nombre del buque y, debajo, el viaje y la escala.
class _TituloDelViaje extends StatelessWidget {
  const _TituloDelViaje({required this.voyage});

  final VesselVoyage voyage;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final esquema = Theme.of(context).colorScheme;
    final viaje = <String>[
      'Viaje ${voyageNumberLabel(voyage.voyageNumber)}',
      if (voyage.portOfCall != null) 'Escala ${voyage.portOfCall}',
    ].join(' · ');
    // Sin elipsis: con la letra grande se encoge, como el título de antes.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(voyage.vessel.name, maxLines: 1, style: textos.titleMedium),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(viaje,
              maxLines: 1,
              style: textos.bodySmall?.copyWith(color: esquema.onSurfaceVariant)),
        ),
      ],
    );
  }
}

/// La cabecera de la oficina (`DESIGN.md` 13.8): el buque y el viaje, el
/// estado, Descarga / Carga cuando hay operación, buscar y la nube.
class _CabeceraDeOficina extends StatelessWidget {
  const _CabeceraDeOficina({
    required this.voyage,
    required this.publicado,
    required this.enOperacion,
    required this.modo,
    required this.modos,
    required this.onModo,
    required this.buscar,
  });

  final VesselVoyage voyage;
  final bool publicado;
  final bool enOperacion;
  final BsModoDeOperacion? modo;
  final Set<BsModoDeOperacion> modos;
  final ValueChanged<BsModoDeOperacion> onModo;
  final Widget buscar;

  @override
  Widget build(BuildContext context) {
    final medidas = BsMedidas.de(context);
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    return Container(
      key: const ValueKey('cabecera-de-oficina'),
      constraints: BoxConstraints(minHeight: medidas.alturaBarraSuperior),
      padding: EdgeInsets.symmetric(
          horizontal: medidas.espacioL, vertical: medidas.espacioS),
      child: Row(
        children: [
          Expanded(child: _TituloDelViaje(voyage: voyage)),
          SizedBox(width: medidas.espacioM),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: medidas.espacioS, vertical: medidas.espacioXs),
            decoration: BoxDecoration(
              color: esquema.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(medidas.radioControl),
            ),
            child: Text(publicado ? 'Publicado' : 'Sin confirmar',
                style: textos.labelMedium),
          ),
          if (enOperacion) ...[
            SizedBox(width: medidas.espacioM),
            SegmentedButton<BsModoDeOperacion>(
              key: const ValueKey('operar-segmentos'),
              segments: [
                for (final valor in BsModoDeOperacion.values)
                  if (modos.contains(valor))
                    ButtonSegment<BsModoDeOperacion>(
                      value: valor,
                      label: Text(valor.rotulo),
                      icon: Icon(valor.icono),
                    ),
              ],
              selected: <BsModoDeOperacion>{
                if (modo != null && modos.contains(modo)) modo!,
              },
              emptySelectionAllowed: true,
              showSelectedIcon: false,
              onSelectionChanged: (valores) {
                if (valores.isNotEmpty) onModo(valores.first);
              },
            ),
          ],
          SizedBox(width: medidas.espacioS),
          buscar,
          const SyncAppBarButton(),
        ],
      ),
    );
  }
}

/// La banda de la marca arriba del muelle (`DESIGN.md` 13.6 y 13.8): el
/// buque, el viaje y la escala, el chip de la nube y Descarga / Carga.
class _BandaDelMuelle extends ConsumerWidget {
  const _BandaDelMuelle({
    required this.voyage,
    required this.modo,
    required this.modos,
    required this.onModo,
    required this.acciones,
  });

  final VesselVoyage voyage;
  final BsModoDeOperacion? modo;
  final Set<BsModoDeOperacion> modos;
  final ValueChanged<BsModoDeOperacion> onModo;
  final List<Widget> acciones;

  /// El estado de la nube en una o dos palabras, para el chip de la banda.
  static String nubeCorta(SyncStatus status) => switch (status.state) {
        SyncState.localOnly => 'Solo aquí',
        SyncState.connecting => 'Conectando',
        SyncState.upToDate => status.rejected > 0 ? 'Revisar' : 'Al día',
        SyncState.sending => 'Enviando',
        SyncState.offline => 'Sin conexión',
        SyncState.sessionExpired ||
        SyncState.notAuthorized ||
        SyncState.unconfirmed =>
          'Revisar',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = visibleSyncStatus(ref.watch(syncStatusProvider));
    return BsBandaMuelle(
      key: const ValueKey('banda-del-muelle'),
      buque: voyage.vessel.name,
      viaje: 'Viaje ${voyageNumberLabel(voyage.voyageNumber)} · ${voyage.portOfCall}',
      nube: BsChipDeNube(
        texto: nubeCorta(status),
        alDia: status.state == SyncState.upToDate && status.rejected == 0,
        onTap: () => openCloudPage(context),
      ),
      modo: modo,
      modos: modos,
      mostrarModos: true,
      onModo: onModo,
      acciones: acciones,
    );
  }
}

/// El panel lateral de la oficina (`DESIGN.md` 8 y 13.8): el detalle de la
/// celda elegida y, con una escala, «En vivo».
class _PanelLateral extends ConsumerWidget {
  const _PanelLateral({required this.voyage, required this.enOperacion});

  final VesselVoyage voyage;
  final bool enOperacion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medidas = BsMedidas.de(context);
    final textos = Theme.of(context).textTheme;
    final esquema = Theme.of(context).colorScheme;
    final celda = ref.watch(celdaSeleccionadaProvider);
    return Column(
      key: const ValueKey('panel-lateral'),
      children: [
        Expanded(
          child: celda == null
              ? Padding(
                  padding: EdgeInsets.all(medidas.espacioXl),
                  child: Text(
                    'Toca una celda del plano para ver su detalle aquí.',
                    style: textos.bodyMedium
                        ?.copyWith(color: esquema.onSurfaceVariant),
                  ),
                )
              : DetalleContenedor(
                  voyage: voyage,
                  container: celda,
                  onCerrar: () =>
                      ref.read(celdaSeleccionadaProvider.notifier).limpiar(),
                ),
        ),
        if (enOperacion)
          Padding(
            padding: EdgeInsets.all(medidas.espacioM),
            child: EnVivoDelViaje(voyage: voyage),
          ),
      ],
    );
  }
}

/// Una entrada de la hoja «Más».
class _EntradaDeMas {
  const _EntradaDeMas({
    required this.clave,
    required this.icono,
    required this.titulo,
    required this.onTap,
    this.subtitulo,
    this.cuenta,
  });

  final String clave;
  final IconData icono;
  final String titulo;
  final String? subtitulo;
  final int? cuenta;
  final VoidCallback onTap;
}

/// La hoja «Más» (`DESIGN.md` 8). Devuelve la entrada elegida; la página la
/// ejecuta con la hoja ya cerrada.
class _HojaMas extends StatelessWidget {
  const _HojaMas({required this.entradas});

  final List<_EntradaDeMas> entradas;

  @override
  Widget build(BuildContext context) {
    final medidas = BsMedidas.de(context);
    final semanticos = BsColoresSemanticos.de(context);
    return SingleChildScrollView(
      key: const ValueKey('hoja-mas'),
      padding: EdgeInsets.symmetric(vertical: medidas.espacioS),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final entrada in entradas)
            ListTile(
              key: ValueKey<String>(entrada.clave),
              leading: Icon(entrada.icono),
              title: Text(entrada.titulo),
              subtitle:
                  entrada.subtitulo == null ? null : Text(entrada.subtitulo!),
              trailing: entrada.cuenta == null || entrada.cuenta == 0
                  ? null
                  : Badge(
                      backgroundColor: semanticos.revisar.contorno,
                      textColor: semanticos.revisar.relleno,
                      label: Text('${entrada.cuenta}'),
                    ),
              onTap: () => Navigator.of(context).pop(entrada),
            ),
        ],
      ),
    );
  }
}

/// Leyendo el archivo: un indicador con su nombre.
class _Leyendo extends StatelessWidget {
  const _Leyendo({required this.fileName});

  final String fileName;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Leyendo $fileName…'),
          ],
        ),
      );
}

/// El error con su causa y «Intentar de nuevo».
class _Fallo extends StatelessWidget {
  const _Fallo({required this.mensaje, required this.onRetry});

  final String mensaje;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline,
                  size: 64, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text(
                'Error al procesar archivo',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                mensaje,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Intentar de nuevo'),
              ),
            ],
          ),
        ),
      );
}

/// Lo que el previo no evalúa, con su icono, en todas las pestañas: nunca un
/// hueco ni «sin alertas» (DESIGN.md 7.2, punto 4).
class _SinEvaluar extends StatelessWidget {
  const _SinEvaluar();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final medidas = BsMedidas.de(context);
    return Material(
      key: const ValueKey('preview-sin-evaluar'),
      color: colorScheme.surfaceContainerLow,
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: medidas.espacioL, vertical: medidas.espacioS),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                size: 20, color: colorScheme.onSurfaceVariant),
            SizedBox(width: medidas.espacioS),
            Expanded(
              child: Text(
                sinEvaluarHastaConfirmar,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
