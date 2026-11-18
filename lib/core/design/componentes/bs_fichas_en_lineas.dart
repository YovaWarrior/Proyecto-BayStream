import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Fichas que envuelven como un `Wrap`, pero en **hasta `maxLineas` líneas**
/// (`DESIGN.md` 18.3; T-120). Si no caben todas, se quedan las primeras que
/// caben y, al final, `verTodas` (el chip «Ver los 9 destinos»), medido todo
/// con las fuentes y la escala de la letra de ese momento: con la letra
/// grande caben menos y «Ver todas» llega antes, solo.
///
/// - **La ficha `fija` siempre se ve:** si no es de las primeras (un puerto
///   chico elegido desde Estadísticas), toma el último lugar antes de
///   `verTodas`.
/// - Las que quedan fuera no se pintan, no se tocan y no están en la
///   semántica: para el lector de pantalla no existen; están en lo que abre
///   `verTodas`.
/// - Si caben todas, `verTodas` no sale.
/// - Cada línea centra sus fichas en vertical, como
///   `WrapCrossAlignment.center`.
class BsFichasEnLineas extends MultiChildRenderObjectWidget {
  /// Crea las fichas.
  BsFichasEnLineas({
    super.key,
    required List<Widget> fichas,
    required Widget verTodas,
    this.maxLineas = 2,
    this.espacio = 8,
    this.espacioEntreLineas = 8,
    this.fija,
  })  : assert(maxLineas >= 1),
        super(children: <Widget>[...fichas, verTodas]);

  /// Cuántas líneas como mucho.
  final int maxLineas;

  /// El aire entre dos fichas de una línea.
  final double espacio;

  /// El aire entre dos líneas.
  final double espacioEntreLineas;

  /// El índice (en las fichas) de la que siempre se ve: la elegida.
  final int? fija;

  @override
  RenderObject createRenderObject(BuildContext context) => RenderBsFichasEnLineas(
        maxLineas: maxLineas,
        espacio: espacio,
        espacioEntreLineas: espacioEntreLineas,
        fija: fija,
      );

  @override
  void updateRenderObject(
      BuildContext context, RenderBsFichasEnLineas renderObject) {
    renderObject
      ..maxLineas = maxLineas
      ..espacio = espacio
      ..espacioEntreLineas = espacioEntreLineas
      ..fija = fija;
  }
}

/// Los datos de cada ficha: dónde va y si se ve.
class DatosDeLaFicha extends ContainerBoxParentData<RenderBox> {
  /// Si se pinta y está en la semántica.
  bool visible = true;
}

