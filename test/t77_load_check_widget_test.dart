import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_operation_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/bay_plan_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/local_profile_test_support.dart';
import 'support/t75_memory_log.dart';
import 'support/t76_fixture.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
        'T-77 avisos a 360 dp ${brightness.name}: 20/40, fuera de plan, '
        'descarga y carga, otro grupo', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final log = T75MemoryLog();
      final scope = ProviderContainer(overrides: [
        movementLogRepositoryProvider.overrideWith((ref) async => log),
        vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
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
              theme: ThemeData(brightness: brightness, useMaterial3: true),
              home: Scaffold(body: BayPlanView(voyage: t76Loading)))));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('bay-plan-display-mode')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Carga').last);
      await tester.pumpAndSettle();

      Future<void> open(String order, {bool empty = false}) async {
        await tester
            .tap(find.byKey(ValueKey(empty ? 'empty-search' : 'load-search')));
        await tester.pumpAndSettle();
        await tester.enterText(
            find.byKey(const ValueKey('loading-query')), order);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(ValueKey('loading-or-$order')));
        await tester.pumpAndSettle();
      }

      FilledButton confirmButton() => tester.widget<FilledButton>(
          find.byKey(const ValueKey('loading-confirm')));
      Future<void> confirm() async {
        await tester
            .ensureVisible(find.byKey(const ValueKey('loading-confirm')));
        await tester.tap(find.byKey(const ValueKey('loading-confirm')));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 7));
        await tester.pumpAndSettle();
      }

      // El plan tal cual: revisado y sin límite declarado.
      await open('2');
      expect(find.byKey(const ValueKey('load-clean')), findsOneWidget);
      expect(find.textContaining('el perfil no declara límite'), findsOneWidget);

      // 20/40: un 20 en una bahía par no se registra, ni con motivo.
      await tester.enterText(
          find.byKey(const ValueKey('loading-cell')), '004-02-82');
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('load-issue-size')), findsOneWidget);
      expect(find.textContaining('No se registra'), findsOneWidget);
      expect(find.byKey(const ValueKey('loading-reason')), findsNothing);
      expect(confirmButton().onPressed, isNull);

      // Fuera de plan: pide motivo y solo con él confirma.
      await tester.enterText(
          find.byKey(const ValueKey('loading-cell')), '003-08-82');
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('load-issue-outOfPlan')), findsOneWidget);
      expect(confirmButton().onPressed, isNull);
      await tester.enterText(
          find.byKey(const ValueKey('loading-reason')), 'Lo dejó la grúa');
      await tester.pumpAndSettle();
      expect(confirmButton().onPressed, isNotNull);
      await confirm();
      final outOfPlan = log.of('op').last.movement;
      expect((outOfPlan.position, outOfPlan.reason),
          ('0030882', 'Lo dejó la grúa'));

      // La celda la ocupa un contenedor que baja aquí: un toque, dos movimientos.
      await open('1');
      expect(find.byKey(const ValueKey('load-discharge-first')), findsOneWidget);
      expect(find.text('Marcar su descarga y cargar'), findsOneWidget);
      await confirm();
      final pair = log.of('op').skip(1).map((r) => r.movement).toList();
      expect(pair.map((m) => (m.type, m.target)), [
        (MovementType.discharge, 'C:INCOMING1'),
        (MovementType.loadFull, 'C:FULL0001234'),
      ]);

      // Un vacío en una reserva de otro grupo: solo con motivo.
      await open('12', empty: true);
      await tester.tap(find.byKey(const ValueKey('loading-other-groups')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('loading-position-12')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('003-03-82 · otro grupo').last);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('load-issue-otherGroup')), findsOneWidget);
      expect(confirmButton().onPressed, isNull);
      await tester.enterText(
          find.byKey(const ValueKey('loading-reason')), 'Sin reservas JMKCT');
      await tester.pumpAndSettle();
      await confirm();
      final assigned = log.of('op').last.movement;
      expect((assigned.target, assigned.reason),
          ('R:0030382', 'Sin reservas JMKCT'));
      final state =
          t76Operation(log.of('op').map((r) => r.movement).toList()).state;
      expect(state.conflicts.map((c) => c.kind).toSet(),
          {ConflictKind.outOfPlan, ConflictKind.otherGroup});
      expect(state.conflicts.where((c) => c.kind == ConflictKind.cellTaken),
          isEmpty);
      expect(tester.takeException(), isNull);
    });
  }
}
