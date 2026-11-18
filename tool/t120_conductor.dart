// T-120, corrección 1 (R4, 10.149) · Conductor del banco para MIRAR lo que
// trae la Lista y el buscador con el buque de las pruebas (BUQUE LISTA,
// `tool/t120_buque.dart`): lo que `T99_SINTETICO_977.edi` y el corpus no
// traen. Recorre la interfaz real del producto en release y, por tema, tamaño
// y letra, guarda una captura PNG de cada estado:
//   1. las tres filas con un destino elegido y con una carga elegida;
//   2. «Ver los n destinos» y su hoja; la hoja cerrada sin elegir; un destino
//      chico elegido, a la vista (solo en el teléfono, donde está «Ver»);
//   3. «Sin destino» en la Lista; Estadísticas con «Otros N puertos» y la
//      tabla, donde están todos; de una barra a la Lista (D9);
//   4. la tarjeta y la hoja de un fuera de medida;
//   5. el buscador con «oog», «imo 3», «reefer imo» y «reefer GTSTC».
// Cada captura anota los textos que no caben y los errores de Flutter. No
// toca nada que una persona no tocaría: elige con los chips, abre con los
// botones y escribe en el campo; solo lleva lo elegido a la vista.
//
// Se configura con variables de entorno al arrancar (como el conductor de
// T-99): T120_ARCHIVO (el asset de t99_inputs/), T120_CAPTURAS (carpeta en
// %TEMP%), T120_PASOS (registro), T120_TAMANOS («1366x690,360x800»),
// T120_TEMAS («claro,oscuro») y T120_LETRAS_TELEFONO («1.0,2.0»).
import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:baystream/core/app.dart';
import 'package:baystream/core/design/design.dart';
import 'package:baystream/features/vessel/domain/entities/app_theme_preference.dart';
import 'package:baystream/features/vessel/presentation/providers/theme_preference_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/navegacion_del_viaje.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 't99_app.dart';
import 't99_plataforma.dart';

String _entorno(String nombre, [String porOmision = '']) {
  final v = variableDeEntorno(nombre);
  return v.isEmpty ? porOmision : v;
}

/// El conductor, o `null` si no se pidió (sin T120_ARCHIVO).
T120Conductor? t120ConductorDelEntorno() {
  final archivo = _entorno('T120_ARCHIVO');
  return archivo.isEmpty ? null : T120Conductor(archivo);
}

class T120Conductor {
  T120Conductor(this.archivo);

  final String archivo;
  final _capturas = _entorno('T120_CAPTURAS');
  final _pasos = _entorno('T120_PASOS');
  final _tamanos = _entorno('T120_TAMANOS', '1366x690,360x800');
  final _temas = _entorno('T120_TEMAS', 'claro,oscuro');
  final _letrasTelefono = _entorno('T120_LETRAS_TELEFONO', '1.0,2.0');

  final _tamano = ValueNotifier<Size?>(null);
  final _letra = ValueNotifier<double>(1.0);
  final _lienzo = GlobalKey();
  final _errores = <String>[];
  var _puntero = 12000;

