import 'dart:convert';

import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/vessel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // TDT anonimizados A01–A06, cada uno con la versión de su archivo: A06 es
  // la 1.5, que T-103 vuelve a leer con las reglas de 2.x.
  const segments = [
    "UNH+1+BAPLIE:D:95B:UN:SMDG20'TDT+20+V01N+++NV2:172:20+++9000003:146:11:BUQUE ALFA'",
    "UNH+1+BAPLIE:D:95B:UN:SMDG20'TDT+20+VIAJE001A+++NV3:172:20+++9000015:146:11:BUQUE BRAVO'",
    "UNH+1+BAPLIE:D:95B:UN:SMDG20'TDT+20+VIAJE003A+++NV3:172:166+++ZZAB1:103:ZZZ:BUQUE CHARLIE'",
    "UNH+1+BAPLIE:D:95B:UN:SMDG20'TDT+20+VIAJE002A+++NAVE5:172:20+++9000027:146:11:BUQUE DELTA'",
    "UNH+1+BAPLIE:D:95B:UN:SMDG20'TDT+20++++NV4:172:ZZZ+++ZZC5603:103::BUQUE ECO:kingston JM++LINEA-A:LR'",
    "UNH+1+BAPLIE:1:911:UN:SMDG15'TDT+20+VIAJE004A++9000039:146::BUQUE ECO++NV3:172:20'",
  ];
  const keys = [
    'imo:9000003',
    'imo:9000015',
    'callSign:ZZAB1',
    'imo:9000027',
    'callSign:ZZC5603',
    'imo:9000039',
  ];
  final parser = BaplieParserService();

  for (var i = 0; i < segments.length; i++) {
    test('TDT A0${i + 1}: clave estable y UUID independiente', () {
      final first = parser.parse(segments[i]).vessel;
      final second = parser.parse(segments[i]).vessel;
      expect(first.profileKey, keys[i]);
      expect(second.profileKey, first.profileKey);
      expect(second.id, isNot(first.id));
      expect(first.matchIdentity(second), VesselIdentityMatch.automatic);
      final identity = first.profileIdentity;
      expect(VesselIdentity.fromJson(jsonDecode(jsonEncode(identity.toJson()))),
          identity);
      expect(Vessel.fromJson(first.toJson()).profileIdentity, identity);
    });
  }

  test('TDT homónimos de A05 (2.x) y A06 (1.5) requieren confirmar la identidad',
      () {
    final a05 = parser.parse(segments[4]).vessel;
    final a06 = parser.parse(segments[5]).vessel;
    expect(a05.name, a06.name);
    expect(a05.profileKey, isNot(a06.profileKey));
    expect(a05.imoNumber, isNull);
    expect(a05.callSign, 'ZZC5603');
    expect(a06.imoNumber, '9000039');
    expect(a06.callSign, isNull);
    expect(a05.matchIdentity(a06), VesselIdentityMatch.requiresConfirmation);
  });

  test(
      'el respaldo por nombre normalizado exige confirmación incluso si es igual',
      () {
    const a = Vessel(id: 'a', name: '  Buque   Alfa ');
    const b = Vessel(id: 'b', name: 'BUQUE ALFA');
    expect(a.profileKey, 'name:BUQUE ALFA');
    expect(a.profileKey, b.profileKey);
    expect(a.matchIdentity(b), VesselIdentityMatch.requiresConfirmation);
  });

  test('IMO tiene precedencia sobre indicativo y un cambio de nombre', () {
    const a =
        Vessel(id: 'a', name: 'ANTES', imoNumber: '9000003', callSign: 'ZZAB1');
    const b = Vessel(id: 'b', name: 'AHORA', imoNumber: '9000003');
    expect(a.profileIdentity.source, VesselIdentitySource.imo);
    expect(a.matchIdentity(b), VesselIdentityMatch.automatic);
  });

  test('un calificador desconocido no se interpreta como IMO por tener dígitos',
      () {
    final vessel =
        parser.parse("UNH+1+BAPLIE:D:95B:UN:SMDG20'TDT+20+V+++NV:172:20+++9000003:999::BUQUE ALFA'").vessel;
    expect(vessel.imoNumber, isNull);
    expect(vessel.callSign, isNull);
    expect(vessel.profileKey, 'name:BUQUE ALFA');
  });

  test(
      'nombres distintos no coinciden y campos vacíos usan el siguiente respaldo',
      () {
    const a =
        Vessel(id: 'a', name: 'ALFA', imoNumber: ' ', callSign: ' zzab1 ');
    const b = Vessel(id: 'b', name: 'BRAVO');
    expect(a.profileKey, 'callSign:ZZAB1');
    expect(a.matchIdentity(b), VesselIdentityMatch.none);
    expect(() => VesselIdentity(source: VesselIdentitySource.name, value: ' '),
        throwsArgumentError);
  });
}
