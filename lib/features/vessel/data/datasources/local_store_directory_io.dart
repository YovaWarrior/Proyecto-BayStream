import 'dart:io';

import 'package:flutter/services.dart';

/// Directorio persistente propio. Nunca usa temporales ni el directorio de trabajo.
Future<String> localStoreDirectory() async {
  late final String root;
  if (Platform.isAndroid) {
    final path = await const MethodChannel('baystream/local_store')
        .invokeMethod<String>('filesDirectory');
    if (path == null || path.isEmpty) {
      throw StateError('Android no devolvió el directorio privado');
    }
    root = path;
  } else if (Platform.isWindows) {
    if (Platform.environment['FLUTTER_TEST'] == 'true') {
      throw StateError('El almacén real de Windows está bloqueado bajo flutter test '
          '(FLUTTER_TEST=true). Sobrescribe localVesselRepositoryProvider y '
          'movementLogRepositoryProvider con un directorio temporal.');
    }
    final path = Platform.environment['LOCALAPPDATA'];
    if (path == null || path.isEmpty) {
      throw StateError('Windows no tiene LOCALAPPDATA');
    }
    root = '$path/BayStream';
  } else {
    throw UnsupportedError('Plataforma sin almacén local configurado');
  }
  return (await Directory('$root/vessel_store').create(recursive: true)).path;
}
