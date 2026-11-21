// T-147, entrega 2, parte 2a · P1 (10.156 y 10.160, cambios 1 y 2): las filas
// que el listado de la agencia cancela.
//
// - Una fila está cancelada si su MARCHAMO o su CONTENIDO trae, entera y sin
//   mirar mayúsculas ni tildes, la palabra CANCEL con sus formas, «ROLEADO» o
//   «YA EMBARCADO», con su femenino y su plural.
// - Una fila cancelada no cuenta como carga: ni en el resumen, ni en las
//   equivalencias, ni en el cruce. No se ofrece en la hoja ni en la carga por
//   OR; sale solo si se la busca, y se carga con motivo.
// - Lo que subió, subió: la carga de una fila cancelada queda como conflicto
//   para la oficina, también si se cargó antes de la revisión que la cancela.
//
// Solo datos sintéticos (test/support/t147e2_support.dart). Compila también
// contra `v1.0.2`: lo que ahí no existe se lee con `e2Nuevo`.
import 'dart:convert';
import 'dart:io';

import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/departure_baplie_writer.dart';
import 'package:baystream/features/vessel/domain/services/export_list_cross_checker.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';
import 'package:baystream/features/vessel/presentation/providers/export_list_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t147_listado_support.dart';
import 'support/t147e2_support.dart';

const _guardadoPorLa102 = 'test/fixtures/t147e2_listado_guardado_por_la_102.json';

final _edi = e2EdiDeLasCanceladas;

List<List<Object?>> _hoja({String? notaDelOr1}) =>
    e2HojaDeLasCanceladas(notaDelOr1: notaDelOr1);

/// Las que el listado cancela: todas menos la 1, la 2, la 9, la 10, la 12 y
/// la 15, cuya nota no es ninguna de las tres.
const _canceladas = [3, 4, 5, 6, 7, 8, 11, 14];

VesselVoyage _plan() => e2Plan(_edi);

ExportList _normalizada(ExportList lista) =>
    e2Normalizar(lista, e2Proponer(lista, _plan(), tipos: {'20ST': '22G1'}));

bool _cancelada(ExportListRow fila) =>
    e2Nuevo(() => (fila as dynamic).cancelled as bool, false);

