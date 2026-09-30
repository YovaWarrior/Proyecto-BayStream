import 'dart:convert';
import 'dart:io';

import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/container_unit.dart';
import 'package:baystream/features/vessel/domain/entities/dangerous_goods.dart';
import 'package:baystream/features/vessel/domain/entities/stowage_validation_result.dart';
import 'package:baystream/features/vessel/domain/entities/vessel_geometry.dart';
import 'package:baystream/features/vessel/domain/services/dangerous_goods_validator.dart';
import 'package:baystream/features/vessel/domain/services/segregation_rules.dart';

/// T-55, punto 3: `segregation_rules.dart` contra docs/T41-SEGREGACION-FUENTE.md.
///
/// Uso: `dart run tool/t55_tabla_segregacion.dart DIRECTORIO_CORPUS`.
/// Las tablas de este archivo se copiaron a mano de la fuente (§3 y §4), no
/// del código: son el segundo lector, no un espejo de la implementación.
void main(List<String> args) {
  if (args.length != 1) {
    throw ArgumentError('Indicar el directorio del corpus real');
  }
  final out = <String, dynamic>{
    'pares': _pairs(),
    'numerosOnu': _unProfiles(),
    'barrido17x17': _sweep(),
    'casosSinRegla': _noRuleCases(),
    'precedenciaCompatibilidad': _compatibilityPrecedence(),
    'tiposIsoPeligrososDelCorpus': _corpusIsoTypes(args.single),
  };
  stdout.writeln(const JsonEncoder.withIndent('  ').convert(out));
}

/// Fuente §3, los 28 pares: 1, 2, X, * tal como están escritos.
const _source = <String, String>{
  '1.4/1.4': '*', '1.4/2.1': '2', '1.4/3': '2', '1.4/4.1': '2',
  '1.4/5.1': '2', '1.4/8': '2', '1.4/9': 'X', '2.1/2.1': 'X',
  '2.1/3': '2', '2.1/4.1': '1', '2.1/5.1': '2', '2.1/8': '1',
  '2.1/9': 'X', '3/3': 'X', '3/4.1': 'X', '3/5.1': '2', '3/8': 'X',
  '3/9': 'X', '4.1/4.1': 'X', '4.1/5.1': '1', '4.1/8': '1', '4.1/9': 'X',
  '5.1/5.1': 'X', '5.1/8': '2', '5.1/9': 'X', '8/8': 'X', '8/9': 'X',
  '9/9': 'X',
};

String _symbol(SegregationCode? c) => switch (c) {
      SegregationCode.away => '1',
      SegregationCode.separated => '2',
      SegregationCode.substance => 'X',
      SegregationCode.compatibility => '*',
      null => 'sin regla',
    };

Map<String, dynamic> _pairs() {
  final mismatches = <String>[];
  for (final e in _source.entries) {
    final parts = e.key.split('/');
    final ab = _symbol(SegregationRules.code(parts[0], parts[1]));
    final ba = _symbol(SegregationRules.code(parts[1], parts[0]));
    if (ab != e.value || ba != e.value) {
      mismatches.add('${e.key}: fuente ${e.value}, código $ab / $ba');
    }
  }
  final outside = ['1.1', '1.4S', '2.2', '6.1', '7', '4.3', '']
      .where((x) => SegregationRules.code(x, '3') != null)
      .toList();
  return {
    'paresEnFuente': _source.length,
    'discrepancias': mismatches,
    'clasesFueraDeLaMatrizConRegla': outside,
    'clasesDelCodigo': SegregationRules.classes,
  };
}

/// Fuente §4: clase, secundario, grupo de compatibilidad, «como clase 9» y
/// códigos 10B de segregación por grupos (§176.83(m)).
const _unSource = <String, (String, List<String>, String?, bool, List<int>)>{
  '0012': ('1.4', [], 'S', false, []),
  '0303': ('1.4', [], 'G', false, []),
  '1950': ('2.1', [], null, true, []),
  '1170': ('3', [], null, false, []),
  '1263': ('3', [], null, false, []),
  '1266': ('3', [], null, false, []),
  '1993': ('3', [], null, false, []),
  '3065': ('3', [], null, false, []),
  '3175': ('4.1', [], null, false, []),
  '3085': ('5.1', ['8'], null, false, [56, 58, 138]),
  '1719': ('8', [], null, false, [52]),
  '2735': ('8', [], null, false, [52]),
  '2794': ('8', [], null, false, [53, 58]),
  '3084': ('8', ['5.1'], null, false, []),
  '3265': ('8', [], null, false, [53, 58]),
  '3077': ('9', [], null, false, []),
  '3082': ('9', [], null, false, []),
};

