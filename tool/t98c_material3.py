"""T-98 · Censo de Material 3 (RNF-002, decisión 2.4 a): cada control
interactivo de las rutas del producto, si es un componente de la biblioteca
Material y si su color sale de `Theme.of(context).colorScheme`.

Unidad: cada aparición en el código de un constructor de control interactivo
(como cuenta tool/t98_inventario.py), asignada a la pantalla donde se ve. Los
controles que el framework pone sin un constructor en lib/ (el botón de volver
de AppBar, el campo del buscador, el selector de fecha) se agregan como filas
«implícitas».

El color se lee en el tramo de argumentos del constructor, hijos incluidos:
una expresión con `colorScheme`, `scheme.` o `colors.` sale del esquema; una
con `Colors.` o `Color(0x…)` es fija. Sin ninguna expresión de color, el
control usa los colores del tema, que Material 3 deriva del esquema.
"""
import re

from t98c_lexico import CODEX_CONTROLS, Lexer, masked, leer

# Los nombres de tool/t98_inventario.py más los que no busca, y con argumentos
# de tipo opcionales: su patrón no admite `PopupMenuButton<T>(`, así que esos
# constructores no entran en sus 210 candidatos.
NOMBRES = (
    'TextButton|FilledButton|ElevatedButton|OutlinedButton|IconButton|'
    'FloatingActionButton|DropdownButton|DropdownMenu|PopupMenuButton|'
    'Checkbox|Switch|Radio|Slider|RangeSlider|TextField|TextFormField|'
    'FilterChip|ChoiceChip|ActionChip|InputChip|SegmentedButton|'
    'NavigationBar|NavigationRail|NavigationDrawer|BottomNavigationBar|'
    'TabBar|ListTile|CheckboxListTile|SwitchListTile|RadioListTile|'
    'InkWell|GestureDetector|Draggable|DragTarget|InteractiveViewer|'
    'MenuItemButton|SubmenuButton|SearchBar|SearchAnchor|'
    'ExpansionTile|DropdownButtonFormField|PopupMenuItem|SnackBarAction|'
    'LongPressDraggable')
COMPLETO = re.compile(
    r'\b(?:' + NOMBRES + r')\b(?:\.[\w]+)?\s*(?:<[^()]*?>)?\s*\(')
# Lo que tool/t98_inventario.py no busca, sin operación de usuario.
NO_CONTROLES = ('InteractiveViewer',)

PANTALLAS = {
    'S01': 'Inicio y viaje: barra superior, pestañas y Lista (VesselOverviewPage)',
    'S02': 'Bay Plan (pestaña): encabezado, selector de bahías, leyenda, zoom y hojas de detalle',
    'S03': 'Estadísticas (pestaña)',
    'S04': 'Buscar contenedor (SearchDelegate)',
    'S05': 'Viajes recientes',
    'S06': 'Perfiles guardados',
    'S07': 'Parámetros',
    'S08': 'Política de privacidad',
    'S09': 'Parámetros del buque (geometría)',
    'S10': 'Tapas de escotilla',
    'S11': 'Alertas de estiba',
    'S12': 'Listado de la agencia',
    'S13': 'BAPLIE de salida',
    'S14': 'Comparar BAPLIE',
    'S15': 'Orden de descarga',
    'S16': 'Avance de la operación',
    'S17': 'Tapas en la operación',
    'S18': 'Solicitudes de cambio, Bandeja y formulario Pedir cambio / Mover',
    'S19': 'Nube y cuenta',
}

