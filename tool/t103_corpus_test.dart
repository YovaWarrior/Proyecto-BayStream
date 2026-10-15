import 'dart:convert';
import 'dart:io';

import 'package:baystream/features/vessel/data/datasources/hive_vessel_data_source.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_impl.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

import 't86_corpus_support.dart';

Object? _withoutIds(Object? value) {
  if (value is Map) {
    return {
      for (final e in value.entries)
        if (e.key != 'id') e.key: _withoutIds(e.value)
    };
  }
  if (value is List) return value.map(_withoutIds).toList();
  return value;
}

/// T-103 · A06 (SMDG15) con las cifras de antes de T-86, tomadas de
/// 1b1be4b^: BLOQUE7A/7B, T-37, T-55 y HALLAZGOS-PLANO-REAL. La lectura
/// completa del lector de 1b1be4b^ es opcional y vive solo en %TEMP%.
/// flutter test tool/t103_corpus_test.dart
/// --dart-define=BAYSTREAM_CORPUS_DIRECTORY=...
/// --dart-define=T103_A06_BEFORE=.../t103_a06_antes.json
void main() {
  const corpus = String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');
  const beforePath = String.fromEnvironment('T103_A06_BEFORE');
  String source() {
    expect(corpus, isNotEmpty);
    return File('$corpus/CORPUS_A06.edi').readAsStringSync();
  }

  test('T-103 A06 abre con las cifras de antes de T-86 y el aviso', () {
    final parsed = readA06WithNotice(source());
    final geometry = VesselProfile.proposeFrom(parsed).geometry;
    final voyage = parsed.withGeometry(geometry);
    final dangerous = voyage.containers
        .where((c) => (c.dangerousGoods ?? const []).isNotEmpty);
    expect(voyage.metadata!.messageVersion, '1');
    expect(voyage.metadata!.readWithV2Rules, isTrue);
    expect(voyage.vessel.name, 'BUQUE ECO');
    expect(voyage.vessel.profileKey, 'imo:9000039');
    expect(voyage.voyageNumber, 'VIAJE004A');
    expect(voyage.portOfOrigin, 'GTPBR');
    expect(voyage.portOfNextCall, isNull);
    expect(voyage.totalContainers, 717);
    expect(voyage.bays, hasLength(27));
    expect(voyage.totalReservedSlots, 0);
    expect(voyage.totalWeight, closeTo(10766933.0, 0.000001));
    expect(
        voyage.containers
            .where((c) => c.isoSizeType?.startsWith('2') ?? false)
            .length,
        190);
    expect(voyage.containers.where((c) => c.isReefer).length, 91);
    expect(voyage.containers.where((c) => c.temperature != null).length, 73);
    expect(dangerous.expand((c) => c.dangerousGoods!).length, 1);
    expect(dangerous.length, 1);
    if (beforePath.isNotEmpty) {
      expect(_withoutIds(parsed.toJson()),
          jsonDecode(File(beforePath).readAsStringSync()),
          reason: 'el mismo viaje que el lector de 1b1be4b^, salvo los UUID');
    }
    stdout.writeln('T-103 A06: ${voyage.totalContainers} contenedores, '
        '${voyage.bays.length} bahías, '
        '${voyage.totalWeight.toStringAsFixed(2)} kg, 1 DGS en 1 unidad, '
        '${beforePath.isEmpty ? 'cifras' : 'viaje completo'} de 1b1be4b^ '
        'sin diferencias; aviso 1.5');
  });

  test('T-103 A06 reabierta desde el almacén conserva el aviso', () async {
    final parsed = readA06WithNotice(source());
    final profile = VesselProfile.proposeFrom(parsed);
    final voyage = parsed
        .withGeometry(profile.geometry)
        .copyWith(vesselProfileKey: profile.key);
    final root = await Directory.systemTemp.createTemp('t103_store_');
    addTearDown(() => root.delete(recursive: true));
    Future<LocalVesselRepositoryImpl> open() async =>
        LocalVesselRepositoryImpl(await HiveVesselDataSource.open(
            directory: root.path, namespace: 't103_corpus'));
    final first = await open();
    expect((await first.saveVoyage(voyage)).isRight(), isTrue);
    await first.close();
    final second = await open();
    final reopened = (await second.getVoyageById(voyage.id))
        .getOrElse(() => throw StateError('No se pudo releer A06'))!;
    await second.close();
    expect(reopened.metadata!.readWithV2Rules, isTrue);
    expect(reopened.totalContainers, 717);
    expect(reopened.bays, hasLength(27));
  });
}
