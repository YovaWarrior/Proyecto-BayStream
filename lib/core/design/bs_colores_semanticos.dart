import 'package:flutter/material.dart';

import 'bs_categorico.dart';

/// Un rol de color: el relleno, el texto que va sobre el relleno y el contorno.
///
/// Cada rol está verificado en `docs/rediseno/fase2/contraste.md`: el texto
/// sobre el relleno cumple 4.5:1 y el contorno 3:1 sobre el papel.
@immutable
class BsRol {
  /// Crea un rol.
  const BsRol({
    required this.relleno,
    required this.texto,
    required this.contorno,
  });

  /// El relleno de la celda, el chip o la banda.
  final Color relleno;

  /// El texto y los iconos sobre [relleno].
  final Color texto;

  /// El contorno, que también sirve de color de icono sobre el papel.
  final Color contorno;

  /// El rol atenuado, para lo que queda fuera del filtro de «Resaltar»
  /// (10.7, H1): el relleno baja a [alfa] compuesto sobre el [papel] y queda
  /// opaco, sin un [Opacity], así el contraste no depende de lo que haya
  /// detrás; el texto y el contorno no llevan alfa, cambian a [tintaSuave] y
  /// [lineaFuerte], que cumplen 4.5:1 y 3:1 sobre lo compuesto (el peor caso
  /// es el naranja: 4.98:1 en claro). Con alfa en el texto, el código quedaba
  /// en 2.1:1 en claro y 2.9:1 en oscuro.
  BsRol atenuado({
    required Color papel,
    required Color tintaSuave,
    required Color lineaFuerte,
    double alfa = 0.35,
  }) =>
      BsRol(
        relleno: Color.alphaBlend(relleno.withValues(alpha: alfa), papel),
        texto: tintaSuave,
        contorno: lineaFuerte,
      );

  /// Interpola con [otro].
  BsRol lerp(BsRol otro, double t) => BsRol(
        relleno: Color.lerp(relleno, otro.relleno, t)!,
        texto: Color.lerp(texto, otro.texto, t)!,
        contorno: Color.lerp(contorno, otro.contorno, t)!,
      );
}

/// Los roles semánticos del plano y la paleta categórica de «Colorear por»
/// (`DESIGN.md`, sección 5).
///
/// El color nunca va solo: el componente que usa un rol lleva además su
/// icono o su rótulo. La tabla fija de la paleta categórica ([tablaFija]) es
/// la que confirmó Carlos en 10.6 ([tablaFijaConfirmada]), por omisión; lo que
/// no esté en ella usa el cálculo de [ranuraCategorica]. T-115 le suma las
/// ranuras que asigne la oficina.
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
    required this.categoricos,
    this.tablaFija = const {},
  });

  /// Los roles del modo claro.
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
        categoricos: _categoricosClaro,
        tablaFija: tablaFija,
      );

  /// Los roles del modo oscuro.
  factory BsColoresSemanticos.oscuro({
    Map<String, int> tablaFija = tablaFijaConfirmada,
  }) =>
      BsColoresSemanticos(
        pendiente: const BsRol(
            relleno: Color(0xFF1E3A66),
            texto: Color(0xFFE6EEF8),
            contorno: Color(0xFF8FB4F2)),
        hecho: const BsRol(
            relleno: Color(0xFF1D4A33),
            texto: Color(0xFFE6EEF8),
            contorno: Color(0xFF6FCF97)),
        cancelado: const BsRol(
            relleno: Color(0xFF2A3850),
            texto: Color(0xFFA9B8CC),
            contorno: Color(0xFF8A9DB8)),
        revisar: const BsRol(
            relleno: Color(0xFF5C4300),
            texto: Color(0xFFF2F6FB),
            contorno: Color(0xFFE0B23F)),
        error: const BsRol(
            relleno: Color(0xFF601410),
            texto: Color(0xFFF2F6FB),
            contorno: Color(0xFFF2B8B5)),
        peligrosa: const BsRol(
            relleno: Color(0xFF601410),
            texto: Color(0xFFF2F6FB),
            contorno: Color(0xFFF2B8B5)),
        refrigerado: const BsRol(
            relleno: Color(0xFF1E4A5C),
            texto: Color(0xFFF2F6FB),
            contorno: Color(0xFF7FC6DD)),
        oog: const BsRol(
            relleno: Color(0xFF4A2A5E),
            texto: Color(0xFFF2F6FB),
            contorno: Color(0xFFC9A0DE)),
        dePaso: const BsRol(
            relleno: Color(0xFF0B1626),
            texto: Color(0xFFA9B8CC),
            contorno: Color(0xFF6983A3)),
        reservado: const BsRol(
            relleno: Color(0xFF13223A),
            texto: Color(0xFFA9B8CC),
            contorno: Color(0xFF8A9DB8)),
        enMovimiento: const BsRol(
            relleno: Color(0xFFFF7A1A),
            texto: Color(0xFF0B1626),
            contorno: Color(0xFFFF9A4D)),
        cubierta: const BsRol(
            relleno: Color(0xFF13223A),
            texto: Color(0xFFE6EEF8),
            contorno: Color(0xFF6983A3)),
        bodega: const BsRol(
            relleno: Color(0xFF1C2F4D),
            texto: Color(0xFFE6EEF8),
            contorno: Color(0xFF6983A3)),
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

  /// De paso: sin relleno, texto en tinta suave, «Paso».
  final BsRol dePaso;

  /// Reservado: solo contorno, sin relleno.
  final BsRol reservado;

  /// En movimiento o sin confirmar: el naranja de la grúa, con icono.
  final BsRol enMovimiento;

  /// La zona de cubierta de la rejilla.
  final BsRol cubierta;

  /// La zona de bodega de la rejilla, en acero tenue.
  final BsRol bodega;

  /// Las 24 ranuras de «Colorear por»: doce tonos en dos luminosidades.
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
      categoricos: [
        for (var i = 0; i < categoricos.length; i++)
          categoricos[i].lerp(
              other.categoricos[i < other.categoricos.length ? i : 0], t),
      ],
      tablaFija: t < 0.5 ? tablaFija : other.tablaFija,
    );
  }
}

