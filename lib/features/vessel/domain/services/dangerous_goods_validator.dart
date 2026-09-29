import '../entities/container_unit.dart';
import '../entities/dangerous_goods.dart';
import '../entities/stowage_validation_result.dart';
import '../entities/vessel_geometry.dart';
import 'segregation_rules.dart';

/// T-41. Apoyo a la decisión según 49 CFR; no verifica cumplimiento IMDG.
/// Evalúa todas las declaraciones, incluso dos DGS de una misma unidad.
class DangerousGoodsValidator {
  const DangerousGoodsValidator();

  List<StowageValidationResult> validate(
      Iterable<ContainerUnit> containers, VesselGeometry geometry) {
    final entries = <(ContainerUnit, DangerousGoods)>[];
    final results = <StowageValidationResult>[];
    for (final c in containers) {
      if (!c.isDangerous && (c.dangerousGoods?.isEmpty ?? true)) continue;
      if (c.dangerousGoods == null || c.dangerousGoods!.isEmpty) {
        results.add(_result(
            c,
            null,
            ValidationStatus.notEvaluated,
            'Registro sin lista completa de DGS. Volver a importar el BAPLIE '
            'para evaluar todas las sustancias; el dato histórico solo conservaba una.',
            []));
        continue;
      }
      for (final d in c.dangerousGoods!) {
        entries.add((c, d));
        final problem = _problem(c, d);
        if (problem != null) {
          results.add(_result(c, null, ValidationStatus.notEvaluated,
              '${_name(d)}: $problem', ['49 CFR §172.101', '49 CFR §176.2']));
        }
      }
    }
    for (var i = 0; i < entries.length; i++) {
      for (var j = i + 1; j < entries.length; j++) {
        results.add(evaluatePair(entries[i].$1, entries[i].$2, entries[j].$1,
            entries[j].$2, geometry));
      }
    }
    return List.unmodifiable(results);
  }

