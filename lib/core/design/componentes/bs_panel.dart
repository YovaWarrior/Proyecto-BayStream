import 'package:flutter/material.dart';

import '../bs_medidas.dart';
import '../bs_paleta.dart';

/// El panel de Estadísticas (`DESIGN.md`, 15.5): la hoja, el radio de panel
/// del puente de mando (13.10) y el borde en línea, con su título en tipo
/// oración como encabezado para el lector de pantalla y, a la derecha, una
/// acción opcional. Lo que va dentro lo decide la pantalla.
class BsPanel extends StatelessWidget {
  /// Crea el panel.
  const BsPanel({
    super.key,
    required this.titulo,
    required this.child,
    this.accion,
  });

  /// El título («Por puerto de descarga»).
  final String titulo;

  /// Lo que va dentro.
  final Widget child;

  /// Un control a la derecha del título, si hace falta.
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final medidas = BsMedidas.de(context);
    final paleta = BsPaleta.de(tema.brightness);
    final esquema = tema.colorScheme;
    return Container(
      padding: EdgeInsets.all(medidas.espacioL),
      decoration: BoxDecoration(
        color: paleta.hoja,
        borderRadius: BorderRadius.circular(medidas.radioPanel),
        border: Border.all(color: esquema.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(titulo, style: tema.textTheme.titleMedium),
                ),
              ),
              if (accion != null) ...<Widget>[
                SizedBox(width: medidas.espacioS),
                accion!,
              ],
            ],
          ),
          SizedBox(height: medidas.espacioM),
          child,
        ],
      ),
    );
  }
}
