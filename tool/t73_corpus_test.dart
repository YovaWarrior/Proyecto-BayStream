import 'dart:convert';
import 'dart:io';

import 'package:baystream/features/vessel/data/datasources/hive_movement_data_source.dart';
import 'package:baystream/features/vessel/data/datasources/hive_vessel_data_source.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_impl.dart';
import 'package:baystream/features/vessel/data/repositories/movement_log_repository_impl.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/data/services/export_list_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/services/export_list_cross_checker.dart';
import 'package:flutter_test/flutter_test.dart';

/// T-73 · Aceptación de la ficha contra el caso real anonimizado:
/// LISTADO_A08.xlsx con CORPUS_A08 y CORPUS_A08v_VGM, sin copiar nada al
/// repositorio.
/// Uso: flutter test tool/t73_corpus_test.dart
///        --dart-define=BAYSTREAM_CORPUS_DIRECTORY=CARPETA_DEL_CORPUS
void main() {
  const corpus = String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');

  for (final name in ['A08', 'A08v_VGM']) {
    test('T-73 LISTADO_A08 contra CORPUS_$name: las cifras de la ficha', () async {
      expect(corpus, isNotEmpty, reason: 'Indica el directorio del corpus real');
      final plan = BaplieParserService()
          .parse(File('$corpus/CORPUS_$name.edi').readAsStringSync())
          .copyWith(portOfCall: 'GTSTC');
      final list = const ExportListParserService().parseXlsx(
          File('$corpus/LISTADO_A08.xlsx').readAsBytesSync(),
          fileName: 'LISTADO_A08.xlsx');

      // 176 filas en 4 agencias, cero sin entender.
      expect(list.rows.length, 176);
      expect(list.agencies.length, 4);
      expect(list.issues, isEmpty);
      expect(list.rows.map((r) => r.order), [for (var i = 1; i <= 176; i++) i]);
      expect(list.fulls.length, 120);
      expect(list.empties.length, 56);

      // Las cinco equivalencias se proponen solas; 40RF → 45R1 se pide.
      var proposals = ExportListCrossChecker.propose(list, plan, portOfCall: 'GTSTC');
      final proposed = {
        for (final p in proposals)
          if (p.origin == EquivalenceOrigin.inferred && !p.isIdentity)
            '${p.kind.wire} ${p.listCode}→${p.planCode}',
      };
      expect(proposed, {
        'type 40HC→45G1',
        'type 20ST→22G1',
        'type 40ST→42G1',
        'port COMNG→COSPC',
        'line LNB→LINB',
      });
      final pending = proposals.where((p) => p.needsUser).toList();
      expect(pending.map((p) => '${p.kind.wire} ${p.listCode}'), ['type 40RF']);
      expect(pending.single.candidates, contains('45R1'));
      expect(proposals.where((p) => p.contradicted), isEmpty);

      proposals = [for (final p in proposals) p.needsUser ? p.choose('45R1') : p];
      final table = ExportListCrossChecker.tableOf(proposals);
      final normalized = list.normalized(table);
      final check = ExportListCrossChecker.crossCheck(normalized, plan, 'GTSTC');

      // 120 llenos que cruzan uno a uno; 56 vacíos en los 6 grupos.
      expect(check.matches.length, 120);
      expect(check.matches.map((m) => m.container.containerId).toSet().length, 120);
      expect(check.matchesWithDifferences.map((m) => m.differences), isEmpty);
      expect(check.fullsNotInPlan, isEmpty);
      expect(check.planNotInList, isEmpty);
      expect(check.emptiesWithoutGroup, isEmpty);
      expect(check.groups.map((g) => g.planCells), [20, 17, 9, 7, 2, 1]);
      expect(check.groups.map((g) => g.empties.length), [20, 17, 9, 7, 2, 1]);
      expect(check.emptiesInGroups, 56);
      expect(check.clean, isTrue);
      expect(check.groups.last.numberedEmpties.single.stowagePosition!.toIsoCode(), '0060204');
      expect(check.groups.last.empties.single.order, 85);

      // OR 127: clase 9 y UN 3082 y 3077, con el aviso de que el plan no trae 3082.
      final or127 = normalized.byOrder(127)!;
      expect(or127.imdgClass, '9');
      expect(or127.unNumbers, ['3082', '3077']);
      expect(check.dangerousGoods.map((n) => n.row.order), [127]);
      expect(check.dangerousGoods.single.message, contains('el plan no trae UN 3082'));

      // VGM exacto: el OR 130 da 7 266.59 kg, no los 7 200 del plan.
      final or130 = normalized.byOrder(130)!;
      expect(or130.vgmKg, 7266.59);
      expect(plan.containers.singleWhere((c) => c.containerId == or130.containerId).effectiveWeight,
          7200);
      // Caso, sección 6: 47 llenos difieren y el plan suma 2.4 t menos.
      expect(check.weightDifferences, 47);
      expect((check.weightDifferenceKg / 1000).toStringAsFixed(1), '-2.4');

      // Guardado: equivalencias en el almacén local y el listado como fuente
      // export_list de la operación. Al reabrir, una segunda importación no pide nada.
      // T-75: el almacén temporal lleva contenido del corpus; vive en el
      // directorio temporal del sistema, nunca en el build/ del repositorio.
      final directory = await Directory.systemTemp.createTemp('baystream_t73_caso_');
      final namespace = 't73_corpus_${DateTime.now().microsecondsSinceEpoch}';
      var local = LocalVesselRepositoryImpl(
          await HiveVesselDataSource.open(directory: directory.path, namespace: namespace));
      var log = MovementLogRepositoryImpl(
          await HiveMovementDataSource.open(directory: directory.path, namespace: namespace));
      try {
        expect((await local.saveCodeEquivalences(table)).isRight(), isTrue);
        expect(
            (await log.saveOperation(Operation(
              id: 'caso-a08',
              vesselName: plan.vessel.name,
              voyageNumber: plan.voyageNumber,
              portOfCall: 'GTSTC',
              createdAt: DateTime.utc(2025, 10, 4),
              sources: [
                OperationSource(
                  kind: OperationSourceKind.exportList,
                  fileName: list.fileName,
                  content: jsonEncode(normalized.toJson()),
                ),
              ],
            )))
                .isRight(),
            isTrue);
        await local.close();
        await log.close();

        local = LocalVesselRepositoryImpl(
            await HiveVesselDataSource.open(directory: directory.path, namespace: namespace));
        log = MovementLogRepositoryImpl(
            await HiveMovementDataSource.open(directory: directory.path, namespace: namespace));
        final saved = (await local.getCodeEquivalences()).getOrElse(() => throw StateError(''));
        final again = ExportListCrossChecker.propose(list, plan, portOfCall: 'GTSTC', saved: saved);
        expect(again.where((p) => p.needsUser), isEmpty);
        final operation =
            (await log.getOperation('caso-a08')).getOrElse(() => throw StateError(''))!;
        final stored = ExportList.fromJson(jsonDecode(
            operation.source(OperationSourceKind.exportList)!.content) as Map<String, dynamic>);
        expect(stored, normalized);
        expect(stored.byOrder(130)!.vgmKg, 7266.59);
        expect(stored.byOrder(83)!.type, '45R1');
        expect(stored.byOrder(83)!.listType, '40RF');
      } finally {
        await local.close();
        await log.close();
        await directory.delete(recursive: true);
      }
    });
  }
}
