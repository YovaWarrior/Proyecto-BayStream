import 'package:flutter/material.dart';

import 'bs_paleta.dart';

/// Las familias tipográficas empaquetadas (`DESIGN.md`, sección 6; 10.4).
///
/// IBM Plex, SIL Open Font License 1.1, en `assets/fonts/plex/` con su
/// `LICENSE-IBMPlex.txt` y su `provenance.json`. Roboto, que ya estaba
/// empaquetada, queda de respaldo para cualquier glifo que falte.
abstract final class BsFuentes {
  /// La interfaz: IBM Plex Sans (Regular, Medium y SemiBold).
  static const String sans = 'IBM Plex Sans';

  /// El código de la celda del plano: IBM Plex Sans Condensed (Medium y
  /// SemiBold), para que «USHOU» quepa en 52 dp.
  static const String condensada = 'IBM Plex Sans Condensed';

  /// Números de contenedor y posiciones: IBM Plex Mono (Regular y Medium).
  static const String mono = 'IBM Plex Mono';

  /// El respaldo para lo que Plex no tenga.
  static const List<String> respaldo = <String>['Roboto'];
}

/// Los tamaños de letra del sistema: base 14, razón 1.2, redondeados.
///
/// Son los únicos tamaños de letra de la capa de presentación: todo
/// `fontSize` del producto sale de aquí a través del tema.
abstract final class BsEscala {
  /// KPI, contadores y totales.
  static const double cifraGrande = 34;

  /// El nombre del buque en el inicio.
  static const double titular = 28;

  /// El título de pantalla y la cabecera de bahía.
  static const double titulo = 22;

  /// Los títulos de bloque y de la cartela.
  static const double bloque = 16;

  /// El texto corriente.
  static const double cuerpo = 14;

  /// Metadatos y ayudas.
  static const double secundario = 12;

  /// Chips, pestañas, leyenda y rótulos de cifra.
  static const double rotulo = 12;

  /// El rótulo más pequeño del sistema (sobrelíneas).
  static const double rotuloMinimo = 11;

  /// Números de contenedor y posiciones en listas y detalle.
  static const double datoMono = 14;

  /// El código en la celda del plano, en condensada.
  static const double celda = 12;

  /// La segunda línea de la celda: peso o tipo.
  static const double celdaLinea2 = 10;
}

/// Las cifras siempre tabulares. Plex ya trae los dígitos de ancho fijo de
/// serie (comprobado en los anchos de la fuente al empaquetarla); el rasgo
/// se deja declarado como refuerzo para la fuente de respaldo.
const List<FontFeature> cifrasTabulares = <FontFeature>[
  FontFeature.tabularFigures(),
];

/// El [TextTheme] de la dirección A sobre una [BsPaleta].
///
/// La familia es [BsFuentes.sans]; el tema aplica además el respaldo. Los
/// roles de Material 3 se asignan así: `display` para cifras grandes,
/// `headline` para titulares, `title` para títulos de pantalla y de bloque,
/// `body` para el texto y `label` para rótulos y botones.
TextTheme bsTextTheme(BsPaleta paleta) {
  TextStyle estilo(double tamano, FontWeight peso, double altura,
          {Color? color, bool cifras = false}) =>
      TextStyle(
        fontFamily: BsFuentes.sans,
        fontFamilyFallback: BsFuentes.respaldo,
        fontSize: tamano,
        fontWeight: peso,
        height: altura,
        color: color ?? paleta.tinta,
        fontFeatures: cifras ? cifrasTabulares : null,
      );
  return TextTheme(
    displayLarge:
        estilo(BsEscala.cifraGrande, FontWeight.w600, 1.1, cifras: true),
    displayMedium: estilo(BsEscala.titular, FontWeight.w600, 1.2),
    displaySmall: estilo(BsEscala.titulo, FontWeight.w600, 1.25),
    headlineLarge: estilo(BsEscala.titular, FontWeight.w600, 1.2),
    headlineMedium: estilo(BsEscala.titulo, FontWeight.w600, 1.25),
    headlineSmall: estilo(BsEscala.bloque, FontWeight.w600, 1.3),
    titleLarge: estilo(BsEscala.titulo, FontWeight.w600, 1.25),
    titleMedium: estilo(BsEscala.bloque, FontWeight.w600, 1.3),
    titleSmall: estilo(BsEscala.cuerpo, FontWeight.w600, 1.4),
    bodyLarge: estilo(BsEscala.bloque, FontWeight.w400, 1.5),
    bodyMedium: estilo(BsEscala.cuerpo, FontWeight.w400, 1.5),
    bodySmall: estilo(BsEscala.secundario, FontWeight.w400, 1.4,
        color: paleta.tintaSuave),
    labelLarge: estilo(BsEscala.cuerpo, FontWeight.w500, 1.2),
    labelMedium: estilo(BsEscala.rotulo, FontWeight.w500, 1.2),
    labelSmall: estilo(BsEscala.rotuloMinimo, FontWeight.w500, 1.2,
        color: paleta.tintaSuave),
  );
}

