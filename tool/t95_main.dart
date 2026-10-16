// Banco T-95. A07 se agrega como asset SOLO a la copia de compilación en TEMP
// (t95_inputs/), nunca al repo. Las tapas que declara son PROVISIONALES (T-83).
import 'dart:async';
import 'dart:math' as math;

import 'package:baystream/core/app.dart';
import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/data/repositories/local_only_operation_sync.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_factory.dart';
import 'package:baystream/features/vessel/domain/entities/app_theme_preference.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/discharge_sequence.dart';
import 'package:baystream/features/vessel/presentation/formatters/operation_text.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_overview_page.dart';
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
/// abre A07 y declara o quita tapas; el orden de descarga es el del producto.
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
const _assets = 't95_inputs';
const _ns = 't95acc';

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
  String _message = 'Modo sin cuenta · namespace t95acc';
  bool _busy = false;

  Future<void> _run(Future<String> Function() action) async {
    setState(() => _busy = true);
    try {
      final result = await action();
      if (mounted) setState(() => _message = result);
    } catch (error) {
      if (mounted) setState(() => _message = 'NO PASA: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String> _openArrival() async {
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
    return 'A07 abierto: ${operationCount(v.totalContainers, 'contenedor', 'contenedores')} · '
        'escala GTSTC · ${_covers()}';
  }

  /// Tres tapas de grúa por bahía con bodega, de babor a estribor, declaradas
  /// en las pares y en las impares sin par vecina. PROVISIONALES (T-83).
  Future<String> _declare({required bool provisional}) async {
    final notifier = ref.read(voyageNotifierProvider.notifier);
    final voyage = notifier.publishedVoyage;
    final geometry = voyage?.geometry;
    if (voyage == null || geometry == null) {
      throw StateError('Abre A07 primero.');
    }
    final holdBays = (notifier.currentProfile?.observedHoldBayNumbers ??
            observedHoldBays(voyage, geometry))
        .toList()
      ..sort();
    final rows = [
      for (final row in geometry.orderedRows)
        if (geometry.covers(IsoCoordinate(
            bay: 1, row: row, tier: geometry.holdTiers.first, rawCode: '')))
          row,
    ];
    final third = (rows.length / 3).ceil();
    final declaration = HatchCoverDeclaration(kind: HatchCoverKind.crane, covers: [
      for (var i = 0; i < rows.length; i += third)
        rows.sublist(i, math.min(i + third, rows.length)).toSet(),
    ]);
    final covers = provisional
        ? {
            for (final bay in holdBays)
              if (bay.isEven ||
                  !holdBays.any((b) => b.isEven && footprintsTouch(b, bay)))
                bay: declaration,
          }
        : <int, HatchCoverDeclaration>{};
    final error = await notifier.confirmGeometry(geometry,
        portOfCall: voyage.portOfCall, hatchCovers: covers);
    if (error != null) throw StateError(error);
    return provisional
        ? 'Tapas PROVISIONALES: ${covers.length} declaraciones, '
            '${declaration.covers.length} tapas de grúa cada una · ${_covers()}'
        : 'Tapas quitadas del perfil · ${_covers()}';
  }

  String _covers() {
    final covers =
        ref.read(voyageNotifierProvider.notifier).currentProfile?.hatchCovers ??
            const {};
    return covers.isEmpty
        ? 'sin tapas declaradas'
        : 'tapas en ${operationCount(covers.length, 'bahía', 'bahías')}';
  }

  @override
  Widget build(BuildContext context) {
    final voyage = ref.watch(voyageNotifierProvider).value;
    return Scaffold(
        appBar: AppBar(title: const Text('T-95 · aceptación')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Text(_message, key: const ValueKey('t95-message')),
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
              onPressed: _busy ? null : () => _run(_openArrival),
              child: const Text('Abrir A07 · llegada GTSTC')),
          OutlinedButton(
              onPressed: _busy || voyage == null
                  ? null
                  : () => _run(() => _declare(provisional: true)),
              child: const Text('Declarar tapas PROVISIONALES')),
          OutlinedButton(
              onPressed: _busy || voyage == null
                  ? null
                  : () => _run(() => _declare(provisional: false)),
              child: const Text('Quitar las tapas')),
          if (voyage != null)
            FilledButton(
                onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                        builder: (_) => const VesselOverviewPage())),
                child: const Text('Pantalla del producto')),
        ]));
  }
}
