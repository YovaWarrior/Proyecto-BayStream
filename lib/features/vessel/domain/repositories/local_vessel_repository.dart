import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/entities.dart';

/// Resultado de identidad: solo un identificador permite resolución automática.
class VesselProfileLookup {
  final VesselProfile? automaticMatch;
  final List<VesselProfile> nameCandidates;

  VesselProfileLookup(
      {this.automaticMatch, List<VesselProfile> nameCandidates = const []})
      : nameCandidates = List.unmodifiable(nameCandidates);

  bool get requiresConfirmation => nameCandidates.isNotEmpty;
}

/// Almacén propio, independiente de Firestore y sin tipos de Hive en el dominio.
abstract class LocalVesselRepository {
  Future<Either<Failure, void>> saveVoyage(VesselVoyage voyage);
  Future<Either<Failure, VesselVoyage?>> getVoyageById(String id);
  Future<Either<Failure, List<VesselVoyage>>> getAllVoyages();
  Future<Either<Failure, void>> deleteVoyage(String id);

  Future<Either<Failure, VesselProfileLookup>> findProfileFor(Vessel vessel);
  Future<Either<Failure, List<VesselProfile>>> getAllProfiles();

  /// La interfaz debe resolver cualquier homónimo antes de confirmar esta opción.
  /// Confirmar conserva la clave recibida; nunca fusiona ni cambia otros perfiles.
  Future<Either<Failure, void>> saveProfile(
    VesselProfile profile, {
    bool nameMatchConfirmed = false,
  });

  Future<Either<Failure, void>> close();
}
