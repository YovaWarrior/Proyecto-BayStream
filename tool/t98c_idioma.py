"""T-98 · Censo del idioma (RNF-002): qué cadenas de lib/ ve el usuario y en
qué idioma están.

Unidad: la cadena de Dart (las partes adyacentes, unidas como hace el
compilador; ver t98c_lexico.py). Cada cadena recibe una regla con nombre:

1. Contextos automáticos que no admiten duda: directiva import/export, archivo
   que no llega al producto, clave de mapa, ValueKey, debugPrint, RegExp,
   comparación, primer argumento de Text, tooltip, labelText…
2. «Sin letras»: cadenas cuyo texto fijo no tiene ninguna letra (cifras,
   signos, separadores o solo interpolaciones). No tienen idioma: se cuentan
   aparte y no entran en la métrica.
3. Las tablas POR_ARCHIVO, escritas leyendo el código: una regla por omisión
   para lo que quede de cada archivo y excepciones por línea, con su motivo.
4. Una cadena anidada en una interpolación (`'${f('a')}'`) hereda la decisión
   de su cadena madre si su propio contexto no la decide.

El idioma de las cadenas visibles se decide por palabra con el vocabulario
revisado de VOCABULARIO (abajo): cada palabra que no es española queda
etiquetada con su motivo. Nada se decide por muestreo.
"""
import re

# ---------------------------------------------------------------------------
# Archivos de lib/ que no llegan al producto desde lib/main.dart
# ---------------------------------------------------------------------------
FUERA_DEL_PRODUCTO = {
    'lib/latency_test_screen.dart':
        'pantalla H5 congelada; solo la abre tool/h5_main.dart',
    'lib/c3_reconciliation_screen.dart':
        'pantalla H5 congelada; solo la abre tool/h5_main.dart',
    'lib/features/vessel/presentation/pages/segregation_page.dart':
        'la matriz de segregación no tiene entrada en el producto (10.89, pendiente del Sprint 4)',
    'lib/core/utils/privacy_policy_html.dart':
        'plantilla HTML/CSS de tool/t88_privacidad.dart; el texto sale de privacy_policy.dart',
}

# ---------------------------------------------------------------------------
# Contextos automáticos
# ---------------------------------------------------------------------------
LLAMADAS_NO_VISIBLES = {
    'debugPrint': 'NV-REGISTRO', 'print': 'NV-REGISTRO', 'log': 'NV-REGISTRO',
    'developer.log': 'NV-REGISTRO', 'debugPrintStack': 'NV-REGISTRO',
    'assert': 'NV-REGISTRO',
    'ValueKey': 'NV-CLAVE-WIDGET', 'Key': 'NV-CLAVE-WIDGET', 'ObjectKey': 'NV-CLAVE-WIDGET',
    'PageStorageKey': 'NV-CLAVE-WIDGET', 'GlobalObjectKey': 'NV-CLAVE-WIDGET',
    'RegExp': 'NV-PATRON',
    'String.fromEnvironment': 'NV-ENTORNO', 'bool.fromEnvironment': 'NV-ENTORNO',
    'int.fromEnvironment': 'NV-ENTORNO',
}
METODOS_OPERANDO = (
    'startsWith', 'endsWith', 'contains', 'indexOf', 'lastIndexOf', 'split',
    'replaceAll', 'replaceFirst', 'containsKey', 'remove', 'firstWhere',
    'where', 'any', 'tryParse', 'parse', 'trim', 'matchAsPrefix', 'compareTo',
)
METODOS_PERSISTENCIA = (
    'collection', 'doc', 'orderBy', 'openBox', 'box', 'get', 'put', 'delete',
    'containsKey', 'field', 'update', 'set',
)
ETIQUETAS_NO_VISIBLES = {
    'code': 'NV-CODIGO', 'field': 'NV-CODIGO', 'fontFamily': 'NV-CODIGO',
    'package': 'NV-CODIGO', 'restorationId': 'NV-CODIGO', 'heroTag': 'NV-CODIGO',
    'mimeType': 'NV-CODIGO', 'allowedExtensions': 'NV-CODIGO', 'id': 'NV-CODIGO',
    'localeId': 'NV-CODIGO',
}
WIDGETS_DE_TEXTO = {
    'Text': 'pantalla', 'SelectableText': 'pantalla', 'Text.rich': 'pantalla',
    'pw.Text': 'pdf', 'pw.Paragraph': 'pdf', 'pw.Header': 'pdf', 'pw.Bullet': 'pdf',
}
ARGUMENTOS_VISIBLES = {
    ('TextSpan', 'text'): 'pantalla', ('pw.TextSpan', 'text'): 'pdf',
    ('Tab', 'text'): 'pantalla', ('Tooltip', 'message'): 'accesibilidad',
    ('Semantics', 'label'): 'accesibilidad', ('Semantics', 'value'): 'accesibilidad',
    ('Semantics', 'hint'): 'accesibilidad',
}
ETIQUETAS_VISIBLES = {
    'tooltip': 'accesibilidad', 'semanticLabel': 'accesibilidad',
    'semanticsLabel': 'accesibilidad', 'semanticsValue': 'accesibilidad',
    'labelText': 'pantalla', 'hintText': 'pantalla', 'helperText': 'pantalla',
    'errorText': 'pantalla', 'prefixText': 'pantalla', 'suffixText': 'pantalla',
    'counterText': 'pantalla', 'helpText': 'pantalla', 'cancelText': 'pantalla',
    'confirmText': 'pantalla', 'fieldLabelText': 'pantalla', 'fieldHintText': 'pantalla',
    'errorFormatText': 'pantalla', 'errorInvalidText': 'pantalla',
    'searchFieldLabel': 'pantalla', 'dialogTitle': 'sistema',
}

LETRA = re.compile(r'[A-Za-zÀ-ÿ]')


def _sin_cadenas(texto):
    return re.sub(r'§+', 'S', texto)


def _metodo(c):
    """Nombre del método si la cadena es argumento de `x.metodo(` (también
    `x!.metodo(` y `x?.metodo(`)."""
    callee = c.callee or ''
    if '.' in callee:
        return callee.rsplit('.', 1)[-1]
    if callee and re.search(r'[!?]?\.\s*' + re.escape(callee) + r'\s*\($', c.antes.rstrip()):
        return callee
    return None


