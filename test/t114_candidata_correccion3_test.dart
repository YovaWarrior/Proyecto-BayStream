// T-114 · Tercera corrección de la candidata del piloto (SPRINT-4.md 10.33,
// H2-A y H2-B de la segunda reaceptación de Codex): la regla de 10.31 cubría
// los avisos de los cuatro archivos de la página del viaje, pero quedaban
// nueve avisos hechos a mano en otras ocho partes de la app que se ven sobre
// el plano: Comparar, que se llama desde el plano, y los de otras páginas
// (Parámetros, Tapas en la operación, Perfiles, BAPLIE de salida, Listado de
// la agencia, Tapas de escotilla y Viajes recientes), que siguen en pantalla
// al volver al plano mientras dura su plazo. Con la letra a 2.0, el error de
// Comparar y el de Parámetros tapaban nueve celdas, y el registro de una tapa
// pisaba el resumen que se abre con un toque. Ahora todos los avisos de la
// app se hacen con `avisoDelViaje`: donde se vean, saben su lugar.
//
// La base es la de la segunda corrección y la de la reaceptación de Codex: la
// app entera con las fuentes reales, el plan sintético de 24 contenedores
// (filas 02 a 08, niveles 82 a 92) y el plano desplazado; cada celda se
// recorta con los desplazables y la ventana antes de compararla con el aviso.
// Las tres rutas de Codex corren de verdad: Comparar con un archivo vacío,
// el error de guardar el tema en Parámetros y el registro de una tapa con su
// «Deshacer», en 360 × 640, 360 × 800 (el Honor) y 412 × 915, con la letra a
// 2.0. Una guarda revisa todo `lib/`.
import 'dart:io';
import 'dart:math' as math;

import 'package:baystream/core/app.dart';
import 'package:baystream/core/design/design.dart';
import 'package:baystream/features/vessel/domain/entities/app_theme_preference.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';
import 'package:baystream/features/vessel/presentation/formatters/vessel_error_message.dart';
import 'package:baystream/features/vessel/presentation/pages/parameters_page.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_overview_page.dart';
import 'package:baystream/features/vessel/presentation/pages/voyage_comparison_page.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_operation_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/plano_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/theme_preference_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/avisos_del_viaje.dart';
import 'package:baystream/features/vessel/presentation/widgets/bay_plan_view.dart';
import 'package:baystream/features/vessel/presentation/widgets/hatch_operation_controls.dart';
import 'package:baystream/features/vessel/presentation/widgets/loading_controls.dart';
import 'package:baystream/features/vessel/presentation/widgets/loading_plan_controls.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/local_profile_test_support.dart';
import 'support/t75_memory_log.dart';
import 'support/t76_fixture.dart';

var _fuentesCargadas = false;

/// Las fuentes del producto (Plex, Roboto y los íconos), para que el aviso,
/// la franja y las celdas midan lo que miden en el muelle.
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
final _aviso = find.byType(SnackBar);

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

