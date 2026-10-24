import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'bs_categorico.dart';

/// Un rol de color: el relleno, el texto que va sobre el relleno y el contorno.
///
/// Cada rol está verificado en `docs/rediseno/fase2bis/contraste.md`: el texto
/// sobre el relleno cumple 4.5:1 y el contorno 3:1 sobre los fondos del modo.
@immutable
class BsRol {
  /// Crea un rol.
  const BsRol({
    required this.relleno,
    required this.texto,
    required this.contorno,
    this.punteado = false,
  });

  /// El relleno de la celda, el chip o la banda.
  final Color relleno;

  /// El texto y los iconos sobre [relleno].
  final Color texto;

  /// El contorno, que también sirve de color de icono sobre el papel.
  final Color contorno;

  /// Si el contorno se dibuja punteado: la celda bajada de noche, vacía y con
  /// su palomita (`DESIGN.md`, 13.2).
  final bool punteado;

  /// El rol atenuado, para lo que queda fuera del filtro de «Resaltar»
  /// (10.7, H1): el relleno baja a [alfa] compuesto sobre el [papel] y queda
  /// opaco, sin un [Opacity], así el contraste no depende de lo que haya
  /// detrás; el texto y el contorno no llevan alfa: el contorno cambia a
  /// [lineaFuerte] y el texto a [tintaSuave], o a [tinta] si la tinta suave no
  /// llega a 4.5:1 sobre lo compuesto (pasa con los rellenos de «por bajar»
  /// de la vista Estado: 3.5:1 de día y 3.1:1 de noche; `DESIGN.md`, 13.2).
  /// Con alfa en el texto, el código quedaba en 2.1:1 en claro y 2.9:1 en
  /// oscuro.
  BsRol atenuado({
    required Color papel,
    required Color tintaSuave,
    required Color lineaFuerte,
    Color? tinta,
    double alfa = 0.35,
  }) {
    final compuesto = Color.alphaBlend(relleno.withValues(alpha: alfa), papel);
    final legible = tinta == null || contrasteEntre(tintaSuave, compuesto) >= 4.5
        ? tintaSuave
        : tinta;
    return BsRol(
      relleno: compuesto,
      texto: legible,
      contorno: lineaFuerte,
      punteado: punteado,
    );
  }

  /// Interpola con [otro].
  BsRol lerp(BsRol otro, double t) => BsRol(
        relleno: Color.lerp(relleno, otro.relleno, t)!,
        texto: Color.lerp(texto, otro.texto, t)!,
        contorno: Color.lerp(contorno, otro.contorno, t)!,
        punteado: t < 0.5 ? punteado : otro.punteado,
      );

  /// La relación de contraste de WCAG 2 entre dos colores opacos.
  static double contrasteEntre(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
  }
}

/// Los roles semánticos del plano y la paleta categórica de «Colorear por»
/// (`DESIGN.md`, secciones 5 y 13).
///
/// El color nunca va solo: el componente que usa un rol lleva además su
/// icono o su rótulo. La tabla fija de la paleta categórica ([tablaFija]) es
/// la que confirmó Carlos en 10.6 ([tablaFijaConfirmada]), por omisión; lo que
/// no esté en ella usa el cálculo de [ranuraCategorica]. T-115 le suma las
/// ranuras que asigne la oficina. Los valores de oscuro son los de la noche de
/// la dirección C (10.14), y de noche las ranuras son fichas: relleno profundo
/// del tono, código y contorno en el tono vivo (13.4).
@immutable
class BsColoresSemanticos extends ThemeExtension<BsColoresSemanticos> {
  /// Crea el conjunto de roles.
  const BsColoresSemanticos({
    required this.pendiente,
    required this.hecho,
    required this.cancelado,
    required this.revisar,
    required this.error,
    required this.peligrosa,
    required this.refrigerado,
    required this.oog,
    required this.dePaso,
    required this.reservado,
    required this.enMovimiento,
    required this.cubierta,
    required this.bodega,
    required this.informacion,
    required this.porBajarCubierta,
    required this.porBajarBodega,
    required this.bajado,
    required this.recienMovido,
    required this.tintaTenue,
    required this.categoricos,
    this.tablaFija = const {},
  });

