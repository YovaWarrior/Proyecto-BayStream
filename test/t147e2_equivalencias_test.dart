// T-147, entrega 2, parte 2a · P3 (hallazgo 3 de la 10.85; 10.151 y 10.160,
// D7 y D8): las equivalencias guardadas.
//
// Hasta la 1.0.2, lo guardado en el dispositivo mandaba sobre lo que dijeran
// los contenedores, se guardaba todo (también los puertos, que son de un
// viaje) y no había dónde verlo ni quitarlo.
// - Manda el plan. Después, la revisión anterior del listado de esta misma
//   operación; después, el dispositivo, y solo si el plan no lo contradice.
// - En el dispositivo se guardan solo tipos y líneas. Los puertos que
//   quedaron de versiones anteriores no se leen ni se tocan.
// - Lo guardado se ve y se quita desde una tarjeta de «Listado de la
//   agencia».
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
  e2Grupo('0100282', t147Matricula(1), '45G1', 'COCTG', 'LNH'),
  e2Grupo('0100482', t147Matricula(2), '45G1', 'COCTG', 'LNH'),
  e2Reserva('0180082', '45G1', 'COTRB', 'LNH'),
  e2Reserva('0180482', 'L5G1', 'COTRB', 'LNH'),
  e2Reserva('0180682', 'L5G0', 'COTRB', 'LNH'),
  e2Reserva('0190282', '22G1', 'JMKIN', 'LNJ'),
]);

/// [potDelOr2] es el POT de la fila 2: con otro código que el del plan, la
/// 1.0.2 lo deduce y lo guarda en el dispositivo como un puerto.
List<List<Object?>> _hoja({String potDelOr2 = 'COCTG'}) => [
      e2Fila(1, 1, '40HC', 'COCTG', 'LGH'),
      e2Fila(2, 2, '40HC', potDelOr2, 'LGH'),
      e2Fila(7, 11, '40HC', 'COTRB', 'LGH', vacio: true),
      e2Fila(9, 13, '45HC', 'COTRB', 'LGH', vacio: true),
      e2Fila(12, 14, '20ST', 'JMKIN', 'LNJ', vacio: true),
    ];

CodeEquivalences _tabla(
        {Map<String, String> tipos = const {},
        Map<String, String> puertos = const {},
        Map<String, String> lineas = const {}}) =>
    CodeEquivalences({
      EquivalenceKind.type: tipos,
      EquivalenceKind.port: puertos,
      EquivalenceKind.line: lineas,
    });

String? _noUsada(EquivalenceProposal p) =>
    e2Nuevo(() => (p as dynamic).discarded as String?, null);

