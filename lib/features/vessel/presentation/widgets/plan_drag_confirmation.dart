import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/design.dart';
import '../../domain/entities/entities.dart';
import '../../domain/services/change_requests.dart';
import '../formatters/vessel_error_message.dart';
import '../../domain/services/loading_operation.dart';
import '../providers/loading_operation_provider.dart';
import '../providers/movement_log_provider.dart';
import '../providers/plano_providers.dart';
import '../providers/sync_providers.dart';
import 'avisos_del_viaje.dart';
import 'loading_controls.dart' show loadingPosition;

/// T-106: la escala del zoom, para lo que no debe ampliarse (el margen) o se
/// dibuja fuera del viewport (la copia que se arrastra, en el Overlay).
class PlanZoomScope extends InheritedWidget {
  final double scale;
  const PlanZoomScope({super.key, required this.scale, required super.child});

  static double of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PlanZoomScope>()?.scale ?? 1;

  @override
  bool updateShouldNotify(PlanZoomScope oldWidget) => oldWidget.scale != scale;
}

/// Amplía la rejilla y su área desplazable; conserva los gestos de cada celda.
/// La escala vive en `planZoomProvider`: la pellizca aquí y la cambia el chip
/// `ZoomDelPlano`, que desde 10.20 va fuera de la rejilla, en la línea de los
/// controles, para no tapar ninguna celda. Durante un arrastre, los
/// desplazamientos de la rejilla los mueve `_PlanDragSource` (T-122, H7).
///
/// T-119 (`DESIGN.md` 16.2 y 16.3): además de los dos dedos sobre la
/// pantalla, amplían el pellizco del touchpad (`PointerPanZoom…`, en Windows
/// con touchpad de precisión), Ctrl + rueda, también con el mouse (P4), y el
/// pellizco que el motor web entrega como `PointerScaleEvent`. En la oficina,
/// el punto bajo el puntero se queda quieto.
class PlanZoomViewport extends ConsumerStatefulWidget {
  final Widget child;

  /// La oficina (`DESIGN.md` 14.1): la rejilla no tiene alto propio ni
  /// desplazamiento vertical; se amplía a su alto natural y le dice a la
  /// columna que la desplaza cuánto mide ampliada. Su desplazamiento
  /// horizontal va por fuera de la escala, con [horizontal] (16.4). Sin esto
  /// (el teléfono), el lienzo ocupa el alto que le dan y los dos
  /// desplazamientos de la rejilla van por dentro.
  final bool alturaNatural;

  /// En la oficina, el controlador del desplazamiento horizontal de la
  /// rejilla: el de la barra de abajo de la columna (`BarraDeLaRejilla`).
  final ScrollController? horizontal;
  const PlanZoomViewport(
      {super.key,
      required this.child,
      this.alturaNatural = false,
      this.horizontal});

  /// El aire alrededor de la rejilla, en dp de pantalla: la rejilla lo pone
  /// entre la escala, para que no se amplíe.
  static const double margen = 16;

  /// Cuánto se aparta el pellizco del touchpad de 1.0 antes de ampliar: por
  /// debajo, los dos dedos solo desplazan.
  static const double umbralDelPellizco = 0.01;

  /// Ctrl + rueda: la escala se multiplica por e^(−dy / [pasoDeLaRueda]), la
  /// misma cuenta con que el motor web convierte el pellizco.
  static const double pasoDeLaRueda = 200;

  @override
  ConsumerState<PlanZoomViewport> createState() => _PlanZoomViewportState();
}

class _PlanZoomViewportState extends ConsumerState<PlanZoomViewport> {
  double gestureScale = 1;
  double span = 1;
  final pointers = <int, Offset>{};

  /// La escala al empezar el gesto del touchpad, mientras dura.
  double? _escalaDelTouchpad;

  /// Si el gesto del touchpad ya es un pellizco: la rejilla y la columna no
  /// se desplazan hasta que termina.
  bool _pellizcando = false;

  /// Quien apaga el pellizco en la columna; guardado al empezar, porque en
  /// `dispose` no se puede usar `ref`.
  PellizcoDelPlanoNotifier? _pellizco;

  /// El ancho natural de la rejilla, que mide [PlanZoomContenido].
  final _AnchoNatural _ancho = _AnchoNatural();

