import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/entities.dart';
import '../../domain/services/loading_plan_progress.dart';
import '../formatters/vessel_error_message.dart';
import '../pages/export_list_import_page.dart';
import '../providers/discharge_provider.dart';
import '../providers/loading_plan_provider.dart';
import 'discharge_controls.dart';

/// Modos de vista del plano. «Descarga» (T-75) solo existe en un plano de
/// llegada; fuera de ese modo, tocar una celda abre el detalle, como siempre.
enum BayPlanMode { content, order, discharge }

class LoadingPlanControls extends ConsumerWidget {
  final VesselVoyage voyage;
  final int? selectedBay;
  final BayPlanMode mode;
  final ValueChanged<BayPlanMode> onModeChanged;
  const LoadingPlanControls(
      {super.key,
      required this.voyage,
      required this.selectedBay,
      required this.mode,
      required this.onModeChanged});

  bool get orderMode => mode == BayPlanMode.order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discharge = offersDischarge(voyage);
    final dischargeMode = discharge && mode == BayPlanMode.discharge;
    final progress = voyage.portOfCall == null
        ? null
        : ref.watch(loadingPlanProgressProvider(voyage));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(
            spacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              DropdownButton<BayPlanMode>(
                key: const ValueKey('bay-plan-display-mode'),
                value: !discharge && mode == BayPlanMode.discharge
                    ? BayPlanMode.content
                    : mode,
                items: [
                  const DropdownMenuItem(
                      value: BayPlanMode.content, child: Text('Contenido')),
                  const DropdownMenuItem(
                      value: BayPlanMode.order, child: Text('Número de orden')),
                  if (discharge)
                    const DropdownMenuItem(
                        value: BayPlanMode.discharge, child: Text('Descarga')),
                ],
                onChanged: (value) {
                  if (value != null) onModeChanged(value);
                },
              ),
              if (dischargeMode)
                TextButton.icon(
                  key: const ValueKey('discharge-table-button'),
                  onPressed: () => showDischargeTable(context, voyage),
                  icon: const Icon(Icons.table_chart_outlined),
                  label: const Text('Pendientes de descarga'),
                )
              else
                TextButton.icon(
                  onPressed:
                      progress?.hasValue == true ? () => _table(context) : null,
                  icon: const Icon(Icons.table_chart_outlined),
                  label: const Text('Pendientes por bahía'),
                ),
            ]),
        if (dischargeMode)
          DischargeSummary(voyage: voyage, selectedBay: selectedBay)
        else if (voyage.portOfCall == null)
          const Text('Confirma la escala para ver el plan de carga.')
        else if (progress!.hasError)
          Text(vesselErrorMessage(progress.error!, progress.stackTrace))
        else if (!progress.hasValue)
          const Text('Leyendo el estado de la operación…')
        else ...[
          _summary(progress.value!, selectedBay),
          if (orderMode && progress.value!.list == null)
            Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
              const Text('Esta operación todavía no tiene listado de agencia.'),
              TextButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const ExportListImportPage())),
                  child: const Text('Importar listado')),
            ])
          else if (orderMode)
            Text('${progress.value!.unmatched} celdas de carga sin cruce (—).'),
        ],
      ]),
    );
  }

  Widget _summary(LoadingPlanProgress progress, int? selected) {
    final bay = selected == null ? null : progress.forBay(selected);
    return Text(
        bay == null
            ? 'Pendientes de carga: 0 en esta bahía.'
            : 'Bahía ${bay.label} · pendientes de carga: '
                'cubierta ${bay.deck} (${bay.deckFull} llenos / ${bay.deckEmpty} vacíos) · '
                'bodega ${bay.hold} (${bay.holdFull} llenos / ${bay.holdEmpty} vacíos)',
        key: const ValueKey('bay-loading-pending'));
  }

  void _table(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (context) => SafeArea(
            child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .8,
          child: Consumer(builder: (context, ref, _) {
            final progress = ref.watch(loadingPlanProgressProvider(voyage));
            return progress.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  Center(child: Text(vesselErrorMessage(error, stack))),
              data: (data) {
                final bays = data.bays.values.toList()
                  ..sort((a, b) => a.bay.compareTo(b.bay));
                return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Pendientes de carga · ${voyage.vessel.name} · ${voyage.voyageNumber} · ${voyage.portOfCall}',
                            style: Theme.of(context).textTheme.titleMedium),
                        Text(
                            '${bays.length} bahías · ${data.total} pendientes · '
                            '${data.deck} en cubierta / ${data.hold} en bodega · '
                            '${data.full} llenos / ${data.empty} vacíos',
                            key: const ValueKey('operation-loading-totals')),
                        if (data.list == null)
                          const Text('Sin listado: F/E según el plan.'),
                        const Text(
                            'Cub. = cubierta; Bod. = bodega; L = llenos; V = vacíos.'),
                        SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              horizontalMargin: 8,
                              columnSpacing: 12,
                              columns: [
                                for (final label in [
                                  'Bahía',
                                  'Cub. L',
                                  'Cub. V',
                                  'Bod. L',
                                  'Bod. V',
                                  'Total'
                                ])
                                  DataColumn(label: Text(label))
                              ],
                              rows: [
                                for (final bay in bays)
                                  DataRow(cells: [
                                    DataCell(Text(bay.label)),
                                    for (final count in [
                                      bay.deckFull,
                                      bay.deckEmpty,
                                      bay.holdFull,
                                      bay.holdEmpty,
                                      bay.deck + bay.hold
                                    ])
                                      DataCell(Text('$count')),
                                  ])
                              ],
                            )),
                        if (data.state.conflicts.isNotEmpty)
                          Text(
                              '${data.state.conflicts.length} conflictos en la bitácora; los pendientes respetan el estado derivado.'),
                        if (data.state.notDerived.isNotEmpty)
                          Text(
                              '${data.state.notDerived.length} cambios de posición o tapas todavía sin derivar (T-80/T-84).'),
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cerrar')),
                      ],
                    ));
              },
            );
          }),
        )),
      );
}
