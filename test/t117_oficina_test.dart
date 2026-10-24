// T-117 · Más plano en la oficina (SPRINT-4.md 10.36 a 10.39; DESIGN.md 14):
// la columna central se desplaza entera, el panel del buque en tres alturas
// con su borde, la franja de la bahía fijada arriba, la franja de cifras fija
// abajo con los avisos, y el panel lateral fijo, oculto o flotante.
//
// La matriz de 0.5.5 y 14.9: siete ventanas, tres letras, el panel fijo,
// flotante y oculto, y Contenido, Descarga y Carga, sin desbordes, con la
// leyenda, las franjas y las tarjetas enteras. Con las fuentes del producto.
// Buque y números sintéticos (BUQUE MANUAL, TSTU).
import 'package:baystream/core/design/design.dart';
import 'package:baystream/features/vessel/domain/repositories/local_vessel_repository.dart';
import 'package:baystream/features/vessel/presentation/pages/parameters_page.dart';
import 'package:baystream/features/vessel/presentation/providers/oficina_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/plano_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/avisos_del_viaje.dart';
import 'package:baystream/features/vessel/presentation/widgets/detalle_contenedor.dart';
import 'package:baystream/features/vessel/presentation/widgets/loading_plan_controls.dart';
import 'package:baystream/features/vessel/presentation/widgets/navegacion_del_viaje.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t117_oficina_support.dart';

/// Las ventanas de la matriz (0.5.5): maximizada a 100 % y a 125 %, la laptop
/// de Carlos, 1366 × 768 maximizada, 1280 × 720, media pantalla de 1920 y
/// 800 × 600.
const _ventanas = <Size>[
  Size(1920, 1000),
  Size(1707, 996),
  Size(1536, 793),
  Size(1366, 690),
  Size(1280, 720),
  Size(960, 1000),
  Size(800, 600),
];

const _letras = <double>[1.0, 1.45, 2.0];

const _modos = <BayPlanMode>[
  BayPlanMode.content,
  BayPlanMode.discharge,
  BayPlanMode.loading,
];

/// Cómo está el panel lateral en cada caso de la matriz.
enum _Panel { fijo, flotante, oculto }

final _cabecera = find.byKey(const ValueKey('cabecera-de-oficina'));
final _franjaDeLaBahia = find.byKey(const ValueKey('franja-de-la-bahia'));
final _franjaDeCifras = find.byKey(const ValueKey('franja-de-cifras'));
final _puente = find.byKey(const ValueKey('puente-del-plano'));
final _borde = find.byKey(const ValueKey('borde-del-puente'));
final _leyenda = find.byKey(const ValueKey('leyenda-del-plano'));
final _panel = find.byKey(const ValueKey('panel-lateral'));
final _flotante = find.byKey(const ValueKey('panel-flotante'));
final _bordeDelPanel = find.byKey(const ValueKey('borde-del-panel'));
final _botonDelPanel = find.byKey(const ValueKey('boton-del-panel'));
final _botonDelPuente = find.byKey(const ValueKey('boton-del-puente'));
final _columna = find.byType(MideLosLados);

/// La columna que se desplaza.
ScrollableState _desplazable(WidgetTester tester) => tester.state<ScrollableState>(
    find
        .descendant(
            of: find.byKey(const ValueKey('columna-del-plano')),
            matching: find.byType(Scrollable))
        .first);