  void beginPinch() {
    if (pointers.length != 2) return;
    span = (pointers.values.first - pointers.values.last).distance;
    gestureScale = ref.read(planZoomProvider);
  }

  void endPointer(int pointer) {
    setState(() => pointers.remove(pointer));
    beginPinch();
  }

  /// Fija la escala en [escala] (acotada por el proveedor) y, en la oficina,
  /// deja quieto el punto que está bajo [foco], en coordenadas de este lienzo.
  void _ampliar(double escala, Offset foco) {
    final antes = ref.read(planZoomProvider);
    ref.read(planZoomProvider.notifier).fijar(escala);
    final despues = ref.read(planZoomProvider);
    if (despues == antes || !widget.alturaNatural) return;
    _dejarQuieto(foco, antes, despues);
  }

  /// La rejilla empieza a [PlanZoomViewport.margen] del borde del lienzo (o
  /// centrada, si no llena la vista) y crece de [antes] a [despues]: el punto
  /// bajo [foco] queda donde estaba si los dos desplazamientos se corren lo
  /// que él se corre (16.3). Se mueven antes del cuadro con la escala nueva,
  /// así que los dos cambios se ven juntos; si la cuenta pasa del borde nuevo,
  /// la física lo acota al medirse.
  void _dejarQuieto(Offset foco, double antes, double despues) {
    const margen = PlanZoomViewport.margen;
    final razon = despues / antes;
    final horizontal = widget.horizontal;
    if (horizontal != null && horizontal.positions.length == 1) {
      final posicion = horizontal.position;
      if (posicion.hasContentDimensions) {
        final ancho = posicion.viewportDimension;
        // El ancho natural de la rejilla, sin el aire; sin medida, el que
        // dice el desplazamiento (exacto si la rejilla no cabe).
        final natural = _ancho.valor ??
            (posicion.maxScrollExtent + ancho - 2 * margen) / antes;
        // Dónde empieza la rejilla con cada escala: centrada si no llena.
        double inicio(double escala) =>
            margen + math.max(0.0, (ancho - 2 * margen - natural * escala) / 2);
        final punto = (posicion.pixels + foco.dx - inicio(antes)) / antes;
        final tope = math.max(0.0, natural * despues + 2 * margen - ancho);
        final destino = (inicio(despues) + punto * despues - foco.dx)
            .clamp(0.0, tope)
            .toDouble();
        if (destino != posicion.pixels) posicion.jumpTo(destino);
      }
    }
    final columna = Scrollable.maybeOf(context, axis: Axis.vertical)?.position;
    final alto = context.size?.height;
    if (columna != null && columna.hasContentDimensions && alto != null) {
      // La columna crece lo que crece la rejilla; lo de arriba no cambia.
      final crece = (alto - 2 * margen) * (razon - 1);
      final destino = (columna.pixels + (foco.dy - margen) * (razon - 1))
          .clamp(columna.minScrollExtent,
              math.max(columna.minScrollExtent, columna.maxScrollExtent + crece))
          .toDouble();
      if (destino != columna.pixels) columna.jumpTo(destino);
    }
  }

  /// Dónde está [evento] en este lienzo, ahora. No es `localPosition`: el
  /// gesto del touchpad guarda la posición del lienzo al empezar, y el lienzo
  /// se mueve con la columna mientras se pellizca.
  Offset _foco(PointerEvent evento) {
    final caja = context.findRenderObject();
    return caja is RenderBox && caja.hasSize
        ? caja.globalToLocal(evento.position)
        : evento.localPosition;
  }

  /// Ctrl + rueda y el pellizco de la Web. Se registran en el resolvedor
  /// aunque la escala ya esté en su tope, para que la columna no se mueva.
  void _senal(PointerSignalEvent evento) {
    final foco = _foco(evento);
    if (evento is PointerScaleEvent) {
      if (evento.scale == 1) return;
      final factor = evento.scale;
      GestureBinding.instance.pointerSignalResolver.register(evento,
          (_) => _ampliar(ref.read(planZoomProvider) * factor, foco));
    } else if (evento is PointerScrollEvent &&
        evento.scrollDelta.dy != 0 &&
        HardwareKeyboard.instance.isControlPressed) {
      final factor =
          math.exp(-evento.scrollDelta.dy / PlanZoomViewport.pasoDeLaRueda);
      GestureBinding.instance.pointerSignalResolver.register(evento,
          (_) => _ampliar(ref.read(planZoomProvider) * factor, foco));
    }
  }

