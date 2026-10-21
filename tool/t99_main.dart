// T-99 · Banco de medición: la interfaz del producto con el namespace t99. Se
// compila en release desde una copia temporal del commit medido
// (tool/t99_copia.ps1), nunca sobre los binarios de otra tarea:
//   flutter build windows --release --no-pub -t tool/t99_main.dart --dart-define=T99_ALMACEN=<carpeta en %TEMP%>
//   flutter build web --release --no-pub -t tool/t99_main.dart
//   flutter build apk --release -t tool/t99_main.dart
// El APK va SIN --no-pub: con integration_test entre las dependencias de
// desarrollo, solo así Flutter regenera GeneratedPluginRegistrant para
// release sin ese plugin (flutter#162649); con --no-pub no compila.
//
// En Windows el almacén va en %TEMP% (T99_ALMACEN): el almacén real no se abre
// ni se crean cajas dentro (10.88). En Android, la carpeta privada del paquete
// .t99; en la Web, el IndexedDB del origen del banco.
//
// Con T99_FIREBASE=true es «el producto» para la RAM (10.86): inicializa
// Firebase como lib/main.dart, con la misma configuración, pero en una app de
// Firebase aparte llamada «t99», que no recupera la sesión de nadie. Sin
// sesión no se sincroniza nada; si la app t99 trajera una sesión, se detiene.
// Sin la opción, el banco no inicializa Firebase.
//
// Sin T99_ESCENARIO es la app para recorrerla a mano (anchos, entrada y el
// escenario de RAM con el selector de archivos). Con T99_ESCENARIO=ram o
// anchos la recorre tool/t99_conductor.dart.
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
import 'package:baystream/features/vessel/domain/repositories/local_vessel_repository.dart';
import 'package:baystream/features/vessel/domain/repositories/movement_log_repository.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 't99_app.dart';
import 't99_conductor.dart';

const _almacen = String.fromEnvironment('T99_ALMACEN');
const _conFirebase = bool.fromEnvironment('T99_FIREBASE');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final windows = !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
  if (windows && !RegExp(r'[/\\]Temp[/\\]').hasMatch(_almacen)) {
    throw StateError('T99_ALMACEN debe apuntar a %TEMP%: el almacén real no se abre (10.88).');
  }
  final directorio = kIsWeb ? null : windows ? _almacen : await localStoreDirectory();
  Future<LocalVesselRepository> local() async => LocalVesselRepositoryImpl(
      await HiveVesselDataSource.open(directory: directorio, namespace: t99Namespace));
  Future<MovementLogRepository> bitacora() async => MovementLogRepositoryImpl(
      await HiveMovementDataSource.open(directory: directorio, namespace: t99Namespace));
  final conductor = conductorDesdeDefiniciones();

  if (!_conFirebase) {
    runApp(t99App(local: local, bitacora: bitacora, builder: conductor?.envoltorio));
    conductor?.iniciar();
    return;
  }

  const web = FirebaseOptions(
      apiKey: String.fromEnvironment('FIREBASE_WEB_API_KEY'),
      appId: String.fromEnvironment('FIREBASE_WEB_APP_ID'),
      messagingSenderId: String.fromEnvironment('FIREBASE_WEB_MESSAGING_SENDER_ID'),
      projectId: String.fromEnvironment('FIREBASE_WEB_PROJECT_ID'),
      authDomain: String.fromEnvironment('FIREBASE_WEB_AUTH_DOMAIN'),
      storageBucket: String.fromEnvironment('FIREBASE_WEB_STORAGE_BUCKET'));
  const android = FirebaseOptions(
      apiKey: String.fromEnvironment('FIREBASE_ANDROID_API_KEY'),
      appId: String.fromEnvironment('FIREBASE_ANDROID_APP_ID'),
      messagingSenderId: String.fromEnvironment('FIREBASE_ANDROID_MESSAGING_SENDER_ID'),
      projectId: String.fromEnvironment('FIREBASE_ANDROID_PROJECT_ID'),
      storageBucket: String.fromEnvironment('FIREBASE_ANDROID_STORAGE_BUCKET'));
  // La misma elección que lib/main.dart: la Web usa sus opciones; Windows y
  // Android, las de Android.
  const options = kIsWeb ? web : android;
  if (options.projectId != 'baystream-app') {
    throw StateError('T-99 requiere la configuración autorizada de BayStream.');
  }
  final app = await Firebase.initializeApp(name: 't99', options: options);
  final database = FirebaseFirestore.instanceFor(app: app);
  final auth = FirebaseAuth.instanceFor(app: app);
  // Solo estado booleano: nunca correo, UID ni datos de la sesión.
  debugPrint('T99 Firebase=true; sesionInicial=${auth.currentUser == null ? "ausente" : "presente"}');
  if (auth.currentUser != null) {
    throw StateError('T-99 no usa sesión y la app t99 trae una: detente y avisa.');
  }
  runApp(ProviderScope(overrides: [
    vesselRepositoryProvider.overrideWith((ref) => VesselRepositoryImpl(firestore: database)),
    localVesselRepositoryProvider.overrideWith((ref) async {
      final repo = await local();
      ref.onDispose(() => unawaited(repo.close()));
      return repo;
    }),
    movementLogRepositoryProvider.overrideWith((ref) async {
      final repo = await bitacora();
      ref.onDispose(() => unawaited(repo.close()));
      return repo;
    }),
    sessionRepositoryProvider.overrideWith((ref) async {
      final repo = FirebaseSessionRepository(auth, database,
          await HiveLastOperatorStore.open(directory: directorio, namespace: t99Namespace));
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
  ], child: BayStreamApp(builder: conductor?.envoltorio)));
  conductor?.iniciar();
}
