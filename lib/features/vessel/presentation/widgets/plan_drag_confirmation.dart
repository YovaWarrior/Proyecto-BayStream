import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
/// controles, para no tapar ninguna celda.
class PlanZoomViewport extends ConsumerStatefulWidget {
  final Widget child;

  /// La oficina (`DESIGN.md` 14.1): la rejilla no tiene alto propio ni
  /// desplazamiento vertical; se amplía a su alto natural y le dice a la
  /// columna que la desplaza cuánto mide ampliada. Sin esto (el teléfono),
  /// el lienzo ocupa el alto que le dan y la rejilla se desplaza por dentro.
  final bool alturaNatural;
  const PlanZoomViewport(
      {super.key, required this.child, this.alturaNatural = false});

  @override
  ConsumerState<PlanZoomViewport> createState() => _PlanZoomViewportState();
}

class _PlanZoomViewportState extends ConsumerState<PlanZoomViewport> {
  double gestureScale = 1;
  double span = 1;
  final pointers = <int, Offset>{};

  void beginPinch() {
    if (pointers.length != 2) return;
    span = (pointers.values.first - pointers.values.last).distance;
    gestureScale = ref.read(planZoomProvider);
  }

  void endPointer(int pointer) {
    setState(() => pointers.remove(pointer));
    beginPinch();
  }

  @override
  Widget build(BuildContext context) {
    final scale = ref.watch(planZoomProvider);
    Widget ampliado(Widget hijo) => ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
            physics: pointers.length >= 2
                ? const NeverScrollableScrollPhysics()
                : null),
        child: PlanZoomScope(scale: scale, child: hijo));
    if (widget.alturaNatural) {
      return Listener(
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
          child: ClipRect(
              child: _AltoAmpliado(escala: scale, child: ampliado(widget.child))));
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Listener(
          key: const ValueKey('plan-zoom-gesture'),
          behavior: HitTestBehavior.opaque,
          // Observar dos contactos evita competir con los scrolls y
          // LongPressDraggable por el gesto de un solo dedo.
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
                          child: ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context)
                                  .copyWith(
                                      physics: pointers.length >= 2
                                          ? const NeverScrollableScrollPhysics()
                                          : null),
                              child: PlanZoomScope(
                                  scale: scale, child: widget.child)))))));
    });
  }
}

/// La rejilla de la oficina ampliada a su alto natural (14.1): el hijo se
/// arma al ancho de la vista lógica (el ancho entre la escala), con el alto
/// que pida, y se dibuja ampliado; la caja mide el ancho que le dan y el alto
/// del hijo por la escala, que es lo que la columna desplaza.
class _AltoAmpliado extends SingleChildRenderObjectWidget {
  const _AltoAmpliado({required this.escala, required super.child});

  final double escala;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderAltoAmpliado(escala);

  @override
  void updateRenderObject(
          BuildContext context, _RenderAltoAmpliado renderObject) =>
      renderObject.escala = escala;
}

class _RenderAltoAmpliado extends RenderProxyBox {
  _RenderAltoAmpliado(this._escala);

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
    final ancho = constraints.maxWidth;
    if (hijo == null) {
      size = constraints.smallest;
      return;
    }
    if (!ancho.isFinite) {
      hijo.layout(const BoxConstraints(), parentUsesSize: true);
      size = constraints.constrain(hijo.size * _escala);
      return;
    }
    final logico = ancho / _escala;
    hijo.layout(BoxConstraints(minWidth: logico, maxWidth: logico),
        parentUsesSize: true);
    size = constraints.constrain(Size(ancho, hijo.size.height * _escala));
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

  List<PositionChange> _changes(LoadingOperation current, _PlanDrag drag) {
    final other = current.plan.loadingItemAt(position);
    return [
      PositionChange(drag.target, drag.from, position),
      if (other != null && other.key != drag.target)
        PositionChange(other.key, other.plannedPosition, drag.from),
    ];
  }

  ChangePreview _preview(WidgetRef ref, _PlanDrag drag) {
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
    if (drag.from.substring(0, 3) != position.substring(0, 3)) {
      return const ChangePreview.invalid(
          'El arrastre solo mueve dentro de la bahía: para otra bahía utiliza '
          'el formulario.');
    }
    return const ChangeRequests().preview(
        current, ref.read(operatorProvider).value, _changes(current, drag));
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
      cell = LongPressDraggable<_PlanDrag>(
        key: ValueKey('plan-drag-$itemKey'),
        data: _PlanDrag(operation!.id, source.key, source.plannedPosition),
        maxSimultaneousDrags: 1,
        dragAnchorStrategy: pointerDragAnchorStrategy,
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
    return DragTarget<_PlanDrag>(
      key: ValueKey('plan-drop-$position'),
      // Acepta también el rojo para explicar el motivo al soltar, sin guardar.
      onWillAcceptWithDetails: (_) => enableDrag,
      onAcceptWithDetails: (details) {
        final result = _preview(ref, details.data);
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
                operationId: details.data.operationId,
                changes: _changes(current, details.data)));
      },
      builder: (context, candidates, rejected) {
        final preview =
            candidates.isEmpty ? null : _preview(ref, candidates.first!);
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
