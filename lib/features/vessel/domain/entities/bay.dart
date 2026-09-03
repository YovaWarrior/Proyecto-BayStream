import 'package:equatable/equatable.dart';
import 'container_slot.dart';
import 'container_unit.dart';
import 'vessel_geometry.dart';

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
  
  /// PROVISIONAL — supuesto histórico de capacidad, hoy sin uso en el cálculo.
  ///
  /// El parser nunca asignó estos dos valores, así que la ocupación se
  /// calculaba contra 120 huecos ficticios. Desde C-3 la capacidad viene de
  /// [geometry], que el usuario declara. Se conservan porque los documentos
  /// de Firestore ya escritos los traen; se retiran cuando C-2, C-4 y C-5
  /// hayan aterrizado, no antes.
  final int maxRows;

  /// PROVISIONAL — ver [maxRows].
  final int maxTiers;

  /// Indica si es bahía de cubierta (deck) o bodega (hold)
  final BayLocation location;

  /// Geometría declarada del buque, inyectada por `VesselVoyage`.
  ///
  /// **No se serializa aquí a propósito.** La geometría es del buque, no de
  /// cada bahía: guardarla en las 27 bahías la duplicaría 27 veces en el
  /// documento de Firestore y permitiría que dos bahías del mismo buque
  /// declararan geometrías distintas, que no significa nada. Vive una sola vez
  /// en `VesselVoyage.geometry`, y `VesselVoyage.fromJson` la reinyecta aquí
  /// al reconstruir cada bahía.
  final VesselGeometry? geometry;

  const Bay({
    required this.bayNumber,
    this.is40FtBay = false,
    this.slots = const {},
    this.containers = const [],
    this.maxRows = 12,
    this.maxTiers = 10,
    this.location = BayLocation.unknown,
    this.geometry,
  });

  /// Número de bahía con padding de 3 dígitos
  String get bayNumberPadded => bayNumber.toString().padLeft(3, '0');

  /// Total de slots ocupados
  int get occupiedSlots => slots.values.where((s) => s.isOccupied).length;

  /// Total de slots vacíos
  int get emptySlots => slots.values.where((s) => !s.isOccupied).length;

  /// Porcentaje de ocupación contra la geometría declarada del buque.
  ///
  /// Devuelve `null` cuando la bahía tiene carga y no hay geometría declarada:
  /// sin capacidad declarada no existe un porcentaje que calcular, y un número
  /// de respaldo aquí sería exactamente el defecto que C-3 corrige, reaparecido
  /// en silencio. Quien lo muestre debe rotular ese caso, no rellenarlo.
  ///
  /// Una bahía vacía sí devuelve 0: cero contenedores son cero por ciento
  /// contra cualquier capacidad, y eso se sabe sin declarar nada.
  double? get occupancyRate {
    if (containers.isEmpty) return 0.0;
    final totalCapacity = geometry?.slotsPerBay;
    if (totalCapacity == null || totalCapacity == 0) return null;
    return (containers.length / totalCapacity) * 100;
  }

  /// Peso total de contenedores en esta bahía
  double get totalWeight =>
      containers.fold(0.0, (sum, c) => sum + (c.grossWeight ?? 0));

  /// Peso bruto acumulado por nivel (tier), en kilogramos.
  /// Clave: número de nivel. Valor: suma de grossWeight de los contenedores de ese nivel.
  Map<int, double> get weightByTier {
    final weights = <int, double>{};
    for (final container in containers) {
      final tier = container.stowagePosition?.tier;
      if (tier == null) continue;
      weights.update(
        tier,
        (weight) => weight + (container.grossWeight ?? 0),
        ifAbsent: () => container.grossWeight ?? 0,
      );
    }
    return weights;
  }

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
        geometry,
      ];

  Bay copyWith({
    int? bayNumber,
    bool? is40FtBay,
    Map<String, ContainerSlot>? slots,
    List<ContainerUnit>? containers,
    int? maxRows,
    int? maxTiers,
    BayLocation? location,
    VesselGeometry? geometry,
  }) {
    return Bay(
      bayNumber: bayNumber ?? this.bayNumber,
      is40FtBay: is40FtBay ?? this.is40FtBay,
      slots: slots ?? this.slots,
      containers: containers ?? this.containers,
      maxRows: maxRows ?? this.maxRows,
      maxTiers: maxTiers ?? this.maxTiers,
      location: location ?? this.location,
      geometry: geometry ?? this.geometry,
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

  /// La geometría no se incluye a propósito: ver [geometry].
  Map<String, dynamic> toJson() => {
        'bayNumber': bayNumber,
        'is40FtBay': is40FtBay,
        'slots': slots.map((k, v) => MapEntry(k, v.toJson())),
        'containers': containers.map((c) => c.toJson()).toList(),
        'maxRows': maxRows,
        'maxTiers': maxTiers,
        'location': location.name,
      };

  /// [geometry] la aporta `VesselVoyage.fromJson`, que la lee una sola vez del
  /// documento y la reinyecta en cada bahía.
  factory Bay.fromJson(
    Map<String, dynamic> json, {
    VesselGeometry? geometry,
  }) =>
      Bay(
        geometry: geometry,
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
  String toString() => 'Bay($bayNumberPadded, containers: ${containers.length}, '
      'occupancy: ${occupancyRate?.toStringAsFixed(1) ?? 'sin geometria'}%)';
}

/// Ubicación de la bahía en el buque
enum BayLocation {
  deck,    // Cubierta (sobre la línea de cubierta)
  hold,    // Bodega (bajo la línea de cubierta)
  unknown,
}
