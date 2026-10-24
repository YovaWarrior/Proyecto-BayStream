// T-114 · Segunda corrección de la candidata del piloto (SPRINT-4.md 10.31,
// H2): con la letra a 2.0, el aviso de 6 s con «Deshacer» crecía hacia arriba
// más que las cifras de la franja y pisaba la última fila de celdas. La regla
// medía la fila de controles y ponía el aviso encima, pero nada acotaba su
// borde de arriba. Ahora la página mide también la franja (`MideLaFranja`) y
// cada aviso de la página (`avisoDelViaje`) sabe cuánto alto tiene entre el
// borde de arriba de la franja, donde termina la rejilla, y su aire sobre los
// controles (`LugarDelAviso`): sale entero si cabe; si no, con su texto corto,
// que sigue diciendo qué pasó; y no pasa de ese borde mida lo que mida.
//
// La base es la prueba de geometría de Codex (reaceptación, 10.31): la app
// entera con las fuentes reales, planes sintéticos de 24 contenedores (filas
// 02 a 08, niveles 82 a 92) y el plano desplazado; cada celda se recorta con
// los desplazables y la ventana antes de compararla con el aviso. La matriz:
// 360 × 640 (el emulador) y 412 × 915; la letra a 1.0, 1.45 y 2.0; Descarga y
// Carga. Los textos son los de los avisos de verdad (`discharge_controls`,
// `loading_controls`); dos pruebas más registran de verdad con la letra a 2.0.
import 'dart:io';

import 'package:baystream/core/app.dart';
import 'package:baystream/core/design/design.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_overview_page.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_operation_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/plano_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/avisos_del_viaje.dart';
import 'package:baystream/features/vessel/presentation/widgets/bay_plan_view.dart';
import 'package:baystream/features/vessel/presentation/widgets/loading_plan_controls.dart';
import 'package:baystream/features/vessel/presentation/widgets/navegacion_del_viaje.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/local_profile_test_support.dart';
import 'support/t75_memory_log.dart';
import 'support/t76_fixture.dart';

/// El alto que le queda al plano en el emulador de 360 × 640 dp debajo de la
/// barra de estado, la banda de la marca y la barra inferior: va anidado y
/// con los controles en la franja (13.8).
const _telefonoBajo = Size(360, 420);

var _fuentesCargadas = false;

/// Las fuentes del producto (Plex, Roboto y los íconos), para que el aviso,
/// la franja y las celdas midan lo que miden en el muelle: con la fuente
/// cuadrada de las pruebas el aviso mide el doble.
Future<void> _cargarFuentes() async {
  if (_fuentesCargadas) return;
  _fuentesCargadas = true;
  const familias = <String, List<String>>{
    'IBM Plex Sans': [
      'assets/fonts/plex/IBMPlexSans-Regular.ttf',
      'assets/fonts/plex/IBMPlexSans-Medium.ttf',
      'assets/fonts/plex/IBMPlexSans-SemiBold.ttf',
    ],
    'IBM Plex Sans Condensed': [
      'assets/fonts/plex/IBMPlexSansCondensed-Medium.ttf',
      'assets/fonts/plex/IBMPlexSansCondensed-SemiBold.ttf',
    ],
    'IBM Plex Mono': [
      'assets/fonts/plex/IBMPlexMono-Regular.ttf',
      'assets/fonts/plex/IBMPlexMono-Medium.ttf',
    ],
    'Roboto': ['assets/fonts/Roboto-Regular.ttf', 'assets/fonts/Roboto-Medium.ttf'],
    'BayStreamIconos': ['assets/fonts/bs_iconos/BayStreamIconos.ttf'],
    'MaterialIcons': ['fonts/MaterialIcons-Regular.otf'],
  };
  for (final entrada in familias.entries) {
    final cargador = FontLoader(entrada.key);
    for (final ruta in entrada.value) {
      cargador.addFont(rootBundle.load(ruta));
    }
    await cargador.load();
  }
}

