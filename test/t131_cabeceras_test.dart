// T-131 · El distintivo de rol en las tres cabeceras (SPRINT-4.md 10.86;
// DESIGN.md 13.12), con un `operatorProvider` falso:
//   - el rol sale de la cuenta: oficina → «Oficina», muelle → «Muelle», la
//     cuenta de la copia local también; sin cuenta o sin autorizar no hay
//     distintivo y la cabecera queda como antes; si el rol cambia, el
//     distintivo cambia sin reiniciar;
//   - tocarlo, completo o compacto, abre «Nube y cuenta»;
//   - en la barra superior del teléfono va completo si cabe; si no,
//     compacto; y solo después el nombre se encoge. En la banda y en la
//     cabecera de la oficina los controles mandan (Carlos, 3-nov): completo,
//     compacto o sin distintivo, y la banda y la cabecera son las mismas que
//     sin cuenta (el alto, las líneas y la forma del selector; la cabecera de
//     1366 con la letra a 2.0, en 92 dp y una línea);
//   - nada se desborda: el teléfono a 360 × 640 y a 360 × 800, la oficina a
//     600 y a 1366 dp de ancho, con la letra a 1.0 y a 2.0;
//   - las cuatro pautas de accesibilidad en las tres cabeceras.
//
// Buque y números sintéticos; las cuentas son sintéticas.
import 'package:baystream/core/design/design.dart';
import 'package:baystream/features/vessel/domain/repositories/session_repository.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_overview_page.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/plano_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/loading_plan_controls.dart'
    show SelectorDelModo;
import 'package:flutter/foundation.dart' show precisionErrorTolerance;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t117_oficina_support.dart' show t117TextosCortados;
import 'support/t131_cabeceras_support.dart';

/// La regla para caber (13.12), en el `BsPrimeraQueCabe` que eligió la forma:
/// compacto si y solo si el completo no entra en el ancho que hay.
void _laFormaQueCabe(WidgetTester tester, Finder donde) {
  final distintivo = t131Distintivo(tester, donde)!;
  final eleccion = find
      .ancestor(
          of: find.descendant(
              of: donde, matching: find.byType(BsDistintivoDeRol)),
          matching: find.byType(BsPrimeraQueCabe))
      .first;
  final caja = tester.renderObject<RenderBox>(eleccion);
  final variantes = <RenderBox>[];
  caja.visitChildren((hijo) => variantes.add(hijo as RenderBox));
  final completo = variantes.first.getMaxIntrinsicWidth(double.infinity);
  final ancho = caja.constraints.maxWidth;
  expect(distintivo.compacto, completo > ancho + precisionErrorTolerance,
      reason: 'el completo mide ${completo.toStringAsFixed(1)} y hay '
          '${ancho.toStringAsFixed(1)} dp');
}

/// La regla de la banda (13.12): completo si cabe con los segmentos enteros;
/// si no, compacto; si ni así, sin distintivo. En los tres casos, Descarga y
/// Carga conservan su rótulo, entero en un renglón, y su ícono.
void _laFormaDeLaBanda(WidgetTester tester) {
  final banda = T131Cabecera.banda.donde;
  final caja = tester.renderObject<RenderBox>(
      find.descendant(of: banda, matching: find.byType(BsPrimeraQueCabe)));
  final variantes = <RenderBox>[];
  caja.visitChildren((hijo) => variantes.add(hijo as RenderBox));
  expect(variantes, hasLength(3), reason: 'completo, compacto y sin distintivo');
  final ancho = caja.constraints.maxWidth + precisionErrorTolerance;
  final completo = variantes[0].getMaxIntrinsicWidth(double.infinity);
  final compacto = variantes[1].getMaxIntrinsicWidth(double.infinity);
  final distintivo = t131Distintivo(tester, banda);
  final medidas = 'completo ${completo.toStringAsFixed(1)}, compacto '
      '${compacto.toStringAsFixed(1)}, hay ${ancho.toStringAsFixed(1)} dp';
  if (completo <= ancho) {
    expect(distintivo?.compacto, isFalse, reason: medidas);
  } else if (compacto <= ancho) {
    expect(distintivo?.compacto, isTrue, reason: medidas);
  } else {
    expect(distintivo, isNull, reason: medidas);
  }
  for (final (rotulo, icono) in <(String, IconData)>[
    ('Descarga', BsIconos.descarga),
    ('Carga', BsIconos.carga),
  ]) {
    final texto = tester.renderObject<RenderParagraph>(
        find.descendant(of: banda, matching: find.text(rotulo)));
    expect(texto.size.width,
        greaterThanOrEqualTo(texto.getMaxIntrinsicWidth(double.infinity) - 0.5),
        reason: '$rotulo entero en un renglón; $medidas');
    expect(find.descendant(of: banda, matching: find.byIcon(icono)),
        findsOneWidget);
  }
}

