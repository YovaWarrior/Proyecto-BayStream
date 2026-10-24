import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/design.dart';

/// Lo que mide, en dp, lo que los avisos no deben tapar al pie del plano
/// (`DESIGN.md` 13.8): en el muelle operando, la fila de controles de la barra
/// de la operación (el modo, el zoom, «Acciones», «OR / últimos dígitos», la
/// acción) con el aire de abajo de la barra; si no se opera, la leyenda
/// entera, que es toda controles. Guarda la última medida; la página decide
/// cuándo aplica ([AvisosSobreElPie.conPlano]).
///
/// Los avisos flotantes (`SnackBar`) se dibujan al pie del `Scaffold` y
/// tapaban esa fila: con el aviso de 6 s que sale con cada registro había que
/// esperar antes del siguiente contenedor (10.29, H2). Con esta medida,
/// [AvisosSobreElPie] pone el aire de abajo de los avisos para que floten
/// **por encima de los controles**, sobre las cifras de la barra, que no se
/// tocan, y nunca sobre la rejilla: el primer intento los puso por encima de
/// la barra entera y en el teléfono bajo, con la silueta a la vista, el aviso
/// cubría la única fila de celdas y la siguiente «Baja» caía sobre él.
/// «Deshacer» queda a mano durante todo su plazo y los controles, tocables.
/// El borde de arriba lo acota [franjaDelPlanoProvider] (10.31).
final pieDelPlanoProvider =
    NotifierProvider<PieDelPlano, double>(PieDelPlano.new);

class PieDelPlano extends Notifier<double> {
  @override
  double build() => 0;

  /// El pie midió [alto].
  void medir(double alto) {
    if (ref.mounted && state != alto) state = alto;
  }
}

/// El alto, en dp, de la franja de la operación en el muelle (la barra con
/// sus cifras y su fila de controles), de donde termina la rejilla al pie del
/// plano. Sin valor cuando el pie no es la franja (la leyenda, fuera de la
/// operación).
///
/// Con la letra a 2.0 el aviso de 6 s crecía hacia arriba más que las cifras
/// y pisaba la última fila de celdas (10.31, H2): nada acotaba su borde de
/// arriba. Con esta medida la página sabe cuánto alto le queda a un aviso
/// entre el borde de arriba de la franja y su aire sobre los controles
/// ([LugarDelAviso]), y el aviso no lo pasa, mida lo que mida su texto
/// ([avisoDelViaje]). Puede tapar las cifras durante su plazo (10.30); la
/// rejilla, el resumen de encima y los controles, nunca.
final franjaDelPlanoProvider =
    NotifierProvider<FranjaDelPlano, double?>(FranjaDelPlano.new);

class FranjaDelPlano extends Notifier<double?> {
  @override
  double? build() => null;

  /// La franja midió [alto]; sin valor, ya no hay franja.
  void medir(double? alto) {
    if (ref.mounted && state != alto) state = alto;
  }
}

/// Envuelve lo que los avisos no deben tapar y anota su alto, más [ajuste],
/// en [pieDelPlanoProvider] después de cada cuadro en que cambia. No dibuja
/// nada.
class MideElPieDelPlano extends ConsumerStatefulWidget {
  const MideElPieDelPlano(
      {super.key, this.ajuste = 0, this.sinFranja = false, required this.child});

  /// Lo que hay debajo de lo medido hasta el pie del plano (el aire de abajo
  /// de la barra de la operación, cuando se mide solo su fila de controles).
  final double ajuste;

  /// El pie es la leyenda, sin franja: los avisos no tienen tope arriba
  /// ([franjaDelPlanoProvider] queda sin valor).
  final bool sinFranja;

  final Widget child;

  @override
  ConsumerState<MideElPieDelPlano> createState() => _MideElPieDelPlanoState();
}

class _MideElPieDelPlanoState extends ConsumerState<MideElPieDelPlano> {
  @override
  Widget build(BuildContext context) => _MideAlto(
        onAlto: (double alto) {
          // Después del cuadro; si el pie ya se fue, no hay nada que anotar.
          if (mounted) {
            ref.read(pieDelPlanoProvider.notifier).medir(alto + widget.ajuste);
            if (widget.sinFranja) {
              ref.read(franjaDelPlanoProvider.notifier).medir(null);
            }
          }
        },
        child: widget.child,
      );
}

