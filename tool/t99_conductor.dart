// T-99 · Conductor del banco: recorre la interfaz real del producto en
// release, sin flutter_test, tocando como lo haría una persona.
//
// Escenarios (`--dart-define=T99_ESCENARIO=…`):
//   - `ram`: el escenario fijo de T-63 (1, «Operación normal») para medir la
//     RAM desde fuera: cargar, Plano, todas las bahías, Estadísticas,
//     buscar un ID y volver a Lista. Tras cada paso anuncia «T99 PASO <paso>»
//     (consola y logcat; en Windows también T99_PASOS) y espera T99_PAUSA_MS
//     sin tocar nada, para que el muestreador tome sus cinco lecturas.
//   - `anchos`: RNF-003 (3.3 a). Para cada tamaño de T99_ANCHOS impone ese
//     tamaño lógico a la app, recorre Lista, Plano, Estadísticas y la
//     búsqueda, y guarda una captura PNG de cada pantalla con lo que encontró:
//     textos que no caben (RenderParagraph.didExceedMaxLines), desplazables
//     horizontales con contenido oculto y errores de Flutter. Los desbordes
//     de RenderFlex solo se informan en debug; en release los ve la persona.
//   - `inicio` (Fase 3 de T-114, 10.9): capturas del inicio y del previo a
//     cada tamaño de T99_ANCHOS, en claro y en oscuro y con la letra a cada
//     escala de T99_LETRAS. Antes publica T99_ARCHIVO_PUBLICADO (un plan de
//     carga) y lo cierra, para que el inicio tenga un reciente, y deja el
//     historial de escala en T99_ESCALA_ANTERIOR, para que el archivo
//     T99_ARCHIVO abra en previo; cada previo se descarta después.
//
// Las definiciones se leen al compilar (--dart-define) y, si faltan, del
// entorno del proceso al arrancar (Windows y Android): el mismo binario sirve
// para medir a mano y para los escenarios.
//
// Carga (`T99_CARGA`): `asset` lee t99_inputs/<T99_ARCHIVO> de la copia de
// compilación (nunca del repositorio) y la publica como t99Publicar;
// `selector` toca «Seleccionar archivo» en el inicio y espera a que una
// persona elija el archivo, que desde el rediseño (10.9, «ver primero,
// confirmar después») ya deja el plano a la vista en previo; si la persona
// además confirma el perfil, el viaje queda publicado. El paso `cargar` anota
// si quedó en previo.
import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:baystream/core/app.dart';
import 'package:baystream/features/vessel/domain/entities/app_theme_preference.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/providers/theme_preference_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 't99_app.dart';
import 't99_plataforma.dart';

String _definicion(String nombre, String compilada, [String porOmision = '']) {
  if (compilada.isNotEmpty) return compilada;
  final entorno = variableDeEntorno(nombre);
  return entorno.isNotEmpty ? entorno : porOmision;
}

final _escenario =
    _definicion('T99_ESCENARIO', const String.fromEnvironment('T99_ESCENARIO'));
final _archivo = _definicion('T99_ARCHIVO', const String.fromEnvironment('T99_ARCHIVO'));
final _archivoPublicado = _definicion(
    'T99_ARCHIVO_PUBLICADO', const String.fromEnvironment('T99_ARCHIVO_PUBLICADO'));
final _escalaAnterior = _definicion(
    'T99_ESCALA_ANTERIOR', const String.fromEnvironment('T99_ESCALA_ANTERIOR'));
final _carga = _definicion('T99_CARGA', const String.fromEnvironment('T99_CARGA'), 'asset');
final _pasos = _definicion('T99_PASOS', const String.fromEnvironment('T99_PASOS'));
final _capturas = _definicion('T99_CAPTURAS', const String.fromEnvironment('T99_CAPTURAS'));
final _pausaMs = int.parse(
    _definicion('T99_PAUSA_MS', const String.fromEnvironment('T99_PAUSA_MS'), '12000'));
