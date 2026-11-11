import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/fecha_corta.dart';
import '../../domain/entities/movement.dart';
import '../../domain/entities/operation.dart';
import '../../domain/entities/vessel_profile.dart';
import '../../domain/repositories/movement_log_repository.dart';
import '../../domain/repositories/operation_sync_repository.dart';
import '../../domain/repositories/session_repository.dart';
import 'source_revisions.dart' as transport;
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
/// Las reglas que la protegen son `docs/T80-firestore.rules.propuesta` y,
/// desde T-127, `docs/T127-firestore.rules.propuesta`: el listado de la
/// agencia se agrega o se reemplaza con revisión (`source_revisions.dart`).
class FirestoreOperationSync implements OperationSyncRepository {
  final FirebaseFirestore _db;
  final MovementLogRepository _log;
  final SessionRepository _session;
  final DateTime Function() _clock;
  final _engines = <String, SyncEngine>{};

  /// T-130 · Las fuentes que esta oficina está subiendo, para que su propio
  /// motor no las baje ni las avise cuando el eco llegue antes que el
  /// guardado local (10.90, ajuste 3).
  final _ownWrites = OwnSourceWrites();

  FirestoreOperationSync(this._db, this._log, this._session,
      {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  /// Trozo de una fuente: 300 000 caracteres son a lo sumo 900 000 bytes en
  /// UTF-8, dentro del MiB por documento y de las 900 000 de las reglas.
  static const sourcePartLength = transport.sourcePartLength;
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
          message:
              'Publicar y cerrar exige sesión: inicia sesión con una cuenta de oficina.'));
    }
    if (!operator.authorized || operator.role != OperatorRole.office) {
      return const Left(FirestoreFailure(
          code: 'not_office',
          message: 'Solo una cuenta de oficina autorizada publica y cierra '
              'operaciones: inicia sesión con una o pide al responsable que '
              'autorice la tuya.'));
    }
    return Right(operator);
  }

  /// Lee del servidor, no de la caché: sin red falla en vez de esperar, así
  /// publicar y cerrar dicen enseguida que necesitan conexión.
  Future<DocumentSnapshot<Map<String, dynamic>>> _serverGet(
          DocumentReference<Map<String, dynamic>> ref) =>
      ref.get(const GetOptions(source: Source.server)).timeout(_networkTimeout);

  /// T-129 (O-128-2) · El documento como quedó en el servidor después de una
  /// escritura propia con `FieldValue.serverTimestamp()`. Leerlo «del
  /// servidor» no basta: si el documento ya se escucha (el motor lo sigue
  /// desde T-127), el SDK resuelve esa lectura con la última vista de la
  /// escucha, que todavía lleva la hora pendiente y la lee como nula, hasta
  /// que llega el eco del servidor. Aquí se espera ese eco: la primera
  /// instantánea del servidor sin escrituras pendientes. Si no llega en
  /// [_networkTimeout], falla como las demás lecturas. El filtro va antes del
  /// plazo: `Stream.timeout` lo reinicia con cada evento, y las instantáneas
  /// descartadas no deben darle más tiempo (revisión de Codex, 10.91).
  Future<DocumentSnapshot<Map<String, dynamic>>> _afterOwnWrite(
          DocumentReference<Map<String, dynamic>> ref) =>
      ref
          .snapshots(includeMetadataChanges: true)
          .where((snapshot) =>
              !snapshot.metadata.hasPendingWrites &&
              !snapshot.metadata.isFromCache)
          .timeout(_networkTimeout)
          .first;

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
        // T-130 (10.90, ajuste 1): no se publica una segunda operación
        // abierta del mismo buque, viaje y puerto. Las reglas no pueden
        // exigirlo; aquí se lee la misma lista de «Operaciones abiertas en
        // la nube» y, si ya hay una, se ofrece unirse a ella.
        final duplicate = await _openDuplicateOf(operation);
        if (duplicate != null) {
          final when = duplicate.createdAt;
          return Left(FirestoreFailure(
              code: 'duplicate',
              message: 'Ya hay una operación publicada y abierta de '
                  '${duplicate.vesselName} · ${duplicate.voyageNumber} · '
                  '${duplicate.portOfCall}'
                  '${when == null ? '' : ', publicada el ${fechaCorta(when)}'}. '
                  'No se publica otra: únete a ella desde «Operaciones abiertas '
                  'en la nube».'));
        }
        final batch = _db.batch();
        final manifest = <String, Object?>{};
        for (final source in operation.sources) {
          // Sin revisión: los trozos `{tipo}-{i}` de siempre, que también lee
          // un cliente 0.4.0 (T-127 solo revisa después de publicar).
          final packed = transport.packSource(source);
          manifest[source.kind.wire] = packed.entry.toMap();
          for (final part in packed.parts) {
            batch.set(ref.collection('sources').doc(part.id), {
              ...part.toMap(),
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
          'profile': FirestoreProfileCodec.encode(profile),
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

  /// T-130 · La operación abierta de la nube con el mismo buque, viaje y
  /// puerto que [operation], si la hay, leída del servidor.
  Future<PublishedOperation?> _openDuplicateOf(Operation operation) async {
    final open = await _operations
        .where('status', isEqualTo: 'open')
        .get(const GetOptions(source: Source.server))
        .timeout(_networkTimeout);
    for (final doc in open.docs) {
      final summary = _summary(doc.data());
      if (summary != null &&
          summary.id != operation.id &&
          summary.vesselName == operation.vesselName &&
          summary.voyageNumber == operation.voyageNumber &&
          summary.portOfCall == operation.portOfCall) {
        return summary;
      }
    }
    return null;
  }

  static String _publishMessage(FirebaseException error) => switch (error.code) {
        'permission-denied' =>
          'La nube no aceptó la publicación: revisa que la cuenta sea de oficina '
              'y esté activa.',
        'unavailable' => 'Sin conexión con la nube: publicar o cerrar requiere '
            'red. Conéctate e inténtalo de nuevo.',
        _ => _unknownCloudError(error),
      };

  /// T-112: el código de Firebase va al registro, no a la pantalla.
  static String _unknownCloudError(FirebaseException error) {
    debugPrint('La nube devolvió ${error.code}: ${error.message}');
    return 'La nube devolvió un error que BayStream no reconoce; el código '
        'técnico quedó en el registro. Inténtalo de nuevo y, si se repite, '
        'avisa al responsable.';
  }

  /// T-112: la fuente con su nombre en español, no con su identificador.
  static String _sourceName(OperationSourceKind kind) => switch (kind) {
        OperationSourceKind.arrivalBaplie => 'plano de llegada',
        OperationSourceKind.loadingBaplie => 'plan de carga',
        OperationSourceKind.exportList => 'listado de la agencia',
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
            code: 'not_found',
            message: 'La operación ya no está en la nube: se retiró después de '
                'publicarse. Pide a la oficina que la publique de nuevo.'));
      }
      final snapshotParts = await ref
          .collection('sources')
          .get(const GetOptions(source: Source.server))
          .timeout(_networkTimeout);
      final parts = [
        for (final doc in snapshotParts.docs)
          if (transport.SourcePart.read(doc.data()) case final part?) part
      ];
      final manifest = Map<String, dynamic>.from(data['sources'] as Map? ?? const {});
      final sources = <OperationSource>[];
      for (final kind in OperationSourceKind.values) {
        final entry = transport.SourceManifestEntry.read(kind, manifest[kind.wire]);
        if (entry == null) continue;
        // T-127: con `revision` en el manifiesto, solo los trozos de esa
        // revisión; sin ella, los publicados con la operación, como siempre.
        // La huella se calcula sobre el texto tal como se publicó (10.11):
        // no se vuelve a serializar nada antes de comprobarla.
        final source = transport.assembleSource(entry, parts);
        if (source == null) {
          return Left(FirestoreFailure(
              code: 'source_mismatch',
              message: 'La fuente «${_sourceName(kind)}» llegó incompleta o '
                  'distinta de la publicada. No se guardó nada: vuelve a intentarlo.'));
        }
        sources.add(source);
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
            ? FirestoreProfileCodec.decode(data['profile'] as Map)
            : null,
      );
      return (await _log.saveOperation(operation)).map((_) => operation);
    } on FirebaseException catch (error) {
      return Left(FirestoreFailure(
          code: error.code,
          message: error.code == 'permission-denied'
              ? 'Tu cuenta no puede leer esta operación: revisa que esté autorizada.'
              : 'Sin conexión con la nube: unirse requiere red. Conéctate e '
                  'inténtalo de nuevo.'));
    } on TimeoutException {
      return const Left(FirestoreFailure(
          code: 'timeout',
          message: 'Sin respuesta de la nube: unirse requiere red. Revisa la red e '
              'inténtalo de nuevo.'));
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
        snapshot = await _afterOwnWrite(ref);
      }
      final closedAt = (snapshot.data()?['closedAt'] as Timestamp?)?.toDate();
      final local = (await _log.getOperation(operationId)).getOrElse(() => null);
      if (local == null || closedAt == null) {
        return const Left(FirestoreFailure(
            code: 'not_found',
            message: 'No se encontró la operación para cerrarla en este dispositivo '
                'o en la nube. Vuelve a abrir «Nube y cuenta» e inténtalo de nuevo.'));
      }
      final closed = local.copyWith(closedAt: closedAt);
      return (await _log.saveOperation(closed)).map((_) => closed);
    } on FirebaseException catch (error) {
      return Left(FirestoreFailure(code: error.code, message: _publishMessage(error)));
    } on TimeoutException {
      return const Left(FirestoreFailure(
          code: 'timeout',
          message: 'Sin respuesta de la nube: cerrar requiere red. Revisa la red e '
              'inténtalo de nuevo.'));
    }
  }

  /// T-127 (10.78) · El listado con la revisión siguiente a la que el
  /// servidor tiene, en un solo lote: los trozos `export_list-r{n}-{i}` y la
  /// entrada `sources.export_list` del manifiesto. Las reglas exigen que la
  /// operación siga abierta, que la revisión suba y que los trozos lleven la
  /// revisión del manifiesto; si otra oficina revisó mientras tanto, el lote
  /// se rechaza y se vuelve a intentar desde la pantalla.
  @override
  Future<Either<Failure, Operation>> replaceSource(
      Operation operation, OperationSource source) async {
    if (source.kind != OperationSourceKind.exportList) {
      return const Left(ValidationFailure(
          field: 'source',
          message: 'En una operación publicada solo cambia el listado de la '
              'agencia: los BAPLIE son el contrato de la operación. Para otro '
              'plan, publica una operación nueva.'));
    }
    final office = _office();
    if (office.isLeft()) return office.map((_) => operation);
    final uid = office.getOrElse(() => throw StateError('sin oficina')).uid;
    final ref = _operations.doc(operation.id);
    try {
      final snapshot = await _serverGet(ref);
      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        return const Left(FirestoreFailure(
            code: 'not_found',
            message: 'La operación ya no está en la nube: se retiró después de '
                'publicarse. Publícala de nuevo antes de importar el listado.'));
      }
      if (data['status'] != 'open') {
        return const Left(FirestoreFailure(
            code: 'closed',
            message: 'La operación ya está cerrada en la nube y su listado no '
                'cambia. Para trabajar con otro listado, abre el plan de carga '
                'como una operación nueva.'));
      }
      final manifest = Map<String, dynamic>.from(data['sources'] as Map? ?? const {});
      final previous = transport.SourceManifestEntry.read(
          OperationSourceKind.exportList, manifest[source.kind.wire]);
      final revision = (previous?.revision ?? 0) + 1;
      final packed = transport.packSource(source, revision: revision);
      final updated = operation.copyWith(sources: [
        ...operation.sources.where((s) => s.kind != source.kind),
        source.withRevision(revision),
      ]);
      return await _writeSource(ref, uid, operation.id, packed, updated);
    } on FirebaseException catch (error) {
      return Left(FirestoreFailure(
          code: error.code,
          message: switch (error.code) {
            'permission-denied' =>
              'La nube no aceptó el listado: la operación está cerrada, la '
                  'cuenta no es de oficina o alguien acaba de cambiar el listado. '
                  'Vuelve a abrir «Listado de la agencia» e inténtalo de nuevo.',
            'unavailable' => 'Sin conexión con la nube: reemplazar el listado de '
                'una operación publicada requiere red. Conéctate e inténtalo de '
                'nuevo.',
            _ => _unknownCloudError(error),
          }));
    } on TimeoutException {
      return const Left(FirestoreFailure(
          code: 'timeout',
          message: 'Sin respuesta de la nube: reemplazar el listado requiere '
              'conexión. Revisa la red e inténtalo de nuevo.'));
    }
  }

  /// T-130 (10.90) · El BAPLIE que falta, en un solo lote: los trozos
  /// `{tipo}-{i}` sin revisión (el mismo formato que `publish`, para que un
  /// cliente 0.4.0 o 0.4.1 se pueda unir después) y la entrada
  /// `sources.{tipo}` del manifiesto, con `voyage` si el archivo declara otro
  /// viaje. Las reglas exigen que la operación siga abierta y que el tipo no
  /// estuviera; si ya está, no se reemplaza.
  @override
  Future<Either<Failure, Operation>> addSource(
      Operation operation, OperationSource source) async {
    if (source.kind == OperationSourceKind.exportList) {
      return const Left(ValidationFailure(
          field: 'source',
          message: 'El listado de la agencia se agrega o se reemplaza con '
              'revisión, no como un plan: vuelve a importarlo desde «Listado de '
              'la agencia».'));
    }
    final office = _office();
    if (office.isLeft()) return office.map((_) => operation);
    final uid = office.getOrElse(() => throw StateError('sin oficina')).uid;
    final ref = _operations.doc(operation.id);
    try {
      final snapshot = await _serverGet(ref);
      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        return const Left(FirestoreFailure(
            code: 'not_found',
            message: 'La operación ya no está en la nube: se retiró después de '
                'publicarse. Publícala de nuevo antes de agregar el plan.'));
      }
      if (data['status'] != 'open') {
        return const Left(FirestoreFailure(
            code: 'closed',
            message: 'La operación ya está cerrada en la nube y sus BAPLIE no '
                'cambian. Para trabajar con este archivo, ábrelo como una '
                'operación nueva.'));
      }
      final manifest = transport.SourceManifest.read(data['sources']);
      final current = manifest[source.kind];
      if (current != null) {
        return Left(FirestoreFailure(
            code: 'already_has',
            message: 'La operación publicada ya tiene el '
                '${_sourceName(source.kind)} («${current.fileName}») y los '
                'BAPLIE de una operación publicada no cambian. Si este archivo '
                'lo corrige, cierra la operación y publica una nueva con los '
                'planos correctos.'));
      }
      final packed = transport.packSource(source);
      final updated = operation.copyWith(sources: [
        ...operation.sources.where((s) => s.kind != source.kind),
        source,
      ]);
      return await _writeSource(ref, uid, operation.id, packed, updated);
    } on FirebaseException catch (error) {
      return Left(FirestoreFailure(
          code: error.code,
          message: switch (error.code) {
            'permission-denied' =>
              'La nube no aceptó el plan: la operación está cerrada, ya tiene '
                  'ese plan, la cuenta no es de oficina o las reglas publicadas '
                  'todavía no lo admiten. Vuelve a abrir el plano e inténtalo de '
                  'nuevo.',
            'unavailable' => 'Sin conexión con la nube: agregar un plan a una '
                'operación publicada requiere red. Conéctate e inténtalo de '
                'nuevo.',
            _ => _unknownCloudError(error),
          }));
    } on TimeoutException {
      return const Left(FirestoreFailure(
          code: 'timeout',
          message: 'Sin respuesta de la nube: agregar un plan requiere '
              'conexión. Revisa la red e inténtalo de nuevo.'));
    }
  }

  /// T-127 y T-130 · Los trozos y la entrada del manifiesto en un solo lote;
  /// si pasa, la operación local actualizada. Mientras el lote vuela y hasta
  /// que lo local está guardado, la fuente queda anotada como escritura
  /// propia, para que el motor de esta misma oficina no la baje ni la avise
  /// si el eco del servidor llega antes (10.90, ajuste 3).
  Future<Either<Failure, Operation>> _writeSource(
      DocumentReference<Map<String, dynamic>> ref,
      String uid,
      String operationId,
      ({transport.SourceManifestEntry entry, List<transport.SourcePart> parts}) packed,
      Operation updated) async {
    final kind = packed.entry.kind;
    _ownWrites.begin(operationId, kind, packed.entry.sha256);
    try {
      final batch = _db.batch();
      for (final part in packed.parts) {
        batch.set(ref.collection('sources').doc(part.id), {
          ...part.toMap(),
          'createdBy': uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      batch.update(ref, {
        FieldPath(['sources', kind.wire]): packed.entry.toMap(),
      });
      await batch.commit().timeout(_networkTimeout);
      return (await _log.saveOperation(updated)).map((_) => updated);
    } finally {
      _ownWrites.end(operationId, kind, packed.entry.sha256);
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
            clock: _clock,
            ownWrites: _ownWrites);
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

  /// Huella SHA-256 del texto en UTF-8, tal cual (10.11). Vive en
  /// `source_revisions.dart` desde T-127; aquí queda su nombre de siempre.
  static String sourceHash(String content) => transport.sourceHash(content);

  /// Parte el texto sin cortar un par sustituto de UTF-16.
  static List<String> splitSource(String content, [int length = sourcePartLength]) =>
      transport.splitSource(content, length);
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

  /// T-127 · El documento de la operación, por su manifiesto. Una escritura
  /// propia pendiente (la oficina que acaba de revisar o agregar) no cuenta
  /// hasta que el servidor la confirma; de la caché, sin red, llega lo último
  /// visto. T-130: los tres tipos, no solo el listado. T-143 (O-139-1): y la
  /// hora del cierre, del mismo documento y en la misma escucha; el cierre
  /// propio, mientras está pendiente, tampoco cuenta (lo guarda `close`).
  @override
  Stream<RemoteOperationDocument> watchOperation(String operationId) => _db
      .collection('operations')
      .doc(operationId)
      .snapshots(includeMetadataChanges: true)
      .where((snapshot) => !snapshot.metadata.hasPendingWrites)
      .map((snapshot) => RemoteOperationDocument(
          transport.SourceManifest.read(snapshot.data()?['sources']),
          closedAt: (snapshot.data()?['closedAt'] as Timestamp?)?.toDate()))
      .handleError((Object error) => throw _remoteError(error));

  /// T-130 · Los trozos `{tipo}-{i}` de un BAPLIE, del servidor: un índice de
  /// un solo campo (`kind`), que Firestore crea solo. Sin red falla, y el
  /// motor espera. Los de una revisión del listado no entran aquí; los de
  /// otro tipo, tampoco.
  @override
  Future<List<transport.SourcePart>> planParts(
      String operationId, OperationSourceKind kind) async {
    try {
      final query = await _db
          .collection('operations')
          .doc(operationId)
          .collection('sources')
          .where('kind', isEqualTo: kind.wire)
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 45));
      return [
        for (final doc in query.docs)
          if (transport.SourcePart.read(doc.data()) case final part?) part
      ];
    } on TimeoutException {
      throw const RemoteStoreException(RemoteErrorKind.unavailable, 'timeout');
    } catch (error) {
      throw _remoteError(error);
    }
  }

  /// T-127 · Solo los trozos de esa revisión, del servidor: un índice de un
  /// solo campo, que Firestore crea solo. Sin red falla, y el motor espera.
  @override
  Future<List<transport.SourcePart>> listParts(
      String operationId, int revision) async {
    try {
      final query = await _db
          .collection('operations')
          .doc(operationId)
          .collection('sources')
          .where('revision', isEqualTo: revision)
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 45));
      return [
        for (final doc in query.docs)
          if (transport.SourcePart.read(doc.data()) case final part?) part
      ];
    } on TimeoutException {
      throw const RemoteStoreException(RemoteErrorKind.unavailable, 'timeout');
    } catch (error) {
      throw _remoteError(error);
    }
  }
}

