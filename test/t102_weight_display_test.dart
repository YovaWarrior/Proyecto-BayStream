import 'package:baystream/core/design/design.dart';
import 'dart:io';

import 'package:baystream/features/vessel/data/services/pdf_report_service.dart';
import 'package:baystream/features/vessel/presentation/widgets/bay_plan_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../tool/t102_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pump(WidgetTester tester,
      {bool complete = false, double scale = 1}) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final font = FontLoader('Roboto')
      ..addFont(rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    await font.load();
    await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
            theme: ThemeData(fontFamily: 'Roboto'),
            home: MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                child: Scaffold(
                    body: BayPlanView(
                        voyage: t102Voyage(complete: complete)))))));
    await tester.pumpAndSettle();
  }

  String label(WidgetTester tester, String zone, int row) =>
      tester.widget<Text>(find.byKey(ValueKey('peso-pila-$zone-$row'))).data!;

  testWidgets('T-102 pila mixta suma VGM y marca el peso faltante',
      (tester) async {
    await pump(tester);
    expect(label(tester, 'cub.', 2), '28.7+?');
    expect(label(tester, 'bod.', 1), '30.0');
    expect(tester.takeException(), isNull);
  });
  testWidgets('T-102 pila completa conserva un decimal y no lleva marca',
      (tester) async {
    await pump(tester, complete: true);
    expect(label(tester, 'cub.', 2), '29.7');
    expect(find.textContaining('+?'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('T-102 pila sin ningun peso muestra 0.0+?', (tester) async {
    await pump(tester);
    expect(label(tester, 'bod.', 0), '0.0+?');
  });
  testWidgets(
      'T-102 reserva sin peso y peso cero no vuelven incompleta la pila',
      (tester) async {
    await pump(tester);
    expect(t102Voyage().totalReservedSlots, 1);
    expect(label(tester, 'cub.', 1), '21.0');
    expect(label(tester, 'bod.', 2), '0.0');
  });
  testWidgets('T-102 el faltante solo marca su zona, sin contaminar otra fila',
      (tester) async {
    await pump(tester);
    expect(label(tester, 'cub.', 0), '0.0');
    expect(label(tester, 'bod.', 2), '0.0');
    expect(find.textContaining('+?'), findsNWidgets(2));
  });
  testWidgets('T-102 cabeceras y celdas caben a 360 dp con letra grande',
      (tester) async {
    await pump(tester, scale: 1.3);
    expect(label(tester, 'cub.', 2), '28.7+?');
    // Fase 3: el peso es la segunda línea de BsCelda.
    expect(
        tester
            .widgetList<BsCelda>(find.byType(BsCelda))
            .where((c) => c.linea2 != null),
        hasLength(4));
    expect(tester.takeException(), isNull);
  });
  test('T-102 PDF sintetico con VGM, bruto, ambos, cero y faltantes', () async {
    final voyage = t102Voyage();
    expect(voyage.totalWeight, 79700);
    final bytes = await const PdfReportService()
        .generate(voyage, geometry: voyage.geometry!);
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    final directory = await Directory.systemTemp.createTemp('t102-synthetic-');
    await File('${directory.path}/sintetico.pdf').writeAsBytes(bytes);
    // Se verifica con tool/t102_verify_pdf.py; ninguna salida entra al repo.
    stdout.writeln('PDF sintético: ${directory.path}/sintetico.pdf');
  });
}
