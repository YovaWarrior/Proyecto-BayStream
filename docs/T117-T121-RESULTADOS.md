# T-117 a T-121 · Resultados

Timonel (Claude Code, Claude Opus 5.5). Rama `sprint-4`, carpeta del rediseño
(`C:\Proyectos\baystream-rediseno`), HEAD `6edc21f` («Sprint 4: decision 10.36…»). Las
cinco tareas nacen en la decisión 10.36 de `SPRINT-4.md`: más plano en la oficina
(T-117), el selector de modo y su resumen (T-118), el mouse y el touchpad (T-119), el
filtro por destino en la Lista (T-120) y las estadísticas nuevas (T-121). Una sección por
fase; esta es la primera.

## Fase 0 · Diagnóstico y propuesta (24-oct-2026)

### 0.1 Resultado en tres líneas

- **Lo de arriba se come el plano porque nada lo limita.** La columna central es una
  `Column` con la rejilla como único `Expanded`: la cabecera, los controles con tres o
  cuatro frases de resumen, la silueta y las tarjetas suman de 397 a 499 dp, y donde las
  tarjetas pasan a dos filas (con 1 040 a 1 399 dp de ancho útil, el caso de la laptop
  de Carlos) la franja de arriba mide 102 dp más que la silueta. A 1366 × 768, en Carga,
  a la rejilla le queda alto para fila y media de celdas.
- **Lo demás tiene una causa por síntoma**, con archivo y línea (0.4 a 0.9): la leyenda
  vive en un desplazamiento horizontal que en escritorio no muestra barra y no responde
  a la rueda; «En vivo» no se desplaza y se corta bajo 600 dp de alto; la silueta y la
  rejilla son desplazables horizontales, que Flutter no mueve con la rueda; el pellizco
  solo escucha dos dedos sobre la pantalla; el selector de modo es un `DropdownButton`
  de Material 2 y está duplicado; las estadísticas nunca se rediseñaron: 27 `Colors.*`,
  texto a 9 dp y girado, y el naranja de la grúa como color del peso.
- **Propongo** una columna que se desplaza entera, con el puente (silueta y cifras) en
  tres alturas que se eligen arrastrando su borde o con un botón, la franja de la bahía
  fijada arriba y una franja de cifras fija abajo, donde viven los avisos como en el
  muelle. El panel lateral se fija o flota. Dos estadísticas distintas para elegir: «El
  buque en corte» y «Tablero de destinos». Son 47 a 57 horas en tres entregas, y Carlos
  decide once preguntas (0.12).

### 0.2 Base, lo que leí y lo que no se corrió

- **Leí** `AGENTS.md`, `CLAUDE.md`, la sección 2 de `SPRINT-3.md` y de `SPRINT-4.md`, las
  decisiones 10.14 y 10.29 a 10.36, `DESIGN.md` entero (1 404 líneas) y
  `docs/rediseno/concepto/LEEME.md`. Del código: `vessel_overview_page.dart`;
  `bay_plan_view.dart`, `loading_plan_controls.dart`, `loading_controls.dart`,
  `discharge_controls.dart`, `voyage_stats_view.dart`, `vessel_profile_view.dart`,
  `avisos_del_viaje.dart`, `silueta_del_viaje.dart`, `cifras_del_viaje.dart`,
  `en_vivo_del_viaje.dart`, `plan_drag_confirmation.dart`, `zoom_del_plano.dart` y
  `navegacion_del_viaje.dart`; `plano_providers.dart` y los providers de la Lista y de las
  estadísticas en `vessel_providers.dart`; y en `lib/core/design/`, `bs_medidas.dart`,
  `bs_tipografia.dart`, `bs_silueta_buque`, `bs_panel_en_vivo`, `bs_tarjeta_cifra`,
  `bs_anillo_avance`, `bs_barra_de_operacion`, `bs_cartela` y `bs_hoja_de_detalle`.
- **Evidencia de pantalla:** las capturas de Windows a 1920 × 1080 de la candidata
  (`docs/rediseno/fase3/candidata/recorrido/windows/p15_carga.png` y
  `p22_plano-con-en-vivo.png`). Con ellas contrasté los altos que calculo desde el código.
  Carlos no pegó capturas de la 3.1.0 ni las imágenes de referencia en este chat; si las
  trae, se cotejan en la implementación.
- **No corrí ningún comando de Flutter** (ni `test`, ni `analyze`, ni `build`, ni `run`):
  hoy es la exposición y el ensayo, y el 25 y el 26 el piloto con la 3.1.0. El piso
  vigente es el documentado: **1371** y `analyze` en cero (10.34).
- **Sí corrí:** lecturas con `grep` y `git log` / `git show --stat` / `git diff --stat`,
  y el validador de paletas de la skill de dataviz (`validate_palette.js`, con Node) para
  las rampas de T-121 (0.9.4). Usé las skills `dataviz` y `frontend-design`.
- No se tocó `lib/`, `test/`, `pubspec.*`, Firebase, las apps instaladas, el Honor ni el
  corpus. La 3.1.0 publicada no cambia.
- El árbol trae cuatro archivos con cambios que no son míos: `test/t114_fase3_correccion_test.dart`
  y tres de `windows/flutter/`. `git diff --stat` solo avisa del fin de línea (CRLF); no
  los toco y no van en el bloque de Git.

### 0.3 Cómo se calculan las medidas

- **Dp lógicos.** La ventana maximizada deja menos alto que la pantalla: la barra de tareas
  (48) y el título de la ventana (31) a 100 %. Supongo **1920 × 1000** y **1366 × 690**.
  Sumo dos casos medidos en el Sprint 3: la laptop de Carlos, **1707 × 996** (2560 × 1600
  a 150 %, T-99), y **1536 × 793** (1920 × 1080 a 125 %, T-100). La implementación mide
  el alto real en cada caso.
- **El ancho de la columna central** es la ventana menos el riel, menos el panel lateral
  de 360 desde 1200 dp, y menos dos divisiones de 1 dp. El riel no mide 80: toma el
  rótulo más largo («Estadísticas») con su aire (`navegacion_del_viaje.dart:450-472`), y
  en la captura p15 mide 98.
- **Los altos de letra** salen de `bs_tipografia.dart`: `bodyMedium` 14 × 1.5 = 21,
  `titleSmall` 14 × 1.4 = 19.6, `bodySmall` 12 × 1.4 = 16.8, cifra grande 34 × 1.1 = 37.4.
  Todo con la letra del sistema a 1.0; con 1.45 y 2.0 crece y lo de arriba ocupa más.
- **El corpus real** tiene 6 o más niveles por zona en las bahías llenas, así que la
  silueta pinta el máximo (6 y 6). El buque sintético de las capturas tiene menos niveles
  y su silueta es más baja: por eso la captura da algo menos que el cálculo.

### 0.4 T-117 · Diagnóstico

#### 0.4.1 Qué hay hoy en la columna central de la oficina

La oficina (desde 600 dp, `vessel_overview_page.dart:247-289`) es una fila: riel,
columna central y, desde 1200 dp, el panel lateral de 360. La columna central es una
`Column` con la cabecera y el contenido (`vessel_overview_page.dart:263-278`), y el
plano es otra `Column` (`bay_plan_view.dart:310-316`):

| Pieza | Archivo y línea | Alto | De dónde sale el alto |
|---|---|---:|---|
| Cabecera | `vessel_overview_page.dart:1174-1205` | 64 | Mínimo 56 más 8 + 8 de aire; el botón Buscar mide 48 (p15: 68) |
| Controles del plano | `loading_plan_controls.dart:120-169` | 77 a 180 | 4 + 4 de aire, la fila del selector (48) y el resumen (0.6): Contenido 1 frase (77); Descarga 3 frases (119); Carga 3 frases más «OR / últimos dígitos» y «Asignar vacío» (159; 180 sin listado). p15: 148 |
| Silueta y tarjetas | `bay_plan_view.dart:350-432` | 173 o 275 | 4 + 8 de aire y lo más alto entre la silueta y las tarjetas (abajo) |
| División | `bay_plan_view.dart:313` | 1 | |
| Rejilla | `bay_plan_view.dart:314` (`Expanded`) y `1006-1159` | lo que sobra | Tiene su propio desplazamiento, vertical y horizontal, dentro del zoom |
| Leyenda | `bay_plan_view.dart:275-284`, `454-586` | 82 | 8 + 8 de aire, la cartela (8 + 8, chips de 48 y su borde). p22: 66 de cartela |

**La silueta** mide 6 + 9 × niveles de cubierta + 4 + 9 × niveles de bodega + 10 + el pie
(número, barra y aire: 33.2) (`bs_silueta_buque.dart:143-151`, `355-388`): de 70 dp con un
nivel por zona a **161 dp** con 6 y 6.

**Las tarjetas** (`bs_tarjeta_cifra.dart:64-103`) miden 16 de aire, el rótulo (19.6), 8,
la fila de la cifra y 16 de aire, más el detalle (4 + 16.8). Con el anillo de 52
(`bs_anillo_avance.dart:15`) la fila mide 52 y la tarjeta **132 dp**; sin anillo, 37.4 y
**118 dp**. En la captura p15, Carga mide 133 y Llenos 118. Las reglas de
`bay_plan_view.dart:403-429` son:

- con menos de 1 040 dp útiles **no hay tarjetas**: las cifras quedan en «Avance»;
- desde 1 400, **una fila**: 132 dp, que ya son más que la silueta del buque sintético;
- entre 1 040 y 1 399, **dos tarjetas por fila**. Con cuatro tarjetas (Carga, Llenos,
  Vacíos y Conflictos en Carga, `cifras_del_viaje.dart:60-96`) son dos filas: 132 + 12
  + 118 = **262 dp**, y la franja pasa de 173 a **275 dp**.

El comentario de `bay_plan_view.dart:406-409` dice que «la fila nunca es más alta que la
silueta». Con dos filas no se cumple: 262 contra 161. Esas dos filas son las que Carlos
describe: «hasta las tarjetas de Vacíos y Conflictos».

#### 0.4.2 Cuánto alto ocupa lo de arriba

Lo de arriba es la cabecera, los controles, la silueta y las tarjetas, y la división. El
«alto para la rejilla» es la ventana menos lo de arriba y la leyenda; dentro de la
rejilla todavía van el título de la bahía, su resumen, los pesos por pila y la cabecera
de filas, unos 130 dp, antes de la primera celda. Cada fila de celdas mide 52 dp.

**En Carga** (controles de 159 dp), con el panel lateral abierto:

| Ventana (lógica) | Columna central | Tarjetas | Lo de arriba | Parte de la ventana | Alto para la rejilla | Filas de celdas a la vista |
|---|---:|---|---:|---:|---:|---:|
| **1920 × 1000** | 1 460 | una fila | 64 + 159 + 173 + 1 = **397** | **40 %** | 521 | ≈ 7 |
| 1707 × 996 (la laptop de Carlos) | 1 247 | dos filas | 64 + 159 + 275 + 1 = **499** | **50 %** | 415 | ≈ 5 |
| 1536 × 793 (1920 × 1080 a 125 %) | 1 076 | dos filas | **499** | **63 %** | 212 | ≈ 1.5 |
| **1366 × 690** | 906 | ninguna | 64 + 159 + 173 + 1 = **397** | **58 %** | 211 | ≈ 1.5 |

**En Descarga** (controles de 119 dp; tres tarjetas, que también van en dos filas entre
1 040 y 1 399):

