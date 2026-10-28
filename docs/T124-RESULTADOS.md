# T-124 · La regla de la par en la presentación — Resultados

**Programador:** Timonel (Claude Code). **Fecha:** 27 de octubre de 2026.
**Base:** `sprint-4` en `2cce28f` (la 10.65), en `C:\Proyectos\baystream-rediseno`.
**Decisiones:** `SPRINT-4.md` 10.52, 10.53, 10.56, 10.61, 10.64 y 10.65; la aceptación de T-123
(`docs/t123/aceptacion-codex.md`, sección 5).

Datos sintéticos en todo: el buque de T-76, el plan de carga de T-122 (`BUQUE PRUEBA T122`,
`TSTU…`), el plano de llegada de T-100 (`BUQUE MANUAL`, `MNLU…`) y el sintético de 977 de T-99
(`T99 SINTETICO 977`, `SNTU…`). Nada del piloto ni del corpus real. Evidencia en `build/t124/`
(fuera de Git).

## 0. Resumen

| Punto | Qué cambia | Dónde | Prueba (roja antes) |
|---|---|---|---|
| 1 · P2, la ficha de la bahía | Dice lo de la bahía que se ve con su número y lo del grupo con el rótulo de su par | `resumen_del_modo.dart`; `DESIGN.md` 14.7 | `t124_par_test.dart`, grupo 1 (5 casos, 4 rojos y 1 guarda) |
| 2 · Estadísticas con la regla de la par | Cada impar se cuenta con la par vecina que la cubre; la columna y la fila llevan la par y abren la par | `estadisticas_del_viaje.dart`; `DESIGN.md` 15 | grupo 2 (5 casos, 4 rojos y 1 guarda) |
| 3 · P3, la salida | «1 contenedor a bordo en la salida» | `departure_baplie_page.dart` | 1 caso, rojo |
| 4 · O1, el conductor del arrastre | Contacto nuevo en cada gesto, se levanta siempre (`finally`) y no evalúa el borde si la celda no se levantó | `tool/t123_capturas_android.py` | `tool/t124_conductor_prueba.py` (3 casos, los 3 rojos) |
| 5 · Los vacíos asignados en otras vistas | Solo propuesta, sin código | sección 5 | — |

**Cifras:** la suite completa, **1832 de 1832** en una sola corrida, sin reintentos ni omitidas (el
piso era 1821; entran las 11 de `t124_par_test.dart`); `flutter analyze lib test` en **cero**.
Las pruebas de T-121 que esperaban la regla vieja pasan a la nueva (sección 4). Capturas: **65** PNG sintéticos en los dos temas (la Web 24, Windows 17, el emulador 24), sección 6.

## 1. P2 · La ficha de la bahía (14.7)

**El defecto (Codex, aceptación de T-123, sección 5).** Con la 21 elegida, la ficha decía «Bahía 22:
7 contenedores, 1 celda reservada, 57.7 t…; por cargar cub. 27». Las cifras eran de la 21 y el
rótulo y lo pendiente, del grupo de la 22, que tiene 11. La causa: `fichasDelResumen` rotulaba con
`enLaBahia.label`, el rótulo del grupo que da `forBay(21)` desde H5, y ponía delante las cifras de la
bahía elegida.

**El texto que propongo, y que queda escrito en `DESIGN.md` 14.7:**

| Dónde | Bahía sola | Bahía de un grupo |
|---|---|---|
| Oficina, Carga | «Bahía 10: 20 contenedores, 231.9 t; por cargar cub. 2, bod. 7» (como antes) | «Bahía 21: 7 contenedores, 1 celda reservada, 57.7 t, tapas sin declarar; **grupo 22 (21, 22 y 23)**, por cargar cub. 27, bod. 0» |
| Oficina, Contenido u Orden | «Bahía 10: …; carga: cub. 2 (…), bod. 7 (…)» | «Bahía 23: …; **carga del grupo 22 (21, 22 y 23)**: cub. 27 (…), bod. 0 (…)» |
| Teléfono, Carga | «Bahía 10: cub. 2, bod. 7» | «Bahía 21: **grupo 22 (21, 22 y 23)**, cub. 27, bod. 0» |
| Teléfono, Contenido | «Bahía 10, carga: cub. 2 (…), bod. 7 (…)» | «Bahía 21, **carga del grupo 22 (21, 22 y 23)**: cub. 27 (…), bod. 0 (…)» |

