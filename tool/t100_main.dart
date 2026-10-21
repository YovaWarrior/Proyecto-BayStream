// T-100 · La app del producto con el namespace t100, para el manual de usuario.
//
// Es la interfaz de lib/ sin tocarla (BayStreamApp), con almacenes propios
// t100 y, con T100_FIREBASE=true, Firebase inicializado como lib/main.dart
// pero en una app aparte llamada «t100», que no recupera la sesión de nadie.
// El manual se escribe sin sesión: si la app t100 trajera una, se detiene.
// En Windows el almacén va en %TEMP% (T100_WINDOWS_STORE): el almacén real
// no se abre ni se crean cajas dentro (10.88). En Android, la carpeta privada
// del paquete .t100; en la Web, el IndexedDB del origen local.
//
//   flutter build windows --release -t tool/t100_main.dart --dart-define=T100_FIREBASE=true
//     --dart-define-from-file=<configuración privada> --dart-define=T100_WINDOWS_STORE=<%TEMP%\...>
//   flutter build web --release --no-web-resources-cdn -t tool/t100_main.dart ...
//   flutter build apk --release -t tool/t100_main.dart ...   (sin --no-pub)
import 'dart:async';

import 'package:baystream/core/app.dart';
import 'package:baystream/features/vessel/data/datasources/hive_movement_data_source.dart';
import 'package:baystream/features/vessel/data/datasources/hive_vessel_data_source.dart';
import 'package:baystream/features/vessel/data/datasources/local_store_directory.dart';
import 'package:baystream/features/vessel/data/repositories/firebase_session_repository.dart';
import 'package:baystream/features/vessel/data/repositories/firestore_operation_sync.dart';
import 'package:baystream/features/vessel/data/repositories/local_only_operation_sync.dart';
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

/// El namespace de los almacenes del manual (ficha de T-100, «Las capturas»).
const t100Namespace = 't100';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const temporary = String.fromEnvironment('T100_WINDOWS_STORE');
  if (!kIsWeb &&
      defaultTargetPlatform == TargetPlatform.windows &&
      !RegExp(r'[/\\]Temp[/\\]').hasMatch(temporary)) {
    throw StateError('T100_WINDOWS_STORE debe apuntar a TEMP (10.88).');
  }
  final directory = kIsWeb
      ? null
      : defaultTargetPlatform == TargetPlatform.windows
          ? temporary
          : await localStoreDirectory();
  const configured = bool.fromEnvironment('T100_FIREBASE');
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
    // La misma elección que lib/main.dart: la Web usa sus opciones; Windows
    // y Android, las de Android.
    const options = kIsWeb ? web : android;
    if (options.projectId != 'baystream-app') {
      throw StateError('T-100 requiere la configuración autorizada de BayStream.');
    }
    app = await Firebase.initializeApp(name: 't100', options: options);
  }
  final database = app == null ? null : FirebaseFirestore.instanceFor(app: app);
  final auth = app == null ? null : FirebaseAuth.instanceFor(app: app);
  // Solo estado booleano: nunca correo, UID ni datos de la sesión.
  debugPrint('T100 Firebase=$configured; '
      'sesionInicial=${auth?.currentUser == null ? "ausente" : "presente"}');
  if (auth?.currentUser != null) {
    throw StateError('T-100 se escribe sin sesión y la app t100 trae una: detente y avisa.');
  }
  runApp(ProviderScope(overrides: [
    vesselRepositoryProvider.overrideWith(
        (ref) => VesselRepositoryImpl(firestore: database ?? _NoCloud())),
    localVesselRepositoryProvider.overrideWith((ref) async {
      final repo = LocalVesselRepositoryImpl(await HiveVesselDataSource.open(
          directory: directory, namespace: t100Namespace));
      ref.onDispose(() => unawaited(repo.close()));
      return repo;
    }),
    movementLogRepositoryProvider.overrideWith((ref) async {
      final repo = MovementLogRepositoryImpl(await HiveMovementDataSource.open(
          directory: directory, namespace: t100Namespace));
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
              directory: directory, namespace: t100Namespace));
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

/// Sin Firebase, el repositorio real solo usa su lectura. Una llamada remota
/// accidental falla de inmediato; no se simula la red.
class _NoCloud implements FirebaseFirestore {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('T-100 sin Firebase no admite acceso remoto.');
}
