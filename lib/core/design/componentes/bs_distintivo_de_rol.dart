import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../bs_iconos.dart';
import '../bs_medidas.dart';
import '../bs_paleta.dart';
import '../bs_tipografia.dart';
import 'bs_panel_en_vivo.dart' show BsEquipo;

/// El distintivo de rol de la cabecera (`DESIGN.md` 13.12; decisión 10.86, la
/// variante B «Filo de metal»): dice si la cuenta es del muelle o de la
/// oficina, porque en un teléfono las dos se veían iguales (10.85, hallazgo 8).
///
/// Una píldora del alto visible de [BsMedidas.alturaChip] (40 en el muelle y
/// 32 en la oficina) con la zona táctil de [BsMedidas.objetivoTactil]: el
/// relleno en el degradado del fondo, el filo de [grosorDelFilo] en el metal
/// del rol (cobre o oro, [BsMetalDeRol]), un brillo de 1 dp arriba por dentro
/// y una sombra leve; el ícono del paquete (`muelle` o `oficina`) y el rótulo
/// en IBM Plex Sans Condensed 600. Con [compacto], solo el ícono en un círculo
/// con el mismo relleno y el mismo filo. Sin animación.
///
/// No lee providers: recibe el rol, la forma y qué pasa al tocarla (en la
/// app, abrir «Nube y cuenta»). Para el lector de pantalla es el botón «Rol:
/// Muelle» o «Rol: Oficina», con la pista [pista]; la descripción emergente
/// dice el rol y queda fuera de la semántica, como la de «Acciones» (14.8).
class BsDistintivoDeRol extends StatelessWidget {
  /// Crea el distintivo de [equipo].
  const BsDistintivoDeRol({
    super.key,
    required this.equipo,
    this.compacto = false,
    this.onTap,
  });

  /// El rol de la cuenta.
  final BsEquipo equipo;

  /// Solo el ícono, en un círculo: cuando el completo no cabe (13.12).
  final bool compacto;

  /// Qué pasa al tocarlo.
  final VoidCallback? onTap;

  /// El grosor del filo de metal.
  static const double grosorDelFilo = 1.5;

  /// Lo que hace al tocarlo, para el lector de pantalla.
  static const String pista = 'Abre Nube y cuenta';

  /// La etiqueta accesible y la descripción emergente: «Rol: Muelle».
  String get etiqueta => 'Rol: ${equipo.rotulo}';

  /// El metal de [equipo] en [paleta].
  static BsMetalDeRol metalDe(BsEquipo equipo, BsPaleta paleta) =>
      switch (equipo) {
        BsEquipo.muelle => paleta.metalMuelle,
        BsEquipo.oficina => paleta.metalOficina,
      };

  /// El ícono del paquete de [equipo].
  static IconData iconoDe(BsEquipo equipo) => switch (equipo) {
        BsEquipo.muelle => BsIconos.muelle,
        BsEquipo.oficina => BsIconos.oficina,
      };

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final medidas = BsMedidas.de(context);
    final metal = metalDe(equipo, BsPaleta.de(tema.brightness));
    final alto = medidas.alturaChip;
    final icono = Icon(
      iconoDe(equipo),
      size: medidas.esMuelle ? 20 : 18,
      color: metal.icono,
    );
    // Los aires del lienzo de 10.86, con el filo dentro: 12 y 16 dp a los
    // lados y 8 entre el ícono y el rótulo en el muelle; 10, 14 y 6 en la
    // oficina. Con la letra grande la píldora crece en alto.
    final contenido = compacto
        ? SizedBox.square(dimension: alto, child: Center(child: icono))
        : ConstrainedBox(
            constraints: BoxConstraints(minHeight: alto),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                medidas.esMuelle ? 12 : 10,
                medidas.espacioXs,
                medidas.esMuelle ? 16 : 14,
                medidas.espacioXs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  icono,
                  SizedBox(width: medidas.esMuelle ? 8 : 6),
                  Text(
                    equipo.rotulo,
                    maxLines: 1,
                    softWrap: false,
                    style: tema.textTheme.labelLarge?.copyWith(
                      fontFamily: BsFuentes.condensada,
                      fontWeight: FontWeight.w600,
                      color: metal.rotulo,
                    ),
                  ),
                ],
              ),
            ),
          );
    final ShapeBorder forma =
        compacto ? const CircleBorder() : const StadiumBorder();
    // El metal se pinta debajo y el resalte del toque, del foco y del mouse
    // va encima, en el rótulo con poca opacidad: sobre el azul se ve.
    final pildora = RepaintBoundary(
      child: CustomPaint(
        key: const ValueKey('distintivo-pildora'),
        painter: _PintorDelMetal(metal),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            customBorder: forma,
            excludeFromSemantics: true,
            splashFactory: NoSplash.splashFactory,
            overlayColor: WidgetStateProperty.resolveWith((estados) {
              if (estados.contains(WidgetState.pressed) ||
                  estados.contains(WidgetState.focused)) {
                return metal.rotulo.withValues(alpha: 0.16);
              }
              if (estados.contains(WidgetState.hovered)) {
                return metal.rotulo.withValues(alpha: 0.08);
              }
              return null;
            }),
            child: contenido,
          ),
        ),
      ),
    );
    return Tooltip(
      message: etiqueta,
      excludeFromSemantics: true,
      child: Semantics(
        container: true,
        button: onTap != null,
        label: etiqueta,
        hint: onTap == null ? null : pista,
        onTap: onTap,
        excludeSemantics: true,
        child: _ZonaTactil(
          key: const ValueKey('distintivo-zona'),
          minimo: medidas.objetivoTactil,
          child: pildora,
        ),
      ),
    );
  }
}

