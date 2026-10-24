// T-114 · La travesía del inicio (SPRINT-4.md 10.24; DESIGN.md 13.11, regla
// 7): el buque de `sin_conexion` cruza una banda de mar al pie del inicio. Se
// comprueban la regla (la duración, la opacidad, la geometría), lo que se para
// (la reducción de movimiento, otra ruta encima, el segundo plano), que el
// buque se pinta una sola vez, que la banda ocupa solo lo que sobra sin
// empujar ni tapar nada, que las pautas siguen igual y que es decorativa.

import 'package:baystream/core/design/design.dart';
import 'package:baystream/features/vessel/data/repositories/local_only_operation_sync.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/inicio_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t91_toolbar_support.dart';

/// Una banda sola, de [ancho] × [alto], con o sin reducción de movimiento.
Widget _banda({double ancho = 800, double alto = 240, bool reducido = false}) =>
    MaterialApp(
      theme: BayStreamTema.claro(muelle: true),
      home: Builder(
        builder: (BuildContext context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: reducido),
          child: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: ancho,
                height: alto,
                child: const BsTravesia(key: ValueKey('travesia')),
              ),
            ),
          ),
        ),
      ),
    );

/// El inicio entero, sin nube ni almacén real, con la letra que se pida.
Widget _inicio() => ProviderScope(
      overrides: [
        recentVoyagesProvider.overrideWith((ref) async => <VesselVoyage>[]),
        savedVesselProfilesProvider
            .overrideWith((ref) async => <VesselProfile>[]),
        localVesselRepositoryProvider
            .overrideWith((ref) async => T91MemorySettings()),
        sessionRepositoryProvider
            .overrideWith((ref) async => const LocalSessionRepository()),
      ],
      child: MaterialApp(
        theme: BayStreamTema.claro(muelle: true),
        home: Scaffold(
          body: InicioView(onPickFile: () {}, onOpenRecent: (_) {}),
        ),
      ),
    );

/// Monta [widget] y deja pasar un cuadro más: el ticker arranca al final del
/// primero y da su primer tic en el segundo, con el tiempo en cero. Lo que se
/// mida después cuenta desde ahí. No se usa `pumpAndSettle`: la travesía no se
/// asienta nunca.
Future<void> _arrancar(WidgetTester tester, Widget widget) async {
  await tester.pumpWidget(widget);
  await tester.pump();
  await tester.pump();
}

final _travesia = find.byType(BsTravesia);
final _buque = find.descendant(of: _travesia, matching: find.byType(Opacity));

/// El dibujo del buque, dentro del Transform: dónde se ve, no la caja fija
/// (10.26, H1: la caja no cambia de sitio; lo que se mueve es el Transform).
final _dibujo =
    find.descendant(of: _buque, matching: find.byType(RepaintBoundary));
final _bandaDelInicio = find.byKey(const ValueKey('inicio-travesia'));

var _fuentesCargadas = false;

/// Las fuentes del producto (Plex y Roboto), para que las medidas del
/// teléfono sean las reales y no las de la fuente cuadrada de las pruebas.
Future<void> _cargarFuentes() async {
  if (_fuentesCargadas) return;
  _fuentesCargadas = true;
  const familias = <String, List<String>>{
    'IBM Plex Sans': [
      'assets/fonts/plex/IBMPlexSans-Regular.ttf',
      'assets/fonts/plex/IBMPlexSans-Medium.ttf',
      'assets/fonts/plex/IBMPlexSans-SemiBold.ttf',
    ],
    'IBM Plex Sans Condensed': [
      'assets/fonts/plex/IBMPlexSansCondensed-Medium.ttf',
      'assets/fonts/plex/IBMPlexSansCondensed-SemiBold.ttf',
    ],
    'IBM Plex Mono': [
      'assets/fonts/plex/IBMPlexMono-Regular.ttf',
      'assets/fonts/plex/IBMPlexMono-Medium.ttf',
    ],
    'Roboto': [
      'assets/fonts/Roboto-Regular.ttf',
      'assets/fonts/Roboto-Medium.ttf'
    ],
  };
  for (final entrada in familias.entries) {
    final cargador = FontLoader(entrada.key);
    for (final ruta in entrada.value) {
      cargador.addFont(rootBundle.load(ruta));
    }
    await cargador.load();
  }
}

