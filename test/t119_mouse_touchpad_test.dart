// T-119 · El mouse y el touchpad (SPRINT-4.md 10.36, 10.38 y 10.76;
// DESIGN.md 16): la rueda en la silueta, con su pestillo; el pellizco del
// touchpad y Ctrl + rueda para el zoom; el punto bajo el puntero quieto; y la
// barra horizontal de la rejilla, abajo de la columna.
//
// Con eventos sintéticos por `tester.sendEventToBinding`: la rueda del mouse
// (`PointerScrollEvent`, con y sin Ctrl), el touchpad de precisión de Windows
// (`PointerPanZoom…`) y el pellizco que el motor web entrega como
// `PointerScaleEvent`. En Windows, con las fuentes del producto. Solo usa
// claves y piezas que ya existían, para poder correr también contra el código
// de antes de T-119, donde cada una falla. Buque y números sintéticos (BUQUE
// MANUAL, TSTU).
import 'dart:math' as math;

import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/providers/plano_providers.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t117_oficina_support.dart';

/// El plano de T-117 con 30 bahías más (de la 010 a la 126, de cuatro en
/// cuatro), un 40 en cubierta en cada una: la silueta mide 1 848 dp y no cabe
/// en la columna, así que se desplaza.
final _muchasBahias = () {
  final texto = StringBuffer(t117Texto);
  var numero = 5000;
  for (var bahia = 10; bahia <= 126; bahia += 4) {
    final posicion = '${bahia.toString().padLeft(3, '0')}0182';
    texto.write("LOC+147+$posicion::5'LOC+9+HNPCR:139:6'LOC+11+GTSTC:139:6'"
        "MEA+AAE+VGM+KGM:20000'EQD+CN+TSTU${(numero++).toString().padLeft(7, '0')}"
        "+42G1+++5'");
  }
  final leido = BaplieParserService().parse(texto.toString());
  return leido.withGeometry(
      VesselProfile.proposeFrom(leido)
          .geometry
          .copyWith(portRows: 4, starboardRows: 4),
      portOfCall: 'GTSTC');
}();

/// La ventana de 1366 × 768 maximizada, con el panel fijo.
const _ventana = Size(1366, 690);

final _windows = TargetPlatformVariant.only(TargetPlatform.windows);

final _silueta = find.byKey(const ValueKey('silueta-del-viaje'));
final _lienzo = find.byKey(const ValueKey('plan-zoom-gesture'));
final _barra = find.byKey(const ValueKey('barra-de-la-rejilla'));
final _franjaDeCifras = find.byKey(const ValueKey('franja-de-cifras'));
final _columnaDelPlano = find.byKey(const ValueKey('columna-del-plano'));

/// Una celda vacía de la bahía 002, en la fila 00 (el centro) y el nivel 90.
final _celda = find.byKey(const ValueKey('cell-0-90'));

ScrollPosition _desplazableDe(WidgetTester tester, Finder donde) => tester
    .state<ScrollableState>(
        find.descendant(of: donde, matching: find.byType(Scrollable)).first)
    .position;

ScrollPosition _columna(WidgetTester tester) =>
    _desplazableDe(tester, _columnaDelPlano);

ScrollPosition _laSilueta(WidgetTester tester) =>
    _desplazableDe(tester, _silueta.first);

/// El desplazamiento horizontal de la rejilla: el que contiene sus celdas.
ScrollPosition _rejilla(WidgetTester tester) =>
    Scrollable.of(tester.element(_celda), axis: Axis.horizontal).position;

double _zoom(ProviderContainer scope) => scope.read(planZoomProvider);

/// Un paso de la rueda del mouse en [donde], a la hora [ms].
Future<void> _rueda(WidgetTester tester, Offset donde, double dy,
    {int ms = 0}) async {
  final raton = TestPointer(1, PointerDeviceKind.mouse)..hover(donde);
  await tester.sendEventToBinding(
      raton.scroll(Offset(0, dy), timeStamp: Duration(milliseconds: ms)));
}

/// Ctrl + rueda en [donde].
Future<void> _ctrlRueda(WidgetTester tester, Offset donde, double dy) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  await _rueda(tester, donde, dy);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
}

