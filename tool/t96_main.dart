// Banco T-96. A07, A08, el listado y los eventos del caso se agregan como
// assets SOLO a la copia de compilación en TEMP (t96_inputs/), nunca al repo.
import 'dart:async';
import 'dart:convert';

import 'package:baystream/core/app.dart';
import 'package:baystream/features/vessel/data/repositories/local_only_operation_sync.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_factory.dart';
import 'package:baystream/features/vessel/domain/entities/app_theme_preference.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/operation_sources.dart';
import 'package:baystream/features/vessel/presentation/formatters/operation_text.dart';
import 'package:baystream/features/vessel/presentation/pages/recent_voyages_page.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_overview_page.dart';
import 'package:baystream/features/vessel/presentation/pages/voyage_comparison_page.dart';
import 'package:baystream/features/vessel/presentation/providers/export_list_providers.dart';
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
/// sustituye el diálogo del selector; la lectura, la comparación y las
/// pantallas son las del producto.
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
const _assets = 't96_inputs';
const _ns = 't96acc';

/// El archivo que el «selector» del banco entrega a la comparación.
String _picked = 'CORPUS_A08.edi';

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
    comparisonFilePickerProvider.overrideWithValue(() async => (
          name: _picked,
          content: await rootBundle.loadString('$_assets/$_picked'),
        )),
  ], child: const BayStreamApp(home: _Bank())));
}

class _Bank extends ConsumerStatefulWidget {
  const _Bank();
  @override
  ConsumerState<_Bank> createState() => _BankState();
}

class _BankState extends ConsumerState<_Bank> {
  String _message = 'Modo sin cuenta · namespace t96acc';
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

  Future<VesselVoyage> _open(String file, OperationSourceKind kind) async {
    final notifier = ref.read(voyageNotifierProvider.notifier);
    final text = await rootBundle.loadString('$_assets/$file');
    final result = await notifier.parseBaplieContent(text, fileName: file);
    if (!result.success) throw StateError(result.errorMessage!);
    if (result.needsIdentity) {
      await notifier.resolveIdentity(notifier.identityCandidates.first);
    }
    if (notifier.pendingVoyage != null) {
      final error = await notifier.confirmGeometry(
          notifier.currentProfile?.geometry ??
              VesselProfile.proposeFrom(notifier.pendingVoyage!).geometry,
          portOfCall: 'GTSTC',
          sourceKind: kind);
      if (error != null) throw StateError(error);
    }
    return notifier.publishedVoyage!;
  }

  Future<String> _openArrival() async {
    final v = await _open('CORPUS_A07.edi', OperationSourceKind.arrivalBaplie);
    return 'A07 abierto: ${operationCount(v.totalContainers, 'contenedor', 'contenedores')} · escala GTSTC';
  }

  /// La operación del caso, como el banco de T-82, con los 177 eventos.
  Future<String> _prepareOperation() async {
    final voyage =
        await _open('CORPUS_A08.edi', OperationSourceKind.loadingBaplie);
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
    final log = await ref.read(movementLogRepositoryProvider.future);
    final arrivalText =
        await rootBundle.loadString('$_assets/CORPUS_A07.edi');
    final operation = await OperationSources.save(
        log,
        voyage,
        'GTSTC',
        OperationSource(
            kind: OperationSourceKind.arrivalBaplie,
            fileName: 'CORPUS_A07.edi',
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
        MovementAuthor(name: 'Prueba local T-96', role: OperatorRole.office);
    Future<void> append(MovementDraft draft) async =>
        (await log.append(draft, author)).fold((f) => throw f, (_) {});
    final arrival = (await ref
            .read(vesselRepositoryProvider)
            .parseBaplieFile(arrivalText))
        .fold((f) => throw f, (v) => v);
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
      } else {
        final pos = (e['posicion'] ?? e['celda']) as String;
        await append(e['tipo'] == 'asignar_vacio' &&
                voyage.reservedSlots.any((s) => s.key == 'R:$pos')
            ? MovementDraft.assignEmpty(operation.id, pos, e['contenedor'],
                (e['tara_kg'] as num).toDouble(), order: e['orden'])
            : MovementDraft.loadFull(operation.id, e['contenedor'], pos,
                order: e['orden']));
      }
    }
    return 'Operación preparada: 114 descargas y los 177 eventos, locales.';
  }

  void _page(Widget page) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    final voyage = ref.watch(voyageNotifierProvider).value;
    return Scaffold(
        appBar: AppBar(title: const Text('T-96 · aceptación')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Text(_message, key: const ValueKey('t96-message')),
          Text('El selector de comparar entrega: $_picked'),
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
          for (final file in [
            'CORPUS_A08.edi',
            'CORPUS_A08v_VGM.edi',
            'CORPUS_A07.edi'
          ])
            OutlinedButton(
                onPressed: () => setState(() => _picked = file),
                child: Text('Comparar entregará $file')),
          OutlinedButton(
              onPressed: _busy ? null : () => _run(_openArrival),
              child: const Text('Abrir A07 · llegada GTSTC')),
          OutlinedButton(
              onPressed: _busy ? null : () => _run(_prepareOperation),
              child: const Text('Preparar la operación de A08 con 177 eventos')),
          OutlinedButton(
              onPressed: () => _page(const RecentVoyagesPage()),
              child: const Text('Recientes del dispositivo')),
          if (voyage != null)
            FilledButton(
                onPressed: () => _page(const VesselOverviewPage()),
                child: const Text('Pantalla del producto')),
        ]));
  }
}
