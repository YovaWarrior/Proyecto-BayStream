import 'package:flutter/material.dart';

import '../bs_colores_semanticos.dart';
import '../bs_medidas.dart';
import 'bs_cifra.dart';

/// Un contador de la barra de operación: su valor, su rótulo y, si procede,
/// un rol que lo tiñe.
@immutable
class BsContador {
  /// Crea el contador.
  const BsContador({required this.valor, required this.rotulo, this.rol});

  /// El valor ya formateado («18»).
  final String valor;

  /// El rótulo («por bajar»).
  final String rotulo;

  /// Un rol semántico para teñirlo.
  final BsRol? rol;
}

/// La barra de operación del muelle, la pieza de la dirección B que Carlos
/// trajo a la A (10.4): al pie del plano, con las dos o tres cifras que
/// importan, el aviso del último registro y la acción principal (el campo de
/// OR con el micrófono en Carga, «Pendientes por bahía» en Descarga).
///
/// Vive sobre la hoja alta, con una línea arriba; todo lo que se toca dentro
/// mide al menos 48 dp.
class BsBarraDeOperacion extends StatelessWidget {
  /// Crea la barra.
  const BsBarraDeOperacion({
    super.key,
    required this.contadores,
    this.aviso,
    this.accion,
  });

  /// Las cifras, de izquierda a derecha.
  final List<BsContador> contadores;

  /// El aviso del último registro (normalmente un [BsAvisoDeOperacion]).
  final Widget? aviso;

  /// La acción principal.
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    final medidas = BsMedidas.de(context);
    final esquema = Theme.of(context).colorScheme;
    return Material(
      color: esquema.surfaceContainerHigh,
      child: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: esquema.outlineVariant)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              medidas.espacioL,
              medidas.espacioM,
              medidas.espacioL,
              medidas.espacioM,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (final contador in contadores)
                      Expanded(
                        child: BsCifra(
                          valor: contador.valor,
                          rotulo: contador.rotulo,
                          rol: contador.rol,
                        ),
                      ),
                  ],
                ),
                if (aviso != null)
                  Padding(
                    padding: EdgeInsets.only(top: medidas.espacioS),
                    child: aviso,
                  ),
                if (accion != null)
                  Padding(
                    padding: EdgeInsets.only(top: medidas.espacioS),
                    child: accion,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// El aviso del último registro dentro de la barra: icono de hecho, el texto
/// («Descarga registrada, MSCU 123456 7») y «Deshacer».
class BsAvisoDeOperacion extends StatelessWidget {
  /// Crea el aviso.
  const BsAvisoDeOperacion({
    super.key,
    required this.texto,
    this.accion,
    this.onAccion,
  });

  /// El texto.
  final String texto;

  /// El rótulo de la acción («Deshacer»).
  final String? accion;

  /// Qué hace la acción.
  final VoidCallback? onAccion;

  @override
  Widget build(BuildContext context) {
    final medidas = BsMedidas.de(context);
    final semanticos = BsColoresSemanticos.de(context);
    final textos = Theme.of(context).textTheme;
    return Semantics(
      container: true,
      liveRegion: true,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: medidas.objetivoTactil),
        child: Row(
          children: <Widget>[
            Icon(Icons.check_circle_outline, color: semanticos.hecho.contorno),
            SizedBox(width: medidas.espacioS),
            Expanded(child: Text(texto, style: textos.bodyMedium)),
            if (accion != null)
              TextButton(onPressed: onAccion, child: Text(accion!)),
          ],
        ),
      ),
    );
  }
}