| Ventana | Lo de arriba | Parte de la ventana | Alto para la rejilla |
|---|---:|---:|---:|
| 1920 × 1000 | 64 + 119 + 173 + 1 = **357** | 36 % | 561 |
| 1707 × 996 | 64 + 119 + 275 + 1 = **459** | 46 % | 455 |
| 1366 × 690 | **357** | 52 % | 251 |

Una bahía real tiene unas 16 filas entre cubierta y bodega (unos 850 dp): en ningún
tamaño cabe entera, y a 1366 × 690 desplazar la rejilla es obligatorio para ver
cualquier cosa.

#### 0.4.3 Por qué solo se desplaza la rejilla

- La columna del plano es una `Column` con la rejilla como único `Expanded`
  (`bay_plan_view.dart:310-316`). Los controles, la silueta y la leyenda no están en
  ningún desplazable vertical: la rueda sobre ellos no hace nada.
- La rejilla se desplaza dentro de su propio lienzo: un `SingleChildScrollView` vertical
  (`bay_plan_view.dart:1040`) dentro de `PlanZoomViewport`
  (`plan_drag_confirmation.dart:83-103`), que amplía con un `OverflowBox` y un
  `Transform.scale` y necesita un alto acotado.
- El teléfono bajo sí recoge lo de arriba al desplazar (`NestedScrollView`,
  `bay_plan_view.dart:285-308`), pero solo por debajo de 600 dp de ancho y con menos de
  560 dp de alto útil (`anidar`, `bay_plan_view.dart:172`; `alturaParaAnidar`,
  `bay_plan_view.dart:708`). La oficina nunca entra ahí.

#### 0.4.4 «En vivo»

- El panel lateral (`vessel_overview_page.dart:1262-1302`) es una `Column`: el detalle de
  la celda en un `Expanded` y, debajo, «En vivo» con su aire, **sin desplazamiento**
  (`vessel_overview_page.dart:1294-1298`). Con 8 eventos (`en_vivo_del_viaje.dart:18`)
  «En vivo» mide unos 550 dp: cada fila lleva 12 + 12 de aire, el título y el dato
  (`bs_panel_en_vivo.dart:227-263`). En la captura p22 va de y = 520 a y = 1 068.
- Con una escala en operación (cuando «En vivo» aparece), a 1366 × 690 el detalle de la
  celda se queda con unos 120 dp. **Con menos de unos
  600 dp de alto de ventana, «En vivo» no cabe y se corta** (en depuración, la franja de
  desborde).
- El panel está en todas las pestañas (`vessel_overview_page.dart:279-285`): en
  Estadísticas y en la Lista dice «Toca una celda del plano para ver su detalle aquí» y
  ocupa 361 dp.
- No se puede ocultar: no hay botón ni preferencia.

#### 0.4.5 Lo que se corta o se deforma con el tamaño de la ventana

1. **La leyenda se corta a la derecha** (el caso de Carlos). La cartela es un `Wrap`
   (`bs_cartela.dart:102-110`, y su comentario dice «nunca un scroll horizontal que corte
   “Refrigerado”», `bs_cartela.dart:56-57`), pero la página la mete en un
   `SingleChildScrollView` horizontal (`bay_plan_view.dart:576-584`). Con ancho infinito
   el `Wrap` nunca envuelve: todo va en una línea, que se corta donde termina la columna.
   En escritorio ese desplazamiento no se ve ni se alcanza: Flutter pone barra solo a
   los desplazables verticales (`MaterialScrollBehavior.buildScrollbar`), la rueda mueve
   en vertical, el mouse no arrastra (los `dragDevices` por omisión excluyen el mouse) y
   solo Mayús + rueda o el touchpad lo mueven. La leyenda de la captura p22 (tres tipos
   de vacío) mide 1 278 dp; con el panel abierto quedan 1 436 a 1920, 1 223 en la laptop
   de Carlos y 1 052 a 1536 × 793. A 1920 basta un tipo de vacío más y «Celda reservada»
   (A08 trae 55): cada ficha de tipo suma unos 130 dp y «Celda reservada» unos 145, y la
   línea pasa de 1 436. Es una estimación con el ancho medio de la letra; el ancho real
   con el corpus se mide en la implementación.
2. **«En vivo» se corta** con una ventana baja (0.4.4).
3. **La columna central se desborda** con una ventana de menos de unos 480 dp de alto:
   lo de arriba más la leyenda ya miden 479 y la rejilla es lo único que cede. Con la
   letra a 2.0, antes.
4. **Lo de arriba salta.** Al pasar por 1 040 y 1 400 dp de ancho útil, las tarjetas
   aparecen, desaparecen o pasan de una a dos filas, y la rejilla pierde o gana 100 dp de
   golpe. Al arrastrar la ventana a otro monitor con otra escala (100 ↔ 125 %), Flutter
   recibe el cambio de DPI y el ancho lógico cruza esos umbrales: es el «se deforma» de
   la ventana arrastrada. Pasa lo mismo con el panel lateral en 1200.
5. **La silueta, la rejilla y la leyenda** son desplazables horizontales sin barra en
   escritorio (T-119).

### 0.5 T-117 · Propuesta

#### 0.5.1 La idea

**El plano manda; lo demás cede y nunca se corta.** En la oficina (desde 600 dp, Windows y
la Web) la columna central se arma de arriba abajo con:

1. **La cabecera, fija** (64 dp): el buque y el viaje, el estado, el selector de modo
   (T-118), Buscar, la nube y el botón del panel lateral.
2. **Una columna desplazable** (`CustomScrollView`) con:
   - **el puente:** la silueta y las cifras, en tres alturas (0.5.2), con el borde que se
     arrastra;
   - **la franja de la bahía,** fijada arriba al desplazar (`SliverPersistentHeader`,
     unos 52 dp): ‹ Bahía 10 ›, su total y su peso, «Colorear por», el zoom, «OR /
     últimos dígitos» en Carga, «Acciones» y el botón que pliega o despliega el puente.
     Con el puente fuera de la vista, ‹ › cambian de bahía, y el título abre la lista de
     bahías;
   - **la rejilla a su alto natural por el zoom.** Ya no tiene desplazamiento vertical
     propio: la mueve la columna. Conserva el horizontal, con su barra (T-119);
   - **la leyenda,** al final, en un `Wrap` de varias líneas que nunca se corta, como la
     cartela al pie de la hoja impresa.
3. **La franja de cifras, fija abajo** (56 dp): el resumen del modo en una línea de fichas
   (T-118). Es la «franja» del muelle llevada a la oficina, y **ahí viven los avisos**
   (0.5.6).

El título de la bahía y su resumen salen de dentro de la rejilla
(`bay_plan_view.dart:1064-1085`) y van a la franja de la bahía: la rejilla gana 48 dp más.
El teléfono no cambia: sigue el plano de la candidata, con el `NestedScrollView` del
teléfono bajo y la barra de la operación.

#### 0.5.2 El puente en tres alturas

| Altura | Qué muestra | Alto con la letra a 1.0 |
|---|---|---:|
| **Completo** (por omisión) | La silueta normal (161 con el corpus) y, a su derecha, las tarjetas **cortas**: el anillo de 40, el rótulo y la cifra a 28, unos 76 dp, en una fila o en dos de dos. Nunca más altas que la silueta: 2 × 76 + 12 = 164 | ≈ 176 |
| **Compacto** | La silueta compacta (`compacta: true`, unos 90 dp, 13.6) y las tarjetas cortas en una fila a su derecha | ≈ 102 |
| **Plegado** | Nada: queda la franja de la bahía, y las cifras siguen en la franja de cifras | 0 |

- Con menos de 840 dp de ancho útil (dos tarjetas cortas de 200 y una silueta de al menos
  400), las tarjetas no caben junto a la silueta. No se apilan debajo: sus cifras ya están
  en la franja de cifras. Así la altura no salta por el ancho; cambia solo cuando cambia
  la letra, y entonces se mide, no se fija.
- **El borde que se arrastra:** una zona de 12 dp sobre la línea del borde de abajo del
  puente, con el cursor de redimensionar fila y una agarradera de 32 × 4. Al arrastrar,
  el puente sigue al puntero y su contenido pasa de una altura a otra en los umbrales;
  al soltar, se queda en la más cercana (150 ms, cero si el sistema reduce el
  movimiento). Doble clic en el borde: plegar o desplegar.
- **El botón** de la franja de la bahía (⌃ / ⌄) pliega o devuelve la última altura
  abierta.
- **Con el teclado:** el borde recibe el foco; ↑ y ↓ cambian de altura; Intro pliega o
  despliega. Para el lector de pantalla es un control ajustable: «Alto del panel del
  buque, completo», con subir y bajar.
- **Por qué tres alturas y no un alto libre:** con un alto libre, la silueta y las
  tarjetas tendrían que recortarse o estirarse en los altos intermedios, justo lo que
  T-117.4 prohíbe. Con tres alturas, cada una cabe entera con cualquier letra. Es la
  pregunta P1.

#### 0.5.3 Cómo conviven el plegado, el borde y los dos desplazamientos

| Dónde está el puntero | Rueda | Mayús + rueda | Ctrl + rueda o pellizco | Touchpad, dos dedos |
|---|---|---|---|---|
| Silueta | Avanza o regresa la silueta (T-119); en un extremo pasa a la columna | Igual que la rueda | Nada | Horizontal y vertical: la silueta |
| Tarjetas, franja de la bahía, leyenda | La columna | Nada | Nada | La columna |
| Rejilla | La columna | La rejilla en horizontal | El zoom de la rejilla (T-119) | Vertical: la columna; horizontal: la rejilla; pellizco: el zoom |
| Panel lateral | Su propio desplazamiento | — | — | Su propio desplazamiento |

La barra horizontal de la rejilla (T-119) se arrastra con el mouse, y un clic en su pista
avanza una página.

- **Al bajar con la rueda,** el puente sube y se va, la franja de la bahía se queda
  arriba y la rejilla usa la pantalla; al seguir bajando se llega a la leyenda. Al subir,
  el puente vuelve.
- **Desplazar no cambia la altura elegida:** el puente se va de la vista, pero sigue
  completo. Plegar es otra cosa: el puente desaparece aunque la columna esté arriba.
- **Un pestillo para la rueda:** si la columna se desplazó con la rueda hace menos de
  300 ms, la rueda sigue con la columna aunque la silueta pase bajo el puntero. Sin
  pestillo, al bajar la página la silueta llega bajo el mouse y se roba la rueda.
- **Cambiar de bahía** no mueve la columna: si la nueva bahía es más baja, la columna se
  acomoda a su nuevo largo.

#### 0.5.4 El panel lateral: fijo, flotante o por el borde

- **Fijo** (por omisión): como hoy, 360 dp a la derecha.
- **Oculto:** el botón de la cabecera (◨) lo esconde y la columna central gana 361 dp.
  La app lo recuerda.
- **Con el mouse:** con el panel oculto, una franja de 12 dp en el borde derecho; si el
  mouse se queda 250 ms ahí, el panel sale **flotante**, por encima de la rejilla y sin
  moverla, con el borde y la superficie de panel alto de la noche. Se va 400 ms después
  de que el mouse sale. «Fijar», en su cabecera, lo deja fijo. Sin mouse (pantalla
  táctil), solo el botón. **Se apaga en Parámetros** con «Mostrar el panel lateral al
  pasar el mouse por el borde» (encendido por omisión, P6).
