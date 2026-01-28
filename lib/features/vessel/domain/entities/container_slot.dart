import 'package:equatable/equatable.dart';
import 'container_unit.dart';

/// Entidad que representa una celda/slot en el plan de estiba
/// 
/// Cada slot tiene una posición única definida por:
/// - Bay (Bahía)
/// - Row (Fila)  
/// - Tier (Nivel/Altura)
class ContainerSlot extends Equatable {
  /// Número de fila (00-99)
  final int row;
  
  /// Número de nivel/altura (00-99)
  final int tier;
  
  /// Número de bahía al que pertenece
  final int bayNumber;
  
  /// Contenedor ocupando este slot (null si vacío)
  final ContainerUnit? container;
  
  /// Indica si el slot está bloqueado/no disponible
  final bool isBlocked;
  
  /// Razón del bloqueo si aplica
  final String? blockReason;
  
  /// Capacidad de peso máximo del slot en kg
  final double? maxWeight;
  
  /// Restricciones especiales del slot
  final List<SlotRestriction> restrictions;

  const ContainerSlot({
    required this.row,
    required this.tier,
    required this.bayNumber,
    this.container,
    this.isBlocked = false,
    this.blockReason,
    this.maxWeight,
    this.restrictions = const [],
  });

  /// Indica si el slot está ocupado
  bool get isOccupied => container != null;

  /// Indica si el slot está disponible (no ocupado y no bloqueado)
  bool get isAvailable => !isOccupied && !isBlocked;

  /// Row con padding de 2 dígitos
  String get rowPadded => row.toString().padLeft(2, '0');

  /// Tier con padding de 2 dígitos
  String get tierPadded => tier.toString().padLeft(2, '0');

  /// Bay con padding de 3 dígitos
  String get bayPadded => bayNumber.toString().padLeft(3, '0');

  /// Coordenada completa en formato BBBRRTT
  String get fullCoordinate => '$bayPadded$rowPadded$tierPadded';

  /// Coordenada corta Row-Tier
  String get shortCoordinate => '$rowPadded$tierPadded';

  /// Formato de display "Bay XX, Row YY, Tier ZZ"
  String get displayFormat => 'Bay $bayPadded, Row $rowPadded, Tier $tierPadded';

  /// Indica si es un tier de cubierta (generalmente >= 80)
  bool get isDeckTier => tier >= 80;

  /// Indica si es un tier de bodega (generalmente < 80)
  bool get isHoldTier => tier < 80;

  /// Verifica si puede aceptar un contenedor específico
  bool canAccept(ContainerUnit containerToPlace) {
    if (isOccupied || isBlocked) return false;
    
    // Verificar peso máximo
    if (maxWeight != null && 
        containerToPlace.grossWeight != null &&
        containerToPlace.grossWeight! > maxWeight!) {
      return false;
    }
    
    // Verificar restricciones
    for (final restriction in restrictions) {
      if (restriction == SlotRestriction.noReefer && containerToPlace.isReefer) {
        return false;
      }
      if (restriction == SlotRestriction.noDangerous && containerToPlace.isDangerous) {
        return false;
      }
      if (restriction == SlotRestriction.noHighCube && 
          containerToPlace.height == ContainerHeight.highCube) {
        return false;
      }
    }
    
    return true;
  }

  @override
  List<Object?> get props => [
        row,
        tier,
        bayNumber,
        container,
        isBlocked,
        blockReason,
        maxWeight,
        restrictions,
      ];

  ContainerSlot copyWith({
    int? row,
    int? tier,
    int? bayNumber,
    ContainerUnit? container,
    bool? isBlocked,
    String? blockReason,
    double? maxWeight,
    List<SlotRestriction>? restrictions,
  }) {
    return ContainerSlot(
      row: row ?? this.row,
      tier: tier ?? this.tier,
      bayNumber: bayNumber ?? this.bayNumber,
      container: container ?? this.container,
      isBlocked: isBlocked ?? this.isBlocked,
      blockReason: blockReason ?? this.blockReason,
      maxWeight: maxWeight ?? this.maxWeight,
      restrictions: restrictions ?? this.restrictions,
    );
  }

  /// Limpia el contenedor del slot
  ContainerSlot clearContainer() => copyWith(container: null);

  /// Asigna un contenedor al slot
  ContainerSlot assignContainer(ContainerUnit newContainer) =>
      copyWith(container: newContainer);

  Map<String, dynamic> toJson() => {
        'row': row,
        'tier': tier,
        'bayNumber': bayNumber,
        if (container != null) 'container': container!.toJson(),
        'isBlocked': isBlocked,
        if (blockReason != null) 'blockReason': blockReason,
        if (maxWeight != null) 'maxWeight': maxWeight,
        'restrictions': restrictions.map((r) => r.name).toList(),
      };

  factory ContainerSlot.fromJson(Map<String, dynamic> json) => ContainerSlot(
        row: json['row'] as int,
        tier: json['tier'] as int,
        bayNumber: json['bayNumber'] as int,
        container: json['container'] != null
            ? ContainerUnit.fromJson(json['container'] as Map<String, dynamic>)
            : null,
        isBlocked: json['isBlocked'] as bool? ?? false,
        blockReason: json['blockReason'] as String?,
        maxWeight: (json['maxWeight'] as num?)?.toDouble(),
        restrictions: (json['restrictions'] as List<dynamic>?)
                ?.map((e) => SlotRestriction.values.firstWhere(
                      (r) => r.name == e,
                      orElse: () => SlotRestriction.none,
                    ))
                .where((r) => r != SlotRestriction.none)
                .toList() ??
            [],
      );

  @override
  String toString() =>
      'ContainerSlot($fullCoordinate, ${isOccupied ? 'occupied' : 'empty'})';
}

/// Restricciones de un slot
enum SlotRestriction {
  none,         // Sin restricción
  noReefer,     // No permite refrigerados
  noDangerous,  // No permite peligrosos
  noHighCube,   // No permite High Cube
  noHeavy,      // No permite pesados
  reeferOnly,   // Solo refrigerados
  emptyOnly,    // Solo contenedores vacíos
}
