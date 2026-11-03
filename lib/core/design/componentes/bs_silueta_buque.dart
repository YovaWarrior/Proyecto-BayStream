import 'package:flutter/material.dart';

import '../bs_colores_semanticos.dart';
import '../bs_formato.dart';
import '../bs_medidas.dart';
import '../bs_movimiento.dart';
import '../bs_tipografia.dart';
import 'bs_rueda_horizontal.dart';

/// Una bahía en la silueta: su número, cuántos niveles ocupados tiene en
/// cubierta y en bodega, su avance en esta escala y si tiene trabajo en ella.
@immutable
class BsBahiaDeSilueta {
  /// Crea la bahía.
  const BsBahiaDeSilueta({
    required this.numero,
    this.nivelesCubierta = 0,
    this.nivelesBodega = 0,
    this.avance,
    this.conTrabajo = false,
  });

  /// El número de bahía.
  final int numero;

  /// Los niveles ocupados en cubierta (la pila sobre la tapa).
  final int nivelesCubierta;

  /// Los niveles ocupados en bodega (la pila dentro del casco).
  final int nivelesBodega;

  /// El avance de la operación en esta bahía, de 0 a 1; nulo sin operación.
  final double? avance;

  /// Si tiene contenedores que bajar o subir en esta escala: su pila va más
  /// clara que las que solo van de paso.
  final bool conTrabajo;

  /// El número con dos cifras.
  String get rotulo => numero.toString().padLeft(2, '0');

  /// La etiqueta accesible, sin la selección.
  String get etiqueta {
    final niveles = nivelesCubierta == 0 && nivelesBodega == 0
        ? 'sin carga'
        : '${formatearCuenta(nivelesCubierta, 'nivel', 'niveles')} en cubierta '
            'y $nivelesBodega en bodega';
    final progreso = avance == null
        ? 'sin operación'
        : 'avance ${formatearPorcentaje(avance!)}';
    return 'Bahía $rotulo, $niveles, $progreso';
  }
}

/// La silueta del buque como selector de bahías (`DESIGN.md`, 13.6): el casco
/// con la proa a la izquierda y la línea de flotación, sin superestructura ni
/// grúa (13.9); cada bahía es una pila, los niveles de cubierta sobre la tapa
/// y los de bodega dentro del casco; la seleccionada se dibuja como el ícono
/// (cubierta clara, bodega en acero) con su marco de marca; bajo cada número
/// va la barra de avance; y la bahía donde algo se acaba de mover destella en
/// naranja durante `BsMovimiento.recienMovido` (13.3).
///
/// El casco y las pilas se pintan con `CustomPainter`; cada bahía es un botón
/// de 56 dp de ancho con su etiqueta. Con `disableAnimations` el destello es
/// un anillo fijo. Evoluciona `BsTiraDeBahias`, que se conserva. La rueda del
/// mouse la desplaza en horizontal ([BsRuedaHorizontal], 16.1).
///
/// Con [compacta], la silueta del teléfono bajo (13.8): los mismos niveles,
/// el mismo número, la misma barra de avance y el mismo botón de 56 dp de
/// ancho, pero cada nivel a 4 dp en vez de 9 y menos aire arriba y abajo,
/// para que a 360 × 640 dp la primera fila de la rejilla se vea sin
/// desplazar (10.21, H4). Nada se recorta: solo cambia la escala de las pilas.
class BsSiluetaBuque extends StatelessWidget {
  /// Crea la silueta.
  const BsSiluetaBuque({
    super.key,
    required this.bahias,
    required this.onSeleccion,
    this.seleccionada,
    this.recienMovida,
    this.controlador,
    this.rotuloDeAvance,
    this.compacta = false,
  });

  /// La silueta baja del teléfono corto: niveles a [pasoNivelCompacto].
  final bool compacta;

  /// Las bahías, de proa a popa.
  final List<BsBahiaDeSilueta> bahias;

  /// Qué pasa al tocar una bahía.
  final ValueChanged<int> onSeleccion;