  StowageValidationResult evaluatePair(ContainerUnit a, DangerousGoods da,
      ContainerUnit b, DangerousGoods db, VesselGeometry geometry) {
    final references = <String>[
      '49 CFR §172.101 (${_name(da)}, ${_name(db)})',
      '49 CFR §176.83(b)',
      '49 CFR §176.83(a)(6)'
    ];
    final prefix = '${_name(da)} / ${_name(db)}. ';
    StowageValidationResult result(ValidationStatus status, String reason) =>
        _result(a, b, status, '$prefix$reason', references);
    final problemA = _problem(a, da), problemB = _problem(b, db);
    if (problemA != null || problemB != null) {
      return result(
          ValidationStatus.notEvaluated,
          [if (problemA != null) problemA, if (problemB != null) problemB]
              .join(' '));
    }
    final pa = SegregationRules.unProfiles[_un(da)]!;
    final pb = SegregationRules.unProfiles[_un(db)]!;
    final ca = a.stowagePosition, cb = b.stowagePosition;
    if (ca == null ||
        cb == null ||
        !geometry.covers(ca) ||
        !geometry.covers(cb)) {
      return result(ValidationStatus.notEvaluated,
          'Posición ausente o fuera de la geometría declarada.');
    }
    final sameUnit = a.id == b.id;
    final classesA = _classes(da, pa), classesB = _classes(db, pb);
    var code = SegregationCode.substance;
    for (final x in classesA) {
      for (final y in classesB) {
        final candidate = SegregationRules.code(x, y);
        if (candidate == null) {
          return result(ValidationStatus.notEvaluated,
              'Clase o etiqueta $x/$y fuera de la matriz documentada.');
        }
        if (candidate.index > code.index) code = candidate;
      }
    }
    final details = <String>[];
    if (pa.asClassNine || pb.asClassNine) {
      references
          .addAll(['49 CFR §176.84 códigos 87 y 126', '49 CFR §176.83(a)(10)']);
      details.add('UN1950 se segrega como clase 9 (código 126), con excepción '
          'de 1.4 en el código 87.');
    }
    if (pa.subsidiary.isNotEmpty || pb.subsidiary.isNotEmpty) {
      details.add('Se incorporaron los riesgos secundarios de la tabla ONU '
          '(${{...pa.subsidiary, ...pb.subsidiary}.join(', ')}).');
    }
    final groups = {...pa.groupCodes, ...pb.groupCodes}.toList()..sort();
    final unresolvedGroups = groups.isNotEmpty;
    String groupReason() => 'Grupos de segregación no evaluados '
        '(códigos ${groups.join(', ')}): posible incompatibilidad '
        'ácido/álcali u otros grupos; confirmar con el embarcador. '
        '§176.83(m) remite al IMDG 3.1.4; no se infiere pertenencia al grupo.';
    if (unresolvedGroups) references.add('49 CFR §176.83(m)(1)-(2)');
    String explain(String reason) =>
        [...details, reason, if (unresolvedGroups) groupReason()].join(' ');
    StowageValidationResult pass(String reason) => result(
        unresolvedGroups
            ? ValidationStatus.notEvaluated
            : ValidationStatus.conforming,
        explain(reason));

    if (code == SegregationCode.compatibility) {
      references.add('49 CFR §176.144(a),(e)');
      if (pa.compatibilityGroup == null ||
          pb.compatibilityGroup == null ||
          !{'S', 'G'}.contains(pa.compatibilityGroup) ||
          !{'S', 'G'}.contains(pb.compatibilityGroup)) {
        return result(ValidationStatus.notEvaluated,
            'Grupo de compatibilidad de clase 1 no cubierto por las entradas ONU.');
      }
      return pass('Grupos ${pa.compatibilityGroup}/${pb.compatibilityGroup} '
          'autorizados juntos por §176.144; la letra procede del número ONU.');
    }
    // §176.83(a)(8): la excepción entre sustancias de la misma clase exige
    // confirmar ausencia de reacción peligrosa; no la inferimos de la clase.
    if (pa.primary == pb.primary && code != SegregationCode.substance) {
      references.add('49 CFR §176.83(a)(8)');
      return result(
          ValidationStatus.notEvaluated,
          explain(
              'Misma clase primaria con riesgo subsidiario: confirmar compatibilidad '
              'química antes de aplicar la excepción de §176.83(a)(8).'));
    }
    if (sameUnit && code != SegregationCode.substance) {
      references.add('49 CFR §176.83(d)');
      return result(
          ValidationStatus.nonConforming,
          explain(
              'Posible incumplimiento: sustancias que requieren segregación en la misma unidad.'));
    }
    if (code == SegregationCode.substance) {
      return pass(
          'Sin exigencia adicional en las reglas por número ONU evaluadas; '
          'no es una declaración de cumplimiento integral.');
    }
    references.add('49 CFR §176.83(f)');
    if (code == SegregationCode.away) {
      return pass(
          'Código 1: sin restricción espacial entre unidades cerradas separadas.');
    }

    final sizeA = a.sizeInFeet, sizeB = b.sizeInFeet;
    if (sizeA == null ||
        sizeB == null ||
        (sizeA == 20) != ca.bay.isOdd ||
        (sizeB == 20) != cb.bay.isOdd) {
      return result(
          ValidationStatus.notEvaluated,
          explain(
              'Longitud o relación tamaño/bahía no confirmada para comparar las huellas.'));
    }
    final deckA = geometry.isDeckTier(ca.tier),
        deckB = geometry.isDeckTier(cb.tier);
    // Derivación geométrica rotulada, NO conversión medida a metros:
    // una unidad longitudinal es un hueco de 20 pies; el centro avanza media
    // unidad por número de bahía. Se compara el borde, no solo el centro.
    final longitudinalGap = (ca.bay - cb.bay).abs() / 2 - (sizeA + sizeB) / 40;
    final rows = geometry.orderedRows;
    final lateralGap = (rows.indexOf(ca.row) - rows.indexOf(cb.row)).abs() - 1;
    final overlaps = longitudinalGap < 0 && ca.row == cb.row;
    if (overlaps) {
      return result(
          deckA == deckB
              ? ValidationStatus.nonConforming
              : ValidationStatus.notEvaluated,
          explain(deckA == deckB
              ? 'Posible incumplimiento: código 2 en la misma vertical sin una cubierta separadora declarada.'
              : 'Misma vertical entre cubierta y bodega: se desconoce si la cubierta es resistente al fuego y a los líquidos.'));
    }
    details.add('Derivación por huecos, no medición: un hueco completo entre '
        'huellas en sentido longitudinal o transversal. §176.83(f)(4) exige '
        '6 m o 2,5 m respectivamente; confirmar el paso real del buque.');
    // Una separación horizontal puede conseguirse por cualquiera de los ejes.
    if (longitudinalGap >= 1 || lateralGap >= 1) {
      return pass(
          'Código 2: separación satisfecha en el modelo de huecos declarado.');
    }
    if (!deckA || !deckB) {
      return result(
          ValidationStatus.notEvaluated,
          explain(
              'Distancia insuficiente en huecos; no se conocen los mamparos ni '
              'la resistencia de las cubiertas que podrían aportar la separación alternativa.'));
    }
    return result(
        ValidationStatus.nonConforming,
        explain(
            'Posible incumplimiento: código 2 sin un hueco completo de separación entre las huellas.'));
  }

