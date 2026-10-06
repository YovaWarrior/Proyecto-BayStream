import 'dart:async';

import 'package:file_picker/file_picker.dart';
import '../formatters/vessel_error_message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/vessel_repository_impl.dart';
import '../../data/services/baplie_parser_service.dart';
import '../../domain/entities/entities.dart';
import '../../domain/services/current_profile_parameters.dart';
import '../../domain/repositories/vessel_repository.dart';
import '../../domain/repositories/local_vessel_repository.dart';
import '../../data/repositories/local_vessel_repository_factory.dart';

/// Una instancia compartida por la aplicación. La presentación usa el contrato.
final localVesselRepositoryProvider =
    FutureProvider<LocalVesselRepository>((ref) async {
  var disposed = false;
  LocalVesselRepository? repository;
  ref.onDispose(() {
    disposed = true;
    if (repository != null) unawaited(repository.close());
  });
  repository = await openLocalVesselRepository();
  if (disposed) await repository.close();
  return repository;
});

final savedVesselProfilesProvider =
    FutureProvider<List<VesselProfile>>((ref) async {
  final local = await ref.watch(localVesselRepositoryProvider.future);
  return (await local.getAllProfiles()).fold(
      (failure) => throw VesselOperationFailure(failure),
      (profiles) => profiles);
});