_P = 'lib/features/vessel/presentation/'
# Archivo → pantalla por omisión; excepciones por rango de líneas.
PANTALLA_DE = {
    _P + 'pages/vessel_overview_page.dart': {'*': 'S01'},
    _P + 'widgets/empty_state_widget.dart': {'*': 'S01+S05'},
    _P + 'widgets/containers_list_view.dart': {'*': 'S01'},
    _P + 'widgets/reserved_slots_list_view.dart': {'*': 'S01'},
    _P + 'widgets/reserved_slot_details.dart': {'*': 'S01+S02'},
    _P + 'widgets/voyage_summary_card.dart': {'*': 'S01'},
    _P + 'pages/departure_baplie_page.dart': {'*': 'S13', (25, 38): 'S01'},
    _P + 'widgets/bay_plan_view.dart': {'*': 'S02'},
    _P + 'widgets/loading_plan_controls.dart': {'*': 'S02'},
    _P + 'widgets/loading_controls.dart': {'*': 'S02'},
    _P + 'widgets/discharge_controls.dart': {'*': 'S02'},
    _P + 'widgets/plan_drag_confirmation.dart': {'*': 'S02'},
    _P + 'widgets/office_plan_controls.dart': {'*': 'S02'},
    _P + 'widgets/voice_search_field.dart': {'*': 'S02'},
    _P + 'widgets/hatch_operation_controls.dart': {'*': 'S17', (9, 37): 'S02'},
    _P + 'widgets/sync_status_chip.dart': {'*': 'S02+S16+S18', (98, 116): 'S01'},
    _P + 'pages/change_requests_page.dart': {'*': 'S18', (26, 50): 'S02'},
    _P + 'widgets/voyage_stats_view.dart': {'*': 'S03'},
    _P + 'widgets/container_search_delegate.dart': {'*': 'S04'},
    _P + 'pages/recent_voyages_page.dart': {'*': 'S05'},
    _P + 'pages/vessel_profiles_page.dart': {'*': 'S06'},
    _P + 'pages/parameters_page.dart': {'*': 'S07'},
    _P + 'pages/privacy_policy_page.dart': {'*': 'S08'},
    _P + 'pages/vessel_geometry_page.dart': {'*': 'S09'},
    _P + 'pages/hatch_covers_page.dart': {'*': 'S10'},
    _P + 'pages/stowage_alerts_page.dart': {'*': 'S11'},
    _P + 'pages/export_list_import_page.dart': {'*': 'S12'},
    _P + 'pages/voyage_comparison_page.dart': {'*': 'S14'},
    _P + 'pages/discharge_sequence_page.dart': {'*': 'S15'},
    _P + 'pages/operation_progress_page.dart': {'*': 'S16'},
    _P + 'pages/cloud_page.dart': {'*': 'S19'},
}

# La rejilla (decisión 2.4 a): sus celdas no tienen componente equivalente en
# Material 3. Sus controles externos (selector, leyenda, zoom, botones) sí se
# cuentan.
REJILLA = {
    (_P + 'widgets/bay_plan_view.dart', 1231): '_ReservedCell: celda reservada de la rejilla',
    (_P + 'widgets/bay_plan_view.dart', 1642): '_ContainerCell: celda de contenedor de la rejilla',
    (_P + 'widgets/loading_controls.dart', 972): 'LoadingCell: celda del modo Carga en la rejilla',
    (_P + 'widgets/plan_drag_confirmation.dart', 215): 'PlanDragCell: pulsación larga sin sesión sobre una celda',
    (_P + 'widgets/plan_drag_confirmation.dart', 220): 'PlanDragCell: arrastre de una celda',
    (_P + 'widgets/plan_drag_confirmation.dart', 243): 'PlanDragCell: destino de arrastre de una celda',
}

# Constructores encontrados que no son controles interactivos.
NO_INTERACTIVOS = {
    (_P + 'pages/voyage_comparison_page.dart', 243): 'ListTile sin onTap (fila de la lista)',
    (_P + 'pages/voyage_comparison_page.dart', 298): 'ListTile sin onTap (fila de la lista)',
    (_P + 'pages/vessel_overview_page.dart', 115): 'ListTile dentro de PopupMenuItem: el control es el PopupMenuItem',
    (_P + 'pages/vessel_overview_page.dart', 123): 'ListTile dentro de PopupMenuItem: el control es el PopupMenuItem',
    (_P + 'pages/vessel_overview_page.dart', 131): 'ListTile dentro de PopupMenuItem: el control es el PopupMenuItem',
}

