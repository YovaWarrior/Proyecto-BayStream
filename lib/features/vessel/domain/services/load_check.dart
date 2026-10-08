import 'package:equatable/equatable.dart';

import '../../../../core/utils/iso_coordinate_parser.dart';
import '../entities/entities.dart';

/// T-77 · Lo que la revisión encuentra antes de confirmar una carga.
enum LoadIssueKind {
  /// Un 40 pies en una posición de 20, o al revés. No se registra.
  size,

  /// La celda no existe en la geometría del buque. No se registra.
  unknownCell,

  /// Un lleno fuera de su posición planificada. Pide motivo y queda
  /// «fuera de plan».
  outOfPlan,

  /// Un vacío en una reserva de otro grupo. Pide motivo y queda en conflicto.
  otherGroup,

  /// La celda la ocupa algo que no baja en esta escala. Pide motivo, como un
  /// «fuera de plan» (T-77, punto 3).
  cellTaken,

  /// El peso de la pila supera el límite del perfil. Pide motivo.
  stackWeight,
}

class LoadIssue extends Equatable {
  final LoadIssueKind kind;
  final String message;

  const LoadIssue(this.kind, this.message);

  /// Lo físicamente imposible no se registra, ni con motivo.
  bool get blocks =>
      kind == LoadIssueKind.size || kind == LoadIssueKind.unknownCell;

  @override
  List<Object?> get props => [kind, message];
}

enum StackWeightStatus { withinLimit, exceeded, notEvaluated }

/// Peso de la pila donde queda el contenedor, con él dentro. Es la pila de
/// T-67: bahía del BAPLIE, fila y zona; no suma las bahías vecinas.
class StackWeightCheck extends Equatable {
  final int bay;
  final int row;
  final bool deck;

  /// Suma de los pesos conocidos, el del contenedor que se carga incluido.
  final double knownKg;

  /// Contenedores de la pila sin ningún peso.
  final int missing;
  final double? limitKg;
  final StackWeightStatus status;

  const StackWeightCheck({
    required this.bay,
    required this.row,
    required this.deck,
    required this.knownKg,
    required this.missing,
    required this.limitKg,
    required this.status,
  });

  String get label => 'Pila de ${deck ? 'cubierta' : 'bodega'} '
      '${bay.toString().padLeft(3, '0')}, fila ${row.toString().padLeft(2, '0')}';

  String get message {
    final weight = '${(knownKg / 1000).toStringAsFixed(1)} t';
    final unweighed = missing == 1
        ? '1 contenedor de la pila no trae peso'
        : '$missing contenedores de la pila no traen peso';
    return switch (status) {
      StackWeightStatus.exceeded =>
        '$label: quedaría en $weight y el límite del perfil es '
            '${(limitKg! / 1000).toStringAsFixed(1)} t'
            '${missing > 0 ? '; $unweighed, el peso real es mayor' : ''}.',
      StackWeightStatus.withinLimit =>
        '$label: $weight de ${(limitKg! / 1000).toStringAsFixed(1)} t.',
      StackWeightStatus.notEvaluated => limitKg == null
          ? '$label: $weight. Peso no evaluado: el perfil no declara límite.'
          : '$label: $weight con los pesos conocidos. No evaluado: $unweighed.',
    };
  }

  @override
  List<Object?> get props =>
      [bay, row, deck, knownKg, missing, limitKg, status];
}

/// Resultado de la revisión de una carga, antes de escribir en la bitácora.
class LoadCheck extends Equatable {
  final String position;
  final List<LoadIssue> issues;
  final StackWeightCheck? stack;

  /// El contenedor de llegada que ocupa la celda, baja en esta escala y no
  /// se ha marcado. La pantalla ofrece «Marcar su descarga y cargar».
  final PlanItem? dischargeFirst;

  LoadCheck(
      {required this.position,
      Iterable<LoadIssue> issues = const [],
      this.stack,
      this.dischargeFirst})
      : issues = List.unmodifiable(issues);

  bool get blocked => issues.any((issue) => issue.blocks);

  /// Se registra solo con motivo escrito en `payload.reason`.
  bool get needsReason => !blocked && issues.isNotEmpty;

  /// Un aviso es todo lo que no deja confirmar con un toque.
  bool get warns => issues.isNotEmpty;

  @override
  List<Object?> get props => [position, issues, stack, dischargeFirst];
}

