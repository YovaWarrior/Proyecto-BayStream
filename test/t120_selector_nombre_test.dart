// T-120, entrega 2 · O2 (`docs/T120-RESULTADOS.md` 1.6.1; C2.9 de la
// aceptación de T-117 y T-118): en segmentos, cada segmento de
// `BsSelectorDeModo` llevaba la descripción emergente en la semántica, y
// Windows le suma al nombre esa descripción, que empieza por el mismo nombre:
// «botón Destino. Destino. El puerto de descarga…».
//
// Ahora cada segmento dice su nombre una sola vez, el entero y con su cuenta
// entera («Descarga, 28 por bajar en GTSTC»), la ayuda va como pista y la
// descripción emergente sigue al pasar el mouse, fuera de la semántica, como
// «Acciones» (10.45). En Windows el motor no expone la pista (ni UIA ni
// MSAA, medido en el banco): ahí la ayuda queda en la descripción emergente.
// Con las fuentes del producto. Buque y números sintéticos (BUQUE MANUAL,
// TSTU).
import 'dart:ui' show CheckedState;

import 'package:baystream/core/design/design.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t117_oficina_support.dart';

const _entradas = <BsEntradaDeModo<String>>[
  BsEntradaDeModo<String>(
    valor: 'contenido',
    rotulo: 'Contenido',
    icono: BsIconos.contenedor40,
    ayuda: 'El destino de cada contenedor',
  ),
  BsEntradaDeModo<String>(
    valor: 'orden',
    rotulo: 'Número de orden',
    rotuloCorto: 'Orden',
    icono: BsIconos.orden,
    cuenta: '30 OR del listado',
  ),
  BsEntradaDeModo<String>(
    valor: 'descarga',
    rotulo: 'Descarga',
    icono: BsIconos.descarga,
    cuenta: '28 por bajar en GTSTC',
    cuentaCorta: '28',
    ayuda: 'Toca un contenedor para marcarlo como descargado',
  ),
  BsEntradaDeModo<String>(
    valor: 'carga',
    rotulo: 'Carga',
    icono: BsIconos.carga,
    cuenta: '29 pendientes: 20 llenos, 9 vacíos',
    cuentaCorta: '29',
  ),
];

/// El nombre y la pista que se esperan de cada segmento.
const _esperados = <(String, String, String?)>[
  ('Contenido', 'Contenido', 'El destino de cada contenedor'),
  ('Número de orden', 'Número de orden, 30 OR del listado', null),
  (
    'Descarga',
    'Descarga, 28 por bajar en GTSTC',
    'Toca un contenedor para marcarlo como descargado'
  ),
  ('Carga', 'Carga, 29 pendientes: 20 llenos, 9 vacíos', null),
];

Future<List<String>> _selector(WidgetTester tester, {bool oscuro = false}) async {
  await t117CargarFuentes();
  final elegidos = <String>[];
  await tester.pumpWidget(MaterialApp(
    theme: oscuro ? BayStreamTema.oscuro() : BayStreamTema.claro(),
    home: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 1000,
          child: StatefulBuilder(
            builder: (context, setState) => BsSelectorDeModo<String>(
              key: const ValueKey('selector'),
              entradas: _entradas,
              elegido: elegidos.isEmpty ? 'carga' : elegidos.last,
              forma: BsFormaDelSelector.segmentos,
              onElegir: (valor) => setState(() => elegidos.add(valor)),
            ),
          ),
        ),
      ),
    ),
  ));
  await tester.pumpAndSettle();
  return elegidos;
}

/// Los nodos de los segmentos: los botones del grupo que se elige.
List<SemanticsData> _segmentos(WidgetTester tester) {
  final nodos = <SemanticsData>[];
  void visitar(SemanticsNode nodo) {
    final datos = nodo.getSemanticsData();
    if (datos.flagsCollection.isButton &&
        datos.flagsCollection.isInMutuallyExclusiveGroup &&
        datos.hasAction(SemanticsAction.tap)) {
      nodos.add(datos);
    }
    nodo.visitChildren((hijo) {
      visitar(hijo);
      return true;
    });
  }

  visitar(tester.getSemantics(find.byType(SegmentedButton<String>)));
  return nodos;
}

void main() {
  group('O2 · cada segmento dice su nombre una vez', () {
    for (final oscuro in [false, true]) {
      testWidgets(
          'el nombre entero con su cuenta, sin la descripción emergente, y la '
          'ayuda como pista (${oscuro ? 'de noche' : 'de día'})',
          (tester) async {
        final semantica = tester.ensureSemantics();
        await _selector(tester, oscuro: oscuro);
        final nodos = _segmentos(tester);
        expect(nodos, hasLength(4), reason: '$nodos');
        for (var i = 0; i < 4; i++) {
          final (nombre, etiqueta, pista) = _esperados[i];
          final datos = nodos[i];
          expect(datos.label, etiqueta, reason: '$datos');
          expect(datos.tooltip, isEmpty,
              reason: 'Windows suma la descripción emergente al nombre');
          expect(datos.hint, pista ?? isEmpty);
          expect(
              RegExp(RegExp.escape(nombre))
                  .allMatches('${datos.label} ${datos.tooltip}'),
              hasLength(1),
              reason: '«$nombre» una sola vez en el nombre: $datos');
        }
        expect(nodos.last.flagsCollection.isChecked, CheckedState.isTrue,
            reason: 'Carga, la elegida');
        semantica.dispose();
      });
    }

    testWidgets(
        'la descripción emergente sigue al pasar el mouse, y el segmento se '
        'elige igual', (tester) async {
      final elegidos = await _selector(tester);
      final mensajes = tester
          .widgetList<Tooltip>(find.byType(Tooltip))
          .map((t) => t.message)
          .toSet();
      expect(mensajes, contains(_entradas[2].descripcion));
      expect(mensajes, contains(_entradas[1].descripcion));
      for (final t in tester.widgetList<Tooltip>(find.byType(Tooltip))) {
        expect(t.excludeFromSemantics, isTrue, reason: t.message);
      }
      await tester.tap(find.text('Descarga 28'));
      await tester.pumpAndSettle();
      expect(elegidos, ['descarga']);
    });

    testWidgets(
        'en la cabecera de la oficina (1920 dp), ningún segmento lleva la '
        'descripción emergente en la semántica', (tester) async {
      final semantica = tester.ensureSemantics();
      await t117Pump(tester, tamano: const Size(1920, 1000));
      final selectores = find.byWidgetPredicate((w) => w is SegmentedButton);
      expect(selectores, findsWidgets);
      var vistos = 0;
      for (final elemento in selectores.evaluate()) {
        void visitar(SemanticsNode nodo) {
          final datos = nodo.getSemanticsData();
          if (datos.flagsCollection.isButton) {
            vistos++;
            expect(datos.tooltip, isEmpty, reason: '$datos');
            final primera = datos.label.split(',').first;
            expect(RegExp(RegExp.escape(primera)).allMatches(datos.label),
                hasLength(1),
                reason: 'el nombre una sola vez: $datos');
          }
          nodo.visitChildren((hijo) {
            visitar(hijo);
            return true;
          });
        }

        visitar(tester.getSemantics(find.byWidget(elemento.widget)));
      }
      expect(vistos, greaterThanOrEqualTo(2));
      semantica.dispose();
    });
  });
}
