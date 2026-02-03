import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/vessel_repository_impl.dart';
import '../../data/services/baplie_parser_service.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/vessel_repository.dart';

/// Provider del servicio de parsing BAPLIE
final baplieParserServiceProvider = Provider<BaplieParserService>((ref) {
  return BaplieParserService();
});

/// Provider del repositorio de buques
final vesselRepositoryProvider = Provider<VesselRepository>((ref) {
  final parserService = ref.watch(baplieParserServiceProvider);
  return VesselRepositoryImpl(parserService: parserService);
});

/// Provider del viaje actual - maneja estado async manualmente
final voyageNotifierProvider = NotifierProvider<VoyageNotifier, AsyncValue<VesselVoyage?>>(
  VoyageNotifier.new,
);

/// Resultado de la operación de carga de archivo
class LoadFileResult {
  final bool success;
  final String? fileName;
  final String? errorMessage;

  const LoadFileResult._({
    required this.success,
    this.fileName,
    this.errorMessage,
  });

  factory LoadFileResult.success(String fileName) => 
      LoadFileResult._(success: true, fileName: fileName);
  
  factory LoadFileResult.error(String message) => 
      LoadFileResult._(success: false, errorMessage: message);
  
  factory LoadFileResult.cancelled() => 
      const LoadFileResult._(success: false);

  bool get isCancelled => !success && errorMessage == null;
}

/// Notifier para manejar operaciones de viajes (Riverpod 3.x)
class VoyageNotifier extends Notifier<AsyncValue<VesselVoyage?>> {
  @override
  AsyncValue<VesselVoyage?> build() {
    return const AsyncValue.data(null);
  }

  /// Abre el selector de archivos, lee el contenido y parsea el BAPLIE
  /// Retorna un resultado indicando éxito, error o cancelación
  Future<LoadFileResult> loadVesselFromFile() async {
    try {
      // Abrir selector de archivos nativo
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['edi', 'txt', 'baplie'],
        withData: true,
        dialogTitle: 'Seleccionar archivo BAPLIE',
      );

      // Usuario canceló la selección
      if (result == null || result.files.isEmpty) {
        return LoadFileResult.cancelled();
      }

      final file = result.files.first;
      
      // Verificar que el archivo tenga contenido
      if (file.bytes == null || file.bytes!.isEmpty) {
        return LoadFileResult.error('No se pudo leer el contenido del archivo');
      }

      // Poner estado en loading
      state = const AsyncValue.loading();

      // Convertir bytes a String
      final content = String.fromCharCodes(file.bytes!);
      
      // Parsear el contenido
      final repository = ref.read(vesselRepositoryProvider);
      final parseResult = await repository.parseBaplieFile(content);
      
      return parseResult.fold(
        (failure) {
          state = AsyncValue.error(failure.message, StackTrace.current);
          return LoadFileResult.error(failure.message);
        },
        (voyage) {
          state = AsyncValue.data(voyage);
          return LoadFileResult.success(file.name);
        },
      );
    } catch (e) {
      final errorMsg = 'Error inesperado: ${e.toString()}';
      state = AsyncValue.error(errorMsg, StackTrace.current);
      return LoadFileResult.error(errorMsg);
    }
  }

  /// Parsea contenido BAPLIE directamente (para uso con contenido ya leído)
  Future<void> parseBaplieContent(String content) async {
    state = const AsyncValue.loading();
    
    final repository = ref.read(vesselRepositoryProvider);
    final result = await repository.parseBaplieFile(content);
    
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (voyage) => state = AsyncValue.data(voyage),
    );
  }

  /// Limpia el viaje cargado
  void clearVoyage() {
    state = const AsyncValue.data(null);
  }
}

/// Provider para obtener contenedores de una bahía específica
final containersInBayProvider = Provider.family<List<ContainerUnit>, int>((ref, bayNumber) {
  final voyageAsync = ref.watch(voyageNotifierProvider);
  
  return voyageAsync.maybeWhen(
    data: (voyage) {
      if (voyage == null) return [];
      return voyage.getContainersInBay(bayNumber);
    },
    orElse: () => [],
  );
});

/// Provider para el filtro de naviera seleccionada
final selectedCarrierProvider = NotifierProvider<SelectedCarrierNotifier, String?>(
  SelectedCarrierNotifier.new,
);

/// Notifier para la naviera seleccionada
class SelectedCarrierNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? carrier) {
    state = carrier;
  }

  void clear() {
    state = null;
  }
}

/// Provider para obtener lista de navieras únicas del viaje
final carriersListProvider = Provider<List<String>>((ref) {
  final voyageAsync = ref.watch(voyageNotifierProvider);
  
  return voyageAsync.maybeWhen(
    data: (voyage) {
      if (voyage == null) return [];
      final carriers = voyage.containers
          .map((c) => c.operatorCode)
          .where((code) => code != null && code.isNotEmpty)
          .cast<String>()
          .toSet()
          .toList();
      carriers.sort();
      return carriers;
    },
    orElse: () => [],
  );
});

/// Provider para contenedores filtrados por naviera
final filteredContainersProvider = Provider<List<ContainerUnit>>((ref) {
  final voyageAsync = ref.watch(voyageNotifierProvider);
  final selectedCarrier = ref.watch(selectedCarrierProvider);
  
  return voyageAsync.maybeWhen(
    data: (voyage) {
      if (voyage == null) return [];
      if (selectedCarrier == null) return voyage.containers;
      return voyage.containers
          .where((c) => c.operatorCode == selectedCarrier)
          .toList();
    },
    orElse: () => [],
  );
});

/// Provider para estadísticas del viaje actual
final voyageStatsProvider = Provider<VoyageStats?>((ref) {
  final voyageAsync = ref.watch(voyageNotifierProvider);
  
  return voyageAsync.maybeWhen(
    data: (voyage) {
      if (voyage == null) return null;
      return VoyageStats(
        totalContainers: voyage.totalContainers,
        fullContainers: voyage.fullContainers,
        emptyContainers: voyage.emptyContainers,
        totalGrossWeight: voyage.totalGrossWeight,
        totalVgmWeight: voyage.totalVgmWeight,
        totalBays: voyage.bays.length,
      );
    },
    orElse: () => null,
  );
});

/// Provider para el contenedor resaltado (búsqueda)
final highlightedContainerProvider = NotifierProvider<HighlightedContainerNotifier, String?>(
  HighlightedContainerNotifier.new,
);

/// Notifier para el contenedor resaltado
class HighlightedContainerNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void highlight(String containerId) {
    state = containerId;
  }

  void clear() {
    state = null;
  }
}

/// Provider para la bahía seleccionada en el Bay Plan
final selectedBayProvider = NotifierProvider<SelectedBayNotifier, int?>(
  SelectedBayNotifier.new,
);

/// Notifier para la bahía seleccionada
class SelectedBayNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void select(int bayNumber) {
    state = bayNumber;
  }

  void clear() {
    state = null;
  }
}

/// Clase para estadísticas del viaje
class VoyageStats {
  final int totalContainers;
  final int fullContainers;
  final int emptyContainers;
  final double totalGrossWeight;
  final double totalVgmWeight;
  final int totalBays;

  const VoyageStats({
    required this.totalContainers,
    required this.fullContainers,
    required this.emptyContainers,
    required this.totalGrossWeight,
    required this.totalVgmWeight,
    required this.totalBays,
  });

  double get occupancyRate => totalContainers > 0 
      ? (fullContainers / totalContainers) * 100 
      : 0;
}