void main() {
  final lista = e2Listado(_hoja());
  final plan = _plan();

  group('P1 · cómo se reconoce una fila cancelada', () {
    test('las tres notas, con sus formas, en MARCHAMO y en CONTENIDO', () {
      expect(lista.issues, isEmpty);
      expect([
        for (final fila in lista.rows)
          if (_cancelada(fila)) fila.order
      ], _canceladas);
    });

    test('la expresión: CANCEL, ROLEADO y YA EMBARCADO, enteras', () {
      bool casa(String nota) => _cancelada(e2Listado([
            e2Fila(1, 1, '40HC', 'COCTG', 'LGH', nota: nota),
          ]).rows.single);
      for (final nota in [
        'CANCEL', 'CANCELADO', 'CANCELADA', 'CANCELADOS', 'CANCELADAS',
        'CANCELLED', 'CANCELED', 'ROLEADO', 'ROLEADA', 'ROLEADOS', 'ROLEADAS',
        'YA EMBARCADO', 'YA EMBARCADA', 'YA EMBARCADOS', 'YA EMBARCADAS',
        'ROLEADO - CANCEL', 'YA EMBARCADO -CANCEL', 'REEMPLAZO - CANCEL',
        'cancelado', 'Ya   Embarcado', 'CÁNCELADO',
      ]) {
        expect(casa(nota), isTrue, reason: nota);
      }
      for (final nota in [
        // No son la palabra entera, o no son ninguna de las tres.
        'CANCELACION', 'ENROLEADO', 'EMBARCADO', 'PENDIENTE', 'REEMPLAZO',
        'AB123456', 'ROLEADOR',
      ]) {
        expect(casa(nota), isFalse, reason: nota);
      }
    });

    test('la nota de MARCHAMO sale entera; la de CONTENIDO, sola', () {
      String? nota(int orden) => e2Nuevo(
          () => (lista.byOrder(orden) as dynamic).cancelNote as String?, null);
      expect(nota(3), 'ROLEADO - CANCEL');
      expect(nota(4), 'YA EMBARCADO -CANCEL');
      expect(nota(8), 'Ya embarcada');
      expect(nota(6), 'CANCELLED');
      expect(nota(1), isNull);
    });

    test('una nota sin cifras que no es una cancelación se carga y se avisa; '
        'un texto con cifras es un marchamo', () {
      final notas = e2Nuevo(
          () => (lista as dynamic).unrecognizedNotes as Map, const {});
      expect(notas, {
        'PENDIENTE': [12],
        'CANCELACION': [15],
      });
      expect(_cancelada(lista.byOrder(12)!), isFalse);
      expect(_cancelada(lista.byOrder(2)!), isFalse);
      expect(_cancelada(lista.byOrder(15)!), isFalse);
    });

    test('un listado guardado por la 1.0.2 se lee cancelado sin volver a '
        'importarlo, y se vuelve a guardar igual', () {
      final texto = File(_guardadoPorLa102).readAsStringSync();
      final guardado =
          ExportList.fromJson(jsonDecode(texto) as Map<String, dynamic>);
      expect([
        for (final fila in guardado.rows)
          if (_cancelada(fila)) fila.order
      ], _canceladas);
      expect(jsonEncode(guardado.toJson()), texto.trim());
    });
  });

  group('P1 · una fila cancelada no cuenta como carga', () {
    test('las equivalencias cuentan solo lo que se carga, y un código que '
        'solo traen filas canceladas no pide equivalencia', () {
      final propuestas = e2Proponer(lista, plan);
      expect(e2De(propuestas, EquivalenceKind.type, '40HC').rows, 5);
      expect(propuestas.where((p) => p.listCode == '40XX'), isEmpty);
      expect(e2De(propuestas, EquivalenceKind.port, 'COCTG').rows, 3);
    });

    test('el cruce: ningún lleno cancelado sale como «no está en el plan», y '
        'el vacío cancelado no entra en su grupo', () {
      final cruce = ExportListCrossChecker.crossCheck(
          _normalizada(lista), plan, e2Escala);
      expect(cruce.matches.map((m) => m.row.order), [1, 2]);
      // La 15, con una nota que no es una cancelación, sí se carga y no está.
      expect(cruce.fullsNotInPlan.map((r) => r.order), [15]);
      final grupo = cruce.groups
          .firstWhere((g) => g.type == '45G1' && g.pod == 'COTRB');
      expect(grupo.empties.map((r) => r.order), [9, 10]);
      expect(grupo.balanced, isTrue);
      expect(cruce.emptiesWithoutGroup, isEmpty);
    });

    test('el cruce lleva aparte las canceladas, y de ellas, la que el plan '
        'todavía carga', () {
      final cruce = ExportListCrossChecker.crossCheck(
          _normalizada(lista), plan, e2Escala);
      expect(
          e2Nuevo(
              () => [
                    for (final r in (cruce as dynamic).cancelled as List)
                      (r as ExportListRow).order
                  ],
              const <int>[]),
          _canceladas);
      expect(
          e2Nuevo(
              () => [
                    for (final m in (cruce as dynamic).cancelledInPlan as List)
                      (m as ExportListMatch).row.order
                  ],
              const <int>[]),
          [3]);
      // El contenedor que el listado cancela está en el listado: no es uno
      // «del plan que no está en el listado».
      expect(cruce.planNotInList, isEmpty);
    });
  });

  group('P1 · no se ofrece, pero se carga con motivo', () {
    final normalizada = _normalizada(lista);
    LoadingOperation operacion([List<Movement> movimientos = const []]) =>
        e2Operacion(plan, normalizada, movimientos);
    ReservedSlot celda(String posicion) => plan.reservedSlots
        .firstWhere((s) => s.stowagePosition.toIsoCode() == posicion);

    test('la hoja de los vacíos no ofrece el cancelado', () {
      final data = operacion();
      expect(data.search('', empties: true).map((r) => r.order), [9, 10, 12]);
      expect(data.rowsFor(celda('0180082'), '').map((r) => r.order), [9, 10]);
    });

    test('si se busca por su OR o por su número, sale', () {
      final data = operacion();
      expect(data.search('11', empties: true).map((r) => r.order),
          contains(11));
      final digitos = t147Matricula(13).substring(7);
      expect(data.search(digitos, empties: true).map((r) => r.order),
          contains(11));
      expect(
          data.rowsFor(celda('0180082'), '11').map((r) => r.order), [11]);
    });

    test('la carga por OR no ofrece el lleno que el plan trae y el listado '
        'cancela, salvo que se lo busque', () {
      final data = operacion();
      expect(data.search('').map((r) => r.order), [1, 2]);
      expect(data.search('3').map((r) => r.order), contains(3));
    });

    test('el lleno cancelado pide motivo y dice por qué; no se bloquea', () {
      final data = operacion();
      final fila = normalizada.byOrder(3)!;
      final revision = data.check(fila, '0100682');
      expect(revision.blocked, isFalse);
      expect(revision.needsReason, isTrue);
      expect(revision.issues.map((i) => i.kind.name), ['listCancelled']);
      expect(revision.issues.single.message,
          startsWith('el listado lo marca cancelado («ROLEADO - CANCEL»).'));
      expect(() => data.draft(fila, '0100682'), throwsStateError);
      final carga =
          data.draft(fila, '0100682', reason: 'Llegó al gancho y subió');
      expect(carga.type, MovementType.loadFull);
      expect(carga.payload['reason'], 'Llegó al gancho y subió');
    });

    test('el vacío cancelado se asigna con motivo', () {
      final data = operacion();
      final fila = normalizada.byOrder(11)!;
      expect(data.candidateSlots(fila).map((s) => s.stowagePosition.toIsoCode()),
          ['0180082', '0180282']);
      final revision = data.check(fila, '0180082');
      expect(revision.blocked, isFalse);
      expect(revision.issues.map((i) => i.kind.name), ['listCancelled']);
      expect(() => data.draft(fila, '0180082'), throwsStateError);
      expect(
          data.draft(fila, '0180082', reason: 'Lo autoriza la línea').type,
          MovementType.assignEmpty);
    });

    test('la fila que se carga sin nota no pide motivo', () {
      final data = operacion();
      expect(data.check(normalizada.byOrder(1)!, '0100282').issues, isEmpty);
      expect(data.check(normalizada.byOrder(9)!, '0180082').issues, isEmpty);
    });
  });

  group('P1 · lo que subió, subió: queda como conflicto', () {
    final normalizada = _normalizada(lista);
    final lleno = e2Movimiento(
        MovementDraft.loadFull('e2', t147Matricula(3), '0100682',
            order: 3, reason: 'Llegó al gancho y subió'),
        1);
    final vacio = e2Movimiento(
        MovementDraft.assignEmpty('e2', '0180082', t147Matricula(13), 3900,
            order: 11, reason: 'Lo autoriza la línea'),
        2);

    test('el lleno cancelado, cargado: la celda queda en conflicto y el '
        'mensaje dice la nota', () {
      final data = e2Operacion(plan, normalizada, [lleno]);
      final item = data.state['C:${t147Matricula(3)}']!;
      expect(item.state, ItemState.moved);
      expect(item.inConflict, isTrue);
      final conflicto = data.state.conflicts.single;
      expect(conflicto.kind.name, 'cancelledInList');
      expect(
          conflicto.message,
          'OR 3 · ${t147Matricula(3)} se cargó y el listado lo marca '
          'cancelado («ROLEADO - CANCEL»). Si el registro fue un error, '
          'deshazlo desde el detalle de la celda.');
    });

    test('el vacío cancelado, asignado: el conflicto queda en su celda', () {
      final data = e2Operacion(plan, normalizada, [vacio]);
      expect(data.state['R:0180082']!.inConflict, isTrue);
      expect(data.state.conflicts.single.kind.name, 'cancelledInList');
      expect(data.state.conflicts.single.message,
          contains('OR 11 · ${t147Matricula(13)} se cargó'));
    });

    test('«Deshacer carga» quita el conflicto', () {
      final deshecho = e2Movimiento(
          MovementDraft.annul('e2', lleno.id, 'Se marcó por error',
              target: lleno.target),
          3);
      final data = e2Operacion(plan, normalizada, [lleno, deshecho]);
      expect(data.state.conflicts, isEmpty);
      expect(data.state['C:${t147Matricula(3)}']!.state, ItemState.planned);
    });

    test('se cargó antes, y la revisión del listado lo cancela: la carga no '
        'se toca, la importación lo cuenta y queda el conflicto', () {
      final antes = _normalizada(lista);
      final carga = e2Movimiento(
          MovementDraft.loadFull('e2', t147Matricula(1), '0100282', order: 1),
          1);
      expect(e2Operacion(plan, antes, [carga]).state.conflicts, isEmpty);

      final revision = _normalizada(e2Listado(_hoja(notaDelOr1: 'CANCELADO')));
      final estado = e2Operacion(plan, antes, [carga]).state;
      final impacto =
          ExportListCrossChecker.revisionImpact(estado, antes, revision);
      expect(
          e2Nuevo(
              () => ((impacto as dynamic).loadedNowCancelled as List)
                  .cast<String>(),
              const <String>[]),
          [t147Matricula(1)]);

      final despues = e2Operacion(plan, revision, [carga]);
      expect(despues.state['C:${t147Matricula(1)}']!.state, ItemState.moved);
      expect(despues.state.conflicts.map((c) => c.kind.name),
          ['cancelledInList']);
    });
  });

  group('P1 · el BAPLIE de salida', () {
    final normalizada = _normalizada(lista);
    DepartureBaplie salida([List<Movement> movimientos = const []]) =>
        const DepartureBaplieWriter().generate(
            operation: e2OperacionGuardada(_edi, plan),
            state: e2Operacion(plan, normalizada, movimientos).state,
            list: normalizada,
            movements: movimientos,
            now: DateTime.utc(2026, 11, 20, 12),
            preview: true);

    test('«Filas que no cargaron» dice la nota de la agencia, venga de '
        'MARCHAMO o de CONTENIDO', () {
      final lineas = salida().notLoaded;
      String linea(int orden, int numero, String nota) =>
          'OR $orden · ${t147Matricula(numero)} · cancelado en el listado '
          '(«$nota»)';
      expect(
          lineas,
          containsAll([
            linea(3, 3, 'ROLEADO - CANCEL'),
            linea(4, 20, 'YA EMBARCADO -CANCEL'),
            linea(6, 22, 'CANCELLED'),
            linea(7, 23, 'ROLEADO'),
            linea(11, 13, 'CANCELADO'),
          ]));
      expect(lineas.where((l) => l.contains('cancelado en el listado')),
          hasLength(_canceladas.length));
      // Las que se cargan y no subieron siguen con su motivo de siempre.
      expect(lineas, contains('OR 1 · ${t147Matricula(1)} · carga no registrada'));
    });

    test('la cancelada que está a bordo sale en la salida, con su aviso', () {
      final carga = e2Movimiento(
          MovementDraft.loadFull('e2', t147Matricula(3), '0100682',
              order: 3, reason: 'Llegó al gancho y subió'),
          1);
      final generada = salida([carga]);
      expect(generada.text, contains('EQD+CN+${t147Matricula(3)}+'));
      expect(
          generada.warnings,
          contains('OR 3 · ${t147Matricula(3)}: está a bordo y el listado lo '
              'marca cancelado («ROLEADO - CANCEL»).'));
      expect(generada.notLoaded.where((l) => l.startsWith('OR 3 ·')), isEmpty);
    });
  });

  group('P1 · en pantalla', () {
    testWidgets('el resumen cuenta lo que se carga y las canceladas, por su '
        'nota', (tester) async {
      await e2AbrirLaPagina(tester, plan, lista);
      expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('export-list-counts')))
              .data,
          '14 filas en 1 agencias · 6 para cargar: 3 llenos y 3 vacíos');
      expect(
          e2Textos(tester, 'canceladas en el listado, que no se cargan'),
          ['8 canceladas en el listado, que no se cargan: 7 llenos y 1 vacío']);
      expect(e2Textos(tester, 'ROLEADO - CANCEL 1'), hasLength(1));
      expect(e2Textos(tester, 'Canceladas en el listado (8)'), hasLength(1));
    });

    testWidgets('la nota que no se reconoce se avisa, con su OR y qué hacer',
        (tester) async {
      await e2AbrirLaPagina(tester, plan, lista);
      String aviso(String nota, int orden) =>
          '1 fila trae en MARCHAMO una nota que no se reconoce: «$nota» '
          '(OR $orden). Se carga. Si no se carga en este buque, pide a la '
          'agencia que diga CANCELADO y vuelve a importar el listado.';
      expect(e2Textos(tester, 'una nota que no se reconoce'),
          [aviso('PENDIENTE', 12), aviso('CANCELACION', 15)]);
    });

    testWidgets('el cruce nombra la cancelada que el plan todavía carga',
        (tester) async {
      final scope = await e2AbrirLaPagina(tester, plan, lista);
      scope
          .read(exportListImportProvider.notifier)
          .choose(EquivalenceKind.type, '20ST', '22G1');
      await tester.pumpAndSettle();
      expect(e2Textos(tester, 'llenos cruzan con el plan'),
          ['2 de 3 llenos cruzan con el plan']);
      expect(e2Textos(tester, 'que el plan todavía carga'), [
        '1 cancelada en el listado que el plan todavía carga',
        'Canceladas en el listado que el plan todavía carga (1)',
      ]);
    });

    testWidgets('un listado sin notas dice lo de siempre', (tester) async {
      await e2AbrirLaPagina(
          tester,
          plan,
          e2Listado([
            e2Fila(1, 1, '40HC', 'COCTG', 'LGH'),
            e2Fila(9, 11, '40HC', 'COTRB', 'LGH', vacio: true),
          ]));
      expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('export-list-counts')))
              .data,
          '2 filas en 1 agencias · 1 llenos · 1 vacíos');
      expect(e2Textos(tester, 'cancelada'), isEmpty);
    });
  });
}