final _franja = find.byKey(const ValueKey('barra-de-operacion'));
final _controles = find.byKey(const ValueKey('controles-de-la-franja'));
final _aviso = find.byKey(const ValueKey('aviso-de-prueba'));

/// La tarjeta de un aviso (su `Material`), sin el aire que lo separa del pie.
Rect _tarjeta(WidgetTester tester, Finder aviso) => tester.getRect(
    find.descendant(of: aviso, matching: find.byType(Material)).first);

/// Lo que se ve de un elemento: su rectángulo recortado por los desplazables
/// y los recortes que lo contienen, y por la ventana.
Rect _loQueSeVe(Element elemento, Size ventana) {
  final caja = elemento.findRenderObject()! as RenderBox;
  var recto =
      MatrixUtils.transformRect(caja.getTransformTo(null), caja.paintBounds);
  for (RenderObject? padre = caja.parent; padre != null; padre = padre.parent) {
    if (padre is RenderViewport ||
        padre is RenderShrinkWrappingViewport ||
        padre is RenderClipRect ||
        padre is RenderClipRRect) {
      recto = recto.intersect(MatrixUtils.transformRect(
          padre.getTransformTo(null), padre.paintBounds));
    }
  }
  return recto.intersect(Offset.zero & ventana);
}

/// Las celdas a la vista: las de la rejilla en Descarga y en Carga y las del
/// plan de carga.
Iterable<Element> _celdas() => find
    .byWidgetPredicate((Widget w) =>
        w.key is ValueKey<String> &&
        ['cell-', 'plan-cell-', 'loading-C:']
            .any((p) => (w.key! as ValueKey<String>).value.startsWith(p)))
    .evaluate();

/// Las cuatro comprobaciones de 10.31 sobre un aviso a la vista, salvo
/// «Deshacer», que se toca aparte: (1) no cruza ninguna celda visible ni pasa
/// del borde de arriba de la franja; (2) la fila de controles queda libre;
/// (3) su texto está entero y no desborda. Devuelve el texto que se ve, que
/// tiene que ser uno de los del aviso ([esSuTexto]).
String _comprobar(WidgetTester tester, Finder aviso, Size ventana,
    {required bool Function(String) esSuTexto}) {
  final tarjeta = _tarjeta(tester, aviso);
  // (1) El borde de arriba de la franja es el tope.
  final franja = tester.getRect(_franja);
  expect(tarjeta.top, greaterThanOrEqualTo(franja.top - 0.01),
      reason: 'el aviso (${tarjeta.top}) pasa del borde de arriba de la '
          'franja (${franja.top})');
  for (final celda in _celdas()) {
    final recto = _loQueSeVe(celda, ventana);
    if (recto.isEmpty) continue;
    expect(tarjeta.overlaps(recto), isFalse,
        reason: 'el aviso $tarjeta tapa ${celda.widget.key} $recto');
  }
  // (2) La fila de controles, libre, y nada de lo que se toca en ella.
  final controles = tester.getRect(_controles);
  expect(tarjeta.bottom, lessThanOrEqualTo(controles.top),
      reason: 'el aviso (${tarjeta.bottom}) pisa los controles (${controles.top})');
  for (final control in find
      .descendant(
          of: _controles,
          matching: find.byWidgetPredicate((Widget w) =>
              w is IconButton || w is ButtonStyleButton || w is DropdownButton))
      .evaluate()) {
    final recto = _loQueSeVe(control, ventana);
    if (recto.isEmpty) continue;
    expect(tarjeta.overlaps(recto), isFalse,
        reason: 'el aviso tapa ${control.widget.runtimeType} $recto');
  }
  // (3) El texto: uno de los del aviso, entero, sin elipsis y dentro.
  final parrafos = find
      .descendant(of: aviso, matching: find.byType(RichText))
      .evaluate()
      .map((e) => e.renderObject! as RenderParagraph)
      .where((p) => esSuTexto(p.text.toPlainText()))
      .toList();
  expect(parrafos, hasLength(1), reason: 'se ve un solo texto del aviso');
  final parrafo = parrafos.single;
  expect(parrafo.didExceedMaxLines, isFalse);
  expect(parrafo.size.height,
      greaterThanOrEqualTo(parrafo.getMinIntrinsicHeight(parrafo.size.width) - 0.01),
      reason: 'el texto se corta');
  final recto =
      MatrixUtils.transformRect(parrafo.getTransformTo(null), parrafo.paintBounds);
  expect(tarjeta.inflate(0.01).contains(recto.topLeft), isTrue);
  expect(tarjeta.inflate(0.01).contains(recto.bottomRight), isTrue,
      reason: 'el texto $recto desborda la tarjeta $tarjeta');
  return parrafo.text.toPlainText();
}

