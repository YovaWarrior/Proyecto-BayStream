// T-114 · Fase 3, entrega 2: el plano por bahía en la dirección C «Puente de
// mando» (SPRINT-4.md 10.16; DESIGN.md 8, 13.2, 13.3 y 13.8): la navegación
// adaptable, «Más» con su contador, la silueta como selector, las tarjetas
// con la operación real, «Colorear por», la regla del naranja, el detalle en
// el panel o en la hoja, la banda del muelle y lo que 10.8 dejó pendiente
// (el selector de modo y el código de cinco letras enteros a 2.0, la acción
// de la banda que baja de línea).
//
// Buque y números sintéticos (BUQUE MANUAL, TSTU); sin nube ni almacén real.
import 'package:baystream/core/design/design.dart';
import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/data/repositories/local_only_operation_sync.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/entities/stowage_validation_result.dart';
import 'package:baystream/features/vessel/presentation/pages/operation_progress_page.dart';
import 'package:baystream/features/vessel/presentation/pages/stowage_alerts_page.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_overview_page.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/plano_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/stowage_validation_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/bay_plan_view.dart';
import 'package:baystream/features/vessel/presentation/widgets/loading_plan_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/local_profile_test_support.dart';
import 'support/t74_movement_log_support.dart';
import 'support/t91_toolbar_support.dart';

/// Un plano de llegada a GTSTC: en la bahía 002, dos llenos (a GTSTC y a
/// USHOU) y un vacío; en la 006, un lleno a PAMIT.
const _texto = "UNH+1+BAPLIE:D:95B:UN:SMDG22'"
    "TDT+20+V114+++TST:172:20+++9000114:146:11:BUQUE MANUAL'"
    "LOC+5+HNPCR:139:6'LOC+61+GTSTC:139:6'"
    "LOC+147+0020182::5'LOC+9+HNPCR:139:6'LOC+11+GTSTC:139:6'"
    "MEA+AAE+VGM+KGM:20000'EQD+CN+TSTU0000011+42G1+++5'"
    "LOC+147+0020184::5'LOC+9+HNPCR:139:6'LOC+11+USHOU:139:6'"
    "MEA+AAE+VGM+KGM:21000'EQD+CN+TSTU0000022+42G1+++5'"
    "LOC+147+0020102::5'LOC+9+HNPCR:139:6'LOC+11+GTSTC:139:6'"
    "EQD+CN+TSTU0000033+22G1+++4'"
    "LOC+147+0060182::5'LOC+9+HNPCR:139:6'LOC+11+PAMIT:139:6'"
    "MEA+AAE+VGM+KGM:18000'EQD+CN+TSTU0000044+42G1+++5'";

final _leido = BaplieParserService().parse(_texto);
final _geometria = VesselProfile.proposeFrom(_leido)
    .geometry
    .copyWith(portRows: 4, starboardRows: 4);

/// Publicado con la escala GTSTC: hay operación (descarga) y «Avance».
final _conEscala = _leido.withGeometry(_geometria, portOfCall: 'GTSTC');

/// Publicado sin escala: no hay operación, no hay tarjetas ni «Avance».
final _sinEscala = _leido.withGeometry(_geometria);

class _Viaje extends VoyageNotifier {
  _Viaje(this.voyage);
  final VesselVoyage voyage;
  @override
  AsyncValue<VesselVoyage?> build() => AsyncData(voyage);
}

StowageValidationResult _alerta(ValidationSeverity severidad) =>
    StowageValidationResult(
      rule: StowageRule.values.first,
      status: ValidationStatus.nonConforming,
      severity: severidad,
      description: 'Alerta sintética',
      positions: <IsoCoordinate>[],
      containerIds: const <String>['TSTU0000011'],
    );

var _fuentesCargadas = false;

/// Las fuentes del producto (Plex y Roboto), para que las medidas de 360 dp
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
  };
  for (final entrada in familias.entries) {
    final cargador = FontLoader(entrada.key);
    for (final ruta in entrada.value) {
      cargador.addFont(rootBundle.load(ruta));
    }
    await cargador.load();
  }
}

