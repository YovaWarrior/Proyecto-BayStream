# T-123 · La 3.1.1 entra en `sprint-4` con una mezcla — Resultados

**Programador:** Timonel (Claude Code). **Fecha:** 26 y 27 de octubre de 2026.
**Base:** `sprint-4` en `e4156ad` (10.63) con `master` `34d8838` (`v3.1.1`) mezclado por Carlos
con `git merge --no-ff --no-commit`, en `C:\Proyectos\baystream-rediseno`. La base común es
`38965b8`. **Decisiones:** `SPRINT-4.md` 10.49 a 10.52 y 10.55 a 10.63.

Datos sintéticos en todo (`BUQUE PRUEBA T122`, `TSTU…`, `BUQUE MANUAL`). Nada del piloto ni del
corpus real. Evidencia en `build/t123/` (fuera de Git).

## 0. Resumen

| Qué | Dónde | Cómo quedó |
|---|---|---|
| Conflicto 1 | `vessel_overview_page.dart` | Quedan las dos importaciones |
| Conflicto 2 | `loading_controls.dart` | El diseño del rediseño (fichas de 14.7, `soloIcono` de 10.40) con el comportamiento de H4 (`disponible`) |
| El aviso de H4 | `resumen_del_modo.dart` | La ficha `loading-sin-listado` dice la regla nueva, a la manera de las fichas |
| La llamada de la franja | `loading_plan_controls.dart` | `busquedaDeCarga(…, disponible: plan != null, soloIcono: orSoloIcono)` |
| Lo que se mezcló solo | `bay_plan_view.dart` (H6), `loading_plan_controls.dart` (H4, la tira), `plan_drag_confirmation.dart` (H7) | Revisado por dentro y probado en la oficina (sección 3) |
| Pruebas de T-122 | `t122_hallazgos_test.dart`, `t122c2_vacio_con_numero_test.dart` | El plano suelto se monta a 360 × 800 (sección 4) |
| Prueba de la mezcla | `test/t123_mezcla_test.dart` (nueva, 5 casos) | H4 en la oficina y en el teléfono; H7 en la columna de la oficina |

**Cifras:** la suite completa, **1821 de 1821** en una sola corrida, sin reintentos ni omitidas
(el piso de `sprint-4` era 1783; entran las 33 de la 3.1.1 y las 5 de T-123);
`flutter analyze lib test tool/t122_main.dart tool/t122_entradas.dart` en **cero**.
Capturas: **103** PNG con datos sintéticos en los dos temas (Web 40, Windows 23, emulador 40), sección 6.

## 1. Los dos conflictos

### 1.1 `vessel_overview_page.dart`: una importación

Cada lado agregó la suya en el mismo sitio: el rediseño `oficina_providers.dart` (las
preferencias de la oficina, 14.4) y la 3.1.1 `loading_operation_provider.dart` (H6:
`aboardContainersProvider`, y `carriersListProvider` y `filteredContainersProvider` que se
mudaron ahí desde `vessel_providers.dart`). Quedan las dos. Lo demás del archivo se mezcló solo:
la búsqueda general y la Lista recorren lo que va a bordo (13 líneas de la 3.1.1) dentro de la
página de la oficina (626 líneas del rediseño).

### 1.2 `loading_controls.dart`: `busquedaDeCarga` y el `build` del resumen

- **Se queda el bloque del rediseño:** `busquedaDeCarga` con `soloIcono` (la franja que no cabe
  en una línea, 10.40: `IconButton` con el rótulo en la descripción emergente) y el `build` que
  arma el resumen con `fichasDelResumen` (14.7), con `soloLaBahia` para la barra del muelle.
- **Con el comportamiento de H4:** el parámetro vuelve a llamarse `disponible`, como en la
  3.1.1, y ya no mira el listado. En el `build` va `disponible: data != null`: el botón solo espera
  a que el plan esté leído (en la 3.1.1 era `disponible: true` dentro de la rama `data:` del
  `when`, que es lo mismo; el rediseño ya no usa `when` ahí porque las fichas dicen «Leyendo el
  plan combinado…»). «Asignar vacío» sigue pidiendo el listado (`data?.list == null`): los vacíos
  van con su fila (10.51, 10.59).
- **Lo que la 3.1.1 traía en el `build` viejo y ya vivía en las fichas:** las cifras de carga y
  descarga (`loading-operation-totals`, `loading-discharge-totals`) y los estados de lectura. Lo
  único que faltaba era el aviso nuevo de H4, que fue a `resumen_del_modo.dart` (1.3).
