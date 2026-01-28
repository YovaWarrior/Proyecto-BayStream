import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/vessel_repository.dart';
import '../services/baplie_parser_service.dart';

/// Implementación del repositorio de buques
class VesselRepositoryImpl implements VesselRepository {
  final BaplieParserService _parserService;

  VesselRepositoryImpl({
    BaplieParserService? parserService,
  }) : _parserService = parserService ?? BaplieParserService();

  @override
  Future<Either<Failure, VesselVoyage>> parseBaplieFile(String content) async {
    try {
      final voyage = _parserService.parse(content);
      return Right(voyage);
    } on BaplieParsingException catch (e) {
      return Left(BaplieParsingFailure(
        message: e.message,
        lineNumber: e.lineNumber,
        segment: e.segment,
      ));
    } catch (e) {
      return Left(BaplieParsingFailure(
        message: 'Error inesperado al parsear archivo: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> saveVoyage(VesselVoyage voyage) async {
    // TODO: Implementar con Firebase Firestore
    throw UnimplementedError('Firestore integration pending');
  }

  @override
  Future<Either<Failure, VesselVoyage>> getVoyageById(String id) async {
    // TODO: Implementar con Firebase Firestore
    throw UnimplementedError('Firestore integration pending');
  }

  @override
  Future<Either<Failure, List<VesselVoyage>>> getAllVoyages() async {
    // TODO: Implementar con Firebase Firestore
    throw UnimplementedError('Firestore integration pending');
  }

  @override
  Future<Either<Failure, void>> deleteVoyage(String id) async {
    // TODO: Implementar con Firebase Firestore
    throw UnimplementedError('Firestore integration pending');
  }

  @override
  Future<Either<Failure, List<ContainerUnit>>> searchContainers(String query) async {
    // TODO: Implementar búsqueda
    throw UnimplementedError('Search implementation pending');
  }
}
