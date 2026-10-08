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
  final operation =
      await OperationSources.find(repository, voyage, voyage.portOfCall!);
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
  final loading = await source(OperationSourceKind.loadingBaplie) ?? voyage;
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
          movements: records.map((r) => r.movement));
  if (operation == null) {
    yield derive(const []);
    return;
  }
  await for (final records in repository.watch(operation.id)) {
    yield derive(records);
  }
});