- **El rótulo de la ficha es siempre la bahía elegida;** sus cifras son las suyas.
- **Lo del grupo lleva «grupo», el número de la par y, entre paréntesis, las bahías que cuenta:** las
  del plan de carga que la regla de `reference_bay.dart` cuenta con esa par, más la elegida si es
  una mitad de 20 sin carga propia («grupo 02 (01 y 02)»).
- **Se nombra el grupo** cuando la bahía elegida no es la par, o cuando la par cuenta alguna impar
  (`BayLoadingPending.paired`). Con la 22 elegida también se dice, porque su «por cargar» incluye la
  21 y la 23. Una bahía que no cuenta otra sigue exactamente como antes.
- En Descarga no hay grupo: lo pendiente de bajar es de cada bahía (`DischargeProgress`, sin cambios).
- Las claves no cambian (`loading-bay-pending`, `bay-loading-pending`).

**El arreglo.** `fichasDelResumen` rotula con `rotuloDeBahia(bahia)` y añade el grupo con
`grupoDeLaPar(bahia, grupo, plan)`, una función nueva del mismo archivo que solo lee el plan y usa
`referenceBay` del dominio. `domain/` y `data/` no se tocan.

**Prueba (roja antes).** `test/t124_par_test.dart`, grupo 1, con un plan sintético de dos 40 en la
22, un 20 en la 21, otro en la 23 y uno solo en la 26:

| Caso | Antes (`build/t124/01-rojo-antes-del-arreglo.log`) | Ahora |
|---|---|---|
| Oficina, Carga, 21 | «Bahía 22: 1 contenedor, 0.0 t, tapas sin declarar; por cargar cub. 4, bod. 0» | «Bahía 21: 1 contenedor, …; grupo 22 (21, 22 y 23), por cargar cub. 4, bod. 0» |
| Oficina, Carga, 22 | «Bahía 22: 2 contenedores, …; por cargar cub. 4, bod. 0» | «…; grupo 22 (21, 22 y 23), por cargar cub. 4, bod. 0» |
| Oficina, Carga, 26 (guarda) | «Bahía 26: 1 contenedor, …; por cargar cub. 1, bod. 0» | igual, sin «grupo» |
| Oficina, Contenido, 23 | «Bahía 22: 1 contenedor, …; carga: cub. 4 (…)» | «Bahía 23: …; carga del grupo 22 (21, 22 y 23): cub. 4 (4 llenos, 0 vacíos), bod. 0 (0 llenos, 0 vacíos)» |
| Teléfono, Carga, 21 | «Bahía 22: cub. 4, bod. 0» | «Bahía 21: grupo 22 (21, 22 y 23), cub. 4, bod. 0» |

## 2. Estadísticas con la regla de la par (15)

**Lo que pasaba (10.53).** `EstadisticasDelViaje` hacía una columna por número de bahía: con
`T100_LLEGADA` eran nueve columnas, seis en cero (las mitades de 20 vecinas de los de 40), y el
avance ya contaba con la par (H5).

**El arreglo (`estadisticas_del_viaje.dart`).** Cada número de bahía del viaje (las de
`voyage.bays` y las de las posiciones) se cuenta con su bahía de referencia,
`referenceBay(numero, hasBay: <las bahías del viaje>)`, la misma regla del avance. La columna suma
cubierta, bodega y peso de sus bahías y lleva el número de la par. Como la silueta y «Ver como
tabla» leen la misma lista, las dos cuentan igual sin tocar `BsBuqueEnCorte` ni
`VoyageStatsView`, y **tocar la columna abre la par en el plano** (`onSeleccion(numero)`).
«Bahías con carga» cuenta bahías de referencia. Lo demás de la página no cambia.

