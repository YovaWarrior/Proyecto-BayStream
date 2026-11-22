// T-120, entrega 2 · El conductor del banco para MIRAR la entrega en la app
// del producto, en Windows y en la Web (`tool/t120e2_main.dart`). Usa los
// helpers de plataforma de T-147 (`t147_plataforma.dart`: parámetros, el caso
// de fuera del repositorio, los pasos y las capturas) y no toca nada de T-147.
//
// Escenarios (parámetro `escenario`; en Windows, la variable T147_ESCENARIO;
// en la Web, `?escenario=`), cada uno con su archivo (`archivo`):
//
// - `capturas`, por tema, tamaño y letra (`temas`, `tamanos`, `letras`):
//   - con el buque de 977: la fila «Carga especial» (O-120-5) y, al tocar la
//     barra de PAMIT en Estadísticas, los cuatro cuadros que siguen al toque,
//     uno por uno, sin esperar a que se asiente (O-120-4), con dónde queda el
//     título en cada uno;
//   - con la lista corta: de la barra de VELAG y de «Sin destino» a la Lista
//     (D9, 18.5), con el título y las tarjetas medidos contra la vista;
//   - con la repetida: el aviso del lector y las dos tarjetas.
// - `pellizco`: O-119-1 en la app de verdad, con eventos sintéticos del
//   touchpad (PointerPanZoom…) y del pellizco de la Web (PointerScaleEvent),
//   en pasos chicos, midiendo cuadro por cuadro el punto bajo el puntero.
// - `foco`: O-128-4. Empieza un pellizco del touchpad sin su final, anota
//   «esperando-foco» y espera a que la ventana o la pestaña pierda el foco y
//   lo recupere (lo hace el arnés: t120e2_windows.py o t120e2_web.py); anota
//   si el plano soltó el pellizco y si la rueda vuelve a mover la columna.
// - `mano`: mide los pellizcos de verdad (el touchpad de Carlos) durante
//   `tope` segundos: por cada gesto, el peor desvío del punto bajo el
//   puntero, cuadro por cuadro.
// - `parpadeo` (corrección 1, D4): toca la barra de PAMIT `toques` veces,
//   sin capturar por dentro, para medir O-120-4 en la grabación de la
//   ventana sin que el instrumento alargue los cuadros.
// - `selector` (corrección 1, D2 y D3): abre el Plano, anota el rectángulo
//   de cada segmento del selector (el icono, el rótulo y el segmento entero,
//   en píxeles lógicos de la ventana) y espera `tope` segundos: el arnés pasa
//   el mouse y lee el árbol de accesibilidad del navegador.
// - `monitores`: abre el Plano con zoom y desplazado y se queda quieto;
//   anota cada cambio de tamaño o de densidad de la ventana y cada error de
//   Flutter (para los dos monitores, con tool/t120_monitores.ps1).
//
// Cada captura anota los textos que no caben y los errores de Flutter.
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:baystream/core/app.dart';
import 'package:baystream/core/design/design.dart';
import 'package:baystream/features/vessel/domain/entities/app_theme_preference.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/operation_sources.dart';
import 'package:baystream/features/vessel/presentation/providers/plano_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/theme_preference_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/filtros_de_la_lista.dart';
import 'package:baystream/features/vessel/presentation/widgets/navegacion_del_viaje.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 't147_plataforma.dart';

String _p(String nombre, [String porOmision = '']) {
  final v = parametro(nombre);
  return v.isEmpty ? porOmision : v;
}

/// El conductor, o `null` si no se pidió (sin escenario).
T120e2Conductor? t120e2Conductor() {
  final escenario = parametro('escenario');
  return escenario.isEmpty ? null : T120e2Conductor(escenario);
}

class T120e2Conductor {
  T120e2Conductor(this.escenario);

  final String escenario;
  final _tamano = ValueNotifier<Size?>(null);
  final _letra = ValueNotifier<double>(1.0);
  final _lienzo = GlobalKey();
  final _errores = <String>[];
  final _ciclo = <String>[];
  var _puntero = 12000;
  AppLifecycleListener? _escucha;

  /// Para `BayStreamApp.builder`: impone el tamaño lógico y la letra, reduce
  /// el movimiento y deja un `RepaintBoundary` para la captura. Sin tamaño,
  /// la ventana manda (los monitores).
  Widget envoltorio(BuildContext context, Widget? child) =>
      ValueListenableBuilder<Size?>(
          valueListenable: _tamano,
          builder: (context, tamano, _) => ValueListenableBuilder<double>(
              valueListenable: _letra,
              builder: (context, letra, _) {
                final datos = MediaQuery.of(context).copyWith(
                    size: tamano,
                    textScaler: letra == 1.0 ? null : TextScaler.linear(letra),
                    disableAnimations: true);
                final lienzo = RepaintBoundary(
                    key: _lienzo,
                    child: MediaQuery(data: tamano == null ? MediaQuery.of(context) : datos, child: child!));
                if (tamano == null) return lienzo;
                return ColoredBox(
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    child: FittedBox(
                        child: SizedBox.fromSize(size: tamano, child: lienzo)));
              }));

