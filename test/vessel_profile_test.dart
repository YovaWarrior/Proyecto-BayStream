import 'dart:convert';

import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final identity =
      VesselIdentity(source: VesselIdentitySource.imo, value: '9000003');
  final date = DateTime.utc(2026, 9, 19, 20);
  const geometry = VesselGeometry(
    portRows: 6,
    starboardRows: 6,
    holdTiers: [2, 4],
    deckTiers: [82, 84],
  );
  VesselProfile profile(
          {VesselGeometry shape = geometry, Set<String> slots = const {}}) =>
      VesselProfile(
          identity: identity,
          vesselName: 'BUQUE ALFA',
          geometry: shape,
          reeferSlots: slots,
          origin: VesselProfileOrigin.proposedFromFile,
          updatedAt: date);

  test('perfil sin opcionales conserva igualdad tras JSON real', () {
    final original = profile();
    final recovered =
        VesselProfile.fromJson(jsonDecode(jsonEncode(original.toJson())));
    expect(recovered, original);
    expect(recovered.stackWeightLimitKg, isNull);
    expect(recovered.reeferSlots, isEmpty);
    expect(recovered.key, 'imo:9000003');
    final missingSlots = original.toJson()..remove('reeferSlots');
    expect(VesselProfile.fromJson(missingSlots), original);
  });

  test(
      'perfil completo conserva límite, tomas y los tres orígenes sin elevar confianza',
      () {
    for (final origin in VesselProfileOrigin.values) {
      final original = profile(
          shape: geometry.copyWith(stackWeightLimitKg: 75000),
          slots: {'0020182', '0040284'}).copyWith(origin: origin);
      final recovered =
          VesselProfile.fromJson(jsonDecode(jsonEncode(original.toJson())));
      expect(recovered, original);
      expect(recovered.origin, origin);
      expect(recovered.stackWeightLimitKg, 75000);
      expect(recovered.hasReeferSocket('0020182'), isTrue);
      expect(recovered.hasReeferSocket('0020282'), isFalse);
      expect(recovered.updatedAt.isUtc, isTrue);
    }
  });

  test('copyWith distingue conservar un límite de retirarlo explícitamente',
      () {
    final original = profile().copyWith(stackWeightLimitKg: 75000);
    expect(original.copyWith().stackWeightLimitKg, 75000);
    expect(
        original.copyWith(stackWeightLimitKg: null).stackWeightLimitKg, isNull);
    expect(
        original.copyWith(stackWeightLimitKg: 80000).stackWeightLimitKg, 80000);
    expect(original.stackWeightLimitKg, 75000);
  });

  test('el perfil copia y protege niveles y tomas frente a mutaciones externas',
      () {
    final tiers = [82, 84];
    final sockets = {'0020182'};
    final original =
        profile(shape: geometry.copyWith(deckTiers: tiers), slots: sockets);
    tiers.clear();
    sockets.clear();
    expect(original.geometry.deckTiers, [82, 84]);
    expect(original.reeferSlots, {'0020182'});
    expect(() => original.geometry.deckTiers.add(86), throwsUnsupportedError);
    expect(() => original.reeferSlots.add('0040182'), throwsUnsupportedError);
    final copy = original.copyWith(reeferSlots: {'0060182'});
    expect(copy.reeferSlots, {'0060182'});
    expect(original.reeferSlots, {'0020182'});
  });

  test('un origen desconocido no se convierte silenciosamente en declarado',
      () {
    final json = profile().toJson()..['origin'] = 'desconocido';
    expect(() => VesselProfile.fromJson(json), throwsArgumentError);
  });
}
