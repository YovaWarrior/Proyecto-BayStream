import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/operation.dart';
import '../entities/vessel_profile.dart';

/// T-79 · Sincronización de una operación entre dispositivos (T-79a 3.3).
/// La presentación solo ve este contrato; no sabe si corre Firestore.
enum SyncCapability { none, realtime }

/// Lo que la pantalla dice del envío (T-79a 4.2 y 4.5).
enum SyncState {
  /// Sin cuenta, sin publicar o sin la nube: modo de un solo dispositivo.
  localOnly,
  upToDate,
  sending,
  offline,
  sessionExpired,
  notAuthorized,

  /// Salvaguarda de 10.5 (umbral PROVISIONAL de 5 minutos): un movimiento
  /// propio sigue sin confirmar mientras el listener recibe del servidor.
  /// El SDK puede quedarse sin token sin avisar (T-70b).
  unconfirmed,
}

class SyncStatus extends Equatable {
  final SyncState state;

  /// Movimientos propios por enviar.
  final int pending;
  final int rejected;

  /// Movimientos que no se suben: registrados sin cuenta o antes de publicar.
  final int localOnly;

  /// Pendientes de otra cuenta de este dispositivo: esperan a su autor.
  final int otherAuthor;

  /// En `unconfirmed`, la hora de registro del más antiguo sin confirmar.
  final DateTime? since;
  final bool closed;

  const SyncStatus(
    this.state, {
    this.pending = 0,
    this.rejected = 0,
    this.localOnly = 0,
    this.otherAuthor = 0,
    this.since,
    this.closed = false,
  });

  static const local = SyncStatus(SyncState.localOnly);

  @override
  List<Object?> get props =>
      [state, pending, rejected, localOnly, otherAuthor, since, closed];

  @override
  String toString() => 'SyncStatus(${state.name}, pendientes $pending, '
      'rechazados $rejected, locales $localOnly, de otra cuenta $otherAuthor'
      '${since == null ? '' : ', desde $since'}${closed ? ', cerrada' : ''})';
}

/// Una operación abierta en la nube, para que el muelle elija a cuál unirse.
class PublishedOperation extends Equatable {
  final String id;
  final String vesselName;
  final String voyageNumber;
  final String portOfCall;
  final DateTime? createdAt;
  final List<OperationSourceKind> sources;

  const PublishedOperation({
    required this.id,
    required this.vesselName,
    required this.voyageNumber,
    required this.portOfCall,
    this.createdAt,
    this.sources = const [],
  });

  @override
  List<Object?> get props =>
      [id, vesselName, voyageNumber, portOfCall, createdAt, sources];
}

abstract class OperationSyncRepository {
  SyncCapability get capability;

  /// Oficina: la operación, su perfil y sus fuentes en un solo lote.
  /// Requiere red. Devuelve la operación local marcada como publicada.
  Future<Either<Failure, Operation>> publish(
      Operation operation, VesselProfile profile);

  Stream<List<PublishedOperation>> watchOpenOperations();

  /// Muelle: descarga la operación y sus fuentes, comprueba la huella de cada
  /// fuente sobre el texto publicado tal cual y la guarda en local.
  Future<Either<Failure, Operation>> join(String operationId);

  /// Oficina: cierra la operación, una vez.
  Future<Either<Failure, Operation>> close(String operationId);

  /// Sigue la operación: escucha la nube y envía lo pendiente mientras haya
  /// alguien suscrito. Emite el estado al suscribirse y en cada cambio.
  Stream<SyncStatus> follow(Operation operation);

  /// Vuelve a poner en cola lo rechazado y reenvía lo pendiente.
  Future<void> retry(String operationId);

  Future<void> dispose();
}
