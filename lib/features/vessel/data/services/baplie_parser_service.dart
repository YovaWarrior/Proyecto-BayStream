import 'package:uuid/uuid.dart';
import '../../../../core/constants/baplie_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/iso_coordinate_parser.dart';
import '../../domain/entities/entities.dart';

/// Servicio para parsear archivos BAPLIE 2.2.1 (EDIFACT)
/// 
/// Implementa el parsing según el estándar SMDG BAPLIE 2.2.1:
/// - Separador de segmentos: `'` (comilla simple)
/// - Separador de elementos: `+`
/// - Separador de componentes: `:`
class BaplieParserService {
  final Uuid _uuid = const Uuid();

  /// Parsea un string completo de archivo BAPLIE/EDI
  /// 
  /// Retorna un [VesselVoyage] con toda la información del buque y contenedores.
  /// Lanza [BaplieParsingException] si el formato es inválido.
  VesselVoyage parse(String ediContent) {
    if (ediContent.trim().isEmpty) {
      throw const BaplieParsingException(
        message: 'El contenido del archivo BAPLIE está vacío',
      );
    }

    // Normalizar saltos de línea y separar segmentos
    final normalizedContent = _normalizeContent(ediContent);
    final segments = _splitSegments(normalizedContent);

    if (segments.isEmpty) {
      throw const BaplieParsingException(
        message: 'No se encontraron segmentos válidos en el archivo',
      );
    }

    // Extraer información del buque (TDT)
    final vesselInfo = _parseVesselInfo(segments);
    
    // Extraer metadatos del mensaje
    final metadata = _parseMetadata(segments);
    
    // Extraer contenedores (grupos LOC+147 -> EQD -> MEA)
    final containers = _parseContainers(segments);
    
    // Organizar contenedores por bahías
    final bays = _organizeBays(containers);

    return VesselVoyage(
      id: _uuid.v4(),
      vessel: vesselInfo.vessel,
      voyageNumber: vesselInfo.voyageNumber,
      direction: _determineDirection(segments),
      containers: containers,
      bays: bays,
      metadata: metadata,
    );
  }

  /// Normaliza el contenido removiendo saltos de línea innecesarios
  String _normalizeContent(String content) {
    return content
        .replaceAll('\r\n', '')
        .replaceAll('\r', '')
        .replaceAll('\n', '')
        .trim();
  }

