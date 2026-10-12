import 'dart:async';
import 'dart:convert';

import 'package:baystream/core/errors/failures.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_factory.dart';
import 'package:baystream/features/vessel/data/repositories/operation_sync_factory.dart';
import 'package:baystream/features/vessel/data/repositories/firestore_operation_sync.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/movement_log_repository.dart';
import 'package:baystream/features/vessel/presentation/pages/vessel_overview_page.dart';
import 'package:baystream/features/vessel/presentation/providers/export_list_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_operation_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/sync_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:baystream/features/vessel/presentation/widgets/sync_status_chip.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

/// Banco privado T-80 contra baystream-app. Usa la app, los lectores, la
/// bitácora y el motor reales. Las solicitudes y decisiones se prueban desde
/// sus pantallas; el banco prepara fuentes, reproduce cargas y muestra conteos.
/// Carlos autorizó además el intento negativo de aprobación desde el muelle.
/// Carlos introduce credenciales en «Nube y cuenta».
/// Corpus como assets SOLO en una copia externa al repositorio.
/// Compilar con T80_NS=t80acc y las opciones privadas por define-from-file.
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
const _namespace = String.fromEnvironment('T80_NS', defaultValue: 't80acc');
const _vessel = 'PRUEBA T-80';
const _corpus = 'assets/t77-corpus';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const options = kIsWeb ? _firebaseWebOptions : _firebaseAndroidOptions;
  if (options.projectId != _project || options.apiKey.trim().isEmpty) {
    runApp(const MaterialApp(
        home: Scaffold(
            body: Center(child: Text('T-80 · aceptación: solo contra baystream-app.')))));
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
  String _message = 'T-80 · aceptación · $_project · namespace $_namespace';
  bool _busy = false;
  bool _showBank = true;


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

  /// Oficina: A08 con el buque «PRUEBA T-80» y el listado, por los mismos
  /// lectores que la pantalla. Publicar se hace en «Nube y cuenta».
  Future<String> _prepareOffice() async {
    final notifier = ref.read(voyageNotifierProvider.notifier);
    final text = (await rootBundle.loadString('$_corpus/CORPUS_A08.edi'))
        .replaceFirst(':ZZZ:BUQUE GOLF', ':ZZZ:$_vessel');
    final read = await notifier.parseBaplieContent(text, fileName: 'PRUEBA_T80_A08.edi');
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

  /// Solo el corpus privado: las solicitudes y decisiones se hacen desde
  /// las pantallas de T-80, sin aprobación automática ni cambio forzado.
  Future<String> _loadCase() async {
    final (operation, log) = await _active();
    final actor = ref.read(operatorProvider).value;
    if (operation.vesselName != _vessel || actor?.authorized != true ||
        actor?.role != OperatorRole.dock) {
      throw StateError('Solo muelle autorizado sobre PRUEBA T-80.');
    }
    final existing = (await log.records(operation.id)).getOrElse(() => const []);
    final orders = existing.where((r) => r.movement.type == MovementType.loadFull ||
        r.movement.type == MovementType.assignEmpty).map((r) => r.movement.payload['order']).toSet();
    final voyage = ref.read(voyageNotifierProvider).value!;
    final data = await ref.read(loadingOperationProvider(voyage).future);
    var count = 0;
    for (final event in (await _events()).where((e) => e['tipo'] != 'cambio_de_posicion')) {
      if (orders.contains(event['orden'])) continue;
      final position = (event['posicion'] ?? event['celda']) as String;
      final reason = event['orden'] == 128 || event['orden'] == 145
          ? 'Intercambio 128-145 solicitado a la oficina' : null;
      final draft = event['tipo'] == 'asignar_vacio' && data.plan.loading.containsKey('R:$position')
          ? MovementDraft.assignEmpty(operation.id, position, event['contenedor'],
              (event['tara_kg'] as num).toDouble(), order: event['orden'])
          : MovementDraft.loadFull(operation.id, event['contenedor'], position,
              order: event['orden'], reason: reason);
      (await log.append(draft, actor!.author)).fold((f) => throw StateError(f.message), (_) => count++);
    }
    return '$count cargas del caso registradas; revisa el envío y la bandeja.';
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
    final csv = (await rootBundle.loadString('$_corpus/CASO_A08_ESTADO_FINAL.csv'))
        .split('\n').skip(1).where((line) => line.trim().isNotEmpty);
    final expected = {for (final line in csv)
        line.split(',')[0]: line.trim().split(',')[1]};
    final matches = expected.entries.where((e) => data.state.occupancy[e.key] == e.value).length;
    return 'Registros ${records.length} (ids distintos $ids) · '
        '${byState.entries.map((e) => '${e.key.name} ${e.value}').join(', ')} · '
        '${byType.entries.map((e) => '${e.key.name} ${e.value}').join(', ')} · '
        'conflictos ${data.state.conflicts.length} · pendientes de carga ${data.progress.total} · '
        '$matches/${expected.length} posiciones CSV · solicitudes '
        '${data.state.requests.map((r) => r.status.name).join(', ')}'
        '${records.where((r) => r.rejection != null).map((r) => ' · rechazado ${r.movement.type.name} (${r.movement.author.role.name}): ${r.rejection}').join()}';
  }

  /// Prueba negativa autorizada por Carlos: SDK cliente con la sesión real
  /// del muelle, el sobre normal y receivedAt del servidor. No entra en Hive.
  Future<String> _forceDockApproval() async {
    final (operation, log) = await _active();
    final actor = ref.read(operatorProvider).value;
    if (operation.vesselName != _vessel || actor?.authorized != true ||
        actor?.role != OperatorRole.dock) {
      throw StateError('Solo muelle autorizado sobre PRUEBA T-80.');
    }
    final records = (await log.records(operation.id)).getOrElse(() => const []);
    final request = records.lastWhere(
        (r) => r.movement.type == MovementType.requestChange).movement;
    final draft = MovementDraft.approveChange(
        operation.id, request, 'Prueba negativa del permiso de muelle');
    final id = const Uuid().v4();
    final movement = Movement(
        id: id, operationId: operation.id, type: draft.type,
        payload: draft.payload, author: actor!.author,
        deviceId: const Uuid().v4(), sequence: 1, createdAt: DateTime.now());
    final document = FirebaseFirestore.instance.collection('operations')
        .doc(operation.id).collection('movements').doc(id);
    try {
      await document.set(FirestoreMovementCodec.encode(movement));
    } on FirebaseException catch (error) {
      if (error.code != 'permission-denied') rethrow;
      final absent = !(await document.get(
          const GetOptions(source: Source.server))).exists;
      if (!absent) throw StateError('La aprobación forzada existe en la nube.');
      return 'PERMISSION_DENIED · aprobación forzada del muelle denegada '
          '· documento ausente en servidor · sin registro local';
    }
    throw StateError('La nube permitió la aprobación del muelle. Detener aceptación.');
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
              if (operator?.role == OperatorRole.office) button('Preparar oficina', _prepareOffice),
              if (operator?.role == OperatorRole.dock) button('Reproducir cargas', _loadCase),
              if (operator?.role == OperatorRole.dock) button('Forzar aprobación (negativa)', _forceDockApproval),
              button('Comprobar', _check),
              button('Verificar sesión', _verify),
              button('Salir', _signOut),
            ]),
            Text(
                '${operator == null ? 'Sin sesión' : '${operator.name} · ${operator.role.name}'}'
                ' · ${status == null ? '…' : syncStatusText(status)}\n$_message',
                key: const ValueKey('t80-message'),
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
