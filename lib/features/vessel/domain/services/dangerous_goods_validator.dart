import '../entities/container_unit.dart';
import '../entities/dangerous_goods.dart';
import '../entities/hatch_covers.dart';
import '../entities/stowage_validation_result.dart';
import '../entities/vessel_geometry.dart';
import 'discharge_sequence.dart' show footprintsTouch;
import 'imdg_42_24_data.dart';
import 'segregation_rules.dart';

/// IMDG 42-24. Apoyo a la decisión, con las limitaciones visibles en cada par.
/// No infiere riesgos, grupos ni excepciones a partir del número ONU.
class DangerousGoodsValidator {
  const DangerousGoodsValidator();

  List<StowageValidationResult> validate(
      Iterable<ContainerUnit> containers, VesselGeometry geometry,
      {Map<int, HatchCoverDeclaration> hatchCovers = const {}}) {
    final entries = <(ContainerUnit, DangerousGoods)>[];
    final results = <StowageValidationResult>[];
    final occupiedCenterRows = <(bool, int)>{};
    for (final c in containers) {
      final p = c.stowagePosition;
      if (p != null && p.row == 0) {
        for (final bay in _occupiedBays(c)) {
          occupiedCenterRows.add((geometry.isDeckTier(p.tier), bay));
        }
      }
      if (!c.isDangerous && (c.dangerousGoods?.isEmpty ?? true)) continue;
      if (c.dangerousGoods == null || c.dangerousGoods!.isEmpty) {
        results.add(_result(
            c,
            null,
            ValidationStatus.notEvaluated,
            'Registro sin lista completa de DGS. Volver a importar el BAPLIE para evaluar todas las sustancias.',
            const ['IMDG 42-24, 7.2.4']));
        continue;
      }
      for (final d in c.dangerousGoods!) {
        entries.add((c, d));
        final problem = _problem(d) ??
            (_isOpen(c) == null
                ? 'Tipo de unidad abierto o cerrado no confirmado por el tercer carácter ISO.'
                : null);
        if (problem != null) {
          results.add(_result(
              c, null, ValidationStatus.notEvaluated, '${_name(d)}: $problem', [
            'IMDG 42-24, 7.2.4',
            if (problem.contains('secundarios')) 'IMDG 42-24, 7.2.3.4',
            if (problem.startsWith('Tipo de unidad')) 'IMDG 42-24, 7.4.3.2'
          ]));
        }
      }
    }
    for (var i = 0; i < entries.length; i++) {
      for (var j = i + 1; j < entries.length; j++) {
        results.add(evaluatePair(entries[i].$1, entries[i].$2, entries[j].$1,
            entries[j].$2, geometry,
            occupiedCenterRows: occupiedCenterRows, hatchCovers: hatchCovers));
      }
    }
    return List.unmodifiable(results);
  }