final recentVoyagesProvider = FutureProvider<List<VesselVoyage>>((ref) async {
  final local = await ref.watch(localVesselRepositoryProvider.future);
  return (await local.getAllVoyages()).fold(
      (failure) => throw VesselOperationFailure(failure), (voyages) => voyages);
});

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
final voyageNotifierProvider =
    NotifierProvider<VoyageNotifier, AsyncValue<VesselVoyage?>>(
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
  final bool needsIdentity;

  const LoadFileResult._({
    required this.success,
    this.fileName,
    this.errorMessage,
    this.needsGeometry = false,
    this.needsIdentity = false,
  });

  factory LoadFileResult.success(String fileName) =>
      LoadFileResult._(success: true, fileName: fileName);

  factory LoadFileResult.needsGeometry(String fileName) =>
      LoadFileResult._(success: true, fileName: fileName, needsGeometry: true);

  factory LoadFileResult.needsIdentity(String fileName) =>
      LoadFileResult._(success: true, fileName: fileName, needsIdentity: true);

  factory LoadFileResult.error(String message) =>
      LoadFileResult._(success: false, errorMessage: message);

  factory LoadFileResult.cancelled() => const LoadFileResult._(success: false);

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
  VesselProfile? _pendingProfile;
  VesselProfile? _publishedProfile;
  List<VesselProfile> _identityCandidates = const [];
  bool _nameMatchConfirmed = false;
  bool _newProfile = false;
  bool _busy = false;
  String _fileName = 'BAPLIE';

  VesselProfile? get currentProfile => _pendingProfile ?? _publishedProfile;

  /// Perfil de la instantánea visible, nunca el borrador de otro buque.
  VesselProfile? get publishedProfile => _publishedProfile;

  /// Parámetros del perfil vigente que no se aplicaron al reabrir el viaje
  /// visible porque dejarían carga fuera del plano (T-61).
  List<VesselParameter> get reopenKeptParameters => _reopenKeptParameters;
  List<VesselParameter> _reopenKeptParameters = const [];
  bool get canChooseTemplate =>
      _pendingVoyage != null && _newProfile && _identityCandidates.isEmpty;

  /// Elegir una plantilla solo cambia el borrador del buque pendiente.
  void useTemplate(VesselProfile source) {
    if (!canChooseTemplate || _busy) {
      throw const VesselActionRequired(
          'No hay un buque nuevo confirmado para usar la plantilla. '
          'Confirma primero el buque o inicia otra carga.');
    }
    _pendingProfile = source.cloneFor(_pendingVoyage!.vessel);
  }

  List<VesselProfile> get identityCandidates =>
      List.unmodifiable(_identityCandidates);
  List<String> get outsideProfilePositions {
    final voyage = _pendingVoyage;
    final profile = _pendingProfile;
    if (voyage == null || profile == null) return const [];
    return voyage.stowagePositions
        .where((p) => !profile.geometry.covers(p))
        .map((p) => p.rawCode)
        .toSet()
        .toList()
      ..sort();
  }

  /// Viaje a la espera de que se confirmen los parámetros del buque.
  VesselVoyage? get pendingVoyage => _pendingVoyage;

  /// Viaje publicado, o `null` si no hay ninguno.
  VesselVoyage? get publishedVoyage => state.hasValue ? state.value : null;

  @override
  AsyncValue<VesselVoyage?> build() {
    return const AsyncValue.data(null);
  }

  /// Una publicación también puede cambiar solo las tomas o su origen,
  /// guardados en publishedProfile y no en la igualdad de VesselVoyage.
  /// Riverpod 3 compara por ==: notificar cada nueva instantánea publicada
  /// evita conservar validaciones calculadas con el perfil anterior.
  @override
  bool updateShouldNotify(
          AsyncValue<VesselVoyage?> previous, AsyncValue<VesselVoyage?> next) =>
      !identical(previous, next);

  /// Abre el selector de archivos, lee el contenido y parsea el BAPLIE
  /// Retorna un resultado indicando éxito, error o cancelación
  Future<LoadFileResult> loadVesselFromFile() async {
    if (_busy || _pendingVoyage != null) {
      return LoadFileResult.error(
          'Ya hay una carga en curso. Termínala o cancélala antes de abrir otra.');
    }
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
        return LoadFileResult.error(
            'El archivo está vacío o no se pudo leer. Selecciona otra exportación BAPLIE.');
      }

      return parseBaplieContent(String.fromCharCodes(file.bytes!),
          fileName: file.name);
    } catch (e, stack) {
      return LoadFileResult.error(vesselErrorMessage(e, stack));
    }
  }

  /// Ambas entradas pasan por identidad/perfil antes de publicar el viaje.
  Future<LoadFileResult> parseBaplieContent(
    String content, {
    String fileName = 'BAPLIE',
  }) async {
    if (_busy || _pendingVoyage != null) {
      return LoadFileResult.error(
          'Ya hay una carga en curso. Termínala o cancélala antes de abrir otra.');
    }
    _busy = true;
    final previousState = state;
    state = const AsyncValue.loading();
    try {
      final result =
          await ref.read(vesselRepositoryProvider).parseBaplieFile(content);
      final voyage = result.fold(
          (failure) => throw VesselOperationFailure(failure), (v) => v);
      final local = await ref.read(localVesselRepositoryProvider.future);
      final lookupResult = await local.findProfileFor(voyage.vessel);
      final lookup = lookupResult.fold(
          (failure) => throw VesselOperationFailure(failure), (v) => v);
      _pendingVoyage = voyage;
      _fileName = fileName;
      _nameMatchConfirmed = false;
      _identityCandidates = lookup.nameCandidates;
      state = previousState;
      if (lookup.requiresConfirmation) {
        return LoadFileResult.needsIdentity(fileName);
      }
      return await _useProfile(lookup.automaticMatch);
    } catch (error, stack) {
      _clearPending();
      state = previousState;
      return LoadFileResult.error(vesselErrorMessage(error, stack));
    } finally {
      _busy = false;
    }
  }

  /// Una coincidencia de nombre se resuelve solo por una elección explícita.
  Future<LoadFileResult> resolveIdentity(VesselProfile? selected) async {
    if (_busy) {
      return LoadFileResult.error(
          'Hay una operación en curso. Espera a que termine e inténtalo de nuevo.');
    }
    final voyage = _pendingVoyage;
    if (voyage == null || _identityCandidates.isEmpty) {
      return LoadFileResult.error(
          'No hay una identidad pendiente. Carga un BAPLIE para elegir el buque.');
    }
    if (selected != null && !_identityCandidates.contains(selected)) {
      return LoadFileResult.error(
          'El perfil no corresponde a este buque. Elige uno de los perfiles propuestos.');
    }
    if (selected == null &&
        _identityCandidates.any((p) => p.key == voyage.vessel.profileKey)) {
      return LoadFileResult.error(
          'No se pueden distinguir estos buques solo por nombre. '
          'Pide una exportación con IMO o indicativo en el archivo.');
    }
    _nameMatchConfirmed = true;
    _identityCandidates = const [];
    _busy = true;
    try {
      return await _useProfile(selected);
    } catch (error, stack) {
      return LoadFileResult.error(vesselErrorMessage(error, stack));
    } finally {
      _busy = false;
    }
  }

  Future<LoadFileResult> _useProfile(VesselProfile? saved) async {
    final voyage = _pendingVoyage!;
    _newProfile = saved == null;
    _pendingProfile = saved ?? VesselProfile.proposeFrom(voyage);
    if (saved != null && saved.geometry.coversAll(voyage.stowagePositions)) {
      await _publish(voyage, saved, voyage.proposedPortOfCall);
      return LoadFileResult.success(_fileName);
    }
    return LoadFileResult.needsGeometry(_fileName);
  }

  /// Único punto de publicación: siempre inyecta la geometría del perfil.
  Future<void> _publish(
      VesselVoyage voyage, VesselProfile profile, String? portOfCall) async {
    final published = voyage
        .withGeometry(profile.geometry, portOfCall: portOfCall)
        .copyWith(vesselProfileKey: profile.key);
    final local = await ref.read(localVesselRepositoryProvider.future);
    (await local.saveVoyage(published))
        .fold((failure) => throw VesselOperationFailure(failure), (_) {});
    ref.invalidate(recentVoyagesProvider);
    _publishedProfile = profile;
    _reopenKeptParameters = const [];
    _clearPending();
    state = AsyncValue.data(published);
  }

  /// Publica el viaje con la geometría que el usuario confirmó.
  ///
  /// Sirve para el viaje pendiente y también para corregir la geometría de uno
  /// ya publicado. Solo delega en `_publish` después de guardar correctamente.
  Future<String?> confirmGeometry(VesselGeometry geometry,
      {String? portOfCall,
      Set<String>? reeferSlots,
      VesselProfileOrigin? reeferSlotsOrigin}) async {
    if (_busy) {
      return 'Hay una operación en curso. Espera a que termine e inténtalo de nuevo.';
    }
    if (_identityCandidates.isNotEmpty) {
      return 'Confirma primero la identidad del buque.';
    }
    final target = _pendingVoyage ?? publishedVoyage;
    if (target == null) {
      return 'No hay un viaje para confirmar. Carga un BAPLIE primero.';
    }
    if (!geometry.coversAll(target.stowagePositions)) {
      return 'La geometría deja posiciones del archivo fuera del plano. '
          'Amplía las filas o niveles para incluirlas.';
    }
    final profile = (currentProfile ?? VesselProfile.proposeFrom(target))
        .copyWith(
            geometry: geometry,
            reeferSlots: reeferSlots,
            reeferSlotsOrigin: reeferSlotsOrigin,
            origin: VesselProfileOrigin.declaredByUser,
            updatedAt: DateTime.now());
    _busy = true;
    try {
      final local = await ref.read(localVesselRepositoryProvider.future);
      final saved = await local.saveProfile(profile,
          nameMatchConfirmed: _nameMatchConfirmed || _pendingVoyage == null);
      final error = saved.fold<String?>(
          (failure) => vesselFailureMessage(failure), (_) => null);
      if (error != null) return error;
      ref.invalidate(savedVesselProfilesProvider);
      await _publish(target, profile, portOfCall);
      return null;
    } catch (error, stack) {
      return vesselErrorMessage(error, stack);
    } finally {
      _busy = false;
    }
  }

  /// Edita un perfil sin necesitar cargar un archivo. Si su buque tiene viaje
  /// visible, preserva la cobertura de su carga y actualiza su plano al guardar.
  Future<String?> saveEditedProfile(
      VesselProfile original, VesselProfile edited) async {
    if (_busy || _pendingVoyage != null) {
      return 'Ya hay una carga en curso. Termínala o cancélala antes de abrir otra.';
    }
    if (original.identity != edited.identity ||
        original.vesselName != edited.vesselName) {
      return 'La edición de parámetros no permite cambiar la identidad del buque. '
          'Abre el perfil correcto antes de editar.';
    }
    final voyage = publishedVoyage;
    final applies = _publishedProfile?.key == original.key && voyage != null;
    if (applies && !edited.geometry.coversAll(voyage.stowagePositions)) {
      return 'La geometría deja posiciones del viaje abierto fuera del plano. '
          'Amplía las filas o niveles para incluirlas.';
    }
    if (original == edited) return null;
    _busy = true;
    try {
      final local = await ref.read(localVesselRepositoryProvider.future);
      final profiles = (await local.getAllProfiles()).fold(
          (failure) => throw VesselOperationFailure(failure), (value) => value);
      if (!profiles.contains(original)) {
        return 'El perfil cambió. Vuelve a abrirlo antes de editar.';
      }
      final result = await local.saveProfile(edited, nameMatchConfirmed: true);
      final error = result.fold<String?>(
          (failure) => vesselFailureMessage(failure), (_) => null);
      if (error != null) return error;
      ref.invalidate(savedVesselProfilesProvider);
      if (applies) await _publish(voyage, edited, voyage.portOfCall);
      return null;
    } catch (error, stack) {
      return vesselErrorMessage(error, stack);
    } finally {
      _busy = false;
    }
  }

  /// Reabre la instantánea local, sin parser, selector de archivo ni nube.
  Future<String?> openRecentVoyage(String id) async {
    if (_busy || _pendingVoyage != null) {
      return 'Ya hay una carga en curso. Termínala o cancélala antes de abrir otra.';
    }
    _busy = true;
    try {
      final local = await ref.read(localVesselRepositoryProvider.future);
      final voyage = (await local.getVoyageById(id)).fold(
          (failure) => throw VesselOperationFailure(failure), (value) => value);
      if (voyage == null) {
        return 'El viaje ya no está guardado. Vuelve a cargar su BAPLIE.';
      }
      final geometry = voyage.geometry;
      if (geometry == null || !geometry.coversAll(voyage.stowagePositions)) {
        return 'Este viaje no tiene una geometría válida guardada. Vuelve a cargar el BAPLIE.';
      }
      final profiles = (await local.getAllProfiles()).fold(
          (failure) => throw VesselOperationFailure(failure), (value) => value);
      VesselProfile? profile;
      for (final saved in profiles) {
        if (voyage.vesselProfileKey != null
            ? saved.key == voyage.vesselProfileKey
            : saved.identity
                .matchesAutomatically(voyage.vessel.profileIdentity)) {
          profile = saved;
          break;
        }
      }
      // T-61: las dimensiones son las del viaje (la geometría histórica no se
      // ensancha); los parámetros del buque salen del perfil vigente, salvo
      // el que dejaría carga fuera del plano, que conserva el valor guardado.
      final reopened = profile == null
          ? null
          : applyCurrentProfileParameters(
              voyageGeometry: geometry,
              profileGeometry: profile.geometry,
              positions: voyage.stowagePositions);
      final effective = reopened?.geometry ?? geometry;
      _publishedProfile = (profile ?? VesselProfile.proposeFrom(voyage))
          .copyWith(geometry: effective);
      _reopenKeptParameters = reopened?.keptFromVoyage ?? const [];
      _clearPending();
      ref.read(selectedBayProvider.notifier).clear();
      ref.read(highlightedContainerProvider.notifier).clear();
      ref.read(selectedCarrierProvider.notifier).clear();
      ref.read(selectedTypeFilterProvider.notifier).clear();
      state = AsyncValue.data(
          effective == geometry ? voyage : voyage.withGeometry(effective));
      return null;
    } catch (error, stack) {
      return vesselErrorMessage(error, stack);
    } finally {
      _busy = false;
    }
  }

  Future<String?> deleteRecentVoyage(String id) async {
    if (_busy || _pendingVoyage != null) {
      return 'Ya hay una carga en curso. Termínala o cancélala antes de abrir otra.';
    }
    _busy = true;
    try {
      final local = await ref.read(localVesselRepositoryProvider.future);
      (await local.deleteVoyage(id))
          .fold((failure) => throw VesselOperationFailure(failure), (_) {});
      ref.invalidate(recentVoyagesProvider);
      // El viaje abierto sigue visible; borrar la copia local no borra el perfil.
      return null;
    } catch (error, stack) {
      return vesselErrorMessage(error, stack);
    } finally {
      _busy = false;
    }
  }

  /// Descarta el viaje pendiente cuando el usuario cancela los parámetros.
  void discardPendingVoyage() {
    if (!_busy) _clearPending();
  }

  void _clearPending() {
    _pendingVoyage = null;
    _pendingProfile = null;
    _identityCandidates = const [];
    _nameMatchConfirmed = false;
    _newProfile = false;
  }

  /// Limpia el viaje cargado
  void clearVoyage() {
    if (_busy) return;
    _clearPending();
    _publishedProfile = null;
    _reopenKeptParameters = const [];
    state = const AsyncValue.data(null);
  }
}

