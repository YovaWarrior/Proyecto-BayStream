import 'package:baystream/core/errors/failures.dart';
import 'package:baystream/features/vessel/data/repositories/firestore_operation_sync.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/session_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t129_fake_firestore.dart';
import 'support/t75_memory_log.dart';

/// T-129 (O-128-2) · «Cerrar operación» desde la oficina con el motor de
/// T-127 escuchando el documento de la operación. En la aceptación de la
/// 0.4.1 el primer cierre dejó la nube cerrada, contestó «No se encontró la
/// operación para cerrarla…» y la copia local siguió abierta; el segundo la
/// cerró. La causa: la lectura «del servidor» que sigue a la escritura se
/// resuelve con la vista local de la escucha, donde `closedAt` sigue
/// pendiente y se lee como nulo (`docs/T129-RESULTADOS.md`, 3). Corre contra
/// la nube falsa de `support/t129_fake_firestore.dart`, en la capa de
/// plataforma, debajo de las clases reales de `cloud_firestore`.
void main() {
  const office =
      Operator(uid: 'uid-oficina', name: 'Oficina 1', role: OperatorRole.office);
  const operationId = '5c2f7a10-9d4e-4b6a-8e31-2f7c9d0a1b45';
  const path = 'operations/$operationId';
  final createdAt = DateTime.utc(2026, 10, 30, 4, 7, 44);
  final serverNow = DateTime.utc(2026, 10, 30, 4, 13, 10, 231);

  late T129FakeFirestore db;
  late _Log log;
  late FirestoreOperationSync sync;

  // La operación local de la oficina de la aceptación: publicada, abierta,
  // con el plan de carga y, si se pide, el listado en su revisión 2.
  Operation published({bool withList = true}) => Operation(
        id: operationId,
        vesselName: 'BUQUE MANUAL',
        voyageNumber: 'M100',
        portOfCall: 'GTSTC',
        createdAt: createdAt,
        published: true,
        sources: [
          const OperationSource(
              kind: OperationSourceKind.loadingBaplie,
              fileName: 'T100_CARGA.edi',
              content: 'UNB+UNOA:2+PRUEBA'),
          if (withList)
            const OperationSource(
                kind: OperationSourceKind.exportList,
                fileName: 'T100_LISTADO_v2.xlsx',
                content: '{"fileName":"T100_LISTADO_v2.xlsx","rows":[]}',
                revision: 2),
        ],
      );

  Map<String, Object?> remoteOpen({bool withList = true}) => <String, Object?>{
        'id': operationId,
        'schema': 1,
        'vessel': 'BUQUE MANUAL',
        'voyage': 'M100',
        'portOfCall': 'GTSTC',
        'status': 'open',
        'createdAt': Timestamp.fromDate(createdAt),
        'sources': <String, Object?>{
          'loading_baplie': <String, Object?>{
            'fileName': 'T100_CARGA.edi',
            'parts': 1,
          },
          if (withList)
            'export_list': <String, Object?>{
              'fileName': 'T100_LISTADO_v2.xlsx',
              'parts': 1,
              'revision': 2,
            },
        },
      };

  /// Una vuelta del bucle de eventos: lo que tarda el eco del servidor en la
  /// nube falsa.
  Future<void> vuelta() => Future<void>.delayed(Duration.zero);

  setUp(() {
    db = T129FakeFirestore(clock: () => serverNow);
    log = _Log();
    sync = FirestoreOperationSync(db.instance, log, const _Session(office));
    db.server[path] = remoteOpen();
  });

  tearDown(() => sync.dispose());

  group('T-129 · el cierre con el documento de la operación ya escuchado (O-128-2)',
      () {
    test('el primer «Cerrar operación» cierra la nube y también la copia local',
        () async {
      await log.saveOperation(published());
      // El motor de T-127 mantiene esta escucha mientras la oficina sigue la
      // operación (`FirestoreRemoteMovementStore.watchList`); aquí la abre la
      // prueba, con los mismos parámetros.
      final doc = db.instance.collection('operations').doc(operationId);
      final listening =
          doc.snapshots(includeMetadataChanges: true).listen((_) {});
      addTearDown(listening.cancel);

      final result = await sync.close(operationId);
      await vuelta();

      // La nube quedó cerrada con la hora del servidor…
      expect(db.server[path]?['status'], 'closed');
      expect((db.server[path]?['closedAt'] as Timestamp?)?.toDate().toUtc(),
          serverNow);
      // …y la lectura que siguió a la escritura fue la de la vista escuchada.
      expect(db.readsFromListenedView, greaterThanOrEqualTo(1));
      // El dispositivo también cierra: esto es lo que O-128-2 vio fallar.
      final closed =
          result.fold<Operation?>((_) => null, (operation) => operation);
      expect(closed, isNotNull,
          reason: 'close() contestó: '
              '${result.fold((f) => '${f.code}: ${f.message}', (_) => '')}');
      expect(closed!.closedAt?.toUtc(), serverNow);
      final local = (await log.getOperation(operationId)).getOrElse(() => null);
      expect(local?.closed, isTrue);
      expect(local?.closedAt?.toUtc(), serverNow);
      expect(local?.exportListRevision, 2);
    });

    test('pasa igual sin listado ni revisión: lo que cuenta es la escucha abierta',
        () async {
      db.server[path] = remoteOpen(withList: false);
      await log.saveOperation(published(withList: false));
      final doc = db.instance.collection('operations').doc(operationId);
      final listening =
          doc.snapshots(includeMetadataChanges: true).listen((_) {});
      addTearDown(listening.cancel);

      final result = await sync.close(operationId);
      await vuelta();

      expect(db.server[path]?['status'], 'closed');
      expect(result.isRight(), isTrue,
          reason: 'close() contestó: '
              '${result.fold((f) => '${f.code}: ${f.message}', (_) => '')}');
      final local = (await log.getOperation(operationId)).getOrElse(() => null);
      expect(local?.closedAt?.toUtc(), serverNow);
      expect(local?.exportListRevision, 0);
    });

    test('sin ninguna escucha abierta, el cierre llega al dispositivo a la primera',
        () async {
      await log.saveOperation(published());

      final result = await sync.close(operationId);
      await vuelta();

      expect(result.isRight(), isTrue);
      expect(db.readsFromListenedView, 0);
      final local = (await log.getOperation(operationId)).getOrElse(() => null);
      expect(local?.closedAt?.toUtc(), serverNow);
    });

    test('el segundo intento, con la nube ya cerrada, cierra el dispositivo',
        () async {
      await log.saveOperation(published());
      db.server[path] = <String, Object?>{
        ...remoteOpen(),
        'status': 'closed',
        'closedAt': Timestamp.fromDate(serverNow),
      };
      final doc = db.instance.collection('operations').doc(operationId);
      final listening =
          doc.snapshots(includeMetadataChanges: true).listen((_) {});
      addTearDown(listening.cancel);

      final result = await sync.close(operationId);

      expect(result.isRight(), isTrue);
      final local = (await log.getOperation(operationId)).getOrElse(() => null);
      expect(local?.closedAt?.toUtc(), serverNow);
    });

    test('sin la operación en el dispositivo sigue diciendo que no la encontró',
        () async {
      final result = await sync.close(operationId);
      await vuelta();

      expect(db.server[path]?['status'], 'closed');
      expect(result.fold((f) => f.code, (_) => null), 'not_found');
      expect(result.fold((f) => f.message, (_) => ''),
          contains('No se encontró la operación'));
    });
  });

  // Revisión de Codex (`docs/t129/revision-codex.md`, P2; 10.91): el plazo de
  // 45 s del cierre cuenta desde que empieza a esperar el eco, y las
  // instantáneas que descarta no lo reinician. Con el reloj simulado de
  // `testWidgets`: `tester.pump(d)` adelanta el tiempo y dispara los plazos.
  group('T-129 · el plazo del cierre no se reinicia (P2 de la revisión)', () {
    /// Adelanta el reloj simulado [d] y deja correr lo que quedó pendiente.
    /// `Stream.timeout` cancela su fuente devolviendo `subscription.cancel()`,
    /// que es `Future._nullFuture`, de la zona raíz; con `cancelOnError`, el
    /// error del plazo se entrega cuando esa cancelación termina, y eso solo
    /// corre con una vuelta del bucle real (`runAsync`). Codex lo anotó igual
    /// en sus sondas (`docs/t129/revision-codex.md`, 2).
    Future<void> pasa(WidgetTester tester, Duration d) async {
      await tester.pump(d);
      for (var i = 0; i < 3; i++) {
        await tester.runAsync(() => Future<void>.delayed(Duration.zero));
        await tester.pump();
      }
    }

    /// Llama a `close()` sin esperarla y devuelve cómo va: nulo mientras
    /// espera. Si termina con un error en vez de un resultado, falla con él.
    Future<Either<Failure, Operation>?> Function() closing() {
      Either<Failure, Operation>? result;
      Object? error;
      sync.close(operationId).then((value) => result = value,
          onError: (Object e) => error = e);
      return () async {
        expect(error, isNull, reason: 'close() terminó con un error');
        return result;
      };
    }

    Future<void> expectTimedOut(Either<Failure, Operation>? result) async {
      expect(result, isNotNull, reason: 'close() sigue esperando');
      expect(result!.fold((f) => f.code, (_) => null), 'timeout');
      expect(db.server[path]?['status'], 'closed');
      expect(db.document(path).listeners, 0,
          reason: 'la escucha del cierre sigue abierta');
      final local = (await log.getOperation(operationId)).getOrElse(() => null);
      expect(local?.closed, isFalse);
    }

    testWidgets('en silencio, contesta timeout a los 45 s y suelta la escucha',
        (tester) async {
      await log.saveOperation(published());
      db.holdEcho = true;

      final result = closing();
      await pasa(tester, Duration.zero);
      expect(db.document(path).listeners, 1);

      await pasa(tester, const Duration(seconds: 44));
      expect(await result(), isNull, reason: 'terminó antes de los 45 s');
      await pasa(tester, const Duration(seconds: 2));
      await expectTimedOut(await result());
    });

    testWidgets(
        'con instantáneas rechazadas cada 40 s, contesta timeout a los 45 s '
        'y no espera hasta los 160 s', (tester) async {
      await log.saveOperation(published());
      db.holdEcho = true;
      final doc = db.document(path);

      final result = closing();
      await pasa(tester, Duration.zero);
      expect(doc.listeners, 1);

      // A los 40 s, la vista con la escritura pendiente: no sirve.
      await pasa(tester, const Duration(seconds: 40));
      doc.emitRejected();
      await pasa(tester, const Duration(seconds: 4));
      expect(await result(), isNull, reason: 'terminó antes de los 45 s');
      // A los 46 s ya contestó, aunque el último evento fue a los 40.
      await pasa(tester, const Duration(seconds: 2));
      await expectTimedOut(await result());

      // Los rechazos siguen hasta pasar los 160 s, de la caché y pendientes:
      // nadie los escucha y el resultado no cambia.
      var now = 46;
      for (final second in [80, 120, 160]) {
        await pasa(tester, Duration(seconds: second - now));
        now = second;
        doc.emitRejected(fromCache: second != 120);
      }
      await pasa(tester, const Duration(seconds: 5));
      await expectTimedOut(await result());
    });
  });
}

/// La bitácora en memoria de T-75 con la lectura de una operación, que
/// `close` usa y T-75 no necesitaba.
class _Log extends T75MemoryLog {
  @override
  Future<Either<Failure, Operation?>> getOperation(String id) async =>
      Right(operations.where((o) => o.id == id).firstOrNull);
}

/// Sesión fija de oficina autorizada: lo que `close` exige.
class _Session implements SessionRepository {
  const _Session(this.operator);

  final Operator operator;

  @override
  bool get supportsAccounts => true;
  @override
  Operator? get current => operator;
  @override
  Stream<Operator?> watchOperator() => Stream.value(operator);
  @override
  Future<Either<Failure, Operator>> signIn(String email, String password) async =>
      Right(operator);
  @override
  Future<Either<Failure, void>> signOut() async => const Right(null);
  @override
  Future<Either<Failure, void>> sendPasswordReset(String email) async =>
      const Right(null);
  @override
  Future<void> verify() async {}
  @override
  Future<void> dispose() async {}
}
