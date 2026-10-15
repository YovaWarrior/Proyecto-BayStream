import 'dart:io';

import 'package:baystream/features/vessel/data/datasources/local_store_directory.dart';
import 'package:baystream/features/vessel/data/datasources/local_store_compaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  if (Platform.isWindows) {
    test('T-104 compactación recupera acceso denegado transitorio', () async {
      var attempts = 0;
      await compactLocalStore(() async {
        if (++attempts < 3) {
          throw const FileSystemException('rename', '', OSError('denegado', 5));
        }
      });
      expect(attempts, 3);
    });

    test('T-104 compactación propaga acceso denegado persistente', () async {
      var attempts = 0;
      const failure = FileSystemException('rename', '', OSError('denegado', 5));
      await expectLater(compactLocalStore(() async {
        attempts++;
        throw failure;
      }), throwsA(same(failure)));
      expect(attempts, 5);
    });

    test('T-104 compactación propaga otro error de disco sin reintentar', () async {
      var attempts = 0;
      const failure = FileSystemException('rename', '', OSError('no existe', 2));
      await expectLater(compactLocalStore(() async {
        attempts++;
        throw failure;
      }), throwsA(same(failure)));
      expect(attempts, 1);
    });

    test('T-104 compactación propaga errores ajenos al sistema de archivos', () async {
      var attempts = 0;
      final failure = StateError('caja cerrada');
      await expectLater(compactLocalStore(() async {
        attempts++;
        throw failure;
      }), throwsA(same(failure)));
      expect(attempts, 1);
    });

    test('T-104 flutter test bloquea el almacén real de Windows', () async {
      expect(Platform.environment['FLUTTER_TEST'], 'true');
      await expectLater(
          localStoreDirectory(),
          throwsA(isA<StateError>().having(
              (e) => e.message,
              'mensaje de aislamiento',
              allOf(
                  contains('FLUTTER_TEST=true'),
                  contains('movementLogRepositoryProvider'),
                  contains('directorio temporal')))));
    });
  }
}
