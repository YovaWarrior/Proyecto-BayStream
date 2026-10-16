import '../../../../core/utils/iso_coordinate_parser.dart';
import '../entities/entities.dart';
import '../repositories/session_repository.dart';
import 'loading_operation.dart';
import 'load_check.dart';

/// T-80 · Permisos y revisión antes de anexar una solicitud o decisión.
class ChangeRequests {
  const ChangeRequests();

  bool pending(LoadingOperation data, String key) =>
      data.plan.loading[key]?.role == PlanRole.load &&
      data.state[key]?.state == ItemState.planned;

  /// T-105: una sola revisión pura para el gesto y ambos caminos de guardado.
  ChangePreview preview(
      LoadingOperation data, Operator? actor, List<PositionChange> changes) {
    if (actor == null || !actor.authorized) {
      return const ChangePreview.invalid('Inicia sesión para mover');
    }
    if (PositionChange.readAll(changes.map((c) => c.toJson()).toList()) ==
        null) {
      return const ChangePreview.invalid(
          'Indica de uno a cuatro cambios válidos, sin repetir objetos ni destinos.');
    }
    final error = review(data, changes);
    if (error != null) return ChangePreview.invalid(error);
    final batch =
        PositionChange.readAll(changes.map((c) => c.toJson()).toList())!;
    for (final change in batch) {
      if (!pending(data, change.target)) {
        return const ChangePreview.invalid(
            'Solo se mueve un objeto pendiente del plan de carga.');
      }
      final source = data.plan.loading[change.target]!.reservedSlot;
      final destination = data.plan.loadingItemAt(change.to)?.reservedSlot;
      if (source != null &&
          destination != null &&
          (source.isoSizeType != destination.isoSizeType ||
              source.portOfDischarge != destination.portOfDischarge ||
              source.operatorCode != destination.operatorCode)) {
        return const ChangePreview.invalid(
            'Las reservas del intercambio deben ser del mismo grupo.');
      }
    }
    return ChangePreview.valid(batch.any((c) =>
        batch.any((other) => other.target != c.target && other.from == c.to)));
  }

  /// T-81: solo objetos pendientes de carga; se revisa de nuevo al guardar.
  MovementDraft move(Operation operation, Operator? actor,
      LoadingOperation data, List<PositionChange> changes, String reason) {
    _access(operation, actor, OperatorRole.office);
    final draft = MovementDraft.changePosition(operation.id, changes, reason);
    final error = draft.validate() ?? preview(data, actor, changes).error;
    if (error != null) throw StateError(error);
    return draft;
  }

  MovementDraft cancel(Operation operation, Operator? actor,
      LoadingOperation data, String key, String reason) {
    _access(operation, actor, OperatorRole.office);
    if (!pending(data, key)) {
      throw StateError(
          'Solo se cancela un objeto pendiente del plan de carga.');
    }
    final draft = MovementDraft.cancelItem(operation.id, key, reason);
    final error = draft.validate();
    if (error != null) throw StateError(error);
    return draft;
  }

  List<Movement> undoable(LoadingOperation data, String key) => data.movements
      .where((m) =>
          !data.state.voided.contains(m.id) &&
          (m.type == MovementType.cancelItem && m.target == key ||
              m.type == MovementType.changePosition &&
                  !m.payload.containsKey('request') &&
                  (PositionChange.readAll(m.payload['changes']) ?? const [])
                      .any((c) => c.target == key)))
      .toList()
    ..sort((a, b) => Movement.compareOrder(b, a));

