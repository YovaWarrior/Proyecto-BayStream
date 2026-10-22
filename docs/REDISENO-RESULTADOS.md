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
