import 'package:flutter_test/flutter_test.dart';
import 'package:baystream/core/errors/exceptions.dart';
import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';

void main() {
  group('IsoCoordinateParser', () {
    test('debe parsear coordenada ISO válida 0120006', () {
      final result = parseIsoCoordinates('0120006');
      
      expect(result.bay, 12);
      expect(result.row, 0);
      expect(result.tier, 6);
      expect(result.rawCode, '0120006');
    });

    test('debe parsear coordenada 0010102', () {
      final result = parseIsoCoordinates('0010102');
      
      expect(result.bay, 1);
      expect(result.row, 1);
      expect(result.tier, 2);
    });

    test('debe parsear coordenada con valores máximos 9999999', () {
      final result = parseIsoCoordinates('9999999');
      
      expect(result.bay, 999);
      expect(result.row, 99);
      expect(result.tier, 99);
    });

    test('debe lanzar excepción para coordenada muy corta', () {
      expect(
        () => parseIsoCoordinates('12345'),
        throwsA(isA<InvalidIsoCoordinateException>()),
      );
    });

    test('debe lanzar excepción para coordenada con letras', () {
      expect(
        () => parseIsoCoordinates('012A006'),
        throwsA(isA<InvalidIsoCoordinateException>()),
      );
    });

    test('tryParse debe retornar null para coordenada inválida', () {
      final result = IsoCoordinateParser.tryParse('invalid');
      expect(result, isNull);
    });

    test('isValid debe validar correctamente', () {
      expect(IsoCoordinateParser.isValid('0120006'), isTrue);
      expect(IsoCoordinateParser.isValid('invalid'), isFalse);
      expect(IsoCoordinateParser.isValid('123456'), isFalse);
    });

    test('fromValues debe crear coordenada correctamente', () {
      final result = IsoCoordinateParser.fromValues(
        bay: 12,
        row: 0,
        tier: 6,
      );
      
      expect(result.toIsoCode(), '0120006');
    });

    test('displayFormat debe mostrar formato legible', () {
      final result = parseIsoCoordinates('0120006');
      expect(result.displayFormat, 'Bay 012, Row 00, Tier 06');
    });
  });

  group('BaplieParserService', () {
    late BaplieParserService parser;

    setUp(() {
      parser = BaplieParserService();
    });

    test('debe parsear archivo BAPLIE básico', () {
      const baplieContent = '''
UNB+UNOA:2+SENDER+RECEIVER+230615:1200+123456'
UNH+1+BAPLIE:D:95B:UN'
BGM+129+BAPLIE123+9'
TDT+20+V001++++++CARRIER:::VESSEL MAYA'
LOC+147+0120006:::5'
EQD+CN+MSCU1234567+22G1+++5'
MEA+AAE+WT+KGM:25000'
MEA+AAE+VGM+KGM:25500'
LOC+147+0120106:::5'
EQD+CN+TCNU7654321+45R1+++5'
MEA+AAE+WT+KGM:28000'
UNT+12+1'
UNZ+1+123456'
''';

      final result = parser.parse(baplieContent);

      expect(result.vessel.name, 'VESSEL MAYA');
      expect(result.voyageNumber, 'V001');
      expect(result.containers.length, 2);
      
      // Primer contenedor
      final container1 = result.containers[0];
      expect(container1.containerId, 'MSCU1234567');
      expect(container1.isoSizeType, '22G1');
      expect(container1.status, ContainerStatus.full);
      expect(container1.grossWeight, 25000);
      expect(container1.vgmWeight, 25500);
      expect(container1.stowagePosition?.bay, 12);
      expect(container1.stowagePosition?.row, 0);
      expect(container1.stowagePosition?.tier, 6);

      // Segundo contenedor
      final container2 = result.containers[1];
      expect(container2.containerId, 'TCNU7654321');
      expect(container2.isoSizeType, '45R1');
    });

    test('debe organizar contenedores en bahías', () {
      const baplieContent = '''
UNH+1+BAPLIE:D:95B:UN'
TDT+20+V002++++++:::TEST VESSEL'
LOC+147+0100102:::5'
EQD+CN+CONT001+22G1+++5'
LOC+147+0100202:::5'
EQD+CN+CONT002+22G1+++5'
LOC+147+0200102:::5'
EQD+CN+CONT003+22G1+++5'
UNT+10+1'
''';

      final result = parser.parse(baplieContent);

      expect(result.bays.length, 2);
      expect(result.bays[10]?.containers.length, 2);
      expect(result.bays[20]?.containers.length, 1);
    });

    test('debe calcular estadísticas correctamente', () {
      const baplieContent = '''
UNH+1+BAPLIE:D:95B:UN'
TDT+20+V003++++++:::STATS VESSEL'
LOC+147+0100102:::5'
EQD+CN+CONT001+22G1+++5'
MEA+AAE+WT+KGM:20000'
LOC+147+0100202:::5'
EQD+CN+CONT002+22G1+++4'
MEA+AAE+WT+KGM:2000'
UNT+10+1'
''';

      final result = parser.parse(baplieContent);

      expect(result.totalContainers, 2);
      expect(result.fullContainers, 1);
      expect(result.emptyContainers, 1);
      expect(result.totalGrossWeight, 22000);
    });

    test('debe lanzar excepción para contenido vacío', () {
      expect(
        () => parser.parse(''),
        throwsA(isA<Exception>()),
      );
    });

    test('debe lanzar excepción si no encuentra TDT', () {
      const invalidContent = '''
UNH+1+BAPLIE:D:95B:UN'
LOC+147+0100102:::5'
EQD+CN+CONT001+22G1+++5'
UNT+4+1'
''';

      expect(
        () => parser.parse(invalidContent),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('TDT · nombre del buque', () {
    late BaplieParserService parser;

    setUp(() {
      parser = BaplieParserService();
    });

    String mensajeCon(String tdt) => [
          "UNH+1+BAPLIE:D:95B:UN'",
          "$tdt'",
          "LOC+147+0060102:::5'",
          "EQD+CN+ABCU1234567+22G1+++5'",
          "UNT+5+1'",
        ].join();

    test('lo lee del elemento 8, que es donde lo pone el estandar', () {
      // Segmento real de CORPUS_A01.
      final r = parser.parse(mensajeCon(
        'TDT+20+V01N+++NV2:172:20+++9000003:146:11:BUQUE ALFA',
      ));

      expect(r.vessel.name, 'BUQUE ALFA');
      expect(r.voyageNumber, 'V01N');
    });

    test('lo encuentra en el elemento 4 cuando el segmento omite vacios', () {
      // Segmento real de CORPUS_A06, el archivo que no se podia abrir: trae
      // el bloque c222 en el elemento 4 y el transportista en el 6.
      final r = parser.parse(mensajeCon(
        'TDT+20+VIAJE004A++9000039:146::BUQUE ECO++NV3:172:20',
      ));

      expect(r.vessel.name, 'BUQUE ECO');
      expect(r.voyageNumber, 'VIAJE004A');
    });

    test('con cinco componentes toma el nombre, no el lugar', () {
      // Segmento real de CORPUS_A05: el quinto componente es un puerto.
      final r = parser.parse(mensajeCon(
        'TDT+20++++NV4:172:ZZZ+++ZZC5603:103::BUQUE ECO:kingston JM'
        '++LINEA-A:LR',
      ));

      expect(r.vessel.name, 'BUQUE ECO');
    });

    test('prefiere la posicion del estandar sobre la busqueda por forma', () {
      // c040 admite la misma forma cuando trae el nombre de la naviera en su
      // cuarto componente. Buscar por forma primero devolveria la naviera.
      final r = parser.parse(mensajeCon(
        'TDT+20+V01N+++NV2:172:20:NAVIERA FALSA+++9000003:146:11:BUQUE ALFA',
      ));

      expect(r.vessel.name, 'BUQUE ALFA');
    });

    test('sin nombre en ninguna parte falla en vez de inventar uno', () {
      expect(
        () => parser.parse(mensajeCon('TDT+20+V01N+++NV2:172:20')),
        throwsA(isA<BaplieParsingException>()),
      );
    });
  });

  group('EQD · indicador lleno/vacío', () {
    late BaplieParserService parser;

    setUp(() {
      parser = BaplieParserService();
    });

    /// Envuelve segmentos EQD reales del corpus en un mensaje mínimo.
    String mensajeCon(List<String> segmentosEqd) {
      final buffer = StringBuffer()
        ..writeln("UNH+1+BAPLIE:D:95B:UN'")
        ..writeln("TDT+20+V001++++++CARRIER:::VESSEL MAYA'");
      for (var i = 0; i < segmentosEqd.length; i++) {
        buffer
          ..writeln("LOC+147+006010${i + 2}:::5'")
          ..writeln("${segmentosEqd[i]}'");
      }
      buffer.writeln("UNT+9+1'");
      return buffer.toString();
    }

    test('lee el elemento 6 y no el primero que valga 4 o 5', () {
      // Segmento real de CORPUS_A01. El elemento 5 vale '4' —es e8249, otro
      // código EDIFACT— y el elemento 6 vale '5'. Buscar por valor se detenía
      // en el 5 y declaraba vacío un contenedor lleno.
      final result = parser.parse(mensajeCon([
        'EQD+CN+TSTU5805726+22G1++4+5',
      ]));

      expect(result.containers.single.status, ContainerStatus.full);
    });

    test('el elemento 5 con valor 4 no decide el estado', () {
      // Mismo elemento 5 en los dos, distinto elemento 6: el resultado tiene
      // que diferir.
      final result = parser.parse(mensajeCon([
        'EQD+CN+TSTU5805726+22G1++4+5',
        'EQD+CN+ZKPU4140679+22G1++4+4',
      ]));

      expect(result.containers[0].status, ContainerStatus.full);
      expect(result.containers[1].status, ContainerStatus.empty);
    });

    test('reconoce las tres formas del elemento 5 en el corpus', () {
      // Vacío en 325 segmentos, '2' en 457 y '4' en 195, sobre CORPUS_A01.
      final result = parser.parse(mensajeCon([
        'EQD+CN+WLDU1694480+45G1+++5',
        'EQD+CN+EDUU0994165+45G1++2+4',
        'EQD+CN+VALU0988827+45R8++4+5',
      ]));

      expect(
        result.containers.map((c) => c.status).toList(),
        [ContainerStatus.full, ContainerStatus.empty, ContainerStatus.full],
      );
    });

    test('sin elemento 6 el estado queda desconocido, no se adivina', () {
      final result = parser.parse(mensajeCon([
        'EQD+CN+ABCU1234567+22G1',
      ]));

      expect(result.containers.single.status, ContainerStatus.unknown);
    });
  });

  group('ContainerUnit', () {
    test('debe calcular tamaño en pies correctamente', () {
      const container20 = ContainerUnit(
        id: '1',
        containerId: 'TEST1',
        isoSizeType: '22G1',
      );
      expect(container20.sizeInFeet, 20);

      const container40 = ContainerUnit(
        id: '2',
        containerId: 'TEST2',
        isoSizeType: '45R1',
      );
      expect(container40.sizeInFeet, 40);
    });

    test('debe identificar tipo de contenedor', () {
      const dryContainer = ContainerUnit(
        id: '1',
        containerId: 'TEST1',
        isoSizeType: '22G1',
      );
      expect(dryContainer.containerType, ContainerType.generalPurpose);

      const reeferContainer = ContainerUnit(
        id: '2',
        containerId: 'TEST2',
        isoSizeType: '45R1',
      );
      expect(reeferContainer.containerType, ContainerType.reefer);
    });

    test('debe identificar altura correctamente', () {
      const standardHeight = ContainerUnit(
        id: '1',
        containerId: 'TEST1',
        isoSizeType: '22G1',
      );
      expect(standardHeight.height, ContainerHeight.standard);

      const highCube = ContainerUnit(
        id: '2',
        containerId: 'TEST2',
        isoSizeType: '45R1',
      );
      expect(highCube.height, ContainerHeight.highCube);
    });

    test('debe calcular peso neto', () {
      const container = ContainerUnit(
        id: '1',
        containerId: 'TEST1',
        grossWeight: 25000,
        tareWeight: 2200,
      );
      expect(container.netWeight, 22800);
    });
  });

  group('Bay', () {
    test('debe agregar contenedor y actualizar slot', () {
      const container = ContainerUnit(
        id: '1',
        containerId: 'TEST1',
        stowagePosition: IsoCoordinate(
          bay: 10,
          row: 1,
          tier: 2,
          rawCode: '0100102',
        ),
      );

      const bay = Bay(bayNumber: 10);
      final updatedBay = bay.addContainer(container);

      expect(updatedBay.containers.length, 1);
      expect(updatedBay.slots.length, 1);
      expect(updatedBay.hasContainerAt(1, 2), isTrue);
    });

    test('debe calcular ocupación correctamente', () {
      const container1 = ContainerUnit(
        id: '1',
        containerId: 'TEST1',
        stowagePosition: IsoCoordinate(bay: 10, row: 1, tier: 2, rawCode: '0100102'),
      );
      const container2 = ContainerUnit(
        id: '2',
        containerId: 'TEST2',
        stowagePosition: IsoCoordinate(bay: 10, row: 2, tier: 2, rawCode: '0100202'),
      );

      const bay = Bay(bayNumber: 10);
      final updatedBay = bay.addContainer(container1).addContainer(container2);

      expect(updatedBay.occupiedSlots, 2);
    });

    test('debe acumular el peso bruto por nivel', () {
      const deckContainer1 = ContainerUnit(
        id: '1',
        containerId: 'DECK1',
        grossWeight: 50000,
        stowagePosition: IsoCoordinate(bay: 10, row: 1, tier: 82, rawCode: '0100182'),
      );
      const deckContainer2 = ContainerUnit(
        id: '2',
        containerId: 'DECK2',
        grossWeight: 45000,
        stowagePosition: IsoCoordinate(bay: 10, row: 2, tier: 82, rawCode: '0100282'),
      );
      const holdContainer = ContainerUnit(
        id: '3',
        containerId: 'HOLD1',
        grossWeight: 25000,
        stowagePosition: IsoCoordinate(bay: 10, row: 1, tier: 6, rawCode: '0100106'),
      );
      const containerWithoutWeight = ContainerUnit(
        id: '4',
        containerId: 'HOLD2',
        stowagePosition: IsoCoordinate(bay: 10, row: 2, tier: 6, rawCode: '0100206'),
      );
      const containerWithoutPosition = ContainerUnit(
        id: '5',
        containerId: 'NO_POSITION',
      );

      const bay = Bay(
        bayNumber: 10,
        containers: [
          deckContainer1,
          deckContainer2,
          holdContainer,
          containerWithoutWeight,
          containerWithoutPosition,
        ],
      );

      expect(bay.weightByTier[82], 95000);
      expect(bay.weightByTier[6], 25000);
      expect(bay.weightByTier.length, 2);
      expect(bay.weightByTier.values.reduce((a, b) => a + b), bay.totalWeight);
    });
  });
}