- El resto del archivo (el toque de la celda sin fila con `unlistedRow` y `needsRow`, los rótulos
  `row.label` y `row.name`, el detalle que corrige por número) vino de la 3.1.1 sin conflicto.

### 1.3 El aviso de H4, a la manera de las fichas (`resumen_del_modo.dart`)

La 3.1.1 cambió el texto «Importa el listado de agencia para operar por OR.» por «Sin listado de
agencia: los llenos se cargan por su número; los vacíos esperan el listado.». En el rediseño ese
texto es una ficha en revisar (`loading-sin-listado`, 14.7), así que la ficha dice ahora
**«Sin listado de agencia: los llenos se cargan por su número; los vacíos esperan el listado»**,
con «Sin listado de agencia» de rótulo (tinta suave) y la regla de valor, en el contorno de
revisar y con la misma clave. En Número de orden, «Esta operación todavía no tiene listado de
agencia.» no cambia: ahí el listado sigue haciendo falta para los OR.

### 1.4 Las llamadas a `busquedaDeCarga`

| Dónde | Antes de la mezcla | Ahora |
|---|---|---|
| El `build` del resumen (`loading_controls.dart`) | rediseño `conListado: data?.list != null`; 3.1.1 `disponible: true` | `disponible: data != null` |
| La franja de la bahía (`loading_plan_controls.dart`, `ParteDeLosControles.franja`) | rediseño `conListado: listado != null, soloIcono: orSoloIcono` | `disponible: plan != null, soloIcono: orSoloIcono` |
| La tira del pie del teléfono bajo (`_CompactPlanBar`, `tira: true`) | se mezcló solo con la 3.1.1: `disponible: data != null` | igual |

## 2. Lo que se mezcló solo y se revisó por dentro

- **`bay_plan_view.dart` (H6).** El trozo de la 3.1.1 (la reserva se resalta también cuando el
  número resaltado es el del vacío que se le asignó) cayó dentro de `_Rejilla`, la rejilla del
  rediseño, en el mismo cálculo de `loadHighlighted` que ya tenía lo recién movido de 13.3. En la
  oficina el resultado de la búsqueda general llega por `destinoDelViajeProvider`, `selectedBay` y
  `highlightedContainerProvider`, como en el teléfono; la prueba de página de T-122 (1300 dp, con el
  panel fijo) lo comprueba en la oficina y pasa sin cambios.
- **`loading_plan_controls.dart` (H4).** La 3.1.1 tocaba una sola línea, la tira del teléfono
  bajo, y entró sola (`disponible: data != null`). La franja de la bahía es del rediseño y se
  resolvió en 1.4. El menú «Acciones» conserva «Asignar vacío» apagado sin listado.
- **`plan_drag_confirmation.dart` (H7).** El rediseño agregó `alturaNatural` y `_AltoAmpliado`
  (14.1: la rejilla de la oficina sin desplazamiento vertical propio, ampliada a su alto natural);
  la 3.1.1 agregó `_PlanDragSource` (un `EdgeDraggingAutoScroller` por eje sobre los `Scrollable`
  más cercanos) y `_dropSpotAt` (la celda bajo el puntero por prueba de toque). Se mezclaron sin
  conflicto y encajan:
  - en el teléfono los dos `Scrollable` más cercanos siguen siendo los de la rejilla; las tres
    pruebas de H7 a 360 dp pasan sin cambios;
  - **en la oficina el vertical más cercano a la celda es la columna entera**
    (`columna-del-plano`, el `CustomScrollView` de 14.1), porque la rejilla ya no tiene el suyo;
    el horizontal sigue dentro de la rejilla. Así, con el puntero cerca del borde de abajo, lo que
    se desplaza es la columna (el puente, la franja y la leyenda incluidos), que es lo que hay
    que desplazar. Lo comprueba `t123_mezcla_test.dart` con el dedo y con el mouse a 800 × 420:
    el desplazamiento llega al final y al soltar cuenta la celda bajo el puntero, sin guardar nada;
  - `_RenderAltoAmpliado` implementa `applyPaintTransform` y `hitTestChildren` con su matriz, así
    que el desplazador, que mide en coordenadas de pantalla, y `_dropSpotAt`, que hace la prueba de
    toque, aciertan también con zoom en la oficina;
  - una nota, no un defecto: la franja de la bahía fijada arriba (56 dp) tapa el margen de 40 dp
    del desplazador en el borde de arriba, así que para subir hay que llevar el puntero sobre la
    franja (sigue dentro del viewport de la columna). En la oficina el mouse tiene además la rueda.
