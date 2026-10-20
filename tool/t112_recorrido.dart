// T-112 · Recorrido automático del banco: la interfaz real, en release, sin
// flutter_test ni control del escritorio. Toca como lo haría una persona
// (mismo método que tool/t99_conductor.dart) y, para cada tamaño y escala de
// letra, guarda una captura PNG de cada pantalla con lo que encontró:
//   - los textos que se dibujan (para buscar inglés que haya quedado);
//   - los que no caben (RenderParagraph.didExceedMaxLines);
//   - los desplazables horizontales con contenido oculto;
//   - los errores de Flutter (los desbordes de RenderFlex solo en debug).
// Los registros van a T112_RECORRIDO (una carpeta en TEMP en Windows y Android;
// en la Web, al servidor local de tool/t99_servidor.dart).
import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

import 't99_plataforma.dart';

const _salida = String.fromEnvironment('T112_RECORRIDO');
const _tamanos = String.fromEnvironment('T112_TAMANOS', defaultValue: '360x780,real');
const _escalas = String.fromEnvironment('T112_ESCALAS', defaultValue: '1.0,1.45');
// Para el control de regresión sobre HEAD, que todavía dice «Bay Plan» y «Back».
const _plano = String.fromEnvironment('T112_PLANO', defaultValue: 'Plano');
const _atras = String.fromEnvironment('T112_ATRAS', defaultValue: 'Atrás');

/// Palabras que T-112 quitó de la pantalla. Si alguna se dibuja, el recorrido
/// la anota (como palabra suelta, no dentro de otra: «Bahía» no cuenta).
final _ingles = RegExp(r'\b(Bay|BAY|Row|Tier|Tiers|Reefers?|DECK|HOLD|Tip|UNKNOWN|Back|Alert|Dismiss|'
    r'Cancel|OK|Select|loading_baplie|containerId|grossWeight)\b');

/// El recorrido, o `null` si la compilación no lo pide.
T112Recorrido? recorridoDesdeDefiniciones() =>
    _salida.isEmpty ? null : T112Recorrido();

class T112Recorrido {
  final _tamano = ValueNotifier<Size?>(null);
  final _escala = ValueNotifier<double?>(1.0);
  final _lienzo = GlobalKey();
  final _errores = <String>[];
  var _puntero = 11200;

  /// Envoltorio para BayStreamApp.builder: impone tamaño lógico y escala de
  /// letra, y deja un RepaintBoundary para la captura.
  Widget envoltorio(BuildContext context, Widget? child) => ValueListenableBuilder<double?>(
      valueListenable: _escala,
      builder: (context, escala, _) => ValueListenableBuilder<Size?>(
          valueListenable: _tamano,
          builder: (context, tamano, _) {
            final sistema = MediaQuery.of(context);
            final datos = sistema.copyWith(
                textScaler: escala == null ? sistema.textScaler : TextScaler.linear(escala),
                size: tamano ?? sistema.size);
            final lienzo = RepaintBoundary(
                key: _lienzo, child: MediaQuery(data: datos, child: child!));
            if (tamano == null) return lienzo;
            return ColoredBox(
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                child: FittedBox(child: SizedBox.fromSize(size: tamano, child: lienzo)));
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
      await _registrar('inicio', {});
      for (final tamano in _tamanos.split(',').map((s) => s.trim())) {
        // «sistema»: la letra que pone el sistema (el Honor con font_scale),
        // sin forzar la escala desde aquí.
        for (final escala in _escalas.split(',').map((s) => s.trim())) {
          final partes = tamano.split('x');
          _tamano.value =
              tamano == 'real' ? null : Size(double.parse(partes[0]), double.parse(partes[1]));
          _escala.value = escala == 'sistema' ? null : double.parse(escala);
          await _asentar();
          await _pantallas('${tamano}_$escala', ancho: tamano == 'real');
        }
      }
      _tamano.value = null;
      _escala.value = null;
      await _registrar('fin', {});
    } catch (error, pila) {
      await _registrar('error', {'detalle': '$error', 'pila': '$pila'.split('\n').take(8).join(' | ')});
    }
  }

  Future<void> _pantallas(String caso, {required bool ancho}) async {
    await _tocar(_pestana('Lista'));
    await _capturar(caso, 'lista');
    await _tocar(_texto('TSTU1120009'));
    await _capturar(caso, 'detalle');
    await _cerrarHoja();

    await _tocar(_pestana(_plano));
    await _capturar(caso, 'plano');

    await _tocar(_pestana('Estadísticas'));
    await _capturar(caso, 'estadisticas');

    await _tocar(_conTooltip('Buscar contenedor'));
    await _capturar(caso, 'buscar_consejo');
    final campo = _buscarElemento((e) => e.widget is EditableText);
    if (campo == null) throw StateError('No apareció el campo de búsqueda');
    ((campo as StatefulElement).state as EditableTextState).updateEditingValue(
        const TextEditingValue(text: 'TSTU112', selection: TextSelection.collapsed(offset: 7)));
    await _capturar(caso, 'buscar');
    await _tocar(_conTooltip('Volver'));
    await _asentar();

    if (ancho) {
      await _tocar(_conTooltip('Parámetros'));
      await _capturar(caso, 'parametros');
      await _tocar(_conTooltip(_atras));
      await _asentar();
      await _tocar(_conClave('cloud-page'));
      await _capturar(caso, 'nube');
      await _tocar(_conTooltip(_atras));
      await _asentar();
    }
    await _tocar(_pestana('Lista'));
    await _asentar();
  }

  Future<void> _cerrarHoja() async {
    final barrera = _buscarElemento((e) => e.widget is ModalBarrier);
    if (barrera == null) return;
    Navigator.of(barrera).pop();
    await _asentar();
  }

  Future<void> _capturar(String caso, String pantalla) async {
    await _asentar();
    final caja = _lienzo.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final imagen = await caja.toImage(pixelRatio: 1);
    final png = await imagen.toByteData(format: ui.ImageByteFormat.png);
    imagen.dispose();
    final nombre = 't112_${caso}_$pantalla.png';
    await guardarBytes(_salida, nombre, png!.buffer.asUint8List());
    final textos = <String>[];
    final truncados = <String>[];
    void visitar(RenderObject r) {
      if (r is RenderParagraph) {
        final texto = r.text.toPlainText();
        if (texto.trim().isNotEmpty) textos.add(texto);
        if (r.didExceedMaxLines) truncados.add(texto);
      }
      r.visitChildren(visitar);
    }

    visitar(caja);
    final tooltips = <String>[];
    final horizontales = <int>[];
    void visitarElementos(Element e) {
      final w = e.widget;
      if (w is Tooltip && w.message != null) tooltips.add(w.message!);
      if (e is StatefulElement && e.state is ScrollableState) {
        final s = e.state as ScrollableState;
        if (s.position.axis == Axis.horizontal && s.position.maxScrollExtent > 0.5) {
          horizontales.add(s.position.maxScrollExtent.round());
        }
      }
      e.visitChildren(visitarElementos);
    }

    _lienzo.currentContext!.visitChildElements(visitarElementos);
    final ingles = [
      for (final t in [...textos, ...tooltips])
        for (final m in _ingles.allMatches(t)) '${m[0]} ← ${t.length > 80 ? '${t.substring(0, 80)}…' : t}'
    ];
    await _registrar('captura', {
      'caso': caso,
      'pantalla': pantalla,
      'archivo': nombre,
      'logico': '${caja.size.width.round()}x${caja.size.height.round()}',
      'textos_que_no_caben': truncados,
      'ingles': ingles,
      'tooltips': tooltips.toSet().toList(),
      'desplazables_horizontales_px': horizontales,
      'errores_de_flutter': [..._errores],
      'textos': textos,
    });
    _errores.clear();
  }

  // --- Interacción (como tool/t99_conductor.dart) -------------------------

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
      _buscarElemento((e) => e.widget is Tab && (e.widget as Tab).text == texto), 'la pestaña $texto');

