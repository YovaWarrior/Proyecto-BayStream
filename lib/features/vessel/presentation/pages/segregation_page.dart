import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/stowage_validation_result.dart';
import '../../domain/services/segregation_rules.dart';
import '../providers/segregation_provider.dart';

/// Vista específica de T-41. El panel conjunto y la navegación a posiciones
/// pertenecen a T-42; aquí solo se expone qué se evaluó y qué quedó sin evaluar.
class SegregationPage extends ConsumerWidget {
  const SegregationPage({super.key});

  static String statusLabel(ValidationStatus status) => switch (status) {
        ValidationStatus.conforming => 'Conforme en las reglas evaluadas',
        ValidationStatus.nonConforming => 'Posible incumplimiento',
        ValidationStatus.notEvaluated => 'No evaluado',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(segregationResultsProvider);
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Segregación · IMDG')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: results.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(SegregationRules.disclaimer),
                  const SizedBox(height: 12),
                  Text(results.isEmpty
                      ? 'No hay pares de mercancías peligrosas para evaluar. Esto no declara el viaje conforme.'
                      : '${results.where((r) => r.status == ValidationStatus.nonConforming).length} posibles incumplimientos · '
                          '${results.where((r) => r.status == ValidationStatus.notEvaluated).length} no evaluados · '
                          '${results.where((r) => r.status == ValidationStatus.conforming).length} conformes en las reglas evaluadas'),
                  const SizedBox(height: 12),
                  const Text('Matriz por clase · IMDG 7.2.4. '
                      '1 a 4: exigencia de separación creciente, evaluada con 7.4.3.2; '
                      'X: consultar la Lista; *: revisar 7.2.7.1. '
                      'La clase 1 usa las divisiones agrupadas indicadas.'),
                  ExpansionTile(
                    title: const Text('Ver matriz de 17 clases'),
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: RepaintBoundary(
                            child: DataTable(
                          dataRowColor: WidgetStatePropertyAll(colors.surface),
                          headingRowColor:
                              WidgetStatePropertyAll(colors.surfaceContainer),
                          columns: [
                            const DataColumn(label: Text('Clase')),
                            for (final c in SegregationRules.classes)
                              DataColumn(label: Text(c)),
                          ],
                          rows: [
                            for (final a in SegregationRules.classes)
                              DataRow(cells: [
                                DataCell(Text(a)),
                                for (final b in SegregationRules.classes)
                                  DataCell(Text(SegregationRules.symbol(
                                      SegregationRules.code(a, b)!))),
                              ]),
                          ],
                        )),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                ]);
          }
          final result = results[index - 1];
          return Card(
              color: colors.surfaceContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(statusLabel(result.status),
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(result.containerIds.join(' / ')),
                      Text(result.positions.isEmpty
                          ? 'Posición no disponible'
                          : result.positions
                              .map((p) => p.toIsoCode())
                              .join(' / ')),
                      const SizedBox(height: 8),
                      Text(result.description),
                      if (result.references.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(result.references.join('; '),
                            style: TextStyle(color: colors.onSurfaceVariant)),
                      ],
                    ]),
              ));
        },
      ),
    );
  }
}
