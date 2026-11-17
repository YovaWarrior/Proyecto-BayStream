import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/pages/hatch_covers_page.dart';
import 'package:baystream/features/vessel/presentation/pages/recent_voyages_page.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_overview_page.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/containers_list_view.dart';
import 'package:baystream/features/vessel/presentation/widgets/empty_state_widget.dart';
import 'package:baystream/features/vessel/presentation/widgets/voyage_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/t91_toolbar_support.dart';

// Fixture sintético de una sola bahía; no contiene archivos del corpus.
final _parsed = BaplieParserService().parse("UNH+1+BAPLIE:D:95B:UN:SMDG22'"
    "TDT+20+T104+++TST:172:20+++9000104:146:11:BUQUE PRUEBA'"
    "LOC+5+HNPCR:139:6'LOC+61+GTSTC:139:6'"
    "LOC+147+0010182::5'LOC+9+HNPCR:139:6'LOC+11+GTSTC:139:6'"
    "MEA+AAE+VGM+KGM:6940578'EQD+CN+TSTU0000104+22G1+++5'");
final _voyage = _parsed.withGeometry(
    VesselProfile.proposeFrom(_parsed).geometry,
    portOfCall: 'GTSTC');

// Medido con MediaQuery en el Honor a font_scale=2.0 el 15-oct.
// Evidencia: honor-escala-real-2.xml en TEMP. Incluye los tamaños Material
// usados en estas pantallas; se interpola entre los puntos medidos.
class _HonorLargeText extends TextScaler {
  const _HonorLargeText();
  static const _samples = <int, double>{
    8: 16,
    10: 20,
    11: 22,
    12: 24,
    14: 26,
    16: 28,
    18: 30,
    20: 34,
    22: 35,
    24: 36,
    28: 37.333,
    32: 39.771,
    36: 43.314,
    40: 46.857,
    48: 53.943,
    56: 61.029,
    64: 68.114,
    72: 75.200,
    96: 96.457,
    100: 100,
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

Widget _app(Widget home, Brightness brightness) => MaterialApp(
    theme: ThemeData(brightness: brightness, fontFamily: 'Roboto'),
    builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const _HonorLargeText()),
        child: child!),
    home: home);

