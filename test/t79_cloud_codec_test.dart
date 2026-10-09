import 'dart:convert';

import 'package:baystream/core/errors/failures.dart';
import 'package:baystream/features/vessel/data/repositories/firestore_operation_sync.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/operation_sources.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t75_memory_log.dart';

/// T-79 · Lo que viaja a la nube, sin red: el sobre de T-79a 2.3 como
/// documento, la huella de las fuentes (10.11) y las fuentes publicadas.
void main() {
  final createdAt = DateTime.utc(2026, 10, 9, 8, 15, 30, 123);
  final movement = Movement(
    id: '2f0c1d7e-3a94-4c55-9b7e-6a1f0e2d8c41',
    operationId: '8d3b0f52-1e6a-4b8f-a2c4-5e9d7f1a0b36',
    type: MovementType.assignEmpty,
    target: 'R:0030984',
    payload: {
      'container': 'TSTU0000012',
      'tareKg': 2185.0,
      'order': 12,
      'seal': 'S-12',
      'operatedAt': DateTime.utc(2026, 10, 9, 8, 10).toIso8601String(),
    },
    author: const MovementAuthor(uid: 'uid-muelle', name: 'Tarjador 1', role: OperatorRole.dock),
    deviceId: '7a1e9c04-5b2d-4f3a-8e61-0c9d2b7f4e15',
    sequence: 3,
    createdAt: createdAt,
  );

  group('el documento del movimiento', () {
    test('lleva el sobre exacto de las reglas, con horas como Timestamp', () {
      final doc = FirestoreMovementCodec.encode(movement);
      expect(doc.keys.toSet(), {
        'id', 'schema', 'operationId', 'type', 'target', 'payload', 'author',
        'deviceId', 'sequence', 'createdAt', 'receivedAt'
      });
      expect(doc['schema'], 1);
      expect(doc['type'], 'assign_empty');
      expect(doc['createdAt'], Timestamp.fromDate(createdAt));
      expect(doc['receivedAt'], isA<FieldValue>(), reason: 'hora del servidor');
      final payload = doc['payload']! as Map;
      expect(payload['operatedAt'], isA<Timestamp>());
      expect(doc['author'], {'uid': 'uid-muelle', 'name': 'Tarjador 1', 'role': 'dock'});
    });

    test('ida y vuelta: el mismo movimiento, aunque la tara vuelva entera', () {
      final doc = Map<String, dynamic>.from(FirestoreMovementCodec.encode(movement))
        ..['receivedAt'] = Timestamp.fromDate(DateTime.utc(2026, 10, 9, 8, 16));
      // La Web escribe 2185.0 como entero; el derivador lee `num`.
      (doc['payload'] as Map)['tareKg'] = 2185;
      final back = FirestoreMovementCodec.decode(doc);
      expect(back.id, movement.id);
      expect(back.createdAt.isAtSameMomentAs(createdAt), isTrue);
      expect(back.payload['operatedAt'], movement.payload['operatedAt']);
      expect(back.payload['order'], 12);
      expect((back.payload['tareKg'] as num).toDouble(), 2185.0);
      expect(back.author, movement.author);
      expect(back.receivedAt!.isAtSameMomentAs(DateTime.utc(2026, 10, 9, 8, 16)), isTrue);
      expect(Movement.compareOrder(back, movement), 0);
    });

    test('un documento que no se entiende se omite sin detener la escucha', () {
      expect(FirestoreMovementCodec.tryDecode({'type': 'otro'}), isNull);
      expect(FirestoreMovementCodec.tryDecode(null), isNull);
    });
  });

  group('las fuentes publicadas', () {
    test('la huella es del texto tal cual: 3900 y 3900.0 son textos distintos', () {
      final web = jsonEncode({'tara': 3900});
      const io = '{"tara":3900.0}';
      expect(FirestoreOperationSync.sourceHash(web), hasLength(64));
      expect(FirestoreOperationSync.sourceHash(web),
          isNot(FirestoreOperationSync.sourceHash(io)));
      expect(FirestoreOperationSync.sourceHash('ñandú'),
          FirestoreOperationSync.sourceHash('ñandú'));
    });

    test('los trozos caben en un documento y no cortan un par sustituto', () {
      final text = '${'A' * 9}😀${'B' * 10}';
      final parts = FirestoreOperationSync.splitSource(text, 10);
      expect(parts.join(), text);
      expect(parts.first, 'A' * 9, reason: 'el emoji no se parte');
      expect(parts.every((p) => p.length <= 10), isTrue);
      final big = 'X' * 650000;
      final bigParts = FirestoreOperationSync.splitSource(big);
      expect(bigParts.map((p) => p.length), [300000, 300000, 50000]);
      expect(FirestoreOperationSync.splitSource(''), ['']);
    });

    test('una operación guardada antes de T-79 se lee sin publicar y sin perfil', () {
      final old = {
        'id': 'op', 'vessel': 'B', 'voyage': 'V', 'portOfCall': 'GTSTC',
        'createdAt': '2026-10-07T12:00:00.000Z', 'sources': <Object>[],
      };
      final operation = Operation.fromJson(old);
      expect(operation.published, isFalse);
      expect(operation.closed, isFalse);
      expect(operation.profile, isNull);
      final again = Operation.fromJson(
          jsonDecode(jsonEncode(operation.copyWith(
              published: true, closedAt: DateTime.utc(2026, 10, 9))
              .toJson())) as Map<String, dynamic>);
      expect(again.published, isTrue);
      expect(again.closedAt, DateTime.utc(2026, 10, 9));
    });

    test('la publicada manda sobre la local y sus fuentes no cambian', () async {
      final log = T75MemoryLog();
      const voyage = VesselVoyage(
        id: 'v',
        vessel: Vessel(id: 'b', name: 'BUQUE PRUEBA'),
        voyageNumber: 'V001',
        containers: [],
        bays: {},
        portOfCall: 'GTSTC',
      );
      await log.saveOperation(Operation(
          id: 'local', vesselName: 'BUQUE PRUEBA', voyageNumber: 'V001',
          portOfCall: 'GTSTC', createdAt: DateTime.utc(2026, 10, 1)));
      await log.saveOperation(Operation(
          id: 'publicada', vesselName: 'BUQUE PRUEBA', voyageNumber: 'V001',
          portOfCall: 'GTSTC', createdAt: DateTime.utc(2026, 10, 2),
          published: true,
          sources: const [OperationSource(
              kind: OperationSourceKind.loadingBaplie, fileName: 'A.edi', content: 'UNB+A')]));
      expect((await OperationSources.find(log, voyage, 'GTSTC'))!.id, 'publicada');
      // Abrir la misma fuente no cambia nada.
      final same = await OperationSources.save(log, voyage, 'GTSTC',
          const OperationSource(
              kind: OperationSourceKind.loadingBaplie, fileName: 'A.edi', content: 'UNB+A'));
      expect(same.id, 'publicada');
      // Otro archivo, no: la nube tiene otra fuente.
      expect(
          () => OperationSources.save(log, voyage, 'GTSTC',
              const OperationSource(
                  kind: OperationSourceKind.loadingBaplie, fileName: 'B.edi', content: 'UNB+B')),
          throwsA(isA<ValidationFailure>()));
    });
  });
}
