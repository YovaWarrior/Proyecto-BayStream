import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/entities.dart';
import '../../domain/services/loading_operation.dart';
import '../../domain/services/operation_sources.dart';
import '../formatters/vessel_error_message.dart';
import 'movement_log_provider.dart';
import 'vessel_providers.dart';

final loadingOperationProvider = StreamProvider.autoDispose
    .family<LoadingOperation, VesselVoyage>((ref, voyage) async* {
  ref.watch(operationSourcesRevisionProvider);
  final repository = await ref.watch(movementLogRepositoryProvider.future);
  // Si el viaje se cierra mientras esto construye (Atrás dos veces nada más
  // abrir el plano, «Cerrar el plano»), el provider ya está desechado y usar
  // `ref` lanzaría: se comprueba después de cada espera (10.28).
  if (!ref.mounted) return;
  final operation =
      await OperationSources.find(repository, voyage, voyage.portOfCall!);
  if (!ref.mounted) return;
  ref.watch(voyageNotifierProvider);
  final current = ref.read(voyageNotifierProvider.notifier).publishedProfile;
  final profile = operation?.published == true ? operation?.profile :
      current?.key == (voyage.vesselProfileKey ?? voyage.vessel.profileKey) ? current : null;
  Future<VesselVoyage?> source(OperationSourceKind kind) async {
    final text = operation?.source(kind)?.content;
    if (text == null) return null;
    final parsed =
        (await ref.read(vesselRepositoryProvider).parseBaplieFile(text)).fold(
            (failure) => throw VesselOperationFailure(failure),
            (value) => value);
    return voyage.geometry == null
        ? parsed.copyWith(portOfCall: voyage.portOfCall)
        : parsed.withGeometry(voyage.geometry!, portOfCall: voyage.portOfCall);
  }

  final arrival = await source(OperationSourceKind.arrivalBaplie);
  if (!ref.mounted) return;
  final loading = await source(OperationSourceKind.loadingBaplie) ?? voyage;
  if (!ref.mounted) return;
  final listSource = operation?.source(OperationSourceKind.exportList);
  final list = listSource == null
      ? null
      : ExportList.fromJson(
          jsonDecode(listSource.content) as Map<String, dynamic>);
  LoadingOperation derive(Iterable<MovementRecord> records) =>
      LoadingOperation.build(
          operationId: operation?.id,
          arrival: arrival,
          loading: loading,
          list: list,
          hatchCovers: profile?.hatchCovers ?? const {},
          movements: records.where((r) => r.state != SendState.rejected).map((r) => r.movement));
  if (operation == null) {
    yield derive(const []);
    return;
  }
  await for (final records in repository.watch(operation.id)) {
    yield derive(records);
  }
});

/// Si en [voyage] se carga algo en la escala: entonces hay plan de carga y
/// puede haber vacíos asignados a sus reservas. Es la condición con que el
/// viaje ofrece «Listado de la agencia».
bool _loadsAtCall(VesselVoyage voyage) {
  final port = voyage.portOfCall;
  return port != null &&
      voyage.cargoCountsFor(port).loaded +
              voyage.reservedCountsFor(port).loaded >
          0;
}

/// T-122 (H6, 10.56) · Los contenedores a bordo que la Lista y la búsqueda
/// general recorren: los del archivo y, en un plan de carga con operación,
/// los vacíos que el muelle asignó a una reserva, que el archivo trae sin
/// número y en la 3.1.0 ninguna búsqueda encontraba.
final aboardContainersProvider = Provider<List<ContainerUnit>>((ref) {
  final voyage = ref.watch(voyageNotifierProvider).value;
  if (voyage == null) return const [];
  if (!_loadsAtCall(voyage)) return voyage.containers;
  final assigned =
      ref.watch(loadingOperationProvider(voyage)).value?.assignedEmpties ??
          const <ContainerUnit>[];
  return [...voyage.containers, ...assigned];
});

/// Las navieras de lo que va a bordo, ordenadas.
final carriersListProvider = Provider<List<String>>((ref) {
  final carriers = ref
      .watch(aboardContainersProvider)
      .map((c) => c.operatorCode)
      .where((code) => code != null && code.isNotEmpty)
      .cast<String>()
      .toSet()
      .toList();
  carriers.sort();
  return carriers;
});

/// Lo que va a bordo, filtrado por la naviera elegida.
final filteredContainersProvider = Provider<List<ContainerUnit>>((ref) {
  final containers = ref.watch(aboardContainersProvider);
  final selectedCarrier = ref.watch(selectedCarrierProvider);
  if (selectedCarrier == null) return containers;
  return containers.where((c) => c.operatorCode == selectedCarrier).toList();
});