  /// Para `BayStreamApp.builder`: impone el tamaño lógico y la letra, reduce
  /// el movimiento y deja un `RepaintBoundary` para la captura.
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
                    key: _lienzo, child: MediaQuery(data: datos, child: child!));
                if (tamano == null) return lienzo;
                return ColoredBox(
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    child: FittedBox(
                        child: SizedBox.fromSize(size: tamano, child: lienzo)));
              }));

  void iniciar() {
    final anterior = FlutterError.onError;
    FlutterError.onError = (detalles) {
      _errores.add(detalles.exceptionAsString().split('\n').first);
      anterior?.call(detalles);
    };
    SchedulerBinding.instance.addPostFrameCallback((_) => unawaited(_ejecutar()));
  }

  Future<void> _ejecutar() async {
    try {
      await _asentar();
      await _registrar('inicio', {'archivo': archivo});
      await _cargar();
      final contenedor = _riverpod();
      for (final tema in _temas.split(',').map((t) => t.trim())) {
        await contenedor.read(themePreferenceProvider.notifier).select(
            tema == 'claro' ? AppThemePreference.light : AppThemePreference.dark);
        for (final especificacion in _tamanos.split(',').map((s) => s.trim())) {
          final partes = especificacion.split('x');
          final tamano = Size(double.parse(partes[0]), double.parse(partes[1]));
          final telefono = tamano.width < AnchosDeNavegacion.riel;
          final letras = telefono
              ? _letrasTelefono.split(',').map((s) => double.parse(s.trim()))
              : const <double>[1.0];
          for (final letra in letras) {
            _tamano.value = tamano;
            _letra.value = letra;
            await _asentar();
            await _recorrido('${especificacion}_${tema}_letra$letra', telefono);
          }
        }
      }
      _tamano.value = null;
      _letra.value = 1.0;
      await _registrar('fin', {});
    } catch (error, pila) {
      await _registrar('error', {
        'detalle': '$error',
        'pila': pila.toString().split('\n').take(6).join(' | '),
      });
    }
  }

  // --- El recorrido -----------------------------------------------------

  Future<void> _recorrido(String sufijo, bool telefono) async {
    final c = _riverpod();
    await _ir(DestinoDelViaje.lista);
    _sinFiltros();
    await _asentar();

    // 1. Un destino elegido, con el chip (en el teléfono, desde la hoja si
    // no está entre los que caben); después una carga.
    await _elegirDestino('PAMIT');
    await _alaVista('filtros-de-la-lista');
    await _capturar(sufijo, '1a_destino_elegido');
    _sinFiltros();
    await _asentar();
    await _elegir('carga', 'refrigerado');
    await _alaVista('filtros-de-la-lista');
    await _capturar(sufijo, '1b_carga_elegida');
    _sinFiltros();
    await _asentar();

    // 2. «Ver los n destinos» y su hoja (solo en el teléfono).
    if (telefono) {
      await _alaVista('filtros-de-la-lista');
      await _capturar(sufijo, '2a_ver_los_n_destinos');
      await _tocarALaVista(() => _conClave('filtro-destino-ver-todas'));
      await _capturar(sufijo, '2b_hoja_de_destinos');
      await _volver();
      await _capturar(sufijo, '2c_hoja_cerrada_sin_elegir');
      await _tocarALaVista(() => _conClave('filtro-destino-ver-todas'));
      await _tocarALaVista(() => _conClave('hoja-filtro-destino-JMKCT'));
      await _alaVista('filtros-de-la-lista');
      await _capturar(sufijo, '2d_destino_chico_a_la_vista');
      _sinFiltros();
      await _asentar();
    }

    // 3. «Sin destino» en la Lista, y Estadísticas.
    await _elegirDestino('sin-destino');
    await _alaVista('titulo-de-la-lista');
    await _capturar(sufijo, '3a_sin_destino_en_la_lista');
    _sinFiltros();
    await _ir(DestinoDelViaje.estadisticas);
    await _alaVista('estadisticas-puertos');
    await _capturar(sufijo, '3b_estadisticas_otros_puertos');
    await _tocarALaVista(() => _conClave('estadisticas-ver-tabla'));
    await _alaVistaTexto('Sin destino');
    await _capturar(sufijo, '3c_estadisticas_tabla_sin_destino');
    await _tocarALaVista(() => _conClave('estadisticas-ver-tabla'));
    await _alaVista('estadisticas-puertos');
    await _tocarALaVista(() => _barraDe('PAMIT'));
    await _capturar(sufijo, '3d_de_la_barra_a_la_lista_D9');
    _sinFiltros();
    await _asentar();

    // 4. La tarjeta y la hoja de un fuera de medida.
    await _ir(DestinoDelViaje.lista);
    await _elegir('carga', 'fueraDeMedida');
    await _alaVista('titulo-de-la-lista');
    await _capturar(sufijo, '4a_tarjeta_fuera_de_medida');
    await _tocarALaVista(() => _primeraTarjeta());
    await _capturar(sufijo, '4b_hoja_fuera_de_medida');
    // El renglón de las medidas queda bajo el pliegue de la hoja.
    await _alaVistaUltimoTexto('Fuera de medida');
    await _capturar(sufijo, '4c_hoja_fuera_de_medida_medidas');
    await _volver();
    _sinFiltros();
    await _asentar();

    // 5. El buscador.
    for (final consulta in ['oog', 'imo 3', 'reefer imo', 'reefer GTSTC']) {
      await _tocar(_conTooltip('Buscar contenedor'));
      await _asentar();
      final campo = _buscar((e) => e.widget is EditableText);
      if (campo == null) throw StateError('No apareció el campo de búsqueda');
      ((campo as StatefulElement).state as EditableTextState).updateEditingValue(
          TextEditingValue(
              text: consulta,
              selection: TextSelection.collapsed(offset: consulta.length)));
      await _asentar();
      await _capturar(sufijo, '5_buscar_${consulta.replaceAll(' ', '_')}');
      await _volver();
    }
    c.read(highlightedContainerProvider.notifier).clear();
  }

  // --- Piezas -----------------------------------------------------------

  Future<void> _cargar() async {
    final datos = await rootBundle.load('t99_inputs/$archivo');
    final texto = utf8.decode(datos.buffer.asUint8List(), allowMalformed: true);
    final error = await t99Publicar(
        _riverpod().read(voyageNotifierProvider.notifier), texto, archivo);
    if (error != null) throw StateError(error);
    await _asentar();
  }

  /// Elige [clave] de la fila [fila] con su chip; si no está entre los que
  /// caben (el teléfono), desde la hoja de «Ver los n».
  Future<void> _elegir(String fila, String clave) async {
    final chip = _buscar((e) => e.widget.key == ValueKey<String>('filtro-$fila-$clave'));
    if (chip != null) {
      await _tocarALaVista(() => _conClave('filtro-$fila-$clave'));
      return;
    }
    await _tocarALaVista(() => _conClave('filtro-$fila-ver-todas'));
    await _tocarALaVista(() => _conClave('hoja-filtro-$fila-$clave'));
  }

  Future<void> _elegirDestino(String clave) => _elegir('destino', clave);

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
    final e = _buscar((e) => e.widget is BayStreamApp);
    if (e == null) throw StateError('No se encontró la app');
    return ProviderScope.containerOf(e);
  }

  Element? _buscar(bool Function(Element e) cumple) {
    Element? hallado;
    void visitar(Element e) {
      if (hallado != null) return;
      if (cumple(e) && _visible(e)) {
        hallado = e;
        return;
      }
      e.visitChildren(visitar);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(visitar);
    return hallado;
  }

  bool _visible(Element e) {
    final r = e.renderObject;
    if (r is! RenderBox || !r.attached || !r.hasSize || r.size.isEmpty) {
      return false;
    }
    // Una ficha que BsFichasEnLineas no enseña tiene tamaño, pero no se ve.
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

  Element _conClave(String clave) =>
      _buscar((e) => e.widget.key == ValueKey<String>(clave)) ??
      (throw StateError('No está a la vista: $clave'));

  Element _conTooltip(String mensaje) =>
      _buscar((e) => e.widget is Tooltip && (e.widget as Tooltip).message == mensaje) ??
      (throw StateError('No está a la vista: el botón $mensaje'));

  Element _barraDe(String codigo) =>
      _buscar((e) =>
          e.widget is Semantics &&
          ((e.widget as Semantics).properties.label ?? '').startsWith('$codigo:') &&
          (e.widget as Semantics).properties.button == true) ??
      (throw StateError('No está a la vista: la barra de $codigo'));

  Element _primeraTarjeta() =>
      _buscar((e) {
        final k = e.widget.key;
        return k is ValueKey<String> && k.value.startsWith('tarjeta-');
      }) ??
      (throw StateError('No está a la vista: una tarjeta'));

  Future<void> _alaVista(String clave) async {
    await Scrollable.ensureVisible(_conClave(clave), duration: Duration.zero);
    await _asentar();
  }

  Future<void> _alaVistaTexto(String texto) async {
    final e = _buscar((e) => e.widget is Text && (e.widget as Text).data == texto);
    if (e != null) {
      await Scrollable.ensureVisible(e, alignment: 0.3, duration: Duration.zero);
      await _asentar();
    }
  }

  /// Lleva a la vista el último [texto] del árbol (el de la hoja abierta).
  Future<void> _alaVistaUltimoTexto(String texto) async {
    Element? ultimo;
    void visitar(Element e) {
      if (e.widget is Text && (e.widget as Text).data == texto && _visible(e)) {
        ultimo = e;
      }
      e.visitChildren(visitar);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(visitar);
    if (ultimo != null) {
      await Scrollable.ensureVisible(ultimo!, alignment: 0.5, duration: Duration.zero);
      await _asentar();
    }
  }

  Future<void> _tocarALaVista(Element Function() buscar) async {
    await Scrollable.ensureVisible(buscar(), alignment: 0.5, duration: Duration.zero);
    await _asentar();
    await _tocar(buscar());
    await _asentar();
  }

  Future<void> _volver() async {
    final e = _buscar((e) => e.widget is Navigator);
    await ((e! as StatefulElement).state as NavigatorState).maybePop();
    await _asentar();
  }

  /// Toca el centro de [e], después de comprobar que nada lo tapa.
  Future<void> _tocar(Element e) async {
    final caja = e.renderObject! as RenderBox;
    final centro = caja.localToGlobal(caja.size.center(Offset.zero));
    final vista = WidgetsBinding.instance.platformDispatcher.implicitView!.viewId;
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

  Future<void> _capturar(String sufijo, String pantalla) async {
    await _asentar();
    final caja = _lienzo.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final imagen = await caja.toImage(pixelRatio: 1);
    final png = await imagen.toByteData(format: ui.ImageByteFormat.png);
    imagen.dispose();
    final nombre = '${sufijo}_$pantalla.png';
    await guardarBytes(_capturas, nombre, png!.buffer.asUint8List());
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
      'textos_que_no_caben': truncados,
      'errores_de_flutter': [..._errores],
    });
    _errores.clear();
  }

  Future<void> _asentar() async {
    final limite = Stopwatch()..start();
    do {
      final listo = Completer<void>();
      SchedulerBinding.instance
        ..addPostFrameCallback((_) => listo.complete())
        ..scheduleFrame();
      await listo.future;
    } while (SchedulerBinding.instance.hasScheduledFrame &&
        limite.elapsedMilliseconds < 20000);
  }

  Future<void> _registrar(String paso, Map<String, Object?> datos) async {
    final ahora = DateTime.now().toUtc().toIso8601String();
    debugPrint('T120 PASO $paso $ahora');
    await anexarLinea(_pasos, jsonEncode({'paso': paso, 'ts': ahora, ...datos}));
  }
}
