import 'dart:js_interop';
import 'dart:js_interop_unsafe';

bool get browserVoiceSupported =>
    globalContext.has('SpeechRecognition') ||
    globalContext.has('webkitSpeechRecognition');
