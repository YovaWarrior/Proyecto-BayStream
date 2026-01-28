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
