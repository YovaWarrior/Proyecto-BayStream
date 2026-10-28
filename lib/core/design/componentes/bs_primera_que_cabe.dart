import 'dart:math' as math;

import 'package:flutter/foundation.dart' show precisionErrorTolerance;
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Pone la primera de sus [variantes] que cabe a lo ancho (`DESIGN.md`,
/// 14.11): mide cada una a su ancho natural (el ancho intrínseco máximo, sin
/// partir líneas) y elige la primera que entra en el ancho que hay. Si
/// ninguna cabe, pone la última con el ancho que hay: se espera que esa
/// envuelva.
///
/// Es lo que hace la cabecera de la oficina (una línea con los segmentos, una
/// línea con el menú o dos líneas), la franja de la bahía y el selector de
/// modo según el ancho (14.6 y 14.8): una decisión medida, no un umbral de dp
/// que deja de valer con otra letra.
///
/// Solo la elegida se dibuja, recibe toques, se anuncia y se ve en las
/// pruebas, como en un `IndexedStack`; las demás no reciben el foco. Las
/// variantes no deben llevar un `LayoutBuilder` (no da medidas intrínsecas)
/// y las de una línea, tampoco un `Wrap`: su ancho intrínseco no cuenta el
/// `spacing` y la medida se queda corta.
class BsPrimeraQueCabe extends StatefulWidget {
  /// Crea la elección entre [variantes], de la preferida a la de reserva.
  /// Sin variantes no dibuja nada.
  const BsPrimeraQueCabe({super.key, required this.variantes});

  /// Las variantes, de la preferida a la que envuelve.
  final List<Widget> variantes;

  @override
  State<BsPrimeraQueCabe> createState() => _BsPrimeraQueCabeState();
}

class _BsPrimeraQueCabeState extends State<BsPrimeraQueCabe> {
  int _elegida = 0;

  // Lo decide el layout, después del cuadro; el foco se ajusta en el
  // siguiente.
  void _eligio(int indice) {
    if (mounted && indice != _elegida) setState(() => _elegida = indice);
  }

  @override
  Widget build(BuildContext context) => _PrimeraQueCabe(
        onElegida: _eligio,
        children: <Widget>[
          for (var i = 0; i < widget.variantes.length; i++)
            ExcludeFocus(excluding: i != _elegida, child: widget.variantes[i]),
        ],
      );
}

class _PrimeraQueCabe extends MultiChildRenderObjectWidget {
  const _PrimeraQueCabe({required this.onElegida, required super.children});

  final ValueChanged<int> onElegida;

  @override
  _RenderPrimeraQueCabe createRenderObject(BuildContext context) =>
      _RenderPrimeraQueCabe(onElegida);

  @override
  void updateRenderObject(
          BuildContext context, _RenderPrimeraQueCabe renderObject) =>
      renderObject.onElegida = onElegida;

  @override
  MultiChildRenderObjectElement createElement() =>
      _PrimeraQueCabeElement(this);
}

class _PrimeraQueCabeElement extends MultiChildRenderObjectElement {
  _PrimeraQueCabeElement(_PrimeraQueCabe super.widget);

  // Lo que no se ve tampoco está para las pruebas.
  @override
  void debugVisitOnstageChildren(ElementVisitor visitor) {
    final elegida = (renderObject as _RenderPrimeraQueCabe).elegida;
    var indice = 0;
    for (final hijo in children) {
      if (indice++ == elegida) visitor(hijo);
    }
  }
}

class _PrimeraQueCabeParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderPrimeraQueCabe extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, _PrimeraQueCabeParentData> {
  _RenderPrimeraQueCabe(this.onElegida);

  ValueChanged<int> onElegida;

  /// El índice de la variante que se ve.
  int elegida = 0;
  RenderBox? _hijoElegido;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _PrimeraQueCabeParentData) {
      child.parentData = _PrimeraQueCabeParentData();
    }
  }

  @override
  void performLayout() {
    final ancho = constraints.maxWidth;
    final anterior = elegida;
    _hijoElegido = null;
    var indice = 0;
    for (RenderBox? hijo = firstChild; hijo != null; hijo = childAfter(hijo)) {
      // La última no se mide: si nada cupo, va con el ancho que hay.
      final esLaUltima = childAfter(hijo) == null;
      if (esLaUltima || _cabe(hijo, ancho)) {
        _hijoElegido = hijo;
        elegida = indice;
        break;
      }
      indice++;
    }
    for (RenderBox? hijo = firstChild; hijo != null; hijo = childAfter(hijo)) {
      if (identical(hijo, _hijoElegido)) {
        hijo.layout(constraints.loosen().copyWith(minWidth: constraints.minWidth),
            parentUsesSize: true);
      } else {
        // Las demás no se ven: sin tamaño, para que nadie las tome por
        // visibles (los instrumentos de T-99 buscan lo que tiene tamaño).
        hijo.layout(BoxConstraints.tight(Size.zero));
      }
    }
    if (elegida != anterior) markNeedsSemanticsUpdate();
    size = constraints.constrain(_hijoElegido?.size ?? Size.zero);
    if (elegida != anterior || !_avisada) {
      _avisada = true;
      final indiceElegido = elegida;
      SchedulerBinding.instance
          .addPostFrameCallback((_) => onElegida(indiceElegido));
    }
  }

  bool _avisada = false;

  /// Si [hijo] cabe entero en [ancho]. Con la tolerancia de `RenderFlex`
  /// para avisar de un desborde: con medio dp de gracia, a 960 dp con la
  /// letra a 2.0 entraba una variante 0.08 dp más ancha (10.42).
  static bool _cabe(RenderBox hijo, double ancho) =>
      hijo.getMaxIntrinsicWidth(double.infinity) <=
      ancho + precisionErrorTolerance;

  @override
  double computeMinIntrinsicWidth(double height) {
    var minimo = double.infinity;
    for (RenderBox? hijo = firstChild; hijo != null; hijo = childAfter(hijo)) {
      minimo = math.min(minimo, hijo.getMinIntrinsicWidth(height));
    }
    return minimo.isFinite ? minimo : 0;
  }

  @override
  double computeMaxIntrinsicWidth(double height) =>
      firstChild?.getMaxIntrinsicWidth(height) ?? 0;

  @override
  double computeMinIntrinsicHeight(double width) =>
      firstChild?.getMinIntrinsicHeight(width) ?? 0;

  @override
  double computeMaxIntrinsicHeight(double width) =>
      firstChild?.getMaxIntrinsicHeight(width) ?? 0;

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) {
    final ancho = constraints.maxWidth;
    for (RenderBox? hijo = firstChild; hijo != null; hijo = childAfter(hijo)) {
      final esLaUltima = childAfter(hijo) == null;
      if (esLaUltima || _cabe(hijo, ancho)) {
        return constraints.constrain(hijo.getDryLayout(
            constraints.loosen().copyWith(minWidth: constraints.minWidth)));
      }
    }
    return constraints.smallest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final hijo = _hijoElegido;
    if (hijo != null) context.paintChild(hijo, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      _hijoElegido?.hitTest(result, position: position) ?? false;

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    final hijo = _hijoElegido;
    if (hijo != null) visitor(hijo);
  }
}