Map<String, dynamic> _unProfiles() {
  final mismatches = <String>[];
  const code = SegregationRules.unProfiles;
  for (final e in _unSource.entries) {
    final p = code[e.key];
    final (primary, subsidiary, group, asNine, groups) = e.value;
    if (p == null) {
      mismatches.add('UN${e.key}: falta en el código');
      continue;
    }
    if (p.primary != primary ||
        p.subsidiary.join(',') != subsidiary.join(',') ||
        p.compatibilityGroup != group ||
        p.asClassNine != asNine ||
        ([...p.groupCodes]..sort()).join(',') != groups.join(',')) {
      mismatches.add('UN${e.key}: fuente $primary/$subsidiary/$group/$asNine/'
          '$groups, código ${p.primary}/${p.subsidiary}/'
          '${p.compatibilityGroup}/${p.asClassNine}/${p.groupCodes}');
    }
  }
  final extra = code.keys.where((k) => !_unSource.containsKey(k)).toList();
  return {
    'enFuente': _unSource.length,
    'enCodigo': code.length,
    'discrepancias': mismatches,
    'sobranEnCodigo': extra,
  };
}

const _geometry = VesselGeometry(
    portRows: 6, starboardRows: 6, holdTiers: [2, 4, 6], deckTiers: [82, 84]);
const _dg = DangerousGoodsValidator();

ContainerUnit _unit(String id, String position,
        {String iso = '45G1', required List<DangerousGoods> goods}) =>
    ContainerUnit(
      id: id,
      containerId: id,
      isoSizeType: iso,
      stowagePosition: IsoCoordinateParser.tryParse(position),
      isDangerous: true,
      dangerousGoods: goods,
    );

DangerousGoods _goods(String un, {String? cls, List<String> labels = const []}) =>
    DangerousGoods(
        unNumber: un,
        hazardClass: cls ?? _unSource[un]?.$1,
        labels: labels);

/// Código más restrictivo según la FUENTE, tras secundarios (§176.83(a)(6))
/// y UN1950 como clase 9 (código 126). Solo para decidir si «2» aplica.
bool _sourceRequiresTwo(String a, String b) {
  Set<String> classes(String un) {
    final s = _unSource[un]!;
    return {s.$4 ? '9' : s.$1, ...s.$2};
  }

  for (final x in classes(a)) {
    for (final y in classes(b)) {
      final key = ([x, y]..sort()).join('/');
      if (_source[key] == '2') return true;
    }
  }
  return false;
}

/// Todos los pares de los 17 números ONU en configuraciones sin la
/// separación de un hueco completo. Invariantes: un par con «2» en la fuente
/// nunca sale conforme; un par con grupos (§176.83(m)) nunca sale conforme.
Map<String, dynamic> _sweep() {
  const configs = {
    'contiguas en cubierta (01/03, nivel 82)': ('0020182', '0020382'),
    'misma vertical en cubierta (01, 82/84)': ('0020182', '0020184'),
    'contiguas en bodega (01/03, nivel 04)': ('0020104', '0020304'),
    'bodega bajo cubierta (01, 04/82)': ('0020104', '0020182'),
    'una fila de por medio (01/05, nivel 82)': ('0020182', '0020582'),
  };
  final violations = <String>[];
  final tally = <String, Map<String, int>>{};
  final uns = _unSource.keys.toList();
  for (final cfg in configs.entries) {
    final counts = <String, int>{};
    for (var i = 0; i < uns.length; i++) {
      for (var j = i; j < uns.length; j++) {
        final ga = _goods(uns[i]), gb = _goods(uns[j]);
        final a = _unit('A', cfg.value.$1, goods: [ga]);
        final b = _unit('B', cfg.value.$2, goods: [gb]);
        final r = _dg.evaluatePair(a, ga, b, gb, _geometry);
        counts[r.status.name] = (counts[r.status.name] ?? 0) + 1;
        final hasGroups = _unSource[uns[i]]!.$5.isNotEmpty ||
            _unSource[uns[j]]!.$5.isNotEmpty;
        final spaced = cfg.key.startsWith('una fila');
        if (r.status == ValidationStatus.conforming &&
            ((!spaced && _sourceRequiresTwo(uns[i], uns[j])) || hasGroups)) {
          violations.add('${cfg.key}: UN${uns[i]}/UN${uns[j]} conforme');
        }
      }
    }
    tally[cfg.key] = counts;
  }
  return {'estadosPorConfiguracion': tally, 'violaciones': violations};
}