  void _empiezaElTouchpad(PointerPanZoomStartEvent evento) =>
      _escalaDelTouchpad = ref.read(planZoomProvider);

  void _sigueElTouchpad(PointerPanZoomUpdateEvent evento) {
    final base = _escalaDelTouchpad;
    if (base == null) return;
    if (!_pellizcando &&
        (evento.scale - 1).abs() <= PlanZoomViewport.umbralDelPellizco) {
      return;
    }
    if (!_pellizcando) {
      setState(() => _pellizcando = true);
      final pellizco = ref.read(pellizcoDelPlanoProvider.notifier);
      _pellizco = pellizco;
      pellizco.empezar();
    }
    _ampliar(base * evento.scale, _foco(evento));
  }

  void _terminaElTouchpad(PointerPanZoomEndEvent evento) {
    _escalaDelTouchpad = null;
    if (!_pellizcando) return;
    setState(() => _pellizcando = false);
    _pellizco?.terminar();
    _pellizco = null;
  }

  @override
  void dispose() {
    _pellizco?.terminar();
    super.dispose();
  }

  /// Mientras dura un pellizco, ningún desplazamiento de la rejilla se mueve.
  ScrollPhysics? get _fisica => pointers.length >= 2 || _pellizcando
      ? const NeverScrollableScrollPhysics()
      : null;

  /// Los gestos: dos contactos sobre la pantalla, el touchpad y la rueda.
  /// Observar dos contactos evita competir con los scrolls y
  /// LongPressDraggable por el gesto de un solo dedo.
  Widget _gestos({required Widget child}) => Listener(
      key: const ValueKey('plan-zoom-gesture'),
      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) {
        setState(() => pointers[event.pointer] = event.localPosition);
        beginPinch();
      },
      onPointerMove: (event) {
        if (!pointers.containsKey(event.pointer)) return;
        pointers[event.pointer] = event.localPosition;
        if (pointers.length == 2 && span > 0) {
          ref.read(planZoomProvider.notifier).fijar(gestureScale *
              (pointers.values.first - pointers.values.last).distance /
              span);
        }
      },
      onPointerUp: (event) => endPointer(event.pointer),
      onPointerCancel: (event) => endPointer(event.pointer),
      onPointerSignal: _senal,
      onPointerPanZoomStart: _empiezaElTouchpad,
      onPointerPanZoomUpdate: _sigueElTouchpad,
      onPointerPanZoomEnd: _terminaElTouchpad,
      child: child);

  @override
  Widget build(BuildContext context) {
    final scale = ref.watch(planZoomProvider);
    Widget ampliado(Widget hijo) => ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(physics: _fisica),
        child: PlanZoomScope(scale: scale, child: hijo));
    if (widget.alturaNatural) {
      // El desplazamiento horizontal va por fuera de la escala (16.4): su
      // barra no se amplía con la rejilla y vive abajo de la columna.
      return _gestos(
          child: ClipRect(
              child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                      key: const ValueKey('rejilla-horizontal'),
                      controller: widget.horizontal,
                      scrollDirection: Axis.horizontal,
                      physics: _fisica,
                      child: ConstrainedBox(
                          constraints:
                              BoxConstraints(minWidth: constraints.maxWidth),
                          child: _TamanoAmpliado(
                              escala: scale,
                              child: _MedidaDelContenido(
                                  ancho: _ancho,
                                  child: ampliado(widget.child))))))));
    }
    return LayoutBuilder(builder: (context, constraints) {
      return _gestos(
          child: ClipRect(
              // El viewport lógico disminuye al ampliar: los scrolls
              // conservan acceso a TODA la rejilla, también a sus bordes.
              child: SizedBox.expand(
                  child: OverflowBox(
                      alignment: Alignment.topLeft,
                      minWidth: constraints.maxWidth / scale,
                      maxWidth: constraints.maxWidth / scale,
                      minHeight: constraints.maxHeight / scale,
                      maxHeight: constraints.maxHeight / scale,
                      child: Transform.scale(
                          alignment: Alignment.topLeft,
                          scale: scale,
                          child: ampliado(widget.child))))));
    });
  }
}

