import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/departure_export_repository.dart';
import 'package:baystream/features/vessel/domain/repositories/session_repository.dart';
import 'package:baystream/features/vessel/presentation/pages/departure_baplie_page.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_operation_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/t82_fixture.dart';

class _Save implements DepartureExportRepository {
  String? text;
  @override
  Future<String?> save(Operation operation, String edi) async {
    text = edi;
    return 'salida.edi';
  }
}

void main() {
  const office =
      Operator(uid: 'test-office', name: 'Prueba', role: OperatorRole.office);
  const dock =
      Operator(uid: 'test-dock', name: 'Prueba', role: OperatorRole.dock);
  for (final actor in <Operator?>[null, office, dock]) {
    testWidgets('T-82 acción según rol ${actor?.role.name ?? 'sin cuenta'}',
        (tester) async {
      await tester.pumpWidget(ProviderScope(
          overrides: [
            operatorProvider.overrideWith((ref) => Stream.value(actor)),
          ],
          child: MaterialApp(
              home:
                  Scaffold(body: DepartureBaplieButton(voyage: t82Loading)))));
      await tester.pumpAndSettle();
      expect(find.text('Generar BAPLIE de salida'),
          actor == dock ? findsNothing : findsOneWidget);
    });
  }
  for (final brightness in Brightness.values) {
    testWidgets(
        'T-82 360 dp ${brightness.name}: guardar parcial, copiar cancelados y anular en vivo',
        (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final events = StateProviderCompat();
      final save = _Save();
      final scope = ProviderContainer(overrides: [
        operatorProvider.overrideWith((ref) => Stream.value(office)),
        activeOperationProvider.overrideWith((ref) async => t82Operation),
        loadingOperationProvider(t82Loading).overrideWith(
            (ref) => Stream.value(t82Derive(ref.watch(events.provider)))),
        departureExportRepositoryProvider.overrideWithValue(save),
      ]);
      addTearDown(scope.dispose);
      String? copied;
      tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
          }
        return null;
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null));
      await tester.pumpWidget(UncontrolledProviderScope(
          container: scope,
          child: MaterialApp(
              theme: ThemeData(brightness: brightness, useMaterial3: true),
              home: DepartureBapliePage(voyage: t82Loading))));
      await tester.pumpAndSettle();
      expect(find.textContaining('2 de carga y 1 de descarga'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('departure-save')));
      await tester.pumpAndSettle();
      expect(save.text, contains('TSTU0000110'));
      expect(save.text, isNot(contains('EQD+CN+TSTU0000014+')));
      final cancel = t82Move(
          MovementDraft.cancelItem('op', 'C:TSTU0000014', 'No embarca'), 0);
      scope.read(events.provider.notifier).update([cancel, ...t82Loads]);
      await tester.pumpAndSettle();
      // T-132 también lo muestra entre las filas no cargadas: verificamos
      // cada lista por su identidad, sin confundir la nueva con los cancelados.
      expect(tester.widget<SelectableText>(find.byKey(
          const ValueKey('departure-cancelled-list'))).data,
          contains('OR 5 · TSTU0000014 · 0030282 · No embarca'));
      expect(tester.widget<SelectableText>(find.byKey(
          const ValueKey('departure-not-loaded-list'))).data,
          contains('OR 5 · TSTU0000014 · cancelado en la operación'));
      await tester.ensureVisible(
          find.byKey(const ValueKey('departure-copy-cancelled')));
      await tester.tap(find.byKey(const ValueKey('departure-copy-cancelled')));
      await tester.pumpAndSettle();
      expect(copied, contains('No embarca'));
      scope.read(events.provider.notifier).update([
        cancel,
        ...t82Loads,
        t82Move(MovementDraft.annul('op', cancel.id, 'Sí embarca'), 4)
      ]);
      await tester.pumpAndSettle();
      expect(find.text('Cancelados vigentes (0)'), findsOneWidget);
      expect(
          find.byKey(const ValueKey('departure-copy-cancelled')), findsNothing);
      await tester.ensureVisible(find.byKey(const ValueKey('departure-save')));
      await tester.tap(find.byKey(const ValueKey('departure-save')));
      await tester.pumpAndSettle();
      expect(save.text, contains('EQD+CN+TSTU0000014+'));
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('T-82 sin loading_baplie informa el motivo sin ofrecer guardar',
      (tester) async {
    await tester.pumpWidget(ProviderScope(overrides: [
      operatorProvider.overrideWith((ref) => Stream.value(null)),
      activeOperationProvider
          .overrideWith((ref) async => t82Operation.copyWith(sources: [])),
      loadingOperationProvider(t82Loading)
          .overrideWith((ref) => Stream.value(t82Derive())),
    ], child: MaterialApp(home: DepartureBapliePage(voyage: t82Loading))));
    await tester.pumpAndSettle();
    expect(find.textContaining('no tiene el plan de carga (BAPLIE)'), findsOneWidget);
    expect(find.byKey(const ValueKey('departure-save')), findsNothing);
  });
}

class _Events extends Notifier<List<Movement>> {
  @override
  List<Movement> build() => [];
  void update(List<Movement> events) => state = events;
}

class StateProviderCompat {
  final provider = NotifierProvider<_Events, List<Movement>>(_Events.new);
}
