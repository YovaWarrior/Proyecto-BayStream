import '../entities/movement.dart';
import '../entities/operation.dart';

/// T-72 · Deriva el estado de la escala a partir del plan y la bitácora
/// (T-79a 2.7). Es una función pura: los mismos movimientos dan el mismo
/// estado en cualquier dispositivo, en cualquier orden de llegada.
///
/// Deriva descarga, carga, vacío, anular, corregir y cancelar. Los cambios
/// de posición (T-80) y las tapas (T-84) se guardan, pero aquí se cuentan
/// en [OperationState.notDerived] sin aplicarse.
class OperationStateDeriver {
  const OperationStateDeriver();

  OperationState derive(OperationPlan plan, Iterable<Movement> movements) {
    final byId = <String, Movement>{for (final m in movements) m.id: m};
    final voided = _voided(byId);
    final vigentes = byId.values.where((m) => !voided.contains(m.id)).toList()
      ..sort(Movement.compareOrder);
    return _Run(plan, voided).apply(vigentes);
  }

  /// Un movimiento queda sin efecto si otro vigente lo anula o lo corrige.
  /// Anular una anulación restaura el original. Las referencias apuntan
  /// siempre a algo que el autor ya tenía, así que no hay ciclos; aun así,
  /// un ciclo malformado no anula a nadie.
  Set<String> _voided(Map<String, Movement> byId) {
    final references = <String, List<String>>{};
    for (final m in byId.values) {
      final annuls = m.type == MovementType.annul ? m.annuls : null;
      final corrects = m.type.canCorrect ? m.corrects : null;
      for (final target in [annuls, corrects]) {
        if (target != null && target != m.id) {
          references.putIfAbsent(target, () => []).add(m.id);
        }
      }
    }
    final memo = <String, bool>{};
    bool isVoid(String id, Set<String> path) {
      final known = memo[id];
      if (known != null) return known;
      if (!path.add(id)) return false;
      final result = (references[id] ?? const <String>[])
          .any((by) => byId.containsKey(by) && !isVoid(by, path));
      path.remove(id);
      return memo[id] = result;
    }

    return {for (final id in byId.keys) if (isVoid(id, {})) id};
  }
}

class _Run {
  final OperationPlan plan;
  final Set<String> voided;
  final items = <String, ItemStatus>{};

  /// Posición → clave de lo que la ocupa ahora.
  final occupied = <String, String>{};

  /// Vacío → reserva donde quedó.
  final emptiesAssigned = <String, String>{};
  final conflicts = <OperationConflict>[];
  final duplicates = <String>[];
  final notDerived = <String>[];

  _Run(this.plan, this.voided) {
    final keys = {...plan.arrival.keys, ...plan.loading.keys};
    for (final key in keys) {
      final arrival = plan.arrival[key];
      final loading = plan.loading[key];
      final item = loading != null && loading.role == PlanRole.load
          ? loading
          : arrival != null && arrival.role == PlanRole.discharge
              ? arrival
              : (loading ?? arrival)!;
      // Lo que se carga aquí todavía no está a bordo; lo demás sí.
      final aboard = item.role == PlanRole.load ? null : item.plannedPosition;
      items[key] = ItemStatus(
        key: key,
        kind: item.kind,
        role: item.role,
        state: ItemState.planned,
        plannedPosition: item.plannedPosition,
        position: aboard,
      );
      if (aboard != null) occupied[aboard] = key;
    }
  }

  OperationState apply(List<Movement> vigentes) {
    for (final m in vigentes) {
      switch (m.type) {
        case MovementType.discharge:
          _discharge(m);
        case MovementType.loadFull:
          _loadFull(m);
        case MovementType.assignEmpty:
          _assignEmpty(m);
        case MovementType.cancelItem:
          _cancel(m);
        case MovementType.annul:
          break; // ya actuó en la vigencia
        case MovementType.requestChange:
        case MovementType.changePosition:
        case MovementType.rejectChange:
        case MovementType.hatchCover:
          notDerived.add(m.id);
      }
    }
    return OperationState(
      items: items,
      conflicts: conflicts,
      duplicates: duplicates,
      notDerived: notDerived,
      voided: voided,
      isDeckTier: plan.isDeckTier,
    );
  }

  void _conflict(ConflictKind kind, String key, Movement m, String message,
      {String? other}) {
    conflicts.add(OperationConflict(
        kind: kind, key: key, movementId: m.id, otherMovementId: other, message: message));
    final status = items[key];
    if (status != null) {
      items[key] = status.copyWith(conflicts: [...status.conflicts, kind]);
    }
  }

  void _discharge(Movement m) {
    final key = m.target!;
    final status = items[key];
    if (status == null || !plan.arrival.containsKey(key)) {
      _conflict(ConflictKind.notInPlan, key, m,
          '$key no está en el plano de llegada de esta escala.');
      return;
    }
    if (status.state == ItemState.cancelled) {
      _conflict(ConflictKind.cancelledItem, key, m, '$key está cancelado y se descargó.',
          other: status.movementId);
      return;
    }
    if (status.state == ItemState.moved && status.position == null) {
      duplicates.add(m.id);
      return;
    }
    final restow = m.payload['restow'] == true;
    if (status.position != null && occupied[status.position] == key) {
      occupied.remove(status.position);
    }
    items[key] = status.copyWith(
        state: ItemState.moved, clearPosition: true, restow: restow, movementId: m.id);
    if (status.role != PlanRole.discharge && !restow) {
      _conflict(ConflictKind.outOfPlan, key, m,
          '$key no descarga en ${plan.portOfCall}; si sale para volver a subir, es una re-estiba.');
    }
  }

