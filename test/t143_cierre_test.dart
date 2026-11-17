import 'dart:async';
import 'dart:io';

import 'package:baystream/core/design/design.dart';
import 'package:baystream/core/errors/failures.dart';
import 'package:baystream/features/vessel/data/datasources/hive_movement_data_source.dart';
import 'package:baystream/features/vessel/data/repositories/firestore_operation_sync.dart';
import 'package:baystream/features/vessel/data/repositories/local_only_operation_sync.dart';
import 'package:baystream/features/vessel/data/repositories/movement_log_repository_impl.dart';
import 'package:baystream/features/vessel/data/repositories/sync_engine.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/operation_sync_repository.dart';
import 'package:baystream/features/vessel/domain/repositories/session_repository.dart';
import 'package:baystream/features/vessel/presentation/pages/cloud_page.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/aviso_del_cierre.dart';
import 'package:baystream/features/vessel/presentation/widgets/sync_status_chip.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t129_fake_firestore.dart';
import 'support/t75_memory_log.dart';
import 'support/t79_fake_cloud.dart';

/// T-143 (O-139-1; 10.117) · El muelle se entera del cierre sin registrar
/// nada. El motor lee la hora del cierre del documento de la operación, en la
/// misma escucha que ya bajaba las fuentes (T-127, T-130): con red cambia en
/// cuanto la oficina cierra; sin red, al volver la red. Contra la nube falsa
/// de T-79 sobre la bitácora real en Hive, el adaptador real sobre la
/// Firestore falsa de T-129 y las pantallas con la nube sustituida.
void main() {
  const dock = Operator(uid: 'uid-muelle', name: 'Tarjador 1', role: OperatorRole.dock);
  const office =
      Operator(uid: 'uid-oficina', name: 'Oficina 1', role: OperatorRole.office);
  const operationId = '2e7b5c90-4a1d-4f3e-8b6c-9d0a1e2f3b47';
  late Directory directory;
  late String namespace;
  late DateTime now;
  DateTime clock() => now;

  final published = Operation(
    id: operationId,
    vesselName: 'BUQUE MANUAL',
    voyageNumber: 'M100',
    portOfCall: 'GTSTC',
    createdAt: DateTime.utc(2026, 11, 10, 20),
    published: true,
  );

  Future<MovementLogRepositoryImpl> open() async => MovementLogRepositoryImpl(
      await HiveMovementDataSource.open(
          directory: directory.path, namespace: namespace),
      clock: () {
        now = now.add(const Duration(seconds: 1));
        return now;
      });

  Future<MovementRecord> load(MovementLogRepositoryImpl log, String container) async =>
      (await log.append(
              MovementDraft.loadFull(operationId, container, '0140102', order: 1),
              dock.author))
          .getOrElse(() => throw StateError('no se anexó'));

  Future<List<MovementRecord>> records(MovementLogRepositoryImpl log) async =>
      (await log.records(operationId)).getOrElse(() => const []);

  Future<Operation?> local(MovementLogRepositoryImpl log) async =>
      (await log.getOperation(operationId)).getOrElse(() => null);

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

  group('el motor del muelle', () {
    setUp(() async {
      directory = await Directory.systemTemp.createTemp('t143_cierre_');
      namespace = 't143_${DateTime.now().microsecondsSinceEpoch}';
      now = DateTime.utc(2026, 11, 10, 21);
    });
    tearDown(() async {
      if (directory.existsSync()) await directory.delete(recursive: true);
    });

    test('con red: la oficina cierra y el muelle se entera sin registrar nada',
        () async {
      final log = await open();
      await log.saveOperation(published);
      final cloud = FakeCloud(clock: clock)
        ..authorization[dock.uid] = RemoteAuthorization.active;
      final sync = engine(log, cloud);
      await sync.start(dock);
      await until(() async => sync.current.state == SyncState.upToDate);
      expect(sync.current.closed, isFalse);

      final cierre = now.add(const Duration(minutes: 3));
      cloud.server.closeOperation(cierre);
      await until(() async => sync.current.closed);
      expect(syncStatusText(sync.current), 'Al día · operación cerrada');
      expect(await records(log), isEmpty, reason: 'no hizo falta registrar');
      expect(cloud.writes, isEmpty);
      // El muelle lo recuerda al reiniciar.
      await until(() async => (await local(log))?.closed ?? false);
      expect((await local(log))!.closedAt, cierre);
      await sync.stop();
      await log.close();
    });

    test('sin red no cambia; al volver la red cambia solo', () async {
      final log = await open();
      await log.saveOperation(published);
      final cloud = FakeCloud(clock: clock)
        ..authorization[dock.uid] = RemoteAuthorization.active;
      final sync = engine(log, cloud);
      await sync.start(dock);
      await until(() async => sync.current.state == SyncState.upToDate);
      cloud.goOffline();
      await until(() async => sync.current.state == SyncState.offline);

      cloud.server.closeOperation(now.add(const Duration(minutes: 1)));
      await settle();
      expect(sync.current.closed, isFalse,
          reason: 'sin red el muelle no puede saberlo');
      expect((await local(log))!.closed, isFalse);

      cloud.goOnline();
      await until(() async => sync.current.closed);
      await until(() async => (await local(log))?.closed ?? false);
      expect(sync.current.state, SyncState.upToDate);
      expect(await records(log), isEmpty);
      await sync.stop();
      await log.close();
    });

    test('la cola al cerrar: entra lo anterior, se rechaza lo posterior, y el '
        'chip no invita a registrarlo de nuevo', () async {
      final log = await open();
      await log.saveOperation(published);
      final cloud = FakeCloud(clock: clock)
        ..authorization[dock.uid] = RemoteAuthorization.active;
      cloud.online = false;
      final sync = engine(log, cloud);
      await sync.start(dock);
      final before = await load(log, 'TSTU0000001');
      cloud.server.closeOperation(now.add(const Duration(milliseconds: 500)));
      now = now.add(const Duration(seconds: 5));
      final after = await load(log, 'TSTU0000002');
      cloud.goOnline();
      await until(() async =>
          (await records(log)).every((r) => r.state != SendState.pending));
      final byId = {for (final r in await records(log)) r.movement.id: r};
      expect(byId[before.movement.id]!.state, SendState.confirmed,
          reason: 'lo registrado antes del cierre no se pierde (reglas, d.createdAt <= closedAt)');
      expect(byId[after.movement.id]!.state, SendState.rejected);
      expect(byId[after.movement.id]!.rejection,
          'La operación se cerró antes de este movimiento.');
      await until(() async => sync.current.rejected == 1 && sync.current.closed);
      expect(syncStatusText(sync.current),
          'Al día · 1 rechazado: la operación ya estaba cerrada · operación cerrada');
      await sync.stop();
      await log.close();
    });

    test('guardar el cierre no pierde un plan que llegó después del arranque',
        () async {
      final log = await open();
      await log.saveOperation(published);
      final cloud = FakeCloud(clock: clock)
        ..authorization[dock.uid] = RemoteAuthorization.active;
      final sync = engine(log, cloud);
      await sync.start(dock);
      await until(() async => sync.current.state == SyncState.upToDate);
      // Otro camino guardó una fuente en la operación local (el motor de
      // T-130 lo hace al bajar un plan agregado).
      const plan = OperationSource(
          kind: OperationSourceKind.loadingBaplie,
          fileName: 'T100_CARGA.edi',
          content: 'UNB+UNOA:2+PRUEBA');
      await log.saveOperation(published.copyWith(sources: [plan]));
      cloud.server.closeOperation(now.add(const Duration(minutes: 1)));
      await until(() async => (await local(log))?.closed ?? false);
      expect((await local(log))!.source(OperationSourceKind.loadingBaplie), plan);
      await sync.stop();
      await log.close();
    });
  });

  group('el adaptador real lee la hora del cierre del documento', () {
    const path = 'operations/$operationId';
    final serverNow = DateTime.utc(2026, 11, 10, 22, 4, 11, 120);
    late T129FakeFirestore db;

    setUp(() {
      db = T129FakeFirestore(clock: () => serverNow);
      db.server[path] = <String, Object?>{
        'id': operationId,
        'schema': 1,
        'vessel': 'BUQUE MANUAL',
        'voyage': 'M100',
        'portOfCall': 'GTSTC',
        'status': 'open',
        'createdAt': Timestamp.fromDate(published.createdAt),
      };
    });

    Future<void> vuelta() => Future<void>.delayed(Duration.zero);

    test('el cierre de otro equipo llega por la escucha; la vista pendiente no',
        () async {
      final vistos = <RemoteOperationDocument>[];
      final escucha = FirestoreRemoteMovementStore(db.instance)
          .watchOperation(operationId)
          .listen(vistos.add);
      addTearDown(escucha.cancel);
      await vuelta();
      expect(vistos, isNotEmpty);
      expect(vistos.every((d) => d.closedAt == null), isTrue);

      // La oficina cierra (en la misma nube): primero la vista pendiente, con
      // la hora como nula, que no cuenta; después el eco del servidor.
      final log = _Log()..operations.add(published);
      final oficina =
          FirestoreOperationSync(db.instance, log, const _Session(office));
      addTearDown(oficina.dispose);
      final cerrada = await oficina.close(operationId);
      expect(cerrada.isRight(), isTrue);
      await vuelta();
      await vuelta();
      expect(vistos.last.closedAt?.toUtc(), serverNow);
      expect(
          vistos.skipWhile((d) => d.closedAt == null).every((d) => d.closedAt != null),
          isTrue,
          reason: 'después del cierre no vuelve a llegar una vista sin hora');
    });

    test('de la caché, un cierre ya visto vale', () async {
      db.server[path] = {
        ...db.server[path]!,
        'status': 'closed',
        'closedAt': Timestamp.fromDate(serverNow),
      };
      final vistos = <RemoteOperationDocument>[];
      final escucha = FirestoreRemoteMovementStore(db.instance)
          .watchOperation(operationId)
          .listen(vistos.add);
      addTearDown(escucha.cancel);
      await vuelta();
      db.document(path).emitRejected(fromCache: true);
      await vuelta();
      expect(vistos, isNotEmpty);
      expect(vistos.last.closedAt?.toUtc(), serverNow);
    });
  });

  group('las pantallas del muelle', () {
    Operation abierta() => published;

    testWidgets(
        'el aviso del cierre sale una vez, pide releer la operación y no sale '
        'en el equipo que cerró', (tester) async {
      final estados = StreamController<SyncStatus>.broadcast();
      addTearDown(estados.close);
      await tester.pumpWidget(ProviderScope(
          overrides: [
            syncStatusProvider.overrideWith((ref) => estados.stream),
            activeOperationProvider.overrideWith((ref) async => abierta()),
          ],
          child: MaterialApp(
              theme: BayStreamTema.claro(muelle: true),
              home: const Scaffold(body: AvisoDelCierre()))));
      await tester.pump();
      final container =
          ProviderScope.containerOf(tester.element(find.byType(AvisoDelCierre)));
      const aviso = ValueKey('aviso-operacion-cerrada');
      Future<void> emitir(SyncStatus estado) async {
        estados.add(estado);
        for (var i = 0; i < 4; i++) {
          await tester.pump();
        }
      }

      await emitir(const SyncStatus(SyncState.upToDate));
      expect(find.byKey(aviso), findsNothing);
      expect(container.read(operationSourcesRevisionProvider), 0);

      await emitir(const SyncStatus(SyncState.upToDate, closed: true));
      expect(find.byKey(aviso), findsOneWidget);
      expect(
          find.text('La oficina cerró la operación de GTSTC. Lo que registres '
              'desde ahora se rechazará.'),
          findsOneWidget);
      expect(container.read(operationSourcesRevisionProvider), 1,
          reason: 'la píldora y «Nube y cuenta» vuelven a leer la operación');

      // El aviso entra, dura sus 8 s y se va.
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 9));
      await tester.pumpAndSettle();
      expect(find.byKey(aviso), findsNothing);
      await emitir(const SyncStatus(SyncState.sending, pending: 1, closed: true));
      expect(find.byKey(aviso), findsNothing, reason: 'una sola vez');
      expect(container.read(operationSourcesRevisionProvider), 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('en el equipo que cerró no hay aviso', (tester) async {
      final estados = StreamController<SyncStatus>.broadcast();
      addTearDown(estados.close);
      await tester.pumpWidget(ProviderScope(
          overrides: [
            syncStatusProvider.overrideWith((ref) => estados.stream),
            activeOperationProvider.overrideWith((ref) async => abierta()),
          ],
          child: MaterialApp(
              theme: BayStreamTema.claro(),
              home: const Scaffold(body: AvisoDelCierre()))));
      await tester.pump();
      final container =
          ProviderScope.containerOf(tester.element(find.byType(AvisoDelCierre)));
      estados.add(const SyncStatus(SyncState.upToDate));
      await tester.pump();
      await tester.pump();
      container.read(operacionesCerradasAquiProvider.notifier).anotar(operationId);
      estados.add(const SyncStatus(SyncState.upToDate, closed: true));
      for (var i = 0; i < 4; i++) {
        await tester.pump();
      }
      expect(find.byKey(const ValueKey('aviso-operacion-cerrada')), findsNothing);
      expect(container.read(operationSourcesRevisionProvider), 1,
          reason: 'la operación se relee igual');
    });

    testWidgets('una operación que ya estaba cerrada al abrirse no es noticia',
        (tester) async {
      await tester.pumpWidget(ProviderScope(
          overrides: [
            syncStatusProvider.overrideWith((ref) =>
                Stream.value(const SyncStatus(SyncState.upToDate, closed: true))),
            activeOperationProvider.overrideWith((ref) async =>
                published.copyWith(closedAt: DateTime.utc(2026, 11, 10, 22))),
          ],
          child: MaterialApp(
              theme: BayStreamTema.claro(),
              home: const Scaffold(body: AvisoDelCierre()))));
      for (var i = 0; i < 4; i++) {
        await tester.pump();
      }
      expect(find.byKey(const ValueKey('aviso-operacion-cerrada')), findsNothing);
    });

    for (final brightness in Brightness.values) {
      testWidgets(
          '«Nube y cuenta» del muelle dice «Publicada y cerrada», sin «Reintentar», '
          'a 360 dp en tema ${brightness.name}', (tester) async {
        tester.view.physicalSize = const Size(720, 1600);
        tester.view.devicePixelRatio = 2;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(ProviderScope(
            overrides: [
              sessionRepositoryProvider
                  .overrideWith((ref) async => const _Session(dock)),
              operationSyncProvider
                  .overrideWith((ref) async => const LocalOnlyOperationSync()),
              movementLogRepositoryProvider.overrideWith((ref) async => T75MemoryLog()),
              activeOperationProvider.overrideWith((ref) async => abierta()),
              syncStatusProvider.overrideWith((ref) => Stream.value(
                  const SyncStatus(SyncState.upToDate, rejected: 1, closed: true))),
              openOperationsProvider.overrideWith((ref) => Stream.value(const [])),
            ],
            child: MaterialApp(
                theme: brightness == Brightness.light
                    ? BayStreamTema.claro(muelle: true)
                    : BayStreamTema.oscuro(muelle: true),
                home: const CloudPage())));
        await tester.pumpAndSettle();
        expect(
            tester.widget<Text>(find.byKey(const ValueKey('cloud-operation-state'))).data,
            'Publicada y cerrada');
        expect(
            tester.widget<Text>(find.byKey(const ValueKey('cloud-sync-status'))).data,
            'Al día · 1 rechazado: la operación ya estaba cerrada · operación cerrada');
        expect(find.byKey(const ValueKey('retry-button')), findsNothing);
        expect(find.byKey(const ValueKey('close-operation-button')), findsNothing);
        expect(find.text('No hay operaciones abiertas.'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('la oficina con la operación cerrada en la nube tampoco ofrece cerrarla',
        (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(ProviderScope(
          overrides: [
            sessionRepositoryProvider
                .overrideWith((ref) async => const _Session(office)),
            operationSyncProvider
                .overrideWith((ref) async => const LocalOnlyOperationSync()),
            movementLogRepositoryProvider.overrideWith((ref) async => T75MemoryLog()),
            activeOperationProvider.overrideWith((ref) async => abierta()),
            syncStatusProvider.overrideWith((ref) =>
                Stream.value(const SyncStatus(SyncState.upToDate, closed: true))),
            openOperationsProvider.overrideWith((ref) => Stream.value(const [])),
          ],
          child: MaterialApp(theme: BayStreamTema.claro(), home: const CloudPage())));
      await tester.pumpAndSettle();
      expect(find.text('Publicada y cerrada'), findsOneWidget);
      expect(find.byKey(const ValueKey('close-operation-button')), findsNothing);
    });
  });
}

class _Log extends T75MemoryLog {
  @override
  Future<Either<Failure, Operation?>> getOperation(String id) async =>
      Right(operations.where((o) => o.id == id).firstOrNull);
}

/// Sesión fija y autorizada.
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
