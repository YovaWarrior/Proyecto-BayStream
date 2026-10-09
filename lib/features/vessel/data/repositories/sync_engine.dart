import 'dart:async';

import '../../domain/entities/movement.dart';
import '../../domain/entities/operation.dart';
import '../../domain/repositories/movement_log_repository.dart';
import '../../domain/repositories/operation_sync_repository.dart';
import '../../domain/repositories/session_repository.dart';

/// Clase de error remoto, ya clasificada por el adaptador (T-79a 4.5).
enum RemoteErrorKind { unauthenticated, permissionDenied, unavailable, invalid }

class RemoteStoreException implements Exception {
  final RemoteErrorKind kind;
  final String code;
  final String? detail;

  const RemoteStoreException(this.kind, this.code, [this.detail]);

  @override
  String toString() => 'RemoteStoreException($code${detail == null ? '' : ': $detail'})';
}

enum RemoteAuthorization { active, inactive, absent, unknown }

class RemoteSnapshot {
  /// Movimientos que el servidor ya tiene: sin escrituras pendientes de
  /// este cliente.
  final List<Movement> movements;

  /// El listener recibe del servidor, no de la caché local.
  final bool fromServer;

  const RemoteSnapshot(this.movements, {required this.fromServer});
}

/// Lo único del motor que toca la nube (T-79a 3.4).
abstract class RemoteMovementStore {
  /// `set()` con id = `movement.id`. Termina cuando el servidor confirma.
  Future<void> put(Movement movement);
  Stream<RemoteSnapshot> watch(String operationId);
  Future<RemoteAuthorization> authorizationOf(String uid);

  /// Cuándo se cerró la operación en la nube; null si sigue abierta.
  Future<DateTime?> closedAt(String operationId);
}

/// T-79 · El motor de la cola (T-79a 4.1 a 4.6), en Dart puro: no sabe que
/// existe Firestore. Habla con la nube por [RemoteMovementStore] y con el
/// dispositivo por la bitácora de T-72, que es la fuente de verdad.
///
/// - Envía cada pendiente propio una vez, en orden de secuencia, y lo
///   confirma por el `set` o por el eco del listener: basta uno.
/// - Reenviar es idempotente: el mismo id es el mismo documento.
/// - No se fía solo de los errores del SDK (T-70b): si un movimiento propio
///   lleva [unconfirmedAfter] sin confirmar con el listener recibiendo del
///   servidor, el estado pasa a [SyncState.unconfirmed].
class SyncEngine {
  final MovementLogRepository log;
  final RemoteMovementStore remote;
  final Operation operation;
  final DateTime Function() _clock;

  /// Umbral **PROVISIONAL** de 10.5: no sale de una especificación, sino de
  /// que una escritura con red se confirma en milisegundos (T-70, T-70b).
  final Duration unconfirmedAfter;
  final Duration tick;

  SyncEngine({
    required this.log,
    required this.remote,
    required this.operation,
    DateTime Function()? clock,
    this.unconfirmedAfter = const Duration(minutes: 5),
    this.tick = const Duration(seconds: 15),
  })  : _clock = clock ?? DateTime.now,
        _closed = operation.closed;

  final _status = StreamController<SyncStatus>.broadcast();
  SyncStatus _current = SyncStatus.local;
  Operator? _operator;
  List<MovementRecord> _records = const [];
  final _inFlight = <String>{};
  bool _sessionExpired = false;
  bool _notAuthorized = false;
  bool _fromServer = false;
  bool _closed;
  bool _stopped = false;
  DateTime? _onlineSince;
  StreamSubscription<RemoteSnapshot>? _remote;
  StreamSubscription<List<MovementRecord>>? _local;
  Timer? _timer;

  SyncStatus get current => _current;
  Stream<SyncStatus> get status => _status.stream;

  Future<void> start(Operator? operator) async {
    _local = log.watch(operation.id).listen((records) {
      _records = records;
      _emit();
      unawaited(flush());
    });
    _timer = Timer.periodic(tick, (_) {
      evaluate();
      unawaited(flush());
    });
    await setOperator(operator);
  }

  /// La sesión cambió. Volver a iniciar sesión, cambiar de cuenta o recuperar
  /// la autorización reanudan la escucha y el envío.
  Future<void> setOperator(Operator? operator) async {
    final previous = _operator;
    _operator = operator;
    final resumed = operator != null &&
        (previous == null ||
            previous.uid != operator.uid ||
            (operator.authorized && !previous.authorized));
    if (operator == null || !operator.authorized) {
      _notAuthorized = operator != null;
      _listen(false);
    } else if (resumed) {
      _sessionExpired = false;
      _notAuthorized = false;
      _listen(true);
    }
    _emit();
    await flush();
  }

  /// «Reintentar»: vuelve a escuchar y reenvía todo lo pendiente propio.
  Future<void> retry() async {
    _sessionExpired = false;
    _notAuthorized = !(_operator?.authorized ?? true);
    _listen(_operator?.authorized ?? false);
    _emit();
    await flush();
  }

  void _listen(bool on) {
    unawaited(_remote?.cancel());
    _remote = null;
    _fromServer = false;
    _onlineSince = null;
    if (!on || _stopped) return;
    _remote = remote.watch(operation.id).listen(_onSnapshot, onError: _onWatchError);
  }

  Future<void> _onSnapshot(RemoteSnapshot snapshot) async {
    if (snapshot.fromServer && !_fromServer) _onlineSince = _clock();
    if (!snapshot.fromServer) _onlineSince = null;
    _fromServer = snapshot.fromServer;
    if (_stopped) return;
    await log.acceptRemote(snapshot.movements);
    _emit();
    await flush();
  }

