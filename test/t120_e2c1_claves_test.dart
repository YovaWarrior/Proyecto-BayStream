// T-120, corrección 1 de la entrega 2 · T120-E2-01 (P3, de la aceptación de
// GLM; SPRINT-4.md 10.170): con una matrícula en más de una celda, dos
// tarjetas de la Lista compartían la clave de la matrícula, y al rearmarse la
// lista perezosa con las dos a la vista el framework fallaba
// («indexOf(child) > index»). Ahora la clave lleva la celda
// (`ContainersSliverList.claveDe`).
//
// En su propio archivo: contra el código de antes, el árbol queda roto y
// arrastraría a las pruebas que vinieran después en el mismo aislado.
// Buque sintético (BUQUE LISTA, TSTU); sin nube ni almacén real.
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t120_lista_support.dart';

final _lista = find.byKey(const ValueKey('lista-scroll'));

ScrollPosition _posicion(WidgetTester tester) => tester
    .state<ScrollableState>(
        find.descendant(of: _lista, matching: find.byType(Scrollable)).first)
    .position;

VesselVoyage _leer(String texto) {
  final leido = BaplieParserService().parse(texto);
  return leido.withGeometry(VesselProfile.proposeFrom(leido).geometry);
}

void main() {
  group('T120-E2-01 · una clave por tarjeta, con su celda', () {
    // T120-E2-01 (aceptación de la entrega 2, 10.170): con la matrícula en
    // más de una celda, el filtro de su naviera deja dos de sus tarjetas a la
    // vista; al soltarlo, la lista perezosa se rearmaba con dos hijos de la
    // misma clave y el framework lanzaba «indexOf(child) > index». Con tres
    // celdas es el caso de GLM (el 3.º, el 4.º y el 7.º); con dos, el 3.º y
    // el 4.º, los dos de LNB, que es lo que traería un plan de verdad.
    for (final (celdas, otras) in [
      (2, [4]),
      (3, [4, 7]),
    ]) {
      testWidgets(
          'T120-E2-01 · la matrícula en $celdas celdas: el filtro de su '
          'naviera deja dos a la vista; al soltarlo, la Lista se rearma sin '
          'errores, en su orden, y cada tarjeta lleva su clave', (tester) async {
        var texto = t120Baplie(13);
        for (final i in otras) {
          texto = texto.replaceFirst(
              'EQD+CN+${t120Numero(i)}', 'EQD+CN+${t120Numero(3)}');
        }
        final viaje = _leer(texto);
        expect(viaje.containers, hasLength(13));
        final repetidos =
            viaje.containers.where((c) => c.containerId == t120Numero(3));
        expect(repetidos, hasLength(celdas));
        final scope = await t120Pump(tester, voyage: viaje);

        /// Las tarjetas de toda la Lista, en el orden en que se ven, con su
        /// clave: «matrícula @ posición = clave».
        Future<List<String>> enOrden() async {
          final posicion = _posicion(tester);
          final vista = tester.getRect(_lista);
          final porAltura = <String, double>{};
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
              final dicho = '${textos.firstWhere((t) => t.startsWith('TSTU'))}'
                  ' @ ${textos[textos.indexOf('Posición') + 1]}'
                  ' = ${(el.widget.key! as ValueKey<String>).value}';
              porAltura[dicho] =
                  y + tester.getRect(find.byWidget(el.widget)).top - vista.top;
            }
            if (y >= posicion.maxScrollExtent) break;
            y = (y + 150).clamp(0, posicion.maxScrollExtent).toDouble();
          }
          posicion.jumpTo(0);
          await tester.pump();
          return porAltura.keys.toList()
            ..sort((a, b) => porAltura[a]!.compareTo(porAltura[b]!));
        }

        final antes = await enOrden();
        expect(antes, hasLength(13), reason: '$antes');

        final naviera = repetidos.first.operatorCode;
        expect(repetidos.take(2).map((c) => c.operatorCode).toSet(), {naviera},
            reason: 'las dos primeras son de la misma naviera');
        scope.read(selectedCarrierProvider.notifier).select(naviera);
        await tester.pumpAndSettle();
        final filtradas = await enOrden();
        expect(filtradas.where((t) => t.startsWith(t120Numero(3))),
            hasLength(greaterThanOrEqualTo(2)),
            reason: 'dos de la matrícula a la vista: $filtradas');

        // Soltar el filtro, con los errores del framework anotados.
        final errores = <String>[];
        final anterior = FlutterError.onError;
        FlutterError.onError = (detalles) =>
            errores.add(detalles.exceptionAsString().split('\n').first);
        List<String> despues = const [];
        try {
          scope.read(selectedCarrierProvider.notifier).clear();
          for (var i = 0; i < 10; i++) {
            await tester.pump();
          }
          despues = await enOrden();
        } catch (error) {
          errores.add('$error'.split('\n').first);
        }
        if (errores.isNotEmpty) {
          // El árbol quedó roto: se desmonta con la anotación puesta.
          await tester.pumpWidget(const SizedBox.shrink());
        }
        FlutterError.onError = anterior;
        expect(errores, isEmpty,
            reason: 'al soltar el filtro, la Lista se rearma sin errores');
        expect(despues, antes, reason: 'las 13, en el mismo orden');
        final claves = despues.map((t) => t.split(' = ').last).toList();
        expect(claves.toSet(), hasLength(13), reason: 'una clave por tarjeta');
        for (final c in repetidos) {
          expect(
              claves,
              contains(
                  'tarjeta-${t120Numero(3)}-${c.stowagePosition!.toIsoCode()}'),
              reason: 'la clave lleva la celda');
        }
      });
    }
  });
}
