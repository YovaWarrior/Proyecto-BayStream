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

  /// Slots que ocupa físicamente un contenedor de 40 o 45 pies estibado en una
  /// bahía par vecina. Clave `"RRTT"`, como [slots].
  ///
  /// Un contenedor de 40 pies estibado en la bahía par `B` ocupa los slots de
  /// las impares `B-1` y `B+1`, así que pares e impares no son independientes.
  /// La regla es absoluta en el corpus: de 977 contenedores de `CORPUS_A01`,
  /// los 128 de 20 pies están en bahías impares y los 849 de 40 y 45 en pares,
  /// **sin una sola excepción**. Igual en `CORPUS_A05`.
  ///
  /// **No se serializa aquí**, por lo mismo que [geometry]: es dato derivado de
  /// los contenedores del viaje, y `VesselVoyage` lo recalcula e inyecta.
  final Set<String> slotsOccupiedByNeighbors;

  const Bay({
    required this.bayNumber,
    this.is40FtBay = false,
    this.slots = const {},
    this.containers = const [],
    this.maxRows = 12,
    this.maxTiers = 10,
    this.location = BayLocation.unknown,
    this.geometry,
    this.slotsOccupiedByNeighbors = const {},
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
    if (containers.isEmpty && slotsOccupiedByNeighbors.isEmpty) return 0.0;
    final totalCapacity = geometry?.slotsPerBay;
    if (totalCapacity == null || totalCapacity == 0) return null;
    return (occupiedSlotKeys.length / totalCapacity) * 100;
  }

  /// Slots físicamente ocupados: los de los contenedores propios más los que
  /// toma un contenedor de 40 pies de una bahía vecina.
  ///
  /// Se cuenta la unión y no la suma: un slot tomado dos veces sigue siendo un
  /// slot, y sumar inflaría la ocupación de la bahía.
  Set<String> get occupiedSlotKeys {
    final keys = <String>{...slotsOccupiedByNeighbors};
    for (final container in containers) {
      final position = container.stowagePosition;
      if (position == null) continue;
      keys.add('${position.rowPadded}${position.tierPadded}');
    }
    return keys;
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

  /// Peso bruto acumulado por fila en cubierta, en kilogramos.
  ///
  /// Una **pila** es la columna vertical de contenedores de una fila, y es la
  /// magnitud a la que aplica el límite de apilamiento. No es lo mismo que
  /// [weightByTier], que suma horizontalmente todas las filas de un nivel: en
  /// la bahía 22 de `CORPUS_A01` el peso por nivel supera las 90 toneladas en
  /// seis de once niveles, y una alerta que salta más de la mitad de las veces
  /// no informa nada.
  ///
  /// Cubierta y bodega van separadas porque son pilas físicamente distintas:
  /// entre ellas está la tapa de escotilla. La de bodega apoya en el doble
  /// fondo y la de cubierta sobre la tapa, así que sus pesos no se suman.
  Map<int, double> get deckWeightByRow =>
      _weightByRow((tier) => tier >= VesselGeometry.firstDeckTier);

  /// Peso bruto acumulado por fila en bodega, en kilogramos.
  /// Ver [deckWeightByRow].
  Map<int, double> get holdWeightByRow =>
      _weightByRow((tier) => tier < VesselGeometry.firstDeckTier);

  Map<int, double> _weightByRow(bool Function(int tier) enZona) {
    final weights = <int, double>{};
    for (final container in containers) {
      final position = container.stowagePosition;
      if (position == null || !enZona(position.tier)) continue;
      weights.update(
        position.row,
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
        slotsOccupiedByNeighbors,
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
    Set<String>? slotsOccupiedByNeighbors,
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
      slotsOccupiedByNeighbors:
          slotsOccupiedByNeighbors ?? this.slotsOccupiedByNeighbors,
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

  /// La geometría y los slots de las vecinas no se incluyen a propósito: son
  /// datos derivados que `VesselVoyage` recalcula. Ver [geometry].
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
