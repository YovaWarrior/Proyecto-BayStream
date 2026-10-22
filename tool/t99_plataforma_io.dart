import 'dart:io';
import 'dart:typed_data';

/// Una variable de entorno del proceso, o vacío. Permite elegir el escenario
/// y las salidas del conductor al arrancar, sin recompilar (Fase 3 de T-114).
String variableDeEntorno(String nombre) => Platform.environment[nombre] ?? '';

/// Agrega una línea a [ruta]. Sin ruta, no escribe nada.
Future<void> anexarLinea(String ruta, String linea) async {
  if (ruta.isEmpty) return;
  final archivo = File(ruta);
  await archivo.parent.create(recursive: true);
  await archivo.writeAsString('$linea\n', mode: FileMode.append, flush: true);
}

/// Guarda [bytes] como [carpeta]/[nombre]. Sin carpeta, no escribe nada.
Future<void> guardarBytes(String carpeta, String nombre, Uint8List bytes) async {
  if (carpeta.isEmpty) return;
  await Directory(carpeta).create(recursive: true);
  await File('$carpeta/$nombre').writeAsBytes(bytes, flush: true);
}
