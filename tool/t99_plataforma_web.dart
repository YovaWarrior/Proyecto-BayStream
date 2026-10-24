import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

@JS('fetch')
external JSPromise<JSAny?> _fetch(JSString url, JSObject opciones);

/// En la Web no hay archivos: se envía al servidor local que sirve el banco.
/// Si el banco no lo sirve tool/t99_servidor.dart, el envío falla y se ignora.
Future<void> _enviar(String url, JSAny cuerpo) async {
  try {
    final opciones = JSObject()
      ..setProperty('method'.toJS, 'POST'.toJS)
      ..setProperty('body'.toJS, cuerpo);
    await _fetch(url.toJS, opciones).toDart;
  } catch (_) {
    // Sin servidor de T-99 no hay dónde guardar; la consola conserva el paso.
  }
}

/// En la Web no hay entorno del proceso: solo valen las definiciones.
String variableDeEntorno(String nombre) => '';

/// El servidor guarda la línea en el archivo de nombre igual al de [ruta].
Future<void> anexarLinea(String ruta, String linea) async {
  if (ruta.isEmpty) return;
  final nombre = ruta.replaceAll(String.fromCharCode(92), '/').split('/').last;
  await _enviar('/t99/registro?nombre=${Uri.encodeQueryComponent(nombre)}', linea.toJS);
}

Future<void> guardarBytes(String carpeta, String nombre, Uint8List bytes) async {
  if (carpeta.isEmpty) return;
  await _enviar('/t99/captura?nombre=${Uri.encodeQueryComponent(nombre)}', bytes.toJS);
}
