import 'package:equatable/equatable.dart';
import '../../../../core/utils/iso_coordinate_parser.dart';
import 'vessel.dart';
import 'container_unit.dart';
import 'bay.dart';
import 'vessel_geometry.dart';

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
  
  /// Puerto de salida declarado en la cabecera del archivo (`LOC+5`).
  ///
  /// El mismo plano puede utilizarse en la salida o en la llegada siguiente.
  final String? portOfOrigin;

  /// Próximo puerto declarado en la cabecera (`LOC+61`), si es un UN/LOCODE.
  /// Es opcional para conservar la lectura de los viajes guardados anteriores.
  final String? portOfNextCall;
  
  /// Puerto de destino
  final String? portOfDestination;
  
  /// Fecha de creación del archivo BAPLIE
  final DateTime? messageDate;
  
  /// Lista de todos los contenedores en el buque
  final List<ContainerUnit> containers;
  
  /// Mapa de bahías organizadas por número.
  ///
  /// **Cambio de contrato.** Antes contenía solo las bahías con carga propia
  /// de este viaje, porque el parser crea una bahía por cada contenedor. Desde
  /// la extensión posterior a C-7 contiene **toda bahía con evidencia física
  /// de ocupación**: la propia y también la que está tomada por contenedores
  /// de 40 pies de una bahía par vecina, aunque no traiga ni un contenedor de
  /// este viaje.
  ///
  /// El motivo: sin eso, siete bahías impares de `CORPUS_A01` no aparecían en
  /// el plano estando físicamente ocupadas. La 013 tiene 92 de sus 156 huecos
  /// tomados —un 59 %— y el planificador no podía verla.
  ///
  /// La extensión la hace [withGeometry], no el parser: depende de la
  /// geometría declarada tanto como el resto del plano. Recién parseado, el
  /// mapa sigue teniendo solo las bahías con carga propia.
  final Map<int, Bay> bays;
  
  /// Metadatos adicionales del mensaje BAPLIE
  final BaplieMetadata? metadata;

  /// Geometría del buque declarada por el usuario.
  ///
  /// Fuente única: se guarda una sola vez aquí y `Bay` la recibe inyectada.
  /// Es `null` mientras el viaje está pendiente de confirmación, y en los
  /// documentos escritos antes de C-3. En ambos casos la ocupación se rotula
  /// como no calculable en vez de mostrar un número de respaldo.
  final VesselGeometry? geometry;

  /// Puerto de esta escala, confirmado por el usuario.
  ///
  /// Separa la carga que se opera aquí de la que ya venía a bordo. Se propone
  /// desde [portOfOrigin] —el `LOC+5` de la cabecera— y se sigue confirmando:
  /// el archivo declara para qué salida se emitió el plano, no dónde está el
  /// buque el día que alguien lo abre.
  final String? portOfCall;

  /// Perfil elegido al confirmar identidad, incluso si se resolvió un homónimo.
  /// Opcional para leer los registros anteriores a viajes recientes.
  final String? vesselProfileKey;

  const VesselVoyage({
    required this.id,
    required this.vessel,
    required this.voyageNumber,
    this.direction = VoyageDirection.unknown,
    this.portOfOrigin,
    this.portOfNextCall,
    this.portOfDestination,
    this.messageDate,
    this.containers = const [],
    this.bays = const {},
    this.metadata,
    this.geometry,
    this.portOfCall,
    this.vesselProfileKey,
  });

  /// Total de contenedores en el buque
  int get totalContainers => containers.length;
  
  /// Contenedores llenos
  int get fullContainers => 
      containers.where((c) => c.status == ContainerStatus.full).length;
  
  /// Contenedores vacíos
  int get emptyContainers => 
      containers.where((c) => c.status == ContainerStatus.empty).length;
  
  /// Peso total del viaje (en kg): suma del peso efectivo de cada contenedor,
  /// el VGM si viene y, si no, el bruto (T-66). Es el que se muestra.
  double get totalWeight =>
      containers.fold(0.0, (sum, c) => sum + (c.effectiveWeight ?? 0));

  /// Suma cruda de `MEA+WT` de todos los contenedores (en kg).
  /// No es el peso del viaje: un contenedor que solo trae VGM suma 0 aquí.
  double get totalGrossWeight =>
      containers.fold(0.0, (sum, c) => sum + (c.grossWeight ?? 0));
  
  /// Suma cruda de `MEA+VGM` de todos los contenedores (en kg)
  double get totalVgmWeight =>
      containers.fold(0.0, (sum, c) => sum + (c.vgmWeight ?? 0));

  /// Obtiene contenedores en una bahía específica
  List<ContainerUnit> getContainersInBay(int bayNumber) =>
      containers.where((c) => c.stowagePosition?.bay == bayNumber).toList();

  /// Devuelve el viaje con la geometría confirmada y propagada a cada bahía.
  ///
  /// Es la única transformación que asigna geometría. Mantiene el invariante
  /// de que un viaje publicado siempre trae geometría, en el buque y en todas
  /// sus bahías a la vez.
  /// También recalcula qué slots de cada bahía impar toma un contenedor de 40
  /// pies de una bahía par vecina: es dato derivado de los contenedores, así
  /// que se computa aquí, una sola vez, y se inyecta.
  VesselVoyage withGeometry(VesselGeometry geometry, {String? portOfCall}) {
    final shadows = neighborOccupiedSlots();
    final updated = <int, Bay>{};

    for (final entry in bays.entries) {
      updated[entry.key] = entry.value.copyWith(
        geometry: geometry,
        slotsOccupiedByNeighbors: shadows[entry.key] ?? const {},
      );
    }

    // Bahías sin carga propia pero físicamente ocupadas por un contenedor de
    // 40 pies de una vecina. Sin esto quedan invisibles aunque estén tomadas,
    // que es lo que le pasa a siete bahías impares de CORPUS_A01. Ver [bays].
    for (final entry in shadows.entries) {
      if (updated.containsKey(entry.key)) continue;
      updated[entry.key] = Bay(
        bayNumber: entry.key,
        is40FtBay: entry.key.isEven,
        geometry: geometry,
        slotsOccupiedByNeighbors: entry.value,
      );
    }

    return copyWith(
      geometry: geometry,
      portOfCall: portOfCall,
      bays: updated,
    );
  }

  /// Slots que los contenedores de 40 y 45 pies de las bahías pares ocupan en
  /// las impares vecinas, por número de bahía. Clave `"RRTT"`.
  ///
  /// Un contenedor de 40 pies estibado en la bahía par `B` ocupa físicamente
  /// los slots de `B-1` y `B+1`. El resultado incluye bahías impares que no
  /// existen en [bays]: quien lo consuma decide qué hacer con ellas.
  ///
  /// No se da por hecho que la vecina exista, ni en un sentido ni en el otro:
  /// en `CORPUS_A01` la bahía 41 tiene carga y ninguna par vecina cargada.
  Map<int, Set<String>> neighborOccupiedSlots() {
    final shadows = <int, Set<String>>{};
    for (final container in containers) {
      final position = container.stowagePosition;
      if (position == null) continue;
      if (position.bay.isOdd) continue;
      final size = container.sizeInFeet;
      if (size == null || size < 40) continue;

      final key = '${position.rowPadded}${position.tierPadded}';
      for (final neighbor in [position.bay - 1, position.bay + 1]) {
        if (neighbor < 1) continue;
        shadows.putIfAbsent(neighbor, () => <String>{}).add(key);
      }
    }
    return shadows;
  }

  /// Posiciones de estiba ocupadas en este viaje, para deducir la geometría.
  Iterable<IsoCoordinate> get stowagePositions =>
      containers.map((c) => c.stowagePosition).whereType<IsoCoordinate>();

  /// Puertos de carga del archivo (`LOC+9`) con su conteo, del más frecuente
  /// al menos frecuente.
  ///
  /// Sobre `CORPUS_A01`: HNPCR 457, GTPBR 325, PAMIT 195.
  Map<String, int> get loadingPortCounts {
    final counts = <String, int>{};
    for (final container in containers) {
      final port = container.portOfLoading;
      if (port == null || port.isEmpty) continue;
      counts[port] = (counts[port] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted);
  }

  /// Puerto de escala propuesto: el `LOC+5` de la cabecera, y si falta, el
  /// `LOC+9` más frecuente.
  ///
  /// El orden importa y no es un detalle. El `LOC+5` es una **declaración del
  /// archivo**: el puerto de salida para el que se emitió el plano, presente
  /// una vez por mensaje en los siete archivos del corpus. El `LOC+9` más
  /// frecuente es una **apuesta**: el archivo dice dónde se cargó cada caja,
  /// no en qué escala está el buque, y las dos cosas no coinciden. En
  /// `CORPUS_A01` el `LOC+5` dice GTPBR mientras que el `LOC+9` más repetido
  /// es HNPCR con 457 de 977 — contar habría propuesto el puerto equivocado.
  ///
  /// El respaldo se queda porque el estándar no obliga al `LOC+5`, y porque un
  /// archivo sin él sigue teniendo que poder abrirse. Con o sin declaración,
  /// el usuario confirma.
  String? get proposedPortOfCall {
    final declared = portOfOrigin;
    if (declared != null && declared.isNotEmpty) return declared;
    return loadingPortCounts.keys.isEmpty ? null : loadingPortCounts.keys.first;
  }

  /// El historial del dispositivo solo propone una de las dos escalas del
  /// mensaje. Un puerto ajeno o un archivo sin LOC+61 conserva la propuesta.
  String? suggestPortOfCall(String? lastConfirmedPort) {
    if (portOfNextCall != null && lastConfirmedPort != null &&
        (lastConfirmedPort == portOfOrigin ||
            lastConfirmedPort == portOfNextCall)) {
      return lastConfirmedPort;
    }
    return proposedPortOfCall;
  }

  /// Conteos independientes: carga y descarga se reconocen por sus LOC+9/11.
  ({int loaded, int discharged, int transit}) cargoCountsFor(String? port) => (
    loaded: port == null ? 0 : containers.where((c) => c.portOfLoading == port).length,
    discharged: port == null ? 0 : containers.where((c) => c.portOfDischarge == port).length,
    transit: port == null ? 0 : containers.where((c) =>
        c.portOfLoading != null && c.portOfLoading != port &&
        c.portOfDischarge != port).length,
  );

  /// Indica si el contenedor ya venía a bordo y no se opera en esta escala.
  ///
  /// Es lo que el planificador tacha a mano en el plano impreso. Sin puerto de
  /// escala declarado no hay nada que distinguir, y un contenedor sin puerto de
  /// carga no se marca: no saber no es lo mismo que ir de paso.
  bool isInTransit(ContainerUnit container) =>
      portOfCall != null &&
      container.portOfLoading != null &&
      container.portOfLoading != portOfCall &&
      container.portOfDischarge != portOfCall;

  /// Contenedores que se operan en esta escala.
  int get containersAtCall =>
      portOfCall == null ? 0 : containers.where((c) => !isInTransit(c)).length;

  /// Contenedores que van de paso.
  int get containersInTransit => containers.where(isInTransit).length;

  @override
  List<Object?> get props => [
        id,
        vessel,
        voyageNumber,
        direction,
        portOfOrigin,
        portOfNextCall,
        portOfDestination,
        messageDate,
        containers,
        bays,
        metadata,
        geometry,
        portOfCall,
        vesselProfileKey,
      ];

  VesselVoyage copyWith({
    String? id,
    Vessel? vessel,
    String? voyageNumber,
    VoyageDirection? direction,
    String? portOfOrigin,
    String? portOfNextCall,
    String? portOfDestination,
    DateTime? messageDate,
    List<ContainerUnit>? containers,
    Map<int, Bay>? bays,
    BaplieMetadata? metadata,
    VesselGeometry? geometry,
    String? portOfCall,
    bool clearPortOfCall = false,
    String? vesselProfileKey,
  }) {
    return VesselVoyage(
      id: id ?? this.id,
      vessel: vessel ?? this.vessel,
      voyageNumber: voyageNumber ?? this.voyageNumber,
      direction: direction ?? this.direction,
      portOfOrigin: portOfOrigin ?? this.portOfOrigin,
      portOfNextCall: portOfNextCall ?? this.portOfNextCall,
      portOfDestination: portOfDestination ?? this.portOfDestination,
      messageDate: messageDate ?? this.messageDate,
      containers: containers ?? this.containers,
      bays: bays ?? this.bays,
      metadata: metadata ?? this.metadata,
      geometry: geometry ?? this.geometry,
      portOfCall: clearPortOfCall ? null : portOfCall ?? this.portOfCall,
      vesselProfileKey: vesselProfileKey ?? this.vesselProfileKey,
    );
  }

  /// Por defecto conserva el documento histórico de exportación y Firestore.
  /// El almacén local omite las bahías, reconstruibles desde [containers].
  Map<String, dynamic> toJson({bool includeBays = true}) => {
        'id': id,
        'vessel': vessel.toJson(),
        'voyageNumber': voyageNumber,
        'direction': direction.name,
        if (portOfOrigin != null) 'portOfOrigin': portOfOrigin,
        if (portOfNextCall != null) 'portOfNextCall': portOfNextCall,
        if (portOfDestination != null) 'portOfDestination': portOfDestination,
        if (messageDate != null) 'messageDate': messageDate!.toIso8601String(),
        'containers': containers.map((c) => c.toJson()).toList(),
        if (includeBays)
          'bays': bays.map((k, v) => MapEntry(k.toString(), v.toJson())),
        if (metadata != null) 'metadata': metadata!.toJson(),
        // Una sola vez para todo el buque: las bahias no la serializan.
        if (geometry != null) 'geometry': geometry!.toJson(),
        if (portOfCall != null) 'portOfCall': portOfCall,
        if (vesselProfileKey != null) 'vesselProfileKey': vesselProfileKey,
      };

  factory VesselVoyage.fromJson(Map<String, dynamic> json) {
    // Se lee antes que las bahias porque cada una la recibe inyectada.
    final geometry = json['geometry'] != null
        ? VesselGeometry.fromJson(json['geometry'] as Map<String, dynamic>)
        : null;

    final containers = (json['containers'] as List<dynamic>?)
            ?.map((e) => ContainerUnit.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    // El esquema local no guarda bahías ni celdas duplicadas. Los documentos
    // históricos sí: se conservan sus atributos y solo se restauran vecinos.
    final storedBays = json['bays'] as Map<String, dynamic>?;
    final bays = storedBays?.map(
          (k, v) => MapEntry(
            int.parse(k),
            Bay.fromJson(v as Map<String, dynamic>, geometry: geometry),
          ),
        ) ??
        _baysFromContainers(containers, geometry);
    final voyage = VesselVoyage(
        geometry: geometry,
        portOfCall: json['portOfCall'] as String?,
        vesselProfileKey: json['vesselProfileKey'] as String?,
        id: json['id'] as String,
        vessel: Vessel.fromJson(json['vessel'] as Map<String, dynamic>),
        voyageNumber: json['voyageNumber'] as String,
        direction: VoyageDirection.values.firstWhere(
          (e) => e.name == json['direction'],
          orElse: () => VoyageDirection.unknown,
        ),
        portOfOrigin: json['portOfOrigin'] as String?,
        portOfNextCall: json['portOfNextCall'] as String?,
        portOfDestination: json['portOfDestination'] as String?,
        messageDate: json['messageDate'] != null
            ? DateTime.parse(json['messageDate'] as String)
            : null,
        containers: containers,
        bays: bays,
        metadata: json['metadata'] != null
            ? BaplieMetadata.fromJson(json['metadata'] as Map<String, dynamic>)
            : null,
    );
    // También se reconstruyen sin geometría: la ocupación queda no calculable,
    // pero nunca se pierde la evidencia física ni se muestra un cero falso.
    final shadows = voyage.neighborOccupiedSlots();
    return voyage.copyWith(bays: {
      for (final entry in bays.entries)
        entry.key: entry.value.copyWith(
          slotsOccupiedByNeighbors: shadows[entry.key] ?? const {},
        ),
      for (final entry in shadows.entries)
        if (!bays.containsKey(entry.key))
          entry.key: Bay(
            bayNumber: entry.key,
            is40FtBay: entry.key.isEven,
            geometry: geometry,
            slotsOccupiedByNeighbors: entry.value,
          ),
    });
  }

  static Map<int, Bay> _baysFromContainers(
    List<ContainerUnit> containers,
    VesselGeometry? geometry,
  ) {
    final bays = <int, Bay>{};
    for (final container in containers) {
      final position = container.stowagePosition;
      if (position == null) continue;
      final bay = bays.putIfAbsent(position.bay, () => Bay(
        bayNumber: position.bay,
        is40FtBay: position.bay.isEven,
        geometry: geometry,
      ));
      bays[position.bay] = bay.addContainer(container);
    }
    return bays;
  }

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
