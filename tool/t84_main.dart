import 'dart:async';
import 'dart:convert';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_factory.dart';
import 'package:baystream/features/vessel/data/repositories/operation_sync_factory.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/operation_sources.dart';
import 'package:baystream/features/vessel/presentation/pages/cloud_page.dart';
import 'package:baystream/features/vessel/presentation/pages/operation_progress_page.dart';
import 'package:baystream/features/vessel/presentation/providers/discharge_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_operation_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/bay_plan_view.dart';
import 'package:baystream/features/vessel/presentation/widgets/hatch_operation_controls.dart';
import 'package:baystream/features/vessel/presentation/widgets/discharge_controls.dart';
import 'package:baystream/features/vessel/presentation/widgets/loading_controls.dart';
import 'package:baystream/features/vessel/presentation/widgets/sync_status_chip.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Banco sintético sin credenciales ni assets del corpus. Acciones del producto;
/// namespace t84acc en cada cliente. Carlos inicia sesión en «Nube y cuenta».
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
    "UNH+1+BAPLIE:D:95B:UN:SMDG20'TDT+20+T84+++TST:172:20+++9000003:146:11:PRUEBA T-84'LOC+5+HNPCR:139:6'LOC+61+GTSTC:139:6'";
String _cell(String id, String at, {bool load = false, bool transit = false}) =>
    "LOC+147+$at::5'LOC+9+${load ? 'GTSTC' : 'HNPCR'}:139:6'LOC+11+${transit || load ? 'PAMIT' : 'GTSTC'}:139:6'MEA+AAE+WT+KGM:5000'EQD+CN+$id+22G1+++5'";
final _arrival = _header +
    _cell('TSTU0000001', '0030202') +
    _cell('TSTU0000004', '0030282') +
    _cell('TSTU0000005', '0050202', transit: true) +
    _cell('TSTU0000006', '0070202');
