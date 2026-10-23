// T-114 · Fase 2 bis: las piezas nuevas de la dirección C (DESIGN.md 13.6):
// qué dibujan, qué dicen al lector de pantalla, las tres pautas de
// accesibilidad de Flutter en el día y en la noche, y que con
// `disableAnimations` nada se mueve (13.3).
import 'package:baystream/core/design/design.dart';
import 'package:baystream/core/design/vistas_previas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Los temas se construyen una sola vez: un `ThemeData` nuevo en cada `pump`
// (aunque sea igual) hace que `AnimatedTheme` interpole 200 ms y confunde las
// comprobaciones de «nada se mueve».
final Map<bool, ThemeData> _claro = <bool, ThemeData>{};
final Map<bool, ThemeData> _oscuro = <bool, ThemeData>{};

Widget _envuelve(Widget hijo,
        {bool oscuro = false, bool muelle = true, bool sinMovimiento = false}) =>
    MaterialApp(
      theme: _claro.putIfAbsent(muelle, () => BayStreamTema.claro(muelle: muelle)),
      darkTheme: _oscuro.putIfAbsent(muelle, () => BayStreamTema.oscuro(muelle: muelle)),
      themeMode: oscuro ? ThemeMode.dark : ThemeMode.light,
      builder: (BuildContext context, Widget? child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: sinMovimiento),
        child: child!,
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(padding: const EdgeInsets.all(16), child: hijo),
        ),
      ),
    );

List<BsBahiaDeSilueta> _bahias() => <BsBahiaDeSilueta>[
      for (var i = 0; i < 6; i++)
        BsBahiaDeSilueta(
          numero: 2 + 4 * i,
          nivelesCubierta: 2 + i % 3,
          nivelesBodega: 3,
          avance: i < 2 ? 1.0 : (i == 2 ? 0.25 : null),
          conTrabajo: i >= 2 && i <= 4,
        ),
    ];

List<BsEventoEnVivo> _eventos({VoidCallback? onRevisar}) => <BsEventoEnVivo>[
      const BsEventoEnVivo(
        que: 'Bajado',
        quien: BsEquipo.muelle,
        detalle: 'TSTU 004218 0 · 014-01-86',
        tipo: BsTipoDeEvento.hecho,
        momento: 'hace 1 min',
      ),
      BsEventoEnVivo(
        que: 'Cambio pedido',
        quien: BsEquipo.muelle,
        detalle: 'TSTU 020493 3 · 014-03-84',
        tipo: BsTipoDeEvento.aviso,
        accion: 'Revisar',
        onAccion: onRevisar ?? () {},
      ),
      const BsEventoEnVivo(
        que: 'Re‑estiba aprobada',
        quien: BsEquipo.oficina,
        detalle: 'TSTU 031167 5 · 018-07-84 → 018-05-86',
        tipo: BsTipoDeEvento.aprobado,
        momento: 'hace 9 min',
      ),
    ];

