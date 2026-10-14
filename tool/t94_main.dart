// Banco T-94: se compila en TEMP. Sus tres assets se añaden SOLO al pubspec
// de esa copia desde el corpus externo; nunca se guardan en el repositorio.
import 'dart:async';
import 'dart:convert';

import 'package:baystream/core/app.dart';
import 'package:baystream/features/vessel/data/repositories/local_only_operation_sync.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_factory.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/data/services/export_list_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/export_list_cross_checker.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_operation_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/loading_controls.dart';
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const options = kIsWeb ? _web : _android;
  if (options.projectId != 'baystream-app') {
    throw StateError('Solo baystream-app.');
  }
  await Firebase.initializeApp(options: options);
  runApp(ProviderScope(overrides: [
    localVesselRepositoryProvider.overrideWith((ref) async {
      final repo = await openLocalVesselRepository(namespace: 't94acc');
      ref.onDispose(() => unawaited(repo.close()));
      return repo;
    }),
    movementLogRepositoryProvider.overrideWith((ref) async {
      final repo = await openMovementLogRepository(namespace: 't94acc');
      ref.onDispose(() => unawaited(repo.close()));
      return repo;
    }),
    sessionRepositoryProvider
        .overrideWith((ref) async => const LocalSessionRepository()),
  ], child: const BayStreamApp(home: _Bank())));
}

class _Bank extends ConsumerStatefulWidget {
  const _Bank();
  @override
  ConsumerState<_Bank> createState() => _BankState();
}

class _BankState extends ConsumerState<_Bank> {
  VesselVoyage? _voyage;
  ExportList? _list;
  String? _error;
  @override
  void initState() {
    super.initState();
    unawaited(_prepare());
  }

  Future<void> _prepare() async {
    try {
      final arrival = await rootBundle.loadString('t94_inputs/CORPUS_A07.edi');
      final loading = await rootBundle.loadString('t94_inputs/CORPUS_A08.edi');
      final parsed = BaplieParserService().parse(loading);
      final voyage = parsed.withGeometry(
          VesselProfile.proposeFrom(parsed).geometry,
          portOfCall: 'GTSTC');
      final bytes = await rootBundle.load('t94_inputs/LISTADO_A08.xlsx');
      final raw = const ExportListParserService().parseXlsx(
          bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
          fileName: 'LISTADO_A08.xlsx');
      final proposals =
          ExportListCrossChecker.propose(raw, voyage, portOfCall: 'GTSTC')
              .map((p) => p.kind == EquivalenceKind.type && p.listCode == '40RF'
                  ? p.choose('45R1')
                  : p)
              .toList();
      final list = raw.normalized(ExportListCrossChecker.tableOf(proposals));
      final repo = await ref.read(movementLogRepositoryProvider.future);
      final existing =
          (await repo.getOperation('t94-local')).fold((f) => throw f, (v) => v);
      final operation = existing ??
          Operation(
              id: 't94-local',
              vesselName: voyage.vessel.name,
              voyageNumber: voyage.voyageNumber,
              portOfCall: 'GTSTC',
              createdAt: DateTime.now(),
              sources: [
                OperationSource(
                    kind: OperationSourceKind.arrivalBaplie,
                    fileName: 'CORPUS_A07.edi',
                    content: arrival),
                OperationSource(
                    kind: OperationSourceKind.loadingBaplie,
                    fileName: 'CORPUS_A08.edi',
                    content: loading),
                OperationSource(
                    kind: OperationSourceKind.exportList,
                    fileName: 'LISTADO_A08.xlsx',
                    content: jsonEncode(list.toJson())),
              ]);
      (await repo.saveOperation(operation)).fold((f) => throw f, (_) {});
      if (mounted) {
        setState(() {
          _voyage = voyage;
          _list = list;
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final voyage = _voyage;
    final data = voyage == null
        ? null
        : ref.watch(loadingOperationProvider(voyage)).value;
    return Scaffold(
        appBar: AppBar(title: const Text('T-94 · búsqueda del muelle')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('t94acc · Solo este dispositivo · sin cuenta'),
            if (_error != null) Text(_error!),
            if (voyage == null && _error == null)
              const Text('Preparando caso anonimizado…'),
            if (voyage != null) ...[
              Text(
                  '${voyage.totalContainers} contenedores · ${voyage.totalReservedSlots} reservas'),
              if (data != null) ...[
                const Text(
                    'Dicta el contenedor completo de OR 1; después, los últimos cuatro dígitos de OR 3.'),
                for (final row
                    in _list!.rows.where((r) => r.order == 1 || r.order == 3))
                  Text(
                      'OR ${row.order}: ${row.containerId} · sufijo ${row.containerId.substring(row.containerId.length - 4)}'),
              ],
              LoadingControls(voyage: voyage),
            ],
          ],
        ));
  }
}
