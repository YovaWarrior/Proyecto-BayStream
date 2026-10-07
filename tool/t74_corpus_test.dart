import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:baystream/features/vessel/data/datasources/hive_movement_data_source.dart';
import 'package:baystream/features/vessel/data/datasources/hive_vessel_data_source.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_impl.dart';
import 'package:baystream/features/vessel/data/repositories/movement_log_repository_impl.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/loading_plan_progress.dart';
import 'package:baystream/features/vessel/domain/services/operation_state_deriver.dart';
import 'package:baystream/features/vessel/presentation/providers/export_list_providers.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_plan_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test/support/local_profile_test_support.dart';

/// Lee únicamente el corpus externo. No genera fixtures ni imprime su texto.
/// flutter test tool/t74_corpus_test.dart
/// --dart-define=BAYSTREAM_CORPUS_DIRECTORY=CARPETA_DEL_CORPUS
void main() {
  const corpus = String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');
  const expected = {
    '03': (5, 0, 1, 4),
    '05/06': (26, 26, 30, 22),
    '07': (0, 11, 6, 5),
    '13/14': (14, 18, 32, 0),
    '15': (0, 4, 4, 0),
    '22': (6, 16, 22, 0),
    '25/26': (13, 17, 7, 23),
    '27': (0, 2, 0, 2),
    '29/30': (18, 0, 18, 0),
  };
  for (final name in ['A08', 'A08v_VGM']) {
    test('T-74 $name: una operación, fuentes completas, OR y 176→0 pendientes',
        () async {
      expect(corpus, isNotEmpty);
      final directory = await Directory.systemTemp.createTemp('baystream_t74_caso_');
      final namespace = 't74_${DateTime.now().microsecondsSinceEpoch}';
      Future<LocalVesselRepositoryImpl> openLocal() async =>
          LocalVesselRepositoryImpl(await HiveVesselDataSource.open(
              directory: directory.path, namespace: namespace));
      Future<MovementLogRepositoryImpl> openLog() async =>
          MovementLogRepositoryImpl(await HiveMovementDataSource.open(
              directory: directory.path, namespace: namespace));
      var local = await openLocal();
      var log = await openLog();
      ProviderContainer container() => ProviderContainer(overrides: [
            localVesselRepositoryProvider.overrideWith((ref) async => local),
            movementLogRepositoryProvider.overrideWith((ref) async => log),
            vesselRepositoryProvider.overrideWithValue(ParserOnlyRepository()),
          ]);
      var scope = container();
      final incoming = File('$corpus/CORPUS_A07.edi').readAsStringSync();
      final loading = File('$corpus/CORPUS_$name.edi').readAsStringSync();
      try {
        Future<void> read(String text, String filename) async {
          final notifier = scope.read(voyageNotifierProvider.notifier);
          final result =
              await notifier.parseBaplieContent(text, fileName: filename);
          expect(result.success, isTrue, reason: result.errorMessage);
          if (result.needsGeometry) {
            final target = notifier.pendingVoyage!;
            final proposed = VesselProfile.proposeFrom(target).geometry;
            expect(
                await notifier.confirmGeometry(proposed, portOfCall: 'GTSTC'),
                isNull);
          }
        }

        // T-73 puede haber creado antes la operación solo con el listado.
        await read(loading, 'CORPUS_$name.edi');
        final subscription = scope.listen(exportListImportProvider, (_, __) {});
        final importer = scope.read(exportListImportProvider.notifier);
        await importer.loadBytes(
            File('$corpus/LISTADO_A08.xlsx').readAsBytesSync(),
            fileName: 'LISTADO_A08.xlsx');
        importer.choose(EquivalenceKind.type, '40RF', '45R1');
        expect(await importer.confirm(), isNull);
        subscription.close();
        final original = (await log.getOperations()).getOrElse(() => []).single;
        await read(incoming, 'CORPUS_A07.edi');
        final withArrival =
            (await log.getOperations()).getOrElse(() => []).single;
        expect(withArrival.id, original.id);
        expect(withArrival.createdAt, original.createdAt);
        expect(withArrival.sources, hasLength(3));
        expect(withArrival.source(OperationSourceKind.arrivalBaplie)!.content,
            incoming);
        expect(withArrival.source(OperationSourceKind.loadingBaplie)!.content,
            loading);
        await read(loading, 'CORPUS_${name}_releido.edi');
        final replaced = (await log.getOperations()).getOrElse(() => []).single;
        expect(replaced.id, original.id);
        expect(replaced.createdAt, original.createdAt);
        expect(replaced.sources, hasLength(3));
        expect(replaced.source(OperationSourceKind.exportList),
            original.source(OperationSourceKind.exportList));
        expect(replaced.source(OperationSourceKind.loadingBaplie)!.fileName,
            'CORPUS_${name}_releido.edi');
        scope.dispose();
        await local.close();
        await log.close();
        local = await openLocal();
        log = await openLog();
        scope = container();
        final reopened = (await log.getOperations()).getOrElse(() => []).single;
        expect(reopened, replaced);
        final voyages = (await local.getAllVoyages()).getOrElse(() => []);
        final id = voyages.firstWhere((v) => v.containers.length == 405).id;
        expect(
            await scope
                .read(voyageNotifierProvider.notifier)
                .openRecentVoyage(id),
            isNull);
        final voyage = scope.read(voyageNotifierProvider).value!;
        Completer<LoadingPlanProgress>? nextUpdate;
        final progressSubscription = scope.listen(loadingPlanProgressProvider(voyage), (_, next) {
          if (next.hasValue && nextUpdate != null && !nextUpdate.isCompleted) {
            nextUpdate.complete(next.value!);
          }
        });
        final data =
            await scope.read(loadingPlanProgressProvider(voyage).future);
        expect({
          for (final b in data.bays.values)
            b.label: (b.deck, b.hold, b.full, b.empty)
        }, expected);
        expect(
            (data.deck, data.hold, data.full, data.empty), (82, 94, 120, 56));
        expect(data.unmatched, 0);
        expect(data.labels.length, 176);
        expect(data.labels.values.where((s) => s.startsWith('OR ')),
            hasLength(121));
        expect(data.labels.values.where((s) => !s.startsWith('OR ')),
            hasLength(55));
        final emptyNumbered = data.list!.byOrder(85)!;
        expect(data.label('C:${emptyNumbered.containerId}'), 'OR 85');

        final events = ((jsonDecode(
                    File('$corpus/CASO_A08_EVENTOS.json').readAsStringSync())
                as Map)['eventos'] as List)
            .cast<Map<String, dynamic>>();
        var previous = 176;
        var skipped = 0;
        final movements = <Movement>[];
        for (final event in events) {
          if (event['tipo'] == 'cambio_de_posicion') {
            skipped++;
            continue;
          }
          final container = event['contenedor'] as String;
          final cell = (event['posicion'] ?? event['celda']) as String;
          final draft = event['tipo'] == 'asignar_vacio' &&
                  data.plan.loading.containsKey('R:$cell')
              ? MovementDraft.assignEmpty(reopened.id, cell, container,
                  (event['tara_kg'] as num).toDouble(),
                  order: event['orden'] as int)
              : MovementDraft.loadFull(reopened.id, container, cell,
                  order: event['orden'] as int);
          nextUpdate = Completer<LoadingPlanProgress>();
          final record = (await log.append(
                  draft,
                  const MovementAuthor(
                      name: 'Aceptación T74', role: OperatorRole.dock)))
              .fold((failure) => throw StateError(failure.message),
                  (record) => record);
          movements.add(record.movement);
          final current = LoadingPlanProgress.build(voyage,
              const OperationStateDeriver().derive(data.plan, movements),
              list: data.list);
          expect(current.total, previous - 1, reason: 'Evento ${event['n']}');
          final live = await nextUpdate.future.timeout(const Duration(seconds: 5));
          expect(live.total, current.total);
          previous = current.total;
        }
        expect(previous, 0);
        expect(skipped, 1);
        progressSubscription.close();
        scope.dispose();
        await log.close();
        log = await openLog();
        scope = container();
        final records = (await log.records(reopened.id)).getOrElse(() => []);
        expect(records, hasLength(176));
        final state = const OperationStateDeriver()
            .derive(data.plan, records.map((r) => r.movement));
        final finalData =
            LoadingPlanProgress.build(voyage, state, list: data.list);
        expect(finalData.total, 0);
        expect(finalData.bays, hasLength(9));
        expect(state.conflicts.map((c) => c.kind),
            [ConflictKind.outOfPlan, ConflictKind.outOfPlan]);
        final csv = {
          for (final row in File('$corpus/CASO_A08_ESTADO_FINAL.csv')
              .readAsLinesSync()
              .skip(1)
              .where((r) => r.trim().isNotEmpty)
              .map((r) => r.split(',')))
            row[0]: row[1]
        };
        expect(state.occupancy, csv);
        stdout.writeln(
            'T-74 $name: operación única con 3 fuentes; 121 OR, 55 reservas con grupo, 0 sin cruce; 9 bahías 82/94 y 120/56; 176 descensos y 0 pendientes al reabrir; 2 conflictos previstos.');
      } finally {
        scope.dispose();
        await local.close();
        await log.close();
        await directory.delete(recursive: true);
      }
    });
  }
}


