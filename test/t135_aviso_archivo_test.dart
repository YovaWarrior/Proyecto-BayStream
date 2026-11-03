// T-135 · El aviso «Archivo "null" cargado correctamente». Carlos lo vio en
// la candidata 0.4.2 (Edge, Chrome y el .exe): con el plano en previo, se
// confirma desde «Parámetros» → «Parámetros del buque» y no con «Confirmar»
// en la banda. Ese camino abría los parámetros sin el nombre del archivo, así
// que la pantalla no decía «Archivo: …» y el aviso final decía «null». Viene
// de la 10.32 (3.1.0).
//
// Los tres caminos, con el mismo plano en previo: la banda, «Parámetros» en
// el riel de la oficina y «Parámetros» en «Más» del teléfono. En los tres, la
// pantalla muestra el nombre, el aviso lo dice y ningún aviso dice «null».
//
// El archivo es un sintético de T-100 (tool/t100_sintetico.dart): BUQUE
// MANUAL, viaje M100, plan de carga que sale de GTSTC.
import 'dart:io';

import 'package:baystream/core/app.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_impl.dart';
import 'package:baystream/features/vessel/presentation/pages/parameters_page.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_geometry_page.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/voyage_ui_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../tool/t100_sintetico.dart' as t100;
import 'support/local_profile_test_support.dart';
import 'support/t117_oficina_support.dart' show t117CargarFuentes;
import 'support/t74_movement_log_support.dart';

const _archivo = 'T100_CARGA.edi';

/// Plan de carga de T-100, recortado: dos cajas de paso a USHOU y dos que
/// se cargaron en GTSTC.
final _planDeCarga = t100.mensaje([
  t100.Caja(t100.id(31), '42G1', t100.celda(2, 1, 2), 'HNPCR', 'USHOU', 'MNA',
      9000, true),
  t100.Caja(t100.id(32), '42G1', t100.celda(2, 2, 2), 'HNPCR', 'USMSY', 'MNB',
      9420, true),
  t100.Caja(t100.id(61), '45G1', t100.celda(2, 1, 4), t100.escala, 'USMSY',
      'MNB', 14000, true),
  t100.Caja(t100.id(62), '42G1', t100.celda(2, 2, 4), t100.escala, 'USHOU',
      'MNA', 14500, true),
], salida: t100.escala, siguiente: 'USHOU', ref: 'M100CARGA');

/// El notifier del producto, con el selector de archivos sustituido.
class _ReplayNotifier extends VoyageNotifier {
  @override
  Future<LoadFileResult> loadVesselFromFile() =>
      parseBaplieContent(_planDeCarga, fileName: _archivo);
}

void main() {
  late ProviderContainer container;
  late ({Directory directory, LocalVesselRepositoryImpl repository}) store;

  Future<void> abrir() async {
    store = await testProfileStore();
    container = ProviderContainer(overrides: [
      movementLogRepositoryProvider.overrideWith((ref) async => T74MemoryLog()),
      vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
      localVesselRepositoryProvider.overrideWith((ref) async => store.repository),
      voyageNotifierProvider.overrideWith(_ReplayNotifier.new),
    ]);
  }

  Future<void> cerrar() async {
    container.dispose();
    await store.repository.close();
    await store.directory.delete(recursive: true);
  }

  VoyageNotifier notifier() => container.read(voyageNotifierProvider.notifier);

  /// Abre la app con el plano en previo, como al elegir el archivo.
  ///
  /// Con las fuentes del producto: con la cuadrada de las pruebas, «Seguir al
  /// sistema» desborda el menú del tema de «Parámetros» a 360 dp. Y con el
  /// movimiento reducido: desde 840 dp el inicio lleva la travesía, que no
  /// termina nunca y no deja asentarse a pumpAndSettle.
  Future<void> enPrevio(WidgetTester tester, Size tamano) async {
    await t117CargarFuentes();
    tester.view.physicalSize = tamano;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container, child: const BayStreamApp()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('select-file')));
    await tester.pumpAndSettle();
    expect(container.read(voyageUiStateProvider), isA<Previo>());
    expect(notifier().loadedFileName, _archivo);
  }

  /// En «Parámetros del buque»: el nombre del archivo, «No lo tengo» en el
  /// apilamiento, la escala propuesta y confirmar.
  Future<void> confirmarParametros(WidgetTester tester) async {
    expect(find.byType(VesselGeometryPage), findsOneWidget);
    expect(find.text('Archivo: $_archivo'), findsOneWidget,
        reason: 'la pantalla dice qué archivo se está confirmando');
    expect(find.textContaining('null'), findsNothing);
    final lista = find.byType(Scrollable).first;
    for (final clave in ['geometry-no-limit', 'geometry-confirm']) {
      final control = find.byKey(ValueKey(clave));
      await tester.scrollUntilVisible(control, 300, scrollable: lista);
      await tester.ensureVisible(control);
      await tester.pumpAndSettle();
      await tester.tap(control);
      await tester.pumpAndSettle();
    }
    // Guardar el perfil y el viaje es E/S real: se espera fuera del reloj de
    // los widgets, como en t114_fase3_inicio_test.
    for (var intento = 0; intento < 500 && notifier().isPreview; intento++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    await tester.pumpAndSettle();
    expect(find.byType(VesselGeometryPage), findsNothing);
    expect(container.read(voyageUiStateProvider), isA<Publicado>());
    expect(notifier().publishedVoyage!.portOfCall, t100.escala);
  }

  void avisoConElNombre() {
    expect(find.text('Archivo "$_archivo" cargado correctamente'),
        findsOneWidget);
    expect(
        find.descendant(
            of: find.byType(SnackBar), matching: find.textContaining('null')),
        findsNothing,
        reason: 'ningún aviso dice «null»');
  }

  Future<void> caso(WidgetTester tester, Size tamano,
      Future<void> Function() abrirParametros) async {
    await tester.runAsync(() async {
      await abrir();
      try {
        await enPrevio(tester, tamano);
        await abrirParametros();
        await confirmarParametros(tester);
        avisoConElNombre();
        expect(tester.takeException(), isNull);
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        await cerrar();
      }
    });
  }

  Future<void> tocar(WidgetTester tester, Finder control) async {
    await tester.tap(control);
    await tester.pumpAndSettle();
  }

  group('el aviso del archivo cargado lleva su nombre', () {
    testWidgets('por «Confirmar» en la banda', (tester) async {
      await caso(tester, const Size(360, 800), () async {
        await tocar(tester, find.text('Confirmar'));
      });
    });

    testWidgets('por «Parámetros» en el riel de la oficina', (tester) async {
      await caso(tester, const Size(1280, 800), () async {
        await tocar(tester, find.byKey(const ValueKey('edit-geometry')));
        expect(find.byType(ParametersPage), findsOneWidget);
        await tocar(tester, find.text('Parámetros del buque'));
      });
    });

    testWidgets('por «Parámetros» en «Más» del teléfono', (tester) async {
      await caso(tester, const Size(360, 800), () async {
        await tocar(tester, find.byKey(const ValueKey('destino-mas')));
        await tocar(tester, find.byKey(const ValueKey('edit-geometry')));
        expect(find.byType(ParametersPage), findsOneWidget);
        await tocar(tester, find.text('Parámetros del buque'));
      });
    });
  });
}
