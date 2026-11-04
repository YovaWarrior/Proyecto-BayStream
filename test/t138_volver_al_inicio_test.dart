// T-138 · «Volver al inicio» (10.101). Volver al inicio solo se podía desde
// «Más» → «Cerrar el plano», y el subtítulo «Limpia los datos cargados en este
// dispositivo» sonaba a borrar. En la oficina, la marca del riel es ahora ese
// botón; en «Más» la entrada dice lo que de verdad hace; en el teléfono no hay
// botón suelto.
//
// `clearVoyage` solo suelta lo que está en memoria: el plano sigue en el
// almacén y en «Recientes en este dispositivo». El archivo es sintético: BUQUE
// MANUAL, con dos cajas en la bahía 002, un plan de carga que sale de GTSTC.
import 'dart:io';

import 'package:baystream/core/app.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_impl.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/voyage_ui_state.dart';
import 'package:baystream/features/vessel/presentation/widgets/navegacion_del_viaje.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/local_profile_test_support.dart';
import 'support/t117_oficina_support.dart' show t117CargarFuentes;
import 'support/t74_movement_log_support.dart';

const _planDeCarga = "UNH+1+BAPLIE:D:95B:UN:SMDG20'"
    "TDT+20+V01N+++NV2:172:20+++9000003:146:11:BUQUE MANUAL'"
    "LOC+5+GTSTC:139:6'"
    "LOC+147+0020182::5'LOC+9+GTSTC:139:6'LOC+11+USHOU:139:6'"
    "EQD+CN+TEST0000001+42G1+++5'"
    "LOC+147+0020184::5'LOC+9+GTSTC:139:6'LOC+11+USHOU:139:6'"
    "EQD+CN+TEST0000002+42G1+++5'";

const _oficina = Size(1280, 800);
const _telefono = Size(360, 800);

const _subtituloConfirmado = 'Sigue en Recientes; no se borra nada.';
const _subtituloPrevio = 'Descarta el previo sin guardar nada';

final _windows = TargetPlatformVariant.only(TargetPlatform.windows);
final _marca = find.byKey(const ValueKey('riel-volver-al-inicio'));
final _entrada = find.byKey(const ValueKey('mas-cerrar'));

