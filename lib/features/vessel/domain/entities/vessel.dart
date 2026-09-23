import 'package:equatable/equatable.dart';

/// Entidad que representa un buque/barco
/// 
/// Datos extraídos del segmento TDT del BAPLIE:
/// - Nombre del barco: c222.e8212
/// - Número de viaje: e8028
class Vessel extends Equatable {
  /// Identificador único interno
  final String id;
  
  /// Nombre del buque (ID Transporte desde TDT c222.e8212)
  final String name;
  
  /// Código IMO del buque (si está disponible)
  final String? imoNumber;
  
  /// Código de llamada del buque
  final String? callSign;
  
  /// Bandera/país de registro
  final String? flag;
  
  /// Operador/naviera
  final String? operator;

  const Vessel({
    required this.id,
    required this.name,
    this.imoNumber,
    this.callSign,
    this.flag,
    this.operator,
  });

  /// Identidad persistente independiente del UUID de este objeto.
  VesselIdentity get profileIdentity => VesselIdentity.fromVesselData(
        name: name,
        imoNumber: imoNumber,
        callSign: callSign,
      );

  String get profileKey => profileIdentity.key;

  /// Un nombre compartido propone una pregunta, nunca una asociación automática.
  VesselIdentityMatch matchIdentity(Vessel other) {
    if (profileIdentity.matchesAutomatically(other.profileIdentity)) {
      return VesselIdentityMatch.automatic;
    }
    return VesselIdentity.normalizeName(name) ==
            VesselIdentity.normalizeName(other.name)
        ? VesselIdentityMatch.requiresConfirmation
        : VesselIdentityMatch.none;
  }

  @override
  List<Object?> get props => [id, name, imoNumber, callSign, flag, operator];

  Vessel copyWith({
    String? id,
    String? name,
    String? imoNumber,
    String? callSign,
    String? flag,
    String? operator,
  }) {
    return Vessel(
      id: id ?? this.id,
      name: name ?? this.name,
      imoNumber: imoNumber ?? this.imoNumber,
      callSign: callSign ?? this.callSign,
      flag: flag ?? this.flag,
      operator: operator ?? this.operator,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (imoNumber != null) 'imoNumber': imoNumber,
        if (callSign != null) 'callSign': callSign,
        if (flag != null) 'flag': flag,
        if (operator != null) 'operator': operator,
      };

  factory Vessel.fromJson(Map<String, dynamic> json) => Vessel(
        id: json['id'] as String,
        name: json['name'] as String,
        imoNumber: json['imoNumber'] as String?,
        callSign: json['callSign'] as String?,
        flag: json['flag'] as String?,
        operator: json['operator'] as String?,
      );

  @override
  String toString() => 'Vessel(name: $name, imo: $imoNumber)';
}

/// La procedencia forma parte de la clave: un indicativo no es un IMO.
enum VesselIdentitySource { imo, callSign, name }

enum VesselIdentityMatch { automatic, requiresConfirmation, none }

/// Clave natural seleccionada del TDT, serializable sin paquetes de datos.
class VesselIdentity extends Equatable {
  final VesselIdentitySource source;
  final String value;

  const VesselIdentity._(this.source, this.value);

  factory VesselIdentity({
    required VesselIdentitySource source,
    required String value,
  }) {
    final normalized = source == VesselIdentitySource.name
        ? normalizeName(value)
        : value.trim().toUpperCase();
    if (normalized.isEmpty) {
      throw ArgumentError.value(value, 'value', 'La identidad no puede estar vacía');
    }
    return VesselIdentity._(source, normalized);
  }

  factory VesselIdentity.fromVesselData({
    required String name,
    String? imoNumber,
    String? callSign,
  }) {
    if (imoNumber != null && imoNumber.trim().isNotEmpty) {
      return VesselIdentity(source: VesselIdentitySource.imo, value: imoNumber);
    }
    if (callSign != null && callSign.trim().isNotEmpty) {
      return VesselIdentity(source: VesselIdentitySource.callSign, value: callSign);
    }
    return VesselIdentity(source: VesselIdentitySource.name, value: name);
  }

  /// Conserva acentos y puntuación para no fusionar nombres por aproximación.
  static String normalizeName(String name) =>
      name.trim().replaceAll(RegExp(r'\s+'), ' ').toUpperCase();

  String get key => '${source.name}:$value';

  bool matchesAutomatically(VesselIdentity other) =>
      source != VesselIdentitySource.name && this == other;

  Map<String, dynamic> toJson() => {'source': source.name, 'value': value};

  factory VesselIdentity.fromJson(Map<String, dynamic> json) => VesselIdentity(
        source: VesselIdentitySource.values.byName(json['source'] as String),
        value: json['value'] as String,
      );

  @override
  List<Object?> get props => [source, value];
}
