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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// T-79 · Punto de entrada de las pruebas entre dispositivos de T-79a 7.3,
/// como `tool/h5_main.dart`: la app real (plano, «Nube y cuenta», bitácora,
/// cola y motor) contra el **emulador local** de Firebase, con un banco que
/// solo prepara las fuentes y reproduce el caso por el mismo camino de la
/// app: `append` → cola en Hive → motor. No escribe documentos a mano.
///
/// Nunca toca un proyecto en la nube: sin un `T79_PROJECT` que empiece por
/// `demo-` no arranca. El corpus no está en el repositorio: la compilación
/// privada lo agrega como assets en `assets/t77-corpus/`, como los bancos de
/// T-76 a T-78.
///
///     flutter run -t tool/t79_replay_main.dart -d <dispositivo>
///         --dart-define=T79_PROJECT=demo-t79 --dart-define=T79_NS=t79c2
///         --dart-define=T79_EMAIL=... --dart-define=T79_PASSWORD=...
///
/// En el Honor, el emulador llega por `adb reverse` de los puertos 9199 y 8181.
const _project = String.fromEnvironment('T79_PROJECT');
const _host = String.fromEnvironment('T79_HOST', defaultValue: '127.0.0.1');
const _authPort = int.fromEnvironment('T79_AUTH_PORT', defaultValue: 9199);
const _firestorePort = int.fromEnvironment('T79_FIRESTORE_PORT', defaultValue: 8181);
const _namespace = String.fromEnvironment('T79_NS', defaultValue: 't79emu');
const _email = String.fromEnvironment('T79_EMAIL');
const _password = String.fromEnvironment('T79_PASSWORD');
const _pace = int.fromEnvironment('T79_PACE_MS', defaultValue: 250);
const _corpus = 'assets/t77-corpus';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!_project.startsWith('demo-')) {
    runApp(const MaterialApp(
        home: Scaffold(
            body: Center(
                child: Text('T-79: solo contra el emulador local (T79_PROJECT=demo-…).')))));
    return;
  }
  // Con `demoProjectId` y sin nombre, la app no sería la predeterminada y
  // `FirebaseAuth.instance` no la encontraría (como en la espiga de T-70).
  await Firebase.initializeApp(name: '[DEFAULT]', demoProjectId: _project);
  await FirebaseAuth.instance
      .useAuthEmulator(_host, _authPort, automaticHostMapping: false);
  FirebaseFirestore.instance
      .useFirestoreEmulator(_host, _firestorePort, automaticHostMapping: false);
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D47A1))),
      darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0D47A1), brightness: Brightness.dark)),
      home: const _Replay(),
    ),
  ));
}

class _Replay extends ConsumerStatefulWidget {
  const _Replay();
  @override
  ConsumerState<_Replay> createState() => _ReplayState();
}

class _ReplayState extends ConsumerState<_Replay> {
  String _message = 'T-79 · emulador $_project · namespace $_namespace';
  bool _busy = false;
  bool _showBank = true;
  StreamSubscription<List<MovementRecord>>? _approvals;
  Map<String, String>? _expected;

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

  Future<String> _signIn() async {
    final session = await ref.read(sessionRepositoryProvider.future);
    final result = await session.signIn(_email, _password);
    return result.fold((f) => 'Sesión: ${f.message}',
        (o) => 'Sesión: ${o.name} · ${o.role.name}${o.authorized ? '' : ' · sin autorizar'}');
  }

  /// Oficina: A08 con su escala y el listado, como en la pantalla.
  Future<String> _prepareOffice() async {
    final notifier = ref.read(voyageNotifierProvider.notifier);
    final text = await rootBundle.loadString('$_corpus/CORPUS_A08.edi');
    final read = await notifier.parseBaplieContent(text, fileName: 'CORPUS_A08.edi');
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
    return 'A08 y el listado en la operación local. Publícala en «Nube y cuenta».';
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
            r.movement.payload['request'] == id);
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

  /// Muelle: los 177 eventos del caso, retomando donde quedó tras un cierre.
  Future<String> _replay() async {
    final (operation, log) = await _active();
    final voyage = ref.read(voyageNotifierProvider).value!;
    final data = await ref.read(loadingOperationProvider(voyage).future);
    final list = data.list;
    if (list == null) throw StateError('La operación no tiene listado.');
    final events = ((jsonDecode(await rootBundle.loadString('$_corpus/CASO_A08_EVENTOS.json'))
            as Map)['eventos'] as List)
        .cast<Map<String, dynamic>>();
    var registered = 0, skipped = 0;
    for (final event in events) {
      var existing = (await log.records(operation.id)).getOrElse(() => const []);
      bool has(bool Function(Movement m) test) => existing.any((r) => test(r.movement));
      final MovementDraft draft;
      if (event['tipo'] == 'cambio_de_posicion') {
        if (has((m) => m.type == MovementType.requestChange)) {
          skipped++;
          continue;
        }
        final before = (event['plan'] as Map).cast<String, String>();
        final after = (event['nuevo'] as Map).cast<String, String>();
        draft = MovementDraft.raw(operation.id, MovementType.requestChange, null, {
          'changes': [
            for (final order in (event['ordenes'] as List).cast<int>())
              {
                'target': 'C:${list.byOrder(order)!.containerId}',
                'from': before['$order'],
                'to': after['$order'],
              }
          ],
          'reason': 'Intercambio en bodega 14',
        });
      } else {
        final position = (event['posicion'] ?? event['celda']) as String;
        final empty = event['tipo'] == 'asignar_vacio' &&
            data.plan.loading.containsKey('R:$position');
        final target = empty ? 'R:$position' : 'C:${event['contenedor']}';
        if (has((m) =>
            m.target == target &&
            (m.type == MovementType.loadFull || m.type == MovementType.assignEmpty))) {
          skipped++;
          continue;
        }
        if (event['orden'] == 128 || event['orden'] == 145) {
          // El muelle espera a ver la aprobación antes de cargar (C2).
          while (!has((m) => m.type == MovementType.changePosition)) {
            if (mounted) setState(() => _message = 'Esperando la aprobación de la oficina…');
            await Future<void>.delayed(const Duration(milliseconds: 500));
            existing = (await log.records(operation.id)).getOrElse(() => const []);
          }
        }
        draft = empty
            ? MovementDraft.assignEmpty(operation.id, position, event['contenedor'],
                (event['tara_kg'] as num).toDouble(),
                order: event['orden'])
            : MovementDraft.loadFull(operation.id, event['contenedor'], position,
                order: event['orden']);
      }
      final result = await log.append(draft, ref.read(movementAuthorProvider));
      result.fold((f) => throw StateError(f.message), (_) => registered++);
      if (mounted) {
        setState(() => _message = 'Evento ${event['n']} de 177 · registrados $registered');
      }
      await Future<void>.delayed(const Duration(milliseconds: _pace));
    }
    return 'Reproducción: $registered registrados, $skipped ya estaban.';
  }

