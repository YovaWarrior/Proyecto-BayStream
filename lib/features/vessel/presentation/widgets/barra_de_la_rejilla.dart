import 'package:flutter/material.dart';

/// La barra horizontal de la rejilla de la oficina (T-119, `DESIGN.md` 16.4).
///
/// Envuelve la columna central, que se desplaza en vertical, y dibuja pegada
/// a su borde de abajo, justo encima de la franja de cifras, la barra del
/// desplazamiento horizontal de la rejilla, aunque el pie de la rejilla esté
/// más abajo: como en una hoja de cálculo. Es la barra de Material con el
/// controlador de la rejilla, que la rejilla toma de aquí con [controladorDe],
/// y que solo escucha lo que se desplaza en ese controlador.
///
/// Solo aparece cuando la bahía no cabe a lo ancho. Entonces se ve siempre,
/// con su pista; el pulgar se arrastra con el mouse y un clic en la pista
/// avanza una página (el 80 % de la vista, como cualquier barra de Flutter).
/// La columna deja [aire] abajo mientras la barra está: la barra va en ese
/// aire y nunca tapa celdas.
class BarraDeLaRejilla extends StatefulWidget {
  const BarraDeLaRejilla({super.key, required this.child});

  /// La columna central.
  final Widget child;

  /// Lo que mide la barra de Material con su pista en escritorio: 12 dp de
  /// grosor y 2 de margen.
  static const double aire = 14;

  /// El controlador del desplazamiento horizontal de la rejilla, si la
  /// rejilla está dentro de una [BarraDeLaRejilla].
  static ScrollController? controladorDe(BuildContext context) => context
      .getInheritedWidgetOfExactType<_ControladorDeLaRejilla>()
      ?.controlador;

  @override
  State<BarraDeLaRejilla> createState() => _BarraDeLaRejillaState();
}

class _BarraDeLaRejillaState extends State<BarraDeLaRejilla> {
  late final ScrollController _controlador =
      ScrollController(onAttach: _cambio, onDetach: _cambio);

  /// Si la bahía no cabe a lo ancho, según la última medida de la rejilla.
  bool _desborda = false;

  /// Al cambiar de bahía la rejilla se arma de nuevo: el desplazamiento viejo
  /// se suelta al final del cuadro, cuando el árbol no admite cambios. Se
  /// vuelve a mirar después del cuadro; si no quedó rejilla (una bahía sin
  /// geometría), la barra se va.
  void _cambio(ScrollPosition _) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        if (!_controlador.hasClients) _desborda = false;
      });
    });
  }

  /// Lo que se desplaza en el controlador de la rejilla, y nada más: la
  /// silueta y la columna llevan sus propios desplazamientos.
  bool _esDeLaRejilla(ScrollNotification notificacion) => _controlador
      .positions
      .any((p) => p.context.notificationContext == notificacion.context);

  bool _alMedir(ScrollMetricsNotification notificacion) {
    if (!_esDeLaRejilla(notificacion.asScrollUpdate())) return false;
    final desborda = notificacion.metrics.maxScrollExtent > 0;
    if (desborda != _desborda) setState(() => _desborda = desborda);
    return false;
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _desborda && _controlador.positions.length == 1;
    return _ControladorDeLaRejilla(
      controlador: _controlador,
      child: NotificationListener<ScrollMetricsNotification>(
        onNotification: _alMedir,
        child: Scrollbar(
          key: const ValueKey('barra-de-la-rejilla'),
          controller: _controlador,
          thumbVisibility: visible,
          trackVisibility: visible,
          interactive: true,
          scrollbarOrientation: ScrollbarOrientation.bottom,
          notificationPredicate: _esDeLaRejilla,
          child: Padding(
            padding:
                EdgeInsets.only(bottom: visible ? BarraDeLaRejilla.aire : 0),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _ControladorDeLaRejilla extends InheritedWidget {
  const _ControladorDeLaRejilla(
      {required this.controlador, required super.child});

  final ScrollController controlador;

  @override
  bool updateShouldNotify(_ControladorDeLaRejilla oldWidget) =>
      !identical(controlador, oldWidget.controlador);
}
