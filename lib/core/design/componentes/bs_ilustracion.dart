import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../bs_colores_semanticos.dart';
import '../bs_paleta.dart';

/// Un color de una ilustración, por el nombre que lleva en la paleta de
/// `DESIGN.md` 13.1 (`marca`, `cubierta`, `bodega`, `grua`, `frase`, `fondo`,
/// `hoja`, `papel`, `panel`, `panel_alto`, `tinta`, `tinta_suave`, `linea`,
/// `hecho`): el mismo nombre en los dos temas, o uno por tema. `null` en un
/// tema quiere decir que ahí esa parte no se pinta.
@immutable
class BsColorDeIlustracion {
  /// El mismo color en claro y en oscuro.
  const BsColorDeIlustracion.fijo(String nombre)
      : claro = nombre,
        oscuro = nombre;

  /// Un color por tema.
  const BsColorDeIlustracion.porTema({this.claro, this.oscuro});

  /// El nombre en el tema claro, o nada.
  final String? claro;

  /// El nombre en el tema oscuro, o nada.
  final String? oscuro;

  /// El nombre que toca en [brillo].
  String? de(Brightness brillo) => brillo == Brightness.dark ? oscuro : claro;

  /// Los nombres que usa, sin repetir.
  Set<String> get nombres =>
      <String>{if (claro != null) claro!, if (oscuro != null) oscuro!};

  @override
  bool operator ==(Object other) =>
      other is BsColorDeIlustracion &&
      other.claro == claro &&
      other.oscuro == oscuro;

  @override
  int get hashCode => Object.hash(claro, oscuro);
}

/// Una forma de una ilustración: la ruta (solo `M`, `L`, `C` y `Z`
/// absolutos, en las unidades del lienzo), el relleno y el trazo por nombre,
/// el grosor del trazo y, si lo lleva, el punteado como `[pintado, hueco]`.
@immutable
class BsFormaDeIlustracion {
  /// Crea la forma.
  const BsFormaDeIlustracion({
    required this.grupo,
    required this.ruta,
    this.relleno,
    this.trazo,
    this.grosor = 0,
    this.punteado,
  });

  /// A qué parte del dibujo pertenece («agua», «muelle», «celda_vacia»).
  final String grupo;

  /// La ruta SVG.
  final String ruta;

  /// El relleno, o nada.
  final BsColorDeIlustracion? relleno;

  /// El trazo, o nada.
  final BsColorDeIlustracion? trazo;

  /// El grosor del trazo, en las unidades del lienzo; 0 es sin trazo.
  final double grosor;

  /// El punteado del trazo, `[pintado, hueco]`, o nada.
  final List<double>? punteado;
}

/// Una ilustración del paquete: su lienzo, su descripción y sus formas.
@immutable
class BsDatosDeIlustracion {
  /// Crea los datos.
  const BsDatosDeIlustracion({
    required this.nombre,
    required this.descripcion,
    required this.ancho,
    required this.alto,
    this.fondo = 'fondo',
    required this.formas,
  });

  /// El nombre del paquete («inicio», «sin_conexion»).
  final String nombre;

  /// Qué muestra, en una frase: la etiqueta accesible por omisión.
  final String descripcion;

  /// El ancho del lienzo.
  final double ancho;

  /// El alto del lienzo.
  final double alto;

  /// El nombre del color del fondo (el papel o la noche).
  final String fondo;

  /// Las formas, de atrás hacia adelante.
  final List<BsFormaDeIlustracion> formas;

  /// Los nombres de color que usan el fondo y las formas.
  Set<String> get coloresUsados => <String>{
        fondo,
        for (final forma in formas) ...?forma.relleno?.nombres,
        for (final forma in formas) ...?forma.trazo?.nombres,
      };
}

/// Resuelve un nombre de color de las ilustraciones a un token de la app, para
/// el tema de [paleta]. Los nombres son los de `DESIGN.md` 13.1 y el paquete
/// los documenta con su hex por tema; aquí no se copia ningún hex: cada
/// nombre es un token, y `test/t114_ilustraciones_test.dart` comprueba que da
/// el mismo color que el paquete declara. Un nombre desconocido es un error de
/// datos, no un color de respaldo.
Color? colorDeIlustracion(
  String? nombre, {
  required BsPaleta paleta,
  required BsColoresSemanticos semanticos,
}) =>
    switch (nombre) {
      null => null,
      'fondo' || 'papel' => paleta.papel,
      'hoja' || 'panel' => paleta.hoja,
      'panel_alto' => paleta.hojaAlta,
      'tinta' => paleta.tinta,
      'tinta_suave' => paleta.tintaSuave,
      'linea' => paleta.linea,
      // La marca de las ilustraciones es el azul del ícono en los dos temas:
      // la marca como superficie (13.1), no el azul de selección de la noche.
      'marca' => paleta.marcaSuperficie,
      'frase' => paleta.sobreMarcaSuave,
      'bodega' => paleta.acero,
      'grua' => paleta.gruaRelleno,
      'hecho' => semanticos.hecho.contorno,
      // El blanco de la cubierta del ícono (13.2) es el mismo de día y de
      // noche: de día es el papel; de noche, el relleno de «por bajar en
      // cubierta», que es ese blanco sobre la noche.
      'cubierta' => paleta.brillo == Brightness.dark
          ? semanticos.porBajarCubierta.relleno
          : paleta.papel,
      _ => throw ArgumentError.value(
          nombre, 'nombre', 'No es un color de la paleta de las ilustraciones'),
    };

