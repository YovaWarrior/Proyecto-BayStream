// Aceptación de T-111 (Timonel, 19-oct): barrido de anchos y escalas de la
// tarjeta del viaje, con el widget real.
//
// Corre igual en una copia del padre (83d0dc1) y en una de HEAD:
// - en el padre, con T111ACC_CAPTURE_BASELINE=true, escribe la referencia;
// - en HEAD la compara.
// Para cada viaje, ancho y escala registra si la fila de indicadores se apila,
// qué textos se parten en más de una línea y la huella RGBA de la tarjeta.
// En HEAD exige: ningún texto partido; si la fila no se apila, la tarjeta es
// idéntica a la del padre; si se apila y en el padre no, el padre partía algo.
// El corpus llega por BAYSTREAM_CORPUS_DIRECTORY y la salida va a
// T111ACC_OUTPUT, en %TEMP%. ACC2 es sintético: una sola reserva.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/widgets/voyage_summary_card.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const corpus = String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');
const output = String.fromEnvironment('T111ACC_OUTPUT');
const capture = bool.fromEnvironment('T111ACC_CAPTURE_BASELINE');

/// Un 20 en la 1, un 40 (45G1) en la 4 y una sola reserva de 40 en la 10.
const acc2 = "UNB+UNOA:2+ACEPTACION+BAYSTREAM+261019:1300+ACC2'"
    "UNH+ACC2+BAPLIE:D:95B:UN:SMDG22'BGM++ACC2+9'"
    "DTM+137:2610191300:201'"
    "TDT+20+ACC2+++TEST:172:20+++:::BUQUE ACEPTACION DOS'"
    "LOC+5+GTSTC:139:6'"
    "LOC+147+0010082::5'MEA+WT++KGM:12000'LOC+9+GTSTC:139:6'"
    "LOC+11+PAMIT:139:6'EQD+CN+MSCU1234566+22G1++2+5'"
    "LOC+147+0040082::5'MEA+WT++KGM:20000'LOC+9+GTSTC:139:6'"
    "LOC+11+PAMIT:139:6'EQD+CN+CSQU3054383+45G1++2+5'"
    "LOC+147+0100082::5'LOC+9+GTSTC:139:6'LOC+11+PAMIT:139:6'"
    "EQD+CN++45G1+++4'"
    "UNT+20+ACC2'UNZ+1+ACC2'";

const widths = [300.0, 320.0, 340.0, 360.0, 400.0, 480.0, 600.0, 1280.0];
const scales = [1.0, 1.15, 1.3, 1.45, 1.6, 2.0];

VesselVoyage _voyage(String text) {
  final parsed = BaplieParserService().parse(text);
  return parsed.withGeometry(VesselGeometry.proposeFrom(parsed.stowagePositions));
}

String _weight(double kg) => kg >= 1000
    ? '${(kg / 1000).toStringAsFixed(1)} t'
    : '${kg.toStringAsFixed(0)} kg';

