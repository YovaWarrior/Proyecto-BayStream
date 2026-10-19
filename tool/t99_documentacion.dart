// T-99 · RNF-005, cobertura de documentación (T-63 5.1 (a); umbral: ≥ 80 %).
//
// Métrica: 1 − (señaladas / denominador), sobre clases y métodos públicos,
// con las dos pantallas de H5 dentro. La regla `public_member_api_docs` decide
// qué es público y qué sobrescribe a otro; este script solo clasifica lo que
// ella señala. Nunca toca el analysis_options.yaml versionado: trabaja sobre
// dos copias de lib/ en %TEMP%.
//   - con-docs: lib/ tal cual. Lo señalado es lo que no tiene `///`.
//   - sin-docs: lib/ con cada `///` cambiado por `// ` y cada `/**` por `/* `,
//     sin mover una sola columna. Lo señalado es todo el denominador.
//
// Pasos (los dos `dart analyze` piden semáforo a Carlos):
//   dart tool/t99_documentacion.dart preparar <raíz> <carpeta en %TEMP%>
//   (en <carpeta>/con-docs)  dart analyze --format=machine lib > analisis.txt
//   (en <carpeta>/sin-docs)  dart analyze --format=machine lib > analisis.txt
//   dart tool/t99_documentacion.dart resumir <carpeta> <salida en %TEMP%>
import 'dart:io';

import 't99_comun.dart';
import 't99_fuente.dart';

/// Las clases de declaración del denominador de 5.1 (a). `funcion` (de nivel
/// superior) se informa aparte, como lectura alternativa.
const clasesDelDenominador = {'clase', 'enum', 'mixin', 'extension', 'metodo'};

const opcionesDelAnalisis = '''
# T-99 · Solo para la copia temporal de RNF-005. No es el del repositorio.
analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
linter:
  rules:
    - public_member_api_docs
''';

/// Cambia `///` por `// ` y `/**` por `/* ` sin mover columnas.
String neutralizarDocumentacion(String fuente) {
  final clases = clasificarDart(fuente);
  final b = StringBuffer();
  for (var i = 0; i < fuente.length; i++) {
    final inicio = clases[i] == Clase.comentario &&
        (i == 0 || clases[i - 1] != Clase.comentario || fuente[i - 1] == '\n');
    if (inicio && fuente.startsWith('///', i) && !fuente.startsWith('////', i)) {
      b.write('// ');
      i += 2;
      continue;
    }
    if (inicio && fuente.startsWith('/**', i) && !fuente.startsWith('/**/', i)) {
      b.write('/* ');
      i += 2;
      continue;
    }
    b.write(fuente[i]);
  }
  return b.toString();
}

/// Un cuerpo de tipo (clase, enum, mixin o extensión) dentro de una fuente.
class _Cuerpo {
  final String clase;
  final String? nombre;
  final int abre;
  final int cierra;

  /// En un enum, dónde termina la lista de constantes.
  final int finDeConstantes;
  const _Cuerpo(this.clase, this.nombre, this.abre, this.cierra, this.finDeConstantes);
}

List<_Cuerpo> _cuerpos(String codigo) {
  final out = <_Cuerpo>[];
  final cabecera = RegExp(
      r'\b(class|enum|mixin|extension\s+type|extension)\b(?:\s+([A-Za-z_$][\w$]*))?');
  for (final m in cabecera.allMatches(codigo)) {
    final palabra = m.group(1)!.replaceAll(RegExp(r'\s+'), ' ');
    final nombre = m.group(2);
    // `mixin class X` se cuenta una vez, por `class`.
    if (palabra == 'mixin' && nombre == 'class') continue;
    if (palabra == 'extension' && nombre == 'type') continue;
    var nivel = 0;
    var abre = -1;
    for (var i = m.end; i < codigo.length; i++) {
      final c = codigo[i];
      if (c == '(' || c == '<' || c == '[') nivel++;
      if (c == ')' || c == '>' || c == ']') nivel--;
      if (c == ';' && nivel <= 0) break;
      if (c == '{' && nivel <= 0) {
        abre = i;
        break;
      }
    }
    if (abre < 0) continue;
    final cierra = llaveQueCierra(codigo, abre);
    if (cierra < 0) continue;
    var finDeConstantes = cierra;
    if (palabra == 'enum') {
      var n = 0;
      for (var i = abre + 1; i < cierra; i++) {
        final c = codigo[i];
        if ('({['.contains(c)) n++;
        if (')}]'.contains(c)) n--;
        if (c == ';' && n == 0) {
          finDeConstantes = i;
          break;
        }
      }
    }
    final clase = switch (palabra) {
      'class' => 'clase',
      'enum' => 'enum',
      'mixin' => 'mixin',
      _ => 'extension',
    };
    out.add(_Cuerpo(clase, nombre, abre, cierra, finDeConstantes));
  }
  return out;
}

