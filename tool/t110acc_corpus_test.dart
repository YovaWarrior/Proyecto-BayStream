// Aceptación de T-110 (Timonel, 19-oct): cotejo propio de bahías,
// Estadísticas y lo guardado, con el lector y el codec reales.
//
// Corre igual en una copia del padre (246d577) y en una de HEAD:
// - en el padre, con T110ACC_CAPTURE_BASELINE=true, escribe la referencia;
// - en HEAD la compara: mismas bahías al reabrir y con geometría, mismas
//   ocupadas en Estadísticas, mismo registro local y mismos pesos.
// El corpus llega por BAYSTREAM_CORPUS_DIRECTORY y todo lo que escribe va a
// T110ACC_OUTPUT, en %TEMP%. Los tres sintéticos son propios y no traen datos
// reales; el instrumento los escribe también como .edi para los clientes.
import 'dart:convert';
import 'dart:io';

import 'package:baystream/features/vessel/data/datasources/local_vessel_codec.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const corpus = String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');
const output = String.fromEnvironment('T110ACC_OUTPUT');
const capture = bool.fromEnvironment('T110ACC_CAPTURE_BASELINE');

/// ACC1, el de la aceptación de T-108: sin UNB ni BGM; TNE, LBR, unidad
/// desconocida y sin unidad; dos posiciones mal formadas y dos dígitos malos.
const acc1 = "UNH+ACC1+BAPLIE:D:95B:UN:SMDG22'"
    "DTM+137:2610181200:201'"
    "TDT+20+ACC1+++TEST:172:20+++:::BUQUE ACEPTACION'"
    "LOC+5+GTSTC:139:6'"
    "LOC+147+0120082::5'MEA+VGM++TNE:23.4567'LOC+9+GTSTC:139:6'"
    "LOC+11+PAMIT:139:6'EQD+CN+TSTU0000020+22G1++2+5'"
    "LOC+147+0140082::5'MEA+WT++LBR:52910'LOC+9+GTSTC:139:6'"
    "LOC+11+PAMIT:139:6'EQD+CN+CSQU3054388+22G1++2+5'"
    "LOC+147+-120082::5'MEA+WT++KGM:12000'LOC+9+GTSTC:139:6'"
    "LOC+11+PAMIT:139:6'EQD+CN+CSQU3045383+22G1++2+5'"
    "LOC+147+016008::5'MEA+WT++XYZ:9000'LOC+9+GTSTC:139:6'"
    "LOC+11+PAMIT:139:6'EQD+CN+CSQU3054383+22G1++2+5'"
    "LOC+147+0180082::5'MEA+WT++15000'LOC+9+GTSTC:139:6'"
    "LOC+11+PAMIT:139:6'EQD+CN+MSCU1234566+22G1++2+5'"
    "UNT+30+ACC1'UNZ+1+ACC1'";

/// ACC2: un 20 en la 1, un 40 (45G1, de 9'6") en la 4, con sombra en 3 y 5, y
/// una reserva de 40 (45G1) en la 10, sin carga en 9, 10 ni 11. Solo le falta
/// UNZ.
const acc2 = "UNB+UNOA:2+ACEPTACION+BAYSTREAM+261019:1300+ACC2'"
    "UNH+ACC2+BAPLIE:D:95B:UN:SMDG22'BGM++ACC2+9'"
    "DTM+137:2610191300:201'"
    "TDT+20+ACC2+++TEST:172:20+++:::BUQUE ACEPTACION DOS'"
    "LOC+5+GTSTC:139:6'"
    "LOC+147+0010082::5'MEA+WT++KGM:12000'LOC+9+GTSTC:139:6'"
    "LOC+11+PAMIT:139:6'EQD+CN+MSCU1234566+22G1++2+5'"
    "LOC+147+0040082::5'MEA+WT++KGM:20000'LOC+9+GTSTC:139:6'"
    "LOC+11+PAMIT:139:6'EQD+CN+CSQU3054383+45G1++2+5'"
    "LOC+147+0100082::5'LOC+9+GTSTC:139:6'LOC+11+PAMIT:139:6'"
    "EQD+CN++45G1+++4'"
    "UNT+20+ACC2'";

