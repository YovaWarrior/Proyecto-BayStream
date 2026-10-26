import 'package:flutter/material.dart';

import '../bs_colores_semanticos.dart';
import '../bs_medidas.dart';
import '../bs_tipografia.dart';

/// La caja del código de puerto (`DESIGN.md`, 15.3 y 15.5): el relleno, el
/// código en Plex Mono y el contorno del rol categórico del puerto (5.3 y
/// 13.4). Es el único sitio donde Estadísticas lleva el color del puerto, y
/// enlaza con el plano sin colorear la barra: el validador de la skill de
/// dataviz rechaza las fichas como relleno de serie (0.9.4). El código va
/// siempre escrito: el color nunca va solo.
class BsCajaDeCodigo extends StatelessWidget {
  /// Crea la caja.
  const BsCajaDeCodigo({super.key, required this.codigo, required this.rol});

  /// El código («GTSTC»).
  final String codigo;

  /// El rol categórico del puerto (`BsColoresSemanticos.categorico`).
  final BsRol rol;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final medidas = BsMedidas.de(context);
    final mono = tema.extension<BsTextos>()?.datoMono ?? tema.textTheme.bodyMedium;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: medidas.espacioS - 2,
        vertical: medidas.espacioXs - 2,
      ),
      decoration: BoxDecoration(
        color: rol.relleno,
        borderRadius: BorderRadius.circular(medidas.radioControl),
        border: Border.all(color: rol.contorno),
      ),
      child: Text(
        codigo,
        maxLines: 1,
        style: mono?.copyWith(
          fontSize: BsEscala.rotulo,
          fontWeight: FontWeight.w600,
          height: 1.2,
          color: rol.texto,
        ),
      ),
    );
  }
}