/// La página completa con el tema del producto, sin nube ni almacén real.
Future<ProviderContainer> _pump(
  WidgetTester tester, {
  Size tamano = const Size(1300, 900),
  bool muelle = false,
  double letra = 1.0,
  VesselVoyage? voyage,
  List<StowageValidationResult>? alertas,
}) async {
  await _cargarFuentes();
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = tamano;
  addTearDown(tester.view.reset);
  if (letra != 1.0) {
    tester.platformDispatcher.textScaleFactorTestValue = letra;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }
  final scope = ProviderContainer(overrides: [
    voyageNotifierProvider.overrideWith(() => _Viaje(voyage ?? _conEscala)),
    localVesselRepositoryProvider.overrideWith((ref) async => T91MemorySettings()),
    vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
    movementLogRepositoryProvider.overrideWith((ref) async => T74MemoryLog()),
    sessionRepositoryProvider
        .overrideWith((ref) async => const LocalSessionRepository()),
    if (alertas != null)
      stowageValidationResultsProvider.overrideWith((ref) => alertas),
  ]);
  addTearDown(scope.dispose);
  // Los 40 de la 002 dejan sombra en la 001 y la 003: la bahía con carga es
  // la 002, y es la que se mira.
  scope.read(selectedBayProvider.notifier).select(2);
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

BsCelda _celda(WidgetTester tester, String clave) => tester.widget<BsCelda>(
    find.descendant(
        of: find.byKey(ValueKey(clave)),
        matching: find.byType(BsCelda),
        matchRoot: true));

void main() {
  final riel = find.byKey(const ValueKey('riel-del-viaje'));
  final barra = find.byKey(const ValueKey('barra-del-viaje'));
  final panel = find.byKey(const ValueKey('panel-lateral'));

  group('navegación adaptable (DESIGN.md 8)', () {
    testWidgets('1300 dp: riel, cabecera y panel; 800: solo el riel; 360: la barra',
        (tester) async {
      await _pump(tester);
      expect(riel, findsOneWidget);
      expect(find.byKey(const ValueKey('cabecera-de-oficina')), findsOneWidget);
      expect(panel, findsOneWidget);
      expect(find.byKey(const ValueKey('en-vivo')), findsOneWidget);
      expect(barra, findsNothing);
      expect(find.byType(AppBar), findsNothing);
      expect(find.byType(BayPlanView), findsOneWidget);
      // La marca encima del riel.
      expect(find.descendant(of: riel, matching: find.byType(BsMarca)),
          findsOneWidget);
      expect(tester.takeException(), isNull);

      tester.view.physicalSize = const Size(800, 900);
      await tester.pumpAndSettle();
      expect(riel, findsOneWidget);
      expect(panel, findsNothing);
      expect(barra, findsNothing);
      expect(tester.takeException(), isNull);

      tester.view.physicalSize = const Size(360, 800);
      await tester.pumpAndSettle();
      expect(barra, findsOneWidget);
      expect(riel, findsNothing);
      expect(find.byType(AppBar), findsOneWidget);
      // En la barra el destino se escribe «Estad.»; el nombre entero queda
      // en la descripción emergente.
      expect(find.descendant(of: barra, matching: find.text('Estad.')),
          findsOneWidget);
      expect(find.byTooltip('Estadísticas'), findsOneWidget);
      expect(find.byKey(const ValueKey('destino-avance')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('sin escala no hay «Avance»; con escala abre embebido en el riel',
        (tester) async {
      await _pump(tester, voyage: _sinEscala);
      expect(find.descendant(of: riel, matching: find.text('Avance')),
          findsNothing);
      await tester.pumpWidget(const SizedBox());
      await _pump(tester);
      await tester.tap(find.descendant(of: riel, matching: find.text('Avance')));
      await tester.pumpAndSettle();
      expect(find.byType(OperationProgressBody), findsOneWidget);
      expect(find.byType(OperationProgressPage), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('«Más»: las alertas primero y el contador en error si alguna es crítica',
        (tester) async {
      final scope = await _pump(tester,
          tamano: const Size(360, 800),
          alertas: [
            _alerta(ValidationSeverity.warning),
            _alerta(ValidationSeverity.error),
          ]);
      expect(scope.read(cuentaDeAlertasProvider), 2);
      expect(scope.read(alertaCriticaProvider), isTrue);
      final contador = find.byKey(const ValueKey('contador-de-alertas'));
      expect(contador, findsOneWidget);
      expect(find.descendant(of: contador, matching: find.text('2')),
          findsOneWidget);
      expect(tester.widget<Badge>(contador).backgroundColor,
          BsColoresSemanticos.claro().error.contorno,
          reason: 'nunca en grúa (13.3, punto 6)');
      await tester.tap(find.byKey(const ValueKey('destino-mas')));
      await tester.pumpAndSettle();
      final hoja = find.byKey(const ValueKey('hoja-mas'));
      expect(hoja, findsOneWidget);
      final primera = tester
          .widgetList<ListTile>(
              find.descendant(of: hoja, matching: find.byType(ListTile)))
          .first;
      expect(primera.key, const ValueKey('mas-alertas'));
      await tester.tap(find.byKey(const ValueKey('mas-alertas')));
      await tester.pumpAndSettle();
      expect(find.byType(StowageAlertsPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('solo avisos: el contador va en aviso', (tester) async {
      await _pump(tester,
          tamano: const Size(360, 800),
          alertas: [_alerta(ValidationSeverity.warning)]);
      final contador = find.byKey(const ValueKey('contador-de-alertas'));
      expect(tester.widget<Badge>(contador).backgroundColor,
          BsColoresSemanticos.claro().revisar.contorno);
    });

    testWidgets('ningún contador hereda la grúa: el tema pone los Badge en aviso',
        (tester) async {
      // El BadgeThemeData global y, con él, el contador de «Acciones» de la
      // línea compacta del plano (13.3, punto 6).
      for (final (tema, semanticos) in [
        (BayStreamTema.claro(), BsColoresSemanticos.claro()),
        (BayStreamTema.oscuro(), BsColoresSemanticos.oscuro()),
      ]) {
        final paleta = BsPaleta.de(tema.brightness);
        expect(tema.badgeTheme.backgroundColor, semanticos.revisar.contorno);
        expect(tema.badgeTheme.textColor, semanticos.revisar.relleno);
        expect(tema.badgeTheme.backgroundColor, isNot(paleta.grua));
        expect(tema.badgeTheme.backgroundColor, isNot(paleta.gruaRelleno));
        await tester.pumpWidget(MaterialApp(
          theme: tema,
          home: const Scaffold(
            body: Center(
              child: Badge(
                key: ValueKey('contador'),
                label: Text('3'),
                child: Icon(Icons.more_vert),
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();
        // El Badge dibuja un círculo con el color del tema.
        final pintado = tester.widget<DecoratedBox>(find
            .descendant(
                of: find.byKey(const ValueKey('contador')),
                matching: find.byType(DecoratedBox))
            .first);
        expect((pintado.decoration as ShapeDecoration).color,
            semanticos.revisar.contorno);
      }
    });
  });

  group('el plano (DESIGN.md 13.2 y 13.8)', () {
    testWidgets('la silueta elige la bahía y la rejilla la titula', (tester) async {
      final scope = await _pump(tester);
      expect(find.byKey(const ValueKey('silueta-del-viaje')), findsOneWidget);
      expect(find.byKey(const ValueKey('bay-selector')), findsOneWidget);
      expect(find.textContaining(RegExp(r'^Bahía 02')), findsOneWidget);
      expect(find.byKey(const ValueKey('cell-1-82')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('silueta-bahia-6')));
      await tester.pumpAndSettle();
      expect(scope.read(selectedBayProvider), 6);
      expect(find.textContaining(RegExp(r'^Bahía 06')), findsOneWidget);
      expect(_celda(tester, 'cell-1-82').codigo, 'PAMIT');
      expect(tester.takeException(), isNull);
    });

    testWidgets('las tarjetas salen de la operación; sin escala no hay tarjetas',
        (tester) async {
      // Con 1600 dp el plano tiene sitio para las tarjetas junto a la silueta.
      await _pump(tester, tamano: const Size(1600, 900));
      expect(find.byKey(const ValueKey('cifra-descarga')), findsOneWidget);
      expect(find.byKey(const ValueKey('cifra-por-bajar')), findsOneWidget);
      expect(find.byKey(const ValueKey('cifra-alertas')), findsNothing);
      expect(find.byKey(const ValueKey('linea-de-tapa')), findsOneWidget);
      expect(find.byType(BsCascoBodega), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await _pump(tester, tamano: const Size(1600, 900), voyage: _sinEscala);
      expect(find.byType(BsTarjetaCifra), findsNothing);
      expect(find.byKey(const ValueKey('en-vivo')), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Colorear por: destino con la ficha del puerto, tipo solo los vacíos, estado sin ficha',
        (tester) async {
      final scope = await _pump(tester);
      final semanticos = BsColoresSemanticos.claro();
      expect(colorearPorOmision(BayPlanMode.content), ColorearPor.destino);
      expect(_celda(tester, 'cell-1-82').codigo, 'GTSTC');
      expect(_celda(tester, 'cell-1-82').categoria?.relleno,
          semanticos.categorico('GTSTC').relleno);
      expect(_celda(tester, 'cell-1-84').codigo, 'USHOU');
      expect(_celda(tester, 'cell-1-82').linea2, '20.0');

      scope
          .read(colorearPorProvider.notifier)
          .elegir(BayPlanMode.content, ColorearPor.tipo);
      await tester.pumpAndSettle();
      expect(_celda(tester, 'cell-1-82').codigo, '42G1');
      expect(_celda(tester, 'cell-1-82').categoria, isNull,
          reason: 'los llenos en papel');
      expect(_celda(tester, 'cell-1-2').codigo, '22G1');
      expect(_celda(tester, 'cell-1-2').categoria?.relleno,
          semanticos.categorico('22G1').relleno);

      scope
          .read(colorearPorProvider.notifier)
          .elegir(BayPlanMode.content, ColorearPor.estado);
      await tester.pumpAndSettle();
      expect(_celda(tester, 'cell-1-82').categoria, isNull);
      expect(_celda(tester, 'cell-1-82').estado, BsEstadoDeCelda.ninguno);
      // El de paso (va a USHOU) se apaga en la vista Estado.
      expect(_celda(tester, 'cell-1-84').estado, BsEstadoDeCelda.dePaso);
      expect(
          find.descendant(
              of: find.byKey(const ValueKey('leyenda-del-plano')),
              matching: find.text('Estado')),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('lo recién movido sale en naranja 1.5 s y la silueta destella',
        (tester) async {
      final scope = await _pump(tester);
      scope.read(recienMovidoProvider.notifier).marcar(const RecienMovido(
            containerId: 'TSTU0000011',
            bahia: 2,
            movimientoId: 'm1',
            quien: BsEquipo.muelle,
          ));
      await tester.pump();
      expect(_celda(tester, 'cell-1-82').estado, BsEstadoDeCelda.recienMovido);
      // La vecina va a USHOU: de paso en esta escala (C-5a), no naranja.
      expect(_celda(tester, 'cell-1-84').estado, BsEstadoDeCelda.dePaso);
      expect(
          tester
              .widget<BsSiluetaBuque>(
                  find.byKey(const ValueKey('silueta-del-viaje')))
              .recienMovida,
          2);
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pumpAndSettle();
      expect(_celda(tester, 'cell-1-82').estado, BsEstadoDeCelda.ninguno);
      expect(
          tester
              .widget<BsSiluetaBuque>(
                  find.byKey(const ValueKey('silueta-del-viaje')))
              .recienMovida,
          isNull);
      expect(tester.takeException(), isNull);
    });

    testWidgets('el detalle va al panel con sitio y a una hoja sin él',
        (tester) async {
      await _pump(tester);
      final celda = find.byKey(const ValueKey('cell-1-82'));
      await tester.ensureVisible(celda);
      await tester.tap(celda);
      await tester.pumpAndSettle();
      final detalle = find.byKey(const ValueKey('detalle-contenedor'));
      expect(find.descendant(of: panel, matching: detalle), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);
      expect(find.descendant(of: detalle, matching: find.text('Puerto de descarga')),
          findsOneWidget);
      await tester.tap(find.descendant(of: detalle, matching: find.text('Cerrar')));
      await tester.pumpAndSettle();
      expect(detalle, findsNothing);

      tester.view.physicalSize = const Size(800, 900);
      await tester.pumpAndSettle();
      await tester.ensureVisible(celda);
      await tester.tap(celda);
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(detalle, findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('el muelle y lo pendiente de 10.8', () {
    testWidgets('en el teléfono con escala va la banda de la marca; Descarga / Carga cambian el modo',
        (tester) async {
      final scope = await _pump(tester,
          tamano: const Size(360, 800), muelle: true);
      final banda = find.byKey(const ValueKey('banda-del-muelle'));
      expect(banda, findsOneWidget);
      expect(find.byType(AppBar), findsNothing);
      expect(find.descendant(of: banda, matching: find.byType(BsMarca)),
          findsOneWidget);
      await tester.tap(find.descendant(of: banda, matching: find.text('Carga')));
      await tester.pumpAndSettle();
      expect(scope.read(bayPlanModeProvider), BayPlanMode.loading);
      expect(find.byKey(const ValueKey('barra-de-operacion')), findsOneWidget);
      await tester.tap(find.descendant(of: banda, matching: find.text('Descarga')));
      await tester.pumpAndSettle();
      expect(scope.read(bayPlanModeProvider), BayPlanMode.discharge);
      expect(find.byKey(const ValueKey('barra-de-operacion')), findsOneWidget);
      // En el muelle, la vista Estado escribe la marca: «Baja».
      expect(find.byKey(const ValueKey('discharge-pending')), findsWidgets);
      expect(find.text('Baja'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('el selector de modo se lee entero a 360 dp con la letra a 2.0',
        (tester) async {
      await _pump(tester, tamano: const Size(360, 800), letra: 2.0);
      final selector = find.byKey(const ValueKey('bay-plan-display-mode'));
      expect(selector, findsOneWidget);
      final texto = find
          .descendant(of: selector, matching: find.text('Contenido'))
          .first;
      expect(tester.renderObject<RenderParagraph>(texto).didExceedMaxLines,
          isFalse);
      expect(tester.getRect(selector).right, lessThanOrEqualTo(360));
      expect(tester.takeException(), isNull);
    });

    testWidgets('a 360 × 800 la rejilla cabe debajo de la silueta: no hay '
        'cabecera que desplazar', (tester) async {
      await _pump(tester, tamano: const Size(360, 800), muelle: true);
      expect(find.byKey(const ValueKey('plano-anidado')), findsNothing);
      expect(find.byKey(const ValueKey('bay-selector')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'a 360 × 640 la silueta y los controles se van al desplazar la rejilla, '
        'que gana su alto, y vuelven', (tester) async {
      await _pump(tester, tamano: const Size(360, 640), muelle: true);
      // Fuera de la vista sigue en el árbol: se busca sin saltar lo oculto.
      final selector =
          find.byKey(const ValueKey('bay-selector'), skipOffstage: false);
      final anidado = find.byKey(const ValueKey('plano-anidado'));
      final zoom = find.byKey(const ValueKey('plan-zoom-2'));
      expect(anidado, findsOneWidget);
      final selectorArriba = tester.getRect(selector);
      final altoAntes = tester.getRect(zoom).height;
      expect(selectorArriba.top,
          greaterThanOrEqualTo(tester.getRect(anidado).top));
      final altoDeLaCabecera = selectorArriba.height;
      await tester.drag(zoom, const Offset(0, -400));
      await tester.pumpAndSettle();
      // La cabecera (la silueta compacta) queda por encima del área del plano
      // y la rejilla gana su alto; la banda y la barra inferior no se mueven.
      expect(tester.getRect(selector).bottom,
          lessThanOrEqualTo(tester.getRect(anidado).top + 1));
      expect(tester.getRect(zoom).height,
          greaterThan(altoAntes + altoDeLaCabecera - 1));
      expect(find.byKey(const ValueKey('banda-del-muelle')), findsOneWidget);
      expect(find.byKey(const ValueKey('barra-del-viaje')), findsOneWidget);
      await tester.drag(zoom, const Offset(0, 400));
      await tester.pumpAndSettle();
      expect(tester.getRect(selector).top, closeTo(selectorArriba.top, 1));
      expect(tester.getRect(zoom).height, closeTo(altoAntes, 1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('el código de cinco letras cabe entero a 2.0: la celda se ensancha',
        (tester) async {
      await _pump(tester, tamano: const Size(360, 800), letra: 2.0);
      final celda = find.byKey(const ValueKey('cell-1-82'));
      final codigo = find.descendant(of: celda, matching: find.text('GTSTC'));
      expect(codigo, findsOneWidget);
      expect(tester.renderObject<RenderParagraph>(codigo).didExceedMaxLines,
          isFalse);
      expect(tester.getSize(celda).width, greaterThan(BsMedidas.oficina.anchoCelda));
      expect(tester.takeException(), isNull);
    });

    testWidgets('la acción de la banda baja de línea cuando no cabe', (tester) async {
      await _cargarFuentes();
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 800);
      addTearDown(tester.view.reset);
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      const texto = 'Plano sin confirmar: perfil propuesto desde el archivo.';
      Widget app() => MaterialApp(
            theme: BayStreamTema.claro(),
            home: Scaffold(
              body: Column(children: [
                BsBanda(
                    texto: texto,
                    icono: Icons.info_outline,
                    accion: 'Confirmar',
                    onAccion: () {}),
              ]),
            ),
          );
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      final parrafo = tester.getRect(find.text(texto));
      var boton = tester.getRect(find.text('Confirmar'));
      expect(boton.top, greaterThanOrEqualTo(parrafo.bottom - 1),
          reason: 'apilada: la acción debajo del texto');
      expect(boton.right, lessThanOrEqualTo(360));
      expect(tester.takeException(), isNull);

      tester.platformDispatcher.textScaleFactorTestValue = 1.0;
      tester.view.physicalSize = const Size(1200, 800);
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      final ancho = tester.getRect(find.text(texto));
      boton = tester.getRect(find.text('Confirmar'));
      expect(boton.left, greaterThanOrEqualTo(ancho.right),
          reason: 'con sitio, la acción a la derecha del texto');
      expect(tester.takeException(), isNull);
    });
  });
}