void main() {
  late ProviderContainer container;
  late ({Directory directory, LocalVesselRepositoryImpl repository}) store;

  VoyageNotifier notifier() => container.read(voyageNotifierProvider.notifier);

  Future<void> abrir() async {
    store = await testProfileStore();
    container = ProviderContainer(overrides: [
      movementLogRepositoryProvider.overrideWith((ref) async => T74MemoryLog()),
      vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
      localVesselRepositoryProvider.overrideWith((ref) async => store.repository),
    ]);
  }

  Future<void> cerrar() async {
    container.dispose();
    await store.repository.close();
    await store.directory.delete(recursive: true);
  }

  Future<void> enPrevio() async {
    final carga =
        await notifier().parseBaplieContent(_planDeCarga, fileName: 'carga.edi');
    expect(carga.preview, isTrue);
  }

  Future<void> confirmado() async {
    await enPrevio();
    expect(
        await notifier().confirmGeometry(notifier().currentProfile!.geometry,
            portOfCall: 'GTSTC', sourceKind: OperationSourceKind.loadingBaplie),
        isNull);
    expect(notifier().isPreview, isFalse);
  }

  /// Con las fuentes del producto y el movimiento reducido: desde 840 dp el
  /// inicio lleva la travesía, que no deja asentarse a pumpAndSettle.
  Future<void> pintar(WidgetTester tester, Size tamano) async {
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
  }

  Future<void> caso(WidgetTester tester, Future<void> Function() cuerpo) async {
    await tester.runAsync(() async {
      await abrir();
      try {
        await cuerpo();
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

  /// La lista del inicio se lee del almacén: es E/S real, fuera del reloj de
  /// los widgets.
  Future<void> esperarRecientes(WidgetTester tester) async {
    for (var intento = 0;
        intento < 500 && !container.read(recentVoyagesProvider).hasValue;
        intento++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    await tester.pumpAndSettle();
  }

  group('la marca del riel', () {
    testWidgets('a 1280, con un plano confirmado, vuelve al inicio y el plano '
        'sigue en Recientes', (tester) async {
      await caso(tester, () async {
        await confirmado();
        await pintar(tester, _oficina);
        expect(container.read(voyageUiStateProvider), isA<Publicado>());

        await tocar(tester, _marca);

        expect(find.text('¿Descartar el plano sin confirmar?'), findsNothing,
            reason: 'un plano confirmado no pregunta');
        expect(container.read(voyageUiStateProvider), isA<SinViaje>());
        await esperarRecientes(tester);
        expect(find.text('Recientes en este dispositivo'), findsOneWidget);
        expect(find.textContaining('BUQUE MANUAL'), findsOneWidget);
        final guardados = (await store.repository.getAllVoyages())
            .getOrElse(() => const []);
        expect(guardados, hasLength(1));
        expect(guardados.single.vessel.name, 'BUQUE MANUAL');
      });
    }, variant: _windows);

    testWidgets('con un previo pregunta, y «Seguir mirando» no lo descarta',
        (tester) async {
      await caso(tester, () async {
        await enPrevio();
        await pintar(tester, _oficina);

        await tocar(tester, _marca);
        expect(find.text('¿Descartar el plano sin confirmar?'), findsOneWidget);
        await tocar(tester, find.byKey(const ValueKey('preview-keep')));
        expect(container.read(voyageUiStateProvider), isA<Previo>());

        await tocar(tester, _marca);
        await tocar(tester, find.byKey(const ValueKey('preview-discard')));
        expect(container.read(voyageUiStateProvider), isA<SinViaje>());
        expect((await store.repository.getAllVoyages())
            .getOrElse(() => const []), isEmpty);
      });
    }, variant: _windows);

    testWidgets('tiene descripción emergente, etiqueta y foco con el teclado',
        (tester) async {
      final lector = tester.ensureSemantics();
      await caso(tester, () async {
        await confirmado();
        await pintar(tester, _oficina);

        expect(find.byTooltip('Volver al inicio'), findsOneWidget);
        expect(
            tester.getSemantics(_marca),
            containsSemantics(
                label: 'Volver al inicio',
                isButton: true,
                isFocusable: true,
                hasTapAction: true));

        BoxDecoration decoracion() => tester
            .widget<DecoratedBox>(find.descendant(
                of: _marca, matching: find.byType(DecoratedBox)))
            .decoration as BoxDecoration;
        expect(decoracion().border, isNull);
        for (var i = 0; i < 12 && decoracion().border == null; i++) {
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pump();
        }
        expect(decoracion().border, isNotNull,
            reason: 'con el foco, la marca se ve enfocada');

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(container.read(voyageUiStateProvider), isA<SinViaje>());
      });
      lector.dispose();
    }, variant: _windows);

    testWidgets('el riel conserva su ancho y sus destinos', (tester) async {
      await caso(tester, () async {
        await confirmado();

        List<String> destinos() => [
              for (final destino in tester
                  .widget<NavigationRail>(
                      find.byKey(const ValueKey('riel-del-viaje')))
                  .destinations)
                (destino.label as Text).data!,
            ];
        Rect lugar(String destino) => tester.getRect(find.descendant(
            of: find.byType(RielDelViaje), matching: find.text(destino)));

        await pintar(tester, _oficina);
        expect(_marca, findsOneWidget);
        final ancho = tester.getSize(find.byType(RielDelViaje)).width;
        expect(destinos(),
            ['Plano', 'Lista', 'Avance', 'Estadísticas', 'Más', 'Alertas']);
        final conBoton = {for (final d in destinos()) d: lugar(d)};

        // La misma pantalla con la marca sola, como en Android.
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        await tester.pumpWidget(const SizedBox.shrink());
        await pintar(tester, _oficina);
        expect(_marca, findsNothing);
        expect(tester.getSize(find.byType(RielDelViaje)).width, ancho);
        expect({for (final d in destinos()) d: lugar(d)}, conBoton);
      });
    }, variant: _windows);
  });

  group('en el teléfono', () {
    Future<void> abrirMas(WidgetTester tester) async {
      await tocar(tester, find.text('Más'));
      await tester.scrollUntilVisible(_entrada, 80,
          scrollable: find.descendant(
              of: find.byKey(const ValueKey('hoja-mas')),
              matching: find.byType(Scrollable)));
      await tester.pumpAndSettle();
    }

    void entradaCon(String subtitulo) {
      for (final texto in ['Volver al inicio', subtitulo]) {
        expect(
            find.descendant(of: _entrada, matching: find.text(texto)),
            findsOneWidget);
      }
      expect(find.text('Cerrar el plano'), findsNothing);
    }

    testWidgets('«Más» a 360 dice «Volver al inicio» y no se borra nada',
        (tester) async {
      await caso(tester, () async {
        await confirmado();
        await pintar(tester, _telefono);
        expect(_marca, findsNothing, reason: 'ni la banda ni la barra');
        await abrirMas(tester);
        entradaCon(_subtituloConfirmado);

        await tocar(tester, _entrada);
        expect(container.read(voyageUiStateProvider), isA<SinViaje>());
        await esperarRecientes(tester);
        expect((await store.repository.getAllVoyages())
            .getOrElse(() => const []), hasLength(1));
      });
    });

    testWidgets('con un previo, conserva su subtítulo y su pregunta',
        (tester) async {
      await caso(tester, () async {
        await enPrevio();
        await pintar(tester, _telefono);
        await abrirMas(tester);
        entradaCon(_subtituloPrevio);

        await tocar(tester, _entrada);
        expect(find.text('¿Descartar el plano sin confirmar?'), findsOneWidget);
        await tocar(tester, find.byKey(const ValueKey('preview-keep')));
        expect(container.read(voyageUiStateProvider), isA<Previo>());
      });
    });
  });
}
