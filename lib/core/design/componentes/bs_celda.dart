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
/// [atenuada] usa alfa en los colores, no un [Opacity].
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
    this.onTap,
  });

  /// El texto principal: el puerto con sus cinco letras, el tipo ISO o el
  /// número de orden.
  final String codigo;

  /// La etiqueta de accesibilidad completa, con el número de contenedor, la
  /// posición y lo que la celda muestra.
  final String etiqueta;

  /// El rol de color del relleno. Sin él, la celda es un hueco.
  final BsRol? categoria;

  /// La segunda línea: el peso en toneladas o el tipo.
  final String? linea2;

  /// La insignia de carga especial.
  final BsInsigniaDeCelda insignia;

  /// La marca de la operación.
  final BsMarcaDeCelda marca;

  /// Resaltada por una búsqueda o una alerta: contorno de grúa.
  final bool resaltada;

  /// Fuera del filtro activo.
  final bool atenuada;

  /// Una reserva: solo contorno, sin relleno.
  final bool reservada;

  /// Qué pasa al tocarla. Sin él, la celda no es un botón.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final medidas = BsMedidas.de(context);
    final semanticos = BsColoresSemanticos.de(context);
    final textos = Theme.of(context).extension<BsTextos>() ??
        BsTextos.de(BsPaleta.de(Theme.of(context).brightness));
    final esquema = Theme.of(context).colorScheme;
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
    final efectivo = atenuada ? rol.atenuado(0.35) : rol;
    final contorno = resaltada ? esquema.tertiary : efectivo.contorno;
    final grosor = resaltada ? 3.0 : medidas.grosorContornoCelda;
    final insigniaRol = switch (insignia) {
      BsInsigniaDeCelda.ninguna => null,
      BsInsigniaDeCelda.peligrosa => semanticos.peligrosa,
      BsInsigniaDeCelda.refrigerado => semanticos.refrigerado,
      BsInsigniaDeCelda.oog => semanticos.oog,
    };

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
                if (marca != BsMarcaDeCelda.ninguna)
                  Icon(_iconoDeMarca(marca), size: 14, color: efectivo.texto),
                Text(
                  marca == BsMarcaDeCelda.ninguna
                      ? codigo
                      : _rotuloDeMarca(marca),
                  style: textos.celda.copyWith(color: efectivo.texto),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                if (linea2 != null && marca == BsMarcaDeCelda.ninguna)
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
                size: 12,
                color: atenuada
                    ? insigniaRol.contorno.withValues(alpha: 0.35)
                    : insigniaRol.contorno,
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
