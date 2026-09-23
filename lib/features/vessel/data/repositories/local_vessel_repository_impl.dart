import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/local_vessel_repository.dart';
import '../datasources/hive_vessel_data_source.dart';

class LocalVesselRepositoryImpl implements LocalVesselRepository {
  final HiveVesselDataSource _source;
  Future<void> _profileWrites = Future.value();

  LocalVesselRepositoryImpl(this._source);

  Future<Either<Failure, T>> _guard<T>(FutureOr<T> Function() operation) async {
    try {
      return Right(await operation());
    } catch (error) {
      return Left(
          CacheFailure(message: 'No se pudo acceder al almacén local: $error'));
    }
  }

  @override
  Future<Either<Failure, void>> saveVoyage(VesselVoyage voyage) =>
      _guard(() => _source.saveVoyage(voyage));

  @override
  Future<Either<Failure, VesselVoyage?>> getVoyageById(String id) =>
      _guard(() => _source.getVoyageById(id));

  @override
  Future<Either<Failure, List<VesselVoyage>>> getAllVoyages() =>
      _guard(_source.getAllVoyages);

  @override
  Future<Either<Failure, void>> deleteVoyage(String id) =>
      _guard(() => _source.deleteVoyage(id));

  @override
  Future<Either<Failure, List<VesselProfile>>> getAllProfiles() =>
      _guard(_source.getAllProfiles);

  @override
  Future<Either<Failure, VesselProfileLookup>> findProfileFor(Vessel vessel) =>
      _guard(() {
        final profiles = _source.getAllProfiles();
        for (final profile in profiles) {
          if (profile.identity.matchesAutomatically(vessel.profileIdentity)) {
            return VesselProfileLookup(automaticMatch: profile);
          }
        }
        return VesselProfileLookup(
            nameCandidates: profiles
                .where((profile) =>
                    VesselIdentity.normalizeName(profile.vesselName) ==
                    VesselIdentity.normalizeName(vessel.name))
                .toList());
      });

  @override
  Future<Either<Failure, void>> saveProfile(
    VesselProfile profile, {
    bool nameMatchConfirmed = false,
  }) async {
    // Serializa comprobación + escritura para que dos cargas simultáneas no
    // introduzcan homónimos antes de que la otra escritura sea visible.
    final previous = _profileWrites;
    final completion = Completer<void>();
    _profileWrites = completion.future;
    await previous;
    try {
      final profiles = _source.getAllProfiles();
      final exact = profiles.any(
          (saved) => saved.identity.matchesAutomatically(profile.identity));
      final ambiguous = !exact &&
          profiles.any((saved) =>
              saved.key == profile.key ||
              VesselIdentity.normalizeName(saved.vesselName) ==
                  VesselIdentity.normalizeName(profile.vesselName));
      if (ambiguous && !nameMatchConfirmed) {
        return const Left(CacheFailure(
          code: 'profile_confirmation_required',
          message:
              'Hay un perfil con el mismo nombre. Confirma la identidad del buque antes de guardar.',
        ));
      }
      return await _guard(() => _source.saveProfile(profile));
    } catch (error) {
      return Left(
          CacheFailure(message: 'No se pudo guardar el perfil: $error'));
    } finally {
      completion.complete();
    }
  }

  @override
  Future<Either<Failure, void>> close() async {
    await _profileWrites;
    return _guard(_source.close);
  }
}