  StowageValidationResult evaluatePair(ContainerUnit a, DangerousGoods da,
      ContainerUnit b, DangerousGoods db, VesselGeometry geometry,
      {Set<(bool, int)> occupiedCenterRows = const {},
      Map<int, HatchCoverDeclaration> hatchCovers = const {}}) {
    final references = <String>['IMDG 42-24, 7.2.4'];
    final details = <String>[];
    StowageValidationResult result(ValidationStatus status, String reason) =>
        _result(
            a,
            b,
            status,
            '${_name(da)} / ${_name(db)}. ${[...details, reason].join(' ')}',
            references);
    final problems = [_problem(da), _problem(db)].whereType<String>().toSet();
    if (problems.isNotEmpty) {
      if (problems.any((s) => s.contains('secundarios'))) {
        references.add('IMDG 42-24, 7.2.3.4');
      }
      return result(ValidationStatus.notEvaluated, problems.join(' '));
    }
    final classesA = _classes(da), classesB = _classes(db);
    if (classesA.length > 1 || classesB.length > 1) {
      references.add('IMDG 42-24, 7.2.3.3');
      details.add(
          'Se compara también el peligro secundario declarado; prevalece la exigencia más alta.');
    }
    var requirement = 0;
    var list = false;
    var explosives = false;
    for (final x in classesA) {
      for (final y in classesB) {
        final code = SegregationRules.code(x, y)!;
        final value = SegregationRules.requirement(code);
        if (value > requirement) requirement = value;
        list |= code == SegregationCode.substance;
        explosives |= code == SegregationCode.compatibility;
      }
    }
    if (list) {
      references.add('IMDG 42-24, 7.2.3.1');
      details.add(
          'X: consultar la Lista de mercancías peligrosas; su columna 16b no se evalúa.');
    }
    if (explosives) {
      references.add('IMDG 42-24, 7.2.7.1');
      details.add(
          '*: revisar la compatibilidad de explosivos en 7.2.7.1; BayStream no la resuelve.');
    }
    if (requirement == 0) {
      return result(
          ValidationStatus.notEvaluated,
          list
              ? 'No evaluado: consultar la Lista de mercancías peligrosas.'
              : 'No evaluado: ver 7.2.7.1.');
    }
    details.add('Exigencia $requirement de la matriz por clase.');
    if (a.id == b.id) {
      references.add('IMDG 42-24, 7.2.3.2');
      return result(ValidationStatus.nonConforming,
          'Sustancias que requieren segregación dentro de la misma unidad.');
    }
    references.add('IMDG 42-24, 7.4.3.2');
    final openA = _isOpen(a), openB = _isOpen(b);
    if (openA == null || openB == null) {
      return result(ValidationStatus.notEvaluated,
          'Tipo de unidad abierto o cerrado no confirmado por el tercer carácter ISO.');
    }
    final ca = a.stowagePosition, cb = b.stowagePosition;
    if (ca == null ||
        cb == null ||
        !geometry.covers(ca) ||
        !geometry.covers(cb)) {
      return result(ValidationStatus.notEvaluated,
          'Posición ausente o fuera de la geometría declarada.');
    }
    final sizeA = a.sizeInFeet, sizeB = b.sizeInFeet;
    if (sizeA == null ||
        sizeB == null ||
        (sizeA == 20) != ca.bay.isOdd ||
        (sizeB == 20) != cb.bay.isOdd) {
      return result(ValidationStatus.notEvaluated,
          'Longitud o relación tamaño/bahía no confirmada para comparar las huellas.');
    }
    final deckA = geometry.isDeckTier(ca.tier),
        deckB = geometry.isDeckTier(cb.tier);
    final pair = !openA && !openB
        ? ImdgUnitPair.closedClosed
        : openA && openB
            ? ImdgUnitPair.openOpen
            : ImdgUnitPair.closedOpen;
    final sameVertical = ca.row == cb.row && footprintsTouch(ca.bay, cb.bay);
    if (deckA != deckB) {
      final openHold = hatchCovers.entries.any((e) =>
          e.value.kind == HatchCoverKind.openHold &&
          (footprintsTouch(e.key, ca.bay) || footprintsTouch(e.key, cb.bay)));
      if (openHold) {
        return result(ValidationStatus.notEvaluated,
            'Bodega abierta declarada: no hay tapa separadora. El caso sin tapas de 7.4.3.3 queda fuera de esta evaluación.');
      }
      if (requirement >= 3) {
        return result(ValidationStatus.notEvaluated,
            'Una unidad en cubierta y otra en bodega: para la exigencia $requirement faltan los límites de la bodega.');
      }
      references.add('IMDG 42-24, 7.4.2.2');
      return result(
          ValidationStatus.conforming,
          'La cubierta entre las unidades satisface la exigencia $requirement: '
          'se considera la tapa como cubierta resistente al fuego y a los líquidos (IMDG 7.4.2.2).');
    }
    if (sameVertical) {
      if (ca.tier == cb.tier) {
        return result(ValidationStatus.nonConforming,
            'Dos unidades ocupan la misma posición física.');
      }
      final rule = Imdg4224Data.vertical[requirement - 1][pair.index];
      final openIsAbove = openA ? ca.tier > cb.tier : cb.tier > ca.tier;
      if (rule == ImdgVerticalRule.stacked ||
          (rule == ImdgVerticalRule.openAboveClosed && openIsAbove)) {
        return result(ValidationStatus.conforming,
            'La disposición vertical satisface la exigencia $requirement para estos tipos de unidad.');
      }
      return result(
          ValidationStatus.nonConforming,
          rule == ImdgVerticalRule.forbidden
              ? 'La exigencia $requirement no admite esta disposición vertical.'
              : 'Esta disposición vertical necesita una cubierta separadora; ambas unidades están en la misma zona.');
    }
    // Modelo heredado: borde de la huella, en huecos de 20 pies, no centros.
    final longitudinalGap = (ca.bay - cb.bay).abs() / 2 - (sizeA + sizeB) / 40;
    final pairBays = {..._occupiedBays(a), ..._occupiedBays(b)};
    String? centerSource(bool onDeck) {
      final declared =
          onDeck ? geometry.centerRowOnDeck : geometry.centerRowInHold;
      if (declared == true) return 'fila 00 declarada';
      if (declared == false) return null;
      return pairBays.any((bay) => occupiedCenterRows.contains((onDeck, bay)))
          ? 'fila 00 ocupada en este viaje'
          : null;
    }

    final source = centerSource(deckA);
    final rows = source != null || ca.row == 0 || cb.row == 0
        ? geometry.orderedRows
        : [...geometry.portRowNumbers, ...geometry.starboardRowNumbers];
    final lateralGap = (rows.indexOf(ca.row) - rows.indexOf(cb.row)).abs() - 1;
    final without = [
      ...geometry.portRowNumbers,
      ...geometry.starboardRowNumbers
    ];
    final gapWithout =
        (without.indexOf(ca.row) - without.indexOf(cb.row)).abs() - 1;
    references.add('IMDG 42-24, 7.4.3.1.1');
    details.add(
        'Derivación por huecos, no medición: longitudinal $longitudinalGap; '
        'transversal $lateralGap. Un espacio exige un hueco completo entre huellas.');
    if (source != null &&
        lateralGap > gapWithout &&
        ca.row != 0 &&
        cb.row != 0) {
      details.add('El cálculo transversal incluye $source.');
    }
    final longRule = Imdg4224Data.horizontalRule(
        requirement, ImdgAxis.longitudinal, pair,
        onDeck: deckA);
    final transRule = Imdg4224Data.horizontalRule(
        requirement, ImdgAxis.transverse, pair,
        onDeck: deckA);
    if (longRule == ImdgHorizontalRule.meters24 ||
        longRule == ImdgHorizontalRule.bulkheadAnd24) {
      details.add(
          'Aproximación de 24 m: cuatro huecos longitudinales de 20 pies (7.4.3.1.1).');
    }
    final longStatus = _horizontal(longRule, longitudinalGap);
    final transStatus = _horizontal(transRule, lateralGap.toDouble());
    if (longStatus == ValidationStatus.conforming ||
        transStatus == ValidationStatus.conforming) {
      return result(
          ValidationStatus.conforming,
          'Exigencia $requirement satisfecha en el modelo de huecos por el sentido '
          '${longStatus == ValidationStatus.conforming ? 'longitudinal' : 'transversal'}; no acredita la columna 16b.');
    }
    if (longStatus == ValidationStatus.notEvaluated ||
        transStatus == ValidationStatus.notEvaluated) {
      return result(ValidationStatus.notEvaluated,
          'La alternativa necesita mamparos que BayStream no conoce; los huecos no bastan para resolverla.');
    }
    return result(ValidationStatus.nonConforming,
        'Exigencia $requirement sin separación suficiente entre las huellas en los sentidos permitidos.');
  }