/// Una oficina ancha: la cabecera lleva el distintivo con los segmentos.
const _ancha = Size(1920, 1080);

/// La cabecera de la oficina como la mide la regla (13.12): su alto, si va en
/// una línea (`Row`) o en dos (`Wrap`) y la forma del selector.
({double alto, Type lineas, BsFormaDelSelector? selector}) _laCabecera(
    WidgetTester tester) {
  final cabecera = T131Cabecera.cabecera.donde;
  final controles = find.descendant(
      of: cabecera, matching: find.byKey(const ValueKey('cabecera-controles')));
  final selector =
      find.descendant(of: cabecera, matching: find.byType(SelectorDelModo));
  return (
    alto: tester.getSize(cabecera).height,
    lineas: tester.widget(controles).runtimeType,
    selector: selector.evaluate().isEmpty
        ? null
        : tester.widget<SelectorDelModo>(selector).forma,
  );
}

/// En la barra superior, el nombre del buque se encoge solo con el
/// distintivo compacto.
void _elNombreSeEncogeDespues(WidgetTester tester, Finder donde, String buque) {
  final nombre = find.descendant(of: donde, matching: find.text(buque));
  final caja = find.ancestor(of: nombre, matching: find.byType(FittedBox)).first;
  final encogido =
      tester.getSize(nombre).width > tester.getSize(caja).width + 0.5;
  if (encogido) {
    expect(t131Distintivo(tester, donde)!.compacto, isTrue,
        reason: 'el nombre se encoge solo después del compacto');
  }
}

