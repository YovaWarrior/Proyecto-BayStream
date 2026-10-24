// T-114 · Candidata del piloto (SPRINT-4.md 10.28): las pantallas que
// todavía no se rediseñaron funcionan con el tema nuevo. Cada una se dibuja a
// 360 × 800 con la letra a 1.0 y a 2.0 (el muelle, de día) y a 1920 × 1080 de
// noche (la oficina) sin lanzar nada (un desborde es una excepción), con las
// fuentes del producto; y los chips seleccionados se leen en los dos temas:
// `FilterChip` no usa `secondaryLabelStyle` y de noche quedaba tinta sobre
// tinta («Solo con cambios» en la comparación, los filtros por naviera de la
// Lista).
//
// Un plano de llegada sintético: BUQUE MANUAL, viaje V114, con refrigerados,
// carga peligrosa, vacíos y 20 pies, para que las pantallas tengan qué mostrar.
import 'package:baystream/core/design/design.dart';
import 'package:baystream/features/vessel/data/repositories/local_only_operation_sync.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/pages/change_requests_page.dart';
import 'package:baystream/features/vessel/presentation/pages/cloud_page.dart';
import 'package:baystream/features/vessel/presentation/pages/departure_baplie_page.dart';
import 'package:baystream/features/vessel/presentation/pages/discharge_sequence_page.dart';
import 'package:baystream/features/vessel/presentation/pages/export_list_import_page.dart';
import 'package:baystream/features/vessel/presentation/pages/hatch_covers_page.dart';
import 'package:baystream/features/vessel/presentation/pages/operation_progress_page.dart';
import 'package:baystream/features/vessel/presentation/pages/parameters_page.dart';
import 'package:baystream/features/vessel/presentation/pages/privacy_policy_page.dart';
import 'package:baystream/features/vessel/presentation/pages/recent_voyages_page.dart';
import 'package:baystream/features/vessel/presentation/pages/segregation_page.dart';
import 'package:baystream/features/vessel/presentation/pages/stowage_alerts_page.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_geometry_page.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_overview_page.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_profiles_page.dart';
import 'package:baystream/features/vessel/presentation/pages/voyage_comparison_page.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/hatch_operation_controls.dart';
import 'package:baystream/features/vessel/presentation/widgets/navegacion_del_viaje.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/local_profile_test_support.dart';
import 'support/t74_movement_log_support.dart';

/// Un plano de llegada sintético (SMDG22): bahías 02, 06 y 10, filas 00 a 05,
/// niveles 02 a 12 y 82 a 92 (216 contenedores); a GTSTC, USHOU y PAMIT.
String _llegada() {
  final b = StringBuffer("UNH+1+BAPLIE:D:95B:UN:SMDG22'"
      "TDT+20+V114+++TST:172:20+++9000114:146:11:BUQUE MANUAL'"
      "LOC+5+HNPCR:139:6'LOC+61+GTSTC:139:6'");
  var n = 0;
  for (final bahia in [2, 6, 10]) {
    for (final fila in [0, 1, 2, 3, 4, 5]) {
      for (final nivel in [2, 4, 6, 8, 10, 12, 82, 84, 86, 88, 90, 92]) {
        n++;
        final pos = '${bahia.toString().padLeft(3, '0')}'
            '${fila.toString().padLeft(2, '0')}${nivel.toString().padLeft(2, '0')}';
        final pod = switch (n % 4) { 0 => 'USHOU', 2 => 'PAMIT', _ => 'GTSTC' };
        final tipo = n % 7 == 0 ? '22G1' : n % 13 == 0 ? '45R1' : '42G1';
        final estado = n % 11 == 0 ? '4' : '5';
        b.write("LOC+147+$pos::5'LOC+9+HNPCR:139:6'LOC+11+$pod:139:6'"
            "MEA+AAE+VGM+KGM:${14000 + n * 37}'"
            "EQD+CN+TSTU${n.toString().padLeft(7, '0')}+$tipo+++$estado'");
        if (n % 13 == 0) b.write("TMP+2+-18:CEL'");
        if (n % 17 == 0) b.write("DGS+IMD+3+1203'");
      }
    }
  }
  return b.toString();
}

class _Replay extends VoyageNotifier {
  @override
  Future<LoadFileResult> loadVesselFromFile() =>
      parseBaplieContent(_llegada(), fileName: 'LLEGADA_SINTETICA.edi');
}

var _fuentesCargadas = false;

/// Las fuentes del producto (Plex, Roboto y los íconos), para que las medidas
/// sean las reales y no las de la fuente cuadrada de las pruebas.
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

typedef _Config = ({String nombre, Size ventana, bool muelle, bool oscuro, double letra});

