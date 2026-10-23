import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/plano_providers.dart';

/// El chip del zoom del plano (T-106) fuera de la rejilla (10.20): «100 %» en
/// la línea de los controles y, al tocarlo, un menú anclado con alejar,
/// restablecer y acercar. Antes flotaba en la esquina inferior derecha de la
/// rejilla y a 360 dp con la letra a 1.45 y 2.0 tapaba la última columna; en
/// la línea de los controles no tapa ninguna celda y el menú no se desborda.
/// La escala vive en `planZoomProvider`; la rejilla la lee en
/// `PlanZoomViewport`. Las claves de T-105 y T-106 se conservan.
class ZoomDelPlano extends ConsumerWidget {
  const ZoomDelPlano({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final escala = ref.watch(planZoomProvider);
    final zoom = ref.read(planZoomProvider.notifier);
    final porcentaje = '${(escala * 100).round()} %';
    return MenuAnchor(
      key: const ValueKey('plan-zoom-menu'),
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