- **El detalle del contenedor con el panel oculto:** al tocar una celda, el panel sale
  flotante con el detalle (el mismo `DetalleContenedor`, una sola hoja de detalle, 3.6).
  «Cerrar», Esc o un clic fuera lo devuelven. No hace falta una segunda forma de ver el
  detalle (P5).
- **«En vivo» no vuelve a cortarse:** el panel reparte su alto. El detalle se queda con lo
  suyo y «En vivo» con hasta la mitad, y su lista se desplaza por dentro.
- **Fuera del Plano** (Lista, Avance, Estadísticas) el panel lleva solo «En vivo», sin la
  frase de la celda.
- Desde 600 y hasta 1199 dp no hay panel fijo: solo flotante (por el botón o por el
  borde).

#### 0.5.5 Con cualquier tamaño de ventana

- La leyenda envuelve (`Wrap` sin desplazamiento horizontal) y crece hacia abajo, dentro
  de la columna que se desplaza.
- El puente no salta por el ancho (0.5.2) y nunca se corta por el alto: si la ventana es
  más baja que lo que se ve a la vez, la columna se desplaza.
- La franja de la bahía y la de cifras son de una línea; con la letra grande o una
  ventana angosta, lo que no cabe pasa a «Acciones» o a una segunda línea, medida (como
  la cabecera de la corrección 10.21).
- **Lo que se prueba en la implementación:**
  - una matriz de pruebas de widget sin desbordes, con la leyenda y las franjas enteras;
  - tamaños: 1920 × 1000, 1707 × 996, 1536 × 793, 1366 × 690, 1280 × 720, media pantalla
    de 1920 (960 × 1000) y 800 × 600;
  - con la letra a 1.0, 1.45 y 2.0; con el panel fijo, flotante y oculto; en Contenido,
    Descarga y Carga;
  - **en la ventana real:** maximizar, ajustar con Win + ← y →, redimensionar con el borde
    y, si Carlos tiene un segundo monitor, arrastrar de uno al otro (P11).

#### 0.5.6 Los avisos (10.30 a 10.33)

Hoy, en la oficina, el pie es la leyenda medida «sin franja»
(`bay_plan_view.dart:278-284`): el aviso no tiene tope arriba y cruza el riel y «En
vivo» (O3, 10.31). La regla del muelle no aplicaba. Con la propuesta:

- La franja de cifras de la oficina se mide como la franja del muelle (`MideLaFranja`):
  el aviso vive en ella, puede tapar sus cifras durante su plazo y no pasa de su borde de
  arriba. La rejilla, la franja de la bahía y la leyenda no se tapan, **por construcción**,
  con `LugarDelAviso` y el texto corto de `avisoDelViaje`.
- La franja de cifras no lleva controles, así que el aviso no tapa nada que se toque. Mide
  56 dp: el aviso compacto pide 48 + 4 + 4.
- El aire del aviso, a izquierda y derecha, lo deja dentro de la columna central. **Cierra
  O3.**
- En el teléfono no cambia nada.

#### 0.5.7 Guardar las preferencias exige tocar `domain/` y `data/`

Las tres preferencias son el alto del puente (completo, compacto o plegado), el panel
(visible u oculto) y «mostrar con el mouse» (sí o no). La presentación no puede guardarlas
sola: el almacén del equipo vive en `data/` (`hive_vessel_data_source.dart`, caja
`_settings`) detrás de `LocalVesselRepository` en `domain/`. La preferencia de T-91
(`getPlanToolbarCollapsed`, sin lector desde la entrega 2) no sirve: es un sí o no y por
omisión dice «plegado».

**Lo mínimo:** un par genérico, en vez de seis métodos.

- `domain/repositories/local_vessel_repository.dart`: un `enum UiPreference
  { bridgeHeight, sidePanel, sidePanelOnHover }` y dos métodos,
  `getUiPreference(UiPreference key)` → `Either<Failure, String?>` y
  `setUiPreference(UiPreference key, String? value)`.
- `data/`: dos métodos en `HiveVesselDataSource` (la clave `ui.<nombre>` en `_settings`,
  por la misma cola `_writeVoyages` que el tema) y dos `_guard` en
  `LocalVesselRepositoryImpl`. Unas 20 líneas en total; sin migración (sin valor, la
  presentación usa el de omisión); la caja ya existe.
- Las seis pruebas que implementan el repositorio usan `noSuchMethod`: compilan igual. La
  presentación trata un fallo de lectura como «sin valor», como hace el tema de T-90.
- **«Cada usuario»** es el usuario del equipo: la cuenta de Windows (el almacén vive en
  su `%LOCALAPPDATA%`) o el perfil del navegador en la Web. Por cuenta de BayStream
  habría que guardar en Firestore, fuera del alcance (P3).
- El mismo par serviría después para lo que `DESIGN.md` 5.4 promete y el código guarda en
  memoria: la última vista de «Colorear por» por modo (`plano_providers.dart:37-39`). No
  entra en esta propuesta.

#### 0.5.8 Lo que gana el plano

Alto para la rejilla en Carga, en dp; la rejilla además ya no lleva dentro el título y el
resumen de la bahía:

| Ventana | Hoy | Puente completo | Compacto | Plegado o desplazado |
|---|---:|---:|---:|---:|
| 1920 × 1000 | 521 | 652 | 726 | 828 |
| 1707 × 996 | 415 | 648 | 722 | 824 |
| 1536 × 793 | 212 | 445 | 519 | 621 |
| 1366 × 690 | 211 | 342 | 416 | 518 |

Lo fijo de la propuesta es la cabecera (64), la franja de la bahía (52) y la franja de
cifras (56): 172 dp. Cuando la bahía no cabe a lo ancho, la barra horizontal resta 14 dp.
Dentro de la rejilla quedan los pesos por pila y la cabecera de filas, unos 73 dp (hoy,
con el título y el resumen, unos 130). Las filas de celdas a la vista a 1366 × 690 pasan
de ≈ 1.5 a ≈ 5 con el puente completo y a ≈ 8.5 plegado; a 1920 × 1000, de ≈ 7 a ≈ 11 y
≈ 14.5.

#### 0.5.9 Wireframes

Lienzos de 1920 y 1366 px (un carácter ≈ 17 px). Buque y números sintéticos (BUQUE MANUAL,
TSTU con dígito de control). En la ventana real la rejilla es más ancha; aquí se dibuja una
bahía de siete filas.

**1920 × 1080 · Carga · puente completo y panel fijo**
```
┌──────┬──────────────────────────────────────────────────────────────────────────────────────┬─────────────────────┐
│ [▣]  │ BUQUE MANUAL      Publicado   [ Contenido | Orden | Descarga 28 | ■ Carga 29 ]  ⌕  ◨ │ Contenedor          │  64 cabecera fija
│      │ Viaje M100, escala GTSTC                                                             │ TSTU 000110 8       │
│ Plano├──────────────────────────────────────────────────────────────────────────────────────┤ 45G1, 40 HC, lleno  │
│      │ ┌ Bahías de proa a popa ───────────────────────────┐ ┌ ◔ Carga ────┐ ┌ Llenos ─────┐ │ Celda 010-02-06     │  176 puente completo
│ Lista│ │  ▪▪  ▪▪▪  ▪▪▪▪  [████]  ▪▪▪▪  ▪▪▪  ▪▪   ▪▪▪      │ │   1 de 30   │ │   0 de 20   │ │ Peso 24.1 t         │
│      │ │  ▪▪  ▪▪▪  ▪▪▪   [████]  ▪▪▪   ▪▪▪  ▪▪   ▪▪▪      │ └─────────────┘ └─────────────┘ │ [Pedir cambio]      │
│Avance│ │ Proa  02   06    10     14    18   22   26   Popa│ ┌ Vacíos ─────┐ ┌ Conflictos ─┐ │                     │
│      │ └──────────────────────────────────────────────────┘ │   1 de 10   │ │   2 Revisar │ │                     │
│Estad.│                                                      └─────────────┘ └─────────────┘ │                     │
│      ╞════════════════════════ borde que se arrastra: tres alturas ═════════════════════════╡ ┌ En vivo ────────┐ │
│  Más │ ‹ Bahía 10 ›  20 contenedores, 231.9 t  Colorear por [Estado|Destino|■Tipo]  100 %  ⌃│ │ ● Solo aquí     │ │  52 franja de la bahía,
│      │                                          OR / últimos dígitos     Acciones ▾         │ │ ▪ Cargado       │ │     fijada arriba
│Alert.├──────────────────────────────────────────────────────────────────────────────────────┤ │   Muelle, ahora │ │
│      │        cub.  0.0   0.0   3.9   0.0   3.9   0.0   0.0                                 │ │ ▪ Bajado        │ │  la rejilla, a su alto
│      │        bod. 45.8  42.5  25.6   0.0  25.2  40.8  44.2                                 │ │   Muelle, 1 min │ │  natural por el zoom;
│      │              06    04    02    00    01    03    05                                  │ │ …               │ │  se desplaza la
│      │        82  [    ][    ][OR22][    ][OR30][    ][    ]                                │ │ (se desplaza    │ │  columna entera
│      │        ═════════════════════════════════════════════                                 │ │  por dentro)    │ │
│      │        06 ╭[OR21][OR19][OR17][    ][OR28][OR29][OR20]╮                               │ └─────────────────┘ │
│      │        04 │[42G1][42G1][OR18][    ][OR16][42G1][42G1]│                               │                     │
│ Nube │        02 ╰[42G1][42G1][42G1][    ][42G1][45R1][42G1]╯   ↓ la leyenda, al final      │                     │
│      │ ━━━━━━━━━━━━━━ barra horizontal, solo si la bahía no cabe a lo ancho ━━━━━━━━━━━━━━━ │                     │  14 la barra (T-119)
│Parám.├──────────────────────────────────────────────────────────────────────────────────────┤                     │
│      │ Bahía 10: cub. 2, bod. 7   Carga: 29 pendientes, 20 llenos, 9 vacíos   Descarga: 28  │                     │  56 franja de cifras:
└──────┴──────────────────────────────────────────────────────────────────────────────────────┴─────────────────────┘    ahí viven los avisos
```