Future<void> _pautas(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(textContrastGuideline));
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
}

void main() {
  group('La regla', () {
    test('el cruce dura el recorrido entre 48 dp/s, entre 14 y 40 s', () {
      expect(BsTravesia.duracionDelCruce(960), const Duration(seconds: 20));
      expect(BsTravesia.duracionDelCruce(100), BsTravesia.cruceMinimo);
      expect(BsTravesia.duracionDelCruce(48 * 14), BsTravesia.cruceMinimo);
      expect(BsTravesia.duracionDelCruce(48 * 40), BsTravesia.cruceMaximo);
      expect(BsTravesia.duracionDelCruce(10000), BsTravesia.cruceMaximo);
    });

    test('la opacidad sube en el primer 10 %, baja en el último 12 %', () {
      expect(BsTravesia.opacidadDelCruce(0), 0);
      expect(BsTravesia.opacidadDelCruce(0.05), closeTo(0.5, 1e-9));
      expect(BsTravesia.opacidadDelCruce(0.1), 1);
      expect(BsTravesia.opacidadDelCruce(0.5), 1);
      expect(BsTravesia.opacidadDelCruce(0.88), 1);
      expect(BsTravesia.opacidadDelCruce(0.94), closeTo(0.5, 1e-9));
      expect(BsTravesia.opacidadDelCruce(1), 0);
      expect(BsTravesia.opacidadDelCruce(1.2), 0);
      expect(BsTravesia.opacidadDelCruce(-0.1), 0);
    });

    test('la banda: el agua en el tercio de abajo, el buque entre 56 y 120',
        () {
      for (final alto in <double>[120, 150, 180, 240, 400, 900]) {
        final g = BsGeometriaDeTravesia(1280, alto);
        expect(g.alturaDelAgua, closeTo(alto / 3 < 32 ? 32 : alto / 3, 1e-9),
            reason: '$alto');
        expect(g.altoDelBuque, inInclusiveRange(56, 120), reason: '$alto');
        expect(g.altoDelBuque, (alto / 2).clamp(56, 120), reason: '$alto');
        // El buque entero cabe en la banda: lo de arriba, en el cielo.
        final arriba = g.lineaDeFlotacion - g.altoDelBuqueSobreElAgua;
        expect(arriba, greaterThanOrEqualTo(0), reason: '$alto');
        expect(arriba + g.altoDelBuque, lessThanOrEqualTo(alto),
            reason: '$alto');
        // Las dos olas, dentro del agua.
        for (final y in g.olas) {
          expect(y, greaterThan(g.lineaDeFlotacion), reason: '$alto');
          expect(y, lessThan(alto), reason: '$alto');
        }
        expect(g.recorrido, 1280 + g.anchoDelBuque);
        expect(g.duracion, BsTravesia.duracionDelCruce(g.recorrido));
        expect(g.ciclo, g.duracion + BsTravesia.pausa);
        // Quieto: el centro de su caja a un tercio del ancho.
        expect(g.quieto.x + g.anchoDelBuque / 2, closeTo(1280 / 3, 1e-9));
        expect(g.quieto.opacidad, 1);
      }
      // El agua nunca baja de 32 dp.
      expect(BsGeometriaDeTravesia(400, 90).alturaDelAgua, 32);
    });

    test('el instante: entra desde fuera, sale del todo y descansa 3 s', () {
      final g = BsGeometriaDeTravesia(800, 240);
      final d = g.duracion;
      expect(g.instante(Duration.zero).x, -g.anchoDelBuque);
      expect(g.instante(Duration.zero).opacidad, 0);
      final mitad = g.instante(d * 0.5);
      expect(mitad.x + g.anchoDelBuque / 2, closeTo(800 / 2, 1e-6));
      expect(mitad.opacidad, 1);
      expect(g.instante(d).x, -g.anchoDelBuque, reason: 'al terminar, fuera');
      expect(g.instante(d).opacidad, 0);
      expect(g.instante(d + const Duration(seconds: 1)).opacidad, 0,
          reason: 'mar vacío');
      expect(g.instante(g.ciclo + d * 0.5).opacidad, 1,
          reason: 'vuelve a empezar');
      // El vaivén y el cabeceo, acotados.
      for (var ms = 0; ms < 10000; ms += 97) {
        final i = g.instante(Duration(milliseconds: ms));
        expect(i.vaiven.abs(), lessThanOrEqualTo(BsTravesia.vaivenDp));
        expect(i.cabeceo.abs(),
            lessThanOrEqualTo(BsTravesia.cabeceoGrados * 3.14159265 / 180));
      }
      // Las olas corren hacia la izquierda y se repiten cada 48 dp.
      expect(
          BsGeometriaDeTravesia.corrimientoDeOla(
              const Duration(seconds: 1), BsTravesia.olaLenta),
          8);
      expect(
          BsGeometriaDeTravesia.corrimientoDeOla(
              const Duration(seconds: 1), BsTravesia.olaRapida),
          16);
      expect(
          BsGeometriaDeTravesia.corrimientoDeOla(
              const Duration(seconds: 6), BsTravesia.olaLenta),
          0);
    });
  });

  group('Lo que se para', () {
    testWidgets(
        'con reducción de movimiento no hay tickers activos y el buque no se mueve',
        (tester) async {
      await _arrancar(tester, _banda(reducido: true));
      expect(tester.binding.transientCallbackCount, 0);
      final antes = tester.getRect(_dibujo);
      expect(tester.widget<Opacity>(_buque).opacity, 1);
      // Quieto a un tercio del ancho.
      expect(antes.center.dx, closeTo(800 / 3, 0.01));
      await tester.pump(const Duration(seconds: 5));
      expect(tester.getRect(_dibujo), antes);
      expect(tester.binding.transientCallbackCount, 0);
      // Las olas tampoco corren, y el buque está donde dice `quieto`.
      final transformaciones = tester
          .widgetList<Transform>(
              find.descendant(of: _travesia, matching: find.byType(Transform)))
          .toList();
      expect(transformaciones, hasLength(3));
      for (final ola in transformaciones.take(2)) {
        expect(ola.transform.getTranslation().x, 0);
      }
      final g = BsGeometriaDeTravesia(800, 240);
      expect(transformaciones.last.transform, g.transformacion(g.quieto));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('con otra ruta encima no se programan cuadros', (tester) async {
      await _arrancar(tester, _banda());
      expect(tester.binding.transientCallbackCount, greaterThan(0),
          reason: 'a la vista, el ticker pide cuadros');
      final navegador = Navigator.of(tester.element(_travesia));
      navegador.push(MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: Text('Otra pantalla'))));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Otra pantalla'), findsOneWidget);
      expect(tester.binding.transientCallbackCount, 0,
          reason: 'tapada, no pide cuadros');
      navegador.pop();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(tester.binding.transientCallbackCount, greaterThan(0),
          reason: 'al volver, sigue');
    });

    testWidgets('en segundo plano se detiene y al volver sigue desde donde iba',
        (tester) async {
      final g = BsGeometriaDeTravesia(800, 240);
      await _arrancar(tester, _banda());
      await tester.pump(const Duration(seconds: 2));
      final antes = tester.getRect(_dibujo).left;
      addTearDown(() => tester.binding
          .handleAppLifecycleStateChanged(AppLifecycleState.resumed));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(tester.binding.transientCallbackCount, 0);
      await tester.pump(const Duration(seconds: 2));
      expect(tester.getRect(_dibujo).left, antes, reason: 'quieto detrás');
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(tester.binding.transientCallbackCount, greaterThan(0));
      expect(tester.getRect(_dibujo).left, closeTo(antes, 1e-6),
          reason: 'sigue desde donde iba');
      await tester.pump(const Duration(seconds: 1));
      final porSegundo = g.recorrido / (g.duracion.inMilliseconds / 1000);
      // Hasta 3 dp de más o de menos: el cabeceo gira el dibujo alrededor
      // del casco y corre su esquina un par de píxeles.
      expect(tester.getRect(_dibujo).left - antes, closeTo(porSegundo, 3));
      // Sin foco pero a la vista, sigue.
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      expect(tester.binding.transientCallbackCount, greaterThan(0));
    });

    testWidgets('con menos de 120 dp no se construye ni pide cuadros',
        (tester) async {
      await _arrancar(tester, _banda(alto: 119));
      expect(find.descendant(of: _travesia, matching: find.byType(CustomPaint)),
          findsNothing);
      expect(tester.binding.transientCallbackCount, 0);
      await _arrancar(tester, _banda(alto: 120));
      expect(find.descendant(of: _travesia, matching: find.byType(CustomPaint)),
          findsNWidgets(4),
          reason: 'el mar, las dos olas y el buque');
      expect(tester.binding.transientCallbackCount, greaterThan(0));
    });
  });

  group('El cruce', () {
    testWidgets('la opacidad es 0 al empezar y al terminar, y 1 a la mitad',
        (tester) async {
      final g = BsGeometriaDeTravesia(800, 240);
      await _arrancar(tester, _banda());
      expect(tester.widget<Opacity>(_buque).opacity, 0);
      expect(tester.getRect(_dibujo).right, closeTo(0, 1e-6),
          reason: 'empieza fuera, por la izquierda');
      await tester.pump(g.duracion * 0.05);
      expect(tester.widget<Opacity>(_buque).opacity, closeTo(0.5, 0.01));
      await tester.pump(g.duracion * 0.45);
      expect(tester.widget<Opacity>(_buque).opacity, 1);
      expect(tester.getRect(_dibujo).center.dx, closeTo(400, 2));
      await tester.pump(g.duracion * 0.44);
      expect(tester.widget<Opacity>(_buque).opacity, closeTo(0.5, 0.01));
      await tester.pump(g.duracion * 0.06);
      expect(tester.widget<Opacity>(_buque).opacity, 0);
      await tester.pump(const Duration(seconds: 1));
      expect(tester.widget<Opacity>(_buque).opacity, 0, reason: 'mar vacío');
      await tester.pump(
          BsTravesia.pausa + g.duracion * 0.5 - const Duration(seconds: 1));
      expect(tester.widget<Opacity>(_buque).opacity, 1,
          reason: 'vuelve a salir por la izquierda');
    });

    testWidgets('las olas corren hacia la izquierda, una al doble que la otra',
        (tester) async {
      await _arrancar(tester, _banda());
      await tester.pump(const Duration(seconds: 1));
      List<double> olas() => tester
          .widgetList<Transform>(
              find.descendant(of: _travesia, matching: find.byType(Transform)))
          .map((t) => t.transform.getTranslation().x)
          .toList()
          .sublist(0, 2);
      expect(olas(), [-8.0, -16.0]);
      await tester.pump(const Duration(seconds: 5));
      // A los 6 s la lenta dio una vuelta entera y la rápida, dos: la tira
      // vuelve a su sitio sin costura.
      expect(olas(), [0.0, 0.0]);
      await tester.pump(const Duration(milliseconds: 500));
      expect(olas(), [-4.0, -8.0]);
    });

    testWidgets('el buque se pinta una sola vez en 60 cuadros', (tester) async {
      BsTravesia.pintadasDelBuque = 0;
      await _arrancar(tester, _banda());
      // Hasta que aparece, no se pinta; desde ahí, una vez.
      await tester.pump(const Duration(seconds: 3));
      final desde = tester.getRect(_dibujo).left;
      for (var cuadro = 0; cuadro < 60; cuadro++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(tester.getRect(_dibujo).left, greaterThan(desde),
          reason: 'se movió durante los 60 cuadros');
      expect(BsTravesia.pintadasDelBuque, 1);
    });
  });

  group('Solo Transform y opacidad (10.26, H1)', () {
    testWidgets(
        'el cruce y el vaivén no cambian el layout del buque: la caja queda fija y lo mueve un Transform',
        (tester) async {
      final g = BsGeometriaDeTravesia(800, 240);
      BsTravesia.pintadasDelBuque = 0;
      await _arrancar(tester, _banda());
      await tester.pump(const Duration(seconds: 3));
      // La posición de layout: lo que el Stack le dio a la caja del buque.
      Offset colocacion() =>
          (tester.renderObject(_buque).parentData! as StackParentData).offset;
      Positioned caja() => tester.widget<Positioned>(
          find.ancestor(of: _buque, matching: find.byType(Positioned)).first);
      Size tamano() => tester.getSize(_buque);
      final dibujo =
          find.descendant(of: _buque, matching: find.byType(RepaintBoundary));
      final colocacion1 = colocacion();
      final caja1 = caja();
      final tamano1 = tamano();
      final pintado1 = tester.getTopLeft(dibujo);
      final pintadas = BsTravesia.pintadasDelBuque;
      await tester.pump(const Duration(seconds: 2));
      // Dos segundos después, el layout es el mismo: ni el sitio ni el tamaño.
      expect(colocacion(), colocacion1);
      expect(caja().left, caja1.left);
      expect(caja().top, caja1.top);
      expect(caja().left, 0, reason: 'la caja fija, al borde izquierdo');
      expect(tamano(), tamano1);
      // Y lo que se ve sí se movió: lo que toca en 2 s, por el Transform.
      final pintado2 = tester.getTopLeft(dibujo);
      final porSegundo = g.recorrido / (g.duracion.inMilliseconds / 1000);
      // Hasta 3 dp de más o de menos por el cabeceo, que gira la esquina.
      expect(pintado2.dx - pintado1.dx, closeTo(2 * porSegundo, 3));
      // En vertical, el vaivén y lo que el cabeceo corre la esquina.
      expect((pintado2.dy - pintado1.dy).abs(),
          lessThanOrEqualTo(2 * BsTravesia.vaivenDp + 5));
      expect(find.descendant(of: _buque, matching: find.byType(Transform)),
          findsOneWidget,
          reason: 'un solo Transform mueve, cabecea y gira la caja');
      expect(BsTravesia.pintadasDelBuque, pintadas,
          reason: 'moverse no vuelve a pintar el buque');
    });
  });

  group('Al pie del inicio', () {
    testWidgets(
        'sin desbordes ni empujones a 360, 600, 1280 × 720 y 1920 × 1080 con la letra a 1.0, 1.45 y 2.0',
        (tester) async {
      await _cargarFuentes();
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      var conBanda = 0;
      for (final ventana in const [
        Size(360, 640),
        Size(600, 960),
        Size(1280, 720),
        Size(1920, 1080),
      ]) {
        tester.view.physicalSize = ventana;
        for (final letra in const [1.0, 1.45, 2.0]) {
          tester.platformDispatcher.textScaleFactorTestValue = letra;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          final caso = '$ventana, letra $letra';
          await tester.pumpWidget(const SizedBox());
          await _arrancar(tester, _inicio());
          expect(find.byType(CircularProgressIndicator), findsNothing,
              reason: caso);
          expect(tester.takeException(), isNull, reason: caso);
          final boton = find.text('Seleccionar archivo');
          final perfiles = find.byKey(const ValueKey('saved-profiles'));
          expect(boton, findsOneWidget, reason: caso);
          expect(perfiles, findsOneWidget, reason: caso);
          final desplazable =
              tester.state<ScrollableState>(find.byType(Scrollable)).position;
          // Lo que miden los dos bloques con su relleno, y lo que sobra.
          final bloques = tester
              .renderObject<RenderSliver>(find.byType(SliverPadding))
              .geometry!
              .scrollExtent;
          final libre = ventana.height - bloques;
          if (libre < BsTravesia.altoMinimo) {
            // No sobran 120 dp: la banda cede, y nada más cambia.
            expect(_bandaDelInicio, findsNothing,
                reason: '$caso: sobran ${libre.toStringAsFixed(1)} dp');
            continue;
          }
          conBanda++;
          expect(_bandaDelInicio, findsOneWidget,
              reason: '$caso: sobran ${libre.toStringAsFixed(1)} dp');
          final banda = tester.getRect(_bandaDelInicio);
          expect(banda.height, closeTo(libre, 0.01),
              reason: '$caso: la banda es lo que sobra');
          expect(banda.height, greaterThanOrEqualTo(BsTravesia.altoMinimo),
              reason: caso);
          expect(banda.width, ventana.width, reason: '$caso: a todo el ancho');
          expect(banda.bottom, closeTo(ventana.height, 0.01),
              reason: '$caso: al pie');
          expect(banda.top, greaterThanOrEqualTo(tester.getRect(boton).bottom),
              reason: '$caso: debajo del botón');
          expect(
              banda.top, greaterThanOrEqualTo(tester.getRect(perfiles).bottom),
              reason: '$caso: debajo de los bloques');
          expect(desplazable.maxScrollExtent, 0,
              reason: '$caso: la banda no empuja nada fuera de la ventana');
          expect(
              find.descendant(
                  of: _bandaDelInicio, matching: find.byType(CustomPaint)),
              findsNWidgets(4),
              reason: caso);
          await tester.pump(const Duration(seconds: 2));
          expect(tester.takeException(), isNull, reason: caso);
        }
      }
      expect(conBanda, greaterThan(0), reason: 'en el escritorio hay banda');
      expect(_bandaDelInicio, findsOneWidget,
          reason: 'a 1920 × 1080 con 2.0 también sobra sitio');
    });

    testWidgets('a 1280 × 720 hay banda y meetsGuideline sigue igual',
        (tester) async {
      await _cargarFuentes();
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1280, 720);
      addTearDown(tester.view.reset);
      final semantica = tester.ensureSemantics();
      await _arrancar(tester, _inicio());
      expect(_bandaDelInicio, findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
      await _pautas(tester);
      semantica.dispose();
    });

    testWidgets('es decorativa: sin semántica, sin foco y sin toque',
        (tester) async {
      final semantica = tester.ensureSemantics();
      // Los nodos que un lector recorrería, de arriba abajo.
      int nodos() => tester.semantics.simulatedAccessibilityTraversal().length;

      await _arrancar(tester, _banda(alto: 100));
      final sinBanda = nodos();
      await _arrancar(tester, _banda());
      await tester.pump(const Duration(seconds: 3));
      expect(nodos(), sinBanda, reason: 'la banda no añade ningún nodo');
      expect(
          find.descendant(
              of: _travesia, matching: find.byType(ExcludeSemantics)),
          findsOneWidget);
      expect(
          find.descendant(of: _travesia, matching: find.byType(IgnorePointer)),
          findsOneWidget);
      expect(find.descendant(of: _travesia, matching: find.byType(Focus)),
          findsNothing);
      // Con el buque a la vista, a la mitad del cruce, el toque sobre él y
      // sobre el agua no llega a nada de la banda: pasa de largo.
      final g = BsGeometriaDeTravesia(800, 240);
      await tester.pump(g.duracion * 0.5 - const Duration(seconds: 3));
      final banda = tester.renderObject(_travesia);
      bool dentroDeLaBanda(HitTestTarget objetivo) {
        RenderObject? r = objetivo is RenderObject ? objetivo : null;
        while (r != null) {
          if (identical(r, banda)) return true;
          r = r.parent;
        }
        return false;
      }

      for (final punto in [
        tester.getRect(_dibujo).center,
        Offset(400, g.lineaDeFlotacion + g.alturaDelAgua / 2),
      ]) {
        expect(tester.getRect(_travesia).contains(punto), isTrue,
            reason: '$punto está dentro de la banda');
        final toque = tester.hitTestOnBinding(punto);
        expect(toque.path.any((e) => dentroDeLaBanda(e.target)), isFalse,
            reason: 'el toque en $punto pasa de largo');
      }
      semantica.dispose();
    });
  });
}
