import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../bs_iconos.dart';

import '../bs_colores_semanticos.dart';
import '../bs_medidas.dart';
import '../bs_movimiento.dart';
import '../bs_paleta.dart';
import '../bs_tipografia.dart';

/// La insignia de carga especial que la celda lleva en su esquina, siempre,
/// en cualquiera de las tres vistas de «Colorear por».
enum BsInsigniaDeCelda {
  /// Sin carga especial.
  ninguna,

  /// Mercancía peligrosa (IMO).
  peligrosa,

  /// Refrigerado.
  refrigerado,

  /// Sobredimensionado (OOG).
  oog,
}

/// La marca de la operación sobre la celda, en los modos Descarga y Carga:
/// icono y rótulo además del color, para leerse a 360 dp y en los dos temas.
enum BsMarcaDeCelda {
  /// Sin marca: la celda muestra su código.
  ninguna,

  /// Pendiente de descarga: «Baja».
  baja,

  /// Pendiente de carga: «Sube».
  sube,

  /// Descargado o cargado: «Hecho».
  hecho,

  /// Sigue a bordo en esta escala: «Paso».
  paso,

  /// Cancelado por la oficina.
  cancelado,

  /// Conflicto en la bitácora: «Revisar».
  revisar,

  /// Re‑estiba: sale y vuelve.
  reestiba,
}

/// El estado de la celda en la vista Estado (`DESIGN.md`, 13.2): el plano
/// dibujado como el ícono. Decide el relleno; la [BsMarcaDeCelda] pone el
/// icono y el rótulo encima.
enum BsEstadoDeCelda {
  /// Sin estado: el relleno es la categoría.
  ninguno,

  /// Por bajar, en cubierta: el blanco de la cubierta del ícono (de día, la
  /// marca con texto blanco).
  porBajarCubierta,

  /// Por bajar, en bodega: el acero de la bodega del ícono.
  porBajarBodega,

  /// De paso: apagado.
  dePaso,

  /// Bajado: de día el rol hecho; de noche la celda vacía con el contorno
  /// punteado y la palomita.
  bajado,

  /// Lo que se acaba de mover (13.3): el naranja de la grúa; sale de su celda
  /// y dura `BsMovimiento.recienMovido`.
  recienMovido,
}

/// La curva del casco en una celda de los extremos de la bodega (13.2).
enum BsCurvaDeCelda {
  /// Una celda corriente.
  ninguna,

  /// La celda de babor: la esquina inferior izquierda lleva la curva.
  babor,

  /// La celda de estribor: la esquina inferior derecha lleva la curva.
  estribor,

  /// La celda sola en la fila más baja: las dos esquinas.
  ambas,
}

/// La celda del plano: un contenedor, una reserva o un hueco (`DESIGN.md`,
/// secciones 4.3, 5 y 13.2).
///
/// Mide lo que dicen las medidas del tema (56 × 48 en el muelle, 52 × 48 en la
/// oficina): nunca menos de 48 dp de alto, para tocarla con guantes. El
/// relleno es la [categoria] (el destino o el tipo) o el [estado] de la vista
/// Estado; la [insignia] y la [marca] llevan icono y rótulo, así que el color
/// nunca es la única señal.
///
/// Lo que se dibuja cumple el contraste en todos los estados, compuesto sobre
/// el papel (`test/t114_celda_contraste_test.dart` y
/// `test/t114_fase2bis_test.dart`): el código 4.5:1 sobre el relleno
/// compuesto, y el contorno y los iconos 3:1. [atenuada] baja el relleno a un
/// 35 % compuesto sobre el papel (opaco, sin [Opacity]) y pone el código en
/// tinta suave, o en tinta si la suave no llega, y el contorno en línea
/// fuerte; nunca alfa en el texto (10.7, H1). La [linea2] de 10 sp solo se
/// dibuja en la oficina, con [zoom] de 100 % o más y si cabe con la escala de
/// letra del sistema; en el muelle nunca (`DESIGN.md`, 4.2; 10.7, H2).
///
/// [BsEstadoDeCelda.recienMovido] sale de su celda media celda hacia arriba
/// con `Transform` en `BsMovimiento.salida`, desde donde estaba (la misma
/// celda, de 0 a media celda en 150 ms), y deja el hueco punteado en su sitio,
/// como el contenedor del ícono; si el sistema pide reducir el movimiento, se
/// dibuja en naranja en su sitio, quieta (13.3). Al volver a otro estado no se
/// ve regresar. La pantalla apaga el estado al cumplirse
/// `BsMovimiento.recienMovido`.
class BsCelda extends StatelessWidget {
  /// Crea una celda.
  const BsCelda({
    super.key,
    required this.codigo,
    required this.etiqueta,
    this.categoria,
    this.linea2,
    this.insignia = BsInsigniaDeCelda.ninguna,
    this.marca = BsMarcaDeCelda.ninguna,
    this.estado = BsEstadoDeCelda.ninguno,
    this.curva = BsCurvaDeCelda.ninguna,
    this.resaltada = false,
    this.atenuada = false,
    this.reservada = false,
    this.zoom = 1.0,
    this.onTap,
  });