**1920 × 1080 · la columna desplazada y el panel oculto, que sale flotante por el borde**
```
┌──────┬──────────────────────────────────────────────────────────────────────────────────────────────────────────┬─┐
│ [▣]  │ BUQUE MANUAL      Publicado   [ Contenido | Orden | Descarga 28 | ■ Carga 29 ]                    ⌕  ◧   │ │  64 cabecera fija
│      │ Viaje M100, escala GTSTC                                                                                 │ │
│ Plano├──────────────────────────────────────────────────────────────────────────────────────────────────────────┤ │
│      │ ‹ Bahía 10 ›  20 contenedores, 231.9 t   Colorear por [Estado|Destino|■Tipo]  100 %  OR…  Acciones ▾  ⌄  │ │  52 franja, fijada arriba
│      ├──────────────────────────────────────────────────────────────────────────────────────────────────────────┤ │
│ Lista│        82  [    ][    ][OR22][    ][OR30][    ][    ]                ┌ Contenedor ───────────── Fijar ┐  │ │  el borde de 12 dp: con
│      │        ═════════════════════════════════════════════                 │ TSTU 000110 8                  │  │ │  el mouse 250 ms ahí,
│Avance│        06 ╭[OR21][OR19][OR17][    ][OR28][OR29][OR20]╮               │ 45G1, 40 HC, lleno             │  │ │  el panel sale flotante
│      │        04 │[42G1][42G1][OR18][    ][OR16][42G1][42G1]│               │ [Pedir cambio]   [Cerrar]      │  │ │  sobre la rejilla, sin
│Estad.│        02 ╰[42G1][42G1][42G1][    ][42G1][45R1][42G1]╯               ├ En vivo ───────────────────────┤  │ │  moverla; «Fijar» lo
│      │                                                                      │ ▪ Cargado, Muelle, ahora       │  │ │  deja fijo
│  Más │ ┌ Leyenda, tipo de vacío ────────────────────────────────────────┐   │ ▪ Bajado, Muelle, 1 min        │  │ │
│      │ │ [Tipo de vacío] [45G1 vacío 5] [42G1 vacío 4] [45R1 vacío 3]   │   └────────────────────────────────┘  │ │
│Alert.│ │ [Lleno 8] [Vacío 12] [IMO 1] [Refrigerado 3] [OOG 0]           │                                       │ │
│      │ │ [De paso 10] [Ocupado por 40 pies] [Celda reservada]           │                                       │ │
│ Nube │ └────────────────────────────────────────────────────────────────┘                                       │ │
│Parám.├──────────────────────────────────────────────────────────────────────────────────────────────────────────┤ │
│      │ Bahía 10: cub. 2, bod. 7   Carga: 29 pendientes, 20 llenos, 9 vacíos   Descarga: 28, 1 re‑estiba         │ │  56 franja de cifras
└──────┴──────────────────────────────────────────────────────────────────────────────────────────────────────────┴─┘
```

**1366 × 768 · Carga · puente completo y panel fijo**
```
┌──────┬─────────────────────────────────────────────────────┬─────────────────────┐
│ [▣]  │ BUQUE MANUAL     Publicado   [ ↑ Carga ⌄ ]     ⌕  ◨ │ Contenedor          │  64 cabecera
│      │ Viaje M100, escala GTSTC                            │ TSTU 000110 8       │
│ Plano├─────────────────────────────────────────────────────┤ …                   │
│      │ ┌ Bahías ──────────────────┐ ┌ ◔ Carga ┐ ┌ Llenos ─┐│                     │  176 puente completo
│ Lista│ │ ▪▪ ▪▪▪ [███] ▪▪▪ ▪▪ ▪▪▪ ›│ │ 1 de 30 │ │ 0 de 20 ││                     │
│      │ │ ▪▪ ▪▪▪ [███] ▪▪▪ ▪▪ ▪▪▪  │ └─────────┘ └─────────┘│                     │
│Avance│ │ Proa 02 06 10 14 18  Popa│ ┌ Vacíos ─┐ ┌ Confl. ─┐│                     │
│      │ └──────────────────────────┘ │ 1 de 10 │ │ 2       ││                     │
│Estad.│                              └─────────┘ └─────────┘│ ┌ En vivo ────────┐ │
│      ╞═══════════════ borde que se arrastra ═══════════════╡ │ ● Solo aquí     │ │
│  Más │ ‹ Bahía 10 › 20 cont., 231.9 t [■ Tipo ⌄] 100 % ⌃   │ │ ▪ Cargado       │ │  52 franja de la bahía
│Alert.├─────────────────────────────────────────────────────┤ │   Muelle, ahora │ │
│      │   82  [    ][    ][OR22][    ][OR30][    ][    ]    │ │ …               │ │  la rejilla: 342 dp
│      │   ═════════════════════════════════════════════     │ └─────────────────┘ │  (≈ 5 filas de celdas)
│ Nube │   06 ╭[OR21][OR19][OR17][    ][OR28][OR29][OR20]╮   │                     │
│Parám.├─────────────────────────────────────────────────────┤                     │
│      │ Bahía 10: cub. 2, bod. 7   Carga: 29 pend.   ⌄ más  │                     │  56 franja de cifras
└──────┴─────────────────────────────────────────────────────┴─────────────────────┘
```

**1366 × 768 · el puente plegado (se ve igual con el puente desplazado fuera de la vista)**
```
┌──────┬─────────────────────────────────────────────────────┬─────────────────────┐
│ [▣]  │ BUQUE MANUAL     Publicado   [ ↑ Carga ⌄ ]     ⌕  ◨ │ Contenedor          │  64 cabecera
│      │ Viaje M100, escala GTSTC                            │ …                   │
│ Plano├─────────────────────────────────────────────────────┤                     │
│      │ ‹ Bahía 10 › 20 cont., 231.9 t [■ Tipo ⌄] 100 % ⌄   │                     │  52 franja de la bahía
│ Lista├─────────────────────────────────────────────────────┤                     │
│      │   cub.  0.0   0.0   3.9   0.0   3.9   0.0   0.0     │ ┌ En vivo ────────┐ │
│Avance│   bod. 45.8  42.5  25.6   0.0  25.2  40.8  44.2     │ │ ● Solo aquí     │ │  la rejilla: 518 dp
│      │         06    04    02    00    01    03    05      │ │ ▪ Cargado       │ │  (≈ 8.5 filas de celdas)
│Estad.│   82  [    ][    ][OR22][    ][OR30][    ][    ]    │ │   Muelle, ahora │ │
│      │   ═════════════════════════════════════════════     │ │ …               │ │
│  Más │   06 ╭[OR21][OR19][OR17][    ][OR28][OR29][OR20]╮   │ └─────────────────┘ │
│      │   04 │[42G1][42G1][OR18][    ][OR16][42G1][42G1]│   │                     │
│Alert.│   02 ╰[42G1][42G1][42G1][    ][42G1][45R1][42G1]╯   │                     │
│ Nube │   ↓ la leyenda, al final de la columna              │                     │
│Parám.├─────────────────────────────────────────────────────┤                     │
│      │ Bahía 10: cub. 2, bod. 7   Carga: 29 pend.   ⌄ más  │                     │  56 franja de cifras
└──────┴─────────────────────────────────────────────────────┴─────────────────────┘
```

A 1366, los cuatro segmentos con sus nombres no caben junto al buque y los botones de la
cabecera: el selector va en su forma de menú (T-118). «Colorear por» también pasa a menú
en la franja de la bahía. La franja de cifras dice lo esencial; «⌄ más» abre el resto
encima de la franja, sin mover la rejilla.

### 0.6 T-118 · El selector de modo y su resumen

#### 0.6.1 Diagnóstico

- **Es un `DropdownButton` de Material 2** (`loading_plan_controls.dart:172-202`): un
  subrayado, el texto y un triángulo. Abierto, es una lista de cuatro palabras sin icono,
  sin descripción y sin estado, sobre una superficie lisa. No toma el estilo de los
  paneles de la noche (radio 18, borde en línea) ni la selección invertida de 13.1 (tinta
  con texto noche). Por eso «se ve plano, también al abrirlo».
- **El modo se elige en dos sitios.** En la oficina, la cabecera lleva Descarga / Carga
  en un `SegmentedButton` (`vessel_overview_page.dart:1151-1171`), y debajo el desplegable
  repite Descarga y Carga junto a Contenido y Número de orden. En el teléfono operando
  pasa lo mismo con la banda del muelle.
- **El resumen son frases** (T-107):
  - en Carga, tres o cuatro frases más una fila de dos botones: 159 dp
    (`loading_controls.dart:92-131`);
  - en Descarga, tres frases, la última una instrucción fija («Toca un contenedor para
    marcarlo como descargado.», `discharge_controls.dart:35-54`): 119 dp;
  - repite los totales que las tarjetas ya dicen en grande: «Carga: 29 pendientes (20
    llenos / 9 vacíos)» al lado de las tarjetas «Carga 1 de 30», «Llenos 0 de 20» y
    «Vacíos 1 de 10»;
  - en la misma fila de botones va el chip de la nube (`loading_plan_controls.dart:161`),
    que ya está en la cabecera.
- En el teléfono el resumen ya es una línea que se abre (`PlanSummaryLine`,
  `loading_controls.dart:143-223`), pero repite lo que dice la barra de la operación (por
  bajar, hechas y re‑estibas).

#### 0.6.2 Propuesta

**Un solo selector, `BsSelectorDeModo`,** nuevo en `lib/core/design/componentes/`, con su
vista previa, su documentación y sus pruebas, como los demás. Tiene dos formas, y la elige
el ancho medido:

- **Segmentos** (la oficina, cuando caben): Contenido, Orden, Descarga y Carga, con su
  icono (del paquete, `orden`, `descarga` y `carga`; para Contenido, el del contenedor)
  y, con operación, la cuenta de pendientes en tinta suave y cifras tabulares
  («Descarga 28»).
  El seleccionado va invertido (tinta con texto noche de noche; marca tenue de día). Mide
  40 dp en la oficina y 48 en el muelle. Va en la cabecera y sustituye a los dos
  selectores de hoy.
- **Menú** (el teléfono, o la oficina con poco ancho o la letra grande): un chip con el
  icono, el nombre del modo y ⌄. Se abre en un `MenuAnchor` de Material 3 con la superficie
  de panel, borde en línea y radio 10. Cada entrada mide 56 dp o más: el icono, el nombre,
  una línea con su cuenta («28 por bajar en GTSTC», «29 pendientes: 20 llenos, 9 vacíos»)
  y la palomita en marca la elegida. Con flechas y lector de pantalla, como todo
  `MenuAnchor`.
- Conserva la clave `bay-plan-display-mode` (la usan 13 archivos de pruebas) y los
  textos «Contenido», «Número de orden», «Descarga» y «Carga». En segmentos, «Número de
  orden» se escribe «Orden», con el nombre entero en la descripción emergente.

**El resumen, en fichas de una línea:**

- En la oficina va en la **franja de cifras** (T-117), en tres fichas: primero la bahía,
  que las tarjetas no dicen; después el modo; después el otro modo:
  - Carga: «Bahía 10: cub. 2, bod. 7», «Carga: 29 pendientes, 20 llenos, 9 vacíos» y
    «Descarga: 28, 1 re‑estiba»;
  - Descarga: «Bahía 14: 3 por bajar en cub., 5 en bod., 2 bajados», «GTSTC: 30 por
    bajar, 120 bajados, 3 re‑estibas» y «Carga: 29 pendientes».
- Cada ficha es un rótulo en tinta suave y la cifra tabular en tinta. Lo que no cabe en
  la línea pasa a «⌄ más», que abre el resto encima de la franja, sin mover la rejilla.
- La instrucción «Toca un contenedor para marcarlo como descargado» deja de estar fija:
  va como ayuda del modo en el menú y en la descripción emergente.
- Los botones de la fila de hoy van a la franja de la bahía: «OR / últimos dígitos» a la
  vista en Carga y lo demás en «Acciones». El chip duplicado de la nube sale.
- En el teléfono, la misma línea, sin lo que la barra de la operación ya cuenta: queda la
  bahía. Mide lo mismo que hoy, una línea, así que las medidas de los avisos (10.31 a
  10.33) no cambian; igual se repite la matriz de 18 casos.
- Las frases actuales tienen claves y pruebas (`loading-operation-totals`,
  `bay-discharge-pending`, `operation-discharge-totals`, `bay-loading-pending`;
  `t107_texts_test.dart`). Las claves se conservan en las fichas; las pruebas que comparan
  la frase entera se reescriben y se declaran.

