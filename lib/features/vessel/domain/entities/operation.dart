import 'package:equatable/equatable.dart';

import '../../../../core/utils/iso_coordinate_parser.dart';
import 'container_unit.dart';
import 'export_list.dart';
import 'reserved_slot.dart';
import 'vessel_geometry.dart';
import 'vessel_voyage.dart';

/// T-72 · Una operación es una escala: un buque, un viaje y un puerto (T-79a 2.1).
/// Lleva el texto de sus fuentes para abrirse sin red ni archivo.
class Operation extends Equatable {
  final String id;
  final String vesselName;
  final String voyageNumber;
  final String portOfCall;
  final DateTime createdAt;
  final List<OperationSource> sources;

  Operation({
    required this.id,
    required this.vesselName,
    required this.voyageNumber,
    required this.portOfCall,
    required this.createdAt,
    Iterable<OperationSource> sources = const [],
  }) : sources = List.unmodifiable(sources);

  OperationSource? source(OperationSourceKind kind) {
    for (final s in sources) {
      if (s.kind == kind) return s;
    }
    return null;
  }

  @override
  List<Object?> get props => [id, vesselName, voyageNumber, portOfCall, createdAt, sources];

  /// [includeContent] en falso deja solo el nombre de cada fuente: es lo que
  /// lleva la exportación de la bitácora.
  Map<String, dynamic> toJson({bool includeContent = true}) => {
        'id': id,
        'vessel': vesselName,
        'voyage': voyageNumber,
        'portOfCall': portOfCall,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'sources': sources.map((s) => s.toJson(includeContent: includeContent)).toList(),
      };

  factory Operation.fromJson(Map<String, dynamic> json) => Operation(
        id: json['id'] as String,
        vesselName: json['vessel'] as String,
        voyageNumber: json['voyage'] as String,
        portOfCall: json['portOfCall'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        sources: (json['sources'] as List<dynamic>? ?? const [])
            .map((s) => OperationSource.fromJson(Map<String, dynamic>.from(s as Map))),
      );
}

enum OperationSourceKind {
  arrivalBaplie('arrival_baplie'),
  loadingBaplie('loading_baplie'),
  exportList('export_list');

  const OperationSourceKind(this.wire);
  final String wire;
}

class OperationSource extends Equatable {
  final OperationSourceKind kind;
  final String fileName;

  /// Texto del archivo. Vacío en la exportación de la bitácora.
  final String content;

  const OperationSource({required this.kind, required this.fileName, this.content = ''});

  @override
  List<Object?> get props => [kind, fileName, content];

  Map<String, dynamic> toJson({bool includeContent = true}) => {
        'kind': kind.wire,
        'fileName': fileName,
        if (includeContent) 'content': content,
      };

  factory OperationSource.fromJson(Map<String, dynamic> json) => OperationSource(
        kind: OperationSourceKind.values.firstWhere((k) => k.wire == json['kind']),
        fileName: json['fileName'] as String,
        content: json['content'] as String? ?? '',
      );
}

/// Papel de un objeto en la escala, según el puerto de escala.
enum PlanRole {
  /// Baja aquí (plano de llegada, descarga en la escala).
  discharge,

  /// Sube aquí (plan de carga, carga en la escala).
  load,

  /// Ya venía a bordo y sigue: no se opera.
  transit,
}

enum PlanItemKind { container, reservedSlot }

/// Un objeto del plan con su clave natural (T-79a 2.2). Nunca usa el `id`
/// de `ContainerUnit`, que es un UUID nuevo en cada lectura del archivo.
class PlanItem extends Equatable {
  final String key;
  final PlanItemKind kind;
  final PlanRole role;

  /// Posición del plan publicado, `BBBRRTT` de 7 cifras.
  final String plannedPosition;
  final ContainerUnit? container;
  final ReservedSlot? reservedSlot;

  const PlanItem({
    required this.key,
    required this.kind,
    required this.role,
    required this.plannedPosition,
    this.container,
    this.reservedSlot,
  });

  @override
  List<Object?> get props => [key, kind, role, plannedPosition];
}

/// T-72 · El plan combinado de la escala: lo que llega (A07), lo que sale
/// (A08) y sus reservas (T-69). Cada objeto se busca por su clave natural.
class OperationPlan {
  final String portOfCall;

  /// Contenedores del plano de llegada, por clave `C:`.
  final Map<String, PlanItem> arrival;

  /// Contenedores y reservas del plan de carga, por clave `C:` o `R:`.
  final Map<String, PlanItem> loading;

  /// Frontera cubierta/bodega de la geometría declarada; por defecto, la
  /// del ancla de cubierta (nivel 80) que usa `VesselGeometry`.
  final bool Function(int tier) isDeckTier;