  /// Los roles del día (el muelle): los de la Fase 2, más los de la vista
  /// Estado de 13.2 y el rol «información».
  factory BsColoresSemanticos.claro({
    Map<String, int> tablaFija = tablaFijaConfirmada,
  }) =>
      BsColoresSemanticos(
        pendiente: const BsRol(
            relleno: Color(0xFFDCE7F8),
            texto: Color(0xFF10243F),
            contorno: Color(0xFF0D47A1)),
        hecho: const BsRol(
            relleno: Color(0xFFD3EFDB),
            texto: Color(0xFF10243F),
            contorno: Color(0xFF1E6B43)),
        cancelado: const BsRol(
            relleno: Color(0xFFE4E8EE),
            texto: Color(0xFF4A5B73),
            contorno: Color(0xFF6D809F)),
        revisar: const BsRol(
            relleno: Color(0xFFFBE7B5),
            texto: Color(0xFF10243F),
            contorno: Color(0xFF8A5A00)),
        error: const BsRol(
            relleno: Color(0xFFF9D9D6),
            texto: Color(0xFF10243F),
            contorno: Color(0xFFB3261E)),
        peligrosa: const BsRol(
            relleno: Color(0xFFF9D9D6),
            texto: Color(0xFF10243F),
            contorno: Color(0xFFB3261E)),
        refrigerado: const BsRol(
            relleno: Color(0xFFC4E3EE),
            texto: Color(0xFF10243F),
            contorno: Color(0xFF1F6F8B)),
        oog: const BsRol(
            relleno: Color(0xFFE3C4EE),
            texto: Color(0xFF10243F),
            contorno: Color(0xFF6B2E8A)),
        dePaso: const BsRol(
            relleno: Color(0xFFF5F8FC),
            texto: Color(0xFF4A5B73),
            contorno: Color(0xFF6D809F)),
        reservado: const BsRol(
            relleno: Color(0xFFFFFFFF),
            texto: Color(0xFF4A5B73),
            contorno: Color(0xFF6D809F)),
        enMovimiento: const BsRol(
            relleno: Color(0xFFFF7A1A),
            texto: Color(0xFF10243F),
            contorno: Color(0xFFC2410C)),
        cubierta: const BsRol(
            relleno: Color(0xFFFFFFFF),
            texto: Color(0xFF10243F),
            contorno: Color(0xFF6D809F)),
        bodega: const BsRol(
            relleno: Color(0xFFE3EDFB),
            texto: Color(0xFF10243F),
            contorno: Color(0xFF6D809F)),
        informacion: const BsRol(
            relleno: Color(0xFFDCE7F8),
            texto: Color(0xFF10243F),
            contorno: Color(0xFF0D47A1)),
        porBajarCubierta: const BsRol(
            relleno: Color(0xFF0D47A1),
            texto: Color(0xFFFFFFFF),
            contorno: Color(0xFF0D47A1)),
        porBajarBodega: const BsRol(
            relleno: Color(0xFF1F5FD6),
            texto: Color(0xFFFFFFFF),
            contorno: Color(0xFF1F5FD6)),
        bajado: const BsRol(
            relleno: Color(0xFFD3EFDB),
            texto: Color(0xFF10243F),
            contorno: Color(0xFF1E6B43)),
        recienMovido: const BsRol(
            relleno: Color(0xFFFF7A1A),
            texto: Color(0xFF10243F),
            contorno: Color(0xFFC2410C)),
        tintaTenue: const Color(0xFF566986),
        categoricos: _categoricosClaro,
        tablaFija: tablaFija,
      );

