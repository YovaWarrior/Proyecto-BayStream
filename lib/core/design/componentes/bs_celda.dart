import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../bs_colores_semanticos.dart';
import '../bs_medidas.dart';
import '../bs_paleta.dart';
import '../bs_tipografia.dart';

/// La insignia de carga especial que la celda lleva en su esquina, siempre,
/// en cualquiera de las tres vistas de «Colorear por».
enum BsInsigniaDeCelda {
  /// Sin carga especial.
  ninguna,

  /// Mercancía peligrosa (IMO).
  peligrosa,

  /// Refrigerado.
  refrigerado,

  /// Sobredimensionado (OOG).
  oog,
}

/// La marca de la operación sobre la celda, en los modos Descarga y Carga:
/// icono y rótulo además del color, para leerse a 360 dp y en los dos temas.
enum BsMarcaDeCelda {
  /// Sin marca: la celda muestra su código.
  ninguna,

  /// Pendiente de descarga: «Baja».
  baja,

  /// Pendiente de carga: «Sube».
  sube,

  /// Descargado o cargado: «Hecho».
  hecho,

  /// Sigue a bordo en esta escala: «Paso».
  paso,

  /// Cancelado por la oficina.
  cancelado,

  /// Conflicto en la bitácora: «Revisar».
  revisar,

  /// Re‑estiba: sale y vuelve.
  reestiba,
}

/// La celda del plano: un contenedor, una reserva o un hueco (`DESIGN.md`,
/// secciones 4.3 y 5).
///
/// Mide lo que dicen las medidas del tema (56 × 48 en el muelle, 52 × 48 en la
/// oficina): nunca menos de 48 dp de alto, para tocarla con guantes. El
/// relleno es la [categoria] (el destino o el tipo); la [insignia] y la
/// [marca] llevan icono y rótulo, así que el color nunca es la única señal.
///
/// Lo que se dibuja cumple el contraste en todos los estados, compuesto sobre
/// el papel (`test/t114_celda_contraste_test.dart`): el código 4.5:1 sobre el
/// relleno compuesto, y el contorno y los iconos 3:1. [atenuada] baja el
/// relleno a un 35 % compuesto sobre el papel (opaco, sin [Opacity]) y pone el
/// código en tinta suave y el contorno en línea fuerte, que siguen cumpliendo;
/// nunca alfa en el texto (10.7, H1). La [linea2] de 10 sp solo se dibuja en la oficina, con [zoom]
/// de 100 % o más y si cabe con la escala de letra del sistema; en el muelle
/// nunca (`DESIGN.md`, 4.2; 10.7, H2).
class BsCelda extends StatelessWidget {
  /// Crea una celda.
  const BsCelda({
    super.key,
    required this.codigo,
    required this.etiqueta,
    this.categoria,
    this.linea2,
    this.insignia = BsInsigniaDeCelda.ninguna,
    this.marca = BsMarcaDeCelda.ninguna,
    this.resaltada = false,
    this.atenuada = false,
    this.reservada = false,
    this.zoom = 1.0,
    this.onTap,
  });

  /// El texto principal: el puerto con sus cinco letras, el tipo ISO o el
  /// número de orden.
  final String codigo;

  /// La etiqueta de accesibilidad completa, con el número de contenedor, la
  /// posición y lo que la celda muestra. Se conserva en todos los estados.
  final String etiqueta;

  /// El rol de color del relleno. Sin él, la celda es un hueco.
  final BsRol? categoria;

  /// La segunda línea: el peso en toneladas o el tipo. Solo se dibuja en la
  /// oficina, con [zoom] de 1.0 o más, sin marca y si cabe; en el muelle se
  /// ignora aunque venga.
  final String? linea2;

  /// La insignia de carga especial.
  final BsInsigniaDeCelda insignia;

  /// La marca de la operación.
  final BsMarcaDeCelda marca;

  /// Resaltada por una búsqueda o una alerta: contorno de grúa.
  final bool resaltada;

  /// Fuera del filtro de «Resaltar»: relleno al [alfaAtenuada], código en
  /// tinta suave y contorno en línea fuerte.
  final bool atenuada;