  Future<void> _onWatchError(Object error) async {
    _fromServer = false;
    _onlineSince = null;
    if (error is RemoteStoreException) {
      if (error.kind == RemoteErrorKind.unauthenticated) _sessionExpired = true;
      if (error.kind == RemoteErrorKind.permissionDenied) _notAuthorized = true;
    }
    _emit();
  }

  /// Emite `set()` de cada pendiente propio que no esté ya en vuelo, en orden
  /// de secuencia y sin esperar entre uno y otro: el SDK aplica las
  /// escrituras de un cliente en el orden en que se emiten (T-79a 4.3).
  Future<void> flush() async {
    final operator = _operator;
    if (_stopped ||
        operator == null ||
        !operator.authorized ||
        _sessionExpired ||
        _notAuthorized) {
      return;
    }
    final pending = (await log.pendingOf(operation.id, operator.uid))
        .getOrElse(() => const []);
    if (_stopped) return;
    for (final record in pending) {
      if (!_inFlight.add(record.movement.id)) continue;
      unawaited(_send(record.movement));
    }
  }

  Future<void> _send(Movement movement) async {
    try {
      await remote.put(movement);
      // Detenido el motor, la bitácora puede estar cerrada: lo confirmará
      // el eco o el reenvío del siguiente arranque.
      if (_stopped) return;
      await log.markConfirmed(movement.id);
    } on RemoteStoreException catch (error) {
      if (_stopped) return;
      await _failed(movement, error);
    } catch (_) {
      // Un error que no se sabe clasificar no rechaza: sigue pendiente.
    } finally {
      _inFlight.remove(movement.id);
      _emit();
    }
  }

  Future<void> _failed(Movement movement, RemoteStoreException error) async {
    switch (error.kind) {
      case RemoteErrorKind.unauthenticated:
        _sessionExpired = true;
      case RemoteErrorKind.unavailable:
        break;
      case RemoteErrorKind.invalid:
        await log.markRejected(movement.id,
            'Error de la aplicación (${error.code}): exporta la bitácora.');
      case RemoteErrorKind.permissionDenied:
        final authorization = await _authorization(movement.author.uid!);
        if (authorization == RemoteAuthorization.inactive ||
            authorization == RemoteAuthorization.absent) {
          // Carlos quitó la cuenta de la lista: pausa, no rechaza.
          _notAuthorized = true;
          return;
        }
        if (authorization == RemoteAuthorization.unknown) return;
        // Anular o corregir algo que todavía no llegó: espera a que llegue.
        for (final reference in [movement.annuls, movement.corrects]) {
          if (reference != null &&
              _records.any((r) =>
                  r.movement.id == reference && r.state == SendState.pending)) {
            return;
          }
        }
        DateTime? closedAt;
        try {
          closedAt = await remote.closedAt(operation.id);
        } catch (_) {
          return;
        }
        if (closedAt != null && movement.createdAt.isAfter(closedAt)) {
          _closed = true;
          // El muelle se entera del cierre y lo recuerda al reiniciar.
          if (!operation.closed) {
            await log.saveOperation(operation.copyWith(closedAt: closedAt));
          }
          await log.markRejected(
              movement.id, 'La operación se cerró antes de este movimiento.');
        } else {
          await log.markRejected(movement.id,
              'La nube rechazó este movimiento${error.detail == null ? '' : ': ${error.detail}'}.');
        }
    }
  }

  Future<RemoteAuthorization> _authorization(String uid) async {
    try {
      return await remote.authorizationOf(uid);
    } catch (_) {
      return RemoteAuthorization.unknown;
    }
  }

  /// Recalcula el estado; lo llama el reloj para la salvaguarda.
  void evaluate() => _emit();

  void _emit() {
    if (_stopped) return;
    final operator = _operator;
    var own = 0, other = 0, rejected = 0, local = 0;
    DateTime? since;
    final limit = _clock().subtract(unconfirmedAfter);
    for (final record in _records) {
      switch (record.state) {
        case SendState.localOnly:
          local++;
        case SendState.rejected:
          rejected++;
        case SendState.confirmed:
          break;
        case SendState.pending:
          if (operator == null || record.movement.author.uid != operator.uid) {
            other++;
            continue;
          }
          own++;
          final online = _onlineSince;
          if (!_fromServer || online == null) continue;
          final created = record.movement.createdAt;
          final waiting = created.isAfter(online) ? created : online;
          if (!waiting.isAfter(limit) && (since == null || created.isBefore(since))) {
            since = created;
          }
      }
    }
    final SyncState state;
    if (operator == null) {
      state = other > 0 ? SyncState.sessionExpired : SyncState.localOnly;
    } else if (!operator.authorized || _notAuthorized) {
      state = SyncState.notAuthorized;
    } else if (_sessionExpired) {
      state = SyncState.sessionExpired;
    } else if (since != null) {
      state = SyncState.unconfirmed;
    } else if (!_fromServer) {
      state = SyncState.offline;
    } else {
      state = own > 0 ? SyncState.sending : SyncState.upToDate;
    }
    final next = SyncStatus(state,
        pending: operator == null ? other : own,
        otherAuthor: operator == null ? 0 : other,
        rejected: rejected,
        localOnly: local,
        since: since,
        closed: _closed);
    if (next == _current) return;
    _current = next;
    _status.add(next);
  }

  Future<void> stop() async {
    _stopped = true;
    _timer?.cancel();
    await _remote?.cancel();
    await _local?.cancel();
    await _status.close();
  }
}
