// T-131 · El distintivo de rol (SPRINT-4.md 10.86 y 10.90; DESIGN.md 13.12):
//   - la pieza, completa y compacta, del muelle y de la oficina: el alto
//     visible de alturaChip y la zona táctil de 48 dp; el ícono del paquete a
//     20 o 18 dp y el rótulo en Plex Condensed 600 con el tamaño de
//     labelLarge; el botón «Rol: …» con su pista para el lector de pantalla y
//     la descripción emergente fuera de la semántica; el toque, también en el
//     margen de la zona; sin animación; y las cuatro pautas de accesibilidad
//     en claro y en oscuro, sobre el papel y sobre la banda;
//   - el contraste, compuesto, desde BsPaleta: el rótulo y el ícono sobre los
//     dos extremos del fondo, y el relleno o el filo contra la banda, la barra
//     superior y la cabecera de la oficina, en claro y en oscuro, también con
//     la sombra encima; el metal no cambia con el tema y el script de
//     contraste lleva los mismos colores;
//   - la fuente del paquete v3: los 35 glifos de antes conservan su código y
//     su dibujo, y `oficina` (U+E023) pinta el suyo.
//
// Sin datos de nadie: solo los dos roles.
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:baystream/core/design/design.dart';
import 'package:baystream/core/design/vistas_previas.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t117_oficina_support.dart' show t117CargarFuentes;

