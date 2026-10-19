// T-99 · Driver del arnés para `flutter drive`. Escribe la respuesta en
// T99_SALIDA (una carpeta de %TEMP%) como <T99_NOMBRE>.json, sin pisar otra.
//
//   $env:T99_SALIDA = "$env:TEMP\t99-…\rendimiento"; $env:T99_NOMBRE = 'a01-windows-1'
//   flutter drive --profile --no-pub -d windows --driver integration_test/t99_driver.dart `
//     --target integration_test/t99_rendimiento_test.dart `
//     --dart-define=T99_ARCHIVO=t99_inputs/CORPUS_A01.edi --dart-define=T99_CONTENEDORES=977
import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() {
  final carpeta = Platform.environment['T99_SALIDA'];
  var nombre = Platform.environment['T99_NOMBRE'] ?? 't99_rendimiento';
  if (carpeta != null && File('$carpeta/$nombre.json').existsSync()) {
    nombre = '${nombre}_${DateTime.now().millisecondsSinceEpoch}';
  }
  return integrationDriver(
    timeout: const Duration(minutes: 60),
    writeResponseOnFailure: true,
    responseDataCallback: (datos) => writeResponseData(datos,
        testOutputFilename: nombre, destinationDirectory: carpeta),
  );
}
