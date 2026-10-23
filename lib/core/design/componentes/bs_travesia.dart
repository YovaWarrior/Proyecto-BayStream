import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../bs_colores_semanticos.dart';
import '../bs_ilustraciones.dart';
import '../bs_movimiento.dart';
import '../bs_paleta.dart';
import 'bs_ilustracion.dart';

/// Dónde está el buque en un instante del cruce: el borde izquierdo de su
/// caja desde el borde izquierdo de la banda, su opacidad, el vaivén sobre la
/// línea de flotación (dp, positivo hacia abajo) y el cabeceo (radianes).
typedef BsInstanteDeTravesia = ({
  double x,
  double opacidad,
  double vaiven,
  double cabeceo,
});

/// La travesía del inicio (`DESIGN.md` 13.11, regla 7; decisión 10.24): un
/// buque navega de izquierda a derecha por una banda de mar al pie del inicio,
/// se desvanece al llegar a la derecha, el mar queda vacío tres segundos y
/// vuelve a salir por la izquierda.
///
/// No hay arte nuevo: el buque son los grupos `casco_perfil`, `perfil_0_0` a
/// `perfil_0_4`, `caseta` y `puente` de la ilustración `sin_conexion`, sin la
/// nube ni la pausa, reflejados para que la proa mire hacia donde va (la única
/// excepción a «la proa a la izquierda», que sigue valiendo para lo que está
/// quieto); el mar es el agua y la línea de flotación de esa misma ilustración,
/// a todo el ancho, y las olas y la estela llevan el trazo de esa línea. Los
/// colores van por nombre y salen de los tokens del tema, como en
/// [BsIlustracion]; nada es naranja.
///
/// La banda mide lo que le den: el agua ocupa el tercio de abajo (al menos
/// [aguaMinima]) y el buque mide la mitad del alto de la banda, entre
/// [buqueMinimo] y [buqueMaximo]. Por debajo de [altoMinimo] no se pinta nada
/// (13.11, regla 4). El buque y las tiras de las olas se pintan una sola vez,
/// cada uno dentro de su `RepaintBoundary`, en cajas que no cambian de sitio
/// ni de tamaño en ningún cuadro; lo que cambia por cuadro es solo un
/// `Transform` (el cruce, el vaivén y el cabeceo del buque; el corrimiento de
/// cada ola) y una opacidad. Con reducción de movimiento el buque queda
/// quieto a un tercio del ancho, las olas no corren y no hay ningún ticker
/// activo; con otra pantalla encima (`TickerMode`) o con la app en segundo
/// plano (`AppLifecycleState`) se detiene. Es decorativa: sin semántica, sin
/// foco y sin toque.
class BsTravesia extends StatefulWidget {
  /// Crea la travesía.
  const BsTravesia({super.key});

  /// Por debajo de este alto la banda no se pinta (13.11, regla 4).
  static const double altoMinimo = BsIlustracion.altoMinimo;

  /// El agua ocupa el tercio de abajo de la banda, y nunca menos que esto.
  static const double aguaMinima = 32;

  /// El buque mide la mitad del alto de la banda, y nunca menos que esto.
  static const double buqueMinimo = 56;

  /// Ni más que esto.
  static const double buqueMaximo = 120;

  /// La velocidad del cruce, en dp por segundo.
  static const double velocidad = 48;

  /// El cruce no dura menos que esto, aunque la banda sea angosta.
  static const Duration cruceMinimo = Duration(seconds: 14);

  /// Ni más que esto, aunque sea ancha.
  static const Duration cruceMaximo = Duration(seconds: 40);

  /// El mar vacío entre un cruce y el siguiente.
  static const Duration pausa = Duration(seconds: 3);

  /// La parte del recorrido en la que el buque aparece.
  static const double parteDeEntrada = 0.10;

  /// La parte del recorrido en la que se desvanece.
  static const double parteDeSalida = 0.12;

  /// Cuánto sube y baja sobre la línea de flotación.
  static const double vaivenDp = 1.5;

  /// Cada cuánto.
  static const Duration vaivenPeriodo = Duration(milliseconds: 3200);

  /// Cuánto cabecea, en grados, hacia cada lado.
  static const double cabeceoGrados = 0.8;

