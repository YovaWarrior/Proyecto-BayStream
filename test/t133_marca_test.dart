// T-133 · La marca no tapa el número de orden (10.85, hallazgo 7; DESIGN.md
// 13.13). En la tercera prueba piloto, 8 celdas de la bahía 10 decían
// «Revisar» y no dejaban ver el OR, y eran las que había que comparar con el
// papel. Ahora el código sigue siendo el texto grande y la marca va debajo,
// como segunda línea, con su icono y su rótulo corto; si no caben las dos,
// gana el código y la marca queda en su color y en su icono.
//
// Con las fuentes del producto, para que el rótulo se mida como en el equipo.
import 'dart:math' as math;

import 'package:baystream/core/design/design.dart';
import 'package:baystream/core/design/vistas_previas.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/providers/plano_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/loading_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t117_oficina_support.dart'
    show t117CargarFuentes, t117TextosCortados;
import 'support/t133_marca_support.dart';

double _contraste(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

// Los temas se construyen una sola vez: un `ThemeData` nuevo en cada `pump`
// hace que `AnimatedTheme` interpole.
final Map<(bool, bool), ThemeData> _temas = <(bool, bool), ThemeData>{};
ThemeData _tema({required bool oscuro, required bool muelle}) =>
    _temas.putIfAbsent(
        (oscuro, muelle),
        () => oscuro
            ? BayStreamTema.oscuro(muelle: muelle)
            : BayStreamTema.claro(muelle: muelle));

Widget _envuelve(
  Widget hijo, {
  bool oscuro = false,
  bool muelle = true,
  double letra = 1.0,
  bool sinMovimiento = true,
  Color? fondo,
}) {
  final tema = _tema(oscuro: oscuro, muelle: muelle);
  return MaterialApp(
    theme: tema,
    builder: (BuildContext context, Widget? child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(letra),
        disableAnimations: sinMovimiento,
      ),
      child: child!,
    ),
    home: Scaffold(
      body: ColoredBox(
        color: fondo ?? tema.colorScheme.surface,
        child: Center(child: hijo),
      ),
    ),
  );
}

/// [hijo] con la celda de [ancho], como la ensancha la rejilla con la letra
/// del sistema (`BayPlanView`).
Widget _conAncho(ThemeData base, double ancho, Widget hijo) => Theme(
      data: base.copyWith(extensions: <ThemeExtension<Object?>>[
        ...base.extensions.values.where((e) => e is! BsMedidas),
        base.extension<BsMedidas>()!.copyWith(anchoCelda: ancho),
      ]),
      child: hijo,
    );

/// Los textos de la celda, de arriba abajo.
List<RichText> _textos(WidgetTester tester, [Finder? celda]) => tester
    .widgetList<RichText>(find.descendant(
        of: celda ?? find.byType(BsCelda), matching: find.byType(RichText)))
    .where((r) {
      final familia = (r.text as TextSpan).style?.fontFamily;
      return familia != 'MaterialIcons' && familia != BsIconos.familia;
    }).toList();

/// El rótulo de cada marca, como lo dibuja la celda.
const _rotulos = <BsMarcaDeCelda, String>{
  BsMarcaDeCelda.baja: 'Baja',
  BsMarcaDeCelda.sube: 'Sube',
  BsMarcaDeCelda.hecho: 'Hecho',
  BsMarcaDeCelda.paso: 'Paso',
  BsMarcaDeCelda.cancelado: 'Cancel.',
  BsMarcaDeCelda.revisar: 'Revisar',
  BsMarcaDeCelda.reestiba: 'Re‑est.',
};

const _iconos = <BsMarcaDeCelda, IconData>{
  BsMarcaDeCelda.baja: BsIconos.descarga,
  BsMarcaDeCelda.sube: BsIconos.carga,
  BsMarcaDeCelda.hecho: Icons.check_circle,
  BsMarcaDeCelda.paso: BsIconos.buque,
  BsMarcaDeCelda.cancelado: Icons.block,
  BsMarcaDeCelda.revisar: Icons.error,
  BsMarcaDeCelda.reestiba: BsIconos.reestiba,
};