// Las 24 ranuras: tono k mod 12 (arcilla, ámbar, oliva, hierba, verde mar,
// turquesa, cielo, cobalto, índigo, uva, magenta, rosa), luminosidad «suave»
// para k < 12 e «intensa» después. Generadas por tool/rediseno_contraste.py.
const Color _tintaClara = Color(0xFF10243F);
const Color _tintaOscura = Color(0xFFF2F6FB);

const List<BsRol> _categoricosClaro = <BsRol>[
  BsRol(relleno: Color(0xFFEECEC4), texto: _tintaClara, contorno: Color(0xFF833921)),
  BsRol(relleno: Color(0xFFEEE3C4), texto: _tintaClara, contorno: Color(0xFF836A21)),
  BsRol(relleno: Color(0xFFE3EEC4), texto: _tintaClara, contorno: Color(0xFF6A8321)),
  BsRol(relleno: Color(0xFFCEEEC4), texto: _tintaClara, contorno: Color(0xFF398321)),
  BsRol(relleno: Color(0xFFC4EECE), texto: _tintaClara, contorno: Color(0xFF218339)),
  BsRol(relleno: Color(0xFFC4EEE3), texto: _tintaClara, contorno: Color(0xFF21836A)),
  BsRol(relleno: Color(0xFFC4E3EE), texto: _tintaClara, contorno: Color(0xFF216A83)),
  BsRol(relleno: Color(0xFFC4CEEE), texto: _tintaClara, contorno: Color(0xFF213983)),
  BsRol(relleno: Color(0xFFCEC4EE), texto: _tintaClara, contorno: Color(0xFF392183)),
  BsRol(relleno: Color(0xFFE3C4EE), texto: _tintaClara, contorno: Color(0xFF6A2183)),
  BsRol(relleno: Color(0xFFEEC4E3), texto: _tintaClara, contorno: Color(0xFF83216A)),
  BsRol(relleno: Color(0xFFEEC4CE), texto: _tintaClara, contorno: Color(0xFF832139)),
  BsRol(relleno: Color(0xFFDEAC9C), texto: _tintaClara, contorno: Color(0xFF6A2E1B)),
  BsRol(relleno: Color(0xFFDECD9C), texto: _tintaClara, contorno: Color(0xFF6A561B)),
  BsRol(relleno: Color(0xFFCDDE9C), texto: _tintaClara, contorno: Color(0xFF566A1B)),
  BsRol(relleno: Color(0xFFACDE9C), texto: _tintaClara, contorno: Color(0xFF2E6A1B)),
  BsRol(relleno: Color(0xFF9CDEAC), texto: _tintaClara, contorno: Color(0xFF1B6A2E)),
  BsRol(relleno: Color(0xFF9CDECD), texto: _tintaClara, contorno: Color(0xFF1B6A56)),
  BsRol(relleno: Color(0xFF9CCDDE), texto: _tintaClara, contorno: Color(0xFF1B566A)),
  BsRol(relleno: Color(0xFF9CACDE), texto: _tintaClara, contorno: Color(0xFF1B2E6A)),
  BsRol(relleno: Color(0xFFAC9CDE), texto: _tintaClara, contorno: Color(0xFF2E1B6A)),
  BsRol(relleno: Color(0xFFCD9CDE), texto: _tintaClara, contorno: Color(0xFF561B6A)),
  BsRol(relleno: Color(0xFFDE9CCD), texto: _tintaClara, contorno: Color(0xFF6A1B56)),
  BsRol(relleno: Color(0xFFDE9CAC), texto: _tintaClara, contorno: Color(0xFF6A1B2E)),
];

