// Banco T-103. A06 y las fuentes sintéticas se agregan como assets SOLO a la
// copia de compilación en TEMP, nunca al repositorio.
import 'dart:async';

import 'package:baystream/core/app.dart';
import 'package:baystream/features/vessel/data/repositories/local_only_operation_sync.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_factory.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_overview_page.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Banco de aceptación local en modo sin cuenta: la sesión es local y nada
/// sube a la nube. El selector entrega los assets al notifier real; el aviso,
/// la salida, los rechazos y Recientes son los de la pantalla del producto.
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

class _FixtureNotifier extends VoyageNotifier {
  String source = '';
  String fileName = '';
  @override
  Future<LoadFileResult> loadVesselFromFile() =>
      parseBaplieContent(source, fileName: fileName);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const options = kIsWeb ? _web : _android;
  if (options.projectId != 'baystream-app') {
    throw StateError('Solo baystream-app.');
  }
  await Firebase.initializeApp(options: options);
  runApp(ProviderScope(overrides: [
    voyageNotifierProvider.overrideWith(_FixtureNotifier.new),
    localVesselRepositoryProvider.overrideWith((ref) async {
      final repo = await openLocalVesselRepository(namespace: 't103acc');
      ref.onDispose(() => unawaited(repo.close()));
      return repo;
    }),
    movementLogRepositoryProvider.overrideWith((ref) async {
      final repo = await openMovementLogRepository(namespace: 't103acc');
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
  String _message = 'Modo sin cuenta · namespace t103acc';
  bool _busy = false;

  Future<void> _open(String file, {bool prepare = false}) async {
    setState(() => _busy = true);
    try {
      final notifier =
          ref.read(voyageNotifierProvider.notifier) as _FixtureNotifier;
      notifier.source = await rootBundle.loadString('assets/t103-corpus/$file');
      notifier.fileName = file;
      if (prepare) {
        final result = await notifier.loadVesselFromFile();
        if (!result.success) {
          throw StateError(result.errorMessage ?? 'No se abrió');
        }
        if (result.needsIdentity) {
          await notifier.resolveIdentity(notifier.identityCandidates.first);
        }
        if (notifier.pendingVoyage != null) {
          // A06 sale de GTPBR (LOC+5) y no declara la siguiente escala.
          final error = await notifier.confirmGeometry(
              VesselProfile.proposeFrom(notifier.pendingVoyage!).geometry,
              portOfCall: 'GTPBR',
              sourceKind: OperationSourceKind.loadingBaplie);
          if (error != null) throw StateError(error);
        }
        final voyage = notifier.publishedVoyage!;
        setState(() => _message = '${voyage.totalContainers} contenedores · '
            '${voyage.bays.length} bahías · '
            '${voyage.totalWeight.toStringAsFixed(2)} kg · '
            'aviso 1.5: ${voyage.metadata?.readWithV2Rules ?? false}');
      }
      if (mounted) {
        await Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => const VesselOverviewPage()));
      }
    } catch (error) {
      if (mounted) setState(() => _message = '$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('T-103 · aceptación')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Text(_message, key: const ValueKey('t103-message')),
          const SizedBox(height: 16),
          FilledButton(
              onPressed:
                  _busy ? null : () => _open('CORPUS_A06.edi', prepare: true),
              child: const Text('A06 · abrir con aviso')),
          const SizedBox(height: 12),
          FilledButton(
              onPressed: _busy ? null : () => _open('T103_1x.edi'),
              child: const Text('1.x sintética · rechazo')),
          const SizedBox(height: 12),
          FilledButton(
              onPressed: _busy ? null : () => _open('t86_smdg31.edi'),
              child: const Text('3.x · rechazo')),
          const SizedBox(height: 12),
          FilledButton(
              onPressed: _busy ? null : () => _open('t86_sin_unh.edi'),
              child: const Text('Sin UNH · rechazo')),
          const SizedBox(height: 12),
          const Text(
              'En la pantalla BayStream, «Cargar archivo BAPLIE» prueba el '
              'archivo elegido: el rechazo debe conservar A06. «Limpiar datos» '
              'y «Viajes recientes» reabren A06 con su aviso.'),
        ]),
      );
}