final _memo = <String, ({String codigo, List<_Cuerpo> cuerpos})>{};

/// Clasifica la declaración que señala el analizador en [linea]:[columna]
/// (desde 1) de [fuente].
String clasificarDeclaracion(String fuente, int linea, int columna) {
  final memo = _memo.putIfAbsent(fuente, () {
    final codigo = soloCodigo(fuente);
    return (codigo: codigo, cuerpos: _cuerpos(codigo));
  });
  final codigo = memo.codigo;
  var pos = 0;
  for (var l = 1; l < linea; l++) {
    pos = codigo.indexOf('\n', pos) + 1;
  }
  pos += columna - 1;
  final ident = RegExp(r'[A-Za-z_$][\w$]*').matchAsPrefix(codigo, pos)?.group(0) ?? '';
  final inicioDeLinea = codigo.lastIndexOf('\n', pos - 1) + 1;
  final antes = codigo.substring(inicioDeLinea, pos).trimRight();
  final despues = codigo.substring(pos + ident.length).trimLeft();
  _Cuerpo? dentro;
  for (final c in memo.cuerpos) {
    if (c.abre < pos && pos < c.cierra && (dentro == null || c.abre > dentro.abre)) {
      dentro = c;
    }
  }
  // Una llave abierta entre el cuerpo del tipo y la posición es otro ámbito.
  final abiertas = <int>[];
  for (var i = dentro?.abre ?? -1; i < pos; i++) {
    if (i < 0) continue;
    if (codigo[i] == '{') abiertas.add(i);
    if (codigo[i] == '}' && abiertas.isNotEmpty) abiertas.removeLast();
  }
  final enElCuerpo = dentro != null && abiertas.length == 1;
  var nivelSuperior = dentro == null;
  if (dentro == null) {
    var n = 0;
    for (var i = 0; i < pos; i++) {
      if (codigo[i] == '{') n++;
      if (codigo[i] == '}') n--;
    }
    nivelSuperior = n == 0;
  }

  final tipo = RegExp(
          r'\b(class|enum|mixin|extension\s+type|extension)\s*$')
      .firstMatch(antes)
      ?.group(1);
  if (tipo != null) {
    return switch (tipo.split(RegExp(r'\s+')).first) {
      'class' => 'clase',
      'enum' => 'enum',
      'mixin' => antes.endsWith('class') ? 'clase' : 'mixin',
      _ => 'extension',
    };
  }
  if (RegExp(r'\btypedef\b').hasMatch(antes)) return 'typedef';
  if (RegExp(r'\bget$').hasMatch(antes)) return 'getter';
  if (RegExp(r'\bset$').hasMatch(antes)) return 'setter';
  if (RegExp(r'\boperator$').hasMatch(antes)) return 'metodo';
  if (enElCuerpo && dentro.clase == 'enum' && pos < dentro.finDeConstantes) {
    return 'constante_enum';
  }
  final invocable = despues.startsWith('(') || despues.startsWith('<');
  if (invocable) {
    if (enElCuerpo) {
      final nombre = dentro.nombre;
      if (nombre != null && (ident == nombre || antes.endsWith('$nombre.'))) {
        return 'constructor';
      }
      return 'metodo';
    }
    return nivelSuperior ? 'funcion' : 'otro';
  }
  if (enElCuerpo) return 'campo';
  return nivelSuperior ? 'variable' : 'otro';
}

/// Una línea de `dart analyze --format=machine`.
class Senal {
  final String archivo;
  final int linea;
  final int columna;
  const Senal(this.archivo, this.linea, this.columna);
  String get clave => '$archivo:$linea:$columna';
}

