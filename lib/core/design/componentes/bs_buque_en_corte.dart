import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../bs_colores_semanticos.dart';
import '../bs_formato.dart';
import '../bs_medidas.dart';
import '../bs_paleta.dart';
import '../bs_tipografia.dart';

/// Qué dice la altura de la pila de cada bahía: cuántos contenedores o cuánto
/// pesan.
enum BsMagnitudDeLaPila { contenedores, peso }

/// Una bahía del buque en corte: su número y, por zona, cuántos contenedores
/// lleva y cuánto pesan.
@immutable
class BsBahiaEnCorte {
  /// Crea la bahía.
  const BsBahiaEnCorte({
    required this.numero,
    this.contenedoresCubierta = 0,
    this.contenedoresBodega = 0,
    this.pesoCubiertaKg = 0,
    this.pesoBodegaKg = 0,
  });

  /// El número de bahía.
  final int numero;

  /// Los contenedores en cubierta (sobre la tapa).
  final int contenedoresCubierta;

  /// Los contenedores en bodega (dentro del casco).
  final int contenedoresBodega;

  /// El peso en cubierta, en kilos.
  final double pesoCubiertaKg;

  /// El peso en bodega, en kilos.
  final double pesoBodegaKg;

  /// Los contenedores de la bahía.
  int get contenedores => contenedoresCubierta + contenedoresBodega;

  /// El peso de la bahía, en kilos.
  double get pesoKg => pesoCubiertaKg + pesoBodegaKg;

  /// El número con dos cifras.
  String get rotulo => numero.toString().padLeft(2, '0');

  /// La etiqueta accesible: «Bahía 14, 36 contenedores, 712.4 t, 18 en
  /// cubierta y 18 en bodega».
  String get etiqueta => 'Bahía $rotulo, '
      '${formatearCuenta(contenedores, 'contenedor', 'contenedores')}, '
      '${formatearToneladas(pesoKg)}, '
      '$contenedoresCubierta en cubierta y $contenedoresBodega en bodega';

  /// La magnitud de una zona.
  double magnitud(BsMagnitudDeLaPila magnitud, {required bool cubierta}) =>
      switch (magnitud) {
        BsMagnitudDeLaPila.contenedores =>
          (cubierta ? contenedoresCubierta : contenedoresBodega).toDouble(),
        BsMagnitudDeLaPila.peso => cubierta ? pesoCubiertaKg : pesoBodegaKg,
      };
}

/// El buque en corte, la protagonista de Estadísticas (`DESIGN.md`, 15.4): el
/// casco de `BsSiluetaBuque` en grande (la proa a la izquierda, la línea de
/// flotación, sin superestructura) y, en cada bahía, dos pilas que son el dato:
/// la de cubierta crece hacia arriba desde la tapa y la de bodega hacia abajo,
/// dentro del casco, con el alto que dicen los contenedores o el peso de esa
/// zona ([magnitud]). Las dos pilas comparten la escala: la zona más cargada
/// del buque llena [altoDeZona]. Cada pila lleva un separador de 1 dp en el
/// color de su fondo cada [pasoDeNivel]: se lee como una pila de contenedores
/// y mide como una barra.
///
/// Debajo de cada bahía, en el mismo eje y nunca girado, el número, la cuenta
/// y el peso. Cada bahía es un botón de la columna entera, con su etiqueta;
/// la descripción emergente va fuera de la semántica. Cada bahía mide al
/// menos 56 dp por la escala de la letra ([anchoBahia]), y nunca menos que el
/// rótulo más ancho del pie más 8: con la letra a 2.0, 112. Si las bahías
/// caben, se reparten el ancho útil hasta [topeDeLaBahia] veces su mínimo y,
/// si aun así sobra, el casco va centrado; fuera del teléfono las zonas
/// crecen en la misma proporción hasta [crecimientoDelAlto] ([repartir]). Si
/// no caben, la silueta se desplaza a lo ancho con su barra visible.
///
/// Los colores salen del tema: las pilas son las de la vista Estado (13.2),
/// `porBajarCubierta` y `porBajarBodega` (el buque se pinta como el ícono); el
/// casco, la tapa y el agua, del esquema. Nada es naranja y ningún texto lleva
/// el color del dato. Sin bahías no dibuja nada: dice que el archivo no trae
/// posiciones.
class BsBuqueEnCorte extends StatefulWidget {
  /// Crea el buque.
  const BsBuqueEnCorte({
    super.key,
    required this.bahias,
    required this.onSeleccion,
    this.magnitud = BsMagnitudDeLaPila.contenedores,
    this.controlador,
  });

