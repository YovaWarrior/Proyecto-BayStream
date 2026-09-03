import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/widgets/bay_plan_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Geometría equivalente a la que se deduce de CORPUS_A01:
/// 13 columnas (6 babor + fila 00 + 6 estribor) por 12 niveles (5 cubierta,
/// del 82 al 90, y 7 bodega) = 156 huecos por bahía.
const _geometry = VesselGeometry(
  portRows: 6,
  starboardRows: 6,
  holdTiers: 7,
  deckTiers: 5,
);

ContainerUnit _container(String rawCode, {String? id}) {
  final position = IsoCoordinateParser.parse(rawCode);
  return ContainerUnit(
    id: id ?? rawCode,
    containerId: id ?? 'CONT$rawCode',
    grossWeight: 18000,
    stowagePosition: position,
  );
}

VesselVoyage _voyage(
  List<ContainerUnit> containers, {
  VesselGeometry? geometry = _geometry,
}) {
  var bay = const Bay(bayNumber: 6);
  for (final container in containers) {
    bay = bay.addContainer(container);
  }
  final voyage = VesselVoyage(
    id: 'viaje-prueba',
    vessel: const Vessel(id: 'buque-prueba', name: 'Buque Prueba'),
    voyageNumber: 'V001',
    containers: containers,
    bays: {6: bay},
  );
  return geometry == null ? voyage : voyage.withGeometry(geometry);
}

Future<void> pumpPlan(WidgetTester tester, VesselVoyage voyage) async {
  tester.view.physicalSize = const Size(1600, 2200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(home: Scaffold(body: BayPlanView(voyage: voyage))),
    ),
  );
  await tester.pumpAndSettle();
}

Iterable<String> cellKeys(WidgetTester tester) => tester
    .widgetList(
      find.byWidgetPredicate(
        (widget) =>
            widget.key is ValueKey<String> &&
            (widget.key as ValueKey<String>).value.startsWith('cell-'),
      ),
    )
    .map((widget) => (widget.key as ValueKey<String>).value);

void main() {
  final cargo = [
    _container('0060102'),
    _container('0061214'),
    _container('0060190'),
    _container('0061182'),
  ];

  group('C-2 · columnas', () {
    testWidgets('dibuja la fila 00 al centro aunque no venga ocupada',
        (tester) async {
      await pumpPlan(tester, _voyage(cargo));

      // Ningún contenedor de la carga está en la fila 00 y aun así se dibuja.
      expect(cargo.every((c) => c.stowagePosition!.row != 0), isTrue);
      expect(find.text('00'), findsOneWidget);
      expect(cellKeys(tester).contains('cell-0-90'), isTrue);
      expect(cellKeys(tester).contains('cell-0-02'), isFalse,
          reason: 'la clave usa el número de nivel sin relleno');
      expect(cellKeys(tester).contains('cell-0-2'), isTrue);
    });

    testWidgets('las trece columnas salen de la geometría, no del contenido',
        (tester) async {
      // Un solo contenedor en la fila 01: la rejilla igual trae 13 columnas.
      await pumpPlan(tester, _voyage([_container('0060102')]));

      final rowsDrawn = cellKeys(tester)
          .map((key) => int.parse(key.split('-')[1]))
          .toSet();

      expect(rowsDrawn, _geometry.orderedRows.toSet());
      expect(rowsDrawn.length, 13);
    });
  });

  group('C-4 · niveles', () {
    testWidgets('la cubierta va del 90 al 82, sin fila vacia debajo del 82',
        (tester) async {
      await pumpPlan(tester, _voyage(cargo));

      for (final tier in [90, 88, 86, 84, 82]) {
        expect(find.text('$tier'), findsOneWidget, reason: 'nivel $tier');
      }
      // La primera fila de contenedores sobre cubierta va en el 82: anclar en
      // el 80 dibujaba una fila vacia fantasma bajo toda la carga.
      expect(find.text('80'), findsNothing);
    });

    testWidgets('no existe el desierto de celdas entre los niveles 16 y 78',
        (tester) async {
      await pumpPlan(tester, _voyage(cargo));

      for (final tier in [16, 20, 40, 60, 78]) {
        expect(find.text('$tier'), findsNothing, reason: 'nivel inventado $tier');
      }
    });

    testWidgets('la bahía dibuja 156 celdas, no las 540 del rango continuo',
        (tester) async {
      await pumpPlan(tester, _voyage(cargo));

      expect(cellKeys(tester).length, 156);
      expect(cellKeys(tester).toSet().length, 156, reason: 'sin repetidas');
    });

    testWidgets('cubierta y bodega se calculan por separado', (tester) async {
      await pumpPlan(tester, _voyage(cargo));

      final tiersDrawn = cellKeys(tester)
          .map((key) => int.parse(key.split('-')[2]))
          .toSet();

      expect(
        tiersDrawn,
        {..._geometry.deckTierNumbers, ..._geometry.holdTierNumbers},
      );
      expect(tiersDrawn.where((t) => t >= 80).length, 5);
      expect(tiersDrawn.where((t) => t < 80).length, 7);
    });
  });

  group('Carga que la rejilla no alcanza a representar', () {
    testWidgets('un contenedor fuera de la geometría no desaparece en silencio',
        (tester) async {
      // El nivel 03 es impar: la numeración ISO ancla los niveles de bodega de
      // dos en dos, así que ninguna geometría declarable le da una celda.
      final conNivelImpar = [..._voyageCargo(), _container('0060103')];

      await pumpPlan(tester, _voyage(conNivelImpar));

      expect(find.byKey(const ValueKey('outside-geometry-notice')),
          findsOneWidget);
      expect(find.textContaining('1 contenedor fuera de la geometría'),
          findsOneWidget);
      expect(find.textContaining('0060103'), findsOneWidget);
    });

    testWidgets('sin carga fuera de la rejilla no se muestra ningún aviso',
        (tester) async {
      await pumpPlan(tester, _voyage(cargo));

      expect(find.byKey(const ValueKey('outside-geometry-notice')),
          findsNothing);
    });
  });

  group('Sin geometría declarada', () {
    testWidgets('no se dibuja una rejilla inferida del contenido',
        (tester) async {
      await pumpPlan(tester, _voyage(cargo, geometry: null));

      expect(cellKeys(tester), isEmpty);
      expect(
        find.textContaining('no trae la geometría del buque declarada'),
        findsOneWidget,
      );
    });
  });
}

List<ContainerUnit> _voyageCargo() => [
      _container('0060102'),
      _container('0061214'),
    ];
