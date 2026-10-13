import 'package:flutter/material.dart';
import '../../domain/entities/hatch_covers.dart';

/// Contornos por tapa y fila; una franja por tapa permite leer conjuntos no contiguos.
/// En el plano se usa el ancho de sus columnas; la vista compacta cabe a 360 dp.
class HatchCoverDiagram extends StatelessWidget {
  final HatchCoverDeclaration? declaration;
  final List<int> rows;
  final double? columnWidth;
  const HatchCoverDiagram(
      {super.key,
      required this.declaration,
      required this.rows,
      this.columnWidth});
  @override
  Widget build(BuildContext context) {
    final d = declaration;
    if (d == null) {
      return const Text('Tapas: sin declarar',
          key: ValueKey('hatch-undeclared'));
    }
    if (d.kind == HatchCoverKind.openHold) {
      return const Text('Sin tapa · bodega abierta');
    }
    final colors = Theme.of(context).colorScheme;
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(d.kind == HatchCoverKind.automatic
              ? 'Una tapa automática'
              : '${d.covers.length} tapas de grúa'),
          for (var i = 0; i < d.covers.length; i++) ...[
            Text(
                'T${i + 1} · filas ${rows.where(d.covers[i].contains).map((r) => r.toString().padLeft(2, '0')).join(', ')}'),
            Row(
                mainAxisSize:
                    columnWidth == null ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  for (final row in rows)
                    if (columnWidth == null)
                      Expanded(
                          child:
                              _cell(colors, row, i, d.covers[i].contains(row)))
                    else
                      SizedBox(
                          width: columnWidth,
                          child:
                              _cell(colors, row, i, d.covers[i].contains(row))),
                ]),
            const SizedBox(height: 4),
          ],
        ]);
  }

  Widget _cell(ColorScheme colors, int row, int cover, bool covered) =>
      Container(
          key: ValueKey('hatch-outline-$cover-$row'),
          height: 28,
          decoration: covered
              ? BoxDecoration(
                  color:
                      colors.onSurface.withValues(alpha: 0.05 + cover * 0.07),
                  border: Border(
                      top: BorderSide(color: colors.onSurface, width: 2),
                      bottom: BorderSide(color: colors.onSurface, width: 2),
                      left: BorderSide(color: colors.onSurface),
                      right: BorderSide(color: colors.onSurface)))
              : null,
          alignment: Alignment.center,
          child: covered
              ? Text(row.toString().padLeft(2, '0'),
                  style: TextStyle(fontSize: 10, color: colors.onSurface))
              : null);
}