- **El resto de la 3.1.1** (dominio y datos: `reference_bay.dart`, `loading_operation.dart`,
  `export_list.dart`, `vessel_voyage.dart`, `departure_baplie_writer.dart`, el lector del listado;
  `vessel_geometry_page.dart`, `departure_baplie_page.dart`, los dos providers, `pubspec.yaml`
  con la 3.1.1+5) entró tal cual: el rediseño no tocaba esos archivos. No entra nada más del
  dominio, ningún `// ignore:`, ninguna dependencia, ni `lib/main.dart` ni los congelados.
  `pubspec.lock` no cambia.
- **La regla de la par en Estadísticas no se adopta aquí** (10.63): `estadisticas_del_viaje.dart`
  y `bs_buque_en_corte.dart` siguen como en 10.55. Es la tarea siguiente.
- La mezcla no trajo ningún otro choque.

## 3. Verificación

### 3.1 Las pruebas de T-122 y del rediseño, juntas

`build/t123/01-t122-y-t123.log`: las 33 de la 3.1.1 (`t122_hallazgos`, `t122_arrastre`,
`t122_dominio`, `t122c1_salida_sin_fila`, `t122c2_vacio_con_numero`) y las 5 de T-123, **38 de
38**. `02-rediseno-vecinas.log`: las del rediseño que tocan «OR / últimos dígitos», el resumen,
el selector, la oficina y el arrastre (T-76, T-77, T-94, T-105, T-107, T-114 candidata, T-117,
T-118), **419 de 419**.

### 3.2 La suite completa, una vez, y analyze

`flutter test --reporter expanded`, una sola corrida al final, con todo en su sitio
(`03-suite-completa.log`): **+1821 · 0 fallos · 0 omitidas · «All tests passed!»** en 3:57 min.
1783 (el piso de 10.55) + 33 (la 3.1.1: 25 de T-122, 5 de la corrección 1, 3 de la corrección 2)
+ 5 (T-123) = 1821. `flutter analyze lib test tool/t122_main.dart tool/t122_entradas.dart`:
**No issues found** (`04-analyze-lib-test.log`).

## 4. Cada prueba que cambió, y por qué

| Prueba | Cambio | Por qué |
|---|---|---|
| `test/t122_hallazgos_test.dart`, `_plano` | Monta el plano a 360 × 800 dp (como T-76 en `sprint-4`) | El plano suelto a 800 dp se arma como oficina (14.1), donde el selector de modo vive en la cabecera de la página, que la prueba no monta. Los casos (H4 en el muelle, H5 la silueta) son del teléfono; sus expectativas no cambian |
| `test/t122c2_vacio_con_numero_test.dart`, `_plano` | Lo mismo | Lo mismo |
| `test/t123_mezcla_test.dart` | Nueva, 5 casos | H4 en la oficina a 1366 × 690 (con el rótulo y, con la letra a 1.45, solo con el icono) y en el teléfono a 360 × 800: el botón disponible sin listado y la ficha con la regla nueva; H7 en la columna de la oficina a 800 × 420, con el dedo y con el mouse |

Ninguna prueba del rediseño esperaba la regla vieja: ninguna pedía «OR / últimos dígitos» apagado
sin listado ni el texto «Importa el listado de agencia para operar por OR.», y los rótulos «21/22»
ya no estaban. T-68, T-76, T-78, T-82 y T-93 llegaron de la 3.1.1 con su expectativa nueva y no se
tocaron. Ninguna prueba se afloja.

## 5. Archivos tocados después de la mezcla

- `lib/features/vessel/presentation/pages/vessel_overview_page.dart` — conflicto 1.
- `lib/features/vessel/presentation/widgets/loading_controls.dart` — conflicto 2.
- `lib/features/vessel/presentation/widgets/loading_plan_controls.dart` — la llamada de la franja.
- `lib/features/vessel/presentation/widgets/resumen_del_modo.dart` — la ficha de H4.
- `test/t122_hallazgos_test.dart`, `test/t122c2_vacio_con_numero_test.dart` — el tamaño del teléfono.
- `test/t123_mezcla_test.dart` — nueva.
- `tool/t123_capturas_web.py`, `tool/t123_capturas_android.py` — nuevos, los conductores.
- `docs/T123-RESULTADOS.md` — este informe.

Lo que la mezcla dejó listo (lo demás de la 3.1.1 y del rediseño) no se volvió a tocar.

