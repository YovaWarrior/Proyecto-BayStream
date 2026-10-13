import 'dart:async';
import 'dart:convert';

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
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Banco local: selector real y notifier real, namespace propio, sin cuenta.
/// No incluye assets del corpus ni sustituye el diálogo de la plataforma.
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const options = kIsWeb ? _web : _android;
  if (options.projectId != 'baystream-app') {
    throw StateError('Solo baystream-app.');
  }
  await Firebase.initializeApp(options: options);
  runApp(ProviderScope(
      overrides: [
        localVesselRepositoryProvider.overrideWith((ref) async {
          final repo = await openLocalVesselRepository(namespace: 't89acc');
          ref.onDispose(() => unawaited(repo.close()));
          return repo;
        }),
        movementLogRepositoryProvider.overrideWith((ref) async {
          final repo = await openMovementLogRepository(namespace: 't89acc');
          ref.onDispose(() => unawaited(repo.close()));
          return repo;
        }),
        sessionRepositoryProvider
            .overrideWith((ref) async => const LocalSessionRepository()),
      ],
      child: MaterialApp(
          title: 'BayStream T-89',
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
  bool _busy = false;
  String _message = 'Selector nativo · cualquier archivo · sin cuenta · t89acc';
  String _storeMessage = 'Todavía no se ha abierto un archivo.';
  String? _storedSnapshot;

  Future<void> _open() async {
    setState(() => _busy = true);
    final notifier = ref.read(voyageNotifierProvider.notifier);
    final previous = notifier.publishedVoyage;
    try {
      final result = await notifier.loadVesselFromFile();
      if (result.isCancelled) {
        setState(() => _message = 'Selección cancelada.');
        return;
      }
      if (!result.success) {
        setState(() => _message = result.errorMessage!);
      } else {
        if (result.needsIdentity) {
          final resolved =
              await notifier.resolveIdentity(notifier.identityCandidates.first);
          if (!resolved.success) {
            throw StateError(
                resolved.errorMessage ?? 'No se resolvió la identidad.');
          }
        }
        if (notifier.pendingVoyage != null) {
          final error = await notifier.confirmGeometry(
              notifier.currentProfile!.geometry,
              portOfCall: 'GTSTC',
              sourceKind: OperationSourceKind.arrivalBaplie);
          if (error != null) throw StateError(error);
        }
        setState(() => _message = 'Abierto: ${result.fileName}');
      }
      // El banco comprueba la persistencia después de la entrada del producto.
      final local = await ref.read(localVesselRepositoryProvider.future);
      final voyages = (await local.getAllVoyages()).getOrElse(() => []);
      final profiles = (await local.getAllProfiles()).getOrElse(() => []);
      final snapshot = jsonEncode([
        voyages.map((v) => v.toJson()).toList(),
        profiles.map((p) => p.toJson()).toList(),
      ]);
      final unchanged = !result.success &&
          identical(previous, notifier.publishedVoyage) &&
          _storedSnapshot == snapshot;
      setState(() {
        _storeMessage =
            'Almacén: ${voyages.length} viajes · ${profiles.length} perfiles'
            '${!result.success ? unchanged ? ' · rechazo conservó viaje y almacén' : ' · comprobar conservación' : ''}';
        _storedSnapshot = snapshot;
      });
    } catch (error) {
      if (mounted) setState(() => _message = '$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final voyage = ref.watch(voyageNotifierProvider).value;
    final stats = ref.watch(voyageStatsProvider);
    return Scaffold(
        appBar: AppBar(title: const Text('T-89 · aceptación')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Text(_message),
          const SizedBox(height: 12),
          Text(_storeMessage),
          if (voyage != null && stats != null) ...[
            const SizedBox(height: 12),
            Text('${voyage.vessel.name} · ${voyage.voyageNumber} · GTSTC'),
            Text(
                '${stats.totalContainers} contenedores · ${stats.totalBays} bahías · ${stats.totalWeight.toStringAsFixed(2)} kg'),
            Text(
                'Escala: ${voyage.cargoCountsFor('GTSTC').loaded} cargas · ${voyage.cargoCountsFor('GTSTC').discharged} descargas · ${voyage.cargoCountsFor('GTSTC').transit} de paso'),
          ],
          const SizedBox(height: 16),
          FilledButton(
              onPressed: _busy ? null : _open,
              child: const Text('Elegir cualquier archivo BAPLIE')),
          OutlinedButton(
              onPressed: voyage == null
                  ? null
                  : () => Navigator.of(context).push(MaterialPageRoute<void>(
                      builder: (_) => const VesselOverviewPage())),
              child: const Text('Ver pantalla y plano del producto')),
          const Text(
              'Banco local: confirma GTSTC y la geometría propuesta solo para esta aceptación.'),
        ]));
  }
}