const List<BsRol> _categoricosOscuro = <BsRol>[
  BsRol(relleno: Color(0xFF6F3B2A), texto: _tintaOscura, contorno: Color(0xFFDA9781)),
  BsRol(relleno: Color(0xFF6F5E2A), texto: _tintaOscura, contorno: Color(0xFFDAC481)),
  BsRol(relleno: Color(0xFF5E6F2A), texto: _tintaOscura, contorno: Color(0xFFC4DA81)),
  BsRol(relleno: Color(0xFF3B6F2A), texto: _tintaOscura, contorno: Color(0xFF97DA81)),
  BsRol(relleno: Color(0xFF2A6F3B), texto: _tintaOscura, contorno: Color(0xFF81DA97)),
  BsRol(relleno: Color(0xFF2A6F5E), texto: _tintaOscura, contorno: Color(0xFF81DAC4)),
  BsRol(relleno: Color(0xFF2A5E6F), texto: _tintaOscura, contorno: Color(0xFF81C4DA)),
  BsRol(relleno: Color(0xFF2A3B6F), texto: _tintaOscura, contorno: Color(0xFF8197DA)),
  BsRol(relleno: Color(0xFF3B2A6F), texto: _tintaOscura, contorno: Color(0xFF9781DA)),
  BsRol(relleno: Color(0xFF5E2A6F), texto: _tintaOscura, contorno: Color(0xFFC481DA)),
  BsRol(relleno: Color(0xFF6F2A5E), texto: _tintaOscura, contorno: Color(0xFFDA81C4)),
  BsRol(relleno: Color(0xFF6F2A3B), texto: _tintaOscura, contorno: Color(0xFFDA8197)),
  BsRol(relleno: Color(0xFF4E2A1D), texto: _tintaOscura, contorno: Color(0xFFE3B1A0)),
  BsRol(relleno: Color(0xFF4E421D), texto: _tintaOscura, contorno: Color(0xFFE3D3A0)),
  BsRol(relleno: Color(0xFF424E1D), texto: _tintaOscura, contorno: Color(0xFFD3E3A0)),
  BsRol(relleno: Color(0xFF2A4E1D), texto: _tintaOscura, contorno: Color(0xFFB1E3A0)),
  BsRol(relleno: Color(0xFF1D4E2A), texto: _tintaOscura, contorno: Color(0xFFA0E3B1)),
  BsRol(relleno: Color(0xFF1D4E42), texto: _tintaOscura, contorno: Color(0xFFA0E3D3)),
  BsRol(relleno: Color(0xFF1D424E), texto: _tintaOscura, contorno: Color(0xFFA0D3E3)),
  BsRol(relleno: Color(0xFF1D2A4E), texto: _tintaOscura, contorno: Color(0xFFA0B1E3)),
  BsRol(relleno: Color(0xFF2A1D4E), texto: _tintaOscura, contorno: Color(0xFFB1A0E3)),
  BsRol(relleno: Color(0xFF421D4E), texto: _tintaOscura, contorno: Color(0xFFD3A0E3)),
  BsRol(relleno: Color(0xFF4E1D42), texto: _tintaOscura, contorno: Color(0xFFE3A0D3)),
  BsRol(relleno: Color(0xFF4E1D2A), texto: _tintaOscura, contorno: Color(0xFFE3A0B1)),
];
