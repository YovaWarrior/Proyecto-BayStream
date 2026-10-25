// T-117 y T-118 · Corrección 1 de la entrega 1 (SPRINT-4.md 10.42): los tres
// hallazgos de la aceptación de Codex (docs/t117/entrega1/aceptacion-codex.md),
// cada uno con la prueba que lo reproduce y que fallaba antes del arreglo.
//
// - H1: con el panel oculto y el flotante abierto, el botón de la cabecera
//   dice «Cerrar el panel lateral» y lo fijaba, guardando «visible». Ahora
//   cierra el flotante, el panel sigue oculto y la preferencia no cambia
//   (DESIGN.md 14.3).
// - H2: Esc no cerraba el menú del modo, que se quedaba encima de «Deshacer»
//   en dos casos de la matriz de Codex (800 × 600, letra 2.0, Descarga, panel
//   fijo y oculto); se repiten aquí. Atrás de Android, con el viaje entero,
//   está en t114_candidata_atras_test.dart (DESIGN.md 14.6).
// - H3: a 700 dp, sin el panel fijo, el botón del puente quedaba solo en una
//   segunda línea y la franja de la bahía medía 108 dp en vez de 56
//   (DESIGN.md 14.8).
import 'package:baystream/core/design/design.dart';
import 'package:baystream/features/vessel/domain/repositories/local_vessel_repository.dart';
import 'package:baystream/features/vessel/presentation/providers/oficina_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/plano_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/avisos_del_viaje.dart';
import 'package:baystream/features/vessel/presentation/widgets/loading_plan_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t117_oficina_support.dart';

final _panel = find.byKey(const ValueKey('panel-lateral'));
final _flotante = find.byKey(const ValueKey('panel-flotante'));
final _bordeDelPanel = find.byKey(const ValueKey('borde-del-panel'));
final _botonDelPanel = find.byKey(const ValueKey('boton-del-panel'));
final _botonDelPuente = find.byKey(const ValueKey('boton-del-puente'));
final _franjaDeLaBahia = find.byKey(const ValueKey('franja-de-la-bahia'));
final _franjaDeCifras = find.byKey(const ValueKey('franja-de-cifras'));
final _bahiaElegir = find.byKey(const ValueKey('bahia-elegir'));
final _entradas = find.byType(MenuItemButton);

/// El botón del menú del modo en la cabecera de la oficina.
final _menuDelModo = find.descendant(
    of: find.byKey(const ValueKey('bay-plan-display-mode')),
    matching: find.byType(OutlinedButton));

String? _rotulo(WidgetTester tester) =>
    tester.widget<IconButton>(_botonDelPanel).tooltip;

