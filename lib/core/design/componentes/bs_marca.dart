import 'package:flutter/material.dart';

import '../bs_movimiento.dart';
import '../bs_paleta.dart';

/// Cómo se dibuja la marca (`DESIGN.md`, 13.6 y 13.7).
enum BsVarianteDeMarca {
  /// Sobre su recuadro azul con las esquinas del ícono: el riel, el inicio.
  conRecuadro,

  /// Solo el dibujo, para apoyarlo en la banda azul del muelle.
  sinRecuadro,

  /// Todo en un solo color: el contenedor se reconoce por estar fuera de la
  /// cuadrícula, como en el ícono temático de Android.
  monocroma,
}

/// La marca de BayStream pintada desde la geometría de
/// `design/icono/baystream.svg`: dos filas de cubierta, la tapa de escotilla,
/// la bodega que se cierra con el casco y el contenedor naranja que salió de
/// su celda (13.6).
///
/// Con [espera], es la espera de la app: el contenedor sube y baja medio
/// módulo en un bucle de `BsMovimiento.espera`, solo con `Transform`; si el
/// sistema pide reducir el movimiento, se queda quieto en su sitio. Lleva su
/// etiqueta accesible y, mientras espera, lo dice.
class BsMarca extends StatefulWidget {
  /// Crea la marca.
  const BsMarca({
    super.key,
    this.tamano = 40,
    this.variante = BsVarianteDeMarca.conRecuadro,
    this.color,
    this.espera = false,
    this.etiqueta = 'BayStream',
  });

  /// El lado del cuadrado que ocupa.
  final double tamano;

  /// Con recuadro, sin recuadro o monocroma.
  final BsVarianteDeMarca variante;

  /// El color de la variante monocroma; por omisión, la tinta del tema.
  final Color? color;

  /// La espera: el contenedor sube y baja.
  final bool espera;

  /// La etiqueta accesible.
  final String etiqueta;

  /// El lado del lienzo del ícono (las unidades de `baystream.svg`).
  static const double lienzo = 100;

  /// El paso entre celdas, en unidades del lienzo.
  static const double modulo = 13.8;

  /// Cuánto sube el contenedor en la espera: medio módulo.
  static const double subida = modulo / 2;

  @override
  State<BsMarca> createState() => _BsMarcaState();
}

