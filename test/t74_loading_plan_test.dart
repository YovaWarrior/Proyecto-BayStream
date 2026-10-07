import 'dart:async';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/data/services/export_list_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/loading_plan_progress.dart';
import 'package:baystream/features/vessel/domain/services/operation_sources.dart';
import 'package:baystream/features/vessel/domain/services/operation_state_deriver.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_plan_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/bay_plan_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/local_profile_test_support.dart';
import 'support/t73_export_list_support.dart';
import 'support/t74_movement_log_support.dart';

ExportList normalizedList() => const ExportListParserService()
    .parseXlsx(t73ListBytes(), fileName: 'sintetico.xlsx')
    .normalized(CodeEquivalences({
      EquivalenceKind.type: {
        '40HC': '45G1',
        '20ST': '22G1',
        '40RF': '45R1',
        '40ST': '42G1'
      },
      EquivalenceKind.port: {'COMNG': 'COSPC'},
      EquivalenceKind.line: {'LNB': 'LINB'},
    }));

VesselVoyage plan() {
  final voyage = t73Plan();
  return voyage.withGeometry(VesselProfile.proposeFrom(voyage).geometry,
      portOfCall: 'GTSTC');
}

LoadingPlanProgress progress(VesselVoyage voyage,
        {ExportList? list, List<Movement> events = const []}) =>
    LoadingPlanProgress.build(
        voyage,
        const OperationStateDeriver().derive(
            OperationPlan.build(loading: voyage, portOfCall: 'GTSTC'), events),
        list: list);

Movement movement(MovementDraft draft, int sequence) => Movement(
    id: 'evento-$sequence',
    operationId: 'op',
    type: draft.type,
    target: draft.target,
    payload: draft.payload,
    author: const MovementAuthor(name: 'Prueba', role: OperatorRole.dock),
    deviceId: 'prueba',
    sequence: sequence,
    createdAt: DateTime.utc(2026, 1, 1).add(Duration(minutes: sequence)));

