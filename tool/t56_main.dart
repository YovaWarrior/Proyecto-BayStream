// Banco T-56. A07 y A06 se agregan como assets SOLO a la copia de compilación
// en TEMP (t56_inputs/), nunca al repositorio.
import 'dart:async';

import 'package:baystream/core/app.dart';
import 'package:baystream/features/vessel/data/repositories/local_only_operation_sync.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_factory.dart';
import 'package:baystream/features/vessel/domain/entities/app_theme_preference.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/formatters/operation_text.dart';
import 'package:baystream/features/vessel/presentation/pages/hatch_covers_page.dart';
import 'package:baystream/features/vessel/presentation/pages/recent_voyages_page.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_overview_page.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_profiles_page.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/theme_preference_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Banco de aceptación local en modo sin cuenta: la sesión es local y nada
/// sube a la nube. Abre los planos con el notifier real; las tomas, los textos
/// y Recientes son las pantallas del producto.
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

/// Un contenedor sintético, para «1 contenedor» en Recientes.
const _one = "UNH+1+BAPLIE:D:95B:UN:SMDG22'"
    "TDT+20+T56UNO+++TST:172:20+++9000056:146:11:BUQUE PRUEBA T56'"
    "LOC+5+HNPCR:139:6'LOC+61+GTSTC:139:6'"
    "LOC+147+0010182::5'LOC+9+HNPCR:139:6'LOC+11+GTSTC:139:6'"
    "MEA+AAE+VGM+KGM:20000'EQD+CN+TSTU0000056+22G1+++5'";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const options = kIsWeb ? _web : _android;
  if (options.projectId != 'baystream-app') {
    throw StateError('Solo baystream-app.');
  }
  await Firebase.initializeApp(options: options);
  runApp(ProviderScope(overrides: [
    localVesselRepositoryProvider.overrideWith((ref) async {
      final repo = await openLocalVesselRepository(namespace: 't56acc');
      ref.onDispose(() => unawaited(repo.close()));
      return repo;
    }),
    movementLogRepositoryProvider.overrideWith((ref) async {
      final repo = await openMovementLogRepository(namespace: 't56acc');
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
  String _message = 'Modo sin cuenta · namespace t56acc';
  bool _busy = false;

  Future<void> _open(String? asset,
      {required String port, required OperationSourceKind kind}) async {
    setState(() => _busy = true);
    try {
      final text = asset == null
          ? _one
          : await rootBundle.loadString('t56_inputs/$asset');
      final notifier = ref.read(voyageNotifierProvider.notifier);
      final result = await notifier.parseBaplieContent(text,
          fileName: asset ?? 't56_un_contenedor');
      if (!result.success) throw StateError(result.errorMessage!);
      if (result.needsIdentity) {
        await notifier.resolveIdentity(notifier.identityCandidates.first);
      }
      if (notifier.pendingVoyage != null) {
        final error = await notifier.confirmGeometry(
            notifier.currentProfile?.geometry ??
                VesselProfile.proposeFrom(notifier.pendingVoyage!).geometry,
            portOfCall: port,
            sourceKind: kind);
        if (error != null) throw StateError(error);
      }
      final voyage = notifier.publishedVoyage!;
      setState(() => _message =
          '${operationCount(voyage.totalContainers, 'contenedor', 'contenedores')} · '
          '${operationCount(voyage.bays.length, 'bahía', 'bahías')} · '
          '${voyage.totalWeight.toStringAsFixed(0)} kg · escala $port');
    } catch (error) {
      if (mounted) setState(() => _message = '$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _page(Widget page) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    final voyage = ref.watch(voyageNotifierProvider).value;
    return Scaffold(
        appBar: AppBar(title: const Text('T-56 · aceptación')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Text(_message, key: const ValueKey('t56-message')),
          const Text('Solo este dispositivo; sin cuenta.'),
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
              onPressed: _busy
                  ? null
                  : () => _open('CORPUS_A07.edi',
                      port: 'GTSTC', kind: OperationSourceKind.arrivalBaplie),
              child: const Text('Abrir A07 · GTSTC')),
          OutlinedButton(
              onPressed: _busy
                  ? null
                  : () => _open('CORPUS_A06.edi',
                      port: 'GTPBR', kind: OperationSourceKind.loadingBaplie),
              child: const Text('Abrir A06 · GTPBR')),
          OutlinedButton(
              onPressed: _busy
                  ? null
                  : () => _open(null,
                      port: 'GTSTC', kind: OperationSourceKind.arrivalBaplie),
              child: const Text('Abrir un contenedor sintético')),
          OutlinedButton(
              onPressed: () => _page(const RecentVoyagesPage()),
              child: const Text('Recientes del dispositivo')),
          OutlinedButton(
              onPressed: () => _page(const VesselProfilesPage()),
              child: const Text('Perfiles guardados')),
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
          if (voyage != null)
            FilledButton(
                onPressed: () => _page(const VesselOverviewPage()),
                child: const Text('Pantalla del producto')),
        ]));
  }
}
