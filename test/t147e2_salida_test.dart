// T-147, entrega 2, parte 2a · P2 (10.156; D4, D5 y D6) y el cambio 3 de la
// 10.160 (D16): el BAPLIE de salida.
//
// P2 · El destino final del listado sale en `LOC+83`: el POD del Excel, como
//      viene, cuando la fila trae POT y POD distintos, el POD tiene forma de
//      UN/LOCODE y no es el código que ya sale en `LOC+11`. Llenos y vacíos.
//      Va detrás de `LOC+11` (o de `LOC+13`), antes de `LOC+76` y de `RFF`.
//      `LOC+11` sigue siendo el POT (10.153).
// Cambio 3 · Manda el código ISO del plan cuando el tipo del listado lo
//      llena: el del grupo del lleno, o el de la celda del vacío asignado.
//
// Solo datos sintéticos. Compila también contra `v1.0.2`.
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/departure_baplie_writer.dart';
import 'package:baystream/features/vessel/domain/services/export_list_cross_checker.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t147_listado_support.dart';
import 'support/t147e2_support.dart';

final _dePaso = e2Grupo('0300282', t147Matricula(90), '45G1', 'USHOU', 'LNK',
    carga: 'HNPCR', destino: 'BSNAS', origen: 'HNPCR');

final _edi = e2PlanEdi([
  e2Grupo('0100282', t147Matricula(1), '45G1', 'COCTG', 'LNH', origen: 'GTSTC'),
  e2Grupo('0100482', t147Matricula(2), '45G0', 'COCTG', 'LNH'),
  e2Grupo('0100682', t147Matricula(3), '45G1', 'COCTG', 'LNH',
      destino: 'SAJED'),
  e2Grupo('0100882', t147Matricula(4), '45G1', 'COCTG', 'LNH',
      destino: 'ITGOA', origen: 'GTSTC'),
  e2Grupo('0101082', t147Matricula(5), '45G1', 'COCTG', 'LNH'),
  e2Reserva('0180082', '45G0', 'COTRB', 'LNH'),
  e2Reserva('0180282', '45G1', 'JMKIN', 'LNH'),
  _dePaso,
]);

List<List<Object?>> _hoja() => [
      e2Fila(1, 1, '40HC', 'COCTG', 'LGH', pod: 'SAJED'),
      e2Fila(2, 2, '40HC', 'COCTG', 'LGH'),
      e2Fila(3, 3, '40HC', 'COCTG', 'LGH', pod: 'SAJED'),
      e2Fila(4, 4, '40HC', 'COCTG', 'LGH', pod: 'ITLIV'),
      e2Fila(5, 5, '40HC', 'COCTG', 'LGH', pod: 'SAJ'),
      e2Fila(6, 11, '40HC', 'COTRB', 'LGH', pod: 'CNTAO', vacio: true),
      e2Fila(7, 12, '40HC', 'JMKIN', 'LGH', vacio: true),
    ];

const _celdaDelLleno = {
  1: '0100282', 2: '0100482', 3: '0100682', 4: '0100882', 5: '0101082',
};

List<Movement> _todasLasCargas() => [
      for (final e in _celdaDelLleno.entries)
        e2Movimiento(
            MovementDraft.loadFull('e2', t147Matricula(e.key), e.value,
                order: e.key),
            e.key),
      e2Movimiento(
          MovementDraft.assignEmpty('e2', '0180082', t147Matricula(11), 3900,
              order: 6),
          6),
      e2Movimiento(
          MovementDraft.assignEmpty('e2', '0180282', t147Matricula(12), 3900,
              order: 7),
          7),
    ];

DepartureBaplie _generar(
        String edi, VesselVoyage plan, ExportList lista,
        List<Movement> movimientos) =>
    const DepartureBaplieWriter().generate(
        operation: e2OperacionGuardada(edi, plan),
        state: e2Operacion(plan, lista, movimientos).state,
        list: lista,
        movements: movimientos,
        now: DateTime.utc(2026, 11, 20, 12),
        preview: true);

/// El código ISO del `EQD` de [numero] en [texto].
String? _iso(String texto, int numero) {
  final eqd = e2GrupoDe(texto, t147Matricula(numero))
      .where((s) => s.startsWith('EQD+CN+'))
      .firstOrNull;
  return eqd?.split('+')[3].split(':').first;
}

