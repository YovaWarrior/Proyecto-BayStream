import 'dart:io';

import 'package:baystream/core/errors/exceptions.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/data/repositories/vessel_repository_impl.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_overview_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/local_profile_test_support.dart';

class _NoCloud implements FirebaseFirestore {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw StateError('Sin nube');
}

class _FixtureNotifier extends VoyageNotifier {
  final String source;
  _FixtureNotifier(this.source);
  @override
  Future<LoadFileResult> loadVesselFromFile() =>
      parseBaplieContent(source, fileName: 'T86_PRUEBA.edi');
}

class _ExistingVoyageNotifier extends VoyageNotifier {
  final VesselVoyage voyage;
  _ExistingVoyageNotifier(this.voyage);
  @override
  AsyncValue<VesselVoyage?> build() => AsyncValue.data(voyage);
}

void main() {
  final parser = BaplieParserService();
  final source = File('test/fixtures/t86_smdg21.edi').readAsStringSync();
  test('T-86 repositorio real conserva el código de rechazo sin usar Firebase',
      () async {
    final result = await VesselRepositoryImpl(firestore: _NoCloud())
        .parseBaplieFile(source.replaceFirst('SMDG21', 'SMDG15'));
    expect(
        result.fold((f) => f.code, (_) => null), 'unsupported_baplie_version');
  });
  for (final association in ['SMDG20', 'SMDG21', 'SMDG22']) {
    test('T-86 $association conserva todos los datos de la carga', () {
      final voyage = parser.parse(source.replaceFirst('SMDG21', association));
      expect(voyage.vessel.name, 'BUQUE PRUEBA');
      expect(voyage.voyageNumber, 'T86');
      expect(voyage.portOfOrigin, 'GTSTC');
      expect(voyage.portOfNextCall, 'PAMIT');
      expect(voyage.direction, VoyageDirection.export_);
      final c = voyage.containers.single;
      expect(c.containerId, 'TSTU0000086');
      expect(c.stowagePosition!.toIsoCode(), '0020182');
      expect(c.isoSizeType, '45R1');
      expect(c.status, ContainerStatus.full);
      expect(c.grossWeight, 24000);
      expect(c.vgmWeight, 24200.5);
      expect(c.tareWeight, 2185);
      expect(c.portOfLoading, 'GTSTC');
      expect(c.portOfDischarge, 'PAMIT');
      expect(c.operatorCode, 'TEST');
      expect(c.temperature, -18);
      expect(c.isReefer, isTrue);
      expect(c.dangerousGoods!.map((d) => d.unNumber), ['1993', '1760']);
      expect(c.dangerousGoods!.map((d) => d.hazardClass), ['3', '8']);
      expect(voyage.totalWeight, 24200.5);
    });
  }
  for (final identifier in [
    'BAPLIE:1:911:UN:SMDG15',
    'BAPLIE:D:13B:UN:SMDG31',
    'BAPLIE:D:95B:UN:SMDG99',
    'BAPLIE:D:96A:UN:SMDG21',
    'BAPLIE:1:95B:UN:SMDG21',
    'BAPLIE:D:95B:ZZ:SMDG21',
    'BAPLIE:D:95B:UN',
    'OTHER:D:95B:UN:SMDG21',
    'BAPLIE:D:95B:UN:SMDG21:EXTRA',
  ]) {
    test('T-86 rechaza $identifier antes de leer TDT o contenedores', () {
      // Sin TDT: el rechazo UNH debe preceder al error de nombre del buque.
      expect(
          () => parser.parse("UNH+TST86+$identifier'"
              "LOC+147+INVALID'EQD+CN+TSTU0000086+22G1+++5'"),
          throwsA(isA<BaplieParsingException>()
              .having((e) => e.code, 'código', 'unsupported_baplie_version')
              .having((e) => e.segment, 'segmento', 'UNH')
              .having(
                  (e) => e.message, 'versión declarada', contains(identifier))
              .having((e) => e.message, 'familia admitida',
                  contains('familia 2.x'))));
    });
  }
  for (final filename in ['t86_smdg31.edi', 't86_sin_unh.edi']) {
    test('T-86 fixture $filename rechazado en UNH', () {
      expect(
          () =>
              parser.parse(File('test/fixtures/$filename').readAsStringSync()),
          throwsA(isA<BaplieParsingException>()
              .having((e) => e.segment, 'segmento', 'UNH')));
    });
  }
  for (final header in [
    "UNH'",
    "UNHX+TST86+BAPLIE:D:95B:UN:SMDG21'",
    "UNH+TST86+'",
    "UNH+TST86+BAPLIE:D:95B:UN:SMDG21'UNH+OTHER+BAPLIE:1:911:UN:SMDG15'"
  ]) {
    test('T-86 cabecera incompleta o ambigua se rechaza: $header', () {
      expect(
          () => parser.parse(header),
          throwsA(isA<BaplieParsingException>()
              .having((e) => e.code, 'código', 'unsupported_baplie_version')));
    });
  }
  test('T-86 UNH dentro de carga no se interpreta como cabecera', () {
    expect(
        () => parser.parse("LOC+147+0020182'UNH+TST86+BAPLIE:D:95B:UN:SMDG21'"),
        throwsA(isA<BaplieParsingException>()
            .having((e) => e.segment, 'segmento', 'UNH')));
  });
  test(
      'T-86 notifier da archivo y versión sin abrir el almacén ni perder estado',
      () async {
    var storageOpened = false;
    final scope = ProviderContainer(overrides: [
      vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
      voyageNotifierProvider
          .overrideWith(() => _ExistingVoyageNotifier(parser.parse(source))),
      localVesselRepositoryProvider.overrideWith((ref) {
        storageOpened = true;
        throw StateError('Un archivo rechazado no llega al almacén');
      }),
    ]);
    addTearDown(scope.dispose);
    final notifier = scope.read(voyageNotifierProvider.notifier);
    final previous = scope.read(voyageNotifierProvider);
    final result = await notifier.parseBaplieContent(
        source.replaceFirst('SMDG21', 'SMDG31'),
        fileName: 'T86_3x.edi');
    expect(result.success, isFalse);
    expect(result.errorMessage, contains('T86_3x.edi'));
    expect(result.errorMessage, contains('BAPLIE:D:95B:UN:SMDG31'));
    expect(result.errorMessage, contains('familia 2.x'));
    expect(result.needsGeometry, isFalse);
    expect(result.needsIdentity, isFalse);
    expect(scope.read(voyageNotifierProvider), previous);
    expect(storageOpened, isFalse);
  });
  for (final association in ['SMDG15', 'SMDG31']) {
    testWidgets('T-86 aviso real a 360 dp: $association y archivo completos',
        (tester) async {
      final font = FontLoader('Roboto')
        ..addFont(rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
      await font.load();
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(ProviderScope(
          overrides: [
            vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
            voyageNotifierProvider.overrideWith(() =>
                _FixtureNotifier(source.replaceFirst('SMDG21', association))),
          ],
          child: MaterialApp(
              theme: ThemeData(fontFamily: 'Roboto'),
              home: const VesselOverviewPage())));
      await tester.tap(find.byTooltip('Cargar archivo BAPLIE'));
      await tester.pumpAndSettle();
      expect(find.textContaining('T86_PRUEBA.edi'), findsOneWidget);
      expect(find.textContaining(association), findsOneWidget);
      expect(find.textContaining('familia 2.x'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
