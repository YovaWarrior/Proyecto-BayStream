import '../../../../core/utils/iso_coordinate_parser.dart';
import '../entities/entities.dart';
import 'discharge_progress.dart';
import 'loading_plan_progress.dart';
import 'operation_state_deriver.dart';

/// T-76: selección de carga y reservas sobre la misma bitácora de descarga.
class LoadingOperation {
  final String? operationId;
  final VesselVoyage loading;
  final OperationPlan plan;
  final ExportList? list;
  final List<Movement> movements;
  final OperationState state;
  final LoadingPlanProgress progress;
  final DischargeProgress discharge;

  LoadingOperation._(this.operationId, this.loading, this.plan, this.list,
      this.movements, this.state, this.progress, this.discharge);

  factory LoadingOperation.build({
    String? operationId,
    VesselVoyage? arrival,
    required VesselVoyage loading,
    ExportList? list,
    Iterable<Movement> movements = const [],
  }) {
    final events = List<Movement>.unmodifiable(movements);
    final plan = OperationPlan.build(
        portOfCall: loading.portOfCall!,
        arrival: arrival,
        loading: loading,
        geometry: loading.geometry);
    final state = const OperationStateDeriver().derive(plan, events);
    return LoadingOperation._(
        operationId,
        loading,
        plan,
        list,
        events,
        state,
        LoadingPlanProgress.build(loading, state, list: list),
        DischargeProgress.build(plan, state,
            operationId: operationId, movements: events));
  }

  PlanItem? numbered(ExportListRow row) {
    final item = plan.loading['C:${row.containerId}'];
    return item?.role == PlanRole.load ? item : null;
  }

  /// OR exacto o sufijo del contenedor; nunca se elige una coincidencia ambigua.
  List<ExportListRow> search(String query, {bool empties = false}) {
    final value = query.trim().toUpperCase();
    final order = int.tryParse(value.replaceFirst(RegExp(r'^OR\s*'), ''));
    return (list?.rows ?? const <ExportListRow>[]).where((row) {
      if (empties ? !row.isEmpty : numbered(row) == null) return false;
      return value.isEmpty ||
          row.order == order ||
          row.containerId.endsWith(value);
    }).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  /// La nueva corrección sustituirá toda la cadena. La vista previa retira
  /// esa cadena sin registrar movimientos ni restaurar un antecesor.
  OperationState _before(Movement? correcting) {
    if (correcting == null) return state;
    final byId = {for (final movement in movements) movement.id: movement};
    final replaced = <String>{};
    Movement? previous = correcting;
    while (previous != null && replaced.add(previous.id)) {
      previous = previous.type.canCorrect ? byId[previous.corrects] : null;
    }
    return const OperationStateDeriver().derive(
        plan, movements.where((movement) => !replaced.contains(movement.id)));
  }

  bool available(ExportListRow row, {Movement? correcting}) {
    final before = _before(correcting);
    if (before['C:${row.containerId}']?.state == ItemState.cancelled) {
      return false;
    }
    return !before.items.values.any((s) =>
        s.state == ItemState.moved &&
        (s.key == 'C:${row.containerId}' ||
            s.assignedContainer == row.containerId));
  }

  List<ReservedSlot> slots(ExportListRow row,
      {int? selectedBay, Movement? correcting}) {
    if (!row.isEmpty ||
        numbered(row) != null ||
        !available(row, correcting: correcting)) {
      return const [];
    }
    final before = _before(correcting);
    final result = plan.loading.values
        .where((item) {
          final slot = item.reservedSlot;
          return item.role == PlanRole.load &&
              slot != null &&
              slot.isoSizeType == row.type &&
              slot.portOfDischarge == row.pod &&
              slot.operatorCode == row.line &&
              before[item.key]?.state == ItemState.planned &&
              !before.occupancy.containsKey(item.plannedPosition);
        })
        .map((item) => item.reservedSlot!)
        .toList();
    result.sort((a, b) {
      final selectedGroup =
          selectedBay == null ? null : displayBay(selectedBay);
      final aHere = displayBay(a.stowagePosition.bay) == selectedGroup;
      final bHere = displayBay(b.stowagePosition.bay) == selectedGroup;
      if (aHere != bHere) return aHere ? -1 : 1;
      return a.stowagePosition
          .toIsoCode()
          .compareTo(b.stowagePosition.toIsoCode());
    });
    return result;
  }

  int displayBay(int bay) =>
      bay.isEven && loading.bays.containsKey(bay - 1) ? bay - 1 : bay;
  int bayOf(String position) => IsoCoordinateParser.parse(position).bay;

  Movement? movementOf(String key) {
    final id = state[key]?.movementId;
    for (final event in movements) {
      if (event.id == id) return event;
    }
    // Una carga rechazada por ocupación también puede deshacerse/corregirse.
    final conflicts = state.conflicts.where((c) => c.key == key).toList();
    for (final conflict in conflicts.reversed) {
      for (final event in movements) {
        if (event.id == conflict.movementId &&
            (event.type == MovementType.loadFull ||
                event.type == MovementType.assignEmpty)) {
          return event;
        }
      }
    }
    return null;
  }

  MovementDraft draft(ExportListRow row, String position,
      {String? seal,
      DateTime? operatedAt,
      Movement? correcting,
      String? reason}) {
    if (operationId == null) {
      throw StateError('La escala no tiene operación guardada.');
    }
    if (list?.byOrder(row.order) != row) {
      throw StateError('El OR ya no está en el listado.');
    }
    if (correcting != null &&
        (movementOf(correcting.target!)?.id != correcting.id ||
            (reason?.trim().isEmpty ?? true))) {
      throw StateError(
          'La corrección exige un movimiento vigente y un motivo.');
    }
    if (!available(row, correcting: correcting)) {
      throw StateError('El contenedor ya está operado.');
    }
    final item = numbered(row);
    if (item != null) {
      if (position != item.plannedPosition) {
        throw StateError('Solo se confirma la posición planificada.');
      }
      return MovementDraft.loadFull(operationId!, row.containerId, position,
          order: row.order,
          seal: seal,
          operatedAt: operatedAt,
          corrects: correcting?.id,
          reason: reason);
    }
    if (!slots(row, correcting: correcting)
        .any((s) => s.stowagePosition.toIsoCode() == position)) {
      throw StateError(
          'La reserva debe estar libre y ser del mismo tipo, puerto y línea.');
    }
    return MovementDraft.assignEmpty(
        operationId!, position, row.containerId, row.tareKg,
        order: row.order,
        seal: seal,
        operatedAt: operatedAt,
        corrects: correcting?.id,
        reason: reason);
  }
}
