// T-120, entrega 2 · El pellizco (`docs/T120-RESULTADOS.md` 1.5; SPRINT-4.md
// 10.148 y 10.168).
//
// O-119-1 (10.81): al pellizcar desde el 100 %, justo cuando la bahía deja de
// caber centrada, la celda se corría (1.9 dp en Chrome). La prueba de T-119
// solo miraba el cruce con un paso grande de Ctrl + rueda y 1 dp de
// tolerancia. Aquí, pasos chicos, cuadro por cuadro, con 0.25 dp: en cada
// paso, el punto que estaba bajo el puntero tiene que seguir ahí (16.3),
// salvo donde no puede (la bahía cabe y va centrada, o el desplazamiento
// está en su tope).
//
// La causa, confirmada con una prueba roja antes de cambiar nada: un `jumpTo`
// fuera del alcance medido arma una simulación de la física, que avanza en el
// cuadro siguiente antes de que se mida el alcance nuevo, y deja el
// desplazamiento en el tope viejo.
//
// O-128-4: si la ventana pierde el foco a media seña (Alt + Tab, un aviso del
// sistema) y nunca llega el final del gesto, el plano lo suelta: el pellizco
// del touchpad, la columna congelada y los contactos de la pantalla.
//
// Con eventos sintéticos por `tester.sendEventToBinding`, en Windows y con
// las fuentes del producto, sobre el plano sintético de T-117 (BUQUE MANUAL,
// TSTU). Solo usa claves y piezas que ya existían, para poder correr contra
// el código de antes del cambio.
import 'package:baystream/features/vessel/presentation/providers/plano_providers.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t117_oficina_support.dart';

/// La ventana de 1366 × 768 maximizada, con el panel fijo.
const _ventana = Size(1366, 690);

final _windows = TargetPlatformVariant.only(TargetPlatform.windows);

/// Una celda vacía de la bahía 002, en la fila 00 (el centro) y el nivel 90.
final _celda = find.byKey(const ValueKey('cell-0-90'));
final _columnaDelPlano = find.byKey(const ValueKey('columna-del-plano'));

/// Cuánto se puede apartar el punto bajo el puntero, en cada cuadro.
const _tolerancia = 0.25;

/// Un cuadro de 60 Hz.
const _cuadro = Duration(milliseconds: 16);

/// El desplazamiento horizontal de la rejilla: el que contiene sus celdas.
ScrollPosition _rejilla(WidgetTester tester, Finder celda) =>
    Scrollable.of(tester.element(celda), axis: Axis.horizontal).position;

ScrollPosition _columna(WidgetTester tester) => tester
    .state<ScrollableState>(find
        .descendant(of: _columnaDelPlano, matching: find.byType(Scrollable))
        .first)
    .position;

double _zoom(ProviderContainer scope) => scope.read(planZoomProvider);

/// Si el desplazamiento está en un tope (ahí la cuenta se acota a propósito).
bool _enUnTope(ScrollPosition p) =>
    p.pixels <= p.minScrollExtent + 0.01 ||
    p.pixels >= p.maxScrollExtent - 0.01;

/// Mira, cuadro por cuadro, que el punto bajo [foco] se quede quieto: de un
/// paso al siguiente, la celda tiene que ir a foco + (antes − foco) × razón
/// de las escalas. En horizontal solo si la bahía no cabe; si cabe, va
/// centrada (desplazamiento en 0). En vertical, si la columna no está en un
/// tope.
class _Registro {
  _Registro(this.tester, this.scope, this.celda, this.foco)
      : _antes = tester.getCenter(celda),
        _escalaAntes = scope.read(planZoomProvider);

  final WidgetTester tester;
  final ProviderContainer scope;
  final Finder celda;
  final Offset foco;
  Offset _antes;
  double _escalaAntes;

  double peor = 0;
  String donde = '';
  bool cruzo = false;
  bool cupo = false;
  int medidos = 0;