  /// C4: tres movimientos del caso que todavía no estén en la bitácora.
  Future<String> _three() async {
    final (operation, log) = await _active();
    final events = ((jsonDecode(await rootBundle.loadString('$_corpus/CASO_A08_EVENTOS.json'))
            as Map)['eventos'] as List)
        .cast<Map<String, dynamic>>()
        .where((e) => e['tipo'] == 'confirmar_lleno');
    final existing = (await log.records(operation.id)).getOrElse(() => const []);
    var count = 0;
    for (final event in events) {
      if (count == 3) break;
      if (existing.any((r) => r.movement.target == 'C:${event['contenedor']}')) continue;
      (await log.append(
              MovementDraft.loadFull(operation.id, event['contenedor'], event['posicion'],
                  order: event['orden']),
              ref.read(movementAuthorProvider)))
          .fold((f) => throw StateError(f.message), (_) => count++);
    }
    return '$count movimientos registrados.';
  }

  /// C5 a C7: un movimiento nuevo cuando ya no quedan cargas, por el mismo
  /// camino que «Deshacer» en el detalle: anula la última carga propia.
  Future<String> _annulOne() async {
    final (operation, log) = await _active();
    final records = (await log.records(operation.id)).getOrElse(() => const []);
    final author = ref.read(movementAuthorProvider);
    final annulled = {
      for (final r in records)
        if (r.movement.type == MovementType.annul) r.movement.annuls
    };
    final candidates = records.reversed.where((r) =>
        r.movement.type == MovementType.loadFull &&
        r.movement.author.uid == author.uid &&
        r.state == SendState.confirmed &&
        !annulled.contains(r.movement.id));
    if (candidates.isEmpty) return 'No hay una carga propia confirmada para anular.';
    final target = candidates.first.movement;
    final record = (await log.append(
            MovementDraft.annul(operation.id, target.id, 'Prueba de T-79', target: target.target),
            author))
        .fold((f) => throw StateError(f.message), (r) => r);
    return 'Anulada ${target.target} · ${record.state.name}';
  }

  Future<String> _check() async {
    final (operation, log) = await _active();
    final records = (await log.records(operation.id)).getOrElse(() => const []);
    final byState = <SendState, int>{};
    for (final r in records) {
      byState[r.state] = (byState[r.state] ?? 0) + 1;
    }
    final voyage = ref.read(voyageNotifierProvider).value!;
    final data = await ref.read(loadingOperationProvider(voyage).future);
    _expected ??= {
      for (final row in (await rootBundle.loadString('$_corpus/CASO_A08_ESTADO_FINAL.csv'))
          .split('\n')
          .skip(1)
          .where((line) => line.trim().isNotEmpty)
          .map((line) => line.trim().split(',')))
        row[0]: row[1]
    };
    final occupancy = data.state.occupancy;
    final same = _expected!.entries.where((e) => occupancy[e.key] == e.value).length;
    final ids = records.map((r) => r.movement.id).toSet().length;
    return 'Registros ${records.length} (ids distintos $ids) · '
        '${byState.entries.map((e) => '${e.key.name} ${e.value}').join(', ')} · '
        'posiciones iguales al CSV $same/${_expected!.length} · '
        'conflictos ${data.state.conflicts.length} · pendientes de carga ${data.progress.total}'
        '${records.where((r) => r.rejection != null).map((r) => ' · rechazado: ${r.rejection}').join()}';
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
              if (_email.isNotEmpty) button('Entrar', _signIn),
              button('Salir', _signOut),
              button('Preparar oficina', _prepareOffice),
              button(_approvals == null ? 'Aprobar solicitudes' : 'Dejar de aprobar',
                  _toggleApprovals),
              button('Reproducir 177', _replay),
              button('Registrar 3', _three),
              button('Anular uno', _annulOne),
              button('Comprobar', _check),
              button('Verificar sesión', _verify),
            ]),
            Text(
                '${operator == null ? 'Sin sesión' : '${operator.name} · ${operator.role.name}'}'
                ' · ${status == null ? '…' : syncStatusText(status)}\n$_message',
                key: const ValueKey('t79-replay-message'),
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