final _loading = _header +
    _cell('TSTU0000002', '0030202', load: true) +
    _cell('TSTU0000003', '0030402', load: true) +
    _cell('TSTU0000005', '0050202', transit: true);

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
          final repo = await openLocalVesselRepository(namespace: 't84acc');
          ref.onDispose(() => unawaited(repo.close()));
          return repo;
        }),
        movementLogRepositoryProvider.overrideWith((ref) async {
          final repo = await openMovementLogRepository(namespace: 't84acc');
          ref.onDispose(() => unawaited(repo.close()));
          return repo;
        }),
        sessionRepositoryProvider.overrideWith((ref) async {
          final repo = await openSessionRepository(namespace: 't84acc');
          ref.onDispose(() => unawaited(repo.dispose()));
          return repo;
        }),
      ],
      child: MaterialApp(
          title: 'BayStream T-84',
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
  String _message = 'Datos sintéticos · PROVISIONAL · t84acc';
  VesselVoyage? _arrivalVoyage;
  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      if (mounted) setState(() => _message = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _prepare() async {
    final notifier = ref.read(voyageNotifierProvider.notifier);
    final parser = BaplieParserService();
    final a = parser.parse(_arrival);
    final l = parser.parse(_loading);
    final geometry = VesselGeometry.proposeFrom(
        [...a.stowagePositions, ...l.stowagePositions]);
    for (final source in [
      (_arrival, OperationSourceKind.arrivalBaplie),
      (_loading, OperationSourceKind.loadingBaplie)
    ]) {
      final result = await notifier.parseBaplieContent(source.$1,
          fileName: 'sintetico-${source.$2.name}.edi');
      if (!result.success) throw StateError(result.errorMessage!);
      if (result.needsIdentity) {
        await notifier.resolveIdentity(notifier.identityCandidates.first);
      }
      final error = await notifier.confirmGeometry(geometry,
          portOfCall: 'GTSTC', sourceKind: source.$2);
      if (error != null) throw StateError(error);
    }
    final original = notifier.currentProfile!;
    final error = await notifier.saveEditedProfile(
        original,
        original.copyWith(observedHoldBayNumbers: {
          3,
          5,
          7
        }, hatchCovers: {
          3: HatchCoverDeclaration(kind: HatchCoverKind.crane, covers: [
            {2},
            {4}
          ]),
          5: HatchCoverDeclaration(kind: HatchCoverKind.automatic, covers: [
            {2}
          ]),
        }, updatedAt: DateTime.now()));
    if (error != null) throw StateError(error);
    final voyage = notifier.publishedVoyage!;
    final log = await ref.read(movementLogRepositoryProvider.future);
    final list = ExportList(fileName: 'sintetico.xlsx', rows: [
      for (var n = 1; n <= 2; n++)
        ExportListRow(
            sheetRow: n,
            order: n,
            containerId: 'TSTU000000${n + 1}',
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
    setState(() {
      _arrivalVoyage = a.withGeometry(geometry, portOfCall: 'GTSTC');
      _message =
          'PRUEBA T-84 preparada · 3 tapas PROVISIONALES · bahía 07 sin declarar';
    });
  }

  Future<void> _restore() async {
    final local = await ref.read(localVesselRepositoryProvider.future);
    final voyages = (await local.getAllVoyages()).getOrElse(() => []);
    if (voyages.isEmpty) {
      throw StateError('Primero prepara o abre la operación');
    }
    final notifier = ref.read(voyageNotifierProvider.notifier);
    final error = await notifier.openRecentVoyage(voyages.first.id);
    if (error != null) throw StateError(error);
    final loading = notifier.publishedVoyage!;
    _arrivalVoyage = BaplieParserService()
        .parse(_arrival)
        .withGeometry(loading.geometry!, portOfCall: 'GTSTC');
    setState(() => _message = 'Almacén reabierto · t84acc');
  }

  @override
  Widget build(BuildContext context) {
    final voyage = ref.watch(voyageNotifierProvider).value;
    final operator = ref.watch(operatorProvider).value;
    final operation = voyage == null
        ? null
        : ref.watch(loadingOperationProvider(voyage)).value;
    return Scaffold(
        appBar: AppBar(title: const Text('T-84 · aceptación PROVISIONAL')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Text(_message),
        Text('Rol: ${operator?.role.name ?? 'sin cuenta'}'),
          const SyncStatusChip(),
          if (operation != null) ...[
            Text(
                'Bitácora: ${operation.movements.length} · conflictos: ${operation.state.conflicts.length}'),
            for (final cover in operation.state.hatchCovers.values)
              Text(
                  '${cover.key} · ${cover.label} · ${cover.removed ? 'quitada' : cover.movementId == null ? 'puesta' : 'repuesta'}'),
          ],
          FilledButton(
              onPressed: _busy ? null : () => _run(_prepare),
              child: const Text('Preparar PRUEBA T-84 sintética')),
          OutlinedButton(
              onPressed: _busy ? null : () => _run(_restore),
              child: const Text('Reabrir almacén')),
          OutlinedButton(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const CloudPage())),
              child: const Text('Nube y cuenta · Carlos')),
          if (voyage != null) ...[
            OutlinedButton(
                onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                        builder: (_) =>
                            HatchOperationPage(voyage: voyage, initialBay: 3))),
                child: const Text('Tapas · producto')),
            OutlinedButton(
                onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                        builder: (_) => OperationProgressPage(voyage: voyage))),
                child: const Text('Avance · producto')),
            OutlinedButton(
                onPressed: () {
                  ref.read(selectedBayProvider.notifier).select(3);
                  Navigator.of(context).push(MaterialPageRoute<void>(
                      builder: (_) => Scaffold(
                          appBar: AppBar(title: const Text('Plano sintético')),
                          body: BayPlanView(voyage: voyage))));
                },
                child: const Text('Plano · producto')),
            Consumer(builder: (context, ref, _) {
              if (_arrivalVoyage == null) return const SizedBox.shrink();
              ref.watch(dischargeProgressProvider(_arrivalVoyage!));
              return OutlinedButton(
                  onPressed: () => onDischargeTap(context, ref, _arrivalVoyage!,
                      _arrivalVoyage!.containers.first,
                      openDetails: () {}),
                  child: const Text('Descargar bodega · aviso del producto'));
            }),
            OutlinedButton(
                onPressed: operation?.list == null
                    ? null
                    : () => openLoadingRow(
                        context, ref, voyage, operation!.list!.byOrder(2)!),
                child: const Text('Cargar OR 2 · aviso del producto')),
          ],
        ]));
  }
}