  /// Después de cada cuadro; con [cierra], ese cuadro es el último del paso.
  void mirar(String paso, {bool cierra = false}) {
    final escala = _zoom(scope);
    final ahora = tester.getCenter(celda);
    final razon = escala / _escalaAntes;
    final esperado = foco + (_antes - foco) * razon;
    final rejilla = _rejilla(tester, celda);
    final columna = _columna(tester);
    if (rejilla.maxScrollExtent > 0) {
      cruzo = true;
      if (!_enUnTope(rejilla)) {
        _anotar((ahora.dx - esperado.dx).abs(), '$paso, en horizontal');
      }
    } else {
      cupo = true;
      expect(rejilla.pixels, 0, reason: '$paso: cabe, así que va centrada');
    }
    if (!_enUnTope(columna)) {
      _anotar((ahora.dy - esperado.dy).abs(), '$paso, en vertical');
    }
    if (cierra) {
      _antes = ahora;
      _escalaAntes = escala;
    }
  }

  void _anotar(double desvio, String donde) {
    medidos++;
    if (desvio > peor) {
      peor = desvio;
      this.donde = donde;
    }
  }

  void comprobar() {
    debugPrint('peor desvío: ${peor.toStringAsFixed(3)} dp, en $donde '
        '($medidos medidas)');
    expect(medidos, greaterThan(10), reason: 'hubo con qué medir');
    expect(peor, lessThanOrEqualTo(_tolerancia),
        reason: 'el punto bajo el puntero se corrió '
            '${peor.toStringAsFixed(3)} dp ($donde)');
  }
}

/// Un paso del gesto y sus dos cuadros.
Future<void> _paso(WidgetTester tester, _Registro registro, String nombre,
    Future<void> Function() enviar) async {
  await enviar();
  await tester.pump(_cuadro);
  registro.mirar('$nombre, primer cuadro');
  await tester.pump(_cuadro);
  registro.mirar('$nombre, segundo cuadro', cierra: true);
}

/// La celda de la bahía que se ve más abajo en la columna.
Finder _celdaDeAbajo(WidgetTester tester) {
  final vista = tester.getRect(_columnaDelPlano);
  Finder? mejor;
  var y = double.negativeInfinity;
  for (final elemento in find
      .byWidgetPredicate((w) =>
          w.key is ValueKey<String> &&
          (w.key! as ValueKey<String>).value.startsWith('cell-'))
      .evaluate()) {
    final clave = elemento.widget.key!;
    final f = find.byKey(clave);
    if (f.evaluate().length != 1) continue;
    final centro = tester.getCenter(f);
    if (centro.dy < vista.bottom - 40 && centro.dy > vista.top && centro.dy > y) {
      y = centro.dy;
      mejor = f;
    }
  }
  return mejor!;
}

