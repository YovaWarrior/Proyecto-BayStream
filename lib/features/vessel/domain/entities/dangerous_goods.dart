import 'package:equatable/equatable.dart';

/// Una declaración DGS, no el perfil normativo de la sustancia. Las etiquetas
/// del archivo complementan la tabla ONU; no reemplazan sus riesgos secundarios.
class DangerousGoods extends Equatable {
  final String? unNumber;
  final String? hazardClass;
  final String regulation;
  final List<String> labels;

  DangerousGoods(
      {this.unNumber,
      this.hazardClass,
      this.regulation = 'IMD',
      Iterable<String> labels = const []})
      : labels = List.unmodifiable(labels);

  Map<String, dynamic> toJson() => {
        if (unNumber != null) 'unNumber': unNumber,
        if (hazardClass != null) 'hazardClass': hazardClass,
        'regulation': regulation,
        'labels': labels,
      };

  factory DangerousGoods.fromJson(Map<String, dynamic> json) => DangerousGoods(
        unNumber: json['unNumber'] as String?,
        hazardClass: json['hazardClass'] as String?,
        regulation: json['regulation'] as String? ?? 'IMD',
        labels: (json['labels'] as List<dynamic>?)?.cast<String>() ?? const [],
      );

  @override
  List<Object?> get props => [unNumber, hazardClass, regulation, labels];
}