void main() {
  setUpAll(t117CargarFuentes);

  group('la pieza', () {
    for (final muelle in <bool>[true, false]) {
      final densidad = muelle ? 'muelle' : 'oficina';
      testWidgets(
          'con marca, el código es el texto grande y la marca va debajo, '
          'con icono y rótulo ($densidad)', (tester) async {
        for (final marca in _rotulos.keys) {
          await tester.pumpWidget(_envuelve(
            BsCelda(
              codigo: 'OR 142',
              marca: marca,
              etiqueta: 'marca ${marca.name}',
              onTap: () {},
            ),
            muelle: muelle,
          ));
          final donde = '${marca.name}, $densidad';
          expect(tester.takeException(), isNull, reason: donde);
          final textos = _textos(tester);
          expect(textos.map((t) => t.text.toPlainText()),
              <String>['OR 142', _rotulos[marca]!],
              reason: donde);
          // El código en la letra de la celda (12) y el rótulo en la de la
          // segunda línea: 10 en la oficina, 11 en el muelle (4.2).
          expect((textos[0].text as TextSpan).style!.fontSize, BsEscala.celda);
          expect((textos[1].text as TextSpan).style!.fontSize,
              muelle ? BsEscala.rotuloMinimo : BsEscala.celdaLinea2,
              reason: donde);
          final codigo = tester.getRect(find.byWidget(textos[0]));
          final rotulo = tester.getRect(find.byWidget(textos[1]));
          expect(rotulo.top, greaterThanOrEqualTo(codigo.bottom - 0.01),
              reason: '$donde: la marca va debajo del código');
          final icono = find.byIcon(_iconos[marca]!);
          expect(icono, findsOneWidget, reason: donde);
          expect(tester.widget<Icon>(icono).size, BsCelda.tamanoIconoDeMarca);
          expect(tester.getCenter(icono).dy, closeTo(rotulo.center.dy, 2),
              reason: '$donde: el icono va en la línea del rótulo');
          expect(t117TextosCortados(tester, find.byType(BsCelda)), isEmpty,
              reason: donde);
        }
      });
    }

    testWidgets('la marca no cambia el relleno ni el borde de su rol',
        (tester) async {
      for (final oscuro in <bool>[false, true]) {
        final s = _tema(oscuro: oscuro, muelle: true)
            .extension<BsColoresSemanticos>()!;
        for (final (marca, rol) in <(BsMarcaDeCelda, BsRol)>[
          (BsMarcaDeCelda.baja, s.pendiente),
          (BsMarcaDeCelda.hecho, s.hecho),
          (BsMarcaDeCelda.paso, s.dePaso),
          (BsMarcaDeCelda.cancelado, s.cancelado),
          (BsMarcaDeCelda.revisar, s.revisar),
          (BsMarcaDeCelda.reestiba, s.enMovimiento),
        ]) {
          await tester.pumpWidget(_envuelve(
            BsCelda(
              codigo: 'OR 67',
              marca: marca,
              categoria: s.categorico('PAMIT'),
              etiqueta: 'c',
            ),
            oscuro: oscuro,
          ));
          await tester.pumpAndSettle();
          final caja = tester.widget<Container>(find
              .descendant(
                  of: find.byType(BsCelda), matching: find.byType(Container))
              .first);
          final decoracion = caja.decoration! as BoxDecoration;
          expect(decoracion.color, rol.relleno, reason: marca.name);
          if (!rol.punteado) {
            expect((decoracion.border! as Border).top.color, rol.contorno,
                reason: marca.name);
          }
          // El código y la marca, en el texto del rol.
          for (final texto in _textos(tester)) {
            expect((texto.text as TextSpan).style!.color, rol.texto,
                reason: marca.name);
          }
        }
      }
    });

    testWidgets(
        'si no caben las dos (la letra a 2.0, el zoom chico), gana el código: '
        'la marca queda en su color y en su icono', (tester) async {
      for (final muelle in <bool>[true, false]) {
        for (final (letra, zoom) in <(double, double)>[(2.0, 1.0), (1.0, 0.75)]) {
          final base = _tema(oscuro: false, muelle: muelle);
          for (final marca in _rotulos.keys) {
            await tester.pumpWidget(_envuelve(
              // A 2.0, la celda con el ancho tope que le da la rejilla.
              _conAncho(
                base,
                base.extension<BsMedidas>()!.anchoCelda * letra,
                BsCelda(
                  codigo: 'OR 142',
                  marca: marca,
                  zoom: zoom,
                  insignia: BsInsigniaDeCelda.peligrosa,
                  etiqueta: 'c',
                ),
              ),
              muelle: muelle,
              letra: letra,
            ));
            final donde =
                '${marca.name}, ${muelle ? 'muelle' : 'oficina'}, letra $letra, zoom $zoom';
            expect(tester.takeException(), isNull, reason: donde);
            expect(_textos(tester).map((t) => t.text.toPlainText()),
                <String>['OR 142'],
                reason: donde);
            expect(find.byIcon(_iconos[marca]!), findsOneWidget, reason: donde);
            expect(find.byIcon(BsIconos.insigniaPeligrosa), findsOneWidget,
                reason: '$donde: la insignia no se va');
            expect(t117TextosCortados(tester, find.byType(BsCelda)), isEmpty,
                reason: donde);
          }
        }
      }
    });

    testWidgets('con la letra a 1.45 la marca cabe en la celda ensanchada',
        (tester) async {
      // La rejilla ensancha la celda con la letra (`BayPlanView`); aquí, con
      // el ancho que le daría a 1.45 en el muelle.
      await tester.pumpWidget(_envuelve(
        _conAncho(
          _tema(oscuro: false, muelle: true),
          72,
          const BsCelda(
              codigo: 'OR 142', marca: BsMarcaDeCelda.revisar, etiqueta: 'c'),
        ),
        letra: 1.45,
      ));
      expect(_textos(tester).map((t) => t.text.toPlainText()),
          <String>['OR 142', 'Revisar']);
      expect(t117TextosCortados(tester, find.byType(BsCelda)), isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets('la etiqueta accesible no cambia: dice el código y la marca',
        (tester) async {
      final semantica = tester.ensureSemantics();
      for (final recien in <bool>[false, true]) {
        await tester.pumpWidget(_envuelve(BsCelda(
          codigo: 'OR 67',
          marca: BsMarcaDeCelda.revisar,
          estado:
              recien ? BsEstadoDeCelda.recienMovido : BsEstadoDeCelda.ninguno,
          etiqueta: 'Reserva 010 01 82 · OR 67 · TSTU0000067, revisar',
          onTap: () {},
        )));
        expect(
            tester.getSemantics(find.byType(BsCelda)).label,
            'Reserva 010 01 82 · OR 67 · TSTU0000067, revisar'
            '${recien ? ', se acaba de mover' : ''}');
        // El código y el rótulo no se leen por separado.
        expect(find.bySemanticsLabel('OR 67'), findsNothing);
        expect(find.bySemanticsLabel('Revisar'), findsNothing);
      }
      semantica.dispose();
    });

    group('con «recién movido»', () {
      for (final muelle in <bool>[true, false]) {
        final densidad = muelle ? 'muelle' : 'oficina';
        testWidgets('el código sigue a la vista y la marca debajo ($densidad)',
            (tester) async {
          for (final (marca, rotulo) in <(BsMarcaDeCelda, String?)>[
            // «Bajando» cabe junto a su icono en la celda de 52 de la
            // oficina, no en la de 56 del muelle, donde el rótulo es de 11.
            (BsMarcaDeCelda.baja, muelle ? null : 'Bajando'),
            // «Subiendo» no cabe en ninguna: queda la flecha.
            (BsMarcaDeCelda.sube, null),
            (BsMarcaDeCelda.revisar, 'Revisar'),
            (BsMarcaDeCelda.cancelado, 'Cancel.'),
          ]) {
            for (final sinMovimiento in <bool>[true, false]) {
              await tester.pumpWidget(_envuelve(
                BsCelda(
                  codigo: 'OR 1',
                  marca: marca,
                  estado: BsEstadoDeCelda.recienMovido,
                  etiqueta: 'OR 1 · TSTU0000001',
                  onTap: () {},
                ),
                muelle: muelle,
                sinMovimiento: sinMovimiento,
              ));
              await tester.pumpAndSettle();
              final donde = '${marca.name}, $densidad, quieta $sinMovimiento';
              expect(tester.takeException(), isNull, reason: donde);
              expect(_textos(tester).map((t) => t.text.toPlainText()),
                  <String>['OR 1', if (rotulo != null) rotulo],
                  reason: donde);
              expect(find.byIcon(_iconos[marca]!), findsOneWidget,
                  reason: donde);
              // El relleno es el naranja de lo que se acaba de mover (13.3).
              final caja = tester.widget<Container>(find
                  .descendant(
                      of: find.byType(BsCelda),
                      matching: find.byType(Container))
                  .first);
              expect((caja.decoration! as BoxDecoration).color,
                  BsColoresSemanticos.de(tester.element(find.byType(BsCelda)))
                      .recienMovido
                      .relleno,
                  reason: donde);
            }
          }
        });
      }
    });

    for (final oscuro in <bool>[false, true]) {
      for (final muelle in <bool>[true, false]) {
        final modo = '${oscuro ? 'oscuro' : 'claro'}, '
            '${muelle ? 'muelle' : 'oficina'}';
        testWidgets(
            'el código, el rótulo y el icono llegan a 4.5:1 y 3:1 sobre cada '
            'relleno de marca, compuestos ($modo)', (tester) async {
          final tema = _tema(oscuro: oscuro, muelle: muelle);
          final s = tema.extension<BsColoresSemanticos>()!;
          final fondos = <String, Color>{
            'papel': tema.colorScheme.surface,
            'cubierta': s.cubierta.relleno,
            'bodega': s.bodega.relleno,
          };
          var medidos = 0;
          for (final fondo in fondos.entries) {
            for (final marca in _rotulos.keys) {
              for (final (variante, celda) in <(String, BsCelda)>[
                (
                  'sola',
                  BsCelda(
                      codigo: 'OR 142',
                      marca: marca,
                      etiqueta: 'c',
                      onTap: () {})
                ),
                (
                  'sobre la categoría',
                  BsCelda(
                      codigo: 'OR 142',
                      marca: marca,
                      categoria: s.categorico('PAMIT'),
                      etiqueta: 'c',
                      onTap: () {})
                ),
                (
                  'atenuada',
                  BsCelda(
                      codigo: 'OR 142',
                      marca: marca,
                      atenuada: true,
                      etiqueta: 'c',
                      onTap: () {})
                ),
                (
                  'recién movida',
                  BsCelda(
                      codigo: 'OR 142',
                      marca: marca,
                      estado: BsEstadoDeCelda.recienMovido,
                      etiqueta: 'c',
                      onTap: () {})
                ),
              ]) {
                await tester.pumpWidget(_envuelve(celda,
                    oscuro: oscuro, muelle: muelle, fondo: fondo.value));
                final donde =
                    '${marca.name} $variante sobre ${fondo.key} en $modo';
                final caja = tester.widget<Container>(find
                    .descendant(
                        of: find.byType(BsCelda),
                        matching: find.byType(Container))
                    .first);
                final relleno = Color.alphaBlend(
                    (caja.decoration! as BoxDecoration).color!, fondo.value);
                var textos = 0;
                var iconos = 0;
                for (final rico in tester.widgetList<RichText>(find.descendant(
                    of: find.byType(BsCelda),
                    matching: find.byType(RichText)))) {
                  final estilo = (rico.text as TextSpan).style!;
                  final esIcono = estilo.fontFamily == 'MaterialIcons' ||
                      estilo.fontFamily == BsIconos.familia;
                  final color = Color.alphaBlend(estilo.color!, relleno);
                  expect(_contraste(color, relleno),
                      greaterThanOrEqualTo(esIcono ? 3.0 : 4.5),
                      reason: '$donde: '
                          '${esIcono ? 'icono' : '«${rico.text.toPlainText()}»'}');
                  esIcono ? iconos++ : textos++;
                }
                expect(textos, greaterThanOrEqualTo(1), reason: donde);
                expect(iconos, 1, reason: donde);
                medidos++;
              }
            }
          }
          expect(medidos, 3 * _rotulos.length * 4);
        });

        testWidgets('las celdas con marca pasan las pautas ($modo)',
            (tester) async {
          final tema = _tema(oscuro: oscuro, muelle: muelle);
          await tester.pumpWidget(_envuelve(
            SizedBox(
              width: 360,
              child: t133Muestrario(tema.extension<BsColoresSemanticos>()!),
            ),
            oscuro: oscuro,
            muelle: muelle,
          ));
          await expectLater(tester, meetsGuideline(textContrastGuideline));
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        });
      }
    }
  });

  testWidgets('la vista previa se construye en el día y en la noche',
      (tester) async {
    for (final tema in <ThemeData>[
      _tema(oscuro: false, muelle: true),
      _tema(oscuro: true, muelle: false),
    ]) {
      await tester.pumpWidget(MaterialApp(
        theme: tema,
        home: Scaffold(body: vistaPreviaCeldasConMarca()),
      ));
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.takeException(), isNull);
      expect(find.text('OR 142'), findsOneWidget);
      expect(find.text('Revisar'), findsWidgets);
    }
    await tester.pumpWidget(const SizedBox());
  });

  group('el caso del piloto: la bahía 10 en Carga', () {
    String claveDe(String posicion) =>
        t133Carga.plan.loadingItemAt(posicion)!.key;

    test('las 8 reservas quedan llenas y en conflicto por otro grupo', () {
      expect(t133Cruce, hasLength(8));
      for (final MapEntry(key: posicion, value: orden) in t133Cruce.entries) {
        final estado = t133Carga.state[claveDe(posicion)]!;
        expect(estado.state, ItemState.moved, reason: posicion);
        expect(estado.inConflict, isTrue, reason: posicion);
        expect(estado.order, orden, reason: posicion);
      }
      expect(
          t133Carga.state.conflicts.where((c) => c.kind == ConflictKind.otherGroup),
          hasLength(8));
      expect(t133Carga.state['C:$t133Cancelado']!.state, ItemState.cancelled);
    });

    for (final muelle in <bool>[true, false]) {
      final densidad = muelle ? 'muelle' : 'oficina';
      testWidgets('cada una deja ver su OR, con «Revisar» debajo ($densidad)',
          (tester) async {
        final semantica = tester.ensureSemantics();
        for (final MapEntry(key: posicion, value: orden) in t133Cruce.entries) {
          final clave = claveDe(posicion);
          await tester.pumpWidget(_envuelve(
            LoadingCell(itemKey: clave, operation: t133Carga, onTap: () {}),
            muelle: muelle,
          ));
          expect(_textos(tester).map((t) => t.text.toPlainText()),
              <String>['OR $orden', 'Revisar'],
              reason: posicion);
          expect(find.byIcon(Icons.error), findsOneWidget, reason: posicion);
          // La etiqueta de T-107, igual que antes.
          expect(tester.getSemantics(find.byType(BsCelda)).label,
              loadingCellSemantics(t133Carga, clave),
              reason: posicion);
          expect(tester.getSemantics(find.byType(BsCelda)).label,
              allOf(contains('OR $orden'), endsWith(', revisar')));
        }
        semantica.dispose();
      });

      testWidgets('el cancelado deja ver su OR, con «Cancel.» debajo ($densidad)',
          (tester) async {
        final semantica = tester.ensureSemantics();
        await tester.pumpWidget(_envuelve(
          LoadingCell(
              itemKey: 'C:$t133Cancelado', operation: t133Carga, onTap: () {}),
          muelle: muelle,
        ));
        expect(_textos(tester).map((t) => t.text.toPlainText()),
            <String>['OR 49', 'Cancel.']);
        expect(find.byIcon(Icons.block), findsOneWidget);
        expect(tester.getSemantics(find.byType(BsCelda)).label,
            'OR 49 · $t133Cancelado, cancelado');
        semantica.dispose();
      });

      testWidgets('recién movida, sigue diciendo su OR y «Revisar» ($densidad)',
          (tester) async {
        final semantica = tester.ensureSemantics();
        final clave = claveDe(t133ReservasCrly.first);
        await tester.pumpWidget(_envuelve(
          LoadingCell(
              itemKey: clave,
              operation: t133Carga,
              recienMovida: true,
              onTap: () {}),
          muelle: muelle,
        ));
        expect(_textos(tester).map((t) => t.text.toPlainText()),
            <String>['OR ${t133Cruce[t133ReservasCrly.first]}', 'Revisar']);
        expect(tester.getSemantics(find.byType(BsCelda)).label,
            '${loadingCellSemantics(t133Carga, clave)}, se acaba de mover');
        semantica.dispose();
      });
    }

    for (final letra in <double>[1.0, 2.0]) {
      testWidgets('el plano a 360 × 640 con la letra a $letra: las 8 con su OR',
          (tester) async {
        await t133PumpCarga(tester, letra: letra);
        for (final MapEntry(key: posicion, value: orden) in t133Cruce.entries) {
          final celda = find.byKey(ValueKey('loading-${claveDe(posicion)}'));
          await tester.ensureVisible(celda);
          await tester.pumpAndSettle();
          final textos = _textos(tester, celda).map((t) => t.text.toPlainText());
          // A 1.0 caben las dos; a 2.0 gana el código y queda el icono.
          expect(textos,
              letra == 1.0 ? <String>['OR $orden', 'Revisar'] : <String>['OR $orden'],
              reason: posicion);
          expect(find.descendant(of: celda, matching: find.byIcon(Icons.error)),
              findsOneWidget,
              reason: posicion);
          expect(t117TextosCortados(tester, celda), isEmpty, reason: posicion);
        }
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('las tres vistas de «Colorear por» no cambian la celda de carga',
        (tester) async {
      for (final vista in ColorearPor.values) {
        // Cada vista en una página nueva, con su propio contenedor.
        await tester.pumpWidget(const SizedBox());
        await t133PumpCarga(tester, vista: vista);
        final celda = find.byKey(
            ValueKey('loading-${claveDe(t133ReservasOne.first)}'));
        await tester.ensureVisible(celda);
        await tester.pumpAndSettle();
        expect(_textos(tester, celda).map((t) => t.text.toPlainText()),
            <String>['OR ${t133Cruce[t133ReservasOne.first]}', 'Revisar'],
            reason: vista.name);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('en la oficina a 1280 × 720, igual', (tester) async {
      await t133PumpCarga(tester, tamano: const Size(1280, 720), muelle: false);
      for (final MapEntry(key: posicion, value: orden) in t133Cruce.entries) {
        final celda = find.byKey(ValueKey('loading-${claveDe(posicion)}'));
        expect(_textos(tester, celda).map((t) => t.text.toPlainText()),
            <String>['OR $orden', 'Revisar'],
            reason: posicion);
      }
      expect(tester.takeException(), isNull);
    });
  });

  group('en Descarga, con las tres vistas', () {
    for (final vista in ColorearPor.values) {
      for (final muelle in <bool>[true, false]) {
        final densidad = muelle ? 'muelle a 360 × 640' : 'oficina a 1280 × 720';
        testWidgets('el conflicto y el cancelado dejan ver su código '
            '(${vista.name}, $densidad)', (tester) async {
          await t133PumpDescarga(tester,
              vista: vista,
              muelle: muelle,
              tamano: muelle ? const Size(360, 640) : const Size(1280, 720));
          // En «Tipo de vacío» el código es el tipo; en las otras, el destino.
          String codigo(String destino) =>
              vista == ColorearPor.tipo ? '45G1' : destino;
          for (final (clave, destino, rotulo, icono)
              in <(String, String, String, IconData)>[
            ('cell-2-82', 'PAMIT', 'Revisar', Icons.error),
            ('cell-3-82', 'GTSTC', 'Cancel.', Icons.block),
          ]) {
            final celda = find.byKey(ValueKey(clave));
            await tester.ensureVisible(celda);
            await tester.pumpAndSettle();
            expect(_textos(tester, celda).map((t) => t.text.toPlainText()),
                <String>[codigo(destino), rotulo],
                reason: '$clave, ${vista.name}');
            expect(find.descendant(of: celda, matching: find.byIcon(icono)),
                findsOneWidget);
            expect(t117TextosCortados(tester, celda), isEmpty);
          }
          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('a 360 × 640 con la letra a 2.0 gana el código', (tester) async {
      await t133PumpDescarga(tester, letra: 2.0);
      for (final (clave, codigo, icono) in <(String, String, IconData)>[
        ('cell-2-82', 'PAMIT', Icons.error),
        ('cell-3-82', 'GTSTC', Icons.block),
      ]) {
        final celda = find.byKey(ValueKey(clave));
        await tester.ensureVisible(celda);
        await tester.pumpAndSettle();
        expect(_textos(tester, celda).map((t) => t.text.toPlainText()),
            <String>[codigo],
            reason: clave);
        expect(find.descendant(of: celda, matching: find.byIcon(icono)),
            findsOneWidget);
        expect(t117TextosCortados(tester, celda), isEmpty);
      }
      expect(tester.takeException(), isNull);
    });
  });
}
