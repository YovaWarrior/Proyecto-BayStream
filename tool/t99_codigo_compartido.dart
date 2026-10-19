// T-99 · RNF-003, base de código compartida (T-63 3.1 (b); umbral: ≥ 95 %).
//
// Denominador: líneas de Dart de lib/ más el nativo escrito a mano
// (windows/runner, android/app/src y web/), sin comentarios, sin líneas en
// blanco y sin lo generado. Numerador: las líneas de Dart que se usan en los
// tres clientes y no están dentro de una rama por plataforma.
//
// Reglas, declaradas en docs/T99-RESULTADOS.md:
// - Un archivo de lib/ se usa en un cliente si se alcanza desde lib/main.dart,
//   o desde un archivo que nadie importa, resolviendo las directivas
//   condicionales para ese cliente. Lo que no se usa en los tres no se comparte.
// - Una rama por plataforma es el cuerpo de un `if`, `else` o `switch` cuya
//   condición nombra kIsWeb, Platform.isX, defaultTargetPlatform o
//   TargetPlatform, y la línea de un `?:` con esa condición.
// - El nativo nunca es compartido. Lo que coincide con la plantilla de
//   `flutter create` del SDK instalado es generado; lo demás es a mano.
// - web/vendor (el SDK de Firebase copiado, T-92) y web/fonts (fuentes y su
//   procedencia) no son código propio y se excluyen, declarándolo.
//
//   dart tool/t99_codigo_compartido.dart <raíz> <SDK de Flutter> <salida en %TEMP%>
import 'dart:io';

import 't99_comun.dart';
import 't99_fuente.dart';

const clientes = ['windows', 'android', 'web'];

/// Qué cliente satisface cada condición de una directiva condicional.
Set<String> clientesDeCondicion(String condicion) => switch (condicion) {
      'dart.library.io' || 'dart.library.ffi' => {'windows', 'android'},
      'dart.library.html' ||
      'dart.library.js_interop' ||
      'dart.library.js_util' ||
      'dart.library.js' ||
      'dart.library.ui_web' =>
        {'web'},
      _ => <String>{},
    };

/// La URI que elige [cliente] en una directiva, como el compilador: la primera
/// condición que se cumple, o la URI por defecto.
String uriPara(Directiva d, String cliente) {
  for (final (condicion, uri) in d.condicionales) {
    if (clientesDeCondicion(condicion).contains(cliente)) return uri;
  }
  return d.uri;
}

/// Para cada archivo de [fuentes], en qué clientes se usa.
Map<String, Set<String>> clientesPorArchivo(
    Map<String, String> fuentes, String paquete, String raizDeEntrada) {
  final directivas = {
    for (final e in fuentes.entries) e.key: directivasDart(e.value)
  };
  final importados = <String>{};
  for (final e in directivas.entries) {
    for (final d in e.value) {
      for (final uri in d.todasLasUri) {
        final r = resolverUri(e.key, uri, paquete);
        if (r != null && r != e.key) importados.add(r);
      }
    }
  }
  final raices = {
    if (fuentes.containsKey(raizDeEntrada)) raizDeEntrada,
    ...fuentes.keys.where((k) => !importados.contains(k)),
  };
  final usos = {for (final k in fuentes.keys) k: <String>{}};
  for (final cliente in clientes) {
    final pendientes = [...raices];
    final vistos = <String>{};
    while (pendientes.isNotEmpty) {
      final actual = pendientes.removeLast();
      if (!vistos.add(actual) || !fuentes.containsKey(actual)) continue;
      usos[actual]!.add(cliente);
      for (final d in directivas[actual]!) {
        final r = resolverUri(actual, uriPara(d, cliente), paquete);
        if (r != null) pendientes.add(r);
      }
    }
  }
  return usos;
}

final _condicionDePlataforma =
    RegExp(r'\bkIsWeb\b|\bPlatform\.is[A-Z]\w*|\bdefaultTargetPlatform\b|\bTargetPlatform\.');