| Viaje | Antes | Ahora |
|---|---|---|
| Forma de `T100_LLEGADA` (01 a 11) | 9 columnas, 6 en cero | **3: 02, 06 y 10**, cada una en su tope (168 dp) y el casco centrado a 1920 |
| Sintético de 977 (72 números) | 72 columnas | **24: 02 a 94** |
| T-117 (02 y 06, con 01, 03, 05 y 07 vacías) | 6 | 2 |
| Impares sin par vecina (01, 05, 09) | 3 | 3 (quedan solas) |

**Prueba (roja antes).** Grupo 2 de `t124_par_test.dart`: las cuatro cifras de la tabla de arriba, y
en pantalla a 1920 las tres columnas en su tope con el casco centrado, sin las impares en la silueta
ni en la tabla, y tocar la 02 la abre. Antes, `[1, 2, 3, 5, 6, 7, 9, 10, 11]`.

`DESIGN.md` 15 queda al día: 15.4 (la regla, con `T100_LLEGADA` y el 977), 15.6 (la tabla), 15.11
(la desviación 14) y 15.12 (las pruebas).

## 3. P3 · «1 contenedor a bordo en la salida»

`departure_baplie_page.dart` escribía `'${output.containers} contenedores a bordo…'`. Ahora usa
`operationCount`, como el resto de la página. Prueba: `t124_par_test.dart`, caso 3, con el fixture de
T-82 tras bajar el TSTU0000110 (solo sigue a bordo el de paso): antes no había «1 contenedor a bordo
en la salida.», ahora sí, y ningún «1 contenedores».

## 4. O1 · El conductor del arrastre en el emulador

**El defecto (Codex, O1).** `h7` de `tool/t123_capturas_android.py` apoyaba el dedo con el
identificador 1 (`ABS_MT_TRACKING_ID`) y lo levantaba al final, sin `finally`. Si algo fallaba con el
dedo abajo (09c), el contacto quedaba activo; el arrastre siguiente reutilizaba el 1 y la celda ya no
se levantaba (09d y 09e). Es el instrumento, no el producto, como mostró Codex.

**El arreglo.**
- `dedo(x, y)` es un `contextmanager`: apoya el dedo con **un identificador nuevo en cada gesto**
  (un contador que empieza en un valor que depende de la hora, así que tampoco se repite entre
  corridas) y **lo levanta en `finally`**, también si el bloque falla.
- Antes de llevar el dedo al borde, **comprueba que la celda se levantó:** compara la pantalla de antes
  de apoyar el dedo con la de después de la pulsación larga, sobre el rectángulo del origen; la celda
  que se levanta queda a opacidad 0.35 y la copia flota encima, y la diferencia media en gris pasa de
  8. Si no, se detiene con «La celda … no se levantó: no se evalúa el borde», y el `finally` suelta el
  contacto.

**Prueba (roja antes).** `tool/t124_conductor_prueba.py`, sin emulador: un `adb` simulado que anota
las órdenes y da pantallas sintéticas. Antes (`build/t124/05-conductor-rojo.log`), 3 de 3 rojos:
el contacto quedaba apoyado tras un error; dos arrastres usaban el identificador 1; y sin levantarse,
seguía hacia el borde. Ahora (`06-conductor-verde.log`), los 3 pasan.

## 4bis. Las pruebas que cambiaron de expectativa

Las de T-121 esperaban la regla vieja (cada número de bahía, una columna). Pasan a la nueva sin
aflojarse; lo que medían sigue medido:

