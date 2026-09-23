import 'dart:convert';

import '../../domain/entities/entities.dart';

/// Esquema compartido por las dos colecciones del almacén local.
class LocalVesselCodec {
  static const int schemaVersion = 1;

  const LocalVesselCodec();

  String encodeVoyage(VesselVoyage voyage) =>
      _encode(voyage.toJson(includeBays: false));

  VesselVoyage decodeVoyage(String record) =>
      VesselVoyage.fromJson(_decode(record));

  String encodeProfile(VesselProfile profile) => _encode(profile.toJson());

  VesselProfile decodeProfile(String record) =>
      VesselProfile.fromJson(_decode(record));

  String _encode(Map<String, dynamic> data) => jsonEncode({
        'schemaVersion': schemaVersion,
        'data': data,
      });

  Map<String, dynamic> _decode(String record) {
    final json = jsonDecode(record) as Map<String, dynamic>;
    // Ausencia equivale a v1; una versión desconocida no se interpreta a ciegas.
    final version =
        json.containsKey('schemaVersion') ? json['schemaVersion'] : 1;
    if (version is! int || version != schemaVersion) {
      throw FormatException('Versión de almacén local no admitida: $version');
    }
    // También admite un documento v1 sin envoltura, como los JSON históricos.
    return json.containsKey('data')
        ? json['data'] as Map<String, dynamic>
        : json;
  }
}
