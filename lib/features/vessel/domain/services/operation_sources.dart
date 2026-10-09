import 'package:uuid/uuid.dart';

import '../../../../core/errors/failures.dart';
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

  /// T-79 · Si en el dispositivo hay una operación local y otra publicada de
  /// la misma escala (el muelle abrió el archivo antes de unirse), manda la
  /// publicada: es la que comparten los dispositivos.
  static Future<Operation?> find(MovementLogRepository repository,
      VesselVoyage voyage, String port) async {
    final operations = (await repository.getOperations())
        .fold((failure) => throw failure, (operations) => operations);
    Operation? local;
    for (final operation in operations) {
      if (operation.vesselName == voyage.vessel.name &&
          operation.voyageNumber == voyage.voyageNumber &&
          operation.portOfCall == port) {
        if (operation.published) return operation;
        local ??= operation;
      }
    }
    return local;
  }

  /// Las fuentes de una operación publicada no cambian: lanza un
  /// [ValidationFailure] si el archivo es otro. Volver a abrir la misma
  /// fuente, con el mismo texto, no cambia nada.
  static Future<Operation> save(MovementLogRepository repository,
      VesselVoyage voyage, String port, OperationSource source,
      {DateTime Function()? clock}) async {
    final existing = await find(repository, voyage, port);
    if (existing != null && existing.published) {
      if (existing.source(source.kind)?.content == source.content) return existing;
      throw const ValidationFailure(
          field: 'source',
          message: 'La operación de esta escala ya está publicada y sus fuentes '
              'no cambian. Abre la fuente publicada desde «Nube y cuenta».');
    }
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
      profile: existing?.profile,
    );
    (await repository.saveOperation(operation))
        .fold((failure) => throw failure, (_) {});
    return operation;
  }
}
