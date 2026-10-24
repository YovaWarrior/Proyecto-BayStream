// T-114 · Fase 3, entrega 2, corrección tras la aceptación de Codex
// (SPRINT-4.md 10.21; DESIGN.md 8, 13.3, 13.6 y 13.8):
//   H1 · la cabecera de la oficina se reparte o se pliega según el ancho y la
//        letra, y Buscar queda siempre al alcance (600 dp exactos con 1.0,
//        1.45 y 2.0; también 360 y 1920);
//   H2 · una carga real, desde la bitácora hasta la celda, enciende la celda
//        de carga en naranja 1.5 s, sea un lleno o una reserva con su vacío,
//        y con reducción de movimiento la celda se queda quieta;
//   H3 · sin panel lateral (360 y 600 dp) el movimiento se anuncia en una
//        región en vivo con el rol, nunca con un nombre;
//   H4 · a 360 × 640 dp la primera fila de la rejilla se ve sin desplazar;
//   el riel sin `IntrinsicHeight`; el chip del zoom fuera de la rejilla.
//
// Buque y números sintéticos (BUQUE MANUAL, BUQUE PRUEBA, TSTU, FULL, EMPTY);
// sin nube ni almacén real. Nada de aquí inyecta `recienMovidoProvider`: el
// naranja llega por la operación derivada de la bitácora en memoria de T-75.
import 'dart:ui' show Tristate;

import 'package:baystream/core/design/design.dart';
import 'package:baystream/features/vessel/data/repositories/local_only_operation_sync.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_overview_page.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_operation_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/plano_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/voyage_ui_state.dart';
import 'package:baystream/features/vessel/presentation/widgets/loading_plan_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/local_profile_test_support.dart';
import 'support/t74_movement_log_support.dart';
import 'support/t75_memory_log.dart';
import 'support/t76_fixture.dart';
import 'support/t91_toolbar_support.dart';

/// Un plano de llegada sintético con seis niveles en bodega y seis en
/// cubierta, para que la silueta y la rejilla midan lo que miden con un buque
/// cargado: bahías 02, 06, 10 y 14, filas 00 a 05, niveles 02 a 12 y 82 a 92
/// (288 contenedores, 40 pies, a GTSTC y a USHOU).
String _baplieCargado() {
  final b = StringBuffer("UNH+1+BAPLIE:D:95B:UN:SMDG22'"
      "TDT+20+V114+++TST:172:20+++9000114:146:11:BUQUE MANUAL'"
      "LOC+5+HNPCR:139:6'LOC+61+GTSTC:139:6'");
  var n = 0;
  for (final bahia in [2, 6, 10, 14]) {
    for (final fila in [0, 1, 2, 3, 4, 5]) {
      for (final nivel in [2, 4, 6, 8, 10, 12, 82, 84, 86, 88, 90, 92]) {
        n++;
        final pos = '${bahia.toString().padLeft(3, '0')}'
            '${fila.toString().padLeft(2, '0')}${nivel.toString().padLeft(2, '0')}';
        final pod = n % 3 == 0 ? 'USHOU' : 'GTSTC';
        b.write("LOC+147+$pos::5'LOC+9+HNPCR:139:6'LOC+11+$pod:139:6'"
            "MEA+AAE+VGM+KGM:${18000 + n}'"
            "EQD+CN+TSTU${n.toString().padLeft(7, '0')}+42G1+++5'");
      }
    }
  }
  return b.toString();
}

final _leido = BaplieParserService().parse(_baplieCargado());
final _perfil = VesselProfile.proposeFrom(_leido);

/// Publicado con la escala GTSTC: hay operación, Descarga / Carga y «Avance».
final _conEscala = _leido.withGeometry(_perfil.geometry, portOfCall: 'GTSTC');

/// El mismo buque tal como se dibuja en previo: sin escala.
final _enPrevio = _leido.withGeometry(_perfil.geometry);

