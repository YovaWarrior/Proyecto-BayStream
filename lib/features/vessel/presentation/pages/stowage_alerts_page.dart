import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/iso_coordinate_parser.dart';
import '../../domain/entities/stowage_validation_result.dart';
import '../../domain/services/segregation_rules.dart';
import '../providers/stowage_validation_provider.dart';

/// Devuelve la posición elegida al plano del viaje que abrió el panel.
class StowageAlertsPage extends ConsumerWidget {
  const StowageAlertsPage({super.key});

  static String severityLabel(ValidationSeverity value) => switch (value) {
        ValidationSeverity.error => 'Error',
        ValidationSeverity.warning => 'Aviso',
        ValidationSeverity.information => 'Información',
      };
  static String statusLabel(ValidationStatus value) => switch (value) {
        ValidationStatus.nonConforming => 'Posible incumplimiento',
        ValidationStatus.notEvaluated => 'No evaluado',
        ValidationStatus.conforming => 'Conforme en las reglas evaluadas',
      };
  static String ruleLabel(StowageRule value) => switch (value) {
        StowageRule.stackWeight => 'Peso por pila',
        StowageRule.reeferSocket => 'Toma de refrigerado',
        StowageRule.twentyOverForty => '20 pies sobre 40 pies',
        StowageRule.dangerousGoodsSegregation => 'Segregación · 49 CFR',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(stowageValidationResultsProvider);
    final colors = Theme.of(context).colorScheme;
    void open(IsoCoordinate p) => Navigator.of(context).pop(p);
    return Scaffold(
      appBar: AppBar(title: const Text('Alertas de estiba')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: results.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Apoyo a la decisión. Revisar con el planificador; '
                    'este panel no verifica cumplimiento.'),
                const Text(SegregationRules.disclaimer),
                const SizedBox(height: 12),
                Text(
                    '${results.where((r) => r.status == ValidationStatus.nonConforming).length} posibles incumplimientos · '
                    '${results.where((r) => r.status == ValidationStatus.notEvaluated).length} no evaluados · '
                    '${results.where((r) => r.status == ValidationStatus.conforming).length} conformes en las reglas evaluadas'),
                const Text(
                    'Orden: error, aviso, información. Se evalúa todo el viaje. '
                    'Sin límite de peso en el perfil no se emiten alertas de peso. '
                    'Las tomas propuestas o de plantilla no prueban ausencia de enchufe.'),
                if (results.isEmpty)
                  const Text(
                      'No hay resultados para mostrar. Esto no declara el viaje conforme.'),
                const SizedBox(height: 16),
              ],
            );
          }
          final r = results[index - 1];
          final alpha = switch (r.severity) {
            ValidationSeverity.error => 0.18,
            ValidationSeverity.warning => 0.09,
            ValidationSeverity.information => 0.03,
          };
          return Card(
            color: Color.alphaBlend(
                colors.primary.withValues(alpha: alpha), colors.surface),
            child: InkWell(
              onTap: r.positions.isEmpty ? null : () => open(r.positions.first),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        '${severityLabel(r.severity)} · ${statusLabel(r.status)}',
                        style: Theme.of(context).textTheme.titleMedium),
                    Text(ruleLabel(r.rule)),
                    Text(r.containerIds.join(' / ')),
                    const SizedBox(height: 8),
                    Text(r.description),
                    if (r.references.isNotEmpty)
                      Text(r.references.join('; '),
                          style: TextStyle(color: colors.onSurfaceVariant)),
                    if (r.positions.isEmpty)
                      const Text(
                          'Posición no disponible: no se puede localizar en el plano.')
                    else
                      Wrap(
                        spacing: 8,
                        children: [
                          for (final p in r.positions)
                            TextButton.icon(
                              onPressed: () => open(p),
                              icon: const Icon(Icons.location_on_outlined),
                              label: Text('Ver ${p.toIsoCode()}'),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
