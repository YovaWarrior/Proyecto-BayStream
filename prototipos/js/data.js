/* ============================================================================
 * BayStream — Prototipos Interactivos
 * data.js  ·  Datos demo del viaje + catálogo de los 35 Requerimientos (RF)
 *
 * El viaje demo replica el archivo de prueba "test_baystream_demo.edi"
 * descrito en el entregable (MSC GUATEMALA, V047E, GTSTC -> HNPCR).
 * ==========================================================================*/

/* --------------------------------------------------------------------------
 * 1. VIAJE DEMO  (VesselVoyage)
 * ------------------------------------------------------------------------*/
window.DEMO = {
  vessel: {
    name: 'MSC GUATEMALA',
    imoNumber: '9839272',
    callSign: '3FGV8',
    flag: 'PA',          // Panamá
    flagName: 'Panamá',
    operator: 'MSC',
  },
  voyage: {
    voyageNumber: 'V047E',
    messageType: 'BAPLIE',
    baplieVersion: 'D.13B',
    preparationDate: '12/05/2026 18:27',
    portOfLoading: 'GTSTC',   // Santo Tomás de Castilla, Guatemala
    portOfDischarge: 'HNPCR', // Puerto Cortés, Honduras
  },

  // Contenedores del viaje: estándar, reefer, IMDG, OOG y vacíos, en cubierta y bodega
  containers: [
    // --- Bahía 010 · cubierta (tier ≥ 80) + bodega (tier < 80) ---
    {
      id: 'c1', containerId: 'MSCU1234567', isoSizeType: '22G1', sizeFeet: 20,
      status: 'full', bay: 10, row: 4, tier: 82,
      gross: 24500, vgm: 24650, tare: 2200,
      pol: 'GTSTC', pod: 'HNPCR', operator: 'MSC',
      isDangerous: false, isReefer: false, isOOG: false,
    },
    {
      id: 'c2', containerId: 'MSKU7654321', isoSizeType: '45R1', sizeFeet: 40,
      status: 'full', bay: 10, row: 6, tier: 82,
      gross: 28200, vgm: 28400, tare: 4200,
      pol: 'GTSTC', pod: 'HNPCR', operator: 'MSK',
      isDangerous: false, isReefer: true, temp: -18.0, tempUnit: 'C', isOOG: false,
    },
    {
      id: 'c3', containerId: 'MEDU3045882', isoSizeType: '45G1', sizeFeet: 40,
      status: 'full', bay: 10, row: 2, tier: 84,
      gross: 21750, vgm: 21900, tare: 3900,
      pol: 'GTSTC', pod: 'HNPCR', operator: 'MSC',
      isDangerous: false, isReefer: false, isOOG: false,
    },
    {
      id: 'c4', containerId: 'MSKU8830114', isoSizeType: '22G1', sizeFeet: 20,
      status: 'full', bay: 10, row: 4, tier: 78,
      gross: 17600, vgm: 17700, tare: 2200,
      pol: 'GTSTC', pod: 'HNPCR', operator: 'MSK',
      isDangerous: false, isReefer: false, isOOG: false,
    },
    {
      id: 'c5', containerId: 'CMAU5567401', isoSizeType: '22G1', sizeFeet: 20,
      status: 'empty', bay: 10, row: 6, tier: 76,
      gross: 2300, vgm: null, tare: 2300,
      pol: 'GTSTC', pod: 'HNPCR', operator: 'CMA',
      isDangerous: false, isReefer: false, isOOG: false,
    },

    // --- Bahía 012 · mercancía peligrosa (IMDG) ---
    {
      id: 'c6', containerId: 'CMAU9988776', isoSizeType: '22G1', sizeFeet: 20,
      status: 'full', bay: 12, row: 1, tier: 84,
      gross: 19800, vgm: null, tare: 2200,
      pol: 'GTSTC', pod: 'HNPCR', operator: 'CMA',
      isDangerous: true, imdgClass: '3', unNumber: '1993',
      isReefer: false, isOOG: false,
    },

    // --- Bahía 014 · sobredimensionado (OOG) ---
    {
      id: 'c7', containerId: 'HLBU5544332', isoSizeType: '42P3', sizeFeet: 40,
      status: 'full', bay: 14, row: 6, tier: 82,
      gross: 31400, vgm: 31600, tare: 5000,
      pol: 'GTSTC', pod: 'HNPCR', operator: 'HLC',
      isDangerous: false, isReefer: false,
      isOOG: true, overHeight: 35, overWidthLeft: 20, overWidthRight: 20,
    },

    // --- Bahía 022 · contenedor vacío ---
    {
      id: 'c8', containerId: 'ZIMU1112223', isoSizeType: '22G1', sizeFeet: 20,
      status: 'empty', bay: 22, row: 1, tier: 84,
      gross: 2300, vgm: null, tare: 2300,
      pol: 'GTSTC', pod: 'HNPCR', operator: 'ZIM',
      isDangerous: false, isReefer: false, isOOG: false,
    },
  ],

  // Bahías con su % de ocupación
  bays: [
    { bayNumber: 10, occupancy: 6 },
    { bayNumber: 12, occupancy: 2 },
    { bayNumber: 14, occupancy: 1 },
    { bayNumber: 22, occupancy: 1 },
  ],
};

