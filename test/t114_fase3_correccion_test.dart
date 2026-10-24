// T-114 · Fase 3, entrega 1, corrección (10.15, H1): «No lo tengo» no se marca
// por omisión. Viene marcado solo si el perfil es de este mismo buque, lo
// declaró el usuario y no tiene límite; con una plantilla de otro buque (el
// caso de Codex: BUQUE BETA para BUQUE ALFA) o con la propuesta del archivo,
// empieza sin marcar y, sin elegir, no se puede confirmar.
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_geometry_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/local_profile_test_support.dart';

/// La geometría de BUQUE BETA: más grande que la del archivo de ALFA.
const _geometriaBeta = VesselGeometry(
  portRows: 6,
  starboardRows: 6,
  holdTiers: [2, 4, 6, 8, 10, 12, 14],
  deckTiers: [82, 84, 86, 88, 90],
);

void main() {
  // BUQUE ALFA es el buque del archivo (profileTestEdi, IMO 9000003); la
  // página recibe la propuesta y las posiciones de ese archivo, como en la app.
  final alfa = BaplieParserService().parse(profileTestEdi);
  final propuestaDeAlfa = VesselProfile.proposeFrom(alfa);

  /// Un perfil de BUQUE BETA, declarado por el usuario y sin límite por pila.
  VesselProfile beta() => VesselProfile(
        identity: VesselIdentity(
            source: VesselIdentitySource.imo, value: '9000099'),
        vesselName: 'BUQUE BETA',
        geometry: _geometriaBeta,
        origin: VesselProfileOrigin.declaredByUser,
        reeferSlotsOrigin: VesselProfileOrigin.declaredByUser,
        updatedAt: DateTime.utc(2026),
      );

  Future<void> abrir(
    WidgetTester tester, {
    required VesselProfile? profile,
    VesselGeometry? initial,
    VesselVoyage? voyage,
    bool profileOnly = false,
  }) async {
    tester.view.physicalSize = const Size(1000, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: VesselGeometryPage(
        proposal: propuestaDeAlfa.geometry,
        positions: alfa.stowagePositions.toList(),
        loadingPorts: alfa.loadingPortCounts,
        voyage: voyage,
        initial: initial,
        profile: profile,
        profileOnly: profileOnly,
        fileName: 'alfa.edi',
      ),
    ));
    await tester.pumpAndSettle();
  }

  bool marcado(WidgetTester tester) =>
      tester
          .widget<CheckboxListTile>(
              find.byKey(const ValueKey('geometry-no-limit')))
          .value ==
      true;

  bool puedeConfirmar(WidgetTester tester) =>
      tester
          .widget<FilledButton>(find.byKey(const ValueKey('geometry-confirm')))
          .onPressed !=
      null;

  testWidgets(
      'la plantilla sin límite de otro buque empieza sin marcar y sin elegir no se confirma',
      (tester) async {
    // El caso de Codex: el usuario elige «Plantilla: BUQUE BETA» para BUQUE
    // ALFA; useTemplate la clona con origen plantilla.
    final plantilla = beta().cloneFor(alfa.vessel);
    expect(plantilla.origin, VesselProfileOrigin.template);
    expect(plantilla.stackWeightLimitKg, isNull);
    await abrir(tester,
        profile: plantilla, initial: plantilla.geometry, voyage: alfa);
    expect(marcado(tester), isFalse);
    expect(puedeConfirmar(tester), isFalse,
        reason: 'sin límite escrito y sin «No lo tengo» no se confirma');

    // Elegir «No lo tengo» es una acción del usuario, y entonces sí.
    await tester.ensureVisible(find.byKey(const ValueKey('geometry-no-limit')));
    await tester.tap(find.byKey(const ValueKey('geometry-no-limit')));
    await tester.pumpAndSettle();
    expect(marcado(tester), isTrue);
    expect(puedeConfirmar(tester), isTrue);
  });

  testWidgets('la propuesta del archivo empieza sin marcar', (tester) async {
    expect(propuestaDeAlfa.origin, VesselProfileOrigin.proposedFromFile);
    expect(propuestaDeAlfa.stackWeightLimitKg, isNull);
    await abrir(tester, profile: propuestaDeAlfa, voyage: alfa);
    expect(marcado(tester), isFalse);
    expect(puedeConfirmar(tester), isFalse);
    // Escribir el límite también resuelve la elección.
    await tester.enterText(
        find.byKey(const ValueKey('geometry-stack-limit')), '90000');
    await tester.pumpAndSettle();
    expect(marcado(tester), isFalse);
    expect(puedeConfirmar(tester), isTrue);
  });

  testWidgets('el perfil declarado del mismo buque sin límite viene marcado',
      (tester) async {
    final declarado = propuestaDeAlfa.copyWith(
      origin: VesselProfileOrigin.declaredByUser,
    );
    expect(declarado.key, alfa.vessel.profileKey);
    expect(declarado.stackWeightLimitKg, isNull);
    await abrir(tester,
        profile: declarado, initial: declarado.geometry, voyage: alfa);
    expect(marcado(tester), isTrue,
        reason: 'el usuario ya declaró que no tiene el manual de este buque');
    expect(puedeConfirmar(tester), isTrue);
    // Y al editar el perfil solo (sin viaje), igual.
    await abrir(tester,
        profile: declarado, initial: declarado.geometry, profileOnly: true);
    expect(marcado(tester), isTrue);
  });

  testWidgets('un perfil declarado de otro buque no marca nada', (tester) async {
    // Declarado por el usuario, pero no es el buque del archivo.
    await abrir(tester, profile: beta(), initial: beta().geometry, voyage: alfa);
    expect(marcado(tester), isFalse);
    expect(puedeConfirmar(tester), isFalse);
  });
}