| Prueba | Antes | Ahora | Por qué |
|---|---|---|---|
| `t121_estadisticas_test`, el 977 | 72 bahías, `t121Bahias72()`, 72 con carga | 24, de la 02 a la 94, 24 con carga | La regla de la par |
| `t121_estadisticas_test`, T-117 | contiene las vecinas 01, 03, 05 y 07 | las bahías son exactamente 02 y 06 | Las vecinas se cuentan con su par; las cifras de la 02 no cambian |
| `t121_estadisticas_test`, la página a 1920 | la silueta mide 72 y se desplaza | mide 24 y, a 1920 × 1000, todavía se desplaza con su barra | 24 columnas no caben por 9 dp |
| `t121_estadisticas_test`, la última se alcanza | la 95 | la 94 | La 95 va en la 94 |
| `t121_entrega2_c1_test`, «nueve bahías llenan el panel» (5 casos) | `t121Bahias9`, la forma de la llegada | `t121Bahias9Sueltas` (02, 06 … 34), nueve bahías de referencia | La forma de la llegada son tres; lo que se mide (nueve columnas llenan el panel) necesita nueve. Las tres de la llegada, en su tope y centradas, las mide `t124_par_test` |
| `t121_entrega2_c1_test`, 72 bahías a 1920 (2 casos) | el sintético de 977 | `t121Bahias72Sueltas` (72 pares), la popa es la 286 | El 977 son 24 y a 1920 × 1080 caben; para medir el desplazamiento hacen falta 72 columnas |

`test/support/t121_estadisticas_support.dart` gana las dos listas de bahías sueltas.

## 5. Propuesta: los vacíos asignados en las alertas, la comparación y Estadísticas

Desde H6, la Lista y las dos búsquedas cuentan lo que va a bordo con los vacíos asignados a una
reserva (`aboardContainersProvider`: el archivo más `LoadingOperation.assignedEmpties`). Las otras
tres vistas leen el viaje tal como se leyó.

| Vista | Qué lee hoy | Qué cambiaría | Riesgo | Recomendación |
|---|---|---|---|---|
| **Estadísticas** | `voyage.containers`: en un plan de carga, los llenos planificados (cargados o no) y ningún vacío, porque una reserva no es un contenedor | Leer `aboardContainersProvider`, como la Lista: cada vacío asignado suma un contenedor, su tara y su tipo en su bahía, su puerto y su naviera; una ficha diría «incluye n vacíos asignados» | Las cifras se mueven mientras dura la operación, y «a bordo» mezcla lo planificado (los llenos, cargados o no) con lo hecho (los vacíos asignados). Las pruebas de «las cifras cuadran» tendrían que distinguir el archivo de lo asignado | **Sí, en una tarea propia**, con la ficha que lo dice; es lo que el planificador ve en la Lista |
| **Alertas de estiba** | Las reglas (peso por pila, peligrosas, tomas) sobre el viaje leído | Sumar los vacíos asignados al peso de su pila | Sumar solo los vacíos daría un estado híbrido: los llenos del plan cuentan aunque no se hayan cargado y lo descargado sigue contando. Una alerta podría aparecer o irse sin que nada físico cambiara | **No así.** Si se quiere, las alertas deberían evaluar el estado completo de la salida (lo que escribe `DepartureBaplieWriter`), como una vista aparte «como sale», no el viaje con los vacíos añadidos |
| **Comparación de viajes** | Dos BAPLIE leídos, por número de contenedor | Nada | Un vacío asignado no está en ningún archivo; la comparación con la salida ya lo trae, porque el BAPLIE de salida lo escribe. Añadirlo a mano lo contaría dos veces | **No cambiar** |

Decide Carlos. Ninguna de las tres toca `domain/`: `assignedEmpties` ya existe.

## 6. Capturas con datos sintéticos, en los dos temas

**65 PNG** en `build/t124/capturas/`: la Web 24, Windows 17 y el emulador 24.

Banco `tool/t124_main.dart`: copia del de T-122 con dos entradas más, el plano de llegada de T-100 y
el sintético de 977 de T-99, que `tool/t124_entradas.py` escribe en `build/t124/entradas/` desde los
archivos sintéticos de `%TEMP%` (comprueba los prefijos MNLU y SNTU y las cuentas). Almacén
`t124cap`. La pestaña del panel sigue diciendo «Banco T122» para que sirvan los conductores de
T-122 y T-123.