/// El metal de la píldora: la sombra leve, el filo a 135°, el relleno de
/// arriba abajo y el brillo de 1 dp arriba, por dentro (el lienzo de 10.86:
/// `inset 0 1px 0` y `0 1px 3px`).
class _PintorDelMetal extends CustomPainter {
  const _PintorDelMetal(this.metal);

  final BsMetalDeRol metal;

  @override
  void paint(Canvas canvas, Size size) {
    final caja = Offset.zero & size;
    final exterior =
        RRect.fromRectAndRadius(caja, Radius.circular(size.shortestSide / 2));
    final sombra = BoxShadow(
      color: metal.sombra,
      offset: const Offset(0, 1),
      blurRadius: 3,
    );
    canvas.drawRRect(exterior.shift(sombra.offset), sombra.toPaint());
    canvas.drawRRect(exterior, Paint()..shader = _filo(caja));
    final interior = exterior.deflate(BsDistintivoDeRol.grosorDelFilo);
    canvas.drawRRect(
      interior,
      Paint()
        ..shader = ui.Gradient.linear(
          interior.outerRect.topCenter,
          interior.outerRect.bottomCenter,
          <Color>[metal.fondoArriba, metal.fondoAbajo],
        ),
    );
    final brillo = Path.combine(
      PathOperation.difference,
      Path()..addRRect(interior),
      Path()..addRRect(interior.shift(const Offset(0, 1))),
    );
    canvas.drawPath(brillo, Paint()..color = metal.brillo);
  }

  /// El degradado del filo como el `linear-gradient(135deg, …)` del lienzo:
  /// hacia abajo a la derecha a 45° de verdad, con el largo que deja la
  /// esquina de arriba a la izquierda en el claro y la de abajo a la derecha
  /// en el oscuro, sea cual sea el ancho de la píldora.
  ui.Gradient _filo(Rect caja) {
    const lado = math.sqrt1_2;
    const direccion = Offset(lado, lado);
    final mitad = (caja.width + caja.height) * lado / 2;
    return ui.Gradient.linear(
      caja.center - direccion * mitad,
      caja.center + direccion * mitad,
      <Color>[metal.filoClaro, metal.filoMedio, metal.filoOscuro],
      const <double>[0, BsMetalDeRol.paradaMedia, 1],
    );
  }

  @override
  bool shouldRepaint(_PintorDelMetal anterior) => anterior.metal != metal;
}

/// La zona táctil alrededor de la píldora, como la de los chips de Material
/// (`MaterialTapTargetSize.padded`): mide al menos [minimo] en cada lado,
/// centra la píldora y un toque en el margen va al centro de la píldora.
class _ZonaTactil extends SingleChildRenderObjectWidget {
  const _ZonaTactil({super.key, required this.minimo, required super.child});

  final double minimo;

  @override
  _RenderZonaTactil createRenderObject(BuildContext context) =>
      _RenderZonaTactil(minimo);

  @override
  void updateRenderObject(BuildContext context, _RenderZonaTactil renderObject) =>
      renderObject.minimo = minimo;
}

class _RenderZonaTactil extends RenderShiftedBox {
  _RenderZonaTactil(this._minimo) : super(null);

  double _minimo;
  set minimo(double valor) {
    if (valor == _minimo) return;
    _minimo = valor;
    markNeedsLayout();
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      math.max(child?.getMinIntrinsicWidth(height) ?? 0, _minimo);

  @override
  double computeMaxIntrinsicWidth(double height) =>
      math.max(child?.getMaxIntrinsicWidth(height) ?? 0, _minimo);

  @override
  double computeMinIntrinsicHeight(double width) =>
      math.max(child?.getMinIntrinsicHeight(width) ?? 0, _minimo);

  @override
  double computeMaxIntrinsicHeight(double width) =>
      math.max(child?.getMaxIntrinsicHeight(width) ?? 0, _minimo);

  Size _tamano(Size hijo, BoxConstraints restricciones) =>
      restricciones.constrain(Size(
        math.max(hijo.width, _minimo),
        math.max(hijo.height, _minimo),
      ));

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) => _tamano(
      child?.getDryLayout(constraints.loosen()) ?? Size.zero, constraints);

  @override
  void performLayout() {
    final hijo = child;
    if (hijo == null) {
      size = _tamano(Size.zero, constraints);
      return;
    }
    hijo.layout(constraints.loosen(), parentUsesSize: true);
    size = _tamano(hijo.size, constraints);
    (hijo.parentData! as BoxParentData).offset =
        Alignment.center.alongOffset(size - hijo.size as Offset);
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!size.contains(position)) return false;
    if (super.hitTest(result, position: position)) return true;
    final hijo = child;
    if (hijo == null) return false;
    final centro = hijo.size.center(Offset.zero);
    return result.addWithRawTransform(
      transform: MatrixUtils.forceToPoint(centro),
      position: centro,
      hitTest: (BoxHitTestResult resultado, Offset _) =>
          hijo.hitTest(resultado, position: centro),
    );
  }
}
