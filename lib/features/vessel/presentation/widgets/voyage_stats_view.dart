import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/entities.dart';
import '../providers/vessel_providers.dart';

/// Vista de estadísticas completas del viaje
/// Incluye gráficos de distribución por naviera, tipo, tamaño y bahía
class VoyageStatsView extends ConsumerWidget {
  final VesselVoyage voyage;

  const VoyageStatsView({super.key, required this.voyage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(voyageStatsProvider);
    final carrierDist = ref.watch(carrierDistributionProvider);
    final portDist = ref.watch(portDistributionProvider);
    final specialCargo = ref.watch(specialCargoStatsProvider);
    final bayStats = ref.watch(bayStatsProvider);

    if (stats == null) {
      return const Center(child: Text('No hay datos disponibles'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen general en cards
          _SummaryGrid(stats: stats, specialCargo: specialCargo),
          const SizedBox(height: 24),

          // Distribución por tipo de carga
          _SectionTitle(title: 'Distribución por Estado', icon: Icons.pie_chart),
          const SizedBox(height: 12),
          _StatusPieChart(
            fullCount: stats.fullContainers,
            emptyCount: stats.emptyContainers,
            total: stats.totalContainers,
          ),
          const SizedBox(height: 24),

          // Distribución por tamaño
          _SectionTitle(title: 'Distribución por Tamaño', icon: Icons.straighten),
          const SizedBox(height: 12),
          _SizeDistributionBar(specialCargo: specialCargo, total: stats.totalContainers),
          const SizedBox(height: 24),

          // Carga especial
          if (specialCargo.reeferCount > 0 || specialCargo.dangerousCount > 0 || specialCargo.oogCount > 0) ...[
            _SectionTitle(title: 'Carga Especial', icon: Icons.warning_amber),
            const SizedBox(height: 12),
            _SpecialCargoCards(specialCargo: specialCargo),
            const SizedBox(height: 24),
          ],

          // Distribución por naviera
          if (carrierDist.isNotEmpty) ...[
            _SectionTitle(title: 'Distribución por Naviera', icon: Icons.business),
            const SizedBox(height: 12),
            _HorizontalBarChart(
              data: carrierDist,
              maxItems: 10,
              color: Colors.indigo,
              total: stats.totalContainers,
            ),
            const SizedBox(height: 24),
          ],

          // Distribución por puerto de descarga
          if (portDist.isNotEmpty) ...[
            _SectionTitle(title: 'Distribución por Puerto de Descarga', icon: Icons.location_on),
            const SizedBox(height: 12),
            _HorizontalBarChart(
              data: portDist,
              maxItems: 10,
              color: Colors.teal,
              total: stats.totalContainers,
            ),
            const SizedBox(height: 24),
          ],

          // Ocupación por bahía
          if (bayStats.isNotEmpty) ...[
            _SectionTitle(title: 'Contenedores por Bahía', icon: Icons.view_column),
            const SizedBox(height: 12),
            _BayOccupancyChart(bayStats: bayStats),
            const SizedBox(height: 24),
          ],

          // Peso por bahía
          if (bayStats.isNotEmpty) ...[
            _SectionTitle(title: 'Peso por Bahía (toneladas)', icon: Icons.scale),
            const SizedBox(height: 12),
            _BayWeightChart(bayStats: bayStats),
            const SizedBox(height: 32),
          ],
        ],
      ),
    );
  }
}

// ============================================
// COMPONENTES INTERNOS
// ============================================

/// Título de sección
class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

/// Grid de resumen con 6 métricas
class _SummaryGrid extends StatelessWidget {
  final VoyageStats stats;
  final SpecialCargoStats specialCargo;

  const _SummaryGrid({required this.stats, required this.specialCargo});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.8,
          children: [
            _MetricCard(
              label: 'Total Contenedores',
              value: stats.totalContainers.toString(),
              icon: Icons.inventory_2,
              color: Colors.blue,
            ),
            _MetricCard(
              label: 'Bahías Ocupadas',
              value: stats.totalBays.toString(),
              icon: Icons.view_module,
              color: Colors.deepPurple,
            ),
            _MetricCard(
              label: 'Peso Bruto Total',
              value: _formatTons(stats.totalGrossWeight),
              icon: Icons.scale,
              color: Colors.orange,
            ),
            _MetricCard(
              label: 'Llenos',
              value: stats.fullContainers.toString(),
              icon: Icons.check_box,
              color: Colors.green,
            ),
            _MetricCard(
              label: 'Vacíos',
              value: stats.emptyContainers.toString(),
              icon: Icons.check_box_outline_blank,
              color: Colors.amber,
            ),
            _MetricCard(
              label: 'Reefers',
              value: specialCargo.reeferCount.toString(),
              icon: Icons.ac_unit,
              color: Colors.cyan,
            ),
          ],
        );
      },
    );
  }

  String _formatTons(double weightKg) {
    if (weightKg >= 1000) {
      return '${(weightKg / 1000).toStringAsFixed(1)} t';
    }
    return '${weightKg.toStringAsFixed(0)} kg';
  }
}

