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
  
  /// Puerto de salida del buque (Place of Departure)
  ///
  /// Va una sola vez, en la cabecera del mensaje, y es lo que el archivo
  /// declara como puerto para el que vale este plano.
  static const String locPlaceOfDeparture = '5';

  /// Próximo puerto de escala declarado en la cabecera.
  static const String locNextPortOfCall = '61';

  /// Puerto de carga (Port of Loading)
  static const String locPortOfLoading = '9';
  
  /// Puerto de descarga (Port of Discharge)
  static const String locPortOfDischarge = '11';
  
  /// Puerto de transbordo (Port of Transhipment)
  static const String locPortOfTranshipment = '13';

  /// T-144 · Destino final: «"83" = Place of delivery (to be used as final
  /// destination…)» en la guía SMDG 2.2.1 (06/2016, p. 21), y el mismo
  /// calificador en la 1.5 (05/1993, p. 20).
  static const String locFinalDestination = '83';

  /// T-144 · Puerto de carga de la 1.5: «Code "6" (Port of Loading)» (guía
  /// SMDG 1.5, 05/1993, p. 20). En la 1.5 no existen el 9 ni el 11; en la 2.x
  /// el 6 no es un puerto del contenedor, así que va atado a la versión.
  static const String locPortOfLoadingV15 = '6';

  /// T-144 · Puerto de descarga de la 1.5: «Code "12" (Port of Discharge)»
  /// (guía SMDG 1.5, 05/1993, p. 20).
  static const String locPortOfDischargeV15 = '12';

  // ============================================
  // CALIFICADORES DIM (T-144, RF-005)
  // ============================================
  //
  // Guía SMDG 2.2.1 (06/2016, p. 18) y 1.5 (05/1993, p. 17): «Off-standard
  // dims.» 5 frente, 6 atrás, 7 derecha, 8 izquierda y 9 alto. El valor va en
  // el componente del largo (5 y 6), del ancho (7 y 8) o del alto (9) del
  // C211, «as qualified». Unidad CMT (2.x, preferida) o INH; CM en la 1.5.

  /// Sobrelongitud frontal.
  static const String dimOverLengthFront = '5';

  /// Sobrelongitud trasera.
  static const String dimOverLengthRear = '6';

  /// Sobreancho derecho.
  static const String dimOverWidthRight = '7';

  /// Sobreancho izquierdo.
  static const String dimOverWidthLeft = '8';

  /// Sobrealtura.
  static const String dimOverHeight = '9';

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