/// Largo nominal por el primer carácter del tipo ISO 6346: `2` es 20 pies;
/// `4` y los largos mayores (G, H, K, L, M, N, P: 41 a 53 pies) van en una
/// posición de 40. Otro código no se puede juzgar y devuelve null.
int? nominalLength(String? isoType) {
  if (isoType == null || isoType.isEmpty) return null;
  final code = isoType[0].toUpperCase();
  if (code == '2') return 20;
  if ('4GHKLMNP'.contains(code)) return 40;
  return null;
}

/// T-77 · Valida una carga contra el estado derivado del propio dispositivo
/// (T-79a 2.8): plan combinado, bitácora y perfil del buque.
class LoadValidator {
  final OperationPlan plan;
  final OperationState state;
  final VesselVoyage loading;
  final ExportList? list;

  const LoadValidator(
      {required this.plan,
      required this.state,
      required this.loading,
      this.list});

  /// [numbered] es el lleno (o el vacío con número, como el OR 85) que el
  /// plan trae en su celda; nulo para un vacío que va a una reserva.
  LoadCheck check(ExportListRow row, String position, {PlanItem? numbered}) {
    final coordinate = IsoCoordinateParser.tryParse(position);
    if (coordinate == null) {
      return LoadCheck(position: position, issues: [
        LoadIssue(LoadIssueKind.unknownCell,
            'La posición «$position» no tiene la forma BBB-RR-TT.')
      ]);
    }
    final shown = _shown(position);
    final issues = <LoadIssue>[];

    // 1. Lo que no se registra: la celda y el largo.
    final missing = _missingCell(coordinate);
    if (missing != null) {
      issues.add(LoadIssue(LoadIssueKind.unknownCell, missing));
      return LoadCheck(position: position, issues: issues);
    }
    final targetKey = numbered?.key ?? 'R:$position';
    final reservation = numbered == null ? plan.loading[targetKey] : null;
    final type = row.type;
    final length = nominalLength(type);
    final slotLength = coordinate.bay.isOdd ? 20 : 40;
    if (length != null && length != slotLength) {
      issues.add(LoadIssue(
          LoadIssueKind.size,
          'Un contenedor de $length pies ($type) no cabe en $shown: la bahía '
          '${coordinate.bayPadded} es ${coordinate.bay.isOdd ? 'impar, de 20' : 'par, de 40'} pies.'));
    }
    if (issues.isNotEmpty) return LoadCheck(position: position, issues: issues);

    // 2. Lo que se registra con motivo: posición, grupo y celda ocupada.
    if (numbered != null && numbered.plannedPosition != position) {
      final planned = plan.loadingItemAt(position);
      issues.add(LoadIssue(
          LoadIssueKind.outOfPlan,
          'OR ${row.order} está planificado en ${_shown(numbered.plannedPosition)}; '
          'en $shown quedará «fuera de plan»'
          '${planned != null && planned.key != numbered.key ? ', y $shown es la celda de ${_name(planned)}' : ''}.'));
    }
    final slot = reservation?.reservedSlot;
    if (numbered == null && slot != null) {
      final differences = [
        if (slot.isoSizeType != row.type) 'tipo ${slot.isoSizeType}',
        if (slot.portOfDischarge != row.pod) 'puerto ${slot.portOfDischarge}',
        if (slot.operatorCode != row.line) 'línea ${slot.operatorCode}',
      ];
      if (differences.isNotEmpty) {
        issues.add(LoadIssue(
            LoadIssueKind.otherGroup,
            'La reserva $shown es de otro grupo (${differences.join(', ')}); '
            'el OR ${row.order} es ${row.type} · ${row.pod} · ${row.line}.'));
      }
    }
    PlanItem? dischargeFirst;
    final occupant = _occupant(position, targetKey);
    if (occupant != null) {
      final arrival = plan.arrival[occupant.key];
      if (occupant.role == PlanRole.discharge &&
          occupant.state == ItemState.planned &&
          arrival != null) {
        dischargeFirst = arrival;
      } else {
        issues.add(LoadIssue(
            LoadIssueKind.cellTaken,
            '$shown la ocupa ${_occupantName(occupant)}, que no baja en '
            '${plan.portOfCall}: la celda está ocupada.'));
      }
    }

    // 3. El peso de la pila, con el contenedor dentro.
    final stack = _stack(coordinate, row, numbered, targetKey,
        leaving: dischargeFirst?.key);
    if (stack.status == StackWeightStatus.exceeded) {
      issues.add(LoadIssue(LoadIssueKind.stackWeight, stack.message));
    }
    return LoadCheck(
        position: position,
        issues: issues,
        stack: stack,
        dischargeFirst: dischargeFirst);
  }

