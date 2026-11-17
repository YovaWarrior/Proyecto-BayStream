import 'package:flutter/material.dart';

import '../bs_formato.dart';
import '../bs_tipografia.dart';

/// Un número de contenedor como dato: «MSCU 123456 7», en mono y con cifras
/// tabulares (`DESIGN.md`, sección 11, regla 5).
///
/// El [estilo] solo cambia tamaño, peso o color: la familia mono y las cifras
/// tabulares se mantienen siempre.
///
/// T-144, corrección 2 (10.127): **nunca se corta ni lleva elipsis**. Si no
/// cabe en una línea, envuelve por sus grupos (propietario, serie y dígito),
/// que es donde `formatearContenedor` pone los espacios: el número es el dato
/// que identifica el contenedor y tiene que verse entero (RNF-003 en
/// `DESIGN.md` 10, y 17.5).
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
      softWrap: true,
      semanticsLabel: texto,
    );
  }
}
