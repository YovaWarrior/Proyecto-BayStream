# T-122 · La 3.1.1 con los hallazgos del piloto — Resultados

**Programador:** Timonel (Claude Code). **Fecha:** 26 de octubre de 2026.
**Base:** `master`, `7488321` (`v3.1`, la 3.1.0 publicada), en `C:\Proyectos\proyecto-baystream`
(excepción de 10.56). **Decisiones:** `SPRINT-4.md` 10.49 a 10.52, 10.55 y 10.56.
**Versión:** `pubspec.yaml` pasa a `version: 3.1.1+5` y `msix_version: 3.1.1.0`; es el único
cambio de `pubspec.yaml` y `pubspec.lock` no cambia.

Datos sintéticos en todo: `BUQUE PRUEBA T122`, contenedores `TSTU…`, agencias `AGENCIA A/B S.A.`,
línea `LNX`. Nada del piloto entra al repositorio ni a las capturas. Evidencia en `build/t122/`
(fuera de Git).

## 0. Resumen

| Hallazgo | Prioridad | Causa en la 3.1.0 | Arreglo | Prueba |
|---|---|---|---|---|
| H1 · la escala del plano de llegada | P1 | `_portOptions` no ofrecía los puertos de descarga; `suggestPortOfCall` solo proponía salida o siguiente | Entran con su cuenta y se proponen si fueron la última escala | `t122_hallazgos_test.dart` H1 (3) |
| H3 · la fila «AGREGADOS» | P2 | El lector la trataba como fila sin entender; lo de abajo iba a la última agencia | Encabezado de sección; sus filas se cuentan en «AGREGADOS» | H3 (2) |
| H4 · sin listado no se registra | P1 | Una carga solo entraba por su fila del listado | Un lleno del plan se carga por su número, sin OR; la oficina sigue sin registrar | H4 (4) |
| H5 · el avance de la 22 sube en la 21 | P2 | `displayBay` contaba la par con la impar anterior | La par es la referencia (`reference_bay.dart`, una sola vez) | H5 (3) + `t122_dominio_test.dart` |
| H6 · el vacío asignado invisible | P1 | Las búsquedas solo recorrían el BAPLIE y las filas numeradas en el plan | Las dos lo encuentran; la Lista y el resaltado también | H6 (2) + dominio |
| H7 · el arrastre no llega al borde | P2 | `LongPressDraggable` dentro de dos `SingleChildScrollView` sin desplazamiento automático | `EdgeDraggingAutoScroller` en los dos ejes; al soltar cuenta la celda bajo el dedo | `t122_arrastre_test.dart` (3) |
| H2 · el listado en una operación publicada | P1 | Diagnóstico y propuesta (sección 8); no se implementa | — | — |

**Cifras:** la suite completa, **1396 de 1396** en una sola corrida, sin reintentos ni omitidas
(el piso de `master` era 1371, 10.34; entran 25 pruebas nuevas y T-93 pasa a pedir la 3.1.1.0);
`flutter analyze lib test` en **cero**. Capturas: **80** PNG con datos sintéticos en los dos temas
(Windows 22, Web 26, emulador 32), en `build/t122/capturas/`.

## 1. H1 · El plano de llegada no ofrece como escala el puerto donde se descarga (P1, 10.49)

**Lo que pasó (10.49).** El plano de llegada real declaraba la salida (`LOC+5`) y la escala
siguiente (`LOC+61`), pero la carga bajaba en el puerto donde se operaba, y ese puerto no se podía
elegir en «Parámetros del buque»: con la escala equivocada, «0 se descargan» y sin modo Descarga.

**Causa.** `vessel_geometry_page.dart`, `_portOptions`: ofrecía el puerto de salida, el siguiente,
los puertos de carga de los contenedores y los de las reservas; **los puertos de descarga no
entraban**. `vessel_voyage.dart`, `suggestPortOfCall`: la última escala confirmada solo se
proponía si era la de salida o la siguiente.

**Arreglo.**
- `VesselVoyage.dischargePortCounts`: los `LOC+11` del archivo con su cuenta, del más al menos
  frecuente (la contraparte de `loadingPortCounts`).
- `suggestPortOfCall`: con `LOC+61` en el archivo, el historial del dispositivo propone la
  salida, la siguiente **o un puerto donde baja carga**. Sin `LOC+61` sigue como en T-68 (un plan
  de salida no toma el historial).
- `_portOptions` añade los puertos de descarga después de los de carga; la ficha dice «GTSTC (n)»
  con los que bajan ahí (`_portLabel`), y el texto de la sección dice que los demás son puertos
  donde se cargó o se descarga la mercancía.
- `offersDischarge` no cambió: con el puerto elegido, «Descarga» aparece sola.

**Prueba (roja antes).** `test/t122_hallazgos_test.dart`, grupo H1: un BAPLIE sintético que sale
de PAMIT rumbo a CRPMN con dos cajas para GTSTC; `suggestPortOfCall('GTSTC')` devuelve GTSTC y un
puerto ajeno (USLAX) conserva PAMIT; la página a 360 dp ofrece «GTSTC (2)» y la deja elegida si fue
la última escala. Antes: `Actual: 'PAMIT'` y «port-GTSTC» no existía (`build/t122/01-rojo…`).
`test/t122_dominio_test.dart` cubre `dischargePortCounts`. **T-68 cambió de expectativa**: PAMIT
es puerto de descarga en su archivo y ahora se propone; el puerto ajeno de esa prueba pasó a ser
USLAX (dos líneas).

## 2. H3 · La fila «AGREGADOS» del listado (P2, 10.50)

**Causa.** `export_list_parser_service.dart`, `parseGrid`: una fila sin OR solo se entendía como
separador de agencia si contenía «CODIGO»; «AGREGADOS» caía en «No es un contenedor ni un separador
de agencia» (1 fila sin entender). Las filas de debajo **sí se leían**, pero quedaban contadas en
la última agencia del Excel, porque `agency` conservaba su valor.

**Arreglo.** `_sectionHeader` (`^AGREGADOS?$`, tras normalizar mayúsculas, tildes y espacios): la
fila es un encabezado de sección; las filas de debajo llevan `agency: 'AGREGADOS'` y
`ExportList.agencies` las cuenta aparte («AGREGADOS: n»), que es lo que el Excel dice. Lo decidí
así en vez de dejarlas en la última agencia (10.50 pedía revisarlo): un contenedor agregado no es
de la agencia que casualmente va antes; si Carlos prefiere otra cosa, es una línea.

