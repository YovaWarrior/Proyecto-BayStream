// Diagnostico de solo lectura del banco Windows. No imprime datos de identidad.
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 't98_firestore_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!Platform.isWindows) throw StateError('Sonda exclusiva de Windows.');
  const salida = String.fromEnvironment('T98_DIAG_SALIDA');
  final out = File(File(salida).absolute.uri.normalizePath().toFilePath());
  final root = Directory.systemTemp.resolveSymbolicLinksSync().toLowerCase();
  if (!out.path.toLowerCase().startsWith('$root${Platform.pathSeparator}') ||
      out.existsSync()) {
    throw StateError('Salida TEMP nueva requerida.');
  }
  final result = <String, Object?>{
    'base': '33404a5804be4fad85aab80dd923a7ae9e878ee9',
    'lectura':
        'authorized/registro de la cuenta, identificador solo en memoria',
    'fuente': 'server',
  };
  try {
    const options = FirebaseOptions(
      apiKey: String.fromEnvironment('FIREBASE_ANDROID_API_KEY'),
      appId: String.fromEnvironment('FIREBASE_ANDROID_APP_ID'),
      messagingSenderId:
          String.fromEnvironment('FIREBASE_ANDROID_MESSAGING_SENDER_ID'),
      projectId: String.fromEnvironment('FIREBASE_ANDROID_PROJECT_ID'),
      storageBucket: String.fromEnvironment('FIREBASE_ANDROID_STORAGE_BUCKET'),
    );
    if (options.projectId != 'baystream-app') {
      throw StateError('Proyecto no autorizado.');
    }
    final app = await Firebase.initializeApp(name: 't98', options: options);
    const corregido = bool.fromEnvironment('T98_DIAG_BOOTSTRAP');
    if (corregido) t98PrepararFirestoreWindows(app);
    result['bootstrapCorregido'] = corregido;
    final auth = FirebaseAuth.instanceFor(app: app);
    final db = FirebaseFirestore.instanceFor(app: app);
    result.addAll({
      'app': app.name,
      'authApp': auth.app.name,
      'firestoreApp': db.app.name,
      'proyectoCorrecto': true
    });
    final user = await auth
        .authStateChanges()
        .first
        .timeout(const Duration(seconds: 12));
    result['sesionPresente'] = user != null;
    if (user != null) {
      final snapshot = await db
          .collection('authorized')
          .doc(user.uid)
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 12));
      final data = snapshot.data();
      result.addAll({
        'existe': snapshot.exists,
        'desdeCache': snapshot.metadata.isFromCache,
        'rol': {'office', 'dock'}.contains(data?['role'])
            ? data!['role']
            : 'otro_o_ausente',
        'activa': data?['active'] == true
      });
    }
  } on FirebaseException catch (error) {
    result['errorCodigo'] =
        RegExp(r'^[a-zA-Z0-9_-]{1,80}$').hasMatch(error.code)
            ? error.code
            : 'codigo_omitido';
  } catch (error) {
    result['errorTipo'] = error.runtimeType.toString();
  }
  result['utc'] = DateTime.now().toUtc().toIso8601String();
  out.parent.createSync(recursive: true);
  final text = const JsonEncoder.withIndent('  ').convert(result);
  out.writeAsStringSync(text);
  runApp(MaterialApp(
      home: Scaffold(
    appBar: AppBar(title: const Text('Diagnóstico t98 · solo lectura')),
    body: SingleChildScrollView(
        padding: const EdgeInsets.all(24), child: SelectableText(text)),
  )));
}
