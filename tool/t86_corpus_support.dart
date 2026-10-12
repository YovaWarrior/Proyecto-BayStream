import 'package:baystream/core/errors/exceptions.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';

/// Los recorridos históricos conservan A06 como prueba de rechazo de entrada.
String requireA06Rejection(String source) {
  try {
    BaplieParserService().parse(source);
  } on BaplieParsingException catch (error) {
    if (error.code == 'unsupported_baplie_version' &&
        error.segment == 'UNH' &&
        error.message.contains('BAPLIE:1:911:UN:SMDG15') &&
        error.message.contains('familia 2.x')) {
      return error.message;
    }
    rethrow;
  }
  throw StateError('A06 debe rechazarse antes de leer su carga.');
}