  /// Las bahías, de proa a popa.
  final List<BsBahiaEnCorte> bahias;

  /// Qué pasa al tocar una bahía (abrirla en el plano).
  final ValueChanged<int> onSeleccion;

  /// Qué dice la altura de la pila.
  final BsMagnitudDeLaPila magnitud;

  /// El controlador del desplazamiento horizontal, si la pantalla lo maneja.
  final ScrollController? controlador;

  /// El ancho de la columna de cada bahía con la letra a 1.0.
  static const double anchoBahiaBase = 56;

  /// El alto base de la pila más alta, en cubierta y en bodega: el de la
  /// silueta que no cabe, la del teléfono y la que cabe sin crecer.
  static const double altoDeZona = 72;

  /// Cada cuánto va un separador de nivel en la pila: el paso de los niveles
  /// de la silueta del plano.
  static const double pasoDeNivel = 9;

  /// El aire sobre la pila de cubierta más alta.
  static const double arriba = 8;

  /// La holgura entre la tapa y cada pila.
  static const double holgura = 4;

  /// El fondo del casco bajo la pila de bodega más alta.
  static const double fondo = 10;

  /// El grosor de la tapa.
  static const double grosorDeTapa = 2;

  /// El margen mínimo de la proa y de la popa.
  static const double margenBase = 28;

  /// Hasta cuántas veces su ancho mínimo crece una bahía cuando las bahías
  /// caben y sobra ancho (`DESIGN.md` 15.4): con 168 dp a la letra 1.0, la
  /// pila mide 156 y no pasa de una vez y media el alto de su zona crecida;
  /// sigue leyéndose como una pila de contenedores y no como una losa. Con
  /// ese tope, desde ocho bahías la silueta llena un panel de 1440.
  static const double topeDeLaBahia = 3;

  /// Hasta cuántas veces crece el alto de cada zona cuando las bahías crecen:
  /// en la misma proporción que la bahía, hasta 108 dp.
  static const double crecimientoDelAlto = 1.5;

  /// Desde qué ancho disponible crece el alto de las zonas: por debajo es el
  /// teléfono, donde la página no cambia.
  static const double anchoParaCrecerElAlto = 600;

  /// El reparto del ancho [disponible] entre [bahias] columnas
  /// (`DESIGN.md` 15.4). Si no caben con [anchoMinimo] (o el ancho no está
  /// acotado), cada una mide [anchoMinimo], la zona [altoDeZona] y la silueta
  /// se desplaza. Si caben, cada una crece hasta llenar el ancho, sin pasar
  /// de [topeDeLaBahia] veces su mínimo; y, si el ancho disponible no es el
  /// de un teléfono, el alto de las zonas crece en la misma proporción, sin
  /// pasar de [crecimientoDelAlto].
  static ({double ancho, double altoDeZona}) repartir({
    required int bahias,
    required double anchoMinimo,
    required double margen,
    required double disponible,
  }) {
    if (bahias <= 0 || !disponible.isFinite) {
      return (ancho: anchoMinimo, altoDeZona: altoDeZona);
    }
    final porBahia = (disponible - 2 * margen) / bahias;
    if (porBahia <= anchoMinimo) {
      return (ancho: anchoMinimo, altoDeZona: altoDeZona);
    }
    final ancho = math.min(porBahia, topeDeLaBahia * anchoMinimo);
    final crece = disponible >= anchoParaCrecerElAlto
        ? math.min(ancho / anchoMinimo, crecimientoDelAlto)
        : 1.0;
    return (ancho: ancho, altoDeZona: altoDeZona * crece);
  }

  /// La línea de la tapa, con el alto base de la zona.
  static double get yTapa => yTapaCon(altoDeZona);

  /// El fondo del casco, con el alto base de la zona.
  static double get yFondo => yFondoCon(altoDeZona);

  /// El alto del dibujo, sin el pie, con el alto base de la zona: el casco y
  /// la línea de flotación.
  static double get altoDelDibujo => altoDelDibujoCon(altoDeZona);

  /// La línea de la tapa cuando cada zona mide [alto].
  static double yTapaCon(double alto) => arriba + alto + holgura;

  /// El fondo del casco cuando cada zona mide [alto].
  static double yFondoCon(double alto) =>
      yTapaCon(alto) + holgura + alto + fondo;

  /// El alto del dibujo, sin el pie, cuando cada zona mide [alto].
  static double altoDelDibujoCon(double alto) => yFondoCon(alto) + 4;

