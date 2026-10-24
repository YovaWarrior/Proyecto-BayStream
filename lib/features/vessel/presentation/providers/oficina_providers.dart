import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/local_vessel_repository.dart';
import 'vessel_providers.dart';

/// Las tres alturas del panel del buque en la oficina (`DESIGN.md` 14.2): la
/// silueta con las tarjetas, la silueta compacta y nada.
enum AlturaDelPuente {
  /// La silueta normal y las tarjetas cortas en una fila o en dos.
  completo('completo'),

  /// La silueta compacta y las tarjetas que caben en una fila.
  compacto('compacto'),

  /// Nada: quedan el borde y la franja de la bahía.
  plegado('plegado');

  const AlturaDelPuente(this.rotulo);

  /// Cómo se dice, también al lector de pantalla.
  final String rotulo;

  /// Una altura más (↓ en el borde); la más alta se queda.
  AlturaDelPuente get mas => switch (this) {
        AlturaDelPuente.plegado => AlturaDelPuente.compacto,
        _ => AlturaDelPuente.completo,
      };

  /// Una altura menos (↑ en el borde); la plegada se queda.
  AlturaDelPuente get menos => switch (this) {
        AlturaDelPuente.completo => AlturaDelPuente.compacto,
        _ => AlturaDelPuente.plegado,
      };
}

/// Lo que la oficina recuerda en este equipo (`DESIGN.md` 14.4).
@immutable
class PreferenciasDeLaOficina {
  const PreferenciasDeLaOficina({
    this.altura = AlturaDelPuente.completo,
    this.panelVisible = true,
    this.panelAlPasarElMouse = true,
  });

  /// El alto del panel del buque.
  final AlturaDelPuente altura;

  /// Si el panel lateral se ve fijo, desde 1200 dp.
  final bool panelVisible;

  /// Si el panel sale flotante cuando el mouse se queda en el borde derecho.
  final bool panelAlPasarElMouse;

  PreferenciasDeLaOficina copyWith({
    AlturaDelPuente? altura,
    bool? panelVisible,
    bool? panelAlPasarElMouse,
  }) =>
      PreferenciasDeLaOficina(
        altura: altura ?? this.altura,
        panelVisible: panelVisible ?? this.panelVisible,
        panelAlPasarElMouse: panelAlPasarElMouse ?? this.panelAlPasarElMouse,
      );

  @override
  bool operator ==(Object other) =>
      other is PreferenciasDeLaOficina &&
      other.altura == altura &&
      other.panelVisible == panelVisible &&
      other.panelAlPasarElMouse == panelAlPasarElMouse;

  @override
  int get hashCode => Object.hash(altura, panelVisible, panelAlPasarElMouse);
}

/// Las preferencias de la oficina, leídas del almacén del equipo al abrir.
/// Mientras se leen, o si la lectura falla, valen las de omisión: un fallo
/// de lectura es «sin valor» (14.4). Lo que se elige se ve al momento, aunque
/// el almacén tarde o no responda.
final preferenciasDeLaOficinaProvider = AsyncNotifierProvider<
    PreferenciasDeLaOficinaNotifier, PreferenciasDeLaOficina>(
  PreferenciasDeLaOficinaNotifier.new,
  retry: (retryCount, error) => null,
);

class PreferenciasDeLaOficinaNotifier
    extends AsyncNotifier<PreferenciasDeLaOficina> {
  // Lo elegido en esta sesión manda sobre una lectura que llegue tarde.
  AlturaDelPuente? _altura;
  bool? _panelVisible;
  bool? _alPasarElMouse;

  /// La última altura abierta, a la que vuelve el panel al desplegarlo.
  AlturaDelPuente _ultimaAbierta = AlturaDelPuente.completo;

  @override
  Future<PreferenciasDeLaOficina> build() async {
    var leidas = const PreferenciasDeLaOficina();
    try {
      final local = await ref.watch(localVesselRepositoryProvider.future);
      Future<String?> leer(UiPreference clave) async {
        try {
          return (await local.getUiPreference(clave))
              .fold((_) => null, (valor) => valor);
        } catch (_) {
          // Un almacén sin la preferencia (o que falla) es «sin valor».
          return null;
        }
      }

      final altura = await leer(UiPreference.bridgeHeight);
      final panel = await leer(UiPreference.sidePanel);
      final mouse = await leer(UiPreference.sidePanelOnHover);
      leidas = PreferenciasDeLaOficina(
        altura: AlturaDelPuente.values
            .where((a) => a.name == altura)
            .firstOrNull ?? AlturaDelPuente.completo,
        panelVisible: panel != 'oculto',
        panelAlPasarElMouse: mouse != 'no',
      );
    } catch (error) {
      debugPrint('No se leyeron las preferencias de la oficina: $error');
    }
    final actuales = _conLoElegido(leidas);
    if (actuales.altura != AlturaDelPuente.plegado) {
      _ultimaAbierta = actuales.altura;
    }
    return actuales;
  }

  PreferenciasDeLaOficina _conLoElegido(PreferenciasDeLaOficina base) =>
      base.copyWith(
        altura: _altura,
        panelVisible: _panelVisible,
        panelAlPasarElMouse: _alPasarElMouse,
      );

  PreferenciasDeLaOficina get _actuales =>
      _conLoElegido(state.value ?? const PreferenciasDeLaOficina());

  /// Elige el alto del panel del buque. Devuelve si se guardó.
  Future<bool> elegirAltura(AlturaDelPuente altura) {
    if (altura != AlturaDelPuente.plegado) _ultimaAbierta = altura;
    _altura = altura;
    state = AsyncData(_actuales);
    return _guardar(UiPreference.bridgeHeight, altura.name);
  }

  /// Pliega el panel del buque o lo devuelve a la última altura abierta
  /// (el botón de la franja de la bahía, el doble clic y Intro en el borde).
  Future<bool> alternarAltura() => elegirAltura(
      _actuales.altura == AlturaDelPuente.plegado
          ? _ultimaAbierta
          : AlturaDelPuente.plegado);

  /// Muestra u oculta el panel lateral fijo. Devuelve si se guardó.
  Future<bool> mostrarPanel(bool visible) {
    _panelVisible = visible;
    state = AsyncData(_actuales);
    return _guardar(UiPreference.sidePanel, visible ? 'visible' : 'oculto');
  }

  /// Enciende o apaga el panel por el borde. Devuelve si se guardó.
  Future<bool> panelAlPasarElMouse(bool encendido) {
    _alPasarElMouse = encendido;
    state = AsyncData(_actuales);
    return _guardar(UiPreference.sidePanelOnHover, encendido ? 'si' : 'no');
  }

  Future<bool> _guardar(UiPreference clave, String valor) async {
    try {
      final local = await ref.read(localVesselRepositoryProvider.future);
      return (await local.setUiPreference(clave, valor))
          .fold((_) => false, (_) => true);
    } catch (error) {
      debugPrint('No se guardó la preferencia ${clave.name}: $error');
      return false;
    }
  }
}
