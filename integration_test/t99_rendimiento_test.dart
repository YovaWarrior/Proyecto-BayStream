// T-99 · Arnés de RNF-001 (rendimiento) y RNF-007 (capacidad), T-63 2.
//
// Corre en modo profile con flutter drive (ver integration_test/t99_driver.dart)
// sobre la interfaz real de lib/, con almacenes propios en una carpeta temporal
// y sin Firebase. Cinco escenarios, cada uno con una repetición en frío que se
// descarta y T99_REPETICIONES medidas:
//   - parseo: la llamada al lector, BaplieParserService.parse, dentro de una
//     marca de Timeline «t99_parseo» (entrada al lector → modelo construido);
//   - navegacion: toque en el chip de la bahía siguiente → primer cuadro
//     rasterizado con su rejilla;
//   - busqueda: un carácter más en el campo → cuadro con la lista filtrada;
//   - tablero: toque en «Estadísticas» → cuadro con todo pintado y quieto;
//   - scroll_lista y scroll_estadisticas: arrastre continuo de 1.5 s, con
//     traceAction (reglas de TimelineSummary en tool/t99_resumen.dart) y con
//     watchPerformance (FrameTimingSummarizer de flutter_test).
// Cada latencia se mide dos veces: con traceAction y sin traza, con los
// FrameTiming del motor. El ensayo de la Fase A vio que grabar la línea de
// tiempo vuelve más lentos los cuadros de la interfaz con listas grandes
// (efecto observador): la pasada sin traza no lo sufre, y la pasada con traza
// también guarda sus FrameTiming para comprobar que los dos relojes coinciden.
// No corre en la Web: traceAction necesita el VM service, que la Web no expone.
// La entrada es un asset de la copia de compilación (t99_inputs/), nunca del
// repositorio. No da dictámenes: tool/t99_resumen.dart da las cifras.
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:baystream/core/app.dart';
import 'package:baystream/features/vessel/data/datasources/hive_movement_data_source.dart';
import 'package:baystream/features/vessel/data/datasources/hive_vessel_data_source.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_impl.dart';
import 'package:baystream/features/vessel/data/repositories/movement_log_repository_impl.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/voyage_stats_view.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../tool/t99_app.dart';
import 't99_ventana.dart';

const _archivo = String.fromEnvironment('T99_ARCHIVO');
const _esperados = int.fromEnvironment('T99_CONTENEDORES');
const _repeticiones = int.fromEnvironment('T99_REPETICIONES', defaultValue: 5);
const _maximizar = bool.fromEnvironment('T99_MAXIMIZAR', defaultValue: true);

/// Los eventos que necesitan las reglas de TimelineSummary y las marcas.
bool _conservar(Object? nombre) =>
    nombre is String &&
    (nombre.startsWith('t99_') ||
        const {'Frame', 'GPURasterizer::Draw', 'Rasterizer::DoDraw', 'Animator::BeginFrame'}
            .contains(nombre));

