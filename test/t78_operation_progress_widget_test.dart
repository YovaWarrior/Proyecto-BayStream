import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/pages/operation_progress_page.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_operation_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/bay_plan_view.dart';
import 'package:baystream/features/vessel/presentation/widgets/loading_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/local_profile_test_support.dart';
import 'support/t75_memory_log.dart';
import 'support/t76_fixture.dart';

void main() {
  for (final size in [const Size(360, 800), const Size(1920, 1080)]) {
    for (final brightness in Brightness.values) {
      testWidgets(
          'T-78 ${size.width} ${brightness.name}: flujo, actualización y enlace',
          (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final log = T75MemoryLog();
        final container = ProviderContainer(overrides: [
          movementLogRepositoryProvider.overrideWith((ref) async => log),
          vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
          loadingOperationProvider(t76Loading).overrideWith((ref) async* {
            await for (final records in log.watch('op')) {
              yield t76Operation(records.map((r) => r.movement).toList());
            }
          }),
        ]);
        addTearDown(container.dispose);
        await tester.pumpWidget(UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
                theme: ThemeData(brightness: brightness, useMaterial3: true),
                home: Scaffold(body: BayPlanView(voyage: t76Loading)))));
        await tester.pumpAndSettle();
        await tester
            .tap(find.byKey(const ValueKey('operation-progress-button')));
        await tester.pumpAndSettle();
        expect(find.byType(OperationProgressPage), findsOneWidget);
        expect(find.textContaining('2 pendientes'), findsWidgets);
        expect(find.textContaining('6 pendientes'), findsWidgets);
        expect(find.text('Sin conflictos.'), findsOneWidget);
        expect(tester.takeException(), isNull);
        const author = MovementAuthor(
            name: 'Oficina de prueba', role: OperatorRole.office);
        await log.append(
            MovementDraft.loadFull('op', 'FULL0005678', '0030682'), author);
        await tester.pumpAndSettle();
        final original = log.of('op').single.movement;
        await log.append(
            MovementDraft.loadFull('op', 'FULL0005678', '0050282',
                corrects: original.id, reason: 'Prueba de enlace'),
            author);
        await tester.pumpAndSettle();
        final link = find.byKey(const ValueKey('progress-conflict-mov-2'));
        await tester.ensureVisible(link);
        await tester.tap(link);
        await tester.pumpAndSettle();
        expect(find.byType(OperationProgressPage), findsNothing);
        expect(container.read(selectedBayProvider), 5);
        expect(container.read(highlightedContainerProvider), 'R:0050282');
        expect(tester.takeException(), isNull);
        // El detalle usa el movimiento vigente, y deshacer restaura el original.
        final context = tester.element(find.byType(BayPlanView));
        showLoadingDetails(context, t76Loading, 'C:FULL0005678');
        await tester.pumpAndSettle();
        expect(find.text('Deshacer corrección'), findsOneWidget);
        expect(find.text('Deshacer carga'), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