class _Viaje extends VoyageNotifier {
  _Viaje(this.voyage);
  final VesselVoyage voyage;
  @override
  AsyncValue<VesselVoyage?> build() => AsyncData(voyage);
}

var _fuentesCargadas = false;

/// Las fuentes del producto (Plex y Roboto), para que las medidas de 360 y
/// 600 dp sean las reales y no las de la fuente cuadrada de las pruebas.
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
  };
  for (final entrada in familias.entries) {
    final cargador = FontLoader(entrada.key);
    for (final ruta in entrada.value) {
      cargador.addFont(rootBundle.load(ruta));
    }
    await cargador.load();
  }
}

/// El tamaño de la pantalla, la letra y, si se pide, la barra de estado del
/// emulador (24 dp) y la reducción de movimiento del sistema.
void _pantalla(WidgetTester tester, Size tamano,
    {double letra = 1.0, double barraDeEstado = 0, bool sinMovimiento = false}) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = tamano;
  tester.view.padding = FakeViewPadding(top: barraDeEstado);
  addTearDown(tester.view.reset);
  if (letra != 1.0) {
    tester.platformDispatcher.textScaleFactorTestValue = letra;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }
  if (sinMovimiento) {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  }
}

/// La página completa con el tema del producto, sin nube ni almacén real.
Future<ProviderContainer> _pump(
  WidgetTester tester, {
  required Size tamano,
  bool muelle = false,
  double letra = 1.0,
  double barraDeEstado = 0,
  VesselVoyage? voyage,
  bool previo = false,
  int bahia = 2,
}) async {
  await _cargarFuentes();
  _pantalla(tester, tamano, letra: letra, barraDeEstado: barraDeEstado);
  final viaje = voyage ?? (previo ? _enPrevio : _conEscala);
  final scope = ProviderContainer(overrides: [
    voyageNotifierProvider.overrideWith(() => _Viaje(viaje)),
    if (previo)
      voyageUiStateProvider.overrideWith((ref) => Previo(
            voyage: viaje,
            profile: _perfil,
            motivo: PreviewReason.buqueNuevo,
            fileName: 'sintetico.edi',
            portOfCall: 'GTSTC',
          )),
    localVesselRepositoryProvider.overrideWith((ref) async => T91MemorySettings()),
    vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
    movementLogRepositoryProvider.overrideWith((ref) async => T74MemoryLog()),
    sessionRepositoryProvider
        .overrideWith((ref) async => const LocalSessionRepository()),
  ]);
  addTearDown(scope.dispose);
  scope.read(selectedBayProvider.notifier).select(bahia);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: scope,
    child: MaterialApp(
      theme: BayStreamTema.claro(muelle: muelle),
      darkTheme: BayStreamTema.oscuro(muelle: muelle),
      home: const VesselOverviewPage(),
    ),
  ));
  await tester.pumpAndSettle();
  return scope;
}

/// La operación de T-76 derivada de la bitácora en memoria de T-75, como en
/// `t76_loading_widget_test`: la página completa, en el muelle o en la
/// oficina, con los dos ocupantes de llegada ya bajados para que las celdas
/// de carga de la bahía 003 estén a la vista. Lo que no se inyecta es
/// `recienMovidoProvider`: lo alimenta el plano desde la operación.
const _autor =
    MovementAuthor(name: 'Nombre sintetico no publicable', role: OperatorRole.dock);