/// T-119 (16.3) · Mide el ancho natural de la rejilla de la oficina, sin el
/// aire ni el mínimo de la vista: con una bahía que no llena la vista, la
/// rejilla va centrada, y el punto fijo del zoom necesita saber dónde empieza.
/// Va alrededor de la rejilla, con restricciones sueltas, dentro de
/// [PlanZoomViewport]; fuera de él no mide nada.
class PlanZoomContenido extends SingleChildRenderObjectWidget {
  const PlanZoomContenido({super.key, required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderPlanZoomContenido(_MedidaDelContenido.de(context));

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) =>
      (renderObject as _RenderPlanZoomContenido).ancho =
          _MedidaDelContenido.de(context);
}

class _RenderPlanZoomContenido extends RenderProxyBox {
  _RenderPlanZoomContenido(this.ancho);

  _AnchoNatural? ancho;

  @override
  void performLayout() {
    super.performLayout();
    ancho?.valor = size.width;
  }
}

/// Lo que mide [PlanZoomContenido], en unidades de la rejilla sin ampliar.
class _AnchoNatural {
  double? valor;
}

class _MedidaDelContenido extends InheritedWidget {
  const _MedidaDelContenido({required this.ancho, required super.child});

  final _AnchoNatural ancho;

  static _AnchoNatural? de(BuildContext context) => context
      .getInheritedWidgetOfExactType<_MedidaDelContenido>()
      ?.ancho;

  @override
  bool updateShouldNotify(_MedidaDelContenido oldWidget) =>
      !identical(ancho, oldWidget.ancho);
}

/// La rejilla de la oficina ampliada (14.1 y 16.4): el hijo se arma con el
/// ancho que le dan entre la escala (dentro del desplazamiento horizontal:
/// al menos el de la vista lógica, sin tope), con el alto que pida, y se
/// dibuja ampliado; la caja mide lo que el hijo por la escala, en los dos
/// ejes, que es lo que desplazan la columna y la barra de abajo.
class _TamanoAmpliado extends SingleChildRenderObjectWidget {
  const _TamanoAmpliado({required this.escala, required super.child});

  final double escala;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderTamanoAmpliado(escala);

  @override
  void updateRenderObject(
          BuildContext context, _RenderTamanoAmpliado renderObject) =>
      renderObject.escala = escala;
}

class _RenderTamanoAmpliado extends RenderProxyBox {
  _RenderTamanoAmpliado(this._escala);

  double _escala;
  set escala(double valor) {
    if (valor == _escala) return;
    _escala = valor;
    markNeedsLayout();
  }

  Matrix4 get _matriz => Matrix4.diagonal3Values(_escala, _escala, 1);

  @override
  void performLayout() {
    final hijo = child;
    if (hijo == null) {
      size = constraints.smallest;
      return;
    }
    hijo.layout(
        BoxConstraints(
            minWidth: constraints.minWidth / _escala,
            maxWidth: constraints.maxWidth / _escala),
        parentUsesSize: true);
    size = constraints.constrain(hijo.size * _escala);
  }

  @override
  double computeMinIntrinsicHeight(double width) =>
      (child?.getMinIntrinsicHeight(width / _escala) ?? 0) * _escala;

  @override
  double computeMaxIntrinsicHeight(double width) =>
      (child?.getMaxIntrinsicHeight(width / _escala) ?? 0) * _escala;

  final LayerHandle<TransformLayer> _capa = LayerHandle<TransformLayer>();

  @override
  void paint(PaintingContext context, Offset offset) {
    final hijo = child;
    if (hijo == null) {
      _capa.layer = null;
      return;
    }
    _capa.layer = context.pushTransform(needsCompositing, offset, _matriz,
        (PaintingContext context, Offset offset) =>
            context.paintChild(hijo, offset),
        oldLayer: _capa.layer);
  }

