// T-122 · Lo nuevo del dominio y de la página que trajo la 3.1.1 (SPRINT-4.md
// 10.49 a 10.52 y 10.56): la regla de la bahía par de referencia escrita una
// sola vez, los puertos de descarga del archivo, la fila sin OR armada desde
// el plan, los vacíos asignados como contenedores a bordo y la búsqueda
// general que los encuentra. Complementa a t122_hallazgos_test.dart, que
// reproduce cada hallazgo con la API de la 3.1.0.
import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/data/repositories/local_only_operation_sync.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';
import 'package:baystream/features/vessel/domain/services/reference_bay.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_overview_page.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_operation_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_plan_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/local_profile_test_support.dart';
import 'support/t74_movement_log_support.dart';
import 'support/t76_fixture.dart';
import 'support/t91_toolbar_support.dart';

class _Viaje extends VoyageNotifier {
  _Viaje(this.voyage);
  final VesselVoyage voyage;
  @override
  AsyncValue<VesselVoyage?> build() => AsyncData(voyage);
}

void main() {
  group('H5 · referenceBay, la regla de Carlos en un solo sitio', () {
    test('la par convencional de cada impar: 01 y 03 → 02, 21 y 23 → 22',
        () {
      for (final (odd, even) in [
        (1, 2), (3, 2), (5, 6), (7, 6), (17, 18), (19, 18), (21, 22),
        (23, 22), (25, 26), (27, 26), (29, 30), (31, 30), (41, 42), (43, 42),
      ]) {
        expect(conventionalEvenBay(odd), even, reason: 'la $odd');
      }
    });
    test('una par es su propia referencia; una impar sin su par queda sola',
        () {
      final plano = {21, 22, 23, 25, 27, 30}.contains;
      expect(referenceBay(22, hasBay: plano), 22);
      expect(referenceBay(21, hasBay: plano), 22);
      expect(referenceBay(23, hasBay: plano), 22);
      expect(referenceBay(25, hasBay: plano), 25, reason: 'sin la 26');
      expect(referenceBay(27, hasBay: plano), 27, reason: 'sin la 26');
      expect(referenceBay(30, hasBay: plano), 30);
      expect(referenceBay(29, hasBay: plano), 30, reason: 'la 30 está');
      expect(referenceBay(4, hasBay: plano), 4,
          reason: 'una par siempre se cuenta como ella misma');
    });
    test('mira lo que el plano trae: la 044 de CORPUS_A01 cubre a la 043 y la 045',
        () {
      // Las bahías pares del corpus son 02, 06, 10… (conteo directo, 26-oct)
      // salvo la 044 de A01, que la convención no prevé.
      final a01 = {41, 44}.contains;
      expect(referenceBay(41, hasBay: a01), 41);
      expect(referenceBay(43, hasBay: a01), 44);
      expect(referenceBay(45, hasBay: a01), 44);
      // Dos pares vecinas a la vez no se dan; si se dieran, la convencional.
      expect(referenceBay(23, hasBay: {22, 24}.contains), 22);
      expect(referenceBay(1, hasBay: {2}.contains), 2);
    });
  });

  group('H1 · los puertos de descarga del archivo', () {
    test('dischargePortCounts cuenta LOC+11 del más al menos frecuente', () {
      const text = "UNH+1+BAPLIE:D:95B:UN:SMDG20'"
          "TDT+20+V122+++NV2:172:20+++9000122:146:11:BUQUE PRUEBA'"
          "LOC+5+PAMIT:139:6'LOC+61+CRPMN:139:6'"
          "LOC+147+0020182::5'LOC+9+PAMIT:139:6'LOC+11+GTSTC:139:6'"
          "EQD+CN+TSTU0001221+42G1+++5'"
          "LOC+147+0020184::5'LOC+9+PAMIT:139:6'LOC+11+GTSTC:139:6'"
          "EQD+CN+TSTU0001222+42G1+++5'"
          "LOC+147+0020186::5'LOC+9+PAMIT:139:6'LOC+11+CRPMN:139:6'"
          "EQD+CN+TSTU0001223+42G1+++5'";
      final voyage = BaplieParserService().parse(text);
      expect(voyage.dischargePortCounts, {'GTSTC': 2, 'CRPMN': 1});
      expect(voyage.dischargePortCounts.keys.first, 'GTSTC');
    });
  });

  group('H4 · la fila armada desde el plan', () {
    test('ExportListRow.fromPlan: sin OR, con el tipo, el puerto y la línea',
        () {
      final unit = t76Unit('FULL0001234', '0030282')
          .copyWith(tareWeight: 2200, vgmWeight: 9100);
      final row = ExportListRow.fromPlan(unit);
      expect(row.unlisted, isTrue);
      expect(row.order, 0);
      expect(row.sheetRow, 0);
      expect(row.name, 'FULL0001234');
      expect(row.label, 'FULL0001234 · sin OR en el listado');
      expect((row.type, row.pod, row.line), ('22G1', 'PAMIT', 'TEST'));
      expect(row.tareKg, 2200);
      expect(row.vgmKg, 9100);
      expect(row.isFull, isTrue);
      expect(t76Row(7, 'FULL0001234').unlisted, isFalse);
      expect(t76Row(7, 'FULL0001234').label, 'OR 7 · FULL0001234');
    });
    test('unlistedRows: solo lo que el plan carga aquí y el listado no trae',
        () {
      final none = t76Operation();
      expect(none.unlistedRows, isEmpty, reason: 'el listado trae los dos');
      final partial = LoadingOperation.build(
          operationId: 'op',
          arrival: t76Arrival,
          loading: t76Loading,
          list: ExportList(
              fileName: 'parcial.xlsx', rows: [t76Row(2, 'FULL0005678')]));
      expect(partial.unlistedRows.map((r) => r.containerId), ['FULL0001234']);
      expect(partial.unlistedRow('FULL0001234')?.unlisted, isTrue);
      expect(partial.unlistedRow('FULL0005678'), isNull);
      expect(partial.unlistedRow('INCOMING1'), isNull,
          reason: 'lo que baja aquí no se carga');
      final check = partial.check(partial.unlistedRow('FULL0001234')!, '0030282');
      expect(check.issues.map((i) => i.kind), isEmpty,
          reason: 'tipo, celda y grupo coinciden con el plan');
    });
  });

  group('H6 · los vacíos asignados como contenedores a bordo', () {
    final assign = t76Movement(
        MovementDraft.assignEmpty('op', '0030882', 'EMPTY0000012', 2185,
            order: 12),
        1);
    test('assignedEmpties: número, celda, tipo, tara y puertos de la reserva',
        () {
      expect(t76Operation().assignedEmpties, isEmpty);
      final data = t76Operation([assign]);
      final unit = data.assignedEmpties.single;
      expect(unit.containerId, 'EMPTY0000012');
      expect(unit.status, ContainerStatus.empty);
      expect(unit.stowagePosition, IsoCoordinateParser.parse('0030882'));
      expect(unit.isoSizeType, '22G1');
      expect(unit.tareWeight, 2185);
      expect(unit.effectiveWeight, 2185);
      expect((unit.portOfLoading, unit.portOfDischarge, unit.operatorCode),
          ('GTSTC', 'PAMIT', 'TEST'));
      expect(data.search('', empties: true).map((r) => r.order), [12, 13],
          reason: '«Asignar vacío» lo sigue listando, como «Ya cargado»');
    });
    testWidgets('la búsqueda general lo encuentra por su número y lleva al plano',
        (tester) async {
      final font = FontLoader('Roboto')
        ..addFont(rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
      await font.load();
      tester.view.physicalSize = const Size(1300, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final data = t76Operation([assign]);
      final scope = ProviderContainer(overrides: [
        voyageNotifierProvider.overrideWith(() => _Viaje(t76Loading)),
        localVesselRepositoryProvider
            .overrideWith((ref) async => T91MemorySettings()),
        vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
        movementLogRepositoryProvider.overrideWith((ref) async => T74MemoryLog()),
        sessionRepositoryProvider
            .overrideWith((ref) async => const LocalSessionRepository()),
        loadingOperationProvider(t76Loading)
            .overrideWith((ref) => Stream.value(data)),
        loadingPlanProgressProvider(t76Loading)
            .overrideWith((ref) => Stream.value(data.progress)),
      ]);
      addTearDown(scope.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
          container: scope,
          child: MaterialApp(
              theme: ThemeData(fontFamily: 'Roboto'),
              home: const VesselOverviewPage())));
      await tester.pumpAndSettle();
      expect(scope.read(aboardContainersProvider).map((c) => c.containerId),
          contains('EMPTY0000012'));
      await tester.tap(find.byKey(const ValueKey('buscar-contenedor')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'EMPTY0000012');
      await tester.pumpAndSettle();
      expect(find.text('Sin resultados para "EMPTY0000012"'), findsNothing);
      expect(find.textContaining('Posición: '), findsOneWidget);
      await tester.tap(find.textContaining('Posición: '));
      await tester.pumpAndSettle();
      expect(scope.read(selectedBayProvider), 3);
      expect(scope.read(highlightedContainerProvider), 'EMPTY0000012');
    });
  });
}
