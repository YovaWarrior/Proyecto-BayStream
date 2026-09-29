import '../entities/stowage_validation_result.dart';
import '../entities/vessel_profile.dart';
import '../entities/vessel_voyage.dart';

/// T-38: peso bruto por pila (bahía, fila y zona) contra el perfil del buque.
/// Reutiliza el cálculo de Bay: no suma niveles horizontalmente ni duplica
/// el peso de los 40 pies en las bahías vecinas que solo muestran sus sombras.
class StackWeightValidator {
  const StackWeightValidator();

  List<StowageValidationResult> validate(
      VesselVoyage voyage, VesselProfile profile) {
    final limit = profile.stackWeightLimitKg;
    if (limit == null) return const [];
    final results = <StowageValidationResult>[];
    final numbers = voyage.bays.keys.toList()..sort();
    for (final number in numbers) {
      final bay = voyage.bays[number]!.copyWith(geometry: profile.geometry);
      for (final deck in [false, true]) {
        final weights = deck ? bay.deckWeightByRow : bay.holdWeightByRow;
        final rows = weights.keys.toList()..sort();
        for (final row in rows) {
          final weight = weights[row]!;
          if (weight <= limit) continue;
          final containers = bay.containers.where((c) {
            final p = c.stowagePosition;
            return p != null &&
                p.row == row &&
                profile.geometry.isDeckTier(p.tier) == deck;
          }).toList()
            ..sort((a, b) =>
                a.stowagePosition!.tier.compareTo(b.stowagePosition!.tier));
          results.add(StowageValidationResult(
            rule: StowageRule.stackWeight,
            status: ValidationStatus.nonConforming,
            severity: ValidationSeverity.error,
            description: 'La pila de ${deck ? 'cubierta' : 'bodega'} en '
                'bahía ${bay.bayNumberPadded}, fila ${row.toString().padLeft(2, '0')} '
                'suma ${weight.toStringAsFixed(1)} kg y supera el límite del '
                'perfil de ${limit.toStringAsFixed(1)} kg. '
                'Apoyo a la decisión; no es un cálculo estructural certificado.',
            positions: containers.map((c) => c.stowagePosition!),
            containerIds: containers.map((c) => c.containerId),
          ));
        }
      }
    }
    return List.unmodifiable(results);
  }
}
