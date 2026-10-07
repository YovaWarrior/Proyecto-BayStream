import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/data/datasources/hive_vessel_data_source.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_impl.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_geometry_page.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/voyage_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/local_profile_test_support.dart';

const _header = "TDT+20+V01N+++NV2:172:20+++9000003:146:11:BUQUE ALFA'"
    "LOC+5+HNPCR:139:6'";
const _cargo = "LOC+147+0020182::5'LOC+9+HNPCR:139:6'"
    "LOC+11+GTSTC:139:6'EQD+CN+TEST0000001+42G1+++5'"
    "LOC+147+0020184::5'LOC+9+GTSTC:139:6'"
    "LOC+11+PAMIT:139:6'EQD+CN+TEST0000002+42G1+++5'"
    "LOC+147+0020186::5'LOC+9+PAMIT:139:6'"
    "LOC+11+HNPCR:139:6'EQD+CN+TEST0000003+42G1+++5'";
const _arrival = "${_header}LOC+61+GTSTC:139:6'$_cargo";

void main() {
  final parser = BaplieParserService();
  final voyage = parser.parse(_arrival);

  for (final code in ['GTSTC', 'USLAX', 'DE5AB']) {
    test('T-68 acepta LOC+61 $code en la cabecera', () {
      expect(
          parser.parse("${_header}LOC+61+$code:139:6'$_cargo").portOfNextCall,
          code);
    });
  }
  for (final code in ['*****', 'gtstc', 'GT', 'GTSTCC', '12ABC', 'GT*TC', '']) {
    test('T-68 LOC+61 $code no declara un próximo puerto', () {
      expect(
          parser.parse("${_header}LOC+61+$code:139:6'$_cargo").portOfNextCall,
          isNull);
    });
  }
  test('T-68 no busca LOC+61 dentro de la carga', () {
    expect(parser.parse("$_header${_cargo}LOC+61+GTSTC:139:6'").portOfNextCall,
        isNull);
  });
  test('T-68 LOC+61 se conserva en JSON y viajes antiguos siguen abriendo', () {
    final saved = voyage.withGeometry(
        VesselProfile.proposeFrom(voyage).geometry,
        portOfCall: 'GTSTC');
    expect(VesselVoyage.fromJson(saved.toJson()), saved);
    final old = saved.toJson()..remove('portOfNextCall');
    expect(VesselVoyage.fromJson(old).portOfNextCall, isNull);
    expect(VesselVoyage.fromJson(old).portOfCall, 'GTSTC');
  });
  test(
      'T-68 historial coincidente propone salida o llegada; otro conserva salida',
      () {
    expect(voyage.suggestPortOfCall(null), 'HNPCR');
    expect(voyage.suggestPortOfCall('GTSTC'), 'GTSTC');
    expect(voyage.suggestPortOfCall('HNPCR'), 'HNPCR');
    expect(voyage.suggestPortOfCall('PAMIT'), 'HNPCR');
    final withoutNext = parser.parse('$_header$_cargo');
    expect(withoutNext.suggestPortOfCall('GTSTC'), 'HNPCR');
  });
  test('T-68 carga aquí y descarga aquí se operan, ninguno va de paso', () {
    final called = voyage.copyWith(portOfCall: 'GTSTC');
    expect(called.containers.map(called.isInTransit), [false, false, true]);
    expect(
        called.cargoCountsFor('GTSTC'), (loaded: 1, discharged: 1, transit: 1));
    expect(called.containersAtCall, 2);
    expect(called.containersInTransit, 1);
    const noLoading = ContainerUnit(
        id: 'unknown', containerId: 'TEST0000004', portOfDischarge: 'PAMIT');
    expect(called.isInTransit(noLoading), isFalse);
    expect(voyage.isInTransit(called.containers.last), isFalse);
  });

  test(
      'T-68 almacén real persiste el puerto al cerrar y reabrir; borrar viajes lo conserva',
      () async {
    final store = await testProfileStore();
    var local = store.repository;
    final namespace = 't68_reopen_${DateTime.now().microsecondsSinceEpoch}';
    await local.close();
    Future<LocalVesselRepositoryImpl> open() async =>
        LocalVesselRepositoryImpl(await HiveVesselDataSource.open(
            directory: store.directory.path, namespace: namespace));
    local = await open();
    try {
      expect(
          (await local.getLastConfirmedPortOfCall()).getOrElse(() => 'ERROR'),
          isNull);
      expect(
          (await local.setLastConfirmedPortOfCall('GTSTC')).isRight(), isTrue);
      await local.saveVoyage(voyage);
      await local.deleteVoyage(voyage.id);
      await local.close();
      local = await open();
      expect(
          (await local.getLastConfirmedPortOfCall()).getOrElse(() => 'ERROR'),
          'GTSTC');
      expect((await local.getAllVoyages()).getOrElse(() => []), isEmpty);
      await local.setLastConfirmedPortOfCall(null);
      await local.close();
      local = await open();
      expect(
          (await local.getLastConfirmedPortOfCall()).getOrElse(() => 'ERROR'),
          isNull);
    } finally {
      await local.close();
      await store.directory.delete(recursive: true);
    }
  });
  test('T-68 confirmar escribe historial; cancelar y reabrir no lo cambian',
      () async {
    final store = await testProfileStore();
    final scope = ProviderContainer(overrides: [
      vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
      localVesselRepositoryProvider
          .overrideWith((ref) async => store.repository),
    ]);
    try {
      final notifier = scope.read(voyageNotifierProvider.notifier);
      expect(
          (await notifier.parseBaplieContent(_arrival)).needsGeometry, isTrue);
      expect(
          await notifier.confirmGeometry(notifier.currentProfile!.geometry,
              portOfCall: 'GTSTC'),
          isNull);
      final id = notifier.publishedVoyage!.id;
      expect(
          (await store.repository.getLastConfirmedPortOfCall())
              .getOrElse(() => null),
          'GTSTC');
      expect(
          (await notifier.parseBaplieContent(_arrival)).needsGeometry, isTrue,
          reason: 'El perfil conocido no decide la escala');
      expect(notifier.lastConfirmedPortOfCall, 'GTSTC');
      notifier.discardPendingVoyage();
      expect(
          (await store.repository.getLastConfirmedPortOfCall())
              .getOrElse(() => null),
          'GTSTC');
      await store.repository.setLastConfirmedPortOfCall('PAMIT');
      expect(await notifier.openRecentVoyage(id), isNull);
      expect(notifier.publishedVoyage!.portOfCall, 'GTSTC');
      expect(
          (await store.repository.getLastConfirmedPortOfCall())
              .getOrElse(() => null),
          'PAMIT');
      expect(await notifier.confirmGeometry(notifier.currentProfile!.geometry),
          isNull);
      expect(notifier.publishedVoyage!.portOfCall, isNull);
      expect(
          (await store.repository.getLastConfirmedPortOfCall())
              .getOrElse(() => null),
          isNull);
    } finally {
      scope.dispose();
      await store.repository.close();
      await store.directory.delete(recursive: true);
    }
  });

  for (final history in [null, 'GTSTC', 'PAMIT']) {
    testWidgets('T-68 diálogo a 360 dp con historial $history', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(
          home: VesselGeometryPage(
        proposal: VesselProfile.proposeFrom(voyage).geometry,
        voyage: voyage,
        declaredPort: voyage.portOfOrigin,
        loadingPorts: voyage.loadingPortCounts,
        lastConfirmedPortOfCall: history,
      )));
      await tester.scrollUntilVisible(
          find.byKey(const ValueKey('port-source')), 300,
          scrollable: find.byType(Scrollable).first);
      final chips =
          tester.widgetList<ChoiceChip>(find.byType(ChoiceChip)).toList();
      expect(chips.take(2).map((c) => c.key),
          [const ValueKey('port-HNPCR'), const ValueKey('port-GTSTC')]);
      expect(
          tester
              .widget<ChoiceChip>(find.byKey(
                  ValueKey('port-${history == 'GTSTC' ? 'GTSTC' : 'HNPCR'}')))
              .selected,
          isTrue);
      expect(find.textContaining('para la llegada, GTSTC'), findsOneWidget);
      await tester.ensureVisible(find.byKey(const ValueKey('port-GTSTC')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('port-GTSTC')));
      await tester.pumpAndSettle();
      expect(find.text('1 se descargan · 1 se cargan · 1 de paso'),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('T-68 ficha a 360 dp muestra escala y los tres conteos',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
                child: VoyageSummaryCard(
                    voyage: voyage.copyWith(portOfCall: 'GTSTC'))))));
    expect(find.text('Escala: GTSTC'), findsOneWidget);
    expect(
        find.text('1 se descargan · 1 se cargan · 1 de paso'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
