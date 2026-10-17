import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/pages/discharge_sequence_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t91_toolbar_support.dart';

/// T-95 · Datos sintéticos. Las tapas son PROVISIONALES (T-83).
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

const _geometry = VesselGeometry(
    portRows: 4,
    starboardRows: 3,
    holdTiers: [2, 4, 6],
    deckTiers: [82, 84, 86],
    centerRowOnDeck: true,
    centerRowInHold: true);

VesselVoyage _build({bool geometry = true}) {
  final units = [
    _c('TSTU0000951', '0010282', pod: 'GTSTC'),
    _c('TSTU0000952', '0010284'),
    _c('TSTU0000953', '0010482'),
    _c('TSTU0000954', '0010402', pod: 'GTSTC'),
    _c('TSTU0000955', '0050202', pod: 'GTSTC'),
    _c('TSTU0000956', '0090282', pod: 'JMKIN'),
  ];
  final voyage = VesselVoyage(
    id: 'v',
    vessel: const Vessel(id: 'b', name: 'BUQUE T95', imoNumber: '9000095'),
    voyageNumber: 'T95',
    containers: units,
    bays: {
      for (final bay in units.map((u) => u.stowagePosition!.bay).toSet())
        bay: Bay(
            bayNumber: bay,
            containers:
                units.where((u) => u.stowagePosition!.bay == bay).toList()),
    },
  );
  return geometry
      ? voyage.withGeometry(_geometry, portOfCall: 'GTSTC')
      : voyage.copyWith(portOfCall: 'GTSTC');
}

final _voyage = _build();

final _covers = {
  1: HatchCoverDeclaration(kind: HatchCoverKind.crane, covers: [
    {4}
  ]),
};

/// La escala que T-104 midió en el Honor a font_scale=2.0, interpolada (T-96).
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

Widget _page(Brightness brightness, {bool large = false, VesselVoyage? voyage}) =>
    MaterialApp(
        theme: ThemeData(brightness: brightness, fontFamily: 'Roboto'),
        builder: (context, child) => large
            ? MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const _HonorLargeText()),
                child: child!)
            : child!,
        home: DischargeSequencePage(
            voyage: voyage ?? _voyage, hatchCovers: _covers));

String _text(WidgetTester tester, String key) =>
    tester.widget<Text>(find.byKey(ValueKey(key))).data!;

/// El texto se dibuja entero: sin líneas de más ni glifos fuera de su caja.
/// Se mide carácter por carácter: el espacio donde se parte una línea no es un
/// glifo y su caja puede pasar del borde sin que se corte nada.
void _whole(WidgetTester tester, Finder finder) {
  final paragraph = tester.renderObject<RenderParagraph>(finder);
  expect(paragraph.didExceedMaxLines, isFalse);
  final data = tester.widget<Text>(finder).data!;
  for (var i = 0; i < data.length; i++) {
    if (data[i].trim().isEmpty) continue;
    for (final box in paragraph.getBoxesForSelection(
        TextSelection(baseOffset: i, extentOffset: i + 1))) {
      expect(box.right, lessThanOrEqualTo(paragraph.size.width + 1),
          reason: '$data · «${data[i]}» en $i');
      expect(box.bottom, lessThanOrEqualTo(paragraph.size.height + 1),
          reason: data);
    }
  }
}