**Prueba (roja antes).** Grupo H3: un listado sintético en rejilla con una agencia, dos filas,
«AGREGADOS», una fila y «TOTAL»; antes había dos filas sin entender (`[5, 7]`), ahora solo el
TOTAL (`[7]`), y `agencies` es `{'AGENCIA A S.A.': 2, 'AGREGADOS': 1}`. También «Agregados» en
minúsculas, con espacios o en singular.

## 3. H4 · Sin fila en el listado no se registra ninguna carga (P1, 10.51)

**Causa.** En la 3.1.0 una carga solo entraba por su fila del listado: `loading_controls.dart`,
`onLoadingContainerTap`, sin fila la oficina veía el detalle y el muelle recibía «Este contenedor
no tiene OR…»; «OR / últimos dígitos» se apagaba sin listado (`conListado`); y en el dominio
`LoadingOperation.search` solo recorría `list.rows` y `draft` exigía `list.byOrder(row.order) == row`.

**Arreglo.**
- Dominio: `ExportListRow.fromPlan(ContainerUnit)`, la fila que el listado no trae, armada desde
  el plan (tipo, puerto, línea, tara y VGM del archivo) **sin OR** (`order` y `sheetRow` en 0,
  `unlisted` la distingue, `name`/`label` la nombran por su número).
  `LoadingOperation.unlistedRows` y `unlistedRow(id)`: lo que el plan carga aquí con número y el
  listado no trae. `search` devuelve primero las filas del listado y después las del plan sin
  fila, por sus últimos dígitos; `draft` acepta una fila sin OR si el plan la carga aquí y
  registra `loadFull` con `order: null`. `LoadValidator` nombra la fila por `row.name`.
- Muelle: tocar la celda de un lleno sin fila abre «Confirmar carga» con «TSTU… · sin OR en el
  listado»; «OR / últimos dígitos» queda disponible siempre (`disponible:`), y el resumen dice
  «Sin listado de agencia: los llenos se cargan por su número; los vacíos esperan el listado».
  El detalle de una carga sin fila también ofrece «Corregir». El aviso al registrar dice
  «Carga registrada · TSTU…».
- Lo que no cambia: la oficina sigue viendo el detalle y sin registrar (es el diseño, 10.51);
  «Asignar vacío» sigue necesitando el listado (los vacíos van a una reserva con su número y su
  tara, que solo el listado trae).

**Prueba (roja antes).** Grupo H4: sin listado, `search('234')` encuentra FULL0001234 y `draft`
registra `loadFull` sin `order`, con el estado en «movido» y sin conflictos; con un listado al que
le falta la fila, el lleno sin OR va después de los del listado; en el plano, con rol de muelle,
tocar la celda abre «Confirmar carga» y la bitácora recibe el `loadFull` sin OR; con rol de
oficina sigue el detalle («Pendiente») y la bitácora vacía. Antes: `search` devolvía `[]`, el
botón estaba apagado y el toque daba el aviso.

## 4. H5 · El avance de la 22 sube en la 21 (P2, 10.52 y 10.56)

**Causa.** `loading_operation.dart`, `displayBay`: una par se contaba con la impar anterior si
existía (22 → 21) y el avance la rotulaba «21/22» (`operation_progress.dart`);
`loading_plan_progress.dart` repetía la misma regla con `plannedBays`.

**La regla, escrita una sola vez** en `lib/features/vessel/domain/services/reference_bay.dart`:
`referenceBay(bay, hasBay:)`: **la par es la bahía de referencia**; una impar se cuenta con la par
vecina que la cubre y que está en el plano (la 21 y la 23 con la 22; la 25 y la 27 con la 26); si
esa par no está, la impar queda sola; una par siempre es ella misma. «La par vecina» se decide por
lo que el plano trae y no por la convención ISO (02, 06, 10…), porque `CORPUS_A01` trae una 044
(conteo directo, 26-oct: A01 002 006 010 014 018 022 026 030 034 038 **044**; A07 y A08 solo
4k+2); `conventionalEvenBay` solo desempata si las dos vecinas estuvieran en el plano, cosa que la
numeración no permite. La toman `LoadingOperation.displayBay`, `OperationProgress` (las filas de
«Avance de la operación») y `LoadingPlanProgress` (`forBay`, la línea «Bahía 22: cubierta …»), y
por ellos la silueta del plano (`silueta_del_viaje.dart` lee `OperationProgress`). El rótulo del
grupo es la par («22»); `paired` sigue diciendo si el grupo cuenta alguna impar. Estadísticas la
adopta en `sprint-4` cuando la 3.1.1 pase allá. **Los movimientos guardados no cambian**: llevan
su posición física.

**Prueba (roja antes).** Grupo H5: con un 40 en la 22 y un 20 en la 21, `displayBay(21/22/23)`
da 22, el avance tiene una sola fila «22» con 1 cargado y 1 pendiente, y la silueta a 360 dp sube
«avance 50 %» bajo la 22 y nada bajo la 21; sin la par en el plano, la 21 y la 23 quedan solas.
Antes: `Actual: <21>` y la 22 «sin operación». `t122_dominio_test.dart`: la tabla de pares
convencionales, la 044 de A01 (43 y 45 → 44; 41 sola) y el desempate. **T-76 y T-78 cambiaron de
expectativa** (eran la regla vieja: `displayBay(4) == 3` y «la 03 emparejada»): ahora la 03 va
con la 04 del plan de carga, y en T-78 la 04 solo está en el plano de llegada, así que 03, 04 y 05
son filas propias.

## 5. H6 · Un vacío asignado a una celda reservada no aparece en ninguna búsqueda (P1, 10.56)

**Causa (10.56).** El vacío asignado vive solo como `assignedContainer` del estado de la
operación. La búsqueda general (`container_search_delegate.dart`) recorría `voyage.containers`, el
BAPLIE, donde la reserva no trae número; `LoadingOperation.search` solo daba las filas numeradas en
el plan (`numbered`), y un vacío asignado a una reserva no lo está; la Lista del viaje
(`filteredContainersProvider`) también recorría solo `voyage.containers`.

