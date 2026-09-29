import 'dart:io';

import 'package:baystream/features/vessel/data/datasources/hive_vessel_data_source.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_impl.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('T-37 A01 real: seis guardados, cinco recuperados, sin archivo ni nube al abrir', () async {
    const corpus = String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');
    expect(corpus, isNotEmpty, reason: 'Indica el directorio del corpus real');
    final content = await File('$corpus/CORPUS_A01.edi').readAsString();
    final parsed = BaplieParserService().parse(content);
    expect(parsed.totalContainers, 977);
    final profile = VesselProfile.proposeFrom(parsed);
    final voyage = parsed.withGeometry(profile.geometry).copyWith(vesselProfileKey: profile.key);
    final root = await Directory('build/t37/corpus-stores').create(recursive: true);
    final directory = await root.createTemp('a01_');
    Future<LocalVesselRepositoryImpl> open() async => LocalVesselRepositoryImpl(
        await HiveVesselDataSource.open(directory: directory.path, namespace: 'corpus'));
    var repository = await open();
    ProviderContainer? scope;
    try {
      (await repository.saveProfile(profile)).fold((f) => fail(f.message), (_) {});
      for (var i = 0; i < 6; i++) {
        (await repository.saveVoyage(voyage.copyWith(id: 'a01-$i')))
            .fold((f) => fail(f.message), (_) {});
      }
      await repository.close();
      repository = await open();
      final saved = (await repository.getAllVoyages()).fold((f) => throw StateError(f.message), (v) => v);
      expect(saved.map((v) => v.id), ['a01-5', 'a01-4', 'a01-3', 'a01-2', 'a01-1']);
      expect((await repository.getVoyageById('a01-0')).getOrElse(() => null), isNull);
      scope = ProviderContainer(overrides: [
        localVesselRepositoryProvider.overrideWith((ref) async => repository),
        vesselRepositoryProvider.overrideWith((ref) => throw StateError('Parser y nube indisponibles')),
      ]);
      final notifier = scope.read(voyageNotifierProvider.notifier);
      expect(await notifier.openRecentVoyage('a01-5'), isNull);
      final restored = notifier.publishedVoyage!;
      expect(restored.containers, voyage.containers);
      expect(restored.bays.length, 34);
      for (final bay in [5, 13, 15, 35, 39, 43, 45]) {
        expect(restored.bays[bay]!.slotsOccupiedByNeighbors, voyage.bays[bay]!.slotsOccupiedByNeighbors);
        expect(restored.bays[bay]!.slotsOccupiedByNeighbors, isNotEmpty);
      }
      expect(await notifier.deleteRecentVoyage('a01-5'), isNull);
      expect((await repository.getAllVoyages()).getOrElse(() => []).length, 4);
      expect((await repository.getAllProfiles()).getOrElse(() => []), [profile]);
    } finally {
      scope?.dispose();
      await repository.close();
      await directory.delete(recursive: true);
    }
  });
}