/// ACC3: el mismo plano que ACC2, completo (con UNZ): sin ningún aviso.
const acc3 = "${acc2}UNZ+1+ACC2'";

class _Fixed extends VoyageNotifier {
  _Fixed(this.voyage);
  final VesselVoyage voyage;
  @override
  AsyncValue<VesselVoyage?> build() => AsyncData(voyage);
}

/// «Bahías ocupadas» de Estadísticas, leída del provider real.
int occupied(VesselVoyage voyage) {
  final container = ProviderContainer(
      overrides: [voyageNotifierProvider.overrideWith(() => _Fixed(voyage))]);
  try {
    return container.read(voyageStatsProvider)!.totalBays;
  } finally {
    container.dispose();
  }
}

/// JSON canónico sin los UUID (`id`), que cambian en cada lectura.
Object? canon(Object? value) {
  if (value is Map) {
    final keys = value.keys.map((key) => '$key').toList()..sort();
    return {
      for (final key in keys)
        if (key != 'id') key: canon(value[key]),
    };
  }
  if (value is List) return value.map(canon).toList();
  return value;
}

String fingerprint(Object? value) =>
    sha256.convert(utf8.encode(jsonEncode(canon(value)))).toString();

List<int> baysOf(VesselVoyage voyage) => voyage.bays.keys.toList()..sort();

Map<String, Object?> snapshot(String text) {
  const codec = LocalVesselCodec();
  final parsed = BaplieParserService().parse(text);
  final record = jsonDecode(codec.encodeVoyage(parsed)) as Map<String, dynamic>;
  final reopened = codec.decodeVoyage(codec.encodeVoyage(parsed));
  final geometry = VesselGeometry.proposeFrom(parsed.stowagePositions);
  final published =
      parsed.withGeometry(geometry, portOfCall: parsed.proposedPortOfCall);
  final publishedRecord = codec.encodeVoyage(published);
  final reopenedPublished = codec.decodeVoyage(publishedRecord);
  // Con perfil, Recientes vuelve a inyectar la geometría del perfil.
  final reopenedProfile = reopenedPublished.withGeometry(geometry);
  final data = Map<String, dynamic>.from(record['data'] as Map);
  final withoutNotices = Map<String, dynamic>.from(data)..remove('readNotices');
  final publishedData = Map<String, dynamic>.from(
      (jsonDecode(publishedRecord) as Map)['data'] as Map)
    ..remove('readNotices');
  // El aviso trae el texto del peso convertido, lo único que T-110 cambia.
  final exported = published.toJson()
    ..remove('bays')
    ..remove('readNotices');
  final bay27 = published.bays[27];
  return {
    'containers': parsed.totalContainers,
    'reserved': parsed.totalReservedSlots,
    'baysRead': baysOf(parsed),
    'baysReopen': baysOf(reopened),
    'baysGeometry': baysOf(published),
    'baysReopenGeometry': baysOf(reopenedPublished),
    'baysReopenProfile': baysOf(reopenedProfile),
    'occupiedRead': occupied(parsed),
    'occupiedGeometry': occupied(published),
    'occupiedReopen': occupied(reopenedPublished),
    'record': fingerprint(record),
    'recordWithoutNotices': fingerprint(withoutNotices),
    'publishedRecord': fingerprint(jsonDecode(publishedRecord)),
    'publishedWithoutNotices': fingerprint(publishedData),
    'exportWithoutBays': fingerprint(exported),
    'notices': [
      for (final notice in parsed.readNotices)
        {'kind': notice.kind.name, 'details': notice.details},
    ],
    'weights': [
      for (final unit in parsed.containers)
        [unit.containerId, unit.grossWeight, unit.vgmWeight],
    ],
    'totalWeight': parsed.totalWeight,
    'bay27': bay27 == null
        ? null
        : {
            'own': bay27.containers.length,
            'shadowSlots': bay27.slotsOccupiedByNeighbors.length,
            'hasGeometry': bay27.geometry != null,
          },
  };
}

