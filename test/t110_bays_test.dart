import 'package:baystream/features/vessel/data/datasources/local_vessel_codec.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/bay_plan_view.dart';
import 'package:baystream/features/vessel/presentation/widgets/voyage_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../tool/t98_support.dart';
import 'support/local_profile_test_support.dart';

const geometry = VesselGeometry(
    portRows: 1, starboardRows: 1, holdTiers: [2], deckTiers: [82]);
String cargo([String iso = '42G1']) => t98Message().replaceFirst('22G1', iso);
VesselVoyage read(String text) => BaplieParserService().parse(text);
List<int> numbers(VesselVoyage voyage) => voyage.bays.keys.toList();

class _Fixed extends VoyageNotifier {
  final VesselVoyage voyage;
  _Fixed(this.voyage);
  @override
  AsyncValue<VesselVoyage?> build() => AsyncData(voyage);
}

void main() {
  for (final type in ['42G1', '45R1', 'L5G1']) {
    for (final profile in [false, true]) {
      test('T110 $type leer/reabrir con perfil $profile', () {
        final parsed = read(cargo(type));
        final voyage = profile
            ? parsed
                .withGeometry(geometry)
                .copyWith(vesselProfileKey: 'perfil-t110')
            : parsed;
        const codec = LocalVesselCodec();
        final restored = codec.decodeVoyage(codec.encodeVoyage(voyage));
        expect(numbers(voyage), [1, 2, 3]);
        expect(numbers(restored), numbers(voyage));
        expect(restored.containers, voyage.containers);
        expect(voyage.bays[1]!.containers, isEmpty);
        expect(voyage.bays[1]!.slotsOccupiedByNeighbors, {'0182'});
        expect(restored.bays[1]!.slotsOccupiedByNeighbors, {'0182'});
        expect(restored.geometry, voyage.geometry);
      });
    }
  }
  for (final hasProfile in [false, true]) {
    test('T110 Recientes real con perfil $hasProfile conserva lista', () async {
      final store = await testProfileStore();
      final parsed = read(cargo());
      final voyage = parsed.withGeometry(geometry);
      if (hasProfile) {
        final profile = VesselProfile.proposeFrom(voyage).copyWith(
            geometry: geometry,
            origin: VesselProfileOrigin.declaredByUser,
            observedHoldBayNumbers: {
              99
            },
            hatchCovers: {
              99: HatchCoverDeclaration(kind: HatchCoverKind.openHold)
            });
        expect((await store.repository.saveProfile(profile)).isRight(), isTrue);
      }
      expect((await store.repository.saveVoyage(voyage)).isRight(), isTrue);
      final scope = ProviderContainer(overrides: [
        localVesselRepositoryProvider
            .overrideWith((ref) async => store.repository),
        vesselRepositoryProvider.overrideWith(
            (ref) => throw StateError('Sin parser ni red al reabrir')),
      ]);
      try {
        final notifier = scope.read(voyageNotifierProvider.notifier);
        expect(await notifier.openRecentVoyage(voyage.id), isNull);
        final reopened = notifier.publishedVoyage!;
        expect(numbers(reopened), numbers(parsed));
        expect(numbers(reopened), [1, 2, 3]);
        expect(reopened.bays.containsKey(99), isFalse);
        expect(reopened.totalWeight, parsed.totalWeight);
        expect(reopened.containers, parsed.containers);
      } finally {
        scope.dispose();
        await store.repository.close();
        await store.directory.delete(recursive: true);
      }
    });
  }
  test('T110 reserva sola visible, sin sumar a Estadísticas', () {
    final text = cargo()
        .replaceFirst('UNT+', "LOC+147+0110182::5'EQD+CN++22G1+++4'UNT+");
    final voyage = read(text);
    final scope = ProviderContainer(
        overrides: [voyageNotifierProvider.overrideWith(() => _Fixed(voyage))]);
    try {
      expect(numbers(voyage), [1, 2, 3, 11]);
      expect(voyage.bays[11]!.containers, isEmpty);
      expect(voyage.bays[11]!.slotsOccupiedByNeighbors, isEmpty);
      expect(voyage.totalReservedSlots, 1);
      expect(scope.read(voyageStatsProvider)!.totalBays, 3);
      const codec = LocalVesselCodec();
      expect(numbers(codec.decodeVoyage(codec.encodeVoyage(voyage))),
          numbers(voyage));
    } finally {
      scope.dispose();
    }
  });
  testWidgets(
      'T110 impar con solo sombra tiene selector y rejilla cubierta/bodega',
      (tester) async {
    final text = cargo()
        .replaceFirst('UNT+', "LOC+147+0110182::5'EQD+CN++22G1+++4'UNT+");
    final voyage = read(text).withGeometry(geometry);
    await tester.pumpWidget(ProviderScope(overrides: [
      voyageNotifierProvider.overrideWith(() => _Fixed(voyage)),
      operatorProvider.overrideWith((ref) => Stream.value(null)),
      activeOperationProvider.overrideWith((ref) async => null),
      localVesselRepositoryProvider.overrideWith(
          (ref) async => throw StateError('No abrir almacen real')),
    ], child: MaterialApp(home: Scaffold(body: BayPlanView(voyage: voyage)))));
    await tester.pumpAndSettle();
    expect(find.text('BAHÍA 01 (17%)'), findsOneWidget);
    expect(find.text('BAHÍA 11 (0%)'), findsOneWidget);
    final scope =
        ProviderScope.containerOf(tester.element(find.byType(BayPlanView)));
    expect(scope.read(voyageStatsProvider)!.totalBays, 3);
    expect(find.byKey(const ValueKey('cell-1-2')), findsOneWidget);
    expect(find.byKey(const ValueKey('cell-1-82')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final missing in [1, 2]) {
    testWidgets('T110 falta/faltan $missing segmentos', (tester) async {
      var source = t98Message().replaceAll(RegExp(r"UNZ[^']*'"), '');
      if (missing == 2) source = source.replaceAll(RegExp(r"UNT[^']*'"), '');
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: SingleChildScrollView(
                  child: VoyageSummaryCard(voyage: read(source))))));
      await tester.pumpAndSettle();
      final phrase = missing == 1
          ? 'falta 1 segmento (UNZ)'
          : 'faltan 2 segmentos (UNT, UNZ)';
      expect(find.textContaining(phrase), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  for (final qualifier in ['WT', 'VGM', 'T']) {
    for (final unit in ['LBR', 'TNE']) {
      test('T110 $qualifier $unit aviso en kilos enteros', () {
        final voyage = read(t98Message(unit: unit, qualifier: qualifier));
        final details = voyage.readNotices
            .where((n) => n.kind == BaplieReadNoticeKind.weight)
            .single
            .details
            .single;
        final kg = unit == 'LBR' ? '10886' : '24000000';
        expect(details, endsWith('$qualifier en $unit convertido a $kg kg'));
        expect(details, isNot(contains('.0 kg')));
      });
    }
  }
}