def automatica(c, alcanzable):
    """(regla, visible, canal) por contexto, o None si hay que decidirla."""
    if c.directiva:
        return 'NV-DIRECTIVA', False, None
    if not alcanzable:
        return 'NV-FUERA-DEL-PRODUCTO', False, None
    seg = _sin_cadenas(c.seg)
    despues = _sin_cadenas(c.despues).lstrip()
    if c.opener == '{' and c.callee == '{' and despues.startswith(':') \
            and '?' not in seg and not re.search(r'\bcase\s*$', seg):
        return 'NV-CLAVE-MAPA', False, None
    if c.callee == 'subindice':
        return 'NV-CLAVE-MAPA', False, None
    if re.search(r'\bcase\s*$', seg) or re.search(r'(==|!=)\s*$', seg) or \
            re.match(r'\s*(==|!=)', despues):
        return 'NV-COMPARACION', False, None
    callee = c.callee or ''
    if callee in LLAMADAS_NO_VISIBLES:
        return LLAMADAS_NO_VISIBLES[callee], False, None
    metodo = _metodo(c)
    if metodo in METODOS_PERSISTENCIA and re.search(
            r'(_db|firestore|_firestore|FirebaseFirestore|collection|doc|_settings|_box|box|Hive|'
            r'snapshot|batch|transaction|_store|store)\b', callee, re.I):
        return 'NV-PERSISTENCIA', False, None
    if metodo in METODOS_OPERANDO:
        return 'NV-OPERANDO', False, None
    if c.label in ETIQUETAS_NO_VISIBLES:
        return ETIQUETAS_NO_VISIBLES[c.label], False, None
    if callee in WIDGETS_DE_TEXTO and c.label is None and c.arg == 0:
        return 'V-TEXTO', True, WIDGETS_DE_TEXTO[callee]
    if (callee, c.label) in ARGUMENTOS_VISIBLES:
        return 'V-ARGUMENTO', True, ARGUMENTOS_VISIBLES[(callee, c.label)]
    if c.label in ETIQUETAS_VISIBLES:
        return 'V-ETIQUETA', True, ETIQUETAS_VISIBLES[c.label]
    return None


def sin_letras(c):
    return not LETRA.search(c.estatico.replace('\\n', ' ').replace('\\t', ' ')
                            .replace('\\r', ' ').replace('\\u00A0', ' ')
                            .replace('\\ufeff', ' '))


# ---------------------------------------------------------------------------
# Tablas escritas leyendo el código
# ---------------------------------------------------------------------------
def V(canal, motivo):
    return ('V-' + canal.upper(), True, canal, motivo)


def NV(regla, motivo):
    return (regla, False, None, motivo)


_P = 'lib/features/vessel/presentation/'
_D = 'lib/features/vessel/domain/'
_DA = 'lib/features/vessel/data/'

PANTALLA = V('pantalla', 'texto de la interfaz, leído en su widget')
ALERTA = V('pantalla', 'descripción, detalle o referencia de una alerta de estiba (pantalla Alertas)')
CONFLICTO = V('pantalla', 'conflicto de la operación: detalle de la celda, Avance y Tapas en la operación')
INTERNO = NV('NV-INTERNO', 'identificador, clave, código o valor interno; no se muestra')
DEPURACION = NV('NV-DEPURACION', 'toString() de depuración; ninguna pantalla lo muestra')
EDI = NV('NV-DATOS-EDI', 'etiqueta, calificador o valor EDIFACT; dato del archivo, no texto de interfaz')