**Arreglo.**
- Dominio: `LoadingOperation.assigned(row)` (el vacío de la fila ya quedó asignado) y
  `assignedEmpties`: los vacíos asignados como `ContainerUnit` a bordo, con su número, su celda,
  su tipo, su tara (como peso), sus puertos y su línea (de la fila del listado o de la reserva);
  es la misma lectura que ya hacía el BAPLIE de salida, que no cambió. `search` incluye entre los
  llenos las filas cuyo vacío ya está asignado: «OR / últimos dígitos» lo ofrece por su OR y por
  sus dígitos, y la lista lo marca «Ya cargado» y abre su detalle (eso ya existía).
- Presentación: `aboardContainersProvider` (en `loading_operation_provider.dart`): lo del archivo
  más los vacíos asignados cuando el viaje carga en la escala; la búsqueda general y la Lista lo
  usan (con «Todas (n)» y las cuentas por naviera). `carriersListProvider` y
  `filteredContainersProvider` se movieron de `vessel_providers.dart` a ese archivo para no crear
  un ciclo de importaciones. Al elegir el resultado, el plano va a la bahía y resalta la reserva
  por el número asignado (`bay_plan_view.dart`). El detalle del contenedor (`DetalleContenedor`)
  muestra el vacío como cualquier otro.
- Revisadas las demás vistas que listan contenedores: la Lista y la búsqueda general (arregladas);
  el BAPLIE de salida y el plano ya lo tenían; las alertas de estiba, la comparación de viajes y
  las estadísticas leen el BAPLIE y no la operación, y no cambian en la 3.1.1 (anotado para
  `sprint-4`).

**Prueba (roja antes).** Grupo H6: con `assign_empty` de EMPTY0000012 a la reserva 003-08-82,
`search('12')`, `search('OR 12')` y `search('0012')` lo devuelven (antes `[]`), y la Lista lo trae
con su celda y su tipo; `t122_dominio_test.dart`: `assignedEmpties` y, en la página completa a
1300 dp, la búsqueda general lo encuentra, lleva a la bahía 3 y lo resalta.

## 6. H7 · En el teléfono, el arrastre no llega al otro extremo de la bahía (P2, 10.56)

**Causa.** `PlanDragCell` (`plan_drag_confirmation.dart`) era un `LongPressDraggable` dentro de
los dos `SingleChildScrollView` de la rejilla (`_BayGridWidget`, dentro de `PlanZoomViewport`), y
nada desplazaba la vista durante el arrastre; la celda fuera de la vista no se alcanzaba.

**Arreglo.** `_PlanDragSource`: mientras dura el arrastre, un `EdgeDraggingAutoScroller` por eje
(los dos `Scrollable` más cercanos, vertical y horizontal) desplaza el plano en cuanto el puntero,
dedo o mouse, queda a menos de 40 dp del borde de la vista; se mide en coordenadas de pantalla, así
que vale también con zoom; con el puntero quieto sigue (`onScrollViewScrolled` vuelve a situar el
objetivo). La franja que se mide es de un punto en el eje contrario, para no disparar la
comprobación del desplazador con rejillas de una sola fila. **Al soltar cuenta la celda que queda
bajo el puntero** aunque el plano se haya movido bajo un dedo quieto: el `DragTarget` de Flutter
solo cambia de candidato cuando el puntero se mueve, así que la celda la decide una prueba de toque
en ese punto (`_dropSpotAt`, con una marca `MetaData` por celda) y no el último objetivo que el
gesto visitó; los `DragTarget` quedan solo para la vista previa (verde, ámbar, rojo). Un gesto
cancelado por el sistema se trata como soltar en ese punto (abre la hoja, que se cancela).

**Prueba (roja antes).** `test/t122_arrastre_test.dart`, tres casos a 360 dp (dedo, dedo con zoom
al 125 %, mouse): con el puntero quieto en el borde derecho el desplazamiento horizontal llega al
final (antes se quedaba en 0.0); el puntero se posa sobre una reserva (vista previa de
intercambio); el plano vuelve a moverse bajo el puntero quieto y, al soltar, la hoja nombra la
celda que de verdad quedó debajo y no la última visitada. T-105 (los 11 casos del arrastre) sigue
en verde.

## 7. Verificación

### 7.1 Cada hallazgo con su prueba, roja antes del arreglo

`build/t122/01-rojo-antes-del-arreglo.log`: las dos pruebas nuevas sobre la 3.1.0 (`7488321`), **16
en rojo y 1 en verde** (la impar sola de H5, que ya funcionaba). `02-verde-tras-el-arreglo.log`:
las mismas y las vecinas (T-68, T-73, T-74, T-76, T-78, T-105, T-107) en verde tras el arreglo.

| Prueba | Casos | Qué reproduce |
|---|---|---|
| `test/t122_hallazgos_test.dart` | 14 | H1 (3), H3 (2), H4 (4), H5 (3), H6 (2), con la API de la 3.1.0 |
| `test/t122_arrastre_test.dart` | 3 | H7 con dedo, dedo con zoom al 125 % y mouse, a 360 dp |
| `test/t122_dominio_test.dart` | 8 | la regla de la par, los puertos de descarga, la fila sin OR, los vacíos a bordo, la búsqueda en la página |

### 7.2 La suite completa, una vez, y analyze

`flutter test --reporter expanded`, una sola corrida al final, con todo el código ya en su sitio
(`build/t122/03-suite-completa.log`): **+1396 · 0 fallos · 0 omitidas · «All tests passed!»** en
2:58 min. Una corrida anterior (de diagnóstico, antes de las capturas) dio 1395 con un solo rojo:
`t93_msix_config_test.dart` pedía `msix_version` 3.1.0.0; se actualizó a 3.1.1.0, que es lo que
10.56 manda. El piso de `master` era 1371 (10.34): las 25 de más son las 25 pruebas nuevas de T-122
(14 + 3 + 8), y T-68, T-76 y T-78 cambiaron de expectativa sin cambiar de número.

`flutter analyze lib test tool/t122_main.dart tool/t122_entradas.dart`: **No issues found**
(`04-analyze-lib-test.log`). `flutter analyze` del proyecto entero arrastra 13 incidencias de
`build/t112acc/*.dart` (copias viejas de un banco, fuera de Git; `04b-analyze-proyecto.log`), que no
son de esta tarea y ya estaban.

### 7.3 Capturas con datos sintéticos, en los dos temas

