// T-120 (P10; DESIGN.md 18.4) · La Lista perezosa: con 977 contenedores solo
// se construyen las tarjetas que se ven y las de su margen, arriba y al
// final; el lector de pantalla sabe cuántas son; un filtro no hace saltar lo
// de arriba.
//
// Solo usa claves y textos de antes de T-120, para correr también contra el
// código de antes, donde la Lista construía las 977 a la vez.
// Buque sintético (BUQUE LISTA, TSTU); sin nube ni almacén real.
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t120_lista_support.dart';

/// Lo que se desplaza en la pestaña Lista: el de más afuera.
ScrollableState _lista(WidgetTester tester) => tester
    .stateList<ScrollableState>(find.byType(Scrollable))
    .firstWhere((s) => s.position.axis == Axis.vertical &&
        s.position.maxScrollExtent > 10000);

void main() {
  testWidgets('con 977 contenedores, arriba se construyen unas decenas de '
      'tarjetas, no las 977', (tester) async {
    await t120Pump(tester,
        voyage: t120Viaje(977), tamano: const Size(1920, 1400));
    expect(find.text('Contenedores (977)'), findsOneWidget);
    final arriba = t120Tarjetas().evaluate().length;
    expect(arriba, greaterThan(0));
    expect(arriba, lessThan(40), reason: 'construidas: $arriba');
    expect(tester.takeException(), isNull);
  });

  testWidgets('al saltar al final, también: y la última está', (tester) async {
    await t120Pump(tester, voyage: t120Viaje(977));
    // El alcance de una lista perezosa se estima: se salta hasta que no
    // crece más.
    for (var i = 0; i < 20; i++) {
      final lista = _lista(tester);
      if (lista.position.pixels == lista.position.maxScrollExtent && i > 0) {
        break;
      }
      lista.position.jumpTo(lista.position.maxScrollExtent);
      await tester.pumpAndSettle();
    }
    final alFinal = t120Tarjetas().evaluate().length;
    expect(alFinal, lessThan(40), reason: 'construidas: $alFinal');
    expect(find.text(t120Numero(977)), findsOneWidget);
    expect(find.text(t120Numero(1)), findsNothing);
  });

  testWidgets('el lector de pantalla sabe cuántas tarjetas hay',
      (tester) async {
    await t120Pump(tester, voyage: t120Viaje(977));
    final vista = tester.widget<CustomScrollView>(find.byType(CustomScrollView)
        .evaluate()
        .map((e) => find.byWidget(e.widget))
        .firstWhere((f) =>
            tester.widget<CustomScrollView>(f).semanticChildCount == 977,
            orElse: () => find.byKey(const ValueKey('lista-scroll'))));
    expect(vista.semanticChildCount, 977);
  });

  testWidgets('elegir un filtro no hace saltar lo de arriba', (tester) async {
    final scope = await t120Pump(tester, voyage: t120Viaje(977));
    final lista = _lista(tester);
    lista.position.jumpTo(120);
    await tester.pumpAndSettle();
    scope.read(selectedCarrierProvider.notifier).select('LNB');
    await tester.pumpAndSettle();
    expect(_lista(tester).position.pixels, 120);
  });
}
