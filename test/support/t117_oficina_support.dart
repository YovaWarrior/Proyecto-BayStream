// T-117 y T-118 · Lo común a las pruebas de la oficina (DESIGN.md 14): el
// viaje sintético, las fuentes del producto, un almacén del equipo en memoria
// con las preferencias y la página completa con el tema de la oficina.
//
// Buque y números sintéticos (BUQUE MANUAL, TSTU); sin nube ni almacén real.
import 'package:baystream/core/design/design.dart';
import 'package:baystream/core/errors/failures.dart';
import 'package:baystream/features/vessel/data/repositories/local_only_operation_sync.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/app_theme_preference.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/local_vessel_repository.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_overview_page.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/plano_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/loading_plan_controls.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'local_profile_test_support.dart';
import 't74_movement_log_support.dart';

/// Un plano de llegada a GTSTC con dos bahías. La 002 es una pila de seis
/// niveles en cubierta (82 a 92) y seis en bodega (02 a 12), como las bahías
/// llenas del corpus, para que la silueta mida lo que mide con el corpus
/// (161 dp) y la columna tenga que desplazarse: llenos a GTSTC y a USHOU y un
/// vacío. En la 006, dos llenos (a PAMIT y a GTSTC). Hay Descarga y Carga.
const t117Texto = "UNH+1+BAPLIE:D:95B:UN:SMDG22'"
    "TDT+20+V117+++TST:172:20+++9000117:146:11:BUQUE MANUAL'"
    "LOC+5+HNPCR:139:6'LOC+61+GTSTC:139:6'"
    "LOC+147+0020182::5'LOC+9+HNPCR:139:6'LOC+11+GTSTC:139:6'"
    "MEA+AAE+VGM+KGM:20000'EQD+CN+TSTU0000011+42G1+++5'"
    "LOC+147+0020184::5'LOC+9+HNPCR:139:6'LOC+11+USHOU:139:6'"
    "MEA+AAE+VGM+KGM:21000'EQD+CN+TSTU0000022+42G1+++5'"
    "LOC+147+0020186::5'LOC+9+HNPCR:139:6'LOC+11+GTSTC:139:6'"
    "MEA+AAE+VGM+KGM:15000'EQD+CN+TSTU0000061+42G1+++5'"
    "LOC+147+0020188::5'LOC+9+HNPCR:139:6'LOC+11+USHOU:139:6'"
    "MEA+AAE+VGM+KGM:14000'EQD+CN+TSTU0000077+42G1+++5'"
    "LOC+147+0020190::5'LOC+9+HNPCR:139:6'LOC+11+GTSTC:139:6'"
    "MEA+AAE+VGM+KGM:12000'EQD+CN+TSTU0000082+42G1+++5'"
    "LOC+147+0020192::5'LOC+9+HNPCR:139:6'LOC+11+GTSTC:139:6'"
    "MEA+AAE+VGM+KGM:10000'EQD+CN+TSTU0000098+42G1+++5'"
    "LOC+147+0020102::5'LOC+9+HNPCR:139:6'LOC+11+GTSTC:139:6'"
    "EQD+CN+TSTU0000033+22G1+++4'"
    "LOC+147+0020104::5'LOC+9+HNPCR:139:6'LOC+11+GTSTC:139:6'"
    "MEA+AAE+VGM+KGM:24000'EQD+CN+TSTU0000101+22G1+++5'"
    "LOC+147+0020106::5'LOC+9+HNPCR:139:6'LOC+11+USHOU:139:6'"
    "MEA+AAE+VGM+KGM:23000'EQD+CN+TSTU0000117+22G1+++5'"
    "LOC+147+0020108::5'LOC+9+HNPCR:139:6'LOC+11+GTSTC:139:6'"
    "MEA+AAE+VGM+KGM:22000'EQD+CN+TSTU0000122+22G1+++5'"
    "LOC+147+0020110::5'LOC+9+HNPCR:139:6'LOC+11+GTSTC:139:6'"
    "MEA+AAE+VGM+KGM:21000'EQD+CN+TSTU0000138+22G1+++5'"
    "LOC+147+0020112::5'LOC+9+HNPCR:139:6'LOC+11+USHOU:139:6'"
    "MEA+AAE+VGM+KGM:20000'EQD+CN+TSTU0000143+22G1+++5'"
    "LOC+147+0060182::5'LOC+9+HNPCR:139:6'LOC+11+PAMIT:139:6'"
    "MEA+AAE+VGM+KGM:18000'EQD+CN+TSTU0000044+42G1+++5'"
    "LOC+147+0060284::5'LOC+9+HNPCR:139:6'LOC+11+GTSTC:139:6'"
    "MEA+AAE+VGM+KGM:19000'EQD+CN+TSTU0000055+45G1+++5'";