Map<String, String> sources() {
  final files = <String, String>{'ACC1': acc1, 'ACC2': acc2, 'ACC3': acc3};
  final folder = Directory(corpus);
  final names = folder.listSync().whereType<File>()
      .map((file) => file.uri.pathSegments.last)
      .where((name) => name.startsWith('CORPUS_') && name.endsWith('.edi'))
      .toList()
    ..sort();
  for (final name in names) {
    files[name] = File('${folder.path}${Platform.pathSeparator}$name')
        .readAsStringSync(encoding: latin1);
  }
  return files;
}

void main() {
  test('T110ACC · bahías, Estadísticas y registro contra el padre', () {
    expect(corpus, isNotEmpty, reason: 'Falta BAYSTREAM_CORPUS_DIRECTORY');
    expect(output, contains('Temp'), reason: 'T110ACC_OUTPUT debe ir a TEMP');
    final out = Directory(output)..createSync(recursive: true);
    final synthetic = Directory('${out.path}${Platform.pathSeparator}sinteticos')
      ..createSync();
    for (final entry in {'ACC1': acc1, 'ACC2': acc2, 'ACC3': acc3}.entries) {
      File('${synthetic.path}${Platform.pathSeparator}${entry.key}.edi')
          .writeAsStringSync(entry.value, encoding: latin1);
    }
    final current = {
      for (final entry in sources().entries) entry.key: snapshot(entry.value),
    };
    const name = capture ? 'baseline.json' : 'head.json';
    File('${out.path}${Platform.pathSeparator}$name').writeAsStringSync(
        const JsonEncoder.withIndent(' ').convert(current));
    if (capture) {
      stdout.writeln('T110ACC_BASELINE ${current.length} archivos');
      return;
    }

    final base = jsonDecode(
            File('${out.path}${Platform.pathSeparator}baseline.json')
                .readAsStringSync())
        as Map<String, dynamic>;
    final lines = <String>[];
    for (final entry in current.entries) {
      final now = entry.value;
      final before = Map<String, dynamic>.from(base[entry.key] as Map);
      final read = now['baysRead'] as List<int>;
      // Una sola regla: leer, reabrir, con geometría y con perfil dan lo mismo.
      for (final key in [
        'baysReopen',
        'baysGeometry',
        'baysReopenGeometry',
        'baysReopenProfile',
      ]) {
        expect(now[key], read, reason: '${entry.key} $key');
      }
      // Lo que ya existía al reabrir y al publicar no cambia.
      for (final key in [
        'containers',
        'reserved',
        'baysReopen',
        'baysGeometry',
        'baysReopenGeometry',
        'occupiedGeometry',
        'occupiedReopen',
        'recordWithoutNotices',
        'publishedWithoutNotices',
        'exportWithoutBays',
        'weights',
        'totalWeight',
      ]) {
        expect(jsonEncode(now[key]), jsonEncode(before[key]),
            reason: '${entry.key} $key');
      }
      // Los avisos: mismos tipos y detalles; solo cambia «N.0 kg» por «N kg».
      String plain(Object? notices) => jsonEncode(notices)
          .replaceAllMapped(RegExp(r'(\d)\.0 kg'), (m) => '${m[1]} kg');
      expect(plain(now['notices']), plain(before['notices']),
          reason: '${entry.key} notices');
      expect(jsonEncode(now['notices']), isNot(contains('.0 kg')),
          reason: '${entry.key} notices sin .0');
      final added = read.where((b) => !(before['baysRead'] as List).contains(b));
      lines.add('${entry.key}: leer ${(before['baysRead'] as List).length}'
          ' -> ${read.length} (+${added.length}: ${added.join(', ')}); '
          'reabrir ${(now['baysReopen'] as List).length}; '
          'ocupadas al leer ${before['occupiedRead']} -> ${now['occupiedRead']}, '
          'publicado ${now['occupiedGeometry']}; '
          'registro ${now['record'] == before['record'] ? 'igual' : 'distinto'}, '
          'publicado ${now['publishedRecord'] == before['publishedRecord'] ? 'igual' : 'distinto'}'
          '${jsonEncode(now['notices']) == jsonEncode(before['notices']) ? '' : '; avisos: ${jsonEncode(before['notices'])} -> ${jsonEncode(now['notices'])}'}');
    }
    File('${out.path}${Platform.pathSeparator}resumen.txt')
        .writeAsStringSync('${lines.join('\n')}\n');
    stdout.writeln(lines.join('\n'));
  });
}
