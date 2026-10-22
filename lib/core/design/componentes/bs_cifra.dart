import 'package:flutter/material.dart';

import '../bs_colores_semanticos.dart';
import '../bs_medidas.dart';
import '../bs_tipografia.dart';

/// Una cifra con su rótulo: el KPI del avance, el contador de la barra de
/// operación, el total de Estadísticas (`DESIGN.md`, 4.3).
///
/// La cifra lleva dígitos tabulares y va primero; el rótulo, en tinta suave,
/// debajo; si hay [progreso], una barra de 8 dp de marca; si hay [detalle],
/// una línea pequeña al pie.
class BsCifra extends StatelessWidget {
  /// Crea la cifra.
  const BsCifra({
    super.key,
    required this.valor,
    required this.rotulo,
    this.detalle,
    this.progreso,
    this.rol,
  });

  /// El valor ya formateado («120 de 150», «28.7 t»).
  final String valor;

  /// El rótulo («Descargados»).
  final String rotulo;

  /// Una línea de detalle («80 %», «3 llenos, 15 vacíos»).
  final String? detalle;

  /// De 0 a 1, dibuja la barra de progreso.
  final double? progreso;

  /// Un rol semántico para teñir la cifra (por ejemplo, revisar).
  final BsRol? rol;

  @override
  Widget build(BuildContext context) {
    final medidas = BsMedidas.de(context);
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final propios = Theme.of(context).extension<BsTextos>();
    final estiloCifra = (propios?.cifraGrande ?? textos.displayLarge)
        ?.copyWith(color: rol?.contorno ?? esquema.onSurface);
    final descripcion = <String>[
      '$rotulo: $valor',
      if (detalle != null) detalle!,
    ].join(', ');
    return Semantics(
      label: descripcion,
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(valor, style: estiloCifra, maxLines: 1),
          Text(rotulo, style: textos.labelMedium?.copyWith(color: esquema.onSurfaceVariant)),
          if (progreso != null)
            Padding(
              padding: EdgeInsets.only(top: medidas.espacioS),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(medidas.espacioXs),
                child: LinearProgressIndicator(
                  value: progreso!.clamp(0.0, 1.0).toDouble(),
                ),
              ),
            ),
          if (detalle != null)
            Padding(
              padding: EdgeInsets.only(top: medidas.espacioXs),
              child: Text(detalle!, style: textos.bodySmall),
            ),
        ],
      ),
    );
  }
}