String _stepText(WidgetTester tester, String cell, int number) => [
      for (final t in tester.widgetList<Text>(find.descendant(
          of: find.byKey(ValueKey('discharge-step-$cell-$number')),
          matching: find.byType(Text))))
        t.data,
    ].join(' | ');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final font = FontLoader('Roboto')
      ..addFont(rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    await font.load();
  });

  testWidgets('T-95 el resumen, las celdas en orden y sus pasos rotulados',
      (tester) async {
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_page(Brightness.light));
    await tester.pumpAndSettle();
    expect(_text(tester, 'discharge-summary'),
        '3 descargas · 2 re‑estibas (1 por columna, 1 por tapa) · '
        '1 tapa de grúa · 7 movimientos a bordo, 9 por muelle');
    expect(_text(tester, 'discharge-zones'),
        '1 en cubierta · 2 en bodega · 2 celdas, de más a menos movimientos por muelle');
    // La celda de la 001 tiene más movimientos que la de la 005.
    final first = tester.getTopLeft(find.byKey(const ValueKey('discharge-cell-001')));
    final second = tester.getTopLeft(find.byKey(const ValueKey('discharge-cell-005')));
    expect(first.dy, lessThan(second.dy));
    expect(_stepText(tester, '001', 1),
        '1. | Re‑estiba: sale | 001-02-84 · TSTU0000952 · por columna');
    expect(_stepText(tester, '001', 2), '2. | Descarga | 001-02-82 · TSTU0000951');
    expect(_stepText(tester, '001', 3),
        '3. | Re‑estiba: sale | 001-04-82 · TSTU0000953 · por tapa');
    expect(_stepText(tester, '001', 4), '4. | Tapa T1: quitar | Bahía 001 · filas 04');
    expect(_stepText(tester, '001', 5), '5. | Descarga | 001-04-02 · TSTU0000954');
    expect(_stepText(tester, '001', 6), '6. | Tapa T1: reponer | Bahía 001 · filas 04');
    expect(_stepText(tester, '001', 7),
        '7. | Re‑estiba: vuelve | 001-04-82 · TSTU0000953 · por tapa');
    expect(_stepText(tester, '001', 8),
        '8. | Re‑estiba: vuelve | 001-02-84 · TSTU0000952 · por columna');
    final warning =
        find.byKey(const ValueKey('discharge-warning-hold-without-cover'));
    expect(warning, findsOneWidget, reason: 'la 005 no tiene tapa declarada');
    expect(
        find.descendant(of: warning, matching: find.textContaining('005-02-02')),
        findsOneWidget);
  });

  testWidgets('T-95 cambiar de puerto recalcula', (tester) async {
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_page(Brightness.light));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('discharge-port')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('JMKIN').last);
    await tester.pumpAndSettle();
    expect(_text(tester, 'discharge-summary'),
        '1 descarga · 0 re‑estibas (0 por columna, 0 por tapa) · '
        '0 tapas de grúa · 1 movimiento a bordo, 1 por muelle');
    expect(find.byKey(const ValueKey('discharge-cell-009')), findsOneWidget);
    expect(find.byKey(const ValueKey('discharge-cell-001')), findsNothing);
  });

  testWidgets('T-95 sin geometría lo dice, sin calcular', (tester) async {
    await tester.pumpWidget(_page(Brightness.light, voyage: _build(geometry: false)));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('discharge-unavailable')), findsOneWidget);
  });

  for (final brightness in Brightness.values) {
    testWidgets('T-95 legible a 360 dp con la letra del Honor, ${brightness.name}',
        (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_page(brightness, large: true));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      for (final key in ['discharge-summary', 'discharge-zones']) {
        _whole(tester, find.byKey(ValueKey(key)));
      }
      final step = find.byKey(const ValueKey('discharge-step-001-4'));
      await tester.dragUntilVisible(
          step, find.byKey(const ValueKey('discharge-list')), const Offset(0, -200));
      await tester.pumpAndSettle();
      for (final text in tester.widgetList<Text>(
          find.descendant(of: step, matching: find.byType(Text)))) {
        _whole(tester, find.text(text.data!).first);
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('T-95 la entrada en la fila de acciones del viaje abre la pantalla',
      (tester) async {
    await pumpT91Plan(tester, _voyage, T91MemorySettings(), Brightness.light);
    await tester.tap(find.text('Lista'));
    await tester.pumpAndSettle();
    final button = find.byKey(const ValueKey('open-discharge-sequence'));
    await tester.ensureVisible(button);
    // Junto a «Comparar con otro BAPLIE…», en la misma fila de acciones (10.61).
    final row = tester.widget<Wrap>(find
        .ancestor(of: button, matching: find.byType(Wrap))
        .first);
    final keys = [for (final w in row.children) w.key];
    expect(keys.indexOf(const ValueKey('open-discharge-sequence')),
        keys.indexOf(const ValueKey('compare-baplie')) + 1);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.byType(DischargeSequencePage), findsOneWidget);
    expect(_text(tester, 'discharge-summary'), startsWith('3 descargas · '));
  });
}
