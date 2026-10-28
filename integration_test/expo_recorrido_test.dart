// T-126 · La prueba que se ve moverse (SPRINT-4.md 10.70): la 3.2.0 completa,
// sin nube y con datos sintéticos, manejada sola por la prueba.
//
//   flutter test integration_test/expo_recorrido_test.dart -d windows
//   flutter test integration_test/expo_recorrido_test.dart -d windows --dart-define=EXPO_PAUSA_MS=1200
//
// La app es la del producto (BayStreamApp, con sus temas y su página), como en
// los bancos de tool/ (tool/t124_main.dart), con tres cambios y nada más:
// 1. El selector de archivos devuelve el plano de llegada sintético de T-100
//    (expo_escala.dart). Los bytes recorren la entrada real del producto: el
//    botón del inicio, el lector y el previo.
// 2. No hay Firebase: la sesión es la local, la de un solo dispositivo.
// 3. El almacén va en una carpeta nueva de %TEMP%\expo, con namespace «expo»:
//    nunca el almacén real, y cada corrida empieza sin buques guardados.
//
// Los ocho pasos, cada uno comprobado con expect: abrir el plano de llegada,
// confirmar la escala GTSTC, recorrer las bahías 02, 06 y 10, buscar
// MNLU0000200 y verlo resaltado, registrar dos descargas en la 06, deshacer
// una, y mirar el Avance y las Estadísticas.
//
// EXPO_PAUSA_MS es la pausa entre pasos, para que se pueda seguir (0 por
// omisión; la Expo usa unos 1200). EXPO_VENTANA fija el área de la app en
// puntos lógicos («1366x768»), antes del primer cuadro (expo_ventana.dart);
// sin ella queda la ventana del runner (1280 × 720), que no se toca.
import 'dart:convert';
import 'dart:io';

import 'package:baystream/core/app.dart';
import 'package:baystream/core/errors/exceptions.dart';
import 'package:baystream/core/errors/failures.dart';
import 'package:baystream/features/vessel/data/datasources/hive_movement_data_source.dart';
import 'package:baystream/features/vessel/data/datasources/hive_vessel_data_source.dart';
import 'package:baystream/features/vessel/data/repositories/local_only_operation_sync.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_impl.dart';
import 'package:baystream/features/vessel/data/repositories/movement_log_repository_impl.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/vessel_repository.dart';
import 'package:baystream/features/vessel/domain/services/discharge_progress.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_geometry_page.dart';
import 'package:baystream/features/vessel/presentation/providers/discharge_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/plano_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/voyage_ui_state.dart';
import 'package:baystream/features/vessel/presentation/widgets/loading_plan_controls.dart';
import 'package:baystream/features/vessel/presentation/widgets/navegacion_del_viaje.dart';
import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'expo_escala.dart';
import 'expo_ventana.dart';

const _pausaMs = int.fromEnvironment('EXPO_PAUSA_MS');
const _ventana = String.fromEnvironment('EXPO_VENTANA');

/// El namespace del almacén de la Expo: nunca el del producto.
const _namespace = 'expo';

/// El archivo, la escala y los dos contenedores del recorrido. MNLU0000200
/// está en 006-02-82 y MNLU0000196 en 006-01-82: los dos bajan en GTSTC.
const _archivo = 'T100_LLEGADA.edi';
const _escala = 'GTSTC';
const _buscado = 'MNLU0000200';
const _vecino = 'MNLU0000196';
const _bahia = 6;

const _pasos = 8;

