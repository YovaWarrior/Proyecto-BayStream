import '../../../../core/utils/fecha_corta.dart';
import '../../domain/entities/operation.dart';
import '../../domain/repositories/movement_log_repository.dart';
import '../../domain/repositories/operation_sync_repository.dart';
import '../../domain/services/operation_sources.dart';

/// T-130 (10.90, ajustes 1 y 2) · La búsqueda de la oficina al confirmar un
/// plano en una escala: la operación publicada y abierta de ese buque en ese
/// puerto, con cualquier viaje, en este equipo (la bitácora) y en la nube (la
/// misma consulta de «Operaciones abiertas en la nube», leída una vez del
/// servidor con un tope corto). Sin sesión autorizada no hay nube ([sync]
/// nulo) y la búsqueda sigue solo con lo local; si la nube no responde a
/// tiempo, también. Decide [OperationSources.lookup], que es pura.
Future<PlanAttachment> lookupPlanAttachment({
  required MovementLogRepository log,
  required OperationSyncRepository? sync,
  required String vesselName,
  required String port,
  required OperationSourceKind kind,
  required String content,
  Duration cloudTimeout = const Duration(seconds: 5),
}) async {
  final local = await OperationSources.publishedAtCall(log, vesselName, port);
  List<PublishedOperation>? remote;
  if (sync != null && sync.capability == SyncCapability.realtime) {
    try {
      remote = await sync.watchOpenOperations().first.timeout(cloudTimeout);
    } catch (_) {
      remote = null;
    }
  }
  return OperationSources.lookup(
      local: local,
      remote: remote,
      vesselName: vesselName,
      port: port,
      kind: kind,
      content: content);
}

/// Lo que la banda del previo o el aviso dicen según lo que encontró la
/// búsqueda; nulo cuando no hay nada que decir (ninguna operación, o la
/// misma fuente con el mismo texto).
String? textoDeLaBusqueda(PlanAttachment lookup,
    {required String vesselName,
    required String port,
    required OperationSourceKind kind}) {
  final nombre = OperationSources.sourceName(kind);
  switch (lookup) {
    case NoPublishedOperation():
      return null;
    case PlanAlreadyThere(:final source, :final sameContent):
      return sameContent ? null : OperationSources.replaceMessage(kind, source.fileName);
    case AttachablePlan(:final operation):
      return 'La escala $port ya tiene una operación publicada (viaje '
          '${operation.voyageNumber}) sin $nombre: confirma para agregarlo.';
    case PlanInCloudOnly(:final remote):
      return 'La escala $port ya tiene una operación publicada de este buque '
          '(viaje ${remote.voyageNumber}) que este equipo no tiene. Únete en '
          '«Nube y cuenta» y vuelve a abrir el plan para agregarlo.';
    case SeveralOpenOperations(:final candidates):
      final lista = candidates
          .map((c) => 'viaje ${c.voyage}'
              '${c.publishedAt == null ? '' : ' (publicada el ${fechaCorta(c.publishedAt!)})'}')
          .join(' y ');
      return 'Hay ${candidates.length} operaciones publicadas y abiertas de '
          '$vesselName en $port: $lista. Cierra la que no corresponde desde '
          '«Nube y cuenta» y vuelve a abrir el plan.';
  }
}