Future<({ProviderContainer scope, T75MemoryLog log})> _pumpCarga(
  WidgetTester tester, {
  required Size tamano,
  bool sinMovimiento = false,
}) async {
  await _cargarFuentes();
  final muelle = tamano.width < 600;
  _pantalla(tester, tamano, sinMovimiento: sinMovimiento);
  final log = T75MemoryLog();
  await log.append(MovementDraft.discharge('op', 'INCOMING1', '0030282'), _autor);
  await log.append(MovementDraft.discharge('op', 'INCOMING2', '0030482'), _autor);
  final scope = ProviderContainer(overrides: [
    voyageNotifierProvider.overrideWith(() => _Viaje(t76Loading)),
    localVesselRepositoryProvider.overrideWith((ref) async => T91MemorySettings()),
    vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
    sessionRepositoryProvider
        .overrideWith((ref) async => const LocalSessionRepository()),
    movementLogRepositoryProvider.overrideWith((ref) async => log),
    loadingOperationProvider(t76Loading).overrideWith((ref) async* {
      await for (final records in log.watch('op')) {
        yield t76Operation(records.map((r) => r.movement).toList());
      }
    }),
  ]);
  addTearDown(scope.dispose);
  scope.read(selectedBayProvider.notifier).select(3);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: scope,
    child: MaterialApp(
      theme: BayStreamTema.claro(muelle: muelle),
      home: const VesselOverviewPage(),
    ),
  ));
  await tester.pumpAndSettle();
  scope.read(bayPlanModeProvider.notifier).elegir(BayPlanMode.loading);
  await tester.pumpAndSettle();
  return (scope: scope, log: log);
}

/// Anexa a la bitácora y deja que la operación, el plano y el reloj lo vean.
Future<void> _registrar(
    WidgetTester tester, T75MemoryLog log, MovementDraft borrador) async {
  await log.append(borrador, _autor);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 16));
  await tester.pump();
}

/// Las celdas en naranja ahora mismo, con la clave del embarque que las
/// envuelve (`loading-C:…` o `loading-R:…`).
List<String> _naranjas(WidgetTester tester) => [
      for (final celda in find.byType(BsCelda).evaluate())
        if ((celda.widget as BsCelda).estado == BsEstadoDeCelda.recienMovido)
          _claveDeCarga(celda),
    ];

String _claveDeCarga(Element celda) {
  String? clave;
  celda.visitAncestorElements((ancestro) {
    final key = ancestro.widget.key;
    if (key is ValueKey<String> && key.value.startsWith('loading-')) {
      clave = key.value;
      return false;
    }
    return true;
  });
  return clave ?? '(sin clave de carga)';
}

/// Las etiquetas de las regiones en vivo que hay en el árbol.
List<String> _anuncios(WidgetTester tester) => [
      for (final s in tester.widgetList<Semantics>(find.byType(Semantics)))
        if (s.properties.liveRegion == true) s.properties.label ?? '',
    ];

/// La parte de arriba del cuerpo de una celda (lo que se mueve al salir).
double _arribaDelCuerpo(WidgetTester tester, Finder celda) => tester
    .getTopLeft(find.descendant(of: celda, matching: find.byType(Container)).first)
    .dy;

