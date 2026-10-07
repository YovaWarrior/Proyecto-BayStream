import 'dart:async';

import 'package:baystream/core/errors/failures.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/movement_log_repository.dart';
import 'package:dartz/dartz.dart';

/// T-75 · Bitácora en memoria para las pruebas de pantalla: anexa, ordena y
/// avisa como la de Hive, sin abrir el almacén real del equipo.
class T75MemoryLog implements MovementLogRepository {
  final operations = <Operation>[];
  final _records = <MovementRecord>[];
  final _changes = StreamController<String>.broadcast();
  var _sequence = 0;

  List<MovementRecord> of(String operationId) =>
      _records.where((r) => r.movement.operationId == operationId).toList()
        ..sort((a, b) => Movement.compareOrder(a.movement, b.movement));

  @override
  Future<Either<Failure, MovementRecord>> append(
      MovementDraft draft, MovementAuthor author) async {
    final problem = draft.validate();
    if (problem != null) {
      return Left(ValidationFailure(message: problem, field: draft.type.wire));
    }
    _sequence++;
    final record = MovementRecord(
        Movement(
          id: 'mov-$_sequence',
          operationId: draft.operationId,
          type: draft.type,
          target: draft.target,
          payload: draft.payload,
          author: author,
          deviceId: 'dispositivo-prueba',
          sequence: _sequence,
          createdAt:
              DateTime.utc(2026, 10, 7, 12).add(Duration(minutes: _sequence)),
        ),
        SendState.localOnly);
    _records.add(record);
    _changes.add(draft.operationId);
    return Right(record);
  }

  @override
  Future<Either<Failure, List<MovementRecord>>> records(
          String operationId) async =>
      Right(of(operationId));

  @override
  Stream<List<MovementRecord>> watch(String operationId) async* {
    yield of(operationId);
    await for (final changed in _changes.stream) {
      if (changed == operationId) yield of(operationId);
    }
  }

  @override
  Future<Either<Failure, List<Operation>>> getOperations() async =>
      Right(List.of(operations));

  @override
  Future<Either<Failure, void>> saveOperation(Operation operation) async {
    operations.removeWhere((o) => o.id == operation.id);
    operations.add(operation);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> close() async => const Right(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
