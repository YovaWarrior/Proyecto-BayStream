import 'package:hive_ce/hive.dart';

import '../../domain/entities/entities.dart';
import 'local_vessel_codec.dart';

/// Dos cajas del mismo motor: perfiles por clave natural y viajes por UUID.
class HiveVesselDataSource {
  final Box<String> _profiles;
  final Box<String> _voyages;
  final LocalVesselCodec _codec = const LocalVesselCodec();

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

  Future<void> saveVoyage(VesselVoyage voyage) async {
    await _voyages.put(voyage.id, _codec.encodeVoyage(voyage));
    await _voyages.flush();
  }

  VesselVoyage? getVoyageById(String id) {
    final record = _voyages.get(id);
    return record == null ? null : _codec.decodeVoyage(record);
  }

  List<VesselVoyage> getAllVoyages() =>
      _voyages.values.map(_codec.decodeVoyage).toList();

  Future<void> deleteVoyage(String id) async {
    await _voyages.delete(id);
    await _voyages.flush();
  }

  Future<void> saveProfile(VesselProfile profile) async {
    await _profiles.put(profile.key, _codec.encodeProfile(profile));
    await _profiles.flush();
  }

  List<VesselProfile> getAllProfiles() =>
      _profiles.values.map(_codec.decodeProfile).toList();

  Future<void> close() async {
    try {
      await _voyages.close();
    } finally {
      await _profiles.close();
    }
  }
}