  @override
  void dispose() {
    _capa.layer = null;
    super.dispose();
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final hijo = child;
    if (hijo == null) return false;
    return result.addWithPaintTransform(
      transform: _matriz,
      position: position,
      hitTest: (BoxHitTestResult result, Offset position) =>
          hijo.hitTest(result, position: position),
    );
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    transform.multiply(_matriz);
  }
}

class _PlanDrag {
  final String operationId;
  final String target;
  final String from;
  const _PlanDrag(this.operationId, this.target, this.from);
}

/// T-122 (H7, 10.56) · La marca de una celda que recibe arrastres, para
/// saber al soltar cuál queda de verdad bajo el puntero.
class _PlanDropSpot {
  final String position;
  const _PlanDropSpot(this.position);
}

/// La celda del plano bajo [point], en coordenadas de pantalla, o nula.
String? _dropSpotAt(BuildContext context, Offset point) {
  final result = HitTestResult();
  WidgetsBinding.instance.hitTestInView(result, point, View.of(context).viewId);
  for (final entry in result.path) {
    final target = entry.target;
    if (target is RenderMetaData && target.metaData is _PlanDropSpot) {
      return (target.metaData as _PlanDropSpot).position;
    }
  }
  return null;
}

/// T-122 (H7, 10.56) · La celda que se arrastra, con desplazamiento
/// automático. En el piloto, al arrastrar un contenedor de un extremo de la
/// bahía al otro en el teléfono, el plano no se movía cuando el dedo llegaba
/// al borde: `PlanDragCell` era un `LongPressDraggable` dentro de los dos
/// `SingleChildScrollView` de la rejilla, sin nada que los desplazara.
///
/// Ahora, mientras dura el arrastre, los dos desplazamientos que envuelven la
/// celda (el vertical y el horizontal de `_BayGridWidget`, dentro de
/// [PlanZoomViewport]) avanzan solos con [EdgeDraggingAutoScroller] en
/// cuanto el puntero, dedo o mouse, queda a menos de `margen` del borde de la
/// vista. Se mide en coordenadas de pantalla, así que vale también con zoom.
/// Al soltar, cuenta la celda que queda bajo el puntero aunque el plano se
/// haya movido bajo un dedo quieto: la decide [_dropSpotAt] en ese punto, y
/// no el último `DragTarget` que el gesto alcanzó a visitar, que solo cambia
/// cuando el puntero se mueve.
class _PlanDragSource extends StatefulWidget {
  final Key dragKey;
  final _PlanDrag data;
  final Widget feedback;
  final Widget childWhenDragging;
  final Widget child;

  /// Qué hacer al soltar en ese punto de la pantalla.
  final void Function(Offset point) onDrop;

  const _PlanDragSource(
      {required this.dragKey,
      required this.data,
      required this.feedback,
      required this.childWhenDragging,
      required this.child,
      required this.onDrop});

  @override
  State<_PlanDragSource> createState() => _PlanDragSourceState();
}

class _PlanDragSourceState extends State<_PlanDragSource> {
  /// A menos de esto del borde de la vista, el plano se desplaza.
  static const margen = 40.0;

  /// Un desplazador por eje, mientras dura el arrastre.
  final _desplazadores = <(EdgeDraggingAutoScroller, Axis)>[];
  Offset? _ultimo;

  /// La franja que se mide: [margen] a cada lado del puntero en el eje del
  /// desplazamiento y un punto en el otro, para no medir más que la vista.
  static Rect _objetivo(Offset punto, Axis eje) => eje == Axis.horizontal
      ? Rect.fromCenter(center: punto, width: margen * 2, height: 1)
      : Rect.fromCenter(center: punto, width: 1, height: margen * 2);

  void _empezar() {
    _detener();
    for (final eje in Axis.values) {
      final scrollable = Scrollable.maybeOf(context, axis: eje);
      if (scrollable == null) continue;
      late final EdgeDraggingAutoScroller desplazador;
      desplazador = EdgeDraggingAutoScroller(scrollable,
          velocityScalar: 50,
          // Con el puntero quieto el plano sigue moviéndose: el objetivo se
          // vuelve a situar respecto al desplazamiento nuevo.
          onScrollViewScrolled: () {
            final punto = _ultimo;
            if (punto != null) {
              desplazador.startAutoScrollIfNecessary(_objetivo(punto, eje));
            }
          });
      _desplazadores.add((desplazador, eje));
    }
  }

  void _mover(DragUpdateDetails details) {
    _ultimo = details.globalPosition;
    for (final (desplazador, eje) in _desplazadores) {
      desplazador.startAutoScrollIfNecessary(
          _objetivo(details.globalPosition, eje));
    }
  }