  void _loadFull(Movement m) {
    final key = m.target!;
    final position = m.position!;
    var status = items[key];
    if (status == null) {
      // Lo que el muelle registró existe aunque el plan no lo traiga.
      final taken = occupied[position];
      if (taken != null) {
        _conflict(ConflictKind.cellTaken, key, m,
            '$position ya la ocupa ${taken.substring(2)}.',
            other: items[taken]?.movementId);
        return;
      }
      items[key] = ItemStatus(
          key: key,
          kind: PlanItemKind.container,
          role: PlanRole.load,
          state: ItemState.moved,
          position: position,
          order: m.payload['order'] as int?,
          seal: m.payload['seal'] as String?,
          movementId: m.id);
      occupied[position] = key;
      _conflict(ConflictKind.notInPlan, key, m,
          '${key.substring(2)} no está en el plan de carga de ${plan.portOfCall}.');
      return;
    }
    if (status.state == ItemState.cancelled) {
      _conflict(ConflictKind.cancelledItem, key, m, '$key está cancelado y se cargó.',
          other: status.movementId);
      return;
    }
    final reload = status.restow && status.state == ItemState.moved && status.position == null;
    if (status.role != PlanRole.load && !reload) {
      _conflict(ConflictKind.notInPlan, key, m,
          '${key.substring(2)} no se carga en ${plan.portOfCall}.');
      return;
    }
    if (status.role == PlanRole.load && status.state == ItemState.moved) {
      if (status.position == position) {
        duplicates.add(m.id);
      } else {
        _conflict(ConflictKind.movedTwice, key, m,
            '${key.substring(2)} ya se cargó en ${status.position}.',
            other: status.movementId);
      }
      return;
    }
    final taken = occupied[position];
    if (taken != null && taken != key) {
      _conflict(ConflictKind.cellTaken, key, m, '$position ya la ocupa ${taken.substring(2)}.',
          other: items[taken]?.movementId);
      return;
    }
    status = status.copyWith(
        state: ItemState.moved,
        position: position,
        order: m.payload['order'] as int?,
        seal: m.payload['seal'] as String?,
        movementId: m.id);
    items[key] = status;
    occupied[position] = key;
    if (!reload && status.plannedPosition != null && status.plannedPosition != position) {
      _conflict(ConflictKind.outOfPlan, key, m,
          '${key.substring(2)}: planificado en ${status.plannedPosition}, registrado en $position.');
    }
  }

  void _assignEmpty(Movement m) {
    final key = m.target!;
    final container = m.payload['container'] as String;
    final status = items[key];
    if (status == null || status.kind != PlanItemKind.reservedSlot) {
      _conflict(ConflictKind.notInPlan, key, m, '$key no es una celda reservada del plan.');
      return;
    }
    if (status.state == ItemState.cancelled) {
      _conflict(ConflictKind.cancelledItem, key, m, '$key está cancelada y se asignó.',
          other: status.movementId);
      return;
    }
    if (status.state == ItemState.moved) {
      if (status.assignedContainer == container) {
        duplicates.add(m.id);
      } else {
        _conflict(ConflictKind.cellTaken, key, m,
            '$key ya tiene asignado ${status.assignedContainer}.',
            other: status.movementId);
      }
      return;
    }
    final elsewhere = emptiesAssigned[container];
    if (elsewhere != null && elsewhere != key) {
      _conflict(ConflictKind.containerTwice, key, m, '$container ya está en $elsewhere.',
          other: items[elsewhere]?.movementId);
      return;
    }
    final position = status.plannedPosition!;
    final taken = occupied[position];
    if (taken != null && taken != key) {
      _conflict(ConflictKind.cellTaken, key, m, '$position ya la ocupa ${taken.substring(2)}.',
          other: items[taken]?.movementId);
      return;
    }
    items[key] = status.copyWith(
        state: ItemState.moved,
        position: position,
        assignedContainer: container,
        tareKg: (m.payload['tareKg'] as num?)?.toDouble(),
        order: m.payload['order'] as int?,
        seal: m.payload['seal'] as String?,
        movementId: m.id);
    occupied[position] = key;
    emptiesAssigned[container] = key;
  }

  void _cancel(Movement m) {
    final key = m.target!;
    final status = items[key];
    if (status == null) {
      _conflict(ConflictKind.notInPlan, key, m, '$key no está en el plan de esta escala.');
      return;
    }
    if (status.state == ItemState.cancelled) {
      duplicates.add(m.id);
      return;
    }
    if (status.state == ItemState.moved) {
      _conflict(ConflictKind.cancelledItem, key, m,
          '$key ya se movió; para cancelarlo, anula antes ese movimiento.',
          other: status.movementId);
      return;
    }
    items[key] = status.copyWith(state: ItemState.cancelled, movementId: m.id);
  }
}
