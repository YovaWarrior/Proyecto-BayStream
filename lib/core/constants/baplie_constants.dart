/// Constantes del estándar EDIFACT BAPLIE 2.2.1
/// Referencia: SMDG BAPLIE Implementation Guide
class BaplieConstants {
  BaplieConstants._();

  // ============================================
  // SEPARADORES EDIFACT
  // ============================================
  
  /// Separador de segmentos (Segment Terminator)
  static const String segmentSeparator = "'";
  
  /// Separador de elementos de datos (Data Element Separator)
  static const String elementSeparator = '+';
  
  /// Separador de componentes (Component Data Separator)
  static const String componentSeparator = ':';
  
  /// Carácter de escape (Release Character)
  static const String releaseCharacter = '?';

  // ============================================
  // SEGMENTOS PRINCIPALES
  // ============================================
  
  /// Segmento de identificación de mensaje
  static const String segmentUNH = 'UNH';
  
  /// Segmento de terminación de mensaje
  static const String segmentUNT = 'UNT';
  
  /// Segmento de detalles de transporte (Vessel/Voyage)
  static const String segmentTDT = 'TDT';
  
  /// Segmento de localización (Location)
  static const String segmentLOC = 'LOC';
  
  /// Segmento de equipamiento (Container)
  static const String segmentEQD = 'EQD';
  
  /// Segmento de medidas (Measurements)
  static const String segmentMEA = 'MEA';
  
  /// Segmento de referencia
  static const String segmentRFF = 'RFF';
  
  /// Segmento de fecha/hora
  static const String segmentDTM = 'DTM';
  
  /// Segmento de texto libre
  static const String segmentFTX = 'FTX';
  
  /// Segmento de nombre y dirección
  static const String segmentNAD = 'NAD';

  // ============================================
  // CALIFICADORES LOC (Location Qualifiers)
  // ============================================
  
  /// Posición de estiba en el buque (Stowage Cell)
  static const String locStowageCell = '147';
  
  /// Puerto de carga (Port of Loading)
  static const String locPortOfLoading = '9';
  
  /// Puerto de descarga (Port of Discharge)
  static const String locPortOfDischarge = '11';
  
  /// Puerto de transbordo (Port of Transhipment)
  static const String locPortOfTranshipment = '13';

  // ============================================
  // CALIFICADORES EQD (Equipment Qualifiers)
  // ============================================
  
  /// Contenedor (Container)
  static const String eqdContainer = 'CN';
  
  /// Trailer
  static const String eqdTrailer = 'TE';

  // ============================================
  // ESTADOS DE CONTENEDOR (Equipment Status)
  // ============================================
  
  /// Contenedor vacío
  static const String statusEmpty = '4';
  
  /// Contenedor lleno
  static const String statusFull = '5';

  // ============================================
  // CALIFICADORES MEA (Measurement Qualifiers)
  // ============================================
  
  /// Peso bruto (Gross Weight)
  static const String meaGrossWeight = 'WT';
  
  /// Peso verificado SOLAS (Verified Gross Mass)
  static const String meaVgm = 'VGM';
  
  /// Tara del contenedor
  static const String meaTare = 'T';

  // ============================================
  // TIPOS DE TRANSPORTE TDT
  // ============================================
  
  /// Transporte marítimo principal
  static const String transportModeMainCarriage = '20';
}