  void iniciar() {
    final anterior = FlutterError.onError;
    FlutterError.onError = (detalles) {
      final texto = detalles.exceptionAsString().split('\n').first;
      _errores.add(texto);
      unawaited(_registrar('error-de-flutter', {'detalle': texto}));
      anterior?.call(detalles);
    };
    _escucha = AppLifecycleListener(onStateChange: (estado) {
      _ciclo.add(estado.name);
      unawaited(_registrar('ciclo-de-vida', {'estado': estado.name}));
    });
    SchedulerBinding.instance
        .addPostFrameCallback((_) => unawaited(_ejecutar()));
  }

  Future<void> _ejecutar() async {
    try {
      await _asentar();
      await _registrar('inicio', {
        'escenario': escenario,
        'archivo': _p('archivo'),
        'ventana_logica': '${_ventana().width}x${_ventana().height}',
      });
      await _cargar(_p('archivo', 'T120_BUQUE_LISTA_977.edi'));
      switch (escenario) {
        case 'capturas':
          await _capturas();
        case 'pellizco':
          await _pellizco();
        case 'foco':
          await _foco();
        case 'mano':
          await _mano();
        case 'parpadeo':
          await _parpadeoSinCaptura();
        case 'selector':
          await _selector();
        case 'monitores':
          await _monitores();
          return; // se queda abierto: lo cierra el script
        default:
          throw StateError('Escenario desconocido: $escenario');
      }
      _tamano.value = null;
      _letra.value = 1.0;
      await _registrar('fin', {'ciclo_de_vida': _ciclo});
    } catch (error, pila) {
      await _registrar('error', {
        'detalle': '$error',
        'pila': pila.toString().split('\n').take(8).join(' | '),
      });
    } finally {
      _escucha?.dispose();
    }
  }

  // --- capturas ---------------------------------------------------------

  Future<void> _capturas() async {
    final archivo = _p('archivo');
    final c = _riverpod();
    for (final tema in _p('temas', 'claro,oscuro').split(',')) {
      await c.read(themePreferenceProvider.notifier).select(
          tema == 'claro' ? AppThemePreference.light : AppThemePreference.dark);
      for (final especificacion in _p('tamanos', '1366x690,360x800').split(',')) {
        final partes = especificacion.split('x');
        final tamano = Size(double.parse(partes[0]), double.parse(partes[1]));
        final telefono = tamano.width < AnchosDeNavegacion.riel;
        final letras = telefono && archivo.contains('977')
            ? _p('letras', '1.0,2.0').split(',').map(double.parse)
            : const <double>[1.0];
        for (final letra in letras) {
          _tamano.value = tamano;
          _letra.value = letra;
          await _asentar();
          final sufijo = '${especificacion}_${tema}_letra$letra';
          if (archivo.contains('977')) {
            await _filaDeCarga(sufijo);
            if (letra == 1.0) await _parpadeo(sufijo, 'PAMIT');
          } else if (archivo.contains('CORTA')) {
            await _listaCorta(sufijo, 'VELAG');
            await _listaCorta(sufijo, 'Sin destino');
          } else if (archivo.contains('REPETIDA')) {
            await _repetida(sufijo);
          }
        }
      }
    }
  }

  /// O-120-5: la fila «Carga especial», con sus chips a la vista.
  Future<void> _filaDeCarga(String sufijo) async {
    await _ir(DestinoDelViaje.lista);
    _sinFiltros();
    await _asentar();
    await _alaVista('filtros-de-la-lista');
    final chips = <String, Object?>{};
    for (final carga in ['peligrosa', 'refrigerado', 'fueraDeMedida']) {
      final e = _buscar((e) =>
          e.widget.key == ValueKey<String>('filtro-carga-$carga'));
      chips[carga] = e == null ? null : _rect(e).toString();
    }
    await _capturar(sufijo, 'o1205_fila_de_carga', {
      'chips_de_carga': chips,
      'ver_las_3_cargas': _buscar((e) =>
              e.widget.key == const ValueKey<String>('filtro-carga-ver-todas')) !=
          null,
    });
  }

  /// O-120-4: los cuadros que siguen al toque de la barra, uno por uno.
  Future<void> _parpadeo(String sufijo, String puerto) async {
    _sinFiltros();
    await _ir(DestinoDelViaje.estadisticas);
    await _alaVista('estadisticas-puertos');
    final barra = _barraDe(puerto);
    await Scrollable.ensureVisible(barra, alignment: 0.5, duration: Duration.zero);
    await _asentar();
    await _capturar(sufijo, 'o1204_cuadro0_antes_del_toque');
    await _tocar(_barraDe(puerto));
    for (var k = 1; k <= 4; k++) {
      await _siguienteCuadro();
      await _capturarCon(
          sufijo, 'o1204_cuadro${k}_tras_el_toque', _dondeQuedaLaLista(),
          asentar: false);
    }
    await _asentar();
    await _capturar(sufijo, 'o1204_asentado', _dondeQuedaLaLista());
    _sinFiltros();
    await _asentar();
  }

