import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/entities.dart';
import '../../domain/services/loading_plan_progress.dart';
import '../../domain/services/operation_sources.dart';
import '../../domain/services/operation_state_deriver.dart';
import '../formatters/vessel_error_message.dart';
import 'movement_log_provider.dart';
import 'vessel_providers.dart';

/// Sigue los cambios de T-72; no mantiene un contador paralelo en presentación.
final loadingPlanProgressProvider = StreamProvider.autoDispose
    .family<LoadingPlanProgress, VesselVoyage>((ref, voyage) async* {
  ref.watch(operationSourcesRevisionProvider);
  final port = voyage.portOfCall!;
  final repository = await ref.watch(movementLogRepositoryProvider.future);
  final operation = await OperationSources.find(repository, voyage, port);
  final listSource = operation?.source(OperationSourceKind.exportList);
  final list = listSource == null
      ? null
      : ExportList.fromJson(
          jsonDecode(listSource.content) as Map<String, dynamic>);
  // T-74 presenta la carga. El plano de llegada se conserva como fuente para
  // las descargas de T-75; no se inventan sus movimientos en esta proyección.
  final loadingSource = operation?.source(OperationSourceKind.loadingBaplie);
  var loading = voyage;
  if (loadingSource != null) {
    loading = (await ref
            .read(vesselRepositoryProvider)
            .parseBaplieFile(loadingSource.content))
        .fold((failure) => throw VesselOperationFailure(failure),
            (value) => value)
        .withGeometry(voyage.geometry!, portOfCall: port);
  }
  final plan = OperationPlan.build(
      loading: loading, portOfCall: port, geometry: voyage.geometry);
  LoadingPlanProgress derive(Iterable<MovementRecord> records) =>
      LoadingPlanProgress.build(
          loading,
          const OperationStateDeriver().derive(plan,
              LoadingPlanProgress.loadingMovements(records.map((r) => r.movement))),
          list: list);
  if (operation == null) {
    yield derive(const []);
    return;
  }
  await for (final records in repository.watch(operation.id)) {
    yield derive(records);
  }
});
