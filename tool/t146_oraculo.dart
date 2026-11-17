// T-146 · El oráculo de O-144-2 (10.138).
//
// `use_build_context_synchronously` no corre en las carpetas de pruebas del
// paquete (`test/`, `integration_test/`…): el SDK de Dart solo la registra
// si el archivo no está en una de ellas. Para ver lo que marcaría ahí, este
// programa copia `test/` y `tool/` de una COPIA del paquete dentro de su
// `lib/zz_oraculo/`, donde la regla corre siempre, analiza la copia y cuenta
// los avisos de esa regla. Es una herramienta de T-146, no un criterio: el
// criterio sigue siendo `flutter analyze --no-pub` en cero.
//
// Nunca escribe en el repositorio salvo el resumen, y solo dentro de
// build/t146. Dart estándar, sin paquetes. Ejecutar con el semáforo.
import 'dart:convert';
import 'dart:io';

const _uso = '''
dart run tool/t146_oraculo.dart --copia RUTA [--salida RUTA] [--conservar]
  --copia RUTA    Una copia del paquete FUERA de este repositorio (con su
                  pubspec.yaml y su pub get hecho). Ahí se crea
                  lib/zz_oraculo/ con su test/ y su tool/.
  --salida RUTA   Dentro de build/t146. Por omisión: build/t146/oraculo.
  --conservar     No borra lib/zz_oraculo/ de la copia al terminar.
  --help          Muestra esta ayuda.

Salida 0: cero avisos de la regla. Salida 1: hay avisos (van en
resumen.json). Salida 2: no se pudo correr.
''';

const _regla = 'use_build_context_synchronously';
const _carpeta = 'zz_oraculo';

Future<void> main(List<String> argumentos) async {
  try {
    if (argumentos.contains('--help') || argumentos.contains('-h')) {
      stdout.write(_uso);
      return;
    }
    exitCode = await _correr(_opciones(argumentos));
  } on FormatException catch (error) {
    stderr
      ..writeln('T-146: ${error.message}')
      ..write(_uso);
    exitCode = 2;
  } on _Fallo catch (error) {
    stderr.writeln('T-146: ${error.mensaje}');
    exitCode = 2;
  } on FileSystemException catch (error) {
    stderr.writeln('T-146: ${error.message}: ${error.path ?? ''}');
    exitCode = 2;
  }
}

class _Fallo implements Exception {
  const _Fallo(this.mensaje);
  final String mensaje;
}

Map<String, String> _opciones(List<String> argumentos) {
  final opciones = <String, String>{'salida': 'build/t146/oraculo'};
  for (var i = 0; i < argumentos.length; i++) {
    final argumento = argumentos[i];
    if (argumento == '--conservar') {
      opciones['conservar'] = 'si';
    } else if (argumento == '--copia' || argumento == '--salida') {
      if (++i == argumentos.length || argumentos[i].startsWith('--')) {
        throw FormatException('Falta el valor de $argumento.');
      }
      opciones[argumento.substring(2)] = argumentos[i];
    } else {
      throw FormatException('Opción desconocida: $argumento');
    }
  }
  if (!opciones.containsKey('copia')) {
    throw const FormatException('Falta --copia.');
  }
  return opciones;
}

