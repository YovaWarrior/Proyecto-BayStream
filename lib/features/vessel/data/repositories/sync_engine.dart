import 'dart:async';

import '../../domain/entities/movement.dart';
import '../../domain/entities/operation.dart';
import '../../domain/repositories/movement_log_repository.dart';
import '../../domain/repositories/operation_sync_repository.dart';
import '../../domain/repositories/session_repository.dart';
import 'source_revisions.dart';

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

  /// T-127 · El manifiesto `sources` de la operación, por tipo: al
  /// suscribirse y cada vez que cambia. Solo lo que el servidor ya tiene: una
  /// escritura propia todavía pendiente no cuenta. T-130 · Trae los tres
  /// tipos, no solo el listado: el motor baja también el BAPLIE que la
  /// oficina agregó después de publicar.
  Stream<SourceManifest> watchSources(String operationId);

  /// T-127 · Los trozos de esa revisión del listado, del servidor. Sin red
  /// falla con [RemoteStoreException] y el motor lo vuelve a intentar.
  Future<List<SourcePart>> listParts(String operationId, int revision);

  /// T-130 · Los trozos de ese BAPLIE (`{tipo}-{i}`, sin revisión), del
  /// servidor. Sin red falla con [RemoteStoreException] y el motor lo vuelve
  /// a intentar.
  Future<List<SourcePart>> planParts(String operationId, OperationSourceKind kind);
}

/// T-130 (10.90, ajuste 3) · Las escrituras de fuentes propias en vuelo, lo
/// que enseñó T-129: el eco del servidor puede llegar al motor **antes** de
/// que el adaptador guarde en local la fuente que acaba de subir. El
/// adaptador anota (operación, tipo, huella) antes del lote y lo borra
/// después de guardar en local (o al fallar); el motor, al ver en el
/// manifiesto una entrada anotada, no la baja ni avisa: esa fuente la guarda
/// el adaptador, una sola vez. Lo comparten el adaptador y todos sus motores.
class OwnSourceWrites {
  final _inFlight = <String>{};

  static String _key(String operationId, OperationSourceKind kind, String sha256) =>
      '$operationId/${kind.wire}/$sha256';

  void begin(String operationId, OperationSourceKind kind, String sha256) =>
      _inFlight.add(_key(operationId, kind, sha256));

  void end(String operationId, OperationSourceKind kind, String sha256) =>
      _inFlight.remove(_key(operationId, kind, sha256));

  bool contains(String operationId, OperationSourceKind kind, String sha256) =>
      _inFlight.contains(_key(operationId, kind, sha256));

  bool get isEmpty => _inFlight.isEmpty;
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

  /// T-130 · Las escrituras propias en vuelo del adaptador que creó este
  /// motor; un motor solo (las pruebas) tiene el suyo, vacío.
  final OwnSourceWrites ownWrites;

  SyncEngine({
    required this.log,
    required this.remote,
    required this.operation,
    DateTime Function()? clock,
    this.unconfirmedAfter = const Duration(minutes: 5),
    this.tick = const Duration(seconds: 15),
    OwnSourceWrites? ownWrites,
  })  : _clock = clock ?? DateTime.now,
        ownWrites = ownWrites ?? OwnSourceWrites(),
        _closed = operation.closed,
        _localListRevision = operation.exportListRevision,
        _localPlans = {
          for (final source in operation.sources)
            if (source.kind != OperationSourceKind.exportList) source.kind
        };

  final _status = StreamController<SyncStatus>.broadcast();
  SyncStatus _current = SyncStatus.local;
  Operator? _operator;
  List<MovementRecord> _records = const [];
  final _inFlight = <String>{};
  bool _sessionExpired = false;
  bool _notAuthorized = false;
  bool _fromServer = false;
  bool _connectionKnown = false;
  bool _closed;
  bool _stopped = false;
  DateTime? _onlineSince;
  StreamSubscription<RemoteSnapshot>? _remote;
  StreamSubscription<List<MovementRecord>>? _local;
  Timer? _timer;

  // T-127 · El listado de la agencia con revisión (8.3 de T-122; 10.78).
  // T-130 · Y los BAPLIE que la oficina agrega después de publicar (10.90).
  StreamSubscription<SourceManifest>? _sources;
  SourceManifest _remoteSources = SourceManifest.empty;

  /// La revisión del listado que la operación local ya tiene.
  int _localListRevision;
  bool _fetchingList = false;

