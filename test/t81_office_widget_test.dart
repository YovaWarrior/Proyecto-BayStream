import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/session_repository.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_operation_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/office_plan_controls.dart';
import 'package:baystream/features/vessel/presentation/widgets/bay_plan_view.dart';
import 'package:baystream/features/vessel/presentation/widgets/loading_controls.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_plan_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/t75_memory_log.dart';
import 'support/t76_fixture.dart';
import 'support/local_profile_test_support.dart';
import 't81_office_changes_test.dart' as fixture;

class _Actor extends Notifier<Operator?> {
  @override
  Operator? build() => fixture.office;
  void change(Operator? value) => state = value;
}

void main() {
  testWidgets('T-81 Número de orden redibuja plan efectivo y cancelados sin recargar', (tester) async {
    final log = T75MemoryLog();
    final scope = ProviderContainer(overrides: [
      movementLogRepositoryProvider.overrideWith((ref) async => log),
      vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
      loadingOperationProvider(t76Loading).overrideWith((ref) async* {
        await for (final records in log.watch('op')) {
          yield t76Operation(records.map((r) => r.movement).toList());
        }
      }),
      loadingPlanProgressProvider(t76Loading).overrideWith((ref) async* {
        await for (final records in log.watch('op')) {
          yield t76Operation(records.map((r) => r.movement).toList()).progress;
        }
      }),
    ]);
    addTearDown(scope.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: scope,
        child: MaterialApp(home: Scaffold(body: BayPlanView(voyage: t76Loading)))));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('bay-plan-display-mode')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Número de orden').last);
    await tester.pumpAndSettle();
    await log.append(MovementDraft.changePosition('op', fixture.move, 'Cambio remoto'), fixture.office.author);
    await log.append(MovementDraft.cancelItem('op', 'C:FULL0005678', 'No embarca'), fixture.office.author);
    await tester.pumpAndSettle();
    expect(find.text('Cancelado'), findsOneWidget);
    scope.read(selectedBayProvider.notifier).select(5);
    await tester.pumpAndSettle();
    final cell = tester.widget<LoadingCell>(find.byKey(const ValueKey('loading-C:FULL0001234')));
    expect(cell.operation.plan.loading[fixture.key]!.plannedPosition, '0050482');
    expect(find.text('OR 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final brightness in Brightness.values) {
    testWidgets(
        'T-81 360 dp ${brightness.name}: mover, cancelar, deshacer y rol en vivo',
        (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final log = T75MemoryLog();
      final actor = NotifierProvider<_Actor, Operator?>(_Actor.new);
      final scope = ProviderContainer(overrides: [
        movementLogRepositoryProvider.overrideWith((ref) async => log),
        activeOperationProvider.overrideWith((ref) async => fixture.operation),
        operatorProvider.overrideWith((ref) => Stream.value(ref.watch(actor))),
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
              home: Scaffold(
                  body: OfficePlanActions(
                      voyage: t76Loading, itemKey: fixture.key)))));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('office-move')));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byKey(const ValueKey('change-destination-0')), '005-04-82');
      await tester.enterText(
          find.byKey(const ValueKey('change-reason')), 'Mover desde oficina');
      await tester.pumpAndSettle();
      await tester
          .ensureVisible(find.byKey(const ValueKey('send-change-request')));
      await tester.tap(find.byKey(const ValueKey('send-change-request')));
      await tester.pumpAndSettle();
      expect(log.of('op'), hasLength(1),
          reason: tester
              .widgetList<Text>(find.byType(Text))
              .map((t) => t.data)
              .join(' | '));
      expect(log.of('op').single.movement.type, MovementType.changePosition);
      expect(
          log.of('op').single.movement.payload.containsKey('request'), isFalse);
      expect(
          scope
              .read(loadingOperationProvider(t76Loading))
              .value!
              .plan
              .loading[fixture.key]!
              .plannedPosition,
          '0050482');
      await tester.tap(find.byKey(const ValueKey('office-cancel')));
      await tester.pumpAndSettle();
      expect(
          tester
              .widget<FilledButton>(
                  find.byKey(const ValueKey('office-confirm')))
              .onPressed,
          isNull);
      await tester.enterText(
          find.byKey(const ValueKey('office-reason')), 'No embarca');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('office-confirm')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('office-cancelled')), findsOneWidget);
      expect(find.byKey(const ValueKey('office-move')), findsNothing);
      scope.read(actor.notifier).change(fixture.dock);
      await tester.pumpAndSettle();
      expect(find.text('Deshacer cancelación'), findsNothing);
      expect(find.text('Deshacer movimiento'), findsNothing);
      expect(find.byKey(const ValueKey('office-cancelled')), findsOneWidget);
      scope.read(actor.notifier).change(fixture.office);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Deshacer cancelación'));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byKey(const ValueKey('office-reason')), 'Sí embarca');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('office-confirm')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('office-move')), findsOneWidget);
      expect(find.byKey(const ValueKey('office-cancelled')), findsNothing);
      expect(log.of('op').last.movement.type, MovementType.annul);
      scope.read(actor.notifier).change(null);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('office-move')), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
      'T-81 vuelve a revisar pendiente al confirmar tras una carga remota',
      (tester) async {
    final log = T75MemoryLog();
    final scope = ProviderContainer(overrides: [
      movementLogRepositoryProvider.overrideWith((ref) async => log),
      activeOperationProvider.overrideWith((ref) async => fixture.operation),
      operatorProvider.overrideWith((ref) => Stream.value(fixture.office)),
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
            home: Scaffold(
                body: OfficePlanActions(
                    voyage: t76Loading, itemKey: fixture.key)))));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('office-cancel')));
    await tester.pumpAndSettle();
    await log.append(MovementDraft.loadFull('op', 'FULL0001234', '0050482'),
        fixture.dock.author);
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const ValueKey('office-reason')), 'Llegó una carga');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('office-confirm')));
    await tester.pumpAndSettle();
    expect(log.of('op'), hasLength(1));
    expect(find.textContaining('Solo se cancela un objeto pendiente'),
        findsOneWidget,
        reason: tester
            .widgetList<Text>(find.byType(Text))
            .map((t) => t.data)
            .join(' | '));
    expect(tester.takeException(), isNull);
  });
}
