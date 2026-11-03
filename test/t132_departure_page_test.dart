import 'dart:io';
import 'dart:ui' as ui;
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/departure_export_repository.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';
import 'package:baystream/features/vessel/presentation/pages/departure_baplie_page.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_operation_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/t132_fixture.dart';

class _Save implements DepartureExportRepository {
  String? text;
  int calls = 0;
  @override
  Future<String?> save(Operation operation, String edi) async {
    calls++;
    text = edi;
    return 't132.edi';
  }
}

class _LiveData extends Notifier<LoadingOperation> {
  _LiveData(this.initial);
  final LoadingOperation initial;
  @override
  LoadingOperation build() => initial;
  void update(LoadingOperation data) => state = data;
}

T132Fixture _fixture({
  String un = '2903',
  String line = 'TEST',
  String charset = 'UNOC',
}) =>
    T132Fixture(
      cargo:
          "${t132Group(1)}$t132Dgs'${t132Group(2, extra: "TMP+2+-18:CEL'")}${t132Group(3)}",
      rows: [
        t132Row(1, hazard: '6.1', uns: [un], line: line),
        t132Row(2, temperature: '-20'),
        t132Row(3, hazard: '9', uns: ['3082']),
        t132Row(4, contents: 'REEMPLAZO - CANCEL'),
        t132Row(5),
      ],
      loaded: [1, 2, 3],
      charset: charset,
    );

Future<ProviderContainer> _mount(
  WidgetTester tester,
  T132Fixture fixture,
  _Save save, {
  Brightness brightness = Brightness.light,
  double scale = 1,
  GlobalKey? boundary,
  NotifierProvider<_LiveData, LoadingOperation>? live,
}) async {
  final font = FontLoader('Roboto')
    ..addFont(rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
  await font.load();
  final scope = ProviderContainer(
    overrides: [
      operatorProvider.overrideWith((ref) => Stream.value(null)),
      activeOperationProvider.overrideWith((ref) async => fixture.operation),
      loadingOperationProvider(fixture.voyage).overrideWith(
        (ref) => Stream.value(live == null ? fixture.data : ref.watch(live)),
      ),
      departureExportRepositoryProvider.overrideWithValue(save),
    ],
  );
  addTearDown(scope.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: scope,
      child: RepaintBoundary(
        key: boundary,
        child: MaterialApp(
          theme: ThemeData(
            brightness: brightness,
            useMaterial3: true,
            fontFamily: 'Roboto',
          ),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: DepartureBapliePage(voyage: fixture.voyage),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return scope;
}

Future<void> _tap(WidgetTester tester, String key) async {
  final finder = find.byKey(ValueKey(key));
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _capture(WidgetTester tester, GlobalKey key, String name) async {
  if (!const bool.fromEnvironment('T132_CAPTURES')) return;
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final directory = Directory('build/t132/capturas');
    await directory.create(recursive: true);
    await File(
      '${directory.path}/$name.png',
    ).writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  for (final width in [360.0, 1920.0]) {
    for (final brightness in Brightness.values) {
      for (final scale in [1.0, 2.0]) {
        testWidgets(
          'T-132 página $width ${brightness.name} letra $scale: elegir y guardar',
          (tester) async {
            tester.view.physicalSize = Size(width, 1080);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.reset);
            final fixture = _fixture();
            final save = _Save();
            final boundary = GlobalKey();
            await _mount(
              tester,
              fixture,
              save,
              brightness: brightness,
              scale: scale,
              boundary: boundary,
            );
            final saveButton = find.byKey(const ValueKey('departure-save'));
            expect(tester.widget<FilledButton>(saveButton).onPressed, isNull);
            expect(
              find.text('El plan dice UN 2902; el listado, UN 2903'),
              findsOneWidget,
            );
            expect(
              find.text('El plan dice -18 °C; el listado, -20 °C'),
              findsOneWidget,
            );
            expect(
              find.textContaining(
                'solo el listado declara mercancías peligrosas',
              ),
              findsOneWidget,
            );
            await _capture(
              tester,
              boundary,
              '${width.toInt()}_${brightness.name}_${scale}_revision',
            );
            await _tap(
              tester,
              'departure-choice-TSTU0001321-Mercancías peligrosas-list',
            );
            expect(
              tester.widget<FilledButton>(saveButton).onPressed,
              isNull,
              reason: 'falta resolver otro contenedor',
            );
            await _tap(
              tester,
              'departure-choice-TSTU0001322-Temperatura del refrigerado-plan',
            );
            expect(
              tester.widget<FilledButton>(saveButton).onPressed,
              isNotNull,
            );
            await _tap(tester, 'departure-save');
            expect(save.calls, 1);
            expect(save.text, contains(t132Dgs.replaceFirst('2902', '2903')));
            expect(save.text, contains('TMP+2+-18:CEL'));
            expect(save.text, contains('DGS+IMD+9+3082'));
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }
  testWidgets(
    'T-132 la página copia todas las filas que no cargaron con sus motivos',
    (tester) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await _mount(tester, _fixture(), _Save());
      expect(
        find.text('Filas del listado que no cargaron (2)'),
        findsOneWidget,
      );
      await _tap(tester, 'departure-copy-not-loaded');
      expect(
        copied,
        'OR 4 · TSTU0001324 · cancelado en el listado\nOR 5 · TSTU0001325 · sin celda en el plan',
      );
      expect(find.text('Lista de filas no cargadas copiada'), findsOneWidget);
    },
  );
  testWidgets('T-132 la página identifica carácter, campo y fila y no guarda', (
    tester,
  ) async {
    final f = T132Fixture(
      cargo: t132Group(1),
      rows: [t132Row(1, line: 'LÍNEA')],
      charset: 'UNOA',
    );
    final save = _Save();
    await _mount(tester, f, save);
    expect(
      find.textContaining(
        'fila 6 · OPR: el carácter «Í» (U+00CD) no cabe en UNOA',
      ),
      findsOneWidget,
    );
    expect(find.text('Datos que impiden guardar'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const ValueKey('departure-save')))
          .onPressed,
      isNull,
    );
    expect(save.calls, 0);
  });
  testWidgets(
    'T-132 un listado actualizado invalida decisiones de la vista previa',
    (tester) async {
      final fixture = _fixture();
      final live = NotifierProvider<_LiveData, LoadingOperation>(
        () => _LiveData(fixture.data),
      );
      final save = _Save();
      final scope = await _mount(tester, fixture, save, live: live);
      await _tap(
        tester,
        'departure-choice-TSTU0001321-Mercancías peligrosas-list',
      );
      await _tap(
        tester,
        'departure-choice-TSTU0001322-Temperatura del refrigerado-plan',
      );
      expect(
        tester
            .widget<FilledButton>(find.byKey(const ValueKey('departure-save')))
            .onPressed,
        isNotNull,
      );
      scope.read(live.notifier).update(_fixture(un: '1993').data);
      await tester.pumpAndSettle();
      expect(
        find.text('El plan dice UN 2902; el listado, UN 1993'),
        findsOneWidget,
      );
      expect(
        tester
            .widget<FilledButton>(find.byKey(const ValueKey('departure-save')))
            .onPressed,
        isNull,
      );
      expect(save.calls, 0);
    },
  );
}
