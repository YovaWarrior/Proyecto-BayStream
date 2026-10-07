import 'package:uuid/uuid.dart';

import '../entities/operation.dart';
import '../entities/vessel_voyage.dart';
import '../repositories/movement_log_repository.dart';

/// Identidad y reemplazo de una fuente de la escala, sin perder las demás.
class OperationSources {
  const OperationSources._();

  static OperationSourceKind? baplieKind(VesselVoyage voyage, String port) {
    final cargo = voyage.cargoCountsFor(port);
    final reservations = voyage.reservedCountsFor(port);
    final loads = cargo.loaded + reservations.loaded;
    final discharges = cargo.discharged + reservations.discharged;
    if (loads > 0 && discharges == 0) return OperationSourceKind.loadingBaplie;
    if (discharges > 0 && loads == 0) return OperationSourceKind.arrivalBaplie;
    return null;
  }

  static Future<Operation?> find(MovementLogRepository repository,
      VesselVoyage voyage, String port) async {
    final operations = (await repository.getOperations())
        .fold((failure) => throw failure, (operations) => operations);
    for (final operation in operations) {
      if (operation.vesselName == voyage.vessel.name &&
          operation.voyageNumber == voyage.voyageNumber &&
          operation.portOfCall == port) {
        return operation;
      }
    }
    return null;
  }

  static Future<Operation> save(MovementLogRepository repository,
      VesselVoyage voyage, String port, OperationSource source,
      {DateTime Function()? clock}) async {
    final existing = await find(repository, voyage, port);
    final operation = Operation(
      id: existing?.id ?? const Uuid().v4(),
      vesselName: voyage.vessel.name,
      voyageNumber: voyage.voyageNumber,
      portOfCall: port,
      createdAt: existing?.createdAt ?? (clock ?? DateTime.now)(),
      sources: [
        ...?existing?.sources.where((s) => s.kind != source.kind),
        source
      ],
    );
    (await repository.saveOperation(operation))
        .fold((failure) => throw failure, (_) {});
    return operation;
  }
}
