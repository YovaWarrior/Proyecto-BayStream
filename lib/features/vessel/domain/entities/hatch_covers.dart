import 'package:equatable/equatable.dart';

import '../../../../core/utils/iso_coordinate_parser.dart';
import 'vessel_geometry.dart';
import 'vessel_voyage.dart';

enum HatchCoverKind { openHold, automatic, crane }

/// Identidad natural de T-79a; la automática también ocupa el número 1.
class HatchCoverStatus extends Equatable {
  final int bay;
  final int number;
  final HatchCoverKind kind;
  final Set<int> rows;
  final bool removed;
  final String? movementId;
  const HatchCoverStatus({required this.bay, required this.number,
    required this.kind, required this.rows, this.removed = false, this.movementId});
  String get key => 'T:$bay-$number';
  String get label => kind == HatchCoverKind.automatic ? 'Automática' : 'T$number';
  HatchCoverStatus operated(bool remove, String id) => HatchCoverStatus(
    bay: bay, number: number, kind: kind, rows: rows, removed: remove, movementId: id);
  @override
  List<Object?> get props => [bay, number, kind, rows, removed, movementId];
}

/// Declaración explícita: ausencia en el mapa del perfil significa sin declarar.
class HatchCoverDeclaration extends Equatable {
  final HatchCoverKind kind;
  final List<Set<int>> covers;

  HatchCoverDeclaration({required this.kind, List<Set<int>> covers = const []})
      : covers = List.unmodifiable(
            covers.map((rows) => Set<int>.unmodifiable(rows)));

  String? validate(VesselGeometry geometry, {required bool hasHold}) {
    if (!hasHold || geometry.holdTiers.isEmpty) {
      return 'Una bahía sin bodega no puede declarar tapas.';
    }
    if (kind == HatchCoverKind.openHold) {
      return covers.isEmpty ? null : 'Una bodega abierta no lleva tapas.';
    }
    if (kind == HatchCoverKind.automatic && covers.length != 1) {
      return 'Declara exactamente una tapa automática.';
    }
    if (kind == HatchCoverKind.crane && (covers.isEmpty || covers.length > 3)) {
      return 'Declara de una a tres tapas de grúa.';
    }
    final seen = <int>{};
    for (var i = 0; i < covers.length; i++) {
      if (covers[i].isEmpty) {
        return 'La tapa ${i + 1} necesita al menos una fila.';
      }
      for (final row in covers[i]) {
        if (row < 0 ||
            row > 99 ||
            !geometry.covers(IsoCoordinate(
                bay: 1,
                row: row,
                tier: geometry.holdTiers.first,
                rawCode: ''))) {
          return 'La fila ${row.toString().padLeft(2, '0')} de la tapa ${i + 1} '
              'no pertenece a la geometría de bodega de esta bahía.';
        }
        if (!seen.add(row)) {
          return 'La fila ${row.toString().padLeft(2, '0')} se solapa entre tapas.';
        }
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        'kind': kind.name,
        'covers': [for (final rows in covers) rows.toList()..sort()],
      };
  factory HatchCoverDeclaration.fromJson(Map<String, dynamic> json) =>
      HatchCoverDeclaration(
          kind: HatchCoverKind.values.byName(json['kind'] as String),
          covers: (json['covers'] as List<dynamic>)
              .map((rows) => (rows as List<dynamic>).cast<int>().toSet())
              .toList());
  @override
  List<Object?> get props => [kind, covers];
}

/// Misma evidencia que T-77: planes y huellas de 40 pies, sin inferir tapas.
Set<int> observedHoldBays(VesselVoyage voyage, VesselGeometry geometry) {
  final result = <int>{};
  for (final p in voyage.stowagePositions) {
    if (!geometry.isDeckTier(p.tier)) result.add(p.bay);
  }
  for (final entry in voyage.neighborOccupiedSlots().entries) {
    if (entry.value
        .any((slot) => !geometry.isDeckTier(int.parse(slot.substring(2))))) {
      result.add(entry.key);
    }
  }
  for (final entry in voyage.neighborReservedSlots().entries) {
    if (entry.value.values
        .any((slot) => !geometry.isDeckTier(slot.stowagePosition.tier))) {
      result.add(entry.key);
    }
  }
  return result;
}
