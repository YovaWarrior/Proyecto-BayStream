// T-147, entrega 2, parte 2a · O-147-2 y O-147-3 (10.153): la hoja «Vacíos
// del listado».
//
// O-147-2 · La hoja, y la lista «Celda reservada» de «Asignar vacío», no
//           ofrecen un vacío donde no cabe por su largo: una bahía impar es
//           de 20 pies y una par, de 40. Antes lo ofrecían como «Otro grupo:
//           pide motivo», y después el diálogo no lo dejaba registrar.
// O-147-3 · Primero los del grupo de la celda y después los demás, y dentro
//           de cada parte, por OR, en todos los clientes. Antes el orden
//           salía de un `sort` sin desempate, que la Web y la máquina virtual
//           de Dart (Windows y Android) resuelven distinto.
//
// Solo datos sintéticos. Compila también contra `v1.0.2`.
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_operation_provider.dart';
import 'package:baystream/features/vessel/presentation/widgets/loading_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t147e2_support.dart';

/// Dos celdas de 40 pies (bahía 18), dos de 20 (bahía 19) y una de un tipo
/// de largo desconocido.
final _edi = e2PlanEdi([
  e2Reserva('0180082', '45G1', 'COTRB', 'LNH'),
  e2Reserva('0180282', '42G1', 'COTRB', 'LNH'),
  e2Reserva('0190282', '22G1', 'JMKIN', 'LNJ'),
  e2Reserva('0190482', '22U1', 'JMKIN', 'LNJ'),
]);

/// Sesenta vacíos, con los tipos mezclados a lo largo del OR, para que el
/// orden por grupo no coincida con el orden por OR: 45G1, 42G1, 22G1 y 22U1
/// se turnan, y uno de cada diez es de un tipo de largo desconocido.
List<List<Object?>> _hoja() => [
      for (var i = 1; i <= 60; i++)
        () {
          final (tipo, puerto, linea) = switch (i % 10 == 0 ? 4 : i % 4) {
            0 => ('45G1', 'COTRB', 'LNH'),
            1 => ('42G1', 'COTRB', 'LNH'),
            2 => ('22G1', 'JMKIN', 'LNJ'),
            3 => ('22U1', 'JMKIN', 'LNJ'),
            _ => ('ZZZZ', 'JMKIN', 'LNJ'),
          };
          return e2Fila(i, 100 + i, tipo, puerto, linea, vacio: true);
        }()
    ];

Future<void> _abrirLaHoja(WidgetTester tester, LoadingOperation data,
    VesselVoyage plan, ReservedSlot celda) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(400, 20000);
  addTearDown(tester.view.reset);
  final scope = ProviderContainer(overrides: [
    loadingOperationProvider(plan).overrideWith((ref) => Stream.value(data)),
  ]);
  addTearDown(scope.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
      container: scope,
      child: MaterialApp(
          home: Scaffold(
              body: Consumer(
                  builder: (context, ref, _) => TextButton(
                      key: const ValueKey('abrir'),
                      onPressed: () => chooseLoadingRow(context, ref, plan,
                          empties: true, slot: celda),
                      child: const Text('abrir')))))));
  await tester.tap(find.byKey(const ValueKey('abrir')));
  await tester.pumpAndSettle();
}

/// Los OR de las filas de la hoja, de arriba abajo.
List<int> _enPantalla(WidgetTester tester) {
  final filas = [
    for (final fila in tester.widgetList<ListTile>(find.byWidgetPredicate(
        (w) =>
            w is ListTile &&
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith('loading-or-'))))
      (
        orden: int.parse((fila.key! as ValueKey<String>).value.substring(11)),
        y: tester.getTopLeft(find.byKey(fila.key!)).dy
      )
  ]..sort((a, b) => a.y.compareTo(b.y));
  return [for (final fila in filas) fila.orden];
}

