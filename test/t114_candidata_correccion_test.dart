// T-114 · Corrección de la candidata del piloto tras la aceptación de Codex
// (SPRINT-4.md 10.29, H2): los avisos flotantes tapaban la franja de la
// operación («Acciones», «OR / últimos dígitos», el modo y el zoom en el
// teléfono bajo) y el pie de la página del listado («Confirmar e importar»),
// y obligaban a esperar 6 s entre un contenedor y el siguiente. Ahora el pie
// del plano mide su alto (`MideElPieDelPlano`) y la página lo convierte en el
// aire de abajo de los avisos (`AvisosSobreElPie`): flotan por encima de la
// franja, entre la rejilla y la barra, como dibuja DESIGN.md 13.8 («9.3 bis»);
// «Deshacer» queda a mano durante todo su plazo y los controles, tocables.
// En el listado de la agencia, los dos botones van al pie fijo de la página y
// el aviso flota por encima.
//
// Los planos son los sintéticos de T-76 (BUQUE PRUEBA, GTSTC); el listado, el
// de T-73. El teléfono bajo es el del emulador: el plano queda con menos de
// 560 dp de alto y los controles bajan a la franja (13.8).
import 'dart:io';

import 'package:baystream/core/app.dart';
import 'package:baystream/core/design/design.dart';
import 'package:baystream/core/errors/failures.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_impl.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/local_vessel_repository.dart';
import 'package:baystream/features/vessel/domain/repositories/movement_log_repository.dart';
import 'package:baystream/features/vessel/presentation/pages/export_list_import_page.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_overview_page.dart';
import 'package:baystream/features/vessel/presentation/providers/export_list_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_operation_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/plano_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/avisos_del_viaje.dart';
import 'package:baystream/features/vessel/presentation/widgets/bay_plan_view.dart';
import 'package:baystream/features/vessel/presentation/widgets/loading_plan_controls.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/local_profile_test_support.dart';
import 'support/t73_export_list_support.dart';
import 'support/t74_movement_log_support.dart';
import 'support/t75_memory_log.dart';
import 'support/t76_fixture.dart';

/// El alto que le queda al plano en el emulador de 360 × 640 dp debajo de la
/// barra de estado, la banda de la marca y la barra inferior: menos de
/// `alturaParaAnidar` (560), así que va anidado y con los controles en la
/// franja del pie. Las medidas son las reales porque las fuentes también lo
/// son ([_cargarFuentes]): con la fuente cuadrada de las pruebas, el aviso
/// medía el doble que con Plex.
const _telefonoBajo = Size(360, 420);

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
final _avisoDeCarga = find.byKey(const ValueKey('loading-undo-snackbar'));
final _avisoDeDescarga = find.byKey(const ValueKey('discharge-undo-snackbar'));

/// La tarjeta de un aviso (su `Material`), sin el aire que lo separa del pie.
Rect _tarjeta(WidgetTester tester, Finder aviso) => tester.getRect(
    find.descendant(of: aviso, matching: find.byType(Material)).first);

/// Trae a la vista un control de la fila que se desplaza y lo toca.
Future<void> _tocar(WidgetTester tester, Finder control) async {
  await tester.ensureVisible(control);
  await tester.pumpAndSettle();
  await tester.tap(control);
  await tester.pumpAndSettle();
}

/// El aviso flota entero por encima de la fila de controles de la franja,
/// con aire entre los dos, y no pisa ninguna celda de la rejilla; puede
/// quedar sobre las cifras.
void _porEncimaDelPie(WidgetTester tester, Finder aviso) {
  final rectoDelAviso = _tarjeta(tester, aviso);
  final rectoDeControles = tester.getRect(_controles);
  expect(rectoDelAviso.bottom, lessThanOrEqualTo(rectoDeControles.top),
      reason: 'el aviso (${rectoDelAviso.bottom}) no puede pisar los controles '
          '(${rectoDeControles.top})');
  expect(rectoDelAviso.overlaps(rectoDeControles), isFalse);
  for (final celda in find.byWidgetPredicate((Widget w) =>
      w.key is ValueKey<String> &&
      (w.key! as ValueKey<String>).value.startsWith('cell-')).evaluate()) {
    final recto = tester.getRect(find.byWidget(celda.widget));
    expect(rectoDelAviso.overlaps(recto), isFalse,
        reason: 'el aviso tapa la celda ${celda.widget.key}');
  }
}

