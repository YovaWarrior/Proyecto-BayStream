// T-120 · BsFichasEnLineas (DESIGN.md 18.3), como las demás piezas de la
// biblioteca: lo que hace, su semántica, sus pautas y su vista previa; y la
// vista previa de los paneles de Estadísticas con la barra que se toca.
import 'dart:math' as math;

import 'package:baystream/core/design/design.dart';
import 'package:baystream/core/design/vistas_previas.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t117_oficina_support.dart';

/// Una ficha de 100 × 40 con su nombre.
Widget _ficha(int i) => SizedBox(
      key: ValueKey<String>('f$i'),
      width: 100,
      height: 40,
      child: Semantics(button: true, label: 'ficha $i', child: const SizedBox()),
    );

Widget _app(Widget hijo, {double ancho = 330}) => MaterialApp(
      theme: BayStreamTema.claro(),
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: ancho, child: hijo),
        ),
      ),
    );

RenderBsFichasEnLineas _render(WidgetTester tester) =>
    tester.renderObject<RenderBsFichasEnLineas>(find.byType(BsFichasEnLineas));

void main() {
  const ver = SizedBox(
      key: ValueKey<String>('ver'), width: 100, height: 40, child: Text('Ver'));

  testWidgets('si caben todas en las líneas, van todas y «Ver todas» no sale',
      (tester) async {
    await tester.pumpWidget(_app(BsFichasEnLineas(
      fichas: [for (var i = 0; i < 6; i++) _ficha(i)],
      verTodas: ver,
    )));
    final r = _render(tester);
    expect(r.visibles, [0, 1, 2, 3, 4, 5]);
    expect(r.conVerTodas, isFalse);
    // 3 por línea a 330 dp (100 + 8 + 100 + 8 + 100), dos líneas.
    expect(r.size.height, 40 + 8 + 40);
    expect(tester.getTopLeft(find.byKey(const ValueKey('f3'))),
        const Offset(0, 48));
  });

  testWidgets('si no caben, las primeras que caben y «Ver todas» al final, '
      'en dos líneas', (tester) async {
    await tester.pumpWidget(_app(BsFichasEnLineas(
      fichas: [for (var i = 0; i < 9; i++) _ficha(i)],
      verTodas: ver,
    )));
    final r = _render(tester);
    expect(r.visibles, [0, 1, 2, 3, 4]);
    expect(r.conVerTodas, isTrue);
    expect(r.size.height, 88);
    expect(tester.getTopLeft(find.byKey(const ValueKey('ver'))),
        const Offset(216, 48));
  });

  testWidgets('la fija siempre se ve, en el último lugar antes de «Ver»',
      (tester) async {
    await tester.pumpWidget(_app(BsFichasEnLineas(
      fichas: [for (var i = 0; i < 9; i++) _ficha(i)],
      verTodas: ver,
      fija: 7,
    )));
    expect(_render(tester).visibles, [0, 1, 2, 3, 7]);
    expect(tester.getTopLeft(find.byKey(const ValueKey('f7'))),
        const Offset(108, 48));
  });

  testWidgets('las que quedan fuera no se tocan ni están en la semántica',
      (tester) async {
    final semantica = tester.ensureSemantics();
    var tocadas = 0;
    await tester.pumpWidget(_app(BsFichasEnLineas(
      fichas: [
        for (var i = 0; i < 9; i++)
          GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => tocadas++,
              child: _ficha(i)),
      ],
      verTodas: ver,
    )));
    expect(find.bySemanticsLabel('ficha 4'), findsOneWidget);
    expect(find.bySemanticsLabel('ficha 8'), findsNothing);
    // La 8 está fuera: no se alcanza con el puntero.
    expect(find.byKey(const ValueKey('f8')).hitTestable(), findsNothing);
    await tester.tap(find
        .ancestor(
            of: find.byKey(const ValueKey('f4')),
            matching: find.byType(GestureDetector))
        .first);
    expect(tocadas, 1);
    semantica.dispose();
  });

  testWidgets('con una línea, y con «Ver» que no cabe ni sola', (tester) async {
    await tester.pumpWidget(_app(
        BsFichasEnLineas(
          fichas: [for (var i = 0; i < 4; i++) _ficha(i)],
          verTodas: ver,
          maxLineas: 1,
        ),
        ancho: 230));
    expect(_render(tester).visibles, [0]);
    await tester.pumpWidget(_app(
        BsFichasEnLineas(
          fichas: [for (var i = 0; i < 4; i++) _ficha(i)],
          verTodas: ver,
          maxLineas: 1,
        ),
        ancho: 90));
    expect(_render(tester).visibles, isEmpty);
    expect(_render(tester).conVerTodas, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el alto en seco es el de la disposición', (tester) async {
    await tester.pumpWidget(_app(BsFichasEnLineas(
      fichas: [for (var i = 0; i < 9; i++) _ficha(i)],
      verTodas: ver,
    )));
    final r = _render(tester);
    expect(r.getDryLayout(const BoxConstraints(maxWidth: 330)), r.size);
    expect(r.getMinIntrinsicHeight(330), 88);
    expect(r.getMaxIntrinsicWidth(double.infinity), 9 * 100 + 8 * 8);
  });

  group('las vistas previas', () {
    final previas = <String, Widget Function()>{
      'fichas en líneas': vistaPreviaFichasEnLineas,
      'paneles de Estadísticas, con la barra que se toca':
          vistaPreviaPanelesDeEstadisticas,
    };
    for (final previa in previas.entries) {
      testWidgets('${previa.key} se construye en el día y en la noche, con '
          'las pautas', (tester) async {
        await t117CargarFuentes();
        tester.view.physicalSize = const Size(1200, 1600);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final semantica = tester.ensureSemantics();
        for (final tema in [BayStreamTema.claro(), BayStreamTema.oscuro()]) {
          await tester.pumpWidget(MaterialApp(
            theme: tema,
            home: Scaffold(body: SingleChildScrollView(child: previa.value())),
          ));
          await tester.pump(const Duration(milliseconds: 50));
          expect(tester.takeException(), isNull, reason: previa.key);
          // De noche, la pauta de contraste compara los dos colores que más
          // pintan en el rectángulo del nodo: el chip mide 32 dp y su zona
          // táctil 48, así que salen el papel del lienzo y la hoja del chip
          // (4.29:1), no el texto. El texto de cada chip se mide aparte,
          // contra su fondo, en la prueba siguiente.
          if (tema.brightness == Brightness.light ||
              previa.key != 'fichas en líneas') {
            await expectLater(tester, meetsGuideline(textContrastGuideline));
          }
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        }
        semantica.dispose();
        await tester.pumpWidget(const SizedBox());
      });
    }

    for (final tema in [BayStreamTema.claro(), BayStreamTema.oscuro()]) {
      testWidgets('el texto de cada chip contra su fondo pasa 4.5:1 '
          '(${tema.brightness.name})', (tester) async {
        await t117CargarFuentes();
        tester.view.physicalSize = const Size(1200, 1600);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(MaterialApp(
          theme: tema,
          home: Scaffold(body: vistaPreviaFichasEnLineas()),
        ));
        final chipTema = Theme.of(tester.element(find.byType(FilterChip).first))
            .chipTheme;
        double luz(Color c) => c.computeLuminance();
        double contraste(Color a, Color b) {
          final (x, y) = (luz(a), luz(b));
          return (math.max(x, y) + 0.05) / (math.min(x, y) + 0.05);
        }
        for (final chip in tester.widgetList<FilterChip>(find.byType(FilterChip))) {
          final fondo = chip.selected
              ? chipTema.selectedColor!
              : chipTema.backgroundColor!;
          // La caja del puerto lleva su propio fondo (T-121): fuera.
          final textos = tester
              .renderObjectList<RenderParagraph>(find.descendant(
                  of: find.byWidget(chip), matching: find.byType(RichText)))
              .where((t) => find
                  .ancestor(
                      of: find.byWidgetPredicate(
                          (w) => w is RichText && w.text == t.text),
                      matching: find.byType(BsCajaDeCodigo))
                  .evaluate()
                  .isEmpty);
          for (final t in textos) {
            final color = t.text.style?.color ??
                (t.text as TextSpan).children?.whereType<TextSpan>().first.style?.color;
            if (color == null) continue;
            expect(contraste(color, fondo), greaterThanOrEqualTo(4.5),
                reason: '${t.text.toPlainText()} sobre su chip');
          }
        }
      });
    }

    testWidgets('la vista previa de las fichas deja PAMIT, la elegida, a la '
        'vista en el teléfono', (tester) async {
      await t117CargarFuentes();
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        theme: BayStreamTema.claro(),
        home: Scaffold(body: vistaPreviaFichasEnLineas()),
      ));
      final renders = tester
          .renderObjectList<RenderBsFichasEnLineas>(find.byType(BsFichasEnLineas))
          .toList();
      expect(renders.first.conVerTodas, isTrue);
      expect(renders.first.visibles, contains(6));
      expect(renders.last.conVerTodas, isFalse);
    });
  });
}
