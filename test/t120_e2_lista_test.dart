// T-120, entrega 2 · Lo que dejó la aceptación de la entrega 1 (SPRINT-4.md
// 10.152 y 10.154): la Lista corta desde Estadísticas (D9 precisada en
// `DESIGN.md` 18.5), el cuadro con la Lista arriba antes del salto
// (O-120-4), la Lista con una matrícula repetida y, en el teléfono, la fila
// «Carga especial» con sus tres chips siempre (O-120-5).
//
// Buque sintético (BUQUE LISTA, TSTU) con las fuentes del producto; sin nube
// ni almacén real.
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/navegacion_del_viaje.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t120_lista_support.dart';

const _oficina = Size(1366, 690);
const _telefono = Size(360, 800);

final _lista = find.byKey(const ValueKey('lista-scroll'));

Finder _barra(String inicio) => find.descendant(
    of: find.byKey(const ValueKey('estadisticas-puertos')),
    matching: find.bySemanticsLabel(RegExp('^${RegExp.escape(inicio)}[: ]')));

ScrollPosition _posicion(WidgetTester tester) => tester
    .state<ScrollableState>(
        find.descendant(of: _lista, matching: find.byType(Scrollable)).first)
    .position;

VesselVoyage _leer(String texto) {
  final leido = BaplieParserService().parse(texto);
  return leido.withGeometry(VesselProfile.proposeFrom(leido).geometry);
}

/// [n] contenedores entre GTSTC y USHOU, con VELAG en la posición 7 de cada
/// 100: con 100, una tarjeta de VELAG; con 120, dos. El 97 va sin destino.
VesselVoyage _conVelag(int n) => _leer(t120Baplie(n, puertos: <String>[
      for (var i = 0; i < 100; i++)
        i == 7 ? 'VELAG' : (i.isEven ? 'GTSTC' : 'USHOU'),
    ]));

/// Los múltiplos de 97 hasta 291 van sin destino: con 120, uno; con 200,
/// dos. Con tres puertos, «Sin destino» tiene su barra.
VesselVoyage _pocosPuertos(int n) => _leer(t120Baplie(n,
    puertos: const <String>['GTSTC', 'GTSTC', 'USHOU', 'PAMIT']));

/// El cuerpo de una tarjeta (sin su margen de abajo).
Rect _tarjeta(WidgetTester tester, Element tarjeta) => tester.getRect(find
    .descendant(of: find.byWidget(tarjeta.widget), matching: find.byType(InkWell))
    .first);

