import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/entities.dart';
import '../../domain/repositories/local_vessel_repository.dart';
import '../providers/vessel_providers.dart';
import '../formatters/vessel_error_message.dart';
import '../widgets/empty_state_widget.dart';

/// Viajes de este dispositivo; la pantalla solo consulta el contrato local.
class RecentVoyagesPage extends ConsumerStatefulWidget {
  const RecentVoyagesPage({super.key});

  @override
  ConsumerState<RecentVoyagesPage> createState() => _RecentVoyagesPageState();
}

class _RecentVoyagesPageState extends ConsumerState<RecentVoyagesPage> {
  bool _working = false;

  Future<void> _open(VesselVoyage voyage) async {
    setState(() => _working = true);
    final error = await ref
        .read(voyageNotifierProvider.notifier)
        .openRecentVoyage(voyage.id);
    if (!mounted) return;
    setState(() => _working = false);
    if (error == null) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _delete(VesselVoyage voyage) async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Eliminar viaje guardado'),
              content: Text(
                  '¿Eliminar ${voyage.vessel.name}, viaje ${voyage.voyageNumber}, de este dispositivo? '
                  'El perfil del buque se conserva.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar')),
                FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Eliminar')),
              ],
            ));
    if (!mounted || confirmed != true) return;
    setState(() => _working = true);
    final error = await ref
        .read(voyageNotifierProvider.notifier)
        .deleteRecentVoyage(voyage.id);
    if (!mounted) return;
    setState(() => _working = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            error ?? 'Viaje eliminado. El perfil del buque se conserva.')));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Viajes recientes')),
        body: Column(children: [
          const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                  'Se conservan los últimos ${LocalVesselRepository.recentVoyageLimit} viajes cargados en este dispositivo. '
                  'Al guardar el sexto se elimina el más antiguo. Los perfiles se conservan. '
                  'Puedes abrir estos viajes sin conexión ni archivo BAPLIE.')),
          if (_working) const LinearProgressIndicator(),
          Expanded(
              child: ref.watch(recentVoyagesProvider).when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Center(
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(vesselErrorMessage(error)),
                      TextButton(
                          onPressed: () =>
                              ref.invalidate(recentVoyagesProvider),
                          child: const Text('Reintentar')),
                    ])),
                    data: (voyages) => voyages.isEmpty
                        ? EmptyStateWidget(
                            onPickFile: () => Navigator.pop(context, true))
                        : ListView(children: [
                            for (final voyage in voyages)
                              ListTile(
                                  key: ValueKey('recent-${voyage.id}'),
                                  title: Text(
                                      '${voyage.vessel.name} · ${voyage.voyageNumber}'),
                                  subtitle: Text(
                                      '${voyage.totalContainers} contenedores · ${voyage.bays.length} bahías'),
                                  leading: const Icon(
                                      Icons.directions_boat_outlined),
                                  onTap: _working ? null : () => _open(voyage),
                                  trailing: IconButton(
                                      key: ValueKey('delete-${voyage.id}'),
                                      tooltip: 'Eliminar viaje',
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: _working
                                          ? null
                                          : () => _delete(voyage))),
                          ]),
                  )),
        ]),
      );
}
