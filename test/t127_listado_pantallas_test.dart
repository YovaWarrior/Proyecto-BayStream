import 'dart:async';
import 'dart:convert';

import 'package:baystream/core/design/design.dart';
import 'package:baystream/core/errors/failures.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/local_vessel_repository.dart';
import 'package:baystream/features/vessel/domain/repositories/movement_log_repository.dart';
import 'package:baystream/features/vessel/domain/repositories/operation_sync_repository.dart';
import 'package:baystream/features/vessel/presentation/pages/export_list_import_page.dart';
import 'package:baystream/features/vessel/presentation/providers/export_list_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/aviso_del_listado.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t73_export_list_support.dart';

/// T-127 (10.78) · Las pantallas: la oficina importa el listado en una
/// operación publicada (sube la revisión; si la nube no acepta, nada local
/// cambia; el cruce avisa con números) y el muelle avisa «Listado actualizado
/// por la oficina: n filas» y vuelve a derivar el plano.
class _Local implements LocalVesselRepository {
  CodeEquivalences table = CodeEquivalences.empty;

  @override
  Future<Either<Failure, CodeEquivalences>> getCodeEquivalences() async => Right(table);

  @override
  Future<Either<Failure, void>> saveCodeEquivalences(CodeEquivalences equivalences) async {
    table = equivalences;
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Log implements MovementLogRepository {
  final operations = <Operation>[];
  final stored = <MovementRecord>[];

  @override
  Future<Either<Failure, List<Operation>>> getOperations() async => Right(List.of(operations));

  @override
  Future<Either<Failure, void>> saveOperation(Operation operation) async {
    operations
      ..removeWhere((o) => o.id == operation.id)
      ..add(operation);
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<MovementRecord>>> records(String operationId) async =>
      Right(stored.where((r) => r.movement.operationId == operationId).toList());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// La nube de la oficina: anota cada `replaceSource` y, si no se le pide
/// fallar, deja la fuente con la revisión siguiente en la operación local,
/// como hace Firestore.
class _Sync implements OperationSyncRepository {
  _Sync(this.log, {this.failure});

  final _Log log;
  final Failure? failure;
  final calls = <OperationSource>[];

  @override
  Future<Either<Failure, Operation>> replaceSource(
      Operation operation, OperationSource source) async {
    calls.add(source);
    final failure = this.failure;
    if (failure != null) return Left(failure);
    final updated = operation.copyWith(sources: [
      ...operation.sources.where((s) => s.kind != source.kind),
      source.withRevision(operation.exportListRevision + 1),
    ]);
    await log.saveOperation(updated);
    return Right(updated);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PlanNotifier extends VoyageNotifier {
  final VesselVoyage plan;
  _PlanNotifier(this.plan);

  @override
  AsyncValue<VesselVoyage?> build() => AsyncValue.data(plan);
}

void main() {
  const confirmKey = ValueKey('export-list-confirm');
  const operationId = 'op-publicada';
  final plan = t73Plan();

  // El listado que la operación tenía: solo el vacío que el muelle asignó,
  // en la línea LNA; el listado nuevo (el fixture de T-73) lo trae en LNX.
  String previousList() => jsonEncode(ExportList(fileName: 'anterior.xlsx', rows: [
        ExportListRow(
          sheetRow: 2,
          order: 4,
          containerId: 'TSTU0000040',
          status: ContainerStatus.empty,
          listType: '22G1',
          listPod: 'PAMIT',
          listLine: 'LNA',
          tareKg: 2185,
        ),
      ]).toJson());

  Operation publishedOperation() => Operation(
        id: operationId,
        vesselName: plan.vessel.name,
        voyageNumber: plan.voyageNumber,
        portOfCall: 'GTSTC',
        createdAt: DateTime.utc(2026, 10, 25, 22),
        published: true,
        sources: [
          const OperationSource(
              kind: OperationSourceKind.loadingBaplie,
              fileName: 'plan.edi',
              content: t73PlanEdi),
          OperationSource(
              kind: OperationSourceKind.exportList,
              fileName: 'anterior.xlsx',
              content: previousList()),
        ],
      );

  // Lo ya operado: un lleno del plan cargado por su número (H4), que el
  // listado nuevo no trae, y el vacío asignado a su reserva.
  var sequence = 0;
  MovementRecord confirmed(MovementType type, String target, Map<String, Object?> payload) {
    sequence++;
    return MovementRecord(
        Movement(
          id: 'mov-$sequence',
          operationId: operationId,
          type: type,
          target: target,
          payload: payload,
          author: const MovementAuthor(
              uid: 'uid-muelle', name: 'Tarjador 1', role: OperatorRole.dock),
          deviceId: 'honor',
          sequence: sequence,
          createdAt: DateTime.utc(2026, 10, 26, 1, sequence),
        ),
        SendState.confirmed);
  }

  List<MovementRecord> operated() => [
        confirmed(MovementType.loadFull, 'C:TSTU0000090', {'position': '0140184'}),
        confirmed(MovementType.assignEmpty, 'R:0070402',
            {'container': 'TSTU0000040', 'tareKg': 2185, 'order': 4}),
      ];

  Future<ProviderContainer> open(WidgetTester tester,
      {required _Local local, required _Log log, required _Sync sync}) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(overrides: [
      voyageNotifierProvider.overrideWith(() => _PlanNotifier(plan)),
      localVesselRepositoryProvider.overrideWith((ref) async => local),
      movementLogRepositoryProvider.overrideWith((ref) async => log),
      operationSyncProvider.overrideWith((ref) async => sync),
    ], child: MaterialApp(
        theme: BayStreamTema.claro(muelle: false),
        home: const ExportListImportPage())));
    await tester.pump();
    return ProviderScope.containerOf(tester.element(find.byType(ExportListImportPage)));
  }

  /// Lee el fixture de T-73 y resuelve la única equivalencia pendiente.
  Future<void> readList(WidgetTester tester, ProviderContainer container) async {
    await container
        .read(exportListImportProvider.notifier)
        .loadBytes(t73ListBytes(), fileName: 'sintetico.xlsx');
    await tester.pump();
    container
        .read(exportListImportProvider.notifier)
        .choose(EquivalenceKind.type, '40RF', '45R1');
    await tester.pump();
  }

  group('la oficina importa el listado en una operación publicada', () {
    testWidgets('el cruce avisa con números y confirmar sube la revisión', (tester) async {
      final local = _Local();
      final log = _Log()
        ..operations.add(publishedOperation())
        ..stored.addAll(operated());
      final sync = _Sync(log);
      final container = await open(tester, local: local, log: log, sync: sync);
      await readList(tester, container);

      final state = container.read(exportListImportProvider);
      expect(state.impact, isNotNull);
      expect(state.impact!.loadedNotListed, ['TSTU0000090']);
      expect(state.impact!.emptiesRegrouped, ['TSTU0000040']);
      await tester.scrollUntilVisible(
          find.byKey(const ValueKey('revision-loaded-missing')), 300,
          scrollable: find.byType(Scrollable).first);
      expect(find.text('1 contenedor ya cargado no está en el listado nuevo'), findsOneWidget);
      expect(find.text('1 vacío asignado cambia de grupo'), findsOneWidget);

      await tester.tap(find.byKey(confirmKey));
      await tester.pumpAndSettle();
      expect(sync.calls.map((s) => s.kind), [OperationSourceKind.exportList]);
      final saved = log.operations.single.source(OperationSourceKind.exportList)!;
      expect(saved.revision, 1);
      expect(saved.fileName, 'sintetico.xlsx');
      expect(ExportList.fromJson(jsonDecode(saved.content) as Map<String, dynamic>).rows,
          hasLength(7));
      expect(log.operations.single.source(OperationSourceKind.loadingBaplie)!.content,
          t73PlanEdi, reason: 'el plan de carga no cambia');
      expect(log.stored, hasLength(2), reason: 'los movimientos no se tocan');
      expect(local.table.lookup(EquivalenceKind.type, '40RF'), '45R1');
      const mensaje = 'Listado guardado en la operación publicada de GTSTC: 7 filas, '
          'revisión 1. El muelle lo recibe solo.';
      expect(container.read(exportListImportProvider).message, mensaje);
      // La lista sigue desplazada hasta donde estaba la tarjeta del cruce: el
      // aviso de arriba se construye al volver a él.
      await tester.scrollUntilVisible(find.text(mensaje), -300,
          scrollable: find.byType(Scrollable).first);
      expect(find.text(mensaje), findsOneWidget);
      expect(find.byKey(confirmKey), findsNothing, reason: 'ya no hay listado por confirmar');
    });

    testWidgets('si la nube no acepta la revisión, la pantalla lo dice y nada local cambia',
        (tester) async {
      final local = _Local();
      final log = _Log()
        ..operations.add(publishedOperation())
        ..stored.addAll(operated());
      final sync = _Sync(log,
          failure: const FirestoreFailure(
              code: 'permission-denied',
              message: 'La nube no aceptó el listado: la operación está cerrada, la '
                  'cuenta no es de oficina o alguien acaba de cambiar el listado. '
                  'Vuelve a abrir «Listado de la agencia» e inténtalo de nuevo.'));
      final container = await open(tester, local: local, log: log, sync: sync);
      await readList(tester, container);

      await tester.tap(find.byKey(confirmKey));
      await tester.pumpAndSettle();
      expect(sync.calls, hasLength(1));
      final kept = log.operations.single.source(OperationSourceKind.exportList)!;
      expect(kept.content, previousList());
      expect(kept.revision, isNull);
      expect(local.table.lookup(EquivalenceKind.type, '40RF'), isNull,
          reason: 'las equivalencias se guardan después de que la nube acepte');
      expect(find.textContaining('La nube no aceptó el listado', skipOffstage: false),
          findsWidgets);
      expect(find.byKey(confirmKey), findsOneWidget,
          reason: 'el listado leído sigue en pantalla para volver a intentarlo');
    });

    testWidgets('sin movimientos en la operación, el cruce no avisa de lo ya operado',
        (tester) async {
      final local = _Local();
      final log = _Log()..operations.add(publishedOperation());
      final sync = _Sync(log);
      final container = await open(tester, local: local, log: log, sync: sync);
      await readList(tester, container);
      expect(container.read(exportListImportProvider).impact, isNull);
      expect(find.byKey(const ValueKey('revision-impact'), skipOffstage: false), findsNothing);
    });
  });

  group('el muelle recibe el listado', () {
    test('el texto del aviso cuenta las filas', () {
      expect(textoDelListadoActualizado(7), 'Listado actualizado por la oficina: 7 filas.');
      expect(textoDelListadoActualizado(1), 'Listado actualizado por la oficina: 1 fila.');
    });

    testWidgets('avisa «Listado actualizado por la oficina: n filas» una vez por revisión y vuelve a derivar el plano',
        (tester) async {
      final statuses = StreamController<SyncStatus>.broadcast();
      addTearDown(statuses.close);
      await tester.pumpWidget(ProviderScope(
          overrides: [syncStatusProvider.overrideWith((ref) => statuses.stream)],
          child: MaterialApp(
              theme: BayStreamTema.claro(muelle: true),
              home: const Scaffold(body: AvisoDelListado()))));
      await tester.pump();
      final container =
          ProviderScope.containerOf(tester.element(find.byType(AvisoDelListado)));
      const aviso = ValueKey('aviso-listado-actualizado');

      statuses.add(const SyncStatus(SyncState.upToDate));
      await tester.pump();
      await tester.pump();
      expect(find.byKey(aviso), findsNothing);
      expect(container.read(operationSourcesRevisionProvider), 0);

      statuses.add(const SyncStatus(SyncState.upToDate,
          listArrival: ListArrival(revision: 2, rows: 7)));
      await tester.pump();
      await tester.pump();
      expect(find.text('Listado actualizado por la oficina: 7 filas.'), findsOneWidget);
      expect(container.read(operationSourcesRevisionProvider), 1,
          reason: 'el plano se vuelve a derivar con el listado nuevo');

      // El aviso termina de entrar, dura 6 s y se va; la misma llegada en el
      // siguiente estado no lo repite ni vuelve a derivar nada.
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 7));
      await tester.pumpAndSettle();
      expect(find.byKey(aviso), findsNothing);
      statuses.add(const SyncStatus(SyncState.sending,
          pending: 1, listArrival: ListArrival(revision: 2, rows: 7)));
      await tester.pump();
      await tester.pump();
      expect(find.byKey(aviso), findsNothing);
      expect(container.read(operationSourcesRevisionProvider), 1);

      // Otra revisión, otro aviso.
      statuses.add(const SyncStatus(SyncState.upToDate,
          listArrival: ListArrival(revision: 3, rows: 1)));
      await tester.pump();
      await tester.pump();
      expect(find.text('Listado actualizado por la oficina: 1 fila.'), findsOneWidget);
      expect(container.read(operationSourcesRevisionProvider), 2);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 7));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