  /// El texto principal: el puerto con sus cinco letras, el tipo ISO o el
  /// número de orden.
  final String codigo;

  /// La etiqueta de accesibilidad completa, con el número de contenedor, la
  /// posición y lo que la celda muestra. Se conserva en todos los estados; la
  /// celda recién movida le añade «se acaba de mover».
  final String etiqueta;

  /// El rol de color del relleno. Sin él ni [estado], la celda es un hueco.
  final BsRol? categoria;

  /// La segunda línea: el peso en toneladas o el tipo. Solo se dibuja en la
  /// oficina, con [zoom] de 1.0 o más, sin marca y si cabe; en el muelle se
  /// ignora aunque venga.
  final String? linea2;

  /// La insignia de carga especial.
  final BsInsigniaDeCelda insignia;

  /// La marca de la operación.
  final BsMarcaDeCelda marca;

  /// El estado de la vista Estado. Manda sobre [categoria] en el relleno.
  final BsEstadoDeCelda estado;

  /// La curva del casco, en las celdas de los extremos de la bodega.
  final BsCurvaDeCelda curva;

  /// Resaltada por una búsqueda o una alerta: contorno de grúa.
  final bool resaltada;

  /// Fuera del filtro de «Resaltar»: relleno al [alfaAtenuada], código en
  /// tinta suave (o tinta) y contorno en línea fuerte.
  final bool atenuada;

  /// Una reserva: solo contorno, sin relleno.
  final bool reservada;

  /// El factor de zoom de la rejilla: 1.0 es 100 %. Gobierna la [linea2]; el
  /// tamaño de la celda lo decide la rejilla, no este parámetro.
  final double zoom;

  /// Qué pasa al tocarla. Sin él, la celda no es un botón.
  final VoidCallback? onTap;

  /// El alfa del relleno de una celda atenuada.
  static const double alfaAtenuada = 0.35;

  /// El tamaño del icono de la marca.
  static const double tamanoIconoDeMarca = 14;

  /// El tamaño de la insignia de la esquina.
  static const double tamanoInsignia = 12;

  /// Cuánto sube la celda recién movida: media celda.
  static const Offset salida = Offset(0, -0.5);

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final medidas = BsMedidas.de(context);
    final semanticos = BsColoresSemanticos.de(context);
    final textos =
        tema.extension<BsTextos>() ?? BsTextos.de(BsPaleta.de(tema.brightness));
    final esquema = tema.colorScheme;
    final escala = MediaQuery.textScalerOf(context);

