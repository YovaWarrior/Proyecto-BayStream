import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';
import 'package:baystream/features/vessel/domain/services/load_check.dart';
import 'package:baystream/features/vessel/domain/services/operation_progress.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/t76_fixture.dart';

void main() {
  OperationProgress derive(List<Movement> events) =>
      OperationProgress.build(t76Operation(events));
  test('T-78 proyección inicial, carga ocupada y descarga posterior', () {
    final initial = derive([]).total;
    expect(
        (initial.dischargePending, initial.fullPending, initial.emptyPending),
        (2, 2, 6));
    expect((
      initial.discharged,
      initial.fullLoaded,
      initial.emptyLoaded,
      initial.cancelled,
      initial.conflicts
    ), (
      0,
      0,
      0,
      0,
      0
    ));
    final load =
        t76Movement(MovementDraft.loadFull('op', 'FULL0001234', '0030282'), 1);
    final blocked = derive([load]).total;
    expect((blocked.fullPending, blocked.fullLoaded, blocked.conflicts),
        (2, 0, 1));
    final after = derive([
      load,
      t76Movement(MovementDraft.discharge('op', 'INCOMING1', '0030282'), 2)
    ]).total;
    expect((
      after.fullPending,
      after.fullLoaded,
      after.dischargePending,
      after.discharged,
      after.conflicts
    ), (
      1,
      1,
      1,
      1,
      0
    ));
  });
  test('T-78 duplicados no suman y la corrección anulada restaura el original',
      () {
    final first =
        t76Movement(MovementDraft.loadFull('op', 'FULL0005678', '0030682'), 1);
    final duplicate =
        t76Movement(MovementDraft.loadFull('op', 'FULL0005678', '0030682'), 2);
    expect(derive([first, duplicate]).total.fullLoaded, 1);
    final correction = t76Movement(
        MovementDraft.loadFull('op', 'FULL0005678', '0050482',
            corrects: first.id, reason: 'Corregir'),
        3);
    final corrected = derive([first, correction]);
    expect(corrected.total.fullLoaded, 1);
    expect(corrected.conflicts.single.position, '0050482');
    expect(corrected.bays.firstWhere((b) => b.bay == 5).fullLoaded, 1);
    final annul =
        t76Movement(MovementDraft.annul('op', correction.id, 'Deshacer'), 4);
    final restored = derive([correction, annul, first]);
    expect(restored.conflicts, isEmpty);
    expect(restored.total.fullLoaded, 1);
    expect(restored.last!.id, annul.id);
    expect(restored.bays.firstWhere((b) => b.bay == 5).last!.id, annul.id);
  });
  test('T-78 cancelados y anulación de la cancelación', () {
    final cancel = t76Movement(
        MovementDraft.cancelItem('op', 'R:0030882', 'No embarca'), 1);
    expect(
        (derive([cancel]).total.cancelled, derive([cancel]).total.emptyPending),
        (1, 5));
    final annul =
        t76Movement(MovementDraft.annul('op', cancel.id, 'Restaurar'), 2);
    expect((
      derive([cancel, annul]).total.cancelled,
      derive([cancel, annul]).total.emptyPending
    ), (
      0,
      6
    ));
  });
  test('T-78 re-estiba de tránsito aparte de la descarga', () {
    final arrival = t76Voyage(
        [t76Unit('TRANSIT', '0030282').copyWith(portOfLoading: 'HNPCR')]);
    final event = t76Movement(
        MovementDraft.discharge('op', 'TRANSIT', '0030282',
            restow: true, reason: 'Re-estibar'),
        1);
    final data = OperationProgress.build(LoadingOperation.build(
        arrival: arrival, loading: t76Loading, movements: [event]));
    expect((
      data.total.restows,
      data.total.discharged,
      data.total.dischargePending
    ), (
      1,
      0,
      0
    ));
  });
  test('T-78 peso actual: llegada, VGM, tara real y sin límite', () {
    final arrival = t76Voyage([
      t76Unit('INCOMING1', '0030282', incoming: true)
          .copyWith(grossWeight: 4000)
    ]);
    final loading = t76Voyage(
        [t76Unit('FULL0005678', '0030284').copyWith(grossWeight: 1000)],
        slots: [t76Slot('0030286')]);
    final list = ExportList(fileName: 'prueba', rows: [
      ExportListRow(
          sheetRow: 1,
          order: 2,
          containerId: 'FULL0005678',
          status: ContainerStatus.full,
          listType: '22G1',
          listPod: 'PAMIT',
          listLine: 'TEST',
          tareKg: 2000,
          vgmKg: 7000),
      t76Row(12, 'EMPTY0000012', empty: true, tare: 2185)
    ]);
    OperationProgress build(List<Movement> events, {double? limit}) =>
        OperationProgress.build(LoadingOperation.build(
            arrival: arrival,
            loading: loading.withGeometry(
                loading.geometry!.copyWith(stackWeightLimitKg: limit)),
            list: list,
            movements: events));
    final events = [
      t76Movement(MovementDraft.loadFull('op', 'FULL0005678', '0030284'), 1),
      t76Movement(
          MovementDraft.assignEmpty('op', '0030286', 'EMPTY0000012', 2185), 2)
    ];
    expect(build([]).stacks.single.knownKg, 4000);
    final full = build(events, limit: 9000);
    expect(full.stacks.single.knownKg, 13185);
    expect(full.stacks.single.status, StackWeightStatus.exceeded);
    expect(full.conflicts, isEmpty);
    events.add(
        t76Movement(MovementDraft.discharge('op', 'INCOMING1', '0030282'), 3));
    expect(build(events).stacks.single.knownKg, 9185);
    expect(build(events).stacks.single.status, StackWeightStatus.notEvaluated);
  });
  test('T-78 pesos faltantes y pilas separadas por bahía y zona', () {
    final arrival = t76Voyage([
      t76Unit('A', '0030282', incoming: true),
      t76Unit('B', '0040282', incoming: true).copyWith(grossWeight: 6000),
      t76Unit('C', '0030202', incoming: true).copyWith(grossWeight: 4000)
    ]);
    final loading = t76Loading
        .withGeometry(t76Loading.geometry!.copyWith(stackWeightLimitKg: 9000));
    final data = OperationProgress.build(
        LoadingOperation.build(arrival: arrival, loading: loading));
    expect(data.stacks.length, 3);
    expect(data.stacks.singleWhere((s) => s.bay == 3 && s.deck).status,
        StackWeightStatus.notEvaluated);
    expect(data.stacks.singleWhere((s) => s.bay == 4).knownKg, 6000);
    expect(data.stacks.singleWhere((s) => s.bay == 3 && !s.deck).knownKg, 4000);
    expect(data.bays.singleWhere((b) => b.bay == 3).paired, isTrue);
  });
}