void _size(WidgetTester tester) {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void _oneLine(WidgetTester tester, Finder finder) {
  expect(finder, findsOneWidget);
  final text = tester.widget<Text>(finder);
  final paragraph = tester.renderObject<RenderParagraph>(finder);
  expect(paragraph.didExceedMaxLines, isFalse);
  final boxes = paragraph.getBoxesForSelection(
      TextSelection(baseOffset: 0, extentOffset: text.data!.length));
  expect(boxes, hasLength(1),
      reason: '${text.data} no se parte en dos líneas.');
  // La selección de glifos redondea a píxeles; admite menos de un dp.
  expect(boxes.single.right, lessThanOrEqualTo(paragraph.size.width + 1));
  expect(boxes.single.bottom, lessThanOrEqualTo(paragraph.size.height + 1));
}

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
        'T-104 pestañas completas a 360 dp, Honor 2.0 ${brightness.name}',
        (tester) async {
      final scope =
          await pumpT91Plan(tester, _voyage, T91MemorySettings(), brightness);
      _size(tester);
      await tester.pumpWidget(UncontrolledProviderScope(
          container: scope,
          child: _app(const VesselOverviewPage(), brightness)));
      await tester.pumpAndSettle();
      // Fase 3 (DESIGN.md 8): la barra inferior en vez de las pestañas. Sus
      // rótulos crecen con la letra hasta 1.3 y se leen enteros en 360 dp.
      final barra = find.byType(NavigationBar);
      expect(barra, findsOneWidget);
      final rotulos =
          find.descendant(of: barra, matching: find.byType(Text));
      expect(rotulos, findsAtLeastNWidgets(4));
      for (final element in rotulos.evaluate()) {
        final text = find.byWidget(element.widget);
        _oneLine(tester, text);
        expect(tester.getRect(text).bottom,
            lessThanOrEqualTo(tester.getRect(barra).bottom));
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets(
        'T-104 Lista no parte contadores ni peso, Honor 2.0 ${brightness.name}',
        (tester) async {
      _size(tester);
      await tester.pumpWidget(_app(
          Scaffold(
              body: SingleChildScrollView(
                  child: VoyageSummaryCard(voyage: _voyage))),
          brightness));
      await tester.pumpAndSettle();
      for (final label in [
        'Contenedores',
        'Bahías',
        '6940.6 t',
        'Peso total'
      ]) {
        final text = find.text(label);
        await tester.ensureVisible(text);
        await tester.pumpAndSettle();
        _oneLine(tester, text);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'T-104 tarjeta con etiquetas completas, Honor 2.0 ${brightness.name}',
        (tester) async {
      _size(tester);
      await tester.pumpWidget(_app(
          Scaffold(
              body: SingleChildScrollView(
                  child: Padding(
                      padding: const EdgeInsets.all(16),
                      child:
                          ContainersListView(containers: _voyage.containers)))),
          brightness));
      await tester.pumpAndSettle();
      for (final label in ['Posición', 'Destino', 'Peso (VGM)', 'GTSTC']) {
        final text = find.text(label);
        await tester.ensureVisible(text);
        await tester.pumpAndSettle();
        _oneLine(tester, text);
      }
      final position =
          find.text(_voyage.containers.first.stowagePosition!.displayFormat);
      await tester.ensureVisible(position);
      await tester.pumpAndSettle();
      expect(tester.renderObject<RenderParagraph>(position).didExceedMaxLines,
          isFalse,
          reason: 'La posición también se puede leer completa.');
      expect(tester.takeException(), isNull);
    });

    testWidgets('T-104 Recientes dice 1 bahía, Honor 2.0 ${brightness.name}',
        (tester) async {
      _size(tester);
      await tester.pumpWidget(ProviderScope(overrides: [
        recentVoyagesProvider.overrideWith((ref) async => [_voyage]),
      ], child: _app(const RecentVoyagesPage(), brightness)));
      await tester.pumpAndSettle();
      expect(find.textContaining(' · 1 bahía'), findsOneWidget);
      expect(find.textContaining('1 bahías'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('T-104 copiar a una bahía, Honor 2.0 ${brightness.name}',
        (tester) async {
      _size(tester);
      await tester.pumpWidget(_app(
          HatchCoversPage(
              geometry: const VesselGeometry(
                  portRows: 1,
                  starboardRows: 1,
                  holdTiers: [2],
                  deckTiers: [82]),
              holdBays: {
                1,
                3
              },
              initial: {
                1: HatchCoverDeclaration(kind: HatchCoverKind.openHold)
              }),
          brightness));
      await tester.pumpAndSettle();
      final copy = find.byKey(const ValueKey('hatch-copy'));
      await tester.ensureVisible(copy);
      await tester.tap(copy);
      await tester.pumpAndSettle();
      final target = find.byKey(const ValueKey('hatch-target-3'));
      await tester.ensureVisible(target);
      await tester.tap(target);
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('hatch-copy-confirm')));
      await tester.pump();
      expect(find.text('Copiado a 1 bahía'), findsOneWidget);
      expect(find.textContaining('1 bahías'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });

    testWidgets(
        'T-104 inicio valida contenido sin extensiones ${brightness.name}',
        (tester) async {
      _size(tester);
      await tester.pumpWidget(_app(
          Scaffold(
              // Fase 3 (10.9): la cabecera del inicio vive dentro del
              // desplazable del inicio; aquí se le da uno.
              body: SingleChildScrollView(
                  child: EmptyStateWidget(onPickFile: () {})),
              floatingActionButton: FloatingActionButton.extended(
                  onPressed: () {},
                  icon: const Icon(Icons.file_open),
                  label: const Text('Cargar BAPLIE'))),
          brightness));
      expect(find.textContaining('Se valida por su contenido'), findsOneWidget);
      // T-56: desde T-103 la 1.5 también se lee, con aviso.
      expect(find.text('Contenido compatible: BAPLIE 2.x, y la 1.5 con aviso.'),
          findsOneWidget);
      expect(find.textContaining('.edi'), findsNothing);
      expect(find.textContaining('.txt'), findsNothing);
      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(0, -2000));
      await tester.pumpAndSettle();
      expect(
          tester
              .getRect(find
                  .text('Contenido compatible: BAPLIE 2.x, y la 1.5 con aviso.'))
              .bottom,
          lessThanOrEqualTo(
              tester.getRect(find.byType(FloatingActionButton)).top),
          reason: 'El botón flotante no tapa el texto inferior.');
      expect(tester.takeException(), isNull);
    });
  }
}