  /// Divide el contenido en segmentos usando el separador `'`
  List<String> _splitSegments(String content) {
    return content
        .split(BaplieConstants.segmentSeparator)
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// Extrae los elementos de un segmento (separados por `+`)
  List<String> _getElements(String segment) {
    return segment.split(BaplieConstants.elementSeparator);
  }

  /// Extrae los componentes de un elemento (separados por `:`)
  List<String> _getComponents(String element) {
    return element.split(BaplieConstants.componentSeparator);
  }

  /// Obtiene un componente de forma segura por índice
  String? _safeGetComponent(List<String> components, int index) {
    if (index < 0 || index >= components.length) return null;
    final value = components[index].trim();
    return value.isEmpty ? null : value;
  }

  /// Obtiene un elemento de forma segura por índice
  String? _safeGetElement(List<String> elements, int index) {
    if (index < 0 || index >= elements.length) return null;
    final value = elements[index].trim();
    return value.isEmpty ? null : value;
  }

  // ============================================
  // PARSING DE INFORMACIÓN DEL BUQUE (TDT)
  // ============================================

  /// Parsea el segmento TDT para extraer información del buque
  /// 
  /// Estructura TDT según BAPLIE 2.2.1:
  /// TDT+20+voyageNumber+mode++++carrier:qualifier:agency+:::vesselName+flag'
  /// 
  /// - Nombre del barco: c222.e8212 (posición 8, componente 4)
  /// - Número de viaje: e8028 (posición 2)
  _VesselParseResult _parseVesselInfo(List<String> segments) {
    String? vesselName;
    String? voyageNumber;
    String? imoNumber;
    String? callSign;
    String? flag;
    String? operatorCode;

    for (final segment in segments) {
      if (!segment.startsWith(BaplieConstants.segmentTDT)) continue;

      final elements = _getElements(segment);
      
      // Verificar que es transporte marítimo principal (calificador 20)
      final qualifier = _safeGetElement(elements, 1);
      if (qualifier != BaplieConstants.transportModeMainCarriage) continue;

      // e8028 - Número de viaje (posición 2)
      voyageNumber = _safeGetElement(elements, 2);

      // c222.e8212 - Nombre del buque
      // El elemento 8 contiene c222 con componentes: id:qualifier:agency:vesselName
      if (elements.length > 8) {
        final c222Components = _getComponents(elements[8]);
        // e8212 está en la posición 4 del componente (índice 3)
        vesselName = _safeGetComponent(c222Components, 3);
        // Si no está en posición 4, intentar posición 1 (formato alternativo)
        vesselName ??= _safeGetComponent(c222Components, 0);
      }

      // c040 - Carrier information (posición 7)
      if (elements.length > 7) {
        final c040Components = _getComponents(elements[7]);
        operatorCode = _safeGetComponent(c040Components, 0);
      }

      // Flag puede estar en el último elemento
      if (elements.length > 9) {
        flag = _safeGetElement(elements, 9);
      }

      break; // Solo procesamos el primer TDT válido
    }

    if (vesselName == null || vesselName.isEmpty) {
      // Intentar buscar nombre en RFF+VM (Vessel Name Reference)
      vesselName = _findVesselNameFromRFF(segments);
    }

    if (vesselName == null || vesselName.isEmpty) {
      throw const BaplieParsingException(
        message: 'No se encontró el nombre del buque en el segmento TDT',
        segment: 'TDT',
      );
    }

    return _VesselParseResult(
      vessel: Vessel(
        id: _uuid.v4(),
        name: vesselName,
        imoNumber: imoNumber,
        callSign: callSign,
        flag: flag,
        operator: operatorCode,
      ),
      voyageNumber: voyageNumber ?? 'UNKNOWN',
    );
  }

  /// Busca el nombre del buque en segmentos RFF alternativos
  String? _findVesselNameFromRFF(List<String> segments) {
    for (final segment in segments) {
      if (!segment.startsWith(BaplieConstants.segmentRFF)) continue;
      final elements = _getElements(segment);
      if (elements.length > 1) {
        final components = _getComponents(elements[1]);
        if (components.isNotEmpty && components[0] == 'VM') {
          return _safeGetComponent(components, 1);
        }
      }
    }
    return null;
  }

  // ============================================
  // PARSING DE METADATOS DEL MENSAJE
  // ============================================

  BaplieMetadata? _parseMetadata(List<String> segments) {
    String? messageReference;
    String? messageType;
    String? messageVersion;
    DateTime? preparationDateTime;

    for (final segment in segments) {
      // UNH - Message Header
      if (segment.startsWith(BaplieConstants.segmentUNH)) {
        final elements = _getElements(segment);
        messageReference = _safeGetElement(elements, 1);
        
        if (elements.length > 2) {
          final msgIdComponents = _getComponents(elements[2]);
          messageType = _safeGetComponent(msgIdComponents, 0);
          messageVersion = _safeGetComponent(msgIdComponents, 1);
        }
      }
      
      // DTM - Date/Time of Preparation
      if (segment.startsWith(BaplieConstants.segmentDTM)) {
        final elements = _getElements(segment);
        if (elements.length > 1) {
          final components = _getComponents(elements[1]);
          final qualifier = _safeGetComponent(components, 0);
          final dateValue = _safeGetComponent(components, 1);
          
          // 137 = Document/message date/time
          if (qualifier == '137' && dateValue != null) {
            preparationDateTime = _parseDateTimeValue(dateValue);
          }
        }
      }
    }

    if (messageReference == null && messageType == null) {
      return null;
    }

    return BaplieMetadata(
      messageReference: messageReference,
      messageType: messageType,
      messageVersion: messageVersion,
      preparationDateTime: preparationDateTime,
    );
  }

  /// Parsea valores de fecha/hora EDIFACT (formatos 102, 203, 304)
  DateTime? _parseDateTimeValue(String value) {
    try {
      if (value.length == 8) {
        // Formato 102: YYYYMMDD
        return DateTime.parse(value);
      } else if (value.length == 12) {
        // Formato 203: YYYYMMDDHHmm
        return DateTime(
          int.parse(value.substring(0, 4)),
          int.parse(value.substring(4, 6)),
          int.parse(value.substring(6, 8)),
          int.parse(value.substring(8, 10)),
          int.parse(value.substring(10, 12)),
        );
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  // ============================================
  // PARSING DE CONTENEDORES (LOC+147 -> EQD -> MEA)
  // ============================================

  /// Parsea los contenedores del mensaje BAPLIE
  /// 
  /// Lógica según BAPLIE 2.2.1 (orden real del archivo):
  /// 1. LOC+147 (posición de estiba)
  /// 2. MEA (pesos) - puede venir ANTES o DESPUÉS del EQD
  /// 3. EQD+CN (datos del contenedor)
  /// 
  /// Por esto, acumulamos los pesos temporalmente hasta encontrar el EQD
  List<ContainerUnit> _parseContainers(List<String> segments) {
    final containers = <ContainerUnit>[];
    
    IsoCoordinate? currentPosition;
    String? currentPortOfLoading;
    String? currentPortOfDischarge;
    
    // Acumuladores temporales para pesos (pueden venir antes del EQD)
    double? pendingGrossWeight;
    double? pendingVgmWeight;
    double? pendingTareWeight;
    
    _ContainerBuilder? containerBuilder;

    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final segmentType = _getSegmentType(segment);

      switch (segmentType) {
        case 'LOC':
          final locResult = _parseLOC(segment);
          if (locResult != null) {
            switch (locResult.qualifier) {
              case BaplieConstants.locStowageCell: // 147
                // Guardar contenedor anterior cuando viene nueva posición de estiba
                if (containerBuilder != null && containerBuilder.containerId != null) {
                  containers.add(containerBuilder.build(
                    _uuid.v4(),
                    currentPosition,
                    currentPortOfLoading,
                    currentPortOfDischarge,
                  ));
                  containerBuilder = null;
                }
                // Reiniciar datos para nuevo grupo de contenedor
                currentPosition = locResult.coordinate;
                currentPortOfLoading = null;
                currentPortOfDischarge = null;
                // Reiniciar pesos pendientes
                pendingGrossWeight = null;
                pendingVgmWeight = null;
                pendingTareWeight = null;
                break;
              case BaplieConstants.locPortOfLoading: // 9
                currentPortOfLoading = locResult.locationCode;
                break;
              case BaplieConstants.locPortOfDischarge: // 11
                currentPortOfDischarge = locResult.locationCode;
                break;
            }
          }
          break;

        case 'MEA':
          // Parsear peso a un builder temporal
          final tempBuilder = _ContainerBuilder();
          _parseMEA(segment, tempBuilder);
          
          // Guardar en pendientes o aplicar al contenedor si ya existe
          if (containerBuilder != null) {
            // Ya tenemos EQD, aplicar directamente
            if (tempBuilder.grossWeight != null) {
              containerBuilder.grossWeight = tempBuilder.grossWeight;
            }
            if (tempBuilder.vgmWeight != null) {
              containerBuilder.vgmWeight = tempBuilder.vgmWeight;
            }
            if (tempBuilder.tareWeight != null) {
              containerBuilder.tareWeight = tempBuilder.tareWeight;
            }
          } else {
            // EQD aún no llegó, guardar como pendiente
            if (tempBuilder.grossWeight != null) {
              pendingGrossWeight = tempBuilder.grossWeight;
            }
            if (tempBuilder.vgmWeight != null) {
              pendingVgmWeight = tempBuilder.vgmWeight;
            }
            if (tempBuilder.tareWeight != null) {
              pendingTareWeight = tempBuilder.tareWeight;
            }
          }
          break;

        case 'EQD':
          final eqdResult = _parseEQD(segment);
          if (eqdResult != null) {
            // Crear nuevo contenedor
            containerBuilder = _ContainerBuilder()
              ..containerId = eqdResult.containerId
              ..isoSizeType = eqdResult.isoSizeType
              ..status = eqdResult.status;
            
            // Aplicar pesos pendientes (MEA vino antes del EQD)
            if (pendingGrossWeight != null) {
              containerBuilder.grossWeight = pendingGrossWeight;
            }
            if (pendingVgmWeight != null) {
              containerBuilder.vgmWeight = pendingVgmWeight;
            }
            if (pendingTareWeight != null) {
              containerBuilder.tareWeight = pendingTareWeight;
            }
          }
          break;

        case 'NAD':
          // NAD+CA+ZIM:172:20' -> Carrier (Naviera)
          if (containerBuilder != null) {
            final operatorCode = _parseNAD(segment);
            if (operatorCode != null) {
              containerBuilder.operatorCode = operatorCode;
            }
          }
          break;

        case 'DGS':
          // DGS+IMD+clase+unNumber' -> Mercancías peligrosas
          if (containerBuilder != null) {
            final dgsResult = _parseDGS(segment);
            if (dgsResult != null) {
              containerBuilder.isDangerous = true;
              containerBuilder.imdgClass = dgsResult.imdgClass;
              containerBuilder.unNumber = dgsResult.unNumber;
            }
          }
          break;

        case 'TMP':
          // TMP+2+temperatura:CEL' -> Temperatura de reefer
          if (containerBuilder != null) {
            final tmpResult = _parseTMP(segment);
            if (tmpResult != null) {
              containerBuilder.isReefer = true;
              containerBuilder.temperature = tmpResult.temperature;
              containerBuilder.temperatureUnit = tmpResult.unit;
            }
          }
          break;

        case 'UNT':
          // Fin del mensaje, guardar último contenedor
          if (containerBuilder != null && containerBuilder.containerId != null) {
            containers.add(containerBuilder.build(
              _uuid.v4(),
              currentPosition,
              currentPortOfLoading,
              currentPortOfDischarge,
            ));
            containerBuilder = null;
          }
          break;
      }
    }

    // Guardar último contenedor si no fue procesado por UNT
    if (containerBuilder != null && containerBuilder.containerId != null) {
      containers.add(containerBuilder.build(
        _uuid.v4(),
        currentPosition,
        currentPortOfLoading,
        currentPortOfDischarge,
      ));
    }

    return containers;
  }

  /// Obtiene el tipo de segmento (primeros 3 caracteres)
  String _getSegmentType(String segment) {
    if (segment.length < 3) return '';
    final plusIndex = segment.indexOf(BaplieConstants.elementSeparator);
    if (plusIndex > 0) {
      return segment.substring(0, plusIndex);
    }
    return segment.substring(0, 3);
  }

  /// Parsea segmento LOC (Location)
  /// 
  /// Estructura: LOC+qualifier+locationCode:qualifier:agency'
  /// Para posición de estiba (147): LOC+147+BBBRRTT:::5'
  /// - c517.e3225 contiene la coordenada ISO BBBRRTT
  _LocParseResult? _parseLOC(String segment) {
    final elements = _getElements(segment);
    if (elements.length < 3) return null;

    final qualifier = _safeGetElement(elements, 1);
    if (qualifier == null) return null;

    final c517Components = _getComponents(elements[2]);
    final locationCode = _safeGetComponent(c517Components, 0); // e3225

    IsoCoordinate? coordinate;
    if (qualifier == BaplieConstants.locStowageCell && locationCode != null) {
      coordinate = IsoCoordinateParser.tryParse(locationCode);
    }

    return _LocParseResult(
      qualifier: qualifier,
      locationCode: locationCode,
      coordinate: coordinate,
    );
  }

  /// Parsea segmento EQD (Equipment Details)
  /// 
  /// Estructura puede variar:
  /// - EQD+CN+containerId+isoSizeType+...+status'
  /// - EQD+CN+containerId:prefix+isoSizeType+...'
  /// - c237.e8260: ID del contenedor
  /// - c224.e8155: Tipo ISO (22G1, 45R1, etc.)
  /// - e8169: Estado ('5' = Full, '4' = Empty) - puede estar en diferentes posiciones
  _EqdParseResult? _parseEQD(String segment) {
    final elements = _getElements(segment);
    if (elements.length < 2) return null;

    final qualifier = _safeGetElement(elements, 1);
    if (qualifier != BaplieConstants.eqdContainer) return null; // Solo CN

    String? containerId;
    String? isoSizeType;
    ContainerStatus status = ContainerStatus.unknown;

    // c237.e8260 - Container ID (posición 2)
    if (elements.length > 2) {
      final c237Components = _getComponents(elements[2]);
      containerId = _safeGetComponent(c237Components, 0);
    }

    // c224.e8155 - ISO Size/Type (posición 3)
    if (elements.length > 3) {
      final c224Components = _getComponents(elements[3]);
      isoSizeType = _safeGetComponent(c224Components, 0);
    }

    // e8169 - Equipment Status - buscar en múltiples posiciones
    // Puede estar en posición 4, 5, 6, 7 o incluso como componente
    for (int i = 4; i < elements.length && status == ContainerStatus.unknown; i++) {
      final element = _safeGetElement(elements, i);
      if (element != null && element.isNotEmpty) {
        status = _parseContainerStatus(element);
        // También buscar en componentes
        if (status == ContainerStatus.unknown) {
          final components = _getComponents(element);
          for (final comp in components) {
            final parsed = _parseContainerStatus(comp);
            if (parsed != ContainerStatus.unknown) {
              status = parsed;
              break;
            }
          }
        }
      }
    }

    if (containerId == null) return null;

    return _EqdParseResult(
      containerId: containerId,
      isoSizeType: isoSizeType,
      status: status,
    );
  }

  /// Convierte código de estado a enum
  ContainerStatus _parseContainerStatus(String? code) {
    switch (code) {
      case BaplieConstants.statusFull: // '5'
        return ContainerStatus.full;
      case BaplieConstants.statusEmpty: // '4'
        return ContainerStatus.empty;
      default:
        return ContainerStatus.unknown;
    }
  }

  /// Parsea segmento MEA (Measurements)
  /// 
  /// Formatos encontrados:
  /// - MEA+WT++KGM:21850' (qualifier en pos 1, peso en pos 3 comp 1)
  /// - MEA+AAE+WT+KGM:25000' (qualifier en pos 2, peso en pos 3 comp 1)
  /// - WT: Peso Bruto (Gross Weight)
  /// - VGM: Peso Verificado SOLAS (Verified Gross Mass)
  void _parseMEA(String segment, _ContainerBuilder builder) {
    final elements = _getElements(segment);
    if (elements.length < 2) return;

    // Buscar el qualifier (WT, VGM, T) en posición 1 o 2
    String? qualifier;
    int weightElementIndex = 3;
    
    // Formato 1: MEA+WT++KGM:21850 (qualifier en posición 1)
    final pos1 = _safeGetElement(elements, 1);
    if (pos1 == BaplieConstants.meaGrossWeight || 
        pos1 == BaplieConstants.meaVgm || 
        pos1 == BaplieConstants.meaTare) {
      qualifier = pos1;
      weightElementIndex = 3;
    } else {
      // Formato 2: MEA+AAE+WT+KGM:25000 (qualifier en posición 2)
      qualifier = _safeGetElement(elements, 2);
      weightElementIndex = 3;
    }

    if (qualifier == null) return;

    double? weight;

    // Buscar peso en el elemento correspondiente y sus componentes
    for (int elemIdx = weightElementIndex; elemIdx < elements.length && weight == null; elemIdx++) {
      final element = _safeGetElement(elements, elemIdx);
      if (element == null || element.isEmpty) continue;
      
      // Intentar parsear el elemento directamente
      weight = double.tryParse(element);
      
      // Si no, buscar en componentes
      if (weight == null) {
        final components = _getComponents(element);
        for (final comp in components) {
          weight = double.tryParse(comp);
          if (weight != null) break;
        }
      }
    }

    if (weight == null) return;

    switch (qualifier) {
      case BaplieConstants.meaGrossWeight: // WT
        builder.grossWeight = weight;
        break;
      case BaplieConstants.meaVgm: // VGM
        builder.vgmWeight = weight;
        break;
      case BaplieConstants.meaTare: // T
        builder.tareWeight = weight;
        break;
    }
  }

  /// Parsea segmento NAD (Name and Address)
  /// 
  /// Formato: NAD+CA+ZIM:172:20'
  /// - CA = Carrier (Naviera)
  /// - El código de la naviera está en la posición 2, componente 0
  String? _parseNAD(String segment) {
    final elements = _getElements(segment);
    if (elements.length < 3) return null;

    final qualifier = _safeGetElement(elements, 1);
    // CA = Carrier (Naviera)
    if (qualifier != 'CA') return null;

    final components = _getComponents(elements[2]);
    return _safeGetComponent(components, 0);
  }

  /// Parsea segmento DGS (Dangerous Goods)
  /// 
  /// Formato: DGS+IMD+clase:version+unNumber'
  /// - IMD = IMDG (International Maritime Dangerous Goods)
  /// - clase = Clase IMDG (ej: 3, 8, 9)
  /// - unNumber = Número ONU (ej: 1993, 2810)
  _DgsParseResult? _parseDGS(String segment) {
    final elements = _getElements(segment);
    if (elements.length < 3) return null;

    String? imdgClass;
    String? unNumber;

    // Clase IMDG (posición 2)
    if (elements.length > 2) {
      final classComponents = _getComponents(elements[2]);
      imdgClass = _safeGetComponent(classComponents, 0);
    }

    // Número ONU (posición 3)
    if (elements.length > 3) {
      final unComponents = _getComponents(elements[3]);
      unNumber = _safeGetComponent(unComponents, 0);
    }

    if (imdgClass == null && unNumber == null) return null;

    return _DgsParseResult(imdgClass: imdgClass, unNumber: unNumber);
  }

  /// Parsea segmento TMP (Temperature)
  /// 
  /// Formato: TMP+2+temperatura:CEL' o TMP+2+temperatura:FAH'
  /// - 2 = Storage temperature
  /// - temperatura = valor numérico
  /// - CEL = Celsius, FAH = Fahrenheit
  _TmpParseResult? _parseTMP(String segment) {
    final elements = _getElements(segment);
    if (elements.length < 3) return null;

    final tempComponents = _getComponents(elements[2]);
    final tempValue = _safeGetComponent(tempComponents, 0);
    final tempUnit = _safeGetComponent(tempComponents, 1) ?? 'CEL';

    if (tempValue == null) return null;

    final temperature = double.tryParse(tempValue);
    if (temperature == null) return null;

    return _TmpParseResult(
      temperature: temperature,
      unit: tempUnit == 'FAH' ? 'F' : 'C',
    );
  }

  // ============================================
  // ORGANIZACIÓN DE BAHÍAS
  // ============================================

  /// Organiza los contenedores en bahías
  Map<int, Bay> _organizeBays(List<ContainerUnit> containers) {
    final baysMap = <int, List<ContainerUnit>>{};

    for (final container in containers) {
      final position = container.stowagePosition;
      if (position == null) continue;

      final bayNumber = position.bay;
      baysMap.putIfAbsent(bayNumber, () => []);
      baysMap[bayNumber]!.add(container);
    }

    return baysMap.map((bayNumber, containerList) {
      Bay bay = Bay(
        bayNumber: bayNumber,
        is40FtBay: bayNumber % 2 == 0, // Bahías pares suelen ser de 40'
      );

      for (final container in containerList) {
        bay = bay.addContainer(container);
      }

      return MapEntry(bayNumber, bay);
    });
  }

  /// Determina la dirección del viaje (Import/Export)
  VoyageDirection _determineDirection(List<String> segments) {
    for (final segment in segments) {
      if (segment.startsWith('BGM')) {
        final elements = _getElements(segment);
        if (elements.length > 1) {
          final components = _getComponents(elements[1]);
          final docCode = _safeGetComponent(components, 0);
          // 129 = Goods declaration (Import)
          // 130 = Goods declaration (Export)
          if (docCode == '129') return VoyageDirection.import_;
          if (docCode == '130') return VoyageDirection.export_;
        }
      }
    }
    return VoyageDirection.unknown;
  }
}

// ============================================
// CLASES AUXILIARES INTERNAS
// ============================================

class _VesselParseResult {
  final Vessel vessel;
  final String voyageNumber;

  _VesselParseResult({required this.vessel, required this.voyageNumber});
}

class _LocParseResult {
  final String qualifier;
  final String? locationCode;
  final IsoCoordinate? coordinate;

  _LocParseResult({
    required this.qualifier,
    this.locationCode,
    this.coordinate,
  });
}

class _EqdParseResult {
  final String containerId;
  final String? isoSizeType;
  final ContainerStatus status;

  _EqdParseResult({
    required this.containerId,
    this.isoSizeType,
    required this.status,
  });
}

class _DgsParseResult {
  final String? imdgClass;
  final String? unNumber;

  _DgsParseResult({this.imdgClass, this.unNumber});
}

class _TmpParseResult {
  final double temperature;
  final String unit;

  _TmpParseResult({required this.temperature, required this.unit});
}

class _ContainerBuilder {
  String? containerId;
  String? isoSizeType;
  ContainerStatus status = ContainerStatus.unknown;
  double? grossWeight;
  double? vgmWeight;
  double? tareWeight;
  String? operatorCode;
  bool isDangerous = false;
  String? imdgClass;
  String? unNumber;
  bool isReefer = false;
  double? temperature;
  String? temperatureUnit;

  ContainerUnit build(
    String id,
    IsoCoordinate? position,
    String? portOfLoading,
    String? portOfDischarge,
  ) {
    return ContainerUnit(
      id: id,
      containerId: containerId ?? 'UNKNOWN',
      isoSizeType: isoSizeType,
      status: status,
      stowagePosition: position,
      grossWeight: grossWeight,
      vgmWeight: vgmWeight,
      tareWeight: tareWeight,
      portOfLoading: portOfLoading,
      portOfDischarge: portOfDischarge,
      operatorCode: operatorCode,
      isDangerous: isDangerous,
      imdgClass: imdgClass,
      unNumber: unNumber,
      isReefer: isReefer,
      temperature: temperature,
      temperatureUnit: temperatureUnit,
    );
  }
}
