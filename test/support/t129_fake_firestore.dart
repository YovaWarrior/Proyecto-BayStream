import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart'
    show
        CollectionReferencePlatform,
        DocumentReferencePlatform,
        DocumentSnapshotPlatform,
        FieldValuePlatform,
        FirebaseFirestorePlatform,
        InternalSnapshotMetadata;
import 'package:firebase_core/firebase_core.dart';

/// T-129 (O-128-2) · Una nube falsa en la capa de plataforma de Firestore,
/// debajo de las clases reales de `cloud_firestore` (`FirebaseFirestore`,
/// `DocumentReference`, `DocumentSnapshot`, `FieldValue`), que son `@sealed`
/// y no se pueden falsificar. Es la capa que implementa `cloud_firestore_web`.
/// Tiene lo justo que toca `FirestoreOperationSync.close`:
/// `collection().doc()`, `get`, `update` y `snapshots`, con instantáneas que
/// llevan sus metadatos.
///
/// Imita lo que el SDK hace con un documento que **ya se escucha** (en la
/// app, el motor de T-127 lo escucha mientras la oficina sigue la operación).
/// La fuente es firebase-js-sdk 12.17.0: `core/view.ts`,
/// `core/event_manager.ts`, `core/firestore_client.ts` y
/// `core/sync_engine_impl.ts` (`docs/T129-RESULTADOS.md`, 3.3):
///
/// - Una lectura «del servidor» (`Source.server`) es una escucha de una sola
///   vez sobre la misma consulta. Si la consulta ya tiene una escucha, la
///   nueva recibe la última instantánea de esa escucha y, como la vista ya
///   está al día (`fromCache` falso), se resuelve con ella sin ir al
///   servidor; nadie mira `hasPendingWrites`.
/// - Una escritura propia con `FieldValue.serverTimestamp()` entra primero
///   en la vista local: las escuchas reciben una instantánea con
///   `hasPendingWrites` y la hora pendiente, que la plataforma entrega como
///   nula (`ServerTimestampBehavior.none`, el único que usa la app). El
///   servidor la confirma y el `update` termina **sin que la vista cambie**:
///   el SDK calla la instantánea del acuse porque «Watch mandará el mismo
///   documento otra vez». Solo el eco del servidor, que llega en una vuelta
///   posterior del bucle de eventos, trae la hora real y `hasPendingWrites`
///   en falso.
/// - Sin escucha abierta, la lectura «del servidor» trae el documento del
///   servidor, con la hora real.
///
/// Simplificaciones, a propósito: toda instantánea de una escucha es «al
/// día» (`isFromCache` falso); una escucha nueva después del acuse espera el
/// eco igual que una vieja (en el SDK ya leería la hora real: aquí se modela
/// el caso más exigente); todo `FieldValue` se trata como `serverTimestamp`,
/// el único que la app escribe. No hay caché sin red, lotes ni consultas: lo
/// que no se usa lanza `UnimplementedError`, como la plataforma base.
///
/// Cada nube falsa tiene su propia `FirebaseApp` falsa, con un nombre único,
/// porque `FirebaseFirestore.instanceFor` guarda una instancia por app.
class T129FakeFirestore {
  T129FakeFirestore({DateTime Function()? clock})
      : _clock = clock ?? DateTime.now {
    _platform = _T129Platform._(this, _T129App('t129-${_apps++}'));
  }

  static int _apps = 0;

  final DateTime Function() _clock;
  late final _T129Platform _platform;

  /// Lo que guarda el servidor, por ruta (`operations/<id>`).
  final server = <String, Map<String, Object?>>{};

  /// Lecturas «del servidor» que se resolvieron con la vista de una escucha
  /// abierta, sin ir al servidor.
  int readsFromListenedView = 0;

  /// Revisión de Codex (10.91) · Con `true`, el eco que sigue a una escritura
  /// propia no llega: el servidor la aplica y el `update` termina, pero las
  /// escuchas se quedan con la vista pendiente, como sin red después del
  /// acuse. Las instantáneas rechazadas las entrega
  /// [T129FakeDocument.emitRejected].
  bool holdEcho = false;