  /// Los roles de la noche (la oficina), de 10.14.
  factory BsColoresSemanticos.oscuro({
    Map<String, int> tablaFija = tablaFijaConfirmada,
  }) =>
      BsColoresSemanticos(
        pendiente: const BsRol(
            relleno: Color(0xFF1E3A66),
            texto: Color(0xFFEAF0F9),
            contorno: Color(0xFF4F8EF7)),
        hecho: const BsRol(
            relleno: Color(0xFF1D4A33),
            texto: Color(0xFFEAF0F9),
            contorno: Color(0xFF3DD68C)),
        cancelado: const BsRol(
            relleno: Color(0xFF2A3850),
            texto: Color(0xFFA9B9D2),
            contorno: Color(0xFF8A9DB8)),
        revisar: const BsRol(
            relleno: Color(0xFF5C4300),
            texto: Color(0xFFF2F6FB),
            contorno: Color(0xFFF5B83D)),
        error: const BsRol(
            relleno: Color(0xFF601410),
            texto: Color(0xFFF2F6FB),
            contorno: Color(0xFFF2777A)),
        peligrosa: const BsRol(
            relleno: Color(0xFF601410),
            texto: Color(0xFFF2F6FB),
            contorno: Color(0xFFF2777A)),
        refrigerado: const BsRol(
            relleno: Color(0xFF1E4A5C),
            texto: Color(0xFFF2F6FB),
            contorno: Color(0xFF7FC6DD)),
        oog: const BsRol(
            relleno: Color(0xFF4A2A5E),
            texto: Color(0xFFF2F6FB),
            contorno: Color(0xFFC9A0DE)),
        dePaso: const BsRol(
            relleno: Color(0xFF11223F),
            texto: Color(0xFFA9B9D2),
            contorno: Color(0xFF5272A6)),
        reservado: const BsRol(
            relleno: Color(0xFF0C1A31),
            texto: Color(0xFFA9B9D2),
            contorno: Color(0xFF8A9DB8)),
        enMovimiento: const BsRol(
            relleno: Color(0xFFFF7A1A),
            texto: Color(0xFF07111F),
            contorno: Color(0xFFFF9A4D)),
        cubierta: const BsRol(
            relleno: Color(0xFF0C1A31),
            texto: Color(0xFFEAF0F9),
            contorno: Color(0xFF5272A6)),
        bodega: const BsRol(
            relleno: Color(0xFF11213A),
            texto: Color(0xFFEAF0F9),
            contorno: Color(0xFF5272A6)),
        informacion: const BsRol(
            relleno: Color(0xFF11223F),
            texto: Color(0xFFEAF0F9),
            contorno: Color(0xFF4F8EF7)),
        porBajarCubierta: const BsRol(
            relleno: Color(0xFFF5F8FC),
            texto: Color(0xFF07111F),
            contorno: Color(0xFFF5F8FC)),
        porBajarBodega: const BsRol(
            relleno: Color(0xFF6E9DE6),
            texto: Color(0xFF07111F),
            contorno: Color(0xFF6E9DE6)),
        bajado: const BsRol(
            relleno: Color(0xFF07111F),
            texto: Color(0xFF3DD68C),
            contorno: Color(0xFF5272A6),
            punteado: true),
        recienMovido: const BsRol(
            relleno: Color(0xFFFF7A1A),
            texto: Color(0xFF07111F),
            contorno: Color(0xFFFFB27A)),
        tintaTenue: const Color(0xFF8DA0BE),
        categoricos: _categoricosOscuro,
        tablaFija: tablaFija,
      );

  /// Por hacer: «Baja», «Sube». Icono de flecha.
  final BsRol pendiente;

  /// Hecho: «Hecho». Icono de palomita.
  final BsRol hecho;

  /// Cancelado por la oficina. Icono de bloqueo.
  final BsRol cancelado;

  /// Conflicto o aviso: «Revisar». Icono de aviso.
  final BsRol revisar;

  /// Error, con su mensaje de causa y acción.
  final BsRol error;

  /// Mercancía peligrosa (IMO): icono de rombo y la clase.
  final BsRol peligrosa;

  /// Refrigerado: icono de copo y la temperatura.
  final BsRol refrigerado;

  /// Sobredimensionado: icono de flechas hacia fuera.
  final BsRol oog;

  /// De paso: «Paso» y el código. De día sin relleno; de noche apagado, en el
  /// panel alto con tinta suave.
  final BsRol dePaso;

  /// Reservado: solo contorno, sin relleno.
  final BsRol reservado;

  /// En movimiento o sin confirmar: el naranja de la grúa, con icono. Lo usa
  /// la marca de re‑estiba; la celda que se acaba de mover usa [recienMovido].
  final BsRol enMovimiento;

  /// La zona de cubierta de la rejilla.
  final BsRol cubierta;

  /// La zona de bodega de la rejilla, en acero tenue.
  final BsRol bodega;

  /// La banda de información («Plano sin confirmar»): de día el tinte de
  /// marca; de noche el panel alto con el icono en selección.
  final BsRol informacion;

  /// Vista Estado (13.2): por bajar en cubierta. De día la marca con texto
  /// blanco; de noche el blanco de la cubierta del ícono con texto noche.
  final BsRol porBajarCubierta;

  /// Vista Estado: por bajar en bodega. De día un azul más claro con texto
  /// blanco; de noche el acero de la bodega del ícono con texto noche.
  final BsRol porBajarBodega;

  /// Vista Estado: bajado. De día el rol hecho; de noche la celda vacía con el
  /// contorno punteado y la palomita en hecho.
  final BsRol bajado;

