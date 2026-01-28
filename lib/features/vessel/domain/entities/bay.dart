import 'package:equatable/equatable.dart';
import 'container_slot.dart';
import 'container_unit.dart';

/// Entidad que representa una bahía (Bay) del buque
/// 
/// Una bahía es una sección transversal del buque donde se estiban contenedores.
/// Cada bahía tiene múltiples posiciones definidas por Row (fila) y Tier (nivel).
class Bay extends Equatable {
  /// Número de bahía (001-999)
  final int bayNumber;
  
  /// Indica si es una bahía de 40 pies (ocupa 2 bahías de 20)
  final bool is40FtBay;
  
  /// Mapa de slots/celdas en esta bahía
  /// Clave: "RRTT" (Row + Tier)
  final Map<String, ContainerSlot> slots;
  
  /// Lista de contenedores en esta bahía
  final List<ContainerUnit> containers;
  
  /// Número máximo de filas en esta bahía
  final int maxRows;
  
  /// Número máximo de niveles (tiers) en esta bahía
  final int maxTiers;
  
  /// Indica si es bahía de cubierta (deck) o bodega (hold)
  final BayLocation location;

  const Bay({
    required this.bayNumber,
    this.is40FtBay = false,
    this.slots = const {},
    this.containers = const [],
    this.maxRows = 12,
    this.maxTiers = 10,
    this.location = BayLocation.unknown,
  });

  /// Número de bahía con padding de 3 dígitos
  String get bayNumberPadded => bayNumber.toString().padLeft(3, '0');

  /// Total de slots ocupados
  int get occupiedSlots => slots.values.where((s) => s.isOccupied).length;

  /// Total de slots vacíos
  int get emptySlots => slots.values.where((s) => !s.isOccupied).length;

  /// Porcentaje de ocupación
  double get occupancyRate {
    if (slots.isEmpty) return 0.0;
    return (occupiedSlots / slots.length) * 100;
  }

  /// Peso total de contenedores en esta bahía
  double get totalWeight =>
      containers.fold(0.0, (sum, c) => sum + (c.grossWeight ?? 0));

  /// Obtiene un slot específico por coordenadas Row-Tier
  ContainerSlot? getSlot(int row, int tier) {
    final key = '${row.toString().padLeft(2, '0')}${tier.toString().padLeft(2, '0')}';
    return slots[key];
  }

  /// Obtiene el contenedor en una posición específica
  ContainerUnit? getContainerAt(int row, int tier) {
    return containers.firstWhere(
      (c) => c.stowagePosition?.row == row && c.stowagePosition?.tier == tier,
      orElse: () => throw StateError('No container at position'),
    );
  }

  /// Verifica si hay un contenedor en la posición
  bool hasContainerAt(int row, int tier) {
    return containers.any(
      (c) => c.stowagePosition?.row == row && c.stowagePosition?.tier == tier,
    );
  }

  @override
  List<Object?> get props => [
        bayNumber,
        is40FtBay,
        slots,
        containers,
        maxRows,
        maxTiers,
        location,
      ];

  Bay copyWith({
    int? bayNumber,
    bool? is40FtBay,
    Map<String, ContainerSlot>? slots,
    List<ContainerUnit>? containers,
    int? maxRows,
    int? maxTiers,
    BayLocation? location,
  }) {
    return Bay(
      bayNumber: bayNumber ?? this.bayNumber,
      is40FtBay: is40FtBay ?? this.is40FtBay,
      slots: slots ?? this.slots,
      containers: containers ?? this.containers,
      maxRows: maxRows ?? this.maxRows,
      maxTiers: maxTiers ?? this.maxTiers,
      location: location ?? this.location,
    );
  }

  /// Añade un contenedor a la bahía
  Bay addContainer(ContainerUnit container) {
    final updatedContainers = List<ContainerUnit>.from(containers)..add(container);
    
    // Actualizar o crear el slot correspondiente
    final position = container.stowagePosition;
    if (position != null) {
      final slotKey = '${position.rowPadded}${position.tierPadded}';
      final updatedSlots = Map<String, ContainerSlot>.from(slots);
      
      updatedSlots[slotKey] = ContainerSlot(
        row: position.row,
        tier: position.tier,
        bayNumber: bayNumber,
        container: container,
      );
      
      return copyWith(containers: updatedContainers, slots: updatedSlots);
    }
    
    return copyWith(containers: updatedContainers);
  }

  Map<String, dynamic> toJson() => {
        'bayNumber': bayNumber,
        'is40FtBay': is40FtBay,
        'slots': slots.map((k, v) => MapEntry(k, v.toJson())),
        'containers': containers.map((c) => c.toJson()).toList(),
        'maxRows': maxRows,
        'maxTiers': maxTiers,
        'location': location.name,
      };

  factory Bay.fromJson(Map<String, dynamic> json) => Bay(
        bayNumber: json['bayNumber'] as int,
        is40FtBay: json['is40FtBay'] as bool? ?? false,
        slots: (json['slots'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, ContainerSlot.fromJson(v as Map<String, dynamic>)),
            ) ??
            {},
        containers: (json['containers'] as List<dynamic>?)
                ?.map((e) => ContainerUnit.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        maxRows: json['maxRows'] as int? ?? 12,
        maxTiers: json['maxTiers'] as int? ?? 10,
        location: BayLocation.values.firstWhere(
          (e) => e.name == json['location'],
          orElse: () => BayLocation.unknown,
        ),
      );

  @override
  String toString() =>
      'Bay($bayNumberPadded, containers: ${containers.length}, occupancy: ${occupancyRate.toStringAsFixed(1)}%)';
}

/// Ubicación de la bahía en el buque
enum BayLocation {
  deck,    // Cubierta (sobre la línea de cubierta)
  hold,    // Bodega (bajo la línea de cubierta)
  unknown,
}