/// Ruta absoluta comparable en Windows: barras invertidas, sin la final y en
/// minúsculas.
String _clave(String ruta) {
  var clave = Directory(ruta).absolute.path.replaceAll('/', r'\');
  while (clave.endsWith(r'\') && clave.length > 3) {
    clave = clave.substring(0, clave.length - 1);
  }
  return clave.toLowerCase();
}

bool _dentroDe(String ruta, String raiz) {
  final a = _clave(ruta);
  final b = _clave(raiz);
  return a == b || a.startsWith('$b\\');
}

Future<int> _correr(Map<String, String> opciones) async {
  final repo = Directory.current.path;
  if (!File('$repo/pubspec.yaml').existsSync() ||
      !File('$repo/tool/t146_oraculo.dart').existsSync()) {
    throw const _Fallo('Corre este programa desde la raíz del repositorio.');
  }
  final copia = Directory(opciones['copia']!).absolute;
  if (_dentroDe(copia.path, repo)) {
    throw _Fallo('La copia está dentro del repositorio (${copia.path}): '
        'usa una carpeta fuera, por ejemplo en %TEMP%.');
  }
  if (!File('${copia.path}/pubspec.yaml').existsSync() ||
      !File('${copia.path}/.dart_tool/package_config.json').existsSync()) {
    throw _Fallo('${copia.path} no es una copia del paquete con pub get '
        'hecho (faltan pubspec.yaml o .dart_tool/package_config.json).');
  }
  final salida = Directory(opciones['salida']!).absolute;
  if (!_dentroDe(salida.path, '$repo/build/t146')) {
    throw const _Fallo('--salida tiene que estar dentro de build/t146.');
  }

  // 1. test/ y tool/ de la copia, dentro de su lib/zz_oraculo/.
  final oraculo = Directory('${copia.path}/lib/$_carpeta');
  if (oraculo.existsSync()) oraculo.deleteSync(recursive: true);
  var copiados = 0;
  for (final nombre in ['test', 'tool']) {
    final origen = Directory('${copia.path}/$nombre');
    if (!origen.existsSync()) {
      throw const _Fallo('La copia no tiene test/ o tool/.');
    }
    copiados += _copiar(origen, Directory('${oraculo.path}/$nombre'));
  }
  stdout.writeln('T-146: $copiados archivos copiados a ${oraculo.path}');

  // 2. flutter analyze --no-pub en la copia.
  final inicio = DateTime.now();
  final ProcessResult analisis;
  try {
    analisis = await Process.run('flutter', ['analyze', '--no-pub'],
        workingDirectory: copia.path,
        runInShell: true,
        stdoutEncoding: utf8,
        stderrEncoding: utf8);
  } finally {
    if (opciones['conservar'] != 'si' && oraculo.existsSync()) {
      oraculo.deleteSync(recursive: true);
    }
  }
  final segundos = DateTime.now().difference(inicio).inMilliseconds / 1000;
  final texto = '${analisis.stdout}\n${analisis.stderr}';

  // 3. Los avisos de la regla, por archivo, relativos a lib/zz_oraculo/.
  final patron = RegExp(
      r' - lib[\\/]' '$_carpeta' r'[\\/](\S+):(\d+):(\d+) - ' '$_regla' r'\s*$');
  final avisos = <Map<String, Object>>[];
  for (final linea in const LineSplitter().convert(texto)) {
    final m = patron.firstMatch(linea);
    if (m != null) {
      avisos.add({
        'archivo': m.group(1)!.replaceAll(r'\', '/'),
        'linea': int.parse(m.group(2)!),
        'columna': int.parse(m.group(3)!),
      });
    }
  }
  final porArchivo = <String, int>{};
  for (final aviso in avisos) {
    porArchivo.update(aviso['archivo']! as String, (n) => n + 1,
        ifAbsent: () => 1);
  }
  final otros = const LineSplitter()
      .convert(texto)
      .where((l) => RegExp(r'^\s+(error|warning|info) - ').hasMatch(l))
      .where((l) => !l.trimRight().endsWith(_regla))
      .length;

  salida.createSync(recursive: true);
  File('${salida.path}/analyze.log').writeAsStringSync(texto);
  final resumen = {
    'herramienta': 'tool/t146_oraculo.dart',
    'copia': copia.path,
    'fecha': inicio.toIso8601String(),
    'segundos': segundos,
    'archivosCopiados': copiados,
    'salidaAnalyze': analisis.exitCode,
    'regla': _regla,
    'avisosDeLaRegla': avisos.length,
    'porArchivo': porArchivo,
    'avisos': avisos,
    'otrosAvisos': otros,
    'nota': 'otrosAvisos son el ruido de mover test/ y tool/ a lib/ '
        '(depend_on_referenced_packages y los imports de '
        'tool/t124_main.dart); no cuentan.',
  };
  File('${salida.path}/resumen.json').writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(resumen)}\n');

  stdout.writeln('T-146: analyze salió con ${analisis.exitCode} en '
      '${segundos.toStringAsFixed(1)} s.');
  stdout.writeln('T-146: $_regla: ${avisos.length} aviso(s).');
  for (final aviso in avisos) {
    stdout.writeln('  ${aviso['archivo']}:${aviso['linea']}:'
        '${aviso['columna']}');
  }
  stdout.writeln('T-146: resumen en ${salida.path}');
  return avisos.isEmpty ? 0 : 1;
}

/// Copia [origen] en [destino], con sus subcarpetas. Devuelve cuántos
/// archivos copió.
int _copiar(Directory origen, Directory destino) {
  var n = 0;
  final base = origen.path.length;
  for (final entrada in origen.listSync(recursive: true, followLinks: false)) {
    final relativa = entrada.path.substring(base);
    if (entrada is Directory) {
      Directory('${destino.path}$relativa').createSync(recursive: true);
    } else if (entrada is File) {
      final nuevo = File('${destino.path}$relativa');
      nuevo.parent.createSync(recursive: true);
      entrada.copySync(nuevo.path);
      n++;
    }
  }
  return n;
}
