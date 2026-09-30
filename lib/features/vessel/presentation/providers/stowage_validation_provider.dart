import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/stowage_validation_result.dart';
import '../../domain/services/container_stacking_validator.dart';
import '../../domain/services/reefer_socket_validator.dart';
import 'segregation_provider.dart';
import 'stack_weight_provider.dart';
import 'vessel_providers.dart';

final reeferSocketResultsProvider =
    Provider<List<StowageValidationResult>>((ref) {
  final state = ref.watch(voyageNotifierProvider);
  final voyage = state.hasValue ? state.value : null;
  final profile = ref.read(voyageNotifierProvider.notifier).publishedProfile;
  if (voyage == null || profile == null) return const [];
  return const ReeferSocketValidator().validate(voyage.containers, profile);
});

final containerStackingResultsProvider =
    Provider<List<StowageValidationResult>>((ref) {
  final state = ref.watch(voyageNotifierProvider);
  final voyage = state.hasValue ? state.value : null;
  if (voyage == null) return const [];
  return const ContainerStackingValidator().validate(voyage, voyage.geometry!);
});

/// Todo el viaje, independiente de los filtros visuales y sin descartar
/// resultados no evaluados. Desempate estable por regla, posición y contenido.
final stowageValidationResultsProvider =
    Provider<List<StowageValidationResult>>((ref) {
  final results = [
    ...ref.watch(stackWeightResultsProvider),
    ...ref.watch(reeferSocketResultsProvider),
    ...ref.watch(containerStackingResultsProvider),
    ...ref.watch(segregationResultsProvider),
  ];
  results.sort(compareValidationResults);
  return List.unmodifiable(results);
});

int compareValidationResults(
    StowageValidationResult a, StowageValidationResult b) {
  final severity = b.severity.index.compareTo(a.severity.index);
  if (severity != 0) return severity;
  int statusRank(ValidationStatus s) => switch (s) {
        ValidationStatus.nonConforming => 0,
        ValidationStatus.notEvaluated => 1,
        ValidationStatus.conforming => 2,
      };
  final status = statusRank(a.status).compareTo(statusRank(b.status));
  if (status != 0) return status;
  final rule = a.rule.index.compareTo(b.rule.index);
  if (rule != 0) return rule;
  final position = a.positions
      .map((p) => p.toIsoCode())
      .join('/')
      .compareTo(b.positions.map((p) => p.toIsoCode()).join('/'));
  if (position != 0) return position;
  return '${a.containerIds.join('/')}/${a.description}'
      .compareTo('${b.containerIds.join('/')}/${b.description}');
}
