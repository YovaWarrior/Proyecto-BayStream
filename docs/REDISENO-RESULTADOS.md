# Rediseño visual · Resultados

Timonel (Claude Code, Fable 5.1). Rama `sprint-4` (worktree de `master` con el código
de v3.0, HEAD `063d2ae`). Una sección por fase: lo hecho, las validaciones, los
archivos, lo que no se pudo y por qué, y las horas. Las evidencias sintéticas van en
`docs/rediseno/`. Nada de lo que sigue toca `lib/`, `test/` ni `pubspec.*`.

## Fase 0 · Inventario (21-oct-2026)

### 0.1 Resultado en tres líneas

- Leí las reglas, el sprint, el manual con sus 103 capturas, los RNF que fallan por la
  interfaz, la marca, el tema y los 36 archivos de pantallas y widgets de
  `presentation/` (13 849 líneas; 15 296 con providers y formatters).
- La interfaz de hoy es Material 3 de fábrica: un `ColorScheme.fromSeed` y ningún
  token. Lo que el tutor vio pobre y lo que los RNF miden como «no cumple» salen de
  seis causas de raíz (0.5), todas en la capa de presentación.
- Tres cosas que no están como el prompt las describe: `flutter-mcp` y `maestro` no
  conectan en esta sesión, el script de `flutter-ui` vive en otra ruta y en
  `presentation/` hay 28 colores a mano (no 18), más tres formas de color calculado
  que el conteo literal no ve (0.7).

### 0.2 Base, aislamiento y lo que no se corrió

- Rama `sprint-4`, HEAD `063d2ae` («Sprint 3: decisiones 10.111 a 10.113…»). El árbol
  trae tres archivos generados de `windows/flutter/` con cambios de fin de línea
  (`git diff --stat` solo avisa CRLF); no son míos, no se tocan y no van en el bloque
  de Git.
- **No corrí ningún comando de Flutter**: la Fase 0 no toca `lib/` y el semáforo lo da
  Carlos. El piso vigente es el documentado: **1063/1063** y `analyze` en cero (10.94,
  10.96). Lo que sí corrí: Python (la auditoría de `flutter-ui` y `search.py` de
  `ui-ux-pro-max`) y lecturas con `grep`.
- No se abrió ningún cliente, ni el Honor, ni Firebase, ni el corpus real.
- `AGENTS.md` y `CLAUDE.md` siguen diciendo «rama `sprint-3`» y «`SPRINT-3.md`
  vigente»; no existe `SPRINT-4.md`. Trabajo en `sprint-4` porque lo manda el prompt
  de Carlos (la solicitud actual prevalece), y lo anoto para Yov, que mantiene esos
  tres archivos.

### 0.3 Skills y MCP: qué detecto y qué uso en cada fase

El catálogo está duplicado en `~/.agents/skills` y `~/.claude/skills` (69 carpetas
iguales). Todas las que pide el prompt existen. Una salvedad: **`flutter-ui` está
anidada** en `~/.agents/skills/flutter-ui/flutter-ui/` (su `SKILL.md`, ocho archivos
de referencia y `scripts/flutter_ui_audit.py`), así que no aparece en el catálogo del
Skill tool y la ruta del prompt (`~/.agents/skills/flutter-ui/scripts/…`) no existe.
La uso leyendo sus archivos y corriendo el script por su ruta real.

| Skill | Detectada | Fases | Cómo se usa |
|---|---|---|---|
| frontend-design | Sí | F1 (plan), F2 y F3 (código) | Dirección estética en dos pasadas; su código web se traduce a Flutter |
| ui-ux-pro-max | Sí | F1 | `search.py --design-system`, `--domain style/color/typography/ux` y `--stack flutter` (53 reglas en `data/stacks/flutter.csv`). Corre con `python`, no con `python -I` (no encuentra `core.py`) |
| design, design-system, ui-styling, brand | Sí | F1 (tokens en tres capas, identidad), F2 (ThemeExtension) | Solo la jerarquía de tokens y el modo oscuro; se descartan sus salidas CSS, Tailwind y shadcn web |
| interface-design | Sí | F1 a F3 | Coherencia entre pantallas; si exige `.interface-design/system.md`, ahí van solo las medidas de DESIGN.md |
| flutter-ui | Sí (anidada) | F0 (línea base), F2 y F3 | Reglas de rendimiento en el código nuevo y auditoría al cierre de cada entrega |
| flutter-build-responsive-layout, flutter-fix-layout-issues | Sí | F2 y F3 | 360 dp, 600 dp, 1920 px y letra 2.0 sin desbordes |
| flutter-apply-architecture-best-practices | Sí | F2 | Ordenar `presentation/` y `lib/core/design/` |
| dart-use-pattern-matching | Sí | F2 y F3 | Sealed classes para los estados de interfaz (0.6, providers) |
| dart-run-static-analysis | Sí | F2 y F3 | `analyze` en cero en cada entrega |
| flutter-add-widget-test, flutter-add-widget-preview, flutter-add-integration-test, dart-write-documentation, dart-add-unit-test | Sí | F2 (cada componente con prueba, vista previa y doc) y F3 | RNF-005 está en 59 %: lo nuevo nace documentado |
| shadcn-flutter | Sí | F1, solo referencia | No se adopta: dependencia nueva y saca la app de Material 3 (criterio de RNF-002) |
| flutter-setup-declarative-routing (GoRouter) | Sí | F1 decide | Hoy la navegación es Navigator 1.0 (86 `push`/`pop` en 11 archivos). Barra inferior y riel no lo necesitan; se propone solo si el enlace profundo de la Web lo pide |
| dataviz-orchestrator, -selector, -color, -precision, -critique (más dataviz, dataviz-eval y dataviz-fix) | Sí | F1 y F3 | Estadísticas y avance en la oficina |
| web-design-guidelines, webapp-testing | Sí | F3 | Cliente Web: foco visible, reducción de movimiento, capturas |
| writing-guidelines | Sí | F1 | Reglas de texto de DESIGN.md |
| karthik-table-style, chart-annotations, chart-explainer | Sí | Opcionales en F3 | Tablas de avance con cifras tabulares |
| formato-entregables (del proyecto) | Sí | No aplica | Es la skill de Word de Carlos y Yov |
| vercel-*, deploy-to-vercel, microsoft-foundry, report-skills, slides, banner-design, dart-*-ffi*, dart-build-cli-app | Sí | No aplican | — |

| MCP | Estado en esta sesión | Fases previstas | Mientras no conecte |
|---|---|---|---|
| flutter-mcp (Dart MCP) | **No conectó** (`CONNECTION_CLOSED`); `ToolSearch` no devuelve sus herramientas | F2 y F3: `analyze`, pruebas, recarga en caliente, árbol de widgets | La CLI (`flutter analyze`, `flutter test`) bajo el semáforo de Carlos |
| maestro | **No conectó** (`CONNECTION_CLOSED`) | F3: recorridos y capturas repetibles en el emulador API 26 con el cliente `r4`, flujos en `tool/rediseno/maestro/` | Los instrumentos de T-99 y T-100 (`tool/t100_windows.ps1`, `tool/honor19_capturas.py`, `tool/t98_honor_ui.py`) |
| Navegador integrado y Claude in Chrome | Disponibles | F3: el cliente Web | — |

Los dos MCP fallaron al arrancar la sesión; no toqué su configuración. **Carlos:** antes
de la Fase 2 conviene revisar por qué no levantan (la sesión los declara configurados).

### 0.4 Mapa de pantallas y recorridos, con las capturas del manual

Las pantallas llevan el número del censo de T-98 (tabla M-2). Las capturas son las de
`docs/manual/` (`w` = Windows 1920×1080, `h` = Honor 360 dp), todas sintéticas.

| # | Pantalla | Archivos | Capturas | Observaciones de mapa |
|---|---|---|---|---|
| S01 | Inicio, barra superior, pestañas y Lista | `pages/vessel_overview_page.dart`, `widgets/empty_state_widget.dart`, `widgets/voyage_summary_card.dart`, `widgets/containers_list_view.dart`, `widgets/reserved_slots_list_view.dart`, `widgets/sync_status_chip.dart`, `widgets/voyage_call_summary.dart` | w00-inicio, w00-inicio-claro, h00-inicio, h00-inicio-letra-grande, w06-lista, w06-lista-buque-prueba, h06-lista, h06-lista-botones, w08-lista-llegada, w10-exportar-menu, h10-exportar-menu, w10-exportacion-csv, w12-error-no-es-baplie, w12-error-version-no-admitida | El inicio es un estado vacío con un botón y un FAB que repiten la misma acción; la Lista es la pestaña por defecto |
| S02 | Plano por bahía: cabecera, selector, rejilla, leyenda, zoom, hojas de detalle, modos Carga y Descarga, arrastre | `widgets/bay_plan_view.dart`, `widgets/loading_plan_controls.dart`, `widgets/loading_controls.dart`, `widgets/discharge_controls.dart`, `widgets/plan_drag_confirmation.dart`, `widgets/reserved_slot_details.dart`, `widgets/office_plan_controls.dart`, `widgets/hatch_cover_diagram.dart`, `widgets/detail_text_row.dart`, `widgets/voice_search_field.dart` | w05-plano-bahia02, w05-plano-bahia01-sombras, w05-plano-cubierta, w05-plano-detalle-celda, w05-plano-zoom-150, h05-plano, h05-plano-letra-grande, w11-plano-tema-claro, h11-plano-claro, w08-plano-modo-carga, h08-plano-modo-carga, h08-acciones-menu, w08-plano-modo-descarga, h08-plano-modo-descarga, w08-descargado-snackbar, h08-descargado, w08-reestiba-dialogo, w08-reestiba-snackbar, w08-plano-numero-orden, w08-plano-carga-con-or, h08-plano-carga-or, w08-selector-or, w08-selector-or-filtrado, h08-selector-or, w08-confirmar-carga, h08-confirmar-carga, w08-carga-registrada, w08-vacios-del-listado, w08-asignar-vacio, w08-pendientes-por-bahia, w08-pendientes-descarga, h08-pendientes-descarga, w06-buscador-resaltado, h06-buscador-resaltado | La pantalla protagonista. El muelle de carga y descarga **no es una pantalla aparte**: son dos modos del plano (`BayPlanMode.loading` y `.discharge`) elegidos en un desplegable |
| S03 | Estadísticas | `widgets/voyage_stats_view.dart`, `widgets/vessel_profile_view.dart` | w07-estadisticas-arriba, w07-estadisticas-abajo, h07-estadisticas | Tarjetas, donut, barras y el perfil longitudinal |
| S04 | Buscar contenedor | `widgets/container_search_delegate.dart` | w06-buscador-vacio, w06-buscador-resultados, h06-buscador-vacio, h06-buscador-resultados | `SearchDelegate` de Material 2 |
| S05 | Viajes recientes | `pages/recent_voyages_page.dart` | w03-viajes-recientes, h03-viajes-recientes | Solo desde la barra superior |
| S06 | Perfiles guardados | `pages/vessel_profiles_page.dart` | w04-perfiles-guardados | — |
| S07 | Parámetros (ajustes del dispositivo) | `pages/parameters_page.dart` | w11-parametros, w11-tema-claro, h11-parametros, h11-tema-menu, h11-tema-claro | Tema, política y acceso al perfil del buque |
| S08 | Política de privacidad | `pages/privacy_policy_page.dart` | h13-privacidad | — |
| S09 | Parámetros del buque (geometría, escala, límite, tomas, tapas) | `pages/vessel_geometry_page.dart` | w04-perfil-buque-nuevo, w04-parametros-arriba, w04-parametros-abajo, w04-parametros-no-lo-tengo, w04-limite-apilamiento, w04-escala-llegada, w04-escala-carga, h04-escala-llegada, h04-parametros-arriba, h04-parametros-abajo, h04-parametros-no-lo-tengo, wA-editar-perfil, wA-frontera-anclas, wA-niveles-agregar, wA-rejilla-resultante, wA-agregar-tomas, wA-tomas-declarar | El paso obligatorio antes del primer plano |
| S10 | Tapas de escotilla (declaración) | `pages/hatch_covers_page.dart` | wA-tapas-escotilla, wA-copiar-tapas | — |
| S11 | Alertas de estiba | `pages/stowage_alerts_page.dart` | w07-alertas-estiba, h07-alertas | — |
| S12 | Listado de la agencia | `pages/export_list_import_page.dart` | w08-listado-agencia-vacio, w08-listado-escala-leido, w08-listado-importado, h08-listado-leido, h08-listado-importado, w08-listado-agencia-leido, w08-listado-agencia-cruce | — |
| S13 | BAPLIE de salida | `pages/departure_baplie_page.dart` | w08-baplie-salida-escala, w08-baplie-salida, w08-exportacion-baplie-completada | — |
| S14 | Comparar BAPLIE | `pages/voyage_comparison_page.dart` | w08-comparar-baplie, w08-comparar-llegada-salida | Buen modelo de lista densa |
| S15 | Orden de descarga | `pages/discharge_sequence_page.dart` | w08-orden-descarga, h08-orden-descarga | Buen modelo de lista operativa |
| S16 | Avance de la operación | `pages/operation_progress_page.dart` | w08-avance-operacion, w08-avance-completo, w08-avance-descarga | La pantalla de la oficina; hoy es una tabla de conteos |
| S17 | Tapas en la operación | `widgets/hatch_operation_controls.dart` | w08-tapas-operacion | — |
| S18 | Solicitudes de cambio, Bandeja y Pedir cambio / Mover | `pages/change_requests_page.dart` | Sin captura (exigen cuenta; comprobadas en T-105 y T-106) | — |
| S19 | Nube y cuenta | `pages/cloud_page.dart` | Sin captura (por política) | — |
| — | Segregación IMDG | `pages/segregation_page.dart` | Sin captura | Sin entrada desde la interfaz (10.89) |

**Recorridos** (lo que el planificador hace, contado en toques; el desplazamiento no cuenta):

| # | Recorrido | Pasos hoy | Dónde está |
|---|---|---|---|
| R1 | Primera visualización sin perfil | **6**: icono → «Seleccionar archivo» → selector del sistema → «No lo tengo» → «Confirmar y ver el plano» → pestaña «Plano» (T-98: Honor ≈ 29 s, Web ≈ 5.5 s). Con perfil, 4 | S01 → S09 → S01 (Lista) → S02 |
| R2 | Descarga en el muelle | Plano → «Contenido» → «Descarga» → tocar «BAJA» → aviso con «Deshacer» (6 s) | S02 (`discharge_controls.dart`) |
| R3 | Carga por OR | Plano → «Contenido» → «Carga» → tocar la celda o «OR / últimos dígitos» → selector → diálogo «Confirmar carga» (hasta 9 campos) → «Confirmar carga» | S02 (`loading_controls.dart`) |
| R4 | Avance en la oficina | Plano → «Avance de la operación» (botón o menú «Acciones») → tabla | S16 |
| R5 | Estadísticas → bahía | Pestaña «Estadísticas» → perfil longitudinal → tocar bahía → Plano | S03 → S02 |
| R6 | Buscar un contenedor | Lupa → escribir → tocar el resultado → Plano con la celda resaltada | S04 → S02 |
| R7 | Exportar | Flecha → PDF, CSV o JSON → diálogo del sistema → aviso | S01 |
| R8 | Listado de la agencia | Lista → «Listado de la agencia» → «Elegir listado (.xlsx)» → equivalencias → «Confirmar e importar» | S01 → S12 |
| R9 | Nube | Icono o chip de nube → sesión → «Publicar operación» / «Unirse» | S19 |

### 0.5 Las seis causas de raíz

1. **Tema sin tokens.** `lib/core/app.dart` (51 líneas) es `ColorScheme.fromSeed(0xFF0D47A1)`
   en claro y oscuro, `useMaterial3` y una `AppBarTheme`; sin `textTheme`, sin
   `ThemeExtension`, sin familia tipográfica declarada (`assets/fonts/Roboto-*.ttf` solo
   los usa el PDF). Por eso cada widget trae lo suyo: 84 `TextStyle(` a mano, 46
   `fontSize:` literales, 55 `FontWeight.bold`, unas 40 combinaciones distintas de
   `EdgeInsets` y diez radios. Nada se ve «de BayStream».
2. **Roles de color sobrecargados.** En la rejilla el mismo rol significa cosas distintas
   (`primaryContainer` = refrigerado, pendiente de descarga y número de orden;
   `tertiaryContainer` = OOG y resaltado; `secondaryContainer` = lleno y re‑estiba), y en
   Estadísticas hay 27 `Colors.*` en arcoíris. No existe el color por puerto de descarga
   del plano impreso. Hace falta una `ThemeExtension` semántica.
3. **Trazado calculado a mano.** Alturas con `textScaler × constante`, `TextPainter`
   para decidir si apilar, anchos fijos (480, 400, 320, 520, 108), celda de 50×40 y el
   botón de zoom posicionado encima de la rejilla. De ahí salen los cortes de 360 y
   600 dp, el «100 %» sobre el título, la leyenda que corta «Refrigerado» y la barra de
   pestañas que se desplaza a 2.0.
4. **Navegación plana.** Ocho acciones en la barra superior sin prioridad, tres
   pestañas con la Lista primero, las acciones de la operación como `TextButton.icon`
   dentro de la Lista, los modos del muelle en un desplegable y ninguna barra inferior
   ni riel. «Confirmar y ver el plano» cae en la Lista.
5. **Rendimiento de la capa de presentación.** La Lista construye todas sus tarjetas
   (`shrinkWrap`, RAM de 466 MB con A01), la rejilla es un árbol de `Container` por
   celda sin `RepaintBoundary` (117–286 ms por bahía en el Honor), un `Opacity` por
   celda atenuada y un `GridView.count` con `shrinkWrap` en Estadísticas.
6. **Texto sin sistema.** Mayúsculas sostenidas («LLENO», «▲ CUBIERTA», «CARGA
   PELIGROSA - IMO», «TOTAL»), títulos en *title case* («Total Contenedores», «Peso
   Total»), «N/A», usted y tú mezclados («Seleccione…» frente a «Toca…»), dos unidades
   para el mismo peso («416.8 ton» y «2.2 t»), y tres hojas de detalle distintas para el
   mismo contenedor.

### 0.6 Problemas por pantalla, con archivo y línea

Rutas relativas a `lib/features/vessel/presentation/`. Cada punto dice qué hay y qué
efecto tiene; lo que ya está en la lista del Sprint 4 lleva su decisión entre
paréntesis.

**S01 · Inicio y Lista**

- `pages/vessel_overview_page.dart:76-167`: ocho acciones en la barra (recientes,
  perfiles, nube, buscar, exportar, parámetros, cargar, limpiar) sin prioridad; `:181-191`
  el ancho del tramo se calcula con números mágicos (160, 112, 48, 56) y va en un
  `SingleChildScrollView` horizontal: a 360 dp quedan 72 px de acciones fuera del borde
  sin ninguna señal (manual, hallazgo 3; T-99 B.8).
- `:73-74` alto de pestaña calculado a mano; con letra 2.0 la barra de pestañas se
  desplaza (10.89). `:211-223` tres pestañas con la Lista primera; `_askForGeometry`
  (`:536-704`) no cambia de pestaña al confirmar, por eso «Confirmar y ver el plano»
  cae en la Lista (10.97; ver 0.9).
- `:172-175` el título «BayStream» en `FittedBox` se encoge en vez de ceder sitio.
- `:269` y `:294-303`: el estado vacío y un FAB extendido repiten «cargar BAPLIE»; a
  360 dp con letra 1.45 el FAB tapa «Seleccionar archivo» (manual,
  `h00-inicio-letra-grande`; T-98 `con01` lo detectó como texto duplicado).
- `:355-361` SnackBar «Generando reporte PDF...» de dos minutos; `:463-474` los
  SnackBar son el único feedback de carga.
- `:413-443`, `:483-513`, `:555-575`: `AlertDialog` con `width: 480` fijo.
- `:707-856` la pestaña Lista es un `SingleChildScrollView` con una `Column`: tarjeta,
  `Wrap` de cinco `TextButton.icon` (las acciones de la operación con el botón menos
  visible de Material), reservas, chips de naviera en scroll horizontal sin señal,
  «Contenedores (N)» y la lista. `:852` `ContainersListView` con `shrinkWrap`.
- `:859-876` chip propio con `withValues(alpha: .1/.5)` y `fontSize: 12`.
- `:5-6` importa `data/` (exportación y PDF): dos de las 11 violaciones de capa (T-99).
- `widgets/empty_state_widget.dart:18-21`: reserva 128 dp de padding inferior para el
  FAB (parche); `:51-56` «Gestión de Carga Marítima» en *title case*; `:85` «Seleccione…»
  (usted) cuando el resto de la app tutea; `:60-107` tarjeta con alfa .5 a mano. El
  inicio no ofrece los viajes recientes ni los perfiles: la primera visualización
  depende de la barra.
- `widgets/voyage_summary_card.dart:26-34`: `Card` con `primaryContainer` α .3 y borde
  `primary` α .2; `:129-184` `TextPainter` para decidir el apilado con las etiquetas
  escritas dos veces (`:150` frente a `:163`, `:171`, `:179`; T-111); `:186-194`
  «N contenedores · …» sin singular (10.91); `:222-235` «Mensaje: N/A» y «Tipo:» (metadatos
  técnicos en la tarjeta principal); `:319-404` todo aviso de lectura va en
  `errorContainer`, sin grados; `:179` «Peso Total».
- `widgets/containers_list_view.dart:26-28`: `ListView.builder` con `shrinkWrap: true`
  y `NeverScrollableScrollPhysics` dentro del scroll de la pestaña: la causa de los
  466 MB (10.97). Cada tarjeta mide unos 160 dp: en 1920×1080 caben cinco de 977
  (densidad baja para la oficina). `:137-190` y `:260-273` IMO y Refrigerado aparecen dos
  veces en la misma tarjeta; `:192-207` chip de estado propio «LLENO / VACÍO / N/A»;
  `:349-387` colores por estado y tipo con `primary/secondary/tertiary` sin semántica;
  `:407-524` una segunda hoja de detalle distinta de la del plano («MERCANCÍA
  PELIGROSA» aquí, «CARGA PELIGROSA - IMO» allá); `:102`, `:443` `fontFamily: 'monospace'`
  (no es una fuente empaquetada); «N/A» ocho veces; «Puerto Carga», «Puerto Descarga».
- `widgets/sync_status_chip.dart:19-51`: el `ActionChip` lleva textos de hasta 90
  caracteres («Tu cuenta no está autorizada · 3 esperan · pide al responsable…») en la
  cabecera del plano; a 360 dp se corta. Icono, texto y color de error: bien.
- Correctos y reutilizables: `widgets/detail_text_row.dart` (apila por ancho y escala),
  `widgets/reserved_slots_list_view.dart`, `widgets/voyage_call_summary.dart`.

**S02 · Plano por bahía**

- `widgets/bay_plan_view.dart:221-317` selector de bahías: alto a mano desde
  `textScaler` (`:226-227`); `FilterChip` con una `Column` de dos textos (`fontSize` 12
  y 10, `:278-288`) dentro de un `FittedBox`; las flechas (`:232-242`, `:303-313`)
  desplazan 200 px, no una bahía; «sin geometria» (`:266`) sin tilde.
- `:319-368` leyenda: `Row` centrada en un `SingleChildScrollView` horizontal, sin
  `Wrap`: a 360 dp corta «Refrigerado» y a 600 «Ocupado» (T-99 B.8, 10.94). Cada ítem es
  un `InkWell` de unos 24 dp de alto (`:404-405`): objetivo táctil menor de 48; el
  filtro activo se señala con negrita y subrayado (`:425-428`).
- `:436-575` hoja de detalle: `fontFamily: 'monospace'` (`:476`); «LLENO», «VACÍO»
  (`:502-503`), «CARGA PELIGROSA - IMO» (`:522`), «REFRIGERADO:» (`:545`) en mayúsculas;
  «N/A» (`:500-512`).
- `:583-1207` la rejilla es una `Column` de `Row` de `Container`: celda fija de 50×40
  (`:1236-1237`, `:1376-1377`, `:1402-1403`, `:1535-1536`), columna de 54 (`:816`),
  etiqueta de nivel de 40 y columna de peso de 88 (`:584-585`); sin `RepaintBoundary` y
  sin `CustomPainter`. Con 23 columnas y 8 niveles son más de mil widgets por bahía:
  117 ms (A01) y 286 ms (5000) por bahía en el Honor (T-99 B.6).
- Tipografía literal en la rejilla: título `titleLarge` en negrita (`:729`); «▲ CUBIERTA»
  y «▼ BODEGA» a 11 (`:785-791`, `:829-835`); pesos de pila a 9 (`:1001`, `:1024`); filas
  y niveles a 12 (`:1051`, `:1086`); celdas a 10, 8 y 9 (`:1608`, `:1620`, `:1633`); número
  de orden a 18 (`:1591`); marca de descarga a 9 (`:1570`); reservas a 9, 8, 10 y 9
  (`:1256-1277`).
- `:736` «416.8 ton» y `:1196` «2.2 t»: dos unidades para el mismo peso.
- `:1429-1533` roles de color sobrecargados (causa 2): peligrosa `errorContainer`,
  refrigerado `primaryContainer`, OOG `tertiaryContainer`, lleno `secondaryContainer`,
  vacío `surfaceContainerHighest`, desconocido `surfaceContainerLow`, de paso `surface`,
  número de orden `primaryContainer`, pendiente de descarga `primaryContainer` (choca
  con refrigerado), re‑estiba `secondaryContainer` (choca con lleno), resaltado
  `tertiaryContainer` (choca con OOG). Sin color por puerto de descarga.
- `:1644-1650` un `Opacity(0.25)` por celda atenuada (una capa de composición por
  celda); `:1559-1581` `Semantics` solo en las celdas con marca o número de orden: la
  celda normal es un `GestureDetector` sin etiqueta, y además mide 50×40 dp.
- `:1289-1311` `_RevealPosition` espera 350 ms y desplaza 200 ms más.
- `:853-871`, `:945-946` avisos con `maxWidth: 520` fijo; `:709-717` diagrama de tapas
  compacto bajo 600 dp.
- `widgets/loading_plan_controls.dart:121-141`: `DropdownButton` clásico (no el
  `DropdownMenu` de M3) con «Contenido · Número de orden · Descarga · Carga»: mezcla
  qué se ve con qué se opera. `:81-109` en pantallas anchas, un `Wrap` de
  `TextButton.icon`, el chip de nube y el de solicitudes; `:193-202` el resumen de
  pendientes es una sola `Text` larga que se corta con «…» a 360 dp (manual, hallazgo
  4); `:290-401` `_CompactPlanBar` con `IntrinsicWidth` (`:386`), un `PopupMenuButton`
  «Acciones» con `Badge` y el texto en `primary` a mano (`:379`); `:204-283` tabla de
  pendientes en un `showModalBottomSheet` al 80 % con `DataTable`.
- `widgets/plan_drag_confirmation.dart:105-118`: el botón «100 %» va `Positioned` arriba
  a la derecha, encima de la rejilla: tapa el título a 360 y 600 dp (T-99 B.8, 10.97).
  `:58-104` el zoom con `Listener` + `OverflowBox` + `Transform.scale` está bien
  resuelto (GPU). `:275-277` los colores de la previsualización salen de
  `HSLColor.fromColor(primary).withHue(45 / 140)`: color calculado fuera del esquema,
  invisible para el conteo de `Colors.*`. `:318-346` `_CellBorder` es un `CustomPainter`
  sin `RepaintBoundary`. La hoja de confirmación (`:423-487`) trae `PopScope` y
  `ActionChip` de motivos: bien.
- `widgets/reserved_slot_details.dart:138-156`: una tercera variante de fila de
  detalle (etiqueta de 108 px fijos) en vez de `DetailTextRow`; `:62` `'monospace'`.
- `widgets/hatch_cover_diagram.dart:59-73`: celdas de 28 dp, `fontSize: 10` y alfa
  escalonado `0.05 + 0.07·i` sobre `onSurface`.
- `widgets/office_plan_controls.dart` y `widgets/hatch_operation_controls.dart`:
  correctos; «PROVISIONAL ·» en mayúsculas (`hatch_operation_controls.dart:97`).

**S02 · Muelle: Carga y Descarga (modos del plano)**

- `widgets/loading_controls.dart:65-80`: el resumen son tres o cuatro `Text` planas;
  `:81-110` «OR / últimos dígitos» y «Asignar vacío», las acciones principales del
  muelle, son `TextButton.icon`. `:122-202` `PlanSummaryLine` mide una línea con
  `TextPainter` y recorta con `OverflowBox` + `ClipRect`: funciona, pero es frágil.
  `:247-333` el selector por OR es un `showModalBottomSheet` al 80 % con `ListTile`.
  `:538-539` el diálogo «Confirmar carga» mide `width: 400` fijo y lleva hasta nueve
  campos (OR, tipo, posición, celda, reservas, interruptor de grupos, revisión, hora,
  fecha como `TextButton` «Fecha: 21/10/2026» en `:672-673`, marchamo, motivo): a 360
  dp es un diálogo largo con scroll. El botón principal dice lo que hace (`:728-734`):
  bien. `:746-789` `_LoadCheckPanel` con icono, texto y color: bien.
- `widgets/loading_controls.dart:939-1015` `LoadingCell`: 50×40 con `InkWell` (menos de
  48 dp), `fontSize` 10 y 8, marcas «SUBE / CARG. / CANC. / REVISAR» en mayúsculas
  abreviadas; `Semantics` completa (`:970-974`): bien.
- `widgets/discharge_controls.dart:198-217`: el registro con un toque se confirma solo
  con un SnackBar de 6 s con «Deshacer»; `:425-441` marcas «BAJA / DESC. / PASO /
  RE‑EST. / CANC. / REVISAR» con icono: bien como señal doble, mal como texto.
  `:444-448` fechas `dd/mm/yyyy hh:mm`.
- `widgets/voice_search_field.dart:171-173`: «Escuchando…» sin ningún indicador
  visual; `:181-182` los fallos del dictado en una `Text` plana.
- T-106 (aceptación, O1): el muelle no ve la revisión antes de enviar una solicitud; la
  oficina sí (`pages/change_requests_page.dart:373-378`, guarda `widget.direct`).

**S03 · Estadísticas**

- `widgets/voyage_stats_view.dart`: 27 `Colors.*` (`:72`, `:85`, `:208-238`, `:348-381`,
  `:507-543`, `:599-656`, `:986`, `:1084`): arcoíris contra la regla monocromática de
  `AGENTS.md`. Títulos en *title case* (`:42-129`). `:190-202` `GridView.count` con
  `shrinkWrap` y `childAspectRatio` calculado con `textScaler` (origen del desborde de
  0.23 dp a 1280 dp, 10.84). `:270-320` tarjetas con el valor en color y borde α .3.
  `:342-363` donut de 120 px con `_PieChartPainter` (`:1125`) sin `RepaintBoundary`.
  `:536-547` barra apilada con texto blanco a 12. `:825-857` las barras horizontales
  son `LinearProgressIndicator` de 20 dp con alfa decreciente por fila (`:750`).
  `:802`, `:843` `'monospace'`. `:922-1113` barras de 22 px en scroll horizontal con el
  número de bahía rotado a 9 (las «cifras del borde» de 10.89), sin ejes ni toque.
  `:884-897` `_StatsLabel` con `Tooltip` y diálogo «Detalle»: bien.
- `widgets/vessel_profile_view.dart`: el perfil longitudinal es el mejor dibujo de la
  app (`CustomPainter`, `Semantics` por bahía, `SegmentedButton`, leyenda monocromática).
  Sin `RepaintBoundary`; celdas de 54×68 y alto 132 fijos (`:26-29`, `:262-266`); textos
  pintados a 10 y 9 (`:334`, `:342`, `:369`, `:376`); «PROA / POPA» en mayúsculas.

**S04 · Buscar contenedor**

- `widgets/container_search_delegate.dart:7-34`: `SearchDelegate` de Material 2 con
  `appBarTheme` propio y `searchFieldStyle: fontSize 16` (`:18`); M3 ofrece `SearchBar`
  y `SearchAnchor`. `:154-184` estado vacío con `primaryContainer` α .3; `:268` «Consejo:
  Escribe…»; `:355` `'monospace'`; `:374-416` `fontSize` 10, 12, 11; `:385` «POD:» como
  etiqueta; `:411` «28.7t» pegado, frente a «28.7 t» en la tarjeta. Los colores ya son
  del esquema (T-112).

**S05 a S08 · Recientes, Perfiles, Parámetros, Política**

- `pages/recent_voyages_page.dart:81-86`: un párrafo explicativo antes de la lista;
  `:103` reutiliza `EmptyStateWidget` y muestra «BayStream / Gestión de Carga Marítima»
  dentro de Recientes; `:35` SnackBar de 10 s.
- `pages/vessel_profiles_page.dart:35`: el subtítulo es la clave interna `imo:…`;
  `:27-29` el estado vacío es un texto sin icono ni acción.
- `pages/parameters_page.dart`: «Parámetros» (ajustes del dispositivo) y «Parámetros
  del buque» (perfil) se llaman casi igual y comparten el icono de regla
  (`Icons.straighten`, `:64` y `vessel_overview_page.dart:142`).
- `pages/privacy_policy_page.dart`: correcta; viñetas como texto «•  » (`:47`).

**S09 y S10 · Parámetros del buque y tapas**

- `pages/vessel_geometry_page.dart:288-432`: un `ListView` con once bloques
  (explicación, tomas, frontera y anclas, filas, fila 00 ×2, niveles ×2, puerto, límite,
  tomas, tapas, rejilla, confirmar). La decisión más importante, el puerto de la escala
  (`:903-999`), va en sexto lugar en una `Card` igual a las demás; «Confirmar y ver el
  plano» (`:410-415`) está al final de una página larga y «Cancelar la carga» debajo
  como `TextButton`. `:726-747` `DropdownButtonFormField` para la fila 00; `:777-815`
  `InputChip` y un `Chip` «Agregar» con `PopupMenuButton` para los niveles; `:455-535`
  tres formas de cargar tomas en un `ExpansionTile`. Es la pantalla que más pesa en la
  primera visualización (R1).
- `pages/hatch_covers_page.dart:167-179`: `DropdownButton` clásico; `:100-101` diálogo
  con `width: 320` fijo.

**S11 · Alertas de estiba**

- `pages/stowage_alerts_page.dart:65-72`: la severidad se codifica con tres tonos del
  mismo azul (`Color.alphaBlend(primary α .18 / .09 / .03, surface)`), sin icono por
  severidad; `:45-56` dos párrafos de descargo antes del resumen. `ListView.builder` y
  `Card` + `InkWell`: bien.

**S12 a S15 · Listado, Salida, Comparar, Orden de descarga**

- `pages/export_list_import_page.dart:133-151`: `_Banner` propio; `:472-505` el
  `ExpansionTile` de filas construye todas las filas; cruce con icono y texto (`:373-384`):
  bien.
- `pages/departure_baplie_page.dart:5` y `:18-19`: importa `data/` y declara un
  `Provider` en la página (violación de capa, T-99).
- `pages/voyage_comparison_page.dart:99-100`: alto de pestaña calculado a mano; el
  resto (icono, color y rótulo por sección, `ListTile` densos, cifras con espacio fino)
  es un buen modelo de densidad para la oficina.
- `pages/discharge_sequence_page.dart`: `ListView.builder` con cabecera, pasos numerados
  con icono, avisos con icono: buen modelo de lista operativa. Cabecera de celda en
  `secondaryContainer` (`:191-209`).

**S16 · Avance de la operación**

- `pages/operation_progress_page.dart:72-117`: `DataTable` solo a partir de 1000 px y
  `Card` por bahía debajo; todo en un `SingleChildScrollView`. Sin porcentaje, sin
  barra de avance, sin cifras grandes: es una tabla de conteos, no un tablero. «TOTAL»
  (`:103`, `:132`) y «Tapas\nPROVISIONAL» (`:88`) en mayúsculas; conflictos como texto en
  color de error (`:162-163`); `SyncStatusChip` arriba: bien.

**S17 a S19 · Tapas en la operación, Solicitudes, Nube**

- `widgets/hatch_operation_controls.dart:95`: `ListView(children)`; tarjetas con
  `OutlinedButton` «Quitar / Reponer»: bien.
- `pages/change_requests_page.dart:110`, `:142`: `ListView(children)` con todas las
  solicitudes; `:156` la fecha sale cruda (`createdAt.toLocal()`); `:149-154` el estado
  es un `titleMedium` sin icono ni color; `:202-409` formulario de campos de texto.
- `pages/cloud_page.dart:73-77`: el resultado de cada acción es una `Text` arriba sin
  icono ni color; `:103-106` secciones como `titleMedium`; `AutofillGroup` en el inicio
  de sesión: bien.

**Providers y estado de interfaz** (`providers/`)

- 30 providers. `voyageNotifierProvider` es `NotifierProvider<VoyageNotifier,
  AsyncValue<VesselVoyage?>>` (`vessel_providers.dart:56-98`); `LoadFileResult` (`:62`)
  es una clase con banderas (`success`, `isCancelled`, `needsIdentity`, `needsGeometry`):
  candidata a `sealed class` en la Fase 2. El modo del plano, el zoom y la bahía
  seleccionada viven en `setState` dentro de `BayPlanView`; naviera, resaltado, bahía y
  filtro de leyenda en cuatro `Notifier<T?>` sueltos (`:567-712`).
- Violaciones de capa (11, T-99 B.4): `vessel_providers.dart:6-7,14`,
  `voice_recognizer_provider.dart:4-5`, `vessel_overview_page.dart:5-6`,
  `departure_baplie_page.dart:5`, `export_list_providers.dart:7`,
  `movement_log_provider.dart:5`, `sync_providers.dart:5`. Son de providers y páginas que
  instancian `data/`; el rediseño no las toca salvo donde mueva una página.

### 0.7 Inventario de colores, tamaños y estilos escritos a mano

Todo sobre `lib/features/vessel/presentation/` (más la semilla en `lib/core/app.dart`),
contado con `grep` sobre `063d2ae`.

**Colores**

| Qué | Dónde | Cuántos |
|---|---|---|
| `Colors.*` con nombre | `voyage_stats_view.dart` `:72` indigo, `:85` teal, `:208` blue, `:214` deepPurple, `:220` orange, `:226` green, `:232` amber, `:238` cyan, `:348-381` green/orange/grey, `:507-513` blue/indigo/purple/grey, `:543` white, `:599-656` cyan/red/deepOrange, `:986` blue, `:1084` orange | 27 |
| `Colors.transparent` | `vessel_profile_view.dart:164` | 1 |
| `Color(0x…)` | `core/app.dart:26` y `:37` (la semilla `#0D47A1`, claro y oscuro) | 2 |
| Color calculado fuera del esquema | `plan_drag_confirmation.dart:275-277` `HSLColor…withHue(45 / 140)`; `stowage_alerts_page.dart:71` y `vessel_profile_view.dart:58` `Color.alphaBlend`; `vessel_profile_view.dart:317` `Color.lerp` | 4 |
| Transparencias a mano `withValues(alpha:)` | .5 ×6, .1 ×6, .3 ×5, .08 ×3, .7 ×2, .2 ×1, .12 ×1 | 24 |
| Alfa escalonado | `hatch_cover_diagram.dart:63` `0.05 + cover · 0.07` | 1 |

Total: 28 literales en `presentation/`, 2 en el tema y 29 derivados. El prompt decía
«al menos 18»; son más, y los derivados no los ve un conteo de `Colors.*`.

**Tipografía**

| Qué | Cuánto |
|---|---|
| `TextStyle(` a mano | 84 |
| `fontSize:` literal | 46: `bay_plan_view` 23 (8, 9, 10, 11, 12, 18), `container_search_delegate` 8 (10, 11, 12, 16), `containers_list_view` 5 (10, 11, 12), `vessel_profile_view` 4 (9, 10), `voyage_stats_view` 3 (9, 12), `loading_controls` 2 (8, 10), `hatch_cover_diagram` 1 (10), `vessel_overview_page` 1 (12) |
| Tamaños en uso | 8, 9, 10, 11, 12, 16 y 18 sp: cinco por debajo de `labelSmall` (11) |
| `fontWeight` literal | bold 55, w600 8, w500 3 |
| `fontFamily: 'monospace'` | 7 (`bay_plan_view:476`, `containers_list_view:102` y `:443`, `container_search_delegate:355`, `reserved_slot_details:62`, `voyage_stats_view:802` y `:843`); no es una fuente empaquetada, cae en la del sistema |
| Familia declarada en `pubspec.yaml` (`fonts:`) | Ninguna. Windows dibuja con Segoe UI, Android con Roboto y la Web con Roboto más Noto Sans Symbols y Symbols 2 servidas sin red (T-92). La misma pantalla se ve con tres letras distintas |
| Mayúsculas sostenidas en pantalla | LLENO, VACÍO, N/A, CARGA PELIGROSA - IMO, REFRIGERADO:, MERCANCÍA PELIGROSA, CONTENEDOR REFRIGERADO, ▲ CUBIERTA, ▼ BODEGA, PROA, POPA, TOTAL, PROVISIONAL, BAJA, DESC., PASO, RE‑EST., CANC., REVISAR, SUBE, CARG., OR, BAHÍA nn |
| *Title case* en títulos | Gestión de Carga Marítima, Peso Total, Total Contenedores, Bahías Ocupadas, Distribución por Estado / Tamaño / Naviera / Puerto de Descarga, Carga Especial, Contenedores por Bahía, Peso por Bahía, Filtrar por Naviera, Puerto Carga, Puerto Descarga |
| Cifras | Sin `FontFeature.tabularFigures()` en ningún sitio; el número de contenedor va sin agrupar (`MSCU1234567`), el peso con un decimal en el plano y sin decimales en kg en el detalle; «28.7t» pegado en el buscador |

**Símbolos que no son letras** (sin emojis; en la Web dependen de las fuentes servidas)

| Carácter | Usos | Dónde | Para qué |
|---|---|---|---|
| `·` U+00B7 | 161 | 24 archivos | Separador de resúmenes y títulos |
| `‑` U+2011 | 28 | 4 archivos | «re‑estiba» sin partir la línea (T-107) |
| `…` U+2026 | 17 | 13 archivos | Puntos suspensivos |
| `→` U+2192 | 5 | 4 archivos | Movimientos «de → a» |
| `×` U+00D7 | 3 | 3 archivos | «2×20'», «23 columnas × 3 niveles» |
| `▲` U+25B2, `▼` U+25BC | 1 + 1 | `bay_plan_view.dart` | «▲ CUBIERTA», «▼ BODEGA» |
| `↔` U+2194 | 1 | `plan_drag_confirmation.dart` | «Intercambiar A ↔ B» |
| `•` U+2022 | 1 | `privacy_policy_page.dart` | Viñeta |

Roboto cubre `· ‑ … × •`; las flechas y los triángulos salen de Noto Sans Symbols 2 en la
Web, y `web/fonts/LEEME.md` avisa que un glifo fuera de lo servido se dibuja como un
recuadro. En el rediseño, `▲ ▼ → ↔` pasan a iconos.

**Espacios, radios y medidas**

| Qué | Valores |
|---|---|
| `EdgeInsets` | `all(16)` ×39, `all(12)` ×16, `all(24)` ×9, `all(2)` ×7, `only(bottom: 8)` ×7, `only(bottom: 12)` ×5, `all(20)` ×3, `all(8)` ×2 y unas 30 combinaciones sueltas (`symmetric` 8/4, 6/4, 6/2, 12/6, 12/4, 12/10, 10/6, 16/8, 16/6, 4/2…) |
| `SizedBox` | alto 8 ×62, 12 ×42, 16 ×39, 24 ×35, 4 ×27, 20 ×9; ancho 8 ×28, 16 ×12, 12 ×9, 4 ×9 |
| `BorderRadius` | 4 ×16, 12 ×16, 8 ×7, 2 ×6, 20 ×5, 3 ×5, 6 ×3, 16 ×3, 5 ×2, 10 ×1: diez radios distintos |
| Anchos y altos fijos | Diálogos 480 ×3 (`vessel_overview_page`), 400 (`loading_controls:539`), 320 (`hatch_covers_page:101`); avisos `maxWidth: 520` ×2; etiqueta 108 (`reserved_slot_details:144`); celda 50×40 ×7; columnas 54, 40 y 88 (`bay_plan_view`); barras de 22 (`voyage_stats_view:983`, `:1081`); donut 120; perfil 54×68 y alto 132; diagrama de tapas 28; tramo de la barra con 160/112/48/56 (`vessel_overview_page:183-186`) |
| Iconos | 94 `Icons.*` distintos; tamaños 12, 14, 15, 16, 18, 20, 22, 24, 28, 40, 48, 64 y 80; 27 `tooltip:` |
| Movimiento | Flechas del selector 300 ms `easeInOut`; revelar celda 350 + 200 ms; `SnackBar` de 6 s, 10 s y 2 min; sin ninguna consulta a `MediaQuery.disableAnimationsOf` (0 usos): nada respeta la reducción de movimiento del sistema |
| Objetivos táctiles menores de 48 dp | Celdas de 50×40 (`bay_plan_view`, `loading_controls`), ítems de la leyenda (~24 dp), chips del selector de bahías |

### 0.8 Auditoría de `flutter-ui` (línea base)

Comando (desde la raíz, con la ruta real del script):

```
python ~/.agents/skills/flutter-ui/flutter-ui/scripts/flutter_ui_audit.py . --all
```

Salida completa en `docs/rediseno/fase0/flutter-ui-audit-linea-base.txt` (463 líneas).
Sobre los 137 archivos de `lib/`: **18 críticos, 74 avisos y 19 informativos** (el
script termina con código 1 porque hay críticos).

| Regla | Hallazgos | Dónde |
|---|---|---|
| PERF_HARDCODED_FONT_SIZE (aviso) | 70 | 46 en `presentation/`, 22 en `data/services/pdf_report_service.dart` (el PDF, fuera del alcance), 2 en las pantallas congeladas de H5 |
| NAV_NO_POP_SCOPE (informativo) | 19 | Uno por archivo con `Scaffold`; informativo |
| PERF_LIST_VIEW_CHILDREN (crítico) | 15 | 13 `ListView(children)` de páginas cortas, más `containers_list_view.dart:10` y `reserved_slots_list_view.dart:10`; el que pesa es el de la Lista (`shrinkWrap`) |
| RIVERPOD_PROVIDER_IN_CLASS (crítico) | 2 | `vessel_providers.dart:587` y `:669`: **falsos positivos**, los providers son de nivel superior; el script ve el `class` del `Notifier` anterior |
| PERF_HARDCODED_COLOR (aviso) | 2 | `core/app.dart:26` y `:37`: la semilla de la marca |
| RIVERPOD_NO_ERROR_HANDLER (crítico) | 1 | `vessel_overview_page.dart:225`: **falso positivo**, el `error:` está en `:238`, fuera de la ventana de diez líneas del script |
| PERF_INTRINSIC_SIZE (aviso) | 1 | `loading_plan_controls.dart:386` |
| ANIM_ZERO_DURATION (aviso) | 1 | `vessel_overview_page.dart:362`: `Future.delayed(Duration.zero)` cede el hilo, no anima; **falso positivo** |

Por carpeta: `presentation/widgets` 50, `presentation/pages` 30, `data/services` 22,
`presentation/providers` 2, `core` 2, raíz de `lib/` 5 (`main.dart` y las dos pantallas de
H5, que no se tocan).

Lo que el script no ve y sí importa (y queda medido arriba): los `Colors.*`, el
`shrinkWrap`, el `Opacity` por celda, la falta de `RepaintBoundary` en los tres
`CustomPainter`, los objetivos táctiles y los anchos fijos. Meta para las fases 2 y 3:
cero críticos y cero avisos en `presentation/` y `core/`; quedarán los del PDF y los
congelados, que no son del rediseño.

### 0.9 Lo que choca con el prompt o exige una decisión antes de diseñar

1. **La ruta del script de `flutter-ui`** del prompt no existe; la real es
   `~/.agents/skills/flutter-ui/flutter-ui/scripts/flutter_ui_audit.py`. Resuelto.
2. **`flutter-mcp` y `maestro` no conectan.** Mientras sigan así, las fases 2 y 3 van
   por la CLI y por los instrumentos de T-99 y T-100 (0.3). Lo revisa Carlos.
3. **`AGENTS.md` y `CLAUDE.md` siguen en `sprint-3`** y no hay `SPRINT-4.md`. Lo
   mantiene Yov; yo no los edito.
4. **Cambios de comportamiento que el rediseño necesitaría.** Los propongo y no los
   hago; deciden Yov y Carlos:
   - **a.** Abrir la pestaña «Plano» al confirmar la geometría (T-63 2.2, 10.97). Es un
     `animateTo(1)` en `vessel_overview_page.dart` después de `confirmGeometry`, pero
     cambia lo que el usuario ve y lo que miden T-98 y T-99. Quita un paso de R1 (6 → 5
     sin perfil; 4 → 3 con perfil).
   - **b.** El límite de apilamiento es un paso obligatorio (`_limitResolved`,
     `vessel_geometry_page.dart:213-226`). Mientras lo sea, la primera visualización
     sin perfil no baja de **5 acciones** aunque se arregle (a). Para llegar a 3 hay
     que decidir si «No lo tengo» va marcado por omisión cuando el perfil se propone
     desde el archivo (cambia la semántica de la pantalla) o si el umbral de RNF-002 se
     mide con perfil (hoy, 4; con (a), 3).
   - **c.** Los viajes recientes en el inicio: solo presentación, pero cambia R1 con
     perfil a dos toques (icono → viaje reciente → Plano). Propongo hacerlo.
   - **d.** Colores por puerto de descarga, como el plano impreso: solo presentación;
     exige una paleta categórica con contraste AA en claro y oscuro. Lo decide Carlos
     en la Fase 1.
   - **e.** Una entrada a la matriz de segregación (10.89): solo navegación; propongo
     colgarla de «Alertas de estiba».
   - **f.** Fuente empaquetada: no es una dependencia, pero cambia `pubspec.yaml`
     (`fonts:`) y agrega assets con licencia y procedencia. Se declara en la Fase 2
     (2.7 de `SPRINT-3.md`).
   - **g.** Una sola hoja de detalle del contenedor (hoy tres: `bay_plan_view`,
     `containers_list_view`, `reserved_slot_details`) y una sola unidad de peso en
     pantalla. Presentación; lo asumo salvo objeción.
5. **El conductor de T-99** ya busca «Plano» y «BAHÍA nn (» (`tool/t99_conductor.dart:48-51`).
   Si el rediseño cambia esos rótulos o la estructura de pestañas, se actualiza antes de
   medir y se declara.

### 0.10 Validaciones ejecutadas

- Auditoría de `flutter-ui` sobre `lib/` (0.8), salida guardada.
- `search.py` de `ui-ux-pro-max`: funciona con `python` (no con `python -I`); `--stack
  flutter` carga sus 53 reglas (una consulta marítima dio 0 resultados; `--domain color`
  sí devuelve paletas).
- Censos con `grep` (0.7) y con Python (símbolos).
- Cotejo de `tool/t99_conductor.dart` con los rótulos de T-112.
- 103 capturas en `docs/manual/`, todas asignadas a una pantalla (0.4).
- **No se corrió `flutter test` ni `flutter analyze`** (la fase no toca código; el
  semáforo es de Carlos).

### 0.11 Lo que el rediseño va a tocar en las pruebas (para no bajar el piso)

- 106 archivos de prueba, 56 con `testWidgets`; 297 `find.text`, 449 `find.byKey`, 111
  `find.byType`. Rótulos que las pruebas buscan: «Lista» (5 archivos), «Estadísticas»
  (5), «BAHÍA» (3), «Plano» (2), «Pendientes por bahía» (2), «Avance de la operación»
  (2), «Total Contenedores» (2), «Cargar BAPLIE» (1), «Alertas de estiba» (1). 33
  archivos miran el tema o los colores (`fromSeed`, `ThemeData`, `colorScheme`,
  `Brightness`).
- No existe hoy ninguna prueba de accesibilidad (`meetsGuideline`): las de la Fase 2
  serán las primeras.
- Regla de trabajo: conservar las `ValueKey` y los rótulos que las pruebas y el conductor
  buscan; cuando un cambio de interfaz obligue a tocar una prueba, se actualiza sin
  bajar el conteo y se declara, como en T-112.

### 0.12 Archivos de esta entrega

- `docs/REDISENO-RESULTADOS.md` (nuevo, este informe).
- `docs/rediseno/fase0/flutter-ui-audit-linea-base.txt` (nuevo, la auditoría completa).

No cambian `pubspec.yaml` ni `pubspec.lock`. No se tocó `lib/`, `test/`, `lib/main.dart`
ni los archivos congelados. Los tres archivos de `windows/flutter/` que el árbol trae
modificados no son de esta entrega.

### 0.13 Lo que no se pudo y por qué

- Los dos MCP (`flutter-mcp`, `maestro`): no conectaron; no toqué su configuración.
- `flutter analyze` y `flutter test`: no se corrieron, por el semáforo y porque la fase
  no cambia código. El piso queda en el documentado (1063, cero).
- Capturas nuevas: no tocan en esta fase; las 103 del manual son el «antes».

### 0.14 Horas

De las 22:03 (creación del worktree) a las 22:29 del 21-oct-2026: **≈ 0.4 h de
reloj**, sin cronómetro.

### Git para Carlos (Fase 0)

```
git add -- docs/REDISENO-RESULTADOS.md
git add -- docs/rediseno/fase0/flutter-ui-audit-linea-base.txt
git commit -m "Sprint 4: rediseno, fase 0, inventario de pantallas, estilos a mano y auditoria de linea base"
git push
```

### Tres líneas

- Fase 0 entregada sin tocar código: mapa de 19 pantallas y 9 recorridos con las 103
  capturas, problemas con archivo y línea, inventario de 28 colores, 46 tamaños y 84
  estilos a mano, y la auditoría de `flutter-ui` como línea base (18 / 74 / 19).
- Seis causas de raíz, todas en presentación: tema sin tokens, roles de color
  sobrecargados, trazado calculado a mano, navegación plana, Lista y rejilla sin
  construcción perezosa, y texto sin sistema.
- Tres avisos: `flutter-mcp` y `maestro` no conectan, el script de `flutter-ui` vive en
  otra ruta, y la primera visualización en 3 pasos exige una decisión sobre el límite
  de apilamiento (0.9).

### Mensaje para Yov

Yov: Fase 0 del rediseño entregada en `docs/REDISENO-RESULTADOS.md`, sin tocar `lib/`.
Trae el mapa de pantallas con las capturas del manual, los problemas por pantalla con
archivo y línea, el inventario de estilos a mano (28 colores, 46 tamaños, 84 estilos,
diez radios, tres letras distintas por cliente) y la auditoría de `flutter-ui` como
línea base (18 críticos, 74 avisos, 19 informativos; cuatro falsos positivos
identificados). Hay tres cosas para decidir antes de la Fase 1 (sección 0.9): el límite
de apilamiento como paso obligatorio no deja bajar de 5 acciones la primera
visualización sin perfil; los colores por puerto de descarga; y la pestaña «Plano» al
confirmar. `flutter-mcp` y `maestro` no conectan en mi sesión. `AGENTS.md`, `CLAUDE.md`
y la falta de `SPRINT-4.md` son tuyos. Con tu visto bueno arranco la Fase 1
(`DESIGN.md`, dos direcciones y los wireframes) y me detengo en «ALTO: Carlos elige».

## Fase 1 · Dirección (21-oct-2026)

### 1.1 Resultado en tres líneas

- `DESIGN.md` está en la raíz con dos direcciones completas (A «Plano de a bordo» y
  B «Consola de muelle»): paleta con nombre en claro y oscuro, tipografía empaquetada con
  licencia, tokens, movimiento, reglas de texto, los roles semánticos y la paleta
  categórica de «Colorear por», el flujo «ver primero, confirmar después» con las capas
  que toca, la navegación adaptable y los wireframes de las cinco pantallas a 360 dp y
  1920 px.
- El contraste está verificado con un script propio: todas las parejas de texto cumplen
  AA 4.5:1 y los bordes esenciales 3:1 en claro y oscuro, en las dos direcciones, en los
  doce tonos categóricos y en los diez roles semánticos.
- El flujo nuevo cabe en la capa de presentación: **no hace falta T-115**. Termina en
  «ALTO: Carlos elige».

### 1.2 Lo hecho

- Leí `SPRINT-4.md` completo y los cambios de `AGENTS.md` y `CLAUDE.md` desde `6f2700f`.
- Cargué las skills de dirección (`frontend-design`, `interface-design`, `design-system`,
  `dataviz-color`) y las referencias de `flutter-ui` (`flutter-design-thinking.md`,
  `flutter-theme-system.md`); consulté la base de `ui-ux-pro-max` (`--design-system`,
  `--domain color`, `typography`, `style`, `ux` y `--stack flutter`). Lo que sirvió: las
  paletas de alto contraste navy, la regla de 48 dp y 8 dp de separación, la reducción de
  movimiento y el estilo «data-dense dashboard»; lo que no: su propuesta automática de
  sistema (devolvió una boda en rosa: la base no conoce el dominio) y las parejas
  tipográficas Inter y Fira Code, que no aplican.
- Analicé el flujo «ver primero» en el código: `VoyageNotifier` (`vessel_providers.dart:98-550`),
  `sync_providers.dart`, `stack_weight_provider.dart`, `stowage_validation_provider.dart`,
  `loading_operation_provider.dart`, `discharge_provider.dart` y las entidades
  `VesselVoyage`, `VesselProfile`, `Bay`. Conclusión y tabla de archivos en `DESIGN.md`, 8.3.
- Escribí `tool/rediseno_contraste.py` (biblioteca estándar, sin dependencias) y guardé su
  salida en `docs/rediseno/fase1/contraste.md`.
- Escribí `DESIGN.md` (secciones 1 a 15 y el ALTO).

### 1.3 Validaciones ejecutadas

- `python tool/rediseno_contraste.py` → «Pares que no cumplen: 0», código de salida 0.
  Las dos primeras corridas encontraron 8 y 2 pares bajos; los corrigió una regla, no un
  color: el naranja de marca y el acero son rellenos con tinta oscura encima, nunca texto
  claro ni bordes finos sobre papel claro, y los contornos categóricos en claro bajan a
  32 % de luminosidad.
- Los wireframes se comprobaron a mano contra las medidas de los tokens (23 columnas de
  52 dp más rótulos caben en 1 432 px, dentro de los 1 480 que dejan el riel y el panel).
- No se corrió ningún comando de Flutter ni se tocó `lib/`, `test/` ni `pubspec.*`.

### 1.4 Archivos de esta entrega

- `DESIGN.md` (nuevo, raíz; lo pide la fase).
- `tool/rediseno_contraste.py` (nuevo).
- `docs/rediseno/fase1/contraste.md` (nuevo, salida del script).
- `docs/REDISENO-RESULTADOS.md` (esta sección).

### 1.5 Lo que no se pudo y por qué

- La cobertura de glifos de las fuentes (`· ‑ … × •`, sobre todo U+2011) no se comprobó:
  exige los archivos TTF, que entran en la Fase 2 con la familia que elija Carlos. Queda
  anotado en `DESIGN.md`, 7.
- Las maquetas son ASCII, como pide la fase; no hay capturas nuevas.
- Los MCP: Carlos los dejó conectados en su configuración a las 22:53 (10.3 de
  `SPRINT-4.md`: `dart mcp-server` y Maestro 2.11.0). En esta sesión siguen en «failed»
  porque se abrió antes; son servidores de usuario, no conectores, así que no puedo
  reconectarlos yo: hace falta `/mcp` y «reconectar» en esta sesión, o abrir una nueva
  para la Fase 2. No hicieron falta en esta fase.

### 1.6 Horas

De las 22:40 (aprox.) a las 23:00 del 21-oct-2026: ≈ 0.3 h de reloj, sin
cronómetro (la hora de inicio es la del mensaje de Yov con la aceptación de la Fase 0).

### Git para Carlos (Fase 1)

```
git add -- DESIGN.md
git add -- tool/rediseno_contraste.py
git add -- docs/rediseno/fase1/contraste.md
git add -- docs/REDISENO-RESULTADOS.md
git commit -m "Sprint 4: rediseno, fase 1, DESIGN.md con dos direcciones, contraste verificado y flujo ver primero"
git push
```

### Tres líneas

- `DESIGN.md`: dos direcciones completas, A «Plano de a bordo» (papel, tinta, Plex, cartela
  y silueta-selector) y B «Consola de muelle» (losas, Fira condensada, barra de operación
  y chaleco), con wireframes de las cinco pantallas a 360 y 1920.
- Contraste AA verificado por script en claro y oscuro para las paletas, los doce tonos
  de «Colorear por» y los diez roles semánticos; la fuente se empaqueta con licencia OFL.
- «Ver primero, confirmar después» cabe en providers, páginas y widgets (no hace falta
  T-115); la decisión queda en «ALTO: Carlos elige» con seis puntos.

### Mensaje para Yov

Yov: Fase 1 entregada. `DESIGN.md` está en la raíz con las dos direcciones (A «Plano de a
bordo», B «Consola de muelle»), lo que comparten (roles semánticos, paleta categórica de
12 tonos con asignación estable por hash, vistas por omisión de «Colorear por»), el flujo
«ver primero, confirmar después» con la tabla de capas (cabe en presentación: `_publish`
sigue siendo la única escritura y los validadores ya devuelven «sin evaluar» sin perfil
publicado; no hace falta T-115), la navegación adaptable por clases de ventana y los 20
wireframes. El contraste está verificado con `tool/rediseno_contraste.py`
(`docs/rediseno/fase1/contraste.md`, 0 pares bajos). Recomiendo A, tomando de B la barra
de operación del muelle. El ALTO lista seis decisiones para Carlos; la cobertura de
glifos de la fuente se comprueba con el TTF en la Fase 2. Me detengo aquí.

## Fase 2 · Fundación (21-oct-2026)

### 2.1 Resultado en tres líneas

- `DESIGN.md` queda reducido a la dirección A «Plano de a bordo» con todo lo de 10.4
  (649 líneas; antes 923 con dos direcciones): Plex Sans, Mono y Condensed, el puerto con
  sus cinco letras en la celda, 24 ranuras con las dos tablas fijas propuestas (solo
  códigos, a la espera de Carlos), la barra inferior con «Más» y su contador, la celda del
  muelle de 56 × 48, «sin evaluar hasta confirmar el perfil», sin exportar en el previo,
  la regla estricta de publicación directa y buques sintéticos.
- La fundación está en `lib/core/design/`: paleta, tipografía, medidas, trece roles
  semánticos con las 24 ranuras, asignación por FNV-1a, formatos, movimiento, el tema
  claro y oscuro en densidad de oficina o de muelle, ocho componentes con vista previa,
  documentación y prueba, y las fuentes Plex empaquetadas con licencia y procedencia.
- Suite **1126** (piso 1063 + 63 nuevas, ninguna omitida); `analyze` **en cero en lo
  nuevo** (queda un aviso anterior en `tool/t100_sintetico.dart:21`, que no es de esta
  tarea; 2.6); auditoría de `flutter-ui` sin críticos nuevos. **Ninguna pantalla cambia**
  y `lib/core/app.dart` sigue con el tema de v3.0. Me detengo: Codex acepta la Fase 2.

### 2.2 Lo hecho

- Leí 10.4 de `SPRINT-4.md` y reescribí `DESIGN.md` (secciones 1 a 12): queda solo A, con
  la barra de operación de B en el muelle; el nombre del buque del caso de campo no
  aparece (los wireframes usan BUQUE MANUAL, BUQUE PRUEBA y T99 SINTÉTICO); la sección 7
  trae la regla de publicación directa (perfil que cubre la carga **y** escala propuesta
  igual a la última confirmada de ese buque; si falta una, previo) y los «sin evaluar»
  con icono; la 5.3 trae las dos tablas fijas con solo códigos del corpus: 16 puertos de
  descarga y 13 tipos ISO de vacío.
- Fuentes (`assets/fonts/plex/`): siete TTF estáticos del repositorio `IBM/plex`, commit
  `71f558992315a12ca1f06a2215d57962a1992162` (Google Fonts solo trae la variable), con
  `LICENSE-IBMPlex.txt` (OFL 1.1) y `provenance.json` (URL, commit, bytes y SHA-256 de
  cada archivo, como `web/fonts/` en T-92). Con fontTools sobre los TTF: las siete cubren
  `· ‑ … × •`, el español, `« » – — ° ‰`, U+00A0 y U+202F; faltan solo `▲ ▼`, que pasan a
  iconos; los dígitos miden 600 unidades en Sans y Mono y 540 en Condensed, así que son
  tabulares de serie (`tnum` no existe en las fuentes). `pubspec.yaml` declara cuatro
  familias bajo `fonts:`: IBM Plex Sans (400, 500, 600), IBM Plex Sans Condensed (500,
  600), IBM Plex Mono (400, 500) y Roboto (400, 500, los TTF que ya estaban para el PDF),
  que el tema usa de respaldo con `fontFamilyFallback`.
- `tool/rediseno_contraste.py` ahora calcula las 24 ranuras (doce tonos en dos
  luminosidades), aplica las tablas fijas, trae el FNV-1a de referencia y el par «sobre
  grúa / acero»; la salida está en `docs/rediseno/fase2/contraste.md`: 0 pares que no
  cumplen. La primera corrida de las 24 ranuras falló en oscuro: la luminosidad «intensa»
  como sombra más clara deja el texto claro por debajo de 4.5:1 en los verdes; se resolvió
  haciéndola más oscura (21 % en vez de 30 %) y queda escrito en `DESIGN.md`, 5.2.
- Tokens y tema (`lib/core/design/`): `bs_paleta.dart` (`BsPaleta`, 17 colores con nombre
  por brillo), `bs_tipografia.dart` (`BsFuentes`, `BsEscala`, el `TextTheme` y la extensión
  `BsTextos` con cifra grande, dato mono, celda y su segunda línea), `bs_medidas.dart`
  (`BsMedidas`, extensión con espacios, radios, alturas, celda de 52 × 48 en oficina y
  56 × 48 en muelle, objetivos de 48), `bs_colores_semanticos.dart` (`BsColoresSemanticos`,
  trece roles con relleno, texto y contorno, las 24 ranuras y `categorico(codigo)`),
  `bs_categorico.dart` (`fnv1a32` con multiplicación segura para Web y `ranuraCategorica`),
  `bs_formato.dart` (contenedor «MSCU 123456 7», posición «002-01-82», toneladas «28.7 t»,
  kilos «28 650 kg», porcentaje «91 %»), `bs_movimiento.dart` (duraciones y curvas; cero
  con `disableAnimations`) y `bs_tema.dart` (`BayStreamTema.claro` y `.oscuro`, con
  `muelle` y `tablaFija`: `ColorScheme.fromSeed` de la marca ajustado con la paleta, las
  fuentes, el `TextTheme`, los temas de componentes de Material 3 con mínimos de 48 y las
  tres extensiones). `design.dart` reexporta todo.
- Componentes (`lib/core/design/componentes/`), cada uno con doc, vista previa y prueba:
  `BsCelda`, `BsTiraDeBahias`, `BsCartela`, `BsBanda`, `BsCifra`, `BsHojaDeDetalle`,
  `BsBarraDeOperacion` con `BsAvisoDeOperacion` y `BsNumeroDeContenedor` (qué es cada uno:
  `DESIGN.md`, 4.4). Las vistas previas son ocho funciones `@Preview` en
  `vistas_previas.dart`, en claro y oscuro con el tema de muelle.
- Pruebas (`test/t114_*`, 63): `t114_fundacion_test.dart` (el tema trae las extensiones y
  las fuentes; contraste AA de paleta, roles y 24 ranuras calculado en Dart; estabilidad
  de la ranura por código y precedencia de la tabla fija; medidas de 48; formatos;
  movimiento reducido; las ocho vistas previas construyen en claro y oscuro),
  `t114_componentes_test.dart` (el comportamiento de cada componente: celda de 56 × 48 en
  muelle y 48 de alto en oficina, sin `Opacity`; cartela en `Wrap`; hoja de detalle a
  360 dp con letra 2.0 sin desborde; abrir y cerrar; número mono y tabular),
  `t114_accesibilidad_test.dart` (las tres pautas de Flutter, `textContrastGuideline`,
  `androidTapTargetGuideline` y `labeledTapTargetGuideline`, sobre ocho grupos de
  componentes en claro y en oscuro, más la celda de oficina) y `t114_fuentes_test.dart`
  (familias en `pubspec.yaml`, los nueve assets existen, `provenance.json` con SHA-256 y
  bytes exactos, la licencia).
- Un defecto que encontró la prueba: `formatearToneladas(28650)` daba «28.6 t» porque
  `toStringAsFixed(1)` redondea 28.65 hacia abajo por cómo se guarda en binario; ahora
  redondea a la décima con el medio hacia arriba y la prueba cubre 28 650, 28 640 y un
  negativo.

### 2.3 Validaciones ejecutadas

Con la luz verde de 10.4 para `flutter test` y `flutter analyze`; no hubo compilaciones
ni arranques de app, y no se usaron `flutter-mcp` ni `maestro` (ninguna pantalla cambia).

- `flutter test --no-pub test/t114_fundacion_test.dart test/t114_componentes_test.dart
  test/t114_accesibilidad_test.dart test/t114_fuentes_test.dart` → `+63: All tests passed!`.
- `flutter test --no-pub` (suite completa, sobre los archivos finales) → `+1126: All tests
  passed!` en 39 s; 0 fallos, 0 omitidas. Piso: 1063 → **1126**.
- `flutter analyze` → `1 issue found`: `warning - Unused import: 'dart:convert' -
  tool\t100_sintetico.dart:21:8`. No es de esta tarea: el archivo no tiene cambios contra
  `HEAD` y su último commit es `f7e38a3` (T-100 parte A). Durante la fase el analizador
  señaló tres cosas en lo nuevo (`clamp` que devuelve `num` en dos componentes y un
  `const` en una prueba) y las tres están corregidas: **cero en lo nuevo, sin `// ignore:`**.
- `python tool/rediseno_contraste.py` → «Pares que no cumplen: 0» (24 ranuras, trece
  roles, dos luminosidades, claro y oscuro).
- fontTools (Python, fuera del repositorio) sobre los siete TTF: cobertura de glifos y
  anchos de dígitos de 2.2.
- `python …/flutter_ui_audit.py . --all` → 2.4.
- Lo que no se corrió: `dart format` (los archivos existentes del repositorio tampoco lo
  pasan, así que no es convención y no se aplicó a lo nuevo) y el visor de vistas previas
  (`flutter widget-preview start` es un arranque que cuenta en el semáforo; cada vista
  previa se construye en las pruebas en claro y oscuro).

### 2.4 Auditoría de `flutter-ui` (Fase 2)

Mismo comando que en 0.8; salida completa en `docs/rediseno/fase2/flutter-ui-audit.txt`
(1 107 líneas). 155 archivos (137 de la línea base + 18 nuevos): **18 críticos, 235
avisos y 19 informativos**. Los críticos y los informativos son exactamente los de la
línea base (ninguno nuevo); los 161 avisos nuevos están todos en `lib/core/design/`:

| Regla | Hallazgos | Dónde | Qué es |
|---|---|---|---|
| PERF_HARDCODED_COLOR (aviso) | 160: 128 en `bs_colores_semanticos.dart` y 32 en `bs_paleta.dart` (reparto corregido el 22-oct por la O1 de Codex; la primera versión de esta tabla los atribuía todos al primer archivo) | los dos archivos de tokens | Los hexadecimales de la paleta, de los roles y de las 24 ranuras. Son la **única fuente de color** del sistema: la regla del script existe para que no haya hexadecimales fuera del tema, y estos dos archivos son el tema. Fuera de ellos, `lib/core/design/` no tiene ninguno |
| ANIM_ZERO_DURATION (aviso) | 1 | `bs_movimiento.dart:36` | `Duration.zero` cuando el sistema pide reducir el movimiento: es el interruptor de accesibilidad, no una animación de cero |

La meta de 0.8 sigue en pie para la Fase 3: cero críticos y cero avisos en
`presentation/` y `core/` fuera de esos dos archivos de tokens.

### 2.5 Archivos de esta entrega

- `DESIGN.md` (reescrito: una sola dirección).
- `pubspec.yaml` (**cambia**: bloque `fonts:` con cuatro familias). `pubspec.lock` **no
  cambia**: no hay dependencias nuevas.
- `assets/fonts/plex/`: `IBMPlexSans-Regular.ttf`, `IBMPlexSans-Medium.ttf`,
  `IBMPlexSans-SemiBold.ttf`, `IBMPlexSansCondensed-Medium.ttf`,
  `IBMPlexSansCondensed-SemiBold.ttf`, `IBMPlexMono-Regular.ttf`, `IBMPlexMono-Medium.ttf`,
  `LICENSE-IBMPlex.txt` y `provenance.json` (nuevos, 1.26 MB en total).
- `lib/core/design/`: `design.dart`, `bs_paleta.dart`, `bs_categorico.dart`,
  `bs_colores_semanticos.dart`, `bs_formato.dart`, `bs_medidas.dart`, `bs_movimiento.dart`,
  `bs_tipografia.dart`, `bs_tema.dart`, `vistas_previas.dart` y, en `componentes/`,
  `bs_banda.dart`, `bs_barra_de_operacion.dart`, `bs_cartela.dart`, `bs_celda.dart`,
  `bs_cifra.dart`, `bs_hoja_de_detalle.dart`, `bs_numero_de_contenedor.dart` y
  `bs_tira_de_bahias.dart` (nuevos).
- `test/t114_fundacion_test.dart`, `test/t114_componentes_test.dart`,
  `test/t114_accesibilidad_test.dart` y `test/t114_fuentes_test.dart` (nuevos).
- `tool/rediseno_contraste.py` (modificado), `docs/rediseno/fase2/contraste.md` y
  `docs/rediseno/fase2/flutter-ui-audit.txt` (nuevos).
- `docs/REDISENO-RESULTADOS.md` (esta sección).
- Sin cambios: `lib/core/app.dart`, `lib/main.dart`, `domain/`, `data/`, `presentation/`
  y los archivos congelados de H5. `windows/flutter/generated_plugin*` los regenera
  `flutter test` y no se versionan (10.2).

### 2.6 Lo que no se pudo y por qué

- **Las tablas fijas no entran al código todavía**: 10.4 pide que Carlos las confirme
  antes. Están propuestas en `DESIGN.md`, 5.3 (solo códigos); el tema recibe `tablaFija`
  vacía y todo sale por cálculo. Cuando Carlos confirme, son dos mapas en
  `BayStreamTema.claro` y `.oscuro`, con su prueba.
- **`analyze` no queda en cero absoluto** por el aviso previo de
  `tool/t100_sintetico.dart:21` (un `import 'dart:convert'` sin uso, de `f7e38a3`). No lo
  toqué: es del carril de T-100 y no es de esta tarea. Se quita borrando esa línea; que
  lo autorice Carlos.
- **El tema no está conectado en `lib/core/app.dart`**, a propósito: la Fase 3 lo conecta
  con la primera pantalla, para que las capturas del antes y el después se comparen
  pantalla a pantalla y para que en esta fase no cambie ninguna pantalla.
- Las vistas previas se comprobaron por prueba (construyen en claro y oscuro), no en el
  visor: arrancarlo cuenta en el semáforo y no lo pide la fase.
- No hay capturas nuevas: ninguna pantalla cambia.

### 2.7 Horas

De las 23:05 (aprox.) a las 23:55 del 21-oct-2026: ≈ 0.8 h de reloj, sin cronómetro (la
hora de inicio es la del mensaje de Yov con la aceptación de la Fase 1).

### Git para Carlos (Fase 2)

```
git add -- DESIGN.md
git add -- pubspec.yaml
git add -- assets/fonts/plex/IBMPlexSans-Regular.ttf
git add -- assets/fonts/plex/IBMPlexSans-Medium.ttf
git add -- assets/fonts/plex/IBMPlexSans-SemiBold.ttf
git add -- assets/fonts/plex/IBMPlexSansCondensed-Medium.ttf
git add -- assets/fonts/plex/IBMPlexSansCondensed-SemiBold.ttf
git add -- assets/fonts/plex/IBMPlexMono-Regular.ttf
git add -- assets/fonts/plex/IBMPlexMono-Medium.ttf
git add -- assets/fonts/plex/LICENSE-IBMPlex.txt
git add -- assets/fonts/plex/provenance.json
git add -- lib/core/design/design.dart
git add -- lib/core/design/bs_paleta.dart
git add -- lib/core/design/bs_categorico.dart
git add -- lib/core/design/bs_colores_semanticos.dart
git add -- lib/core/design/bs_formato.dart
git add -- lib/core/design/bs_medidas.dart
git add -- lib/core/design/bs_movimiento.dart
git add -- lib/core/design/bs_tipografia.dart
git add -- lib/core/design/bs_tema.dart
git add -- lib/core/design/vistas_previas.dart
git add -- lib/core/design/componentes/bs_banda.dart
git add -- lib/core/design/componentes/bs_barra_de_operacion.dart
git add -- lib/core/design/componentes/bs_cartela.dart
git add -- lib/core/design/componentes/bs_celda.dart
git add -- lib/core/design/componentes/bs_cifra.dart
git add -- lib/core/design/componentes/bs_hoja_de_detalle.dart
git add -- lib/core/design/componentes/bs_numero_de_contenedor.dart
git add -- lib/core/design/componentes/bs_tira_de_bahias.dart
git add -- test/t114_fundacion_test.dart
git add -- test/t114_componentes_test.dart
git add -- test/t114_accesibilidad_test.dart
git add -- test/t114_fuentes_test.dart
git add -- tool/rediseno_contraste.py
git add -- docs/rediseno/fase2/contraste.md
git add -- docs/rediseno/fase2/flutter-ui-audit.txt
git add -- docs/REDISENO-RESULTADOS.md
git commit -m "Sprint 4: rediseno, fase 2, fundacion con tokens, tema claro y oscuro, fuentes Plex y ocho componentes probados"
git push
```

### Tres líneas

- `DESIGN.md` queda en la dirección A con las decisiones de 10.4: Plex, el puerto con
  cinco letras en la celda, 24 ranuras con las dos tablas fijas propuestas, «Más» con
  contador, celda de 56 × 48, «sin evaluar», sin exportar en el previo y la regla de
  publicación directa.
- `lib/core/design/` trae tokens, tema claro y oscuro, trece roles y 24 ranuras con
  contraste AA, las fuentes Plex con licencia y procedencia y ocho componentes con vista
  previa, doc y prueba (incluidas las tres pautas de accesibilidad); ninguna pantalla cambia.
- Suite 1126 (piso 1063 + 63), `analyze` en cero en lo nuevo (queda un aviso previo de
  T-100 en `tool/`), auditoría sin críticos nuevos.

### Mensaje para Yov

Yov: Fase 2 entregada. `DESIGN.md` queda reducido a la dirección A con las decisiones y
correcciones de 10.4: Plex Sans, Mono y Condensed; el puerto con cinco letras en la celda;
24 ranuras con las dos tablas fijas propuestas en 5.3 (solo códigos, a la espera de
Carlos; hasta entonces el tema lleva la tabla vacía); barra Plano, Lista, Avance,
Estadísticas y Más con contador de alertas; celda del muelle de 56 × 48; «sin evaluar
hasta confirmar el perfil» con icono; sin exportar en el previo; buques sintéticos; la
regla estricta de publicación directa en 7.2. La fundación está en `lib/core/design/`
(tokens, tema claro y oscuro con densidad de oficina o de muelle, trece roles y 24 ranuras
verificados AA por script y por prueba en Dart, FNV-1a, formatos, movimiento y ocho
componentes con vista previa, doc y prueba con las tres pautas `meetsGuideline`), y las
fuentes Plex en `assets/fonts/plex/` con OFL y `provenance.json` (fontTools: cubren
`· ‑ … × •` y el español; faltan solo ▲▼, que pasan a iconos; dígitos tabulares de serie).
`pubspec.yaml` cambia (bloque `fonts:`, cuatro familias con Roboto de respaldo);
`pubspec.lock` no. Suite 1126 (1063 + 63, ninguna omitida); `analyze` en cero en lo nuevo,
y queda un aviso previo en `tool/t100_sintetico.dart:21` (`dart:convert` sin uso, de
`f7e38a3`; no lo toqué). Auditoría de flutter-ui: los mismos 18 críticos y 19 informativos
de la línea base; 161 avisos nuevos, 160 son los hexadecimales de los dos archivos de
tokens (128 y 32; reparto corregido el 22-oct) y 1 el `Duration.zero` del movimiento
reducido. Ninguna pantalla cambia y `lib/core/app.dart`
sigue en v3.0 hasta la primera pantalla de la Fase 3. Me detengo: Codex acepta la Fase 2.

## Fase 2 · Corrección tras la aceptación de Codex (22-oct-2026)

Responde a 10.7 de `SPRINT-4.md` y a `docs/rediseno/fase2/aceptacion-codex.md`
(dictamen NO PASA sobre `8c591c8`, con H1, H2 y O1). Ninguna pantalla cambia.

### 2c.1 Resultado en tres líneas

- Los dos hallazgos están corregidos en `BsCelda`. **H1:** la celda atenuada conserva el
  código legible: el relleno baja al 35 % compuesto sobre el papel, el código va en tinta
  suave y el contorno en línea fuerte, en todos los estados, en claro y oscuro y en las
  dos densidades; la etiqueta accesible se conserva. **H2:** la segunda línea de 10 sp
  solo se dibuja en la oficina, con `zoom` de 100 % o más, y nunca en el muelle. Una
  prueba nueva mide lo que se dibuja, compuesto con `Color.alphaBlend`: 75 estados × tres
  fondos × dos temas × dos densidades, 900 casos, 4.5:1 al texto y 3:1 a iconos y contorno.
- Esa prueba encontró **dos defectos más**, que también quedan corregidos: la línea fuerte
  de la Fase 1 quedaba en 2.9:1 sobre el acero tenue de la bodega (token nuevo
  `#6D809F` / `#6983A3`) y la insignia de carga especial no llegaba a 3:1 sobre los
  rellenos intensos en oscuro (ahora toma el primer color que llega a 3:1 entre el
  contorno de su rol, el texto de su rol y la tinta de la celda).
- Las tablas de 10.6 están en el tema por omisión (15 puertos sin `XXVSL`, 13 tipos;
  ranuras 15 a 23 para T-115), el aviso de T-100 está quitado y el reparto de la auditoría
  corregido. Suite **1143** (1126 + 17, ninguna omitida), `analyze` **en cero absoluto**,
  contraste 0 pares bajos, auditoría igual a la entrega. Me detengo: Codex vuelve a aceptar.

### 2c.2 Lo hecho, punto por punto (10.7)

1. **H1, la celda atenuada.** `BsRol.atenuado` cambia de firma: ya no pone alfa en los
   tres colores. El relleno baja al 35 % **compuesto sobre el papel** y queda opaco, para
   que el contraste no dependa de lo que haya detrás (con el relleno translúcido, el
   naranja de «en movimiento» sobre la bodega caía a 4.33:1); el texto pasa a tinta suave
   (`onSurfaceVariant`) y el contorno a línea fuerte (`outline`); el hueco conserva su
   línea de separación. Vale para normal, atenuada, cancelada, de paso, reservada, en
   movimiento, el resto de las marcas, las tres insignias, resaltada y hueco. La insignia
   atenuada va en tinta suave, no en alfa. La etiqueta accesible y el botón no se tocan
   (`matchesSemantics` lo comprueba). Sin `Opacity`.
2. **La prueba que mide lo que se dibuja:** `test/t114_celda_contraste_test.dart`, cuatro
   barridos (claro y oscuro × muelle y oficina) más la reproducción exacta de Codex en los
   dos temas. Toma el `Container` de la celda y sus `RichText` (texto e iconos), compone
   con `Color.alphaBlend` el relleno sobre el fondo, el texto y los iconos sobre el relleno
   compuesto y el contorno sobre el relleno, y exige 4.5:1 al texto y 3:1 a iconos y
   contorno, con `takeException()` nulo en cada caso. 75 estados sobre papel, cubierta
   (hoja) y bodega (acero tenue): 225 por barrido, 900 en total. No usa
   `textContrastGuideline`. Parte del `diagnostico_test.dart` de Codex (la composición
   sobre `scaffoldBackgroundColor`) y lo generaliza. El hueco queda fuera de la exigencia
   de 3:1 del contorno: su línea de 1 dp es un separador (`DESIGN.md`, 4.3), no un
   contorno esencial, y no tiene texto.
   - **Lo que encontró además, corregido:** (a) la línea fuerte `#7A8DA6` / `#5C7392` daba
     2.87:1 y 2.77:1 sobre el acero tenue de la bodega, y 2.93 y 2.84 sobre la hoja alta;
     el token pasa a `#6D809F` / `#6983A3` (3.8 y 4.7 sobre el papel, 3.4 sobre el acero
     tenue, 3.5 sobre la hoja alta) en `bs_paleta.dart`, en los roles que lo usan como
     contorno (cancelado, de paso, reservado, cubierta y bodega), en el script y en
     `DESIGN.md` 4.1 y 5.1; (b) la insignia OOG (`#C9A0DE`) sobre el relleno ámbar oscuro
     (`#6F5E2A`) daba 2.89:1; ahora `BsCelda` elige para la insignia el primer color que
     llega a 3:1 sobre el relleno entre el contorno de su rol, el texto de su rol y la
     tinta de la celda (tres luminancias por celda con carga especial; `DESIGN.md`, 5.1);
     (c) el naranja atenuado translúcido sobre la bodega daba 4.33:1 con tinta suave: de
     ahí que el relleno atenuado se componga sobre el papel en el tema (peor caso 4.98:1,
     el índigo intenso en claro).
3. **H2, la segunda línea.** `BsCelda` recibe `zoom` (1.0 es 100 %, por omisión). La
   línea 2 se dibuja solo si no es muelle, `zoom >= 1.0`, no hay marca y las dos líneas
   caben en el alto interior con la escala de letra del sistema (tamaño × interlínea:
   a 1.45 cabe, a 2.0 no). Con marca, el icono de 14 dp se dibuja si cabe junto al rótulo;
   a 2.0 con el contorno resaltado de 3 dp no cabe y se omite, y el rótulo queda. Así nada
   desborda a 2.0: lo prueba un barrido con las ocho marcas × resaltada × dos densidades.
   La vista previa nueva «Celdas · oficina, zoom 100 % y 75 %» muestra la regla; la del
   muelle recibe `linea2` y no la dibuja.
4. **Las tablas de 10.6, en el tema.** `bs_categorico.dart` trae `tablaFijaDePuertos`
   (15, ranuras 0 a 14), `tablaFijaDeTipos` (13, 0 a 12), `primeraRanuraLibreDePuertos`
   (15) y `tablaFijaConfirmada` (las dos juntas, 28 códigos). `BayStreamTema.claro`,
   `.oscuro` y las fábricas de `BsColoresSemanticos` la usan por omisión; `tablaFija:
   const {}` la desactiva. Pruebas: orden y ranuras, `XXVSL` fuera y por cálculo, ningún
   puerto en 15 a 23, el tema la lleva, y `tool/rediseno_contraste.py` lleva las mismas
   listas (la prueba lee el script). `DESIGN.md` 5.3 reescrito: `XXVSL` fuera, ranuras 15 a
   23 de la oficina, T-115.
5. **El aviso de T-100:** borrada la línea `import 'dart:convert';` de
   `tool/t100_sintetico.dart` (autorizado en 10.5). `flutter analyze`: «No issues found».
6. **El informe:** la tabla de 2.4 y el mensaje a Yov de la Fase 2 dicen ahora 128 en
   `bs_colores_semanticos.dart`, 32 en `bs_paleta.dart` y 1 en `bs_movimiento.dart`.

### 2c.3 Validaciones ejecutadas

- `flutter test --no-pub` con los cinco archivos `test/t114_*` → `+80: All tests passed!`
  (63 + 17 nuevas: 6 de contraste compuesto, 6 de la segunda línea y la letra a 2.0, 4 de
  las tablas, 1 de la vista previa de oficina).
- `flutter test --no-pub` completa → `+1143: All tests passed!` (1 min 53 s), 0 fallos,
  0 omitidas. Piso: 1126 → **1143**.
- `flutter analyze` → **«No issues found»**: cero absoluto, sin `// ignore:`.
- `python tool/rediseno_contraste.py` → «Pares que no cumplen: 0». `contraste.md` (197
  líneas) trae ahora la línea fuerte sobre papel, hoja y acero tenue, las tablas
  confirmadas con la nota de las ranuras libres y la sección «Celda atenuada» (peor texto
  4.98:1 en claro y 6.39:1 en oscuro; borde 3.76 y 4.65).
- Auditoría de `flutter-ui` (`docs/rediseno/fase2/flutter-ui-audit.txt`): 155 archivos,
  **18 críticos, 235 avisos y 19 informativos**, iguales a la entrega; los 161 avisos
  nuevos siguen siendo 128, 32 y 1; `bs_celda.dart`, `bs_categorico.dart` y `bs_tema.dart`
  sin hallazgos.
- La prueba nueva falló tres veces antes de quedar en verde y cada fallo fue un defecto
  real (2c.2, punto 2). `analyze` señaló en lo nuevo un `SemanticsFlag` sin importar (se
  cambió por `matchesSemantics`) y una concatenación de literales; corregidos.
- No hubo compilaciones ni arranques; no se usaron `flutter-mcp` ni `maestro`.

### 2c.4 Archivos de esta entrega

- Modificados: `DESIGN.md`; `lib/core/design/bs_categorico.dart`,
  `bs_colores_semanticos.dart`, `bs_paleta.dart`, `bs_tema.dart`,
  `componentes/bs_celda.dart`, `vistas_previas.dart`; `test/t114_accesibilidad_test.dart`,
  `t114_componentes_test.dart`, `t114_fundacion_test.dart`; `tool/rediseno_contraste.py`;
  `tool/t100_sintetico.dart` (una línea menos); `docs/rediseno/fase2/contraste.md`,
  `docs/rediseno/fase2/flutter-ui-audit.txt`; `docs/REDISENO-RESULTADOS.md` (2.4, el
  mensaje a Yov de la Fase 2 y esta sección).
- Nuevo: `test/t114_celda_contraste_test.dart`.
- Sin cambios: las pantallas, `lib/core/app.dart`, `lib/main.dart`, `domain/`, `data/`,
  `pubspec.yaml`, `pubspec.lock` y los archivos congelados de H5.

### 2c.5 Lo que no se pudo y lo que queda

- El código de cinco letras con la letra del sistema a 2.0 (24 sp en condensada) no
  cabe en 52 ni en 56 dp y se corta con elipsis. Es anterior a esta corrección y 10.7 no
  lo pide; queda escrito en `DESIGN.md`, 12, para la entrega del plano (Fase 3), donde la
  rejilla decide el tamaño de la celda con el zoom y se comprueba con las capturas a
  1.45 y 2.0.
- El aviso de `CupertinoIcons` en la compilación Web que vio Codex: no se compiló en esta
  corrección (cuenta en el semáforo); se revisa en la Fase 3, como dice 10.7.
- Las 9 ranuras de puertos de la oficina: T-115, fuera del rediseño.

### 2c.6 Horas

De las 11:05 (aprox.) a las 11:40 del 22-oct-2026: ≈ 0.6 h de reloj, sin cronómetro (la
hora de inicio es la del mensaje de Yov con el dictamen).

### Git para Carlos (Fase 2, corrección)

```
git add -- DESIGN.md
git add -- lib/core/design/bs_categorico.dart
git add -- lib/core/design/bs_colores_semanticos.dart
git add -- lib/core/design/bs_paleta.dart
git add -- lib/core/design/bs_tema.dart
git add -- lib/core/design/componentes/bs_celda.dart
git add -- lib/core/design/vistas_previas.dart
git add -- test/t114_accesibilidad_test.dart
git add -- test/t114_celda_contraste_test.dart
git add -- test/t114_componentes_test.dart
git add -- test/t114_fundacion_test.dart
git add -- tool/rediseno_contraste.py
git add -- tool/t100_sintetico.dart
git add -- docs/rediseno/fase2/contraste.md
git add -- docs/rediseno/fase2/flutter-ui-audit.txt
git add -- docs/REDISENO-RESULTADOS.md
git commit -m "Sprint 4: rediseno, fase 2, correccion de la celda atenuada y la segunda linea, tablas fijas en el tema y analyze en cero"
git push
```

### Tres líneas

- H1 y H2 corregidos en `BsCelda`, con una prueba que compone lo que se dibuja (900 casos)
  y que encontró y corrigió dos defectos más: la línea fuerte sobre la bodega y la
  insignia sobre los rellenos oscuros.
- Las tablas de 10.6 en el tema por omisión, el `import` sin uso de T-100 borrado y el
  reparto de la auditoría corregido.
- Suite 1143 (1126 + 17), `analyze` en cero absoluto, contraste 0 pares bajos, auditoría
  igual a la entrega; ninguna pantalla cambia.

### Mensaje para Yov

Yov: corrección de la Fase 2 entregada (10.7). H1: `BsRol.atenuado` ya no pone alfa en
el texto: el relleno baja al 35 % compuesto sobre el papel (opaco), el código va en tinta
suave y el contorno en línea fuerte, en todos los estados, claro y oscuro, dos
densidades; la etiqueta accesible se conserva. La prueba nueva
`test/t114_celda_contraste_test.dart` mide lo que se dibuja con `Color.alphaBlend` (75
estados × papel, cubierta y bodega × dos temas × dos densidades, 900 casos; 4.5:1 texto,
3:1 iconos y contorno; sin `textContrastGuideline`) y encontró dos defectos más, ya
corregidos: la línea fuerte de la Fase 1 quedaba en 2.9:1 sobre el acero tenue de la
bodega (token nuevo `#6D809F` / `#6983A3`, en paleta, roles, script y `DESIGN.md`) y la
insignia OOG daba 2.9:1 sobre el ámbar oscuro (la insignia elige el primer color que
llega a 3:1 entre el contorno de su rol, el texto de su rol y la tinta de la celda). H2:
`BsCelda.zoom`; la línea 2 solo en la oficina con zoom ≥ 1.0, sin marca y si cabe con la
escala de letra (a 2.0 se oculta sin desbordar); en el muelle nunca; vista previa y
pruebas ajustadas. Tablas de 10.6 en `tablaFijaConfirmada`, por omisión del tema
(`XXVSL` fuera; ranuras 15 a 23 para T-115; `DESIGN.md` 5.3). `import 'dart:convert'` de
T-100 borrado: `analyze` «No issues found». Informe 2.4: 128 + 32 + 1. Suite 1143
(1126 + 17, ninguna omitida), contraste 0 pares bajos (el script trae ahora la celda
atenuada y la línea fuerte sobre hoja y acero tenue), auditoría 18/235/19 como en la
entrega. Ninguna pantalla cambia; `pubspec` no cambia. Queda anotado para la Fase 3
(`DESIGN.md`, 12) que el código de cinco letras se corta con elipsis a escala 2.0 en
52/56 dp. Me detengo: Codex vuelve a aceptar.

## Fase 3 · Entrega 1: el inicio y la primera visualización (22-oct-2026)

### 3.1 Resultado en tres líneas

- **El inicio y el previo están en la app**: el tema claro y oscuro conectado en
  `lib/core/app.dart` con la preferencia de T-90; el inicio de `DESIGN.md` 9.1 con
  «Seleccionar archivo» como única acción, los recientes, los perfiles y, con cuenta, las
  operaciones abiertas; y «ver primero, confirmar después» (7): el plano abre en previo con
  la banda y «Confirmar», peso por pila y tomas dicen «sin evaluar hasta confirmar el
  perfil», sin modos, sin exportar, descartar pregunta, y al confirmar se queda en el Plano.
  La regla estricta de publicación directa (7.2) está probada con el hallazgo 5 del manual.
- **RNF-002 pasa de seis pasos a tres en los tres clientes**, medido con instrumentos
  nuevos y declarados: Windows 1.83–1.90 s, la Web 0.30–0.42 s (1.28–1.51 s en la primera
  visita) y el emulador Android con cotas de 2.98–3.25 s, contra ≤ 3 pasos y ≤ 30 s.
- Suite **1156** (piso 1143 + 13 nuevas, 19 actualizadas sin bajar el conteo, ninguna
  omitida); `analyze` **«No issues found»**; auditoría de `flutter-ui` con **cero críticos y
  cero avisos en lo tocado** (dos falsos positivos del patrón `ListView(` declarados); censos
  de T-112 sin inglés ni excepciones nuevas. `pubspec` no cambia, `domain/` y `data/` no
  cambian, `main.dart` no cambia. Me detengo: Codex acepta.

### 3.2 Lo hecho

1. **El tema, conectado** (`lib/core/app.dart`, autorizado en 10.9): `BayStreamTema.claro` y
   `.oscuro` con la preferencia de tema de T-90 (`themePreferenceProvider`), en la densidad
   que decide la plataforma (`bayStreamEsMuelle`: muelle en Android e iOS, oficina en
   Windows y la Web; `DESIGN.md` 4.3). Con eso cambian el color y la letra de todas las
   pantallas a la vez; la suite completa las recorre y no hay desbordes nuevos.
2. **Los estados del viaje** (`presentation/providers/voyage_ui_state.dart`, nuevo): la
   `sealed class` de `DESIGN.md` 7.1 (`SinViaje`, `Leyendo`, `Previo`, `Publicado`,
   `Fallo`), derivada del notifier por `voyageUiStateProvider`, con el motivo del previo
   (`PreviewReason`: buque nuevo, homónimo, fuera del perfil, escala por decidir) y los
   textos de la banda. El notifier sigue siendo la única fuente y `_publish`, la única
   escritura.
3. **El previo en el notifier** (`vessel_providers.dart`): `parseBaplieContent` deja el
   plano a la vista con la geometría propuesta (`_abrirPrevio`), sin guardar nada;
   `isPreview`, `previewReason`, `previewPortOfCall`, `visibleVoyage` y
   `discardPreview`; `publishedVoyage` y `publishedProfile` no ven el previo, así que los
   validadores de peso por pila y de tomas no evalúan sin perfil confirmado. Lo que
   había antes (nada, o el viaje publicado) se restaura al descartar.
4. **La regla estricta de publicación directa** (`_useProfile`, `DESIGN.md` 7.2): un viaje
   abre publicado sin previo solo si el perfil guardado cubre toda la carga **y** la
   escala propuesta es la última confirmada para ese buque en este dispositivo (la del
   viaje guardado más reciente de ese perfil con escala, leída del almacén que ya existe:
   `domain/` y `data/` no cambian) **y** el archivo deja claro si es de llegada o de
   carga. Si falta cualquiera, previo. Un plano de llegada que propone el puerto de
   salida (hallazgo 5 del manual) abre en previo con «El archivo sale de PAMIT rumbo a
   GTSTC: confirma la escala.».
5. **El inicio** (`widgets/inicio_view.dart`, nuevo; `widgets/empty_state_widget.dart`,
   rehecho), según `DESIGN.md` 9.1: «Abre un plano de estiba», la validación por
   contenido y «Seleccionar archivo» a 56 dp como acción única; los recientes de este
   dispositivo (hasta cinco, cada uno con buque, viaje, cuentas y escala; «Ver todos»
   lleva a la pantalla que los borra); «Perfiles guardados (N)»; y, con cuenta
   autorizada, «Operaciones abiertas en la nube (N)» hacia Nube y cuenta. La barra
   superior lleva solo Parámetros y Nube; no hay botón flotante ni acciones repetidas
   (T-98, `con01`). Desde 840 dp, dos columnas dentro del ancho máximo de 1440.
6. **El previo en la página** (`pages/vessel_overview_page.dart`): `switch` sobre el
   estado; **el plano es la primera pestaña** (10.2 a), así que la primera
   visualización termina en la rejilla; la banda `BsBanda` con el motivo y «Confirmar»;
   el aviso «Peso por pila y tomas de refrigerado: sin evaluar hasta confirmar el
   perfil.» con icono, en todas las pestañas; sin escala no aparecen los modos Carga y
   Descarga, ni el listado ni la salida; exportar avisa «Para exportar, confirma el
   perfil del buque.»; «Limpiar datos», abrir otro archivo o los recientes preguntan
   «¿Descartar el plano sin confirmar?»; cancelar en los parámetros, en la identidad o
   en la plantilla deja el previo a la vista; al confirmar, el viaje se publica y se
   queda en el Plano. En Alertas de estiba (`stowage_alerts_page.dart`), el previo dice
   «sin evaluar» en vez de «no hay resultados».
7. **Lo que se tocó de paso en la página**, porque la auditoría de `flutter-ui` exige
   cero avisos en lo que se toca: el tamaño de letra escrito a mano de los chips de
   «llenos / vacíos» pasa al tema, y el `Future.delayed(Duration.zero)` de la exportación
   a PDF pasa a esperar el final del cuadro (`WidgetsBinding.instance.endOfFrame`), que
   es lo que buscaba.
8. **Instrumentos** (`tool/`): el conductor de T-99 (`t99_conductor.dart`) toca
   «Seleccionar archivo» en el inicio, espera el viaje a la vista (previo o publicado),
   anota si quedó en previo, lee sus definiciones también del entorno del proceso (el
   mismo binario mide y recorre escenarios) y trae el escenario `inicio` (capturas del
   inicio y del previo por tamaño, tema y letra; `t99_plataforma_*.dart`); el banco toma
   el namespace de `T99_NAMESPACE` (`t99_app.dart`); `t99_copia.ps1` copia el árbol de
   trabajo (`-Arbol`) con la identidad del cliente (`-Sufijo r4`); la primera
   visualización en tres pasos se mide con `t114_primera_android.py` (sucesor de
   `t98_primera_honor.py`, que se conserva como el instrumento de T-98 para el paquete
   `.t98` y sus seis pasos), `t114_primera_windows.py` (sin persona ni agente),
   `t114_primera_web.py` con `t114_primera_web.js` (el Chrome instalado, abierto
   por Playwright en un perfil temporal y en una ventana visible, con el instrumento
   inyectado antes de cada documento) y `t114_primera_cuadros.py` (el primer cuadro
   con rejilla de un video); `t114_capturas_windows.ps1`, `t114_capturas_android.py` y
   `t114_capturas_web.py` toman las capturas del inicio y del previo; `t112_censos.py` conoce
   los archivos nuevos (decisiones de idioma por archivo y pantalla para Material 3).
9. **`DESIGN.md`**: la densidad por plataforma (4.3), los textos del previo y la regla
   de descartar y de «la última escala confirmada para ese buque» (7), las capas que
   tocó la entrega (7.3), lo hecho del inicio (9.1) y el estado de la Fase 3 (12).

### 3.3 Pruebas

- **Nuevas, `test/t114_fase3_inicio_test.dart` (13):** el tema conectado en claro y en
  oscuro con la preferencia; el inicio con una sola acción, los recientes y los
  perfiles, y abrir un reciente va al Plano; un buque nuevo abre en previo con la banda,
  «sin evaluar», sin modos ni exportar (y Alertas dice «sin evaluar»); «Confirmar»
  publica, guarda y se queda en el Plano; cancelar en los parámetros deja el previo y
  descartar pregunta y vuelve al inicio; y la regla estricta: perfil que cubre con la
  escala de siempre abre publicado; otra escala, previo; **el hallazgo 5** (un plano de
  llegada que propone el puerto de salida abre en previo, y con el historial de la misma
  escala abre publicado como llegada); perfil que no cubre, previo con la geometría
  ampliada; descartar vuelve al viaje publicado; buque nuevo sin escala en el archivo;
  homónimo en previo con la identidad pendiente. Son sintéticos (BUQUE MANUAL).
- **Actualizadas sin bajar el conteo (8 archivos, 19 pruebas), porque esperaban que
  «Parámetros del buque» se abriera solo o el inicio de antes:**
  `profile_loading_page_test.dart` (las seis: `load` toca «Seleccionar archivo» y
  `confirmar` toca la banda; cancelar deja el previo; la segunda carga sin escala abre
  en previo con el perfil guardado; el repositorio falso responde `getAllVoyages`);
  `profile_loading_test.dart` (cuatro: la segunda carga sin escala abre en previo y
  confirmar publica; el homónimo elegido queda en previo y confirmar no duplica; el
  perfil con anclas distintas se usa sin recalcularlo, en el previo; ampliar y volver a
  cargar abre en previo sin ampliación pendiente); `profile_persistence_test.dart`
  (las dos: el límite sobrevive en el previo, con `visibleVoyage`);
  `recent_voyages_test.dart` (el plano abre primero y pliega la barra: la Lista la
  muestra); `stowage_alerts_page_test.dart` («Alertas de estiba» está en la Lista);
  `t104_text_test.dart` (las dos: la cabecera del inicio vive dentro de un desplazable);
  `t86_baplie_version_test.dart` (las dos) y `t89_file_input_test.dart` (una): en el
  inicio la carga es «Seleccionar archivo».
- Las 80 de T-114 de la Fase 2 no cambian.

### 3.4 Validaciones ejecutadas

Con la luz verde de 10.9: un comando de Flutter a la vez; los de varios minutos, en
segundo plano y de uno en uno. El Honor no se tocó (el emulador hace de teléfono).

- `flutter test --no-pub` completa → `+1156: All tests passed!`, 0 fallos, 0 omitidas.
  Piso: 1143 → **1156** (13 nuevas).
- `flutter analyze` → **«No issues found»**.
- Auditoría de `flutter-ui` (`docs/rediseno/fase3/flutter-ui-audit.txt`): 157 archivos,
  **17 críticos, 231 avisos y 19 informativos** (la entrega anterior: 18, 235 y 19).
  En los archivos que toqué: `app.dart`, `inicio_view.dart`, `empty_state_widget.dart`,
  `voyage_ui_state.dart` y `stowage_alerts_page.dart`, **cero críticos y cero avisos**
  (solo el informativo `NAV_NO_POP_SCOPE` de cada `Scaffold`); en
  `vessel_overview_page.dart` desaparecen el aviso de letra escrita a mano, el
  `ANIM_ZERO_DURATION` y el crítico `RIVERPOD_NO_ERROR_HANDLER` (que era un falso
  positivo: ya no hay `.when(`), y quedan **dos críticos que son falsos positivos del
  script**: `ReservedSlotsListView(` y `ContainersListView(` coinciden con su patrón
  `ListView(` y no son listas con `children`. En `vessel_providers.dart` siguen los dos
  `RIVERPOD_PROVIDER_IN_CLASS` que la línea base ya declaró como falsos positivos.
- Censos de T-112 sobre el árbol (`tool/t112_censos.py`, salida en
  `docs/rediseno/fase3/censos/`; **la referencia de `--antes` es el `lib/` de
  `5406e20`**, el commit de la corrección de la Fase 2: con `sprint3-cierre` las
  decisiones por línea no coinciden y salen 1834 cadenas y M3 251/16/0, como
  comprobó Codex en 10.15, O3): idioma, **1816 cadenas visibles: 1677 en español y 139
  sin idioma (siglas, nombres o unidades), 0 en inglés o mixtas**; con los 20 textos de
  Flutter, 100 % en las dos lecturas de T-98. Material 3: **259 controles incluidos, 8
  exclusiones declaradas y 5 excepciones**, las cinco anteriores (`GestureDetector`,
  `LongPressDraggable` y `DragTarget` del plano y del arrastre, S02), ninguna en lo que
  toqué; los 48 controles de S01 (inicio y Lista) son Material y toman el color del
  esquema o del tema, y los 7 de los componentes del sistema de diseño también (dos
  toman el color de `BsColoresSemanticos`, una `ThemeExtension`: declarados como
  resueltos). Mensajes: los **218** de T-112, sin cambios. Las 34 cadenas nuevas sin
  decisión (formatos, familias tipográficas, rótulos de la celda, etiquetas de la tira,
  los textos del previo y del inicio) se decidieron por archivo en `T114_DECISIONES`.

### 3.5 RNF-002: la primera visualización en tres pasos

Los tres pasos del producto son (1) abrir la app, (2) «Seleccionar archivo» y (3) elegir el
archivo en el selector del sistema; el fin es la rejilla a la vista, que desde esta entrega
es el previo, sin confirmar nada. El umbral es **≤ 3 pasos y ≤ 30 s**, y rige la
condición «sin perfil»; «con perfil» es informativa. En T-98 (10.97) eran **seis pasos sin
perfil en los tres clientes: no cumplía**. Ahora son **tres en los tres clientes, y el
tiempo queda muy por debajo del umbral**: Windows 1.83–1.90 s, la Web 0.30–0.42 s (1.28–1.51
s en la primera visita) y el emulador Android con cotas de 2.98–3.25 s.

| Cliente | Condición | Rep. | Pasos | Hasta la rejilla (s) | ≤ 3 pasos y ≤ 30 s |
|---|---|---|---|---|---|
| Windows (1920×1080, oscuro) | sin perfil | 5 | 3 | 1.900, 1.871, 1.832, 1.870, 1.887 (± 0.05) | cumple |
| | con perfil | 1 | 3 | 2.566 | cumple |
| Web (Chrome 155, 1280×720, oscuro) | sin perfil, caché caliente | 5 | 3 | 0.421, 0.297, 0.360, 0.325, 0.315 | cumple |
| | sin perfil, primera visita | 5 | 3 | 1.510, 1.284, 1.294, 1.288, 1.295 | cumple |
| | con perfil | 1 | 3 | 2.915 | cumple |
| Emulador Android (API 26, 360 dp, claro) | sin perfil | 5 | 3 | cotas 3.146–3.175, 3.207–3.253, 2.984–3.033, 3.104–3.152, 3.085–3.150 | cumple |
| | con perfil | 1 | 3 | cota 3.140–3.203 | cumple |

**Qué cambia en los instrumentos respecto de T-98 (10.97), declarado.** T-98 midió con
`tool/t98_primera_honor.py` en el Honor (seis pasos, video y PTS), con el agente en Windows
(pausas que impidieron medir el tiempo) y con el screencast CDP del navegador integrado de
Codex en la Web. Los instrumentos de T-98 se conservan sin tocar, para el paquete `.t98` y
sus seis pasos. Los de esta entrega son nuevos, uno por cliente, miden el recorrido de tres
pasos y terminan en la rejilla del previo:

- **Windows, `tool/t114_primera_windows.py`:** sin persona ni agente. Un proceso de Python
  abre el binario del banco r4 como una persona (`explorer.exe`, fuera del paquete de la
  consola), localiza «Seleccionar archivo» por el color de la marca en la captura de la
  ventana (claro y oscuro), escribe la ruta en el selector nativo y lo confirma por mensaje
  Win32, y captura la ventana a unos 20 cuadros por segundo con el reloj monotónico del
  host; el fin es el primer cuadro en que la ventana queda quieta con el plano. La
  incertidumbre es el intervalo entre cuadros (0.05 s). Hitos por repetición (s desde el
  arranque): la ventana a la vista 0.443, 0.440, 0.440, 0.462, 0.439; el archivo confirmado
  1.630, 1.585, 1.598, 1.588, 1.595; la rejilla quieta 1.900, 1.871, 1.832, 1.870, 1.887.
  «Con perfil»: 0.598, 2.070, 2.566. «Sin perfil» aparta el almacén de la copia antes de
  cada repetición (`T99_ALMACEN` en `%TEMP%`); «con perfil» lo conserva con el perfil
  confirmado por una corrida previa. Registros en `docs/rediseno/fase3/rnf-002/windows/`
  (`sinNN/registro.json` con todos los instantes y diferencias entre cuadros,
  `resumen-sin.json`, `resumen-con.json`, y el inicio y la rejilla de `sin01` en PNG).
- **Web, `tool/t114_primera_web.py` con `tool/t114_primera_web.js`:** se describe abajo.
- **Android, `tool/t114_primera_android.py` con `tool/t114_primera_cuadros.py`:** sucesor
  de `t98_primera_honor.py` para el emulador (el Honor solo con `--serial` y el permiso de
  Carlos): ADB, uiautomator y `screenrecord`. El icono no está a la vista en el lanzador
  del emulador, así que el paso 1 es `am start` del paquete r4 (anotado); el paso 2 toca
  «Seleccionar archivo» en el inicio; el paso 3 elige el archivo en el selector de AOSP, que
  abre en «Recent» vacío la primera vez: el instrumento abre el cajón de raíces, Descargas y
  `t114` (el selector cuenta una vez, como en T-98, donde el del Honor recordaba la carpeta;
  en las cinco repeticiones ya recordaba `t114`). El tiempo sale del video: el primer cuadro
  que difiere del lanzador (el lanzamiento) y el primer cuadro quieto con el plano,
  propuestos por `t114_primera_cuadros.py` y revisados a ojo; los JPEG candidatos y los PTS
  quedan en el registro. La cota incluye las lecturas de uiautomator del instrumento (unas
  dos por recorrido), así que es un **límite superior** del tiempo del producto, como en
  T-98. «Sin perfil» hace `pm clear` solo del paquete r4 antes de cada video; «con perfil»
  conserva el perfil que `tool/t114_capturas_android.py` confirmó antes (BUQUE MANUAL, de
  `T100_CARGA.edi`) y abre ese mismo archivo, que por 7.2 abre publicado. Registros en
  `docs/rediseno/fase3/rnf-002/android/` (`captura.json`, `cuadros.json` y los JPEG por
  repetición, `resumen.json`); los MP4 quedan en `%TEMP%` con su SHA-256 en el registro.

#### Web (Chrome 155, ventana visible de 1280×800, vista 1280×720, tema oscuro)

El navegador integrado de la consola no sirvió para medir: cuando nadie mira la
sesión, su panel queda oculto, la página no pinta ni corre
`requestAnimationFrame`, y la primera corrida dio un FCP de 7.99 s que era del
panel, no del producto. La medición se hizo con el Chrome instalado, abierto por
Playwright en un perfil temporal vacío y en una ventana visible del escritorio
(`tool/t114_primera_web.py`), sin tocar el Chrome de Carlos ni cuentas. El
instrumento (`tool/t114_primera_web.js`) se inyecta antes de cada documento, así
que observa desde la navegación: el primer cuadro del motor (FCP del navegador
o, si falta, el lienzo observado), la activación de la semántica (acción del
instrumento) y, del clic en «Seleccionar archivo» a la primera bahía en la
semántica, el tiempo del producto. El selector lo intercepta el navegador, como
en T-98: el archivo ya descargado se asigna al `<input type=file>`. El origen es
`http://127.0.0.1:5899/` con `build/web` de la copia r4; el archivo,
`T99_SINTETICO_977.edi` (977 contenedores).

| Condición | Rep. | Pasos | Primer cuadro (s) | Clic → rejilla (s) | Total (s) | Previo |
|---|---|---|---|---|---|---|
| Sin perfil, caché caliente | 1 | 3 | 0.212 | 0.209 | 0.421 | sí |
| | 2 | 3 | 0.161 | 0.136 | 0.297 | sí |
| | 3 | 3 | 0.176 | 0.184 | 0.360 | sí |
| | 4 | 3 | 0.184 | 0.141 | 0.325 | sí |
| | 5 | 3 | 0.180 | 0.135 | 0.315 | sí |
| Sin perfil, primera visita (sin caché) | 1 | 3 | 1.308 | 0.202 | 1.510 | sí |
| | 2 | 3 | 1.100 | 0.184 | 1.284 | sí |
| | 3 | 3 | 1.112 | 0.182 | 1.294 | sí |
| | 4 | 3 | 1.068 | 0.220 | 1.288 | sí |
| | 5 | 3 | 1.076 | 0.219 | 1.295 | sí |
| Con perfil (informativa) | 1 | 3 | 2.612 | 0.303 | 2.915 | no: publicado directo |

«Caché caliente» es la visita normal (una navegación de calentamiento que no
cuenta, y el almacén borrado antes de cada repetición); «primera visita» es un
contexto nuevo del navegador por repetición, sin caché ni almacén. La
incertidumbre es un cuadro de animación (la rejilla apareció en el primer
cuadro muestreado tras el clic; el reloj es `performance.now()`). En «con
perfil» el perfil se confirmó antes como lo haría la oficina (Confirmar →
Parámetros del buque → No lo tengo → Confirmar y ver el plano) y la segunda
carga abrió publicada, sin previo: la regla de 7.2. Registros en
`docs/rediseno/fase3/rnf-002/web/` (`sin-caliente/`, `sin-fria/`, `con-perfil/`:
`*-registro.json` con todas las marcas, `resumen.json`, y el inicio y la
rejilla de la primera repetición en PNG).

### 3.6 Capturas

Todas en `docs/rediseno/fase3/`, con datos sintéticos (BUQUE MANUAL de T-100 y
T99 SINTETICO 977), sin cuentas y sin el corpus.

- **Antes (`antes/`, 11):** las del manual de T-100 que muestran lo que cambia: el
  inicio de Windows en oscuro y en claro (`w00-inicio*.png`) y el del Honor con la letra
  normal y grande (`h00-inicio*.png`), con el botón flotante y las acciones repetidas en la
  barra; los viajes recientes como pantalla aparte (`w03`, `h03`); y lo que antes abría
  solo al cargar: «Perfil del buque nuevo», «Parámetros del buque» con «No lo tengo» y la
  escala de llegada (`w04-*`, `h04-escala-llegada.png`).
- **Después, Windows (`despues/arnes-windows/`, 36 PNG + `anchos.jsonl`):** el arnés de
  T-99 (`tool/t114_capturas_windows.ps1`, escenario `inicio`) sobre el banco r4: el inicio
  con un reciente y el previo de un plano de llegada que propone el puerto de salida
  (hallazgo 5), a 360×800, 600×960 y 1920×1080, en claro y oscuro, con la letra a 1.0,
  1.45 y 2.0. `anchos.jsonl` anota, por captura, los textos que el arnés encontró
  recortados: ninguno en el inicio; en el previo a 360 dp con letra 1.45 y 2.0 se recortan
  «Contenido» y «Número de orden», que son los controles del plano de antes y van con la
  entrega del plano.
- **Después, Web (`despues/web/`, 12 PNG):** `tool/t114_capturas_web.py` en el Chrome de
  Playwright: el inicio con un reciente y un perfil guardado, y el previo de un buque
  nuevo, a 360×800, 600×960 y 1280×800, en claro y oscuro.
- **Después, emulador (`despues/emulador/`, 8 PNG):** `tool/t114_capturas_android.py` en
  el emulador API 26 a 360 dp (`wm density 480`): el inicio con un reciente y un perfil
  guardado (BUQUE MANUAL, confirmado desde `T100_CARGA.edi` como lo haría la oficina) y el
  previo de un buque nuevo (`T99_SINTETICO_977.edi`), con la letra del sistema a 1.0, 1.45 y
  2.0 en claro, y a 1.0 en oscuro (Parámetros → Tema → Oscuro). Con ese perfil confirmado
  en GTSTC, `T100_LLEGADA.edi` abre publicado en el emulador, porque propone esa misma
  escala (la regla de 7.2 cumpliéndose): el previo del hallazgo 5 está en las capturas de
  Windows, donde el conductor deja el historial en USHOU. La letra y el tema vuelven a 1.0
  y «Seguir al sistema» al terminar. El Honor no se usó.
- **RNF-002 (`rnf-002/`):** por cliente, el inicio y la rejilla de la primera repetición
  (PNG en Windows y la Web; en Android, los cuadros candidatos del video en JPEG) y los
  registros (3.5).

### 3.7 Archivos de esta entrega

- `lib/core/app.dart` (el tema conectado; autorizado en 10.9).
- `lib/features/vessel/presentation/providers/voyage_ui_state.dart` (nuevo),
  `providers/vessel_providers.dart`, `pages/vessel_overview_page.dart`,
  `pages/stowage_alerts_page.dart`, `widgets/inicio_view.dart` (nuevo),
  `widgets/empty_state_widget.dart`.
- `test/t114_fase3_inicio_test.dart` (nuevo) y las actualizadas de 3.3:
  `test/profile_loading_page_test.dart`, `test/profile_loading_test.dart`,
  `test/profile_persistence_test.dart`, `test/recent_voyages_test.dart`,
  `test/stowage_alerts_page_test.dart`, `test/t104_text_test.dart`,
  `test/t86_baplie_version_test.dart`, `test/t89_file_input_test.dart`.
- `tool/t99_conductor.dart`, `tool/t99_app.dart`, `tool/t99_plataforma_io.dart`,
  `tool/t99_plataforma_web.dart`, `tool/t99_copia.ps1`, `tool/t112_censos.py`
  (modificados); `tool/t114_primera_android.py`, `tool/t114_primera_windows.py`,
  `tool/t114_primera_web.py`, `tool/t114_primera_web.js`, `tool/t114_primera_cuadros.py`,
  `tool/t114_capturas_windows.ps1`, `tool/t114_capturas_android.py`,
  `tool/t114_capturas_web.py` (nuevos).
- `DESIGN.md`.
- `docs/rediseno/fase3/`: `flutter-ui-audit.txt`, `censos/tablas.md`,
  `censos/resumen.json`, `antes/` (las 11 capturas del manual que muestran el inicio,
  los recientes y los parámetros de antes), `despues/` (las capturas nuevas),
  `rnf-002/` (los registros de la medición) y `traspaso-entrega1.md` (el traspaso para el
  chat que sigue, pedido por Yov en el alto parcial).
- `docs/REDISENO-RESULTADOS.md` (esta sección).
- Sin cambios: `domain/`, `data/`, `lib/main.dart`, `pubspec.yaml`, `pubspec.lock`,
  los archivos congelados de H5, las apps instaladas y las carpetas de otras tareas.
  `windows/flutter/generated_plugin*` los regenera `flutter test` y no se versionan
  (10.2).

### 3.8 Lo que no se pudo y lo que queda

- **El navegador integrado de la consola no midió la Web.** Con la sesión sin nadie
  mirando, su panel queda oculto, la página no pinta ni corre
  `requestAnimationFrame` y el primer intento dio 7.99 s de «primer cuadro» que eran del
  panel. La medición se hizo con el Chrome instalado abierto por Playwright en un perfil
  temporal y en una ventana visible (`tool/t114_primera_web.py`): el instrumento cambia
  y queda declarado en 3.5; no se tocó el Chrome de Carlos ni ninguna cuenta.
- **El selector del emulador abre en «Recent», vacío.** El instrumento de Android abre
  su cajón de raíces, entra en Descargas y en `t114` y elige el archivo: sigue siendo el
  paso 3 (el selector cuenta una vez, como en T-98, donde el selector del Honor recordaba
  la carpeta). El tiempo de navegar el selector es del instrumento y no del producto,
  y en el video queda a la vista.
- **A 360 dp con letra 1.45 y 2.0, el previo recorta «Contenido» y «Número de orden»**
  (`anchos.jsonl`): son los controles del plano de antes, no del inicio ni de la banda, y
  van con la entrega del plano.
- **A 360 dp con letra 2.0, la banda del previo parte palabras** («pr-opuesto»,
  «confirmar-:») porque el botón «Confirmar» le deja poco ancho al texto, y la pestaña
  «Estadísticas» se corta (`emulador_360_claro_letra2.0_previo.png`). No se corrigió por el
  alto parcial en lo visual: queda declarado para la dirección nueva (la banda tendría que
  poner la acción debajo del texto cuando no cabe).
- **El Honor no se midió** (el emulador hace de teléfono, como pide la entrega); la
  medición en el Honor queda para cuando Carlos lo autorice, con la letra en 1.0.
- **Alto parcial en lo visual (Yov, 22-oct, durante el cierre):** Carlos y Yov revisan
  una dirección visual nueva («Puente de mando»); lo de la Fase 2 se queda y cambiarán
  valores. Esta entrega se cerró solo en lo funcional (el flujo «ver primero, confirmar
  después», los instrumentos y RNF-002), sin pulir colores, tarjetas ni el inicio más de lo
  que ya estaba. **La entrega 2 (el plano por bahía) no se empieza** hasta que Carlos
  apruebe la dirección. El traspaso para el chat que sigue está en
  `docs/rediseno/fase3/traspaso-entrega1.md`.

### 3.9 Horas

De las 12:20 (aprox.) a las 16:05 del 22-oct-2026: ≈ 3.8 h de reloj, sin
cronómetro (la hora de inicio es la del mensaje de Yov que abre la Fase 3). Incluye las
compilaciones de los tres bancos r4 (Windows, Web y el APK), las mediciones y las capturas.

### Git para Carlos (Fase 3, entrega 1)

```
git add -- DESIGN.md
git add -- lib/core/app.dart
git add -- lib/features/vessel/presentation/providers/voyage_ui_state.dart
git add -- lib/features/vessel/presentation/providers/vessel_providers.dart
git add -- lib/features/vessel/presentation/pages/vessel_overview_page.dart
git add -- lib/features/vessel/presentation/pages/stowage_alerts_page.dart
git add -- lib/features/vessel/presentation/widgets/inicio_view.dart
git add -- lib/features/vessel/presentation/widgets/empty_state_widget.dart
git add -- test/t114_fase3_inicio_test.dart
git add -- test/profile_loading_page_test.dart
git add -- test/profile_loading_test.dart
git add -- test/profile_persistence_test.dart
git add -- test/recent_voyages_test.dart
git add -- test/stowage_alerts_page_test.dart
git add -- test/t104_text_test.dart
git add -- test/t86_baplie_version_test.dart
git add -- test/t89_file_input_test.dart
git add -- tool/t99_conductor.dart
git add -- tool/t99_app.dart
git add -- tool/t99_plataforma_io.dart
git add -- tool/t99_plataforma_web.dart
git add -- tool/t99_copia.ps1
git add -- tool/t112_censos.py
git add -- tool/t114_primera_android.py
git add -- tool/t114_primera_windows.py
git add -- tool/t114_primera_web.py
git add -- tool/t114_primera_web.js
git add -- tool/t114_primera_cuadros.py
git add -- tool/t114_capturas_windows.ps1
git add -- tool/t114_capturas_android.py
git add -- tool/t114_capturas_web.py
git add -- docs/rediseno/fase3/antes/h00-inicio-letra-grande.png
git add -- docs/rediseno/fase3/antes/h00-inicio.png
git add -- docs/rediseno/fase3/antes/h03-viajes-recientes.png
git add -- docs/rediseno/fase3/antes/h04-escala-llegada.png
git add -- docs/rediseno/fase3/antes/w00-inicio-claro.png
git add -- docs/rediseno/fase3/antes/w00-inicio.png
git add -- docs/rediseno/fase3/antes/w03-viajes-recientes.png
git add -- docs/rediseno/fase3/antes/w04-escala-llegada.png
git add -- docs/rediseno/fase3/antes/w04-parametros-arriba.png
git add -- docs/rediseno/fase3/antes/w04-parametros-no-lo-tengo.png
git add -- docs/rediseno/fase3/antes/w04-perfil-buque-nuevo.png
git add -- docs/rediseno/fase3/censos/resumen.json
git add -- docs/rediseno/fase3/censos/tablas.md
git add -- docs/rediseno/fase3/despues/arnes-windows/1920x1080_claro_letra1.0_inicio.png
git add -- docs/rediseno/fase3/despues/arnes-windows/1920x1080_claro_letra1.0_previo.png
git add -- docs/rediseno/fase3/despues/arnes-windows/1920x1080_claro_letra1.45_inicio.png
git add -- docs/rediseno/fase3/despues/arnes-windows/1920x1080_claro_letra1.45_previo.png
git add -- docs/rediseno/fase3/despues/arnes-windows/1920x1080_claro_letra2.0_inicio.png
git add -- docs/rediseno/fase3/despues/arnes-windows/1920x1080_claro_letra2.0_previo.png
git add -- docs/rediseno/fase3/despues/arnes-windows/1920x1080_oscuro_letra1.0_inicio.png
git add -- docs/rediseno/fase3/despues/arnes-windows/1920x1080_oscuro_letra1.0_previo.png
git add -- docs/rediseno/fase3/despues/arnes-windows/1920x1080_oscuro_letra1.45_inicio.png
git add -- docs/rediseno/fase3/despues/arnes-windows/1920x1080_oscuro_letra1.45_previo.png
git add -- docs/rediseno/fase3/despues/arnes-windows/1920x1080_oscuro_letra2.0_inicio.png
git add -- docs/rediseno/fase3/despues/arnes-windows/1920x1080_oscuro_letra2.0_previo.png
git add -- docs/rediseno/fase3/despues/arnes-windows/360x800_claro_letra1.0_inicio.png
git add -- docs/rediseno/fase3/despues/arnes-windows/360x800_claro_letra1.0_previo.png
git add -- docs/rediseno/fase3/despues/arnes-windows/360x800_claro_letra1.45_inicio.png
git add -- docs/rediseno/fase3/despues/arnes-windows/360x800_claro_letra1.45_previo.png
git add -- docs/rediseno/fase3/despues/arnes-windows/360x800_claro_letra2.0_inicio.png
git add -- docs/rediseno/fase3/despues/arnes-windows/360x800_claro_letra2.0_previo.png
git add -- docs/rediseno/fase3/despues/arnes-windows/360x800_oscuro_letra1.0_inicio.png
git add -- docs/rediseno/fase3/despues/arnes-windows/360x800_oscuro_letra1.0_previo.png
git add -- docs/rediseno/fase3/despues/arnes-windows/360x800_oscuro_letra1.45_inicio.png
git add -- docs/rediseno/fase3/despues/arnes-windows/360x800_oscuro_letra1.45_previo.png
git add -- docs/rediseno/fase3/despues/arnes-windows/360x800_oscuro_letra2.0_inicio.png
git add -- docs/rediseno/fase3/despues/arnes-windows/360x800_oscuro_letra2.0_previo.png
git add -- docs/rediseno/fase3/despues/arnes-windows/600x960_claro_letra1.0_inicio.png
git add -- docs/rediseno/fase3/despues/arnes-windows/600x960_claro_letra1.0_previo.png
git add -- docs/rediseno/fase3/despues/arnes-windows/600x960_claro_letra1.45_inicio.png
git add -- docs/rediseno/fase3/despues/arnes-windows/600x960_claro_letra1.45_previo.png
git add -- docs/rediseno/fase3/despues/arnes-windows/600x960_claro_letra2.0_inicio.png
git add -- docs/rediseno/fase3/despues/arnes-windows/600x960_claro_letra2.0_previo.png
git add -- docs/rediseno/fase3/despues/arnes-windows/600x960_oscuro_letra1.0_inicio.png
git add -- docs/rediseno/fase3/despues/arnes-windows/600x960_oscuro_letra1.0_previo.png
git add -- docs/rediseno/fase3/despues/arnes-windows/600x960_oscuro_letra1.45_inicio.png
git add -- docs/rediseno/fase3/despues/arnes-windows/600x960_oscuro_letra1.45_previo.png
git add -- docs/rediseno/fase3/despues/arnes-windows/600x960_oscuro_letra2.0_inicio.png
git add -- docs/rediseno/fase3/despues/arnes-windows/600x960_oscuro_letra2.0_previo.png
git add -- docs/rediseno/fase3/despues/arnes-windows/anchos.jsonl
git add -- docs/rediseno/fase3/despues/emulador/emulador_360_claro_letra1.0_inicio.png
git add -- docs/rediseno/fase3/despues/emulador/emulador_360_claro_letra1.0_previo.png
git add -- docs/rediseno/fase3/despues/emulador/emulador_360_claro_letra1.45_inicio.png
git add -- docs/rediseno/fase3/despues/emulador/emulador_360_claro_letra1.45_previo.png
git add -- docs/rediseno/fase3/despues/emulador/emulador_360_claro_letra2.0_inicio.png
git add -- docs/rediseno/fase3/despues/emulador/emulador_360_claro_letra2.0_previo.png
git add -- docs/rediseno/fase3/despues/emulador/emulador_360_oscuro_letra1.0_inicio.png
git add -- docs/rediseno/fase3/despues/emulador/emulador_360_oscuro_letra1.0_previo.png
git add -- docs/rediseno/fase3/despues/web/web_1280_claro_inicio.png
git add -- docs/rediseno/fase3/despues/web/web_1280_claro_previo.png
git add -- docs/rediseno/fase3/despues/web/web_1280_oscuro_inicio.png
git add -- docs/rediseno/fase3/despues/web/web_1280_oscuro_previo.png
git add -- docs/rediseno/fase3/despues/web/web_360_claro_inicio.png
git add -- docs/rediseno/fase3/despues/web/web_360_claro_previo.png
git add -- docs/rediseno/fase3/despues/web/web_360_oscuro_inicio.png
git add -- docs/rediseno/fase3/despues/web/web_360_oscuro_previo.png
git add -- docs/rediseno/fase3/despues/web/web_600_claro_inicio.png
git add -- docs/rediseno/fase3/despues/web/web_600_claro_previo.png
git add -- docs/rediseno/fase3/despues/web/web_600_oscuro_inicio.png
git add -- docs/rediseno/fase3/despues/web/web_600_oscuro_previo.png
git add -- docs/rediseno/fase3/flutter-ui-audit.txt
git add -- docs/rediseno/fase3/rnf-002/android/con01/captura.json
git add -- docs/rediseno/fase3/rnf-002/android/con01/cuadro-00008.jpg
git add -- docs/rediseno/fase3/rnf-002/android/con01/cuadro-00009.jpg
git add -- docs/rediseno/fase3/rnf-002/android/con01/cuadro-00010.jpg
git add -- docs/rediseno/fase3/rnf-002/android/con01/cuadro-00049.jpg
git add -- docs/rediseno/fase3/rnf-002/android/con01/cuadro-00050.jpg
git add -- docs/rediseno/fase3/rnf-002/android/con01/cuadro-00051.jpg
git add -- docs/rediseno/fase3/rnf-002/android/con01/cuadro-00052.jpg
git add -- docs/rediseno/fase3/rnf-002/android/con01/cuadros.json
git add -- docs/rediseno/fase3/rnf-002/android/resumen.json
git add -- docs/rediseno/fase3/rnf-002/android/sin01/captura.json
git add -- docs/rediseno/fase3/rnf-002/android/sin01/cuadro-00010.jpg
git add -- docs/rediseno/fase3/rnf-002/android/sin01/cuadro-00011.jpg
git add -- docs/rediseno/fase3/rnf-002/android/sin01/cuadro-00012.jpg
git add -- docs/rediseno/fase3/rnf-002/android/sin01/cuadro-00057.jpg
git add -- docs/rediseno/fase3/rnf-002/android/sin01/cuadro-00058.jpg
git add -- docs/rediseno/fase3/rnf-002/android/sin01/cuadro-00059.jpg
git add -- docs/rediseno/fase3/rnf-002/android/sin01/cuadro-00060.jpg
git add -- docs/rediseno/fase3/rnf-002/android/sin01/cuadros.json
git add -- docs/rediseno/fase3/rnf-002/android/sin02/captura.json
git add -- docs/rediseno/fase3/rnf-002/android/sin02/cuadro-00009.jpg
git add -- docs/rediseno/fase3/rnf-002/android/sin02/cuadro-00010.jpg
git add -- docs/rediseno/fase3/rnf-002/android/sin02/cuadro-00011.jpg
git add -- docs/rediseno/fase3/rnf-002/android/sin02/cuadro-00059.jpg
git add -- docs/rediseno/fase3/rnf-002/android/sin02/cuadro-00060.jpg
git add -- docs/rediseno/fase3/rnf-002/android/sin02/cuadro-00061.jpg
git add -- docs/rediseno/fase3/rnf-002/android/sin02/cuadro-00062.jpg
git add -- docs/rediseno/fase3/rnf-002/android/sin02/cuadros.json
git add -- docs/rediseno/fase3/rnf-002/android/sin03/captura.json
git add -- docs/rediseno/fase3/rnf-002/android/sin03/cuadro-00010.jpg
git add -- docs/rediseno/fase3/rnf-002/android/sin03/cuadro-00011.jpg
git add -- docs/rediseno/fase3/rnf-002/android/sin03/cuadro-00012.jpg
git add -- docs/rediseno/fase3/rnf-002/android/sin03/cuadro-00057.jpg
git add -- docs/rediseno/fase3/rnf-002/android/sin03/cuadro-00058.jpg
git add -- docs/rediseno/fase3/rnf-002/android/sin03/cuadro-00059.jpg
git add -- docs/rediseno/fase3/rnf-002/android/sin03/cuadro-00060.jpg
git add -- docs/rediseno/fase3/rnf-002/android/sin03/cuadros.json
git add -- docs/rediseno/fase3/rnf-002/android/sin04/captura.json
git add -- docs/rediseno/fase3/rnf-002/android/sin04/cuadro-00010.jpg
git add -- docs/rediseno/fase3/rnf-002/android/sin04/cuadro-00011.jpg
git add -- docs/rediseno/fase3/rnf-002/android/sin04/cuadro-00012.jpg
git add -- docs/rediseno/fase3/rnf-002/android/sin04/cuadro-00057.jpg
git add -- docs/rediseno/fase3/rnf-002/android/sin04/cuadro-00058.jpg
git add -- docs/rediseno/fase3/rnf-002/android/sin04/cuadro-00059.jpg
git add -- docs/rediseno/fase3/rnf-002/android/sin04/cuadro-00060.jpg
git add -- docs/rediseno/fase3/rnf-002/android/sin04/cuadros.json
git add -- docs/rediseno/fase3/rnf-002/android/sin05/captura.json
git add -- docs/rediseno/fase3/rnf-002/android/sin05/cuadro-00010.jpg
git add -- docs/rediseno/fase3/rnf-002/android/sin05/cuadro-00011.jpg
git add -- docs/rediseno/fase3/rnf-002/android/sin05/cuadro-00012.jpg
git add -- docs/rediseno/fase3/rnf-002/android/sin05/cuadro-00060.jpg
git add -- docs/rediseno/fase3/rnf-002/android/sin05/cuadro-00061.jpg
git add -- docs/rediseno/fase3/rnf-002/android/sin05/cuadro-00062.jpg
git add -- docs/rediseno/fase3/rnf-002/android/sin05/cuadro-00063.jpg
git add -- docs/rediseno/fase3/rnf-002/android/sin05/cuadros.json
git add -- docs/rediseno/fase3/rnf-002/web/con-perfil/con00-publicado.png
git add -- docs/rediseno/fase3/rnf-002/web/con-perfil/con01-inicio.png
git add -- docs/rediseno/fase3/rnf-002/web/con-perfil/con01-registro.json
git add -- docs/rediseno/fase3/rnf-002/web/con-perfil/con01-rejilla.png
git add -- docs/rediseno/fase3/rnf-002/web/con-perfil/resumen.json
git add -- docs/rediseno/fase3/rnf-002/web/sin-caliente/resumen.json
git add -- docs/rediseno/fase3/rnf-002/web/sin-caliente/sin01-inicio.png
git add -- docs/rediseno/fase3/rnf-002/web/sin-caliente/sin01-registro.json
git add -- docs/rediseno/fase3/rnf-002/web/sin-caliente/sin01-rejilla.png
git add -- docs/rediseno/fase3/rnf-002/web/sin-caliente/sin02-registro.json
git add -- docs/rediseno/fase3/rnf-002/web/sin-caliente/sin03-registro.json
git add -- docs/rediseno/fase3/rnf-002/web/sin-caliente/sin04-registro.json
git add -- docs/rediseno/fase3/rnf-002/web/sin-caliente/sin05-registro.json
git add -- docs/rediseno/fase3/rnf-002/web/sin-fria/resumen.json
git add -- docs/rediseno/fase3/rnf-002/web/sin-fria/sin01-inicio.png
git add -- docs/rediseno/fase3/rnf-002/web/sin-fria/sin01-registro.json
git add -- docs/rediseno/fase3/rnf-002/web/sin-fria/sin01-rejilla.png
git add -- docs/rediseno/fase3/rnf-002/web/sin-fria/sin02-registro.json
git add -- docs/rediseno/fase3/rnf-002/web/sin-fria/sin03-registro.json
git add -- docs/rediseno/fase3/rnf-002/web/sin-fria/sin04-registro.json
git add -- docs/rediseno/fase3/rnf-002/web/sin-fria/sin05-registro.json
git add -- docs/rediseno/fase3/rnf-002/windows/con01/registro.json
git add -- docs/rediseno/fase3/rnf-002/windows/resumen-con.json
git add -- docs/rediseno/fase3/rnf-002/windows/resumen-sin.json
git add -- docs/rediseno/fase3/rnf-002/windows/sin01-inicio.png
git add -- docs/rediseno/fase3/rnf-002/windows/sin01-rejilla.png
git add -- docs/rediseno/fase3/rnf-002/windows/sin01/registro.json
git add -- docs/rediseno/fase3/rnf-002/windows/sin02/registro.json
git add -- docs/rediseno/fase3/rnf-002/windows/sin03/registro.json
git add -- docs/rediseno/fase3/rnf-002/windows/sin04/registro.json
git add -- docs/rediseno/fase3/rnf-002/windows/sin05/registro.json
git add -- docs/rediseno/fase3/traspaso-entrega1.md
git add -- docs/REDISENO-RESULTADOS.md
git commit -m "Sprint 4: rediseno, fase 3, entrega 1, el inicio y la primera visualizacion en tres pasos con el previo"
git push
```

### Tres líneas

- El inicio y el previo de `DESIGN.md` (7 y 9.1) están en la presentación: estados
  sellados (`voyage_ui_state.dart`), el previo en el notifier sin tocar `domain/` ni
  `data/`, la regla estricta de publicación directa con «la última escala confirmada para
  ese buque», el inicio nuevo (`inicio_view.dart`) y el tema conectado en `app.dart`.
- RNF-002: tres pasos en Windows, la Web y Android (antes seis), con tiempos de 0.3 a 3.3 s
  contra 30; instrumentos nuevos por cliente (`tool/t114_primera_*`), declarados, y los de
  T-98 intactos.
- Suite 1156, `analyze` en cero, auditoría sin críticos ni avisos en lo tocado, censos
  limpios; capturas del antes y del después en `docs/rediseno/fase3/`.

### Mensaje para Yov

Yov: Fase 3, entrega 1, lista para Codex. Tema conectado en `app.dart` (claro y oscuro con
la preferencia de T-90, densidad por plataforma); estados del viaje en una `sealed class`
(`presentation/providers/voyage_ui_state.dart`); el previo vive en el notifier (lo muestra
sin guardar, `_publish` sigue siendo la única escritura, `publishedVoyage` no lo ve, así que
peso por pila y tomas quedan «sin evaluar hasta confirmar el perfil»); regla estricta de
7.2 en `_useProfile`: cubre la carga **y** la escala propuesta es la última confirmada para
ese buque (del almacén que ya existe) **y** el archivo dice si es llegada o carga; si no,
previo. Hallazgo 5 probado: la llegada que propone el puerto de salida abre en previo. El
inicio de 9.1 (`inicio_view.dart`): una acción, recientes, perfiles, nube con cuenta; sin
botón flotante ni acciones repetidas. Sin navegación adaptable: no hizo falta para el
inicio, va con el plano. RNF-002 en tres pasos en los tres clientes (antes seis): Windows
1.83–1.90 s, Web 0.30–0.42 s (primera visita 1.28–1.51), emulador cotas 2.98–3.25 s;
instrumentos nuevos y declarados (`tool/t114_primera_*`; la Web se midió con el Chrome
instalado abierto por Playwright en un perfil temporal porque el navegador integrado no
pinta oculto; los de T-98 intactos). Suite 1156 (1143 + 13; 19 actualizadas, ninguna
omitida), `analyze` 0, auditoría 17/231/19 con cero críticos y cero avisos en lo tocado,
censos 1816 cadenas sin inglés y M3 259/8/5 sin excepciones nuevas. Capturas antes y
después (Windows 36, Web 12, emulador 8, más las de RNF-002) en `docs/rediseno/fase3/`.
Queda anotado: a 360 dp con letra 1.45 y 2.0 el previo recorta «Contenido» y «Número de
orden», que son controles del plano de antes y van con la entrega del plano; el Honor no
se tocó. Por tu alto parcial, la entrega se cerró solo en lo funcional y la entrega 2 no
se empieza; el traspaso para el chat que sigue está en
`docs/rediseno/fase3/traspaso-entrega1.md`. Me detengo: Codex acepta.

---

## Fase 3 · Entrega 1 · Corrección tras la aceptación de Codex (22-oct-2026, 10.15)

Codex dictaminó NO PASA (`docs/rediseno/fase3/aceptacion-codex.md`, sobre `16fa15d`): H1
bloquea y O1 a O3 son observaciones mías; O4 (el informe de la Fase 2 ausente en la copia
de QA) lo resuelve Carlos. Esta corrección va en su propio bloque de git, separada de la
Fase 1 bis y la Fase 2 bis, que siguen después en este mismo informe.

### 3c.1 Resultado en tres líneas

- **H1, «No lo tengo» ya no viene marcado por una plantilla ni por la propuesta del
  archivo.** En `vessel_geometry_page.dart` (`initState`) la casilla empieza marcada solo si
  el perfil es de este mismo buque, lo declaró el usuario (`declaredByUser`) y no tiene
  límite; en los demás casos el usuario tiene que elegir, y sin elegir no se confirma.
  Cuatro pruebas nuevas lo fijan, incluido el caso de Codex (BUQUE BETA como plantilla
  para BUQUE ALFA).
- **O1, la carpeta `con`** (un dispositivo reservado de Windows, que Git no veía) se
  renombró a `con-perfil` con sus cinco archivos intactos; el instrumento Web escribe en
  `con-perfil` y rechaza nombres reservados; el informe y su bloque de git apuntan a la
  ruta nueva. **O2,** las tres comparaciones de `profile_loading_test.dart` vuelven a
  comparar los campos del perfil, salvo `updatedAt`. **O3,** la referencia `5406e20` de
  los censos queda declarada en 3.4 y en la ayuda de `tool/t112_censos.py`.
- Validado en una copia limpia de `HEAD` con solo estos archivos encima: `analyze` **«No
  issues found»** y la suite **1159 en verde de 1160, 0 omitidas, y un solo fallo que no es del producto: `t114_fuentes_test` espera `LICENSE-IBMPlex.txt` con 4456 bytes (CRLF, como está en el árbol) y `git archive` lo exporta con 4363 (LF); en el árbol esa prueba pasa**. Piso: 1156 → **1160** (4 nuevas, ninguna
  omitida). La Fase 2 bis no entra en este bloque.

### 3c.2 Lo hecho, hallazgo por hallazgo

- **H1 (`lib/features/vessel/presentation/pages/vessel_geometry_page.dart:171`).** Antes:
  marcado si había geometría inicial, o era solo el perfil, o el perfil venía de plantilla,
  siempre que el límite fuera nulo. Ahora:
  `mismoBuque && perfil.origin == declaredByUser && start.stackWeightLimitKg == null`,
  donde `mismoBuque` es que el perfil tenga la clave del buque del viaje (o que no haya
  viaje, al editar el perfil solo). `useTemplate` clona con origen `template` y la
  propuesta del archivo nace `proposedFromFile`, así que las dos empiezan sin marcar;
  `_canConfirm` ya exigía `_limitResolved`, así que sin escribir el límite ni marcar la
  casilla el botón sigue deshabilitado. No cambia nada más de la página.
- **Pruebas (`test/t114_fase3_correccion_test.dart`, 4):** la plantilla sin límite de otro
  buque empieza sin marcar y no se confirma hasta marcar; la propuesta del archivo empieza
  sin marcar y escribir el límite también resuelve; el perfil declarado del mismo buque sin
  límite viene marcado, con viaje y al editar el perfil solo; y un perfil declarado de otro
  buque no marca nada. Abren `VesselGeometryPage` con la propuesta y las posiciones del
  archivo sintético de BUQUE ALFA (`profileTestEdi`), sin almacén.
- **O1.** `docs/rediseno/fase3/rnf-002/web/con` → `con-perfil`, renombrada con el prefijo
  `\\?\` desde Python (ni Git ni el Explorador la veían): los cinco archivos
  (`con00-publicado.png`, `con01-inicio.png`, `con01-registro.json`, `con01-rejilla.png`,
  `resumen.json`) son los mismos bytes; la medición no se regeneró.
  `tool/t114_primera_web.py` crea ahora la subcarpeta de la corrida por su condición
  (`sin-caliente`, `sin-fria`, `con-perfil`) y rechaza cualquier parte de la ruta que sea
  `con`, `prn`, `aux`, `nul`, `com1` a `com9` o `lpt1` a `lpt9`; su docstring lo explica.
  En este informe, 3.5 y el bloque de git de la entrega 1 apuntan a `con-perfil/`.
- **O2 (`test/profile_loading_test.dart`).** `_mismoPerfil` compara identidad, nombre,
  geometría (con el límite), tapas, bahías de bodega observadas, tomas y los dos orígenes,
  y se usa en los tres puntos (antes `.key`, `.key` y `hasLength(1)`); `updatedAt` queda
  fuera porque confirmar otra vez lo cambia.
- **O3.** La ayuda de `--antes` en `tool/t112_censos.py` dice que la referencia es el
  `lib/` de `5406e20` (con `sprint3-cierre` las decisiones por línea no coinciden), y 3.4
  lo declara con las cifras que Codex obtuvo con la otra referencia (1834 y M3 251/16/0).

### 3c.3 Validaciones ejecutadas

Para no mezclar esta corrección con la Fase 2 bis, que ya estaba escrita en el árbol, la
validé en una copia limpia: `git archive HEAD` (`16fa15d`) exportado a TEMP, más los
archivos de esta corrección y el `package_config.json` del árbol; un comando de Flutter a
la vez, en segundo plano.

- `flutter analyze --no-pub` en la copia → **«No issues found»**.
- `flutter test --no-pub` en la copia → **`+1159 -1`, 0 omitidas (1160 = 1156 + 4). El fallo es `t114_fuentes_test.dart` «provenance.json cubre los siete TTF y la licencia»: `LICENSE-IBMPlex.txt` mide 4363 bytes en la copia (LF, lo que `git archive` exporta) y 4456 en el árbol (CRLF, lo que `provenance.json` registra). Es de la copia, no del producto: en el árbol la prueba pasa (abajo, 2b.4) y Codex la vio pasar en la suya. La primera corrida en la copia tenía además dos fallos de mi prueba nueva (el perfil propuesto no cubría las posiciones sintéticas que le pasaba a la página); se corrigió la prueba, no el producto, y la segunda corrida es la de arriba.**
- `flutter test --no-pub test/t114_fase3_correccion_test.dart` en el árbol → `+4: All tests
  passed!`.
- `python -X utf8 -I -c "import ast; ast.parse(open('tool/t114_primera_web.py').read())"` →
  compila; no se corrió el instrumento (no se regenera la medición).

### 3c.4 Archivos de esta corrección

- `lib/features/vessel/presentation/pages/vessel_geometry_page.dart` (la condición de
  `_limitUnavailable`).
- `test/t114_fase3_correccion_test.dart` (nuevo, 4 pruebas) y `test/profile_loading_test.dart`.
- `tool/t114_primera_web.py` y `tool/t112_censos.py`.
- `docs/rediseno/fase3/rnf-002/web/con-perfil/` (los cinco archivos, renombrados; eran los
  que faltaban en `a609241`).
- `docs/REDISENO-RESULTADOS.md` (3.4, 3.5, el bloque de la entrega 1 y esta sección).
- Sin cambios: `domain/`, `data/`, `lib/main.dart`, `pubspec.*`, los congelados, los
  instrumentos de T-98 y `lib/core/design/` (que cambia en la Fase 2 bis, aparte).

### 3c.5 Horas

De las 16:50 (el mensaje de Carlos con 10.15) a las 17:10 del 22-oct-2026, entre la Fase 1 bis
y la Fase 2 bis: ≈ 0.3 h, con las dos corridas de la copia limpia en segundo plano.

### Git para Carlos (Fase 3, entrega 1, corrección)

Este bloque va **antes** del de la Fase 1 bis y la Fase 2 bis. Los cinco archivos de
`con-perfil` son los de la entrega 1 que Git no pudo agregar.

```
git add -- lib/features/vessel/presentation/pages/vessel_geometry_page.dart
git add -- test/t114_fase3_correccion_test.dart
git add -- test/profile_loading_test.dart
git add -- tool/t114_primera_web.py
git add -- tool/t112_censos.py
git add -- docs/rediseno/fase3/rnf-002/web/con-perfil/con00-publicado.png
git add -- docs/rediseno/fase3/rnf-002/web/con-perfil/con01-inicio.png
git add -- docs/rediseno/fase3/rnf-002/web/con-perfil/con01-registro.json
git add -- docs/rediseno/fase3/rnf-002/web/con-perfil/con01-rejilla.png
git add -- docs/rediseno/fase3/rnf-002/web/con-perfil/resumen.json
git add -- docs/REDISENO-RESULTADOS.md
git commit -m "Sprint 4: correccion de la entrega 1, No lo tengo sin marcar por omision, carpeta con-perfil y pruebas"
git push
```

Nota: `docs/REDISENO-RESULTADOS.md` lleva también, más abajo, las secciones de la Fase 1
bis y la Fase 2 bis; si Carlos quiere los dos commits con informes separados, este
`git add` del informe puede ir en el segundo bloque y aquí solo el resto.

### Tres líneas

- «No lo tengo» viene marcado solo con un perfil declarado por el usuario para este mismo
  buque y sin límite; plantilla y propuesta empiezan sin marcar, y sin elegir no se confirma.
- La evidencia Web «con perfil» vuelve a existir para Git en `con-perfil`, el instrumento
  no vuelve a crear un nombre reservado, y las tres aserciones comparan el perfil completo.
- Piso 1156 → 1160, `analyze` en cero, validado en una copia limpia de `16fa15d` con solo
  la corrección encima.

---

## Fase 1 bis · La dirección C «Puente de mando» en `DESIGN.md` (22-oct-2026)

### 1b.1 Resultado en tres líneas

- `DESIGN.md` tiene la dirección C en una sección nueva, la **13**, que pasa a ser la
  activa; la A queda en la 4 como historia, con la línea de por qué cambió (10.14), y las
  secciones 2, 3, 5, 9 y 12 anotan dónde la 13 las sustituye. Ningún archivo de `lib/`
  cambió en esta fase.
- La 13 trae la noche y el día con los roles de M3 y los de `BsColoresSemanticos` y el
  contraste de cada pareja; el plano como el ícono (los cinco estados de la vista Estado,
  el casco de la bodega, la curva de las celdas de los extremos y el radio 8); la regla del
  naranja; las fichas en OKLCH con la tabla reordenada y sus 24 valores; el tema por
  omisión según el equipo; las nueve piezas con su API; dónde va la marca; los dos
  wireframes que cambian; lo que no se toma y los datos que no se inventan; y los tokens
  y duraciones que cambian en la Fase 2.
- Todo número de contraste del documento sale de `tool/rediseno_contraste.py`, que ahora
  calcula la noche, las fichas en OKLCH y la permutación, con 0 pares que no cumplen
  (`docs/rediseno/fase2bis/contraste.md`).

### 1b.2 Lo hecho

- Leí `CLAUDE.md`, `AGENTS.md`, `SPRINT-4.md` (la sección 2, T-114 y 10.1 a 10.14), el
  traspaso de la entrega 1, `DESIGN.md`, las cuatro mesas del concepto por sus valores
  exactos (`docs/rediseno/concepto/*.dc.html`; no hay PNG), `design/icono/baystream.svg`
  y su `LEEME.md`, `lib/core/design/**` y las secciones de las Fases 2 y 3 del informe.
  El paso 0 estaba en orden: la entrega 1 en `a609241` y su sección en el informe.
- **La noche, calculada antes de escribirla.** Las parejas de 10.14 se verificaron una por
  una (16.5, 15.2 y 13.8 la tinta; 9.5, 8.7 y 8.0 la tinta suave; 5.9 la selección; 8.6
  el blanco sobre la marca; 3.9, 3.6, 3.3 y 3.3 la línea fuerte). Dos decisiones que el
  concepto no fijaba: **la marca `#0D47A1` no sirve como texto de noche** (1.6:1 sobre la
  noche), así que `primary` pasa a la selección `#4F8EF7` (5.9:1) y la marca queda como
  superficie (`primaryContainer`, el riel activo, la banda); y **la selección de segmentos
  y chips se invierte de noche** (tinta con la noche encima, 16.5:1), como el «Descarga»
  del lienzo. Se añade la **tinta tenue** (`#8DA0BE` / `#566986`, 7.1 y 5.2 sobre el
  papel) para los metadatos terciarios del concepto, y la **marca profunda** `#0A3A85` y
  la **frase** `#BCD2F7` de la banda (10.7 y 5.6 con blanco y sobre la marca).
- **Las fichas en OKLCH.** Implementé la conversión OKLCH → sRGB (Ottosson) en el script;
  con la receta del encargo (suaves: relleno L 0.34 C 0.075, código y contorno L 0.84
  C 0.12) salen los valores del lienzo: ámbar `#4E3100` / `#F8BF6C`, hierba `#1B421E` /
  `#98DF9A` y uva `#462B52` exactos; cielo y rosa difieren por unas unidades porque el
  lienzo recortó la gama de otra forma (el script baja el croma hasta que el color quepa,
  sin tocar tono ni luminosidad). **Las intensas** las elegí probando cinco recetas:
  relleno L 0.44 C 0.12 y código y contorno L 0.93 C 0.06, que separan a las suaves por
  luminosidad (el relleno más claro y cromático, el código más claro: relación 1.3 a 1.5
  con la suave del mismo tono) y dan 6.1 a 6.7 de código sobre relleno y 12.7 a 13.3 de
  contorno sobre los fondos; las recetas más oscuras (L 0.25 a 0.27) daban más contraste
  (11 a 12) pero se separaban menos de las suaves.
- **La tabla reordenada** es una permutación de qué tono pinta cada ranura; los códigos y
  el FNV-1a no cambian. En la rueda de doce tonos a 30°, los cinco primeros puertos quedan
  en 345°, 195°, 105°, 285° y 45° (mínimo 60° entre cualquier par; antes 30°); en los matices
  OKLCH de las fichas, que no van a pasos iguales, uva y rosa quedan a 55°, y así lo dice
  13.4. La 5.3 y la 5.2 del documento remiten a la 13.4.
- **La regla del naranja** (13.3) se escribió completa, con lo que el concepto dejaba
  implícito: la pantalla apaga el estado (la celda no tiene reloj), el destello de la
  silueta dura lo mismo, con reducción de movimiento nada se mueve (la celda queda naranja
  en su sitio y el destello es un anillo fijo), y el anuncio al lector de pantalla va en
  el panel «En vivo» y en la etiqueta de la celda.
- **El tema por omisión** (13.5) se escribió con su límite: el almacén devuelve `system`
  tanto si el usuario nunca eligió como si eligió «Seguir al sistema»; sin tocar `data/`
  no se distinguen. Queda declarada la decisión de esta fase y las dos salidas para
  Carlos (abajo, 2b.6).
- **Las piezas** (13.6) quedaron con su API escrita antes del código: `BsMarca`,
  `BsSiluetaBuque` (evoluciona `BsTiraDeBahias`, que se conserva), `BsCascoBodega`, los
  estados y la curva de `BsCelda`, `BsTarjetaCifra`, `BsAnilloAvance`, `BsPanelEnVivo` (su
  API solo admite el rol del equipo: `BsEquipo.muelle` u `oficina`), `BsBandaMuelle` y
  `BsFondoDePlano`.
- **Los wireframes** 9.2 (1920 px) y 9.3 (360 dp) quedaron sustituidos por los de 13.8:
  el plano de noche con el riel, la silueta, las cuatro tarjetas, la bahía como el ícono,
  el detalle y «En vivo»; y el muelle de día con la banda, «Baja» en la marca y la celda
  que sale de su sitio. Sin «Grúa 2» ni nombres de equipos.
- **Lo que cambia en los tokens** (13.10): `radioCelda` 2 → 8 (las esquinas del ícono),
  `radioPanel` 18, `radioCasco` 18, `pasoRejilla` 32; `BsMovimiento.recienMovido` 1500 ms,
  `salida` 150, `espera` 1200, `pulso` 2200; `BsRol.punteado`; y la regla nueva de la celda
  atenuada (abajo).
- **Un hallazgo del instrumento al escribir el documento:** con los rellenos nuevos de «por
  bajar», la celda atenuada (relleno al 35 %, código en tinta suave) deja el código en
  **3.5:1 de día y 3.1:1 de noche**. La regla de 10.7 pasa a «tinta suave, y si no llega a
  4.5:1 sobre lo compuesto, tinta», decidida por el rol y verificada compuesta; con los 42
  rellenos de cada modo, caen a tinta 2 de día y 1 de noche y el peor queda en 4.69 y 5.10.
  Está en 13.2, en el script y en `BsRol.atenuado` (Fase 2 bis).

### 1b.3 Validaciones ejecutadas

- `python -X utf8 -I tool/rediseno_contraste.py` → «Pares que no cumplen: 0» sobre la
  dirección C en claro y en oscuro (27 pares por modo), la A oscura como historia, las 24
  ranuras en los dos modos (texto y contorno), 19 roles semánticos × 2 modos y la celda
  atenuada con los 42 rellenos por modo. Salida en `docs/rediseno/fase2bis/contraste.md`.
- Los valores de las fichas se cotejaron con los cinco ejemplos de `Sistema.dc.html`
  (arriba). No se compiló ni se corrió la app: la fase no toca `lib/`.

### 1b.4 Archivos de esta fase

`DESIGN.md` (sección 13 nueva, 357 líneas; cabecera, 2, 3, 4, 5.1, 5.2, 5.3, 9.2, 9.3 y 12
anotadas), `tool/rediseno_contraste.py` (la dirección C, OKLCH, la permutación, las fichas,
el respaldo a tinta de la celda atenuada y `--dart`) y `docs/rediseno/fase2bis/contraste.md`.

### 1b.5 Lo que no se pudo y por qué

- No hay exportaciones PNG del concepto en `docs/rediseno/concepto/`, así que las mesas se
  leyeron por su código; los valores que cito son los del código del lienzo.
- La ilustración de la grúa del inicio y el dibujo del muelle de las pantallas vacías no
  se diseñan aquí: llegan en el paquete de 10.14 (13.7 y 13.9).

### 1b.6 Horas

De las 16:15 (aprox., el mensaje de Carlos con el encargo) a las 16:45 del 22-oct-2026:
≈ 0.5 h, con las lecturas del paso 0 y del contexto.

---

## Fase 2 bis · La fundación de la dirección C (22-oct-2026)

### 2b.1 Resultado en tres líneas

- La noche está en `bs_paleta.dart` y en `BayStreamTema.oscuro`; el día no cambia. Los
  roles de la vista Estado, el rol «información», la tinta tenue y las fichas de noche
  están en `bs_colores_semanticos.dart`; la tabla reordenada en `bs_categorico.dart` y en
  el script; el tema por omisión según el equipo en `lib/core/app.dart`; y las nueve piezas
  nuevas en `lib/core/design/componentes/`, con vista previa, documentación y prueba.
  **Ninguna pantalla cambia todavía**: solo cambian los valores del tema que ya estaba
  conectado.
- Suite **1223** (piso 1160 tras la corrección + 63 nuevas, ninguna
  omitida); `analyze` **«No issues found»**; contraste con 0 pares que no cumplen; auditoría de
  `flutter-ui` con **cero críticos y cero avisos en `lib/core/design/`** fuera de los dos
  archivos de tokens, que son la única fuente de color (17 críticos, 272 avisos y 19 informativos en 165 archivos; los 41 avisos nuevos son hexadecimales en `bs_paleta.dart` y `bs_colores_semanticos.dart`).
- Me detengo: **ALTO: Codex acepta la Fase 2 bis**. Después viene la Fase 3 con el plano
  por bahía, ya en la dirección C.

### 2b.2 Lo hecho

1. **La noche (`bs_paleta.dart`, `bs_tema.dart`).** `BsPaleta.oscuro` lleva los valores de
   13.1 y la clase suma cinco colores con nombre en los dos modos: `tintaTenue`,
   `marcaSuperficie`, `sobreMarcaSuperficie`, `sobreMarcaSuave` y `marcaProfunda`. En el
   tema: `primary` es la selección de noche; `primaryContainer` la marca como superficie;
   el indicador del riel y de la barra lleva el icono en blanco de noche y en tinta de
   día; los segmentos y los chips seleccionados se invierten de noche (tinta con la noche
   encima); la pista de las barras de progreso es la línea de noche. El día es byte a byte
   el de la Fase 2.
2. **Los roles (`bs_colores_semanticos.dart`).** Nuevos: `informacion` (la banda, que ya no
   toma el esquema: de noche el icono en marca no llegaba a 3:1 sobre la marca como
   superficie), `porBajarCubierta`, `porBajarBodega`, `bajado`, `recienMovido` y el color
   `tintaTenue`. Los de la Fase 2 toman los valores de la noche (de paso apagado en el
   panel alto; hecho, revisar y error con los contornos de 10.14; cubierta y bodega con el
   panel y el acero tenue). `BsRol` suma `punteado` (el bajado de noche) y `atenuado`
   acepta `tinta` como respaldo cuando la tinta suave no llega a 4.5:1 sobre lo compuesto.
   Las 24 ranuras se regeneraron con `--dart`: de día los rellenos de la Fase 2 en el orden
   nuevo; de noche las fichas.
3. **La tabla reordenada (`bs_categorico.dart`).** `tonosPorRanura` = `[11, 6, 3, 9, 1, 8,
   4, 0, 10, 5, 2, 7]`, `tonoDeRanura(k)` y `nombresDeTono`; `tablaFijaDePuertos`,
   `tablaFijaDeTipos` y `ranuraCategorica` (FNV-1a) no cambian.
4. **El tema por omisión (`lib/core/app.dart`): preparado, no conectado.**
   `bayStreamTemaPorOmision` (oscuro salvo en Android e iOS) está listo y probado, pero
   `bayStreamThemeMode` deja `system` → `ThemeMode.system`: la prueba de T-90
   (`t90_theme_test`, «sistema responde y elección explícita prevalece») exige que «Seguir
   al sistema» siga al sistema, y el almacén devuelve el mismo `system` para quien nunca
   eligió. Resolverlo exige `domain/` y `data/`, así que lo propongo y me detengo en ese
   punto (2b.6); el resto de la fase no depende de él.
5. **Las piezas**, todas en `lib/core/design/componentes/`:
   - `BsMarca` (`bs_marca.dart`): el ícono pintado desde la geometría del SVG (las ocho
     celdas de cubierta con el hueco, la tapa, las seis celdas y los ocho bloques curvos de
     la bodega transcritos punto a punto, el contenedor), con recuadro (lienzo de 126.6 y
     esquinas de 27), sin recuadro y monocroma; la espera sube y baja el contenedor medio
     módulo (6.9 unidades) con `Transform` en un bucle de 1.2 s; `RepaintBoundary`;
     etiqueta «BayStream» y «BayStream, leyendo».
   - `BsSiluetaBuque` (`bs_silueta_buque.dart`): el casco (proa a la izquierda, línea de
     flotación, sin superestructura), una pila por bahía (niveles de cubierta sobre la
     tapa, de bodega dentro del casco; con trabajo más claras, las demás apagadas), la
     seleccionada en cubierta y acero con su marco, el número y la barra de avance bajo
     cada bahía (hecho si llegó a 1, marca si va), el destello de la recién movida
     (anillo en grúa que se apaga en 1.5 s; fijo con reducción de movimiento), «Proa» y
     «Popa»; cada bahía es un botón de 56 dp con etiqueta («Bahía 14, 4 niveles en cubierta
     y 4 en bodega, avance 25 %»). El alto sale de los niveles y de la escala de letra.
   - `BsCascoBodega` (`bs_casco_bodega.dart`): el casco detrás de las filas de bodega, en
     acero tenue con contorno de línea fuerte, dentro de un `RepaintBoundary`.
   - `BsCelda` (`bs_celda.dart`): `estado` (los cinco de 13.2) y `curva` (babor, estribor,
     ambas; radio 18 en la esquina exterior); el estado manda en el relleno y la marca pone
     icono y rótulo («Bajando» y «Subiendo» cuando se acaba de mover); bajado sin marca es
     solo la palomita; el contorno punteado es un `CustomPainter` público
     (`BsContornoPunteado`) para que las pruebas midan su color; recién movida sale de su
     celda con `AnimatedSlide` (media celda, 150 ms) sobre el hueco punteado en grúa y
     añade «se acaba de mover» a su etiqueta; con reducción de movimiento se queda quieta
     y naranja. La celda atenuada usa la tinta como respaldo (13.2).
   - `BsTarjetaCifra` y `BsAnilloAvance`: la tarjeta del mosaico (hoja, radio 18, borde en
     línea o teñido por el rol; rótulo, cifra a 34 / 600 tabular, detalle en tinta tenue;
     etiqueta «Por bajar: 30, 18 en la bahía 14») y el anillo (pista en línea, arco desde
     las doce, sin animación; «80 por ciento»).
   - `BsPanelEnVivo` y `BsPulso`: el panel de 13.6 con el rol del equipo por enum, el tipo
     del evento que decide la marca de color, el momento o la acción, la región en vivo en
     el evento más reciente y el punto que pulsa en opacidad (quieto con reducción de
     movimiento o sin conexión).
   - `BsBandaMuelle` y `BsChipDeNube`: la banda en la marca como superficie, con la marca
     sin recuadro, el buque, el viaje, el chip de la nube (marca profunda, punto en hecho)
     y el `SegmentedButton` Descarga / Carga de 48 dp (seleccionado blanco con texto
     marca).
   - `BsFondoDePlano`: la rejilla de 32 dp en acero al 5 % solo de noche.
   - `BsBanda` toma el rol `informacion`; `design.dart` exporta las piezas nuevas.
6. **Las medidas y el movimiento.** `radioCelda` 8, `radioPanel` 18, `radioCasco` 18 y
   `pasoRejilla` 32 en las dos densidades; `BsMovimiento.salida`, `recienMovido`,
   `espera`, `pulso`, `vaiven` y `reducido(context)`.
7. **Las vistas previas (`vistas_previas.dart`).** Ocho nuevas: las celdas de la vista
   Estado de noche con el casco y de día en el muelle, la marca, la silueta, las tarjetas,
   «En vivo», la banda del muelle y el fondo de plano; las de la Fase 2 se conservan.
8. **El informe de la corrección** de la entrega 1 (sección anterior) se hizo entre la
   Fase 1 bis y esta, como pidió 10.15.

### 2b.3 Pruebas

- **`test/t114_fase2bis_test.dart` (24):** los valores de la noche y la marca
  como superficie; las parejas nuevas en AA en los dos modos y las cifras de 13.1; el tema
  de noche (primary, primaryContainer, superficies, indicador del riel, selección
  invertida, pista de progreso) y el de día intacto; los roles de la vista Estado y de la
  noche en AA sobre el relleno y 3:1 sobre los cuatro fondos de cada modo; sus valores del
  concepto; el respaldo a tinta de la celda atenuada; la permutación y los 60° de los
  cinco primeros puertos; **las 24 fichas de noche recalculadas en Dart con la receta
  OKLCH** (y las de día con la de HSL), su contraste y la separación suave / intensa; el
  script con la misma permutación y receta; el tema por omisión por plataforma (función y
  `BayStreamApp` en Windows y Android: «Seguir al sistema» sigue al sistema y la elección
  explícita manda, como en T-90); y **el contraste compuesto de los
  estados nuevos de la celda**: 5 estados × 4 marcas × atenuada × insignia, sobre papel,
  cubierta y bodega, en dos temas y dos densidades (240 casos por combinación, 960 en
  total), midiendo también el contorno punteado.
- **`test/t114_piezas_test.dart` (39):** cada pieza (qué dibuja, qué responde al
  toque, su etiqueta, sus medidas), la curva y el radio de la celda, el estado que manda
  sobre la categoría, el punteado de noche y el relleno de día, la celda que sale y vuelve
  a su alto de siempre; **con `disableAnimations` nada se mueve** (la marca en espera, el
  pulso, el destello y la celda recién movida: `hasRunningAnimations` falso y sin
  `AnimatedSlide` ni `TweenAnimationBuilder`), y con animaciones sí se mueven; las tres
  pautas de accesibilidad (`textContrastGuideline`, `androidTapTargetGuideline`,
  `labeledTapTargetGuideline`) sobre las siete piezas en el día y en la noche; y las ocho
  vistas previas nuevas construidas en los dos temas.
- **Actualizadas:** `t114_fundacion_test.dart` y `t114_fase3_inicio_test.dart` solo cambian
  el nombre de una prueba («dirección A» → «dirección C» / «el tema»); sus aserciones
  siguen valiendo con los valores nuevos (`BsPaleta.oscuro.marca`, `.papel`). Las 75 ×
  3 × 4 = 900 celdas de `t114_celda_contraste_test.dart` pasan con la noche sin tocar la
  prueba.

### 2b.4 Validaciones ejecutadas

Con la luz verde del encargo para `flutter test` y `flutter analyze`, un comando a la vez
(los dos de la copia limpia de la corrección terminaron antes de empezar estos). Sin
compilaciones ni arranques de app; `flutter-mcp` y `maestro` no hicieron falta (ninguna
pantalla cambia).

- `flutter analyze` → **«No issues found»**.
- `flutter test --no-pub` (suite completa) → **`+1223: All tests passed!`, 0 fallos, 0 omitidas (incluidas las 4 de la corrección y la de las fuentes, que en el árbol pasa)**. Piso: 1160 (tras la
  corrección) → **1223**.
- `python -X utf8 -I tool/rediseno_contraste.py` → «Pares que no cumplen: 0».
- Auditoría de `flutter-ui` (`python …/flutter_ui_audit.py . --all`, salida en
  `docs/rediseno/fase2bis/flutter-ui-audit.txt`): 165 archivos (157 + 8 nuevos), **17 críticos, 272 avisos y 19 informativos** (la entrega 1: 17, 231 y 19). Los críticos y los informativos son los mismos de la entrega 1, ninguno en `lib/core/`. Los 41 avisos nuevos son todos `PERF_HARDCODED_COLOR` en los dos archivos de tokens: `bs_colores_semanticos.dart` pasa de 128 a 159 (los roles nuevos, la noche y las fichas) y `bs_paleta.dart` de 32 a 42 (los cinco colores nuevos en dos modos). Son la única fuente de color del sistema, como desde 10.7 (O1). `bs_movimiento.dart` conserva el `ANIM_ZERO_DURATION` del interruptor de accesibilidad. **En los nueve componentes nuevos, en `bs_celda.dart`, `bs_banda.dart`, `bs_tema.dart`, `bs_medidas.dart`, `bs_categorico.dart`, `vistas_previas.dart` y `lib/core/app.dart`: cero críticos y cero avisos.**

### 2b.5 Archivos de esta fase

- `lib/core/app.dart`.
- `lib/core/design/`: `bs_paleta.dart`, `bs_categorico.dart`, `bs_colores_semanticos.dart`,
  `bs_medidas.dart`, `bs_movimiento.dart`, `bs_tema.dart`, `design.dart`,
  `vistas_previas.dart`; en `componentes/`: `bs_celda.dart` y `bs_banda.dart`
  (modificados) y, nuevos, `bs_marca.dart`, `bs_silueta_buque.dart`, `bs_casco_bodega.dart`,
  `bs_tarjeta_cifra.dart`, `bs_anillo_avance.dart`, `bs_panel_en_vivo.dart`,
  `bs_banda_muelle.dart` y `bs_fondo_de_plano.dart`.
- `test/t114_fase2bis_test.dart` y `test/t114_piezas_test.dart` (nuevos);
  `test/t114_fundacion_test.dart` y `test/t114_fase3_inicio_test.dart` (un nombre).
- `tool/rediseno_contraste.py`, `docs/rediseno/fase2bis/contraste.md` y
  `docs/rediseno/fase2bis/flutter-ui-audit.txt` (compartidos con la Fase 1 bis).
- `DESIGN.md` (Fase 1 bis) y `docs/REDISENO-RESULTADOS.md` (las dos secciones).
- Sin cambios: `lib/features/vessel/presentation/**` (salvo la corrección 10.15, aparte),
  `domain/`, `data/`, `lib/main.dart`, `pubspec.yaml`, `pubspec.lock`, los congelados de H5
  y los instrumentos de T-98. Ninguna dependencia nueva. `windows/flutter/generated_plugin*`
  los regenera `flutter test` y no se versionan (10.2).

### 2b.6 Lo que no se pudo, lo que queda y lo que Carlos decide

- **El tema por omisión según el equipo no se conectó: exige `domain/` y `data/`.**
  «Seguir al sistema» y «nunca eligió» son el mismo `system` para la presentación
  (`hive_vessel_data_source.dart:117`), y la primera corrida de la suite lo dejó claro:
  resolver `system` por equipo rompe `t90_theme_test` («sistema responde»), que es la
  preferencia de T-90 que 10.14 dice que no cambia. Así que `bayStreamTemaPorOmision` queda
  listo y probado, `system` sigue al sistema, y **propongo** (DESIGN.md 13.5) un cuarto valor
  `AppThemePreference.equipo` («Según el equipo») que el almacén devuelva cuando no hay nada
  guardado: dos líneas en `domain/` y `data/`, una en `app.dart` y una opción en Parámetros
  (Fase 3). **Carlos decide y Yov lo escribe como tarea**; mientras tanto, en Windows y la
  Web la app abre según el sistema operativo, como hasta hoy.
- **Los avisos de la auditoría en los dos archivos de tokens** (`bs_paleta.dart` y
  `bs_colores_semanticos.dart`) suben con la noche y las fichas: son la única fuente de
  color del sistema, como desde 10.7 (O1), y fuera de ellos `lib/core/design/` queda en
  cero críticos y cero avisos. `bs_movimiento.dart` conserva el falso positivo de
  `Duration.zero` (el interruptor de accesibilidad).
- Las vistas previas se comprobaron por prueba (se construyen en los dos temas); el visor
  no se arrancó (cuenta en el semáforo y la fase no lo pide). No hay capturas: ninguna
  pantalla cambia.
- Las fichas de cielo y rosa difieren del lienzo por el recorte de gama (13.4); si Carlos
  prefiere los valores del lienzo tal cual, son dos constantes.
- **Queda para la Fase 3** (el plano por bahía): usar `BsSiluetaBuque`, `BsCascoBodega`, la
  vista Estado y la regla del naranja en la pantalla; el código íntegro a 2.0 (10.8); la
  banda que pone la acción debajo del texto cuando no cabe (3.8); y la etiqueta de la
  tira que el conductor de T-99 busca.

### 2b.7 Horas

De las 16:45 a las 17:20 del 22-oct-2026: ≈ 0.6 h de reloj, sin cronómetro,
con la corrección 10.15 en medio (≈ 0.3 h de esas, contadas en la sección de la corrección).

### Git para Carlos (Fase 1 bis y Fase 2 bis)

Después del bloque de la corrección. Un `git add` por ruta; `pubspec.yaml` y
`pubspec.lock` no cambian.

```
git add -- DESIGN.md
git add -- lib/core/app.dart
git add -- lib/core/design/bs_paleta.dart
git add -- lib/core/design/bs_categorico.dart
git add -- lib/core/design/bs_colores_semanticos.dart
git add -- lib/core/design/bs_medidas.dart
git add -- lib/core/design/bs_movimiento.dart
git add -- lib/core/design/bs_tema.dart
git add -- lib/core/design/design.dart
git add -- lib/core/design/vistas_previas.dart
git add -- lib/core/design/componentes/bs_celda.dart
git add -- lib/core/design/componentes/bs_banda.dart
git add -- lib/core/design/componentes/bs_marca.dart
git add -- lib/core/design/componentes/bs_silueta_buque.dart
git add -- lib/core/design/componentes/bs_casco_bodega.dart
git add -- lib/core/design/componentes/bs_tarjeta_cifra.dart
git add -- lib/core/design/componentes/bs_anillo_avance.dart
git add -- lib/core/design/componentes/bs_panel_en_vivo.dart
git add -- lib/core/design/componentes/bs_banda_muelle.dart
git add -- lib/core/design/componentes/bs_fondo_de_plano.dart
git add -- test/t114_fase2bis_test.dart
git add -- test/t114_piezas_test.dart
git add -- test/t114_fundacion_test.dart
git add -- test/t114_fase3_inicio_test.dart
git add -- tool/rediseno_contraste.py
git add -- docs/rediseno/fase2bis/contraste.md
git add -- docs/rediseno/fase2bis/flutter-ui-audit.txt
git add -- docs/REDISENO-RESULTADOS.md
git commit -m "Sprint 4: rediseno, fase 1 bis y 2 bis, direccion Puente de mando: la noche, las fichas, la tabla reordenada, el tema por equipo y las piezas nuevas"
git push
```

### Tres líneas

- `DESIGN.md` 13 es la dirección C completa, con cada pareja de color verificada por el
  script; la A queda como historia.
- `lib/core/design/` tiene la noche, los roles de la vista Estado, las fichas OKLCH con la
  tabla a saltos, el tema por equipo en `app.dart` y nueve piezas nuevas con prueba y vista
  previa; ninguna pantalla cambia.
- Suite 1223 y `analyze` en cero; el tema por omisión según el equipo queda
  preparado y propuesto, no conectado, porque exige `data/` (2b.6). ALTO: Codex acepta la
  Fase 2 bis.

### Mensaje para Yov

Yov: la corrección 10.15 y las Fases 1 bis y 2 bis quedan listas para Codex, en dos bloques de git (primero la corrección). **Corrección:** «No lo tengo» viene marcado solo si el perfil es del mismo buque, declarado por el usuario y sin límite (`vessel_geometry_page.dart`, `initState`); plantilla y propuesta empiezan sin marcar y sin elegir no se confirma; 4 pruebas nuevas, incluido BUQUE BETA para BUQUE ALFA. La carpeta `con` es `con-perfil` con los mismos cinco archivos; `t114_primera_web.py` escribe por condición y rechaza nombres reservados; las tres aserciones de `profile_loading_test` comparan identidad, geometría, tapas, tomas y orígenes salvo `updatedAt`; la referencia `5406e20` está en 3.4 y en la ayuda de `t112_censos.py`. Validada en una copia limpia de `16fa15d` con solo la corrección: analyze 0 y 1159 de 1160 (el único fallo es la licencia en LF de `git archive` contra los 4456 bytes CRLF del árbol; en el árbol pasa). Piso 1160. **Fase 1 bis:** `DESIGN.md` 13 es la dirección C (noche y día con los roles de M3 y los semánticos y el contraste de cada pareja, el plano como el ícono, la regla del naranja, las fichas OKLCH con la tabla a saltos y sus 24 valores, el tema por equipo, nueve piezas con API, dónde va la marca, 9.2 y 9.3 bis, lo que no se toma); la A queda como historia con su porqué. Dos decisiones que el concepto no fijaba y quedan escritas: de noche la marca `#0D47A1` no sirve como texto (1.6:1), así que `primary` es la selección `#4F8EF7` y la marca va como superficie; y la selección de segmentos y chips se invierte de noche. **Fase 2 bis:** la noche en paleta y tema, los roles nuevos (información, por bajar en cubierta y en bodega, de paso apagado, bajado punteado, recién movido, tinta tenue), las fichas y la permutación en Dart y en el script (las fichas se recalculan en la prueba con la receta OKLCH), el tema por equipo en `app.dart`, y `BsMarca`, `BsSiluetaBuque`, `BsCascoBodega`, `BsCelda` con `estado` y `curva`, `BsTarjetaCifra`, `BsAnilloAvance`, `BsPanelEnVivo` (solo el rol del equipo, por enum), `BsBandaMuelle` y `BsFondoDePlano`, cada una con vista previa, prueba y las tres pautas, y con `disableAnimations` nada se mueve. Suite 1223 (63 nuevas, ninguna omitida), analyze 0, contraste 0 pares bajos, auditoría con cero críticos y cero avisos en `lib/core/design/` y `app.dart` fuera de los dos archivos de tokens (201 hexadecimales, antes 160). Un hallazgo del instrumento: con los rellenos de «por bajar» la celda atenuada dejaba el código en 3.5:1 y 3.1:1; la regla pasa a «tinta suave, y si no llega, tinta» (13.2, script y `BsRol.atenuado`). **Para Carlos:** (1) el tema por omisión según el equipo queda preparado (`bayStreamTemaPorOmision`) pero no conectado: el almacén devuelve el mismo `system` para quien nunca eligió y para quien eligió «Seguir al sistema», y la prueba de T-90 exige que este siga al sistema; propongo en 13.5 un cuarto valor `AppThemePreference.equipo` que el almacén devuelva cuando no hay nada guardado (dos líneas en domain/ y data/, una en app.dart y la opción en Parámetros), para que lo decidas y lo escribas como tarea; (2) cielo y rosa difieren del lienzo por el recorte de gama de sRGB. Ninguna pantalla cambia. Me detengo: ALTO: Codex acepta la Fase 2 bis.

---

## Fase 2 bis · Corrección tras la aceptación de Codex (22-oct-2026, 10.17)

Codex aceptó la corrección 10.15 y dictaminó NO PASA la Fase 2 bis: H1 bloquea (la celda
recién movida salta en vez de salir), O1 y O2 son dos cifras de `DESIGN.md` 13.6 que no
coincidían con el código, y 10.16 pedía además enmendar 13.3, punto 6. Esta corrección va
en su propio bloque de git, antes de la entrega 2 del plano, que sigue después en este
informe. El único archivo de la entrega 2 que ya estaba en el árbol al llegar el mensaje
(`lib/features/vessel/presentation/providers/plano_providers.dart`, nuevo y sin seguimiento)
no entra en este bloque.

### 2c.1 Resultado en tres líneas

- **H1, la celda recién movida sale de verdad.** `BsCelda` lleva ahora un widget con estado
  propio (`_Salida`) que vive en el árbol en todos los estados; al entrar en «recién movido»
  arranca un `AnimationController` de 150 ms (`BsMovimiento.salida`, curva
  `BsMovimiento.entrada`) y un `Transform.translate` lleva el cuerpo de 0 a media celda hacia
  arriba **desde donde estaba esa misma celda**; al volver a «bajado» el controlador se
  detiene en 0 y no se ve regresar; con reducción de movimiento se queda quieta, naranja y
  sin hueco.
- **La prueba que Codex pedía existe y discrimina las dos versiones:** cambia el estado de
  la misma celda y compara el fotograma inicial, el de 75 ms y el final. Con la celda de
  `36f5784` (la que sigue en `HEAD`) falla en el primer fotograma («Expected 92.0, Actual
  68.0»: nace 24 dp arriba, el salto que Codex vio); con la de ahora pasa.
- **`DESIGN.md`:** 13.6 dice lo que el código hace (silueta con botones de **56 dp** por
  bahía y alto que sale de los niveles, sin parámetro `alto`; cifra a **34**, no a 40) y
  13.3, punto 6, manda el contador de «Más» a aviso o error, nunca a grúa. Suite
  **1224 en verde de 1224, 0 omitidas (piso 1223 → 1224)**, `analyze` en cero.

### 2c.2 Lo hecho

- **H1, antes (`36f5784`).** El cuerpo de la celda se envolvía en un `AnimatedSlide` solo
  cuando el estado era «recién movido», con `offset: Offset(0, -0.5)` desde el primer
  fotograma. Como el widget nacía ya desplazado, no había nada que animar: la celda
  aparecía media celda arriba de golpe, y al dejar el estado desaparecía el `AnimatedSlide`
  y volvía abajo también de golpe. Con la pantalla en reposo parecía un salto; es
  exactamente lo que la reproducción de Codex mide (leída en
  `C:\Proyectos\baystream-qa-r4\build\t114-fase2bis-aceptacion\salida_celda_test.dart`, sin
  tocarla).
- **H1, ahora (`lib/core/design/componentes/bs_celda.dart`, `_Salida` y `_SalidaState`).**
  `_Salida` envuelve el cuerpo en todos los estados, así que al cambiar `estado` es el mismo
  elemento el que recibe `didUpdateWidget` y la transición parte del valor que tenía. Recibe
  `sale` (`esRecienMovido && !BsMovimiento.reducido(context)`), el ancho y alto de la celda
  (`BsMedidas`), el radio, el color del hueco (`tertiary`), el grosor del contorno y el color
  del halo (`surface`). Al nacer con `sale`, o al pasar a `sale`, `forward(from: 0)`; al dejar
  de salir, `stop()` y `value = 0`, sin animación de vuelta. El `build` es un `Stack` sin
  recorte: debajo, solo mientras sale, el hueco (`CustomPaint` con `BsContornoPunteado`
  del tamaño de la celda); encima, un `AnimatedBuilder` sobre la curva que aplica
  `Transform.translate(Offset(0, BsCelda.salida.dy * alto * valor))` al cuerpo, con el halo
  (`BoxShadow` en `surface`, `spreadRadius: 3`) también solo mientras sale. `BsCelda.salida`
  sigue siendo `Offset(0, -0.5)`; la etiqueta «se acaba de mover» y el relleno de grúa no
  cambian. Con reducción de movimiento, `sale` es falso: el controlador no arranca, el
  `Transform` queda en 0, el relleno sigue siendo grúa y no hay hueco ni halo.
- **Pruebas (`test/t114_piezas_test.dart`).** Nueva: «la celda sale de verdad: de 0 a
  media celda en 150 ms desde su estado anterior, y vuelve de golpe». Monta la celda en
  «bajado» con `ValueKey('misma-celda')`, toma la posición del cuerpo (`getTopLeft` del
  `Container`) como «en su sitio», cambia a «recién movido» con la misma clave y comprueba:
  fotograma inicial en su sitio y una animación corriendo; a los 75 ms, más de 1 dp arriba
  y a más de 1 dp de media celda (estrictamente entre); a los 150 ms, exactamente media
  celda arriba (24 dp de los 48 de `altoCelda`); 16 ms después, ninguna animación corriendo;
  al volver a «bajado», en su sitio en el primer fotograma y a los 75 ms, y sin el pintor
  del hueco. La prueba «recién movido sale de su celda, dice «Bajando» y cambia su etiqueta»
  ya no busca un `AnimatedSlide`: comprueba el pintor del hueco y, tras asentarse, que el
  cuerpo está media celda arriba. La de reducción de movimiento exige la posición en su
  sitio y ningún `CustomPaint`. Un detalle del arnés que salió al medir fotogramas:
  `_envuelve` construía un `ThemeData` nuevo en cada `pump`, y el `AnimatedTheme` de
  `MaterialApp` arrancaba una transición de 200 ms que dejaba una animación viva después
  de los 150 ms; ahora los cuatro temas (claro y oscuro, oficina y muelle) se crean una vez
  por archivo. (La app hace lo mismo en `BayStreamApp.build`; no se toca aquí, queda
  anotado abajo.)
- **Que la prueba falla con la versión vieja.** Copia limpia de `HEAD` (`73ba7b0`, cuyo
  `bs_celda.dart` es el de `36f5784`, con el `AnimatedSlide`) con solo el
  `t114_piezas_test.dart` nuevo encima: `+39 -1`, y el fallo es la prueba nueva en su
  primera aserción, línea 273, «Expected: a numeric value within <0.01> of <92.0>, Actual:
  <68.0>»: la celda nace 24 dp arriba. Las otras 39, incluidas las dos reescritas, pasan en
  las dos versiones.
- **`DESIGN.md` 13.6 (O1, O2).** La fila de `BsSiluetaBuque` quita `alto` de la API y dice
  que cada bahía es un botón de 56 dp de ancho (`anchoBahia`) y que el alto no es un
  parámetro: sale de los niveles que se pintan (hasta 6 por zona, a 9 dp) y de la escala de
  letra del número y la barra. La fila de `BsTarjetaCifra` dice 34 / 600 tabular
  (`BsTextos.cifraGrande`, la escala de 4.2, que 13.10 no cambia; el lienzo la dibujaba a
  40). El código no cambia: ya hacía esto.
- **`DESIGN.md` 13.3 (10.16 y H1).** Punto 6: fuera de lo recién movido, el naranja aparece
  solo en el contenedor del ícono; el contador de «Más» (las alertas de estiba) va en aviso,
  o en error si alguna es crítica, nunca en grúa. Punto 1: la salida es «desde donde estaba
  esa misma celda, de 0 a media celda», y al dejar el estado vuelve de golpe, sin que se
  vea regresar. El contador de «Más» todavía no existe en el código (es de la entrega 2);
  la regla queda escrita para cuando llegue.

### 2c.3 Validaciones ejecutadas

Un comando de Flutter a la vez; la suite completa en segundo plano.

- `flutter analyze --no-pub` → **«No issues found»** (con `plano_providers.dart` en el
  árbol, que también compila limpio).
- `flutter test --no-pub test/t114_piezas_test.dart test/t114_fase2bis_test.dart` →
  `+64: All tests passed!` (40 + 24).
- `flutter test --no-pub` (la suite completa, en el árbol) → **`+1224: All tests passed!`, 0 omitidas, en 1 min 28 s; piso 1223 → **1224** (una prueba nueva)**.
- Copia limpia de `HEAD` más el `t114_piezas_test.dart` nuevo → `+39 -1`, con el fallo
  esperado en la prueba nueva (arriba).

### 2c.4 Archivos de esta corrección

- `lib/core/design/componentes/bs_celda.dart` (`_Salida`, `_SalidaState` y el comentario
  del cuerpo).
- `test/t114_piezas_test.dart` (una prueba nueva, dos reescritas, los temas en caché).
- `DESIGN.md` (13.3, puntos 1 y 6; 13.6, filas de `BsSiluetaBuque` y `BsTarjetaCifra`).
- `docs/REDISENO-RESULTADOS.md` (esta sección).
- Fuera del bloque: `lib/features/vessel/presentation/providers/plano_providers.dart`
  (entrega 2, nuevo, sin seguimiento; va en el bloque de la entrega 2). Los tres archivos
  generados de `windows/flutter/` (`generated_plugin_registrant.cc`, `.h` y
  `generated_plugins.cmake`) figuran como modificados solo por el fin de línea, sin cambio
  de contenido en `git diff`; no son de esta corrección ni se agregan.
- Sin cambios: `domain/`, `data/`, `lib/main.dart`, `pubspec.*`, los congelados y el resto
  de `lib/core/design/`.

### 2c.5 Lo que queda anotado

- `BayStreamApp.build` (`lib/core/app.dart`) construye `BayStreamTema.claro(...)` y
  `oscuro(...)` en cada `build`, así que cada rebuild de la raíz le da a `MaterialApp` un
  `ThemeData` nuevo y el `AnimatedTheme` corre 200 ms aunque nada haya cambiado de color.
  No se nota a la vista, pero es trabajo de más en la raíz; se puede guardar en caché por
  equipo y brillo. No es de esta corrección ni de la entrega 2; lo decide Carlos.

### 2c.6 Horas

De las ≈ 17:45 (el mensaje de Carlos con 10.17, con la entrega 2 recién empezada) a las
17:58 del 22-oct-2026: ≈ 0.25 h, con la suite y la copia limpia en segundo plano.

### Git para Carlos (Fase 2 bis, corrección)

Antes del bloque de la entrega 2. `DESIGN.md` solo trae estas cuatro enmiendas (13.3 y
13.6); `pubspec.yaml` y `pubspec.lock` no cambian.

```
git add -- lib/core/design/componentes/bs_celda.dart
git add -- test/t114_piezas_test.dart
git add -- DESIGN.md
git add -- docs/REDISENO-RESULTADOS.md
git commit -m "Sprint 4: correccion de la fase 2 bis, la celda recien movida sale desde su sitio, silueta de 56 dp y cifra a 34 en DESIGN"
git push
```

### Tres líneas

- La celda recién movida sale desde donde estaba, de 0 a media celda en 150 ms con
  `Transform`, no se ve regresar y con reducción de movimiento se queda quieta y naranja.
- Una prueba de tres fotogramas (0, 75 y 150 ms) lo fija y falla con la celda de `36f5784`
  (nacía 24 dp arriba).
- `DESIGN.md` 13.6 dice 56 dp por bahía con alto adaptable y cifra a 34; 13.3 manda el
  contador de «Más» a aviso o error. Suite 1224 en verde de 1224, 0 omitidas (piso 1223 → 1224), `analyze` en cero.

### Mensaje para Yov

Yov: la corrección de la Fase 2 bis queda lista para que Codex la vuelva a mirar, en su propio bloque de git. **H1:** `BsCelda` lleva un widget con estado (`_Salida`) que vive en el árbol en todos los estados; al entrar en «recién movido» un `AnimationController` de 150 ms y un `Transform.translate` llevan el cuerpo de 0 a media celda desde donde estaba esa misma celda, el hueco punteado y el halo solo existen mientras sale, al volver a «bajado» el controlador se para en 0 sin vuelta visible y con reducción de movimiento se queda quieta, naranja y sin hueco. Antes el `AnimatedSlide` nacía ya en `Offset(0, -0.5)`, por eso saltaba. La prueba nueva cambia el estado de la misma celda y compara el fotograma 0 (en su sitio), el de 75 ms (estrictamente entre) y el de 150 ms (24 dp arriba), más la vuelta de golpe; en una copia limpia de `HEAD` con la celda de `36f5784` falla en el primer fotograma («Expected 92.0, Actual 68.0») y con la de ahora pasa. **O1 y O2:** 13.6 dice 56 dp por bahía (`anchoBahia`) con el alto que sale de los niveles, sin `alto` en la API, y la cifra a 34 / 600 tabular (`BsTextos.cifraGrande`); el código no cambia. **13.3, punto 6:** el contador de «Más» va en aviso, o en error si alguna alerta es crítica, nunca en grúa; y el punto 1 describe la salida desde 0. Suite 1224 en verde de 1224, 0 omitidas (piso 1223 → 1224), `analyze` 0. Un hallazgo del arnés, anotado y sin tocar: `BayStreamApp.build` crea un `ThemeData` nuevo en cada build y el `AnimatedTheme` de `MaterialApp` corre 200 ms de más; lo decide Carlos. Sigo con la entrega 2 del plano.


---

## Fase 3 · Entrega 2: el plano por bahía en la dirección C (22 y 23-oct-2026)

El brief es 10.16 de `SPRINT-4.md` (con el agregado de 10.17 sobre el `Badge` global y «Acciones»);
la dirección, `DESIGN.md` 8, 9 y 13. Codex aceptó antes la corrección de la Fase 2 bis (H1 cerrado,
`docs/rediseno/fase2bis/reaceptacion-codex.md`). El traspaso de trabajo está en
`docs/rediseno/fase3/traspaso-entrega2.md`.

### 4.1 Resultado en tres líneas

- **El plano por bahía es el de «Puente de mando»** en los tres clientes: la navegación adaptable
  (barra inferior, riel con la marca, riel con panel de 360), la silueta como selector, las
  tarjetas de cifra con la operación real, la rejilla dibujada como el ícono (celdas `BsCelda`
  con las fichas de «Colorear por», la tapa, el casco de la bodega), el detalle en una sola hoja
  (panel o hoja inferior), «En vivo» con la bitácora, la banda del muelle con Descarga / Carga, la
  barra de la operación y la regla del naranja con datos de verdad.
- **Lo que 10.8 y 10.16 dejaron pendiente está resuelto:** «Contenido» y «Número de orden» enteros
  a 1.45 y 2.0, el código de cinco letras entero a 2.0 (la celda se ensancha con la letra, no más
  que ella), la acción de la banda que baja de línea, el conductor de T-99 que ya no busca pestañas
  ni chips, el contador de «Más» en aviso o error (y el `Badge` global y el de «Acciones», 10.17),
  `t114_fuentes_test` sin depender del fin de línea, `DESIGN.md` 13.5 con la decisión del tema.
- Suite **1242 en verde** (piso 1224 → **1242**: 18 más, 22 archivos actualizados sin bajar el
  conteo, ninguna omitida); `analyze` **«No issues found»**; censos de T-112 con `5406e20`:
  **1931 cadenas visibles, 1800 en español y 131 sin idioma, 0 en inglés**; Material 3
  **251 / 7 / 3**; mensajes **217** (uno retirado con la barra de T-91); auditoría de
  `flutter-ui` con cero críticos y un aviso declarado en lo nuevo. RNF-002 sigue en tres pasos
  (Windows 1.84–2.19 s, la Web 0.30–0.48 s y 1.28–1.60 s en la primera visita, el emulador con cotas de 3.06–3.88 s). La RAM en Windows, antes y después, en 4.7. **ALTO: Codex acepta la entrega 2.**

### 4.2 Lo hecho

- **La navegación** (`pages/vessel_overview_page.dart`, `widgets/navegacion_del_viaje.dart`,
  nuevo). Sin `TabBar` ni la barra de ocho acciones de T-91 (`DESIGN.md` 8). Con viaje, los
  destinos Plano · Lista · Avance (solo con escala) · Estadísticas · Más viven en
  `destinoDelViajeProvider`; la búsqueda, las estadísticas, las alertas y «Avance» llevan al Plano
  por él. Por debajo de 600 dp, `NavigationBar` (`BarraDelViaje`: claves `destino-<nombre>`,
  «Estad.» como rótulo corto, la letra escala hasta 1.3 porque cinco destinos en 360 dp dan 72 a
  cada uno) y la barra superior con el buque, «Viaje M100 · Escala GTSTC», Buscar y la nube; en el
  muelle con una escala publicada, la barra superior es `BsBandaMuelle` (13.8 bis) con el chip de
  la nube y los segmentos Descarga / Carga, que comparten `bayPlanModeProvider` con el selector de
  modo; Descarga solo si el plano de llegada lo ofrece (`offersDischarge`). Desde 600 dp,
  `NavigationRail` con `BsMarca` arriba y la nube y Parámetros al pie (`RielDelViaje`; en
  ventanas bajas se desplaza en vez de desbordarse) y la cabecera de la oficina
  (`_CabeceraDeOficina`: el buque, «Publicado» o «Sin confirmar», Descarga / Carga, Buscar, la
  nube). Desde 1200 dp, además, el panel de 360 (`_PanelLateral`: el detalle de la celda elegida
  y «En vivo») y Alertas en el riel. «Más» es una hoja (`_HojaMas`) con Alertas de estiba primero
  (su contador), Tapas, Orden de descarga, Listado, Comparar, Exportar PDF / CSV / JSON (en previo,
  `export-preview` avisa como antes), Nube y Parámetros solo sin riel, Cargar archivo, Viajes
  recientes, Perfiles guardados y «Cerrar el plano». `PanelLateralDisponible` (InheritedWidget) le
  dice al plano si el detalle va al panel. El `RelojDelNaranja` de 13.3 vive aquí (abajo).
- **El plano** (`widgets/bay_plan_view.dart`, reescrito; `widgets/silueta_del_viaje.dart`,
  `cifras_del_viaje.dart`, `detalle_contenedor.dart`, `en_vivo_del_viaje.dart`, nuevos).
  - *El selector es la silueta* (`BsSiluetaBuque`): cada bahía con los niveles ocupados de
    cubierta y bodega, su avance de descarga (o de carga en ese modo) debajo del número, las
    bahías sin trabajo apagadas, el destello de la bahía donde se acaba de mover algo; cada botón
    con la clave `silueta-bahia-N`. La bahía inicial es la primera con carga propia: una impar que
    solo trae la sombra de los 40 de sus pares (T-110) no es por donde se empieza a mirar.
  - *Las tarjetas* (`BsTarjetaCifra`) salen de la operación: Descarga con su anillo, Por bajar
    («18 en la bahía 14»), Re‑estibas y, en Carga y Número de orden, Carga, Llenos, Vacíos y
    Conflictos; Alertas en aviso cuando hay. Van a la derecha de la silueta cuando caben (una fila
    de cuatro desde 1400 dp de ancho útil, dos por fila desde 1040); con menos ancho no aparecen,
    para no quitarle el alto a la rejilla (las cifras están en «Avance»). Sin operación no hay
    tarjetas.
  - *«Colorear por»* (`ColorearPor` en `providers/plano_providers.dart`: Estado, Destino, Tipo de
    vacío; por omisión según el modo, 10.4) decide el código y la ficha de cada celda: Destino con
    las fichas OKLCH del puerto, Tipo con las de los vacíos (los llenos en papel), Estado sin
    ficha. La carga de paso va como «de paso» en todas las vistas (C-5a).
  - *La rejilla como el ícono* (13.2): `BsCelda` en cada celda (las claves `cell-r-t`,
    `discharge-<marca>`, `pending-discharge-*`, `reserved-*`, `reserved-shadow-*`,
    `neighbor-twenty`, `plan-cell-*` y `loading-*` se conservan; la clave de la marca de T-75 va
    como `KeyedSubtree` dentro de la de la celda, porque dos hermanas con la misma clave no se
    permiten), la tapa (`linea-de-tapa`), `BsCascoBodega` detrás de la bodega y la curva en las
    celdas de los extremos, sin rótulos de zona (la zona la dicen la tapa y el casco). En la vista
    Estado, por bajar en cubierta / bodega, de paso, bajado (la palomita) y recién movido; la
    marca de T-75 («Baja», «Hecho», «Paso», «Re‑estiba», «Revisar») se escribe en el muelle y en
    las vistas Destino y Tipo; en la oficina, la vista Estado deja el código y el peso (13.2). En
    Número de orden, el número como código y «OR» como segunda línea. El peso de la celda y de las
    pilas sigue como el plano impreso («28.7», sin unidad); el total de la bahía, con
    `formatearToneladas`. La celda se ensancha con la letra del sistema para que el código de
    cinco letras quepa (`BsMedidas.copyWith(anchoCelda:)` en un `Theme` local): lo que mide el
    código con la fuente y nunca más que lo que creció la letra. El chip del zoom pasa a la
    esquina inferior derecha (9.2): ya no tapa el título. La copia que se arrastra (T-106) se
    centra con las medidas de la celda, no con los 27 px de antes.
  - *La leyenda* es `BsCartela` compacta (nueva opción `compacta`: sin título ni aire, para que la
    rejilla se quede con el alto) en una línea que se desplaza: la vista, las fichas con su cuenta
    (destinos o tipos de vacío; en Estado, por bajar, bajado, de paso, re‑estiba), «Resaltar» de
    RF-011 (Lleno, Vacío, IMO, Refrigerado, OOG, De paso) y los huecos (40 pies, 20 pies, reserva).
  - *En el muelle operando*, abajo va `BsBarraDeOperacion` (por bajar / hechas / re‑estibas, o
    pendientes / llenos / vacíos) con «Pendientes de descarga» o «Avance de la operación». El
    aviso con «Deshacer» sigue siendo el de T-75.
  - *El detalle* es `DetalleContenedor`, una sola hoja (`BsHojaDeDetalle`): las filas de antes
    (Celda, Tipo ISO, Estado, VGM, Peso bruto, puertos, Naviera), las señales de IMDG, refrigerado y
    OOG, `DischargeDetailSection` y `OfficePlanActions`. Con panel va al panel
    (`celdaSeleccionadaProvider`); sin él, hoja inferior.
  - *«En vivo»* (`EnVivoDelViaje`): los últimos movimientos de la bitácora (`eventosEnVivo`: qué,
    el rol del equipo, el dato en mono, cuándo), el estado de la nube como resumen y el punto que
    pulsa solo en línea.
- **La regla del naranja con datos de verdad** (`recienMovidoProvider`): aprende la bitácora al
  abrir y marca lo que llega después, propio o por la nube (`observar`, alimentado por
  `loadingOperationProvider` con `ref.listen` más una lectura inicial: este Riverpod no tiene
  `fireImmediately`); el toque en Descarga saca la celda antes de registrar (`_tocarEnDescarga`); la
  silueta destella la bahía. El reloj de 1.5 s no es un `Timer` del notifier sino
  `RelojDelNaranja`, un `TweenAnimationBuilder` de la página que llama a `apagar` al terminar:
  corre con los cuadros de Flutter, como el destello, y no deja temporizadores colgados (la
  primera versión con `Timer` tumbaba `t76_loading_widget_test` con `!timersPending`).
- **La celda de carga** (`loading_controls.dart`, `LoadingCell`): `BsCelda` con el OR como código,
  `pendiente` / `hecho` como rol, «Sube» / «Cargado» como segunda línea, conflicto y cancelación
  como marca («Revisar», «Cancelado»). La etiqueta accesible de T-107 no cambia.
- **El avance** (`pages/operation_progress_page.dart`): `OperationProgressBody` es el cuerpo sin
  barra, con `onCelda` para que «Ir a» de un conflicto lleve al plano sin cerrar nada; la página lo
  envuelve como antes.
- **10.16 y 10.17.** El contador de «Más» va en aviso, o en error si alguna alerta es crítica
  (`alertaCriticaProvider`, `ContadorDeAlertas`); el `BadgeThemeData` global pasa de grúa a aviso
  (`bs_tema.dart`) y el `Badge` de «Acciones» lo hereda: el naranja es solo de lo que se mueve.
  `t114_fuentes_test` acepta la licencia en LF o CRLF. `DESIGN.md` 13.5 anota la decisión del
  tema; 8 y 13.8, lo que el código hace distinto del lienzo (abajo, 4.8).
- **Piezas del sistema de diseño** (`lib/core/design/`): `BsMedidas.copyWith` admite
  `anchoCelda` y `altoCelda`; `BsSiluetaBuque` pone clave a cada bahía; `BsBanda` baja la acción
  a su línea cuando no cabe; `BsBandaMuelle` admite `mostrarModos` y `modos` (un plan de carga sin
  descarga no ofrece el segmento); `BsCartela` admite `compacta`. `bs_celda.dart` no cambia.
- **Instrumentos** (`tool/`): el conductor de T-99 busca los destinos dentro de
  `NavigationBar` / `NavigationRail`, las bahías por `silueta-bahia-N` y tiene el escenario
  `plano` (publica el archivo, pone la escala anterior y captura plano, Descarga, Lista y Avance por
  tema, letra y tamaño); `t114_capturas_windows.ps1` admite `-Escenario` y `-PorExplorer` (desde
  la consola empaquetada el proceso hijo hereda el paquete y el binario no escribe donde se le
  pide: lo abre explorer.exe desde un .cmd con las variables); `t114_capturas_web_plano.py` y
  `t114_capturas_android_plano.py` toman las capturas del plano; `t114_ram_windows.ps1` repite la
  RAM de T-99 con el escenario `ram`; `t114_primera_windows.py` busca «Seleccionar archivo» por
  la marca de la dirección C de noche (`#4F8EF7`, el `primary` desde la Fase 2 bis; antes
  `#8FB4F2`, y sin eso no pulsaba el botón); `t112_censos.py` conoce los archivos nuevos (idioma
  y pantalla) y retira el mensaje de la barra de T-91.
- **Lo que enseñaron las capturas, corregido antes de cerrar.** A 360 dp el título «Bahía 02 ·
  tapas sin declarar» salía cortado: iba centrado sobre la rejilla, más ancha que la pantalla;
  ahora el título y el resumen van al ancho de la vista (y se parten en dos líneas a 1.45 y
  2.0). En el emulador (360 × 640 dp) la rejilla quedaba entera bajo el pliegue: con la banda,
  la silueta y la leyenda solo asomaba la fila de pesos. En el teléfono bajo (menos de 560 dp de
  alto útil para el plano; 360 × 800, el Honor y el arnés de Windows, no lo es) los controles
  del modo y la silueta se van hacia arriba al desplazar la rejilla y vuelven al desplazarla
  hacia abajo (`NestedScrollView`); la banda, la barra de la operación o la leyenda y la barra
  inferior no se mueven (`DESIGN.md` 13.8). Y en el muelle a 360 el modo Descarga se elige desde
  el desplegable del modo, así que los scripts de la Web y de Android lo abren cuando el
  segmento no está a la vista.

### 4.3 Pruebas

- Nueva: `test/t114_fase3_plano_test.dart` (16): la navegación por ancho (1300: riel, cabecera y
  panel; 800: solo el riel; 360: la barra con «Estad.» y su descripción emergente), «Avance» solo
  con escala y embebido, «Más» con las alertas primero y el contador en error o en aviso, ningún
  contador en grúa (el tema y un `Badge` suelto), la silueta elige la bahía y la rejilla la titula,
  las tarjetas con y sin operación, «Colorear por» en las tres vistas, lo recién movido 1.5 s con el
  destello de la silueta, el detalle en el panel y en la hoja, la banda del muelle con Descarga /
  Carga, el selector de modo entero a 2.0, el código entero a 2.0, la banda apilada, y la
  cabecera del plano que a 360 × 640 se va al desplazar la rejilla (que gana su alto) y vuelve,
  y a 360 × 800 se queda. Carga las fuentes del producto (Plex y Roboto) para que las medidas
  de 360 dp sean las reales.
- Nueva: `test/t114_tema_cache_test.dart` (2, bloque aparte, 4.9).
- Actualizadas sin bajar el conteo: `t91_toolbar_support` y `t91_plan_toolbar_test` (abrir y
  cerrar «Más» en vez de plegar; Buscar y la nube arriba, lo demás en «Más», el riel con Nube y
  Parámetros), `t97_text_test` (el título es el buque; `destino-estadisticas`; el detalle nuevo; la
  silueta en vez de chips), `t104_text_test` (los rótulos de la barra), `t107_tabs_test`
  (reescrito con `destinoDelViajeProvider`), `t110_bays_test` y `vessel_profile_view_test` (la
  silueta por clave y la selección por su bandera de semántica), `t106_plan_widget_test` (título
  «Bahía 03», «Baja», «2×20′», y a 300 % la celda se trae a la vista antes de arrastrarla),
  `t75_discharge_test` (claves `discharge-<marca>`),
  `recent_voyages_test`, `profile_loading_page_test`, `t114_fase3_inicio_test` («Más»),
  `t102_weight_display_test`, `effective_weight_test`, `t90_theme_test` y `bay_plan_grid_test`
  (el peso como `linea2` de `BsCelda`; las pilas por `peso-pila-*`; la marca de exceso con radio 6;
  «de paso» es el rol del sistema de diseño), `t69_reserved_slots_view_test` («40′», relleno
  papel), `t81_office_widget_test` («Cancelado»), `t114_fuentes_test`.

### 4.4 Validaciones ejecutadas

Un comando de Flutter a la vez; los largos en segundo plano. El Honor no se tocó.

- `flutter analyze --no-pub` → **«No issues found»**.
- `flutter test --no-pub` → ****1242 pruebas en verde, ninguna fallida ni omitida** (1 min 19 s; piso 1224 de la corrección de la Fase 2 bis → 1242). `flutter analyze` después de la última corrección: **«No issues found»**.**.
- Censos de T-112 (`tool/t112_censos.py`, referencia `5406e20`, salida en
  `docs/rediseno/fase3/entrega2/censos/`): idioma, **1931 cadenas visibles: 1800 en español y 131
  sin idioma, 0 en inglés o mixtas** (entrega 1: 1816, 1677 y 139); Material 3: **251 controles
  incluidos, 7 exclusiones y 3 excepciones** (entrega 1: 259 / 8 / 5: la rejilla ya no lleva el
  `GestureDetector` de cada celda ni el `Opacity`, y los controles nuevos son Material con el color
  del tema); mensajes: **217** (los 218 de T-112 menos «No se pudo guardar la preferencia de la
  barra», que se retira con la barra de T-91). Las 101 cadenas nuevas sin decisión (los destinos,
  las tarjetas, el detalle, los eventos de «En vivo», las etiquetas de la silueta, los segmentos de
  la banda, los nombres de los tonos) se decidieron por archivo en `T114_DECISIONES`.
- Auditoría de `flutter-ui` (`docs/rediseno/fase3/entrega2/flutter-ui-audit.txt`): **17 críticos,
  249 avisos y 20 informativos** (entrega 1: 17, 231 y 19). Comparados hallazgo a hallazgo por
  código y archivo: los avisos nuevos son **41 hexadecimales en los dos archivos de tokens**
  (`bs_colores_semanticos.dart` +31, `bs_paleta.dart` +10, la noche de la Fase 2 bis, la única
  fuente de color declarada), **un `IntrinsicHeight` en `navegacion_del_viaje.dart`** (el riel
  dentro de un desplazable para ventanas bajas: el patrón que la documentación de `NavigationRail`
  da, y se declara), y un informativo `NAV_NO_POP_SCOPE` más en `vessel_overview_page.dart`; se
  van **24 tamaños de letra escritos a mano** de `bay_plan_view.dart` y `loading_controls.dart`.
  En lo nuevo (`navegacion_del_viaje`, `detalle_contenedor`, `cifras_del_viaje`,
  `en_vivo_del_viaje`, `silueta_del_viaje`, `plano_providers`, `bay_plan_view`) no hay críticos ni
  otros avisos; en `vessel_overview_page.dart` siguen los dos falsos positivos de `ListView(`.
- `python -X utf8 -I -c "import ast…"` sobre los tres scripts nuevos de `tool/` → compilan; las
  corridas de capturas y de RAM son su ejecución.

### 4.5 RNF-002 (y T-99) otra vez

La navegación cambió (la Lista y el plano son destinos de la barra o del riel, y el tablero de
pestañas ya no existe), así que la primera visualización se repitió con los **mismos tres
instrumentos de la entrega 1, sin tocar su recorrido**: `tool/t114_primera_windows.py`,
`tool/t114_primera_web.py` (+ `.js`) y `tool/t114_primera_android.py` con
`tool/t114_primera_cuadros.py` (descritos en 3.5). El único cambio es el color por el que el de
Windows localiza «Seleccionar archivo» de noche (4.2). Los tres pasos del producto siguen siendo
(1) abrir la app, (2) «Seleccionar archivo» y (3) elegir el archivo; el fin es la rejilla del
previo a la vista. Umbral: **≤ 3 pasos y ≤ 30 s**, en la condición «sin perfil». Banco r4 de esta
entrega, `T99_SINTETICO_977.edi`, máquina en reposo, cinco repeticiones por condición.

| Cliente | Condición | Rep. | Pasos | Hasta la rejilla (s) | ≤ 3 pasos y ≤ 30 s |
|---|---|---|---|---|---|
| Windows (1920×1080, oscuro, por explorer.exe) | sin perfil | 5 | 3 | 2.188, 1.942, 1.844, 1.869, 1.859 (± 0.05) | cumple |
| Web (Chrome 155 por Playwright, 1280×800, oscuro) | sin perfil, caché caliente | 5 | 3 | 0.478, 0.354, 0.367, 0.334, 0.302 | cumple |
| | sin perfil, primera visita (caché fría) | 5 | 3 | 1.598, 1.489, 1.280, 1.350, 1.362 | cumple |
| Emulador Android (API 26, 360×640 dp, claro) | sin perfil | 5 | 3 | cotas 3.837–3.879, 3.364–3.419, 3.061–3.138, 3.139–3.193, 3.057–3.114 | cumple |

- **Windows:** hitos por repetición (s desde el arranque): la ventana a la vista 0.448, 0.448,
  0.443, 0.443, 0.444; el archivo confirmado 1.766, 1.593, 1.548, 1.585, 1.522; la rejilla quieta
  2.188, 1.942, 1.844, 1.869, 1.859. Frente a la entrega 1 (1.83–1.90 s) la primera repetición
  tarda 0.3 s más y las otras cuatro quedan iguales (1.84–1.94): el inicio nuevo no añade tiempo.
  Registros en `docs/rediseno/fase3/entrega2/rnf-002/windows/` (`sinNN/registro.json`,
  `resumen-sin.json`, y el inicio, la rejilla y el cuadro final de `sin01` en PNG).
- **Web:** el primer cuadro con el plano (desde la navegación) llega a 0.15–0.22 s con caché
  caliente y a 1.08–1.34 s en la primera visita; la rejilla quieta, en la tabla. Igual que en la
  entrega 1 (0.30–0.42 y 1.28–1.51 s). Registros en `rnf-002/web/sin-caliente/` y `sin-fria/`
  (`sinNN-registro.json`, `resumen.json`, y el inicio y la rejilla de `sin01`).
- **Emulador:** el paso 1 sigue siendo `am start` del paquete r4 (el icono no está a la vista en
  el lanzador del emulador, anotado); el tiempo sale del video (PTS del primer cuadro que difiere
  del lanzador y del primer cuadro quieto con el plano, propuestos por `t114_primera_cuadros.py`
  y mirados a ojo: en la primera repetición el cuadro 72 es el primero sin el selector y con la
  rejilla; en la tercera, el 53). La cota incluye las lecturas de uiautomator del instrumento, así
  que es un límite superior, como en T-98 y en la entrega 1 (2.98–3.25 s): la primera repetición
  de hoy (3.84–3.88 s) es la que sigue al `pm clear` y a la primera apertura del selector; las
  otras cuatro quedan en 3.06–3.42 s. Registros en `rnf-002/android/sinNN/` (`captura.json`,
  `cuadros.json` y los JPEG candidatos); los MP4 quedan en `%TEMP%` con su SHA-256 en el registro.
- La condición «con perfil» (informativa) no se repitió: nada de esta entrega la toca y la de la
  entrega 1 sigue valiendo.

### 4.6 Capturas

Las de «después» son del banco r4 de esta entrega (`-t tool/t99_main.dart`, la última compilación,
con todo lo de 4.2), con el plan de carga `T100_CARGA.edi` publicado primero (deja GTSTC como
escala confirmada) y el plano de llegada `T100_LLEGADA.edi` abierto después, que por 7.2 abre
publicado en GTSTC y ofrece Descarga. Todas en `docs/rediseno/fase3/entrega2/`:

| Cliente | Carpeta | Cuántas | Qué hay |
|---|---|---:|---|
| Windows (arnés, `t114_capturas_windows.ps1 -Escenario plano -EscalaAnterior GTSTC -PorExplorer`) | `despues-windows/` | 72 | 1920×1080, 600×960 y 360×800 × claro y oscuro × letra 1.0, 1.45 y 2.0 × plano, Descarga, Lista y Avance |
| Web (Chrome por Playwright, `t114_capturas_web_plano.py`, banco servido en 127.0.0.1) | `despues-web/` | 40 | 360×800, 600×960, 1280×800 y 1920×1080 × claro y oscuro × plano, Descarga (a 360 desde el desplegable), Lista, Avance y «Más» |
| Emulador Android (API 26, 360×640 dp a densidad 480, `t114_capturas_android_plano.py --reiniciar-datos`) | `despues-emulador/` | 28 | letra 1.0, 1.45 y 2.0 en claro y 1.0 en oscuro × plano, Descarga, Lista, Avance y «Más», más `*_rejilla`: el plano y Descarga tras desplazar la rejilla, con la cabecera recogida (13.8) |

El «antes» del plano son las capturas del manual de T-100 (`docs/manual/w05-*`, `w08-plano-modo-*`,
`h05-*`, `h08-*`) y los previos de la entrega 1 (`docs/rediseno/fase3/despues/`): el conductor
de la entrega 1 no tiene el escenario `plano`. Lo que se mira en ellas y se corrigió está en 4.2
(el título cortado a 360, la rejilla bajo el pliegue a 360 × 640); lo que queda a la vista, en 4.8.
Ninguna captura muestra «Nube y cuenta» abierta, el corpus real ni correos: el buque es BUQUE
MANUAL, viaje M100, y los números de contenedor son sintéticos.

### 4.7 La RAM en Windows, antes y después (T-99, RNF-001)

Con el instrumento de T-99 sin tocar (`tool/t99_ram_windows.ps1`, acción `seguir`: cinco lecturas de
`WorkingSet64` tras 5 s de reposo en cada paso del escenario `ram`: cargar, el plano, las 72 bahías,
Estadísticas, buscar y volver a la Lista) y `tool/t99_ram_resumen.dart`, orquestado por
`tool/t114_ram_windows.ps1` (el banco abierto por explorer.exe, fuera del paquete de la consola).
Seis corridas por banco con `T99_SINTETICO_977.edi`; la primera, en frío, se descarta. MB del SI.
«Antes» es un banco compilado de `HEAD` (`ccc8c2f`, el plano anterior) y «después» el de esta
entrega, los dos con `-t tool/t99_main.dart` y la misma máquina en reposo (sin otro Flutter ni
capturas a la vez). Lecturas y resúmenes en `docs/rediseno/fase3/entrega2/ram/`.

| Paso del escenario | Antes, mediana de 5 corridas (mín–máx) | Después, mediana de 5 corridas (mín–máx) |
|---|---:|---:|
| inicio | 133.6 MB (117.1–137.8) | 128.8 MB (113.2–141.6) |
| cargar | 154.2 MB (127.9–156.8) | 150.1 MB (138.5–170.9) |
| plano (bay_plan) | 156.2 MB (129.7–159.3) | 155.7 MB (141.5–177.5) |
| las 72 bahías | 161.3 MB (147.2–174.6) | 155.0 MB (150.2–178.6) |
| Estadísticas | 182.7 MB (162.5–185.9) | 171.9 MB (155.8–185.5) |
| buscar | 189.5 MB (170.9–190.2) | 189.7 MB (164.5–194.9) |
| Lista (estable de T-99) | 510.5 MB (495.4–524.9) | 513.6 MB (484.1–519.7) |

Lectura: **el plano nuevo no cambia la memoria.** En los pasos que son del plano (abrirlo y recorrer
las 72 bahías con la silueta) la mediana queda igual o un poco por debajo (156.2 → 155.7 y 161.3 →
155.0 MB), dentro del ruido entre corridas (± 15 MB). El «estable» de T-99 sigue en ≈ 510 MB en los
dos bancos y sigue sin cumplir el umbral de 200 MB: el salto de 190 a 510 MB ocurre al volver a la
Lista, igual antes y después, y es lo que RNF-001 y RNF-007 piden resolver con la construcción
perezosa de la Lista (`SPRINT-4.md`, sección 2), que no es de esta entrega. Pico y estable coinciden
porque el máximo se alcanza en el último paso. Esta medición es de memoria, no de tiempos: no
reemplaza a T-99 ni a sus bancos, solo responde «¿el plano nuevo gasta más?»: no.

### 4.8 Lo que no se pudo, lo que queda y lo que Carlos decide

- **La barra de T-91 se retira** (es lo que `DESIGN.md` 8 pide). `planToolbarCollapsedProvider` y
  su almacén (`getPlanToolbarCollapsed` / `setPlanToolbarCollapsed`) quedan sin lector; retirarlos
  toca `domain/` y `data/`, así que se propone como tarea (`t91_plan_toolbar_test` conserva la
  prueba del almacén).
- **`BsCelda` no dibuja icono y código a la vez**: por eso la celda de carga lleva el OR como
  código y el estado como rol y segunda línea, y en el muelle «Sube» / «Cargado» se distinguen por
  el rol y la etiqueta accesible. Si se quiere el icono junto al OR es un cambio de la pieza
  (`bs_celda.dart`), que acaba de aceptarse.
- **En la barra inferior los rótulos escalan hasta 1.3** y «Estadísticas» se escribe «Estad.»:
  cinco destinos en 360 dp dan 72 dp a cada uno. El nombre entero va en la descripción emergente y
  para el lector de pantalla. Si Carlos prefiere cuatro destinos o rótulos solo en el activo
  (`onlyShowSelected`), es una línea.
- **Atrás en Android** (cerrar hojas y paneles primero, preguntar con un previo) no se tocó.
- **La leyenda en el panel lateral** (9.2 a 1920) queda para después: hoy va compacta bajo la
  rejilla en todos los anchos.
- **El «antes» del plano** son las capturas del manual de T-100 (`docs/manual/w05-*`,
  `w08-plano-modo-*`, `h05-*`, `h08-*`) y los previos de la entrega 1
  (`docs/rediseno/fase3/despues/`): el conductor de la entrega 1 no tiene el escenario `plano`.
  La RAM «antes» sí se midió con un banco compilado de `HEAD` (ccc8c2f, el código del plano
  anterior) en `%TEMP%\t99-r4-antes\copia`; su primer `flutter build windows` falló con el
  SDK de C++ de Firebase a medio extraer y bastó borrar `build/windows` y compilar de nuevo (el
  binario que «no arrancaba su conductor» era ese, a medio compilar).
- **Lo que las capturas dejan a la vista y no se tocó:** a 360 dp con letra 1.45 y 2.0 el chip del
  zoom («100 %») se superpone a la última columna de la rejilla, porque el área del plano es
  corta y 9.2 lo fija en la esquina inferior derecha; en el emulador la banda del muelle escribe
  «BUQUE MAN…» con elipsis (es el recurso que la sección 10 de `DESIGN.md` prevé para RNF-003 en 360 dp, «título con elipsis»; el nombre entero
  va en la Lista y en «Avance»). En el emulador a 2.0, el contador «re-estibas» de la barra de la
  operación parte la palabra («re-estiba / s»): tres contadores en 360 dp a esa letra no caben en una
  línea. Si Carlos prefiere el chip del zoom fuera del lienzo, el nombre en dos líneas o «re-est.» a
  2.0, es una línea en cada sitio.

### 4.9 El tema en caché (bloque aparte, 10.17)

`BayStreamApp.build` construía un `ThemeData` nuevo en cada build y el `AnimatedTheme` de
`MaterialApp` corría 200 ms aunque nada hubiera cambiado. Ahora `bayStreamTemaClaro` y
`bayStreamTemaOscuro` (`lib/core/app.dart`) construyen el tema una vez por densidad y devuelven la
misma instancia; `BayStreamTema` sigue construyendo uno nuevo cada vez que se le pide (T-115 le
pasa otra tabla de «Colorear por»). `test/t114_tema_cache_test.dart` (2) comprueba la identidad por
densidad y brillo y que un rebuild de `BayStreamApp` deje el mismo `ThemeData` sin animaciones
corriendo. Es su propio bloque de git.

### 4.10 Horas

De ≈ 17:30 del 22-oct-2026 (después de entregar la corrección de la Fase 2 bis) a ≈ 03:00 del
23-oct: **≈ 9.5 h**, de las que más de la mitad son esperas en segundo plano (ocho tandas de la
suite, cinco compilaciones del banco en tres clientes, diez tandas de capturas, la RAM antes y
después y RNF-002 en tres clientes), con una pausa por el límite de uso.

### Git para Carlos (Fase 3, entrega 2)

Después del bloque de la corrección de la Fase 2 bis (ya subido). Un `git add` por ruta;
`pubspec.yaml` y `pubspec.lock` no cambian; `domain/`, `data/`, `lib/main.dart` y los congelados no
cambian. Los tres generados de `windows/flutter/` figuran modificados solo por el fin de línea y no
se agregan.

```
git add -- DESIGN.md
git add -- lib/core/design/bs_medidas.dart
git add -- lib/core/design/bs_tema.dart
git add -- lib/core/design/componentes/bs_banda.dart
git add -- lib/core/design/componentes/bs_banda_muelle.dart
git add -- lib/core/design/componentes/bs_cartela.dart
git add -- lib/core/design/componentes/bs_silueta_buque.dart
git add -- lib/core/design/componentes/bs_tarjeta_cifra.dart
git add -- lib/features/vessel/presentation/pages/operation_progress_page.dart
git add -- lib/features/vessel/presentation/pages/vessel_overview_page.dart
git add -- lib/features/vessel/presentation/widgets/bay_plan_view.dart
git add -- lib/features/vessel/presentation/widgets/container_search_delegate.dart
git add -- lib/features/vessel/presentation/widgets/loading_controls.dart
git add -- lib/features/vessel/presentation/widgets/loading_plan_controls.dart
git add -- lib/features/vessel/presentation/widgets/plan_drag_confirmation.dart
git add -- lib/features/vessel/presentation/providers/plano_providers.dart
git add -- lib/features/vessel/presentation/widgets/cifras_del_viaje.dart
git add -- lib/features/vessel/presentation/widgets/detalle_contenedor.dart
git add -- lib/features/vessel/presentation/widgets/en_vivo_del_viaje.dart
git add -- lib/features/vessel/presentation/widgets/navegacion_del_viaje.dart
git add -- lib/features/vessel/presentation/widgets/silueta_del_viaje.dart
git add -- test/bay_plan_grid_test.dart
git add -- test/effective_weight_test.dart
git add -- test/profile_loading_page_test.dart
git add -- test/recent_voyages_test.dart
git add -- test/support/t91_toolbar_support.dart
git add -- test/t102_weight_display_test.dart
git add -- test/t104_text_test.dart
git add -- test/t106_plan_widget_test.dart
git add -- test/t107_tabs_test.dart
git add -- test/t110_bays_test.dart
git add -- test/t114_fase3_inicio_test.dart
git add -- test/t114_fase3_plano_test.dart
git add -- test/t114_fuentes_test.dart
git add -- test/t69_reserved_slots_view_test.dart
git add -- test/t75_discharge_test.dart
git add -- test/t81_office_widget_test.dart
git add -- test/t90_theme_test.dart
git add -- test/t91_plan_toolbar_test.dart
git add -- test/t97_text_test.dart
git add -- test/vessel_profile_view_test.dart
git add -- tool/t112_censos.py
git add -- tool/t114_capturas_android_plano.py
git add -- tool/t114_capturas_web_plano.py
git add -- tool/t114_capturas_windows.ps1
git add -- tool/t114_primera_windows.py
git add -- tool/t114_ram_windows.ps1
git add -- tool/t99_conductor.dart
git add -- docs/rediseno/fase3/traspaso-entrega2.md
git add -- docs/rediseno/fase3/entrega2/flutter-ui-audit.txt
git add -- docs/rediseno/fase3/entrega2/censos/resumen.json
git add -- docs/rediseno/fase3/entrega2/censos/tablas.md
git add -- docs/rediseno/fase3/entrega2/despues-windows/1920x1080_claro_letra1.0_avance.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/1920x1080_claro_letra1.0_lista.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/1920x1080_claro_letra1.0_plano.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/1920x1080_claro_letra1.0_plano_descarga.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/1920x1080_claro_letra1.45_avance.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/1920x1080_claro_letra1.45_lista.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/1920x1080_claro_letra1.45_plano.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/1920x1080_claro_letra1.45_plano_descarga.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/1920x1080_claro_letra2.0_avance.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/1920x1080_claro_letra2.0_lista.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/1920x1080_claro_letra2.0_plano.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/1920x1080_claro_letra2.0_plano_descarga.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/1920x1080_oscuro_letra1.0_avance.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/1920x1080_oscuro_letra1.0_lista.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/1920x1080_oscuro_letra1.0_plano.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/1920x1080_oscuro_letra1.0_plano_descarga.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/1920x1080_oscuro_letra1.45_avance.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/1920x1080_oscuro_letra1.45_lista.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/1920x1080_oscuro_letra1.45_plano.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/1920x1080_oscuro_letra1.45_plano_descarga.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/1920x1080_oscuro_letra2.0_avance.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/1920x1080_oscuro_letra2.0_lista.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/1920x1080_oscuro_letra2.0_plano.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/1920x1080_oscuro_letra2.0_plano_descarga.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/360x800_claro_letra1.0_avance.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/360x800_claro_letra1.0_lista.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/360x800_claro_letra1.0_plano.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/360x800_claro_letra1.0_plano_descarga.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/360x800_claro_letra1.45_avance.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/360x800_claro_letra1.45_lista.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/360x800_claro_letra1.45_plano.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/360x800_claro_letra1.45_plano_descarga.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/360x800_claro_letra2.0_avance.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/360x800_claro_letra2.0_lista.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/360x800_claro_letra2.0_plano.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/360x800_claro_letra2.0_plano_descarga.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/360x800_oscuro_letra1.0_avance.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/360x800_oscuro_letra1.0_lista.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/360x800_oscuro_letra1.0_plano.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/360x800_oscuro_letra1.0_plano_descarga.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/360x800_oscuro_letra1.45_avance.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/360x800_oscuro_letra1.45_lista.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/360x800_oscuro_letra1.45_plano.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/360x800_oscuro_letra1.45_plano_descarga.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/360x800_oscuro_letra2.0_avance.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/360x800_oscuro_letra2.0_lista.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/360x800_oscuro_letra2.0_plano.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/360x800_oscuro_letra2.0_plano_descarga.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/600x960_claro_letra1.0_avance.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/600x960_claro_letra1.0_lista.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/600x960_claro_letra1.0_plano.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/600x960_claro_letra1.0_plano_descarga.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/600x960_claro_letra1.45_avance.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/600x960_claro_letra1.45_lista.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/600x960_claro_letra1.45_plano.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/600x960_claro_letra1.45_plano_descarga.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/600x960_claro_letra2.0_avance.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/600x960_claro_letra2.0_lista.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/600x960_claro_letra2.0_plano.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/600x960_claro_letra2.0_plano_descarga.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/600x960_oscuro_letra1.0_avance.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/600x960_oscuro_letra1.0_lista.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/600x960_oscuro_letra1.0_plano.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/600x960_oscuro_letra1.0_plano_descarga.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/600x960_oscuro_letra1.45_avance.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/600x960_oscuro_letra1.45_lista.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/600x960_oscuro_letra1.45_plano.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/600x960_oscuro_letra1.45_plano_descarga.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/600x960_oscuro_letra2.0_avance.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/600x960_oscuro_letra2.0_lista.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/600x960_oscuro_letra2.0_plano.png
git add -- docs/rediseno/fase3/entrega2/despues-windows/600x960_oscuro_letra2.0_plano_descarga.png
git add -- docs/rediseno/fase3/entrega2/despues-web/web_1280_claro_avance.png
git add -- docs/rediseno/fase3/entrega2/despues-web/web_1280_claro_lista.png
git add -- docs/rediseno/fase3/entrega2/despues-web/web_1280_claro_mas.png
git add -- docs/rediseno/fase3/entrega2/despues-web/web_1280_claro_plano.png
git add -- docs/rediseno/fase3/entrega2/despues-web/web_1280_claro_plano_descarga.png
git add -- docs/rediseno/fase3/entrega2/despues-web/web_1280_oscuro_avance.png
git add -- docs/rediseno/fase3/entrega2/despues-web/web_1280_oscuro_lista.png
git add -- docs/rediseno/fase3/entrega2/despues-web/web_1280_oscuro_mas.png
git add -- docs/rediseno/fase3/entrega2/despues-web/web_1280_oscuro_plano.png
git add -- docs/rediseno/fase3/entrega2/despues-web/web_1280_oscuro_plano_descarga.png
git add -- docs/rediseno/fase3/entrega2/despues-web/web_1920_claro_avance.png
git add -- docs/rediseno/fase3/entrega2/despues-web/web_1920_claro_lista.png
git add -- docs/rediseno/fase3/entrega2/despues-web/web_1920_claro_mas.png
git add -- docs/rediseno/fase3/entrega2/despues-web/web_1920_claro_plano.png
git add -- docs/rediseno/fase3/entrega2/despues-web/web_1920_claro_plano_descarga.png
git add -- docs/rediseno/fase3/entrega2/despues-web/web_1920_oscuro_avance.png
git add -- docs/rediseno/fase3/entrega2/despues-web/web_1920_oscuro_lista.png
git add -- docs/rediseno/fase3/entrega2/despues-web/web_1920_oscuro_mas.png
git add -- docs/rediseno/fase3/entrega2/despues-web/web_1920_oscuro_plano.png
git add -- docs/rediseno/fase3/entrega2/despues-web/web_1920_oscuro_plano_descarga.png
git add -- docs/rediseno/fase3/entrega2/despues-web/web_360_claro_avance.png
git add -- docs/rediseno/fase3/entrega2/despues-web/web_360_claro_lista.png
git add -- docs/rediseno/fase3/entrega2/despues-web/web_360_claro_mas.png
git add -- docs/rediseno/fase3/entrega2/despues-web/web_360_claro_plano.png
git add -- docs/rediseno/fase3/entrega2/despues-web/web_360_claro_plano_descarga.png
git add -- docs/rediseno/fase3/entrega2/despues-web/web_360_oscuro_avance.png
git add -- docs/rediseno/fase3/entrega2/despues-web/web_360_oscuro_lista.png
git add -- docs/rediseno/fase3/entrega2/despues-web/web_360_oscuro_mas.png
git add -- docs/rediseno/fase3/entrega2/despues-web/web_360_oscuro_plano.png
git add -- docs/rediseno/fase3/entrega2/despues-web/web_360_oscuro_plano_descarga.png
git add -- docs/rediseno/fase3/entrega2/despues-web/web_600_claro_avance.png
git add -- docs/rediseno/fase3/entrega2/despues-web/web_600_claro_lista.png
git add -- docs/rediseno/fase3/entrega2/despues-web/web_600_claro_mas.png
git add -- docs/rediseno/fase3/entrega2/despues-web/web_600_claro_plano.png
git add -- docs/rediseno/fase3/entrega2/despues-web/web_600_claro_plano_descarga.png
git add -- docs/rediseno/fase3/entrega2/despues-web/web_600_oscuro_avance.png
git add -- docs/rediseno/fase3/entrega2/despues-web/web_600_oscuro_lista.png
git add -- docs/rediseno/fase3/entrega2/despues-web/web_600_oscuro_mas.png
git add -- docs/rediseno/fase3/entrega2/despues-web/web_600_oscuro_plano.png
git add -- docs/rediseno/fase3/entrega2/despues-web/web_600_oscuro_plano_descarga.png
git add -- docs/rediseno/fase3/entrega2/despues-emulador/emulador_360_claro_letra1.0_avance.png
git add -- docs/rediseno/fase3/entrega2/despues-emulador/emulador_360_claro_letra1.0_lista.png
git add -- docs/rediseno/fase3/entrega2/despues-emulador/emulador_360_claro_letra1.0_mas.png
git add -- docs/rediseno/fase3/entrega2/despues-emulador/emulador_360_claro_letra1.0_plano.png
git add -- docs/rediseno/fase3/entrega2/despues-emulador/emulador_360_claro_letra1.0_plano_descarga.png
git add -- docs/rediseno/fase3/entrega2/despues-emulador/emulador_360_claro_letra1.0_plano_descarga_rejilla.png
git add -- docs/rediseno/fase3/entrega2/despues-emulador/emulador_360_claro_letra1.0_plano_rejilla.png
git add -- docs/rediseno/fase3/entrega2/despues-emulador/emulador_360_claro_letra1.45_avance.png
git add -- docs/rediseno/fase3/entrega2/despues-emulador/emulador_360_claro_letra1.45_lista.png
git add -- docs/rediseno/fase3/entrega2/despues-emulador/emulador_360_claro_letra1.45_mas.png
git add -- docs/rediseno/fase3/entrega2/despues-emulador/emulador_360_claro_letra1.45_plano.png
git add -- docs/rediseno/fase3/entrega2/despues-emulador/emulador_360_claro_letra1.45_plano_descarga.png
git add -- docs/rediseno/fase3/entrega2/despues-emulador/emulador_360_claro_letra1.45_plano_descarga_rejilla.png
git add -- docs/rediseno/fase3/entrega2/despues-emulador/emulador_360_claro_letra1.45_plano_rejilla.png
git add -- docs/rediseno/fase3/entrega2/despues-emulador/emulador_360_claro_letra2.0_avance.png
git add -- docs/rediseno/fase3/entrega2/despues-emulador/emulador_360_claro_letra2.0_lista.png
git add -- docs/rediseno/fase3/entrega2/despues-emulador/emulador_360_claro_letra2.0_mas.png
git add -- docs/rediseno/fase3/entrega2/despues-emulador/emulador_360_claro_letra2.0_plano.png
git add -- docs/rediseno/fase3/entrega2/despues-emulador/emulador_360_claro_letra2.0_plano_descarga.png
git add -- docs/rediseno/fase3/entrega2/despues-emulador/emulador_360_claro_letra2.0_plano_descarga_rejilla.png
git add -- docs/rediseno/fase3/entrega2/despues-emulador/emulador_360_claro_letra2.0_plano_rejilla.png
git add -- docs/rediseno/fase3/entrega2/despues-emulador/emulador_360_oscuro_letra1.0_avance.png
git add -- docs/rediseno/fase3/entrega2/despues-emulador/emulador_360_oscuro_letra1.0_lista.png
git add -- docs/rediseno/fase3/entrega2/despues-emulador/emulador_360_oscuro_letra1.0_mas.png
git add -- docs/rediseno/fase3/entrega2/despues-emulador/emulador_360_oscuro_letra1.0_plano.png
git add -- docs/rediseno/fase3/entrega2/despues-emulador/emulador_360_oscuro_letra1.0_plano_descarga.png
git add -- docs/rediseno/fase3/entrega2/despues-emulador/emulador_360_oscuro_letra1.0_plano_descarga_rejilla.png
git add -- docs/rediseno/fase3/entrega2/despues-emulador/emulador_360_oscuro_letra1.0_plano_rejilla.png
git add -- docs/rediseno/fase3/entrega2/ram/ram-antes-corridas.csv
git add -- docs/rediseno/fase3/entrega2/ram/ram-antes-resumen.md
git add -- docs/rediseno/fase3/entrega2/ram/ram-antes-windows.csv
git add -- docs/rediseno/fase3/entrega2/ram/ram-despues-corridas.csv
git add -- docs/rediseno/fase3/entrega2/ram/ram-despues-resumen.md
git add -- docs/rediseno/fase3/entrega2/ram/ram-despues-windows.csv
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin01/captura.json
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin01/cuadro-00016.jpg
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin01/cuadro-00017.jpg
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin01/cuadro-00018.jpg
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin01/cuadro-00070.jpg
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin01/cuadro-00071.jpg
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin01/cuadro-00072.jpg
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin01/cuadro-00073.jpg
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin01/cuadros.json
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin02/captura.json
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin02/cuadro-00008.jpg
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin02/cuadro-00009.jpg
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin02/cuadro-00010.jpg
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin02/cuadro-00056.jpg
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin02/cuadro-00057.jpg
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin02/cuadro-00058.jpg
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin02/cuadro-00059.jpg
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin02/cuadros.json
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin03/captura.json
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin03/cuadro-00008.jpg
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin03/cuadro-00009.jpg
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin03/cuadro-00010.jpg
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin03/cuadro-00051.jpg
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin03/cuadro-00052.jpg
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin03/cuadro-00053.jpg
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin03/cuadro-00054.jpg
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin03/cuadros.json
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin04/captura.json
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin04/cuadro-00008.jpg
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin04/cuadro-00009.jpg
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin04/cuadro-00010.jpg
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin04/cuadro-00053.jpg
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin04/cuadro-00054.jpg
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin04/cuadro-00055.jpg
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin04/cuadro-00056.jpg
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin04/cuadros.json
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin05/captura.json
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin05/cuadro-00008.jpg
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin05/cuadro-00009.jpg
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin05/cuadro-00010.jpg
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin05/cuadro-00046.jpg
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin05/cuadro-00047.jpg
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin05/cuadro-00048.jpg
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin05/cuadro-00049.jpg
git add -- docs/rediseno/fase3/entrega2/rnf-002/android/sin05/cuadros.json
git add -- docs/rediseno/fase3/entrega2/rnf-002/web/sin-caliente/resumen.json
git add -- docs/rediseno/fase3/entrega2/rnf-002/web/sin-caliente/sin01-inicio.png
git add -- docs/rediseno/fase3/entrega2/rnf-002/web/sin-caliente/sin01-registro.json
git add -- docs/rediseno/fase3/entrega2/rnf-002/web/sin-caliente/sin01-rejilla.png
git add -- docs/rediseno/fase3/entrega2/rnf-002/web/sin-caliente/sin02-registro.json
git add -- docs/rediseno/fase3/entrega2/rnf-002/web/sin-caliente/sin03-registro.json
git add -- docs/rediseno/fase3/entrega2/rnf-002/web/sin-caliente/sin04-registro.json
git add -- docs/rediseno/fase3/entrega2/rnf-002/web/sin-caliente/sin05-registro.json
git add -- docs/rediseno/fase3/entrega2/rnf-002/web/sin-fria/resumen.json
git add -- docs/rediseno/fase3/entrega2/rnf-002/web/sin-fria/sin01-inicio.png
git add -- docs/rediseno/fase3/entrega2/rnf-002/web/sin-fria/sin01-registro.json
git add -- docs/rediseno/fase3/entrega2/rnf-002/web/sin-fria/sin01-rejilla.png
git add -- docs/rediseno/fase3/entrega2/rnf-002/web/sin-fria/sin02-registro.json
git add -- docs/rediseno/fase3/entrega2/rnf-002/web/sin-fria/sin03-registro.json
git add -- docs/rediseno/fase3/entrega2/rnf-002/web/sin-fria/sin04-registro.json
git add -- docs/rediseno/fase3/entrega2/rnf-002/web/sin-fria/sin05-registro.json
git add -- docs/rediseno/fase3/entrega2/rnf-002/windows/resumen-sin.json
git add -- docs/rediseno/fase3/entrega2/rnf-002/windows/sin01/final.png
git add -- docs/rediseno/fase3/entrega2/rnf-002/windows/sin01/inicio.png
git add -- docs/rediseno/fase3/entrega2/rnf-002/windows/sin01/registro.json
git add -- docs/rediseno/fase3/entrega2/rnf-002/windows/sin01/rejilla.png
git add -- docs/rediseno/fase3/entrega2/rnf-002/windows/sin02/registro.json
git add -- docs/rediseno/fase3/entrega2/rnf-002/windows/sin03/registro.json
git add -- docs/rediseno/fase3/entrega2/rnf-002/windows/sin04/registro.json
git add -- docs/rediseno/fase3/entrega2/rnf-002/windows/sin05/registro.json
git add -- docs/REDISENO-RESULTADOS.md
git commit -m "Sprint 4: fase 3, entrega 2, el plano por bahia en la direccion C con navegacion adaptable, silueta, celdas del icono y banda del muelle"
git push
```

### Git para Carlos (el tema en caché, bloque aparte)

```
git add -- lib/core/app.dart
git add -- test/t114_tema_cache_test.dart
git commit -m "Sprint 4: el tema se construye una vez por densidad, sin AnimatedTheme de mas"
git push
```

### Tres líneas

- El plano por bahía es el de la dirección C en Windows, la Web y Android: navegación adaptable,
  silueta, tarjetas, celdas como el ícono, detalle único, «En vivo», banda del muelle y el naranja
  con la bitácora.
- Suite 1242 en verde, `analyze` 0, censos sin inglés, auditoría sin críticos ni avisos nuevos fuera de
  los tokens; RNF-002 sigue en tres pasos y la RAM queda medida antes y después.
- La barra de T-91 se retira como pide `DESIGN.md` 8; su preferencia queda sin lector (tarea
  propuesta). ALTO: Codex acepta la entrega 2.

### Mensaje para Yov

Yov: la **Fase 3, entrega 2** (10.16 + 10.17) queda lista para Codex, en dos bloques de git: el de la
entrega y, aparte, el del tema en caché (`lib/core/app.dart` + `test/t114_tema_cache_test.dart`).
**Qué hay:** el plano por bahía en la dirección C en los tres clientes: navegación adaptable
(`NavigationBar` < 600, riel con la marca desde 600, riel + panel de 360 desde 1200), la silueta
como selector, tarjetas de cifra con la operación real (solo con escala), la rejilla como el ícono
(`BsCelda` con «Colorear por» en tres vistas, tapa, casco), el detalle en una sola hoja (panel o
hoja inferior), «En vivo» con la bitácora, la banda del muelle con Descarga / Carga, la barra de la
operación y el naranja 1.5 s con datos de verdad; lo pendiente de 10.8/10.16 resuelto («Contenido»
y «Número de orden» enteros, el código de cinco letras a 2.0, la acción de la banda que baja de
línea, el conductor sin pestañas, los contadores en aviso/error y el `Badge` global sin grúa,
`t114_fuentes_test` sin depender del fin de línea, 13.5 con la decisión). **Lo que enseñaron las
capturas y se corrigió antes de cerrar:** el título de la bahía cortado a 360 (ahora al ancho de la
vista) y, en el emulador de 360 × 640, la rejilla bajo el pliegue: con menos de 560 dp de alto útil
la cabecera (controles y silueta) se va al desplazar la rejilla y vuelve (`NestedScrollView`,
13.8); a 360 × 800 (Honor, arnés) no cambia nada. **Números:** suite 1242 (piso 1224), `analyze` 0,
censos 1931 visibles / 0 en inglés, M3 251/7/3, auditoría sin críticos nuevos; RNF-002 sigue en
tres pasos (Windows 1.84–2.19 s, Web 0.30–0.48 y 1.28–1.60 en primera visita, emulador cotas
3.06–3.88 s); la RAM antes/después en Windows es igual en los pasos del plano (≈ 156 MB) y el
estable de T-99 sigue en ≈ 510 MB por la Lista, que es lo de RNF-001/007 pendiente. **Evidencia:**
72 + 40 + 28 capturas, RAM y RNF-002 en `docs/rediseno/fase3/entrega2/`. **Para Carlos:** (1) la
barra de T-91 se retira como pide `DESIGN.md` 8 y su preferencia queda sin lector (tocarla es
`domain/`+`data/`: tarea); (2) la leyenda en el panel lateral a 1920 queda para después; (3) a
360 × 2.0 el chip del zoom pisa la última columna y «re-estibas» se parte, y en el emulador la
banda escribe «BUQUE MAN…»: tres líneas si las quieres distintas. Me detengo: ALTO: Codex acepta la
entrega 2.


## Fase 3 · Entrega 2 · Corrección tras la aceptación de Codex (23-oct-2026, 10.21)

El brief es 10.21 de `SPRINT-4.md`: los cuatro hallazgos del dictamen NO PASA de Codex
(`docs/rediseno/fase3/entrega2/aceptacion-codex.md`), el aviso de `IntrinsicHeight` y el chip del
zoom fuera de la rejilla (10.20). La dirección sigue siendo `DESIGN.md` 8, 13.3, 13.6 y 13.8, que
se corrigen donde el código cambia. Es un chat nuevo de Timonel; el punto de partida fue el paso 0:
los cuatro commits de la entrega 2 (`d1ce1db`), el tema en caché (`f62f709`), la evidencia
(`9522794`) y el dictamen con la decisión 10.21 (`52dd1b6`) están en la historia, y en el árbol
solo quedaban los tres generados de `windows/flutter/` con el fin de línea cambiado, que no son de
nadie y no se tocan.

### 4c.1 Resultado en tres líneas

- **Los cuatro hallazgos están corregidos y cada uno tiene su prueba:** la cabecera de la oficina
  se reparte o se pliega según el ancho y la letra y Buscar queda siempre al alcance (H1, probado
  en 600 dp exactos con 1.0, 1.45 y 2.0, y en 360 y 1920); la celda de carga recibe el movimiento
  real, también el lleno del listado y la reserva con su vacío asignado, 1.5 s y quieta con
  reducción de movimiento (H2, una prueba que va de la bitácora a la celda sin inyectar el
  proveedor del naranja); sin panel lateral el movimiento se anuncia en una región en vivo con el
  rol y nada más (H3, 360 y 600 dp); y en el teléfono bajo la primera rejilla se ve sin desplazar
  (H4, 360 × 640 dp con la barra de estado, en el previo y en Descarga).
- **El riel ya no usa `IntrinsicHeight`** (`CustomScrollView` + `SliverFillRemaining` con su ancho
  medido con la fuente) y **el chip del zoom salió de la rejilla**: vive en la línea de los
  controles del plano con un menú anclado, y la escala en `planZoomProvider`.
- Suite **1260 en verde** (piso 1242 → **1260**: 18 pruebas nuevas en
  `test/t114_fase3_entrega2_correccion_test.dart`, una actualizada, ninguna omitida);
  `analyze` **«No issues found»**; auditoría de `flutter-ui` **17 críticos, 248 avisos y 20
  informativos** (la entrega 2 traía 249 avisos: el que se va es el `IntrinsicHeight`, y en los
  archivos tocados no hay ningún hallazgo nuevo). RNF-002 en Android, repetido con el mismo
  instrumento, en 4c.5. **ALTO: Codex acepta la corrección.**

### 4c.2 Lo hecho, hallazgo por hallazgo

- **H1 · La cabecera de la oficina** (`_CabeceraDeOficina`, `pages/vessel_overview_page.dart`).
  Era una sola `Row` con el título estirable, el estado, Descarga / Carga, Buscar y la nube; a
  600 dp con la letra a 2.0 los anchos fijos sumaban más que la pantalla y Buscar quedaba fuera
  (624.9–672.9 dp, desborde de 137 px). Ahora Buscar y la nube quedan anclados al borde derecho,
  fuera del reparto, y lo demás va en un `Wrap` con `spaceBetween`: el título a la izquierda y
  los controles (el estado y los segmentos, en su propio `Wrap`) a la derecha mientras caben en
  una línea; si el ancho o la letra no lo permiten, los controles bajan a una segunda línea y nada
  se desborda. No hay umbral escrito a mano: lo decide la medida real de cada cosa con la fuente
  del sistema, así que vale igual para un nombre de buque largo. A 600 dp con 1.0 cabe en una
  línea; con 1.45 y 2.0 se pliega. La prueba mide en 600 dp exactos que Buscar y los segmentos
  reciben el toque y terminan dentro de la pantalla, que no hay desbordamiento, y que con la
  letra grande los controles quedan debajo del título; a 1920 comprueba la línea única y a 360,
  la barra superior del teléfono. `DESIGN.md` 8 anota la regla.
- **H2 · La celda de carga** (`LoadingCell` en `widgets/loading_controls.dart`; `_BayGridWidget`
  en `widgets/bay_plan_view.dart`; `providers/plano_providers.dart`). `LoadingCell` solo conocía la
  categoría pendiente / hecho; ahora recibe `recienMovida` y la rejilla se la enciende cuando lo
  recién movido es su embarque: el lleno del listado (`C:<contenedor>`) o la reserva cuyo
  `assignedContainer` es el vacío que acaba de asignarse. Además, el proveedor del naranja
  descartaba los vacíos asignados sin decirlo: `Movement.position` solo lee `payload['position']`,
  y un vacío asignado trae su celda en el `target` (`R:0030482`); `_posicionDe` la toma de ahí,
  tanto para encender la celda como para escribir la celda en «En vivo» («Vacío asignado · Muelle ·
  EMPTY 000001 2 · 003-04-82»). La prueba arma la operación de T-76 sobre la bitácora en memoria de
  T-75, como `t76_loading_widget_test`, con los dos ocupantes de llegada ya bajados; anexa a la
  bitácora un lleno (`FULL0001234` en 003-02-82) y después un vacío asignado a la reserva
  003-04-82, y sigue cada uno hasta la celda: el proveedor del naranja no se toca (lo alimenta el
  plano desde la operación), la única celda en naranja es la de ese embarque, su etiqueta dice «se
  acaba de mover», a los 1480 ms sigue y a los 1500 se apaga; a 360, 600 y 1920 dp. Una prueba
  aparte, con la reducción de movimiento del sistema, comprueba que el cuerpo de la celda no se
  mueve ni a los 75 ni a los 150 ms.
- **H3 · El anuncio sin panel** (`AnuncioDelMovimiento`, nuevo, en `widgets/en_vivo_del_viaje.dart`;
  montado en `vessel_overview_page.dart` solo cuando no hay panel lateral). Es una región en vivo
  sin dibujo (`Semantics(liveRegion: true)` sobre una caja de tamaño cero) cuya etiqueta es la
  misma de la fila más reciente de «En vivo» («Cargado, Muelle, FULL 000123 4 · 003-02-82,
  ahora»): qué pasó, el rol del equipo, el contenedor, la celda y «ahora»; nunca un nombre. Aparece
  cuando el movimiento ya está en la bitácora y se va cuando el naranja se apaga; con el panel
  (desde 1200 dp) no se monta, para que no haya dos anuncios. El panel de la oficina no se lleva
  al teléfono: solo el anuncio. La prueba de H2 comprueba a 360 y 600 que hay exactamente una
  región en vivo con ese texto, que el nodo de semántica tiene la bandera de región en vivo, que
  no contiene el nombre sintético del autor y que «En vivo» no está; a 1920, que el anuncio lo da
  «En vivo» y la región sin dibujo no se monta. `DESIGN.md` 13.3, punto 5, lo anota.
- **H4 · El teléfono bajo** (`DESIGN.md` 13.8, nuevo párrafo). Primero se midió, con una prueba
  de diagnóstico a 360 × 640 dp con la barra de estado de 24 dp del emulador, la densidad del
  muelle, las fuentes del producto y un plano sintético con seis niveles en bodega y seis en
  cubierta (288 contenedores, 12 bahías en la silueta): el área del plano medía 234 dp (de la
  banda de «sin evaluar» a la leyenda) y la cabecera anidada sumaba 251 (la fila de controles 77
  y la silueta 173), así que la rejilla ni se construía; en el muelle operando, con la banda de
  136 dp y la barra de la operación de 132, el área era de 268 y la cabecera de 250: la primera
  fila quedaba en 540 dp, bajo el pliegue. Como ningún recorte parcial alcanzaba (la silueta sola
  deja 71 dp y la primera fila necesita unos 180 desde el borde de la rejilla), el teléfono bajo
  (menos de 560 dp de alto útil para el plano: el emulador de 360 × 640 y también el previo a
  360 × 800, que trae sus dos avisos encima) arma el plano así:
  - la silueta va **compacta** (`BsSiluetaBuque(compacta: true)`, `SiluetaDelViaje(compacta:)`):
    los mismos niveles, números, barras de avance, botones de 56 dp y etiquetas, a 4 dp por nivel
    (3 pintados) y con menos aire; con seis y seis niveles mide 90 dp en vez de 161. Es lo único que
    queda arriba de la rejilla, y sigue yéndose al desplazarla y volviendo;
  - los **controles del plano bajan al pie** (`ParteDeLosControles.barra` en
    `LoadingPlanControls`): el modo, el chip del zoom, «Acciones» solo con su icono (su nombre va
    en la descripción emergente) y, en Carga, «OR / últimos dígitos», uno tras otro a su ancho, al
    principio de la línea que ya se desplaza: la leyenda o, en el muelle operando, la línea de la
    acción de la barra de la operación. La nube no se repite: ya está en la barra superior o en la
    banda. Las claves de T-107 (`bay-plan-display-mode`, `bay-plan-actions`, `empty-search`,
    `load-search`) no cambian;
  - el **resumen del modo** de T-107 va justo encima del pie (`ParteDeLosControles.resumen`); sin
    escala no se escribe «Confirma la escala para ver el plan de carga», porque la banda del previo
    ya dice qué falta;
  - en la **rejilla** el margen de arriba baja a 8 dp y los dos renglones del peso por pila (C-7)
    van debajo de la bodega, como los dibuja 9.2 bis, en vez de encima de la cubierta
    (`_BayGridWidget.compacta`).
  Con eso, a 360 × 640 dp con la barra de estado, en el previo la primera fila de la cubierta
  queda en 422–474 dp dentro de un área que termina en 486, y en Descarga en 338–390 dentro de
  160–403: **la primera rejilla se ve sin desplazar, en los tres pasos de RNF-002**. En Carga, con la
  línea del resumen, falta 14 dp y queda a un gesto, como antes. A 360 × 800 publicado (el Honor)
  nada cambia: los controles siguen sobre la silueta normal. Las pruebas fijan las cuatro
  situaciones (previo a 640, Descarga a 640, publicado a 800 y previo a 800) y la silueta compacta
  como pieza (mide 60 dp menos que la normal con las mismas bahías, etiquetas y botones de 48 dp o
  más). La prueba de la entrega 2 que desplazaba la cabecera a 360 × 640 sigue, con la ganancia de
  alto medida sobre la silueta que ahora es la cabecera.
- **El aviso de `IntrinsicHeight`** (`RielDelViaje`, `widgets/navegacion_del_viaje.dart`). El riel
  va en `CustomScrollView` con `SliverFillRemaining(hasScrollBody: false)`: llena la ventana y, si
  el riel pide más, crece y se desplaza. Un viewport dentro de una `Row` no tiene ancho, así que
  el riel se lo da: los 80 dp de `DESIGN.md` 8 o, si la letra del sistema lo pide, el del rótulo
  más largo con su aire, medido con la fuente (`TextPainter`), que también va como `minWidth` del
  `NavigationRail`. El pie (la nube y Parámetros) deja de ir en un `Expanded`: el grupo de destinos
  ya se queda con el alto sobrante, y aquel `Expanded` duplicaba el alto que el riel pedía en una
  ventana baja. La prueba lo monta en 800 × 560, comprueba que no hay `IntrinsicHeight` sobre el
  riel, que está dentro de un `CustomScrollView`, que la nube del pie se alcanza desplazando y que
  no hay desbordamiento.
- **El chip del zoom fuera de la rejilla** (10.20; `ZoomDelPlano`, nuevo, en
  `widgets/zoom_del_plano.dart`; `planZoomProvider` en `plano_providers.dart`;
  `PlanZoomViewport` en `widgets/plan_drag_confirmation.dart`). La escala del zoom de T-106 vive
  ahora en un proveedor: la rejilla la lee (y la pellizca) y el chip «100 %» la muestra en la línea
  de los controles del plano (al final de la fila ancha; en el teléfono, antes de la nube; en la
  tira del teléfono bajo, tras el modo). Un toque abre un menú anclado (`MenuAnchor`, Material 3)
  con alejar, «Restablecer» y acercar, que no tapa ninguna celda ni se desborda en 360 dp, y otro
  toque lo cierra. Las claves de T-105 y T-106 (`plan-zoom-toggle`, `plan-zoom-in`,
  `plan-zoom-out`, `plan-zoom-reset`, `plan-zoom-gesture`) se conservan y sus pruebas pasan sin
  cambios. Como la escala ya no vive en el `State` del lienzo de cada bahía, el zoom se conserva
  al cambiar de bahía y vuelve a 100 % al cerrar o cambiar el viaje (antes volvía a 100 % en cada
  bahía: se declara en 4c.7). La prueba, a 360 dp con la letra a 1.45 y 2.0, comprueba que el chip
  está en la línea de los controles y no pisa el lienzo de la rejilla, y que el menú acerca,
  restablece y se cierra. `DESIGN.md` 9.2 anota dónde vive ahora el chip.

### 4c.3 Pruebas

- Nueva: `test/t114_fase3_entrega2_correccion_test.dart` (**18**): H1 (600 dp × 1.0, 1.45 y
  2.0; 1920; 360 × 1.0 y 2.0), H2 y H3 (360, 600 y 1920 dp, más la reducción de movimiento), el
  riel sin `IntrinsicHeight`, el chip del zoom (1.45 y 2.0), y el teléfono bajo (previo a
  360 × 640, Descarga a 360 × 640, publicado a 360 × 800, previo a 360 × 800, y la silueta compacta
  como pieza). Carga las fuentes del producto para que las medidas sean las reales; la operación
  de H2 sale de la bitácora en memoria de T-75 y del fixture de T-76.
- Actualizada sin bajar el conteo: `test/t114_fase3_plano_test.dart` (la prueba de 360 × 640 mide
  la ganancia de alto contra la cabecera que queda, la silueta compacta, en vez de un número
  fijo).
- `test/t114_fase3_correccion_test.dart` **es la de la corrección de la entrega 1 (10.15) y no
  cambia**; ver 4c.7.

### 4c.4 Validaciones ejecutadas

Un comando de Flutter a la vez; la suite y el APK, en segundo plano. El Honor no se tocó.

- `flutter analyze --no-pub` → **«No issues found»** (después de cada tanda de cambios y al final).
- `flutter test --no-pub` → **1260 pruebas en verde, ninguna fallida ni omitida** (51 s; piso
  1242 → 1260).
- Auditoría de `flutter-ui` (`docs/rediseno/fase3/entrega2/correccion/flutter-ui-audit.txt`):
  **17 críticos, 248 avisos y 20 informativos** (entrega 2: 17, 249 y 20). Comparados hallazgo a
  hallazgo por código y archivo, la única diferencia es el `PERF_INTRINSIC_SIZE` de
  `navegacion_del_viaje.dart`, que se va. En los archivos tocados quedan los que ya estaban y se
  declaran: los dos «críticos» de `vessel_overview_page.dart` (los falsos positivos de
  `ReservedSlotsListView` y `ContainersListView` que el escáner toma por `ListView(children:)`), el
  `IntrinsicWidth` de la barra compacta de T-107 en `loading_plan_controls.dart` y el informativo
  `NAV_NO_POP_SCOPE`. Ninguno es nuevo. El escáner también cuenta la palabra dentro de un
  comentario, así que el comentario del riel no la escribe.
- Censos de T-112 (`tool/t112_censos.py`, referencia `5406e20`, salida en
  `docs/rediseno/fase3/entrega2/correccion/censos/`): idioma, **1932 cadenas visibles: 1801 en
  español y 131 sin idioma, 0 en inglés o mixtas** (entrega 2: 1931, 1800 y 131; la cadena nueva
  es «Restablecer», del menú del zoom); Material 3: **250 controles incluidos, 7 exclusiones y 3
  excepciones** (entrega 2: 251 / 7 / 3, sin excepción nueva: el chip del zoom deja de ser un
  `Material` propio sobre la rejilla y pasa a un `MenuAnchor`); mensajes: **217, los 217 con causa
  y acción y los 12 EDIFACT con su segmento**, como en la entrega 2. El instrumento solo aprende el
  archivo nuevo (`zoom_del_plano.dart`: canal pantalla, pantalla S02); sin eso no escribía las
  tablas.
### 4c.5 RNF-002 en Android, repetido (H4)

El mismo instrumento de la entrega 2 y el mismo recorrido de tres pasos: `tool/t114_primera_android.py`
(`am start` del banco r4, «Seleccionar archivo», el archivo en el selector de AOSP) y
`tool/t114_primera_cuadros.py` (el primer cuadro que difiere del lanzador y el primer cuadro quieto
con el plano, por los PTS del video). Emulador `t99_api26` (API 26, 360 × 640 dp con `wm density
480`, claro, letra 1.0), condición «sin perfil» (`pm clear` del paquete r4 antes de cada video),
`T99_SINTETICO_977.edi`, cinco repeticiones, el banco r4 recompilado desde el árbol corregido e
instalado encima del anterior. Umbral: **≤ 3 pasos y ≤ 30 s hasta la rejilla a la vista.**

| Rep. | Pasos | Cuadro inicio → fin (PTS, s) | Hasta la rejilla (s, cota) | Previo | ≤ 3 pasos y ≤ 30 s |
|---|---|---|---|---|---|
| sin01 | 3 | 9 (5.698) → 66 (10.610) | 4.911–4.984 | sí | cumple |
| sin02 | 3 | 9 (4.807) → 53 (7.760) | 2.954–3.202 | sí | cumple |
| sin03 | 3 | 11 (4.473) → 61 (7.395) | 2.922–2.959 | sí | cumple |
| sin04 | 3 | 11 (4.489) → 65 (7.445) | 2.956–2.997 | sí | cumple |
| sin05 | 3 | 11 (4.546) → 59 (7.390) | 2.845–2.894 | sí | cumple |

- **Los cuadros finales muestran celdas.** Se revisaron a ojo los cuadros que el instrumento
  propone como fin (66, 53, 61, 65 y 59) y sus vecinos: en los cinco se ven la barra superior, la
  banda del previo, «sin evaluar», la silueta compacta (bahías 01 a 06 a la vista), el título
  «Bahía 01 · tapas sin declarar», «2 contenedores · 23.2 t», la cabecera de columnas (22, 20, 18,
  16, 14) y **la primera fila de celdas** (nivel 04: cuatro huecos ocupados por 40 pies y el
  contenedor XXVS en la 14), y debajo la tira de los controles («Contenido», «100 %», «⋮» y la
  leyenda) y la barra inferior. Nada se desplazó: el instrumento no toca la pantalla después de
  elegir el archivo. En sin02 el cuadro 53 todavía tiene el selector desvaneciéndose encima (una
  transición semitransparente, como las que Codex describió); el 54 ya está limpio y se guarda.
- **Tiempos.** La primera repetición (4.91–4.98 s) es la que sigue a la instalación del APK nuevo,
  al `pm clear` y a la primera apertura del selector (que abre en «Recent» vacío y hay que
  llevarlo a Descargas y a `t114`): es la misma condición de la primera repetición de la entrega 2
  (3.84–3.88 s), con el coste añadido del primer arranque del paquete recién instalado. Las otras
  cuatro quedan en **2.85–3.20 s**, por debajo de las de la entrega 2 (3.06–3.42 s): la cabecera
  que se construye ahora es más corta. La cota incluye las lecturas de uiautomator del
  instrumento, así que sigue siendo un límite superior, como en T-98 y en las dos entregas.
- Registros en `docs/rediseno/fase3/entrega2/correccion/rnf-002/android/` (`sinNN/captura.json`
  con las acciones del host, los PTS y el SHA-256 del video; `sinNN/cuadros.json` con los cuadros
  propuestos, las diferencias por cuadro y las dos cotas; los siete JPEG candidatos de cada
  corrida, inicio y fin con sus vecinos; y `resumen.json` con la tabla). Los MP4 quedan en
  `%TEMP%/claude-corr/primera/android/`, fuera del repositorio.
- Windows y la Web no se repitieron: nada de esta corrección toca su recorrido de tres pasos
  (Codex repitió Windows en su aceptación: 1.929 s), y la cabecera de la oficina que cambia no
  está en ese recorrido. El Honor no se tocó.

### 4c.6 Archivos de esta corrección

Ninguno de `domain/`, `data/`, `lib/main.dart`, `pubspec.*` ni los congelados; `pubspec.yaml` y
`pubspec.lock` no cambian.

- **Nuevos en `lib/`:** `features/vessel/presentation/widgets/zoom_del_plano.dart`.
- **Modificados en `lib/`:** `features/vessel/presentation/pages/vessel_overview_page.dart`,
  `providers/plano_providers.dart`, `widgets/bay_plan_view.dart`, `widgets/en_vivo_del_viaje.dart`,
  `widgets/loading_controls.dart`, `widgets/loading_plan_controls.dart`,
  `widgets/navegacion_del_viaje.dart`, `widgets/plan_drag_confirmation.dart`,
  `widgets/silueta_del_viaje.dart`; `core/design/componentes/bs_silueta_buque.dart`.
- **Pruebas:** nueva `test/t114_fase3_entrega2_correccion_test.dart`; actualizada
  `test/t114_fase3_plano_test.dart`.
- **Instrumentos:** `tool/t112_censos.py` (aprende `zoom_del_plano.dart`).
- **Documentos y evidencia:** `DESIGN.md` (8, 9.2, 13.3, 13.6 y 13.8),
  `docs/rediseno/fase3/traspaso-entrega2.md` (la nota de la corrección),
  `docs/rediseno/fase3/entrega2/correccion/` (la auditoría, los censos y RNF-002 de Android) y esta
  sección.
- **Fuera del bloque:** los tres generados de `windows/flutter/`, que solo cambian el fin de línea.

### 4c.7 Lo que queda anotado y lo que Carlos decide

- **El teléfono bajo en Carga** (360 × 640, operando) queda a un gesto: con la línea del resumen
  encima de la barra de la operación faltan 14 dp para la primera fila. La medición de RNF-002 es
  el previo, que sí la muestra. Si Carlos prefiere que en Carga el resumen también se pliegue, es
  una línea.
- **El zoom se conserva al cambiar de bahía.** Antes la escala vivía en el lienzo de cada bahía y
  volvía a 100 % al cambiarla; con el proveedor, el planificador que acerca a 150 % recorre las
  bahías a 150 % y el zoom vuelve a 100 % al cerrar o cambiar el viaje. Las pruebas de T-105 y
  T-106 no dependían de aquello. Si Carlos prefiere el reinicio por bahía, es una línea en el
  proveedor.
- **Los pesos por pila debajo de la bodega solo en el teléfono bajo.** En los demás tamaños siguen
  arriba, donde C-7 los puso; 9.2 bis los dibuja abajo. Si Carlos quiere la misma posición en
  todos los tamaños, es un cambio de una condición.
- **«Confirma la escala para ver el plan de carga»** no se escribe en el teléfono bajo (la banda
  del previo ya dice qué falta); en los demás tamaños sigue.
- **Un archivo de prueba se sobrescribió y se restauró.** El primer borrador de las pruebas de esta
  corrección se guardó con el nombre `test/t114_fase3_correccion_test.dart`, que ya era el de las
  cuatro pruebas de la corrección de la entrega 1 (10.15): la suite bajó a 1256 y lo delató. El
  archivo se restauró desde `HEAD` con `git show` (una lectura), byte a byte (`git diff --stat` no
  lo lista), y las pruebas nuevas viven en `test/t114_fase3_entrega2_correccion_test.dart`. Se
  deja escrito para que Codex no tenga que deducirlo del árbol.
- **La región en vivo sin dibujo** es una caja de tamaño cero con `Semantics(liveRegion: true)`:
  el árbol de semántica la conserva (la prueba lee su nodo con la bandera), y es el mecanismo que
  Flutter recomienda frente a `SemanticsService.announce`, que Android desaconseja. No se probó con
  TalkBack en el Honor (fuera de esta corrección); si en la prueba de campo no se oyera, el
  recurso es darle 1 dp de alto.
- **La prueba de diagnóstico** del presupuesto de alto (la que dio las cifras de 4c.2) fue
  temporal y no se versiona; las cifras quedan aquí y las pruebas de H4 fijan el resultado.
- **Las corridas de Android y el emulador**: el instrumento y el emulador son los de la entrega 2
  (`t99_api26`, API 26, 360 × 640 dp con `wm density 480`); el banco r4 se compiló desde una copia
  del árbol corregido (`tool/t99_copia.ps1 -Arbol -Sufijo r4`, `flutter pub get` en la copia y
  `flutter build apk --release -t tool/t99_main.dart`) y se instaló encima del anterior con el mismo
  identificador.

### 4c.8 Horas
De ≈ 06:15 a ≈ 08:00 del 23-oct-2026: **≈ 1.8 h**, con la lectura del paso 0, el diagnóstico del
presupuesto de alto, las seis correcciones con sus pruebas, tres tandas de la suite completa, la
auditoría, los censos, la compilación del banco r4 y las cinco corridas de Android.

### Git para Carlos (Fase 3, entrega 2, corrección)

Un `git add` por ruta; `pubspec.yaml` y `pubspec.lock` no cambian; `domain/`, `data/`,
`lib/main.dart` y los congelados no cambian. Los tres generados de `windows/flutter/` figuran
modificados solo por el fin de línea y no se agregan. La evidencia nueva va por carpeta porque son
solo archivos nuevos de evidencia (la regla de las 60 rutas).

```
git add -- DESIGN.md
git add -- lib/core/design/componentes/bs_silueta_buque.dart
git add -- lib/features/vessel/presentation/pages/vessel_overview_page.dart
git add -- lib/features/vessel/presentation/providers/plano_providers.dart
git add -- lib/features/vessel/presentation/widgets/bay_plan_view.dart
git add -- lib/features/vessel/presentation/widgets/en_vivo_del_viaje.dart
git add -- lib/features/vessel/presentation/widgets/loading_controls.dart
git add -- lib/features/vessel/presentation/widgets/loading_plan_controls.dart
git add -- lib/features/vessel/presentation/widgets/navegacion_del_viaje.dart
git add -- lib/features/vessel/presentation/widgets/plan_drag_confirmation.dart
git add -- lib/features/vessel/presentation/widgets/silueta_del_viaje.dart
git add -- lib/features/vessel/presentation/widgets/zoom_del_plano.dart
git add -- test/t114_fase3_entrega2_correccion_test.dart
git add -- test/t114_fase3_plano_test.dart
git add -- tool/t112_censos.py
git add -- docs/rediseno/fase3/traspaso-entrega2.md
git add -- docs/rediseno/fase3/entrega2/correccion/flutter-ui-audit.txt
git add -- docs/rediseno/fase3/entrega2/correccion/censos
git add -- docs/rediseno/fase3/entrega2/correccion/rnf-002
git add -- docs/REDISENO-RESULTADOS.md
git commit -m "Sprint 4: correccion de la entrega 2 de la fase 3, cabecera que se pliega, naranja en la celda de carga, anuncio sin panel, rejilla a la vista en el telefono bajo, riel sin IntrinsicHeight y zoom fuera de la rejilla"
git push
```

### Tres líneas

- H1 a H4 corregidos con prueba propia: la cabecera se pliega y Buscar queda al alcance; la celda
  de carga (lleno o reserva) se enciende desde la bitácora; el anuncio accesible existe sin panel;
  a 360 × 640 la primera rejilla se ve sin desplazar.
- El riel va sin `IntrinsicHeight` y el chip del zoom salió de la rejilla a la línea de los
  controles; suite 1260 (piso 1242), `analyze` 0, auditoría con un aviso menos y ninguno nuevo.
- RNF-002 en Android repetido con el mismo instrumento, con los cuadros que muestran celdas.
  ALTO: Codex acepta la corrección.

### Mensaje para Yov
Yov: la **corrección de la entrega 2** (10.21) queda lista para Codex, en un solo bloque de git.
**H1:** la cabecera de la oficina se reparte o se pliega según el ancho y la letra (`Wrap` con
`spaceBetween`; Buscar y la nube ancladas a la derecha); probado en 600 dp exactos con 1.0, 1.45 y
2.0, y en 360 y 1920, sin desbordamiento. **H2:** `LoadingCell` recibe `recienMovida` y el plano
se la enciende por el contenedor (`C:`) o por la reserva con su `assignedContainer`; además el
proveedor descartaba los vacíos asignados porque su celda viene en el `target` (`R:…`) y no en
`payload['position']` (`_posicionDe`); la prueba va de la bitácora en memoria de T-75 a la celda
sin inyectar `recienMovidoProvider`, con un lleno y una reserva, 1480/1500 ms, a 360, 600 y 1920, y
quieta con reducción de movimiento. **H3:** `AnuncioDelMovimiento`, una región en vivo sin dibujo
con el mismo texto que la fila de «En vivo» (rol, contenedor, celda, «ahora»), solo donde no hay
panel. **H4:** a 360 × 640 con barra de estado la cabecera (controles 77 + silueta 173) se comía
los 234 dp del área; ahora, con menos de 560 dp útiles, la silueta va compacta (90 dp), los
controles del plano bajan a la tira del pie (leyenda o barra de la operación, con «Acciones» solo
icono y en Carga el OR), el resumen encima del pie y los pesos por pila debajo de la bodega: la
primera fila queda en 422–474 de un área que termina en 486 (previo) y 338–390 de 160–403
(Descarga); Carga queda a un gesto (14 dp). **Además:** el riel va en `CustomScrollView` +
`SliverFillRemaining` con su ancho medido con la fuente (sin `IntrinsicHeight`), y el chip del zoom
vive en la línea de los controles con un menú anclado (`planZoomProvider`; el zoom ya no se
reinicia por bahía). **Cifras:** suite 1260 (piso 1242 + 18 en
`test/t114_fase3_entrega2_correccion_test.dart`), `analyze` 0, auditoría 17/248/20 (solo se va el
`IntrinsicHeight`; ningún hallazgo nuevo en lo tocado), censos 1932 visibles / 0 inglés, M3
250/7/3, 217 mensajes. **RNF-002 Android**, cinco corridas con el mismo instrumento y el banco
recompilado: 4.91–4.98 s la primera (tras instalar y `pm clear`) y 2.85–3.20 s las otras cuatro, tres
pasos, y los cuadros finales muestran la primera fila de celdas (evidencia en
`docs/rediseno/fase3/entrega2/correccion/`). **Dos avisos:** el primer borrador de las pruebas
sobrescribió `test/t114_fase3_correccion_test.dart` (la de 10.15) y se restauró desde `HEAD` byte a
byte; y `DESIGN.md` 8, 9.2, 13.3, 13.6 y 13.8 anotan las reglas nuevas. Me detengo: ALTO: Codex
acepta la corrección.

## Fase 3 · Paquete de íconos e ilustraciones (10.19): Parte B y Parte C (23-oct-2026)

Carlos cerró la entrega 2 con la excepción de Carga a 360 × 640 (10.22) y dio luz verde para
Flutter. Las dos partes van juntas, en un solo bloque de git: la **Parte B** (la base del paquete:
la fuente, las constantes, el catálogo, las ilustraciones como datos y `BsIlustracion`) se escribió
con Codex todavía en la aceptación, sin un solo comando de Flutter, y se probó al recibir la luz
verde; la **Parte C** (los íconos del dominio en las pantallas, las insignias de 12 px y las seis
ilustraciones en sus estados vacíos) siguió sin detenerse. Codex acepta el paquete al final.

### 5.1 Resultado en tres líneas

- El paquete de Nube (v2, 84 archivos con su SHA-256 más el LEEME) está en el repositorio en sus
  tres carpetas, comprobado archivo por archivo, y la fuente `BayStreamIconos` (35 glifos,
  U+E000 a U+E022) es la única línea nueva de `pubspec.yaml`; `pubspec.lock` no cambia y no hay
  dependencia nueva.
- Los 28 íconos con sitio y las 4 insignias reemplazan a Material donde la tabla del LEEME lo
  pide, con las colisiones resueltas como fijó Carlos; las seis ilustraciones se pintan con
  `CustomPainter` desde datos const, con los colores resueltos por nombre con los tokens del
  tema, y van en el inicio y en los cinco estados vacíos.
- Suite 1290 (piso 1242; 1260 tras la corrección + 30 del paquete), `analyze` 0, auditoría
  17/248/20 sin hallazgos en lo nuevo, censos 1940 visibles / 0 inglés, M3 250/7/3, 217
  mensajes. Las capturas de Android muestran los glifos y encontraron una regla que faltaba: la
  ilustración cede ante la letra grande. ALTO: Codex acepta el paquete.

### 5.2 Parte B: la base del paquete

**El paquete, comprobado.** `C:/Proyectos/baystream-iconos-paquete-v2.zip` trae 85 archivos: el
LEEME y los 84 de su tabla de SHA-256. Se calculó la huella de cada archivo del zip, se contrastó
con la tabla (84 de 84 coinciden) y se copiaron a sus rutas del repositorio:
`assets/fonts/bs_iconos/BayStreamIconos.ttf` (1), `design/iconos/` (56: LEEME, `codigos.json`,
31 SVG, 4 SVG de insignias, 13 fuentes `.py`, las vistas previas y la comprobación de Skia) y
`design/ilustraciones/` (28: 6 JSON, 12 SVG, 9 fuentes y la vista previa). Antes del bloque de git
se volvió a correr la comprobación sobre el árbol: 85 de 85 `OK`, sin `__pycache__`, `.pyc` ni
otros restos (`docs/rediseno/fase3/paquete/sha256-paquete-v2.txt` es la lista; se repite con
`sha256sum -c` desde la raíz).

**La fuente.** `pubspec.yaml` declara la familia `BayStreamIconos` junto a las Plex, con un
comentario de tres líneas que dice de dónde viene; es la única línea nueva. La fuente tiene em
1024, ascendente 1024, descendente 0 y avance 1024: cada glifo ocupa el cuadrado del em, como
Material Icons, así que `Icon(BsIconos.x, size: 24)` mide lo mismo que un ícono de Material.

**Las constantes.** `lib/core/design/bs_iconos.dart` es el bloque del LEEME tal cual (los 31
íconos y las 4 insignias, `familia = 'BayStreamIconos'`), con `library;` y una nota de que los
códigos no se tocan a mano: vienen de `design/iconos/codigos.json`.
`lib/core/design/bs_iconos_catalogo.dart` los recorre por su nombre del paquete
(`BsIconosCatalogo.iconos`, `insignias`, `todos`, `rejillaDe`) para las pruebas, el censo y las
vistas previas, sin que ninguna pantalla pase por ahí.

**Las ilustraciones como datos.** La app no declara los JSON como assets ni suma `flutter_svg`:
`tool/bs_ilustraciones_generar.py` lee `design/ilustraciones/*.json` y escribe
`lib/core/design/bs_ilustraciones.dart`, seis constantes `BsDatosDeIlustracion` (`inicio`,
`vacioRecientes`, `vacioBusqueda`, `sinConexion`, `descargaCompleta`, `sinAlertas`; 115 formas)
con el lienzo, la descripción del LEEME y, por forma, el grupo, la ruta, el relleno, el trazo, el
grosor y el punteado. Copia solo las rutas (M, L, C y Z absolutos) y los **nombres** de color (uno,
o uno por tema); los hex del bloque `paleta` no se copian. `--verificar` compara el `.dart` con
los JSON y es lo que corre la prueba.

**`BsIlustracion`** (`lib/core/design/componentes/bs_ilustracion.dart`): `colorDeIlustracion`
resuelve cada nombre con los tokens (`fondo`/`papel` → papel, `hoja`/`panel` → hoja,
`panel_alto` → hoja alta, `tinta`, `tinta_suave`, `linea`, `marca` → la marca como superficie,
`frase` → sobre la marca suave, `bodega` → acero, `grua` → el relleno de grúa, `hecho` → el
contorno del rol, `cubierta` → el papel de día y el relleno de «por bajar en cubierta» de noche;
otro nombre es `ArgumentError`); `rutaDeIlustracion` lee la ruta con un `Path` (M, L, C, Z;
cualquier otro comando es `FormatException`); `rutaPunteada` reparte el trazo con `PathMetrics`
como `stroke-dasharray`. El widget es `Semantics(label, image)` → `SizedBox(width)` →
`AspectRatio` → `RepaintBoundary` → `CustomPaint`; el pintor escala uniforme, guarda las rutas ya
leídas y pinta con puntas y uniones redondas. Dos decisiones que el LEEME dejaba abiertas: `marca`
es la marca como superficie en los dos temas (no el azul de selección de la noche), y `cubierta` es
el blanco del ícono, que de noche es el relleno de «por bajar en cubierta».

**Vistas previas.** `lib/core/design/vistas_previas_iconos.dart`: los 31 íconos a 24 en claro y
en oscuro, las 4 insignias a 12 y las 6 ilustraciones en los dos temas (`@Preview`).

### 5.3 Parte C: los íconos del dominio en las pantallas

La tabla de `DESIGN.md` 13.11 dice dónde va cada uno; aquí, lo que cambió y las colisiones:

- **Contenedor.** `iconoDeContenedor(ContainerUnit)` (en
  `widgets/iconos_del_dominio.dart`) fija la regla: peligrosa manda, luego refrigerado, fuera de
  medida, vacío, y si no, el tipo ISO (`refrigerado`, `tanque`, `plataforma`, `techoAbierto`) o
  el tamaño (`contenedor20`, `contenedor40`, `contenedor45` por `sizeInFeet`). La usan la
  tarjeta de la Lista, el resultado de la búsqueda, el detalle, los chips de carga especial, las
  tarjetas de Estadísticas, «Asignar vacío» y «Vacío» en la leyenda. `inventory_2` sigue para el
  total y para «Lleno», y `check_box` para «Llenos».
- **Peligrosa.** `peligrosa` en la insignia, los chips IMO / IMDG, el detalle y «Carga especial»;
  el aviso genérico sigue en `warning_amber`.
- **Buque y bahía.** `buque` donde la celda y la marca de descarga dicen «Paso» / sigue a bordo
  (`BsCelda` y `dischargeMarkIcon`), en los recientes, «Perfiles guardados», el resumen del viaje
  y «Perfil longitudinal»; `bahia` en el destino «Plano» (en reposo y activo), «Posición»,
  «Bahías», «Contenedores por bahía», «Ocupación» e «Ir a».
- **Descarga y carga.** `descarga` («Baja») y `carga` («Sube») en los segmentos de la banda del
  muelle, las marcas de la celda, la comparación y el panel de la carga; en la secuencia de
  descarga «Re‑estiba: sale» es `descarga` y «vuelve» es `carga`; `tapaEscotilla` en los pasos
  de tapas, en «Tapas en la operación» y en «Editar tapas por bahía». El hecho sigue en
  `check_circle`.
- **Re‑estiba y pedir cambio.** `reestiba` en la marca de la celda y en la de descarga;
  `pedirCambio` en «Pedir cambio», «Bandeja de cambios», «Solicitudes de cambio» y la solicitud
  pendiente sobre la celda (antes `schedule`).
- **Peso.** `pesoPila` en la línea del peso por pila del panel de carga y `vgm` en «Peso (VGM)»
  de la tarjeta; `scale` sigue para el peso genérico.
- **Archivos.** `baplie` en «Seleccionar archivo» y «Cargar archivo BAPLIE», `compararBaplie`,
  `baplieSalida` y `listadoAgencia` («Listado de la agencia», «Elegir listado»); el CSV sigue en
  `table_view`, como pidió Carlos.
- **Nube.** `alDia` y `soloAqui` en el chip de estado y en la barra superior; los demás estados
  (`cloud_sync`, `cloud_upload`, `lock_clock`, `block`, `warning_amber`) y «Nube y cuenta» sin
  cuenta (`cloud`) siguen en Material.
- **Los genéricos que iban en contorno pasan a relleno** junto a los íconos nuevos (hecho,
  revisar, alertas, nube, tabla, avance, paleta, ocupado por 40 pies, lista, estadísticas),
  porque la familia es sólida y a 16 px un contorno al lado de un macizo se lee más débil. La
  barra inferior y el riel llevan el mismo glifo relleno en reposo y activo: la selección la dice
  el indicador de Material 3. Buscar, cerrar, micrófono, parámetros, historia, descargar y más
  siguen siendo Material.
- **Las insignias.** `BsCelda` dibuja `insigniaPeligrosa`, `insigniaRefrigerado` e
  `insigniaFueraDeMedida` a 12 px (`tamanoInsignia`) en la esquina de la celda.
- **Sin sitio todavía** (la tabla los da como «ninguno hoy»): `limiteApilamiento`,
  `segregacion`, `orden`, `grua`, `muelle`, `escala` e `insigniaVacio` quedan en la fuente sin
  usarse; la prueba comprueba que ninguno se cuele y que los 28 con sitio están todos en uso.

Dos cosas que se arreglaron de paso porque la prueba de pautas las encontró al poner la
ilustración: la pista de la búsqueda iba con `onSurfaceVariant` al 70 % (3.29:1) y ahora va con
el color entero; y «Viajes recientes» vacío desbordaba 24 px con el dibujo, así que su estado
vacío va en un `SingleChildScrollView`.

### 5.4 Las ilustraciones en sus pantallas, y la regla del alto

- `inicio` sobre «Abre un plano de estiba» (`EmptyStateWidget`, hasta 480 de ancho);
  `vacio_recientes` en «Todavía no hay viajes guardados» del inicio (320); `vacio_busqueda` en
  «Sin resultados» de la búsqueda (240); `sin_conexion` en «Nube y cuenta» cuando la app trabaja
  solo en este equipo (320); `descarga_completa` en el avance, solo cuando la escala tiene
  llegada, algo se bajó y no queda nada por bajar, con la frase «Descarga completa en {puerto}.»
  (320); `sin_alertas` en Alertas de estiba cuando hay al menos un resultado conforme y ninguno
  incumple, nunca en previo (240). Cada una lleva su descripción como etiqueta accesible de
  imagen, y las pantallas conservan contraste y objetivos táctiles (`meetsGuideline`).
- **La regla del alto (13.11, regla 4), encontrada mirando la pantalla.** La primera ronda de
  capturas en el emulador (360 × 640, API 26) pasó con la letra a 1.0 y 1.45 y se detuvo en 2.0:
  «No apareció: Seleccionar archivo». El volcado de accesibilidad lo explica: con la letra a 2.0
  la ilustración ocupaba 288–903 px (205 dp), el título 951–1281 y los dos párrafos llegaban al
  borde de la ventana (1776 px); el botón ni siquiera estaba en el árbol. Antes del paquete, en la
  misma corrida de la entrega 2, el botón se veía sin desplazar. Así que el dibujo acompaña a la
  frase y cede ante la letra, no al revés: `BsIlustracion` mide `anchoQueCabe`, que da a cada
  ilustración como máximo **tres décimas del alto de la ventana divididas por la escala de la
  letra** (`parteDelAlto = 0.3`) y, si con eso no llega a 120 dp de alto (`altoMinimo`), no la
  pinta. En la ventana del emulador (360 × 592 bajo la barra de estado) el inicio lleva el dibujo
  a 178 dp con 1.0 y a 123 dp con 1.45, y con 2.0 va sin dibujo; en 1920 × 1080 cabe entero a 480
  × 300. `EmptyStateWidget` y el estado vacío de los recientes consultan la misma función para no
  dejar la separación cuando no hay dibujo. Lo prueban `test/t114_ilustraciones_test.dart` (la
  pieza a 360 × 640 con 1.0, 1.45 y 2.0, y en el escritorio) y `test/t114_paquete_test.dart` (el
  inicio completo con las fuentes reales: el botón queda dentro de la ventana en los tres
  tamaños de letra, con y sin barra de estado).

### 5.5 Pruebas

Treinta pruebas nuevas en tres archivos; la suite pasa de 1260 a **1290** (piso 1242), sin
omitidas:

- `test/t114_iconos_test.dart` (7): `pubspec.yaml` declara `BayStreamIconos` con su único asset y
  nada más; el TTF es el del LEEME (SHA-256); `codigos.json` y `BsIconos` coinciden (35 glifos de
  U+E000 a U+E022); el `cmap` de la fuente (formatos 4 y 12, leído del TTF) trae un glifo para
  cada código y ninguno más en el área privada; con la fuente cargada cada constante pinta su
  glifo y los 35 son distintos (al menos 8 px cambian entre cualquier par a 24 px); y una muestra
  de 13 glifos pintada como texto a 16 y a 24 px coincide con su SVG rasterizado con `Canvas`
  (tolerancia de borde: hasta un 12 % de píxeles cambian de estado y la diferencia media de
  alfa queda bajo 16). Medido: a 16 px cambian de estado entre 0 (`descarga`, `carga`) y 8 de 256 píxeles (`peligrosa`, `insignia_peligrosa`), con una diferencia media de alfa de 0.9 a 10.8; a 24 px, entre 0 (`contenedor_20`, `contenedor_40`, `vacio`) y 63 de 576 (`buque`, 10.9 %), con una diferencia media de 0.7 a 6.6.
- `test/t114_ilustraciones_test.dart` (10): las seis están con su descripción; los datos
  coinciden con los JSON forma por forma (115); cada ruta se lee con M, L, C y Z y cae dentro de
  su lienzo (y `Q`, `l` o `A` se rechazan); el punteado reparte la ruta como `stroke-dasharray`;
  los nombres de color dan el mismo hex que el bloque `paleta` del paquete en claro y en oscuro;
  los trazos quedan a 3:1 o más sobre el fondo (`BsRol.contrasteEntre`); las seis pintan en los
  dos temas dentro de un `RepaintBoundary` con su etiqueta, y el color dominante es un token;
  `conFondo` pinta el papel; y la regla del alto.
- `test/t114_paquete_test.dart` (13): el censo de `lib/` (ninguno de los íconos de Material que la
  tabla reemplaza sigue en uso fuera de los congelados; `table_view` solo en el CSV; los
  contornos que se van no quedan salvo donde 13.11 los deja; los 28 con sitio se usan y los 7 sin
  sitio no); la regla del contenedor; las marcas, la nube, la banda y el destino; las insignias
  a 12 px y «Paso» con `buque`; y las seis ilustraciones en sus pantallas con `meetsGuideline`
  (inicio, recientes vacíos, búsqueda sin resultados, Nube y cuenta en local, descarga completa
  solo cuando corresponde, alertas solo con resultados conformes y sin incumplimientos), más el
  inicio en el teléfono bajo con la letra grande.
- Cinco pruebas existentes se ajustaron a los glifos nuevos: `t114_componentes_test`
  (`descarga`, `reestiba`, `insigniaPeligrosa`), `t114_piezas_test` (`check_circle`),
  `t96_comparison_page_test` (`descarga` / `carga`), `t114_fuentes_test` (diez assets de fuente)
  y `t114_celda_contraste_test` (un glifo de `BayStreamIconos` es ícono, 3:1, no texto).

### 5.6 Validaciones ejecutadas

| Qué | Resultado |
|---|---|
| `flutter analyze --no-pub` | 0 incidencias, sin `// ignore:` |
| `flutter test --no-pub` | **1290** pruebas, todas en verde, ninguna omitida (1260 + 30) |
| Auditoría flutter-ui (`--all`) | 17 críticos / 248 avisos / 20 info: los mismos de la corrección; ningún hallazgo en los archivos nuevos ni en los tocados (`docs/rediseno/fase3/paquete/flutter-ui-audit.txt`) |
| Censos T-112 (`tool/t112_censos.py`) | 1940 visibles: 1809 español, 131 sin idioma, **0 en inglés**; accesibilidad 63 (las seis descripciones son etiquetas de imagen); M3 250 incluidos / 7 excluidos / 3 excepciones; 217 mensajes con causa y acción (`docs/rediseno/fase3/paquete/censos/`) |
| SHA-256 del paquete | 85 de 85 `OK` contra el zip, antes de copiar y antes del bloque de git; sin `__pycache__` |
| Capturas en el emulador | 31 capturas en `docs/rediseno/fase3/paquete/capturas/android/` (banco `r4` recompilado con el árbol final, emulador `t99_api26`, 360 × 640): el plano en Carga y en Descarga, con y sin la rejilla, la Lista, el Avance y «Más», con la letra a 1.0, 1.45 y 2.0 en claro y a 1.0 en oscuro (`tool/t114_capturas_android_plano.py --reiniciar-datos`), más el inicio a 1.0, 1.45 y 2.0 a mano. Se ven `descarga` y `carga` en los segmentos, `buque` en «Paso», `bahia` en «Plano», `soloAqui` en el chip, `tapaEscotilla` y `compararBaplie` en «Más», la grúa del inicio a 178 dp (1.0) y a 123 dp (1.45), y el inicio sin dibujo a 2.0 con «Seleccionar archivo» a la vista. La primera ronda, antes de la regla del alto, se había detenido en 2.0 |

Del censo: `tool/t112_censos.py` suma las decisiones de los archivos nuevos (el nombre de la
fuente, los nombres de color y de grupo del archivo generado, los mensajes de `ArgumentError` /
`FormatException` como excepción interna) y toma la descripción de cada dibujo por su rótulo,
no por su línea, porque el archivo lo regenera el generador. Los ocho visibles de más respecto a
la corrección (1932 → 1940) son las seis descripciones, el texto «Descarga completa en …» y su
etiqueta.

### 5.7 Archivos del paquete

- **Nuevos, por carpeta:** `assets/fonts/bs_iconos/` (1), `design/iconos/` (56),
  `design/ilustraciones/` (28).
- **Nuevos en `lib/`:** `core/design/bs_iconos.dart`, `core/design/bs_iconos_catalogo.dart`,
  `core/design/bs_ilustraciones.dart` (generado), `core/design/componentes/bs_ilustracion.dart`,
  `core/design/vistas_previas_iconos.dart`,
  `features/vessel/presentation/widgets/iconos_del_dominio.dart`.
- **Modificados en `lib/`:** `core/design/design.dart`, `componentes/bs_banda_muelle.dart`,
  `componentes/bs_celda.dart`, `vistas_previas.dart`; las páginas `change_requests`, `cloud`,
  `departure_baplie`, `discharge_sequence`, `export_list_import`, `operation_progress`,
  `recent_voyages`, `stowage_alerts`, `vessel_geometry`, `vessel_overview`,
  `voyage_comparison`; los widgets `bay_plan_view`, `container_search_delegate`,
  `containers_list_view`, `detalle_contenedor`, `discharge_controls`, `empty_state_widget`,
  `inicio_view`, `loading_controls`, `loading_plan_controls`, `navegacion_del_viaje`,
  `plan_drag_confirmation`, `sync_status_chip`, `vessel_profile_view`, `voyage_stats_view`,
  `voyage_summary_card`.
- **`pubspec.yaml`:** la familia `BayStreamIconos`. `pubspec.lock` no cambia.
- **Pruebas:** nuevas `t114_iconos_test.dart`, `t114_ilustraciones_test.dart`,
  `t114_paquete_test.dart`; ajustadas `t114_celda_contraste_test.dart`,
  `t114_componentes_test.dart`, `t114_fuentes_test.dart`, `t114_piezas_test.dart`,
  `t96_comparison_page_test.dart`.
- **Herramientas:** `tool/bs_ilustraciones_generar.py` (nuevo), `tool/t112_censos.py`.
- **Documentos:** `DESIGN.md` (13.7, 13.9 y la sección nueva 13.11),
  `docs/rediseno/fase3/traspaso-entrega2.md`, esta sección, y la evidencia en
  `docs/rediseno/fase3/paquete/`.
- No cambian `domain/`, `data/`, `lib/main.dart`, las opciones de Firebase ni los congelados.

### 5.8 Lo que queda anotado y lo que Carlos decide

- La tolerancia de la comparación glifo–SVG es del 12 % de píxeles porque el rasterizado de la
  fuente (FreeType con hinting, en Skia) y el del `Path` difieren en el borde; Nube midió lo
  mismo en Chromium (10.4 %). Es una comparación de forma, no de píxel exacto.
- `marca` y `cubierta` se resolvieron como dice 5.2; si Carlos prefiere el azul de selección de
  noche para la marca de los dibujos, es una línea de `colorDeIlustracion`.
- `orden`, `grua`, `muelle`, `escala`, `limiteApilamiento`, `segregacion` e `insigniaVacio`
  quedan en la fuente sin sitio, como dice la tabla; darles uno es una decisión de pantalla.
- El emulador `t99_api26` sigue abierto con el banco `r4`; la letra volvió a 1.0 y el tema a
  «Seguir al sistema».

### 5.9 Horas

Unas 2 h 20 min en total, aproximadas por las horas de los archivos: cerca de 1 h la Parte B (el zip y sus huellas, la fuente, las constantes, el generador, `BsIlustracion` y sus pruebas, escritas sin Flutter mientras Codex aceptaba la corrección), unos 35 min la Parte C (33 archivos de pantalla, las pruebas y los ajustes que encontraron) y unos 45 min las validaciones, el censo con sus decisiones nuevas, el emulador, la regla del alto y este informe.

### Git para Carlos (Fase 3, paquete de íconos e ilustraciones)

Un solo bloque para la Parte B y la Parte C. Las tres carpetas nuevas del paquete van por carpeta,
con sus SHA-256 comprobados y sin `__pycache__`; el resto, un `git add` por ruta. Las capturas de
Android van por carpeta por ser solo archivos nuevos de evidencia (la regla de las 60 rutas).
`pubspec.lock`, `domain/`, `data/`, `lib/main.dart` y los congelados no cambian; los generados de
`windows/flutter/` figuran modificados solo por el fin de línea y no se agregan.

```
git add -- assets/fonts/bs_iconos
git add -- design/iconos
git add -- design/ilustraciones
git add -- pubspec.yaml
git add -- DESIGN.md
git add -- lib/core/design/bs_iconos.dart
git add -- lib/core/design/bs_iconos_catalogo.dart
git add -- lib/core/design/bs_ilustraciones.dart
git add -- lib/core/design/componentes/bs_ilustracion.dart
git add -- lib/core/design/vistas_previas_iconos.dart
git add -- lib/core/design/design.dart
git add -- lib/core/design/componentes/bs_banda_muelle.dart
git add -- lib/core/design/componentes/bs_celda.dart
git add -- lib/core/design/vistas_previas.dart
git add -- lib/features/vessel/presentation/widgets/iconos_del_dominio.dart
git add -- lib/features/vessel/presentation/pages/change_requests_page.dart
git add -- lib/features/vessel/presentation/pages/cloud_page.dart
git add -- lib/features/vessel/presentation/pages/departure_baplie_page.dart
git add -- lib/features/vessel/presentation/pages/discharge_sequence_page.dart
git add -- lib/features/vessel/presentation/pages/export_list_import_page.dart
git add -- lib/features/vessel/presentation/pages/operation_progress_page.dart
git add -- lib/features/vessel/presentation/pages/recent_voyages_page.dart
git add -- lib/features/vessel/presentation/pages/stowage_alerts_page.dart
git add -- lib/features/vessel/presentation/pages/vessel_geometry_page.dart
git add -- lib/features/vessel/presentation/pages/vessel_overview_page.dart
git add -- lib/features/vessel/presentation/pages/voyage_comparison_page.dart
git add -- lib/features/vessel/presentation/widgets/bay_plan_view.dart
git add -- lib/features/vessel/presentation/widgets/container_search_delegate.dart
git add -- lib/features/vessel/presentation/widgets/containers_list_view.dart
git add -- lib/features/vessel/presentation/widgets/detalle_contenedor.dart
git add -- lib/features/vessel/presentation/widgets/discharge_controls.dart
git add -- lib/features/vessel/presentation/widgets/empty_state_widget.dart
git add -- lib/features/vessel/presentation/widgets/inicio_view.dart
git add -- lib/features/vessel/presentation/widgets/loading_controls.dart
git add -- lib/features/vessel/presentation/widgets/loading_plan_controls.dart
git add -- lib/features/vessel/presentation/widgets/navegacion_del_viaje.dart
git add -- lib/features/vessel/presentation/widgets/plan_drag_confirmation.dart
git add -- lib/features/vessel/presentation/widgets/sync_status_chip.dart
git add -- lib/features/vessel/presentation/widgets/vessel_profile_view.dart
git add -- lib/features/vessel/presentation/widgets/voyage_stats_view.dart
git add -- lib/features/vessel/presentation/widgets/voyage_summary_card.dart
git add -- test/t114_iconos_test.dart
git add -- test/t114_ilustraciones_test.dart
git add -- test/t114_paquete_test.dart
git add -- test/t114_celda_contraste_test.dart
git add -- test/t114_componentes_test.dart
git add -- test/t114_fuentes_test.dart
git add -- test/t114_piezas_test.dart
git add -- test/t96_comparison_page_test.dart
git add -- tool/bs_ilustraciones_generar.py
git add -- tool/t112_censos.py
git add -- docs/rediseno/fase3/traspaso-entrega2.md
git add -- docs/rediseno/fase3/paquete/sha256-paquete-v2.txt
git add -- docs/rediseno/fase3/paquete/flutter-ui-audit.txt
git add -- docs/rediseno/fase3/paquete/censos/resumen.json
git add -- docs/rediseno/fase3/paquete/censos/tablas.md
git add -- docs/rediseno/fase3/paquete/capturas/android
git add -- docs/REDISENO-RESULTADOS.md
git commit -m "Sprint 4: paquete de iconos e ilustraciones (10.19), fuente BayStreamIconos, BsIlustracion con CustomPainter, iconos del dominio e insignias en las pantallas y las seis ilustraciones en sus estados vacios"
git push
```

### Tres líneas

- El paquete de Nube está en el repositorio comprobado archivo por archivo; la fuente es un asset
  y las ilustraciones, datos que la app pinta sola: ninguna dependencia nueva, `pubspec.lock`
  igual.
- Los íconos del dominio y las insignias están en todas sus pantallas con las colisiones que
  fijó Carlos, y las seis ilustraciones en sus estados, con una regla nueva: el dibujo cede ante
  la letra grande.
- Suite 1290 (piso 1242), `analyze` 0, auditoría sin hallazgos nuevos, censos 0 inglés, SHA-256
  85/85. ALTO: Codex acepta el paquete.

### Mensaje para Yov
Yov: el **paquete de íconos e ilustraciones (10.19)** queda integrado, Parte B y Parte C juntas en un solo bloque de git. **Parte B:** el zip v2 de Nube comprobado archivo por archivo (84 de 84 huellas de la tabla, 85 de 85 sobre el árbol antes del bloque, sin `__pycache__`) en `assets/fonts/bs_iconos/`, `design/iconos/` y `design/ilustraciones/`; `pubspec.yaml` solo suma la familia `BayStreamIconos` (`pubspec.lock` igual, ninguna dependencia); `BsIconos` textual del LEEME más un catálogo por nombre; las seis ilustraciones viajan como datos const que genera `tool/bs_ilustraciones_generar.py` desde los JSON y las pinta `BsIlustracion` (`CustomPainter` en `RepaintBoundary`, M/L/C/Z, puntas redondas, punteado, colores por nombre resueltos con los tokens: `marca` es la marca como superficie y `cubierta` el blanco del ícono). **Parte C:** la tabla del LEEME aplicada con las colisiones que fijó Carlos (`peligrosa` solo para la carga peligrosa y `warning_amber` para el aviso; `reestiba` y `pedirCambio`; «Paso» con `buque`; en la secuencia «sale» es `descarga` y «vuelve» es `carga`; `listadoAgencia` para el listado y `table_view` para el CSV; el contenedor por `iconoDeContenedor`: peligrosa > refrigerado > fuera de medida > vacío > tipo ISO > tamaño), las insignias a 12 px en la celda, los genéricos que iban en contorno pasan a relleno junto a los nuevos, y las ilustraciones en el inicio y en los cinco estados vacíos con `meetsGuideline`. **Una regla nueva, encontrada mirando la pantalla:** la primera ronda de capturas se detuvo con la letra a 2.0 porque el dibujo del inicio empujaba «Seleccionar archivo» fuera del árbol; ahora cada ilustración ocupa como máximo tres décimas del alto de la ventana entre la escala de la letra y bajo 120 dp no se pinta (`DESIGN.md` 13.11, regla 4): en el emulador el inicio lleva la grúa a 178 dp con 1.0, a 123 con 1.45 y va sin dibujo con 2.0, con el botón a la vista. **Cifras:** suite 1290 (piso 1242; 1260 + 30 en `t114_iconos_test`, `t114_ilustraciones_test` y `t114_paquete_test`, que censa `lib/` para que ningún concepto de la tabla vuelva a Material), `analyze` 0, auditoría 17/248/20 sin hallazgos en lo nuevo, censos 1940 visibles / 0 inglés (los ocho de más son las seis descripciones, etiquetas de imagen, y «Descarga completa en …»), M3 250/7/3, 217 mensajes; 31 capturas de Android en `docs/rediseno/fase3/paquete/capturas/android/`. **Dos arreglos de paso** que la prueba de pautas encontró: la pista de la búsqueda (3.29:1 → color entero) y el desbordamiento de «Viajes recientes» vacío. `DESIGN.md` 13.7, 13.9 y la sección nueva 13.11 anotan dónde va cada ícono y las reglas de uso. Me detengo: ALTO: Codex acepta el paquete.

## Fase 3 · Paquete · Corrección tras la aceptación de Codex (23-oct-2026)

Codex no aceptó el paquete (`docs/rediseno/fase3/paquete/aceptacion-codex.md`; decisión 10.23) por un
hallazgo y una observación. **H1:** en la búsqueda, `_buildLeadingIcon` dibujaba el glifo de la condición
del contenedor sin etiqueta ni descripción emergente, así que la carga peligrosa, el refrigerado, el fuera
de medida y el vacío sonaban igual en el lector de pantalla («TSTU0000011 / 22G1» en los cuatro casos).
**O1:** la tarjeta de la Lista elegía su ícono con `iconoDeTipo` en vez de la regla única que prometen
`iconos_del_dominio.dart` y `DESIGN.md` 13.11, y dibujaba el 20 pies en los cuatro casos. Esta sección
corrige las dos cosas en un bloque de git aparte, como fija 10.23, y, a pedido de Carlos antes de subirla,
la insignia de la celda del plano, que la revisión de 6.4 encontró sin nombre. La salvedad de los PNG del
verificador quedó resuelta en esa misma decisión y no se toca.

### 6.1 Resultado en tres líneas

- La búsqueda, la Lista y el detalle dicen la condición del contenedor al lector de pantalla con la
  etiqueta del glifo («Carga peligrosa», «Refrigerado», «Fuera de medida», «Vacío», el tipo ISO o el
  tamaño) y la muestran como descripción emergente. Los cuatro casos de Codex tienen ahora cuatro
  etiquetas distintas, leídas desde el árbol de semántica.
- La regla del ícono vive en un solo sitio, `CondicionDelContenedor`, que da el glifo y su nombre. La
  tarjeta de la Lista la aplica, y una prueba comprueba que Lista, búsqueda y detalle dibujan el mismo
  glifo con el mismo nombre para once contenedores.
- Suite 1297 (1290 + 7), `analyze` 0, auditoría 17/248/20 sin cambios, censo 1950 visibles y 0 inglés.
  La revisión de los demás íconos del dominio encontró uno más sin nombre, la insignia de la celda del
  plano; Carlos pidió corregirlo aquí, y la celda nombra ahora su condición en las tres vistas de
  «Colorear por».

### 6.2 H1 · La búsqueda dice la condición

**Qué pasaba.** El resultado de la búsqueda es un `ListTile` con `onTap`: Flutter funde en un solo nodo
de semántica las etiquetas de sus hijos (título, subtítulo, cola). El ícono principal iba sin
`semanticLabel` y sin `Tooltip`, así que no aportaba nada a ese nodo. Codex lo reprodujo con cuatro
contenedores sintéticos que solo difieren en su condición: cuatro glifos distintos, una sola etiqueta.

**Qué se hizo.** El ícono principal del contenedor es ahora una pieza, `IconoDelContenedor`
(`lib/features/vessel/presentation/widgets/iconos_del_dominio.dart`): el glifo de la condición con el
nombre de esa condición como `semanticLabel` y como `Tooltip`. Un parámetro `marco` envuelve al glifo con
lo que cada pantalla le pone alrededor (el círculo de color del resultado, el recuadro de la tarjeta),
para que la descripción emergente cubra el marco entero y no solo los 20 px del glifo. La búsqueda usa
esa pieza en `_buildLeadingIcon`; los colores del círculo (T-112) no cambian.

**Lo que dice cada condición.** La prioridad es la de 13.11 y los nombres son los de la app:

| Condición | Glifo | Nombre (etiqueta y descripción emergente) |
|---|---|---|
| Carga peligrosa (IMDG) | `peligrosa` (U+E005) | «Carga peligrosa» |
| Refrigerado, por marca o por tipo ISO | `refrigerado` (U+E004) | «Refrigerado» |
| Fuera de medida (OOG) | `fueraDeMedida` (U+E006) | «Fuera de medida» |
| Vacío | `vacio` (U+E003) | «Vacío» |
| Tanque (ISO T) | `tanque` (U+E007) | «Tanque» |
| Plataforma (ISO P) | `plataforma` (U+E008) | «Plataforma» |
| Techo abierto (ISO U) | `techoAbierto` (U+E009) | «Techo abierto» |
| 20, 40 o 45 pies; sin tamaño, 40 | `contenedor20`, `contenedor40`, `contenedor45` | «Contenedor de 20 pies», «… de 40 pies», «… de 45 pies» |

**La descripción emergente va fuera de la semántica** (`excludeFromSemantics: true`). La etiqueta del
glifo y la descripción llevan el mismo texto; si las dos entraran en el árbol, iOS añadiría la
descripción a la etiqueta y el lector diría el nombre dos veces. La descripción queda para el ratón y la
pulsación larga; la etiqueta, para el lector. La prueba comprueba las dos cosas por separado: la
etiqueta en el nodo del resultado y la descripción en el `Tooltip` con su texto.

**Después.** El nodo del resultado, con el mismo contenedor de Codex (`TSTU0000011`, `22G1`):

```text
label: "Carga peligrosa / TSTU0000011 / 22G1"      (antes: "TSTU0000011 / 22G1")
label: "Refrigerado / TSTU0000011 / 22G1"
label: "Fuera de medida / TSTU0000011 / 22G1"
label: "Vacío / TSTU0000011 / 22G1"
```

El árbol completo de los cuatro casos, más un 22G1 corriente, en la búsqueda, en la tarjeta de la Lista
y en el detalle, y las etiquetas de las cinco celdas del plano en las tres vistas (6.4), están en
`docs/rediseno/fase3/paquete/correccion/semantica-busqueda.txt` (lo escriben dos pruebas de evidencia que
no forman parte de la suite, `build/t114-paquete-correccion/semantica_test.dart`, fuera de Git por
`/build/`).

### 6.3 O1 · La regla única, en la Lista, en la búsqueda y en el detalle

- **Una sola regla.** `condicionDelContenedor` devuelve la `CondicionDelContenedor` (glifo y nombre) con
  la prioridad de 13.11: peligrosa, refrigerado, fuera de medida, vacío, tipo ISO, tamaño. Las funciones
  de siempre, `iconoDeContenedor`, `iconoDeTipo` e `iconoDeTamano`, se derivan de ella y conservan su
  firma: las pruebas del paquete que las usan no cambian. Así el nombre no puede separarse del glifo.
- **La Lista.** La tarjeta dibuja su ícono principal con `IconoDelContenedor`, no con `iconoDeTipo`. El
  color del ícono sigue ahora a la condición que manda, con los mismos colores que los chips de la propia
  tarjeta (error para IMDG, primario para refrigerado, terciario para OOG, secundario para vacío) y, si
  no hay condición, el color del tipo de antes. Los chips y los textos de carga especial siguen ahí.
- **El detalle.** El detalle no tenía ícono principal: solo las señales de carga especial (`_Senal`), con
  su texto, para peligrosa, refrigerado y fuera de medida. Para un vacío, un tanque o un 40 pies no
  dibujaba nada, y la tabla de 13.11 lo nombra como uno de los sitios del ícono del contenedor. Ahora el
  título de la hoja lleva el ícono delante del número, en tinta suave, con el mismo nombre. Las señales
  siguen igual.
- **`DESIGN.md` 13.11.** La fila «Contenedor» de la tabla nombra a `condicionDelContenedor`, y la regla 3
  dice cómo se etiqueta el ícono principal y cuándo un ícono no necesita etiqueta propia.

### 6.4 Los demás íconos del dominio, revisados

Se revisaron los 90 usos de `BsIconos.` en `lib/` fuera de `bs_iconos.dart`, el catálogo y las vistas
previas, mirando qué hay al lado de cada glifo y qué llega al árbol de semántica.

| Cómo se dibuja | Dónde | Qué lo etiqueta |
|---|---|---|
| Botón con rótulo (`FilledButton.icon`, `TextButton.icon`, `OutlinedButton.icon`, `ButtonSegment`, `Tab`) | «Pedir cambio» y «Bandeja / Solicitudes de cambio», «Generar / Guardar BAPLIE de salida», «Comparar con la llegada» y «Comparar con otro BAPLIE…», «Elegir listado» y «Listado de la agencia», «Ir a …», «Editar tapas por bahía», «Seleccionar archivo», «Asignar vacío», «Ocupación», los segmentos Descarga / Carga de la banda del muelle, las pestañas de la comparación | el rótulo del botón |
| `IconButton` con `tooltip` | «Tapas en la operación» (avance y plano), la nube en la barra y en los controles («Nube y cuenta · estado») | la descripción emergente |
| Ícono junto a su texto, en la misma fila o entrada | las entradas de «Más», el menú de los controles de carga, las líneas de la comprobación de carga (descarga, peso por pila), la tarjeta de la Lista (posición, VGM, los chips IMO, refrigerado, IMDG y OOG), las señales y la sección de descarga del detalle («En GTSTC: …»), los pasos de la secuencia, los títulos y las tarjetas de Estadísticas, la leyenda («Vacío»), el chip de la nube, «Bahías» en el resumen del viaje, el destino «Plano» de la navegación | el texto de al lado dice lo mismo |
| Con etiqueta propia | las filas de la comparación (`semanticLabel`), la solicitud pendiente sobre la celda (`Semantics(label: 'Solicitud pendiente en …')`), la marca de la celda (`dischargeMarkText` en la etiqueta de `BsCelda`) y, desde hoy, el ícono principal del contenedor | su `semanticLabel` o su `Semantics` |
| Decorativo junto al nombre que ya se lee | `buque` delante del nombre del buque en el resumen del viaje y en los recientes (inicio y «Viajes recientes») | no comunica nada que el texto no diga |
| **Comunicaba algo y no estaba en la etiqueta** | **la insignia de la celda del plano** | **nada; corregido en esta misma entrega, a pedido de Carlos: la etiqueta de la celda nombra la condición** |

**El hallazgo, corregido.** `BsCelda` excluye su contenido de la semántica y expone solo `etiqueta`; en
`bay_plan_view.dart` esa etiqueta se armaba con el número, la posición, la marca de descarga, el orden y
«de paso», pero no con la insignia. En el plano, la carga peligrosa, el refrigerado y el fuera de medida
se veían en la esquina de la celda y no se oían. (Las celdas que Codex revisó traían la insignia en la
etiqueta porque eran las de las pruebas de `BsCelda`, que la escriben a mano.) Carlos pidió corregirlo
dentro de esta parte, antes de subirla: la etiqueta lleva ahora, después de la marca de descarga, el
nombre de la condición cuando la celda la señala (`CondicionDelContenedor.enLaCelda`: las tres insignias
y el vacío), con los mismos nombres que el ícono principal y en las tres vistas de «Colorear por».
«Vacío» entra también aunque solo la vista Tipo de vacío lo colorea: es lo que el contenedor es, y lo
que el ícono principal diría. El tipo y el tamaño no se señalan en la celda y no van en su etiqueta. Las
cinco celdas de la prueba, en la bahía 003 del viaje sintético, se leen así en las tres vistas:

```text
TSTU 000001 1, 003-01-82, Carga peligrosa
TSTU 000002 2, 003-02-82, Refrigerado
TSTU 000003 3, 003-03-82, Fuera de medida
TSTU 000004 4, 003-04-82, Vacío
TSTU 000005 5, 003-05-82
```

### 6.5 Pruebas

`test/t114_paquete_correccion_test.dart`, 7 pruebas nuevas. Suite **1297** (1290 + 7), sin omitidas.

| Prueba | Qué comprueba |
|---|---|
| H1 · los cuatro casos, leídos desde el árbol de semántica | con el mismo número y tipo ISO, el nodo del resultado contiene «Carga peligrosa», «Refrigerado», «Fuera de medida» o «Vacío» además del número y el ISO; el glifo es el de `iconoDeContenedor` y lleva ese `semanticLabel`; hay un `Tooltip` con el mismo texto, fuera de la semántica; las cuatro etiquetas son distintas |
| H1 · sin carga especial, dice el tipo ISO o el tamaño | 22G1, 42G1, L5G1, 22T1, 42P1 y 22U1 dicen «Contenedor de 20 / 40 / 45 pies», «Tanque», «Plataforma» y «Techo abierto» |
| H1 · la búsqueda y la Lista siguen las pautas con los cuatro casos | `meetsGuideline` de contraste, objetivos táctiles y objetivos con etiqueta, con los cuatro resultados y las cuatro tarjetas |
| O1 · la condición da el glifo y el nombre, con la prioridad de 13.11 | la prioridad con condiciones combinadas (una peligrosa, refrigerada, fuera de medida y vacía dice «Carga peligrosa»; un tanque vacío dice «Vacío»), los diez nombres, glifos del paquete y distintos entre sí, y que `iconoDeContenedor`, `iconoDeTipo` e `iconoDeTamano` dan el glifo de la misma condición |
| O1 · la Lista, la búsqueda y el detalle dibujan el mismo glifo con el mismo nombre | once contenedores (los cuatro casos y siete corrientes): el ícono principal de las tres pantallas tiene el mismo código, la familia `BayStreamIconos` y el mismo `semanticLabel` |
| O1 · la tarjeta de la Lista y el detalle también dicen la condición | el nodo de la tarjeta contiene la condición y el número; en el detalle hay un nodo con la condición y el `Tooltip` lleva su texto |
| La celda del plano dice su insignia · en Destino, Tipo de vacío y Estado | el plano real (`VesselOverviewPage`) con cinco celdas en la bahía 003, los cuatro casos y una corriente: en las tres vistas de «Colorear por», la etiqueta de `BsCelda` leída del árbol de semántica contiene el número y el nombre de su condición, y solo el suyo; la corriente no contiene ninguno; la insignia dibujada es la que el nombre dice; `enLaCelda` marca exactamente las cuatro |

### 6.6 Validaciones ejecutadas

| Qué | Resultado |
|---|---|
| `flutter analyze --no-pub` | 0 incidencias |
| `flutter test --no-pub` | **1297** pruebas en verde, ninguna omitida (`build/t114-paquete-correccion/flutter-test.txt`) |
| `flutter test build/t114-paquete-correccion/semantica_test.dart` | 2 pruebas de evidencia; escriben `semantica-busqueda.txt` (la búsqueda, la Lista y el detalle; las celdas del plano en las tres vistas) |
| Auditoría `flutter-ui` (`--all`) | **17 / 248 / 20**, los mismos del paquete; el diff con la auditoría del paquete sin números de línea es vacío (solo se corren las líneas de `containers_list_view.dart`) · `docs/rediseno/fase3/paquete/correccion/flutter-ui-audit.txt` |
| Censo T-112 (referencia `5406e20`) | **1950** visibles (1940 + los diez nombres): 1819 español, 131 sin idioma, **0 inglés**; M3 250 / 7 / 3; 217 / 217 mensajes · `docs/rediseno/fase3/paquete/correccion/censos/` |

Flutter se usó con la luz verde vigente desde 10.22, un comando a la vez y después de que Codex entregó
su dictamen. No se tocaron el emulador, el Honor, Firebase ni Git de escritura.

### 6.7 Archivos

- **Modificados (`lib/`):** `lib/features/vessel/presentation/widgets/iconos_del_dominio.dart`
  (`CondicionDelContenedor`, `condicionDelContenedor`, `condicionDelTipo`, `condicionDelTamano`,
  `IconoDelContenedor`; `iconoDeContenedor`, `iconoDeTipo` e `iconoDeTamano` derivadas),
  `container_search_delegate.dart` (`_buildLeadingIcon`), `containers_list_view.dart` (el ícono principal
  y `_getIconColor`), `detalle_contenedor.dart` (el ícono en el título) y `bay_plan_view.dart` (la
  etiqueta de la celda nombra la condición; `CondicionDelContenedor.enLaCelda`).
- **Modificados (documentos y herramientas):** `DESIGN.md` (13.11: la fila «Contenedor» y la regla 3),
  `tool/t112_censos.py` (la decisión del censo para los diez nombres), este informe y
  `docs/rediseno/fase3/traspaso-entrega2.md`.
- **Nuevos:** `test/t114_paquete_correccion_test.dart`;
  `docs/rediseno/fase3/paquete/correccion/semantica-busqueda.txt`, `flutter-ui-audit.txt`,
  `censos/resumen.json` y `censos/tablas.md`.
- No cambian `domain/`, `data/`, `lib/main.dart`, los congelados, Firebase, `pubspec.yaml` ni
  `pubspec.lock`. Ninguna dependencia nueva.

### 6.8 Lo que queda anotado y lo que Carlos decide

1. **La insignia de la celda del plano**, que la revisión encontró sin nombre, se corrigió aquí a pedido
   de Carlos (6.4). La celda dice también «Vacío» cuando el contenedor está vacío, en las tres vistas,
   aunque solo Tipo de vacío lo colorea. Si Carlos prefiere «Vacío» solo en esa vista, es una condición
   en `enLaCelda` y una línea en `bay_plan_view.dart`.
2. **El ícono en el título del detalle** es nuevo: la tabla de 13.11 nombraba el detalle como sitio del
   ícono y la hoja no lo tenía. Si Carlos lo prefiere en otro lugar de la hoja, o no lo quiere, es un
   widget.
3. **El color del ícono de la Lista** sigue ahora a la condición, como los chips; antes seguía solo al
   tipo ISO. Si se prefiere el color del tipo en todos los casos, es una función (`_getIconColor`).
4. **La descripción emergente fuera de la semántica** es una decisión explicada en 6.2 y en 13.11,
   regla 3. Si Codex o Carlos prefieren que entre en el árbol, es un parámetro.

### 6.9 Horas

Unos 50 min: leer el dictamen y las decisiones, revisar los 90 usos, la pieza y los cuatro parches, las
siete pruebas, las validaciones y este informe, con la vuelta de la insignia de la celda.

### Git para Carlos (Fase 3, paquete, corrección)

Un `git add` por ruta. Los generados de `windows/flutter/` y `test/t114_fase3_correccion_test.dart`
figuran modificados solo por el fin de línea y no se agregan. El último comando tiene que mostrar
**14 files changed**.

```powershell
git add -- lib/features/vessel/presentation/widgets/iconos_del_dominio.dart
git add -- lib/features/vessel/presentation/widgets/container_search_delegate.dart
git add -- lib/features/vessel/presentation/widgets/containers_list_view.dart
git add -- lib/features/vessel/presentation/widgets/detalle_contenedor.dart
git add -- lib/features/vessel/presentation/widgets/bay_plan_view.dart
git add -- DESIGN.md
git add -- tool/t112_censos.py
git add -- test/t114_paquete_correccion_test.dart
git add -- docs/rediseno/fase3/paquete/correccion/semantica-busqueda.txt
git add -- docs/rediseno/fase3/paquete/correccion/flutter-ui-audit.txt
git add -- docs/rediseno/fase3/paquete/correccion/censos/resumen.json
git add -- docs/rediseno/fase3/paquete/correccion/censos/tablas.md
git add -- docs/rediseno/fase3/traspaso-entrega2.md
git add -- docs/REDISENO-RESULTADOS.md
git commit -m "Sprint 4: correccion del paquete de iconos (10.23), la busqueda, la lista, el detalle y la celda del plano dicen la condicion del contenedor con una sola regla"
git push
git show --stat --format="%h %s" HEAD | Select-Object -Last 1
```

### Tres líneas

- H1: el ícono principal del contenedor dice su condición al lector de pantalla y la muestra como
  descripción emergente; los cuatro casos de Codex tienen cuatro etiquetas distintas.
- O1: una sola regla, `CondicionDelContenedor`, da el glifo y el nombre; la Lista, la búsqueda y el
  detalle dibujan lo mismo, y una prueba lo comprueba para once contenedores.
- Suite 1297, `analyze` 0, auditoría sin cambios, censo 0 inglés; la insignia de la celda del plano, que
  tampoco estaba en su etiqueta, entra también, a pedido de Carlos, en las tres vistas.

### Mensaje para Yov

Yov: la **corrección del paquete (10.23)** está escrita y probada, en un bloque aparte. **H1:** el ícono
principal del contenedor es ahora una pieza, `IconoDelContenedor`, que dibuja el glifo de la condición con
su nombre como `semanticLabel` y como `Tooltip` («Carga peligrosa», «Refrigerado», «Fuera de medida»,
«Vacío», «Tanque», «Plataforma», «Techo abierto», «Contenedor de 20 / 40 / 45 pies»); la descripción
emergente queda fuera de la semántica para que el lector no diga el nombre dos veces (iOS la añadiría a la
etiqueta). El nodo del resultado pasa de «TSTU0000011 / 22G1» en los cuatro casos a «Carga peligrosa /
TSTU0000011 / 22G1», etc.; el árbol de los cuatro casos está en
`docs/rediseno/fase3/paquete/correccion/semantica-busqueda.txt`. **O1:** `CondicionDelContenedor`
(glifo y nombre, prioridad de 13.11) es la única regla; `iconoDeContenedor`, `iconoDeTipo` e
`iconoDeTamano` se derivan de ella y conservan su firma; la tarjeta de la Lista la usa (y su color sigue a
la condición, como los chips) y el título del detalle lleva el ícono delante del número, porque la tabla de
13.11 nombraba el detalle y la hoja no lo tenía. `DESIGN.md` 13.11: la fila «Contenedor» y la regla 3 (cómo
se etiqueta el ícono principal y cuándo un ícono no necesita etiqueta). **Pruebas:** 7 nuevas en
`test/t114_paquete_correccion_test.dart` (los cuatro casos desde el árbol de semántica; el tipo y el tamaño;
pautas; la prioridad y los diez nombres; Lista, búsqueda y detalle con el mismo glifo y nombre para once
contenedores; la tarjeta y el detalle también dicen la condición; la celda del plano en las tres vistas de «Colorear
por»), suite **1297**, `analyze` 0, auditoría
17/248/20 idéntica, censo 1950 visibles / 0 inglés (los diez de más son los nombres), M3 250/7/3. **De la
revisión de los otros usos de íconos** (botones con rótulo, `IconButton` con tooltip, íconos junto a su
texto, los que ya tienen etiqueta y los decorativos junto al nombre) salió **uno más sin nombre: la
insignia de la celda del plano** (`bay_plan_view.dart` armaba la etiqueta sin ella y `BsCelda` excluye el
resto de la semántica); Carlos pidió corregirlo antes de subir, y la celda nombra ahora su condición
(«Carga peligrosa», «Refrigerado», «Fuera de medida», «Vacío») después de la marca, en Destino, Tipo de
vacío y Estado, leída desde el árbol de semántica. El bloque tiene 14 archivos y no toca `domain/`, `data/`, `main.dart`, Firebase,
`pubspec.yaml` ni `pubspec.lock`. Me detengo: ALTO: Codex acepta la corrección del paquete.

## Fase 3 · La travesía del inicio (10.24) (23-oct-2026)

Carlos pidió (decisión 10.24) que en el espacio libre debajo de los dos bloques del inicio («Abre un
plano de estiba» y «Recientes») un buque navegue de izquierda a derecha, se desvanezca al llegar a la
derecha y vuelva a salir por la izquierda. Yov la definió con el vocabulario del paquete de Nube, sin
dibujo nuevo. Esta sección es la Parte 2 del encargo, en un bloque de git aparte, después de la
corrección del paquete (10.23, aceptada en 10.25).

### 7.1 Resultado en tres líneas

- `BsTravesia` (`lib/core/design/componentes/bs_travesia.dart`) pinta el buque de `sin_conexion`
  reflejado, con la proa a la derecha, sobre el agua y la línea de flotación de esa misma ilustración
  a todo el ancho, y lo mueve solo con `Transform` y opacidad: el dibujo se pinta una vez. Vaivén,
  cabeceo, estela y dos olas, con los colores por nombre y nada naranja.
- Vive al pie del inicio, en lo que sobra debajo de los dos bloques, a todo el ancho; si cambian la
  ventana o la letra, cede ella, y con menos de 120 dp libres no se pinta. Con reducción de movimiento
  queda quieta sin tickers; con otra pantalla encima o en segundo plano se detiene; es decorativa.
- 14 pruebas nuevas (suite 1311), `analyze` 0, auditoría 17/248/20 sin hallazgos nuevos, censo 0
  inglés, y 12 capturas del inicio a 1280 × 720 y 1920 × 1080, en claro y en oscuro, con el buque al
  entrar, a la mitad y al salir.

### 7.2 La pieza

**Sin arte nuevo.** El buque son las formas de `BsIlustraciones.sinConexion` con grupo `casco_perfil`,
`perfil_0_0` a `perfil_0_4`, `caseta` y `puente`; quedan fuera la nube y la pausa. Se pintan con
`pintarFormaDeIlustracion`, la pintura de una forma que `PintorDeIlustracion` hacía por dentro y que
ahora es una función de `bs_ilustracion.dart` compartida por las dos piezas (el relleno, el trazo con
puntas y uniones redondas, el punteado, la caché de rutas). El lienzo del buque se mide desde las
rutas (`Path.getBounds`), no a mano: ocupa de 36 a 284 de ancho y de 84.66 a 180 de alto en el lienzo
de `sin_conexion`, con la línea de flotación a 152; la caja del buque le suma 52 unidades de estela
detrás de la popa. El mar es el relleno del grupo `agua` y el trazo del grupo `flotacion`, a todo el
ancho de la banda; las olas y la estela llevan ese mismo trazo (las olas al 55 %, la estela apagándose
al 60, 40 y 20 %). Todos los colores van por nombre a `colorDeIlustracion`, como en `BsIlustracion`;
no hay ningún hex ni nada naranja.

**La proa hacia donde va.** El pintor refleja el lienzo (`scale(-1, 1)`): la caseta y el puente, que en
la ilustración van a la derecha, quedan a la izquierda, en la popa; la proa curva mira a la derecha,
hacia donde navega. Es la única excepción a «la proa a la izquierda», que sigue valiendo para la
silueta, las ilustraciones y los íconos (`DESIGN.md` 13.11, regla 7).

**Dónde y cuánto.** `BsGeometriaDeTravesia(ancho, alto)` fija las medidas de la banda y las pruebas
las leen sin mirar píxeles:

| Regla | Valor |
|---|---|
| Alto mínimo de la banda | 120 dp (`BsIlustracion.altoMinimo`, 13.11 regla 4); por debajo, `SizedBox.shrink` y sin ticker |
| El agua | el tercio de abajo, mínimo 32 dp |
| El buque | la mitad del alto de la banda, entre 56 y 120 dp; su ancho sale de la proporción del lienzo |
| El cruce | el recorrido (el ancho de la banda más el del buque: entra desde fuera y sale del todo) entre 48 dp/s, acotado entre 14 y 40 s |
| La opacidad | de 0 a 1 en el primer 10 % del recorrido, 1 en medio, de 1 a 0 en el último 12 %; 0 durante los 3 s de mar vacío |
| El vaivén y el cabeceo | ±1.5 dp cada 3.2 s; ±0.8° cada 4.4 s, alrededor del centro del casco sobre la línea de flotación |
| Las olas | dos tiras a un tercio y a dos tercios del agua, que corren hacia la izquierda a 8 y a 16 dp/s; cada tira se repite cada 48 dp y mide el ancho más un paso, así que no hay costura |
| En la banda de 1280 × 720 | banda de 226.0 dp, buque de 113.0 dp, cruce de 34.1 s |
| En la de 1920 × 1080 | banda de 502.0 dp, buque de 120.0 dp, cruce de 40.0 s |

**El movimiento, solo con `Transform` y opacidad.** Un solo `Ticker` lleva el tiempo de la travesía en
un `ValueNotifier<Duration>`; por cuadro se reconstruyen solo tres cosas: el `Positioned` del buque
(su sitio y su vaivén), el `Transform.rotate` del cabeceo y la `Opacity`, y los `Transform.translate`
de las dos olas. El buque, cada ola y el mar son `CustomPaint` dentro de su `RepaintBoundary`: su
capa se compone de nuevo en cada cuadro, pero no se vuelve a pintar. `BsTravesia.pintadasDelBuque`
lo cuenta para las pruebas: una vez en 60 cuadros. El ciclo es el cruce más 3 s de mar vacío; el
vaivén y el cabeceo siguen el reloj y no saltan en el cambio de ciclo porque el buque está invisible
cuando el ciclo cambia.

**Cuándo se para.** Con `MediaQuery.disableAnimations` (`BsMovimiento.reducido`) el ticker no arranca:
el buque queda quieto, con el centro de su caja a un tercio del ancho, y las olas no corren. Con otra
pantalla encima, `TickerMode` silencia el ticker por sí solo (`SingleTickerProviderStateMixin`) y no se
programa ningún cuadro. En segundo plano (`AppLifecycleState` distinto de `resumed` e `inactive`) el
ticker se detiene, guarda lo andado y al volver sigue desde donde iba; con la ventana sin foco pero
a la vista (`inactive`) sigue navegando. Sin sitio para pintarse, tampoco corre.

**Es decorativa.** `ExcludeSemantics` e `IgnorePointer`; no hay ningún widget con foco. No añade ni
un nodo al árbol de semántica y el toque pasa de largo.

**La vista previa** `vistaPreviaTravesia` (`vistas_previas.dart`, 720 × 240) muestra la banda en el día
y en la noche para `flutter widget-preview start`.

### 7.3 Al pie del inicio

`InicioView` pasa de un `SingleChildScrollView` a un `CustomScrollView` con dos slivers: los dos
bloques de siempre, con su relleno, en un `SliverPadding`; y después un `SliverLayoutBuilder` que
calcula lo que sobra (`viewportMainAxisExtent - precedingScrollExtent`) y, si llega a 120 dp, pone
la banda con ese alto exacto; si no, nada. Así la banda nunca empuja los bloques ni los tapa, nunca
hace que el inicio se desplace, y cede antes que el texto cuando crece la letra o se achica la
ventana. No se usó el `SliverFillRemaining(hasScrollBody: false)` del ejemplo del encargo con un
`LayoutBuilder` dentro porque ese sliver pide el alto intrínseco de su hijo y `LayoutBuilder` no lo
tiene (lanza en depuración); el `SliverLayoutBuilder` da el mismo resultado sin esa trampa.

Con las fuentes reales, la banda aparece en el escritorio (1280 × 720 y 1920 × 1080 con las tres
escalas de letra) y no aparece en el teléfono (360 × 640) ni en 600 × 960 con la letra a 1.0, donde
los bloques dejan menos de 120 dp; la prueba de 7.4 recorre los doce casos y comprueba que la banda
mide exactamente lo que sobra y que nada se desplaza.

### 7.4 Pruebas

`test/t114_travesia_test.dart`, 14 pruebas nuevas. Suite **1311** (1297 + 14), sin omitidas.
Ninguna usa `pumpAndSettle` con la travesía viva: no se asienta nunca.

| Prueba | Qué comprueba |
|---|---|
| La regla · el cruce dura el recorrido entre 48 dp/s, entre 14 y 40 s | `duracionDelCruce`: 960 dp son 20 s; por debajo de 672 dp, 14 s; por encima de 1920 dp, 40 s |
| La regla · la opacidad sube en el primer 10 %, baja en el último 12 % | `opacidadDelCruce` en 0, 0.05, 0.1, 0.5, 0.88, 0.94, 1 y fuera del cruce |
| La regla · la banda: el agua en el tercio de abajo, el buque entre 56 y 120 | para alturas de 120 a 900: el agua, el alto del buque, que el buque cabe entero, las olas dentro del agua, el recorrido, el ciclo y el buque quieto a un tercio |
| La regla · el instante | entra desde fuera por la izquierda, a la mitad está en el centro, al terminar está fuera y con opacidad 0, descansa 3 s y vuelve; el vaivén y el cabeceo acotados; las olas a 8 y 16 dp/s, sin costura a los 6 s |
| Lo que se para · con reducción de movimiento | `transientCallbackCount` 0, opacidad 1, el centro de la caja a un tercio del ancho, el mismo rectángulo 5 s después, las olas en 0; `pumpAndSettle` se asienta |
| Lo que se para · con otra ruta encima | a la vista pide cuadros; con una `MaterialPageRoute` encima, 0; al volver, pide otra vez |
| Lo que se para · en segundo plano | con `paused`, 0 cuadros y el buque quieto; con `resumed`, sigue desde el mismo sitio y avanza lo que toca en 1 s; con `inactive` sigue |
| Lo que se para · con menos de 120 dp | a 119 dp ni `CustomPaint` ni cuadros; a 120, el mar, las dos olas y el buque, y el ticker |
| El cruce · la opacidad | 0 al empezar (y el buque fuera por la izquierda), 0.5 al 5 %, 1 a la mitad (y en el centro), 0.5 al 94 %, 0 al terminar y en el mar vacío, 1 otra vez en el ciclo siguiente |
| El cruce · las olas | −8 y −16 dp a 1 s, 0 y 0 a los 6 s, −4 y −8 a los 6.5 s |
| El cruce · el buque se pinta una sola vez | `pintadasDelBuque` es 1 tras 60 cuadros de 16 ms en los que el buque se movió |
| Al pie del inicio · sin desbordes ni empujones | el inicio real a 360 × 640, 600 × 960, 1280 × 720 y 1920 × 1080 con 1.0, 1.45 y 2.0, con las fuentes reales: sin excepciones; la banda existe exactamente cuando sobran 120 dp, mide lo que sobra, va a todo el ancho y al pie, debajo del botón y de «Perfiles guardados», y el desplazable no tiene nada que desplazar |
| Al pie del inicio · meetsGuideline | a 1280 × 720 con la banda y 4 s de travesía: contraste, objetivos táctiles y objetivos con etiqueta |
| Al pie del inicio · es decorativa | el recorrido de accesibilidad tiene los mismos nodos con y sin banda; `ExcludeSemantics`, `IgnorePointer`, ningún `Focus`; el toque sobre el buque no toca ningún `RenderCustomPaint` |

**Una prueba existente cambió:** `test/profile_loading_page_test.dart` abre el inicio a 1000 × 2600 y
usa `pumpAndSettle`; con la travesía viva no se asentaría. Pide reducir el movimiento
(`FakeAccessibilityFeatures(disableAnimations: true)`), como ya hace `t114_fase3_entrega2_correccion_test`,
y queda igual en todo lo demás. Las demás pruebas que abren el inicio lo hacen a 360 de ancho o a
800 × 600, donde los bloques no dejan 120 dp y no hay banda.

### 7.5 Capturas

Doce PNG en `docs/rediseno/fase3/travesia/capturas/`, con su `registro.tsv`. Son **capturas de prueba
de widget** (`build/t114-travesia/capturas_test.dart`, fuera de la suite y de Git): el inicio entero
(`VesselOverviewPage` sin viaje, con la barra superior) con las fuentes reales, en claro y en oscuro,
detenido con el reloj de la prueba al 6 %, al 50 % y al 95 % del cruce. Es lo que permite parar el buque
en un instante exacto; una captura de cliente no sabría cuándo entra ni cuándo sale. No son capturas
de un cliente compilado: si Codex quiere verlo en Windows o en la Web, la banda está en el inicio de
cualquier banco a 1280 de ancho o más.

| Archivo | Ventana | Tema | Momento | Banda | Buque | Cruce |
|---|---|---|---|---:|---:|---:|
| `inicio_1280x720_claro_entra.png` | 1280x720 | claro | entra (6 % del cruce) | 226.0 | 113.0 | 34.1 s |
| `inicio_1280x720_claro_mitad.png` | 1280x720 | claro | mitad (50 % del cruce) | 226.0 | 113.0 | 34.1 s |
| `inicio_1280x720_claro_sale.png` | 1280x720 | claro | sale (95 % del cruce) | 226.0 | 113.0 | 34.1 s |
| `inicio_1280x720_oscuro_entra.png` | 1280x720 | oscuro | entra (6 % del cruce) | 226.0 | 113.0 | 34.1 s |
| `inicio_1280x720_oscuro_mitad.png` | 1280x720 | oscuro | mitad (50 % del cruce) | 226.0 | 113.0 | 34.1 s |
| `inicio_1280x720_oscuro_sale.png` | 1280x720 | oscuro | sale (95 % del cruce) | 226.0 | 113.0 | 34.1 s |
| `inicio_1920x1080_claro_entra.png` | 1920x1080 | claro | entra (6 % del cruce) | 502.0 | 120.0 | 40.0 s |
| `inicio_1920x1080_claro_mitad.png` | 1920x1080 | claro | mitad (50 % del cruce) | 502.0 | 120.0 | 40.0 s |
| `inicio_1920x1080_claro_sale.png` | 1920x1080 | claro | sale (95 % del cruce) | 502.0 | 120.0 | 40.0 s |
| `inicio_1920x1080_oscuro_entra.png` | 1920x1080 | oscuro | entra (6 % del cruce) | 502.0 | 120.0 | 40.0 s |
| `inicio_1920x1080_oscuro_mitad.png` | 1920x1080 | oscuro | mitad (50 % del cruce) | 502.0 | 120.0 | 40.0 s |
| `inicio_1920x1080_oscuro_sale.png` | 1920x1080 | oscuro | sale (95 % del cruce) | 502.0 | 120.0 | 40.0 s |

### 7.6 Validaciones ejecutadas

| Qué | Resultado |
|---|---|
| `flutter analyze --no-pub` | 0 incidencias |
| `flutter test --no-pub` | **1311** pruebas en verde, ninguna omitida (`build/t114-travesia/flutter-test.txt`) |
| `flutter test build/t114-travesia/capturas_test.dart` | 1 prueba de evidencia; escribe las 12 capturas y `registro.tsv` |
| Auditoría `flutter-ui` (`--all`) | **17 / 248 / 20**, los mismos de la corrección del paquete; el diff sin números de línea solo cambia «178 archivos» por «179» · `docs/rediseno/fase3/travesia/flutter-ui-audit.txt`. El escáner marca como «animación de duración cero» cualquier `Duration.zero`; el arranque del reloj de la travesía se escribe `const Duration()`, que es lo mismo, para no sumar dos avisos que no son animaciones |
| Censo T-112 (referencia `5406e20`) | **1950** visibles: 1819 español, 131 sin idioma, **0 inglés**; M3 250 / 7 / 3; 217 / 217 mensajes · `docs/rediseno/fase3/travesia/censos/`. Los nombres de grupo de `bs_travesia.dart` son código (NV-CODIGO) |

Flutter se usó con la luz verde de 10.25, un comando a la vez. No se tocaron el emulador, el Honor,
Firebase, el paquete de Nube ni Git de escritura.

### 7.7 Archivos

- **Nuevos:** `lib/core/design/componentes/bs_travesia.dart`, `test/t114_travesia_test.dart`,
  `docs/rediseno/fase3/travesia/` (la auditoría, los censos, las 12 capturas y su registro).
- **Modificados (`lib/`):** `componentes/bs_ilustracion.dart` (`pintarFormaDeIlustracion` compartida;
  `PintorDeIlustracion` la usa), `design.dart` (el export), `vistas_previas.dart` (la vista previa),
  `lib/features/vessel/presentation/widgets/inicio_view.dart` (la banda al pie).
- **Modificados (documentos, pruebas y herramientas):** `DESIGN.md` (13.7, la fila del pie del inicio;
  13.11, la regla 7), `test/profile_loading_page_test.dart`, `tool/t112_censos.py`, este informe y
  `docs/rediseno/fase3/traspaso-entrega2.md`.
- No cambian `domain/`, `data/`, `lib/main.dart`, los congelados, Firebase, `pubspec.yaml`,
  `pubspec.lock` ni nada del paquete de Nube (`assets/fonts/bs_iconos`, `design/`). Ninguna dependencia
  nueva.

### 7.8 Lo que queda anotado y lo que Carlos decide

1. **Las capturas son de prueba de widget**, no de un cliente (7.5). Si la aceptación quiere además
   una captura de Windows o de la Web, la banda se ve en cualquier banco a 1280 de ancho o más.
2. **La ventana sin foco sigue navegando.** `AppLifecycleState.inactive` (la ventana de Windows sin
   foco, pero a la vista) no detiene la travesía; `paused` y `hidden`, sí. Si Carlos prefiere pararla
   también sin foco, es una condición en `_ajustar`.
3. **La duración del cruce** se calcula sobre el recorrido completo (el ancho de la banda más el del
   buque), para que la velocidad sea la misma dentro y fuera de la ventana. A 1280 de ancho da
   34.1 s; a 1920, 40.0 s.
4. **La mitad del alto como tamaño del buque.** El encargo fija «entre 56 y 120 dp, según la banda»; se
   eligió la mitad del alto de la banda, acotada, para que el buque crezca con el sitio sin llenarlo.
5. **El tono de las olas y la estela** es el trazo de la línea de flotación al 55 % (las olas) y al 60,
   40 y 20 % (la estela): ningún color nuevo. Si se quieren más marcadas, son dos constantes.
6. **`profile_loading_page_test` pide reducir el movimiento** para asentarse (7.4). Cualquier prueba
   futura que abra el inicio a 840 de ancho o más tendrá que hacer lo mismo, o usar `pump`.

### 7.9 Horas

Unas 2 h: leer el encargo y los datos del paquete, la pieza y su geometría, la banda en el inicio,
las 14 pruebas y los tres fallos propios que encontraron (la compuerta por tamaño del ticker, un
estado reutilizado entre dos arranques y una medida mal hecha de lo que sobra), las capturas, las
validaciones y este informe.

### Git para Carlos (Fase 3, la travesía del inicio)

Un `git add` por ruta; la carpeta de las capturas va por carpeta (12 PNG y su registro). Los generados
de `windows/flutter/` y `test/t114_fase3_correccion_test.dart` figuran modificados solo por el fin de
línea y no se agregan. El último comando tiene que mostrar **27 files changed**.

```powershell
git add -- lib/core/design/componentes/bs_travesia.dart
git add -- lib/core/design/componentes/bs_ilustracion.dart
git add -- lib/core/design/design.dart
git add -- lib/core/design/vistas_previas.dart
git add -- lib/features/vessel/presentation/widgets/inicio_view.dart
git add -- DESIGN.md
git add -- tool/t112_censos.py
git add -- test/t114_travesia_test.dart
git add -- test/profile_loading_page_test.dart
git add -- docs/rediseno/fase3/travesia/flutter-ui-audit.txt
git add -- docs/rediseno/fase3/travesia/censos/resumen.json
git add -- docs/rediseno/fase3/travesia/censos/tablas.md
git add -- docs/rediseno/fase3/travesia/capturas
git add -- docs/rediseno/fase3/traspaso-entrega2.md
git add -- docs/REDISENO-RESULTADOS.md
git commit -m "Sprint 4: la travesia del inicio (10.24), BsTravesia con el buque de sin_conexion navegando al pie del inicio, sin arte nuevo, solo Transform y opacidad, quieta con reduccion de movimiento y parada fuera de vista"
git push
git show --stat --format="%h %s" HEAD | Select-Object -Last 1
```

### Tres líneas

- `BsTravesia`: el buque de `sin_conexion`, reflejado con la proa a la derecha, cruza el mar al pie
  del inicio solo con `Transform` y opacidad, pintado una vez, con vaivén, cabeceo, estela y dos olas,
  y sin un color ni un trazo nuevos.
- Ocupa solo lo que sobra debajo de los dos bloques y cede ante la ventana y la letra; quieta con
  reducción de movimiento, parada con otra pantalla encima o en segundo plano, y decorativa.
- 14 pruebas (suite 1311), `analyze` 0, auditoría y censo sin cambios, 12 capturas del inicio en
  dos tamaños, dos temas y tres momentos del cruce.

### Mensaje para Yov

Yov: la **travesía del inicio (10.24)** está escrita, probada y documentada, en un bloque aparte de
27 archivos. **La pieza:** `BsTravesia` (`lib/core/design/componentes/bs_travesia.dart`) toma
de `BsIlustraciones.sinConexion` los grupos `casco_perfil`, `perfil_0_0` a `perfil_0_4`, `caseta` y
`puente` (sin la nube ni la pausa) y los pinta reflejados, con la proa a la derecha; el mar es el
relleno de `agua` y el trazo de `flotacion` a todo el ancho; las olas y la estela llevan ese mismo
trazo; todo por nombre con `colorDeIlustracion`, nada naranja. La pintura de una forma salió de
`PintorDeIlustracion` a `pintarFormaDeIlustracion`, compartida. **La regla** (`BsGeometriaDeTravesia`):
agua en el tercio de abajo (mínimo 32), buque a la mitad del alto entre 56 y 120, cruce a 48 dp/s sobre
el recorrido (banda más buque) entre 14 y 40 s, opacidad 0→1 en el primer 10 % y 1→0 en el último
12 %, 3 s de mar vacío, vaivén ±1.5 dp / 3.2 s, cabeceo ±0.8° / 4.4 s, estela de tres trazos, olas a 8
y 16 dp/s en tiras de 48 dp sin costura. **El movimiento** va con un solo `Ticker` y por cuadro solo
cambian `Positioned`, `Transform` y `Opacity`; el buque, las olas y el mar son `CustomPaint` en su
`RepaintBoundary` y se pintan una vez (`pintadasDelBuque` = 1 en 60 cuadros). **Se para** con
reducción de movimiento (quieto a un tercio, sin tickers), con otra ruta encima (`TickerMode`) y en
segundo plano (`AppLifecycleState`), y no corre si no hay sitio. **En el inicio** va en un
`CustomScrollView`: los bloques en un `SliverPadding` y un `SliverLayoutBuilder` que da a la banda
exactamente lo que sobra si llega a 120 dp (no se usó `SliverFillRemaining` con `LayoutBuilder`
dentro, porque pide intrínsecos que `LayoutBuilder` no tiene). **Pruebas:** 14 en
`test/t114_travesia_test.dart` (la regla; sin tickers con reducción; sin cuadros con otra ruta o en
segundo plano; nada bajo 120 dp; la opacidad 0/1/0; las olas; pintado una vez en 60 cuadros; el inicio
sin desbordes ni empujones a 360, 600, 1280 × 720 y 1920 × 1080 con 1.0/1.45/2.0 y la banda igual a lo
que sobra; `meetsGuideline`; decorativa), suite **1311**, `analyze` 0, auditoría 17/248/20 sin
hallazgos nuevos, censo 1950 / 0 inglés. `profile_loading_page_test` pide reducir el movimiento para
poder asentarse (abre el inicio a 1000 × 2600). **Capturas:** 12 PNG en
`docs/rediseno/fase3/travesia/capturas/` (1280 × 720 y 1920 × 1080, claro y oscuro, al 6 %, 50 % y
95 % del cruce), de prueba de widget con las fuentes reales y el reloj de la prueba; no son de un
cliente. `DESIGN.md`: la fila del pie del inicio en 13.7 y la regla 7 de 13.11, con la excepción de la
proa. Me detengo: ALTO: Codex acepta la travesía.

## Fase 3 · La travesía · Corrección tras la aceptación de Codex (23-oct-2026)

Codex no aceptó la travesía (`docs/rediseno/fase3/travesia/aceptacion-codex.md`; decisión 10.26). El
rendimiento salió bien en los dos clientes (Windows: build p99 0.55 ms, raster p99 2.18 ms; la Web: build
p99 1.0 ms; el buque no se repintó en 60 s), pero quedaron tres cosas: **H1**, el cruce y el vaivén
cambiaban `Positioned.left` y `top` en cada cuadro; **H2**, RNF-002 en Windows no quedó acreditado porque
el detector de `tool/t114_primera_windows.py` pulsó el muelle de la ilustración y, cuando el clic acertó,
la corrida se quedó sin el paso 3; y **O1**, `_asentar` del conductor de T-99 esperaba un reposo que el
inicio ya no tiene. Esta sección corrige las tres cosas en un bloque aparte.

### 8.1 Resultado en tres líneas

- H1: la caja del buque queda fija (`left: 0`, el alto de siempre) y el cruce, el vaivén y el cabeceo
  son un solo `Transform` sobre ella; el buque sigue pintándose una vez y una prueba nueva lee la
  posición de layout en dos instantes y comprueba que es la misma.
- H2: el detector lee el tema del papel, acepta solo un rectángulo con la forma y el rótulo del botón,
  conoce la capa de hover y aparca el cursor antes de buscar, y el clic se comprueba y se repite con
  diagnóstico; RNF-002 en Windows volvió a correr entero: cinco
  repeticiones con los tres pasos y la captura de la rejilla, entre 1.84 y 1.89 s.
- O1: el conductor pide reducción de movimiento y `_asentar` avisa al vencer; los scripts de capturas y
  RAM de Windows cuentan esos avisos. La Web y Android no suponían reposo ni color: no cambian. Suite
  1312, `analyze` 0, auditoría y censo iguales.

### 8.2 H1 · La caja fija y el `Transform`

`BsGeometriaDeTravesia` tiene ahora `arribaDeLaCaja` (dónde va el borde de arriba de la caja, sin
vaivén), `ejeDelCabeceoEnLaCaja` (el eje del cabeceo en dp) y `transformacion(instante)`: una matriz que
traslada lo que el cruce y el vaivén piden y gira el cabeceo alrededor de su eje. El `Positioned` del
buque es fijo (`left: 0`, `top: arribaDeLaCaja`, el ancho y el alto de la caja) y dentro van el
`ValueListenableBuilder`, la `Opacity` y un único `Transform` con esa matriz; el `RepaintBoundary` con el
`CustomPaint` es el hijo que no se reconstruye. Así, por cuadro cambian solo la opacidad y la
transformación, y el layout de la caja no cambia nunca; las olas ya iban así. `DESIGN.md` 13.11, regla 7,
lo dice ahora con esas palabras.

La prueba nueva (`Solo Transform y opacidad (10.26, H1)`) monta la banda, deja pasar 3 s, lee el
`StackParentData.offset` del buque, su `Positioned` y su tamaño, deja pasar 2 s más y comprueba que los
tres siguen iguales, que hay un solo `Transform` bajo la `Opacity`, que el dibujo (la esquina del
`RepaintBoundary`, ya transformada) se corrió lo que tocan 2 s de cruce, y que el contador de pintadas no
subió. Las pruebas que medían dónde está el buque leen ahora el dibujo dentro del `Transform`, no la
caja; una tolerancia de 3 dp absorbe lo que el cabeceo corre la esquina.

### 8.3 H2 · El detector, el clic y RNF-002

**El detector.** `boton_de_marca` ya no prueba azules por turno. Lee el tema por el papel de la ventana
(el color que más píxeles ocupa: `#F5F8FC` de día, `#07111F` de noche), busca rectángulos del color del
botón de ese tema (`#0D47A1` de día, `#4F8EF7` de noche) y acepta solo el que tiene la forma del botón
(de 40 a 120 px de alto, al menos tres veces más ancho que alto, al menos 120 px de ancho y relleno en un
75 % o más) y lleva un rótulo dentro: píxeles que no son del color del botón, concentrados en la franja
central de filas, centrados a lo ancho y con una extensión de entre el 8 y el 60 % del ancho. El muelle de
la ilustración comparte el azul de día, pero no esa forma ni esa firma. Antes de pulsar, el botón tiene
que verse en el mismo sitio en dos cuadros seguidos. `--detector <png>…` corre solo el detector sobre
capturas guardadas; sobre las de Codex y las de la entrega 2 da esto (`detector.txt`):

```text
{"imagen": "<aceptación de Codex>/rnf-windows/sin01/inicio.png", "tamano": [1938, 1038], "tema": "oscuro", "boton": {"punto": [420, 592], "tema": "oscuro", "caja": [69, 772, 563, 621], "ancho": 704, "alto": 59, "relleno": 0.971, "rotulo": 0.263, "rotuloDesvio": 0.006, "otros": 0.029, "color": "normal"}}
{"imagen": "<aceptación de Codex>/rnf-tema/sin01/inicio.png", "tamano": [1938, 1038], "tema": "oscuro", "boton": {"punto": [420, 592], "tema": "oscuro", "caja": [69, 772, 563, 621], "ancho": 704, "alto": 59, "relleno": 0.971, "rotulo": 0.263, "rotuloDesvio": 0.006, "otros": 0.029, "color": "normal"}}
{"imagen": "docs/rediseno/fase3/entrega2/rnf-002/windows/sin01/inicio.png", "tamano": [1938, 1038], "tema": "oscuro", "boton": {"punto": [420, 275], "tema": "oscuro", "caja": [69, 772, 246, 304], "ancho": 704, "alto": 59, "relleno": 0.973, "rotulo": 0.266, "rotuloDesvio": 0.007, "otros": 0.027, "color": "normal"}}
{"imagen": "docs/rediseno/fase3/entrega2/rnf-002/windows/sin01/rejilla.png", "tamano": [1938, 1038], "tema": "oscuro", "boton": null}
{"imagen": "docs/rediseno/fase3/travesia/correccion/rnf-002/windows-intento-hover/sin04/ultimo.png", "tamano": [1938, 1038], "tema": "oscuro", "boton": {"punto": [420, 592], "tema": "oscuro", "caja": [69, 772, 563, 621], "ancho": 704, "alto": 59, "relleno": 0.971, "rotulo": 0.263, "rotuloDesvio": 0.006, "otros": 0.029, "color": "hover"}}
{"imagen": "docs/rediseno/fase3/travesia/correccion/rnf-002/windows/sin01/inicio.png", "tamano": [1938, 1038], "tema": "oscuro", "boton": {"punto": [420, 592], "tema": "oscuro", "caja": [69, 772, 563, 621], "ancho": 704, "alto": 59, "relleno": 0.971, "rotulo": 0.263, "rotuloDesvio": 0.006, "otros": 0.029, "color": "normal"}}
{"imagen": "docs/rediseno/fase3/travesia/correccion/rnf-002/windows/sin01/rejilla.png", "tamano": [1938, 1038], "tema": "oscuro", "boton": null}
```

**Lo que encontró la primera corrida: el botón bajo el cursor.** La primera corrida con el detector nuevo
dio 3.08 s, 67.7 s (con el clic a los 66.6 s), 2.13 s y un «Más de 120 s sin rejilla» sin clic, con el
inicio a la vista todo el tiempo. El histograma de esos cuadros lo explica
(`rnf-002/windows-intento-hover/histograma.txt`): al repetir, el cursor queda donde pulsó la repetición
anterior, justo sobre el botón, y el botón nace con la capa de hover de Material 3 (`onPrimary` al 8 %):
(74, 132, 230) en vez de (79, 142, 247), 17 unidades de distancia, fuera de la tolerancia de 12. El
detector se corrige por los dos lados: antes de buscar, el cursor se aparca en la barra de título de la
ventana (`cursorAparcado` en el registro), y `MARCAS` trae por tema la variante `normal` y la `hover`
(de día, (32, 86, 169)); `--detector` dice cuál vio (`color`). Sobre `sin04/ultimo.png` de ese intento da
ahora el botón con `color: hover`. Los registros de las cuatro repeticiones quedan como evidencia; no se
cuentan como medición.

**El clic se comprueba.** Tras pulsar, si en 4 s no asoma el selector, el instrumento anota qué ventana
estaba en primer plano y cuál había bajo el cursor (`WindowFromPoint`, `GetForegroundWindow`,
`GetCursorPos`), guarda el cuadro, vuelve a traer el banco al frente y repite el clic, hasta tres veces;
después falla con ese diagnóstico, en vez de esperar 120 s en silencio. Cada intento queda en
`registro.json` (`clics`, con `selectorEnS` y `diagnostico`) y en `reintentosDeClic`.

**La causa del segundo bloqueo.** En la corrida de Codex con el clic en el botón (`rnf-tema/sin01`), el
clic salió a los 0.56 s, 0.14 s después de aparecer la ventana, al punto correcto; y en los cuadros
siguientes la diferencia entre cuadros se quedó en 0.02 a 0.06 (solo el buque entrando): ni la onda del
botón, que mueve 40 000 píxeles, ni el selector. Es decir, el puntero nunca llegó al botón, no que el
selector tardara. El instrumento de entonces no podía decir por qué: esperaba el selector en silencio.
Las dos diferencias con las corridas de la entrega 2, que sí abrieron el selector en 1.5 s, son el momento
(allí el clic salió 0.22 a 0.25 s después de la ventana) y la consola que lo lanzó. Esta corrección quita
las dos dudas: el botón tiene que estar quieto dos cuadros antes del clic, y si el clic no abre el
selector queda escrito a qué ventana fue y se repite. En las cinco repeticiones de aquí, el primer clic
abrió el selector en todas (0 reintentos); el diagnóstico queda listo para la reaceptación de
Codex, por si en su consola vuelve a pasar.

**RNF-002 en Windows, repetido** (`rnf-002/windows/`, tema del sistema oscuro, sin perfil, banco r4
del árbol corregido compilado en `%TEMP%\t99-r4-travesia`, almacén en `%TEMP%`, el sintético de 977):

| Repetición | Ventana (s) | Clic (s) | Selector confirmado (s) | Rejilla quieta (s) | Reintentos | El botón que vio | ≤ 30 s |
|---:|---:|---:|---:|---:|---:|---|---|
| 1 | 0.397 | 0.796 | 1.619 | 1.877 | 0 | 704 × 59, relleno 0.97, rótulo 0.26 | sí |
| 2 | 0.459 | 0.863 | 1.639 | 1.893 | 0 | 704 × 59, relleno 0.97, rótulo 0.26 | sí |
| 3 | 0.437 | 0.815 | 1.585 | 1.841 | 0 | 704 × 59, relleno 0.97, rótulo 0.26 | sí |
| 4 | 0.457 | 0.825 | 1.600 | 1.851 | 0 | 704 × 59, relleno 0.97, rótulo 0.26 | sí |
| 5 | 0.436 | 0.805 | 1.621 | 1.873 | 0 | 704 × 59, relleno 0.97, rótulo 0.26 | sí |

Tres pasos del producto en las cinco; mediana 1.87 s, incertidumbre 0.05 s. Cada carpeta
`sinNN/` trae `inicio.png` (lo que vio el detector), `rejilla.png` (el primer cuadro quieto con el plano)
y `final.png`.

### 8.4 O1 · El conductor y los scripts que heredan su espera

`tool/t99_conductor.dart` pide reducción de movimiento en su `MediaQuery` (`disableAnimations: true`)
salvo que `T99_MOVIMIENTO=completo`: es lo que pide el sistema cuando alguien activa esa opción, y con
ello el inicio con la travesía se asienta (el buque quieto a un tercio del ancho, las olas quietas, sin
tickers). `_asentar` espera hasta `T99_ASENTAR_MS` (20 000 por omisión), devuelve si hubo reposo y, si
el límite vence, lo anota como paso `aviso` (`asentar: vencido`, los ms) y sigue: quien lee los pasos sabe
que lo que siguió se tomó sin reposo. `t114_capturas_windows.ps1` pasa `T99_MOVIMIENTO` (parámetro
`-Movimiento`, `reducido` por omisión) y, al terminar, dice cuántas esperas vencieron; `t114_ram_windows.ps1`
fija `reducido` y lo dice por corrida. Con el escenario `inicio` a 1920 × 1080 y letra 1.0:

| Corrida | `T99_MOVIMIENTO` | PNG | Esperas vencidas (`aviso`) | Último paso |
|---|---|---:|---:|---|
| `capturas-reposo/` | reducido | 4 | 0 | fin |
| `capturas-completo/` | completo | 1 | 11 (de 20002 a 20054 ms) | fin |

### 8.5 La Web y Android, revisados

| Instrumento | Cómo encuentra el botón | Cómo espera | Veredicto |
|---|---|---|---|
| `t114_primera_web.js` / `.py` (RNF-002 Web) | por el texto «Seleccionar archivo» en la semántica, no por color | `esperarCuadros` con límite y error explícito («espera agotada», «Sin rejilla en el límite»); el fin es una bahía en la semántica, no un cuadro quieto | sin el supuesto; no cambia |
| `t114_primera_android.py` + `t114_primera_cuadros.py` | por el texto en `uiautomator` | el fin lo da el video: el primer cuadro desde el que todo se parece al cuadro final (el plano quieto); a 360 × 640 la banda no existe | sin el supuesto; no cambia |
| `t114_capturas_web.py` / `_plano.py` | por el texto (`esperar(page, patrón)` con límite) | pausas fijas y `wait_for_function` con `timeout` | sin el supuesto; no cambia |
| `t114_capturas_android.py` / `_plano.py` | por el texto en `uiautomator` | `esperar` por intentos y `screencap` | sin el supuesto; no cambia |
| `t114_capturas_windows.ps1`, `t114_ram_windows.ps1` (conductor) | no pulsan: el conductor toca por elemento | heredaban `_asentar` | corregidos (8.4) |
| `t114_primera_windows.py` | por color, forma y rótulo | selector con límite y diagnóstico; rejilla por cuadro quieto (el plano no se anima) | corregido (8.3) |

Los instrumentos de T-98 no se tocan.

### 8.6 Pruebas

`test/t114_travesia_test.dart` pasa de 14 a 15 pruebas: la nueva de H1 (8.2) y las cinco que leían la
posición del buque, ahora sobre el dibujo dentro del `Transform`; «es decorativa» toca el buque a la
mitad del cruce y el agua, y comprueba que ningún objeto de la banda entra en el `HitTestResult` (la
versión anterior tocaba un punto fuera de la ventana). Suite **1312** (1311 + 1), sin omitidas.

### 8.7 Validaciones ejecutadas

| Qué | Resultado |
|---|---|
| `flutter analyze --no-pub` | 0 incidencias |
| `flutter test --no-pub` | **1312** pruebas en verde, ninguna omitida (`build/t114-travesia/flutter-test.txt`) |
| `tool/t114_primera_windows.py --perfil sin --repeticiones 5` | 5 de 5 con tres pasos y rejilla; 8.3 |
| `tool/t114_primera_windows.py --detector` | el botón en las capturas de Codex y de la entrega 2; nada en la rejilla |
| `tool/t114_capturas_windows.ps1 -Escenario inicio -Anchos 1920x1080 -Letras 1.0 -PorExplorer` | reducido: 0 avisos; completo: 11 avisos (8.4) |
| Auditoría `flutter-ui` (`--all`) | **17 / 248 / 20**, idéntica a la travesía · `flutter-ui-audit.txt` |
| Censo T-112 (referencia `5406e20`) | **1950** visibles, **0 inglés**; M3 250 / 7 / 3; 217 / 217 · `censos/` |

Flutter se usó con la luz verde de 10.26, un comando a la vez; las mediciones se hicieron sin compilar ni
correr pruebas a la vez. El banco se abrió con `explorer.exe` y el almacén fue el de `%TEMP%`. No se tocó
el emulador, el Honor, Firebase ni Git de escritura.

### 8.8 Archivos

- **Modificados (`lib/` y `test/`):** `lib/core/design/componentes/bs_travesia.dart` (H1),
  `test/t114_travesia_test.dart` (15 pruebas).
- **Modificados (instrumentos):** `tool/t114_primera_windows.py` (H2), `tool/t99_conductor.dart`,
  `tool/t114_capturas_windows.ps1` y `tool/t114_ram_windows.ps1` (O1).
- **Modificados (documentos):** `DESIGN.md` (13.11, regla 7), este informe y
  `docs/rediseno/fase3/traspaso-entrega2.md`.
- **Nuevos:** `docs/rediseno/fase3/travesia/correccion/` (la corrida RNF-002 con sus registros y PNG, las
  dos corridas del conductor, el detector, la auditoría y los censos).
- No cambian `domain/`, `data/`, `lib/main.dart`, los congelados, Firebase, `pubspec.yaml`,
  `pubspec.lock`, el paquete de Nube ni los instrumentos de T-98.

### 8.9 Lo que queda anotado y lo que Carlos decide

1. **La causa del segundo bloqueo de Codex** se acota, no se reproduce (8.3): el puntero no llegó al
   botón. El instrumento ahora lo diría; si en la consola de Codex vuelve a pasar, el `diagnostico` de
   `registro.json` dirá a qué ventana fue el clic.
2. **La condición «con perfil» no se repitió**: es informativa y el almacén de la copia nueva no tiene
   un perfil confirmado. Si Codex la quiere, es una corrida más con `--perfil con`.
3. **Con `T99_MOVIMIENTO=completo` las capturas del inicio salen con el buque en un instante cualquiera**
   y las esperas vencen: es el modo para medir la animación, no para capturar.
4. **El clic sigue siendo `mouse_event` de `t98acc_sonda_windows.py`**, que no se toca; la
   comprobación y el reintento están en el instrumento de T-114.
5. **La capa de hover** son dos ternas por tema en `MARCAS`, calculadas como `onPrimary` al 8 % sobre
   `primary`; si el tema cambia esos tokens, cambian ahí.

### 8.10 Horas

Unas 2 h 15 min: leer el dictamen y los instrumentos, H1 y su prueba, el detector y el clic con sus
reintentos, el conductor y los scripts, el banco de Windows, las corridas de RNF-002 y del conductor,
las validaciones y este informe.

### Git para Carlos (Fase 3, la travesía, corrección)

Un `git add` por ruta; la evidencia de la corrección va por carpeta. Los generados de `windows/flutter/`
y `test/t114_fase3_correccion_test.dart` figuran modificados solo por el fin de línea y no se agregan. El
último comando tiene que mostrar **48 files changed**.

```powershell
git add -- lib/core/design/componentes/bs_travesia.dart
git add -- test/t114_travesia_test.dart
git add -- tool/t114_primera_windows.py
git add -- tool/t99_conductor.dart
git add -- tool/t114_capturas_windows.ps1
git add -- tool/t114_ram_windows.ps1
git add -- DESIGN.md
git add -- docs/rediseno/fase3/travesia/correccion
git add -- docs/rediseno/fase3/traspaso-entrega2.md
git add -- docs/REDISENO-RESULTADOS.md
git commit -m "Sprint 4: correccion de la travesia (10.26), caja fija con Transform, el detector de Windows valida el boton y comprueba el clic, RNF-002 repetido, y el conductor de T-99 pide reduccion de movimiento y avisa al vencer la espera"
git push
git show --stat --format="%h %s" HEAD | Select-Object -Last 1
```

### Tres líneas

- H1: la caja del buque no cambia de sitio ni de tamaño en ningún cuadro; el cruce, el vaivén y el
  cabeceo son un solo `Transform`, y una prueba lo lee del layout.
- H2: el detector reconoce el botón por el tema, la forma y el rótulo, el clic se comprueba y se
  repite con diagnóstico, y RNF-002 en Windows está acreditado: cinco corridas con tres pasos y
  rejilla, entre 1.84 y 1.89 s.
- O1: el conductor pide reducción de movimiento y avisa al vencer la espera; la Web y Android no tenían
  el supuesto. Suite 1312, analyze 0, auditoría y censo iguales.

### Mensaje para Yov

Yov: la **corrección de la travesía (10.26)** está escrita, probada y medida, en un bloque aparte de
48 archivos. **H1:** la caja del buque queda fija (`Positioned` con `left: 0` y el alto de siempre)
y el cruce, el vaivén y el cabeceo van en un solo `Transform` (`BsGeometriaDeTravesia.transformacion`,
que traslada y gira alrededor del eje del casco); por cuadro cambian solo la opacidad y esa matriz, el
buque se pinta una vez y la prueba nueva lee `StackParentData.offset`, el `Positioned` y el tamaño en dos
instantes. **H2:** `t114_primera_windows.py` lee el tema por el papel, busca el botón del color de ese
tema y acepta solo el rectángulo con su forma (40–120 px de alto, ≥ 3:1, ≥ 120 px, relleno ≥ 75 %) y su
rótulo centrado; `--detector` lo corre sobre capturas (en las de Codex da el botón, [420, 592], no el
muelle); el botón tiene que estar quieto dos cuadros, el cursor se aparca en la barra de título y el
detector acepta la capa de hover (la primera corrida perdió dos de cuatro repeticiones porque el botón
nacía bajo el cursor de la repetición anterior, apagado; evidencia en `windows-intento-hover/`); y tras
el clic, si en 4 s no asoma el selector,
anota qué ventana estaba en primer plano y cuál bajo el cursor, trae el banco al frente y repite hasta
tres veces, y después falla con ese diagnóstico. La causa del segundo bloqueo de Codex se acota: el clic
salió al punto correcto a los 0.56 s y los cuadros siguientes no muestran ni la onda del botón, así que el
puntero no llegó al banco; el instrumento ahora lo diría y lo reintenta. **RNF-002 en Windows, repetido:**
cinco repeticiones sin perfil con los tres pasos y la rejilla, entre 1.84 y 1.89 s
(mediana 1.87), 0 reintentos, con `inicio`, `rejilla` y `final` por repetición. **O1:** el
conductor pide `disableAnimations` (`T99_MOVIMIENTO=reducido` por omisión; `completo` para medir la
animación con cuadros acotados), `_asentar` devuelve si hubo reposo y anota `aviso` al vencer
`T99_ASENTAR_MS`, y los scripts de capturas y RAM de Windows lo cuentan: con reducido, 0 avisos y el
inicio quieto; con completo, 11 avisos. **La Web y Android** encuentran el botón por texto y esperan
estados concretos con límite o leen el fin del video: no tenían el supuesto y no cambian; los de T-98 no
se tocan. **Cifras:** suite 1312 (1311 + 1), `analyze` 0, auditoría 17/248/20 idéntica, censo 1950 / 0
inglés. Me detengo: ALTO: Codex acepta la corrección de la travesía.

## Fase 3 · Candidata del piloto (10.28) (23-oct-2026)

Carlos decidió (10.28) que la prueba piloto con COMAR, el 25 o el 26-oct, vaya con el
rediseño. El encargo de este chat: que lo rediseñado y lo que todavía no se rediseñó
funcionen de punta a punta en el muelle y en la oficina; sin funciones nuevas ni pantallas
enteras. Paso 0: la travesía (`f27de53`, `53838d7`), su aceptación (10.27) y la decisión
10.28 (`25b8cf7`) están en commits; en el árbol solo quedaban los tres generados de
`windows/flutter/` y `test/t114_fase3_correccion_test.dart` con el fin de línea cambiado,
que no son de nadie y no se tocan.

### 9.1 Resultado en tres líneas

- **El recorrido del piloto se hizo en los tres clientes con el banco r4 y datos sintéticos**
  (BUQUE MANUAL, viaje M100, escala GTSTC: `T100_CARGA.edi`, `T100_LISTADO.xlsx` y
  `T100_LLEGADA.edi`), como una persona y por la interfaz: Windows (26 pasos, la oficina a
  1920 de noche), la Web (27 pasos, con la descarga del BAPLIE de salida) y el emulador
  (25 pasos, el muelle a 360 × 640 de día). Nada bloqueó. Lo que necesita
  Firebase (unirse, publicar, pedir y decidir cambios, sincronizar) no se recorrió: está
  probado en memoria (T-79, T-80, T-81) y queda en la lista del ensayo de Carlos.
- **Cinco correcciones, solo en la presentación y con su prueba:** Atrás en Android como
  dice `DESIGN.md` 8 (un toque por error no saca del plano); el chip seleccionado de noche,
  que quedaba tinta sobre tinta («Solo con cambios», los filtros por naviera); «Re‑estiba» en
  la celda, que salía cortada; `loadingOperationProvider`, que usaba `ref` después de que el
  viaje se cerrara mientras construía; y dos pruebas que fijaban el rótulo viejo. Las
  pantallas sin rediseñar no lanzan nada a 360 dp (1.0 y 2.0) ni a 1920 en oscuro.
- Suite **1329** (piso 1312; ninguna omitida), `analyze` **«No issues found»**. Versiones
  propuestas: Android **3.1.0 (4)**, MSIX **3.1.0.0**, Web **3.1.0 (4)**; `pubspec.yaml` las
  lleva. La lista de comprobación del ensayo y del piloto está en
  `docs/piloto/LISTA-PILOTO.md`. **ALTO: Codex acepta la candidata.**

### 9.2 El recorrido del piloto, con sus capturas

Los tres clientes recorren lo mismo, en el orden del piloto, cada uno con su instrumento
(9.8): Windows con el escenario `piloto` del conductor de T-99 (toques reales por elemento;
los archivos entran sin el selector del sistema, como en los escenarios anteriores); la Web
con Playwright sobre la semántica de Flutter (los archivos los asigna el navegador al
`<input type=file>`, como en RNF-002); el emulador con ADB y uiautomator (los archivos en
`/sdcard/Download/t114`, elegidos en el selector de AOSP). Las capturas numeradas, con una
línea de registro por paso, están en `docs/rediseno/fase3/candidata/recorrido/windows/`
(`pNN_*.png`, `pasos.jsonl` con los textos que no caben y los errores de Flutter por
captura, `anchos.jsonl`), `recorrido/web/` (`pNN-*.png`, `registro.tsv`) y
`recorrido/emulador/` (`pNN-*.png`, `registro.tsv`). Ninguna muestra «Nube y cuenta», un
correo ni el corpus.

| Paso del piloto | Windows (oficina, 1920 oscuro) | Web (oficina, 1920 oscuro) | Emulador (muelle, 360 × 640 claro) | Qué se vio |
|---|---|---|---|---|
| El inicio | p01 | p01 | p01 | «Abre un plano de estiba» y «Seleccionar archivo»; en Windows y la Web, la travesía al pie |
| Abrir el plan de carga: previo | p02 | p02 | p02 | La banda «Plano sin confirmar: perfil propuesto desde el archivo. Escala propuesta GTSTC.» con «Confirmar»; «sin evaluar» debajo; la rejilla a la vista en tres pasos |
| Confirmar la escala y el perfil | p03, p04, p05 | p03, p04, p05 | p03, p04, p05 | «Parámetros del buque» con «No lo tengo» sin marcar (10.15); al marcarlo y «Confirmar y ver el plano», el Plano con «Publicado» y el segmento «Carga» |
| El listado de la agencia | p06, p07 | p06, p07 | p06, p07 | «30 filas en 2 agencias · 20 llenos · 10 vacíos», las tres equivalencias propuestas, el cruce 20 de 20; «1 fila sin entender» por la fila TOTAL, como T-100A; «Listado importado.» |
| Abrir la llegada: publicada sin previo | p08 | p08 | p08 | Con la escala confirmada, `T100_LLEGADA.edi` abre publicada (regla 7.2); «Descarga» y «Carga» en la cabecera; en el muelle, la banda de la marca |
| Descarga: «Baja» | p09, p10 | p09, p10 | p09, p10 | La celda sale en naranja, queda vacía con la palomita y el aviso «Descargado · <contenedor> · 002-02-82» con «Deshacer»; «Descarga 1 de 30 · 3 %», «Por bajar 29 · 9 en la bahía 02»; «En vivo»: «Bajado · Muelle» |
| Otra «Baja» y «Deshacer» | p11, p12 | p11, p12 | p11, p12 | «Deshacer» del aviso anula el movimiento: la celda vuelve a «Baja» y «En vivo» dice «Deshecho · Muelle» |
| «Paso»: la pregunta y la re‑estiba | p13, p14 | p13, p14 | p13, p14 | «<contenedor> no se descarga en GTSTC: va a USMSY…» con «Registrar re‑estiba»; la celda queda «Re‑est.» en naranja; «Re‑estibas 1 · no cuentan entre los que bajan» |
| Carga: asignar un vacío por OR | p15, p16, p17, p18 | p15, p16, p17, p18 | p15, p16, p17, p18 | «Asignar vacío» → «Vacíos del listado» (OR 16 a 30, con su tara) → el formulario propone 010-01-04; la celda la ocupa uno de llegada sin marcar, así que el botón dice «Marcar su descarga y cargar» → «Descarga y carga registradas · OR 16»; «Carga 1 de 30», «Vacíos 1 de 10» |
| Otro vacío y «Deshacer» | p19, p20 | p19, p20 | p19, p20 | El OR vuelve a estar pendiente; «En vivo»: «Deshecho · Muelle» |
| Avance | p21 | p21 | p21 | La tabla por bahía (descarga, llenos, vacíos, cancelados, conflictos, tapas PROVISIONAL, último movimiento) con «Muelle (sin cuenta)» de autor |
| «En vivo» | p22 | p22 | — | El panel con los ocho movimientos (qué, el rol, el contenedor, la celda, «ahora»); en el teléfono no hay panel: el anuncio lo da el lector de pantalla (10.21, H3) |
| Alertas de estiba | p23 | p23 | — | Desde el riel |
| El BAPLIE de salida | p24, p25 | p24, p25, p26 | — | «58 contenedores a bordo en la salida. Pendientes: 29 de carga y 28 de descarga.»; «Comparar con la llegada»: 3 descargados · 1 cargado · 57 permanentes; en la Web, «Guardar BAPLIE de salida» descargó `BayStream_BUQUE MANUAL_M100_salida.edi` (7849 bytes, SMDG22) y avisó «Exportación BAPLIE completada»; en Windows, guardar abre el diálogo del sistema, que el conductor no maneja: queda para el ensayo |
| Atrás | — | — | p22, p23, p24 | Un toque: el aviso «Toca Atrás otra vez para volver al inicio.» (el instrumento lo leyó en el árbol de accesibilidad; dura 2 s y en p22 ya se había apagado: lo que se ve es que el plano sigue); dos toques seguidos: el inicio con el viaje en los recientes (p23); el reciente reabre publicado con la operación (p24) |
| «Más» | p26 | p27 | p25 | La hoja con Alertas primero y «Cerrar el plano» al final |

**Lo que necesita Firebase, anotado para el ensayo** (`LISTA-PILOTO.md`, pasos 1.6, 1.7,
1.11, 1.12, 2.1, 2.2, 2.10, 2.11 y 2.13): iniciar sesión, publicar la operación, unirse
desde el muelle, pedir un cambio, aprobarlo o rechazarlo y la cola sin red. Sin cuenta, la
app no ofrece «Solicitudes de cambio» ni «Bandeja de cambios» (su botón solo existe con una
cuenta autorizada y una operación publicada), así que en los bancos no se recorren; en
memoria lo prueban `t80_requests_widget_test` (el muelle pide, la oficina decide, sin cuenta
no ofrece), `t81_office_widget_test` (mover, cancelar, deshacer y el rol en vivo) y
`t79_sync_engine_test` (la sincronización con el servidor falso), que la suite corre.

**Lo que el recorrido enseñó y se corrigió** está en 9.3; **lo que queda anotado**, en 9.3.

**El emulador** (`t99_api26`, API 26, 360 × 640 dp con `wm density 480`, el muelle de día, la letra a 1.0; el Honor no se tocó) recorre lo mismo hasta el avance y sigue con Atrás y «Más»; no tiene «En vivo» ni alertas en el riel (son de la oficina) y el BAPLIE de salida es de la oficina. Tres cosas que el teléfono bajo enseña y una persona resuelve sin pensar, pero que al conductor le costaron una vuelta cada una: al abrir la llegada desde «Más → Cargar archivo BAPLIE» el destino sigue en la Lista (la banda del muelle con Descarga / Carga se ve igual, y el plano está a un toque en «Plano»); los avisos flotantes de 6 s («Re‑estiba registrada», «Carga registrada») tapan la tira del pie donde están «Acciones» y «OR / últimos dígitos», así que hay que esperar a que se apaguen; y con seis niveles en cubierta, las celdas «Paso» de las filas de abajo quedan bajo el pliegue y se llega a ellas desplazando la rejilla (13.8). Ninguna es un fallo.

### 9.3 Lo que se corrigió y lo que queda anotado

Solo en la capa de presentación (`lib/features/vessel/presentation/**` y
`lib/core/design/**`), cada cosa con su prueba:

1. **Atrás en Android** (9.4): antes la página del viaje no tenía `PopScope`, así que un
   toque en Atrás en el plano salía de la app. Ahora cierra primero lo abierto, pregunta con
   un previo y vuelve al inicio con dos toques.
2. **El chip seleccionado de noche quedaba tinta sobre tinta.** El tema ponía el texto de
   la selección en `secondaryLabelStyle`, que solo usa `ChoiceChip`; `FilterChip` e
   `InputChip` resuelven el color del rótulo por estado. «Solo con cambios» en la
   comparación (1.00:1, el texto invisible: `pantallas/comparar_1920_oscuro_letra1.0.png`
   antes, p25 de Windows después) y los filtros por naviera de la Lista tenían el fallo.
   `bs_tema.dart` resuelve el color del rótulo con `WidgetStateColor`; la prueba mide el
   contraste del rótulo sobre el relleno en `FilterChip`, `ChoiceChip` e `InputChip` en los
   cuatro temas, y la página de comparación de noche pasa `textContrastGuideline`.
3. **«Re‑estiba» en la celda salía cortada** («Re‑esti…»; el conductor lo anotó como texto
   que no cabe en la primera corrida de Windows). La celda escribe ahora «Re‑est.», como la
   tabla de pendientes; la etiqueta accesible sigue diciendo «re‑estiba». Dos pruebas que
   fijaban el rótulo (`t114_componentes_test`, `t75_discharge_test`) se ajustaron sin bajar
   el conteo.
4. **`loadingOperationProvider` usaba `ref` después de un `await` con el viaje ya cerrado**
   (`UnmountedRefException` al salir del plano con dos toques nada más abrirlo). Comprueba
   `ref.mounted` tras cada espera. La prueba de Atrás «dos toques nada más abrir» lo fija.
5. **`pubspec.yaml`** (las dos líneas autorizadas): `version: 3.1.0+4` y
   `msix_version: 3.1.0.0`; `t93_msix_config_test` espera la versión nueva.

**Queda anotado, sin tocar:**

- **El aviso «Archivo … cargado correctamente» (4 s) flota sobre el pie de la página del
  listado**, donde está «Confirmar e importar», y el de «Carga registrada» (6 s) sobre el
  pie de la hoja de los vacíos. Una persona espera a que se apaguen; el conductor, que
  exige que nada tape el control, se detuvo ahí dos veces. No bloquea; la lista del piloto
  lo dice (1.5).
- **En Windows, «Guardar BAPLIE de salida» abre el diálogo del sistema**: el conductor no
  lo maneja, así que se capturó la página y la comparación y el guardado queda para el
  ensayo (en la Web se descargó).
- **Los avisos escriben el número de contenedor sin agrupar** («MNLU0000405 · 002-06-04»)
  mientras la celda, el detalle y «En vivo» lo agrupan («MNLU 000040 5»). Son los textos de
  T-75 y sus pruebas los fijan; cambiarlos es otra tarea.
- **La leyenda de la vista Estado escribe «De paso» dos veces** (la ficha del estado, sin
  cuenta, y «De paso 10» de «Resaltar»). Es el diseño aceptado en la entrega 2.
- **La pauta de contraste dio dos falsos positivos** (9.5): «Tapas: sin declarar» a 360 y
  «BUQUE MANUAL · V114» en la bandeja a 360, con un rectángulo de semántica desplazado de
  lo dibujado; las capturas muestran los dos textos en tinta sobre papel.
- **El número de contenedor en las capturas de prueba de widget** de la Lista sale como un
  rectángulo: la prueba no carga la fuente mono y Flutter dibuja cuadros. En los tres
  clientes se lee (p21 de Windows, la Lista de la Web). No es del producto.
- **El micrófono** (`uses-feature android.hardware.microphone required=false`, 10.112) sigue
  sin declararse: es el manifiesto, fuera de la presentación.
- **TalkBack** no se probó en el Honor; **la letra** del Honor distinta de 1.0 tampoco.

### 9.4 Atrás en Android (`DESIGN.md` 8)

`AtrasDelViaje` (`navegacion_del_viaje.dart`) envuelve la página del viaje, solo en Android
(`defaultTargetPlatform`; en la Web el navegador manda y en Windows no hay botón):

1. **Lo abierto se cierra primero.** Las hojas («Más», el detalle en el teléfono), los
   diálogos y la búsqueda son rutas y las cierra el `Navigator` por su cuenta, antes de
   llegar a la página. El menú del zoom no es una ruta (`MenuAnchor`): mientras está abierto
   se anota en `cerrablesDeAtrasProvider` (un registro de lo abierto con lo que lo cierra) y
   Atrás lo cierra antes que nada. Con panel lateral, Atrás cierra el detalle de la celda.
2. **En la raíz con un previo**, pregunta lo mismo que «Más → Cerrar el plano»: «¿Descartar
   el plano sin confirmar?», con «Seguir mirando» y «Descartar». Atrás sobre la pregunta la
   cierra: es seguir mirando. Se reusa el diálogo que ya existía, para que la pregunta sea
   una sola en toda la app (`DESIGN.md` 8 la llama «¿Cerrar el plano?»; se anota ahí con
   su texto exacto).
3. **En la raíz con el viaje publicado**, vuelve al inicio solo con **dos toques seguidos**:
   el primero avisa «Toca Atrás otra vez para volver al inicio.» (2 s) y el segundo, mientras
   dura el aviso, deja el viaje (lo mismo que «Cerrar el plano»: sigue guardado y se reabre
   desde los recientes con un toque). Un toque por error no saca a nadie del plano. En el
   inicio, Atrás sale de la app como siempre.

**Pruebas** (`test/t114_candidata_atras_test.dart`, 9, con el notifier real y un almacén en
disco; el botón del sistema es `handlePopRoute`): la hoja «Más» se cierra y el viaje sigue;
la hoja del detalle en el teléfono se cierra; el menú del zoom se cierra y se olvida (también
al cerrarlo desde el chip); el detalle del panel lateral se cierra antes que la raíz; con un
previo pregunta, «Seguir mirando» y Atrás sobre la pregunta lo dejan y «Descartar» vuelve al
inicio; publicado, un toque avisa y no sale, pasada la ventana otro toque vuelve a avisar, y
dos seguidos vuelven al inicio con el viaje en los recientes; dos toques nada más abrir el
plano no rompen nada; en el inicio Atrás no se atiende; en Windows no gobierna nada. En el
emulador, el recorrido lo muestra (p22: el plano sigue tras un toque; p23: el inicio con el reciente tras dos; p24: el reciente reabierto).

### 9.5 Las pantallas sin rediseñar con el tema nuevo

Las 19 pantallas que no se rediseñaron (Parámetros, Parámetros del buque, Perfiles
guardados, Viajes recientes, Alertas de estiba, la matriz de segregación, Tapas por bahía,
Tapas en la operación, Orden de descarga, Listado de la agencia, Comparar, Bandeja de
cambios, BAPLIE de salida, Avance, Privacidad, Nube y cuenta, la Lista, Estadísticas y la
búsqueda) se dibujaron con las fuentes del producto, con un plano de llegada sintético con
refrigerados, carga peligrosa, vacíos y 20 pies, a **360 × 800 con la letra a 1.0 y a 2.0**
(el muelle, de día) y a **1920 × 1080 de noche** (la oficina): 57 configuraciones.

- **Ninguna lanza al dibujarse** (un desborde es una excepción): 57 de 57. Lo fija
  `test/t114_candidata_pantallas_test.dart` (3 pruebas, una por configuración).
- **Contraste** (`textContrastGuideline`, 4.5:1): 54 de 57 pasan. De las tres que no: el
  chip «Solo con cambios» de noche (1.00:1) era real y se corrigió (9.3, 2); «Tapas: sin
  declarar» a 360 (3.76) y «BUQUE MANUAL · V114» en la bandeja a 360 (1.36) son falsos
  positivos de la medición (el rectángulo de semántica no coincide con lo dibujado: las
  capturas muestran tinta sobre papel). La comparación de noche pasa ahora la pauta en la
  suite.
- Las 54 capturas y el registro (`registro.tsv`: pantalla, configuración, excepción,
  contraste, detalle) están en `docs/rediseno/fase3/candidata/pantallas/`; las escribe
  `build/t114-candidata/pantallas_test.dart`, fuera de la suite y de Git. «Nube y cuenta» se
  revisó y no se capturó. Textos en inglés: 0 (la suite y el censo de T-112 lo fijan);
  íconos que no se ven: ninguno.

### 9.6 Las versiones propuestas

| Cliente | Publicado (10.113) | Candidata | Por qué |
|---|---|---|---|
| Android (AAB, prueba interna) | 3.0.0, `versionCode` 3 | **3.1.0, `versionCode` 4** | Play rechaza un número repetido |
| Windows (MSIX) | 3.0.0.0 | **3.1.0.0** | Windows solo instala encima si sube |
| Web (Hosting) | 3.0.0 (3) | **3.1.0 (4)** | `version.json` lo deja visible |

Menor y no mayor porque el Sprint 4 no cierra: es una candidata. `pubspec.yaml` dice ya
`version: 3.1.0+4` y `msix_version: 3.1.0.0` (10.112 pedía alinearlo), y `pubspec.lock` no
cambia. Los comandos, con la versión repetida en la línea de comandos como en la guía del
cierre, están en `LISTA-PILOTO.md`, sección 4 (la mezcla, el MSIX con `t93_msix.ps1
-Version 3.1.0.0`, el AAB sin `--no-pub`, la Web con el bloque de T-92 y `firebase deploy
--only hosting`, y cómo volver a la v3.0).

### 9.7 La lista del piloto

`docs/piloto/LISTA-PILOTO.md`: antes del ensayo (versiones, cuentas, el Honor, los
artefactos de la v3.0); el ensayo por rol, la oficina (15 pasos) y el muelle (14 pasos),
cada uno con qué hay que ver y qué hacer si falla, con los rótulos exactos de la app; el día
del piloto; la compilación y la publicación con las versiones nuevas, revisadas contra
`docs/CIERRE-DESPLIEGUE.md` y 10.111 a 10.113 (la configuración de Firebase solo con
`--dart-define-from-file`, sin abrirla; nunca `firebase deploy` a secas); y lo que la
candidata no cubre. Yov la revisa; Carlos la corre.

### 9.8 Los instrumentos

- **`tool/t99_conductor.dart`, escenario `piloto`:** prepara la operación como la oficina
  (el plan de carga por la banda, «Parámetros del buque», «No lo tengo» y «Confirmar y ver
  el plano»; el listado por su página, con `loadBytes`; la llegada, publicada por 7.2) y
  recorre descarga, carga, avance, alertas, el BAPLIE de salida con la comparación y «Más»,
  con toques reales (`_tocar`), trayendo a la vista lo que está en un desplazable
  (`_tocarALaVista`) y apartando los avisos que flotan sobre el pie (`_sinAvisos`) donde una
  persona esperaría. `t114_capturas_windows.ps1` admite `-Listado`.
- **`tool/t114_piloto_web.py`:** el mismo recorrido con Playwright sobre la semántica de
  Flutter; los destinos del riel llevan «Pestaña n de m» detrás del rótulo, así que el
  patrón ancla la primera línea; el botón de confirmar la carga puede decir «Marcar su
  descarga y cargar»; «Guardar BAPLIE de salida» se recoge como descarga del navegador.
- **`tool/t114_piloto_android.py`:** el mismo recorrido con ADB y uiautomator en el
  emulador (el Honor solo con el permiso de Carlos), más Atrás.
- **`tool/t114_primera_windows.py`** (10.27): cada repetición lleva `valida` (`false` con
  reintentos de clic), el resumen cuenta `corridasValidas` y `corridasNoValidas`, y el
  instrumento avisa que se repitan. No se volvió a medir RNF-002: nada de esta candidata
  toca los tres pasos.
- **`build/t114-candidata/pantallas_test.dart`:** las capturas y la pauta de contraste de
  9.5, fuera de la suite.

### 9.9 Validaciones ejecutadas

Un comando de Flutter a la vez (luz verde de 10.28); un cliente a la vez para compilar y
capturar; el Honor no se tocó.

| Qué | Resultado |
|---|---|
| `flutter analyze --no-pub` | **«No issues found»** |
| `flutter test --no-pub` | **1329** pruebas en verde, ninguna omitida (piso 1312 → 1329) |
| `test/t114_candidata_atras_test.dart` | 9 nuevas (9.4) |
| `test/t114_candidata_pantallas_test.dart` | 8 nuevas: tres configuraciones sin excepciones, la comparación de noche con la pauta de contraste, los chips en cuatro temas |
| Pantallas sin rediseñar | 57 configuraciones sin excepción; contraste 54/57 (1 real corregido, 2 falsos positivos) |
| El recorrido | Windows 26 pasos, 0 textos que no caben, 0 errores de Flutter, 0 esperas vencidas; la Web 27 pasos; el emulador 25 pasos |
| Bancos r4 | `%TEMP%\t99-r4-piloto\copia` (`t99_copia.ps1 -Arbol -Sufijo r4`): Windows, la Web (servida en 127.0.0.1:5901) y el APK (`gt.cmartinez.baystream.r4` en `t99_api26`), compilados del árbol con las correcciones |

### 9.10 Archivos

- **`lib/`:** `core/design/bs_tema.dart` (el rótulo del chip por estado),
  `core/design/componentes/bs_celda.dart` («Re‑est.»),
  `features/vessel/presentation/pages/vessel_overview_page.dart` (envuelve con
  `AtrasDelViaje`), `providers/loading_operation_provider.dart` (`ref.mounted`),
  `widgets/navegacion_del_viaje.dart` (`CerrablesDeAtras`, `AtrasDelViaje`),
  `widgets/zoom_del_plano.dart` (se anota al abrirse).
- **`test/`:** nuevas `t114_candidata_atras_test.dart` y `t114_candidata_pantallas_test.dart`;
  ajustadas `t114_componentes_test.dart`, `t75_discharge_test.dart`, `t93_msix_config_test.dart`.
- **`tool/`:** `t99_conductor.dart` (escenario `piloto`), `t114_capturas_windows.ps1`
  (`-Listado`), `t114_primera_windows.py` (`valida`); nuevos `t114_piloto_web.py` y
  `t114_piloto_android.py`.
- **`pubspec.yaml`:** solo `version` y `msix_version`. `pubspec.lock` no cambia.
- **Documentos:** `DESIGN.md` (8: lo que Atrás hace), `docs/piloto/LISTA-PILOTO.md` (nuevo),
  `docs/rediseno/fase3/traspaso-entrega2.md`, este informe, y la evidencia en
  `docs/rediseno/fase3/candidata/` (`pantallas/`, `recorrido/windows/`, `recorrido/web/`,
  `recorrido/emulador/`).
- Sin cambios: `domain/`, `data/`, `lib/main.dart`, los congelados, Firebase, las apps
  instaladas, `C:\Proyectos\baystream-demo17\` y el Honor. Los generados de
  `windows/flutter/` y `test/t114_fase3_correccion_test.dart` figuran modificados solo por
  el fin de línea y no se agregan.

### 9.11 Horas

De ≈ 15:12 (el mensaje que abre el encargo) a ≈ 16:30 del 23-oct-2026: **≈ 1.3 h** de reloj, sin cronómetro. Casi todo fueron esperas en segundo plano, solapadas: cuatro compilaciones del banco r4 de Windows, dos de la Web y dos del APK, tres tandas de la suite completa, y los tres recorridos con sus repeticiones (Windows cuatro, la Web siete, el emulador cuatro), cada repetición por un ajuste del conductor y nunca por la app.

### Git para Carlos (Fase 3, candidata del piloto)

Un `git add` por ruta; la evidencia nueva va por carpeta. `pubspec.yaml` cambia solo en
`version` y `msix_version`; `pubspec.lock`, `domain/`, `data/`, `lib/main.dart` y los
congelados no cambian. El último comando tiene que mostrar **158 files changed**.

```powershell
git add -- lib/core/design/bs_tema.dart
git add -- lib/core/design/componentes/bs_celda.dart
git add -- lib/features/vessel/presentation/pages/vessel_overview_page.dart
git add -- lib/features/vessel/presentation/providers/loading_operation_provider.dart
git add -- lib/features/vessel/presentation/widgets/navegacion_del_viaje.dart
git add -- lib/features/vessel/presentation/widgets/zoom_del_plano.dart
git add -- pubspec.yaml
git add -- test/t114_candidata_atras_test.dart
git add -- test/t114_candidata_pantallas_test.dart
git add -- test/t114_componentes_test.dart
git add -- test/t75_discharge_test.dart
git add -- test/t93_msix_config_test.dart
git add -- tool/t99_conductor.dart
git add -- tool/t114_capturas_windows.ps1
git add -- tool/t114_primera_windows.py
git add -- tool/t114_piloto_web.py
git add -- tool/t114_piloto_android.py
git add -- DESIGN.md
git add -- docs/piloto/LISTA-PILOTO.md
git add -- docs/rediseno/fase3/traspaso-entrega2.md
git add -- docs/rediseno/fase3/candidata/pantallas
git add -- docs/rediseno/fase3/candidata/recorrido/windows
git add -- docs/rediseno/fase3/candidata/recorrido/web
git add -- docs/rediseno/fase3/candidata/recorrido/emulador
git add -- docs/REDISENO-RESULTADOS.md
git commit -m "Sprint 4: candidata del piloto (10.28), Atras en Android, chips legibles de noche, Re-est. en la celda, recorrido del piloto en los tres clientes, pantallas sin redisenar revisadas, versiones 3.1.0 y lista del piloto"
git push
git show --stat --format="%h %s" HEAD | Select-Object -Last 1
```

### Tres líneas

- El piloto se recorrió de punta a punta en Windows, la Web y el emulador con datos
  sintéticos; nada bloqueó, y lo que necesita Firebase queda en la lista del ensayo.
- Atrás en Android hace lo que dice `DESIGN.md` 8 (un toque por error no saca del plano);
  el chip de noche, la celda «Re‑est.» y el provider al cerrar el viaje se corrigieron con
  su prueba; las 19 pantallas sin rediseñar no desbordan a 360 (1.0 y 2.0) ni a 1920 oscuro.
- Suite 1329, `analyze` 0; versiones 3.1.0 (4) / 3.1.0.0 / 3.1.0 (4) en `pubspec.yaml`;
  la lista del piloto en `docs/piloto/LISTA-PILOTO.md`. ALTO: Codex acepta la candidata.

### Mensaje para Yov

Yov: la **candidata del piloto (10.28)** está lista para Codex, en un bloque de git de
158 archivos. **El recorrido:** los tres clientes con el banco r4 y los sintéticos de
T-100, como una persona: Windows 26 pasos (el conductor de T-99 con el escenario `piloto`),
la Web 27 (Playwright; descargó el BAPLIE de salida) y el emulador 25 (adb);
abrir y confirmar, el listado, la llegada publicada por 7.2, Baja / Deshacer / Paso, asignar
vacíos por OR y deshacer, avance, «En vivo», alertas, BAPLIE de salida y comparación, «Más»
y Atrás; capturas numeradas con registro en `docs/rediseno/fase3/candidata/recorrido/`.
Lo que necesita Firebase (sesión, publicar, unirse, pedir y decidir cambios, la cola sin
red) no se recorrió: lo cubren T-79, T-80 y T-81 en memoria y la lista del ensayo.
**Corregido** (presentación, con prueba): Atrás en Android como `DESIGN.md` 8
(`AtrasDelViaje`: cierra lo abierto, pregunta con un previo, dos toques para salir del
plano publicado; 9 pruebas); el chip seleccionado de noche, que era tinta sobre tinta
(`FilterChip` no usa `secondaryLabelStyle`: «Solo con cambios», los filtros por naviera);
«Re‑est.» en la celda (la palabra entera salía cortada); `loadingOperationProvider` con
`ref.mounted`. **Las pantallas sin rediseñar:** 19 pantallas × 3 configuraciones (360 con
1.0 y 2.0, 1920 oscuro) sin una sola excepción; contraste 54/57 (1 real, corregido; 2
falsos positivos de la pauta, explicados). **Versiones:** Android 3.1.0 (4), MSIX 3.1.0.0,
Web 3.1.0 (4); `pubspec.yaml` lleva `version: 3.1.0+4` y `msix_version: 3.1.0.0`, nada más
en `pubspec.*`. **La lista:** `docs/piloto/LISTA-PILOTO.md`, por rol, con los comandos de la
guía del cierre y la versión nueva, y cómo volver a la v3.0. **Cifras:** suite 1329
(piso 1312), `analyze` 0. **Anotado:** los avisos de 4 y 6 s tapan el pie del listado y de
la hoja de vacíos (una persona espera); en Windows guardar el BAPLIE de salida abre el
diálogo del sistema (queda para el ensayo); los avisos escriben el número sin agrupar
(textos de T-75); el micrófono del manifiesto (10.112) sigue sin declararse. Además,
`t114_primera_windows.py` marca como no válidas las corridas con reintentos (10.27). Me
detengo: **ALTO: Codex acepta la candidata.**

## Fase 3 · Candidata del piloto · Corrección tras la aceptación de Codex (23-oct-2026)

Codex no aceptó la candidata (`docs/rediseno/fase3/candidata/aceptacion-codex.md`; decisión 10.29) por dos
fallos del muelle: **H1**, Atrás usaba la cola de avisos como reloj (con un aviso de movimiento de 6 s en
pantalla, la advertencia «toca otra vez para salir» quedaba formada detrás, la ventana de 2 s dependía de
cuándo se apagaba ese aviso y el segundo toque intentaba cerrar un aviso que no era el primero de la cola:
en pruebas, `_snackBars.first == controller`); y **H2**, los avisos flotantes tapaban los controles del
muelle (el de 6 s, «Acciones», «OR / últimos dígitos» y el pie de la hoja de los vacíos; el de 4 s,
«Confirmar e importar»). También pidió rehacer cuatro capturas de las pantallas sin rediseñar. Esta
sección corrige las tres cosas en un bloque aparte, sin agregar funciones. Paso 0: la candidata
(`e78035d`) y el dictamen con la decisión 10.29 (`3fb6d4c`) están en commits; en el árbol solo quedaban
los tres generados de `windows/flutter/` y `test/t114_fase3_correccion_test.dart` con el fin de línea
cambiado, que no son de nadie y no se tocan.

### 10.1 Resultado en tres líneas

- H1: la ventana de 2 s se cuenta desde el primer toque con su propio reloj (un `Timer` que se cancela
  al salir o al desmontarse) y la advertencia es una tarjeta propia, arriba, que no entra en la cola de
  avisos: se ve aunque esté el aviso de 6 s de un registro, ese aviso con su «Deshacer» sigue su curso y
  ningún aviso ajeno se cierra. Cuatro pruebas nuevas con avisos de 4 y 6 s en cola: dos toques dentro de
  2 s salen; dos separados por más de 2 s no; sin excepciones.
- H2: los avisos de la página del viaje flotan **por encima de la fila de controles** de la barra de la
  operación (el modo, el zoom, «Acciones», «OR / últimos dígitos»), sobre las cifras, que no se tocan, y
  nunca sobre la rejilla: la fila mide su alto y la página lo pone como aire del tema de `SnackBar`. Todo
  lo que se toca en el muelle sigue tocable mientras dura el aviso y «Deshacer» queda a mano todo su
  plazo; en el listado de la agencia, «Descartar» y «Confirmar e importar» van al pie fijo de la página.
  Cinco pruebas nuevas con las fuentes reales, y el tramo del muelle repetido en el emulador sin esperar a
  que se apaguen los avisos: dos cargas por OR seguidas y dos «Baja» seguidas.
- Las 54 capturas de las pantallas sin rediseñar se rehicieron dibujando cada página dentro de `runAsync`:
  ninguna trae ya el indicador de carga, y la comparación de noche sale con el chip corregido. Suite
  **1338** (piso 1329; ninguna omitida), `analyze` **«No issues found»**. **ALTO: Codex acepta la
  corrección de la candidata.**

### 10.2 H1 · Atrás con su propio reloj y una advertencia aparte

Antes, el primer toque guardaba el controlador que devolvía `showSnackBar` y «había ventana» mientras ese
controlador no se cerrara; el segundo toque hacía `close()` sobre él. Con otro aviso delante, el de Atrás
quedaba formado detrás (la ventana duraba lo que tardara en apagarse el anterior más los 2 s propios),
`close()` sobre un aviso que no es el primero de la cola rompe la aserción del `ScaffoldMessenger`, y en
Release esa rama podía sacar del viaje con dos toques separados por más de 2 s y apagar el «Deshacer».

Ahora `AtrasDelViaje` (`navegacion_del_viaje.dart`) no usa la cola de avisos:

- **El reloj** es un `Timer` de `AtrasDelViaje.ventana` (2 s) que arranca en el primer toque; mientras
  existe, el siguiente toque lo cancela y vuelve al inicio (`onVolverAlInicio`); al vencer, la advertencia
  se va y el siguiente toque vuelve a advertir. Se cancela al desmontarse, así que ninguna prueba deja un
  `Timer` pendiente.
- **La advertencia** es `_AdvertenciaDeAtras`: una tarjeta con los colores, el borde y la letra del tema de
  `SnackBar` (así se ve como un aviso de la app), centrada arriba bajo la barra de estado, de hasta 560 dp
  de ancho, dentro de un `Stack` con `StackFit.passthrough` sobre el `Scaffold` (no cambia nada del
  layout), con `IgnorePointer` (el toque la atraviesa) y `Semantics(liveRegion: true)` (el lector de
  pantalla la anuncia). Entra con un fundido de opacidad de 150 ms, quieto con reducción de movimiento.
  Va arriba y no al pie porque al pie van los avisos del registro y la franja de la operación (H2): así se
  ve a la vez que cualquiera de ellos y no tapa ningún control.
- **La cola de avisos no se toca:** el aviso del movimiento, con su «Deshacer», sigue su curso; nada llama
  a `close()` ni a `hideCurrentSnackBar()` desde Atrás.

**Pruebas** (`test/t114_candidata_atras_test.dart`, de 9 a 13): con un aviso de movimiento de 6 s con
«Deshacer» en pantalla, un toque muestra la advertencia **a la vez** que ese aviso (la tarjeta arriba, el
aviso abajo, sin pisarse), «Deshacer» sigue, y el segundo toque sale sin excepción; con un aviso de 4 s y
otro de 6 s en cola (el caso de Codex más el de «cargado correctamente»), dos toques separados por 3 s no
salen y la advertencia vuelve a avisar; con los mismos dos avisos en cola, dos toques dentro de 2 s salen;
y la advertencia no recibe toques y es región en vivo con su texto. Las nueve de antes siguen igual. La
reproducción de Codex (`atras-cola_test.dart.txt`) no se tocó; su caso es el segundo de los nuevos.

### 10.3 H2 · Los avisos flotan por encima de los controles de la franja

El `SnackBar` se dibuja al pie del cuerpo del `Scaffold`; la franja de la operación (`BsBarraDeOperacion`:
las cifras y, debajo, la fila con la acción y, en el teléfono bajo, el modo, el zoom, «Acciones» y «OR /
últimos dígitos») está dentro del cuerpo, al pie del plano, así que el aviso le caía encima (capturas p14 a
p19 del emulador en la candidata). La corrección es una sola regla para toda la página, en vez de un
margen por aviso:

- **Lo que no se tapa se mide.** `MideElPieDelPlano` (`avisos_del_viaje.dart`, nuevo) envuelve, en
  `BayPlanView`, la fila de controles de la barra de la operación (con el aire de abajo de la barra) en el
  muelle operando, o la leyenda entera si no se opera (es toda controles), con un `RenderProxyBox` que,
  después de cada cuadro en que su alto cambia, lo anota en `pieDelPlanoProvider`. Nunca durante el layout.
- **La página pone el aire.** `AvisosSobreElPie` envuelve el `Scaffold` de la página del viaje (dentro de
  `AtrasDelViaje`) y copia el tema con `snackBarTheme.insetPadding = (16, 4, 16, 8 + lo medido)`, solo con
  el Plano a la vista (`conPlano: destino == plano`); en la Lista, el Avance y las estadísticas no hay
  franja y el aviso va donde siempre. Vale para todo aviso que salga en la página (el registro con
  «Deshacer», «Deshecho», «cargado correctamente», los errores), sin tocar cada `showSnackBar`; los cuatro
  avisos de la página que traían `margin: EdgeInsets.all(16)` lo pierden para que mande el tema.
- **Dónde queda:** sobre las cifras de la barra (que no se tocan y que el propio aviso explica: «Descargado
  · … · 002-02-82»), con aire sobre la fila de controles, y **nunca sobre la rejilla**. El primer intento
  de esta noche lo puso por encima de la barra entera, entre la rejilla y la franja, como dibuja el lienzo
  de 13.8; el emulador enseñó el problema antes que las pruebas: en el teléfono bajo, con la silueta a la
  vista, el aviso cubría la única fila de celdas y la segunda «Baja» del recorrido cayó sobre el aviso
  (sobre su «Deshacer»: la primera descarga quedó deshecha). Para Descarga, donde se toca una celda tras
  otra, eso era peor que el fallo original. Las once capturas de ese intento quedan en
  `docs/rediseno/fase3/candidata/correccion/emulador-intento-1/` (p10: el aviso sobre la fila; p11: la
  descarga deshecha). La ranura `aviso` de `BsBarraDeOperacion` sigue sin usarse: un aviso dentro de la
  barra la haría crecer y movería la rejilla bajo el dedo.
- **Las hojas** («Vacíos del listado», el detalle) y los diálogos son rutas del `Navigator`, por encima
  del `Scaffold`: el aviso queda detrás de ellas y su pie («Cerrar», la última fila) nunca se tapa. Lo que
  el conductor de Windows apartaba antes de tocar «Asignar vacío» (`_sinAvisos()`, «el pie de la hoja de
  los vacíos») era en realidad el control de la franja; la hoja no estaba abierta.
- **El listado de la agencia** (`export_list_import_page.dart`): «Descartar» y «Confirmar e importar»
  pasan al pie fijo del `Scaffold` (`persistentFooterButtons`), solo mientras hay un listado leído sin
  confirmar. Siempre a la vista, sin desplazar la lista, y el aviso «Archivo … cargado correctamente»
  (4 s) flota por encima. El texto «Falta elegir N equivalencias» sigue al final de la lista.

**Pruebas** (`test/t114_candidata_correccion_test.dart`, nuevo, 5; con las fuentes del producto cargadas,
porque con la fuente cuadrada de las pruebas el aviso de dos líneas con «Deshacer» mide 153 dp y la
franja 146, el doble que con Plex): en Carga, en el teléfono bajo (el plano anidado, los controles en la
franja), la medida es la fila de controles más el aire de la barra y el tema de la página lleva ese aire;
la primera carga por OR deja el aviso entero por encima de la fila de controles y sin pisar ninguna celda
(`cell-*`); con el aviso en pantalla «Acciones» abre su menú y la segunda carga por OR sale sin esperar;
«Deshacer» responde a los 5 s. En Descarga, dos «Baja» seguidas, cada una con su aviso por encima de los
controles y fuera de las celdas, y el modo sigue al alcance. La hoja de los vacíos abre con un aviso de
6 s detrás y su «Cerrar» responde sin apagarlo. La página real del viaje (Android, 360 × 640, el plan de
carga publicado): el aviso de la página flota por encima de los controles con «Acciones» y «OR / últimos
dígitos» a la vista; en la Lista baja a su sitio de siempre; de vuelta al Plano la medida vuelve. Y el
listado a 360 × 640: sin listado no hay pie; con uno leído, los dos botones están en el pie fijo (fuera de
la lista) y el aviso de 4 s flota por encima sin pisarlos. La prueba de T-73 a 360 dp se ajustó
(`t73_export_list_page_test.dart`, sin bajar el conteo): el pie fijo le quita unos 60 dp a la lista y las
equivalencias se traen a la vista antes de leerlas.

### 10.4 Las cuatro capturas de las pantallas sin rediseñar

`build/t114-candidata/pantallas_test.dart` (fuera de la suite y de Git) dibujaba cada página fuera de
`runAsync`, así que las que leen el almacén en disco al abrirse (Perfiles guardados, Viajes recientes,
Tapas en la operación) se quedaban con el indicador de carga en la primera configuración y su registro
decía «pumpAndSettle timed out»; la comparación de noche era de antes de corregir el chip. Ahora cada
página se dibuja dentro de `runAsync` (la pauta de contraste sigue fuera, porque llama a `runAsync` por su
cuenta) y el registro anota «indicador de carga» si quedara uno. Se regeneraron las 54: **cambian cinco**
(las tres del indicador, ahora con su contenido; `comparar_1920_oscuro`, con «Solo con cambios» legible;
y `parametros_360_claro_letra1.0`, cuyo desplegable del tema sale ya cargado, en tinta y no apagado) y
**las otras 49 son byte a byte las mismas** (`build/t114-candidata-correccion/pantallas-antes.sha256`
guarda las huellas de antes). El registro queda: 57 configuraciones, **0 excepciones, 0 indicadores de
carga**, contraste **55 de 57** (los dos que no pasan son los falsos positivos ya explicados en 9.5:
«Tapas: sin declarar» y «BUQUE MANUAL · V114» a 360). Las cifras del informe de la candidata (9.5) decían
54 de 57 con la comparación de noche sin pasar; con la captura rehecha son 55 de 57.

### 10.5 El tramo del muelle, repetido en el emulador

`tool/t114_piloto_android.py` ya no espera a que se apaguen los avisos (`sin_aviso()` desaparece): exige
que el aviso con «Deshacer» **siga en pantalla** (`con_aviso()`) antes de tocar «Acciones», captura el menú
abierto con el aviso debajo y hace la segunda carga por OR sin esperar. Atrás se prueba ahora con el aviso
de una «Baja» recién registrada: un toque, y la advertencia arriba con el aviso y su «Deshacer» abajo, a
la vez; pasados 3.5 s otro toque vuelve a advertir y el plano sigue (si el inicio apareciera, el
instrumento falla); y dos toques seguidos vuelven al inicio. El recorrido entero (el inicio, el plan de
carga por la interfaz, el listado, la llegada, Descarga, Carga, el avance, Atrás, el reciente y «Más») se
repitió en `t99_api26` (360 × 640 dp, el muelle de día, la letra a 1.0) con el APK r4 compilado de este
árbol (`%TEMP%\t99-r4-corr-candidata\copia`, `flutter build apk --release -t tool/t99_main.dart`), con los
sintéticos de T-100; el Honor no se tocó. **Hicieron falta cuatro intentos: el primero, con el anclaje sobre la barra entera, se detuvo en el paso 12 y enseñó el problema de la rejilla (10.3); el segundo completó los 28 pasos ya con el anclaje definitivo, pero sus capturas de los estados de 2 y 6 s llegaron tarde; el tercero se detuvo en el paso 19 por una comprobación mal puesta del instrumento; el cuarto, el definitivo, completó los **27 pasos sin un solo fallo**, con las capturas al instante.** Las capturas numeradas, con su registro,
están en `docs/rediseno/fase3/candidata/correccion/emulador/` (`pNN-*.png`, `registro.tsv`); ninguna
muestra «Nube y cuenta», un correo ni el corpus.

| Paso | Captura | Qué se ve |
|---|---|---|
| «Baja» y otra «Baja», sin esperar | p10, p11 | «Descargado · … · 002-02-82» con «Deshacer» sobre las cifras de la barra; la fila de controles («Descarga ▾», el zoom, «Acciones», «Pendientes…») y las celdas a la vista; la segunda «Baja» registra con el aviso de la primera en pantalla |
| La re‑estiba y el cambio a Carga | p14, p15 | «Re‑estiba registrada» sobre las cifras; el modo Carga abre con ese aviso todavía en pantalla y los controles libres |
| La primera carga por OR | p18 | «Descarga y carga registradas · OR 16» con «Deshacer», sobre las cifras; la celda en naranja |
| La segunda carga, sin esperar | p19, p20 | «Acciones» abierto con el aviso de la primera carga detrás, a la vista; después, «… · OR 17» |
| Atrás con el aviso de una «Baja» | p23 | la advertencia arriba y el aviso con «Deshacer» abajo, a la vez; el plano sigue |
| Otro toque pasados más de 2 s | p24 | la advertencia otra vez y el plano sigue: no sale |
| Dos toques seguidos | p25, p26 | el inicio con el viaje en los recientes; el reciente reabre publicado |

Los estados que duran 2 y 6 s se capturan al instante, con las coordenadas de «Carga» y «Acciones»
tomadas antes del registro: cada volcado de uiautomator tarda cerca de un segundo y, en el segundo
intento de la noche (28 pasos completos ya con el anclaje definitivo; sus capturas no se versionan
porque el recorrido final las sustituye), las capturas tomadas tras dos volcados ya no mostraban el
aviso ni la advertencia. Un tercer intento se detuvo en el paso 19 por una comprobación mal puesta del
instrumento: con el menú «Acciones» abierto, su barrera oculta al lector lo que queda debajo y
«Deshacer» no aparece en el volcado aunque se vea; la comprobación se hace ahora antes de abrir el
menú.

### 10.6 Los instrumentos

- `tool/t114_piloto_android.py`: `con_aviso()` en lugar de `sin_aviso()`, las dos capturas de «Acciones»
  con el aviso y el tramo nuevo de Atrás (10.5).
- `build/t114-candidata/pantallas_test.dart` (fuera de Git): cada página dentro de `runAsync` y la
  columna de excepción anota «indicador de carga» (10.4).
- El conductor de Windows (`tool/t99_conductor.dart`, escenario `piloto`) **no cambia**: conserva sus tres
  `_sinAvisos()`. Dos de ellos (antes de «Confirmar e importar» y de «Asignar vacío») ya no hacen falta y
  el tercero (antes del BAPLIE de salida, en la Lista) sigue siendo necesario porque en la Lista no hay
  pie y el aviso va al pie. Retirarlos y repetir el recorrido de Windows es una vuelta de instrumentos que
  no toca el producto; queda anotada (10.9).

### 10.7 Validaciones ejecutadas

Un comando de Flutter a la vez, con la luz verde de 10.29; un cliente a la vez para compilar y capturar;
el Honor (`AJ5TBB6531101024`, también conectado) no se tocó: cada orden de `adb` lleva `-s emulator-5554`.

| Qué | Resultado |
|---|---|
| `flutter analyze --no-pub` | **«No issues found»** (`build/t114-candidata-correccion/analyze-2.txt`) |
| `flutter test --no-pub` | **1338** pruebas en verde, ninguna omitida (piso 1329 → 1338; `suite-2.txt`) |
| `test/t114_candidata_atras_test.dart` | 13 (9 + 4 nuevas de H1) |
| `test/t114_candidata_correccion_test.dart` | 5 nuevas de H2, con las fuentes del producto |
| `test/t73_export_list_page_test.dart` | ajustada al pie fijo, mismas aserciones |
| `build/t114-candidata/pantallas_test.dart` | 57 configuraciones: 0 excepciones, 0 indicadores de carga, contraste 55/57; 5 PNG cambian, 49 idénticos |
| `tool/t114_piloto_android.py` | **27 pasos, 0 fallos** (cuarto intento; `build/t114-candidata-correccion/emulador-corrida-4.log`); el primer intento, 11 pasos y el fallo de la rejilla (`correccion/emulador-intento-1/salida.txt`) |
| Banco r4 | `%TEMP%\t99-r4-corr-candidata\copia` (`t99_copia.ps1 -Arbol -Sufijo r4 -Entradas …`), APK `gt.cmartinez.baystream.r4` instalado encima en `t99_api26` |

No se repitieron RNF-002, la RAM, la auditoría ni los censos: nada de esta corrección toca los tres
pasos, las listas ni añade textos nuevos salvo los de las pruebas; el único texto visible nuevo no existe
(la advertencia de Atrás conserva su frase). Windows y la Web no se recompilaron (10.6).

### 10.8 Archivos

- **`lib/` (solo presentación):** nuevo
  `features/vessel/presentation/widgets/avisos_del_viaje.dart` (`pieDelPlanoProvider`,
  `MideElPieDelPlano`, `AvisosSobreElPie`); modificados
  `widgets/navegacion_del_viaje.dart` (H1: el `Timer` y `_AdvertenciaDeAtras`),
  `pages/vessel_overview_page.dart` (`AvisosSobreElPie` dentro de `conAtras`; cuatro avisos sin
  `margin`), `widgets/bay_plan_view.dart` (el pie dentro de `MideElPieDelPlano`),
  `pages/export_list_import_page.dart` (`persistentFooterButtons`).
- **`test/`:** nuevo `t114_candidata_correccion_test.dart`; modificados `t114_candidata_atras_test.dart`
  (+4) y `t73_export_list_page_test.dart` (ajuste).
- **`tool/`:** `t114_piloto_android.py`.
- **Documentos:** `DESIGN.md` (8: la advertencia propia y su reloj; 13.8: dónde flotan los avisos),
  `docs/rediseno/fase3/traspaso-entrega2.md`, este informe, y la evidencia nueva en
  `docs/rediseno/fase3/candidata/correccion/emulador/` y las cinco capturas rehechas con su registro en
  `docs/rediseno/fase3/candidata/pantallas/`.
- Sin cambios: `domain/`, `data/`, `lib/main.dart`, los congelados, `pubspec.yaml`, `pubspec.lock`,
  Firebase, las apps instaladas, «PRUEBA T-105», `C:\Proyectos\baystream-demo17\`,
  `docs/piloto/LISTA-PILOTO.md` y el Honor. Los generados de `windows/flutter/` y
  `test/t114_fase3_correccion_test.dart` siguen figurando modificados solo por el fin de línea y no se
  agregan.

### 10.9 Lo que queda anotado y lo que Carlos decide

1. **El aviso cubre durante su plazo las cifras de la barra** («29 por bajar · 1 hecha · 0
   re‑estibas») y, en el teléfono bajo, la línea del resumen (10.3). Es el precio de no tapar ni una
   celda ni un control; el propio aviso dice qué pasó. Si en el piloto molesta, la alternativa es
   acortar el texto del aviso (hoy el número de contenedor va sin agrupar y parte en dos líneas: ya
   anotado en 9.3) o usar la ranura `aviso` de `BsBarraDeOperacion` reservándole sitio fijo, que cuesta
   56 dp de rejilla en el teléfono bajo. La decisión 10.29 pedía los avisos «fuera de la franja de
   operación»: quedan fuera de todo lo que se toca en ella; sobre sus cifras, no. Carlos decide si eso
   basta o si se reserva el sitio fijo.
2. **El conductor de Windows conserva `_sinAvisos()`** (10.6); retirarlos y repetir el recorrido es una
   vuelta de instrumentos aparte.
3. **La advertencia de Atrás va arriba.** Android acostumbra el «toca otra vez» abajo, pero abajo están
   la franja y los avisos; arriba no tapa ningún control. Si Carlos la prefiere en otro sitio, es un
   `Alignment` en `_AdvertenciaDeAtras`.
4. **`pieDelPlanoProvider` guarda la última medida** y la página decide cuándo aplica (`conPlano`):
   Riverpod 3.1 no permite `ref` en `dispose`, y un post-frame que escribiera en el provider cuando el
   contenedor ya no existe lanzaría. Está escrito en el código.
5. **Las capturas de las pantallas sin rediseñar cambian cinco, no cuatro:** la de Parámetros a 360
   sale ahora con el desplegable del tema cargado (antes, apagado mientras leía el almacén). Es la misma
   causa que las tres del indicador.

### 10.10 Horas

De ≈ 17:30 (el mensaje que abre el encargo) a ≈ 18:50 del 23-oct-2026: **≈ 1.3 h** de reloj.
Leer el dictamen, la reproducción y el código; H1 y H2 con sus pruebas (dos vueltas por la fuente de las
pruebas y por `ref` en `dispose`); la suite tres veces (una delató el ajuste de T-73); las capturas; el
banco r4, dos APK y cuatro recorridos del emulador; los documentos.

### Git para Carlos (Fase 3, candidata del piloto, corrección)

Un `git add` por ruta; la evidencia nueva va por carpeta y las cinco capturas rehechas con su registro,
por su carpeta también (solo cambian esas seis rutas dentro de `pantallas/`). `pubspec.*`, `domain/`,
`data/`, `lib/main.dart`, los congelados y `docs/piloto/LISTA-PILOTO.md` no cambian. El último comando
tiene que mostrar **59 files changed**.

```powershell
git add -- lib/features/vessel/presentation/widgets/avisos_del_viaje.dart
git add -- lib/features/vessel/presentation/widgets/navegacion_del_viaje.dart
git add -- lib/features/vessel/presentation/widgets/bay_plan_view.dart
git add -- lib/features/vessel/presentation/pages/vessel_overview_page.dart
git add -- lib/features/vessel/presentation/pages/export_list_import_page.dart
git add -- test/t114_candidata_correccion_test.dart
git add -- test/t114_candidata_atras_test.dart
git add -- test/t73_export_list_page_test.dart
git add -- tool/t114_piloto_android.py
git add -- DESIGN.md
git add -- docs/rediseno/fase3/traspaso-entrega2.md
git add -- docs/rediseno/fase3/candidata/pantallas
git add -- docs/rediseno/fase3/candidata/correccion/emulador
git add -- docs/rediseno/fase3/candidata/correccion/emulador-intento-1
git add -- docs/REDISENO-RESULTADOS.md
git commit -m "Sprint 4: correccion de la candidata del piloto (10.29), Atras con reloj propio y advertencia aparte, los avisos flotan por encima de la franja del muelle y del pie del listado, capturas rehechas y el muelle repetido en el emulador"
git push
git show --stat --format="%h %s" HEAD | Select-Object -Last 1
```

### Tres líneas

- H1: la ventana de Atrás es un reloj propio de 2 s desde el primer toque y la advertencia una tarjeta
  aparte, arriba, fuera de la cola de avisos: se ve con el aviso de movimiento delante, no cierra ningún
  aviso ajeno y «Deshacer» sigue; cuatro pruebas con avisos de 4 y 6 s en cola.
- H2: los avisos de la página flotan por encima del pie del plano (el pie mide su alto, la página lo pone
  como aire del tema de `SnackBar`) y «Confirmar e importar» va al pie fijo del listado; cinco pruebas con
  las fuentes reales y el muelle repetido en el emulador con dos cargas seguidas sin esperar.
- Las cinco capturas rehechas (0 indicadores de carga, contraste 55/57); suite 1338, `analyze` 0. ALTO:
  Codex acepta la corrección de la candidata.

### Mensaje para Yov

Yov: la **corrección de la candidata (10.29)** está escrita, probada y repetida en el emulador, en un
bloque aparte de 59 archivos. **H1:** `AtrasDelViaje` ya no usa `showSnackBar`: la ventana es un
`Timer` de 2 s desde el primer toque (se cancela al salir y al desmontarse) y la advertencia es
`_AdvertenciaDeAtras`, una tarjeta con los colores del tema de `SnackBar`, arriba bajo la barra de
estado, `IgnorePointer` y región en vivo, sobre un `Stack` con `passthrough`; la cola de avisos no se
toca, así que el «Deshacer» del movimiento sigue y nada cierra un aviso que no sea el primero. Cuatro
pruebas nuevas: con el aviso de 6 s delante, la advertencia se ve a la vez y dos toques salen; con 4 s y
6 s en cola, dos toques separados por 3 s no salen (el caso de Codex) y dos dentro de 2 s sí; sin
excepciones. **H2:** una regla para toda la página: la fila de controles de la barra de la operación (o la
leyenda entera, sin operación) se mide (`MideElPieDelPlano` → `pieDelPlanoProvider`, en
`avisos_del_viaje.dart`) y `AvisosSobreElPie` envuelve el `Scaffold` con `snackBarTheme.insetPadding =
8 + lo medido` solo con el Plano a la vista; los avisos flotan sobre las cifras de la barra, por encima
del modo, el zoom, «Acciones» y «OR», y nunca sobre la rejilla; los cuatro `margin` explícitos de la
página se quitaron. El primer intento los puso sobre la barra entera y el emulador enseñó que, con la
silueta a la vista, tapaban la única fila de celdas y la segunda «Baja» caía sobre «Deshacer»
(`correccion/emulador-intento-1/`, p10 y p11): se cambió el anclaje antes de seguir. En el listado,
«Descartar» y «Confirmar e importar» van a `persistentFooterButtons`. Las hojas son rutas y quedan por
encima de los avisos (lo que el conductor apartaba era la franja, no la hoja). Cinco pruebas con las
fuentes reales (con Ahem el aviso mide 153 dp): dos cargas por OR seguidas sin esperar con «Acciones»
abierto bajo el aviso, dos «Baja» seguidas con las celdas libres, la hoja con un aviso detrás, la página
real a 360 × 640 y el listado. A cambio, el aviso cubre esos segundos las cifras de la barra (anotado; la
decisión pedía «fuera de la franja» y queda fuera de todo lo que se toca en ella). **Emulador:**
el tramo del muelle repetido en `t99_api26` con el APK r4 de este árbol, 27 pasos sin fallos: p10–p11, dos «Baja» seguidas con el aviso sobre las cifras y las celdas libres; p15, el modo Carga con el aviso de la re‑estiba aún en pantalla; p19, «Acciones» abierto con el aviso de la primera carga detrás, y p20 la segunda carga sin esperar; p23, Atrás con el aviso de una «Baja»: la advertencia arriba y el aviso con «Deshacer» abajo, a la vez; p24, otro toque pasados más de 2 s vuelve a advertir y el plano sigue; p25–p26, dos toques seguidos al inicio y el reciente reabre. El primer intento (el anclaje sobre la barra entera) queda en `correccion/emulador-intento-1/` como la razón del cambio. **Capturas:** las 54 regeneradas dentro de `runAsync`; cambian cinco (las tres del indicador,
la comparación de noche y Parámetros, cuyo desplegable sale cargado), 49 idénticas byte a byte; 0
indicadores, contraste 55/57. **Cifras:** suite 1338 (1329 + 9), `analyze` 0; `pubspec.*`, `domain/`,
`data/` y la lista del piloto sin tocar; Windows y la Web no se recompilaron y el conductor de Windows
conserva sus `_sinAvisos()` (anotado). `DESIGN.md` 8 y 13.8 dicen lo nuevo. Me detengo: **ALTO: Codex
acepta la corrección de la candidata.**

## Fase 3 · Candidata del piloto · Segunda corrección (letra 2.0) (23-oct-2026)

Codex volvió a aceptar la corrección (`docs/rediseno/fase3/candidata/reaceptacion-codex.md`; decisión
10.31) y no pasó por **H2 con la letra a 2.0**: en el teléfono bajo (360 × 640) el aviso de 6 s con
«Deshacer» medía 328 × 196 dp, iba de y=296 a y=492 y pisaba 4 dp de tres celdas del nivel 88, en
Descarga y en Carga. La regla de la corrección anterior medía la fila de controles y ponía el aviso
encima, pero nada acotaba su borde de arriba. Dejó además tres observaciones P3: **O1** (Atrás que
cierra otra cosa dejaba abierta la ventana de 2 s), **O2** (el instrumento de Android ya no comprobaba
en positivo el plano y la advertencia) y O3 (la oficina, que queda para COMAR y no se toca). Esta
sección corrige H2, O1 y O2 en un bloque aparte, sin agregar funciones. Paso 0: arriba, `81f4bc9` con
la decisión 10.31; en el árbol solo los tres generados de `windows/flutter/` y
`test/t114_fase3_correccion_test.dart` con el fin de línea cambiado, que no son de nadie y no se tocan.
Semáforo: Codex había terminado; solo este chat usó Flutter y el emulador, un comando a la vez.

### 11.1 Resultado en tres líneas

- H2: el aviso de la página vive en la franja, **entre el borde de arriba de la barra de la operación
  (donde termina la rejilla) y su aire sobre los controles**, por construcción: la página mide los dos
  bordes y cada aviso de la página (`avisoDelViaje`) sabe cuánto alto tiene, muestra su texto entero si
  cabe o, si no, uno corto que sigue diciendo qué pasó, y nunca pasa de ese borde. Compacto, con
  «Deshacer» al lado del texto, a la letra del sistema y sin sitio reservado (10.30 intacta). La matriz
  de Codex (2 teléfonos × 3 letras × 2 modos) pasa entera, con el aviso más largo de la página y la
  oficina a 1920.
- O1: lo que se abre o se cierra en medio (el zoom, el detalle, una hoja, un diálogo) cancela la ventana
  de Atrás; el siguiente toque en la raíz vuelve a advertir. O2: tras cada Atrás, el instrumento exige en
  un mismo volcado, dentro de los 2 s, la advertencia, el plano y (con la Baja) «Deshacer».
- Suite **1359** (piso 1338; 21 nuevas, ninguna omitida), `analyze` **«No issues found»**, el muelle
  completo en el emulador: 27 pasos sin fallos con la letra a 1.0. **ALTO: Codex acepta la segunda corrección.**

### 11.2 H2 · El aviso no pasa del borde de arriba de la franja

**Lo que fallaba, medido.** Además de lo que vio Codex a 360 × 640, la misma regla fallaba a
412 × 915 (no anidado, sin resumen sobre la barra, así que el lugar para el aviso son solo las cifras):
con la letra a 1.45 el aviso de Descarga pisaba 6 dp de cuatro celdas, y con 2.0, 13 dp en Descarga y
26 dp en Carga; con 1.0 ya pasaba 6 dp por encima de la barra, sin celdas debajo en ese plan. Y el aviso
más largo de la página (T-61, 10 s, al reabrir un viaje) subía sobre la rejilla con cualquier letra:
86 dp a 1.45 y 214 dp a 2.0 en 360 × 640. En el Honor (360 × 800, que con la letra a 1.0 no va anidado)
pasaba lo mismo que a 412 × 915: 6 dp por encima de la barra con 1.0 y cuatro celdas pisadas con 1.45. Las capturas `antes-*.png` y `antes.jsonl` de
`docs/rediseno/fase3/candidata/correccion2/geometria/` lo muestran (con el aviso como lo hacía la
página, sobre la regla de `81f4bc9`).

**Por qué no bastaba un aviso «más compacto».** Con la letra a 2.0 el lugar que la 10.30 deja al aviso
(las cifras de la barra) mide 117 dp a 412 × 915 en Descarga, y el aviso de un registro con el número
del contenedor, la celda y «Deshacer» necesita tres líneas más su relleno: no cabe con ningún relleno.
Hacía falta que el aviso supiera cuánto alto tiene y eligiera qué decir.

**La regla nueva** (`avisos_del_viaje.dart`, `DESIGN.md` 13.8):
- **Los dos bordes se miden.** Además de la fila de controles (`MideElPieDelPlano`, de 10.29), la barra
  de la operación entera se mide (`MideLaFranja` → `franjaDelPlanoProvider`, en `BayPlanView`); la
  leyenda, sin operación, deja la franja sin valor. `AvisosSobreElPie` resta el aire de abajo del aviso
  y pasa el alto que queda (`LugarDelAviso`) a lo que está debajo del `Scaffold`, que incluye el aviso.
  El resumen de encima de la barra (la línea que se abre con un toque) queda fuera: es un control.
- **El aviso cabe por construcción.** `avisoDelViaje(texto:, corto:, accion:, …)` hace el `SnackBar`
  de la página: compacto (4 dp de aire arriba y abajo, «Deshacer» al lado del texto con 8 dp a los
  lados en vez de 16) y con dos filas, la del texto entero y la del corto. Una pieza propia
  (`_ElQueCabe`) las mide al ancho que hay y muestra la primera que cabe en el alto del lugar; las demás
  ni se dibujan, ni reciben toques, ni se anuncian, ni las encuentran las pruebas. Si ni la corta cabe
  (fuera de lo probado: letra mayor que 2.0 o pantallas de menos de 360 dp), se recorta a su lugar: el
  tope no se pasa nunca. La letra del aviso es la del sistema; no se reserva sitio; no va arriba.
- **Todos los avisos de la página pasan por ahí**: los de `discharge_controls.dart` (la Baja y la
  re‑estiba con «Deshacer», «Deshecho», «No se registró», «No se deshizo», «No se quitó la tapa»,
  «Esta escala no tiene operación guardada»), `loading_controls.dart` (la carga con «Deshacer», «Este
  contenedor no tiene OR», los errores al deshacer), `plan_drag_confirmation.dart` y
  `vessel_overview_page.dart` (exportar, cargar el archivo, el perfil, los parámetros, T-61). T-61 se
  arma en un solo sitio (`avisoDelParametroConservado`) porque sale sobre el plano también cuando se
  reabre desde «Viajes recientes». Una prueba lee esos archivos y falla si aparece un `SnackBar(` hecho
  a mano.
- **Los textos cortos.** La Baja: «Descargado · MNLU0000107» (sin la celda, que ya está en naranja y se
  ve en la rejilla; el número del contenedor no se ve en ningún otro sitio). La carga: «Descarga y carga ·
  OR 16», «Cargado · OR 16», «Corregido · OR 16». Un error o un aviso largo sin acción dice qué pasó («No
  se registró.», «No se deshizo.», «No se aplicó todo el perfil vigente.») y lleva **«Ver»**, que abre el
  texto entero en un diálogo con «Cerrar». Los errores al deshacer una carga, que antes eran solo el
  mensaje del dominio, ahora empiezan «No se deshizo:», como los de la descarga.
- **Sin franja no cambia nada**: en la Lista, el Avance, la oficina y el plano sin operación no hay tope y
  el aviso dice siempre su texto entero; solo se ve más compacto.

**Cifras con la regla nueva** (fuentes reales, 24 contenedores, el plano desplazado; la tarjeta del aviso
y el borde de arriba de la barra en dp; `geometria.jsonl`):

| Pantalla | Letra | Descarga: texto · aviso (borde de la barra) | Carga: texto · aviso (borde de la barra) | Celdas tapadas |
|---|---|---|---|---|
| 360 × 640 | 1.0 | entero · 434–492 (428) | entero · 436–492 (428) | 0 |
| 360 × 640 | 1.45 | corto · 416–492 (404) | entero · 416–492 (404) | 0 |
| 360 × 640 | 2.0 | corto · 350–492 (346) | corto · 392–492 (346) | 0 |
| 412 × 915 | 1.0 | entero · 711–767 (703) | entero · 711–767 (703) | 0 |
| 412 × 915 | 1.45 | corto · 691–767 (679) | entero · 691–767 (679) | 0 |
| 412 × 915 | 2.0 | corto · 667–767 (650) | entero · 625–767 (621) | 0 |

La fila de controles empieza en y=500 (360 × 640) y y=775 (412 × 915) en todos los casos, 8 dp por debajo
del aviso. T-61 con la letra a 2.0 en 360 × 640: «No se aplicó todo el perfil vigente.» con «Ver», 392–492;
el diálogo lo muestra entero (`360x640-t61-letra2.0-ver.png`).

**Pruebas** (`test/t114_candidata_correccion2_test.dart`, nuevo, 18). Con la prueba de geometría de
Codex como base (la app entera, las fuentes reales, los planes de 24 contenedores, el plano desplazado
y cada celda recortada por los desplazables y la ventana; en Carga también `plan-cell-*` y
`loading-C:*`):
- **la matriz, 12 casos** (360 × 640 y 412 × 915; letra 1.0, 1.45 y 2.0; Descarga y Carga), con el
  aviso de 6 s hecho como lo hace la página y los textos de los avisos de verdad. Cada caso comprueba que
  ninguna celda visible cruza el aviso y que no pasa del borde de arriba de la barra; que la fila de
  controles y lo que se toca en ella quedan libres; que el texto que se ve es el entero o el corto, entero
  (sin elipsis y sin líneas recortadas: su alto es el de su texto) y dentro de la tarjeta; y que
  «Deshacer» responde. Con la letra a 1.0 exige además el texto entero;
- **el aviso más largo** de los demás de la página (T-61) con la letra a 2.0 en 360 × 640: el corto,
  entero y sin tapar nada; el lector de pantalla lee ese y no el que no cabe; y «Ver» abre el texto entero,
  que se lee sin cortes;
- **la oficina a 1920 × 1080** con la letra a 1.0 (el aviso compacto también cambia ahí): sin franja,
  sin tope; el aviso, entero y por encima de la leyenda, no tapa celdas y «Deshacer» responde;
- **dos registros de verdad** con la letra a 2.0 en el teléfono bajo: dos Baja seguidas y una carga por
  OR, cada aviso en su lugar y entero, y «Deshacer» deshace;
- **la medida vieja** de Codex, adaptada: con medidas viejas grandes y pequeñas (también de la franja),
  al abrir otro viaje y al volver de la Lista, en todos los cuadros visibles el aviso queda entre el borde
  de arriba de la barra y los controles, y las medidas nuevas sustituyen a las viejas. Sigue teniendo
  sentido: la franja también se mide después del cuadro;
- **una guarda**: ningún `SnackBar(` hecho a mano en los cuatro archivos de la página, y T-61 de los
  recientes por `avisoDelParametroConservado`.

La prueba de Codex tal cual (`geometria-final_test.dart.txt`) **sigue fallando**, y es lo esperado: pone
en pantalla un `SnackBar` hecho a mano, que no sabe su lugar. La regla es de los avisos de la página, y
la guarda asegura que todos se hacen con `avisoDelViaje`; la matriz nueva es la suya con el aviso como
lo hace la página. Las cinco pruebas de la corrección anterior siguen pasando sin cambios.

### 11.3 O1 · Atrás que cierra otra cosa

La ventana de 2 s es para dos toques seguidos en la raíz. Ahora `AtrasDelViaje` la cancela, y la
advertencia se va, cuando en medio:
- **se abre algo que no es una ruta**: el menú del zoom (`cerrablesDeAtrasProvider` sube) o el detalle
  en el panel lateral (`celdaSeleccionadaProvider` deja de estar vacío);
- **se abre una ruta encima** (una hoja, un diálogo, la búsqueda): la página deja de ser la ruta actual
  (`ModalRoute.isCurrentOf`, en `didChangeDependencies`);
- **Atrás cierra otra cosa** (el zoom, el detalle): ese toque no cuenta como primero y cancela la que
  hubiera.
El siguiente Atrás en la raíz vuelve a advertir. Lo demás de H1 no cambia: el reloj cuenta desde el
primer toque, la tarjeta va arriba fuera de la cola de avisos y no cierra avisos ajenos, y solo aplica al
viaje publicado en Android. **Pruebas** (`test/t114_candidata_atras_test.dart`, 13 → 16): los dos casos de
Codex (`h1-intermedio_test.dart.txt`), ahora sin salir del viaje (el zoom; el detalle en el panel lateral a
1300 × 900), el de una hoja («Más»), y en el primero, al final, dos toques seguidos en la raíz siguen
saliendo. Las 13 de antes pasan sin cambios.

### 11.4 O2 · El instrumento de Android

`tool/t114_piloto_android.py`: tras cada Atrás en la raíz, `advertencia_y_plano()` sondea el árbol de
uiautomator mientras dura la ventana y exige en **un mismo volcado** la advertencia («Toca Atrás otra
vez…»), un elemento del plano (una celda «por descargar», la bahía o una cifra de la franja) y, con el
aviso de la Baja, «Deshacer»; el inicio o un volcado vacío no valen, y si no aparecen antes de los 2 s
el paso falla. Anota en `registro.tsv` a qué segundo los vio. `sin_inicio()` también exige ahora el plano
en positivo. La captura va al instante, en otro hilo, a la vez que el sondeo (`atras_comprobado()`).

Hicieron falta tres intentos para ajustar el instrumento, y los tres los paró la comprobación nueva, no la
app (sus capturas p23 muestran la advertencia, el plano y el aviso a la vez): **un volcado de uiautomator
espera a que la app se quede quieta**. En reposo tarda 1,2 s y ve la advertencia; justo después de una
Baja, o cuando se va el aviso de 6 s, tarda 3,0 s y llega con la ventana ya cerrada (medido aparte en el
emulador). Ahora, tras la Baja, el primer volcado comprueba el aviso con «Deshacer» (`con_aviso()`, que
espera a que la app esté quieta) y entonces va el Atrás; antes del segundo Atrás, `sin_inicio()` hace lo
mismo. Los intentos quedan en `%TEMP%\t114-correccion2\emulador-1.0-intento-{1,2,3}` (fuera de Git) y se
cuentan en 11.5. El instrumento acepta además `--letra` (por omisión 1.0; al terminar vuelve a 1.0) para la
corrida con la letra grande.

### 11.5 El emulador

`tool/t114_piloto_android.py` con el APK r4 de este árbol (banco `%TEMP%\t99-r4-corr2\copia`,
`flutter build apk --release -t tool/t99_main.dart`), instalado solo en `t99_api26` (`emulator-5554`,
360 × 640 dp, el muelle de día), con los sintéticos T100_CARGA.edi, T100_LLEGADA.edi y T100_LISTADO.xlsx,
desde datos limpios (el instrumento hace `pm clear`). El Honor no se tocó.

- **Con la letra a 1.0: 27 pasos, 0 fallos**, en el cuarto intento (`correccion2/emulador/`: `pNN-*.png`,
  `registro.tsv`, `salida.txt`). Los tres anteriores los paró la comprobación nueva de O2, en el paso 23
  (dos) y en el 24 (uno), por el tiempo del volcado (11.4): en los tres, los pasos 1 a 22 pasaron igual, y
  la captura p23 del primero muestra la advertencia, el plano y el aviso a la vez
  (`correccion2/emulador-intentos/`, con sus registros). Antes del cuarto se recompiló el APK con la línea
  que rehace la semántica de `_ElQueCabe` al cambiar de texto (11.2); lo demás es igual.

| Paso | Captura | Qué se ve |
|---|---|---|
| Baja y otra Baja, sin esperar | p10, p11 | el aviso entero, «Descargado · MNLU… · 002-0x-82» con «Deshacer», entre la línea del resumen y la fila de controles: el resumen ya no queda debajo; la segunda Baja registra con el aviso de la primera en pantalla |
| La re‑estiba y el cambio a Carga | p14, p15 | «Re‑estiba registrada» sobre las cifras; Carga abre con ese aviso aún en pantalla |
| La primera carga por OR | p18 | «Descarga y carga registradas · OR 16», en una línea, con «Deshacer» al lado |
| La segunda, sin esperar | p19, p20 | «Acciones» abierto con el aviso de la primera detrás; después, la segunda carga |
| Atrás con el aviso de una Baja | p23 | la advertencia arriba y el aviso con «Deshacer» abajo; O2 los ve con el plano a los 1,2 s |
| Otro toque pasados más de 2 s | p24 | la advertencia otra vez y el plano sigue; O2, a los 1,2 s |
| Dos toques seguidos | p25, p26 | el inicio con el viaje en los recientes; el reciente reabre publicado |

- **Con la letra a 2.0** (`--letra 2.0`, sin tocar ningún paso): el instrumento se detiene en el **paso 4**,
  en «Parámetros del buque»: «No lo tengo» no llega entero a la vista al deslizar
  (`correccion2/emulador-letra2.0/`: p01 a p03 y la salida). **No llega a una Baja ni a una carga por OR**, así
  que no hay capturas del aviso con la letra a 2.0 en el emulador; no se forzó el instrumento. Con la letra a
  2.0 lo cubren las capturas de geometría con las fuentes reales (11.2) y las dos pruebas que registran de
  verdad a 2.0. Al terminar, `font_scale` quedó en 1.0 (comprobado con `adb -s emulator-5554 shell settings
  get system font_scale`).

### 11.6 Validaciones ejecutadas

Un comando de Flutter a la vez; el Honor (`AJ5TBB6531101024`, conectado) no se tocó: el instrumento fija
`ANDROID_SERIAL=emulator-5554` y las órdenes sueltas llevan `-s emulator-5554`.

| Qué | Resultado |
|---|---|
| `flutter analyze --no-pub` | **«No issues found»**, sin `// ignore:` |
| `flutter test --no-pub`, al final, tras el último cambio | **1359** en verde, ninguna omitida, sin reintentos (piso 1338 → 1359; `build/t114-correccion2/suite-final.txt`, fuera de Git). Una corrida anterior, antes de la línea de la semántica de `_ElQueCabe`, dio también 1359 |
| `test/t114_candidata_correccion2_test.dart` | 18 nuevas (H2: 12 de la matriz, T-61, la oficina, dos registros de verdad, la medida vieja, la guarda) |
| `test/t114_candidata_atras_test.dart` | 16 (13 + 3 de O1) |
| `test/t114_candidata_correccion_test.dart` | las 5 de antes, sin cambios |
| Capturas de geometría | `correccion2/geometria/`: 10 con la regla nueva (1.0 y 2.0, los dos teléfonos, los dos modos; T-61 y su «Ver») y 5 de antes, con sus medidas |
| `tool/t114_piloto_android.py` | **27 pasos, 0 fallos** con la letra a 1.0 (cuarto intento; los tres anteriores, parados por O2 en p23/p24 por el tiempo del volcado); con la letra a 2.0 se detiene en el paso 4 y no llega a la Baja |
| Banco r4 | `%TEMP%\t99-r4-corr2\copia` (`t99_copia.ps1 -Arbol -Sufijo r4 -Entradas …`), APK `gt.cmartinez.baystream.r4` (`flutter build apk --release -t tool/t99_main.dart`) |

**Las 54 capturas de las pantallas sin rediseñar no se rehacen**: la corrección solo cambia los avisos
(que no salen en ellas), la ventana de Atrás (que no se ve sin tocar Atrás) y dos medidores
(`MideLaFranja` y la leyenda con `sinFranja`), que son cajas que no dibujan ni cambian el layout. Ninguna
página cambia sin aviso. Windows y la Web no se recompilaron; RNF-002, la RAM, la auditoría y los censos no
se repitieron: nada toca los tres pasos ni las listas.

### 11.7 Archivos

- **`lib/` (solo presentación):** `features/vessel/presentation/widgets/avisos_del_viaje.dart`
  (`franjaDelPlanoProvider`, `MideLaFranja`, `LugarDelAviso`, `avisoDelViaje`,
  `avisoDelParametroConservado`, `_ElQueCabe`; `MideElPieDelPlano(sinFranja:)`), `widgets/bay_plan_view.dart`
  (la barra dentro de `MideLaFranja`; la leyenda sin franja), `widgets/navegacion_del_viaje.dart` (O1),
  `widgets/discharge_controls.dart`, `widgets/loading_controls.dart`, `widgets/plan_drag_confirmation.dart`,
  `pages/vessel_overview_page.dart` y `pages/recent_voyages_page.dart` (los avisos por `avisoDelViaje`).
- **`test/`:** nuevo `t114_candidata_correccion2_test.dart`; modificado `t114_candidata_atras_test.dart` (+3).
- **`tool/`:** `t114_piloto_android.py` (O2 y `--letra`).
- **Documentos:** `DESIGN.md` (8: la ventana se cancela; 13.8: el borde de arriba del aviso), este informe y
  la evidencia nueva en `docs/rediseno/fase3/candidata/correccion2/` (`geometria/`, `emulador/`, `emulador-intentos/` y `emulador-letra2.0/`).
- Sin cambios: `domain/`, `data/`, `lib/main.dart`, los congelados, `pubspec.yaml`, `pubspec.lock`, Firebase,
  las apps instaladas, «PRUEBA T-105», `C:\Proyectos\baystream-demo17\`, `docs/piloto/LISTA-PILOTO.md` y el
  Honor. Los generados de `windows/flutter/` y `test/t114_fase3_correccion_test.dart` siguen figurando
  modificados solo por el fin de línea y no se agregan.

### 11.8 Lo que queda anotado

1. **Con la letra grande, el aviso de la Baja dice el contenedor y no la celda** («Descargado ·
   MNLU0000107»), y a 360 dp el número parte en dos líneas («MNLU00001 / 07») porque no cabe entero al lado
   de «Deshacer». Está entero, pero se lee peor. Agrupar el número como en ISO 6346 («MNLU 000010 7»,
   ya anotado en 9.3) lo partiría por los espacios; es un cambio de presentación de todos los números de
   contenedor y no entra aquí.
2. **Los errores largos se leen con «Ver».** Con la letra a 1.0 casi todos caben enteros; con la grande, el
   aviso dice qué pasó y el porqué está a un toque. Si en el piloto molesta, el porqué puede ir en el detalle
   de la celda.
3. **Un aviso que se muestra en otra página y sigue en pantalla al volver al plano** (por ejemplo «Listado
   importado.» si se vuelve en sus 4 s) no pasa por `avisoDelViaje` y no sabe su lugar. Son textos de una
   línea y caben; T-61, el único que está hecho para verse en el plano, ya pasa por ahí.
4. **El plano sin operación** (la leyenda al pie) no tiene franja: el aviso flota por encima de la leyenda,
   como desde 10.29, y puede cruzar la rejilla. La 10.31 pide el muelle operando (Descarga y Carga); fuera
   de él no se cambió.
5. **O3 (la oficina)** queda para COMAR, como dice la 10.31.

### 11.9 Horas

De ≈ 20:20 (el encargo) a ≈ 21:35 del 23-oct-2026: **≈ 1.3 h** de reloj. Medir la regla vieja en los dos
teléfonos y en el Honor (360 × 800), probar tres formas del aviso, la regla y sus 18 pruebas, O1 con 3,
O2, la suite una vez, el banco y el APK, cinco corridas del emulador y los documentos.

### Git para Carlos (Fase 3, candidata del piloto, segunda corrección)

Un `git add` por ruta; la evidencia nueva va por su carpeta, verificada: 58 archivos, ninguno ignorado
(`geometria/` 17, `emulador/` 29, `emulador-intentos/` 7, `emulador-letra2.0/` 5). `pubspec.*`, `domain/`,
`data/`, `lib/main.dart`, los congelados y `docs/piloto/LISTA-PILOTO.md` no cambian; los generados de
`windows/flutter/` y `test/t114_fase3_correccion_test.dart` no se agregan. El último comando tiene que
mostrar **71 files changed**.

```powershell
git add -- lib/features/vessel/presentation/widgets/avisos_del_viaje.dart
git add -- lib/features/vessel/presentation/widgets/bay_plan_view.dart
git add -- lib/features/vessel/presentation/widgets/navegacion_del_viaje.dart
git add -- lib/features/vessel/presentation/widgets/discharge_controls.dart
git add -- lib/features/vessel/presentation/widgets/loading_controls.dart
git add -- lib/features/vessel/presentation/widgets/plan_drag_confirmation.dart
git add -- lib/features/vessel/presentation/pages/vessel_overview_page.dart
git add -- lib/features/vessel/presentation/pages/recent_voyages_page.dart
git add -- test/t114_candidata_correccion2_test.dart
git add -- test/t114_candidata_atras_test.dart
git add -- tool/t114_piloto_android.py
git add -- DESIGN.md
git add -- docs/rediseno/fase3/candidata/correccion2
git add -- docs/REDISENO-RESULTADOS.md
git commit -m "Sprint 4: segunda correccion de la candidata del piloto (10.31), el aviso no pasa del borde de arriba de la franja con cualquier letra, Atras cancela la ventana al abrir o cerrar otra cosa, el instrumento de Android comprueba en positivo y el muelle repetido en el emulador" --trailer "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
git push origin sprint-4
git show --stat --format="%h %s" HEAD | Select-Object -Last 1
```

### Tres líneas

- H2: el aviso de la página vive entre el borde de arriba de la barra de la operación y sus controles, por
  construcción: la página mide los dos bordes y `avisoDelViaje` muestra el texto entero si cabe o uno corto
  que sigue diciendo qué pasó («Ver» para el entero en los largos); compacto, con «Deshacer» al lado, a la
  letra del sistema y sin sitio reservado.
- O1: lo que se abre o se cierra en medio cancela la ventana de Atrás; O2: el instrumento exige en un
  volcado, dentro de los 2 s, la advertencia, el plano y «Deshacer».
- Suite 1359, `analyze` 0, la matriz de Codex (2 teléfonos × 3 letras × 2 modos) en verde, el muelle en el emulador con 27 pasos sin fallos. ALTO: Codex
  acepta la segunda corrección.

### Mensaje para Yov

Yov: la **segunda corrección de la candidata (10.31)** está escrita, probada y repetida en el emulador, en
un bloque aparte de 71 archivos. **H2:** la regla de 10.29 acotaba el borde de abajo del aviso y nada el de
arriba; además de lo que vio Codex a 360 × 640, a 412 × 915 pisaba celdas ya con la letra a 1.45, y el aviso
de T-61 subía sobre la rejilla con cualquier letra. Con la letra a 2.0 el lugar que deja la 10.30 (las
cifras) mide 117 dp a 412 × 915 y el aviso con número, celda y «Deshacer» no cabe con ningún relleno, así
que el aviso tiene que elegir qué decir. Ahora la barra entera se mide (`MideLaFranja`), `AvisosSobreElPie`
pasa a los avisos su alto (`LugarDelAviso`) y todos los avisos de la página se hacen con `avisoDelViaje`:
compactos, con «Deshacer» al lado del texto, y con dos textos, el entero y uno corto que sigue diciendo qué
pasó («Descargado · MNLU0000107»; los errores, «No se registró.» con «Ver» para el entero). Una pieza propia
mide los dos y muestra el primero que cabe; si ni el corto cabe, se recorta a su lugar: el tope no se pasa
nunca. Letra del sistema, sin sitio reservado, abajo: la 10.30 queda intacta. Una prueba-guarda falla si
aparece un `SnackBar(` a mano en los archivos de la página. La prueba de Codex tal cual sigue fallando,
porque pone un `SnackBar` hecho a mano; la matriz nueva es la suya con el aviso como lo hace la página.
**Pruebas:** 18 nuevas: la matriz de 12 (360 × 640 y 412 × 915; 1.0, 1.45 y 2.0; Descarga y Carga), T-61 a
2.0 con «Ver», la oficina a 1920, dos registros de verdad a 2.0, la medida vieja de Codex y la guarda. **O1:**
lo que se abre o se cierra en medio (zoom, detalle, hoja, diálogo) cancela la ventana de Atrás; tres
pruebas, los dos casos de Codex sin salir y la hoja; dos toques seguidos siguen saliendo. **O2:** tras cada
Atrás, el instrumento exige en un volcado, dentro de los 2 s, la advertencia, el plano y «Deshacer»; un
volcado de uiautomator espera a que la app quede quieta (3 s tras una Baja, 1,2 s en reposo) y costó tres
intentos ajustarlo. **Emulador:** 27 pasos sin fallos a 1.0, O2 a los 1,2 s en los dos Atrás; a 2.0 el
instrumento se detiene en el paso 4 («No lo tengo») y no llega a la Baja: no se forzó. **Cifras:** suite 1359
(1338 + 21), `analyze` 0; `pubspec.*`, `domain/`, `data/` y la lista del piloto sin tocar; las 54 capturas
no cambian (nada se ve distinto sin aviso). Anotado: a 360 dp con letra grande el número del contenedor
parte en dos líneas, y el plano sin operación sigue sin tope. `DESIGN.md` 8 y 13.8 dicen lo nuevo. Me
detengo: **ALTO: Codex acepta la segunda corrección.**