| Cliente | Cómo | Claro | Oscuro |
|---|---|---:|---:|
| Web (`build/t124/web` servida en 127.0.0.1:5904; `tool/t124_capturas_web.py`, Playwright, 1920 × 1080, la oficina; un perfil nuevo por tema) | automático | 12 | 12 |
| Windows (`build/t124/windows`, abierto con `explorer.exe`, padre `explorer.exe`; por UIA con `tool/t117_correccion2_windows.ps1`, clics por el rectángulo del nodo y teclas por `tool/t100_windows.ps1`; PNG por `PrintWindow`, 1920 × 991) | paso a paso | 9 | 8 |
| Emulador (`emulator-5554`, 360 × 640 dp; `tool/t124_capturas_android.py`, adb + uiautomator) | automático | 12 | 12 |

Por punto (`<cliente>_<tema>_<pantalla>.png`):
- **1 · La ficha** `ficha_21_carga` («Bahía 21: 7 contenedores, 1 celda reservada, 57.7 t, tapas sin
  declarar; grupo 22 (21, 22 y 23), por cargar cub. 27, bod. 0»), `ficha_22_carga` («Bahía 22: 11
  contenedores, 5 celdas reservadas, 225.5 t…; grupo 22 (21, 22 y 23), por cargar …»), `ficha_26_carga`
  («Bahía 26: 3 contenedores, 63.3 t…; grupo 26 (25 y 26), por cargar cub. 4, bod. 0»: en este plan la
  25 tiene carga y la 27 no trae nada, así que el grupo nombra solo las dos), `ficha_23_contenido` («Bahía 23: 3 contenedores, 25.8
  t…; carga del grupo 22 (21, 22 y 23): cub. 27 (20 llenos, 7 vacíos), bod. 0 (…)»). En el teléfono,
  `ficha_21_carga` («Bahía 21: grupo 22 (21, 22 y 23), cub. 27, bod…» en la línea del resumen) y
  `ficha_21_contenido`.
- **2 · Estadísticas** `estadisticas_t100` (tres bahías, 02, 06 y 10, cada una en su tope, con el
  casco centrado; «3 bahías con carga»), `estadisticas_t100_tabla` y, en la Web,
  `estadisticas_t100_tabla_bahias` (la tabla por bahía con tres filas); `estadisticas_977` (24 bahías,
  de la 02 a la 94, «24 bahías con carga»; a 1920 se desplazan con su barra) y sus tablas. En el
  teléfono, además, `estadisticas_<archivo>_silueta`.
- **3 · La salida** `salida_carga_sin_or` (el lleno TSTU0220071 cargado por sus últimos dígitos, sin
  listado) y `salida_1_contenedor` («1 contenedor a bordo en la salida.»).

### 6.1 Lo que hay que saber del instrumento

- **Un buque nuevo pide «Perfil del buque nuevo»** antes de los parámetros («Proponer desde el
  archivo» o una plantilla). El previo de T-122 no lo contemplaba porque su banco solo abría el buque
  de T-122; los conductores de T-124 lo eligen («Proponer desde el archivo»). Como el almacén es nuevo,
  el plano de llegada de T-100 se confirmó en la Web con la escala que el archivo propuso para ese
  equipo (PAMIT en una corrida, GTSTC en otra); Estadísticas no depende de la escala.
- **Web:** la primera corrida se detuvo en ese diálogo y la segunda al buscar «Por bahía» en la tabla
  (la semántica no lo traía al desplazar): se cambió por dos tomas fijas. El tema claro de Estadísticas
  se repitió en un perfil nuevo (`--solo-estadisticas`) y el oscuro completo; las fichas y la salida del
  claro son de la segunda corrida. El puntero se aparta antes de cada toma (la descripción emergente de
  una bahía salía en la primera).