**1920 · la cabecera con el selector en segmentos** (detalle de la del wireframe de T-117)
```
┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
│ BUQUE MANUAL        Publicado   ┌─────────────┬─────────┬───────────────┬──────────────┐   ⌕   ◨ │
│ Viaje M100, escala GTSTC        │ ▦ Contenido │ # Orden │ ↓ Descarga 28 │ ■ ↑ Carga 29 │         │
│                                 └─────────────┴─────────┴───────────────┴──────────────┘         │
└──────────────────────────────────────────────────────────────────────────────────────────────────┘
  ■ = el seleccionado, invertido: tinta con texto noche (13.1). Los números son los pendientes.
```

**1366 · el selector en su forma de menú, abierto** (la entrada elegida lleva la palomita y
el fondo de panel alto)
```
┌──────────────────────────────────────────────────────────────────────┐
│ BUQUE MANUAL     Publicado   [ ↑ Carga ⌄ ]                    ⌕  ◨   │
│ Viaje M100, escala GTSTC     ┌─────────────────────────────────┐     │
│                              │ ▦ Contenido                     │     │
│                              │   El destino de cada contenedor │     │
│                              │ # Número de orden               │     │
│                              │   30 OR del listado             │     │
│                              │ ↓ Descarga                      │     │
│                              │   28 por bajar en GTSTC         │     │
│                              │ ↑ Carga                       ✓ │     │
│                              │   29 pendientes: 20 llenos,     │     │
│                              │   9 vacíos                      │     │
│                              └─────────────────────────────────┘     │
└──────────────────────────────────────────────────────────────────────┘
```

**360 dp · el teléfono (Honor, 360 × 800), Carga, el menú abierto y el resumen en una línea**
```
┌──────────────────────────────────────┐
│ ▣  BUQUE MANUAL          ● Al día    │ banda de la marca
│    Viaje M100, GTSTC                 │
│ ┌─────────────────┬────────────────┐ │
│ │   ↓ Descarga    │ ■ ↑ Carga      │ │ SegmentedButton 48
│ └─────────────────┴────────────────┘ │
├──────────────────────────────────────┤
│ [ ↑ Carga ⌄ ]  100 %   ⋮   OR / últ. │ el chip del modo, 48
│ ┌──────────────────────────────────┐ │
│ │ ▦ Contenido                      │ │ 56 por entrada
│ │   El destino de cada contenedor  │ │
│ │ # Número de orden                │ │
│ │   30 OR del listado              │ │
│ │ ↑ Carga                        ✓ │ │
│ │   29 pendientes: 20 llenos,      │ │
│ │   9 vacíos                       │ │
│ └──────────────────────────────────┘ │
│ Bahía 10: cub. 2, bod. 7          ⌄  │ el resumen: solo la bahía
│ ╭ silueta ╮ …                        │
```
En el teléfono operando, Descarga y Carga siguen en la banda del muelle; el chip ofrece
Contenido, Número de orden y el modo vigente. Con la letra a 2.0, cada entrada crece con su
texto y el menú se desplaza dentro de la pantalla.

### 0.7 T-119 · El mouse y el touchpad

#### 0.7.1 Diagnóstico

- **La rueda no mueve la silueta.** La silueta es un `SingleChildScrollView` horizontal
  (`bs_silueta_buque.dart:194-199`). En Flutter, un desplazable horizontal toma solo el
  componente horizontal del evento de la rueda; la rueda del mouse trae solo el vertical,
  así que no pasa nada. Mayús + rueda sí la mueve: es el modificador que invierte los ejes
  para el mouse (`pointerAxisModifiers`). El touchpad la mueve porque Windows entrega los
  dos dedos de un touchpad de precisión como un gesto de desplazar y ampliar
  (`PointerPanZoom…`), que el desplazable trata como arrastre; en la Web llegan como
  rueda con componente horizontal.
- **El touchpad no amplía.** `PlanZoomViewport` (`plan_drag_confirmation.dart:63-82`)
  escucha `PointerDown` y `PointerMove` y amplía cuando hay **dos contactos**: solo la
  pantalla táctil. El touchpad no produce contactos, produce:
  - en Windows con touchpad de precisión, `PointerPanZoomStart` / `Update` / `End`, con
    la escala del pellizco;
  - en Chrome y Edge, el pellizco llega como **Ctrl + rueda**, y en Windows con un
    touchpad sin controlador de precisión suele llegar igual.
  Nada de eso se escucha hoy. El zoom solo cambia con el chip
  (`zoom_del_plano.dart`, de 75 a 300 % en pasos de 25, `plano_providers.dart:84-86`).
- **No hay barra horizontal.** El desplazamiento horizontal de la rejilla
  (`bay_plan_view.dart:1088-1154`) no lleva `Scrollbar`, y en escritorio Flutter solo la
  pone a los verticales. Con una bahía ancha o con zoom, la derecha de la bahía queda
  fuera de la vista y, para el mouse, solo se alcanza con Mayús + rueda, que nadie conoce.
  Además, la barra que se pusiera dentro del `Transform.scale` del zoom se dibujaría
  ampliada con él.

#### 0.7.2 Cómo se resuelve en Flutter (3.38.9) en Windows y en la Web

| Qué | Cómo | Windows | Web |
|---|---|---|---|
| **Rueda en la silueta** | Un `Listener(onPointerSignal:)` alrededor del desplazable de la silueta (en `SiluetaDelViaje` o como opción de `BsSiluetaBuque`). Con un `PointerScrollEvent` vertical se registra en `GestureBinding.instance.pointerSignalResolver` (gana el primero que se registra, así que la columna no se desplaza a la vez) y mueve el `ScrollController` de la silueta: abajo avanza hacia la popa y arriba regresa hacia la proa, con una animación de 100 ms (cero si se reduce el movimiento) | La rueda trae `scrollDelta.dy` | Igual: la rueda del navegador llega como `PointerScrollEvent` |
| En los extremos | Si la silueta no puede moverse más en ese sentido, no se registra y la rueda pasa a la columna. Con el pestillo de 0.5.3 | | |
| **Pellizco del touchpad** | En `PlanZoomViewport`: `onPointerPanZoomStart` guarda la escala; `onPointerPanZoomUpdate` fija escala × `event.scale` cuando se aparta más de un 1 % de 1.0. Mientras dura el pellizco, el desplazamiento se suspende, como hoy con dos dedos | Touchpad de precisión: llega así | No llega así |
| **Ctrl + rueda** | En el mismo `Listener`, un `PointerScrollEvent` con Ctrl pulsado (`HardwareKeyboard.instance.isControlPressed`) multiplica la escala por e^(−dy/200), registrado en el resolvedor para que la columna no se mueva. Si el motor web entrega el pellizco como `PointerScaleEvent`, multiplica por `event.scale` | Touchpad sin precisión y el mouse con Ctrl | Chrome y Edge entregan el pellizco como Ctrl + rueda |
| **Que el pellizco no amplíe la página (Web)** | El navegador amplía la página con Ctrl + rueda salvo que la página cancele ese evento. **No afirmo si el motor web de Flutter 3.38 ya lo cancela:** se comprueba primero, en 30 min, en Chrome y Edge con el touchpad de Carlos. Si lo cancela, no hay que hacer nada más. Si la página se amplía, en `web/index.html` un escucha no pasivo cancela Ctrl + rueda **solo con el puntero sobre el plano**: Dart avisa al entrar y salir con `dart:js_interop`, del SDK, sin dependencia. Fuera del plano, el zoom del navegador sigue, y Ctrl + «+» y Ctrl + «−» nunca se tocan (accesibilidad). Tocar `web/index.html` está fuera de `lib/` y lo autoriza Carlos (P7) | — | Solo si hace falta |
| **El punto bajo los dedos se queda quieto** | Hoy el zoom amplía desde la esquina de arriba a la izquierda. Al pellizcar, se ajustan el desplazamiento horizontal de la rejilla y el de la columna para que el punto bajo el puntero quede donde estaba: nuevo = (actual + foco) × (escala nueva ÷ escala vieja) − foco | Sí | Sí |
| **Barra horizontal** | Un `ScrollController` en el desplazamiento horizontal de la rejilla y una barra con `thumbVisibility`, `trackVisibility` e `interactive`, abajo, solo cuando la bahía no cabe. El orden cambia: el desplazamiento horizontal va **por fuera** de la escala del zoom, así que la barra no se amplía con él. La barra queda **pegada al borde de abajo de la columna**, justo encima de la franja de cifras, aunque el pie de la rejilla esté más abajo (como en una hoja de cálculo): es la barra de Material envolviendo la columna, con el controlador de la rejilla y un `notificationPredicate` que solo escucha el eje horizontal. La columna deja 14 dp de aire abajo, así que la barra nunca tapa celdas. La pista se toca para avanzar una página; el pulgar se arrastra. Se confirma con una prueba al empezar; si la barra de Material no sirve fuera de su desplazable, se hace una propia de unas 80 líneas sobre el mismo controlador | Sí | Sí |

- **Ctrl + rueda con el mouse.** En la Web, y en Windows con touchpads sin controlador de
  precisión, el pellizco llega como Ctrl + rueda y no se distingue con certeza de la rueda
  del mouse con Ctrl. Si Ctrl + rueda **no** acercara con el mouse, la app tendría que
  adivinar de dónde viene cada evento, y a veces fallaría. **Recomiendo que sí acerque**:
  es la costumbre de los navegadores, de Office y de los visores de planos. Es la
  pregunta P4.
- El teléfono y la tableta conservan el pellizco de dos dedos de hoy.
- **Pruebas:** con eventos sintéticos (`PointerPanZoomUpdateEvent` y `PointerScrollEvent`
  con Ctrl simulado, por `tester.sendEventToBinding`):
  - la rueda sobre la silueta la mueve y no mueve la columna;
  - en el extremo pasa a la columna;
  - el pestillo funciona;
  - el pellizco y Ctrl + rueda cambian la escala, acotada entre 75 y 300 %, sin mover la
    columna;
  - la barra aparece solo cuando hace falta y arrastrarla mueve la rejilla.
- **En la laptop de Carlos,** con su touchpad y su mouse: 15 minutos en Windows y otros
  15 en Chrome y Edge, con su semáforo.

### 0.8 T-120 · Filtrar por destino en la Lista

#### 0.8.1 Diagnóstico

- La Lista (`vessel_overview_page.dart:909-1048`) tiene «Filtrar por Naviera», con «N»
  mayúscula, contra la regla 3 de `DESIGN.md` 11 (`vessel_overview_page.dart:969-972`).
  Son chips en una línea con desplazamiento horizontal (`vessel_overview_page.dart:974-1008`):
  en escritorio, el mismo problema que la leyenda.
- Las cuentas por naviera se calculan en el mismo `build`, recorriendo los contenedores
  una vez por chip (`vessel_overview_page.dart:991-993`).
- El filtro es solo por naviera (`filteredContainersProvider`,
  `vessel_providers.dart:734-748`; la elegida, `vessel_providers.dart:694-711`).
- La cuenta por puerto ya existe para Estadísticas (`portDistributionProvider`,
  `vessel_providers.dart:885-901`), pero escribe «N/A» para el contenedor sin destino
  (`vessel_providers.dart:892`), contra la regla 4. En la Lista no se usa.
- La Lista construye todas sus tarjetas a la vez (`ListView` con `shrinkWrap` dentro de un
  `SingleChildScrollView`, `containers_list_view.dart:28-37`). Es el salto de memoria de
  T-99 (190 → 510 MB). Filtrar ayuda, pero no lo arregla.

#### 0.8.2 Propuesta

