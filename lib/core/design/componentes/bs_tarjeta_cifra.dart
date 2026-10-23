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
  });

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

    final contenido = Padding(
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
              style: textos.bodySmall?.copyWith(color: semanticos.tintaTenue),
            ),
          ],
        ],
      ),
    );

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
            ? contenido
            : InkWell(onTap: onTap, child: contenido),
      ),
    );
  }
}
