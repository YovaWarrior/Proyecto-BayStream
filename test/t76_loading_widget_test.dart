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
        'T-76 Carga a 360 dp ${brightness.name}: buscar, confirmar, corregir, vacío y deshacer',
        (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final log = T75MemoryLog();
      const author = MovementAuthor(name: 'Prueba', role: OperatorRole.dock);
      await log.append(
          MovementDraft.discharge('op', 'INCOMING1', '0030282'), author);
      await log.append(
          MovementDraft.discharge('op', 'INCOMING2', '0030482'), author);
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
      expect(find.textContaining('Descarga: 0 pendientes'), findsOneWidget);
      Future<void> search(String query, {bool empty = false}) async {
        await tester
            .tap(find.byKey(ValueKey(empty ? 'empty-search' : 'load-search')));
        await tester.pumpAndSettle();
        await tester.enterText(
            find.byKey(const ValueKey('loading-query')), query);
        await tester.pumpAndSettle();
      }

      Future<void> confirm() async {
        await tester.pumpAndSettle();
        await tester
            .ensureVisible(find.byKey(const ValueKey('loading-confirm')));
        await tester.tap(find.byKey(const ValueKey('loading-confirm')));
        await tester.pumpAndSettle();
      }

      await search('1');
      await tester.tap(find.byKey(const ValueKey('loading-or-1')));
      await tester.pumpAndSettle();
      expect(scope.read(highlightedContainerProvider), 'FULL0001234');
      expect(find.text('Posición planificada: 003-02-82'), findsOneWidget);
      await tester.enterText(
          find.byKey(const ValueKey('loading-hour')), '25:80');
      await confirm();
      expect(find.byKey(const ValueKey('loading-error')), findsOneWidget);
      expect(log.of('op').length, 2);
      await tester.enterText(
          find.byKey(const ValueKey('loading-hour')), '09:35');
      await tester.enterText(
          find.byKey(const ValueKey('loading-seal')), 'TEST-1');
      await confirm();
      final loaded = log.of('op').last.movement;
      expect((loaded.type, loaded.payload['order'], loaded.payload['seal']),
          (MovementType.loadFull, 1, 'TEST-1'));
      expect(
          DateTime.parse(loaded.payload['operatedAt'] as String).toLocal().hour,
          9);
      await tester.tap(find.text('Deshacer'));
      await tester.pumpAndSettle();
      expect(log.of('op').last.movement.type, MovementType.annul);
      await search('1234');
      await tester.tap(find.byKey(const ValueKey('loading-or-1')));
      await tester.pumpAndSettle();
      await confirm();
      await tester.pump(const Duration(seconds: 7));
      await search('1');
      await tester.tap(find.byKey(const ValueKey('loading-or-1')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Registrado'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('loading-correct')));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byKey(const ValueKey('loading-seal')), 'TEST-2');
      await tester.enterText(
          find.byKey(const ValueKey('loading-correction-reason')),
          'Marchamo corregido');
      await confirm();
      expect(find.byKey(const ValueKey('loading-error')), findsNothing,
          reason: tester
              .widgetList<Text>(find.byKey(const ValueKey('loading-error')))
              .map((t) => t.data)
              .join());
      expect(log.of('op').last.movement.corrects, log.of('op')[4].movement.id);
      expect(log.of('op').length, 6,
          reason: 'Corregir anexa una sola escritura');
      expect(find.text('Marchamo: TEST-2'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('loading-undo-detail')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('annul-by-mistake')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cerrar').last);
      await tester.pumpAndSettle();
      await search('12', empty: true);
      await tester.tap(find.byKey(const ValueKey('loading-or-12')));
      await tester.pumpAndSettle();
      expect(find.text('Tara real: 2185 kg'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('loading-position-12')));
      await tester.pumpAndSettle();
      expect(find.text('003-01-82'), findsNothing);
      expect(find.text('003-03-82'), findsNothing);
      expect(find.text('003-05-82'), findsNothing);
      await tester.tap(find.text('003-04-82').last);
      await tester.pumpAndSettle();
      await confirm();
      final assigned = log.of('op').last.movement;
      expect((assigned.type, assigned.target, assigned.payload['tareKg']),
          (MovementType.assignEmpty, 'R:0030482', 2185));
      expect(
          t76Operation(log.of('op').map((r) => r.movement).toList())
              .state
              .conflicts,
          isEmpty);
      expect(tester.takeException(), isNull);
    });
  }
}