POR_ARCHIVO = {
    'lib/core/app.dart': {'*': V('sistema', 'MaterialApp.title: título de la ventana o de la tarea')},
    'lib/main.dart': {'*': V('sistema', 'MaterialApp.title de la pantalla sin configuración de Firebase')},
    'lib/core/constants/baplie_constants.dart': {'*': EDI},
    'lib/core/constants/privacy_policy.dart': {
        '*': V('pantalla', 'texto de la política (pantalla Política de privacidad; también web/privacidad.html)'),
    },
    'lib/core/errors/exceptions.dart': {
        '*': DEPURACION,
        53: NV('NV-EXCEPCION-INTERNA', 'InvalidIsoCoordinateException: ninguna entrada del usuario llega a parse '
               'con un código inválido (PositionChange.readAll valida antes); no se muestra'),
    },
    'lib/core/errors/failures.dart': {'*': DEPURACION},
    'lib/core/utils/iso_coordinate_parser.dart': {
        '*': INTERNO,
        25: V('pantalla', 'IsoCoordinate.displayFormat: «Posición» en el detalle del contenedor '
              '(bay_plan_view:500, containers_list_view:223 y :453), de la reserva '
              '(reserved_slot_details:67) y del buscador (container_search_delegate:393)'),
        40: DEPURACION,
        140: NV('NV-EXCEPCION-INTERNA', 'rango fuera de 0-999/0-99: solo con enteros del programa, nunca con texto del usuario'),
        143: NV('NV-EXCEPCION-INTERNA', 'rango fuera de 0-999/0-99: solo con enteros del programa, nunca con texto del usuario'),
        146: NV('NV-EXCEPCION-INTERNA', 'rango fuera de 0-999/0-99: solo con enteros del programa, nunca con texto del usuario'),
    },
    _DA + 'datasources/hive_movement_data_source.dart': {
        '*': INTERNO,
        137: NV('NV-EXCEPCION-INTERNA', 'FormatException al leer la bitácora; el repositorio la convierte en '
                'CacheFailure con texto propio'),
    },
    _DA + 'datasources/hive_vessel_data_source.dart': {'*': INTERNO},
    _DA + 'datasources/local_store_compaction.dart': {'*': NV('NV-DIRECTIVA', 'export condicional (segunda línea)')},
    _DA + 'datasources/local_store_directory.dart': {'*': NV('NV-DIRECTIVA', 'export condicional (segunda línea)')},
    _DA + 'datasources/local_store_directory_io.dart': {
        '*': INTERNO,
        12: V('pantalla', 'StateError al abrir el almacén en Android: llega como .message a los cinco catch '
              'que muestran StateError (registro de carga, arrastre, oficina, solicitudes) y como '
              '«Bad state: …» a Tapas en la operación; ruta de error poco probable'),
        17: NV('NV-EXCEPCION-INTERNA', 'solo bajo flutter test (FLUTTER_TEST=true)'),
        23: V('pantalla', 'StateError al abrir el almacén en Windows; mismas rutas que la línea 12'),
        27: NV('NV-EXCEPCION-INTERNA', 'UnsupportedError solo en plataformas sin cliente (iOS, macOS, Linux)'),
    },
    _DA + 'datasources/local_vessel_codec.dart': {
        '*': NV('NV-EXCEPCION-INTERNA', 'FormatException al leer el almacén; se convierte en CacheFailure'),
    },
    _DA + 'repositories/departure_export_repository_impl.dart': {
        '*': V('archivo', 'nombre de archivo sugerido al guardar el BAPLIE de salida'),
        23: INTERNO,
    },
    _DA + 'repositories/export_list_repository_impl.dart': {
        '*': NV('NV-INTERNO', 'nombre por omisión del parámetro; la pantalla pasa el nombre real'),
        26: V('pantalla', 'ValidationFailure del listado: aviso de la pantalla Listado de la agencia'),
    },
    _DA + 'repositories/firebase_session_repository.dart': {
        '*': INTERNO,
        87: V('pantalla', 'nombre provisional de la cuenta en Nube y cuenta'),
        126: V('pantalla', 'nombre de la cuenta en Nube y cuenta'),
        134: V('pantalla', 'nombre de la cuenta en Nube y cuenta'),
        161: V('pantalla', 'mensaje de sesión (Nube y cuenta)'),
        (170, 'Correo'): V('pantalla', 'mensaje de sesión (Nube y cuenta)'),
        (171, 'El correo'): V('pantalla', 'mensaje de sesión (Nube y cuenta)'),
        (172, 'Esta cuenta'): V('pantalla', 'mensaje de sesión (Nube y cuenta)'),
        (173, 'Demasiados'): V('pantalla', 'mensaje de sesión (Nube y cuenta)'),
        (174, 'Sin conexión'): V('pantalla', 'mensaje de sesión (Nube y cuenta)'),
        175: V('pantalla', 'mensaje de sesión con el código de Firebase interpolado'),
        186: V('pantalla', 'mensaje de sesión (Nube y cuenta)'),
        199: V('pantalla', 'mensaje de recuperación de contraseña'),
        200: V('pantalla', 'mensaje de recuperación con el código de Firebase interpolado'),
    },
    _DA + 'repositories/firestore_operation_sync.dart': {
        '*': INTERNO,
        54: V('pantalla', 'mensaje de la nube (Nube y cuenta)'),
        59: V('pantalla', 'mensaje de la nube (Nube y cuenta)'),
        75: NV('NV-INALCANZABLE', 'getOrElse después de comprobar isLeft'),
        127: V('pantalla', 'mensaje de la nube (Nube y cuenta)'),
        (134, 'La nube'): V('pantalla', 'mensaje de la nube (Nube y cuenta)'),
        (136, 'Sin conexión'): V('pantalla', 'mensaje de la nube (Nube y cuenta)'),
        137: V('pantalla', 'mensaje de la nube con el código de Firebase interpolado'),
        178: V('pantalla', 'mensaje de la nube (Nube y cuenta)'),
        202: V('pantalla', 'mensaje de la nube con kind.wire interpolado (arrival_baplie, loading_baplie o export_list)'),
        226: V('pantalla', 'mensaje de la nube (Nube y cuenta)'),
        227: V('pantalla', 'mensaje de la nube (Nube y cuenta)'),
        230: V('pantalla', 'mensaje de la nube (Nube y cuenta)'),
        238: NV('NV-INALCANZABLE', 'map sobre un Left: la función no se ejecuta'),
        240: NV('NV-INALCANZABLE', 'getOrElse después de comprobar isLeft'),
        256: V('pantalla', 'mensaje de la nube (Nube y cuenta)'),
        264: V('pantalla', 'mensaje de la nube (Nube y cuenta)'),
        433: NV('NV-EXCEPCION-INTERNA', 'FormatException al leer el perfil publicado; la pantalla muestra el genérico'),
        482: NV('NV-EXCEPCION-INTERNA', 'FormatException al leer un movimiento remoto; no se muestra'),
    },
    _DA + 'repositories/local_only_operation_sync.dart': {
        '*': V('pantalla', 'mensaje de Nube y cuenta en una compilación sin nube'),
    },
    _DA + 'repositories/local_vessel_repository_factory.dart': {'*': INTERNO},
    _DA + 'repositories/operation_sync_factory.dart': {'*': INTERNO},
    _DA + 'repositories/local_vessel_repository_impl.dart': {
        '*': NV('NV-REEMPLAZADO', 'CacheFailure: la pantalla muestra en su lugar el texto de vesselFailureMessage'),
    },
    _DA + 'repositories/movement_log_repository_impl.dart': {
        '*': INTERNO,
        46: V('pantalla', 'CacheFailure de la bitácora: appendMovement muestra failure.message'),
        236: NV('NV-SIN-USO', 'deleteOperation no tiene llamada en la presentación'),
    },
    _DA + 'repositories/sync_engine.dart': {
        '*': NV('NV-NO-MOSTRADO', 'motivo del rechazo guardado en el registro; ninguna pantalla lo muestra '
                '(solo la cuenta «N rechazados»)'),
        20: DEPURACION,
    },
    _DA + 'repositories/vessel_repository_impl.dart': {
        '*': NV('NV-SOLO-H5', 'funciones remotas de viaje que solo usa la pantalla H5 C3'),
        39: NV('NV-REEMPLAZADO', 'vesselFailureMessage muestra el genérico de vessel_error_message.dart:39'),
    },
    _DA + 'services/baplie_parser_service.dart': {
        '*': EDI,
        25: NV('NV-REEMPLAZADO', 'contiene «vacío»: la pantalla muestra notBaplieFileMessage'),
        35: NV('NV-REEMPLAZADO', 'contiene «segmentos válidos»: la pantalla muestra notBaplieFileMessage'),
        128: NV('NV-REEMPLAZADO', 'marcador para vesselFailureMessage: la pantalla muestra notBaplieFileMessage'),
        133: V('pantalla', 'versión no admitida (unsupported_baplie_version): se muestra tal cual'),
        135: V('pantalla', 'parte del mensaje de versión no admitida'),
        294: NV('NV-REEMPLAZADO', 'TDT: la pantalla muestra el texto propio de vessel_error_message.dart:35'),
        308: V('pantalla', 'número de viaje por omisión cuando el TDT no lo trae: «Viaje: UNKNOWN», PDF y nombre de archivo'),
        491: V('pantalla', 'detalle del aviso «Posiciones mal formadas»'),
        498: V('pantalla', 'detalle del aviso «Pesos revisados»'),
        813: V('pantalla', 'detalle del aviso «Pesos revisados»'),
        817: V('pantalla', 'detalle del aviso «Pesos revisados»'),
        820: V('pantalla', 'detalle del aviso «Pesos revisados»'),
        823: V('pantalla', 'detalle del aviso «Pesos revisados»'),
        1017: NV('NV-INALCANZABLE', 'build() solo se llama con containerId distinto de null (línea 487)'),
    },
    _DA + 'services/browser_voice_support.dart': {'*': NV('NV-DIRECTIVA', 'export condicional (segunda línea)')},
    _DA + 'services/browser_voice_support_web.dart': {'*': INTERNO},
    _DA + 'services/export_list_parser_service.dart': {
        '*': NV('NV-INTERNO', 'encabezado, marca o valor que el lector busca en el Excel; no se muestra'),
        65: V('pantalla', 'error de lectura del listado (aviso de Listado de la agencia)'),
        76: V('pantalla', 'error de lectura del listado (aviso de Listado de la agencia)'),
        155: V('pantalla', 'error de lectura del listado (aviso de Listado de la agencia)'),
        169: V('pantalla', 'error de lectura del listado (aviso de Listado de la agencia)'),
        200: V('pantalla', 'problema de una fila: «Fila N: …» en el resumen del listado'),
        207: V('pantalla', 'problema de una fila del listado'),
        209: V('pantalla', 'problema de una fila del listado'),
        214: V('pantalla', 'problema de una fila del listado'),
        219: V('pantalla', 'problema de una fila del listado'),
        220: V('pantalla', 'problema de una fila del listado'),
        221: V('pantalla', 'problema de una fila del listado'),
        223: V('pantalla', 'problema de una fila del listado'),
        226: V('pantalla', 'problema de una fila del listado'),
        228: V('pantalla', 'problema de una fila del listado'),
        231: V('pantalla', 'problema de una fila del listado'),
        234: V('pantalla', 'problema de una fila del listado'),
        237: V('pantalla', 'problema de una fila del listado'),
    },
    _DA + 'services/export_service.dart': {
        '*': INTERNO,
        13: V('pantalla', 'format.label en «Exportación PDF completada» y en el error de exportación'),
        14: V('pantalla', 'format.label en «Exportación CSV completada» y en el error de exportación'),
        15: V('pantalla', 'format.label en «Exportación JSON completada» y en el error de exportación'),
        (24, 47): V('archivo', 'encabezado de columna del CSV exportado (se abre en Excel)'),
        103: NV('NV-INALCANZABLE', 'el PDF nunca pasa por bytesFor'),
        119: NV('NV-INALCANZABLE', 'el PDF siempre llega con bytes'),
        120: NV('NV-INALCANZABLE', 'el PDF siempre llega con bytes'),
        137: V('archivo', 'nombre de archivo sugerido al exportar'),
        188: V('archivo', 'parte del nombre de archivo sugerido'),
    },
    _DA + 'services/pdf_report_service.dart': {
        '*': V('pdf', 'texto del reporte PDF'),
        27: NV('NV-INTERNO', 'ruta del recurso de fuente'),
        30: NV('NV-INTERNO', 'ruta del recurso de fuente'),
        33: V('pdf', 'metadatos del PDF (título)'),
        34: V('pdf', 'metadatos del PDF (autor)'),
        35: V('pdf', 'metadatos del PDF (creador)'),
        36: V('pdf', 'metadatos del PDF (asunto)'),
    },
    _D + 'entities/bay.dart': {
        '*': INTERNO,
        165: NV('NV-SIN-USO', 'getContainerAt no tiene llamadas en lib/'),
        275: DEPURACION, 276: DEPURACION,
    },
    _D + 'entities/container_slot.dart': {
        '*': INTERNO,
        68: NV('NV-SIN-USO', 'ContainerSlot.displayFormat no se usa en ninguna pantalla'),
        172: DEPURACION,
    },
    _D + 'entities/container_unit.dart': {'*': DEPURACION},
    _D + 'entities/dangerous_goods.dart': {
        '*': V('pantalla', 'reglamento por omisión (IMD): «Reglamento» en el detalle de la reserva'),
    },
    _D + 'entities/export_list.dart': {
        '*': INTERNO,
        (8, 'Tipo'): V('pantalla', 'kind.label en las equivalencias del listado'),
        (9, 'Puerto'): V('pantalla', 'kind.label en las equivalencias del listado'),
        (10, 'Línea'): V('pantalla', 'kind.label en las equivalencias del listado'),
        283: V('pantalla', 'agrupación «Sin agencia: N» del resumen del listado'),
        329: NV('NV-EXCEPCION-INTERNA', 'FormatException del listado guardado; la pantalla del listado '
                'muestra el genérico (Tapas en la operación mostraría «FormatException: …», ver mensajes)'),
    },
    _D + 'entities/hatch_covers.dart': {
        '*': V('pantalla', 'validación de tapas (Tapas de escotilla, Parámetros del buque) o nombre de la tapa'),
        19: INTERNO,
    },
    _D + 'entities/movement.dart': {
        '*': INTERNO,
        178: NV('NV-EXCEPCION-INTERNA', 'FormatException al leer un movimiento; no se muestra'),
        (325, 384): V('pantalla', 'MovementDraft.validate: llega como error de registro o como StateError de ChangeRequests'),
    },
    _D + 'entities/operation.dart': {'*': INTERNO},
    _D + 'entities/reserved_slot.dart': {'*': INTERNO},
    _D + 'entities/vessel.dart': {
        '*': INTERNO,
        96: DEPURACION,
        119: NV('NV-EXCEPCION-INTERNA', 'ArgumentError al construir la identidad; no se muestra'),
    },
    _D + 'entities/vessel_geometry.dart': {'*': DEPURACION},
    _D + 'entities/vessel_profile.dart': {
        '*': V('pantalla', 'hatchCoverError: «Bahía N: …» al confirmar la geometría'),
        57: NV('NV-REEMPLAZADO', 'ArgumentError capturado en _chooseTemplate: se muestra el genérico'),
    },
    _D + 'entities/vessel_voyage.dart': {
        '*': INTERNO,
        456: DEPURACION,
        565: NV('NV-EXCEPCION-INTERNA', 'invariante interna de los avisos de lectura'),
        580: V('pantalla', 'detalle de un aviso de lectura al reabrir un viaje'),
    },
    _D + 'repositories/export_list_repository.dart': {'*': NV('NV-INTERNO', 'nombre por omisión del parámetro')},
    _D + 'repositories/operation_sync_repository.dart': {'*': DEPURACION},
    _D + 'services/change_requests.dart': {
        '*': V('pantalla', 'revisión de un cambio de plan: SnackBar del arrastre, formularios y decisiones'),
    },
    _D + 'services/container_stacking_validator.dart': {'*': ALERTA},
    _D + 'services/container_voice_query.dart': {
        '*': NV('NV-VOZ', 'vocabulario del dictado (letras, cifras y palabras que devuelve el reconocedor); no se muestra'),
    },
    _D + 'services/current_profile_parameters.dart': {
        '*': V('pantalla', 'nombre del parámetro en el aviso de Viajes recientes'),
    },
    _D + 'services/dangerous_goods_validator.dart': {
        '*': ALERTA,
        (287, 288): NV('NV-INTERNO', 'tercer carácter del tipo ISO que se compara'),
    },
    _D + 'services/departure_baplie_writer.dart': {
        '*': EDI,
        19: V('pantalla', 'error al generar el BAPLIE de salida (pantalla BAPLIE de salida)'),
        25: V('pantalla', 'error al generar el BAPLIE de salida'),
        45: V('pantalla', 'error al generar el BAPLIE de salida'),
        54: V('pantalla', 'error al generar el BAPLIE de salida'),
        66: V('pantalla', 'error al generar el BAPLIE de salida'),
        91: V('pantalla', 'línea de la lista de cancelados (pantalla BAPLIE de salida)'),
        92: V('pantalla', 'parte de la línea de cancelados'),
        124: INTERNO, 125: INTERNO, 127: INTERNO,
        183: V('pantalla', 'error al generar el BAPLIE de salida'),
        193: V('pantalla', 'error al generar el BAPLIE de salida'),
        196: V('pantalla', 'error al generar el BAPLIE de salida'),
        229: V('pantalla', 'error al generar el BAPLIE de salida'),
        236: V('pantalla', 'error al generar el BAPLIE de salida'),
        237: V('pantalla', 'parte del error de versión'),
        279: V('pantalla', 'error al generar el BAPLIE de salida'),
    },
    _D + 'services/export_list_cross_checker.dart': {
        '*': V('pantalla', 'cruce del listado con el plan: diferencias y avisos de peligrosas'),
        290: INTERNO, 361: INTERNO,
    },
    _D + 'services/imdg_42_24_data.dart': {
        '*': NV('NV-DATOS', 'tabla de segregación codificada (la muestra la matriz, sin entrada en el producto)'),
    },
    _D + 'services/load_check.dart': {
        '*': V('pantalla', 'revisión de la carga (diálogo Confirmar carga) y peso de la pila'),
        137: INTERNO, 175: INTERNO,
    },
    _D + 'services/loading_operation.dart': {
        '*': V('pantalla', 'StateError del registro de carga: se muestra su .message'),
    },
    _D + 'services/loading_plan_progress.dart': {'*': V('pantalla', 'rótulo de la celda en el modo Número de orden')},
    _D + 'services/operation_sources.dart': {
        '*': V('pantalla', 'ValidationFailure: vesselErrorMessage lo muestra tal cual'),
    },
    _D + 'services/operation_state_deriver.dart': {'*': CONFLICTO},
    _D + 'services/reefer_socket_ranges.dart': {
        '*': V('pantalla', 'error de la carga de tomas por rangos (Parámetros del buque)'),
    },
    _D + 'services/reefer_socket_validator.dart': {'*': ALERTA},
    _D + 'services/segregation_rules.dart': {
        '*': NV('NV-INTERNO', 'código de segregación'),
        15: V('pantalla', 'descargo de la pantalla Alertas de estiba'),
    },
    _D + 'services/stack_weight_validator.dart': {'*': ALERTA},
    _D + 'services/voyage_comparison.dart': {
        '*': V('pantalla', 'pantalla Comparar BAPLIE (campos y aviso de buque)'),
    },
    _P + 'formatters/operation_text.dart': {'*': PANTALLA},
    _P + 'formatters/vessel_error_message.dart': {'*': V('pantalla', 'mensaje de error de la interfaz')},
    _P + 'pages/change_requests_page.dart': {'*': PANTALLA, 241: INTERNO},
    _P + 'pages/cloud_page.dart': {'*': PANTALLA},
    _P + 'pages/departure_baplie_page.dart': {
        '*': PANTALLA,
        172: NV('NV-INALCANZABLE', 'getOrElse después de comprobar los fallos'),
        173: NV('NV-INALCANZABLE', 'getOrElse después de comprobar los fallos'),
    },
    _P + 'pages/discharge_sequence_page.dart': {
        '*': PANTALLA,
        (126, 126): INTERNO, (133, 133): INTERNO, (140, 140): INTERNO,
        (146, 146): INTERNO, (152, 152): INTERNO,
    },
    _P + 'pages/export_list_import_page.dart': {'*': PANTALLA},
    _P + 'pages/hatch_covers_page.dart': {'*': PANTALLA, (182, 197): INTERNO},
    _P + 'pages/operation_progress_page.dart': {'*': PANTALLA},
    _P + 'pages/recent_voyages_page.dart': {'*': PANTALLA},
    _P + 'pages/stowage_alerts_page.dart': {'*': PANTALLA},
    _P + 'pages/vessel_geometry_page.dart': {
        '*': PANTALLA,
        (307, 'geometry'): INTERNO, (308, 'geometry'): INTERNO, (309, 'geometry'): INTERNO,
        342: INTERNO, 351: INTERNO, 365: INTERNO, 374: INTERNO,
        (470, 'socket'): INTERNO, (472, 'socket'): INTERNO, (474, 'socket'): INTERNO,
        (586, 'socket'): INTERNO, (587, 'socket'): INTERNO, (590, 'socket'): INTERNO,
        (591, 'socket'): INTERNO, (592, 'socket'): INTERNO, (594, 'socket'): INTERNO,
        (724, 740): INTERNO,
    },
    _P + 'pages/vessel_overview_page.dart': {'*': PANTALLA},
    _P + 'pages/voyage_comparison_page.dart': {'*': PANTALLA},
    _P + 'providers/discharge_provider.dart': {
        '*': V('pantalla', 'autor sin cuenta y motivo rápido «Marcado por error» (se ven en los detalles)'),
    },
    _P + 'providers/export_list_providers.dart': {'*': PANTALLA, 121: INTERNO},
    _P + 'providers/stowage_validation_provider.dart': {'*': INTERNO},
    _P + 'providers/vessel_providers.dart': {
        '*': PANTALLA,
        111: V('pantalla', 'nombre por omisión del archivo en «Archivo "BAPLIE" cargado correctamente»'),
        209: V('pantalla', 'nombre por omisión del archivo'),
        740: V('pantalla', 'rótulo de la barra de navieras en Estadísticas'),
        760: V('pantalla', 'rótulo de la barra de puertos en Estadísticas cuando falta el POD'),
    },
    _P + 'providers/voice_recognizer_provider.dart': {'*': INTERNO},
    _P + 'widgets/bay_plan_view.dart': {
        '*': PANTALLA,
        560: INTERNO, 1109: INTERNO, 1164: INTERNO,
    },
    _P + 'widgets/container_search_delegate.dart': {'*': PANTALLA},
    _P + 'widgets/containers_list_view.dart': {'*': PANTALLA},
    _P + 'widgets/discharge_controls.dart': {'*': PANTALLA},
    _P + 'widgets/hatch_cover_diagram.dart': {'*': PANTALLA},
    _P + 'widgets/hatch_operation_controls.dart': {'*': PANTALLA},
    _P + 'widgets/loading_controls.dart': {
        '*': PANTALLA,
        35: INTERNO, 617: INTERNO,
        135: NV('NV-MEDICION', 'texto que solo se mide (TextPainter) para calcular el alto de una línea'),
    },
    _P + 'widgets/loading_plan_controls.dart': {'*': PANTALLA},
    _P + 'widgets/office_plan_controls.dart': {'*': PANTALLA},
    _P + 'widgets/plan_drag_confirmation.dart': {'*': PANTALLA},
    _P + 'widgets/reserved_slot_details.dart': {'*': PANTALLA},
    _P + 'widgets/reserved_slots_list_view.dart': {'*': PANTALLA},
    _P + 'widgets/sync_status_chip.dart': {'*': PANTALLA},
    _P + 'widgets/voice_search_field.dart': {'*': PANTALLA},
    _P + 'widgets/voyage_call_summary.dart': {'*': PANTALLA},
    _P + 'widgets/voyage_stats_view.dart': {'*': PANTALLA},
    _P + 'widgets/voyage_summary_card.dart': {
        '*': PANTALLA,
        148: NV('NV-MEDICION', 'palabras que solo se miden (TextPainter) para decidir si apilar'),
    },
}

