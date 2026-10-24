import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/design.dart';
import '../providers/oficina_providers.dart';

/// El panel del buque de la oficina (`DESIGN.md` 14.2): la silueta y las
/// tarjetas cortas en tres alturas (completo, compacto y plegado), con el
/// borde que se arrastra debajo. Va al principio de la columna que se
/// desplaza: al bajar, se va de la vista sin cambiar de altura.
///
/// Cada altura mide lo que mide su contenido; nunca se recorta ni se estira.
/// Mientras se arrastra el borde, el panel muestra la altura más grande que
/// cabe en el alto arrastrado, arriba y entera, y al soltar se queda en la
/// más cercana. El cambio no se anima (4.5).
class PuenteDelPlano extends ConsumerStatefulWidget {
  const PuenteDelPlano({
    super.key,
    required this.completo,
    required this.compacto,
  });

  /// La silueta normal con las tarjetas cortas.
  final Widget completo;

  /// La silueta compacta con las tarjetas que caben en una fila.
  final Widget compacto;

  @override
  ConsumerState<PuenteDelPlano> createState() => _PuenteDelPlanoState();
}

class _PuenteDelPlanoState extends ConsumerState<PuenteDelPlano> {
  /// El alto mientras se arrastra el borde; sin valor, en reposo.
  double? _arrastre;

  /// Lo que midió cada altura la última vez que estuvo armada.
  final Map<AlturaDelPuente, double> _altos = <AlturaDelPuente, double>{
    AlturaDelPuente.plegado: 0,
  };

  final FocusNode _foco = FocusNode(debugLabel: 'borde-del-puente');

  @override
  void dispose() {
    _foco.dispose();
    super.dispose();
  }

  PreferenciasDeLaOficinaNotifier get _preferencias =>
      ref.read(preferenciasDeLaOficinaProvider.notifier);

  void _elegir(AlturaDelPuente altura) =>
      _preferencias.elegirAltura(altura);

  void _empezar(AlturaDelPuente altura) =>
      setState(() => _arrastre = _altos[altura] ?? 0);

  void _arrastrar(double dy) {
    final arrastre = _arrastre;
    if (arrastre == null) return;
    final tope = _altos[AlturaDelPuente.completo] ?? double.infinity;
    setState(() => _arrastre = (arrastre + dy).clamp(0, tope).toDouble());
  }

  void _soltar() {
    final arrastre = _arrastre;
    if (arrastre == null) return;
    // La altura más cercana al alto arrastrado, entre las que se midieron.
    var cercana = AlturaDelPuente.plegado;
    var distancia = double.infinity;
    for (final altura in AlturaDelPuente.values) {
      final alto = _altos[altura];
      if (alto == null) continue;
      final esta = (alto - arrastre).abs();
      if (esta < distancia) {
        distancia = esta;
        cercana = altura;
      }
    }
    setState(() => _arrastre = null);
    _elegir(cercana);
  }

  @override
  Widget build(BuildContext context) {
    final altura = (ref.watch(preferenciasDeLaOficinaProvider).value ??
            const PreferenciasDeLaOficina())
        .altura;
    final arrastrando = _arrastre != null;
    // En reposo solo se arma la altura elegida; al arrastrar, las dos, para
    // saber cuál cabe. Las claves conservan el estado de cada una (el
    // desplazamiento de la silueta).
    final hijos = <AlturaDelPuente>[
      if (arrastrando || altura == AlturaDelPuente.completo)
        AlturaDelPuente.completo,
      if (arrastrando || altura == AlturaDelPuente.compacto)
        AlturaDelPuente.compacto,
    ];
    return Column(
      key: const ValueKey('puente-del-plano'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _AlturasDelPuente(
          hijos: hijos,
          altura: altura,
          arrastre: _arrastre,
          onMedida: (AlturaDelPuente a, double alto) => _altos[a] = alto,
          children: <Widget>[
            for (final a in hijos)
              KeyedSubtree(
                key: ValueKey<AlturaDelPuente>(a),
                child: ExcludeFocus(
                  excluding: arrastrando,
                  child: a == AlturaDelPuente.completo
                      ? widget.completo
                      : widget.compacto,
                ),
              ),
          ],
        ),
        _BordeDelPuente(
          altura: altura,
          foco: _foco,
          onEmpezar: () => _empezar(altura),
          onArrastrar: _arrastrar,
          onSoltar: _soltar,
          onMas: () => _elegir(altura.mas),
          onMenos: () => _elegir(altura.menos),
          onAlternar: () => _preferencias.alternarAltura(),
        ),
      ],
    );
  }
}

