import 'package:flutter/material.dart';

import '../bs_colores_semanticos.dart';
import '../bs_formato.dart';
import '../bs_medidas.dart';
import '../bs_paleta.dart';
import '../bs_tipografia.dart';
import 'bs_caja_de_codigo.dart';

/// Una barra de magnitud de Estadísticas (`DESIGN.md`, 15.5): el rótulo (o
/// la caja del código, con [caja]), la barra de [altoDeBarra] sobre su pista,
/// la cifra y el porcentaje del total. En una línea si el ancho llega a
/// [anchoDeUnaLinea] por la escala de la letra; si no, **la etiqueta va
/// encima de su barra**, con la cifra y el porcentaje a la derecha, y la barra
/// a todo el ancho (0.9.3).
///
/// El largo es [valor] entre [maximo] (la barra más larga del panel llena el
/// ancho); el porcentaje, [valor] entre [total]. El color es [color] o la
/// marca (`ColorScheme.primary`: la marca de día, la selección de noche); el
/// texto nunca lleva el color del dato. La etiqueta para el lector de pantalla
/// y la descripción emergente dicen lo mismo: «GTSTC: 520 contenedores, 53 %».
/// El extremo del dato va redondeado y la base cuadrada; la pista es un paso
/// más del mismo tono (`BsPaleta.pistaDeMagnitud`).
class BsBarraDeMagnitud extends StatelessWidget {
  /// Crea la barra.
  const BsBarraDeMagnitud({
    super.key,
    required this.rotulo,
    required this.valor,
    required this.total,
    required this.maximo,
    this.color,
    this.caja,
    this.enMono = false,
    this.singular = 'contenedor',
    this.plural = 'contenedores',
  });

  /// El rótulo («GTSTC», «Otros 3 puertos», «20 pies»).
  final String rotulo;

  /// Cuántos.
  final int valor;

  /// El total del que [valor] es parte, para el porcentaje.
  final int total;

  /// El valor de la barra más larga del panel, para el largo.
  final int maximo;

  /// El color de la barra; por omisión, la marca.
  final Color? color;

  /// Con él, el rótulo va en la caja del código con ese rol categórico.
  final BsRol? caja;

  /// El rótulo en Plex Mono (un código sin caja: una naviera).
  final bool enMono;

  /// La palabra que concuerda con [valor], en singular y en plural.
  final String singular;
  final String plural;

  /// El alto de la barra: nunca más de 24.
  static const double altoDeBarra = 12;

  /// Desde este ancho, por la escala de la letra, la barra va en una línea.
  static const double anchoDeUnaLinea = 400;

  /// El ancho del rótulo en la variante de una línea («Otras 12 navieras»).
  static const double anchoDelRotulo = 120;

  /// El ancho de la cifra y del porcentaje en la variante de una línea.
  static const double anchoDeCifra = 48;

  /// La fracción del total.
  double get fraccionDelTotal => total <= 0 ? 0 : valor / total;

  /// La etiqueta: el rótulo, la cuenta y el porcentaje.
  String get etiqueta => '$rotulo: ${formatearCuenta(valor, singular, plural)}, '
      '${formatearPorcentaje(fraccionDelTotal)}';

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final medidas = BsMedidas.de(context);
    final paleta = BsPaleta.de(tema.brightness);
    final esquema = tema.colorScheme;
    final textos = tema.textTheme;
    final escala = MediaQuery.textScalerOf(context);
    final mono = tema.extension<BsTextos>()?.datoMono;
    final estiloRotulo = (enMono
            ? mono?.copyWith(
                fontSize: BsEscala.rotulo,
                fontWeight: FontWeight.w500,
                height: 1.2,
              )
            : textos.labelMedium)
        ?.copyWith(color: esquema.onSurface);
    final estiloCifra = textos.labelMedium?.copyWith(
      color: esquema.onSurface,
      fontFeatures: cifrasTabulares,
    );
    final estiloPorcentaje = textos.labelMedium?.copyWith(
      color: esquema.onSurfaceVariant,
      fontFeatures: cifrasTabulares,
    );
    final largo =
        maximo <= 0 ? 0.0 : (valor / maximo).clamp(0.0, 1.0).toDouble();
    final radio = Radius.circular(medidas.espacioXs);

    final rotuloWidget = caja != null
        ? BsCajaDeCodigo(codigo: rotulo, rol: caja!)
        : Text(rotulo, style: estiloRotulo);
    final barra = SizedBox(
      height: altoDeBarra,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: paleta.pistaDeMagnitud,
          borderRadius: BorderRadius.horizontal(right: radio),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: largo,
            heightFactor: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color ?? esquema.primary,
                borderRadius: BorderRadius.horizontal(right: radio),
              ),
            ),
          ),
        ),
      ),
    );
    final cifra = Text('$valor', style: estiloCifra, textAlign: TextAlign.end);
    final porcentaje = Text(
      formatearPorcentaje(fraccionDelTotal),
      style: estiloPorcentaje,
      textAlign: TextAlign.end,
    );

    return Semantics(
      label: etiqueta,
      excludeSemantics: true,
      child: Tooltip(
        message: etiqueta,
        excludeFromSemantics: true,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints restricciones) {
            // Sin ancho acotado (una Row sin Expanded, un desplazable
            // horizontal) la barra se da el ancho de una línea: la pista
            // tiene que medir algo.
            if (!restricciones.hasBoundedWidth) {
              return SizedBox(
                width: escala.scale(anchoDeUnaLinea),
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: escala.scale(anchoDelRotulo),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        heightFactor: 1,
                        child: rotuloWidget,
                      ),
                    ),
                    SizedBox(width: medidas.espacioS),
                    Expanded(child: barra),
                    SizedBox(width: medidas.espacioS),
                    SizedBox(width: escala.scale(anchoDeCifra), child: cifra),
                    SizedBox(width: medidas.espacioXs),
                    SizedBox(width: escala.scale(anchoDeCifra), child: porcentaje),
                  ],
                ),
              );
            }
            if (restricciones.maxWidth >= escala.scale(anchoDeUnaLinea)) {
              return Row(
                children: <Widget>[
                  SizedBox(
                    width: escala.scale(anchoDelRotulo),
                    // Con el alto a su medida: sin el factor, un Align con
                    // alto acotado se estira a todo el que le dan.
                    child: Align(
                      alignment: Alignment.centerLeft,
                      heightFactor: 1,
                      child: rotuloWidget,
                    ),
                  ),
                  SizedBox(width: medidas.espacioS),
                  Expanded(child: barra),
                  SizedBox(width: medidas.espacioS),
                  SizedBox(width: escala.scale(anchoDeCifra), child: cifra),
                  SizedBox(width: medidas.espacioXs),
                  SizedBox(width: escala.scale(anchoDeCifra), child: porcentaje),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        heightFactor: 1,
                        child: rotuloWidget,
                      ),
                    ),
                    SizedBox(width: medidas.espacioS),
                    cifra,
                    SizedBox(width: medidas.espacioS),
                    porcentaje,
                  ],
                ),
                SizedBox(height: medidas.espacioXs),
                barra,
              ],
            );
          },
        ),
      ),
    );
  }
}