# Cadenas que la regla automática clasificó y la lectura corrige.
CORRECCIONES = {
    ('lib/features/vessel/presentation/widgets/loading_controls.dart', 135):
        NV('NV-MEDICION', 'texto que solo se mide (TextPainter) para calcular el alto de una línea'),
}


# ---------------------------------------------------------------------------
# Vocabulario revisado: toda palabra de una cadena visible que NO es española.
# Lo que no está aquí se lee como español (las palabras con tilde o ñ lo son
# por construcción; las demás, 1322 palabras distintas sin tilde, se revisaron
# una por una en la lista que produce el censo).
# ---------------------------------------------------------------------------
EN = 'inglés'
SIGLA = 'sigla o código'
NOMBRE = 'nombre propio, marca o producto'
FORMATO = 'unidad, formato, ruta o identificador técnico'
PRESTAMO = 'préstamo de uso común'

VOCABULARIO = {
    # inglés
    'Bay': (EN, 'bahía; «Bay Plan» es el nombre de la vista en el ERS y en T-63'),
    'BAY': (EN, 'bahía'),
    'Row': (EN, 'fila'), 'Tier': (EN, 'nivel'), 'Tiers': (EN, 'niveles'),
    'DECK': (EN, 'cubierta (glosa entre paréntesis)'),
    'HOLD': (EN, 'bodega (glosa entre paréntesis)'),
    'Reefer': (EN, 'refrigerado; el producto dice «Refrigerado» en otras pantallas'),
    'reefer': (EN, 'refrigerado'), 'Reefers': (EN, 'refrigerados'),
    'slots': (EN, 'huecos o celdas'),
    'Tip': (EN, 'consejo o sugerencia'),
    'UNKNOWN': (EN, 'desconocido; marcador de número de viaje ausente'),
    'loading_baplie': (EN, 'identificador interno de la fuente (OperationSourceKind.wire)'),
    'containerId': (EN, 'encabezado del CSV'), 'finalDestination': (EN, 'encabezado del CSV'),
    'grossWeight': (EN, 'encabezado del CSV'), 'imdgClass': (EN, 'encabezado del CSV'),
    'isDangerous': (EN, 'encabezado del CSV'), 'isoSizeType': (EN, 'encabezado del CSV'),
    'isOverDimension': (EN, 'encabezado del CSV'), 'isReefer': (EN, 'encabezado del CSV'),
    'operatorCode': (EN, 'encabezado del CSV'), 'overHeight': (EN, 'encabezado del CSV'),
    'overLengthFront': (EN, 'encabezado del CSV'), 'overLengthRear': (EN, 'encabezado del CSV'),
    'overWidthLeft': (EN, 'encabezado del CSV'), 'overWidthRight': (EN, 'encabezado del CSV'),
    'portOfDischarge': (EN, 'encabezado del CSV'), 'portOfLoading': (EN, 'encabezado del CSV'),
    'status': (EN, 'encabezado del CSV'), 'stowagePosition': (EN, 'encabezado del CSV'),
    'tareWeight': (EN, 'encabezado del CSV'), 'temperature': (EN, 'encabezado del CSV'),
    'temperatureUnit': (EN, 'encabezado del CSV'), 'unNumber': (EN, 'encabezado del CSV'),
    'vgmWeight': (EN, 'encabezado del CSV'),
    # préstamos
    'app': (PRESTAMO, 'Fundéu la admite como abreviación de «aplicación»; también en una ruta'),
    'Zoom': (PRESTAMO, 'anglicismo; la forma española es «zum»'),
    'zoom': (PRESTAMO, 'anglicismo; la forma española es «zum»'),
    # siglas y códigos del estándar o del dominio
    **{w: (SIGLA, 'sigla o código') for w in (
        'BAPLIE', 'EDIFACT', 'SMDG', 'UNB', 'UNH', 'TDT', 'DGS', 'IMD', 'IMDG', 'IMO',
        'ISO', 'ONU', 'UN', 'OOG', 'TEU', 'VGM', 'WT', 'LBR', 'TNE', 'POD', 'POL', 'OPR',
        'OR', 'DG', 'ID', 'id', 'IP', 'SDK', 'MSKU', 'R', 'T', 'B', 'C', 'D', 'E', 'F',
        'L', 'V', 'X', 'S', 'b', 'N_A', 'N_D')},
    # nombres propios, marcas y productos
    **{w: (NOMBRE, 'nombre propio, marca o producto') for w in (
        'BayStream', 'baystream', 'BAYSTREAM', 'Android', 'Windows', 'Excel', 'Firebase',
        'Firestore', 'firestore', 'Google', 'Cloud', 'Authentication', 'Hosting',
        'Carlos', 'Giovanni', 'Aldana', 'Barrios', 'Guatemala', 'Martínez', 'México',
        'northamerica', 'south')},
    'CORREO_ELECTRONICO': (FORMATO, 'dirección de correo (las salidas la omiten)'),
    # unidades, formatos, rutas e identificadores técnicos
    **{w: (FORMATO, 'unidad, formato, ruta o identificador técnico') for w in (
        'kg', 't', 'ft', 'm', 'HH', 'mm', 'BBB', 'RR', 'TT', 'BBBRRTT', 'CSV', 'PDF',
        'JSON', 'xlsx', 'edi', 'x', 'AppData', 'Local', 'DEFAULT', 'LOCALAPPDATA')},
}
# Palabras de una letra que son españolas (conjunciones y preposición).
ESPANOL_UNA_LETRA = {'a', 'e', 'o', 'u', 'y', 'O', 'Y'}


