import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/entities/stowage_validation_result.dart';
import 'package:baystream/features/vessel/presentation/pages/segregation_page.dart';
import 'package:baystream/features/vessel/presentation/providers/segregation_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dangerous_goods_validator_test.dart' show dangerous, testGeometry;

class _Published extends VoyageNotifier {
  final VesselVoyage voyage;
  VesselProfile? profile;
  _Published(this.voyage);
  @override
  VesselProfile? get publishedProfile => profile;
  @override
  AsyncValue<VesselVoyage?> build() => AsyncValue.data(voyage);
  void publish(VesselProfile value) {
    profile = value;
    state = AsyncValue.data(voyage);
  }
}

void main() {
  test('T85 proveedor recalcula al cambiar solo las tapas del perfil publicado',
      () {
    final v = VesselVoyage(
        id: 'synthetic',
        vessel: const Vessel(id: 's', name: 'SINTETICO'),
        voyageNumber: 's',
        bays: const {},
        geometry: testGeometry,
        containers: [
          dangerous('0001', '3', '0010182'),
          dangerous('0002', '5.1', '0010102')
        ]);
    final notifier = _Published(v);
    final scope = ProviderContainer(
        overrides: [voyageNotifierProvider.overrideWith(() => notifier)]);
    addTearDown(scope.dispose);
    final sub = scope.listen(segregationResultsProvider, (previous, next) {});
    addTearDown(sub.close);
    final profile = VesselProfile.proposeFrom(v);
    notifier.publish(profile);
    expect(scope.read(segregationResultsProvider).single.status,
        ValidationStatus.conforming);
    notifier.publish(profile.copyWith(hatchCovers: {
      1: HatchCoverDeclaration(kind: HatchCoverKind.openHold)
    }));
    expect(scope.read(segregationResultsProvider).single.status,
        ValidationStatus.notEvaluated);
  });
  for (final brightness in Brightness.values) {
    testWidgets(
        'T85 fuente matriz y resultados a 360 dp 1.45 ${brightness.name}',
        (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(ProviderScope(
          overrides: [segregationResultsProvider.overrideWithValue(const [])],
          child: MaterialApp(
              theme: ThemeData(brightness: brightness),
              builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: const TextScaler.linear(1.45)),
                  child: child!),
              home: const SegregationPage())));
      expect(find.textContaining('Fuente: Código IMDG, Enmienda 42-24'),
          findsOneWidget);
      for (var i = 0;
          i < 10 &&
              find
                  .text('Ver matriz de 17 clases')
                  .hitTestable()
                  .evaluate()
                  .isEmpty;
          i++) {
        await tester.drag(find.byType(ListView), const Offset(0, -300));
        await tester.pumpAndSettle();
      }
      expect(
          find.text('Ver matriz de 17 clases').hitTestable(), findsOneWidget);
      await tester.tap(find.text('Ver matriz de 17 clases'));
      await tester.pumpAndSettle();
      expect(find.byType(DataTable), findsOneWidget);
      final table = tester.widget<DataTable>(find.byType(DataTable));
      expect(table.columns.length, 18);
      expect(table.rows.length, 17);
      expect(tester.takeException(), isNull);
    });
  }
}