Banco `tool/t122_main.dart` (la app del producto con un panel «T122» para elegir la entrada
sintética, el rol y el tema; sin Firebase; almacén `t122cap`). Entradas de `tool/t122_entradas.py`
(`build/t122/entradas/`). Capturas en `build/t122/capturas/`:

| Cliente | Cómo | Tema claro | Tema oscuro |
|---|---|---|---|
| Windows (banco abierto con `explorer.exe`, PID anotado en `banco-windows.pid`; clics por el control del escritorio que Carlos autorizó y por `tool/t100_windows.ps1`; PNG por `PrintWindow`) | a mano, 1920 × 991 | 9 | 13 |
| Web (`build/t122/web` servida en 127.0.0.1:5902; `tool/t122_capturas_web.py`, Playwright, 1920 × 1080) | automático | 13 | 13 |
| Emulador (`emulator-5554`, 360 × 640 dp; `tool/t122_capturas_android.py`, adb + uiautomator; el arrastre con `sendevent`) | automático | 16 | 16 |

Por hallazgo (nombres `<cliente>_<tema>_<hallazgo>_<pantalla>.png`):
- **H1** `h1_parametros_escala` (las fichas «PAMIT (13) · CRPMN (4) · GTSTC (7) · USHOU (2)»),
  `h1_parametros_escala_elegida` («7 se descargan · 0 se cargan · 6 de paso»), `h1_plano_con_descarga`
  / `h1_modo_descarga` (el modo Descarga existe: «0 de 7 · por bajar 7»).
- **H3** `h3_agregados` («14 filas en 3 agencias · AGREGADOS: 2 · Todas las filas se entendieron»),
  `h3_importado`.
- **H4** `h4_busqueda_sin_or` (Windows: «TSTU0220071 · sin OR en el listado» por sus últimos
  dígitos), `h4_confirmar_sin_or` (el diálogo, rol muelle), `h4_registrado` («Carga registrada ·
  TSTU0220071», «1 de 29»).
- **H5** `h5_silueta_22` (la barra bajo la 22, nada bajo la 21 ni la 23), `h5_avance_22` (una fila
  «22» con 2 cargados · 17 pendientes y una «26»), `h5_confirmar_or1`.
- **H6** `h6_or_ultimos_digitos` («OR 12 · TSTU0012123 … Ya cargado» con «123»),
  `h6_busqueda_general` («Posición: Bahía 021, Fila 00, Nivel 84»), `h6_resaltado` (la reserva
  021-00-84 resaltada al elegir el resultado), `h6_lista_24` (Windows: la Lista cuenta 24 = 23 + el
  vacío asignado).
- **H7** (solo el teléfono) `h7_arrastre_en_marcha` (la copia de «OR 2» en el borde y el plano ya
  desplazado), `h7_sobre_la_celda` (la vista previa verde sobre 022-09-84, que antes no estaba a la
  vista), `h7_al_soltar` («Mover OR 2 · TSTU0220019 · 022-01-82 → 022-09-84»).

En Windows el tema claro se capturó sobre la misma operación después del recorrido en oscuro (la
escala de H1 reabriendo el plano de llegada desde «Viajes recientes»), por eso tiene menos tomas.
Los registros de los conductores (`06-android-*.log`, `07-web.log`) quedan en `build/t122/`.

## 8. H2 · El listado no entra en una operación publicada (P1, 10.50): diagnóstico y propuesta

**No se implementa en la 3.1.1** (10.56). Lo que sigue es lo que hay en el código y en las reglas,
y lo que haría falta tocar; decide Carlos.

### 8.1 Cómo viajan hoy las fuentes por la nube

- **Al publicar** (`firestore_operation_sync.dart`, `publish`): la oficina escribe en **un solo
  lote** y **solo si el documento no existe** (`if (!existing.exists)`): el documento
  `operations/{id}` con el campo `sources`, un manifiesto por tipo de fuente
  (`arrival_baplie`, `loading_baplie`, `export_list`) con `fileName`, `sha256` del texto
  entero, `parts` y `length`; y los trozos `operations/{id}/sources/{tipo}-{i}` (300 000
  caracteres cada uno, con `kind`, `part`, `parts`, `sha256`, `content`, `createdBy`,
  `createdAt`). El listado viaja como `export_list`, el JSON normalizado de
  `ExportList.toJson()`, **únicamente si ya era una fuente de la operación en ese momento.**
  Después de publicar, `publish` no vuelve a escribir nada («si ya estaba, basta marcarla»).
- **Al unirse** (`join`): el muelle lee el documento y **todos** los trozos de `sources`, por
  tipo comprueba que el número de trozos sea el del manifiesto y que la huella de cada trozo y
  del texto unido sea la del manifiesto (`source_mismatch` si no), y guarda la operación en su
  bitácora local **una vez**, con sus fuentes dentro. Nadie vuelve a mirar el manifiesto: `follow`
  (el `SyncEngine`) solo escucha `movements`.
- **En el dispositivo** (`operation_sources.dart`, `OperationSources.save`): una operación
  publicada acepta únicamente la misma fuente con el mismo texto; cualquier fuente nueva o
  distinta lanza el `ValidationFailure` que Carlos vio («…sus fuentes no cambian»). Es lo que
  llama `exportListImportProvider.confirm` al importar el listado.

### 8.2 Qué permiten las reglas publicadas (`docs/T80-firestore.rules.propuesta`)

- `operations/{id}`: `update` solo con `validClosing()`: de `open` a `closed`, una vez, y
  `affectedKeys().hasOnly(['status', 'closedBy', 'closedAt'])`. **El manifiesto `sources` no
  puede cambiar** después de crearse.
- `operations/{id}/sources/{sourceId}`: `create` para la oficina mientras la operación esté
  abierta, con `kind` en los tres tipos, `part < parts ≤ 20`, `sha256` hex de 64, `content`
  ≤ 900 000, `createdBy == uid`, `createdAt == request.time`; `update` y `delete` prohibidos.
