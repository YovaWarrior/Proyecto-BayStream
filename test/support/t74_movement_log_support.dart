import 'package:baystream/core/errors/failures.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/movement_log_repository.dart';
import 'package:dartz/dartz.dart';

/// Evita que las pruebas de perfiles abran el almacén real de Windows.
class T74MemoryLog implements MovementLogRepository {
  final operations = <Operation>[];
  @override
  Future<Either<Failure, List<Operation>>> getOperations() async => Right(List.of(operations));
  @override
  Future<Either<Failure, void>> saveOperation(Operation operation) async {
    operations.removeWhere((o) => o.id == operation.id);
    operations.add(operation);
    return const Right(null);
  }
  @override
  Stream<List<MovementRecord>> watch(String operationId) => Stream.value(const []);
  @override
  Future<Either<Failure, void>> close() async => const Right(null);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
