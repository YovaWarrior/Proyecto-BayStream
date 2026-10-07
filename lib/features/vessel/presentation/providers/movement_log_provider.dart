import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/local_vessel_repository_factory.dart';
import '../../domain/repositories/movement_log_repository.dart';

/// Almacén de T-72 compartido por las fuentes, el listado y el plano.
final movementLogRepositoryProvider =
    FutureProvider<MovementLogRepository>((ref) async {
  var disposed = false;
  MovementLogRepository? repository;
  ref.onDispose(() {
    disposed = true;
    if (repository != null) unawaited(repository.close());
  });
  repository = await openMovementLogRepository();
  if (disposed) await repository.close();
  return repository;
});

final operationSourcesRevisionProvider =
    NotifierProvider<OperationSourcesRevision, int>(
        OperationSourcesRevision.new);

class OperationSourcesRevision extends Notifier<int> {
  @override
  int build() => 0;
  void changed() => state++;
}
