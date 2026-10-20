import 'package:flutter/foundation.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';

/// Conserva el fallo tipado sin convertirlo en texto de una excepción de Dart.
class VesselOperationFailure implements Exception {
  final Failure failure;
  const VesselOperationFailure(this.failure);
}

/// Errores esperados de secuencia que la interfaz puede explicar directamente.
class VesselActionRequired implements Exception {
  final String message;
  const VesselActionRequired(this.message);
}

/// Error que no es de un tipo conocido, cuando el llamador no nombra la
/// operación. El detalle técnico va al registro (T-112).
const unknownVesselErrorMessage =
    'No se pudo completar la operación por un error interno de la aplicación; '
    'el detalle técnico quedó en el registro. Inténtalo de nuevo y, si se '
    'repite, reinicia la aplicación.';

/// El mismo mensaje, con la operación que falló si el llamador la nombra
/// («abrir el viaje», «exportar PDF»): T-112, M001.
String unexpectedErrorMessage([String? operation]) => operation == null
    ? unknownVesselErrorMessage
    : 'No se pudo $operation por un error interno de la aplicación; el '
        'detalle técnico quedó en el registro. Inténtalo de nuevo y, si se '
        'repite, reinicia la aplicación.';

/// T-112, M099: la operación que pide el formulario no está lista todavía.
const operationUnavailable = 'La operación todavía no se cargó o cambió '
    'mientras tanto: espera un momento e inténtalo de nuevo.';

const notBaplieFileMessage =
    'Este archivo no parece un BAPLIE: no se reconoce su cabecera UNH/S009. '
    'Selecciona una exportación BAPLIE completa.';

/// [operation] dice qué se intentaba hacer, para los fallos que no traen un
/// texto propio (T-112).
String vesselFailureMessage(Failure failure, [String? operation]) {
  if (failure is BaplieParsingFailure) {
    // T-112, M004: el lector nombra el segmento que leía cuando falló.
    if (failure.code == BaplieParsingException.unexpectedSegment &&
        failure.segment != null) {
      final segment = failure.segment!;
      final where = failure.lineNumber != null
          ? 'el segmento $segment (n.º ${failure.lineNumber} del archivo)'
          : segment.contains(' y ')
              ? 'los segmentos $segment'
              : 'el segmento $segment';
      return 'No se pudo interpretar $where del BAPLIE: trae un dato que el '
          'lector no esperaba. Revisa ese segmento en el archivo o pide una '
          'nueva exportación.';
    }
    if (failure.message.contains('sin UNH/S009 reconocible') ||
        failure.message.contains('vacío') ||
        failure.message.contains('segmentos válidos')) {
      return notBaplieFileMessage;
    }
    if (failure.code == 'unsupported_baplie_version') return failure.message;
    if (failure.segment == 'TDT' ||
        failure.message.contains('nombre del buque')) {
      return 'El archivo no trae el nombre del buque en el segmento TDT. '
          'Revisa que sea un BAPLIE completo o pide una nueva exportación.';
    }
    debugPrint('Fallo de análisis BAPLIE: ${failure.message}');
    return 'No se pudo interpretar el archivo BAPLIE: el lector falló antes de '
        'llegar a sus segmentos; el detalle técnico quedó en el registro. '
        'Revisa que sea un archivo EDIFACT completo o pide una nueva exportación.';
  }
  if (failure is CacheFailure) {
    if (failure.code == 'profile_confirmation_required') {
      return 'Hay un perfil con el mismo nombre y no se puede identificar el buque. '
          'Confirma su identidad antes de guardar.';
    }
    debugPrint('Fallo del almacén local: ${failure.message}');
    // T-112, M006: qué se intentaba y qué falló.
    return 'No se pudo ${operation ?? 'completar la operación'}: falló la '
        'lectura o la escritura de los datos guardados en este dispositivo. '
        'Inténtalo de nuevo y, si se repite, reinicia la aplicación.';
  }
  debugPrint('Fallo de operación de buque: ${failure.message}');
  return unexpectedErrorMessage(operation);
}

/// [operation] dice qué se intentaba hacer («abrir el viaje»), para los
/// errores que no traen un texto propio (T-112).
String vesselErrorMessage(Object error, [StackTrace? stack, String? operation]) {
  if (error is VesselOperationFailure) {
    return vesselFailureMessage(error.failure, operation);
  }
  if (error is VesselActionRequired) return error.message;
  // T-79 · Un aviso de dominio escrito para el usuario, como el de las
  // fuentes de una operación publicada (OperationSources.save).
  if (error is ValidationFailure) return error.message;
  debugPrint('Error de operación de buque: $error\n$stack');
  return unexpectedErrorMessage(operation);
}
