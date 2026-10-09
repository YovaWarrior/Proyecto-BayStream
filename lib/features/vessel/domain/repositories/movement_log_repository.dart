import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/movement.dart';
import '../entities/operation.dart';

/// T-72 · Bitácora local de la operación (T-79a 3.2 y 4.1).
///
/// Todo se escribe primero aquí, con `flush`, y funciona sin conexión en los
/// tres clientes. T-79 agrega lo propio de la sincronización (pendientes por
/// autor, aceptar lo remoto, confirmar y rechazar) sobre este mismo almacén:
/// la cola en Hive es la fuente de verdad, no la del SDK.
abstract class MovementLogRepository {
  /// Asigna id (UUID v4), autor, dispositivo, secuencia y hora, y persiste.
  /// Solo cuando devuelve Right la pantalla puede decir «registrado».
  ///
  /// T-79 · Nace `pending` solo si el autor tiene cuenta, la operación está
  /// publicada y no anula ni corrige un movimiento que se quedó en el
  /// dispositivo; si no, `localOnly`, como en el modo de un solo dispositivo.
  Future<Either<Failure, MovementRecord>> append(
      MovementDraft draft, MovementAuthor author);

  /// T-79 · Pendientes de envío de [authorUid], en orden de secuencia.
  Future<Either<Failure, List<MovementRecord>>> pendingOf(
      String operationId, String authorUid);

  /// T-79 · Lo que confirmó la nube: lo de otros dispositivos se anexa como
  /// confirmado y lo propio pasa a confirmado. Un id repetido no se duplica.
  Future<Either<Failure, void>> acceptRemote(Iterable<Movement> movements);

  Future<Either<Failure, void>> markConfirmed(String id, {DateTime? receivedAt});

  /// RECHAZADO no cuenta para el estado, pero no se borra (T-79a 4.2).
  Future<Either<Failure, void>> markRejected(String id, String reason);

  /// Devuelve a la cola lo rechazado de la operación; dice cuántos.
  Future<Either<Failure, int>> requeueRejected(String operationId);

  /// Movimientos de la operación, en el orden total de T-79a 2.7.2.
  Future<Either<Failure, List<MovementRecord>>> records(String operationId);

  /// Emite la lista completa al suscribirse y después de cada cambio.
  Stream<List<MovementRecord>> watch(String operationId);

  /// Punto de control del 14-oct: la bitácora en JSON, sin red.
  Future<Either<Failure, String>> exportJson(String operationId);

  Future<Either<Failure, void>> saveOperation(Operation operation);
  Future<Either<Failure, List<Operation>>> getOperations();
  Future<Either<Failure, Operation?>> getOperation(String id);

  /// Rechaza con `operation_has_movements` si la operación tiene algún
  /// movimiento que no está confirmado en la nube: sería la única copia.
  Future<Either<Failure, void>> deleteOperation(String id);

  Future<Either<Failure, void>> close();
}