final _idBuscado = _definicion('T99_ID', const String.fromEnvironment('T99_ID'));
final _anchos = _definicion('T99_ANCHOS', const String.fromEnvironment('T99_ANCHOS'),
    '360x800,600x960,840x1200,1200x800,2560x1440,real');
final _letras = _definicion(
    'T99_LETRAS', const String.fromEnvironment('T99_LETRAS'), '1.0,1.45,2.0');

// Textos de la interfaz que el conductor toca. T-112 (10.94) cambió «Bay Plan»
// por «Plano» y «BAY nn (» por «BAHÍA nn (»; si vuelven a cambiar, es aquí.
const _pestanaPlano = 'Plano';
String _rotuloDeBahia(int bahia) => 'BAHÍA ${bahia.toString().padLeft(2, '0')} (';

/// El conductor, o `null` si la compilación no pide un escenario.
T99Conductor? conductorDesdeDefiniciones() =>
    _escenario.isEmpty ? null : T99Conductor(_escenario);

class T99Conductor {
  final String escenario;
  T99Conductor(this.escenario);

  final _tamano = ValueNotifier<Size?>(null);
  final _letra = ValueNotifier<double>(1.0);
  final _lienzo = GlobalKey();
  final _errores = <String>[];
  var _puntero = 9900;

