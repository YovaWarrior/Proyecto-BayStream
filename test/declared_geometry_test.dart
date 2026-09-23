import 'dart:convert';

import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('anclas declaradas siembran corridas y descienden hasta la carga', () {
    const parameters = VesselGeometry(
        portRows: 0,
        starboardRows: 0,
        holdTiers: [],
        deckTiers: [],
        firstHoldTier: 4,
        firstDeckTier: 84);
    final above = VesselGeometry.proposeFrom([
      IsoCoordinateParser.parse('0020188'),
      IsoCoordinateParser.parse('0020108'),
    ], parameters: parameters);
    expect(above.deckTiers, [84, 86, 88]);
    expect(above.holdTiers, [4, 6, 8]);
    final positions = [
      IsoCoordinateParser.parse('0010080'),
      IsoCoordinateParser.parse('0010086'),
      IsoCoordinateParser.parse('0010002')
    ];
    final below = VesselGeometry.proposeFrom(positions, parameters: parameters);
    expect(below.deckTiers, [80, 82, 84, 86]);
    expect(below.holdTiers, [2]);
    expect(below.coversAll(positions), isTrue);
    expect(below.firstDeckTier, 84);
    final profile = VesselProfile(
        identity: const Vessel(id: '1', name: 'A').profileIdentity,
        vesselName: 'A',
        geometry: above,
        origin: VesselProfileOrigin.declaredByUser,
        updatedAt: DateTime.utc(2026));
    final restored =
        VesselProfile.fromJson(jsonDecode(jsonEncode(profile.toJson())));
    expect(restored, profile);
    expect(restored.firstDeckTier, 84);
    expect(restored.firstHoldTier, 4);
    expect(restored.copyWith(stackWeightLimitKg: null).geometry, above);
  });

  test('JSON histórico recibe las anclas ISO solamente al deserializar', () {
    final json = const VesselGeometry(
        portRows: 1, starboardRows: 1, holdTiers: [2], deckTiers: [82]).toJson()
      ..remove('firstHoldTier')
      ..remove('firstDeckTier');
    final restored = VesselGeometry.fromJson(json);
    expect(restored.firstHoldTier, 2);
    expect(restored.firstDeckTier, 82);
  });
  test('frontera declarada clasifica cobertura y peso por pila', () {
    const geometry = VesselGeometry(
        portRows: 1,
        starboardRows: 1,
        holdTiers: [2, 82],
        deckTiers: [84, 86],
        deckTierFloor: 84);
    final position = IsoCoordinateParser.parse('0020182');
    expect(geometry.isDeckTier(82), isFalse);
    expect(geometry.isDeckTier(84), isTrue);
    expect(geometry.covers(position), isTrue);
    final bay = const Bay(bayNumber: 2, geometry: geometry).addContainer(
        ContainerUnit(
            id: '1',
            containerId: 'C1',
            grossWeight: 12000,
            stowagePosition: position));
    expect(bay.holdWeightByRow, {1: 12000.0});
    expect(bay.deckWeightByRow, isEmpty);
    expect(VesselGeometry.fromJson(jsonDecode(jsonEncode(geometry.toJson()))),
        geometry);
    expect(geometry.copyWith().deckTierFloor, 84);
    expect(geometry.withoutStackWeightLimit().deckTierFloor, 84);
  });

  test('geometría anterior a T-26 conserva frontera 80 al leer', () {
    final json = const VesselGeometry(
        portRows: 1, starboardRows: 1, holdTiers: [2], deckTiers: [82]).toJson()
      ..remove('deckTierFloor');
    expect(VesselGeometry.fromJson(json).deckTierFloor, 80);
  });
}
