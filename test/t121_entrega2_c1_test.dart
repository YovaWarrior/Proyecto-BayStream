// T-121 · Entrega 2, corrección 1 (SPRINT-4.md 10.53; DESIGN.md 15.4):
//   - H1: con pocas bahías la silueta ocupa el ancho útil del panel; cada
//     bahía crece hasta su tope (tres veces la mínima) y, si aun así sobra
//     ancho, el casco va centrado; en pantalla ancha las zonas crecen hasta
//     1.5 veces su alto. Con 72 bahías, en el teléfono y con la letra a 2.0
//     cuando no caben, todo sigue como antes: 56 dp por la escala de la
//     letra, el alto base y el desplazamiento con su barra.
//   - O1: la muestra de la leyenda es una pila pequeña con sus separadores,
//     sin borde y más alta que ancha: no parece una casilla, y en el árbol
//     accesible sigue siendo texto.
// Con las fuentes del producto. Buque y números sintéticos; nunca el corpus.
import 'dart:ui' show CheckedState, Tristate;

import 'package:baystream/core/design/design.dart';
import 'package:baystream/features/vessel/presentation/widgets/voyage_stats_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t121_estadisticas_support.dart';

// T-124: nueve bahías de referencia. La forma del plano de llegada
// (`t121Bahias9`) son tres con la regla de la par: `t124_par_test.dart`.
final _nueve = t121ViajeCorto(t121Bahias9Sueltas);
// Setenta y dos bahías de referencia: el 977 son 24 y a 1920 caben.
final _setentaYDos = t121ViajeCorto(t121Bahias72Sueltas, cuantos: 216);
// Tres bahías impares: una de 40 en una par trae a sus dos vecinas.
const _bahiasTres = <int>[1, 5, 9];
final _tres = t121ViajeCorto(_bahiasTres, cuantos: 30);

final _vista = find.byKey(const ValueKey<String>('buque-en-corte-scroll'));
final _panel =
    find.byKey(const ValueKey<String>('estadisticas-carga-por-bahia'));

Finder _bahia(int numero) =>
    find.byKey(ValueKey<String>('buque-en-corte-bahia-$numero'));

/// El borde izquierdo de la primera bahía y el derecho de la última.
({double izquierda, double derecha}) _tramo(
        WidgetTester tester, List<int> bahias) =>
    (
      izquierda: tester.getRect(_bahia(bahias.first)).left,
      derecha: tester.getRect(_bahia(bahias.last)).right,
    );

/// El margen de proa y popa con la letra a [letra]: lo que mida «Popa» más 8,
/// y nunca menos de 28 (15.4). Con la letra a 2.0 no pasa de 70.
double _margenMaximo(double letra) => letra == 1.0 ? 40 : 80;

