// T-99 · RNF-005, separación de capas (T-63, 5.2 «Capas»; umbral: 0).
//
// Cuenta las violaciones de las dos reglas de AGENTS.md:
//   1. ningún archivo de dominio importa Flutter, la capa de datos ni la de
//      presentación;
//   2. la presentación no importa la capa de datos.
// Cuenta `import` y `export`, con sus URI condicionales. Informa aparte, sin
// dictamen, lo que el dominio importa de Hive o Firebase (Definición de
// Terminado, 7). Solo lee: no toca el código.
//
//   dart tool/t99_capas.dart <raíz del proyecto> <salida en %TEMP%>
import 'dart:io';

import 't99_comun.dart';
import 't99_fuente.dart';

enum Capa { dominio, datos, presentacion, otra }

/// La capa por la ruta: `lib/features/<función>/<capa>/...`.
Capa capaDe(String ruta) {
  final r = ruta.replaceAll('\\', '/');
  final m = RegExp(r'^lib/features/[^/]+/(domain|data|presentation)/').firstMatch(r);
  return switch (m?.group(1)) {
    'domain' => Capa.dominio,
    'data' => Capa.datos,
    'presentation' => Capa.presentacion,
    _ => Capa.otra,
  };
}

class Violacion {
  final String archivo;
  final int linea;
  final String regla;
  final String importa;
  const Violacion(this.archivo, this.linea, this.regla, this.importa);
}

bool _esFlutter(String uri) =>
    uri.startsWith('package:flutter/') ||
    uri.startsWith('package:flutter_riverpod/') ||
    uri == 'dart:ui' ||
    uri.startsWith('dart:ui/');

bool _esHiveOFirebase(String uri) => RegExp(
        r'^package:(hive|hive_ce|hive_flutter|firebase_\w+|cloud_firestore)/')
    .hasMatch(uri);

/// Revisa un conjunto de fuentes (`lib/...` → texto) del paquete [paquete].
({List<Violacion> violaciones, List<Violacion> informativas}) revisarCapas(
    Map<String, String> fuentes, String paquete) {
  final violaciones = <Violacion>[];
  final informativas = <Violacion>[];
  for (final entrada in fuentes.entries) {
    final archivo = entrada.key.replaceAll('\\', '/');
    final capa = capaDe(archivo);
    if (capa != Capa.dominio && capa != Capa.presentacion) continue;
    for (final d in directivasDart(entrada.value)) {
      for (final uri in d.todasLasUri) {
        final destino = resolverUri(archivo, uri, paquete);
        final capaDestino = destino == null ? null : capaDe(destino);
        if (capa == Capa.dominio) {
          if (_esFlutter(uri)) {
            violaciones.add(Violacion(archivo, d.linea + 1, '1 · dominio → Flutter', uri));
          } else if (capaDestino == Capa.datos) {
            violaciones.add(Violacion(archivo, d.linea + 1, '1 · dominio → datos', uri));
          } else if (capaDestino == Capa.presentacion) {
            violaciones.add(
                Violacion(archivo, d.linea + 1, '1 · dominio → presentación', uri));
          } else if (_esHiveOFirebase(uri)) {
            informativas.add(
                Violacion(archivo, d.linea + 1, 'informativa · dominio → Hive/Firebase', uri));
          }
        } else if (capaDestino == Capa.datos) {
          violaciones.add(
              Violacion(archivo, d.linea + 1, '2 · presentación → datos', uri));
        }
      }
    }
  }
  return (violaciones: violaciones, informativas: informativas);
}

String nombreDelPaquete(String raiz) {
  final pubspec = File('$raiz/pubspec.yaml').readAsLinesSync();
  final linea = pubspec.firstWhere((l) => l.startsWith('name:'));
  return linea.substring(5).trim();
}

/// Las fuentes Dart de `lib/` sin lo generado; devuelve también lo excluido.
({Map<String, String> fuentes, List<String> excluidas}) fuentesDeLib(String raiz) {
  final base = Directory('$raiz/lib').absolute.path.replaceAll('\\', '/');
  final fuentes = <String, String>{};
  final excluidas = <String>[];
  final archivos = Directory('$raiz/lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  for (final f in archivos) {
    final ruta = 'lib${f.absolute.path.replaceAll('\\', '/').substring(base.length)}';
    final texto = f.readAsStringSync();
    if (esGenerado(ruta, texto)) {
      excluidas.add(ruta);
    } else {
      fuentes[ruta] = texto;
    }
  }
  return (fuentes: fuentes, excluidas: excluidas);
}

void main(List<String> args) {
  if (args.length != 2) {
    stderr.writeln('Uso: dart tool/t99_capas.dart <raíz> <salida en %TEMP%>');
    exitCode = 64;
    return;
  }
  final raiz = args[0];
  final salida = args[1];
  exigirSalidaEnTemp(salida, repo: raiz);
  carpetaNueva(salida);
  final lib = fuentesDeLib(raiz);
  final paquete = nombreDelPaquete(raiz);
  final r = revisarCapas(lib.fuentes, paquete);
  final porCapa = <String, int>{};
  for (final ruta in lib.fuentes.keys) {
    porCapa.update(capaDe(ruta).name, (n) => n + 1, ifAbsent: () => 1);
  }
  final csv = StringBuffer()
    ..writeln(filaCsv(['archivo', 'linea', 'regla', 'importa']));
  for (final v in [...r.violaciones, ...r.informativas]) {
    csv.writeln(filaCsv([v.archivo, v.linea, v.regla, v.importa]));
  }
  File('$salida/capas.csv').writeAsStringSync(csv.toString());
  final porRegla = <String, int>{};
  for (final v in r.violaciones) {
    porRegla.update(v.regla, (n) => n + 1, ifAbsent: () => 1);
  }
  escribirJson('$salida/capas.json', {
    'instrumento': 'tool/t99_capas.dart',
    'raiz': File(raiz).absolute.path,
    'archivos_por_capa': porCapa,
    'excluidos_generados': lib.excluidas,
    'violaciones': r.violaciones.length,
    'violaciones_por_regla': porRegla,
    'archivos_con_violaciones':
        r.violaciones.map((v) => v.archivo).toSet().length,
    'informativas_hive_firebase_en_dominio': r.informativas.length,
    'umbral': 0,
  });
  stdout.writeln('Capas: ${lib.fuentes.length} archivos de lib/ '
      '(${porCapa.entries.map((e) => '${e.key} ${e.value}').join(', ')}).');
  stdout.writeln('Violaciones: ${r.violaciones.length} '
      '(${porRegla.entries.map((e) => '${e.key}: ${e.value}').join('; ')}); '
      'informativas Hive/Firebase en dominio: ${r.informativas.length}.');
  stdout.writeln('Salida: $salida');
}
