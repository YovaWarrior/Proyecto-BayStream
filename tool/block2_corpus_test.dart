import 'dart:convert';
import 'dart:io';

import 'package:baystream/core/errors/failures.dart';
import 'package:baystream/features/vessel/data/datasources/hive_vessel_data_source.dart';
import 'package:baystream/features/vessel/data/datasources/local_vessel_codec.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_impl.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/data/services/export_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

T value<T>(Either<Failure, T> result) =>
    result.fold((failure) => throw StateError(failure.message), (data) => data);

void main() {
  test('bloque 2 contra los seis corpus y persistencia íntegra de CORPUS_A01',
      () async {
    const corpusDirectory =
        String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');
    expect(corpusDirectory, isNotEmpty,
        reason:
            'Indica la carpeta real con --dart-define=BAYSTREAM_CORPUS_DIRECTORY=...');
    final parser = BaplieParserService();
    const keys = [
      'imo:9000003',
      'imo:9000015',
      'callSign:ZZAB1',
      'imo:9000027',
      'callSign:ZZC5603',
      'imo:9000039'
    ];
    final voyages = <VesselVoyage>[];
    for (var i = 1; i <= 6; i++) {
      final file = File('$corpusDirectory/CORPUS_A0$i.edi');
      final parsed =
          parser.parse(String.fromCharCodes(await file.readAsBytes()));
      expect(parsed.vessel.profileKey, keys[i - 1]);
      voyages.add(parsed);
    }
    expect(voyages[4].vessel.matchIdentity(voyages[5].vessel),
        VesselIdentityMatch.requiresConfirmation);
    final parsed = voyages.first;
    final original = parsed.withGeometry(
      VesselGeometry.proposeFrom(parsed.stowagePositions),
      portOfCall: parsed.proposedPortOfCall,
    );
    expect(original.totalContainers, 977);
    expect(original.bays, hasLength(34));
    final shadowOnly =
        original.bays.values.where((bay) => bay.containers.isEmpty).toList();
    expect(shadowOnly, hasLength(7));
    final legacy =
        VesselVoyage.fromJson(jsonDecode(jsonEncode(original.toJson())));
    expect(legacy, original);
    for (final bay in shadowOnly) {
      expect(legacy.bays[bay.bayNumber]!.occupancyRate, bay.occupancyRate);
      expect(legacy.bays[bay.bayNumber]!.occupancyRate, greaterThan(0));
    }
    const codec = LocalVesselCodec();
    final record = codec.encodeVoyage(original);
    expect(codec.decodeVoyage(record), original);
    final versionless = jsonDecode(record) as Map<String, dynamic>;
    expect(codec.decodeVoyage(jsonEncode(versionless..remove('schemaVersion'))),
        original);
    final profile = VesselProfile(
      identity: original.vessel.profileIdentity,
      vesselName: original.vessel.name,
      geometry: original.geometry!,
      reeferSlots: original.containers
          .where((c) => c.isReefer)
          .map((c) => c.stowagePosition!.rawCode)
          .toSet(),
      origin: VesselProfileOrigin.proposedFromFile,
      updatedAt: DateTime.utc(2026, 9, 19),
    );
    expect(VesselProfile.fromJson(jsonDecode(jsonEncode(profile.toJson()))),
        profile);

    final output =
        await Directory('build/block2/corpus').create(recursive: true);
    // Directorio y espacio de nombres propios para no tocar datos de la app.
    final directory = await output.createTemp('store_');
    final namespace = 'corpus_${DateTime.now().microsecondsSinceEpoch}';
    Future<LocalVesselRepositoryImpl> open() async => LocalVesselRepositoryImpl(
          await HiveVesselDataSource.open(
              directory: directory.path, namespace: namespace),
        );
    var repository = await open();
    try {
      value(await repository.saveVoyage(original));
      value(await repository.saveProfile(profile));
      value(await repository.close());
      repository = await open();
      expect(value(await repository.getVoyageById(original.id)), original);
      expect(
          value(await repository.findProfileFor(original.vessel))
              .automaticMatch,
          profile);
      value(await repository.deleteVoyage(original.id));
      expect(value(await repository.getVoyageById(original.id)), isNull);
      expect(value(await repository.getAllProfiles()), [profile]);
    } finally {
      await repository.close();
      await directory.delete(recursive: true);
    }
    final exported = const ExportService().serializeJson(original);
    final fullCompact = jsonEncode(original.toJson());
    final localPretty =
        const JsonEncoder.withIndent('  ').convert(jsonDecode(record));
    final metrics = {
      'containers': original.totalContainers,
      'bays': original.bays.length,
      'shadowOnlyBays': shadowOnly.map((bay) => bay.bayNumber).toList()..sort(),
      'exportUtf8Bytes': utf8.encode(exported).length,
      'fullCompactUtf8Bytes': utf8.encode(fullCompact).length,
      'localPrettyUtf8Bytes': utf8.encode(localPretty).length,
      'localRecordUtf8Bytes': utf8.encode(record).length,
      'profileUtf8Bytes': utf8.encode(codec.encodeProfile(profile)).length,
    };
    await File('${output.path}/CORPUS_A01-local.json')
        .writeAsString(record, flush: true);
    await File('${output.path}/CORPUS_A01-export.json')
        .writeAsString(exported, flush: true);
    await File('${output.path}/profile.json')
        .writeAsString(codec.encodeProfile(profile), flush: true);
    await File('${output.path}/measurement.json')
        .writeAsString(jsonEncode(metrics), flush: true);
    stdout.writeln('BLOQUE2_CORPUS_OK ${jsonEncode(metrics)}');
  });
}
