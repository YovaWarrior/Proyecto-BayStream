import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/movement.dart';
import '../../domain/entities/operation.dart';
import '../../domain/entities/vessel_profile.dart';
import '../../domain/repositories/movement_log_repository.dart';
import '../../domain/repositories/operation_sync_repository.dart';
import '../../domain/repositories/session_repository.dart';
import 'sync_engine.dart';

/// T-79 · Sincronización con Firestore en Android, Web y Windows (10.8).
///
/// Colecciones de T-79a 5.1:
///
///     operations/{operationId}                  la publica la oficina
///     operations/{operationId}/sources/{id}     texto de las fuentes, en trozos
///     operations/{operationId}/movements/{id}   la bitácora
///     authorized/{uid}                          la escribe Carlos en la consola
///
/// Las reglas que la protegen son `docs/T79a-firestore.rules.propuesta`.
class FirestoreOperationSync implements OperationSyncRepository {
  final FirebaseFirestore _db;
  final MovementLogRepository _log;
  final SessionRepository _session;
  final DateTime Function() _clock;
  final _engines = <String, SyncEngine>{};

  FirestoreOperationSync(this._db, this._log, this._session,
      {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  /// Trozo de una fuente: 300 000 caracteres son a lo sumo 900 000 bytes en
  /// UTF-8, dentro del MiB por documento y de las 900 000 de las reglas.
  static const sourcePartLength = 300000;
  static const _networkTimeout = Duration(seconds: 45);

  CollectionReference<Map<String, dynamic>> get _operations =>
      _db.collection('operations');

  @override
  SyncCapability get capability => SyncCapability.realtime;

  Either<Failure, Operator> _office() {
    final operator = _session.current;
    if (operator == null) {
      return const Left(FirestoreFailure(
          code: 'no_session',
          message: 'Inicia sesión con una cuenta de oficina.'));
    }
    if (!operator.authorized || operator.role != OperatorRole.office) {
      return const Left(FirestoreFailure(
          code: 'not_office',
          message: 'Solo una cuenta de oficina autorizada publica y cierra operaciones.'));
    }
    return Right(operator);
  }

  /// Lee del servidor, no de la caché: sin red falla en vez de esperar, así
  /// publicar y cerrar dicen enseguida que necesitan conexión.
  Future<DocumentSnapshot<Map<String, dynamic>>> _serverGet(
          DocumentReference<Map<String, dynamic>> ref) =>
      ref.get(const GetOptions(source: Source.server)).timeout(_networkTimeout);

  @override
  Future<Either<Failure, Operation>> publish(
      Operation operation, VesselProfile profile) async {
    final office = _office();
    if (office.isLeft()) return office.map((_) => operation);
    final uid = office.getOrElse(() => throw StateError('sin oficina')).uid;
    final ref = _operations.doc(operation.id);
    try {
      final existing = await _serverGet(ref);
      if (!existing.exists) {
        final batch = _db.batch();
        final manifest = <String, Object?>{};
        for (final source in operation.sources) {
          final parts = splitSource(source.content);
          final hash = sourceHash(source.content);
          manifest[source.kind.wire] = {
            'fileName': source.fileName,
            'sha256': hash,
            'parts': parts.length,
            'length': source.content.length,
          };
          for (var i = 0; i < parts.length; i++) {
            final id = '${source.kind.wire}-$i';
            batch.set(ref.collection('sources').doc(id), {
              'id': id,
              'kind': source.kind.wire,
              'sha256': hash,
              'part': i,
              'parts': parts.length,
              'content': parts[i],
              'createdBy': uid,
              'createdAt': FieldValue.serverTimestamp(),
            });
          }
        }
        batch.set(ref, {
          'id': operation.id,
          'schema': 1,
          'vessel': operation.vesselName,
          'voyage': operation.voyageNumber,
          'portOfCall': operation.portOfCall,
          'status': 'open',
          'createdBy': uid,
          'createdAt': FieldValue.serverTimestamp(),
          'profile': profile.toJson(),
          'sources': manifest,
        });
        await batch.commit().timeout(_networkTimeout);
      }
      // Si ya estaba (un intento anterior llegó tarde), basta marcarla.
      final published = operation.copyWith(published: true, profile: profile);
      return (await _log.saveOperation(published)).map((_) => published);
    } on FirebaseException catch (error) {
      return Left(FirestoreFailure(code: error.code, message: _publishMessage(error)));
    } on TimeoutException {
      return const Left(FirestoreFailure(
          code: 'timeout',
          message: 'Sin respuesta de la nube. Publicar requiere conexión: '
              'revisa la red e inténtalo de nuevo.'));
    }
  }

  static String _publishMessage(FirebaseException error) => switch (error.code) {
        'permission-denied' =>
          'La nube no aceptó la publicación: revisa que la cuenta sea de oficina '
              'y esté activa.',
        'unavailable' => 'Sin conexión con la nube. Publicar requiere red.',
        _ => 'La nube devolvió un error (${error.code}).',
      };

  @override
  Stream<List<PublishedOperation>> watchOpenOperations() => _operations
      .where('status', isEqualTo: 'open')
      .snapshots()
      .map((snapshot) => [
            for (final doc in snapshot.docs)
              if (_summary(doc.data()) case final summary?) summary
          ]..sort((a, b) => (b.createdAt ?? DateTime(0))
              .compareTo(a.createdAt ?? DateTime(0))))
      .handleError((Object error) => throw _remoteError(error));

  static PublishedOperation? _summary(Map<String, dynamic> data) {
    try {
      final manifest = Map<String, dynamic>.from(data['sources'] as Map? ?? const {});
      return PublishedOperation(
        id: data['id'] as String,
        vesselName: data['vessel'] as String,
        voyageNumber: data['voyage'] as String,
        portOfCall: data['portOfCall'] as String,
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
        sources: [
          for (final kind in OperationSourceKind.values)
            if (manifest.containsKey(kind.wire)) kind
        ],
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Either<Failure, Operation>> join(String operationId) async {
    try {
      final ref = _operations.doc(operationId);
      final snapshot = await _serverGet(ref);
      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        return const Left(FirestoreFailure(
            code: 'not_found', message: 'La operación ya no está en la nube.'));
      }
      final parts = await ref
          .collection('sources')
          .get(const GetOptions(source: Source.server))
          .timeout(_networkTimeout);
      final manifest = Map<String, dynamic>.from(data['sources'] as Map? ?? const {});
      final sources = <OperationSource>[];
      for (final kind in OperationSourceKind.values) {
        final entry = manifest[kind.wire];
        if (entry is! Map) continue;
        final expected = (entry['parts'] as num).toInt();
        final pieces = [
          for (final doc in parts.docs)
            if (doc.data()['kind'] == kind.wire) doc.data()
        ]..sort((a, b) => (a['part'] as num).compareTo(b['part'] as num));
        final content = pieces.map((p) => p['content'] as String).join();
        // La huella se calcula sobre el texto tal como se publicó (10.11):
        // no se vuelve a serializar nada antes de comprobarla.
        if (pieces.length != expected ||
            sourceHash(content) != entry['sha256'] ||
            pieces.any((p) => p['sha256'] != entry['sha256'])) {
          return Left(FirestoreFailure(
              code: 'source_mismatch',
              message: 'La fuente ${kind.wire} llegó incompleta o distinta de la '
                  'publicada. No se guardó nada: vuelve a intentarlo.'));
        }
        sources.add(OperationSource(
            kind: kind, fileName: entry['fileName'] as String? ?? kind.wire, content: content));
      }
      final operation = Operation(
        id: data['id'] as String,
        vesselName: data['vessel'] as String,
        voyageNumber: data['voyage'] as String,
        portOfCall: data['portOfCall'] as String,
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? _clock(),
        sources: sources,
        published: true,
        closedAt: (data['closedAt'] as Timestamp?)?.toDate(),
        profile: data['profile'] is Map
            ? VesselProfile.fromJson(
                jsonDecode(jsonEncode(data['profile'])) as Map<String, dynamic>)
            : null,
      );
      return (await _log.saveOperation(operation)).map((_) => operation);
    } on FirebaseException catch (error) {
      return Left(FirestoreFailure(
          code: error.code,
          message: error.code == 'permission-denied'
              ? 'Tu cuenta no puede leer esta operación: revisa que esté autorizada.'
              : 'Sin conexión con la nube. Unirse requiere red.'));
    } on TimeoutException {
      return const Left(FirestoreFailure(
          code: 'timeout', message: 'Sin respuesta de la nube. Unirse requiere red.'));
    }
  }

  @override
  Future<Either<Failure, Operation>> close(String operationId) async {
    final office = _office();
    if (office.isLeft()) {
      return office.map((_) => throw StateError('sin oficina'));
    }
    final uid = office.getOrElse(() => throw StateError('sin oficina')).uid;
    final ref = _operations.doc(operationId);
    try {
      var snapshot = await _serverGet(ref);
      if (snapshot.data()?['status'] == 'open') {
        await ref.update({
          'status': 'closed',
          'closedBy': uid,
          'closedAt': FieldValue.serverTimestamp(),
        }).timeout(_networkTimeout);
        snapshot = await _serverGet(ref);
      }
      final closedAt = (snapshot.data()?['closedAt'] as Timestamp?)?.toDate();
      final local = (await _log.getOperation(operationId)).getOrElse(() => null);
      if (local == null || closedAt == null) {
        return const Left(FirestoreFailure(
            code: 'not_found', message: 'No se encontró la operación para cerrarla.'));
      }
      final closed = local.copyWith(closedAt: closedAt);
      return (await _log.saveOperation(closed)).map((_) => closed);
    } on FirebaseException catch (error) {
      return Left(FirestoreFailure(code: error.code, message: _publishMessage(error)));
    } on TimeoutException {
      return const Left(FirestoreFailure(
          code: 'timeout', message: 'Sin respuesta de la nube. Cerrar requiere red.'));
    }
  }

  @override
  Stream<SyncStatus> follow(Operation operation) {
    if (!operation.published) return Stream.value(SyncStatus.local);
    SyncEngine? engine;
    StreamSubscription<SyncStatus>? statuses;
    StreamSubscription<Operator?>? operators;
    late final StreamController<SyncStatus> controller;
    controller = StreamController<SyncStatus>(
      onListen: () async {
        final started = SyncEngine(
            log: _log,
            remote: FirestoreRemoteMovementStore(_db),
            operation: operation,
            clock: _clock);
        engine = started;
        _engines[operation.id] = started;
        statuses = started.status.listen(controller.add);
        await started.start(_session.current);
        controller.add(started.current);
        operators = _session.watchOperator().listen(started.setOperator);
      },
      onCancel: () async {
        await operators?.cancel();
        await statuses?.cancel();
        if (_engines[operation.id] == engine) _engines.remove(operation.id);
        await engine?.stop();
        await controller.close();
      },
    );
    return controller.stream;
  }

  @override
  Future<void> retry(String operationId) async {
    await _log.requeueRejected(operationId);
    await _session.verify();
    await _engines[operationId]?.retry();
  }

  @override
  Future<void> dispose() async {
    for (final engine in _engines.values.toList()) {
      await engine.stop();
    }
    _engines.clear();
  }

  /// Huella SHA-256 del texto en UTF-8, tal cual (10.11).
  static String sourceHash(String content) =>
      sha256.convert(utf8.encode(content)).toString();

  /// Parte el texto sin cortar un par sustituto de UTF-16.
  static List<String> splitSource(String content, [int length = sourcePartLength]) {
    if (content.isEmpty) return [''];
    final parts = <String>[];
    var start = 0;
    while (start < content.length) {
      var end = start + length;
      if (end >= content.length) {
        end = content.length;
      } else if (_isHighSurrogate(content.codeUnitAt(end - 1))) {
        end--;
      }
      parts.add(content.substring(start, end));
      start = end;
    }
    return parts;
  }

  static bool _isHighSurrogate(int unit) => unit >= 0xD800 && unit <= 0xDBFF;
}

/// El puerto del motor sobre `operations/{op}/movements` (T-79a 3.4).
class FirestoreRemoteMovementStore implements RemoteMovementStore {
  final FirebaseFirestore _db;
  FirestoreRemoteMovementStore(this._db);

  CollectionReference<Map<String, dynamic>> _movements(String operationId) =>
      _db.collection('operations').doc(operationId).collection('movements');

  @override
  Future<void> put(Movement movement) async {
    try {
      await _movements(movement.operationId)
          .doc(movement.id)
          .set(FirestoreMovementCodec.encode(movement));
    } catch (error) {
      throw _remoteError(error);
    }
  }

  /// Toda la subcolección, sin consulta ni índice (T-79a 4.3). Solo entran
  /// los cambios que el servidor ya tiene: con `includeMetadataChanges`, la
  /// confirmación de una escritura propia llega como un cambio de metadatos.
  @override
  Stream<RemoteSnapshot> watch(String operationId) => _movements(operationId)
      .snapshots(includeMetadataChanges: true)
      .map((snapshot) => RemoteSnapshot([
            for (final change in snapshot.docChanges)
              if (change.type != DocumentChangeType.removed &&
                  !change.doc.metadata.hasPendingWrites)
                if (FirestoreMovementCodec.tryDecode(change.doc.data()) case final m?) m
          ], fromServer: !snapshot.metadata.isFromCache))
      .handleError((Object error) => throw _remoteError(error));

  /// También del servidor: decide si un permiso denegado pausa o rechaza.
  @override
  Future<RemoteAuthorization> authorizationOf(String uid) async {
    try {
      final doc = await _db
          .collection('authorized')
          .doc(uid)
          .get(const GetOptions(source: Source.server));
      if (!doc.exists) return RemoteAuthorization.absent;
      return doc.data()?['active'] == true
          ? RemoteAuthorization.active
          : RemoteAuthorization.inactive;
    } catch (_) {
      return RemoteAuthorization.unknown;
    }
  }

  /// Del servidor, no de la caché: justo al reconectar, la caché todavía
  /// puede tener la operación abierta (C7). Sin red, falla y el motor deja
  /// el movimiento pendiente para decidir después.
  @override
  Future<DateTime?> closedAt(String operationId) async {
    final doc = await _db
        .collection('operations')
        .doc(operationId)
        .get(const GetOptions(source: Source.server));
    return (doc.data()?['closedAt'] as Timestamp?)?.toDate();
  }
}

/// El sobre de T-79a 2.3 como documento: horas como `Timestamp` y
/// `receivedAt` con la hora del servidor, que las reglas exigen.
class FirestoreMovementCodec {
  const FirestoreMovementCodec._();

  static Map<String, Object?> encode(Movement movement) => {
        'id': movement.id,
        'schema': Movement.schema,
        'operationId': movement.operationId,
        'type': movement.type.wire,
        'target': movement.target,
        'payload': {
          for (final entry in movement.payload.entries)
            entry.key: entry.key == 'operatedAt' && entry.value is String
                ? Timestamp.fromDate(DateTime.parse(entry.value! as String))
                : entry.value,
        },
        'author': {
          'uid': movement.author.uid,
          'name': movement.author.name,
          'role': movement.author.role.name,
        },
        'deviceId': movement.deviceId,
        'sequence': movement.sequence,
        'createdAt': Timestamp.fromDate(movement.createdAt),
        'receivedAt': FieldValue.serverTimestamp(),
      };

  /// Un documento que no se entiende no detiene la escucha: se omite.
  static Movement? tryDecode(Map<String, dynamic>? data) {
    if (data == null) return null;
    try {
      return decode(data);
    } catch (_) {
      return null;
    }
  }

  static Movement decode(Map<String, dynamic> data) {
    final type = MovementType.fromWire(data['type'] as String?);
    if (type == null) throw FormatException('Tipo desconocido: ${data['type']}');
    final payload = <String, Object?>{};
    for (final entry in Map<String, dynamic>.from(data['payload'] as Map).entries) {
      final value = entry.value;
      payload[entry.key] = switch (entry.key) {
        'operatedAt' when value is Timestamp => value.toDate().toUtc().toIso8601String(),
        'order' when value is num => value.toInt(),
        _ => value,
      };
    }
    final author = Map<String, dynamic>.from(data['author'] as Map);
    return Movement(
      id: data['id'] as String,
      operationId: data['operationId'] as String,
      type: type,
      target: data['target'] as String?,
      payload: payload,
      author: MovementAuthor(
        uid: author['uid'] as String?,
        name: author['name'] as String,
        role: OperatorRole.values.firstWhere((r) => r.name == author['role'],
            orElse: () => OperatorRole.dock),
      ),
      deviceId: data['deviceId'] as String,
      sequence: (data['sequence'] as num).toInt(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      receivedAt: (data['receivedAt'] as Timestamp?)?.toDate(),
    );
  }
}

/// T-79a 4.5: el código de Firestore decide qué hace el motor.
RemoteStoreException _remoteError(Object error) {
  if (error is RemoteStoreException) return error;
  final code = error is FirebaseException ? error.code : 'unknown';
  final kind = switch (code) {
    'unauthenticated' => RemoteErrorKind.unauthenticated,
    'permission-denied' => RemoteErrorKind.permissionDenied,
    'invalid-argument' ||
    'failed-precondition' ||
    'out-of-range' ||
    'already-exists' ||
    'data-loss' ||
    'unimplemented' =>
      RemoteErrorKind.invalid,
    _ => RemoteErrorKind.unavailable,
  };
  return RemoteStoreException(
      kind, code, error is FirebaseException ? error.message : '$error');
}