  /// Una revisión cuyos trozos no cuadraron con el manifiesto: no se vuelve
  /// a bajar; el dispositivo se queda con el listado anterior, como `join`.
  int? _rejectedListRevision;
  ListArrival? _listArrival;

  /// T-130 · Los BAPLIE que la operación local ya tiene.
  final Set<OperationSourceKind> _localPlans;
  bool _fetchingPlan = false;

  /// T-130 · Un BAPLIE cuyos trozos no cuadraron con su entrada (por huella):
  /// no se vuelve a pedir mientras la entrada sea esa.
  final _rejectedPlans = <OperationSourceKind, String>{};
  PlanArrival? _planArrival;

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
      unawaited(_syncSources());
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
    unawaited(_sources?.cancel());
    _sources = null;
    _fromServer = false;
    _connectionKnown = false;
    _onlineSince = null;
    if (!on || _stopped) return;
    _remote = remote.watch(operation.id).listen(_onSnapshot, onError: _onWatchError);
    _sources = remote
        .watchSources(operation.id)
        .listen(_onSources, onError: _onWatchError);
  }

  Future<void> _onSnapshot(RemoteSnapshot snapshot) async {
    // T-97: la caché inicial no prueba una caída. Tras recibir del servidor,
    // volver a caché sí confirma que el listener perdió esa conexión.
    if (snapshot.fromServer || _fromServer) _connectionKnown = true;
    if (snapshot.fromServer && !_fromServer) _onlineSince = _clock();
    if (!snapshot.fromServer) _onlineSince = null;
    _fromServer = snapshot.fromServer;
    if (_stopped) return;
    await log.acceptRemote(snapshot.movements);
    _emit();
    await flush();
    // T-127: con el servidor de vuelta, lo que no se pudo bajar.
    if (snapshot.fromServer) unawaited(_syncSources());
  }

  Future<void> _onWatchError(Object error) async {
    _fromServer = false;
    _onlineSince = null;
    if (error is RemoteStoreException) {
      if (error.kind == RemoteErrorKind.unavailable) _connectionKnown = true;
      if (error.kind == RemoteErrorKind.unauthenticated) _sessionExpired = true;
      if (error.kind == RemoteErrorKind.permissionDenied) _notAuthorized = true;
    }
    _emit();
  }

  /// T-127 · El manifiesto de la operación cambió, o se acaba de escuchar.
  Future<void> _onSources(SourceManifest manifest) async {
    _remoteSources = manifest;
    await _syncSources();
  }

  /// T-127 y T-130 · Lo que el manifiesto declara y la operación local no
  /// tiene: la revisión nueva del listado, y el BAPLIE agregado.
  Future<void> _syncSources() async {
    await _syncList();
    await _syncPlans();
  }

  /// T-127 · Si el manifiesto trae una revisión del listado mayor que la
  /// local, baja solo sus trozos, los comprueba como `join` y guarda la
  /// fuente en la operación local, con los movimientos intactos: el estado
  /// se vuelve a derivar con el listado nuevo. Sin red, el dispositivo sigue
  /// con el listado que tenía y lo reintenta al siguiente contacto con el
  /// servidor (8.3, punto 3).
  Future<void> _syncList() async {
    final entry = _remoteSources.exportList;
    final revision = entry?.revision ?? 0;
    if (entry == null ||
        _stopped ||
        _fetchingList ||
        revision <= _localListRevision ||
        revision == _rejectedListRevision ||
        // T-130: el listado que esta misma oficina está subiendo lo guarda
        // el adaptador; el eco no es noticia.
        ownWrites.contains(operation.id, OperationSourceKind.exportList, entry.sha256)) {
      return;
    }
    _fetchingList = true;
    try {
      // Lo que el dispositivo ya guardó manda: la oficina que acaba de
      // revisar el listado lo tiene en local antes de que llegue el eco.
      final before = await _localOperation();
      if (before != null && before.exportListRevision > _localListRevision) {
        _localListRevision = before.exportListRevision;
      }
      if (_stopped || revision <= _localListRevision) return;
      final parts = await remote.listParts(operation.id, revision);
      if (_stopped) return;
      final source = assembleSource(entry, parts);
      final rows = source == null ? null : exportListRows(source.content);
      if (source == null || rows == null) {
        _rejectedListRevision = revision;
        return;
      }
      final current = await _localOperation();
      if (_stopped || current == null || current.exportListRevision >= revision) {
        return;
      }
      final saved = await log.saveOperation(current.copyWith(sources: [
        ...current.sources.where((s) => s.kind != OperationSourceKind.exportList),
        source,
      ]));
      if (saved.isLeft()) return;
      _localListRevision = revision;
      _listArrival = ListArrival(revision: revision, rows: rows);
      _emit();
    } on RemoteStoreException catch (_) {
      // Sin red o sin respuesta: se queda el listado anterior hasta reconectar.
    } catch (_) {
      // Un error que no se sabe clasificar tampoco toca el listado local.
    } finally {
      _fetchingList = false;
    }
  }

  /// T-130 · Por cada BAPLIE que el manifiesto declara y la operación local
  /// no tiene: relee la operación local (lo que el dispositivo guardó manda),
  /// salta lo que esta misma oficina está subiendo, baja sus trozos, los
  /// comprueba como `join`, guarda la fuente en la operación local **sin
  /// tocar los movimientos** y lo dice en [SyncStatus.planArrival]. Sin red,
  /// se queda con lo que tiene y lo reintenta al siguiente contacto con el
  /// servidor. Un plan cuyos trozos no cuadran se anota y no se vuelve a
  /// pedir mientras su entrada sea la misma.
  Future<void> _syncPlans() async {
    if (_stopped || _fetchingPlan) return;
    _fetchingPlan = true;
    try {
      for (final entry in _remoteSources.plans) {
        if (_stopped) return;
        if (_localPlans.contains(entry.kind) ||
            _rejectedPlans[entry.kind] == entry.sha256 ||
            ownWrites.contains(operation.id, entry.kind, entry.sha256)) {
          continue;
        }
        final before = await _localOperation();
        if (_stopped) return;
        if (before != null) _refreshLocalPlans(before);
        if (_localPlans.contains(entry.kind)) continue;
        final parts = await remote.planParts(operation.id, entry.kind);
        if (_stopped) return;
        final source = assembleSource(entry, parts);
        if (source == null) {
          _rejectedPlans[entry.kind] = entry.sha256;
          continue;
        }
        final current = await _localOperation();
        if (_stopped || current == null) return;
        _refreshLocalPlans(current);
        if (_localPlans.contains(entry.kind)) continue;
        final saved = await log.saveOperation(
            current.copyWith(sources: [...current.sources, source]));
        if (saved.isLeft()) continue;
        _localPlans.add(entry.kind);
        _planArrival = PlanArrival(
            kind: entry.kind, fileName: entry.fileName, voyage: entry.voyage);
        _emit();
      }
    } on RemoteStoreException catch (_) {
      // Sin red o sin respuesta: se queda con los planos que tiene.
    } catch (_) {
      // Un error que no se sabe clasificar tampoco toca la operación local.
    } finally {
      _fetchingPlan = false;
    }
  }

  void _refreshLocalPlans(Operation local) {
    for (final source in local.sources) {
      if (source.kind != OperationSourceKind.exportList) _localPlans.add(source.kind);
    }
  }

  Future<Operation?> _localOperation() async =>
      (await log.getOperation(operation.id)).fold((_) => null, (o) => o);

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
        _connectionKnown = true;
        _fromServer = false;
        _onlineSince = null;
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
          // Solo el texto del rechazo: sin cambiar su clasificación ni el
          // registro. Un detalle ya puntuado no recibe un segundo punto.
          final detail = error.detail?.trim().replaceFirst(RegExp(r'\.+$'), '');
          await log.markRejected(movement.id,
              'La nube rechazó este movimiento${detail == null || detail.isEmpty ? '' : ': $detail'}.');
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
      state = _connectionKnown ? SyncState.offline : SyncState.connecting;
    } else {
      state = own > 0 ? SyncState.sending : SyncState.upToDate;
    }
    final next = SyncStatus(state,
        pending: operator == null ? other : own,
        otherAuthor: operator == null ? 0 : other,
        rejected: rejected,
        localOnly: local,
        since: since,
        closed: _closed,
        listArrival: _listArrival,
        planArrival: _planArrival);
    if (next == _current) return;
    _current = next;
    _status.add(next);
  }

  Future<void> stop() async {
    _stopped = true;
    _timer?.cancel();
    await _remote?.cancel();
    await _sources?.cancel();
    await _local?.cancel();
    await _status.close();
  }
}
