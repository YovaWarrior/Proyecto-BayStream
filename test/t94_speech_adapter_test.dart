import 'package:baystream/features/vessel/data/services/speech_to_text_recognizer.dart';
import 'package:baystream/features/vessel/domain/repositories/voice_recognizer.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speech_to_text/speech_to_text.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugin.csdcorp.com/speech_to_text');
  final calls = <MethodCall>[];
  var ready = true;
  var locales = <String>[];
  setUp(() {
    calls.clear();
    ready = true;
    locales = ['en_US:English', 'es_MX:Español'];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return switch (call.method) {
        'initialize' => ready,
        'locales' => locales,
        'listen' => true,
        _ => null,
      };
    });
  });
  tearDown(() => TestDefaultBinaryMessengerBinding
      .instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, null));

  Future<List<VoiceFailure>> start(SpeechToTextRecognizer recognizer) async {
    final failures = <VoiceFailure>[];
    await recognizer.start(
        onTranscript: (_) {}, onFailure: failures.add, onDone: () {});
    return failures;
  }

  test('T-94 adaptador Web pide español aunque el navegador no enumere idiomas',
      () async {
    locales = [];
    final recognizer = SpeechToTextRecognizer(
        supported: true,
        requestedLocale: 'es-GT',
        speech: SpeechToText.withMethodChannel());
    expect(await start(recognizer), isEmpty);
    expect(calls.where((c) => c.method == 'locales'), isEmpty);
    final listen = calls.singleWhere((c) => c.method == 'listen');
    expect(listen.arguments['localeId'], 'es-GT');
    expect(listen.arguments['partialResults'], true);
    expect(
        calls
            .singleWhere((c) => c.method == 'initialize')
            .arguments['noBluetooth'],
        true);
    expect(
        calls
            .singleWhere((c) => c.method == 'initialize')
            .arguments['debugLogging'],
        false);
    await recognizer.cancel();
  });
  test(
      'T-94 adaptador Android elige español y conserva la selección entre escuchas',
      () async {
    final recognizer = SpeechToTextRecognizer(
        supported: true, speech: SpeechToText.withMethodChannel());
    expect(await start(recognizer), isEmpty);
    await recognizer.cancel();
    expect(await start(recognizer), isEmpty);
    expect(
        calls
            .where((c) => c.method == 'listen')
            .map((c) => c.arguments['localeId']),
        ['es_MX', 'es_MX']);
    expect(calls.where((c) => c.method == 'initialize'), hasLength(1));
    await recognizer.cancel();
  });
  test('T-94 adaptador sin soporte no invoca ningún canal', () async {
    final recognizer = SpeechToTextRecognizer(
        supported: false, speech: SpeechToText.withMethodChannel());
    expect(await start(recognizer), [VoiceFailure.unavailable]);
    await recognizer.cancel();
    expect(calls, isEmpty);
  });
  test('T-94 adaptador Android sin español informa y no escucha en otro idioma',
      () async {
    locales = ['en_US:English'];
    final recognizer = SpeechToTextRecognizer(
        supported: true, speech: SpeechToText.withMethodChannel());
    expect(await start(recognizer), [VoiceFailure.language]);
    expect(calls.where((c) => c.method == 'listen'), isEmpty);
    await recognizer.cancel();
  });
  test(
      'T-94 adaptador con servicio denegado o ausente informa indisponibilidad',
      () async {
    ready = false;
    final recognizer = SpeechToTextRecognizer(
        supported: true, speech: SpeechToText.withMethodChannel());
    expect(await start(recognizer), [VoiceFailure.unavailable]);
    expect(calls.where((c) => c.method == 'listen'), isEmpty);
    await recognizer.cancel();
  });
}
