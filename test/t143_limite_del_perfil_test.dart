import 'dart:io';

import 'package:baystream/core/design/design.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_impl.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_geometry_page.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/voyage_ui_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/local_profile_test_support.dart';
import 'support/t74_movement_log_support.dart';
import 'support/t82_fixture.dart';

/// T-143 (O-139-6; 10.117) · El límite de apilamiento al agregar el plan de
/// carga a la operación publicada. T-139 vio «No lo tengo» sin marcar en ese
/// paso. Aquí se reproduce el recorrido del manual (7.7) con el notificador
/// real: la llegada confirmada con «No lo tengo», la operación publicada y el
/// plan de carga abierto en previo con la banda de la operación publicada; la
/// página de parámetros recibe lo que le pasa `_askForGeometry`.
///
/// Los planos son los de T-82 con un IMO, como los sintéticos de T-100: con
/// un IMO el perfil se reconoce sin preguntar por homónimos.
const _imo = '9000003';
final _llegada = t82ArrivalEdi.replaceFirst('+++:::BUQUE PRUEBA', '+++$_imo:146:11:BUQUE PRUEBA');
final _carga = t82LoadingEdi.replaceFirst('+++:::BUQUE PRUEBA', '+++$_imo:146:11:BUQUE PRUEBA');

void main() {
  late ProviderContainer container;
  late VoyageNotifier notifier;
  late T74MemoryLog log;
  late ({Directory directory, LocalVesselRepositoryImpl repository}) store;

  setUp(() async {
    store = await testProfileStore();
    log = T74MemoryLog();
    container = ProviderContainer(overrides: [
      movementLogRepositoryProvider.overrideWith((ref) async => log),
      vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
      localVesselRepositoryProvider.overrideWith((ref) async => store.repository),
    ]);
    notifier = container.read(voyageNotifierProvider.notifier);
  });
  tearDown(() async {
    container.dispose();
    await store.repository.close();
    await store.directory.delete(recursive: true);
  });

  /// La llegada confirmada en GTSTC, con el límite que se pida (nulo es
  /// «No lo tengo»), y su operación publicada en este equipo.
  Future<void> llegadaPublicada({double? limite}) async {
    final abierta = await notifier.parseBaplieContent(_llegada, fileName: 'llegada.edi');
    expect(abierta.preview, isTrue);
    final propuesta = notifier.currentProfile!.geometry;
    final geometria = limite == null
        ? propuesta.withoutStackWeightLimit()
        : propuesta.copyWith(stackWeightLimitKg: limite);
    expect(
        await notifier.confirmGeometry(geometria,
            portOfCall: 'GTSTC', sourceKind: OperationSourceKind.arrivalBaplie),
        isNull);
    final operaciones = (await log.getOperations()).getOrElse(() => const []);
    expect(operaciones, hasLength(1));
    await log.saveOperation(operaciones.single.copyWith(published: true));
  }

  /// El plan de carga en previo con la banda de la operación publicada, y lo
  /// que `_askForGeometry` le pasa a la página (vessel_overview_page.dart).
  Future<VesselGeometryPage> planDeCargaEnPrevio() async {
    final abierto = await notifier.parseBaplieContent(_carga, fileName: 'carga.edi');
    expect(abierto.preview, isTrue);
    final ui = container.read(voyageUiStateProvider);
    expect(ui, isA<Previo>());
    expect((ui as Previo).motivo, PreviewReason.operacionPublicada,
        reason: 'el recorrido de 7.7 del manual');
    final target = notifier.pendingVoyage!;
    final profile = notifier.currentProfile!;
    final proposal =
        VesselProfile.proposeFrom(target, parameters: profile.geometry).geometry;
    return VesselGeometryPage(
      proposal: proposal,
      positions: target.stowagePositions.toList(),
      loadingPorts: target.loadingPortCounts,
      voyage: target,
      lastConfirmedPortOfCall: notifier.lastConfirmedPortOfCall,
      declaredPort: target.portOfOrigin,
      initialPortOfCall: target.portOfCall,
      initial: profile.origin != VesselProfileOrigin.proposedFromFile
          ? profile.geometry
          : null,
      profile: profile,
      fileName: 'carga.edi',
    );
  }

  Future<void> abrir(WidgetTester tester, VesselGeometryPage pagina) async {
    tester.view.physicalSize = const Size(1000, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: pagina));
    await tester.pumpAndSettle();
  }

  bool marcado(WidgetTester tester) =>
      tester
          .widget<CheckboxListTile>(find.byKey(const ValueKey('geometry-no-limit')))
          .value ==
      true;

  testWidgets('el perfil guardado con «No lo tengo» llega resuelto al plan de carga, '
      'con su línea',
      (tester) async {
    late VesselGeometryPage pagina;
    await tester.runAsync(() async {
      await llegadaPublicada();
      pagina = await planDeCargaEnPrevio();
    });
    expect(pagina.profile!.origin, VesselProfileOrigin.declaredByUser);
    expect(pagina.profile!.stackWeightLimitKg, isNull);
    expect(pagina.voyage!.vessel.profileKey, pagina.profile!.key);
    await abrir(tester, pagina);
    // La reproducción de T-139 (O-139-6) sale marcada con el código de la
    // 1.0.0: la regla de la corrección 10.15 ya lo cubría. T-143 agrega la
    // línea que dice de dónde viene.
    expect(marcado(tester), isTrue);
    expect(find.text(_lineaNoLoTengo), findsOneWidget);

    // Desmarcarlo es cambiarlo: la línea se va y hay que escribir un límite.
    await tester.tap(find.byKey(const ValueKey('geometry-no-limit')));
    await tester.pumpAndSettle();
    expect(marcado(tester), isFalse);
    expect(find.byKey(const ValueKey('geometry-limit-from-profile')), findsNothing);
  });

  testWidgets('el perfil guardado con un valor llega con el valor y lo dice',
      (tester) async {
    late VesselGeometryPage pagina;
    await tester.runAsync(() async {
      await llegadaPublicada(limite: 90000);
      pagina = await planDeCargaEnPrevio();
    });
    await abrir(tester, pagina);
    expect(marcado(tester), isFalse);
    expect(
        tester
            .widget<TextFormField>(find.byKey(const ValueKey('geometry-stack-limit')))
            .controller!
            .text,
        '90000');
    expect(find.text('Del perfil guardado: ${formatearKilos(90000)} por pila.'),
        findsOneWidget);
    expect(
        tester
                .widget<FilledButton>(find.byKey(const ValueKey('geometry-confirm')))
                .onPressed !=
            null,
        isTrue,
        reason: 'viene resuelto');

    // Otro valor ya no es el del perfil: la línea se va.
    await tester.enterText(
        find.byKey(const ValueKey('geometry-stack-limit')), '85000');
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('geometry-limit-from-profile')), findsNothing);
  });

  testWidgets('la propuesta del archivo no tiene línea ni viene marcada',
      (tester) async {
    late VesselGeometryPage pagina;
    await tester.runAsync(() async {
      final abierta =
          await notifier.parseBaplieContent(_llegada, fileName: 'llegada.edi');
      expect(abierta.preview, isTrue);
      final target = notifier.pendingVoyage!;
      final profile = notifier.currentProfile!;
      expect(profile.origin, VesselProfileOrigin.proposedFromFile);
      pagina = VesselGeometryPage(
        proposal: profile.geometry,
        positions: target.stowagePositions.toList(),
        loadingPorts: target.loadingPortCounts,
        voyage: target,
        profile: profile,
        fileName: 'llegada.edi',
      );
    });
    await abrir(tester, pagina);
    expect(marcado(tester), isFalse);
    expect(find.byKey(const ValueKey('geometry-limit-from-profile')), findsNothing);
  });
}

const _lineaNoLoTengo = 'Del perfil guardado: “No lo tengo”.';
