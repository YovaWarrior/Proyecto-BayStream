import 'package:flutter/material.dart';

/// La paleta de la dirección C, «Puente de mando» (`DESIGN.md`, 13.1): el día
/// de la Fase 2 (4.1) y la noche de 10.14.
///
/// Son los colores con nombre y sus derivados, en claro y en oscuro. Es la
/// **única** fuente de hexadecimales de la capa de presentación: todo lo demás
/// los toma del [ColorScheme] del tema o de la extensión semántica.
///
/// Entre el día y la noche cambia la luminosidad, no el tono, salvo en la
/// marca: de noche el azul del ícono no llega a 3:1 sobre la noche como texto,
/// así que pasa a ser superficie ([marcaTenue] y [marcaSuperficie], con texto
/// blanco a 8.6:1) y el texto y la selección van en el azul de selección
/// ([marca]). Cada par de texto y fondo está verificado con
/// `tool/rediseno_contraste.py` (`docs/rediseno/fase2bis/contraste.md`): AA
/// 4.5:1 para el texto y 3:1 para los bordes esenciales.
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
    required this.tintaTenue,
    required this.linea,
    required this.lineaFuerte,
    required this.marca,
    required this.sobreMarca,
    required this.marcaTenue,
    required this.marcaSuperficie,
    required this.sobreMarcaSuperficie,
    required this.sobreMarcaSuave,
    required this.marcaProfunda,
    required this.acero,
    required this.aceroTenue,
    required this.sobreAcero,
    required this.grua,
    required this.gruaRelleno,
    required this.sobreGrua,
  });

  /// Claro u oscuro.
  final Brightness brillo;

  /// El fondo de la app: el papel de día, la noche de noche (con la rejilla de
  /// plano al 5 % de acero, que pinta `BsFondoDePlano`).
  final Color papel;

  /// Las superficies que se apoyan en el papel: tarjetas, hojas, paneles.
  final Color hoja;

  /// Una superficie por encima de la hoja: la fila activa, los chips de
  /// estado, la celda de paso de noche.
  final Color hojaAlta;

  /// Texto, iconos y bordes fuertes.
  final Color tinta;

  /// Texto secundario: metadatos, ayudas, rótulos.
  final Color tintaSuave;

  /// Texto terciario: el momento de un evento, el detalle de una tarjeta, los
  /// números de bahía no seleccionados.
  final Color tintaTenue;

  /// Separadores y la pista de las barras de avance, sin exigencia de
  /// contraste.
  final Color linea;

  /// Bordes esenciales, como el contorno de una celda o el casco (3:1 sobre el
  /// papel, la hoja, la hoja alta y el acero tenue).
  final Color lineaFuerte;

  /// La acción principal, el foco y la selección de celda y de bahía, como
  /// texto o como icono: la semilla del ícono de día, el azul de selección de
  /// noche.
  final Color marca;

  /// Texto sobre [marca].
  final Color sobreMarca;

  /// De día, el tinte de marca (chip seleccionado, indicador del riel); de
  /// noche, la marca como superficie (el riel activo, el chip seleccionado, el
  /// botón tonal), con texto en [tinta].
  final Color marcaTenue;

  /// La marca como superficie en los dos modos: la banda del muelle y el
  /// recuadro del ícono. Texto encima: [sobreMarcaSuperficie] y
  /// [sobreMarcaSuave].
  final Color marcaSuperficie;

  /// Texto blanco sobre [marcaSuperficie] (8.6:1).
  final Color sobreMarcaSuperficie;

  /// Texto secundario sobre [marcaSuperficie]: la frase de la banda (5.6:1).
  final Color sobreMarcaSuave;

  /// Un azul más profundo dentro de la banda: el chip de la nube (blanco
  /// encima, 10.7:1).
  final Color marcaProfunda;

  /// La bodega del ícono: por bajar en bodega, el segundo plano de la silueta.
  final Color acero;

  /// Relleno tenue de acero: la zona de bodega de la rejilla y el casco.
  final Color aceroTenue;

  /// Texto sobre [acero]: siempre tinta oscura, en los dos modos.
  final Color sobreAcero;

  /// Texto e iconos naranja: lo que se acaba de mover.
  final Color grua;

  /// Relleno naranja: solo la celda que se acaba de mover y el contenedor del
  /// ícono.
  final Color gruaRelleno;

  /// Texto sobre [gruaRelleno]: siempre tinta oscura, en los dos modos.
  final Color sobreGrua;

  /// La paleta del día (el muelle): la de la Fase 2, sin cambios.
  static const BsPaleta claro = BsPaleta(
    brillo: Brightness.light,
    papel: Color(0xFFF5F8FC),
    hoja: Color(0xFFFFFFFF),
    hojaAlta: Color(0xFFE9EFF7),
    tinta: Color(0xFF10243F),
    tintaSuave: Color(0xFF4A5B73),
    tintaTenue: Color(0xFF566986),
    linea: Color(0xFFC9D3E0),
    lineaFuerte: Color(0xFF6D809F),
    marca: Color(0xFF0D47A1),
    sobreMarca: Color(0xFFFFFFFF),
    marcaTenue: Color(0xFFDCE7F8),
    marcaSuperficie: Color(0xFF0D47A1),
    sobreMarcaSuperficie: Color(0xFFFFFFFF),
    sobreMarcaSuave: Color(0xFFBCD2F7),
    marcaProfunda: Color(0xFF0A3A85),
    acero: Color(0xFF6E9DE6),
    aceroTenue: Color(0xFFE3EDFB),
    sobreAcero: Color(0xFF10243F),
    grua: Color(0xFFC2410C),
    gruaRelleno: Color(0xFFFF7A1A),
    sobreGrua: Color(0xFF10243F),
  );

  /// La paleta de la noche (la oficina), de 10.14.
  static const BsPaleta oscuro = BsPaleta(
    brillo: Brightness.dark,
    papel: Color(0xFF07111F),
    hoja: Color(0xFF0C1A31),
    hojaAlta: Color(0xFF11223F),
    tinta: Color(0xFFEAF0F9),
    tintaSuave: Color(0xFFA9B9D2),
    tintaTenue: Color(0xFF8DA0BE),
    linea: Color(0xFF1E3457),
    lineaFuerte: Color(0xFF5272A6),
    marca: Color(0xFF4F8EF7),
    sobreMarca: Color(0xFF07111F),
    marcaTenue: Color(0xFF0D47A1),
    marcaSuperficie: Color(0xFF0D47A1),
    sobreMarcaSuperficie: Color(0xFFFFFFFF),
    sobreMarcaSuave: Color(0xFFBCD2F7),
    marcaProfunda: Color(0xFF0A3A85),
    acero: Color(0xFF6E9DE6),
    aceroTenue: Color(0xFF11213A),
    sobreAcero: Color(0xFF07111F),
    grua: Color(0xFFFF9A4D),
    gruaRelleno: Color(0xFFFF7A1A),
    sobreGrua: Color(0xFF07111F),
  );

  /// La paleta que corresponde a un brillo.
  static BsPaleta de(Brightness brillo) =>
      brillo == Brightness.dark ? oscuro : claro;
}
