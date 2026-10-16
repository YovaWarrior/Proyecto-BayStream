import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/pages/departure_baplie_page.dart';
import 'package:baystream/features/vessel/presentation/pages/voyage_comparison_page.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_operation_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/local_profile_test_support.dart';
import 'support/t82_fixture.dart';
import 'support/t89_file_picker.dart';
import 'support/t91_toolbar_support.dart';

// Fixtures sintéticos; ningún archivo del corpus.
const _header = "UNH+1+BAPLIE:D:95B:UN:SMDG22'"
    "TDT+20+T96+++TST:172:20+++9000096:146:11:BUQUE T96'"
    "LOC+5+HNPCR:139:6'LOC+61+GTSTC:139:6'";
const _arrival = '$_header'
    "LOC+147+0020310::5'LOC+9+HNPCR:139:6'LOC+11+PAMIT:139:6'"
    "MEA+AAE+WT+KGM:24300'MEA+AAE+VGM+KGM:24260'"
    "EQD+CN+TSTU0000961+45G1+++5'NAD+CA+LNA:172:20'"
    "LOC+147+0030182::5'LOC+9+HNPCR:139:6'LOC+11+GTSTC:139:6'"
    "MEA+AAE+VGM+KGM:20000'EQD+CN+TSTU0000962+22G1+++5'NAD+CA+LNA:172:20'";
const _plan = '$_header'
    "LOC+147+0020310::5'LOC+9+GTSTC:139:6'LOC+11+PAMIT:139:6'"
    "MEA+AAE+VGM+KGM:24200'EQD+CN+TSTU0000961+45G1+++5'NAD+CA+LNA:172:20'"
    "LOC+147+0050182::5'LOC+9+GTSTC:139:6'LOC+11+PAMIT:139:6'"
    "MEA+AAE+VGM+KGM:18000'EQD+CN+TSTU0000963+22G1+++5'NAD+CA+LNA:172:20'"
    "LOC+147+0070182::5'MEA+WT++KGM:2100'LOC+9+GTSTC:139:6'"
    "LOC+11+PAMIT:139:6'EQD+CN++22G1+++4'NAD+CA+LNA:172:20'";

final _first = BaplieParserService().parse(_arrival);
final _second = BaplieParserService().parse(_plan);

/// La escala que T-104 midió en el Honor a font_scale=2.0, interpolada.
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

Widget _page(Brightness brightness, {bool large = false}) => MaterialApp(
    theme: ThemeData(brightness: brightness, fontFamily: 'Roboto'),
    builder: (context, child) => large
        ? MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const _HonorLargeText()),
            child: child!)
        : child!,
    home: VoyageComparisonPage(
        first: _first,
        second: _second,
        firstLabel: 'Viaje abierto',
        secondLabel: 'plan.edi'));

String _text(WidgetTester tester, String key) =>
    tester.widget<Text>(find.byKey(ValueKey(key))).data!;

