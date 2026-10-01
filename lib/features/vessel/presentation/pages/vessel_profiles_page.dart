import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/entities.dart';
import '../providers/vessel_providers.dart';
import '../formatters/vessel_error_message.dart';
import 'vessel_geometry_page.dart';

/// Acceso a los parámetros del buque aunque no haya un viaje abierto.
class VesselProfilesPage extends ConsumerWidget {
  const VesselProfilesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(title: const Text('Perfiles guardados')),
        body: ref.watch(savedVesselProfilesProvider).when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(vesselErrorMessage(error)),
                TextButton(
                    onPressed: () =>
                        ref.invalidate(savedVesselProfilesProvider),
                    child: const Text('Reintentar')),
              ])),
              data: (profiles) => profiles.isEmpty
                  ? const Center(
                      child: Text(
                          'Todavía no hay perfiles guardados. Carga un BAPLIE para declarar el primero.'))
                  : ListView(children: [
                      for (final profile in profiles)
                        ListTile(
                            key: ValueKey('edit-profile-${profile.key}'),
                            title: Text(profile.vesselName),
                            subtitle: Text(profile.key),
                            trailing: const Icon(Icons.edit_outlined),
                            onTap: () => _edit(context, ref, profile)),
                    ]),
            ),
      );

  Future<void> _edit(
      BuildContext context, WidgetRef ref, VesselProfile original) async {
    final notifier = ref.read(voyageNotifierProvider.notifier);
    final voyage = notifier.currentProfile?.key == original.key
        ? notifier.publishedVoyage
        : null;
    var draft = original;
    while (context.mounted) {
      final positions = voyage?.stowagePositions.toList() ?? [];
      final result = await Navigator.of(context)
          .push<VesselCallParameters>(MaterialPageRoute(
        builder: (_) => VesselGeometryPage(
            profile: draft,
            profileOnly: true,
            proposal: VesselGeometry.proposeFrom(positions,
                parameters: draft.geometry),
            initial: draft.geometry,
            positions: positions),
      ));
      if (!context.mounted || result == null) return;
      if (!result.changed && draft == original) return;
      draft = draft.copyWith(
          geometry: result.geometry,
          reeferSlots: result.reeferSlots,
          reeferSlotsOrigin: result.reeferSlotsOrigin,
          origin: VesselProfileOrigin.declaredByUser,
          updatedAt: DateTime.now());
      final error = await notifier.saveEditedProfile(original, draft);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error ?? 'Perfil guardado'),
          backgroundColor:
              error == null ? null : Theme.of(context).colorScheme.error));
      if (error == null) return;
    }
  }
}
