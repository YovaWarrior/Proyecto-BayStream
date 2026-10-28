// T-123 · La 3.1.1 dentro del rediseño (SPRINT-4.md 10.63): lo que la mezcla
// tocó a mano y lo que se mezcló solo, visto en la oficina y en el teléfono.
//
// - H4 en las fichas de 14.7 y en la franja de la bahía (14.8): «OR / últimos
//   dígitos» no se apaga sin listado, con el rótulo o solo con el icono
//   (10.40), y la ficha de «revisar» dice que los llenos se cargan por su
//   número y los vacíos esperan el listado.
// - H7 en la columna de la oficina (14.1): la rejilla ya no tiene
//   desplazamiento vertical propio, así que durante el arrastre lo que se
//   desplaza es la columna entera, y al soltar cuenta la celda bajo el puntero.
import 'package:baystream/features/vessel/presentation/widgets/bay_plan_view.dart';
import 'package:baystream/features/vessel/presentation/widgets/loading_plan_controls.dart';
import 'package:baystream/features/vessel/presentation/widgets/plan_drag_confirmation.dart';
import 'package:baystream/core/design/design.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t117_oficina_support.dart';
import 't105_drag_widget_test.dart' as t105;

const _aviso =
    'Sin listado de agencia: los llenos se cargan por su número; los vacíos '
    'esperan el listado';

/// Si «OR / últimos dígitos» se puede pulsar, sea con el rótulo (`TextButton`)
/// o solo con el icono (`IconButton`, 10.40).
bool _orDisponible(WidgetTester tester) {
  final widget = tester.widget(find.byKey(const ValueKey('load-search')));
  return switch (widget) {
    TextButton(:final onPressed) => onPressed != null,
    IconButton(:final onPressed) => onPressed != null,
    _ => throw StateError('«OR / últimos dígitos» es ${widget.runtimeType}'),
  };
}

String _ficha(WidgetTester tester, String clave) =>
    tester.widget<BsFichaDeCifra>(find.byKey(ValueKey(clave))).texto;

void main() {
  group('H4 en la oficina (14.7 y 14.8)', () {
    testWidgets(
        'a 1366 × 690, en Carga sin listado, «OR / últimos dígitos» está '
        'disponible en la franja de la bahía y la ficha dice la regla nueva',
        (tester) async {
      await t117Pump(tester,
          tamano: const Size(1366, 690), modo: BayPlanMode.loading);
      final buscar = find.byKey(const ValueKey('load-search'));
      expect(
          find.descendant(
              of: find.byKey(const ValueKey('franja-de-la-bahia')),
              matching: buscar),
          findsOneWidget);
      expect(_orDisponible(tester), isTrue,
          reason: '«OR / últimos dígitos» no se apaga sin listado (H4)');
      expect(
          find.descendant(
              of: find.byKey(const ValueKey('franja-de-cifras')),
              matching: find.byKey(const ValueKey('loading-sin-listado'))),
          findsOneWidget);
      expect(_ficha(tester, 'loading-sin-listado'), _aviso);
      expect(find.text('Importa el listado de agencia para operar por OR.'),
          findsNothing);
      // Se pulsa y abre la búsqueda de carga, sin listado.
      await tester.tap(buscar);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('loading-query')), findsOneWidget);
      await tester.tap(find.text('Cerrar').last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'con la letra a 1.45, solo con su icono (10.40), sigue disponible',
        (tester) async {
      await t117Pump(tester,
          tamano: const Size(1366, 690), letra: 1.45, modo: BayPlanMode.loading);
      final buscar = find.byKey(const ValueKey('load-search'));
      expect(tester.widget(buscar), isA<IconButton>());
      expect(tester.widget<IconButton>(buscar).tooltip, 'OR / últimos dígitos');
      expect(_orDisponible(tester), isTrue);
      expect(_ficha(tester, 'loading-sin-listado'), _aviso);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets(
      'H4 en el teléfono: a 360 × 800, en Carga sin listado, el botón de la '
      'línea del resumen está disponible y la ficha dice la regla nueva',
      (tester) async {
    await t117Pump(tester,
        tamano: const Size(360, 800), modo: BayPlanMode.loading);
    expect(find.byKey(const ValueKey('plan-summary-line')), findsOneWidget);
    expect(tester.widget(find.byKey(const ValueKey('load-search'))),
        isA<TextButton>());
    expect(_orDisponible(tester), isTrue);
    expect(_ficha(tester, 'loading-sin-listado'), _aviso);
    expect(tester.takeException(), isNull);
  });

  group('H7 en la columna de la oficina (14.1)', () {
    for (final (name, kind) in [
      ('dedo', PointerDeviceKind.touch),
      ('mouse', PointerDeviceKind.mouse),
    ]) {
      testWidgets(
          'a 800 × 420, con el $name en el borde de abajo se desplaza la '
          'columna entera y al soltar cuenta la celda bajo el puntero',
          (tester) async {
        tester.view.physicalSize = const Size(800, 420);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final (log, _) = await t105.start(tester);
        // La oficina: la columna desplaza, la rejilla ya no.
        final columna = find.byKey(const ValueKey('columna-del-plano'));
        expect(columna, findsOneWidget);
        final origin = find.byKey(const ValueKey('plan-cell-0030282'));
        await tester.ensureVisible(origin);
        await tester.pumpAndSettle();
        final vertical =
            Scrollable.of(tester.element(origin), axis: Axis.vertical).position;
        // El desplazamiento vertical más cercano a la celda es el de la
        // columna (`CustomScrollView`), no uno propio de la rejilla.
        final deLaColumna = tester
            .state<ScrollableState>(find
                .descendant(of: columna, matching: find.byType(Scrollable))
                .first)
            .position;
        expect(vertical, same(deLaColumna));
        expect(vertical.maxScrollExtent, greaterThan(0),
            reason: 'la columna es más alta que la ventana');
        vertical.jumpTo(0);
        await tester.pumpAndSettle();
        final start = tester.getCenter(origin);
        final viewport = tester.getRect(columna);
        expect(viewport.contains(start), isTrue);
        final gesture = await tester.startGesture(start, kind: kind);
        await tester.pump(const Duration(milliseconds: 600));

        // Con el puntero quieto en el borde de abajo, la columna se desplaza
        // sola hasta el final.
        final edge = Offset(start.dx, viewport.bottom - 28);
        await gesture.moveTo(edge);
        for (var i = 0; i < 80; i++) {
          await tester.pump(const Duration(milliseconds: 20));
        }
        expect(vertical.pixels, vertical.maxScrollExtent,
            reason: 'la columna se desplaza mientras el puntero está en el borde');

        // Al soltar cuenta lo que queda bajo el puntero: una celda abre la
        // hoja (o explica por qué no), y nada se guarda.
        await gesture.up();
        await tester.pumpAndSettle();
        if (find.byType(PlanDragConfirmation).evaluate().isNotEmpty) {
          await tester.tap(find.text('Cancelar'));
          await tester.pumpAndSettle();
        }
        expect(log.of('op'), isEmpty);
        expect(find.byType(BayPlanView), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
