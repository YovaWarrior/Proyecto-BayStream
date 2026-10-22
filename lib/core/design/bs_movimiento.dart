import 'package:flutter/material.dart';

/// Las duraciones y curvas del sistema (`DESIGN.md`, sección 10).
///
/// Solo se animan `Transform` y `opacity`, nunca anchos, altos ni márgenes. Lo
/// que se repite cien veces por turno (cambiar de bahía en el muelle, marcar
/// una celda) no se anima. Si el sistema pide reducir el movimiento, [de]
/// devuelve cero y solo quedan los cambios de color y opacidad.
abstract final class BsMovimiento {
  /// Pulsación de un control.
  static const Duration pulsacion = Duration(milliseconds: 150);

  /// Chips y segmentos.
  static const Duration seleccion = Duration(milliseconds: 150);

  /// Hojas y diálogos.
  static const Duration hoja = Duration(milliseconds: 220);

  /// El fundido al cambiar de bahía en la oficina.
  static const Duration bahia = Duration(milliseconds: 120);

  /// El único momento orquestado: la rejilla «asienta» al abrir un plano.
  static const Duration asentar = Duration(milliseconds: 250);

  /// Cuánto dura un aviso con «Deshacer».
  static const Duration aviso = Duration(seconds: 6);

  /// La curva de lo que entra.
  static const Curve entrada = Curves.easeOutCubic;

  /// La curva de lo que se mueve en pantalla.
  static const Curve movimiento = Curves.easeInOutCubic;

  /// [duracion], o cero si el sistema pide reducir el movimiento.
  static Duration de(BuildContext context, Duration duracion) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : duracion;
}
