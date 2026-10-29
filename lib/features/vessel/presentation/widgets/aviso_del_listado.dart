import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/operation_sync_repository.dart';
import '../providers/movement_log_provider.dart';
import '../providers/sync_providers.dart';
import 'avisos_del_viaje.dart';

/// T-127 (10.78) · «Listado actualizado por la oficina: n filas.»
String textoDelListadoActualizado(int filas) =>
    'Listado actualizado por la oficina: ${filas == 1 ? '1 fila' : '$filas filas'}.';

/// T-127 · El aviso del muelle cuando la oficina agrega o reemplaza el listado
/// de la operación publicada. El motor ya bajó el listado, comprobó sus
/// huellas y lo guardó en la operación local ([SyncStatus.listArrival]); aquí
/// se avisa una vez por revisión y se pide que el plano se vuelva a derivar
/// con el listado nuevo ([operationSourcesRevisionProvider]), con los
/// movimientos intactos. No dibuja nada: va en la página del viaje, dentro de
/// su `Scaffold`, y el aviso flota como los demás de la página.
class AvisoDelListado extends ConsumerStatefulWidget {
  const AvisoDelListado({super.key});

  @override
  ConsumerState<AvisoDelListado> createState() => _AvisoDelListadoState();
}

class _AvisoDelListadoState extends ConsumerState<AvisoDelListado> {
  /// La última llegada avisada: el estado la repite en cada emisión, y al
  /// volver a armarse la escucha la trae como valor anterior.
  ListArrival? _avisada;

  @override
  void initState() {
    super.initState();
    // Lo que llegó antes de armarse esta página ya no es noticia.
    _avisada = ref.read(syncStatusProvider).value?.listArrival;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<SyncStatus>>(syncStatusProvider, (_, siguiente) {
      final llegada = siguiente.value?.listArrival;
      if (llegada == null || llegada == _avisada || !mounted) return;
      _avisada = llegada;
      ref.read(operationSourcesRevisionProvider.notifier).changed();
      ScaffoldMessenger.of(context).showSnackBar(avisoDelViaje(
        key: const ValueKey('aviso-listado-actualizado'),
        texto: textoDelListadoActualizado(llegada.rows),
        duracion: const Duration(seconds: 6),
      ));
    });
    return const SizedBox.shrink();
  }
}
