// T-130 · La app del producto contra el emulador de Firebase, para la prueba
// de punta a punta de la sección 3.10 de docs/T130-RESULTADOS.md: la laptop
// como oficina (la Web, en Chrome) y el Honor como muelle (un APK de
// depuración), los dos contra el emulador que corre en la laptop. Está hecho
// como el banco de la aceptación de T-128 (Codex): la interfaz de lib/ sin
// tocarla (BayStreamApp), almacenes propios `t130emu` y Firebase inicializado
// en una app aparte, `t130emu`, apuntando al emulador y a ningún proyecto
// real: solo `demo-*`.
//
// Lo que cambia frente al de T-128: el anfitrión puede ser la IP de la laptop
// en el Wi-Fi (T130_HOST), para que el Honor llegue al emulador; los puertos
// siguen siendo los del emulador (Auth 9399, Firestore 8383). El cortafuegos
// lo abre y lo cierra Carlos, solo en el perfil privado, y el emulador
// escucha en 0.0.0.0 solo durante la prueba (10.90, ajuste 6).
//
//   flutter build web --release --no-pub --no-web-resources-cdn -t tool/t130_emu_main.dart
//     --dart-define=T130_HOST=127.0.0.1 --output=build/t130/web-emu
//   flutter build apk --debug -t tool/t130_emu_main.dart
//     --dart-define=T130_HOST=<IP de la laptop>        (sin --no-pub, 10.83)
//   flutter run -d windows -t tool/t130_emu_main.dart
//     --dart-define=T130_WINDOWS_STORE=<%TEMP%\t130-emu> --dart-define=T130_HOST=127.0.0.1
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

/// El namespace de los almacenes de esta prueba: nunca el real.
const t130Namespace = 't130emu';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const temporary = String.fromEnvironment('T130_WINDOWS_STORE');
  if (!kIsWeb &&
      defaultTargetPlatform == TargetPlatform.windows &&
      !RegExp(r'[/\\]Temp[/\\]').hasMatch(temporary)) {
    throw StateError('T130_WINDOWS_STORE debe apuntar a TEMP (10.88).');
  }
  final directory = kIsWeb
      ? null
      : defaultTargetPlatform == TargetPlatform.windows
          ? temporary
          : await localStoreDirectory();

  const project = String.fromEnvironment('T130_PROJECT', defaultValue: 'demo-t130-e2e');
  const host = String.fromEnvironment('T130_HOST', defaultValue: '127.0.0.1');
  const authPort = int.fromEnvironment('T130_AUTH_PORT', defaultValue: 9399);
  const firestorePort = int.fromEnvironment('T130_FIRESTORE_PORT', defaultValue: 8383);
  // Solo un proyecto demo-, un anfitrión local (loopback o una IP privada
  // del Wi-Fi) y los puertos del emulador: nunca baystream-app.
  final private = RegExp(r'^(127\.0\.0\.1|10\.\d+\.\d+\.\d+|192\.168\.\d+\.\d+|172\.(1[6-9]|2\d|3[01])\.\d+\.\d+)$');
  if (!project.startsWith('demo-') ||
      !private.hasMatch(host) ||
      ![9399, 9398].contains(authPort) ||
      ![8383, 8384].contains(firestorePort)) {
    throw StateError('T130: solo proyecto demo-, anfitrión local y puertos del emulador.');
  }
  final app = await Firebase.initializeApp(name: 't130emu', demoProjectId: project);
  await FirebaseAuth.instanceFor(app: app)
      .useAuthEmulator(host, authPort, automaticHostMapping: false);
  FirebaseFirestore.instanceFor(app: app)
      .useFirestoreEmulator(host, firestorePort, automaticHostMapping: false);
  final database = FirebaseFirestore.instanceFor(app: app);
  final auth = FirebaseAuth.instanceFor(app: app);
  // Solo estado booleano: nunca correo, UID ni datos de la sesión.
  debugPrint('T130 emulador=$host:$firestorePort; '
      'sesionInicial=${auth.currentUser == null ? "ausente" : "presente"}');

  runApp(ProviderScope(overrides: [
    vesselRepositoryProvider
        .overrideWith((ref) => VesselRepositoryImpl(firestore: database)),
    localVesselRepositoryProvider.overrideWith((ref) async {
      final repo = LocalVesselRepositoryImpl(await HiveVesselDataSource.open(
          directory: directory, namespace: t130Namespace));
      ref.onDispose(() => unawaited(repo.close()));
      return repo;
    }),
    movementLogRepositoryProvider.overrideWith((ref) async {
      final repo = MovementLogRepositoryImpl(await HiveMovementDataSource.open(
          directory: directory, namespace: t130Namespace));
      ref.onDispose(() => unawaited(repo.close()));
      return repo;
    }),
    sessionRepositoryProvider.overrideWith((ref) async {
      final repo = FirebaseSessionRepository(
          auth,
          database,
          await HiveLastOperatorStore.open(
              directory: directory, namespace: t130Namespace));
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