/// Los estilos de texto propios del plano que no caben en los roles de
/// Material: cifras grandes, datos en mono y el texto de la celda.
@immutable
class BsTextos extends ThemeExtension<BsTextos> {
  /// Crea el conjunto de estilos.
  const BsTextos({
    required this.cifraGrande,
    required this.datoMono,
    required this.celda,
    required this.celdaLinea2,
  });

  /// Los estilos para una [BsPaleta].
  factory BsTextos.de(BsPaleta paleta) => BsTextos(
        cifraGrande: TextStyle(
          fontFamily: BsFuentes.sans,
          fontFamilyFallback: BsFuentes.respaldo,
          fontSize: BsEscala.cifraGrande,
          fontWeight: FontWeight.w600,
          height: 1.1,
          color: paleta.tinta,
          fontFeatures: cifrasTabulares,
        ),
        datoMono: TextStyle(
          fontFamily: BsFuentes.mono,
          fontFamilyFallback: BsFuentes.respaldo,
          fontSize: BsEscala.datoMono,
          fontWeight: FontWeight.w400,
          height: 1.4,
          color: paleta.tinta,
          fontFeatures: cifrasTabulares,
        ),
        celda: TextStyle(
          fontFamily: BsFuentes.condensada,
          fontFamilyFallback: BsFuentes.respaldo,
          fontSize: BsEscala.celda,
          fontWeight: FontWeight.w600,
          height: 1.1,
          color: paleta.tinta,
          fontFeatures: cifrasTabulares,
        ),
        celdaLinea2: TextStyle(
          fontFamily: BsFuentes.condensada,
          fontFamilyFallback: BsFuentes.respaldo,
          fontSize: BsEscala.celdaLinea2,
          fontWeight: FontWeight.w500,
          height: 1.1,
          color: paleta.tinta,
          fontFeatures: cifrasTabulares,
        ),
      );

  /// KPI, contadores y totales: 34, seminegrita, tabular.
  final TextStyle cifraGrande;

  /// Número de contenedor y posición: mono, tabular.
  final TextStyle datoMono;

  /// El código de la celda: condensada, 12, seminegrita.
  final TextStyle celda;

  /// La segunda línea de la celda: condensada, 10.
  final TextStyle celdaLinea2;

  @override
  BsTextos copyWith({
    TextStyle? cifraGrande,
    TextStyle? datoMono,
    TextStyle? celda,
    TextStyle? celdaLinea2,
  }) =>
      BsTextos(
        cifraGrande: cifraGrande ?? this.cifraGrande,
        datoMono: datoMono ?? this.datoMono,
        celda: celda ?? this.celda,
        celdaLinea2: celdaLinea2 ?? this.celdaLinea2,
      );

  @override
  BsTextos lerp(ThemeExtension<BsTextos>? other, double t) {
    if (other is! BsTextos) return this;
    return BsTextos(
      cifraGrande: TextStyle.lerp(cifraGrande, other.cifraGrande, t)!,
      datoMono: TextStyle.lerp(datoMono, other.datoMono, t)!,
      celda: TextStyle.lerp(celda, other.celda, t)!,
      celdaLinea2: TextStyle.lerp(celdaLinea2, other.celdaLinea2, t)!,
    );
  }
}
