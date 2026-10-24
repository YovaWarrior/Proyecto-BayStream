import 'dart:io';

import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_overview_page.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/local_profile_test_support.dart';
import 'support/t74_movement_log_support.dart';
import 'support/t89_file_picker.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';

class _ExistingVoyage extends VoyageNotifier {
  final VesselVoyage voyage;
  _ExistingVoyage(this.voyage);
  @override
  AsyncValue<VesselVoyage?> build() => AsyncValue.data(voyage);
}

void main() {
  final source = File('test/fixtures/t86_smdg21.edi').readAsStringSync();
  final previousVoyage = BaplieParserService().parse(source);
  late T89FilePicker picker;
  FilePicker? original;
  setUp(() {
    try {
      original = FilePicker.platform;
    } catch (_) {
      original = null;
    }
    picker = T89FilePicker();
    FilePicker.platform = picker;
  });
  tearDown(() {
    if (original != null) FilePicker.platform = original!;
  });
  void pick(String name, String text) {
    final bytes = Uint8List.fromList(text.codeUnits);
    picker.result = FilePickerResult(
        [PlatformFile(name: name, size: bytes.length, bytes: bytes)]);
  }

  for (final name in ['T89_A07', 'T89_A07.txt', 'T89_A07.edi']) {
    test('T-89 $name recorre selector sin filtro y guarda tras confirmar',
        () async {
      final store = await testProfileStore();
      final scope = ProviderContainer(overrides: [
        vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
        localVesselRepositoryProvider
            .overrideWith((ref) async => store.repository),
        movementLogRepositoryProvider
            .overrideWith((ref) async => T74MemoryLog()),
      ]);
      addTearDown(() async {
        scope.dispose();
        await store.repository.close();
        await store.directory.delete(recursive: true);
      });
      pick(name, source);
      final notifier = scope.read(voyageNotifierProvider.notifier);
      final result = await notifier.loadVesselFromFile();
      expect(picker.requestedType, FileType.any);
      expect(picker.requestedExtensions, isNull);
      expect(picker.requestedData, isTrue);
      expect(result.fileName, name);
      expect(result.needsGeometry, isTrue);
      expect(notifier.publishedVoyage, isNull);
      expect((await store.repository.getAllVoyages()).getOrElse(() => []),
          isEmpty);
      expect(
          await notifier.confirmGeometry(notifier.currentProfile!.geometry,
              portOfCall: 'GTSTC',
              sourceKind: OperationSourceKind.loadingBaplie),
          isNull);
      expect(notifier.publishedVoyage!.containers.single.containerId,
          'TSTU0000086');
      expect(notifier.publishedVoyage!.totalWeight, 24200.5);
      expect(
          (await store.repository.getAllVoyages()).getOrElse(() => []).length,
          1);
    });
  }

  for (final content in [
    'Un texto corriente; UNB y UNH mencionados, sin segmentos.',
    "UNB+UNOA:2+TST+TST'",
    "UNH'",
    '\u0000\u0001\u0002',
    '',
  ]) {
    test(
        'T-89 sin cabecera legible no abre almacén ni sustituye viaje: ${content.length}',
        () async {
      var storageOpened = false;
      final scope = ProviderContainer(overrides: [
        vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
        voyageNotifierProvider
            .overrideWith(() => _ExistingVoyage(previousVoyage)),
        localVesselRepositoryProvider.overrideWith((ref) {
          storageOpened = true;
          throw StateError('Un rechazo no toca el almacén');
        }),
      ]);
      addTearDown(scope.dispose);
      final previous = scope.read(voyageNotifierProvider);
      pick('T89_NO_BAPLIE.bin', content);
      final notifier = scope.read(voyageNotifierProvider.notifier);
      final result = await notifier.loadVesselFromFile();
      expect(result.success, isFalse);
      expect(result.errorMessage, contains('Este archivo no parece un BAPLIE'));
      expect(result.needsGeometry, isFalse);
      expect(result.needsIdentity, isFalse);
      expect(notifier.pendingVoyage, isNull);
      expect(scope.read(voyageNotifierProvider), same(previous));
      expect(storageOpened, isFalse);
    });
  }
  // T-103: la 1.5 se lee; el rechazo de la 1.x se prueba con una sintética.
  for (final identifier in [
    'BAPLIE:1:911:UN:SMDG10',
    'BAPLIE:D:13B:UN:SMDG31'
  ]) {
    test('T-89 cabecera $identifier conserva el aviso de T-86 sin almacenar',
        () async {
      var storageOpened = false;
      final scope = ProviderContainer(overrides: [
        vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
        voyageNotifierProvider
            .overrideWith(() => _ExistingVoyage(previousVoyage)),
        localVesselRepositoryProvider.overrideWith((ref) {
          storageOpened = true;
          throw StateError('Versión rechazada');
        }),
      ]);
      addTearDown(scope.dispose);
      final previous = scope.read(voyageNotifierProvider);
      pick('T89_VERSION',
          source.replaceFirst('BAPLIE:D:95B:UN:SMDG21', identifier));
      final result = await scope
          .read(voyageNotifierProvider.notifier)
          .loadVesselFromFile();
      expect(result.errorMessage, contains('T89_VERSION'));
      expect(result.errorMessage, contains(identifier));
      expect(result.errorMessage, contains('familia 2.x'));
      expect(result.errorMessage, isNot(contains('no parece')));
      expect(scope.read(voyageNotifierProvider), same(previous));
      expect(storageOpened, isFalse);
    });
  }
  test('T-89 cancelar cualquier archivo conserva viaje y no abre almacén',
      () async {
    final scope = ProviderContainer(overrides: [
      voyageNotifierProvider
          .overrideWith(() => _ExistingVoyage(previousVoyage)),
      localVesselRepositoryProvider
          .overrideWith((ref) => throw StateError('No abrir')),
    ]);
    addTearDown(scope.dispose);
    final previous = scope.read(voyageNotifierProvider);
    expect(
        (await scope.read(voyageNotifierProvider.notifier).loadVesselFromFile())
            .isCancelled,
        isTrue);
    expect(scope.read(voyageNotifierProvider), same(previous));
  });
  testWidgets('T-89 aviso del producto a 360 dp conserva el estado sin viaje',
      (tester) async {
    final font = FontLoader('Roboto')
      ..addFont(rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    await font.load();
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    pick('T89_TEXTO.txt', 'Texto sin cabecera');
    await tester.pumpWidget(ProviderScope(
        overrides: [
          vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
          localVesselRepositoryProvider
              .overrideWith((ref) => throw StateError('No abrir')),
        ],
        child: MaterialApp(
            theme: ThemeData(fontFamily: 'Roboto'),
            home: const VesselOverviewPage())));
    // Fase 3 (10.9): en el inicio la carga es «Seleccionar archivo».
      await tester.tap(find.byKey(const ValueKey('select-file')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Este archivo no parece un BAPLIE'),
        findsOneWidget);
    final scope = ProviderScope.containerOf(
        tester.element(find.byType(VesselOverviewPage)));
    expect(scope.read(voyageNotifierProvider).value, isNull);
    expect(tester.takeException(), isNull);
  });
}