void main() {
  group('H1 · la silueta ocupa el ancho útil del panel (10.53)', () {
    for (final oscuro in <bool>[false, true]) {
      final tema = oscuro ? 'noche' : 'día';
      testWidgets(
          'nueve bahías a 1920 ($tema): llenan el panel, en Contenedores y en Peso',
          (tester) async {
        await t121Pump(tester,
            voyage: _nueve, tamano: const Size(1920, 1080), oscuro: oscuro);
        final vista = tester.getRect(_vista);
        final panel = tester.getRect(_panel);
        expect(vista.width, greaterThan(panel.width * 0.9),
            reason: 'la vista del buque es el ancho útil del panel');
        expect(t121Buque(tester).position.maxScrollExtent, 0,
            reason: 'nueve bahías caben: no hay nada que desplazar');
        for (final magnitud in <String>['Contenedores', 'Peso']) {
          await tester.tap(find.text(magnitud));
          await tester.pumpAndSettle();
          final tramo = _tramo(tester, t121Bahias9Sueltas);
          expect(
              tramo.izquierda - vista.left, lessThanOrEqualTo(_margenMaximo(1)),
              reason: '$magnitud: la proa al borde del panel, no un vacío');
          expect(
              vista.right - tramo.derecha, lessThanOrEqualTo(_margenMaximo(1)),
              reason:
                  '$magnitud: la popa al borde del panel, no un vacío a la derecha');
          expect(
              tramo.derecha - tramo.izquierda, greaterThan(vista.width * 0.9),
              reason: '$magnitud: las bahías ocupan el ancho útil');
        }
        // Todas las bahías miden lo mismo, más que la mínima y no más que su
        // tope.
        final anchos = <double>{
          for (final b in t121Bahias9Sueltas)
            (tester.getRect(_bahia(b)).width * 100).round() / 100,
        };
        expect(anchos, hasLength(1));
        expect(anchos.single, greaterThan(BsBuqueEnCorte.anchoBahiaBase));
        expect(
            anchos.single,
            lessThanOrEqualTo(
                BsBuqueEnCorte.topeDeLaBahia * BsBuqueEnCorte.anchoBahiaBase));
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('a 1366 × 768 las nueve bahías también llenan el panel',
        (tester) async {
      await t121Pump(tester, voyage: _nueve, tamano: const Size(1366, 768));
      final vista = tester.getRect(_vista);
      final tramo = _tramo(tester, t121Bahias9Sueltas);
      expect(t121Buque(tester).position.maxScrollExtent, 0);
      expect(tramo.derecha - tramo.izquierda, greaterThan(vista.width * 0.9));
      expect(tester.takeException(), isNull);
    });

    testWidgets('con la letra a 2.0 a 1920, llenan el panel y nada se corta',
        (tester) async {
      await t121Pump(tester,
          voyage: _nueve, tamano: const Size(1920, 1080), letra: 2.0);
      final vista = tester.getRect(_vista);
      final tramo = _tramo(tester, t121Bahias9Sueltas);
      expect(t121Buque(tester).position.maxScrollExtent, 0);
      expect(tramo.izquierda - vista.left, lessThanOrEqualTo(_margenMaximo(2)));
      expect(vista.right - tramo.derecha, lessThanOrEqualTo(_margenMaximo(2)));
      expect(
          tester.getRect(_bahia(2)).width,
          greaterThanOrEqualTo(
              BsBuqueEnCorte.anchoBahia(const TextScaler.linear(2.0))));
      t121NadaSeCorta(tester, find.byType(VoyageStatsView));
      expect(tester.takeException(), isNull);
    });

    testWidgets('tres bahías: cada una en su tope y el casco centrado',
        (tester) async {
      await t121Pump(tester, voyage: _tres, tamano: const Size(1920, 1080));
      final vista = tester.getRect(_vista);
      final tramo = _tramo(tester, _bahiasTres);
      for (final b in _bahiasTres) {
        expect(tester.getRect(_bahia(b)).width,
            BsBuqueEnCorte.topeDeLaBahia * BsBuqueEnCorte.anchoBahiaBase);
      }
      final aLaIzquierda = tramo.izquierda - vista.left;
      final aLaDerecha = vista.right - tramo.derecha;
      expect(aLaIzquierda, greaterThan(_margenMaximo(1)),
          reason: 'sobra ancho');
      expect((aLaIzquierda - aLaDerecha).abs(), lessThanOrEqualTo(1),
          reason: 'el casco va centrado');
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'en pantalla ancha las zonas crecen 1.5 veces; con 72 bahías y en el '
        'teléfono, el alto base', (tester) async {
      // El alto de la columna de una bahía: el dibujo más el pie.
      await t121Pump(tester,
          voyage: _setentaYDos, tamano: const Size(1920, 1080));
      final base = tester.getRect(_bahia(2)).height;
      expect(tester.getRect(_bahia(2)).width, BsBuqueEnCorte.anchoBahiaBase,
          reason: '72 bahías no caben: 56 dp, como antes');
      expect(t121Buque(tester).position.maxScrollExtent, greaterThan(0));
      t121BarraVisible(tester);

      await t121Pump(tester, voyage: _nueve, tamano: const Size(1920, 1080));
      expect(
          tester.getRect(_bahia(2)).height,
          base +
              2 *
                  BsBuqueEnCorte.altoDeZona *
                  (BsBuqueEnCorte.crecimientoDelAlto - 1),
          reason: 'las dos zonas, 72 → 108');

      await t121Pump(tester, voyage: _nueve, tamano: const Size(360, 800));
      expect(tester.getRect(_bahia(2)).height, base,
          reason: 'en el teléfono la página no cambia');
      expect(tester.getRect(_bahia(2)).width, BsBuqueEnCorte.anchoBahiaBase);
      expect(t121Buque(tester).position.maxScrollExtent, greaterThan(0),
          reason: 'a 360 las nueve bahías se desplazan, como antes');
      t121BarraVisible(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        '72 bahías a 1920: se desplazan como antes y la popa se alcanza',
        (tester) async {
      final tocadas = <int>[];
      await t121Pump(tester,
          voyage: _setentaYDos,
          tamano: const Size(1920, 1080),
          onBahia: tocadas.add);
      final posicion = t121Buque(tester).position;
      expect(posicion.maxScrollExtent, greaterThan(0));
      posicion.jumpTo(posicion.maxScrollExtent);
      await tester.pumpAndSettle();
      final ultima = _bahia(286);
      expect(tester.getRect(ultima).right,
          lessThanOrEqualTo(tester.getRect(_vista).right + 0.5));
      await tester.tap(ultima);
      expect(tocadas, <int>[286]);
      expect(tester.takeException(), isNull);
    });

    test('la regla del reparto', () {
      // Caben: crecen hasta llenar, con su tope.
      final nueve = BsBuqueEnCorte.repartir(
          bahias: 9, anchoMinimo: 56, margen: 30, disponible: 1380);
      expect(nueve.ancho, closeTo((1380 - 60) / 9, 0.001));
      expect(nueve.altoDeZona, 108);
      final una = BsBuqueEnCorte.repartir(
          bahias: 1, anchoMinimo: 56, margen: 30, disponible: 1380);
      expect(una.ancho, 168);
      // No caben: la mínima y el alto base.
      final muchas = BsBuqueEnCorte.repartir(
          bahias: 72, anchoMinimo: 56, margen: 30, disponible: 1380);
      expect(muchas.ancho, 56);
      expect(muchas.altoDeZona, 72);
      // En el teléfono crece el ancho si caben, nunca el alto.
      final telefono = BsBuqueEnCorte.repartir(
          bahias: 3, anchoMinimo: 56, margen: 30, disponible: 320);
      expect(telefono.ancho, closeTo((320 - 60) / 3, 0.001));
      expect(telefono.altoDeZona, 72);
      // Sin ancho acotado (una vista previa): como antes.
      final suelta = BsBuqueEnCorte.repartir(
          bahias: 3, anchoMinimo: 56, margen: 30, disponible: double.infinity);
      expect(suelta.ancho, 56);
      expect(suelta.altoDeZona, 72);
      // El alto crece con la proporción, hasta 1.5.
      final poco = BsBuqueEnCorte.repartir(
          bahias: 10, anchoMinimo: 56, margen: 30, disponible: 10 * 70 + 60);
      expect(poco.ancho, closeTo(70, 0.001));
      expect(poco.altoDeZona, closeTo(72 * 70 / 56, 0.001));
    });
  });

  group('O1 · la muestra de la leyenda no parece una casilla (10.53)', () {
    for (final oscuro in <bool>[false, true]) {
      final tema = oscuro ? 'noche' : 'día';
      testWidgets('una pila pequeña con sus separadores, sin borde ($tema)',
          (tester) async {
        final semantica = tester.ensureSemantics();
        await t121Pump(tester,
            voyage: _nueve, tamano: const Size(1920, 1080), oscuro: oscuro);
        final contexto = tester.element(_panel);
        final semanticos = BsColoresSemanticos.de(contexto);
        for (final (zona, rol) in <(String, BsRol)>[
          ('cubierta', semanticos.porBajarCubierta),
          ('bodega', semanticos.porBajarBodega),
        ]) {
          final muestra =
              find.byKey(ValueKey<String>('estadisticas-muestra-$zona'));
          expect(muestra, findsOneWidget, reason: 'la muestra de $zona');
          final bloques = tester
              .widgetList<DecoratedBox>(find.descendant(
                  of: muestra, matching: find.byType(DecoratedBox)))
              .map((d) => d.decoration as BoxDecoration)
              .toList();
          expect(bloques, hasLength(3),
              reason: '$zona: tres niveles de una pila');
          for (final bloque in bloques) {
            expect(bloque.border, isNull,
                reason: '$zona: sin borde de casilla');
            expect(bloque.color, rol.relleno,
                reason: '$zona: el color de su pila');
          }
          // Los niveles van separados: el hueco deja ver la hoja.
          final rects = <Rect>[
            for (final e in find
                .descendant(of: muestra, matching: find.byType(DecoratedBox))
                .evaluate())
              (e.renderObject! as RenderBox).localToGlobal(Offset.zero) &
                  (e.renderObject! as RenderBox).size,
          ]..sort((a, b) => a.top.compareTo(b.top));
          final pila = rects.reduce((a, b) => a.expandToInclude(b));
          expect(pila.height, greaterThanOrEqualTo(pila.width * 1.5),
              reason: '$zona: alargada, no cuadrada como una casilla');
          for (var i = 1; i < rects.length; i++) {
            expect(rects[i].top - rects[i - 1].bottom, greaterThanOrEqualTo(1),
                reason: '$zona: el separador entre niveles');
          }
        }
        // En el árbol accesible son texto, no controles.
        for (final rotulo in <String>['Cubierta', 'Bodega']) {
          final nodo = tester.getSemantics(find.bySemanticsLabel(rotulo));
          expect(nodo.flagsCollection.isButton, isFalse, reason: rotulo);
          expect(nodo.flagsCollection.isChecked, CheckedState.none,
              reason: rotulo);
          expect(nodo.flagsCollection.isToggled, Tristate.none, reason: rotulo);
          expect(nodo.flagsCollection.isFocused, Tristate.none,
              reason: '$rotulo: no toma el foco');
        }
        semantica.dispose();
        expect(tester.takeException(), isNull);
      });
    }
  });
}
