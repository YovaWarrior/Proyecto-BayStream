import 'package:uuid/uuid.dart';

import '../../../../core/errors/failures.dart';
import '../entities/operation.dart';
import '../entities/vessel_voyage.dart';
import '../repositories/movement_log_repository.dart';
import '../repositories/operation_sync_repository.dart';

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

  /// Los BAPLIE de una operación publicada no cambian: lanza un
  /// [ValidationFailure] si el archivo es otro. Volver a abrir la misma
  /// fuente, con el mismo texto, no cambia nada.
  ///
  /// T-127 (10.78) · El listado de la agencia es la única fuente que la
  /// oficina puede agregar o reemplazar después de publicar, mientras la
  /// operación siga abierta: viaja por la nube con una revisión
  /// ([OperationSyncRepository.replaceSource]) y el muelle lo recibe solo.
  /// Si la nube no lo acepta, se lanza su [Failure] y nada local cambia.
  static Future<Operation> save(MovementLogRepository repository,
      VesselVoyage voyage, String port, OperationSource source,
      {OperationSyncRepository? sync, DateTime Function()? clock}) async {
    final existing = await find(repository, voyage, port);
    if (existing != null && existing.published) {
      if (existing.source(source.kind)?.content == source.content) return existing;
      if (source.kind != OperationSourceKind.exportList) {
        throw const ValidationFailure(
            field: 'source',
            message: 'La operación de esta escala ya está publicada y sus '
                'BAPLIE no cambian; solo el listado de la agencia se puede '
                'reemplazar. Abre la fuente publicada desde «Nube y cuenta».');
      }
      if (existing.closed) {
        throw const ValidationFailure(
            field: 'source',
            message: 'La operación de esta escala ya está cerrada y su listado '
                'no cambia. Para trabajar con otro listado, abre el plan de '
                'carga como una operación nueva.');
      }
      if (sync == null) {
        throw const ValidationFailure(
            field: 'source',
            message: 'El listado de una operación publicada se reemplaza por '
                'la nube, y esta compilación no la tiene configurada. Pide al '
                'responsable una compilación con la nube.');
      }
      return (await sync.replaceSource(existing, source))
          .fold((failure) => throw failure, (updated) => updated);
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