- Consecuencia (corregida en la corrección 2, O1 de Codex): hoy la oficina **sí podría crear**
  trozos nuevos (por ejemplo `export_list-0` en una operación que se publicó sin listado), pero
  el manifiesto no diría que existen, y `join` **los ignoraría**: recorre solo los tipos que el
  manifiesto declara (`for (final kind in OperationSourceKind.values) … if (entry is! Map)
  continue`), así que un trozo de un tipo sin entrada no llega al muelle. Lo que `join` rechaza
  (`source_mismatch`, la operación entera) es un tipo **declarado** cuyos trozos no cuadran en
  número o en huella; por eso tampoco sirve crear trozos nuevos de un tipo ya declarado (un
  `export_list` de reemplazo). Es decir: **sin tocar las reglas no hay forma coherente** de
  agregar ni de reemplazar el listado después de publicar, porque el manifiesto es lo que
  manda y no cambia. Tampoco cabe meter el listado en un movimiento: `validPayload` valida cada
  tipo de movimiento con sus campos, y no es lo que un movimiento significa.

### 8.3 Propuesta (decide Carlos; las reglas no se tocan sin él)

**Regla de diseño:** los BAPLIE siguen inmutables (son el contrato de las claves naturales de
los movimientos); el **listado** es la única fuente que la oficina puede **agregar o
reemplazar** mientras la operación esté abierta, y viaja con **revisión**.

1. **Nube (reglas, dos cláusulas nuevas).**
   - En `operations/{id}`: `allow update: if isOffice() && (validClosing() || validListRevision())`,
     con `validListRevision()` = la operación sigue `open`, `affectedKeys().hasOnly(['sources'])`,
     y de `sources` solo cambia la entrada `export_list` (las otras dos iguales), que trae
     `fileName`, `sha256`, `parts`, `length` y un entero `revision` mayor que el anterior
     (o 1 si no había listado).
   - En `sources/{sourceId}`: `validSource` acepta además el id `export_list-r{revision}-{i}`
     con un campo `revision` igual al que `getAfter` ve en el manifiesto. Los trozos viejos
     no se borran (siguen sin `update`/`delete`): son historia, y `join` los filtra por
     revisión.
   - Los movimientos no cambian de reglas.
2. **Oficina (cliente).** `OperationSources.save` acepta en una operación publicada una fuente
   `export_list` nueva o distinta (solo esa), y la sube por un método nuevo del contrato
   `OperationSyncRepository.replaceSource(operation, source)`: escribe los trozos con la
   revisión nueva y actualiza el manifiesto en un lote; si falla, no toca nada local. Luego
   `operationSourcesRevisionProvider.changed()` vuelve a derivar el plan con el listado nuevo.
3. **Muelle (cliente).** `follow` escucha también el documento de la operación; cuando
   `sources.export_list.revision` sea mayor que la local, baja solo los trozos de esa
   revisión, comprueba la huella como `join`, guarda la fuente en la operación local y avisa
   («Listado actualizado por la oficina: n filas»). Sin red, el muelle sigue con el listado
   que tenía hasta reconectar; la `SyncStatus` ya existe para decirlo.
4. **Los movimientos no se pierden.** Viven en `movements/`, con claves naturales (`C:número`,
   `R:posición`) que no dependen del listado; `OperationStateDeriver` los vuelve a aplicar con
   el listado nuevo. Lo único que el listado cambia es lo que ya cambia hoy al importarlo
   antes de publicar: los rótulos OR, los grupos de los vacíos (`plan.emptyGroups`, que
   reevalúa los conflictos `otherGroup`) y los datos exactos con que el BAPLIE de salida
   escribe lo cargado: con fila, el VGM y la tara del listado; sin fila, desde la corrección 1
   (8bis), el grupo del plan de carga para un lleno, y para un vacío asignado la fila sigue
   siendo necesaria (corregido en la corrección 2, O1 de Codex: el escritor ya no exige la
   fila del lleno). Por eso el cruce al importar debe avisar antes de confirmar: «n
   contenedores ya cargados no están en el listado nuevo» y «m vacíos asignados cambian de
   grupo», y la 3.1.1 ya deja cargar los llenos sin fila (H4), así que un listado tardío solo
   cuesta los OR, los pesos exactos de los llenos y los vacíos.
5. **Pruebas:** el motor (`t79_fake_cloud.dart`) con una revisión 2 que llega al muelle con y
   sin movimientos previos; las reglas con `tool/t80_reglas.mjs` (una revisión por la oficina
   pasa, por el muelle no; un trozo con revisión distinta de la del manifiesto no pasa; la
   entrada `loading_baplie` no cambia).

**Mientras tanto, en el piloto:** importar el listado **antes** de publicar (el camino que
funcionó el 25-oct a las 23:11, 10.52). Con H4, un listado que llega tarde ya no bloquea la
carga de llenos.

## 8bis. Corrección 1 (10.57): el BAPLIE de salida con un lleno cargado sin fila (P1)

**El defecto.** Con H4, un lleno cargado por su número sin fila en el listado dejaba la operación
sin BAPLIE de salida: `DepartureBaplieWriter` exigía la fila de cada lleno cargado que no venía en
el plano de llegada y se detenía con «El contenedor cargado … no está en el listado…». En una
operación publicada sin listado la oficina tampoco puede importarlo después (H2), así que la
salida no se generaba nunca. Lo nombraba en 8.3, punto 4, sin prueba.

**El arreglo (`departure_baplie_writer.dart`).** Un lleno cargado sin fila sale en la celda donde
quedó con **el grupo de segmentos que el plan de carga le dio**, como ya salía lo que sigue a
bordo: `LOC+147` con la posición real y, tal cual, los demás segmentos del plan (peso WT o VGM,
tara si venía, puertos, línea, DGS y lo que el lector no modela, como FTX). Elegí esta vía y no la
fila que arma `ExportListRow.fromPlan` porque **no inventa nada**: son los datos que la agencia
transmitió, y `_loaded` con una fila armada exigiría un VGM que el plan muchas veces no trae (solo
WT) y perdería los segmentos que el lector no modela. Lo que la fila añadiría (VGM y tara exactos,
marchamo) no se adivina. Si hay fila, todo sigue como hoy: los datos exactos salen del listado.
Un **vacío asignado** sin fila sigue pidiendo el listado, ahora con su aviso propio («El vacío
asignado … no está en el listado; su fila trae la tara y el tipo exactos»): la reserva no tiene
grupo con número en el plan y su tara y tipo exactos solo están en la fila (H4: los vacíos esperan
el listado). `DepartureBaplie.withoutRow` lista esos llenos y la página (`departure_baplie_page.dart`)
dice «n llenos van con los datos del plan de carga porque no tienen fila en el listado: …»
(`departure-without-row`).

