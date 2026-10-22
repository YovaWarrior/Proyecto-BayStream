import 'package:flutter/material.dart';

import '../bs_colores_semanticos.dart';
import '../bs_medidas.dart';

/// El casco que cierra la bodega (`DESIGN.md`, 13.2): detrás de las filas de
/// bodega, los costados que bajan rectos desde la tapa y el fondo que se curva
/// hacia la quilla, con el relleno de la zona de bodega y el contorno en línea
/// fuerte de 1.5 dp. Las celdas de los extremos llevan la misma curva en su
/// esquina (`BsCelda.curva`).
class BsCascoBodega extends StatelessWidget {
  /// Crea el casco alrededor de [child].
  const BsCascoBodega({super.key, required this.child, this.radio = 48});

  /// Las filas de bodega.
  final Widget child;

  /// El radio de la curva del fondo; se recorta a la mitad del ancho y al alto.
  final double radio;

  /// El grosor del contorno.
  static const double grosor = 1.5;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final semanticos = BsColoresSemanticos.de(context);
    final medidas = BsMedidas.de(context);
    return RepaintBoundary(
      child: CustomPaint(
        painter: _CascoPainter(
          relleno: semanticos.bodega.relleno,
          contorno: esquema.outline,
          radio: radio,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            medidas.espacioS,
            0,
            medidas.espacioS,
            medidas.espacioM,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _CascoPainter extends CustomPainter {
  const _CascoPainter({
    required this.relleno,
    required this.contorno,
    required this.radio,
  });

  final Color relleno;
  final Color contorno;
  final double radio;

  @override
  void paint(Canvas canvas, Size size) {
    const medio = BsCascoBodega.grosor / 2;
    final r = radio.clamp(0.0, size.shortestSide / 2).toDouble();
    final casco = Path()
      ..moveTo(medio, 0)
      ..lineTo(medio, size.height - r)
      ..quadraticBezierTo(medio, size.height - medio, r, size.height - medio)
      ..lineTo(size.width - r, size.height - medio)
      ..quadraticBezierTo(
          size.width - medio, size.height - medio, size.width - medio, size.height - r)
      ..lineTo(size.width - medio, 0);
    canvas.drawPath(casco, Paint()..color = relleno);
    canvas.drawPath(
      casco,
      Paint()
        ..color = contorno
        ..style = PaintingStyle.stroke
        ..strokeWidth = BsCascoBodega.grosor
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_CascoPainter anterior) =>
      anterior.relleno != relleno ||
      anterior.contorno != contorno ||
      anterior.radio != radio;
}