- **«Filtrar por destino»** justo debajo de «Filtrar por naviera», que pasa a minúscula.
  Un chip por puerto con la **ficha del puerto** (el relleno y el contorno de su ranura,
  los mismos de la celda y de la leyenda del plano, 13.4), su código y su cuenta en cifras
  tabulares: «GTSTC 520». Van ordenados de más a menos. El contenedor sin destino va en
  «Sin destino 3», nunca «N/A».
- **Elegir un destino filtra la Lista** («cuáles son»), junto con la naviera: se cumplen
  los dos. El título dice «Contenedores (520), destino GTSTC» y lleva «Quitar filtros».
- **Las cuentas son cruzadas:** con una naviera elegida, cada destino cuenta los de esa
  naviera, y al revés. Un chip en cero va apagado y no se toca. «Todos» y «Todas» llevan
  el total del otro filtro (P10).
- **Oficina:** las dos filas en `Wrap`, con el rótulo a la izquierda; nunca se cortan.
- **Teléfono:** `Wrap` de hasta dos líneas y, si no caben, «Ver los n destinos», que abre
  una hoja con todos los puertos, su ficha y su cuenta. Con la letra a 2.0, la hoja llega
  antes. Lo mismo para las navieras.
- **Capas:** un `selectedDestinationProvider` en `presentation/providers/` y el filtro
  doble en `filteredContainersProvider`. Se limpia al abrir otro viaje, como la naviera
  (`vessel_providers.dart:408` y `613`). `domain/` y `data/` no cambian.
- **Opcional, aparte (P10):** pasar la Lista a construcción perezosa (`SliverList`), como
  pedía `DESIGN.md` 10 para RNF-001 y RNF-007. Son 1.5 h más; se mide antes y después con
  T-99.

**1920 · la Lista con los dos filtros**
```
┌──────────────────────────────────────────────────────────────────────────────────────────┐
│ Filtrar por naviera   [Todas 20] [LNA 9] [LNB 6] [LNC 3] [LND 2]                         │
│ Filtrar por destino   [Todos 30] [■ GTSTC 20] [■ USHOU 6] [■ PAMIT 3] [□ Sin destino 1]  │
│                                                                                          │
│ Contenedores (20), destino GTSTC        20 llenos   0 vacíos           [Quitar filtros]  │
│ ┌──────────────────────────────────────────────────────────────────────────────────────┐ │
│ │ ▤  TSTU 000110 8    45G1, 40 HC, lleno     Celda 010-02-06    GTSTC    24.1 t        │ │
│ └──────────────────────────────────────────────────────────────────────────────────────┘ │
│ …                                                                                        │
└──────────────────────────────────────────────────────────────────────────────────────────┘
  ■ = la ficha del puerto: el mismo relleno y contorno que su celda en el plano.
```

**360 dp · la Lista, con la letra a 1.0**
```
┌──────────────────────────────────────┐
│ Filtrar por naviera                  │
│ [Todas 520] [LNA 212] [LNB 160]      │
│ [LNC 98]    [Ver las 6 navieras]     │
│ Filtrar por destino                  │
│ [Todos 977] [■GTSTC 520] [■USHOU 245]│
│ [■PAMIT 130] [■JMKIN 82] [Ver los 7] │
│                                      │
│ Contenedores (520), GTSTC            │
│ 412 llenos  108 vacíos               │
│ [Quitar filtros]                     │
│ ┌──────────────────────────────────┐ │
│ │ ▤ TSTU 000110 8                  │ │
│ │   45G1, lleno, 010-02-06         │ │
│ └──────────────────────────────────┘ │
```

### 0.9 T-121 · Las estadísticas

#### 0.9.1 Inventario de hoy

`voyage_stats_view.dart` (1 156 líneas) es de T-109: el rediseño no lo tocó. Es una sola
columna de tarjetas en un `SingleChildScrollView`, sin ancho máximo y sin el fondo de la
noche (`voyage_stats_view.dart:33-137`). En la oficina, el panel lateral sigue al lado con
«Toca una celda del plano…». Lleva **27 `Colors.*`**, todos de este archivo.

| Pieza | Qué muestra | Colores | Problemas | Dónde |
|---|---|---|---|---|
| Resumen, seis tarjetas | Total de contenedores, bahías ocupadas, peso total, llenos, vacíos, refrigerados | `blue`, `deepPurple`, `orange`, `green`, `amber`, `cyan`: borde al 30 %, icono al 10 %, **la cifra en el color** | Texto en color de dato. De día, sobre blanco: ámbar 1.6:1, naranja 2.2:1, cian 2.3:1, verde 2.8:1, azul 3.1:1 (calculado; Android abre de día). Rótulos con mayúscula en cada palabra («Total Contenedores»). Seis tarjetas iguales y ninguna protagonista | `:174-253`; colores `:205-240` |
| Distribución por estado | Una dona: llenos, vacíos y sin estado | `green.shade600`, `orange.shade600`, `grey.shade400` | Dona de dos porciones (es una cifra o un medidor). «62.6%» sin espacio | `:324-415` |
| Distribución por tamaño | Barra apilada: 20', 40', 45' y otro | `blue`, `indigo` y `purple.shade600`, `grey.shade500`; cifras en `Colors.white` a 12 | **Violeta de adorno.** Blanco sobre azul 600, ≈ 3.7:1 (no llega a 4.5:1 a 12 px). Tonos distintos para algo ordenado (20 < 40 < 45) | `:496-575` |
| Carga especial | Refrigerado, «IMO / DG», OOG | `cyan`, `red`, `deepOrange`: fondo al 8 %, cifra y rótulo en el color | **Naranja de adorno** en OOG, cuyo rol es uva (5.1). «IMO / DG» contra «Peligrosa IMDG» del plano: dos nombres | `:584-712` |
| Por naviera | Barras horizontales, las 10 primeras | `Colors.indigo`, con una opacidad que baja por puesto | **Violeta.** La opacidad dice el puesto, que ya dice el largo. `'monospace'` en vez de Plex Mono. «SIN NAVIERA» en mayúsculas | `:66-77`, `:714-874`; `vessel_providers.dart:872` |
| Por puerto de descarga | Barras horizontales, las 10 primeras | `Colors.teal`, con la misma opacidad | No lleva la muestra del color del puerto que pide 5.5. «N/A» | `:79-90`; `vessel_providers.dart:892` |
| Perfil longitudinal | Ocupación o peso por bahía, como celdas | `primary`; en Peso, **`tertiary`: el naranja de la grúa** | Naranja de adorno, contra 13.3. Texto pintado a 9 (por debajo del mínimo de 10) y a 10 (por debajo del 11 del muelle). «85%» y «416.8t». Su casco no es el de `BsSiluetaBuque`: hay dos buques distintos en la app | `vessel_profile_view.dart:56-58`, `329-344`, `357-363` |
| Contenedores por bahía | Columnas | `blue.shade600` | Número de bahía **girado** (`RotatedBox`) y letra a 9. Sin barra en escritorio | `:922-1016` |
| Peso por bahía | Columnas | **`orange.shade700`** | Naranja de adorno. Girado, letra a 9, «t» pegada | `:1018-1114` |
| Títulos de sección | Siete títulos con icono | `primary` | Mayúscula en cada palabra («Distribución por Puerto de Descarga»). Peso 700, fuera de la escala | `:148-172`, `:43-130` |
| La página | — | — | Ninguna vista de tabla. Las barras se estiran a todo el ancho de 1920 | `:33-137` |

#### 0.9.2 Lo que se toma de cada referencia

| Referencia | Qué se toma | En A | En B |
|---|---|---|---|
| Maestro | El fondo oscuro técnico con rejilla | `BsFondoDePlano` (rejilla al 5 %) detrás; paneles encima | Igual |
| ShipX | Las cifras grandes en tarjetas | La fila de cifras junto a la protagonista | El mosaico de puertos |
| OceanView | El azul profundo y el anillo | La rampa de marca; el anillo de llenos | El anillo de la parte del puerto |
| Shipping Logistics Dashboard | La silueta del buque y los códigos de puerto en caja | **La silueta grande es la protagonista**; los códigos en caja en las barras | **Los puertos en caja son los protagonistas**; una silueta pequeña dice dónde va cada uno |
| Craftwork (kit marítimo) | Las alertas con color y peso propios | Las tarjetas de carga especial con el relleno, el contorno y el icono de su rol | Igual |

#### 0.9.3 Lo común a las dos propuestas

- **Ningún `Colors.*`:** todo sale del tema y de `BsColoresSemanticos`. Una prueba-censo
  falla si vuelve uno a la carpeta de presentación.
- **Una sola rampa para las magnitudes,** validada con el script (0.9.4). Las barras de una
  sola serie van en un solo color: marca de día, selección de noche.
- **El color del puerto va solo en la caja del código,** con el código escrito. El
  validador rechaza las fichas como relleno de barra (abajo), así que nunca lo son.
- **Carga especial con su rol:** peligrosa, refrigerado y fuera de medida, con el relleno,
  el contorno y el icono del paquete. El uva de OOG es su rol de 5.1, no un adorno.
- **El naranja no aparece:** en Estadísticas no hay nada que se acabe de mover (13.3).
- **El texto nunca lleva el color del dato.** Mínimo 11 en el teléfono, nunca girado,
  tipo oración, «53 %» con espacio, «7 419.5 t» con `formatearToneladas`, Plex Mono para
  los códigos.
- **Todo gráfico tiene su tabla:** «Ver como tabla» muestra los mismos números en una
  tabla accesible. La barra lleva su descripción emergente con el mouse y su etiqueta para
  el lector de pantalla.
- **Toca una bahía o un puerto y lleva al plano o a la Lista** con ese filtro (T-120).
- **Ninguna dependencia:** `CustomPainter` y widgets. Ancho máximo de 1 440, centrado.
- **En la oficina,** el panel lateral lleva solo «En vivo», o se oculta (T-117).
- **A 360 dp con la letra a 2.0:** todo apila a todo el ancho; la etiqueta va encima de su
  barra; la silueta se desplaza con su barra visible. Nada se corta.

#### 0.9.4 La paleta, validada

Con `validate_palette.js` de la skill de dataviz (Node 24; el umbral de las rampas es
2:1 del paso extremo contra la superficie):

| Paleta | Superficie | Resultado |
|---|---|---|
| La rampa de 5.5 tal como está (`#D9E7FC → #95BBF6 → #518FF1 → #1365E5 → #0D47A1`) | Hoja de día `#FFFFFF` | **Falla:** el paso claro queda a 1.25:1 |
| Sin el paso más claro (`#95BBF6 → … → #0D47A1`) | `#FFFFFF` | **Falla** por poco: 1.96:1 |
| **Día propuesta:** `#88B0F5 → #518FF1 → #1365E5 → #0D47A1` | `#FFFFFF` y papel `#F5F8FC` | **Pasa** (2.19:1 y 2.06:1, un solo tono, pasos visibles) |
| **Noche propuesta:** `#2C5BA8 → #4F8EF7 → #95BBF6 → #D9E7FC` (más es más claro) | Panel `#0C1A31` y noche `#07111F` | **Pasa** (2.62:1 y 2.86:1) |
| Las fichas de los cinco primeros puertos, de noche (`#FFB2BD`, `#84D7FE`, `#98DF9A`, `#E7B3FF`, `#F8BF6C`) como serie | `#0C1A31` | **Falla como relleno de serie:** luminosidad fuera de la banda, croma bajo en dos, y cielo y hierba a ΔE 14.6 con visión normal |
| Los contornos de día de esos cinco | `#FFFFFF` | Falla la banda y el croma; pasa la separación |

