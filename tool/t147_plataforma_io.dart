import 'dart:io';
import 'dart:typed_data';

/// Un parámetro del banco: la variable de entorno `T147_<NOMBRE>`, o vacío.
/// Así el mismo binario sirve para todos los escenarios, sin recompilar.
String parametro(String nombre) =>
    Platform.environment['T147_${nombre.toUpperCase()}'] ?? '';

/// Un archivo del caso, de la carpeta `T147_CASO` (fuera del repositorio).
Future<Uint8List> leerDelCaso(String nombre) =>
    File('${parametro('caso')}/$nombre').readAsBytes();

/// Agrega una línea a `T147_SALIDA/pasos.jsonl`.
Future<void> registrarLinea(String linea) async {
  final carpeta = parametro('salida');
  if (carpeta.isEmpty) return;
  await Directory(carpeta).create(recursive: true);
  await File('$carpeta/pasos.jsonl')
      .writeAsString('$linea\n', mode: FileMode.append, flush: true);
}

/// Guarda una captura en `T147_SALIDA/capturas/`.
Future<void> guardarCaptura(String nombre, Uint8List bytes) async {
  final carpeta = parametro('salida');
  if (carpeta.isEmpty) return;
  await Directory('$carpeta/capturas').create(recursive: true);
  await File('$carpeta/capturas/$nombre').writeAsBytes(bytes, flush: true);
}
