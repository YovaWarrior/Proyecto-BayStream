import 'package:equatable/equatable.dart';

import '../../../../core/utils/iso_coordinate_parser.dart';

enum StowageRule {
  stackWeight,
  dangerousGoodsSegregation,
  reeferSocket,
  twentyOverForty,
}

/// Estado de evaluación y severidad son ejes distintos: no evaluar no equivale
/// a aprobar. Las próximas reglas reutilizan este contrato, no otro tipo de alerta.
enum ValidationStatus { conforming, nonConforming, notEvaluated }

enum ValidationSeverity { information, warning, error }

/// Resultado de apoyo a la decisión; nunca certificación de cumplimiento.
/// Admite una pila, un contenedor sin posición o un par en posiciones distintas.
class StowageValidationResult extends Equatable {
  final StowageRule rule;
  final ValidationStatus status;
  final ValidationSeverity severity;
  final String description;
  final List<IsoCoordinate> positions;
  final List<String> containerIds;
  final List<String> references;

  StowageValidationResult({
    required this.rule,
    required this.status,
    required this.severity,
    required this.description,
    required Iterable<IsoCoordinate> positions,
    required Iterable<String> containerIds,
    Iterable<String> references = const [],
  })  : positions = List.unmodifiable(positions),
        containerIds = List.unmodifiable(containerIds),
        references = List.unmodifiable(references);

  @override
  List<Object?> get props => [
        rule,
        status,
        severity,
        description,
        positions,
        containerIds,
        references
      ];
}
