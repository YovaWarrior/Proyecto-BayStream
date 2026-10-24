import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/app_theme_preference.dart';
import '../formatters/vessel_error_message.dart';
import '../providers/oficina_providers.dart';
import '../providers/theme_preference_provider.dart';
import '../widgets/avisos_del_viaje.dart';
import '../widgets/navegacion_del_viaje.dart' show AnchosDeNavegacion;
import 'privacy_policy_page.dart';

/// Ajustes del dispositivo, separados de la confirmación del perfil del buque.
class ParametersPage extends ConsumerWidget {
  final VoidCallback? onVesselParameters;
  const ParametersPage({super.key, this.onVesselParameters});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preference = ref.watch(themePreferenceProvider);
    // T-117 · Lo de la oficina, solo donde hay oficina (desde 600 dp).
    final conOficina =
        MediaQuery.sizeOf(context).width >= AnchosDeNavegacion.riel;
    final oficina = conOficina
        ? ref.watch(preferenciasDeLaOficinaProvider).value ??
            const PreferenciasDeLaOficina()
        : null;
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
              // Puede seguir en pantalla al volver al plano: sabe su
              // lugar (10.33).
              ScaffoldMessenger.of(context).showSnackBar(avisoDelViaje(
                texto: vesselErrorMessage(error, stack, 'guardar el tema'),
                corto: 'No se guardó el tema.',
                fondo: Theme.of(context).colorScheme.error,
              ));
            }
          },
        ),
        const SizedBox(height: 8),
        const Text('La elección se guarda en este dispositivo. Seguir al sistema adapta el tema a sus cambios.'),
        if (preference.hasError) ...[
          const SizedBox(height: 8),
          Text('No se pudo leer el tema guardado: falló la lectura de las preferencias '
              'de este dispositivo; se usa el del sistema. Elígelo de nuevo.',
              style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ],
        // T-117 (DESIGN.md 14.3): el panel lateral por el borde, del equipo.
        if (oficina != null) ...[
          const SizedBox(height: 24),
          Text('Panel lateral', style: Theme.of(context).textTheme.titleMedium),
          SwitchListTile(
            key: const ValueKey('pref-panel-por-el-borde'),
            contentPadding: EdgeInsets.zero,
            title: const Text(
                'Mostrar el panel lateral al pasar el mouse por el borde'),
            subtitle: const Text('Con el panel oculto, sale flotante si el '
                'mouse se queda en el borde derecho de la ventana. Se guarda '
                'en este equipo.'),
            value: oficina.panelAlPasarElMouse,
            onChanged: (value) async {
              final guardado = await ref
                  .read(preferenciasDeLaOficinaProvider.notifier)
                  .panelAlPasarElMouse(value);
              if (guardado) return;
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(avisoDelViaje(
                texto: 'No se guardó la preferencia: falló el almacén local de '
                    'este equipo. Vale hasta cerrar la app; elígela de nuevo '
                    'al volver a abrirla.',
                corto: 'No se guardó la preferencia.',
                fondo: Theme.of(context).colorScheme.error,
              ));
            },
          ),
        ],
        // T-88: la política, sin viaje y sin sesión.
        const SizedBox(height: 24),
        ListTile(
          key: const ValueKey('privacy-policy'),
          leading: const Icon(Icons.privacy_tip_outlined),
          title: const Text('Política de privacidad'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => PrivacyPolicyPage.open(context),
        ),
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
