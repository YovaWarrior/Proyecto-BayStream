import 'dart:io';

import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/widgets/voyage_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../tool/t98_support.dart';

VesselVoyage _voyage({bool reservations = false, bool single = false}) {
  const corpus = String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');
  final source = corpus.isNotEmpty && !single
      ? File('$corpus/CORPUS_${reservations ? 'A08' : 'A07'}.edi')
          .readAsStringSync()
      : t98Message().replaceFirst('KGM:24000', 'KGM:7419500') +
          (reservations
              ? "LOC+147+0050182::5'EQD+CN++22G1+++4'"
                  "${single ? '' : "LOC+147+0070182::5'EQD+CN++22G1+++4'"}"
              : '');
  final parsed = BaplieParserService().parse(source);
  return parsed.withGeometry(VesselProfile.proposeFrom(parsed).geometry);
}

Future<void> _pump(WidgetTester tester, VesselVoyage voyage,
    {double width = 360, double scale = 1}) async {
  tester.view.physicalSize = Size(width, 780);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(
    theme: ThemeData(useMaterial3: true, fontFamily: 'Roboto'),
    builder: (context, child) => MediaQuery(
      data:
          MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: VoyageSummaryCard(voyage: voyage),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

String _weight(VesselVoyage voyage) => voyage.totalWeight >= 1000
    ? '${(voyage.totalWeight / 1000).toStringAsFixed(1)} t'
    : '${voyage.totalWeight.toStringAsFixed(0)} kg';

// Se comprueban los glifos reales: una etiqueta y cada cifra con su unidad
// deben caber completos, sin elipsis, recorte ni reducción de la escala.
void _singleLine(WidgetTester tester, String text, double scale) {
  final finder = find.text(text);
  expect(finder, findsOneWidget);
  final paragraph = tester.renderObject<RenderParagraph>(finder);
  final boxes = paragraph.getBoxesForSelection(
      TextSelection(baseOffset: 0, extentOffset: text.length));
  expect(boxes, isNotEmpty);
  expect(boxes.map((box) => box.top).toSet(), hasLength(1), reason: text);
  for (final box in boxes) {
    expect(box.left, greaterThanOrEqualTo(-0.01), reason: text);
    expect(box.right, lessThanOrEqualTo(paragraph.constraints.maxWidth + 0.01),
        reason: text);
  }
  expect(paragraph.textScaler.scale(12), closeTo(12 * scale, 0.001));
  expect(paragraph.didExceedMaxLines, isFalse);
  expect(paragraph.overflow, isNot(TextOverflow.ellipsis));
  expect(find.ancestor(of: finder, matching: find.byType(FittedBox)),
      findsNothing);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final font = FontLoader('Roboto')
      ..addFont(rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    await font.load();
  });

  for (final scale in [1.0, 1.45, 2.0]) {
    for (final reservations in [false, true]) {
      testWidgets(
          'T111 360 dp letra $scale reservas $reservations: texto entero',
          (tester) async {
        final voyage = _voyage(reservations: reservations);
        await _pump(tester, voyage, scale: scale);
        for (final text in [
          'Contenedores',
          'Bahías',
          'Peso Total',
          _weight(voyage),
        ]) {
          _singleLine(tester, text, scale);
        }
        final first = tester.getTopLeft(find.text('Contenedores'));
        final second = tester.getTopLeft(find.text('Bahías'));
        if (scale > 1) expect(second.dy, greaterThan(first.dy));
        expect(tester.takeException(), isNull);
        if (reservations) {
          expect(voyage.totalReservedSlots, greaterThan(1));
          expect(
              find.textContaining(
                  '${voyage.totalReservedSlots} celdas reservadas'),
              findsOneWidget);
        }
      });
    }
  }

  for (final scale in [1.0, 1.45, 2.0]) {
    testWidgets('T111 1280 dp letra $scale: conserva la fila en tercios',
        (tester) async {
      final voyage = _voyage();
      await _pump(tester, voyage, width: 1280, scale: scale);
      final positions = ['Contenedores', 'Bahías', 'Peso Total']
          .map((label) => tester.getCenter(find.text(label)))
          .toList();
      expect(positions[0].dy, positions[1].dy);
      expect(positions[1].dy, positions[2].dy);
      expect(positions[1].dx - positions[0].dx,
          closeTo(positions[2].dx - positions[1].dx, 0.001));
      _singleLine(tester, _weight(voyage), scale);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('T111 mismo ancho: la letra decide si caben los indicadores',
      (tester) async {
    final voyage = _voyage();
    await _pump(tester, voyage, width: 400);
    expect(tester.getCenter(find.text('Contenedores')).dy,
        tester.getCenter(find.text('Bahías')).dy);
    await _pump(tester, voyage, width: 400, scale: 1.45);
    expect(tester.getCenter(find.text('Bahías')).dy,
        greaterThan(tester.getCenter(find.text('Contenedores')).dy));
    _singleLine(tester, _weight(voyage), 1.45);
    expect(tester.takeException(), isNull);
  });

  testWidgets('T111 una reserva usa el singular', (tester) async {
    final voyage = _voyage(reservations: true, single: true);
    expect(voyage.totalReservedSlots, 1);
    await _pump(tester, voyage);
    expect(find.textContaining('1 celda reservada'), findsOneWidget);
    expect(find.textContaining('1 celdas reservadas'), findsNothing);
  });

  testWidgets('T111 sin reservas no agrega un resumen de reservas',
      (tester) async {
    await _pump(tester, _voyage());
    expect(find.byKey(const ValueKey('voyage-reserved-count')), findsNothing);
  });

  testWidgets('T111 peso menor a una tonelada conserva numero y kg',
      (tester) async {
    final voyage = BaplieParserService()
        .parse(t98Message().replaceFirst('KGM:24000', 'KGM:999'));
    await _pump(tester, voyage, scale: 1.45);
    _singleLine(tester, '999 kg', 1.45);
    expect(tester.takeException(), isNull);
  });
}