/// Envuelve la franja de la operación y anota su alto en
/// [franjaDelPlanoProvider] después de cada cuadro en que cambia. No dibuja
/// nada.
class MideLaFranja extends ConsumerStatefulWidget {
  const MideLaFranja({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<MideLaFranja> createState() => _MideLaFranjaState();
}

class _MideLaFranjaState extends ConsumerState<MideLaFranja> {
  @override
  Widget build(BuildContext context) => _MideAlto(
        onAlto: (double alto) {
          if (mounted) ref.read(franjaDelPlanoProvider.notifier).medir(alto);
        },
        child: widget.child,
      );
}

/// Avisa, después del cuadro, cada vez que el alto de su hijo cambia.
class _MideAlto extends SingleChildRenderObjectWidget {
  const _MideAlto({required this.onAlto, required super.child});

  final ValueChanged<double> onAlto;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderMideAlto(onAlto);

  @override
  void updateRenderObject(
          BuildContext context, _RenderMideAlto renderObject) =>
      renderObject.onAlto = onAlto;
}

class _RenderMideAlto extends RenderProxyBox {
  _RenderMideAlto(this.onAlto);

  ValueChanged<double> onAlto;
  double? _ultimo;

  @override
  void performLayout() {
    super.performLayout();
    final alto = size.height;
    if (_ultimo == alto) return;
    _ultimo = alto;
    // Nunca durante el layout: quien escucha vuelve a construir, y eso va en
    // el cuadro siguiente.
    SchedulerBinding.instance
        .addPostFrameCallback((Duration _) => onAlto(alto));
  }
}

/// Pone el aire de los avisos del `Scaffold` que envuelve según lo que mide
/// el pie del plano ([pieDelPlanoProvider]): con el plano a la vista
/// ([conPlano]), flotan por encima de los controles de la barra de la
/// operación o de la leyenda; sin plano (la Lista, el Avance, las
/// estadísticas), al pie como siempre. Es el tema de los avisos de la página,
/// no de cada aviso: lo que muestre cualquier parte del viaje (el registro con
/// «Deshacer», un error, «cargado correctamente») sale en el mismo sitio.
///
/// Con la franja de la operación a la vista ([franjaDelPlanoProvider]) dice
/// además cuánto alto tiene un aviso ([LugarDelAviso]): el que hay entre el
/// borde de arriba de la franja y su aire sobre los controles.
class AvisosSobreElPie extends ConsumerWidget {
  const AvisosSobreElPie({super.key, this.conPlano = true, required this.child});

  /// Si el plano, con su pie, está a la vista. Si no, la medida no aplica.
  final bool conPlano;

  final Widget child;

  /// El aire de un aviso cuando lo que no debe tapar mide [alto].
  static EdgeInsets aire(BsMedidas medidas, double alto) => EdgeInsets.fromLTRB(
      medidas.espacioL, medidas.espacioXs, medidas.espacioL, medidas.espacioS + alto);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alto = conPlano ? ref.watch(pieDelPlanoProvider) : 0.0;
    final franja = conPlano ? ref.watch(franjaDelPlanoProvider) : null;
    final tema = Theme.of(context);
    final medidas = BsMedidas.de(context);
    final margen = aire(medidas, alto);
    // La franja va del borde de arriba (donde termina la rejilla) al pie del
    // plano; el aire de abajo del aviso ya cubre los controles.
    final lugar = franja == null ? null : franja - margen.bottom;
    return Theme(
      data: tema.copyWith(
        snackBarTheme: tema.snackBarTheme.copyWith(insetPadding: margen),
      ),
      child: LugarDelAviso(
          alto: lugar != null && lugar > 0 ? lugar : null, child: child),
    );
  }
}

/// El alto que tiene un aviso de la página del viaje: del borde de arriba de
/// la franja de la operación a su aire sobre los controles (13.8). Sin valor,
/// no hay tope (la Lista, la oficina, la leyenda).
class LugarDelAviso extends InheritedWidget {
  const LugarDelAviso({super.key, required this.alto, required super.child});

  final double? alto;

