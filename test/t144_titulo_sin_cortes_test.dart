import 'package:baystream/core/design/design.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/iso6346_check_digit.dart';
import 'package:baystream/features/vessel/presentation/widgets/detalle_contenedor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t117_oficina_support.dart' show t117CargarFuentes;

/// T-144, corrección 2 (10.127; T144-ACC-02) · La matrícula del título del
/// detalle nunca se corta ni lleva elipsis. Si no cabe junto a la naviera, la
/// naviera baja a la línea siguiente; si tampoco cabe sola, envuelve por sus
/// grupos. Con la letra en que ya cabía, se ve como antes: la matrícula a la
/// izquierda y la naviera a la derecha, en la misma línea.
///
/// Con las fuentes del producto (Plex Mono), no con la cuadrada de las
/// pruebas: es lo que midió la aceptación en Android.

/// Un número ISO 6346 válido a partir de sus diez primeras posiciones.
String iso(String diez) => [
      for (var d = 0; d < 10; d++) '$diez$d',
    ].firstWhere((n) => Iso6346CheckDigit.isValid(n) == true);

void main() {
  setUpAll(t117CargarFuentes);

  final numero = iso('TSTU144000');
  final agrupado = formatearContenedor(numero);
  const naviera = 'NAVIER';
  final contenedor = ContainerUnit(
    id: '1',
    containerId: numero,
    isoSizeType: '22G1',
    status: ContainerStatus.full,
    grossWeight: 20000,
    portOfLoading: 'GTSTC',
    portOfDischarge: 'PAMIT',
    operatorCode: naviera,
  );
  final viaje = VesselVoyage(
    id: 'v144c2',
    vessel: const Vessel(id: 'b', name: 'BUQUE PRUEBA'),
    voyageNumber: 'V144',
    containers: [contenedor],
  );

  // La naviera del título; la otra es la fila «Naviera» del detalle.
  Finder chip() => find.descendant(
      of: find.byKey(const ValueKey('detalle-contenedor-titulo')),
      matching: find.text(naviera));

  // El recuadro de la naviera, con su relleno.
  Finder recuadro() =>
      find.ancestor(of: chip(), matching: find.byType(Container)).first;

  Future<void> abrir(WidgetTester tester, double ancho, double letra) async {
    tester.view.physicalSize = Size(ancho, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        theme: BayStreamTema.claro(muelle: true),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(letra)),
          child: child!,
        ),
        home: Scaffold(
            body: DetalleContenedor(voyage: viaje, container: contenedor)),
      ),
    ));
    await tester.pumpAndSettle();
  }

  for (final ancho in [360.0, 600.0]) {
    for (final letra in [1.0, 1.45, 2.0]) {
      testWidgets('a ${ancho.toInt()} dp con letra $letra la matrícula se ve '
          'entera y ningún párrafo se corta', (tester) async {
        final semantica = tester.ensureSemantics();
        await abrir(tester, ancho, letra);
        expect(tester.takeException(), isNull);

        // La matrícula, entera y agrupada; ningún párrafo del detalle cortado.
        final matricula = find.text(agrupado);
        expect(matricula, findsOneWidget);
        for (final elemento in find.byType(RichText).evaluate()) {
          final parrafo = elemento.renderObject! as RenderParagraph;
          expect(parrafo.didExceedMaxLines, isFalse,
              reason: parrafo.text.toPlainText());
        }
        expect(tester.widget<Text>(matricula).maxLines, isNull);
        expect(tester.widget<Text>(matricula).overflow, isNot(TextOverflow.ellipsis));

        // La etiqueta accesible lleva la matrícula completa.
        expect(find.bySemanticsLabel(RegExp(RegExp.escape(agrupado))),
            findsWidgets);

        // La naviera: a la derecha en la misma línea si cabe; si no, debajo.
        final caja = tester.getRect(find.byKey(const ValueKey('detalle-contenedor-titulo')));
        final rectoNumero = tester.getRect(matricula);
        final rectoNaviera = tester.getRect(recuadro());
        final mismaLinea = rectoNaviera.top < rectoNumero.bottom;
        if (letra < 2.0) {
          // Donde ya cabía, como antes (T144-ACC-02 solo se vio con 2.0).
          expect(mismaLinea, isTrue, reason: '$ancho dp, letra $letra');
        }
        if (mismaLinea) {
          expect(rectoNaviera.right, moreOrLessEquals(caja.right, epsilon: 0.5));
          expect(rectoNaviera.center.dy,
              moreOrLessEquals(rectoNumero.center.dy, epsilon: 0.5));
          expect(rectoNumero.left, moreOrLessEquals(caja.left, epsilon: 0.5));
        } else {
          expect(rectoNaviera.top, greaterThanOrEqualTo(rectoNumero.bottom));
          expect(rectoNaviera.left, moreOrLessEquals(caja.left, epsilon: 0.5));
        }
        semantica.dispose();
      });
    }
  }

  testWidgets('a 360 dp con letra 2.0, la naviera baja (el caso de '
      'T144-ACC-02)', (tester) async {
    await abrir(tester, 360, 2.0);
    final rectoNumero = tester.getRect(find.text(agrupado));
    final rectoNaviera = tester.getRect(recuadro());
    expect(rectoNaviera.top, greaterThanOrEqualTo(rectoNumero.bottom));
  });

  testWidgets('sola y sin espacio, la matrícula envuelve por sus grupos, sin '
      'elipsis', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      theme: BayStreamTema.claro(muelle: true),
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 140,
            child: BsNumeroDeContenedor(numero,
                estilo: const TextStyle(fontSize: 24)),
          ),
        ),
      ),
    ));
    // El `Text` con `semanticsLabel` envuelve su párrafo en una semántica.
    final parrafo = tester.renderObject<RenderParagraph>(find.descendant(
        of: find.text(agrupado), matching: find.byType(RichText)));
    expect(parrafo.didExceedMaxLines, isFalse);
    // Más de una línea, y ningún grupo (propietario, serie, dígito) partido:
    // cada uno queda entero en una sola línea.
    final todas = parrafo.getBoxesForSelection(
        TextSelection(baseOffset: 0, extentOffset: agrupado.length));
    expect(todas.map((c) => c.top).toSet().length, greaterThan(1));
    for (final (inicio, fin) in [(0, 4), (5, 11), (12, 13)]) {
      final cajas = parrafo.getBoxesForSelection(
          TextSelection(baseOffset: inicio, extentOffset: fin));
      expect(cajas.map((c) => c.top).toSet(), hasLength(1),
          reason: '«${agrupado.substring(inicio, fin)}» se partió');
    }
  });
}
