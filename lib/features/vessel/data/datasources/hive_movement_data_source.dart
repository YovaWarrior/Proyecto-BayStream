import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/movement.dart';
import '../../domain/entities/operation.dart';

/// T-72 · Tres cajas propias para la bitácora (T-79a 4.1), fuera del límite
/// de cinco viajes recientes: un movimiento sin enviar no puede perderse por
/// abrir otros archivos.
class HiveMovementDataSource {
  static const int schemaVersion = 1;

  final Box<String> _operations;
  final Box<String> _movements;
  final Box<String> _device;

  /// UUID de esta instalación, creado una vez.
  final String deviceId;
  int _sequence;
  Future<void> _writes = Future.value();

  HiveMovementDataSource._(
      this._operations, this._movements, this._device, this.deviceId, this._sequence);

  /// Mismo directorio y motor que el almacén de viajes y perfiles. En Web,
  /// `directory: null` usa IndexedDB del origen.
  static Future<HiveMovementDataSource> open({
    required String? directory,
    String namespace = 'baystream',
  }) async {
    final opened = <Box<String>>[];
    try {
      for (final name in ['operations', 'movements', 'device']) {
        opened.add(await Hive.openBox<String>('${namespace}_$name', path: directory));
      }
    } catch (_) {
      for (final box in opened) {
        await box.close();
      }
      rethrow;
    }
    final [operations, movements, device] = opened;
    var deviceId = device.get('deviceId');
    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await device.put('deviceId', deviceId);
      await device.flush();
    }
    // La secuencia no se guarda aparte: sale de los movimientos propios, así
    // no hay dos escrituras que puedan quedar a medias (T-79a 4.1).
    var sequence = 0;
    for (final record in movements.values) {
      final movement = _decodeMovement(record).movement;
      if (movement.deviceId == deviceId && movement.sequence > sequence) {
        sequence = movement.sequence;
      }
    }
    return HiveMovementDataSource._(operations, movements, device, deviceId, sequence);
  }

  int nextSequence() => ++_sequence;

  Future<void> _write(Future<void> Function() operation) {
    final result = _writes.then((_) => operation());
    // Una escritura fallida se informa al llamador, sin bloquear las siguientes.
    _writes = result.then<void>((_) {}, onError: (Object error, StackTrace stack) {});
    return result;
  }

  Future<void> putMovement(MovementRecord record) => _write(() async {
        await _movements.put(record.movement.id, _encodeMovement(record));
        await _movements.flush();
      });

  /// T-79 · Lo que trae la nube llega por tandas: una sola escritura a disco.
  Future<void> putMovements(Iterable<MovementRecord> records) => _write(() async {
        await _movements.putAll({
          for (final record in records) record.movement.id: _encodeMovement(record)
        });
        await _movements.flush();
      });

  MovementRecord? movement(String id) {
    final record = _movements.get(id);
    return record == null ? null : _decodeMovement(record);
  }

  List<MovementRecord> movements(String operationId) => _movements.values
      .map(_decodeMovement)
      .where((r) => r.movement.operationId == operationId)
      .toList();

  Future<void> putOperation(Operation operation) => _write(() async {
        await _operations.put(operation.id, jsonEncode({
          'schemaVersion': schemaVersion,
          'data': operation.toJson(),
        }));
        await _operations.flush();
      });

  Operation? operation(String id) {
    final record = _operations.get(id);
    return record == null ? null : _decodeOperation(record);
  }

  List<Operation> operations() => _operations.values.map(_decodeOperation).toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  Future<void> deleteOperation(String id) => _write(() async {
        await _operations.delete(id);
        await _operations.flush();
      });

  Future<void> close() async {
    await _writes;
    try {
      await _movements.close();
      await _operations.close();
    } finally {
      await _device.close();
    }
  }

  static String _encodeMovement(MovementRecord record) => jsonEncode({
        'schemaVersion': schemaVersion,
        'data': record.movement.toJson(),
        'send': {'state': record.state.name, 'rejection': record.rejection},
      });

  static Map<String, dynamic> _data(String record) {
    final json = jsonDecode(record) as Map<String, dynamic>;
    final version = json['schemaVersion'];
    // Una versión desconocida no se interpreta a ciegas.
    if (version != schemaVersion) {
      throw FormatException('Versión de bitácora local no admitida: $version');
    }
    return json;
  }

  static MovementRecord _decodeMovement(String record) {
    final json = _data(record);
    final send = Map<String, dynamic>.from(json['send'] as Map? ?? const {});
    return MovementRecord(
      Movement.fromJson(Map<String, dynamic>.from(json['data'] as Map)),
      SendState.values.firstWhere((s) => s.name == send['state'],
          orElse: () => SendState.localOnly),
      rejection: send['rejection'] as String?,
    );
  }

  static Operation _decodeOperation(String record) =>
      Operation.fromJson(Map<String, dynamic>.from(_data(record)['data'] as Map));
}
