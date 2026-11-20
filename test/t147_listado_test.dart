// T-147 · R4, R5 y R6 (10.151, hallazgos 3 y 5): el listado de la agencia.
//
// R4 · Con la columna POT llena, el puerto de la fila para cruzar con el plan
//      es el POT; vacía, el POD, como hasta la 1.0.1. La fila conserva los
//      dos, la pantalla los enseña cuando son distintos y la forma del
//      listado guardado en la operación no cambia.
// R5 · Un código del listado sin respaldo, igual a un código que el plan
//      carga en la escala, se propone como identidad, no como pendiente.
// R6 · «COD.» vale como «CODIGO», y «TRANSBORDOS» y «VACIOS» son encabezados
//      de sección, como «AGREGADOS».
//
// Solo datos sintéticos (test/support/t147_listado_support.dart).
import 'dart:convert';
import 'dart:io';

import 'package:baystream/core/errors/failures.dart';
import 'package:baystream/features/vessel/data/services/export_list_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/export_list_repository.dart';
import 'package:baystream/features/vessel/domain/repositories/local_vessel_repository.dart';
import 'package:baystream/features/vessel/domain/repositories/movement_log_repository.dart';
import 'package:baystream/features/vessel/domain/services/export_list_cross_checker.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';
import 'package:baystream/features/vessel/presentation/pages/export_list_import_page.dart';
import 'package:baystream/features/vessel/presentation/providers/export_list_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t147_listado_support.dart';

const _guardadoPorLa101 = 'test/fixtures/t147_listado_guardado_por_la_101.json';

/// Las claves de una fila que lee `ExportListRow.fromJson` en `37be8a5`.
const _clavesDeLa101 = {
  'row', 'order', 'container', 'status', 'type', 'pot', 'pod', 'line',
  'listType', 'listPot', 'listPod', 'listLine', 'tareKg', 'vgmKg', 'netKg',
  'reeferTemperature', 'origin', 'contents', 'hour', 'seal', 'agency',
  'imdgClass', 'unNumbers',
};

List<EquivalenceProposal> _proponer(ExportList lista, VesselVoyage plan) =>
    ExportListCrossChecker.propose(lista, plan, portOfCall: 'GTSTC');

List<String> _pendientes(Iterable<EquivalenceProposal> propuestas) => [
      for (final p in propuestas)
        if (p.needsUser) '${p.kind.wire}:${p.listCode}'
    ];

EquivalenceProposal _de(Iterable<EquivalenceProposal> propuestas,
        EquivalenceKind kind, String codigo) =>
    propuestas.firstWhere((p) => p.kind == kind && p.listCode == codigo);

/// Una hoja con solo POD (sin columna POT), para R5.
List<List<Object?>> _hojaSinPot(List<List<Object?>> filas) => [
      const ['OR', 'CONTENEDOR', 'TIPO', 'POD', 'TARA', 'PESO VGM', 'F', 'E',
        'CONTENIDO', 'OPR'],
      const ['AGENCIA UNO S.A. CODIGO 00-000-001'],
      ...filas,
    ];

List<Object?> _vacio(int orden, int numero, String tipo, String pod,
        String linea) =>
    [orden, t147Matricula(numero), tipo, pod, 3900, null, null, 'X',
      'VACIO EN PATIO', linea];

