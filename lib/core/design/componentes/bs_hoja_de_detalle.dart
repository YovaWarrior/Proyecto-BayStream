import 'package:flutter/material.dart';

import '../bs_medidas.dart';
import '../bs_tipografia.dart';

/// Una fila del detalle: etiqueta y valor.
@immutable
class BsFilaDeDetalle {
  /// Crea la fila.
  const BsFilaDeDetalle(this.etiqueta, this.valor);

  /// La etiqueta («Posición», «Peso bruto»).
  final String etiqueta;

  /// El valor («Bahía 002, Fila 01, Nivel 82», «28 650 kg»).
  final String valor;
}

/// La única hoja de detalle del contenedor (`DESIGN.md`, decisión g de 10.2).
///
/// Se abre desde abajo con [mostrar]. Lleva un título (normalmente el número
/// de contenedor en mono), un subtítulo, las filas de etiqueta y valor, las
/// secciones extra (peligrosa, refrigerado, la operación) con un separador
/// delante, las acciones y el botón «Cerrar». Cada fila apila su valor bajo
/// la etiqueta cuando la hoja es estrecha o la letra grande, para que ningún
/// texto se corte a 360 dp con letra 2.0.
class BsHojaDeDetalle extends StatelessWidget {
  /// Crea la hoja.
  const BsHojaDeDetalle({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.filas = const <BsFilaDeDetalle>[],
    this.secciones = const <Widget>[],
    this.acciones = const <Widget>[],
    this.controlador,
    this.onCerrar,
  });

  /// El título, ya como widget (por ejemplo, `BsNumeroDeContenedor`).
  final Widget titulo;

  /// El subtítulo, en tinta suave.
  final String? subtitulo;

  /// Las filas de etiqueta y valor.
  final List<BsFilaDeDetalle> filas;

  /// Las secciones extra, cada una con un separador delante.
  final List<Widget> secciones;

  /// Las acciones, antes de «Cerrar».
  final List<Widget> acciones;

  /// El controlador de scroll que entrega [mostrar].
  final ScrollController? controlador;

  /// Qué hace «Cerrar»; si no se da, cierra la hoja.
  final VoidCallback? onCerrar;

  /// Abre una hoja de detalle con los gestos y tamaños de siempre.
  static Future<T?> mostrar<T>(
    BuildContext context, {
    required Widget Function(BuildContext context, ScrollController controlador)
        constructor,
  }) =>
      showModalBottomSheet<T>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (BuildContext context) => DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.3,
          maxChildSize: 0.92,
          expand: false,
          builder: constructor,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final medidas = BsMedidas.de(context);
    final textos = Theme.of(context).textTheme;
    return SingleChildScrollView(
      controller: controlador,
      padding: EdgeInsets.fromLTRB(
        medidas.espacioXl,
        medidas.espacioS,
        medidas.espacioXl,
        medidas.espacioXl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DefaultTextStyle.merge(
            style: textos.headlineSmall,
            child: titulo,
          ),
          if (subtitulo != null) ...<Widget>[
            SizedBox(height: medidas.espacioXs),
            Text(subtitulo!, style: textos.bodySmall),
          ],
          SizedBox(height: medidas.espacioL),
          for (final fila in filas) _FilaDeDetalle(fila: fila),
          for (final seccion in secciones) ...<Widget>[
            Divider(height: medidas.espacioXl),
            seccion,
          ],
          SizedBox(height: medidas.espacioXl),
          ...acciones,
          if (acciones.isNotEmpty) SizedBox(height: medidas.espacioS),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onCerrar ?? () => Navigator.of(context).maybePop(),
              child: const Text('Cerrar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilaDeDetalle extends StatelessWidget {
  const _FilaDeDetalle({required this.fila});

  final BsFilaDeDetalle fila;

  @override
  Widget build(BuildContext context) {
    final medidas = BsMedidas.de(context);
    final textos = Theme.of(context).textTheme;
    final esquema = Theme.of(context).colorScheme;
    final etiqueta = Text(
      fila.etiqueta,
      style: textos.bodyMedium?.copyWith(color: esquema.onSurfaceVariant),
    );
    final valor = Text(
      fila.valor,
      style: textos.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        fontFeatures: cifrasTabulares,
      ),
    );
    return MergeSemantics(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: medidas.espacioS / 2),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints restricciones) {
            final apilada = restricciones.maxWidth < 360 ||
                MediaQuery.textScalerOf(context).scale(BsEscala.cuerpo) > 20;
            if (apilada) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  etiqueta,
                  SizedBox(height: medidas.espacioXs),
                  valor,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(child: etiqueta),
                SizedBox(width: medidas.espacioM),
                Expanded(child: valor),
              ],
            );
          },
        ),
      ),
    );
  }
}
