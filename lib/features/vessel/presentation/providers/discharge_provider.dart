import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/entities.dart';
import '../../domain/repositories/movement_log_repository.dart';
import '../../domain/services/discharge_progress.dart';
import '../../domain/services/operation_sources.dart';
import '../../domain/services/operation_state_deriver.dart';
import '../formatters/vessel_error_message.dart';
import 'movement_log_provider.dart';
import 'vessel_providers.dart';

/// T-75 · Quién registra sin cuenta: el modo de un solo dispositivo. Desde
/// T-79, con sesión firma la cuenta (`movementAuthorProvider`), y lo que
/// firma este autor se queda en el dispositivo.
const dockOperator =
    MovementAuthor(name: 'Muelle (sin cuenta)', role: OperatorRole.dock);

/// Motivo de un toque para deshacer (T-79a: `annul` exige motivo).
const markedByMistake = 'Marcado por error';

/// El modo Descarga solo tiene sentido en un plano de llegada: un viaje con
/// escala confirmada y algo que baje en ella.
bool offersDischarge(VesselVoyage voyage) =>
    voyage.portOfCall != null &&
    voyage.cargoCountsFor(voyage.portOfCall).discharged > 0;

/// Sigue la bitácora de T-72 sobre el plan combinado de la escala: el plano
/// de llegada que se ve y, si la operación lo tiene, su plan de carga. No
/// mantiene un contador paralelo: cada cambio vuelve a derivar el estado.
final dischargeProgressProvider = StreamProvider.autoDispose
    .family<DischargeProgress, VesselVoyage>((ref, voyage) async* {
  ref.watch(operationSourcesRevisionProvider);
  final port = voyage.portOfCall!;
  final repository = await ref.watch(movementLogRepositoryProvider.future);
  final operation = await OperationSources.find(repository, voyage, port);
  final loadingSource = operation?.source(OperationSourceKind.loadingBaplie);
  VesselVoyage? loading;
  if (loadingSource != null) {
    final parsed = (await ref
            .read(vesselRepositoryProvider)
            .parseBaplieFile(loadingSource.content))
        .fold((failure) => throw VesselOperationFailure(failure),
            (value) => value);
    loading = voyage.geometry == null
        ? parsed
        : parsed.withGeometry(voyage.geometry!, portOfCall: port);
  }
  final plan = OperationPlan.build(
      portOfCall: port,
      arrival: voyage,
      loading: loading,
      geometry: voyage.geometry);
  DischargeProgress derive(Iterable<MovementRecord> records) {
    final movements = records.map((r) => r.movement).toList();
    return DischargeProgress.build(
        plan, const OperationStateDeriver().derive(plan, movements),
        operationId: operation?.id, movements: movements);
  }

  if (operation == null) {
    yield derive(const []);
    return;
  }
  await for (final records in repository.watch(operation.id)) {
    yield derive(records);
  }
});

/// Registra un movimiento en la bitácora. Devuelve el registrado o el
/// mensaje del error; solo con el registrado la pantalla dice «registrado».
/// Recibe el repositorio y el autor, no el `ref`, para que el «Deshacer» de
/// un aviso funcione aunque la pestaña del plano ya no esté en pantalla.
Future<({MovementRecord? record, String? error})> appendMovement(
    MovementLogRepository repository, MovementDraft draft,
    MovementAuthor author) async {
  try {
    return (await repository.append(draft, author)).fold(
        (failure) => (record: null, error: failure.message),
        (record) => (record: record, error: null));
  } catch (error, stack) {
    return (record: null, error: vesselErrorMessage(error, stack));
  }
}

/// Deshace un movimiento con `annul`, nunca borrando (T-72).
Future<String?> annulMovement(MovementLogRepository repository,
    Movement movement, String reason, MovementAuthor author) async {
  final result = await appendMovement(
      repository,
      MovementDraft.annul(movement.operationId, movement.id, reason,
          target: movement.target),
      author);
  return result.error;
}
