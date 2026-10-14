enum VoiceFailure { unavailable, permission, network, noMatch, language }

/// Solo entrega texto. Nunca busca ni registra movimientos.
abstract class VoiceRecognizer {
  bool get supported;
  Future<void> start({
    required void Function(String transcript) onTranscript,
    required void Function(VoiceFailure failure) onFailure,
    required void Function() onDone,
  });
  Future<void> stop();
  Future<void> cancel();
}
