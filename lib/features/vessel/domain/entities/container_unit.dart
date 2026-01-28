import 'package:equatable/equatable.dart';
import '../../../../core/utils/iso_coordinate_parser.dart';

/// Entidad que representa un contenedor
/// 
/// Datos extraídos del segmento EQD del BAPLIE:
/// - ID Contenedor: c237.e8260
/// - Tipo ISO: c224.e8155 (ej. 22G1, 45R1)
/// - Estado: e8169 ('5' = Full, '4' = Empty)
/// 
/// Pesos del segmento MEA:
/// - WT -> Peso Bruto (Gross Weight)
/// - VGM -> Peso Verificado SOLAS
class ContainerUnit extends Equatable {
  /// Identificador único interno
  final String id;
  
  /// Número de contenedor (formato ISO 6346, ej: MSCU1234567)
  final String containerId;
  
  /// Tipo/Tamaño ISO del contenedor (ej: 22G1, 45R1)
  final String? isoSizeType;
  
  /// Estado del contenedor (lleno/vacío)
  final ContainerStatus status;
  
  /// Posición de estiba en formato ISO (BBBRRTT)
  final IsoCoordinate? stowagePosition;
  
  /// Peso bruto en kilogramos (desde MEA+WT)
  final double? grossWeight;
  
  /// Peso verificado SOLAS en kilogramos (desde MEA+VGM)
  final double? vgmWeight;
  
  /// Tara del contenedor en kilogramos
  final double? tareWeight;
  
  /// Puerto de carga (POL - Port of Loading)
  final String? portOfLoading;
  
  /// Puerto de descarga (POD - Port of Discharge)
  final String? portOfDischarge;
  
  /// Puerto de destino final
  final String? finalDestination;
  
  /// Operador/línea naviera
  final String? operatorCode;
  
  /// Indicador de mercancía peligrosa
  final bool isDangerous;
  
  /// Clase IMDG si es peligroso
  final String? imdgClass;
  
  /// Número ONU si es peligroso
  final String? unNumber;
  
  /// Indicador de contenedor refrigerado
  final bool isReefer;
  
  /// Temperatura requerida (si es reefer)
  final double? temperature;
  
  /// Unidad de temperatura (C/F)
  final String? temperatureUnit;
  
  /// Indicador de sobre-dimensionado (OOG - Out of Gauge)
  final bool isOverDimension;
  
  /// Sobre-altura en cm
  final double? overHeight;
  
  /// Sobre-ancho izquierdo en cm
  final double? overWidthLeft;
  
  /// Sobre-ancho derecho en cm
  final double? overWidthRight;
  
  /// Sobre-longitud frontal en cm
  final double? overLengthFront;
  
  /// Sobre-longitud trasera en cm
  final double? overLengthRear;

  const ContainerUnit({
    required this.id,
    required this.containerId,
    this.isoSizeType,
    this.status = ContainerStatus.unknown,
    this.stowagePosition,
    this.grossWeight,
    this.vgmWeight,
    this.tareWeight,
    this.portOfLoading,
    this.portOfDischarge,
    this.finalDestination,
    this.operatorCode,
    this.isDangerous = false,
    this.imdgClass,
    this.unNumber,
    this.isReefer = false,
    this.temperature,
    this.temperatureUnit,
    this.isOverDimension = false,
    this.overHeight,
    this.overWidthLeft,
    this.overWidthRight,
    this.overLengthFront,
    this.overLengthRear,
  });

