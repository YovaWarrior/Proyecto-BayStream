import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/movement.dart';
import '../../domain/entities/operation.dart';
import '../../domain/repositories/movement_log_repository.dart';
import '../datasources/hive_movement_data_source.dart';

class MovementLogRepositoryImpl implements MovementLogRepository {
  final HiveMovementDataSource _source;
  final DateTime Function() _clock;

  /// Hasta T-79 ningún cliente sincroniza: todo nace `localOnly`.
  final SendState _initialState;

  MovementLogRepositoryImpl(
    this._source, {
    DateTime Function()? clock,
    SendState initialState = SendState.localOnly,
  })  : _clock = clock ?? DateTime.now,
        _initialState = initialState;

  Future<Either<Failure, T>> _guard<T>(FutureOr<T> Function() operation) async {
    try {
      return Right(await operation());
    } catch (error, stack) {
      debugPrint('Error de la bitácora local: $error\n$stack');
      return const Left(CacheFailure(
          message: 'No se pudo acceder a la bitácora local. Inténtalo de nuevo.'));
    }
  }

  List<MovementRecord> _ordered(String operationId) =>
      _source.movements(operationId)
        ..sort((a, b) => Movement.compareOrder(a.movement, b.movement));

  @override
  Future<Either<Failure, MovementRecord>> append(
      MovementDraft draft, MovementAuthor author) async {
    final problem = draft.validate();
    if (problem != null) {
      return Left(ValidationFailure(message: problem, field: draft.type.wire));
    }
    return _guard(() async {
      final registeredAt = _clock();
      final record = MovementRecord(
        Movement(
          id: const Uuid().v4(),
          operationId: draft.operationId,
          type: draft.type,
          target: draft.target,
          payload: {
            ...draft.payload,
            if ((draft.type == MovementType.loadFull ||
                    draft.type == MovementType.assignEmpty) &&
                draft.payload['operatedAt'] == null)
              'operatedAt': registeredAt.toUtc().toIso8601String(),
          },
          author: author,
          deviceId: _source.deviceId,
          sequence: _source.nextSequence(),
          createdAt: registeredAt,
        ),
        _initialState,
      );
      await _source.putMovement(record);
      _changes.add(draft.operationId);
      return record;
    });
  }

  @override
  Future<Either<Failure, List<MovementRecord>>> records(String operationId) =>
      _guard(() => _ordered(operationId));

  /// Avisa qué operación cambió. Toda escritura pasa por este repositorio
  /// (también lo remoto, en T-79), así que basta con avisar desde aquí.
  final _changes = StreamController<String>.broadcast();

  @override
  Stream<List<MovementRecord>> watch(String operationId) {
    StreamSubscription<String>? subscription;
    late final StreamController<List<MovementRecord>> controller;
    controller = StreamController<List<MovementRecord>>(
      onListen: () {
        controller.add(_ordered(operationId));
        subscription = _changes.stream
            .where((id) => id == operationId)
            .listen((_) => controller.add(_ordered(operationId)));
      },
      onCancel: () async {
        await subscription?.cancel();
        await controller.close();
      },
    );
    return controller.stream;
  }

  @override
  Future<Either<Failure, String>> exportJson(String operationId) => _guard(() {
        final operation = _source.operation(operationId);
        return const JsonEncoder.withIndent('  ').convert({
          'format': 'baystream-bitacora',
          'schema': Movement.schema,
          'exportedAt': _clock().toUtc().toIso8601String(),
          'deviceId': _source.deviceId,
          'operation': operation?.toJson(includeContent: false),
          'movements': _ordered(operationId)
              .map((r) => {
                    ...r.movement.toJson(),
                    'sendState': r.state.name,
                    if (r.rejection != null) 'rejection': r.rejection,
                  })
              .toList(),
        });
      });

  @override
  Future<Either<Failure, void>> saveOperation(Operation operation) =>
      _guard(() => _source.putOperation(operation));

  @override
  Future<Either<Failure, List<Operation>>> getOperations() => _guard(_source.operations);

  @override
  Future<Either<Failure, Operation?>> getOperation(String id) =>
      _guard(() => _source.operation(id));

  @override
  Future<Either<Failure, void>> deleteOperation(String id) async {
    final unconfirmed = await _guard(() => _source
        .movements(id)
        .any((r) => r.state != SendState.confirmed));
    return unconfirmed.fold<Future<Either<Failure, void>>>(
      (failure) async => Left(failure),
      (has) async {
        if (has) {
          return const Left(CacheFailure(
            code: 'operation_has_movements',
            message: 'La operación tiene movimientos que solo están en este '
                'dispositivo. Exporta la bitácora antes de quitarla.',
          ));
        }
        return _guard(() => _source.deleteOperation(id));
      },
    );
  }

  @override
  Future<Either<Failure, void>> close() => _guard(() async {
        await _changes.close();
        await _source.close();
      });
}