  static String? _problem(ContainerUnit c, DangerousGoods d) {
    if (d.regulation != 'IMD') return 'Código de regulación DGS no cubierto.';
    final profile = SegregationRules.unProfiles[_un(d)];
    if (profile == null) {
      return 'Número ONU ausente o fuera de los 17 números evaluados.';
    }
    final declared = (d.hazardClass ?? '').trim().toUpperCase();
    if (declared != profile.primary &&
        declared != '${profile.primary}${profile.compatibilityGroup ?? ''}') {
      return 'Clase declarada ausente, fuera de la matriz o contradictoria con la entrada ONU evaluada.';
    }
    if (_classes(d, profile)
        .any((x) => !SegregationRules.classes.contains(x))) {
      return 'Etiqueta de peligro fuera de la matriz documentada.';
    }
    // §176.2: solo tipos de envolvente permanente reconocidos. 22K2 y
    // unidades abiertas no se tratan como cerradas por omisión.
    if (c.isoSizeType == null ||
        !RegExp(r'^[24LM][0-9A-Z][GRT][0-9]$').hasMatch(c.isoSizeType!)) {
      return 'Tipo de unidad cerrada no confirmado (${c.isoSizeType ?? 'sin ISO'}).';
    }
    return null;
  }

  static Set<String> _classes(DangerousGoods d, UnSegregationProfile p) => {
        p.asClassNine ? '9' : p.primary,
        ...p.subsidiary,
        ...d.labels
            .map((s) => s.trim().toUpperCase())
            .where((s) =>
                s != p.primary &&
                s != '${p.primary}${p.compatibilityGroup ?? ''}')
            .map((s) => s == '1.4S' || s == '1.4G' ? '1.4' : s),
      };
  static String _un(DangerousGoods d) => (d.unNumber ?? '').trim();
  static String _name(DangerousGoods d) =>
      'UN${_un(d).isEmpty ? 'desconocido' : _un(d)}';

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
            ValidationStatus.notEvaluated => ValidationSeverity.warning,
          },
          description: reason,
          positions: {
            if (a.stowagePosition != null) a.stowagePosition!,
            if (b?.stowagePosition != null) b!.stowagePosition!
          },
          containerIds: {a.containerId, if (b != null) b.containerId},
          references: references);
}