/// Desplaza la columna hasta que [buscado] esté a la vista, sin arrastrar
/// (el panel flotante puede estar encima del centro de la columna).
Future<void> _desplazarHasta(WidgetTester tester, Finder buscado) async {
  final posicion = _desplazable(tester).position;
  while (buscado.evaluate().isEmpty &&
      posicion.pixels < posicion.maxScrollExtent) {
    posicion.jumpTo((posicion.pixels + 120).clamp(0, posicion.maxScrollExtent));
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

/// El alto que ocupa ahora el panel del buque (sin el borde).
double _altoDelPuente(WidgetTester tester) =>
    tester.getSize(_puente).height - tester.getSize(_borde).height;

void main() {
  group('la matriz de 0.5.5: nada se corta ni se desborda', () {
    for (final ventana in _ventanas) {
      for (final letra in _letras) {
        for (final panel in _Panel.values) {
          for (final modo in _modos) {
            final nombre = '${ventana.width.round()} × ${ventana.height.round()}, '
                'letra $letra, panel ${panel.name}, ${modo.name}';
            testWidgets(nombre, (tester) async {
              final equipo = T117Equipo({
                if (panel != _Panel.fijo) UiPreference.sidePanel: 'oculto',
              });
              await t117Pump(tester,
                  tamano: ventana, letra: letra, equipo: equipo, modo: modo);
              if (panel == _Panel.flotante) {
                await tester.tap(_bordeDelPanel);
                await tester.pumpAndSettle();
                expect(_flotante, findsOneWidget);
              }
              expect(tester.takeException(), isNull, reason: 'al abrir');

              final columna = tester.getRect(_columna);
              expect(columna.right, lessThanOrEqualTo(ventana.width + 0.5));
              // La cabecera, con Buscar y el botón del panel al alcance.
              expect(tester.getRect(_cabecera).right,
                  lessThanOrEqualTo(columna.right + 0.5));
              expect(find.byKey(const ValueKey('buscar-contenedor')).hitTestable(),
                  findsOneWidget);
              expect(_botonDelPanel.hitTestable(), findsOneWidget);
              // La franja de cifras, fija abajo y dentro de la columna.
              final cifras = tester.getRect(_franjaDeCifras);
              expect(cifras.bottom, closeTo(ventana.height, 0.5));
              expect(cifras.height, greaterThanOrEqualTo(64));
              expect(cifras.right, lessThanOrEqualTo(columna.right + 0.5));
              // Las tarjetas, enteras dentro de la columna.
              for (final tarjeta in tester
                  .widgetList<BsTarjetaCifra>(find.byType(BsTarjetaCifra))) {
                final rect = tester.getRect(find.byWidget(tarjeta));
                expect(rect.right, lessThanOrEqualTo(columna.right + 0.5));
                expect(tarjeta.corta, isTrue);
              }
              // El panel como se pidió.
              final hayPanelFijo =
                  panel == _Panel.fijo && ventana.width >= 1200;
              if (hayPanelFijo) {
                expect(_panel, findsOneWidget);
                expect(_flotante, findsNothing);
                expect(_bordeDelPanel, findsNothing);
              } else if (panel == _Panel.flotante) {
                final flotante = tester.getRect(_flotante);
                expect(flotante.right, lessThanOrEqualTo(columna.right + 0.5));
                expect(flotante.bottom, lessThanOrEqualTo(cifras.top + 0.5),
                    reason: 'el flotante no tapa la franja de cifras');
                expect(flotante.left, greaterThanOrEqualTo(columna.left + 47.5),
                    reason: 'la columna conserva 48 dp');
              } else {
                expect(_panel, findsNothing);
                expect(_bordeDelPanel, findsOneWidget);
              }
              // Ningún texto cortado en la cabecera ni en las franjas.
              expect(t117TextosCortados(tester, _cabecera), isEmpty);
              expect(t117TextosCortados(tester, _franjaDeCifras), isEmpty);
              // La rejilla, a la vista al desplazar la columna; con la letra
              // grande en una ventana baja, el panel del buque llena la vista
              // y la franja de la bahía asoma al desplazar.
              final altoDelPuente = tester.getSize(_puente).height;
              final celda = find.byKey(const ValueKey('cell-1-82'));
              await _desplazarHasta(tester, celda);
              expect(find.byKey(const ValueKey('plan-zoom-2')), findsOneWidget);
              // A la vista de verdad: en el centro de la columna, sin que la
              // franja de la bahía (fijada o no) ni la de cifras la tapen. El
              // panel flotante, si está, va encima a propósito.
              await tester.ensureVisible(celda);
              Scrollable.ensureVisible(tester.element(celda), alignment: 0.5);
              await tester.pumpAndSettle();
              if (panel != _Panel.flotante) {
                expect(celda.hitTestable(), findsOneWidget,
                    reason: 'la rejilla a la vista');
              }
              // La franja de la bahía, entera a lo ancho (si no cabe fijada,
              // ya se fue hacia arriba: se mide igual).
              final franjaEntera = find.byKey(
                  const ValueKey('franja-de-la-bahia'),
                  skipOffstage: false);
              final franja = tester.getRect(franjaEntera);
              expect(franja.left, greaterThanOrEqualTo(columna.left - 0.5));
              expect(franja.right, lessThanOrEqualTo(columna.right + 0.5));
              expect(t117TextosCortados(tester, franjaEntera), isEmpty);
              // Al final de la columna, la leyenda: envuelve y no se corta.
              final desplazable = _desplazable(tester);
              desplazable.position.jumpTo(desplazable.position.maxScrollExtent);
              await tester.pumpAndSettle();
              expect(_leyenda, findsOneWidget);
              final leyenda = tester.getRect(_leyenda);
              expect(leyenda.left, greaterThanOrEqualTo(columna.left - 0.5));
              expect(leyenda.right, lessThanOrEqualTo(columna.right + 0.5));
              expect(t117TextosCortados(tester, _leyenda), isEmpty);
              // La franja de la bahía se queda fijada arriba si cabe (un
              // tercio de la columna); si no, se fue con el panel del buque,
              // para no tapar la rejilla (14.1).
              final vista = tester
                  .getSize(find.byKey(const ValueKey('columna-del-plano')))
                  .height;
              final franjaFinal = find.byKey(const ValueKey('franja-de-la-bahia'),
                  skipOffstage: false);
              final fijada = tester.getSize(franjaFinal).height <= vista / 3;
              final cabeceraAbajo = tester.getRect(_cabecera).bottom;
              if (fijada && desplazable.position.pixels >= altoDelPuente) {
                expect(tester.getRect(franjaFinal).top,
                    closeTo(cabeceraAbajo, 0.5));
              }
              expect(tester.takeException(), isNull, reason: 'al desplazar');
            });
          }
        }
      }
    }
  });

  group('el panel del buque en tres alturas (14.2)', () {
    testWidgets('el botón pliega y despliega, y la app lo recuerda',
        (tester) async {
      final equipo = T117Equipo();
      await t117Pump(tester, equipo: equipo, modo: BayPlanMode.discharge);
      final completo = _altoDelPuente(tester);
      expect(completo, greaterThan(160), reason: 'la silueta de 6 y 6 niveles');
      expect(find.byKey(const ValueKey('bay-selector')), findsOneWidget);
      await tester.tap(_botonDelPuente);
      await tester.pumpAndSettle();
      expect(_altoDelPuente(tester), 0);
      expect(find.byKey(const ValueKey('bay-selector')), findsNothing);
      expect(equipo.guardadas[UiPreference.bridgeHeight], 'plegado');
      // Plegado, las cifras siguen en la franja de cifras.
      expect(find.byKey(const ValueKey('operation-discharge-totals')),
          findsOneWidget);
      await tester.tap(_botonDelPuente);
      await tester.pumpAndSettle();
      expect(_altoDelPuente(tester), completo);
      expect(equipo.guardadas[UiPreference.bridgeHeight], 'completo');
      expect(tester.takeException(), isNull);
    });

    testWidgets('abre como lo dejó este equipo', (tester) async {
      await t117Pump(tester,
          equipo: T117Equipo({UiPreference.bridgeHeight: 'compacto'}));
      final compacto = _altoDelPuente(tester);
      await tester.tap(_botonDelPuente);
      await tester.pumpAndSettle();
      await tester.tap(_botonDelPuente);
      await tester.pumpAndSettle();
      expect(_altoDelPuente(tester), compacto, reason: 'vuelve a la compacta');
      expect(tester.takeException(), isNull);
    });

    testWidgets('arrastrar el borde: nunca recorta y al soltar se queda en la '
        'altura más cercana', (tester) async {
      final equipo = T117Equipo();
      final scope = await t117Pump(tester, equipo: equipo);
      final completo = _altoDelPuente(tester);
      // El alto de la compacta, para saber dónde están los umbrales.
      await scope
          .read(preferenciasDeLaOficinaProvider.notifier)
          .elegirAltura(AlturaDelPuente.compacto);
      await tester.pumpAndSettle();
      final compacta = _altoDelPuente(tester);
      await scope
          .read(preferenciasDeLaOficinaProvider.notifier)
          .elegirAltura(AlturaDelPuente.completo);
      await tester.pumpAndSettle();
      expect(completo - compacta, greaterThan(40));
      // El arrastre empieza al pasar la tolerancia del gesto (kTouchSlop).
      const tolerancia = 18.0;
      // Un poco hacia arriba: sigue completo.
      final gesto = await tester.startGesture(tester.getCenter(_borde));
      await gesto.moveBy(const Offset(0, -tolerancia - 2));
      await tester.pump();
      await gesto.moveBy(Offset(0, -(completo - compacta) * 0.3));
      await tester.pump();
      // Mientras se arrastra, lo que se ve cabe entero en el alto arrastrado.
      final arrastrado = _altoDelPuente(tester);
      final selectores = find.byKey(const ValueKey('bay-selector'));
      if (selectores.evaluate().isNotEmpty) {
        expect(tester.getSize(selectores).height,
            lessThanOrEqualTo(arrastrado + 0.5));
      }
      await gesto.up();
      await tester.pumpAndSettle();
      expect(_altoDelPuente(tester), completo);
      // Cerca de la compacta: se queda en ella.
      final gesto2 = await tester.startGesture(tester.getCenter(_borde));
      await gesto2.moveBy(const Offset(0, -tolerancia - 2));
      await tester.pump();
      await gesto2.moveBy(Offset(0, -(completo - compacta) * 0.9));
      await tester.pump();
      await gesto2.up();
      await tester.pumpAndSettle();
      expect(equipo.guardadas[UiPreference.bridgeHeight], 'compacto');
      expect(_altoDelPuente(tester), compacta);
      // Hasta arriba del todo: plegado.
      final gesto3 = await tester.startGesture(tester.getCenter(_borde));
      await gesto3.moveBy(const Offset(0, -tolerancia - 2));
      await tester.pump();
      await gesto3.moveBy(Offset(0, -compacta - 40));
      await tester.pump();
      await gesto3.up();
      await tester.pumpAndSettle();
      expect(_altoDelPuente(tester), 0);
      expect(equipo.guardadas[UiPreference.bridgeHeight], 'plegado');
      expect(tester.takeException(), isNull);
    });

    testWidgets('el doble clic en el borde pliega y despliega', (tester) async {
      await t117Pump(tester);
      final completo = _altoDelPuente(tester);
      await tester.tap(_borde);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(_borde);
      await tester.pumpAndSettle();
      expect(_altoDelPuente(tester), 0);
      await tester.tap(_borde);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(_borde);
      await tester.pumpAndSettle();
      expect(_altoDelPuente(tester), completo);
    });

    testWidgets('con el teclado: ↑ baja una altura, ↓ sube y Intro pliega',
        (tester) async {
      final scope = await t117Pump(tester);
      AlturaDelPuente altura() =>
          scope.read(preferenciasDeLaOficinaProvider).value!.altura;
      final foco = tester
          .widget<Focus>(find
              .descendant(of: _borde, matching: find.byType(Focus))
              .first)
          .focusNode!;
      foco.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      expect(altura(), AlturaDelPuente.compacto);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      expect(altura(), AlturaDelPuente.plegado);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(altura(), AlturaDelPuente.compacto);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(altura(), AlturaDelPuente.plegado);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(altura(), AlturaDelPuente.compacto, reason: 'la última abierta');
    });

    testWidgets('para el lector de pantalla es un control ajustable',
        (tester) async {
      final semantica = tester.ensureSemantics();
      await t117Pump(tester);
      final nodo = tester.getSemantics(_borde);
      expect(nodo.label, 'Alto del panel del buque');
      expect(nodo.value, 'completo');
      expect(nodo.decreasedValue, 'compacto');
      final datos = nodo.getSemanticsData();
      expect(datos.hasAction(SemanticsAction.decrease), isTrue);
      expect(datos.hasAction(SemanticsAction.increase), isTrue);
      expect(nodo.flagsCollection.isSlider, isTrue);
      semantica.dispose();
    });

    testWidgets('al desplazar, el panel se va sin cambiar de altura y la franja '
        'de la bahía se queda arriba', (tester) async {
      final scope = await t117Pump(tester, tamano: const Size(1366, 690));
      final desplazable = _desplazable(tester);
      desplazable.position.jumpTo(desplazable.position.maxScrollExtent);
      await tester.pumpAndSettle();
      expect(scope.read(preferenciasDeLaOficinaProvider).value!.altura,
          AlturaDelPuente.completo);
      expect(tester.getRect(_franjaDeLaBahia).top,
          closeTo(tester.getRect(_cabecera).bottom, 0.5));
      // ‹ y › cambian de bahía con el panel fuera de la vista (también a las
      // impares que solo traen la sombra de los 40).
      final numeros = t117ConEscala.bays.keys.toList()..sort();
      final siguiente = numeros[numeros.indexOf(2) + 1];
      await tester.tap(find.byKey(const ValueKey('bahia-siguiente')));
      await tester.pumpAndSettle();
      expect(scope.read(selectedBayProvider), siguiente);
      expect(find.byKey(ValueKey('plan-zoom-$siguiente')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('bahia-anterior')));
      await tester.pumpAndSettle();
      expect(scope.read(selectedBayProvider), 2);
      expect(tester.takeException(), isNull);
    });
  });

  group('el panel lateral: fijo, oculto o flotante (14.3)', () {
    testWidgets('el botón oculta el panel fijo y la app lo recuerda',
        (tester) async {
      final equipo = T117Equipo();
      await t117Pump(tester, equipo: equipo, modo: BayPlanMode.discharge);
      final antes = tester.getRect(_columna).width;
      expect(_panel, findsOneWidget);
      await tester.tap(_botonDelPanel);
      await tester.pumpAndSettle();
      expect(_panel, findsNothing);
      expect(_bordeDelPanel, findsOneWidget);
      expect(equipo.guardadas[UiPreference.sidePanel], 'oculto');
      expect(tester.getRect(_columna).width, greaterThan(antes + 300),
          reason: 'la columna central gana el ancho del panel');
      await tester.tap(_botonDelPanel);
      await tester.pumpAndSettle();
      expect(_panel, findsOneWidget);
      expect(equipo.guardadas[UiPreference.sidePanel], 'visible');
    });

    testWidgets('con el mouse en el borde 250 ms sale flotante y se va al '
        'salir', (tester) async {
      await t117Pump(tester,
          equipo: T117Equipo({UiPreference.sidePanel: 'oculto'}));
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: const Offset(900, 500));
      await tester.pump();
      await mouse.moveTo(tester.getCenter(_bordeDelPanel));
      await tester.pump(const Duration(milliseconds: 200));
      expect(_flotante, findsNothing, reason: 'todavía no');
      await tester.pump(const Duration(milliseconds: 100));
      expect(_flotante, findsOneWidget);
      // Del borde al panel: se queda.
      await mouse.moveTo(tester.getCenter(_flotante));
      await tester.pump(const Duration(milliseconds: 600));
      expect(_flotante, findsOneWidget);
      // Fuera del panel: se va a los 400 ms.
      await mouse.moveTo(const Offset(400, 500));
      await tester.pump(const Duration(milliseconds: 300));
      expect(_flotante, findsOneWidget);
      await tester.pump(const Duration(milliseconds: 150));
      expect(_flotante, findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('un dedo que pasa no lo abre; el toque sí', (tester) async {
      await t117Pump(tester,
          equipo: T117Equipo({UiPreference.sidePanel: 'oculto'}));
      final dedo = await tester.createGesture(kind: PointerDeviceKind.touch);
      await dedo.down(tester.getCenter(_bordeDelPanel) + const Offset(0, -200));
      await dedo.moveTo(tester.getCenter(_bordeDelPanel));
      await tester.pump(const Duration(milliseconds: 400));
      await dedo.up();
      await tester.pumpAndSettle();
      expect(_flotante, findsNothing);
      await tester.tap(_bordeDelPanel);
      await tester.pumpAndSettle();
      expect(_flotante, findsOneWidget);
    });

    testWidgets('apagado en Parámetros, el borde no está y queda el botón',
        (tester) async {
      await t117Pump(tester,
          equipo: T117Equipo({
            UiPreference.sidePanel: 'oculto',
            UiPreference.sidePanelOnHover: 'no',
          }));
      expect(_bordeDelPanel, findsNothing);
      await tester.tap(_botonDelPanel);
      await tester.pumpAndSettle();
      expect(_panel, findsOneWidget, reason: 'desde 1200 dp el botón lo fija');
    });

    testWidgets('con el panel oculto, una celda abre el flotante con su '
        'detalle; Cerrar, Esc y Fijar', (tester) async {
      final equipo = T117Equipo({UiPreference.sidePanel: 'oculto'});
      final scope = await t117Pump(tester, equipo: equipo);
      final celda = find.byKey(const ValueKey('cell-1-82'));
      await tester.ensureVisible(celda);
      await tester.pumpAndSettle();
      await tester.tap(celda);
      await tester.pumpAndSettle();
      expect(_flotante, findsOneWidget);
      expect(find.descendant(of: _flotante, matching: find.byType(DetalleContenedor)),
          findsOneWidget);
      // Cerrar lo guarda y limpia la selección.
      await tester.tap(find.byKey(const ValueKey('cerrar-panel')));
      await tester.pumpAndSettle();
      expect(_flotante, findsNothing);
      expect(scope.read(celdaSeleccionadaProvider), isNull);
      // Esc también.
      await tester.tap(celda);
      await tester.pumpAndSettle();
      expect(_flotante, findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(_flotante, findsNothing);
      // «Fijar» lo deja fijo y lo recuerda.
      await tester.tap(celda);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('fijar-panel')));
      await tester.pumpAndSettle();
      expect(_flotante, findsNothing);
      expect(_panel, findsOneWidget);
      expect(equipo.guardadas[UiPreference.sidePanel], 'visible');
      expect(tester.takeException(), isNull);
    });

    testWidgets('de 600 a 1199 dp el detalle sale en el flotante, no en la '
        'hoja de abajo', (tester) async {
      await t117Pump(tester, tamano: const Size(960, 1000));
      final celda = find.byKey(const ValueKey('cell-1-82'));
      await tester.ensureVisible(celda);
      await tester.pumpAndSettle();
      await tester.tap(celda);
      await tester.pumpAndSettle();
      expect(_flotante, findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);
      expect(find.byKey(const ValueKey('fijar-panel')), findsNothing,
          reason: 'sin sitio para fijarlo');
    });

    testWidgets('«En vivo» no se corta con una ventana baja y una celda elegida',
        (tester) async {
      await t117Pump(tester,
          tamano: const Size(1366, 690), modo: BayPlanMode.discharge);
      final celda = find.byKey(const ValueKey('cell-1-82'));
      await tester.ensureVisible(celda);
      await tester.pumpAndSettle();
      await tester.tap(celda);
      await tester.pumpAndSettle();
      final panel = tester.getRect(_panel);
      final enVivo = tester.getRect(find.byKey(const ValueKey('en-vivo-del-panel')));
      expect(enVivo.height, lessThanOrEqualTo(panel.height / 2 + 0.5));
      expect(enVivo.bottom, lessThanOrEqualTo(panel.bottom + 0.5));
      expect(tester.takeException(), isNull);
    });
  });

  group('los avisos viven en la franja de cifras (14.5; cierra O3)', () {
    for (final ventana in _ventanas) {
      for (final letra in _letras) {
        testWidgets(
            '${ventana.width.round()} × ${ventana.height.round()}, letra $letra: '
            'el aviso no sale de la franja ni de la columna', (tester) async {
          await t117Pump(tester,
              tamano: ventana, letra: letra, modo: BayPlanMode.discharge);
          final mensajero = tester.state<ScaffoldMessengerState>(
              find.byType(ScaffoldMessenger).first);
          mensajero.showSnackBar(avisoDelViaje(
            key: const ValueKey('aviso-de-la-oficina'),
            texto: 'Descarga registrada: TSTU 000001 1 en la celda 002-01-82, '
                'con su VGM y el muelle de la escala GTSTC.',
            corto: 'Descargado · TSTU0000011',
            accion: 'Deshacer',
            onAccion: () {},
            duracion: const Duration(seconds: 6),
          ));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 750));
          final aviso = tester.getRect(find
              .descendant(
                  of: find.byKey(const ValueKey('aviso-de-la-oficina')),
                  matching: find.byType(Material))
              .first);
          final franja = tester.getRect(_franjaDeCifras);
          final columna = tester.getRect(_columna);
          expect(aviso.top, greaterThanOrEqualTo(franja.top - 0.5),
              reason: 'no pasa del borde de arriba de la franja');
          expect(aviso.bottom, lessThanOrEqualTo(ventana.height));
          expect(aviso.left, greaterThanOrEqualTo(columna.left - 0.5),
              reason: 'no cruza el riel');
          expect(aviso.right, lessThanOrEqualTo(columna.right + 0.5),
              reason: 'no cruza el panel');
          expect(find.text('Deshacer').hitTestable(), findsOneWidget);
          // La franja de cifras está fuera de la columna que se desplaza: el
          // aviso no tapa celdas, la franja de la bahía ni controles.
          expect(
              aviso.top,
              greaterThanOrEqualTo(tester
                      .getRect(find.byKey(const ValueKey('columna-del-plano')))
                      .bottom -
                  0.5));
          expect(tester.takeException(), isNull);
          mensajero.clearSnackBars();
          await tester.pumpAndSettle();
        });
      }
    }

    testWidgets('fuera del Plano el aviso va al pie, a lo ancho de la columna',
        (tester) async {
      final scope = await t117Pump(tester);
      scope.read(destinoDelViajeProvider.notifier).ir(DestinoDelViaje.lista);
      await tester.pumpAndSettle();
      final mensajero = tester.state<ScaffoldMessengerState>(
          find.byType(ScaffoldMessenger).first);
      mensajero.showSnackBar(avisoDelViaje(
          key: const ValueKey('aviso-de-la-lista'), texto: 'Archivo cargado.'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));
      final aviso = tester.getRect(find
          .descendant(
              of: find.byKey(const ValueKey('aviso-de-la-lista')),
              matching: find.byType(Material))
          .first);
      final columna = tester.getRect(_columna);
      expect(aviso.left, greaterThanOrEqualTo(columna.left - 0.5));
      expect(aviso.right, lessThanOrEqualTo(columna.right + 0.5));
      mensajero.clearSnackBars();
      await tester.pumpAndSettle();
    });
  });

  group('Parámetros (14.3)', () {
    Future<ProviderContainer> parametros(
        WidgetTester tester, Size tamano, T117Equipo equipo) async {
      await t117CargarFuentes();
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = tamano;
      addTearDown(tester.view.reset);
      final scope = ProviderContainer(overrides: [
        localVesselRepositoryProvider.overrideWith((ref) async => equipo),
      ]);
      addTearDown(scope.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: scope,
        child: MaterialApp(
            theme: BayStreamTema.claro(), home: const ParametersPage()),
      ));
      await tester.pumpAndSettle();
      return scope;
    }

    final interruptor = find.byKey(const ValueKey('pref-panel-por-el-borde'));

    testWidgets('«Mostrar el panel lateral al pasar el mouse por el borde», '
        'encendido, se apaga y se guarda', (tester) async {
      final equipo = T117Equipo();
      await parametros(tester, const Size(1366, 768), equipo);
      expect(
          find.text('Mostrar el panel lateral al pasar el mouse por el borde'),
          findsOneWidget);
      expect(tester.widget<SwitchListTile>(interruptor).value, isTrue);
      await tester.tap(interruptor);
      await tester.pumpAndSettle();
      expect(tester.widget<SwitchListTile>(interruptor).value, isFalse);
      expect(equipo.guardadas[UiPreference.sidePanelOnHover], 'no');
    });

    testWidgets('en el teléfono no se ofrece: no hay oficina', (tester) async {
      await parametros(tester, const Size(360, 800), T117Equipo());
      expect(interruptor, findsNothing);
    });
  });
}
