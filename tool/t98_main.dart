// Entrada aislada: UI real, repositorios t98. Sin opciones = ensayo sin Firebase.
// En Fase B la condición A exige Firebase configurado y ninguna sesión iniciada.
import 'dart:async';

import 'package:baystream/core/app.dart';
import 'package:baystream/features/vessel/data/datasources/local_store_directory.dart';
import 'package:baystream/features/vessel/data/repositories/firebase_session_repository.dart';
import 'package:baystream/features/vessel/data/repositories/firestore_operation_sync.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_factory.dart';
import 'package:baystream/features/vessel/data/repositories/local_only_operation_sync.dart';
import 'package:baystream/features/vessel/data/repositories/vessel_repository_impl.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const configured = bool.fromEnvironment('T98_FIREBASE');
  FirebaseApp? app;
  if (configured) {
    const web = FirebaseOptions(
        apiKey: String.fromEnvironment('FIREBASE_WEB_API_KEY'),
        appId: String.fromEnvironment('FIREBASE_WEB_APP_ID'),
        messagingSenderId:
            String.fromEnvironment('FIREBASE_WEB_MESSAGING_SENDER_ID'),
        projectId: String.fromEnvironment('FIREBASE_WEB_PROJECT_ID'),
        authDomain: String.fromEnvironment('FIREBASE_WEB_AUTH_DOMAIN'),
        storageBucket: String.fromEnvironment('FIREBASE_WEB_STORAGE_BUCKET'));
    const android = FirebaseOptions(
        apiKey: String.fromEnvironment('FIREBASE_ANDROID_API_KEY'),
        appId: String.fromEnvironment('FIREBASE_ANDROID_APP_ID'),
        messagingSenderId:
            String.fromEnvironment('FIREBASE_ANDROID_MESSAGING_SENDER_ID'),
        projectId: String.fromEnvironment('FIREBASE_ANDROID_PROJECT_ID'),
        storageBucket:
            String.fromEnvironment('FIREBASE_ANDROID_STORAGE_BUCKET'));
    const options = kIsWeb ? web : android;
    if (options.projectId != 'baystream-app') {
      throw StateError(
          'T-98 requiere la configuración autorizada de BayStream.');
    }
    app = await Firebase.initializeApp(name: 't98', options: options);
  }
  final database = app == null ? null : FirebaseFirestore.instanceFor(app: app);
  final auth = app == null ? null : FirebaseAuth.instanceFor(app: app);
  runApp(ProviderScope(overrides: [
    vesselRepositoryProvider.overrideWith(
        (ref) => VesselRepositoryImpl(firestore: database ?? _NoCloud())),
    localVesselRepositoryProvider.overrideWith((ref) async {
      final repo = await openLocalVesselRepository(namespace: 't98');
      ref.onDispose(() => unawaited(repo.close()));
      return repo;
    }),
    movementLogRepositoryProvider.overrideWith((ref) async {
      final repo = await openMovementLogRepository(namespace: 't98');
      ref.onDispose(() => unawaited(repo.close()));
      return repo;
    }),
    sessionRepositoryProvider.overrideWith((ref) async {
      if (database == null || auth == null) {
        return const LocalSessionRepository();
      }
      final repo = FirebaseSessionRepository(
          auth,
          database,
          await HiveLastOperatorStore.open(
              directory: await localStoreDirectory(), namespace: 't98'));
      ref.onDispose(() => unawaited(repo.dispose()));
      return repo;
    }),
    operationSyncProvider.overrideWith((ref) async {
      if (database == null) return const LocalOnlyOperationSync();
      final log = await ref.watch(movementLogRepositoryProvider.future);
      final session = await ref.watch(sessionRepositoryProvider.future);
      final sync = FirestoreOperationSync(database, log, session);
      ref.onDispose(() => unawaited(sync.dispose()));
      return sync;
    }),
  ], child: const BayStreamApp()));
}

/// En ensayo sin Firebase, el repositorio real solo usa su método de parseo.
/// Una llamada remota accidental falla de inmediato; no se simula éxito de red.
class _NoCloud implements FirebaseFirestore {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('El ensayo T98 sin Firebase no admite acceso remoto.');
}
