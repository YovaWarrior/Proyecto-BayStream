// Banco de aceptación T-106: fuentes sintéticas, sesión real y namespace t106acc.
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

const _header =
    "UNH+1+BAPLIE:D:95B:UN:SMDG20'TDT+20+T106+++TST:172:20+++9000003:146:11:PRUEBA T-106'LOC+5+HNPCR:139:6'LOC+61+GTSTC:139:6'";

/// Una celda sintética. Lo que sube aquí va de GTSTC a PAMIT; lo que llega
/// viene de HNPCR y baja en GTSTC, salvo la carga de paso, que sigue a PAMIT.
String _cell(String id, String at,
        {bool load = false, bool transit = false, String type = '22G1'}) =>
    "LOC+147+$at::5'LOC+9+${load ? 'GTSTC' : 'HNPCR'}:139:6'"
    "LOC+11+${load || transit ? 'PAMIT' : 'GTSTC'}:139:6'"
    "MEA+AAE+WT+KGM:5000'EQD+CN+$id+$type+++5'";

/// Llegada: dos descargas pendientes (una en la 0030082, que el plan deja
/// vacía, y otra en la 0050682, vecina de la par) y una carga de paso.
final _arrival = _header +
    _cell('TSTU0000011', '0030082') +
    _cell('TSTU0000012', '0050482', transit: true) +
    _cell('TSTU0000013', '0050682');

/// Carga: tres 20 en la 003 y un 40 en la 004, con la carga de paso.
final _loading = _header +
    _cell('TSTU0000001', '0030282', load: true) +
    _cell('TSTU0000002', '0030482', load: true) +
    _cell('TSTU0000003', '0030682', load: true) +
    _cell('TSTU0000004', '0040882', load: true, type: '45G1') +
    _cell('TSTU0000012', '0050482', transit: true);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const options = kIsWeb ? _web : _android;
  if (options.projectId != 'baystream-app') {
    throw StateError('Solo baystream-app.');
  }
  await Firebase.initializeApp(options: options);
  runApp(ProviderScope(overrides: [
    localVesselRepositoryProvider.overrideWith((ref) async {
      final repo = await openLocalVesselRepository(namespace: 't106acc');
      ref.onDispose(() => unawaited(repo.close()));
      return repo;
    }),
    movementLogRepositoryProvider.overrideWith((ref) async {
      final repo = await openMovementLogRepository(namespace: 't106acc');
      ref.onDispose(() => unawaited(repo.close()));
      return repo;
    }),
    sessionRepositoryProvider.overrideWith((ref) async {
      final repo = await openSessionRepository(namespace: 't106acc');
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
      title: 'BayStream T-106',
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
  String message = 'PRUEBA T-106 · sintética · PROVISIONAL · t106acc';
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
    // La misma geometría sintética de PRUEBA T-105: el perfil no cambia.
    const geometry = VesselGeometry(
        portRows: 4,
        starboardRows: 3,
        holdTiers: [2, 4],
        deckTiers: [82, 84],
        centerRowOnDeck: true,
        centerRowInHold: true);
    for (final source in [
      (_arrival, OperationSourceKind.arrivalBaplie),
      (_loading, OperationSourceKind.loadingBaplie),
    ]) {
      final result = await notifier.parseBaplieContent(source.$1,
          fileName: 'PRUEBA_T106_${source.$2.name}.edi');
      if (!result.success) throw StateError(result.errorMessage!);
      if (result.needsIdentity) {
        await notifier.resolveIdentity(notifier.identityCandidates.first);
      }
      final error = await notifier.confirmGeometry(geometry,
          portOfCall: 'GTSTC', sourceKind: source.$2);
      if (error != null) throw StateError(error);
    }
    final voyage = notifier.publishedVoyage!;
    final log = await ref.read(movementLogRepositoryProvider.future);
    final list = ExportList(fileName: 'sintetico.xlsx', rows: [
      for (var n = 1; n <= 4; n++)
        ExportListRow(
            sheetRow: n,
            order: n,
            containerId: 'TSTU000000$n',
            status: ContainerStatus.full,
            listType: n == 4 ? '45G1' : '22G1',
            listPod: 'PAMIT',
            listLine: '',
            tareKg: n == 4 ? 3800 : 2100,
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
          () => message = 'Preparada. Publicar PRUEBA T-106 en Nube y cuenta.');
    }
  }

  Future<void> reopen() async {
    final repo = await ref.read(localVesselRepositoryProvider.future);
    final voyages = (await repo.getAllVoyages()).getOrElse(() => []);
    final target =
        voyages.where((v) => v.vessel.name == 'PRUEBA T-106').firstOrNull;
    if (target == null) {
      throw StateError('Únete a PRUEBA T-106 en Nube y cuenta.');
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
        appBar: AppBar(title: const Text('T-106 · aceptación'), actions: [
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
                  'Movimientos ${data.movements.length} · llegada ${data.plan.arrival.length} · '
                  'carga ${data.plan.loading.length} · conflictos ${data.state.conflicts.length}',
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
