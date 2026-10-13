import 'dart:convert';
import 'dart:io';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/data/datasources/hive_vessel_data_source.dart';
import 'package:baystream/features/vessel/data/repositories/local_vessel_repository_impl.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

/// Configuraciones exclusivamente PROVISIONALES: el corpus no declara tapas.
void main() {
  const corpus = String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');
  VesselVoyage read(String file) =>
      BaplieParserService().parse(File('$corpus/$file').readAsStringSync());
  test('T83 nueve fuentes compatibles: perfiles sin tapas inventadas', () {
    for (final code in [
      'A01',
      'A02',
      'A03',
      'A03v_VGM',
      'A04',
      'A05',
      'A07',
      'A08',
      'A08v_VGM'
    ]) {
      final v = read('CORPUS_$code.edi');
      final p = VesselProfile.proposeFrom(v);
      expect(p.hatchCovers, isEmpty);
      expect(
          VesselProfile.fromJson(
              jsonDecode(jsonEncode(p.toJson())) as Map<String, dynamic>),
          p);
    }
  });
  for (final file in ['CORPUS_A08.edi', 'CORPUS_A08v_VGM.edi']) {
    test('T83 $file: caso, perfiles provisionales, cierre y reapertura de Hive',
        () async {
      final arrival = read('CORPUS_A07.edi');
      final loading = read(file);
      final geometry = VesselGeometry.proposeFrom(
          [...arrival.stowagePositions, ...loading.stowagePositions]);
      final holdBays = {
        ...observedHoldBays(arrival, geometry),
        ...observedHoldBays(loading, geometry)
      };
      expect(
          holdBays.containsAll({5, 6, 7, 13, 14, 15, 22, 25, 26, 27}), isTrue,
          reason: 'bahías con movimientos de bodega de la sección 2 del caso');
      final rows = geometry.orderedRows
          .where((r) => r != 0 || geometry.centerRowInHold != false)
          .toList();
      final declarations = <int, HatchCoverDeclaration>{};
      final sorted = holdBays.toList()..sort();
      for (var i = 0; i < sorted.length; i++) {
        final count = (i % 3) + 1;
        declarations[sorted[i]] = switch (i % 5) {
          0 => HatchCoverDeclaration(kind: HatchCoverKind.openHold),
          1 => HatchCoverDeclaration(
              kind: HatchCoverKind.automatic, covers: [rows.toSet()]),
          _ => HatchCoverDeclaration(
              kind: HatchCoverKind.crane,
              covers: List.generate(
                  count,
                  (n) =>
                      {for (var r = n; r < rows.length; r += count) rows[r]})),
        };
      }
      final p = VesselProfile.proposeFrom(loading).copyWith(
          geometry: geometry,
          observedHoldBayNumbers: holdBays,
          hatchCovers: declarations);
      expect(p.hatchCoverError, isNull);
      final temp =
          await Directory.systemTemp.createTemp('baystream_t83_corpus_');
      final source = await HiveVesselDataSource.open(
          directory: temp.path, namespace: 't83corpus');
      final repository = LocalVesselRepositoryImpl(source);
      expect((await repository.saveProfile(p)).isRight(), isTrue);
      await repository.close();
      final reopened = LocalVesselRepositoryImpl(
          await HiveVesselDataSource.open(
              directory: temp.path, namespace: 't83corpus'));
      expect((await reopened.getAllProfiles()).getOrElse(() => []).single, p);
      expect(
          (await reopened.saveProfile(p.copyWith(hatchCovers: {
            3: HatchCoverDeclaration(kind: HatchCoverKind.crane, covers: [
              {99}
            ])
          })))
              .isLeft(),
          isTrue);
      expect((await reopened.getAllProfiles()).getOrElse(() => []).single, p);
      await reopened.close();
      await temp.delete(recursive: true);
      stdout.writeln(
          'PROVISIONAL $file: bodega ${sorted.join(',')}; filas ${rows.join(',')}; perfil idéntico tras reabrir.');
    });
  }
}
