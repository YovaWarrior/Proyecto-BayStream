import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

/// Coordenadas que reproducen el patrón del corpus real sin depender de los
/// archivos, que viven fuera del repositorio.
///
/// `CORPUS_A01`: filas 01 a 12 sin fila 00, bodega 02 a 14, cubierta 82 a 90.
List<IsoCoordinate> _corpusA01Pattern() => [
      IsoCoordinateParser.parse('0061202'), // fila par máxima, nivel mínimo
      IsoCoordinateParser.parse('0061114'), // fila impar máxima, bodega máxima
      IsoCoordinateParser.parse('0060182'), // cubierta mínima observada
      IsoCoordinateParser.parse('0060290'), // cubierta máxima observada
    ];

void main() {
  group('VesselGeometry.proposeFrom', () {
    test('deduce la geometría mínima del patrón de CORPUS_A01', () {
      final geometry = VesselGeometry.proposeFrom(_corpusA01Pattern());

      expect(geometry.portRows, 6, reason: 'filas 02 a 12');
      expect(geometry.starboardRows, 6, reason: 'filas 01 a 11');
      expect(geometry.holdTiers, 7, reason: 'niveles 02 a 14');
      expect(geometry.deckTiers, 6, reason: 'niveles 80 a 90');
    });

    test('con carga hasta el nivel 90 propone el nivel 80 que el archivo nunca trae',
        () {
      // Los siete archivos del corpus solo traen cubierta 82, 84, 86, 88 y 90.
      // El plano impreso del MIZAR tiene seis niveles, incluido el 80 vacío.
      // Anclar en el máximo observado y no en la cantidad de valores distintos
      // es lo que rescata ese nivel.
      final geometry = VesselGeometry.proposeFrom([
        IsoCoordinateParser.parse('0060182'),
        IsoCoordinateParser.parse('0060184'),
        IsoCoordinateParser.parse('0060186'),
        IsoCoordinateParser.parse('0060188'),
        IsoCoordinateParser.parse('0060190'),
      ]);

      expect(geometry.deckTiers, 6);
      expect(geometry.deckTierNumbers, [90, 88, 86, 84, 82, 80]);
    });

    test('el límite de apilamiento nunca se propone', () {
      final geometry = VesselGeometry.proposeFrom(_corpusA01Pattern());

      expect(geometry.stackWeightLimitKg, isNull);
    });

    test('la fila 00 ocupada no altera el conteo de babor ni de estribor', () {
      // El patrón de CORPUS_A03: filas 00 a 10.
      final geometry = VesselGeometry.proposeFrom([
        IsoCoordinateParser.parse('0060002'), // fila central
        IsoCoordinateParser.parse('0061002'),
        IsoCoordinateParser.parse('0060902'),
        IsoCoordinateParser.parse('0060114'),
        IsoCoordinateParser.parse('0060190'),
      ]);

      expect(geometry.portRows, 5, reason: 'filas 02 a 10');
      expect(geometry.starboardRows, 5, reason: 'filas 01 a 09');
    });
  });

  group('VesselGeometry · rejilla derivada', () {
    const geometry = VesselGeometry(
      portRows: 6,
      starboardRows: 6,
      holdTiers: 7,
      deckTiers: 6,
    );

    test('las columnas van pares descendentes, la fila 00 y luego impares', () {
      expect(
        geometry.orderedRows,
        [12, 10, 8, 6, 4, 2, 0, 1, 3, 5, 7, 9, 11],
      );
    });

    test('la fila 00 se incluye aunque el archivo no la traiga ocupada', () {
      expect(geometry.orderedRows.contains(VesselGeometry.centerRow), isTrue);
      expect(geometry.orderedRows.length, 13);
    });

    test('los niveles salen separados y descendentes', () {
      expect(geometry.deckTierNumbers, [90, 88, 86, 84, 82, 80]);
      expect(geometry.holdTierNumbers, [14, 12, 10, 8, 6, 4, 2]);
      expect(geometry.totalTiers, 13);
    });

    test('los huecos por bahía son columnas por niveles', () {
      expect(geometry.slotsPerBay, 169, reason: '13 columnas x 13 niveles');
    });
  });

  group('VesselGeometry · validación', () {
    const minimum = VesselGeometry(
      portRows: 6,
      starboardRows: 6,
      holdTiers: 7,
      deckTiers: 6,
    );

    test('declarar más que el mínimo observado es válido', () {
      const declared = VesselGeometry(
        portRows: 7,
        starboardRows: 7,
        holdTiers: 8,
        deckTiers: 7,
      );

      expect(declared.isAtLeast(minimum), isTrue);
    });

    test('declarar menos que el mínimo dejaría carga fuera del plano', () {
      const declared = VesselGeometry(
        portRows: 6,
        starboardRows: 6,
        holdTiers: 7,
        deckTiers: 5, // el archivo trae carga en el nivel 90
      );

      expect(declared.isAtLeast(minimum), isFalse);
    });

    test('covers deja fuera la posición que excede la geometría declarada', () {
      expect(minimum.covers(IsoCoordinateParser.parse('0061290')), isTrue);
      expect(minimum.covers(IsoCoordinateParser.parse('0061490')), isFalse);
      expect(minimum.covers(IsoCoordinateParser.parse('0061292')), isFalse);
      expect(minimum.covers(IsoCoordinateParser.parse('0060002')), isTrue);
    });
  });

  group('Bay.occupancyRate', () {
    const geometry = VesselGeometry(
      portRows: 6,
      starboardRows: 6,
      holdTiers: 7,
      deckTiers: 6,
    );

    const container = ContainerUnit(
      id: '1',
      containerId: 'TEST1',
      stowagePosition: IsoCoordinate(
        bay: 6,
        row: 1,
        tier: 2,
        rawCode: '0060102',
      ),
    );

    test('se calcula contra la geometría declarada, no contra 120 huecos', () {
      const bay = Bay(bayNumber: 6, geometry: geometry);
      final loaded = bay.addContainer(container);

      expect(loaded.occupancyRate, closeTo(1 / 169 * 100, 0.0001));
    });

    test('sin geometría declarada no hay porcentaje, y no se inventa uno', () {
      const bay = Bay(bayNumber: 6);
      final loaded = bay.addContainer(container);

      expect(loaded.occupancyRate, isNull);
    });

    test('una bahía vacía es 0 % contra cualquier capacidad', () {
      const bay = Bay(bayNumber: 6);

      expect(bay.occupancyRate, 0.0);
    });
  });

  group('Persistencia de la geometría', () {
    const geometry = VesselGeometry(
      portRows: 6,
      starboardRows: 6,
      holdTiers: 7,
      deckTiers: 6,
      stackWeightLimitKg: 90000,
    );

    const container = ContainerUnit(
      id: '1',
      containerId: 'TEST1',
      stowagePosition: IsoCoordinate(
        bay: 6,
        row: 1,
        tier: 2,
        rawCode: '0060102',
      ),
    );

    VesselVoyage buildVoyage() {
      final bay = const Bay(bayNumber: 6).addContainer(container);
      return VesselVoyage(
        id: 'viaje-prueba',
        vessel: const Vessel(id: 'buque-prueba', name: 'Buque Prueba'),
        voyageNumber: 'V001',
        containers: const [container],
        bays: {6: bay},
      ).withGeometry(geometry);
    }

    test('withGeometry la propaga a todas las bahías', () {
      final voyage = buildVoyage();

      expect(voyage.geometry, geometry);
      expect(voyage.bays[6]!.geometry, geometry);
    });

    test('la geometría se serializa una sola vez, no en cada bahía', () {
      final json = buildVoyage().toJson();
      final bayJson = (json['bays'] as Map<String, dynamic>)['6']
          as Map<String, dynamic>;

      expect(json['geometry'], isNotNull);
      expect(bayJson.containsKey('geometry'), isFalse);
    });

    test('el viaje vuelve de Firestore con la geometría puesta en cada bahía',
        () {
      // El hueco que se está tapando: si la geometría no diera la vuelta, la
      // ocupación caería en silencio al respaldo de 12 x 10 = 120 huecos.
      final restored = VesselVoyage.fromJson(buildVoyage().toJson());

      expect(restored.geometry, geometry);
      expect(restored.bays[6]!.geometry, geometry);
      expect(restored.bays[6]!.occupancyRate, closeTo(1 / 169 * 100, 0.0001));
    });

    test('un documento anterior a C-3 no produce un porcentaje inventado', () {
      final json = buildVoyage().toJson()..remove('geometry');

      final restored = VesselVoyage.fromJson(json);

      expect(restored.geometry, isNull);
      expect(restored.bays[6]!.geometry, isNull);
      expect(restored.bays[6]!.occupancyRate, isNull);
    });
  });
}
