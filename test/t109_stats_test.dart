import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:baystream/core/constants/privacy_policy.dart';
import 'package:baystream/core/utils/privacy_policy_html.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/voyage_stats_view.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../tool/t98_support.dart';

class _Voyage extends VoyageNotifier {
  final VesselVoyage voyage;
  _Voyage(this.voyage);
  @override
  AsyncValue<VesselVoyage?> build() => AsyncData(voyage);
}

VesselVoyage _fixture() {
  const corpus = String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');
  final source = corpus.isEmpty
      ? t98Message()
          .replaceFirst('22G1', '22R1')
          .replaceFirst('UNT+13+', "DGS+IMD+3+1993'NAD+CA+TEST:172:20'UNT+15+")
      : File('$corpus/CORPUS_A07.edi').readAsStringSync();
  final voyage = BaplieParserService().parse(source);
  return voyage.withGeometry(VesselProfile.proposeFrom(voyage).geometry);
}

Future<void> _pump(WidgetTester tester, VesselVoyage voyage,
    {required double width, double scale = 1, String? longLabel}) async {
  tester.view.physicalSize = Size(width, 780);
  tester.view.devicePixelRatio = 1;
  await tester.pumpWidget(ProviderScope(
    key: UniqueKey(),
    overrides: [
      voyageNotifierProvider.overrideWith(() => _Voyage(voyage)),
      if (longLabel != null)
        carrierDistributionProvider
            .overrideWithValue({longLabel: voyage.totalContainers}),
    ],
    child: MaterialApp(
      theme: ThemeData(useMaterial3: true),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: Scaffold(
          body: RepaintBoundary(
        key: const ValueKey('t109-boundary'),
        child: VoyageStatsView(voyage: voyage, onBaySelected: (_) {}),
      )),
    ),
  ));
  await tester.pumpAndSettle();
}

List<String> _texts(WidgetTester tester) => find
    .descendant(of: find.byType(VoyageStatsView), matching: find.byType(Text))
    .evaluate()
    .map((e) => (e.widget as Text).data ?? '')
    .where((text) => text.isNotEmpty)
    .toList()
  ..sort();

ScrollableState _scroll(WidgetTester tester) =>
    tester.state<ScrollableState>(find
        .descendant(
            of: find.byType(VoyageStatsView),
            matching: find.byWidgetPredicate((w) =>
                w is Scrollable && w.axisDirection == AxisDirection.down))
        .first);