const _configs = <_Config>[
  (nombre: '360 × 800, claro, letra 1.0', ventana: Size(360, 800), muelle: true, oscuro: false, letra: 1.0),
  (nombre: '360 × 800, claro, letra 2.0', ventana: Size(360, 800), muelle: true, oscuro: false, letra: 2.0),
  (nombre: '1920 × 1080, oscuro, letra 1.0', ventana: Size(1920, 1080), muelle: false, oscuro: true, letra: 1.0),
];

/// El contraste WCAG entre dos colores opacos.
double _contraste(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final claro = la > lb ? la : lb;
  final oscuro = la > lb ? lb : la;
  return (claro + 0.05) / (oscuro + 0.05);
}

void main() {
  group('las pantallas sin rediseñar con el tema nuevo', () {
    for (final config in _configs) {
      testWidgets('a ${config.nombre}: ninguna lanza al dibujarse', (tester) async {
        // Todo dentro de runAsync: el almacén está en disco y las páginas lo
        // leen al dibujarse; así las esperas reales terminan.
        await tester.runAsync(() async {
          await _cargarFuentes();
          final store = await testProfileStore();
          final container = ProviderContainer(overrides: [
            movementLogRepositoryProvider.overrideWith((ref) async => T74MemoryLog()),
            vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
            localVesselRepositoryProvider.overrideWith((ref) async => store.repository),
            voyageNotifierProvider.overrideWith(_Replay.new),
            sessionRepositoryProvider
                .overrideWith((ref) async => const LocalSessionRepository()),
          ]);
          try {
            final n = container.read(voyageNotifierProvider.notifier);
            final leido =
                await n.parseBaplieContent(_llegada(), fileName: 'LLEGADA_SINTETICA.edi');
            expect(leido.preview, isTrue, reason: leido.errorMessage);
            final geometria =
                n.currentProfile!.geometry.copyWith(stackWeightLimitKg: 90000);
            expect(
                await n.confirmGeometry(geometria,
                    portOfCall: 'GTSTC', sourceKind: OperationSourceKind.arrivalBaplie),
                isNull);
            final voyage = n.publishedVoyage!;
            final otro = voyage.copyWith(
                containers: voyage.containers.skip(1).toList(), voyageNumber: 'V115');
            final paginas = <String, Widget Function()>{
              'Parámetros': () => ParametersPage(onVesselParameters: () {}),
              'Parámetros del buque': () => VesselGeometryPage(
                    proposal: VesselProfile.proposeFrom(voyage).geometry,
                    positions: voyage.stowagePositions.toList(),
                    loadingPorts: voyage.loadingPortCounts,
                    voyage: voyage,
                    declaredPort: voyage.portOfOrigin,
                    initialPortOfCall: voyage.portOfCall,
                    initial: geometria,
                    profile: n.currentProfile,
                    fileName: 'LLEGADA_SINTETICA.edi',
                  ),
              'Perfiles guardados': () => const VesselProfilesPage(),
              'Viajes recientes': () => const RecentVoyagesPage(),
              'Alertas de estiba': () => const StowageAlertsPage(),
              'Matriz de segregación': () => const SegregationPage(),
              'Tapas por bahía': () => HatchCoversPage(
                  geometry: geometria, holdBays: voyage.bays.keys.toSet(), initial: const {}),
              'Tapas en la operación': () => HatchOperationPage(voyage: voyage),
              'Orden de descarga': () => DischargeSequencePage(voyage: voyage),
              'Listado de la agencia': () => const ExportListImportPage(),
              'Comparar': () => VoyageComparisonPage(
                  first: voyage,
                  second: otro,
                  firstLabel: 'Llegada: LLEGADA_SINTETICA.edi',
                  secondLabel: 'Salida generada, sin guardar'),
              'Bandeja de cambios': () => ChangeRequestsPage(voyage: voyage),
              'BAPLIE de salida': () => DepartureBapliePage(voyage: voyage),
              'Avance': () => OperationProgressPage(voyage: voyage),
              'Privacidad': () => const PrivacyPolicyPage(),
              'Nube y cuenta': () => const CloudPage(),
              'Lista': () => const VesselOverviewPage(),
              'Estadísticas': () => const VesselOverviewPage(),
              'Búsqueda': () => const VesselOverviewPage(),
            };
            tester.view.devicePixelRatio = 1;
            tester.view.physicalSize = config.ventana;
            tester.platformDispatcher.textScaleFactorTestValue = config.letra;
            tester.platformDispatcher.accessibilityFeaturesTestValue =
                const FakeAccessibilityFeatures(disableAnimations: true);
            final tema = config.oscuro
                ? BayStreamTema.oscuro(muelle: config.muelle)
                : BayStreamTema.claro(muelle: config.muelle);
            final fallos = <String>[];
            for (final entrada in paginas.entries) {
              await tester.pumpWidget(const SizedBox());
              await tester.pump();
              container.read(destinoDelViajeProvider.notifier).ir(switch (entrada.key) {
                'Lista' => DestinoDelViaje.lista,
                'Estadísticas' => DestinoDelViaje.estadisticas,
                _ => DestinoDelViaje.plano,
              });
              await tester.pumpWidget(UncontrolledProviderScope(
                container: container,
                child: MaterialApp(theme: tema, home: entrada.value()),
              ));
              try {
                await tester.pumpAndSettle(const Duration(milliseconds: 100),
                    EnginePhase.sendSemanticsUpdate, const Duration(seconds: 20));
              } on FlutterError catch (e) {
                fallos.add('${entrada.key}: no se asienta (${e.message.split('\n').first})');
              }
              if (entrada.key == 'Búsqueda') {
                await tester.tap(find.byKey(const ValueKey('buscar-contenedor')));
                await tester.pumpAndSettle();
                await tester.enterText(find.byType(TextField).first, 'TSTU00000');
                await tester.pumpAndSettle();
              }
              expect(find.byType(CircularProgressIndicator), findsNothing,
                  reason: '${entrada.key} se quedó cargando');
              final lanzada = tester.takeException();
              if (lanzada != null) {
                fallos.add('${entrada.key}: ${lanzada.toString().split('\n').first}');
              }
              while (tester.takeException() != null) {}
            }
            await tester.pumpWidget(const SizedBox());
            await tester.pump();
            expect(fallos, isEmpty);
          } finally {
            tester.view.reset();
            tester.platformDispatcher.clearTextScaleFactorTestValue();
            tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
            container.dispose();
            await store.repository.close();
            await store.directory.delete(recursive: true);
          }
        });
      });
    }

    testWidgets('la comparación de noche pasa la pauta de contraste del texto',
        (tester) async {
      final primero = BaplieParserService().parse(_llegada());
      final segundo = primero.copyWith(
          containers: primero.containers.skip(1).toList(), voyageNumber: 'V115');
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1920, 1080);
      addTearDown(tester.view.reset);
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(MaterialApp(
        theme: BayStreamTema.oscuro(),
        home: VoyageComparisonPage(
            first: primero,
            second: segundo,
            firstLabel: 'Llegada: sintetica.edi',
            secondLabel: 'Salida generada, sin guardar'),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Solo con cambios'), findsOneWidget);
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });
  });

  group('los chips seleccionados se leen en los dos temas', () {
    for (final (nombre, tema) in [
      ('de día', BayStreamTema.claro()),
      ('de noche', BayStreamTema.oscuro()),
      ('de día, muelle', BayStreamTema.claro(muelle: true)),
      ('de noche, muelle', BayStreamTema.oscuro(muelle: true)),
    ]) {
      testWidgets('$nombre: FilterChip, ChoiceChip e InputChip a 4.5:1 sobre su relleno',
          (tester) async {
        await tester.pumpWidget(MaterialApp(
          theme: tema,
          home: Scaffold(
            body: Wrap(children: [
              FilterChip(
                  label: const Text('Solo con cambios'),
                  selected: true,
                  onSelected: (_) {}),
              FilterChip(
                  label: const Text('Todas (977)'),
                  selected: false,
                  onSelected: (_) {}),
              ChoiceChip(
                  label: const Text('Llegada'), selected: true, onSelected: (_) {}),
              InputChip(
                  label: const Text('014-01-82'), selected: true, onSelected: (_) {}),
            ]),
          ),
        ));
        await tester.pumpAndSettle();
        for (final rotulo in ['Solo con cambios', 'Todas (977)', 'Llegada', '014-01-82']) {
          final contexto = tester.element(find.text(rotulo));
          final texto = DefaultTextStyle.of(contexto).style.color!;
          final chip = find.ancestor(of: find.text(rotulo), matching: find.byType(RawChip));
          final seleccionado = tester.widget<RawChip>(chip).selected;
          final esquema = tema.colorScheme;
          final relleno = seleccionado
              ? tema.chipTheme.selectedColor!
              : tema.chipTheme.backgroundColor ?? esquema.surface;
          final rellenoOpaco = Color.alphaBlend(relleno, esquema.surface);
          final textoOpaco = Color.alphaBlend(texto, rellenoOpaco);
          expect(_contraste(textoOpaco, rellenoOpaco), greaterThanOrEqualTo(4.5),
              reason: '$rotulo ($nombre): texto $textoOpaco sobre $rellenoOpaco');
        }
        expect(tester.takeException(), isNull);
      });
    }
  });
}
