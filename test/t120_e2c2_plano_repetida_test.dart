// T-120, corrección 2 de la entrega 2 · T120-E2-03 (P3, de la aceptación de
// GLM de la corrección 1; SPRINT-4.md 10.172): elegir en el buscador una
// matrícula repetida rompía el armado del Plano.
//
// El buscador resalta por matrícula, y cada celda resaltada iba dentro de un
// `_RevealPosition` con la clave de la matrícula. Las celdas de un nivel son
// hijas de una misma fila: con la matrícula en dos celdas del mismo nivel, dos
// hermanas compartían clave y el framework lanzaba «Duplicate keys found».
// Ahora la clave es de la celda y del contenedor (`bay_plan_view.dart`).
//
// El caso es el de GLM: el 3.º y el 7.º del buque sintético de la Lista
// (t120Baplie(13)), con la misma matrícula, en 0020382 y 0020782. El buscador
// da dos resultados; al elegir cada uno, el Plano se arma sin errores, en su
// bahía. Lo que queda resaltado se anota: el buscador resalta la matrícula, en
// todas sus celdas (que cada resultado resalte solo la suya va con O-120-6).
//
// En su propio archivo: contra el código de antes, el árbol queda roto.
// Buque sintético (BUQUE LISTA, TSTU); sin nube ni almacén real.
import 'package:baystream/core/design/componentes/bs_celda.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/navegacion_del_viaje.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t120_lista_support.dart';

final _resultados = find.byWidgetPredicate(
    (w) => w.runtimeType.toString() == '_ContainerSearchResultTile');

VesselVoyage _leer(String texto) {
  final leido = BaplieParserService().parse(texto);
  return leido.withGeometry(VesselProfile.proposeFrom(leido).geometry);
}

/// Las celdas del Plano resaltadas, por su clave («cell-», la fila y el
/// nivel).
List<String> _resaltadas(WidgetTester tester) => find
    .byType(BsCelda)
    .evaluate()
    .map((e) => e.widget as BsCelda)
    .where((c) => c.resaltada)
    .map((c) => (c.key as ValueKey<String>?)?.value ?? '(sin clave)')
    .toList()
  ..sort();

void main() {
  final repetida = t120Numero(3);
  for (final (indice, fila) in [(0, 'Fila 03'), (1, 'Fila 07')]) {
    testWidgets(
        'T120-E2-03 · la matrícula en dos celdas del mismo nivel: al elegir '
        'en el buscador el resultado de la $fila, el Plano se arma sin errores, '
        'en su bahía', (tester) async {
      final viaje = _leer(t120Baplie(13)
          .replaceFirst('EQD+CN+${t120Numero(7)}', 'EQD+CN+$repetida'));
      final celdas = viaje.containers
          .where((c) => c.containerId == repetida)
          .map((c) => c.stowagePosition!.toIsoCode())
          .toList();
      expect(celdas, ['0020382', '0020782'],
          reason: 'la matrícula en dos celdas del nivel 82 de la bahía 2');
      final scope = await t120Pump(tester, voyage: viaje);

      await tester.tap(find.byKey(const ValueKey('buscar-contenedor')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, repetida);
      await tester.pumpAndSettle();
      expect(_resultados, findsNWidgets(2), reason: 'dos resultados');
      final textos = find
          .descendant(
              of: _resultados.at(indice), matching: find.byType(Text))
          .evaluate()
          .map((t) => (t.widget as Text).data)
          .whereType<String>()
          .join(' | ');
      expect(textos, contains(fila),
          reason: 'el resultado $indice es el de la $fila: $textos');

      final errores = <String>[];
      final anterior = FlutterError.onError;
      FlutterError.onError = (detalles) =>
          errores.add(detalles.exceptionAsString().split('\n').first);
      var resaltadas = const <String>[];
      try {
        await tester.tap(_resultados.at(indice));
        await tester.pumpAndSettle();
        // `_RevealPosition` lleva la vista a la celda a los 350 ms.
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();
        resaltadas = _resaltadas(tester);
      } catch (error) {
        errores.add('$error'.split('\n').first);
      }
      if (errores.isNotEmpty) {
        await tester.pumpWidget(const SizedBox.shrink());
      }
      FlutterError.onError = anterior;
      debugPrint('T120-E2-03 resultado $indice ($fila): destino '
          '${scope.read(destinoDelViajeProvider).name}, bahía '
          '${scope.read(selectedBayProvider)}, resaltado '
          '${scope.read(highlightedContainerProvider)}, celdas resaltadas '
          '$resaltadas, errores $errores');
      expect(errores, isEmpty, reason: 'el Plano se arma sin errores');
      expect(scope.read(destinoDelViajeProvider), DestinoDelViaje.plano);
      expect(scope.read(selectedBayProvider), 2);
      expect(scope.read(highlightedContainerProvider), repetida);
      // El buscador resalta la matrícula: sus dos celdas (O-120-6).
      expect(resaltadas, ['cell-3-82', 'cell-7-82']);
      expect(tester.takeException(), isNull);
    });
  }
}
