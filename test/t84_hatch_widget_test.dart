import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/providers/discharge_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_operation_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/widgets/discharge_controls.dart';
import 'package:baystream/features/vessel/presentation/widgets/loading_controls.dart';
import 'package:baystream/features/vessel/presentation/widgets/hatch_operation_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/t75_memory_log.dart';
import 't84_hatch_operation_test.dart'
    show t84Operation, t84Arrival, t84Loading;

void main() {
  for (final remove in [false, true]) {
    testWidgets(
        'T-84 descarga a 360 dp: ${remove ? 'quitar y continuar, deshacer el par' : 'seguir sin quitar no bloquea'}',
        (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final log = T75MemoryLog();
      await tester.pumpWidget(ProviderScope(
          overrides: [
            movementLogRepositoryProvider.overrideWith((ref) async => log),
            dischargeProgressProvider(t84Arrival).overrideWith((ref) async* {
              await for (final records in log.watch('op')) {
                yield t84Operation(records.map((r) => r.movement)).discharge;
              }
            }),
          ],
          child: MaterialApp(
              home: Scaffold(body: Consumer(builder: (context, ref, _) {
            ref.watch(dischargeProgressProvider(t84Arrival));
            return TextButton(
                onPressed: () => onDischargeTap(
                    context, ref, t84Arrival, t84Arrival.containers.first,
                    openDetails: () {}),
                child: const Text('Descargar'));
          })))));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Descargar'));
      await tester.pumpAndSettle();
      expect(find.text('Tapa puesta · T1'), findsOneWidget);
      expect(find.textContaining('PROVISIONAL'), findsOneWidget);
      expect(find.text('Quitar tapa y continuar'), findsOneWidget);
      await tester.tap(find.byKey(
          ValueKey(remove ? 'hatch-remove-continue' : 'hatch-continue')));
      await tester.pumpAndSettle();
      expect(
          log.of('op').map((r) => r.movement.type),
          remove
              ? [MovementType.hatchCover, MovementType.discharge]
              : [MovementType.discharge]);
      if (remove) {
        await tester.tap(find.text('Deshacer'));
        await tester.pumpAndSettle();
        expect(log.of('op').map((r) => r.movement.type), [
          MovementType.hatchCover,
          MovementType.discharge,
          MovementType.annul,
          MovementType.annul
        ]);
        final state = t84Operation(log.of('op').map((r) => r.movement)).state;
        expect(state.hatchCovers['T:3-1']!.removed, isFalse);
        expect(state['C:TSTU0000001']!.state, ItemState.planned);
      }
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
      'T-84 carga ocupada bajo tapa: tapa, descarga y carga; undo restaura los tres',
      (tester) async {
    final log = T75MemoryLog();
    await tester.pumpWidget(ProviderScope(
        overrides: [
          movementLogRepositoryProvider.overrideWith((ref) async => log),
          loadingOperationProvider(t84Loading).overrideWith((ref) async* {
            await for (final records in log.watch('op')) {
              yield t84Operation(records.map((r) => r.movement));
            }
          }),
        ],
        child: MaterialApp(
            home: Scaffold(body: Consumer(builder: (context, ref, _) {
          final operation =
              ref.watch(loadingOperationProvider(t84Loading)).value;
          return TextButton(
              onPressed: operation == null
                  ? null
                  : () => openLoadingRow(
                      context, ref, t84Loading, operation.list!.byOrder(1)!),
              child: const Text('Cargar'));
        })))));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cargar'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('loading-confirm')));
    await tester.tap(find.byKey(const ValueKey('loading-confirm')));
    await tester.pumpAndSettle();
    expect(find.text('Quitar tapa y continuar'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('hatch-remove-continue')));
    await tester.pumpAndSettle();
    expect(log.of('op').map((r) => r.movement.type), [
      MovementType.hatchCover,
      MovementType.discharge,
      MovementType.loadFull
    ]);
    await tester.tap(find.text('Deshacer'));
    await tester.pumpAndSettle();
    expect(log.of('op').where((r) => r.movement.type == MovementType.annul),
        hasLength(3));
    final state = t84Operation(log.of('op').map((r) => r.movement)).state;
    expect(state.hatchCovers['T:3-1']!.removed, isFalse);
    expect(state.occupancy, t84Operation([]).state.occupancy);
    expect(tester.takeException(), isNull);
  });
  testWidgets('T-84 pantalla a 360 dp: reponer sin quitar, conflicto y annul',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final log = T75MemoryLog();
    await tester.pumpWidget(ProviderScope(
        overrides: [
          movementLogRepositoryProvider.overrideWith((ref) async => log),
          loadingOperationProvider(t84Loading).overrideWith((ref) async* {
            await for (final records in log.watch('op')) {
              yield t84Operation(records.map((r) => r.movement));
            }
          }),
        ],
        child: MaterialApp(
            home: HatchOperationPage(voyage: t84Loading, initialBay: 3))));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('hatch-replace-T:3-1')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Deshacer conflicto'));
    await tester.tap(find.text('Deshacer conflicto'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('annul-by-mistake')));
    await tester.pumpAndSettle();
    expect(t84Operation(log.of('op').map((r) => r.movement)).state.conflicts,
        isEmpty);
    expect(log.of('op').last.movement.type, MovementType.annul);
    expect(tester.takeException(), isNull);
  });
}
