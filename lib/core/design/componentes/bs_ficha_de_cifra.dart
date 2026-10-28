import 'package:flutter/material.dart';

import '../bs_colores_semanticos.dart';
import '../bs_tipografia.dart';

/// Una ficha del resumen del modo (`DESIGN.md`, 14.7): el rótulo en tinta
/// suave y el dato en tinta con cifras tabulares («Carga: 29 pendientes, 20
/// llenos, 9 vacíos»). Va en una línea que envuelve si no cabe; nunca con
/// elipsis. Con [rol] (revisar, para lo que falta), las dos partes toman el
/// contorno del rol.
class BsFichaDeCifra extends StatelessWidget {
  /// Crea la ficha.
  const BsFichaDeCifra({
    super.key,
    this.rotulo,
    required this.valor,
    this.rol,
  });

  /// Qué se cuenta («Carga», «Bahía 10»); sin él, solo el dato.
  final String? rotulo;

  /// El dato ya formateado.
  final String valor;

  /// El rol que la tiñe (revisar).
  final BsRol? rol;

  /// El texto entero, como se lee.
  String get texto => rotulo == null ? valor : '$rotulo: $valor';

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final esquema = tema.colorScheme;
    final base = tema.textTheme.bodyMedium;
    final acento = rol?.contorno;
    return Text.rich(
      TextSpan(
        style: base,
        children: <InlineSpan>[
          if (rotulo != null)
            TextSpan(
              text: '$rotulo: ',
              style: TextStyle(color: acento ?? esquema.onSurfaceVariant),
            ),
          TextSpan(
            text: valor,
            style: TextStyle(
              color: acento ?? esquema.onSurface,
              fontWeight: FontWeight.w500,
              fontFeatures: cifrasTabulares,
            ),
          ),
        ],
      ),
      softWrap: true,
    );
  }
}