  /// Cada cuánto.
  static const Duration cabeceoPeriodo = Duration(milliseconds: 4400);

  /// La ola lenta corre hacia la izquierda a esta velocidad, en dp por segundo.
  static const double olaLenta = 8;

  /// Y la rápida, a esta.
  static const double olaRapida = 16;

  /// Cada cuántos dp se repite la tira de una ola, sin costura.
  static const double pasoDeOla = 48;

  /// Cuántas veces se ha pintado el dibujo del buque desde que se puso a cero.
  /// Solo para las pruebas: tiene que ser una por travesía montada, no una
  /// por cuadro.
  @visibleForTesting
  static int pintadasDelBuque = 0;

  /// La duración del cruce para un [recorrido] en dp (el ancho de la banda más
  /// el del buque, que entra desde fuera y sale del todo): a [velocidad],
  /// entre [cruceMinimo] y [cruceMaximo].
  static Duration duracionDelCruce(double recorrido) {
    final segundos = (recorrido / velocidad).clamp(
      cruceMinimo.inMilliseconds / 1000,
      cruceMaximo.inMilliseconds / 1000,
    );
    return Duration(milliseconds: (segundos * 1000).round());
  }

  /// La opacidad del buque según el [progreso] del cruce, de 0 a 1: sube de 0
  /// a 1 en el primer 10 % y baja de 1 a 0 en el último 12 %; fuera del cruce
  /// es 0.
  static double opacidadDelCruce(double progreso) {
    if (progreso <= 0 || progreso >= 1) return 0;
    if (progreso < parteDeEntrada) return progreso / parteDeEntrada;
    if (progreso > 1 - parteDeSalida) return (1 - progreso) / parteDeSalida;
    return 1;
  }

  @override
  State<BsTravesia> createState() => _BsTravesiaState();
}

/// Las medidas de una travesía para una banda de [ancho] × [alto]: dónde
/// está el agua, cuánto mide el buque y cuánto dura el cruce. Pública para
/// que las pruebas comprueben las reglas sin leer píxeles.
@immutable
class BsGeometriaDeTravesia {
  /// Las medidas para una banda de [ancho] × [alto].
  factory BsGeometriaDeTravesia(double ancho, double alto) {
    final alturaDelAgua = math.max(BsTravesia.aguaMinima, alto / 3);
    final altoDelBuque = (alto / 2)
        .clamp(BsTravesia.buqueMinimo, BsTravesia.buqueMaximo)
        .toDouble();
    final escala = altoDelBuque / _Lienzo.altoDelBuque;
    final anchoDelBuque = _Lienzo.anchoDelBuque * escala;
    return BsGeometriaDeTravesia._(
      ancho: ancho,
      alto: alto,
      alturaDelAgua: alturaDelAgua,
      altoDelBuque: altoDelBuque,
      anchoDelBuque: anchoDelBuque,
      escala: escala,
      duracion: BsTravesia.duracionDelCruce(ancho + anchoDelBuque),
    );
  }

  const BsGeometriaDeTravesia._({
    required this.ancho,
    required this.alto,
    required this.alturaDelAgua,
    required this.altoDelBuque,
    required this.anchoDelBuque,
    required this.escala,
    required this.duracion,
  });

  /// El ancho de la banda.
  final double ancho;

  /// El alto de la banda.
  final double alto;

  /// Cuánto mide el agua, desde la línea de flotación hasta abajo.
  final double alturaDelAgua;

  /// Cuánto mide el buque de alto, con su obra viva.
  final double altoDelBuque;

  /// Cuánto mide de ancho, con la estela.
  final double anchoDelBuque;

  /// Cuántos dp mide una unidad del lienzo de `sin_conexion`.
  final double escala;

  /// Cuánto dura el cruce.
  final Duration duracion;

  /// Dónde está la línea de flotación, desde arriba de la banda.
  double get lineaDeFlotacion => alto - alturaDelAgua;

  /// Lo que el buque recorre: entra desde fuera y sale del todo.
  double get recorrido => ancho + anchoDelBuque;

  /// Un cruce y el mar vacío que lo sigue.
  Duration get ciclo => duracion + BsTravesia.pausa;