- `#D9E7FC` queda como pista de las barras, no como dato. `#88B0F5` es un valor nuevo:
  entra en `bs_paleta.dart` y en `DESIGN.md` 5.5 antes que en el código.
- **Las fichas no sirven como color de barra:** se hicieron para que el código se lea
  sobre el relleno (13.4), no para separar series. Por eso el puerto se identifica por su
  caja con el código escrito, y la barra va en el color de la rampa.

#### 0.9.5 Propuesta A · «El buque en corte»

**La protagonista es la silueta, en grande:** el buque de proa a popa, y cada bahía una pila
con sus contenedores en cubierta y en bodega, como en el plano.

- **La cifra protagonista: «977 contenedores a bordo».** Encima van, en la fila de cifras
  (ShipX), el peso total, las bahías, los llenos y los vacíos.
- Debajo de cada bahía va su cuenta; debajo, el peso por bahía en columnas **alineadas
  con la silueta** (el mismo eje), en acero, nunca girado.
- «Contenedores / Peso» cambia lo que dice la altura de la pila.
- Tocar una bahía la abre en el plano.
- **Debajo, en tres paneles:**
  - por puerto de descarga: la caja del código, la barra y la cifra al final; los
    puertos que pasan de siete van en «Otros 3 puertos»;
  - llenos y vacíos: el anillo de llenos, un medidor de una razón;
  - por tamaño: 20, 40 y 45 en la rampa, porque van en orden.
- La carga especial va en tarjetas de su rol.
- Las navieras van como barras, las ocho primeras y «Otras».
- **Por qué:** la silueta es la firma de la app y de la dirección («la app es el ícono en
  grande»). Estadísticas pasa a ser el mismo buque del plano, visto entero. Para el
  tribunal se lee de un vistazo: dónde va la carga y cuánta es.

Las cifras de los wireframes de T-121 son de ejemplo, las del wireframe de `DESIGN.md` 9.5,
y cuadran entre sí (977 = 612 llenos + 365 vacíos = la suma de los puertos y de los
tamaños).

**1920 × 1080 · Propuesta A** (el panel lateral oculto; contenido a 1 440, centrado)
```
┌ Estadísticas ───────────────────────────────────────────────────── BUQUE MANUAL, viaje M100 ┐
│                                                                          [Ver como tabla]   │
│ 977                                   7 419.5 t     27 bahías     612 llenos   365 vacíos   │
│ contenedores a bordo                  peso total    con carga                               │
│                                                                                             │
│               ▌▌  ▌▌▌ ▌▌▌ ▌▌▌                                                               │
│ Proa ╭──▌▌──▌▌▌──▌▌▌▌─▌▌▌▌─▌▌▌▌──▌▌▌▌──▌▌▌──▌▌──▌▌─────╮ Popa    cada pila: los             │
│      │  ▌▌  ▌▌▌  ▌▌▌▌ ▌▌▌▌ ▌▌▌▌  ▌▌▌▌  ▌▌▌  ▌▌  ▌▌     │         contenedores de la         │
│      ╰─────────────────────────────────────────────────╯         bahía, cubierta y bodega   │
│         02  06   10   14   18    22    26   30  34                                          │
│         63  58   61   44   52    49    38   41  29          contenedores                    │
│         ▂▂  ▃▃   ▅▅   ▇▇   ▆▆    ▅▅    ▃▃   ▃▃  ▂▂          peso, t (el mismo eje)          │
│      [ ■ Contenedores | Peso ]     Toca una bahía para abrirla en el plano                  │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
┌ Por puerto de descarga ─────────────────────┐ ┌ Llenos y vacíos ──┐ ┌ Carga especial ───────┐
│ [GTSTC] ████████████████████████  520  53 % │ │    ◔   63 %       │ │ ◆   3  Peligrosa IMDG │
│ [USHOU] ████████████  245  25 %             │ │   612 llenos      │ │ *  12  Refrigerado    │
│ [PAMIT] ██████  130  13 %                   │ │   365 vacíos      │ │ ⇔   1  Fuera de medida│
│ [JMKIN] ██  42  4 %                         │ └───────────────────┘ └───────────────────────┘
│ Otros 3 puertos  ██  40  4 %                │ ┌ Por tamaño ─────────────────────────────────┐
└─────────────────────────────────────────────┘ │ 20'  ███████████████  410  42 %             │
┌ Por naviera ────────────────────────────────┐ │ 40'  ██████████████████  487  50 %          │
│ LNA  ████████████████  412  42 %            │ │ 45'  ███  80  8 %                           │
│ LNB  ███████████  301  31 %   … y 4 más     │ └─────────────────────────────────────────────┘
└─────────────────────────────────────────────┘
  [GTSTC] = la caja del puerto con su ficha. Las barras, en un solo azul. Los roles, con icono.
```

**360 × 800 con la letra a 2.0 · Propuesta A**
```
┌──────────────────────────────────────┐
│ Estadísticas                 Tabla   │
├──────────────────────────────────────┤
│ 977                                  │ la protagonista
│ contenedores a bordo                 │
│ 7 419.5 t                            │ las demás cifras
│ peso total                           │ apilan, una por
│ 27 bahías con carga                  │ línea
│ 612 llenos                           │
│ 365 vacíos                           │
│ ┌──────────────────────────────────┐ │
│ │ Proa ╭─▌▌─▌▌▌─▌▌▌▌─▌▌▌▌─…        │ │ la silueta se
│ │      02  06  10   14             │ │ desplaza, con su
│ │      63  58  61   44             │ │ barra visible
│ │ ════════════                     │ │
│ └──────────────────────────────────┘ │
│ [ ■ Contenedores | Peso ]            │
│ Por puerto de descarga               │
│ [GTSTC]                              │ la caja arriba,
│ 520  53 %                            │ la cifra debajo
│ ████████████████████████████████     │ y la barra a
│ [USHOU]                              │ todo el ancho
│ 245  25 %                            │
│ ███████████████                      │
```

#### 0.9.6 Propuesta B · «Tablero de destinos»

**Los protagonistas son los puertos, en caja.** La pregunta del agente naviero es «¿cuánto va
a cada puerto y dónde está?».

- **La cifra protagonista: «GTSTC, 520 contenedores, 53 %».** Es el puerto de la escala
  de este viaje (lo que baja aquí) o, sin escala, el que más lleva. Un anillo grande dice
  su parte del total; al lado, su peso, sus llenos y sus vacíos.
- **«Dónde va»:** una silueta pequeña con sus bahías en marca y las demás apagadas.
- «Ver en la Lista» la abre filtrada por ese destino (T-120); «Ver en el plano» abre su
  primera bahía.
- **A la derecha, el mosaico de los demás puertos** (ShipX): cada tarjeta lleva la caja
  del código, la cifra, el porcentaje y una barra corta. Tocar una la vuelve protagonista.
- **Debajo,** una línea con el total a bordo; la composición (llenos y vacíos, tamaños) y
  la carga especial con sus roles, como en A; y las navieras en una tabla con barras.
- **Por qué:** se alinea con T-120 y con el trabajo de la oficina, que reparte por destino.
  Es más operativa y menos «la app en grande».

**1920 × 1080 · Propuesta B**
```
┌ Estadísticas ───────────────────────────────────────────────────── BUQUE MANUAL, viaje M100 ┐
│                                                                          [Ver como tabla]   │
│ ┌──────────────────────────────────────────────────┐ ┌────────┐ ┌────────┐ ┌────────┐       │
│ │ [GTSTC]   escala de este viaje                   │ │[USHOU] │ │[PAMIT] │ │[JMKIN] │       │
│ │                                                  │ │  245   │ │  130   │ │   42   │       │
│ │   ╭──╮    520                                    │ │  25 %  │ │  13 %  │ │   4 %  │       │
│ │  │53 %│   contenedores                           │ │ ███    │ │ ██     │ │ █      │       │
│ │   ╰──╯    3 120.4 t, 412 llenos, 108 vacíos      │ └────────┘ └────────┘ └────────┘       │
│ │                                                  │ ┌────────┐ ┌────────┐ ┌────────┐       │
│ │   Dónde va:  ╭─▪▪─▌▌─▌▌▌─▪▪▪─▌▌─▪▪─▪▪──╮         │ │[JMKCT] │ │[COSPC] │ │Otros 2 │       │
│ │              02 06  10  14 18 22 26              │ │   20   │ │   12   │ │    8   │       │
│ │   [Ver en la Lista]   [Ver en el plano]          │ │   2 %  │ │   1 %  │ │   1 %  │       │
│ └──────────────────────────────────────────────────┘ │ ▌      │ │ ▌      │ │ ▌      │       │
│                                                      └────────┘ └────────┘ └────────┘       │
│ A bordo: 977 contenedores, 7 419.5 t, 27 bahías con carga                                   │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
┌ Llenos y vacíos ──┐ ┌ Por tamaño ─────────────────────────┐ ┌ Carga especial ───────────────┐
│    ◔   63 %       │ │ 20'  ███████████████  410  42 %     │ │ ◆   3  Peligrosa IMDG         │
│   612 llenos      │ │ 40'  ██████████████████  487  50 %  │ │ *  12  Refrigerado            │
│   365 vacíos      │ │ 45'  ███  80  8 %                   │ │ ⇔   1  Fuera de medida        │
└───────────────────┘ └─────────────────────────────────────┘ └───────────────────────────────┘
┌ Por naviera ────────────────────────────────────────────────────────────────────────────────┐
│ Naviera   Contenedores          Llenos   Vacíos                                             │
│ LNA       ████████████  412     300      112                                                │
│ LNB       █████████  301        212       89                                                │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
  ▌ = bahía con contenedores para el puerto elegido; ▪ = las demás, apagadas.
```

**360 × 800 con la letra a 2.0 · Propuesta B**
```
┌──────────────────────────────────────┐
│ Estadísticas                 Tabla   │
├──────────────────────────────────────┤
│ ┌──────────────────────────────────┐ │
│ │ [GTSTC]                          │ │ la protagonista,
│ │ escala de este viaje             │ │ a todo el ancho
│ │  ╭──╮                            │ │
│ │ │53 %│                           │ │
│ │  ╰──╯                            │ │
│ │ 520                              │ │
│ │ contenedores                     │ │
│ │ 3 120.4 t                        │ │
│ │ [Ver en la Lista]                │ │
│ └──────────────────────────────────┘ │
│ ┌──────────────────────────────────┐ │ los demás puertos,
│ │ [USHOU]                          │ │ uno por fila con
│ │ 245  25 %                        │ │ la letra a 2.0
│ │ ███████████                      │ │ (dos por fila
│ └──────────────────────────────────┘ │ con 1.0)
│ ┌──────────────────────────────────┐ │
│ │ [PAMIT]                          │ │
│ │ 130  13 %                        │ │
```

#### 0.9.7 Comparación y recomendación

| | A · El buque en corte | B · Tablero de destinos |
|---|---|---|
| Protagonista | La silueta del buque con la carga por bahía | El puerto en caja con su anillo |
| Cifra protagonista | 977 contenedores a bordo | GTSTC, 520 contenedores, 53 % |
| Qué contesta primero | ¿Dónde va la carga en el buque y cuánta es? | ¿Cuánto va a cada puerto y dónde está? |
| Firma de la dirección | Máxima: el buque del plano, entero | Media: la silueta es secundaria |
| Sin escala (previo, mirar) | Igual | El protagonista es el puerto que más lleva |
| Riesgo | La silueta con 40 bahías (5000 contenedores) se desplaza a lo ancho; se prueba con T99 SINTÉTICO | Con un solo puerto, el mosaico queda vacío: la protagonista se queda sola |
| Horas | 11–13 | 12–14 |

