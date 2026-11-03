import 'package:flutter/material.dart';
import '../bs_iconos.dart';

import '../bs_colores_semanticos.dart';
import '../bs_medidas.dart';
import '../bs_paleta.dart';
import 'bs_marca.dart';
import 'bs_panel_en_vivo.dart';
import 'bs_primera_que_cabe.dart';

/// El modo de operación que la banda ofrece.
enum BsModoDeOperacion {
  /// Descarga.
  descarga('Descarga', BsIconos.descarga),

  /// Carga.
  carga('Carga', BsIconos.carga);

  const BsModoDeOperacion(this.rotulo, this.icono);

  /// Cómo se escribe.
  final String rotulo;

  /// Su icono.
  final IconData icono;
}

/// La banda de la marca arriba del muelle (`DESIGN.md`, 13.6 y 13.8): la marca
/// sin recuadro sobre el azul, el nombre del buque y el viaje, el chip de la
/// nube y, debajo, el `SegmentedButton` Descarga / Carga de 48 dp, con el
/// distintivo de rol a su izquierda (13.12).
///
/// El fondo es la marca como superficie en los dos temas; el texto va en
/// blanco (8.6:1) y la frase en el azul claro de la banda (5.6:1).
class BsBandaMuelle extends StatelessWidget {
  /// Crea la banda.
  const BsBandaMuelle({
    super.key,
    required this.buque,
    this.viaje,
    this.nube,
    this.modo,
    this.onModo,
    this.mostrarModos = false,
    this.modos = const <BsModoDeOperacion>{
      BsModoDeOperacion.descarga,
      BsModoDeOperacion.carga,
    },
    this.acciones = const <Widget>[],
    this.distintivo,
  });

  /// El nombre del buque.
  final String buque;

  /// El viaje y la escala («Viaje M100 · GTSTC»).
  final String? viaje;

  /// El chip de la nube; por omisión no hay. Ver [BsChipDeNube].
  final Widget? nube;

  /// El modo seleccionado; sin él no hay segmentos.
  final BsModoDeOperacion? modo;

  /// Qué pasa al cambiar de modo.
  final ValueChanged<BsModoDeOperacion>? onModo;

  /// Dibuja los segmentos aunque [modo] sea nulo (el plano está en otra
  /// vista, como «Contenido»): ninguno queda seleccionado hasta tocar uno.
  final bool mostrarModos;

  /// Qué modos ofrece esta escala: un plan de carga sin nada que baje no
  /// tiene Descarga. Con uno solo, el segmento va solo.
  final Set<BsModoDeOperacion> modos;

  /// Acciones a la derecha del chip de la nube (iconos de 48 dp).
  final List<Widget> acciones;

