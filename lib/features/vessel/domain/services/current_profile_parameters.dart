import '../../../../core/utils/iso_coordinate_parser.dart';
import '../entities/vessel_geometry.dart';

/// Parámetros del buque que un viaje reabierto toma del perfil vigente (T-61).
///
/// No incluye filas ni niveles: esas son las dimensiones que la carga del
/// viaje necesita, y la geometría histórica no se ensancha ni se recorta.
enum VesselParameter {
  // La frontera va primero: decide en qué zona cae cada nivel, y con ello
  // a qué declaración de fila 00 responde cada contenedor.
  deckTierFloor('frontera cubierta/bodega'),
  centerRowOnDeck('fila 00 en cubierta'),
  centerRowInHold('fila 00 en bodega'),
  firstHoldTier('primer nivel de bodega'),
  firstDeckTier('primer nivel de cubierta'),
  stackWeightLimitKg('límite de apilamiento');

  final String label;
  const VesselParameter(this.label);
}

/// Geometría con la que se reabre un viaje y los parámetros que no se pudieron
/// tomar del perfil vigente.
class ReopenedGeometry {
  final VesselGeometry geometry;

  /// Parámetros del perfil vigente que dejarían carga del viaje fuera de la
  /// geometría. Para ellos se conserva el valor guardado con el viaje.
  final List<VesselParameter> keptFromVoyage;

  ReopenedGeometry(this.geometry, Iterable<VesselParameter> keptFromVoyage)
      : keptFromVoyage = List.unmodifiable(keptFromVoyage);
}

/// Combina la geometría guardada con un viaje y la del perfil vigente.
///
/// Conserva las dimensiones del viaje y toma del perfil cada parámetro del
/// buque, uno por uno. Si aplicar uno deja algún contenedor fuera de la
/// geometría —por ejemplo, la fila 00 declarada inexistente en un viaje con
/// carga en la 00—, ese parámetro conserva el valor del viaje y se informa.
/// No se oculta carga para respetar una declaración.
ReopenedGeometry applyCurrentProfileParameters({
  required VesselGeometry voyageGeometry,
  required VesselGeometry profileGeometry,
  required Iterable<IsoCoordinate> positions,
}) {
  final cargo = positions.toList(growable: false);
  var geometry = voyageGeometry;
  final kept = <VesselParameter>[];
  for (final parameter in VesselParameter.values) {
    final candidate = _withParameter(geometry, profileGeometry, parameter);
    if (candidate == geometry) continue;
    if (candidate.coversAll(cargo)) {
      geometry = candidate;
    } else {
      kept.add(parameter);
    }
  }
  return ReopenedGeometry(geometry, kept);
}

VesselGeometry _withParameter(
    VesselGeometry base, VesselGeometry source, VesselParameter parameter) {
  switch (parameter) {
    case VesselParameter.deckTierFloor:
      return base.copyWith(deckTierFloor: source.deckTierFloor);
    case VesselParameter.centerRowOnDeck:
      return base.copyWith(centerRowOnDeck: source.centerRowOnDeck);
    case VesselParameter.centerRowInHold:
      return base.copyWith(centerRowInHold: source.centerRowInHold);
    case VesselParameter.firstHoldTier:
      return base.copyWith(firstHoldTier: source.firstHoldTier);
    case VesselParameter.firstDeckTier:
      return base.copyWith(firstDeckTier: source.firstDeckTier);
    case VesselParameter.stackWeightLimitKg:
      // copyWith trata null como «sin cambio»; quitar el límite es explícito.
      final limit = source.stackWeightLimitKg;
      return limit == null
          ? base.withoutStackWeightLimit()
          : base.copyWith(stackWeightLimitKg: limit);
  }
}
