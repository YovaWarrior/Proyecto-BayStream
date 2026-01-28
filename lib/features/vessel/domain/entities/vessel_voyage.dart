import 'package:equatable/equatable.dart';
import 'vessel.dart';
import 'container_unit.dart';
import 'bay.dart';

/// Entidad que representa un viaje completo de un buque
/// 
/// Combina la información del buque (TDT) con todos los contenedores
/// parseados del archivo BAPLIE.
class VesselVoyage extends Equatable {
  /// Identificador único del viaje
  final String id;
  
  /// Información del buque
  final Vessel vessel;
  
  /// Número de viaje (desde TDT e8028)
  final String voyageNumber;
  
  /// Dirección del viaje (Import/Export)
  final VoyageDirection direction;
  
  /// Puerto de origen del archivo BAPLIE
  final String? portOfOrigin;
  
  /// Puerto de destino
  final String? portOfDestination;
  
  /// Fecha de creación del archivo BAPLIE
  final DateTime? messageDate;
  
  /// Lista de todos los contenedores en el buque
  final List<ContainerUnit> containers;
  
  /// Mapa de bahías organizadas por número
  final Map<int, Bay> bays;
  
  /// Metadatos adicionales del mensaje BAPLIE
  final BaplieMetadata? metadata;

  const VesselVoyage({
    required this.id,
    required this.vessel,
    required this.voyageNumber,
    this.direction = VoyageDirection.unknown,
    this.portOfOrigin,
    this.portOfDestination,
    this.messageDate,
    this.containers = const [],
    this.bays = const {},
    this.metadata,
  });

  /// Total de contenedores en el buque
  int get totalContainers => containers.length;
  
  /// Contenedores llenos
  int get fullContainers => 
      containers.where((c) => c.status == ContainerStatus.full).length;
  
  /// Contenedores vacíos
  int get emptyContainers => 
      containers.where((c) => c.status == ContainerStatus.empty).length;
  
  /// Peso total bruto de todos los contenedores (en kg)
  double get totalGrossWeight =>
      containers.fold(0.0, (sum, c) => sum + (c.grossWeight ?? 0));
  
  /// Peso total VGM de todos los contenedores (en kg)
  double get totalVgmWeight =>
      containers.fold(0.0, (sum, c) => sum + (c.vgmWeight ?? 0));

  /// Obtiene contenedores en una bahía específica
  List<ContainerUnit> getContainersInBay(int bayNumber) =>
      containers.where((c) => c.stowagePosition?.bay == bayNumber).toList();

  @override
  List<Object?> get props => [
        id,
        vessel,
        voyageNumber,
        direction,
        portOfOrigin,
        portOfDestination,
        messageDate,
        containers,
        bays,
        metadata,
      ];

  VesselVoyage copyWith({
    String? id,
    Vessel? vessel,
    String? voyageNumber,
    VoyageDirection? direction,
    String? portOfOrigin,
    String? portOfDestination,
    DateTime? messageDate,
    List<ContainerUnit>? containers,
    Map<int, Bay>? bays,
    BaplieMetadata? metadata,
  }) {
    return VesselVoyage(
      id: id ?? this.id,
      vessel: vessel ?? this.vessel,
      voyageNumber: voyageNumber ?? this.voyageNumber,
      direction: direction ?? this.direction,
      portOfOrigin: portOfOrigin ?? this.portOfOrigin,
      portOfDestination: portOfDestination ?? this.portOfDestination,
      messageDate: messageDate ?? this.messageDate,
      containers: containers ?? this.containers,
      bays: bays ?? this.bays,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'vessel': vessel.toJson(),
        'voyageNumber': voyageNumber,
        'direction': direction.name,
        if (portOfOrigin != null) 'portOfOrigin': portOfOrigin,
        if (portOfDestination != null) 'portOfDestination': portOfDestination,
        if (messageDate != null) 'messageDate': messageDate!.toIso8601String(),
        'containers': containers.map((c) => c.toJson()).toList(),
        'bays': bays.map((k, v) => MapEntry(k.toString(), v.toJson())),
        if (metadata != null) 'metadata': metadata!.toJson(),
      };

  factory VesselVoyage.fromJson(Map<String, dynamic> json) => VesselVoyage(
        id: json['id'] as String,
        vessel: Vessel.fromJson(json['vessel'] as Map<String, dynamic>),
        voyageNumber: json['voyageNumber'] as String,
        direction: VoyageDirection.values.firstWhere(
          (e) => e.name == json['direction'],
          orElse: () => VoyageDirection.unknown,
        ),
        portOfOrigin: json['portOfOrigin'] as String?,
        portOfDestination: json['portOfDestination'] as String?,
        messageDate: json['messageDate'] != null
            ? DateTime.parse(json['messageDate'] as String)
            : null,
        containers: (json['containers'] as List<dynamic>?)
                ?.map((e) => ContainerUnit.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        bays: (json['bays'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(int.parse(k), Bay.fromJson(v as Map<String, dynamic>)),
            ) ??
            {},
        metadata: json['metadata'] != null
            ? BaplieMetadata.fromJson(json['metadata'] as Map<String, dynamic>)
            : null,
      );

  @override
  String toString() =>
      'VesselVoyage(vessel: ${vessel.name}, voyage: $voyageNumber, containers: $totalContainers)';
}

/// Dirección del viaje
enum VoyageDirection {
  import_,  // Descarga
  export_,  // Carga
  unknown,
}

/// Metadatos del mensaje BAPLIE
class BaplieMetadata extends Equatable {
  final String? messageReference;
  final String? messageType;
  final String? messageVersion;
  final String? senderIdentification;
  final String? recipientIdentification;
  final DateTime? preparationDateTime;

  const BaplieMetadata({
    this.messageReference,
    this.messageType,
    this.messageVersion,
    this.senderIdentification,
    this.recipientIdentification,
    this.preparationDateTime,
  });

  @override
  List<Object?> get props => [
        messageReference,
        messageType,
        messageVersion,
        senderIdentification,
        recipientIdentification,
        preparationDateTime,
      ];

  Map<String, dynamic> toJson() => {
        if (messageReference != null) 'messageReference': messageReference,
        if (messageType != null) 'messageType': messageType,
        if (messageVersion != null) 'messageVersion': messageVersion,
        if (senderIdentification != null) 'senderIdentification': senderIdentification,
        if (recipientIdentification != null) 'recipientIdentification': recipientIdentification,
        if (preparationDateTime != null)
          'preparationDateTime': preparationDateTime!.toIso8601String(),
      };

  factory BaplieMetadata.fromJson(Map<String, dynamic> json) => BaplieMetadata(
        messageReference: json['messageReference'] as String?,
        messageType: json['messageType'] as String?,
        messageVersion: json['messageVersion'] as String?,
        senderIdentification: json['senderIdentification'] as String?,
        recipientIdentification: json['recipientIdentification'] as String?,
        preparationDateTime: json['preparationDateTime'] != null
            ? DateTime.parse(json['preparationDateTime'] as String)
            : null,
      );
}