final RegExp _token = RegExp(r'[A-Za-z]|-?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?');
final RegExp _letra = RegExp(r'^[A-Za-z]$');

/// Lee una ruta SVG con solo `M`, `L`, `C` y `Z` absolutos (lo que el paquete
/// exporta) y devuelve su `Path`. Cualquier otro comando es un error de datos.
Path rutaDeIlustracion(String ruta) {
  final path = Path();
  final tokens = _token.allMatches(ruta).map((m) => m.group(0)!).toList();
  var i = 0;
  String? comando;
  double numero() {
    if (i >= tokens.length) {
      throw FormatException('La ruta termina a medias', ruta);
    }
    final valor = double.tryParse(tokens[i]);
    if (valor == null) {
      throw FormatException('Se esperaba un número y llegó «${tokens[i]}»', ruta);
    }
    i++;
    return valor;
  }

  while (i < tokens.length) {
    if (_letra.hasMatch(tokens[i])) {
      comando = tokens[i];
      i++;
      if (comando == 'Z' || comando == 'z') {
        path.close();
        comando = null;
        continue;
      }
    }
    switch (comando) {
      case 'M':
        final x = numero();
        final y = numero();
        path.moveTo(x, y);
        // Más pares después de una M son líneas, como en SVG.
        comando = 'L';
      case 'L':
        final x = numero();
        final y = numero();
        path.lineTo(x, y);
      case 'C':
        final x1 = numero();
        final y1 = numero();
        final x2 = numero();
        final y2 = numero();
        final x = numero();
        final y = numero();
        path.cubicTo(x1, y1, x2, y2, x, y);
      case null:
        throw FormatException('Un número sin comando', ruta);
      default:
        throw FormatException(
            'Comando «$comando» no admitido: solo M, L, C y Z absolutos', ruta);
    }
  }
  return path;
}

/// La ruta a trazos: [patron] es `[pintado, hueco]` en las unidades del lienzo
/// (y se repite). Es lo que SVG hace con `stroke-dasharray`.
Path rutaPunteada(Path ruta, List<double> patron) {
  final salida = Path();
  if (patron.isEmpty || patron.every((p) => p <= 0)) return ruta;
  for (final metrica in ruta.computeMetrics()) {
    var desde = 0.0;
    var indice = 0;
    var pintado = true;
    while (desde < metrica.length) {
      final paso = patron[indice % patron.length];
      final hasta = math.min(desde + paso, metrica.length);
      if (pintado && paso > 0) {
        salida.addPath(metrica.extractPath(desde, hasta), Offset.zero);
      }
      desde = hasta;
      indice++;
      pintado = !pintado;
    }
  }
  return salida;
}

/// Una ilustración del paquete de Nube (`DESIGN.md` 13.7 y 13.9), pintada con
/// `CustomPainter` desde sus datos: el inicio, «todavía no hay viajes»,
/// «ningún contenedor coincide», «trabajando solo en este equipo», «descarga
/// completa» y «sin posibles incumplimientos». Línea de plano técnico con los
/// rellenos planos de la paleta, los colores por nombre y resueltos con los
/// tokens del tema (claro u oscuro), los trazos con puntas y uniones redondas y
/// el punteado donde el paquete lo pide. Dentro de un `RepaintBoundary`, con su
/// etiqueta accesible como imagen.
///
/// Mide lo que le den de ancho (o [ancho]) y conserva la proporción del lienzo,
/// sin pasar de su parte del alto de la ventana ([anchoQueCabe]): el dibujo
/// acompaña a la frase y cede ante la letra grande, no al revés.
/// Con [conFondo] pinta también el papel o la noche detrás; sin él, el dibujo
/// se apoya en el fondo de la pantalla, que es el mismo color.
class BsIlustracion extends StatelessWidget {
  /// Crea la ilustración.
  const BsIlustracion({
    super.key,
    required this.datos,
    this.etiqueta,
    this.ancho,
    this.conFondo = false,
  });

  /// Qué se pinta.
  final BsDatosDeIlustracion datos;

  /// La etiqueta accesible; por omisión, la descripción de los datos.
  final String? etiqueta;

  /// El ancho, si no es el que dé el padre.
  final double? ancho;