    final esHueco =
        categoria == null && !reservada && estado == BsEstadoDeCelda.ninguno;
    final hueco = BsRol(
      relleno: esquema.surfaceContainerLow,
      texto: esquema.onSurfaceVariant,
      contorno: esquema.outlineVariant,
    );
    final base = categoria ?? (reservada ? semanticos.reservado : hueco);
    final rolDeMarca = switch (marca) {
      BsMarcaDeCelda.ninguna => null,
      BsMarcaDeCelda.baja || BsMarcaDeCelda.sube => semanticos.pendiente,
      BsMarcaDeCelda.hecho => semanticos.hecho,
      BsMarcaDeCelda.paso => semanticos.dePaso,
      BsMarcaDeCelda.cancelado => semanticos.cancelado,
      BsMarcaDeCelda.revisar => semanticos.revisar,
      BsMarcaDeCelda.reestiba => semanticos.enMovimiento,
    };
    final rolDeEstado = switch (estado) {
      BsEstadoDeCelda.ninguno => null,
      BsEstadoDeCelda.porBajarCubierta => semanticos.porBajarCubierta,
      BsEstadoDeCelda.porBajarBodega => semanticos.porBajarBodega,
      BsEstadoDeCelda.dePaso => semanticos.dePaso,
      BsEstadoDeCelda.bajado => semanticos.bajado,
      BsEstadoDeCelda.recienMovido => semanticos.recienMovido,
    };
    // El estado de la vista Estado manda en el relleno; la marca, si viene,
    // pone el icono y el rótulo.
    final rol = rolDeEstado ?? rolDeMarca ?? base;
    // Atenuada (10.7): baja el relleno, compuesto sobre el papel; el código y
    // el contorno cambian de color, no de alfa. El hueco conserva su línea.
    final efectivo = atenuada
        ? rol.atenuado(
            papel: esquema.surface,
            tintaSuave: esquema.onSurfaceVariant,
            tinta: esquema.onSurface,
            lineaFuerte:
                esHueco && rolDeMarca == null ? rol.contorno : esquema.outline,
            alfa: alfaAtenuada,
          )
        : rol;
    final contorno = resaltada ? esquema.tertiary : efectivo.contorno;
    final grosor = resaltada ? 3.0 : medidas.grosorContornoCelda;
    final insigniaRol = switch (insignia) {
      BsInsigniaDeCelda.ninguna => null,
      BsInsigniaDeCelda.peligrosa => semanticos.peligrosa,
      BsInsigniaDeCelda.refrigerado => semanticos.refrigerado,
      BsInsigniaDeCelda.oog => semanticos.oog,
    };
    // La insignia va siempre y se lee sobre cualquier relleno: el color de su
    // rol si llega a 3:1 sobre el relleno; si no (los rellenos intensos en
    // oscuro, el naranja), el texto del rol o la tinta de la celda, que
    // siempre llegan. Atenuada, la tinta del código: nunca alfa.
    final colorDeInsignia = insigniaRol == null
        ? null
        : atenuada
            ? efectivo.texto
            : _legibleSobre(efectivo.relleno, <Color>[
                insigniaRol.contorno,
                insigniaRol.texto,
                efectivo.texto,
              ]);

    // Qué cabe en el alto interior con la escala de letra del sistema: nada
    // se corta ni desborda a 1.45 ni a 2.0 (RNF-003). Las líneas miden
    // tamaño × interlínea, porque los estilos de la celda fijan `height`.
    final altoInterior = medidas.altoCelda - 2 * grosor;
    double altoDe(TextStyle estilo) =>
        escala.scale(estilo.fontSize ?? BsEscala.celda) * (estilo.height ?? 1);
    final altoDelCodigo = altoDe(textos.celda);
    final conMarca = marca != BsMarcaDeCelda.ninguna;
    final esBajado = estado == BsEstadoDeCelda.bajado;
    final esRecienMovido = estado == BsEstadoDeCelda.recienMovido;
    // Bajada sin marca: solo la palomita, el contenedor ya no está.
    final soloPalomita = esBajado && !conMarca;
    final icono = conMarca
        ? _iconoDeMarca(marca)
        : soloPalomita
            ? Icons.check
            : null;
    final muestraIcono = icono != null &&
        (soloPalomita || altoDelCodigo + tamanoIconoDeMarca <= altoInterior);
    final texto = conMarca
        ? _rotuloDeMarca(marca, recienMovido: esRecienMovido)
        : soloPalomita
            ? ''
            : codigo;
    final muestraLinea2 = linea2 != null &&
        !conMarca &&
        !soloPalomita &&
        !medidas.esMuelle &&
        zoom >= 1.0 &&
        altoDelCodigo + altoDe(textos.celdaLinea2) <= altoInterior;