# Controles que el framework construye sin un constructor propio en lib/.
IMPLICITOS = [
    ('S05', 'BackButton de AppBar', 'recent_voyages_page.dart:78'),
    ('S06', 'BackButton de AppBar', 'vessel_profiles_page.dart:15'),
    ('S07', 'BackButton de AppBar', 'parameters_page.dart:18'),
    ('S08', 'BackButton de AppBar', 'privacy_policy_page.dart:22'),
    ('S10', 'BackButton de AppBar', 'hatch_covers_page.dart:155'),
    ('S11', 'BackButton de AppBar', 'stowage_alerts_page.dart:36'),
    ('S12', 'BackButton de AppBar', 'export_list_import_page.dart:123'),
    ('S13', 'BackButton de AppBar', 'departure_baplie_page.dart:74'),
    ('S14', 'BackButton de AppBar', 'voyage_comparison_page.dart:101'),
    ('S15', 'BackButton de AppBar', 'discharge_sequence_page.dart:39'),
    ('S16', 'BackButton de AppBar', 'operation_progress_page.dart:21'),
    ('S17', 'BackButton de AppBar', 'hatch_operation_controls.dart:80'),
    ('S18', 'BackButton de AppBar (bandeja y formulario)', 'change_requests_page.dart:100 y :300'),
    ('S19', 'BackButton de AppBar', 'cloud_page.dart:66'),
    ('S04', 'Campo de búsqueda de SearchDelegate (tema de appBarTheme con colorScheme)',
     'container_search_delegate.dart:22'),
    ('S02', 'Selector de fecha de showDatePicker (botones y calendario del framework)',
     'loading_controls.dart:660'),
]

# Juicios que la lectura agrega a la regla automática de color.
OBSERVACIONES = {
    (_P + 'widgets/plan_drag_confirmation.dart', 114):
        'dentro de Material(color: colorScheme.surfaceContainerLow)',
    (_P + 'widgets/voyage_summary_card.dart', 345):
        'dentro de Material(color: scheme.errorContainer)',
    (_P + 'pages/stowage_alerts_page.dart', 73):
        'Card(color: Color.alphaBlend(colors.primary…, colors.surface)): mezcla de colores del esquema',
}

# Colores que salen de una variable o de un método auxiliar, resueltos leyendo
# el código (la regla automática solo ve el tramo del constructor).
RESUELTOS = {
    (_P + 'widgets/bay_plan_view.dart', 396):
        ('sí', 'color recibido del llamador: scheme.secondaryContainer, surfaceContainerHighest, '
               'errorContainer, primaryContainer, tertiaryContainer, surface, surfaceContainerHigh y '
               'surfaceContainerLow (líneas 335-363); borde onSurface/outline del esquema'),
    (_P + 'widgets/containers_list_view.dart', 59):
        ('sí', 'typeColor y statusColor salen de _getTypeColor y _getStatusColor con colorScheme '
               '(líneas 349-387); borde outlineVariant'),
    (_P + 'widgets/container_search_delegate.dart', 347):
        ('no', 'leading: _buildLeadingIcon usa Colors.red, Colors.cyan, Colors.green y Colors.orange '
               '(líneas 428-437) para el avatar; _buildHighlightedText resalta con '
               'Colors.yellow.withValues(alpha: 0.4) (línea 470)'),
}

COLOR_ARG = re.compile(
    r'\b(color|backgroundColor|foregroundColor|selectedColor|iconColor|textColor|'
    r'surfaceTintColor|checkColor|activeColor|fillColor|shadowColor|overlayColor|'
    r'valueColor|disabledColor|focusColor|hoverColor|splashColor|highlightColor|'
    r'selectedTileColor|tileColor|collapsedIconColor|collapsedBackgroundColor)\s*:')
FIJO = re.compile(r'\bColors\.(?!transparent\b)\w+|\bColor\s*\(\s*0x|\bColor\.fromARGB|\bColor\.fromRGBO')
TRANSPARENTE = re.compile(r'\bColors\.transparent\b')
ESQUEMA = re.compile(r'colorScheme|\bscheme\.|\bcolors\.|\bcs\.|Theme\.of\(context\)\.colorScheme')