/// Provider para obtener contenedores de una bahía específica
final containersInBayProvider =
    Provider.family<List<ContainerUnit>, int>((ref, bayNumber) {
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
final selectedCarrierProvider =
    NotifierProvider<SelectedCarrierNotifier, String?>(
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
        totalWeight: voyage.totalWeight,
        totalGrossWeight: voyage.totalGrossWeight,
        totalVgmWeight: voyage.totalVgmWeight,
        totalBays: voyage.bays.length,
      );
    },
    orElse: () => null,
  );
});

/// Provider para el contenedor resaltado (búsqueda)
final highlightedContainerProvider =
    NotifierProvider<HighlightedContainerNotifier, String?>(
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
enum LegendFilterType { full, empty, imo, reefer, oog, transit }

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
  /// Peso efectivo del viaje (T-66): VGM si viene, si no el bruto.
  final double totalWeight;
  final double totalGrossWeight;
  final double totalVgmWeight;
  final int totalBays;

  const VoyageStats({
    required this.totalContainers,
    required this.fullContainers,
    required this.emptyContainers,
    required this.totalWeight,
    required this.totalGrossWeight,
    required this.totalVgmWeight,
    required this.totalBays,
  });

  double get occupancyRate =>
      totalContainers > 0 ? (fullContainers / totalContainers) * 100 : 0;
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
      int reefers = 0,
          dangerous = 0,
          oog = 0,
          twentyFt = 0,
          fortyFt = 0,
          fortyFiveFt = 0;
      for (final c in voyage.containers) {
        if (c.isReefer) reefers++;
        if (c.isDangerous) dangerous++;
        if (c.isOverDimension) oog++;
        final size = c.sizeInFeet;
        if (size == 20) {
          twentyFt++;
        } else if (size == 40) {
          fortyFt++;
        } else if (size == 45) {
          fortyFiveFt++;
        }
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
