// Banco T-107: la app del producto con el namespace t107tm y sesión real.
// A07 se agrega como asset SOLO a la copia de compilación en TEMP
// (t107_inputs/), nunca al repo. Carlos inicia sesión; este banco nunca
// escribe credenciales.
import 'dart:async';

import 'package:baystream/core/app.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_factory.dart';
import 'package:baystream/features/vessel/data/repositories/operation_sync_factory.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/formatters/operation_text.dart';
import 'package:baystream/features/vessel/presentation/pages/cloud_page.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_overview_page.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _web = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_WEB_API_KEY'),
    appId: String.fromEnvironment('FIREBASE_WEB_APP_ID'),
    messagingSenderId:
        String.fromEnvironment('FIREBASE_WEB_MESSAGING_SENDER_ID'),
    projectId: String.fromEnvironment('FIREBASE_WEB_PROJECT_ID'),
    authDomain: String.fromEnvironment('FIREBASE_WEB_AUTH_DOMAIN'),
    storageBucket: String.fromEnvironment('FIREBASE_WEB_STORAGE_BUCKET'));
const _android = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_ANDROID_API_KEY'),
    appId: String.fromEnvironment('FIREBASE_ANDROID_APP_ID'),
    messagingSenderId:
        String.fromEnvironment('FIREBASE_ANDROID_MESSAGING_SENDER_ID'),
    projectId: String.fromEnvironment('FIREBASE_ANDROID_PROJECT_ID'),
    storageBucket: String.fromEnvironment('FIREBASE_ANDROID_STORAGE_BUCKET'));
const _assets = 't107_inputs';
const _ns = 't107tm';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const options = kIsWeb ? _web : _android;
  if (options.projectId != 'baystream-app') {
    throw StateError('Solo baystream-app.');
  }
  await Firebase.initializeApp(options: options);
  runApp(ProviderScope(overrides: [
    localVesselRepositoryProvider.overrideWith((ref) async {
      final repo = await openLocalVesselRepository(namespace: _ns);
      ref.onDispose(() => unawaited(repo.close()));
      return repo;
    }),
    movementLogRepositoryProvider.overrideWith((ref) async {
      final repo = await openMovementLogRepository(namespace: _ns);
      ref.onDispose(() => unawaited(repo.close()));
      return repo;
    }),
    sessionRepositoryProvider.overrideWith((ref) async {
      final repo = await openSessionRepository(namespace: _ns);
      ref.onDispose(() => unawaited(repo.dispose()));
      return repo;
    }),
  ], child: const BayStreamApp(home: _Bank())));
}

class _Bank extends ConsumerStatefulWidget {
  const _Bank();
  @override
  ConsumerState<_Bank> createState() => _BankState();
}

class _BankState extends ConsumerState<_Bank> {
  String _message = 'T-107 · namespace t107tm';
  bool _busy = false;

  Future<void> _openArrival() async {
    setState(() => _busy = true);
    try {
      final notifier = ref.read(voyageNotifierProvider.notifier);
      final text = await rootBundle.loadString('$_assets/CORPUS_A07.edi');
      final result =
          await notifier.parseBaplieContent(text, fileName: 'CORPUS_A07.edi');
      if (!result.success) throw StateError(result.errorMessage!);
      if (result.needsIdentity) {
        await notifier.resolveIdentity(notifier.identityCandidates.first);
      }
      if (notifier.pendingVoyage != null) {
        final error = await notifier.confirmGeometry(
            notifier.currentProfile?.geometry ??
                VesselProfile.proposeFrom(notifier.pendingVoyage!).geometry,
            portOfCall: 'GTSTC',
            sourceKind: OperationSourceKind.arrivalBaplie);
        if (error != null) throw StateError(error);
      }
      final v = notifier.publishedVoyage!;
      if (mounted) {
        setState(() => _message =
            'A07 abierto: ${operationCount(v.totalContainers, 'contenedor', 'contenedores')} · escala GTSTC');
      }
    } catch (error) {
      if (mounted) setState(() => _message = 'NO PASA: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final voyage = ref.watch(voyageNotifierProvider).value;
    final actor = ref.watch(operatorProvider).value;
    return Scaffold(
        appBar: AppBar(title: const Text('T-107 · banco')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Text(_message, key: const ValueKey('t107-message')),
          Text('Rol: ${actor?.role.name ?? 'sin sesión'}'),
          OutlinedButton(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const CloudPage())),
              child: const Text('Nube y cuenta')),
          OutlinedButton(
              onPressed: _busy ? null : _openArrival,
              child: const Text('Abrir A07 · llegada GTSTC')),
          if (voyage != null)
            FilledButton(
                onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                        builder: (_) => const VesselOverviewPage())),
                child: const Text('Pantalla del producto')),
        ]));
  }
}
