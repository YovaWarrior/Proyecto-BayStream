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

/// Envuelve lo que los avisos no deben tapar y anota su alto, más [ajuste],
/// en [pieDelPlanoProvider] después de cada cuadro en que cambia. No dibuja
/// nada.
class MideElPieDelPlano extends ConsumerStatefulWidget {
  const MideElPieDelPlano({super.key, this.ajuste = 0, required this.child});

  /// Lo que hay debajo de lo medido hasta el pie del plano (el aire de abajo
  /// de la barra de la operación, cuando se mide solo su fila de controles).
  final double ajuste;

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
          }
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
    final tema = Theme.of(context);
    final medidas = BsMedidas.de(context);
    return Theme(
      data: tema.copyWith(
        snackBarTheme:
            tema.snackBarTheme.copyWith(insetPadding: aire(medidas, alto)),
      ),
      child: child,
    );
  }
}
