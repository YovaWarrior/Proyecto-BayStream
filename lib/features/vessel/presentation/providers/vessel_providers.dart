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

  /// El archivo se parseó pero el viaje quedó pendiente de que el usuario
  /// confirme la geometría del buque. Todavía no hay nada publicado.
  final bool needsGeometry;

  const LoadFileResult._({
    required this.success,
    this.fileName,
    this.errorMessage,
    this.needsGeometry = false,
  });

  factory LoadFileResult.success(String fileName) =>
      LoadFileResult._(success: true, fileName: fileName);

  factory LoadFileResult.needsGeometry(String fileName) =>
      LoadFileResult._(success: true, fileName: fileName, needsGeometry: true);

  factory LoadFileResult.error(String message) =>
      LoadFileResult._(success: false, errorMessage: message);

  factory LoadFileResult.cancelled() =>
      const LoadFileResult._(success: false);

  bool get isCancelled => !success && errorMessage == null;
}

/// Notifier para manejar operaciones de viajes (Riverpod 3.x)
class VoyageNotifier extends Notifier<AsyncValue<VesselVoyage?>> {
  /// Viaje parseado que todavía no se publica porque falta confirmar la
  /// geometría del buque.
  ///
  /// Sostiene el invariante de C-3: **un viaje publicado siempre trae
  /// geometría**. El único lugar que lo rompe o lo mantiene es este notifier.
  VesselVoyage? _pendingVoyage;

  /// Viaje a la espera de que se confirmen los parámetros del buque.
  VesselVoyage? get pendingVoyage => _pendingVoyage;

  /// Viaje publicado, o `null` si no hay ninguno.
  VesselVoyage? get publishedVoyage => state.hasValue ? state.value : null;

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

      // Si el usuario cancela los parámetros, se vuelve a lo que había antes:
      // una carga a medias no debe borrar el viaje que ya estaba en pantalla.
      final previousState = state;

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
          // El viaje NO se publica todavía: primero se confirma la geometría.
          _pendingVoyage = voyage;
          state = previousState;
          return LoadFileResult.needsGeometry(file.name);
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

  /// Publica el viaje con la geometría que el usuario confirmó.
  ///
  /// Sirve para el viaje pendiente y también para corregir la geometría de uno
  /// ya publicado. Es el único punto donde un viaje pasa a estado publicado.
  void confirmGeometry(VesselGeometry geometry) {
    final target = _pendingVoyage ?? publishedVoyage;
    if (target == null) return;
    _pendingVoyage = null;
    state = AsyncValue.data(target.withGeometry(geometry));
  }

  /// Descarta el viaje pendiente cuando el usuario cancela los parámetros.
  void discardPendingVoyage() {
    _pendingVoyage = null;
  }

  /// Limpia el viaje cargado
  void clearVoyage() {
    _pendingVoyage = null;
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

/// Tipos visuales seleccionables desde la leyenda del Bay Plan
enum LegendFilterType { full, empty, imo, reefer, oog }

/// Provider para el filtro visual activo desde la leyenda interactiva (RF-011)
final selectedTypeFilterProvider =
    NotifierProvider<SelectedTypeFilterNotifier, LegendFilterType?>(
  SelectedTypeFilterNotifier.new,
);

/// Notifier que permite alternar el filtro visual del Bay Plan
class SelectedTypeFilterNotifier extends Notifier<LegendFilterType?> {
  @override
  LegendFilterType? build() => null;

  /// Selecciona el tipo; si ya estaba activo, lo limpia (toggle).
  void toggle(LegendFilterType type) {
    state = state == type ? null : type;
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

/// Provider para distribución de contenedores por naviera (operatorCode -> count)
final carrierDistributionProvider = Provider<Map<String, int>>((ref) {
  final voyageAsync = ref.watch(voyageNotifierProvider);
  return voyageAsync.maybeWhen(
    data: (voyage) {
      if (voyage == null) return {};
      final dist = <String, int>{};
      for (final c in voyage.containers) {
        final key = c.operatorCode ?? 'SIN NAVIERA';
        dist[key] = (dist[key] ?? 0) + 1;
      }
      // Ordenar por cantidad descendente
      final sorted = dist.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      return Map.fromEntries(sorted);
    },
    orElse: () => {},
  );
});

/// Provider para distribución por puerto de descarga (port -> count)
final portDistributionProvider = Provider<Map<String, int>>((ref) {
  final voyageAsync = ref.watch(voyageNotifierProvider);
  return voyageAsync.maybeWhen(
    data: (voyage) {
      if (voyage == null) return {};
      final dist = <String, int>{};
      for (final c in voyage.containers) {
        final key = c.portOfDischarge ?? 'N/A';
        dist[key] = (dist[key] ?? 0) + 1;
      }
      final sorted = dist.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      return Map.fromEntries(sorted);
    },
    orElse: () => {},
  );
});

/// Provider para conteo de carga especial
final specialCargoStatsProvider = Provider<SpecialCargoStats>((ref) {
  final voyageAsync = ref.watch(voyageNotifierProvider);
  return voyageAsync.maybeWhen(
    data: (voyage) {
      if (voyage == null) return const SpecialCargoStats();
      int reefers = 0, dangerous = 0, oog = 0, twentyFt = 0, fortyFt = 0, fortyFiveFt = 0;
      for (final c in voyage.containers) {
        if (c.isReefer) reefers++;
        if (c.isDangerous) dangerous++;
        if (c.isOverDimension) oog++;
        final size = c.sizeInFeet;
        if (size == 20) twentyFt++;
        else if (size == 40) fortyFt++;
        else if (size == 45) fortyFiveFt++;
      }
      return SpecialCargoStats(
        reeferCount: reefers,
        dangerousCount: dangerous,
        oogCount: oog,
        twentyFtCount: twentyFt,
        fortyFtCount: fortyFt,
        fortyFiveFtCount: fortyFiveFt,
      );
    },
    orElse: () => const SpecialCargoStats(),
  );
});

/// Provider para estadísticas por bahía (bayNumber -> {containers, weight})
final bayStatsProvider = Provider<List<BayStat>>((ref) {
  final voyageAsync = ref.watch(voyageNotifierProvider);
  return voyageAsync.maybeWhen(
    data: (voyage) {
      if (voyage == null) return [];
      final stats = <BayStat>[];
      final sortedKeys = voyage.bays.keys.toList()..sort();
      for (final bayNum in sortedKeys) {
        final bay = voyage.bays[bayNum]!;
        stats.add(BayStat(
          bayNumber: bayNum,
          containerCount: bay.containers.length,
          totalWeight: bay.totalWeight,
        ));
      }
      return stats;
    },
    orElse: () => [],
  );
});

/// Estadísticas de carga especial
class SpecialCargoStats {
  final int reeferCount;
  final int dangerousCount;
  final int oogCount;
  final int twentyFtCount;
  final int fortyFtCount;
  final int fortyFiveFtCount;

  const SpecialCargoStats({
    this.reeferCount = 0,
    this.dangerousCount = 0,
    this.oogCount = 0,
    this.twentyFtCount = 0,
    this.fortyFtCount = 0,
    this.fortyFiveFtCount = 0,
  });
}

/// Estadísticas de una bahía individual
class BayStat {
  final int bayNumber;
  final int containerCount;
  final double totalWeight;

  const BayStat({
    required this.bayNumber,
    required this.containerCount,
    required this.totalWeight,
  });
}
