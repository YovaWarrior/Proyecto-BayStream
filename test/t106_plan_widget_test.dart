import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_operation_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_plan_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/bay_plan_view.dart';
import 'package:baystream/features/vessel/presentation/widgets/plan_drag_confirmation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/local_profile_test_support.dart';
import 'support/t75_memory_log.dart';
import 'support/t76_fixture.dart';
import 't105_drag_widget_test.dart' show start, mode, openZoom, drag;
import 't81_office_changes_test.dart' as f;

/// T-106 · Lo que el planner ve: el zoom a 300 % en una ventana ancha, la
/// copia que se arrastra a escala, la descarga pendiente en Carga y los 20 de
/// las impares vecinas en una par. Datos sintéticos de T-76.

/// La rejilla de la 003 de T-105: filas 00 a 06 en el nivel 82.
const _bay3 = [
  '0030082', '0030182', '0030282', '0030382', '0030482', '0030582', '0030682'
];

Future<void> _zoomTo300(WidgetTester tester) async {
  await openZoom(tester);
  for (var i = 0; i < 8; i++) {
    await tester.tap(find.byKey(const ValueKey('plan-zoom-in')));
    await tester.pumpAndSettle();
  }
  await tester.tap(find.byKey(const ValueKey('plan-zoom-toggle')));
  await tester.pumpAndSettle();
  expect(find.text('300 %'), findsOneWidget);
}

/// El plano sobre una operación fija, sin bitácora que la cambie.
Future<ProviderContainer> _pump(
    WidgetTester tester, VesselVoyage voyage, LoadingOperation data) async {
  final scope = ProviderContainer(overrides: [
    movementLogRepositoryProvider.overrideWith((ref) async => T75MemoryLog()),
    vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
    operatorProvider.overrideWith((ref) => Stream.value(f.office)),
    activeOperationProvider.overrideWith((ref) async => f.operation),
    loadingOperationProvider(voyage).overrideWith((ref) => Stream.value(data)),
    loadingPlanProgressProvider(voyage)
        .overrideWith((ref) => Stream.value(data.progress)),
  ]);
  addTearDown(scope.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
      container: scope,
      child: MaterialApp(home: Scaffold(body: BayPlanView(voyage: voyage)))));
  await tester.pumpAndSettle();
  await mode(tester, 'Carga');
  return scope;
}

/// El plan de T-105 (fila 00 en cubierta) con una descarga pendiente en la
/// 0030082, que el plan de carga deja vacía.
final _loading = t76Loading.withGeometry(
    t76Loading.geometry!.copyWith(centerRowOnDeck: true),
    portOfCall: 'GTSTC');
LoadingOperation _arriving([List<Movement> movements = const []]) =>
    LoadingOperation.build(
        operationId: 'op',
        arrival: t76Voyage([t76Unit('ARRIVAL0', '0030082', incoming: true)]),
        loading: _loading,
        list: t76List,
        movements: movements);

Finder _inCell(String position, Finder matching) => find.descendant(
    of: find.byKey(ValueKey('plan-cell-$position')), matching: matching);

/// Las sombras de los 20 de las impares vecinas: cada una con su clave, por
/// su posición en la par (`neighbor-twenty-0040282`; O-124-1, T-125).
final _neighborTwenties = find.byWidgetPredicate((w) =>
    w.key is ValueKey<String> &&
    (w.key! as ValueKey<String>).value.startsWith('neighbor-twenty-'));

/// El título de la bahía («Bahía 03»): en el teléfono, sobre la rejilla, con
/// las tapas si no están declaradas; en la oficina, en la franja de la bahía
/// (T-117, DESIGN.md 14.8), que lo escribe aparte de sus cifras.
Finder _title(int bay) => find.textContaining(
    RegExp('^Bahía ${bay.toString().padLeft(2, '0')}(\$| ·)'));

