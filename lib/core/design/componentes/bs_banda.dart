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
    final textos = Theme.of(context).textTheme;
    // Información: el rol «información» (13.1): de día el tinte de marca; de
    // noche el panel alto con el icono en selección, para que el icono llegue
    // a 3:1 (la marca como superficie no lo deja).
    final rol = switch (tono) {
      BsTonoDeBanda.informacion => semanticos.informacion,
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
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints restricciones) {
              // La acción va a la derecha del texto mientras quepa; en
              // pantallas angostas, y antes con la letra grande, baja a su
              // propia línea para que el texto no quede en una columna
              // (10.8 y 10.16: «Confirmar» a 360 dp con la letra a 2.0).
              final escala = MediaQuery.textScalerOf(context).scale(10) / 10;
              final apilada = accion != null &&
                  restricciones.maxWidth < (escala > 1.2 ? 520 : 400);
              final boton = accion == null
                  ? null
                  : FilledButton(
                      onPressed: onAccion,
                      child: Text(accion!),
                    );
              final cabecera = Row(
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
                  if (boton != null && !apilada) ...<Widget>[
                    SizedBox(width: medidas.espacioM),
                    boton,
                  ],
                  if (onCerrar != null)
                    IconButton(
                      onPressed: onCerrar,
                      tooltip: 'Cerrar el aviso',
                      icon: Icon(Icons.close, color: rol.contorno),
                    ),
                ],
              );
              if (!apilada) return cabecera;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  cabecera,
                  SizedBox(height: medidas.espacioS),
                  Align(alignment: Alignment.centerRight, child: boton),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
