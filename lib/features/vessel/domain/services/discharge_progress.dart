import '../../../../core/utils/iso_coordinate_parser.dart';
import '../entities/entities.dart';

/// T-75 · Cómo se ve cada contenedor del plano de llegada en el modo Descarga.
enum DischargeMark {
  /// Baja en esta escala y todavía no se marcó.
  pending,

  /// Ya se marcó como descargado.
  discharged,

  /// Sigue a bordo: su puerto de descarga no es esta escala.
  transit,

  /// Era de paso y salió para volver a estibarse (`restow: true`).
  restowed,

  /// La oficina lo canceló (T-81).
  cancelled,

  /// La bitácora lo deja en conflicto (T-79a 2.7.2).
  conflict,
}

/// T-75 · Pendientes de descarga, calculados con el estado derivado de T-72.
///
/// Se cuentan por bahía del BAPLIE, como el plano agrupa sus bahías, en
/// cubierta y bodega. Las re-estibas van aparte: no son parte de lo que baja.
class DischargeProgress {
  final OperationPlan plan;
  final OperationState state;

  /// Operación donde se registran los movimientos; nula si la escala todavía
  /// no tiene operación guardada (no se puede marcar).
  final String? operationId;

  /// Movimientos vigentes y anulados, por id: el detalle dice quién y cuándo.
  final Map<String, Movement> movements;
  final Map<int, BayDischargePending> bays;

  DischargeProgress._(
      this.plan, this.state, this.operationId, this.movements, this.bays);

  factory DischargeProgress.build(OperationPlan plan, OperationState state,
      {String? operationId, Iterable<Movement> movements = const []}) {
    final bays = <int, BayDischargePending>{};
    for (final item in plan.arrival.values) {
      final status = state[item.key];
      final c = IsoCoordinateParser.parse(item.plannedPosition);
      final deck = plan.isDeckTier(c.tier);
      if (item.role == PlanRole.discharge) {
        final bay = bays.putIfAbsent(c.bay, () => BayDischargePending(c.bay));
        switch (status?.state ?? ItemState.planned) {
          case ItemState.planned:
            deck ? bay.deckPending++ : bay.holdPending++;
          case ItemState.moved:
            bay.discharged++;
          case ItemState.cancelled:
            bay.cancelled++;
        }
      } else if (status != null &&
          status.restow &&
          status.state == ItemState.moved) {
        final bay = bays.putIfAbsent(c.bay, () => BayDischargePending(c.bay));
        deck ? bay.deckRestows++ : bay.holdRestows++;
      }
    }
    return DischargeProgress._(
        plan,
        state,
        operationId,
        Map.unmodifiable({for (final m in movements) m.id: m}),
        Map.unmodifiable(bays));
  }

  bool get canRegister => operationId != null;

  /// La marca de un contenedor del plano de llegada; nula si no está en él.
  DischargeMark? markOf(String containerId) {
    final item = plan.arrival['C:$containerId'];
    if (item == null) return null;
    final status = state['C:$containerId'];
    if (status == null) return null;
    if (status.inConflict) return DischargeMark.conflict;
    switch (status.state) {
      case ItemState.cancelled:
        return DischargeMark.cancelled;
      case ItemState.moved:
        return status.restow
            ? DischargeMark.restowed
            : DischargeMark.discharged;
      case ItemState.planned:
        return item.role == PlanRole.discharge
            ? DischargeMark.pending
            : DischargeMark.transit;
    }
  }

  ItemStatus? statusOf(String containerId) => state['C:$containerId'];

  /// El movimiento que dejó al contenedor como está, si lo hay.
  Movement? movementOf(String containerId) {
    final id = statusOf(containerId)?.movementId;
    return id == null ? null : movements[id];
  }

  /// Conflictos de la bitácora sobre lo que trae el plano de llegada.
  List<OperationConflict> get conflicts => state.conflicts
      .where((c) => plan.arrival.containsKey(c.key))
      .toList(growable: false);

  BayDischargePending? forBay(int number) => bays[number];

  int get deckPending => bays.values.fold(0, (s, b) => s + b.deckPending);
  int get holdPending => bays.values.fold(0, (s, b) => s + b.holdPending);
  int get pending => deckPending + holdPending;
  int get discharged => bays.values.fold(0, (s, b) => s + b.discharged);
  int get restows => bays.values.fold(0, (s, b) => s + b.restows);
}

class BayDischargePending {
  final int bay;
  int deckPending = 0;
  int holdPending = 0;
  int discharged = 0;
  int cancelled = 0;
  int deckRestows = 0;
  int holdRestows = 0;

  BayDischargePending(this.bay);

  String get label => bay.toString().padLeft(2, '0');
  int get pending => deckPending + holdPending;
  int get restows => deckRestows + holdRestows;
}
