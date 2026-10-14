import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/app_theme_preference.dart';
import '../formatters/vessel_error_message.dart';
import 'vessel_providers.dart';

final themePreferenceProvider =
    AsyncNotifierProvider<ThemePreferenceNotifier, AppThemePreference>(
  ThemePreferenceNotifier.new,
  retry: (retryCount, error) => null,
);

class ThemePreferenceNotifier extends AsyncNotifier<AppThemePreference> {
  @override
  Future<AppThemePreference> build() async {
    final local = await ref.watch(localVesselRepositoryProvider.future);
    return (await local.getThemePreference()).fold(
        (failure) => throw VesselOperationFailure(failure), (value) => value);
  }

  Future<void> select(AppThemePreference preference) async {
    if (state.isLoading) {
      try {
        await future;
      } catch (_) {
        // La lectura fallida no impide elegir; la escritura informa su resultado.
      }
    }
    state = AsyncData(preference);
    final local = await ref.read(localVesselRepositoryProvider.future);
    (await local.setThemePreference(preference))
        .fold((failure) => throw VesselOperationFailure(failure), (_) {});
  }
}
