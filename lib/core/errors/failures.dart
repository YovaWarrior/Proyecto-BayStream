import 'package:equatable/equatable.dart';

/// Clase base abstracta para representar fallos en la aplicación
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Fallo durante el parsing de archivos BAPLIE
class BaplieParsingFailure extends Failure {
  final int? lineNumber;
  final String? segment;

  const BaplieParsingFailure({
    required super.message,
    super.code,
    this.lineNumber,
    this.segment,
  });

  @override
  List<Object?> get props => [message, code, lineNumber, segment];

  @override
  String toString() {
    final buffer = StringBuffer('BaplieParsingFailure: $message');
    if (lineNumber != null) buffer.write(' (línea: $lineNumber)');
    if (segment != null) buffer.write(' [segmento: $segment]');
    return buffer.toString();
  }
}

/// Fallo de validación de datos
class ValidationFailure extends Failure {
  final String field;

  const ValidationFailure({
    required super.message,
    required this.field,
    super.code,
  });

  @override
  List<Object?> get props => [message, code, field];
}

/// Fallo de Firebase/Firestore
class FirestoreFailure extends Failure {
  const FirestoreFailure({
    required super.message,
    super.code,
  });
}

/// Fallo genérico del servidor
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
  });
}

/// Fallo de caché local
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
  });
}
