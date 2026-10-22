import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Espacios, radios, alturas de control y medidas de la celda (`DESIGN.md`,
/// secciones 4.3 y 13.10), en dos densidades: la oficina y el muelle.
///
/// El muelle sube los objetivos táctiles (56 dp para la acción principal, celda
/// de 56 × 48) y afloja el espacio; la oficina es más densa. Nada de lo que se
/// toca baja de [objetivoTactil] en ninguna de las dos.
@immutable
class BsMedidas extends ThemeExtension<BsMedidas> {
  /// Crea un juego de medidas. En el producto solo existen [oficina] y
  /// [muelle].
  const BsMedidas({
    required this.esMuelle,
    required this.espacioXs,
    required this.espacioS,
    required this.espacioM,
    required this.espacioL,
    required this.espacioXl,
    required this.espacioXxl,
    required this.espacioXxxl,
    required this.dentroDeBloque,
    required this.entreBloques,
    required this.radioCelda,
    required this.radioControl,
    required this.radioHoja,
    required this.radioPanel,
    required this.radioDialogo,
    required this.radioCasco,
    required this.pasoRejilla,
    required this.alturaBoton,
    required this.alturaBotonPrincipal,
    required this.alturaCampo,
    required this.alturaFila,
    required this.alturaChip,
    required this.objetivoTactil,
    required this.alturaBarraSuperior,
    required this.alturaBarraNavegacion,
    required this.anchoRiel,
    required this.anchoPanelLateral,
    required this.anchoMaximo,
    required this.anchoCelda,
    required this.altoCelda,
    required this.huecoCelda,
    required this.grosorContornoCelda,
    required this.anchoEtiquetaNivel,
    required this.anchoColumnaPesos,
  });

  /// Verdadero en la densidad del muelle.
  final bool esMuelle;

  /// 4.
  final double espacioXs;

  /// 8.
  final double espacioS;

  /// 12.
  final double espacioM;

  /// 16.
  final double espacioL;

  /// 24.
  final double espacioXl;

  /// 32.
  final double espacioXxl;

  /// 40.
  final double espacioXxxl;

  /// El espacio entre elementos de un mismo bloque.
  final double dentroDeBloque;

  /// El espacio entre bloques.
  final double entreBloques;

  /// El radio de la celda del plano: las esquinas del ícono, el 17 % del lado
  /// (13.2).
  final double radioCelda;

  /// El radio de botones, campos y chips.
  final double radioControl;

  /// El radio de hojas, tarjetas y paneles.
  final double radioHoja;

  /// El radio de los paneles del puente de mando: tarjetas de cifra, la
  /// silueta, «En vivo» (13.10).
  final double radioPanel;

  /// El radio de los diálogos.
  final double radioDialogo;

  /// La curva del casco en la esquina exterior inferior de las celdas de los
  /// extremos de la bodega (13.2).
  final double radioCasco;

  /// El paso de la rejilla de plano del fondo de noche (13.1).
  final double pasoRejilla;

  /// La altura de un botón corriente.
  final double alturaBoton;

  /// La altura de la acción principal de una pantalla.
  final double alturaBotonPrincipal;

  /// La altura de un campo de texto.
  final double alturaCampo;

  /// La altura de una fila de lista.
  final double alturaFila;

  /// La altura visible de un chip (su zona táctil llega a [objetivoTactil]).
  final double alturaChip;

  /// El mínimo de todo lo que se toca: 48 dp.
  final double objetivoTactil;

  /// La barra superior.
  final double alturaBarraSuperior;

  /// La barra de navegación del teléfono.
  final double alturaBarraNavegacion;

  /// El riel de navegación de tableta y oficina.
  final double anchoRiel;

  /// El panel lateral de la oficina.
  final double anchoPanelLateral;

  /// El ancho máximo del contenido, centrado.
  final double anchoMaximo;

  /// El ancho de la celda del plano.
  final double anchoCelda;

  /// El alto de la celda del plano; nunca menos de [objetivoTactil].
  final double altoCelda;

  /// El hueco entre celdas.
  final double huecoCelda;

  /// El grosor del contorno de la celda.
  final double grosorContornoCelda;

  /// El ancho de la etiqueta de nivel a la izquierda de la rejilla.
  final double anchoEtiquetaNivel;

  /// El ancho de la columna de pesos a la derecha de la rejilla.
  final double anchoColumnaPesos;

  /// La densidad de la oficina (1920 px, mouse y teclado).
  static const BsMedidas oficina = BsMedidas(
    esMuelle: false,
    espacioXs: 4,
    espacioS: 8,
    espacioM: 12,
    espacioL: 16,
    espacioXl: 24,
    espacioXxl: 32,
    espacioXxxl: 40,
    dentroDeBloque: 12,
    entreBloques: 24,
    radioCelda: 8,
    radioControl: 6,
    radioHoja: 10,
    radioPanel: 18,
    radioDialogo: 16,
    radioCasco: 18,
    pasoRejilla: 32,
    alturaBoton: 40,
    alturaBotonPrincipal: 48,
    alturaCampo: 48,
    alturaFila: 56,
    alturaChip: 32,
    objetivoTactil: 48,
    alturaBarraSuperior: 56,
    alturaBarraNavegacion: 80,
    anchoRiel: 80,
    anchoPanelLateral: 360,
    anchoMaximo: 1440,
    anchoCelda: 52,
    altoCelda: 48,
    huecoCelda: 4,
    grosorContornoCelda: 1,
    anchoEtiquetaNivel: 40,
    anchoColumnaPesos: 72,
  );

  /// La densidad del muelle (360 dp, al sol, con guantes).
  static const BsMedidas muelle = BsMedidas(
    esMuelle: true,
    espacioXs: 4,
    espacioS: 8,
    espacioM: 12,
    espacioL: 16,
    espacioXl: 24,
    espacioXxl: 32,
    espacioXxxl: 40,
    dentroDeBloque: 16,
    entreBloques: 24,
    radioCelda: 8,
    radioControl: 6,
    radioHoja: 10,
    radioPanel: 18,
    radioDialogo: 16,
    radioCasco: 18,
    pasoRejilla: 32,
    alturaBoton: 48,
    alturaBotonPrincipal: 56,
    alturaCampo: 56,
    alturaFila: 64,
    alturaChip: 40,
    objetivoTactil: 48,
    alturaBarraSuperior: 56,
    alturaBarraNavegacion: 80,
    anchoRiel: 80,
    anchoPanelLateral: 360,
    anchoMaximo: 1440,
    anchoCelda: 56,
    altoCelda: 48,
    huecoCelda: 4,
    grosorContornoCelda: 2,
    anchoEtiquetaNivel: 40,
    anchoColumnaPesos: 72,
  );

  /// Las medidas del contexto, o las de la oficina si el tema no las trae.
  static BsMedidas de(BuildContext context) =>
      Theme.of(context).extension<BsMedidas>() ?? oficina;

  @override
  BsMedidas copyWith({bool? esMuelle}) {
    if (esMuelle == null || esMuelle == this.esMuelle) return this;
    return esMuelle ? muelle : oficina;
  }

  @override
  BsMedidas lerp(ThemeExtension<BsMedidas>? other, double t) {
    if (other is! BsMedidas) return this;
    double entre(double a, double b) => lerpDouble(a, b, t)!;
    return BsMedidas(
      esMuelle: t < 0.5 ? esMuelle : other.esMuelle,
      espacioXs: entre(espacioXs, other.espacioXs),
      espacioS: entre(espacioS, other.espacioS),
      espacioM: entre(espacioM, other.espacioM),
      espacioL: entre(espacioL, other.espacioL),
      espacioXl: entre(espacioXl, other.espacioXl),
      espacioXxl: entre(espacioXxl, other.espacioXxl),
      espacioXxxl: entre(espacioXxxl, other.espacioXxxl),
      dentroDeBloque: entre(dentroDeBloque, other.dentroDeBloque),
      entreBloques: entre(entreBloques, other.entreBloques),
      radioCelda: entre(radioCelda, other.radioCelda),
      radioControl: entre(radioControl, other.radioControl),
      radioHoja: entre(radioHoja, other.radioHoja),
      radioPanel: entre(radioPanel, other.radioPanel),
      radioDialogo: entre(radioDialogo, other.radioDialogo),
      radioCasco: entre(radioCasco, other.radioCasco),
      pasoRejilla: entre(pasoRejilla, other.pasoRejilla),
      alturaBoton: entre(alturaBoton, other.alturaBoton),
      alturaBotonPrincipal:
          entre(alturaBotonPrincipal, other.alturaBotonPrincipal),
      alturaCampo: entre(alturaCampo, other.alturaCampo),
      alturaFila: entre(alturaFila, other.alturaFila),
      alturaChip: entre(alturaChip, other.alturaChip),
      objetivoTactil: entre(objetivoTactil, other.objetivoTactil),
      alturaBarraSuperior: entre(alturaBarraSuperior, other.alturaBarraSuperior),
      alturaBarraNavegacion:
          entre(alturaBarraNavegacion, other.alturaBarraNavegacion),
      anchoRiel: entre(anchoRiel, other.anchoRiel),
      anchoPanelLateral: entre(anchoPanelLateral, other.anchoPanelLateral),
      anchoMaximo: entre(anchoMaximo, other.anchoMaximo),
      anchoCelda: entre(anchoCelda, other.anchoCelda),
      altoCelda: entre(altoCelda, other.altoCelda),
      huecoCelda: entre(huecoCelda, other.huecoCelda),
      grosorContornoCelda: entre(grosorContornoCelda, other.grosorContornoCelda),
      anchoEtiquetaNivel: entre(anchoEtiquetaNivel, other.anchoEtiquetaNivel),
      anchoColumnaPesos: entre(anchoColumnaPesos, other.anchoColumnaPesos),
    );
  }
}