  void _detener() {
    for (final (desplazador, _) in _desplazadores) {
      desplazador.stopAutoScroll();
    }
    _desplazadores.clear();
    _ultimo = null;
  }

  void _soltar(DraggableDetails details) {
    _detener();
    // Con `pointerDragAnchorStrategy`, `offset` es el puntero en pantalla.
    widget.onDrop(details.offset);
  }

  @override
  void dispose() {
    _detener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LongPressDraggable<_PlanDrag>(
        key: widget.dragKey,
        data: widget.data,
        maxSimultaneousDrags: 1,
        dragAnchorStrategy: pointerDragAnchorStrategy,
        feedback: widget.feedback,
        childWhenDragging: widget.childWhenDragging,
        onDragStarted: _empezar,
        onDragUpdate: _mover,
        onDragEnd: _soltar,
        child: widget.child,
      );
}

/// T-105: conserva la celda y sus gestos; el dominio decide si puede moverse.
class PlanDragCell extends ConsumerWidget {
  final VesselVoyage voyage;
  final LoadingOperation data;
  final String position;
  final String? itemKey;
  final bool enableDrag;
  final Widget child;

  const PlanDragCell(
      {super.key,
      required this.voyage,
      required this.data,
      required this.position,
      this.itemKey,
      required this.enableDrag,
      required this.child});

  /// Los cambios de soltar [drag] en [destino]: el movimiento y, si la celda
  /// la tiene otro objeto, el intercambio.
  List<PositionChange> _changes(
      LoadingOperation current, _PlanDrag drag, String destino) {
    final other = current.plan.loadingItemAt(destino);
    return [
      PositionChange(drag.target, drag.from, destino),
      if (other != null && other.key != drag.target)
        PositionChange(other.key, other.plannedPosition, drag.from),
    ];
  }

  ChangePreview _preview(WidgetRef ref, _PlanDrag drag, String destino) {
    final operation = ref.read(activeOperationProvider).value;
    final current = ref.read(loadingOperationProvider(voyage)).value;
    if (operation == null ||
        current == null ||
        operation.closed ||
        !operation.published ||
        operation.id != drag.operationId ||
        current.operationId != drag.operationId) {
      return const ChangePreview.invalid(ChangeRequests.operationNotOpen);
    }
    if (drag.from.substring(0, 3) != destino.substring(0, 3)) {
      return const ChangePreview.invalid(
          'El arrastre solo mueve dentro de la bahía: para otra bahía utiliza '
          'el formulario.');
    }
    return const ChangeRequests().preview(current,
        ref.read(operatorProvider).value, _changes(current, drag, destino));
  }