**Recomiendo A:** cumple la dirección «Puente de mando» al pie de la letra, une Estadísticas
con el plano y es la de más impacto para la presentación final. Si lo que diga COMAR en el
piloto apunta a los destinos, B sigue disponible, y su «Ver en la Lista» se puede sumar a A
en las barras por puerto.

**La cifra protagonista** pide 48 dp, por encima de los 34 de la cifra grande, el tamaño
mayor de la escala de `DESIGN.md` 4.2. La skill de dataviz pide 48 o más para la única
cifra que encabeza una vista. Es un tamaño nuevo (`BsEscala.cifraProtagonista`), una sola
vez por vista, y se escribe en `DESIGN.md` antes del código (P9).

### 0.10 Horas, orden y entregas

| Tarea | Horas | Qué incluye |
|---|---:|---|
| **T-117** | 16–19 | Columna desplazable con la franja fijada y la escala del plano que informa su tamaño (4). El puente en tres alturas: borde, botón, teclado y semántica (3). El panel fijo, flotante y por el borde; el detalle con el panel oculto; «En vivo» sin desbordarse (3). Preferencias, con el cambio mínimo de 0.5.7 si Carlos lo aprueba, y Parámetros (1.5). La franja de cifras con los avisos por construcción, más O3 (1.5). La matriz de pruebas y las capturas de Windows y la Web (4) |
| **T-118** | 6–8 | `BsSelectorDeModo` con vista previa, documentación y pruebas (2.5). La cabecera de la oficina y el chip del teléfono (1.5). El resumen en fichas (1). Las 13 pruebas del selector y las de T-107 reescritas; la matriz de avisos de 18 casos en el emulador (2). Las capturas de los tres clientes (1) |
| **T-119** | 8–10 | La rueda en la silueta con el pestillo (1.5). El pellizco y Ctrl + rueda, con el punto fijo bajo los dedos (3). La comprobación de la Web y, si hace falta, la guarda de `web/index.html` (1–2). La barra horizontal pegada (2). Las pruebas con eventos sintéticos y 30 min en la laptop de Carlos (1.5) |
| **T-120** | 3–4 | El provider, los chips con ficha y cuenta cruzada, la hoja del teléfono, los textos, las pruebas y las capturas. La Lista perezosa, aparte: 1.5 h más |
| **T-121** | 11–13 (A) o 12–14 (B) | La página nueva, las piezas (la silueta grande o el mosaico, el medidor, las tarjetas de rol, la vista de tabla), la rampa en `bs_paleta.dart`, `DESIGN.md` y las pruebas: contraste compuesto, 360 dp a 2.0 sin desbordes, `meetsGuideline` y el censo sin `Colors.*`. Las capturas en los dos temas y los tres clientes |
| Común | 3 | `DESIGN.md` (secciones nuevas para la oficina y las estadísticas), el informe, el apoyo a la aceptación |
| **Total** | **47–57** | Unos siete días de trabajo, más las aceptaciones de Codex |

**Orden recomendado,** desde el 27-oct, con lo que diga COMAR (10.36), una entrega aceptada
por Codex antes de la siguiente:

1. **Entrega 1, T-117 + T-118.** La estructura de la oficina. Las dos tocan los mismos
   archivos (`vessel_overview_page.dart`, `bay_plan_view.dart`,
   `loading_plan_controls.dart`), y la franja de cifras es a la vez el resumen de T-118 y
   el lugar de los avisos de T-117. Por separado, se tocaría dos veces lo mismo.
2. **Entrega 2, T-121.** El mayor impacto para la presentación final.
3. **Entrega 3, T-119 + T-120.** La barra horizontal necesita la columna de la entrega 1.

Si la presentación es el 7-nov, las entregas 1 y 2 caben antes y la 3 puede quedar para la
3.2.1. Si es el 14-nov, caben las tres en la 3.2.0 (P11).

### 0.11 Riesgos

| Riesgo | Qué se hace |
|---|---|
| **Los avisos (10.30–10.33)** cambian de sitio en la oficina | La franja de cifras usa las mismas piezas que el muelle (`MideLaFranja`, `LugarDelAviso`, `avisoDelViaje`). La matriz de avisos se extiende a la oficina (siete tamaños y tres letras). La guarda de `SnackBar(` sigue en todo `lib/` |
| **Dos caminos para el plano:** las capas de la oficina y el `NestedScrollView` del teléfono | Comparten la rejilla (`_Rejilla`); solo cambia el envoltorio. El teléfono no se toca y su matriz se repite |
| **RNF-002 y los instrumentos de T-98 y T-99** | El conductor busca la rejilla al final de los tres pasos; si la estructura cambia, se actualiza antes de medir (3.10) y RNF-002 se vuelve a medir en Windows (hoy 1.84–1.89 s) |
| **La rueda se roba entre la silueta y la columna** | El resolvedor de señales y el pestillo de 300 ms, con pruebas |
| **La Web puede ampliar la página con Ctrl + rueda** | Se comprueba primero (30 min); la guarda solo sobre el plano y solo con el permiso de Carlos (P7) |
| **El touchpad real no se simula del todo** | Pruebas con eventos sintéticos y 30 min en la laptop de Carlos, con su semáforo |
| **El cambio de DPI al arrastrar entre monitores** | Los umbrales ya no mueven el alto del puente; se prueba en la ventana real si hay un segundo monitor (P11) |
| **Las preferencias tocan `domain/` y `data/`** | Lo mínimo de 0.5.7, solo si Carlos lo aprueba; si no, viven en memoria y se pierden al cerrar |
| **El selector cambia de widget** | La clave `bay-plan-display-mode` se conserva; 13 archivos de pruebas se adaptan y se declaran; la lista del piloto se revisa después del piloto |
| **La cifra protagonista fuera de la escala** | Se escribe en `DESIGN.md` y la decide Carlos (P9) |
| **El tiempo:** 47–57 h para el 7 o el 14-nov | Tres entregas que se publican por separado; T-119 y T-120 pueden ir en una 3.2.1 |
| **Lo que diga COMAR el 25 y el 26** | La implementación arranca el 27; si el piloto cambia una prioridad (O3, T-61), se reordena antes de empezar |

### 0.12 Preguntas para Carlos

Cada una con la opción que recomiendo primero.

| # | Pregunta | Recomiendo | La otra opción |
|---|---|---|---|
| P1 | ¿El borde del puente se queda en tres alturas al soltar, o en cualquier alto? | **Tres alturas** (completo, compacto, plegado): nada se corta ni se estira | Alto libre, con la silueta y las tarjetas recortadas en los altos intermedios |
| P2 | ¿Se aprueba el cambio mínimo en `domain/` y `data/` para guardar las preferencias (0.5.7)? | **Sí:** un par leer y guardar, unas 20 líneas, sin migración | Que vivan en memoria y se pierdan al cerrar la app |
| P3 | ¿«Cada usuario» es el usuario del equipo o la cuenta de BayStream? | **El del equipo** (la cuenta de Windows o el perfil del navegador) | Por cuenta, guardado en Firestore: fuera del alcance |
| P4 | ¿Ctrl + rueda acerca y aleja también con el mouse? | **Sí:** es la costumbre, y en la Web el pellizco llega igual que Ctrl + rueda | Solo el pellizco, adivinando el origen del evento |
| P5 | Con el panel oculto, ¿dónde se ve el detalle del contenedor? | **El panel sale flotante con el detalle** y se va al cerrar | La hoja de abajo del teléfono |
| P6 | ¿«Mostrar al pasar el mouse» viene encendido? | **Sí,** con 250 ms de espera; se apaga en Parámetros | Apagado hasta que se encienda |
| P7 | Si la Web amplía la página con el pellizco, ¿se autoriza tocar `web/index.html`? | **Sí, solo si la comprobación lo demuestra,** y la guarda solo sobre el plano | No tocarlo y aceptar que el navegador amplíe |
| P8 | ¿Qué estadísticas? | **A · El buque en corte** | B · Tablero de destinos |
| P9 | ¿La cifra protagonista de Estadísticas va a 48 dp? | **Sí, una por vista,** escrita en `DESIGN.md` | Quedarse en 34, la cifra grande de hoy |
| P10 | En la Lista, ¿cuentas cruzadas entre naviera y destino? ¿Y la Lista perezosa en la misma entrega? | **Cruzadas, sí. Perezosa, aparte,** si no cabe en el tiempo | Cuentas fijas del viaje; perezosa dentro de T-120 |
| P11 | ¿Cuándo es la presentación final, el 7 o el 14-nov? ¿Hay un segundo monitor para probar el arrastre? | El orden de 0.10: **entregas 1 y 2 primero** | T-121 primero si la fecha es el 7 |

### 0.13 Lo que esta fase no hizo

- No tocó `lib/`, `test/` ni `pubspec.*`, y no corrió Flutter. Las medidas salen del código
  y de dos capturas de la candidata; las que quedan por medir en la implementación son:
  - el alto real de la ventana maximizada a 1366 × 768 y 1920 × 1080 (100 y 125 %);
  - el ancho real de la leyenda con el corpus A08 en Carga;
  - el ancho del riel;
  - el alto de «En vivo» con 8 eventos a 1.0, 1.45 y 2.0;
  - si el motor web de Flutter 3.38 cancela Ctrl + rueda;
  - la escala que entrega el touchpad de Carlos.
- No abrió el corpus, ni las apps, ni el Honor, ni Firebase. La 3.1.0 publicada no cambia.
- No escribió `DESIGN.md`: lo que se elija entra ahí al empezar la implementación, antes
  del código (regla de `DESIGN.md`, encabezado).

### 0.14 Archivos y Git

**Archivo nuevo:** `docs/T117-T121-RESULTADOS.md` (este informe). Ningún otro archivo cambió.
No cambian `pubspec.yaml` ni `pubspec.lock`.

**Para Carlos:**

```bash
git add -- docs/T117-T121-RESULTADOS.md
git commit -m "Sprint 4: T-117 a T-121, fase 0, diagnostico y propuesta de las mejoras de la oficina y las estadisticas" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
git push
```

**Mensaje para Yov:**

> Yov: la Fase 0 de T-117 a T-121 está en `docs/T117-T121-RESULTADOS.md`, sin código y sin
> Flutter. Lo de arriba del plano ocupa de 40 a 63 % de la ventana: la columna no se
> desplaza, y las tarjetas pasan a dos filas entre 1 040 y 1 399 dp útiles, el caso de la
> laptop de Carlos. La leyenda se corta porque su `Wrap` vive dentro de un desplazamiento
> horizontal. Propongo:
> - una columna que se desplaza entera, con el puente en tres alturas y una franja de
>   cifras fija donde viven los avisos, como en el muelle (cierra O3);
> - un selector de modo único;
> - la rueda, el pellizco y la barra horizontal;
> - el filtro por destino en la Lista;
> - dos estadísticas («El buque en corte», que recomiendo, y «Tablero de destinos»), con la
>   rampa validada por script.
>
> Son 47–57 h en tres entregas. Guardar las preferencias exige un par de métodos en
> `domain/` y `data/`. Carlos decide once preguntas (0.12). El bloque de Git lleva solo el
> informe.

**ALTO: Carlos elige.**
