// T-147 · La lectura de todo el corpus, antes y después.
//
// Lee cada `.edi` de las carpetas que se le pasan (todas FUERA del
// repositorio) con el lector del producto y guarda, por archivo, sus cuentas y
// dos huellas: la de lo leído (contenedores y celdas reservadas, campo por
// campo, sin el `id`, que es un UUID nuevo en cada lectura) y la de los avisos
// del lector. Con un listado, guarda además la huella de sus filas, de las
// equivalencias que propone la app y de su cruce con el plan. Con `--comparar`
// dice qué archivos cambian entre dos corridas.
//
//   dart run tool/t147_corpus.dart --salida build/t147/e1/corpus/antes.json
//       --carpeta "<corpus>" --carpeta "<escritorio>"
//       [--listado RUTA.xlsx --plan RUTA.edi --escala GTSTC]...
//   dart run tool/t147_corpus.dart --comparar ANTES.json DESPUES.json
//
// En la salida no va ninguna matrícula: solo cuentas y huellas SHA-256.
import 'dart:convert';
import 'dart:io';

import 'package:baystream/core/errors/exceptions.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/data/services/export_list_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/export_list_cross_checker.dart';
import 'package:crypto/crypto.dart';

String _huella(Object? valor) =>
    sha256.convert(utf8.encode(jsonEncode(valor))).toString();

