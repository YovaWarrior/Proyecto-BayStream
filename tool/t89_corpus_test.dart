import 'dart:io';
import 'dart:typed_data';

import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test/support/local_profile_test_support.dart';
import '../test/support/t74_movement_log_support.dart';
import '../test/support/t89_file_picker.dart';

/// Solo lee el corpus externo; el almacén de comprobación vive en systemTemp.
void main() {
  const corpus = String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');
  for (final name in ['T89_A07', 'T89_A07.txt', 'T89_A07.edi']) {
    test(
        'T-89 A07 como $name: selector, publicación y rechazo sin alterar almacén',
        () async {
      expect(corpus, isNotEmpty);
      final bytes = File('$corpus/CORPUS_A07.edi').readAsBytesSync();
      final picker = T89FilePicker()
        ..result = FilePickerResult([
          PlatformFile(name: name, size: bytes.length, bytes: bytes),
        ]);
      FilePicker.platform = picker;
      final store = await testProfileStore();
      final scope = ProviderContainer(overrides: [
        vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
        localVesselRepositoryProvider
            .overrideWith((ref) async => store.repository),
        movementLogRepositoryProvider
            .overrideWith((ref) async => T74MemoryLog()),
      ]);
      addTearDown(() async {
        scope.dispose();
        await store.repository.close();
        await store.directory.delete(recursive: true);
      });
      final notifier = scope.read(voyageNotifierProvider.notifier);
      final result = await notifier.loadVesselFromFile();
      expect(picker.requestedType, FileType.any);
      expect(picker.requestedExtensions, isNull);
      expect(result.needsGeometry, isTrue);
      expect(
          await notifier.confirmGeometry(notifier.currentProfile!.geometry,
              portOfCall: 'GTSTC',
              sourceKind: OperationSourceKind.arrivalBaplie),
          isNull);
      final v = notifier.publishedVoyage!;
      expect(v.totalContainers, 398);
      expect(v.totalReservedSlots, 0);
      expect(v.totalWeight, 6940578);
      expect(scope.read(voyageStatsProvider)!.totalBays, 21);
      final counts = v.cargoCountsFor('GTSTC');
      expect((counts.loaded, counts.discharged, counts.transit), (0, 114, 284));
      final before =
          (await store.repository.getAllVoyages()).getOrElse(() => []);
      final profiles =
          (await store.repository.getAllProfiles()).getOrElse(() => []);
      final bad = Uint8List.fromList('Texto sin cabecera'.codeUnits);
      picker.result = FilePickerResult(
          [PlatformFile(name: 'T89_TEXTO.txt', size: bad.length, bytes: bad)]);
      expect((await notifier.loadVesselFromFile()).errorMessage,
          contains('Este archivo no parece un BAPLIE'));
      expect(notifier.publishedVoyage, same(v));
      expect(
          (await store.repository.getAllVoyages()).getOrElse(() => []), before);
      expect((await store.repository.getAllProfiles()).getOrElse(() => []),
          profiles);
      stdout.writeln(
          '$name: 398 contenedores; 21 bahías; 6 940 578 kg; 0/114/284; rechazo conserva viaje y almacén.');
    });
  }
}