def palabras(c):
    """Palabras del texto fijo de una cadena (sin interpolaciones). Una
    dirección de correo cuenta como una sola palabra, sin repetirla."""
    t = c.estatico
    t = re.sub(r'[\w.+-]+@[\w.-]+\.[A-Za-z]{2,}', ' CORREO_ELECTRONICO ', t)
    t = re.sub(r'\\[ntr]', ' ', t)
    t = re.sub(r'\\u[0-9A-Fa-f]{4}', ' ', t)
    t = t.replace('N/A', ' N_A ').replace('N/D', ' N_D ')
    return re.findall(r'[A-Za-zÀ-ÿ_]+', t)


# Cadenas cuyo texto fijo es español pero que interpolan un valor en inglés.
INTERPOLA_INGLES = {
    ('lib/features/vessel/data/repositories/firestore_operation_sync.dart', 202):
        'kind.wire: arrival_baplie, loading_baplie o export_list',
    ('lib/features/vessel/data/repositories/firestore_operation_sync.dart', 137):
        'error.code de Firebase (p. ej. «internal», «deadline-exceeded»)',
    ('lib/features/vessel/data/repositories/firebase_session_repository.dart', 175):
        'código de Firebase Auth (p. ej. «operation-not-allowed»)',
    ('lib/features/vessel/data/repositories/firebase_session_repository.dart', 200):
        'código de Firebase Auth',
}