  final _documents = <String, T129FakeDocument>{};

  /// El `FirebaseFirestore` real que la app recibe, sobre esta nube.
  late final FirebaseFirestore instance = _platform.connect();

  T129FakeDocument document(String path) =>
      _documents.putIfAbsent(path, () => T129FakeDocument._(this, path));
}

/// La app de Firebase de una nube falsa: solo su nombre, que es lo único que
/// `FirebaseFirestore` lee antes de pedir la plataforma.
class _T129App implements FirebaseApp {
  _T129App(this.name);

  @override
  final String name;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('T129FakeFirestore: ${invocation.memberName}');
}

/// La plataforma de Firestore de una nube falsa. La instancia global de la
/// plataforma es una más de éstas, sin nube, que reparte cada app a la suya.
class _T129Platform extends FirebaseFirestorePlatform {
  _T129Platform._(this._cloud, FirebaseApp app)
      : super(appInstance: app, databaseChoice: '(default)');

  _T129Platform._router() : _cloud = null;

  static final _byApp = <String, _T129Platform>{};

  /// Si la instancia global ya es el repartidor. Se lleva aparte porque leer
  /// `FirebaseFirestorePlatform.instance` sin asignarla crea la de canales,
  /// que pide `Firebase.app()`.
  static bool _routing = false;

  final T129FakeFirestore? _cloud;

  T129FakeFirestore get _ownCloud =>
      _cloud ?? (throw StateError('T129FakeFirestore: plataforma sin nube'));

  FirebaseFirestore connect() {
    if (!_routing) {
      FirebaseFirestorePlatform.instance = _T129Platform._router();
      _routing = true;
    }
    _byApp[app.name] = this;
    return FirebaseFirestore.instanceFor(app: app);
  }

  @override
  FirebaseFirestorePlatform delegateFor(
          {required FirebaseApp app, required String databaseId}) =>
      _byApp[app.name] ??
      (throw StateError('T129FakeFirestore: ninguna nube para ${app.name}'));

  @override
  CollectionReferencePlatform collection(String collectionPath) =>
      _T129Collection(this, collectionPath);

  @override
  DocumentReferencePlatform doc(String documentPath) =>
      _ownCloud.document(documentPath);
}

class _T129Collection extends CollectionReferencePlatform {
  _T129Collection(this._platform, String path) : super(_platform, path);

  final _T129Platform _platform;

  @override
  DocumentReferencePlatform doc([String? path]) {
    if (path == null) {
      throw UnimplementedError('T129FakeFirestore: doc() sin id');
    }
    return _platform._ownCloud.document('${this.path}/$path');
  }
}

/// Un documento de la nube falsa: lo que tiene el servidor, su vista local
/// mientras una escritura propia espera el eco, y las escuchas abiertas.
class T129FakeDocument extends DocumentReferencePlatform {
  T129FakeDocument._(this._cloud, String path)
      : super(_cloud._platform, path);

  final T129FakeFirestore _cloud;

  final _listeners = <StreamController<DocumentSnapshotPlatform>>[];

  /// La vista local mientras una escritura propia espera el eco: el documento
  /// del servidor con lo escrito encima y la hora pendiente como nula.
  Map<String, Object?>? _pendingView;

  /// La última instantánea que recibieron las escuchas abiertas; nula sin
  /// escuchas, porque entonces el SDK no tiene vista de la consulta.
  DocumentSnapshotPlatform? _lastEmitted;

  /// Cuántas escuchas hay abiertas sobre el documento.
  int get listeners => _listeners.length;

  /// Si una escritura propia sigue esperando el eco del servidor.
  bool get awaitingEcho => _pendingView != null;

  Map<String, Object?>? get _serverData => _cloud.server[path];

