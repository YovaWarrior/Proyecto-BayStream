import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/pages/discharge_sequence_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// T-106 · «re‑estiba» lleva un guion que no parte línea (U+2011) en la
/// pantalla de T-95. Datos sintéticos de T-95; las tapas son PROVISIONALES.
ContainerUnit _c(String id, String position, {String? pod = 'PAMIT'}) =>
    ContainerUnit(
      id: 'id-$id',
      containerId: id,
      stowagePosition: IsoCoordinateParser.parse(position),
      isoSizeType: '22G1',
      status: ContainerStatus.full,
      portOfLoading: 'HNPCR',
      portOfDischarge: pod,
      operatorCode: 'LNA',
      vgmWeight: 20000,
    );

final _voyage = () {
  final units = [
    _c('TSTU0000951', '0010282', pod: 'GTSTC'),
    _c('TSTU0000952', '0010284'),
    _c('TSTU0000953', '0010482'),
    _c('TSTU0000954', '0010402', pod: 'GTSTC'),
    _c('TSTU0000955', '0050202', pod: 'GTSTC'),
  ];
  return VesselVoyage(
    id: 'v',
    vessel: const Vessel(id: 'b', name: 'BUQUE T106', imoNumber: '9000106'),
    voyageNumber: 'T106',
    containers: units,
    bays: {
      for (final bay in units.map((u) => u.stowagePosition!.bay).toSet())
        bay: Bay(
            bayNumber: bay,
            containers:
                units.where((u) => u.stowagePosition!.bay == bay).toList()),
    },
  ).withGeometry(
      const VesselGeometry(
          portRows: 4,
          starboardRows: 3,
          holdTiers: [2, 4, 6],
          deckTiers: [82, 84, 86],
          centerRowOnDeck: true,
          centerRowInHold: true),
      portOfCall: 'GTSTC');
}();

final _covers = {
  1: HatchCoverDeclaration(kind: HatchCoverKind.crane, covers: [
    {4}
  ]),
};

/// La letra del Honor a font_scale=2.0, como la midió T-104 (la misma que usa
/// la prueba de T-95).
class _HonorLargeText extends TextScaler {
  const _HonorLargeText();
  static const _samples = <int, double>{
    8: 16, 10: 20, 11: 22, 12: 24, 14: 26, 16: 28, 18: 30, 20: 34, 22: 35,
    24: 36, 28: 37.333, 32: 39.771, 36: 43.314, 40: 46.857, 48: 53.943,
    56: 61.029, 64: 68.114, 72: 75.200, 96: 96.457, 100: 100,
  };
  @override
  double scale(double fontSize) {
    var previousSize = 0.0;
    var previousScaled = 0.0;
    for (final sample in _samples.entries) {
      if (fontSize <= sample.key) {
        return previousScaled +
            (sample.value - previousScaled) *
                (fontSize - previousSize) /
                (sample.key - previousSize);
      }
      previousSize = sample.key.toDouble();
      previousScaled = sample.value;
    }
    return fontSize;
  }

  @override
  double get textScaleFactor => 2;
}

final _word = RegExp('[Rr]e‑estibas?');

/// Cada «re‑estiba» que se ve queda en una sola línea, y ningún texto usa el
/// guion que parte. Devuelve cuántas se revisaron.
int _unbroken(WidgetTester tester, {String? reason}) {
  var seen = 0;
  for (final paragraph
      in tester.renderObjectList<RenderParagraph>(find.byType(RichText))) {
    final text = paragraph.text.toPlainText();
    expect(text, isNot(contains(RegExp('[Rr]e-estiba'))), reason: text);
    for (final match in _word.allMatches(text)) {
      seen++;
      final lines = paragraph
          .getBoxesForSelection(
              TextSelection(baseOffset: match.start, extentOffset: match.end))
          .map((box) => box.top.round())
          .toSet();
      expect(lines, hasLength(1), reason: '$reason · $text');
    }
  }
  return seen;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final font = FontLoader('Roboto')
      ..addFont(rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    await font.load();
  });

  testWidgets('T-106 «re‑estibas» no se parte a 360 dp con la letra del Honor',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
        theme: ThemeData(fontFamily: 'Roboto'),
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const _HonorLargeText()),
            child: child!),
        home: DischargeSequencePage(voyage: _voyage, hatchCovers: _covers)));
    await tester.pumpAndSettle();
    // De 360 dp hacia arriba el corte de línea cae en otro lugar a cada
    // ancho: si el guion partiera, alguno lo dejaría en el borde.
    for (var width = 360.0; width <= 420; width += 2) {
      tester.view.physicalSize = Size(width, 800);
      await tester.pumpAndSettle();
      expect(_unbroken(tester, reason: '${width.round()} dp'), greaterThan(0));
    }
    tester.view.physicalSize = const Size(360, 800);
    await tester.pumpAndSettle();
    final back = find.byKey(const ValueKey('discharge-step-001-8'));
    await tester.dragUntilVisible(back,
        find.byKey(const ValueKey('discharge-list')), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(
        find.descendant(of: back, matching: find.text('Re‑estiba: vuelve')),
        findsOneWidget);
    expect(_unbroken(tester, reason: 'paso 8'), greaterThan(0));
    expect(tester.takeException(), isNull);
  });
}