void main() {
  test('T-74 tipo de fuente: cargas, descargas, ambas y ninguna', () {
    final loading = plan();
    expect(OperationSources.baplieKind(loading, 'GTSTC'),
        OperationSourceKind.loadingBaplie);
    final arrival = BaplieParserService().parse(t73PlanEdi
        .replaceAll('LOC+9+GTSTC', 'LOC+9+HNPCR')
        .replaceAll('LOC+11+PAMIT', 'LOC+11+GTSTC'));
    expect(OperationSources.baplieKind(arrival, 'GTSTC'),
        OperationSourceKind.arrivalBaplie);
    final mixed = BaplieParserService()
        .parse(t73PlanEdi.replaceFirst('LOC+11+COSPC', 'LOC+11+GTSTC'));
    expect(OperationSources.baplieKind(mixed, 'GTSTC'), isNull);
    expect(OperationSources.baplieKind(loading, 'ZZZZZ'), isNull);
  });

  test(
      'T-74 agregar y reemplazar una fuente conserva identidad, fecha y las otras',
      () async {
    final log = T74MemoryLog();
    final voyage = plan();
    final original = await OperationSources.save(
        log,
        voyage,
        'GTSTC',
        const OperationSource(
            kind: OperationSourceKind.exportList,
            fileName: 'lista',
            content: 'lista'),
        clock: () => DateTime.utc(2026, 1, 1));
    await OperationSources.save(
        log,
        voyage,
        'GTSTC',
        const OperationSource(
            kind: OperationSourceKind.arrivalBaplie,
            fileName: 'llegada',
            content: 'texto llegada'));
    await OperationSources.save(
        log,
        voyage,
        'GTSTC',
        const OperationSource(
            kind: OperationSourceKind.loadingBaplie,
            fileName: 'carga',
            content: 'texto carga'));
    final updated = await OperationSources.save(
        log,
        voyage,
        'GTSTC',
        const OperationSource(
            kind: OperationSourceKind.loadingBaplie,
            fileName: 'nueva',
            content: 'texto nuevo'));
    expect(log.operations, hasLength(1));
    expect(updated.id, original.id);
    expect(updated.createdAt, original.createdAt);
    expect(updated.sources, hasLength(3));
    expect(updated.source(OperationSourceKind.arrivalBaplie)!.content,
        'texto llegada');
    expect(updated.source(OperationSourceKind.exportList)!.content, 'lista');
    expect(updated.source(OperationSourceKind.loadingBaplie)!.content,
        'texto nuevo');
    await OperationSources.save(
        log,
        voyage,
        'PAMIT',
        const OperationSource(
            kind: OperationSourceKind.loadingBaplie,
            fileName: 'otra',
            content: 'otra escala'));
    expect(log.operations, hasLength(2));
  });

  test('T-74 una fuente ambigua exige elección antes de guardar o publicar',
      () async {
    final store = await testProfileStore();
    final log = T74MemoryLog();
    final scope = ProviderContainer(overrides: [
      vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
      localVesselRepositoryProvider
          .overrideWith((ref) async => store.repository),
      movementLogRepositoryProvider.overrideWith((ref) async => log),
    ]);
    try {
      final notifier = scope.read(voyageNotifierProvider.notifier);
      await notifier.parseBaplieContent(profileTestEdi,
          fileName: 'sintetico.edi');
      final geometry = notifier.currentProfile!.geometry;
      expect(await notifier.confirmGeometry(geometry, portOfCall: 'GTSTC'),
          contains('Elige'));
      expect(notifier.publishedVoyage, isNull);
      expect(log.operations, isEmpty);
      expect((await store.repository.getAllProfiles()).getOrElse(() => []),
          isEmpty);
      expect(
          await notifier.confirmGeometry(geometry,
              portOfCall: 'GTSTC',
              sourceKind: OperationSourceKind.arrivalBaplie),
          isNull);
      expect(
          log.operations.single
              .source(OperationSourceKind.arrivalBaplie)!
              .content,
          profileTestEdi);
    } finally {
      scope.dispose();
      await store.repository.close();
      await store.directory.delete(recursive: true);
    }
  });

  test('T-74 OR, reserva sin OR, sin cruce y pendientes F/E del listado', () {
    final voyage = plan();
    final data = progress(voyage, list: normalizedList());
    expect(data.label('C:TSTU0000014'), 'OR 1');
    expect(data.label('C:TSTU0000061'), 'OR 6');
    expect(data.label('R:0060208'), '45R1\nPAMIT\nLNX');
    expect(data.label('C:TSTU0000090'), '—');
    expect(data.unmatched, 1);
    expect((data.total, data.full, data.empty), (7, 4, 3));
    expect(data.forBay(14)!.label, '14');
    // La lista manda incluso cuando el plan declara lleno al vacío numerado.
    final changed = voyage.copyWith(containers: [
      for (final c in voyage.containers)
        c.containerId == 'TSTU0000061'
            ? c.copyWith(status: ContainerStatus.full)
            : c
    ]);
    expect(progress(changed, list: normalizedList()).empty, 3);
    expect(progress(changed).empty, 2);
  });

  test('T-74 mover, cancelar y anular recalculan pendientes desde T-72', () {
    final voyage = plan();
    final list = normalizedList();
    final load =
        movement(MovementDraft.loadFull('op', 'TSTU0000014', '0140282'), 1);
    final cancel =
        movement(MovementDraft.cancelItem('op', 'R:0060208', 'No se carga'), 2);
    final annul = movement(MovementDraft.annul('op', load.id, 'Corrección'), 3);
    final after = progress(voyage, list: list, events: [load, cancel]);
    expect((after.total, after.full, after.empty), (5, 3, 2));
    expect(
        progress(voyage, list: list, events: [load, cancel, annul]).total, 6);
    expect(after.bays.length, progress(voyage, list: list).bays.length);
  });

  for (final withList in [true, false]) {
    testWidgets('T-74 plano a 360 dp, OR y tabla, listado=$withList',
        (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final voyage = plan();
      final data = progress(voyage, list: withList ? normalizedList() : null);
      await tester.pumpWidget(ProviderScope(
          overrides: [
            loadingPlanProgressProvider(voyage)
                .overrideWith((ref) => Stream.value(data)),
          ],
          child:
              MaterialApp(home: Scaffold(body: BayPlanView(voyage: voyage)))));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('bay-plan-display-mode')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Número de orden').last);
      await tester.pumpAndSettle();
      if (withList) {
        expect(
            find.textContaining('1 celdas de carga sin cruce'), findsOneWidget);
        expect(find.text('2'), findsWidgets); // OR 2 en bahía 03.
      } else {
        expect(find.text('Importar listado'), findsOneWidget);
        expect(find.textContaining('todavía no tiene listado'), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Pendientes por bahía'));
      await tester.pumpAndSettle();
      expect(find.textContaining('7 pendientes'), findsOneWidget);
      expect(find.text('Cub. L'), findsOneWidget);
      expect(find.text('Bod. V'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