  /// Dónde va el borde de arriba de la caja del buque cuando no hay vaivén.
  double get altoDelBuqueSobreElAgua =>
      (_Lienzo.flotacion - _Lienzo.limitesDelBuque.top) * escala;

  /// Alrededor de qué punto de su caja cabecea el buque: el centro del casco
  /// sobre la línea de flotación, ya reflejado.
  Alignment get ejeDelCabeceo {
    final x = _Lienzo.anchoDelBuque -
        (_Lienzo.casco.center.dx - _Lienzo.limitesDelBuque.left);
    final y = _Lienzo.flotacion - _Lienzo.limitesDelBuque.top;
    return Alignment(
      x / _Lienzo.anchoDelBuque * 2 - 1,
      y / _Lienzo.altoDelBuque * 2 - 1,
    );
  }

  /// El eje del cabeceo dentro de la caja del buque, en dp.
  Offset get ejeDelCabeceoEnLaCaja {
    final eje = ejeDelCabeceo;
    return Offset(
        (eje.x + 1) / 2 * anchoDelBuque, (eje.y + 1) / 2 * altoDelBuque);
  }

  /// Dónde va el borde de arriba de la caja fija del buque, desde arriba
  /// de la banda: la caja no se mueve; el vaivén va en la transformación.
  double get arribaDeLaCaja => lineaDeFlotacion - altoDelBuqueSobreElAgua;

  /// La transformación de la caja fija del buque en un [instante]: la
  /// traslación del cruce y del vaivén, y el giro del cabeceo alrededor de
  /// su eje. Es lo único que cambia por cuadro; el layout de la caja no
  /// cambia nunca (10.26, H1).
  Matrix4 transformacion(BsInstanteDeTravesia instante) {
    final eje = ejeDelCabeceoEnLaCaja;
    return Matrix4.identity()
      ..translateByDouble(instante.x, instante.vaiven, 0, 1)
      ..translateByDouble(eje.dx, eje.dy, 0, 1)
      ..rotateZ(instante.cabeceo)
      ..translateByDouble(-eje.dx, -eje.dy, 0, 1);
  }

  /// Dónde están las dos olas, desde arriba de la banda: a un tercio y a dos
  /// tercios del agua.
  List<double> get olas => <double>[
        lineaDeFlotacion + alturaDelAgua / 3,
        lineaDeFlotacion + alturaDelAgua * 2 / 3,
      ];

  /// El buque en el instante [t] de la travesía; durante el mar vacío, fuera
  /// de la banda y con opacidad 0.
  BsInstanteDeTravesia instante(Duration t) {
    final enCiclo = t.inMicroseconds % ciclo.inMicroseconds;
    final progreso = enCiclo / duracion.inMicroseconds;
    if (progreso >= 1) {
      return (x: -anchoDelBuque, opacidad: 0, vaiven: 0, cabeceo: 0);
    }
    final segundos = t.inMicroseconds / Duration.microsecondsPerSecond;
    return (
      x: -anchoDelBuque + progreso * recorrido,
      opacidad: BsTravesia.opacidadDelCruce(progreso),
      vaiven: BsTravesia.vaivenDp *
          math.sin(
              2 * math.pi * segundos / _segundos(BsTravesia.vaivenPeriodo)),
      cabeceo: BsTravesia.cabeceoGrados *
          math.pi /
          180 *
          math.sin(
              2 * math.pi * segundos / _segundos(BsTravesia.cabeceoPeriodo)),
    );
  }

  /// El buque quieto, con reducción de movimiento: a un tercio del ancho.
  BsInstanteDeTravesia get quieto => (
        x: ancho / 3 - anchoDelBuque / 2,
        opacidad: 1,
        vaiven: 0,
        cabeceo: 0,
      );

  /// Cuánto se ha corrido hacia la izquierda una ola que va a [velocidad]
  /// en el instante [t], dentro de su paso.
  static double corrimientoDeOla(Duration t, double velocidad) =>
      (velocidad * t.inMicroseconds / Duration.microsecondsPerSecond) %
      BsTravesia.pasoDeOla;

  static double _segundos(Duration d) =>
      d.inMicroseconds / Duration.microsecondsPerSecond;
}

