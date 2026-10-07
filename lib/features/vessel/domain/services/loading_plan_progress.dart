import '../../../../core/utils/iso_coordinate_parser.dart';
import '../entities/entities.dart';
import 'export_list_cross_checker.dart';

/// Pendientes de carga: la bitácora decide el estado y el listado F/E.
class LoadingPlanProgress {
  final OperationPlan plan;
  final OperationState state;
  final ExportList? list;
  final Map<String, String> labels;
  final Map<int, BayLoadingPending> bays;
  final int unmatched;

  LoadingPlanProgress._(
      this.plan, this.state, this.list, this.labels, this.bays, this.unmatched);

  factory LoadingPlanProgress.build(VesselVoyage voyage, OperationState state,
      {ExportList? list}) {
    final plan = OperationPlan.build(
        loading: voyage,
        portOfCall: voyage.portOfCall!,
        geometry: voyage.geometry);
    final labels = <String, String>{};
    if (list != null) {
      for (final item
          in plan.loading.values.where((i) => i.role == PlanRole.load)) {
        final container = item.container;
        final row =
            container == null ? null : list.byContainer(container.containerId);
        if (row != null) labels[item.key] = 'OR ${row.order}';
      }
      final cross =
          ExportListCrossChecker.crossCheck(list, voyage, voyage.portOfCall!);
      for (final group in cross.groups.where((g) => g.empties.isNotEmpty)) {
        for (final slot in group.reservedSlots) {
          labels[slot.key] = '${group.type}\n${group.pod}\n${group.line}';
        }
      }
    }
    final bays = <int, BayLoadingPending>{};
    final plannedBays = plan.loading.values
        .where((i) => i.role == PlanRole.load)
        .map((i) => IsoCoordinateParser.parse(i.plannedPosition).bay)
        .toSet();
    var unmatched = 0;
    for (final item
        in plan.loading.values.where((i) => i.role == PlanRole.load)) {
      if (list != null && !labels.containsKey(item.key)) unmatched++;
      final position = IsoCoordinateParser.parse(item.plannedPosition);
      final key = position.bay.isEven && plannedBays.contains(position.bay - 1)
          ? position.bay - 1
          : position.bay;
      final bay = bays.putIfAbsent(key, () => BayLoadingPending(key));
      if (key != position.bay) bay.paired = true;
      // Conserva también las filas de la tabla al terminar la carga.
      if (state[item.key]?.state != ItemState.planned) continue;
      final row = item.container == null
          ? null
          : list?.byContainer(item.container!.containerId);
      final empty = item.kind == PlanItemKind.reservedSlot ||
          (row?.status ?? item.container?.status) == ContainerStatus.empty;
      bay.add(deck: plan.isDeckTier(position.tier), empty: empty);
    }
    return LoadingPlanProgress._(plan, state, list, Map.unmodifiable(labels),
        Map.unmodifiable(bays), unmatched);
  }

  String label(String key) => labels[key] ?? '—';
  BayLoadingPending? forBay(int number) {
    for (final bay in bays.values) {
      if (bay.bay == number || (bay.paired && bay.bay + 1 == number)) {
        return bay;
      }
    }
    return null;
  }

  int get deck => bays.values.fold(0, (sum, bay) => sum + bay.deck);
  int get hold => bays.values.fold(0, (sum, bay) => sum + bay.hold);
  int get full => bays.values.fold(0, (sum, bay) => sum + bay.full);
  int get empty => bays.values.fold(0, (sum, bay) => sum + bay.empty);
  int get total => deck + hold;
}

class BayLoadingPending {
  final int bay;
  bool paired = false;
  int deckFull = 0;
  int deckEmpty = 0;
  int holdFull = 0;
  int holdEmpty = 0;
  BayLoadingPending(this.bay);
  String get label => '${bay.toString().padLeft(2, '0')}'
      '${paired ? '/${(bay + 1).toString().padLeft(2, '0')}' : ''}';
  int get deck => deckFull + deckEmpty;
  int get hold => holdFull + holdEmpty;
  int get full => deckFull + holdFull;
  int get empty => deckEmpty + holdEmpty;
  void add({required bool deck, required bool empty}) {
    if (deck) {
      if (empty) {
        deckEmpty++;
      } else {
        deckFull++;
      }
    } else {
      if (empty) {
        holdEmpty++;
      } else {
        holdFull++;
      }
    }
  }
}