  /// La bahía seleccionada.
  final int? seleccionada;

  /// La bahía donde algo se acaba de mover: destella.
  final int? recienMovida;

  /// El controlador del desplazamiento horizontal, si la pantalla lo maneja.
  final ScrollController? controlador;

  /// Qué mide el avance, para la etiqueta de la silueta («avance de la
  /// descarga en GTSTC»).
  final String? rotuloDeAvance;

  /// El ancho de la columna de cada bahía.
  static const double anchoBahia = 56;

  /// El alto de un nivel pintado y el hueco entre niveles.
  static const double altoNivel = 7;

  /// El paso entre niveles.
  static const double pasoNivel = 9;

  /// El alto de un nivel y el paso en la silueta compacta.
  static const double altoNivelCompacto = 3;
  static const double pasoNivelCompacto = 4;

  /// Cuántos niveles se pintan como máximo por zona.
  static const int nivelesMaximos = 6;

  /// El margen de la proa y de la popa.
  static const double margen = 28;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final medidas = BsMedidas.de(context);
    final semanticos = BsColoresSemanticos.de(context);
    final esquema = tema.colorScheme;
    final textos = tema.textTheme;
    final mono = tema.extension<BsTextos>()?.datoMono;
    final escala = MediaQuery.textScalerOf(context);
    final reducido = BsMovimiento.reducido(context);

    final maxCubierta = bahias.fold<int>(
        0, (m, b) => b.nivelesCubierta > m ? b.nivelesCubierta : m);
    final maxBodega =
        bahias.fold<int>(0, (m, b) => b.nivelesBodega > m ? b.nivelesBodega : m);
    // El pie: el número, su hueco, la barra de avance y el aire de abajo
    // (menos en la compacta).
    final pieInferior = compacta ? medidas.espacioXs : medidas.espacioS;
    final geometria = _Geometria(
      cubierta: maxCubierta.clamp(1, nivelesMaximos),
      bodega: maxBodega.clamp(1, nivelesMaximos),
      compacta: compacta,
      altoDelPie: escala.scale(BsEscala.rotuloMinimo) * 1.2 +
          medidas.espacioXs * 2 +
          medidas.espacioXs +
          pieInferior,
    );
    final ancho = margen * 2 + anchoBahia * bahias.length;
    final cuenta = formatearCuenta(bahias.length, 'bahía', 'bahías');
    final descripcion = <String>[
      'Silueta del buque, $cuenta de proa a popa',
      if (rotuloDeAvance != null) rotuloDeAvance!,
    ].join(', ');

    final colores = _Colores(
      casco: esquema.surfaceContainerHigh,
      contorno: esquema.outline,
      agua: esquema.outlineVariant,
      tapa: esquema.outline,
      cubiertaApagada:
          Color.lerp(esquema.outlineVariant, esquema.onSurfaceVariant, 0.25)!,
      bodegaApagada:
          Color.lerp(esquema.secondaryContainer, esquema.secondary, 0.25)!,
      cubiertaConTrabajo: esquema.onSurfaceVariant,
      bodegaConTrabajo:
          Color.lerp(esquema.secondary, esquema.surfaceContainerLow, 0.4)!,
      cubiertaSeleccionada: semanticos.porBajarCubierta.relleno,
      bodegaSeleccionada: semanticos.porBajarBodega.relleno,
      marco: esquema.primary,
      destello: esquema.tertiary,
    );

    Widget pintura(double destello) => RepaintBoundary(
          child: CustomPaint(
            painter: _SiluetaPainter(
              bahias: bahias,
              seleccionada: seleccionada,
              recienMovida: recienMovida,
              destello: destello,
              geometria: geometria,
              colores: colores,
            ),
          ),
        );

