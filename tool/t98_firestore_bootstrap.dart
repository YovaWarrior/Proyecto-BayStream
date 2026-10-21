// El adaptador fijado en pubspec.lock consulta Firebase.app() al crear su
// instancia de plataforma. El banco Windows solo tiene la app t98. Sembrar
// el mismo adaptador con t98 evita crear/abrir una sesion [DEFAULT] ajena.
// Se usan clases de la dependencia transitiva ya instalada, solo en tool/.
// ignore_for_file: depend_on_referenced_packages, implementation_imports
import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:cloud_firestore_platform_interface/src/method_channel/method_channel_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

void t98PrepararFirestoreWindows(FirebaseApp app) {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
    FirebaseFirestorePlatform.instance =
        MethodChannelFirebaseFirestore(app: app, databaseId: '(default)');
  }
}
