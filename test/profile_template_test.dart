import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final source = VesselProfile(
    identity: VesselIdentity(source: VesselIdentitySource.imo, value: '9000003'),
    vesselName: 'ALFA',
    geometry: const VesselGeometry(portRows: 2, starboardRows: 3,
        holdTiers: [4, 6], deckTiers: [84, 86], deckTierFloor: 82,
        firstHoldTier: 4, firstDeckTier: 84, stackWeightLimitKg: 75000),
    reeferSlots: {'0020184'},
    origin: VesselProfileOrigin.declaredByUser,
    reeferSlotsOrigin: VesselProfileOrigin.declaredByUser,
    updatedAt: DateTime.utc(2026, 9, 27),
  );
  const target = Vessel(id: 'nuevo-uuid', name: 'BETA', imoNumber: '9000004');

  test('T-32 clona parámetros para otra identidad con ambos orígenes plantilla', () {
    final clone = source.cloneFor(target);
    expect(clone.identity, target.profileIdentity);
    expect(clone.key, isNot(source.key));
    expect(clone.vesselName, 'BETA');
    expect(clone.geometry, source.geometry);
    expect(clone.reeferSlots, source.reeferSlots);
    expect(clone.origin, VesselProfileOrigin.template);
    expect(clone.reeferSlotsOrigin, VesselProfileOrigin.template);
  });

  test('T-32 editar colecciones y límite del clon no modifica la fuente', () {
    final clone = source.cloneFor(target);
    expect(identical(clone.geometry.deckTiers, source.geometry.deckTiers), isFalse);
    expect(identical(clone.reeferSlots, source.reeferSlots), isFalse);
    final levels = [...clone.geometry.deckTiers, 88];
    final sockets = {...clone.reeferSlots}..add('0040286');
    final edited = clone.copyWith(geometry: clone.geometry.copyWith(deckTiers: levels),
        reeferSlots: sockets, stackWeightLimitKg: null);
    levels.clear();
    sockets.clear();
    expect(edited.geometry.deckTiers, [84, 86, 88]);
    expect(edited.reeferSlots, {'0020184', '0040286'});
    expect(edited.stackWeightLimitKg, isNull);
    expect(source.geometry.deckTiers, [84, 86]);
    expect(source.reeferSlots, {'0020184'});
    expect(source.stackWeightLimitKg, 75000);
    expect(() => clone.reeferSlots.clear(), throwsUnsupportedError);
    expect(() => clone.geometry.holdTiers.clear(), throwsUnsupportedError);
  });

  test('T-32 rechaza usar la identidad del buque fuente como clon', () {
    expect(() => source.cloneFor(const Vessel(id: 'otro-uuid', name: 'ALFA',
        imoNumber: '9000003')), throwsArgumentError);
  });
}
