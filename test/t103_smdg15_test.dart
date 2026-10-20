import 'dart:io';

import 'package:baystream/core/errors/exceptions.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_impl.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/formatters/vessel_error_message.dart';
import 'package:baystream/features/vessel/presentation/pages/departure_baplie_page.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_operation_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/voyage_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/local_profile_test_support.dart';
import 'support/t74_movement_log_support.dart';
import 'support/t82_fixture.dart';

class _ExistingVoyageNotifier extends VoyageNotifier {
  final VesselVoyage voyage;
  _ExistingVoyageNotifier(this.voyage);
  @override
  AsyncValue<VesselVoyage?> build() => AsyncValue.data(voyage);
}

/// T-103 · La 1.5 (SMDG15) se lee con las reglas de 2.x y lo avisa; el resto
/// de la 1.x, la 3.x y lo que no tiene UNH se rechazan como en T-86.
/// T-112: con identificador, el mensaje nombra la cabecera UNH.
String _declared(String version) =>
    version.startsWith('sin UNH') ? version : 'la cabecera UNH declara $version';

void main() {
  final parser = BaplieParserService();
  final smdg21 = File('test/fixtures/t86_smdg21.edi').readAsStringSync();
  final smdg15 =
      smdg21.replaceFirst('BAPLIE:D:95B:UN:SMDG21', smdg15MessageIdentifier);
  // Una 1.x sintética distinta de la 1.5.
  final smdg10 =
      smdg21.replaceFirst('BAPLIE:D:95B:UN:SMDG21', 'BAPLIE:1:911:UN:SMDG10');

  test('T-103 la 1.5 se lee completa, con la marca del aviso', () {
    final voyage = parser.parse(smdg15);
    final reference = parser.parse(smdg21);
    expect(voyage.metadata!.messageVersion, '1');
    expect(voyage.metadata!.readWithV2Rules, isTrue);
    expect(reference.metadata!.readWithV2Rules, isFalse);
    // Las reglas de 2.x dan lo mismo que en la 2.x de la que sale.
    expect(voyage.vessel.name, reference.vessel.name);
    expect(voyage.voyageNumber, reference.voyageNumber);
    expect(voyage.portOfOrigin, reference.portOfOrigin);
    expect(voyage.portOfNextCall, reference.portOfNextCall);
    expect(voyage.containers.map((c) => c.copyWith(id: '')),
        reference.containers.map((c) => c.copyWith(id: '')));
    expect(voyage.totalWeight, 24200.5);
    expect(voyage.containers.single.dangerousGoods!.map((d) => d.unNumber),
        ['1993', '1760']);
  });

  test('T-103 solo la cabecera exacta de la 1.5 se reconoce en una fuente', () {
    expect(declaresSmdg15(smdg15), isTrue);
    expect(declaresSmdg15(smdg15.replaceAll("'", "'\r\n")), isTrue);
    for (final other in [
      smdg21,
      smdg10,
      smdg21.replaceFirst('SMDG21', 'SMDG15'),
      smdg21.replaceFirst('BAPLIE:D:95B:UN:SMDG21', 'BAPLIE:1:912:UN:SMDG15'),
      File('test/fixtures/t86_sin_unh.edi').readAsStringSync(),
    ]) {
      expect(declaresSmdg15(other), isFalse);
    }
  });

  for (final (name, content, version) in [
    ('T103_1x.edi', smdg10, 'BAPLIE:1:911:UN:SMDG10'),
    (
      't86_smdg31.edi',
      File('test/fixtures/t86_smdg31.edi').readAsStringSync(),
      'BAPLIE:D:13B:UN:SMDG31'
    ),
    (
      't86_sin_unh.edi',
      File('test/fixtures/t86_sin_unh.edi').readAsStringSync(),
      'sin UNH/S009 reconocible'
    ),
  ]) {
    test('T-103 $name se rechaza con el mensaje de T-86 y conserva el viaje',
        () async {
      const t86 = 'BayStream lee la familia 2.x (SMDG20, SMDG21 y SMDG22). '
          'Pide una exportación compatible.';
      expect(
          () => parser.parse(content),
          throwsA(isA<BaplieParsingException>()
              .having((e) => e.code, 'código', 'unsupported_baplie_version')
              .having((e) => e.message, 'mensaje',
                  'Versión BAPLIE no admitida: ${_declared(version)}. $t86')));
      var storageOpened = false;
      final scope = ProviderContainer(overrides: [
        vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
        voyageNotifierProvider
            .overrideWith(() => _ExistingVoyageNotifier(parser.parse(smdg15))),
        localVesselRepositoryProvider.overrideWith((ref) {
          storageOpened = true;
          throw StateError('Un archivo rechazado no llega al almacén');
        }),
      ]);
      addTearDown(scope.dispose);
      final previous = scope.read(voyageNotifierProvider);
      final result = await scope
          .read(voyageNotifierProvider.notifier)
          .parseBaplieContent(content, fileName: name);
      // Sin UNH, la pantalla dice lo de T-89: no parece un BAPLIE.
      expect(
          result.errorMessage,
          version.startsWith('sin UNH')
              ? 'Archivo «$name»: $notBaplieFileMessage'
              : 'Archivo «$name»: Versión BAPLIE no admitida: '
                  '${_declared(version)}. $t86');
      expect(result.needsGeometry, isFalse);
      expect(result.needsIdentity, isFalse);
      expect(scope.read(voyageNotifierProvider), previous);
      expect(storageOpened, isFalse);
    });
  }

  group('T-103 con almacén real en temporal', () {
    late ProviderContainer container;
    late VoyageNotifier notifier;
    late ({Directory directory, LocalVesselRepositoryImpl repository}) store;
    setUp(() async {
      store = await testProfileStore();
      container = ProviderContainer(overrides: [
        movementLogRepositoryProvider
            .overrideWith((ref) async => T74MemoryLog()),
        vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
        localVesselRepositoryProvider
            .overrideWith((ref) async => store.repository),
      ]);
      notifier = container.read(voyageNotifierProvider.notifier);
    });
    tearDown(() async {
      container.dispose();
      await store.repository.close();
      await store.directory.delete(recursive: true);
    });

    test('la 1.5 se publica con aviso y lo conserva al reabrir de Recientes',
        () async {
      final first = await notifier.parseBaplieContent(
          profileTestEdi.replaceFirst(
              'BAPLIE:D:95B:UN:SMDG20', smdg15MessageIdentifier),
          fileName: 'T103_15.edi');
      expect(first.needsGeometry, isTrue);
      expect(await notifier.confirmGeometry(notifier.currentProfile!.geometry),
          isNull);
      final published = notifier.publishedVoyage!;
      expect(published.metadata!.readWithV2Rules, isTrue);
      notifier.clearVoyage();
      expect(notifier.publishedVoyage, isNull);
      expect(await notifier.openRecentVoyage(published.id), isNull);
      expect(notifier.publishedVoyage!.id, published.id);
      expect(notifier.publishedVoyage!.metadata!.readWithV2Rules, isTrue);
      expect(notifier.publishedVoyage!.totalContainers, 1);
    });
  });

  for (final brightness in Brightness.values) {
    testWidgets('T-103 resumen a 360 dp ${brightness.name}: aviso solo en 1.5',
        (tester) async {
      final font = FontLoader('Roboto')
        ..addFont(rootBundle.load('assets/fonts/Roboto-Regular.ttf'))
        ..addFont(rootBundle.load('assets/fonts/Roboto-Medium.ttf'));
      await font.load();
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      Future<void> pump(String source) => tester.pumpWidget(MaterialApp(
          theme: ThemeData(
              brightness: brightness, useMaterial3: true, fontFamily: 'Roboto'),
          home: Scaffold(
              body: SingleChildScrollView(
                  child: VoyageSummaryCard(voyage: parser.parse(source))))));
      await pump(smdg15);
      expect(find.text(smdg15Notice), findsOneWidget);
      expect(find.text('Versión 1.5 (la cabecera UNH declara SMDG15), leída con '
          'las reglas de 2.x; revisa pesos y peligrosas'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await pump(smdg21);
      expect(find.byKey(const ValueKey('voyage-smdg15-notice')), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  for (final kind in [
    OperationSourceKind.loadingBaplie,
    OperationSourceKind.arrivalBaplie
  ]) {
    testWidgets('T-103 la salida de T-82 se niega con una fuente 1.5 (${kind.wire})',
        (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final operation = t82Operation.copyWith(sources: [
        for (final source in t82Operation.sources)
          source.kind == kind
              ? OperationSource(
                  kind: kind,
                  fileName: 'A06.edi',
                  content: source.content.replaceFirst(
                      'BAPLIE:D:95B:UN:SMDG20', smdg15MessageIdentifier))
              : source
      ]);
      await tester.pumpWidget(ProviderScope(
          overrides: [
            operatorProvider.overrideWith((ref) => Stream.value(null)),
            activeOperationProvider.overrideWith((ref) async => operation),
            loadingOperationProvider(t82Loading)
                .overrideWith((ref) => Stream.value(t82Derive())),
          ],
          child: MaterialApp(home: DepartureBapliePage(voyage: t82Loading))));
      await tester.pumpAndSettle();
      expect(
          find.text('No se genera el BAPLIE de salida: «A06.edi» es versión 1.5 '
              '(SMDG15) y se leyó con las reglas de 2.x. Escribir la salida con '
              'esas reglas no sería fiel a lo que llegó. Importa el plano en '
              'SMDG20, SMDG21 o SMDG22.'),
          findsOneWidget);
      expect(find.byKey(const ValueKey('departure-save')), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
