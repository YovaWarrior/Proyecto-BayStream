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

  MovementLogRepositoryImpl(
    this._source, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  /// T-79 (T-79a 4.2) · Solo se sube lo que la nube puede aceptar y verificar:
  /// un autor con cuenta, en una operación publicada, que no anule ni corrija
  /// algo que se quedó en el dispositivo. Lo demás queda `localOnly`, que es
  /// el modo de un solo dispositivo y el respaldo del 14-oct.
  SendState _stateFor(MovementDraft draft, MovementAuthor author) {
    if (author.uid == null) return SendState.localOnly;
    final operation = _source.operation(draft.operationId);
    if (operation == null || !operation.published) return SendState.localOnly;
    for (final reference in [draft.payload['annuls'], draft.payload['corrects']]) {
      if (reference is String &&
          _source.movement(reference)?.state == SendState.localOnly) {
        return SendState.localOnly;
      }
    }
    return SendState.pending;
  }

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
      // T-79 · En milisegundos: la Web no guarda microsegundos, y el orden
      // total por `createdAt` tiene que ser el mismo en los tres clientes.
      final now = _clock();
      final registeredAt = now.isUtc
          ? DateTime.fromMillisecondsSinceEpoch(now.millisecondsSinceEpoch, isUtc: true)
          : DateTime.fromMillisecondsSinceEpoch(now.millisecondsSinceEpoch);
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
        _stateFor(draft, author),
      );
      await _source.putMovement(record);
      _changes.add(draft.operationId);
      return record;
    });
  }

  @override
  Future<Either<Failure, List<MovementRecord>>> pendingOf(
          String operationId, String authorUid) =>
      _guard(() => _source
          .movements(operationId)
          .where((r) =>
              r.state == SendState.pending && r.movement.author.uid == authorUid)
          .toList()
        ..sort((a, b) => a.movement.sequence.compareTo(b.movement.sequence)));

  @override
  Future<Either<Failure, void>> acceptRemote(Iterable<Movement> movements) =>
      _guard(() async {
        final changed = <MovementRecord>[];
        for (final movement in movements) {
          final local = _source.movement(movement.id);
          if (local == null) {
            changed.add(MovementRecord(movement, SendState.confirmed));
          } else if (local.state != SendState.confirmed ||
              local.movement.receivedAt != movement.receivedAt) {
            // Lo propio se conserva tal como se registró: de la nube solo
            // entra la hora de recepción.
            changed.add(MovementRecord(
                local.movement.withReceivedAt(
                    movement.receivedAt ?? local.movement.receivedAt),
                SendState.confirmed));
          }
        }
        if (changed.isEmpty) return;
        await _source.putMovements(changed);
        for (final id in changed.map((r) => r.movement.operationId).toSet()) {
          _changes.add(id);
        }
      });

  @override
  Future<Either<Failure, void>> markConfirmed(String id, {DateTime? receivedAt}) =>
      _guard(() async {
        final local = _source.movement(id);
        if (local == null) return;
        if (local.state == SendState.confirmed &&
            (receivedAt == null || local.movement.receivedAt == receivedAt)) {
          return;
        }
        await _source.putMovement(MovementRecord(
            local.movement.withReceivedAt(receivedAt ?? local.movement.receivedAt),
            SendState.confirmed));
        _changes.add(local.movement.operationId);
      });

  @override
  Future<Either<Failure, void>> markRejected(String id, String reason) =>
      _guard(() async {
        final local = _source.movement(id);
        if (local == null || local.state == SendState.confirmed) return;
        await _source.putMovement(
            MovementRecord(local.movement, SendState.rejected, rejection: reason));
        _changes.add(local.movement.operationId);
      });

  @override
  Future<Either<Failure, int>> requeueRejected(String operationId) =>
      _guard(() async {
        final rejected = _source
            .movements(operationId)
            .where((r) => r.state == SendState.rejected)
            .map((r) => MovementRecord(r.movement, SendState.pending))
            .toList();
        if (rejected.isEmpty) return 0;
        await _source.putMovements(rejected);
        _changes.add(operationId);
        return rejected.length;
      });

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
