import 'dart:async';

import 'package:baystream/core/app.dart';
import 'package:baystream/features/vessel/data/repositories/local_only_operation_sync.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_factory.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/operation_sources.dart';
import 'package:baystream/features/vessel/presentation/pages/export_list_import_page.dart';
import 'package:baystream/features/vessel/presentation/pages/hatch_covers_page.dart';
import 'package:baystream/features/vessel/presentation/pages/operation_progress_page.dart';
import 'package:baystream/features/vessel/presentation/pages/parameters_page.dart';
import 'package:baystream/features/vessel/presentation/pages/recent_voyages_page.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_geometry_page.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_overview_page.dart';
import 'package:baystream/features/vessel/presentation/providers/export_list_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/theme_preference_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/containers_list_view.dart';
import 'package:baystream/features/vessel/presentation/widgets/reserved_slot_details.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _web = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_WEB_API_KEY'),
    appId: String.fromEnvironment('FIREBASE_WEB_APP_ID'),
    messagingSenderId: String.fromEnvironment('FIREBASE_WEB_MESSAGING_SENDER_ID'),
    projectId: String.fromEnvironment('FIREBASE_WEB_PROJECT_ID'),
    authDomain: String.fromEnvironment('FIREBASE_WEB_AUTH_DOMAIN'),
    storageBucket: String.fromEnvironment('FIREBASE_WEB_STORAGE_BUCKET'));
const _android = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_ANDROID_API_KEY'),
    appId: String.fromEnvironment('FIREBASE_ANDROID_APP_ID'),
    messagingSenderId: String.fromEnvironment('FIREBASE_ANDROID_MESSAGING_SENDER_ID'),
    projectId: String.fromEnvironment('FIREBASE_ANDROID_PROJECT_ID'),
    storageBucket: String.fromEnvironment('FIREBASE_ANDROID_STORAGE_BUCKET'));

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const options = kIsWeb ? _web : _android;
  if (options.projectId != 'baystream-app') throw StateError('Solo baystream-app.');
  await Firebase.initializeApp(options: options);
  runApp(ProviderScope(overrides: [
    localVesselRepositoryProvider.overrideWith((ref) async {
      final repo = await openLocalVesselRepository(namespace: 't90acc');
      ref.onDispose(() => unawaited(repo.close()));
      return repo;
    }),
    movementLogRepositoryProvider.overrideWith((ref) async {
      final repo = await openMovementLogRepository(namespace: 't90acc');
      ref.onDispose(() => unawaited(repo.close()));
      return repo;
    }),
    sessionRepositoryProvider.overrideWith((ref) async => const LocalSessionRepository()),
  ], child: BayStreamApp(home: const _Bank(), builder: (context, child) => Center(
    child: SizedBox(width: 360, child: LayoutBuilder(builder: (context, constraints) => MediaQuery(
      data: MediaQuery.of(context).copyWith(size: Size(constraints.maxWidth, constraints.maxHeight)), child: child!,
    ))),
  ))));
}

class _Bank extends ConsumerStatefulWidget {
  const _Bank();
  @override
  ConsumerState<_Bank> createState() => _BankState();
}

