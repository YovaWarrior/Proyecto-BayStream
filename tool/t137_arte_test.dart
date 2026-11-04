// T-137 · Arte del asistente, dibujado por Flutter y fuera de la suite.
// Con el semáforo de Carlos: flutter test tool/t137_arte_test.dart
// Tamaños: https://jrsoftware.org/ishelp/topic_setup_wizardimagefile.htm
// y https://jrsoftware.org/ishelp/topic_setup_wizardsmallimagefile.htm.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:baystream/core/design/design.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test/support/t117_oficina_support.dart' show t117CargarFuentes;

// La escala de Inno depende de la fuente de Windows, no de multiplicar por
// el porcentaje. Se conservan las siete medidas exactas de su ayuda.
const _escalas = <({int porcentaje, int ancho, int alto, int pequeno})>[
  (porcentaje: 100, ancho: 202, alto: 386, pequeno: 58),
  (porcentaje: 125, ancho: 269, alto: 515, pequeno: 77),
  (porcentaje: 150, ancho: 336, alto: 643, pequeno: 97),
  (porcentaje: 175, ancho: 403, alto: 772, pequeno: 116),
  (porcentaje: 200, ancho: 430, alto: 824, pequeno: 124),
  (porcentaje: 225, ancho: 498, alto: 953, pequeno: 143),
  (porcentaje: 250, ancho: 534, alto: 1022, pequeno: 159),
];

