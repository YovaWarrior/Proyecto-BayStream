import '../../../../core/utils/iso_coordinate_parser.dart';
import '../entities/entities.dart';
import 'export_list_cross_checker.dart';
import 'reference_bay.dart';

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
    final plan = state.effectivePlan ?? OperationPlan.build(
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
          final item = plan.loadingItemAt(slot.stowagePosition.toIsoCode());
          labels[item?.key ?? slot.key] = '${group.type}\n${group.pod}\n${group.line}';
        }
      }
    }
    final bays = <int, BayLoadingPending>{};
    var unmatched = 0;
    for (final item
        in plan.loading.values.where((i) => i.role == PlanRole.load)) {
      if (list != null && !labels.containsKey(item.key)) unmatched++;
      final position = IsoCoordinateParser.parse(item.plannedPosition);
      // T-122 (H5): la par es la bahía de referencia, con las bahías que el
      // plan dibuja, igual que `LoadingOperation.displayBay`.
      final key =
          referenceBay(position.bay, hasBay: voyage.bays.containsKey);
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

  /// T-75 · Lo que esta proyección deriva: la carga. Las descargas de T-75 y
  /// las anulaciones que las deshacen se dejan fuera, porque el plan de carga
  /// no trae el plano de llegada y las contaría como «fuera del plan».
  static List<Movement> loadingMovements(Iterable<Movement> movements) {
    final byId = {for (final m in movements) m.id: m};
    final excluded = <String>{
      for (final m in byId.values)
        if (m.type == MovementType.discharge) m.id
    };
    // Una anulación de una anulación de una descarga también es de descarga.
    var grew = true;
    while (grew) {
      grew = false;
      for (final m in byId.values) {
        if (m.type == MovementType.annul &&
            !excluded.contains(m.id) &&
            excluded.contains(m.annuls)) {
          excluded.add(m.id);
          grew = true;
        }
      }
    }
    return [
      for (final m in byId.values)
        if (!excluded.contains(m.id)) m
    ];
  }

  String label(String key) => labels[key] ?? '—';

  /// El grupo de [number]: el suyo o, para una impar, el de la par que la
  /// cubre si ese grupo existe (H5).
  BayLoadingPending? forBay(int number) =>
      bays[referenceBay(number, hasBay: bays.containsKey)];

  int get deck => bays.values.fold(0, (sum, bay) => sum + bay.deck);
  int get hold => bays.values.fold(0, (sum, bay) => sum + bay.hold);
  int get full => bays.values.fold(0, (sum, bay) => sum + bay.full);
  int get empty => bays.values.fold(0, (sum, bay) => sum + bay.empty);
  int get total => deck + hold;
}

class BayLoadingPending {
  final int bay;

  /// Verdadero si el grupo cuenta también alguna impar vecina (H5).
  bool paired = false;
  int deckFull = 0;
  int deckEmpty = 0;
  int holdFull = 0;
  int holdEmpty = 0;
  BayLoadingPending(this.bay);

  /// El grupo se rotula con su bahía de referencia, la par (H5).
  String get label => bay.toString().padLeft(2, '0');
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
