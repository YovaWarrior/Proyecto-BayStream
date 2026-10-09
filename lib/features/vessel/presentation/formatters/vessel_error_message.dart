import 'package:flutter/foundation.dart';

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

const unknownVesselErrorMessage =
    'No se pudo completar la operación por un error inesperado. '
    'Inténtalo de nuevo; si persiste, reinicia la aplicación.';

String vesselFailureMessage(Failure failure) {
  if (failure is BaplieParsingFailure) {
    if (failure.segment == 'TDT' ||
        failure.message.contains('nombre del buque')) {
      return 'El archivo no trae el nombre del buque en el segmento TDT. '
          'Revisa que sea un BAPLIE completo o pide una nueva exportación.';
    }
    if (failure.message.contains('vacío')) {
      return 'El archivo BAPLIE está vacío. Selecciona un archivo con datos e inténtalo de nuevo.';
    }
    if (failure.message.contains('segmentos válidos')) {
      return 'El archivo no contiene segmentos BAPLIE válidos. '
          'Revisa el formato o pide una nueva exportación.';
    }
    debugPrint('Fallo de análisis BAPLIE: ${failure.message}');
    return 'No se pudo interpretar el archivo BAPLIE. '
        'Revisa su formato o pide una nueva exportación.';
  }
  if (failure is CacheFailure) {
    if (failure.code == 'profile_confirmation_required') {
      return 'Hay un perfil con el mismo nombre y no se puede identificar el buque. '
          'Confirma su identidad antes de guardar.';
    }
    debugPrint('Fallo del almacén local: ${failure.message}');
    return 'No se pudo acceder a los datos guardados en este dispositivo. '
        'Inténtalo de nuevo; si persiste, reinicia la aplicación.';
  }
  debugPrint('Fallo de operación de buque: ${failure.message}');
  return unknownVesselErrorMessage;
}

String vesselErrorMessage(Object error, [StackTrace? stack]) {
  if (error is VesselOperationFailure) {
    return vesselFailureMessage(error.failure);
  }
  if (error is VesselActionRequired) return error.message;
  // T-79 · Un aviso de dominio escrito para el usuario, como el de las
  // fuentes de una operación publicada (OperationSources.save).
  if (error is ValidationFailure) return error.message;
  debugPrint('Error de operación de buque: $error\n$stack');
  return unknownVesselErrorMessage;
}