/// T-84: Firestore Standard no admite arrays dentro de arrays. Solo en el
/// transporte, las filas de cada tapa se guardan en un mapa por número;
/// el perfil local conserva su JSON y la identidad T:bahía-número.
class FirestoreProfileCodec {
  const FirestoreProfileCodec._();

  static Map<String, dynamic> encode(VesselProfile profile) {
    final json = profile.toJson();
    json['hatchCovers'] = {
      for (final entry in profile.hatchCovers.entries)
        '${entry.key}': {
          'kind': entry.value.kind.name,
          'covers': {
            for (var i = 0; i < entry.value.covers.length; i++)
              '${i + 1}': entry.value.covers[i].toList()..sort(),
          },
        },
    };
    return json;
  }

  static VesselProfile decode(Map data) {
    final json = jsonDecode(jsonEncode(data)) as Map<String, dynamic>;
    final declarations = json['hatchCovers'] as Map<String, dynamic>?;
    for (final declaration in declarations?.values ?? const []) {
      final covers = (declaration as Map<String, dynamic>)['covers'];
      if (covers is Map<String, dynamic>) {
        final numbers = covers.keys.map(int.parse).toList()..sort();
        if (numbers.length > 3 ||
            List.generate(numbers.length, (i) => i + 1).join(',') != numbers.join(',')) {
          throw const FormatException('Numeración de tapas publicada inválida.');
        }
        declaration['covers'] = [for (final n in numbers) covers['$n']];
      }
    }
    return VesselProfile.fromJson(json);
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
