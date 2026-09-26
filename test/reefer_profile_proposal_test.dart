import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('T-31 propone por ISO y TMP sin incorporar secos ni vecinos de 40 pies',
      () {
    const edi = "TDT+20+V01N+++NV2:172:20+++9000003:146:11:BUQUE ALFA'"
        "LOC+147+0020182:::5'EQD+CN+ISO+42R1+++5'"
        "LOC+147+0020282:::5'TMP+2+-020:CEL'EQD+CN+TMP+42G1+++5'"
        "LOC+147+0020382:::5'EQD+CN+SECO+42G1+++5'";
    final voyage = BaplieParserService().parse(edi);
    expect(voyage.containers.map((c) => c.isReefer), [true, true, false]);
    final profile = VesselProfile.proposeFrom(voyage);
    expect(profile.reeferSlots, {'0020182', '0020282'});
    expect(profile.reeferSlotsOrigin, VesselProfileOrigin.proposedFromFile);
    expect(profile.hasReeferSocket('0010182'), isFalse);
    expect(profile.hasReeferSocket('0030182'), isFalse);
    expect(profile.hasReeferSocket('0020382'), isFalse);
  });

  test('la cota inferior elimina duplicados y excluye reefers sin posición',
      () {
    const position =
        IsoCoordinate(bay: 2, row: 1, tier: 82, rawCode: '0020182');
    const voyage = VesselVoyage(
        id: 'v',
        vessel: Vessel(id: 'b', name: 'B'),
        voyageNumber: '1',
        containers: [
          ContainerUnit(
              id: '1',
              containerId: '1',
              isReefer: true,
              stowagePosition: position),
          ContainerUnit(
              id: '2',
              containerId: '2',
              isReefer: true,
              stowagePosition: position),
          ContainerUnit(id: '3', containerId: '3', isReefer: true),
        ]);
    expect(VesselProfile.proposeFrom(voyage).reeferSlots, {'0020182'});
    expect(
        VesselProfile.proposeFrom(voyage.copyWith(containers: [])).reeferSlots,
        isEmpty);
  });
}
