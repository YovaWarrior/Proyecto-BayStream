import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/app_theme_preference.dart';
import '../formatters/vessel_error_message.dart';
import '../providers/theme_preference_provider.dart';

/// Ajustes del dispositivo, separados de la confirmación del perfil del buque.
class ParametersPage extends ConsumerWidget {
  final VoidCallback? onVesselParameters;
  const ParametersPage({super.key, this.onVesselParameters});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preference = ref.watch(themePreferenceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Parámetros')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text('Tema de la aplicación', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        DropdownButtonFormField<AppThemePreference>(
          key: ValueKey('theme-choice-${preference.value?.name ?? "system"}'),
          initialValue: preference.value ?? AppThemePreference.system,
          decoration: const InputDecoration(labelText: 'Tema', border: OutlineInputBorder()),
          items: const [
            DropdownMenuItem(value: AppThemePreference.system, child: Text('Seguir al sistema')),
            DropdownMenuItem(value: AppThemePreference.light, child: Text('Claro')),
            DropdownMenuItem(value: AppThemePreference.dark, child: Text('Oscuro')),
          ],
          onChanged: preference.isLoading ? null : (value) async {
            if (value == null) return;
            try {
              await ref.read(themePreferenceProvider.notifier).select(value);
            } catch (error, stack) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('No se pudo guardar el tema. ${vesselErrorMessage(error, stack)}'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ));
            }
          },
        ),
        const SizedBox(height: 8),
        const Text('La elección se guarda en este dispositivo. Seguir al sistema adapta el tema a sus cambios.'),
        if (preference.hasError) ...[
          const SizedBox(height: 8),
          Text('No se pudo leer el tema guardado. Puedes elegirlo de nuevo.',
              style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ],
        if (onVesselParameters != null) ...[
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.straighten),
            title: const Text('Parámetros del buque'),
            trailing: const Icon(Icons.chevron_right),
            onTap: onVesselParameters,
          ),
        ],
      ]),
    );
  }
}
