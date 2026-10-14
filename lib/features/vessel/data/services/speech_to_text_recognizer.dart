import 'package:speech_to_text/speech_to_text.dart';

import '../../domain/repositories/voice_recognizer.dart';

/// Un único plugin por sesión; sus callbacks apuntan a la escucha vigente.
class SpeechToTextRecognizer implements VoiceRecognizer {
  @override
  final bool supported;
  final String? _requestedLocale;
  final SpeechToText _speech;
  void Function(String)? _transcript;
  void Function(VoiceFailure)? _failure;
  void Function()? _done;
  int _session = 0;

  SpeechToTextRecognizer(
      {required this.supported, String? requestedLocale, SpeechToText? speech})
      : _requestedLocale = requestedLocale,
        _speech = speech ?? SpeechToText();

  @override
  Future<void> start({
    required void Function(String transcript) onTranscript,
    required void Function(VoiceFailure failure) onFailure,
    required void Function() onDone,
  }) async {
    final session = ++_session;
    _transcript = onTranscript;
    _failure = onFailure;
    _done = onDone;
    if (!supported) {
      _failure?.call(VoiceFailure.unavailable);
      return;
    }
    try {
      final ready = await _speech.initialize(
        // Micrófono del dispositivo: no se solicitan permisos Bluetooth.
        options: [SpeechToText.androidNoBluetooth],
        onStatus: (status) {
          if (status == SpeechToText.doneStatus) _done?.call();
        },
        onError: (error) {
          final code = error.errorMsg;
          _failure?.call(code.contains('permission') || code.contains('allowed')
              ? VoiceFailure.permission
              : code.contains('network') || code.contains('server')
                  ? VoiceFailure.network
                  : code.contains('no_match') || code.contains('timeout')
                      ? VoiceFailure.noMatch
                      : code.contains('language')
                          ? VoiceFailure.language
                          : VoiceFailure.unavailable);
        },
      );
      if (session != _session) return;
      if (!ready) {
        _failure?.call(VoiceFailure.unavailable);
        return;
      }
      var locale = _requestedLocale;
      if (locale == null) {
        final locales = await _speech.locales();
        final system = await _speech.systemLocale();
        if (session != _session) return;
        final spanish = system?.localeId.startsWith('es') == true
            ? system
            : locales.where((l) => l.localeId.startsWith('es')).firstOrNull;
        locale = spanish?.localeId;
      }
      if (locale == null) {
        _failure?.call(VoiceFailure.language);
        return;
      }
      await _speech.listen(
        localeId: locale,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        listenOptions: SpeechListenOptions(
          cancelOnError: true,
          partialResults: true,
          listenMode: ListenMode.dictation,
        ),
        onResult: (result) {
          if (session == _session) _transcript?.call(result.recognizedWords);
        },
      );
    } catch (_) {
      if (session == _session) _failure?.call(VoiceFailure.unavailable);
    }
  }

  @override
  Future<void> stop() async => _speech.stop();

  @override
  Future<void> cancel() async {
    _session++;
    _transcript = null;
    _failure = null;
    _done = null;
    if (supported) await _speech.cancel();
  }
}
