// T-122 · La 3.1.1 con los hallazgos del piloto (SPRINT-4.md 10.49 a 10.52,
// 10.55 y 10.56). Cada prueba reproduce un hallazgo con datos sintéticos y
// estaba en rojo antes del arreglo (docs/T122-RESULTADOS.md). Solo usa la API
// que ya existía en la 3.1.0; lo nuevo del dominio se prueba en
// t122_dominio_test.dart.
import 'package:baystream/features/vessel/data/repositories/local_only_operation_sync.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/data/services/export_list_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/session_repository.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';
import 'package:baystream/features/vessel/domain/services/operation_progress.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_geometry_page.dart';
import 'package:baystream/features/vessel/presentation/providers/discharge_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_operation_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_plan_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/bay_plan_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/local_profile_test_support.dart';
import 'support/t74_movement_log_support.dart';
import 'support/t75_memory_log.dart';
import 'support/t76_fixture.dart';
import 'support/t91_toolbar_support.dart';
import 't81_office_changes_test.dart' as f;

/// H1 · Un plano de llegada que sale de PAMIT rumbo a CRPMN con dos cajas que
/// bajan en GTSTC: el puerto donde se descarga no es ni el de salida ni el
/// siguiente del archivo.
const _h1 = "UNH+1+BAPLIE:D:95B:UN:SMDG20'"
    "TDT+20+V122+++NV2:172:20+++9000122:146:11:BUQUE PRUEBA'"
    "LOC+5+PAMIT:139:6'LOC+61+CRPMN:139:6'"
    "LOC+147+0020182::5'LOC+9+PAMIT:139:6'LOC+11+GTSTC:139:6'"
    "EQD+CN+TSTU0001221+42G1+++5'"
    "LOC+147+0020184::5'LOC+9+PAMIT:139:6'LOC+11+GTSTC:139:6'"
    "EQD+CN+TSTU0001222+42G1+++5'"
    "LOC+147+0020186::5'LOC+9+PAMIT:139:6'LOC+11+CRPMN:139:6'"
    "EQD+CN+TSTU0001223+42G1+++5'";

/// H5 · Un 40 pies en la bahía 22 y un 20 pies en la 21, que la 22 cubre.
final _h5Loading = t76Voyage([
  t76Unit('LONG0000040', '0220282').copyWith(isoSizeType: '45G1'),
  t76Unit('SHORT000020', '0210482'),
]);

/// H6 · El vacío OR 12 del listado, asignado a la reserva libre de la
/// 003-08-82 (la de la 04 la ocupa todavía un contenedor de llegada).
final _h6Assign = t76Movement(
    MovementDraft.assignEmpty('op', '0030882', 'EMPTY0000012', 2185,
        order: 12),
    1);

class _Viaje extends VoyageNotifier {
  _Viaje(this.voyage);
  final VesselVoyage voyage;
  @override
  AsyncValue<VesselVoyage?> build() => AsyncData(voyage);
}

/// El plano por bahía en Carga, con una bitácora en memoria, como en T-105.
Future<(T75MemoryLog, ProviderContainer)> _plano(WidgetTester tester,
    {required VesselVoyage loading,
    ExportList? list,
    Operator? actor = f.dock,
    List<MovementDraft> initial = const []}) async {
  final log = T75MemoryLog();
  for (final draft in initial) {
    await log.append(draft, f.dock.author);
  }
  LoadingOperation derive(List<MovementRecord> records) =>
      LoadingOperation.build(
          operationId: 'op',
          loading: loading,
          list: list,
          movements: records.map((r) => r.movement));
  final scope = ProviderContainer(overrides: [
    movementLogRepositoryProvider.overrideWith((ref) async => log),
    vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
    operatorProvider.overrideWith((ref) => Stream.value(actor)),
    activeOperationProvider.overrideWith((ref) async => f.operation),
    loadingOperationProvider(loading).overrideWith((ref) async* {
      await for (final records in log.watch('op')) {
        yield derive(records);
      }
    }),
    loadingPlanProgressProvider(loading).overrideWith((ref) async* {
      await for (final records in log.watch('op')) {
        yield derive(records).progress;
      }
    }),
  ]);
  addTearDown(scope.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
      container: scope,
      child: MaterialApp(home: Scaffold(body: BayPlanView(voyage: loading)))));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('bay-plan-display-mode')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Carga').last);
  await tester.pumpAndSettle();
  return (log, scope);
}

