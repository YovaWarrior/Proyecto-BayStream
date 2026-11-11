import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/operation_sync_repository.dart';
import '../providers/movement_log_provider.dart' show operationSourcesRevisionProvider;
import '../providers/sync_providers.dart';
import 'avisos_del_viaje.dart';

/// T-143 (O-139-1; 10.117) · El texto del aviso: dice quién cerró, qué
/// operación y qué pasa con lo que se registre.
String textoDelCierre(String port) =>
    'La oficina cerró la operación de $port. Lo que registres desde ahora se '
    'rechazará.';

/// T-143 · El aviso del cierre, hermano de `AvisoDelPlan` y
/// `AvisoDelListado`. El motor ve el cierre en el documento de la operación,
/// sin que el muelle registre nada, guarda la operación local cerrada y lo
/// dice en [SyncStatus.closed]; aquí se avisa una vez, se pide que la
/// operación se vuelva a leer ([operationSourcesRevisionProvider]) para que
/// la píldora y «Nube y cuenta» digan «Cerrada», y no se avisa en el equipo
/// que la cerró ([operacionesCerradasAquiProvider]). Una operación que ya
/// estaba cerrada al abrirse no es noticia. No dibuja nada: va en la página
/// del viaje, dentro de su `Scaffold`.
class AvisoDelCierre extends ConsumerStatefulWidget {
  const AvisoDelCierre({super.key});

  @override
  ConsumerState<AvisoDelCierre> createState() => _AvisoDelCierreState();
}

class _AvisoDelCierreState extends ConsumerState<AvisoDelCierre> {
  /// La operación cuyo estado ya se vio, y si ya estaba cerrada.
  String? _vista;
  bool _cerrada = false;

  @override
  void initState() {
    super.initState();
    _vio(ref.read(syncStatusProvider).value);
  }

  /// Anota la operación que se ve; devuelve verdadero si es la misma de
  /// antes y acaba de cerrarse.
  bool _vio(SyncStatus? status) {
    final operation = ref.read(activeOperationProvider).value;
    if (operation == null || status == null) return false;
    final cerrada = status.closed || operation.closed;
    if (operation.id != _vista) {
      _vista = operation.id;
      _cerrada = cerrada;
      return false;
    }
    if (_cerrada || !cerrada) return false;
    _cerrada = true;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<SyncStatus>>(syncStatusProvider, (_, siguiente) {
      if (!mounted || !_vio(siguiente.value)) return;
      final operation = ref.read(activeOperationProvider).value!;
      ref.read(operationSourcesRevisionProvider.notifier).changed();
      if (ref.read(operacionesCerradasAquiProvider).contains(operation.id)) return;
      ScaffoldMessenger.of(context).showSnackBar(avisoDelViaje(
        key: const ValueKey('aviso-operacion-cerrada'),
        texto: textoDelCierre(operation.portOfCall),
        corto: 'La oficina cerró la operación de ${operation.portOfCall}.',
        duracion: const Duration(seconds: 8),
      ));
    });
    return const SizedBox.shrink();
  }
}
