// T-114 · El paquete de íconos e ilustraciones (10.19), parte B: la fuente
// BayStreamIconos y sus constantes.
//   - pubspec declara la familia con su único asset, y el TTF es el del LEEME
//     (SHA-256 de la tabla del paquete);
//   - codigos.json y BsIconos coinciden: 35 glifos de U+E000 a U+E022, con el
//     catálogo por nombre;
//   - el cmap del TTF trae los 35 códigos;
//   - con la fuente cargada, cada constante pinta su glifo y los 35 son
//     distintos entre sí;
//   - una muestra, pintada como texto a 16 y 24 px, coincide con su SVG
//     (el mismo trazado, rasterizado con Canvas), con tolerancia de borde.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:baystream/core/design/bs_iconos.dart';
import 'package:baystream/core/design/bs_iconos_catalogo.dart';
import 'package:baystream/core/design/componentes/bs_ilustracion.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _ttf = 'assets/fonts/bs_iconos/BayStreamIconos.ttf';

/// El SHA-256 del TTF en la tabla «Archivos» de design/iconos/LEEME.md (v2).
const _sha256DelLeeme =
    '8eec33ae80a6d3bd73f1214626fc20ebc90df77927107d75628b8d9a2b159147';

/// La muestra que se compara con su SVG: contenedores, lo que más se usa en
/// la celda, las dos flechas de Carlos (10.19) y dos insignias.
const _muestra = <String>[
  'contenedor_20',
  'contenedor_40',
  'vacio',
  'refrigerado',
  'peligrosa',
  'buque',
  'bahia',
  'descarga',
  'carga',
  'grua',
  'al_dia',
  'insignia_refrigerado',
  'insignia_peligrosa',
];

var _fuenteCargada = false;

Future<void> _cargarFuente() async {
  if (_fuenteCargada) return;
  _fuenteCargada = true;
  final cargador = FontLoader(BsIconos.familia)..addFont(rootBundle.load(_ttf));
  await cargador.load();
}

/// Los puntos de código con glifo en el `cmap` del TTF (formatos 4 y 12).
Set<int> _codigosDelCmap(Uint8List bytes) {
  final datos = ByteData.sublistView(bytes);
  final tablas = datos.getUint16(4);
  int? cmap;
  for (var i = 0; i < tablas; i++) {
    final registro = 12 + i * 16;
    if (String.fromCharCodes(bytes.sublist(registro, registro + 4)) == 'cmap') {
      cmap = datos.getUint32(registro + 8);
      break;
    }
  }
  if (cmap == null) throw StateError('El TTF no trae tabla cmap');
  final codigos = <int>{};
  final subtablas = datos.getUint16(cmap + 2);
  for (var i = 0; i < subtablas; i++) {
    final sub = cmap + datos.getUint32(cmap + 4 + i * 8 + 4);
    final formato = datos.getUint16(sub);
    if (formato == 4) {
      final segmentos = datos.getUint16(sub + 6) ~/ 2;
      final fines = sub + 14;
      final inicios = fines + segmentos * 2 + 2;
      final deltas = inicios + segmentos * 2;
      final rangos = deltas + segmentos * 2;
      for (var s = 0; s < segmentos; s++) {
        final fin = datos.getUint16(fines + s * 2);
        final inicio = datos.getUint16(inicios + s * 2);
        final delta = datos.getUint16(deltas + s * 2);
        final rango = datos.getUint16(rangos + s * 2);
        if (inicio == 0xFFFF) continue;
        for (var c = inicio; c <= fin; c++) {
          var glifo = rango == 0
              ? (c + delta) & 0xFFFF
              : datos.getUint16(rangos + s * 2 + rango + (c - inicio) * 2);
          if (rango != 0 && glifo != 0) glifo = (glifo + delta) & 0xFFFF;
          if (glifo != 0) codigos.add(c);
        }
      }
    } else if (formato == 12) {
      final grupos = datos.getUint32(sub + 12);
      for (var g = 0; g < grupos; g++) {
        final base = sub + 16 + g * 12;
        final inicio = datos.getUint32(base);
        final fin = datos.getUint32(base + 4);
        for (var c = inicio; c <= fin; c++) {
          codigos.add(c);
        }
      }
    }
  }
  return codigos;
}

