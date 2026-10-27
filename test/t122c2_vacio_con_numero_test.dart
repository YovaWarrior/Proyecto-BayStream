// T-122 · Corrección 2 (SPRINT-4.md 10.59, A1): sin listado solo se cargan los
// contenedores que el plan declara llenos (10.51). Un vacío que el plan trae
// con su número, y un contenedor sin estado, necesitan su fila: no se
// ofrecen, no se registran y el borrador rechaza una fila sin OR que no sea de
// un lleno. Estaba en rojo antes del arreglo: el vacío se ofrecía «sin OR en
// el listado», con tara 0, y quedaba cargado como load_full.
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';
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
import 'support/t75_memory_log.dart';
import 'support/t76_fixture.dart';
import 't81_office_changes_test.dart' as f;

/// Un plan de carga sin listado: un lleno, un vacío con número (como el
/// MNLU0000811 de T100_CARGA, que el plan declara `empty`) y uno sin estado.
final _vacioConNumero = t76Unit('EMPTY0000811', '0030482')
    .copyWith(status: ContainerStatus.empty, grossWeight: 2200);
final _sinEstado = t76Unit('UNKN0000900', '0030682')
    .copyWith(status: ContainerStatus.unknown);
final _loading = t76Voyage([
  t76Unit('FULL0001234', '0030282'),
  _vacioConNumero,
  _sinEstado,
]);

LoadingOperation _data([List<Movement> moves = const []]) =>
    LoadingOperation.build(operationId: 'op', loading: _loading, movements: moves);

Future<T75MemoryLog> _plano(WidgetTester tester) async {
  final log = T75MemoryLog();
  LoadingOperation derive(List<MovementRecord> records) =>
      LoadingOperation.build(
          operationId: 'op',
          loading: _loading,
          movements: records.map((r) => r.movement));
  final scope = ProviderContainer(overrides: [
    movementLogRepositoryProvider.overrideWith((ref) async => log),
    vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
    operatorProvider.overrideWith((ref) => Stream.value(f.dock)),
    activeOperationProvider.overrideWith((ref) async => f.operation),
    loadingOperationProvider(_loading).overrideWith((ref) async* {
      await for (final records in log.watch('op')) {
        yield derive(records);
      }
    }),
    loadingPlanProgressProvider(_loading).overrideWith((ref) async* {
      await for (final records in log.watch('op')) {
        yield derive(records).progress;
      }
    }),
  ]);
  addTearDown(scope.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
      container: scope,
      child: MaterialApp(home: Scaffold(body: BayPlanView(voyage: _loading)))));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('bay-plan-display-mode')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Carga').last);
  await tester.pumpAndSettle();
  return log;
}

void main() {
  test('sin listado solo se ofrece el lleno: ni el vacío con número ni el sin estado',
      () {
    final data = _data();
    expect(data.list, isNull);
    expect(data.plan.loading['C:EMPTY0000811']!.role, PlanRole.load);
    expect(data.unlistedRows.map((r) => r.containerId), ['FULL0001234']);
    expect(data.search('').map((r) => r.containerId), ['FULL0001234']);
    expect(data.search('811'), isEmpty);
    expect(data.search('900'), isEmpty);
    expect(data.unlistedRow('EMPTY0000811'), isNull);
    expect(data.unlistedRow('UNKN0000900'), isNull);
    expect(data.search('', empties: true), isEmpty,
        reason: 'los vacíos siguen saliendo solo del listado');
  });

  test('el borrador rechaza una fila sin OR que no sea de un lleno, aunque se la pasen',
      () {
    final data = _data();
    for (final unit in [_vacioConNumero, _sinEstado]) {
      final row = ExportListRow.fromPlan(unit);
      expect(row.unlisted, isTrue);
      expect(
          () => data.draft(row, unit.stowagePosition!.toIsoCode()),
          throwsA(isA<StateError>().having(
              (e) => e.message, 'message', contains('listado'))),
          reason: unit.containerId);
    }
    // El lleno sí, como en H4.
    final lleno = data.draft(ExportListRow.fromPlan(_loading.containers.first),
        '0030282');
    expect(lleno.type, MovementType.loadFull);
    expect(lleno.payload['order'], isNull);
  });

  testWidgets(
      'en el muelle, tocar el vacío con número sin listado no abre «Confirmar carga»',
      (tester) async {
    final log = await _plano(tester);
    await tester.ensureVisible(find.byKey(const ValueKey('plan-cell-0030482')));
    await tester.tap(find.byKey(const ValueKey('plan-cell-0030482')));
    // El aviso flotante lleva su temporizador: se avanza a mano, sin settle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const ValueKey('loading-confirm')), findsNothing);
    expect(find.textContaining('espera el listado'), findsWidgets,
        reason: 'el aviso dice que el vacío espera el listado');
    expect(log.of('op'), isEmpty);
    // El lleno sí abre «Confirmar carga» (H4), cuando el aviso ya se fue.
    await tester.pump(const Duration(seconds: 8));
    await tester.ensureVisible(find.byKey(const ValueKey('plan-cell-0030282')));
    await tester.tap(find.byKey(const ValueKey('plan-cell-0030282')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('loading-confirm')), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    // Ningún aviso ni temporizador queda vivo al terminar.
    await tester.pump(const Duration(seconds: 10));
    expect(tester.takeException(), isNull);
  });
}
