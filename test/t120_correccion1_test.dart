// T-120, entrega 1, corrección 1 (10.149): lo que la revisión de Yov leyó en
// el código y ni las pruebas ni las capturas vieron.
//   R1 · de noche, el ícono del chip elegido de «Carga especial» desaparece;
//   R2 · dos motivos de un mismo resultado del buscador con la misma clave;
//   R3 · los chips que BsFichasEnLineas no enseña reciben el foco;
//   D9 · desde Estadísticas, la Lista se abre con su título arriba;
//   D10 · el panel de puertos dice a la vista que sus barras se tocan.
//
// Solo usa piezas que ya estaban en la entrega 1 (02169fc), para correr
// también contra ella (las rojas). Buque y contenedores sintéticos (TSTU).
import 'dart:math' as math;

import 'package:baystream/core/design/design.dart';
import 'package:baystream/features/vessel/domain/entities/dangerous_goods.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/container_search_delegate.dart';
import 'package:baystream/features/vessel/presentation/widgets/navegacion_del_viaje.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t120_lista_support.dart';
import 'support/t117_oficina_support.dart';
import 'support/t121_estadisticas_support.dart';

Future<void> _tocar(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

double _contraste(Color a, Color b) {
  final (x, y) = (a.computeLuminance(), b.computeLuminance());
  return (math.max(x, y) + 0.05) / (math.min(x, y) + 0.05);
}

/// Si [objeto] está dentro de una ficha que `BsFichasEnLineas` no enseña.
bool _enFichaOculta(RenderObject? objeto) {
  var hijo = objeto;
  var padre = objeto?.parent;
  while (padre != null) {
    if (padre is RenderBsFichasEnLineas) {
      final datos = (hijo! as RenderBox).parentData;
      return datos is DatosDeLaFicha && !datos.visible;
    }
    hijo = padre;
    padre = padre.parent;
  }
  return false;
}

Finder _barra(String inicio) => find.descendant(
    of: find.byKey(const ValueKey('estadisticas-puertos')),
    matching: find.bySemanticsLabel(RegExp('^${RegExp.escape(inicio)}[: ]')));

void main() {
  group('R1 · el texto y el ícono de cada chip elegido se leen', () {
    for (final oscuro in [false, true]) {
      testWidgets(
          'con una naviera, un destino y las tres cargas elegidas '
          '(${oscuro ? 'noche' : 'día'}): el texto a 4.5:1 y el ícono a 3:1',
          (tester) async {
        final scope = await t120Pump(tester, oscuro: oscuro);
        // Primero las cargas: elegidas, siguen activas aunque los otros
        // filtros las dejen en cero.
        for (final clave in ['peligrosa', 'refrigerado', 'fueraDeMedida']) {
          await _tocar(tester, t120Chip('carga', clave));
        }
        scope.read(selectedCarrierProvider.notifier).select('LNA');
        scope.read(selectedDischargePortProvider.notifier).select('GTSTC');
        await tester.pumpAndSettle();
        final chipTema =
            Theme.of(tester.element(t120Chip('carga', 'peligrosa'))).chipTheme;
        var iconos = 0;
        var textos = 0;
        for (final chip in tester.widgetList<FilterChip>(find.byType(FilterChip))) {
          if (chip.onSelected == null) continue;
          final fondo =
              chip.selected ? chipTema.selectedColor! : chipTema.backgroundColor!;
          for (final e in find
              .descendant(of: find.byWidget(chip), matching: find.byType(RichText))
              .evaluate()) {
            final enCaja = find
                .ancestor(
                    of: find.byWidget(e.widget),
                    matching: find.byType(BsCajaDeCodigo))
                .evaluate()
                .isNotEmpty;
            if (enCaja) continue;
            final esIcono = find
                .ancestor(of: find.byWidget(e.widget), matching: find.byType(Icon))
                .evaluate()
                .isNotEmpty;
            final parrafo = e.renderObject! as RenderParagraph;
            final color = esIcono
                ? (parrafo.text as TextSpan).style!.color!
                : parrafo.text.style!.color!;
            final minimo = esIcono ? 3.0 : 4.5;
            expect(_contraste(color, fondo), greaterThanOrEqualTo(minimo),
                reason: '${esIcono ? 'el ícono' : '«${parrafo.text.toPlainText()}»'} '
                    'de ${chip.key}, ${chip.selected ? 'elegido' : 'sin elegir'}');
            if (esIcono) {
              iconos++;
            } else {
              textos++;
            }
          }
        }
        expect(iconos, 3, reason: 'los tres chips de carga llevan su ícono');
        expect(textos, greaterThan(10));
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('R2 · un resultado con dos cargas', () {
    testWidgets('«reefer imo» con un refrigerado peligroso: los dos motivos a '
        'la vista y ninguna excepción', (tester) async {
      final doble = ContainerUnit(
        id: 'd',
        containerId: 'TSTU0000099',
        portOfDischarge: 'GTSTC',
        isReefer: true,
        temperature: -18,
        temperatureUnit: 'C',
        isDangerous: true,
        imdgClass: '3',
        unNumber: '1993',
        dangerousGoods: [DangerousGoods(hazardClass: '3', unNumber: '1993')],
      );
      await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
          theme: BayStreamTema.claro(),
          home: Consumer(builder: (context, ref, _) {
            return Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showSearch<ContainerUnit?>(
                    context: context,
                    query: 'reefer imo',
                    delegate:
                        ContainerSearchDelegate(containers: [doble], ref: ref),
                  ),
                  child: const Text('abrir'),
                ),
              ),
            );
          }),
        ),
      ));
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Refrigerado, ${menos}18$espacioDuro°C'), findsOneWidget);
      expect(find.text('Peligrosa IMDG, IMO 3, UN 1993'), findsOneWidget);
    });
  });

  group('R3 · el foco no cae en una ficha que no se ve', () {
    testWidgets('a 360 dp, con Tab por toda la Lista, el foco nunca cae en un '
        'chip oculto', (tester) async {
      final scope = await t120Pump(tester, tamano: const Size(360, 800));
      final destinos = tester
          .renderObjectList<RenderBsFichasEnLineas>(find.byType(BsFichasEnLineas))
          .elementAt(1);
      expect(destinos.conVerTodas, isTrue, reason: 'la fila de destinos no cabe');
      var enChips = 0;
      for (var i = 0; i < 80; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        final foco = FocusManager.instance.primaryFocus?.context?.findRenderObject();
        expect(_enFichaOculta(foco), isFalse, reason: 'Tab número ${i + 1}');
        if (foco != null &&
            find
                .ancestor(
                    of: find.byElementPredicate(
                        (e) => e.renderObject == foco),
                    matching: find.byType(FilterChip))
                .evaluate()
                .isNotEmpty) {
          enChips++;
        }
      }
      expect(enChips, greaterThan(0), reason: 'Tab sí recorre los chips que se ven');
      expect(scope.read(selectedDischargePortProvider), isNull);
    });

    testWidgets('un chip oculto no toma el foco, ni Intro ni espacio lo activan',
        (tester) async {
      final scope = await t120Pump(tester, tamano: const Size(360, 800));
      final oculto = find.byWidgetPredicate((w) {
        if (w is! FilterChip) return false;
        final clave = (w.key! as ValueKey<String>).value;
        return clave.startsWith('filtro-destino-');
      }).evaluate().firstWhere((e) => _enFichaOculta(e.renderObject));
      final clave = (oculto.widget.key! as ValueKey<String>).value;
      final texto = find
          .descendant(of: find.byWidget(oculto.widget), matching: find.byType(Text))
          .first;
      Focus.of(tester.element(texto)).requestFocus();
      await tester.pump();
      final foco = FocusManager.instance.primaryFocus?.context?.findRenderObject();
      expect(_enFichaOculta(foco), isFalse, reason: '$clave tomó el foco');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(scope.read(selectedDischargePortProvider), isNull,
          reason: '$clave se activó sin verse');
    });
  });

  group('Al mirar · el texto de ayuda del buscador cabe en el teléfono', () {
    for (final letra in [1.0, 1.45]) {
      testWidgets('a 360 dp con la letra a $letra, con las fuentes del producto',
          (tester) async {
        await t117CargarFuentes();
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        tester.platformDispatcher.textScaleFactorTestValue = letra;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        late ContainerSearchDelegate delegado;
        await tester.pumpWidget(ProviderScope(
          child: MaterialApp(
            theme: BayStreamTema.claro(muelle: true),
            home: Consumer(builder: (context, ref, _) {
              delegado = ContainerSearchDelegate(containers: const [], ref: ref);
              return Scaffold(
                body: Builder(
                  builder: (context) => TextButton(
                    onPressed: () => showSearch<ContainerUnit?>(
                        context: context, delegate: delegado),
                    child: const Text('abrir'),
                  ),
                ),
              );
            }),
          ),
        ));
        await tester.tap(find.text('abrir'));
        await tester.pumpAndSettle();
        final ayuda = delegado.searchFieldLabel!;
        final parrafos = tester
            .renderObjectList<RenderParagraph>(find.byType(RichText))
            .where((p) => p.text.toPlainText() == ayuda)
            .toList();
        expect(parrafos, isNotEmpty, reason: 'el campo muestra «$ayuda»');
        for (final p in parrafos) {
          expect(p.didExceedMaxLines, isFalse, reason: '«$ayuda» se corta');
        }
      });
    }
  });

  group('Al mirar · desde la página, la ayuda que cabe', () {
    for (final (letra, ayuda) in [
      (1.0, 'Matrícula, puerto o carga'),
      (1.45, 'Matrícula, puerto o carga'),
      (2.0, 'Buscar'),
    ]) {
      testWidgets('a 360 dp con la letra a $letra dice «$ayuda» y no se corta',
          (tester) async {
        await t120Pump(tester, tamano: const Size(360, 800), letra: letra);
        await tester.tap(find.byKey(const ValueKey('buscar-contenedor')));
        await tester.pumpAndSettle();
        final parrafos = tester
            .renderObjectList<RenderParagraph>(find.byType(RichText))
            .where((p) => p.text.toPlainText() == ayuda)
            .toList();
        expect(parrafos, isNotEmpty);
        for (final p in parrafos) {
          expect(p.didExceedMaxLines, isFalse, reason: '«$ayuda» se corta');
        }
      });
    }
  });

  group('D9 y D10 · de Estadísticas a la Lista', () {
    testWidgets('desde una barra, la Lista se abre con su título arriba y las '
        'tarjetas debajo', (tester) async {
      final semantica = tester.ensureSemantics();
      final scope = await t120Pump(tester,
          tamano: const Size(360, 800), pestana: DestinoDelViaje.estadisticas);
      await _tocar(tester, _barra('PAMIT'));
      expect(scope.read(destinoDelViajeProvider), DestinoDelViaje.lista);
      final pamit = t120Viaje()
          .containers
          .where((c) => c.portOfDischarge == 'PAMIT')
          .length;
      final titulo = find.text('Contenedores ($pamit), destino PAMIT');
      expect(titulo, findsOneWidget);
      final lista = tester.getRect(find.byKey(const ValueKey('lista-scroll')));
      final arriba = tester.getTopLeft(titulo).dy - lista.top;
      expect(arriba, inInclusiveRange(0, 24), reason: 'el título, arriba');
      expect(t120Tarjetas().hitTestable(), findsWidgets,
          reason: 'y las tarjetas debajo, a la vista');
      semantica.dispose();
    });

    testWidgets('la entrada por la barra no cambia: la Lista recuerda dónde '
        'estaba', (tester) async {
      final scope = await t120Pump(tester);
      final lista = tester.state<ScrollableState>(find
          .descendant(
              of: find.byKey(const ValueKey('lista-scroll')),
              matching: find.byType(Scrollable))
          .first);
      lista.position.jumpTo(700);
      await tester.pumpAndSettle();
      scope.read(destinoDelViajeProvider.notifier).ir(DestinoDelViaje.plano);
      await tester.pumpAndSettle();
      scope.read(destinoDelViajeProvider.notifier).ir(DestinoDelViaje.lista);
      await tester.pumpAndSettle();
      expect(
          tester
              .state<ScrollableState>(find
                  .descendant(
                      of: find.byKey(const ValueKey('lista-scroll')),
                      matching: find.byType(Scrollable))
                  .first)
              .position
              .pixels,
          700);
    });

    testWidgets('el panel de puertos dice que sus barras se tocan', (tester) async {
      await t120Pump(tester, pestana: DestinoDelViaje.estadisticas);
      expect(
          find.descendant(
              of: find.byKey(const ValueKey('estadisticas-puertos')),
              matching: find.text('Toca un puerto para verlo en la Lista')),
          findsOneWidget);
    });

    testWidgets('sin onPuerto, la línea no sale', (tester) async {
      await t121Pump(tester, voyage: t120Viaje());
      expect(find.text('Toca un puerto para verlo en la Lista'), findsNothing);
    });
  });
}
