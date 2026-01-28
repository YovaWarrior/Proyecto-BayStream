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

/// Provider del viaje actualmente cargado
final currentVoyageProvider = StateProvider<VesselVoyage?>((ref) => null);

/// Provider de estado de carga
final isLoadingProvider = StateProvider<bool>((ref) => false);

/// Provider de errores
final errorMessageProvider = StateProvider<String?>((ref) => null);

/// Notifier para manejar operaciones de viajes
class VoyageNotifier extends StateNotifier<AsyncValue<VesselVoyage?>> {
  final VesselRepository _repository;

  VoyageNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> parseBaplieContent(String content) async {
    state = const AsyncValue.loading();
    
    final result = await _repository.parseBaplieFile(content);
    
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (voyage) => state = AsyncValue.data(voyage),
    );
  }

  void clearVoyage() {
    state = const AsyncValue.data(null);
  }
}

/// Provider del notifier de viajes
final voyageNotifierProvider = 
    StateNotifierProvider<VoyageNotifier, AsyncValue<VesselVoyage?>>((ref) {
  final repository = ref.watch(vesselRepositoryProvider);
  return VoyageNotifier(repository);
});

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
final selectedCarrierProvider = StateProvider<String?>((ref) => null);

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