  /// El distintivo de rol (`BsDistintivoDeRol`, 13.12) en la forma que se le
  /// pide: va en la segunda fila, a la izquierda de Descarga / Carga y
  /// centrado con los segmentos. Completo solo si los segmentos conservan su
  /// rótulo y su ícono enteros; si no, compacto; si ni así, no va. Sin él, la
  /// banda queda como antes.
  final Widget Function(bool compacto)? distintivo;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final paleta = BsPaleta.de(tema.brightness);
    final medidas = BsMedidas.de(context);
    final textos = tema.textTheme;
    final segmentos = (modo != null || mostrarModos) && modos.isNotEmpty
        ? SegmentedButton<BsModoDeOperacion>(
            emptySelectionAllowed: true,
            segments: <ButtonSegment<BsModoDeOperacion>>[
              for (final valor in BsModoDeOperacion.values)
                if (modos.contains(valor))
                  ButtonSegment<BsModoDeOperacion>(
                    value: valor,
                    label: Text(valor.rotulo),
                    icon: Icon(valor.icono),
                  ),
            ],
            selected: <BsModoDeOperacion>{
              if (modo != null && modos.contains(modo)) modo!,
            },
            onSelectionChanged: onModo == null
                ? null
                : (Set<BsModoDeOperacion> valores) {
                    if (valores.isNotEmpty) onModo!(valores.first);
                  },
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(
              minimumSize: Size(medidas.objetivoTactil, medidas.alturaBoton),
              backgroundColor: paleta.marcaProfunda,
              foregroundColor: paleta.sobreMarcaSuave,
              selectedBackgroundColor: paleta.sobreMarcaSuperficie,
              selectedForegroundColor: paleta.marcaSuperficie,
              side: BorderSide(color: paleta.marcaProfunda),
              textStyle: textos.labelLarge,
            ),
          )
        : null;
    // La segunda fila (13.12): el distintivo a la izquierda de los segmentos,
    // medido como el resto de la cabecera. Completo solo si los segmentos
    // caben con su rótulo y su ícono enteros; si no, compacto; y si ni así,
    // los segmentos solos, como antes: Descarga y Carga mandan (Carlos,
    // 3-nov; a 360 dp con la letra a 2.0, el compacto partía «Descarga»).
    final distintivo = this.distintivo;
    final Widget? segundaFila = distintivo == null
        ? segmentos
        : segmentos == null
            ? Align(
                alignment: AlignmentDirectional.centerStart,
                child: distintivo(false),
              )
            : BsPrimeraQueCabe(variantes: <Widget>[
                for (final compacto in const <bool>[false, true])
                  Row(
                    children: <Widget>[
                      distintivo(compacto),
                      SizedBox(width: medidas.espacioM),
                      Expanded(child: segmentos),
                    ],
                  ),
                segmentos,
              ]);
    return Material(
      color: paleta.marcaSuperficie,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            medidas.espacioL,
            medidas.espacioM,
            medidas.espacioL,
            medidas.espacioL,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const BsMarca(
                    tamano: 44,
                    variante: BsVarianteDeMarca.sinRecuadro,
                  ),
                  SizedBox(width: medidas.espacioM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          buque,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textos.titleMedium
                              ?.copyWith(color: paleta.sobreMarcaSuperficie),
                        ),
                        if (viaje != null)
                          Text(
                            viaje!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textos.bodySmall
                                ?.copyWith(color: paleta.sobreMarcaSuave),
                          ),
                      ],
                    ),
                  ),
                  if (nube != null) ...<Widget>[
                    SizedBox(width: medidas.espacioS),
                    nube!,
                  ],
                  for (final accion in acciones) ...<Widget>[
                    SizedBox(width: medidas.espacioXs),
                    IconTheme(
                      data: IconThemeData(color: paleta.sobreMarcaSuperficie),
                      child: accion,
                    ),
                  ],
                ],
              ),
              if (segundaFila != null) ...<Widget>[
                SizedBox(height: medidas.espacioM),
                segundaFila,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// El chip de la nube dentro de la banda: un punto en hecho con pulso cuando
/// está al día y el texto en blanco sobre la marca profunda (10.7:1).
class BsChipDeNube extends StatelessWidget {
  /// Crea el chip.
  const BsChipDeNube({super.key, required this.texto, this.alDia = true, this.onTap});

  /// Qué dice («Al día», «Sin conexión»).
  final String texto;

  /// Si está al día: el punto en hecho y pulsando; si no, quieto y en el azul
  /// claro de la banda.
  final bool alDia;

  /// Qué pasa al tocarlo (abrir «Nube y cuenta»).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final paleta = BsPaleta.de(tema.brightness);
    final medidas = BsMedidas.de(context);
    final semanticos = BsColoresSemanticos.de(context);
    final punto = alDia ? semanticos.hecho.contorno : paleta.sobreMarcaSuave;
    return Semantics(
      label: 'Nube: $texto',
      button: onTap != null,
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: paleta.marcaProfunda,
        shape: const StadiumBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Container(
            constraints: BoxConstraints(
              minHeight: medidas.objetivoTactil,
              minWidth: medidas.objetivoTactil,
            ),
            padding: EdgeInsets.symmetric(horizontal: medidas.espacioM),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                BsPulso(color: punto, activo: alDia),
                SizedBox(width: medidas.espacioS),
                Text(
                  texto,
                  style: tema.textTheme.labelLarge
                      ?.copyWith(color: paleta.sobreMarcaSuperficie),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
