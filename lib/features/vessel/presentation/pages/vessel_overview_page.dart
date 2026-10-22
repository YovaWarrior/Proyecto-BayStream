import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/design.dart';
import '../../../../core/utils/iso_coordinate_parser.dart';
import '../../data/services/export_service.dart';
import '../../data/services/pdf_report_service.dart';
import '../../domain/entities/entities.dart';
import '../../domain/services/discharge_sequence.dart';
import '../../domain/services/operation_sources.dart';
import '../providers/vessel_providers.dart';
import '../providers/plan_toolbar_provider.dart';
import '../providers/voyage_ui_state.dart';
import '../formatters/vessel_error_message.dart';
import '../widgets/voyage_summary_card.dart';
import '../widgets/reserved_slots_list_view.dart';
import '../widgets/containers_list_view.dart';
import '../widgets/inicio_view.dart';
import '../widgets/bay_plan_view.dart';
import '../widgets/container_search_delegate.dart';
import '../widgets/voyage_stats_view.dart';
import '../widgets/sync_status_chip.dart';
import 'export_list_import_page.dart';
import 'departure_baplie_page.dart';
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
class VesselOverviewPage extends ConsumerStatefulWidget {
  const VesselOverviewPage({super.key});

  @override
  ConsumerState<VesselOverviewPage> createState() => _VesselOverviewPageState();
}

