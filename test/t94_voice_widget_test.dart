import 'package:baystream/features/vessel/domain/repositories/voice_recognizer.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_operation_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/voice_recognizer_provider.dart';
import 'package:baystream/features/vessel/presentation/widgets/loading_controls.dart';
import 'package:baystream/features/vessel/presentation/widgets/voice_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/local_profile_test_support.dart';
import 'support/t75_memory_log.dart';
import 'support/t76_fixture.dart';
import 'support/t94_fake_recognizer.dart';

final _query = find.byKey(const ValueKey('loading-query'));
final _mic = find.byKey(const ValueKey('loading-voice'));
final _confirm = find.byKey(const ValueKey('loading-voice-confirm'));

Future<T75MemoryLog> _picker(WidgetTester tester, T94FakeRecognizer fake,
    {Brightness brightness = Brightness.light}) async {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final log = T75MemoryLog();
  final scope = ProviderContainer(overrides: [
    voiceRecognizerProvider.overrideWithValue(fake),
    vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
    movementLogRepositoryProvider.overrideWith((ref) async => log),
    loadingOperationProvider(t76Loading).overrideWith((ref) async* {
      yield t76Operation();
    }),
  ]);
  addTearDown(scope.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
      container: scope,
      child: MaterialApp(
          theme: ThemeData(brightness: brightness, useMaterial3: true),
          home: Scaffold(body: LoadingControls(voyage: t76Loading)))));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('load-search')));
  await tester.pumpAndSettle();
  return log;
}

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
        'T-94 ${brightness.name}: dictado borrador sin buscar ni operar hasta confirmar',
        (tester) async {
      final fake = T94FakeRecognizer();
      final log = await _picker(tester, fake, brightness: brightness);
      expect(fake.starts, 0, reason: 'No pide micrófono al abrir.');
      await tester.tap(_mic);
      await tester.pump();
      fake.transcript!('efe u ele ele cero cero cero uno dos tres cuatro');
      fake.done!();
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(_query).controller!.text, 'FULL0001234');
      expect(find.byKey(const ValueKey('loading-or-1')), findsNothing);
      expect(find.byKey(const ValueKey('loading-confirm')), findsNothing);
      expect(log.of('op'), isEmpty);
      await tester.tap(_confirm);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('loading-or-1')), findsOneWidget);
      expect(find.byKey(const ValueKey('loading-or-2')), findsNothing);
      expect(log.of('op'), isEmpty);
      await tester.tap(find.byKey(const ValueKey('loading-or-1')));
      await tester.pumpAndSettle();
      expect(find.text('Posición planificada: 003-02-82'), findsOneWidget);
      expect(log.of('op'), isEmpty,
          reason: 'La búsqueda tampoco registra carga.');
    });
  }
  testWidgets('T-94 sufijo y edición del borrador requieren Buscar',
      (tester) async {
    final fake = T94FakeRecognizer();
    await _picker(tester, fake);
    await tester.tap(_mic);
    await tester.pump();
    fake.transcript!('uno dos tres cuatro');
    await tester.pump();
    expect(tester.widget<TextField>(_query).controller!.text, '1234');
    await tester.enterText(_query, '5678');
    await tester.pumpAndSettle();
    fake.transcript!('uno dos tres cuatro');
    await tester.pump();
    expect(tester.widget<TextField>(_query).controller!.text, '5678',
        reason: 'Callback tardío no pisa la edición.');
    expect(find.byKey(const ValueKey('loading-or-2')), findsNothing);
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('loading-or-2')), findsOneWidget);
    expect(find.byKey(const ValueKey('loading-or-1')), findsNothing);
  });
  testWidgets(
      'T-94 sin soporte oculta micrófono y conserva búsqueda manual OR y sufijo',
      (tester) async {
    final fake = T94FakeRecognizer(supported: false);
    await _picker(tester, fake);
    expect(_mic, findsNothing);
    await tester.enterText(_query, '1');
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('loading-or-1')), findsOneWidget);
    await tester.enterText(_query, '5678');
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('loading-or-2')), findsOneWidget);
    expect(fake.starts, 0);
  });
  for (final failure in VoiceFailure.values) {
    testWidgets(
        'T-94 ${failure.name}: aviso claro y búsqueda manual después del fallo',
        (tester) async {
      final fake = T94FakeRecognizer();
      final log = await _picker(tester, fake);
      await tester.tap(_mic);
      await tester.pump();
      fake.failure!(failure);
      await tester.pumpAndSettle();
      expect(
          find.byKey(const ValueKey('loading-voice-message')), findsOneWidget);
      await tester.enterText(_query, '1234');
      await tester.tap(_confirm);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('loading-or-1')), findsOneWidget);
      expect(log.of('op'), isEmpty);
    });
  }
  testWidgets(
      'T-94 cierra selector y descarta callbacks tardíos; nuevo dictado',
      (tester) async {
    final fake = T94FakeRecognizer();
    await _picker(tester, fake);
    await tester.tap(_mic);
    await tester.pump();
    final old = fake.transcript!;
    await tester.tap(find.text('Cerrar'));
    await tester.pumpAndSettle();
    old('uno');
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.tap(find.byKey(const ValueKey('load-search')));
    await tester.pumpAndSettle();
    await tester.tap(_mic);
    await tester.pump();
    fake.transcript!('cinco seis siete ocho');
    await tester.tap(_confirm);
    await tester.pumpAndSettle();
    old('uno');
    fake.transcript!('dos');
    await tester.pump();
    expect(tester.widget<TextField>(_query).controller!.text, '5678');
    expect(find.byKey(const ValueKey('loading-or-2')), findsOneWidget);
  });
  testWidgets('T-94 servicio que no contesta vence y permite búsqueda',
      (tester) async {
    final fake = T94FakeRecognizer();
    await _picker(tester, fake);
    await tester.tap(_mic);
    await tester.pump(const Duration(seconds: 36));
    expect(find.textContaining('voz no disponible'), findsOneWidget);
    await tester.enterText(_query, '1');
    await tester.tap(_confirm);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('loading-or-1')), findsOneWidget);
  });
  testWidgets('T-94 pausa cancela escucha y ruido queda editable',
      (tester) async {
    final fake = T94FakeRecognizer();
    final queries = <String?>[];
    await tester.pumpWidget(ProviderScope(
        overrides: [voiceRecognizerProvider.overrideWithValue(fake)],
        child: MaterialApp(
            home: Scaffold(body: VoiceSearchField(onQuery: queries.add)))));
    await tester.tap(_mic);
    await tester.pump();
    fake.transcript!('ruido extraño dos');
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    fake.transcript!('tres');
    expect(tester.widget<TextField>(_query).controller!.text, 'ruidoextraño2');
    expect(queries, [null]);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.enterText(_query, '1234');
    await tester.tap(_confirm);
    await tester.pump();
    expect(queries, [null, '1234']);
  });
}
