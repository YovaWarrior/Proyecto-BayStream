import 'package:baystream/core/errors/failures.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/local_vessel_repository.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_overview_page.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/local_profile_test_support.dart';

class _ReplayNotifier extends VoyageNotifier {
  String content = profileTestEdi;
  @override
  Future<LoadFileResult> loadVesselFromFile() =>
      parseBaplieContent(content, fileName: 'A01.edi');
}

/// Controla respuestas del contrato para probar decisiones visibles de la pantalla.
class _ProfileResponses implements LocalVesselRepository {
  VesselProfileLookup lookup = VesselProfileLookup();
  final saved = <VesselProfile>[];
  @override
  Future<Either<Failure, VesselProfileLookup>> findProfileFor(
          Vessel vessel) async =>
      Right(lookup);
  @override
  Future<Either<Failure, void>> saveProfile(VesselProfile profile,
      {bool nameMatchConfirmed = false}) async {
    saved.add(profile);
    lookup = VesselProfileLookup(automaticMatch: profile);
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _ProfileResponses local;
  late _ReplayNotifier notifier;
  Future<void> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    notifier = _ReplayNotifier();
    await tester.pumpWidget(ProviderScope(overrides: [
      vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
      localVesselRepositoryProvider.overrideWith((ref) async => local),
      voyageNotifierProvider.overrideWith(() => notifier),
    ], child: const MaterialApp(home: VesselOverviewPage())));
  }

  Future<void> load(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Cargar archivo BAPLIE'));
    await tester.pumpAndSettle();
  }

  setUp(() => local = _ProfileResponses());

  testWidgets('T-31 muestra cota inferior y confirmar no declara las tomas',
      (tester) async {
    await open(tester);
    notifier.content = profileTestEdi.replaceAll('42G1', '42R1');
    await load(tester);
    expect(
        find.textContaining(
            '1 posiciones propuestas del archivo (cota inferior)'),
        findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('geometry-no-limit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('geometry-confirm')));
    await tester.pumpAndSettle();
    expect(local.saved.single.origin, VesselProfileOrigin.declaredByUser);
    expect(local.saved.single.reeferSlotsOrigin,
        VesselProfileOrigin.proposedFromFile);
    expect(local.saved.single.reeferSlots, {'0020182'});
  });

  testWidgets(
      'la pantalla pregunta una vez y reutiliza el perfil en la segunda carga',
      (tester) async {
    await open(tester);
    await load(tester);
    expect(find.text('Confirmar y ver el plano'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('geometry-no-limit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('geometry-confirm')));
    await tester.pumpAndSettle();
    expect(local.saved, hasLength(1));
    await load(tester);
    expect(find.text('Confirmar y ver el plano'), findsNothing);
    expect(local.saved, hasLength(1));
    expect(notifier.publishedVoyage!.geometry, local.saved.single.geometry);
  });

  testWidgets(
      'avisa coordenadas fuera del perfil y cancelar no guarda una ampliación',
      (tester) async {
    final profile =
        VesselProfile.proposeFrom(BaplieParserService().parse(profileTestEdi))
            .copyWith(origin: VesselProfileOrigin.declaredByUser);
    local.lookup = VesselProfileLookup(automaticMatch: profile);
    await open(tester);
    notifier.content = profileTestEdi.replaceAll('0020182', '0020386');
    await load(tester);
    expect(find.text('La carga excede el perfil guardado'), findsOneWidget);
    expect(find.textContaining('0020386'), findsOneWidget);
    expect(local.saved, isEmpty);
    await tester.tap(find.text('Cancelar carga'));
    await tester.pumpAndSettle();
    expect(notifier.pendingVoyage, isNull);
    expect(notifier.publishedVoyage, isNull);
    expect(local.saved, isEmpty);
    await load(tester);
    await tester.tap(find.text('Revisar ampliación'));
    await tester.pumpAndSettle();
    expect(local.saved, isEmpty);
    await tester.tap(find.byKey(const ValueKey('geometry-confirm')));
    await tester.pumpAndSettle();
    expect(
        local.saved.single.geometry
            .coversAll(notifier.publishedVoyage!.stowagePositions),
        isTrue);
    expect(profile.geometry.starboardRows, 1);
  });

  testWidgets('un homónimo muestra una pregunta y cancelar no carga el plano',
      (tester) async {
    final profile =
        VesselProfile.proposeFrom(BaplieParserService().parse(profileTestEdi));
    local.lookup = VesselProfileLookup(nameCandidates: [profile]);
    await open(tester);
    await load(tester);
    expect(find.text('Confirma la identidad del buque'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(notifier.publishedVoyage, isNull);
    expect(notifier.pendingVoyage, isNull);
    expect(local.saved, isEmpty);
  });
}
