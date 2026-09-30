import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/entities/stowage_validation_result.dart';
import 'package:baystream/features/vessel/domain/services/reefer_socket_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const vessel = Vessel(id: 'v', name: 'PRUEBA');
  const geometry = VesselGeometry(
      portRows: 1, starboardRows: 1, holdTiers: [2], deckTiers: [82, 84]);
  ContainerUnit cargo({String? position = '0010182', bool reefer = true}) =>
      ContainerUnit(
          id: 'id',
          containerId: 'TEST1234567',
          isReefer: reefer,
          stowagePosition:
              position == null ? null : IsoCoordinateParser.parse(position));
  VesselProfile profile(VesselProfileOrigin sockets,
          {Set<String> slots = const {}}) =>
      VesselProfile(
          identity: vessel.profileIdentity,
          vesselName: vessel.name,
          geometry: geometry,
          reeferSlots: slots,
          reeferSlotsOrigin: sockets,
          origin: VesselProfileOrigin.declaredByUser,
          updatedAt: DateTime.utc(2026));
  const validator = ReeferSocketValidator();

  test('T-39 toma declarada ausente es error con contenedor y posición', () {
    final r = validator.validate(
        [cargo()], profile(VesselProfileOrigin.declaredByUser)).single;
    expect(r.severity, ValidationSeverity.error);
    expect(r.status, ValidationStatus.nonConforming);
    expect(r.rule, StowageRule.reeferSocket);
    expect(r.positions.single.toIsoCode(), '0010182');
    expect(r.containerIds, ['TEST1234567']);
    expect(r.description, contains('inventario declarado'));
  });
  test('T-39 cota inferior genera aviso y no afirma ausencia de enchufe', () {
    final r = validator.validate(
        [cargo()], profile(VesselProfileOrigin.proposedFromFile)).single;
    expect(r.severity, ValidationSeverity.warning);
    expect(r.status, ValidationStatus.notEvaluated);
    expect(r.description, contains('cota inferior'));
    expect(r.description, contains('no demuestra'));
  });
  test('T-39 plantilla no hereda confianza del origen general declarado', () {
    final r = validator
        .validate([cargo()], profile(VesselProfileOrigin.template)).single;
    expect(r.severity, ValidationSeverity.warning);
    expect(r.status, ValidationStatus.notEvaluated);
    expect(r.description, contains('plantilla'));
  });
  test('T-39 enchufe presente y contenedor seco no alertan', () {
    for (final origin in VesselProfileOrigin.values) {
      expect(validator.validate([cargo()], profile(origin, slots: {'0010182'})),
          isEmpty);
      expect(
          validator.validate([cargo(reefer: false)], profile(origin)), isEmpty);
    }
  });
  test('T-39 posición ausente no se diagnostica como falta de toma', () {
    final r = validator.validate([cargo(position: null)],
        profile(VesselProfileOrigin.declaredByUser)).single;
    expect(r.status, ValidationStatus.notEvaluated);
    expect(r.positions, isEmpty);
    expect(r.severity, ValidationSeverity.warning);
  });
  test('T-39 fuera de geometría conserva razón y posición', () {
    final r = validator.validate([cargo(position: '0010582')],
        profile(VesselProfileOrigin.declaredByUser)).single;
    expect(r.status, ValidationStatus.notEvaluated);
    expect(r.description, contains('fuera de la geometría'));
    expect(r.positions.single.toIsoCode(), '0010582');
  });
}
