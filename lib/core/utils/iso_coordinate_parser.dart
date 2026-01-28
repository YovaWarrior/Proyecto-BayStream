import '../errors/exceptions.dart';

/// Resultado del parsing de coordenadas ISO BBBRRTT
class IsoCoordinate {
  /// Número de bahía (Bay) - 3 dígitos, valor 001-999
  final int bay;
  
  /// Número de fila (Row) - 2 dígitos, valor 00-99
  final int row;
  
  /// Número de altura/nivel (Tier) - 2 dígitos, valor 00-99
  final int tier;
  
  /// Coordenada original sin procesar
  final String rawCode;

  const IsoCoordinate({
    required this.bay,
    required this.row,
    required this.tier,
    required this.rawCode,
  });

  /// Devuelve la coordenada en formato legible: "Bay 12, Row 00, Tier 06"
  String get displayFormat => 'Bay $bayPadded, Row $rowPadded, Tier $tierPadded';

  /// Bay con padding de 3 dígitos
  String get bayPadded => bay.toString().padLeft(3, '0');
  
  /// Row con padding de 2 dígitos
  String get rowPadded => row.toString().padLeft(2, '0');
  
  /// Tier con padding de 2 dígitos
  String get tierPadded => tier.toString().padLeft(2, '0');

  /// Reconstruye el código ISO de 7 dígitos
  String toIsoCode() => '$bayPadded$rowPadded$tierPadded';

  @override
  String toString() => 'IsoCoordinate($displayFormat)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IsoCoordinate &&
          bay == other.bay &&
          row == other.row &&
          tier == other.tier;

  @override
  int get hashCode => Object.hash(bay, row, tier);

  Map<String, dynamic> toJson() => {
        'bay': bay,
        'row': row,
        'tier': tier,
        'rawCode': rawCode,
      };

  factory IsoCoordinate.fromJson(Map<String, dynamic> json) => IsoCoordinate(
        bay: json['bay'] as int,
        row: json['row'] as int,
        tier: json['tier'] as int,
        rawCode: json['rawCode'] as String,
      );
}

/// Parser de coordenadas ISO según estándar BAPLIE 2.2.1
/// 
/// Formato estricto: BBBRRTT
/// - BBB: Bay (Bahía) - 3 dígitos
/// - RR: Row (Fila) - 2 dígitos  
/// - TT: Tier (Altura/Nivel) - 2 dígitos
/// 
/// Ejemplo: "0120006" -> Bay: 12, Row: 00, Tier: 06
class IsoCoordinateParser {
  IsoCoordinateParser._();

  /// Longitud exacta requerida para coordenada ISO
  static const int isoCoordinateLength = 7;

  /// Parsea una coordenada ISO de 7 dígitos (BBBRRTT)
  /// 
  /// Lanza [InvalidIsoCoordinateException] si el formato es inválido.
  /// 
  /// ```dart
  /// final coord = IsoCoordinateParser.parse('0120006');
  /// print(coord.bay);  // 12
  /// print(coord.row);  // 0
  /// print(coord.tier); // 6
  /// ```
  static IsoCoordinate parse(String code) {
    final trimmed = code.trim();
    
    // Validar longitud
    if (trimmed.length != isoCoordinateLength) {
      throw InvalidIsoCoordinateException(coordinate: code);
    }
    
    // Validar que solo contenga dígitos
    if (!RegExp(r'^\d{7}$').hasMatch(trimmed)) {
      throw InvalidIsoCoordinateException(coordinate: code);
    }

    final bay = int.parse(trimmed.substring(0, 3));
    final row = int.parse(trimmed.substring(3, 5));
    final tier = int.parse(trimmed.substring(5, 7));

    return IsoCoordinate(
      bay: bay,
      row: row,
      tier: tier,
      rawCode: trimmed,
    );
  }

  /// Intenta parsear una coordenada ISO, retorna null si falla
  static IsoCoordinate? tryParse(String code) {
    try {
      return parse(code);
    } catch (_) {
      return null;
    }
  }

  /// Valida si un código cumple el formato ISO BBBRRTT
  static bool isValid(String code) {
    final trimmed = code.trim();
    return trimmed.length == isoCoordinateLength && 
           RegExp(r'^\d{7}$').hasMatch(trimmed);
  }

  /// Crea una coordenada ISO a partir de valores individuales
  static IsoCoordinate fromValues({
    required int bay,
    required int row,
    required int tier,
  }) {
    if (bay < 0 || bay > 999) {
      throw const InvalidIsoCoordinateException(coordinate: 'Bay fuera de rango (0-999)');
    }
    if (row < 0 || row > 99) {
      throw const InvalidIsoCoordinateException(coordinate: 'Row fuera de rango (0-99)');
    }
    if (tier < 0 || tier > 99) {
      throw const InvalidIsoCoordinateException(coordinate: 'Tier fuera de rango (0-99)');
    }

    final rawCode = '${bay.toString().padLeft(3, '0')}'
        '${row.toString().padLeft(2, '0')}'
        '${tier.toString().padLeft(2, '0')}';

    return IsoCoordinate(
      bay: bay,
      row: row,
      tier: tier,
      rawCode: rawCode,
    );
  }
}

/// Función auxiliar de conveniencia para parsear coordenadas ISO
/// 
/// Uso directo según especificación del proyecto:
/// ```dart
/// final coord = parseIsoCoordinates('0120006');
/// // Bay: 12, Row: 00, Tier: 06
/// ```
IsoCoordinate parseIsoCoordinates(String code) => IsoCoordinateParser.parse(code);
