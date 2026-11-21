// T-147, entrega 2, parte 2a · P4 (hallazgo 6 de la 10.151; 10.160, D9, D10
// y cambio 4): «también llena».
//
// El listado dice 40HC y el plan separa 45G1 y 45G0. La equivalencia sigue
// siendo una, la principal; los demás códigos del plan que el tipo llena van
// aparte, dentro del listado.
// - Con el respaldo repartido, se propone sola: el más repetido es el
//   principal y los demás van a «también llena». Con un empate se pregunta.
// - Una celda reservada cuyo código no llena ningún tipo se enseña, con su
//   sugerencia; la oficina la declara, o sigue pidiendo motivo.
// - El grupo de un código es el de su tipo principal: en el cruce, en la
//   hoja, en la revisión de la carga y en el conflicto «otro grupo».
// - Un código del plan, un solo grupo: si dos tipos con principales
//   distintos declaran el mismo código, la importación no sigue.
// - La fila guardada no cambia: la 1.0.2, que no lee lo declarado, arma los
//   mismos grupos que antes.
//
// Solo datos sintéticos. Compila también contra `v1.0.2`.
import 'dart:convert';

import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/export_list_cross_checker.dart';
import 'package:baystream/features/vessel/presentation/providers/export_list_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t147_listado_support.dart';
import 'support/t147e2_support.dart';

final _edi = e2PlanEdi([
  // 40HC, repartido: dos 45G1 y un 45G0.
  e2Grupo('0100282', t147Matricula(1), '45G1', 'COCTG', 'LNH'),
  e2Grupo('0100482', t147Matricula(2), '45G1', 'COCTG', 'LNH'),
  e2Grupo('0100682', t147Matricula(3), '45G0', 'COCTG', 'LNH'),
  // 20TK, repartido: dos 22K2 y un 22T1.
  e2Grupo('0110282', t147Matricula(4), '22K2', 'COCTG', 'LNH'),
  e2Grupo('0110482', t147Matricula(5), '22T1', 'COCTG', 'LNH'),
  e2Grupo('0110682', t147Matricula(6), '22K2', 'COCTG', 'LNH'),
  e2Reserva('0180082', '45G1', 'COTRB', 'LNH'),
  e2Reserva('0180282', '45G0', 'COTRB', 'LNH'),
  e2Reserva('0180482', 'L5G1', 'COTRB', 'LNH'),
  e2Reserva('0180682', 'L5G0', 'COTRB', 'LNH'),
  e2Reserva('0190282', '22T4', 'COCTG', 'LNH'),
  e2Reserva('0200082', '49P9', 'JMKIN', 'LNH'),
]);

List<List<Object?>> _hoja() => [
      e2Fila(1, 1, '40HC', 'COCTG', 'LGH'),
      e2Fila(2, 2, '40HC', 'COCTG', 'LGH'),
      e2Fila(3, 3, '40HC', 'COCTG', 'LGH'),
      e2Fila(4, 4, '20TK', 'COCTG', 'LGH'),
      e2Fila(5, 5, '20TK', 'COCTG', 'LGH'),
      e2Fila(6, 6, '20TK', 'COCTG', 'LGH'),
      e2Fila(7, 11, '40HC', 'COTRB', 'LGH', vacio: true),
      e2Fila(8, 12, '40HC', 'COTRB', 'LGH', vacio: true),
      e2Fila(9, 13, '45HC', 'COTRB', 'LGH', vacio: true),
      e2Fila(10, 14, '45HC', 'COTRB', 'LGH', vacio: true),
      e2Fila(11, 15, '20TK', 'COCTG', 'LGH', vacio: true),
    ];

/// Las propuestas con lo que la oficina declara: `{'45HC': ['L5G0']}`.
List<EquivalenceProposal> _declarar(List<EquivalenceProposal> propuestas,
        Map<String, List<String>> declarado) =>
    [
      for (final p in propuestas)
        p.kind == EquivalenceKind.type && declarado.containsKey(p.listCode)
            ? e2Nuevo(
                () => (p as dynamic).withAlso(
                        [...e2Tambien(p), ...declarado[p.listCode]!])
                    as EquivalenceProposal,
                p)
            : p
    ];

