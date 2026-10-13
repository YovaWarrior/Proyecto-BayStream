import 'package:baystream/core/errors/failures.dart';
import 'package:baystream/features/vessel/data/datasources/hive_vessel_data_source.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_impl.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/providers/plan_toolbar_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/loading_plan_controls.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/local_profile_test_support.dart';
import 'support/t91_toolbar_support.dart';

class _FailedSave extends LocalVesselRepositoryImpl {
  _FailedSave(super.source);
  @override
  Future<Either<Failure, void>> setPlanToolbarCollapsed(bool collapsed) async =>
      const Left(CacheFailure(message: 'Fallo sintético de escritura'));
}

class _UnavailableSettings extends T91MemorySettings {
  @override
  Future<Either<Failure, bool>> getPlanToolbarCollapsed() async =>
      const Left(CacheFailure(message: 'Fallo sintético de lectura'));
  @override
  Future<Either<Failure, void>> setPlanToolbarCollapsed(bool collapsed) async =>
      const Left(CacheFailure(message: 'Fallo sintético de escritura'));
}

void main() {
  final parsed = BaplieParserService().parse("UNH+1+BAPLIE:D:95B:UN:SMDG22'"
      "TDT+20+T91+++TST:172:20+++9000091:146:11:BUQUE PRUEBA'"
      "LOC+5+HNPCR:139:6'LOC+61+GTSTC:139:6'"
      "LOC+147+0020182::5'LOC+9+HNPCR:139:6'LOC+11+GTSTC:139:6'"
      "MEA+AAE+VGM+KGM:20000'EQD+CN+TSTU0000091+42G1+++5'"
      "LOC+147+0060182::5'LOC+9+HNPCR:139:6'LOC+11+GTSTC:139:6'"
      "MEA+AAE+VGM+KGM:21000'EQD+CN+TSTU0000092+42G1+++5'");
  final voyage = parsed.withGeometry(
      VesselProfile.proposeFrom(parsed)
          .geometry
          .copyWith(portRows: 10, starboardRows: 10),
      portOfCall: 'GTSTC');

  test('T-91 ajuste sobrevive reapertura, retencion y borrado de viajes',
      () async {
    final store = await testProfileStore();
    await store.repository.close();
    Future<LocalVesselRepositoryImpl> open(String namespace) async =>
        LocalVesselRepositoryImpl(await HiveVesselDataSource.open(
            directory: store.directory.path, namespace: namespace));
    var local = await open('t91');
    try {
      expect((await local.getPlanToolbarCollapsed()).getOrElse(() => false),
          isTrue);
      await local.setLastConfirmedPortOfCall('GTSTC');
      await local.setPlanToolbarCollapsed(false);
      for (var i = 0; i < 6; i++) {
        await local.saveVoyage(voyage.copyWith(id: 'viaje-$i'));
      }
      for (final saved in (await local.getAllVoyages()).getOrElse(() => [])) {
        await local.deleteVoyage(saved.id);
      }
      await local.close();
      local = await open('t91');
      expect((await local.getPlanToolbarCollapsed()).getOrElse(() => true),
          isFalse);
      expect((await local.getLastConfirmedPortOfCall()).getOrElse(() => null),
          'GTSTC');
      await local.setPlanToolbarCollapsed(true);
      await local.close();
      local = await open('t91');
      expect((await local.getPlanToolbarCollapsed()).getOrElse(() => false),
          isTrue);
      final other = await open('t91_otro');
      await other.setPlanToolbarCollapsed(false);
      expect((await local.getPlanToolbarCollapsed()).getOrElse(() => false),
          isTrue);
      await other.close();
    } finally {
      await local.close();
      await store.directory.delete(recursive: true);
    }
  });

  test('T-91 toques rapidos persisten la ultima eleccion', () async {
    final store = await testProfileStore();
    final scope = ProviderContainer(overrides: [
      localVesselRepositoryProvider
          .overrideWith((ref) async => store.repository),
    ]);
    try {
      await scope.read(planToolbarCollapsedProvider.future);
      final notifier = scope.read(planToolbarCollapsedProvider.notifier);
      await Future.wait(
          [notifier.toggle(), notifier.toggle(), notifier.toggle()]);
      expect(scope.read(planToolbarCollapsedProvider).value, isFalse);
      expect(
          (await store.repository.getPlanToolbarCollapsed())
              .getOrElse(() => true),
          isFalse);
    } finally {
      scope.dispose();
      await store.repository.close();
      await store.directory.delete(recursive: true);
    }
  });

  test('T-91 error al guardar informa el fallo y deja accesibles las acciones',
      () async {
    final store = await testProfileStore();
    await store.repository.close();
    final local = _FailedSave(await HiveVesselDataSource.open(
        directory: store.directory.path, namespace: 't91_fallo'));
    final scope = ProviderContainer(overrides: [
      localVesselRepositoryProvider.overrideWith((ref) async => local),
    ]);
    try {
      await scope.read(planToolbarCollapsedProvider.future);
      await expectLater(
          scope.read(planToolbarCollapsedProvider.notifier).toggle(),
          throwsA(isA<Exception>()));
      expect(scope.read(planToolbarCollapsedProvider).value, isFalse);
    } finally {
      scope.dispose();
      await local.close();
      await store.directory.delete(recursive: true);
    }
  });

  test('T-91 ajuste inaccesible permite desplegar y avisa al guardar',
      () async {
    final scope = ProviderContainer(overrides: [
      localVesselRepositoryProvider
          .overrideWith((ref) async => _UnavailableSettings()),
    ]);
    addTearDown(scope.dispose);
    await expectLater(scope.read(planToolbarCollapsedProvider.future),
        throwsA(isA<Exception>()));
    await expectLater(
        scope.read(planToolbarCollapsedProvider.notifier).toggle(),
        throwsA(isA<Exception>()));
    expect(scope.read(planToolbarCollapsedProvider).value, isFalse);
  });

  for (final brightness in Brightness.values) {
    testWidgets(
        'T-91 plegada a 360 dp, tema ${brightness.name}, acciones y vista conservadas',
        (tester) async {
      final local = T91MemorySettings();
      final scope = await pumpT91Plan(tester, voyage, local, brightness);
      tester.view.physicalSize = const Size(360, 800);
      await tester.pumpAndSettle();
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.actions, hasLength(1));
      expect(appBar.automaticallyImplyLeading, isFalse);
      expect(find.byTooltip('Desplegar acciones'), findsOneWidget);
      for (final action in t91ActionTooltips) {
        expect(
            find.descendant(
                of: find.byType(AppBar), matching: find.byTooltip(action)),
            findsNothing);
      }
      expect(tester.takeException(), isNull);
      // La aceptación del Honor detectó que el botón quedaba fuera de pantalla
      // al desplegar. Se conserva fijo aun con objetivos táctiles de 48 dp.
      await tester.tap(find.byTooltip('Desplegar acciones'));
      await tester.pumpAndSettle();
      final toggleRect =
          tester.getRect(find.byKey(const ValueKey('toggle-plan-toolbar')));
      expect(toggleRect.left, greaterThanOrEqualTo(0));
      expect(toggleRect.right, lessThanOrEqualTo(360));
      final strip = find.byKey(const ValueKey('plan-toolbar-actions'));
      await tester.drag(strip, const Offset(-250, 0));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Limpiar datos').hitTestable(), findsOneWidget);
      await tester.tap(find.byTooltip('Plegar acciones'));
      await tester.pumpAndSettle();
      expect(tester.widget<AppBar>(find.byType(AppBar)).actions, hasLength(1));
      expect(tester.takeException(), isNull);
      tester.view.physicalSize = const Size(1200, 900);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Desplegar acciones'));
      await tester.pumpAndSettle();
      for (final action in t91ActionTooltips) {
        expect(
            find.descendant(
                of: find.byType(AppBar), matching: find.byTooltip(action)),
            findsOneWidget);
      }
      await tester.tap(find.byTooltip('Plegar acciones'));
      await tester.pumpAndSettle();
      for (final mode in BayPlanMode.values) {
        await checkT91Toggle(tester, scope, voyage, mode);
      }
      await tester.tap(find.text('Lista'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('toggle-plan-toolbar')), findsNothing);
      expect(find.byTooltip('Cargar archivo BAPLIE'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
