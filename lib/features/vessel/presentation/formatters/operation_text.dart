import '../../domain/entities/operation.dart';
import '../../domain/repositories/operation_sync_repository.dart';

/// Concordancia de los contadores visibles de la operación.
String operationCount(int count, String singular, String plural) =>
    '$count ${count == 1 ? singular : plural}';

String pendingZones(int deck, int hold) =>
    '(${operationCount(deck, 'pendiente', 'pendientes')} en cubierta / '
    '${operationCount(hold, 'pendiente', 'pendientes')} en bodega)';

String rejectionText(String message) =>
    message.replaceFirst(RegExp(r'\.{2,}\s*$'), '.');

/// T-143 (O-139-7, O-139-1; 10.117) · El estado del plano y de su operación,
/// una sola regla para los tres clientes: la píldora de la cabecera y «Nube y
/// cuenta» la leen de aquí. La palabra de la nube va solo cuando la operación
/// está en la nube: antes de publicar, el plano está «Confirmado» en este
/// equipo; desde la publicación, la operación está «Publicada» o «Cerrada».
enum EstadoDeLaOperacion { sinConfirmar, confirmado, publicada, cerrada }

/// [confirmado] es el plano con el perfil confirmado (`Publicado` en
/// `voyage_ui_state.dart`); [operation] es la operación de la escala en este
/// equipo, si la hay, y [status] el estado del envío. El cierre cuenta si lo
/// guardó el equipo o si el motor lo acaba de ver en la nube.
EstadoDeLaOperacion estadoDeLaOperacion({
  required bool confirmado,
  Operation? operation,
  SyncStatus? status,
}) {
  if (!confirmado) return EstadoDeLaOperacion.sinConfirmar;
  if (operation == null || !operation.published) {
    return EstadoDeLaOperacion.confirmado;
  }
  return operationIsClosed(operation, status)
      ? EstadoDeLaOperacion.cerrada
      : EstadoDeLaOperacion.publicada;
}

/// La operación está cerrada si este equipo ya lo guardó o si el motor lo
/// vio en el documento de la nube (T-143): «Nube y cuenta» no espera a que
/// la operación local se vuelva a leer.
bool operationIsClosed(Operation operation, SyncStatus? status) =>
    operation.closed || (status?.closed ?? false);

/// Lo que dice la píldora de la cabecera.
String textoDelEstado(EstadoDeLaOperacion estado) => switch (estado) {
      EstadoDeLaOperacion.sinConfirmar => 'Sin confirmar',
      EstadoDeLaOperacion.confirmado => 'Confirmado',
      EstadoDeLaOperacion.publicada => 'Publicada',
      EstadoDeLaOperacion.cerrada => 'Cerrada',
    };

/// La frase entera, para la descripción emergente y la etiqueta accesible de
/// la píldora. Empieza con la palabra visible, para que la etiqueta la
/// contenga.
String fraseDelEstado(EstadoDeLaOperacion estado) => switch (estado) {
      EstadoDeLaOperacion.sinConfirmar =>
        'Sin confirmar: confirma el perfil del buque para operar',
      EstadoDeLaOperacion.confirmado =>
        'Confirmado en este equipo: la operación todavía no está en la nube',
      EstadoDeLaOperacion.publicada => 'Publicada en la nube',
      EstadoDeLaOperacion.cerrada =>
        'Cerrada por la oficina: ya no se registran movimientos',
    };

/// Lo que «Nube y cuenta» dice de la operación de la escala.
String textoDeLaOperacionEnLaNube(Operation operation, SyncStatus? status) =>
    !operation.published
        ? 'Solo en este dispositivo'
        : operationIsClosed(operation, status)
            ? 'Publicada y cerrada'
            : 'Publicada';
