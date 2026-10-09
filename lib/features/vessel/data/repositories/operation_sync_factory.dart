import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../domain/repositories/movement_log_repository.dart';
import '../../domain/repositories/operation_sync_repository.dart';
import '../../domain/repositories/session_repository.dart';
import '../datasources/local_store_directory.dart';
import 'firebase_session_repository.dart';
import 'firestore_operation_sync.dart';
import 'local_only_operation_sync.dart';

/// T-79 · Elige el adaptador (T-79a 3.4). Desde 10.8 los tres clientes usan
/// Firestore y Firebase Auth; sin Firebase inicializado (las pruebas, o una
/// compilación sin opciones) la app sigue en el modo de un solo dispositivo.
/// Solo aquí se crean `FirebaseAuth.instance` y `FirebaseFirestore.instance`.
bool get cloudAvailable => Firebase.apps.isNotEmpty;

Future<SessionRepository> openSessionRepository(
    {String namespace = 'baystream'}) async {
  if (!cloudAvailable) return const LocalSessionRepository();
  return FirebaseSessionRepository(
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
    await HiveLastOperatorStore.open(
        directory: await localStoreDirectory(), namespace: namespace),
  );
}

OperationSyncRepository openOperationSync(
        MovementLogRepository log, SessionRepository session) =>
    cloudAvailable && session.supportsAccounts
        ? FirestoreOperationSync(FirebaseFirestore.instance, log, session)
        : const LocalOnlyOperationSync();
