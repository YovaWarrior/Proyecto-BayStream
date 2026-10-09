import '../../../../core/utils/iso_coordinate_parser.dart';
import '../entities/entities.dart';
import 'load_check.dart';
import 'loading_operation.dart';

/// T-78: proyección de solo lectura. No guarda ni vuelve a aplicar movimientos.
class OperationProgress {
  final List<BayOperationProgress> bays;
  final BayOperationProgress total;
  final List<ProgressConflict> conflicts;
  final List<StackWeightCheck> stacks;
  final Movement? last;

  OperationProgress._(
      this.bays, this.total, this.conflicts, this.stacks, this.last);

  factory OperationProgress.build(LoadingOperation operation) {
    final plan = operation.plan;
    final state = operation.state;
    final rows = <int, BayOperationProgress>{};
    BayOperationProgress row(String position) {
      final physical = IsoCoordinateParser.parse(position).bay;
      final bay = operation.displayBay(physical);
      final value = rows.putIfAbsent(bay, () => BayOperationProgress(bay));
      if (physical != bay) value.paired = true;
      return value;
    }

    final total = BayOperationProgress(0);
    for (final item in state.items.values) {
      if (item.role == PlanRole.transit && !item.restow) continue;
      final at = item.state == ItemState.moved
          ? item.position ?? item.plannedPosition
          : item.plannedPosition;
      if (at == null) continue;
      final c = IsoCoordinateParser.parse(at);
      final source = plan.loading[item.key] ?? plan.arrival[item.key];
      final listed = source?.container == null
          ? null
          : operation.list?.byContainer(source!.container!.containerId);
      final empty = item.kind == PlanItemKind.reservedSlot ||
          (listed?.status ?? source?.container?.status) ==
              ContainerStatus.empty;
      for (final target in [row(at), total]) {
        target._add(item, deck: plan.isDeckTier(c.tier), empty: empty);
      }
    }

    final events = {for (final m in operation.movements) m.id: m};
    final conflicts = <ProgressConflict>[];
    for (final conflict in state.conflicts) {
      final movement = events[conflict.movementId];
      final item = state[conflict.key];
      final position =
          movement?.position ?? item?.position ?? item?.plannedPosition;
      conflicts.add(ProgressConflict(conflict, position, movement));
      if (position != null) row(position).conflicts++;
      total.conflicts++;
    }
    final ordered = events.values.toList()..sort(Movement.compareOrder);
    String? positionOf(Movement m, Set<String> visited) {
      if (!visited.add(m.id)) return null;
      final predecessor = events[m.annuls];
      return m.position ??
          (m.target == null ? null : state[m.target!]?.plannedPosition) ??
          (predecessor == null ? null : positionOf(predecessor, visited));
    }

    for (final movement in ordered) {
      final position = positionOf(movement, {});
      if (position != null) row(position).last = movement;
    }
    total.last = ordered.isEmpty ? null : ordered.last;

    // Pilas físicas: solo lo que sigue a bordo. Nunca se mezclan bahías vecinas.
    final weights =
        <({int bay, int row, bool deck}), ({double kg, int missing})>{};
    for (final item in state.items.values) {
      final at = item.position;
      if (at == null ||
          (item.kind == PlanItemKind.reservedSlot &&
              item.assignedContainer == null)) {
        continue;
      }
      final c = IsoCoordinateParser.parse(at);
      final key = (bay: c.bay, row: c.row, deck: plan.isDeckTier(c.tier));
      final listed =
          item.role == PlanRole.load && item.kind == PlanItemKind.container
              ? operation.list?.byContainer(item.key.substring(2))
              : null;
      final weight = item.kind == PlanItemKind.reservedSlot
          ? item.tareKg
          : (listed == null
                  ? null
                  : listed.isEmpty
                      ? listed.tareKg
                      : listed.vgmKg) ??
              (plan.loading[item.key]?.container ??
                      plan.arrival[item.key]?.container)
                  ?.effectiveWeight;
      final previous = weights[key] ?? (kg: 0.0, missing: 0);
      weights[key] = (
        kg: previous.kg + (weight ?? 0),
        missing: previous.missing + (weight == null ? 1 : 0)
      );
    }
    final limit = operation.loading.geometry?.stackWeightLimitKg;
    final stacks = [
      for (final entry in weights.entries)
        StackWeightCheck(
            bay: entry.key.bay,
            row: entry.key.row,
            deck: entry.key.deck,
            knownKg: entry.value.kg,
            missing: entry.value.missing,
            limitKg: limit,
            status: limit == null
                ? StackWeightStatus.notEvaluated
                : entry.value.kg > limit
                    ? StackWeightStatus.exceeded
                    : entry.value.missing > 0
                        ? StackWeightStatus.notEvaluated
                        : StackWeightStatus.withinLimit)
    ]..sort((a, b) {
        var result = a.bay.compareTo(b.bay);
        if (result == 0) result = a.row.compareTo(b.row);
        if (result == 0) {
          result = a.deck == b.deck
              ? 0
              : a.deck
                  ? 1
                  : -1;
        }
        return result;
      });
    final sorted = rows.values.toList()..sort((a, b) => a.bay.compareTo(b.bay));
    return OperationProgress._(List.unmodifiable(sorted), total,
        List.unmodifiable(conflicts), List.unmodifiable(stacks), total.last);
  }
}