/// Los campos de una línea en formato máquina: separados por `|`, con `\\`
/// para la barra invertida y `\|` para la barra vertical.
List<String> camposDeMaquina(String linea) {
  final campos = <String>[];
  final b = StringBuffer();
  for (var i = 0; i < linea.length; i++) {
    final c = linea[i];
    if (c == r'\' && i + 1 < linea.length) {
      b.write(linea[++i]);
    } else if (c == '|') {
      campos.add(b.toString());
      b.clear();
    } else {
      b.write(c);
    }
  }
  campos.add(b.toString());
  return campos;
}

/// Las señales de `public_member_api_docs`, con rutas relativas a [raiz].
List<Senal> leerAnalisis(String texto, String raiz) {
  final base = rutaComparable(raiz);
  final out = <Senal>[];
  for (final l in texto.split(RegExp(r'\r?\n'))) {
    final p = camposDeMaquina(l);
    if (p.length < 8 || p[2].toLowerCase() != 'public_member_api_docs') continue;
    var ruta = p[3].replaceAll(r'\', '/');
    if (rutaComparable(ruta).startsWith('$base/')) {
      ruta = ruta.substring(base.length + 1);
    }
    out.add(Senal(ruta, int.parse(p[4]), int.parse(p[5])));
  }
  return out;
}

void _copiar(String origen, String destino) {
  for (final e in Directory(origen).listSync(recursive: true)) {
    final rel = e.path.substring(origen.length);
    if (e is Directory) {
      Directory('$destino$rel').createSync(recursive: true);
    } else if (e is File) {
      File('$destino$rel').parent.createSync(recursive: true);
      e.copySync('$destino$rel');
    }
  }
}

void preparar(String raiz, String destino) {
  exigirSalidaEnTemp(destino, repo: raiz);
  carpetaNueva(destino);
  for (final variante in ['con-docs', 'sin-docs']) {
    final d = '$destino/$variante';
    _copiar(Directory('$raiz/lib').absolute.path, '$d/lib');
    for (final f in ['pubspec.yaml', 'pubspec.lock']) {
      File('$raiz/$f').copySync('$d/$f');
    }
    Directory('$d/.dart_tool').createSync(recursive: true);
    for (final f in ['package_config.json', 'package_graph.json']) {
      final origen = File('$raiz/.dart_tool/$f');
      if (origen.existsSync()) origen.copySync('$d/.dart_tool/$f');
    }
    File('$d/analysis_options.yaml').writeAsStringSync(opcionesDelAnalisis);
    if (variante == 'sin-docs') {
      for (final f in Directory('$d/lib').listSync(recursive: true).whereType<File>()) {
        if (f.path.endsWith('.dart')) {
          f.writeAsStringSync(neutralizarDocumentacion(f.readAsStringSync()));
        }
      }
    }
  }
  escribirJson('$destino/preparacion.json', {
    'instrumento': 'tool/t99_documentacion.dart',
    'raiz': Directory(raiz).absolute.path,
    'archivos_dart': Directory('$destino/con-docs/lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .length,
    'siguiente': 'dart analyze --format=machine lib > analisis.txt en con-docs y en sin-docs',
  });
  stdout.writeln('Copias listas en $destino (con-docs y sin-docs).');
}

void resumir(String carpeta, String salida) {
  exigirSalidaEnTemp(salida);
  carpetaNueva(salida);
  final con = '$carpeta/con-docs';
  final sin = '$carpeta/sin-docs';
  final senaladas = leerAnalisis(File('$con/analisis.txt').readAsStringSync(), con);
  final todas = leerAnalisis(File('$sin/analisis.txt').readAsStringSync(), sin);
  final fuentes = <String, String>{};
  String fuente(String ruta) =>
      fuentes.putIfAbsent(ruta, () => File('$con/$ruta').readAsStringSync());
  final generados = <String>[
    for (final f in Directory('$con/lib').listSync(recursive: true).whereType<File>())
      if (f.path.endsWith('.dart') &&
          esGenerado(f.path, f.readAsStringSync()))
        f.path.substring(con.length + 1).replaceAll('\\', '/'),
  ];
  final claseDe = <String, String>{
    for (final s in todas)
      s.clave: clasificarDeclaracion(fuente(s.archivo), s.linea, s.columna)
  };
  final claves = todas.map((s) => s.clave).toSet();
  final fuera = senaladas.where((s) => !claves.contains(s.clave)).toList();
  final sinDoc = senaladas.map((s) => s.clave).toSet();

  final porClase = <String, ({int total, int sinDoc})>{};
  final porArchivo = <String, ({int total, int sinDoc})>{};
  final detalle = StringBuffer()
    ..writeln(filaCsv(['archivo', 'linea', 'columna', 'clase', 'documentado']));
  for (final s in todas) {
    final clase = claseDe[s.clave]!;
    final falta = sinDoc.contains(s.clave);
    final a = porClase[clase] ?? (total: 0, sinDoc: 0);
    porClase[clase] = (total: a.total + 1, sinDoc: a.sinDoc + (falta ? 1 : 0));
    if (clasesDelDenominador.contains(clase)) {
      final b = porArchivo[s.archivo] ?? (total: 0, sinDoc: 0);
      porArchivo[s.archivo] = (total: b.total + 1, sinDoc: b.sinDoc + (falta ? 1 : 0));
    }
    detalle.writeln(filaCsv([s.archivo, s.linea, s.columna, clase, falta ? 'no' : 'si']));
  }
  File('$salida/documentacion_detalle.csv').writeAsStringSync(detalle.toString());
  final archivos = StringBuffer()
    ..writeln(filaCsv(['archivo', 'clases_y_metodos', 'sin_documentar', 'h5']));
  for (final e in (porArchivo.entries.toList()..sort((a, b) => a.key.compareTo(b.key)))) {
    final h5 = e.key.endsWith('latency_test_screen.dart') ||
        e.key.endsWith('c3_reconciliation_screen.dart');
    archivos.writeln(filaCsv([e.key, e.value.total, e.value.sinDoc, h5 ? 'si' : '']));
  }
  File('$salida/documentacion_por_archivo.csv').writeAsStringSync(archivos.toString());

  ({int total, int sinDoc}) suma(Set<String> clases) {
    var t = 0, s = 0;
    for (final c in clases) {
      t += porClase[c]?.total ?? 0;
      s += porClase[c]?.sinDoc ?? 0;
    }
    return (total: t, sinDoc: s);
  }

  double cobertura(({int total, int sinDoc}) x) =>
      x.total == 0 ? 0 : 100 * (1 - x.sinDoc / x.total);
  final a = suma(clasesDelDenominador);
  final conFunciones = suma({...clasesDelDenominador, 'funcion'});
  escribirJson('$salida/documentacion.json', {
    'instrumento': 'tool/t99_documentacion.dart',
    'regla': 'public_member_api_docs',
    'senaladas_con_docs': senaladas.length,
    'senaladas_sin_docs': todas.length,
    'senaladas_fuera_del_denominador': fuera.map((s) => s.clave).toList(),
    'excluidos_generados': generados,
    'por_clase': {
      for (final e in porClase.entries)
        e.key: {'total': e.value.total, 'sin_documentar': e.value.sinDoc}
    },
    'denominador_5_1_a': a.total,
    'sin_documentar_5_1_a': a.sinDoc,
    'cobertura_5_1_a': cobertura(a),
    'alternativa_con_funciones_de_nivel_superior': {
      'denominador': conFunciones.total,
      'sin_documentar': conFunciones.sinDoc,
      'cobertura': cobertura(conFunciones),
    },
    'umbral_porcentaje': 80,
  });
  stdout.writeln('Señaladas: ${todas.length} sin documentación posible, '
      '${senaladas.length} con la documentación actual '
      '(${fuera.length} fuera del denominador).');
  stdout.writeln('Clases y métodos (5.1 a): ${a.total}, sin documentar ${a.sinDoc}, '
      'cobertura ${cifra(cobertura(a), 2)} %. Salida: $salida');
}

void main(List<String> args) {
  if (args.length == 3 && args[0] == 'preparar') {
    preparar(args[1], args[2]);
  } else if (args.length == 3 && args[0] == 'resumir') {
    resumir(args[1], args[2]);
  } else {
    stderr.writeln('Uso: dart tool/t99_documentacion.dart preparar <raíz> <carpeta en %TEMP%>\n'
        '     dart tool/t99_documentacion.dart resumir <carpeta> <salida en %TEMP%>');
    exitCode = 64;
  }
}
