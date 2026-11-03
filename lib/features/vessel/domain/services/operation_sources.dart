import 'package:uuid/uuid.dart';

import '../../../../core/errors/failures.dart';
import '../entities/operation.dart';
import '../entities/vessel_voyage.dart';
import '../repositories/movement_log_repository.dart';
import '../repositories/operation_sync_repository.dart';

/// T-130 · Lo que la oficina encuentra al confirmar un plano en una escala:
/// la operación publicada y abierta de ese buque en ese puerto, con
/// cualquier viaje, buscada en este equipo y en la nube (10.90, ajustes 1 y
/// 2). Lo calcula [OperationSources.lookup]; la pantalla decide con esto si
/// muestra el diálogo de agregar, la banda que lleva a «Unirse» o el mensaje
/// de que ya está.
sealed class PlanAttachment {
  const PlanAttachment();
}

/// No hay ninguna: el flujo de siempre.
final class NoPublishedOperation extends PlanAttachment {
  const NoPublishedOperation();
}

/// Una, en este equipo, a la que le falta este tipo de BAPLIE: se puede
/// agregar, con la confirmación de la oficina.
final class AttachablePlan extends PlanAttachment {
  final Operation operation;

  /// Cuándo se publicó, con la hora del servidor, si la nube respondió.
  final DateTime? publishedAt;

  const AttachablePlan(this.operation, {this.publishedAt});
}

/// Una, en este equipo, que ya tiene este tipo: con el mismo texto (volver a
/// abrir el publicado no cambia nada) o con otro (los BAPLIE no cambian).
final class PlanAlreadyThere extends PlanAttachment {
  final Operation operation;
  final OperationSource source;
  final bool sameContent;

  const PlanAlreadyThere(this.operation, this.source,
      {required this.sameContent});
}

/// Una, en la nube y no en este equipo: hay que unirse antes de agregar.
final class PlanInCloudOnly extends PlanAttachment {
  final PublishedOperation remote;

  const PlanInCloudOnly(this.remote);
}

/// Más de una publicada y abierta de ese buque en esa escala, aquí o en la
/// nube: la app no elige; la oficina cierra la que no corresponde.
final class SeveralOpenOperations extends PlanAttachment {
  final List<({String voyage, DateTime? publishedAt})> candidates;