    final radio = _radio(medidas);
    final punteado = efectivo.punteado && !resaltada;
    final caja = Container(
      width: medidas.anchoCelda,
      height: medidas.altoCelda,
      decoration: BoxDecoration(
        color: efectivo.relleno,
        borderRadius: radio,
        border: punteado ? null : Border.all(color: contorno, width: grosor),
      ),
      child: Stack(
          children: <Widget>[
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (muestraIcono)
                    Icon(
                      icono,
                      size: soloPalomita
                          ? tamanoIconoDeMarca + medidas.espacioXs
                          : tamanoIconoDeMarca,
                      color: efectivo.texto,
                    ),
                  if (texto.isNotEmpty)
                    Text(
                      texto,
                      style: textos.celda.copyWith(color: efectivo.texto),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  if (muestraLinea2)
                    Text(
                      linea2!,
                      style: textos.celdaLinea2.copyWith(color: efectivo.texto),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
            if (insigniaRol != null)
              Positioned(
                top: 1,
                right: 1,
                child: Icon(
                  _iconoDeInsignia(insignia),
                  size: tamanoInsignia,
                  color: colorDeInsignia,
                ),
              ),
          ],
        ),
    );
    // El contorno punteado se pinta encima de la caja; si no hay, no hay
    // CustomPaint.
    final cuerpo = punteado
        ? CustomPaint(
            foregroundPainter: BsContornoPunteado(
                color: contorno, grosor: grosor, radio: radio),
            child: caja,
          )
        : caja;

    // La celda recién movida sale de su sitio (13.3): el hueco punteado queda
    // debajo y el cuerpo sube media celda con `Transform`, de 0 a media celda
    // en 150 ms desde el estado anterior de esta misma celda; quieta si el
    // sistema pide reducir el movimiento, y sin vuelta visible al apagarse.
    final dibujo = _Salida(
      sale: esRecienMovido && !BsMovimiento.reducido(context),
      ancho: medidas.anchoCelda,
      alto: medidas.altoCelda,
      radio: radio,
      hueco: esquema.tertiary,
      grosorDelHueco: medidas.grosorContornoCelda,
      halo: esquema.surface,
      child: cuerpo,
    );

    final conHueco = Padding(
      padding: EdgeInsets.all(medidas.huecoCelda / 2),
      child: onTap == null
          ? dibujo
          : InkWell(
              onTap: onTap,
              borderRadius: radio,
              child: dibujo,
            ),
    );
    return Semantics(
      button: onTap != null,
      label: esRecienMovido ? '$etiqueta, se acaba de mover' : etiqueta,
      onTap: onTap,
      excludeSemantics: true,
      child: conHueco,
    );
  }

  BorderRadius _radio(BsMedidas medidas) {
    final celda = Radius.circular(medidas.radioCelda);
    final casco = Radius.circular(medidas.radioCasco);
    return switch (curva) {
      BsCurvaDeCelda.ninguna => BorderRadius.all(celda),
      BsCurvaDeCelda.babor => BorderRadius.only(
          topLeft: celda, topRight: celda, bottomRight: celda, bottomLeft: casco),
      BsCurvaDeCelda.estribor => BorderRadius.only(
          topLeft: celda, topRight: celda, bottomLeft: celda, bottomRight: casco),
      BsCurvaDeCelda.ambas => BorderRadius.only(
          topLeft: celda, topRight: celda, bottomLeft: casco, bottomRight: casco),
    };
  }

  /// El primer color de [candidatos] que llega a 3:1 sobre [fondo], el
  /// mínimo de un icono; si ninguno llega, el de mayor contraste.
  static Color _legibleSobre(Color fondo, List<Color> candidatos) {
    final lf = fondo.computeLuminance();
    var mejor = candidatos.first;
    var mejorContraste = 0.0;
    for (final color in candidatos) {
      final lc = color.computeLuminance();
      final contraste = (math.max(lf, lc) + 0.05) / (math.min(lf, lc) + 0.05);
      if (contraste >= 3) return color;
      if (contraste > mejorContraste) {
        mejorContraste = contraste;
        mejor = color;
      }
    }
    return mejor;
  }

  // Los íconos del dominio del paquete (13.11); los genéricos (hecho,
  // cancelado, revisar) van en su variante rellena, como la familia.
  static IconData _iconoDeMarca(BsMarcaDeCelda marca) => switch (marca) {
        BsMarcaDeCelda.ninguna => Icons.circle_outlined,
        BsMarcaDeCelda.baja => BsIconos.descarga,
        BsMarcaDeCelda.sube => BsIconos.carga,
        BsMarcaDeCelda.hecho => Icons.check_circle,
        BsMarcaDeCelda.paso => BsIconos.buque,
        BsMarcaDeCelda.cancelado => Icons.block,
        BsMarcaDeCelda.revisar => Icons.error,
        BsMarcaDeCelda.reestiba => BsIconos.reestiba,
      };

  static String _rotuloDeMarca(BsMarcaDeCelda marca,
          {required bool recienMovido}) =>
      switch (marca) {
        BsMarcaDeCelda.ninguna => '',
        BsMarcaDeCelda.baja => recienMovido ? 'Bajando' : 'Baja',
        BsMarcaDeCelda.sube => recienMovido ? 'Subiendo' : 'Sube',
        BsMarcaDeCelda.hecho => 'Hecho',
        BsMarcaDeCelda.paso => 'Paso',
        BsMarcaDeCelda.cancelado => 'Cancelado',
        BsMarcaDeCelda.revisar => 'Revisar',
        BsMarcaDeCelda.reestiba => 'Re‑estiba',
      };

  static IconData _iconoDeInsignia(BsInsigniaDeCelda insignia) =>
      switch (insignia) {
        BsInsigniaDeCelda.ninguna => Icons.circle_outlined,
        BsInsigniaDeCelda.peligrosa => BsIconos.insigniaPeligrosa,
        BsInsigniaDeCelda.refrigerado => BsIconos.insigniaRefrigerado,
        BsInsigniaDeCelda.oog => BsIconos.insigniaFueraDeMedida,
      };
}

/// La salida de la celda recién movida (13.3): el mismo widget en todos los
/// estados, para que al pasar a «recién movido» la traslación arranque en
/// cero y recorra media celda en `BsMovimiento.salida`; al dejar de serlo
/// vuelve a cero de golpe, sin animación de regreso. Solo `Transform` y la
/// opacidad del halo; con [sale] falso no hay hueco ni desplazamiento.
class _Salida extends StatefulWidget {
  const _Salida({
    required this.sale,
    required this.ancho,
    required this.alto,
    required this.radio,
    required this.hueco,
    required this.grosorDelHueco,
    required this.halo,
    required this.child,
  });