void main() {
  group('BsMarca', () {
    testWidgets('se pinta en sus tres variantes y dice quién es', (tester) async {
      final semantica = tester.ensureSemantics();
      await tester.pumpWidget(_envuelve(const Row(children: <Widget>[
        BsMarca(tamano: 44),
        BsMarca(tamano: 44, variante: BsVarianteDeMarca.sinRecuadro),
        BsMarca(tamano: 44, variante: BsVarianteDeMarca.monocroma),
      ])));
      expect(find.byType(BsMarca), findsNWidgets(3));
      expect(find.descendant(of: find.byType(BsMarca), matching: find.byType(CustomPaint)),
          findsNWidgets(3));
      expect(find.descendant(of: find.byType(BsMarca), matching: find.byType(RepaintBoundary)),
          findsNWidgets(3));
      expect(tester.getSize(find.byType(BsMarca).first), const Size(44, 44));
      expect(tester.getSemantics(find.byType(BsMarca).first).label, 'BayStream');
      expect(tester.hasRunningAnimations, isFalse, reason: 'sin espera, quieta');
      semantica.dispose();
    });

    testWidgets('en espera, el contenedor se mueve; con reducción de movimiento, no',
        (tester) async {
      final semantica = tester.ensureSemantics();
      await tester.pumpWidget(_envuelve(const BsMarca(tamano: 52, espera: true)));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.hasRunningAnimations, isTrue);
      expect(tester.getSemantics(find.byType(BsMarca)).label, 'BayStream, leyendo');
      await tester.pumpWidget(_envuelve(const BsMarca(tamano: 52, espera: true),
          sinMovimiento: true));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.hasRunningAnimations, isFalse);
      semantica.dispose();
    });
  });

  group('BsSiluetaBuque', () {
    testWidgets('pinta el casco y una pila por bahía, con toque y etiqueta',
        (tester) async {
      final semantica = tester.ensureSemantics();
      int? elegida;
      await tester.pumpWidget(_envuelve(BsSiluetaBuque(
        bahias: _bahias(),
        seleccionada: 10,
        onSeleccion: (int bahia) => elegida = bahia,
        rotuloDeAvance: 'avance de la descarga en GTSTC',
      )));
      expect(find.text('Proa'), findsOneWidget);
      expect(find.text('Popa'), findsOneWidget);
      for (final numero in ['02', '06', '10', '14', '18', '22']) {
        expect(find.text(numero), findsOneWidget);
      }
      final boton = find.bySemanticsLabel(RegExp(r'^Bahía 10,'));
      expect(boton, findsOneWidget);
      expect(
          tester.getSemantics(boton),
          matchesSemantics(
            // El porcentaje lleva el espacio duro de bs_formato.
            label: 'Bahía 10, 4 niveles en cubierta y 3 en bodega, '
                'avance ${formatearPorcentaje(0.25)}',
            hasSelectedState: true,
            isSelected: true,
            isButton: true,
            hasTapAction: true,
          ));
      expect(tester.getSemantics(find.bySemanticsLabel(RegExp(r'^Bahía 22,'))).label,
          'Bahía 22, 4 niveles en cubierta y 3 en bodega, sin operación');
      await tester.tap(find.text('14'));
      expect(elegida, 14);
      final tamano = tester.getSize(find.bySemanticsLabel(RegExp(r'^Bahía 14,')));
      expect(tamano.width, BsSiluetaBuque.anchoBahia);
      expect(tamano.height, greaterThanOrEqualTo(48));
      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.byType(LinearProgressIndicator), findsNWidgets(3),
          reason: 'una barra por bahía con avance');
      semantica.dispose();
    });

    testWidgets('la bahía recién movida destella y se apaga; quieta si se reduce el movimiento',
        (tester) async {
      await tester.pumpWidget(_envuelve(BsSiluetaBuque(
        bahias: _bahias(),
        seleccionada: 10,
        recienMovida: 10,
        onSeleccion: (_) {},
      )));
      expect(find.byType(TweenAnimationBuilder<double>), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pump(BsMovimiento.recienMovido);
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse, reason: 'se apaga en 1.5 s');

      await tester.pumpWidget(_envuelve(
        BsSiluetaBuque(
          bahias: _bahias(),
          seleccionada: 10,
          recienMovida: 10,
          onSeleccion: (_) {},
        ),
        sinMovimiento: true,
      ));
      expect(find.byType(TweenAnimationBuilder<double>), findsNothing);
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('BsCelda, los estados de la vista Estado', () {
    testWidgets('bajado sin marca muestra solo la palomita; con marca, «Hecho»',
        (tester) async {
      await tester.pumpWidget(_envuelve(const BsCelda(
        codigo: 'GTSTC',
        estado: BsEstadoDeCelda.bajado,
        etiqueta: 'Celda 014-03-86, bajado',
      )));
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.text('GTSTC'), findsNothing);
      await tester.pumpWidget(_envuelve(const BsCelda(
        codigo: 'GTSTC',
        estado: BsEstadoDeCelda.bajado,
        marca: BsMarcaDeCelda.hecho,
        etiqueta: 'Celda 014-03-86, hecho',
      )));
      expect(find.text('Hecho'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('de noche, bajado va punteado y de día va lleno', (tester) async {
      Iterable<CustomPaint> pinturas() => tester.widgetList<CustomPaint>(
          find.descendant(of: find.byType(BsCelda), matching: find.byType(CustomPaint)));
      await tester.pumpWidget(_envuelve(
        const BsCelda(codigo: 'GTSTC', estado: BsEstadoDeCelda.bajado, etiqueta: 'b'),
        oscuro: true,
      ));
      expect(pinturas().where((p) => p.foregroundPainter is BsContornoPunteado),
          hasLength(1));
      await tester.pumpWidget(_envuelve(
        const BsCelda(codigo: 'GTSTC', estado: BsEstadoDeCelda.bajado, etiqueta: 'b'),
      ));
      // El cambio de tema se anima (AnimatedTheme): se espera a que termine.
      await tester.pumpAndSettle();
      expect(pinturas(), isEmpty, reason: 'de día no hay punteado ni CustomPaint');
    });

    testWidgets('recién movido sale de su celda, dice «Bajando» y cambia su etiqueta',
        (tester) async {
      final semantica = tester.ensureSemantics();
      await tester.pumpWidget(_envuelve(BsCelda(
        codigo: 'GTSTC',
        estado: BsEstadoDeCelda.recienMovido,
        marca: BsMarcaDeCelda.baja,
        etiqueta: 'TSTU 004218 0, 014-01-86',
        onTap: () {},
      )));
      expect(find.text('Bajando'), findsOneWidget);
      expect(
          tester
              .widgetList<CustomPaint>(find.byType(CustomPaint))
              .where((p) => p.painter is BsContornoPunteado),
          hasLength(1),
          reason: 'el hueco que deja');
      expect(tester.getSemantics(find.byType(BsCelda)).label,
          'TSTU 004218 0, 014-01-86, se acaba de mover');
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
      // Terminada la salida, el cuerpo está media celda más arriba que su
      // caja, con `Transform`: la celda sigue midiendo lo mismo.
      final cuerpo = find.descendant(of: find.byType(BsCelda), matching: find.byType(Container));
      final celda = tester.getRect(find.byType(BsCelda));
      expect(tester.getTopLeft(cuerpo.first).dy, closeTo(celda.top + 2 - 24, 0.01));
      expect(celda.height, 48 + 4);
      semantica.dispose();
    });

    testWidgets(
        'la celda sale de verdad: de 0 a media celda en 150 ms desde su estado anterior, '
        'y vuelve de golpe', (tester) async {
      // 10.17, H1: la misma celda (misma clave, misma posición en el árbol)
      // cambia de estado; el fotograma inicial está en su sitio, el de 75 ms
      // a medio camino y el de 150 ms media celda arriba.
      Widget celda(BsEstadoDeCelda estado) => _envuelve(SizedBox(
            width: 200,
            height: 200,
            child: Center(
              child: BsCelda(
                key: const ValueKey('misma-celda'),
                codigo: 'GTSTC',
                estado: estado,
                marca: BsMarcaDeCelda.baja,
                etiqueta: 'TSTU 004218 0, 014-01-86',
              ),
            ),
          ));
      double arriba() => tester
          .getTopLeft(find.descendant(
              of: find.byType(BsCelda), matching: find.byType(Container)).first)
          .dy;
      await tester.pumpWidget(celda(BsEstadoDeCelda.porBajarCubierta));
      await tester.pumpAndSettle();
      final enSuSitio = arriba();
      final media = BsMedidas.muelle.altoCelda / 2;

      await tester.pumpWidget(celda(BsEstadoDeCelda.recienMovido));
      await tester.pump();
      expect(arriba(), closeTo(enSuSitio, 0.01),
          reason: 'el primer fotograma sale desde donde estaba');
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pump(const Duration(milliseconds: 75));
      final aMedias = arriba();
      expect(aMedias, lessThan(enSuSitio - 1), reason: 'a los 75 ms ya subió');
      expect(aMedias, greaterThan(enSuSitio - media + 1),
          reason: 'a los 75 ms todavía no llegó');
      await tester.pump(const Duration(milliseconds: 75));
      expect(arriba(), closeTo(enSuSitio - media, 0.01),
          reason: 'a los 150 ms está media celda arriba');
      // Un fotograma más para que el reloj de la animación se detenga.
      await tester.pump(const Duration(milliseconds: 16));
      expect(tester.hasRunningAnimations, isFalse,
          reason: 'terminada la salida no queda nada en marcha');

      // Al volver a «bajado» no se ve regresar: en el primer fotograma ya está
      // en su sitio, y a los 75 ms sigue ahí.
      await tester.pumpWidget(celda(BsEstadoDeCelda.bajado));
      await tester.pump();
      expect(arriba(), closeTo(enSuSitio, 0.01));
      expect(tester.hasRunningAnimations, isFalse);
      await tester.pump(const Duration(milliseconds: 75));
      expect(arriba(), closeTo(enSuSitio, 0.01));
      expect(
          tester
              .widgetList<CustomPaint>(find.byType(CustomPaint))
              .where((p) => p.painter is BsContornoPunteado),
          isEmpty,
          reason: 'sin hueco al volver');
    });

    testWidgets('con reducción de movimiento, recién movido se queda quieta y naranja',
        (tester) async {
      await tester.pumpWidget(_envuelve(
        const BsCelda(
          codigo: 'GTSTC',
          estado: BsEstadoDeCelda.recienMovido,
          marca: BsMarcaDeCelda.sube,
          etiqueta: 'c',
        ),
        sinMovimiento: true,
      ));
      expect(find.text('Subiendo'), findsOneWidget);
      expect(find.descendant(of: find.byType(BsCelda), matching: find.byType(CustomPaint)),
          findsNothing, reason: 'sin hueco punteado: no sale de su sitio');
      final contenedor = tester.widget<Container>(find.byType(Container).first);
      expect((contenedor.decoration! as BoxDecoration).color,
          BsColoresSemanticos.claro().recienMovido.relleno);
      final cuerpo = find.descendant(of: find.byType(BsCelda), matching: find.byType(Container));
      final arriba = tester.getTopLeft(cuerpo.first).dy;
      expect(arriba, closeTo(tester.getRect(find.byType(BsCelda)).top + 2, 0.01),
          reason: 'en su sitio: el desplazamiento es cero');
      await tester.pump(const Duration(seconds: 1));
      expect(tester.hasRunningAnimations, isFalse);
      expect(tester.getTopLeft(cuerpo.first).dy, closeTo(arriba, 0.01));
    });

    testWidgets('la curva del casco va en la esquina exterior y el radio es el del ícono',
        (tester) async {
      BorderRadius radioDe(BsCurvaDeCelda curva) {
        final contenedor = tester.widget<Container>(find.byType(Container).first);
        return (contenedor.decoration! as BoxDecoration).borderRadius! as BorderRadius;
      }

      await tester.pumpWidget(_envuelve(const BsCelda(
          codigo: 'GTSTC', estado: BsEstadoDeCelda.porBajarBodega, etiqueta: 'c')));
      var radio = radioDe(BsCurvaDeCelda.ninguna);
      expect(radio.bottomLeft, const Radius.circular(8));
      expect(radio.topRight, const Radius.circular(8));
      await tester.pumpWidget(_envuelve(const BsCelda(
          codigo: 'GTSTC',
          estado: BsEstadoDeCelda.porBajarBodega,
          curva: BsCurvaDeCelda.babor,
          etiqueta: 'c')));
      radio = radioDe(BsCurvaDeCelda.babor);
      expect(radio.bottomLeft, const Radius.circular(18));
      expect(radio.bottomRight, const Radius.circular(8));
      await tester.pumpWidget(_envuelve(const BsCelda(
          codigo: 'GTSTC',
          estado: BsEstadoDeCelda.porBajarBodega,
          curva: BsCurvaDeCelda.ambas,
          etiqueta: 'c')));
      radio = radioDe(BsCurvaDeCelda.ambas);
      expect(radio.bottomLeft, const Radius.circular(18));
      expect(radio.bottomRight, const Radius.circular(18));
      expect(radio.topLeft, const Radius.circular(8));
    });

    testWidgets('el estado manda en el relleno y la categoría queda para el código',
        (tester) async {
      await tester.pumpWidget(_envuelve(Builder(
        builder: (BuildContext context) => BsCelda(
          codigo: 'GTSTC',
          estado: BsEstadoDeCelda.porBajarCubierta,
          categoria: BsColoresSemanticos.de(context).categorico('GTSTC'),
          etiqueta: 'c',
        ),
      )));
      final contenedor = tester.widget<Container>(find.byType(Container).first);
      expect((contenedor.decoration! as BoxDecoration).color,
          BsColoresSemanticos.claro().porBajarCubierta.relleno);
      expect(find.text('GTSTC'), findsOneWidget);
    });
  });

  group('BsCascoBodega', () {
    testWidgets('pinta el casco detrás de las filas, dentro de un RepaintBoundary',
        (tester) async {
      await tester.pumpWidget(_envuelve(const BsCascoBodega(
        child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
          BsCelda(
              codigo: 'GTSTC',
              estado: BsEstadoDeCelda.porBajarBodega,
              curva: BsCurvaDeCelda.babor,
              etiqueta: 'a'),
          BsCelda(
              codigo: 'GTSTC',
              estado: BsEstadoDeCelda.porBajarBodega,
              curva: BsCurvaDeCelda.estribor,
              etiqueta: 'b'),
        ]),
      )));
      final casco = find.descendant(
          of: find.byType(BsCascoBodega), matching: find.byType(CustomPaint));
      expect(casco, findsOneWidget);
      expect(
          find.descendant(
              of: find.byType(BsCascoBodega), matching: find.byType(RepaintBoundary)),
          findsOneWidget);
      expect(tester.getSize(find.byType(BsCascoBodega)).width, greaterThan(2 * 56));
    });
  });

  group('BsTarjetaCifra y BsAnilloAvance', () {
    testWidgets('rótulo, cifra, detalle, anillo y etiqueta completa', (tester) async {
      final semantica = tester.ensureSemantics();
      var toques = 0;
      await tester.pumpWidget(_envuelve(SizedBox(
        width: 240,
        child: BsTarjetaCifra(
          valor: '80 %',
          rotulo: 'Descarga',
          detalle: '120 de 150 bajados en GTSTC',
          anillo: const BsAnilloAvance(fraccion: 0.8),
          onTap: () => toques++,
        ),
      )));
      expect(find.text('Descarga'), findsOneWidget);
      expect(find.text('80 %'), findsOneWidget);
      expect(find.text('120 de 150 bajados en GTSTC'), findsOneWidget);
      // La tarjeta es un solo nodo: el anillo queda dentro de su etiqueta.
      expect(tester.getSemantics(find.byType(BsTarjetaCifra)).label,
          'Descarga: 80 %, 120 de 150 bajados en GTSTC');
      expect(tester.getSize(find.byType(BsAnilloAvance)), const Size(52, 52));
      await tester.tap(find.byType(BsTarjetaCifra));
      expect(toques, 1);
      expect(tester.widget<Text>(find.text('80 %')).style?.fontSize, BsEscala.cifraGrande);
      // Solo, el anillo dice su porcentaje.
      await tester.pumpWidget(_envuelve(const BsAnilloAvance(fraccion: 0.8)));
      expect(tester.getSemantics(find.byType(BsAnilloAvance)).label, '80 por ciento');
      expect(
          find.descendant(of: find.byType(BsAnilloAvance), matching: find.byType(RepaintBoundary)),
          findsOneWidget);
      semantica.dispose();
    });

    testWidgets('con rol, la cifra toma el color del rol', (tester) async {
      await tester.pumpWidget(_envuelve(Builder(
        builder: (BuildContext context) => BsTarjetaCifra(
          valor: '2',
          rotulo: 'Alertas de estiba',
          rol: BsColoresSemanticos.de(context).revisar,
        ),
      )));
      expect(tester.widget<Text>(find.text('2')).style?.color,
          BsColoresSemanticos.claro().revisar.contorno);
    });
  });

  group('BsPanelEnVivo', () {
    testWidgets('una fila por evento con el rol del equipo, la acción y la región en vivo',
        (tester) async {
      final semantica = tester.ensureSemantics();
      var revisados = 0;
      await tester.pumpWidget(_envuelve(SizedBox(
        width: 360,
        child: BsPanelEnVivo(
          resumen: 'Oficina y 2 teléfonos del muelle',
          eventos: _eventos(onRevisar: () => revisados++),
        ),
      )));
      expect(find.text('En vivo'), findsOneWidget);
      expect(find.text('Oficina y 2 teléfonos del muelle'), findsOneWidget);
      expect(find.text('Bajado · Muelle'), findsOneWidget);
      expect(find.text('Cambio pedido · Muelle'), findsOneWidget);
      expect(find.text('Re‑estiba aprobada · Oficina'), findsOneWidget);
      expect(find.text('hace 1 min'), findsOneWidget);
      await tester.tap(find.text('Revisar'));
      expect(revisados, 1);
      expect(
          tester.getSemantics(find.bySemanticsLabel(
              'Bajado, Muelle, TSTU 004218 0 · 014-01-86, hace 1 min')),
          matchesSemantics(
            label: 'Bajado, Muelle, TSTU 004218 0 · 014-01-86, hace 1 min',
            isLiveRegion: true,
          ),
          reason: 'el evento más reciente se anuncia');
      expect(
          tester.getSemantics(
              find.bySemanticsLabel(RegExp(r'^Re‑estiba aprobada, Oficina'))),
          matchesSemantics(
            label: 'Re‑estiba aprobada, Oficina, TSTU 031167 5 · 018-07-84 → 018-05-86, hace 9 min',
            isLiveRegion: false,
          ));
      expect(find.byType(BsPulso), findsOneWidget);
      semantica.dispose();
    });

    testWidgets('sin eventos lo dice, y el pulso se queda quieto sin movimiento',
        (tester) async {
      await tester.pumpWidget(_envuelve(
        const SizedBox(width: 360, child: BsPanelEnVivo(eventos: <BsEventoEnVivo>[])),
        sinMovimiento: true,
      ));
      expect(find.text('Todavía no hay movimientos en esta escala.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(tester.hasRunningAnimations, isFalse);
      await tester.pumpWidget(_envuelve(
        const SizedBox(width: 360, child: BsPanelEnVivo(eventos: <BsEventoEnVivo>[])),
      ));
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.hasRunningAnimations, isTrue, reason: 'en línea, el punto pulsa');
    });
  });

  group('BsBandaMuelle', () {
    testWidgets('la marca sin recuadro, el buque, el viaje, la nube y los modos',
        (tester) async {
      final semantica = tester.ensureSemantics();
      BsModoDeOperacion? modo;
      var nube = 0;
      await tester.pumpWidget(_envuelve(BsBandaMuelle(
        buque: 'BUQUE MANUAL',
        viaje: 'Viaje M100 · GTSTC',
        nube: BsChipDeNube(texto: 'Al día', onTap: () => nube++),
        modo: BsModoDeOperacion.descarga,
        onModo: (BsModoDeOperacion valor) => modo = valor,
      )));
      expect(find.text('BUQUE MANUAL'), findsOneWidget);
      expect(find.text('Viaje M100 · GTSTC'), findsOneWidget);
      expect(find.text('Descarga'), findsOneWidget);
      expect(find.text('Carga'), findsOneWidget);
      expect(tester.widget<BsMarca>(find.byType(BsMarca)).variante,
          BsVarianteDeMarca.sinRecuadro);
      await tester.tap(find.text('Carga'));
      expect(modo, BsModoDeOperacion.carga);
      await tester.tap(find.text('Al día'));
      expect(nube, 1);
      expect(tester.getSemantics(find.byType(BsChipDeNube)).label, 'Nube: Al día');
      final material = tester.widget<Material>(find.descendant(
          of: find.byType(BsBandaMuelle), matching: find.byType(Material)).first);
      expect(material.color, BsPaleta.claro.marcaSuperficie);
      semantica.dispose();
    });
  });

  group('BsFondoDePlano', () {
    testWidgets('de noche pinta la rejilla; de día, solo el papel', (tester) async {
      await tester.pumpWidget(_envuelve(
          const BsFondoDePlano(child: SizedBox(width: 200, height: 100)),
          oscuro: true));
      expect(
          find.descendant(of: find.byType(BsFondoDePlano), matching: find.byType(CustomPaint)),
          findsOneWidget);
      await tester.pumpWidget(_envuelve(
          const BsFondoDePlano(child: SizedBox(width: 200, height: 100))));
      await tester.pumpAndSettle();
      expect(
          find.descendant(of: find.byType(BsFondoDePlano), matching: find.byType(CustomPaint)),
          findsNothing);
      expect(
          tester.widget<ColoredBox>(find.descendant(
              of: find.byType(BsFondoDePlano), matching: find.byType(ColoredBox)).first).color,
          BsPaleta.claro.papel);
    });
  });

  group('las tres pautas de accesibilidad en el día y en la noche', () {
    final piezas = <String, Widget Function(BuildContext)>{
      'marca': (_) => const Row(children: <Widget>[
            BsMarca(tamano: 44),
            BsMarca(tamano: 44, variante: BsVarianteDeMarca.sinRecuadro),
            BsMarca(tamano: 44, variante: BsVarianteDeMarca.monocroma),
            BsMarca(tamano: 72, espera: true),
          ]),
      'silueta del buque': (_) => BsSiluetaBuque(
            bahias: _bahias(),
            seleccionada: 10,
            recienMovida: 14,
            onSeleccion: (_) {},
          ),
      'celdas de la vista Estado en el casco': (context) {
        final semanticos = BsColoresSemanticos.de(context);
        return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Wrap(children: <Widget>[
            BsCelda(
                codigo: 'GTSTC',
                estado: BsEstadoDeCelda.porBajarCubierta,
                categoria: semanticos.categorico('GTSTC'),
                etiqueta: 'por bajar',
                onTap: () {}),
            BsCelda(
                codigo: 'GTSTC',
                estado: BsEstadoDeCelda.recienMovido,
                marca: BsMarcaDeCelda.baja,
                etiqueta: 'recién movido',
                onTap: () {}),
            BsCelda(
                codigo: 'GTSTC',
                estado: BsEstadoDeCelda.bajado,
                etiqueta: 'bajado',
                onTap: () {}),
            const BsCelda(
                codigo: 'USHOU',
                estado: BsEstadoDeCelda.dePaso,
                marca: BsMarcaDeCelda.paso,
                etiqueta: 'de paso'),
          ]),
          BsCascoBodega(
            child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
              BsCelda(
                  codigo: 'GTSTC',
                  estado: BsEstadoDeCelda.porBajarBodega,
                  curva: BsCurvaDeCelda.babor,
                  etiqueta: 'bodega babor',
                  onTap: () {}),
              BsCelda(
                  codigo: 'GTSTC',
                  estado: BsEstadoDeCelda.porBajarBodega,
                  curva: BsCurvaDeCelda.estribor,
                  etiqueta: 'bodega estribor',
                  onTap: () {}),
            ]),
          ),
        ]);
      },
      'tarjetas de cifra': (context) => Wrap(spacing: 12, children: <Widget>[
            SizedBox(
              width: 220,
              child: BsTarjetaCifra(
                valor: '80 %',
                rotulo: 'Descarga',
                detalle: '120 de 150 bajados en GTSTC',
                anillo: const BsAnilloAvance(fraccion: 0.8),
                onTap: () {},
              ),
            ),
            SizedBox(
              width: 200,
              child: BsTarjetaCifra(
                valor: '2',
                rotulo: 'Alertas de estiba',
                detalle: '1 de peso por pila, 1 de segregación',
                rol: BsColoresSemanticos.de(context).revisar,
                onTap: () {},
              ),
            ),
          ]),
      'panel En vivo': (_) => SizedBox(
            width: 360,
            child: BsPanelEnVivo(
              resumen: 'Oficina y 2 teléfonos del muelle',
              eventos: _eventos(),
            ),
          ),
      'banda del muelle': (_) => BsBandaMuelle(
            buque: 'BUQUE MANUAL',
            viaje: 'Viaje M100 · GTSTC',
            nube: BsChipDeNube(texto: 'Al día', onTap: () {}),
            modo: BsModoDeOperacion.descarga,
            onModo: (_) {},
          ),
      'fondo de plano': (_) => const BsFondoDePlano(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('Abre un plano de estiba'),
            ),
          ),
    };
    for (final pieza in piezas.entries) {
      for (final oscuro in [false, true]) {
        final modo = oscuro ? 'noche' : 'día';
        testWidgets('${pieza.key}: contraste, objetivos y etiquetas en $modo',
            (tester) async {
          final semantica = tester.ensureSemantics();
          await tester.pumpWidget(_envuelve(Builder(builder: pieza.value), oscuro: oscuro));
          await expectLater(tester, meetsGuideline(textContrastGuideline));
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          semantica.dispose();
        });
      }
    }
  });

  group('las vistas previas nuevas', () {
    final previas = <String, Widget Function()>{
      'celdas de la vista Estado': vistaPreviaCeldasEstado,
      'celdas de la vista Estado en el muelle': vistaPreviaCeldasEstadoMuelle,
      'marca': vistaPreviaMarca,
      'silueta del buque': vistaPreviaSiluetaBuque,
      'tarjetas de cifra': vistaPreviaTarjetasCifra,
      'panel En vivo': vistaPreviaPanelEnVivo,
      'banda del muelle': vistaPreviaBandaMuelle,
      'fondo de plano': vistaPreviaFondoDePlano,
    };
    for (final previa in previas.entries) {
      testWidgets('${previa.key} se construye en el día y en la noche', (tester) async {
        tester.view.physicalSize = const Size(1200, 1600);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        for (final tema in [BayStreamTema.claro(), BayStreamTema.oscuro(muelle: true)]) {
          await tester.pumpWidget(MaterialApp(
            theme: tema,
            home: Scaffold(body: SingleChildScrollView(child: previa.value())),
          ));
          await tester.pump(const Duration(milliseconds: 50));
          expect(tester.takeException(), isNull, reason: previa.key);
        }
        await tester.pumpWidget(const SizedBox());
      });
    }
  });
}
