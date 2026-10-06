import '../entities/stowage_validation_result.dart';
import '../entities/vessel_profile.dart';
import '../entities/vessel_voyage.dart';

/// T-38: peso por pila (bahía, fila y zona) contra el perfil del buque.
/// Reutiliza el cálculo de Bay: no suma niveles horizontalmente ni duplica
/// el peso de los 40 pies en las bahías vecinas que solo muestran sus sombras.
///
/// T-67: la pila suma el peso efectivo (VGM si viene, si no el bruto) y un
/// contenedor sin ningún peso ya no cuenta como 0 en silencio. Si la suma
/// conocida supera el límite, la pila está excedida igual; si no, la regla no
/// puede afirmar que cumple y la declara «no evaluado».
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
          final containers = bay.containers.where((c) {
            final p = c.stowagePosition;
            return p != null &&
                p.row == row &&
                profile.geometry.isDeckTier(p.tier) == deck;
          }).toList()
            ..sort((a, b) =>
                a.stowagePosition!.tier.compareTo(b.stowagePosition!.tier));
          final missing =
              containers.where((c) => c.effectiveWeight == null).length;
          final exceeded = weight > limit;
          if (!exceeded && missing == 0) continue;
          final stack = 'La pila de ${deck ? 'cubierta' : 'bodega'} en '
              'bahía ${bay.bayNumberPadded}, fila ${row.toString().padLeft(2, '0')}';
          final unweighed = missing == 1
              ? '1 contenedor de esta pila no trae peso'
              : '$missing contenedores de esta pila no traen peso';
          results.add(StowageValidationResult(
            rule: StowageRule.stackWeight,
            status: exceeded
                ? ValidationStatus.nonConforming
                : ValidationStatus.notEvaluated,
            severity:
                exceeded ? ValidationSeverity.error : ValidationSeverity.warning,
            description: exceeded
                ? '$stack suma ${weight.toStringAsFixed(1)} kg y supera el '
                    'límite del perfil de ${limit.toStringAsFixed(1)} kg. '
                    '${missing > 0 ? '$unweighed: el peso real es mayor. ' : ''}'
                    'Apoyo a la decisión; no es un cálculo estructural certificado.'
                : '$unweighed. $stack suma ${weight.toStringAsFixed(1)} kg con '
                    'los pesos conocidos, por debajo del límite del perfil de '
                    '${limit.toStringAsFixed(1)} kg, pero sin todos los pesos '
                    'no se puede afirmar que lo cumpla.',
            positions: containers.map((c) => c.stowagePosition!),
            containerIds: containers.map((c) => c.containerId),
          ));
        }
      }
    }
    return List.unmodifiable(results);
  }
}
