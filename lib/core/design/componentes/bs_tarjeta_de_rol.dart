import 'package:flutter/material.dart';

import '../bs_colores_semanticos.dart';
import '../bs_medidas.dart';
import '../bs_tipografia.dart';

/// La tarjeta de carga especial de Estadísticas (`DESIGN.md`, 15.5): el
/// relleno y el contorno del rol (peligrosa, refrigerado u OOG; 5.1), el icono
/// del paquete (13.11) en el contorno, la cifra a 28 tabular y el rótulo, los
/// dos en el texto del rol. El color nunca va solo: lleva el icono y el
/// rótulo, y el uva de OOG es su rol, no un adorno.
///
/// Está verificada compuesta: el texto sobre el relleno llega a 4.5:1 y el
/// contorno y el icono sobre el relleno a 3:1 en los dos modos
/// (`test/t121_estadisticas_test.dart`).
class BsTarjetaDeRol extends StatelessWidget {
  /// Crea la tarjeta.
  const BsTarjetaDeRol({
    super.key,
    required this.rol,
    required this.icono,
    required this.valor,
    required this.rotulo,
  });

  /// El rol que la pinta.
  final BsRol rol;

  /// El icono del paquete («peligrosa», «refrigerado», «fueraDeMedida»).
  final IconData icono;

  /// La cifra ya formateada («3»).
  final String valor;

  /// El rótulo («Peligrosa IMDG»).
  final String rotulo;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final medidas = BsMedidas.de(context);
    final textos = tema.textTheme;
    return Semantics(
      label: '$rotulo: $valor',
      excludeSemantics: true,
      child: Container(
        padding: EdgeInsets.all(medidas.espacioM),
        decoration: BoxDecoration(
          color: rol.relleno,
          borderRadius: BorderRadius.circular(medidas.radioHoja),
          border: Border.all(color: rol.contorno),
        ),
        child: Row(
          children: <Widget>[
            Icon(icono, size: 24, color: rol.contorno),
            SizedBox(width: medidas.espacioM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    valor,
                    style: textos.headlineLarge?.copyWith(
                      color: rol.texto,
                      fontFeatures: cifrasTabulares,
                    ),
                  ),
                  Text(
                    rotulo,
                    style: textos.labelMedium?.copyWith(color: rol.texto),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
