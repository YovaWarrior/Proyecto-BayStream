import 'dart:convert';
import 'dart:io';

import 'package:baystream/features/vessel/data/datasources/hive_vessel_data_source.dart';
import 'package:baystream/features/vessel/data/datasources/local_vessel_codec.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('T-30/T-31 conjunto exacto del A01 real y tamaño del perfil persistido',
      () async {
    const directory = String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');
    expect(directory, isNotEmpty);
    final content = String.fromCharCodes(
        await File('$directory/CORPUS_A01.edi').readAsBytes());
    final voyage = BaplieParserService().parse(content);
    expect(voyage.totalContainers, 977);
    // Oráculo independiente del booleano del parser: posiciones LOC de bloques
    // que traen un EQD refrigerado o un TMP. El corpus no usa escape de comillas.
    final expected = <String>{};
    String? position;
    var isoReefers = 0;
    var temperatures = 0;
    for (final raw in content.split("'")) {
      final segment = raw.trim();
      if (segment.startsWith('LOC+147+')) {
        position = segment.split('+')[2].split(':').first;
      }
      if (segment.startsWith('EQD+CN+')) {
        final iso = segment.split('+')[3].split(':').first;
        if (iso.length >= 3 && iso[2] == 'R') {
          isoReefers++;
          if (position != null) expected.add(position);
        }
      }
      if (segment.startsWith('TMP+')) {
        temperatures++;
        if (position != null) expected.add(position);
      }
    }
    final profile =
        VesselProfile.proposeFrom(voyage, updatedAt: DateTime.utc(2026, 9, 19));
    expect(profile.reeferSlots, expected);
    expect(expected, hasLength(50));
    expect(profile.reeferSlotsOrigin, VesselProfileOrigin.proposedFromFile);
    final confirmed = profile.copyWith(
        origin: VesselProfileOrigin.declaredByUser, stackWeightLimitKg: 75000);
    const codec = LocalVesselCodec();
    final record = codec.encodeProfile(profile);
    final voyageRecord =
        codec.encodeVoyage(voyage.withGeometry(profile.geometry));
    final profileBytes = utf8.encode(record).length;
    expect(profileBytes, lessThan(1200));
    expect(profileBytes, lessThan(utf8.encode(voyageRecord).length));
    final out = await Directory('build/block4').create(recursive: true);
    final storeDirectory = await out.createTemp('corpus_');
    Future<HiveVesselDataSource> open() => HiveVesselDataSource.open(
        directory: storeDirectory.path, namespace: 't30_corpus');
    var store = await open();
    try {
      await store.saveProfile(confirmed);
      await store.close();
      store = await open();
      final recovered = store.getAllProfiles().single;
      expect(recovered, confirmed);
      expect(recovered.reeferSlots, expected);
      expect(recovered.stackWeightLimitKg, 75000);
      expect(recovered.reeferSlotsOrigin, VesselProfileOrigin.proposedFromFile);
      await store.saveProfile(recovered.copyWith(stackWeightLimitKg: null));
      await store.close();
      store = await open();
      expect(store.getAllProfiles().single.stackWeightLimitKg, isNull);
      expect(store.getAllProfiles().single.reeferSlots, expected);
    } finally {
      await store.close();
      await storeDirectory.delete(recursive: true);
    }
    final metrics = {
      'containers': voyage.totalContainers,
      'isoReefers': isoReefers,
      'tmpSegments': temperatures,
      'proposedSockets': expected.length,
      'slotsJsonBytes':
          utf8.encode(jsonEncode(profile.toJson()['reeferSlots'])).length,
      'profileEntityBytes': utf8.encode(jsonEncode(profile.toJson())).length,
      'profileRecordBytes': profileBytes,
      'confirmedWithLimitRecordBytes':
          utf8.encode(codec.encodeProfile(confirmed)).length,
      'voyageRecordBytes': utf8.encode(voyageRecord).length,
    };
    await File('${out.path}/profile.json').writeAsString(record);
    await File('${out.path}/metrics.json').writeAsString(jsonEncode(metrics));
    stdout.writeln('BLOQUE4_CORPUS_OK ${jsonEncode(metrics)}');
  });
}
