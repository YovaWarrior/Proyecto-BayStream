// Banco T-104. A07 se agrega como asset SOLO a la copia en TEMP.
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
import 'package:baystream/features/vessel/presentation/pages/recent_voyages_page.dart';
import 'package:baystream/features/vessel/presentation/pages/hatch_covers_page.dart';
import 'package:baystream/features/vessel/presentation/formatters/operation_text.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/theme_preference_provider.dart';
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
const _realCloud = bool.fromEnvironment('BAYSTREAM_T104_REAL_CLOUD');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const options = kIsWeb ? _web : _android;
  if (options.projectId != 'baystream-app') {
    throw StateError('Solo baystream-app.');
  }
  await Firebase.initializeApp(options: options);
  runApp(ProviderScope(overrides: [
    localVesselRepositoryProvider.overrideWith((ref) async {
      final repo = await openLocalVesselRepository(namespace: 't104acc');
      ref.onDispose(() => unawaited(repo.close()));
      return repo;
    }),
    movementLogRepositoryProvider.overrideWith((ref) async {
      final repo = await openMovementLogRepository(namespace: 't104acc');
      ref.onDispose(() => unawaited(repo.close()));
      return repo;
    }),
    sessionRepositoryProvider.overrideWith((ref) async {
      final session = _realCloud
          ? await openSessionRepository(namespace: 't104acc')
          : const LocalSessionRepository();
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
  String _message = 'Preparando A07 anonimizado…';
  @override
  void initState() {
    super.initState();
    unawaited(_prepare());
  }

  Future<void> _prepare({bool synthetic = false}) async {
    try {
      final text = synthetic
          ? "UNH+1+BAPLIE:D:95B:UN:SMDG22'"
              "TDT+20+T104+++TST:172:20+++9000104:146:11:BUQUE PRUEBA'"
              "LOC+5+HNPCR:139:6'LOC+61+GTSTC:139:6'"
              "LOC+147+0010182::5'LOC+9+HNPCR:139:6'LOC+11+GTSTC:139:6'"
              "MEA+AAE+VGM+KGM:20000'EQD+CN+TSTU0000104+22G1+++5'"
          : await rootBundle.loadString('t104_inputs/CORPUS_A07.edi');
      final notifier = ref.read(voyageNotifierProvider.notifier);
      final result = await notifier.parseBaplieContent(text,
          fileName: synthetic ? 't104_sintetico' : 'CORPUS_A07.edi');
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
            '${operationCount(voyage.totalContainers, 'contenedor', 'contenedores')} · '
                '${operationCount(voyage.bays.length, 'bahía', 'bahías')} · '
                '${voyage.totalWeight.toStringAsFixed(0)} kg');
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
        appBar: AppBar(title: const Text('T-104 · aceptación')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          const Text('t104acc · aceptación'),
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
          OutlinedButton(
              onPressed: _prepare, child: const Text('Abrir A07 local')),
          OutlinedButton(
              onPressed: () => _prepare(synthetic: true),
              child: const Text('Preparar una bahía sintética local')),
          OutlinedButton(
              onPressed: () => _page(const RecentVoyagesPage()),
              child: const Text('Recientes del dispositivo')),
          OutlinedButton(
              onPressed: () => _page(HatchCoversPage(
                      geometry: const VesselGeometry(
                          portRows: 2,
                          starboardRows: 2,
                          holdTiers: [2, 4],
                          deckTiers: [82]),
                      holdBays: const {
                        1,
                        3
                      },
                      initial: {
                        1: HatchCoverDeclaration(kind: HatchCoverKind.openHold)
                      })),
              child: const Text('Editor de tapas: borrador local')),
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
          Text('Escala del cliente: ${[
            8.0,
            10.0,
            11.0,
            12.0,
            14.0,
            16.0,
            18.0,
            20.0,
            22.0,
            24.0,
            28.0,
            32.0,
            36.0,
            40.0,
            48.0,
            56.0,
            64.0,
            72.0,
            96.0,
            100.0
          ].map((size) => '${size.toInt()}:${MediaQuery.textScalerOf(context).scale(size).toStringAsFixed(3)}').join('; ')}'),
        ]));
  }
}
