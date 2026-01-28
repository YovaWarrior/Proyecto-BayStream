import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/entities.dart';

/// Repositorio abstracto para operaciones con buques y viajes
abstract class VesselRepository {
  /// Parsea un archivo BAPLIE y retorna el viaje completo
  Future<Either<Failure, VesselVoyage>> parseBaplieFile(String content);
  
  /// Guarda un viaje en Firestore
  Future<Either<Failure, void>> saveVoyage(VesselVoyage voyage);
  
  /// Obtiene un viaje por ID
  Future<Either<Failure, VesselVoyage>> getVoyageById(String id);
  
  /// Obtiene todos los viajes
  Future<Either<Failure, List<VesselVoyage>>> getAllVoyages();
  
  /// Elimina un viaje
  Future<Either<Failure, void>> deleteVoyage(String id);
  
  /// Busca contenedores por ID
  Future<Either<Failure, List<ContainerUnit>>> searchContainers(String query);
}
