import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/design.dart';
import '../../domain/entities/entities.dart';
import '../formatters/operation_text.dart';
import '../providers/oficina_providers.dart';
import 'avisos_del_viaje.dart';
import 'loading_plan_controls.dart' show BayPlanMode;
import 'resumen_del_modo.dart';

/// La franja de la bahía de la oficina (`DESIGN.md` 14.8): fijada arriba de
/// la columna que se desplaza. ‹ y › cambian de bahía y el título abre la
/// lista de bahías, así que con el panel del buque fuera de la vista se
/// sigue navegando; después, las cifras de la bahía, «Colorear por», los
/// controles del plano y el botón que pliega o despliega el panel.
///
/// Se pone en una línea con «Colorear por» en segmentos; si no cabe, con el
/// menú; si tampoco, envuelve en las líneas que pida ([BsPrimeraQueCabe]).
class FranjaDeLaBahia extends StatelessWidget {
  const FranjaDeLaBahia({
    super.key,
    required this.bahia,
    required this.numeros,
    required this.onBahia,
    required this.cifras,
    required this.colorear,
    required this.controles,
  });

  /// El número de la bahía a la vista.
  final int bahia;

  /// Las bahías del plano, de proa a popa.
  final List<int> numeros;

  /// Qué pasa al elegir otra bahía.
  final ValueChanged<int> onBahia;

  /// Las cifras de la bahía, ya escritas.
  final String cifras;

  /// «Colorear por» en la forma que se le pide.
  final Widget Function(BsFormaDelSelector forma) colorear;

  /// Los controles del plano (el zoom, «OR / últimos dígitos», «Acciones»),
  /// uno nuevo por variante.
  final Widget Function() controles;

  @override
  Widget build(BuildContext context) {
    final medidas = BsMedidas.de(context);
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final indice = numeros.indexOf(bahia);
    final anterior = indice > 0 ? numeros[indice - 1] : null;
    final siguiente =
        indice >= 0 && indice < numeros.length - 1 ? numeros[indice + 1] : null;
    String nombre(int numero) => 'Bahía ${numero.toString().padLeft(2, '0')}';

    Widget navegacion() => Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              key: const ValueKey('bahia-anterior'),
              tooltip: 'Bahía anterior',
              onPressed: anterior == null ? null : () => onBahia(anterior),
              icon: const Icon(Icons.chevron_left),
            ),
            MenuAnchor(
              menuChildren: <Widget>[
                for (final numero in numeros)
                  MenuItemButton(
                    onPressed: () => onBahia(numero),
                    trailingIcon: numero == bahia
                        ? Icon(Icons.check, color: esquema.primary, size: 20)
                        : null,
                    child: Text(nombre(numero)),
                  ),
              ],
              builder: (BuildContext context, MenuController menu, Widget? _) =>
                  TextButton(
                key: const ValueKey('bahia-elegir'),
                onPressed: () => menu.isOpen ? menu.close() : menu.open(),
                child: Text(nombre(bahia),
                    style: textos.titleMedium?.copyWith(color: esquema.onSurface)),
              ),
            ),
            IconButton(
              key: const ValueKey('bahia-siguiente'),
              tooltip: 'Bahía siguiente',
              onPressed: siguiente == null ? null : () => onBahia(siguiente),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        );
    Widget lasCifras() => Text(
          cifras,
          key: const ValueKey('cifras-de-la-bahia'),
          style: textos.bodyMedium?.copyWith(
              color: esquema.onSurfaceVariant, fontFeatures: cifrasTabulares),
        );
    Widget colorearPor(BsFormaDelSelector forma) => Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Colorear por',
                style: textos.labelLarge
                    ?.copyWith(color: esquema.onSurfaceVariant)),
            SizedBox(width: medidas.espacioS),
            colorear(forma),
          ],
        );
    Widget enUnaLinea(BsFormaDelSelector forma) => Row(
          children: <Widget>[
            navegacion(),
            SizedBox(width: medidas.espacioS),
            lasCifras(),
            const Spacer(),
            SizedBox(width: medidas.espacioL),
            colorearPor(forma),
            SizedBox(width: medidas.espacioS),
            controles(),
            const _BotonDelPuente(),
          ],
        );
    return Material(
      key: const ValueKey('franja-de-la-bahia'),
      color: Theme.of(context).scaffoldBackgroundColor,
      shape: Border(bottom: BorderSide(color: esquema.outlineVariant)),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: medidas.alturaFila),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: medidas.espacioS, vertical: medidas.espacioXs),
          child: BsPrimeraQueCabe(variantes: <Widget>[
            enUnaLinea(BsFormaDelSelector.segmentos),
            enUnaLinea(BsFormaDelSelector.menu),
            Wrap(
              spacing: medidas.espacioS,
              runSpacing: medidas.espacioXs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                navegacion(),
                lasCifras(),
                colorearPor(BsFormaDelSelector.menu),
                controles(),
                const _BotonDelPuente(),
              ],
            ),
          ]),
        ),
      ),
    );
  }

  /// Las cifras de [bay] como las escribe la franja: los contenedores, las
  /// reservas, el peso y, si no hay tapas declaradas, que faltan (11.6: con
  /// comas, no con punto medio).
  static String cifrasDe(Bay bay,
          {required int reservas, required bool tapasDeclaradas}) =>
      <String>[
        operationCount(bay.containers.length, 'contenedor', 'contenedores'),
        if (reservas > 0)
          operationCount(reservas, 'celda reservada', 'celdas reservadas'),
        formatearToneladas(bay.totalWeight),
        if (!tapasDeclaradas) 'tapas sin declarar',
      ].join(', ');
}