  /// El alto del lugar de los avisos donde está [context]; sin valor, sin tope.
  static double? altoDe(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LugarDelAviso>()?.alto;

  @override
  bool updateShouldNotify(LugarDelAviso oldWidget) => oldWidget.alto != alto;
}

/// Un aviso de la página del viaje (`DESIGN.md` 13.8). Todos los avisos de la
/// app se hacen aquí (10.33): también los de otras páginas, que siguen en
/// pantalla al volver al plano mientras dura su plazo, y los de Comparar, que
/// se llama desde el plano. Así caben en su lugar ([LugarDelAviso]) con
/// cualquier letra, donde se vean: compactos, con la acción
/// ([accion], «Deshacer») al lado del texto; si [texto] no cabe entero en el
/// alto que deja la franja, sale [corto], que sigue diciendo qué pasó. Un
/// aviso sin acción que se queda en [corto] lleva «Ver», que abre [texto]
/// entero. Si ni [corto] cabe, se recorta al lugar: la rejilla no se tapa.
/// Sobre el fondo de error ([fondo]), el texto y la acción van en su color de
/// contraste.
SnackBar avisoDelViaje({
  Key? key,
  required String texto,
  String? corto,
  String? accion,
  VoidCallback? onAccion,
  Duration duracion = const Duration(milliseconds: 4000),
  Color? fondo,
}) =>
    SnackBar(
      key: key,
      duration: duracion,
      backgroundColor: fondo,
      behavior: SnackBarBehavior.floating,
      // El relleno lo pone el contenido, que mide lo que ocupa.
      padding: EdgeInsets.zero,
      content: _ContenidoDelAviso(
          texto: texto,
          corto: corto,
          accion: accion,
          onAccion: onAccion,
          fondo: fondo),
    );

/// T-61: al reabrir un viaje, los parámetros del perfil vigente que no se
/// aplicaron ([parametros]). Se ve sobre el plano, también cuando se reabre
/// desde «Viajes recientes», así que va por [avisoDelViaje].
SnackBar avisoDelParametroConservado(Iterable<String> parametros) =>
    avisoDelViaje(
      key: const ValueKey('reopen-kept-parameters'),
      duracion: const Duration(seconds: 10),
      texto: 'No se aplicó del perfil vigente: ${parametros.join(', ')}. '
          'Dejaría contenedores de este viaje fuera del plano; se conserva el '
          'valor guardado con el viaje. Revisa el perfil del buque.',
      corto: 'No se aplicó todo el perfil vigente.',
    );

/// El texto del aviso y su acción, en una fila, con el texto que cabe.
class _ContenidoDelAviso extends StatelessWidget {
  const _ContenidoDelAviso(
      {required this.texto, this.corto, this.accion, this.onAccion, this.fondo});

  final String texto;
  final String? corto;
  final String? accion;
  final VoidCallback? onAccion;

  /// El fondo del aviso, si no es el del tema.
  final Color? fondo;

  /// Lo que dice la acción que abre el texto entero.
  static const String ver = 'Ver';

  @override
  Widget build(BuildContext context) {
    final alto = LugarDelAviso.altoDe(context);
    final medidas = BsMedidas.de(context);
    final esquema = Theme.of(context).colorScheme;
    // Sobre el fondo de error, el texto y la acción van en su color de
    // contraste: la tinta y la marca no llegaban a 3:1 sobre el rojo (10.33).
    final sobreElFondo =
        fondo != null && fondo == esquema.error ? esquema.onError : null;
    // La acción, con menos aire a los lados que en un aviso de Material: con
    // la letra grande deja más ancho al texto.
    final estiloDelBoton = TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: medidas.espacioS))
        .merge(TextButtonTheme.of(context).style);
    Widget fila(String linea, {bool conVer = false}) => Padding(
          padding: EdgeInsetsDirectional.fromSTEB(medidas.espacioL,
              medidas.espacioXs, medidas.espacioXs, medidas.espacioXs),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: medidas.objetivoTactil),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: medidas.espacioXs),
                    child: Text(linea,
                        style: sobreElFondo == null
                            ? null
                            : TextStyle(color: sobreElFondo)),
                  ),
                ),
                if (accion != null || conVer)
                  TextButtonTheme(
                    data: TextButtonThemeData(style: estiloDelBoton),
                    child: SnackBarAction(
                      textColor: sobreElFondo,
                      label: accion ?? ver,
                      onPressed: accion != null
                          ? (onAccion ?? () {})
                          : () => _verEntero(context),
                    ),
                  ),
              ],
            ),
          ),
        );
    if (alto == null) return fila(texto);
    return _ElQueCabe(
      alto: alto,
      children: <Widget>[
        fila(texto),
        if (corto != null && corto != texto)
          fila(corto!, conVer: accion == null),
      ],
    );
  }

  /// El texto entero, en un diálogo.
  void _verEntero(BuildContext context) => showDialog<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          key: const ValueKey('aviso-entero'),
          content: SingleChildScrollView(child: Text(texto)),
          actions: <Widget>[
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar')),
          ],
        ),
      );
}

/// Muestra el primero de sus hijos que cabe en [alto]; si ninguno cabe, el
/// último, recortado a [alto]. Todos se miden al ancho que hay; solo el
/// elegido se dibuja, recibe toques y se anuncia, como en un `IndexedStack`.
class _ElQueCabe extends MultiChildRenderObjectWidget {
  const _ElQueCabe({required this.alto, required super.children});

