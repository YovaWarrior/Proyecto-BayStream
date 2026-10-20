// Salida agregada: nunca IDs, nombres de buque ni fragmentos del corpus.
import 'dart:io';

import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';

import 't98_support.dart';

const t98CorpusNames = [
  'A01',
  'A02',
  'A03',
  'A04',
  'A05',
  'A06',
  'A07',
  'A08',
  'A03v_VGM',
  'A08v_VGM',
];

/// Cap. 7: contextos distintos para etiquetas repetidas; X no se exige.
const t98GuidePaths = [
  'servicio/UNB',
  'cabecera/UNH',
  'cabecera/BGM',
  'cabecera/DTM',
  'SG1/TDT',
  'SG1/LOC',
  'SG1/DTM',
  'SG1/RFF',
  'SG2/LOC',
  'SG2/GID',
  'SG2/GDS',
  'SG2/FTX',
  'SG2/MEA',
  'SG2/DIM',
  'SG2/TMP',
  'SG2/RNG',
  'SG2/RFF',
  'SG3/EQD',
  'SG3/EQA',
  'SG3/NAD',
  'SG4/DGS',
  'SG4/FTX',
  'cierre/UNT',
  'servicio/UNZ',
];

Set<String> t98Coverage(List<String> segments) {
  final paths = <String>{};
  var group = 'cabecera';
  for (final segment in segments) {
    final elements = segment.split('+');
    final tag = elements.first;
    if (tag == 'TDT') group = 'SG1';
    if (tag == 'LOC' && elements.elementAtOrNull(1) == '147') group = 'SG2';
    if (tag == 'EQD') group = 'SG3';
    if (tag == 'DGS') group = 'SG4';
    final context = switch (tag) {
      'UNB' || 'UNZ' => 'servicio',
      'UNT' => 'cierre',
      _ => group,
    };
    paths.add('$context/$tag');
  }
  return paths;
}