class _QaPlan extends VoyageNotifier {
  _QaPlan(this.plan);
  VesselVoyage plan;

  @override
  AsyncValue<VesselVoyage?> build() => AsyncValue.data(plan);

  void cambiar(VesselVoyage otro) => state = AsyncValue.data(plan = otro);
}

/// La llegada y el plan de carga de Codex: 24 contenedores en las filas 02 a
/// 08 y los niveles 82 a 92 de la bahía 3.
final _llegada = t76Voyage([
  for (final nivel in [82, 84, 86, 88, 90, 92])
    for (final fila in [2, 4, 6, 8])
      t76Unit('QA$fila$nivel', '003${fila.toString().padLeft(2, '0')}$nivel',
          incoming: true)
]);
final _salida = t76Voyage([
  for (final nivel in [82, 84, 86, 88, 90, 92])
    for (final fila in [2, 4, 6, 8])
      t76Unit('QB$fila$nivel', '003${fila.toString().padLeft(2, '0')}$nivel')
]);

/// La app entera con el viaje del modo, en [ventana] y con la letra a
/// [escala]; el cuerpo corre con todo montado y después se desmonta.
Future<void> _enLaApp(WidgetTester tester,
    {required Size ventana,
    required double escala,
    required bool carga,
    TargetPlatform plataforma = TargetPlatform.android,
    required Future<void> Function(ProviderContainer scope) cuerpo}) async {
  await tester.runAsync(() async {
    await _cargarFuentes();
    debugDefaultTargetPlatformOverride = plataforma;
    final store = await testProfileStore();
    final viaje = carga ? _salida : _llegada;
    final scope = ProviderContainer(overrides: [
      movementLogRepositoryProvider.overrideWith((ref) async => T75MemoryLog()),
      vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
      localVesselRepositoryProvider.overrideWith((ref) async => store.repository),
      voyageNotifierProvider.overrideWith(() => _QaPlan(viaje)),
      loadingOperationProvider(viaje).overrideWith((ref) async* {
        yield LoadingOperation.build(
            operationId: 'qa',
            arrival: _llegada,
            loading: _salida,
            list: ExportList(fileName: 'qa-sintetico.xlsx', rows: [
              for (var i = 0; i < _salida.containers.length; i++)
                t76Row(i + 1, _salida.containers[i].containerId)
            ]),
            movements: const []);
      }),
    ]);
    tester.view.physicalSize = ventana;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = escala;
    try {
      await tester.pumpWidget(UncontrolledProviderScope(
          container: scope, child: const BayStreamApp()));
      await tester.pumpAndSettle();
      scope
          .read(bayPlanModeProvider.notifier)
          .elegir(carga ? BayPlanMode.loading : BayPlanMode.discharge);
      await tester.pumpAndSettle();
      await cuerpo(scope);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      scope.dispose();
      await store.repository.close();
      await store.directory.delete(recursive: true);
      tester.view.reset();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
      debugDefaultTargetPlatformOverride = null;
    }
  });
}

