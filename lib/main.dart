import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/app.dart';

const _firebaseWebOptions = FirebaseOptions(
  apiKey: 'AIzaSyBFJp2zSTlgWGVNUx2HOTPUGtfYthjgD_0',
  appId: '1:705963558258:web:59320af1397d7db5c049eb',
  messagingSenderId: '705963558258',
  projectId: 'baystream-h5-temporal-20260814',
  authDomain: 'baystream-h5-temporal-20260814.firebaseapp.com',
  storageBucket: 'baystream-h5-temporal-20260814.firebasestorage.app',
);

const _firebaseAndroidOptions = FirebaseOptions(
  apiKey: 'AIzaSyBFJp2zSTlgWGVNUx2HOTPUGtfYthjgD_0',
  appId: '1:705963558258:android:5415db2c5f2beed1c049eb',
  messagingSenderId: '705963558258',
  projectId: 'baystream-h5-temporal-20260814',
  storageBucket: 'baystream-h5-temporal-20260814.firebasestorage.app',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: kIsWeb ? _firebaseWebOptions : _firebaseAndroidOptions,
  );
  runApp(
    const ProviderScope(
      child: BayStreamApp(),
    ),
  );
}
