import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/browser_voice_support.dart';
import '../../data/services/speech_to_text_recognizer.dart';
import '../../domain/repositories/voice_recognizer.dart';

// No inicializa el micrófono al construir la pantalla; solo tras el toque.
final voiceRecognizerProvider = Provider<VoiceRecognizer>((ref) =>
    SpeechToTextRecognizer(
        // Web Speech no enumera idiomas: se solicita español explícitamente.
        requestedLocale: kIsWeb ? 'es-GT' : null,
        supported: kIsWeb
            ? browserVoiceSupported
            : defaultTargetPlatform == TargetPlatform.android));
