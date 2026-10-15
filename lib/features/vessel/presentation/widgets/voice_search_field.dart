import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/voice_recognizer.dart';
import '../../domain/services/container_voice_query.dart';
import '../providers/voice_recognizer_provider.dart';

/// null suspende las coincidencias mientras se revisa el borrador de voz.
class VoiceSearchField extends ConsumerStatefulWidget {
  final ValueChanged<String?> onQuery;
  const VoiceSearchField({super.key, required this.onQuery});

  @override
  ConsumerState<VoiceSearchField> createState() => _VoiceSearchFieldState();
}

class _VoiceSearchFieldState extends ConsumerState<VoiceSearchField>
    with WidgetsBindingObserver {
  final _text = TextEditingController();
  late VoiceRecognizer _recognizer;
  Timer? _timeout;
  bool _listening = false;
  bool _finishing = false;
  bool _receivedTranscript = false;
  bool _draft = false;
  String? _message;
  int _session = 0;

  @override
  void initState() {
    super.initState();
    _recognizer = ref.read(voiceRecognizerProvider);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _session++;
    _timeout?.cancel();
    unawaited(_recognizer.cancel());
    WidgetsBinding.instance.removeObserver(this);
    _text.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && (_listening || _finishing)) {
      _cancel();
    }
  }

  void _cancel() {
    _session++;
    _finishing = false;
    _timeout?.cancel();
    unawaited(_recognizer.cancel());
    if (mounted) setState(() => _listening = false);
  }

  Future<void> _listen() async {
    if (_listening) {
      _cancel();
      return;
    }
    final session = ++_session;
    _finishing = false;
    _receivedTranscript = false;
    setState(() {
      _listening = true;
      _draft = true;
      _message = null;
    });
    widget.onQuery(null);
    // También limita inicialización/permisos/servicios que nunca contestan.
    _timeout = Timer(const Duration(seconds: 35), () {
      if (mounted && session == _session) _fail(VoiceFailure.unavailable);
    });
    await _recognizer.start(
      onTranscript: (transcript) {
        if (!mounted || session != _session) return;
        final value = normalizeContainerVoiceQuery(transcript);
        if (value.isEmpty) return;
        _receivedTranscript = true;
        setState(() {
          _text.value = TextEditingValue(
              text: value,
              selection: TextSelection.collapsed(offset: value.length));
        });
      },
      onFailure: (failure) {
        if (mounted && session == _session) _fail(failure);
      },
      onDone: () {
        if (!mounted || session != _session || _finishing) return;
        _finishing = true;
        _timeout?.cancel();
        setState(() => _listening = false);
        // Android puede entregar el error después de done. Conservamos los
        // callbacks brevemente; cerrar, editar o confirmar cancela también esto.
        _timeout = Timer(const Duration(milliseconds: 500), () {
          if (!mounted || session != _session) return;
          if (_receivedTranscript) {
            _cancel();
          } else {
            _fail(VoiceFailure.noMatch);
          }
        });
      },
    );
  }

  void _fail(VoiceFailure failure) {
    _cancel();
    setState(() => _message = switch (failure) {
          VoiceFailure.permission =>
            'Permiso de micrófono denegado. Puedes escribir la búsqueda.',
          VoiceFailure.network =>
            'Reconocimiento sin conexión o servicio no disponible. Puedes escribir la búsqueda.',
          VoiceFailure.noMatch =>
            'No se entendió el dictado. Reintenta o escribe la búsqueda.',
          VoiceFailure.language =>
            'Reconocimiento en español no disponible. Puedes escribir la búsqueda.',
          VoiceFailure.unavailable =>
            'Reconocimiento de voz no disponible. Puedes escribir la búsqueda.',
        });
  }

  void _confirm() {
    _cancel();
    setState(() {
      _draft = false;
      _message = null;
    });
    widget.onQuery(_text.text);
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
                child: TextField(
              key: const ValueKey('loading-query'),
              controller: _text,
              decoration:
                  const InputDecoration(labelText: 'OR o últimos dígitos'),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _confirm(),
              onChanged: (value) {
                if (_listening || _finishing) _cancel();
                if (!_draft) widget.onQuery(value);
              },
            )),
            if (_recognizer.supported)
              IconButton(
                key: const ValueKey('loading-voice'),
                tooltip: _listening
                    ? 'Detener dictado'
                    : 'Dictar búsqueda en español',
                onPressed: _listen,
                icon: Icon(
                    _listening ? Icons.stop_circle_outlined : Icons.mic_none),
              ),
          ]),
          if (_draft)
            Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
              Text(_listening
                  ? 'Escuchando…'
                  : 'Borrador: revisa o corrige y pulsa Buscar.'),
              TextButton.icon(
                key: const ValueKey('loading-voice-confirm'),
                onPressed: _confirm,
                icon: const Icon(Icons.search),
                label: const Text('Buscar'),
              ),
            ]),
          if (_message != null)
            Text(_message!, key: const ValueKey('loading-voice-message')),
        ],
      );
}
