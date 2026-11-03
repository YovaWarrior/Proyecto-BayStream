import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../bs_movimiento.dart';

/// La rueda del mouse en un desplazable horizontal (`DESIGN.md` 16.1, T-119).
///
/// Un desplazable horizontal de Flutter solo toma el componente horizontal
/// de la rueda, y la rueda del mouse trae solo el vertical: sin esto, sobre la
/// silueta del buque la rueda no movía nada. Va **alrededor** del desplazable
/// que arma [constructor], con el [controlador] que le dan o con uno propio:
/// dentro no serviría, porque mientras el desplazable anima su contenido no
/// recibe el puntero, y el segundo paso de la rueda se iría a la columna.
///
/// Con la rueda hacia abajo el desplazable avanza (hacia la popa, en la
/// silueta) y hacia arriba regresa, con [BsMovimiento.rueda] de animación, o
/// sin ella si el sistema reduce el movimiento. Se registra en el resolvedor
/// de señales (`GestureBinding.pointerSignalResolver`), donde gana el primero
/// que se registra: como está más adentro que la columna que lo contiene, la
/// columna no se mueve a la vez. Si el desplazable ya no puede moverse en ese
/// sentido, no se registra y la rueda pasa a la columna.
///
/// No toma lo que ya tiene dueño: la rueda con más componente horizontal que
/// vertical (el touchpad en la Web) la toma el desplazable; Mayús + rueda, el
/// desplazable, que invierte los ejes del mouse; Ctrl + rueda, nadie aquí.
/// Respeta el pestillo de [BsPestilloDeLaRueda] si lo hay encima.
class BsRuedaHorizontal extends StatefulWidget {
  /// Arma con [constructor] el desplazable horizontal, con [controlador] o,
  /// si es nulo, con uno propio.
  const BsRuedaHorizontal(
      {super.key, this.controlador, required this.constructor});

  /// El controlador del desplazable, si la pantalla lo maneja.
  final ScrollController? controlador;

  /// El desplazable horizontal, con el controlador que debe usar.
  final Widget Function(BuildContext context, ScrollController controlador)
      constructor;

  @override
  State<BsRuedaHorizontal> createState() => _BsRuedaHorizontalState();
}

class _BsRuedaHorizontalState extends State<BsRuedaHorizontal> {
  ScrollController? _propio;

  ScrollController get _controlador =>
      widget.controlador ?? (_propio ??= ScrollController());

  /// Adónde va la animación en curso: cada paso de la rueda suma al anterior,
  /// no a donde la animación alcanzó a llegar.
  double? _destino;

  ScrollPosition? get _posicion {
    final controlador = _controlador;
    return controlador.positions.length == 1 ? controlador.position : null;
  }

  void _alRecibir(PointerSignalEvent evento) {
    if (evento is! PointerScrollEvent) return;
    final delta = evento.scrollDelta;
    if (delta.dy == 0 || delta.dx.abs() >= delta.dy.abs()) return;
    final teclado = HardwareKeyboard.instance;
    if (teclado.isControlPressed || teclado.isShiftPressed) return;
    final pestillo = BsPestilloDeLaRueda.maybeOf(context);
    if (pestillo != null && pestillo.retiene(evento)) return;
    final posicion = _posicion;
    if (posicion == null ||
        !posicion.hasContentDimensions ||
        !posicion.physics.shouldAcceptUserOffset(posicion)) {
      return;
    }
    final desde = _destino ?? posicion.pixels;
    final hasta = (desde + delta.dy)
        .clamp(posicion.minScrollExtent, posicion.maxScrollExtent)
        .toDouble();
    // En el extremo, la rueda es de la columna.
    if (hasta == desde) return;
    GestureBinding.instance.pointerSignalResolver
        .register(evento, (_) => _mover(hasta));
    // Lo único más adentro que se registra con la rueda vertical sería el
    // desplazable con Mayús, y entonces no se llega aquí: el evento es suyo.
    pestillo?.tomar(evento);
  }

