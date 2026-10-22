import 'package:baystream/core/errors/failures.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/local_vessel_repository.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_overview_page.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/voyage_ui_state.dart';
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
  List<VesselProfile> templates = [];
  @override
  Future<Either<Failure, String?>> getLastConfirmedPortOfCall() async => const Right(null);
  @override
  Future<Either<Failure, void>> setLastConfirmedPortOfCall(String? port) async => const Right(null);
  @override
  Future<Either<Failure, void>> saveVoyage(VesselVoyage voyage) async => const Right(null);
  // Fase 3 (10.9): la regla de publicación directa lee los viajes guardados.
  @override
  Future<Either<Failure, List<VesselVoyage>>> getAllVoyages() async => const Right([]);
  @override
  Future<Either<Failure, List<VesselProfile>>> getAllProfiles() async => Right(templates);
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

  /// Fase 3 (10.9): en el inicio la carga es «Seleccionar archivo»; con un
  /// viaje a la vista, la barra (desde la Lista, donde no se pliega), y un
  /// previo abierto se descarta antes (DESIGN.md 7.2, punto 5).
  Future<void> load(WidgetTester tester) async {
    final selectFile = find.byKey(const ValueKey('select-file'));
    if (selectFile.evaluate().isNotEmpty) {
      await tester.tap(selectFile);
      await tester.pumpAndSettle();
      return;
    }
    await tester.tap(find.text('Lista'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Cargar archivo BAPLIE'));
    await tester.pumpAndSettle();
    final discard = find.byKey(const ValueKey('preview-discard'));
    if (discard.evaluate().isNotEmpty) {
      await tester.tap(discard);
      await tester.pumpAndSettle();
    }
  }

  /// «Confirmar» en la banda del previo: lo que antes se abría solo.
  Future<void> confirmar(WidgetTester tester) async {
    expect(find.byKey(const ValueKey('preview-banner')), findsOneWidget);
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();
  }

  setUp(() => local = _ProfileResponses());

  testWidgets('T-33 plantilla conserva identidad nueva y espera confirmación', (tester) async {
    final source = VesselProfile.proposeFrom(BaplieParserService().parse(
        profileTestEdi.replaceAll('9000003', '9000004').replaceAll('BUQUE ALFA', 'BUQUE BETA')))
        .copyWith(stackWeightLimitKg: 75000, reeferSlots: {'0020182'},
          origin: VesselProfileOrigin.declaredByUser,
          reeferSlotsOrigin: VesselProfileOrigin.declaredByUser);
    local.templates = [source];
    await open(tester);
    await load(tester);
    await confirmar(tester);
    expect(find.text('Perfil del buque nuevo'), findsOneWidget);
    await tester.tap(find.byKey(ValueKey('profile-template-${source.key}')));
    await tester.pumpAndSettle();
    expect(local.saved, isEmpty);
    expect(notifier.publishedVoyage, isNull);
    expect(notifier.currentProfile!.key, 'imo:9000003');
    expect(notifier.currentProfile!.origin, VesselProfileOrigin.template);
    expect(notifier.currentProfile!.reeferSlotsOrigin, VesselProfileOrigin.template);
    await tester.tap(find.byKey(const ValueKey('geometry-confirm')));
    await tester.pumpAndSettle();
    expect(local.saved.single.key, 'imo:9000003');
    expect(local.saved.single.reeferSlotsOrigin, VesselProfileOrigin.template);
    expect(source.key, 'imo:9000004');
  });

  testWidgets('T-33 elegir archivo o cancelar no guarda una plantilla', (tester) async {
    local.templates = [VesselProfile.proposeFrom(BaplieParserService().parse(
      profileTestEdi.replaceAll('9000003', '9000004')))];
    await open(tester);
    await load(tester);
    await confirmar(tester);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    // Cancelar deja el previo a la vista, sin guardar nada.
    expect(notifier.isPreview, isTrue);
    expect(notifier.publishedVoyage, isNull);
    expect(local.saved, isEmpty);
    await load(tester);
    await confirmar(tester);
    await tester.tap(find.byKey(const ValueKey('profile-from-file')));
    await tester.pumpAndSettle();
    expect(notifier.currentProfile!.origin, VesselProfileOrigin.proposedFromFile);
    expect(local.saved, isEmpty);
    await tester.tap(find.byKey(const ValueKey('geometry-cancel')));
    await tester.pumpAndSettle();
    expect(local.saved, isEmpty);
  });

  testWidgets('T-31 muestra cota inferior y confirmar no declara las tomas',
      (tester) async {
    await open(tester);
    notifier.content = profileTestEdi.replaceAll('42G1', '42R1');
    await load(tester);
    await confirmar(tester);
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
    await confirmar(tester);
    expect(find.text('Confirmar y ver el plano'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('geometry-no-limit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('geometry-confirm')));
    await tester.pumpAndSettle();
    expect(local.saved, hasLength(1));
    await load(tester);
    // Fase 3 (10.9): el archivo no declara escala, así que la segunda carga
    // abre en previo con el perfil guardado, sin volver a preguntarlo
    // (DESIGN.md 7.2); los parámetros no se abren solos.
    expect(find.text('Confirmar y ver el plano'), findsNothing);
    expect(find.byKey(const ValueKey('preview-banner')), findsOneWidget);
    expect(notifier.previewReason, PreviewReason.escalaPorDecidir);
    expect(local.saved, hasLength(1));
    expect(notifier.currentProfile!.geometry, local.saved.single.geometry);
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
    expect(notifier.previewReason, PreviewReason.fueraDelPerfil);
    await confirmar(tester);
    expect(find.text('La carga excede el perfil guardado'), findsOneWidget);
    expect(find.textContaining('0020386'), findsOneWidget);
    expect(local.saved, isEmpty);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(notifier.isPreview, isTrue);
    expect(notifier.publishedVoyage, isNull);
    expect(local.saved, isEmpty);
    await load(tester);
    await confirmar(tester);
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
    expect(notifier.previewReason, PreviewReason.homonimo);
    await confirmar(tester);
    expect(find.text('Confirma la identidad del buque'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(notifier.publishedVoyage, isNull);
    expect(notifier.isPreview, isTrue, reason: 'cancelar deja el previo');
    expect(local.saved, isEmpty);
  });
}
