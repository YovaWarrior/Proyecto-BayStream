import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/app.dart';

const _firebaseWebOptions = FirebaseOptions(
  apiKey: String.fromEnvironment('FIREBASE_WEB_API_KEY'),
  appId: String.fromEnvironment('FIREBASE_WEB_APP_ID'),
  messagingSenderId: String.fromEnvironment('FIREBASE_WEB_MESSAGING_SENDER_ID'),
  projectId: String.fromEnvironment('FIREBASE_WEB_PROJECT_ID'),
  authDomain: String.fromEnvironment('FIREBASE_WEB_AUTH_DOMAIN'),
  storageBucket: String.fromEnvironment('FIREBASE_WEB_STORAGE_BUCKET'),
);

const _firebaseAndroidOptions = FirebaseOptions(
  apiKey: String.fromEnvironment('FIREBASE_ANDROID_API_KEY'),
  appId: String.fromEnvironment('FIREBASE_ANDROID_APP_ID'),
  messagingSenderId:
      String.fromEnvironment('FIREBASE_ANDROID_MESSAGING_SENDER_ID'),
  projectId: String.fromEnvironment('FIREBASE_ANDROID_PROJECT_ID'),
  storageBucket: String.fromEnvironment('FIREBASE_ANDROID_STORAGE_BUCKET'),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const options = kIsWeb ? _firebaseWebOptions : _firebaseAndroidOptions;
  final required = [
    options.apiKey,
    options.appId,
    options.messagingSenderId,
    options.projectId,
    options.storageBucket,
    if (kIsWeb) options.authDomain,
  ];
  if (required.any((value) => value == null || value.trim().isEmpty)) {
    runApp(const _MissingFirebaseOptions());
    return;
  }
  await Firebase.initializeApp(options: options);
  runApp(
    const ProviderScope(
      child: BayStreamApp(),
    ),
  );
}

class _MissingFirebaseOptions extends StatelessWidget {
  const _MissingFirebaseOptions();

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'BayStream',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true),
        home: const Scaffold(
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Falta la configuración de Firebase'),
                    SizedBox(height: 16),
                    Text(
                        'Esta versión de BayStream no tiene todas las opciones '
                        'necesarias para iniciar. Solicita una compilación '
                        'configurada al responsable.'),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
