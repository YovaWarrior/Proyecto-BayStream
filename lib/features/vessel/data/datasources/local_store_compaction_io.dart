import 'dart:io';

/// Hive reabre el archivo original si falla el renombrado de su copia compacta.
/// Windows puede denegar ese renombrado brevemente aunque ya cerrara Hive sus
/// handles. Se reintenta solo la compactación, sin repetir ni omitir guardados.
Future<void> compactLocalStore(Future<void> Function() compact) async {
  for (var attempt = 0; ; attempt++) {
    try {
      await compact();
      return;
    } on FileSystemException catch (error) {
      if (!Platform.isWindows || error.osError?.errorCode != 5 || attempt == 4) {
        rethrow;
      }
      await Future<void>.delayed(Duration(milliseconds: 25 * (1 << attempt)));
    }
  }
}