/// Lo que la travesía toma de `sin_conexion` (`BsIlustraciones`): las formas
/// del buque, el agua y la línea de flotación, y sus medidas en el lienzo.
/// Las rutas se leen una vez; los datos son constantes.
abstract final class _Lienzo {
  static const Set<String> gruposDelBuque = <String>{
    'casco_perfil',
    'perfil_0_0',
    'perfil_0_1',
    'perfil_0_2',
    'perfil_0_3',
    'perfil_0_4',
    'caseta',
    'puente',
  };

  /// Cuánto lienzo deja la estela detrás de la popa.
  static const double estela = 52;

  static final List<BsFormaDeIlustracion> buque = BsIlustraciones
      .sinConexion.formas
      .where((f) => gruposDelBuque.contains(f.grupo))
      .toList(growable: false);

  static final BsFormaDeIlustracion agua =
      BsIlustraciones.sinConexion.formas.firstWhere((f) => f.grupo == 'agua');

  static final BsFormaDeIlustracion lineaDeFlotacion = BsIlustraciones
      .sinConexion.formas
      .firstWhere((f) => f.grupo == 'flotacion');

  /// La caja del buque en el lienzo, sin la estela.
  static final Rect limitesDelBuque = buque
      .map((f) => rutaDeIlustracion(f.ruta).getBounds())
      .reduce((a, b) => a.expandToInclude(b));

  /// La caja del casco solo, para el eje del cabeceo.
  static final Rect casco =
      rutaDeIlustracion(buque.firstWhere((f) => f.grupo == 'casco_perfil').ruta)
          .getBounds();

  /// A qué altura del lienzo está la línea de flotación.
  static final double flotacion =
      rutaDeIlustracion(lineaDeFlotacion.ruta).getBounds().top;

  /// El ancho de la caja del buque con su estela, en unidades del lienzo.
  static double get anchoDelBuque => limitesDelBuque.width + estela;

  /// Y su alto.
  static double get altoDelBuque => limitesDelBuque.height;
}

