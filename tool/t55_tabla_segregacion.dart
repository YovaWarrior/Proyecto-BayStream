import 'dart:convert';
import 'dart:io';
import 't86_corpus_support.dart';
import 'package:baystream/core/utils/iso_coordinate_parser.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/container_unit.dart';
import 'package:baystream/features/vessel/domain/entities/dangerous_goods.dart';
import 'package:baystream/features/vessel/domain/entities/stowage_validation_result.dart';
import 'package:baystream/features/vessel/domain/entities/vessel_geometry.dart';
import 'package:baystream/features/vessel/domain/services/dangerous_goods_validator.dart';
import 'package:baystream/features/vessel/domain/services/segregation_rules.dart';

/// T-55 actualizado por T-85: barrido funcional por clase, no perfiles ONU.
/// El cotejo de datos contra la fuente privada lo hace t85_tabla_privada.dart.
/// Uso: dart run tool/t55_tabla_segregacion.dart DIRECTORIO_CORPUS > SALIDA_TEMP
void main(List<String> args) {
  if (args.length != 1) throw ArgumentError('Indicar directorio del corpus.');
  const g = VesselGeometry(
      portRows: 6,
      starboardRows: 6,
      holdTiers: [2, 4, 6],
      deckTiers: [82, 84, 86]);
  const validator = DangerousGoodsValidator();
  final tally = <String, Map<String, int>>{};
  var evaluated = 0;
  for (final config in [
    ('contiguas', '0010182', '0010382'),
    ('vertical', '0010182', '0010184'),
    ('con_hueco', '0010182', '0050182')
  ]) {
    final counts = <String, int>{};
    for (final a in SegregationRules.classes) {
      for (final b in SegregationRules.classes) {
        ContainerUnit unit(String id, String cls, String p) => ContainerUnit(
            id: id,
            containerId: id,
            isoSizeType: '22G1',
            stowagePosition: IsoCoordinateParser.parse(p),
            isDangerous: true,
            dangerousGoods: [DangerousGoods(hazardClass: cls)]);
        final ua = unit('A', a, config.$2), ub = unit('B', b, config.$3);
        final r = validator.evaluatePair(
            ua, ua.dangerousGoods!.single, ub, ub.dangerousGoods!.single, g);
        counts[r.status.name] = (counts[r.status.name] ?? 0) + 1;
        evaluated++;
        final requirement =
            SegregationRules.requirement(SegregationRules.code(a, b)!);
        if (config.$1 == 'contiguas' &&
            requirement >= 2 &&
            r.status == ValidationStatus.conforming) {
          throw StateError('Par $a/$b aprobado sin hueco.');
        }
        if ((a == '9' || b == '9') && r.status != ValidationStatus.notEvaluated) {
          throw StateError('Clase 9 aprobada.');
        }
      }
    }
    tally[config.$1] = counts;
  }
  final types = <String, int>{};
  for (final name in ['A01', 'A02', 'A03', 'A04', 'A05', 'A06']) {
    final raw = File('${args.single}/CORPUS_$name.edi').readAsStringSync();
    final v = name == 'A06'
        ? readA06WithNotice(raw)
        : BaplieParserService().parse(raw);
    for (final c in v.containers.where((c) => c.isDangerous)) {
      final k = c.isoSizeType ?? 'sin ISO';
      types[k] = (types[k] ?? 0) + 1;
    }
  }
  stdout.writeln(const JsonEncoder.withIndent('  ').convert({
    'fuente': SegregationRules.disclaimer,
    'clases': SegregationRules.classes,
    'matriz': [
      for (final a in SegregationRules.classes)
        [
          for (final b in SegregationRules.classes)
            SegregationRules.symbol(SegregationRules.code(a, b)!)
        ]
    ],
    'paresPorConfiguracion': 289,
    'evaluaciones': evaluated,
    'estados': tally,
    'tiposPeligrososEnCorpus': types,
    'cerradas': 'G R T B V H',
    'abiertas': 'U P',
    'datosPrivados':
        'Cotejar con tool/t85_tabla_privada.dart; no se leen aqui.',
  }));
}
