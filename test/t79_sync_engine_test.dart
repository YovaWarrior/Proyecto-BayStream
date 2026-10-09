import 'dart:io';

import 'package:baystream/features/vessel/data/datasources/hive_movement_data_source.dart';
import 'package:baystream/features/vessel/data/repositories/local_only_operation_sync.dart';
import 'package:baystream/features/vessel/data/repositories/movement_log_repository_impl.dart';
import 'package:baystream/features/vessel/data/repositories/sync_engine.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/operation_sync_repository.dart';
import 'package:baystream/features/vessel/domain/repositories/session_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t79_fake_cloud.dart';

/// T-79 · La suite de T-79a 7.1: el motor de la cola contra una nube falsa,
/// sobre la bitácora real en Hive. Cada prueba usa su carpeta temporal.
void main() {
  const dock = Operator(uid: 'uid-muelle', name: 'Tarjador 1', role: OperatorRole.dock);
  const other = Operator(uid: 'uid-otro', name: 'Tarjador 2', role: OperatorRole.dock);
  const operationId = '8d3b0f52-1e6a-4b8f-a2c4-5e9d7f1a0b36';
  late Directory directory;
  late String namespace;
  late DateTime now;
  DateTime clock() => now;

  final published = Operation(
    id: operationId,
    vesselName: 'BUQUE PRUEBA',
    voyageNumber: 'V001',
    portOfCall: 'GTSTC',
    createdAt: DateTime.utc(2026, 10, 9, 7),
    published: true,
  );

  Future<MovementLogRepositoryImpl> open() async => MovementLogRepositoryImpl(
      await HiveMovementDataSource.open(
          directory: directory.path, namespace: namespace),
      clock: () {
        now = now.add(const Duration(seconds: 1));
        return now;
      });

  Future<MovementRecord> load(MovementLogRepositoryImpl log, String container,
      {Operator operator = dock}) async {
    final record = (await log.append(
            MovementDraft.loadFull(operationId, container, '0140102', order: 1),
            operator.author))
        .getOrElse(() => throw StateError('no se anexó'));
    return record;
  }

  Future<List<MovementRecord>> records(MovementLogRepositoryImpl log) async =>
      (await log.records(operationId)).getOrElse(() => const []);

  /// Espera a que la cola y Hive terminen: son escrituras de disco reales.
  Future<void> until(Future<bool> Function() condition) async {
    for (var i = 0; i < 300; i++) {
      if (await condition()) return;
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    fail('No se cumplió a tiempo');
  }

  Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 80));

  SyncEngine engine(MovementLogRepositoryImpl log, FakeCloud cloud) => SyncEngine(
      log: log,
      remote: cloud,
      operation: published,
      clock: clock,
      tick: const Duration(hours: 1));

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('t79_cola_');
    namespace = 't79_${DateTime.now().microsecondsSinceEpoch}';
    now = DateTime.utc(2026, 10, 9, 8);
  });

  tearDown(() async {
    if (directory.existsSync()) await directory.delete(recursive: true);
  });

  group('al anexar', () {
    test('con cuenta y operación publicada nace pendiente; sin cuenta, solo local',
        () async {
      final log = await open();
      await log.saveOperation(published);
      final withAccount = await load(log, 'TSTU0000001');
      final withoutAccount = (await log.append(
              MovementDraft.loadFull(operationId, 'TSTU0000002', '0140104'),
              const MovementAuthor(name: 'Muelle (sin cuenta)', role: OperatorRole.dock)))
          .getOrElse(() => throw StateError('no'));
      expect(withAccount.state, SendState.pending);
      expect(withoutAccount.state, SendState.localOnly);
      // Anular algo que se quedó en el dispositivo tampoco se sube: la nube
      // no tendría el movimiento anulado.
      final annul = (await log.append(
              MovementDraft.annul(operationId, withoutAccount.movement.id, 'Error'),
              dock.author))
          .getOrElse(() => throw StateError('no'));
      expect(annul.state, SendState.localOnly);
      expect(withAccount.movement.createdAt.microsecond, 0,
          reason: 'milisegundos, para ordenar igual en la Web');
      await log.close();
    });

    test('en una operación sin publicar, todo queda local', () async {
      final log = await open();
      await log.saveOperation(Operation(
          id: operationId,
          vesselName: 'BUQUE PRUEBA',
          voyageNumber: 'V001',
          portOfCall: 'GTSTC',
          createdAt: DateTime.utc(2026)));
      expect((await load(log, 'TSTU0000001')).state, SendState.localOnly);
      await log.close();
    });
  });

  test('confirma por el set y, si el set no contesta, por el eco', () async {
    final log = await open();
    await log.saveOperation(published);
    final cloud = FakeCloud(clock: clock)..authorization[dock.uid] = RemoteAuthorization.active;
    final sync = engine(log, cloud);
    await sync.start(dock);
    final first = await load(log, 'TSTU0000001');
    await until(() async => (await records(log)).single.state == SendState.confirmed);
    expect(cloud.docs.keys, [first.movement.id]);

    // El servidor lo recibe, pero la respuesta del set nunca llega: el eco
    // del listener basta para confirmar.
    cloud.silent = true;
    final second = await load(log, 'TSTU0000002');
    await settle();
    expect((await records(log)).last.state, SendState.pending);
    cloud.dropQueue();
    cloud.silent = false;
    cloud.receiveWithoutAck(second.movement);
    await until(() async =>
        (await records(log)).every((r) => r.state == SendState.confirmed) &&
        sync.current.state == SyncState.upToDate);
    await sync.stop();
    await log.close();
  });

  test('sin red queda pendiente y al volver sube cada id una sola vez', () async {
    final log = await open();
    await log.saveOperation(published);
    final cloud = FakeCloud(clock: clock)..authorization[dock.uid] = RemoteAuthorization.active;
    cloud.online = false;
    final sync = engine(log, cloud);
    await sync.start(dock);
    for (var i = 1; i <= 3; i++) {
      await load(log, 'TSTU000000$i');
    }
    await until(() async => sync.current.pending == 3);
    expect(sync.current.state, SyncState.offline);
    expect(cloud.docs, isEmpty);
    cloud.goOnline();
    await until(() async =>
        (await records(log)).every((r) => r.state == SendState.confirmed));
    expect(cloud.docs, hasLength(3));
    expect(cloud.writes.toSet(), hasLength(3));
    await until(() async => sync.current.state == SyncState.upToDate);
    await sync.stop();
    await log.close();
  });

  test('reinicio: reenvía los mismos ids y el servidor no duplica', () async {
    var log = await open();
    await log.saveOperation(published);
    final cloud = FakeCloud(clock: clock)..authorization[dock.uid] = RemoteAuthorization.active;
    cloud.online = false;
    var sync = engine(log, cloud);
    await sync.start(dock);
    final a = await load(log, 'TSTU0000001');
    await load(log, 'TSTU0000002');
    await load(log, 'TSTU0000003');
    await until(() async => cloud.queued == 3);
    // El primero sí había llegado antes del cierre forzado.
    cloud.receiveWithoutAck(a.movement);
    await sync.stop();
    await log.close();
    cloud.dropQueue();

    log = await open();
    expect((await records(log)).where((r) => r.state == SendState.pending), hasLength(3));
    cloud.online = true;
    sync = engine(log, cloud);
    await sync.start(dock);
    await until(() async =>
        (await records(log)).every((r) => r.state == SendState.confirmed));
    expect(cloud.docs, hasLength(3), reason: 'cada id una sola vez');
    expect(cloud.identicalResends, 1, reason: 'el reenvío del primero es el no-op permitido');
    await sync.stop();
    await log.close();
  });

  test('cuenta inactiva: pausa sin rechazar y al reactivarla se envía todo', () async {
    final log = await open();
    await log.saveOperation(published);
    final cloud = FakeCloud(clock: clock)
      ..authorization[dock.uid] = RemoteAuthorization.inactive;
    final sync = engine(log, cloud);
    await sync.start(dock);
    await load(log, 'TSTU0000001');
    await load(log, 'TSTU0000002');
    await until(() async =>
        sync.current.state == SyncState.notAuthorized && sync.current.pending == 2);
    expect(sync.current.rejected, 0);
    expect((await records(log)).map((r) => r.state).toSet(), {SendState.pending});

    // La sesión avisa en tiempo real de `active`: primero falso, luego verdadero.
    await sync.setOperator(const Operator(
        uid: 'uid-muelle', name: 'Tarjador 1', role: OperatorRole.dock, authorized: false));
    cloud.authorization[dock.uid] = RemoteAuthorization.active;
    await sync.setOperator(dock);
    await until(() async =>
        (await records(log)).every((r) => r.state == SendState.confirmed));
    expect(cloud.docs, hasLength(2));
    await until(() async => sync.current.state == SyncState.upToDate);
    await sync.stop();
    await log.close();
  });

  test('permiso denegado con la cuenta activa: ese movimiento queda rechazado',
      () async {
    final log = await open();
    await log.saveOperation(published);
    final cloud = FakeCloud(clock: clock)..authorization[dock.uid] = RemoteAuthorization.active;
    cloud.denied.add('C:TSTU0000002');
    final sync = engine(log, cloud);
    await sync.start(dock);
    await load(log, 'TSTU0000001');
    final denied = await load(log, 'TSTU0000002');
    await until(() async =>
        (await records(log)).every((r) => r.state != SendState.pending));
    final byId = {for (final r in await records(log)) r.movement.id: r};
    expect(byId[denied.movement.id]!.state, SendState.rejected);
    expect(byId[denied.movement.id]!.rejection, 'La nube rechazó este movimiento: reglas.');
    await until(() async => sync.current.rejected == 1);
    expect(cloud.docs, hasLength(1));

    // Rechazado no es borrado: si se corrige la causa, «Reintentar» lo envía.
    cloud.denied.clear();
    await log.requeueRejected(operationId);
    await sync.retry();
    await until(() async =>
        (await records(log)).every((r) => r.state == SendState.confirmed));
    await until(() async => sync.current.rejected == 0);
    await sync.stop();
    await log.close();
  });

  test('sesión vencida: pausa, los pendientes siguen y al volver a entrar se envían',
      () async {
    final log = await open();
    await log.saveOperation(published);
    final cloud = FakeCloud(clock: clock)
      ..authorization[dock.uid] = RemoteAuthorization.active
      ..unauthenticated = true;
    final sync = engine(log, cloud);
    await sync.start(dock);
    await load(log, 'TSTU0000001');
    await until(() async => sync.current.state == SyncState.sessionExpired);
    expect(sync.current.pending, 1);
    expect((await records(log)).single.state, SendState.pending);

    // Cerrar sesión y volver a entrar: el SDK vuelve a tener token.
    await sync.setOperator(null);
    expect(sync.current.state, SyncState.sessionExpired,
        reason: 'sin sesión, lo pendiente sigue esperando');
    cloud.unauthenticated = false;
    await sync.setOperator(dock);
    await until(() async => (await records(log)).single.state == SendState.confirmed);
    await sync.stop();
    await log.close();
  });

  test('operación cerrada: entra lo anterior al cierre y se rechaza lo posterior',
      () async {
    final log = await open();
    await log.saveOperation(published);
    final cloud = FakeCloud(clock: clock)..authorization[dock.uid] = RemoteAuthorization.active;
    cloud.online = false;
    final sync = engine(log, cloud);
    await sync.start(dock);
    final before = await load(log, 'TSTU0000001');
    cloud.closedAtValue = now.add(const Duration(milliseconds: 500));
    now = now.add(const Duration(seconds: 5));
    final after = await load(log, 'TSTU0000002');
    cloud.goOnline();
    await until(() async =>
        (await records(log)).every((r) => r.state != SendState.pending));
    final byId = {for (final r in await records(log)) r.movement.id: r};
    expect(byId[before.movement.id]!.state, SendState.confirmed);
    expect(byId[after.movement.id]!.state, SendState.rejected);
    expect(byId[after.movement.id]!.rejection,
        'La operación se cerró antes de este movimiento.');
    await until(() async =>
        sync.current.rejected == 1 &&
        sync.current.closed &&
        // el muelle recuerda el cierre al reiniciar
        (await log.getOperation(operationId)).getOrElse(() => null)!.closed);
    await sync.stop();
    await log.close();
  });

  test('cambio de usuario: lo pendiente de otra cuenta no se envía con la nueva',
      () async {
    final log = await open();
    await log.saveOperation(published);
    final cloud = FakeCloud(clock: clock)
      ..authorization[dock.uid] = RemoteAuthorization.active
      ..authorization[other.uid] = RemoteAuthorization.active;
    cloud.online = false;
    final sync = engine(log, cloud);
    await sync.start(dock);
    await load(log, 'TSTU0000001');
    await sync.setOperator(null);
    await sync.setOperator(other);
    await load(log, 'TSTU0000002', operator: other);
    cloud.dropQueue();
    cloud.goOnline();
    await until(() async => cloud.docs.length == 1);
    await settle();
    expect(cloud.docs.values.single.author.uid, other.uid);
    await until(() async =>
        sync.current.otherAuthor == 1 && sync.current.state == SyncState.upToDate);
    await sync.stop();
    await log.close();
  });

  test('el falso deja de confirmar sin dar error: a los 5 minutos lo dice', () async {
    final log = await open();
    await log.saveOperation(published);
    final cloud = FakeCloud(clock: clock)
      ..authorization[dock.uid] = RemoteAuthorization.active
      ..silent = true;
    final sync = engine(log, cloud);
    await sync.start(dock);
    final record = await load(log, 'TSTU0000001');
    await settle();
    expect(sync.current.state, SyncState.sending);
    now = now.add(const Duration(minutes: 4, seconds: 50));
    sync.evaluate();
    expect(sync.current.state, SyncState.sending, reason: 'todavía no son 5 minutos');
    now = now.add(const Duration(seconds: 20));
    sync.evaluate();
    expect(sync.current.state, SyncState.unconfirmed);
    expect(sync.current.since, record.movement.createdAt);
    expect(sync.current.pending, 1);
    await sync.stop();
    await log.close();
  });

  test('sin red no cuenta para la salvaguarda: el reloj corre desde que vuelve',
      () async {
    final log = await open();
    await log.saveOperation(published);
    final cloud = FakeCloud(clock: clock)..authorization[dock.uid] = RemoteAuthorization.active;
    cloud.online = false;
    final sync = engine(log, cloud);
    await sync.start(dock);
    await load(log, 'TSTU0000001');
    now = now.add(const Duration(hours: 2));
    sync.evaluate();
    expect(sync.current.state, SyncState.offline);
    await sync.stop();
    await log.close();
  });

  test('sin la nube: un solo dispositivo, sin publicar ni unirse', () async {
    const sync = LocalOnlyOperationSync();
    const session = LocalSessionRepository();
    expect(sync.capability, SyncCapability.none);
    expect(await sync.follow(published).first, SyncStatus.local);
    expect((await sync.publish(published, _profile())).isLeft(), isTrue);
    expect((await sync.join(operationId)).isLeft(), isTrue);
    expect(session.supportsAccounts, isFalse);
    expect(await session.watchOperator().first, isNull);
    expect((await session.signIn('a@b.c', 'x')).isLeft(), isTrue);
  });
}

VesselProfile _profile() => VesselProfile(
      identity: VesselIdentity(source: VesselIdentitySource.name, value: 'BUQUE PRUEBA'),
      vesselName: 'BUQUE PRUEBA',
      geometry: VesselGeometry.proposeFrom(const []),
      origin: VesselProfileOrigin.declaredByUser,
      updatedAt: DateTime.utc(2026),
    );