class _BsTravesiaState extends State<BsTravesia>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final Ticker _ticker;
  final ValueNotifier<Duration> _tiempo =
      ValueNotifier<Duration>(const Duration());

  /// Lo andado antes de la última parada, para seguir desde ahí.
  Duration _base = const Duration();
  bool _reducido = false;
  bool _enPrimerPlano = true;

  /// Si la banda tiene sitio para pintarse; sin sitio, el ticker no corre.
  bool _cabe = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tic);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reducido = BsMovimiento.reducido(context);
    _ajustar();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Con la ventana sin foco (inactive) se sigue viendo; en segundo plano, no.
    _enPrimerPlano = state == AppLifecycleState.resumed ||
        state == AppLifecycleState.inactive;
    _ajustar();
  }

  void _tic(Duration transcurrido) {
    _tiempo.value = _base + transcurrido;
  }

  /// Corre solo cuando tiene sitio, se ve y el sistema no pide reducir el
  /// movimiento. Con otra pantalla encima, `TickerMode` silencia el ticker
  /// por sí solo.
  void _ajustar() {
    final debeCorrer = _cabe && !_reducido && _enPrimerPlano;
    if (debeCorrer && !_ticker.isActive) {
      _ticker.start();
    } else if (!debeCorrer && _ticker.isActive) {
      _base = _tiempo.value;
      _ticker.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    _tiempo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: IgnorePointer(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints limites) {
            final ancho = limites.maxWidth;
            final alto = limites.maxHeight;
            final cabe = ancho.isFinite &&
                alto.isFinite &&
                ancho > 0 &&
                alto >= BsTravesia.altoMinimo;
            if (cabe != _cabe) {
              // Sin sitio, el ticker no corre; con sitio, arranca. Después
              // de este cuadro, no durante la construcción.
              _cabe = cabe;
              SchedulerBinding.instance.addPostFrameCallback((_) {
                if (mounted) _ajustar();
              });
            }
            if (!cabe) {
              return const SizedBox.shrink();
            }
            final geometria = BsGeometriaDeTravesia(ancho, alto);
            final paleta = BsPaleta.de(Theme.of(context).brightness);
            final semanticos = BsColoresSemanticos.de(context);
            return Stack(
              clipBehavior: Clip.hardEdge,
              children: <Widget>[
                // El mar: el agua y la línea de flotación, quietos.
                Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _PintorDelMar(
                        geometria: geometria,
                        paleta: paleta,
                        semanticos: semanticos,
                      ),
                    ),
                  ),
                ),
                // Las dos olas: cada tira se pinta una vez y corre hacia la
                // izquierda dentro de su paso; una pasada más de tira a la
                // derecha es lo que hace la repetición sin costura.
                for (final (indice, y) in geometria.olas.indexed)
                  Positioned(
                    left: 0,
                    top: y - _PintorDeOla.alto / 2,
                    width: ancho + BsTravesia.pasoDeOla,
                    height: _PintorDeOla.alto,
                    child: ValueListenableBuilder<Duration>(
                      valueListenable: _tiempo,
                      builder: (BuildContext context, Duration t, Widget? ola) {
                        final corrimiento = _reducido
                            ? 0.0
                            : BsGeometriaDeTravesia.corrimientoDeOla(
                                t,
                                indice == 0
                                    ? BsTravesia.olaLenta
                                    : BsTravesia.olaRapida,
                              );
                        return Transform.translate(
                          offset: Offset(-corrimiento, 0),
                          child: ola,
                        );
                      },
                      child: RepaintBoundary(
                        child: CustomPaint(
                          painter: _PintorDeOla(
                            geometria: geometria,
                            paleta: paleta,
                            semanticos: semanticos,
                          ),
                        ),
                      ),
                    ),
                  ),
                // El buque: se pinta una vez, y su caja no cambia de sitio ni
                // de tamaño en ningún cuadro (10.26, H1). Por cuadro cambian
                // solo la opacidad y un Transform: la traslación del cruce y
                // del vaivén, y el giro del cabeceo.
                Positioned(
                  left: 0,
                  top: geometria.arribaDeLaCaja,
                  width: geometria.anchoDelBuque,
                  height: geometria.altoDelBuque,
                  child: ValueListenableBuilder<Duration>(
                    valueListenable: _tiempo,
                    builder: (BuildContext context, Duration t, Widget? buque) {
                      final instante =
                          _reducido ? geometria.quieto : geometria.instante(t);
                      return Opacity(
                        opacity: instante.opacidad,
                        child: Transform(
                          transform: geometria.transformacion(instante),
                          child: buque,
                        ),
                      );
                    },
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: _PintorDelBuque(
                          escala: geometria.escala,
                          paleta: paleta,
                          semanticos: semanticos,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// El agua a todo el ancho y la línea de flotación encima, con el relleno y el
/// trazo de `sin_conexion` resueltos por nombre.
class _PintorDelMar extends CustomPainter {
  const _PintorDelMar({
    required this.geometria,
    required this.paleta,
    required this.semanticos,
  });

  final BsGeometriaDeTravesia geometria;
  final BsPaleta paleta;
  final BsColoresSemanticos semanticos;

  Color? _color(String? nombre) =>
      colorDeIlustracion(nombre, paleta: paleta, semanticos: semanticos);

  @override
  void paint(Canvas canvas, Size size) {
    final agua = _color(_Lienzo.agua.relleno?.de(paleta.brillo));
    final y = geometria.lineaDeFlotacion;
    if (agua != null) {
      canvas.drawRect(
          Rect.fromLTRB(0, y, size.width, size.height), Paint()..color = agua);
    }
    final trazo = _color(_Lienzo.lineaDeFlotacion.trazo?.de(paleta.brillo));
    if (trazo != null) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        Paint()
          ..color = trazo
          ..strokeWidth = _Lienzo.lineaDeFlotacion.grosor * geometria.escala
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_PintorDelMar anterior) =>
      anterior.geometria.lineaDeFlotacion != geometria.lineaDeFlotacion ||
      anterior.geometria.escala != geometria.escala ||
      anterior.paleta != paleta ||
      anterior.semanticos != semanticos;
}

/// Una tira de ola: una curva suave que se repite cada [BsTravesia.pasoDeOla],
/// con el trazo de la línea de flotación más suave.
class _PintorDeOla extends CustomPainter {
  const _PintorDeOla({
    required this.geometria,
    required this.paleta,
    required this.semanticos,
  });

  /// El alto de la tira: la amplitud hacia cada lado y el trazo.
  static const double alto = 6;

  /// Cuánto sube y baja la ola.
  static const double amplitud = 1.5;

  final BsGeometriaDeTravesia geometria;
  final BsPaleta paleta;
  final BsColoresSemanticos semanticos;

  @override
  void paint(Canvas canvas, Size size) {
    final trazo = colorDeIlustracion(
        _Lienzo.lineaDeFlotacion.trazo?.de(paleta.brillo),
        paleta: paleta,
        semanticos: semanticos);
    if (trazo == null) return;
    final medio = size.height / 2;
    const paso = BsTravesia.pasoDeOla;
    // Cada media onda es una cúbica con los controles a 4/3 de la amplitud:
    // la curva llega a la amplitud en el centro y sale plana por los
    // extremos, así que una tira sigue a la otra sin costura.
    const control = amplitud * 4 / 3;
    final ruta = Path()..moveTo(0, medio);
    var x = 0.0;
    var signo = -1.0;
    while (x < size.width) {
      final hasta = x + paso / 2;
      ruta.cubicTo(x + paso / 6, medio + signo * control, x + paso / 3,
          medio + signo * control, hasta, medio);
      x = hasta;
      signo = -signo;
    }
    canvas.drawPath(
      ruta,
      Paint()
        ..color = trazo.withValues(alpha: trazo.a * 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, 1.25 * geometria.escala)
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_PintorDeOla anterior) =>
      anterior.geometria.escala != geometria.escala ||
      anterior.paleta != paleta ||
      anterior.semanticos != semanticos;
}

/// El buque de `sin_conexion` reflejado, con la proa a la derecha, y la
/// estela detrás de la popa: tres trazos que se apagan. Se pinta una vez por
/// travesía montada: lo cuenta [BsTravesia.pintadasDelBuque].
class _PintorDelBuque extends CustomPainter {
  const _PintorDelBuque({
    required this.escala,
    required this.paleta,
    required this.semanticos,
  });

  final double escala;
  final BsPaleta paleta;
  final BsColoresSemanticos semanticos;

  /// Los tres trazos de la estela: dónde empieza cada uno detrás de la popa,
  /// cuánto mide y cuánto se ha apagado, en unidades del lienzo.
  static const List<({double desde, double largo, double alfa})> estela = [
    (desde: 6, largo: 18, alfa: 0.6),
    (desde: 28, largo: 12, alfa: 0.4),
    (desde: 44, largo: 7, alfa: 0.2),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    BsTravesia.pintadasDelBuque++;
    final limites = _Lienzo.limitesDelBuque;
    canvas.save();
    // Del lienzo a la caja, reflejado: la popa (la caseta y el puente) queda
    // a la izquierda y la proa, a la derecha, hacia donde navega.
    canvas.scale(escala);
    canvas.translate(_Lienzo.anchoDelBuque, 0);
    canvas.scale(-1, 1);
    canvas.translate(-limites.left, -limites.top);
    for (final forma in _Lienzo.buque) {
      pintarFormaDeIlustracion(canvas, forma,
          paleta: paleta, semanticos: semanticos);
    }
    final trazo = colorDeIlustracion(
        _Lienzo.lineaDeFlotacion.trazo?.de(paleta.brillo),
        paleta: paleta,
        semanticos: semanticos);
    if (trazo != null) {
      final y = _Lienzo.flotacion;
      for (final tramo in estela) {
        final desde = limites.right + tramo.desde;
        canvas.drawLine(
          Offset(desde, y),
          Offset(desde + tramo.largo, y),
          Paint()
            ..color = trazo.withValues(alpha: trazo.a * tramo.alfa)
            ..strokeWidth = _Lienzo.lineaDeFlotacion.grosor
            ..strokeCap = StrokeCap.round,
        );
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PintorDelBuque anterior) =>
      anterior.escala != escala ||
      anterior.paleta != paleta ||
      anterior.semanticos != semanticos;
}