  /// Vista Estado: lo que se acaba de mover (13.3). El naranja de la grúa con
  /// texto oscuro; dura `BsMovimiento.recienMovido`.
  final BsRol recienMovido;

  /// Texto terciario: el momento de un evento, el detalle de una tarjeta.
  final Color tintaTenue;

  /// Las 24 ranuras de «Colorear por»: doce tonos en dos luminosidades, en el
  /// orden de la tabla reordenada ([tonoDeRanura]).
  final List<BsRol> categoricos;

  /// La tabla fija de códigos a ranura (puertos y tipos ISO), en mayúsculas.
  final Map<String, int> tablaFija;

  /// El rol categórico de un código de puerto o de tipo ISO.
  BsRol categorico(String codigo) =>
      categoricos[ranuraCategorica(codigo, tablaFija: tablaFija)];

  /// Los roles del contexto, o los del modo claro si el tema no los trae.
  static BsColoresSemanticos de(BuildContext context) =>
      Theme.of(context).extension<BsColoresSemanticos>() ??
      BsColoresSemanticos.claro();

  @override
  BsColoresSemanticos copyWith({
    BsRol? pendiente,
    BsRol? hecho,
    BsRol? cancelado,
    BsRol? revisar,
    BsRol? error,
    BsRol? peligrosa,
    BsRol? refrigerado,
    BsRol? oog,
    BsRol? dePaso,
    BsRol? reservado,
    BsRol? enMovimiento,
    BsRol? cubierta,
    BsRol? bodega,
    BsRol? informacion,
    BsRol? porBajarCubierta,
    BsRol? porBajarBodega,
    BsRol? bajado,
    BsRol? recienMovido,
    Color? tintaTenue,
    List<BsRol>? categoricos,
    Map<String, int>? tablaFija,
  }) =>
      BsColoresSemanticos(
        pendiente: pendiente ?? this.pendiente,
        hecho: hecho ?? this.hecho,
        cancelado: cancelado ?? this.cancelado,
        revisar: revisar ?? this.revisar,
        error: error ?? this.error,
        peligrosa: peligrosa ?? this.peligrosa,
        refrigerado: refrigerado ?? this.refrigerado,
        oog: oog ?? this.oog,
        dePaso: dePaso ?? this.dePaso,
        reservado: reservado ?? this.reservado,
        enMovimiento: enMovimiento ?? this.enMovimiento,
        cubierta: cubierta ?? this.cubierta,
        bodega: bodega ?? this.bodega,
        informacion: informacion ?? this.informacion,
        porBajarCubierta: porBajarCubierta ?? this.porBajarCubierta,
        porBajarBodega: porBajarBodega ?? this.porBajarBodega,
        bajado: bajado ?? this.bajado,
        recienMovido: recienMovido ?? this.recienMovido,
        tintaTenue: tintaTenue ?? this.tintaTenue,
        categoricos: categoricos ?? this.categoricos,
        tablaFija: tablaFija ?? this.tablaFija,
      );

  @override
  BsColoresSemanticos lerp(
      ThemeExtension<BsColoresSemanticos>? other, double t) {
    if (other is! BsColoresSemanticos) return this;
    return BsColoresSemanticos(
      pendiente: pendiente.lerp(other.pendiente, t),
      hecho: hecho.lerp(other.hecho, t),
      cancelado: cancelado.lerp(other.cancelado, t),
      revisar: revisar.lerp(other.revisar, t),
      error: error.lerp(other.error, t),
      peligrosa: peligrosa.lerp(other.peligrosa, t),
      refrigerado: refrigerado.lerp(other.refrigerado, t),
      oog: oog.lerp(other.oog, t),
      dePaso: dePaso.lerp(other.dePaso, t),
      reservado: reservado.lerp(other.reservado, t),
      enMovimiento: enMovimiento.lerp(other.enMovimiento, t),
      cubierta: cubierta.lerp(other.cubierta, t),
      bodega: bodega.lerp(other.bodega, t),
      informacion: informacion.lerp(other.informacion, t),
      porBajarCubierta: porBajarCubierta.lerp(other.porBajarCubierta, t),
      porBajarBodega: porBajarBodega.lerp(other.porBajarBodega, t),
      bajado: bajado.lerp(other.bajado, t),
      recienMovido: recienMovido.lerp(other.recienMovido, t),
      tintaTenue: Color.lerp(tintaTenue, other.tintaTenue, t)!,
      categoricos: [
        for (var i = 0; i < categoricos.length; i++)
          categoricos[i].lerp(
              other.categoricos[i < other.categoricos.length ? i : 0], t),
      ],
      tablaFija: t < 0.5 ? tablaFija : other.tablaFija,
    );
  }
}