  /// Bahías que el buque tiene: las de los dos planes y sus vecinas, porque
  /// una posición de 40 en la bahía par ocupa las dos impares que la forman.
  /// La geometría declarada no trae la lista de bahías; filas y niveles sí.
  String? _missingCell(IsoCoordinate c) {
    final bays = <int>{
      ...loading.bays.keys,
      for (final item in plan.arrival.values)
        IsoCoordinateParser.parse(item.plannedPosition).bay,
      for (final item in plan.loading.values)
        IsoCoordinateParser.parse(item.plannedPosition).bay,
    };
    final shown = _shown(c.toIsoCode());
    if (c.bay == 0 ||
        !(bays.contains(c.bay) ||
            bays.contains(c.bay - 1) ||
            bays.contains(c.bay + 1))) {
      return 'La bahía ${c.bayPadded} no existe en este buque: $shown no se puede registrar.';
    }
    final geometry = loading.geometry;
    if (geometry != null && !geometry.covers(c)) {
      return '$shown no existe en la geometría del buque (fila ${c.rowPadded}, '
          'nivel ${c.tierPadded}).';
    }
    return null;
  }

  ItemStatus? _occupant(String position, String targetKey) {
    for (final item in state.items.values) {
      if (item.position != position) continue;
      if (item.key == targetKey) {
        // La propia reserva ya tiene otro vacío.
        if (item.kind == PlanItemKind.reservedSlot &&
            item.assignedContainer != null) {
          return item;
        }
        continue;
      }
      if (item.kind == PlanItemKind.reservedSlot &&
          item.assignedContainer == null) {
        continue;
      }
      return item;
    }
    return null;
  }

  StackWeightCheck _stack(IsoCoordinate c, ExportListRow row,
      PlanItem? numbered, String targetKey,
      {String? leaving}) {
    final deck = plan.isDeckTier(c.tier);
    var known = 0.0;
    var missing = 0;
    void add(double? weight) {
      if (weight == null) {
        missing++;
      } else {
        known += weight;
      }
    }

    for (final item in state.items.values) {
      final at = item.position;
      if (at == null || item.key == targetKey || item.key == leaving) continue;
      final p = IsoCoordinateParser.parse(at);
      if (p.bay != c.bay || p.row != c.row || plan.isDeckTier(p.tier) != deck) {
        continue;
      }
      if (item.kind == PlanItemKind.reservedSlot &&
          item.assignedContainer == null) {
        continue;
      }
      add(_weight(item));
    }
    add(row.isEmpty
        ? row.tareKg
        : row.vgmKg ?? numbered?.container?.effectiveWeight);
    final limit = loading.geometry?.stackWeightLimitKg;
    final status = limit == null
        ? StackWeightStatus.notEvaluated
        : known > limit
            ? StackWeightStatus.exceeded
            : missing > 0
                ? StackWeightStatus.notEvaluated
                : StackWeightStatus.withinLimit;
    return StackWeightCheck(
        bay: c.bay,
        row: c.row,
        deck: deck,
        knownKg: known,
        missing: missing,
        limitKg: limit,
        status: status);
  }

  /// El peso del listado para lo que se cargó (VGM exacto del lleno, tara
  /// real del vacío); el del plan para lo que ya venía a bordo.
  double? _weight(ItemStatus item) {
    if (item.kind == PlanItemKind.reservedSlot) return item.tareKg;
    final id = item.key.substring(2);
    final listed = item.role == PlanRole.load ? list?.byContainer(id) : null;
    final fromList = listed == null
        ? null
        : listed.isEmpty
            ? listed.tareKg
            : listed.vgmKg;
    return fromList ??
        (plan.loading[item.key]?.container ?? plan.arrival[item.key]?.container)
            ?.effectiveWeight;
  }

  String _name(PlanItem item) {
    final id = item.container?.containerId;
    final order = id == null ? null : list?.byContainer(id)?.order;
    return order != null ? 'OR $order' : id ?? 'una reserva';
  }

  String _occupantName(ItemStatus item) => item.kind == PlanItemKind.reservedSlot
      ? 'el vacío ${item.assignedContainer}'
      : item.key.substring(2);

  static String _shown(String value) => value.length == 7
      ? '${value.substring(0, 3)}-${value.substring(3, 5)}-${value.substring(5)}'
      : value;
}