## 6. Capturas con datos sintéticos, en los dos temas

Banco `tool/t122_main.dart`, compilado tal cual en `sprint-4` (la app del producto con el panel
«T122»: la entrada sintética, el rol simulado, el tema; sin Firebase; almacén `t122cap`).
Entradas sintéticas de `tool/t122_entradas.dart`. **103 PNG** en `build/t123/capturas/`:

| Cliente | Cómo | Claro | Oscuro |
|---|---|---:|---:|
| Web (`build/t123/web` servida en 127.0.0.1:5903; `tool/t123_capturas_web.py`, Playwright, 1920 × 1080, la oficina) | automático; `--solo-sin-listado` para la ficha de H4 en un perfil limpio | 20 | 20 |
| Windows (`build/t123/windows`, abierto con `explorer.exe`, PID 35168, padre `explorer.exe`; sin mouse ni control del escritorio: UIA Invoke por nombre con `tool/t117_correccion2_windows.ps1`, clics por el rectángulo del nodo y teclas por `tool/t100_windows.ps1`; PNG por `PrintWindow`, 1920 × 991, ventana maximizada; escala 125 %, 1536 dp) | a mano, paso a paso | 14 | 9 |
| Emulador (`emulator-5554`, 360 × 640 dp, el teléfono bajo; `tool/t123_capturas_android.py`, adb + uiautomator; el arrastre con `sendevent`) | automático | 20 | 20 |

Por hallazgo (`<cliente>_<tema>_<hallazgo>_<pantalla>.png`):
- **H1** `h1_parametros_escala` (las fichas «PAMIT (13) · CRPMN (4) · GTSTC (7) · USHOU (2)» en
  «Parámetros del buque»), `h1_parametros_escala_elegida` (Web y emulador: «7 se descargan · 0 se
  cargan · 6 de paso»), `h1_plano_con_descarga` (el segmento «Descarga 7» en la cabecera de la
  oficina; la banda del muelle en el teléfono) y `h1_modo_descarga`.
- **H3** `h3_agregados` («AGREGADOS: 2 · Todas las filas se entendieron»), `h3_importado` (Web y
  emulador; en Windows el listado ya estaba importado de T-122, 6.1).
- **H4** `h4_carga_bahia_22` (Carga en la oficina: «OR / últimos dígitos» en la franja de la bahía y
  las fichas en la franja de cifras), `h4_confirmar_sin_or` («TSTU0220071 · sin OR en el listado»;
  en Windows, TSTU0220092), `h4_registrado` («Carga registrada · TSTU…»); en la Web, además,
  `h4_sin_listado_ficha` (la ficha de revisar «Sin listado de agencia: los llenos se cargan por su
  número; los vacíos esperan el listado» con el botón disponible) y `h4_sin_listado_busqueda`
  (la búsqueda sin listado con los llenos «sin OR en el listado»).
- **H5** `h5_silueta_22` (la barra bajo la 22 en el puente, nada bajo la 21 ni la 23),
  `h5_avance_22` («Avance de la operación» desde «Acciones», una fila «22»), `h5_confirmar_or1`.
- **H6** `h6_or_ultimos_digitos` («OR 12 · TSTU0012123 … Ya cargado» con «123»),
  `h6_busqueda_general` («26 contenedores disponibles», el vacío asignado con «Posición: Bahía 021,
  Fila 00, Nivel 84»), `h6_resaltado` (la reserva 021-00-84 resaltada en el plano de la oficina),
  `h6_lista` (Web y Windows: la Lista con el vacío asignado).
- **H7** (solo el emulador) `h7_arrastre_en_marcha` (la copia de la celda en el borde y el plano ya
  desplazado), `h7_sobre_la_celda` (la vista previa verde sobre 022-09-84), `h7_al_soltar` («Mover
  TSTU0220106 · 022-10-82 → 022-09-84»).
- **El rediseño como quedó aceptado:** `plano_contenido` (la oficina de 14 con el puente, la franja
  de la bahía y la de cifras; el teléfono bajo de 13.8) y `estadisticas` («El buque en corte», 15).

### 6.1 Lo que hay que saber de cada banco

