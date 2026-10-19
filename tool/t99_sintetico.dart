// T-99 · Archivos sintéticos de 5 000 y 10 000 contenedores (RNF-001 y 007).
//
// Son CARGA DE PRUEBA, no viajes (T-63 1.4 (a); AGENTS.md: no inventar datos).
// Se construyen con la estructura de A01: cabecera, grupos de segmentos por
// contenedor (tipo, pesos, puertos, refrigerados y peligrosas) y cola, en el
// orden del archivo y repitiéndolo. Cambian la identidad del buque, el número
// de cada contenedor (SNTU, con su dígito ISO 6346) y la posición, que sale de
// una geometría sintética de portacontenedores grande que admite 10 000:
//   - 24 bahías de 40 (02, 06, … 94), cada una con sus dos impares de 20;
//   - filas 01 a 22; bodega 02 a 20 y cubierta 82 a 98;
//   - 528 pilas × 19 niveles: 10 032 huecos de 40, unos 20 000 TEU.
// Cada pila es de 40 o de 20 según la proporción de A01, repartidas a lo largo
// del buque, y se llenan nivel por nivel, como un buque cargado parejo.
//
// Las salidas van solo a %TEMP%. El script se verifica con el lector real:
// si no abre un archivo o da otra cuenta, falla y hay que detenerse (ficha).
//
//   dart tool/t99_sintetico.dart <CORPUS_A01.edi> <salida en %TEMP%> 5000 10000
import 'dart:io';

import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';

import 't99_comun.dart';

/// Separa segmentos EDIFACT por `'`, respetando el carácter de escape `?`.
List<String> segmentosEdifact(String texto) {
  final out = <String>[];
  final b = StringBuffer();
  for (var i = 0; i < texto.length; i++) {
    final c = texto[i];
    if (c == '?' && i + 1 < texto.length) {
      b
        ..write(c)
        ..write(texto[++i]);
      continue;
    }
    if (c == "'") {
      final s = b.toString().trim();
      if (s.isNotEmpty) out.add(s);
      b.clear();
      continue;
    }
    b.write(c);
  }
  final s = b.toString().trim();
  if (s.isNotEmpty) out.add(s);
  return out;
}

/// Cabecera, grupos por contenedor (desde cada `LOC+147`) y cola (UNT, UNZ).
({List<String> cabecera, List<List<String>> grupos, List<String> cola})
    estructuraBaplie(List<String> segmentos) {
  final cabecera = <String>[];
  final grupos = <List<String>>[];
  final cola = <String>[];
  for (final s in segmentos) {
    if (s.startsWith('UNT+') || s.startsWith('UNZ+')) {
      cola.add(s);
    } else if (s.startsWith('LOC+147+')) {
      grupos.add([s]);
    } else if (grupos.isEmpty) {
      cabecera.add(s);
    } else {
      grupos.last.add(s);
    }
  }
  return (cabecera: cabecera, grupos: grupos, cola: cola);
}

/// Dígito de control ISO 6346 de un código de 10 caracteres (dueño,
/// categoría y serie). Letras con su valor, sin los múltiplos de 11.
int digitoIso6346(String diez) {
  const valores = {
    'A': 10, 'B': 12, 'C': 13, 'D': 14, 'E': 15, 'F': 16, 'G': 17, 'H': 18,
    'I': 19, 'J': 20, 'K': 21, 'L': 23, 'M': 24, 'N': 25, 'O': 26, 'P': 27,
    'Q': 28, 'R': 29, 'S': 30, 'T': 31, 'U': 32, 'V': 34, 'W': 35, 'X': 36,
    'Y': 37, 'Z': 38,
  };
  if (diez.length != 10) throw ArgumentError('Se esperan 10 caracteres: $diez');
  var suma = 0;
  for (var i = 0; i < 10; i++) {
    final c = diez[i];
    final v = valores[c] ?? int.parse(c);
    suma += v << i;
  }
  return suma % 11 % 10;
}

/// Número sintético de contenedor: dueño SNTU, serie y dígito de control.
String idSintetico(int n) {
  final diez = 'SNTU${n.toString().padLeft(6, '0')}';
  return '$diez${digitoIso6346(diez)}';
}

/// Número IMO de siete dígitos con su dígito de control.
String imoSintetico(String seis) {
  var suma = 0;
  for (var i = 0; i < 6; i++) {
    suma += int.parse(seis[i]) * (7 - i);
  }
  return '$seis${suma % 10}';
}

/// La geometría sintética descrita arriba.
class GeometriaSintetica {
  final List<int> bahias40 = [for (var b = 2; b <= 94; b += 4) b];
  final List<int> filas = [for (var r = 1; r <= 22; r++) r];
  final List<int> niveles = [
    for (var t = 2; t <= 20; t += 2) t,
    for (var t = 82; t <= 98; t += 2) t,
  ];
  int get pilas => bahias40.length * filas.length;
}

