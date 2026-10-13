import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../formatters/vessel_error_message.dart';
import 'vessel_providers.dart';

/// T-91 · Preferencia local compartida; alternar no modifica el viaje.
final planToolbarCollapsedProvider =
    AsyncNotifierProvider<PlanToolbarNotifier, bool>(
  PlanToolbarNotifier.new,
  retry: (retryCount, error) => null,
);

class PlanToolbarNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final local = await ref.watch(localVesselRepositoryProvider.future);
    return (await local.getPlanToolbarCollapsed()).fold(
        (failure) => throw VesselOperationFailure(failure), (value) => value);
  }

  Future<void> toggle() async {
    if (state.isLoading) {
      try {
        await future;
      } catch (_) {
        // Si falla la lectura, el botón sigue recuperando las acciones.
        // La escritura posterior informa el fallo de persistencia a la vista.
      }
    }
    final collapsed = !(state.value ?? true);
    state = AsyncData(collapsed);
    final local = await ref.read(localVesselRepositoryProvider.future);
    (await local.setPlanToolbarCollapsed(collapsed))
        .fold((failure) => throw VesselOperationFailure(failure), (_) {});
  }
}
