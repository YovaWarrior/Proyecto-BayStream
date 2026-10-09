import 'dart:async';

import 'package:baystream/features/vessel/data/repositories/sync_engine.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';

/// T-79 · El servidor falso, compartido por los dispositivos. Imita lo que
/// importa de Firestore y de las reglas propuestas (T-79a 5.2): crear una
/// vez, el reenvío idéntico del autor no duplica, la lista de autorizados y
/// el cierre.
class FakeServer {
  FakeServer({DateTime Function()? clock}) : _clock = clock ?? DateTime.now;
  final DateTime Function() _clock;

  /// Lo que guarda el servidor, por id.
  final docs = <String, Movement>{};

  /// Cada `set` que llegó, incluidos los reenvíos.
  final writes = <String>[];
  int identicalResends = 0;
  final authorization = <String, RemoteAuthorization>{};

  /// Objetivos cuyo contenido no pasa las reglas.
  final denied = <String>{};
  DateTime? closedAtValue;
  final _clients = <FakeCloud>[];

  RemoteStoreException? _check(Movement movement) {
    if (authorization[movement.author.uid] != RemoteAuthorization.active) {
      return const RemoteStoreException(
          RemoteErrorKind.permissionDenied, 'permission-denied', 'cuenta');
    }
    if (denied.contains(movement.target)) {
      return const RemoteStoreException(
          RemoteErrorKind.permissionDenied, 'permission-denied', 'reglas');
    }
    final closed = closedAtValue;
    if (closed != null && movement.createdAt.isAfter(closed)) {
      return const RemoteStoreException(
          RemoteErrorKind.permissionDenied, 'permission-denied', 'cerrada');
    }
    final existing = docs[movement.id];
    if (existing != null &&
        existing.withReceivedAt(null) != movement.withReceivedAt(null)) {
      return const RemoteStoreException(
          RemoteErrorKind.permissionDenied, 'permission-denied', 'distinto');
    }
    return null;
  }

  void _store(Movement movement) {
    writes.add(movement.id);
    if (docs.containsKey(movement.id)) identicalResends++;
    docs[movement.id] = movement.withReceivedAt(_clock());
    for (final client in List.of(_clients)) {
      client._emit();
    }
  }
}

/// Un dispositivo conectado al [FakeServer], con su propia red. Sin red,
/// las escrituras esperan en cola como en el SDK y salen al volver.
class FakeCloud implements RemoteMovementStore {
  FakeCloud({DateTime Function()? clock, FakeServer? server})
      : server = server ?? FakeServer(clock: clock) {
    this.server._clients.add(this);
  }

  final FakeServer server;
  bool online = true;

  /// Recibe pero no contesta ni hace eco (T-70b: el SDK se queda sin token
  /// sin avisar).
  bool silent = false;

  /// La sesión del SDK ya no vale.
  bool unauthenticated = false;

  final _queued = <(Movement, Completer<void>)>[];
  final _listeners = <StreamController<RemoteSnapshot>>[];

  Map<String, Movement> get docs => server.docs;
  List<String> get writes => server.writes;
  int get identicalResends => server.identicalResends;
  Map<String, RemoteAuthorization> get authorization => server.authorization;
  Set<String> get denied => server.denied;
  DateTime? get closedAtValue => server.closedAtValue;
  set closedAtValue(DateTime? value) => server.closedAtValue = value;
  int get queued => _queued.length;

  @override
  Future<void> put(Movement movement) {
    if (unauthenticated) {
      return Future.error(const RemoteStoreException(
          RemoteErrorKind.unauthenticated, 'unauthenticated'));
    }
    final done = Completer<void>();
    if (!online || silent) {
      _queued.add((movement, done));
    } else {
      _apply(movement, done);
    }
    return done.future;
  }

  void _apply(Movement movement, Completer<void> done) {
    final error = server._check(movement);
    if (error != null) {
      server.writes.add(movement.id);
      done.completeError(error);
      return;
    }
    server._store(movement);
    done.complete();
  }

  /// El servidor recibió la escritura, pero la app se cerró antes de saberlo.
  void receiveWithoutAck(Movement movement) => server._store(movement);

  void goOffline() {
    online = false;
    _emit();
  }

  void goOnline() {
    online = true;
    final queued = List.of(_queued);
    _queued.clear();
    for (final (movement, done) in queued) {
      _apply(movement, done);
    }
    _emit();
  }

  /// Lo que estaba en la cola del SDK se pierde, como al forzar el cierre.
  void dropQueue() => _queued.clear();

  RemoteSnapshot _snapshot() => RemoteSnapshot(
      silent || !online ? const [] : server.docs.values.toList(),
      fromServer: online);

  void _emit() {
    for (final listener in List.of(_listeners)) {
      listener.add(_snapshot());
    }
  }

  @override
  Stream<RemoteSnapshot> watch(String operationId) {
    late final StreamController<RemoteSnapshot> controller;
    controller = StreamController<RemoteSnapshot>(
      onListen: () {
        _listeners.add(controller);
        controller.add(_snapshot());
      },
      onCancel: () {
        _listeners.remove(controller);
        return controller.close();
      },
    );
    return controller.stream;
  }

  @override
  Future<RemoteAuthorization> authorizationOf(String uid) async =>
      server.authorization[uid] ?? RemoteAuthorization.absent;

  @override
  Future<DateTime?> closedAt(String operationId) async => server.closedAtValue;
}
