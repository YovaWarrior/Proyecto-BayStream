// T-120 · Los filtros de la Lista con las fuentes del producto, en el teléfono
// y en la oficina, con la letra a 1.0, 1.45 y 2.0 (DESIGN.md 18.3): nada
// desbordado ni fuera de la pantalla, hasta dos líneas y «Ver los n» en el
// teléfono, con el elegido a la vista y la hoja con todos.
//
// Buque sintético (BUQUE LISTA, TSTU); sin nube ni almacén real.
import 'package:baystream/core/design/design.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_operation_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t120_lista_support.dart';

const _tamanos = <Size>[
  Size(360, 800),
  Size(599, 900),
  Size(800, 600),
  Size(1366, 690),
  Size(1920, 1000),
];
const _letras = <double>[1.0, 1.45, 2.0];

void main() {
  for (final tamano in _tamanos) {
    for (final letra in _letras) {
      final telefono = tamano.width < 600;
      testWidgets(
          '${tamano.width.toInt()} × ${tamano.height.toInt()}, letra $letra: '
          'nada desbordado ni fuera de la pantalla', (tester) async {
        await t120Pump(tester, tamano: tamano, letra: letra);
        await tester.ensureVisible(find.text('Filtrar por destino'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final renders = tester
            .renderObjectList<RenderBsFichasEnLineas>(
                find.byType(BsFichasEnLineas))
            .toList();
        if (telefono) {
          // Las tres filas, cada una en dos líneas como mucho.
          expect(renders, hasLength(3));
          final destinos = renders[1];
          expect(destinos.conVerTodas, isTrue,
              reason: 'once chips no caben en dos líneas de un teléfono');
          expect(find.textContaining(RegExp(r'^Ver los \d+ destinos$')),
              findsOneWidget);
          for (final r in renders) {
            var alto = 0.0;
            r.visitChildren((hijo) {
              final caja = hijo as RenderBox;
              if (caja.size.height > alto) alto = caja.size.height;
            });
            expect(r.size.height, lessThanOrEqualTo(2 * alto + 8 + 0.01));
          }
        } else {
          expect(renders, isEmpty, reason: 'la oficina envuelve sin límite');
        }
        // Los chips que se ven caben a lo ancho.
        for (final chip in [
          ...find.byType(FilterChip).evaluate(),
          ...find.byType(ActionChip).evaluate(),
        ]) {
          final caja = chip.renderObject! as RenderBox;
          final padre = caja.parentData;
          if (padre is DatosDeLaFicha && !padre.visible) continue;
          final rect = caja.localToGlobal(Offset.zero) & caja.size;
          expect(rect.left, greaterThanOrEqualTo(0), reason: '$chip');
          expect(rect.right, lessThanOrEqualTo(tamano.width + 0.01),
              reason: '$chip');
        }
      });
    }
  }

  testWidgets('en el teléfono, un destino chico elegido sigue a la vista',
      (tester) async {
    final scope = await t120Pump(tester, tamano: const Size(360, 800));
    scope.read(selectedDischargePortProvider.notifier).select('JMKCT');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Filtrar por destino'));
    await tester.pumpAndSettle();
    final destinos = tester
        .renderObjectList<RenderBsFichasEnLineas>(find.byType(BsFichasEnLineas))
        .elementAt(1);
    final chip = t120Chip('destino', 'JMKCT');
    final padre = (tester.renderObject(chip) as RenderBox).parentData;
    expect(padre, isA<DatosDeLaFicha>());
    expect((padre! as DatosDeLaFicha).visible, isTrue);
    expect(destinos.conVerTodas, isTrue);
  });

  testWidgets('en el teléfono, «Ver los n destinos» abre la hoja con todos, y '
      'elegir en ella filtra y la cierra', (tester) async {
    final scope = await t120Pump(tester, tamano: const Size(360, 800));
    final ver = find.byKey(const ValueKey('filtro-destino-ver-todas'));
    await tester.ensureVisible(ver);
    await tester.pumpAndSettle();
    await tester.tap(ver);
    await tester.pumpAndSettle();
    expect(find.text('Todos los destinos'), findsOneWidget);
    final fila = find.byKey(const ValueKey('hoja-filtro-destino-JMKCT'));
    await tester.ensureVisible(fila);
    await tester.tap(fila);
    await tester.pumpAndSettle();
    expect(find.text('Todos los destinos'), findsNothing);
    expect(scope.read(selectedDischargePortProvider), 'JMKCT');
    expect(scope.read(filteredContainersProvider),
        everyElement(predicate((c) => (c as dynamic).portOfDischarge == 'JMKCT')));
    expect(tester.takeException(), isNull);
  });
}
