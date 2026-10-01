import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/vessel_repository.dart';
import '../services/baplie_parser_service.dart';

/// Implementación del repositorio de buques
class VesselRepositoryImpl implements VesselRepository {
  final BaplieParserService _parserService;
  final FirebaseFirestore _firestore;

  VesselRepositoryImpl({
    BaplieParserService? parserService,
    FirebaseFirestore? firestore,
  })  : _parserService = parserService ?? BaplieParserService(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _voyages =>
      _firestore.collection('voyages');

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
    } catch (e, stack) {
      debugPrint('Error inesperado al analizar BAPLIE: $e\n$stack');
      return const Left(BaplieParsingFailure(
        message: 'No se pudo interpretar el archivo BAPLIE.',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> saveVoyage(VesselVoyage voyage) async {
    try {
      await _voyages.doc(voyage.id).set({
        ...voyage.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e, stack) {
      debugPrint('Error al guardar el viaje remoto: $e\n$stack');
      return const Left(FirestoreFailure(
        message: 'No se pudo guardar el viaje. Inténtalo de nuevo.',
      ));
    }
  }

  @override
  Future<Either<Failure, VesselVoyage>> getVoyageById(String id) async {
    try {
      final snapshot = await _voyages.doc(id).get();
      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        return const Left(FirestoreFailure(
            message:
                'El viaje no está disponible. Vuelve a la lista y selecciona otro.'));
      }
      return Right(VesselVoyage.fromJson(data));
    } catch (e, stack) {
      debugPrint('Error al obtener el viaje remoto: $e\n$stack');
      return const Left(FirestoreFailure(
        message: 'No se pudo obtener el viaje. Inténtalo de nuevo.',
      ));
    }
  }

  @override
  Stream<VesselVoyage> watchVoyageById(String id) => _voyages
      .doc(id)
      .snapshots(includeMetadataChanges: true)
      .where((snapshot) => snapshot.exists && snapshot.data() != null)
      .map((snapshot) => VesselVoyage.fromJson(snapshot.data()!));

  @override
  Future<Either<Failure, List<VesselVoyage>>> getAllVoyages() async {
    try {
      final snapshot = await _voyages.get();
      return Right(snapshot.docs
          .map((document) => VesselVoyage.fromJson(document.data()))
          .toList());
    } catch (e, stack) {
      debugPrint('Error al listar los viajes remotos: $e\n$stack');
      return const Left(FirestoreFailure(
        message: 'No se pudieron obtener los viajes. Inténtalo de nuevo.',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deleteVoyage(String id) async {
    try {
      await _voyages.doc(id).delete();
      return const Right(null);
    } catch (e, stack) {
      debugPrint('Error al eliminar el viaje remoto: $e\n$stack');
      return const Left(FirestoreFailure(
        message: 'No se pudo eliminar el viaje. Inténtalo de nuevo.',
      ));
    }
  }

  @override
  Future<Either<Failure, List<ContainerUnit>>> searchContainers(
      String query) async {
    final voyagesResult = await getAllVoyages();
    return voyagesResult.map((voyages) {
      final normalized = query.trim().toUpperCase();
      return voyages
          .expand((voyage) => voyage.containers)
          .where((container) =>
              container.containerId.toUpperCase().contains(normalized))
          .toList();
    });
  }
}
