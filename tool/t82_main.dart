import 'dart:async';
import 'dart:convert';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_factory.dart';
import 'package:baystream/features/vessel/data/repositories/operation_sync_factory.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/operation_sources.dart';
import 'package:baystream/features/vessel/presentation/pages/departure_baplie_page.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_overview_page.dart';
import 'package:baystream/features/vessel/presentation/providers/export_list_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/sync_status_chip.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Banco T-82. Assets del corpus solo en la copia EXTERNA de aceptación.
/// Operación y movimientos locales, namespace t82acc. No publica ni modifica
/// datos de Firestore. Carlos introduce cualquier credencial en la app.
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
const _assets = 'assets/t82-corpus';
const _ns = 't82acc';

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
          final repo = await openSessionRepository(namespace: _ns);
          ref.onDispose(() => unawaited(repo.dispose()));
          return repo;
        }),
      ],
      child: MaterialApp(
          title: 'BayStream T-82',
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
  String _message = 'T-82 · generación local · namespace t82acc';
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

  Future<String> _prepare() async {
    final notifier = ref.read(voyageNotifierProvider.notifier);
    final source = await rootBundle.loadString('$_assets/CORPUS_A08.edi');
    final read =
        await notifier.parseBaplieContent(source, fileName: 'T82_A08.edi');
    if (!read.success) throw StateError(read.errorMessage ?? 'No se leyó A08');
    if (read.needsGeometry) {
      final error = await notifier.confirmGeometry(
          VesselProfile.proposeFrom(notifier.pendingVoyage!).geometry,
          portOfCall: 'GTSTC',
          sourceKind: OperationSourceKind.loadingBaplie);
      if (error != null) throw StateError(error);
    }
    final keep = ref.listenManual(exportListImportProvider, (_, __) {});
    try {
      final importer = ref.read(exportListImportProvider.notifier);
      final bytes = await rootBundle.load('$_assets/LISTADO_A08.xlsx');
      await importer.loadBytes(bytes.buffer.asUint8List(),
          fileName: 'LISTADO_A08.xlsx');
      importer.choose(EquivalenceKind.type, '40RF', '45R1');
      final error = await importer.confirm();
      if (error != null) throw StateError(error);
    } finally {
      keep.close();
    }
    final voyage = ref.read(voyageNotifierProvider).value!;
    final log = await ref.read(movementLogRepositoryProvider.future);
    final arrivalText = await rootBundle.loadString('$_assets/CORPUS_A07.edi');
    final operation = await OperationSources.save(
        log,
        voyage,
        'GTSTC',
        OperationSource(
            kind: OperationSourceKind.arrivalBaplie,
            fileName: 'A07.edi',
            content: arrivalText));
    ref.read(operationSourcesRevisionProvider.notifier).changed();
    final records =
        (await log.records(operation.id)).fold((f) => throw f, (r) => r);
    if (records.isNotEmpty) {
      return 'Operación existente: ${records.length} registros locales.';
    }
    final list = ExportList.fromJson(
        jsonDecode(operation.source(OperationSourceKind.exportList)!.content)
            as Map<String, dynamic>);
    const author =
        MovementAuthor(name: 'Prueba local T-82', role: OperatorRole.office);
    Future<void> append(MovementDraft draft) async =>
        (await log.append(draft, author)).fold((f) => throw f, (_) {});
    await append(MovementDraft.cancelItem(operation.id,
        'C:${list.byOrder(5)!.containerId}', 'No embarca: prueba T-82'));
    final arrival = BaplieParserService().parse(arrivalText);
    for (final c
        in arrival.containers.where((c) => c.portOfDischarge == 'GTSTC')) {
      await append(MovementDraft.discharge(
          operation.id, c.containerId, c.stowagePosition!.toIsoCode()));
    }
    final events = ((jsonDecode(
                await rootBundle.loadString('$_assets/CASO_A08_EVENTOS.json'))
            as Map)['eventos'] as List)
        .cast<Map<String, dynamic>>();
    for (final e in events) {
      if (e['tipo'] == 'cambio_de_posicion') {
        await append(MovementDraft.changePosition(
            operation.id,
            [
              for (final or in (e['ordenes'] as List).cast<int>())
                PositionChange('C:${list.byOrder(or)!.containerId}',
                    e['plan']['$or'], e['nuevo']['$or'])
            ],
            'Intercambio del caso'));
      } else if (e['orden'] != 5) {
        final pos = (e['posicion'] ?? e['celda']) as String;
        await append(e['tipo'] == 'asignar_vacio' &&
                voyage.reservedSlots.any((s) => s.key == 'R:$pos')
            ? MovementDraft.assignEmpty(operation.id, pos, e['contenedor'],
                (e['tara_kg'] as num).toDouble(), order: e['orden'])
            : MovementDraft.loadFull(operation.id, e['contenedor'], pos,
                order: e['orden']));
      }
    }
    return 'Preparado: 459 a bordo, OR 5 cancelado, cero cargas pendientes.';
  }

  Future<String> _restore() async {
    final operation = await ref.read(activeOperationProvider.future);
    if (operation == null) throw StateError('Prepara el caso primero.');
    final log = await ref.read(movementLogRepositoryProvider.future);
    final records =
        (await log.records(operation.id)).fold((f) => throw f, (r) => r);
    final cancel = records
        .firstWhere((r) => r.movement.type == MovementType.cancelItem)
        .movement;
    const author =
        MovementAuthor(name: 'Prueba local T-82', role: OperatorRole.office);
    (await log.append(
            MovementDraft.annul(operation.id, cancel.id, 'Sí embarca'), author))
        .fold((f) => throw f, (_) {});
    final events = ((jsonDecode(
                await rootBundle.loadString('$_assets/CASO_A08_EVENTOS.json'))
            as Map)['eventos'] as List)
        .cast<Map<String, dynamic>>();
    final e = events.firstWhere((e) => e['orden'] == 5);
    (await log.append(
            MovementDraft.loadFull(operation.id, e['contenedor'], e['posicion'],
                order: 5),
            author))
        .fold((f) => throw f, (_) {});
    return 'OR 5 restaurado: 460 a bordo, cero cancelados y cero pendientes.';
  }

  Future<String> _openSaved() async {
    final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['edi'], withData: true);
    if (picked == null) return 'Apertura cancelada.';
    final bytes = picked.files.single.bytes;
    if (bytes == null) throw StateError('El selector no entregó el archivo.');
    final reread = BaplieParserService().parse(utf8.decode(bytes));
    final expected =
        (await rootBundle.loadString('$_assets/CASO_A08_ESTADO_FINAL.csv'))
            .split('\n')
            .skip(1)
            .where((r) => r.trim().isNotEmpty)
            .map((r) => r.trim().split(','))
            .toList();
    final actual = {
      for (final c in reread.containers) c.stowagePosition!.toIsoCode(): c
    };
    var matched = 0;
    for (final row in expected) {
      final c = actual[row[0]];
      if (c != null &&
          c.containerId == row[1] &&
          c.isoSizeType == row[2] &&
          c.portOfLoading == row[4] &&
          c.portOfDischarge == row[5] &&
          c.operatorCode == row[6] &&
          c.effectiveWeight == double.parse(row[7])) {
        matched++;
      }
    }
    if (actual.length != 460 || matched != 460) {
      throw StateError('Relectura: $matched/460, ${actual.length} ocupantes.');
    }
    return 'PASA: archivo guardado abierto por BayStream, 460/460 en siete campos.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          title: const Text('T-82 · aceptación'),
          actions: const [SyncAppBarButton()]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text(_message),
        TextButton(
            onPressed: _busy ? null : () => _run(_prepare),
            child: const Text('Preparar caso con OR 5 cancelado')),
        TextButton(
            onPressed: _busy ? null : () => _run(_restore),
            child: const Text('Anular cancelación y cargar OR 5')),
        TextButton(
            onPressed: _busy
                ? null
                : () {
                    final voyage = ref.read(voyageNotifierProvider).value;
                    if (voyage != null) {
                      Navigator.of(context).push(MaterialPageRoute<void>(
                          builder: (_) => DepartureBapliePage(voyage: voyage)));
                    }
                  },
            child: const Text('Abrir salida del producto')),
        TextButton(
            onPressed: _busy ? null : () => _run(_openSaved),
            child: const Text('Abrir archivo guardado y comparar')),
        TextButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => const VesselOverviewPage())),
            child: const Text('Abrir BayStream')),
        if (_busy) const LinearProgressIndicator(),
      ]));
}
