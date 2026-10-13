import 'dart:async';
import 'dart:convert';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/presentation/pages/hatch_covers_page.dart';
import 'package:baystream/features/vessel/presentation/widgets/bay_plan_view.dart';

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
          final repo = await openLocalVesselRepository(namespace: 't83acc');
          ref.onDispose(() => unawaited(repo.close()));
          return repo;
        }),
        movementLogRepositoryProvider.overrideWith((ref) async {
          final repo = await openMovementLogRepository(namespace: 't83acc');
          ref.onDispose(() => unawaited(repo.close()));
          return repo;
        }),
        sessionRepositoryProvider.overrideWith((ref) async {
          final repo = await openSessionRepository(namespace: 't83acc');
          ref.onDispose(() => unawaited(repo.dispose()));
          return repo;
        }),
      ],
      child: MaterialApp(
          title: 'BayStream T-83',
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
  String _message = 'PROVISIONAL · sin cuenta · namespace t83acc';
  bool _busy = false;
  VoyageNotifier get _notifier => ref.read(voyageNotifierProvider.notifier);
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
    final a07 = await rootBundle.loadString('assets/t83-corpus/CORPUS_A07.edi');
    final a08 = await rootBundle.loadString('assets/t83-corpus/CORPUS_A08.edi');
    final arrival = BaplieParserService().parse(a07);
    final loading = BaplieParserService().parse(a08);
    final geometry = VesselGeometry.proposeFrom(
        [...arrival.stowagePositions, ...loading.stowagePositions]);
    for (final entry in [
      (a07, 'CORPUS_A07.edi', OperationSourceKind.arrivalBaplie),
      (a08, 'CORPUS_A08.edi', OperationSourceKind.loadingBaplie)
    ]) {
      final result =
          await _notifier.parseBaplieContent(entry.$1, fileName: entry.$2);
      if (!result.success) {
        throw StateError(result.errorMessage ?? 'No se abrió');
      }
      if (result.needsIdentity) {
        await _notifier.resolveIdentity(_notifier.identityCandidates.first);
      }
      final error = await _notifier.confirmGeometry(geometry,
          portOfCall: 'GTSTC', sourceKind: entry.$3);
      if (error != null) throw StateError(error);
    }
    final original = _notifier.currentProfile!;
    final oldJson = original.toJson()
      ..remove('hatchCovers')
      ..remove('observedHoldBayNumbers');
    final old = VesselProfile.fromJson(
        jsonDecode(jsonEncode(oldJson)) as Map<String, dynamic>);
    final error = await _notifier.saveEditedProfile(original, old);
    if (error != null) throw StateError(error);
    setState(() =>
        _message = 'A07 398 · A08 405 + 55 · perfil histórico sin declarar');
  }

  Future<void> _declare() async {
    final v = _notifier.publishedVoyage!;
    final arrival = BaplieParserService()
        .parse(await rootBundle.loadString('assets/t83-corpus/CORPUS_A07.edi'));
    final original = _notifier.currentProfile!;
    final geometry = original.geometry;
    final holds = {
      ...observedHoldBays(arrival, geometry),
      ...observedHoldBays(v, geometry)
    };
    final bays = holds.toList()..sort();
    final rows = geometry.orderedRows
        .where((r) => r != 0 || geometry.centerRowInHold != false)
        .toList();
    final declarations = <int, HatchCoverDeclaration>{};
    for (var i = 0; i < bays.length; i++) {
      final count = i % 3 + 1;
      declarations[bays[i]] = switch (i % 5) {
        0 => HatchCoverDeclaration(kind: HatchCoverKind.openHold),
        1 => HatchCoverDeclaration(
            kind: HatchCoverKind.automatic, covers: [rows.toSet()]),
        _ => HatchCoverDeclaration(
            kind: HatchCoverKind.crane,
            covers: List.generate(
                count,
                (n) => rows
                    .sublist(n * rows.length ~/ count,
                        (n + 1) * rows.length ~/ count)
                    .toSet())),
      };
    }
    final error = await _notifier.saveEditedProfile(
        original,
        original.copyWith(
            observedHoldBayNumbers: holds,
            hatchCovers: declarations,
            updatedAt: DateTime.now()));
    if (error != null) throw StateError(error);
    setState(() => _message =
        'PROVISIONAL · ${declarations.length} bahías declaradas · filas ${rows.join(', ')}');
  }

  Future<void> _edit() async {
    final original = _notifier.currentProfile!;
    final map = await Navigator.of(context)
        .push<Map<int, HatchCoverDeclaration>>(MaterialPageRoute(
            builder: (_) => HatchCoversPage(
                geometry: original.geometry,
                holdBays: original.observedHoldBayNumbers,
                initial: original.hatchCovers)));
    if (map == null) return;
    final error = await _notifier.saveEditedProfile(original,
        original.copyWith(hatchCovers: map, updatedAt: DateTime.now()));
    if (error != null) throw StateError(error);
    setState(() =>
        _message = 'Edición del producto guardada · ${map.length} bahías');
  }

  Future<void> _restore() async {
    final repo = await ref.read(localVesselRepositoryProvider.future);
    final profiles = (await repo.getAllProfiles()).getOrElse(() => []);
    final voyages = (await repo.getAllVoyages()).getOrElse(() => []);
    if (profiles.isEmpty || voyages.isEmpty) {
      throw StateError('Primero prepara el caso');
    }
    final stored = profiles.single;
    final before = _notifier.currentProfile;
    if (before != null && before != stored) {
      throw StateError('El perfil guardado difiere del visible');
    }
    final error = await _notifier.openRecentVoyage(voyages.first.id);
    if (error != null) throw StateError(error);
    if (_notifier.currentProfile != stored) {
      throw StateError('El perfil reabierto difiere');
    }
    setState(() => _message =
        'Perfil releído igual · ${stored.hatchCovers.length} bahías · ${stored.hatchCoverError ?? 'válido'}');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('T-83 · aceptación PROVISIONAL')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text(_message),
        for (final action in <(String, Future<void> Function())>[
          ('A07/A08 · perfil anterior', _prepare),
          ('Declarar tapas PROVISIONALES', _declare),
          ('Editar y copiar tapas', _edit),
          ('Reabrir y cotejar perfil', _restore),
        ])
          Padding(
              padding: const EdgeInsets.only(top: 12),
              child: FilledButton(
                  onPressed: _busy ? null : () => _run(action.$2),
                  child: Text(action.$1))),
        const SizedBox(height: 12),
        OutlinedButton(
            onPressed: _busy
                ? null
                : () => Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (_) => const VesselOverviewPage())),
            child: const Text('Abrir producto')),
        OutlinedButton(
            onPressed: _busy
                ? null
                : () {
                    final voyage = _notifier.publishedVoyage;
                    if (voyage == null) return;
                    ref.read(selectedBayProvider.notifier).select(6);
                    Navigator.of(context).push(MaterialPageRoute<void>(
                        builder: (_) => Scaffold(
                            appBar: AppBar(
                                title: const Text('PROVISIONAL · plano A08')),
                            body: BayPlanView(voyage: voyage))));
                  },
            child: const Text('Plano · bahía 06')),
      ]));
}