def _pantalla(rel, linea):
    tabla = PANTALLA_DE.get(rel)
    if tabla is None:
        return None
    for clave, valor in tabla.items():
        if isinstance(clave, tuple) and clave[0] <= linea <= clave[1]:
            return valor
    return tabla.get('*')


def _tramo(m, abre):
    cierra = None
    for k, v in m.par.items():
        if v == abre:
            cierra = k
            break
    return m[abre:cierra + 1] if cierra is not None else m[abre:abre + 400]


def colores(tramo):
    """Expresiones de color del tramo y su origen."""
    out = []
    for mt in COLOR_ARG.finditer(tramo):
        expr = tramo[mt.end():mt.end() + 160]
        expr = re.split(r',\s*\n|\)\s*,|\n\s*\)', expr)[0].strip()
        if FIJO.search(expr):
            origen = 'fijo'
        elif TRANSPARENTE.search(expr):
            origen = 'transparente'
        elif ESQUEMA.search(expr):
            origen = 'esquema'
        else:
            origen = 'variable'
        out.append((mt.group(1), ' '.join(expr.split())[:90], origen))
    for mt in FIJO.finditer(tramo):
        ventana = tramo[max(0, mt.start() - 60):mt.start()]
        if not COLOR_ARG.search(ventana):
            out.append(('(expresión)', ' '.join(tramo[max(0, mt.start() - 30):mt.end() + 20].split()), 'fijo'))
    return out


def controles(root, rel):
    """Apariciones de constructores de control en un archivo."""
    src = leer(root / rel)
    lx = Lexer(src).run()
    m = masked(src, lx)
    codex = {mt.start() for mt in CODEX_CONTROLS.finditer(m)}
    filas = []
    for mt in COMPLETO.finditer(m):
        nombre = re.match(r'[\w.]+', mt.group()).group()
        linea = m.count('\n', 0, mt.start()) + 1
        abre = mt.end() - 1
        tramo = _tramo(m, abre)
        filas.append({'archivo': rel, 'linea': linea, 'control': nombre,
                      'origen': 'candidato Codex' if mt.start() in codex else 'agregado',
                      'tramo': tramo})
    return filas


def clasificar(fila):
    rel, linea, nombre = fila['archivo'], fila['linea'], fila['control']
    if (rel, linea) in REJILLA:
        return dict(fila, incluido='no', motivo='rejilla (2.4 a): ' + REJILLA[(rel, linea)],
                    material='', color='', excepcion='')
    if (rel, linea) in NO_INTERACTIVOS:
        return dict(fila, incluido='no', motivo=NO_INTERACTIVOS[(rel, linea)],
                    material='', color='', excepcion='')
    if nombre in NO_CONTROLES:
        return dict(fila, incluido='no', motivo='no es un control', material='', color='', excepcion='')
    if nombre.endswith('.styleFrom'):
        return dict(fila, incluido='no', motivo='no es un control: fábrica de estilo (el patrón de Codex la cuenta)',
                    material='', color='', excepcion='')
    material = 'no' if nombre in ('GestureDetector', 'Draggable', 'DragTarget', 'LongPressDraggable') else 'sí'
    cols = colores(fila['tramo'])
    origenes = {c[2] for c in cols}
    if 'fijo' in origenes:
        color = 'no: ' + '; '.join(f'{c[0]} {c[1]}' for c in cols if c[2] == 'fijo')
    elif 'variable' in origenes:
        color = 'revisar: ' + '; '.join(f'{c[0]} {c[1]}' for c in cols if c[2] == 'variable')
    elif cols:
        color = 'sí: ' + '; '.join(sorted({c[2] for c in cols}))
    else:
        color = 'sí: tema (sin color propio)'
    nota = OBSERVACIONES.get((rel, linea), '')
    resuelto = RESUELTOS.get((rel, linea))
    if resuelto is not None:
        color = f'{resuelto[0]}: {resuelto[1]}'
    exc = 'sí' if material == 'no' or color.startswith('no') else ''
    return dict(fila, incluido='sí', motivo=nota, material=material, color=color, excepcion=exc)
