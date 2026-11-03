// T-114 · El paquete de íconos e ilustraciones (10.19), parte C: los íconos
// del dominio en las pantallas, las insignias de 12 px y las ilustraciones en
// sus seis estados (DESIGN.md 13.11).
//   - el censo: ningún concepto de la tabla del LEEME sigue en Material en
//     lib/ (fuera de los archivos congelados), lo que 13.11 deja en Material a
//     propósito sigue ahí, y cada ícono del paquete con sitio está en uso;
//   - las insignias de BsCelda son los glifos de 12 px;
//   - la regla del ícono de contenedor, las marcas de descarga, el estado de
//     la nube, los segmentos de la banda y el destino «Plano»;
//   - las seis ilustraciones en sus pantallas, con meetsGuideline.
//
// Buques y números sintéticos (BUQUE PRUEBA, INCOMING, FULL); sin nube ni
// almacén real.
import 'dart:io';

import 'package:baystream/core/design/design.dart';
import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/data/repositories/local_only_operation_sync.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/entities/stowage_validation_result.dart';
import 'package:baystream/features/vessel/domain/repositories/operation_sync_repository.dart';
import 'package:baystream/features/vessel/domain/services/discharge_progress.dart';
import 'package:baystream/features/vessel/presentation/pages/cloud_page.dart';
import 'package:baystream/features/vessel/presentation/pages/operation_progress_page.dart';
import 'package:baystream/features/vessel/presentation/pages/stowage_alerts_page.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_operation_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/stowage_validation_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/container_search_delegate.dart';
import 'package:baystream/features/vessel/presentation/widgets/discharge_controls.dart';
import 'package:baystream/features/vessel/presentation/widgets/empty_state_widget.dart';
import 'package:baystream/features/vessel/presentation/widgets/iconos_del_dominio.dart';
import 'package:baystream/features/vessel/presentation/widgets/inicio_view.dart';
import 'package:baystream/features/vessel/presentation/widgets/navegacion_del_viaje.dart';
import 'package:baystream/features/vessel/presentation/widgets/sync_status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/local_profile_test_support.dart';
import 'support/t74_movement_log_support.dart';
import 'support/t75_memory_log.dart';
import 'support/t76_fixture.dart';
import 'support/t91_toolbar_support.dart';

/// Los íconos de Material que la tabla del LEEME reemplaza. `warning_amber`
/// (el aviso genérico), `table_view` (el CSV), `inventory_2` (el total y
/// «Lleno») y `check_box` («Llenos») se quedan a propósito (13.11).
final _reemplazados = RegExp(r'Icons\.(?:'
    r'ac_unit|open_in_full|local_gas_station|view_agenda|open_in_browser|'
    r'directions_boat(?:_outlined)?|view_module|view_column(?:_outlined)?|'
    r'grid_view(?:_outlined)?|layers_outlined|scale_outlined|south|north|'
    r'arrow_upward|swap_vert|inbox_outlined|schedule|upload_file|folder_open|'
    r'compare_arrows|save_alt|cloud_done_outlined|phone_android|'
    r'cloud_off_outlined|check_box_outline_blank|inventory_2_outlined|'
    r'add_box_outlined|warning|search_off'
    r')\b');

/// Los que la sección 13.11 deja en Material junto a los nuevos, ya rellenos.
final _contornosQueSeVan = RegExp(r'Icons\.(?:'
    r'check_circle_outline|error_outline|fact_check_outlined|cloud_outlined|'
    r'cloud_sync_outlined|cloud_upload_outlined|lock_clock_outlined|'
    r'warning_amber_outlined|table_chart_outlined|assignment_outlined|'
    r'palette_outlined|view_week_outlined|list_alt_outlined|'
    r'data_usage_outlined|bar_chart_outlined'
    r')\b');

const _congelados = <String>{
  'lib/latency_test_screen.dart',
  'lib/c3_reconciliation_screen.dart',
  'lib/main.dart',
};