final _leido = BaplieParserService().parse(t117Texto);

/// Publicado con la escala GTSTC: hay operación (Descarga y Carga).
final t117ConEscala = _leido.withGeometry(
    VesselProfile.proposeFrom(_leido).geometry.copyWith(portRows: 4, starboardRows: 4),
    portOfCall: 'GTSTC');

/// Publicado sin escala: sin operación ni tarjetas.
final t117SinEscala = _leido.withGeometry(
    VesselProfile.proposeFrom(_leido).geometry.copyWith(portRows: 4, starboardRows: 4));

class _Viaje extends VoyageNotifier {
  _Viaje(this.voyage);
  final VesselVoyage voyage;
  @override
  AsyncValue<VesselVoyage?> build() => AsyncData(voyage);
}

/// El almacén del equipo en memoria: solo las preferencias de la oficina y
/// la barra de T-91, que la página ya leía.
class T117Equipo implements LocalVesselRepository {
  T117Equipo([Map<UiPreference, String>? inicial])
      : guardadas = <UiPreference, String>{...?inicial};

  final Map<UiPreference, String> guardadas;

  @override
  Future<Either<Failure, String?>> getUiPreference(UiPreference key) async =>
      Right(guardadas[key]);

  @override
  Future<Either<Failure, void>> setUiPreference(
      UiPreference key, String? value) async {
    if (value == null) {
      guardadas.remove(key);
    } else {
      guardadas[key] = value;
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, bool>> getPlanToolbarCollapsed() async =>
      const Right(true);

  @override
  Future<Either<Failure, AppThemePreference>> getThemePreference() async =>
      const Right(AppThemePreference.system);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

var _fuentesCargadas = false;

/// Las fuentes del producto (Plex, Roboto y los íconos): las medidas de la
/// oficina son las de verdad, no las de la fuente cuadrada de las pruebas.
Future<void> t117CargarFuentes() async {
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

/// La página del viaje en la oficina, con el tema de la oficina, la bahía 002
/// a la vista y el modo pedido.
Future<ProviderContainer> t117Pump(
  WidgetTester tester, {
  Size tamano = const Size(1920, 1000),
  double letra = 1.0,
  T117Equipo? equipo,
  BayPlanMode modo = BayPlanMode.content,
  VesselVoyage? voyage,
  bool oscuro = false,
}) async {
  await t117CargarFuentes();
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = tamano;
  addTearDown(tester.view.reset);
  if (letra != 1.0) {
    tester.platformDispatcher.textScaleFactorTestValue = letra;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }
  final scope = ProviderContainer(overrides: [
    voyageNotifierProvider.overrideWith(() => _Viaje(voyage ?? t117ConEscala)),
    localVesselRepositoryProvider
        .overrideWith((ref) async => equipo ?? T117Equipo()),
    vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
    movementLogRepositoryProvider.overrideWith((ref) async => T74MemoryLog()),
    sessionRepositoryProvider
        .overrideWith((ref) async => const LocalSessionRepository()),
  ]);
  addTearDown(scope.dispose);
  scope.read(selectedBayProvider.notifier).select(2);
  scope.read(bayPlanModeProvider.notifier).elegir(modo);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: scope,
    child: MaterialApp(
      theme: BayStreamTema.claro(),
      darkTheme: BayStreamTema.oscuro(),
      themeMode: oscuro ? ThemeMode.dark : ThemeMode.light,
      home: const VesselOverviewPage(),
    ),
  ));
  await tester.pumpAndSettle();
  return scope;
}

/// Los textos cortados con elipsis o por líneas dentro de [donde].
List<String> t117TextosCortados(WidgetTester tester, Finder donde) {
  final cortados = <String>[];
  for (final elemento in donde.evaluate()) {
    void visitar(RenderObject r) {
      // Las variantes que no se ven (`BsPrimeraQueCabe`) no tienen tamaño.
      if (r is RenderBox && r.hasSize && r.size.isEmpty) return;
      if (r is RenderParagraph && r.didExceedMaxLines) {
        cortados.add(r.text.toPlainText());
      }
      r.visitChildren(visitar);
    }

    final raiz = elemento.renderObject;
    if (raiz != null) visitar(raiz);
  }
  return cortados;
}