/// La franja de la bahía fijada arriba al desplazar la columna (14.1), si
/// cabe: si mide más que [parteDeLaVista] del alto de la columna (la letra a
/// 2.0 en una ventana baja), se desplaza con el panel del buque, porque
/// fijada taparía la rejilla entera.
class FranjaFijadaSiCabe extends SingleChildRenderObjectWidget {
  const FranjaFijadaSiCabe(
      {super.key, this.parteDeLaVista = 1 / 3, required super.child});

  /// Cuánto del alto de la columna puede ocupar la franja fijada.
  final double parteDeLaVista;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderFranjaFijadaSiCabe(parteDeLaVista);

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) =>
      (renderObject as _RenderFranjaFijadaSiCabe).parteDeLaVista =
          parteDeLaVista;
}

class _RenderFranjaFijadaSiCabe extends RenderSliverSingleBoxAdapter {
  _RenderFranjaFijadaSiCabe(this._parteDeLaVista);

  double _parteDeLaVista;
  set parteDeLaVista(double valor) {
    if (valor == _parteDeLaVista) return;
    _parteDeLaVista = valor;
    markNeedsLayout();
  }

  bool _fijada = true;

  @override
  double childMainAxisPosition(covariant RenderObject child) =>
      _fijada ? 0 : -constraints.scrollOffset;

  @override
  void performLayout() {
    final hijo = child;
    if (hijo == null) {
      geometry = SliverGeometry.zero;
      return;
    }
    final SliverConstraints restricciones = constraints;
    hijo.layout(restricciones.asBoxConstraints(), parentUsesSize: true);
    final alto = hijo.size.height;
    _fijada = alto <= restricciones.viewportMainAxisExtent * _parteDeLaVista;
    if (!_fijada) {
      // Como un `SliverToBoxAdapter`: se va al desplazar.
      final pintado = calculatePaintOffset(restricciones, from: 0, to: alto);
      geometry = SliverGeometry(
        scrollExtent: alto,
        paintExtent: pintado,
        cacheExtent: calculateCacheOffset(restricciones, from: 0, to: alto),
        maxPaintExtent: alto,
        hitTestExtent: pintado,
        hasVisualOverflow: alto > restricciones.remainingPaintExtent ||
            restricciones.scrollOffset > 0,
      );
      setChildParentData(hijo, restricciones, geometry!);
      return;
    }
    // Como un `PinnedHeaderSliver`: se queda arriba.
    (hijo.parentData! as SliverPhysicalParentData).paintOffset = Offset.zero;
    final pintado = math.min(
        alto, restricciones.remainingPaintExtent - restricciones.overlap);
    geometry = SliverGeometry(
      scrollExtent: alto,
      paintOrigin: restricciones.overlap,
      paintExtent: math.max(0, pintado),
      layoutExtent: clampDouble(alto - restricciones.scrollOffset, 0,
          restricciones.remainingPaintExtent),
      maxPaintExtent: alto,
      maxScrollObstructionExtent: alto,
      cacheExtent: calculateCacheOffset(restricciones, from: 0, to: alto),
      hasVisualOverflow: true,
    );
  }
}

/// «Plegar el panel del buque» o «Desplegar el panel del buque» (14.2).
class _BotonDelPuente extends ConsumerWidget {
  const _BotonDelPuente();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final altura = (ref.watch(preferenciasDeLaOficinaProvider).value ??
            const PreferenciasDeLaOficina())
        .altura;
    final plegado = altura == AlturaDelPuente.plegado;
    return IconButton(
      key: const ValueKey('boton-del-puente'),
      tooltip: plegado
          ? 'Desplegar el panel del buque'
          : 'Plegar el panel del buque',
      icon: Icon(plegado ? Icons.expand_more : Icons.expand_less),
      onPressed: () =>
          ref.read(preferenciasDeLaOficinaProvider.notifier).alternarAltura(),
    );
  }
}

/// La franja de cifras de la oficina (`DESIGN.md` 14.5 y 14.7): fija abajo,
/// con el resumen del modo en fichas que envuelven. Es donde viven los
/// avisos: se mide como la franja del muelle, no lleva controles y mide al
/// menos 64 dp, lo que pide el aviso compacto con su aire. Con la letra
/// grande en una ventana baja no pasa de un cuarto del alto de la ventana:
/// las fichas que no caben se desplazan por dentro.
class FranjaDeCifras extends ConsumerWidget {
  const FranjaDeCifras({
    super.key,
    required this.voyage,
    required this.modo,
    required this.bahia,
  });

  final VesselVoyage voyage;
  final BayPlanMode modo;
  final int? bahia;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medidas = BsMedidas.de(context);
    final tema = Theme.of(context);
    final paleta = BsPaleta.de(tema.brightness);
    final fichas = fichasDelResumen(context, ref,
        voyage: voyage, modo: modo, bahia: bahia);
    final minimo = medidas.objetivoTactil + 2 * medidas.espacioS;
    final tope = math.max(minimo, MediaQuery.sizeOf(context).height / 4);
    return MideLaFranja(
      sinControles: true,
      child: Container(
        key: const ValueKey('franja-de-cifras'),
        constraints: BoxConstraints(minHeight: minimo, maxHeight: tope),
        decoration: BoxDecoration(
          color: paleta.hoja,
          border: Border(top: BorderSide(color: tema.colorScheme.outlineVariant)),
        ),
        // Mide lo que piden las fichas, entre el mínimo y el tope.
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          heightFactor: 1,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
                horizontal: medidas.espacioL, vertical: medidas.espacioS),
            child: Wrap(
              spacing: medidas.espacioXl,
              runSpacing: medidas.espacioXs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: fichas,
            ),
          ),
        ),
      ),
    );
  }
}