void main() {
  final plan = e2Plan(_edi);
  final lista = e2Listado(_hoja());
  // Con el respaldo repartido (cuatro 45G1 y un 45G0), 40HC llena los dos.
  final propuestas = e2Proponer(lista, plan, tipos: {'40HC': '45G1'});
  final declarada = e2Normalizar(lista, propuestas);
  final salida = _generar(_edi, plan, declarada, _todasLasCargas());
  List<String> grupo(int numero) =>
      e2GrupoDe(salida.text, t147Matricula(numero));

  group('P2 · el destino final sale en LOC+83', () {
    test('el lleno con POT y POD distintos: LOC+11 con el POT y LOC+83 con '
        'el POD, detrás de LOC+11 y antes de LOC+76 y de RFF', () {
      final g = grupo(1);
      expect(g, contains('LOC+11+COCTG:139:6'));
      expect(g, contains('LOC+83+SAJED:139:6'));
      expect(g.indexOf('LOC+83+SAJED:139:6'),
          g.indexOf('LOC+11+COCTG:139:6') + 1);
      expect(g.indexOf('LOC+83+SAJED:139:6'),
          lessThan(g.indexOf('LOC+76+GTSTC:139:6')));
      expect(g.indexOf('LOC+76+GTSTC:139:6'),
          lessThan(g.indexWhere((s) => s.startsWith('RFF+'))));
      expect(g.where((s) => s.startsWith('LOC+13+')), isEmpty);
    });

    test('vale igual para un vacío asignado', () {
      final id = t147Matricula(11);
      expect(grupo(11), [
        'LOC+147+0180082::5',
        'MEA+WT++KGM:3900',
        'MEA+T++KGM:3900',
        'LOC+9+GTSTC:139:6',
        'LOC+11+COTRB:139:6',
        'LOC+83+CNTAO:139:6',
        'RFF+BM:1',
        'EQD+CN+$id+45G0+++4',
        'NAD+CA+LNH:172:20',
      ]);
    });

    test('con POT igual al POD no sale: ni en el lleno ni en el vacío', () {
      expect(grupo(2).where((s) => s.startsWith('LOC+83+')), isEmpty);
      expect(grupo(12).where((s) => s.startsWith('LOC+83+')), isEmpty);
    });

    test('el plan ya trae el mismo destino: el segmento queda donde estaba, '
        'sin aviso', () {
      expect(grupo(3).where((s) => s.startsWith('LOC+83+')),
          ['LOC+83+SAJED:139:6']);
      expect(salida.warnings.where((w) => w.startsWith('OR 3 ·')), isEmpty);
    });

    test('el plan trae otro destino: manda el listado, en el mismo lugar, y '
        'se dice', () {
      final g = grupo(4);
      expect(g.where((s) => s.startsWith('LOC+83+')), ['LOC+83+ITLIV:139:6']);
      expect(g.indexOf('LOC+83+ITLIV:139:6'),
          g.indexOf('LOC+11+COCTG:139:6') + 1);
      expect(
          salida.warnings,
          contains('OR 4 · ${t147Matricula(4)}: destino final ITLIV, del '
              'listado; el plan decía ITGOA.'));
    });

    test('un POD sin forma de UN/LOCODE no se escribe, y se avisa', () {
      expect(grupo(5).where((s) => s.startsWith('LOC+83+')), isEmpty);
      expect(
          salida.warnings,
          contains('OR 5 · ${t147Matricula(5)}: el POD «SAJ» del listado no '
              'tiene forma de UN/LOCODE; el destino final no se escribió.'));
    });

    test('lo que sigue a bordo conserva su grupo entero, con su LOC+83', () {
      expect(salida.text, contains(_dePaso));
    });

    test('la cuenta de la página, y ningún LOC+13 en toda la salida', () {
      expect(e2Nuevo(() => (salida as dynamic).finalDestinations as int, -1),
          4);
      expect(salida.text, isNot(contains('LOC+13+')));
      expect('LOC+83+'.allMatches(salida.text), hasLength(5));
    });

    test('la salida, releída con el lector, da el POD como destino final',
        () {
      final releida = BaplieParserService().parse(salida.text);
      String? destino(int numero) => releida.containers
          .firstWhere((c) => c.containerId == t147Matricula(numero))
          .finalDestination;
      expect(destino(1), 'SAJED');
      expect(destino(11), 'CNTAO');
      expect(destino(4), 'ITLIV');
      expect(destino(2), isNull);
      expect(destino(90), 'BSNAS');
      expect(releida.readNotices, isEmpty);
    });
  });

  group('P2 · con una fila guardada por la 1.0.1', () {
    ExportListRow fila(int orden, int numero,
            {required String pod, required String pot}) =>
        ExportListRow(
            sheetRow: orden + 5,
            order: orden,
            containerId: t147Matricula(numero),
            status: ContainerStatus.full,
            listType: '40HC',
            listPot: 'COCTG',
            listPod: 'SAJED',
            listLine: 'LGH',
            type: '45G1',
            pot: pot,
            pod: pod,
            line: 'LNH',
            tareKg: 3800,
            vgmKg: 20000);
    DepartureBaplie generar(ExportListRow guardada) => _generar(
        _edi,
        plan,
        ExportList(fileName: 'de-la-101.xlsx', rows: [guardada]),
        [
          e2Movimiento(
              MovementDraft.loadFull(
                  'e2', guardada.containerId, '0101082',
                  order: guardada.order),
              1)
        ]);

    test('su puerto es el POD: LOC+11 con el POD, LOC+13 con el POT (la regla '
        'de T-132) y sin LOC+83, que repetiría LOC+11', () {
      final g = e2GrupoDe(
          generar(fila(5, 5, pod: 'SAJED', pot: 'COCTG')).text,
          t147Matricula(5));
      expect(g, contains('LOC+11+SAJED:139:6'));
      expect(g, contains('LOC+13+COCTG:139:6'));
      expect(g.where((s) => s.startsWith('LOC+83+')), isEmpty);
    });

    test('con «destino final → trasbordo» elegida, como en el piloto 4: '
        'LOC+11 con el trasbordo y LOC+83 con el POD del Excel', () {
      final g = e2GrupoDe(
          generar(fila(5, 5, pod: 'COCTG', pot: 'COCTG')).text,
          t147Matricula(5));
      expect(g, contains('LOC+11+COCTG:139:6'));
      expect(g.where((s) => s.startsWith('LOC+13+')), isEmpty);
      expect(g.indexOf('LOC+83+SAJED:139:6'),
          g.indexOf('LOC+11+COCTG:139:6') + 1);
    });
  });

  group('Cambio 3 · manda el código ISO del plan cuando el tipo lo llena', () {
    test('el lleno sale con el código de su grupo del plan', () {
      expect(_iso(salida.text, 2), '45G0');
      expect(_iso(salida.text, 1), '45G1');
    });

    test('el vacío asignado sale con el código de su celda', () {
      expect(_iso(salida.text, 11), '45G0');
      expect(_iso(salida.text, 12), '45G1');
    });

    test('todas las cargas salen con el código que el plan trae para esa '
        'pieza, y el cruce no cuenta ninguna como dato distinto', () {
      final delPlan = {
        for (final c in plan.containers) c.containerId: c.isoSizeType,
        t147Matricula(11): '45G0',
        t147Matricula(12): '45G1',
      };
      for (final numero in [1, 2, 3, 4, 5, 11, 12]) {
        expect(_iso(salida.text, numero), delPlan[t147Matricula(numero)],
            reason: 'contenedor $numero');
      }
      expect(
          ExportListCrossChecker.crossCheck(declarada, plan, e2Escala)
              .matchesWithDifferences,
          isEmpty);
    });

    test('sin nada declarado, sale el principal de su tipo, como hasta la '
        '1.0.2, y el cruce lo cuenta como dato distinto', () {
      final sinDeclarar =
          lista.normalized(ExportListCrossChecker.tableOf(propuestas));
      final comoAntes = _generar(_edi, plan, sinDeclarar, _todasLasCargas());
      expect(_iso(comoAntes.text, 2), '45G1');
      expect(_iso(comoAntes.text, 11), '45G1');
      expect(
          ExportListCrossChecker.crossCheck(sinDeclarar, plan, e2Escala)
              .matchesWithDifferences
              .map((m) => m.row.order),
          [2]);
    });

    test('la Lista enseña el vacío asignado con el código de su celda', () {
      final data = e2Operacion(plan, declarada, _todasLasCargas());
      expect({
        for (final c in data.assignedEmpties) c.containerId: c.isoSizeType
      }, {
        t147Matricula(11): '45G0',
        t147Matricula(12): '45G1',
      });
    });
  });
}