// Las 24 ranuras, en el orden de la tabla reordenada de 10.14: la ranura k
// pinta el tono tonosPorRanura[k mod 12] (rosa, cielo, hierba, uva, ámbar,
// índigo, verde mar, arcilla, magenta, turquesa, oliva, cobalto), luminosidad
// «suave» para k < 12 e «intensa» después. De día, los rellenos y contornos de
// la Fase 2 (HSL) con la tinta encima; de noche, fichas en OKLCH: el relleno
// profundo del tono y el código y el contorno en el tono vivo. Generadas por
// `python tool/rediseno_contraste.py --dart`.
const Color _tintaClara = Color(0xFF10243F);

const List<BsRol> _categoricosClaro = <BsRol>[
  // 0: rosa suave
  BsRol(relleno: Color(0xFFEEC4CE), texto: _tintaClara, contorno: Color(0xFF832139)),
  // 1: cielo suave
  BsRol(relleno: Color(0xFFC4E3EE), texto: _tintaClara, contorno: Color(0xFF216A83)),
  // 2: hierba suave
  BsRol(relleno: Color(0xFFCEEEC4), texto: _tintaClara, contorno: Color(0xFF398321)),
  // 3: uva suave
  BsRol(relleno: Color(0xFFE3C4EE), texto: _tintaClara, contorno: Color(0xFF6A2183)),
  // 4: ámbar suave
  BsRol(relleno: Color(0xFFEEE3C4), texto: _tintaClara, contorno: Color(0xFF836A21)),
  // 5: índigo suave
  BsRol(relleno: Color(0xFFCEC4EE), texto: _tintaClara, contorno: Color(0xFF392183)),
  // 6: verde mar suave
  BsRol(relleno: Color(0xFFC4EECE), texto: _tintaClara, contorno: Color(0xFF218339)),
  // 7: arcilla suave
  BsRol(relleno: Color(0xFFEECEC4), texto: _tintaClara, contorno: Color(0xFF833921)),
  // 8: magenta suave
  BsRol(relleno: Color(0xFFEEC4E3), texto: _tintaClara, contorno: Color(0xFF83216A)),
  // 9: turquesa suave
  BsRol(relleno: Color(0xFFC4EEE3), texto: _tintaClara, contorno: Color(0xFF21836A)),
  // 10: oliva suave
  BsRol(relleno: Color(0xFFE3EEC4), texto: _tintaClara, contorno: Color(0xFF6A8321)),
  // 11: cobalto suave
  BsRol(relleno: Color(0xFFC4CEEE), texto: _tintaClara, contorno: Color(0xFF213983)),
  // 12: rosa intensa
  BsRol(relleno: Color(0xFFDE9CAC), texto: _tintaClara, contorno: Color(0xFF6A1B2E)),
  // 13: cielo intensa
  BsRol(relleno: Color(0xFF9CCDDE), texto: _tintaClara, contorno: Color(0xFF1B566A)),
  // 14: hierba intensa
  BsRol(relleno: Color(0xFFACDE9C), texto: _tintaClara, contorno: Color(0xFF2E6A1B)),
  // 15: uva intensa
  BsRol(relleno: Color(0xFFCD9CDE), texto: _tintaClara, contorno: Color(0xFF561B6A)),
  // 16: ámbar intensa
  BsRol(relleno: Color(0xFFDECD9C), texto: _tintaClara, contorno: Color(0xFF6A561B)),
  // 17: índigo intensa
  BsRol(relleno: Color(0xFFAC9CDE), texto: _tintaClara, contorno: Color(0xFF2E1B6A)),
  // 18: verde mar intensa
  BsRol(relleno: Color(0xFF9CDEAC), texto: _tintaClara, contorno: Color(0xFF1B6A2E)),
  // 19: arcilla intensa
  BsRol(relleno: Color(0xFFDEAC9C), texto: _tintaClara, contorno: Color(0xFF6A2E1B)),
  // 20: magenta intensa
  BsRol(relleno: Color(0xFFDE9CCD), texto: _tintaClara, contorno: Color(0xFF6A1B56)),
  // 21: turquesa intensa
  BsRol(relleno: Color(0xFF9CDECD), texto: _tintaClara, contorno: Color(0xFF1B6A56)),
  // 22: oliva intensa
  BsRol(relleno: Color(0xFFCDDE9C), texto: _tintaClara, contorno: Color(0xFF566A1B)),
  // 23: cobalto intensa
  BsRol(relleno: Color(0xFF9CACDE), texto: _tintaClara, contorno: Color(0xFF1B2E6A)),
];