  /// Envoltorio para BayStreamApp.builder: en `anchos` impone el tamaño
  /// lógico y deja un RepaintBoundary para la captura.
  Widget envoltorio(BuildContext context, Widget? child) =>
      ValueListenableBuilder<Size?>(
          valueListenable: _tamano,
          builder: (context, tamano, _) => ValueListenableBuilder<double>(
              valueListenable: _letra,
              builder: (context, letra, _) {
                final lienzo = RepaintBoundary(key: _lienzo, child: child);
                final datos = MediaQuery.of(context).copyWith(
                    size: tamano,
                    textScaler: letra == 1.0 ? null : TextScaler.linear(letra));
                if (tamano == null) {
                  return letra == 1.0
                      ? lienzo
                      : MediaQuery(data: datos, child: lienzo);
                }
                return ColoredBox(
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    child: FittedBox(
                        child: SizedBox.fromSize(
                            size: tamano,
                            child: MediaQuery(data: datos, child: lienzo))));
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
      await _registrar('inicio', {'escenario': escenario, 'archivo': _archivo});
      await _pausa();
      switch (escenario) {
        case 'ram':
          await _escenarioRam();
        case 'anchos':
          await _escenarioAnchos();
        case 'inicio':
          await _escenarioInicio();
        default:
          throw StateError('Escenario desconocido: $escenario');
      }
      await _registrar('fin', {});
    } catch (error) {
      await _registrar('error', {'detalle': '$error'});
    }
  }

  // --- Escenario de RAM -------------------------------------------------

  Future<void> _escenarioRam() async {
    await _cargar();
    await _registrar('cargar', {
      'previo': _contenedorRiverpod().read(voyageNotifierProvider.notifier).isPreview,
    });
    await _pausa();

    await _tocar(_pestana(_pestanaPlano));
    await _asentar();
    await _registrar('bay_plan', {});
    await _pausa();

    final bahias = _viaje().bays.keys.toList()..sort();
    final sinChip = <int>[];
    for (final bahia in bahias) {
      final chip = await _chipALaVista(bahia);
      if (chip == null) {
        sinChip.add(bahia);
        continue;
      }
      await Scrollable.ensureVisible(chip, alignment: 0.5);
      await _asentar();
      await _tocar(_chip(bahia));
      await _asentar();
    }
    await _registrar('bahias', {'bahias': bahias.length, 'sin_chip': sinChip});
    await _pausa();

    await _tocar(_pestana('Estadísticas'));
    await _asentar();
    await _registrar('estadisticas', {});
    await _pausa();

    await _buscar();
    await _registrar('buscar', {});
    await _pausa();

    await _tocar(_conTooltip('Volver'));
    await _asentar();
    await _tocar(_pestana('Lista'));
    await _asentar();
    await _registrar('lista', {});
    await _pausa();
  }

  Future<void> _cargar() async {
    final contenedor = _contenedorRiverpod();
    if (_carga == 'selector') {
      await _tocar(_conClave('select-file'));
      final limite = DateTime.now().add(const Duration(minutes: 10));
      while (contenedor.read(voyageNotifierProvider.notifier).visibleVoyage == null) {
        if (DateTime.now().isAfter(limite)) throw StateError('Nadie eligió el archivo');
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
    } else {
      final datos = await rootBundle.load('t99_inputs/$_archivo');
      final texto = String.fromCharCodes(datos.buffer.asUint8List());
      final error = await t99Publicar(
          contenedor.read(voyageNotifierProvider.notifier), texto, _archivo);
      if (error != null) throw StateError(error);
    }
    await _asentar();
  }

  Future<void> _buscar() async {
    await _tocar(_conTooltip('Buscar contenedor'));
    await _asentar();
    final ids = _viaje().containers.map((c) => c.containerId).toList()..sort();
    final id = _idBuscado.isNotEmpty ? _idBuscado : ids[ids.length ~/ 2];
    final campo = _buscarElemento((e) => e.widget is EditableText);
    if (campo == null) throw StateError('No apareció el campo de búsqueda');
    ((campo as StatefulElement).state as EditableTextState).updateEditingValue(
        TextEditingValue(text: id, selection: TextSelection.collapsed(offset: id.length)));
    await _asentar();
  }

  // --- Escenario de anchos ----------------------------------------------

  Future<void> _escenarioAnchos() async {
    await _cargar();
    for (final especificacion in _anchos.split(',').map((s) => s.trim())) {
      final partes = especificacion.split('x');
      _tamano.value = especificacion == 'real'
          ? null
          : Size(double.parse(partes[0]), double.parse(partes[1]));
      await _asentar();
      await _tocar(_pestana('Lista'));
      await _asentar();
      await _capturar(especificacion, 'lista');
      await _tocar(_pestana(_pestanaPlano));
      await _asentar();
      await _capturar(especificacion, 'bay_plan');
      await _tocar(_pestana('Estadísticas'));
      await _asentar();
      await _capturar(especificacion, 'estadisticas');
      await _buscar();
      await _capturar(especificacion, 'busqueda');
      await _tocar(_conTooltip('Volver'));
      await _asentar();
    }
    _tamano.value = null;
  }

  // --- Escenario del inicio (Fase 3 de T-114) ---------------------------

  Future<void> _escenarioInicio() async {
    final contenedor = _contenedorRiverpod();
    final n = contenedor.read(voyageNotifierProvider.notifier);
    // Un reciente en el inicio: el plan publicado como lo haría la oficina.
    if (_archivoPublicado.isNotEmpty) {
      final datos = await rootBundle.load('t99_inputs/$_archivoPublicado');
      final error = await t99Publicar(
          n, String.fromCharCodes(datos.buffer.asUint8List()), _archivoPublicado);
      if (error != null) throw StateError(error);
      await _asentar();
      n.clearVoyage();
      await _asentar();
    }
    // El historial de escala del dispositivo: con otra escala, un plano de
    // llegada propone el puerto de salida y abre en previo (hallazgo 5).
    if (_escalaAnterior.isNotEmpty) {
      final local = await contenedor.read(localVesselRepositoryProvider.future);
      await local.setLastConfirmedPortOfCall(_escalaAnterior);
    }
    final texto = String.fromCharCodes(
        (await rootBundle.load('t99_inputs/$_archivo')).buffer.asUint8List());
    for (final tema in [AppThemePreference.light, AppThemePreference.dark]) {
      await contenedor.read(themePreferenceProvider.notifier).select(tema);
      await _asentar();
      final nombreTema = tema == AppThemePreference.light ? 'claro' : 'oscuro';
      for (final letra in _letras.split(',').map((s) => double.parse(s.trim()))) {
        _letra.value = letra;
        for (final especificacion in _anchos.split(',').map((s) => s.trim())) {
          final partes = especificacion.split('x');
          _tamano.value = especificacion == 'real'
              ? null
              : Size(double.parse(partes[0]), double.parse(partes[1]));
          await _asentar();
          final sufijo = '${especificacion}_${nombreTema}_letra$letra';
          await _capturar(sufijo, 'inicio');
          final r = await n.parseBaplieContent(texto, fileName: _archivo);
          if (!r.success) throw StateError(r.errorMessage ?? 'No abrió $_archivo');
          await _asentar();
          await _capturar(sufijo, r.preview ? 'previo' : 'publicado');
          if (n.isPreview) {
            n.discardPreview();
          } else {
            n.clearVoyage();
          }
          await _asentar();
        }
      }
    }
    _letra.value = 1.0;
    _tamano.value = null;
    await contenedor
        .read(themePreferenceProvider.notifier)
        .select(AppThemePreference.system);
    await _asentar();
  }

  Future<void> _capturar(String tamano, String pantalla) async {
    await _asentar();
    final caja = _lienzo.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final imagen = await caja.toImage(pixelRatio: 1);
    final png = await imagen.toByteData(format: ui.ImageByteFormat.png);
    imagen.dispose();
    final nombre = '${tamano}_$pantalla.png';
    await guardarBytes(_capturas, nombre, png!.buffer.asUint8List());
    final truncados = <String>[];
    void visitar(RenderObject r) {
      if (r is RenderParagraph && r.didExceedMaxLines) {
        truncados.add(r.text.toPlainText());
      }
      r.visitChildren(visitar);
    }

    visitar(caja);
    final horizontales = <Map<String, Object>>[];
    void visitarElementos(Element e) {
      if (e is StatefulElement && e.state is ScrollableState) {
        final s = e.state as ScrollableState;
        if (s.position.axis == Axis.horizontal && s.position.maxScrollExtent > 0.5) {
          horizontales.add({
            'oculto_px': s.position.maxScrollExtent.round(),
            'dentro_de': _pista(e),
          });
        }
      }
      e.visitChildren(visitarElementos);
    }

    _lienzo.currentContext!.visitChildElements(visitarElementos);
    await _registrar('captura', {
      'tamano': tamano,
      'pantalla': pantalla,
      'archivo': nombre,
      'logico': '${caja.size.width.round()}x${caja.size.height.round()}',
      'textos_que_no_caben': truncados,
      'desplazables_horizontales': horizontales,
      'errores_de_flutter': [..._errores],
    });
    _errores.clear();
  }

  /// Qué contiene un desplazable: la rejilla, el selector de bahías u otro.
  /// La vista más cercana nombra el tipo (las páginas de TabBarView y la
  /// barra de pestañas se desplazan por diseño); las claves del plano dicen si
  /// es la rejilla, el selector de bahías o las acciones de la barra.
  String _pista(Element e) {
    String? tipo;
    String? clave;
    var enPestanas = false;
    e.visitAncestorElements((a) {
      final w = a.widget;
      // Nombres escritos a mano: en la Web en release, runtimeType sale
      // minificado.
      tipo ??= switch (w) {
        PageView() => 'páginas de las pestañas',
        SingleChildScrollView() => 'SingleChildScrollView',
        ListView() => 'ListView',
        GridView() => 'GridView',
        CustomScrollView() => 'CustomScrollView',
        ScrollView() => 'ScrollView',
        _ => null,
      };
      if (w is TabBar) enPestanas = true;
      final k = w.key;
      if (k is ValueKey<String>) {
        if (k.value.startsWith('plan-zoom-')) clave = 'rejilla de la bahía';
        if (k.value == 'bay-selector') clave = 'selector de bahías';
        if (k.value == 'plan-toolbar-actions') clave = 'acciones de la barra';
      }
      return clave == null;
    });
    if (clave != null) return clave!;
    if (enPestanas) return 'pestañas';
    return tipo == 'páginas de las pestañas' ? tipo! : 'otro (${tipo ?? 'sin vista'})';
  }

  // --- Interacción ------------------------------------------------------

  ProviderContainer _contenedorRiverpod() {
    final e = _buscarElemento((e) => e.widget is BayStreamApp);
    if (e == null) throw StateError('No se encontró la app');
    return ProviderScope.containerOf(e);
  }

  /// El viaje a la vista: publicado o, con el selector, quizá en previo.
  VesselVoyage _viaje() {
    final v = _contenedorRiverpod().read(voyageNotifierProvider.notifier).visibleVoyage;
    if (v == null) throw StateError('No hay viaje a la vista');
    return v;
  }

  Element? _buscarElemento(bool Function(Element e) cumple) {
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
    return r is RenderBox && r.attached && r.hasSize && !r.size.isEmpty;
  }

  Element _exigir(Element? e, String que) => e ?? (throw StateError('No está a la vista: $que'));

  Element _pestana(String texto) => _exigir(
      _buscarElemento((e) => e.widget is Tab && (e.widget as Tab).text == texto),
      'la pestaña $texto');

  Element _conTooltip(String mensaje) => _exigir(
      _buscarElemento((e) => e.widget is Tooltip && (e.widget as Tooltip).message == mensaje),
      'el botón $mensaje');

  Element _conClave(String clave) => _exigir(
      _buscarElemento((e) => e.widget.key == ValueKey(clave)), 'el control $clave');

  Element? _chipSiHay(int bahia) {
    final rotulo = _rotuloDeBahia(bahia);
    return _buscarElemento((e) =>
        e.widget is Text && ((e.widget as Text).data?.startsWith(rotulo) ?? false));
  }

  Element _chip(int bahia) => _exigir(_chipSiHay(bahia), 'la bahía $bahia');

  /// La lista de chips es perezosa y elegir una bahía la desplaza: si el chip
  /// no está construido, se recorre la lista desde el inicio hasta hallarlo.
  /// Devuelve `null` si la bahía no tiene chip.
  Future<Element?> _chipALaVista(int bahia) async {
    var chip = _chipSiHay(bahia);
    if (chip != null) return chip;
    final selector = _buscarElemento((e) => e.widget.key == const ValueKey('bay-selector'));
    ScrollableState? lista;
    void buscar(Element e) {
      if (lista != null) return;
      if (e is StatefulElement && e.state is ScrollableState) {
        lista = e.state as ScrollableState;
        return;
      }
      e.visitChildElements(buscar);
    }

    selector?.visitChildElements(buscar);
    final posicion = lista?.position;
    if (posicion == null) return null;
    posicion.jumpTo(0);
    await _asentar();
    while ((chip = _chipSiHay(bahia)) == null && posicion.pixels < posicion.maxScrollExtent) {
      posicion.jumpTo((posicion.pixels + 150).clamp(0, posicion.maxScrollExtent));
      await _asentar();
    }
    return chip;
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

  /// Espera a que no quede ningún cuadro pendiente (animaciones incluidas).
  Future<void> _asentar() async {
    final limite = Stopwatch()..start();
    do {
      await _cuadro();
    } while (SchedulerBinding.instance.hasScheduledFrame &&
        limite.elapsed < const Duration(seconds: 20));
  }

  Future<void> _cuadro() {
    final listo = Completer<void>();
    SchedulerBinding.instance
      ..addPostFrameCallback((_) => listo.complete())
      ..scheduleFrame();
    return listo.future;
  }

  Future<void> _pausa() => Future<void>.delayed(Duration(milliseconds: _pausaMs));

  Future<void> _registrar(String paso, Map<String, Object?> datos) async {
    final ahora = DateTime.now().toUtc().toIso8601String();
    debugPrint('T99 PASO $paso $ahora');
    await anexarLinea(_pasos, jsonEncode({'paso': paso, 'ts': ahora, ...datos}));
    if (paso == 'captura' && _capturas.isNotEmpty) {
      await anexarLinea('$_capturas/anchos.jsonl',
          jsonEncode({'paso': paso, 'ts': ahora, ...datos}));
    }
  }
}