Directory _fuera(String ruta) {
  final carpeta = Directory(ruta).absolute;
  final raiz = Directory.current.absolute.path.toLowerCase();
  if (carpeta.path.replaceAll('/', r'\').toLowerCase().startsWith(raiz)) {
    stderr.writeln('T-147: $ruta está dentro del repositorio.');
    exit(2);
  }
  return carpeta;
}

Map<String, Object?> _plan(File archivo) {
  final bytes = archivo.readAsBytesSync();
  final VesselVoyage viaje;
  try {
    viaje = BaplieParserService().parse(latin1.decode(bytes));
  } on BaplieParsingException catch (error) {
    return {
      'sha256': sha256.convert(bytes).toString(),
      'rechazado': error.code ?? error.message,
    };
  }
  return {
    'sha256': sha256.convert(bytes).toString(),
    'contenedores': viaje.containers.length,
    'reservas': viaje.reservedSlots.length,
    'bahias': viaje.bays.length,
    'lectura': _huella({
      'buque': viaje.vessel.name,
      'viaje': viaje.voyageNumber,
      'salida': viaje.portOfOrigin,
      'proxima': viaje.portOfNextCall,
      'contenedores': [
        for (final c in viaje.containers) c.toJson()..remove('id')
      ],
      'reservas': [for (final s in viaje.reservedSlots) s.toJson()],
    }),
    'avisos': {
      for (final aviso in viaje.readNotices)
        aviso.kind.name: aviso.details.length
    },
    'huellaDeLosAvisos': _huella([
      for (final aviso in viaje.readNotices)
        {'tipo': aviso.kind.name, 'detalles': aviso.details}
    ]),
  };
}

Map<String, Object?> _listado(File listado, File plan, String escala) {
  final lista = const ExportListParserService()
      .parseXlsx(listado.readAsBytesSync(), fileName: 'LISTADO.xlsx');
  final viaje = BaplieParserService()
      .parse(latin1.decode(plan.readAsBytesSync()))
      .copyWith(portOfCall: escala);
  final propuestas =
      ExportListCrossChecker.propose(lista, viaje, portOfCall: escala);
  final normalizada =
      lista.normalized(ExportListCrossChecker.tableOf(propuestas));
  final cruce = ExportListCrossChecker.crossCheck(normalizada, viaje, escala);
  return {
    'filas': lista.rows.length,
    'filasSinEntender': lista.issues.length,
    'secciones': lista.agencies.length,
    'pendientes': propuestas.where((p) => p.needsUser).length,
    'equivalencias': _huella([
      for (final p in propuestas)
        [p.kind.wire, p.listCode, p.planCode, p.origin.name, p.rows, p.observed]
    ]),
    'filasGuardadas': _huella(normalizada.toJson()),
    'cruce': {
      'llenosQueCruzan': cruce.matches.length,
      'llenosFueraDelPlan': cruce.fullsNotInPlan.length,
      'delPlanFueraDelListado': cruce.planNotInList.length,
      'vaciosEnGrupos': cruce.emptiesInGroups,
      'vaciosSinGrupo': cruce.emptiesWithoutGroup.length,
      'grupos': cruce.groups.length,
      'conDatosDistintos': cruce.matchesWithDifferences.length,
      'conVgmDistinto': cruce.weightDifferences,
    },
    'huellaDelCruce': _huella([
      for (final m in cruce.matches) [m.row.order, m.differences],
      for (final g in cruce.groups)
        [g.type, g.pod, g.line, g.planCells, g.empties.length],
      for (final n in cruce.dangerousGoods) [n.row.order, n.message],
    ]),
  };
}

void _comparar(String a, String b) {
  final antes = jsonDecode(File(a).readAsStringSync()) as Map<String, dynamic>;
  final despues = jsonDecode(File(b).readAsStringSync()) as Map<String, dynamic>;
  var distintos = 0;
  for (final grupo in const ['planes', 'listados']) {
    final viejos = antes[grupo] as Map<String, dynamic>;
    final nuevos = despues[grupo] as Map<String, dynamic>;
    for (final nombre in {...viejos.keys, ...nuevos.keys}.toList()..sort()) {
      final igual = jsonEncode(viejos[nombre]) == jsonEncode(nuevos[nombre]);
      if (!igual) distintos++;
      stdout.writeln('${igual ? 'igual   ' : 'DISTINTO'}  $nombre');
      if (!igual && viejos[nombre] is Map && nuevos[nombre] is Map) {
        final v = viejos[nombre] as Map<String, dynamic>;
        final n = nuevos[nombre] as Map<String, dynamic>;
        for (final clave in {...v.keys, ...n.keys}) {
          if (jsonEncode(v[clave]) != jsonEncode(n[clave])) {
            stdout.writeln('            $clave: ${jsonEncode(v[clave])} → '
                '${jsonEncode(n[clave])}');
          }
        }
      }
    }
  }
  stdout.writeln('$distintos distintos.');
}

void main(List<String> argumentos) {
  if (argumentos.length == 3 && argumentos.first == '--comparar') {
    _comparar(argumentos[1], argumentos[2]);
    return;
  }
  String? salida;
  final carpetas = <Directory>[];
  final listados = <({String listado, String plan, String escala})>[];
  String? listado;
  String? plan;
  for (var i = 0; i + 1 < argumentos.length; i += 2) {
    final valor = argumentos[i + 1];
    switch (argumentos[i]) {
      case '--salida':
        salida = valor;
      case '--carpeta':
        carpetas.add(_fuera(valor));
      case '--listado':
        listado = valor;
      case '--plan':
        plan = valor;
      case '--escala':
        listados.add((listado: listado!, plan: plan!, escala: valor));
      default:
        stderr.writeln('T-147: opción desconocida: ${argumentos[i]}');
        exit(2);
    }
  }
  if (salida == null ||
      !salida.replaceAll(r'\', '/').startsWith('build/t147/')) {
    stderr.writeln('T-147: --salida tiene que estar dentro de build/t147.');
    exit(2);
  }
  final planes = <String, Object?>{};
  for (final carpeta in carpetas) {
    final archivos = carpeta
        .listSync()
        .whereType<File>()
        .where((f) => f.path.toLowerCase().endsWith('.edi'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    for (final archivo in archivos) {
      planes[archivo.uri.pathSegments.last] = _plan(archivo);
    }
  }
  final resultado = {
    'planes': planes,
    'listados': {
      for (final caso in listados)
        File(caso.listado).uri.pathSegments.last: _listado(
            File(_fuera(File(caso.listado).parent.path).path +
                Platform.pathSeparator +
                File(caso.listado).uri.pathSegments.last),
            File(caso.plan),
            caso.escala)
    },
  };
  final texto = const JsonEncoder.withIndent('  ').convert(resultado);
  File(salida)
    ..parent.createSync(recursive: true)
    ..writeAsStringSync('$texto\n');
  stdout.writeln(texto);
}
