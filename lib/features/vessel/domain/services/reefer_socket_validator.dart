import '../entities/container_unit.dart';
import '../entities/stowage_validation_result.dart';
import '../entities/vessel_profile.dart';

/// T-39: el inventario del buque y su origen son independientes del viaje.
///
/// T-56: la toma se busca por **celda física**, con los códigos de siete
/// dígitos tal como están guardados. Una impar es un extremo de la celda; una
/// par, la celda sin extremo; una impar sin par, la celda entera.
/// - Un refrigerado en la par E (40 o 45) acepta la toma de E, E−1 o E+1: un
///   40 se orienta hacia su toma (T-59, códigos RFA y RFF de SMDG).
/// - Uno en la impar b (20) acepta la de b. Si solo consta una par vecina, la
///   celda tiene toma pero no se sabe en qué extremo: aviso, nunca error.
/// - No se calcula «la par de una impar»: se miran las dos vecinas, porque esa
///   correspondencia es del buque (T-55: en ALFA la 044 cubre 043 y 045, y la
///   041 va sola).
class ReeferSocketValidator {
  const ReeferSocketValidator();

  List<StowageValidationResult> validate(
      Iterable<ContainerUnit> containers, VesselProfile profile) {
    final results = <StowageValidationResult>[];
    final origin = switch (profile.reeferSlotsOrigin) {
      VesselProfileOrigin.declaredByUser => 'declaradas por el usuario',
      VesselProfileOrigin.proposedFromFile =>
        'propuestas del archivo (cota inferior; puede haber más tomas)',
      VesselProfileOrigin.template =>
        'copiadas de una plantilla, sin declaración para este buque',
    };
    for (final c in containers.where((c) => c.isReefer)) {
      final p = c.stowagePosition;
      final located = p != null && profile.geometry.covers(p);
      String? socket(int bay) => bay < 1 || bay > 999
          ? null
          : '${bay.toString().padLeft(3, '0')}${p!.rowPadded}${p.tierPadded}';
      if (located) {
        if (profile.hasReeferSocket(p.toIsoCode())) continue;
        final neighbors = [socket(p.bay - 1), socket(p.bay + 1)]
            .whereType<String>()
            .where(profile.hasReeferSocket)
            .toList();
        if (p.bay.isEven && neighbors.isNotEmpty) continue;
        if (p.bay.isOdd && neighbors.isNotEmpty) {
          results.add(StowageValidationResult(
            rule: StowageRule.reeferSocket,
            status: ValidationStatus.notEvaluated,
            severity: ValidationSeverity.warning,
            description: 'Refrigerado ${c.containerId} en ${p.toIsoCode()}: '
                '${neighbors.length == 1 ? 'consta la toma' : 'constan las tomas'} '
                '${neighbors.join(' y ')}, de bahía par y sin extremo. La '
                'celda tiene toma, pero no consta en qué extremo: confírmalo.',
            positions: [p],
            containerIds: [c.containerId],
            references: ['Perfil ${profile.key}: tomas $origin.'],
          ));
          continue;
        }
      }
      final declared =
          profile.reeferSlotsOrigin == VesselProfileOrigin.declaredByUser;
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
