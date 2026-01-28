/// Excepción base para errores de la aplicación
class BayStreamException implements Exception {
  final String message;
  final String? code;

  const BayStreamException({required this.message, this.code});

  @override
  String toString() => 'BayStreamException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Excepción durante el parsing de archivos BAPLIE
class BaplieParsingException extends BayStreamException {
  final int? lineNumber;
  final String? segment;

  const BaplieParsingException({
    required super.message,
    super.code,
    this.lineNumber,
    this.segment,
  });

  @override
  String toString() {
    final buffer = StringBuffer('BaplieParsingException: $message');
    if (lineNumber != null) buffer.write(' (línea: $lineNumber)');
    if (segment != null) buffer.write(' [segmento: $segment]');
    return buffer.toString();
  }
}

/// Excepción de validación
class ValidationException extends BayStreamException {
  final String field;

  const ValidationException({
    required super.message,
    required this.field,
    super.code,
  });

  @override
  String toString() => 'ValidationException: Campo "$field" - $message';
}

/// Excepción de formato de coordenada ISO inválida
class InvalidIsoCoordinateException extends BayStreamException {
  final String coordinate;

  const InvalidIsoCoordinateException({
    required this.coordinate,
  }) : super(message: 'Coordenada ISO inválida: $coordinate');

  @override
  String toString() => 'InvalidIsoCoordinateException: "$coordinate" no cumple formato BBBRRTT';
}

/// Excepción de servidor/Firebase
class ServerException extends BayStreamException {
  const ServerException({
    required super.message,
    super.code,
  });
}

/// Excepción de caché
class CacheException extends BayStreamException {
  const CacheException({
    required super.message,
    super.code,
  });
}