class _VesselOverviewPageState extends ConsumerState<VesselOverviewPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  /// La pestaña del plano es la primera que se ve con un viaje (10.2 a):
  /// la primera visualización termina en la rejilla, sin un paso más.
  static const int _planoTab = 1;
  bool _isBayPlan = true;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 3, vsync: this, initialIndex: _planoTab);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    final isBayPlan = _tabController.index == _planoTab;
    if (_isBayPlan != isBayPlan) {
      setState(() => _isBayPlan = isBayPlan);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ui = ref.watch(voyageUiStateProvider);
    final voyage = switch (ui) {
      Previo(:final voyage) => voyage,
      Publicado(:final voyage) => voyage,
      _ => null,
    };
    final hasVoyage = voyage != null;
    final preview = ui is Previo;
    final showToolbarToggle = hasVoyage && _isBayPlan;
    final toolbarCollapsed = showToolbarToggle &&
        (ref.watch(planToolbarCollapsedProvider).value ?? true);
    final tabLabelStyle = Theme.of(context).textTheme.titleSmall!;
    final tabHeight = 42 + MediaQuery.textScalerOf(context)
        .scale(tabLabelStyle.fontSize ?? 14) * (tabLabelStyle.height ?? 1.5);

    final parametersButton = IconButton(
      key: const ValueKey('edit-geometry'),
      icon: const Icon(Icons.straighten),
      tooltip: 'Parámetros',
      onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => ParametersPage(
          onVesselParameters:
              hasVoyage ? () => _askForGeometry(context) : null,
        ),
      )),
    );

    final toolbarActions = <Widget>[
      IconButton(
          key: const ValueKey('recent-voyages'),
          icon: const Icon(Icons.history),
          tooltip: 'Viajes recientes',
          onPressed: () => _openRecentVoyages(context)),
      IconButton(
          key: const ValueKey('saved-profiles'),
          icon: const Icon(Icons.directions_boat_outlined),
          tooltip: 'Perfiles guardados',
          onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                  builder: (_) => const VesselProfilesPage()))),
      // T-79: cuenta, publicar y unirse; su icono dice el estado de envío.
      const SyncAppBarButton(),
      // Botón de búsqueda (solo si hay viaje cargado)
      if (hasVoyage)
        IconButton(
          icon: const Icon(Icons.search),
          tooltip: 'Buscar contenedor',
          onPressed: () => _openSearch(context, voyage),
        ),
      // Único punto de exportación para PDF, CSV y JSON. En previo, exportar
      // cuenta como operar: el botón dice que falta confirmar (10.4).
      if (hasVoyage && preview)
        IconButton(
          key: const ValueKey('export-preview'),
          icon: const Icon(Icons.download),
          tooltip: 'Exportar viaje',
          onPressed: () => _avisar(context, exportarSinConfirmar),
        )
      else if (hasVoyage)
        PopupMenuButton<VoyageExportFormat>(
          icon: const Icon(Icons.download),
          tooltip: 'Exportar viaje',
          onSelected: (format) => _exportVoyage(context, voyage, format),
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: VoyageExportFormat.pdf,
              child: ListTile(
                leading: Icon(Icons.picture_as_pdf),
                title: Text('PDF'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: VoyageExportFormat.csv,
              child: ListTile(
                leading: Icon(Icons.table_view),
                title: Text('CSV'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: VoyageExportFormat.json,
              child: ListTile(
                leading: Icon(Icons.data_object),
                title: Text('JSON'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      // T-90: tema del dispositivo y acceso a la geometría del viaje vigente.
      parametersButton,
      // Botón para cargar archivo BAPLIE
      IconButton(
        icon: const Icon(Icons.upload_file),
        tooltip: 'Cargar archivo BAPLIE',
        onPressed: () => _loadBaplieFile(context),
      ),
      // Botón para limpiar datos cargados. En previo pregunta antes.
      if (hasVoyage)
        IconButton(
          icon: const Icon(Icons.clear),
          tooltip: 'Limpiar datos',
          onPressed: () => _clear(context, preview: preview),
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !toolbarCollapsed,
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('BayStream', maxLines: 2),
        ),
        centerTitle: true,
        actions: [
          // El inicio solo lleva Parámetros y Nube (DESIGN.md 9.1): la
          // carga, los recientes y los perfiles están en el cuerpo.
          if (!hasVoyage) parametersButton,
          if (!hasVoyage) const SyncAppBarButton(),
          if (hasVoyage && !toolbarCollapsed)
              // T-97: reserva espacio visible para el título. T-91 conserva
              // su tira desplazable y el botón fijo con un toque.
              SizedBox(
                key: const ValueKey('plan-toolbar-actions'),
                width: (MediaQuery.sizeOf(context).width - (showToolbarToggle ? 160 : 112) -
                        (showToolbarToggle ? 48 : 0) -
                        (Navigator.of(context).canPop() ? 56 : 0))
                    .clamp(0.0, toolbarActions.length * 48.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(mainAxisSize: MainAxisSize.min, children: toolbarActions),
                ),
              ),
          if (showToolbarToggle)
            IconButton(
              key: const ValueKey('toggle-plan-toolbar'),
              tooltip: toolbarCollapsed ? 'Desplegar acciones' : 'Plegar acciones',
              icon: Icon(toolbarCollapsed ? Icons.expand_more : Icons.expand_less),
              onPressed: () async {
                try {
                  await ref.read(planToolbarCollapsedProvider.notifier).toggle();
                } catch (error, stack) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(vesselErrorMessage(
                        error, stack, 'guardar la preferencia de la barra')),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ));
                }
              },
            ),
        ],
        bottom: hasVoyage
            ? TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelStyle: tabLabelStyle,
                tabs: [
                  Tab(height: tabHeight, icon: const Icon(Icons.list), text: 'Lista'),
                  Tab(height: tabHeight, icon: const Icon(Icons.grid_view), text: 'Plano'),
                  Tab(height: tabHeight, icon: const Icon(Icons.bar_chart), text: 'Estadísticas'),
                ],
              )
            : null,
      ),
      body: switch (ui) {
        Leyendo(:final fileName) => _Leyendo(fileName: fileName),
        Fallo(:final mensaje) => _Fallo(
            mensaje: mensaje,
            onRetry: () => _loadBaplieFile(context),
          ),
        SinViaje() => InicioView(
            onPickFile: () => _loadBaplieFile(context),
            onOpenRecent: (recent) => _openRecent(context, recent),
          ),
        Previo() || Publicado() => Column(
            children: [
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
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Pestaña 1: Lista de contenedores
                    _buildContainersListTab(context, voyage!),

                    // Pestaña 2: Bay Plan
                    BayPlanView(voyage: voyage),

                    // Pestaña 3: Estadísticas
                    VoyageStatsView(
                      voyage: voyage,
                      onBaySelected: _openBayPlan,
                    ),
                  ],
                ),
              ),
            ],
          ),
      },
    );
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
        tabController: _tabController,
      ),
    );
  }

  /// Selecciona una bahía desde el perfil y abre su rejilla en Bay Plan.
  void _openBayPlan(int bayNumber) {
    ref.read(highlightedContainerProvider.notifier).clear();
    ref.read(selectedBayProvider.notifier).select(bayNumber);
    _tabController.animateTo(_planoTab);
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

  /// «Limpiar datos»: con un previo pregunta; publicado, limpia como siempre.
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

      if (!isEditing) _tabController.animateTo(_planoTab);
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
                  onPressed: () {
                    final profile =
                        ref.read(voyageNotifierProvider.notifier).currentProfile;
                    final covers = profile?.key ==
                            (voyage.vesselProfileKey ?? voyage.vessel.profileKey)
                        ? profile!.hatchCovers
                        : const <int, HatchCoverDeclaration>{};
                    Navigator.of(context).push(MaterialPageRoute<void>(
                        builder: (_) => DischargeSequencePage(
                            voyage: voyage, hatchCovers: covers)));
                  },
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
