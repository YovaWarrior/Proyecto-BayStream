import 'dart:convert';
import 'dart:io';

import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';
import 'package:baystream/features/vessel/domain/entities/stowage_validation_result.dart';
import 'package:baystream/features/vessel/domain/entities/vessel_profile.dart';
import 'package:baystream/features/vessel/domain/entities/vessel_voyage.dart';
import 'package:baystream/features/vessel/domain/services/container_stacking_validator.dart';
import 'package:baystream/features/vessel/domain/services/dangerous_goods_validator.dart';
import 'package:baystream/features/vessel/domain/services/reefer_socket_validator.dart';
import 'package:baystream/features/vessel/domain/services/stack_weight_validator.dart';

/// Aceptación de T-42: reproduce, fuera de la interfaz, lo que muestra el panel.
///
/// Uso: `dart run tool/t42_aceptacion.dart DIRECTORIO_CORPUS`.
/// Llama a los mismos cuatro validadores que `stowageValidationResultsProvider`.
/// El orden copia `compareValidationResults`: importarlo arrastraría Flutter,
/// que `dart run` no tiene. No modifica `lib/`. Los perfiles de aquí son los
/// que el planificador puede declarar: sin datos inventados del buque.
void main(List<String> args) {
  if (args.length != 1) {
    throw ArgumentError('Indicar el directorio del corpus real');
  }
  final dir = args.single;
  VesselVoyage load(String name) => BaplieParserService()
      .parse(File('$dir/CORPUS_$name.edi').readAsStringSync());
  final a01 = load('A01'), a03 = load('A03');

  final out = <String, dynamic>{
    'A01 declarado: fila 00 no existe, sin limite, tomas propuestas': _panel(
        a01,
        VesselProfile.proposeFrom(a01).copyWith(
            deckTierFloor: null,
            stackWeightLimitKg: null,
            geometry: VesselProfile.proposeFrom(a01)
                .geometry
                .copyWith(centerRowOnDeck: false, centerRowInHold: false))),
    'A01 propuesta pura (fila 00 sin declarar)':
        _panel(a01, VesselProfile.proposeFrom(a01)),
    'A03 perfil historico (fila 00 en null)': _panel(
        a03,
        VesselProfile.proposeFrom(a03).copyWith(
            geometry: VesselProfile.proposeFrom(a03).geometry.copyWith(
                centerRowOnDeck: null, centerRowInHold: null))),
    'A03 propuesta nueva (fila 00 segun el viaje)':
        _panel(a03, VesselProfile.proposeFrom(a03)),
  };
  stdout.writeln(const JsonEncoder.withIndent('  ').convert(out));
}

int compareValidationResults(
    StowageValidationResult a, StowageValidationResult b) {
  final severity = b.severity.index.compareTo(a.severity.index);
  if (severity != 0) return severity;
  int statusRank(ValidationStatus s) => switch (s) {
        ValidationStatus.nonConforming => 0,
        ValidationStatus.notEvaluated => 1,
        ValidationStatus.conforming => 2,
      };
  final status = statusRank(a.status).compareTo(statusRank(b.status));
  if (status != 0) return status;
  final rule = a.rule.index.compareTo(b.rule.index);
  if (rule != 0) return rule;
  final position = a.positions
      .map((p) => p.toIsoCode())
      .join('/')
      .compareTo(b.positions.map((p) => p.toIsoCode()).join('/'));
  if (position != 0) return position;
  return '${a.containerIds.join('/')}/${a.description}'
      .compareTo('${b.containerIds.join('/')}/${b.description}');
}

Map<String, dynamic> _panel(VesselVoyage parsed, VesselProfile profile) {
  final voyage = parsed.withGeometry(profile.geometry);
  final results = [
    ...const StackWeightValidator().validate(voyage, profile),
    ...const ReeferSocketValidator().validate(voyage.containers, profile),
    ...const ContainerStackingValidator().validate(voyage, profile.geometry),
    ...const DangerousGoodsValidator()
        .validate(voyage.containers, profile.geometry),
  ]..sort(compareValidationResults);

  int count(ValidationStatus s) => results.where((r) => r.status == s).length;
  String reason(StowageValidationResult r) {
    final d = r.description;
    if (d.contains('Registro sin lista completa')) return 'registro historico sin lista DGS';
    if (d.contains('Posición ausente')) return 'posicion ausente o fuera de geometria';
    if (d.contains('Tipo de unidad cerrada')) return 'tipo de unidad no confirmado como cerrado';
    if (d.contains('Grupos de segregación no evaluados')) return 'grupos de segregacion (49 CFR 176.83(m))';
    if (d.contains('Distancia insuficiente')) return 'mamparos o cubierta desconocidos';
    if (d.contains('Misma vertical entre cubierta y bodega')) return 'cubierta entre bodega y cubierta';
    if (d.contains('fuera de la matriz') || d.contains('fuera de los 17')) return 'clase u ONU fuera de la tabla';
    if (d.contains('Longitud o relación')) return 'tamano/bahia no confirmado';
    if (d.contains('Misma clase primaria')) return 'misma clase con secundario (a)(8)';
    return 'OTRO: ${d.length > 80 ? d.substring(0, 80) : d}';
  }

  final reasons = <String, int>{};
  for (final r in results.where((r) => r.status == ValidationStatus.notEvaluated)) {
    final k = reason(r);
    reasons[k] = (reasons[k] ?? 0) + 1;
  }
  final unexplained = results
      .where((r) =>
          r.description.trim().isEmpty ||
          (r.rule == StowageRule.dangerousGoodsSegregation &&
              r.references.isEmpty) ||
          r.positions.isEmpty && r.status != ValidationStatus.notEvaluated)
      .length;
  final centerRowNotes = results
      .where((r) =>
          r.description.contains('fila 00 declarada') ||
          r.description.contains('fila 00 ocupada'))
      .length;

  return {
    'buque': voyage.vessel.name,
    'filaCentralCubierta': profile.geometry.centerRowOnDeck,
    'filaCentralBodega': profile.geometry.centerRowInHold,
    'limiteKg': profile.stackWeightLimitKg,
    'origenTomas': profile.reeferSlotsOrigin.name,
    'tomas': profile.reeferSlots.length,
    'panel': '${count(ValidationStatus.nonConforming)} / '
        '${count(ValidationStatus.notEvaluated)} / '
        '${count(ValidationStatus.conforming)}',
    'porRegla': {
      for (final rule in StowageRule.values)
        rule.name: results.where((r) => r.rule == rule).length,
    },
    'noEvaluadosPorMotivo': reasons,
    'resultadosSinExplicacion': unexplained,
    'descripcionesQueNombranLaFila00': centerRowNotes,
    'primeros': results
        .take(3)
        .map((r) => {
              'estado': r.status.name,
              'posiciones': r.positions.map((p) => p.toIsoCode()).toList(),
              'contenedores': r.containerIds,
            })
        .toList(),
    'todos': results
        .map((r) => {
              'estado': r.status.name,
              'severidad': r.severity.name,
              'regla': r.rule.name,
              'posiciones': r.positions.map((p) => p.toIsoCode()).toList(),
              'contenedores': r.containerIds,
              'descripcion': r.description,
              'referencias': r.references,
            })
        .toList(),
  };
}
