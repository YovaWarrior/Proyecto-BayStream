import 'dart:convert';

import 'package:hive_ce/hive.dart';

import '../../domain/entities/entities.dart';
import '../../domain/repositories/local_vessel_repository.dart';
import 'local_vessel_codec.dart';

/// Dos cajas del mismo motor: perfiles por clave natural y viajes por UUID.
class HiveVesselDataSource {
  final Box<String> _profiles;
  final Box<String> _voyages;
  final LocalVesselCodec _codec = const LocalVesselCodec();
  Future<void> _voyageWrites = Future.value();

  HiveVesselDataSource._(this._profiles, this._voyages);

  /// En Windows/Android se inyecta el directorio privado de la aplicación.
  /// En Web, `directory: null` utiliza IndexedDB del origen actual.
  /// No usa `Hive.init` ni cierra cajas ajenas a este almacén.
  static Future<HiveVesselDataSource> open({
    required String? directory,
    String namespace = 'baystream',
  }) async {
    final profiles =
        await Hive.openBox<String>('${namespace}_profiles', path: directory);
    try {
      final voyages =
          await Hive.openBox<String>('${namespace}_voyages', path: directory);
      return HiveVesselDataSource._(profiles, voyages);
    } catch (_) {
      await profiles.close();
      rethrow;
    }
  }

  Future<void> _writeVoyages(Future<void> Function() operation) {
    final result = _voyageWrites.then((_) => operation());
    // Una escritura fallida se informa al llamador, sin bloquear las siguientes.
    _voyageWrites = result.then<void>((_) {}, onError: (Object error, StackTrace stack) {});
    return result;
  }

  Future<void> saveVoyage(VesselVoyage voyage) => _writeVoyages(() async {
    final keys = _orderedKeys();
    final existing = _voyages.get(voyage.id);
    final order = existing == null
        ? (keys.isEmpty ? 1 : _savedOrder(_voyages.get(keys.last)!) + 1)
        : _savedOrder(existing);
    final record = jsonDecode(_codec.encodeVoyage(voyage)) as Map<String, dynamic>;
    // Hive ordena las claves, no las inserciones. El ordinal local persiste el
    // orden de incorporación; no depende del UUID ni de la fecha del archivo.
    record['savedOrder'] = order;
    await _voyages.put(voyage.id, jsonEncode(record));
    final excess = _voyages.length - LocalVesselRepository.recentVoyageLimit;
    if (excess > 0) {
      await _voyages.deleteAll(_orderedKeys().take(excess).toList());
    }
    await _voyages.flush();
    // En disco, quitar una clave deja un registro histórico hasta compactar.
    // El presupuesto de cinco no debe acumular los viajes descartados en el log.
    if (excess > 0 || existing != null) await _voyages.compact();
  });

  VesselVoyage? getVoyageById(String id) {
    final record = _voyages.get(id);
    return record == null ? null : _codec.decodeVoyage(record);
  }

  int _savedOrder(String record) =>
      (jsonDecode(record) as Map<String, dynamic>)['savedOrder'] as int? ?? 0;

  List<String> _orderedKeys() {
    final orders = {for (final key in _voyages.keys.cast<String>())
      key: _savedOrder(_voyages.get(key)!)};
    return orders.keys.toList()..sort((a, b) {
      final order = orders[a]!.compareTo(orders[b]!);
      return order == 0 ? a.compareTo(b) : order;
    });
  }

  List<VesselVoyage> getAllVoyages() => _orderedKeys().reversed
      .map((key) => _codec.decodeVoyage(_voyages.get(key)!)).toList();

  Future<void> deleteVoyage(String id) => _writeVoyages(() async {
    await _voyages.delete(id);
    await _voyages.flush();
    await _voyages.compact();
  });

  Future<void> saveProfile(VesselProfile profile) async {
    await _profiles.put(profile.key, _codec.encodeProfile(profile));
    await _profiles.flush();
  }

  List<VesselProfile> getAllProfiles() =>
      _profiles.values.map(_codec.decodeProfile).toList();

  Future<void> close() async {
    await _voyageWrites;
    try {
      await _voyages.close();
    } finally {
      await _profiles.close();
    }
  }
}