  /// D9 con una lista corta: de la barra a la Lista.
  Future<void> _listaCorta(String sufijo, String barra) async {
    _sinFiltros();
    await _ir(DestinoDelViaje.estadisticas);
    await _alaVista('estadisticas-puertos');
    await Scrollable.ensureVisible(_barraDe(barra),
        alignment: 0.5, duration: Duration.zero);
    await _asentar();
    await _tocar(_barraDe(barra));
    await _asentar();
    final nombre = barra == 'Sin destino' ? 'sin_destino' : barra;
    await _capturar(sufijo, 'd9_corta_$nombre', _dondeQuedaLaLista());
    _sinFiltros();
    await _asentar();
  }

  /// La Lista con una matrícula repetida: arriba, el aviso; abajo, las dos.
  Future<void> _repetida(String sufijo) async {
    await _ir(DestinoDelViaje.lista);
    _sinFiltros();
    await _asentar();
    final lista = _scrollDeLaLista();
    lista.jumpTo(0);
    await _asentar();
    await _capturar(sufijo, 'repetida_1_aviso');
    // La primera tarjeta de la repetida, arriba; después la segunda.
    final tarjetas = <String>[];
    for (var vez = 0; vez < 2; vez++) {
      Element? tarjeta;
      var y = 0.0;
      while (tarjeta == null && y <= lista.maxScrollExtent) {
        lista.jumpTo(y);
        await _asentar();
        final halladas = _todos((e) {
          final k = e.widget.key;
          return k is ValueKey<String> &&
              // Corrección 1 (T120-E2-01): la clave lleva la celda.
              k.value.startsWith('tarjeta-TSTU0000003-') &&
              _visible(e);
        });
        if (halladas.length > vez) tarjeta = halladas[vez];
        y += 120;
      }
      if (tarjeta == null) throw StateError('No apareció la tarjeta $vez');
      await Scrollable.ensureVisible(tarjeta, alignment: 0.05, duration: Duration.zero);
      await _asentar();
      final textos = _textosDe(tarjeta);
      tarjetas.add(textos.join(' | '));
      await _capturar(sufijo, 'repetida_${vez + 2}_tarjeta_${vez + 1}',
          {'textos_de_la_tarjeta': textos});
    }
    await _registrar('repetida', {'tarjetas': tarjetas});
    if (_p('archivo').contains('TRES')) await _filtroYSoltar(sufijo);
  }

  /// Corrección 1 (T120-E2-01): el filtro de LNB deja dos tarjetas de la
  /// matrícula a la vista; al soltarlo, la Lista se rearma. Anota las claves
  /// en orden y los errores de Flutter.
  Future<void> _filtroYSoltar(String sufijo) async {
    List<String> claves() {
      final todas = _todos((e) {
        final k = e.widget.key;
        return k is ValueKey<String> && k.value.startsWith('tarjeta-');
      })
        ..sort((a, b) => _rect(a).top.compareTo(_rect(b).top));
      return [for (final e in todas) (e.widget.key! as ValueKey<String>).value];
    }

    final lista = _scrollDeLaLista();
    lista.jumpTo(0);
    _riverpod().read(selectedCarrierProvider.notifier).select('LNB');
    await _asentar();
    await _alaVista('titulo-de-la-lista');
    await _capturar(sufijo, 'repetida_4_filtro_LNB', {'claves': claves()});
    _riverpod().read(selectedCarrierProvider.notifier).clear();
    await _asentar();
    await _alaVista('titulo-de-la-lista');
    await _capturar(sufijo, 'repetida_5_filtro_soltado', {'claves': claves()});
  }

  Map<String, Object?> _dondeQuedaLaLista() {
    final vista = _buscar((e) => e.widget.key == const ValueKey('lista-scroll'));
    final titulo = _buscar((e) => e.widget is TituloDeLaLista);
    if (vista == null || titulo == null) return {'lista': 'no construida'};
    final rv = _rect(vista);
    final rt = _rect(titulo);
    final p = _scrollDeLaLista();
    final tarjetas = _todos((e) {
      final k = e.widget.key;
      return k is ValueKey<String> && k.value.startsWith('tarjeta-');
    });
    return {
      'titulo_desde_arriba_de_la_vista': (rt.top - rv.top).roundToDouble(),
      'desplazamiento': p.pixels.roundToDouble(),
      'tope': p.maxScrollExtent.roundToDouble(),
      'tarjetas_construidas': tarjetas.length,
      'tarjetas': [
        for (final t in tarjetas)
          {
            'arriba': (_rect(t).top - rv.top).roundToDouble(),
            // El cuerpo, sin el margen de abajo de la tarjeta (12 dp).
            'abajo': (_rect(t).bottom - 12 - rv.top).roundToDouble(),
          }
      ],
      'alto_de_la_vista': rv.height.roundToDouble(),
    };
  }

  // --- pellizco ---------------------------------------------------------