void main() {
  group('el rol sale de la cuenta', () {
    for (final donde in T131Cabecera.values) {
      testWidgets('${donde.nombre}: oficina, muelle, sin autorizar, la copia '
          'local y sin cuenta, sin reiniciar', (tester) async {
        // La cabecera, a 1920: ahí el distintivo cabe con los segmentos.
        final cambiar = await t131Pump(tester, donde,
            tamano: donde == T131Cabecera.cabecera ? _ancha : null);
        final region = donde.donde;
        expect(region, findsOneWidget);
        expect(t131Distintivo(tester, region), isNull, reason: 'sin cuenta');
        final sinCuenta = tester.getSize(region);

        cambiar(t131Oficina);
        await tester.pumpAndSettle();
        expect(t131Distintivo(tester, region)?.equipo, BsEquipo.oficina);
        expect(
            find.descendant(of: region, matching: find.byIcon(BsIconos.oficina)),
            findsOneWidget);

        cambiar(t131Muelle);
        await tester.pumpAndSettle();
        expect(t131Distintivo(tester, region)?.equipo, BsEquipo.muelle);
        expect(
            find.descendant(of: region, matching: find.byIcon(BsIconos.muelle)),
            findsOneWidget);

        cambiar(t131SinAutorizar);
        await tester.pumpAndSettle();
        expect(t131Distintivo(tester, region), isNull, reason: 'sin autorizar');
        expect(tester.getSize(region), sinCuenta,
            reason: 'sin distintivo, la cabecera queda como antes');

        cambiar(t131DeLaCopia);
        await tester.pumpAndSettle();
        expect(t131Distintivo(tester, region)?.equipo, BsEquipo.muelle,
            reason: 'la cuenta de la copia local, sin red');

        cambiar(null);
        await tester.pumpAndSettle();
        expect(t131Distintivo(tester, region), isNull);
        expect(tester.getSize(region), sinCuenta);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('con cuenta, el rótulo dice el rol en la cabecera',
        (tester) async {
      await t131Pump(tester, T131Cabecera.cabecera,
          cuenta: t131Oficina, tamano: _ancha);
      expect(
          find.descendant(
              of: T131Cabecera.cabecera.donde, matching: find.text('Oficina')),
          findsOneWidget);
    });
  });

  group('tocarlo abre «Nube y cuenta»', () {
    // Completo en la barra de la oficina a 390; compacto en la barra de 360
    // con un nombre largo, donde el completo no cabe.
    for (final (donde, cuenta, compacto) in <(T131Cabecera, Operator, bool)>[
      (T131Cabecera.barraDeLaOficina, t131Oficina, false),
      (T131Cabecera.barraDelMuelle, t131Muelle, true),
    ]) {
      testWidgets(
          '${compacto ? 'compacto' : 'completo'}, en ${donde.nombre}',
          (tester) async {
        await t131Pump(tester, donde,
            cuenta: cuenta, voyage: compacto ? t131NombreLargo : null);
        final distintivo = t131Distintivo(tester, donde.donde)!;
        expect(distintivo.compacto, compacto);
        expect(find.text('Nube y cuenta'), findsNothing);
        await tester.tap(find.descendant(
            of: donde.donde, matching: find.byType(BsDistintivoDeRol)));
        await tester.pumpAndSettle();
        expect(find.text('Nube y cuenta'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('la forma que cabe', () {
    testWidgets('en la barra de 360 con un nombre largo: compacto, y el nombre '
        'se encoge', (tester) async {
      await t131Pump(tester, T131Cabecera.barraDelMuelle,
          cuenta: t131Muelle, voyage: t131NombreLargo);
      final donde = T131Cabecera.barraDelMuelle.donde;
      expect(t131Distintivo(tester, donde)!.compacto, isTrue);
      _laFormaQueCabe(tester, donde);
      final nombre = find.descendant(
          of: donde, matching: find.text(t131NombreLargo.vessel.name));
      final caja =
          find.ancestor(of: nombre, matching: find.byType(FittedBox)).first;
      expect(tester.getSize(nombre).width,
          greaterThan(tester.getSize(caja).width));
      expect(tester.takeException(), isNull);
    });

    // Los controles mandan y la cabecera no crece por el distintivo (Carlos,
    // 3-nov): con cualquier cuenta es la misma que sin cuenta. T-143: con la
    // operación publicada o cerrada; el plano solo confirmado aquí tiene sus
    // propios casos (el grupo de «Confirmado», más abajo).
    for (final cerrada in <bool>[false, true]) {
    for (final ancho in <double>[600, 1366]) {
      for (final letra in <double>[1.0, 2.0]) {
        testWidgets(
            'la cabecera de la oficina a ${ancho.toInt()} con la letra a $letra, '
            '${cerrada ? 'cerrada' : 'publicada'}, '
            'es la misma que sin distintivo: el alto, las líneas y el selector',
            (tester) async {
          final operacion = t131Operacion(cerrada: cerrada);
          final cambiar = await t131Pump(tester, T131Cabecera.cabecera,
              tamano: Size(ancho, ancho == 600 ? 800 : 768),
              letra: letra,
              operacion: () => operacion);
          expect(find.text(cerrada ? 'Cerrada' : 'Publicada'), findsOneWidget);
          final sinCuenta = _laCabecera(tester);
          if (ancho == 1366 && letra == 2.0) {
            expect(sinCuenta.alto, 92, reason: 'en 92 dp');
            expect(sinCuenta.lineas, Row, reason: 'en una línea');
          }
          for (final cuenta in <Operator>[t131Oficina, t131Muelle]) {
            cambiar(cuenta);
            await tester.pumpAndSettle();
            expect(_laCabecera(tester), sinCuenta,
                reason: 'con la cuenta de ${cuenta.role.name}');
            final distintivo =
                t131Distintivo(tester, T131Cabecera.cabecera.donde);
            debugPrint('CABECERA · ${ancho.toInt()} · letra $letra · '
                '${cuenta.role.name}: ${distintivo == null ? 'sin distintivo' : distintivo.compacto ? 'compacto' : 'completo'}'
                ' · ${sinCuenta.alto} dp · ${sinCuenta.lineas == Row ? 'una línea' : 'dos líneas'}'
                ' · selector en ${sinCuenta.selector?.name}');
          }
          expect(tester.takeException(), isNull);
        });
      }
    }
    }

    for (final (letra, forma) in <(double, String)>[
      (1.0, 'compacto'),
      (2.0, 'sin distintivo'),
    ]) {
      testWidgets(
          'en la banda a 360 × 800 con la letra a $letra: $forma, con Descarga y '
          'Carga enteras y la banda del alto de antes', (tester) async {
        final cambiar = await t131Pump(tester, T131Cabecera.banda, letra: letra);
        final banda = T131Cabecera.banda.donde;
        final sinCuenta = tester.getSize(banda);
        cambiar(t131Muelle);
        await tester.pumpAndSettle();
        _laFormaDeLaBanda(tester);
        final distintivo = t131Distintivo(tester, banda);
        expect(
            distintivo == null
                ? 'sin distintivo'
                : distintivo.compacto
                    ? 'compacto'
                    : 'completo',
            forma);
        expect(tester.getSize(banda), sinCuenta);
        expect(tester.takeException(), isNull);
      });
    }

  });

  group('nada se desborda', () {
    for (final donde in T131Cabecera.values) {
      final tamanos = donde == T131Cabecera.cabecera
          ? const <Size>[Size(600, 800), Size(1366, 768)]
          : const <Size>[Size(360, 640), Size(360, 800)];
      for (final tamano in tamanos) {
        for (final letra in <double>[1.0, 2.0]) {
          for (final cuenta in <Operator>[t131Oficina, t131Muelle]) {
            final rol = cuenta == t131Oficina ? 'oficina' : 'muelle';
            testWidgets(
                '${donde.nombre} a ${tamano.width.toInt()} × '
                '${tamano.height.toInt()}, letra $letra, cuenta de $rol',
                (tester) async {
              await t131Pump(tester, donde,
                  cuenta: cuenta, tamano: tamano, letra: letra);
              expect(tester.takeException(), isNull);
              final region = donde.donde;
              final distintivo = find.descendant(
                  of: region, matching: find.byType(BsDistintivoDeRol));
              if (donde == T131Cabecera.cabecera) {
                final buscar = tester.getRect(
                    find.byKey(const ValueKey('buscar-contenedor')));
                expect(buscar.right, lessThanOrEqualTo(tamano.width));
              }
              // En la banda y en la cabecera de la oficina el distintivo cede
              // y puede no ir (13.12): ahí no hay más que medir.
              if (donde == T131Cabecera.banda) _laFormaDeLaBanda(tester);
              if (donde == T131Cabecera.banda ||
                  donde == T131Cabecera.cabecera) {
                if (distintivo.evaluate().isEmpty) {
                  debugPrint('FORMA · ${donde.nombre} · ${tamano.width.toInt()} × '
                      '${tamano.height.toInt()} · letra $letra · $rol: sin '
                      'distintivo · alto de la cabecera '
                      '${tester.getSize(region).height}');
                  return;
                }
              }
              expect(distintivo, findsOneWidget);
              final caja = tester.getRect(distintivo);
              final pantalla = Offset.zero & tamano;
              expect(pantalla.contains(caja.topLeft) &&
                      pantalla.contains(caja.bottomRight - const Offset(0.01, 0.01)),
                  isTrue,
                  reason: 'el distintivo, en la pantalla: $caja');
              final contenedor = tester.getRect(region);
              expect(caja.top, greaterThanOrEqualTo(contenedor.top - 0.01));
              expect(caja.bottom, lessThanOrEqualTo(contenedor.bottom + 0.01),
                  reason: 'la barra de 56 no lo recorta');
              debugPrint('FORMA · ${donde.nombre} · ${tamano.width.toInt()} × '
                  '${tamano.height.toInt()} · letra $letra · $rol: '
                  '${tester.widget<BsDistintivoDeRol>(distintivo).compacto ? 'compacto' : 'completo'}'
                  ' · alto de la cabecera ${tester.getSize(region).height}');
              if (donde == T131Cabecera.barraDelMuelle ||
                  donde == T131Cabecera.barraDeLaOficina) {
                _laFormaQueCabe(tester, region);
              }
              if (donde == T131Cabecera.barraDelMuelle ||
                  donde == T131Cabecera.barraDeLaOficina) {
                _elNombreSeEncogeDespues(tester, region, 'BUQUE MANUAL');
              }
            });
          }
        }
      }
    }
  });

  // En la oficina, las cuatro pautas en la pantalla entera. En el teléfono, la
  // de toque y la de etiqueta se miden en la cabecera: debajo, la línea del
  // resumen del plano («Bahía 02, carga: nada pendiente»), que T-131 no toca,
  // es un botón de 21 dp de alto y no pasa androidTapTargetGuideline. El
  // contraste se mide en la pantalla entera y lo que falle tiene que estar
  // fuera de la cabecera: en la oficina del teléfono, de día, el peso por pila
  // «110.0+?» (11 px en tinta suave, 4.33:1) falla igual sin cuenta. Las dos
  // se anotan en docs/T131-RESULTADOS.md.
  group('las cuatro pautas en las cabeceras', () {
    for (final (donde, cuenta) in <(T131Cabecera, Operator)>[
      (T131Cabecera.banda, t131Muelle),
      (T131Cabecera.barraDeLaOficina, t131Oficina),
      (T131Cabecera.cabecera, t131Oficina),
    ]) {
      for (final oscuro in <bool>[false, true]) {
        testWidgets('${donde.nombre}, ${oscuro ? 'noche' : 'día'}',
            (tester) async {
          final semantica = tester.ensureSemantics();
          await t131Pump(tester, donde, cuenta: cuenta, oscuro: oscuro);
          if (donde == T131Cabecera.cabecera) {
            await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
            await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
            await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
            await expectLater(tester, meetsGuideline(textContrastGuideline));
          } else {
            _tocablesDeLaCabecera(tester, donde.donde);
            final contraste = await textContrastGuideline.evaluate(tester);
            final fuera = <String>[
              for (final m in RegExp(r'label: "([^"]*)"')
                  .allMatches(contraste.reason ?? ''))
                m.group(1)!,
            ];
            for (final texto in fuera) {
              expect(find.descendant(of: donde.donde, matching: find.text(texto)),
                  findsNothing,
                  reason: '«$texto» bajo 4.5:1 está en la cabecera');
            }
            if (!contraste.passed) {
              debugPrint('${donde.nombre}, ${oscuro ? 'noche' : 'día'}: fuera de '
                  'la cabecera: ${contraste.reason}');
            }
            expect(contraste.passed || fuera.isNotEmpty, isTrue,
                reason: 'si falla, se sabe qué: ${contraste.reason}');
          }
          semantica.dispose();
        });
      }
    }
  });

  // T-143 (O-139-7; Carlos y Yov, 11-nov) · La píldora dice «Confirmado» con
  // el plano solo confirmado aquí, una palabra más ancha que «Publicado». Es
  // la única excepción a la línea de 92 dp: solo en ese estado y solo cuando
  // no cabe, la cabecera va en dos líneas (DESIGN.md 14.8). Con «Publicada» y
  // «Cerrada», los casos de arriba siguen exigiendo la línea de 92 dp.
  group('el estado «Confirmado» (T-143)', () {
    testWidgets('a 1366 con la letra a 2.0: dos líneas de 144 dp, nada cortado',
        (tester) async {
      await t131Pump(tester, T131Cabecera.cabecera,
          tamano: const Size(1366, 768), letra: 2.0);
      final cabecera = T131Cabecera.cabecera.donde;
      expect(find.descendant(of: cabecera, matching: find.text('Confirmado')),
          findsOneWidget);
      final forma = _laCabecera(tester);
      expect(forma.alto, 144, reason: 'en 144 dp');
      expect(forma.lineas, Wrap, reason: 'en dos líneas');
      expect(t117TextosCortados(tester, cabecera), isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a 1920 con la letra a 2.0, donde trabajan los planificadores: '
        'una línea', (tester) async {
      await t131Pump(tester, T131Cabecera.cabecera,
          tamano: const Size(1920, 1080), letra: 2.0);
      final cabecera = T131Cabecera.cabecera.donde;
      expect(find.descendant(of: cabecera, matching: find.text('Confirmado')),
          findsOneWidget);
      final forma = _laCabecera(tester);
      expect(forma.lineas, Row, reason: 'en una línea');
      expect(forma.alto, 92, reason: 'el alto de la línea única');
      expect(t117TextosCortados(tester, cabecera), isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'al publicar, la cabecera pasa de dos líneas a una sin perder la bahía, '
        'el zoom ni el desplazamiento del plano', (tester) async {
      var operacion = t131Operacion(publicada: false);
      await t131Pump(tester, T131Cabecera.cabecera,
          tamano: const Size(1366, 768),
          letra: 2.0,
          operacion: () => operacion);
      final scope = ProviderScope.containerOf(
          tester.element(find.byType(VesselOverviewPage)));
      // El planificador mira la bahía 006 al 200 % y desplazó la rejilla.
      scope.read(selectedBayProvider.notifier).select(6);
      scope.read(planZoomProvider.notifier).fijar(2.0);
      await tester.pumpAndSettle();
      ScrollPosition rejilla() => tester
          .state<ScrollableState>(find
              .descendant(
                  of: find.byKey(const ValueKey('rejilla-horizontal')),
                  matching: find.byType(Scrollable))
              .first)
          .position;
      expect(rejilla().maxScrollExtent, greaterThan(0),
          reason: 'al 200 % la rejilla se desplaza');
      rejilla().jumpTo(rejilla().maxScrollExtent / 2);
      await tester.pumpAndSettle();
      final desplazamiento = rejilla().pixels;
      expect(_laCabecera(tester).lineas, Wrap);
      expect(find.text('Confirmado'), findsOneWidget);

      // Publicar: la oficina vuelve a leer la operación (cloud_page.dart).
      operacion = t131Operacion();
      scope.read(operationSourcesRevisionProvider.notifier).changed();
      await tester.pumpAndSettle();
      expect(find.text('Publicada'), findsOneWidget);
      final forma = _laCabecera(tester);
      expect(forma.lineas, Row, reason: 'una línea');
      expect(forma.alto, 92);
      expect(scope.read(selectedBayProvider), 6, reason: 'la misma bahía');
      expect(scope.read(planZoomProvider), 2.0, reason: 'el mismo zoom');
      expect(rejilla().pixels, desplazamiento,
          reason: 'el mismo desplazamiento de la rejilla');
      expect(tester.takeException(), isNull);
    });
  });
}

/// Las pautas de toque (48 dp en Android, 44 en iOS) y de etiqueta, como
/// las de `flutter_test`, solo para lo que se toca dentro de [donde].
void _tocablesDeLaCabecera(WidgetTester tester, Finder donde) {
  final cabecera = tester.getRect(donde);
  final revisados = <String>[];
  void recorrer(SemanticsNode nodo, Matrix4 transformacion) {
    final propia = nodo.transform == null
        ? transformacion
        : (transformacion.clone()..multiply(nodo.transform!));
    final caja = MatrixUtils.transformRect(propia, nodo.rect);
    final datos = nodo.getSemanticsData();
    final tocable = datos.hasAction(SemanticsAction.tap) ||
        datos.hasAction(SemanticsAction.longPress);
    if (tocable &&
        !nodo.isMergedIntoParent &&
        cabecera.contains(caja.center)) {
      revisados.add(datos.label);
      expect(caja.width, greaterThanOrEqualTo(48 - 0.01), reason: '$datos');
      expect(caja.height, greaterThanOrEqualTo(48 - 0.01), reason: '$datos');
      expect(datos.label.trim().isNotEmpty || datos.tooltip.trim().isNotEmpty,
          isTrue,
          reason: 'sin etiqueta: $datos');
    }
    nodo.visitChildren((hijo) {
      recorrer(hijo, propia);
      return true;
    });
  }

  // La vista de la prueba va a 1 píxel por dp: la raíz no escala.
  recorrer(
      tester.binding.renderViews.single.owner!.semanticsOwner!.rootSemanticsNode!,
      Matrix4.identity());
  expect(revisados, contains(startsWith('Rol: ')),
      reason: 'el distintivo es uno de los revisados: $revisados');
}
