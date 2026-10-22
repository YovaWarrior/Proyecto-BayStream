import 'package:flutter/material.dart';

import '../bs_medidas.dart';

/// El fondo de la oficina de noche (`DESIGN.md`, 13.1): la rejilla de plano,
/// líneas cada `BsMedidas.pasoRejilla` en acero al 5 % sobre la noche. De día
/// solo pinta el papel.
class BsFondoDePlano extends StatelessWidget {
  /// Crea el fondo.
  const BsFondoDePlano({super.key, required this.child});

  /// Lo que va encima.
  final Widget child;

  /// El alfa de las líneas.
  static const double alfa = 0.05;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final medidas = BsMedidas.de(context);
    final esquema = tema.colorScheme;
    final noche = tema.brightness == Brightness.dark;
    return ColoredBox(
      color: esquema.surface,
      child: noche
          ? RepaintBoundary(
              child: CustomPaint(
                painter: _RejillaPainter(
                  paso: medidas.pasoRejilla,
                  color: esquema.secondary.withValues(alpha: alfa),
                ),
                child: child,
              ),
            )
          : child,
    );
  }
}

class _RejillaPainter extends CustomPainter {
  const _RejillaPainter({required this.paso, required this.color});

  final double paso;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final pintura = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (var x = paso; x < size.width; x += paso) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), pintura);
    }
    for (var y = paso; y < size.height; y += paso) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), pintura);
    }
  }

  @override
  bool shouldRepaint(_RejillaPainter anterior) =>
      anterior.paso != paso || anterior.color != color;
}