  /// Una reserva: solo contorno, sin relleno.
  final bool reservada;

  /// El factor de zoom de la rejilla: 1.0 es 100 %. Gobierna la [linea2]; el
  /// tamaño de la celda lo decide la rejilla, no este parámetro.
  final double zoom;

  /// Qué pasa al tocarla. Sin él, la celda no es un botón.
  final VoidCallback? onTap;

  /// El alfa del relleno de una celda atenuada.
  static const double alfaAtenuada = 0.35;

  /// El tamaño del icono de la marca.
  static const double tamanoIconoDeMarca = 14;

  /// El tamaño de la insignia de la esquina.
  static const double tamanoInsignia = 12;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final medidas = BsMedidas.de(context);
    final semanticos = BsColoresSemanticos.de(context);
    final textos =
        tema.extension<BsTextos>() ?? BsTextos.de(BsPaleta.de(tema.brightness));
    final esquema = tema.colorScheme;
    final escala = MediaQuery.textScalerOf(context);

    final esHueco = categoria == null && !reservada;
    final hueco = BsRol(
      relleno: esquema.surfaceContainerLow,
      texto: esquema.onSurfaceVariant,
      contorno: esquema.outlineVariant,
    );
    final base = categoria ?? (reservada ? semanticos.reservado : hueco);
    final rolDeMarca = switch (marca) {
      BsMarcaDeCelda.ninguna => null,
      BsMarcaDeCelda.baja || BsMarcaDeCelda.sube => semanticos.pendiente,
      BsMarcaDeCelda.hecho => semanticos.hecho,
      BsMarcaDeCelda.paso => semanticos.dePaso,
      BsMarcaDeCelda.cancelado => semanticos.cancelado,
      BsMarcaDeCelda.revisar => semanticos.revisar,
      BsMarcaDeCelda.reestiba => semanticos.enMovimiento,
    };
    final rol = rolDeMarca ?? base;
    // Atenuada (10.7): baja el relleno, compuesto sobre el papel; el código y
    // el contorno cambian de color, no de alfa. El hueco conserva su línea.
    final efectivo = atenuada
        ? rol.atenuado(
            papel: esquema.surface,
            tintaSuave: esquema.onSurfaceVariant,
            lineaFuerte:
                esHueco && rolDeMarca == null ? rol.contorno : esquema.outline,
            alfa: alfaAtenuada,
          )
        : rol;
    final contorno = resaltada ? esquema.tertiary : efectivo.contorno;
    final grosor = resaltada ? 3.0 : medidas.grosorContornoCelda;
    final insigniaRol = switch (insignia) {
      BsInsigniaDeCelda.ninguna => null,
      BsInsigniaDeCelda.peligrosa => semanticos.peligrosa,
      BsInsigniaDeCelda.refrigerado => semanticos.refrigerado,
      BsInsigniaDeCelda.oog => semanticos.oog,
    };
    // La insignia va siempre y se lee sobre cualquier relleno: el color de su
    // rol si llega a 3:1 sobre el relleno; si no (los rellenos intensos en
    // oscuro, el naranja), el texto del rol o la tinta de la celda, que
    // siempre llegan. Atenuada, tinta suave: nunca alfa.
    final colorDeInsignia = insigniaRol == null
        ? null
        : atenuada
            ? esquema.onSurfaceVariant
            : _legibleSobre(efectivo.relleno, <Color>[
                insigniaRol.contorno,
                insigniaRol.texto,
                efectivo.texto,
              ]);

    // Qué cabe en el alto interior con la escala de letra del sistema: nada
    // se corta ni desborda a 1.45 ni a 2.0 (RNF-003). Las líneas miden
    // tamaño × interlínea, porque los estilos de la celda fijan `height`.
    final altoInterior = medidas.altoCelda - 2 * grosor;
    double altoDe(TextStyle estilo) =>
        escala.scale(estilo.fontSize ?? BsEscala.celda) * (estilo.height ?? 1);
    final altoDelCodigo = altoDe(textos.celda);
    final conMarca = marca != BsMarcaDeCelda.ninguna;
    final muestraIcono =
        conMarca && altoDelCodigo + tamanoIconoDeMarca <= altoInterior;
    final muestraLinea2 = linea2 != null &&
        !conMarca &&
        !medidas.esMuelle &&
        zoom >= 1.0 &&
        altoDelCodigo + altoDe(textos.celdaLinea2) <= altoInterior;