  Future<void> _pellizco() async {
    _tamano.value = const Size(1366, 690);
    await _riverpod()
        .read(themePreferenceProvider.notifier)
        .select(AppThemePreference.light);
    await _ir(DestinoDelViaje.plano);
    final resultados = <String, Object?>{};
    for (final serie in ['touchpad', 'web', 'rafaga', 'touchpad_al_fondo']) {
      final c = _riverpod();
      c.read(planZoomProvider.notifier).fijar(1);
      await _asentar();
      final celda0 = _celdaDelCentro();
      final columna = Scrollable.of(celda0, axis: Axis.vertical).position;
      columna.jumpTo(serie == 'touchpad_al_fondo' ? columna.maxScrollExtent : 0);
      await _asentar();
      final celda = serie == 'touchpad_al_fondo' ? _celdaDeAbajo() : _celdaDelCentro();
      final clave = celda.widget.key!;
      Element actual() =>
          _buscar((e) => e.widget.key == clave) ?? (throw StateError('Se perdió $clave'));
      final foco = _centroEnElLienzo(celda);
      await _capturar('1366x690_claro', 'pellizco_${serie}_antes');
      var antes = foco;
      var escalaAntes = c.read(planZoomProvider);
      var peor = 0.0;
      var donde = '';
      var medidas = 0;
      var cruzo = false;
      void mirar(String paso, {bool cierra = false}) {
        final escala = c.read(planZoomProvider);
        final e = actual();
        final ahora = _centroEnElLienzo(e);
        final esperado = foco + (antes - foco) * (escala / escalaAntes);
        final rejilla = Scrollable.of(e, axis: Axis.horizontal).position;
        final col = Scrollable.of(e, axis: Axis.vertical).position;
        bool tope(ScrollPosition p) =>
            p.pixels <= p.minScrollExtent + 0.01 || p.pixels >= p.maxScrollExtent - 0.01;
        if (rejilla.maxScrollExtent > 0) {
          cruzo = true;
          if (!tope(rejilla)) {
            medidas++;
            final d = (ahora.dx - esperado.dx).abs();
            if (d > peor) {
              peor = d;
              donde = '$paso, horizontal';
            }
          }
        }
        if (!tope(col)) {
          medidas++;
          final d = (ahora.dy - esperado.dy).abs();
          if (d > peor) {
            peor = d;
            donde = '$paso, vertical';
          }
        }
        if (cierra) {
          antes = ahora;
          escalaAntes = escala;
        }
      }

      final global = _aGlobal(foco);
      final vista = _vista();
      final puntero = _puntero++;
      Future<void> dosCuadros(String paso) async {
        await _siguienteCuadro();
        mirar('$paso, primer cuadro');
        await _siguienteCuadro();
        mirar('$paso, segundo cuadro', cierra: true);
      }

      if (serie.startsWith('touchpad')) {
        GestureBinding.instance.handlePointerEvent(PointerPanZoomStartEvent(
            pointer: puntero, position: global, viewId: vista));
        await _siguienteCuadro();
        final pasos = serie == 'touchpad' ? 80 : 40;
        for (var i = 2; i <= pasos; i++) {
          GestureBinding.instance.handlePointerEvent(PointerPanZoomUpdateEvent(
              pointer: puntero, position: global, scale: 1 + i / 100, viewId: vista));
          await dosCuadros('a ${(1 + i / 100).toStringAsFixed(2)}');
        }
        GestureBinding.instance.handlePointerEvent(PointerPanZoomEndEvent(
            pointer: puntero, position: global, viewId: vista));
      } else {
        final veces = serie == 'web' ? 60 : 30;
        for (var i = 1; i <= veces; i++) {
          for (var r = 0; r < (serie == 'web' ? 1 : 3); r++) {
            GestureBinding.instance.handlePointerEvent(PointerScaleEvent(
                position: global,
                scale: serie == 'web' ? 1.01 : 1.005,
                viewId: vista));
          }
          await dosCuadros('paso $i');
        }
      }
      await _asentar();
      mirar('asentado');
      resultados[serie] = {
        'peor_desvio_dp': double.parse(peor.toStringAsFixed(3)),
        'donde': donde,
        'medidas': medidas,
        'cruzo_de_caber_a_no_caber': cruzo,
        'zoom_final': c.read(planZoomProvider),
      };
      await _registrar('pellizco', {
        'serie': serie,
        ...resultados[serie]! as Map<String, Object?>,
      });
      await _capturar('1366x690_claro', 'pellizco_${serie}_despues');
    }
    await _registrar('pellizco-resumen', resultados);
  }

  Element _celdaDelCentro() {
    final lienzo = _buscar((e) => e.widget.key == const ValueKey('plan-zoom-gesture')) ??
        (throw StateError('No está el plano'));
    final centro = _rect(lienzo).center;
    Element? mejor;
    var distancia = double.infinity;
    for (final e in _celdas()) {
      final d = (_rect(e).center - centro).distance;
      if (d < distancia) {
        distancia = d;
        mejor = e;
      }
    }
    return mejor ?? (throw StateError('No hay celdas'));
  }