**Prueba (roja antes).** `test/t122c1_salida_sin_fila_test.dart`, cinco casos:
sin listado (H4) el lleno cargado por su número sale en 003-02-82 con `MEA+WT++KGM:7200`, los
puertos y la línea del plan y `withoutRow == [TSTU0000014]`, y lo que sigue a bordo igual que
antes; con un listado al que le falta esa fila, el lleno sale con el plan y el vacío asignado con
su fila (tara 2185); con la fila, los datos exactos del listado (VGM 7266.59, tara 3900, dos ONU)
y `withoutRow` vacío; un vacío asignado sin fila sigue deteniéndose con su aviso; un lleno cargado
en otra celda que la planificada sale en la real. Antes del arreglo: 3 de 4 en rojo con «no está
en el listado» (`build/t122/c1/01-rojo-antes-del-arreglo.log`). **T-82 cambió de expectativa**
(«no inventa datos de un cargado ausente del listado»): ahora el cargado sale con el plan, sin VGM
inventado, y el vacío asignado sin fila sigue lanzando.

**Otras salidas que exijan la fila (revisión).** Ninguna la exige: la exportación CSV/JSON/PDF
(`export_service.dart`, `pdf_report_service.dart`) y la comparación leen el viaje; la bitácora se
exporta por `Operation.toJson(includeContent: false)` y sus movimientos, sin listado; el cierre de
la operación (`FirestoreOperationSync.close`) no mira las fuentes; el avance (`operation_progress.dart`),
la validación de carga (`load_check.dart`) y la bandeja de cambios (`change_requests_page.dart`)
usan la fila solo si existe (OR y pesos exactos). El listado sigue siendo necesario únicamente para
los vacíos (asignarlos y escribirlos en la salida).

**Verificación.** `build/t122/c1/02-verde-tras-el-arreglo.log`: la prueba nueva, T-82 (escritor) y
T-82 (página), 21 de 21. `03-suite-completa.log`: la suite completa, una sola corrida, **1401 de
1401**, sin omitidas (1396 + las 5 de la corrección). `04-analyze-lib-test.log`: `flutter analyze
lib test`, **No issues found**.

**Captura.** `build/t122/c1/capturas/`, Web a 1920 × 1080 con `tool/t122_c1_captura_web.py`
(datos sintéticos, sin listado, el lleno TSTU0220071 cargado por sus últimos dígitos):
`web_claro_c1_salida_lleno_sin_fila.png` y `web_oscuro_c1_salida_lleno_sin_fila.png`, la página
«BAPLIE de salida» con «1 contenedores a bordo en la salida · Pendientes: 28 de carga y 0 de
descarga · 1 lleno va con los datos del plan de carga porque no tiene fila en el listado:
TSTU0220071» y el botón «Guardar BAPLIE de salida» activo; y `web_<tema>_c1_h4_sin_listado_registrado.png`,
el diálogo de esa carga. Antes del arreglo la misma página decía «El contenedor cargado … no está
en el listado» y no generaba nada.

**Archivos de la corrección:** `lib/features/vessel/domain/services/departure_baplie_writer.dart`,
`lib/features/vessel/presentation/pages/departure_baplie_page.dart`,
`test/t122c1_salida_sin_fila_test.dart` (nuevo), `test/t82_departure_baplie_test.dart`,
`tool/t122_c1_captura_web.py` (nuevo), `tool/t122_entradas.py` y `tool/t122_entradas.dart` (los
BAPLIE sintéticos del banco llevan ahora el sobre EDIFACT completo, UNB/UNH … UNT/UNZ, que la salida
exige; las capturas de T-122 se tomaron sin él y por eso traen el aviso «faltan 4 segmentos»), este
informe. Evidencia en `build/t122/c1/` (fuera de Git).

**Git de la corrección (Carlos, en `master`):**

```powershell
Set-Location -LiteralPath C:\Proyectos\proyecto-baystream
git add -- lib/features/vessel/domain/services/departure_baplie_writer.dart
git add -- lib/features/vessel/presentation/pages/departure_baplie_page.dart
git add -- test/t122c1_salida_sin_fila_test.dart
git add -- test/t82_departure_baplie_test.dart
git add -- tool/t122_c1_captura_web.py
git add -- tool/t122_entradas.py
git add -- tool/t122_entradas.dart
git add -- docs/T122-RESULTADOS.md
git commit -m "Sprint 4: T-122 correccion 1 (10.57), el BAPLIE de salida incluye los llenos cargados sin fila del listado con los datos del plan de carga" --trailer "Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
git push origin master
git log --oneline -1
```

## 8ter. Corrección 2 (10.59): A1, O1 y O2 de la aceptación de Codex

### A1 · P2 · Sin listado, un vacío con número se cargaba como lleno, con tara 0

**La causa** (como la dio Codex): `LoadingOperation.unlistedRows` no miraba si el contenedor
era lleno, y `ExportListRow.fromPlan` contemplaba «un vacío con número». Así, sin listado,
«OR / últimos dígitos» ofrecía el MNLU0000811 de `T100_CARGA` «sin OR en el listado», con «Tara
real: 0 kg», y quedaba cargado como `load_full`.

**La regla (10.51, que no cambia):** sin fila en el listado solo se cargan los contenedores que el
plan declara **llenos**. Un vacío con número, y uno que el plan no declara ni lleno ni vacío,
necesitan su fila: de ahí salen su tara y su tipo exactos, que la salida necesita.

**El arreglo.**
- `LoadingOperation.unlistedRows` solo da los llenos (`status == ContainerStatus.full`), así que ni
  «OR / últimos dígitos» ni `unlistedRow` ofrecen el vacío con número ni el sin estado.
- `LoadingOperation.needsRow(id)` dice por qué un contenedor del plan no se carga sin su fila
  («El vacío X espera el listado de la agencia: su fila trae la tara y el tipo exactos…», «X no
  declara lleno ni vacío en el plan: espera el listado…», o «no está en el plan de carga»), y
  `draft` rechaza con ese motivo una fila sin OR que no sea de un lleno, aunque alguien la pase.
- En el muelle, tocar la celda de ese vacío sin fila no abre «Confirmar carga»: el aviso es el de
  `needsRow`. Tocar un lleno sin fila sigue abriéndolo (H4).
- El comentario de `ExportListRow.fromPlan` ya no habla de «un vacío con número».