String posicionIso(int bahia, int fila, int nivel) =>
    '${bahia.toString().padLeft(3, '0')}${fila.toString().padLeft(2, '0')}'
    '${nivel.toString().padLeft(2, '0')}';

/// Un tipo ISO de 20 pies empieza por 2; lo demás (40, 45…) va en una de 40.
bool esDeVeinte(String tipoIso) => tipoIso.startsWith('2');

String? _tipoDelGrupo(List<String> grupo) {
  for (final s in grupo) {
    if (s.startsWith('EQD+CN+')) {
      final e = s.split('+');
      return e.length > 3 ? e[3] : null;
    }
  }
  return null;
}

/// Las posiciones para [de40] contenedores de 40 y [de20] de 20, en el orden
/// de llenado. Devuelve dos listas: la de 40 y la de 20.
({List<String> de40, List<String> de20}) posicionesSinteticas(
    GeometriaSintetica g, int de40, int de20) {
  final pilas = g.pilas;
  final niveles = g.niveles.length;
  var pilas20 = (pilas * (de20 / 2) / (de40 + de20 / 2)).ceil();
  while (de20 > pilas20 * 2 * niveles) {
    pilas20++;
  }
  if (de40 > (pilas - pilas20) * niveles) {
    throw StateError('La geometría sintética no admite $de40 de 40 y $de20 de 20');
  }
  bool esPila20(int k) => (k + 1) * pilas20 ~/ pilas > k * pilas20 ~/ pilas;
  final p40 = <String>[];
  final p20 = <String>[];
  for (final nivel in g.niveles) {
    for (var k = 0; k < pilas; k++) {
      final bahia = g.bahias40[k ~/ g.filas.length];
      final fila = g.filas[k % g.filas.length];
      if (esPila20(k)) {
        for (final b in [bahia - 1, bahia + 1]) {
          if (p20.length < de20) p20.add(posicionIso(b, fila, nivel));
        }
      } else if (p40.length < de40) {
        p40.add(posicionIso(bahia, fila, nivel));
      }
    }
  }
  return (de40: p40, de20: p20);
}

/// Genera el BAPLIE sintético de [cantidad] contenedores a partir de [plantilla].
({String texto, Map<String, Object?> datos}) generarSintetico(
    String plantilla, int cantidad) {
  final e = estructuraBaplie(segmentosEdifact(plantilla));
  final grupos = e.grupos.where((g) => _tipoDelGrupo(g) != null).toList();
  if (grupos.isEmpty) throw StateError('La plantilla no trae contenedores');
  final secuencia = [for (var i = 0; i < cantidad; i++) grupos[i % grupos.length]];
  final cola40 = secuencia.where((g) => !esDeVeinte(_tipoDelGrupo(g)!)).toList();
  final cola20 = secuencia.where((g) => esDeVeinte(_tipoDelGrupo(g)!)).toList();
  final geometria = GeometriaSintetica();
  final posiciones = posicionesSinteticas(geometria, cola40.length, cola20.length);

  final referencia = 'T99S$cantidad';
  final nombre = 'T99 SINTETICO $cantidad';
  final imo = imoSintetico('99${(cantidad ~/ 1000).toString().padLeft(3, '0')}0');
  String cabecera(String s) {
    final el = s.split('+');
    if (s.startsWith('UNB+') && el.length > 5) {
      el[5] = referencia;
    } else if (s.startsWith('BGM+') && el.length > 2) {
      el[2] = 'T99SINTETICO$cantidad';
    } else if (s.startsWith('TDT+')) {
      if (el.length > 2) el[2] = referencia;
      for (var i = 0; i < el.length; i++) {
        final c = el[i].split(':');
        if (c.length >= 4 && c[1] == '146') {
          c[0] = imo;
          c[3] = nombre;
          el[i] = c.join(':');
        }
      }
    } else if (s.startsWith('RFF+VON:')) {
      return 'RFF+VON:$referencia';
    }
    return el.join('+');
  }

  var serie = 0;
  List<String> contenedor(List<String> grupo, String posicion) => [
        for (final s in grupo)
          if (s.startsWith('LOC+147+'))
            'LOC+147+$posicion${s.substring(8).contains(':') ? s.substring(8 + s.substring(8).indexOf(':')) : ''}'
          else if (s.startsWith('EQD+CN+'))
            (s.split('+')..[2] = idSintetico(++serie)).join('+')
          else
            s,
      ];

  final cuerpo = <String>[
    for (var i = 0; i < cola40.length; i++) ...contenedor(cola40[i], posiciones.de40[i]),
    for (var i = 0; i < cola20.length; i++) ...contenedor(cola20[i], posiciones.de20[i]),
  ];
  final encabezado = e.cabecera.map(cabecera).toList();
  final desdeUnh = encabezado.indexWhere((s) => s.startsWith('UNH+'));
  final unhRef = encabezado[desdeUnh].split('+')[1];
  final segmentosMensaje = encabezado.length - desdeUnh + cuerpo.length + 1;
  final todos = [
    ...encabezado,
    ...cuerpo,
    'UNT+$segmentosMensaje+$unhRef',
    'UNZ+1+$referencia',
  ];
  final separador = plantilla.contains("'\r\n") ? "'\r\n" : plantilla.contains("'\n") ? "'\n" : "'";
  final texto = '${todos.join(separador)}$separador';
  return (
    texto: texto,
    datos: {
      'aviso': 'Carga de prueba sintética de T-99. No es un viaje ni evidencia de un buque real.',
      'contenedores': cantidad,
      'de_40': cola40.length,
      'de_20': cola20.length,
      'grupos_de_la_plantilla': grupos.length,
      'segmentos': todos.length,
      'buque': nombre,
      'imo_sintetico': imo,
      'geometria': {
        'bahias_de_40': geometria.bahias40,
        'filas': '01-22',
        'bodega': '02-20',
        'cubierta': '82-98',
        'pilas': geometria.pilas,
        'huecos_de_40': geometria.pilas * geometria.niveles.length,
      },
    },
  );
}

