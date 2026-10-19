import 'dart:io';
import 'dart:typed_data';

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