**Prueba (roja antes).** `test/t122c2_vacio_con_numero_test.dart`, tres casos, con un plan sin
listado que trae un lleno, un vacío con número (como el MNLU0000811, `status: empty`) y un
contenedor sin estado: `unlistedRows` y la búsqueda solo dan el lleno y «811»/«900» no devuelven
nada; `draft` rechaza la fila armada del vacío y del sin estado y acepta la del lleno sin `order`;
en el plano, con rol de muelle, tocar el vacío no abre «Confirmar carga», avisa que espera el
listado y la bitácora queda vacía, y tocar el lleno sí lo abre. Antes del arreglo, los tres en
rojo (`build/t122/c2/01-rojo-antes-del-arreglo.log`: el vacío se ofrecía, el borrador salía y el
diálogo se abría).

### O1 · P3 · Dos matices del diagnóstico de H2, corregidos en 8.2 y 8.3

- 8.2: `join` recorre solo los tipos que el manifiesto declara, así que **ignora** los trozos de
  un tipo sin entrada; lo que rechaza (`source_mismatch`) es un tipo declarado cuyos trozos no
  cuadran. La conclusión no cambia: el manifiesto es inmutable y sin reglas nuevas no hay forma
  coherente de agregar ni de reemplazar el listado.
- 8.3, punto 4: desde la corrección 1 el escritor ya no exige la fila del lleno; la fila sigue
  dando los pesos exactos, y sigue siendo necesaria para el vacío asignado.

### O2 · P3 · El error de la Web del banco al arrancar

**Viene del panel del banco, no del producto, y no se toca.** Lo aislé con
`tool/t122_c2_error_web.py` (Playwright en un perfil temporal, sin tocar nada, 8 s escuchando
`pageerror` y `console.error`) sobre tres compilaciones Web, las tres servidas en 127.0.0.1:

| Compilación | Modo | Errores al arrancar | Evidencia |
|---|---|---|---|
| Banco de T-122 (`tool/t122_main.dart`, `master`) | release | 1 `pageerror` | `build/t122/c2/errores-banco-t122-master.json` |
| El mismo banco | profile (nombres legibles) | 1, con pila: `WidgetsFlutterBinding.handleViewFocusChanged` → `_ViewState.didChangeViewFocus` → `ReadingOrderTraversalPolicy._findInitialFocus` → `FocusScopeNode.rect` → `RenderSemanticsAnnotations.size` (un `RenderBox` sin layout) | `errores-banco-t122-master-profile.json` |
| Banco de T-99 (`tool/t99_main.dart`, el producto sin panel), `master` | profile | **0** | `errores-t99-master.json` |
| Banco de T-99 en una copia limpia de `7488321` (la 3.1.0) en `%TEMP%\t122-c2-7488321` | profile | **0** | `errores-t99-7488321.json` |

Es el mismo error que vio Codex. Lo dispara el navegador al dar el foco a la vista de Flutter en
el primer cuadro, y el recorrido de foco por orden de lectura mide el `RenderBox` de un nodo con
foco que todavía no tiene layout: el `InkWell` de la pestaña «Banco T122» que mi banco pone en un
`Stack` encima de la app, en el `builder` de `BayStreamApp`. Con el producto sin ese panel (el
banco de T-99) no aparece, ni en `master` ni en la 3.1.0. Conclusión: **no es del producto ni es
nuevo de la 3.1.1**; es del panel del banco de capturas, y no lo corrijo (10.59: solo si fuera del
producto). La página se dibuja y todo funciona después, como anotó Codex.

### Verificación

`build/t122/c2/01-rojo-antes-del-arreglo.log`: los tres casos de A1 en rojo sobre `6086bb5`.
`02-verde-tras-el-arreglo.log` y `02b-widget.log`: la prueba nueva y las de T-122 (hallazgos,
dominio, corrección 1) en verde. `03-suite-completa.log`: la suite completa, una sola corrida,
**1404 de 1404**, sin omitidas (1401 + los 3 de A1). `04-analyze-lib-test.log`: `flutter analyze
lib test`, **No issues found**. Sondas de O2: `errores-*.json`, con su PNG del arranque.

### Captura

`build/t122/c2/capturas/`, Web a 1920 × 1080 con `tool/t122_c2_captura_web.py`, datos sintéticos,
muelle local sin listado, en los dos temas (12 PNG, `web_<tema>_c2_<paso>.png`):
- `vacio_con_numero_espera_el_listado`: tocar el vacío con número TSTU0210284 en la bahía 21 da el
  aviso «El vacío TSTU0210284 espera el listado de la agencia: su fila trae la tara y el tipo
  exactos. Importa el listado para cargarlo», sin «Confirmar carga»;
- `sin_estado_espera_el_listado`: igual con TSTU0210480, «no declara lleno ni vacío en el plan»;
- `or_solo_ofrece_llenos` (la lista sin filtrar trae solo llenos «sin OR en el listado»),
  `or_no_ofrece_el_vacio` («0284» → «No hay coincidencias disponibles») y `or_ofrece_el_lleno`
  («0071» → «TSTU0220071 · sin OR en el listado»);
- `lleno_sin_fila_registrado`: el lleno sí se carga (H4).

**Archivos de la corrección:** `lib/features/vessel/domain/services/loading_operation.dart`,
`lib/features/vessel/domain/entities/export_list.dart` (comentario),
`lib/features/vessel/presentation/widgets/loading_controls.dart`,
`test/t122c2_vacio_con_numero_test.dart` (nuevo), `tool/t122_entradas.py` y `tool/t122_entradas.dart`
(el plan sintético trae ahora un vacío con número y uno sin estado), `tool/t122_c2_captura_web.py`
y `tool/t122_c2_error_web.py` (nuevos), este informe. Evidencia en `build/t122/c2/` (fuera de Git).

**Git de la corrección 2 (Carlos, en `master`):**

```powershell
Set-Location -LiteralPath C:\Proyectos\proyecto-baystream
git add -- lib/features/vessel/domain/services/loading_operation.dart
git add -- lib/features/vessel/domain/entities/export_list.dart
git add -- lib/features/vessel/presentation/widgets/loading_controls.dart
git add -- test/t122c2_vacio_con_numero_test.dart
git add -- tool/t122_entradas.py
git add -- tool/t122_entradas.dart
git add -- tool/t122_c2_captura_web.py
git add -- tool/t122_c2_error_web.py
git add -- docs/T122-RESULTADOS.md
git commit -m "Sprint 4: T-122 correccion 2 (10.59), sin listado solo se cargan los llenos del plan; 8.2 y 8.3 corregidos; diagnostico del error de la Web al arrancar" --trailer "Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
git push origin master
git log --oneline -1
```

