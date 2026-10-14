import 'dart:io';

import 'package:baystream/core/app.dart';
import 'package:baystream/core/errors/failures.dart';
import 'package:baystream/features/vessel/data/datasources/hive_vessel_data_source.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_impl.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/app_theme_preference.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/pages/parameters_page.dart';
import 'package:baystream/features/vessel/presentation/providers/theme_preference_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/containers_list_view.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

import 'support/local_profile_test_support.dart';
import 'support/t91_toolbar_support.dart';

class T90MemorySettings extends T91MemorySettings {
  AppThemePreference theme = AppThemePreference.system;
  bool fail = false;
  @override
  Future<Either<Failure, AppThemePreference>> getThemePreference() async => Right(theme);
  @override
  Future<Either<Failure, void>> setThemePreference(AppThemePreference value) async {
    if (fail) return const Left(CacheFailure(message: 'Fallo sintético'));
    theme = value;
    return const Right(null);
  }
}

final t90Voyage = (() {
  final parsed = BaplieParserService().parse("UNH+1+BAPLIE:D:95B:UN:SMDG22'"
      "TDT+20+T90+++TST:172:20+++9000090:146:11:BUQUE PRUEBA'"
      "LOC+5+HNPCR:139:6'LOC+61+GTSTC:139:6'"
      "LOC+147+0020182::5'LOC+9+HNPCR:139:6'LOC+11+GTSTC:139:6'"
      "MEA+AAE+VGM+KGM:20000'EQD+CN+TSTU0000090+42R1+++5'TMP+2+3:CEL'"
      "LOC+147+0020382::5'LOC+9+HNPCR:139:6'LOC+11+GTSTC:139:6'"
      "MEA+AAE+VGM+KGM:21000'EQD+CN+TSTU0000091+42G1+++5'DGS+IMD+3+1203'");
  return parsed.withGeometry(VesselProfile.proposeFrom(parsed).geometry, portOfCall: 'GTSTC');
})();

double t90Contrast(Color foreground, Color background) {
  final a = foreground.computeLuminance(), b = background.computeLuminance();
  return a > b ? (a + 0.05) / (b + 0.05) : (b + 0.05) / (a + 0.05);
}

