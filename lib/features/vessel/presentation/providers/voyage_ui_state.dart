import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/entities.dart';
import '../formatters/vessel_error_message.dart';
import 'vessel_providers.dart';

/// Los estados del viaje en la interfaz («ver primero, confirmar después»,
/// `DESIGN.md` 7.1; decisión 10.2).
///
/// Se derivan del [voyageNotifierProvider]: el notifier sigue siendo la única
/// fuente del viaje visible y `_publish`, la única escritura. Las pantallas
/// hacen `switch` sobre este tipo en vez de leer banderas sueltas.
sealed class VoyageUiState {
  const VoyageUiState();
}

/// El inicio: «Seleccionar archivo», los recientes y los perfiles.
final class SinViaje extends VoyageUiState {
  const SinViaje();
}

/// Leyendo el archivo: un indicador con su nombre.
final class Leyendo extends VoyageUiState {
  const Leyendo(this.fileName);

  /// El archivo que se está leyendo.
  final String fileName;
}

/// Por qué el plano abre en previo. Escribe el texto de la banda.
enum PreviewReason {
  /// No hay perfil guardado para este buque: se propone desde el archivo.
  buqueNuevo,

  /// Hay perfiles con el mismo nombre: hay que elegir el buque.
  homonimo,

  /// El perfil guardado no cubre toda la carga del archivo.
  fueraDelPerfil,

  /// El perfil cubre la carga, pero la escala propuesta no es la última
  /// confirmada para este buque (regla de `DESIGN.md` 7.2).
  escalaPorDecidir,

  /// T-130 (10.90) · La escala ya tiene una operación publicada y abierta de
  /// este buque: a la que le falta este plan (confirmar lo agrega, con un
  /// diálogo), la que está en la nube y no en este equipo (hay que unirse),
  /// la que ya tiene este tipo con otro texto, o varias abiertas. La
  /// publicación directa nunca agrega sola: el plano abre en previo y la
  /// banda dice cuál es el caso ([Previo.nota]).
  operacionPublicada,
}

/// El plano se ve con el perfil propuesto, sin guardar nada: se puede mirar,
/// buscar y colorear; para operar, publicar o exportar hay que confirmar.
final class Previo extends VoyageUiState {
  const Previo({
    required this.voyage,
    required this.profile,
    required this.motivo,
    required this.fileName,
    this.portOfCall,
    this.identidadPendiente = false,
    this.nota,
  });

  /// El viaje tal como se dibuja: con la geometría propuesta y sin escala.
  final VesselVoyage voyage;

  /// T-130 · Lo que la banda dice con [PreviewReason.operacionPublicada]: el
  /// texto de la búsqueda (`textoDeLaBusqueda`), ya escrito por el notifier.
  final String? nota;

  /// El perfil propuesto (o el guardado, si existe) que todavía no se confirma.
  final VesselProfile profile;

  /// Por qué no abrió publicado.
  final PreviewReason motivo;

  /// El archivo leído.
  final String fileName;

  /// La escala que la app propone (`suggestPortOfCall`), si el archivo da pie.
  final String? portOfCall;

  /// Hay homónimos: «Confirmar» pide elegir el buque antes de los parámetros.
  final bool identidadPendiente;

  /// El texto de la banda, según el motivo (`DESIGN.md` 7.1).
  String get texto => switch (motivo) {
        PreviewReason.homonimo =>
          'Hay perfiles con el mismo nombre: confirma el buque antes de operar.',
        PreviewReason.fueraDelPerfil =>
          'El perfil guardado no cubre esta carga: revisa la ampliación.',
        PreviewReason.buqueNuevo => portOfCall == null
            ? 'Plano sin confirmar: perfil propuesto desde el archivo. '
                'El archivo no declara la escala.'
            : 'Plano sin confirmar: perfil propuesto desde el archivo. '
                'Escala propuesta $portOfCall.',
        PreviewReason.escalaPorDecidir => _escalaPorDecidir,
        PreviewReason.operacionPublicada => nota ??
            'La escala ${portOfCall ?? 'de este plano'} ya tiene una operación '
                'publicada de este buque: confirma para agregar este plan.',
      };

  String get _escalaPorDecidir {
    final salida = voyage.portOfOrigin;
    final llegada = voyage.portOfNextCall;
    if (salida != null && llegada != null && salida != llegada) {
      return 'El archivo sale de $salida rumbo a $llegada: confirma la escala.';
    }
    return portOfCall == null
        ? 'Plano sin confirmar: confirma el perfil y la escala para operar.'
        : 'Plano sin confirmar. Escala propuesta $portOfCall: '
            'confírmala para operar.';
  }
}

/// Publicado: lo de hoy. Se opera, se publica, se exporta.
final class Publicado extends VoyageUiState {
  const Publicado(this.voyage);

  /// El viaje publicado, con geometría confirmada.
  final VesselVoyage voyage;
}

/// El error, con su causa y la acción de volver a intentar.
final class Fallo extends VoyageUiState {
  const Fallo(this.mensaje);

  /// Qué pasó y qué hacer.
  final String mensaje;
}

/// Lo que el previo no evalúa, dicho con esas palabras y nunca con un hueco
/// ni con «sin alertas» (`DESIGN.md` 7.2, punto 4; decisión 10.4).
const String sinEvaluarHastaConfirmar =
    'Peso por pila y tomas de refrigerado: sin evaluar hasta confirmar el perfil.';

/// Lo que el previo no hace: exportar cuenta como operar (10.4).
const String exportarSinConfirmar =
    'Para exportar, confirma el perfil del buque.';

/// El estado de la interfaz, derivado del notifier.
final voyageUiStateProvider = Provider<VoyageUiState>((ref) {
  final estado = ref.watch(voyageNotifierProvider);
  final notifier = ref.read(voyageNotifierProvider.notifier);
  if (estado.isLoading) return Leyendo(notifier.loadedFileName);
  if (estado.hasError) {
    return Fallo(vesselErrorMessage(
        estado.error!, estado.stackTrace, 'procesar el archivo'));
  }
  final voyage = estado.value;
  if (voyage == null) return const SinViaje();
  if (notifier.isPreview) {
    return Previo(
      voyage: voyage,
      profile: notifier.currentProfile ?? VesselProfile.proposeFrom(voyage),
      motivo: notifier.previewReason ?? PreviewReason.buqueNuevo,
      fileName: notifier.loadedFileName,
      portOfCall: notifier.previewPortOfCall,
      identidadPendiente: notifier.identityCandidates.isNotEmpty,
      nota: notifier.previewNota,
    );
  }
  return Publicado(voyage);
});