/// Las líneas (desde 0) que están dentro de una rama por plataforma.
Set<int> lineasEnRamasDePlataforma(String fuente) {
  final clases = clasificarDart(fuente);
  final codigo = soloCodigo(fuente, clases);
  final lineaDe = lineaDeCadaPosicion(codigo);
  final tieneCodigo = lineasConCodigo(fuente, clases);
  final out = <int>{};

  void marcar(int desde, int hasta) {
    for (var l = lineaDe[desde]; l <= lineaDe[hasta]; l++) {
      if (l < tieneCodigo.length && tieneCodigo[l]) out.add(l);
    }
  }

  // Un bloque cuenta por sus líneas interiores: la del `if (...) {` y la de
  // la llave que cierra son estructura que se evalúa en todos los clientes.
  void marcarCuerpo(int inicio, int fin) {
    if (codigo[inicio] != '{' || lineaDe[inicio] == lineaDe[fin]) {
      marcar(inicio, fin);
      return;
    }
    for (var l = lineaDe[inicio] + 1; l < lineaDe[fin]; l++) {
      if (l < tieneCodigo.length && tieneCodigo[l]) out.add(l);
    }
  }

  int saltarEspacios(int i) {
    while (i < codigo.length && codigo[i].trim().isEmpty) {
      i++;
    }
    return i;
  }

  // Cuerpo de un if/else: un bloque, o una sola instrucción o elemento de
  // colección, que termina en `;` o `,` al mismo nivel o al cerrar su nivel.
  int finDelCuerpo(int i) {
    i = saltarEspacios(i);
    if (i < codigo.length && codigo[i] == '{') {
      final fin = llaveQueCierra(codigo, i);
      return fin < 0 ? codigo.length - 1 : fin;
    }
    var nivel = 0;
    for (var k = i; k < codigo.length; k++) {
      final c = codigo[k];
      if ('([{'.contains(c)) nivel++;
      if (')]}'.contains(c)) {
        if (nivel == 0) return k - 1;
        nivel--;
      }
      if ((c == ';' || c == ',') && nivel == 0) return k;
    }
    return codigo.length - 1;
  }

  for (final m in RegExp(r'\b(if|switch)\s*\(').allMatches(codigo)) {
    final abre = m.end - 1;
    final cierra = llaveQueCierra(codigo, abre);
    if (cierra < 0) continue;
    final condicion = codigo.substring(abre + 1, cierra);
    if (!_condicionDePlataforma.hasMatch(condicion)) continue;
    if (m.group(1) == 'switch') {
      final cuerpo = saltarEspacios(cierra + 1);
      if (cuerpo < codigo.length && codigo[cuerpo] == '{') {
        final fin = llaveQueCierra(codigo, cuerpo);
        if (fin > cuerpo) marcarCuerpo(cuerpo, fin);
      }
      continue;
    }
    var finEntonces = finDelCuerpo(cierra + 1);
    marcarCuerpo(saltarEspacios(cierra + 1), finEntonces);
    var siguiente = saltarEspacios(finEntonces + 1);
    // `else` y `else if`: todo el resto de la cadena depende de la plataforma.
    while (codigo.startsWith('else', siguiente)) {
      final cuerpo = saltarEspacios(siguiente + 4);
      if (codigo.startsWith('if', cuerpo)) {
        final abreElse = codigo.indexOf('(', cuerpo);
        final cierraElse = abreElse < 0 ? -1 : llaveQueCierra(codigo, abreElse);
        if (cierraElse < 0) break;
        finEntonces = finDelCuerpo(cierraElse + 1);
        marcarCuerpo(saltarEspacios(cierraElse + 1), finEntonces);
      } else {
        finEntonces = finDelCuerpo(cuerpo);
        marcarCuerpo(cuerpo, finEntonces);
      }
      siguiente = saltarEspacios(finEntonces + 1);
    }
  }
  // Un `?:` con condición de plataforma: la línea que lo contiene.
  final lineas = codigo.split('\n');
  for (var l = 0; l < lineas.length; l++) {
    final t = lineas[l];
    final plataforma = _condicionDePlataforma.firstMatch(t);
    if (plataforma != null &&
        RegExp(r'\?(?![?.\[])').hasMatch(t.substring(plataforma.end)) &&
        tieneCodigo[l]) {
      out.add(l);
    }
  }
  return out;
}

/// Un archivo nativo con su conteo frente a la plantilla.
class Nativo {
  final String ruta;
  final int lineas;
  final int deLaPlantilla;
  final String? plantilla;
  const Nativo(this.ruta, this.lineas, this.deLaPlantilla, this.plantilla);
  int get aMano => lineas - deLaPlantilla;
}

const _extensionesNativas = {
  '.cpp', '.h', '.rc', '.manifest', '.cmake', '.kt', '.java', '.xml', '.html',
  '.js', '.json', '.css',
};

bool esNativoContable(String ruta) {
  final r = ruta.replaceAll('\\', '/');
  if (r.startsWith('web/vendor/') || r.startsWith('web/fonts/')) return false;
  if (r.endsWith('CMakeLists.txt')) return true;
  final punto = r.lastIndexOf('.');
  return punto >= 0 && _extensionesNativas.contains(r.substring(punto));
}

