import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/operation.dart';
import '../../domain/entities/vessel_profile.dart';
import '../../domain/repositories/operation_sync_repository.dart';
import '../../domain/repositories/session_repository.dart';

/// T-79 · Sin la nube configurada la app sigue en el modo de un solo
/// dispositivo: la bitácora local de T-72, sin publicar ni unirse. Desde 10.8
/// Windows sí sincroniza; este adaptador queda para una compilación sin
/// opciones de Firebase y para las pruebas (T-79a 3.4).
class LocalOnlyOperationSync implements OperationSyncRepository {
  const LocalOnlyOperationSync();

  static const _failure = FirestoreFailure(
      code: 'no_cloud',
      message: 'Esta compilación no tiene la nube configurada: la app trabaja '
          'en un solo dispositivo.');

  @override
  SyncCapability get capability => SyncCapability.none;

  @override
  Future<Either<Failure, Operation>> publish(
          Operation operation, VesselProfile profile) async =>
      const Left(_failure);

  @override
  Stream<List<PublishedOperation>> watchOpenOperations() => Stream.value(const []);

  @override
  Future<Either<Failure, Operation>> join(String operationId) async =>
      const Left(_failure);

  @override
  Future<Either<Failure, Operation>> close(String operationId) async =>
      const Left(_failure);

  @override
  Stream<SyncStatus> follow(Operation operation) => Stream.value(SyncStatus.local);

  @override
  Future<void> retry(String operationId) async {}

  @override
  Future<void> dispose() async {}
}

/// Sin cuentas: no toca Firebase Auth. Los movimientos llevan el autor sin
/// cuenta y se quedan en el dispositivo.
class LocalSessionRepository implements SessionRepository {
  const LocalSessionRepository();

  @override
  bool get supportsAccounts => false;

  @override
  Operator? get current => null;

  @override
  Stream<Operator?> watchOperator() => Stream.value(null);

  @override
  Future<Either<Failure, Operator>> signIn(String email, String password) async =>
      const Left(LocalOnlyOperationSync._failure);

  @override
  Future<Either<Failure, void>> signOut() async => const Right(null);

  @override
  Future<Either<Failure, void>> sendPasswordReset(String email) async =>
      const Left(LocalOnlyOperationSync._failure);

  @override
  Future<void> verify() async {}

  @override
  Future<void> dispose() async {}
}
