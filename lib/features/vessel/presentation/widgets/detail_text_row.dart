import 'package:flutter/material.dart';

/// Etiqueta y valor completos, también en un detalle estrecho con letra grande.
class DetailTextRow extends StatelessWidget {
  final String label;
  final String value;
  final double verticalPadding;
  const DetailTextRow(
      {super.key,
      required this.label,
      required this.value,
      this.verticalPadding = 6});

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(vertical: verticalPadding),
        child: LayoutBuilder(builder: (context, constraints) {
          final theme = Theme.of(context);
          final caption = Text(label,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant));
          final content = Text(value,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600));
          if (constraints.maxWidth < 360 ||
              MediaQuery.textScalerOf(context).scale(14) > 20) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [caption, const SizedBox(height: 4), content]);
          }
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: caption),
            const SizedBox(width: 12),
            Expanded(child: content),
          ]);
        }),
      );
}
