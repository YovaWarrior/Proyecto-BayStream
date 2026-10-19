// T-99 · Lectura ligera de fuentes para los conteos de RNF-003 y RNF-005.
//
// No es un analizador de Dart: separa código, comentarios y cadenas (con
// interpolación anidada) para contar líneas y emparejar llaves sin que una
// `//` dentro de una URL o una llave dentro de una cadena muevan el resultado.
// Lo que no resuelve está declarado en docs/T99-RESULTADOS.md, y sus casos
// están en test/t99_fuente_test.dart.

/// Qué es cada carácter de una fuente.
enum Clase { codigo, comentario, cadena }

/// Clasifica cada carácter de una fuente Dart.
///
/// Reconoce `//`, `/* */` anidados, cadenas simples, dobles, triples y crudas
/// (`r'...'`), escapes e interpolaciones `${...}` con cadenas dentro. El
/// interior de una interpolación se marca como cadena: sus llaves están
/// equilibradas y no cambian la profundidad del código que la rodea.
List<Clase> clasificarDart(String s) {
  final out = List<Clase>.filled(s.length, Clase.codigo);
  _codigo(s, out, 0, Clase.codigo, false);
  return out;
}

int _codigo(String s, List<Clase> out, int i, Clase marca, bool interpolacion) {
  var llaves = 0;
  while (i < s.length) {
    final c = s[i];
    if (c == '/' && i + 1 < s.length && s[i + 1] == '/') {
      while (i < s.length && s[i] != '\n') {
        out[i++] = Clase.comentario;
      }
      continue;
    }
    if (c == '/' && i + 1 < s.length && s[i + 1] == '*') {
      var profundidad = 0;
      do {
        if (s.startsWith('/*', i)) {
          profundidad++;
          out[i] = out[i + 1] = Clase.comentario;
          i += 2;
        } else if (s.startsWith('*/', i)) {
          profundidad--;
          out[i] = out[i + 1] = Clase.comentario;
          i += 2;
        } else {
          out[i++] = Clase.comentario;
        }
      } while (profundidad > 0 && i < s.length);
      continue;
    }
    if (c == '"' || c == "'") {
      final cruda = i > 0 &&
          (s[i - 1] == 'r' || s[i - 1] == 'R') &&
          (i < 2 || !_identificador(s[i - 2]));
      if (cruda) out[i - 1] = Clase.cadena;
      final triple = s.startsWith(c * 3, i);
      i = _cadena(s, out, i, c, triple, cruda);
      continue;
    }
    if (interpolacion) {
      if (c == '{') llaves++;
      if (c == '}') {
        if (llaves == 0) {
          out[i] = Clase.cadena;
          return i + 1;
        }
        llaves--;
      }
    }
    out[i++] = marca;
  }
  return i;
}

int _cadena(
    String s, List<Clase> out, int i, String comilla, bool triple, bool cruda) {
  final cierre = triple ? comilla * 3 : comilla;
  for (var k = 0; k < cierre.length; k++) {
    out[i + k] = Clase.cadena;
  }
  i += cierre.length;
  while (i < s.length) {
    final c = s[i];
    if (!cruda && c == r'\') {
      out[i] = Clase.cadena;
      if (i + 1 < s.length) out[i + 1] = Clase.cadena;
      i += 2;
      continue;
    }
    if (!cruda && c == r'$' && i + 1 < s.length && s[i + 1] == '{') {
      out[i] = out[i + 1] = Clase.cadena;
      i = _codigo(s, out, i + 2, Clase.cadena, true);
      continue;
    }
    if (s.startsWith(cierre, i)) {
      for (var k = 0; k < cierre.length; k++) {
        out[i + k] = Clase.cadena;
      }
      return i + cierre.length;
    }
    // Una cadena simple sin cerrar termina en el salto de línea, como el
    // compilador al recuperarse; no se come el resto del archivo.
    if (!triple && c == '\n') return i;
    out[i++] = Clase.cadena;
  }
  return i;
}

bool _identificador(String c) => RegExp(r'[A-Za-z0-9_$]').hasMatch(c);

/// La fuente con los comentarios cambiados por espacios. Conserva los saltos
/// de línea y la longitud: las líneas y columnas no se mueven.
String sinComentarios(String s, [List<Clase>? clases]) {
  final k = clases ?? clasificarDart(s);
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    b.write(k[i] == Clase.comentario && s[i] != '\n' ? ' ' : s[i]);
  }
  return b.toString();
}

/// Solo el código: comentarios y cadenas pasan a espacios, sin mover nada.
/// Sirve para buscar palabras clave y emparejar llaves.
String soloCodigo(String s, [List<Clase>? clases]) {
  final k = clases ?? clasificarDart(s);
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    b.write(k[i] != Clase.codigo && s[i] != '\n' ? ' ' : s[i]);
  }
  return b.toString();
}

