import '../../../../core/utils/iso_coordinate_parser.dart';
import '../entities/entities.dart';
import '../repositories/session_repository.dart';
import 'loading_operation.dart';
import 'load_check.dart';

/// T-80 · Permisos y revisión antes de anexar una solicitud o decisión.
class ChangeRequests {
  const ChangeRequests();

  void _access(Operation operation, Operator? actor, OperatorRole role) {
    if (actor == null || !actor.authorized || actor.role != role) {
      throw StateError(role == OperatorRole.dock
          ? 'Solo una cuenta de muelle autorizada puede pedir cambios.'
          : 'Solo una cuenta de oficina autorizada puede decidir.');
    }
    if (!operation.published || operation.closed) {
      throw StateError('La operación debe estar publicada y abierta.');
    }
  }

  String? review(LoadingOperation data, List<PositionChange> changes) {
    final batch =
        PositionChange.readAll(changes.map((c) => c.toJson()).toList());
    if (batch == null) return 'Indica de uno a cuatro cambios válidos.';
    final targets = batch.map((c) => c.target).toSet();
    for (final c in batch) {
      final item = data.plan.loading[c.target];
      if (item == null) return '${c.target} no está en el plan.';
      if (item.plannedPosition != c.from) {
        return 'El origen de ${c.target} cambió; revisa la solicitud.';
      }
      final coordinate = IsoCoordinateParser.parse(c.to);
      if (coordinate.bay == 0 ||
          data.loading.geometry?.covers(coordinate) == false ||
          !data.loading.bays.keys.any((b) => (b - coordinate.bay).abs() <= 1)) {
        return 'La celda ${c.to} no existe en la geometría del buque.';
      }
      final size = nominalLength(
          item.container?.isoSizeType ?? item.reservedSlot?.isoSizeType);
      if (size != null && size != (coordinate.bay.isEven ? 40 : 20)) {
        return '${c.target} no cabe en la bahía ${coordinate.bay}.';
      }
      if (data.plan.loading.values
          .any((i) => !targets.contains(i.key) && i.plannedPosition == c.to)) {
        return '${c.to} está prevista para otro objeto; inclúyelo en el intercambio.';
      }
    }
    return null;
  }

  MovementDraft request(Operation operation, Operator? actor,
      LoadingOperation data, List<PositionChange> changes, String reason) {
    _access(operation, actor, OperatorRole.dock);
    final draft = MovementDraft.requestChange(operation.id, changes, reason);
    final error = draft.validate() ?? review(data, changes);
    if (error != null) throw StateError(error);
    return draft;
  }

  MovementDraft decide(Operation operation, Operator? actor,
      LoadingOperation data, String requestId, String reason,
      {required bool approve}) {
    _access(operation, actor, OperatorRole.office);
    final request = data.state.requests
        .where((r) => r.movement.id == requestId)
        .firstOrNull;
    if (request == null || request.status != ChangeRequestStatus.pending) {
      throw StateError('La solicitud ya no está pendiente.');
    }
    if (approve) {
      final error = review(data, request.changes);
      if (error != null) throw StateError(error);
    }
    final draft = approve
        ? MovementDraft.approveChange(operation.id, request.movement, reason)
        : MovementDraft.rejectChange(operation.id, requestId, reason);
    final error = draft.validate();
    if (error != null) throw StateError(error);
    return draft;
  }
}
