import 'dart:async';

import 'package:baystream/features/vessel/data/repositories/source_revisions.dart';
import 'package:baystream/features/vessel/data/repositories/sync_engine.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';

/// T-79 · El servidor falso, compartido por los dispositivos. Imita lo que
/// importa de Firestore y de las reglas propuestas (T-79a 5.2): crear una
/// vez, el reenvío idéntico del autor no duplica, la lista de autorizados y
/// el cierre. T-127: el manifiesto del listado y sus trozos por revisión.
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

  /// T-127 · La entrada `sources.export_list` del manifiesto y los trozos de
  /// todas las revisiones, como quedan en `sources/`: los viejos no se borran.
  SourceManifestEntry? listManifest;
  final sourceParts = <SourcePart>[];

  /// T-130 · Las entradas de los BAPLIE del manifiesto (`sources.arrival_baplie`
  /// y `sources.loading_baplie`), publicados con la operación o agregados.
  final plans = <OperationSourceKind, SourceManifestEntry>{};

  /// T-130 · El manifiesto entero, como lo escucha el motor.
  SourceManifest get manifest => SourceManifest({
        ...plans,
        if (listManifest case final list?) OperationSourceKind.exportList: list,
      });

  /// T-130 · Un BAPLIE publicado con la operación, o agregado después por la
  /// oficina (`addSource`): los trozos `{tipo}-{i}` sin revisión y su entrada,
  /// con `voyage` si el archivo declara otro viaje. Los dispositivos con red
  /// reciben el manifiesto nuevo.
  SourceManifestEntry addPlan(OperationSourceKind kind, String content,
      {String? fileName, String? voyage}) {
    final packed = packSource(OperationSource(
        kind: kind,
        fileName: fileName ?? '${kind.wire}.edi',
        content: content,
        voyage: voyage));
    sourceParts.addAll(packed.parts);
    plans[kind] = packed.entry;
    for (final client in List.of(_clients)) {
      client._emitSources();
    }
    return packed.entry;
  }

  /// T-127 · Un listado publicado junto con la operación, sin revisión, como
  /// lo escribe `publish` (también en la 0.4.0).
  void publishList(String content, {String fileName = 'listado.xlsx'}) {
    final packed = packSource(OperationSource(
        kind: OperationSourceKind.exportList,
        fileName: fileName,
        content: content));
    sourceParts.addAll(packed.parts);
    listManifest = packed.entry;
  }

  /// T-127 · La oficina agrega o reemplaza el listado en un lote, como
  /// `replaceSource`: los trozos con la revisión siguiente (o [revision]) y
  /// el manifiesto. Los dispositivos con red reciben el manifiesto nuevo.
  SourceManifestEntry reviseList(String content,
      {String fileName = 'listado.xlsx', int? revision}) {
    final next = revision ?? (listManifest?.revision ?? 0) + 1;
    final packed = packSource(
        OperationSource(
            kind: OperationSourceKind.exportList,
            fileName: fileName,
            content: content),
        revision: next);
    sourceParts.addAll(packed.parts);
    listManifest = packed.entry;
    for (final client in List.of(_clients)) {
      client._emitSources();
    }
    return packed.entry;
  }

  /// T-143 · La oficina cierra: el documento de la operación cambia y los
  /// dispositivos con red lo reciben en la misma escucha que las fuentes; los
  /// que no tienen red lo reciben al volver. (Asignar [closedAtValue] a mano
  /// solo cambia lo que el servidor contesta, como antes.)
  void closeOperation(DateTime at) {
    closedAtValue = at;
    for (final client in List.of(_clients)) {
      client._emitSources();
    }
  }

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
  final _sourcesListeners = <StreamController<RemoteOperationDocument>>[];

  /// T-127 · Lo último que este dispositivo vio del manifiesto: su caché, lo
  /// que el SDK entrega sin red.
  SourceManifest _seenSources = SourceManifest.empty;

  /// T-143 · La hora del cierre que este dispositivo vio por última vez.
  DateTime? _seenClosedAt;

  RemoteOperationDocument get _document =>
      RemoteOperationDocument(_seenSources, closedAt: _seenClosedAt);

  /// T-127 · Cuántas bajadas de trozos fallarán antes de responder, y
  /// cuántas se pidieron.
  int listPartsFailures = 0;
  int listPartsRequests = 0;

  /// T-130 · Lo mismo para los trozos de un BAPLIE agregado.
  int planPartsFailures = 0;
  int planPartsRequests = 0;

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
    _emitSources();
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

  /// T-127 · Con red, el manifiesto del servidor; sin red, nada nuevo.
  void _emitSources() {
    if (!online) return;
    _seenSources = server.manifest;
    _seenClosedAt = server.closedAtValue;
    for (final listener in List.of(_sourcesListeners)) {
      listener.add(_document);
    }
  }

  /// T-127 · Al suscribirse, con red, lo que tiene el servidor; sin red, lo
  /// último visto (la caché del SDK). T-130: el manifiesto entero. T-143: y
  /// la hora del cierre, del mismo documento.
  @override
  Stream<RemoteOperationDocument> watchOperation(String operationId) {
    late final StreamController<RemoteOperationDocument> controller;
    controller = StreamController<RemoteOperationDocument>(
      onListen: () {
        _sourcesListeners.add(controller);
        if (online) {
          _seenSources = server.manifest;
          _seenClosedAt = server.closedAtValue;
        }
        controller.add(_document);
      },
      onCancel: () {
        _sourcesListeners.remove(controller);
        return controller.close();
      },
    );
    return controller.stream;
  }

  /// T-130 · Los trozos `{tipo}-{i}` de un BAPLIE, sin revisión; sin red
  /// falla, y [planPartsFailures] hace fallar las primeras bajadas.
  @override
  Future<List<SourcePart>> planParts(
      String operationId, OperationSourceKind kind) async {
    planPartsRequests++;
    if (!online) {
      throw const RemoteStoreException(RemoteErrorKind.unavailable, 'unavailable');
    }
    if (planPartsFailures > 0) {
      planPartsFailures--;
      throw const RemoteStoreException(RemoteErrorKind.unavailable, 'unavailable');
    }
    return [
      for (final part in server.sourceParts)
        if (part.kind == kind && part.revision == null) part
    ];
  }

  @override
  Future<List<SourcePart>> listParts(String operationId, int revision) async {
    listPartsRequests++;
    if (!online) {
      throw const RemoteStoreException(RemoteErrorKind.unavailable, 'unavailable');
    }
    if (listPartsFailures > 0) {
      listPartsFailures--;
      throw const RemoteStoreException(RemoteErrorKind.unavailable, 'unavailable');
    }
    return [
      for (final part in server.sourceParts)
        if (part.revision == revision) part
    ];
  }
}