/// El texto se dibuja entero: sin líneas de más ni glifos fuera de su caja.
void _whole(WidgetTester tester, Finder finder) {
  final paragraph = tester.renderObject<RenderParagraph>(finder);
  expect(paragraph.didExceedMaxLines, isFalse);
  final data = tester.widget<Text>(finder).data!;
  final boxes = paragraph.getBoxesForSelection(
      TextSelection(baseOffset: 0, extentOffset: data.length));
  for (final box in boxes) {
    expect(box.right, lessThanOrEqualTo(paragraph.size.width + 1),
        reason: data);
    expect(box.bottom, lessThanOrEqualTo(paragraph.size.height + 1),
        reason: data);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final font = FontLoader('Roboto')
      ..addFont(rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    await font.load();
  });

  testWidgets('T-96 cuentas, resumen por campo, reservas y «antes → después»',
      (tester) async {
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_page(Brightness.light));
    await tester.pumpAndSettle();
    expect(_text(tester, 'comparison-counts'),
        '1 descargado · 1 cargado · 1 permanente, 1 con cambios');
    expect(_text(tester, 'comparison-reserved'),
        'Reservas sin número: 0 en el primero · 1 en el segundo');
    expect(_text(tester, 'comparison-fields'),
        'Cambios en los permanentes: POL 1 · Peso 1');
    expect(find.byKey(const ValueKey('comparison-vessel-notice')),
        findsNothing);
    expect(_text(tester, 'comparison-change-TSTU0000961-weight'),
        'Peso 24\u00A0260 → 24\u00A0200\u00A0kg');
    expect(_text(tester, 'comparison-change-TSTU0000961-portOfLoading'),
        'POL HNPCR → GTSTC');
    expect(find.text('Primero: WT 24\u00A0300 · VGM 24\u00A0260\u00A0kg'),
        findsOneWidget);
    // Las secciones llevan ícono y rótulo, no solo color.
    for (final (key, icon, label) in [
      ('discharged', Icons.south, 'Descargados (1)'),
      ('loaded', Icons.north, 'Cargados (1)'),
      ('permanent', Icons.sync_alt, 'Permanentes (1)'),
    ]) {
      final tab = find.byKey(ValueKey('comparison-tab-$key'));
      expect(find.descendant(of: tab, matching: find.byIcon(icon)),
          findsOneWidget);
      expect(find.descendant(of: tab, matching: find.text(label)),
          findsOneWidget);
    }
    await tester.tap(find.byKey(const ValueKey('comparison-tab-discharged')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('comparison-row-TSTU0000962')),
        findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('comparison-tab-loaded')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('comparison-row-TSTU0000963')),
        findsOneWidget);
  });

  testWidgets('T-96 «Solo con cambios» oculta y muestra los que no cambian',
      (tester) async {
    final same = BaplieParserService().parse(_arrival);
    await tester.pumpWidget(MaterialApp(
        home: VoyageComparisonPage(
            first: _first,
            second: same,
            firstLabel: 'uno',
            secondLabel: 'otro')));
    await tester.pumpAndSettle();
    expect(_text(tester, 'comparison-fields'),
        'Ningún campo cambia en los permanentes.');
    expect(find.text('Ningún permanente con cambios.'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('comparison-only-changed')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('comparison-row-TSTU0000961')),
        findsOneWidget);
    expect(find.text('Sin cambios.'), findsNWidgets(2));
  });

  testWidgets('T-96 distinto buque y la 1.5: los dos avisos arriba',
      (tester) async {
    final other = BaplieParserService()
        .parse(_plan.replaceFirst('9000096', '9000097'));
    final old = _first.copyWith(
        metadata: const BaplieMetadata(messageVersion: '1'));
    expect(old.metadata!.readWithV2Rules, isTrue);
    await tester.pumpWidget(MaterialApp(
        home: VoyageComparisonPage(
            first: old, second: other, firstLabel: 'A06', secondLabel: 'B')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('comparison-vessel-notice')),
        findsOneWidget);
    expect(find.textContaining('No parece el mismo buque'), findsOneWidget);
    expect(find.textContaining('A06: Versión 1.5'), findsOneWidget);
  });

  testWidgets('T-96 indicativo contra IMO, el mismo nombre: el aviso pide confirmar',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // 10.61: como A05 → A06, un archivo por indicativo y otro por IMO.
    final byCallSign = BaplieParserService()
        .parse(_plan.replaceFirst('9000096:146:11', 'ZZC5603:103:ZZZ'));
    expect(byCallSign.vessel.profileKey, 'callSign:ZZC5603');
    await tester.pumpWidget(MaterialApp(
        home: VoyageComparisonPage(
            first: byCallSign,
            second: _first,
            firstLabel: 'A05',
            secondLabel: 'A06')));
    await tester.pumpAndSettle();
    final notice = find.byKey(const ValueKey('comparison-vessel-notice'));
    expect(notice, findsOneWidget);
    expect(
        find.descendant(
            of: notice,
            matching: find.textContaining(
                'No se puede confirmar que sea el mismo buque: BUQUE T96 se '
                'identifica por indicativo ZZC5603 y BUQUE T96, por IMO 9000096.')),
        findsOneWidget);
    expect(find.textContaining('No parece el mismo buque'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final brightness in Brightness.values) {
    testWidgets('T-96 legible a 360 dp con la letra del Honor, ${brightness.name}',
        (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_page(brightness, large: true));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      for (final key in ['comparison-counts', 'comparison-fields']) {
        _whole(tester, find.byKey(ValueKey(key)));
      }
      // Las pestañas se desplazan y cada rótulo se lee entero.
      for (final label in ['Descargados (1)', 'Cargados (1)', 'Permanentes (1)']) {
        final text = find.text(label);
        await tester.ensureVisible(text);
        await tester.pumpAndSettle();
        _whole(tester, text);
        final tab = find.ancestor(of: text, matching: find.byType(Tab));
        expect(tester.getRect(text).bottom,
            lessThanOrEqualTo(tester.getRect(tab).bottom + 1));
      }
      final change = find.byKey(
          const ValueKey('comparison-change-TSTU0000961-weight'));
      await tester.dragUntilVisible(
          change, find.byType(NestedScrollView), const Offset(0, -200));
      await tester.pumpAndSettle();
      _whole(tester, change);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
      'T-96 «Comparar con otro BAPLIE…»: no publica, no guarda ni toca Recientes',
      (tester) async {
    final picker = T89FilePicker()
      ..result = FilePickerResult([
        PlatformFile(
            name: 'plan.edi',
            size: _plan.length,
            bytes: Uint8List.fromList(_plan.codeUnits)),
      ]);
    FilePicker.platform = picker;
    // El almacén solo sabe guardar preferencias de la barra: cualquier
    // guardado de viaje o perfil lanzaría NoSuchMethodError.
    final open = _first.withGeometry(
        const VesselGeometry(
            portRows: 1,
            starboardRows: 1,
            holdTiers: [10],
            deckTiers: [82]),
        portOfCall: 'GTSTC');
    final scope =
        await pumpT91Plan(tester, open, T91MemorySettings(), Brightness.light);
    await tester.tap(find.text('Lista'));
    await tester.pumpAndSettle();
    final before = scope.read(voyageNotifierProvider).value;
    final button = find.byKey(const ValueKey('compare-baplie'));
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(picker.requestedData, isTrue);
    expect(_text(tester, 'comparison-counts'),
        '1 descargado · 1 cargado · 1 permanente, 1 con cambios');
    expect(find.text('(plan.edi)'), findsOneWidget);
    expect(identical(scope.read(voyageNotifierProvider).value, before), isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('T-96 «Comparar con otro BAPLIE…» con un archivo que no es BAPLIE',
      (tester) async {
    final picker = T89FilePicker()
      ..result = FilePickerResult([
        PlatformFile(
            name: 'notas.txt',
            size: 5,
            bytes: Uint8List.fromList('hola\n'.codeUnits)),
      ]);
    FilePicker.platform = picker;
    final open = _first.withGeometry(
        const VesselGeometry(
            portRows: 1,
            starboardRows: 1,
            holdTiers: [10],
            deckTiers: [82]),
        portOfCall: 'GTSTC');
    await pumpT91Plan(tester, open, T91MemorySettings(), Brightness.light);
    await tester.tap(find.text('Lista'));
    await tester.pumpAndSettle();
    final button = find.byKey(const ValueKey('compare-baplie'));
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.byType(VoyageComparisonPage), findsNothing);
    expect(find.textContaining('Archivo «notas.txt»'), findsOneWidget);
  });

  testWidgets('T-96 «Comparar con la llegada» desde la salida de T-82',
      (tester) async {
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final scope = ProviderContainer(overrides: [
      operatorProvider.overrideWith((ref) => Stream.value(null)),
      activeOperationProvider.overrideWith((ref) async => t82Operation),
      loadingOperationProvider(t82Loading)
          .overrideWith((ref) => Stream.value(t82Derive(t82Loads))),
      vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
    ]);
    addTearDown(scope.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: scope,
        child: MaterialApp(home: DepartureBapliePage(voyage: t82Loading))));
    await tester.pumpAndSettle();
    final button = find.byKey(const ValueKey('departure-compare-arrival'));
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    // Llega 0010282 de paso y 0030984 que baja; sale con lo cargado y el
    // vacío asignado en la celda reservada.
    expect(_text(tester, 'comparison-counts'),
        '1 descargado · 2 cargados · 1 permanente, 0 con cambios');
    expect(find.text('(Llegada: llegada.edi)'), findsOneWidget);
    expect(find.text('(Salida generada, sin guardar)'), findsOneWidget);
  });

  testWidgets('T-96 sin plano de llegada no se ofrece comparar',
      (tester) async {
    await tester.pumpWidget(ProviderScope(overrides: [
      operatorProvider.overrideWith((ref) => Stream.value(null)),
      activeOperationProvider.overrideWith((ref) async => t82Operation
          .copyWith(
              sources: t82Operation.sources
                  .where((s) => s.kind != OperationSourceKind.arrivalBaplie)
                  .toList())),
      loadingOperationProvider(t82Loading)
          .overrideWith((ref) => Stream.value(t82Derive(t82Loads))),
    ], child: MaterialApp(home: DepartureBapliePage(voyage: t82Loading))));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('departure-compare-arrival')),
        findsNothing);
    expect(find.byKey(const ValueKey('departure-compare-unavailable')),
        findsOneWidget);
  });
}