void main() {
  testWidgets('T-137: genera las 28 imágenes y su manifiesto', (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    // Platform.script puede ser el arnés del SDK en flutter test. Se exige
    // la raíz del proyecto para no escribir imágenes en otro directorio.
    final proyecto = Directory.current;
    expect(
      File('pubspec.yaml').existsSync(),
      isTrue,
      reason: 'Ejecutar desde la raíz de BayStream.',
    );
    expect(File('tool/t137_arte_test.dart').existsSync(), isTrue);
    final destino = Directory.fromUri(
      proyecto.uri.resolve('windows/installer/arte/'),
    );
    final icono = await tester.runAsync(() async {
      await t117CargarFuentes();
      final bytes = await File.fromUri(
        proyecto.uri.resolve('web/icons/Icon-512.png'),
      ).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      try {
        return (await codec.getNextFrame()).image;
      } finally {
        codec.dispose();
      }
    });
    expect(icono, isNotNull);
    addTearDown(() => icono!.dispose());

    final archivos = <Map<String, Object>>[];
    final paletas = <String, Object>{};
    for (final oscuro in [false, true]) {
      final nombre = oscuro ? 'oscuro' : 'claro';
      final paleta = oscuro ? BsPaleta.oscuro : BsPaleta.claro;
      final tema = oscuro ? BayStreamTema.oscuro() : BayStreamTema.claro();
      paletas[nombre] = <String, String>{
        'papel': _hex(paleta.papel),
        'hoja': _hex(paleta.hoja),
        'tinta': _hex(paleta.tinta),
        'tintaSuave': _hex(paleta.tintaSuave),
        'marca': _hex(paleta.marca),
      };
      for (final escala in _escalas) {
        for (final grande in [true, false]) {
          final ancho = grande ? escala.ancho : escala.pequeno;
          final alto = grande ? escala.alto : escala.pequeno;
          final tamano = Size(ancho.toDouble(), alto.toDouble());
          tester.view.physicalSize = tamano;
          final borde = GlobalKey();
          await tester.pumpWidget(
            Directionality(
              textDirection: TextDirection.ltr,
              child: MediaQuery(
                data: MediaQueryData(
                  size: tamano,
                  disableAnimations: true,
                  textScaler: TextScaler.noScaling,
                ),
                child: Theme(
                  data: tema,
                  child: DefaultTextStyle(
                    style: tema.textTheme.bodyMedium!,
                    child: RepaintBoundary(
                      key: borde,
                      child: ColoredBox(
                        color: paleta.papel,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: grande
                              ? _ArteGrande(paleta: paleta, icono: icono!)
                              : _ArtePequeno(paleta: paleta, icono: icono!),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(
            tester.getSize(find.byType(FittedBox)),
            tamano,
            reason: 'El dibujo debe escalar al lienzo completo en cada DPI.',
          );
          final objeto =
              borde.currentContext!.findRenderObject() as RenderRepaintBoundary;
          expect(objeto.size, tamano);
          final archivo =
              '${grande ? 'grande' : 'pequena'}_'
              '${nombre}_${escala.porcentaje}.png';
          await tester.runAsync(() async {
            final imagen = await objeto.toImage(pixelRatio: 1);
            try {
              expect(imagen.width, ancho);
              expect(imagen.height, alto);
              final png = await imagen.toByteData(
                format: ui.ImageByteFormat.png,
              );
              expect(png, isNotNull);
              final bytes = png!.buffer.asUint8List(
                png.offsetInBytes,
                png.lengthInBytes,
              );
              await destino.create(recursive: true);
              await File.fromUri(
                destino.uri.resolve(archivo),
              ).writeAsBytes(bytes, flush: true);
              archivos.add({
                'archivo': archivo,
                'ancho': ancho,
                'alto': alto,
                'escala': escala.porcentaje,
                'tema': nombre,
                'tipo': grande ? 'grande' : 'pequena',
                'sha256': sha256.convert(bytes).toString(),
              });
            } finally {
              imagen.dispose();
            }
          });
        }
      }
    }
    expect(archivos.length, 28);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(() async {
      // Las huellas impiden empaquetar imágenes anteriores a un cambio de
      // paleta, de ilustración, de tipografía o de este mismo generador.
      final fuentes = <Map<String, String>>[];
      final rutas = <String>[
        'tool/t137_arte_test.dart',
        'test/support/t117_oficina_support.dart',
        'web/icons/Icon-512.png',
        'lib/core/design/bs_paleta.dart',
        'lib/core/design/bs_tipografia.dart',
        'lib/core/design/bs_ilustraciones.dart',
        'lib/core/design/bs_tema.dart',
        'lib/core/design/bs_medidas.dart',
        'lib/core/design/bs_colores_semanticos.dart',
        'lib/core/design/bs_categorico.dart',
        'lib/core/design/componentes/bs_ilustracion.dart',
        'lib/core/design/componentes/bs_fondo_de_plano.dart',
        for (final archivo in Directory.fromUri(
          proyecto.uri.resolve('assets/fonts/plex/'),
        ).listSync().whereType<File>())
          if (archivo.path.endsWith('.ttf'))
            'assets/fonts/plex/${archivo.uri.pathSegments.last}',
        'assets/fonts/Roboto-Regular.ttf',
        'assets/fonts/Roboto-Medium.ttf',
      ]..sort();
      for (final ruta in rutas) {
        final archivo = File.fromUri(proyecto.uri.resolve(ruta));
        fuentes.add({
          'archivo': ruta,
          'sha256': (await sha256.bind(archivo.openRead()).first).toString(),
        });
      }
      await File.fromUri(destino.uri.resolve('manifiesto.json')).writeAsString(
        '${const JsonEncoder.withIndent('  ').convert({'schema': 1, 'generador': 'flutter test tool/t137_arte_test.dart', 'paletas': paletas, 'fuentes': fuentes, 'archivos': archivos})}\n',
        flush: true,
      );
    });
  });
}

String _hex(Color color) =>
    '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';

class _ArtePequeno extends StatelessWidget {
  const _ArtePequeno({required this.paleta, required this.icono});

  final BsPaleta paleta;
  final ui.Image icono;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 58,
    height: 58,
    child: ColoredBox(
      color: paleta.papel,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: RawImage(image: icono, filterQuality: FilterQuality.high),
      ),
    ),
  );
}

class _ArteGrande extends StatelessWidget {
  const _ArteGrande({required this.paleta, required this.icono});

  final BsPaleta paleta;
  final ui.Image icono;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return SizedBox(
      width: 202,
      height: 386,
      child: BsFondoDePlano(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: RawImage(
                      image: icono,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('BayStream', style: texto.titleLarge),
                  const SizedBox(height: 4),
                  Text('Plano de estiba', style: texto.bodyMedium),
                  const SizedBox(height: 4),
                  Text('Tu carga, a la vista.', style: texto.bodySmall),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 126,
              width: 202,
              child: CustomPaint(
                painter: PintorDeIlustracion(
                  datos: BsIlustraciones.inicio,
                  paleta: paleta,
                  semanticos: BsColoresSemanticos.de(context),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: paleta.linea, height: 1),
                  const SizedBox(height: 12),
                  Text(
                    'OFICINA Y MUELLE',
                    style: texto.labelSmall?.copyWith(color: paleta.marca),
                  ),
                  const SizedBox(height: 4),
                  Text('Windows, Android y Web', style: texto.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