/* Helpers de datos --------------------------------------------------------*/
window.DEMO.containersByBay = function (bayNumber) {
  return window.DEMO.containers.filter(function (c) { return c.bay === bayNumber; });
};
window.DEMO.findContainer = function (cid) {
  return window.DEMO.containers.find(function (c) { return c.containerId === cid; });
};
window.DEMO.totalWeightTon = function () {
  var kg = window.DEMO.containers.reduce(function (s, c) { return s + (c.gross || 0); }, 0);
  return (kg / 1000).toFixed(1);
};
window.DEMO.carriers = function () {
  var map = {};
  window.DEMO.containers.forEach(function (c) { map[c.operator] = (map[c.operator] || 0) + 1; });
  return map;
};
window.DEMO.ports = function () {
  var map = {};
  window.DEMO.containers.forEach(function (c) {
    if (c.pod) map[c.pod] = (map[c.pod] || 0) + 1;
  });
  return map;
};

/* Formato de posición BBBRRTT legible */
window.fmtPosition = function (c) {
  if (!c || c.bay == null) return 'N/A';
  var pad = function (n, l) { return String(n).padStart(l, '0'); };
  return 'Bay ' + pad(c.bay, 3) + ', Row ' + pad(c.row, 2) + ', Tier ' + pad(c.tier, 2);
};

/* Tipo de carga especial dominante (para colores / etiquetas) */
window.cargoKind = function (c) {
  if (c.isDangerous) return 'imo';
  if (c.isReefer) return 'reefer';
  if (c.isOOG) return 'oog';
  if (c.status === 'full') return 'full';
  if (c.status === 'empty') return 'empty';
  return 'unknown';
};

/* --------------------------------------------------------------------------
 * 2. CATÁLOGO DE LOS 35 REQUERIMIENTOS FUNCIONALES
 *    (7 módulos · prioridad MoSCoW · estado · caso de uso · trazabilidad)
 * ------------------------------------------------------------------------*/
