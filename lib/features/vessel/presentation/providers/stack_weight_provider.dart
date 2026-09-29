import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/stowage_validation_result.dart';
import '../../domain/services/stack_weight_validator.dart';
import 'vessel_providers.dart';

/// Resultados de T-38 para el viaje completo; los filtros visuales no alteran
/// la carga que soporta una pila. T-42 consumirá este mismo contrato.
final stackWeightResultsProvider =
    Provider<List<StowageValidationResult>>((ref) {
  final state = ref.watch(voyageNotifierProvider);
  final voyage = state.hasValue ? state.value : null;
  final profile = ref.read(voyageNotifierProvider.notifier).publishedProfile;
  if (voyage == null || profile == null) return const [];
  return const StackWeightValidator().validate(voyage, profile);
});