  /// T-77 · Grupo de cada vacío del listado (tipo, puerto y línea, ya
  /// traducidos), por número de contenedor. El listado es una fuente de la
  /// operación, así que todos los dispositivos ven el mismo «vacío de otro
  /// grupo». Vacío si la operación todavía no tiene listado.
  final Map<String, ({String type, String pod, String line})> emptyGroups;

  OperationPlan._(this.portOfCall, this.arrival, this.loading, this.isDeckTier,
      this.emptyGroups);

  factory OperationPlan.build({
    required String portOfCall,
    VesselVoyage? arrival,
    VesselVoyage? loading,
    VesselGeometry? geometry,
    ExportList? list,
  }) {
    final arrivalItems = <String, PlanItem>{};
    for (final c in arrival?.containers ?? const <ContainerUnit>[]) {
      final position = c.stowagePosition;
      if (position == null) continue;
      arrivalItems['C:${c.containerId}'] = PlanItem(
        key: 'C:${c.containerId}',
        kind: PlanItemKind.container,
        role: c.portOfDischarge == portOfCall ? PlanRole.discharge : PlanRole.transit,
        plannedPosition: position.toIsoCode(),
        container: c,
      );
    }
    final loadingItems = <String, PlanItem>{};
    for (final c in loading?.containers ?? const <ContainerUnit>[]) {
      final position = c.stowagePosition;
      if (position == null) continue;
      loadingItems['C:${c.containerId}'] = PlanItem(
        key: 'C:${c.containerId}',
        kind: PlanItemKind.container,
        role: c.portOfLoading == portOfCall ? PlanRole.load : PlanRole.transit,
        plannedPosition: position.toIsoCode(),
        container: c,
      );
    }
    for (final r in loading?.reservedSlots ?? const <ReservedSlot>[]) {
      loadingItems[r.key] = PlanItem(
        key: r.key,
        kind: PlanItemKind.reservedSlot,
        role: r.portOfLoading == portOfCall ? PlanRole.load : PlanRole.transit,
        plannedPosition: r.stowagePosition.toIsoCode(),
        reservedSlot: r,
      );
    }
    final deck = geometry ?? loading?.geometry ?? arrival?.geometry;
    return OperationPlan._(
      portOfCall,
      Map.unmodifiable(arrivalItems),
      Map.unmodifiable(loadingItems),
      deck == null ? (tier) => tier >= 80 : deck.isDeckTier,
      Map.unmodifiable({
        for (final row in list?.empties ?? const <ExportListRow>[])
          row.containerId: row.group
      }),
    );
  }

  bool get hasArrival => arrival.isNotEmpty;
  bool get hasLoading => loading.isNotEmpty;

  /// El objeto que el plan de carga tiene en esa posición, si lo hay.
  PlanItem? loadingItemAt(String position) {
    for (final item in loading.values) {
      if (item.plannedPosition == position) return item;
    }
    return null;
  }
}

/// Estado operativo de T-72: planificado, movido o cancelado.
enum ItemState { planned, moved, cancelled }

enum ConflictKind {
  /// Un movimiento sobre un objeto que no está en el plan de la escala.
  notInPlan,

  /// Registrado en una celda distinta de la que tiene en el plan.
  outOfPlan,

  /// La celda ya la ocupa otro objeto: vale el primero en el orden.
  cellTaken,

  /// El mismo objeto se movió dos veces a sitios distintos.
  movedTwice,

  /// El mismo vacío asignado a dos reservas.
  containerTwice,

  /// Se operó un objeto cancelado, o se canceló uno ya movido.
  cancelledItem,

  /// T-77 · Un vacío asignado a una reserva de otro grupo (tipo, puerto o
  /// línea distintos). Queda asignado, con el motivo escrito a la vista.
  otherGroup,
}

/// Un conflicto no se resuelve en silencio: la oficina lo ve y anula el
/// movimiento que sobra (T-79a 2.7.2).
class OperationConflict extends Equatable {
  final ConflictKind kind;
  final String key;
  final String movementId;
  final String? otherMovementId;
  final String message;

  const OperationConflict({
    required this.kind,
    required this.key,
    required this.movementId,
    this.otherMovementId,
    required this.message,
  });

  @override
  List<Object?> get props => [kind, key, movementId, otherMovementId, message];
}

/// Estado derivado de un objeto de la escala.
class ItemStatus extends Equatable {
  final String key;
  final PlanItemKind kind;
  final PlanRole role;
  final ItemState state;

  /// Posición del plan; nula si el objeto no está en el plan.
  final String? plannedPosition;

  /// Dónde está ahora a bordo: la del plan para lo que ya venía, la que
  /// registró el muelle para lo cargado, o nula si todavía no sube o ya bajó.
  final String? position;

  /// Para una reserva asignada: el vacío y su tara real.
  final String? assignedContainer;
  final double? tareKg;
  final String? seal;
  final int? order;
  final bool restow;