class _BsMarcaState extends State<BsMarca>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controlador = AnimationController(
    vsync: this,
    duration: BsMovimiento.espera,
  );
  late final Animation<double> _curva =
      CurvedAnimation(parent: _controlador, curve: BsMovimiento.vaiven);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ajustar();
  }

  @override
  void didUpdateWidget(BsMarca anterior) {
    super.didUpdateWidget(anterior);
    if (anterior.espera != widget.espera) _ajustar();
  }

  void _ajustar() {
    if (widget.espera && !BsMovimiento.reducido(context)) {
      if (!_controlador.isAnimating) _controlador.repeat(reverse: true);
    } else {
      _controlador.stop();
      _controlador.value = 0;
    }
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final paleta = BsPaleta.de(tema.brightness);
    final mono = widget.variante == BsVarianteDeMarca.monocroma;
    final tinta = widget.color ?? tema.colorScheme.onSurface;
    return Semantics(
      image: true,
      label: widget.espera ? '${widget.etiqueta}, leyendo' : widget.etiqueta,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: widget.tamano,
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _curva,
            builder: (BuildContext context, Widget? _) => CustomPaint(
              painter: _MarcaPainter(
                conRecuadro: widget.variante == BsVarianteDeMarca.conRecuadro,
                recuadro: paleta.marcaSuperficie,
                cubierta: mono ? tinta : BsPaleta.claro.papel,
                bodega: mono ? tinta : paleta.acero,
                contenedor: mono ? tinta : paleta.gruaRelleno,
                subida: _curva.value,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// El ícono, en las unidades de `baystream.svg` (lienzo de 100; el recuadro
/// de la forma propia va de −13.3 a 113.3 con esquinas de 27).
class _MarcaPainter extends CustomPainter {
  const _MarcaPainter({
    required this.conRecuadro,
    required this.recuadro,
    required this.cubierta,
    required this.bodega,
    required this.contenedor,
    required this.subida,
  });

  final bool conRecuadro;
  final Color recuadro;
  final Color cubierta;
  final Color bodega;
  final Color contenedor;

  /// De 0 (en su sitio) a 1 (medio módulo más arriba).
  final double subida;

  static const double _celda = 11;
  static const double _radio = 1.9;
  static const List<double> _columnas = <double>[23.8, 37.6, 51.4, 65.2];

  @override
  void paint(Canvas canvas, Size size) {
    final lado = conRecuadro ? 126.6 : BsMarca.lienzo;
    final escala = size.shortestSide / lado;
    canvas.save();
    canvas.scale(escala);
    if (conRecuadro) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(0, 0, 126.6, 126.6),
          const Radius.circular(27),
        ),
        Paint()..color = recuadro,
      );
      canvas.translate(13.3, 13.3);
    }
    final pintaCubierta = Paint()..color = cubierta;
    final pintaBodega = Paint()..color = bodega;
    // La cubierta: dos filas; en la primera falta la celda de la que salió el
    // contenedor (columna 51.4).
    for (final x in _columnas) {
      if (x != 51.4) _celdaEn(canvas, x, 21.05, pintaCubierta);
      _celdaEn(canvas, x, 34.85, pintaCubierta);
    }
    // La tapa de escotilla.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(17.8, 48.65, 64.4, 5.4),
        const Radius.circular(2.7),
      ),
      pintaCubierta,
    );
    // La bodega: tres filas que se cierran con el casco.
    _poligono(canvas, _bodegaIzquierda1, pintaBodega);
    _celdaEn(canvas, 37.6, 56.85, pintaBodega);
    _celdaEn(canvas, 51.4, 56.85, pintaBodega);
    _poligono(canvas, _bodegaDerecha1, pintaBodega);
    _poligono(canvas, _bodegaIzquierda2, pintaBodega);
    _celdaEn(canvas, 37.6, 70.65, pintaBodega);
    _celdaEn(canvas, 51.4, 70.65, pintaBodega);
    _poligono(canvas, _bodegaDerecha2, pintaBodega);
    _poligono(canvas, _bodegaIzquierda3, pintaBodega);
    _poligono(canvas, _bodegaDerecha3, pintaBodega);
    // El contenedor en la grúa: flota sobre el hueco y, en la espera, sube
    // medio módulo y vuelve.
    canvas.save();
    canvas.translate(0, -BsMarca.subida * subida);
    _celdaEn(canvas, 51.4, 4.55, Paint()..color = contenedor);
    canvas.restore();
    canvas.restore();
  }

  void _celdaEn(Canvas canvas, double x, double y, Paint pintura) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, _celda, _celda),
        const Radius.circular(_radio),
      ),
      pintura,
    );
  }

  void _poligono(Canvas canvas, List<Offset> puntos, Paint pintura) {
    final camino = Path()..moveTo(puntos.first.dx, puntos.first.dy);
    for (final punto in puntos.skip(1)) {
      camino.lineTo(punto.dx, punto.dy);
    }
    camino.close();
    canvas.drawPath(camino, pintura);
  }

  @override
  bool shouldRepaint(_MarcaPainter anterior) =>
      anterior.conRecuadro != conRecuadro ||
      anterior.recuadro != recuadro ||
      anterior.cubierta != cubierta ||
      anterior.bodega != bodega ||
      anterior.contenedor != contenedor ||
      anterior.subida != subida;

  // Los bloques de los extremos de la bodega, tal como los traza el SVG: el
  // costado curvo del casco y el resto de la celda.
  static const List<Offset> _bodegaIzquierda1 = <Offset>[
    Offset(24.87, 67), Offset(24.67, 65.85), Offset(24.49, 64.71),
    Offset(24.33, 63.59), Offset(24.19, 62.49), Offset(24.07, 61.41),
    Offset(23.97, 60.36), Offset(23.9, 59.35), Offset(23.84, 58.4),
    Offset(23.81, 57.53), Offset(23.8, 56.85), Offset(34.8, 56.85),
    Offset(34.8, 67.85), Offset(25.04, 67.85),
  ];
  static const List<Offset> _bodegaDerecha1 = <Offset>[
    Offset(65.2, 56.85), Offset(76.2, 56.85), Offset(76.19, 57.53),
    Offset(76.16, 58.4), Offset(76.1, 59.35), Offset(76.03, 60.36),
    Offset(75.93, 61.41), Offset(75.81, 62.49), Offset(75.67, 63.59),
    Offset(75.51, 64.71), Offset(75.33, 65.85), Offset(75.13, 67),
    Offset(74.96, 67.85), Offset(65.2, 67.85),
  ];
  static const List<Offset> _bodegaIzquierda2 = <Offset>[
    Offset(29.15, 81.52), Offset(28.73, 80.49), Offset(28.32, 79.44),
    Offset(27.92, 78.37), Offset(27.54, 77.28), Offset(27.17, 76.18),
    Offset(26.83, 75.06), Offset(26.49, 73.92), Offset(26.18, 72.78),
    Offset(25.88, 71.63), Offset(25.64, 70.65), Offset(34.8, 70.65),
    Offset(34.8, 81.65), Offset(29.21, 81.65),
  ];
  static const List<Offset> _bodegaDerecha2 = <Offset>[
    Offset(65.2, 70.65), Offset(74.36, 70.65), Offset(74.12, 71.63),
    Offset(73.82, 72.78), Offset(73.51, 73.92), Offset(73.17, 75.06),
    Offset(72.83, 76.18), Offset(72.46, 77.28), Offset(72.08, 78.37),
    Offset(71.68, 79.44), Offset(71.27, 80.49), Offset(70.85, 81.52),
    Offset(70.79, 81.65), Offset(65.2, 81.65),
  ];
  static const List<Offset> _bodegaIzquierda3 = <Offset>[
    Offset(40.78, 95.43), Offset(40.39, 95.35), Offset(39.97, 95.23),
    Offset(39.52, 95.06), Offset(39.05, 94.84), Offset(38.56, 94.58),
    Offset(38.07, 94.27), Offset(37.6, 93.93), Offset(37.6, 84.45),
    Offset(48.6, 84.45), Offset(48.6, 95.45), Offset(41.09, 95.45),
  ];
  static const List<Offset> _bodegaDerecha3 = <Offset>[
    Offset(51.4, 84.45), Offset(62.4, 84.45), Offset(62.4, 93.93),
    Offset(61.93, 94.27), Offset(61.44, 94.58), Offset(60.95, 94.84),
    Offset(60.48, 95.06), Offset(60.03, 95.23), Offset(59.61, 95.35),
    Offset(59.22, 95.43), Offset(58.91, 95.45), Offset(51.4, 95.45),
  ];
}