- **Windows:** el almacén `t122cap` de `%LOCALAPPDATA%\BayStream` conserva las operaciones del
  recorrido de T-122 (V1221 y V1222, con sus tres movimientos), y la oficina no tiene «Limpiar
  datos», así que el plano de llegada abre ya publicado en GTSTC (7.2: el perfil y la escala
  guardados son el efecto de H1) y la operación del plan de carga ya traía el listado, OR 1 cargado
  y OR 12 asignado; H4 se repitió con otro lleno sin fila (TSTU0220092). La BayStream instalada
  (MSIX 3.1.1.0, la cuenta de oficina) estaba abierta a la vez (PID 39288, de `sihost.exe`): no se
  tocó, y el banco se cerró solo por su PID. Para escribir en el campo de la búsqueda general sirvió
  `-Accion tecla` (SendKeys); `-Accion texto` (SendInput Unicode) entraba en el buscador de carga
  pero no en ese campo. Los árboles UIA y MSAA de cada paso quedan en `build/t123/windows-arbol/`.
- **Emulador:** en el teléfono bajo del rediseño la fila de abajo de la rejilla (nivel 82) asoma
  bajo el pliegue y el volcado de uiautomator la recorta: el conductor exige la celda entera (alto
  ≥ 120 px) y por encima de la barra de la operación antes de tocarla, y si no, desplaza la columna.
  **H7 tardó tres corridas:** las dos primeras (`09d`, `09e`) no levantaron la celda; una sonda que
  pasó por el panel paso a paso (rol Oficina y «Publicar en este dispositivo») sí la levantó, y las
  dos corridas siguientes del mismo conductor (`09f`, `09g`) pasaron sin cambiar nada más. No aislé
  la causa de las dos primeras; los registros quedan en `build/t123/`. Los seis hallazgos y las
  dos vistas del rediseño están en los dos temas.
- **Web:** el recorrido completo pasó a la primera en los dos temas; `--solo-sin-listado` añadió
  la ficha de H4 en un perfil limpio.

## 7. Un hallazgo para la tarea siguiente (la regla de la par en la presentación)

Con H5, `LoadingPlanProgress.forBay(21)` devuelve el grupo de la par vecina, rotulado «22». En el
rediseño, la ficha de la bahía de 14.7 empieza por las cifras de la bahía elegida y sigue con lo
que la operación dice del grupo, bajo el rótulo del grupo: con la 21 elegida, la franja de cifras
dice **«Bahía 22: 7 contenedores, 1 celda reservada, 57.7 t, tapas sin declarar; por cargar cub.
27, bod. 0»** (`web_claro_h4_sin_listado_ficha.png`, `windows_claro_h6_resaltado.png`): las
cifras son de la 21 y el rótulo y el pendiente, del grupo 21/22. En la 3.1.1 la línea del teléfono
ya decía «Bahía 22: cubierta 27 · bodega 0» con la 21 elegida, y Codex lo aceptó (10.61); lo nuevo
es que ahora convive en la misma ficha con las cifras de la 21. No lo cambio: 10.63 deja la regla
de la par en la presentación para la tarea siguiente, y qué rótulo lleva la ficha es una decisión
de diseño (por ejemplo, «Bahía 21: 7 contenedores, …; por cargar en la 21/22: cub. 27»). No es
un choque de la mezcla.

## 8. Bloque de Git para Carlos

Desde `C:\Proyectos\baystream-rediseno`, en `sprint-4`, con la mezcla abierta. Un `git add` por
cada ruta tocada después de la mezcla, los dos conflictos incluidos; lo que la mezcla ya dejó listo
no se vuelve a añadir. El `commit` cierra la mezcla (Git conserva `MERGE_HEAD`). `pubspec.yaml`
viene de la mezcla (3.1.1+5) y `pubspec.lock` no cambia. Nada de `build/` entra.

```powershell
Set-Location -LiteralPath C:\Proyectos\baystream-rediseno
git add -- lib/features/vessel/presentation/pages/vessel_overview_page.dart
git add -- lib/features/vessel/presentation/widgets/loading_controls.dart
git add -- lib/features/vessel/presentation/widgets/loading_plan_controls.dart
git add -- lib/features/vessel/presentation/widgets/resumen_del_modo.dart
git add -- test/t122_hallazgos_test.dart
git add -- test/t122c2_vacio_con_numero_test.dart
git add -- test/t123_mezcla_test.dart
git add -- tool/t123_capturas_web.py
git add -- tool/t123_capturas_android.py
git add -- docs/T123-RESULTADOS.md
git commit -m "Sprint 4: T-123, la 3.1.1 (v3.1.1) entra en sprint-4; dos conflictos resueltos y H4, H6 y H7 adaptados al rediseno (10.63)" --trailer "Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
git push origin sprint-4
git log --oneline -3
```
