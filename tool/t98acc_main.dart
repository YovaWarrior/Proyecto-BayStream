// Aceptación de T-98 (Timonel): UI real con repositorios t98acc, sin sesión.
// Android usa la app [DEFAULT], igual que lib/main.dart: la carpeta privada
// del paquete .t98acc es nueva y no trae sesión. Windows usa la app con nombre
// t98acc para no recuperar una sesión de otra BayStream de esta laptop.
import 'dart:async';

import 'package:baystream/core/app.dart';
import 'package:baystream/features/vessel/data/datasources/hive_movement_data_source.dart';
import 'package:baystream/features/vessel/data/datasources/hive_vessel_data_source.dart';
import 'package:baystream/features/vessel/data/datasources/local_store_directory.dart';
import 'package:baystream/features/vessel/data/repositories/firebase_session_repository.dart';
import 'package:baystream/features/vessel/data/repositories/firestore_operation_sync.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_impl.dart';
import 'package:baystream/features/vessel/data/repositories/movement_log_repository_impl.dart';
import 'package:baystream/features/vessel/data/repositories/vessel_repository_impl.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _namespace = 't98acc';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final windows =
      !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
  // Windows no abre cajas en el almacén real: la ruta tiene que ser de TEMP.
  const temporary = String.fromEnvironment('T98ACC_WINDOWS_STORE');
  if (windows && !RegExp(r'[/\\]Temp[/\\]').hasMatch(temporary)) {
    throw StateError('T98ACC_WINDOWS_STORE debe apuntar a TEMP.');
  }
  final directory =
      kIsWeb ? null : (windows ? temporary : await localStoreDirectory());
  const options = FirebaseOptions(
      apiKey: String.fromEnvironment('FIREBASE_ANDROID_API_KEY'),
      appId: String.fromEnvironment('FIREBASE_ANDROID_APP_ID'),
      messagingSenderId:
          String.fromEnvironment('FIREBASE_ANDROID_MESSAGING_SENDER_ID'),
      projectId: String.fromEnvironment('FIREBASE_ANDROID_PROJECT_ID'),
      storageBucket: String.fromEnvironment('FIREBASE_ANDROID_STORAGE_BUCKET'));
  if (kIsWeb || options.projectId != 'baystream-app') {
    throw StateError('T98ACC compila Android o Windows con la configuración '
        'autorizada de BayStream.');
  }
  final app = windows
      ? await Firebase.initializeApp(name: _namespace, options: options)
      : await Firebase.initializeApp(options: options);
  final database = FirebaseFirestore.instanceFor(app: app);
  final auth = FirebaseAuth.instanceFor(app: app);
  // Solo estado booleano: nunca imprimir correo, UID ni datos de la sesión.
  debugPrint('T98ACC app=${app.name}; '
      'sesionInicial=${auth.currentUser == null ? "ausente" : "presente"}');
  runApp(ProviderScope(overrides: [
    vesselRepositoryProvider
        .overrideWith((ref) => VesselRepositoryImpl(firestore: database)),
    localVesselRepositoryProvider.overrideWith((ref) async {
      final repo = LocalVesselRepositoryImpl(await HiveVesselDataSource.open(
          directory: directory, namespace: _namespace));
      ref.onDispose(() => unawaited(repo.close()));
      return repo;
    }),
    movementLogRepositoryProvider.overrideWith((ref) async {
      final repo = MovementLogRepositoryImpl(await HiveMovementDataSource.open(
          directory: directory, namespace: _namespace));
      ref.onDispose(() => unawaited(repo.close()));
      return repo;
    }),
    sessionRepositoryProvider.overrideWith((ref) async {
      final repo = FirebaseSessionRepository(
          auth,
          database,
          await HiveLastOperatorStore.open(
              directory: directory, namespace: _namespace));
      ref.onDispose(() => unawaited(repo.dispose()));
      return repo;
    }),
    operationSyncProvider.overrideWith((ref) async {
      final log = await ref.watch(movementLogRepositoryProvider.future);
      final session = await ref.watch(sessionRepositoryProvider.future);
      final sync = FirestoreOperationSync(database, log, session);
      ref.onDispose(() => unawaited(sync.dispose()));
      return sync;
    }),
  ], child: const BayStreamApp()));
}
