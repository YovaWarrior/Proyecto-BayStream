# T-120 · Aceptación de la corrección 1 de la entrega 2 (GLM, 22-nov)

**Dictamen: PASA.** Dos hallazgos nuevos, ambos **P3** y ninguno detiene:
T120-E2-02 y T120-E2-03, los dos preexistentes (también están en el código de
antes) y ninguno de la corrección. **O-120-7 queda confirmada.**

La punta que acepto: `ed1255e` (la decisión 10.171), con la corrección 1 en
`07d8236`, sobre `1a7b03b`. Todo lo que cité está en `build/t120/glm-e2c1/` de
esta carpeta; las corridas del banco se corrieron en `%TEMP%\t120-glm2\banco\`
y se copiaron aquí. Cada cifra sale de un archivo; de cada sonda cito la
última corrida, que es la que tiene todo en su estado final.

## O-120-7 · Un arrastre de celda cancelado puede tomarse como soltado — **CONFIRMADA**

Lo que leyó Yov en el código, sin correrlo, es lo que hace el producto: al
cancelar el contacto, Flutter avisa el final del arrastre por el mismo camino
que un soltado (`onDragEnd` → `_PlanDragSource._soltar`, que no mira
`wasAccepted`), y `onDrop` busca la celda que quedó bajo el puntero. La hoja
de confirmación sale **en el momento de perder el foco**, sin que nadie haya
soltado. Sin pulsar «Confirmar», nada se registra (0 registros en los 32
escenarios). P3, como la clasificó la 10.171.

Última salida de la sonda: `sondas/o1207-despues.txt` (16 de 16) y
`sondas/o1207-antes.txt` (16 de 16). Sonda: `sondas/fuentes/t120glm_c1_o1207_sonda_test.dart`,
sobre el arnés de T-105 (operación publicada y abierta, operador autorizado,
la celda pendiente 0030282), con dedo y con mouse, y con la pérdida de foco
(`AppLifecycleState.inactive`) y con la cancelación del sistema
(`PointerCancelEvent` directo).

**En despues** (con la corrección), al perder el foco, antes de soltar:

| Caso | Lo que hay en pantalla justo al perder el foco | Al soltar después | Registrado |
|---|---|---|---|
| (a) sobre 0030382, reserva (intercambio válido) | **la hoja PlanDragConfirmation**, ya abierta | la hoja sigue; soltar no hace nada más | 0 |
| (b) sobre 0030182, rojo («no cabe») | **el aviso** (SnackBar), ya mostrado | el aviso sigue | 0 |
| (c) sobre la celda de origen 0030282 | **el aviso** (la propia celda es un destino rojo) | el aviso sigue | 0 |
| (d) fuera de las celdas | nada | nada | 0 |

Con la cancelación del sistema (`gesto`) pasa lo mismo que con el ciclo de
vida: en despues los dos caminos terminan en la hoja o el aviso al momento.

**En antes** (contra `1a7b03b`):

| Caso | Al perder el foco | Al soltar después | Registrado |
|---|---|---|---|
| (a) válido | nada — **la copia del arrastre sigue viva** | **la hoja aparece al soltar** | 0 |
| (b) rojo | nada — la copia sigue | **el aviso aparece al soltar** | 0 |
| (c) origen | nada — la copia sigue | **el aviso aparece al soltar** | 0 |
| (d) fuera | nada | nada | 0 |

Y el dato que cierra el origen de la observación: en **antes**, con la
**cancelación del sistema** (sin la corrección), la hoja o el aviso **ya
salían al momento de la cancelación** — «no sería nuevo del todo», decía la
10.171. La corrección extendió ese comportamiento a perder el foco. En las dos
versiones, un arrastre nuevo de la misma celda funciona y termina en su hoja
(la sonda lo comprueba al final de cada escenario), y sin pulsar «Confirmar»
nunca se registró nada.

## La tabla de la sección 3

| # | Punto | Resultado | Evidencia |
|---|---|---|---|
| 1 | Dos copias limpias (`despues` = HEAD, `antes` = `1a7b03b`) con la entrada de T-124 y su `pub get` | ✓ misma huella `d4384834…d1162` en las tres | `paso0/cifras.txt`, `paso0/pubget-despues.txt` |
| 2 | `flutter analyze --no-pub` en despues | ✓ **«No issues found!»** | `a/analyze-despues.txt` |
| 3 | La suite en despues, en una sola corrida | ✓ **`+2563: All tests passed!`** (2558 + 5), sin `~` ni `-` | `a/suite-despues.txt` |
| 4 | `pubspec.yaml` y `pubspec.lock` contra `1a7b03b` | ✓ iguales byte a byte | `paso0/cifras.txt` |
| 5 | Las rojas contra `1a7b03b`, una por una | ✓ **8 de 32**, cada una con su motivo, ninguna de compilación | `rojas/roja-{claves,selector,lista,pellizco}.txt` |
| 6 | O-120-7 | ✓ **confirmada** (arriba) | `sondas/o1207-despues.txt`, `sondas/o1207-antes.txt` |
| 7 | D1, tratar de romperlo | ✓ desplazamientos 60/60 dp con dos y un contacto; ups viejos sin excepción; rueda 100 dp; clic del mouse abre el detalle; sin contactos no pasa nada. **Una esquina queda: T120-E2-02** | `sondas/d1-despues.txt`, `sondas/d1-antes.txt` |
| 8 | La clave de la tarjeta | ✓ misma matrícula en la misma celda: el lector guarda los dos, la Lista enseña **una** tarjeta (la clave repetida no llega a existir), rearme sin errores; en 2 y 4 celdas, una clave por tarjeta con su celda y rearme limpio. **El buscador destapa T120-E2-03** | `sondas/claves-despues.txt`, `sondas/claves-antes.txt` |
| 9 | B en iOS, macOS y Linux | ✓ la ayuda va como **pista** (no en el nombre), igual que Android; solo en Windows va en el nombre | `sondas/selector-plataformas.txt` |
| 10 | El banco puesto al día (3 `lib/` + 5 `tool/`) y su build release | ✓ `lib/` IGUAL y `tool/` IGUAL (sin `__pycache__`) por `diff`; build ✓ en 37.2 s | `cotejo/cotejo-banco-{lib,tool}.txt`, `cotejo/build-windows-banco.txt` |
| 11 | Las entradas (`dart tool/t120e2_buques.dart`) | ✓ `T120_REPETIDA_TRES.edi`: **13 contenedores, 11 matrículas**; los cuatro archivos verificados por el lector | `cotejo/buques.txt` |
| 12 | Tres corridas en Windows | ✓ `capturas`: «fin», **20 capturas**, sin errores de Flutter, claves con su celda en `repetida_4_filtro_LNB` y `repetida_5_filtro_soltado`; `foco`: `pellizco_abierto_antes=true`, `pellizco_abierto_despues=false`, `la_rueda_movio_la_columna=true` (columna 37.2→137.2, zoom 1.2); `pellizco`: «fin», **8 capturas**, sin errores | `windows/capturas-c1/`, `windows/foco-c1/`, `windows/pellizco-c1/` |
| 13 | El árbol accesible de Windows (t117, `ancho` y `arbol`, por el PID 9180, ventana pedida a 1920 × 1000, el monitor la acota a 1539.2 × 844 dp a 120 dpi, como la mañana) | ✓ **UIA 224 y MSAA 240 nodos, como la mañana; cambian exactamente 10 líneas: los cinco segmentos, en UIA y en MSAA, cada uno con su nombre y su ayuda una vez — y nada más** | `windows/monitores-c1/o2glm-c1.{json,txt}`, `windows/diferencia-arbol-con-la-manana.txt`, `windows/ancho-c1.json` |
| 14 | La Web: build + tres corridas | ✓ `programa.es_el_que_se_sirve=true` en las tres (`1dd1344c…`, el de la carpeta que se sirve); `red.json` sin nada cortado fuera de 127.0.0.1; consola sin errores de Flutter; perfiles nuevos `glm-c1-*`, ya borrados | `web/capturas-c1/`, `web/foco-c1/`, `web/selector-c1/` |
| 15 | Los dos monitores y el pellizco de verdad | — **no los hice ni los doy por vistos**: piden la mano de Carlos, siguen pendientes con Timonel. Android tampoco entra | — |

Las rojas, una por una (contra `1a7b03b`):

- `t120_e2c1_claves_test.dart`: **2 de 2** — la aserción esperada
  `'child == null || indexOf(child) > index'` (sliver_multi_box_adaptor.dart
  277), con la matrícula en dos celdas y en tres; detrás, «RenderSliverPadding
  expected… RenderErrorBox». Es la de T120-E2-01.
- `t120_selector_nombre_test.dart`: **3 de 7** — las tres variantes de Windows
  (de día, de noche y la cabecera a 1920).
- `t120_e2_lista_test.dart`: **2 de 15** — las dos de la matrícula repetida
  (1366 y 360): 11 claves para 12 tarjetas (el `Set` con las claves viejas,
  `tarjeta-TSTU0000003` sin celda).
- `t120_pellizco_test.dart`: **1 de 8** — «dos contactos sin levantar…»: un
  dedo, 90 dp a la izquierda, la rejilla se movió **0.0 dp**.

## Lo que vi en pantalla

**Windows** (`windows/capturas-c1/capturas/`, corrida con
`T120_REPETIDA_TRES.edi`; abrí cuatro):

- `1366x690_claro_letra1.0_repetida_4_filtro_LNB.png` — título «Contenedores
  (4), naviera LNB», con «4 llenos / 0 vacíos» y «Quitar filtros»; las **dos
  tarjetas de TSTU0000003 seguidas**, la de 22G1 en Bahía 002, **Fila 03**
  (21 000 kg, GTSTC) y la de 42G1 en **Fila 04** (22 000 kg, GTSTC), las dos
  LNB; después TSTU0000010 (refrigerado) y TSTU0000011.
- `1366x690_claro_letra1.0_repetida_5_filtro_soltado.png` — «Contenedores
  (13)», las tarjetas en su orden: TSTU0000001 (Fila 01), 0000002 (Fila 02),
  **0000003 en Fila 03 y otra vez en Fila 04**, y después 0000005.
- `1366x690_oscuro_letra1.0_repetida_4_filtro_LNB.png` — lo mismo de noche:
  «Contenedores (4), naviera LNB», las dos de 0000003 en Fila 03 y Fila 04.
- `360x800_claro_letra1.0_repetida_4_filtro_LNB.png` — teléfono: «Contenedores
  (4), naviera LNB», las dos tarjetas seguidas, nada cortado.

Las claves del conductor, en el orden en que se ven y cada una con su celda:
con el filtro, `tarjeta-TSTU0000003-0020382` y `-0020482` primeras (y
0000010-0020284 y 0000011-0020384); soltado, las 13 en su orden, con la
tercera celda de la matrícula, `-0020782`, más abajo (pasos.jsonl de la
corrida `capturas-c1`).

**La Web** (`web/capturas-c1/capturas/`; abrí dos):

- `1366x690_claro_letra1_repetida_4_filtro_LNB.png` — lo mismo que en Windows:
  «Contenedores (4), naviera LNB», las dos de TSTU0000003 en Fila 03 y Fila 04.
- `360x800_oscuro_letra1_repetida_5_filtro_soltado.png` — «Contenedores (13)»
  de noche, en su orden, con las dos de TSTU0000003 seguidas.

**D2, el árbol de Chrome** (`web/selector-c1/arbol-chrome.json`, 1920 × 1000):
los cinco segmentos son **`radio`**, con el nombre una vez y la ayuda como
descripción — Contenido/«El destino de cada contenedor»; «Número de orden,
Sin listado de la agencia»/«Los OR del listado de la agencia»; «Carga, 977
pendientes: 977 llenos, 0 vacíos»/«Toca un contenedor o busca su OR para
cargarlo»; Destino/«El puerto de descarga de cada contenedor»; «Tipo de
vacío»/«El tipo ISO de los vacíos; los llenos en papel». Es el árbol, no un
lector de pantalla hablando: no medí a uno hablando.

**D3, la descripción emergente con el mouse** (`web/selector-c1/raton/`,
`raton.json`): sale sobre el **icono** y sobre el **rótulo** («Contenido. El
destino de cada contenedor»; «Carga. 977 pendientes: …»; «Destino. El puerto
de descarga de cada contenedor») y **no sale sobre el borde** (los cinco
puntos de borde, a 4 dp del borde izquierdo, sin globo; el segmento se
resalta). Lo vi: `01-icono.png` y `02-rotulo.png` con el globo visible sobre
el segmento Contenido; `09-borde.png` sin globo.

## Hallazgos

### T120-E2-02 (P3, preexistente) · Tras dos contactos cancelados al perder el foco, un pellizco del touchpad no registra

- **Qué medí:** con dos contactos sin levantar y el ciclo de vida completo
  (inactive, hidden, paused y de vuelta), un `PointerPanZoomStart` con
  `panZoomUpdate(scale: 1.2)` **no cambia la escala** (queda 1.000,
  `pellizcando=false`). Lo mismo con el ciclo corto de la suite
  (inactive→resumed). En cambio, con los mismos dos contactos cancelados
  **directo** por `GestureBinding.cancelPointer` (sin ciclo de vida) el
  pellizco sí va (1.200); con **un** contacto y ciclo completo también
  (1.200 — este caso lo arregla la corrección: en antes era 1.000); sin
  contactos, también. La **rueda** movió la columna en las seis variantes
  (100 dp), en despues y en antes. En **antes**, el pellizco con dos contactos
  y ciclo también está muerto (1.000): **no es una regresión de la
  corrección** — es la esquina que queda.
- **Cómo reproducirlo:** prueba de widgets con el arnés de T-117: dos
  contactos (TestPointer 11 y 12) sobre la celda, la secuencia del ciclo de
  vida, y después `TestPointer(2, trackpad).panZoomStart` +
  `panZoomUpdate(scale: 1.2)`; `planZoomProvider` sigue en 1.0.
- **Evidencia:** `sondas/d1-despues.txt` («pellizco (dos contactos y ciclo
  completo): escala 1.000, pellizcando=false»; «(dos contactos y
  cancelPointer): escala 1.200») y `sondas/d1-antes.txt`. Sonda:
  `sondas/fuentes/t120glm_c1_d1_sonda_test.dart`.

### T120-E2-03 (P3, preexistente) · Elegir un resultado del buscador de una matrícula repetida rompe el Plano

- **Qué medí:** con TSTU0000003 en dos celdas de navieras distintas
  (`T120_BUQUE_LISTA_977.edi` no la trae; el buque sintético de la sonda,
  sí), el buscador da **2 resultados** (Fila 03 y Fila 07). Al elegir
  **cualquiera de los dos**, la app va al Plano y el armado lanza
  **«Duplicate keys found.»**: un `Row` con varios hijos con la clave
  `<'TSTU0000003'>`, y detrás las aserciones del framework (línea 6420 y
  `_dependents.isEmpty`). Los dos resultados llevan **a lo mismo**: bahía 2,
  matrícula resaltada, sin distinguir la celda. En **antes** pasa igual
  (preexistente; la corrección no tocó el plano ni el buscador). Es la misma
  familia de T120-E2-01 — claves duplicadas por matrícula repetida — pero en
  otro sitio: el plano, no la Lista.
- **Cómo reproducirlo:** en la Lista, botón «buscar-contenedor», escribir la
  matrícula repetida, elegir un resultado.
- **Evidencia:** `sondas/claves-despues.txt` y `sondas/claves-antes.txt`
  (bloque CLAVES4 de la sonda `t120glm_c1_claves_sonda_test.dart`).

### Conocidas, con datos que sumo (no son hallazgo)

- La descripción emergente no sale sobre el borde del segmento (D3): medido
  hoy en `raton.json` — cinco puntos de borde, ninguno con globo.
- El pellizco de verdad, los dos monitores y Android: sin medir, pendientes.

## Lo que no se pudo

- **Los dos monitores y el pellizco de verdad** (el escenario `mano`):
  piden la mano de Carlos; siguen pendientes, con Timonel. No los hice ni los
  doy por vistos. Android tampoco entra.
- **Un lector de pantalla hablando**: lo medido es el árbol accesible
  (UIA y MSAA en Windows; el árbol de Chrome en la Web), no un lector
  reproduciendo voz.
- En la corrida de claves, tras el error del Plano (T120-E2-03) el árbol
  queda roto y la sonda lo desmonta y remonta para seguir midiendo: los
  renglones «TooltipState … multiple tickers» del segundo resultado son de
  ese remonte mío, no del producto; el error del producto es el trío
  «Duplicate keys found» + las dos aserciones del framework, igual en los
  dos resultados.

## Cómo trabajé

GLM 5.3 Flash, con el esfuerzo en Max. La consola corre desde la aplicación
de escritorio de ZCode en la laptop de Carlos. Un comando de Flutter o de
Dart a la vez, con sus líneas `SEMÁFORO:` al empezar y al terminar cada
ventana; Timonel no corrió nada en la máquina mientras tanto. Nunca ejecuté
`git status`, ni escrituras de Git, ni `firebase deploy`, ni `flutter run`
contra el Honor; no toqué `%LOCALAPPDATA%\BayStream`, la MSIX ni el corpus.

Dos incidencias de mi propio instrumento, para que no confundan:

- Las primeras corridas de las sondas O-120-7 y D1 fallaron por el arnés
  (un `TestGesture.up()` después de una cancelación, un arrastre diagonal
  donde el reconocedor horizontal ganaba la arena y la columna nunca recibía
  el puntero, la secuencia `paused→resumed` que no es una transición válida,
  y el timer de 350 ms de `RevealPosition`). Reescritas; **la última corrida
  de cada sonda es la que vale** y es la que está en la evidencia.
- Un `flutter analyze` intermedio dio «5 issues found»: eran de mis cuatro
  archivos de sonda dentro de `despues/test` (dos imports sin uso, un
  elemento sin uso, dos infos de estilo), no del producto. Saqué las sondas
  de la copia y el `analyze` final del paquete es el limpio de
  `a/analyze-despues.txt`. Las sondas corren fuera del repositorio.

**Cifras de la máquina:** el disco empezó con 43.6 GB libres y terminó con
42.3. El banco (`%TEMP%\t120-glm2\`, **12 GB**) se queda, como pide la
10.171; el SDK de Firebase no se volvió a extraer (el del banco, en
`banco\build\windows\x64\extracted\firebase_cpp_sdk_windows`). Al terminar
detuve el proceso del banco (PID 9180) y no quedó ningún servidor ni proceso
mío; borré mis tres perfiles de Chrome (`glm-c1-capturas`, `glm-c1-foco`,
`glm-c1-selector`) y ningún otro.

**Horas del reloj**, de las fechas de mis archivos (22-nov): de las **15:26**
(primera copia, `despues.tar`) a las **16:22** (último `analyze`). La suite
terminó a las 15:32; las rojas, 15:33–15:37; las sondas, 15:38–16:06; el
build de Windows del banco, 16:08; las entradas, 16:09; las corridas de
Windows, 16:10–16:13; el árbol accesible, 16:14; el build Web, 16:16; las
corridas Web, 16:17–16:20.

## Git, para que lo ejecute Carlos

Desde esta carpeta (`baystream-qa-r4`, en la punta de `sprint-4`):

```powershell
git add -- docs/t120/entrega2/aceptacion-glm-c1.md
git commit -m "Sprint 4: aceptacion de la correccion 1 de la entrega 2 de T-120"
git push origin HEAD:sprint-4
```

Solo ese archivo: mi informe. La evidencia queda sin seguimiento en
`build/t120/glm-e2c1/`.

## En tres líneas

- **O-120-7 confirmada** en despues y en antes: al perder el foco a medio
  arrastre, la hoja o el aviso salen en ese momento, sin que nadie suelte;
  sin «Confirmar», nada se registra; con la cancelación del sistema ya pasaba
  en antes.
- La corrección pasa sus cuatro pruebas: la suite sube a **2563 de 2563** y
  `analyze` en cero; las rojas son **8 de 32** con su motivo; el árbol de
  Windows cambia **solo los 10 renglones de los cinco segmentos**; Windows y
  la Web dicen lo mismo en pantalla, con el programa que se sirve.
- Dos hallazgos P3 nuevos, los dos preexistentes: el pellizco del touchpad
  tras dos contactos cancelados por el ciclo de vida (T120-E2-02) y el Plano
  que se rompe al elegir un resultado del buscador de una matrícula repetida
  (T120-E2-03). Monitores y pellizco de verdad, pendientes de Carlos.

## Mensaje para Yov

> Yov, acepté la corrección 1 de la entrega 2 de T-120: **PASA**. Tu lectura
> de O-120-7 era exacta: la sonda la confirma caso por caso en despues (hoja o
> aviso al perder el foco, sin soltar; 0 registros), y en antes la hoja salía
> al soltar — con cancelación del sistema, en antes ya salía al momento. La
> clave nueva de la tarjeta se comporta: en pantalla y en las claves del
> conductor, cada tarjeta lleva su celda; la matrícula dos veces en la misma
> celda la lista la deduplica (una tarjeta) y no lanza nada; con dos y cuatro
> celdas, una clave por tarjeta y rearme limpio. El árbol de Windows cambió
> solo los 10 renglones de los cinco segmentos; en Chrome los cinco son
> `radio` con la ayuda como descripción; en iOS/macOS/Linux la ayuda sigue
> como pista, igual que Android. Suite 2563/2563, `analyze` cero, rojas 8 de
> 32. Dos hallazgos P3 nuevos, los dos preexistentes: (E2-02) tras dos
> contactos cancelados por el ciclo de vida, un pellizco del touchpad no
> registra — con `cancelPointer` directo sí, y con un contacto la corrección
> lo arregló; (E2-03) elegir un resultado del buscador de una matrícula
> repetida lanza «Duplicate keys found» en el Plano, un `Row` con la clave de
> la matrícula, y los dos resultados llevan al mismo lugar. La salida natural
> de la E2-02 es la que ya decías para la O-120-7 (que un arrastre cancelado
> no proponga nada); para la E2-03, la clave del identificador del
> contenedor. Informe y evidencia en `docs/t120/entrega2/aceptacion-glm-c1.md`
> y `build/t120/glm-e2c1/`.