double _luminancia(Color color) {
  double canal(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * canal(color.r) + 0.7152 * canal(color.g) + 0.0722 * canal(color.b);
}

double _contraste(Color a, Color b) {
  final la = _luminancia(a);
  final lb = _luminancia(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

final _pildora = find.byKey(const ValueKey('distintivo-pildora'));
final _zona = find.byKey(const ValueKey('distintivo-zona'));

/// La pieza en una página del tema del producto, con la densidad pedida.
Widget _envuelve(Widget hijo,
        {bool oscuro = false, bool muelle = true, Color? fondo}) =>
    MaterialApp(
      theme: BayStreamTema.claro(muelle: muelle),
      darkTheme: BayStreamTema.oscuro(muelle: muelle),
      themeMode: oscuro ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        backgroundColor: fondo,
        body: Center(child: hijo),
      ),
    );

/// Los cuatro: el muelle y la oficina, completo y compacto.
Widget _cuatro({VoidCallback? onTap}) => Wrap(
      spacing: 12,
      runSpacing: 12,
      children: <Widget>[
        for (final equipo in BsEquipo.values)
          for (final compacto in const <bool>[false, true])
            BsDistintivoDeRol(
                equipo: equipo, compacto: compacto, onTap: onTap ?? () {}),
      ],
    );

// --- La fuente (las ayudas de test/t114_iconos_test.dart) -----------------

/// Los 35 códigos del paquete v2 (design/iconos/codigos.json en 10.19), que
/// el v3 no mueve.
const _codigosDelV2 = <String, int>{
  'contenedor_20': 0xE000,
  'contenedor_40': 0xE001,
  'contenedor_45': 0xE002,
  'vacio': 0xE003,
  'refrigerado': 0xE004,
  'peligrosa': 0xE005,
  'fuera_de_medida': 0xE006,
  'tanque': 0xE007,
  'plataforma': 0xE008,
  'techo_abierto': 0xE009,
  'buque': 0xE00A,
  'bahia': 0xE00B,
  'tapa_escotilla': 0xE00C,
  'peso_pila': 0xE00D,
  'limite_apilamiento': 0xE00E,
  'vgm': 0xE00F,
  'segregacion': 0xE010,
  'descarga': 0xE011,
  'carga': 0xE012,
  'reestiba': 0xE013,
  'pedir_cambio': 0xE014,
  'orden': 0xE015,
  'grua': 0xE016,
  'muelle': 0xE017,
  'escala': 0xE018,
  'baplie': 0xE019,
  'comparar_baplie': 0xE01A,
  'baplie_salida': 0xE01B,
  'listado_agencia': 0xE01C,
  'al_dia': 0xE01D,
  'solo_aqui': 0xE01E,
  'insignia_refrigerado': 0xE01F,
  'insignia_peligrosa': 0xE020,
  'insignia_fuera_de_medida': 0xE021,
  'insignia_vacio': 0xE022,
};

/// El SVG de un glifo del paquete.
String _rutaDelSvg(String nombre) => nombre.startsWith('insignia_')
    ? 'design/iconos/svg_insignias/${nombre.substring('insignia_'.length)}.svg'
    : 'design/iconos/svg/$nombre.svg';

ui.Picture _glifo(IconData icono, double lado) {
  final grabadora = ui.PictureRecorder();
  final pintor = TextPainter(
    text: TextSpan(
      text: String.fromCharCode(icono.codePoint),
      style: TextStyle(
        fontFamily: icono.fontFamily,
        fontSize: lado,
        color: const Color(0xFF000000),
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  pintor.paint(Canvas(grabadora), Offset.zero);
  pintor.dispose();
  return grabadora.endRecording();
}

ui.Picture _svg(String nombre, double lado) {
  final texto = File(_rutaDelSvg(nombre)).readAsStringSync();
  final rejilla = double.parse(
      RegExp(r'viewBox="0 0 (\d+) (\d+)"').firstMatch(texto)!.group(1)!);
  final rutas = RegExp(r' d="([^"]+)"').allMatches(texto).toList();
  expect(rutas, hasLength(1), reason: '$nombre: un solo path');
  final escalaInterna = texto.contains('transform="scale(0.5)"') ? 0.5 : 1.0;
  final grabadora = ui.PictureRecorder();
  Canvas(grabadora)
    ..scale(lado / rejilla)
    ..scale(escalaInterna)
    ..drawPath(
      rutaDeIlustracion(rutas.single.group(1)!),
      Paint()..color = const Color(0xFF000000),
    );
  return grabadora.endRecording();
}

Future<List<int>> _alfas(ui.Picture dibujo, int lado) async {
  final imagen = await dibujo.toImage(lado, lado);
  final bytes = await imagen.toByteData(format: ui.ImageByteFormat.rawRgba);
  imagen.dispose();
  dibujo.dispose();
  final rgba = bytes!.buffer.asUint8List();
  return <int>[for (var i = 3; i < rgba.length; i += 4) rgba[i]];
}

/// `testWidgets` con las fuentes del producto cargadas: las medidas son las
/// de Plex y el ícono es el glifo del paquete, no la fuente cuadrada.
void _prueba(String descripcion, WidgetTesterCallback cuerpo) =>
    testWidgets(descripcion, (tester) async {
      await t117CargarFuentes();
      await cuerpo(tester);
    });

void main() {
  group('la pieza', () {
    for (final muelle in <bool>[true, false]) {
      final medidas = muelle ? BsMedidas.muelle : BsMedidas.oficina;
      final densidad = muelle ? 'el muelle' : 'la oficina';
      for (final equipo in BsEquipo.values) {
        _prueba(
            '${equipo.rotulo}, completo en $densidad: alto visible, zona de 48, '
            'ícono y rótulo', (tester) async {
          await tester.pumpWidget(_envuelve(
              BsDistintivoDeRol(equipo: equipo, onTap: () {}),
              muelle: muelle));
          expect(tester.getSize(_pildora).height, medidas.alturaChip);
          expect(tester.getSize(_zona).height, medidas.objetivoTactil);
          expect(tester.getSize(_zona).width,
              greaterThanOrEqualTo(medidas.objetivoTactil));
          final icono = tester.widget<Icon>(find.byIcon(
              equipo == BsEquipo.muelle ? BsIconos.muelle : BsIconos.oficina));
          expect(icono.size, muelle ? 20 : 18);
          final metal = BsDistintivoDeRol.metalDe(equipo, BsPaleta.claro);
          expect(icono.color, metal.icono);
          final rotulo = tester.widget<Text>(find.text(equipo.rotulo));
          final tema = Theme.of(tester.element(_pildora));
          expect(rotulo.style!.fontFamily, BsFuentes.condensada);
          expect(rotulo.style!.fontWeight, FontWeight.w600);
          expect(rotulo.style!.fontSize, tema.textTheme.labelLarge!.fontSize);
          expect(rotulo.style!.color, metal.rotulo);
          expect(tester.takeException(), isNull);
        });

        _prueba('${equipo.rotulo}, compacto en $densidad: el círculo con el ícono',
            (tester) async {
          await tester.pumpWidget(_envuelve(
              BsDistintivoDeRol(equipo: equipo, compacto: true, onTap: () {}),
              muelle: muelle));
          expect(tester.getSize(_pildora),
              Size.square(medidas.alturaChip));
          expect(tester.getSize(_zona), Size.square(medidas.objetivoTactil));
          expect(find.text(equipo.rotulo), findsNothing);
          expect(find.byType(Icon), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      }
    }

    _prueba('con la letra a 2.0 la píldora crece en alto y nada se corta',
        (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(_envuelve(_cuatro(), muelle: false));
      for (final equipo in BsEquipo.values) {
        final rotulo = find.text(equipo.rotulo);
        expect(tester.renderObject<RenderParagraph>(rotulo).didExceedMaxLines,
            isFalse);
        final pildora = find.ancestor(of: rotulo, matching: _pildora);
        expect(tester.getSize(pildora).height,
            greaterThan(BsMedidas.oficina.alturaChip));
        expect(tester.getRect(rotulo).top,
            greaterThanOrEqualTo(tester.getRect(pildora).top));
        expect(tester.getRect(rotulo).bottom,
            lessThanOrEqualTo(tester.getRect(pildora).bottom));
      }
      expect(tester.takeException(), isNull);
    });

    _prueba('para el lector de pantalla es el botón «Rol: …» con su pista; '
        'la descripción emergente dice el rol fuera de la semántica',
        (tester) async {
      final semantica = tester.ensureSemantics();
      await tester.pumpWidget(_envuelve(_cuatro(), muelle: false));
      for (final equipo in BsEquipo.values) {
        final nodos = find.bySemanticsLabel('Rol: ${equipo.rotulo}');
        expect(nodos, findsNWidgets(2), reason: 'completo y compacto');
        for (var i = 0; i < 2; i++) {
          expect(
              tester.getSemantics(nodos.at(i)),
              matchesSemantics(
                label: 'Rol: ${equipo.rotulo}',
                hint: 'Abre Nube y cuenta',
                isButton: true,
                hasTapAction: true,
              ));
        }
      }
      final mensajes = tester
          .widgetList<Tooltip>(find.byType(Tooltip))
          .map((t) => t.message)
          .toList();
      expect(mensajes, <String>[
        'Rol: Muelle',
        'Rol: Muelle',
        'Rol: Oficina',
        'Rol: Oficina',
      ]);
      expect(
          tester
              .widgetList<Tooltip>(find.byType(Tooltip))
              .every((t) => t.excludeFromSemantics == true),
          isTrue);
      semantica.dispose();
    });

    for (final compacto in <bool>[false, true]) {
      _prueba(
          '${compacto ? 'compacto' : 'completo'}: se toca en la píldora y en el '
          'margen de la zona de 48', (tester) async {
        var toques = 0;
        await tester.pumpWidget(_envuelve(
            BsDistintivoDeRol(
                equipo: BsEquipo.oficina,
                compacto: compacto,
                onTap: () => toques++),
            muelle: false));
        final pildora = tester.getRect(_pildora);
        final zona = tester.getRect(_zona);
        expect(zona.height - pildora.height, 16, reason: '8 dp arriba y abajo');
        await tester.tapAt(pildora.center);
        expect(toques, 1);
        await tester.tapAt(Offset(pildora.center.dx, zona.top + 2));
        expect(toques, 2, reason: 'arriba, fuera de la píldora');
        await tester.tapAt(Offset(pildora.center.dx, zona.bottom - 2));
        expect(toques, 3, reason: 'abajo, fuera de la píldora');
        if (compacto) {
          await tester.tapAt(zona.topLeft + const Offset(2, 2));
          expect(toques, 4, reason: 'la esquina de la zona');
        }
        await tester.tapAt(Offset(pildora.center.dx, zona.top - 4));
        expect(toques, compacto ? 4 : 3, reason: 'fuera de la zona no cuenta');
        await tester.pumpAndSettle();
      });
    }

    _prueba('sin animación: quieto en reposo, sin cuadros ni tickers',
        (tester) async {
      await tester.pumpWidget(_envuelve(_cuatro()));
      await tester.pump();
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(SchedulerBinding.instance.transientCallbackCount, 0);
    });

    for (final oscuro in <bool>[false, true]) {
      for (final muelle in <bool>[true, false]) {
        final modo = '${oscuro ? 'noche' : 'día'}, ${muelle ? 'muelle' : 'oficina'}';
        for (final sobreLaBanda in <bool>[false, true]) {
          _prueba(
              'las cuatro pautas en $modo, '
              '${sobreLaBanda ? 'sobre la banda' : 'sobre el papel'}',
              (tester) async {
            final semantica = tester.ensureSemantics();
            await tester.pumpWidget(_envuelve(
              Padding(padding: const EdgeInsets.all(16), child: _cuatro()),
              oscuro: oscuro,
              muelle: muelle,
              fondo: sobreLaBanda ? BsPaleta.claro.marcaSuperficie : null,
            ));
            await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
            await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
            await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
            await expectLater(tester, meetsGuideline(textContrastGuideline));
            semantica.dispose();
          });
        }
      }
    }

    _prueba('el metal se pinta: el filo claro a la izquierda y el relleno '
        'azul por dentro', (tester) async {
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_envuelve(RepaintBoundary(
          key: const ValueKey('lienzo'),
          child: BsDistintivoDeRol(equipo: BsEquipo.muelle, onTap: () {}))));
      final lienzo = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(const ValueKey('lienzo')));
      final pildora = tester.getRect(_pildora)
          .shift(-tester.getTopLeft(find.byKey(const ValueKey('lienzo'))));
      late Color filo;
      late Color relleno;
      await tester.runAsync(() async {
        final imagen = await lienzo.toImage(pixelRatio: 3);
        final datos = (await imagen.toByteData())!;
        Color pixel(Offset p) {
          final i = ((p.dy * 3).floor() * imagen.width + (p.dx * 3).floor()) * 4;
          return Color.fromARGB(datos.getUint8(i + 3), datos.getUint8(i),
              datos.getUint8(i + 1), datos.getUint8(i + 2));
        }

        // A media altura: en el filo izquierdo (0.75 dp por dentro) y en el
        // relleno, entre el filo y el ícono (a 6 dp del borde).
        filo = pixel(Offset(pildora.left + 0.75, pildora.center.dy));
        relleno = pixel(Offset(pildora.left + 6, pildora.center.dy));
        imagen.dispose();
      });
      final metal = BsPaleta.claro.metalMuelle;
      expect(_luminancia(filo), greaterThan(_luminancia(metal.filoOscuro)),
          reason: 'el filo izquierdo va entre el claro y el del medio: $filo');
      expect(_contraste(relleno, metal.fondoArriba), lessThan(1.3),
          reason: 'el relleno es el azul del fondo: $relleno');
    });
  });

  group('el contraste, compuesto', () {
    test('el metal no cambia con el tema y es el de la especificación', () {
      expect(identical(BsPaleta.claro.metalMuelle, BsPaleta.oscuro.metalMuelle),
          isTrue);
      expect(identical(BsPaleta.claro.metalOficina, BsPaleta.oscuro.metalOficina),
          isTrue);
      final cobre = BsPaleta.claro.metalMuelle;
      expect(<Color>[
        cobre.fondoArriba,
        cobre.fondoAbajo,
        cobre.filoClaro,
        cobre.filoMedio,
        cobre.filoOscuro,
        cobre.icono,
        cobre.rotulo,
      ], const <Color>[
        Color(0xFF0B3E93),
        Color(0xFF082F70),
        Color(0xFFF8D2B6),
        Color(0xFFE0895A),
        Color(0xFF9E5530),
        Color(0xFFF4B48E),
        Color(0xFFFFFFFF),
      ]);
      final oro = BsPaleta.claro.metalOficina;
      expect(<Color>[
        oro.fondoArriba,
        oro.fondoAbajo,
        oro.filoClaro,
        oro.filoMedio,
        oro.filoOscuro,
        oro.icono,
        oro.rotulo,
      ], const <Color>[
        Color(0xFF16305C),
        Color(0xFF0E2244),
        Color(0xFFFFF0C4),
        Color(0xFFF2C46D),
        Color(0xFFA87A2C),
        Color(0xFFF2C46D),
        Color(0xFFF4F6FB),
      ]);
      expect(BsMetalDeRol.paradaMedia, 0.55);
      expect(cobre.brillo.a, closeTo(0.18, 0.003));
      expect(oro.brillo.a, closeTo(0.14, 0.003));
    });

    for (final equipo in BsEquipo.values) {
      test('${equipo.rotulo}: el rótulo a 4.5:1 y el ícono a 3:1 sobre los dos '
          'extremos del fondo', () {
        final metal = BsDistintivoDeRol.metalDe(equipo, BsPaleta.claro);
        for (final fondo in <Color>[metal.fondoArriba, metal.fondoAbajo]) {
          expect(_contraste(metal.rotulo, fondo), greaterThanOrEqualTo(4.5));
          expect(_contraste(metal.icono, fondo), greaterThanOrEqualTo(3));
        }
      });

      for (final oscuro in <bool>[false, true]) {
        test(
            '${equipo.rotulo} en ${oscuro ? 'oscuro' : 'claro'}: el relleno o el '
            'filo a 3:1 contra la banda, la barra superior y la cabecera', () {
          final paleta = oscuro ? BsPaleta.oscuro : BsPaleta.claro;
          final tema = oscuro ? BayStreamTema.oscuro() : BayStreamTema.claro();
          final metal = BsDistintivoDeRol.metalDe(equipo, paleta);
          final donde = <String, Color>{
            'la banda del muelle': paleta.marcaSuperficie,
            'la barra superior': tema.appBarTheme.backgroundColor!,
            'la cabecera de la oficina': tema.scaffoldBackgroundColor,
          };
          for (final lugar in donde.entries) {
            // También con la sombra encima, a su opacidad entera: el peor caso.
            final fondos = <Color>[
              lugar.value,
              Color.alphaBlend(metal.sombra, lugar.value),
            ];
            double peor(Color c) =>
                fondos.map((f) => _contraste(c, f)).reduce(math.min);
            final relleno = math.min(peor(metal.fondoArriba), peor(metal.fondoAbajo));
            final claro = peor(metal.filoClaro);
            final medio = peor(metal.filoMedio);
            final razon = '${lugar.key}: relleno ${relleno.toStringAsFixed(2)}, '
                'filo ${claro.toStringAsFixed(2)} · ${medio.toStringAsFixed(2)} · '
                '${peor(metal.filoOscuro).toStringAsFixed(2)}';
            // El filo se exige en su claro y en su tono del 55 %; el extremo
            // oscuro se informa (Carlos, 2-nov).
            expect(relleno >= 3 || (claro >= 3 && medio >= 3), isTrue,
                reason: razon);
            debugPrint('${equipo.rotulo} ${oscuro ? 'oscuro' : 'claro'} · $razon');
          }
        });
      }
    }

    test('tool/rediseno_contraste.py lleva los mismos colores', () {
      final script = File('tool/rediseno_contraste.py').readAsStringSync();
      final bloque = RegExp(r'METALES = \{(.*?)\n\}', dotAll: true)
          .firstMatch(script)!
          .group(1)!;
      String hex(Color c) => '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
      for (final entrada in <String, BsMetalDeRol>{
        'muelle': BsPaleta.claro.metalMuelle,
        'oficina': BsPaleta.claro.metalOficina,
      }.entries) {
        final metal = entrada.value;
        final rol = RegExp("'${entrada.key}': \\{(.*?)\\}", dotAll: true)
            .firstMatch(bloque)!
            .group(1)!;
        expect(rol, contains("'fondo': ('${hex(metal.fondoArriba)}', '${hex(metal.fondoAbajo)}')"));
        expect(rol, contains("'filo': ('${hex(metal.filoClaro)}', '${hex(metal.filoMedio)}', '${hex(metal.filoOscuro)}')"));
        expect(rol, contains("'icono': '${hex(metal.icono)}'"));
        expect(rol, contains("'rotulo': '${hex(metal.rotulo)}'"));
        final brillo = RegExp(r"'brillo': \('(#[0-9A-F]{6})', ([0-9.]+)\)").firstMatch(rol)!;
        expect(brillo.group(1), hex(metal.brillo));
        expect(double.parse(brillo.group(2)!), closeTo(metal.brillo.a, 0.003));
        final sombra = RegExp(r"'sombra': \('(#[0-9A-F]{6})', ([0-9.]+)\)").firstMatch(rol)!;
        expect(sombra.group(1), hex(metal.sombra));
        expect(double.parse(sombra.group(2)!), closeTo(metal.sombra.a, 0.003));
      }
      expect(script, contains("('la banda del muelle', 'claro y oscuro', '#0D47A1')"));
    });
  });

  group('las vistas previas', () {
    final previas = <String, Widget Function()>{
      'distintivo de rol': vistaPreviaDistintivoDeRol,
      'distintivo de rol, noche': vistaPreviaDistintivoDeRolOscuro,
      'distintivo de rol en la oficina': vistaPreviaDistintivoDeRolOficina,
    };
    for (final previa in previas.entries) {
      _prueba('${previa.key} se construye en el día y en la noche',
          (tester) async {
        tester.view.physicalSize = const Size(600, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        for (final tema in <ThemeData>[
          BayStreamTema.claro(muelle: true),
          BayStreamTema.oscuro(),
        ]) {
          await tester.pumpWidget(MaterialApp(
            theme: tema,
            home: Scaffold(body: SingleChildScrollView(child: previa.value())),
          ));
          await tester.pump(const Duration(milliseconds: 50));
          expect(tester.takeException(), isNull, reason: previa.key);
          expect(find.byType(BsDistintivoDeRol), findsAtLeastNWidgets(4));
        }
        await tester.pumpWidget(const SizedBox());
      });
    }
  });

  group('la fuente del paquete v3', () {
    final codigos = (jsonDecode(File('design/iconos/codigos.json').readAsStringSync())
            as Map<String, dynamic>)['codigos'] as Map<String, dynamic>;

    test('los 35 glifos de antes conservan su código; oficina va en U+E023', () {
      for (final entrada in _codigosDelV2.entries) {
        expect(BsIconosCatalogo.todos[entrada.key]!.codePoint, entrada.value,
            reason: entrada.key);
        expect(codigos[entrada.key], 'U+${entrada.value.toRadixString(16).toUpperCase()}',
            reason: entrada.key);
      }
      expect(BsIconos.oficina.codePoint, 0xE023);
      expect(BsIconos.oficina.fontFamily, BsIconos.familia);
      expect(codigos['oficina'], 'U+E023');
      expect(codigos.keys.toSet(), <String>{..._codigosDelV2.keys, 'oficina'});
      expect(BsIconosCatalogo.iconos['oficina'], BsIconos.oficina);
      expect(BsIconosCatalogo.rejillaDe('oficina'), 24);
    });

    test('y su dibujo: los 35 SVG son los del v2, con la huella de «Frente al v2»',
        () {
      final leeme = File('design/iconos/LEEME.md').readAsStringSync().replaceAll('\r\n', '\n');
      final seccion = leeme.substring(
          leeme.indexOf('## Frente al v2'), leeme.indexOf('## Archivos'));
      final huellas = <String, String>{
        for (final m in RegExp(r'^\| `([^`]+)` \| `([0-9a-f]{64})` \|$', multiLine: true)
            .allMatches(seccion))
          m.group(1)!: m.group(2)!,
      };
      for (final nombre in _codigosDelV2.keys) {
        final ruta = _rutaDelSvg(nombre);
        expect(huellas, contains(ruta), reason: '$ruta, igual al v2');
        // Sin el fin de línea de Windows: la huella del paquete es la del LF.
        final bytes = File(ruta).readAsBytesSync().where((b) => b != 0x0D).toList();
        expect(sha256.convert(bytes).toString(), huellas[ruta], reason: ruta);
      }
      expect(huellas.keys, isNot(contains('design/iconos/svg/oficina.svg')));
      expect(File(_rutaDelSvg('oficina')).existsSync(), isTrue);
    });

    for (final lado in <int>[16, 24]) {
      _prueba('los 36 glifos, pintados como texto a $lado px, coinciden con su SVG',
          (tester) async {
        final informe = <String>[];
        await tester.runAsync(() async {
          for (final entrada in BsIconosCatalogo.todos.entries) {
            final texto = await _alfas(_glifo(entrada.value, lado.toDouble()), lado);
            final svg = await _alfas(_svg(entrada.key, lado.toDouble()), lado);
            var distintos = 0;
            var suma = 0;
            var tinta = 0;
            for (var i = 0; i < texto.length; i++) {
              if ((texto[i] > 127) != (svg[i] > 127)) distintos++;
              suma += (texto[i] - svg[i]).abs();
              if (texto[i] > 127) tinta++;
            }
            final total = lado * lado;
            final media = suma / total;
            informe.add('${entrada.key}: $distintos de $total, Δ medio '
                '${media.toStringAsFixed(2)}');
            expect(tinta, greaterThan(0), reason: '${entrada.key} pinta su glifo');
            // La tolerancia de borde de test/t114_iconos_test.dart.
            expect(distintos / total, lessThanOrEqualTo(0.12),
                reason: '${entrada.key} a $lado px: $distintos de $total');
            expect(media, lessThanOrEqualTo(16),
                reason: '${entrada.key} a $lado px: Δ medio $media');
          }
        });
        debugPrint('los 36 a $lado px:\n  ${informe.join('\n  ')}');
      });
    }
  });
}
