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
EQD+CN+MSCU1234567+22G1++++5'
MEA+AAE+WT+KGM:25000'
MEA+AAE+VGM+KGM:25500'
LOC+147+0120106:::5'
EQD+CN+TCNU7654321+45R1++++5'
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
EQD+CN+CONT001+22G1++++5'
LOC+147+0100202:::5'
EQD+CN+CONT002+22G1++++5'
LOC+147+0200102:::5'
EQD+CN+CONT003+22G1++++5'
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
EQD+CN+CONT001+22G1++++5'
MEA+AAE+WT+KGM:20000'
LOC+147+0100202:::5'
EQD+CN+CONT002+22G1++++4'
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
EQD+CN+CONT001+22G1++++5'
UNT+4+1'
''';

      expect(
        () => parser.parse(invalidContent),
        throwsA(isA<Exception>()),
      );
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
  });
}