String _grupo(EmptyGroup g) =>
    '${g.type} · ${g.pod} · ${g.line}: ${g.empties.length} para ${g.planCells}';

void main() {
  final plan = e2Plan(_edi);
  final lista = e2Listado(_hoja());
  List<EquivalenceProposal> propuestas() =>
      e2Proponer(lista, plan, tipos: {'45HC': 'L5G1'});
  List<EquivalenceProposal> declaradas() => _declarar(propuestas(), {
        '45HC': ['L5G0'],
        '20TK': ['22T4'],
      });

  group('P4 · el respaldo repartido se propone solo', () {
    test('el más repetido es el principal y los demás van a «también '
        'llena»', () {
      final todas = propuestas();
      final hc = e2De(todas, EquivalenceKind.type, '40HC');
      expect(hc.needsUser, isFalse);
      expect(hc.planCode, '45G1');
      expect(hc.origin.name, 'inferred');
      expect(e2Tambien(hc), ['45G0']);
      final tk = e2De(todas, EquivalenceKind.type, '20TK');
      expect(tk.planCode, '22K2');
      expect(e2Tambien(tk), ['22T1']);
      expect([
        for (final p in ExportListCrossChecker.propose(lista, plan,
            portOfCall: e2Escala))
          if (p.needsUser) p.listCode
      ], ['45HC']);
    });

    test('con un empate se sigue preguntando, como hasta la 1.0.2', () {
      final empate = e2Listado([
        e2Fila(4, 4, '20TK', 'COCTG', 'LGH'),
        e2Fila(5, 5, '20TK', 'COCTG', 'LGH'),
      ]);
      final tk = e2De(
          ExportListCrossChecker.propose(empate, plan, portOfCall: e2Escala),
          EquivalenceKind.type,
          '20TK');
      expect(tk.needsUser, isTrue);
      expect(tk.candidates, unorderedEquals(['22K2', '22T1']));
    });

    test('un puerto o una línea con el respaldo repartido se sigue '
        'preguntando: «también llena» es solo de los tipos', () {
      final dosPuertos = e2PlanEdi([
        e2Grupo('0100282', t147Matricula(1), '45G1', 'COCTG', 'LNH'),
        e2Grupo('0100482', t147Matricula(2), '45G1', 'COCTG', 'LNH'),
        e2Grupo('0100682', t147Matricula(3), '45G1', 'COTRB', 'LNH'),
      ]);
      final sinPot = e2Listado([
        e2Fila(1, 1, '40HC', 'COXXX', 'LGH'),
        e2Fila(2, 2, '40HC', 'COXXX', 'LGH'),
        e2Fila(3, 3, '40HC', 'COXXX', 'LGH'),
      ]);
      final puerto = e2De(
          ExportListCrossChecker.propose(sinPot, e2Plan(dosPuertos),
              portOfCall: e2Escala),
          EquivalenceKind.port,
          'COXXX');
      expect(puerto.needsUser, isTrue);
    });
  });

  group('P4 · el grupo de un código es el de su tipo principal', () {
    test('lo declarado va en el listado, y la fila conserva su tipo', () {
      final normalizada = e2Normalizar(lista, declaradas());
      expect(normalizada.toJson()['typeFamilies'], {
        '45G0': '45G1',
        '22T1': '22K2',
        '22T4': '22K2',
        'L5G0': 'L5G1',
      });
      expect(normalizada.byOrder(3)!.type, '45G1');
      expect(normalizada.byOrder(11)!.type, '22K2');
      final vuelta = ExportList.fromJson(
          jsonDecode(jsonEncode(normalizada.toJson())) as Map<String, dynamic>);
      expect(vuelta, normalizada);
    });

    test('el cruce une los grupos: los vacíos de un tipo llenan las celdas '
        'de todos sus códigos', () {
      final cruce = ExportListCrossChecker.crossCheck(
          e2Normalizar(lista, declaradas()), plan, e2Escala);
      expect(cruce.groups.map(_grupo), [
        '45G1 · COTRB · LNH: 2 para 2',
        'L5G1 · COTRB · LNH: 2 para 2',
        '22K2 · COCTG · LNH: 1 para 1',
        '49P9 · JMKIN · LNH: 0 para 1',
      ]);
      expect(cruce.emptiesWithoutGroup, isEmpty);
      final hc = cruce.groups.first;
      expect(
          e2Nuevo(() => (hc as dynamic).cellsByCode as Map, const {}),
          {'45G1': 1, '45G0': 1});
    });

    test('un lleno cuyo código del plan es uno de los que su tipo llena no '
        'tiene datos distintos', () {
      final cruce = ExportListCrossChecker.crossCheck(
          e2Normalizar(lista, declaradas()), plan, e2Escala);
      expect(cruce.matches, hasLength(6));
      expect(cruce.matchesWithDifferences, isEmpty);
    });

    test('sin lo declarado, que es lo que lee la 1.0.2 del listado nuevo, '
        'los grupos son los de siempre', () {
      final json = e2Normalizar(lista, declaradas()).toJson()
        ..remove('typeFamilies');
      final comoLa102 = ExportList.fromJson(
          jsonDecode(jsonEncode(json)) as Map<String, dynamic>);
      final cruce =
          ExportListCrossChecker.crossCheck(comoLa102, plan, e2Escala);
      expect(cruce.groups.map((g) => g.type),
          unorderedEquals(['45G1', '45G0', 'L5G1', 'L5G0', '22T4', '49P9']));
      expect(cruce.emptiesWithoutGroup.map((r) => r.order), [11]);
      expect(cruce.matchesWithDifferences.map((m) => m.row.order), [3, 5]);
    });

    test('la hoja, las celdas y la revisión tratan el código declarado como '
        'del grupo: sin «otro grupo» y sin motivo', () {
      final normalizada = e2Normalizar(lista, declaradas());
      final data = e2Operacion(plan, normalizada);
      final celda = plan.reservedSlots
          .firstWhere((s) => s.stowagePosition.toIsoCode() == '0180282');
      // Primero los de su grupo (40HC), después los demás de 40 pies.
      expect(data.rowsFor(celda, '').map((r) => r.order), [7, 8, 9, 10]);
      final fila = normalizada.byOrder(7)!;
      expect(
          data.candidateSlots(fila).map((s) => s.stowagePosition.toIsoCode()),
          ['0180082', '0180282']);
      expect(data.check(fila, '0180282').issues, isEmpty);
      // Lo que nadie declaró sigue pidiendo motivo.
      expect(data.check(fila, '0200082').issues.map((i) => i.kind.name),
          ['otherGroup']);
    });

    test('el vacío asignado a una celda de un código declarado no queda en '
        'conflicto, y la celda dice su código', () {
      final normalizada = e2Normalizar(lista, declaradas());
      final asignado = e2Movimiento(
          MovementDraft.assignEmpty('e2', '0180282', t147Matricula(11), 3900,
              order: 7),
          1);
      final data = e2Operacion(plan, normalizada, [asignado]);
      expect(data.state.conflicts, isEmpty);
      expect(data.state['R:0180282']!.inConflict, isFalse);
      expect(e2Operacion(plan, normalizada).progress.label('R:0180282'),
          '45G0\nCOTRB\nLNH');
    });
  });

  group('P4 · en pantalla', () {
    testWidgets('la propuesta dice cómo se reparte y qué llena el tipo',
        (tester) async {
      await e2AbrirLaPagina(tester, plan, lista);
      expect(e2Textos(tester, '40HC llena'), [
        'Propuesta: 2 contenedores van a 45G1 y 1 a 45G0. 40HC llena los dos.'
      ]);
      expect(find.byKey(const ValueKey('also-40HC-45G0')), findsOneWidget);
      expect(find.byKey(const ValueKey('also-20TK-22T1')), findsOneWidget);
    });

    testWidgets('las celdas sin dueño se enseñan con su sugerencia, y se '
        'declaran con un toque', (tester) async {
      final scope = await e2AbrirLaPagina(tester, plan, lista);
      scope
          .read(exportListImportProvider.notifier)
          .choose(EquivalenceKind.type, '45HC', 'L5G1');
      await tester.pumpAndSettle();
      expect(
          e2Textos(tester, 'Celdas reservadas que ningún tipo'),
          ['Celdas reservadas que ningún tipo del listado llena (3)']);
      expect(e2Textos(tester, ' · 1 celda'), [
        '22T4 · 1 celda. ¿La llena 20TK (22K2)?',
        '49P9 · 1 celda. Ningún tipo del listado se le parece.',
        'L5G0 · 1 celda. ¿La llena 45HC (L5G1)?',
      ]);

      await tester.tap(find.byKey(const ValueKey('orphan-yes-L5G0')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('orphan-yes-22T4')));
      await tester.pumpAndSettle();
      expect(
          e2Textos(tester, 'Celdas reservadas que ningún tipo'),
          ['Celdas reservadas que ningún tipo del listado llena (1)']);
      expect(find.byKey(const ValueKey('also-45HC-L5G0')), findsOneWidget);
      expect(find.byKey(const ValueKey('also-20TK-22T4')), findsOneWidget);
      expect(e2Textos(tester, 'L5G1 · COTRB · LNH:'), [
        'L5G1 · COTRB · LNH: 2 vacíos, 2 celdas (1 de L5G1 y 1 de L5G0)'
      ]);
      expect(e2Textos(tester, '22K2 · COCTG · LNH:'),
          ['22K2 · COCTG · LNH: 1 vacío, 1 celda']);
      expect(e2Textos(tester, 'llenos cruzan con el plan'),
          ['6 de 6 llenos cruzan con el plan']);
      expect(e2Textos(tester, 'Llenos con datos distintos'), isEmpty);
    });

    testWidgets('declarar no es obligatorio: «Confirmar e importar» sigue',
        (tester) async {
      final scope = await e2AbrirLaPagina(tester, plan, lista);
      scope
          .read(exportListImportProvider.notifier)
          .choose(EquivalenceKind.type, '45HC', 'L5G1');
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('orphan-codes')), findsOneWidget);
      expect(
          tester
              .widget<FilledButton>(
                  find.byKey(const ValueKey('export-list-confirm')))
              .onPressed,
          isNotNull);
    });
  });

  group('P4 · un código del plan, un solo tipo del listado', () {
    testWidgets('si dos tipos declaran el mismo código, la importación no '
        'sigue y la pantalla dice cuáles', (tester) async {
      final scope = await e2AbrirLaPagina(tester, plan, lista);
      final notifier = scope.read(exportListImportProvider.notifier);
      // La oficina le pone a 45HC, con el lápiz, un código que 40HC ya llena.
      notifier.choose(EquivalenceKind.type, '45HC', '45G0');
      await tester.pumpAndSettle();
      const mensaje = '45G0 lo declaran dos tipos: 40HC (45G1) y 45HC (45G0). '
          'Un código del plan lo llena un solo tipo: corrige uno con el lápiz '
          'o quita el «también llena» que sobra.';
      expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('family-conflict-45G0')))
              .data,
          mensaje);
      expect(
          tester
              .widget<Text>(find
                  .byKey(const ValueKey('export-list-family-conflicts')))
              .data,
          'No se puede importar: $mensaje');
      expect(
          tester
              .widget<FilledButton>(
                  find.byKey(const ValueKey('export-list-confirm')))
              .onPressed,
          isNull);
      expect(await notifier.confirm(), mensaje);

      // Se quita el «también llena» que sobra, con su ficha, y ya sigue.
      await tester.tap(find.byTooltip('Quitar 45G0 de 40HC'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('family-conflict-45G0')), findsNothing);
      expect(
          tester
              .widget<FilledButton>(
                  find.byKey(const ValueKey('export-list-confirm')))
              .onPressed,
          isNotNull);
    });

    testWidgets('dos tipos con el mismo código principal son un solo grupo: '
        'no chocan', (tester) async {
      final dosNombres = e2Listado([
        e2Fila(1, 1, '40HC', 'COCTG', 'LGH'),
        e2Fila(2, 2, '40HQ', 'COCTG', 'LGH'),
      ]);
      await e2AbrirLaPagina(tester, plan, dosNombres);
      expect(e2Textos(tester, 'lo declaran'), isEmpty);
      expect(
          tester
              .widget<FilledButton>(
                  find.byKey(const ValueKey('export-list-confirm')))
              .onPressed,
          isNotNull);
    });
  });
}