    return Semantics(
      container: true,
      label: descripcion,
      child: SizedBox(
        height: geometria.alto,
        // La rueda del mouse avanza hacia la popa y regresa hacia la proa
        // (T-119, 16.1).
        child: BsRuedaHorizontal(
          controlador: controlador,
          constructor: (context, desplazamiento) => SingleChildScrollView(
            controller: desplazamiento,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: ancho,
              height: geometria.alto,
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: ExcludeSemantics(
                      child: recienMovida == null
                          ? pintura(0)
                          : reducido
                              ? pintura(1)
                              : TweenAnimationBuilder<double>(
                                  key: ValueKey<int>(recienMovida!),
                                  tween: Tween<double>(begin: 1, end: 0),
                                  duration: BsMovimiento.recienMovido,
                                  curve: BsMovimiento.entrada,
                                  builder: (BuildContext context, double valor,
                                          Widget? _) =>
                                      pintura(valor),
                                ),
                    ),
                  ),
                  Positioned(
                    left: medidas.espacioXs,
                    bottom: medidas.espacioXs,
                    child: ExcludeSemantics(
                      child: Text('Proa',
                          style: textos.labelSmall
                              ?.copyWith(color: semanticos.tintaTenue)),
                    ),
                  ),
                  Positioned(
                    right: medidas.espacioXs,
                    bottom: medidas.espacioXs,
                    child: ExcludeSemantics(
                      child: Text('Popa',
                          style: textos.labelSmall
                              ?.copyWith(color: semanticos.tintaTenue)),
                    ),
                  ),
                  Positioned(
                    left: margen,
                    top: 0,
                    bottom: 0,
                    child: Row(
                      children: <Widget>[
                        for (final bahia in bahias)
                          _BotonDeBahia(
                            key: ValueKey<String>(
                                'silueta-bahia-${bahia.numero}'),
                            bahia: bahia,
                            seleccionada: bahia.numero == seleccionada,
                            onTap: () => onSeleccion(bahia.numero),
                            estiloNumero: (mono ?? textos.labelSmall)?.copyWith(
                              fontSize: bahia.numero == seleccionada
                                  ? BsEscala.rotulo
                                  : BsEscala.rotuloMinimo,
                              fontWeight: bahia.numero == seleccionada
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: bahia.numero == seleccionada
                                  ? esquema.onSurface
                                  : semanticos.tintaTenue,
                            ),
                            colorDeAvance: bahia.avance == null
                                ? null
                                : bahia.avance! >= 1
                                    ? semanticos.hecho.contorno
                                    : bahia.numero == seleccionada
                                        ? semanticos.porBajarCubierta.relleno
                                        : esquema.primary,
                            pista: esquema.outlineVariant,
                            altoDelPie: geometria.altoDelPie,
                            pieInferior: pieInferior,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BotonDeBahia extends StatelessWidget {
  const _BotonDeBahia({
    super.key,
    required this.bahia,
    required this.seleccionada,
    required this.onTap,
    required this.estiloNumero,
    required this.colorDeAvance,
    required this.pista,
    required this.altoDelPie,
    required this.pieInferior,
  });

  final BsBahiaDeSilueta bahia;
  final bool seleccionada;
  final VoidCallback onTap;
  final TextStyle? estiloNumero;
  final Color? colorDeAvance;
  final Color pista;
  final double altoDelPie;

  /// El aire bajo la barra de avance.
  final double pieInferior;

  @override
  Widget build(BuildContext context) {
    final medidas = BsMedidas.de(context);
    return Semantics(
      button: true,
      selected: seleccionada,
      label: bahia.etiqueta,
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(medidas.radioControl),
        child: SizedBox(
          width: BsSiluetaBuque.anchoBahia,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(bahia.rotulo, style: estiloNumero),
              SizedBox(height: medidas.espacioXs),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: medidas.espacioS),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: SizedBox(
                    height: medidas.espacioXs,
                    child: colorDeAvance == null
                        ? ColoredBox(color: pista)
                        : LinearProgressIndicator(
                            value: bahia.avance!.clamp(0.0, 1.0).toDouble(),
                            color: colorDeAvance,
                            backgroundColor: pista,
                            minHeight: medidas.espacioXs,
                          ),
                  ),
                ),
              ),
              SizedBox(height: pieInferior),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dónde cae cada cosa, en dp, para un alto dado por los niveles; con
/// [compacta], las medidas de la silueta del teléfono bajo.
class _Geometria {
  _Geometria({
    required this.cubierta,
    required this.bodega,
    required this.altoDelPie,
    this.compacta = false,
  });

  final int cubierta;
  final int bodega;
  final double altoDelPie;
  final bool compacta;

  /// El paso entre niveles y el alto de cada nivel pintado.
  double get paso =>
      compacta ? BsSiluetaBuque.pasoNivelCompacto : BsSiluetaBuque.pasoNivel;
  double get altoNivel =>
      compacta ? BsSiluetaBuque.altoNivelCompacto : BsSiluetaBuque.altoNivel;

  /// El aire sobre la pila más alta, entre la tapa y las pilas, y bajo el
  /// casco.
  double get arriba => compacta ? 4 : 6;
  double get holgura => compacta ? 3 : 4;
  double get fondo => compacta ? 6 : 10;

  /// La línea de la tapa: donde la cubierta se apoya en el casco.
  double get yTapa => arriba + cubierta * paso + holgura;

  /// El fondo del casco.
  double get yFondo => yTapa + bodega * paso + fondo;

  /// El alto total.
  double get alto => yFondo + altoDelPie;
}

class _Colores {
  const _Colores({
    required this.casco,
    required this.contorno,
    required this.agua,
    required this.tapa,
    required this.cubiertaApagada,
    required this.bodegaApagada,
    required this.cubiertaConTrabajo,
    required this.bodegaConTrabajo,
    required this.cubiertaSeleccionada,
    required this.bodegaSeleccionada,
    required this.marco,
    required this.destello,
  });

  final Color casco;
  final Color contorno;
  final Color agua;
  final Color tapa;
  final Color cubiertaApagada;
  final Color bodegaApagada;
  final Color cubiertaConTrabajo;
  final Color bodegaConTrabajo;
  final Color cubiertaSeleccionada;
  final Color bodegaSeleccionada;
  final Color marco;
  final Color destello;

  @override
  bool operator ==(Object other) =>
      other is _Colores &&
      other.casco == casco &&
      other.contorno == contorno &&
      other.agua == agua &&
      other.tapa == tapa &&
      other.cubiertaApagada == cubiertaApagada &&
      other.bodegaApagada == bodegaApagada &&
      other.cubiertaConTrabajo == cubiertaConTrabajo &&
      other.bodegaConTrabajo == bodegaConTrabajo &&
      other.cubiertaSeleccionada == cubiertaSeleccionada &&
      other.bodegaSeleccionada == bodegaSeleccionada &&
      other.marco == marco &&
      other.destello == destello;

  @override
  int get hashCode => Object.hash(casco, contorno, agua, tapa, cubiertaApagada,
      bodegaApagada, cubiertaConTrabajo, bodegaConTrabajo,
      cubiertaSeleccionada, bodegaSeleccionada, marco, destello);
}

/// El casco, la línea de flotación, las pilas, el marco de la seleccionada y
/// el destello.
class _SiluetaPainter extends CustomPainter {
  const _SiluetaPainter({
    required this.bahias,
    required this.seleccionada,
    required this.recienMovida,
    required this.destello,
    required this.geometria,
    required this.colores,
  });

  final List<BsBahiaDeSilueta> bahias;
  final int? seleccionada;
  final int? recienMovida;

  /// La opacidad del destello, de 1 a 0.
  final double destello;
  final _Geometria geometria;
  final _Colores colores;

  @override
  void paint(Canvas canvas, Size size) {
    final yTapa = geometria.yTapa;
    final yFondo = geometria.yFondo;
    const xProa = BsSiluetaBuque.margen * 0.5;
    final xPopa = size.width - BsSiluetaBuque.margen * 0.5;
    const curvaProa = BsSiluetaBuque.margen * 1.6;

    // La línea de flotación, por debajo del casco.
    canvas.drawLine(
      Offset(0, yFondo + 3),
      Offset(size.width, yFondo + 3),
      Paint()
        ..color = colores.agua
        ..strokeWidth = 1,
    );

    // El casco: proa a la izquierda, popa a la derecha, sin superestructura.
    final casco = Path()
      ..moveTo(xProa, yTapa - 6)
      ..lineTo(xProa, yTapa)
      ..quadraticBezierTo(xProa, yFondo, xProa + curvaProa, yFondo)
      ..lineTo(xPopa - 14, yFondo)
      ..quadraticBezierTo(xPopa, yFondo, xPopa, yTapa)
      ..lineTo(xPopa, yTapa - 2)
      ..close();
    canvas.drawPath(casco, Paint()..color = colores.casco);
    canvas.drawPath(
      casco,
      Paint()
        ..color = colores.contorno
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeJoin = StrokeJoin.round,
    );

    // Las pilas.
    const ancho = BsSiluetaBuque.anchoBahia;
    const anchoPila = ancho - 12;
    final alto = geometria.altoNivel;
    final paso = geometria.paso;
    const radio = Radius.circular(1.5);
    for (var i = 0; i < bahias.length; i++) {
      final bahia = bahias[i];
      final x = BsSiluetaBuque.margen + i * ancho + 6;
      final esSeleccionada = bahia.numero == seleccionada;
      final cubierta = esSeleccionada
          ? colores.cubiertaSeleccionada
          : bahia.conTrabajo
              ? colores.cubiertaConTrabajo
              : colores.cubiertaApagada;
      final bodega = esSeleccionada
          ? colores.bodegaSeleccionada
          : bahia.conTrabajo
              ? colores.bodegaConTrabajo
              : colores.bodegaApagada;
      final nivelesCubierta =
          bahia.nivelesCubierta.clamp(0, BsSiluetaBuque.nivelesMaximos);
      final nivelesBodega =
          bahia.nivelesBodega.clamp(0, BsSiluetaBuque.nivelesMaximos);
      final pintaCubierta = Paint()..color = cubierta;
      final pintaBodega = Paint()..color = bodega;
      for (var t = 0; t < nivelesCubierta; t++) {
        final y = yTapa - geometria.holgura - (t + 1) * paso + (paso - alto);
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(x, y, anchoPila, alto), radio),
          pintaCubierta,
        );
      }
      // La tapa de esta bahía.
      canvas.drawRect(
        Rect.fromLTWH(x, yTapa - 2.5, anchoPila, 2),
        Paint()
          ..color = esSeleccionada ? colores.cubiertaSeleccionada : colores.tapa,
      );
      for (var t = 0; t < nivelesBodega; t++) {
        final y = yTapa + geometria.holgura + t * paso;
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(x, y, anchoPila, alto), radio),
          pintaBodega,
        );
      }
      final marcoRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x - 4,
          geometria.arriba - 2,
          anchoPila + 8,
          yFondo - geometria.arriba - 2,
        ),
        const Radius.circular(6),
      );
      if (esSeleccionada) {
        canvas.drawRRect(
          marcoRect,
          Paint()..color = colores.marco.withValues(alpha: 0.10),
        );
        canvas.drawRRect(
          marcoRect,
          Paint()
            ..color = colores.marco
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      }
      if (bahia.numero == recienMovida && destello > 0) {
        canvas.drawRRect(
          marcoRect.inflate(2),
          Paint()
            ..color = colores.destello.withValues(alpha: destello)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_SiluetaPainter anterior) =>
      anterior.bahias != bahias ||
      anterior.seleccionada != seleccionada ||
      anterior.recienMovida != recienMovida ||
      anterior.destello != destello ||
      anterior.geometria.alto != geometria.alto ||
      anterior.geometria.compacta != geometria.compacta ||
      anterior.colores != colores;
}