  /// Tamaño del contenedor en pies (20, 40, 45, etc.)
  int? get sizeInFeet {
    if (isoSizeType == null || isoSizeType!.isEmpty) return null;
    final firstChar = isoSizeType![0];
    switch (firstChar) {
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

  /// Altura del contenedor
  ContainerHeight? get height {
    if (isoSizeType == null || isoSizeType!.length < 2) return null;
    final secondChar = isoSizeType![1];
    switch (secondChar) {
      case '2':
      case '3':
        return ContainerHeight.standard; // 8'6"
      case '4':
      case '5':
        return ContainerHeight.highCube; // 9'6"
      default:
        return null;
    }
  }

  /// Tipo de contenedor (Dry, Reefer, Tank, etc.)
  ContainerType? get containerType {
    if (isoSizeType == null || isoSizeType!.length < 3) return null;
    final thirdChar = isoSizeType![2];
    switch (thirdChar) {
      case 'G':
        return ContainerType.generalPurpose;
      case 'R':
        return ContainerType.reefer;
      case 'U':
        return ContainerType.openTop;
      case 'P':
        return ContainerType.flatRack;
      case 'T':
        return ContainerType.tank;
      case 'B':
        return ContainerType.bulk;
      default:
        return ContainerType.other;
    }
  }

  /// Peso neto (bruto - tara)
  double? get netWeight {
    if (grossWeight == null) return null;
    return grossWeight! - (tareWeight ?? 0);
  }

  @override
  List<Object?> get props => [
        id,
        containerId,
        isoSizeType,
        status,
        stowagePosition,
        grossWeight,
        vgmWeight,
        tareWeight,
        portOfLoading,
        portOfDischarge,
        finalDestination,
        operatorCode,
        isDangerous,
        imdgClass,
        unNumber,
        isReefer,
        temperature,
        temperatureUnit,
        isOverDimension,
        overHeight,
        overWidthLeft,
        overWidthRight,
        overLengthFront,
        overLengthRear,
      ];

  ContainerUnit copyWith({
    String? id,
    String? containerId,
    String? isoSizeType,
    ContainerStatus? status,
    IsoCoordinate? stowagePosition,
    double? grossWeight,
    double? vgmWeight,
    double? tareWeight,
    String? portOfLoading,
    String? portOfDischarge,
    String? finalDestination,
    String? operatorCode,
    bool? isDangerous,
    String? imdgClass,
    String? unNumber,
    bool? isReefer,
    double? temperature,
    String? temperatureUnit,
    bool? isOverDimension,
    double? overHeight,
    double? overWidthLeft,
    double? overWidthRight,
    double? overLengthFront,
    double? overLengthRear,
  }) {
    return ContainerUnit(
      id: id ?? this.id,
      containerId: containerId ?? this.containerId,
      isoSizeType: isoSizeType ?? this.isoSizeType,
      status: status ?? this.status,
      stowagePosition: stowagePosition ?? this.stowagePosition,
      grossWeight: grossWeight ?? this.grossWeight,
      vgmWeight: vgmWeight ?? this.vgmWeight,
      tareWeight: tareWeight ?? this.tareWeight,
      portOfLoading: portOfLoading ?? this.portOfLoading,
      portOfDischarge: portOfDischarge ?? this.portOfDischarge,
      finalDestination: finalDestination ?? this.finalDestination,
      operatorCode: operatorCode ?? this.operatorCode,
      isDangerous: isDangerous ?? this.isDangerous,
      imdgClass: imdgClass ?? this.imdgClass,
      unNumber: unNumber ?? this.unNumber,
      isReefer: isReefer ?? this.isReefer,
      temperature: temperature ?? this.temperature,
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
      isOverDimension: isOverDimension ?? this.isOverDimension,
      overHeight: overHeight ?? this.overHeight,
      overWidthLeft: overWidthLeft ?? this.overWidthLeft,
      overWidthRight: overWidthRight ?? this.overWidthRight,
      overLengthFront: overLengthFront ?? this.overLengthFront,
      overLengthRear: overLengthRear ?? this.overLengthRear,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'containerId': containerId,
        if (isoSizeType != null) 'isoSizeType': isoSizeType,
        'status': status.name,
        if (stowagePosition != null) 'stowagePosition': stowagePosition!.toJson(),
        if (grossWeight != null) 'grossWeight': grossWeight,
        if (vgmWeight != null) 'vgmWeight': vgmWeight,
        if (tareWeight != null) 'tareWeight': tareWeight,
        if (portOfLoading != null) 'portOfLoading': portOfLoading,
        if (portOfDischarge != null) 'portOfDischarge': portOfDischarge,
        if (finalDestination != null) 'finalDestination': finalDestination,
        if (operatorCode != null) 'operatorCode': operatorCode,
        'isDangerous': isDangerous,
        if (imdgClass != null) 'imdgClass': imdgClass,
        if (unNumber != null) 'unNumber': unNumber,
        'isReefer': isReefer,
        if (temperature != null) 'temperature': temperature,
        if (temperatureUnit != null) 'temperatureUnit': temperatureUnit,
        'isOverDimension': isOverDimension,
        if (overHeight != null) 'overHeight': overHeight,
        if (overWidthLeft != null) 'overWidthLeft': overWidthLeft,
        if (overWidthRight != null) 'overWidthRight': overWidthRight,
        if (overLengthFront != null) 'overLengthFront': overLengthFront,
        if (overLengthRear != null) 'overLengthRear': overLengthRear,
      };

  factory ContainerUnit.fromJson(Map<String, dynamic> json) => ContainerUnit(
        id: json['id'] as String,
        containerId: json['containerId'] as String,
        isoSizeType: json['isoSizeType'] as String?,
        status: ContainerStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => ContainerStatus.unknown,
        ),
        stowagePosition: json['stowagePosition'] != null
            ? IsoCoordinate.fromJson(json['stowagePosition'] as Map<String, dynamic>)
            : null,
        grossWeight: (json['grossWeight'] as num?)?.toDouble(),
        vgmWeight: (json['vgmWeight'] as num?)?.toDouble(),
        tareWeight: (json['tareWeight'] as num?)?.toDouble(),
        portOfLoading: json['portOfLoading'] as String?,
        portOfDischarge: json['portOfDischarge'] as String?,
        finalDestination: json['finalDestination'] as String?,
        operatorCode: json['operatorCode'] as String?,
        isDangerous: json['isDangerous'] as bool? ?? false,
        imdgClass: json['imdgClass'] as String?,
        unNumber: json['unNumber'] as String?,
        isReefer: json['isReefer'] as bool? ?? false,
        temperature: (json['temperature'] as num?)?.toDouble(),
        temperatureUnit: json['temperatureUnit'] as String?,
        isOverDimension: json['isOverDimension'] as bool? ?? false,
        overHeight: (json['overHeight'] as num?)?.toDouble(),
        overWidthLeft: (json['overWidthLeft'] as num?)?.toDouble(),
        overWidthRight: (json['overWidthRight'] as num?)?.toDouble(),
        overLengthFront: (json['overLengthFront'] as num?)?.toDouble(),
        overLengthRear: (json['overLengthRear'] as num?)?.toDouble(),
      );

  @override
  String toString() =>
      'ContainerUnit($containerId, type: $isoSizeType, pos: ${stowagePosition?.displayFormat})';
}

/// Estado del contenedor según BAPLIE e8169
enum ContainerStatus {
  full,    // '5' - Contenedor lleno
  empty,   // '4' - Contenedor vacío
  unknown,
}

/// Altura del contenedor
enum ContainerHeight {
  standard, // 8'6"
  highCube, // 9'6"
}

/// Tipo de contenedor según código ISO
enum ContainerType {
  generalPurpose, // G - Dry container
  reefer,         // R - Refrigerado
  openTop,        // U - Techo abierto
  flatRack,       // P - Flat rack
  tank,           // T - Tanque
  bulk,           // B - Granelero
  other,
}