/// Para cada línea (desde 0), si tiene código o cadena que no sea espacio.
/// Es el criterio «sin comentarios ni líneas en blanco» de RNF-003 (3.1).
List<bool> lineasConCodigo(String s, [List<Clase>? clases]) {
  final k = clases ?? clasificarDart(s);
  final lineas = <bool>[false];
  for (var i = 0; i < s.length; i++) {
    final c = s[i];
    if (c == '\n') {
      lineas.add(false);
      continue;
    }
    if (k[i] != Clase.comentario && c.trim().isNotEmpty) lineas[lineas.length - 1] = true;
  }
  return lineas;
}

int contarLineasDeCodigo(String s) => lineasConCodigo(s).where((l) => l).length;

/// Índice de línea (desde 0) de cada posición de [s].
List<int> lineaDeCadaPosicion(String s) {
  final out = List<int>.filled(s.length + 1, 0);
  var linea = 0;
  for (var i = 0; i < s.length; i++) {
    out[i] = linea;
    if (s[i] == '\n') linea++;
  }
  out[s.length] = linea;
  return out;
}

/// Posición de la llave que cierra la que abre en [abre], sobre texto de
/// [soloCodigo]. Devuelve -1 si no cierra.
int llaveQueCierra(String codigo, int abre) {
  final apertura = codigo[abre];
  final cierre = switch (apertura) { '{' => '}', '(' => ')', '[' => ']', _ => '' };
  if (cierre.isEmpty) throw ArgumentError('No es una apertura: $apertura');
  var profundidad = 0;
  for (var i = abre; i < codigo.length; i++) {
    if (codigo[i] == apertura) profundidad++;
    if (codigo[i] == cierre) {
      profundidad--;
      if (profundidad == 0) return i;
    }
  }
  return -1;
}

/// Una directiva `import` o `export`, con sus URI condicionales.
class Directiva {
  final String tipo;
  final String uri;

  /// Pares (condición, URI) de `if (dart.library.x) 'otra.dart'`, en orden.
  final List<(String, String)> condicionales;
  final int linea;
  const Directiva(this.tipo, this.uri, this.condicionales, this.linea);

  List<String> get todasLasUri => [uri, for (final c in condicionales) c.$2];
}

final _directiva = RegExp(
    r'''(?:^|[;\s])(import|export)\s+(['"])([^'"]+)\2((?:\s+if\s*\(\s*[\w.]+(?:\s*==\s*(?:'[^']*'|"[^"]*"))?\s*\)\s*(['"])[^'"]+\5)*)''',
    multiLine: true);
final _condicion =
    RegExp(r'''if\s*\(\s*([\w.]+)(?:\s*==\s*(?:'[^']*'|"[^"]*"))?\s*\)\s*(['"])([^'"]+)\2''');

/// Las directivas de una fuente Dart, sin las que están comentadas.
List<Directiva> directivasDart(String fuente) {
  final limpio = sinComentarios(fuente);
  final lineas = lineaDeCadaPosicion(limpio);
  return [
    for (final m in _directiva.allMatches(limpio))
      Directiva(
          m.group(1)!,
          m.group(3)!,
          [
            for (final c in _condicion.allMatches(m.group(4) ?? ''))
              (c.group(1)!, c.group(3)!)
          ],
          lineas[m.start] + (limpio[m.start] == '\n' ? 1 : 0)),
  ];
}

/// Resuelve una URI de directiva a una ruta relativa a la raíz del paquete
/// (`lib/...`), o devuelve `null` si es de otro paquete o de `dart:`.
String? resolverUri(String desde, String uri, String paquete) {
  if (uri.startsWith('package:$paquete/')) {
    return 'lib/${uri.substring('package:$paquete/'.length)}';
  }
  if (uri.contains(':')) return null;
  final partes = desde.replaceAll('\\', '/').split('/')..removeLast();
  for (final p in uri.split('/')) {
    if (p == '..') {
      if (partes.isNotEmpty) partes.removeLast();
    } else if (p != '.') {
      partes.add(p);
    }
  }
  return partes.join('/');
}

/// Código generado que se excluye de los conteos, declarándolo.
bool esGenerado(String ruta, String fuente) {
  final r = ruta.replaceAll('\\', '/');
  if (r.endsWith('.g.dart') ||
      r.endsWith('.freezed.dart') ||
      r.endsWith('.gr.dart') ||
      r.contains('generated_plugin_registrant') ||
      r.endsWith('generated_plugins.cmake') ||
      r.endsWith('GeneratedPluginRegistrant.java')) {
    return true;
  }
  final cabecera = fuente.length > 400 ? fuente.substring(0, 400) : fuente;
  return cabecera.contains('GENERATED CODE - DO NOT MODIFY') ||
      cabecera.contains('Generated file. Do not edit.');
}