/// El borde del panel del buque (14.2): 12 dp con una línea y la agarradera,
/// el cursor de redimensionar fila, el arrastre, el doble clic, el teclado y
/// la semántica de un control ajustable.
class _BordeDelPuente extends StatelessWidget {
  const _BordeDelPuente({
    required this.altura,
    required this.foco,
    required this.onEmpezar,
    required this.onArrastrar,
    required this.onSoltar,
    required this.onMas,
    required this.onMenos,
    required this.onAlternar,
  });

  final AlturaDelPuente altura;
  final FocusNode foco;
  final VoidCallback onEmpezar;
  final ValueChanged<double> onArrastrar;
  final VoidCallback onSoltar;
  final VoidCallback onMas;
  final VoidCallback onMenos;
  final VoidCallback onAlternar;

  /// El alto del borde.
  static const double alto = 12;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final paleta = BsPaleta.de(Theme.of(context).brightness);
    final medidas = BsMedidas.de(context);
    return Semantics(
      key: const ValueKey('borde-del-puente'),
      slider: true,
      label: 'Alto del panel del buque',
      value: altura.rotulo,
      increasedValue: altura.mas.rotulo,
      decreasedValue: altura.menos.rotulo,
      onIncrease: onMas,
      onDecrease: onMenos,
      child: Focus(
        focusNode: foco,
        onKeyEvent: (FocusNode _, KeyEvent evento) {
          if (evento is! KeyDownEvent && evento is! KeyRepeatEvent) {
            return KeyEventResult.ignored;
          }
          final tecla = evento.logicalKey;
          if (tecla == LogicalKeyboardKey.arrowUp) {
            onMenos();
          } else if (tecla == LogicalKeyboardKey.arrowDown) {
            onMas();
          } else if (tecla == LogicalKeyboardKey.enter ||
              tecla == LogicalKeyboardKey.numpadEnter ||
              tecla == LogicalKeyboardKey.space) {
            if (evento is KeyDownEvent) onAlternar();
          } else {
            return KeyEventResult.ignored;
          }
          return KeyEventResult.handled;
        },
        child: Tooltip(
          message: 'Arrastra para cambiar el alto del panel del buque; '
              'doble clic para plegarlo o desplegarlo',
          excludeFromSemantics: true,
          waitDuration: const Duration(milliseconds: 800),
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeRow,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              excludeFromSemantics: true,
              onVerticalDragStart: (_) => onEmpezar(),
              onVerticalDragUpdate: (DragUpdateDetails d) =>
                  onArrastrar(d.delta.dy),
              onVerticalDragEnd: (_) => onSoltar(),
              onVerticalDragCancel: onSoltar,
              onDoubleTap: onAlternar,
              child: ListenableBuilder(
                listenable: foco,
                builder: (BuildContext context, Widget? _) => SizedBox(
                  height: alto,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Positioned(
                        left: medidas.espacioM,
                        right: medidas.espacioM,
                        bottom: 0,
                        child: Container(height: 1, color: esquema.outlineVariant),
                      ),
                      Container(
                        width: 32,
                        height: 4,
                        decoration: BoxDecoration(
                          color: foco.hasFocus ? esquema.primary : paleta.lineaFuerte,
                          borderRadius: BorderRadius.circular(2),
                          border: foco.hasFocus
                              ? Border.all(color: esquema.primary, width: 2,
                                  strokeAlign: BorderSide.strokeAlignOutside)
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Arma las alturas del panel y pone la que toca: en reposo, la elegida (o
/// nada, plegado); al arrastrar, la más grande que cabe en el alto
/// arrastrado. Solo la que se ve se dibuja, se toca y se anuncia.
class _AlturasDelPuente extends MultiChildRenderObjectWidget {
  const _AlturasDelPuente({
    required this.hijos,
    required this.altura,
    required this.arrastre,
    required this.onMedida,
    required super.children,
  });

  /// La altura de cada hijo, en su orden.
  final List<AlturaDelPuente> hijos;
  final AlturaDelPuente altura;
  final double? arrastre;
  final void Function(AlturaDelPuente altura, double alto) onMedida;

  @override
  _RenderAlturasDelPuente createRenderObject(BuildContext context) =>
      _RenderAlturasDelPuente(hijos, altura, arrastre, onMedida);

  @override
  void updateRenderObject(
      BuildContext context, _RenderAlturasDelPuente renderObject) {
    renderObject
      ..hijos = hijos
      ..altura = altura
      ..arrastre = arrastre
      ..onMedida = onMedida;
  }

  @override
  MultiChildRenderObjectElement createElement() =>
      _AlturasDelPuenteElement(this);
}

class _AlturasDelPuenteElement extends MultiChildRenderObjectElement {
  _AlturasDelPuenteElement(_AlturasDelPuente super.widget);

  @override
  void debugVisitOnstageChildren(ElementVisitor visitor) {
    final elegido = (renderObject as _RenderAlturasDelPuente).elegido;
    var indice = 0;
    for (final hijo in children) {
      if (indice++ == elegido) visitor(hijo);
    }
  }
}

class _AlturasDelPuenteParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderAlturasDelPuente extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, _AlturasDelPuenteParentData> {
  _RenderAlturasDelPuente(this._hijos, this._altura, this._arrastre, this.onMedida);

  List<AlturaDelPuente> _hijos;
  set hijos(List<AlturaDelPuente> valor) {
    _hijos = valor;
    markNeedsLayout();
  }

  AlturaDelPuente _altura;
  set altura(AlturaDelPuente valor) {
    if (valor == _altura) return;
    _altura = valor;
    markNeedsLayout();
  }

  double? _arrastre;
  set arrastre(double? valor) {
    if (valor == _arrastre) return;
    _arrastre = valor;
    markNeedsLayout();
  }

  void Function(AlturaDelPuente altura, double alto) onMedida;

  /// El índice del hijo que se ve; -1, ninguno.
  int elegido = -1;
  RenderBox? _hijoElegido;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _AlturasDelPuenteParentData) {
      child.parentData = _AlturasDelPuenteParentData();
    }
  }

  @override
  void performLayout() {
    final ancho = constraints.maxWidth;
    final alAncho = BoxConstraints(minWidth: ancho, maxWidth: ancho);
    final anterior = elegido;
    _hijoElegido = null;
    elegido = -1;
    var indice = 0;
    var mayor = 0.0;
    for (RenderBox? hijo = firstChild; hijo != null; hijo = childAfter(hijo)) {
      hijo.layout(alAncho, parentUsesSize: true);
      final suAltura = _hijos[indice];
      final alto = hijo.size.height;
      onMedida(suAltura, alto);
      mayor = math.max(mayor, alto);
      final enArrastre = _arrastre;
      final cabe = enArrastre == null
          ? suAltura == _altura
          // Los hijos van del más alto al más bajo: el primero que cabe.
          : alto <= enArrastre + 0.5;
      if (_hijoElegido == null && cabe) {
        _hijoElegido = hijo;
        elegido = indice;
      }
      indice++;
    }
    if (elegido != anterior) markNeedsSemanticsUpdate();
    final arrastre = _arrastre;
    final alto = arrastre != null
        ? math.min(arrastre, mayor)
        : _hijoElegido?.size.height ?? 0;
    size = constraints.constrain(Size(ancho, alto));
  }

  @override
  double computeMinIntrinsicHeight(double width) => _altoIntrinseco(width);

  @override
  double computeMaxIntrinsicHeight(double width) => _altoIntrinseco(width);

  double _altoIntrinseco(double width) {
    var indice = 0;
    for (RenderBox? hijo = firstChild; hijo != null; hijo = childAfter(hijo)) {
      if (_hijos[indice] == _altura) return hijo.getMaxIntrinsicHeight(width);
      indice++;
    }
    return 0;
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