/// Lo que mide la franja para los avisos: su fila de controles más el aire
/// de abajo de la barra.
double _medidaDeLaFranja(WidgetTester tester) =>
    tester.getSize(_controles).height +
    BsMedidas.de(tester.element(_controles)).espacioM;

/// El pie, dentro de [AvisosSobreElPie] y un `Scaffold` como el de la página.
Widget _muelle(ProviderContainer scope, Widget plano) => UncontrolledProviderScope(
      container: scope,
      child: MaterialApp(
        theme: BayStreamTema.claro(muelle: true),
        home: AvisosSobreElPie(child: Scaffold(body: plano)),
      ),
    );

class _Local implements LocalVesselRepository {
  CodeEquivalences table = CodeEquivalences.empty;

  @override
  Future<Either<Failure, CodeEquivalences>> getCodeEquivalences() async =>
      Right(table);

  @override
  Future<Either<Failure, void>> saveCodeEquivalences(
      CodeEquivalences equivalences) async {
    table = equivalences;
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Log implements MovementLogRepository {
  final operations = <Operation>[];

  @override
  Future<Either<Failure, List<Operation>>> getOperations() async =>
      Right(List.of(operations));

  @override
  Future<Either<Failure, void>> saveOperation(Operation operation) async {
    operations
      ..removeWhere((o) => o.id == operation.id)
      ..add(operation);
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PlanNotifier extends VoyageNotifier {
  final VesselVoyage plan;
  _PlanNotifier(this.plan);

  @override
  AsyncValue<VesselVoyage?> build() => AsyncValue.data(plan);
}

const _cabecera = "UNH+1+BAPLIE:D:95B:UN:SMDG20'"
    "TDT+20+V01N+++NV2:172:20+++9000003:146:11:BUQUE MANUAL'";

/// Plan de carga: sale de GTSTC y todo se cargó en GTSTC.
const _planDeCarga = "${_cabecera}LOC+5+GTSTC:139:6'"
    "LOC+147+0020182::5'LOC+9+GTSTC:139:6'LOC+11+USHOU:139:6'"
    "EQD+CN+TEST0000001+42G1+++5'"
    "LOC+147+0020184::5'LOC+9+GTSTC:139:6'LOC+11+USHOU:139:6'"
    "EQD+CN+TEST0000002+42G1+++5'";

class _ReplayNotifier extends VoyageNotifier {
  @override
  Future<LoadFileResult> loadVesselFromFile() =>
      parseBaplieContent(_planDeCarga, fileName: 'BUQUE_MANUAL.edi');
}

void main() {
  group('el pie del plano se mide y los avisos flotan por encima', () {
    testWidgets(
        'en Carga, en el teléfono bajo: el aviso del registro queda entre la '
        'rejilla y la franja, y dos cargas seguidas por OR no esperan',
        (tester) async {
      await tester.runAsync(_cargarFuentes);
      tester.view.physicalSize = _telefonoBajo;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
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
      await tester.pumpWidget(_muelle(scope, BayPlanView(voyage: t76Loading)));
      await tester.pumpAndSettle();
      // El teléfono bajo: el plano anidado y los controles en la franja.
      expect(find.byKey(const ValueKey('plano-anidado')), findsOneWidget);
      await _tocar(tester, find.byKey(const ValueKey('bay-plan-display-mode')));
      await tester.tap(find.text('Carga').last);
      await tester.pumpAndSettle();
      expect(_franja, findsOneWidget);
      expect(find.byKey(const ValueKey('load-search')), findsOneWidget);
      // El pie midió su fila de controles con el aire de abajo de la barra.
      final altoDelPie = _medidaDeLaFranja(tester);
      expect(altoDelPie, greaterThanOrEqualTo(48));
      expect(scope.read(pieDelPlanoProvider), altoDelPie);
      // El tema de la página lleva ese aire.
      final temaDeAvisos = Theme.of(tester.element(_franja)).snackBarTheme;
      expect(temaDeAvisos.insetPadding?.bottom,
          AvisosSobreElPie.aire(BsMedidas.de(tester.element(_franja)), altoDelPie)
              .bottom);

      Future<void> cargar(String consulta, int or) async {
        await _tocar(tester, find.byKey(const ValueKey('load-search')));
        await tester.enterText(find.byKey(const ValueKey('loading-query')), consulta);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(ValueKey('loading-or-$or')));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byKey(const ValueKey('loading-confirm')));
        await tester.tap(find.byKey(const ValueKey('loading-confirm')));
        await tester.pumpAndSettle();
      }

      // La primera carga: el aviso con «Deshacer», por encima de la franja.
      await cargar('1', 1);
      expect(_avisoDeCarga, findsOneWidget);
      // La celda planificada la ocupa uno de llegada: «Descarga y carga
      // registradas · OR 1» (T-77); si no, «Carga registrada · OR 1».
      expect(
          find.descendant(
              of: _avisoDeCarga,
              matching: find.textContaining(RegExp(r'registradas? · OR 1$'))),
          findsOneWidget);
      expect(find.text('Deshacer'), findsOneWidget);
      _porEncimaDelPie(tester, _avisoDeCarga);
      expect(log.of('op').last.movement.type, MovementType.loadFull);

      // Con el aviso en pantalla, los controles de la franja responden:
      // «Acciones» abre su menú…
      await _tocar(tester, find.byKey(const ValueKey('bay-plan-actions')));
      expect(find.byKey(const ValueKey('empty-search')), findsOneWidget);
      await tester.tapAt(const Offset(8, 8));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('empty-search')), findsNothing);
      expect(_avisoDeCarga, findsOneWidget, reason: 'el aviso sigue su plazo');

      // …y la segunda carga por OR sale sin esperar a que el aviso se vaya.
      await cargar('5678', 2);
      expect(
          find.descendant(
              of: _avisoDeCarga,
              matching: find.textContaining(RegExp(r'registradas? · OR 2$'))),
          findsOneWidget);
      _porEncimaDelPie(tester, _avisoDeCarga);
      // T-77: antes de cada carga queda la descarga del ocupante; las
      // cargas son dos.
      expect(
          log.of('op').where((r) => r.movement.type == MovementType.loadFull),
          hasLength(2));

      // «Deshacer» sigue a mano hasta el final de su plazo (6 s).
      await tester.pump(const Duration(seconds: 5));
      expect(find.text('Deshacer'), findsOneWidget);
      await tester.tap(find.text('Deshacer'));
      await tester.pumpAndSettle();
      expect(log.of('op').last.movement.type, MovementType.annul);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'en Descarga, en el teléfono bajo: «Baja» avisa por encima de la '
        'franja y la siguiente «Baja» no espera', (tester) async {
      await tester.runAsync(_cargarFuentes);
      tester.view.physicalSize = _telefonoBajo;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
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
      await tester.pumpWidget(_muelle(scope, BayPlanView(voyage: t76Arrival)));
      await tester.pumpAndSettle();
      await _tocar(tester, find.byKey(const ValueKey('bay-plan-display-mode')));
      await tester.tap(find.text('Descarga').last);
      await tester.pumpAndSettle();
      expect(_franja, findsOneWidget);
      expect(scope.read(pieDelPlanoProvider), _medidaDeLaFranja(tester));

      await tester.tap(find.byKey(const ValueKey('cell-2-82')));
      await tester.pumpAndSettle();
      expect(_avisoDeDescarga, findsOneWidget);
      expect(find.textContaining('Descargado · INCOMING1'), findsOneWidget);
      _porEncimaDelPie(tester, _avisoDeDescarga);
      // La siguiente «Baja», con el aviso anterior todavía en pantalla: la
      // celda está libre (lo comprueba `_porEncimaDelPie`) y responde.
      await tester.tap(find.byKey(const ValueKey('cell-4-82')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Descargado · INCOMING2'), findsOneWidget);
      _porEncimaDelPie(tester, _avisoDeDescarga);
      expect(log.of('op-llegada'), hasLength(2));
      // Y el modo sigue al alcance debajo del aviso.
      await _tocar(tester, find.byKey(const ValueKey('bay-plan-display-mode')));
      expect(find.text('Carga').last, findsOneWidget);
      await tester.tapAt(const Offset(8, 8));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('la hoja de los vacíos queda por encima de los avisos: su pie responde',
        (tester) async {
      await tester.runAsync(_cargarFuentes);
      tester.view.physicalSize = _telefonoBajo;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
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
      await tester.pumpWidget(_muelle(scope, BayPlanView(voyage: t76Loading)));
      await tester.pumpAndSettle();
      await _tocar(tester, find.byKey(const ValueKey('bay-plan-display-mode')));
      await tester.tap(find.text('Carga').last);
      await tester.pumpAndSettle();
      // Un aviso de 6 s como el de un registro, y encima la hoja.
      ScaffoldMessenger.of(tester.element(_franja)).showSnackBar(SnackBar(
        key: const ValueKey('aviso-de-prueba'),
        duration: const Duration(seconds: 6),
        content: const Text('Carga registrada · OR 1'),
        action: SnackBarAction(label: 'Deshacer', onPressed: () {}),
      ));
      await tester.pumpAndSettle();
      await _tocar(tester, find.byKey(const ValueKey('bay-plan-actions')));
      await tester.tap(find.byKey(const ValueKey('empty-search')));
      await tester.pumpAndSettle();
      expect(find.text('Vacíos del listado'), findsOneWidget);
      // El pie de la hoja («Cerrar») está por encima del aviso y responde.
      await tester.tap(find.text('Cerrar'));
      await tester.pumpAndSettle();
      expect(find.text('Vacíos del listado'), findsNothing);
      expect(find.byKey(const ValueKey('aviso-de-prueba')), findsOneWidget,
          reason: 'la hoja no apaga el aviso: su plazo sigue');
      expect(tester.takeException(), isNull);
    });
  });

  group('la página del viaje pone el aire de sus avisos', () {
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

    testWidgets(
        'en el muelle (Android, 360 × 640) el aviso de la página flota por '
        'encima de la franja; en la Lista, sin plano, vuelve al pie',
        (tester) async {
      await tester.runAsync(() async {
        await _cargarFuentes();
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        await abrir();
        try {
          final n = container.read(voyageNotifierProvider.notifier);
          final leido =
              await n.parseBaplieContent(_planDeCarga, fileName: 'carga.edi');
          expect(leido.preview, isTrue);
          expect(
              await n.confirmGeometry(n.currentProfile!.geometry,
                  portOfCall: 'GTSTC',
                  sourceKind: OperationSourceKind.loadingBaplie),
              isNull);
          tester.view.physicalSize = const Size(360, 640);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          await tester.pumpWidget(UncontrolledProviderScope(
              container: container, child: const BayStreamApp()));
          await tester.pumpAndSettle();
          // Publicado en el muelle, operando en Carga (la banda ofrece el
          // modo; aquí se elige directo): la franja al pie.
          expect(find.byKey(const ValueKey('barra-del-viaje')), findsOneWidget);
          container.read(bayPlanModeProvider.notifier).elegir(BayPlanMode.loading);
          await tester.pumpAndSettle();
          expect(_franja, findsOneWidget);
          final altoDelPie = _medidaDeLaFranja(tester);
          expect(container.read(pieDelPlanoProvider), altoDelPie);
          final pagina = tester.element(find.byType(VesselOverviewPage));
          ScaffoldMessenger.of(pagina).showSnackBar(const SnackBar(
              key: ValueKey('aviso-de-la-pagina'),
              content: Text('Archivo "carga.edi" cargado correctamente')));
          await tester.pumpAndSettle();
          final avisoDeLaPagina = find.byKey(const ValueKey('aviso-de-la-pagina'));
          expect(avisoDeLaPagina, findsOneWidget);
          _porEncimaDelPie(tester, avisoDeLaPagina);
          // Los controles de la franja están a la vista y debajo del aviso.
          expect(find.byKey(const ValueKey('bay-plan-actions')), findsOneWidget);
          expect(find.byKey(const ValueKey('load-search')), findsOneWidget);
          ScaffoldMessenger.of(pagina).clearSnackBars();
          await tester.pumpAndSettle();
          // En la Lista no hay plano ni franja: la medida no aplica y el
          // aviso vuelve al pie de la pantalla, sobre la barra inferior.
          await tester.tap(find.byKey(const ValueKey('destino-lista')));
          await tester.pumpAndSettle();
          expect(_franja, findsNothing);
          ScaffoldMessenger.of(pagina).showSnackBar(const SnackBar(
              key: ValueKey('aviso-en-la-lista'),
              content: Text('Archivo "carga.edi" cargado correctamente')));
          await tester.pumpAndSettle();
          final enLaLista =
              _tarjeta(tester, find.byKey(const ValueKey('aviso-en-la-lista')));
          final barra = tester.getRect(find.byKey(const ValueKey('barra-del-viaje')));
          expect(enLaLista.bottom, lessThanOrEqualTo(barra.top));
          expect(barra.top - enLaLista.bottom, lessThan(altoDelPie),
              reason: 'sin franja, el aviso baja a su sitio de siempre');
          // Y de vuelta al Plano, la franja vuelve a medirse.
          await tester.tap(find.byKey(const ValueKey('destino-plano')));
          await tester.pumpAndSettle();
          expect(container.read(pieDelPlanoProvider), altoDelPie);
          expect(tester.takeException(), isNull);
        } finally {
          await tester.pumpWidget(const SizedBox.shrink());
          await cerrar();
          debugDefaultTargetPlatformOverride = null;
        }
      });
    });
  });

  group('el listado de la agencia', () {
    testWidgets(
        'a 360 dp, «Descartar» y «Confirmar e importar» van al pie fijo, '
        'siempre a la vista, y el aviso flota por encima', (tester) async {
      await tester.runAsync(_cargarFuentes);
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final local = _Local();
      final log = _Log();
      await tester.pumpWidget(ProviderScope(overrides: [
        voyageNotifierProvider.overrideWith(() => _PlanNotifier(t73Plan())),
        localVesselRepositoryProvider.overrideWith((ref) async => local),
        movementLogRepositoryProvider.overrideWith((ref) async => log),
      ], child: MaterialApp(
          theme: BayStreamTema.claro(muelle: true),
          home: const ExportListImportPage())));
      await tester.pump();
      final container = ProviderScope.containerOf(
          tester.element(find.byType(ExportListImportPage)));
      // Sin listado leído no hay pie.
      expect(find.byKey(const ValueKey('export-list-confirm')), findsNothing);
      await container
          .read(exportListImportProvider.notifier)
          .loadBytes(t73ListBytes(), fileName: 'sintetico.xlsx');
      await tester.pumpAndSettle();
      final confirmar = find.byKey(const ValueKey('export-list-confirm'));
      expect(confirmar, findsOneWidget);
      expect(find.text('Descartar'), findsOneWidget);
      // En el pie fijo del Scaffold, sin desplazar la lista.
      expect(
          find.ancestor(of: confirmar, matching: find.byType(Scrollable)),
          findsNothing,
          reason: 'el botón ya no viaja con la lista');
      final recto = tester.getRect(confirmar);
      expect(recto.bottom, lessThanOrEqualTo(640));
      // El aviso de hace un momento («cargado correctamente», 4 s) flota
      // por encima del pie y el botón sigue tocable.
      ScaffoldMessenger.of(tester.element(confirmar)).showSnackBar(const SnackBar(
          key: ValueKey('aviso-cargado'),
          content: Text('Archivo "T100_CARGA.edi" cargado correctamente')));
      await tester.pumpAndSettle();
      final aviso = _tarjeta(tester, find.byKey(const ValueKey('aviso-cargado')));
      expect(aviso.bottom, lessThanOrEqualTo(recto.top));
      expect(aviso.overlaps(recto), isFalse);
      final habilitado = tester.widget<ButtonStyleButton>(confirmar).enabled;
      if (habilitado) {
        await tester.tap(confirmar);
        await tester.pumpAndSettle();
        expect(find.text('Listado importado.'), findsOneWidget);
      } else {
        // Con equivalencias pendientes el botón espera, pero está a la vista
        // sin desplazar; la explicación va al final de la lista.
        await tester.scrollUntilVisible(find.textContaining('Falta elegir'), 300,
            scrollable: find.byType(Scrollable).first);
        expect(find.textContaining('Falta elegir'), findsOneWidget);
        expect(confirmar, findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });
  });
}