  /// Si pinta el fondo del lienzo.
  final bool conFondo;

  /// La parte del alto de la ventana que un dibujo puede ocupar (13.11, regla
  /// 4): tres décimas, divididas por la escala de la letra, para que ceda ante
  /// el texto grande y la frase y su acción sigan en la primera pantalla del
  /// teléfono bajo (360 × 640 con la letra a 2.0, T-114).
  static const double parteDelAlto = 0.3;

  /// Por debajo de este alto el dibujo ya no se lee, y no se pinta.
  static const double altoMinimo = 120;

  /// El ancho con el que [datos] cabe en su parte del alto de la ventana, sin
  /// pasar de [ancho] si se da; `null` cuando no llega a [altoMinimo].
  static double? anchoQueCabe(
    BuildContext context,
    BsDatosDeIlustracion datos, {
    double? ancho,
  }) {
    final ventana = MediaQuery.sizeOf(context).height;
    final letra = MediaQuery.textScalerOf(context).scale(1);
    final proporcion = datos.alto / datos.ancho;
    final maximo = ventana * parteDelAlto / letra / proporcion;
    final elegido = ancho == null ? maximo : math.min(ancho, maximo);
    return elegido * proporcion < altoMinimo ? null : elegido;
  }

  @override
  Widget build(BuildContext context) {
    final anchoReal = anchoQueCabe(context, datos, ancho: ancho);
    if (anchoReal == null) {
      return const SizedBox.shrink();
    }
    final paleta = BsPaleta.de(Theme.of(context).brightness);
    final semanticos = BsColoresSemanticos.de(context);
    return Semantics(
      label: etiqueta ?? datos.descripcion,
      image: true,
      excludeSemantics: true,
      child: SizedBox(
        width: anchoReal,
        child: AspectRatio(
          aspectRatio: datos.ancho / datos.alto,
          child: RepaintBoundary(
            child: CustomPaint(
              painter: PintorDeIlustracion(
                datos: datos,
                paleta: paleta,
                semanticos: semanticos,
                conFondo: conFondo,
              ),
              size: Size.infinite,
            ),
          ),
        ),
      ),
    );
  }
}

/// El pintor de [BsIlustracion]: escala el lienzo al tamaño que le den, sin
/// deformarlo, y pinta cada forma de atrás hacia adelante. Las rutas se leen
/// una vez por texto y se guardan: los datos son constantes.
class PintorDeIlustracion extends CustomPainter {
  /// Crea el pintor.
  const PintorDeIlustracion({
    required this.datos,
    required this.paleta,
    required this.semanticos,
    this.conFondo = false,
  });

  /// Qué se pinta.
  final BsDatosDeIlustracion datos;

  /// La paleta del tema.
  final BsPaleta paleta;

  /// Los roles del tema (para «hecho» y la cubierta de noche).
  final BsColoresSemanticos semanticos;

  /// Si pinta el fondo del lienzo.
  final bool conFondo;

  static final Map<String, Path> _rutas = <String, Path>{};

  static Path _ruta(BsFormaDeIlustracion forma, {required bool punteada}) {
    final base = _rutas[forma.ruta] ??= rutaDeIlustracion(forma.ruta);
    if (!punteada) return base;
    final clave = '${forma.ruta}|${forma.punteado}';
    return _rutas[clave] ??= rutaPunteada(base, forma.punteado!);
  }

  Color? _color(String? nombre) =>
      colorDeIlustracion(nombre, paleta: paleta, semanticos: semanticos);

  @override
  void paint(Canvas canvas, Size size) {
    final escala = math.min(size.width / datos.ancho, size.height / datos.alto);
    canvas.save();
    canvas.translate((size.width - datos.ancho * escala) / 2,
        (size.height - datos.alto * escala) / 2);
    canvas.scale(escala);
    if (conFondo) {
      final fondo = _color(datos.fondo);
      if (fondo != null) {
        canvas.drawRect(
            Rect.fromLTWH(0, 0, datos.ancho, datos.alto), Paint()..color = fondo);
      }
    }
    for (final forma in datos.formas) {
      final relleno = _color(forma.relleno?.de(paleta.brillo));
      if (relleno != null) {
        canvas.drawPath(
          _ruta(forma, punteada: false),
          Paint()
            ..color = relleno
            ..style = PaintingStyle.fill,
        );
      }
      final trazo = _color(forma.trazo?.de(paleta.brillo));
      if (trazo != null && forma.grosor > 0) {
        canvas.drawPath(
          _ruta(forma, punteada: forma.punteado != null),
          Paint()
            ..color = trazo
            ..style = PaintingStyle.stroke
            ..strokeWidth = forma.grosor
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(PintorDeIlustracion anterior) =>
      !identical(anterior.datos, datos) ||
      anterior.paleta != paleta ||
      anterior.semanticos != semanticos ||
      anterior.conFondo != conFondo;
}
