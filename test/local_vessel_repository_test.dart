import 'dart:convert';
import 'dart:io';

import 'package:baystream/core/errors/failures.dart';
import 'package:baystream/features/vessel/data/datasources/hive_vessel_data_source.dart';
import 'package:baystream/features/vessel/data/datasources/local_vessel_codec.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_impl.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

T value<T>(Either<Failure, T> result) =>
    result.fold((failure) => throw StateError(failure.message), (data) => data);

void main() {
  late Directory directory;
  late String namespace;
  late LocalVesselRepositoryImpl repository;
  const codec = LocalVesselCodec();
  final parsed = BaplieParserService().parse(
    "TDT+20+V01N+++NV2:172:20+++9000003:146:11:BUQUE ALFA'"
    "LOC+147+0020182:::5'EQD+CN+TEST0000001+42G1+++5'",
  );
  final voyage =
      parsed.withGeometry(VesselGeometry.proposeFrom(parsed.stowagePositions));
  VesselProfile profile(Vessel vessel) => VesselProfile(
        identity: vessel.profileIdentity,
        vesselName: vessel.name,
        geometry: voyage.geometry!,
        reeferSlots: {'0020182'},
        origin: VesselProfileOrigin.declaredByUser,
        updatedAt: DateTime.utc(2026, 9, 19),
      );

  Future<LocalVesselRepositoryImpl> open() async => LocalVesselRepositoryImpl(
        await HiveVesselDataSource.open(
            directory: directory.path, namespace: namespace),
      );

  setUp(() async {
    final root =
        await Directory('build/block2/test-stores').create(recursive: true);
    directory = await root.createTemp('hive_');
    namespace = 't36_${DateTime.now().microsecondsSinceEpoch}';
    repository = await open();
  });

  tearDown(() async {
    await repository.close();
    await directory.delete(recursive: true);
  });

  test('el registro lleva versión y guarda cada contenedor una sola vez', () {
    final record = codec.encodeVoyage(voyage);
    final json = jsonDecode(record) as Map<String, dynamic>;
    expect(json['schemaVersion'], 1);
    expect((json['data'] as Map).containsKey('bays'), isFalse);
    expect(RegExp('TEST0000001').allMatches(record).length, 1);
    expect(record, isNot(contains('slots')));
    expect(record, isNot(contains('maxRows')));
    expect(codec.decodeVoyage(record), voyage);
  });

  test('sin número de versión lee viajes y perfiles como versión uno', () {
    final voyageRecord =
        jsonDecode(codec.encodeVoyage(voyage)) as Map<String, dynamic>;
    final originalProfile = profile(voyage.vessel);
    final profileRecord = jsonDecode(codec.encodeProfile(originalProfile))
        as Map<String, dynamic>;
    expect(
        codec.decodeVoyage(jsonEncode(voyageRecord..remove('schemaVersion'))),
        voyage);
    expect(
        codec.decodeProfile(jsonEncode(profileRecord..remove('schemaVersion'))),
        originalProfile);
    expect(codec.decodeVoyage(jsonEncode(voyage.toJson())), voyage);
    expect(codec.decodeProfile(jsonEncode(originalProfile.toJson())),
        originalProfile);
  });

  test('rechaza versiones futuras o inválidas sin borrar el registro', () {
    for (final version in [2, 0, null, '1']) {
      final record =
          jsonDecode(codec.encodeVoyage(voyage)) as Map<String, dynamic>;
      record['schemaVersion'] = version;
      expect(
          () => codec.decodeVoyage(jsonEncode(record)), throwsFormatException);
    }
  });

  test('Hive real recupera viaje y perfil tras cerrar y abrir el almacén',
      () async {
    final originalProfile = profile(voyage.vessel);
    value(await repository.saveVoyage(voyage));
    value(await repository.saveProfile(originalProfile));
    value(await repository.close());
    repository = await open();
    expect(value(await repository.getVoyageById(voyage.id)), voyage);
    expect(value(await repository.getAllVoyages()), [voyage]);
    final found = value(await repository
        .findProfileFor(voyage.vessel.copyWith(id: 'otro-uuid')));
    expect(found.automaticMatch, originalProfile);
    expect(found.requiresConfirmation, isFalse);
    expect(value(await repository.getAllProfiles()), [originalProfile]);
  });

  test('eliminar un viaje conserva el perfil del buque', () async {
    value(await repository.saveVoyage(voyage));
    value(await repository.saveProfile(profile(voyage.vessel)));
    value(await repository.deleteVoyage(voyage.id));
    expect(value(await repository.getVoyageById(voyage.id)), isNull);
    expect(value(await repository.getAllVoyages()), isEmpty);
    expect(value(await repository.getAllProfiles()), hasLength(1));
  });

  test('A05 y A06 requieren confirmación antes de crear un homónimo', () async {
    const a05 = Vessel(id: 'a05', name: 'BUQUE ECO', callSign: 'ZZC5603');
    const a06 = Vessel(id: 'a06', name: 'BUQUE ECO', imoNumber: '9000039');
    value(await repository.saveProfile(profile(a05)));
    final lookup = value(await repository.findProfileFor(a06));
    expect(lookup.automaticMatch, isNull);
    expect(lookup.requiresConfirmation, isTrue);
    expect(lookup.nameCandidates, [profile(a05)]);
    final denied = await repository.saveProfile(profile(a06));
    expect(denied.fold((failure) => failure.code, (_) => null),
        'profile_confirmation_required');
    expect(value(await repository.getAllProfiles()), [profile(a05)]);
    value(await repository.saveProfile(profile(a06), nameMatchConfirmed: true));
    expect(value(await repository.getAllProfiles()), hasLength(2));
    expect(value(await repository.findProfileFor(a06)).automaticMatch,
        profile(a06));
  });

  test(
      'coincidir solo por nombre nunca permite recuperar ni sobrescribir automáticamente',
      () async {
    const vessel = Vessel(id: 'a', name: 'Solo Nombre');
    final original = profile(vessel);
    value(await repository.saveProfile(original));
    final lookup = value(await repository.findProfileFor(vessel));
    expect(lookup.automaticMatch, isNull);
    expect(lookup.requiresConfirmation, isTrue);
    final edited = original.copyWith(stackWeightLimitKg: 75000);
    expect((await repository.saveProfile(edited)).isLeft(), isTrue);
    expect(value(await repository.getAllProfiles()), [original]);
    value(await repository.saveProfile(edited, nameMatchConfirmed: true));
    expect(value(await repository.getAllProfiles()), [edited]);
  });

  test('misma identidad actualiza el perfil aunque cambie el nombre', () async {
    final original = profile(voyage.vessel);
    value(await repository.saveProfile(original));
    final renamed = original.copyWith(vesselName: 'NOMBRE NUEVO');
    value(await repository.saveProfile(renamed));
    expect(value(await repository.getAllProfiles()), [renamed]);
    expect(value(await repository.findProfileFor(voyage.vessel)).automaticMatch,
        renamed);
  });

  test('dos guardados simultáneos no crean homónimos sin preguntar', () async {
    const a = Vessel(id: 'a', name: 'BUQUE ECO', callSign: 'ZZC5603');
    const b = Vessel(id: 'b', name: 'BUQUE ECO', imoNumber: '9000039');
    final results = await Future.wait([
      repository.saveProfile(profile(a)),
      repository.saveProfile(profile(b)),
    ]);
    expect(results.where((result) => result.isRight()), hasLength(1));
    expect(results.where((result) => result.isLeft()), hasLength(1));
    expect(value(await repository.getAllProfiles()), hasLength(1));
  });

  test('los errores del motor se entregan como fallo de caché', () async {
    value(await repository.close());
    final result = await repository.getVoyageById(voyage.id);
    expect(result.fold((failure) => failure is CacheFailure, (_) => false),
        isTrue);
  });
}
