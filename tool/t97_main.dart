// Banco T-97. A07 se agrega como asset SOLO a la copia en TEMP.
import 'dart:async';
import 'package:baystream/core/app.dart';
import 'package:baystream/features/vessel/data/repositories/operation_sync_factory.dart';
import 'package:baystream/features/vessel/data/repositories/local_only_operation_sync.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_factory.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/entities/app_theme_preference.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_overview_page.dart';
import 'package:baystream/features/vessel/presentation/pages/operation_progress_page.dart';
import 'package:baystream/features/vessel/presentation/pages/cloud_page.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/theme_preference_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
const _realCloud = bool.fromEnvironment('BAYSTREAM_T97_REAL_CLOUD');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const options = kIsWeb ? _web : _android;
  if (options.projectId != 'baystream-app') {
    throw StateError('Solo baystream-app.');
  }
  await Firebase.initializeApp(options: options);
  runApp(ProviderScope(overrides: [
    localVesselRepositoryProvider.overrideWith((ref) async {
      final repo = await openLocalVesselRepository(namespace: 't97acc');
      ref.onDispose(() => unawaited(repo.close()));
      return repo;
    }),
    movementLogRepositoryProvider.overrideWith((ref) async {
      final repo = await openMovementLogRepository(namespace: 't97acc');
      ref.onDispose(() => unawaited(repo.close()));
      return repo;
    }),
    sessionRepositoryProvider.overrideWith((ref) async {
      final session = _realCloud
          ? await openSessionRepository(namespace: 't97acc')
          : const LocalSessionRepository();
      ref.onDispose(() => unawaited(session.dispose()));
      return session;
    }),
  ], child: const BayStreamApp(home: _Bank(), builder: _narrow)));
}

Widget _narrow(BuildContext context, Widget? child) => Center(
    child: SizedBox(
        width: 360,
        child: LayoutBuilder(
            builder: (context, constraints) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                    size: Size(constraints.maxWidth, constraints.maxHeight)),
                child: child!))));

class _Bank extends ConsumerStatefulWidget {
  const _Bank();
  @override
  ConsumerState<_Bank> createState() => _BankState();
}

class _BankState extends ConsumerState<_Bank> {
  String _message = 'Preparando A07 anonimizado…';
  @override
  void initState() {
    super.initState();
    unawaited(_prepare());
  }

  Future<void> _prepare() async {
    try {
      final text = await rootBundle.loadString('t97_inputs/CORPUS_A07.edi');
      final notifier = ref.read(voyageNotifierProvider.notifier);
      final result =
          await notifier.parseBaplieContent(text, fileName: 'CORPUS_A07.edi');
      if (!result.success) throw StateError(result.errorMessage!);
      if (result.needsIdentity) {
        await notifier.resolveIdentity(notifier.identityCandidates.first);
      }
      if (notifier.pendingVoyage != null) {
        final error = await notifier.confirmGeometry(
            notifier.currentProfile!.geometry,
            portOfCall: 'GTSTC',
            sourceKind: OperationSourceKind.arrivalBaplie);
        if (error != null) throw StateError(error);
      }
      final voyage = notifier.publishedVoyage!;
      if (mounted) {
        setState(() => _message =
            '${voyage.totalContainers} contenedores · ${voyage.bays.length} bahías · ${voyage.totalWeight.toStringAsFixed(0)} kg');
      }
    } catch (error) {
      if (mounted) setState(() => _message = '$error');
    }
  }

  void _page(Widget page) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  @override
  Widget build(BuildContext context) {
    final voyage = ref.watch(voyageNotifierProvider).value;
    return Scaffold(
        appBar: AppBar(title: const Text('T-97 · aceptación')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          const Text('t97acc · A07 anonimizado'),
          Text(_message),
          const Text(_realCloud
              ? 'Nube real: Carlos inicia sesión; usar solo una operación existente.'
              : 'Solo este dispositivo; sin cuenta.'),
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
          if (voyage != null) ...[
            FilledButton(
                onPressed: () => _page(const VesselOverviewPage()),
                child: const Text('Pantalla del producto')),
            OutlinedButton(
                onPressed: () => _page(OperationProgressPage(voyage: voyage)),
                child: const Text('Avance de la operación')),
          ],
          if (_realCloud)
            OutlinedButton(
                onPressed: () => _page(const CloudPage()),
                child: const Text('Nube y cuenta (Carlos)')),
          if (_realCloud) ...[
            OutlinedButton(
                onPressed: () => FirebaseFirestore.instance.disableNetwork(),
                child: const Text('Cortar conexión del SDK (banco)')),
            OutlinedButton(
                onPressed: () => FirebaseFirestore.instance.enableNetwork(),
                child: const Text('Restablecer conexión del SDK (banco)')),
          ],
        ]));
  }
}
