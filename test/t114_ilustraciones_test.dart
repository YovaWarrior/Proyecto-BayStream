// T-114 · El paquete de íconos e ilustraciones (10.19), parte B: las seis
// ilustraciones pintadas por BsIlustracion desde sus datos.
//   - los datos generados (bs_ilustraciones.dart) coinciden con los JSON del
//     paquete, forma por forma;
//   - cada ruta se lee con solo M, L, C y Z y cae dentro de su lienzo;
//   - los nombres de color resuelven a tokens con el mismo hex que el bloque
//     «paleta» del JSON declara, en claro y en oscuro;
//   - los trazos quedan a 3:1 o más sobre el fondo, en claro y en oscuro;
//   - la pieza pinta en los dos temas, dentro de un RepaintBoundary y con su
//     etiqueta accesible como imagen; el punteado y el lector de rutas hacen
//     lo que dicen.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:baystream/core/design/bs_colores_semanticos.dart';
import 'package:baystream/core/design/bs_ilustraciones.dart';
import 'package:baystream/core/design/bs_paleta.dart';
import 'package:baystream/core/design/bs_tema.dart';
import 'package:baystream/core/design/componentes/bs_ilustracion.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _json(BsDatosDeIlustracion datos) =>
    jsonDecode(File('design/ilustraciones/${datos.nombre}.json').readAsStringSync())
        as Map<String, dynamic>;

/// Un color del JSON (un nombre, `{claro, oscuro}` o nada) como lo escribe el
/// generador.
BsColorDeIlustracion? _color(Object? valor) {
  if (valor == null) return null;
  if (valor is String) return BsColorDeIlustracion.fijo(valor);
  final mapa = valor as Map<String, dynamic>;
  final claro = mapa['claro'] as String?;
  final oscuro = mapa['oscuro'] as String?;
  if (claro == null && oscuro == null) return null;
  return BsColorDeIlustracion.porTema(claro: claro, oscuro: oscuro);
}

String _hex(Color color) =>
    '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

({BsPaleta paleta, BsColoresSemanticos semanticos}) _tema(String nombre) =>
    nombre == 'oscuro'
        ? (paleta: BsPaleta.oscuro, semanticos: BsColoresSemanticos.oscuro())
        : (paleta: BsPaleta.claro, semanticos: BsColoresSemanticos.claro());