class BayOperationProgress {
  final int bay;
  bool paired = false;
  ProgressCount dischargeDeck = const ProgressCount();
  ProgressCount dischargeHold = const ProgressCount();
  ProgressCount fullDeck = const ProgressCount();
  ProgressCount fullHold = const ProgressCount();
  ProgressCount emptyDeck = const ProgressCount();
  ProgressCount emptyHold = const ProgressCount();
  int restows = 0;
  int conflicts = 0;
  Movement? last;
  BayOperationProgress(this.bay);
  String get label => '${bay.toString().padLeft(2, '0')}'
      '${paired ? '/${(bay + 1).toString().padLeft(2, '0')}' : ''}';
  int get dischargePending => dischargeDeck.pending + dischargeHold.pending;
  int get discharged => dischargeDeck.moved + dischargeHold.moved;
  int get fullPending => fullDeck.pending + fullHold.pending;
  int get fullLoaded => fullDeck.moved + fullHold.moved;
  int get emptyPending => emptyDeck.pending + emptyHold.pending;
  int get emptyLoaded => emptyDeck.moved + emptyHold.moved;
  int get cancelled =>
      dischargeDeck.cancelled +
      dischargeHold.cancelled +
      fullDeck.cancelled +
      fullHold.cancelled +
      emptyDeck.cancelled +
      emptyHold.cancelled;

  void _add(ItemStatus item, {required bool deck, required bool empty}) {
    if (item.restow) {
      if (item.state == ItemState.moved) restows++;
      return;
    }
    if (item.role == PlanRole.discharge) {
      if (deck) {
        dischargeDeck = dischargeDeck.add(item.state);
      } else {
        dischargeHold = dischargeHold.add(item.state);
      }
    } else if (empty) {
      if (deck) {
        emptyDeck = emptyDeck.add(item.state);
      } else {
        emptyHold = emptyHold.add(item.state);
      }
    } else {
      if (deck) {
        fullDeck = fullDeck.add(item.state);
      } else {
        fullHold = fullHold.add(item.state);
      }
    }
  }
}

class ProgressConflict {
  final OperationConflict conflict;
  final String? position;
  final Movement? movement;
  const ProgressConflict(this.conflict, this.position, this.movement);
}

class OperationCellLink {
  final String key;
  final String displayKey;
  final String position;
  final PlanRole role;
  const OperationCellLink(this.key, this.position, this.role,
      {String? displayKey})
      : displayKey = displayKey ?? key;
}