  Element _conTooltip(String mensaje) => _exigir(
      _buscarElemento((e) => e.widget is Tooltip && (e.widget as Tooltip).message == mensaje),
      'el botón $mensaje');

  Element _conClave(String clave) =>
      _exigir(_buscarElemento((e) => e.widget.key == ValueKey(clave)), 'la clave $clave');

  Element _texto(String texto) => _exigir(
      _buscarElemento((e) => e.widget is Text && (e.widget as Text).data == texto), 'el texto $texto');

  /// Toca el centro de [e], después de traerlo a la vista y comprobar que
  /// nada lo tapa.
  Future<void> _tocar(Element e) async {
    await Scrollable.ensureVisible(e, alignment: 0.5);
    await _asentar();
    final caja = e.renderObject! as RenderBox;
    final centro = caja.localToGlobal(caja.size.center(Offset.zero));
    final vista = WidgetsBinding.instance.platformDispatcher.implicitView!.viewId;
    final prueba = HitTestResult();
    WidgetsBinding.instance.hitTestInView(prueba, centro, vista);
    if (!prueba.path.any((entrada) => entrada.target == caja)) {
      throw StateError('Algo tapa ${e.widget.runtimeType} en $centro');
    }
    final puntero = _puntero++;
    GestureBinding.instance
        .handlePointerEvent(PointerDownEvent(pointer: puntero, position: centro, viewId: vista));
    await Future<void>.delayed(const Duration(milliseconds: 60));
    GestureBinding.instance
        .handlePointerEvent(PointerUpEvent(pointer: puntero, position: centro, viewId: vista));
    await _asentar();
  }

  /// Espera a que no quede ningún cuadro pendiente (animaciones incluidas).
  Future<void> _asentar() async {
    final limite = Stopwatch()..start();
    do {
      await _cuadro();
    } while (SchedulerBinding.instance.hasScheduledFrame && limite.elapsed < const Duration(seconds: 20));
  }

  Future<void> _cuadro() {
    final listo = Completer<void>();
    SchedulerBinding.instance
      ..addPostFrameCallback((_) => listo.complete())
      ..scheduleFrame();
    return listo.future;
  }

  Future<void> _registrar(String paso, Map<String, Object?> datos) async {
    final ahora = DateTime.now().toUtc().toIso8601String();
    debugPrint('T112 PASO $paso $ahora');
    await anexarLinea('$_salida/recorrido.jsonl', jsonEncode({'paso': paso, 'ts': ahora, ...datos}));
  }
}

