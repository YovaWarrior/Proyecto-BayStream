// T-122 · H7 (SPRINT-4.md 10.56): en el teléfono, al arrastrar un contenedor
// de un extremo de la bahía al otro, el plano se desplaza solo cuando el dedo
// (o el mouse) llega al borde de la vista, también con zoom, y al soltar
// cuenta la celda que queda bajo el dedo aunque el plano se haya movido
// debajo de un dedo quieto. Estaba en rojo antes del arreglo: el plano no se
// desplazaba.
import 'package:baystream/features/vessel/presentation/widgets/loading_controls.dart'
    show loadingPosition;
import 'package:baystream/features/vessel/presentation/widgets/plan_drag_confirmation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 't105_drag_widget_test.dart' as t105;

/// La celda del plano que contiene [point], por su posición ISO.
String? _cellUnder(WidgetTester tester, Offset point) {
  for (final element in find
      .byWidgetPredicate((w) =>
          w.key is ValueKey<String> &&
          (w.key as ValueKey<String>).value.startsWith('plan-cell-'))
      .evaluate()) {
    final box = element.renderObject as RenderBox?;
    if (box == null || !box.hasSize || !box.attached) continue;
    final rect = box.localToGlobal(Offset.zero) & box.size;
    if (rect.contains(point)) {
      return (element.widget.key as ValueKey<String>)
          .value
          .substring('plan-cell-'.length);
    }
  }
  return null;
}

void main() {
  for (final (name, kind, zoom) in [
    ('dedo', PointerDeviceKind.touch, false),
    ('dedo con zoom al 125 %', PointerDeviceKind.touch, true),
    ('mouse', PointerDeviceKind.mouse, false),
  ]) {
    testWidgets(
        'H7 · a 360 dp, con el $name en el borde el plano se desplaza y suelta en la celda bajo el puntero',
        (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final (log, _) = await t105.start(tester);
      if (zoom) {
        await t105.openZoom(tester);
        await tester.tap(find.byKey(const ValueKey('plan-zoom-in')));
        await tester.pumpAndSettle();
        expect(find.text('125 %'), findsOneWidget);
      }
      final origin = find.byKey(const ValueKey('plan-cell-0030282'));
      final horizontal =
          Scrollable.of(tester.element(origin), axis: Axis.horizontal).position;
      horizontal.jumpTo(0);
      await tester.pumpAndSettle();
      expect(horizontal.maxScrollExtent, greaterThan(0),
          reason: 'la bahía es más ancha que el teléfono');
      final start = tester.getCenter(origin);
      final viewport =
          tester.getRect(find.byKey(const ValueKey('plan-zoom-gesture')));
      final gesture = await tester.startGesture(start, kind: kind);
      await tester.pump(const Duration(milliseconds: 600));

      // 1. Con el puntero quieto en el borde derecho, el plano se desplaza
      //    solo hasta el final.
      final edge = Offset(viewport.right - 28, start.dy);
      await gesture.moveTo(edge);
      for (var i = 0; i < 80; i++) {
        await tester.pump(const Duration(milliseconds: 20));
      }
      expect(horizontal.pixels, horizontal.maxScrollExtent,
          reason: 'el plano se desplaza mientras el puntero está en el borde');

      // 2. El puntero se posa sobre una celda que antes no estaba a la vista.
      final target = find.byKey(const ValueKey('plan-cell-0030382'));
      final point = tester.getCenter(target);
      expect(viewport.contains(point), isTrue);
      await gesture.moveTo(point);
      await tester.pump();
      // La 003-03-82 es una reserva: soltar ahí sería un intercambio.
      expect(find.byKey(const ValueKey('plan-preview-swap-0030382')),
          findsOneWidget);

      // 3. El plano se mueve bajo el puntero quieto (como cuando el
      //    desplazamiento sigue solo): la celda de debajo es otra.
      horizontal.jumpTo(0);
      await tester.pump();
      final under = _cellUnder(tester, point);
      expect(under, isNotNull, reason: 'bajo el puntero hay una celda');
      expect(under, isNot('0030382'));
      expect(under, isNot('0030282'));

      // 4. Al soltar cuenta la celda que queda bajo el puntero, no la última
      //    que el gesto visitó.
      await gesture.up();
      await tester.pumpAndSettle();
      expect(find.byType(PlanDragConfirmation), findsOneWidget);
      expect(find.textContaining('→ ${loadingPosition(under!)}'),
          findsOneWidget);
      expect(find.textContaining('→ ${loadingPosition('0030382')}'),
          findsNothing);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(log.of('op'), isEmpty);
      expect(tester.takeException(), isNull);
    });
  }
}