  static ValidationStatus _horizontal(ImdgHorizontalRule rule, double gap) {
    final minimum = switch (rule) {
      ImdgHorizontalRule.none => 0,
      ImdgHorizontalRule.space1 || ImdgHorizontalRule.space1OrBulkhead => 1,
      ImdgHorizontalRule.space2 => 2,
      ImdgHorizontalRule.space3 => 3,
      ImdgHorizontalRule.meters24 || ImdgHorizontalRule.bulkheadAnd24 => 4,
      _ => null,
    };
    if (rule == ImdgHorizontalRule.forbidden) {
      return ValidationStatus.nonConforming;
    }
    if (rule == ImdgHorizontalRule.none) return ValidationStatus.conforming;
    if (rule == ImdgHorizontalRule.bulkhead1 ||
        rule == ImdgHorizontalRule.bulkhead2) {
      return ValidationStatus.notEvaluated;
    }
    if (rule == ImdgHorizontalRule.bulkheadAnd24) {
      return gap >= 4
          ? ValidationStatus.notEvaluated
          : ValidationStatus.nonConforming;
    }
    if (gap >= minimum!) return ValidationStatus.conforming;
    return rule == ImdgHorizontalRule.space1OrBulkhead
        ? ValidationStatus.notEvaluated
        : ValidationStatus.nonConforming;
  }

