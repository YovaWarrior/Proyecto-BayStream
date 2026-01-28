import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/vessel_providers.dart';
import '../widgets/voyage_summary_card.dart';
import '../widgets/containers_list_view.dart';
import '../widgets/empty_state_widget.dart';

/// Página principal de la aplicación BayStream
/// Permite cargar archivos BAPLIE y visualizar la información del viaje
class VesselOverviewPage extends ConsumerWidget {
  const VesselOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voyageAsync = ref.watch(voyageNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BayStream'),
        centerTitle: true,
        actions: [
          // Botón para cargar archivo BAPLIE
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Cargar archivo BAPLIE',
            onPressed: () => _pickAndParseBaplieFile(context, ref),
          ),
          // Botón para limpiar datos cargados
          if (voyageAsync.hasValue && voyageAsync.value != null)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Limpiar datos',
              onPressed: () => ref.read(voyageNotifierProvider.notifier).clearVoyage(),
            ),
        ],
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
                  onPressed: () => _pickAndParseBaplieFile(context, ref),
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
              onPickFile: () => _pickAndParseBaplieFile(context, ref),
            );
          }

          // Mostrar información del viaje cargado
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tarjeta resumen del viaje
                VoyageSummaryCard(voyage: voyage),
                const SizedBox(height: 24),
                
                // Título de la lista de contenedores
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Contenedores (${voyage.totalContainers})',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    // Chip con estadísticas rápidas
                    Row(
                      children: [
                        _buildStatChip(
                          context,
                          '${voyage.fullContainers} llenos',
                          Colors.green,
                        ),
                        const SizedBox(width: 8),
                        _buildStatChip(
                          context,
                          '${voyage.emptyContainers} vacíos',
                          Colors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Lista de contenedores
                ContainersListView(containers: voyage.containers),
              ],
            ),
          );
        },
      ),
      // Botón flotante para cargar archivo
      floatingActionButton: voyageAsync.maybeWhen(
        data: (voyage) => voyage == null
            ? FloatingActionButton.extended(
                onPressed: () => _pickAndParseBaplieFile(context, ref),
                icon: const Icon(Icons.file_open),
                label: const Text('Cargar BAPLIE'),
              )
            : null,
        orElse: () => null,
      ),
    );
  }

  /// Abre el selector de archivos y parsea el archivo BAPLIE seleccionado
  Future<void> _pickAndParseBaplieFile(BuildContext context, WidgetRef ref) async {
    try {
      // Abrir selector de archivos
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['edi', 'txt', 'baplie'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      
      // Verificar que el archivo tenga contenido
      if (file.bytes == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo leer el contenido del archivo'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Convertir bytes a String y parsear
      final content = String.fromCharCodes(file.bytes!);
      await ref.read(voyageNotifierProvider.notifier).parseBaplieContent(content);

      // Mostrar mensaje de éxito
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Archivo "${file.name}" cargado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
