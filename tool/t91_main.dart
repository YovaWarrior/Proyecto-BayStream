import 'dart:async';

import 'package:baystream/features/vessel/data/repositories/local_only_operation_sync.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_factory.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_overview_page.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/plan_toolbar_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

/// Aceptación local del producto: selector real, ajuste y viaje persistentes.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const options = kIsWeb ? _web : _android;
  if (options.projectId != 'baystream-app') {
    throw StateError('Solo baystream-app.');
  }
  await Firebase.initializeApp(options: options);
  runApp(ProviderScope(overrides: [
    localVesselRepositoryProvider.overrideWith((ref) async {
      final repo = await openLocalVesselRepository(namespace: 't91acc');
      ref.onDispose(() => unawaited(repo.close()));
      return repo;
    }),
    movementLogRepositoryProvider.overrideWith((ref) async {
      final repo = await openMovementLogRepository(namespace: 't91acc');
      ref.onDispose(() => unawaited(repo.close()));
      return repo;
    }),
    sessionRepositoryProvider
        .overrideWith((ref) async => const LocalSessionRepository()),
  ], child: const _App()));
}

class _App extends StatefulWidget {
  const _App();
  @override
  State<_App> createState() => _AppState();
}

class _AppState extends State<_App> {
  Brightness _brightness = Brightness.light;
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'BayStream T-91', debugShowCheckedModeBanner: false,
        theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
                seedColor: ThemeData().colorScheme.primary,
                brightness: _brightness)),
        // 360 dp también en Windows: la misma pantalla del producto, sin escalarla.
        builder: (context, child) => Center(
          child: SizedBox(
            width: 360,
            child: !kIsWeb && defaultTargetPlatform == TargetPlatform.windows
                ? LayoutBuilder(
                    builder: (context, constraints) => MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                      ),
                      child: child!,
                    ),
                  )
                : child,
          ),
        ),
        home: _Bank(
            onTheme: () => setState(() => _brightness =
                _brightness == Brightness.light
                    ? Brightness.dark
                    : Brightness.light)),
      );
}

class _Bank extends ConsumerStatefulWidget {
  final VoidCallback onTheme;
  const _Bank({required this.onTheme});
  @override
  ConsumerState<_Bank> createState() => _BankState();
}

class _BankState extends ConsumerState<_Bank> {
  String _message = 't91acc · sin cuenta · selector real';
  bool _busy = false;

  Future<void> _open({bool restore = false}) async {
    setState(() => _busy = true);
    try {
      final notifier = ref.read(voyageNotifierProvider.notifier);
      if (restore) {
        final local = await ref.read(localVesselRepositoryProvider.future);
        final voyages = (await local.getAllVoyages()).getOrElse(() => []);
        if (voyages.isEmpty) throw StateError('Sin viaje guardado.');
        final error = await notifier.openRecentVoyage(voyages.first.id);
        if (error != null) throw StateError(error);
      } else {
        final result = await notifier.loadVesselFromFile();
        if (result.isCancelled) return;
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
      }
      final voyage = notifier.publishedVoyage!;
      final collapsed = await ref.read(planToolbarCollapsedProvider.future);
      setState(() => _message = '${voyage.totalContainers} contenedores · '
          '${voyage.bays.length} bahías · ${voyage.totalWeight.toStringAsFixed(0)} kg\n'
          'Preferencia releída: ${collapsed ? "plegada" : "desplegada"}');
    } catch (error) {
      setState(() => _message = '$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('T-91 · aceptación')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Text(_message),
          FilledButton(
              onPressed: _busy ? null : () => _open(),
              child: const Text('Elegir A07')),
          OutlinedButton(
              onPressed: _busy ? null : () => _open(restore: true),
              child: const Text('Reabrir viaje guardado')),
          OutlinedButton(
              onPressed: widget.onTheme,
              child:
                  Text('Cambiar tema · ${Theme.of(context).brightness.name}')),
          OutlinedButton(
              onPressed: ref.watch(voyageNotifierProvider).value == null
                  ? null
                  : () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                          builder: (_) => const VesselOverviewPage())),
              child: const Text('Abrir pantalla del producto')),
        ]),
      );
}