class _BankState extends ConsumerState<_Bank> {
  String _message = 't90acc · sin cuenta · selector real';
  bool _busy = false;
  Future<void> _prepareList() async {
    final subscription = ref.listenManual(exportListImportProvider, (_, __) {});
    setState(() => _busy = true);
    try {
      final importer = ref.read(exportListImportProvider.notifier);
      await importer.pickFile();
      if (ref.read(exportListImportProvider).list == null) return;
      // Equivalencia de aceptación de LISTADO_A08, ya comprobada en T-73.
      importer.choose(EquivalenceKind.type, '40RF', '45R1');
      final error = await importer.confirm();
      if (error != null) throw StateError(error);
      setState(() => _message = 'Listado guardado para el barrido de Número de orden.');
    } catch (error) {
      setState(() => _message = '$error');
    } finally {
      subscription.close();
      if (mounted) setState(() => _busy = false);
    }
  }
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
        if (result.needsIdentity) await notifier.resolveIdentity(notifier.identityCandidates.first);
        if (notifier.pendingVoyage != null) {
          final pending = notifier.pendingVoyage!;
          final profile = notifier.currentProfile!;
          final holds = observedHoldBays(pending, profile.geometry);
          // Declaración de aceptación PROVISIONAL, no especificación del buque.
          final hatches = {for (final bay in holds) bay: HatchCoverDeclaration(
            kind: HatchCoverKind.automatic, covers: [profile.geometry.orderedRows
                .where((row) => row != 0 || profile.geometry.centerRowInHold != false).toSet()],
          )};
          final error = await notifier.confirmGeometry(profile.geometry, portOfCall: 'GTSTC',
            sourceKind: OperationSources.baplieKind(pending, 'GTSTC'),
            hatchCovers: hatches, observedHoldBayNumbers: holds);
          if (error != null) throw StateError(error);
        }
      }
      final voyage = notifier.publishedVoyage!;
      final preference = await ref.read(themePreferenceProvider.future);
      setState(() => _message = '${voyage.totalContainers} contenedores · '
        '${voyage.totalReservedSlots} reservas · ${voyage.bays.length} bahías · '
        '${voyage.totalWeight.toStringAsFixed(0)} kg\nTema releído: ${preference.name}');
    } catch (error) {
      setState(() => _message = '$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _page(Widget page) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    final voyage = ref.watch(voyageNotifierProvider).value;
    final preference = ref.watch(themePreferenceProvider).value;
    final profile = ref.read(voyageNotifierProvider.notifier).currentProfile;
    return Scaffold(appBar: AppBar(title: const Text('T-90 · aceptación')), body: ListView(
      padding: const EdgeInsets.all(16), children: [
        Text(_message),
        Text('Tema: ${preference?.name ?? "leyendo"} · efectivo: ${Theme.of(context).brightness.name} · sistema: ${MediaQuery.platformBrightnessOf(context).name}'),
        FilledButton(onPressed: _busy ? null : () => _open(), child: const Text('Elegir BAPLIE')),
        OutlinedButton(onPressed: _busy ? null : () => _open(restore: true), child: const Text('Reabrir viaje guardado')),
        OutlinedButton(onPressed: () => _page(const ParametersPage()), child: const Text('Parámetros')),
        OutlinedButton(onPressed: () => _page(const RecentVoyagesPage()), child: const Text('Viajes recientes')),
        if (voyage != null) ...[
          OutlinedButton(onPressed: () => _page(const VesselOverviewPage()), child: const Text('Pantalla del producto')),
          OutlinedButton(onPressed: () => _page(OperationProgressPage(voyage: voyage)), child: const Text('Avance de la operación')),
          OutlinedButton(onPressed: () => _page(const ExportListImportPage()), child: const Text('Importación del listado')),
          OutlinedButton(onPressed: _busy ? null : _prepareList, child: const Text('Preparar listado para OR (banco)')),
          OutlinedButton(onPressed: () => _page(Scaffold(appBar: AppBar(title: const Text('Contenedor reefer · barrido')),
            body: ContainersListView(containers: [voyage.containers.firstWhere((c) => c.isReefer, orElse: () => voyage.containers.first)]))),
            child: const Text('Detalle de contenedor')),
          if (voyage.reservedSlots.isNotEmpty)
            OutlinedButton(onPressed: () => showReservedSlotDetails(context, voyage.reservedSlots.first, voyage: voyage), child: const Text('Detalle de reserva')),
          if (profile != null)
            OutlinedButton(onPressed: () => _page(VesselGeometryPage(proposal: profile.geometry, initial: profile.geometry,
              profile: profile, profileOnly: true)), child: const Text('Perfil con tapas PROVISIONALES')),
          if (profile != null)
            OutlinedButton(onPressed: () => _page(HatchCoversPage(geometry: profile.geometry,
              holdBays: profile.observedHoldBayNumbers, initial: profile.hatchCovers)),
              child: const Text('Tapas del perfil PROVISIONALES')),
        ],
      ],
    ));
  }
}
