import 'package:flutter/material.dart';

import '../bs_colores_semanticos.dart';
import '../bs_medidas.dart';

/// El tono de una banda: qué dice y con qué color y qué icono.
enum BsTonoDeBanda {
  /// Información: el plano sin confirmar, un dato que conviene saber.
  informacion,

  /// Aviso: algo que revisar antes de seguir.
  aviso,

  /// Error: algo que no se pudo hacer, con su causa y su acción.
  error,

  /// Confirmación: algo que se hizo.
  confirmacion,
}

/// La banda de aviso que se queda a la vista (`DESIGN.md`, 4.3 y 7): icono,
/// texto de una o dos líneas que crece con la letra y, si procede, una acción
/// con el mismo nombre que lo que hace («Confirmar»).
///
/// Es el aviso de «Plano sin confirmar» de la primera visualización y la
/// banda de «sin evaluar hasta confirmar el perfil».
class BsBanda extends StatelessWidget {
  /// Crea la banda.
  const BsBanda({
    super.key,
    required this.texto,
    this.tono = BsTonoDeBanda.informacion,
    this.icono,
    this.accion,
    this.onAccion,
    this.onCerrar,
  });

  /// El texto, en tipo oración y voz activa.
  final String texto;

  /// El tono.
  final BsTonoDeBanda tono;

  /// Un icono distinto del que el tono trae.
  final IconData? icono;

  /// El rótulo de la acción («Confirmar»). Sin él no hay botón.
  final String? accion;

  /// Qué hace la acción.
  final VoidCallback? onAccion;

  /// Si se puede cerrar, qué pasa al cerrarla.
  final VoidCallback? onCerrar;

  @override
  Widget build(BuildContext context) {
    final medidas = BsMedidas.de(context);
    final semanticos = BsColoresSemanticos.de(context);
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final rol = switch (tono) {
      BsTonoDeBanda.informacion => BsRol(
          relleno: esquema.primaryContainer,
          texto: esquema.onPrimaryContainer,
          contorno: esquema.primary,
        ),
      BsTonoDeBanda.aviso => semanticos.revisar,
      BsTonoDeBanda.error => semanticos.error,
      BsTonoDeBanda.confirmacion => semanticos.hecho,
    };
    final iconoDelTono = switch (tono) {
      BsTonoDeBanda.informacion => Icons.info_outline,
      BsTonoDeBanda.aviso => Icons.warning_amber_rounded,
      BsTonoDeBanda.error => Icons.error_outline,
      BsTonoDeBanda.confirmacion => Icons.check_circle_outline,
    };
    return Semantics(
      container: true,
      liveRegion: tono != BsTonoDeBanda.informacion,
      child: Material(
        color: rol.relleno,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: medidas.espacioL,
            vertical: medidas.espacioS,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(icono ?? iconoDelTono, color: rol.contorno),
              SizedBox(width: medidas.espacioM),
              Expanded(
                child: Text(
                  texto,
                  style: textos.bodyMedium?.copyWith(color: rol.texto),
                ),
              ),
              if (accion != null) ...<Widget>[
                SizedBox(width: medidas.espacioM),
                FilledButton(
                  onPressed: onAccion,
                  child: Text(accion!),
                ),
              ],
              if (onCerrar != null)
                IconButton(
                  onPressed: onCerrar,
                  tooltip: 'Cerrar el aviso',
                  icon: Icon(Icons.close, color: rol.contorno),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