  const SeveralOpenOperations(this.candidates);
}

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

  /// El nombre de cada fuente, como se dice en pantalla.
  static String sourceName(OperationSourceKind kind) => switch (kind) {
        OperationSourceKind.arrivalBaplie => 'plano de llegada',
        OperationSourceKind.loadingBaplie => 'plan de carga',
        OperationSourceKind.exportList => 'listado de la agencia',
      };

  /// T-79 · Si en el dispositivo hay una operación local y otra publicada de
  /// la misma escala (el muelle abrió el archivo antes de unirse), manda la
  /// publicada: es la que comparten los dispositivos.
  ///
  /// T-130 · La operación es la del viaje del plano que se ve, o la que tiene
  /// una fuente que declara ese viaje ([Operation.matchesVoyage]): un plan
  /// agregado después de publicar puede venir con otro número de viaje.
  static Future<Operation?> find(MovementLogRepository repository,
      VesselVoyage voyage, String port) async {
    final operations = (await repository.getOperations())
        .fold((failure) => throw failure, (operations) => operations);
    Operation? local;
    for (final operation in operations) {
      if (operation.vesselName == voyage.vessel.name &&
          operation.portOfCall == port &&
          operation.matchesVoyage(voyage.voyageNumber)) {
        if (operation.published) return operation;
        local ??= operation;
      }
    }
    return local;
  }

  /// T-130 · Las operaciones publicadas y abiertas de ese buque en esa escala
  /// que este equipo tiene, con cualquier viaje: donde la oficina agrega el
  /// plan que falta.
  static Future<List<Operation>> publishedAtCall(
      MovementLogRepository repository, String vesselName, String port) async {
    final operations = (await repository.getOperations())
        .fold((failure) => throw failure, (operations) => operations);
    return [
      for (final operation in operations)
        if (operation.published &&
            !operation.closed &&
            operation.vesselName == vesselName &&
            operation.portOfCall == port)
          operation
    ];
  }

  /// T-130 · Cruza lo que este equipo tiene ([local], las de
  /// [publishedAtCall]) con las operaciones abiertas de la nube ([remote];
  /// nulo si la nube no respondió o no hay sesión). Con la nube a la vista,
  /// una copia local que la nube ya no lista está cerrada o retirada y no
  /// cuenta. Función pura: la pantalla reúne las dos listas.
  static PlanAttachment lookup({
    required Iterable<Operation> local,
    required List<PublishedOperation>? remote,
    required String vesselName,
    required String port,
    required OperationSourceKind kind,
    required String content,
  }) {
    final here = [
      for (final o in local)
        if (o.published &&
            !o.closed &&
            o.vesselName == vesselName &&
            o.portOfCall == port)
          o
    ];
    final cloud = remote == null
        ? null
        : [
            for (final r in remote)
              if (r.vesselName == vesselName && r.portOfCall == port) r
          ];
    final candidates = cloud == null
        ? here
        : [
            for (final o in here)
              if (cloud.any((r) => r.id == o.id)) o
          ];
    final onlyCloud = cloud == null
        ? const <PublishedOperation>[]
        : [
            for (final r in cloud)
              if (!here.any((o) => o.id == r.id)) r
          ];
    DateTime? publishedAt(Operation o) =>
        cloud?.where((r) => r.id == o.id).firstOrNull?.createdAt;
    final total = candidates.length + onlyCloud.length;
    if (total == 0) return const NoPublishedOperation();
    if (total > 1) {
      final all = [
        for (final o in candidates)
          (voyage: o.voyageNumber, publishedAt: publishedAt(o) ?? o.createdAt),
        for (final r in onlyCloud) (voyage: r.voyageNumber, publishedAt: r.createdAt),
      ]..sort((a, b) =>
          (a.publishedAt ?? DateTime(0)).compareTo(b.publishedAt ?? DateTime(0)));
      return SeveralOpenOperations(all);
    }
    if (candidates.isEmpty) return PlanInCloudOnly(onlyCloud.single);
    final operation = candidates.single;
    final existing = operation.source(kind);
    if (existing != null) {
      return PlanAlreadyThere(operation, existing,
          sameContent: existing.content == content);
    }
    return AttachablePlan(operation, publishedAt: publishedAt(operation));
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
  ///
  /// T-130 (10.90) · Una operación publicada y abierta acepta también el
  /// BAPLIE que le falta, solo con la confirmación explícita de la oficina
  /// ([attachTo] es la operación confirmada en pantalla): sube por
  /// [OperationSyncRepository.addSource], y si el archivo declara otro viaje
  /// que la operación, la fuente lo recuerda ([OperationSource.voyage]). Un
  /// BAPLIE que ya está nunca se reemplaza.
  static Future<Operation> save(MovementLogRepository repository,
      VesselVoyage voyage, String port, OperationSource source,
      {OperationSyncRepository? sync,
      DateTime Function()? clock,
      Operation? attachTo}) async {
    final existing = attachTo ?? await find(repository, voyage, port);
    if (existing != null && existing.published) {
      if (existing.source(source.kind)?.content == source.content) return existing;
      if (existing.closed) {
        throw ValidationFailure(
            field: 'source',
            message: source.kind == OperationSourceKind.exportList
                ? 'La operación de esta escala ya está cerrada y su listado no '
                    'cambia. Para trabajar con otro listado, abre el plan de '
                    'carga como una operación nueva.'
                : 'La operación de esta escala ya está cerrada y sus BAPLIE no '
                    'cambian. Para trabajar con este archivo, ábrelo como una '
                    'operación nueva.');
      }
      if (source.kind == OperationSourceKind.exportList) {
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
      final current = existing.source(source.kind);
      if (current != null) {
        throw ValidationFailure(
            field: 'source', message: replaceMessage(source.kind, current.fileName));
      }
      if (attachTo == null) {
        throw ValidationFailure(
            field: 'source',
            message: 'La operación de esta escala ya está publicada y no tiene '
                'este ${sourceName(source.kind)}: para agregarlo, confirma el '
                'plano desde la banda y acepta «Agregar a la operación».');
      }
      if (sync == null) {
        throw const ValidationFailure(
            field: 'source',
            message: 'El plan que falta en una operación publicada se agrega por '
                'la nube, y esta compilación no la tiene configurada. Pide al '
                'responsable una compilación con la nube.');
      }
      final declared = voyage.voyageNumber == existing.voyageNumber
          ? null
          : voyage.voyageNumber;
      return (await sync.addSource(existing, source.withVoyage(declared)))
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

  /// T-130 (3.2 del diseño) · Lo que dice la página cuando la oficina abre un
  /// BAPLIE de un tipo que la operación publicada ya tiene, con otro texto.
  static String replaceMessage(OperationSourceKind kind, String fileName) =>
      'La operación publicada de esta escala ya tiene el ${sourceName(kind)} '
      '(«$fileName») y los BAPLIE de una operación publicada no cambian. Si '
      'este archivo lo corrige, cierra la operación y publica una nueva con los '
      'planos correctos; si es otra escala o viaje, cámbialo en «Parámetros del '
      'buque».';
}
