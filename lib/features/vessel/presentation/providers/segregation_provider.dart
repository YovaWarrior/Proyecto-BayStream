import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/stowage_validation_result.dart';
import '../../domain/services/dangerous_goods_validator.dart';
import 'vessel_providers.dart';

/// Recalcula sobre todo el viaje publicado; el filtro visual por naviera no
/// puede ocultar una sustancia de la evaluación. No consulta red ni almacén.
final segregationResultsProvider =
    Provider<List<StowageValidationResult>>((ref) {
  final state = ref.watch(voyageNotifierProvider);
  final voyage = state.hasValue ? state.value : null;
  if (voyage == null) return const [];
  return const DangerousGoodsValidator()
      .validate(voyage.containers, voyage.geometry!);
});