/// El glifo pintado como texto, negro sobre transparente, en un cuadrado de
/// [lado] px: el em es el cuadrado (ascendente 1024, descendente 0, avance
/// 1024), así que el dibujo de 24 cae en el lienzo sin correrse.
ui.Picture _glifo(IconData icono, double lado) {
  final grabadora = ui.PictureRecorder();
  final lienzo = Canvas(grabadora);
  final pintor = TextPainter(
    text: TextSpan(
      text: String.fromCharCode(icono.codePoint),
      style: TextStyle(
        fontFamily: icono.fontFamily,
        fontSize: lado,
        color: const Color(0xFF000000),
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  pintor.paint(lienzo, Offset.zero);
  pintor.dispose();
  return grabadora.endRecording();
}

/// El SVG del paquete pintado con Canvas al mismo tamaño: su único `path`
/// (M, L, C y Z absolutos, el mismo lector de las ilustraciones), escalado de
/// su rejilla (24, o 12 con el `scale(0.5)` de las insignias) a [lado].
ui.Picture _svg(String nombre, double lado) {
  final insignia = nombre.startsWith('insignia_');
  final archivo = File(insignia
      ? 'design/iconos/svg_insignias/${nombre.substring('insignia_'.length)}.svg'
      : 'design/iconos/svg/$nombre.svg');
  final texto = archivo.readAsStringSync();
  final rejilla = double.parse(
      RegExp(r'viewBox="0 0 (\d+) (\d+)"').firstMatch(texto)!.group(1)!);
  final rutas = RegExp(r' d="([^"]+)"').allMatches(texto).toList();
  expect(rutas, hasLength(1), reason: '$nombre: un solo path');
  final escalaInterna = texto.contains('transform="scale(0.5)"') ? 0.5 : 1.0;
  final grabadora = ui.PictureRecorder();
  Canvas(grabadora)
    ..scale(lado / rejilla)
    ..scale(escalaInterna)
    ..drawPath(
      rutaDeIlustracion(rutas.single.group(1)!),
      Paint()
        ..color = const Color(0xFF000000)
        ..style = PaintingStyle.fill,
    );
  return grabadora.endRecording();
}

Future<Uint8List> _pixeles(ui.Picture dibujo, int lado) async {
  final imagen = await dibujo.toImage(lado, lado);
  final bytes = await imagen.toByteData(format: ui.ImageByteFormat.rawRgba);
  imagen.dispose();
  dibujo.dispose();
  return bytes!.buffer.asUint8List();
}

/// Cuántos píxeles tienen tinta (alfa por encima de la mitad).
int _tinta(Uint8List rgba) {
  var n = 0;
  for (var i = 3; i < rgba.length; i += 4) {
    if (rgba[i] > 127) n++;
  }
  return n;
}

/// En cuántos píxeles difiere la tinta de dos dibujos del mismo tamaño.
int _distintos(Uint8List a, Uint8List b) {
  var n = 0;
  for (var i = 3; i < a.length; i += 4) {
    if ((a[i] > 127) != (b[i] > 127)) n++;
  }
  return n;
}

/// La diferencia media de alfa, de 0 a 255.
double _diferenciaMedia(Uint8List a, Uint8List b) {
  var suma = 0;
  for (var i = 3; i < a.length; i += 4) {
    suma += (a[i] - b[i]).abs();
  }
  return suma / (a.length ~/ 4);
}

void main() {
  final pubspec = File('pubspec.yaml').readAsStringSync().replaceAll('\r\n', '\n');
  final codigos = (jsonDecode(File('design/iconos/codigos.json').readAsStringSync())
          as Map<String, dynamic>)['codigos'] as Map<String, dynamic>;

  test('pubspec declara BayStreamIconos con su único asset, y nada más', () {
    expect(
        pubspec,
        contains('    - family: BayStreamIconos\n'
            '      fonts:\n'
            '        - asset: $_ttf\n'));
    expect('- family: BayStreamIconos'.allMatches(pubspec), hasLength(1));
    expect(RegExp(r'- asset: assets/fonts/bs_iconos/').allMatches(pubspec),
        hasLength(1));
  });

  test('el TTF existe y es el del LEEME del paquete (SHA-256)', () {
    final archivo = File(_ttf);
    expect(archivo.existsSync(), isTrue);
    expect(sha256.convert(archivo.readAsBytesSync()).toString(), _sha256DelLeeme);
  });

  test('codigos.json y BsIconos coinciden: 35 glifos de U+E000 a U+E022', () {
    expect(codigos, hasLength(35));
    expect(BsIconosCatalogo.todos, hasLength(35));
    expect(BsIconosCatalogo.iconos, hasLength(31));
    expect(BsIconosCatalogo.insignias, hasLength(4));
    expect(BsIconosCatalogo.todos.keys.toSet(), codigos.keys.toSet());
    for (final entrada in codigos.entries) {
      final icono = BsIconosCatalogo.todos[entrada.key]!;
      final esperado =
          int.parse((entrada.value as String).substring(2), radix: 16);
      expect(icono.codePoint, esperado, reason: entrada.key);
      expect(icono.fontFamily, BsIconos.familia, reason: entrada.key);
      expect(icono.fontPackage, isNull, reason: entrada.key);
    }
    final puntos = BsIconosCatalogo.todos.values.map((i) => i.codePoint).toList()
      ..sort();
    expect(puntos.first, 0xE000);
    expect(puntos.last, 0xE022);
    expect(puntos.toSet(), hasLength(35), reason: 'sin códigos repetidos');
    for (final nombre in BsIconosCatalogo.insignias.keys) {
      expect(nombre, startsWith('insignia_'));
      expect(BsIconosCatalogo.rejillaDe(nombre), 12);
    }
    expect(BsIconosCatalogo.rejillaDe('buque'), 24);
  });

  test('el cmap de la fuente trae un glifo para cada uno de los 35 códigos', () {
    final presentes = _codigosDelCmap(File(_ttf).readAsBytesSync());
    for (final entrada in BsIconosCatalogo.todos.entries) {
      expect(presentes, contains(entrada.value.codePoint), reason: entrada.key);
    }
    // Ningún glifo de más en el área de uso privado.
    expect(presentes.where((c) => c >= 0xE000 && c <= 0xF8FF), hasLength(35));
  });

  testWidgets('con la fuente cargada, cada constante pinta su glifo y los 35 son distintos',
      (tester) async {
    await _cargarFuente();
    const lado = 24;
    final dibujos = <String, Uint8List>{};
    await tester.runAsync(() async {
      for (final entrada in BsIconosCatalogo.todos.entries) {
        dibujos[entrada.key] =
            await _pixeles(_glifo(entrada.value, lado.toDouble()), lado);
      }
    });
    for (final entrada in dibujos.entries) {
      expect(_tinta(entrada.value), greaterThanOrEqualTo(40),
          reason: '${entrada.key} pinta algo a 24 px');
      expect(_tinta(entrada.value), lessThan(lado * lado),
          reason: '${entrada.key} no es un cuadrado macizo');
    }
    final nombres = dibujos.keys.toList();
    for (var i = 0; i < nombres.length; i++) {
      for (var j = i + 1; j < nombres.length; j++) {
        expect(_distintos(dibujos[nombres[i]]!, dibujos[nombres[j]]!),
            greaterThanOrEqualTo(8),
            reason: '${nombres[i]} y ${nombres[j]} se distinguen a 24 px');
      }
    }
  });

  for (final lado in <int>[16, 24]) {
    testWidgets('la muestra pintada como texto a $lado px coincide con su SVG',
        (tester) async {
      await _cargarFuente();
      final informe = <String>[];
      await tester.runAsync(() async {
        for (final nombre in _muestra) {
          final icono = BsIconosCatalogo.todos[nombre]!;
          final texto = await _pixeles(_glifo(icono, lado.toDouble()), lado);
          final svg = await _pixeles(_svg(nombre, lado.toDouble()), lado);
          final total = lado * lado;
          final distintos = _distintos(texto, svg);
          final media = _diferenciaMedia(texto, svg);
          informe.add('$nombre: $distintos de $total píxeles cambian de estado, '
              'Δ medio ${media.toStringAsFixed(2)}');
          expect(_tinta(svg), greaterThan(0), reason: '$nombre: el SVG pinta');
          // La misma geometría, rasterizada por el texto y por el lienzo:
          // cambian solo los bordes. El paquete midió hasta un 10.4 % de
          // píxeles en Chromium a 24 px (comprobacion-skia.md) y aquí `buque`
          // da 10.9 % con Skia: el tope es 12 %, y el Δ medio de alfa, 16/255.
          expect(distintos / total, lessThanOrEqualTo(0.12),
              reason: '$nombre a $lado px: $distintos de $total píxeles cambian');
          expect(media, lessThanOrEqualTo(16),
              reason: '$nombre a $lado px: Δ medio de alfa $media');
        }
      });
      // Queda en la salida de la prueba, como el comprobacion-skia.md del paquete.
      debugPrint('muestra a $lado px:\n  ${informe.join('\n  ')}');
    });
  }
}
