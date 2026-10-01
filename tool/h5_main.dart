import 'package:baystream/c3_reconciliation_screen.dart';
import 'package:baystream/latency_test_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// T-62 · Punto de entrada de la instrumentación de H5, separado de
/// `lib/main.dart`. Abre las dos pantallas congeladas sin modificarlas.
///
/// Las opciones de Firebase no viven en el repositorio: se leen de un archivo
/// privado con `--dart-define-from-file`. Ejemplo (Chrome, oficina):
///
///     flutter run -d chrome -t tool/h5_main.dart
///         --dart-define-from-file=C:\Proyectos\baystream-privado\h5-temporal.json
///
/// En el Android de muelle, el mismo comando con `-d <dispositivo>`.
/// Las mismas reglas que `main.dart`: opciones Web en Web, Android en el resto.
const _apiKey = String.fromEnvironment('H5_API_KEY');
const _projectId = String.fromEnvironment('H5_PROJECT_ID');
const _senderId = String.fromEnvironment('H5_MESSAGING_SENDER_ID');
const _storageBucket = String.fromEnvironment('H5_STORAGE_BUCKET');
const _authDomain = String.fromEnvironment('H5_AUTH_DOMAIN');
const _webAppId = String.fromEnvironment('H5_WEB_APP_ID');
const _androidAppId = String.fromEnvironment('H5_ANDROID_APP_ID');

/// Colecciones y documento que sostienen H5; la comprobación solo los lee.
const _latencyCollection = 'latency_test';
const _c3Document = 'voyages/c3-measurement-voyage';

FirebaseOptions? _options() {
  const appId = kIsWeb ? _webAppId : _androidAppId;
  final required = [_apiKey, _projectId, _senderId, appId];
  if (required.any((value) => value.isEmpty)) return null;
  return FirebaseOptions(
    apiKey: _apiKey,
    appId: appId,
    messagingSenderId: _senderId,
    projectId: _projectId,
    authDomain: kIsWeb && _authDomain.isNotEmpty ? _authDomain : null,
    storageBucket: _storageBucket.isEmpty ? null : _storageBucket,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final options = _options();
  if (options != null) await Firebase.initializeApp(options: options);
  runApp(MaterialApp(
    title: 'BayStream · H5',
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
    home: options == null ? const _MissingOptions() : const _H5Home(),
  ));
}

class _MissingOptions extends StatelessWidget {
  const _MissingOptions();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Faltan las opciones de Firebase de H5. Lanza con '
              '--dart-define-from-file apuntando al archivo privado '
              '(H5_API_KEY, H5_PROJECT_ID, H5_MESSAGING_SENDER_ID y el '
              'identificador de app de la plataforma).'),
        ),
      );
}

class _H5Home extends StatefulWidget {
  const _H5Home();

  @override
  State<_H5Home> createState() => _H5HomeState();
}

class _H5HomeState extends State<_H5Home> {
  String _check = 'Sin comprobar';
  bool _checking = false;

  /// Solo lectura: un conteo de agregación y un get del documento C3.
  /// No agrega, modifica ni borra nada.
  Future<void> _readOnlyCheck() async {
    setState(() {
      _checking = true;
      _check = 'Consultando el servidor...';
    });
    try {
      final firestore = FirebaseFirestore.instance;
      final count = await firestore
          .collection(_latencyCollection)
          .count()
          .get(source: AggregateSource.server);
      final c3 = await firestore
          .doc(_c3Document)
          .get(const GetOptions(source: Source.server));
      final result = '$_latencyCollection: ${count.count} documentos · '
          '$_c3Document: ${c3.exists ? 'existe' : 'no existe'}';
      debugPrint('H5_CHECK:${count.count}:${c3.exists}');
      setState(() => _check = result);
    } catch (error) {
      debugPrint('H5_CHECK_ERROR:$error');
      setState(() => _check = 'Error de lectura: $error');
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  void _open(Widget screen) => Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => screen));

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('BayStream · instrumentación H5')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Text('Proyecto: ${Firebase.app().options.projectId}'),
          const SizedBox(height: 8),
          const Text('Las pantallas escriben en Firestore al pulsar sus '
              'acciones: emisor y receptor en latency_test, preparar ciclo y '
              'aplicar cambio en voyages. Úsalas solo para medir.'),
          const SizedBox(height: 16),
          FilledButton(
            key: const ValueKey('h5-latency'),
            onPressed: () => _open(const LatencyTestScreen()),
            child: const Text('C1/C2 · Prueba de latencia'),
          ),
          const SizedBox(height: 8),
          FilledButton(
            key: const ValueKey('h5-c3'),
            onPressed: () => _open(const C3ReconciliationScreen()),
            child: const Text('C3 · Reconciliación offline-first'),
          ),
          const Divider(height: 32),
          OutlinedButton(
            key: const ValueKey('h5-check'),
            onPressed: _checking ? null : _readOnlyCheck,
            child: const Text('Comprobar conexión (solo lectura)'),
          ),
          const SizedBox(height: 8),
          Text(_check, key: const ValueKey('h5-check-result')),
        ]),
      );
}