void main() {
  final plan = e2Plan(_edi);
  final lista = e2Normalizar(
      e2Listado(_hoja()), e2Proponer(e2Listado(_hoja()), plan));
  final data = e2Operacion(plan, lista);
  ReservedSlot celda(String posicion) => plan.reservedSlots
      .firstWhere((s) => s.stowagePosition.toIsoCode() == posicion);
  List<int> deTipo(Set<String> tipos) => [
        for (final fila in lista.rows)
          if (tipos.contains(fila.type)) fila.order
      ];

  test('el caso: los cinco tipos se cruzan por identidad, sin pendientes', () {
    expect(lista.rows, hasLength(60));
    expect(deTipo({'45G1'}), hasLength(12));
    expect(deTipo({'ZZZZ'}), hasLength(6));
  });

  group('O-147-2 · la hoja no ofrece lo que no cabe', () {
    test('desde una celda de 40 pies no ofrece los vacíos de 20', () {
      final ofrecidos =
          data.rowsFor(celda('0180082'), '').map((r) => r.order).toSet();
      expect(ofrecidos, {...deTipo({'45G1', '42G1', 'ZZZZ'})});
      expect(ofrecidos.intersection({...deTipo({'22G1', '22U1'})}), isEmpty);
    });

    test('desde una celda de 20 pies no ofrece los vacíos de 40', () {
      final ofrecidos =
          data.rowsFor(celda('0190282'), '').map((r) => r.order).toSet();
      expect(ofrecidos, {...deTipo({'22G1', '22U1', 'ZZZZ'})});
    });

    test('un tipo de largo desconocido se sigue ofreciendo', () {
      for (final posicion in ['0180082', '0190282']) {
        expect(
            data.rowsFor(celda(posicion), '').map((r) => r.order),
            containsAll(deTipo({'ZZZZ'})));
      }
    });

    test('«Asignar vacío» tampoco ofrece, ni como otro grupo, una celda '
        'donde no cabe', () {
      final de20 = lista.byOrder(2)!; // 22G1
      expect(
          data
              .candidateSlots(de20, otherGroups: true)
              .map((s) => s.stowagePosition.toIsoCode()),
          ['0190282', '0190482']);
      final de40 = lista.byOrder(4)!; // 45G1
      expect(
          data
              .candidateSlots(de40, otherGroups: true)
              .map((s) => s.stowagePosition.toIsoCode()),
          ['0180082', '0180282']);
    });

    test('lo que la hoja ofrece se puede registrar: ninguna fila queda '
        'bloqueada por el largo', () {
      for (final posicion in ['0180082', '0190282']) {
        for (final fila in data.rowsFor(celda(posicion), '')) {
          expect(data.check(fila, posicion).blocked, isFalse,
              reason: 'OR ${fila.order} en $posicion');
        }
      }
    });
  });

  group('O-147-3 · el orden de la hoja', () {
    List<int> esperado(String posicion, Set<String> suTipo, Set<String> otros) =>
        [...deTipo(suTipo), ...deTipo(otros)];

    test('primero los del grupo de la celda y después los demás; dentro de '
        'cada parte, por OR', () {
      expect(data.rowsFor(celda('0180082'), '').map((r) => r.order),
          esperado('0180082', {'45G1'}, {'42G1', 'ZZZZ'}));
      expect(data.rowsFor(celda('0190482'), '').map((r) => r.order),
          esperado('0190482', {'22U1'}, {'22G1', 'ZZZZ'}));
    });

    testWidgets('la hoja lo dibuja en ese orden', (tester) async {
      await _abrirLaHoja(tester, data, plan, celda('0180082'));
      expect(find.text('Vacíos del listado'), findsOneWidget);
      expect(_enPantalla(tester),
          esperado('0180082', {'45G1'}, {'42G1', 'ZZZZ'}));
    });

    testWidgets('al buscar, el orden sigue siendo ese', (tester) async {
      await _abrirLaHoja(tester, data, plan, celda('0180082'));
      // Los que terminan en 4 o son el OR 4: de su grupo y de otros.
      await tester.enterText(find.byType(TextField), '4');
      await tester.pumpAndSettle();
      final ofrecidos = data.rowsFor(celda('0180082'), '4').map((r) => r.order);
      expect(ofrecidos, isNotEmpty);
      expect(_enPantalla(tester), ofrecidos);
    });
  });

  group('P1 · en la hoja, la fila cancelada', () {
    final conNota = e2Listado([
      e2Fila(1, 101, '45G1', 'COTRB', 'LNH', vacio: true),
      e2Fila(2, 102, '45G1', 'COTRB', 'LNH', vacio: true, nota: 'CANCELADO'),
    ]);
    final normalizada = e2Normalizar(conNota, e2Proponer(conNota, plan));

    testWidgets('no sale; si se la busca, sale marcada', (tester) async {
      await _abrirLaHoja(
          tester, e2Operacion(plan, normalizada), plan, celda('0180082'));
      expect(_enPantalla(tester), [1]);
      await tester.enterText(find.byType(TextField), '2');
      await tester.pumpAndSettle();
      expect(_enPantalla(tester), contains(2));
      expect(
          e2Textos(tester, 'Cancelado en el listado: pide motivo'),
          hasLength(1));
    });
  });
}
