import 'package:baystream/features/vessel/domain/repositories/voice_recognizer.dart';

class T94FakeRecognizer implements VoiceRecognizer {
  @override
  final bool supported;
  void Function(String)? transcript;
  void Function(VoiceFailure)? failure;
  void Function()? done;
  int starts = 0;
  int cancels = 0;
  T94FakeRecognizer({this.supported = true});

  @override
  Future<void> start({
    required void Function(String transcript) onTranscript,
    required void Function(VoiceFailure failure) onFailure,
    required void Function() onDone,
  }) async {
    starts++;
    transcript = onTranscript;
    failure = onFailure;
    done = onDone;
  }

  @override
  Future<void> stop() async => done?.call();
  @override
  Future<void> cancel() async {
    cancels++;
  }
}
