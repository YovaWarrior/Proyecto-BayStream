import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/entities.dart';
import '../../domain/repositories/operation_sync_repository.dart';
import '../pages/cloud_page.dart' show openOperationSource;
import '../providers/movement_log_provider.dart' show operationSourcesRevisionProvider;
import '../providers/sync_providers.dart';
import '../providers/vessel_providers.dart';
import 'avisos_del_viaje.dart';

/// T-130 (10.90) · Las cifras de un plan en los avisos: «Plan de carga agregado
/// por la oficina: 104 contenedores y 55 reservas.» en el muelle, y «Plan de
/// carga agregado a la operación publicada de GTSTC: … El muelle lo recibe
/// solo.» en la oficina. Son los mismos conteos del diálogo «Tipo de BAPLIE».
String textoDelPlanAgregado({
  required OperationSourceKind kind,
  required String port,
  required VesselVoyage plan,
  required bool enElMuelle,
}) {
  final cargo = plan.cargoCountsFor(port);
  final reservas = plan.reservedCountsFor(port);
  final nombre = kind == OperationSourceKind.arrivalBaplie
      ? 'Plano de llegada'
      : 'Plan de carga';
  final cifras = kind == OperationSourceKind.arrivalBaplie
      ? '${cargo.discharged + reservas.discharged} se descargan'
      : '${cargo.loaded} contenedores y ${reservas.loaded} reservas';
  return enElMuelle
      ? '$nombre agregado por la oficina: $cifras.'
      : '$nombre agregado a la operación publicada de $port: $cifras. El '
          'muelle lo recibe solo.';
}

/// T-130 · El aviso del muelle cuando la oficina agrega el plano de llegada o
/// el plan de carga a la operación publicada. El motor ya bajó el plan,
/// comprobó sus huellas y lo guardó en la operación local
/// ([SyncStatus.planArrival]); aquí se avisa una vez por llegada, se pide que
/// el plano se vuelva a derivar ([operationSourcesRevisionProvider]), con los
/// movimientos intactos, y «Abrir» abre ese plano desde la operación, como
/// «Abrir plano de llegada» en «Nube y cuenta» (la Descarga solo existe con
/// el plano de llegada a la vista; la Carga se deriva de la operación y
/// funciona sin reabrir). No dibuja nada: va en la página del viaje, dentro
/// de su `Scaffold`, hermano de `AvisoDelListado`.
class AvisoDelPlan extends ConsumerStatefulWidget {
  const AvisoDelPlan({super.key});

  @override
  ConsumerState<AvisoDelPlan> createState() => _AvisoDelPlanState();
}

class _AvisoDelPlanState extends ConsumerState<AvisoDelPlan> {
  /// La última llegada avisada: el estado la repite en cada emisión, y al
  /// volver a armarse la escucha la trae como valor anterior.
  PlanArrival? _avisada;

  @override
  void initState() {
    super.initState();
    // Lo que llegó antes de armarse esta página ya no es noticia.
    _avisada = ref.read(syncStatusProvider).value?.planArrival;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<SyncStatus>>(syncStatusProvider, (_, siguiente) {
      final llegada = siguiente.value?.planArrival;
      if (llegada == null || llegada == _avisada || !mounted) return;
      _avisada = llegada;
      ref.read(operationSourcesRevisionProvider.notifier).changed();
      unawaited(_avisar(llegada));
    });
    return const SizedBox.shrink();
  }

  Future<void> _avisar(PlanArrival llegada) async {
    final nombre = llegada.kind == OperationSourceKind.arrivalBaplie
        ? 'Plano de llegada'
        : 'Plan de carga';
    var texto = '$nombre agregado por la oficina: «${llegada.fileName}».';
    Operation? operation;
    try {
      // Después de `changed()`, la operación de la escala vuelve a leerse de
      // la bitácora, ya con el plan que el motor guardó.
      operation = await ref.read(activeOperationProvider.future);
      final source = operation?.source(llegada.kind);
      final port = operation?.portOfCall;
      if (source != null && port != null) {
        final parsed = await ref
            .read(vesselRepositoryProvider)
            .parseBaplieFile(source.content);
        texto = parsed.fold(
            (_) => texto,
            (plan) => textoDelPlanAgregado(
                kind: llegada.kind, port: port, plan: plan, enElMuelle: true));
      }
    } catch (_) {
      // Sin cifras, el aviso dice el archivo.
    }
    if (!mounted) return;
    final abrir = operation;
    ScaffoldMessenger.of(context).showSnackBar(avisoDelViaje(
      key: const ValueKey('aviso-plan-agregado'),
      texto: texto,
      duracion: const Duration(seconds: 6),
      accion: abrir == null ? null : 'Abrir',
      onAccion: abrir == null
          ? null
          : () => unawaited(openOperationSource(ref, abrir, llegada.kind)),
    ));
  }
}
