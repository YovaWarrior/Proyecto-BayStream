import 'dart:convert';

import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  VesselVoyage voyage() {
    final parsed = BaplieParserService().parse(
      "TDT+20+V01N+++NV2:172:20+++9000003:146:11:BUQUE ALFA'"
      "LOC+147+0020182:::5'EQD+CN+TEST0000001+42G1+++5'"
      "LOC+147+0010282:::5'EQD+CN+TEST0000002+22G1+++5'",
    );
    return parsed.withGeometry(
        VesselGeometry.proposeFrom(parsed.stowagePositions),
        portOfCall: 'GTPBR');
  }

  test(
      'Firestore recupera vecinos, sombras y ocupación de bahías sin carga propia',
      () {
    final original = voyage();
    final restored =
        VesselVoyage.fromJson(jsonDecode(jsonEncode(original.toJson())));
    expect(restored.bays[3]!.containers, isEmpty);
    expect(restored.bays[3]!.slotsOccupiedByNeighbors, {'0182'});
    expect(restored.bays[1]!.occupiedSlotKeys, {'0182', '0282'});
    expect(restored.bays[3]!.occupancyRate, original.bays[3]!.occupancyRate);
    expect(restored, original);
  });

  test(
      'sin bahías serializadas reconstruye bahías, celdas y vecinos desde contenedores',
      () {
    final original = voyage();
    final json = original.toJson()..remove('bays');
    final restored = VesselVoyage.fromJson(jsonDecode(jsonEncode(json)));
    expect(restored, original);
    expect(
        restored.bays[2]!.getSlot(1, 82)!.container, original.containers.first);
    expect(restored.portOfCall, 'GTPBR');
  });

  test(
      'documento antiguo sin geometría recupera vecinos sin inventar porcentajes',
      () {
    final json = voyage().toJson()..remove('geometry');
    final restored = VesselVoyage.fromJson(json);
    expect(restored.geometry, isNull);
    expect(restored.bays[3]!.slotsOccupiedByNeighbors, {'0182'});
    expect(restored.bays[3]!.occupancyRate, isNull);
  });

  test(
      'Firestore conserva atributos históricos de celdas al recuperar los vecinos',
      () {
    final json = voyage().toJson();
    final bay =
        (json['bays'] as Map<String, dynamic>)['2'] as Map<String, dynamic>;
    final slot =
        (bay['slots'] as Map<String, dynamic>)['0182'] as Map<String, dynamic>;
    slot['isBlocked'] = true;
    slot['blockReason'] = 'Reserva declarada';
    slot['maxWeight'] = 30000;
    bay['location'] = 'deck';
    final restored = VesselVoyage.fromJson(json);
    expect(restored.bays[2]!.location, BayLocation.deck);
    expect(restored.bays[2]!.getSlot(1, 82)!.isBlocked, isTrue);
    expect(restored.bays[2]!.getSlot(1, 82)!.blockReason, 'Reserva declarada');
    expect(restored.bays[2]!.getSlot(1, 82)!.maxWeight, 30000);
    expect(restored.bays[3]!.slotsOccupiedByNeighbors, {'0182'});
  });
}
