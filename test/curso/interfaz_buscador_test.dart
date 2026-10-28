import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/container_search_delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/t76_fixture.dart' show t76Unit;

void main() {
  testWidgets('abre el buscador, filtra por número y devuelve el contenedor',
      (tester) async {
    // Arrange
    final unidades = [
      t76Unit('CSQU3054383', '0030282'),
      t76Unit('AAAU0000060', '0050282'),
    ];
    final estado = ProviderContainer();
    addTearDown(estado.dispose);
    ContainerUnit? seleccionado;
    await tester.pumpWidget(UncontrolledProviderScope(
      container: estado,
      child: _aplicacion(unidades, (valor) => seleccionado = valor),
    ));

    // Act
    await tester.tap(find.text('Buscar contenedor'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '305438');
    await tester.pump();

    // Assert
    expect(find.text('CSQU3054383', findRichText: true), findsOneWidget);
    expect(find.text('AAAU0000060', findRichText: true), findsNothing);
    expect(find.byType(ListTile), findsOneWidget);

    // Act: elegir el resultado cierra showSearch y resuelve su Future.
    await tester.tap(find.text('CSQU3054383', findRichText: true));
    await tester.pumpAndSettle();

    // Assert
    expect(seleccionado, same(unidades.first));
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Buscar contenedor'), findsOneWidget);
    expect(estado.read(selectedBayProvider), 3);
    expect(estado.read(highlightedContainerProvider), 'CSQU3054383');
  });

  testWidgets('muestra en español que la búsqueda no tiene resultados',
      (tester) async {
    // Arrange
    var devolvioSeleccion = false;
    await tester.pumpWidget(ProviderScope(
      child: _aplicacion(
        [t76Unit('CSQU3054383', '0030282')],
        (_) => devolvioSeleccion = true,
      ),
    ));

    // Act
    await tester.tap(find.text('Buscar contenedor'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '999999');
    await tester.pump();

    // Assert
    expect(find.text('Sin resultados para "999999"'), findsOneWidget);
    expect(find.text('Intenta con otro término de búsqueda'), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
    expect(devolvioSeleccion, isFalse);
  });
}

Widget _aplicacion(
  List<ContainerUnit> unidades,
  void Function(ContainerUnit?) alSeleccionar,
) =>
    MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        body: Consumer(builder: (context, ref, child) {
          return Center(
            child: FilledButton(
              onPressed: () async {
                final resultado = await showSearch<ContainerUnit?>(
                  context: context,
                  delegate:
                      ContainerSearchDelegate(containers: unidades, ref: ref),
                );
                alSeleccionar(resultado);
              },
              child: const Text('Buscar contenedor'),
            ),
          );
        }),
      ),
    );