  /// El ancho de la columna de cada bahía: [anchoBahiaBase] por la escala de
  /// la letra, y nunca menos que [anchoDelPie] (el rótulo más ancho del pie)
  /// más 8.
  static double anchoBahia(TextScaler escala, {double anchoDelPie = 0}) =>
      math.max(
        math.max(anchoBahiaBase, escala.scale(anchoBahiaBase)),
        anchoDelPie + 8,
      );

  @override
  State<BsBuqueEnCorte> createState() => _BsBuqueEnCorteState();
}

class _BsBuqueEnCorteState extends State<BsBuqueEnCorte> {
  ScrollController? _propio;

  ScrollController get _controlador =>
      widget.controlador ?? (_propio ??= ScrollController());

  @override
  void dispose() {
    _propio?.dispose();
    super.dispose();
  }

  double _anchoDe(String texto, TextStyle? estilo, TextScaler escala) {
    final pintor = TextPainter(
      text: TextSpan(text: texto, style: estilo),
      textDirection: TextDirection.ltr,
      textScaler: escala,
    )..layout();
    final ancho = pintor.width;
    pintor.dispose();
    return ancho;
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final medidas = BsMedidas.de(context);
    final semanticos = BsColoresSemanticos.de(context);
    final paleta = BsPaleta.de(tema.brightness);
    final esquema = tema.colorScheme;
    final textos = tema.textTheme;
    final escala = MediaQuery.textScalerOf(context);
    final mono = tema.extension<BsTextos>()?.datoMono;
    final bahias = widget.bahias;

    if (bahias.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(medidas.espacioL),
        child: Text(
          'El archivo no trae posiciones de estiba.',
          style: textos.bodyMedium?.copyWith(color: esquema.onSurfaceVariant),
        ),
      );
    }

    final estiloNumero = (mono ?? textos.labelSmall)?.copyWith(
      fontSize: BsEscala.rotuloMinimo,
      fontWeight: FontWeight.w500,
      height: 1.2,
      color: semanticos.tintaTenue,
    );
    final estiloCuenta = textos.labelMedium?.copyWith(
      color: esquema.onSurface,
      fontFeatures: cifrasTabulares,
    );
    final estiloPeso = textos.labelSmall?.copyWith(
      color: esquema.onSurfaceVariant,
      fontFeatures: cifrasTabulares,
    );
    final estiloExtremo =
        textos.labelSmall?.copyWith(color: semanticos.tintaTenue);

    // El rótulo más ancho del pie, medido con la letra del sistema, para que
    // nada se corte con ninguna escala.
    var anchoDelPie = 0.0;
    for (final bahia in bahias) {
      anchoDelPie = math.max(
        anchoDelPie,
        math.max(
          _anchoDe(formatearToneladas(bahia.pesoKg), estiloPeso, escala),
          _anchoDe('${bahia.contenedores}', estiloCuenta, escala),
        ),
      );
    }
    final anchoMinimo =
        BsBuqueEnCorte.anchoBahia(escala, anchoDelPie: anchoDelPie);
    final margen = math.max(
      BsBuqueEnCorte.margenBase,
      math.max(
            _anchoDe('Proa', estiloExtremo, escala),
            _anchoDe('Popa', estiloExtremo, escala),
          ) +
          medidas.espacioS,
    );
    var maximo = 0.0;
    for (final bahia in bahias) {
      maximo = math.max(
        maximo,
        math.max(
          bahia.magnitud(widget.magnitud, cubierta: true),
          bahia.magnitud(widget.magnitud, cubierta: false),
        ),
      );
    }
    final queDice = widget.magnitud == BsMagnitudDeLaPila.contenedores
        ? 'los contenedores'
        : 'el peso';
    final descripcion = 'El buque en corte, '
        '${formatearCuenta(bahias.length, 'bahía', 'bahías')} de proa a popa; '
        'la altura de cada pila dice $queDice en cubierta y en bodega';

    final colores = _Colores(
      fondo: paleta.hoja,
      casco: esquema.surfaceContainerHigh,
      contorno: esquema.outline,
      agua: esquema.outlineVariant,
      tapa: esquema.outline,
      cubierta: semanticos.porBajarCubierta.relleno,
      bodega: semanticos.porBajarBodega.relleno,
    );

