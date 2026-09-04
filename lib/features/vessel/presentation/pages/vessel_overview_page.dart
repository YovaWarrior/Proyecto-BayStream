import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/export_service.dart';
import '../../data/services/pdf_report_service.dart';
import '../../domain/entities/entities.dart';
import '../providers/vessel_providers.dart';
import '../widgets/voyage_summary_card.dart';
import '../widgets/containers_list_view.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/bay_plan_view.dart';
import '../widgets/container_search_delegate.dart';
import '../widgets/voyage_stats_view.dart';
import 'vessel_geometry_page.dart';

/// Página principal de la aplicación BayStream
/// Permite cargar archivos BAPLIE y visualizar la información del viaje
class VesselOverviewPage extends ConsumerStatefulWidget {
  const VesselOverviewPage({super.key});

  @override
  ConsumerState<VesselOverviewPage> createState() => _VesselOverviewPageState();
}

class _VesselOverviewPageState extends ConsumerState<VesselOverviewPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final voyageAsync = ref.watch(voyageNotifierProvider);
    final hasVoyage = voyageAsync.hasValue && voyageAsync.value != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('BayStream'),
        centerTitle: true,
        actions: [
          // Botón de búsqueda (solo si hay viaje cargado)
          if (hasVoyage)
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Buscar contenedor',
              onPressed: () => _openSearch(context, voyageAsync.value!),
            ),
          // Único punto de exportación para PDF, CSV y JSON
          if (hasVoyage)
            PopupMenuButton<VoyageExportFormat>(
              icon: const Icon(Icons.download),
              tooltip: 'Exportar viaje',
              onSelected: (format) =>
                  _exportVoyage(context, voyageAsync.value!, format),
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
          // Corregir la geometría declarada sin volver a cargar el archivo
          if (hasVoyage)
            IconButton(
              key: const ValueKey('edit-geometry'),
              icon: const Icon(Icons.straighten),
              tooltip: 'Parámetros del buque',
              onPressed: () => _askForGeometry(context),
            ),
          // Botón para cargar archivo BAPLIE
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Cargar archivo BAPLIE',
            onPressed: () => _loadBaplieFile(context),
          ),
          // Botón para limpiar datos cargados
          if (hasVoyage)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Limpiar datos',
              onPressed: () {
                ref.read(voyageNotifierProvider.notifier).clearVoyage();
                ref.read(highlightedContainerProvider.notifier).clear();
                ref.read(selectedBayProvider.notifier).clear();
              },
            ),
        ],
        bottom: hasVoyage
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.list), text: 'Lista'),
                  Tab(icon: Icon(Icons.grid_view), text: 'Bay Plan'),
                  Tab(icon: Icon(Icons.bar_chart), text: 'Estadísticas'),
                ],
              )
            : null,
      ),
      body: voyageAsync.when(
        // Estado: Cargando
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Procesando archivo BAPLIE...'),
            ],
          ),
        ),
        // Estado: Error
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error al procesar archivo',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => _loadBaplieFile(context),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Intentar de nuevo'),
                ),
              ],
            ),
          ),
        ),
        // Estado: Datos cargados o vacío
        data: (voyage) {
          if (voyage == null) {
            return EmptyStateWidget(
              onPickFile: () => _loadBaplieFile(context),
            );
          }

          // Mostrar información del viaje con pestañas
          return TabBarView(
            controller: _tabController,
            children: [
              // Pestaña 1: Lista de contenedores
              _buildContainersListTab(context, voyage),
              
              // Pestaña 2: Bay Plan
              BayPlanView(voyage: voyage),
              
              // Pestaña 3: Estadísticas
              VoyageStatsView(
                voyage: voyage,
                onBaySelected: _openBayPlan,
              ),
            ],
          );
        },
      ),
      // Botón flotante para cargar archivo
      floatingActionButton: voyageAsync.maybeWhen(
        data: (voyage) => voyage == null
            ? FloatingActionButton.extended(
                onPressed: () => _loadBaplieFile(context),
                icon: const Icon(Icons.file_open),
                label: const Text('Cargar BAPLIE'),
              )
            : null,
        orElse: () => null,
      ),
    );
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
    _tabController.animateTo(1);
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
        await Future<void>.delayed(Duration.zero);
        pdfBytes = await const PdfReportService().generate(voyage);
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
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo exportar ${format.label}: $error'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Carga un archivo BAPLIE usando el VoyageNotifier
  ///
  /// El viaje no se publica al parsearlo: primero pasa por la pantalla de
  /// parámetros del buque. El plano nunca se dibuja con geometría inferida.
  Future<void> _loadBaplieFile(BuildContext context) async {
    final notifier = ref.read(voyageNotifierProvider.notifier);
    final result = await notifier.loadVesselFromFile();

    if (!context.mounted) return;

    // No mostrar nada si el usuario canceló el selector de archivos
    if (result.isCancelled) return;

    if (result.needsGeometry) {
      await _askForGeometry(context, fileName: result.fileName);
      return;
    }

    // Mostrar SnackBar según el resultado
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.success
              ? 'Archivo "${result.fileName}" cargado correctamente'
              : result.errorMessage ?? 'Error desconocido',
        ),
        backgroundColor: result.success ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Abre la pantalla de parámetros del buque con la propuesta deducida.
  ///
  /// Si el usuario cancela, el viaje pendiente se descarta: no se publica un
  /// viaje sin geometría confirmada.
  Future<void> _askForGeometry(
    BuildContext context, {
    String? fileName,
  }) async {
    final notifier = ref.read(voyageNotifierProvider.notifier);
    final target = notifier.pendingVoyage ?? notifier.publishedVoyage;
    if (target == null) return;

    final isEditing = notifier.pendingVoyage == null;
    final result = await Navigator.of(context).push<VesselCallParameters>(
      MaterialPageRoute(
        builder: (_) => VesselGeometryPage(
          proposal: VesselGeometry.proposeFrom(target.stowagePositions),
          positions: target.stowagePositions.toList(),
          loadingPorts: target.loadingPortCounts,
          initialPortOfCall: target.portOfCall,
          initial: target.geometry,
          fileName: fileName,
        ),
      ),
    );

    if (!context.mounted) return;

    if (result == null) {
      // Cancelar deja el árbol como estaba: nada publicado, nada pendiente.
      notifier.discardPendingVoyage();
      if (isEditing) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Carga cancelada: no se confirmó la geometría del buque',
          ),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
        ),
      );
      return;
    }

    notifier.confirmGeometry(result.geometry, portOfCall: result.portOfCall);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEditing
              ? 'Parámetros del buque actualizados'
              : 'Archivo "$fileName" cargado correctamente',
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
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
          const SizedBox(height: 24),
          
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Contenedores (${filteredContainers.length})',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              // Chip con estadísticas rápidas
              Row(
                children: [
                  _buildStatChip(
                    context,
                    '${filteredContainers.where((c) => c.status == ContainerStatus.full).length} llenos',
                    Colors.green,
                  ),
                  const SizedBox(width: 8),
                  _buildStatChip(
                    context,
                    '${filteredContainers.where((c) => c.status == ContainerStatus.empty).length} vacíos',
                    Colors.orange,
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }
}
