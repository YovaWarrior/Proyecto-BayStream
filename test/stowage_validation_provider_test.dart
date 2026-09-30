import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/entities/stowage_validation_result.dart';
import 'package:baystream/features/vessel/presentation/providers/stowage_validation_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const geometry = VesselGeometry(
      portRows: 1, starboardRows: 1, holdTiers: [2], deckTiers: [82, 84]);
  const vessel = Vessel(id: 'v', name: 'PRUEBA');
  final cargo = ContainerUnit(
      id: 'c',
      containerId: 'REEFER',
      isoSizeType: '22R1',
      isReefer: true,
      stowagePosition: IsoCoordinateParser.parse('0010184'));
  final voyage = VesselVoyage(
          id: 't',
          vessel: vessel,
          voyageNumber: '1',
          containers: [cargo],
          bays: {1: const Bay(bayNumber: 1).addContainer(cargo)})
      .withGeometry(geometry);
  final profile = VesselProfile(
      identity: vessel.profileIdentity,
      vesselName: vessel.name,
      geometry: geometry,
      origin: VesselProfileOrigin.declaredByUser,
      updatedAt: DateTime.utc(2026));

  test(
      'T-42 valida perfil publicado y se actualiza al cambiar solo origen de tomas',
      () {
    final notifier = _Published(voyage, profile);
    final scope = ProviderContainer(overrides: [
      voyageNotifierProvider.overrideWith(() => notifier),
    ]);
    addTearDown(scope.dispose);
    final subscription =
        scope.listen(stowageValidationResultsProvider, (previous, next) {});
    addTearDown(subscription.close);
    expect(scope.read(reeferSocketResultsProvider).single.severity,
        ValidationSeverity.warning);
    notifier.publish(profile.copyWith(
        reeferSlotsOrigin: VesselProfileOrigin.declaredByUser));
    expect(scope.read(stowageValidationResultsProvider).single.severity,
        ValidationSeverity.error);
    notifier.publish(profile.copyWith(reeferSlots: {'0010184'}));
    expect(scope.read(stowageValidationResultsProvider), isEmpty);
  });
  test('T-42 filtros visuales no esconden la validación real de tomas', () {
    final scope = ProviderContainer(overrides: [
      voyageNotifierProvider.overrideWith(() => _Published(voyage, profile)),
    ]);
    addTearDown(scope.dispose);
    final before = scope.read(stowageValidationResultsProvider);
    scope.read(selectedCarrierProvider.notifier).select('SIN_CARGA');
    scope
        .read(selectedTypeFilterProvider.notifier)
        .toggle(LegendFilterType.full);
    expect(scope.read(stowageValidationResultsProvider), before);
    expect(before.single.rule, StowageRule.reeferSocket);
  });
}

class _Published extends VoyageNotifier {
  final VesselVoyage voyage;
  VesselProfile profile;
  _Published(this.voyage, this.profile);
  @override
  VesselProfile get publishedProfile => profile;
  @override
  AsyncValue<VesselVoyage?> build() => AsyncValue.data(voyage);
  void publish(VesselProfile next) {
    profile = next;
    state = AsyncValue.data(voyage.withGeometry(next.geometry));
  }
}
