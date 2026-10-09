import 'dart:async';
import 'dart:convert';

import 'package:baystream/core/errors/failures.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_factory.dart';
import 'package:baystream/features/vessel/data/repositories/operation_sync_factory.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/movement_log_repository.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_overview_page.dart';
import 'package:baystream/features/vessel/presentation/providers/export_list_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_operation_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/sync_status_chip.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// T-79 · C9 de T-79a 7.4: la app real contra `baystream-app`, con las
/// opciones de producción por `--dart-define-from-file`, igual que
/// `lib/main.dart`. Solo cambia dos cosas:
///
/// - el namespace del almacén local (`T79_NS`), para no anexar movimientos de
///   prueba en el almacén de Carlos (AGENTS, 10.11);
/// - un banco que se oculta, para lo que la pantalla de T-79 todavía no
///   ofrece: el intercambio y su aprobación (T-80) y la aprobación forzada
///   desde el muelle, que la nube tiene que negar.
///
/// Las sesiones se abren en «Nube y cuenta»: el banco no lleva correos ni
/// contraseñas. Sin `baystream-app` como proyecto no arranca: nunca el de H5.
/// El corpus no está en el repositorio: la compilación privada lo agrega como
/// assets en `assets/t77-corpus/`, como `tool/t79_replay_main.dart`.
///
///     flutter build windows -t tool/t79_c9_main.dart --dart-define=T79_NS=t79prod
///         --dart-define-from-file=<opciones de producción>
const _firebaseWebOptions = FirebaseOptions(
  apiKey: String.fromEnvironment('FIREBASE_WEB_API_KEY'),
  appId: String.fromEnvironment('FIREBASE_WEB_APP_ID'),
  messagingSenderId: String.fromEnvironment('FIREBASE_WEB_MESSAGING_SENDER_ID'),
  projectId: String.fromEnvironment('FIREBASE_WEB_PROJECT_ID'),
  authDomain: String.fromEnvironment('FIREBASE_WEB_AUTH_DOMAIN'),
  storageBucket: String.fromEnvironment('FIREBASE_WEB_STORAGE_BUCKET'),
);

const _firebaseAndroidOptions = FirebaseOptions(
  apiKey: String.fromEnvironment('FIREBASE_ANDROID_API_KEY'),
  appId: String.fromEnvironment('FIREBASE_ANDROID_APP_ID'),
  messagingSenderId:
      String.fromEnvironment('FIREBASE_ANDROID_MESSAGING_SENDER_ID'),
  projectId: String.fromEnvironment('FIREBASE_ANDROID_PROJECT_ID'),
  storageBucket: String.fromEnvironment('FIREBASE_ANDROID_STORAGE_BUCKET'),
);

const _project = 'baystream-app';
const _namespace = String.fromEnvironment('T79_NS', defaultValue: 't79prod');
const _vessel = 'PRUEBA T-79';
const _corpus = 'assets/t77-corpus';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const options = kIsWeb ? _firebaseWebOptions : _firebaseAndroidOptions;
  if (options.projectId != _project || options.apiKey.trim().isEmpty) {
    runApp(const MaterialApp(
        home: Scaffold(
            body: Center(child: Text('T-79 · C9: solo contra baystream-app.')))));
    return;
  }
  await Firebase.initializeApp(options: options);
  runApp(ProviderScope(
    overrides: [
      localVesselRepositoryProvider.overrideWith((ref) async {
        final repository = await openLocalVesselRepository(namespace: _namespace);
        ref.onDispose(() => unawaited(repository.close()));
        return repository;
      }),
      movementLogRepositoryProvider.overrideWith((ref) async {
        final repository = await openMovementLogRepository(namespace: _namespace);
        ref.onDispose(() => unawaited(repository.close()));
        return repository;
      }),
      sessionRepositoryProvider.overrideWith((ref) async {
        final session = await openSessionRepository(namespace: _namespace);
        ref.onDispose(() => unawaited(session.dispose()));
        return session;
      }),
    ],
    child: MaterialApp(
      title: 'BayStream',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D47A1))),
      darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0D47A1), brightness: Brightness.dark)),
      home: const _C9(),
    ),
  ));
}

class _C9 extends ConsumerStatefulWidget {
  const _C9();
  @override
  ConsumerState<_C9> createState() => _C9State();
}

class _C9State extends ConsumerState<_C9> {
  String _message = 'T-79 · C9 · $_project · namespace $_namespace';
  bool _busy = false;
  bool _showBank = true;
  StreamSubscription<List<MovementRecord>>? _approvals;

  @override
  void dispose() {
    unawaited(_approvals?.cancel());
    super.dispose();
  }