void main() {
  for (final width in [1600.0, 1920.0]) {
    testWidgets(
        'T-106 a 300 % con ${width.round()} px la rejilla abre a la vista',
        (tester) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final (log, _) = await start(tester, actor: null);
      await _zoomTo300(tester);
      // Sin desplazar: antes, la rejilla quedaba centrada en un lienzo tan
      // ancho como la vista y la pantalla abría en blanco. En la oficina
      // (T-117) el título va en la franja de la bahía, encima de la rejilla.
      final viewport =
          tester.getRect(find.byKey(const ValueKey('plan-zoom-gesture')));
      expect(
          find.descendant(
              of: find.byKey(const ValueKey('franja-de-la-bahia')),
              matching: _title(3)),
          findsOneWidget);
      expect(tester.getRect(find.byKey(const ValueKey('franja-de-la-bahia'))).bottom,
          lessThanOrEqualTo(viewport.top + .5));
      for (final position in _bay3) {
        final cell = find.byKey(ValueKey('plan-cell-$position'));
        expect(viewport.contains(tester.getCenter(cell)), isTrue,
            reason: position);
        expect(cell.hitTestable(), findsOneWidget, reason: position);
      }
      expect(log.of('op'), isEmpty);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('T-106 el margen de 16 dp no se escala con el zoom',
      (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await start(tester, actor: null);
    // En la oficina (T-117, DESIGN.md 14.1) la rejilla va a su alto natural:
    // el margen es un `Padding`, no el de un desplazable vertical propio.
    final viewport = find.byKey(const ValueKey('plan-zoom-gesture'));
    final relleno = find
        .descendant(of: viewport, matching: find.byType(Padding))
        .first;
    final content =
        find.descendant(of: relleno, matching: find.byType(Column)).first;
    Offset margin() =>
        tester.getTopLeft(content) - tester.getTopLeft(viewport);
    expect(tester.widget<Padding>(relleno).padding, const EdgeInsets.all(16));
    expect(margin().dx, closeTo(16, .5));
    expect(margin().dy, closeTo(16, .5));
    await _zoomTo300(tester);
    expect(tester.widget<Padding>(relleno).padding,
        const EdgeInsets.all(16 / 3));
    expect(margin().dx, closeTo(16, .5));
    expect(margin().dy, closeTo(16, .5));
  });

  testWidgets('T-106 la copia que se arrastra se dibuja a la escala del zoom',
      (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final (log, _) = await start(tester);
    await _zoomTo300(tester);
    final cell = find.byKey(const ValueKey('plan-cell-0030282'));
    // A 300 % la fila de arriba puede quedar bajo el borde del área del plano
    // (el título va al ancho de la vista y, con la fuente de prueba, ocupa dos
    // líneas): se trae a la vista antes de tomar la celda.
    await tester.ensureVisible(cell);
    final cellRect = tester.getRect(cell);
    final gesture = await tester.startGesture(tester.getCenter(cell));
    await tester.pump(const Duration(milliseconds: 600));
    final pointer = tester.getCenter(cell) + const Offset(0, 30);
    await gesture.moveTo(pointer);
    await tester.pump();
    final feedback = find.byKey(const ValueKey('plan-drag-feedback'));
    expect(feedback, findsOneWidget);
    // Se mide lo que la escala dibuja: el propio Transform no la incluye.
    final copy = tester.getRect(
        find.descendant(of: feedback, matching: find.byType(Opacity)).first);
    expect(copy.width, closeTo(cellRect.width, 1));
    expect(copy.height, closeTo(cellRect.height, 1));
    // Centrada sobre el dedo y por encima de él, también a 300 %.
    expect(copy.center.dx, closeTo(pointer.dx, 1));
    expect(copy.bottom, lessThan(pointer.dy));
    // Se suelta fuera de toda celda: no abre hoja ni registra.
    await gesture
        .moveTo(tester.getCenter(find.byKey(const ValueKey('bay-selector'))));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.byType(PlanDragConfirmation), findsNothing);
    expect(log.of('op'), isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'T-106 Carga dibuja la descarga pendiente: no se arrastra, el toque abre '
      'detalle y soltar ahí sigue en rojo', (tester) async {
    final data = _arriving();
    expect(data.state['C:ARRIVAL0']!.role, PlanRole.discharge);
    expect(data.state['C:ARRIVAL0']!.position, '0030082');
    await _pump(tester, _loading, data);
    final pending = find.byKey(const ValueKey('pending-discharge-ARRIVAL0'));
    expect(_inCell('0030082', pending), findsOneWidget);
    expect(
        find.descendant(
            of: pending, matching: find.byKey(const ValueKey('discharge-pending'))),
        findsOneWidget);
    expect(find.descendant(of: pending, matching: find.text('Baja')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('plan-drag-C:ARRIVAL0')), findsNothing);
    expect(find.byKey(const ValueKey('plan-drag-C:FULL0001234')), findsOneWidget);

    await tester.ensureVisible(pending);
    await tester.tap(pending);
    await tester.pumpAndSettle();
    final sheet = find.byType(DraggableScrollableSheet);
    expect(sheet, findsOneWidget);
    expect(find.descendant(of: sheet, matching: find.textContaining('ARRIVAL0')),
        findsWidgets);
    Navigator.of(tester.element(sheet)).pop();
    await tester.pumpAndSettle();

    await drag(tester, '0030282', '0030082', expected: 'invalid');
    expect(
        find.text('0030082 choca con ARRIVAL0 en 0030082. '
            'La celda está ocupada a bordo; marca primero su descarga.'),
        findsOneWidget);
    expect(find.byType(PlanDragConfirmation), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('T-106 registrada la descarga, la celda vuelve a verse libre',
      (tester) async {
    final data = _arriving(
        [t76Movement(MovementDraft.discharge('op', 'ARRIVAL0', '0030082'), 1)]);
    expect(data.state['C:ARRIVAL0']!.position, isNull);
    await _pump(tester, _loading, data);
    expect(find.byKey(const ValueKey('pending-discharge-ARRIVAL0')),
        findsNothing);
    await drag(tester, '0030282', '0030082');
    expect(find.byType(PlanDragConfirmation), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  group('T-106 los 20 de las impares vecinas en la vista de una par', () {
    // Un 40 pendiente en la 004 y, alrededor, 20 de la 003 y de la 005: del
    // plan, una reserva y una descarga pendiente que llega a bordo.
    final voyage = t76Voyage([
      t76Unit('FULL0001234', '0030282'),
      t76Unit('FULL0005678', '0030682'),
      t76Unit('FORTY0000001', '0040482').copyWith(isoSizeType: '45G1'),
      t76Unit('TWENTY0000008', '0050882'),
    ], slots: [
      t76Slot('0050282'),
    ]);
    LoadingOperation data() => LoadingOperation.build(
        operationId: 'op',
        arrival: t76Voyage([t76Unit('ARRIVAL6', '0050682', incoming: true)]),
        loading: voyage,
        list: t76List);

    Future<ProviderContainer> bay4(WidgetTester tester) async {
      final scope = await _pump(tester, voyage, data());
      scope.read(selectedBayProvider.notifier).select(4);
      await tester.pumpAndSettle();
      expect(_title(4), findsOneWidget);
      return scope;
    }

    testWidgets('se dibujan como sombra, con cuántos 20 hay en la celda',
        (tester) async {
      await bay4(tester);
      final shadow = _neighborTwenties;
      expect(shadow, findsNWidgets(3));
      // Fila 02: el 20 de la 003 y la reserva de la 005. Fila 06: el 20 de la
      // 003 y la descarga pendiente de la 005. Fila 08: un 20 de la 005.
      for (final (position, label) in [
        ('0040282', '2×20′'),
        ('0040682', '2×20′'),
        ('0040882', '20′'),
      ]) {
        final own = find.byKey(ValueKey('neighbor-twenty-$position'));
        expect(own, findsOneWidget, reason: position);
        expect(
            find.descendant(
                of: _inCell(position, own), matching: find.text(label)),
            findsOneWidget,
            reason: position);
      }
      // La leyenda lo explica sin cambiar la de C-5b.
      expect(find.text('Ocupado por 20 pies'), findsOneWidget);
      expect(find.text('Ocupado por 40 pies'), findsOneWidget);
      // La celda del 40 sigue siendo la del 40.
      expect(_inCell('0040482', shadow), findsNothing);
      expect(find.byKey(const ValueKey('plan-drag-C:FORTY0000001')),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('es solo dibujo: no se arrastra ni se toca', (tester) async {
      await bay4(tester);
      for (final position in ['0040282', '0040682', '0040882']) {
        expect(
            _inCell(position,
                find.byWidgetPredicate((w) => w is LongPressDraggable)),
            findsNothing,
            reason: position);
        expect(
            _inCell(
                position,
                find.byWidgetPredicate((w) =>
                    w is GestureDetector &&
                    (w.onTap != null || w.onLongPress != null))),
            findsNothing,
            reason: position);
        final cell = find.byKey(ValueKey('plan-cell-$position'));
        await tester.ensureVisible(cell);
        await tester.tap(cell);
        await tester.pumpAndSettle();
        await tester.longPress(cell);
        await tester.pumpAndSettle();
        expect(find.byType(BottomSheet), findsNothing, reason: position);
        expect(find.byType(Dialog), findsNothing, reason: position);
        expect(find.byType(SnackBar), findsNothing, reason: position);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('el rojo de 10.63 coincide con lo que se ve', (tester) async {
      await bay4(tester);
      await drag(tester, '0040482', '0040282', expected: 'invalid');
      expect(
          find.text('0040282 choca con OR 1 · FULL0001234 en 0030282: un 40 '
              'ocupa las dos mitades de la celda. Un 20 y un 40 no se '
              'intercambian: elige otra celda del mismo tamaño.'),
          findsOneWidget);
      expect(find.byType(PlanDragConfirmation), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('la impar vecina no dibuja sombras de 20', (tester) async {
      final scope = await _pump(tester, voyage, data());
      for (final bay in [3, 5]) {
        scope.read(selectedBayProvider.notifier).select(bay);
        await tester.pumpAndSettle();
        expect(_title(bay), findsOneWidget);
        expect(_neighborTwenties, findsNothing, reason: 'bahía $bay');
        expect(find.text('Ocupado por 20 pies'), findsNothing,
            reason: 'bahía $bay');
      }
      expect(tester.takeException(), isNull);
    });
  });
}