Future<Map<String, Object?>> _case(
    WidgetTester tester, VesselVoyage voyage, double width, double scale) async {
  const key = ValueKey('t111acc-card');
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  await tester.pumpWidget(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, fontFamily: 'Roboto'),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: RepaintBoundary(key: key, child: VoyageSummaryCard(voyage: voyage)),
      ),
    ),
  ));
  await tester.pumpAndSettle();
  final card = find.byKey(key);
  final texts = [
    'Contenedores',
    'Bahías',
    'Peso total',
    voyage.totalContainers.toString(),
    voyage.bays.length.toString(),
    _weight(voyage.totalWeight),
  ];
  final split = <String>[];
  for (final text in texts) {
    for (final element
        in find.descendant(of: card, matching: find.text(text)).evaluate()) {
      final paragraph = element.renderObject! as RenderParagraph;
      final boxes = paragraph.getBoxesForSelection(
          TextSelection(baseOffset: 0, extentOffset: text.length));
      if (boxes.map((box) => box.top.round()).toSet().length > 1) {
        split.add(text);
      }
    }
  }
  final first = tester.getCenter(
      find.descendant(of: card, matching: find.text('Contenedores')));
  final second =
      tester.getCenter(find.descendant(of: card, matching: find.text('Bahías')));
  final boundary = tester.renderObject<RenderRepaintBoundary>(card);
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    image.dispose();
    return data!.buffer.asUint8List();
  });
  final reserved =
      find.byKey(const ValueKey('voyage-reserved-count')).evaluate();
  expect(tester.takeException(), isNull);
  return {
    'stacked': second.dy > first.dy + 0.5,
    'split': split,
    'rgba': sha256.convert(bytes!).toString(),
    'reserved': reserved.isEmpty
        ? null
        : (reserved.single.widget as Text).data,
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final font = FontLoader('Roboto')
      ..addFont(rootBundle.load('assets/fonts/Roboto-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Roboto-Medium.ttf'));
    await font.load();
  });

  testWidgets('T111ACC · barrido de la tarjeta contra el padre',
      (tester) async {
    expect(corpus, isNotEmpty, reason: 'Falta BAYSTREAM_CORPUS_DIRECTORY');
    expect(output, contains('Temp'), reason: 'T111ACC_OUTPUT debe ir a TEMP');
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    String read(String name) => File('$corpus${Platform.pathSeparator}$name')
        .readAsStringSync(encoding: latin1);
    final voyages = {
      'A07': _voyage(read('CORPUS_A07.edi')),
      'A03': _voyage(read('CORPUS_A03.edi')),
      'A08': _voyage(read('CORPUS_A08.edi')),
      'ACC2': _voyage(acc2),
    };
    final current = <String, Object?>{};
    for (final entry in voyages.entries) {
      for (final width in widths) {
        for (final scale in scales) {
          current['${entry.key} $width $scale'] =
              await _case(tester, entry.value, width, scale);
        }
      }
    }
    final out = Directory(output)..createSync(recursive: true);
    const name = capture ? 'baseline.json' : 'head.json';
    File('${out.path}${Platform.pathSeparator}$name').writeAsStringSync(
        const JsonEncoder.withIndent(' ').convert(current));
    if (capture) {
      stdout.writeln('T111ACC_BASELINE ${current.length} casos');
      return;
    }

    final base = jsonDecode(File('${out.path}${Platform.pathSeparator}'
            'baseline.json')
        .readAsStringSync()) as Map<String, dynamic>;
    final fixed = <String>[];
    final kept = <String>[];
    final failures = <String>[];
    for (final entry in current.entries) {
      final now = entry.value! as Map<String, Object?>;
      final before = Map<String, dynamic>.from(base[entry.key] as Map);
      final hadSplit = (before['split'] as List).isNotEmpty;
      if ((now['split'] as List).isNotEmpty) {
        failures.add('${entry.key}: HEAD parte ${now['split']}');
      }
      if (before['stacked'] == true && now['stacked'] != true) {
        failures.add('${entry.key}: el padre apilaba y HEAD no');
      }
      if (now['stacked'] != true) {
        // Si caben, el ancho de antes: la misma tarjeta, salvo el singular.
        if (before['stacked'] == true || hadSplit) {
          failures.add('${entry.key}: fila en HEAD donde el padre no cabía');
        } else if (!entry.key.startsWith('ACC2') &&
            now['rgba'] != before['rgba']) {
          failures.add('${entry.key}: la fila cambió de píxeles');
        }
        kept.add(entry.key);
      } else if (before['stacked'] != true) {
        if (!hadSplit) failures.add('${entry.key}: apila sin necesidad');
        fixed.add('${entry.key} (el padre partía ${before['split']})');
      }
      if (entry.key.startsWith('ACC2')) {
        if (before['reserved'] != '2 contenedores · 1 celdas reservadas' ||
            now['reserved'] != '2 contenedores · 1 celda reservada') {
          failures.add('${entry.key}: reservas ${before['reserved']} -> '
              '${now['reserved']}');
        }
      } else if (now['reserved'] != before['reserved']) {
        failures.add('${entry.key}: cambió el resumen de reservas');
      }
    }
    final lines = [
      'Casos: ${current.length}',
      'Fila conservada, idéntica al padre: ${kept.length}',
      'Apilados por T-111 donde el padre partía: ${fixed.length}',
      ...fixed.map((line) => '  $line'),
      'Fallas: ${failures.length}',
      ...failures.map((line) => '  $line'),
    ];
    File('${out.path}${Platform.pathSeparator}resumen.txt')
        .writeAsStringSync('${lines.join('\n')}\n');
    stdout.writeln(lines.join('\n'));
    expect(failures, isEmpty);
  }, timeout: const Timeout(Duration(minutes: 10)));
}
