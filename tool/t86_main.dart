import 'dart:async';

import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_factory.dart';
import 'package:baystream/features/vessel/data/repositories/operation_sync_factory.dart';
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

/// Banco de aceptación local. El selector entrega fixtures al notifier real;
/// el aviso y el plano se muestran en VesselOverviewPage sin cambios.
/// A07 es asset solo en la copia de compilación de %TEMP%, nunca en el repo.
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
  runApp(ProviderScope(
      overrides: [
        voyageNotifierProvider.overrideWith(_FixtureNotifier.new),
        localVesselRepositoryProvider.overrideWith((ref) async {
          final repo = await openLocalVesselRepository(namespace: 't86acc');
          ref.onDispose(() => unawaited(repo.close()));
          return repo;
        }),
        movementLogRepositoryProvider.overrideWith((ref) async {
          final repo = await openMovementLogRepository(namespace: 't86acc');
          ref.onDispose(() => unawaited(repo.close()));
          return repo;
        }),
        sessionRepositoryProvider.overrideWith((ref) async {
          final repo = await openSessionRepository(namespace: 't86acc');
          ref.onDispose(() => unawaited(repo.dispose()));
          return repo;
        }),
      ],
      child: MaterialApp(
          title: 'BayStream T-86',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(useMaterial3: true),
          home: const _Bank())));
}

class _Bank extends ConsumerStatefulWidget {
  const _Bank();
  @override
  ConsumerState<_Bank> createState() => _BankState();
}

class _BankState extends ConsumerState<_Bank> {
  String _message = 'Modo sin cuenta · namespace t86acc';
  bool _busy = false;
  Future<void> _open(String file, {bool prepare = false}) async {
    setState(() => _busy = true);
    try {
      final notifier =
          ref.read(voyageNotifierProvider.notifier) as _FixtureNotifier;
      notifier.source = await rootBundle.loadString('assets/t86-corpus/$file');
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
          final error = await notifier.confirmGeometry(
              VesselProfile.proposeFrom(notifier.pendingVoyage!).geometry,
              portOfCall: 'GTSTC',
              sourceKind: OperationSourceKind.arrivalBaplie);
          if (error != null) throw StateError(error);
        }
        final voyage = notifier.publishedVoyage!;
        setState(() => _message = '${voyage.totalContainers} contenedores · '
            '${voyage.totalWeight.toStringAsFixed(2)} kg · '
            '${voyage.cargoCountsFor('GTSTC')}');
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
        appBar: AppBar(title: const Text('T-86 · aceptación')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Text(_message),
          const SizedBox(height: 16),
          FilledButton(
              onPressed:
                  _busy ? null : () => _open('CORPUS_A07.edi', prepare: true),
              child: const Text('A07 · abrir plano')),
          const SizedBox(height: 12),
          FilledButton(
              onPressed: _busy ? null : () => _open('T86_1x.edi'),
              child: const Text('1.x · probar rechazo')),
          const SizedBox(height: 12),
          FilledButton(
              onPressed: _busy ? null : () => _open('T86_3x.edi'),
              child: const Text('3.x · probar rechazo')),
          const SizedBox(height: 12),
          const Text(
              'En la pantalla BayStream, toca «Cargar archivo BAPLIE» para '
              'probar el archivo elegido. El aviso debe conservar el plano A07.'),
        ]),
      );
}