  /// Movimiento vigente que lo dejó en este estado.
  final String? movementId;
  final List<ConflictKind> conflicts;

  ItemStatus({
    required this.key,
    required this.kind,
    required this.role,
    required this.state,
    this.plannedPosition,
    this.position,
    this.assignedContainer,
    this.tareKg,
    this.seal,
    this.order,
    this.restow = false,
    this.movementId,
    Iterable<ConflictKind> conflicts = const [],
  }) : conflicts = List.unmodifiable(conflicts);

  bool get inConflict => conflicts.isNotEmpty;

  ItemStatus copyWith({
    ItemState? state,
    String? position,
    bool clearPosition = false,
    String? assignedContainer,
    double? tareKg,
    String? seal,
    int? order,
    bool? restow,
    String? movementId,
    Iterable<ConflictKind>? conflicts,
  }) =>
      ItemStatus(
        key: key,
        kind: kind,
        role: role,
        state: state ?? this.state,
        plannedPosition: plannedPosition,
        position: clearPosition ? null : (position ?? this.position),
        assignedContainer: assignedContainer ?? this.assignedContainer,
        tareKg: tareKg ?? this.tareKg,
        seal: seal ?? this.seal,
        order: order ?? this.order,
        restow: restow ?? this.restow,
        movementId: movementId ?? this.movementId,
        conflicts: conflicts ?? this.conflicts,
      );

  @override
  List<Object?> get props => [
        key,
        kind,
        role,
        state,
        plannedPosition,
        position,
        assignedContainer,
        tareKg,
        seal,
        order,
        restow,
        movementId,
        conflicts,
      ];
}

/// Conteo de una bahía y zona: lo previsto que sigue pendiente, lo movido y
/// lo cancelado. Es el «30 MOVS» al pie de la bahía del papel (T-78).
class ProgressCount extends Equatable {
  final int pending;
  final int moved;
  final int cancelled;

  const ProgressCount({this.pending = 0, this.moved = 0, this.cancelled = 0});

  ProgressCount add(ItemState state) => ProgressCount(
        pending: pending + (state == ItemState.planned ? 1 : 0),
        moved: moved + (state == ItemState.moved ? 1 : 0),
        cancelled: cancelled + (state == ItemState.cancelled ? 1 : 0),
      );

  @override
  List<Object?> get props => [pending, moved, cancelled];
}

/// Resultado de `OperationStateDeriver.derive`.
class OperationState {
  final Map<String, ItemStatus> items;
  final List<OperationConflict> conflicts;

  /// Movimientos repetidos sobre el mismo objeto y la misma celda: no son
  /// conflicto, pero no se aplican dos veces.
  final List<String> duplicates;

  /// Movimientos que T-72 guarda pero todavía no deriva (T-80, T-84).
  final List<String> notDerived;

  /// Movimientos anulados o corregidos.
  final Set<String> voided;
  final bool Function(int tier) _isDeckTier;

  OperationState({
    required Map<String, ItemStatus> items,
    required List<OperationConflict> conflicts,
    required List<String> duplicates,
    required List<String> notDerived,
    required Set<String> voided,
    required bool Function(int tier) isDeckTier,
  })  : items = Map.unmodifiable(items),
        conflicts = List.unmodifiable(conflicts),
        duplicates = List.unmodifiable(duplicates),
        notDerived = List.unmodifiable(notDerived),
        voided = Set.unmodifiable(voided),
        _isDeckTier = isDeckTier;

  ItemStatus? operator [](String key) => items[key];

  /// Qué hay en cada celda ahora: número de contenedor por posición. Una
  /// reserva cuenta solo si ya tiene su vacío; lo que bajó ya no está.
  Map<String, String> get occupancy {
    final result = <String, String>{};
    for (final item in items.values) {
      final position = item.position;
      if (position == null) continue;
      if (item.kind == PlanItemKind.reservedSlot) {
        if (item.assignedContainer != null) result[position] = item.assignedContainer!;
      } else {
        result[position] = item.key.substring(2);
      }
    }
    return result;
  }

  /// Avance de lo que se opera en la escala, por bahía y zona. Lo previsto
  /// se cuenta en su celda del plan; lo movido, donde lo registró el muelle.
  Map<({int bay, bool deck}), ProgressCount> progress({PlanRole? role}) {
    final result = <({int bay, bool deck}), ProgressCount>{};
    for (final item in items.values) {
      if (item.role == PlanRole.transit && !item.restow) continue;
      if (role != null && item.role != role) continue;
      final at = item.state == ItemState.moved && item.position != null
          ? item.position!
          : item.plannedPosition;
      if (at == null) continue;
      final c = IsoCoordinateParser.parse(at);
      final slot = (bay: c.bay, deck: _isDeckTier(c.tier));
      result[slot] = (result[slot] ?? const ProgressCount()).add(item.state);
    }
    return result;
  }
}
