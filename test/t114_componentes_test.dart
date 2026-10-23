// T-114 · Fase 2 del rediseño: los ocho componentes, en claro y en oscuro.
import 'package:baystream/core/design/design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _envuelve(Widget hijo, {bool oscuro = false, bool muelle = true}) =>
    MaterialApp(
      theme: BayStreamTema.claro(muelle: muelle),
      darkTheme: BayStreamTema.oscuro(muelle: muelle),
      themeMode: oscuro ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(body: Center(child: hijo)),
    );

void main() {
  group('BsCelda', () {
    testWidgets('muestra el código, mide al menos 56 × 48 y responde al toque',
        (tester) async {
      var toques = 0;
      await tester.pumpWidget(_envuelve(Builder(
        builder: (context) => BsCelda(
          codigo: 'GTSTC',
          linea2: '28.7',
          categoria: BsColoresSemanticos.de(context).categorico('GTSTC'),
          etiqueta: 'MSCU 123456 7, 002-01-82, GTSTC, 28.7 t',
          onTap: () => toques++,
        ),
      )));
      expect(find.text('GTSTC'), findsOneWidget);
      // En el muelle la segunda línea no se dibuja aunque venga (10.7, H2).
      expect(find.text('28.7'), findsNothing);
      final tamano = tester.getSize(find.byType(BsCelda));
      expect(tamano.width, greaterThanOrEqualTo(56));
      expect(tamano.height, greaterThanOrEqualTo(48));
      await tester.tap(find.byType(BsCelda));
      expect(toques, 1);
      expect(tester.getSemantics(find.byType(BsCelda)).label,
          'MSCU 123456 7, 002-01-82, GTSTC, 28.7 t');
    });

    testWidgets('la marca lleva icono y rótulo, no solo color', (tester) async {
      await tester.pumpWidget(_envuelve(const BsCelda(
        codigo: 'GTSTC',
        marca: BsMarcaDeCelda.baja,
        etiqueta: 'baja',
      )));
      expect(find.text('Baja'), findsOneWidget);
      expect(find.byIcon(BsIconos.descarga), findsOneWidget);
      expect(find.text('GTSTC'), findsNothing);
      await tester.pumpWidget(_envuelve(const BsCelda(
        codigo: 'GTSTC',
        marca: BsMarcaDeCelda.reestiba,
        etiqueta: 're-estiba',
      )));
      expect(find.text('Re‑estiba'), findsOneWidget);
      expect(find.byIcon(BsIconos.reestiba), findsOneWidget);
    });

    testWidgets('la insignia de carga especial va siempre, y atenuar no usa Opacity',
        (tester) async {
      await tester.pumpWidget(_envuelve(const BsCelda(
        codigo: 'USHOU',
        insignia: BsInsigniaDeCelda.peligrosa,
        atenuada: true,
        etiqueta: 'peligrosa, fuera del filtro',
      )));
      expect(find.byIcon(BsIconos.insigniaPeligrosa), findsOneWidget);
      expect(find.byType(Opacity), findsNothing);
    });

    testWidgets('en la oficina la celda sigue midiendo 48 de alto',
        (tester) async {
      await tester.pumpWidget(_envuelve(
        const BsCelda(codigo: 'GTSTC', etiqueta: 'celda'),
        muelle: false,
      ));
      final tamano = tester.getSize(find.byType(BsCelda));
      expect(tamano.height, greaterThanOrEqualTo(48));
      expect(tamano.width, greaterThanOrEqualTo(52));
    });

    // H2 de la aceptación de Codex (10.7): la segunda línea de 10 sp.
    for (final oscuro in [false, true]) {
      final modo = oscuro ? 'oscuro' : 'claro';
      testWidgets('en el muelle la segunda línea no se dibuja ni con zoom en $modo',
          (tester) async {
        for (final zoom in <double>[1.0, 2.0]) {
          await tester.pumpWidget(_envuelve(
            BsCelda(
              codigo: 'GTSTC',
              linea2: '28.7',
              zoom: zoom,
              etiqueta: 'Contenedor de prueba',
              onTap: () {},
            ),
            oscuro: oscuro,
          ));
          expect(find.text('GTSTC'), findsOneWidget);
          expect(find.text('28.7'), findsNothing, reason: 'zoom $zoom');
        }
      });

      testWidgets('en la oficina se dibuja con zoom de 100 % o más en $modo',
          (tester) async {
        for (final (zoom, visible) in <(double, bool)>[
          (1.0, true),
          (1.5, true),
          (0.99, false),
          (0.75, false),
        ]) {
          await tester.pumpWidget(_envuelve(
            BsCelda(
              codigo: 'GTSTC',
              linea2: '28.7',
              zoom: zoom,
              etiqueta: 'Contenedor de prueba',
              onTap: () {},
            ),
            oscuro: oscuro,
            muelle: false,
          ));
          expect(find.text('28.7'), visible ? findsOneWidget : findsNothing,
              reason: 'zoom $zoom');
          if (visible) {
            expect(tester.widget<Text>(find.text('28.7')).style?.fontSize, 10);
          }
        }
        // El zoom por omisión es 100 %.
        await tester.pumpWidget(_envuelve(
          BsCelda(codigo: 'GTSTC', linea2: '28.7', etiqueta: 'c', onTap: () {}),
          oscuro: oscuro,
          muelle: false,
        ));
        expect(find.text('28.7'), findsOneWidget);
      });
    }
    testWidgets('la segunda línea no se dibuja con marca ni cuando no cabe',
        (tester) async {
      await tester.pumpWidget(_envuelve(
        const BsCelda(
          codigo: 'GTSTC',
          linea2: '28.7',
          marca: BsMarcaDeCelda.baja,
          etiqueta: 'baja',
        ),
        muelle: false,
      ));
      expect(find.text('28.7'), findsNothing);
      expect(find.text('Baja'), findsOneWidget);
      // Con la letra a 1.45 cabe; a 2.0 no cabe y se oculta sin desbordar.
      for (final (escala, visible) in <(double, bool)>[(1.45, true), (2.0, false)]) {
        await tester.pumpWidget(_envuelve(
          MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(escala)),
            child: const BsCelda(
              codigo: 'GTSTC',
              linea2: '28.7',
              etiqueta: 'Contenedor de prueba',
            ),
          ),
          muelle: false,
        ));
        expect(tester.takeException(), isNull, reason: 'letra $escala');
        expect(find.text('28.7'), visible ? findsOneWidget : findsNothing,
            reason: 'letra $escala');
        expect(find.text('GTSTC'), findsOneWidget);
      }
    });

    testWidgets('con la letra a 2.0 ninguna marca desborda y el rótulo queda',
        (tester) async {
      for (final muelle in [true, false]) {
        for (final marca in BsMarcaDeCelda.values) {
          for (final resaltada in [false, true]) {
            await tester.pumpWidget(_envuelve(
              MediaQuery(
                data: const MediaQueryData(textScaler: TextScaler.linear(2)),
                child: BsCelda(
                  codigo: 'GTSTC',
                  linea2: '28.7',
                  marca: marca,
                  resaltada: resaltada,
                  insignia: BsInsigniaDeCelda.peligrosa,
                  etiqueta: 'marca ${marca.name}',
                ),
              ),
              muelle: muelle,
            ));
            expect(tester.takeException(), isNull,
                reason: '${marca.name}, resaltada $resaltada, muelle $muelle');
            expect(find.byType(Text), findsOneWidget);
          }
        }
      }
    });
  });

  group('BsTiraDeBahias', () {
    testWidgets('dibuja una casilla de 48 por bahía y selecciona al tocar',
        (tester) async {
      int? seleccionada;
      await tester.pumpWidget(_envuelve(BsTiraDeBahias(
        bahias: const [
          BsBahiaDeTira(numero: 1, ocupacion: 0.2),
          BsBahiaDeTira(numero: 2, ocupacion: 0.9),
          BsBahiaDeTira(numero: 3),
        ],
        seleccionada: 2,
        onSeleccion: (bahia) => seleccionada = bahia,
      )));
      expect(find.text('01'), findsOneWidget);
      expect(find.text('02'), findsOneWidget);
      expect(tester.getSize(find.ancestor(
            of: find.text('03'),
            matching: find.byType(InkWell),
          ).first).width, greaterThanOrEqualTo(48));
      await tester.tap(find.text('03'));
      expect(seleccionada, 3);
      expect(find.byType(RepaintBoundary), findsWidgets);
    });

    testWidgets('la etiqueta dice la ocupación o que no hay geometría',
        (tester) async {
      await tester.pumpWidget(_envuelve(BsTiraDeBahias(
        bahias: const [
          BsBahiaDeTira(numero: 2, ocupacion: 0.91),
          BsBahiaDeTira(numero: 4),
        ],
        onSeleccion: (_) {},
      )));
      expect(find.bySemanticsLabel('Bahía 02, 91 % de ocupación'),
          findsOneWidget);
      expect(find.bySemanticsLabel('Bahía 04, sin geometría'), findsOneWidget);
    });
  });

  group('BsCartela', () {
    testWidgets('título, cifras y leyenda que envuelve, con toque para resaltar',
        (tester) async {
      var toques = 0;
      await tester.pumpWidget(_envuelve(Builder(
        builder: (context) => BsCartela(
          titulo: 'Bahía 02',
          cifras: const [
            BsCifraDeCartela(rotulo: 'Contenedores', valor: '63'),
            BsCifraDeCartela(rotulo: 'Peso', valor: '416.8 t'),
          ],
          leyenda: [
            BsEntradaDeLeyenda(
              rotulo: 'GTSTC',
              cuenta: 120,
              rol: BsColoresSemanticos.de(context).categorico('GTSTC'),
              onTap: () => toques++,
            ),
            const BsEntradaDeLeyenda(
                rotulo: 'Refrigerado', cuenta: 12, icono: Icons.ac_unit),
          ],
          nota: 'Peso por pila: sin evaluar hasta confirmar el perfil.',
        ),
      )));
      expect(find.text('Bahía 02'), findsOneWidget);
      expect(find.text('63'), findsOneWidget);
      expect(find.text('Refrigerado'), findsOneWidget);
      expect(find.text('Peso por pila: sin evaluar hasta confirmar el perfil.'),
          findsOneWidget);
      expect(find.byType(Wrap), findsWidgets);
      expect(find.byType(SingleChildScrollView), findsNothing);
      await tester.tap(find.text('GTSTC'));
      expect(toques, 1);
      expect(find.bySemanticsLabel('GTSTC, 120'), findsOneWidget);
    });
  });

  group('BsBanda', () {
    testWidgets('texto, acción con el mismo nombre que lo que hace y cerrar',
        (tester) async {
      var confirmaciones = 0;
      var cierres = 0;
      await tester.pumpWidget(_envuelve(BsBanda(
        texto: 'Plano sin confirmar. Escala propuesta GTSTC.',
        accion: 'Confirmar',
        onAccion: () => confirmaciones++,
        onCerrar: () => cierres++,
      )));
      expect(find.text('Plano sin confirmar. Escala propuesta GTSTC.'),
          findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      await tester.tap(find.text('Confirmar'));
      await tester.tap(find.byTooltip('Cerrar el aviso'));
      expect(confirmaciones, 1);
      expect(cierres, 1);
    });

    testWidgets('cada tono trae su icono', (tester) async {
      for (final (tono, icono) in [
        (BsTonoDeBanda.aviso, Icons.warning_amber_rounded),
        (BsTonoDeBanda.error, Icons.error_outline),
        (BsTonoDeBanda.confirmacion, Icons.check_circle_outline),
      ]) {
        await tester.pumpWidget(_envuelve(BsBanda(texto: 'x', tono: tono)));
        expect(find.byIcon(icono), findsOneWidget, reason: tono.name);
      }
    });
  });

  group('BsCifra', () {
    testWidgets('cifra, rótulo, detalle y barra de progreso', (tester) async {
      await tester.pumpWidget(_envuelve(const BsCifra(
        valor: '120 de 150',
        rotulo: 'Descargados',
        detalle: '80 %',
        progreso: 0.8,
      )));
      expect(find.text('120 de 150'), findsOneWidget);
      expect(find.text('Descargados'), findsOneWidget);
      expect(find.text('80 %'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.bySemanticsLabel('Descargados: 120 de 150, 80 %'),
          findsOneWidget);
      await tester.pumpWidget(_envuelve(const BsCifra(valor: '3', rotulo: 'x')));
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });
  });

  group('BsHojaDeDetalle', () {
    const hoja = BsHojaDeDetalle(
      titulo: BsNumeroDeContenedor('MSCU1234567'),
      subtitulo: 'Lleno',
      filas: [
        BsFilaDeDetalle('Posición', 'Bahía 002, Fila 01, Nivel 82'),
        BsFilaDeDetalle('VGM', '28 650 kg'),
      ],
      secciones: [Text('Sección extra')],
      acciones: [Text('Acción')],
    );

    testWidgets('muestra título, filas, secciones, acciones y Cerrar',
        (tester) async {
      await tester.pumpWidget(_envuelve(hoja));
      expect(find.text('MSCU 123456 7'), findsOneWidget);
      expect(find.text('Lleno'), findsOneWidget);
      expect(find.text('Bahía 002, Fila 01, Nivel 82'), findsOneWidget);
      expect(find.text('Sección extra'), findsOneWidget);
      expect(find.text('Acción'), findsOneWidget);
      expect(find.text('Cerrar'), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('con letra 2.0 a 360 dp nada desborda', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        theme: BayStreamTema.claro(muelle: true),
        home: const MediaQuery(
          data: MediaQueryData(
            size: Size(360, 800),
            textScaler: TextScaler.linear(2),
          ),
          child: Scaffold(body: hoja),
        ),
      ));
      expect(tester.takeException(), isNull);
      expect(find.text('28 650 kg'), findsOneWidget);
    });

    testWidgets('se abre desde abajo y Cerrar la cierra', (tester) async {
      await tester.pumpWidget(_envuelve(Builder(
        builder: (context) => FilledButton(
          onPressed: () => BsHojaDeDetalle.mostrar<void>(
            context,
            constructor: (context, controlador) => BsHojaDeDetalle(
              titulo: const BsNumeroDeContenedor('MSCU1234567'),
              controlador: controlador,
              filas: const [BsFilaDeDetalle('Posición', '002-01-82')],
            ),
          ),
          child: const Text('Abrir'),
        ),
      )));
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      expect(find.text('MSCU 123456 7'), findsOneWidget);
      await tester.tap(find.text('Cerrar'));
      await tester.pumpAndSettle();
      expect(find.text('MSCU 123456 7'), findsNothing);
    });
  });

  group('BsBarraDeOperacion', () {
    testWidgets('contadores, aviso con Deshacer y acción', (tester) async {
      var deshechos = 0;
      await tester.pumpWidget(_envuelve(BsBarraDeOperacion(
        contadores: const [
          BsContador(valor: '18', rotulo: 'por bajar'),
          BsContador(valor: '6', rotulo: 'hechas'),
        ],
        aviso: BsAvisoDeOperacion(
          texto: 'Descarga registrada, MSCU 123456 7',
          accion: 'Deshacer',
          onAccion: () => deshechos++,
        ),
        accion: OutlinedButton(onPressed: () {}, child: const Text('Pendientes')),
      )));
      expect(find.text('18'), findsOneWidget);
      expect(find.text('hechas'), findsOneWidget);
      expect(find.text('Pendientes'), findsOneWidget);
      await tester.tap(find.text('Deshacer'));
      expect(deshechos, 1);
    });
  });

  group('BsNumeroDeContenedor', () {
    testWidgets('agrupa el número y lo pone en mono con cifras tabulares',
        (tester) async {
      await tester.pumpWidget(_envuelve(const BsNumeroDeContenedor('MSCU1234567')));
      final texto = tester.widget<Text>(find.text('MSCU 123456 7'));
      expect(texto.style?.fontFamily, BsFuentes.mono);
      expect(texto.style?.fontFeatures, contains(const FontFeature.tabularFigures()));
      expect(texto.semanticsLabel, 'MSCU 123456 7');
    });
  });
}