void main() {
  // Antes del primer cuadro, con la ventana del runner todavía oculta.
  final medida = _ventana.split('x');
  final pedida = medida.length == 2
      ? fijarVentanaAntesDelPrimerCuadro(
          int.parse(medida[0]), int.parse(medida[1]))
      : null;
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // Cada cuadro que la app pide se dibuja: la Expo ve las animaciones reales.
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('Expo · la 3.2.0 de punta a punta, sin nube', (tester) async {
    // ------------------------------------------------------------ ayudantes
    final reloj = Stopwatch()..start();
    var paso = 0;
    var inicioDelPaso = Duration.zero;

    void anunciar(String que) {
      if (paso > 0) {
        debugPrint('      ok en ${_segundos(reloj.elapsed - inicioDelPaso)}');
      }
      paso++;
      inicioDelPaso = reloj.elapsed;
      debugPrint('EXPO · paso $paso de $_pasos · $que');
    }

    // Deja que la interfaz termine lo que está moviendo, sin esperar más de
    // dos segundos si algo se anima sin fin.
    Future<void> quieta() async {
      final espera = Stopwatch()..start();
      do {
        await tester.pump(const Duration(milliseconds: 16));
      } while (binding.hasScheduledFrame && espera.elapsedMilliseconds < 2000);
    }

    // La pausa entre pasos, para que la sala alcance a leer.
    Future<void> pausa([double factor = 1]) async {
      if (_pausaMs > 0) {
        await Future<void>.delayed(
            Duration(milliseconds: (_pausaMs * factor).round()));
      }
      await quieta();
    }

    Future<void> hastaQue(bool Function() listo, String que,
        {int segundos = 20}) async {
      final espera = Stopwatch()..start();
      while (!listo()) {
        if (espera.elapsed.inSeconds >= segundos) {
          fail('La app no llegó en $segundos s a: $que');
        }
        await tester.pump(const Duration(milliseconds: 50));
      }
      await quieta();
    }

    Future<void> tocar(Finder objetivo) async {
      expect(objetivo, findsWidgets);
      await tester.ensureVisible(objetivo.first);
      await quieta();
      await tester.tap(objetivo.first);
      await tester.pump();
    }

    // ------------------------------------------------------------- ventana
    // El runner de Windows muestra la ventana con el primer cuadro.
    await tester.pumpWidget(const SizedBox.shrink());
    if (pedida != null) {
      for (var i = 0;
          i < 40 &&
              tester.view.physicalSize !=
                  Size(pedida.ancho.toDouble(), pedida.alto.toDouble());
          i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    }
    final logica = tester.view.physicalSize / tester.view.devicePixelRatio;
    debugPrint('EXPO · ventana de ${logica.width.round()} × '
        '${logica.height.round()} puntos (escala ${tester.view.devicePixelRatio})');

    // ------------------------------------------------- el archivo y la app
    // Arrange: el plano sintético, comprobado con el lector real como lo hace
    // tool/t100_sintetico.dart antes de escribirlo.
    final texto = expoLlegada();
    final leido = BaplieParserService().parse(texto);
    expect(leido.totalContainers, 60);
    final cuentas = leido.cargoCountsFor(_escala);
    expect(cuentas.discharged, 30);
    expect(cuentas.transit, 30);
    expect(cuentas.loaded, 0);
    String? celdaDe(String contenedor) => leido.containers
        .firstWhere((c) => c.containerId == contenedor)
        .stowagePosition
        ?.toIsoCode();
    expect(celdaDe(_buscado), '0060282');
    expect(celdaDe(_vecino), '0060182');

    final raiz = Directory('${Directory.systemTemp.path}/expo')
      ..createSync(recursive: true);
    // Lo que dejó una corrida que se cortó antes del cierre.
    for (final vieja in raiz.listSync().whereType<Directory>()) {
      if (!vieja.path.split(RegExp(r'[\\/]')).last.startsWith('almacen-')) {
        continue;
      }
      try {
        vieja.deleteSync(recursive: true);
      } on FileSystemException {
        debugPrint('EXPO · no se pudo borrar ${vieja.path}');
      }
    }
    final carpeta = raiz.createTempSync('almacen-');
    debugPrint('EXPO · almacén «$_namespace» en ${carpeta.path}');
    final local = LocalVesselRepositoryImpl(await HiveVesselDataSource.open(
        directory: carpeta.path, namespace: _namespace));
    final bitacora = MovementLogRepositoryImpl(
        await HiveMovementDataSource.open(
            directory: carpeta.path, namespace: _namespace));
    final estado = ProviderContainer(overrides: [
      vesselRepositoryProvider.overrideWithValue(_SoloLector()),
      localVesselRepositoryProvider.overrideWith((ref) async => local),
      movementLogRepositoryProvider.overrideWith((ref) async => bitacora),
      sessionRepositoryProvider
          .overrideWith((ref) async => const LocalSessionRepository()),
    ]);
    final bytes = Uint8List.fromList(ascii.encode(texto));
    FilePicker.platform = _Selector(_archivo, bytes);

    await tester.pumpWidget(UncontrolledProviderScope(
        container: estado, child: const BayStreamApp()));

    // ------------------------------------------------ 1 · abrir el plano
    anunciar('abrir el plano de llegada $_archivo');
    final seleccionar = find.byKey(const ValueKey('select-file'));
    await hastaQue(() => seleccionar.evaluate().isNotEmpty, 'el inicio');
    expect(find.text('Abre un plano de estiba'), findsOneWidget);
    await pausa();
    await tocar(seleccionar);
    await hastaQue(() => estado.read(voyageUiStateProvider) is Previo,
        'el previo del plano');
    final previo = estado.read(voyageUiStateProvider) as Previo;
    expect(previo.fileName, _archivo);
    // Sin historial en el equipo, la app propone el puerto de salida que
    // declara el archivo; la escala de llegada se elige en los parámetros.
    expect(previo.portOfCall, 'PAMIT');
    expect(find.byKey(const ValueKey('preview-banner')), findsOneWidget);
    await pausa(1.5);

    // ------------------------------------------- 2 · confirmar la escala
    anunciar('confirmar el buque y la escala $_escala');
    await tocar(find.descendant(
        of: find.byKey(const ValueKey('preview-banner')),
        matching: find.text('Confirmar')));
    final parametros = find.byType(VesselGeometryPage);
    await hastaQue(
        () => parametros.evaluate().isNotEmpty, 'los parámetros del buque');
    final lista = find
        .descendant(of: parametros, matching: find.byType(Scrollable))
        .first;
    final puerto = find.byKey(const ValueKey('port-$_escala'));
    await tester.scrollUntilVisible(puerto, 300, scrollable: lista);
    expect(
        tester
            .widget<ChoiceChip>(find.byKey(const ValueKey('port-PAMIT')))
            .selected,
        isTrue);
    expect(tester.widget<ChoiceChip>(puerto).selected, isFalse);
    await pausa();
    await tocar(puerto);
    expect(tester.widget<ChoiceChip>(puerto).selected, isTrue);
    expect(find.textContaining('30 se descargan · 0 se cargan · 30 de paso'),
        findsOneWidget);
    await pausa();
    final sinLimite = find.byKey(const ValueKey('geometry-no-limit'));
    await tester.scrollUntilVisible(sinLimite, 300, scrollable: lista);
    await tocar(sinLimite);
    final confirmar = find.byKey(const ValueKey('geometry-confirm'));
    await tester.scrollUntilVisible(confirmar, 300, scrollable: lista);
    expect(tester.widget<FilledButton>(confirmar).enabled, isTrue);
    await pausa();
    await tocar(confirmar);
    await hastaQue(
        () =>
            estado.read(voyageUiStateProvider) is Publicado &&
            parametros.evaluate().isEmpty,
        'el plano publicado');
    final notificador = estado.read(voyageNotifierProvider.notifier);
    final viaje = notificador.publishedVoyage!;
    expect(viaje.portOfCall, _escala);
    expect(viaje.totalContainers, 60);
    expect(estado.read(destinoDelViajeProvider), DestinoDelViaje.plano,
        reason: 'confirmar se queda en el Plano');
    await pausa();

    // ------------------------------------------ 3 · recorrer las bahías
    anunciar('recorrer las bahías 02, 06 y 10');
    for (final bahia in [2, 6, 10]) {
      await tocar(find.byKey(ValueKey<String>('silueta-bahia-$bahia')));
      await hastaQue(
          () => find.byKey(ValueKey('plan-zoom-$bahia')).evaluate().isNotEmpty,
          'la rejilla de la bahía $bahia');
      await pausa();
    }

    // ----------------------------------------------- 4 · buscar y resaltar
    anunciar('buscar $_buscado y verlo resaltado');
    await tocar(find.byKey(const ValueKey('buscar-contenedor')));
    // La búsqueda es una ruta opaca: abierta, su campo es el único a la vista.
    await hastaQue(
        () => find
            .textContaining('Escribe parte del ID del contenedor')
            .evaluate()
            .isNotEmpty,
        'el buscador');
    final campo = find.byType(TextField);
    expect(campo, findsOneWidget);
    await pausa(0.5);
    for (final parte in ['MNLU', 'MNLU00002', _buscado]) {
      await tester.enterText(campo, parte);
      await tester.pump();
      await pausa(0.6);
    }
    final resultado = find.text(_buscado, findRichText: true);
    final fila = find.ancestor(of: resultado, matching: find.byType(ListTile));
    await hastaQue(() => find.byType(ListTile).evaluate().length == 1,
        'un solo resultado');
    expect(fila, findsOneWidget);
    await pausa(0.5);
    await tocar(resultado);
    final rejilla = find.byKey(const ValueKey('plan-zoom-$_bahia'));
    await hastaQue(
        () => fila.evaluate().isEmpty && rejilla.evaluate().isNotEmpty,
        'el plano en la bahía $_bahia');
    expect(estado.read(selectedBayProvider), _bahia);
    expect(estado.read(highlightedContainerProvider), _buscado);
    expect(
        find.descendant(
            of: rejilla, matching: find.byKey(const ValueKey(_buscado))),
        findsOneWidget,
        reason: 'la celda resaltada lleva el número del contenedor');
    await pausa(1.5);

    // ------------------------------------------- 5 · registrar dos descargas
    anunciar('registrar dos descargas en la bahía $_bahia');
    await _elegirDescarga(tocar);
    await hastaQue(
        () => estado.read(bayPlanModeProvider) == BayPlanMode.discharge,
        'el modo Descarga');
    // La prueba escucha el mismo avance que dibuja la rejilla.
    final avance = estado.listen(
        dischargeProgressProvider(estado.read(voyageNotifierProvider).value!),
        (_, __) {});
    DischargeMark? marca(String contenedor) =>
        avance.read().value?.markOf(contenedor);
    await hastaQue(
        () =>
            marca(_buscado) == DischargeMark.pending &&
            marca(_vecino) == DischargeMark.pending,
        'los dos por bajar en $_escala');
    await pausa();
    Finder celda(String clave) =>
        find.descendant(of: rejilla, matching: find.byKey(ValueKey(clave)));
    for (final (contenedor, clave) in [
      (_buscado, 'cell-2-82'),
      (_vecino, 'cell-1-82'),
    ]) {
      await tocar(celda(clave));
      await hastaQue(() => marca(contenedor) == DischargeMark.discharged,
          'la descarga de $contenedor');
      expect(find.textContaining('Descargado · $contenedor'), findsOneWidget);
      await pausa();
    }

    // ------------------------------------------------- 6 · deshacer una
    anunciar('deshacer la descarga de $_buscado');
    await tocar(celda('cell-2-82'));
    final deshacer = find.byKey(const ValueKey('discharge-undo-detail'));
    await hastaQue(() => deshacer.evaluate().isNotEmpty,
        'el detalle con «Deshacer la descarga»');
    await pausa();
    await tocar(deshacer);
    final porError = find.byKey(const ValueKey('annul-by-mistake'));
    await hastaQue(() => porError.evaluate().isNotEmpty, 'el motivo');
    expect(find.text('Deshacer · $_buscado'), findsOneWidget);
    await pausa();
    await tocar(porError);
    await hastaQue(() => marca(_buscado) == DischargeMark.pending,
        'la descarga de $_buscado deshecha');
    expect(marca(_vecino), DischargeMark.discharged);
    expect(find.textContaining('Deshecho · $_buscado'), findsOneWidget);
    await pausa(1.5);

    // ------------------------------------------------------- 7 · el avance
    anunciar('mirar el Avance de la escala');
    await _irA(tocar, DestinoDelViaje.avance);
    final tablaDelAvance =
        find.byKey(const ValueKey('operation-progress-scroll'));
    await hastaQue(() => tablaDelAvance.evaluate().isNotEmpty, 'el Avance');
    // El total y la bahía 06: una descarga hecha, la deshecha vuelve a faltar.
    expect(
        find.descendant(
            of: tablaDelAvance,
            matching: find.textContaining('1 descargado · 29 pendientes')),
        findsOneWidget);
    expect(
        find.descendant(
            of: tablaDelAvance,
            matching: find.textContaining('1 descargado · 9 pendientes')),
        findsOneWidget);
    await pausa(2);

    // -------------------------------------------------- 8 · Estadísticas
    anunciar('mirar las Estadísticas del buque');
    await _irA(tocar, DestinoDelViaje.estadisticas);
    final protagonista =
        find.byKey(const ValueKey<String>('estadisticas-protagonista'));
    await hastaQue(() => protagonista.evaluate().isNotEmpty, 'Estadísticas');
    expect(tester.widget<Text>(protagonista).data, '60');
    expect(find.text('contenedores a bordo'), findsOneWidget);
    await pausa(1.5);
    await tester.timedDrag(
        find.byKey(const ValueKey<String>('estadisticas-scroll')),
        const Offset(0, -500),
        const Duration(milliseconds: 900));
    await pausa(1.5);
    expect(tester.takeException(), isNull);
    debugPrint('      ok en ${_segundos(reloj.elapsed - inicioDelPaso)}');
    debugPrint('EXPO · $_pasos de $_pasos pasos comprobados en '
        '${_segundos(reloj.elapsed)}');

    // ----------------------------------------------------------- cierre
    avance.close();
    await tester.pumpWidget(const SizedBox.shrink());
    estado.dispose();
    await local.close();
    await bitacora.close();
    try {
      carpeta.deleteSync(recursive: true);
    } on FileSystemException {
      debugPrint('EXPO · el almacén queda en ${carpeta.path}');
    }
  }, timeout: const Timeout(Duration(minutes: 5)));
}

String _segundos(Duration d) =>
    '${(d.inMilliseconds / 1000).toStringAsFixed(1)} s';

/// Elige el modo Descarga como lo haría una persona: en los segmentos de la
/// oficina, en su menú si no caben, o en la banda del muelle del teléfono.
Future<void> _elegirDescarga(Future<void> Function(Finder) tocar) async {
  final banda = find.descendant(
      of: find.byKey(const ValueKey('banda-del-muelle')),
      matching: find.text('Descarga'));
  if (banda.evaluate().isNotEmpty) {
    await tocar(banda);
    return;
  }
  final selector = find.byKey(const ValueKey('bay-plan-display-mode')).first;
  final enSegmentos = find.descendant(
      of: selector, matching: find.byType(SegmentedButton<BayPlanMode>));
  if (enSegmentos.evaluate().isNotEmpty) {
    await tocar(find.descendant(
        of: selector,
        matching: find.textContaining('Descarga', findRichText: true)));
    return;
  }
  await tocar(
      find.descendant(of: selector, matching: find.byType(OutlinedButton)));
  await tocar(find.ancestor(
      of: find.text('Descarga'), matching: find.byType(MenuItemButton)));
}

/// Va a un destino del viaje: por el riel en la oficina, por la barra en el
/// teléfono.
Future<void> _irA(
    Future<void> Function(Finder) tocar, DestinoDelViaje destino) async {
  final enElRiel = find.descendant(
      of: find.byKey(const ValueKey('riel-del-viaje')),
      matching: find.text(destino.rotulo));
  await tocar(enElRiel.evaluate().isNotEmpty
      ? enElRiel
      : find.byKey(ValueKey<String>('destino-${destino.name}')));
}

/// Sustituye solo el diálogo; los bytes recorren la entrada real del producto.
class _Selector extends FilePicker {
  _Selector(this.nombre, this.bytes);

  final String nombre;
  final Uint8List bytes;

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = false,
    int compressionQuality = 0,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async =>
      FilePickerResult(
          [PlatformFile(name: nombre, size: bytes.length, bytes: bytes)]);
}

/// Solo lee BAPLIE; nada de nube (como el `_SoloLector` de tool/t124_main.dart).
class _SoloLector implements VesselRepository {
  @override
  Future<Either<Failure, VesselVoyage>> parseBaplieFile(String content) async {
    try {
      return Right(BaplieParserService().parse(content));
    } on BaplieParsingException catch (e) {
      return Left(BaplieParsingFailure(
          message: e.message, code: e.code, segment: e.segment));
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
