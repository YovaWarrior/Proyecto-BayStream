import '../entities/container_unit.dart';
import '../entities/stowage_validation_result.dart';
import '../entities/vessel_geometry.dart';
import '../entities/vessel_voyage.dart';

/// T-40: apoyo a la decisión; el archivo no declara equipo especial de soporte.
/// Busca la carga inmediatamente inferior ocupada en la misma mitad de huella
/// y zona. No alerta otra vez por cada 20 pies que continúe encima de ese 20.
class ContainerStackingValidator {
  const ContainerStackingValidator();

  List<StowageValidationResult> validate(
      VesselVoyage voyage, VesselGeometry geometry) {
    final shadows = voyage.neighborOccupiedSlots();
    final columns = <(int, int, bool), List<ContainerUnit>>{};
    for (final c in voyage.containers) {
      final p = c.stowagePosition;
      if (p == null || !geometry.covers(p)) continue;
      final size = c.sizeInFeet;
      final occupied = <int>[];
      if (size == 20 && p.bay.isOdd) occupied.add(p.bay);
      if (size != null && size >= 40 && p.bay.isEven) {
        final slot = '${p.rowPadded}${p.tierPadded}';
        for (final neighbor in [p.bay - 1, p.bay + 1]) {
          // La pertenencia física procede de C-5b, también tras deserializar.
          if (shadows[neighbor]?.contains(slot) ?? false) {
            occupied.add(neighbor);
          }
        }
      }
      for (final bay in occupied) {
        columns.putIfAbsent(
            (bay, p.row, geometry.isDeckTier(p.tier)), () => []).add(c);
      }
    }
    final results = <StowageValidationResult>[];
    for (final c in voyage.containers.where((c) => c.sizeInFeet == 20)) {
      final p = c.stowagePosition;
      if (p == null || !p.bay.isOdd || !geometry.covers(p)) continue;
      final below = (columns[(p.bay, p.row, geometry.isDeckTier(p.tier))] ?? [])
          .where((b) => b.stowagePosition!.tier < p.tier)
          .toList()
        ..sort((a, b) =>
            b.stowagePosition!.tier.compareTo(a.stowagePosition!.tier));
      if (below.isEmpty) continue;
      final tier = below.first.stowagePosition!.tier;
      for (final support in below.where(
          (b) => b.stowagePosition!.tier == tier && b.sizeInFeet! >= 40)) {
        final q = support.stowagePosition!;
        results.add(StowageValidationResult(
          rule: StowageRule.twentyOverForty,
          status: ValidationStatus.nonConforming,
          severity: ValidationSeverity.error,
          description: 'Posible apilamiento incompatible: ${c.containerId} '
              '(20 pies, ${p.toIsoCode()}) sobre la huella de '
              '${support.containerId} (${support.sizeInFeet} pies, '
              '${q.toIsoCode()}) en ${geometry.isDeckTier(p.tier) ? 'cubierta' : 'bodega'}. '
              'Es la carga inferior más cercana en esa columna. '
              'Verificar apoyo y equipo especial; el archivo no los declara.',
          positions: [p, q],
          containerIds: [c.containerId, support.containerId],
          references: const [
            'T-40 / C-5b: huella de bahía par en sus dos impares vecinas.'
          ],
        ));
      }
    }
    return List.unmodifiable(results);
  }
}
