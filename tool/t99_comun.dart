// T-99 · Utilidades compartidas de los instrumentos de RNF-001, 003, 005 y 007.
//
// Todo lo que escriben estos scripts va a %TEMP%, nunca al repositorio: las
// salidas pueden traer datos del corpus (anonimizado, pero privado) o de un
// sintético que no es un viaje. `exigirSalidaEnTemp` lo hace cumplir.
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

/// Normaliza una ruta de Windows o POSIX para compararla sin distinguir
/// mayúsculas ni el tipo de barra.
String rutaComparable(String ruta) =>
    File(ruta).absolute.path.replaceAll('\\', '/').toLowerCase();

/// `true` si [ruta] está dentro de [carpeta] (o es la misma).
bool estaDentro(String ruta, String carpeta) {
  final r = rutaComparable(ruta);
  var c = rutaComparable(carpeta);
  if (!c.endsWith('/')) c = '$c/';
  return r == c.substring(0, c.length - 1) || r.startsWith(c);
}

/// La carpeta temporal del sistema: %TEMP% en Windows.
String carpetaTemporal() => Directory.systemTemp.absolute.path;

/// Falla si [ruta] no cuelga de %TEMP% o si cae dentro de [repo].
///
/// Es la regla de la ficha de T-99: los sintéticos y las evidencias nunca
/// entran al repositorio, que es público.
void exigirSalidaEnTemp(String ruta, {String? repo}) {
  if (!estaDentro(ruta, carpetaTemporal())) {
    throw ArgumentError(
        'La salida debe ir dentro de %TEMP% (${carpetaTemporal()}): $ruta');
  }
  if (repo != null && estaDentro(ruta, repo)) {
    throw ArgumentError('La salida no puede quedar dentro del repositorio: $ruta');
  }
}

/// Crea [ruta] y falla si ya existe con contenido: una corrida no pisa otra.
Directory carpetaNueva(String ruta) {
  final dir = Directory(ruta);
  if (dir.existsSync() && dir.listSync().isNotEmpty) {
    throw StateError('La carpeta ya tiene una corrida; usa otra: $ruta');
  }
  return dir..createSync(recursive: true);
}

String sha256DeBytes(List<int> bytes) => sha256.convert(bytes).toString();

String sha256DeArchivo(String ruta) =>
    sha256DeBytes(File(ruta).readAsBytesSync());

/// Un campo CSV con comillas cuando hace falta (RFC 4180).
String campoCsv(Object? valor) {
  final texto = valor?.toString() ?? '';
  if (texto.contains(RegExp(r'[",\r\n]'))) {
    return '"${texto.replaceAll('"', '""')}"';
  }
  return texto;
}

String filaCsv(Iterable<Object?> campos) => campos.map(campoCsv).join(',');

/// Lee un CSV sencillo con comillas RFC 4180 (lo que escribe [filaCsv]).
List<List<String>> leerCsv(String texto) {
  final filas = <List<String>>[];
  var fila = <String>[];
  final campo = StringBuffer();
  var comillas = false;
  for (var i = 0; i < texto.length; i++) {
    final c = texto[i];
    if (comillas) {
      if (c == '"') {
        if (i + 1 < texto.length && texto[i + 1] == '"') {
          campo.write('"');
          i++;
        } else {
          comillas = false;
        }
      } else {
        campo.write(c);
      }
    } else if (c == '"') {
      comillas = true;
    } else if (c == ',') {
      fila.add(campo.toString());
      campo.clear();
    } else if (c == '\n' || c == '\r') {
      if (c == '\r' && i + 1 < texto.length && texto[i + 1] == '\n') i++;
      fila.add(campo.toString());
      campo.clear();
      if (fila.any((f) => f.isNotEmpty) || fila.length > 1) filas.add(fila);
      fila = <String>[];
    } else {
      campo.write(c);
    }
  }
  if (campo.isNotEmpty || fila.isNotEmpty) {
    fila.add(campo.toString());
    filas.add(fila);
  }
  return filas;
}

void escribirJson(String ruta, Object? datos) => File(ruta)
    .writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(datos)}\n');

/// Mediana de una lista no vacía (promedio de los dos centrales si es par).
double mediana(Iterable<num> valores) {
  final v = valores.map((e) => e.toDouble()).toList()..sort();
  if (v.isEmpty) throw StateError('Mediana de una lista vacía');
  final m = v.length ~/ 2;
  return v.length.isOdd ? v[m] : (v[m - 1] + v[m]) / 2;
}

double maximo(Iterable<num> valores) {
  if (valores.isEmpty) throw StateError('Máximo de una lista vacía');
  return valores.map((e) => e.toDouble()).reduce((a, b) => a > b ? a : b);
}

/// El percentil exactamente como `findPercentile` de flutter_driver 3.38.9
/// (`packages/flutter_driver/lib/src/driver/percentile_utils.dart`): ordena y
/// toma el índice `round((n - 1) * p / 100)`, sin interpolar.
double percentilComoTimelineSummary(Iterable<num> valores, double p) {
  final v = valores.map((e) => e.toDouble()).toList()..sort();
  if (v.isEmpty) throw StateError('Percentil de una lista vacía');
  return v[((v.length - 1) * (p / 100)).round()];
}

/// Una cifra con [decimales] decimales y punto decimal, como en el informe.
String cifra(num valor, [int decimales = 1]) => valor.toStringAsFixed(decimales);
