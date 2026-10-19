// Ronda del Honor del 19-oct (Timonel): el producto de 8d1bbb8 con su propia
// identidad y el namespace honor19, como t106cx.
//
// Arranca igual que lib/main.dart y muestra la misma app; solo cambian los
// tres almacenes locales, que van al namespace honor19. Firebase se inicializa
// porque el lector del producto lo pide (VesselRepositoryImpl toma
// FirebaseFirestore.instance), pero nadie inicia sesión: sin cuenta la sesión
// no consulta Firestore y una operación local no se sincroniza.
// Se compila desde una copia en %TEMP%, con -t tool/honor19_main.dart, el
// applicationId gt.cmartinez.baystream.honor19 y la configuración por
// --dart-define-from-file, sin abrirla.
import 'dart:async';

import 'package:baystream/core/app.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_factory.dart';
import 'package:baystream/features/vessel/data/repositories/operation_sync_factory.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _namespace = 'honor19';

const _android = FirebaseOptions(
  apiKey: String.fromEnvironment('FIREBASE_ANDROID_API_KEY'),
  appId: String.fromEnvironment('FIREBASE_ANDROID_APP_ID'),
  messagingSenderId:
      String.fromEnvironment('FIREBASE_ANDROID_MESSAGING_SENDER_ID'),
  projectId: String.fromEnvironment('FIREBASE_ANDROID_PROJECT_ID'),
  storageBucket: String.fromEnvironment('FIREBASE_ANDROID_STORAGE_BUCKET'),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
    throw StateError('honor19 es solo para el Honor.');
  }
  if (_android.projectId != 'baystream-app') {
    throw StateError('Solo baystream-app.');
  }
  await Firebase.initializeApp(options: _android);
  runApp(ProviderScope(overrides: [
    localVesselRepositoryProvider.overrideWith((ref) async {
      final repo = await openLocalVesselRepository(namespace: _namespace);
      ref.onDispose(() => unawaited(repo.close()));
      return repo;
    }),
    movementLogRepositoryProvider.overrideWith((ref) async {
      final repo = await openMovementLogRepository(namespace: _namespace);
      ref.onDispose(() => unawaited(repo.close()));
      return repo;
    }),
    sessionRepositoryProvider.overrideWith((ref) async {
      final repo = await openSessionRepository(namespace: _namespace);
      ref.onDispose(() => unawaited(repo.dispose()));
      return repo;
    }),
  ], child: const BayStreamApp()));
}