  final bool sale;
  final double ancho;
  final double alto;
  final BorderRadius radio;
  final Color hueco;
  final double grosorDelHueco;
  final Color halo;
  final Widget child;

  @override
  State<_Salida> createState() => _SalidaState();
}

class _SalidaState extends State<_Salida> with SingleTickerProviderStateMixin {
  late final AnimationController _controlador = AnimationController(
    vsync: this,
    duration: BsMovimiento.salida,
  );
  late final Animation<double> _curva =
      CurvedAnimation(parent: _controlador, curve: BsMovimiento.entrada);

  @override
  void initState() {
    super.initState();
    if (widget.sale) _controlador.forward(from: 0);
  }

  @override
  void didUpdateWidget(_Salida anterior) {
    super.didUpdateWidget(anterior);
    if (widget.sale && !anterior.sale) {
      // Sale desde donde estaba: de 0 a media celda.
      _controlador.forward(from: 0);
    } else if (!widget.sale && anterior.sale) {
      // No se ve regresar: vuelve a su sitio de golpe.
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
  Widget build(BuildContext context) => Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          if (widget.sale)
            CustomPaint(
              painter: BsContornoPunteado(
                color: widget.hueco,
                grosor: widget.grosorDelHueco,
                radio: widget.radio,
              ),
              child: SizedBox(width: widget.ancho, height: widget.alto),
            ),
          AnimatedBuilder(
            animation: _curva,
            child: widget.child,
            builder: (BuildContext context, Widget? child) => Transform.translate(
              offset: Offset(0, BsCelda.salida.dy * widget.alto * _curva.value),
              child: widget.sale
                  ? DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: widget.radio,
                        boxShadow: <BoxShadow>[
                          BoxShadow(color: widget.halo, spreadRadius: 3),
                        ],
                      ),
                      child: child,
                    )
                  : child!,
            ),
          ),
        ],
      );
}

/// El contorno punteado de la celda: la celda bajada de noche y el hueco que
/// deja la celda que sale de su sitio (13.2 y 13.3). Es público para que las
/// pruebas midan el color de lo que se dibuja.
class BsContornoPunteado extends CustomPainter {
  /// Crea el contorno.
  const BsContornoPunteado({
    required this.color,
    required this.grosor,
    required this.radio,
  });

  /// El color del trazo.
  final Color color;

  /// El grosor del trazo.
  final double grosor;

  /// Las esquinas que sigue.
  final BorderRadius radio;

  /// El largo del trazo y del hueco.
  static const double trazo = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final pintura = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = grosor;
    final rect = radio.toRRect(
      Rect.fromLTWH(grosor / 2, grosor / 2, size.width - grosor, size.height - grosor),
    );
    final camino = Path()..addRRect(rect);
    for (final metrica in camino.computeMetrics()) {
      var distancia = 0.0;
      while (distancia < metrica.length) {
        final fin = math.min(distancia + trazo, metrica.length);
        canvas.drawPath(metrica.extractPath(distancia, fin), pintura);
        distancia += trazo * 2;
      }
    }
  }

  @override
  bool shouldRepaint(BsContornoPunteado anterior) =>
      anterior.color != color ||
      anterior.grosor != grosor ||
      anterior.radio != radio;
}