def idioma(c):
    """(categoría, lista de palabras no españolas con su etiqueta)."""
    es, otras = 0, []
    interpolado = INTERPOLA_INGLES.get((c.archivo, c.linea))
    if interpolado is not None:
        otras.append(('{valor interpolado}', EN, interpolado))
    for w in palabras(c):
        etiqueta = VOCABULARIO.get(w)
        if etiqueta is None and len(w) == 1 and w not in ESPANOL_UNA_LETRA:
            etiqueta = (SIGLA, 'letra suelta')
        if etiqueta is None:
            es += 1
            continue
        otras.append((w,) + etiqueta)
    ingles = [o for o in otras if o[1] == EN]
    if ingles:
        return ('mixta' if es else 'otro idioma'), otras
    if es:
        return 'español', otras
    return 'sin idioma (siglas, nombres o unidades)', otras


# ---------------------------------------------------------------------------
# Textos que pone Flutter (DefaultMaterialLocalizations, inglés de EE. UU.)
# porque MaterialApp no declara localizationsDelegates ni locale y
# flutter_localizations no está en pubspec.yaml. Origen: SDK 3.38.9,
# packages/flutter/lib/src/material/…; cada fila dice el widget de lib/ que
# lo hace aparecer. No son literales de lib/: se cuentan aparte.
# ---------------------------------------------------------------------------
_MAT = 'material/'
FRAMEWORK = [
    # (texto, origen en el SDK, widget, dónde aparece en BayStream, canal, plataformas)
    ('Back', _MAT + 'action_buttons.dart:149 y :200 (backButtonTooltip)',
     'BackButton automático de AppBar',
     'las 15 rutas empujadas sin leading propio (14 pantallas): Recientes, Perfiles, Parámetros, Política, Tapas de escotilla, '
     'Alertas, Listado, BAPLIE de salida, Comparar, Orden de descarga, Avance, Tapas en la operación, Solicitudes '
     '(y su formulario) y Nube y cuenta. El Honor lo leyó en Alertas, Recientes y Parámetros (Fase B).',
     'accesibilidad y tooltip', 'Android, Windows y Web'),
    ('Alert', _MAT + 'dialog.dart:782 (alertDialogLabel)', 'AlertDialog sin semanticLabel',
     'los 17 AlertDialog del producto', 'accesibilidad', 'Android, Windows y Linux (no iOS/macOS)'),
    ('Dismiss', _MAT + 'dialog.dart:1680 (modalBarrierDismissLabel)', 'barrera de showDialog',
     'las 19 llamadas a showDialog', 'accesibilidad', 'todas'),
    ('Scrim', _MAT + 'bottom_sheet.dart:1271 (scrimLabel)', 'barrera de showModalBottomSheet',
     'las 7 hojas modales (detalle del contenedor y de la reserva, tablas de pendientes, selector de OR, '
     'confirmación del arrastre)', 'accesibilidad', 'todas'),
    ('Close Bottom Sheet', _MAT + 'bottom_sheet.dart:1272 (scrimOnTapHint + bottomSheetLabel)',
     'barrera de showModalBottomSheet', 'las mismas 7 hojas', 'accesibilidad', 'todas'),
    ('Popup menu', _MAT + 'popup_menu.dart:1203 (popupMenuLabel)', 'menú de PopupMenuButton',
     'Exportar viaje, Acciones del Bay Plan compacto, Agregar un nivel (los tres botones traen tooltip propio)',
     'accesibilidad', 'todas'),
    ('Delete', _MAT + 'chip.dart:1307-1308 (deleteButtonTooltip)', 'InputChip con onDeleted sin deleteButtonTooltipMessage',
     'Parámetros del buque: niveles (vessel_geometry_page.dart:778) y tomas (:505)', 'tooltip y accesibilidad', 'todas'),
    ('Tab 1 of 3 (Tab N of M)', _MAT + 'tabs.dart:1970 (tabLabel)', 'TabBar',
     'pestañas Lista / Bay Plan / Estadísticas y las de Comparar BAPLIE', 'accesibilidad', 'todas'),
    ('N characters remaining', _MAT + 'text_field.dart:1243 (remainingTextFieldCharacterCount)',
     'TextField con maxLength', 'los cuatro campos de motivo con 300 caracteres (arrastre, oficina, solicitud, '
     'decisión); el contador visible «0/300» es numérico', 'accesibilidad', 'todas'),
    ('Expanded / Collapsed', _MAT + 'expansion_tile.dart:533-534 (expandedHint, collapsedHint; se anuncia al abrir o cerrar)',
     'ExpansionTile', 'Celdas reservadas, Frontera y anclas, Tomas de reefer, secciones del cruce y Filas del listado',
     'accesibilidad', 'todas (las pistas «double tap…» de :597-598 son solo de iOS y macOS)'),
    ('Expand for more details / Collapse', _MAT + 'expansion_tile.dart:590-591', 'ExpansionTile',
     'los mismos cinco', 'accesibilidad', 'todas'),
    ('Cut / Copy / Paste / Select all', _MAT + 'adaptive_text_selection_toolbar.dart:221-224',
     'barra de selección de texto', 'todos los TextField y TextFormField, los SelectableText (detalle de avisos, '
     'cancelados, etiquetas de Estadísticas) y la SelectionArea de la Política', 'pantalla',
     'Android y Windows; en la Web los campos usan el menú del navegador (widgets/editable_text.dart:2511)'),
    ('Look Up / Search Web / Share', _MAT + 'adaptive_text_selection_toolbar.dart:226-228',
     'barra de selección de texto', 'los mismos campos, según lo que ofrezca el sistema', 'pantalla', 'Android'),
    ('Select date', _MAT + 'date_picker.dart:724 (datePickerHelpText)', 'showDatePicker sin helpText',
     'botón «Fecha» del diálogo Confirmar carga (loading_controls.dart:660)', 'pantalla', 'todas'),
    ('Cancel / OK', _MAT + 'date_picker.dart:615 y :622', 'showDatePicker sin cancelText ni confirmText',
     'el mismo selector', 'pantalla', 'todas'),
    ('Switch to input / Switch to calendar', _MAT + 'date_picker.dart:698 y :711', 'showDatePicker',
     'el mismo selector', 'tooltip', 'todas'),
    ('Enter Date / mm/dd/yyyy', 'material/input_date_picker_form_field.dart:273-274', 'showDatePicker en modo texto',
     'el mismo selector (formato de EE. UU., distinto del «día/mes/año» que muestra el diálogo)', 'pantalla', 'todas'),
    ('Invalid format. / Out of range.', 'material/input_date_picker_form_field.dart:232-234', 'showDatePicker en modo texto',
     'el mismo selector', 'pantalla', 'todas'),
    ('Previous month / Next month / Select year', 'material/calendar_date_picker.dart:874-889 y :489',
     'showDatePicker', 'el mismo selector', 'tooltip y accesibilidad', 'todas'),
    ('January … December; S M T W T F S; «Tue, Oct 20»; «October 2026»',
     _MAT + 'material_localizations.dart (_months, _narrowWeekdays, formatMediumDate, formatMonthYear)',
     'showDatePicker', 'el mismo selector', 'pantalla', 'todas'),
]