/// Un FrameTiming del motor, en microsegundos.
Map<String, int> _cuadro(ui.FrameTiming t) => {
      'vsync': t.timestampInMicroseconds(ui.FramePhase.vsyncStart),
      'build_inicio': t.timestampInMicroseconds(ui.FramePhase.buildStart),
      'build_fin': t.timestampInMicroseconds(ui.FramePhase.buildFinish),
      'raster_inicio': t.timestampInMicroseconds(ui.FramePhase.rasterStart),
      'raster_fin': t.timestampInMicroseconds(ui.FramePhase.rasterFinish),
    };

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('T-99 rendimiento · $_archivo', (tester) async {
    expect(_archivo, isNotEmpty, reason: 'Falta --dart-define=T99_ARCHIVO');
    final medidas = <Map<String, Object?>>[];
    final entorno = <String, Object?>{
      'archivo': _archivo,
      'modo': kProfileMode ? 'profile' : kReleaseMode ? 'release' : 'debug',
      'plataforma': Platform.operatingSystem,
      'version_del_sistema': Platform.operatingSystemVersion,
      'repeticiones_medidas': _repeticiones,
      'repeticion_descartada': 0,
    };
    binding.reportData = {
      't99': {'entorno': entorno, 'medidas': medidas}
    };

    // Solo los flujos Dart (marcas y «Frame») y Embedder (el motor y su
    // raster): con «all», el búfer circular de la línea de tiempo se llenaba y
    // perdía los eventos más viejos (ensayo de la Fase A, 18-oct).
    Future<List<Map<String, dynamic>>> trazar(Future<void> Function() accion) async {
      const clave = 't99_traza';
      await binding.traceAction(accion,
          reportKey: clave, streams: const ['Dart', 'Embedder']);
      final traza = binding.reportData!.remove(clave) as Map<String, dynamic>;
      return [
        for (final e in (traza['traceEvents'] as List? ?? const []).cast<Map<String, dynamic>>())
          if (_conservar(e['name'])) e
      ];
    }

    // Los FrameTiming de los cuadros que dibuja [accion]. Llegan en lotes:
    // se sigue dibujando hasta recibir uno que empezó después de [despuesDe].
    Future<List<Map<String, int>>> conCuadros(
        Future<void> Function() accion, int Function() despuesDe) async {
      final tiempos = <ui.FrameTiming>[];
      void alRecibir(List<ui.FrameTiming> t) => tiempos.addAll(t);
      binding.addTimingsCallback(alRecibir);
      await accion();
      for (var i = 0;
          i < 60 &&
              !tiempos.any((t) =>
                  t.timestampInMicroseconds(ui.FramePhase.buildStart) > despuesDe());
          i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      binding.removeTimingsCallback(alRecibir);
      return [for (final t in tiempos) _cuadro(t)];
    }

    // Con `quieto`, espera además a que no quede ningún cuadro pendiente: el
    // tablero termina cuando todo está pintado y la pestaña dejó de moverse.
    Future<void> hastaQue(bool Function() listo, {bool quieto = true}) async {
      for (var i = 0; i < 600; i++) {
        await tester.pump();
        if (listo() && (!quieto || !binding.hasScheduledFrame)) return;
      }
      fail('La interfaz no llegó al estado esperado');
    }

    // Una latencia, dos pasadas: con traza y sin ella. [preparar] deja la
    // interfaz igual antes de cada una; las marcas guardan su hora en el reloj
    // de la línea de tiempo (developer.Timeline.now).
    Future<void> latencia(String escenario, int rep, Map<String, Object?> datos,
        {required Future<void> Function() preparar,
        required Future<void> Function() accion,
        required bool Function() listo,
        bool quieto = true}) async {
      var marcaUs = 0, finUs = 0;
      Future<void> recorrido() async {
        marcaUs = developer.Timeline.now;
        developer.Timeline.instantSync('t99_marca');
        await accion();
        await hastaQue(listo, quieto: quieto);
        finUs = developer.Timeline.now;
        developer.Timeline.instantSync('t99_fin');
      }

      await preparar();
      var eventos = <Map<String, dynamic>>[];
      final cuadrosConTraza = await conCuadros(() async {
        eventos = await trazar(recorrido);
      }, () => finUs);
      await tester.pumpAndSettle();
      await preparar();
      final cuadrosSinTraza = await conCuadros(recorrido, () => finUs);
      await tester.pumpAndSettle();
      medidas.add({
        ...datos,
        'escenario': escenario,
        'repeticion': rep,
        'eventos': eventos,
        'cuadros_con_traza': cuadrosConTraza,
        'sin_traza': {'marca_us': marcaUs, 'fin_us': finUs, 'cuadros': cuadrosSinTraza},
      });
    }

    // El runner de Windows muestra la ventana con el primer cuadro: antes no
    // hay ninguna visible que maximizar.
    await tester.pumpWidget(const SizedBox());
    for (var i = 0; i < 50 && ventanaPropiaMaximizada() == null && Platform.isWindows; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    final antes = tester.view.physicalSize;
    entorno['vista_fisica_al_abrir'] = '${antes.width.round()}x${antes.height.round()}';
    final tocadas = _maximizar ? maximizarVentanaPropia() : 0;
    if (tocadas > 0) {
      for (var i = 0; i < 60 && tester.view.physicalSize == antes; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    }
    entorno['ventanas_propias_maximizadas'] = tocadas;
    entorno['ventana_maximizada'] = ventanaPropiaMaximizada();
    entorno['vista_fisica'] =
        '${tester.view.physicalSize.width.round()}x${tester.view.physicalSize.height.round()}';
    entorno['escala'] = tester.view.devicePixelRatio;
    final logico = tester.view.physicalSize / tester.view.devicePixelRatio;
    entorno['vista_logica'] = '${logico.width.round()}x${logico.height.round()}';

    final datos = await rootBundle.load(_archivo);
    final bytes = datos.buffer.asUint8List();
    final texto = String.fromCharCodes(bytes);
    entorno['bytes'] = bytes.length;
    entorno['sha256'] = sha256.convert(bytes).toString();

    // 1 · Parseo: la llamada al lector, sin la interfaz.
    for (var rep = 0; rep <= _repeticiones; rep++) {
      var cuenta = -1;
      final reloj = Stopwatch();
      final eventos = await trazar(() async {
        developer.Timeline.timeSync('t99_parseo', () {
          reloj.start();
          cuenta = BaplieParserService().parse(texto).totalContainers;
          reloj.stop();
        });
      });
      medidas.add({
        'escenario': 'parseo', 'repeticion': rep, 'eventos': eventos,
        'cronometro_us': reloj.elapsedMicroseconds, 'contenedores': cuenta,
      });
      entorno['contenedores_leidos'] = cuenta;
      if (_esperados > 0) {
        expect(cuenta, _esperados, reason: 'El lector dio otra cuenta: detente y avisa');
      }
    }

    // Preparación, sin medir: la app con el viaje publicado y el perfil guardado.
    final almacen = await Directory.systemTemp.createTemp('t99_almacen_');
    await tester.pumpWidget(t99App(
      local: () async => LocalVesselRepositoryImpl(
          await HiveVesselDataSource.open(directory: almacen.path, namespace: t99Namespace)),
      bitacora: () async => MovementLogRepositoryImpl(
          await HiveMovementDataSource.open(directory: almacen.path, namespace: t99Namespace)),
    ));
    await tester.pumpAndSettle();
    final contenedor = ProviderScope.containerOf(tester.element(find.byType(BayStreamApp)));
    final notificador = contenedor.read(voyageNotifierProvider.notifier);
    final error = await t99Publicar(notificador, texto, _archivo.split('/').last);
    expect(error, isNull, reason: 'No se pudo publicar el archivo');
    await tester.pumpAndSettle();
    final viaje = notificador.publishedVoyage!;
    entorno['bahias'] = viaje.bays.length;

    // 2 · Navegación entre bahías: de la bahía rep a la siguiente.
    await tester.tap(find.widgetWithText(Tab, 'Bay Plan'));
    await tester.pumpAndSettle();
    // Las bahías que se tocan son las del selector, como las ve el usuario:
    // la lista de chips es perezosa y no construye lo que queda fuera de vista.
    final selector = find
        .descendant(of: find.byKey(const ValueKey('bay-selector')), matching: find.byType(Scrollable))
        .first;
    tester.state<ScrollableState>(selector).position.jumpTo(0);
    await tester.pumpAndSettle();
    final bahias = {
      for (final t in tester.widgetList<Text>(
          find.descendant(of: find.byKey(const ValueKey('bay-selector')), matching: find.byType(Text))))
        if (RegExp(r'^BAY (\d+) \(').firstMatch(t.data ?? '') case final m?) int.parse(m.group(1)!)
    }.toList()
      ..sort();
    entorno['bahias_del_viaje'] = (viaje.bays.keys.toList()..sort()).join(' ');
    entorno['bahias_del_selector_al_inicio'] = bahias.join(' ');
    Finder chip(int bahia) {
      final f = find.textContaining('BAY ${bahia.toString().padLeft(2, '0')} (');
      if (f.evaluate().isEmpty) {
        final vistas = tester
            .widgetList<Text>(find.textContaining('BAY '))
            .map((t) => t.data)
            .join(' | ');
        fail('No está el chip de la bahía $bahia. Se ven: $vistas');
      }
      return f.first;
    }

    // Elegir una bahía desplaza la lista de chips: antes de tocar uno se trae
    // a la vista, desde el inicio de la lista si hace falta.
    Future<void> chipALaVista(int bahia) async {
      final f = find.textContaining('BAY ${bahia.toString().padLeft(2, '0')} (');
      if (f.evaluate().isEmpty) {
        tester.state<ScrollableState>(selector).position.jumpTo(0);
        await tester.pumpAndSettle();
      }
      if (f.evaluate().isEmpty) {
        await tester.scrollUntilVisible(f, 120, scrollable: selector);
      }
      await tester.ensureVisible(chip(bahia));
      await tester.pumpAndSettle();
    }

    for (var rep = 0; rep <= _repeticiones; rep++) {
      final desde = bahias[rep % bahias.length];
      final destino = bahias[(rep + 1) % bahias.length];
      await latencia('navegacion', rep, {'bahia': destino},
          preparar: () async {
            await chipALaVista(desde);
            await tester.tap(chip(desde));
            await tester.pumpAndSettle();
            await chipALaVista(destino);
          },
          accion: () => tester.tap(chip(destino)),
          // El primer cuadro con la rejilla nueva (T-63): la animación del
          // chip ya no cuenta.
          listo: () => find.byKey(ValueKey('plan-zoom-$destino')).evaluate().isNotEmpty,
          quieto: false);
    }

    // 3 · Búsqueda: un carácter más por repetición.
    await tester.tap(find.widgetWithText(Tab, 'Lista'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Buscar contenedor'));
    await tester.pumpAndSettle();
    final ids = viaje.containers.map((c) => c.containerId).toList()..sort();
    final id = ids[ids.length ~/ 2];
    void escribir(String q) => tester
        .state<EditableTextState>(find.byType(EditableText).first)
        .updateEditingValue(
            TextEditingValue(text: q, selection: TextSelection.collapsed(offset: q.length)));
    for (var rep = 0; rep <= _repeticiones; rep++) {
      final consulta = id.substring(0, math.min(rep + 1, id.length));
      await latencia('busqueda', rep, {'caracteres': consulta.length},
          preparar: () async {
            escribir(consulta.substring(0, consulta.length - 1));
            await tester.pumpAndSettle();
          },
          accion: () async => escribir(consulta),
          // El cuadro con la lista filtrada es el primero después del carácter.
          listo: () => true,
          quieto: false);
    }
    await tester.tap(find.byTooltip('Volver'));
    await tester.pumpAndSettle();

    // 4 · Tablero: de Lista a Estadísticas.
    for (var rep = 0; rep <= _repeticiones; rep++) {
      await latencia('tablero', rep, {},
          preparar: () async {
            await tester.tap(find.widgetWithText(Tab, 'Lista'));
            await tester.pumpAndSettle();
          },
          accion: () => tester.tap(find.widgetWithText(Tab, 'Estadísticas')),
          listo: () => find.byType(VoyageStatsView).evaluate().isNotEmpty);
    }

    // 5 · Scroll continuo de Lista y de Estadísticas. El desplazable es el
    // vertical con más recorrido: la Lista anida un ListView que no se mueve.
    Finder vertical() {
      final estados = tester
          .stateList<ScrollableState>(find.byType(Scrollable))
          .where((s) => s.position.axis == Axis.vertical)
          .toList()
        ..sort((a, b) => b.position.maxScrollExtent.compareTo(a.position.maxScrollExtent));
      return find.byWidget(estados.first.widget);
    }

    for (final (escenario, pestana, tope) in [
      ('scroll_lista', 'Lista', 3000.0),
      ('scroll_estadisticas', 'Estadísticas', 1500.0),
    ]) {
      await tester.tap(find.widgetWithText(Tab, pestana));
      await tester.pumpAndSettle();
      for (var rep = 0; rep <= _repeticiones; rep++) {
        Future<double> alInicio() async {
          final s = tester.state<ScrollableState>(vertical());
          s.position.jumpTo(0);
          await tester.pumpAndSettle();
          return math.min(tope, s.position.maxScrollExtent);
        }

        var distancia = await alInicio();
        Future<void> arrastrar() async {
          await tester.timedDrag(
              vertical(), Offset(0, -distancia), const Duration(milliseconds: 1500));
          await tester.pumpAndSettle();
        }

        final eventos = await trazar(arrastrar);
        distancia = await alInicio();
        await binding.watchPerformance(arrastrar, reportKey: 't99_cuadros');
        medidas.add({
          'escenario': escenario, 'repeticion': rep, 'distancia_px': distancia,
          'eventos': eventos, 'resumen_cuadros': binding.reportData!.remove('t99_cuadros'),
        });
      }
    }

    // Qué evento de raster trae este motor (TimelineSummary usa el primero).
    final nombres = {
      for (final m in medidas) ...(m['eventos'] as List).map((e) => (e as Map)['name'])
    };
    entorno['evento_de_raster'] =
        nombres.contains('GPURasterizer::Draw') ? 'GPURasterizer::Draw' : 'Rasterizer::DoDraw';
    // Hive sigue con sus cajas abiertas hasta que termina el proceso: el
    // almacén temporal no se borra aquí. Queda en %TEMP% y se anota.
    entorno['almacen_temporal'] = almacen.path;
  }, timeout: Timeout.none);
}