const List<BsRol> _categoricosOscuro = <BsRol>[
  // 0: rosa suave
  BsRol(relleno: Color(0xFF58252F), texto: Color(0xFFFFB2BD), contorno: Color(0xFFFFB2BD)),
  // 1: cielo suave
  BsRol(relleno: Color(0xFF003E55), texto: Color(0xFF84D7FE), contorno: Color(0xFF84D7FE)),
  // 2: hierba suave
  BsRol(relleno: Color(0xFF1B421E), texto: Color(0xFF98DF9A), contorno: Color(0xFF98DF9A)),
  // 3: uva suave
  BsRol(relleno: Color(0xFF462B52), texto: Color(0xFFE7B3FF), contorno: Color(0xFFE7B3FF)),
  // 4: ámbar suave
  BsRol(relleno: Color(0xFF4E3100), texto: Color(0xFFF8BF6C), contorno: Color(0xFFF8BF6C)),
  // 5: índigo suave
  BsRol(relleno: Color(0xFF34315D), texto: Color(0xFFC4C4FF), contorno: Color(0xFFC4C4FF)),
  // 6: verde mar suave
  BsRol(relleno: Color(0xFF004332), texto: Color(0xFF6FE4BF), contorno: Color(0xFF6FE4BF)),
  // 7: arcilla suave
  BsRol(relleno: Color(0xFF58281C), texto: Color(0xFFFFB6A3), contorno: Color(0xFFFFB6A3)),
  // 8: magenta suave
  BsRol(relleno: Color(0xFF522641), texto: Color(0xFFFEADDB), contorno: Color(0xFFFEADDB)),
  // 9: turquesa suave
  BsRol(relleno: Color(0xFF004142), texto: Color(0xFF55E3E3), contorno: Color(0xFF55E3E3)),
  // 10: oliva suave
  BsRol(relleno: Color(0xFF3B3B00), texto: Color(0xFFCFD271), contorno: Color(0xFFCFD271)),
  // 11: cobalto suave
  BsRol(relleno: Color(0xFF22375E), texto: Color(0xFFAFCBFE), contorno: Color(0xFFAFCBFE)),
  // 12: rosa intensa
  BsRol(relleno: Color(0xFF873043), texto: Color(0xFFFFDFE2), contorno: Color(0xFFFFDFE2)),
  // 13: cielo intensa
  BsRol(relleno: Color(0xFF005B7A), texto: Color(0xFFCCEEFF), contorno: Color(0xFFCCEEFF)),
  // 14: hierba intensa
  BsRol(relleno: Color(0xFF1A6323), texto: Color(0xFFD0F3D0), contorno: Color(0xFFD0F3D0)),
  // 15: uva intensa
  BsRol(relleno: Color(0xFF6B3A7F), texto: Color(0xFFF4DFFF), contorno: Color(0xFFF4DFFF)),
  // 16: ámbar intensa
  BsRol(relleno: Color(0xFF704A00), texto: Color(0xFFFEE3BF), contorno: Color(0xFFFEE3BF)),
  // 17: índigo intensa
  BsRol(relleno: Color(0xFF4D4691), texto: Color(0xFFE5E5FE), contorno: Color(0xFFE5E5FE)),
  // 18: verde mar intensa
  BsRol(relleno: Color(0xFF00624B), texto: Color(0xFFC1F6E2), contorno: Color(0xFFC1F6E2)),
  // 19: arcilla intensa
  BsRol(relleno: Color(0xFF88341F), texto: Color(0xFFFFE0D8), contorno: Color(0xFFFFE0D8)),
  // 20: magenta intensa
  BsRol(relleno: Color(0xFF7E3261), texto: Color(0xFFFFDDEF), contorno: Color(0xFFFFDDEF)),
  // 21: turquesa intensa
  BsRol(relleno: Color(0xFF005F5F), texto: Color(0xFFB9F5F4), contorno: Color(0xFFB9F5F4)),
  // 22: oliva intensa
  BsRol(relleno: Color(0xFF565700), texto: Color(0xFFEAECBE), contorno: Color(0xFFEAECBE)),
  // 23: cobalto intensa
  BsRol(relleno: Color(0xFF2C4F94), texto: Color(0xFFDCE9FE), contorno: Color(0xFFDCE9FE)),
];