/// Abre el archivo con el lector real y comprueba la cuenta y las posiciones.
Map<String, Object?> verificarConElLector(String texto, int esperados) {
  final viaje = BaplieParserService().parse(texto);
  final posiciones =
      viaje.containers.map((c) => c.stowagePosition?.toIsoCode()).toSet();
  final perfil = VesselProfile.proposeFrom(viaje);
  // Desde T-108 el lector avisa pesos, posiciones, dígitos y archivos
  // incompletos. Un sintético con avisos sería otra carga: tiene que salir limpio.
  final avisos = <String, int>{
    for (final a in viaje.readNotices) a.kind.name: a.details.length,
  };
  return {
    'lector': 'BaplieParserService',
    'contenedores_leidos': viaje.totalContainers,
    'contenedores_esperados': esperados,
    'cuenta_exacta': viaje.totalContainers == esperados,
    'avisos_del_lector': avisos,
    'posiciones_unicas': posiciones.length,
    'bahias': viaje.bays.length,
    'geometria_propuesta_cubre_todo': perfil.geometry.coversAll(viaje.stowagePositions),
  };
}

void main(List<String> args) {
  if (args.length < 3) {
    stderr.writeln('Uso: dart tool/t99_sintetico.dart <CORPUS_A01.edi> <salida en %TEMP%> <N> [<N>…]');
    exitCode = 64;
    return;
  }
  final plantilla = File(args[0]);
  final salida = args[1];
  exigirSalidaEnTemp(salida, repo: Directory.current.path);
  carpetaNueva(salida);
  final texto = plantilla.readAsStringSync();
  final manifiesto = <String, Object?>{
    'instrumento': 'tool/t99_sintetico.dart',
    'plantilla': {
      'archivo': plantilla.uri.pathSegments.last,
      'sha256': sha256DeArchivo(plantilla.path),
    },
    'archivos': <Object?>[],
  };
  var fallo = false;
  for (final n in args.skip(2).map(int.parse)) {
    final g = generarSintetico(texto, n);
    final nombre = 'T99_SINTETICO_$n.edi';
    File('$salida/$nombre').writeAsStringSync(g.texto);
    final verificacion = verificarConElLector(g.texto, n);
    (manifiesto['archivos'] as List).add({
      'archivo': nombre,
      'sha256': sha256DeArchivo('$salida/$nombre'),
      'bytes': File('$salida/$nombre').lengthSync(),
      ...g.datos,
      'verificacion': verificacion,
    });
    final ok = verificacion['cuenta_exacta'] == true &&
        verificacion['posiciones_unicas'] == n &&
        verificacion['geometria_propuesta_cubre_todo'] == true &&
        (verificacion['avisos_del_lector'] as Map).isEmpty;
    fallo = fallo || !ok;
    stdout.writeln('$nombre: ${verificacion['contenedores_leidos']} leídos de $n, '
        '${verificacion['posiciones_unicas']} posiciones, '
        '${verificacion['bahias']} bahías, avisos del lector '
        '${verificacion['avisos_del_lector']}${ok ? '' : ' · DETENTE: no cuadra'}');
  }
  escribirJson('$salida/manifiesto.json', manifiesto);
  stdout.writeln('Carga de prueba sintética, no un viaje. Salida: $salida');
  if (fallo) exitCode = 1;
}
