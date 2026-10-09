import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/operation_sync_factory.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/operation_sync_repository.dart';
import '../../domain/repositories/session_repository.dart';
import '../../domain/services/operation_sources.dart';
import 'discharge_provider.dart' show dockOperator;
import 'movement_log_provider.dart';
import 'vessel_providers.dart';

/// T-79 · La sesión y la sincronización, por sus contratos (T-79a 3.3). Sin
/// Firebase inicializado no abren nada: la app sigue en un solo dispositivo.
final sessionRepositoryProvider = FutureProvider<SessionRepository>((ref) async {
  final session = await openSessionRepository();
  ref.onDispose(() => unawaited(session.dispose()));
  return session;
});

final operatorProvider = StreamProvider<Operator?>((ref) async* {
  final session = await ref.watch(sessionRepositoryProvider.future);
  yield* session.watchOperator();
});

/// Quién firma lo que se registra: la cuenta (10.11) o, sin cuenta, el
/// autor del modo de un solo dispositivo, cuyos movimientos no se suben.
final movementAuthorProvider = Provider<MovementAuthor>(
    (ref) => ref.watch(operatorProvider).value?.author ?? dockOperator);

final operationSyncProvider = FutureProvider<OperationSyncRepository>((ref) async {
  final log = await ref.watch(movementLogRepositoryProvider.future);
  final session = await ref.watch(sessionRepositoryProvider.future);
  final sync = openOperationSync(log, session);
  ref.onDispose(() => unawaited(sync.dispose()));
  return sync;
});

/// La operación de la escala que se ve, si existe en este dispositivo.
final activeOperationProvider = FutureProvider<Operation?>((ref) async {
  ref.watch(operationSourcesRevisionProvider);
  final key = ref.watch(voyageNotifierProvider.select((value) {
    final voyage = value.value;
    final port = voyage?.portOfCall;
    return voyage == null || port == null
        ? null
        : (voyage.vessel.name, voyage.voyageNumber, port);
  }));
  if (key == null) return null;
  final voyage = ref.read(voyageNotifierProvider).value!;
  final log = await ref.watch(movementLogRepositoryProvider.future);
  return OperationSources.find(log, voyage, key.$3);
});

/// Estado de envío de la operación que se ve. No se descarta al salir de la
/// pantalla: mientras la escala esté abierta, el motor sigue enviando.
final syncStatusProvider = StreamProvider<SyncStatus>((ref) async* {
  if (!cloudAvailable) {
    yield SyncStatus.local;
    return;
  }
  final operation = await ref.watch(activeOperationProvider.future);
  if (operation == null || !operation.published) {
    yield SyncStatus.local;
    return;
  }
  final sync = await ref.watch(operationSyncProvider.future);
  yield* sync.follow(operation);
});

/// Operaciones guardadas en este dispositivo, para saber a cuáles ya se unió.
final localOperationsProvider =
    FutureProvider.autoDispose<List<Operation>>((ref) async {
  ref.watch(operationSourcesRevisionProvider);
  final log = await ref.watch(movementLogRepositoryProvider.future);
  return (await log.getOperations()).fold((failure) => throw failure, (o) => o);
});

/// Operaciones abiertas en la nube, para unirse desde el muelle.
final openOperationsProvider =
    StreamProvider.autoDispose<List<PublishedOperation>>((ref) async* {
  final operator = ref.watch(operatorProvider).value;
  if (operator == null || !operator.authorized) {
    yield const [];
    return;
  }
  final sync = await ref.watch(operationSyncProvider.future);
  yield* sync.watchOpenOperations();
});
