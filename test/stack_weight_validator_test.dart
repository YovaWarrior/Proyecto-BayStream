import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/entities/stowage_validation_result.dart';
import 'package:baystream/features/vessel/domain/services/stack_weight_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const vessel = Vessel(id: 'v', name: 'PRUEBA');
  ContainerUnit cargo(String position, double? weight) => ContainerUnit(
      id: position,
      containerId: position,
      isoSizeType: '22G1',
      stowagePosition: IsoCoordinateParser.parse(position),
      grossWeight: weight);
  VesselProfile profile(double? limit, {int floor = 80}) => VesselProfile(
      identity: vessel.profileIdentity,
      vesselName: vessel.name,
      geometry: VesselGeometry(
          portRows: 2,
          starboardRows: 2,
          holdTiers: const [2, 4],
          deckTiers: const [80, 82, 84],
          deckTierFloor: floor,
          stackWeightLimitKg: limit),
      origin: VesselProfileOrigin.declaredByUser,
      updatedAt: DateTime.utc(2026));
  VesselVoyage voyage(List<ContainerUnit> cargo) {
    var bay = const Bay(bayNumber: 1);
    for (final c in cargo) {
      bay = bay.addContainer(c);
    }
    return VesselVoyage(
        id: 'trip',
        vessel: vessel,
        voyageNumber: '1',
        containers: cargo,
        bays: {1: bay});
  }

  const validator = StackWeightValidator();

  test('T-38 exceso por pila, con posiciones y contenedores del contrato común',
      () {
    final result = validator.validate(
        voyage([
          cargo('0010182', 40000),
          cargo('0010184', 40000),
          cargo('0010382', 50000),
          cargo('0010102', 60000)
        ]),
        profile(75000));
    expect(result, hasLength(1));
    expect(result.single.rule, StowageRule.stackWeight);
    expect(result.single.status, ValidationStatus.nonConforming);
    expect(result.single.severity, ValidationSeverity.error);
    expect(result.single.positions.map((p) => p.toIsoCode()),
        ['0010182', '0010184']);
    expect(result.single.containerIds, ['0010182', '0010184']);
    expect(result.single.description, contains('80000.0 kg'));
  });
  test('T-38 null no produce alertas ni un límite sustituto', () {
    expect(
        validator.validate(voyage([cargo('0010182', 999999)]), profile(null)),
        isEmpty);
  });
  test('T-38 igualdad no es exceso; cubierta y bodega no se suman', () {
    expect(
        validator.validate(
            voyage([
              cargo('0010182', 75000),
              cargo('0010102', 75000),
              cargo('0010104', null)
            ]),
            profile(75000)),
        isEmpty);
  });
  test('T-38 usa la frontera del perfil, no una constante local', () {
    final trip = voyage([cargo('0010180', 40000), cargo('0010182', 40000)]);
    expect(validator.validate(trip, profile(75000)), hasLength(1));
    expect(validator.validate(trip, profile(75000, floor: 82)), isEmpty);
  });
  test('T-38 el contrato copia y protege sus colecciones', () {
    final positions = [IsoCoordinateParser.parse('0010182')];
    final ids = ['A'];
    final result = StowageValidationResult(
        rule: StowageRule.stackWeight,
        status: ValidationStatus.nonConforming,
        severity: ValidationSeverity.error,
        description: 'Prueba',
        positions: positions,
        containerIds: ids);
    positions.clear();
    ids.clear();
    expect(result.positions, hasLength(1));
    expect(result.containerIds, ['A']);
    expect(() => result.positions.clear(), throwsUnsupportedError);
  });
}