def _buscar(tabla, c):
    """Decisión de la tabla de un archivo para la cadena c."""
    linea = c.linea
    texto = c.texto
    for clave, decision in tabla.items():
        if isinstance(clave, tuple) and isinstance(clave[1], str):
            if clave[0] == linea and texto.startswith(clave[1]):
                return decision
    if linea in tabla:
        return tabla[linea]
    for clave, decision in tabla.items():
        if isinstance(clave, tuple) and isinstance(clave[1], int):
            if clave[0] <= linea <= clave[1]:
                return decision
    return tabla.get('*')


def decidir(c, alcanzable, padres):
    """(regla, visible, canal, motivo) de una cadena. `padres` guarda las
    decisiones ya tomadas por índice de literal."""
    auto = automatica(c, alcanzable)
    if auto is not None and auto[0] in ('NV-DIRECTIVA', 'NV-FUERA-DEL-PRODUCTO'):
        motivo = FUERA_DEL_PRODUCTO.get(c.archivo, 'directiva import/export/part')
        return auto + (motivo,)
    if sin_letras(c):
        return ('SIN-LETRAS', None, None, 'sin letras: cifras, signos, separadores o solo interpolaciones')
    correccion = CORRECCIONES.get((c.archivo, c.linea))
    if correccion is not None:
        return correccion
    if auto is not None:
        return auto + ('contexto automático',)
    if c.parent is not None and c.padre_cadena is not None:
        madre = padres.get(id(c.padre_cadena))
        if madre is not None and madre[0] != 'SIN-LETRAS':
            return (madre[0] + '/ANIDADA',) + tuple(madre[1:3]) + ('hereda de su cadena madre',)
    tabla = POR_ARCHIVO.get(c.archivo)
    if tabla is not None:
        d = _buscar(tabla, c)
        if d is not None:
            return d
    return ('PENDIENTE', None, None, 'sin decidir')