void main() {
  group('O-119-1 · el punto bajo el puntero, cuadro por cuadro', () {
    testWidgets(
        'el pellizco del touchpad, en pasos de 1 %, del 100 % a no caber',
        (tester) async {
      final scope = await t117Pump(tester, tamano: _ventana);
      expect(_rejilla(tester, _celda).maxScrollExtent, 0,
          reason: 'al 100 % la bahía cabe y va centrada');
      final foco = tester.getCenter(_celda);
      final registro = _Registro(tester, scope, _celda, foco);
      final touchpad = TestPointer(2, PointerDeviceKind.trackpad);
      await tester.sendEventToBinding(touchpad.panZoomStart(foco));
      await tester.pump(_cuadro);
      for (var paso = 2; paso <= 80; paso++) {
        final escala = 1 + paso / 100;
        await _paso(tester, registro, 'a ${escala.toStringAsFixed(2)}',
            () => tester.sendEventToBinding(
                touchpad.panZoomUpdate(foco, scale: escala)));
      }
      await tester.sendEventToBinding(touchpad.panZoomEnd());
      await tester.pumpAndSettle();
      registro.mirar('asentado');
      expect(_zoom(scope), closeTo(1.8, 1e-9));
      expect(registro.cupo && registro.cruzo, isTrue,
          reason: 'empieza cabiendo y deja de caber');
      registro.comprobar();
      expect(tester.takeException(), isNull);
    }, variant: _windows);

    testWidgets(
        'el pellizco del touchpad con la columna al fondo: el destino '
        'vertical pasa del alcance de antes', (tester) async {
      final scope = await t117Pump(tester, tamano: _ventana);
      final columna = _columna(tester);
      expect(columna.maxScrollExtent, greaterThan(100));
      columna.jumpTo(columna.maxScrollExtent);
      await tester.pumpAndSettle();
      final celda = _celdaDeAbajo(tester);
      final foco = tester.getCenter(celda);
      final registro = _Registro(tester, scope, celda, foco);
      final touchpad = TestPointer(2, PointerDeviceKind.trackpad);
      await tester.sendEventToBinding(touchpad.panZoomStart(foco));
      await tester.pump(_cuadro);
      for (var paso = 2; paso <= 40; paso++) {
        final escala = 1 + paso / 100;
        await _paso(tester, registro, 'a ${escala.toStringAsFixed(2)}',
            () => tester.sendEventToBinding(
                touchpad.panZoomUpdate(foco, scale: escala)));
      }
      await tester.sendEventToBinding(touchpad.panZoomEnd());
      await tester.pumpAndSettle();
      registro.mirar('asentado');
      registro.comprobar();
      expect(tester.takeException(), isNull);
    }, variant: _windows);

    testWidgets(
        'el pellizco del touchpad alejando, de no caber a caber otra vez',
        (tester) async {
      final scope = await t117Pump(tester, tamano: _ventana);
      scope.read(planZoomProvider.notifier).fijar(1.6);
      await tester.pumpAndSettle();
      final rejilla = _rejilla(tester, _celda);
      rejilla.jumpTo(rejilla.maxScrollExtent / 2);
      await tester.pumpAndSettle();
      final foco = tester.getCenter(_celda);
      final registro = _Registro(tester, scope, _celda, foco);
      final touchpad = TestPointer(2, PointerDeviceKind.trackpad);
      await tester.sendEventToBinding(touchpad.panZoomStart(foco));
      await tester.pump(_cuadro);
      for (var paso = 2; paso <= 50; paso++) {
        final escala = 1 - paso / 100;
        await _paso(tester, registro, 'a ${(1.6 * escala).toStringAsFixed(3)}',
            () => tester.sendEventToBinding(
                touchpad.panZoomUpdate(foco, scale: escala)));
      }
      await tester.sendEventToBinding(touchpad.panZoomEnd());
      await tester.pumpAndSettle();
      registro.mirar('asentado');
      expect(registro.cupo && registro.cruzo, isTrue,
          reason: 'empieza sin caber y vuelve a caber');
      registro.comprobar();
      expect(tester.takeException(), isNull);
    }, variant: _windows);

    testWidgets(
        'el pellizco de la Web (PointerScaleEvent de 1.01), del 100 % a no '
        'caber', (tester) async {
      final scope = await t117Pump(tester, tamano: _ventana);
      final foco = tester.getCenter(_celda);
      final registro = _Registro(tester, scope, _celda, foco);
      final raton = TestPointer(1, PointerDeviceKind.mouse)..hover(foco);
      for (var paso = 1; paso <= 60; paso++) {
        await _paso(tester, registro, 'paso $paso',
            () => tester.sendEventToBinding(raton.scale(1.01)));
      }
      await tester.pumpAndSettle();
      registro.mirar('asentado');
      expect(registro.cupo && registro.cruzo, isTrue);
      registro.comprobar();
      expect(tester.takeException(), isNull);
    }, variant: _windows);

    testWidgets(
        'el pellizco de la Web en ráfagas: tres pasos dentro de un mismo '
        'cuadro', (tester) async {
      final scope = await t117Pump(tester, tamano: _ventana);
      final foco = tester.getCenter(_celda);
      final registro = _Registro(tester, scope, _celda, foco);
      final raton = TestPointer(1, PointerDeviceKind.mouse)..hover(foco);
      for (var paso = 1; paso <= 30; paso++) {
        await _paso(tester, registro, 'ráfaga $paso', () async {
          for (var i = 0; i < 3; i++) {
            await tester.sendEventToBinding(raton.scale(1.005));
          }
        });
      }
      await tester.pumpAndSettle();
      registro.mirar('asentado');
      expect(registro.cupo && registro.cruzo, isTrue);
      registro.comprobar();
      expect(tester.takeException(), isNull);
    }, variant: _windows);
  });

  group('O-128-4 · el plano suelta el pellizco al perder el foco', () {
    testWidgets(
        'un pellizco del touchpad sin su final: al pasar a inactive, la '
        'columna se suelta y la rueda vuelve a moverla', (tester) async {
      final scope = await t117Pump(tester, tamano: _ventana);
      final foco = tester.getCenter(_celda);
      final touchpad = TestPointer(2, PointerDeviceKind.trackpad);
      await tester.sendEventToBinding(touchpad.panZoomStart(foco));
      await tester.sendEventToBinding(
          touchpad.panZoomUpdate(foco, scale: 1.2));
      await tester.pump();
      expect(scope.read(pellizcoDelPlanoProvider), isTrue,
          reason: 'el pellizco empezó: la columna queda congelada');
      expect(_zoom(scope), closeTo(1.2, 1e-9));

      // Alt + Tab: en Windows, perder el foco de la ventana es inactive. El
      // final del gesto no llega nunca.
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(scope.read(pellizcoDelPlanoProvider), isFalse,
          reason: 'al perder el foco, la columna se suelta');
      expect(_zoom(scope), closeTo(1.2, 1e-9),
          reason: 'la escala se queda donde quedó');

      final columna = _columna(tester);
      final antes = columna.pixels;
      final raton = TestPointer(1, PointerDeviceKind.mouse)..hover(foco);
      await tester.sendEventToBinding(raton.scroll(const Offset(0, 100)));
      await tester.pumpAndSettle();
      expect(columna.pixels, greaterThan(antes),
          reason: 'la rueda vuelve a mover la columna');
      expect(_zoom(scope), closeTo(1.2, 1e-9),
          reason: 'y ya no es parte del pellizco viejo');
      expect(tester.takeException(), isNull);
    }, variant: _windows);

    testWidgets(
        'dos contactos sin levantar: al pasar a inactive se olvidan, y un '
        'dedo vuelve a desplazar la rejilla', (tester) async {
      final scope = await t117Pump(tester, tamano: _ventana);
      scope.read(planZoomProvider.notifier).fijar(2);
      await tester.pumpAndSettle();
      final rejilla = _rejilla(tester, _celda);
      expect(rejilla.maxScrollExtent, greaterThan(100));
      final centro = tester.getCenter(_celda);
      final uno = TestPointer(11, PointerDeviceKind.touch);
      final dos = TestPointer(12, PointerDeviceKind.touch);
      await tester.sendEventToBinding(uno.down(centro));
      await tester.sendEventToBinding(dos.down(centro + const Offset(80, 0)));
      await tester.pump();
      ScrollPhysics fisica() =>
          tester.widget<Scrollable>(find.ancestor(
              of: _celda, matching: find.byType(Scrollable)).first)
              .physics!;
      expect(fisica(), isA<NeverScrollableScrollPhysics>(),
          reason: 'con dos contactos, la rejilla no se desplaza');

      // Los dos `up` nunca llegan: la ventana pierde el foco.
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(
          tester.widget<Scrollable>(find.ancestor(
              of: _celda, matching: find.byType(Scrollable)).first)
              .physics,
          isNot(isA<NeverScrollableScrollPhysics>()),
          reason: 'los contactos viejos se olvidan');

      // Corrección 1 de la entrega 2 (10.170): que un dedo la desplace de
      // verdad. El arrastre va en varios pasos: con uno solo no pasa el
      // umbral del gesto y nada se mueve.
      final antes = rejilla.pixels;
      final dedo = TestPointer(13, PointerDeviceKind.touch);
      await tester.sendEventToBinding(dedo.down(centro));
      await tester.pump();
      for (var i = 1; i <= 6; i++) {
        await tester.sendEventToBinding(
            dedo.move(centro - Offset(15.0 * i, 0)));
        await tester.pump(_cuadro);
      }
      await tester.sendEventToBinding(dedo.up());
      await tester.pumpAndSettle();
      final movida = _rejilla(tester, _celda).pixels - antes;
      debugPrint('un dedo, 90 dp a la izquierda: la rejilla se movió '
          '${movida.toStringAsFixed(1)} dp');
      expect(movida, greaterThan(30),
          reason: 'un dedo vuelve a desplazar la rejilla');
      expect(tester.takeException(), isNull);
    }, variant: _windows);

    testWidgets(
        'un gesto del touchpad nuevo, con el viejo abierto, lo cierra al '
        'empezar; desde el gesto siguiente, dos dedos mueven la columna',
        (tester) async {
      // Es el respaldo si el ciclo de vida no avisa. El gesto que cierra al
      // viejo no desplaza: la columna lo repartió cuando aún estaba
      // congelada, sin su reconocedor de arrastre.
      final scope = await t117Pump(tester, tamano: _ventana);
      final foco = tester.getCenter(_celda);
      final viejo = TestPointer(2, PointerDeviceKind.trackpad);
      await tester.sendEventToBinding(viejo.panZoomStart(foco));
      await tester.sendEventToBinding(viejo.panZoomUpdate(foco, scale: 1.2));
      await tester.pump();
      expect(scope.read(pellizcoDelPlanoProvider), isTrue);

      // Sin `panZoomEnd` del viejo, empieza otro gesto.
      final nuevo = TestPointer(3, PointerDeviceKind.trackpad);
      await tester.sendEventToBinding(nuevo.panZoomStart(foco));
      await tester.pump();
      expect(scope.read(pellizcoDelPlanoProvider), isFalse,
          reason: 'el gesto nuevo cierra el viejo');
      await tester.sendEventToBinding(nuevo.panZoomEnd());
      await tester.pumpAndSettle();

      final columna = _columna(tester);
      final antes = columna.pixels;
      final otro = TestPointer(4, PointerDeviceKind.trackpad);
      await tester.sendEventToBinding(otro.panZoomStart(foco));
      for (var i = 1; i <= 4; i++) {
        await tester.sendEventToBinding(
            otro.panZoomUpdate(foco, pan: Offset(0, -20.0 * i)));
        await tester.pump();
      }
      await tester.sendEventToBinding(otro.panZoomEnd());
      await tester.pumpAndSettle();
      expect(columna.pixels, greaterThan(antes),
          reason: 'dos dedos sin pellizcar desplazan la columna');
      expect(_zoom(scope), closeTo(1.2, 1e-9));
      expect(tester.takeException(), isNull);
    }, variant: _windows);

    // Corrección 2 de la entrega 2 · T120-E2-02 (10.172): después de dos
    // contactos sin levantar y de perder el foco, un pellizco del touchpad no
    // amplía. GLM lo midió con un paso; aquí, para descartar el instrumento,
    // con varios pasos, con tiempo entre el ciclo y el gesto, y con un segundo
    // gesto después del primero. Con uno y con dos contactos, y con el ciclo
    // corto (inactive y de vuelta) y el entero (hasta paused y de vuelta).
    //
    // Con un contacto, amplía: es lo que se quiere, y lo arregló la
    // corrección 1. Con dos, no: es un DEFECTO CONOCIDO, que Carlos dejó como
    // observación (no se corrige aquí; `docs/T120-RESULTADOS.md`, corrección 2
    // de la entrega 2, C). La causa: al 100 % la rejilla no se desplaza, así
    // que el primer contacto hace ganar al arrastre de la columna, sin rival
    // en la arena, y la columna tapa el plano con su `IgnorePointer` mientras
    // arrastra. El segundo contacto nunca llega al plano; al perder el foco,
    // el plano cancela solo el que conoce, y la columna se queda arrastrando
    // con el otro, tapando el plano: el touchpad ya no llega. Estas pruebas
    // fijan ese defecto, con su nombre: cuando se arregle, cambian.
    for (final contactos in [1, 2]) {
      for (final (ciclo, estados) in [
        ('corto', [AppLifecycleState.inactive, AppLifecycleState.resumed]),
        (
          'entero',
          [
            AppLifecycleState.inactive,
            AppLifecycleState.hidden,
            AppLifecycleState.paused,
            AppLifecycleState.hidden,
            AppLifecycleState.inactive,
            AppLifecycleState.resumed,
          ]
        ),
      ]) {
        final defecto = contactos == 2;
        testWidgets(
            defecto
                ? 'T120-E2-02 (DEFECTO CONOCIDO, sin corregir) · 2 contactos sin '
                    'levantar y el ciclo $ciclo: después, el pellizco del '
                    'touchpad NO amplía, ni en varios pasos ni en un segundo '
                    'gesto'
                : 'T120-E2-02 · 1 contacto sin levantar y el ciclo $ciclo: '
                    'después, el pellizco del touchpad amplía, en varios '
                    'pasos, y un segundo gesto también',
            (tester) async {
          final scope = await t117Pump(tester, tamano: _ventana);
          final foco = tester.getCenter(_celda);
          for (var i = 0; i < contactos; i++) {
            await tester.sendEventToBinding(TestPointer(11 + i)
                .down(foco + Offset(80.0 * i, 0)));
          }
          await tester.pump();
          for (final estado in estados) {
            tester.binding.handleAppLifecycleStateChanged(estado);
            await tester.pump();
          }
          // Tiempo entre el ciclo y el gesto.
          await tester.pump(const Duration(milliseconds: 500));
          await tester.pumpAndSettle();
          expect(_zoom(scope), closeTo(1, 1e-9));

          final primero = TestPointer(2, PointerDeviceKind.trackpad);
          await tester.sendEventToBinding(primero.panZoomStart(foco));
          await tester.pump(_cuadro);
          final pasos = <String>[];
          for (final escala in [1.05, 1.1, 1.15, 1.2]) {
            await tester.sendEventToBinding(
                primero.panZoomUpdate(foco, scale: escala));
            await tester.pump(_cuadro);
            pasos.add('${escala.toStringAsFixed(2)}→'
                '${_zoom(scope).toStringAsFixed(3)}'
                '${scope.read(pellizcoDelPlanoProvider) ? '' : ' (sin pellizco)'}');
          }
          await tester.sendEventToBinding(primero.panZoomEnd());
          await tester.pumpAndSettle();
          final trasElPrimero = _zoom(scope);

          final segundo = TestPointer(3, PointerDeviceKind.trackpad);
          await tester.sendEventToBinding(segundo.panZoomStart(foco));
          await tester.pump(_cuadro);
          for (final escala in [0.95, 0.9]) {
            await tester.sendEventToBinding(
                segundo.panZoomUpdate(foco, scale: escala));
            await tester.pump(_cuadro);
          }
          final pellizcandoElSegundo = scope.read(pellizcoDelPlanoProvider);
          await tester.sendEventToBinding(segundo.panZoomEnd());
          await tester.pumpAndSettle();
          debugPrint('T120-E2-02 $contactos contacto(s), ciclo $ciclo · '
              'primer gesto: ${pasos.join(', ')}; tras él '
              '${trasElPrimero.toStringAsFixed(3)}; segundo gesto (×0.9): '
              '${_zoom(scope).toStringAsFixed(3)}, pellizcando='
              '$pellizcandoElSegundo');
          if (defecto) {
            expect(trasElPrimero, closeTo(1, 1e-9),
                reason: 'defecto conocido: el primer pellizco no amplía');
            expect(_zoom(scope), closeTo(1, 1e-9),
                reason: 'defecto conocido: el segundo tampoco');
          } else {
            expect(trasElPrimero, closeTo(1.2, 1e-9),
                reason: 'el primer pellizco amplía');
            expect(_zoom(scope), closeTo(1.2 * 0.9, 1e-9),
                reason: 'el segundo también');
          }
          expect(scope.read(pellizcoDelPlanoProvider), isFalse);
          expect(tester.takeException(), isNull);
        }, variant: _windows);
      }
    }
  });

  // Corrección 2 de la entrega 2 · O-120-8 (nueva; la causa es la de
  // T120-E2-02): al 100 %, en la oficina, el pellizco de dos dedos en una
  // pantalla táctil no amplía si el primer dedo cae donde solo se desplaza la
  // columna, como una celda vacía. El plano no ve el segundo dedo: la columna
  // ya está arrastrando y lo tapa. Con la escala en 2 la rejilla también se
  // desplaza, el arrastre de la columna no gana solo y el plano ve los dos.
  // En el teléfono, el `Listener` del plano envuelve los desplazables de la
  // rejilla y ninguno lo tapa: amplía.
  group('O-120-8 · el pellizco de dos dedos que empieza en una celda vacía', () {
    /// Dos dedos a 40 dp sobre la celda vacía, que se separan hasta 160 dp
    /// (×4), en seis cuadros. Devuelve la escala con los dos todavía puestos.
    Future<double> separar(WidgetTester tester, ProviderContainer scope) async {
      final foco = tester.getCenter(_celda);
      final uno = TestPointer(11);
      final dos = TestPointer(12);
      await tester.sendEventToBinding(uno.down(foco));
      await tester.pump();
      await tester.sendEventToBinding(dos.down(foco + const Offset(40, 0)));
      await tester.pump();
      for (var i = 1; i <= 6; i++) {
        await tester.sendEventToBinding(uno.move(foco - Offset(10.0 * i, 0)));
        await tester
            .sendEventToBinding(dos.move(foco + Offset(40 + 10.0 * i, 0)));
        await tester.pump(_cuadro);
      }
      final escala = _zoom(scope);
      await tester.sendEventToBinding(uno.up());
      await tester.sendEventToBinding(dos.up());
      await tester.pumpAndSettle();
      return escala;
    }

    testWidgets(
        'O-120-8 (DEFECTO CONOCIDO, sin corregir) · en la oficina, al 100 %, '
        'dos dedos que empiezan en una celda vacía NO amplían', (tester) async {
      final scope = await t117Pump(tester, tamano: _ventana);
      final escala = await separar(tester, scope);
      debugPrint('O-120-8 oficina al 100 %: escala ${escala.toStringAsFixed(3)}');
      expect(escala, closeTo(1, 1e-9),
          reason: 'defecto conocido: el plano no ve el segundo dedo');
      expect(tester.takeException(), isNull);
    }, variant: _windows);

    testWidgets(
        'O-120-8 · en la oficina, con la escala en 2, los dos dedos amplían '
        '(hasta el tope)', (tester) async {
      final scope = await t117Pump(tester, tamano: _ventana);
      scope.read(planZoomProvider.notifier).fijar(2);
      await tester.pumpAndSettle();
      final escala = await separar(tester, scope);
      debugPrint('O-120-8 oficina a 2: escala ${escala.toStringAsFixed(3)}');
      expect(escala, greaterThan(2.5));
      expect(tester.takeException(), isNull);
    }, variant: _windows);

    for (final tamano in [const Size(360, 800), const Size(412, 915)]) {
      testWidgets(
          'O-120-8 · en el teléfono (${tamano.width.toInt()} × '
          '${tamano.height.toInt()}), al 100 %, dos dedos que empiezan en una '
          'celda vacía amplían', (tester) async {
        final scope = await t117Pump(tester, tamano: tamano);
        final escala = await separar(tester, scope);
        debugPrint('O-120-8 teléfono ${tamano.width.toInt()} al 100 %: '
            'escala ${escala.toStringAsFixed(3)}');
        expect(escala, greaterThan(2.5));
        expect(tester.takeException(), isNull);
      }, variant: TargetPlatformVariant.only(TargetPlatform.android));
    }
  });
}
