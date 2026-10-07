import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/movement.dart';
import '../entities/operation.dart';

/// T-72 · Bitácora local de la operación (T-79a 3.2 y 4.1).
///
/// Todo se escribe primero aquí, con `flush`, y funciona sin conexión en los
/// tres clientes. T-79 agrega lo propio de la sincronización (pendientes por
/// autor, aceptar lo remoto, confirmar y rechazar) sobre este mismo almacén.
abstract class MovementLogRepository {
  /// Asigna id (UUID v4), autor, dispositivo, secuencia y hora, y persiste.
  /// Solo cuando devuelve Right la pantalla puede decir «registrado».
  Future<Either<Failure, MovementRecord>> append(
      MovementDraft draft, MovementAuthor author);

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