void main() {
  group('D9 con una lista corta: el título y todas las tarjetas a la vista '
      '(18.5)', () {
    final casos = <(String, VesselVoyage Function(), String, int)>[
      ('«Sin destino» con una tarjeta', () => _pocosPuertos(120), 'Sin destino', 1),
      ('«Sin destino» con dos tarjetas', () => _pocosPuertos(200), 'Sin destino', 2),
      ('un puerto con una tarjeta', () => _conVelag(100), 'VELAG', 1),
      ('un puerto con dos tarjetas', () => _conVelag(120), 'VELAG', 2),
    ];
    for (final tamano in [_oficina, _telefono]) {
      for (final (nombre, viaje, barra, tarjetas) in casos) {
        testWidgets(
            '$nombre, a ${tamano.width.toInt()} × ${tamano.height.toInt()}, '
            'con la letra a 1.0', (tester) async {
          final semantica = tester.ensureSemantics();
          await t120Pump(tester,
              tamano: tamano,
              voyage: viaje(),
              pestana: DestinoDelViaje.estadisticas);
          await tester.ensureVisible(_barra(barra));
          await tester.pumpAndSettle();
          await tester.tap(_barra(barra));
          await tester.pumpAndSettle();

          final vista = tester.getRect(_lista);
          final titulo = find.textContaining(RegExp(r'^Contenedores \('));
          expect(titulo, findsOneWidget);
          final cajaDelTitulo = tester.getRect(titulo);
          expect(cajaDelTitulo.top, greaterThanOrEqualTo(vista.top - 0.5),
              reason: 'el título a la vista');
          expect(cajaDelTitulo.bottom, lessThanOrEqualTo(vista.bottom + 0.5));

          final construidas = t120Tarjetas().evaluate().toList();
          expect(construidas, hasLength(tarjetas));
          for (final tarjeta in construidas) {
            final caja = _tarjeta(tester, tarjeta);
            expect(caja.top, greaterThanOrEqualTo(vista.top - 0.5),
                reason: 'la tarjeta empieza a la vista: $caja en $vista');
            expect(caja.bottom, lessThanOrEqualTo(vista.bottom + 0.5),
                reason: 'la tarjeta se ve entera: $caja en $vista');
          }

          // Arriba, o toda la lista a la vista cuando no hay más que
          // desplazar.
          final posicion = _posicion(tester);
          final arriba = cajaDelTitulo.top - vista.top <= 24;
          final enElTope =
              (posicion.pixels - posicion.maxScrollExtent).abs() < 0.5;
          expect(arriba || enElTope, isTrue,
              reason: 'título a ${cajaDelTitulo.top - vista.top} dp; '
                  '${posicion.pixels} de ${posicion.maxScrollExtent}');
          expect(tester.takeException(), isNull);
          semantica.dispose();
        });
      }
    }
  });

  group('la Lista con una matrícula repetida (10.160 y 10.164)', () {
    // El 3.º y el 5.º con la misma matrícula, en celdas distintas: el lector
    // lo avisa (BaplieReadNoticeKind.duplicate) y lo lee como dos
    // contenedores.
    VesselVoyage repetida() => _leer(t120Baplie(12).replaceFirst(
        'EQD+CN+${t120Numero(5)}', 'EQD+CN+${t120Numero(3)}'));

    for (final tamano in [_oficina, _telefono]) {
      testWidgets(
          'a ${tamano.width.toInt()} dp: una tarjeta por celda, las dos con '
          'su posición; el título cuenta las celdas; el aviso del lector '
          'arriba', (tester) async {
        final viaje = repetida();
        expect(viaje.containers, hasLength(12));
        expect(viaje.containers.map((c) => c.containerId).toSet(), hasLength(11));
        final scope = await t120Pump(tester, tamano: tamano, voyage: viaje);
        expect(find.text('Contenedores (12)'), findsOneWidget);
        expect(
            find.textContaining('Matrículas repetidas en EQD: 1 contenedor'),
            findsOneWidget);

        // Las tarjetas, bajando por toda la Lista.
        Future<List<(String, String)>> recorrer() async {
          final posicion = _posicion(tester);
          final vistas = <String, (String, String)>{};
          var y = 0.0;
          while (true) {
            posicion.jumpTo(y);
            await tester.pump();
            for (final el in t120Tarjetas().evaluate()) {
              final textos = find
                  .descendant(
                      of: find.byWidget(el.widget), matching: find.byType(Text))
                  .evaluate()
                  .map((t) => (t.widget as Text).data)
                  .whereType<String>()
                  .toList();
              final matricula =
                  textos.firstWhere((t) => t.startsWith('TSTU'));
              final posicionDeLaCelda =
                  textos[textos.indexOf('Posición') + 1];
              vistas['$matricula $posicionDeLaCelda'] =
                  (matricula, posicionDeLaCelda);
            }
            if (y >= posicion.maxScrollExtent) break;
            y = (y + 150).clamp(0, posicion.maxScrollExtent).toDouble();
          }
          posicion.jumpTo(0);
          await tester.pumpAndSettle();
          return vistas.values.toList();
        }

        final todas = await recorrer();
        expect(todas, hasLength(12), reason: '$todas');
        final repetidas =
            todas.where((t) => t.$1 == t120Numero(3)).map((t) => t.$2).toSet();
        expect(repetidas,
            {'Bahía 002, Fila 03, Nivel 82', 'Bahía 002, Fila 05, Nivel 82'},
            reason: 'una tarjeta por celda, con su posición');
        expect(tester.takeException(), isNull);

        // Un filtro que deja una sola de las dos, y soltarlo: la lista se
        // reconstruye con las claves repetidas sin perder ninguna.
        final una = viaje.containers
            .firstWhere((c) => c.containerId == t120Numero(3));
        scope.read(selectedCarrierProvider.notifier).select(una.operatorCode);
        await tester.pumpAndSettle();
        final filtradas = await recorrer();
        expect(
            filtradas.where((t) => t.$1 == t120Numero(3)), hasLength(1));
        scope.read(selectedCarrierProvider.notifier).clear();
        await tester.pumpAndSettle();
        expect(await recorrer(), hasLength(12));
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('O-120-5 · en el teléfono, «Carga especial» enseña sus tres chips',
      () {
    for (final letra in [1.0, 2.0]) {
      testWidgets(
          'a 360 × 800 con la letra a $letra: las tres cargas a la vista, sin '
          '«Ver las 3 cargas»; los destinos y las navieras, como antes',
          (tester) async {
        await t120Pump(tester, tamano: _telefono, letra: letra);
        for (final carga in ['peligrosa', 'refrigerado', 'fueraDeMedida']) {
          final chip = t120Chip('carga', carga);
          expect(chip, findsOneWidget, reason: carga);
          await tester.ensureVisible(chip);
          await tester.pumpAndSettle();
          expect(chip.hitTestable(), findsOneWidget,
              reason: '$carga se ve y se toca');
          expect(tester.getRect(chip).right, lessThanOrEqualTo(360));
        }
        expect(find.byKey(const ValueKey('filtro-carga-ver-todas')),
            findsNothing);
        expect(find.byKey(const ValueKey('filtro-destino-ver-todas')),
            findsOneWidget,
            reason: 'nueve destinos siguen con «Ver los n destinos»');
        expect(find.byKey(const ValueKey('filtro-naviera-lineas')),
            findsOneWidget,
            reason: 'las navieras siguen en sus dos líneas');
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('O-120-4 · desde Estadísticas, ningún cuadro enseña la Lista arriba',
      () {
    /// Si la Lista se pinta: ningún antecesor la deja con opacidad cero.
    bool seVe(WidgetTester tester) {
      RenderObject? r = tester.renderObject(_lista);
      while (r != null) {
        if (r is RenderOpacity && r.opacity == 0) return false;
        if (r is RenderAnimatedOpacity && r.opacity.value == 0) return false;
        r = r.parent;
      }
      return true;
    }

    for (final tamano in [_oficina, _telefono]) {
      testWidgets(
          'a ${tamano.width.toInt()} dp: en el cuadro que sigue al toque de '
          'PAMIT la Lista no se pinta; en el siguiente, con el título arriba',
          (tester) async {
        await t120Pump(tester,
            tamano: tamano, pestana: DestinoDelViaje.estadisticas);
        await tester.ensureVisible(_barra('PAMIT'));
        await tester.pumpAndSettle();
        await tester.tap(_barra('PAMIT'));
        await tester.pump();
        // El primer cuadro de la Lista: todavía no saltó.
        final vista = tester.getRect(_lista);
        final titulo = find.textContaining(RegExp(r'^Contenedores \('));
        final arriba = tester.getRect(titulo).top - vista.top;
        expect(!seVe(tester) || (arriba >= 0 && arriba <= 24), isTrue,
            reason: 'se pinta la Lista con el título a $arriba dp: el '
                'resumen del viaje arriba, un cuadro antes del salto');
        await tester.pump();
        expect(seVe(tester), isTrue, reason: 'ya saltó: se ve');
        expect(tester.getRect(titulo).top - tester.getRect(_lista).top,
            inInclusiveRange(0, 24));
        await tester.pumpAndSettle();
        expect(seVe(tester), isTrue);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('por el riel, la Lista se ve desde el primer cuadro',
        (tester) async {
      final scope = await t120Pump(tester, pestana: DestinoDelViaje.plano);
      scope.read(destinoDelViajeProvider.notifier).ir(DestinoDelViaje.lista);
      await tester.pump();
      expect(seVe(tester), isTrue);
    });
  });
}
