// T-131 · Las capturas del distintivo de rol (la evidencia de build/t131/):
// las tres cabeceras en claro y en oscuro, con datos sintéticos (BUQUE
// MANUAL y cuentas sintéticas): el muelle a 360 × 800, la oficina en un
// teléfono a 390 × 844 y la oficina a 1366 × 768, también con la letra a 2.0
// en claro; y los cuatro distintivos de cerca, a 3×. «Nube y cuenta» no sale
// en ninguna. La evidencia se queda en el disco: no va al repositorio.
//
// Se pintan siempre y se comprueba que hay imagen; los PNG se escriben solo
// con `--dart-define=T131_CAPTURAS=<carpeta>`:
//   flutter test test/t131_capturas_test.dart --dart-define=T131_CAPTURAS=build/t131
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:baystream/core/design/design.dart';
import 'package:baystream/core/design/vistas_previas.dart';
import 'package:baystream/features/vessel/domain/repositories/session_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t117_oficina_support.dart' show t117CargarFuentes;
import 'support/t131_cabeceras_support.dart';

const _destino = String.fromEnvironment('T131_CAPTURAS');

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
  // En la banda y en la cabecera de la oficina el distintivo cede a los
  // controles (13.12): la captura muestra lo que sale, con él o sin él.
  for (final (donde, cuenta, archivo, letra, temas)
      in <(T131Cabecera, Operator, String, double, List<bool>)>[
    (T131Cabecera.banda, t131Muelle, 'muelle-360x800', 1.0, [false, true]),
    (T131Cabecera.barraDeLaOficina, t131Oficina, 'oficina-telefono-390x844',
        1.0, [false, true]),
    (T131Cabecera.cabecera, t131Oficina, 'oficina-1366x768', 1.0, [false, true]),
    (T131Cabecera.cabecera, t131Oficina, 'oficina-1366x768-letra2', 2.0, [false]),
  ]) {
    for (final oscuro in temas) {
      final tema = oscuro ? 'oscuro' : 'claro';
      testWidgets('captura de ${donde.nombre}, letra $letra, $tema',
          (tester) async {
        await t131Pump(tester, donde,
            cuenta: cuenta, oscuro: oscuro, letra: letra, capturable: true);
        if (donde == T131Cabecera.barraDeLaOficina) {
          expect(t131Distintivo(tester, donde.donde), isNotNull);
        }
        expect(find.text('Nube y cuenta'), findsNothing);
        _guardar('$archivo-$tema',
            await _png(tester, const ValueKey('t131-pantalla'), 1));
      });
    }
  }

  for (final oscuro in <bool>[false, true]) {
    final tema = oscuro ? 'oscuro' : 'claro';
    for (final muelle in <bool>[true, false]) {
      final densidad = muelle ? 'muelle' : 'oficina';
      testWidgets('los cuatro distintivos de cerca, $densidad, $tema',
          (tester) async {
        await t117CargarFuentes();
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(440, 360);
        addTearDown(tester.view.reset);
        await tester.pumpWidget(MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: BayStreamTema.claro(muelle: muelle),
          darkTheme: BayStreamTema.oscuro(muelle: muelle),
          themeMode: oscuro ? ThemeMode.dark : ThemeMode.light,
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: RepaintBoundary(
                key: const ValueKey('t131-cerca'),
                child: SizedBox(
                  width: 420,
                  child: muelle
                      ? vistaPreviaDistintivoDeRol()
                      : vistaPreviaDistintivoDeRolOficina(),
                ),
              ),
            ),
          ),
        ));
        await tester.pump(const Duration(milliseconds: 50));
        _guardar('distintivos-$densidad-$tema',
            await _png(tester, const ValueKey('t131-cerca'), 3));
      });
    }
  }
}