  void _mover(double hasta) {
    final posicion = _posicion;
    if (!mounted || posicion == null) return;
    final duracion = BsMovimiento.de(context, BsMovimiento.rueda);
    if (duracion == Duration.zero) {
      _destino = null;
      posicion.jumpTo(hasta);
      return;
    }
    _destino = hasta;
    posicion
        .animateTo(hasta, duration: duracion, curve: BsMovimiento.entrada)
        .whenComplete(() {
      if (_destino == hasta) _destino = null;
    });
  }

  @override
  void dispose() {
    _propio?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Listener(
        onPointerSignal: _alRecibir,
        child: widget.constructor(context, _controlador),
      );
}

/// El pestillo de la rueda (`DESIGN.md` 16.1 y la tabla de 14.1): si la
/// columna se desplazó con la rueda hace menos de [plazo], la rueda sigue con
/// la columna aunque un [BsRuedaHorizontal] pase bajo el puntero. Sin él, al
/// bajar la página la silueta llega bajo el mouse y se roba la rueda.
///
/// Envuelve la columna que se desplaza. Anota la hora de cada paso de la rueda
/// vertical que llega a la columna y no tomó nadie más adentro; Ctrl + rueda
/// no cuenta, porque es el zoom. Usa la hora del evento, no la del reloj.
class BsPestilloDeLaRueda extends StatefulWidget {
  /// Envuelve [child], la columna.
  const BsPestilloDeLaRueda({super.key, required this.child});

  /// La columna.
  final Widget child;

  /// Cuánto dura el pestillo después del último paso de la rueda.
  static const Duration plazo = Duration(milliseconds: 300);

  /// El pestillo de la columna que contiene [context], si lo hay.
  static BsRegistroDeLaRueda? maybeOf(BuildContext context) => context
      .getInheritedWidgetOfExactType<_PestilloHeredado>()
      ?.registro;

  @override
  State<BsPestilloDeLaRueda> createState() => _BsPestilloDeLaRuedaState();
}

/// Lo que el pestillo recuerda de la rueda de su columna.
class BsRegistroDeLaRueda {
  Duration? _ultimaDeLaColumna;
  PointerEvent? _tomado;

  /// Verdadero si la rueda es todavía de la columna.
  bool retiene(PointerScrollEvent evento) {
    final ultima = _ultimaDeLaColumna;
    if (ultima == null) return false;
    final pasado = evento.timeStamp - ultima;
    return pasado >= Duration.zero && pasado < BsPestilloDeLaRueda.plazo;
  }

  /// Un desplazable de dentro tomó [evento]: no es de la columna.
  void tomar(PointerSignalEvent evento) => _tomado = _sinTransformar(evento);

  /// Cada escucha recibe el evento en sus coordenadas, como un objeto aparte:
  /// el mismo evento es el mismo original.
  static PointerEvent _sinTransformar(PointerEvent evento) =>
      evento.original ?? evento;

  void _anotar(PointerSignalEvent evento) {
    if (evento is! PointerScrollEvent ||
        identical(_sinTransformar(evento), _tomado)) {
      return;
    }
    final delta = evento.scrollDelta;
    if (delta.dy == 0 || delta.dx.abs() >= delta.dy.abs()) return;
    if (HardwareKeyboard.instance.isControlPressed) return;
    _ultimaDeLaColumna = evento.timeStamp;
  }
}

class _BsPestilloDeLaRuedaState extends State<BsPestilloDeLaRueda> {
  final BsRegistroDeLaRueda _registro = BsRegistroDeLaRueda();

  @override
  Widget build(BuildContext context) => _PestilloHeredado(
        registro: _registro,
        // Los de dentro reciben el evento antes que este escucha: cuando
        // llega aquí, ya se sabe si alguno lo tomó.
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerSignal: _registro._anotar,
          child: widget.child,
        ),
      );
}

class _PestilloHeredado extends InheritedWidget {
  const _PestilloHeredado({required this.registro, required super.child});

  final BsRegistroDeLaRueda registro;

  @override
  bool updateShouldNotify(_PestilloHeredado oldWidget) =>
      !identical(registro, oldWidget.registro);
}