  // Supuestos de Carlos, 10.67: se leen aqui, sin alterar ContainerUnit.
  static bool? _isOpen(ContainerUnit c) {
    final iso = (c.isoSizeType ?? '').trim().toUpperCase();
    if (iso.length < 3) return null;
    final type = iso[2];
    if ({'G', 'R', 'T', 'B', 'V', 'H'}.contains(type)) return false;
    if ({'U', 'P'}.contains(type)) return true;
    return null;
  }

  static Set<int> _occupiedBays(ContainerUnit c) {
    final bay = c.stowagePosition?.bay;
    if (bay == null) return const {};
    return c.sizeInFeet != null && c.sizeInFeet! >= 40 && bay.isEven
        ? {bay - 1, bay, bay + 1}
        : {bay};
  }

  static List<String> _secondary(DangerousGoods d) {
    final primary = SegregationRules.classRow(d.hazardClass);
    return {
      for (final label in d.labels)
        if (SegregationRules.classRow(label) != primary)
          label.trim().toUpperCase()
    }.toList();
  }

  static List<String> _classes(DangerousGoods d) => [
        SegregationRules.classRow(d.hazardClass)!,
        for (final s in _secondary(d))
          s.startsWith('1.')
              ? Imdg4224Data.classes[1]
              : SegregationRules.classRow(s)!,
      ];
  static String? _problem(DangerousGoods d) {
    if (d.regulation.trim().toUpperCase() != 'IMD') {
      return 'Código de regulación DGS no cubierto.';
    }
    if (SegregationRules.classRow(d.hazardClass) == null) {
      return 'Clase declarada ausente o fuera de la matriz IMDG.';
    }
    final secondary = _secondary(d);
    if (secondary.any((s) => SegregationRules.classRow(s) == null)) {
      return 'Etiqueta de peligro fuera de la matriz IMDG.';
    }
    if (secondary.length >= 2) {
      return 'Dos o más peligros secundarios: no evaluado; consultar la columna 16b (7.2.3.4).';
    }
    return null;
  }

  static String _name(DangerousGoods d) =>
      'UN${(d.unNumber ?? '').trim().isEmpty ? 'desconocido' : d.unNumber!.trim()} (clase ${d.hazardClass ?? 'sin dato'})';
  static StowageValidationResult _result(
          ContainerUnit a,
          ContainerUnit? b,
          ValidationStatus status,
          String reason,
          Iterable<String> references) =>
      StowageValidationResult(
          rule: StowageRule.dangerousGoodsSegregation,
          status: status,
          severity: switch (status) {
            ValidationStatus.conforming => ValidationSeverity.information,
            ValidationStatus.nonConforming => ValidationSeverity.error,
            ValidationStatus.notEvaluated => ValidationSeverity.warning
          },
          description: reason,
          positions: {
            if (a.stowagePosition != null) a.stowagePosition!,
            if (b?.stowagePosition != null) b!.stowagePosition!
          },
          containerIds: {a.containerId, if (b != null) b.containerId},
          references: references);
}
