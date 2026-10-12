import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/session_repository.dart';
import 'package:baystream/features/vessel/domain/services/change_requests.dart';
import 'package:baystream/features/vessel/presentation/pages/change_requests_page.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_operation_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/domain/repositories/operation_sync_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/t75_memory_log.dart';
import 'support/t76_fixture.dart';

class _Actor extends Notifier<Operator?> {
  @override
  Operator? build() => const Operator(
      uid: 'prueba-dock', name: 'Muelle', role: OperatorRole.dock);
  void change(Operator? actor) => state = actor;
}

class _RejectedApprovalLog extends T75MemoryLog {
  final List<MovementRecord> snapshot;
  _RejectedApprovalLog(this.snapshot);
  @override
  Stream<List<MovementRecord>> watch(String operationId) => Stream.value(snapshot);
}

void main() {
  final operation = Operation(
      id: 'op',
      vesselName: 'PRUEBA',
      voyageNumber: 'VTEST',
      portOfCall: 'GTSTC',
      createdAt: DateTime.utc(2026),
      published: true);
  const dock =
      Operator(uid: 'prueba-dock', name: 'Muelle', role: OperatorRole.dock);
  const office = Operator(
      uid: 'prueba-office', name: 'Oficina', role: OperatorRole.office);
  test('T-80 una aprobación rechazada por la nube no modifica el plan', () async {
    final request = t76Movement(MovementDraft.requestChange('op', const [
      PositionChange('C:FULL0001234', '0030282', '0030682'),
      PositionChange('C:FULL0005678', '0030682', '0030282'),
    ], 'Intercambio'), 1);
    final approval = t76Movement(MovementDraft.approveChange('op', request, 'Forzada'), 2);
    final log = _RejectedApprovalLog([MovementRecord(request, SendState.confirmed),
      MovementRecord(approval, SendState.rejected, rejection: 'Rol no permitido')]);
    log.operations.add(Operation(id: 'op', vesselName: t76Loading.vessel.name,
        voyageNumber: t76Loading.voyageNumber, portOfCall: 'GTSTC',
        createdAt: DateTime.utc(2026), published: true));
    final scope = ProviderContainer(overrides: [
      movementLogRepositoryProvider.overrideWith((ref) async => log),
    ]);
    addTearDown(scope.dispose);
    final subscription = scope.listen(loadingOperationProvider(t76Loading), (_, __) {});
    addTearDown(subscription.close);
    final data = await scope.read(loadingOperationProvider(t76Loading).future);
    expect(data.state.requests.single.status, ChangeRequestStatus.pending);
    expect(data.plan.loading['C:FULL0001234']!.plannedPosition, '0030282');
  });
  for (final brightness in Brightness.values) {
    testWidgets(
        'T-80 a 360 dp ${brightness.name}: muelle pide, oficina decide, sin cuenta no ofrece',
        (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final log = T75MemoryLog();
      final actor = NotifierProvider<_Actor, Operator?>(_Actor.new);
      final scope = ProviderContainer(overrides: [
        movementLogRepositoryProvider.overrideWith((ref) async => log),
        activeOperationProvider.overrideWith((ref) async => operation),
        operatorProvider.overrideWith((ref) => Stream.value(ref.watch(actor))),
        syncStatusProvider.overrideWith(
            (ref) => Stream.value(const SyncStatus(SyncState.upToDate))),
        loadingOperationProvider(t76Loading).overrideWith((ref) async* {
          await for (final records in log.watch('op')) {
            yield t76Operation(records.map((r) => r.movement).toList());
          }
        }),
      ]);
      addTearDown(scope.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
          container: scope,
          child: MaterialApp(
              theme: ThemeData(useMaterial3: true, brightness: brightness),
              home: ChangeRequestsPage(voyage: t76Loading))));
      await tester.pumpAndSettle();
      expect(find.text('Pedir cambio'), findsOneWidget);
      expect(find.text('Aprobar'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('new-change-request')));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byKey(const ValueKey('change-object-0')), '1');
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byKey(const ValueKey('change-object-1')), '2');
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('change-reason')),
          'Intercambio solicitado');
      await tester.pumpAndSettle();
      await tester
          .ensureVisible(find.byKey(const ValueKey('send-change-request')));
      expect(
          tester
              .widget<FilledButton>(
                  find.byKey(const ValueKey('send-change-request')))
              .onPressed,
          isNotNull,
          reason: tester
              .widgetList<Text>(find.byType(Text))
              .map((t) => t.data)
              .join(' | '));
      await tester.tap(find.byKey(const ValueKey('send-change-request')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('change-error')), findsNothing,
          reason: tester
              .widgetList<Text>(find.byKey(const ValueKey('change-error')))
              .map((t) => t.data)
              .join());
      expect(log.of('op').single.movement.type, MovementType.requestChange);
      expect(find.text('Pendiente'), findsOneWidget);
      scope.read(actor.notifier).change(office);
      await tester.pumpAndSettle();
      expect(find.text('Pedir cambio'), findsNothing);
      await tester.tap(find.text('Aprobar'));
      await tester.pumpAndSettle();
      expect(
          tester
              .widget<FilledButton>(
                  find.byKey(const ValueKey('confirm-change-decision')))
              .onPressed,
          isNull);
      await tester.enterText(
          find.byKey(const ValueKey('decision-reason')), 'Aprobado');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('confirm-change-decision')));
      await tester.pumpAndSettle();
      expect(find.text('Aprobada'), findsOneWidget);
      expect(log.of('op').last.movement.payload['request'],
          log.of('op').first.movement.id);
      // Otro pedido se rechaza y conserva la primera aprobación.
      final data = t76Operation(log.of('op').map((r) => r.movement).toList());
      final draft = const ChangeRequests().request(
          operation,
          dock,
          data,
          [
            const PositionChange('C:FULL0001234', '0030682', '0030282'),
            const PositionChange('C:FULL0005678', '0030282', '0030682'),
          ],
          'Volver al original');
      await log.append(draft, dock.author);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Rechazar'));
      await tester.tap(find.text('Rechazar'));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byKey(const ValueKey('decision-reason')), 'Mantener aprobado');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('confirm-change-decision')));
      await tester.pumpAndSettle();
      expect(find.text('Rechazada'), findsOneWidget);
      expect(log.of('op').last.movement.type, MovementType.rejectChange);
      scope.read(actor.notifier).change(null);
      await tester.pumpAndSettle();
      expect(find.text('Pedir cambio'), findsNothing);
      expect(find.text('Aprobar'), findsNothing);
      expect(find.text('Rechazar'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
  test(
      'T-80 exige rol, autorización y operación publicada; rechazo exige motivo',
      () {
    final data = t76Operation();
    const changes = [PositionChange('C:FULL0001234', '0030282', '0050482')];
    const service = ChangeRequests();
    expect(() => service.request(operation, null, data, changes, 'Motivo'),
        throwsStateError);
    expect(() => service.request(operation, office, data, changes, 'Motivo'),
        throwsStateError);
    expect(
        () => service.request(
            operation,
            const Operator(
                uid: 'x',
                name: 'x',
                role: OperatorRole.dock,
                authorized: false),
            data,
            changes,
            'Motivo'),
        throwsStateError);
    expect(
        () => service.request(operation.copyWith(published: false), dock, data,
            changes, 'Motivo'),
        throwsStateError);
    final r = t76Movement(
        service.request(operation, dock, data, changes, 'Motivo'), 1);
    final pending = t76Operation([r]);
    expect(
        () => service.decide(operation, dock, pending, r.id, 'Motivo',
            approve: true),
        throwsStateError);
    expect(
        () => service.decide(operation, office, pending, r.id, '',
            approve: false),
        throwsStateError);
  });
}