/// Los íconos del paquete con un sitio en la app, según la tabla.
const _conSitio = <String>{
  'contenedor20',
  'contenedor40',
  'contenedor45',
  'vacio',
  'refrigerado',
  'peligrosa',
  'fueraDeMedida',
  'tanque',
  'plataforma',
  'techoAbierto',
  'buque',
  'bahia',
  'tapaEscotilla',
  'pesoPila',
  'vgm',
  'descarga',
  'carga',
  'reestiba',
  'pedirCambio',
  // T-118 (DESIGN.md 13.11 y 14.6): el modo Número de orden del selector.
  'orden',
  'baplie',
  'compararBaplie',
  'baplieSalida',
  'listadoAgencia',
  'alDia',
  'soloAqui',
  'insigniaRefrigerado',
  'insigniaPeligrosa',
  'insigniaFueraDeMedida',
  // T-131 (DESIGN.md 13.12): el distintivo de rol de la cabecera; `muelle`
  // estaba sin sitio hasta aquí y `oficina` llega con el paquete v3.
  'muelle',
  'oficina',
};

/// Los que el LEEME da como «ninguno hoy»: quedan en la fuente sin sitio.
const _sinSitio = <String>{
  'limiteApilamiento',
  'segregacion',
  'grua',
  'escala',
  'insigniaVacio',
};

ContainerUnit _contenedor(String iso,
        {ContainerStatus status = ContainerStatus.full,
        bool peligrosa = false,
        bool refrigerado = false,
        bool fueraDeMedida = false}) =>
    ContainerUnit(
        id: 'uuid-$iso',
        containerId: 'TSTU0000011',
        isoSizeType: iso,
        status: status,
        isDangerous: peligrosa,
        isReefer: refrigerado,
        isOverDimension: fueraDeMedida);

class _Viaje extends VoyageNotifier {
  _Viaje(this.voyage);
  final VesselVoyage voyage;
  @override
  AsyncValue<VesselVoyage?> build() => AsyncData(voyage);
}

Widget _app(Widget hijo, {List overrides = const []}) => ProviderScope(
      overrides: [...overrides],
      child: MaterialApp(
        theme: BayStreamTema.claro(muelle: true),
        home: Scaffold(body: hijo),
      ),
    );

Future<void> _pautas(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(textContrastGuideline));
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
}

BsIlustracion _ilustracion(WidgetTester tester, [Finder? donde]) =>
    tester.widget<BsIlustracion>(donde ?? find.byType(BsIlustracion));

var _fuentesCargadas = false;

/// Las fuentes del producto (Plex y Roboto), para que las medidas del
/// teléfono sean las reales y no las de la fuente cuadrada de las pruebas.
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
    'Roboto': [
      'assets/fonts/Roboto-Regular.ttf',
      'assets/fonts/Roboto-Medium.ttf'
    ],
  };
  for (final entrada in familias.entries) {
    final cargador = FontLoader(entrada.key);
    for (final ruta in entrada.value) {
      cargador.addFont(rootBundle.load(ruta));
    }
    await cargador.load();
  }
}