/// Cada dato que falta o no cubre la tabla, frente a un compañero lejano con
/// el que el par sería conforme. Todos deben salir «no evaluado».
/// El compañero es UN0012 (1.4S): 3/1.4 = 2, así que también se ejercitan
/// tamaño, paridad y geometría; con un par X no habría regla espacial.
Map<String, dynamic> _noRuleCases() {
  final partnerGoods = _goods('0012');
  final partner = _unit('P', '0020982', goods: [partnerGoods]);
  final cases = <String, (String, String, DangerousGoods)>{
    'control: UN1170 cerrado y en su bahía (debe ser conforme)':
        ('45G1', '0020182', _goods('1170')),
    'ONU fuera de los 17 (UN1203)': ('45G1', '0020182', _goods('1203', cls: '3')),
    'ONU ausente': ('45G1', '0020182', DangerousGoods(hazardClass: '3')),
    'clase declarada contradictoria (UN1170 como 8)':
        ('45G1', '0020182', _goods('1170', cls: '8')),
    'clase declarada ausente': ('45G1', '0020182',
        DangerousGoods(unNumber: '1170')),
    'etiqueta fuera de la matriz (6.1)':
        ('45G1', '0020182', _goods('1170', labels: ['6.1'])),
    'regulación distinta de IMD': ('45G1', '0020182',
        DangerousGoods(unNumber: '1170', hazardClass: '3', regulation: 'ADR')),
    'techo abierto 42U1': ('42U1', '0020182', _goods('1170')),
    'plataforma 42P1': ('42P1', '0020182', _goods('1170')),
    'tipo 22K2 del corpus': ('22K2', '0010182', _goods('1170')),
    'ventilado 22V1': ('22V1', '0010182', _goods('1170')),
    'sin tipo ISO': ('', '0020182', _goods('1170')),
    '20 pies en bahía par': ('22G1', '0020182', _goods('1170')),
    '40 pies en bahía impar': ('45G1', '0010182', _goods('1170')),
    'posición fuera de la geometría (fila 14)':
        ('45G1', '0021482', _goods('1170')),
    'sin posición': ('45G1', 'XXXXXXX', _goods('1170')),
  };
  final results = <String, String>{};
  final wrong = <String>[];
  for (final e in cases.entries) {
    final (iso, position, goods) = e.value;
    final unit = ContainerUnit(
        id: 'U',
        containerId: 'U',
        isoSizeType: iso.isEmpty ? null : iso,
        stowagePosition: IsoCoordinateParser.tryParse(position),
        isDangerous: true,
        dangerousGoods: [goods]);
    // Filas 01 y 09: tres filas de por medio, código 2 cumplido si todo cuadra.
    final r = _dg.evaluatePair(unit, goods, partner, partnerGoods, _geometry);
    results[e.key] = r.status.name;
    final isControl = e.key.startsWith('control');
    if ((isControl && r.status != ValidationStatus.conforming) ||
        (!isControl && r.status != ValidationStatus.notEvaluated)) {
      wrong.add('${e.key}: ${r.status.name}');
    }
  }
  return {'estados': results, 'incorrectos': wrong};
}

/// `SegregationCode.compatibility` tiene el índice más alto del enum, y el
/// validador se queda con el índice mayor de todas las combinaciones de clase.
/// Si una unidad 1.4 trae además una etiqueta C236 con otra clase, «*» gana a
/// «2» y el par se resuelve por §176.144 como si ambas fueran solo 1.4.
Map<String, dynamic> _compatibilityPrecedence() {
  const a = '0020182', b = '0020382'; // contiguas en cubierta
  Map<String, String> run(String label, DangerousGoods ga, DangerousGoods gb) {
    final ua = _unit('A', a, goods: [ga]), ub = _unit('B', b, goods: [gb]);
    final r = _dg.evaluatePair(ua, ga, ub, gb, _geometry);
    return {'caso': label, 'estado': r.status.name, 'descripcion': r.description};
  }

  return {
    'posiciones': [a, b],
    'casos': [
      run('control: UN0012 / UN0303, 1.4S con 1.4G', _goods('0012'),
          _goods('0303')),
      run('control: UN0012 con etiqueta 3 / UN1170 (la etiqueta sí cuenta)',
          _goods('0012', labels: ['3']), _goods('1170')),
      run('control: UN1170 / UN0303 (3 frente a 1.4 = código 2)',
          _goods('1170'), _goods('0303')),
      run('UN0012 con etiqueta 3 / UN0303 (3 frente a 1.4G = código 2)',
          _goods('0012', labels: ['3']), _goods('0303')),
      run('UN0012 con etiqueta 5.1 / UN0303', _goods('0012', labels: ['5.1']),
          _goods('0303')),
    ],
  };
}

Map<String, dynamic> _corpusIsoTypes(String dir) {
  final types = <String, int>{};
  for (var i = 1; i <= 6; i++) {
    final v = BaplieParserService()
        .parse(File('$dir/CORPUS_A0$i.edi').readAsStringSync());
    for (final c in v.containers.where((c) =>
        c.isDangerous || (c.dangerousGoods?.isNotEmpty ?? false))) {
      final key = c.isoSizeType ?? 'sin ISO';
      types[key] = (types[key] ?? 0) + 1;
    }
  }
  return {
    'unidadesPeligrosasPorTipo': types,
    'patronCerradoDelValidador': r'^[24LM][0-9A-Z][GRT][0-9]$',
  };
}