window.RF_MODULES = [
  {
    num: 1, icon: '📥', name: 'Carga y Procesamiento de Datos',
    rfs: [
      { id: 'RF-001', name: 'Selección y Carga de Archivo BAPLIE', priority: 'MUST', status: 'Implementado', cu: 'CU01',
        desc: 'Permite seleccionar y cargar un archivo BAPLIE/EDIFACT (.edi, .txt, .baplie) desde el sistema de archivos mediante un selector nativo, con retroalimentación visual de progreso y éxito/error.',
        key: ['Estado vacío con llamada a la acción', 'Selector nativo filtrado a .edi/.txt/.baplie', 'Indicador de progreso de carga', 'SnackBar de confirmación con el nombre del archivo'] },
      { id: 'RF-002', name: 'Parsing y Validación del Formato BAPLIE 2.2.1', priority: 'MUST', status: 'Implementado', cu: 'CU01',
        desc: 'Parser EDIFACT que normaliza el contenido, separa segmentos, elementos (+) y componentes (:), y los procesa secuencialmente (UNH, TDT, LOC, EQD, MEA, NAD, DGS, TMP, UNT) para construir el VesselVoyage.',
        key: ['Normalización y división en segmentos', 'Procesamiento secuencial por tipo de segmento', 'Construcción del objeto VesselVoyage', 'Excepción descriptiva ante formato inválido'] },
      { id: 'RF-003', name: 'Extracción de Información del Buque', priority: 'MUST', status: 'Implementado', cu: 'CU01',
        desc: 'Extrae del segmento TDT el nombre del buque, número de viaje, código de naviera, bandera y número IMO, con respaldo en segmentos RFF (calificador VM).',
        key: ['Segmento TDT con calificador 20', 'Nombre, viaje, operador, bandera, IMO', 'Respaldo RFF+VM', 'Viaje = UNKNOWN si no está presente'] },
      { id: 'RF-004', name: 'Extracción de Datos de Contenedores', priority: 'MUST', status: 'Implementado', cu: 'CU01',
        desc: 'Extrae cada contenedor de los grupos LOC+EQD+MEA+NAD: identificador BIC, tipo ISO, estado, posición BBBRRTT, pesos (bruto/VGM/tara) y naviera, con mecanismo de pesos pendientes.',
        key: ['Coordenada ISO BBBRRTT → bahía/fila/tier', 'Pesos MEA (WT/VGM/T)', 'Naviera NAD+CA', 'Pesos pendientes sin importar orden'] },
      { id: 'RF-005', name: 'Detección de Carga Especial (IMO, Reefer, OOG)', priority: 'MUST', status: 'Implementado', cu: 'CU01',
        desc: 'Detecta y clasifica mercancía peligrosa (DGS: clase IMDG + ONU), refrigerados (TMP: temperatura) y sobredimensión (DIM/OOG), marcando indicadores booleanos.',
        key: ['DGS → isDangerous + clase IMDG + UN', 'TMP → isReefer + temperatura', 'DIM → isOverDimension', 'Indicadores simultáneos posibles'] },
    ],
  },
  {
    num: 2, icon: '🗺️', name: 'Visualización del Plano de Estiba',
    rfs: [
      { id: 'RF-006', name: 'Representación Visual del Grid de Bahía', priority: 'MUST', status: 'Implementado', cu: 'CU02 · CU08',
        desc: 'Genera una cuadrícula por bahía donde cada celda es una posición de estiba (fila/tier). Filas impares/pares, tiers de bodega (02-78) y cubierta (80-98).',
        key: ['Grid adaptado al tamaño real de la bahía', 'Etiquetas de fila y tier', 'Celdas ocupadas vs. vacías', 'Posición según coordenada ISO'] },
      { id: 'RF-007', name: 'Selector de Bahías con Navegación', priority: 'MUST', status: 'Implementado', cu: 'CU02',
        desc: 'Barra horizontal de chips numerados para seleccionar bahías, con flechas de avance/retroceso y scroll automático. La bahía activa se resalta y el grid se actualiza.',
        key: ['Chips ordenados numéricamente', 'Flechas ◀ ▶ de navegación', 'Bahía activa resaltada', 'Scroll automático'] },
      { id: 'RF-008', name: 'Codificación por Color según Estado', priority: 'MUST', status: 'Implementado', cu: 'CU02 · CU08',
        desc: 'Esquema cromático por estado/tipo: verde (lleno), naranja (vacío), celeste (reefer), rojo (IMO/DG), morado/naranja (OOG), gris (sin contenedor). Prioridad: peligroso > reefer > OOG > estado base.',
        key: ['Color único por tipo', 'Jerarquía de prioridad de colores', 'Distinguible en tema claro/oscuro'] },
      { id: 'RF-009', name: 'Separación Visual Cubierta / Bodega', priority: 'MUST', status: 'Implementado', cu: 'CU02',
        desc: 'Diferencia cubierta (tiers ≥ 80) y bodega (tiers < 80) con etiquetas "CUBIERTA (DECK)" y "BODEGA (HOLD)" y una línea divisora que simula la tapa de escotilla.',
        key: ['Etiqueta CUBIERTA en azul', 'Etiqueta BODEGA en marrón', 'Línea divisora (hatch cover)', 'Solo se muestra la sección con carga'] },
      { id: 'RF-010', name: 'Detalle de Contenedor al Interactuar', priority: 'MUST', status: 'Implementado', cu: 'CU06',
        desc: 'Al tocar una celda ocupada se abre un panel modal (BottomSheet) con todos los atributos del contenedor: BIC, ISO, estado, posición, pesos, puertos, naviera y carga especial.',
        key: ['Modal con secciones organizadas', 'Celda vacía no abre panel', 'Sección IMDG / Reefer destacada', 'Cierre por toque exterior'] },
      { id: 'RF-011', name: 'Leyenda Interactiva de Colores', priority: 'SHOULD', status: 'Propuesto', cu: 'CU08',
        desc: 'Leyenda inferior donde al tocar un color se filtran/resaltan solo los contenedores de ese tipo, atenuando los demás. Un segundo toque desactiva el filtro.',
        key: ['Leyenda con los 6 tipos', 'Toque filtra por tipo', 'Atenúa los no coincidentes', 'Segundo toque limpia el filtro'] },
      { id: 'RF-012', name: 'Indicadores de Peso por Tier', priority: 'SHOULD', status: 'Propuesto', cu: 'CU02',
        desc: 'Calcula y muestra el peso acumulado por tier (en toneladas) al costado del grid, con barra proporcional, para verificar la distribución de peso para estabilidad.',
        key: ['Suma de peso bruto por tier', 'Etiqueta en toneladas', 'Barra proporcional', 'Tiers vacíos sin indicador'] },
      { id: 'RF-013', name: 'Resaltado de Contenedor Buscado', priority: 'MUST', status: 'Implementado', cu: 'CU03',
        desc: 'Aplica un efecto de borde dorado pulsante sobre la celda del contenedor localizado desde la búsqueda, seleccionando automáticamente su bahía.',
        key: ['Borde dorado animado', 'Bahía seleccionada automáticamente', 'Resaltado visible sin distraer', 'Se limpia al cambiar de contexto'] },
      { id: 'RF-014', name: 'Indicador de % de Ocupación por Bahía', priority: 'SHOULD', status: 'Propuesto', cu: 'CU02',
        desc: 'Calcula y muestra el porcentaje de ocupación de cada bahía (slots ocupados / total) junto a su número en el selector, con escala de intensidad de color.',
        key: ['% por bahía en el selector', 'Gradiente proporcional', 'Bahías sin carga = 0%'] },
    ],
  },
  {
    num: 3, icon: '🔍', name: 'Búsqueda de Contenedores',
    rfs: [
      { id: 'RF-015', name: 'Búsqueda por Identificador (BIC Code)', priority: 'MUST', status: 'Implementado', cu: 'CU03',
        desc: 'Búsqueda en tiempo real por identificador BIC (ISO 6346) con coincidencia parcial e insensible a mayúsculas. Resultados como tarjetas; al seleccionar navega al Bay Plan.',
        key: ['Búsqueda parcial', 'Insensible a mayúsculas', 'Resultados en tiempo real', 'Navegación al Bay Plan al seleccionar'] },
      { id: 'RF-016', name: 'Búsqueda por Puerto de Carga/Descarga', priority: 'MUST', status: 'Implementado', cu: 'CU03',
        desc: 'Filtra contenedores por puerto de carga (LOC+9) o descarga (LOC+11) usando códigos UN/LOCODE de 5 caracteres, distinguiendo el tipo de coincidencia.',
        key: ['Códigos UN/LOCODE', 'Coincidencia parcial y completa', 'Distingue carga vs. descarga'] },
      { id: 'RF-017', name: 'Búsqueda por Naviera Operadora', priority: 'SHOULD', status: 'Implementado', cu: 'CU03',
        desc: 'Localiza contenedores por código de naviera (operatorCode del NAD+CA, estándar SCAC/BIC) con búsqueda parcial.',
        key: ['Filtro por operatorCode', 'Búsqueda parcial (MS → MSC)', 'Complementa los chips de la lista'] },
      { id: 'RF-018', name: 'Búsqueda por Tipo de Carga Especial', priority: 'SHOULD', status: 'Implementado', cu: 'CU03',
        desc: 'Filtra por tipo de carga especial mediante términos como "reefer", "imo", "peligroso", "oog" o "sobredimensión".',
        key: ['Palabras clave de carga especial', 'Resultados con etiqueta del tipo', 'Útil para inspecciones de seguridad'] },
      { id: 'RF-019', name: 'Navegación Automática al Bay Plan', priority: 'MUST', status: 'Implementado', cu: 'CU03',
        desc: 'Al seleccionar un resultado, cierra el buscador, calcula la bahía desde la coordenada ISO, actualiza los providers y cambia a la pestaña Bay Plan con la celda resaltada.',
        key: ['Calcula bahía desde coordenada ISO', 'Actualiza selectedBay/highlighted', 'Cambia a pestaña Bay Plan', 'Celda resaltada'] },
      { id: 'RF-020', name: 'Estado Vacío del Buscador con Estadísticas', priority: 'COULD', status: 'Propuesto', cu: 'CU03',
        desc: 'Cuando el campo está vacío muestra sugerencias accionables (navieras y puertos del viaje con conteo) y estadísticas rápidas; sin resultados muestra mensaje claro.',
        key: ['Sugerencias de navieras (chips)', 'Sugerencias de puertos', 'Estadísticas del viaje', 'Tip contextual'] },
    ],
  },
  {
    num: 4, icon: '📋', name: 'Lista y Filtrado de Contenedores',
    rfs: [
      { id: 'RF-021', name: 'Lista Desplazable con Tarjetas de Detalle', priority: 'MUST', status: 'Implementado', cu: 'CU06',
        desc: 'ListView de tarjetas con BIC, naviera, tipo ISO, estado, posición, peso e indicadores de carga especial. Al tocar una tarjeta se abre el detalle completo.',
        key: ['Una tarjeta por contenedor', 'Iconos de carga especial', 'Scroll fluido con miles de ítems', 'Toque → detalle completo'] },
      { id: 'RF-022', name: 'Filtrado por Naviera mediante Chips', priority: 'MUST', status: 'Implementado', cu: 'CU08',
        desc: 'FilterChips con "Todas" + un chip por naviera con conteo. Al seleccionar filtra la lista; los chips estadísticos se recalculan. Solo un filtro activo a la vez.',
        key: ['Chip Todas + chips por naviera', 'Conteo por naviera', 'Recalcula llenos/vacíos', 'Reactividad con Riverpod'] },
      { id: 'RF-023', name: 'Tarjeta de Resumen del Viaje', priority: 'MUST', status: 'Implementado', cu: 'CU02',
        desc: 'Tarjeta superior con buque, número de viaje, bandera, total de contenedores, bahías, peso bruto total y metadatos del mensaje BAPLIE.',
        key: ['Buque, viaje, bandera', 'Métricas agregadas', 'Metadatos BAPLIE', 'Diseño con gradiente'] },
      { id: 'RF-024', name: 'Dashboard Estadístico con Gráficos', priority: 'SHOULD', status: 'Implementado', cu: 'CU09',
        desc: 'Pestaña de estadísticas: grid de métricas, gráfico circular lleno/vacío, distribución por tamaño, tarjetas de carga especial y barras por naviera/puerto/bahía.',
        key: ['6 métricas clave', 'Pie chart lleno/vacío', 'Distribución por tamaño', 'Barras por naviera, puerto y bahía'] },
      { id: 'RF-025', name: 'Exportación de Reporte en PDF', priority: 'SHOULD', status: 'Propuesto', cu: 'CU09',
        desc: 'Genera y exporta un reporte PDF con resumen del viaje, estadísticas, distribución y Bay Plan simplificado, localmente y sin conexión.',
        key: ['PDF con secciones formateadas', 'Tablas de distribución', 'Bay Plan simplificado', 'Guardar o compartir, sin internet'] },
    ],
  },
  {
    num: 5, icon: '⚓', name: 'Gestión de Muelle y Planificación',
    rfs: [
      { id: 'RF-026', name: 'Distribución General del Buque', priority: 'SHOULD', status: 'Propuesto', cu: 'CU02',
        desc: 'Vista panorámica con todas las bahías en una sola pantalla, coloreadas por nivel de ocupación, identificando zonas de alta/baja carga y carga especial.',
        key: ['Bahías de proa a popa', 'Color por ocupación', 'Indicadores de carga especial', 'Toque → detalle de bahía'] },
      { id: 'RF-027', name: 'Validación de Reglas de Estiba', priority: 'COULD', status: 'Propuesto', cu: 'CU04',
        desc: 'Verifica reglas de estiba: apilamiento de 20 pies sobre 40 pies, límites de peso por stack, separación IMDG y reefers con acceso eléctrico, generando alertas.',
        key: ['Reglas de apilamiento', 'Límite de peso por stack', 'Separación IMDG', 'Alertas con severidad y ubicación'] },
      { id: 'RF-028', name: 'Planificación de Secuencia de Descarga', priority: 'COULD', status: 'Propuesto', cu: 'CU04',
        desc: 'Dado un puerto de descarga, agrupa contenedores por bahía y sugiere un orden que minimiza movimientos de grúa (cubierta antes que bodega).',
        key: ['Filtra por puerto de descarga', 'Agrupa por bahía', 'Cubierta antes que bodega', 'Conteo de movimientos estimados'] },
      { id: 'RF-029', name: 'Comparación entre Viajes', priority: 'COULD', status: 'Propuesto', cu: 'CU01',
        desc: 'Carga dos BAPLIE del mismo buque (llegada/salida) y compara: descargados, cargados y permanentes, con colores diferenciados.',
        key: ['Dos archivos BAPLIE', 'Diff por ID de contenedor', '3 estados diferenciados', 'Resumen numérico de movimientos'] },
      { id: 'RF-030', name: 'Soporte de Modo Offline', priority: 'MUST', status: 'Implementado', cu: 'CU04 · CU05',
        desc: 'Toda la funcionalidad (carga, parsing, visualización, búsqueda, filtrado) opera localmente sin conexión a internet, requisito operativo del sector portuario.',
        key: ['Parsing 100% local', 'Sin llamadas a APIs para función básica', 'UI funcional sin red', 'Arquitectura Offline-First'] },
    ],
  },
  {
    num: 6, icon: '☁️', name: 'Sincronización y Respaldo de Datos',
    rfs: [
      { id: 'RF-031', name: 'Almacenamiento Local Persistente', priority: 'SHOULD', status: 'Propuesto', cu: 'CU07',
        desc: 'Guarda viajes procesados en almacenamiento local (JSON serializado) para reabrirlos sin reprocesar el BAPLIE, con lista de viajes recientes.',
        key: ['Serialización toJson/fromJson', 'SharedPreferences / Hive', 'Índice de viajes guardados', 'Lista de viajes recientes'] },
      { id: 'RF-032', name: 'Sincronización en la Nube', priority: 'COULD', status: 'Propuesto', cu: 'CU05',
        desc: 'Sincroniza viajes con Firebase Firestore (opcional) para respaldo y acceso multi-dispositivo, manteniendo offline como modo primario y resolviendo conflictos por timestamp.',
        key: ['Opcional y configurable', 'Cola offline + reintento', 'Resolución por timestamp', 'No afecta el modo offline'] },
      { id: 'RF-033', name: 'Exportación en Formatos Estándar', priority: 'SHOULD', status: 'Propuesto', cu: 'CU09',
        desc: 'Exporta los datos del viaje en CSV (una fila por contenedor) y JSON (VesselVoyage completo) para integrarse con otros sistemas o TOS.',
        key: ['CSV con todos los campos', 'JSON reimportable', 'Diálogo de guardado', 'Integración con TOS'] },
    ],
  },
  {
    num: 7, icon: '🔐', name: 'Administración y Seguridad',
    rfs: [
      { id: 'RF-034', name: 'Autenticación de Usuarios', priority: 'COULD', status: 'Propuesto', cu: 'CU05 · CU07',
        desc: 'Login con Firebase Authentication (correo/contraseña y Google) para funciones avanzadas (sync, historial). Las funciones básicas permanecen sin login.',
        key: ['Correo/contraseña + Google', 'Token seguro persistente', 'Funciones básicas sin login', 'Cierre de sesión'] },
      { id: 'RF-035', name: 'Control de Acceso Basado en Roles (RBAC)', priority: 'COULD', status: 'Propuesto', cu: 'CU07',
        desc: 'Roles Operador, Planificador y Administrador con permisos diferenciados; la interfaz se adapta mostrando solo las funciones autorizadas por rol.',
        key: ['3 roles definidos', 'Menús adaptados por rol', 'Validación en operaciones sensibles', 'Admin gestiona roles'] },
    ],
  },
];

/* Aplana el catálogo para búsquedas por id y orden de navegación */
window.RF_FLAT = [];
window.RF_MODULES.forEach(function (m) {
  m.rfs.forEach(function (rf) {
    rf.moduleNum = m.num;
    rf.moduleName = m.name;
    window.RF_FLAT.push(rf);
  });
});
window.findRF = function (id) {
  return window.RF_FLAT.find(function (rf) { return rf.id === id; });
};
