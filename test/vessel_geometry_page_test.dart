import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_geometry_page.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Propuesta equivalente a la que deduce CORPUS_A01.
const _proposal = VesselGeometry(
  portRows: 6,
  starboardRows: 6,
  holdTiers: [2, 4, 6, 8, 10, 12, 14],
  deckTiers: [82, 84, 86, 88, 90],
);

/// Carga del viaje: niveles 90 y 02 ocupados, el resto vacios.
final _posiciones = [
  IsoCoordinateParser.parse('0061290'),
  IsoCoordinateParser.parse('0060102'),
];

void main() {
  /// Abre la pantalla y deja el resultado en [captured] al cerrarse.
  Future<void> openPage(
    WidgetTester tester,
    void Function(VesselCallParameters?) captured, {
    VesselGeometry? initial,
    Map<String, int> loadingPorts = const {'GTPBR': 3, 'HNPCR': 2},
    String? declaredPort,
  }) async {
    tester.view.physicalSize = const Size(1000, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  final result =
                      await Navigator.of(context).push<VesselCallParameters>(
                    MaterialPageRoute(
                      builder: (_) => VesselGeometryPage(
                        proposal: _proposal,
                        positions: _posiciones,
                        loadingPorts: loadingPorts,
                        declaredPort: declaredPort,
                        initial: initial,
                        fileName: 'CORPUS_A01.edi',
                      ),
                    ),
                  );
                  captured(result);
                },
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  bool confirmEnabled(WidgetTester tester) =>
      tester
          .widget<FilledButton>(find.byKey(const ValueKey('geometry-confirm')))
          .onPressed !=
      null;

  testWidgets('llega con la propuesta precargada y rotulada como mínimo',
      (tester) async {
    await openPage(tester, (_) {});

    expect(find.text('Lo propuesto es un mínimo observado'), findsOneWidget);
    expect(
      find.text('Mínimo observado en el archivo: 6. El buque puede tener más.'),
      findsWidgets,
    );
    // Los niveles llegan como chips, uno por nivel de la corrida anclada.
    for (final tier in ['82', '84', '86', '88', '90']) {
      expect(find.byKey(ValueKey('deck-tier-$tier')), findsOneWidget,
          reason: 'cubierta $tier');
    }
    for (final tier in ['02', '04', '06', '08', '10', '12', '14']) {
      expect(find.byKey(ValueKey('hold-tier-$tier')), findsOneWidget,
          reason: 'bodega $tier');
    }
  });

  testWidgets('la propuesta sin tocar no se rotula como corregida',
      (tester) async {
    await openPage(tester, (_) {});

    // Los niveles se comparan por contenido: la pantalla trabaja sobre copias
    // de las listas de la propuesta, y compararlas por identidad rotulaba como
    // corregida una geometria que nadie habia tocado.
    expect(find.text('Geometría igual al mínimo observado en el archivo.'),
        findsOneWidget);
    expect(find.text('Geometría corregida por el usuario.'), findsNothing);
  });

  testWidgets('al quitar un nivel sí se rotula como corregida', (tester) async {
    await openPage(tester, (_) {});

    tester
        .widget<InputChip>(find.byKey(const ValueKey('deck-tier-84')))
        .onDeleted!();
    await tester.pumpAndSettle();

    expect(find.text('Geometría corregida por el usuario.'), findsOneWidget);
  });

  testWidgets('un nivel con carga no se puede quitar', (tester) async {
    await openPage(tester, (_) {});

    // El 90 trae carga en este viaje; el 84 no.
    final conCarga =
        tester.widget<InputChip>(find.byKey(const ValueKey('deck-tier-90')));
    final vacio =
        tester.widget<InputChip>(find.byKey(const ValueKey('deck-tier-84')));

    expect(conCarga.onDeleted, isNull, reason: 'el 90 trae carga');
    expect(vacio.onDeleted, isNotNull, reason: 'el 84 esta vacio');
  });

  testWidgets('quitar un nivel vacío deja el hueco en la geometría',
      (tester) async {
    VesselCallParameters? captured;
    await openPage(tester, (value) => captured = value);

    // Se invoca el contrato del chip y no su icono, que cambia con el tema.
    tester
        .widget<InputChip>(find.byKey(const ValueKey('deck-tier-84')))
        .onDeleted!();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('geometry-no-limit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('geometry-confirm')));
    await tester.pumpAndSettle();

    expect(captured!.geometry.deckTierNumbers, [90, 88, 86, 82]);
    expect(captured!.geometry.totalTiers, 11);
  });

  testWidgets('se puede volver a agregar un nivel quitado', (tester) async {
    await openPage(tester, (_) {});

    // Se invoca el contrato del chip y no su icono, que cambia con el tema.
    tester
        .widget<InputChip>(find.byKey(const ValueKey('deck-tier-84')))
        .onDeleted!();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('deck-tier-84')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('deck-add')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('deck-add-84')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('deck-tier-84')), findsOneWidget);
  });

  testWidgets('Confirmar queda deshabilitado hasta resolver el límite',
      (tester) async {
    await openPage(tester, (_) {});

    expect(confirmEnabled(tester), isFalse);
    expect(find.text('Falta resolver el límite de apilamiento.'),
        findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('geometry-stack-limit')),
      '90000',
    );
    await tester.pumpAndSettle();

    expect(confirmEnabled(tester), isTrue);
  });

  testWidgets('«No lo tengo» habilita Confirmar y no inventa un umbral',
      (tester) async {
    VesselCallParameters? captured;
    await openPage(tester, (value) => captured = value);

    await tester.tap(find.byKey(const ValueKey('geometry-no-limit')));
    await tester.pumpAndSettle();

    expect(confirmEnabled(tester), isTrue);

    await tester.tap(find.byKey(const ValueKey('geometry-confirm')));
    await tester.pumpAndSettle();

    expect(captured, isNotNull);
    expect(captured!.geometry.stackWeightLimitKg, isNull);
  });

  testWidgets('bajar las filas por debajo del mínimo explica qué queda fuera',
      (tester) async {
    await openPage(tester, (_) {});

    await tester.enterText(
      find.byKey(const ValueKey('geometry-port-rows')),
      '4',
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        'El archivo trae carga en la fila 12; con 4 filas a babor quedaría '
        'fuera del plano.',
      ),
      findsOneWidget,
    );
    expect(confirmEnabled(tester), isFalse);
  });

  testWidgets('subir por encima del mínimo se acepta sin objeción',
      (tester) async {
    VesselCallParameters? captured;
    await openPage(tester, (value) => captured = value);

    await tester.enterText(
      find.byKey(const ValueKey('geometry-port-rows')),
      '8',
    );
    await tester.enterText(
      find.byKey(const ValueKey('geometry-stack-limit')),
      '90000',
    );
    await tester.pumpAndSettle();

    expect(confirmEnabled(tester), isTrue);

    await tester.tap(find.byKey(const ValueKey('geometry-confirm')));
    await tester.pumpAndSettle();

    expect(captured!.geometry.portRows, 8);
    expect(captured!.geometry.stackWeightLimitKg, 90000);
    expect(captured!.geometry.slotsPerBay, 15 * 12);
  });

  testWidgets('cancelar no devuelve geometría', (tester) async {
    var called = false;
    VesselCallParameters? captured;
    await openPage(tester, (value) {
      called = true;
      captured = value;
    });

    await tester.tap(find.byKey(const ValueKey('geometry-cancel')));
    await tester.pumpAndSettle();

    expect(called, isTrue);
    expect(captured, isNull);
  });

  group('C-5a · puerto de esta escala', () {
    testWidgets('propone el puerto más frecuente y muestra el reparto',
        (tester) async {
      await openPage(tester, (_) {});

      expect(
        tester
            .widget<ChoiceChip>(find.byKey(const ValueKey('port-GTPBR')))
            .selected,
        isTrue,
        reason: 'GTPBR es el mas frecuente con 3',
      );
      expect(
        find.text('3 se operan en esta escala y 2 ya vienen a bordo, de paso.'),
        findsOneWidget,
      );
    });

    testWidgets('propone el que declara el archivo, no el mas cargado',
        (tester) async {
      // PAMIT no aparece en ningun LOC+9 del viaje: se ofrece igual porque lo
      // declara la cabecera, y el reparto dice la verdad, que es que toda la
      // carga a bordo viene de otro sitio.
      await openPage(tester, (_) {}, declaredPort: 'PAMIT');

      expect(
        tester
            .widget<ChoiceChip>(find.byKey(const ValueKey('port-PAMIT')))
            .selected,
        isTrue,
      );
      expect(find.text('PAMIT'), findsOneWidget);
      expect(
        find.text('0 se operan en esta escala y 5 ya vienen a bordo, de paso.'),
        findsOneWidget,
      );
    });

    testWidgets('el puerto declarado se ofrece primero', (tester) async {
      await openPage(tester, (_) {}, declaredPort: 'PAMIT');

      final etiquetas = tester
          .widgetList<ChoiceChip>(find.byType(ChoiceChip))
          .map((chip) => (chip.label as Text).data)
          .toList();

      expect(etiquetas, ['PAMIT', 'GTPBR (3)', 'HNPCR (2)', 'Sin declarar']);
    });

    testWidgets('el texto nombra el puerto que declara el archivo',
        (tester) async {
      await openPage(tester, (_) {}, declaredPort: 'GTPBR');

      expect(
        find.textContaining('El archivo declara GTPBR como puerto de salida'),
        findsOneWidget,
      );
    });

    testWidgets('sin LOC+9 en la carga sigue habiendo puerto que declarar',
        (tester) async {
      // CORPUS_A06: ningun contenedor dice donde se cargo. Antes no habia un
      // solo chip que elegir y la escala quedaba sin declarar por falta de
      // opciones, no por decision del usuario.
      await openPage(
        tester,
        (_) {},
        loadingPorts: const {},
        declaredPort: 'GTPBR',
      );

      expect(
        tester
            .widget<ChoiceChip>(find.byKey(const ValueKey('port-GTPBR')))
            .selected,
        isTrue,
      );
      expect(
        find.textContaining('la carga de paso no se puede separar'),
        findsOneWidget,
      );
    });

    testWidgets('corregir el puerto recalcula el reparto', (tester) async {
      await openPage(tester, (_) {});

      await tester.tap(find.byKey(const ValueKey('port-HNPCR')));
      await tester.pumpAndSettle();

      expect(
        find.text('2 se operan en esta escala y 3 ya vienen a bordo, de paso.'),
        findsOneWidget,
      );
    });

    testWidgets('sin declarar el puerto no se distingue la carga de paso',
        (tester) async {
      VesselCallParameters? captured;
      await openPage(tester, (value) => captured = value);

      await tester.tap(find.byKey(const ValueKey('port-none')));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('no se distingue la carga de paso'),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('geometry-no-limit')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('geometry-confirm')));
      await tester.pumpAndSettle();

      expect(captured!.portOfCall, isNull);
    });

    testWidgets('el puerto elegido viaja en el resultado', (tester) async {
      VesselCallParameters? captured;
      await openPage(tester, (value) => captured = value);

      await tester.tap(find.byKey(const ValueKey('port-HNPCR')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('geometry-no-limit')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('geometry-confirm')));
      await tester.pumpAndSettle();

      expect(captured!.portOfCall, 'HNPCR');
    });
  });

  group('Invariante de publicación', () {
    test('confirmGeometry propaga la geometría a todas las bahías', () {
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
      final voyage = VesselVoyage(
        id: 'viaje-prueba',
        vessel: const Vessel(id: 'buque-prueba', name: 'Buque Prueba'),
        voyageNumber: 'V001',
        containers: const [container],
        bays: {6: const Bay(bayNumber: 6).addContainer(container)},
      );

      final providerContainer = ProviderContainer(
        overrides: [
          voyageNotifierProvider.overrideWith(() => _SeededVoyageNotifier(voyage)),
        ],
      );
      addTearDown(providerContainer.dispose);

      // Antes de confirmar no hay geometría y la ocupación no es calculable.
      expect(providerContainer.read(voyageNotifierProvider).value!.geometry, isNull);
      expect(
        providerContainer.read(voyageNotifierProvider).value!.bays[6]!.occupancyRate,
        isNull,
      );

      providerContainer
          .read(voyageNotifierProvider.notifier)
          .confirmGeometry(_proposal);

      final published = providerContainer.read(voyageNotifierProvider).value!;
      expect(published.geometry, _proposal);
      expect(published.bays[6]!.geometry, _proposal);
      expect(published.bays[6]!.occupancyRate, isNotNull);
    });
  });
}

class _SeededVoyageNotifier extends VoyageNotifier {
  final VesselVoyage voyage;

  _SeededVoyageNotifier(this.voyage);

  @override
  AsyncValue<VesselVoyage?> build() => AsyncValue.data(voyage);
}