/// El render de [BsFichasEnLineas]. Público para las pruebas, que leen
/// [visibles].
class RenderBsFichasEnLineas extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, DatosDeLaFicha>,
        RenderBoxContainerDefaultsMixin<RenderBox, DatosDeLaFicha> {
  /// Crea el render.
  RenderBsFichasEnLineas({
    required int maxLineas,
    required double espacio,
    required double espacioEntreLineas,
    int? fija,
  })  : _maxLineas = maxLineas,
        _espacio = espacio,
        _espacioEntreLineas = espacioEntreLineas,
        _fija = fija;

  int _maxLineas;
  set maxLineas(int valor) {
    if (valor == _maxLineas) return;
    _maxLineas = valor;
    markNeedsLayout();
  }

  double _espacio;
  set espacio(double valor) {
    if (valor == _espacio) return;
    _espacio = valor;
    markNeedsLayout();
  }

  double _espacioEntreLineas;
  set espacioEntreLineas(double valor) {
    if (valor == _espacioEntreLineas) return;
    _espacioEntreLineas = valor;
    markNeedsLayout();
  }

  int? _fija;
  set fija(int? valor) {
    if (valor == _fija) return;
    _fija = valor;
    markNeedsLayout();
  }

  /// Los índices de las fichas que se ven, sin `verTodas`;
  /// y si `verTodas` se ve.
  List<int> get visibles => List<int>.unmodifiable(_visibles);
  List<int> _visibles = const <int>[];
  bool get conVerTodas => _conVerTodas;
  bool _conVerTodas = false;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! DatosDeLaFicha) {
      child.parentData = DatosDeLaFicha();
    }
  }

  List<RenderBox> get _hijos {
    final hijos = <RenderBox>[];
    var hijo = firstChild;
    while (hijo != null) {
      hijos.add(hijo);
      hijo = childAfter(hijo);
    }
    return hijos;
  }

  /// Dispone [tamanos] (los de las fichas elegidas, en orden) en líneas de
  /// [ancho]: devuelve la posición de cada una y el alto total, o `null` si
  /// pasan de [_maxLineas].
  _Disposicion? _disponer(List<Size> tamanos, double ancho,
      {int? maxLineas}) {
    final lineas = <List<int>>[<int>[]];
    final altos = <double>[0];
    var x = 0.0;
    for (var i = 0; i < tamanos.length; i++) {
      final t = tamanos[i];
      if (lineas.last.isNotEmpty && x + _espacio + t.width > ancho) {
        lineas.add(<int>[]);
        altos.add(0);
        x = 0;
      }
      x += (lineas.last.isEmpty ? 0 : _espacio) + t.width;
      lineas.last.add(i);
      altos.last = math.max(altos.last, t.height);
    }
    if (maxLineas != null && lineas.length > maxLineas) return null;
    final posiciones = List<Offset>.filled(tamanos.length, Offset.zero);
    var y = 0.0;
    var anchoUsado = 0.0;
    for (var l = 0; l < lineas.length; l++) {
      var xi = 0.0;
      for (final i in lineas[l]) {
        posiciones[i] = Offset(xi, y + (altos[l] - tamanos[i].height) / 2);
        xi += tamanos[i].width + _espacio;
      }
      anchoUsado = math.max(anchoUsado, xi - _espacio);
      y += altos[l] + (l < lineas.length - 1 ? _espacioEntreLineas : 0);
    }
    return _Disposicion(posiciones, Size(math.max(0, anchoUsado), y));
  }

  /// Elige qué fichas se ven con los [tamanos] de todos los hijos (el último
  /// es «Ver todas») en [ancho].
  _Eleccion _elegir(List<Size> tamanos, double ancho) {
    final n = tamanos.length - 1;
    final todas = List<int>.generate(n, (int i) => i);
    if (!ancho.isFinite) {
      return _Eleccion(todas, false,
          _disponer(<Size>[for (final i in todas) tamanos[i]], double.infinity)!);
    }
    final conTodas = _disponer(
        <Size>[for (final i in todas) tamanos[i]], ancho,
        maxLineas: _maxLineas);
    if (conTodas != null) return _Eleccion(todas, false, conTodas);
    final fija = _fija;
    for (var k = n - 1; k >= 0; k--) {
      var elegidas = List<int>.generate(k, (int i) => i);
      if (fija != null && fija >= k && fija < n) {
        elegidas = k == 0
            ? <int>[]
            : <int>[...List<int>.generate(k - 1, (int i) => i), fija];
      }
      final disposicion = _disponer(
          <Size>[for (final i in elegidas) tamanos[i], tamanos[n]], ancho,
          maxLineas: _maxLineas);
      if (disposicion != null) return _Eleccion(elegidas, true, disposicion);
    }
    // Ni «Ver todas» cabe en las líneas: va solo, en las que pida.
    return _Eleccion(const <int>[], true, _disponer(<Size>[tamanos[n]], ancho)!);
  }

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) {
    final hijos = _hijos;
    if (hijos.isEmpty) return constraints.smallest;
    final suelto = BoxConstraints(maxWidth: constraints.maxWidth);
    final tamanos = <Size>[for (final h in hijos) h.getDryLayout(suelto)];
    final eleccion = _elegir(tamanos, constraints.maxWidth);
    return constraints.constrain(Size(
        constraints.hasBoundedWidth
            ? constraints.maxWidth
            : eleccion.disposicion.tamano.width,
        eleccion.disposicion.tamano.height));
  }

  @override
  void performLayout() {
    final hijos = _hijos;
    if (hijos.isEmpty) {
      size = constraints.smallest;
      _visibles = const <int>[];
      _conVerTodas = false;
      return;
    }
    final suelto = BoxConstraints(maxWidth: constraints.maxWidth);
    for (final h in hijos) {
      h.layout(suelto, parentUsesSize: true);
    }
    final tamanos = <Size>[for (final h in hijos) h.size];
    final eleccion = _elegir(tamanos, constraints.maxWidth);
    final n = hijos.length - 1;
    final enOrden = <int>[...eleccion.fichas, if (eleccion.verTodas) n];
    for (final h in hijos) {
      (h.parentData! as DatosDeLaFicha).visible = false;
    }
    for (var j = 0; j < enOrden.length; j++) {
      final datos = hijos[enOrden[j]].parentData! as DatosDeLaFicha;
      datos
        ..visible = true
        ..offset = eleccion.disposicion.posiciones[j];
    }
    _visibles = eleccion.fichas;
    _conVerTodas = eleccion.verTodas;
    size = constraints.constrain(Size(
        constraints.hasBoundedWidth
            ? constraints.maxWidth
            : eleccion.disposicion.tamano.width,
        eleccion.disposicion.tamano.height));
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    var minimo = 0.0;
    for (final h in _hijos) {
      minimo = math.max(minimo, h.getMinIntrinsicWidth(height));
    }
    return minimo;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    final hijos = _hijos;
    if (hijos.isEmpty) return 0;
    var suma = 0.0;
    for (final h in hijos.take(hijos.length - 1)) {
      suma += h.getMaxIntrinsicWidth(height) + _espacio;
    }
    return math.max(0, suma - _espacio);
  }

  @override
  double computeMinIntrinsicHeight(double width) =>
      computeDryLayout(BoxConstraints(maxWidth: width)).height;

  @override
  double computeMaxIntrinsicHeight(double width) =>
      computeMinIntrinsicHeight(width);

  @override
  void paint(PaintingContext context, Offset offset) {
    var hijo = firstChild;
    while (hijo != null) {
      final datos = hijo.parentData! as DatosDeLaFicha;
      if (datos.visible) context.paintChild(hijo, datos.offset + offset);
      hijo = datos.nextSibling;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    var hijo = lastChild;
    while (hijo != null) {
      final datos = hijo.parentData! as DatosDeLaFicha;
      if (datos.visible) {
        final tocado = result.addWithPaintOffset(
          offset: datos.offset,
          position: position,
          hitTest: (BoxHitTestResult result, Offset transformado) =>
              hijo!.hitTest(result, position: transformado),
        );
        if (tocado) return true;
      }
      hijo = datos.previousSibling;
    }
    return false;
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    var hijo = firstChild;
    while (hijo != null) {
      final datos = hijo.parentData! as DatosDeLaFicha;
      if (datos.visible) visitor(hijo);
      hijo = datos.nextSibling;
    }
  }
}

class _Disposicion {
  const _Disposicion(this.posiciones, this.tamano);
  final List<Offset> posiciones;
  final Size tamano;
}

class _Eleccion {
  const _Eleccion(this.fichas, this.verTodas, this.disposicion);
  final List<int> fichas;
  final bool verTodas;
  final _Disposicion disposicion;
}
