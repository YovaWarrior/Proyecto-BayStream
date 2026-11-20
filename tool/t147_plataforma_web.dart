import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

@JS('fetch')
external JSPromise<JSAny?> _fetch(JSString url, [JSObject? opciones]);

/// Un parámetro del banco: en la Web va en la dirección (`?escenario=medir`).
String parametro(String nombre) => Uri.base.queryParameters[nombre] ?? '';

/// Un archivo del caso: lo sirve tool/t147_servidor.py desde su carpeta de
/// fuera del repositorio, solo en 127.0.0.1.
Future<Uint8List> leerDelCaso(String nombre) async {
  final respuesta =
      (await _fetch('/t147/caso/${Uri.encodeComponent(nombre)}'.toJS).toDart)!
          as JSObject;
  if (!(respuesta.getProperty('ok'.toJS) as JSBoolean).toDart) {
    throw StateError('El servidor del banco no dio $nombre.');
  }
  final cuerpo = await (respuesta.callMethod('arrayBuffer'.toJS)
          as JSPromise<JSAny?>)
      .toDart;
  return (cuerpo! as JSArrayBuffer).toDart.asUint8List();
}

Future<void> _enviar(String url, JSAny cuerpo) async {
  final opciones = JSObject()
    ..setProperty('method'.toJS, 'POST'.toJS)
    ..setProperty('body'.toJS, cuerpo);
  await _fetch(url.toJS, opciones).toDart;
}

/// El servidor agrega la línea a `pasos.jsonl` de su carpeta de salida.
Future<void> registrarLinea(String linea) =>
    _enviar('/t147/registro', linea.toJS);

/// El servidor guarda la captura en `capturas/` de su carpeta de salida.
Future<void> guardarCaptura(String nombre, Uint8List bytes) => _enviar(
    '/t147/captura?nombre=${Uri.encodeQueryComponent(nombre)}', bytes.toJS);
