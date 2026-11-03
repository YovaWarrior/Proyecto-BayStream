// T-133 · Las capturas de la marca que no tapa el número de orden (la
// evidencia de build/t133/), con datos sintéticos: las celdas de cerca en
// las dos densidades y los dos temas, a 3×; el plano de carga de la bahía 10
// con los ocho vacíos cruzados en «Revisar», a 360 × 640 con la letra a 1.0
// en claro y en oscuro y a 2.0 en claro, y en la oficina a 1280 × 720; y el
// plano de descarga en las tres vistas de «Colorear por». La evidencia se
// queda en el disco: no va al repositorio (10.94).
//
// Se pintan siempre y se comprueba que hay imagen; los PNG se escriben solo
// con `--dart-define=T133_CAPTURAS=<carpeta>`:
//   flutter test test/t133_capturas_test.dart --dart-define=T133_CAPTURAS=build/t133/despues
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:baystream/core/design/design.dart';
import 'package:baystream/features/vessel/presentation/providers/plano_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/loading_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t117_oficina_support.dart' show t117CargarFuentes;
import 'support/t133_marca_support.dart';

const _destino = String.fromEnvironment('T133_CAPTURAS');

/// La imagen del `RepaintBoundary` de [clave], en PNG.
Future<Uint8List> _png(WidgetTester tester, Key clave, double escala) async {
  final caja = tester.renderObject<RenderRepaintBoundary>(find.byKey(clave));
  late Uint8List png;
  await tester.runAsync(() async {
    final imagen = await caja.toImage(pixelRatio: escala);
    png = (await imagen.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
    imagen.dispose();
  });
  return png;
}

void _guardar(String nombre, Uint8List png) {
  expect(png.length, greaterThan(1000), reason: '$nombre tiene imagen');
  if (_destino.isEmpty) return;
  File('$_destino/$nombre.png')
    ..createSync(recursive: true)
    ..writeAsBytesSync(png);
}

void main() {
  for (final oscuro in <bool>[false, true]) {
    final tema = oscuro ? 'oscuro' : 'claro';
    for (final muelle in <bool>[true, false]) {
      final densidad = muelle ? 'muelle' : 'oficina';
      testWidgets('las celdas de cerca, $densidad, $tema', (tester) async {
        await t117CargarFuentes();
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(400, 300);
        addTearDown(tester.view.reset);
        // Quietas: la recién movida se dibuja en naranja en su sitio (13.3).
        tester.platformDispatcher.accessibilityFeaturesTestValue =
            const FakeAccessibilityFeatures(disableAnimations: true);
        addTearDown(
            tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
        final tema0 = oscuro
            ? BayStreamTema.oscuro(muelle: muelle)
            : BayStreamTema.claro(muelle: muelle);
        await tester.pumpWidget(MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: tema0,
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: RepaintBoundary(
                key: const ValueKey('t133-cerca'),
                child: ColoredBox(
                  color: tema0.colorScheme.surface,
                  child: SizedBox(
                    width: 360,
                    child: t133Muestrario(
                        tema0.extension<BsColoresSemanticos>()!),
                  ),
                ),
              ),
            ),
          ),
        ));
        await tester.pump(const Duration(milliseconds: 50));
        expect(tester.takeException(), isNull);
        _guardar('celdas-$densidad-$tema',
            await _png(tester, const ValueKey('t133-cerca'), 3));
      });
    }
  }

  for (final (archivo, tamano, letra, muelle, oscuro)
      in <(String, Size, double, bool, bool)>[
    ('carga-muelle-360x640', const Size(360, 640), 1.0, true, false),
    ('carga-muelle-360x640-oscuro', const Size(360, 640), 1.0, true, true),
    ('carga-muelle-360x640-letra2', const Size(360, 640), 2.0, true, false),
    ('carga-oficina-1280x720', const Size(1280, 720), 1.0, false, false),
  ]) {
    testWidgets('captura del plano de carga: $archivo', (tester) async {
      await t133PumpCarga(tester,
          tamano: tamano, letra: letra, muelle: muelle, oscuro: oscuro);
      // A 2.0 la rejilla queda bajo el pliegue: se trae a la vista.
      if (letra != 1.0) {
        await tester.ensureVisible(find.byType(LoadingCell).first);
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
      _guardar(archivo, await _png(tester, t133Pantalla, 1));
    });
  }

  for (final vista in ColorearPor.values) {
    testWidgets('captura del plano de descarga, vista ${vista.name}',
        (tester) async {
      await t133PumpDescarga(tester, vista: vista);
      expect(tester.takeException(), isNull);
      _guardar('descarga-muelle-360x640-${vista.name}',
          await _png(tester, t133Pantalla, 1));
    });
  }
}