## 9. Archivos tocados

**Dominio y datos (lo mínimo para H1, H3, H4, H5 y H6; 10.52 y 10.56):**
- `lib/features/vessel/domain/entities/vessel_voyage.dart` — `dischargePortCounts`, `suggestPortOfCall` (H1).
- `lib/features/vessel/data/services/export_list_parser_service.dart` — la sección «AGREGADOS» (H3).
- `lib/features/vessel/domain/entities/export_list.dart` — `ExportListRow.fromPlan`, `unlisted`, `name`, `label` (H4).
- `lib/features/vessel/domain/services/loading_operation.dart` — `unlistedRows`, `unlistedRow`, `assigned`, `assignedEmpties`, `search`, `draft`, `displayBay` (H4, H5, H6).
- `lib/features/vessel/domain/services/load_check.dart` — los avisos nombran la fila por `row.name` (H4).
- `lib/features/vessel/domain/services/reference_bay.dart` — **nuevo**, la regla de la par (H5).
- `lib/features/vessel/domain/services/loading_plan_progress.dart`, `operation_progress.dart` — la regla y el rótulo del grupo (H5).

**Presentación:**
- `lib/features/vessel/presentation/pages/vessel_geometry_page.dart` — las fichas de los puertos de descarga (H1).
- `lib/features/vessel/presentation/widgets/loading_controls.dart` — el toque sin fila, «OR / últimos dígitos» sin listado, los rótulos sin OR, el detalle (H4).
- `lib/features/vessel/presentation/widgets/loading_plan_controls.dart` — `disponible:` (H4).
- `lib/features/vessel/presentation/providers/loading_operation_provider.dart` — `aboardContainersProvider`; recibe `carriersListProvider` y `filteredContainersProvider` (H6).
- `lib/features/vessel/presentation/providers/vessel_providers.dart` — se van esos dos providers (H6).
- `lib/features/vessel/presentation/pages/vessel_overview_page.dart` — la búsqueda y la Lista recorren lo que va a bordo (H6).
- `lib/features/vessel/presentation/widgets/bay_plan_view.dart` — resalta la reserva por el vacío asignado (H6).
- `lib/features/vessel/presentation/widgets/plan_drag_confirmation.dart` — `_PlanDragSource`, `_dropSpotAt`, `_PlanDropSpot` (H7).

**Pruebas:** `test/t122_hallazgos_test.dart` (nuevo), `test/t122_arrastre_test.dart` (nuevo),
`test/t122_dominio_test.dart` (nuevo); `test/t68_port_of_call_test.dart`, `test/t76_loading_test.dart`,
`test/t78_operation_progress_test.dart` (expectativas de las reglas viejas, H1 y H5);
`test/t93_msix_config_test.dart` (la versión 3.1.1.0).

**Versión:** `pubspec.yaml` (`version: 3.1.1+5`, `msix_version: 3.1.1.0`); `pubspec.lock` no cambia.

**Herramientas (fuera de `lib/`):** `tool/t122_entradas.py` (genera las entradas sintéticas),
`tool/t122_entradas.dart` (generado), `tool/t122_main.dart` (el banco de capturas),
`tool/t122_capturas_android.py`, `tool/t122_capturas_web.py` (los conductores).
`tool/t100_windows.ps1` se usó tal cual para Windows.

**No se tocó:** `lib/main.dart`, las opciones de Firebase, las reglas, `lib/latency_test_screen.dart`,
`lib/c3_reconciliation_screen.dart`, `docs/piloto/LISTA-PILOTO.md`, las dependencias. Ningún
`// ignore:`. Los documentos de Carlos en `docs/` (docx, pdf, pptx) no se tocan ni van en el bloque.

## 10. Bloque de Git para Carlos

Desde `C:\Proyectos\proyecto-baystream`, en `master`. Un `git add` por ruta; `pubspec.yaml` va
declarado; `pubspec.lock` no cambia. Nada de `build/` entra.

```powershell
Set-Location -LiteralPath C:\Proyectos\proyecto-baystream
git add -- pubspec.yaml
git add -- lib/features/vessel/domain/entities/vessel_voyage.dart
git add -- lib/features/vessel/domain/entities/export_list.dart
git add -- lib/features/vessel/domain/services/reference_bay.dart
git add -- lib/features/vessel/domain/services/loading_operation.dart
git add -- lib/features/vessel/domain/services/load_check.dart
git add -- lib/features/vessel/domain/services/loading_plan_progress.dart
git add -- lib/features/vessel/domain/services/operation_progress.dart
git add -- lib/features/vessel/data/services/export_list_parser_service.dart
git add -- lib/features/vessel/presentation/pages/vessel_geometry_page.dart
git add -- lib/features/vessel/presentation/pages/vessel_overview_page.dart
git add -- lib/features/vessel/presentation/providers/loading_operation_provider.dart
git add -- lib/features/vessel/presentation/providers/vessel_providers.dart
git add -- lib/features/vessel/presentation/widgets/loading_controls.dart
git add -- lib/features/vessel/presentation/widgets/loading_plan_controls.dart
git add -- lib/features/vessel/presentation/widgets/bay_plan_view.dart
git add -- lib/features/vessel/presentation/widgets/plan_drag_confirmation.dart
git add -- test/t122_hallazgos_test.dart
git add -- test/t122_arrastre_test.dart
git add -- test/t122_dominio_test.dart
git add -- test/t68_port_of_call_test.dart
git add -- test/t76_loading_test.dart
git add -- test/t78_operation_progress_test.dart
git add -- test/t93_msix_config_test.dart
git add -- tool/t122_entradas.py
git add -- tool/t122_entradas.dart
git add -- tool/t122_main.dart
git add -- tool/t122_capturas_android.py
git add -- tool/t122_capturas_web.py
git add -- docs/T122-RESULTADOS.md
git commit -m "Sprint 4: T-122, la 3.1.1 con los hallazgos del piloto (H1 escala de descarga, H3 AGREGADOS, H4 carga sin listado, H5 la par de referencia, H6 vacio asignado en las busquedas, H7 arrastre con desplazamiento), version 3.1.1+5 y diagnostico de H2" --trailer "Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
git push origin master
git log --oneline -1
```
