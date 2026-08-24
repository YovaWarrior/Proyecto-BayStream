import 'dart:math';

import 'package:flutter/material.dart';

import '../../domain/entities/entities.dart';

/// Magnitud representada por el perfil longitudinal del buque.
enum VesselProfileMetric { occupancy, weight }

/// Vista panorámica de todas las bahías, ordenadas de proa a popa.
class VesselProfileView extends StatefulWidget {
  final VesselVoyage voyage;

  const VesselProfileView({super.key, required this.voyage});

  @override
  State<VesselProfileView> createState() => _VesselProfileViewState();
}

class _VesselProfileViewState extends State<VesselProfileView> {
  static const _cellWidth = 54.0;
  static const _cellGap = 6.0;
  static const _sidePadding = 36.0;
  static const _profileHeight = 132.0;

  VesselProfileMetric _metric = VesselProfileMetric.occupancy;

  @override
  Widget build(BuildContext context) {
    final bays = widget.voyage.bays.values.toList()
      ..sort((a, b) => a.bayNumber.compareTo(b.bayNumber));

    if (bays.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('No hay bahías para mostrar')),
        ),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final baseColor = _metric == VesselProfileMetric.occupancy
        ? colorScheme.primary
        : colorScheme.tertiary;
    final lowColor = Color.alphaBlend(
      baseColor.withValues(alpha: 0.12),
      colorScheme.surfaceContainerHighest,
    );
    final maxWeight = bays.fold<double>(
      0,
      (maximum, bay) => max(maximum, bay.totalWeight),
    );

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bahías ordenadas de proa a popa',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<VesselProfileMetric>(
              segments: const [
                ButtonSegment(
                  value: VesselProfileMetric.occupancy,
                  icon: Icon(Icons.grid_view),
                  label: Text('Ocupación'),
                ),
                ButtonSegment(
                  value: VesselProfileMetric.weight,
                  icon: Icon(Icons.scale),
                  label: Text('Peso'),
                ),
              ],
              selected: {_metric},
              showSelectedIcon: false,
              onSelectionChanged: (selection) {
                setState(() => _metric = selection.first);
              },
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final cellsWidth =
                    bays.length * _cellWidth + (bays.length - 1) * _cellGap;
                final profileWidth = max(
                  constraints.maxWidth,
                  cellsWidth + _sidePadding * 2,
                );

                return SizedBox(
                  height: _profileHeight,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Semantics(
                      label: _semanticsLabel(bays, maxWeight),
                      child: CustomPaint(
                        size: Size(profileWidth, _profileHeight),
                        painter: VesselProfilePainter(
                          bays: bays,
                          metric: _metric,
                          baseColor: baseColor,
                          lowColor: lowColor,
                          outlineColor: colorScheme.outlineVariant,
                          textColor: colorScheme.onSurface,
                          guideColor: colorScheme.onSurfaceVariant,
                          maxWeight: maxWeight,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            _ProfileLegend(
              metric: _metric,
              lowColor: lowColor,
              highColor: baseColor,
              maxWeight: maxWeight,
            ),
          ],
        ),
      ),
    );
  }

  String _semanticsLabel(List<Bay> bays, double maxWeight) {
    final metricLabel =
        _metric == VesselProfileMetric.occupancy ? 'ocupación' : 'peso';
    final maximumLabel = _metric == VesselProfileMetric.occupancy
        ? 'cien por ciento'
        : '${(maxWeight / 1000).toStringAsFixed(1)} toneladas';
    return 'Perfil longitudinal con ${bays.length} bahías. '
        'Modo $metricLabel, escala de cero a $maximumLabel.';
  }
}

/// Leyenda monocromática de la magnitud seleccionada.
class _ProfileLegend extends StatelessWidget {
  final VesselProfileMetric metric;
  final Color lowColor;
  final Color highColor;
  final double maxWeight;

  const _ProfileLegend({
    required this.metric,
    required this.lowColor,
    required this.highColor,
    required this.maxWeight,
  });