/// Card individual de métrica
class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gráfico circular (pie chart) de estado lleno/vacío
class _StatusPieChart extends StatelessWidget {
  final int fullCount;
  final int emptyCount;
  final int total;

  const _StatusPieChart({
    required this.fullCount,
    required this.emptyCount,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    if (total == 0) return const SizedBox.shrink();
    final fullPct = (fullCount / total * 100).toStringAsFixed(1);
    final emptyPct = (emptyCount / total * 100).toStringAsFixed(1);
    final unknownCount = total - fullCount - emptyCount;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Pie chart custom painted
            SizedBox(
              width: 120,
              height: 120,
              child: CustomPaint(
                painter: _PieChartPainter(
                  segments: [
                    _PieSegment(fullCount / total, Colors.green.shade600),
                    _PieSegment(emptyCount / total, Colors.orange.shade600),
                    if (unknownCount > 0)
                      _PieSegment(unknownCount / total, Colors.grey.shade400),
                  ],
                ),
                child: Center(
                  child: Text(
                    '$total',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 24),
            // Leyenda
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LegendItem(
                    color: Colors.green.shade600,
                    label: 'Llenos',
                    value: '$fullCount ($fullPct%)',
                  ),
                  const SizedBox(height: 8),
                  _LegendItem(
                    color: Colors.orange.shade600,
                    label: 'Vacíos',
                    value: '$emptyCount ($emptyPct%)',
                  ),
                  if (unknownCount > 0) ...[
                    const SizedBox(height: 8),
                    _LegendItem(
                      color: Colors.grey.shade400,
                      label: 'Sin estado',
                      value: '$unknownCount',
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Item de leyenda
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

/// Barra de distribución por tamaño (20ft / 40ft / 45ft)
class _SizeDistributionBar extends StatelessWidget {
  final SpecialCargoStats specialCargo;
  final int total;

  const _SizeDistributionBar({required this.specialCargo, required this.total});

  @override
  Widget build(BuildContext context) {
    if (total == 0) return const SizedBox.shrink();

    final items = <_SizeItem>[
      _SizeItem("20'", specialCargo.twentyFtCount, Colors.blue.shade600),
      _SizeItem("40'", specialCargo.fortyFtCount, Colors.indigo.shade600),
      _SizeItem("45'", specialCargo.fortyFiveFtCount, Colors.purple.shade600),
    ];
    final other = total - specialCargo.twentyFtCount - specialCargo.fortyFtCount - specialCargo.fortyFiveFtCount;
    if (other > 0) {
      items.add(_SizeItem('Otro', other, Colors.grey.shade500));
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Barra proporcional
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 28,
                child: Row(
                  children: items
                      .where((i) => i.count > 0)
                      .map((item) => Expanded(
                            flex: item.count,
                            child: Container(
                              color: item.color,
                              alignment: Alignment.center,
                              child: item.count / total > 0.08
                                  ? Text(
                                      '${item.count}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    )
                                  : null,
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Leyenda
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: items.map((item) {
                final pct = (item.count / total * 100).toStringAsFixed(1);
                return _LegendItem(
                  color: item.color,
                  label: item.label,
                  value: '${item.count} ($pct%)',
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SizeItem {
  final String label;
  final int count;
  final Color color;
  const _SizeItem(this.label, this.count, this.color);
}

/// Cards de carga especial (Reefer, IMO, OOG)
class _SpecialCargoCards extends StatelessWidget {
  final SpecialCargoStats specialCargo;

  const _SpecialCargoCards({required this.specialCargo});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (specialCargo.reeferCount > 0)
          Expanded(
            child: _SpecialCard(
              icon: Icons.ac_unit,
              label: 'Reefer',
              count: specialCargo.reeferCount,
              color: Colors.cyan,
            ),
          ),
        if (specialCargo.reeferCount > 0 && specialCargo.dangerousCount > 0)
          const SizedBox(width: 12),
        if (specialCargo.dangerousCount > 0)
          Expanded(
            child: _SpecialCard(
              icon: Icons.warning_amber,
              label: 'IMO / DG',
              count: specialCargo.dangerousCount,
              color: Colors.red,
            ),
          ),
        if ((specialCargo.reeferCount > 0 || specialCargo.dangerousCount > 0) && specialCargo.oogCount > 0)
          const SizedBox(width: 12),
        if (specialCargo.oogCount > 0)
          Expanded(
            child: _SpecialCard(
              icon: Icons.open_in_full,
              label: 'OOG',
              count: specialCargo.oogCount,
              color: Colors.deepOrange,
            ),
          ),
      ],
    );
  }
}

class _SpecialCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _SpecialCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gráfico de barras horizontales genérico (para navieras, puertos, etc.)
class _HorizontalBarChart extends StatelessWidget {
  final Map<String, int> data;
  final int maxItems;
  final Color color;
  final int total;

  const _HorizontalBarChart({
    required this.data,
    required this.maxItems,
    required this.color,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final entries = data.entries.take(maxItems).toList();
    final maxValue = entries.first.value.toDouble();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            for (int i = 0; i < entries.length; i++) ...[
              _BarRow(
                label: entries[i].key,
                value: entries[i].value,
                maxValue: maxValue,
                total: total,
                color: color.withOpacity(1.0 - (i * 0.06).clamp(0.0, 0.5)),
              ),
              if (i < entries.length - 1) const SizedBox(height: 8),
            ],
            if (data.length > maxItems) ...[
              const SizedBox(height: 8),
              Text(
                '+ ${data.length - maxItems} más',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final int value;
  final double maxValue;
  final int total;
  final Color color;

  const _BarRow({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (value / total * 100).toStringAsFixed(1);
    final fraction = maxValue > 0 ? value / maxValue : 0.0;

    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 20,
              backgroundColor: color.withOpacity(0.08),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 70,
          child: Text(
            '$value ($pct%)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

/// Gráfico de barras verticales para ocupación por bahía
class _BayOccupancyChart extends StatelessWidget {
  final List<BayStat> bayStats;

  const _BayOccupancyChart({required this.bayStats});

  @override
  Widget build(BuildContext context) {
    final maxContainers = bayStats.fold<int>(0, (m, b) => max(m, b.containerCount));

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 180,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Eje Y labels
              SizedBox(
                width: 30,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('$maxContainers', style: _axisStyle(context)),
                    Text('${(maxContainers / 2).round()}', style: _axisStyle(context)),
                    Text('0', style: _axisStyle(context)),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              // Barras
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: bayStats.map((stat) {
                      final height = maxContainers > 0
                          ? (stat.containerCount / maxContainers) * 150
                          : 0.0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${stat.containerCount}',
                              style: _axisStyle(context)?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              width: 22,
                              height: max(height, 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade600,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(3),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            RotatedBox(
                              quarterTurns: -1,
                              child: Text(
                                '${stat.bayNumber}',
                                style: _axisStyle(context),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle? _axisStyle(BuildContext context) =>
      Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 9);
}

/// Gráfico de barras verticales para peso por bahía
class _BayWeightChart extends StatelessWidget {
  final List<BayStat> bayStats;

  const _BayWeightChart({required this.bayStats});

  @override
  Widget build(BuildContext context) {
    final maxWeight = bayStats.fold<double>(0, (m, b) => max(m, b.totalWeight));
    final maxTons = maxWeight / 1000;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 180,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Eje Y labels
              SizedBox(
                width: 36,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${maxTons.toStringAsFixed(0)}t', style: _axisStyle(context)),
                    Text('${(maxTons / 2).toStringAsFixed(0)}t', style: _axisStyle(context)),
                    Text('0', style: _axisStyle(context)),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              // Barras
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: bayStats.map((stat) {
                      final height = maxWeight > 0
                          ? (stat.totalWeight / maxWeight) * 150
                          : 0.0;
                      final tons = stat.totalWeight / 1000;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              tons >= 1 ? '${tons.toStringAsFixed(0)}' : '',
                              style: _axisStyle(context)?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              width: 22,
                              height: max(height, 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade700,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(3),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            RotatedBox(
                              quarterTurns: -1,
                              child: Text(
                                '${stat.bayNumber}',
                                style: _axisStyle(context),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle? _axisStyle(BuildContext context) =>
      Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 9);
}

// ============================================
// CUSTOM PAINTERS
// ============================================

class _PieSegment {
  final double fraction;
  final Color color;
  const _PieSegment(this.fraction, this.color);
}

class _PieChartPainter extends CustomPainter {
  final List<_PieSegment> segments;

  _PieChartPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    const strokeWidth = 20.0;
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    double startAngle = -pi / 2; // Empezar desde arriba

    for (final segment in segments) {
      if (segment.fraction <= 0) continue;
      final sweepAngle = segment.fraction * 2 * pi;
      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) =>
      oldDelegate.segments != segments;
}