  MovementDraft undo(Operation operation, Operator? actor,
      LoadingOperation data, String key, String movementId, String reason) {
    _access(operation, actor, OperatorRole.office);
    if (data.plan.loading[key]?.role != PlanRole.load ||
        !undoable(data, key).any((m) => m.id == movementId)) {
      throw StateError('El cambio de oficina ya no está vigente.');
    }
    if (reason.trim().isEmpty || reason.trim().length > 300) {
      throw StateError('Deshacer exige un motivo de hasta 300 caracteres.');
    }
    return MovementDraft.annul(operation.id, movementId, reason.trim(),
        target: key);
  }

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
    final batch = PositionChange.readAll(
      changes.map((c) => c.toJson()).toList(),
    );
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
        item.container?.isoSizeType ?? item.reservedSlot?.isoSizeType,
      );
      if (size != null && size != (coordinate.bay.isEven ? 40 : 20)) {
        return '${c.target} no cabe en la bahía ${coordinate.bay}.';
      }
      // T-105, 10.63: la par ocupa sus dos impares vecinas. Las posiciones
      // actuales y previstas se revisan aquí, también al aprobar solicitudes.
      // Los orígenes del propio lote no bloquean un intercambio atómico.
      for (final occupant in data.state.items.values) {
        final at = occupant.position;
        if (at == null ||
            targets.contains(occupant.key) ||
            occupant.kind == PlanItemKind.reservedSlot &&
                occupant.assignedContainer == null) {
          continue;
        }
        final other = IsoCoordinateParser.parse(at);
        if (_overlaps(coordinate, other)) {
          return _collision(
            coordinate,
            other,
            occupant.assignedContainer ?? occupant.key.substring(2),
            aboard: true,
          );
        }
      }
      for (final otherItem in data.plan.loading.values) {
        if (targets.contains(otherItem.key) ||
            otherItem.role == PlanRole.discharge ||
            data.state[otherItem.key]?.role == PlanRole.discharge) {
          continue;
        }
        final other = IsoCoordinateParser.parse(otherItem.plannedPosition);
        if (_overlaps(coordinate, other)) {
          return _collision(coordinate, other, _name(otherItem));
        }
      }
      // Excluir los orígenes no permite superponer los destinos del lote.
      for (final otherChange in batch.where((o) => o.target != c.target)) {
        final otherItem = data.plan.loading[otherChange.target];
        if (otherItem == null) continue;
        final other = IsoCoordinateParser.parse(otherChange.to);
        if (_overlaps(coordinate, other)) {
          return _collision(coordinate, other, _name(otherItem));
        }
      }
    }
    return null;
  }

  /// Huellas físicas, sin deducir la par de una impar (ALFA: 041 sola,
  /// 044 sobre 043 y 045). Fila y nivel deben coincidir exactamente.
  Set<int> _footprint(int bay) => bay.isOdd ? {bay} : {bay - 1, bay + 1};

  bool _overlaps(IsoCoordinate a, IsoCoordinate b) =>
      a.row == b.row &&
      a.tier == b.tier &&
      _footprint(a.bay).intersection(_footprint(b.bay)).isNotEmpty;

  String _shown(IsoCoordinate p) =>
      '${p.bayPadded} ${p.rowPadded} ${p.tierPadded}';

  String _name(PlanItem item) =>
      item.container?.containerId ??
      'la reserva ${_shown(IsoCoordinateParser.parse(item.plannedPosition))}';

  String _collision(
    IsoCoordinate destination,
    IsoCoordinate other,
    String name, {
    bool aboard = false,
  }) =>
      '${destination.toIsoCode()} choca con $name en ${other.toIsoCode()}: '
      '${destination.bay != other.bay ? 'un 40 ocupa las dos mitades de la celda. ' : ''}'
      '${aboard ? 'La celda está ocupada a bordo; marca primero su descarga.' : 'La celda está prevista para otro objeto; inclúyelo en el intercambio.'}';

  MovementDraft request(Operation operation, Operator? actor,
      LoadingOperation data, List<PositionChange> changes, String reason) {
    _access(operation, actor, OperatorRole.dock);
    final draft = MovementDraft.requestChange(operation.id, changes, reason);
    final error = draft.validate() ?? preview(data, actor, changes).error;
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

/// Resultado de la revisión; no registra ni modifica el plan.
class ChangePreview {
  final String? error;
  final bool isSwap;
  const ChangePreview.invalid(this.error) : isSwap = false;
  const ChangePreview.valid(this.isSwap) : error = null;
  bool get valid => error == null;
}
