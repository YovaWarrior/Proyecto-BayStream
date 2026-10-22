import 'package:flutter/material.dart';

/// La paleta de la dirección A, «Plano de a bordo» (`DESIGN.md`, sección 4.1).
///
/// Son los seis colores con nombre y sus derivados, en claro y en oscuro. Es la
/// **única** fuente de hexadecimales de la capa de presentación: todo lo demás
/// los toma del [ColorScheme] del tema o de la extensión semántica.
///
/// Entre claro y oscuro cambia la luminosidad, no el tono. Cada par de texto y
/// fondo está verificado con `tool/rediseno_contraste.py`
/// (`docs/rediseno/fase2/contraste.md`): AA 4.5:1 para el texto y 3:1 para los
/// bordes esenciales.
@immutable
class BsPaleta {
  /// Crea una paleta. En el producto solo existen [claro] y [oscuro].
  const BsPaleta({
    required this.brillo,
    required this.papel,
    required this.hoja,
    required this.hojaAlta,
    required this.tinta,
    required this.tintaSuave,
    required this.linea,
    required this.lineaFuerte,
    required this.marca,
    required this.sobreMarca,
    required this.marcaTenue,
    required this.acero,
    required this.aceroTenue,
    required this.sobreAcero,
    required this.grua,
    required this.gruaRelleno,
    required this.sobreGrua,
  });

  /// Claro u oscuro.
  final Brightness brillo;

  /// El fondo de la app: las celdas de cubierta del ícono.
  final Color papel;

  /// Las superficies que se apoyan en el papel: tarjetas, hojas, paneles.
  final Color hoja;

  /// Una superficie por encima de la hoja: la barra de operación, la fila activa.
  final Color hojaAlta;

  /// Texto, iconos y bordes fuertes.
  final Color tinta;

  /// Texto secundario: metadatos, ayudas, rótulos.
  final Color tintaSuave;

  /// Separadores, sin exigencia de contraste.
  final Color linea;

  /// Bordes esenciales, como el contorno de una celda (3:1 sobre el papel).
  final Color lineaFuerte;

  /// La acción principal, la selección y el destino activo: la semilla del ícono.
  final Color marca;

  /// Texto sobre [marca].
  final Color sobreMarca;

  /// Relleno tenue de marca: chips seleccionados, bandas de información.
  final Color marcaTenue;

  /// La bodega del ícono: la zona inferior del plano, el segundo plano.
  final Color acero;

  /// Relleno tenue de acero: la zona de bodega de la rejilla.
  final Color aceroTenue;

  /// Texto sobre [acero]: siempre tinta oscura, en los dos modos.
  final Color sobreAcero;

  /// Texto e iconos naranja: lo que se mueve o espera una decisión.
  final Color grua;

  /// Relleno naranja: la celda en movimiento, la marca de «sin confirmar».
  final Color gruaRelleno;

  /// Texto sobre [gruaRelleno]: siempre tinta oscura, en los dos modos.
  final Color sobreGrua;

  /// La paleta del modo claro.
  static const BsPaleta claro = BsPaleta(
    brillo: Brightness.light,
    papel: Color(0xFFF5F8FC),
    hoja: Color(0xFFFFFFFF),
    hojaAlta: Color(0xFFE9EFF7),
    tinta: Color(0xFF10243F),
    tintaSuave: Color(0xFF4A5B73),
    linea: Color(0xFFC9D3E0),
    lineaFuerte: Color(0xFF7A8DA6),
    marca: Color(0xFF0D47A1),
    sobreMarca: Color(0xFFFFFFFF),
    marcaTenue: Color(0xFFDCE7F8),
    acero: Color(0xFF6E9DE6),
    aceroTenue: Color(0xFFE3EDFB),
    sobreAcero: Color(0xFF10243F),
    grua: Color(0xFFC2410C),
    gruaRelleno: Color(0xFFFF7A1A),
    sobreGrua: Color(0xFF10243F),
  );

  /// La paleta del modo oscuro.
  static const BsPaleta oscuro = BsPaleta(
    brillo: Brightness.dark,
    papel: Color(0xFF0B1626),
    hoja: Color(0xFF13223A),
    hojaAlta: Color(0xFF1B2D4A),
    tinta: Color(0xFFE6EEF8),
    tintaSuave: Color(0xFFA9B8CC),
    linea: Color(0xFF2E4260),
    lineaFuerte: Color(0xFF5C7392),
    marca: Color(0xFF8FB4F2),
    sobreMarca: Color(0xFF0B1626),
    marcaTenue: Color(0xFF1E3A66),
    acero: Color(0xFF6E9DE6),
    aceroTenue: Color(0xFF1C2F4D),
    sobreAcero: Color(0xFF0B1626),
    grua: Color(0xFFFF9A4D),
    gruaRelleno: Color(0xFFFF7A1A),
    sobreGrua: Color(0xFF0B1626),
  );

  /// La paleta que corresponde a un brillo.
  static BsPaleta de(Brightness brillo) =>
      brillo == Brightness.dark ? oscuro : claro;
}
