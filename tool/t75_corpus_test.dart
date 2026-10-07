import 'dart:async';
import 'dart:io';

import 'package:baystream/features/vessel/data/datasources/hive_movement_data_source.dart';
import 'package:baystream/features/vessel/data/datasources/hive_vessel_data_source.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_impl.dart';
import 'package:baystream/features/vessel/data/repositories/movement_log_repository_impl.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/discharge_progress.dart';
import 'package:baystream/features/vessel/presentation/providers/discharge_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/loading_plan_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/movement_log_provider.dart';
import 'package:baystream/features/vessel/presentation/providers/vessel_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test/support/local_profile_test_support.dart';

/// T-75 · Aceptación de la descarga contra el plano de llegada anonimizado.
/// Lee únicamente el corpus externo, no imprime su texto, y el almacén
/// temporal vive en el directorio temporal del sistema, fuera del repo.
/// flutter test tool/t75_corpus_test.dart
/// --dart-define=BAYSTREAM_CORPUS_DIRECTORY=CARPETA_DEL_CORPUS
void main() {
  const corpus = String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');
  // Ficha de T-75: por bahía del BAPLIE, (cubierta, bodega).
  const expected = {
    '03': (3, 0),
    '14': (19, 16),
    '21': (0, 12),
    '22': (20, 8),
    '23': (0, 12),
    '30': (24, 0),
  };
  for (final name in ['A08', 'A08v_VGM']) {
    test(
        'T-75 A07 en GTSTC con $name: 114 pendientes, marcar, re-estibar, '
        'deshacer y reabrir', () async {
      expect(corpus, isNotEmpty);
      final directory =
          await Directory.systemTemp.createTemp('baystream_t75_caso_');
      final namespace = 't75_${DateTime.now().microsecondsSinceEpoch}';
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
      const author =
          MovementAuthor(name: 'Aceptación T75', role: OperatorRole.dock);
      try {
        Future<void> read(String file) async {
          final notifier = scope.read(voyageNotifierProvider.notifier);
          final result = await notifier.parseBaplieContent(
              File('$corpus/$file').readAsStringSync(),
              fileName: file);
          expect(result.success, isTrue, reason: result.errorMessage);
          if (result.needsGeometry) {
            final proposed =
                VesselProfile.proposeFrom(notifier.pendingVoyage!).geometry;
            expect(
                await notifier.confirmGeometry(proposed, portOfCall: 'GTSTC'),
                isNull);
          }
        }

        await read('CORPUS_$name.edi');
        await read('CORPUS_A07.edi');
        final operation =
            (await log.getOperations()).getOrElse(() => []).single;
        expect(operation.sources.map((s) => s.kind).toSet(), {
          OperationSourceKind.arrivalBaplie,
          OperationSourceKind.loadingBaplie
        });
        final voyage = scope.read(voyageNotifierProvider).value!;
        expect(voyage.containers, hasLength(398));
        expect(offersDischarge(voyage), isTrue);

        Completer<DischargeProgress>? nextUpdate;
        var subscription =
            scope.listen(dischargeProgressProvider(voyage), (_, next) {
          if (next.hasValue && !(nextUpdate?.isCompleted ?? true)) {
            nextUpdate!.complete(next.value!);
          }
        });
        Future<MovementRecord> append(MovementDraft draft) async {
          nextUpdate = Completer<DischargeProgress>();
          return (await log.append(draft, author))
              .fold((failure) => throw StateError(failure.message), (r) => r);
        }

        // Los proveedores son autoDispose: se leen con un oyente abierto.
        Future<T> settled<T>(void Function() release, Future<T> future) async {
          try {
            return await future;
          } finally {
            release();
          }
        }

        Future<DischargeProgress> live() =>
            nextUpdate!.future.timeout(const Duration(seconds: 5));

        final start =
            await scope.read(dischargeProgressProvider(voyage).future);
        expect(start.operationId, operation.id);
        expect((start.pending, start.deckPending, start.holdPending),
            (114, 66, 48));
        expect({
          for (final b in start.bays.values)
            b.label: (b.deckPending, b.holdPending)
        }, expected);
        expect((start.discharged, start.restows, start.conflicts.length),
            (0, 0, 0));

        // Marcar los 114, uno por uno: cada marca baja un pendiente.
        final toDischarge = start.plan.arrival.values
            .where((i) => i.role == PlanRole.discharge)
            .toList()
          ..sort((a, b) => a.plannedPosition.compareTo(b.plannedPosition));
        final marks = <Movement>[];
        var previous = 114;
        for (final item in toDischarge) {
          final record = await append(MovementDraft.discharge(
              operation.id, item.container!.containerId, item.plannedPosition));
          marks.add(record.movement);
          final now = await live();
          expect(now.pending, previous - 1);
          expect(now.markOf(item.container!.containerId),
              DischargeMark.discharged);
          previous = now.pending;
        }
        expect(previous, 0);

        // La carga de T-74 no cuenta las descargas como conflictos.
        final loading = await settled(
            scope.listen(loadingPlanProgressProvider(voyage), (_, __) {}).close,
            scope.read(loadingPlanProgressProvider(voyage).future));
        expect((loading.total, loading.state.conflicts.length), (176, 0));

        // Reabrir con las marcas puestas: siguen iguales.
        subscription.close();
        scope.dispose();
        await log.close();
        log = await openLog();
        scope = container();
        final reopened = await settled(
            scope.listen(dischargeProgressProvider(voyage), (_, __) {}).close,
            scope.read(dischargeProgressProvider(voyage).future));
        expect((reopened.pending, reopened.discharged), (0, 114));

        // Deshacer los 114 con annul: vuelven los 114 y la bitácora guarda 228.
        subscription =
            scope.listen(dischargeProgressProvider(voyage), (_, next) {
          if (next.hasValue && !(nextUpdate?.isCompleted ?? true)) {
            nextUpdate!.complete(next.value!);
          }
        });
        previous = 0;
        for (final mark in marks) {
          await append(MovementDraft.annul(
              operation.id, mark.id, markedByMistake,
              target: mark.target));
          final now = await live();
          expect(now.pending, previous + 1);
          previous = now.pending;
        }
        expect(previous, 114);
        expect((await log.records(operation.id)).getOrElse(() => []),
            hasLength(228));

        // Un contenedor de paso: re-estiba aparte, no entre los 114.
        final transit = start.plan.arrival.values
            .firstWhere((i) => i.role == PlanRole.transit);
        final restow = await append(MovementDraft.discharge(operation.id,
            transit.container!.containerId, transit.plannedPosition,
            restow: true, reason: 'Re-estiba de prueba'));
        expect(restow.movement.payload['restow'], isTrue);
        final afterRestow = await live();
        expect(
            (afterRestow.pending, afterRestow.discharged, afterRestow.restows),
            (114, 0, 1));
        expect(afterRestow.markOf(transit.container!.containerId),
            DischargeMark.restowed);

        subscription.close();
        scope.dispose();
        await local.close();
        await log.close();
        local = await openLocal();
        log = await openLog();
        scope = container();
        final finalRecords =
            (await log.records(operation.id)).getOrElse(() => []);
        expect(finalRecords, hasLength(229));
        final last = await settled(
            scope.listen(dischargeProgressProvider(voyage), (_, __) {}).close,
            scope.read(dischargeProgressProvider(voyage).future));
        expect(
            (last.pending, last.deckPending, last.holdPending), (114, 66, 48));
        expect(
            (last.discharged, last.restows, last.conflicts.length), (0, 1, 0));
        stdout.writeln('T-75 $name: A07 en GTSTC, 114 pendientes (66 cub. / '
            '48 bod.) por bahía como la ficha; 114 marcas → 0; reabrir conserva; '
            '114 annul → 114 y 228 movimientos; re-estiba aparte (229); la '
            'carga de T-74 sigue en 176 sin conflictos.');
      } finally {
        scope.dispose();
        await local.close();
        await log.close();
        await directory.delete(recursive: true);
      }
    });
  }
}