  final double alto;

  @override
  _RenderElQueCabe createRenderObject(BuildContext context) =>
      _RenderElQueCabe(alto);

  @override
  void updateRenderObject(
          BuildContext context, _RenderElQueCabe renderObject) =>
      renderObject.alto = alto;

  @override
  MultiChildRenderObjectElement createElement() => _ElQueCabeElement(this);
}

class _ElQueCabeElement extends MultiChildRenderObjectElement {
  _ElQueCabeElement(_ElQueCabe super.widget);

  // Lo que no se ve tampoco está para las pruebas.
  @override
  void debugVisitOnstageChildren(ElementVisitor visitor) {
    final elegido = (renderObject as _RenderElQueCabe).elegido;
    var indice = 0;
    for (final hijo in children) {
      if (indice++ == elegido) visitor(hijo);
    }
  }
}

class _ElQueCabeParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderElQueCabe extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, _ElQueCabeParentData> {
  _RenderElQueCabe(this._alto);

  double _alto;
  set alto(double valor) {
    if (valor == _alto) return;
    _alto = valor;
    markNeedsLayout();
  }

  /// El índice del hijo que se ve.
  int elegido = 0;
  RenderBox? _hijoElegido;
  bool _recortado = false;
  final LayerHandle<ClipRectLayer> _recorte = LayerHandle<ClipRectLayer>();

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _ElQueCabeParentData) {
      child.parentData = _ElQueCabeParentData();
    }
  }

  @override
  void performLayout() {
    final alAncho = BoxConstraints(
        minWidth: constraints.minWidth, maxWidth: constraints.maxWidth);
    RenderBox? hijo = firstChild;
    RenderBox? ultimo;
    var indice = 0;
    final anterior = elegido;
    _hijoElegido = null;
    _recortado = false;
    while (hijo != null) {
      hijo.layout(alAncho, parentUsesSize: true);
      if (_hijoElegido == null && hijo.size.height <= _alto) {
        _hijoElegido = hijo;
        elegido = indice;
      }
      ultimo = hijo;
      indice++;
      hijo = childAfter(hijo);
    }
    if (_hijoElegido == null && ultimo != null) {
      // Ninguno cabe: el más corto, con el alto que hay. El tope no se pasa.
      ultimo.layout(alAncho.copyWith(maxHeight: _alto), parentUsesSize: true);
      _hijoElegido = ultimo;
      elegido = indice - 1;
      _recortado = true;
    }
    // Otro texto a la vista: el lector de pantalla lee el nuevo.
    if (elegido != anterior) markNeedsSemanticsUpdate();
    size = constraints.constrain(_hijoElegido?.size ?? Size.zero);
  }

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) {
    final alAncho = BoxConstraints(
        minWidth: constraints.minWidth, maxWidth: constraints.maxWidth);
    Size? ultimo;
    for (RenderBox? hijo = firstChild; hijo != null; hijo = childAfter(hijo)) {
      final medida = hijo.getDryLayout(alAncho);
      if (medida.height <= _alto) return constraints.constrain(medida);
      ultimo = medida;
    }
    return constraints.constrain(ultimo == null
        ? Size.zero
        : Size(ultimo.width, math.min(ultimo.height, _alto)));
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      firstChild?.getMinIntrinsicWidth(height) ?? 0;

  @override
  double computeMaxIntrinsicWidth(double height) =>
      firstChild?.getMaxIntrinsicWidth(height) ?? 0;

  @override
  double computeMinIntrinsicHeight(double width) =>
      math.min(firstChild?.getMinIntrinsicHeight(width) ?? 0, _alto);

  @override
  double computeMaxIntrinsicHeight(double width) =>
      math.min(firstChild?.getMaxIntrinsicHeight(width) ?? 0, _alto);

  @override
  void paint(PaintingContext context, Offset offset) {
    final hijo = _hijoElegido;
    if (hijo == null) return;
    if (!_recortado) {
      _recorte.layer = null;
      context.paintChild(hijo, offset);
      return;
    }
    _recorte.layer = context.pushClipRect(
      needsCompositing,
      offset,
      Offset.zero & size,
      (PaintingContext context, Offset offset) =>
          context.paintChild(hijo, offset),
      oldLayer: _recorte.layer,
    );
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      _hijoElegido?.hitTest(result, position: position) ?? false;

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    final hijo = _hijoElegido;
    if (hijo != null) visitor(hijo);
  }

  @override
  void dispose() {
    _recorte.layer = null;
    super.dispose();
  }
}