/// Las líneas con código de un archivo nativo, según su lenguaje.
List<String> lineasNativas(String ruta, String texto) {
  final r = ruta.toLowerCase();
  String limpio;
  if (r.endsWith('.xml') || r.endsWith('.html') || r.endsWith('.manifest')) {
    limpio = texto.replaceAllMapped(
        RegExp(r'<!--[\s\S]*?-->'), (m) => m.group(0)!.replaceAll(RegExp(r'[^\n]'), ' '));
    if (r.endsWith('.html')) {
      // El JS dentro de <script> también puede llevar comentarios.
      limpio = _sinComentariosC(limpio);
    }
  } else if (r.endsWith('cmakelists.txt') || r.endsWith('.cmake')) {
    limpio = texto.split('\n').map((l) {
      final h = l.indexOf('#');
      return h < 0 ? l : l.substring(0, h);
    }).join('\n');
  } else if (r.endsWith('.json')) {
    limpio = texto;
  } else {
    limpio = _sinComentariosC(texto);
  }
  return limpio
      .split('\n')
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty)
      .toList();
}

/// Comentarios `//` y `/* */` de C, C++, Kotlin, Java y JS, respetando
/// cadenas con comillas simples, dobles e invertidas.
String _sinComentariosC(String s) {
  final b = StringBuffer();
  var i = 0;
  while (i < s.length) {
    final c = s[i];
    if (c == '"' || c == "'" || c == '`') {
      final inicio = i++;
      while (i < s.length && s[i] != c && s[i] != '\n') {
        if (s[i] == r'\') i++;
        i++;
      }
      i++;
      b.write(s.substring(inicio, i.clamp(0, s.length)));
      continue;
    }
    if (s.startsWith('//', i)) {
      while (i < s.length && s[i] != '\n') {
        i++;
      }
      continue;
    }
    if (s.startsWith('/*', i)) {
      final fin = s.indexOf('*/', i + 2);
      final hasta = fin < 0 ? s.length : fin + 2;
      b.write(s.substring(i, hasta).replaceAll(RegExp(r'[^\n]'), ' '));
      i = hasta;
      continue;
    }
    b.write(c);
    i++;
  }
  return b.toString();
}

/// La plantilla de `flutter create` que corresponde a [ruta], si existe.
String? plantillaPara(String ruta, String sdk) {
  final base = '$sdk/packages/flutter_tools/templates/app';
  final r = ruta.replaceAll('\\', '/');
  final candidatos = <String>[];
  if (r.startsWith('windows/runner/')) {
    candidatos.add('$base/windows.tmpl/runner/${r.substring('windows/runner/'.length)}');
  } else if (r.startsWith('android/app/src/main/kotlin/') && r.endsWith('MainActivity.kt')) {
    candidatos.add(
        '$base/android-kotlin.tmpl/app/src/main/kotlin/androidIdentifier/MainActivity.kt');
  } else if (r.startsWith('android/app/src/main/java/') && r.endsWith('MainActivity.java')) {
    candidatos.add(
        '$base/android-java.tmpl/app/src/main/java/androidIdentifier/MainActivity.java');
  } else if (r.startsWith('android/app/src/')) {
    candidatos.add('$base/android.tmpl/app/src/${r.substring('android/app/src/'.length)}');
  } else if (r.startsWith('web/')) {
    candidatos.add('$base/web/${r.substring('web/'.length)}');
  }
  for (final c in candidatos) {
    for (final p in [c, '$c.tmpl']) {
      if (File(p).existsSync()) return p;
    }
  }
  return null;
}

/// Cuántas líneas de [lineas] coinciden con la plantilla, emparejando cada
/// línea de la plantilla una sola vez. Un marcador `{{...}}` vale por
/// cualquier texto; las líneas de sección Mustache se ignoran.
int lineasDeLaPlantilla(List<String> lineas, String plantilla) {
  final patrones = <RegExp>[];
  for (final l in plantilla.split('\n').map((l) => l.trim())) {
    if (l.isEmpty || RegExp(r'^\{\{[#/^].*\}\}$').hasMatch(l)) continue;
    final partes = l.split(RegExp(r'\{\{[^}]*\}\}'));
    patrones.add(RegExp('^${partes.map(RegExp.escape).join('.*')}\$'));
  }
  final usadas = List<bool>.filled(patrones.length, false);
  var coinciden = 0;
  for (final l in lineas) {
    for (var k = 0; k < patrones.length; k++) {
      if (!usadas[k] && patrones[k].hasMatch(l)) {
        usadas[k] = true;
        coinciden++;
        break;
      }
    }
  }
  return coinciden;
}

List<Nativo> contarNativo(String raiz, String sdk) {
  final out = <Nativo>[];
  for (final carpeta in ['windows/runner', 'android/app/src', 'web']) {
    final dir = Directory('$raiz/$carpeta');
    if (!dir.existsSync()) continue;
    final base = Directory(raiz).absolute.path.replaceAll('\\', '/');
    final archivos = dir.listSync(recursive: true).whereType<File>().toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    for (final f in archivos) {
      final ruta = f.absolute.path.replaceAll('\\', '/').substring(base.length + 1);
      if (!esNativoContable(ruta)) continue;
      final texto = f.readAsStringSync();
      if (esGenerado(ruta, texto)) continue;
      final lineas = lineasNativas(ruta, texto);
      final plantilla = plantillaPara(ruta, sdk);
      final iguales = plantilla == null
          ? 0
          : lineasDeLaPlantilla(
              lineas, lineasNativas(ruta, File(plantilla).readAsStringSync()).join('\n'));
      out.add(Nativo(ruta, lineas.length, iguales, plantilla));
    }
  }
  return out;
}

void main(List<String> args) {
  if (args.length != 3) {
    stderr.writeln(
        'Uso: dart tool/t99_codigo_compartido.dart <raíz> <SDK de Flutter> <salida en %TEMP%>');
    exitCode = 64;
    return;
  }
  final raiz = args[0];
  final sdk = args[1].replaceAll('\\', '/');
  final salida = args[2];
  exigirSalidaEnTemp(salida, repo: raiz);
  carpetaNueva(salida);

  final pubspec = File('$raiz/pubspec.yaml').readAsLinesSync();
  final paquete = pubspec.firstWhere((l) => l.startsWith('name:')).substring(5).trim();
  final base = Directory('$raiz/lib').absolute.path.replaceAll('\\', '/');
  final fuentes = <String, String>{};
  final generados = <String>[];
  for (final f in Directory('$raiz/lib').listSync(recursive: true).whereType<File>()) {
    if (!f.path.endsWith('.dart')) continue;
    final ruta = 'lib${f.absolute.path.replaceAll('\\', '/').substring(base.length)}';
    final texto = f.readAsStringSync();
    if (esGenerado(ruta, texto)) {
      generados.add(ruta);
    } else {
      fuentes[ruta] = texto;
    }
  }
  final usos = clientesPorArchivo(fuentes, paquete, 'lib/main.dart');
  final filas = StringBuffer()
    ..writeln(filaCsv([
      'ruta', 'tipo', 'clientes', 'lineas', 'no_compartidas', 'compartidas',
      'de_plantilla', 'plantilla'
    ]));
  var totalDart = 0, compartidasDart = 0, ramas = 0, porArchivo = 0;
  final ordenadas = fuentes.keys.toList()..sort();
  for (final ruta in ordenadas) {
    final texto = fuentes[ruta]!;
    final lineas = contarLineasDeCodigo(texto);
    final enTodos = usos[ruta]!.length == clientes.length;
    final enRamas = enTodos ? lineasEnRamasDePlataforma(texto).length : lineas;
    totalDart += lineas;
    compartidasDart += lineas - enRamas;
    if (enTodos) {
      ramas += enRamas;
    } else {
      porArchivo += lineas;
    }
    filas.writeln(filaCsv([
      ruta, 'dart', (usos[ruta]!.toList()..sort()).join('+'), lineas, enRamas,
      lineas - enRamas, '', ''
    ]));
  }
  final nativos = contarNativo(raiz, sdk);
  var aMano = 0, dePlantilla = 0;
  for (final n in nativos) {
    aMano += n.aMano;
    dePlantilla += n.deLaPlantilla;
    filas.writeln(filaCsv([
      n.ruta, 'nativo', n.ruta.split('/').first, n.aMano, n.aMano, 0,
      n.deLaPlantilla, n.plantilla?.replaceFirst(sdk, '<sdk>') ?? ''
    ]));
  }
  File('$salida/codigo_compartido.csv').writeAsStringSync(filas.toString());
  final total = totalDart + aMano;
  final porcentaje = total == 0 ? 0.0 : 100 * compartidasDart / total;
  escribirJson('$salida/codigo_compartido.json', {
    'instrumento': 'tool/t99_codigo_compartido.dart',
    'sdk_plantillas': sdk,
    'archivos_dart': fuentes.length,
    'excluidos_generados': generados,
    'lineas_dart': totalDart,
    'lineas_dart_compartidas': compartidasDart,
    'lineas_dart_en_ramas_de_plataforma': ramas,
    'lineas_dart_en_archivos_de_una_parte_de_los_clientes': porArchivo,
    'lineas_nativas_a_mano': aMano,
    'lineas_nativas_de_plantilla_excluidas': dePlantilla,
    'excluido_por_regla': ['web/vendor/**', 'web/fonts/**'],
    'denominador': total,
    'porcentaje_compartido': porcentaje,
    'umbral_porcentaje': 95,
  });
  stdout.writeln('Dart: ${fuentes.length} archivos, $totalDart líneas, '
      '$compartidasDart compartidas ($ramas en ramas, $porArchivo en archivos '
      'que no usan los tres clientes).');
  stdout.writeln('Nativo: ${nativos.length} archivos, $aMano líneas a mano, '
      '$dePlantilla de plantilla (excluidas).');
  stdout.writeln('Compartido: ${cifra(porcentaje, 2)} % de $total líneas. Salida: $salida');
}
