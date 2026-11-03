import 'package:flutter/material.dart';

/// Las duraciones y curvas del sistema (`DESIGN.md`, 4.5 y 13.3).
///
/// Solo se animan `Transform` y `opacity`, nunca anchos, altos ni márgenes. Lo
/// que se repite cien veces por turno (cambiar de bahía en el muelle, marcar
/// una celda) no se anima. Si el sistema pide reducir el movimiento, [de]
/// devuelve cero, [reducido] es verdadero y nada se mueve: lo que animaba se
/// dibuja quieto en su estado final.
abstract final class BsMovimiento {
  /// Pulsación de un control.
  static const Duration pulsacion = Duration(milliseconds: 150);

  /// Chips y segmentos.
  static const Duration seleccion = Duration(milliseconds: 150);

  /// La celda recién movida sale de su sitio (13.3).
  static const Duration salida = Duration(milliseconds: 150);

  /// Hojas y diálogos.
  static const Duration hoja = Duration(milliseconds: 220);

  /// El fundido al cambiar de bahía en la oficina.
  static const Duration bahia = Duration(milliseconds: 120);

  /// Un paso de la rueda del mouse en un desplazable horizontal: la silueta
  /// avanza o regresa (T-119, `DESIGN.md` 16.1).
  static const Duration rueda = Duration(milliseconds: 100);

  /// El único momento orquestado: la rejilla «asienta» al abrir un plano.
  static const Duration asentar = Duration(milliseconds: 250);

  /// Cuánto dura el naranja de lo que se acaba de mover, en la celda y en el
  /// destello de la silueta (13.3). La pantalla apaga el estado al cumplirse.
  static const Duration recienMovido = Duration(milliseconds: 1500);

  /// El bucle de la espera: el contenedor de la marca sube y baja (13.6).
  static const Duration espera = Duration(milliseconds: 1200);

  /// El pulso del punto de «Al día» y de «En vivo» (13.6).
  static const Duration pulso = Duration(milliseconds: 2200);

  /// Cuánto dura un aviso con «Deshacer».
  static const Duration aviso = Duration(seconds: 6);

  /// La curva de lo que entra.
  static const Curve entrada = Curves.easeOutCubic;

  /// La curva de lo que se mueve en pantalla.
  static const Curve movimiento = Curves.easeInOutCubic;

  /// La curva de lo que va y vuelve en bucle (la espera, el pulso).
  static const Curve vaiven = Curves.easeInOut;

  /// Verdadero si el sistema pide reducir el movimiento
  /// (`MediaQuery.disableAnimations`).
  static bool reducido(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);

  /// [duracion], o cero si el sistema pide reducir el movimiento.
  static Duration de(BuildContext context, Duration duracion) =>
      reducido(context) ? Duration.zero : duracion;
}
