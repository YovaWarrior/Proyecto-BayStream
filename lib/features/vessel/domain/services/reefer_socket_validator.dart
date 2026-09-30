import '../entities/container_unit.dart';
import '../entities/stowage_validation_result.dart';
import '../entities/vessel_profile.dart';

/// T-39: el inventario del buque y su origen son independientes del viaje.
class ReeferSocketValidator {
  const ReeferSocketValidator();

  List<StowageValidationResult> validate(
      Iterable<ContainerUnit> containers, VesselProfile profile) {
    final results = <StowageValidationResult>[];
    for (final c in containers.where((c) => c.isReefer)) {
      final p = c.stowagePosition;
      final located = p != null && profile.geometry.covers(p);
      if (located && profile.hasReeferSocket(p.toIsoCode())) continue;
      final declared =
          profile.reeferSlotsOrigin == VesselProfileOrigin.declaredByUser;
      final origin = switch (profile.reeferSlotsOrigin) {
        VesselProfileOrigin.declaredByUser => 'declaradas por el usuario',
        VesselProfileOrigin.proposedFromFile =>
          'propuestas del archivo (cota inferior; puede haber más tomas)',
        VesselProfileOrigin.template =>
          'copiadas de una plantilla, sin declaración para este buque',
      };
      results.add(StowageValidationResult(
        rule: StowageRule.reeferSocket,
        status: !located || !declared
            ? ValidationStatus.notEvaluated
            : ValidationStatus.nonConforming,
        severity: located && declared
            ? ValidationSeverity.error
            : ValidationSeverity.warning,
        description: !located
            ? 'No se puede comprobar la toma de ${c.containerId}: posición '
                'ausente o fuera de la geometría del perfil. Tomas $origin.'
            : declared
                ? 'Refrigerado ${c.containerId} en ${p.toIsoCode()} sin toma '
                    'en el inventario declarado por el usuario.'
                : 'No consta toma para el refrigerado ${c.containerId} en '
                    '${p.toIsoCode()}. Tomas $origin. Confirmar el inventario: '
                    'la ausencia en esta lista no demuestra que falte el enchufe.',
        positions: [if (p != null) p],
        containerIds: [c.containerId],
        references: ['Perfil ${profile.key}: tomas $origin.'],
      ));
    }
    return List.unmodifiable(results);
  }
}