void main() {
  test('las seis ilustraciones del paquete están, con su descripción', () {
    expect(BsIlustraciones.todas, hasLength(6));
    expect(BsIlustraciones.todas.map((d) => d.nombre), [
      'inicio',
      'vacio_recientes',
      'vacio_busqueda',
      'sin_conexion',
      'descarga_completa',
      'sin_alertas',
    ]);
    for (final datos in BsIlustraciones.todas) {
      expect(datos.descripcion, isNotEmpty, reason: datos.nombre);
      expect(datos.descripcion, endsWith('.'), reason: datos.nombre);
      expect(datos.formas, isNotEmpty, reason: datos.nombre);
    }
    expect(BsIlustraciones.inicio.ancho, 640);
    expect(BsIlustraciones.inicio.alto, 400);
    expect(BsIlustraciones.sinAlertas.ancho, 320);
    expect(BsIlustraciones.sinAlertas.alto, 200);
  });

  test('los datos generados coinciden con los JSON del paquete, forma por forma',
      () {
    var formas = 0;
    for (final datos in BsIlustraciones.todas) {
      final json = _json(datos);
      expect(json['nombre'], datos.nombre);
      expect((json['ancho'] as num).toDouble(), datos.ancho, reason: datos.nombre);
      expect((json['alto'] as num).toDouble(), datos.alto, reason: datos.nombre);
      expect(json['fondo'], datos.fondo, reason: datos.nombre);
      final listadas = (json['formas'] as List<dynamic>).cast<Map<String, dynamic>>();
      expect(datos.formas, hasLength(listadas.length), reason: datos.nombre);
      for (var i = 0; i < listadas.length; i++) {
        final esperada = listadas[i];
        final forma = datos.formas[i];
        final donde = '${datos.nombre} · forma $i (${forma.grupo})';
        expect(forma.grupo, esperada['grupo'], reason: donde);
        expect(forma.ruta, esperada['ruta'], reason: donde);
        expect(forma.relleno, _color(esperada['relleno']), reason: donde);
        expect(forma.trazo, _color(esperada['trazo']), reason: donde);
        expect(forma.grosor, closeTo(((esperada['grosor'] ?? 0) as num).toDouble(), 1e-9),
            reason: donde);
        final punteado = esperada['punteado'] as List<dynamic>?;
        if (punteado == null) {
          expect(forma.punteado, isNull, reason: donde);
        } else {
          expect(forma.punteado, hasLength(punteado.length), reason: donde);
          for (var k = 0; k < punteado.length; k++) {
            expect(forma.punteado![k], closeTo((punteado[k] as num).toDouble(), 1e-9),
                reason: donde);
          }
        }
        formas++;
      }
    }
    expect(formas, 115);
  });

  test('cada ruta se lee con solo M, L, C y Z, y cae dentro de su lienzo', () {
    for (final datos in BsIlustraciones.todas) {
      for (final forma in datos.formas) {
        final letras = forma.ruta.replaceAll(RegExp(r'[^A-Za-z]'), '').split('').toSet();
        expect(letras.difference({'M', 'L', 'C', 'Z'}), isEmpty,
            reason: '${datos.nombre} · ${forma.grupo}');
        final ruta = rutaDeIlustracion(forma.ruta);
        final limites = ruta.getBounds();
        expect(limites.left, greaterThanOrEqualTo(-1), reason: '${datos.nombre} · ${forma.grupo}');
        expect(limites.top, greaterThanOrEqualTo(-1), reason: '${datos.nombre} · ${forma.grupo}');
        expect(limites.right, lessThanOrEqualTo(datos.ancho + 1),
            reason: '${datos.nombre} · ${forma.grupo}');
        expect(limites.bottom, lessThanOrEqualTo(datos.alto + 1),
            reason: '${datos.nombre} · ${forma.grupo}');
      }
    }
    expect(() => rutaDeIlustracion('M0 0 Q 5 5 10 0'), throwsFormatException);
    expect(() => rutaDeIlustracion('M0 0 l 5 5'), throwsFormatException);
    expect(() => rutaDeIlustracion('M0 0 A 1 1 0 0 1 2 2'), throwsFormatException);
    expect(() => rutaDeIlustracion('10 10'), throwsFormatException);
    expect(() => rutaDeIlustracion('M0 0 L 5'), throwsFormatException);
  });

  test('el punteado reparte la ruta en trazos y huecos como stroke-dasharray', () {
    final recta = Path()
      ..moveTo(0, 0)
      ..lineTo(100, 0);
    final punteada = rutaPunteada(recta, <double>[10, 5]);
    final largo = punteada
        .computeMetrics()
        .fold<double>(0, (suma, metrica) => suma + metrica.length);
    // 0–10, 15–25, 30–40, 45–55, 60–70, 75–85 y 90–100: siete trazos de 10.
    expect(largo, closeTo(70, 0.5));
    expect(punteada.computeMetrics(), hasLength(7));
    expect(identical(rutaPunteada(recta, <double>[]), recta), isTrue);
  });

  test('los nombres de color resuelven a tokens con el hex que declara el paquete',
      () {
    var comprobados = 0;
    for (final datos in BsIlustraciones.todas) {
      final paleta = _json(datos)['paleta'] as Map<String, dynamic>;
      for (final tema in const ['claro', 'oscuro']) {
        final t = _tema(tema);
        final nombres = (paleta[tema] as Map<String, dynamic>).cast<String, String>();
        for (final entrada in nombres.entries) {
          final color = colorDeIlustracion(entrada.key,
              paleta: t.paleta, semanticos: t.semanticos);
          expect(color, isNotNull, reason: '${datos.nombre} · $tema · ${entrada.key}');
          expect(_hex(color!), entrada.value.toUpperCase(),
              reason: '${datos.nombre} · $tema · ${entrada.key}');
          comprobados++;
        }
        // Y todo lo que las formas nombran está en ese bloque: nada se inventa.
        for (final nombre in datos.coloresUsados) {
          final usadoEnTema = datos.fondo == nombre ||
              datos.formas.any((f) =>
                  f.relleno?.de(t.paleta.brillo) == nombre ||
                  f.trazo?.de(t.paleta.brillo) == nombre);
          if (usadoEnTema) {
            expect(nombres, contains(nombre), reason: '${datos.nombre} · $tema');
          }
        }
      }
    }
    expect(comprobados, greaterThanOrEqualTo(60));
    expect(
        () => colorDeIlustracion('arcoiris',
            paleta: BsPaleta.claro, semanticos: BsColoresSemanticos.claro()),
        throwsArgumentError);
    expect(colorDeIlustracion(null,
            paleta: BsPaleta.claro, semanticos: BsColoresSemanticos.claro()),
        isNull);
  });

  test('los trazos quedan a 3:1 o más sobre el fondo, en claro y en oscuro', () {
    var trazos = 0;
    for (final datos in BsIlustraciones.todas) {
      for (final tema in const ['claro', 'oscuro']) {
        final t = _tema(tema);
        final fondo = colorDeIlustracion(datos.fondo,
            paleta: t.paleta, semanticos: t.semanticos)!;
        for (final forma in datos.formas) {
          final nombre = forma.trazo?.de(t.paleta.brillo);
          if (nombre == null || forma.grosor <= 0) continue;
          final trazo = colorDeIlustracion(nombre,
              paleta: t.paleta, semanticos: t.semanticos)!;
          expect(BsRol.contrasteEntre(trazo, fondo),
              greaterThanOrEqualTo(3.0),
              reason: '${datos.nombre} · $tema · ${forma.grupo} ($nombre sobre ${datos.fondo})');
          trazos++;
        }
      }
    }
    expect(trazos, greaterThan(0));
  });

  for (final oscuro in const [false, true]) {
    final tema = oscuro ? 'oscuro' : 'claro';
    testWidgets('las seis pintan en $tema, en un RepaintBoundary y con su etiqueta',
        (tester) async {
      // Una ventana alta, para que los 320 de ancho quepan en la parte del
      // alto que la regla 4 de 13.11 da al dibujo (300 dp de 1000).
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(800, 1000);
      addTearDown(tester.view.reset);
      final semantica = tester.ensureSemantics();
      for (final datos in BsIlustraciones.todas) {
        await tester.pumpWidget(MaterialApp(
          theme: BayStreamTema.claro(muelle: true),
          darkTheme: BayStreamTema.oscuro(muelle: true),
          themeMode: oscuro ? ThemeMode.dark : ThemeMode.light,
          home: Scaffold(
            body: Center(
              child: SizedBox(width: 320, child: BsIlustracion(datos: datos)),
            ),
          ),
        ));
        await tester.pumpAndSettle();
        final pieza = find.byType(BsIlustracion);
        expect(tester.getSize(pieza).width, 320, reason: datos.nombre);
        expect(tester.getSize(pieza).height,
            closeTo(320 * datos.alto / datos.ancho, 0.5),
            reason: '${datos.nombre} conserva la proporción');
        final frontera = find.descendant(
            of: pieza, matching: find.byType(RepaintBoundary));
        expect(frontera, findsOneWidget, reason: datos.nombre);
        expect(find.descendant(of: frontera, matching: find.byType(CustomPaint)),
            findsOneWidget, reason: datos.nombre);
        final nodo = tester.getSemantics(pieza);
        expect(nodo.label, datos.descripcion, reason: datos.nombre);
        expect(nodo.flagsCollection.isImage, isTrue, reason: datos.nombre);

        // Lo pintado: algo, no todo, y los colores dominantes son tokens.
        final caja = tester.renderObject<RenderRepaintBoundary>(frontera);
        late ui.Image imagen;
        late ByteData bytes;
        await tester.runAsync(() async {
          imagen = await caja.toImage();
          bytes = (await imagen.toByteData(format: ui.ImageByteFormat.rawRgba))!;
        });
        final rgba = bytes.buffer.asUint8List();
        var conTinta = 0;
        final cuentas = <int, int>{};
        for (var i = 0; i < rgba.length; i += 4) {
          if (rgba[i + 3] == 255) {
            conTinta++;
            final argb = 0xFF000000 | (rgba[i] << 16) | (rgba[i + 1] << 8) | rgba[i + 2];
            cuentas[argb] = (cuentas[argb] ?? 0) + 1;
          }
        }
        final total = rgba.length ~/ 4;
        expect(conTinta / total, inInclusiveRange(0.02, 0.98),
            reason: '${datos.nombre} en $tema pinta una parte del lienzo');
        final t = _tema(tema);
        final tokens = <int>{
          for (final nombre in datos.coloresUsados)
            colorDeIlustracion(nombre, paleta: t.paleta, semanticos: t.semanticos)!
                .toARGB32(),
        };
        final dominante = (cuentas.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value)))
            .first
            .key;
        expect(tokens, contains(dominante),
            reason: '${datos.nombre} en $tema: el color que más pinta es un token');
        imagen.dispose();
        expect(tester.takeException(), isNull, reason: datos.nombre);
      }
      semantica.dispose();
    });
  }

  testWidgets('con fondo pinta el papel detrás, y la etiqueta dada manda',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 1000);
    addTearDown(tester.view.reset);
    final semantica = tester.ensureSemantics();
    await tester.pumpWidget(MaterialApp(
      theme: BayStreamTema.claro(muelle: true),
      home: const Scaffold(
        body: Center(
          child: SizedBox(
            width: 320,
            child: BsIlustracion(
              datos: BsIlustraciones.sinAlertas,
              etiqueta: 'Sin posibles incumplimientos',
              conFondo: true,
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(tester.getSemantics(find.byType(BsIlustracion)).label,
        'Sin posibles incumplimientos');
    semantica.dispose();
    final caja = tester.renderObject<RenderRepaintBoundary>(find.descendant(
        of: find.byType(BsIlustracion), matching: find.byType(RepaintBoundary)));
    late int esquina;
    await tester.runAsync(() async {
      final imagen = await caja.toImage();
      final bytes = (await imagen.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      final rgba = bytes.buffer.asUint8List();
      esquina = 0xFF000000 | (rgba[0] << 16) | (rgba[1] << 8) | rgba[2];
      imagen.dispose();
    });
    expect(esquina, BsPaleta.claro.papel.toARGB32());
    expect(tester.takeException(), isNull);
  });

  testWidgets('cede ante la letra grande: tres décimas del alto entre la escala, o nada',
      (tester) async {
    // El teléfono bajo (360 × 640): 192 dp con la letra a 1.0, 132 con 1.45
    // y, con 2.0, 96 no llega a los 120 mínimos: no se pinta (13.11, regla 4).
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 640);
    addTearDown(tester.view.reset);
    const proporcion = 400 / 640;
    for (final letra in const [1.0, 1.45, 2.0]) {
      tester.platformDispatcher.textScaleFactorTestValue = letra;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(MaterialApp(
        theme: BayStreamTema.claro(muelle: true),
        home: Scaffold(
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: const BsIlustracion(datos: BsIlustraciones.inicio),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      final pieza = find.byType(BsIlustracion);
      final pintado = find.descendant(of: pieza, matching: find.byType(CustomPaint));
      final presupuesto = 640 * BsIlustracion.parteDelAlto / letra;
      if (presupuesto < BsIlustracion.altoMinimo) {
        expect(tester.getSize(pieza), Size.zero, reason: 'letra $letra');
        expect(pintado, findsNothing, reason: 'letra $letra');
      } else {
        expect(pintado, findsOneWidget, reason: 'letra $letra');
        expect(tester.getSize(pieza).height, closeTo(presupuesto, 0.5),
            reason: 'letra $letra');
        expect(tester.getSize(pieza).width, closeTo(presupuesto / proporcion, 0.5),
            reason: 'letra $letra conserva la proporción');
      }
    }
    // En el escritorio (1920 × 1080) el inicio cabe entero a 480.
    tester.view.physicalSize = const Size(1920, 1080);
    tester.platformDispatcher.textScaleFactorTestValue = 1.0;
    await tester.pumpWidget(MaterialApp(
      theme: BayStreamTema.claro(muelle: true),
      home: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: const BsIlustracion(datos: BsIlustraciones.inicio),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(BsIlustracion)), const Size(480, 300));
  });
}