  Future<void> _run(Future<String> Function() action) async {
    setState(() => _busy = true);
    try {
      final done = await action();
      if (mounted) setState(() => _message = done);
    } catch (error) {
      if (mounted) setState(() => _message = 'NO PASA: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<List<Map<String, dynamic>>> _events() async =>
      ((jsonDecode(await rootBundle.loadString('$_corpus/CASO_A08_EVENTOS.json'))
              as Map)['eventos'] as List)
          .cast<Map<String, dynamic>>();

  /// Oficina: A08 con el buque «PRUEBA T-79» y el listado, por los mismos
  /// lectores que la pantalla. Publicar se hace en «Nube y cuenta».
  Future<String> _prepareOffice() async {
    final notifier = ref.read(voyageNotifierProvider.notifier);
    final text = (await rootBundle.loadString('$_corpus/CORPUS_A08.edi'))
        .replaceFirst(':ZZZ:BUQUE GOLF', ':ZZZ:$_vessel');
    final read = await notifier.parseBaplieContent(text, fileName: 'PRUEBA_T79_A08.edi');
    if (!read.success) throw StateError(read.errorMessage ?? 'No se leyó A08');
    if (read.needsGeometry) {
      final error = await notifier.confirmGeometry(
          VesselProfile.proposeFrom(notifier.pendingVoyage!).geometry,
          portOfCall: 'GTSTC');
      if (error != null) throw StateError(error);
    }
    final listener = ref.listenManual(exportListImportProvider, (_, __) {});
    try {
      final importer = ref.read(exportListImportProvider.notifier);
      final bytes = await rootBundle.load('$_corpus/LISTADO_A08.xlsx');
      await importer.loadBytes(bytes.buffer.asUint8List(), fileName: 'LISTADO_A08.xlsx');
      importer.choose(EquivalenceKind.type, '40RF', '45R1');
      final error = await importer.confirm();
      if (error != null) throw StateError(error);
    } finally {
      listener.close();
    }
    return '$_vessel y el listado en la operación local. Publícala en «Nube y cuenta».';
  }

  Future<(Operation, MovementLogRepository)> _active() async {
    final operation = await ref.read(activeOperationProvider.future);
    if (operation == null) throw StateError('Abre el plan de carga de la escala.');
    return (operation, await ref.read(movementLogRepositoryProvider.future));
  }

  /// Oficina: aprueba cada solicitud del muelle cuando le llega.
  Future<String> _toggleApprovals() async {
    if (_approvals != null) {
      await _approvals!.cancel();
      _approvals = null;
      return 'Aprobación automática apagada.';
    }
    final (operation, log) = await _active();
    final approving = <String>{};
    _approvals = log.watch(operation.id).listen((records) async {
      for (final request
          in records.where((r) => r.movement.type == MovementType.requestChange)) {
        final id = request.movement.id;
        final approved = records.any((r) =>
            r.movement.type == MovementType.changePosition &&
            r.movement.payload['request'] == id &&
            r.movement.author.role == OperatorRole.office);
        if (approved || !approving.add(id)) continue;
        await log.append(
            MovementDraft.raw(operation.id, MovementType.changePosition, null, {
              'changes': request.movement.payload['changes'],
              'request': id,
              'reason': 'Intercambio aprobado por la oficina',
            }),
            ref.read(movementAuthorProvider));
        if (mounted) setState(() => _message = 'Solicitud aprobada.');
      }
    });
    return 'Aprobación automática encendida.';
  }

  /// Muelle: el intercambio de las órdenes 128 y 145 del caso.
  Future<String> _requestSwap() async {
    final (operation, log) = await _active();
    final records = (await log.records(operation.id)).getOrElse(() => const []);
    if (records.any((r) => r.movement.type == MovementType.requestChange)) {
      return 'La solicitud ya está en la bitácora.';
    }
    final voyage = ref.read(voyageNotifierProvider).value!;
    final list = (await ref.read(loadingOperationProvider(voyage).future)).list;
    if (list == null) throw StateError('La operación no tiene listado.');
    final event = (await _events()).firstWhere((e) => e['tipo'] == 'cambio_de_posicion');
    final before = (event['plan'] as Map).cast<String, String>();
    final after = (event['nuevo'] as Map).cast<String, String>();
    final record = (await log.append(
            MovementDraft.raw(operation.id, MovementType.requestChange, null, {
              'changes': [
                for (final order in (event['ordenes'] as List).cast<int>())
                  {
                    'target': 'C:${list.byOrder(order)!.containerId}',
                    'from': before['$order'],
                    'to': after['$order'],
                  }
              ],
              'reason': 'Intercambio en bodega 14',
            }),
            ref.read(movementAuthorProvider)))
        .fold((f) => throw StateError(f.message), (r) => r);
    return 'Solicitud registrada · ${record.state.name}';
  }

  /// Muelle: la aprobación que la pantalla no le ofrece, forzada por el mismo
  /// camino de la app. Las reglas tienen que negarla.
  Future<String> _forceApproval() async {
    final (operation, log) = await _active();
    final records = (await log.records(operation.id)).getOrElse(() => const []);
    final request = records
        .where((r) => r.movement.type == MovementType.requestChange)
        .firstOrNull;
    if (request == null) return 'Primero, la solicitud del intercambio.';
    final record = (await log.append(
            MovementDraft.raw(operation.id, MovementType.changePosition, null, {
              'changes': request.movement.payload['changes'],
              'request': request.movement.id,
              'reason': 'Aprobación forzada desde el muelle (C9)',
            }),
            ref.read(movementAuthorProvider)))
        .fold((f) => throw StateError(f.message), (r) => r);
    return 'Aprobación forzada registrada · ${record.state.name}';
  }

  /// Tres llenos del caso que todavía no estén en la bitácora, sin las
  /// órdenes del intercambio.
  Future<String> _three() async {
    final (operation, log) = await _active();
    final existing = (await log.records(operation.id)).getOrElse(() => const []);
    var count = 0;
    for (final event in (await _events()).where((e) => e['tipo'] == 'confirmar_lleno')) {
      if (count == 3) break;
      if (event['orden'] == 128 || event['orden'] == 145) continue;
      if (existing.any((r) => r.movement.target == 'C:${event['contenedor']}')) continue;
      (await log.append(
              MovementDraft.loadFull(operation.id, event['contenedor'], event['posicion'],
                  order: event['orden']),
              ref.read(movementAuthorProvider)))
          .fold((f) => throw StateError(f.message), (_) => count++);
    }
    return '$count movimientos registrados.';
  }

  Future<String> _check() async {
    final (operation, log) = await _active();
    final records = (await log.records(operation.id)).getOrElse(() => const []);
    final byState = <SendState, int>{};
    final byType = <MovementType, int>{};
    for (final r in records) {
      byState[r.state] = (byState[r.state] ?? 0) + 1;
      byType[r.movement.type] = (byType[r.movement.type] ?? 0) + 1;
    }
    final voyage = ref.read(voyageNotifierProvider).value!;
    final data = await ref.read(loadingOperationProvider(voyage).future);
    final ids = records.map((r) => r.movement.id).toSet().length;
    return 'Registros ${records.length} (ids distintos $ids) · '
        '${byState.entries.map((e) => '${e.key.name} ${e.value}').join(', ')} · '
        '${byType.entries.map((e) => '${e.key.name} ${e.value}').join(', ')} · '
        'conflictos ${data.state.conflicts.length} · pendientes de carga ${data.progress.total}'
        '${records.where((r) => r.rejection != null).map((r) => ' · rechazado ${r.movement.type.name} (${r.movement.author.role.name}): ${r.rejection}').join()}';
  }

  Future<String> _verify() async {
    final session = await ref.read(sessionRepositoryProvider.future);
    await session.verify();
    return 'Sesión comprobada: ${session.current == null ? 'sin sesión' : session.current!.name}';
  }

  Future<String> _signOut() async {
    final session = await ref.read(sessionRepositoryProvider.future);
    return (await session.signOut()).fold((Failure f) => f.message, (_) => 'Sesión cerrada.');
  }

  @override
  Widget build(BuildContext context) {
    // El plan derivado se descarta solo si nadie lo mira: el banco lo
    // mantiene vivo aunque la pestaña visible no sea el plano.
    final voyage = ref.watch(voyageNotifierProvider).value;
    if (voyage?.portOfCall != null) ref.watch(loadingOperationProvider(voyage!));
    final status = ref.watch(syncStatusProvider).value;
    final operator = ref.watch(operatorProvider).value;
    Widget button(String label, Future<String> Function() action) => TextButton(
        onPressed: _busy ? null : () => _run(action), child: Text(label));
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          if (_showBank) ...[
            Wrap(spacing: 4, children: [
              button('Preparar oficina', _prepareOffice),
              button(_approvals == null ? 'Aprobar solicitudes' : 'Dejar de aprobar',
                  _toggleApprovals),
              button('Solicitar intercambio', _requestSwap),
              button('Forzar aprobación', _forceApproval),
              button('Registrar 3', _three),
              button('Comprobar', _check),
              button('Verificar sesión', _verify),
              button('Salir', _signOut),
            ]),
            Text(
                '${operator == null ? 'Sin sesión' : '${operator.name} · ${operator.role.name}'}'
                ' · ${status == null ? '…' : syncStatusText(status)}\n$_message',
                key: const ValueKey('t79-c9-message'),
                style: Theme.of(context).textTheme.bodySmall),
          ],
          TextButton(
              onPressed: () => setState(() => _showBank = !_showBank),
              child: Text(_showBank ? 'Ocultar banco' : 'Mostrar banco')),
          const Expanded(child: VesselOverviewPage()),
        ]),
      ),
    );
  }
}
