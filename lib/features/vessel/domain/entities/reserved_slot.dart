import 'package:equatable/equatable.dart';

import '../../../../core/utils/iso_coordinate_parser.dart';
import 'container_unit.dart';
import 'dangerous_goods.dart';

/// Posición prevista en el plan, todavía sin número de contenedor.
/// El peso es nominal: no participa en peso, ocupación ni validación de pilas.
class ReservedSlot extends Equatable {
  final IsoCoordinate stowagePosition;
  final String? isoSizeType;
  final ContainerStatus status;
  final String? portOfLoading;
  final String? portOfDischarge;
  final String? operatorCode;
  final double? nominalWeight;
  final bool isReefer;
  final double? temperature;
  final String? temperatureUnit;
  final bool isDangerous;
  final String? imdgClass;
  final String? unNumber;
  final List<DangerousGoods> dangerousGoods;

  const ReservedSlot({
    required this.stowagePosition,
    this.isoSizeType,
    this.status = ContainerStatus.unknown,
    this.portOfLoading,
    this.portOfDischarge,
    this.operatorCode,
    this.nominalWeight,
    this.isReefer = false,
    this.temperature,
    this.temperatureUnit,
    this.isDangerous = false,
    this.imdgClass,
    this.unNumber,
    this.dangerousGoods = const [],
  });

  /// Identidad estable del plan publicado (T-79a, sección 2.2).
  String get key => 'R:${stowagePosition.toIsoCode()}';

  int? get sizeInFeet {
    if (isoSizeType == null || isoSizeType!.isEmpty) return null;
    switch (isoSizeType![0]) {
      case '2':
        return 20;
      case '4':
        return 40;
      case 'L':
      case 'M':
        return 45;
      default:
        return null;
    }
  }

  @override
  List<Object?> get props => [
        stowagePosition,
        isoSizeType,
        status,
        portOfLoading,
        portOfDischarge,
        operatorCode,
        nominalWeight,
        isReefer,
        temperature,
        temperatureUnit,
        isDangerous,
        imdgClass,
        unNumber,
        dangerousGoods
      ];

  Map<String, dynamic> toJson() => {
        'stowagePosition': stowagePosition.toJson(),
        if (isoSizeType != null) 'isoSizeType': isoSizeType,
        'status': status.name,
        if (portOfLoading != null) 'portOfLoading': portOfLoading,
        if (portOfDischarge != null) 'portOfDischarge': portOfDischarge,
        if (operatorCode != null) 'operatorCode': operatorCode,
        if (nominalWeight != null) 'nominalWeight': nominalWeight,
        'isReefer': isReefer,
        if (temperature != null) 'temperature': temperature,
        if (temperatureUnit != null) 'temperatureUnit': temperatureUnit,
        'isDangerous': isDangerous,
        if (imdgClass != null) 'imdgClass': imdgClass,
        if (unNumber != null) 'unNumber': unNumber,
        'dangerousGoods': dangerousGoods.map((d) => d.toJson()).toList(),
      };

  factory ReservedSlot.fromJson(Map<String, dynamic> json) => ReservedSlot(
        stowagePosition: IsoCoordinate.fromJson(
            json['stowagePosition'] as Map<String, dynamic>),
        isoSizeType: json['isoSizeType'] as String?,
        status: ContainerStatus.values.firstWhere(
            (s) => s.name == json['status'],
            orElse: () => ContainerStatus.unknown),
        portOfLoading: json['portOfLoading'] as String?,
        portOfDischarge: json['portOfDischarge'] as String?,
        operatorCode: json['operatorCode'] as String?,
        nominalWeight: (json['nominalWeight'] as num?)?.toDouble(),
        isReefer: json['isReefer'] as bool? ?? false,
        temperature: (json['temperature'] as num?)?.toDouble(),
        temperatureUnit: json['temperatureUnit'] as String?,
        isDangerous: json['isDangerous'] as bool? ?? false,
        imdgClass: json['imdgClass'] as String?,
        unNumber: json['unNumber'] as String?,
        dangerousGoods: List.unmodifiable(
            (json['dangerousGoods'] as List<dynamic>? ?? []).map(
                (d) => DangerousGoods.fromJson(d as Map<String, dynamic>))),
      );
}