  @override
  Widget build(BuildContext context) {
    final isOccupancy = metric == VesselProfileMetric.occupancy;
    final endLabel =
        isOccupancy ? '100 %' : '${(maxWeight / 1000).toStringAsFixed(1)} t';

    return Row(
      children: [
        Text(
          isOccupancy ? 'Ocupación' : 'Peso',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(width: 12),
        Text('0', style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(width: 6),
        Expanded(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 220),
            height: 12,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              gradient: LinearGradient(colors: [lowColor, highColor]),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(endLabel, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

/// Dibuja una celda por bahía sobre una vista lateral simplificada del buque.
class VesselProfilePainter extends CustomPainter {
  static const _cellWidth = 54.0;
  static const _cellGap = 6.0;
  static const _sidePadding = 36.0;
  static const _cellTop = 27.0;
  static const _cellHeight = 68.0;

  final List<Bay> bays;
  final VesselProfileMetric metric;
  final Color baseColor;
  final Color lowColor;
  final Color outlineColor;
  final Color textColor;
  final Color guideColor;
  final double maxWeight;

  const VesselProfilePainter({
    required this.bays,
    required this.metric,
    required this.baseColor,
    required this.lowColor,
    required this.outlineColor,
    required this.textColor,
    required this.guideColor,
    required this.maxWeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _paintDirectionLabels(canvas, size);

    final hullPaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final hullPath = Path()
      ..moveTo(8, _cellTop + _cellHeight - 12)
      ..quadraticBezierTo(
          16, _cellTop + _cellHeight, 34, _cellTop + _cellHeight)
      ..lineTo(size.width - 20, _cellTop + _cellHeight)
      ..quadraticBezierTo(
        size.width - 8,
        _cellTop + _cellHeight - 8,
        size.width - 8,
        _cellTop + 8,
      );
    canvas.drawPath(hullPath, hullPaint);

    for (var index = 0; index < bays.length; index++) {
      final bay = bays[index];
      final left = _sidePadding + index * (_cellWidth + _cellGap);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, _cellTop, _cellWidth, _cellHeight),
        const Radius.circular(5),
      );
      final normalizedValue = _normalizedValue(bay);
      final fillColor = Color.lerp(lowColor, baseColor, normalizedValue)!;

      canvas.drawRRect(rect, Paint()..color = fillColor);
      canvas.drawRRect(
        rect,
        Paint()
          ..color = outlineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );

      _paintCenteredText(
        canvas,
        _valueLabel(bay),
        Offset(left + _cellWidth / 2, _cellTop + 26),
        TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      );
      _paintCenteredText(
        canvas,
        'B${bay.bayNumberPadded}',
        Offset(left + _cellWidth / 2, _cellTop + _cellHeight + 14),
        TextStyle(color: guideColor, fontSize: 9),
      );
    }
  }

  double _normalizedValue(Bay bay) {
    if (metric == VesselProfileMetric.occupancy) {
      return (bay.occupancyRate / 100).clamp(0.0, 1.0);
    }
    if (maxWeight <= 0) return 0;
    return (bay.totalWeight / maxWeight).clamp(0.0, 1.0);
  }

  String _valueLabel(Bay bay) {
    if (metric == VesselProfileMetric.occupancy) {
      return '${bay.occupancyRate.toStringAsFixed(0)}%';
    }
    return '${(bay.totalWeight / 1000).toStringAsFixed(1)}t';
  }

  void _paintDirectionLabels(Canvas canvas, Size size) {
    _paintText(
      canvas,
      'PROA',
      const Offset(8, 2),
      TextStyle(color: guideColor, fontSize: 9, fontWeight: FontWeight.bold),
    );
    final popa = TextPainter(
      text: TextSpan(
        text: 'POPA',
        style: TextStyle(
          color: guideColor,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    popa.paint(canvas, Offset(size.width - popa.width - 8, 2));
  }

  void _paintCenteredText(
    Canvas canvas,
    String text,
    Offset center,
    TextStyle style,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: _cellWidth - 4);
    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );
  }

  void _paintText(
    Canvas canvas,
    String text,
    Offset offset,
    TextStyle style,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant VesselProfilePainter oldDelegate) {
    return oldDelegate.bays != bays ||
        oldDelegate.metric != metric ||
        oldDelegate.baseColor != baseColor ||
        oldDelegate.lowColor != lowColor ||
        oldDelegate.outlineColor != outlineColor ||
        oldDelegate.textColor != textColor ||
        oldDelegate.guideColor != guideColor ||
        oldDelegate.maxWeight != maxWeight;
  }
}
