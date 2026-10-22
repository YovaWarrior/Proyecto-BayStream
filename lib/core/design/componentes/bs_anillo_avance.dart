import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../bs_colores_semanticos.dart';

/// El anillo de avance del mosaico de cifras (`DESIGN.md`, 13.6): la pista en
/// línea y el arco desde las doce, con los extremos redondeados, en el color
/// de hecho por omisión. Es un dato, no un movimiento: no se anima.
class BsAnilloAvance extends StatelessWidget {
  /// Crea el anillo.
  const BsAnilloAvance({
    super.key,
    required this.fraccion,
    this.tamano = 52,
    this.grosor = 9,
    this.color,
    this.etiqueta,
  });

  /// De 0 a 1.
  final double fraccion;

  /// El diámetro.
  final double tamano;

  /// El grosor del trazo.
  final double grosor;

  /// El color del arco; por omisión, el contorno del rol hecho.
  final Color? color;

  /// La etiqueta accesible; por omisión, «N por ciento».
  final String? etiqueta;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final semanticos = BsColoresSemanticos.de(context);
    final valor = fraccion.clamp(0.0, 1.0).toDouble();
    return Semantics(
      label: etiqueta ?? '${(valor * 100).round()} por ciento',
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: tamano,
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _AnilloPainter(
              fraccion: valor,
              grosor: grosor,
              pista: esquema.outlineVariant,
              arco: color ?? semanticos.hecho.contorno,
            ),
          ),
        ),
      ),
    );
  }
}

class _AnilloPainter extends CustomPainter {
  const _AnilloPainter({
    required this.fraccion,
    required this.grosor,
    required this.pista,
    required this.arco,
  });

  final double fraccion;
  final double grosor;
  final Color pista;
  final Color arco;

  @override
  void paint(Canvas canvas, Size size) {
    final centro = size.center(Offset.zero);
    final radio = (size.shortestSide - grosor) / 2;
    final rect = Rect.fromCircle(center: centro, radius: radio);
    canvas.drawCircle(
      centro,
      radio,
      Paint()
        ..color = pista
        ..style = PaintingStyle.stroke
        ..strokeWidth = grosor,
    );
    if (fraccion <= 0) return;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * fraccion,
      false,
      Paint()
        ..color = arco
        ..style = PaintingStyle.stroke
        ..strokeWidth = grosor
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_AnilloPainter anterior) =>
      anterior.fraccion != fraccion ||
      anterior.grosor != grosor ||
      anterior.pista != pista ||
      anterior.arco != arco;
}