void main(List<String> args) {
  const corpus = String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');
  const phase = String.fromEnvironment('T98_FASE', defaultValue: 'A');
  const base = String.fromEnvironment('T98_BASE');
  if (args.length != 3 ||
      corpus.isEmpty ||
      !['A', 'B'].contains(phase) ||
      (phase == 'B' && !RegExp(r'^[a-f0-9]{40}$').hasMatch(base))) {
    throw ArgumentError('Declarar BAYSTREAM_CORPUS_DIRECTORY, T98_FASE y '
        'T98_BASE por --define; pasar UNECE_CSV EDICION SALIDA_TEMP.');
  }
  final output = t98Output(args[2]);
  final locodes = t98Locodes(Directory(args[0]));
  final rows = <Object>[];
  final coverage = <String, List<String>>{
    for (final path in t98GuidePaths) path: [],
  };
  for (final name in t98CorpusNames) {
    final file = File('$corpus/CORPUS_$name.edi');
    if (!file.existsSync()) throw StateError('Falta CORPUS_$name.edi.');
    final source = file.readAsStringSync();
    final segments = t98Segments(source);
    final observed = t98Coverage(segments);
    for (final path in t98GuidePaths) {
      if (observed.contains(path)) coverage[path]!.add(name);
    }
    var positions = 0;
    var invalidPositions = 0;
    var ports = 0;
    var unknownPorts = 0;
    var ids = 0;
    var validIds = 0;
    var eqdWithoutId = 0;
    final weightUnits = <String, int>{};
    final sourceKg = <String, double>{};
    var weightsNotComparable = 0;
    for (final segment in segments) {
      final e = segment.split('+');
      if (e.first == 'LOC' && e.length >= 3) {
        final value = e[2].split(':').first;
        if (e[1] == '147') {
          positions++;
          if (!IsoCoordinateParser.isValid(value)) invalidPositions++;
        } else if (['5', '61', '9', '11', '76', '83', '152'].contains(e[1])) {
          ports++;
          if (!locodes.contains(value)) unknownPorts++;
        }
      }
      if (e.first == 'EQD' && e.length >= 3 && e[1] == 'CN') {
        if (e[2].trim().isEmpty) {
          eqdWithoutId++;
        } else {
          ids++;
          if (t98ValidId(e[2])) validIds++;
        }
      }
      if (e.first == 'MEA' && e.length >= 4) {
        const qualifiers = {'WT', 'VGM', 'T'};
        final qualifier = qualifiers.contains(e[1]) ? e[1] : e[2];
        if (!qualifiers.contains(qualifier)) continue;
        final components = e[3].split(':');
        final unit = components.first;
        final publicUnit =
            {'KGM', 'LBR', 'TNE'}.contains(unit) ? unit : 'OTRA_O_AUSENTE';
        weightUnits.update('$qualifier/$publicUnit', (n) => n + 1,
            ifAbsent: () => 1);
        final value = double.tryParse(components.elementAtOrNull(1) ?? '');
        if (unit == 'KGM' && value != null && value.isFinite) {
          sourceKg.update(qualifier, (sum) => sum + value,
              ifAbsent: () => value);
        } else {
          // No adivinar cifras ni convertir formatos fuera del cotejo KGM.
          weightsNotComparable++;
        }
      }
    }
    var accepted = false;
    var notice = false;
    final parsedWeights = <String, Object>{};
    try {
      final voyage = BaplieParserService().parse(source);
      accepted = true;
      notice = voyage.metadata?.readWithV2Rules ?? false;
      final reservedWeights = voyage.reservedSlots
          .map((slot) => slot.nominalWeight)
          .whereType<double>()
          .toList();
      parsedWeights['reservas'] = {
        'huecos': voyage.reservedSlots.length,
        'conPesoNominal': reservedWeights.length,
        'sumaNominalKg':
            reservedWeights.fold<double>(0, (sum, weight) => sum + weight),
      };
      final values = {
        'WT': voyage.containers.map((c) => c.grossWeight),
        'VGM': voyage.containers.map((c) => c.vgmWeight),
        'T': voyage.containers.map((c) => c.tareWeight),
      };
      for (final entry in values.entries) {
        final weights = entry.value.whereType<double>().toList();
        parsedWeights[entry.key] = {
          'contenedoresConPeso': weights.length,
          'sumaKg': weights.fold<double>(0, (sum, weight) => sum + weight),
        };
      }
    } catch (_) {
      // No volcar la excepción: puede contener datos comerciales.
    }
    rows.add({
      'archivo': name,
      'sha256': t98Hash(file.readAsBytesSync()),
      'lectorAcepta': accepted,
      'aviso15': notice,
      'posiciones': positions,
      'posicionesInvalidas': invalidPositions,
      'puertosOcurrencias': ports,
      'puertosAusentesLista': unknownPorts,
      'ids': ids,
      'eqdSinIdentificador': eqdWithoutId,
      'idsDigitoValido': validIds,
      'porcentajeIdsValido': ids == 0 ? null : validIds * 100 / ids,
      'meaUnidadesPorCalificador': weightUnits,
      'sumaFuenteKgm': sourceKg,
      'meaFueraCotejoKgmCanonico': weightsNotComparable,
      'pesosModelo': parsedWeights,
    });
  }
  final csvFiles = Directory(args[0])
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.csv'));
  t98Json(File('${output.path}/estandares-corpus.json'), {
    'fase': phase,
    'base': base,
    'guia': t98Guide,
    'edicionUnlocode': args[1],
    'controlListaUnlocode': {
      for (final code in ['GTSTC', 'PAMIT', 'ZZZZZ'])
        code: locodes.contains(code),
    },
    'listaHuella': {
      for (final f in csvFiles)
        f.uri.pathSegments.last: t98Hash(f.readAsBytesSync())
    },
    'aviso': 'Corpus anonimizado: los IDs no certifican ISO 6346. '
        'Presencia de segmentos/grupos no certifica conformidad; '
        'la cobertura ausente queda visible. A06 es 1.5 con aviso. '
        'Pesos de fuente: MEA WT/VGM/T con KGM:valor. La fuente puede incluir '
        'reservas sin contenedor; el modelo cuenta solo contenedores. '
        'El porcentaje ISO excluye EQD sin identificador y los cuenta aparte. '
        'Los formatos no comparables se declaran, sin inventar conversiones.',
    'cobertura': coverage,
    'grupos': {
      for (final group in ['SG1', 'SG2', 'SG3', 'SG4'])
        group: coverage.entries
            .where((e) => e.key.startsWith('$group/'))
            .expand((e) => e.value)
            .toSet()
            .toList()
          ..sort()
    },
    'archivos': rows,
  });
  stdout.writeln(
      'T-98: corpus y cobertura contextual procesados; salida agregada en TEMP.');
}