- **Windows:** el almacén `t124cap` es nuevo. Mientras la ventana de Chrome de Playwright estaba
  encima, el foco no era del banco: los clics por coordenadas quedaron en pausa hasta que terminó la
  Web. Para escribir en «OR / últimos dígitos» hubo que tocar antes el campo. La BayStream instalada
  (MSIX 3.1.1.0) estaba abierta y no se tocó; el banco se cerró por su PID.
- **Emulador:** en el teléfono la segunda toma de la tabla (`…_tabla_bahias`) muestra el resumen,
  con «Bahías con carga» (3 y 24); las filas por bahía se ven en la Web y en Windows. En el teléfono, «Más» lleva delante la cuenta de alertas («2\nMás\nPestaña 5 de 5») y
  el patrón heredado no lo encontraba; el campo de la búsqueda necesita un toque antes de `input text`;
  y «Por bahía» va justo debajo del resumen. Una corrida se detuvo a mano; la que cuenta es
  `13j-android-completo.log`, desde un almacén limpio, en los dos temas.

Los registros de cada corrida, también las que se detuvieron, quedan en `build/t124/`.

## 7. Archivos tocados

**Presentación:**
- `lib/features/vessel/presentation/widgets/resumen_del_modo.dart` — la ficha y `grupoDeLaPar` (punto 1).
- `lib/features/vessel/presentation/formatters/estadisticas_del_viaje.dart` — la regla de la par (punto 2).
- `lib/features/vessel/presentation/pages/departure_baplie_page.dart` — el singular (punto 3).

**Diseño:** `DESIGN.md` 14.7 y 15.4, 15.6, 15.11 y 15.12.

**Pruebas:** `test/t124_par_test.dart` (nueva, 11 casos); `test/t121_estadisticas_test.dart`,
`test/t121_entrega2_c1_test.dart` y `test/support/t121_estadisticas_support.dart` (sección 4bis).

**Herramientas:** `tool/t123_capturas_android.py` (O1); `tool/t124_conductor_prueba.py`,
`tool/t124_main.dart`, `tool/t124_entradas.py`, `tool/t124_capturas_web.py` y
`tool/t124_capturas_android.py` (nuevos).

**No se tocó:** `domain/`, `data/`, `lib/main.dart`, los congelados, la lista del piloto, las
dependencias, `pubspec.yaml` ni `pubspec.lock`. Ningún `// ignore:`.

## 8. Bloque de Git para Carlos

Desde `C:\Proyectos\baystream-rediseno`, en `sprint-4`. Un `git add` por ruta. `pubspec.yaml` y
`pubspec.lock` no cambian. Nada de `build/` entra: `build/t124/entradas/t124_entradas.dart`, que el
banco importa, se genera con `tool/t124_entradas.py`. `test/t114_fase3_correccion_test.dart` y
`windows/flutter/*` ya estaban modificados antes de esta tarea y no son míos: no van.

```powershell
Set-Location -LiteralPath C:\Proyectos\baystream-rediseno
git add -- lib/features/vessel/presentation/widgets/resumen_del_modo.dart
git add -- lib/features/vessel/presentation/formatters/estadisticas_del_viaje.dart
git add -- lib/features/vessel/presentation/pages/departure_baplie_page.dart
git add -- DESIGN.md
git add -- test/t124_par_test.dart
git add -- test/t121_estadisticas_test.dart
git add -- test/t121_entrega2_c1_test.dart
git add -- test/support/t121_estadisticas_support.dart
git add -- tool/t123_capturas_android.py
git add -- tool/t124_conductor_prueba.py
git add -- tool/t124_main.dart
git add -- tool/t124_entradas.py
git add -- tool/t124_capturas_web.py
git add -- tool/t124_capturas_android.py
git add -- docs/T124-RESULTADOS.md
git commit -m "Sprint 4: T-124, la regla de la par en la presentacion (10.65): la ficha de la bahia nombra el grupo de su par, Estadisticas cuenta cada impar con su par, 1 contenedor a bordo en la salida y el conductor del arrastre suelta siempre el contacto" --trailer "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
git push origin sprint-4
git log --oneline -1
```