  /// Al soltar [drag] en [destino]: explica el motivo si no se puede, y si se
  /// puede abre la hoja que confirma el cambio, sin guardar todavía.
  void _soltarEn(
      BuildContext context, WidgetRef ref, _PlanDrag drag, String destino) {
    final result = _preview(ref, drag, destino);
    if (!result.valid) {
      ScaffoldMessenger.of(context).showSnackBar(avisoDelViaje(
          texto: result.error!, corto: 'Ese cambio no se puede hacer.'));
      return;
    }
    final current = ref.read(loadingOperationProvider(voyage)).value!;
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        builder: (_) => PlanDragConfirmation(
            voyage: voyage,
            operationId: drag.operationId,
            changes: _changes(current, drag, destino)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actor = ref.watch(operatorProvider).value;
    final operation = ref.watch(activeOperationProvider).value;
    final source = itemKey == null ? null : data.plan.loading[itemKey];
    final pending = source != null &&
        source.plannedPosition == position &&
        const ChangeRequests().pending(data, source.key);
    final open = operation?.published == true &&
        operation?.closed == false &&
        operation?.id == data.operationId;
    // T-106: la copia vive en el Overlay, fuera del zoom; se dibuja a su escala.
    final zoom = PlanZoomScope.of(context);
    // La copia va centrada sobre el dedo y por encima de él: media columna a
    // la izquierda y una fila más 16 dp arriba, con las medidas de la celda
    // (Fase 3: BsCelda, 52 o 56 de ancho más su hueco).
    final medidas = BsMedidas.de(context);
    final columna = medidas.anchoCelda + medidas.huecoCelda;
    final fila = medidas.altoCelda + medidas.huecoCelda;
    Widget cell = child;
    if (enableDrag && pending && actor?.authorized != true) {
      cell = GestureDetector(
          onLongPress: () => ScaffoldMessenger.of(context).showSnackBar(
              avisoDelViaje(
                  texto: ChangeRequests.signInToMove,
                  corto: 'Mover exige una cuenta autorizada.')),
          child: cell);
    } else if (enableDrag && pending && open && actor?.authorized == true) {
      final drag = _PlanDrag(operation!.id, source.key, source.plannedPosition);
      cell = _PlanDragSource(
        dragKey: ValueKey('plan-drag-$itemKey'),
        data: drag,
        onDrop: (point) {
          final destino = _dropSpotAt(context, point);
          if (destino != null) _soltarEn(context, ref, drag, destino);
        },
        feedback: Transform.translate(
            offset: Offset(-columna / 2 * zoom, -(fila + 16) * zoom),
            child: Transform.scale(
                key: const ValueKey('plan-drag-feedback'),
                scale: zoom,
                alignment: Alignment.topLeft,
                child: Material(
                    type: MaterialType.transparency,
                    child: IgnorePointer(
                        child: Opacity(opacity: .85, child: child))))),
        childWhenDragging: Opacity(opacity: .35, child: child),
        child: cell,
      );
    }
    final requested = data.state.requests.any((r) =>
        r.status == ChangeRequestStatus.pending &&
        r.changes.any((c) => c.to == position));
    if (!enableDrag && !requested) return cell;
    // La marca de la celda la lee `_dropSpotAt` al soltar (H7); el objetivo
    // solo dibuja la vista previa del gesto, el verde, el ámbar o el rojo.
    return MetaData(
      metaData: _PlanDropSpot(position),
      behavior: HitTestBehavior.translucent,
      child: DragTarget<_PlanDrag>(
        key: ValueKey('plan-drop-$position'),
        // Acepta también el rojo para explicar el motivo al soltar, sin guardar.
        onWillAcceptWithDetails: (_) => enableDrag,
        builder: (context, candidates, rejected) {
          final preview = candidates.isEmpty
              ? null
              : _preview(ref, candidates.first!, position);
        final scheme = Theme.of(context).colorScheme;
        // Los tonos semánticos conservan luminosidad y saturación del tema.
        final color = preview == null
            ? scheme.primary
            : !preview.valid
                ? scheme.error
                : HSLColor.fromColor(scheme.primary)
                    .withHue(preview.isSwap ? 45 : 140)
                    .toColor();
        return Stack(clipBehavior: Clip.none, children: [
          cell,
          if (requested || preview != null)
            Positioned.fill(
                child: IgnorePointer(
                    child: Semantics(
              label: preview == null
                  ? 'Solicitud pendiente en ${loadingPosition(position)}'
                  : !preview.valid
                      ? preview.error!
                      : preview.isSwap
                          ? 'Intercambio'
                          : 'Movimiento válido',
              child: CustomPaint(
                painter: _CellBorder(color, dashed: preview == null),
                child: Align(
                    alignment: Alignment.topRight,
                    child: Container(
                        color: scheme.surface,
                        child: Icon(
                            preview == null
                                ? BsIconos.pedirCambio
                                : !preview.valid
                                    ? Icons.block
                                    : preview.isSwap
                                        ? Icons.swap_horiz
                                        : Icons.check_circle,
                            size: 16,
                            color: color,
                            key: ValueKey(preview == null
                                ? 'plan-pending-$position'
                                : 'plan-preview-${!preview.valid ? 'invalid' : preview.isSwap ? 'swap' : 'valid'}-$position')))),
              ),
            ))),
        ]);
        },
      ),
    );
  }
}

class _CellBorder extends CustomPainter {
  final Color color;
  final bool dashed;
  const _CellBorder(this.color, {required this.dashed});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final rect = (Offset.zero & size).deflate(1);
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)));
    if (!dashed) {
      canvas.drawPath(path, paint);
      return;
    }
    for (final metric in path.computeMetrics()) {
      for (double d = 0; d < metric.length; d += 7) {
        canvas.drawPath(
            metric.extractPath(d, math.min(d + 4, metric.length)), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_CellBorder old) =>
      old.color != color || old.dashed != dashed;
}

/// Hoja que relee operación, rol y plan antes de anexar por el repositorio.
class PlanDragConfirmation extends ConsumerStatefulWidget {
  final VesselVoyage voyage;
  final String operationId;
  final List<PositionChange> changes;
  const PlanDragConfirmation(
      {super.key,
      required this.voyage,
      required this.operationId,
      required this.changes});
  @override
  ConsumerState<PlanDragConfirmation> createState() =>
      _PlanDragConfirmationState();
}

class _PlanDragConfirmationState extends ConsumerState<PlanDragConfirmation> {
  final reason = TextEditingController();
  bool busy = false;
  String? error;
  @override
  void dispose() {
    reason.dispose();
    super.dispose();
  }

  Future<void> save() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final repository = await ref.read(movementLogRepositoryProvider.future);
      // Releer después de la espera; nunca guardar contra el plan de inicio del gesto.
      final operation = ref.read(activeOperationProvider).value;
      final data = ref.read(loadingOperationProvider(widget.voyage)).value;
      final actor = ref.read(operatorProvider).value;
      if (operation == null ||
          data == null ||
          operation.id != widget.operationId ||
          data.operationId != widget.operationId) {
        throw StateError(operationUnavailable);
      }
      const service = ChangeRequests();
      final draft = actor?.role == OperatorRole.office
          ? service.move(operation, actor, data, widget.changes, reason.text)
          : service.request(
              operation, actor, data, widget.changes, reason.text);
      (await repository.append(draft, actor!.author))
          .fold((failure) => throw StateError(failure.message), (_) {});
      if (mounted) Navigator.pop(context);
    } catch (failure, stack) {
      if (mounted) {
        setState(() => error = failure is StateError
            ? failure.message
            : vesselErrorMessage(failure, stack, 'guardar el cambio'));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final office =
        ref.watch(operatorProvider).value?.role == OperatorRole.office;
    final changes = widget.changes;
    final data = ref.watch(loadingOperationProvider(widget.voyage)).value;
    String name(String key) {
      final item = data?.plan.loading[key];
      final order = item?.container == null
          ? null
          : data?.list?.byContainer(item!.container!.containerId)?.order;
      return '${order == null ? '' : 'OR $order · '}${key.substring(2)}';
    }

    return PopScope(
        canPop: !busy,
        child: SafeArea(
            child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
              16, 16, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    changes.length == 2
                        ? 'Intercambiar ${name(changes[0].target)} ↔ ${name(changes[1].target)}'
                        : 'Mover ${name(changes.single.target)}',
                    style: Theme.of(context).textTheme.titleLarge),
                for (final c in changes)
                  Text('${loadingPosition(c.from)} → ${loadingPosition(c.to)}'),
                if (!office)
                  const Text(
                      'El objeto sigue en su celda hasta que la oficina apruebe la solicitud.'),
                TextField(
                    key: const ValueKey('plan-drag-reason'),
                    controller: reason,
                    enabled: !busy,
                    minLines: 2,
                    maxLines: 4,
                    maxLength: 300,
                    onChanged: (_) => setState(() {}),
                    decoration:
                        const InputDecoration(labelText: 'Motivo obligatorio')),
                Wrap(spacing: 8, children: [
                  for (final suggestion in [
                    'Peso',
                    'Segregación',
                    'Acceso de grúa'
                  ])
                    ActionChip(
                        label: Text(suggestion),
                        onPressed: busy
                            ? null
                            : () => setState(() {
                                  reason.text = suggestion;
                                }))
                ]),
                if (error != null)
                  Text(error!,
                      key: const ValueKey('plan-drag-error'),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error)),
                Wrap(spacing: 12, children: [
                  TextButton(
                      onPressed: busy ? null : () => Navigator.pop(context),
                      child: const Text('Cancelar')),
                  FilledButton(
                      key: const ValueKey('plan-drag-confirm'),
                      onPressed:
                          busy || reason.text.trim().isEmpty ? null : save,
                      child: Text(busy
                          ? 'Guardando…'
                          : office
                              ? 'Confirmar'
                              : 'Enviar solicitud')),
                ]),
              ]),
        )));
  }
}