  DocumentSnapshotPlatform _snapshot(Map<String, Object?>? data,
          {required bool hasPendingWrites, bool isFromCache = false}) =>
      DocumentSnapshotPlatform(
        _cloud._platform,
        path,
        data == null ? null : Map<String, Object?>.unmodifiable(data),
        InternalSnapshotMetadata(
            hasPendingWrites: hasPendingWrites, isFromCache: isFromCache),
      );

  /// Revisión de Codex (10.91) · Entrega a las escuchas abiertas una
  /// instantánea que el cierre tiene que descartar: la vista con la escritura
  /// propia todavía pendiente o, con [fromCache], el documento del servidor
  /// leído de la caché.
  void emitRejected({bool fromCache = false}) {
    final pending = _pendingView;
    _emit(fromCache || pending == null
        ? _snapshot(_serverData,
            hasPendingWrites: !fromCache, isFromCache: fromCache)
        : _snapshot(pending, hasPendingWrites: true));
  }

  DocumentSnapshotPlatform _serverSnapshot() =>
      _snapshot(_serverData, hasPendingWrites: false);

  @override
  Future<DocumentSnapshotPlatform> get(
      [GetOptions options = const GetOptions()]) async {
    final last = _lastEmitted;
    if (_listeners.isNotEmpty && last != null) {
      _cloud.readsFromListenedView++;
      return last;
    }
    return _serverSnapshot();
  }

  @override
  Future<void> update(Map<FieldPath, dynamic> data) async {
    final before = _serverData;
    if (before == null) {
      throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'not-found',
          message: 'No hay documento que actualizar: $path');
    }
    // 1. La escritura local: la vista con la hora pendiente, que las escuchas
    //    reciben con `hasPendingWrites` (`syncEngineWrite`).
    final pending = <String, Object?>{
      ...before,
      for (final entry in data.entries)
        entry.key.components.join('.'):
            entry.value is FieldValuePlatform ? null : entry.value,
    };
    _pendingView = pending;
    _emit(_snapshot(pending, hasPendingWrites: true));
    // 2. El servidor la aplica, con su hora en vez de la pendiente.
    _cloud.server[path] = <String, Object?>{
      ...before,
      for (final entry in data.entries)
        entry.key.components.join('.'): entry.value is FieldValuePlatform
            ? Timestamp.fromDate(_cloud._clock())
            : entry.value,
    };
    // 3. El acuse termina el `update` sin que la vista cambie
    //    (`shouldWaitForSyncedDocument`); el eco del servidor llega en una
    //    vuelta posterior del bucle de eventos, salvo que se retenga.
    if (!_cloud.holdEcho) {
      unawaited(Future<void>.delayed(Duration.zero, _echo));
    }
  }

  void _echo() {
    _pendingView = null;
    _emit(_serverSnapshot());
  }

  void _emit(DocumentSnapshotPlatform snapshot) {
    if (_listeners.isEmpty) return;
    _lastEmitted = snapshot;
    for (final listener in List.of(_listeners)) {
      listener.add(snapshot);
    }
  }

  @override
  Stream<DocumentSnapshotPlatform> snapshots({
    bool includeMetadataChanges = false,
    required ListenSource listenSource,
  }) {
    late final StreamController<DocumentSnapshotPlatform> controller;
    controller = StreamController<DocumentSnapshotPlatform>(
      onListen: () {
        _listeners.add(controller);
        // Al suscribirse, la vista actual: la que ya reciben las demás
        // escuchas o, si es la primera, el documento del servidor con la
        // escritura propia pendiente encima.
        final pending = _pendingView;
        final current = _lastEmitted ??
            (pending == null
                ? _serverSnapshot()
                : _snapshot(pending, hasPendingWrites: true));
        _lastEmitted = current;
        controller.add(current);
      },
      onCancel: () {
        _listeners.remove(controller);
        if (_listeners.isEmpty) _lastEmitted = null;
        return controller.close();
      },
    );
    return controller.stream;
  }
}
