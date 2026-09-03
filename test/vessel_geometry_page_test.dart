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
  holdTiers: 7,
  deckTiers: 6,
);

void main() {
  /// Abre la pantalla y deja el resultado en [captured] al cerrarse.
  Future<void> openPage(
    WidgetTester tester,
    void Function(VesselGeometry?) captured, {
    VesselGeometry? initial,
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
                      await Navigator.of(context).push<VesselGeometry>(
                    MaterialPageRoute(
                      builder: (_) => VesselGeometryPage(
                        proposal: _proposal,
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
    expect(
      tester
          .widget<TextFormField>(
            find.byKey(const ValueKey('geometry-deck-tiers')),
          )
          .controller
          ?.text,
      '6',
    );
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
    VesselGeometry? captured;
    await openPage(tester, (value) => captured = value);

    await tester.tap(find.byKey(const ValueKey('geometry-no-limit')));
    await tester.pumpAndSettle();

    expect(confirmEnabled(tester), isTrue);

    await tester.tap(find.byKey(const ValueKey('geometry-confirm')));
    await tester.pumpAndSettle();

    expect(captured, isNotNull);
    expect(captured!.stackWeightLimitKg, isNull);
  });

  testWidgets('bajar por debajo del mínimo explica qué carga quedaría fuera',
      (tester) async {
    await openPage(tester, (_) {});

    await tester.enterText(
      find.byKey(const ValueKey('geometry-deck-tiers')),
      '5',
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        'El archivo trae carga en el nivel 90; con 5 niveles de cubierta '
        'quedaría fuera del plano.',
      ),
      findsOneWidget,
    );
    expect(confirmEnabled(tester), isFalse);
  });

  testWidgets('subir por encima del mínimo se acepta sin objeción',
      (tester) async {
    VesselGeometry? captured;
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

    expect(captured!.portRows, 8);
    expect(captured!.stackWeightLimitKg, 90000);
    expect(captured!.slotsPerBay, 15 * 13);
  });

  testWidgets('cancelar no devuelve geometría', (tester) async {
    var called = false;
    VesselGeometry? captured;
    await openPage(tester, (value) {
      called = true;
      captured = value;
    });

    await tester.tap(find.byKey(const ValueKey('geometry-cancel')));
    await tester.pumpAndSettle();

    expect(called, isTrue);
    expect(captured, isNull);
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
