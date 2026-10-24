import 'package:flutter/material.dart';

import '../bs_colores_semanticos.dart';
import '../bs_medidas.dart';
import '../bs_paleta.dart';
import '../bs_tipografia.dart';

/// La tarjeta de cifra grande del mosaico del puente de mando (`DESIGN.md`,
/// 13.6): el rótulo arriba, la cifra tabular en grande y el detalle al pie;
/// con [rol], la cifra, el rótulo y el borde toman el color del rol (aviso
/// para las alertas); con [anillo], un `BsAnilloAvance` a la izquierda.
///
/// Es un panel: hoja, radio de panel y borde en línea. Si lleva [onTap], es un
/// botón con la etiqueta completa.
///
/// [corta] es la tarjeta del panel del buque en la oficina (14.2): 12 dp de
/// aire, el anillo a la izquierda, el rótulo encima de la cifra a 28 y sin la
/// línea del detalle, que va en la etiqueta y en la descripción emergente.
/// Mide 72 dp de alto con la letra a 1.0.
class BsTarjetaCifra extends StatelessWidget {
  /// Crea la tarjeta.
  const BsTarjetaCifra({
    super.key,
    required this.valor,
    required this.rotulo,
    this.detalle,
    this.rol,
    this.anillo,
    this.onTap,
    this.corta = false,
  });

  /// El ancho de la tarjeta corta con la letra a 1.0: «120 de 150» a 28 junto
  /// al anillo de 40 (14.2). Crece con la escala de la letra.
  static const double anchoCorta = 224;

  /// El anillo de la tarjeta corta.
  static const double anilloCorta = 40;

  /// La cifra ya formateada («30», «80 %», «120 de 150»).
  final String valor;

  /// El rótulo («Por bajar»).
  final String rotulo;

  /// El detalle al pie («18 en la bahía 14»).
  final String? detalle;

  /// El rol que tiñe la tarjeta (revisar para las alertas).
  final BsRol? rol;

  /// El anillo de avance, a la izquierda de la cifra.
  final Widget? anillo;

  /// Qué pasa al tocarla; sin él, no es un botón.
  final VoidCallback? onTap;

  /// La tarjeta corta del panel del buque (14.2).
  final bool corta;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final medidas = BsMedidas.de(context);
    final semanticos = BsColoresSemanticos.de(context);
    final esquema = tema.colorScheme;
    final paleta = BsPaleta.de(tema.brightness);
    final textos = tema.textTheme;
    final propios = tema.extension<BsTextos>();
    final acento = rol?.contorno;
    final radio = BorderRadius.circular(medidas.radioPanel);
    final estiloCifra = (propios?.cifraGrande ?? textos.displayLarge)?.copyWith(
      color: acento ?? esquema.onSurface,
    );
    final descripcion = <String>[
      '$rotulo: $valor',
      if (detalle != null) detalle!,
    ].join(', ');

    final contenido = corta
        ? Padding(
            padding: EdgeInsets.all(medidas.espacioM),
            child: Row(
              children: <Widget>[
                if (anillo != null) ...<Widget>[
                  anillo!,
                  SizedBox(width: medidas.espacioS),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        rotulo,
                        style: textos.labelMedium?.copyWith(
                          color: acento ?? esquema.onSurfaceVariant,
                        ),
                      ),
                      // La cifra se encoge antes que cortarse, como en la
                      // tarjeta grande.
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          valor,
                          maxLines: 1,
                          style: textos.headlineLarge?.copyWith(
                            color: acento ?? esquema.onSurface,
                            fontFeatures: cifrasTabulares,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        : Padding(
            padding: EdgeInsets.all(medidas.espacioL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  rotulo,
                  style: textos.titleSmall?.copyWith(
                    color: acento ?? esquema.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: medidas.espacioS),
                Row(
                  children: <Widget>[
                    if (anillo != null) ...<Widget>[
                      anillo!,
                      SizedBox(width: medidas.espacioM),
                    ],
                    // La cifra se encoge antes que cortarse: con la letra del
                    // sistema a 2.0, «120 de 150» no cabe junto al anillo.
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(valor, style: estiloCifra, maxLines: 1),
                      ),
                    ),
                  ],
                ),
                if (detalle != null) ...<Widget>[
                  SizedBox(height: medidas.espacioXs),
                  Text(
                    detalle!,
                    style: textos.bodySmall
                        ?.copyWith(color: semanticos.tintaTenue),
                  ),
                ],
              ],
            ),
          );

    // La corta no dibuja el detalle: va en la descripción emergente.
    final conDetalle = corta && detalle != null
        ? Tooltip(
            message: detalle!,
            excludeFromSemantics: true,
            child: contenido,
          )
        : contenido;

    return Semantics(
      label: descripcion,
      button: onTap != null,
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: paleta.hoja,
        shape: RoundedRectangleBorder(
          borderRadius: radio,
          side: BorderSide(
            color: acento == null
                ? esquema.outlineVariant
                : Color.alphaBlend(
                    acento.withValues(alpha: 0.35),
                    paleta.hoja,
                  ),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: onTap == null
            ? conDetalle
            : InkWell(onTap: onTap, child: conDetalle),
      ),
    );
  }
}
