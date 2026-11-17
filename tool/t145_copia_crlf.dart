// T-145 (O-137-1) · Copia lo que lee el armado de T-137 a otra carpeta, con
// todas las fuentes de texto en CRLF, como las deja Git con core.autocrlf en
// otra carpeta. Sin Git y sin paquetes. No compila, no arma y no abre nada.
//
//   dart run tool/t145_copia_crlf.dart build/t145/copia-crlf
//
// El destino tiene que estar dentro de build/t145 y no existir.
import 'dart:convert';
import 'dart:io';

// Lo que el armado lee de la carpeta del proyecto, además de las fuentes del
// arte, que salen de su manifiesto.
const _fijos = [
  'tool/t137_instalador.dart',
  'windows/installer/baystream.iss',
  'windows/runner/resources/app_icon.ico',
];

const _texto = {'.dart', '.iss', '.json'};

void main(List<String> argumentos) {
  if (argumentos.length != 1) {
    stderr.writeln('Uso: dart run tool/t145_copia_crlf.dart <destino>');
    exitCode = 64;
    return;
  }
  final proyecto = File.fromUri(Platform.script).parent.parent.absolute;
  final permitida = Directory('${proyecto.path}\\build\\t145').absolute.path;
  final destino = Directory(
    Directory(argumentos.single).absolute.path.replaceAll('/', '\\'),
  );
  if (!destino.path.toLowerCase().startsWith('${permitida.toLowerCase()}\\')) {
    stderr.writeln('T-145: el destino tiene que estar dentro de $permitida.');
    exitCode = 1;
    return;
  }
  if (destino.existsSync()) {
    stderr.writeln('T-145: ${destino.path} ya existe; usa otra carpeta.');
    exitCode = 1;
    return;
  }
  final arte = Directory('${proyecto.path}\\windows\\installer\\arte');
  final manifiesto = jsonDecode(
    File('${arte.path}\\manifiesto.json').readAsStringSync(),
  ) as Map;
  final rutas = <String>{
    ..._fijos,
    for (final archivo in arte.listSync().whereType<File>())
      'windows/installer/arte/${archivo.uri.pathSegments.last}',
    for (final fuente in (manifiesto['fuentes'] as List).cast<Map>())
      fuente['archivo'] as String,
  }.toList()
    ..sort();

  final registro = <Map<String, Object>>[];
  for (final ruta in rutas) {
    final origen = File('${proyecto.path}\\${ruta.replaceAll('/', '\\')}');
    final copia = File('${destino.path}\\${ruta.replaceAll('/', '\\')}');
    copia.parent.createSync(recursive: true);
    final bytes = origen.readAsBytesSync();
    final punto = ruta.lastIndexOf('.');
    final texto = punto >= 0 && _texto.contains(ruta.substring(punto));
    final salida = texto ? _aCrLf(bytes) : bytes;
    copia.writeAsBytesSync(salida, flush: true);
    // La fecha de modificación se conserva, como al copiar con el Explorador.
    copia.setLastModifiedSync(origen.lastModifiedSync());
    registro.add({
      'archivo': ruta,
      'clase': texto ? 'texto en CRLF' : 'binario sin cambios',
      'crlfAntes': _contar(bytes),
      'lfSolosAntes': _lfSolos(bytes),
      'crlfDespues': _contar(salida),
      'lfSolosDespues': _lfSolos(salida),
      'bytesAntes': bytes.length,
      'bytesDespues': salida.length,
    });
  }
  final informe = File('${destino.path}\\t145-copia-crlf.json');
  informe.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert({'schema': 1, 'origen': proyecto.path, 'archivos': registro})}\n',
    flush: true,
  );
  final enTexto = registro.where((r) => r['clase'] == 'texto en CRLF');
  stdout.writeln(
    'T-145: ${registro.length} archivos copiados en ${destino.path}; '
    '${enTexto.length} de texto, todos en CRLF '
    '(${enTexto.where((r) => r['lfSolosAntes'] != 0).length} estaban en LF).',
  );
}

// Primero \r\n pasa a \n y después cada \n a \r\n: un \r suelto se conserva.
List<int> _aCrLf(List<int> bytes) {
  final salida = <int>[];
  for (var i = 0; i < bytes.length; i++) {
    if (bytes[i] == 13 && i + 1 < bytes.length && bytes[i + 1] == 10) continue;
    if (bytes[i] == 10) salida.add(13);
    salida.add(bytes[i]);
  }
  return salida;
}

int _contar(List<int> bytes) {
  var n = 0;
  for (var i = 0; i + 1 < bytes.length; i++) {
    if (bytes[i] == 13 && bytes[i + 1] == 10) n++;
  }
  return n;
}

int _lfSolos(List<int> bytes) {
  var n = 0;
  for (var i = 0; i < bytes.length; i++) {
    if (bytes[i] == 10 && (i == 0 || bytes[i - 1] != 13)) n++;
  }
  return n;
}
