// Corpus externo; referencias y resultados solo en TEMP. Compatible con HEAD.
import 'dart:convert';
import 'dart:io';
import 'package:baystream/features/vessel/data/datasources/local_vessel_codec.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';
import 't98_support.dart';

Object? _stable(Object? value) {
  if (value is Map) {
    final keys = value.keys.map((key) => key.toString()).toList()..sort();
    return {
      for (final key in keys)
        if (key != 'id') key: _stable(value[key])
    };
  }
  if (value is List) return value.map(_stable).toList();
  return value;
}

String _hash(Object? value) => t98Hash(utf8.encode(jsonEncode(_stable(value))));
List<int> _numbers(VesselVoyage voyage) => voyage.bays.keys.toList()..sort();

void main() {
  const corpus = String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');
  const destination = String.fromEnvironment('T110_OUTPUT');
  const capture = bool.fromEnvironment('T110_CAPTURE');
  final output = t98Output(destination);
  final baselineFile = File('${output.path}/baseline.json');
  final baseline = capture
      ? <String, dynamic>{}
      : jsonDecode(baselineFile.readAsStringSync()) as Map<String, dynamic>;
  final rows = <Map<String, Object?>>[];
  for (final name in [
    'A01',
    'A02',
    'A03',
    'A03v_VGM',
    'A04',
    'A05',
    'A06',
    'A07',
    'A08',
    'A08v_VGM'
  ]) {
    test('T110 $name solo lista de bahías', () {
      final file = File('$corpus/CORPUS_$name.edi');
      final voyage = BaplieParserService().parse(file.readAsStringSync());
      final fixed = voyage
          .withGeometry(VesselGeometry.proposeFrom(voyage.stowagePositions));
      const codec = LocalVesselCodec();
      final reopened = codec.decodeVoyage(codec.encodeVoyage(voyage));
      final facts = {
        'source': t98Hash(file.readAsBytesSync()),
        'withoutBays': _hash(voyage.toJson(includeBays: false)),
        'withGeometry': _hash(fixed.toJson()),
        'stored': _hash(jsonDecode(codec.encodeVoyage(voyage))),
        'containers': voyage.totalContainers,
        'weightKg': voyage.totalWeight,
        'reservations': voyage.totalReservedSlots,
      };
      if (capture) {
        baseline[name] = {
          'facts': facts,
          'read': _numbers(voyage),
          'reopened': _numbers(reopened)
        };
      } else {
        final previous = baseline[name] as Map<String, dynamic>;
        expect(facts, previous['facts'],
            reason: 'Datos, geometría aplicada y formato guardado idénticos');
        expect(_numbers(voyage), previous['reopened']);
        expect(_numbers(voyage), _numbers(reopened));
        if (name == 'A07') expect(_numbers(voyage), hasLength(21));
        final oldNumbers = (previous['read'] as List).cast<int>();
        rows.add({
          'file': 'CORPUS_$name.edi',
          'before': oldNumbers,
          'after': _numbers(voyage),
          'added':
              _numbers(voyage).where((n) => !oldNumbers.contains(n)).toList(),
          ...facts
        });
      }
    });
  }
  tearDownAll(() {
    if (capture) {
      if (baselineFile.existsSync()) {
        throw StateError('No sobrescribir referencia');
      }
      baselineFile.writeAsStringSync(jsonEncode(baseline));
    } else {
      t98Json(File('${output.path}/results.json'), rows);
    }
  });
}