/// El plano desplazado como en la prueba de Codex: 350 dp hacia arriba el
/// anidado del teléfono bajo; la rejilla hasta el fondo si no va anidado.
Future<void> _desplazar(WidgetTester tester) async {
  final anidado = find.byKey(const ValueKey('plano-anidado'));
  if (anidado.evaluate().isNotEmpty) {
    await tester.drag(anidado, const Offset(0, -350));
  } else {
    await tester.drag(
        find.byKey(const ValueKey('plan-zoom-3')), const Offset(0, -2000));
  }
  await tester.pumpAndSettle();
}

/// Muestra un aviso de la página desde la página del viaje.
void _mostrar(WidgetTester tester, SnackBar aviso) => ScaffoldMessenger.of(
        tester.element(find.byType(VesselOverviewPage)))
    .showSnackBar(aviso);

void main() {
  group('H2 · el aviso de 6 s con «Deshacer» no pasa del borde de arriba de '
      'la franja', () {
    for (final ventana in const [Size(360, 640), Size(412, 915)]) {
      for (final escala in const [1.0, 1.45, 2.0]) {
        for (final carga in const [false, true]) {
          final modo = carga ? 'Carga' : 'Descarga';
          testWidgets(
              '${ventana.width.toInt()} × ${ventana.height.toInt()}, letra '
              '$escala, $modo: ni celdas ni controles, el texto entero y '
              '«Deshacer» responde', (tester) async {
            await _enLaApp(tester,
                ventana: ventana,
                escala: escala,
                carga: carga, cuerpo: (scope) async {
              await _desplazar(tester);
              // Los textos de los avisos de verdad (`loading_controls`,
              // `discharge_controls`).
              final texto = carga
                  ? 'Descarga y carga registradas · OR 16'
                  : 'Descargado · MNLU0000107 · 002-02-82';
              final corto =
                  carga ? 'Descarga y carga · OR 16' : 'Descargado · MNLU0000107';
              var deshecho = false;
              _mostrar(
                  tester,
                  avisoDelViaje(
                      key: const ValueKey('aviso-de-prueba'),
                      duracion: const Duration(seconds: 6),
                      texto: texto,
                      corto: corto,
                      accion: 'Deshacer',
                      onAccion: () => deshecho = true));
              await tester.pumpAndSettle();
              final visto = _comprobar(tester, _aviso, ventana,
                  esSuTexto: [texto, corto].contains);
              debugPrint('10.31 H2 ${ventana.width.toInt()}x'
                  '${ventana.height.toInt()} $escala $modo: «$visto» '
                  '${_tarjeta(tester, _aviso)}');
              // Con la letra a 1.0 cabe entero en los dos teléfonos.
              if (escala == 1.0) expect(visto, texto);
              // (4) «Deshacer» responde.
              expect(find.text('Deshacer'), findsOneWidget);
              await tester.tap(find.text('Deshacer'));
              await tester.pumpAndSettle();
              expect(deshecho, isTrue);
              expect(_aviso, findsNothing);
              expect(tester.takeException(), isNull);
            });
          });
        }
      }
    }
  });

  group('los demás avisos de la página', () {
    testWidgets(
        'el más largo (T-61, 10 s), con la letra a 2.0 en 360 × 640: el texto '
        'corto, entero y sin tapar nada; «Ver» abre el texto entero',
        (tester) async {
      const ventana = Size(360, 640);
      await _enLaApp(tester, ventana: ventana, escala: 2.0, carga: false,
          cuerpo: (scope) async {
        await _desplazar(tester);
        _mostrar(tester, avisoDelParametroConservado(['primer nivel de cubierta']));
        await tester.pumpAndSettle();
        final aviso = find.byKey(const ValueKey('reopen-kept-parameters'));
        const texto = 'No se aplicó del perfil vigente: primer nivel de '
            'cubierta. Dejaría contenedores de este viaje fuera del plano; se '
            'conserva el valor guardado con el viaje. Revisa el perfil del buque.';
        const corto = 'No se aplicó todo el perfil vigente.';
        expect(
            _comprobar(tester, aviso, ventana,
                esSuTexto: [texto, corto].contains),
            corto,
            reason: 'con la letra a 2.0 el texto entero no cabe sobre las cifras');
        // El lector de pantalla lee el texto que se ve, no el que no cabe.
        final semantica = tester.ensureSemantics();
        await tester.pump();
        expect(find.bySemanticsLabel(RegExp('No se aplicó todo el perfil')),
            findsWidgets);
        expect(find.bySemanticsLabel(RegExp('primer nivel de cubierta')),
            findsNothing);
        semantica.dispose();
        // «Ver» abre el texto entero, que se lee sin cortes.
        await tester.tap(find.text('Ver'));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('aviso-entero')), findsOneWidget);
        final entero = tester.renderObject<RenderParagraph>(find.descendant(
            of: find.byKey(const ValueKey('aviso-entero')),
            matching: find.byWidgetPredicate(
                (Widget w) => w is RichText && w.text.toPlainText() == texto)));
        expect(entero.didExceedMaxLines, isFalse);
        expect(entero.size.height,
            greaterThanOrEqualTo(entero.getMinIntrinsicHeight(entero.size.width) - 0.01));
        await tester.tap(find.text('Cerrar'));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('aviso-entero')), findsNothing);
        expect(tester.takeException(), isNull);
      });
    });

    testWidgets(
        'en la oficina, 1920 × 1080 con la letra a 1.0: el aviso compacto, '
        'entero, en la franja de cifras y sin tapar celdas; «Deshacer» responde',
        (tester) async {
      const ventana = Size(1920, 1080);
      await _enLaApp(tester,
          ventana: ventana,
          escala: 1.0,
          carga: false,
          plataforma: TargetPlatform.windows, cuerpo: (scope) async {
        // T-117 (DESIGN.md 14.5): en la oficina el pie es la franja de
        // cifras, fija abajo y sin controles; el aviso vive en ella, con su
        // tope (`LugarDelAviso`), y la leyenda va dentro de la columna que se
        // desplaza. Antes (10.32) no había franja y el aviso flotaba sobre la
        // leyenda.
        expect(_franja, findsNothing);
        final cifras = find.byKey(const ValueKey('franja-de-cifras'));
        expect(cifras, findsOneWidget);
        expect(scope.read(franjaDelPlanoProvider),
            closeTo(tester.getSize(cifras).height, 0.5));
        const texto = 'Descargado · MNLU0000107 · 002-02-82';
        var deshecho = false;
        _mostrar(
            tester,
            avisoDelViaje(
                key: const ValueKey('aviso-de-prueba'),
                duracion: const Duration(seconds: 6),
                texto: texto,
                corto: 'Descargado · MNLU0000107',
                accion: 'Deshacer',
                onAccion: () => deshecho = true));
        await tester.pumpAndSettle();
        final tarjeta = _tarjeta(tester, _aviso);
        expect(tarjeta.top,
            greaterThanOrEqualTo(tester.getRect(cifras).top - 0.5));
        expect(tarjeta.bottom, lessThanOrEqualTo(ventana.height));
        for (final celda in _celdas()) {
          final recto = _loQueSeVe(celda, ventana);
          if (recto.isEmpty) continue;
          expect(tarjeta.overlaps(recto), isFalse,
              reason: 'el aviso tapa ${celda.widget.key}');
        }
        expect(find.descendant(of: _aviso, matching: find.text(texto)),
            findsOneWidget);
        await tester.tap(find.text('Deshacer'));
        await tester.pumpAndSettle();
        expect(deshecho, isTrue);
        expect(tester.takeException(), isNull);
      });
    });
  });

  group('los avisos de verdad, con la letra a 2.0 en el teléfono bajo', () {
    /// El pie del plano dentro de [AvisosSobreElPie] y un `Scaffold`, como en
    /// la página, con el alto que le queda al plano en el emulador.
    Future<void> montar(WidgetTester tester, ProviderContainer scope,
        VesselVoyage viaje) async {
      await tester.runAsync(_cargarFuentes);
      tester.view.physicalSize = _telefonoBajo;
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: scope,
        child: MaterialApp(
          theme: BayStreamTema.claro(muelle: true),
          home: AvisosSobreElPie(child: Scaffold(body: BayPlanView(voyage: viaje))),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('plano-anidado')), findsOneWidget);
    }

    Future<void> tocar(WidgetTester tester, Finder control) async {
      await tester.ensureVisible(control);
      await tester.pumpAndSettle();
      await tester.tap(control);
      await tester.pumpAndSettle();
    }

    testWidgets('«Baja» y otra «Baja»: cada aviso, en su lugar y entero',
        (tester) async {
      final log = T75MemoryLog();
      await log.saveOperation(Operation(
          id: 'op-llegada',
          vesselName: t76Arrival.vessel.name,
          voyageNumber: t76Arrival.voyageNumber,
          portOfCall: 'GTSTC',
          createdAt: DateTime.utc(2026, 10, 23)));
      final scope = ProviderContainer(overrides: [
        movementLogRepositoryProvider.overrideWith((ref) async => log),
        vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
      ]);
      addTearDown(scope.dispose);
      await montar(tester, scope, t76Arrival);
      await tocar(tester, find.byKey(const ValueKey('bay-plan-display-mode')));
      await tester.tap(find.text('Descarga').last);
      await tester.pumpAndSettle();
      final aviso = find.byKey(const ValueKey('discharge-undo-snackbar'));
      for (final (celda, contenedor) in [('cell-2-82', 'INCOMING1'), ('cell-4-82', 'INCOMING2')]) {
        await tocar(tester, find.byKey(ValueKey(celda)));
        _comprobar(tester, aviso, _telefonoBajo,
            esSuTexto: (t) => t.startsWith('Descargado · $contenedor'));
      }
      expect(log.of('op-llegada'), hasLength(2));
      await tester.tap(find.text('Deshacer'));
      await tester.pumpAndSettle();
      expect(log.of('op-llegada').last.movement.type, MovementType.annul);
      expect(tester.takeException(), isNull);
    });

    testWidgets('una carga por OR: el aviso, en su lugar y entero, y «Deshacer» '
        'responde', (tester) async {
      final log = T75MemoryLog();
      final scope = ProviderContainer(overrides: [
        movementLogRepositoryProvider.overrideWith((ref) async => log),
        vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
        loadingOperationProvider(t76Loading).overrideWith((ref) async* {
          await for (final records in log.watch('op')) {
            yield t76Operation(records.map((r) => r.movement).toList());
          }
        }),
      ]);
      addTearDown(scope.dispose);
      await montar(tester, scope, t76Loading);
      await tocar(tester, find.byKey(const ValueKey('bay-plan-display-mode')));
      await tester.tap(find.text('Carga').last);
      await tester.pumpAndSettle();
      await tocar(tester, find.byKey(const ValueKey('load-search')));
      await tester.enterText(find.byKey(const ValueKey('loading-query')), '1');
      await tester.pumpAndSettle();
      await tocar(tester, find.byKey(const ValueKey('loading-or-1')));
      await tocar(tester, find.byKey(const ValueKey('loading-confirm')));
      final aviso = find.byKey(const ValueKey('loading-undo-snackbar'));
      _comprobar(tester, aviso, _telefonoBajo,
          esSuTexto: (t) => t.endsWith('· OR 1'));
      await tester.tap(find.text('Deshacer'));
      await tester.pumpAndSettle();
      expect(log.of('op').last.movement.type, MovementType.annul);
      expect(tester.takeException(), isNull);
    });
  });

  group('la medida vieja (Codex, 10.31)', () {
    testWidgets(
        'el primer aviso tras otro viaje y al volver al Plano: en los cuadros '
        'visibles, entre el borde de arriba de la franja y los controles',
        (tester) async {
      const ventana = Size(360, 640);
      await _enLaApp(tester, ventana: ventana, escala: 2.0, carga: false,
          cuerpo: (scope) async {
        for (final caso in ['otro viaje', 'regreso al Plano']) {
          scope.read(destinoDelViajeProvider.notifier).ir(DestinoDelViaje.lista);
          await tester.pumpAndSettle();
          // Medidas viejas, una grande y una pequeña.
          final grande = caso == 'otro viaje';
          scope.read(pieDelPlanoProvider.notifier).medir(grande ? 180 : 12);
          scope.read(franjaDelPlanoProvider.notifier).medir(grande ? 400 : 60);
          if (grande) {
            (scope.read(voyageNotifierProvider.notifier) as _QaPlan).cambiar(
                t76Voyage([t76Unit('OTRO', '0030282', incoming: true)]));
          }
          scope.read(destinoDelViajeProvider.notifier).ir(DestinoDelViaje.plano);
          // El primer layout publica sus medidas al terminar el cuadro.
          await tester.pump();
          _mostrar(
              tester,
              avisoDelViaje(
                  key: const ValueKey('aviso-de-prueba'),
                  duracion: const Duration(seconds: 6),
                  texto: 'Descargado · MNLU0000107 · 002-02-82',
                  corto: 'Descargado · MNLU0000107',
                  accion: 'Deshacer',
                  onAccion: () {}));
          for (var cuadro = 0; cuadro < 24; cuadro++) {
            await tester.pump(const Duration(milliseconds: 16));
            var opacidad = 1.0;
            tester
                .element(find
                    .descendant(of: _aviso, matching: find.byType(Material))
                    .first)
                .visitAncestorElements((Element e) {
              if (e.widget is FadeTransition) {
                opacidad *= (e.widget as FadeTransition).opacity.value;
              }
              return true;
            });
            if (opacidad == 0) continue;
            final tarjeta = _tarjeta(tester, _aviso);
            expect(tarjeta.bottom,
                lessThanOrEqualTo(tester.getRect(_controles).top),
                reason: '$caso, cuadro $cuadro');
            expect(tarjeta.top,
                greaterThanOrEqualTo(tester.getRect(_franja).top - 0.01),
                reason: '$caso, cuadro $cuadro');
          }
          // Las medidas de ahora sustituyen a las viejas.
          expect(scope.read(pieDelPlanoProvider),
              tester.getSize(_controles).height +
                  BsMedidas.de(tester.element(_controles)).espacioM);
          expect(scope.read(franjaDelPlanoProvider),
              tester.getSize(_franja).height);
          ScaffoldMessenger.of(tester.element(find.byType(VesselOverviewPage)))
              .clearSnackBars();
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
      });
    });
  });

  group('todos los avisos de la página pasan por avisoDelViaje', () {
    test('ningún aviso de los que se ven sobre el plano se hace a mano', () {
      // Los archivos cuyos avisos salen en la página del viaje con el plano a
      // la vista: un `SnackBar(` hecho a mano no sabría su lugar.
      const archivos = [
        'lib/features/vessel/presentation/pages/vessel_overview_page.dart',
        'lib/features/vessel/presentation/widgets/discharge_controls.dart',
        'lib/features/vessel/presentation/widgets/loading_controls.dart',
        'lib/features/vessel/presentation/widgets/plan_drag_confirmation.dart',
      ];
      final aMano = RegExp(r'(?<![A-Za-z_])SnackBar\(');
      for (final ruta in archivos) {
        final fuente = File(ruta).readAsStringSync();
        expect(aMano.allMatches(fuente), isEmpty, reason: ruta);
        expect(fuente, contains('avisoDelViaje('), reason: ruta);
      }
      // T-61 sale sobre el plano también al reabrir desde los recientes.
      expect(
          File('lib/features/vessel/presentation/pages/recent_voyages_page.dart')
              .readAsStringSync(),
          contains('avisoDelParametroConservado('));
    });
  });
}
