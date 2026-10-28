// T-118 · El selector de modo y su resumen (SPRINT-4.md 10.36 y 10.38;
// DESIGN.md 14.6, 14.7 y 14.11): un solo selector, `BsSelectorDeModo`, en
// segmentos o en menú según el ancho medido, con `BsPrimeraQueCabe`; el
// resumen del modo en fichas de una línea; y las tarjetas cortas del panel
// del buque. Con las fuentes del producto y en los dos temas.
// Buque y números sintéticos (BUQUE MANUAL, TSTU).
import 'package:baystream/core/design/design.dart';
import 'package:baystream/features/vessel/presentation/providers/plano_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/loading_plan_controls.dart';
import 'package:flutter/material.dart';
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

/// Un selector suelto en un ancho dado, con el tema de la oficina.
Future<List<String>> _selector(
  WidgetTester tester, {
  required double ancho,
  BsFormaDelSelector forma = BsFormaDelSelector.segunElAncho,
  bool oscuro = false,
}) async {
  await t117CargarFuentes();
  final elegidos = <String>[];
  await tester.pumpWidget(MaterialApp(
    theme: oscuro ? BayStreamTema.oscuro() : BayStreamTema.claro(),
    home: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: ancho,
          child: StatefulBuilder(
            builder: (context, setState) => BsSelectorDeModo<String>(
              key: const ValueKey('selector'),
              entradas: _entradas,
              elegido: elegidos.isEmpty ? 'carga' : elegidos.last,
              forma: forma,
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

final _segmentos = find.byType(SegmentedButton<String>);
final _boton = find.byType(OutlinedButton);

/// Los segmentos de cualquier selector (en la página son de `BayPlanMode`).
final _cualquierSegmento = find.byWidgetPredicate((w) => w is SegmentedButton);

void main() {
  group('BsSelectorDeModo (14.6)', () {
    testWidgets('según el ancho medido: segmentos si caben enteros, si no el '
        'menú', (tester) async {
      await _selector(tester, ancho: 1000);
      expect(_segmentos, findsOneWidget);
      expect(_boton, findsNothing);
      await _selector(tester, ancho: 240);
      expect(_segmentos, findsNothing, reason: 'no cabe: no se ve');
      expect(_boton, findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('en segmentos: el rótulo corto, la cuenta y el nombre entero '
        'en la descripción emergente', (tester) async {
      final elegidos = await _selector(tester,
          ancho: 1000, forma: BsFormaDelSelector.segmentos);
      expect(find.text('Orden'), findsOneWidget);
      expect(find.text('Descarga 28'), findsOneWidget);
      expect(find.text('Carga 29'), findsOneWidget);
      final mensajes = tester
          .widgetList<Tooltip>(find.byType(Tooltip))
          .map((t) => t.message)
          .toList();
      expect(mensajes, contains(startsWith('Número de orden')));
      expect(mensajes,
          contains(contains('Toca un contenedor para marcarlo como descargado')));
      await tester.tap(find.text('Descarga 28'));
      await tester.pumpAndSettle();
      expect(elegidos, ['descarga']);
      final boton = tester.widget<SegmentedButton<String>>(_segmentos);
      expect(boton.selected, {'descarga'});
    });

    testWidgets('en menú: el elegido con su icono, entradas de 56 dp o más con '
        'su cuenta y la palomita en la elegida', (tester) async {
      final elegidos =
          await _selector(tester, ancho: 400, forma: BsFormaDelSelector.menu);
      expect(find.descendant(of: _boton, matching: find.text('Carga')),
          findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('selector')));
      await tester.pumpAndSettle();
      final entradas = find.byType(MenuItemButton);
      expect(entradas, findsNWidgets(4));
      for (final entrada in tester.widgetList(entradas)) {
        expect(tester.getSize(find.byWidget(entrada)).height,
            greaterThanOrEqualTo(56));
      }
      expect(find.text('28 por bajar en GTSTC'), findsOneWidget);
      expect(find.text('29 pendientes: 20 llenos, 9 vacíos'), findsOneWidget);
      expect(
          find.descendant(
              of: find.widgetWithText(MenuItemButton, 'Carga'),
              matching: find.byIcon(Icons.check)),
          findsOneWidget);
      await tester.tap(find.text('Número de orden').last);
      await tester.pumpAndSettle();
      expect(elegidos, ['orden']);
      expect(find.byType(MenuItemButton), findsNothing, reason: 'se cerró');
    });

    for (final oscuro in [false, true]) {
      testWidgets('accesible en las dos formas, ${oscuro ? 'de noche' : 'de día'}',
          (tester) async {
        final semantica = tester.ensureSemantics();
        await _selector(tester,
            ancho: 1000, forma: BsFormaDelSelector.segmentos, oscuro: oscuro);
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        await _selector(tester,
            ancho: 400, forma: BsFormaDelSelector.menu, oscuro: oscuro);
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        expect(find.bySemanticsLabel('Modo del plano: Carga'), findsOneWidget);
        semantica.dispose();
      });
    }
  });

  group('BsPrimeraQueCabe (14.11)', () {
    Future<void> elegir(WidgetTester tester, double ancho) async {
      await tester.pumpWidget(MaterialApp(
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: ancho,
            child: const BsPrimeraQueCabe(variantes: [
              SizedBox(key: ValueKey('ancha'), width: 500, height: 20),
              SizedBox(key: ValueKey('media'), width: 300, height: 30),
              SizedBox(key: ValueKey('reserva'), width: 100, height: 40),
            ]),
          ),
        ),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('pone la primera que cabe; las demás no se ven ni tienen tamaño',
        (tester) async {
      await elegir(tester, 600);
      expect(find.byKey(const ValueKey('ancha')), findsOneWidget);
      expect(find.byKey(const ValueKey('media')), findsNothing);
      await elegir(tester, 400);
      expect(find.byKey(const ValueKey('media')), findsOneWidget);
      expect(find.byKey(const ValueKey('ancha')), findsNothing);
      expect(
          tester
              .getSize(find.byKey(const ValueKey('ancha'), skipOffstage: false))
              .isEmpty,
          isTrue);
      await elegir(tester, 120);
      expect(find.byKey(const ValueKey('reserva')), findsOneWidget);
      expect(tester.getSize(find.byType(BsPrimeraQueCabe)).height, 40);
    });
  });

  group('la tarjeta corta y la ficha (14.2 y 14.7)', () {
    testWidgets('la tarjeta corta: 72 dp, sin la línea del detalle, que va en '
        'su etiqueta', (tester) async {
      await t117CargarFuentes();
      final semantica = tester.ensureSemantics();
      await tester.pumpWidget(MaterialApp(
        theme: BayStreamTema.claro(),
        home: const Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: BsTarjetaCifra.anchoCorta,
              child: BsTarjetaCifra(
                corta: true,
                valor: '120 de 150',
                rotulo: 'Descarga',
                detalle: '80 %',
                anillo: BsAnilloAvance(
                    fraccion: 0.8, tamano: BsTarjetaCifra.anilloCorta, grosor: 7),
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(BsTarjetaCifra)).height,
          closeTo(72, 2));
      expect(find.text('80 %'), findsNothing);
      expect(find.bySemanticsLabel('Descarga: 120 de 150, 80 %'), findsOneWidget);
      // La cifra cabe entera junto al anillo: no se encoge.
      final fitted = tester.getSize(find.byType(FittedBox).first);
      final cifra = tester.getSize(find.text('120 de 150'));
      expect(cifra.width, lessThanOrEqualTo(fitted.width + 0.5));
      semantica.dispose();
    });

    testWidgets('la ficha: rótulo y dato en una línea que envuelve, nunca con '
        'elipsis', (tester) async {
      await t117CargarFuentes();
      await tester.pumpWidget(MaterialApp(
        theme: BayStreamTema.claro(),
        home: const Scaffold(
          body: SizedBox(
            width: 160,
            child: BsFichaDeCifra(
                rotulo: 'Carga', valor: '29 pendientes, 20 llenos, 9 vacíos'),
          ),
        ),
      ));
      expect(find.text('Carga: 29 pendientes, 20 llenos, 9 vacíos'),
          findsOneWidget);
      expect(t117TextosCortados(tester, find.byType(BsFichaDeCifra)), isEmpty);
      expect(tester.getSize(find.byType(BsFichaDeCifra)).height,
          greaterThan(30), reason: 'envuelve en vez de cortar');
    });
  });

  group('en la oficina', () {
    final selector = find.byKey(const ValueKey('bay-plan-display-mode'));

    testWidgets('a 1920 la cabecera lleva los segmentos', (tester) async {
      await t117Pump(tester, modo: BayPlanMode.loading);
      expect(selector, findsOneWidget);
      expect(find.descendant(of: selector, matching: _cualquierSegmento),
          findsOneWidget);
      expect(find.byKey(const ValueKey('cabecera-de-oficina')), findsOneWidget);
      expect(
          find.descendant(
              of: find.byKey(const ValueKey('cabecera-de-oficina')),
              matching: selector),
          findsOneWidget,
          reason: 'un solo selector, en la cabecera');
      expect(tester.takeException(), isNull);
    });

    testWidgets('a 800 × 600 la cabecera lleva el menú', (tester) async {
      await t117Pump(tester, tamano: const Size(800, 600), modo: BayPlanMode.loading);
      expect(selector, findsOneWidget);
      expect(find.descendant(of: selector, matching: _cualquierSegmento),
          findsNothing);
      expect(find.descendant(of: selector, matching: _boton), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a 640 dp, donde el plano mide menos de 600, sigue siendo la '
        'oficina: un solo selector, en la cabecera', (tester) async {
      await t117Pump(tester,
          tamano: const Size(640, 900), modo: BayPlanMode.discharge);
      expect(selector, findsOneWidget);
      expect(
          find.descendant(
              of: find.byKey(const ValueKey('cabecera-de-oficina')),
              matching: selector),
          findsOneWidget);
      expect(find.byKey(const ValueKey('columna-del-plano')), findsOneWidget);
      expect(find.byKey(const ValueKey('franja-de-cifras')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('elegir en la cabecera cambia el modo del plano', (tester) async {
      final scope = await t117Pump(tester);
      // En segmentos, «Descarga» lleva su cuenta al lado.
      await tester.tap(find.descendant(
          of: selector, matching: find.textContaining('Descarga')));
      await tester.pumpAndSettle();
      expect(scope.read(bayPlanModeProvider), BayPlanMode.discharge);
      expect(find.byKey(const ValueKey('bay-discharge-pending')), findsOneWidget);
    });

    testWidgets('fuera del Plano la cabecera no lleva el selector',
        (tester) async {
      await t117Pump(tester);
      await tester.tap(find.text('Lista').first);
      await tester.pumpAndSettle();
      expect(selector, findsNothing);
    });

    testWidgets('el resumen de Descarga en fichas: la bahía, la escala y la '
        'carga', (tester) async {
      await t117Pump(tester, modo: BayPlanMode.discharge);
      final franja = find.byKey(const ValueKey('franja-de-cifras'));
      final bahia = tester.widget<BsFichaDeCifra>(find.descendant(
          of: franja,
          matching: find.byKey(const ValueKey('bay-discharge-pending'))));
      expect(bahia.texto, startsWith('Bahía 02: '));
      expect(bahia.texto, contains('por bajar en cub.'));
      expect(bahia.texto, contains('bajados'));
      expect(
          find.descendant(
              of: franja,
              matching: find.byKey(const ValueKey('operation-discharge-totals'))),
          findsOneWidget);
      // La instrucción ya no es fija: es la ayuda de Descarga.
      expect(find.text('Toca un contenedor para marcarlo como descargado.'),
          findsNothing);
    });

    testWidgets('sin escala, la franja de cifras dice el viaje', (tester) async {
      await t117Pump(tester, voyage: t117SinEscala);
      expect(find.textContaining('Viaje: 14 contenedores'), findsOneWidget);
      expect(find.byKey(const ValueKey('franja-de-cifras')), findsOneWidget);
    });

    testWidgets('«Colorear por» en la franja de la bahía cambia la vista',
        (tester) async {
      final scope = await t117Pump(tester);
      final colorear = find.byKey(const ValueKey('colorear-por'));
      expect(colorear, findsOneWidget);
      expect(
          find.descendant(of: colorear, matching: find.text('Estado')),
          findsNothing,
          reason: 'Estado solo en Descarga');
      await tester.tap(find.descendant(
          of: colorear, matching: find.text('Tipo de vacío')));
      await tester.pumpAndSettle();
      expect(scope.read(colorearPorProvider)[BayPlanMode.content],
          ColorearPor.tipo);
    });
  });
}