/// Las comprobaciones de 10.31 sobre el aviso a la vista, más el resumen de
/// encima de la barra (H2-B): (1) no pasa del borde de arriba de la franja ni
/// cruza una celda visible ni el resumen; (2) la fila de controles queda
/// libre; (3) su texto está entero y no desborda. Devuelve el texto que se
/// ve, que tiene que ser uno de los del aviso ([textos]).
String _comprobar(WidgetTester tester, Size ventana, List<String> textos) {
  final tarjeta = _tarjeta(tester, _aviso);
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
  final resumen = find.byType(PlanSummaryLine);
  if (resumen.evaluate().isNotEmpty) {
    final recto = tester.getRect(resumen);
    expect(tarjeta.overlaps(recto), isFalse,
        reason: 'el aviso $tarjeta tapa el resumen $recto');
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
      .descendant(of: _aviso, matching: find.byType(RichText))
      .evaluate()
      .map((e) => e.renderObject! as RenderParagraph)
      .where((p) => textos.contains(p.text.toPlainText()))
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
  final VesselVoyage plan;

  @override
  AsyncValue<VesselVoyage?> build() => AsyncValue.data(plan);
}

/// Guardar el tema falla en este dispositivo (Parámetros, H2-A).
class _TemaQueFalla extends ThemePreferenceNotifier {
  @override
  Future<AppThemePreference> build() async => AppThemePreference.system;

  @override
  Future<void> select(AppThemePreference preference) async =>
      throw StateError('Fallo sintético de escritura');
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

/// El archivo vacío que se elige para comparar y el error que trae.
const _vacio = 'T100_SINTETICO_VACIO.edi';
const _errorDeComparar = 'Archivo «$_vacio»: $notBaplieFileMessage';

/// La app entera en Descarga, en [ventana] y con la letra a [escala], con la
/// tapa 1 de la bahía 3 declarada; el cuerpo corre con todo montado y después
/// se desmonta.
Future<void> _enLaApp(WidgetTester tester,
    {required Size ventana,
    required double escala,
    required Future<void> Function(ProviderContainer scope) cuerpo}) async {
  await tester.runAsync(() async {
    await _cargarFuentes();
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    final store = await testProfileStore();
    final scope = ProviderContainer(overrides: [
      themePreferenceProvider.overrideWith(_TemaQueFalla.new),
      comparisonFilePickerProvider
          .overrideWithValue(() async => (name: _vacio, content: '')),
      movementLogRepositoryProvider.overrideWith((ref) async => T75MemoryLog()),
      vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
      localVesselRepositoryProvider.overrideWith((ref) async => store.repository),
      voyageNotifierProvider.overrideWith(() => _QaPlan(_llegada)),
      loadingOperationProvider(_llegada).overrideWith((ref) async* {
        yield LoadingOperation.build(
            operationId: 'qa',
            arrival: _llegada,
            loading: _salida,
            list: ExportList(fileName: 'qa-sintetico.xlsx', rows: [
              for (var i = 0; i < _salida.containers.length; i++)
                t76Row(i + 1, _salida.containers[i].containerId)
            ]),
            movements: const [],
            hatchCovers: {
              3: HatchCoverDeclaration(
                  kind: HatchCoverKind.crane,
                  covers: const [
                    {2, 4}
                  ])
            });
      }),
    ]);
    tester.view.physicalSize = ventana;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = escala;
    try {
      await tester.pumpWidget(UncontrolledProviderScope(
          container: scope, child: const BayStreamApp()));
      await tester.pumpAndSettle();
      scope.read(bayPlanModeProvider.notifier).elegir(BayPlanMode.discharge);
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

/// El contraste entre dos colores, como lo mide WCAG.
double _contraste(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  group('los avisos de Comparar y de otras páginas saben su lugar en el plano',
      () {
    const ventanas = <Size>[Size(360, 640), Size(360, 800), Size(412, 915)];
    for (final ventana in ventanas) {
      final tamano = '${ventana.width.toInt()} × ${ventana.height.toInt()}';

      testWidgets(
          'Comparar con un archivo vacío, desde el plano, a $tamano con la '
          'letra a 2.0: el error no pasa de la franja y «Ver» lo abre entero',
          (WidgetTester tester) async {
        await _enLaApp(tester, ventana: ventana, escala: 2,
            cuerpo: (ProviderContainer scope) async {
          await _desplazar(tester);
          final pagina = tester.element(find.byType(VesselOverviewPage));
          final ref =
              (tester.state(find.byType(BayPlanView)) as ConsumerState).ref;
          await compareWithAnotherBaplie(pagina, ref, _llegada);
          await tester.pumpAndSettle();
          expect(_aviso, findsOneWidget);
          final visto = _comprobar(
              tester, ventana, const [_errorDeComparar, 'No se pudo comparar.']);
          if (visto != _errorDeComparar) {
            await tester.tap(
                find.descendant(of: _aviso, matching: find.text('Ver')));
            await tester.pumpAndSettle();
            expect(find.byKey(const ValueKey('aviso-entero')), findsOneWidget);
            expect(find.text(_errorDeComparar), findsOneWidget);
            await tester.tap(find.text('Cerrar'));
            await tester.pumpAndSettle();
            expect(find.byKey(const ValueKey('aviso-entero')), findsNothing);
          }
          expect(tester.takeException(), isNull);
        });
      });

      testWidgets(
          'el error de Parámetros, al volver al plano a $tamano con la letra '
          'a 2.0, no pasa de la franja; en su página se lee entero',
          (WidgetTester tester) async {
        await _enLaApp(tester, ventana: ventana, escala: 2,
            cuerpo: (ProviderContainer scope) async {
          await _desplazar(tester);
          Navigator.of(tester.element(find.byType(VesselOverviewPage))).push(
              MaterialPageRoute<void>(builder: (_) => const ParametersPage()));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const ValueKey('theme-choice-system')));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Oscuro').last);
          await tester.pumpAndSettle();
          // En Parámetros no hay franja: el aviso no tiene tope y lo dice
          // entero.
          final entero = unexpectedErrorMessage('guardar el tema');
          expect(find.descendant(of: _aviso, matching: find.text(entero)),
              findsOneWidget);
          Navigator.of(tester.element(find.byType(ParametersPage))).pop();
          await tester.pumpAndSettle();
          expect(_aviso, findsOneWidget);
          _comprobar(tester, ventana, [entero, 'No se guardó el tema.']);
          expect(tester.takeException(), isNull);
        });
      });

      testWidgets(
          'el registro de una tapa, al volver al plano a $tamano con la letra '
          'a 2.0, no pisa el resumen ni la franja, y «Deshacer» deshace',
          (WidgetTester tester) async {
        await _enLaApp(tester, ventana: ventana, escala: 2,
            cuerpo: (ProviderContainer scope) async {
          await _desplazar(tester);
          Navigator.of(tester.element(find.byType(VesselOverviewPage))).push(
              MaterialPageRoute<void>(
                  builder: (_) =>
                      HatchOperationPage(voyage: _llegada, initialBay: 3)));
          await tester.pumpAndSettle();
          final quitar = find.byKey(const ValueKey('hatch-remove-T:3-1'));
          await tester.ensureVisible(quitar);
          await tester.tap(quitar);
          await tester.pumpAndSettle();
          expect(find.text('Movimiento de tapa registrado'), findsOneWidget);
          Navigator.of(tester.element(find.byType(HatchOperationPage))).pop();
          await tester.pumpAndSettle();
          expect(_aviso, findsOneWidget);
          _comprobar(tester, ventana,
              const ['Movimiento de tapa registrado', 'Tapa registrada']);
          await tester.tap(
              find.descendant(of: _aviso, matching: find.text('Deshacer')));
          await tester.pumpAndSettle();
          final bitacora = await scope.read(movementLogRepositoryProvider.future)
              as T75MemoryLog;
          expect(bitacora.of('qa').last.movement.type, MovementType.annul);
          expect(tester.takeException(), isNull);
        });
      });
    }
  });

  group('un aviso con fondo de error se lee', () {
    for (final (nombre, tema) in <(String, ThemeData)>[
      ('claro', BayStreamTema.claro(muelle: true)),
      ('oscuro', BayStreamTema.oscuro(muelle: true)),
    ]) {
      testWidgets(
          'con el tema $nombre, el texto y «Ver» van en el color de contraste '
          'del error', (WidgetTester tester) async {
        // En el teléfono, con 80 dp de lugar: el error entero no cabe con
        // ninguna fuente y sale el corto, con «Ver».
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(MaterialApp(
          theme: tema,
          home: LugarDelAviso(
            alto: 80,
            child: Scaffold(
              body: Builder(
                builder: (BuildContext context) => TextButton(
                  onPressed: () => ScaffoldMessenger.of(context)
                      .showSnackBar(avisoDelViaje(
                    texto: unexpectedErrorMessage('guardar el tema'),
                    corto: 'No se guardó el tema.',
                    fondo: Theme.of(context).colorScheme.error,
                  )),
                  child: const Text('mostrar'),
                ),
              ),
            ),
          ),
        ));
        await tester.tap(find.text('mostrar'));
        await tester.pumpAndSettle();
        final esquema = tema.colorScheme;
        for (final texto in ['No se guardó el tema.', 'Ver']) {
          final parrafo = tester.renderObject<RenderParagraph>(
              find.descendant(of: _aviso, matching: find.text(texto)));
          expect(parrafo.text.style?.color, esquema.onError, reason: texto);
        }
        expect(_contraste(esquema.onError, esquema.error),
            greaterThanOrEqualTo(4.5));
      });
    }
  });

  group('todos los avisos de la app pasan por avisoDelViaje', () {
    test('ningún archivo de lib/ hace un aviso a mano', () {
      // Un `SnackBar(` hecho a mano no sabe su lugar: donde se vea sobre el
      // plano, crece sin tope. Solo la fábrica lo construye.
      const fabrica =
          'lib/features/vessel/presentation/widgets/avisos_del_viaje.dart';
      final aMano = RegExp(r'(?<![A-Za-z_])SnackBar\(');
      final archivos = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .toList();
      expect(archivos, isNotEmpty);
      for (final archivo in archivos) {
        final ruta = archivo.path.replaceAll(r'\', '/');
        if (ruta.endsWith(fabrica)) continue;
        expect(aMano.allMatches(archivo.readAsStringSync()), isEmpty,
            reason: ruta);
      }
      // Las ocho partes que tenían avisos a mano los hacen con la fábrica.
      for (final ruta in const [
        'lib/features/vessel/presentation/pages/voyage_comparison_page.dart',
        'lib/features/vessel/presentation/pages/parameters_page.dart',
        'lib/features/vessel/presentation/widgets/hatch_operation_controls.dart',
        'lib/features/vessel/presentation/pages/vessel_profiles_page.dart',
        'lib/features/vessel/presentation/pages/departure_baplie_page.dart',
        'lib/features/vessel/presentation/pages/export_list_import_page.dart',
        'lib/features/vessel/presentation/pages/hatch_covers_page.dart',
        'lib/features/vessel/presentation/pages/recent_voyages_page.dart',
      ]) {
        expect(File(ruta).readAsStringSync(), contains('avisoDelViaje('),
            reason: ruta);
      }
    });
  });
}
