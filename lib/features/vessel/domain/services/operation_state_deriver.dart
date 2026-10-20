import '../entities/movement.dart';
import '../entities/operation.dart';
import '../entities/hatch_covers.dart';
import '../../../../core/utils/iso_coordinate_parser.dart';

/// T-72 · Deriva el estado de la escala a partir del plan y la bitácora
/// (T-79a 2.7). Es una función pura: los mismos movimientos dan el mismo
/// estado en cualquier dispositivo, en cualquier orden de llegada.
///
/// T-80: primero obtiene el plan efectivo; después evalúa las operaciones
/// contra ese plan final, incluso si la aprobación se registró más tarde.
class OperationStateDeriver {
  const OperationStateDeriver();

  OperationState derive(OperationPlan plan, Iterable<Movement> movements) {
    final byId = <String, Movement>{for (final m in movements) m.id: m};
    final voided = _voided(byId);
    final vigentes = byId.values.where((m) => !voided.contains(m.id)).toList()
      ..sort(Movement.compareOrder);
    final changes = _PlanChanges(plan, vigentes)..apply();
    return _Run(changes.plan, voided, changes: changes).apply(vigentes);
  }

  /// Un movimiento queda sin efecto si otro vigente lo anula o lo corrige.
  /// Una corrección sustituye toda su cadena anterior; anular la última
  /// restaura la corrección previa. Anular una anulación restaura el original.
  /// Las referencias apuntan
  /// siempre a algo que el autor ya tenía, así que no hay ciclos; aun así,
  /// un ciclo malformado no anula a nadie.
  Set<String> _voided(Map<String, Movement> byId) {
    final references = <String, List<String>>{};
    for (final m in byId.values) {
      final annuls = m.type == MovementType.annul ? m.annuls : null;
      if (annuls != null && annuls != m.id) {
        references.putIfAbsent(annuls, () => []).add(m.id);
      }
      var target = m.type.canCorrect ? m.corrects : null;
      final visited = {m.id};
      while (target != null && visited.add(target)) {
        references.putIfAbsent(target, () => []).add(m.id);
        final previous = byId[target];
        target = previous != null && previous.type.canCorrect
            ? previous.corrects
            : null;
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

/// T-107 · El objeto como lo ve el planner, con el formato de T-106 y sin
/// la clave interna: «OR 7 · TSTU0000017», el número solo si no tiene orden,
/// o «la reserva 005 02 82». El plan no trae el listado, así que el orden es
/// el que registró el movimiento.
String _shown(String key, {int? order}) {
  if (key.startsWith('R:')) {
    final p = IsoCoordinateParser.tryParse(key.substring(2));
    return p == null
        ? 'la reserva ${key.substring(2)}'
        : 'la reserva ${p.bayPadded} ${p.rowPadded} ${p.tierPadded}';
  }
  final id = key.startsWith('C:') ? key.substring(2) : key;
  return order == null ? id : 'OR $order · $id';
}

String _capital(String text) =>
    text.isEmpty ? text : '${text[0].toUpperCase()}${text.substring(1)}';

class _PlanChanges {
  OperationPlan plan;
  final List<Movement> movements;
  final requests = <String, ChangeRequest>{};
  final conflicts = <OperationConflict>[];
  _PlanChanges(this.plan, this.movements);

  void problem(Movement m, String message, {String key = ''}) {
    // T-112: la acción va con el conflicto.
    conflicts.add(OperationConflict(kind: ConflictKind.invalidChange,
        key: key,
        movementId: m.id,
        message: '$message Revísalo en la bandeja de cambios de la oficina.'));
  }

  void apply() {
    for (final m in movements.where((m) => m.type == MovementType.requestChange)) {
      final valid = PositionChange.readAll(m.payload['changes']) != null;
      requests[m.id] = ChangeRequest(m,
          valid ? ChangeRequestStatus.pending : ChangeRequestStatus.conflict);
      if (!valid) {
        problem(m, 'Solicitud con cambios inválidos: no trae de uno a cuatro '
            'cambios válidos.');
      }
    }
    for (final m in movements) {
      if (m.type != MovementType.changePosition && m.type != MovementType.rejectChange) continue;
      final reference = m.payload['request'];
      final request = requests[reference];
      if (reference != null && request == null) {
        problem(m, 'La decisión cita una solicitud que no está vigente.');
        continue;
      }
      if (request != null && request.status != ChangeRequestStatus.pending) {
        problem(m, 'La solicitud ya tiene una decisión o está en conflicto.');
        continue;
      }
      if (m.type == MovementType.rejectChange) {
        if (request == null) {
          problem(m, 'El rechazo no cita una solicitud.');
        } else {
          requests[request.movement.id] = ChangeRequest(request.movement,
              ChangeRequestStatus.rejected, decision: m);
        }
        continue;
      }
      final batch = PositionChange.readAll(m.payload['changes']);
      String? error;
      String key = '';
      if (batch == null) {
        error = 'El cambio no contiene de uno a cuatro cambios válidos.';
      } else if (request != null &&
          (batch.length != request.changes.length ||
              !batch.every((c) => request.changes.contains(c)))) {
        error = 'La aprobación no coincide con lo solicitado.';
      } else {
        final targets = batch.map((c) => c.target).toSet();
        for (final c in batch) {
          key = c.target;
          final item = plan.loading[c.target];
          if (item == null) {
            error = '${_capital(_shown(c.target))} no está en el plan de carga.';
          } else if (item.plannedPosition != c.from) {
            error = '${_capital(_shown(c.target))}: origen obsoleto; plan efectivo ${item.plannedPosition}, cambio desde ${c.from}.';
          } else if (plan.loading.values.any((i) =>
              !targets.contains(i.key) && i.plannedPosition == c.to)) {
            error = '${c.to} está prevista para otro objeto del plan.';
          }
          if (error != null) break;
        }
      }
      if (error != null) {
        problem(m, error, key: key);
      } else {
        // Todo el lote se comprueba antes de aplicar: un intercambio es atómico.
        plan = plan.withPositions({for (final c in batch!) c.target: c.to});
      }
      if (request != null) {
        requests[request.movement.id] = ChangeRequest(request.movement,
            error == null ? ChangeRequestStatus.approved : ChangeRequestStatus.conflict,
            decision: m);
      }
    }
  }
}

class _Run {
  final OperationPlan plan;
  final Set<String> voided;
  final _PlanChanges? changes;
  final items = <String, ItemStatus>{};
  final hatchCovers = <String, HatchCoverStatus>{};

  /// Posición → clave de lo que la ocupa ahora.
  final occupied = <String, String>{};

  /// Vacío → reserva donde quedó.
  final emptiesAssigned = <String, String>{};
  final conflicts = <OperationConflict>[];
  final duplicates = <String>[];
  final notDerived = <String>[];

  /// T-107 · El sujeto del aviso, al principio de la frase.
  String _name(String key) =>
      _capital(_shown(key, order: items[key]?.order));

  /// T-107 · Lo que ocupa una celda: una reserva con vacío asignado se nombra
  /// por su contenedor, como en T-106.
  String _occupant(String key) {
    final status = items[key];
    final assigned = status?.assignedContainer;
    return assigned == null
        ? _shown(key, order: status?.order)
        : _shown(assigned, order: status?.order);
  }

  _Run(this.plan, this.voided, {this.changes}) {
    for (final entry in plan.hatchCovers.entries) {
      for (var i = 0; i < entry.value.covers.length; i++) {
        final cover = HatchCoverStatus(bay: entry.key, number: i + 1,
            kind: entry.value.kind, rows: entry.value.covers[i]);
        hatchCovers[cover.key] = cover;
      }
    }
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
    for (final conflict in changes?.conflicts ?? const <OperationConflict>[]) {
      conflicts.add(conflict);
      final status = items[conflict.key];
      if (status != null) {
        items[conflict.key] = status.copyWith(
            conflicts: [...status.conflicts, conflict.kind]);
      }
    }
    // T-76: el ocupante de llegada deja libre su celda si tiene una
    // descarga vigente, aunque otro dispositivo haya registrado antes la
    // carga. Solo anticipamos la liberación: la descarga conserva su lugar
    // en el orden total, sus duplicados, cancelaciones y posibles conflictos.
    final departures = _Run(plan, voided);
    for (final movement in vigentes) {
      if (movement.type == MovementType.discharge) {
        departures._discharge(movement);
      } else if (movement.type == MovementType.cancelItem &&
          plan.arrival.containsKey(movement.target)) {
        departures._cancel(movement);
      }
    }
    for (final arrival in plan.arrival.values) {
      final departure = departures.items[arrival.key];
      if (departure?.state == ItemState.moved &&
          departure?.position == null &&
          occupied[arrival.plannedPosition] == arrival.key) {
        occupied.remove(arrival.plannedPosition);
      }
    }
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
          break; // primera pasada
        case MovementType.hatchCover:
          _hatchCover(m);
      }
    }
    return OperationState(
      hatchCovers: hatchCovers,
      effectivePlan: plan,
      requests: changes?.requests.values ?? const [],
      items: items,
      conflicts: conflicts,
      duplicates: duplicates,
      notDerived: notDerived,
      voided: voided,
      isDeckTier: plan.isDeckTier,
    );
  }

  void _hatchCover(Movement m) {
    final cover = hatchCovers[m.target];
    final action = m.payload['action'];
    if (cover == null || !['remove', 'replace'].contains(action)) {
      _conflict(ConflictKind.invalidHatchCover, m.target ?? '', m,
          '${m.target}: tapa sin declarar o acción inválida.');
      return;
    }
    final remove = action == 'remove';
    if (cover.removed == remove) {
      _conflict(ConflictKind.invalidHatchCover, cover.key, m,
          'Bahía ${cover.bay} · ${cover.label}: '
          '${remove ? 'ya está quitada' : 'no está quitada para reponerla'}.',
          other: cover.movementId);
      return;
    }
    hatchCovers[cover.key] = cover.operated(remove, m.id);
  }

  void _conflict(ConflictKind kind, String key, Movement m, String message,
      {String? other, bool remedy = true}) {
    conflicts.add(OperationConflict(
        kind: kind,
        key: key,
        movementId: m.id,
        otherMovementId: other,
        message: remedy ? '$message ${_remedy(m)}' : message));
    final status = items[key];
    if (status != null) {
      items[key] = status.copyWith(conflicts: [...status.conflicts, kind]);
    }
  }

  /// T-112: qué hacer con un conflicto, según el registro que lo produjo y
  /// el botón que lo deshace en su pantalla.
  static String _remedy(Movement m) => switch (m.type) {
        MovementType.hatchCover =>
          'Si el registro fue un error, deshazlo con «Deshacer conflicto».',
        MovementType.discharge =>
          'Si el registro fue un error, deshazlo desde el detalle del contenedor.',
        MovementType.cancelItem =>
          'Si la cancelación fue un error, la oficina la deshace desde el detalle '
              'de la celda.',
        _ => 'Si el registro fue un error, deshazlo desde el detalle de la celda.',
      };

  void _discharge(Movement m) {
    final key = m.target!;
    final status = items[key];
    if (status == null || !plan.arrival.containsKey(key)) {
      _conflict(ConflictKind.notInPlan, key, m,
          '${_name(key)} no está en el plano de llegada de esta escala.');
      return;
    }
    if (status.state == ItemState.cancelled) {
      _conflict(ConflictKind.cancelledItem, key, m, '${_name(key)} está cancelado y se descargó.',
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
          '${_name(key)} no descarga en ${plan.portOfCall}; si sale para volver a subir, es una re‑estiba.');
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
            '$position ya la ocupa ${_occupant(taken)}.',
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
          '${_name(key)} no está en el plan de carga de ${plan.portOfCall}.');
      return;
    }
    if (status.state == ItemState.cancelled) {
      _conflict(ConflictKind.cancelledItem, key, m, '${_name(key)} está cancelado y se cargó.',
          other: status.movementId);
      return;
    }
    final reload = status.restow && status.state == ItemState.moved && status.position == null;
    if (status.role != PlanRole.load && !reload) {
      _conflict(ConflictKind.notInPlan, key, m,
          '${_name(key)} no se carga en ${plan.portOfCall}.');
      return;
    }
    if (status.role == PlanRole.load && status.state == ItemState.moved) {
      if (status.position == position) {
        duplicates.add(m.id);
      } else {
        _conflict(ConflictKind.movedTwice, key, m,
            '${_name(key)} ya se cargó en ${status.position}.',
            other: status.movementId);
      }
      return;
    }
    final taken = occupied[position];
    if (taken != null && taken != key) {
      _conflict(ConflictKind.cellTaken, key, m, '$position ya la ocupa ${_occupant(taken)}.',
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
          '${_name(key)}: planificado en ${status.plannedPosition}, registrado en $position.');
    }
  }

  void _assignEmpty(Movement m) {
    final key = m.target!;
    final container = m.payload['container'] as String;
    final status = items[key];
    if (status == null || status.kind != PlanItemKind.reservedSlot) {
      _conflict(ConflictKind.notInPlan, key, m, '${_name(key)} no es una celda reservada del plan.');
      return;
    }
    if (status.state == ItemState.cancelled) {
      _conflict(ConflictKind.cancelledItem, key, m, '${_name(key)} está cancelada y se asignó.',
          other: status.movementId);
      return;
    }
    if (status.state == ItemState.moved) {
      if (status.assignedContainer == container) {
        duplicates.add(m.id);
      } else {
        _conflict(ConflictKind.cellTaken, key, m,
            '${_name(key)} ya tiene asignado ${status.assignedContainer}.',
            other: status.movementId);
      }
      return;
    }
    final elsewhere = emptiesAssigned[container];
    if (elsewhere != null && elsewhere != key) {
      _conflict(ConflictKind.containerTwice, key, m, '$container ya está en ${_shown(elsewhere)}.',
          other: items[elsewhere]?.movementId);
      return;
    }
    final position = status.plannedPosition!;
    final taken = occupied[position];
    if (taken != null && taken != key) {
      _conflict(ConflictKind.cellTaken, key, m, '$position ya la ocupa ${_occupant(taken)}.',
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
    // T-77: lo que T-77 dejó pasar con motivo, u otro dispositivo sin aviso,
    // queda asignado pero a la vista. Sin listado no se sabe el grupo.
    final group = plan.emptyGroups[container];
    final slot = plan.loading[key]?.reservedSlot;
    if (group != null &&
        slot != null &&
        (group.type != slot.isoSizeType ||
            group.pod != slot.portOfDischarge ||
            group.line != slot.operatorCode)) {
      _conflict(ConflictKind.otherGroup, key, m,
          '$container (${group.type} · ${group.pod} · ${group.line}) quedó en una '
          'reserva de ${slot.isoSizeType} · ${slot.portOfDischarge} · ${slot.operatorCode}.');
    }
  }

  void _cancel(Movement m) {
    final key = m.target!;
    final status = items[key];
    if (status == null) {
      _conflict(ConflictKind.notInPlan, key, m, '${_name(key)} no está en el plan de esta escala.');
      return;
    }
    if (status.state == ItemState.cancelled) {
      duplicates.add(m.id);
      return;
    }
    if (status.state == ItemState.moved) {
      _conflict(ConflictKind.cancelledItem, key, m,
          '${_name(key)} ya se movió; para cancelarlo, anula antes ese movimiento.',
          other: status.movementId,
          remedy: false);
      return;
    }
    items[key] = status.copyWith(state: ItemState.cancelled, movementId: m.id);
  }
}
