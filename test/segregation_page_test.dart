import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/domain/entities/stowage_validation_result.dart';
import 'package:baystream/features/vessel/presentation/pages/segregation_page.dart';
import 'package:baystream/features/vessel/presentation/providers/segregation_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('T-41 sin pares no declara conforme el viaje', (tester) async {
    await tester.pumpWidget(ProviderScope(overrides: [
      segregationResultsProvider.overrideWithValue([]),
    ], child: const MaterialApp(home: SegregationPage())));
    expect(find.textContaining('Esto no declara el viaje conforme'),
        findsOneWidget);
    expect(find.textContaining('No es el Código IMDG'), findsOneWidget);
    expect(find.text('Conforme en las reglas evaluadas'), findsNothing);
  });

  for (final status in ValidationStatus.values) {
    testWidgets(
        'T-41 ${status.name}: motivo, posición y fuente a ancho de teléfono',
        (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final result = StowageValidationResult(
          rule: StowageRule.dangerousGoodsSegregation,
          status: status,
          severity: ValidationSeverity.warning,
          description: 'UN3084 / UN1993. Motivo explícito del resultado.',
          positions: [IsoCoordinateParser.parse('0140784')],
          containerIds: ['TEST0000001'],
          references: ['49 CFR §176.83(a)(6)']);
      await tester.pumpWidget(ProviderScope(overrides: [
        segregationResultsProvider.overrideWithValue([result]),
      ], child: const MaterialApp(home: SegregationPage())));
      expect(find.text(SegregationPage.statusLabel(status)), findsOneWidget);
      expect(find.text(result.description), findsOneWidget);
      expect(find.text('0140784'), findsOneWidget);
      expect(find.text('49 CFR §176.83(a)(6)'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