// Solo para la referencia de 1280 dp: conserva, imprime y compara los
// desbordes previos de los gráficos; nunca se aplica a la vista de 360 dp.
Future<List<String>> _priorWideErrors(Future<void> Function() action) async {
  final prior = FlutterError.onError;
  final errors = <String>[];
  FlutterError.onError = (details) {
    final text = details.exceptionAsString().split('\n').first;
    final match =
        RegExp(r'^A RenderFlex overflowed by ([0-9.]+) pixels on the bottom\.')
            .firstMatch(text);
    if (details.library == 'rendering library' &&
        match != null &&
        double.parse(match[1]!) <= 8) {
      errors.add(text);
      debugPrint('T109 incidencia PREEXISTENTE a 1280 dp: $text');
    } else {
      prior?.call(details);
    }
  };
  try {
    await action();
    return errors;
  } finally {
    FlutterError.onError = prior;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const destination = String.fromEnvironment('T109_OUTPUT');
  const capture = bool.fromEnvironment('T109_CAPTURE_BASELINE');
  final output = destination.isEmpty ? null : t98Output(destination);
  final baselineFile =
      output == null ? null : File('${output.path}/wide-baseline.json');
  final reference = !capture && (baselineFile?.existsSync() ?? false)
      ? jsonDecode(baselineFile!.readAsStringSync()) as Map<String, dynamic>
      : <String, dynamic>{};
  final proofs = <String, Object?>{};

  for (final width in [1280.0]) {
    testWidgets('T109 $width dp conserva toda la vista ancha', (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final priorErrors =
          await _priorWideErrors(() => _pump(tester, _fixture(), width: width));
      expect(tester.takeException(), isNull);
      final scroll = _scroll(tester).position;
      final maximum = scroll.maxScrollExtent;
      final offsets = <double>[
        0,
        for (var n = 600.0; n < maximum; n += 600) n,
        if (maximum > 0) maximum
      ];
      final frames = <String>[];
      for (var index = 0; index < offsets.length; index++) {
        scroll.jumpTo(offsets[index]);
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          final boundary = tester.renderObject<RenderRepaintBoundary>(
              find.byKey(const ValueKey('t109-boundary')));
          final image = await boundary.toImage(pixelRatio: 1);
          final raw =
              await image.toByteData(format: ui.ImageByteFormat.rawRgba);
          frames.add(sha256.convert(raw!.buffer.asUint8List()).toString());
          if (capture && output != null) {
            final png = await image.toByteData(format: ui.ImageByteFormat.png);
            File('${output.path}/head-${width.toInt()}-$index.png')
                .writeAsBytesSync(png!.buffer.asUint8List());
          }
          image.dispose();
        });
        expect(tester.takeException(), isNull);
      }
      final key = width.toInt().toString();
      proofs[key] = {
        'extent': maximum,
        'framesRgbaSha256': frames,
        'priorErrors': priorErrors
      };
      if (!capture && reference.isNotEmpty) {
        expect(proofs[key], reference[key],
            reason:
                'Todos los píxeles y la extensión del recorrido ancho, contra HEAD');
      }
    });
  }

  for (final scale in [1.0, 1.45, 2.0]) {
    testWidgets('T109 360x780 dp letra $scale sin desbordes ni datos perdidos',
        (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final voyage = _fixture();
      await _priorWideErrors(() => _pump(tester, voyage, width: 1280));
      final originalTexts = _texts(tester);
      expect(tester.takeException(), isNull);
      await _pump(tester, voyage, width: 360, scale: scale);
      expect(tester.takeException(), isNull);
      expect(_texts(tester), originalTexts,
          reason: 'Mismos textos y cifras de la vista completa a 1280 dp');
      final scroll = _scroll(tester).position;
      for (var offset = 0.0; offset < scroll.maxScrollExtent; offset += 500) {
        scroll.jumpTo(offset);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      scroll.jumpTo(scroll.maxScrollExtent);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final numeric = find.byWidgetPredicate((widget) =>
          widget is Text &&
          RegExp(r'^\d+(\.\d+)?( t|t|%)?( \([\d.]+%\))?$')
              .hasMatch(widget.data ?? ''));
      for (final element in numeric.evaluate()) {
        expect((element.widget as Text).overflow, isNot(TextOverflow.ellipsis));
      }
    });
  }

  testWidgets('T109 etiqueta larga completa a un toque y en accesibilidad',
      (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final semantics = tester.ensureSemantics();
    try {
      const label = 'NAVIERA DE PRUEBA CON NOMBRE MUY LARGO';
      await _pump(tester, _fixture(), width: 360, scale: 2, longLabel: label);
      await tester.ensureVisible(find.text(label));
      await tester.pumpAndSettle();
      final node =
          tester.getSemantics(find.byKey(const ValueKey('stats-label-$label')));
      expect(node.label, contains(label));
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
          find.descendant(
              of: find.byType(AlertDialog), matching: find.text(label)),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });

  test('T109 política con U+2011 y HTML generado desde la fuente', () {
    final source =
        File('lib/core/constants/privacy_policy.dart').readAsStringSync();
    expect(source, contains('re\u2011estibas'));
    expect(source, isNot(contains('re-estibas')));
    final text =
        kPrivacyPolicySections.expand((section) => section.items).join();
    expect(text, contains('re\u2011estibas'));
    expect(
        File('web/privacidad.html').readAsStringSync().replaceAll('\r\n', '\n'),
        privacyPolicyHtml());
  });

  tearDownAll(() {
    if (capture && baselineFile != null) {
      if (baselineFile.existsSync()) {
        throw StateError('No sobrescribir referencia.');
      }
      baselineFile.writeAsStringSync(jsonEncode(proofs));
    } else if (output != null) {
      File('${output.path}/wide-final.json')
          .writeAsStringSync(jsonEncode(proofs));
    }
  });
}
