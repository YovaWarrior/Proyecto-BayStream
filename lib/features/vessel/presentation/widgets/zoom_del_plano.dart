import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/plano_providers.dart';
import 'navegacion_del_viaje.dart';

/// El chip del zoom del plano (T-106) fuera de la rejilla (10.20): «100 %» en
/// la línea de los controles y, al tocarlo, un menú anclado con alejar,
/// restablecer y acercar. Antes flotaba en la esquina inferior derecha de la
/// rejilla y a 360 dp con la letra a 1.45 y 2.0 tapaba la última columna; en
/// la línea de los controles no tapa ninguna celda y el menú no se desborda.
/// La escala vive en `planZoomProvider`; la rejilla la lee en
/// `PlanZoomViewport`. Las claves de T-105 y T-106 se conservan.
///
/// El menú no es una ruta, así que Atrás no lo cierra solo: mientras está
/// abierto se anota en [cerrablesDeAtrasProvider] y Atrás lo cierra antes que
/// nada (`DESIGN.md` 8).
class ZoomDelPlano extends ConsumerStatefulWidget {
  const ZoomDelPlano({super.key});

  @override
  ConsumerState<ZoomDelPlano> createState() => _ZoomDelPlanoState();
}

class _ZoomDelPlanoState extends ConsumerState<ZoomDelPlano> {
  final MenuController _menu = MenuController();
  late final VoidCallback _cerrar = _menu.close;
  bool _anotado = false;

  /// El registro donde el menú se anotó, guardado al abrir: en `dispose` no
  /// se puede usar `ref`, y el menú puede desmontarse abierto.
  CerrablesDeAtras? _registro;

  void _abierto() {
    _anotado = true;
    final registro = ref.read(cerrablesDeAtrasProvider.notifier);
    _registro = registro;
    registro.anotar(_cerrar);
  }

  void _cerrado() {
    if (!_anotado) return;
    _anotado = false;
    _registro?.olvidar(_cerrar);
  }

  @override
  void dispose() {
    _cerrado();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final escala = ref.watch(planZoomProvider);
    final zoom = ref.read(planZoomProvider.notifier);
    final porcentaje = '${(escala * 100).round()} %';
    return MenuAnchor(
      key: const ValueKey('plan-zoom-menu'),
      controller: _menu,
      onOpen: _abierto,
      onClose: _cerrado,
      menuChildren: <Widget>[
        Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
          IconButton(
            key: const ValueKey('plan-zoom-out'),
            tooltip: 'Alejar plano',
            onPressed: escala <= PlanZoomNotifier.minimo ? null : zoom.alejar,
            icon: const Icon(Icons.zoom_out),
          ),
          // El botón dice lo que hace (reglas de texto, 11.2); el porcentaje
          // vigente sigue en el chip, que queda a la vista con el menú abierto.
          TextButton(
            key: const ValueKey('plan-zoom-reset'),
            onPressed: zoom.restablecer,
            child: Semantics(
              label: 'Restablecer zoom del plano',
              child: const Text('Restablecer'),
            ),
          ),
          IconButton(
            key: const ValueKey('plan-zoom-in'),
            tooltip: 'Acercar plano',
            onPressed: escala >= PlanZoomNotifier.maximo ? null : zoom.acercar,
            icon: const Icon(Icons.zoom_in),
          ),
        ]),
      ],
      builder: (BuildContext context, MenuController menu, Widget? _) =>
          Tooltip(
        message: 'Zoom del plano',
        child: TextButton(
          key: const ValueKey('plan-zoom-toggle'),
          onPressed: () => menu.isOpen ? menu.close() : menu.open(),
          child: Text(porcentaje),
        ),
      ),
    );
  }
}
