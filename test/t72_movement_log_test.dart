import 'dart:convert';
import 'dart:io';

import 'package:baystream/core/errors/failures.dart';
import 'package:baystream/features/vessel/data/datasources/hive_movement_data_source.dart';
import 'package:baystream/features/vessel/data/repositories/movement_log_repository_impl.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

/// T-72 · Bitácora local sobre Hive (T-79a 4.1 y 7.1). Cada prueba usa su
/// propia carpeta y su propio espacio de nombres.
void main() {
  const author = MovementAuthor(name: 'Tarjador 1', role: OperatorRole.dock);
  final uuidV4 =
      RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$');
  late Directory directory;
  late String namespace;
  var minute = 0;
  DateTime clock() => DateTime.utc(2025, 10, 4, 9, minute++);

  Future<MovementLogRepositoryImpl> open() async => MovementLogRepositoryImpl(
      await HiveMovementDataSource.open(directory: directory.path, namespace: namespace),
      clock: clock);

  MovementDraft loadDraft(String id, String position) =>
      MovementDraft.loadFull('op-1', id, position, order: 1, seal: 'S-$id');

  Future<MovementRecord> append(MovementLogRepositoryImpl repo, MovementDraft draft) async =>
      (await repo.append(draft, author)).getOrElse(() => throw StateError('append falló'));

  setUp(() async {
    final root = await Directory('build/t72/test-stores').create(recursive: true);
    directory = await root.createTemp('bitacora_');
    namespace = 't72_${DateTime.now().microsecondsSinceEpoch}';
    minute = 0;
  });

  tearDown(() async {
    if (directory.existsSync()) await directory.delete(recursive: true);
  });

  test('anexar asigna id UUID v4, secuencia, autor, dispositivo y hora', () async {
    final repo = await open();
    final a = await append(repo, loadDraft('L1', '0030102'));
    final b = await append(repo, loadDraft('L2', '0030104'));
    expect(a.movement.id, matches(uuidV4));
    expect(a.movement.sequence, 1);
    expect(b.movement.sequence, 2);
    expect(a.movement.deviceId, b.movement.deviceId);
    expect(a.movement.author, author);
    expect(a.movement.createdAt, DateTime.utc(2025, 10, 4, 9, 0));
    expect(a.state, SendState.localOnly, reason: 'hasta T-79 nadie sincroniza');
    final records = (await repo.records('op-1')).getOrElse(() => []);
    expect(records.map((r) => r.movement.target), ['C:L1', 'C:L2']);
    expect((await repo.records('otra')).getOrElse(() => [_dummy]), isEmpty);
    await repo.close();
  });

  test('un borrador inválido no se guarda', () async {
    final repo = await open();
    final result = await repo.append(MovementDraft.annul('op-1', 'x', ''), author);
    expect(result.isLeft(), isTrue);
    expect(result.swap().getOrElse(() => const CacheFailure(message: '')),
        isA<ValidationFailure>());
    expect((await repo.records('op-1')).getOrElse(() => [_dummy]), isEmpty);
    await repo.close();
  });

  test('cerrar y reabrir: lo anexado sigue, el dispositivo es el mismo y la secuencia continúa',
      () async {
    var repo = await open();
    final first = await append(repo, loadDraft('L1', '0030102'));
    await append(repo, loadDraft('L2', '0030104'));
    await append(repo, MovementDraft.annul('op-1', first.movement.id, 'Celda equivocada'));
    await repo.close();

    repo = await open();
    final records = (await repo.records('op-1')).getOrElse(() => []);
    expect(records, hasLength(3));
    expect(records.first, first);
    final next = await append(repo, loadDraft('L1', '0030102'));
    expect(next.movement.sequence, 4);
    expect(next.movement.deviceId, first.movement.deviceId);
    await repo.close();
  });

  test('una caja truncada a mitad del último registro abre sin él', () async {
    var repo = await open();
    await append(repo, loadDraft('L1', '0030102'));
    await append(repo, loadDraft('L2', '0030104'));
    await repo.close();

    final file = File('${directory.path}/${namespace}_movements.hive');
    final bytes = await file.readAsBytes();
    await file.writeAsBytes(bytes.sublist(0, bytes.length - 12), flush: true);

    repo = await open();
    final records = (await repo.records('op-1')).getOrElse(() => []);
    expect(records.map((r) => r.movement.target), ['C:L1'],
        reason: 'la recuperación de Hive descarta el bloque incompleto');
    expect((await append(repo, loadDraft('L2', '0030104'))).movement.sequence, 2);
    await repo.close();
  });

  test('una operación con movimientos sin confirmar no se puede quitar', () async {
    final repo = await open();
    final operation = Operation(
      id: 'op-1',
      vesselName: 'BUQUE GOLF',
      voyageNumber: 'VIAJE007A',
      portOfCall: 'GTSTC',
      createdAt: DateTime.utc(2025, 10, 4),
      sources: const [
        OperationSource(
            kind: OperationSourceKind.loadingBaplie, fileName: 'plan.edi', content: 'UNB+...'),
      ],
    );
    final empty = Operation(
        id: 'op-2',
        vesselName: 'BUQUE GOLF',
        voyageNumber: 'X',
        portOfCall: 'GTSTC',
        createdAt: DateTime.utc(2025, 10, 5));
    await repo.saveOperation(operation);
    await repo.saveOperation(empty);
    expect((await repo.getOperation('op-1')).getOrElse(() => null), operation);
    expect((await repo.getOperations()).getOrElse(() => []).map((o) => o.id), ['op-2', 'op-1']);

    await append(repo, loadDraft('L1', '0030102'));
    final refused = await repo.deleteOperation('op-1');
    expect(refused.swap().getOrElse(() => const CacheFailure(message: '')).code,
        'operation_has_movements');
    expect((await repo.getOperation('op-1')).getOrElse(() => null), isNotNull);

    expect((await repo.deleteOperation('op-2')).isRight(), isTrue);
    expect((await repo.getOperation('op-2')).getOrElse(() => operation), isNull);
    await repo.close();
  });

  test('la exportación lleva la operación sin el texto de las fuentes y cada movimiento',
      () async {
    final repo = await open();
    await repo.saveOperation(Operation(
      id: 'op-1',
      vesselName: 'BUQUE GOLF',
      voyageNumber: 'VIAJE007A',
      portOfCall: 'GTSTC',
      createdAt: DateTime.utc(2025, 10, 4),
      sources: const [
        OperationSource(
            kind: OperationSourceKind.loadingBaplie, fileName: 'plan.edi', content: 'UNB+...'),
      ],
    ));
    await append(repo, loadDraft('L1', '0030102'));
    await append(repo, MovementDraft.assignEmpty('op-1', '0050102', 'EMPT0000001', 2185));
    final json = jsonDecode((await repo.exportJson('op-1')).getOrElse(() => '{}'))
        as Map<String, dynamic>;
    expect(json['format'], 'baystream-bitacora');
    expect(json['schema'], 1);
    final sources = (json['operation'] as Map)['sources'] as List;
    expect((sources.single as Map).containsKey('content'), isFalse);
    final movements = (json['movements'] as List).cast<Map<String, dynamic>>();
    expect(movements.map((m) => m['type']), ['load_full', 'assign_empty']);
    expect(movements.every((m) => m['sendState'] == 'localOnly'), isTrue);
    expect(Movement.fromJson(movements.last).payload['tareKg'], 2185);
    await repo.close();
  });

  test('la escucha emite la lista al suscribirse y después de cada anexo', () async {
    final repo = await open();
    final seen = <int>[];
    final subscription = repo.watch('op-1').listen((records) => seen.add(records.length));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await append(repo, loadDraft('L1', '0030102'));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(seen.first, 0);
    expect(seen.last, 1);
    await subscription.cancel();
    await repo.close();
  });
}

final _dummy = MovementRecord(
  Movement(
      id: 'dummy',
      operationId: 'x',
      type: MovementType.annul,
      author: const MovementAuthor(name: 'x', role: OperatorRole.dock),
      deviceId: 'x',
      sequence: 1,
      createdAt: DateTime.utc(2025)),
  SendState.localOnly,
);