void main() {
  group('el censo de lib/', () {
    final archivos = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .map((f) =>
            (ruta: f.path.replaceAll('\\', '/'), lineas: f.readAsLinesSync()))
        .where((f) => !_congelados.contains(f.ruta))
        .toList();

    test('ningún concepto de la tabla sigue en Material', () {
      final hallazgos = <String>[];
      final tableView = <String>[];
      for (final archivo in archivos) {
        for (var i = 0; i < archivo.lineas.length; i++) {
          final linea = archivo.lineas[i];
          for (final m in _reemplazados.allMatches(linea)) {
            hallazgos.add('${archivo.ruta}:${i + 1}: ${m.group(0)}');
          }
          if (linea.contains('Icons.table_view')) {
            tableView.add('${archivo.ruta}:${i + 1}');
          }
        }
      }
      expect(hallazgos, isEmpty, reason: hallazgos.join('\n'));
      // El CSV de exportar sigue en table_view, y solo él.
      expect(tableView, hasLength(1), reason: tableView.join('\n'));
      expect(tableView.single, contains('vessel_overview_page.dart'));
      expect(archivos.length, greaterThan(100), reason: 'se leyó lib/ entero');
    });

    test('junto a los íconos nuevos, los genéricos van rellenos', () {
      final hallazgos = <String>[];
      for (final archivo in archivos) {
        for (var i = 0; i < archivo.lineas.length; i++) {
          for (final m in _contornosQueSeVan.allMatches(archivo.lineas[i])) {
            hallazgos.add('${archivo.ruta}:${i + 1}: ${m.group(0)}');
          }
        }
      }
      // BsBanda y el aviso de la barra de la operación no van junto a los
      // íconos nuevos: conservan sus contornos (13.11, regla 2).
      final permitidos = hallazgos.where((h) =>
          h.contains('componentes/bs_banda.dart') ||
          h.contains('componentes/bs_barra_de_operacion.dart') ||
          h.contains('pages/vessel_overview_page.dart') &&
              h.contains('error_outline') ||
          h.contains('pages/export_list_import_page.dart') ||
          h.contains('widgets/loading_controls.dart') &&
              h.contains('check_circle_outline'));
      final sobrantes = hallazgos.toSet().difference(permitidos.toSet());
      expect(sobrantes, isEmpty, reason: sobrantes.join('\n'));
    });

    test('cada ícono del paquete con sitio está en uso, y los sin sitio no',
        () {
      final usados = <String>{};
      final referencia = RegExp(r'BsIconos\.(\w+)');
      for (final archivo in archivos) {
        if (archivo.ruta.endsWith('bs_iconos.dart') ||
            archivo.ruta.endsWith('bs_iconos_catalogo.dart') ||
            archivo.ruta.endsWith('vistas_previas_iconos.dart')) {
          continue;
        }
        for (final linea in archivo.lineas) {
          for (final m in referencia.allMatches(linea)) {
            usados.add(m.group(1)!);
          }
        }
      }
      expect(usados, containsAll(_conSitio),
          reason: 'faltan ${_conSitio.difference(usados)}');
      expect(usados.intersection(_sinSitio), isEmpty,
          reason: 'los sin sitio se usan: ${usados.intersection(_sinSitio)}');
      expect(_conSitio.length + _sinSitio.length, 36);
      expect(BsIconosCatalogo.todos.keys, hasLength(36));
    });
  });

  group('la regla de cada ícono', () {
    test('el contenedor: carga especial, vacío, tipo ISO y tamaño', () {
      expect(iconoDeContenedor(_contenedor('22G1')), BsIconos.contenedor20);
      expect(iconoDeContenedor(_contenedor('42G1')), BsIconos.contenedor40);
      expect(
          iconoDeContenedor(_contenedor('22G1', status: ContainerStatus.empty)),
          BsIconos.vacio);
      expect(iconoDeContenedor(_contenedor('22R1')), BsIconos.refrigerado);
      expect(iconoDeContenedor(_contenedor('22T1')), BsIconos.tanque);
      expect(iconoDeContenedor(_contenedor('22P1')), BsIconos.plataforma);
      expect(iconoDeContenedor(_contenedor('22U1')), BsIconos.techoAbierto);
      expect(iconoDeContenedor(_contenedor('42G1', peligrosa: true)),
          BsIconos.peligrosa);
      expect(iconoDeContenedor(_contenedor('42R1', refrigerado: true)),
          BsIconos.refrigerado);
      expect(iconoDeContenedor(_contenedor('42G1', fueraDeMedida: true)),
          BsIconos.fueraDeMedida);
      expect(iconoDeTamano(45), BsIconos.contenedor45);
      expect(iconoDeTamano(null), BsIconos.contenedor40);
      expect(iconoDeTipo(null, pies: 20), BsIconos.contenedor20);
      expect(iconoDeTipo(ContainerType.bulk, pies: 40), BsIconos.contenedor40);
    });

    test('las marcas de descarga, la nube, la banda y el destino «Plano»', () {
      expect(dischargeMarkIcon(DischargeMark.pending), BsIconos.descarga);
      expect(dischargeMarkIcon(DischargeMark.transit), BsIconos.buque);
      expect(dischargeMarkIcon(DischargeMark.restowed), BsIconos.reestiba);
      expect(dischargeMarkIcon(DischargeMark.discharged), Icons.check_circle);
      expect(syncStatusIcon(const SyncStatus(SyncState.localOnly)),
          BsIconos.soloAqui);
      expect(syncStatusIcon(const SyncStatus(SyncState.offline)),
          BsIconos.soloAqui);
      expect(
          syncStatusIcon(const SyncStatus(SyncState.upToDate)), BsIconos.alDia);
      expect(BsModoDeOperacion.descarga.icono, BsIconos.descarga);
      expect(BsModoDeOperacion.carga.icono, BsIconos.carga);
      expect(DestinoDelViaje.plano.icono, BsIconos.bahia);
      expect(DestinoDelViaje.plano.iconoActivo, BsIconos.bahia);
      for (final destino in DestinoDelViaje.values) {
        expect(destino.icono, destino.iconoActivo, reason: destino.name);
      }
    });

    testWidgets('las insignias de la celda son los glifos de 12 px',
        (tester) async {
      for (final (insignia, icono) in <(BsInsigniaDeCelda, IconData)>[
        (BsInsigniaDeCelda.refrigerado, BsIconos.insigniaRefrigerado),
        (BsInsigniaDeCelda.peligrosa, BsIconos.insigniaPeligrosa),
        (BsInsigniaDeCelda.oog, BsIconos.insigniaFueraDeMedida),
      ]) {
        await tester.pumpWidget(_app(Center(
          child:
              BsCelda(codigo: 'GTSTC', insignia: insignia, etiqueta: 'prueba'),
        )));
        final dibujado = tester.widget<Icon>(find.byIcon(icono));
        expect(dibujado.size, BsCelda.tamanoInsignia, reason: insignia.name);
        expect(dibujado.size, 12);
      }
      await tester.pumpWidget(_app(const Center(
        child: BsCelda(
            codigo: 'GTSTC', marca: BsMarcaDeCelda.paso, etiqueta: 'paso'),
      )));
      expect(find.byIcon(BsIconos.buque), findsOneWidget);
    });
  });

  group('las ilustraciones en sus pantallas', () {
    testWidgets(
        'el inicio lleva la suya y «Seleccionar archivo» el ícono del BAPLIE',
        (tester) async {
      await tester.pumpWidget(_app(SingleChildScrollView(
        child: EmptyStateWidget(
            onPickFile: () {}, ilustracion: BsIlustraciones.inicio),
      )));
      await tester.pumpAndSettle();
      expect(_ilustracion(tester).datos, BsIlustraciones.inicio);
      expect(tester.getSize(find.byType(BsIlustracion)).width,
          lessThanOrEqualTo(480));
      expect(find.byIcon(BsIconos.baplie), findsOneWidget);
      expect(find.text('Seleccionar archivo'), findsOneWidget);
      await _pautas(tester);
      await tester.pumpWidget(_app(EmptyStateWidget(onPickFile: () {})));
      expect(find.byType(BsIlustracion), findsNothing,
          reason: 'sin ilustración, el estado vacío de antes');
    });

    testWidgets(
        '«todavía no hay viajes» en el inicio, con el buque en los recientes',
        (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_app(
        InicioView(onPickFile: () {}, onOpenRecent: (_) {}),
        overrides: [
          recentVoyagesProvider.overrideWith((ref) async => <VesselVoyage>[]),
          savedVesselProfilesProvider
              .overrideWith((ref) async => <VesselProfile>[]),
          localVesselRepositoryProvider
              .overrideWith((ref) async => T91MemorySettings()),
          sessionRepositoryProvider
              .overrideWith((ref) async => const LocalSessionRepository()),
        ],
      ));
      await tester.pumpAndSettle();
      final vacio = find.byKey(const ValueKey('inicio-sin-recientes'));
      expect(vacio, findsOneWidget);
      expect(_ilustracion(tester, vacio).datos, BsIlustraciones.vacioRecientes);
      expect(find.textContaining('Todavía no hay viajes'), findsOneWidget);
      expect(_ilustracion(tester, find.byType(BsIlustracion).first).datos,
          BsIlustraciones.inicio);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'en el teléfono bajo, el inicio deja «Seleccionar archivo» a la vista con la letra grande',
        (tester) async {
      // 13.11, regla 4: a 360 × 640 el dibujo del inicio mide 192 dp con la
      // letra a 1.0 y 132 con 1.45; con 2.0 no se pinta, y el botón sigue en
      // la primera pantalla (lo encontró la captura de Android). También con
      // la ventana del emulador: 360 × 592 bajo una barra de estado de 24.
      await _cargarFuentes();
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      for (final (ventana, barra) in const [
        (Size(360, 640), 0.0),
        (Size(360, 592), 24.0),
      ]) {
        tester.view.physicalSize = ventana;
        tester.view.padding = FakeViewPadding(top: barra);
        for (final letra in const [1.0, 1.45, 2.0]) {
          tester.platformDispatcher.textScaleFactorTestValue = letra;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          await tester.pumpWidget(const SizedBox());
          await tester.pumpWidget(_app(
            InicioView(onPickFile: () {}, onOpenRecent: (_) {}),
            overrides: [
              recentVoyagesProvider
                  .overrideWith((ref) async => <VesselVoyage>[]),
              savedVesselProfilesProvider
                  .overrideWith((ref) async => <VesselProfile>[]),
              localVesselRepositoryProvider
                  .overrideWith((ref) async => T91MemorySettings()),
              sessionRepositoryProvider
                  .overrideWith((ref) async => const LocalSessionRepository()),
            ],
          ));
          await tester.pumpAndSettle();
          final caso = '$ventana, barra $barra, letra $letra';
          final boton = find.text('Seleccionar archivo');
          expect(boton, findsOneWidget, reason: caso);
          expect(
              tester.getRect(boton).bottom, lessThanOrEqualTo(ventana.height),
              reason: '$caso: el botón, sin desplazar');
          final inicio = find.byWidgetPredicate(
              (w) => w is BsIlustracion && w.datos == BsIlustraciones.inicio);
          final presupuesto =
              ventana.height * BsIlustracion.parteDelAlto / letra;
          if (presupuesto < BsIlustracion.altoMinimo) {
            // El inicio no pone el dibujo ni su separación.
            expect(inicio, findsNothing, reason: '$caso: sin dibujo');
          } else {
            expect(inicio, findsOneWidget, reason: caso);
            final alto = tester.getSize(inicio).height;
            expect(alto, closeTo(presupuesto, 0.5), reason: caso);
            expect(alto, greaterThanOrEqualTo(BsIlustracion.altoMinimo),
                reason: caso);
          }
          expect(tester.takeException(), isNull, reason: caso);
        }
      }
    });

    testWidgets('«ningún contenedor coincide» en la búsqueda', (tester) async {
      await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
          theme: BayStreamTema.claro(muelle: true),
          home: Scaffold(
            body: Consumer(builder: (context, ref, _) {
              final delegado = ContainerSearchDelegate(
                containers: <ContainerUnit>[_contenedor('22G1')],
                ref: ref,
              )..query = 'ZZZZ';
              return delegado.buildResults(context);
            }),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('busqueda-sin-resultados')),
          findsOneWidget);
      expect(_ilustracion(tester).datos, BsIlustraciones.vacioBusqueda);
      expect(find.textContaining('Sin resultados'), findsOneWidget);
      await _pautas(tester);
    });

    testWidgets('«trabajando solo en este equipo» en Nube y cuenta',
        (tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [
          sessionRepositoryProvider
              .overrideWith((ref) async => const LocalSessionRepository()),
          operationSyncProvider
              .overrideWith((ref) async => const LocalOnlyOperationSync()),
          movementLogRepositoryProvider
              .overrideWith((ref) async => T75MemoryLog()),
        ],
        child: MaterialApp(
          theme: BayStreamTema.claro(muelle: true),
          home: const CloudPage(),
        ),
      ));
      await tester.pumpAndSettle();
      final sola = find.byKey(const ValueKey('nube-solo-aqui'));
      expect(sola, findsOneWidget);
      expect(_ilustracion(tester, sola).datos, BsIlustraciones.sinConexion);
      await _pautas(tester);
    });

    testWidgets(
        '«descarga completa» en el avance, solo cuando no queda nada por bajar',
        (tester) async {
      Future<void> montar(List<MovementDraft> borradores) async {
        final movimientos = <Movement>[
          for (var i = 0; i < borradores.length; i++)
            t76Movement(borradores[i], i + 1),
        ];
        // Un ProviderScope no cambia sus overrideWith al volver a montarse en
        // el mismo sitio: se desmonta el anterior primero.
        await tester.pumpWidget(const SizedBox());
        await tester.pumpWidget(_app(
          OperationProgressBody(voyage: t76Loading),
          overrides: [
            voyageNotifierProvider.overrideWith(() => _Viaje(t76Loading)),
            localVesselRepositoryProvider
                .overrideWith((ref) async => T91MemorySettings()),
            vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
            sessionRepositoryProvider
                .overrideWith((ref) async => const LocalSessionRepository()),
            movementLogRepositoryProvider
                .overrideWith((ref) async => T74MemoryLog()),
            loadingOperationProvider(t76Loading).overrideWith((ref) async* {
              yield t76Operation(movimientos);
            }),
          ],
        ));
        await tester.pumpAndSettle();
      }

      // Uno de los dos de llegada sigue a bordo: nada que celebrar.
      await montar([MovementDraft.discharge('op', 'INCOMING1', '0030282')]);
      expect(find.byKey(const ValueKey('descarga-completa')), findsNothing);
      // Los dos bajaron: la ilustración y la frase.
      await montar([
        MovementDraft.discharge('op', 'INCOMING1', '0030282'),
        MovementDraft.discharge('op', 'INCOMING2', '0030482'),
      ]);
      final completa = find.byKey(const ValueKey('descarga-completa'));
      expect(completa, findsOneWidget);
      expect(_ilustracion(tester, completa).datos,
          BsIlustraciones.descargaCompleta);
      expect(find.text('Descarga completa en GTSTC.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        '«sin posibles incumplimientos» en las alertas, nunca en previo ni con alertas',
        (tester) async {
      Future<void> montar(List<StowageValidationResult> resultados) async {
        await tester.pumpWidget(ProviderScope(
          overrides: [
            stowageValidationResultsProvider.overrideWithValue(resultados)
          ],
          child: MaterialApp(
            theme: BayStreamTema.claro(muelle: true),
            home: const StowageAlertsPage(),
          ),
        ));
        await tester.pumpAndSettle();
      }

      final conforme = StowageValidationResult(
          rule: StowageRule.values.first,
          status: ValidationStatus.conforming,
          severity: ValidationSeverity.information,
          description: 'Regla evaluada conforme',
          positions: const <IsoCoordinate>[],
          containerIds: const <String>['TSTU0000011']);
      final incumple = StowageValidationResult(
          rule: StowageRule.values.first,
          status: ValidationStatus.nonConforming,
          severity: ValidationSeverity.warning,
          description: 'Alerta sintética',
          positions: const <IsoCoordinate>[],
          containerIds: const <String>['TSTU0000011']);
      await montar([conforme]);
      final sinAlertas =
          find.byKey(const ValueKey('alertas-sin-incumplimientos'));
      expect(sinAlertas, findsOneWidget);
      expect(
          _ilustracion(tester, sinAlertas).datos, BsIlustraciones.sinAlertas);
      expect(find.textContaining('0 posibles incumplimientos'), findsOneWidget);
      await _pautas(tester);
      await montar([conforme, incumple]);
      expect(find.byKey(const ValueKey('alertas-sin-incumplimientos')),
          findsNothing);
      // Solo «no evaluado» o nada evaluado tampoco lo declaran.
      await montar([
        StowageValidationResult(
            rule: StowageRule.values.first,
            status: ValidationStatus.notEvaluated,
            severity: ValidationSeverity.warning,
            description: 'ONU fuera de matriz: no evaluado',
            positions: const <IsoCoordinate>[],
            containerIds: const <String>['TSTU0000011']),
      ]);
      expect(find.byKey(const ValueKey('alertas-sin-incumplimientos')),
          findsNothing);
      await montar(const <StowageValidationResult>[]);
      expect(find.byKey(const ValueKey('alertas-sin-incumplimientos')),
          findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