void main() {
  final plan = e2Plan(_edi);
  final lista = e2Listado(_hoja());
  EquivalenceProposal propuesta(
          CodeEquivalences guardado, EquivalenceKind kind, String codigo) =>
      e2De(
          ExportListCrossChecker.propose(lista, plan,
              portOfCall: e2Escala, saved: guardado),
          kind,
          codigo);

  group('P3 · manda el plan, no lo guardado', () {
    test('lo guardado que los contenedores contradicen no se usa', () {
      final hc = propuesta(_tabla(tipos: {'40HC': '45R1'}),
          EquivalenceKind.type, '40HC');
      expect(hc.planCode, '45G1');
      expect(hc.origin.name, 'inferred');
      expect(_noUsada(hc), '45R1');
      final linea = propuesta(
          _tabla(lineas: {'LGH': 'LNK'}), EquivalenceKind.line, 'LGH');
      expect(linea.planCode, 'LNH');
      expect(_noUsada(linea), 'LNK');
    });

    test('sin respaldo, lo guardado se usa si el plan carga ese código', () {
      final hc = propuesta(_tabla(tipos: {'45HC': 'L5G1'}),
          EquivalenceKind.type, '45HC');
      expect(hc.needsUser, isFalse);
      expect(hc.planCode, 'L5G1');
      expect(hc.origin.name, 'saved');
      expect(_noUsada(hc), isNull);
    });

    test('sin respaldo, lo guardado no se usa si el plan no carga ese '
        'código: se pide', () {
      final hc = propuesta(_tabla(tipos: {'45HC': 'L5G9'}),
          EquivalenceKind.type, '45HC');
      expect(hc.needsUser, isTrue);
      expect(hc.planCode, isNull);
      expect(_noUsada(hc), 'L5G9');
      // Las sugerencias siguen siendo las de siempre.
      expect(hc.candidates, containsAll(['L5G1', 'L5G0']));
    });

    test('los puertos guardados en el dispositivo ya no se leen', () {
      final puerto = propuesta(_tabla(puertos: {'COTRB': 'JMKIN'}),
          EquivalenceKind.port, 'COTRB');
      expect(puerto.planCode, 'COTRB');
      expect(puerto.origin.name, 'samePlanCode');
      expect(_noUsada(puerto), isNull);
    });

    test('sin nada guardado, todo como hasta la 1.0.2', () {
      final propuestas = ExportListCrossChecker.propose(lista, plan,
          portOfCall: e2Escala);
      expect([
        for (final p in propuestas)
          if (p.needsUser) '${p.kind.wire}:${p.listCode}'
      ], ['type:45HC', 'type:20ST']);
      expect(e2De(propuestas, EquivalenceKind.type, '40HC').planCode, '45G1');
    });
  });

  group('P3 · la revisión anterior del listado de esta operación', () {
    Operation conListado(Map<String, dynamic> guardado) => Operation(
          id: 'e2',
          vesselName: plan.vessel.name,
          voyageNumber: plan.voyageNumber,
          portOfCall: e2Escala,
          createdAt: DateTime.utc(2026, 11, 20),
          sources: [
            OperationSource(
                kind: OperationSourceKind.loadingBaplie,
                fileName: 'sintetico-t147e2.edi',
                content: _edi),
            OperationSource(
                kind: OperationSourceKind.exportList,
                fileName: 'sintetico-t147e2.xlsx',
                content: jsonEncode(guardado)),
          ],
        );
    final anterior = lista
        .normalized(_tabla(tipos: {'45HC': 'L5G1', '20ST': '22G1'}))
        .toJson();

    testWidgets('manda sobre lo guardado en el dispositivo, y se dice',
        (tester) async {
      final scope = await e2AbrirLaPagina(tester, plan, lista,
          equipo: E2Equipo(_tabla(tipos: {'45HC': 'L5G0'})),
          bitacora: E2Bitacora([conListado(anterior)]));
      final hc = e2De(scope.read(exportListImportProvider).proposals,
          EquivalenceKind.type, '45HC');
      expect(hc.planCode, 'L5G1');
      expect(hc.origin.name, 'previous');
      expect(e2Textos(tester, 'De la revisión anterior'),
          hasLength(2)); // 45HC y 20ST
      const noSeUso = 'En este dispositivo estaba guardada 45HC → L5G0, y la '
          'revisión anterior de este listado usa L5G1: no se usó.';
      expect(e2Textos(tester, 'En este dispositivo estaba guardada'),
          [noSeUso]);
      expect(scope.read(exportListImportProvider).hasPending, isFalse);
    });

    testWidgets('lo que la oficina declaró en «también llena» sigue valiendo',
        (tester) async {
      final scope = await e2AbrirLaPagina(tester, plan, lista,
          bitacora: E2Bitacora([
            conListado({
              ...anterior,
              'typeFamilies': {'L5G0': 'L5G1'},
            })
          ]));
      final hc = e2De(scope.read(exportListImportProvider).proposals,
          EquivalenceKind.type, '45HC');
      expect(hc.planCode, 'L5G1');
      expect(e2Tambien(hc), ['L5G0']);
    });
  });

  group('P3 · qué se guarda en el dispositivo', () {
    testWidgets('solo tipos y líneas; los puertos que había no se tocan',
        (tester) async {
      // La fila 2 trae un POT que el plan llama de otra forma: la 1.0.2 lo
      // deducía y lo guardaba en el dispositivo.
      final conOtroPuerto = e2Listado(_hoja(potDelOr2: 'COCAR'));
      final equipo = E2Equipo(_tabla(puertos: {'INMUN': 'COCTG'}));
      final scope = await e2AbrirLaPagina(tester, plan, conOtroPuerto,
          equipo: equipo);
      final notifier = scope.read(exportListImportProvider.notifier);
      expect(
          e2De(scope.read(exportListImportProvider).proposals,
                  EquivalenceKind.port, 'COCAR')
              .planCode,
          'COCTG');
      notifier
        ..choose(EquivalenceKind.type, '45HC', 'L5G1')
        ..choose(EquivalenceKind.type, '20ST', '22G1');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('export-list-confirm')));
      await tester.pumpAndSettle();
      expect(e2Textos(tester, 'Listado guardado en la operación'), hasLength(1));
      expect(equipo.tabla.of(EquivalenceKind.type),
          {'40HC': '45G1', '45HC': 'L5G1', '20ST': '22G1'});
      expect(equipo.tabla.of(EquivalenceKind.line), {'LGH': 'LNH'});
      expect(equipo.tabla.of(EquivalenceKind.port), {'INMUN': 'COCTG'});
    });
  });

  group('P3 · lo guardado se ve y se quita', () {
    CodeEquivalences sembrado() => _tabla(
        tipos: {'40HC': '45R1', '45HC': 'L5G1'},
        lineas: {'LGH': 'LNH'},
        puertos: {'INMUN': 'COCTG', 'CNTAO': 'JMKIN'});

    Future<void> abrirLaTarjeta(WidgetTester tester) async {
      await tester.tap(find.byKey(const ValueKey('saved-equivalences')));
      await tester.pumpAndSettle();
    }

    testWidgets('la tarjeta enseña lo guardado, también sin un listado leído',
        (tester) async {
      await e2AbrirLaPagina(tester, plan, lista,
          equipo: E2Equipo(sembrado()), leer: false);
      expect(e2Textos(tester, 'Equivalencias guardadas en este dispositivo'),
          ['Equivalencias guardadas en este dispositivo (3)']);
      await abrirLaTarjeta(tester);
      expect(e2Textos(tester, RegExp(r'^(Tipo|Línea) \w+ → ')),
          ['Tipo 40HC → 45R1', 'Tipo 45HC → L5G1', 'Línea LGH → LNH']);
      expect(e2Textos(tester, 'De puerto, de versiones anteriores'),
          ['De puerto, de versiones anteriores (2): ya no se usan.']);
      expect(
          e2Textos(tester, 'no cambia ningún listado'),
          ['Quitar una equivalencia no cambia ningún listado ya importado.']);
    });

    testWidgets('con un equipo sin nada guardado no hay tarjeta',
        (tester) async {
      await e2AbrirLaPagina(tester, plan, lista);
      expect(find.byKey(const ValueKey('saved-equivalences')), findsNothing);
    });

    testWidgets('lo que no se usó dice por qué', (tester) async {
      await e2AbrirLaPagina(tester, plan, lista,
          equipo: E2Equipo(_tabla(tipos: {'40HC': '45R1', '45HC': 'L5G9'})));
      const sinCargarlo = 'En este dispositivo estaba guardada 45HC → L5G9, y '
          'el plan no carga L5G9 en esta escala: no se usó.';
      const contradicha = 'En este dispositivo estaba guardada 40HC → 45R1, y '
          'el plan dice 45G1 (2 contenedores): no se usó.';
      expect(e2Textos(tester, 'En este dispositivo estaba guardada'),
          [sinCargarlo, contradicha]);
    });

    testWidgets('quitar una, quitar las de puerto y quitar todas',
        (tester) async {
      final equipo = E2Equipo(sembrado());
      await e2AbrirLaPagina(tester, plan, lista, equipo: equipo, leer: false);
      await abrirLaTarjeta(tester);

      await tester.tap(find.byKey(const ValueKey('saved-remove-type-40HC')));
      await tester.pumpAndSettle();
      expect(equipo.tabla.of(EquivalenceKind.type), {'45HC': 'L5G1'});
      expect(e2Textos(tester, 'Equivalencias guardadas en este dispositivo'),
          ['Equivalencias guardadas en este dispositivo (2)']);

      await tester.tap(find.byKey(const ValueKey('saved-remove-ports')));
      await tester.pumpAndSettle();
      expect(equipo.tabla.of(EquivalenceKind.port), isEmpty);
      expect(equipo.tabla.of(EquivalenceKind.type), {'45HC': 'L5G1'});
      expect(find.byKey(const ValueKey('saved-ports')), findsNothing);

      await tester.tap(find.byKey(const ValueKey('saved-remove-all')));
      await tester.pumpAndSettle();
      expect(equipo.tabla.isEmpty, isTrue);
      expect(find.byKey(const ValueKey('saved-equivalences')), findsNothing);
    });

    testWidgets('quitar una con un listado leído vuelve a proponer, sin '
        'perder lo que la oficina ya eligió', (tester) async {
      final equipo = E2Equipo(_tabla(tipos: {'45HC': 'L5G1'}));
      final scope =
          await e2AbrirLaPagina(tester, plan, lista, equipo: equipo);
      scope
          .read(exportListImportProvider.notifier)
          .choose(EquivalenceKind.type, '20ST', '22G1');
      await tester.pumpAndSettle();
      expect(scope.read(exportListImportProvider).hasPending, isFalse);

      await tester.tap(find.byKey(const ValueKey('saved-equivalences')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('saved-remove-type-45HC')));
      await tester.pumpAndSettle();
      final propuestas = scope.read(exportListImportProvider).proposals;
      expect(e2De(propuestas, EquivalenceKind.type, '45HC').needsUser, isTrue);
      final st = e2De(propuestas, EquivalenceKind.type, '20ST');
      expect(st.planCode, '22G1');
      expect(st.origin.name, 'chosen');
    });
  });
}
