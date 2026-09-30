import 'dart:convert';
import 'dart:io';

import 'package:baystream/features/vessel/data/datasources/local_vessel_codec.dart';
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/vessel_profile.dart';
import 'package:baystream/features/vessel/domain/entities/stowage_validation_result.dart';
import 'package:baystream/features/vessel/domain/services/container_stacking_validator.dart';
import 'package:baystream/features/vessel/domain/services/reefer_socket_validator.dart';
import 'package:baystream/features/vessel/domain/services/stack_weight_validator.dart';
import 'package:baystream/features/vessel/domain/services/dangerous_goods_validator.dart';

/// Uso: `dart run tool/block7b_corpus.dart DIRECTORIO_CORPUS`.
/// Los perfiles declarados aquí son escenarios de prueba, no datos del buque.
void main(List<String> args) {
  if (args.length != 1) {
    throw ArgumentError('Indicar directorio del corpus real');
  }
  final metrics = <String, dynamic>{};
  const codec = LocalVesselCodec();
  for (var i = 1; i <= 6; i++) {
    final name = 'A0$i';
    final raw = File('${args.single}/CORPUS_$name.edi').readAsStringSync();
    final parsed = BaplieParserService().parse(raw);
    final profile = VesselProfile.proposeFrom(parsed);
    final v = parsed.withGeometry(profile.geometry);
    final stacked =
        const ContainerStackingValidator().validate(v, profile.geometry);
    final restored = codec.decodeVoyage(codec.encodeVoyage(v));
    final again = const ContainerStackingValidator()
        .validate(restored, restored.geometry!);
    if (jsonEncode(stacked.map(record).toList()) !=
        jsonEncode(again.map(record).toList())) {
      throw StateError('$name: persistencia cambia apilamiento');
    }
    final reefers =
        const ReeferSocketValidator().validate(v.containers, profile);
    if (reefers.isNotEmpty) {
      throw StateError('$name: propuesta pierde posición reefer');
    }
    metrics[name] = {
      'containers': v.totalContainers,
      'bays': v.bays.length,
      '20ft': v.containers.where((c) => c.sizeInFeet == 20).length,
      '40ftOrMore': v.containers.where((c) => (c.sizeInFeet ?? 0) >= 40).length,
      'reeferPositions': profile.reeferSlots.length,
      'stackingAlerts': stacked.map(record).toList(),
      'roundtrip': 'PASS',
    };
    if (i == 1) {
      if (v.totalContainers != 977 || v.bays.length != 34) {
        throw StateError('A01 incorrecto');
      }
      final testProfile = profile.copyWith(
          stackWeightLimitKg: 75000,
          origin: VesselProfileOrigin.declaredByUser,
          reeferSlotsOrigin: VesselProfileOrigin.declaredByUser);
      final weight = const StackWeightValidator().validate(v, testProfile);
      final dg = const DangerousGoodsValidator()
          .validate(v.containers, profile.geometry);
      final missing = profile.reeferSlots.first;
      final reduced = {...profile.reeferSlots}..remove(missing);
      final declared = const ReeferSocketValidator()
          .validate(v.containers, testProfile.copyWith(reeferSlots: reduced));
      final proposed = const ReeferSocketValidator()
          .validate(v.containers, profile.copyWith(reeferSlots: reduced));
      if (declared.length != 1 ||
          declared.single.severity != ValidationSeverity.error ||
          proposed.length != 1 ||
          proposed.single.severity != ValidationSeverity.warning) {
        throw StateError('A01: severidades/origen incorrectos');
      }
      metrics['A01_TEST_PROFILE_NOT_OPERATIONAL'] = {
        'testLimitKg': 75000,
        'sockets': profile.reeferSlots.length,
        'weightAlerts': weight.map(record).toList(),
        'segregation': dg.map(record).toList(),
        'removedTestSocket': missing,
        'declaredMissingSocket': record(declared.single),
        'proposedMissingSocket': record(proposed.single),
      };
    }
  }
  stdout.writeln(const JsonEncoder.withIndent('  ').convert(metrics));
}

Map<String, dynamic> record(StowageValidationResult r) => {
      'rule': r.rule.name,
      'status': r.status.name,
      'severity': r.severity.name,
      'ids': r.containerIds,
      'positions': r.positions.map((p) => p.toIsoCode()).toList(),
      'description': r.description,
      'references': r.references,
    };