void main() {
  group('H1 · la escala de un plano de llegada (10.49)', () {
    final voyage = BaplieParserService().parse(_h1);
    test('el puerto de descarga se propone si fue la última escala confirmada',
        () {
      expect(voyage.loadingPortCounts, {'PAMIT': 3});
      expect(voyage.suggestPortOfCall(null), 'PAMIT');
      expect(voyage.suggestPortOfCall('CRPMN'), 'CRPMN');
      expect(voyage.suggestPortOfCall('GTSTC'), 'GTSTC');
      expect(voyage.suggestPortOfCall('USLAX'), 'PAMIT');
      expect(offersDischarge(voyage.copyWith(portOfCall: 'GTSTC')), isTrue);
    });
    for (final history in [null, 'GTSTC']) {
      testWidgets(
          'Parámetros del buque ofrece GTSTC (2) con historial $history',
          (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(MaterialApp(
            home: VesselGeometryPage(
          proposal: VesselProfile.proposeFrom(voyage).geometry,
          voyage: voyage,
          declaredPort: voyage.portOfOrigin,
          loadingPorts: voyage.loadingPortCounts,
          lastConfirmedPortOfCall: history,
        )));
        await tester.scrollUntilVisible(
            find.byKey(const ValueKey('port-source')), 300,
            scrollable: find.byType(Scrollable).first);
        expect(find.byKey(const ValueKey('port-GTSTC')), findsOneWidget);
        expect(find.text('GTSTC (2)'), findsOneWidget);
        expect(find.text('PAMIT (3)'), findsOneWidget);
        expect(
            tester
                .widget<ChoiceChip>(
                    find.byKey(ValueKey('port-${history ?? 'PAMIT'}')))
                .selected,
            isTrue);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('H3 · la fila «AGREGADOS» del listado (10.50)', () {
    const parser = ExportListParserService();
    const header = [
      'OR', 'CONTENEDOR', 'TIPO', 'POD', 'TARA', 'PESO VGM', 'F', 'E',
      'CONTENIDO', 'OPR',
    ];
    List<Object?> fila(int order, String id) =>
        [order, id, '22G1', 'PAMIT', 2230, 8000, 'X', null, 'GENERAL', 'LNX'];
    test('es un encabezado de sección y las filas de abajo se cuentan aparte',
        () {
      final parsed = parser.parseGrid([
        header,
        ['AGENCIA A S.A. CODIGO 100'],
        fila(1, 'TSTU0000014'),
        fila(2, 'TSTU0000020'),
        ['AGREGADOS'],
        fila(3, 'TSTU0000035'),
        ['TOTAL 3 CONTENEDORES'],
      ]);
      expect(parsed.issues.map((i) => i.sheetRow), [7],
          reason: 'solo la fila TOTAL sigue sin entenderse');
      expect(parsed.rows.map((r) => r.order), [1, 2, 3]);
      expect(parsed.agencies, {'AGENCIA A S.A.': 2, 'AGREGADOS': 1});
      expect(parsed.byOrder(2)!.agency, 'AGENCIA A S.A.');
      expect(parsed.byOrder(3)!.agency, 'AGREGADOS');
    });
    test('también en minúsculas, con espacios o en singular', () {
      for (final text in ['  Agregados ', 'agregados', 'AGREGADO']) {
        final parsed =
            parser.parseGrid([header, [text], fila(1, 'TSTU0000014')]);
        expect(parsed.issues, isEmpty, reason: text);
        expect(parsed.rows.single.agency, text.trim().toUpperCase(),
            reason: text);
      }
    });
  });

  group('H4 · cargar un lleno del plan sin fila en el listado (10.51)', () {
    test('se busca por sus últimos dígitos y se registra por su número, sin OR',
        () {
      final data = LoadingOperation.build(operationId: 'op', loading: t76Loading);
      expect(data.list, isNull);
      final found = data.search('234');
      expect(found.map((r) => r.containerId), ['FULL0001234']);
      final draft = data.draft(found.single, '0030282');
      expect(draft.type, MovementType.loadFull);
      expect(draft.target, 'C:FULL0001234');
      expect(draft.payload['order'], isNull);
      final after = LoadingOperation.build(
          operationId: 'op',
          loading: t76Loading,
          movements: [t76Movement(draft, 1)]);
      expect(after.state['C:FULL0001234']!.state, ItemState.moved);
      expect(after.state.conflicts, isEmpty);
      expect(after.search('234').single.containerId, 'FULL0001234');
      // Los vacíos siguen necesitando el listado (10.51).
      expect(data.search('', empties: true), isEmpty);
    });
    test('con un listado al que le falta la fila, el lleno sin OR va después',
        () {
      final partial = LoadingOperation.build(
          operationId: 'op',
          loading: t76Loading,
          list: ExportList(
              fileName: 'parcial.xlsx', rows: [t76Row(2, 'FULL0005678')]));
      expect(partial.search('').map((r) => r.containerId),
          ['FULL0005678', 'FULL0001234']);
      expect(partial.search('678').single.order, 2);
      expect(partial.search('234').single.containerId, 'FULL0001234');
    });
    testWidgets(
        'en el muelle, tocar la celda de un lleno sin listado abre «Confirmar carga» y registra',
        (tester) async {
      final (log, _) = await _plano(tester, loading: t76Loading);
      expect(
          tester
              .widget<TextButton>(find.byKey(const ValueKey('load-search')))
              .onPressed,
          isNotNull,
          reason: '«OR / últimos dígitos» no se apaga sin listado');
      await tester.ensureVisible(find.byKey(const ValueKey('plan-cell-0030282')));
      await tester.tap(find.byKey(const ValueKey('plan-cell-0030282')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('loading-confirm')), findsOneWidget);
      expect(find.text('Este contenedor no tiene OR.'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('loading-confirm')));
      await tester.pumpAndSettle();
      final movement = log.of('op').single.movement;
      expect(movement.type, MovementType.loadFull);
      expect(movement.target, 'C:FULL0001234');
      expect(movement.payload['order'], isNull);
      expect(tester.takeException(), isNull);
    });
    testWidgets('la oficina sigue sin registrar cargas: ve el detalle',
        (tester) async {
      final (log, _) = await _plano(tester, loading: t76Loading, actor: f.office);
      await tester.ensureVisible(find.byKey(const ValueKey('plan-cell-0030282')));
      await tester.tap(find.byKey(const ValueKey('plan-cell-0030282')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('loading-confirm')), findsNothing);
      expect(find.text('Pendiente'), findsOneWidget);
      expect(log.of('op'), isEmpty);
      expect(tester.takeException(), isNull);
    });
  });

  group('H5 · la par es la bahía de referencia (10.52, 10.56)', () {
    test('la 21 se cuenta con la 22 y el grupo se rotula 22', () {
      final data = LoadingOperation.build(operationId: 'op', loading: _h5Loading);
      expect(data.displayBay(22), 22);
      expect(data.displayBay(21), 22);
      expect(data.displayBay(23), 22);
      expect(data.progress.bays.keys, [22]);
      expect(data.progress.forBay(21)!.label, '22');
      expect(data.progress.forBay(22)!.label, '22');
      final loaded = LoadingOperation.build(
          operationId: 'op',
          loading: _h5Loading,
          movements: [
            t76Movement(MovementDraft.loadFull('op', 'LONG0000040', '0220282'), 1)
          ]);
      final progress = OperationProgress.build(loaded);
      expect(progress.bays.map((b) => b.bay), [22]);
      expect(progress.bays.single.label, '22');
      expect((progress.bays.single.fullLoaded, progress.bays.single.fullPending),
          (1, 1));
      expect(loaded.state['C:LONG0000040']!.position, '0220282',
          reason: 'los movimientos guardados no cambian');
    });
    test('sin la par en el plano, la impar queda sola', () {
      final odd = LoadingOperation.build(
          operationId: 'op',
          loading: t76Voyage(
              [t76Unit('ODD00000021', '0210482'), t76Unit('ODD00000023', '0230482')]));
      expect(odd.displayBay(21), 21);
      expect(odd.displayBay(23), 23);
      expect(OperationProgress.build(odd).bays.map((b) => b.label), ['21', '23']);
    });
    testWidgets('la silueta sube el avance bajo la 22, no bajo la 21',
        (tester) async {
      await _plano(tester,
          loading: _h5Loading,
          initial: [MovementDraft.loadFull('op', 'LONG0000040', '0220282')]);
      final par =
          tester.getSemantics(find.byKey(const ValueKey('silueta-bahia-22')));
      expect(par.label, contains('avance 50'));
      final impar =
          tester.getSemantics(find.byKey(const ValueKey('silueta-bahia-21')));
      expect(impar.label, isNot(contains('avance')));
      expect(tester.takeException(), isNull);
    });
  });

  group('H6 · el vacío asignado a una reserva (10.56)', () {
    test('«OR / últimos dígitos» lo encuentra por su OR y por sus dígitos', () {
      final data = t76Operation([_h6Assign]);
      expect(data.state['R:0030882']!.assignedContainer, 'EMPTY0000012');
      expect(data.search('12').map((r) => r.order), contains(12));
      expect(data.search('OR 12').map((r) => r.order), [12]);
      expect(data.search('0012').map((r) => r.order), [12]);
      // Sin asignar sigue siendo un vacío del listado: no sale entre los llenos.
      expect(t76Operation().search('12').map((r) => r.order),
          isNot(contains(12)));
    });
    test('la Lista del viaje lo trae con su celda', () async {
      final data = t76Operation([_h6Assign]);
      final scope = ProviderContainer(overrides: [
        voyageNotifierProvider.overrideWith(() => _Viaje(t76Loading)),
        localVesselRepositoryProvider
            .overrideWith((ref) async => T91MemorySettings()),
        vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
        movementLogRepositoryProvider.overrideWith((ref) async => T74MemoryLog()),
        sessionRepositoryProvider
            .overrideWith((ref) async => const LocalSessionRepository()),
        loadingOperationProvider(t76Loading)
            .overrideWith((ref) => Stream.value(data)),
        loadingPlanProgressProvider(t76Loading)
            .overrideWith((ref) => Stream.value(data.progress)),
      ]);
      addTearDown(scope.dispose);
      final subscription =
          scope.listen(filteredContainersProvider, (_, __) {});
      await scope.read(loadingOperationProvider(t76Loading).future);
      await pumpEventQueue();
      final listed = subscription.read();
      expect(listed.map((c) => c.containerId),
          ['FULL0001234', 'FULL0005678', 'EMPTY0000012']);
      final empty = listed.last;
      expect(empty.status, ContainerStatus.empty);
      expect(empty.stowagePosition?.toIsoCode(), '0030882');
      expect(empty.isoSizeType, '22G1');
    });
  });
}
