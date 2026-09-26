import 'dart:io';

import 'package:baystream/features/vessel/data/datasources/hive_vessel_data_source.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_impl.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/local_profile_test_support.dart';

void main() {
  for (final limit in <double?>[75000, null]) {
    test('T-29 límite $limit sobrevive cierre del viaje y reapertura de Hive',
        () async {
      final directory = await Directory.systemTemp.createTemp('t29_');
      Future<LocalVesselRepositoryImpl> open() async =>
          LocalVesselRepositoryImpl(await HiveVesselDataSource.open(
              directory: directory.path, namespace: 't29'));
      var repository = await open();
      ProviderContainer providers() => ProviderContainer(overrides: [
            vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
            localVesselRepositoryProvider
                .overrideWith((ref) async => repository),
          ]);
      var container = providers();
      try {
        var notifier = container.read(voyageNotifierProvider.notifier);
        await notifier
            .parseBaplieContent(profileTestEdi.replaceAll('42G1', '42R1'));
        // También prueba retirar un valor anterior: null no significa conservar.
        final withLimit =
            notifier.currentProfile!.copyWith(stackWeightLimitKg: 90000);
        final declared = withLimit.copyWith(stackWeightLimitKg: limit).geometry;
        expect(await notifier.confirmGeometry(declared), isNull);
        notifier.clearVoyage();
        expect(notifier.publishedVoyage, isNull);
        container.dispose();
        await repository.close();
        repository = await open();
        container = providers();
        notifier = container.read(voyageNotifierProvider.notifier);
        final result = await notifier.parseBaplieContent(profileTestEdi);
        expect(result.needsGeometry, isFalse);
        expect(notifier.currentProfile!.stackWeightLimitKg, limit);
        // En el viaje nuevo la posición lleva carga seca; la toma es del buque.
        expect(notifier.publishedVoyage!.containers.single.isReefer, isFalse);
        expect(notifier.currentProfile!.reeferSlots, {'0020182'});
        expect(notifier.currentProfile!.reeferSlotsOrigin,
            VesselProfileOrigin.proposedFromFile);
        expect(notifier.currentProfile!.origin,
            VesselProfileOrigin.declaredByUser);
        expect(notifier.publishedVoyage!.geometry!.stackWeightLimitKg, limit);
        for (final bay in notifier.publishedVoyage!.bays.values) {
          expect(bay.geometry!.stackWeightLimitKg, limit);
        }
      } finally {
        container.dispose();
        await repository.close();
        await directory.delete(recursive: true);
      }
    });
  }
}
