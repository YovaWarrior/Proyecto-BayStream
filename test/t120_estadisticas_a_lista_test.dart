// T-120 (10.46) · Desde Estadísticas, tocar un puerto abre la Lista filtrada
// por ese destino (DESIGN.md 15.5 y 18.5); «Sin destino» es un solo nombre en
// las dos pantallas (D6 de la 10.148); Atrás vuelve una vez; las dos
// pantallas recuerdan dónde estaban.
//
// Solo usa claves, textos y providers que ya existían antes de T-120, más
// el destino elegido, para correr también contra el código de antes.
// Buque sintético (BUQUE LISTA, TSTU); sin nube ni almacén real.
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/navegacion_del_viaje.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t120_lista_support.dart';

Finder _barra(String inicio) => find.descendant(
    of: find.byKey(const ValueKey('estadisticas-puertos')),
    matching: find.bySemanticsLabel(RegExp('^${RegExp.escape(inicio)}[: ]')));

ScrollableState _scroll(WidgetTester tester, String clave) =>
    tester.state<ScrollableState>(find.descendant(
        of: find.byKey(ValueKey<String>(clave)),
        matching: find.byType(Scrollable)).first);

void main() {
  final todos = t120Viaje().containers;

  testWidgets('tocar GTSTC abre la Lista filtrada, sin naviera ni carga',
      (tester) async {
    final semantica = tester.ensureSemantics();
    final scope =
        await t120Pump(tester, pestana: DestinoDelViaje.estadisticas);
    scope.read(selectedCarrierProvider.notifier).select('LNA');
    await tester.pumpAndSettle();
    await tester.ensureVisible(_barra('GTSTC'));
    await tester.pumpAndSettle();
    await tester.tap(_barra('GTSTC'));
    await tester.pumpAndSettle();
    expect(scope.read(destinoDelViajeProvider), DestinoDelViaje.lista);
    expect(scope.read(selectedCarrierProvider), isNull);
    final gtstc = todos.where((c) => c.portOfDischarge == 'GTSTC').length;
    expect(find.text('Contenedores ($gtstc), destino GTSTC'), findsOneWidget);
    semantica.dispose();
  });

  testWidgets('«Sin destino» se llama igual en las dos pantallas y lleva a su '
      'chip', (tester) async {
    final semantica = tester.ensureSemantics();
    final scope = await t120Pump(tester,
        voyage: t120ViajeDePocosPuertos(),
        pestana: DestinoDelViaje.estadisticas);
    expect(find.bySemanticsLabel(RegExp('^Sin puerto')), findsNothing);
    await tester.ensureVisible(_barra('Sin destino'));
    await tester.pumpAndSettle();
    await tester.tap(_barra('Sin destino'));
    await tester.pumpAndSettle();
    expect(scope.read(destinoDelViajeProvider), DestinoDelViaje.lista);
    expect(find.text('Contenedores (1), sin destino'), findsOneWidget);
    semantica.dispose();
  });

  testWidgets('«Otros N puertos» junta varios y no se toca', (tester) async {
    final semantica = tester.ensureSemantics();
    await t120Pump(tester, pestana: DestinoDelViaje.estadisticas);
    final otros = tester.getSemantics(_barra('Otros'));
    expect(otros, isNot(containsSemantics(hasTapAction: true)));
    final gtstc = tester.getSemantics(_barra('GTSTC'));
    expect(gtstc, containsSemantics(isButton: true, hasTapAction: true));
    // El nombre, una vez: la ayuda va en la descripción emergente, fuera.
    expect(RegExp('GTSTC').allMatches('${gtstc.label} ${gtstc.tooltip}'),
        hasLength(1));
    semantica.dispose();
  });

  testWidgets('con el teclado: Intro sobre la barra abre la Lista',
      (tester) async {
    final scope =
        await t120Pump(tester, pestana: DestinoDelViaje.estadisticas);
    final barra = find.ancestor(
        of: find.text('USHOU').first, matching: find.byType(InkWell)).first;
    await tester.ensureVisible(barra);
    await tester.pumpAndSettle();
    Focus.of(tester.element(find
            .descendant(of: barra, matching: find.byType(ConstrainedBox))
            .first))
        .requestFocus();
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(scope.read(destinoDelViajeProvider), DestinoDelViaje.lista);
    final ushou = t120Viaje()
        .containers
        .where((c) => c.portOfDischarge == 'USHOU')
        .length;
    expect(find.text('Contenedores ($ushou), destino USHOU'), findsOneWidget);
  });

  testWidgets('Atrás de Android vuelve a Estadísticas una vez; el siguiente '
      'es el primero del doble Atrás', (tester) async {
    final semantica = tester.ensureSemantics();
    final scope = await t120Pump(tester,
        tamano: const Size(360, 800), pestana: DestinoDelViaje.estadisticas);
    await tester.ensureVisible(_barra('PAMIT'));
    await tester.pumpAndSettle();
    await tester.tap(_barra('PAMIT'));
    await tester.pumpAndSettle();
    expect(scope.read(destinoDelViajeProvider), DestinoDelViaje.lista);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(scope.read(destinoDelViajeProvider), DestinoDelViaje.estadisticas);
    expect(find.byKey(const ValueKey('aviso-de-atras')), findsNothing);
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byKey(const ValueKey('aviso-de-atras')), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    semantica.dispose();
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('si se cambia el filtro en la Lista, Atrás ya no vuelve',
      (tester) async {
    final semantica = tester.ensureSemantics();
    final scope = await t120Pump(tester,
        tamano: const Size(360, 800), pestana: DestinoDelViaje.estadisticas);
    await tester.ensureVisible(_barra('PAMIT'));
    await tester.pumpAndSettle();
    await tester.tap(_barra('PAMIT'));
    await tester.pumpAndSettle();
    scope.read(selectedCarrierProvider.notifier).select('LNB');
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(scope.read(destinoDelViajeProvider), DestinoDelViaje.lista);
    expect(find.byKey(const ValueKey('aviso-de-atras')), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    semantica.dispose();
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('la Lista recuerda dónde estaba y, desde Estadísticas, se abre '
      'con su título arriba (D9, 10.149)', (tester) async {
    final semantica = tester.ensureSemantics();
    final scope = await t120Pump(tester);
    _scroll(tester, 'lista-scroll').position.jumpTo(900);
    await tester.pumpAndSettle();
    scope.read(destinoDelViajeProvider.notifier).ir(DestinoDelViaje.plano);
    await tester.pumpAndSettle();
    scope.read(destinoDelViajeProvider.notifier).ir(DestinoDelViaje.lista);
    await tester.pumpAndSettle();
    expect(_scroll(tester, 'lista-scroll').position.pixels, 900);

    scope.read(destinoDelViajeProvider.notifier).ir(DestinoDelViaje.estadisticas);
    await tester.pumpAndSettle();
    await tester.ensureVisible(_barra('USHOU'));
    await tester.pumpAndSettle();
    await tester.tap(_barra('USHOU'));
    await tester.pumpAndSettle();
    // Antes de D9 empezaba arriba, en el resumen del viaje (0); ahora el
    // título queda arriba de lo que se ve.
    final ushou = t120Viaje()
        .containers
        .where((c) => c.portOfDischarge == 'USHOU')
        .length;
    final titulo = find.text('Contenedores ($ushou), destino USHOU');
    final lista = tester.getRect(find.byKey(const ValueKey('lista-scroll')));
    expect(tester.getTopLeft(titulo).dy - lista.top, inInclusiveRange(0, 24));
    semantica.dispose();
  });

  testWidgets('Estadísticas recuerda dónde estaba al volver de la Lista',
      (tester) async {
    final scope =
        await t120Pump(tester, pestana: DestinoDelViaje.estadisticas);
    _scroll(tester, 'estadisticas-scroll').position.jumpTo(300);
    await tester.pumpAndSettle();
    scope.read(destinoDelViajeProvider.notifier).ir(DestinoDelViaje.lista);
    await tester.pumpAndSettle();
    scope.read(destinoDelViajeProvider.notifier).ir(DestinoDelViaje.estadisticas);
    await tester.pumpAndSettle();
    expect(_scroll(tester, 'estadisticas-scroll').position.pixels, 300);
  });
}
