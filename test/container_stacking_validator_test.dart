import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/entities/stowage_validation_result.dart';
import 'package:baystream/features/vessel/domain/services/container_stacking_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const geometry = VesselGeometry(
      portRows: 2,
      starboardRows: 2,
      holdTiers: [2, 4],
      deckTiers: [82, 84, 86]);
  ContainerUnit cargo(String position, String iso) => ContainerUnit(
      id: position,
      containerId: 'C$position',
      isoSizeType: iso,
      stowagePosition: IsoCoordinateParser.parse(position));
  VesselVoyage trip(List<ContainerUnit> cs) => VesselVoyage(
      id: 't',
      vessel: const Vessel(id: 'v', name: 'PRUEBA'),
      voyageNumber: '1',
      containers: cs);
  const validator = ContainerStackingValidator();
  test('T-40 dos mitades de huella de 40 generan dos pares localizables', () {
    final r = validator.validate(
        trip([
          cargo('0020182', '42G1'),
          cargo('0010184', '22G1'),
          cargo('0030184', '22G1')
        ]),
        geometry);
    expect(r, hasLength(2));
    expect(
        r.every((r) =>
            r.severity == ValidationSeverity.error &&
            r.status == ValidationStatus.nonConforming &&
            r.rule == StowageRule.twentyOverForty),
        isTrue);
    expect(r.first.positions.map((p) => p.toIsoCode()), ['0010184', '0020182']);
    expect(r.first.containerIds, ['C0010184', 'C0020182']);
  });
  test('T-40 40 encima de 20 no dispara la regla inversa', () {
    expect(
        validator.validate(
            trip([cargo('0010182', '22G1'), cargo('0020184', '42G1')]),
            geometry),
        isEmpty);
  });
  test('T-40 ni otra fila ni otra pareja de bahías comparten apoyo', () {
    expect(
        validator.validate(
            trip([
              cargo('0020182', '42G1'),
              cargo('0010384', '22G1'),
              cargo('0050184', '22G1')
            ]),
            geometry),
        isEmpty);
  });
  test('T-40 cubierta y bodega no se apilan entre sí', () {
    expect(
        validator.validate(
            trip([cargo('0020104', '42G1'), cargo('0010182', '22G1')]),
            geometry),
        isEmpty);
  });
  test('T-40 respeta frontera del buque y no una constante', () {
    final v = trip([cargo('0020182', '42G1'), cargo('0010184', '22G1')]);
    final g = geometry.copyWith(
        deckTierFloor: 84, holdTiers: [2, 4, 82], deckTiers: [84, 86]);
    expect(validator.validate(v, g), isEmpty);
  });
  test('T-40 no repite alerta para 20 apoyado en otro 20', () {
    final r = validator.validate(
        trip([
          cargo('0020182', '42G1'),
          cargo('0010184', '22G1'),
          cargo('0010186', '22G1')
        ]),
        geometry);
    expect(r, hasLength(1));
  });
  test('T-40 45 pies usa la misma huella y declara su tamaño real', () {
    final r = validator.validate(
        trip([cargo('0020182', 'L5G1'), cargo('0030184', '22G1')]), geometry);
    expect(r.single.description, contains('45 pies'));
  });
  test('T-40 sin tamaño o sin posición no inventa relación', () {
    expect(
        validator.validate(
            trip([
              const ContainerUnit(id: 'x', containerId: 'X'),
              cargo('0010184', '22G1')
            ]),
            geometry),
        isEmpty);
  });
  test('T-40 conserva resultado al reconstruir viaje persistido', () {
    final v = trip([cargo('0020182', '42G1'), cargo('0010184', '22G1')])
        .withGeometry(geometry);
    expect(validator.validate(VesselVoyage.fromJson(v.toJson()), geometry),
        validator.validate(v, geometry));
  });
}
