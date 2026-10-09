import 'dart:convert';
import 'dart:io';

import 'package:baystream/features/vessel/data/datasources/hive_movement_data_source.dart';
import 'package:baystream/features/vessel/data/repositories/movement_log_repository_impl.dart';
import 'package:baystream/features/vessel/data/repositories/sync_engine.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/data/services/export_list_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/repositories/session_repository.dart';
import 'package:baystream/features/vessel/domain/services/export_list_cross_checker.dart';
import 'package:baystream/features/vessel/domain/services/loading_operation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test/support/t79_fake_cloud.dart';

/// T-79 · El caso real entre dos dispositivos, sin red real: la prueba C2 de
/// T-79a 7.3 hecha en memoria, por el mismo camino que la app (`append` →
/// cola en Hive → motor), contra un servidor falso con las reglas.
///
/// - El muelle registra la solicitud del intercambio, los 120 llenos y los
///   56 vacíos; la oficina aprueba la solicitud cuando le llega, y el muelle
///   espera a ver la aprobación antes de las órdenes 128 y 145.
/// - A mitad de la corrida el muelle se queda sin red unos 40 eventos y se
///   fuerza el cierre de la app con pendientes: se pierde la cola del SDK y
///   la cola de Hive los reenvía.
///
/// Datos y almacenes fuera del repositorio:
///
///     flutter test tool/t79_corpus_test.dart
///         --dart-define=BAYSTREAM_CORPUS_DIRECTORY=CARPETA_EXTERNA
void main() {
  const corpus = String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');
  const dock = Operator(uid: 'uid-muelle', name: 'Muelle', role: OperatorRole.dock);
  const office = Operator(uid: 'uid-oficina', name: 'Oficina', role: OperatorRole.office);
  const operationId = '8d3b0f52-1e6a-4b8f-a2c4-5e9d7f1a0b36';

  for (final name in ['A08', 'A08v_VGM']) {
    test('T-79 $name: 177 eventos entre muelle y oficina, sin red y con cierre forzado',
        () async {
      expect(corpus, isNotEmpty);
      final parsed = BaplieParserService()
          .parse(File('$corpus/CORPUS_$name.edi').readAsStringSync());
      final loading = parsed.withGeometry(
          VesselProfile.proposeFrom(parsed).geometry, portOfCall: 'GTSTC');
      final rawList = const ExportListParserService().parseXlsx(
          File('$corpus/LISTADO_A08.xlsx').readAsBytesSync(),
          fileName: 'LISTADO_A08.xlsx');
      final proposals = ExportListCrossChecker.propose(rawList, loading,
              portOfCall: 'GTSTC')
          .map((p) => p.kind == EquivalenceKind.type && p.listCode == '40RF'
              ? p.choose('45R1')
              : p)
          .toList();
      final list = rawList.normalized(ExportListCrossChecker.tableOf(proposals));
      final plan = LoadingOperation.build(
          operationId: operationId, loading: loading, list: list);
      final events = ((jsonDecode(
                  File('$corpus/CASO_A08_EVENTOS.json').readAsStringSync())
              as Map)['eventos'] as List)
          .cast<Map<String, dynamic>>();
      expect(events, hasLength(177));

      final operation = Operation(
          id: operationId,
          vesselName: loading.vessel.name,
          voyageNumber: loading.voyageNumber,
          portOfCall: 'GTSTC',
          createdAt: DateTime.utc(2026, 10, 9, 7),
          published: true);
      final server = FakeServer()
        ..authorization[dock.uid] = RemoteAuthorization.active
        ..authorization[office.uid] = RemoteAuthorization.active;
      final dockCloud = FakeCloud(server: server);
      final officeCloud = FakeCloud(server: server);
      final dockDir = await Directory.systemTemp.createTemp('baystream_t79_muelle_');
      final officeDir = await Directory.systemTemp.createTemp('baystream_t79_oficina_');
      var tick = 0;
      DateTime clock() => DateTime.utc(2026, 10, 9, 8).add(Duration(seconds: tick++));
      // Hive reconoce las cajas por su nombre en todo el proceso: cada
      // dispositivo necesita su propio namespace, no solo su carpeta.
      Future<MovementLogRepositoryImpl> open(Directory dir) async =>
          MovementLogRepositoryImpl(
              await HiveMovementDataSource.open(
                  directory: dir.path,
                  namespace: dir == dockDir ? 't79muelle$name' : 't79oficina$name'),
              clock: clock);
      SyncEngine engine(MovementLogRepositoryImpl log, FakeCloud cloud) => SyncEngine(
          log: log,
          remote: cloud,
          operation: operation,
          clock: clock,
          tick: const Duration(hours: 1));
      Future<List<MovementRecord>> recordsOf(MovementLogRepositoryImpl log) async =>
          (await log.records(operationId)).getOrElse(() => const []);
      Future<void> until(Future<bool> Function() condition, String what) async {
        for (var i = 0; i < 1000; i++) {
          if (await condition()) return;
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }
        fail('No se cumplió a tiempo: $what');
      }

      var dockLog = await open(dockDir);
      final officeLog = await open(officeDir);
      await dockLog.saveOperation(operation);
      await officeLog.saveOperation(operation);
      var dockSync = engine(dockLog, dockCloud);
      final officeSync = engine(officeLog, officeCloud);
      await dockSync.start(dock);
      await officeSync.start(office);

      // La oficina aprueba cada solicitud cuando le llega.
      final approvals = officeLog.watch(operationId).listen((records) async {
        final requests = records.where((r) => r.movement.type == MovementType.requestChange);
        for (final request in requests) {
          final approved = records.any((r) =>
              r.movement.type == MovementType.changePosition &&
              r.movement.payload['request'] == request.movement.id);
          if (approved) continue;
          await officeLog.append(
              MovementDraft.raw(operationId, MovementType.changePosition, null, {
                'changes': request.movement.payload['changes'],
                'request': request.movement.id,
                'reason': 'Intercambio aprobado: mismo tipo, puerto, línea y peso',
              }),
              office.author);
        }
      });

      MovementDraft draftOf(Map<String, dynamic> event) {
        if (event['tipo'] == 'cambio_de_posicion') {
          final before = (event['plan'] as Map).cast<String, String>();
          final after = (event['nuevo'] as Map).cast<String, String>();
          return MovementDraft.raw(operationId, MovementType.requestChange, null, {
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
        }
        final position = (event['posicion'] ?? event['celda']) as String;
        return event['tipo'] == 'asignar_vacio' &&
                plan.plan.loading.containsKey('R:$position')
            ? MovementDraft.assignEmpty(operationId, position, event['contenedor'],
                (event['tara_kg'] as num).toDouble(),
                order: event['orden'])
            : MovementDraft.loadFull(operationId, event['contenedor'], position,
                order: event['orden']);
      }

      const offlineAt = 60, forcedCloseAt = 80, onlineAt = 100;
      var pendingAfterReopen = 0;
      for (var i = 0; i < events.length; i++) {
        final event = events[i];
        if (i == offlineAt) dockCloud.goOffline();
        if (i == forcedCloseAt) {
          // Cierre forzado con pendientes: se pierde la cola del SDK.
          await dockSync.stop();
          dockCloud.dropQueue();
          await Future<void>.delayed(const Duration(milliseconds: 100));
          await dockLog.close();
          dockLog = await open(dockDir);
          pendingAfterReopen = (await recordsOf(dockLog))
              .where((r) => r.state == SendState.pending)
              .length;
          dockSync = engine(dockLog, dockCloud);
          await dockSync.start(dock);
        }
        if (i == onlineAt) dockCloud.goOnline();
        if (event['orden'] == 128 || event['orden'] == 145) {
          await until(
              () async => (await recordsOf(dockLog))
                  .any((r) => r.movement.type == MovementType.changePosition),
              'la aprobación llega al muelle');
        }
        (await dockLog.append(draftOf(event), dock.author))
            .fold((failure) => fail(failure.message), (_) {});
      }
      expect(pendingAfterReopen, forcedCloseAt - offlineAt,
          reason: 'lo registrado sin red sobrevivió al cierre forzado, pendiente');

      await until(() async {
        final d = await recordsOf(dockLog);
        final o = await recordsOf(officeLog);
        return d.length == 178 &&
            o.length == 178 &&
            [...d, ...o].every((r) => r.state == SendState.confirmed);
      }, 'los dos dispositivos con los 178 confirmados');

      // 178 documentos (120 + 56 + la solicitud + la aprobación), cada id una vez.
      expect(server.docs, hasLength(178));
      final dockRecords = await recordsOf(dockLog);
      final officeRecords = await recordsOf(officeLog);
      expect(dockRecords.map((r) => r.movement.id).toSet(), server.docs.keys.toSet());
      expect(officeRecords.map((r) => r.movement.id).toSet(), server.docs.keys.toSet());
      expect(server.writes.length, greaterThanOrEqualTo(178));

      LoadingOperation derive(List<MovementRecord> records) => LoadingOperation.build(
          operationId: operationId,
          loading: loading,
          list: list,
          movements: records.map((r) => r.movement));
      final onDock = derive(dockRecords);
      final onOffice = derive(officeRecords);
      final expected = {
        for (final row in File('$corpus/CASO_A08_ESTADO_FINAL.csv')
            .readAsLinesSync()
            .skip(1)
            .where((line) => line.trim().isNotEmpty)
            .map((line) => line.split(',')))
          row[0]: row[1]
      };
      expect(expected, hasLength(460));
      expect(onDock.state.occupancy, expected, reason: 'las 460 posiciones en el muelle');
      expect(onOffice.state.occupancy, expected, reason: 'las 460 posiciones en la oficina');
      expect(onDock.progress.total, 0);
      // Mientras T-80 no derive el cambio aprobado, el intercambio sigue a la
      // vista como dos «fuera de plan», igual en los dos dispositivos.
      expect(onDock.state.conflicts.map((c) => c.kind).toSet(), {ConflictKind.outOfPlan});
      expect(onDock.state.conflicts, hasLength(2));
      expect(onOffice.state.conflicts.map((c) => c.message).toList(),
          onDock.state.conflicts.map((c) => c.message).toList());
      expect(onDock.state.notDerived, onOffice.state.notDerived);

      printOnFailure('reenvíos idénticos: ${server.identicalResends}');
      stdout.writeln('T-79 $name: 177 eventos → ${server.docs.length} documentos, cada id una vez; '
          '${server.writes.length} escrituras (${server.identicalResends} reenvíos idénticos); '
          '$pendingAfterReopen pendientes al reabrir tras el cierre forzado; '
          '460/460 posiciones en muelle y oficina; ${onDock.state.conflicts.length} '
          'conflictos fuera de plan hasta T-80.');

      await approvals.cancel();
      await dockSync.stop();
      await officeSync.stop();
      await Future<void>.delayed(const Duration(milliseconds: 200));
      await dockLog.close();
      await officeLog.close();
      await dockDir.delete(recursive: true);
      await officeDir.delete(recursive: true);
    }, timeout: const Timeout(Duration(minutes: 3)));
  }
}