/// Un punto de la silueta que se ve, con la columna donde esté: abajo,
/// porque arriba la tapa la cabecera en cuanto la columna se desplaza.
Offset _sobreLaSilueta(WidgetTester tester) {
  final caja = tester.getRect(_silueta.first);
  return Offset(caja.center.dx, caja.bottom - 30);
}

void main() {
  group('la rueda en la silueta (16.1)', () {
    testWidgets(
        'la rueda la avanza hacia la popa y la regresa, y la columna no se mueve',
        (tester) async {
      await t117Pump(tester, tamano: _ventana, voyage: _muchasBahias);
      final silueta = _laSilueta(tester);
      final columna = _columna(tester);
      expect(silueta.maxScrollExtent, greaterThan(300),
          reason: 'la silueta no cabe');
      expect(columna.maxScrollExtent, greaterThan(100),
          reason: 'la columna se desplaza');
      expect(silueta.pixels, 0);

      await _rueda(tester, _sobreLaSilueta(tester), 100);
      await tester.pump();
      expect(silueta.pixels, lessThan(100), reason: 'anima: 100 ms');
      await tester.pumpAndSettle();
      expect(silueta.pixels, 100, reason: 'abajo avanza hacia la popa');
      expect(columna.pixels, 0, reason: 'la columna no se mueve a la vez');

      // Dos pasos seguidos suman, aunque la animación no haya llegado.
      await _rueda(tester, _sobreLaSilueta(tester), 100, ms: 1000);
      await tester.pump(const Duration(milliseconds: 30));
      await _rueda(tester, _sobreLaSilueta(tester), 100, ms: 1030);
      await tester.pumpAndSettle();
      expect(silueta.pixels, 300);

      await _rueda(tester, _sobreLaSilueta(tester), -100, ms: 2000);
      await tester.pumpAndSettle();
      expect(silueta.pixels, 200, reason: 'arriba regresa hacia la proa');
      expect(columna.pixels, 0);
      expect(tester.takeException(), isNull);
    }, variant: _windows);

    testWidgets('sin animación si el sistema reduce el movimiento',
        (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
      await t117Pump(tester, tamano: _ventana, voyage: _muchasBahias);
      final silueta = _laSilueta(tester);
      await _rueda(tester, _sobreLaSilueta(tester), 100);
      await tester.pump();
      expect(silueta.pixels, 100, reason: 'en el mismo cuadro');
      expect(_columna(tester).pixels, 0);
    }, variant: _windows);

    testWidgets('en un extremo la rueda pasa a la columna; del otro lado, no',
        (tester) async {
      await t117Pump(tester, tamano: _ventana, voyage: _muchasBahias);
      final silueta = _laSilueta(tester);
      final columna = _columna(tester);
      silueta.jumpTo(silueta.maxScrollExtent);
      await tester.pumpAndSettle();

      // En la popa, hacia abajo: la silueta no puede, la rueda es de la
      // columna.
      await _rueda(tester, _sobreLaSilueta(tester), 40);
      await tester.pumpAndSettle();
      expect(silueta.pixels, silueta.maxScrollExtent);
      expect(columna.pixels, 40);

      // Pasado el pestillo, hacia arriba la silueta sí puede: es suya.
      await _rueda(tester, _sobreLaSilueta(tester), -40, ms: 1000);
      await tester.pumpAndSettle();
      expect(silueta.pixels, silueta.maxScrollExtent - 40);
      expect(columna.pixels, 40, reason: 'la columna no se mueve');

      // En la proa, hacia arriba, vuelve a ser de la columna.
      silueta.jumpTo(0);
      await tester.pumpAndSettle();
      await _rueda(tester, _sobreLaSilueta(tester), -40, ms: 2000);
      await tester.pumpAndSettle();
      expect(silueta.pixels, 0);
      expect(columna.pixels, 0);
    }, variant: _windows);

    testWidgets(
        'el pestillo: si la columna se movió con la rueda hace menos de 300 ms, '
        'la rueda sigue con la columna sobre la silueta', (tester) async {
      await t117Pump(tester, tamano: _ventana, voyage: _muchasBahias);
      final silueta = _laSilueta(tester);
      final columna = _columna(tester);
      final sobreLaRejilla = tester.getCenter(_celda);

      // La rueda sobre la rejilla desplaza la columna.
      await _rueda(tester, sobreLaRejilla, 20, ms: 1000);
      await tester.pumpAndSettle();
      expect(columna.pixels, 20);

      // 100 ms después, sobre la silueta: sigue la columna.
      await _rueda(tester, _sobreLaSilueta(tester), 20, ms: 1100);
      await tester.pumpAndSettle();
      expect(columna.pixels, 40);
      expect(silueta.pixels, 0);

      // 299 ms después del último paso de la columna: todavía.
      await _rueda(tester, _sobreLaSilueta(tester), 20, ms: 1399);
      await tester.pumpAndSettle();
      expect(columna.pixels, 60);
      expect(silueta.pixels, 0);

      // 300 ms sin rueda en la columna: la rueda vuelve a la silueta.
      await _rueda(tester, _sobreLaSilueta(tester), 20, ms: 1699);
      await tester.pumpAndSettle();
      expect(columna.pixels, 60);
      expect(silueta.pixels, 20);

      // Lo que toma la silueta no alarga el pestillo de la columna.
      await _rueda(tester, _sobreLaSilueta(tester), 20, ms: 1750);
      await tester.pumpAndSettle();
      expect(silueta.pixels, 40);
      expect(columna.pixels, 60);
    }, variant: _windows);
  });

  group('el zoom con Ctrl + rueda y el touchpad (16.2)', () {
    testWidgets(
        'Ctrl + rueda acerca y aleja por e^(−dy/200), entre 75 y 300 %, y la '
        'columna no se desplaza con ella', (tester) async {
      final scope = await t117Pump(tester, tamano: _ventana);
      final columna = _columna(tester);
      final lienzo = tester.getRect(_lienzo);
      // En el borde de arriba de la rejilla (su aire de 16 dp), el punto fijo
      // no mueve la columna: lo que se mueva, lo movió la rueda.
      final arriba = Offset(lienzo.center.dx, lienzo.top + 16);

      // La rueda sola sigue desplazando la columna.
      await _rueda(tester, arriba, 30);
      await tester.pumpAndSettle();
      expect(columna.pixels, 30);
      expect(_zoom(scope), 1);

      final arribaAhora = Offset(arriba.dx, tester.getRect(_lienzo).top + 16);
      await _ctrlRueda(tester, arribaAhora, -100);
      await tester.pumpAndSettle();
      expect(_zoom(scope), closeTo(math.exp(0.5), 1e-9));
      expect(columna.pixels, closeTo(30, 0.01));

      await _ctrlRueda(tester, arribaAhora, 100);
      await tester.pumpAndSettle();
      expect(_zoom(scope), closeTo(1, 1e-9));
      expect(columna.pixels, closeTo(30, 0.01));

      for (var i = 0; i < 6; i++) {
        await _ctrlRueda(tester, arribaAhora, -100);
        await tester.pumpAndSettle();
      }
      expect(_zoom(scope), 3, reason: 'el tope de 300 %');
      // En el tope, Ctrl + rueda sigue siendo del zoom: no desplaza.
      final enElTope = columna.pixels;
      await _ctrlRueda(tester, arribaAhora, -100);
      await tester.pumpAndSettle();
      expect(_zoom(scope), 3);
      expect(columna.pixels, enElTope);

      for (var i = 0; i < 6; i++) {
        await _ctrlRueda(
            tester, Offset(arriba.dx, tester.getRect(_lienzo).top + 16), 100);
        await tester.pumpAndSettle();
      }
      expect(_zoom(scope), .75, reason: 'el piso de 75 %');
      expect(tester.takeException(), isNull);
    }, variant: _windows);

    testWidgets(
        'el pellizco del touchpad amplía pasado el 1 %, acotado, y mientras '
        'dura no desplaza la rejilla ni la columna', (tester) async {
      final scope = await t117Pump(tester, tamano: _ventana);
      final lienzo = tester.getRect(_lienzo);
      final arriba = Offset(lienzo.center.dx, lienzo.top + 16);
      final touchpad = TestPointer(2, PointerDeviceKind.trackpad);

      await tester.sendEventToBinding(touchpad.panZoomStart(arriba));
      await tester.sendEventToBinding(
          touchpad.panZoomUpdate(arriba, scale: 1.008));
      await tester.pump();
      expect(_zoom(scope), 1, reason: 'por debajo del 1 %, solo desplaza');

      await tester.sendEventToBinding(touchpad.panZoomUpdate(arriba, scale: 2));
      await tester.pump();
      expect(_zoom(scope), 2);
      final rejilla = _rejilla(tester);
      final horizontal = rejilla.pixels;

      // Los dedos se corren mientras pellizcan: nada se desplaza.
      await tester.sendEventToBinding(touchpad.panZoomUpdate(arriba,
          pan: const Offset(-60, -60), scale: 2));
      await tester.pump();
      await tester.sendEventToBinding(touchpad.panZoomUpdate(arriba,
          pan: const Offset(-120, -120), scale: 2));
      await tester.pump();
      // Al empezar el pellizco la física cambia y los dos desplazamientos se
      // rehacen: se leen otra vez.
      expect(_columna(tester).pixels, 0, reason: 'la columna no se mueve');
      expect(_rejilla(tester).pixels, horizontal,
          reason: 'la rejilla no se mueve');

      await tester.sendEventToBinding(
          touchpad.panZoomUpdate(arriba, pan: const Offset(-120, -120), scale: 5));
      await tester.pump();
      expect(_zoom(scope), 3, reason: 'el tope de 300 %');
      await tester.sendEventToBinding(touchpad.panZoomUpdate(arriba,
          pan: const Offset(-120, -120), scale: 0.1));
      await tester.pump();
      expect(_zoom(scope), .75, reason: 'el piso de 75 %');
      await tester.sendEventToBinding(touchpad.panZoomEnd());
      await tester.pumpAndSettle();

      // Terminado el pellizco, los dos dedos vuelven a desplazar la columna.
      await tester.sendEventToBinding(touchpad.panZoomStart(arriba));
      for (var i = 1; i <= 4; i++) {
        await tester.sendEventToBinding(
            touchpad.panZoomUpdate(arriba, pan: Offset(0, -20.0 * i)));
        await tester.pump();
      }
      await tester.sendEventToBinding(touchpad.panZoomEnd());
      await tester.pumpAndSettle();
      expect(_zoom(scope), .75);
      expect(_columna(tester).pixels, greaterThan(0));
      expect(tester.takeException(), isNull);
    }, variant: _windows);

    testWidgets('el pellizco que la Web entrega como PointerScaleEvent amplía',
        (tester) async {
      final scope = await t117Pump(tester, tamano: _ventana);
      final lienzo = tester.getRect(_lienzo);
      final raton = TestPointer(1, PointerDeviceKind.mouse)
        ..hover(Offset(lienzo.center.dx, lienzo.top + 16));
      await tester.sendEventToBinding(raton.scale(1.5));
      await tester.pumpAndSettle();
      expect(_zoom(scope), closeTo(1.5, 1e-9));
      expect(_columna(tester).pixels, 0);
    }, variant: _windows);
  });

  group('el punto bajo el puntero se queda quieto (16.3)', () {
    testWidgets(
        'con Ctrl + rueda, también cuando la bahía pasa de caber centrada a '
        'no caber', (tester) async {
      final scope = await t117Pump(tester, tamano: _ventana);
      expect(_rejilla(tester).maxScrollExtent, 0,
          reason: 'al 100 % la bahía cabe y va centrada');
      final antes = tester.getCenter(_celda);
      await _ctrlRueda(tester, antes, -100);
      await tester.pumpAndSettle();
      expect(_zoom(scope), closeTo(math.exp(0.5), 1e-9));
      expect(_rejilla(tester).maxScrollExtent, greaterThan(0));
      final despues = tester.getCenter(_celda);
      expect(despues.dx, closeTo(antes.dx, 1));
      expect(despues.dy, closeTo(antes.dy, 1));

      // Y al alejar un poco, mientras la bahía siga sin caber.
      await _ctrlRueda(tester, despues, 20);
      await tester.pumpAndSettle();
      expect(_rejilla(tester).maxScrollExtent, greaterThan(0));
      final otra = tester.getCenter(_celda);
      expect(otra.dx, closeTo(antes.dx, 1));
      expect(otra.dy, closeTo(antes.dy, 1));
    }, variant: _windows);

    testWidgets('con el pellizco del touchpad, con la rejilla ya desplazada',
        (tester) async {
      final scope = await t117Pump(tester, tamano: _ventana);
      scope.read(planZoomProvider.notifier).fijar(1.5);
      await tester.pumpAndSettle();
      final rejilla = _rejilla(tester);
      rejilla.jumpTo(rejilla.maxScrollExtent / 2);
      _columna(tester).jumpTo(60);
      await tester.pumpAndSettle();
      final antes = tester.getCenter(_celda);
      final touchpad = TestPointer(2, PointerDeviceKind.trackpad);
      await tester.sendEventToBinding(touchpad.panZoomStart(antes));
      for (final escala in [1.1, 1.3, 1.6]) {
        await tester.sendEventToBinding(
            touchpad.panZoomUpdate(antes, scale: escala));
        await tester.pump();
        final ahora = tester.getCenter(_celda);
        expect(ahora.dx, closeTo(antes.dx, 1), reason: 'a ${1.5 * escala}');
        expect(ahora.dy, closeTo(antes.dy, 1), reason: 'a ${1.5 * escala}');
      }
      await tester.sendEventToBinding(touchpad.panZoomEnd());
      await tester.pumpAndSettle();
      expect(_zoom(scope), closeTo(2.4, 1e-9));
      expect(tester.takeException(), isNull);
    }, variant: _windows);
  });

  group('la barra horizontal de la rejilla (16.4)', () {
    testWidgets(
        'solo aparece cuando la bahía no cabe, pegada encima de la franja de '
        'cifras, con 14 dp de aire', (tester) async {
      final scope = await t117Pump(tester, tamano: _ventana);
      expect(_barra, findsOneWidget);
      Scrollbar barra() => tester.widget<Scrollbar>(_barra);
      expect(barra().thumbVisibility, isFalse, reason: 'la bahía cabe');
      expect(tester.getRect(_columnaDelPlano).bottom,
          tester.getRect(_barra).bottom,
          reason: 'sin barra, sin aire');

      scope.read(planZoomProvider.notifier).fijar(3);
      await tester.pumpAndSettle();
      expect(_rejilla(tester).maxScrollExtent, greaterThan(0));
      expect(barra().thumbVisibility, isTrue);
      expect(barra().trackVisibility, isTrue);
      expect(
          barra().controller,
          same(Scrollable.of(tester.element(_celda), axis: Axis.horizontal)
              .widget
              .controller),
          reason: 'la barra es la del desplazamiento de la rejilla');
      final caja = tester.getRect(_barra);
      expect(caja.bottom, tester.getRect(_franjaDeCifras).top,
          reason: 'pegada encima de la franja de cifras');
      expect(caja.bottom - tester.getRect(_columnaDelPlano).bottom, 14,
          reason: 'la columna deja 14 dp para la barra');

      scope.read(planZoomProvider.notifier).fijar(1);
      await tester.pumpAndSettle();
      expect(barra().thumbVisibility, isFalse, reason: 'cabe otra vez');
      expect(tester.getRect(_columnaDelPlano).bottom,
          tester.getRect(_barra).bottom);
      expect(tester.takeException(), isNull);
    }, variant: _windows);

    testWidgets(
        'arrastrar el pulgar mueve la rejilla y un clic en la pista avanza '
        'una página', (tester) async {
      final scope = await t117Pump(tester, tamano: _ventana);
      scope.read(planZoomProvider.notifier).fijar(3);
      await tester.pumpAndSettle();
      final rejilla = _rejilla(tester);
      expect(rejilla.pixels, 0);
      final caja = tester.getRect(_barra);
      final y = caja.bottom - 7;

      // El pulgar empieza a la izquierda.
      await tester.dragFrom(Offset(caja.left + 10, y), const Offset(150, 0),
          kind: PointerDeviceKind.mouse);
      await tester.pumpAndSettle();
      expect(rejilla.pixels, greaterThan(150),
          reason: 'la rejilla es más ancha que la barra');
      final arrastrada = rejilla.pixels;

      // Un clic en la pista, a la derecha del pulgar: una página.
      await tester.tapAt(Offset(caja.right - 10, y),
          kind: PointerDeviceKind.mouse);
      await tester.pumpAndSettle();
      expect(rejilla.pixels,
          closeTo(math.min(rejilla.maxScrollExtent,
              arrastrada + .8 * rejilla.viewportDimension), 1));
      expect(_columna(tester).pixels, 0, reason: 'la columna no se mueve');
      expect(tester.takeException(), isNull);
    }, variant: _windows);
  });
}