void main() {
  final buscar = find.byKey(const ValueKey('buscar-contenedor'));
  final cabecera = find.byKey(const ValueKey('cabecera-de-oficina'));
  final controles = find.byKey(const ValueKey('cabecera-controles'));
  final riel = find.byKey(const ValueKey('riel-del-viaje'));
  final anidado = find.byKey(const ValueKey('plano-anidado'));
  final anuncio = find.byKey(const ValueKey('anuncio-del-movimiento'));
  final enVivo = find.byKey(const ValueKey('en-vivo'));

  group('H1 · la cabecera de la oficina se reparte o se pliega', () {
    for (final letra in [1.0, 1.45, 2.0]) {
      testWidgets('a 600 dp exactos con la letra a $letra Buscar queda al alcance '
          'y nada se desborda', (tester) async {
        await _pump(tester, tamano: const Size(600, 960), letra: letra);
        expect(cabecera, findsOneWidget);
        expect(buscar.hitTestable(), findsOneWidget);
        final rect = tester.getRect(buscar);
        expect(rect.right, lessThanOrEqualTo(600));
        expect(rect.left, greaterThanOrEqualTo(0));
        expect(tester.getRect(cabecera).right, lessThanOrEqualTo(600));
        // Descarga / Carga siguen a la vista y enteros.
        final segmentos = find.byKey(const ValueKey('operar-segmentos'));
        expect(segmentos.hitTestable(), findsOneWidget);
        expect(tester.getRect(segmentos).right, lessThanOrEqualTo(600));
        expect(find.text('BUQUE MANUAL'), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'sin desbordamiento');
        if (letra >= 1.45) {
          // Con la letra grande la cabecera se pliega: los controles bajan a
          // una segunda línea, debajo del título.
          expect(tester.getRect(controles).top,
              greaterThanOrEqualTo(tester.getRect(find.text('BUQUE MANUAL')).bottom - 1));
        }
      });
    }

    testWidgets('a 1920 dp la cabecera va en una sola línea, con Buscar al alcance',
        (tester) async {
      await _pump(tester, tamano: const Size(1920, 1080));
      expect(buscar.hitTestable(), findsOneWidget);
      expect(tester.getRect(buscar).right, lessThanOrEqualTo(1920));
      final titulo = tester.getRect(find.text('BUQUE MANUAL'));
      final rect = tester.getRect(controles);
      expect(rect.top, lessThan(titulo.bottom), reason: 'misma línea');
      expect(rect.left, greaterThan(titulo.right), reason: 'a la derecha del título');
      expect(tester.takeException(), isNull);
    });

    for (final letra in [1.0, 2.0]) {
      testWidgets('a 360 dp con la letra a $letra Buscar está en la barra superior',
          (tester) async {
        await _pump(tester, tamano: const Size(360, 800), letra: letra);
        expect(cabecera, findsNothing);
        expect(buscar.hitTestable(), findsOneWidget);
        expect(tester.getRect(buscar).right, lessThanOrEqualTo(360));
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('H2 y H3 · la carga real enciende la celda y se anuncia', () {
    for (final tamano in const [Size(360, 800), Size(600, 960), Size(1920, 1080)]) {
      testWidgets(
          'a ${tamano.width.round()} dp: de la bitácora a la celda, un lleno y '
          'una reserva asignada, 1.5 s cada uno, con su anuncio', (tester) async {
        final semantica = tester.ensureSemantics();
        final arnes = await _pumpCarga(tester, tamano: tamano);
        final scope = arnes.scope;
        final log = arnes.log;
        expect(_naranjas(tester), isEmpty, reason: 'al abrir no destella nada');

        // Un lleno del listado, en la celda que dejó libre la descarga.
        final operacion = t76Operation(log.of('op').map((r) => r.movement).toList());
        await _registrar(tester, log, operacion.draft(t76List.rows.first, '0030282'));
        expect(scope.read(recienMovidoProvider)?.containerId, 'FULL0001234',
            reason: 'el provider lo aprende de la operación, no de la prueba');
        expect(_naranjas(tester), ['loading-C:FULL0001234']);
        final celda = find.descendant(
            of: find.byKey(const ValueKey('loading-C:FULL0001234')),
            matching: find.byType(BsCelda));
        expect(tester.getSemantics(celda).label, contains('se acaba de mover'));
        expect(tester.getSemantics(celda).label, contains('cargado'));

        // El anuncio accesible: con panel, la fila de «En vivo»; sin panel,
        // la región en vivo sin dibujo. Siempre con el rol y nunca el nombre.
        final anuncios = _anuncios(tester);
        final delMovimiento = anuncios.where((a) =>
            a.contains('Cargado') &&
            a.contains('Muelle') &&
            a.contains('FULL 000123 4') &&
            a.contains('003-02-82') &&
            a.contains('ahora'));
        expect(delMovimiento, hasLength(1), reason: 'un solo anuncio: $anuncios');
        expect(anuncios.join(' '), isNot(contains('Nombre sintetico')));
        if (tamano.width >= 1200) {
          expect(anuncio, findsNothing, reason: 'con panel anuncia «En vivo»');
          expect(enVivo, findsOneWidget);
        } else {
          expect(enVivo, findsNothing, reason: 'el panel no va al teléfono');
          final nodo = tester.getSemantics(anuncio);
          expect(nodo.flagsCollection.isLiveRegion, isTrue);
          expect(nodo.label, delMovimiento.single);
        }

        // Dura 1.5 s: a los 1480 ms sigue; a los 1500 se apaga.
        await tester.pump(const Duration(milliseconds: 1480));
        expect(_naranjas(tester), ['loading-C:FULL0001234']);
        await tester.pump(const Duration(milliseconds: 40));
        await tester.pump();
        expect(_naranjas(tester), isEmpty);
        expect(scope.read(recienMovidoProvider), isNull);
        expect(anuncio, findsNothing);

        // Una reserva con su vacío asignado se enciende igual.
        await _registrar(tester, log,
            MovementDraft.assignEmpty('op', '0030482', 'EMPTY0000012', 2185, order: 12));
        expect(scope.read(recienMovidoProvider)?.containerId, 'EMPTY0000012');
        final naranjas = _naranjas(tester);
        expect(naranjas, hasLength(1));
        expect(naranjas.single, contains('0030482'));
        expect(
            _anuncios(tester).where((a) =>
                a.contains('Vacío asignado') &&
                a.contains('Muelle') &&
                a.contains('ahora')),
            hasLength(1));
        await tester.pump(const Duration(milliseconds: 1600));
        await tester.pumpAndSettle();
        expect(_naranjas(tester), isEmpty);
        expect(tester.takeException(), isNull);
        semantica.dispose();
      });
    }

    testWidgets('con reducción de movimiento la celda de carga se queda quieta',
        (tester) async {
      final arnes = await _pumpCarga(tester, tamano: const Size(360, 800), sinMovimiento: true);
      final log = arnes.log;
      final celda = find.descendant(
          of: find.byKey(const ValueKey('loading-C:FULL0001234')),
          matching: find.byType(BsCelda));
      expect(tester.widget<BsCelda>(celda).estado, BsEstadoDeCelda.ninguno);
      final operacion = t76Operation(log.of('op').map((r) => r.movement).toList());
      await _registrar(tester, log, operacion.draft(t76List.rows.first, '0030282'));
      expect(_naranjas(tester), ['loading-C:FULL0001234']);
      final enSuSitio = _arribaDelCuerpo(tester, celda);
      final caja = tester.getRect(celda).top;
      await tester.pump(const Duration(milliseconds: 75));
      expect(_arribaDelCuerpo(tester, celda), closeTo(enSuSitio, 0.01),
          reason: 'a los 75 ms no se ha movido');
      await tester.pump(const Duration(milliseconds: 75));
      expect(_arribaDelCuerpo(tester, celda), closeTo(enSuSitio, 0.01));
      expect(enSuSitio, greaterThanOrEqualTo(caja), reason: 'dentro de su caja');
      await tester.pump(const Duration(milliseconds: 1400));
      await tester.pumpAndSettle();
      expect(_naranjas(tester), isEmpty);
      expect(tester.takeException(), isNull);
    });
  });

  group('el riel y el chip del zoom', () {
    testWidgets('el riel se desplaza en una ventana baja sin IntrinsicHeight',
        (tester) async {
      // 560 dp de alto: menos que lo que el riel pide con la marca, los
      // cinco destinos y el pie, así que se desplaza.
      await _pump(tester, tamano: const Size(800, 560));
      expect(riel, findsOneWidget);
      expect(find.ancestor(of: riel, matching: find.byType(IntrinsicHeight)),
          findsNothing);
      expect(find.ancestor(of: riel, matching: find.byType(CustomScrollView)),
          findsOneWidget);
      final nube = find.descendant(
          of: riel, matching: find.byKey(const ValueKey('cloud-page')));
      expect(nube, findsOneWidget);
      await tester.ensureVisible(nube);
      await tester.pumpAndSettle();
      expect(nube.hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'sin desbordamiento');
    });

    for (final letra in [1.45, 2.0]) {
      testWidgets(
          'a 360 dp con la letra a $letra el chip del zoom no tapa ninguna celda '
          'y su menú acerca y aleja', (tester) async {
        final scope = await _pump(tester,
            tamano: const Size(360, 800), muelle: true, letra: letra);
        final chip = find.byKey(const ValueKey('plan-zoom-toggle'));
        expect(chip, findsOneWidget);
        // Con la letra grande, la línea de los controles se desplaza.
        await tester.ensureVisible(chip);
        await tester.pumpAndSettle();
        expect(chip.hitTestable(), findsOneWidget);
        expect(find.ancestor(of: chip, matching: find.byType(LoadingPlanControls)),
            findsOneWidget, reason: 'vive en la línea de los controles');
        // Fuera del lienzo de la rejilla (la bahía 02), donde antes flotaba.
        final rect = tester.getRect(chip);
        final lienzo = tester.getRect(find.byKey(const ValueKey('plan-zoom-2')));
        expect(rect.overlaps(lienzo), isFalse,
            reason: 'el chip $rect pisa el lienzo de la rejilla $lienzo');
        expect(find.byKey(const ValueKey('plan-zoom-in')), findsNothing);
        await tester.tap(chip);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('plan-zoom-in')));
        await tester.pumpAndSettle();
        expect(scope.read(planZoomProvider), 1.25);
        expect(find.text('125 %'), findsWidgets);
        await tester.tap(find.byKey(const ValueKey('plan-zoom-reset')));
        await tester.pumpAndSettle();
        expect(scope.read(planZoomProvider), 1);
        await tester.tap(chip);
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('plan-zoom-in')), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('H4 · el teléfono bajo (DESIGN.md 13.8)', () {
    /// Las celdas del nivel más alto de la cubierta (la primera fila), enteras
    /// dentro del área del plano, sin desplazar.
    void primeraFilaALaVista(WidgetTester tester) {
      final area = tester.getRect(anidado);
      final fila = find.byWidgetPredicate((w) =>
          w.key is ValueKey<String> &&
          (w.key as ValueKey<String>).value.startsWith('cell-') &&
          (w.key as ValueKey<String>).value.endsWith('-92'));
      expect(fila, findsWidgets, reason: 'la primera fila está construida');
      for (final celda in fila.evaluate()) {
        final caja = celda.renderObject as RenderBox;
        final suya = caja.localToGlobal(Offset.zero) & caja.size;
        expect(suya.top, greaterThanOrEqualTo(area.top - 0.01));
        expect(suya.bottom, lessThanOrEqualTo(area.bottom + 0.01),
            reason: 'la celda $suya cabe en el área $area sin desplazar');
      }
    }

    testWidgets(
        'a 360 × 640 en previo, con la barra de estado, la primera rejilla se '
        've sin desplazar: silueta compacta y los controles al pie',
        (tester) async {
      await _pump(tester,
          tamano: const Size(360, 640), muelle: true, barraDeEstado: 24, previo: true);
      expect(anidado, findsOneWidget);
      expect(find.byKey(const ValueKey('preview-banner')), findsOneWidget);
      expect(find.byKey(const ValueKey('preview-sin-evaluar')), findsOneWidget);
      final silueta = tester.widget<BsSiluetaBuque>(
          find.byKey(const ValueKey('silueta-del-viaje')));
      expect(silueta.compacta, isTrue);
      expect(silueta.bahias, hasLength(12), reason: 'las mismas bahías');
      // Los controles del plano no están sobre la silueta: van al pie, con
      // la leyenda, a la vista y al alcance.
      expect(find.descendant(of: anidado, matching: find.byType(LoadingPlanControls)),
          findsNothing);
      final modo = find.byKey(const ValueKey('bay-plan-display-mode'));
      expect(modo.hitTestable(), findsOneWidget);
      expect(tester.getRect(modo).bottom, lessThanOrEqualTo(640));
      expect(find.byKey(const ValueKey('bay-plan-actions')).hitTestable(), findsOneWidget);
      expect(find.byKey(const ValueKey('plan-zoom-toggle')).hitTestable(), findsOneWidget);
      expect(find.byKey(const ValueKey('leyenda-del-plano')), findsOneWidget);
      expect(find.textContaining('Bahía 02'), findsOneWidget);
      primeraFilaALaVista(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'a 360 × 640 publicado en el muelle, en Descarga, la primera rejilla '
        'también se ve: los controles van en la barra de la operación',
        (tester) async {
      final scope = await _pump(tester,
          tamano: const Size(360, 640), muelle: true, barraDeEstado: 24);
      scope.read(bayPlanModeProvider.notifier).elegir(BayPlanMode.discharge);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('banda-del-muelle')), findsOneWidget);
      final barra = find.byKey(const ValueKey('barra-de-operacion'));
      expect(barra, findsOneWidget);
      expect(find.descendant(of: barra, matching: find.byKey(const ValueKey('bay-plan-display-mode'))),
          findsOneWidget);
      expect(find.descendant(of: anidado, matching: find.byType(LoadingPlanControls)),
          findsNothing);
      expect(find.byKey(const ValueKey('plan-summary-line')), findsOneWidget,
          reason: 'el resumen de T-107 sigue, encima de la barra');
      primeraFilaALaVista(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a 360 × 800 publicado nada cambia: los controles sobre la silueta normal',
        (tester) async {
      await _pump(tester, tamano: const Size(360, 800), muelle: true);
      expect(anidado, findsNothing);
      final silueta = tester.widget<BsSiluetaBuque>(
          find.byKey(const ValueKey('silueta-del-viaje')));
      expect(silueta.compacta, isFalse);
      final controles = tester.getRect(find.byType(LoadingPlanControls));
      final selector = tester.getRect(find.byKey(const ValueKey('bay-selector')));
      expect(controles.bottom, lessThanOrEqualTo(selector.top + 0.01));
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'a 360 × 800 en previo, con sus dos avisos, también es un teléfono bajo '
        'y la primera rejilla se ve sin desplazar', (tester) async {
      await _pump(tester,
          tamano: const Size(360, 800), muelle: true, barraDeEstado: 24, previo: true);
      expect(anidado, findsOneWidget);
      primeraFilaALaVista(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets('la silueta compacta mide menos, con las mismas bahías y etiquetas',
        (tester) async {
      final semantica = tester.ensureSemantics();
      final bahias = [
        for (var n = 2; n <= 22; n += 4)
          BsBahiaDeSilueta(numero: n, nivelesCubierta: 6, nivelesBodega: 6, conTrabajo: true),
      ];
      Future<double> alto({required bool compacta}) async {
        await tester.pumpWidget(MaterialApp(
          theme: BayStreamTema.claro(muelle: true),
          home: Scaffold(
            body: Center(
              child: BsSiluetaBuque(
                  bahias: bahias, onSeleccion: (_) {}, seleccionada: 10, compacta: compacta),
            ),
          ),
        ));
        await tester.pumpAndSettle();
        for (final b in bahias) {
          expect(find.byKey(ValueKey('silueta-bahia-${b.numero}')), findsOneWidget);
        }
        final boton = find.byKey(const ValueKey('silueta-bahia-10'));
        final nodo = tester.getSemantics(boton);
        expect(nodo.label, startsWith('Bahía 10, 6 niveles en cubierta y 6 en bodega'));
        expect(nodo.flagsCollection.isSelected, Tristate.isTrue);
        expect(tester.getSize(boton).height, greaterThanOrEqualTo(48),
            reason: 'cada bahía sigue siendo un botón de 48 dp o más');
        return tester.getSize(find.byType(BsSiluetaBuque)).height;
      }

      final normal = await alto(compacta: false);
      final compacta = await alto(compacta: true);
      expect(compacta, lessThan(normal - 60));
      expect(compacta, greaterThanOrEqualTo(48), reason: 'sigue siendo un botón');
      expect(tester.takeException(), isNull);
      semantica.dispose();
    });
  });
}
