// Banco de aceptación T-105: fuentes sintéticas, sesión real y namespace t105acc.
// Carlos inicia sesión. Este banco nunca escribe credenciales ni usa el corpus.
import 'dart:async';
import 'dart:convert';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_factory.dart';
import 'package:baystream/features/vessel/data/repositories/operation_sync_factory.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/operation_sources.dart';
import 'package:baystream/features/vessel/presentation/pages/cloud_page.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_operation_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/bay_plan_view.dart';
import 'package:baystream/features/vessel/presentation/widgets/sync_status_chip.dart';
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const options = kIsWeb ? _web : _android;
  if (options.projectId != 'baystream-app') {
    throw StateError('Solo baystream-app.');
  }
  await Firebase.initializeApp(options: options);
  runApp(ProviderScope(overrides: [
    localVesselRepositoryProvider.overrideWith((ref) async {
      final repo = await openLocalVesselRepository(namespace: 't105acc');
      ref.onDispose(() => unawaited(repo.close()));
      return repo;
    }),
    movementLogRepositoryProvider.overrideWith((ref) async {
      final repo = await openMovementLogRepository(namespace: 't105acc');
      ref.onDispose(() => unawaited(repo.close()));
      return repo;
    }),
    sessionRepositoryProvider.overrideWith((ref) async {
      final repo = await openSessionRepository(namespace: 't105acc');
      ref.onDispose(() => unawaited(repo.dispose()));
      return repo;
    }),
  ], child: const _AcceptanceApp()));
}

class _AcceptanceApp extends StatefulWidget {
  const _AcceptanceApp();
  @override
  State<_AcceptanceApp> createState() => _AcceptanceAppState();
}

class _AcceptanceAppState extends State<_AcceptanceApp> {
  bool dark = false;
  @override
  Widget build(BuildContext context) => MaterialApp(
      title: 'BayStream T-105',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: _Bank(onTheme: () => setState(() => dark = !dark)));
}

class _Bank extends ConsumerStatefulWidget {
  final VoidCallback onTheme;
  const _Bank({required this.onTheme});
  @override
  ConsumerState<_Bank> createState() => _BankState();
}

class _BankState extends ConsumerState<_Bank> {
  bool busy = false;
  bool showBank = true;
  String message = 'PRUEBA T-105 · sintética · PROVISIONAL · t105acc';
  Future<void> run(Future<void> Function() action) async {
    setState(() => busy = true);
    try {
      await action();
    } catch (e) {
      if (mounted) setState(() => message = '$e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> prepare() async {
    if (ref.read(operatorProvider).value?.role != OperatorRole.office) {
      throw StateError('Carlos debe iniciar sesión de oficina.');
    }
    final notifier = ref.read(voyageNotifierProvider.notifier);
    const header =
        "UNH+1+BAPLIE:D:95B:UN:SMDG20'TDT+20+T105+++TST:172:20+++9000003:146:11:PRUEBA T-105'LOC+5+HNPCR:139:6'LOC+61+GTSTC:139:6'";
    String cell(int n, String position) =>
        "LOC+147+$position::5'LOC+9+GTSTC:139:6'LOC+11+PAMIT:139:6'MEA+AAE+WT+KGM:5000'EQD+CN+TSTU000000$n+22G1+++5'";
    final result = await notifier.parseBaplieContent(
        header + cell(1, '0030282') + cell(2, '0030482') + cell(3, '0030682'),
        fileName: 'PRUEBA_T105_sintetica.edi');
    if (!result.success) throw StateError(result.errorMessage!);
    if (result.needsIdentity) {
      await notifier.resolveIdentity(notifier.identityCandidates.first);
    }
    const geometry = VesselGeometry(
        portRows: 4,
        starboardRows: 3,
        holdTiers: [2, 4],
        deckTiers: [82, 84],
        centerRowOnDeck: true,
        centerRowInHold: true);
    final error = await notifier.confirmGeometry(geometry,
        portOfCall: 'GTSTC', sourceKind: OperationSourceKind.loadingBaplie);
    if (error != null) throw StateError(error);
    final voyage = notifier.publishedVoyage!;
    final log = await ref.read(movementLogRepositoryProvider.future);
    final list = ExportList(fileName: 'sintetico.xlsx', rows: [
      for (var n = 1; n <= 3; n++)
        ExportListRow(
            sheetRow: n,
            order: n,
            containerId: 'TSTU000000$n',
            status: ContainerStatus.full,
            listType: '22G1',
            listPod: 'PAMIT',
            listLine: '',
            tareKg: 2100,
            vgmKg: 5000)
    ]);
    await OperationSources.save(
        log,
        voyage,
        'GTSTC',
        OperationSource(
            kind: OperationSourceKind.exportList,
            fileName: 'sintetico.xlsx',
            content: jsonEncode(list.toJson())));
    ref.read(operationSourcesRevisionProvider.notifier).changed();
    if (mounted) {
      setState(
          () => message = 'Preparada. Publicar PRUEBA T-105 en Nube y cuenta.');
    }
  }

  Future<void> reopen() async {
    final repo = await ref.read(localVesselRepositoryProvider.future);
    final voyages = (await repo.getAllVoyages()).getOrElse(() => []);
    final target =
        voyages.where((v) => v.vessel.name == 'PRUEBA T-105').firstOrNull;
    if (target == null) {
      throw StateError('Únete a PRUEBA T-105 en Nube y cuenta.');
    }
    final error = await ref
        .read(voyageNotifierProvider.notifier)
        .openRecentVoyage(target.id);
    if (error != null) throw StateError(error);
  }

  @override
  Widget build(BuildContext context) {
    final voyage = ref.watch(voyageNotifierProvider).value;
    final actor = ref.watch(operatorProvider).value;
    final data = voyage?.portOfCall == null
        ? null
        : ref.watch(loadingOperationProvider(voyage!)).value;
    return Scaffold(
        appBar: AppBar(title: const Text('T-105 · aceptación'), actions: [
          IconButton(
              onPressed: widget.onTheme, icon: const Icon(Icons.brightness_6)),
          TextButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute<void>(builder: (_) => const CloudPage())),
              child: const Text('Nube y cuenta')),
        ]),
        body: SafeArea(
            child: Column(children: [
          TextButton(
              onPressed: () => setState(() => showBank = !showBank),
              child: Text(showBank ? 'Ocultar banco' : 'Mostrar banco')),
          if (showBank) ...[
            Text(message, style: Theme.of(context).textTheme.bodySmall),
            Text('Rol: ${actor?.role.name ?? 'sin sesión'}'),
            if (voyage != null) const SyncStatusChip(),
            Wrap(children: [
              TextButton(
                  onPressed: busy ? null : () => run(prepare),
                  child: const Text('Preparar sintética')),
              TextButton(
                  onPressed: busy ? null : () => run(reopen),
                  child: const Text('Reabrir')),
            ]),
            if (data != null)
              Text(
                  'Movimientos ${data.movements.length} · pendientes ${data.progress.total} · conflictos ${data.state.conflicts.length}\n'
                  '${data.plan.loading.values.map((i) => '${i.key}: ${i.plannedPosition}').join(' · ')}',
                  style: Theme.of(context).textTheme.bodySmall),
          ],
          if (voyage != null)
            Expanded(child: BayPlanView(voyage: voyage))
          else
            const Expanded(
                child: Center(
                    child: Text(
                        'Carlos inicia sesión para preparar o unirse a la operación.'))),
        ])));
  }
}