void main() {
  test('T-90 tres temas persisten sin cambiar viaje, puerto ni barra', () async {
    final directory = await Directory.systemTemp.createTemp('t90_');
    Future<LocalVesselRepositoryImpl> open(String namespace) async =>
        LocalVesselRepositoryImpl(await HiveVesselDataSource.open(directory: directory.path, namespace: namespace));
    var local = await open('t90');
    try {
      expect((await local.getThemePreference()).getOrElse(() => AppThemePreference.dark), AppThemePreference.system);
      await local.saveVoyage(t90Voyage);
      await local.setLastConfirmedPortOfCall('GTSTC');
      await local.setPlanToolbarCollapsed(false);
      final voyageBytes = await File('${directory.path}/t90_voyages.hive').readAsBytes();
      for (final preference in AppThemePreference.values) {
        await local.setThemePreference(preference);
        await local.close();
        local = await open('t90');
        expect((await local.getThemePreference()).getOrElse(() => AppThemePreference.dark), preference);
        expect((await local.getLastConfirmedPortOfCall()).getOrElse(() => null), 'GTSTC');
        expect((await local.getPlanToolbarCollapsed()).getOrElse(() => true), isFalse);
        expect((await local.getAllVoyages()).getOrElse(() => []), [t90Voyage]);
        expect(await File('${directory.path}/t90_voyages.hive').readAsBytes(), voyageBytes);
      }
      final other = await open('t90_otro');
      expect((await other.getThemePreference()).getOrElse(() => AppThemePreference.dark), AppThemePreference.system);
      await other.close();
    } finally {
      await local.close();
      await directory.delete(recursive: true);
    }
  });

  test('T-90 ajuste desconocido vuelve a sistema y se puede corregir', () async {
    final directory = await Directory.systemTemp.createTemp('t90_invalid_');
    final box = await Hive.openBox<String>('t90_invalid_settings', path: directory.path);
    await box.put('themePreference', 'valor antiguo desconocido');
    await box.close();
    final local = LocalVesselRepositoryImpl(await HiveVesselDataSource.open(directory: directory.path, namespace: 't90_invalid'));
    try {
      expect((await local.getThemePreference()).getOrElse(() => AppThemePreference.dark), AppThemePreference.system);
      await local.setThemePreference(AppThemePreference.light);
      expect((await local.getThemePreference()).getOrElse(() => AppThemePreference.dark), AppThemePreference.light);
    } finally {
      await local.close();
      await directory.delete(recursive: true);
    }
  });

  test('T-90 elecciones rápidas guardan la última en la cola local', () async {
    final store = await testProfileStore();
    final scope = ProviderContainer(overrides: [localVesselRepositoryProvider.overrideWith((ref) async => store.repository)]);
    try {
      await scope.read(themePreferenceProvider.future);
      final notifier = scope.read(themePreferenceProvider.notifier);
      await Future.wait([notifier.select(AppThemePreference.light), notifier.select(AppThemePreference.dark), notifier.select(AppThemePreference.system)]);
      expect(scope.read(themePreferenceProvider).value, AppThemePreference.system);
      expect((await store.repository.getThemePreference()).getOrElse(() => AppThemePreference.dark), AppThemePreference.system);
    } finally {
      scope.dispose();
      await store.repository.close();
      await store.directory.delete(recursive: true);
    }
  });

  testWidgets('T-90 selector real, sistema responde y elección explícita prevalece', (tester) async {
    final local = T90MemorySettings();
    tester.binding.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.binding.platformDispatcher.clearPlatformBrightnessTestValue);
    await tester.pumpWidget(ProviderScope(overrides: [localVesselRepositoryProvider.overrideWith((ref) async => local)], child: const BayStreamApp(home: ParametersPage())));
    await tester.pumpAndSettle();
    Brightness brightness() => Theme.of(tester.element(find.byType(ParametersPage))).brightness;
    expect(brightness(), Brightness.dark);
    tester.binding.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    await tester.pumpAndSettle();
    expect(brightness(), Brightness.light);
    for (final preference in [AppThemePreference.dark, AppThemePreference.light, AppThemePreference.system]) {
      await tester.tap(find.byType(DropdownButtonFormField<AppThemePreference>));
      await tester.pumpAndSettle();
      final label = switch (preference) { AppThemePreference.light => 'Claro', AppThemePreference.dark => 'Oscuro', AppThemePreference.system => 'Seguir al sistema' };
      await tester.tap(find.text(label).last);
      await tester.pumpAndSettle();
      expect(local.theme, preference);
      tester.binding.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      await tester.pumpAndSettle();
      expect(brightness(), preference == AppThemePreference.light ? Brightness.light : Brightness.dark);
      tester.binding.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      await tester.pumpAndSettle();
      expect(brightness(), preference == AppThemePreference.dark ? Brightness.dark : Brightness.light);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('T-90 fallo de guardado se informa y permite elegir de nuevo', (tester) async {
    final local = T90MemorySettings()..fail = true;
    await tester.pumpWidget(ProviderScope(overrides: [localVesselRepositoryProvider.overrideWith((ref) async => local)], child: const BayStreamApp(home: ParametersPage())));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<AppThemePreference>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Oscuro').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('No se pudo guardar el tema.'), findsOneWidget);
    expect(local.theme, AppThemePreference.system);
    local.fail = false;
    await tester.tap(find.byType(DropdownButtonFormField<AppThemePreference>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Claro').last);
    await tester.pumpAndSettle();
    expect(local.theme, AppThemePreference.light);
    expect(tester.takeException(), isNull);
  });

  for (final brightness in Brightness.values) {
    testWidgets('T-90 ${brightness.name}: contraste de pesos, reefer e IMO', (tester) async {
      final scope = await pumpT91Plan(tester, t90Voyage, T91MemorySettings(), brightness);
      scope.read(selectedBayProvider.notifier).select(2);
      await tester.pumpAndSettle();
      final weights = find.byKey(const ValueKey('peso-celda'));
      expect(weights, findsNWidgets(2));
      for (final element in weights.evaluate()) {
        final text = element.widget as Text;
        final cells = find.ancestor(of: find.byWidget(text), matching: find.byWidgetPredicate((w) => w is Container && w.constraints?.maxWidth == 50 && w.constraints?.maxHeight == 40));
        final cell = tester.widget<Container>(cells.first);
        expect(t90Contrast(text.style!.color!, (cell.decoration! as BoxDecoration).color!), greaterThanOrEqualTo(4.5));
      }
      await tester.pumpWidget(MaterialApp(theme: ThemeData(brightness: brightness, useMaterial3: true), home: Scaffold(body: ContainersListView(containers: [t90Voyage.containers.first]))));
      await tester.pumpAndSettle();
      await tester.tap(find.text(t90Voyage.containers.first.containerId));
      await tester.pumpAndSettle();
      final heading = tester.widget<Text>(find.text('CONTENEDOR REFRIGERADO'));
      final scheme = Theme.of(tester.element(find.text('CONTENEDOR REFRIGERADO'))).colorScheme;
      expect(t90Contrast(heading.style!.color!, scheme.surface), greaterThanOrEqualTo(4.5));
      expect(tester.takeException(), isNull);
    });
  }
}