void main() {
  group('H1 · el botón de la cabecera con el flotante abierto (14.3)', () {
    testWidgets(
        'abierto por una celda: «Cerrar el panel lateral» lo cierra, el panel '
        'sigue oculto y la preferencia guardada no cambia', (tester) async {
      final equipo = T117Equipo({UiPreference.sidePanel: 'oculto'});
      final scope = await t117Pump(tester,
          tamano: const Size(1536, 793), equipo: equipo);
      final celda = find.byKey(const ValueKey('cell-1-82'));
      await tester.ensureVisible(celda);
      await tester.pumpAndSettle();
      await tester.tap(celda);
      await tester.pumpAndSettle();
      expect(_flotante, findsOneWidget);
      expect(_rotulo(tester), 'Cerrar el panel lateral');

      await tester.tap(_botonDelPanel);
      await tester.pumpAndSettle();
      expect(_flotante, findsNothing);
      expect(_panel, findsNothing, reason: 'cerrar no fija el panel');
      expect(equipo.guardadas[UiPreference.sidePanel], 'oculto',
          reason: 'la preferencia guardada no cambia');
      expect(scope.read(preferenciasDeLaOficinaProvider).value!.panelVisible,
          isFalse);
      // Se cierra con su detalle, como con «Cerrar» del flotante (P5).
      expect(scope.read(celdaSeleccionadaProvider), isNull);
      expect(_rotulo(tester), 'Mostrar el panel lateral');
      expect(tester.takeException(), isNull);
    });

    testWidgets('abierto por el borde: lo mismo', (tester) async {
      final equipo = T117Equipo({UiPreference.sidePanel: 'oculto'});
      await t117Pump(tester, tamano: const Size(1536, 793), equipo: equipo);
      await tester.tap(_bordeDelPanel);
      await tester.pumpAndSettle();
      expect(_flotante, findsOneWidget);
      expect(_rotulo(tester), 'Cerrar el panel lateral');
      await tester.tap(_botonDelPanel);
      await tester.pumpAndSettle();
      expect(_flotante, findsNothing);
      expect(_panel, findsNothing);
      expect(equipo.guardadas[UiPreference.sidePanel], 'oculto');
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'sin flotante, desde 1200 dp, el botón sigue ocultando y mostrando el '
        'panel fijo, y la app lo recuerda', (tester) async {
      final equipo = T117Equipo();
      await t117Pump(tester, tamano: const Size(1536, 793), equipo: equipo);
      expect(_panel, findsOneWidget);
      expect(_rotulo(tester), 'Ocultar el panel lateral');
      await tester.tap(_botonDelPanel);
      await tester.pumpAndSettle();
      expect(_panel, findsNothing);
      expect(equipo.guardadas[UiPreference.sidePanel], 'oculto');
      expect(_rotulo(tester), 'Mostrar el panel lateral');
      await tester.tap(_botonDelPanel);
      await tester.pumpAndSettle();
      expect(_panel, findsOneWidget);
      expect(_flotante, findsNothing);
      expect(equipo.guardadas[UiPreference.sidePanel], 'visible');
      expect(tester.takeException(), isNull);
    });

    testWidgets('para fijarlo desde el flotante está «Fijar»', (tester) async {
      final equipo = T117Equipo({UiPreference.sidePanel: 'oculto'});
      await t117Pump(tester, tamano: const Size(1536, 793), equipo: equipo);
      await tester.tap(_bordeDelPanel);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('fijar-panel')));
      await tester.pumpAndSettle();
      expect(_flotante, findsNothing);
      expect(_panel, findsOneWidget);
      expect(equipo.guardadas[UiPreference.sidePanel], 'visible');
      expect(tester.takeException(), isNull);
    });
  });

  group('H2 · Esc cierra el menú del modo (14.6)', () {
    testWidgets('en la cabecera de la oficina: Esc lo cierra', (tester) async {
      await t117Pump(tester,
          tamano: const Size(800, 600), modo: BayPlanMode.discharge);
      expect(_menuDelModo, findsOneWidget,
          reason: 'a 800 dp la cabecera lleva el modo en menú');
      await tester.tap(_menuDelModo);
      await tester.pumpAndSettle();
      expect(_entradas, findsWidgets);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(_entradas, findsNothing);
      expect(_menuDelModo, findsOneWidget, reason: 'el plano se queda');
      expect(tester.takeException(), isNull);
    });

    for (final oculto in <bool>[false, true]) {
      testWidgets(
          'el caso de Codex: 800 × 600, letra 2.0, Descarga, panel '
          '${oculto ? 'oculto' : 'fijo'}: con el menú cerrado por Esc, '
          '«Deshacer» del aviso responde', (tester) async {
        await t117Pump(tester,
            tamano: const Size(800, 600),
            letra: 2.0,
            equipo: T117Equipo(
                {if (oculto) UiPreference.sidePanel: 'oculto'}),
            modo: BayPlanMode.discharge);
        await tester.tap(_menuDelModo);
        await tester.pumpAndSettle();
        expect(_entradas, findsWidgets);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(_entradas, findsNothing, reason: 'Esc cierra el menú');

        var deshecho = false;
        tester
            .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger).first)
            .showSnackBar(avisoDelViaje(
              key: const ValueKey('aviso-de-la-correccion'),
              texto: 'Descarga registrada en la bahía 02.',
              corto: 'Descarga registrada.',
              accion: 'Deshacer',
              onAccion: () => deshecho = true,
              duracion: const Duration(seconds: 6),
            ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 750));
        final aviso = tester.getRect(find
            .descendant(
                of: find.byKey(const ValueKey('aviso-de-la-correccion')),
                matching: find.byType(Material))
            .first);
        expect(aviso.top,
            greaterThanOrEqualTo(tester.getRect(_franjaDeCifras).top - 0.5));
        expect(find.text('Deshacer').hitTestable(), findsOneWidget);
        await tester.tap(find.text('Deshacer'));
        await tester.pumpAndSettle();
        expect(deshecho, isTrue);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets(
        'el selector suelto: al abrirse da lo que lo cierra, lo devuelve al '
        'cerrarse (por lo que lo cierra, como Atrás, o por Esc) y el foco '
        'pasa a la entrada elegida y sale con el menú', (tester) async {
      await t117CargarFuentes();
      final abiertos = <VoidCallback>[];
      final cerrados = <VoidCallback>[];
      await tester.pumpWidget(MaterialApp(
        theme: BayStreamTema.claro(),
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: BsSelectorDeModo<String>(
              entradas: const <BsEntradaDeModo<String>>[
                BsEntradaDeModo<String>(valor: 'contenido', rotulo: 'Contenido'),
                BsEntradaDeModo<String>(valor: 'descarga', rotulo: 'Descarga'),
              ],
              elegido: 'descarga',
              forma: BsFormaDelSelector.menu,
              onElegir: (_) {},
              alAbrirElMenu: abiertos.add,
              alCerrarElMenu: cerrados.add,
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      final boton = find.byType(OutlinedButton);

      await tester.tap(boton);
      await tester.pumpAndSettle();
      expect(abiertos, hasLength(1));
      final elegida = tester.widget<MenuItemButton>(
          find.widgetWithText(MenuItemButton, 'Descarga'));
      expect(elegida.focusNode?.hasPrimaryFocus, isTrue,
          reason: 'el foco pasa a la entrada elegida');
      // Lo que se dio al abrir lo cierra: así lo cierra Atrás de Android.
      abiertos.single();
      await tester.pumpAndSettle();
      expect(_entradas, findsNothing);
      expect(cerrados, hasLength(1));
      expect(identical(cerrados.single, abiertos.single), isTrue);

      await tester.tap(boton);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(_entradas, findsNothing);
      expect(cerrados, hasLength(2));
      expect(elegida.focusNode?.hasFocus, isFalse,
          reason: 'el foco sale con el menú');
      expect(tester.takeException(), isNull);
    });
  });

  group('H3 · el botón del puente no queda solo en una línea (14.8)', () {
    testWidgets(
        'a 700 dp en Contenido, sin el panel fijo: la franja de la bahía va '
        'en una línea, con el botón al final', (tester) async {
      await t117Pump(tester, tamano: const Size(700, 682));
      expect(_panel, findsNothing);
      expect(tester.getSize(_franjaDeLaBahia).height, lessThanOrEqualTo(56.5),
          reason: 'antes medía 108');
      expect(tester.getCenter(_botonDelPuente).dy,
          closeTo(tester.getCenter(_bahiaElegir).dy, 0.5));
      expect(tester.getRect(_botonDelPuente).right,
          lessThanOrEqualTo(tester.getRect(_franjaDeLaBahia).right + 0.5));
      expect(t117TextosCortados(tester, _franjaDeLaBahia), isEmpty);
      expect(tester.takeException(), isNull);
    });

    // Al medir la corrección aparecieron dos desbordes: uno viejo, que la
    // matriz de 0.5.5 no veía (no tiene 600 ni 700 dp): a 600 y 700 con la
    // letra a 2.0, en Carga, los controles con sus rótulos no cabían en lo
    // que envuelve; y otro que traía la variante nueva: a 960 con 2.0, en
    // Descarga, `BsPrimeraQueCabe` la aceptaba aunque medía 0.08 dp más.
    for (final ventana in const <Size>[
      Size(600, 800),
      Size(700, 682),
      Size(800, 600),
      Size(960, 1000),
    ]) {
      for (final letra in const <double>[1.0, 1.45, 2.0]) {
        for (final modo in const <BayPlanMode>[
          BayPlanMode.content,
          BayPlanMode.discharge,
          BayPlanMode.loading,
        ]) {
          testWidgets(
              '${ventana.width.round()} × ${ventana.height.round()}, letra '
              '$letra, ${modo.name}: la franja no se desborda ni corta nada y '
              'el botón va en la primera línea', (tester) async {
            await t117Pump(tester, tamano: ventana, letra: letra, modo: modo);
            expect(tester.takeException(), isNull);
            final franja = tester.getRect(_franjaDeLaBahia);
            final boton = tester.getRect(_botonDelPuente);
            expect(boton.right, lessThanOrEqualTo(franja.right + 0.5));
            expect(boton.top, lessThan(tester.getRect(_bahiaElegir).bottom));
            expect(t117TextosCortados(tester, _franjaDeLaBahia), isEmpty);
          });
        }
      }
    }

    for (final letra in <double>[1.45, 2.0]) {
      testWidgets(
          'a 700 dp con la letra a $letra, si la franja envuelve, el botón va '
          'en la primera línea', (tester) async {
        await t117Pump(tester, tamano: const Size(700, 682), letra: letra);
        final boton = tester.getRect(_botonDelPuente);
        final titulo = tester.getRect(_bahiaElegir);
        expect(boton.top, lessThan(titulo.bottom),
            reason: 'en la línea del título, no sola debajo');
        expect(boton.bottom, greaterThan(titulo.top));
        expect(t117TextosCortados(tester, _franjaDeLaBahia), isEmpty);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