  Element _celdaDeAbajo() {
    final columna = _buscar((e) => e.widget.key == const ValueKey('columna-del-plano')) ??
        (throw StateError('No está la columna'));
    final vista = _rect(columna);
    Element? mejor;
    var y = double.negativeInfinity;
    for (final e in _celdas()) {
      final r = _rect(e);
      if (r.center.dy < vista.bottom - 40 && r.center.dy > vista.top && r.center.dy > y) {
        y = r.center.dy;
        mejor = e;
      }
    }
    return mejor ?? (throw StateError('No hay celdas abajo'));
  }

  List<Element> _celdas() {
    final todas = _todos((e) {
      final k = e.widget.key;
      return k is ValueKey<String> && k.value.startsWith('cell-') && _visible(e);
    });
    // Solo las que salen una vez (la rejilla de la bahía elegida).
    final cuenta = <Key, int>{};
    for (final e in todas) {
      cuenta[e.widget.key!] = (cuenta[e.widget.key!] ?? 0) + 1;
    }
    return todas.where((e) => cuenta[e.widget.key!] == 1).toList();
  }

  // --- foco -------------------------------------------------------------

  Future<void> _foco() async {
    _tamano.value = const Size(1366, 690);
    await _ir(DestinoDelViaje.plano);
    final c = _riverpod();
    final celda = _celdaDelCentro();
    final global = _aGlobal(_centroEnElLienzo(celda));
    final vista = _vista();
    final puntero = _puntero++;
    GestureBinding.instance.handlePointerEvent(PointerPanZoomStartEvent(
        pointer: puntero, position: global, viewId: vista));
    GestureBinding.instance.handlePointerEvent(PointerPanZoomUpdateEvent(
        pointer: puntero, position: global, scale: 1.2, viewId: vista));
    await _asentar();
    final antes = c.read(pellizcoDelPlanoProvider);
    final cicloAntes = _ciclo.length;
    await _registrar('esperando-foco', {'pellizco_abierto': antes, 'zoom': c.read(planZoomProvider)});
    final limite = DateTime.now().add(const Duration(seconds: 90));
    while (DateTime.now().isBefore(limite)) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      final nuevos = _ciclo.skip(cicloAntes).toList();
      if (nuevos.any((s) => s != 'resumed') && nuevos.isNotEmpty && nuevos.last == 'resumed') {
        break;
      }
    }
    await _asentar();
    final despues = c.read(pellizcoDelPlanoProvider);
    // La rueda sobre la rejilla: ¿mueve la columna?
    final columna = Scrollable.of(_celdaDelCentro(), axis: Axis.vertical).position;
    final y0 = columna.pixels;
    GestureBinding.instance.handlePointerEvent(PointerScrollEvent(
        position: global, scrollDelta: const Offset(0, 100), viewId: vista));
    await _asentar();
    await _registrar('foco', {
      'ciclo_de_vida_durante_la_espera': _ciclo.skip(cicloAntes).toList(),
      'pellizco_abierto_antes': antes,
      'pellizco_abierto_despues': despues,
      'la_rueda_movio_la_columna': columna.pixels != y0,
      'columna': [y0, columna.pixels],
      'zoom': c.read(planZoomProvider),
    });
    await _capturar('1366x690_claro', 'foco_despues');
  }

  // --- mano -------------------------------------------------------------

  Future<void> _mano() async {
    await _ir(DestinoDelViaje.plano);
    final c = _riverpod();
    final gestos = <Map<String, Object?>>[];
    Map<String, Object?>? gesto;
    Offset? foco;
    Element? celda;
    Offset? antes;
    var escalaAntes = 1.0;
    DateTime ultimo = DateTime.now();

    void empezar(Offset posicionGlobal, String tipo) {
      final enLienzo = _deGlobal(posicionGlobal);
      Element? masCerca;
      var d = double.infinity;
      for (final e in _celdas()) {
        final dist = (_centroEnElLienzo(e) - enLienzo).distance;
        if (dist < d) {
          d = dist;
          masCerca = e;
        }
      }
      celda = masCerca;
      foco = enLienzo;
      antes = celda == null ? null : _centroEnElLienzo(celda!);
      escalaAntes = c.read(planZoomProvider);
      gesto = {
        'tipo': tipo,
        'desde': escalaAntes,
        'peor_desvio_dp': 0.0,
        'donde': '',
        'cuadros': 0,
        'cruzo': false,
      };
      gestos.add(gesto!);
    }

    GestureBinding.instance.pointerRouter.addGlobalRoute((evento) {
      if (evento is PointerPanZoomStartEvent) {
        empezar(evento.position, 'touchpad');
      } else if (evento is PointerScaleEvent &&
          (gesto == null || DateTime.now().difference(ultimo).inMilliseconds > 400)) {
        empezar(evento.position, 'pellizco de la Web o Ctrl + rueda');
      }
      if (evento is PointerPanZoomUpdateEvent || evento is PointerScaleEvent) {
        ultimo = DateTime.now();
      }
    });
    SchedulerBinding.instance.addPersistentFrameCallback((_) {
      final g = gesto;
      final e = celda;
      if (g == null || e == null || !e.mounted || foco == null || antes == null) return;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!e.mounted) return;
        final escala = c.read(planZoomProvider);
        if (escala == escalaAntes) return;
        final ahora = _centroEnElLienzo(e);
        final esperado = foco! + (antes! - foco!) * (escala / escalaAntes);
        final rejilla = Scrollable.of(e, axis: Axis.horizontal).position;
        final col = Scrollable.of(e, axis: Axis.vertical).position;
        bool tope(ScrollPosition p) =>
            p.pixels <= p.minScrollExtent + 0.01 || p.pixels >= p.maxScrollExtent - 0.01;
        var d = 0.0;
        var eje = '';
        if (rejilla.maxScrollExtent > 0) {
          g['cruzo'] = true;
          if (!tope(rejilla)) {
            d = (ahora.dx - esperado.dx).abs();
            eje = 'horizontal';
          }
        }
        if (!tope(col) && (ahora.dy - esperado.dy).abs() > d) {
          d = (ahora.dy - esperado.dy).abs();
          eje = 'vertical';
        }
        g['cuadros'] = (g['cuadros']! as int) + 1;
        g['hasta'] = escala;
        if (d > (g['peor_desvio_dp']! as double)) {
          g['peor_desvio_dp'] = double.parse(d.toStringAsFixed(3));
          g['donde'] = 'a ${escala.toStringAsFixed(3)}, $eje';
        }
        antes = ahora;
        escalaAntes = escala;
      });
    });
    await _registrar('mano-lista', {
      'tope_s': int.parse(_p('tope', '240')),
      'zoom': c.read(planZoomProvider),
    });
    final fin = DateTime.now().add(Duration(seconds: int.parse(_p('tope', '240'))));
    var anotados = 0;
    while (DateTime.now().isBefore(fin)) {
      await Future<void>.delayed(const Duration(seconds: 1));
      // Un gesto terminado (sin eventos hace más de un segundo) se anota.
      if (gestos.length > anotados &&
          DateTime.now().difference(ultimo).inMilliseconds > 1000) {
        for (final g in gestos.skip(anotados)) {
          await _registrar('gesto', g);
        }
        anotados = gestos.length;
      }
    }
    await _registrar('mano', {'gestos': gestos});
  }

  // --- parpadeo y selector (corrección 1 de la entrega 2) ----------------

  /// D4: el toque de la barra, sin capturar por dentro. Anota la hora de
  /// cada toque, para buscarlo en la grabación de la ventana.
  Future<void> _parpadeoSinCaptura() async {
    final toques = int.parse(_p('toques', '6'));
    for (var i = 1; i <= toques; i++) {
      _sinFiltros();
      await _ir(DestinoDelViaje.estadisticas);
      await _alaVista('estadisticas-puertos');
      await Scrollable.ensureVisible(_barraDe('PAMIT'),
          alignment: 0.5, duration: Duration.zero);
      await _asentar();
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      await _registrar('toque', {'n': i});
      await _tocar(_barraDe('PAMIT'));
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      await _registrar('tras-el-toque', {'n': i, ..._dondeQuedaLaLista()});
    }
  }

  /// D2 y D3: los rectángulos de los segmentos del selector, en la ventana.
  Future<void> _selector() async {
    await _ir(DestinoDelViaje.plano);
    await _asentar();
    final segmentos = <Map<String, Object?>>[];
    for (final boton in _todos((e) => e.widget is SegmentedButton)) {
      final caja = boton.renderObject;
      if (caja is! RenderBox || !caja.hasSize) continue;
      void visitar(Element e) {
        final w = e.widget;
        if (w is Tooltip && e.renderObject is RenderBox) {
          final r = e.renderObject! as RenderBox;
          final global = r.localToGlobal(Offset.zero) & r.size;
          segmentos.add({
            'mensaje': w.message,
            'que': w.child is Icon ? 'icono' : 'rotulo',
            'rect': [global.left, global.top, global.width, global.height],
          });
        }
        if (w.runtimeType.toString().startsWith('_SegmentButton') ||
            w is TextButton) {
          final r = e.renderObject;
          if (r is RenderBox && r.hasSize) {
            final global = r.localToGlobal(Offset.zero) & r.size;
            segmentos.add({
              'que': 'segmento',
              'rect': [global.left, global.top, global.width, global.height],
            });
          }
        }
        e.visitChildren(visitar);
      }

      boton.visitChildren(visitar);
    }
    await _registrar('selector-listo', {'segmentos': segmentos});
    await Future<void>.delayed(Duration(seconds: int.parse(_p('tope', '90'))));
  }

  // --- monitores --------------------------------------------------------

  Future<void> _monitores() async {
    final c = _riverpod();
    await _ir(DestinoDelViaje.plano);
    c.read(planZoomProvider.notifier).fijar(1.5);
    await _asentar();
    final celda = _celdaDelCentro();
    final rejilla = Scrollable.of(celda, axis: Axis.horizontal).position;
    rejilla.jumpTo(rejilla.maxScrollExtent / 2);
    final columna = Scrollable.of(celda, axis: Axis.vertical).position;
    columna.jumpTo(math.min(200, columna.maxScrollExtent));
    await _asentar();
    var ultima = '';
    Future<void> anotar(String porQue) async {
      final vista = WidgetsBinding.instance.platformDispatcher.implicitView!;
      final ahora = '${vista.physicalSize.width.round()}x'
          '${vista.physicalSize.height.round()}@${vista.devicePixelRatio}';
      if (ahora == ultima && porQue == 'cambio') return;
      ultima = ahora;
      final e = _buscar((e) => e.widget.key == const ValueKey('plan-zoom-gesture'));
      Map<String, Object?> desplazamientos = {};
      if (e != null) {
        final celdas = _celdas();
        if (celdas.isNotEmpty) {
          desplazamientos = {
            'rejilla': Scrollable.of(celdas.first, axis: Axis.horizontal).position.pixels,
            'columna': Scrollable.of(celdas.first, axis: Axis.vertical).position.pixels,
          };
        }
      }
      await _registrar('ventana', {
        'por': porQue,
        'fisico': ahora,
        'logico': '${_ventana().width.round()}x${_ventana().height.round()}',
        'zoom': c.read(planZoomProvider),
        'bahia': c.read(selectedBayProvider),
        'pestana': c.read(destinoDelViajeProvider).name,
        ...desplazamientos,
        'errores_de_flutter': [..._errores],
      });
      _errores.clear();
    }

    await anotar('inicio');
    await _registrar('monitores-listo', {});
    // Cada cambio de la ventana, sondeado: la app sigue siendo de Carlos.
    while (true) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      await anotar('cambio');
    }
  }

  // --- piezas -------------------------------------------------------------

  Future<void> _cargar(String nombre) async {
    final n = _riverpod().read(voyageNotifierProvider.notifier);
    final texto = latin1.decode(await leerDelCaso(nombre));
    var r = await n.parseBaplieContent(texto, fileName: nombre);
    if (!r.success) throw StateError(r.errorMessage ?? 'No abrió $nombre');
    if (r.needsIdentity) {
      r = await n.resolveIdentity(n.identityCandidates.first);
      if (!r.success) throw StateError(r.errorMessage ?? 'Identidad sin resolver');
    }
    await _asentar();
    final pendiente = n.pendingVoyage;
    if (pendiente != null) {
      final perfil = n.currentProfile ?? VesselProfile.proposeFrom(pendiente);
      final propuesta =
          VesselProfile.proposeFrom(pendiente, parameters: perfil.geometry).geometry;
      final geometria = perfil.origin != VesselProfileOrigin.proposedFromFile &&
              perfil.geometry.coversAll(pendiente.stowagePositions)
          ? perfil.geometry
          : propuesta;
      final puerto = pendiente.suggestPortOfCall(n.lastConfirmedPortOfCall) ??
          pendiente.portOfOrigin;
      final tipo = puerto != null && OperationSources.baplieKind(pendiente, puerto) == null
          ? OperationSourceKind.loadingBaplie
          : null;
      final error = await n.confirmGeometry(geometria, portOfCall: puerto, sourceKind: tipo);
      if (error != null) throw StateError(error);
    }
    await _asentar();
    await _registrar('cargado', {
      'archivo': nombre,
      'contenedores': _riverpod().read(voyageNotifierProvider).value?.totalContainers,
    });
  }

  void _sinFiltros() {
    final c = _riverpod();
    c.read(selectedCarrierProvider.notifier).clear();
    c.read(selectedDischargePortProvider.notifier).clear();
    c.read(selectedSpecialCargoProvider.notifier).clear();
  }

  Future<void> _ir(DestinoDelViaje destino) async {
    _riverpod().read(destinoDelViajeProvider.notifier).ir(destino);
    await _asentar();
  }

  ProviderContainer _riverpod() {
    final e = _buscar((e) => e.widget is BayStreamApp, soloVisibles: false);
    if (e == null) throw StateError('No se encontró la app');
    return ProviderScope.containerOf(e);
  }

  ScrollPosition _scrollDeLaLista() {
    final e = _buscar((e) => e.widget.key == const ValueKey('lista-scroll')) ??
        (throw StateError('No está la Lista'));
    Element? scrollable;
    void visitar(Element h) {
      if (scrollable != null) return;
      if (h.widget is Scrollable) {
        scrollable = h;
        return;
      }
      h.visitChildren(visitar);
    }

    e.visitChildren(visitar);
    return ((scrollable! as StatefulElement).state as ScrollableState).position;
  }

  Element? _buscar(bool Function(Element e) cumple, {bool soloVisibles = true}) {
    Element? hallado;
    void visitar(Element e) {
      if (hallado != null) return;
      if (cumple(e) && (!soloVisibles || _visible(e))) {
        hallado = e;
        return;
      }
      e.visitChildren(visitar);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(visitar);
    return hallado;
  }

  List<Element> _todos(bool Function(Element e) cumple) {
    final todos = <Element>[];
    void visitar(Element e) {
      if (cumple(e)) todos.add(e);
      e.visitChildren(visitar);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(visitar);
    return todos;
  }

  bool _visible(Element e) {
    final r = e.renderObject;
    if (r is! RenderBox || !r.attached || !r.hasSize || r.size.isEmpty) {
      return false;
    }
    RenderObject hijo = r;
    var padre = r.parent;
    while (padre != null) {
      if (padre is RenderBsFichasEnLineas) {
        final datos = hijo.parentData;
        return datos is! DatosDeLaFicha || datos.visible;
      }
      hijo = padre;
      padre = padre.parent;
    }
    return true;
  }

  RenderBox get _cajaDelLienzo =>
      _lienzo.currentContext!.findRenderObject()! as RenderBox;

  /// El rectángulo de [e] en el lienzo (los dp de la app, sin el
  /// `FittedBox` de la ventana).
  Rect _rect(Element e) {
    final caja = e.renderObject! as RenderBox;
    final arriba = caja.localToGlobal(Offset.zero, ancestor: _cajaDelLienzo);
    return arriba & caja.size;
  }

  Offset _centroEnElLienzo(Element e) => _rect(e).center;

  Offset _aGlobal(Offset enLienzo) => _cajaDelLienzo.localToGlobal(enLienzo);

  Offset _deGlobal(Offset global) => _cajaDelLienzo.globalToLocal(global);

  Size _ventana() => _cajaDelLienzo.size;

  int _vista() => WidgetsBinding.instance.platformDispatcher.implicitView!.viewId;

  List<String> _textosDe(Element e) {
    final textos = <String>[];
    void visitar(Element h) {
      final w = h.widget;
      if (w is Text) {
        final t = w.data ?? w.textSpan?.toPlainText();
        if (t != null && t.isNotEmpty) textos.add(t);
      }
      h.visitChildren(visitar);
    }

    visitar(e);
    return textos;
  }

  Element _conClave(String clave) =>
      _buscar((e) => e.widget.key == ValueKey<String>(clave)) ??
      (throw StateError('No está a la vista: $clave'));

  Element _barraDe(String codigo) =>
      _buscar((e) =>
          e.widget is Semantics &&
          ((e.widget as Semantics).properties.label ?? '').startsWith('$codigo:') &&
          (e.widget as Semantics).properties.button == true) ??
      (throw StateError('No está a la vista: la barra de $codigo'));

  Future<void> _alaVista(String clave) async {
    await Scrollable.ensureVisible(_conClave(clave), duration: Duration.zero);
    await _asentar();
  }

  /// Toca el centro de [e], después de comprobar que nada lo tapa.
  Future<void> _tocar(Element e) async {
    final caja = e.renderObject! as RenderBox;
    final centro = caja.localToGlobal(caja.size.center(Offset.zero));
    final vista = _vista();
    final prueba = HitTestResult();
    WidgetsBinding.instance.hitTestInView(prueba, centro, vista);
    if (!prueba.path.any((entrada) => entrada.target == caja)) {
      throw StateError('Algo tapa ${e.widget.runtimeType} en $centro');
    }
    final puntero = _puntero++;
    GestureBinding.instance.handlePointerEvent(
        PointerDownEvent(pointer: puntero, position: centro, viewId: vista));
    await Future<void>.delayed(const Duration(milliseconds: 60));
    GestureBinding.instance.handlePointerEvent(
        PointerUpEvent(pointer: puntero, position: centro, viewId: vista));
  }

  Future<void> _siguienteCuadro() {
    final listo = Completer<void>();
    SchedulerBinding.instance
      ..addPostFrameCallback((_) => listo.complete())
      ..scheduleFrame();
    return listo.future;
  }

  Future<void> _capturar(String sufijo, String pantalla,
          [Map<String, Object?> datos = const {}]) =>
      _capturarCon(sufijo, pantalla, datos);

  Future<void> _capturarCon(String sufijo, String pantalla,
      Map<String, Object?> datos, {bool asentar = true}) async {
    if (asentar) await _asentar();
    final caja = _lienzo.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final imagen = await caja.toImage(pixelRatio: 1);
    final png = await imagen.toByteData(format: ui.ImageByteFormat.png);
    imagen.dispose();
    final nombre = '${sufijo}_$pantalla.png';
    await guardarCaptura(nombre, png!.buffer.asUint8List());
    final truncados = <String>[];
    void visitar(RenderObject r) {
      if (r is RenderParagraph && r.didExceedMaxLines) {
        truncados.add(r.text.toPlainText());
      }
      r.visitChildren(visitar);
    }

    visitar(caja);
    await _registrar('captura', {
      'archivo': nombre,
      'logico': '${caja.size.width.round()}x${caja.size.height.round()}',
      ...datos,
      'textos_que_no_caben': truncados,
      'errores_de_flutter': [..._errores],
    });
    _errores.clear();
  }

  Future<void> _asentar() async {
    final limite = Stopwatch()..start();
    do {
      await _siguienteCuadro();
    } while (SchedulerBinding.instance.hasScheduledFrame &&
        limite.elapsedMilliseconds < 20000);
  }

  Future<void> _registrar(String paso, Map<String, Object?> datos) async {
    final ahora = DateTime.now().toUtc().toIso8601String();
    debugPrint('T120E2 PASO $paso $ahora');
    await registrarLinea(jsonEncode({'paso': paso, 'ts': ahora, ...datos}));
  }
}