    final cuerpo = Container(
      width: medidas.anchoCelda,
      height: medidas.altoCelda,
      decoration: BoxDecoration(
        color: efectivo.relleno,
        borderRadius: BorderRadius.circular(medidas.radioCelda),
        border: Border.all(color: contorno, width: grosor),
      ),
      child: Stack(
        children: <Widget>[
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (muestraIcono)
                  Icon(
                    _iconoDeMarca(marca),
                    size: tamanoIconoDeMarca,
                    color: efectivo.texto,
                  ),
                Text(
                  conMarca ? _rotuloDeMarca(marca) : codigo,
                  style: textos.celda.copyWith(color: efectivo.texto),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                if (muestraLinea2)
                  Text(
                    linea2!,
                    style: textos.celdaLinea2.copyWith(color: efectivo.texto),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
          if (insigniaRol != null)
            Positioned(
              top: 1,
              right: 1,
              child: Icon(
                _iconoDeInsignia(insignia),
                size: tamanoInsignia,
                color: colorDeInsignia,
              ),
            ),
        ],
      ),
    );

    final conHueco = Padding(
      padding: EdgeInsets.all(medidas.huecoCelda / 2),
      child: onTap == null
          ? cuerpo
          : InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(medidas.radioCelda),
              child: cuerpo,
            ),
    );
    return Semantics(
      button: onTap != null,
      label: etiqueta,
      onTap: onTap,
      excludeSemantics: true,
      child: conHueco,
    );
  }

  /// El primer color de [candidatos] que llega a 3:1 sobre [fondo], el
  /// mínimo de un icono; si ninguno llega, el de mayor contraste.
  static Color _legibleSobre(Color fondo, List<Color> candidatos) {
    final lf = fondo.computeLuminance();
    var mejor = candidatos.first;
    var mejorContraste = 0.0;
    for (final color in candidatos) {
      final lc = color.computeLuminance();
      final contraste = (math.max(lf, lc) + 0.05) / (math.min(lf, lc) + 0.05);
      if (contraste >= 3) return color;
      if (contraste > mejorContraste) {
        mejorContraste = contraste;
        mejor = color;
      }
    }
    return mejor;
  }

  static IconData _iconoDeMarca(BsMarcaDeCelda marca) => switch (marca) {
        BsMarcaDeCelda.ninguna => Icons.circle_outlined,
        BsMarcaDeCelda.baja => Icons.south,
        BsMarcaDeCelda.sube => Icons.north,
        BsMarcaDeCelda.hecho => Icons.check_circle_outline,
        BsMarcaDeCelda.paso => Icons.directions_boat_outlined,
        BsMarcaDeCelda.cancelado => Icons.block,
        BsMarcaDeCelda.revisar => Icons.error_outline,
        BsMarcaDeCelda.reestiba => Icons.swap_vert,
      };

  static String _rotuloDeMarca(BsMarcaDeCelda marca) => switch (marca) {
        BsMarcaDeCelda.ninguna => '',
        BsMarcaDeCelda.baja => 'Baja',
        BsMarcaDeCelda.sube => 'Sube',
        BsMarcaDeCelda.hecho => 'Hecho',
        BsMarcaDeCelda.paso => 'Paso',
        BsMarcaDeCelda.cancelado => 'Cancelado',
        BsMarcaDeCelda.revisar => 'Revisar',
        BsMarcaDeCelda.reestiba => 'Re‑estiba',
      };

  static IconData _iconoDeInsignia(BsInsigniaDeCelda insignia) =>
      switch (insignia) {
        BsInsigniaDeCelda.ninguna => Icons.circle_outlined,
        BsInsigniaDeCelda.peligrosa => Icons.warning_amber_rounded,
        BsInsigniaDeCelda.refrigerado => Icons.ac_unit,
        BsInsigniaDeCelda.oog => Icons.open_in_full,
      };
}
