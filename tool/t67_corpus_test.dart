import 'dart:io';

import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/entities.dart';
import 'package:baystream/features/vessel/domain/entities/stowage_validation_result.dart';
import 'package:baystream/features/vessel/domain/services/stack_weight_validator.dart';
import 'package:flutter_test/flutter_test.dart';

/// T-67 · Aceptación contra el corpus real anonimizado: el mismo plan de carga
/// con el peso como `WT` (A08) y como `VGM` (A08v_VGM) debe dar las mismas
/// alertas de peso por pila con el mismo límite.
/// Uso: flutter test tool/t67_corpus_test.dart
///        --dart-define=BAYSTREAM_CORPUS_DIRECTORY=CARPETA_DEL_CORPUS
void main() {
  const corpus = String.fromEnvironment('BAYSTREAM_CORPUS_DIRECTORY');

  /// Límite **de prueba**, no del buque: el corpus no trae el manual de
  /// estabilidad. 90 t por pila es el valor de las pruebas de C-7 y el del
  /// supuesto que C-7 retiró (`kStackWeightLimitKg`); se usa solo porque deja
  /// pocas alertas legibles en A08. La última prueba registra otros límites.
  const testLimitKg = 90000.0;

  (VesselVoyage, VesselProfile) open(String name, double? limit) {
    expect(corpus, isNotEmpty, reason: 'Indica el directorio del corpus real');
    final parsed = BaplieParserService()
        .parse(File('$corpus/CORPUS_$name.edi').readAsStringSync());
    final proposed = VesselProfile.proposeFrom(parsed);
    final profile = proposed.copyWith(
        stackWeightLimitKg: limit,
        geometry: limit == null
            ? proposed.geometry.withoutStackWeightLimit()
            : proposed.geometry.copyWith(stackWeightLimitKg: limit));
    return (parsed.withGeometry(profile.geometry), profile);
  }

  List<StowageValidationResult> alerts(String name, double? limit) {
    final (voyage, profile) = open(name, limit);
    return const StackWeightValidator().validate(voyage, profile);
  }

  /// Lo que daba el validador antes de T-66/T-67: solo `grossWeight`, y un
  /// contenedor sin él contaba 0.
  int before(String name, double limit) {
    final (voyage, profile) = open(name, limit);
    var count = 0;
    for (final bay in voyage.bays.values) {
      final sums = <String, double>{};
      for (final c in bay.containers) {
        final p = c.stowagePosition!;
        final key = '${p.row}-${profile.geometry.isDeckTier(p.tier)}';
        sums[key] = (sums[key] ?? 0) + (c.grossWeight ?? 0);
      }
      count += sums.values.where((w) => w > limit).length;
    }
    return count;
  }

  test('T-67 A08 y A08v_VGM dan las mismas alertas con el límite de prueba',
      () {
    final wt = alerts('A08', testLimitKg);
    final vgm = alerts('A08v_VGM', testLimitKg);
    expect(wt, isNotEmpty, reason: 'el límite de prueba debe producir alertas');
    expect(vgm, wt, reason: 'mismo plan, mismo peso, mismas alertas');
    expect(wt.every((r) => r.status == ValidationStatus.nonConforming), isTrue,
        reason: 'los 405 contenedores traen peso: nada queda sin evaluar');
    expect(before('A08v_VGM', testLimitKg), 0, reason: 'hoy da cero');
    expect(before('A08', testLimitKg), wt.length);
    final bays = wt.map((r) => r.positions.first.bay).toSet().toList()..sort();
    stdout.writeln('T-67 límite ${testLimitKg.toStringAsFixed(0)} kg · '
        'A08 ${wt.length} alertas · A08v_VGM ${vgm.length} alertas · '
        'antes A08v_VGM ${before('A08v_VGM', testLimitKg)} · bahías $bays');
    for (final r in wt) {
      stdout.writeln('  ${r.description.split('. ').first}');
    }
  });

  test('T-67 sin límite declarado no hay alertas en ningún archivo (C-7)', () {
    for (final name in ['A01', 'A05', 'A07', 'A08', 'A08v_VGM']) {
      expect(alerts(name, null), isEmpty, reason: name);
    }
  });

  test('T-67 con el límite de prueba, el resto del corpus queda registrado',
      () {
    for (final name in ['A01', 'A05', 'A07']) {
      final result = alerts(name, testLimitKg);
      final notEvaluated =
          result.where((r) => r.status == ValidationStatus.notEvaluated);
      expect(notEvaluated, isEmpty,
          reason: '$name: todos sus contenedores traen peso');
      stdout.writeln('T-67 $name: ${result.length} alertas con '
          '${testLimitKg.toStringAsFixed(0)} kg · antes ${before(name, testLimitKg)}');
    }
  });

  test('T-67 A08 y A08v_VGM coinciden también con otros límites', () {
    for (final limit in [50000.0, 60000.0, 70000.0, 80000.0, 90000.0]) {
      final wt = alerts('A08', limit);
      expect(alerts('A08v_VGM', limit), wt, reason: '$limit kg');
      stdout.writeln('T-67 límite ${limit.toStringAsFixed(0)} kg: '
          'A08 ${wt.length} · A08v_VGM ${wt.length} · '
          'antes A08v_VGM ${before('A08v_VGM', limit)}');
    }
  });
}
