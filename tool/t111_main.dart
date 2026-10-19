// Banco T-111 / aceptación T-107: UI real, sin sesión ni acceso remoto.
// Windows exige T111_STORE en TEMP; Android usa la carpeta privada de esta
// identidad de prueba; Web, IndexedDB del origen local exclusivo. No modifica
// main.dart ni inicializa Firebase. El lector usa su adaptador real de parseo.
import 'dart:async';

import 'package:baystream/core/app.dart';
import 'package:baystream/features/vessel/data/datasources/hive_movement_data_source.dart';
import 'package:baystream/features/vessel/data/datasources/hive_vessel_data_source.dart';
import 'package:baystream/features/vessel/data/datasources/local_store_directory.dart';
import 'package:baystream/features/vessel/data/repositories/local_only_operation_sync.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_impl.dart';
import 'package:baystream/features/vessel/data/repositories/movement_log_repository_impl.dart';
import 'package:baystream/features/vessel/data/repositories/vessel_repository_impl.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const temporary = String.fromEnvironment('T111_STORE');
  if (!kIsWeb &&
      defaultTargetPlatform == TargetPlatform.windows &&
      !RegExp(r'[/\\]Temp[/\\]').hasMatch(temporary)) {
    throw StateError('T111_STORE debe apuntar a TEMP.');
  }
  final directory = kIsWeb
      ? null
      : defaultTargetPlatform == TargetPlatform.windows
          ? temporary
          : await localStoreDirectory();
  runApp(ProviderScope(overrides: [
    vesselRepositoryProvider
        .overrideWith((ref) => VesselRepositoryImpl(firestore: _NoCloud())),
    localVesselRepositoryProvider.overrideWith((ref) async {
      final repository = LocalVesselRepositoryImpl(
          await HiveVesselDataSource.open(
              directory: directory, namespace: 't111'));
      ref.onDispose(() => unawaited(repository.close()));
      return repository;
    }),
    movementLogRepositoryProvider.overrideWith((ref) async {
      final repository = MovementLogRepositoryImpl(
          await HiveMovementDataSource.open(
              directory: directory, namespace: 't111'));
      ref.onDispose(() => unawaited(repository.close()));
      return repository;
    }),
    sessionRepositoryProvider
        .overrideWith((ref) async => const LocalSessionRepository()),
    operationSyncProvider
        .overrideWith((ref) async => const LocalOnlyOperationSync()),
  ], child: const BayStreamApp()));
}

// Igual que el ensayo T-98 sin Firebase: una llamada remota accidental falla
// explícitamente, en lugar de acceder a la red o simular una respuesta válida.
class _NoCloud implements FirebaseFirestore {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('El banco T111 no admite acceso remoto.');
}
