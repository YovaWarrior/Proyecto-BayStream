// Banco T-85. A03 se agrega como asset SOLO a la copia de compilación en TEMP
// (t85_inputs/), nunca al repo. Namespace propio y sesion local sin cuenta.
import 'dart:async';

import 'package:baystream/core/app.dart';
import 'package:baystream/features/vessel/data/repositories/local_only_operation_sync.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_factory.dart';
import 'package:baystream/features/vessel/domain/entities/app_theme_preference.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/pages/segregation_page.dart';
import 'package:baystream/features/vessel/presentation/pages/stowage_alerts_page.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/theme_preference_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Modo sin cuenta: la sesión es local y nada sube a la nube. El banco solo
/// abre A03; las pantallas y sus resultados son los del producto.
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
const _assets = 't85_inputs';
const _ns = 't85acc';

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
      const session = LocalSessionRepository();
      ref.onDispose(() => unawaited(session.dispose()));
      return session;
    }),
  ], child: const BayStreamApp(home: _Bank())));
}

class _Bank extends ConsumerStatefulWidget {
  const _Bank();
  @override
  ConsumerState<_Bank> createState() => _BankState();
}

class _BankState extends ConsumerState<_Bank> {
  String message = 'Modo sin cuenta · namespace t85acc';
  bool busy = false;
  Future<void> open() async {
    setState(() => busy = true);
    try {
      final notifier = ref.read(voyageNotifierProvider.notifier);
      final text = await rootBundle.loadString('$_assets/CORPUS_A03.edi');
      final result =
          await notifier.parseBaplieContent(text, fileName: 'CORPUS_A03.edi');
      if (!result.success) throw StateError(result.errorMessage!);
      if (result.needsIdentity) {
        await notifier.resolveIdentity(notifier.identityCandidates.first);
      }
      if (notifier.pendingVoyage != null) {
        final error = await notifier.confirmGeometry(
            notifier.currentProfile?.geometry ??
                VesselProfile.proposeFrom(notifier.pendingVoyage!).geometry,
            portOfCall: 'GTPBR',
            sourceKind: OperationSourceKind.arrivalBaplie);
        if (error != null) throw StateError(error);
      }
      if (mounted) {
        setState(() => message =
            'A03 abierto: ${notifier.publishedVoyage!.totalContainers} contenedores · modo sin cuenta');
      }
    } catch (error) {
      if (mounted) setState(() => message = 'NO PASA: $error');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final voyage = ref.watch(voyageNotifierProvider).value;
    return Scaffold(
        appBar: AppBar(title: const Text('T-85 · aceptación')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Text(message),
          for (final pref in [
            AppThemePreference.light,
            AppThemePreference.dark
          ])
            OutlinedButton(
                onPressed: () =>
                    ref.read(themePreferenceProvider.notifier).select(pref),
                child: Text(pref == AppThemePreference.light
                    ? 'Tema claro'
                    : 'Tema oscuro')),
          OutlinedButton(
              onPressed: busy ? null : open,
              child: const Text('Abrir A03 con peligrosas')),
          FilledButton(
              onPressed: voyage == null
                  ? null
                  : () => Navigator.of(context).push(MaterialPageRoute<void>(
                      builder: (_) => const SegregationPage())),
              child: const Text('Segregación del producto')),
          OutlinedButton(
              onPressed: voyage == null
                  ? null
                  : () => Navigator.of(context).push(MaterialPageRoute<void>(
                      builder: (_) => const StowageAlertsPage())),
              child: const Text('Alertas del producto')),
        ]));
  }
}
