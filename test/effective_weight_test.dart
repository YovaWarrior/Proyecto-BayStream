import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/data/services/export_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/widgets/bay_plan_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// T-66 · El peso que se muestra y se suma es el VGM si viene y, si no, el
/// bruto. Antes todo leía solo `grossWeight`, y un archivo que trae el peso
/// como `MEA+VGM` (333 de 398 en CORPUS_A07) salía «N/A kg» y 0 t.
void main() {
  // Cuatro contenedores, uno por caso: solo VGM, solo WT, los dos, ninguno.
  const edi = '''
UNH+1+BAPLIE:D:95B:UN'
TDT+20+V066++++++:::BUQUE PESOS'
LOC+147+0050182:::5'
EQD+CN+SOLOVGM0001+22G1+++5'
MEA+AAE+VGM+KGM:28700'
LOC+147+0050184:::5'
EQD+CN+SOLOWT00002+22G1+++5'
MEA+AAE+WT+KGM:21000'
LOC+147+0050282:::5'
EQD+CN+LOSDOS00003+22G1+++5'
MEA+AAE+WT+KGM:25000'
MEA+AAE+VGM+KGM:25500'
LOC+147+0050284:::5'
EQD+CN+NINGUNO0004+22G1+++4'
UNT+14+1'
''';

  final voyage = BaplieParserService().parse(edi);
  ContainerUnit unit(String id) =>
      voyage.containers.singleWhere((c) => c.containerId == id);

  group('T-66 · peso efectivo del contenedor', () {
    test('solo VGM: el peso es el VGM y la fuente lo dice', () {
      final c = unit('SOLOVGM0001');
      expect(c.grossWeight, isNull);
      expect(c.effectiveWeight, 28700);
      expect(c.weightSource, WeightSource.vgm);
    });

    test('solo WT: el peso es el bruto, como antes', () {
      final c = unit('SOLOWT00002');
      expect(c.effectiveWeight, 21000);
      expect(c.weightSource, WeightSource.gross);
    });

    test('los dos: se prefiere el VGM y el bruto se conserva', () {
      final c = unit('LOSDOS00003');
      expect(c.effectiveWeight, 25500);
      expect(c.weightSource, WeightSource.vgm);
      expect(c.grossWeight, 25000, reason: 'el dato crudo no se pierde');
    });

    test('ninguno: sin peso efectivo ni fuente, no un cero', () {
      final c = unit('NINGUNO0004');
      expect(c.effectiveWeight, isNull);
      expect(c.weightSource, isNull);
      expect(c.netWeight, isNull);
    });

    test('el peso neto se calcula sobre el peso efectivo', () {
      const c = ContainerUnit(
          id: 'n', containerId: 'NETO', vgmWeight: 30000, tareWeight: 3800);
      expect(c.netWeight, 26200);
    });
  });

  group('T-66 · sumas del viaje y de la bahía', () {
    test('el total del viaje suma VGM y bruto; las sumas crudas no cambian',
        () {
      expect(voyage.totalWeight, 28700 + 21000 + 25500);
      expect(voyage.totalGrossWeight, 21000 + 25000);
      expect(voyage.totalVgmWeight, 28700 + 25500);
    });

    test('bahía, nivel y pila suman el peso efectivo', () {
      final bay = voyage
          .withGeometry(const VesselGeometry(
              portRows: 1,
              starboardRows: 1,
              holdTiers: [2],
              deckTiers: [82, 84]))
          .bays[5]!;
      expect(bay.totalWeight, 75200);
      expect(bay.weightByTier, {82: 28700 + 25500, 84: 21000});
      expect(bay.deckWeightByRow, {1: 28700 + 21000, 2: 25500});
    });

    test('la exportación conserva las tres columnas crudas', () {
      final filas = const ExportService().serializeCsv(voyage).split('\r\n');
      // posición, grossWeight, vgmWeight: el VGM no se copia al bruto.
      expect(filas.firstWhere((l) => l.contains('SOLOVGM0001')),
          contains('0050182",,28700.0,'));
      expect(filas.firstWhere((l) => l.contains('LOSDOS00003')),
          contains('0050282",25000.0,25500.0,'));
    });
  });

  group('T-66 · lo que se ve en pantalla', () {
    const geometry = VesselGeometry(
        portRows: 1, starboardRows: 1, holdTiers: [2], deckTiers: [82, 84]);

    Future<void> pump(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(ProviderScope(
          child: MaterialApp(
              home: Scaffold(
                  body: BayPlanView(voyage: voyage.withGeometry(geometry))))));
      await tester.pumpAndSettle();
    }

    String? cellWeight(WidgetTester tester, String cellKey) {
      final finder = find.descendant(
          of: find.byKey(ValueKey(cellKey)),
          matching: find.byKey(const ValueKey('peso-celda')));
      if (finder.evaluate().isEmpty) return null;
      return tester.widget<Text>(finder).data;
    }

    testWidgets('la celda muestra el peso en toneladas con un decimal',
        (tester) async {
      await pump(tester);
      expect(cellWeight(tester, 'cell-1-82'), '28.7', reason: 'solo VGM');
      expect(cellWeight(tester, 'cell-1-84'), '21.0', reason: 'solo WT');
      expect(cellWeight(tester, 'cell-2-82'), '25.5', reason: 'los dos');
      expect(cellWeight(tester, 'cell-2-84'), isNull,
          reason: 'sin peso no se inventa un 0.0');
      expect(tester.takeException(), isNull, reason: 'nada se desborda');
    });

    testWidgets('el detalle dice de dónde viene el peso', (tester) async {
      await pump(tester);
      await tester.tap(find.byKey(const ValueKey('cell-1-82')));
      await tester.pumpAndSettle();
      expect(find.text('Peso (VGM)'), findsOneWidget);
      expect(find.text('28700 kg'), findsOneWidget);
      expect(find.text('Peso bruto'), findsNothing);
      expect(find.textContaining('N/A kg'), findsNothing);
    });

    testWidgets('con los dos pesos, el detalle muestra los dos',
        (tester) async {
      await pump(tester);
      await tester.tap(find.byKey(const ValueKey('cell-2-82')));
      await tester.pumpAndSettle();
      expect(find.text('Peso (VGM)'), findsOneWidget);
      expect(find.text('25500 kg'), findsOneWidget);
      expect(find.text('Peso bruto'), findsOneWidget);
      expect(find.text('25000 kg'), findsOneWidget);
    });

    testWidgets('sin peso, el detalle lo declara en vez de «N/A kg»',
        (tester) async {
      await pump(tester);
      await tester.tap(find.byKey(const ValueKey('cell-2-84')));
      await tester.pumpAndSettle();
      expect(find.text('El archivo no trae peso'), findsOneWidget);
      expect(find.textContaining('N/A kg'), findsNothing);
    });
  });
}
