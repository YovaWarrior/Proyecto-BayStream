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
  `docs/rediseno/fase3/censos/`): idioma, **1816 cadenas visibles: 1677 en español y 139
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
`docs/rediseno/fase3/rnf-002/web/` (`sin-caliente/`, `sin-fria/`, `con/`:
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
git add -- docs/rediseno/fase3/rnf-002/web/con/con00-publicado.png
git add -- docs/rediseno/fase3/rnf-002/web/con/con01-inicio.png
git add -- docs/rediseno/fase3/rnf-002/web/con/con01-registro.json
git add -- docs/rediseno/fase3/rnf-002/web/con/con01-rejilla.png
git add -- docs/rediseno/fase3/rnf-002/web/con/resumen.json
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