class _Local implements LocalVesselRepository {
  @override
  Future<Either<Failure, CodeEquivalences>> getCodeEquivalences() async =>
      Right(CodeEquivalences.empty);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Log implements MovementLogRepository {
  @override
  Future<Either<Failure, List<Operation>>> getOperations() async =>
      const Right([]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PlanNotifier extends VoyageNotifier {
  final VesselVoyage plan;
  _PlanNotifier(this.plan);

  @override
  AsyncValue<VesselVoyage?> build() => AsyncValue.data(plan);
}

/// Entrega el listado ya leído: la hoja sintética no pasa por un `.xlsx`.
class _Listados implements ExportListRepository {
  final ExportList lista;
  const _Listados(this.lista);

  @override
  Future<Either<Failure, ExportList>> parseExportList(List<int> bytes,
          {String fileName = 'listado.xlsx'}) async =>
      Right(lista);
}

Future<ProviderContainer> _abrirLaPagina(
    WidgetTester tester, ExportList lista) async {
  tester.view.physicalSize = const Size(360, 6000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(overrides: [
    voyageNotifierProvider.overrideWith(() => _PlanNotifier(t147Plan())),
    localVesselRepositoryProvider.overrideWith((ref) async => _Local()),
    movementLogRepositoryProvider.overrideWith((ref) async => _Log()),
    exportListRepositoryProvider.overrideWithValue(_Listados(lista)),
  ], child: const MaterialApp(home: ExportListImportPage())));
  await tester.pump();
  final scope = ProviderScope.containerOf(
      tester.element(find.byType(ExportListImportPage)));
  await scope
      .read(exportListImportProvider.notifier)
      .loadBytes(const [1], fileName: 'sintetico-t147.xlsx');
  await tester.pumpAndSettle();
  return scope;
}

void main() {
  group('R6 · los separadores', () {
    test('«COD.» vale como «CODIGO», y «TRANSBORDOS» y «VACIOS» son '
        'secciones: ninguna fila sin entender', () {
      final lista = t147Listado();
      expect(lista.issues, isEmpty);
      expect(lista.rows, hasLength(8));
      expect(lista.agencies, {
        'AGENCIA UNO S.A.': 2,
        'TRANSBORDOS': 1,
        'VACIOS': 3,
        'AGENCIA DOS S.A.': 1,
        'AGREGADOS': 1,
      });
      expect(lista.byOrder(1)!.agency, 'AGENCIA UNO S.A.');
      expect(lista.byOrder(3)!.agency, 'TRANSBORDOS');
      expect(lista.byOrder(7)!.agency, 'VACIOS');
      expect(lista.byOrder(4)!.agency, 'AGENCIA DOS S.A.');
    });

    test('el separador se reconoce con espacios, punto y tilde', () {
      const parser = ExportListParserService();
      for (final (texto, agencia) in [
        ('AGENCIA UNO S.A. COD. 00-000-001', 'AGENCIA UNO S.A.'),
        ('  Agencia Uno S.A.   Cod.00-000-001 ', 'Agencia Uno S.A.'),
        ('AGENCIA UNO S.A. CÓDIGO 00-000-001', 'AGENCIA UNO S.A.'),
        ('AGENCIA UNO S.A. CODIGO: 00-000-001', 'AGENCIA UNO S.A.'),
      ]) {
        final lista = parser.parseGrid(_hojaSinPot([])
          ..[1] = [texto]
          ..add(_vacio(1, 11, '45G1', 'COTRB', 'LNH')));
        expect(lista.issues, isEmpty, reason: texto);
        expect(lista.rows.single.agency, agencia, reason: texto);
      }
      for (final seccion in ['TRANSBORDOS', 'Transbordo', ' VACIOS ', 'VACÍOS',
        'VACIO', 'AGREGADOS']) {
        final lista = parser.parseGrid(_hojaSinPot([
          [seccion],
          _vacio(1, 11, '45G1', 'COTRB', 'LNH'),
        ]));
        expect(lista.issues, isEmpty, reason: seccion);
        expect(lista.rows.single.agency, isNot('AGENCIA UNO S.A.'),
            reason: seccion);
      }
    });

    test('lo que no es un separador se sigue informando con su fila', () {
      final lista = const ExportListParserService().parseGrid(_hojaSinPot([
        const ['NOTA: REVISAR CODOS DE LA TUBERIA'],
        const ['VACIOS PENDIENTES DE CONFIRMAR'],
        _vacio(1, 11, '45G1', 'COTRB', 'LNH'),
      ]));
      expect(lista.issues.map((i) => i.sheetRow), [3, 4]);
      expect(lista.rows.single.agency, 'AGENCIA UNO S.A.');
    });
  });

  group('R4 · el cruce va por el POT', () {
    test('con POT, el puerto de la fila es el POT, y conserva los dos', () {
      final fila = t147Listado().byOrder(1)!;
      expect(fila.listPot, 'COCTG');
      expect(fila.listPod, 'INMUN');
      expect(fila.pod, 'COCTG');
      expect(fila.group, (type: '40HC', pod: 'COCTG', line: 'LGH'));
    });

    test('sin POT, el puerto de la fila es el POD, como hasta la 1.0.1', () {
      final fila = t147Listado(conPot: false).byOrder(1)!;
      expect(fila.listPot, isNull);
      expect(fila.listPod, 'INMUN');
      expect(fila.pod, 'INMUN');
    });

    test('ningún puerto pendiente: los del POT salen por identidad, con '
        'respaldo', () {
      final propuestas = _proponer(t147Listado(), t147Plan());
      expect(_pendientes(propuestas), isEmpty);
      final puertos = [
        for (final p in propuestas)
          if (p.kind == EquivalenceKind.port)
            '${p.listCode}→${p.planCode} ${p.origin.name} ${p.evidence}'
      ];
      expect(puertos, [
        'COCTG→COCTG inferred 2',
        'COTRB→COTRB inferred 1',
        'JMKIN→JMKIN inferred 1',
      ]);
      // Nada de eso se guarda en el dispositivo: son identidades deducidas.
      expect(
          ExportListCrossChecker.tableOf(propuestas).of(EquivalenceKind.port),
          isEmpty);
    });

    test('el cruce: los llenos sin diferencias y cada vacío en el grupo de '
        'su POT', () {
      final plan = t147Plan();
      final lista = t147Listado();
      final normalizada = lista
          .normalized(ExportListCrossChecker.tableOf(_proponer(lista, plan)));
      final cruce = ExportListCrossChecker.crossCheck(normalizada, plan, 'GTSTC');
      expect(cruce.matches, hasLength(4));
      expect(cruce.matchesWithDifferences, isEmpty);
      expect(cruce.fullsNotInPlan, isEmpty);
      expect(cruce.emptiesWithoutGroup, isEmpty);
      expect({
        for (final g in cruce.groups)
          '${g.type} · ${g.pod} · ${g.line}': (g.empties.length, g.planCells)
      }, {
        '45G1 · COTRB · LNH': (2, 2),
        '22G1 · JMKIN · LNJ': (1, 1),
        '45R1 · JMKIN · LNH': (1, 1),
      });
      expect(cruce.clean, isTrue);
      // Y la carga: el vacío con destino final CNTAO va a la celda de JMKIN.
      final data = LoadingOperation.build(
          operationId: 'op', loading: plan, list: normalizada);
      expect(
          data
              .slots(normalizada.byOrder(7)!)
              .map((s) => s.stowagePosition.toIsoCode()),
          ['0180084']);
    });

    test('sin POT sigue cruzando por el POD: los destinos finales sin '
        'respaldo quedan pendientes, como en la 1.0.1', () {
      final propuestas = _proponer(t147Listado(conPot: false), t147Plan());
      expect(_pendientes(propuestas), ['port:CNTAO']);
      expect(_de(propuestas, EquivalenceKind.port, 'INMUN').planCode, 'COCTG');
      expect(_de(propuestas, EquivalenceKind.port, 'ITLIV').planCode, 'COTRB');
    });

    test('con POT igual al POD nada cambia (el caso A08)', () {
      final hoja = t147Hoja();
      // La misma hoja con el POD copiado del POT, y sin la columna POT.
      final iguales = [
        for (final fila in hoja)
          fila.length > 4 && fila[0] is int ? ([...fila]..[4] = fila[3]) : fila
      ];
      final sinPot = [
        for (final fila in iguales)
          fila.length > 4 && fila[0] is int ? ([...fila]..[3] = null) : fila
      ];
      const parser = ExportListParserService();
      final plan = t147Plan();
      Map<String, Object?> guardado(List<List<Object?>> h) {
        final lista = parser.parseGrid(h, fileName: 'a.xlsx');
        final json = lista
            .normalized(ExportListCrossChecker.tableOf(_proponer(lista, plan)))
            .toJson();
        for (final fila in json['rows'] as List) {
          (fila as Map)
            ..remove('pot')
            ..remove('listPot');
        }
        return json;
      }

      expect(guardado(iguales), guardado(sinPot));
    });

    group('la forma del listado guardado no cambia', () {
      final texto = File(_guardadoPorLa101).readAsStringSync();

      test('una fuente guardada por la 1.0.1 se abre igual y se vuelve a '
          'guardar byte por byte', () {
        final lista =
            ExportList.fromJson(jsonDecode(texto) as Map<String, dynamic>);
        expect(lista.rows, hasLength(8));
        // El grupo de cada vacío es el que guardó la 1.0.1, sin recalcular.
        expect(lista.byOrder(7)!.group,
            (type: '45R1', pod: 'JMKIN', line: 'LNH'));
        expect(lista.byOrder(7)!.listPod, 'CNTAO');
        expect(lista.byOrder(7)!.listPot, 'JMKIN');
        expect(lista.byOrder(1)!.pod, 'COCTG');
        expect(jsonEncode(lista.toJson()), texto);
        final data = LoadingOperation.build(
            operationId: 'op', loading: t147Plan(), list: lista);
        expect(data.progress.total, 8);
        expect(data.progress.unmatched, 0);
      });

      test('lo que guarda la 1.0.2 tiene las mismas claves, y en `pod` el '
          'puerto con que la 1.0.1 arma los grupos', () {
        final vieja = jsonDecode(texto) as Map<String, dynamic>;
        final plan = t147Plan();
        final lista = t147Listado();
        final nueva = lista
            .normalized(ExportListCrossChecker.tableOf(_proponer(lista, plan)))
            .toJson();
        expect(nueva.keys.toSet(), vieja.keys.toSet());
        expect(nueva['format'], vieja['format']);
        expect(nueva['schema'], vieja['schema']);
        final filasViejas = (vieja['rows'] as List).cast<Map<String, dynamic>>();
        final filasNuevas = (nueva['rows'] as List).cast<Map<String, dynamic>>();
        for (var i = 0; i < filasViejas.length; i++) {
          final a = filasViejas[i];
          final b = filasNuevas[i];
          // Ninguna clave que la 1.0.1 no sepa leer (las de su `fromJson`);
          // `agency` aparece ahora donde antes faltaba, porque el separador
          // «COD.» ya se entiende (R6), y la 1.0.1 la lee.
          expect(b.keys.toSet().difference(_clavesDeLa101), isEmpty,
              reason: 'OR ${a['order']}');
          expect(b.keys.toSet().difference(a.keys.toSet()),
              anyOf(isEmpty, {'agency'}));
          for (final clave in a.keys) {
            expect(b[clave].runtimeType, a[clave].runtimeType,
                reason: 'OR ${a['order']}, $clave');
          }
          // La 1.0.1 lee el grupo de `type`, `pod` y `line`: en la fuente
          // del piloto eran los elegidos a mano; en la 1.0.2 salen del POT.
          expect([b['type'], b['pod'], b['line']],
              [a['type'], a['pod'], a['line']],
              reason: 'OR ${a['order']}');
          expect([b['listPot'], b['listPod']], [a['listPot'], a['listPod']]);
        }
        // Y la lee de vuelta cualquiera de las dos, sin perder nada.
        expect(ExportList.fromJson(nueva).toJson(), nueva);
      });
    });

    testWidgets('la pantalla enseña el POT y el POD cuando son distintos',
        (tester) async {
      await _abrirLaPagina(tester, t147Listado());
      expect(find.text('Todas las filas se entendieron.'), findsOneWidget);
      expect(
          find.text('3 filas traen POT y POD distintos: el cruce con el plan '
              'usa el POT, donde el contenedor baja del buque.'),
          findsOneWidget);
      expect(find.textContaining('Falta elegir'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('export-list-rows')));
      await tester.pumpAndSettle();
      Finder enLaFila(int orden, String texto) => find.descendant(
          of: find.byKey(ValueKey('export-row-$orden')),
          matching: find.textContaining(texto));
      expect(enLaFila(1, '45G1 · COCTG · LNH'), findsOneWidget);
      expect(enLaFila(1, 'POT COCTG · POD INMUN'), findsOneWidget);
      expect(enLaFila(7, 'POT JMKIN · POD CNTAO'), findsOneWidget);
      // Iguales: no hay nada que enseñar.
      expect(enLaFila(2, 'POT '), findsNothing);
      expect(enLaFila(4, 'POD '), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('R5 · la identidad se propone', () {
    // Sin POT, y con vacíos cuyo puerto y tipo ya vienen con el código del
    // plan pero sin ningún contenedor que lo respalde.
    ExportList lista() => const ExportListParserService().parseGrid(_hojaSinPot([
          _vacio(1, 11, '45G1', 'COTRB', 'LNH'),
          _vacio(2, 12, '45G1', 'COTRB', 'LNH'),
          _vacio(3, 13, '45R1', 'CNTAO', 'LNH'),
          _vacio(4, 14, '40XX', 'JMKIN', 'LNJ'),
        ]));

    test('un código sin respaldo que el plan carga con ese mismo código es '
        'una identidad propuesta, no una pendiente', () {
      final propuestas = _proponer(lista(), t147Plan());
      for (final (kind, codigo) in [
        (EquivalenceKind.port, 'COTRB'),
        (EquivalenceKind.port, 'JMKIN'),
        (EquivalenceKind.type, '45G1'),
        (EquivalenceKind.type, '45R1'),
        (EquivalenceKind.line, 'LNH'),
        (EquivalenceKind.line, 'LNJ'),
      ]) {
        final p = _de(propuestas, kind, codigo);
        expect(p.needsUser, isFalse, reason: codigo);
        expect(p.planCode, codigo);
        expect(p.origin.name, 'samePlanCode', reason: codigo);
        expect(p.evidence, 0);
      }
      // Lo que el plan no carga con ese código sigue pendiente, y entre sus
      // sugerencias no va lo que ya explica una identidad.
      expect(_pendientes(propuestas), ['type:40XX', 'port:CNTAO']);
      expect(_de(propuestas, EquivalenceKind.port, 'CNTAO').candidates,
          ['COCTG']);
      expect(_de(propuestas, EquivalenceKind.type, '40XX').candidates,
          ['22G1']);
    });

    test('una identidad propuesta no se guarda en el dispositivo', () {
      final propuestas = _proponer(lista(), t147Plan());
      final tabla = ExportListCrossChecker.tableOf(propuestas);
      expect(tabla.isEmpty, isTrue);
      // Si la persona la corrige, sí: es una elección.
      final corregida = [
        for (final p in propuestas)
          p.kind == EquivalenceKind.port && p.listCode == 'COTRB'
              ? p.choose('COCTG')
              : p
      ];
      expect(
          ExportListCrossChecker.tableOf(corregida).of(EquivalenceKind.port),
          {'COTRB': 'COCTG'});
    });

    test('con respaldo manda el respaldo: un código que el plan carga, pero '
        'cuyos contenedores dicen otra cosa, no es identidad', () {
      // El lleno 1 dice COTRB en el listado y el plan lo descarga en COCTG.
      final conRespaldo = const ExportListParserService().parseGrid(_hojaSinPot([
        [1, t147Matricula(1), '40HC', 'COTRB', 3800, 20000.4, 'X', null,
          'GENERAL CARGO', 'LGH'],
        _vacio(2, 12, '45G1', 'COTRB', 'LNH'),
      ]));
      final p = _de(_proponer(conRespaldo, t147Plan()), EquivalenceKind.port,
          'COTRB');
      expect(p.planCode, 'COCTG');
      expect(p.origin.name, 'inferred');
    });

    testWidgets('la pantalla dice de dónde sale', (tester) async {
      await _abrirLaPagina(tester, lista());
      Finder enLaFicha(String clave, String texto) => find.descendant(
          of: find.byKey(ValueKey(clave)), matching: find.textContaining(texto));
      expect(enLaFicha('equivalence-port-COTRB', 'Puerto COTRB → COTRB'),
          findsOneWidget);
      expect(
          enLaFicha(
              'equivalence-port-COTRB',
              'Propuesta: el plan carga COTRB en esta escala con ese mismo '
                  'código. Ningún contenedor de COTRB está en el listado y en '
                  'el plan (2 filas).'),
          findsOneWidget);
      expect(enLaFicha('equivalence-port-CNTAO', 'Puerto CNTAO → ?'),
          findsOneWidget);
      expect(
          find.text('Falta elegir 2 equivalencias antes de importar. Elige '
              'una para cada código pendiente.'),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
