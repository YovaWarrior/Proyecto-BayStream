import 'package:flutter/material.dart';

import '../bs_formato.dart';
import '../bs_tipografia.dart';

/// Un número de contenedor como dato: «MSCU 123456 7», en mono y con cifras
/// tabulares (`DESIGN.md`, sección 11, regla 5).
///
/// El [estilo] solo cambia tamaño, peso o color: la familia mono y las cifras
/// tabulares se mantienen siempre.
class BsNumeroDeContenedor extends StatelessWidget {
  /// Crea el número a partir del identificador tal como lo trae el archivo.
  const BsNumeroDeContenedor(this.numero, {super.key, this.estilo});

  /// El identificador, con o sin espacios.
  final String numero;

  /// Un estilo base distinto de `datoMono` (por ejemplo, el título de la hoja
  /// de detalle).
  final TextStyle? estilo;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).extension<BsTextos>();
    final base = estilo ?? textos?.datoMono ?? DefaultTextStyle.of(context).style;
    final texto = formatearContenedor(numero);
    return Text(
      texto,
      style: base.copyWith(
        fontFamily: BsFuentes.mono,
        fontFamilyFallback: BsFuentes.respaldo,
        fontFeatures: cifrasTabulares,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      semanticsLabel: texto,
    );
  }
}