    // El cuerpo con el ancho de cada bahía y el alto de cada zona que da el
    // reparto (15.4).
    Widget cuerpoCon(double ancho, double altoDeZona) {
      final altoDelDibujo = BsBuqueEnCorte.altoDelDibujoCon(altoDeZona);
      return Stack(
        children: <Widget>[
          Positioned.fill(
            child: ExcludeSemantics(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _BuquePainter(
                    bahias: bahias,
                    magnitud: widget.magnitud,
                    maximo: maximo,
                    ancho: ancho,
                    altoDeZona: altoDeZona,
                    margen: margen,
                    colores: colores,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: medidas.espacioXs,
            top: altoDelDibujo + medidas.espacioXs,
            child: ExcludeSemantics(child: Text('Proa', style: estiloExtremo)),
          ),
          Positioned(
            right: medidas.espacioXs,
            top: altoDelDibujo + medidas.espacioXs,
            child: ExcludeSemantics(child: Text('Popa', style: estiloExtremo)),
          ),
          // La tinta de los botones (el hover, la pulsación, el anillo de
          // foco) se pinta en este Material transparente, por encima del
          // casco y de la hoja del panel; sin él iría al Material del Scaffold,
          // debajo de la hoja, y no se vería.
          Material(
            type: MaterialType.transparency,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: margen),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (final bahia in bahias)
                    _ColumnaDeBahia(
                      key: ValueKey<String>(
                          'buque-en-corte-bahia-${bahia.numero}'),
                      bahia: bahia,
                      ancho: ancho,
                      altoDelDibujo: altoDelDibujo,
                      estiloNumero: estiloNumero,
                      estiloCuenta: estiloCuenta,
                      estiloPeso: estiloPeso,
                      onTap: () => widget.onSeleccion(bahia.numero),
                    ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Semantics(
      container: true,
      label: descripcion,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints restricciones) {
          final disponible = restricciones.maxWidth;
          final reparto = BsBuqueEnCorte.repartir(
            bahias: bahias.length,
            anchoMinimo: anchoMinimo,
            margen: margen,
            disponible: disponible,
          );
          final cuerpo = cuerpoCon(reparto.ancho, reparto.altoDeZona);
          // Si las bahías caben, la silueta ocupa el ancho útil del panel y,
          // si las bahías ya llegaron a su tope, el casco va centrado. Si no
          // caben, se desplaza como antes.
          final cabe = disponible.isFinite &&
              2 * margen + bahias.length * reparto.ancho <= disponible + 0.5;
          return Scrollbar(
            controller: _controlador,
            thumbVisibility: true,
            scrollbarOrientation: ScrollbarOrientation.bottom,
            child: SingleChildScrollView(
              key: const ValueKey<String>('buque-en-corte-scroll'),
              controller: _controlador,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(bottom: medidas.espacioM),
              child: cabe
                  ? SizedBox(
                      width: disponible,
                      child: Align(
                        alignment: Alignment.topCenter,
                        heightFactor: 1,
                        child: cuerpo,
                      ),
                    )
                  : cuerpo,
            ),
          );
        },
      ),
    );
  }
}

class _ColumnaDeBahia extends StatelessWidget {
  const _ColumnaDeBahia({
    super.key,
    required this.bahia,
    required this.ancho,
    required this.altoDelDibujo,
    required this.estiloNumero,
    required this.estiloCuenta,
    required this.estiloPeso,
    required this.onTap,
  });

  final BsBahiaEnCorte bahia;
  final double ancho;
  final double altoDelDibujo;
  final TextStyle? estiloNumero;
  final TextStyle? estiloCuenta;
  final TextStyle? estiloPeso;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final medidas = BsMedidas.de(context);
    return Semantics(
      button: true,
      label: bahia.etiqueta,
      hint: 'Abre la bahía en el plano',
      onTap: onTap,
      excludeSemantics: true,
      child: Tooltip(
        message: 'Abrir la bahía ${bahia.rotulo} en el plano',
        excludeFromSemantics: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(medidas.radioControl),
          child: SizedBox(
            width: ancho,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(height: altoDelDibujo),
                SizedBox(height: medidas.espacioXs),
                Text(bahia.rotulo, style: estiloNumero, maxLines: 1),
                SizedBox(height: medidas.espacioXs),
                Text('${bahia.contenedores}', style: estiloCuenta, maxLines: 1),
                SizedBox(height: medidas.espacioXs),
                Text(formatearToneladas(bahia.pesoKg),
                    style: estiloPeso, maxLines: 1),
                SizedBox(height: medidas.espacioS),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Colores {
  const _Colores({
    required this.fondo,
    required this.casco,
    required this.contorno,
    required this.agua,
    required this.tapa,
    required this.cubierta,
    required this.bodega,
  });

  /// El fondo detrás de la pila de cubierta (la hoja del panel): el color de
  /// sus separadores.
  final Color fondo;

  /// El relleno del casco: el fondo de la pila de bodega.
  final Color casco;
  final Color contorno;
  final Color agua;
  final Color tapa;
  final Color cubierta;
  final Color bodega;

  @override
  bool operator ==(Object other) =>
      other is _Colores &&
      other.fondo == fondo &&
      other.casco == casco &&
      other.contorno == contorno &&
      other.agua == agua &&
      other.tapa == tapa &&
      other.cubierta == cubierta &&
      other.bodega == bodega;

  @override
  int get hashCode =>
      Object.hash(fondo, casco, contorno, agua, tapa, cubierta, bodega);
}

/// El casco, la línea de flotación, la tapa de cada bahía y las dos pilas con
/// sus separadores de nivel.
class _BuquePainter extends CustomPainter {
  const _BuquePainter({
    required this.bahias,
    required this.magnitud,
    required this.maximo,
    required this.ancho,
    required this.altoDeZona,
    required this.margen,
    required this.colores,
  });

  final List<BsBahiaEnCorte> bahias;
  final BsMagnitudDeLaPila magnitud;
  final double maximo;
  final double ancho;
  final double altoDeZona;
  final double margen;
  final _Colores colores;

  @override
  void paint(Canvas canvas, Size size) {
    final yTapa = BsBuqueEnCorte.yTapaCon(altoDeZona);
    final yFondo = BsBuqueEnCorte.yFondoCon(altoDeZona);
    final xProa = margen * 0.5;
    final xPopa = size.width - margen * 0.5;
    final curvaProa = math.min(margen * 1.6, (xPopa - xProa) / 3);

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

    final anchoPila = ancho - 12;
    final porUnidad = maximo > 0 ? altoDeZona / maximo : 0.0;
    const radio = Radius.circular(2);
    final pintaCubierta = Paint()..color = colores.cubierta;
    final pintaBodega = Paint()..color = colores.bodega;
    final pintaTapa = Paint()..color = colores.tapa;
    final separadorCubierta = Paint()..color = colores.fondo;
    final separadorBodega = Paint()..color = colores.casco;
    for (var i = 0; i < bahias.length; i++) {
      final bahia = bahias[i];
      final x = margen + i * ancho + 6;
      final altoCubierta = bahia.magnitud(magnitud, cubierta: true) * porUnidad;
      final altoBodega = bahia.magnitud(magnitud, cubierta: false) * porUnidad;

      if (altoCubierta > 0) {
        final base = yTapa - BsBuqueEnCorte.holgura;
        final rect =
            Rect.fromLTWH(x, base - altoCubierta, anchoPila, altoCubierta);
        canvas.drawRRect(
          RRect.fromRectAndCorners(rect, topLeft: radio, topRight: radio),
          pintaCubierta,
        );
        for (var y = base - BsBuqueEnCorte.pasoDeNivel;
            y > rect.top + 1;
            y -= BsBuqueEnCorte.pasoDeNivel) {
          canvas.drawRect(
              Rect.fromLTWH(x, y - 0.5, anchoPila, 1), separadorCubierta);
        }
      }

      // La tapa de esta bahía.
      canvas.drawRect(
        Rect.fromLTWH(x, yTapa - BsBuqueEnCorte.grosorDeTapa, anchoPila,
            BsBuqueEnCorte.grosorDeTapa),
        pintaTapa,
      );

      if (altoBodega > 0) {
        final base = yTapa + BsBuqueEnCorte.holgura;
        final rect = Rect.fromLTWH(x, base, anchoPila, altoBodega);
        canvas.drawRRect(
          RRect.fromRectAndCorners(rect, bottomLeft: radio, bottomRight: radio),
          pintaBodega,
        );
        for (var y = base + BsBuqueEnCorte.pasoDeNivel;
            y < rect.bottom - 1;
            y += BsBuqueEnCorte.pasoDeNivel) {
          canvas.drawRect(
              Rect.fromLTWH(x, y - 0.5, anchoPila, 1), separadorBodega);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_BuquePainter anterior) =>
      anterior.bahias != bahias ||
      anterior.magnitud != magnitud ||
      anterior.maximo != maximo ||
      anterior.ancho != ancho ||
      anterior.altoDeZona != altoDeZona ||
      anterior.margen != margen ||
      anterior.colores != colores;
}
