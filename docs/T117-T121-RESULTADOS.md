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

---

## Entrega 1 · T-117 y T-118 (24-oct-2026)

Timonel (Claude Code, Claude Opus 5.5), rama `sprint-4`, carpeta del rediseño, sobre
`430fa29` (decisión 10.39). Lo decidido está en 10.38: el puente en tres alturas, la columna
que se desplaza entera con la franja de la bahía arriba y la de cifras abajo, el panel lateral
fijo, oculto o flotante, las tres preferencias por equipo con el cambio mínimo de 0.5.7, y un
solo selector de modo con el resumen en fichas.

### E1.1 Resultado en tres líneas

- **La oficina tiene más plano y nada se corta:** la columna central se desplaza entera; el
  panel del buque (silueta y tarjetas cortas) va en tres alturas con un borde que se arrastra;
  la franja de la bahía se queda arriba y la de cifras abajo, donde viven los avisos (cierra
  O3); el panel lateral se oculta, sale flotante por el borde y lleva el detalle con el panel
  oculto; la app recuerda las tres preferencias en el equipo.
- **Un solo selector de modo,** `BsSelectorDeModo`, en segmentos o en menú según el ancho
  medido (`BsPrimeraQueCabe`), en la cabecera de la oficina y como menú en el teléfono; el
  resumen del modo en fichas de una línea; «Colorear por» con el mismo selector.
- **Suite 1629 (piso 1371), sin fallidas ni omitidas, en una sola corrida, y `analyze` en
  cero.** La matriz de 0.5.5 son 189 pruebas y pasa; desde la tarde (10.40) comprueba además
  que, con el panel fijo y la letra a 1.0, la franja de la bahía va en una línea a 1536 × 793 y
  a 1366 × 690: las cifras de la bahía bajaron a la franja de cifras. **RNF-002 en Windows: 5 de
  5, tres pasos, de 2.17 a 2.68 s.** Capturas de Windows (72) y de la Web (24) y la ventana
  real (8), con datos sintéticos (E1.6).

### E1.2 Base, luz verde y lo que se corrió

- Leí `AGENTS.md`, `CLAUDE.md`, la sección 2 de `SPRINT-3.md` y de `SPRINT-4.md`, las
  decisiones 10.30 a 10.39, la fase 0 de este informe y `DESIGN.md` entero.
- **Primero `DESIGN.md`** (sección 14, notas en 8 y 13.11), después el código.
- **Luz verde de Carlos a las 11:53** para `analyze`, las pruebas nuevas y la suite, hasta las
  13:00. Corrí, uno a la vez: `flutter analyze --no-pub` (varias veces), `flutter test` de los
  archivos nuevos y de los que fallaban, pruebas de exploración en el scratchpad (las medidas de
  E1.6) y **tres suites completas**: la primera dio 1548 aprobadas y 78 fallidas (E1.7); la
  última, después de los arreglos, **1627 aprobadas en una sola corrida, sin omitidas**. Paré
  Flutter a las 12:32.
- No compilé ni abrí ninguna app, no usé el Honor ni el emulador, no toqué las apps
  instaladas, «PRUEBA T-105», `C:\Proyectos\baystream-demo17\`, Firebase ni el corpus. Nada
  se publicó: la 3.1.0 es la del piloto.
- **La tarde (10.40, ≈ 14:55 a 16:50).** Yov revisó el bloque y Carlos lo subió (`096b8dc`).
  Con la luz verde para Flutter, un comando a la vez, en este orden: el ajuste de la franja de
  la bahía con `analyze` y la suite (E1.6); el banco r4 de Windows y de la Web, compilado en
  `%TEMP%\t99-r4-e1` desde el árbol (`tool/t99_copia.ps1 -Arbol -Sufijo r4`, con `T100_LLEGADA`,
  `T100_CARGA` y `T99_SINTETICO_977`); RNF-002 con su `SEMÁFORO:` al empezar y al terminar; las
  capturas; y la ventana real. El banco se abrió siempre con `explorer.exe` y con su almacén en
  `%TEMP%`. No se usaron el Honor, el emulador, las apps instaladas, «PRUEBA T-105», el corpus ni
  «Nube y cuenta». Nada se publicó.

### E1.3 Lo hecho · T-117

| Pieza | Dónde | Qué hace |
|---|---|---|
| La columna central | `bay_plan_view.dart` (`_columnaDeOficina`) | `CustomScrollView` con el panel del buque, la franja de la bahía, la rejilla a su alto natural y la leyenda que envuelve; abajo, fija, la franja de cifras (en el muelle operando, la barra de la operación) |
| La rejilla a su alto natural | `plan_drag_confirmation.dart` (`PlanZoomViewport(alturaNatural:)`, `_AltoAmpliado`) | Amplía la rejilla y le dice a la columna su alto ampliado; conserva el desplazamiento horizontal, el pellizco y el arrastre de T-105 |
| El panel del buque | `puente_del_plano.dart` | Completo, compacto y plegado, medidos; el borde de 12 dp se arrastra (muestra la altura más grande que cabe y al soltar queda en la más cercana), doble clic, teclado (↑ ↓ Intro Espacio) y semántica de control ajustable |
| La franja de la bahía | `franjas_del_plano.dart` (`FranjaDeLaBahia`, `FranjaFijadaSiCabe`) | ‹ y ›, el título que abre la lista de bahías, «Colorear por», el zoom, «OR / últimos dígitos», «Acciones» y el botón del panel; una línea si cabe (con «Colorear por» en segmentos, en menú o, además, el OR solo con su icono), si no envuelve; se fija arriba solo si mide un tercio de la columna o menos |
| La franja de cifras | `franjas_del_plano.dart` (`FranjaDeCifras`) y `resumen_del_modo.dart` | Las fichas del modo, empezando por la bahía con sus cifras (10.40); mínimo 64 dp, tope de un cuarto de la ventana, sin controles |
| Los avisos en la oficina | `avisos_del_viaje.dart` | `MideLaFranja(sinControles:)`, `MideLosLados` (el ancho de la columna) y `AvisosSobreElPie(oficina:, derechaDeLaColumna:)`: el aviso vive en la franja de cifras y no sale de la columna |
| El panel lateral | `vessel_overview_page.dart` | Fijo, oculto con el botón de la cabecera (y recordado), flotante por el borde de 12 dp (250 ms con el mouse, se va a los 400 ms), por un toque o por una celda; «Fijar», «Cerrar», Esc, clic fuera y Atrás; «En vivo» con hasta la mitad del alto y desplazamiento propio |
| Las preferencias | `providers/oficina_providers.dart` | `preferenciasDeLaOficinaProvider`: lee las tres al abrir (un fallo es «sin valor»), elige al momento y guarda; `alternarAltura` vuelve a la última altura abierta |
| Parámetros | `parameters_page.dart` | «Mostrar el panel lateral al pasar el mouse por el borde», solo desde 600 dp; si no se guarda, un aviso con la causa y la acción |
| Oficina o teléfono | `navegacion_del_viaje.dart` (`PanelLateralDisponible.enLaOficina`) | Lo decide la página; el plano suelto mide su ancho (E1.5, punto 4) |

### E1.4 Lo hecho · T-118

- **`BsSelectorDeModo<T>`** (`lib/core/design/componentes/bs_selector_de_modo.dart`): segmentos
  (icono, rótulo corto, cuenta en tinta suave, el elegido invertido, el nombre entero y la ayuda
  en la descripción emergente) o menú (`MenuAnchor` con panel, borde y radio de hoja; entradas
  de 56 dp o más con icono, nombre, cuenta o ayuda y la palomita). Con vista previa y pruebas.
- **`BsPrimeraQueCabe`** (`bs_primera_que_cabe.dart`): pone la primera variante que cabe a lo
  ancho; las demás no se dibujan, no reciben el foco ni toques, y se arman sin tamaño (así los
  instrumentos de T-99, que buscan lo que tiene tamaño, no las toman por visibles).
- **`BsFichaDeCifra`** (`bs_ficha_de_cifra.dart`) y **`BsTarjetaCifra(corta: true)`**: la ficha
  del resumen y la tarjeta del panel del buque (72 dp, el detalle en la etiqueta).
- **El selector en la página:** `SelectorDelModo` (`loading_plan_controls.dart`) con la clave
  `bay-plan-display-mode`; en la cabecera de la oficina con el Plano a la vista; en el teléfono
  como menú, que con la banda del muelle ofrece Contenido, Número de orden y el modo vigente.
  Sustituye al `DropdownButton` y al `SegmentedButton` Descarga / Carga de la cabecera.
- **El resumen en fichas** (`resumen_del_modo.dart`), en la franja de cifras y en la línea de
  T-107 del teléfono; las claves de T-107 se conservan. «Toca un contenedor para marcarlo como
  descargado» pasa a la ayuda de Descarga; «Importar listado» a «Acciones»;
  `DischargeSummary` sale (lo sustituyen las fichas).
- **«Acciones»** (`AccionesDelPlano`) es la misma pieza en la oficina y en el teléfono.

### E1.5 Lo que cambió respecto de la propuesta (también en `DESIGN.md` 14.10)

1. Sin «⌄ más» en la franja de cifras: la franja no lleva controles (el aviso la tapa). Las
   fichas envuelven, con tope.
2. La franja de cifras mide al menos 64 dp, no 56: el aviso compacto más su aire de abajo.
3. El borde del panel guardado va fuera de la columna, para no tapar su barra de desplazamiento.
4. **Oficina o teléfono lo decide la página.** Lo encontró la suite: a 600 dp la página va en
   oficina, pero el plano mide 489 dp y se armaba como teléfono, con un segundo selector.
5. De 600 a 1199 dp el detalle va al panel flotante, no a la hoja de abajo.
6. Sin escala, la franja de cifras dice el viaje («14 contenedores, …»).
7. «Colorear por» usa el mismo selector, sin iconos, con Estado solo en Descarga.
8. El cambio de altura del puente no se anima (4.5).
9. El selector de la cabecera solo va con el Plano a la vista.
10. En el teléfono, «Acciones» va solo con su icono en la línea de los controles: el menú del
    modo con su icono es más ancho que el desplegable de antes y la línea de 360 dp se
    desbordaba 44 dp (la suite lo vio en once archivos).
11. Las variantes de una línea no llevan `Wrap`: su ancho intrínseco no suma el `spacing`, y la
    cabecera se desbordaba 7.4 dp a 1366 × 690 (lo vio la matriz).
12. **La franja de la bahía se fija solo si cabe, y la de cifras tiene tope.** Lo vieron las
    medidas de E1.6: con la letra a 2.0, a 800 × 600 la franja fijada medía 224 dp y a la
    columna le quedaban 217: la rejilla no llegaba a verse nunca.
13. Los avisos se acotan a lo ancho con el ancho de la columna, no con su posición: durante
    una transición de página (que escala la vista) la posición sale negativa y el aire del
    aviso también (lo vio `profile_loading_page_test`).
14. **Las cifras de la bahía bajan a la franja de cifras (10.40, la tarde).** La ficha de la
    bahía empieza por ellas y sigue, tras un punto y coma, con lo que la operación dice de la
    bahía: «Bahía 02: 20 contenedores, 244.7 t, tapas sin declarar; 2 por bajar en cub., 8 en
    bod., 0 bajados». Sin escala, o mientras se lee la operación, van en una ficha propia
    (`cifras-de-la-bahia`). Si aun así la franja de la bahía no cabe en una línea, «OR / últimos
    dígitos» queda solo con su icono y el rótulo en la descripción emergente. En la tableta del
    muelle operando, que no tiene franja de cifras, siguen junto al título. `DESIGN.md` 14.7,
    14.8 y 14.10 (punto 13).

### E1.6 Validaciones y cifras

**Suite y analizador.** Piso 1371 → **1629 aprobadas, 0 fallidas, 0 omitidas, en una corrida**
(2:15 min, la tarde, después del ajuste de 10.40; la mañana dio 1627). `flutter analyze
--no-pub`: **No issues found**, sin `// ignore:`, también después de tocar los instrumentos. Las
258 nuevas:

| Archivo | Pruebas | Qué |
|---|---:|---|
| `test/t117_preferencias_test.dart` | 13 | El almacén y el repositorio (sin valor, guardar y leer, null borra, sobrevive al reabrir, la clave `ui.<nombre>`, almacén cerrado → fallo) y la presentación (omisión, lectura, valor raro, fallo de lectura, almacén de antes, guardar, fallo al guardar, última altura abierta) |
| `test/t117_oficina_test.dart` | 229 | La matriz de 0.5.5 (189), la franja de la bahía en una línea (2, 10.40), el puente (7), el panel (7), los avisos en la oficina (22) y Parámetros (2) |
| `test/t118_selector_test.dart` | 16 | El selector en sus dos formas y la accesibilidad en los dos temas (`meetsGuideline`: objetivo táctil, etiqueta y contraste), `BsPrimeraQueCabe`, la tarjeta corta, la ficha, la cabecera a 1920, 800 y 640 dp, el resumen y «Colorear por» |

**La matriz de 0.5.5** (`t117_oficina_test.dart`, con las fuentes del producto): 1920 × 1000,
1707 × 996, 1536 × 793, 1366 × 690, 1280 × 720, 960 × 1000 y 800 × 600; letra 1.0, 1.45 y 2.0;
panel fijo, flotante y oculto; Contenido, Descarga y Carga. En cada caso: sin desbordes al
abrir ni al desplazar; la cabecera dentro de la columna con Buscar y el botón del panel
tocables; la franja de cifras abajo, de 64 dp o más; las tarjetas enteras; el panel como se
pidió (el flotante no tapa la franja de cifras y deja 48 dp a la columna); ningún texto
cortado en la cabecera, las franjas ni la leyenda; **una celda de la rejilla tocable en el
centro de la columna**; la leyenda entera al final; y la franja de la bahía fijada cuando cabe.
El buque de prueba tiene una bahía de seis y seis niveles, como las llenas del corpus.

**La franja de la bahía en una línea (10.40), en la matriz.** Con el panel fijo y la letra a
1.0, a 1536 × 793 y a 1366 × 690, en Contenido, Descarga y Carga (seis casos de la matriz),
`_franjaEnUnaLinea` exige: la bahía y el botón del panel a la misma altura, la franja de 56 dp
o menos, «Colorear por» a la vista y tocable, sin cifras en la franja de la bahía y la primera
ficha de la franja de cifras empezando por «Bahía 02: 12 contenedores, 202.0 t». Dos pruebas
más: a 1366 × 690 con la letra a 1.45, en Carga, «OR / últimos dígitos» queda como botón de
icono con su descripción emergente y en la misma línea; y sin escala, la franja de cifras
empieza por la bahía (`cifras-de-la-bahia`) y sigue con el viaje. Medido con las fuentes
reales en los cuatro modos (prueba de exploración): con la letra a 1.0 la franja mide 56 dp de
960 a 1920 dp; a 1536 caben los segmentos de «Colorear por»; a 1366, en Carga, va el menú; el
OR solo con su icono entra a 1366 con la letra a 1.45. Con 1.45 a 1280 y con 2.0 puede ir en
dos líneas (de 62 a 126 dp), como permite 10.40.

**Los avisos** (14.5): a los siete tamaños y las tres letras, en Descarga, un aviso de 6 s con
«Deshacer» queda dentro de la franja de cifras (su borde de arriba no pasa del de la franja) y
de la columna (no cruza el riel ni el panel), por debajo de la columna que se desplaza, y
«Deshacer» responde; fuera del Plano va al pie, a lo ancho de la columna. **La matriz de 18
casos del teléfono** (10.31 a 10.33, `t114_candidata_correccion2_test.dart` y
`t114_candidata_correccion3_test.dart`) y **la guarda de `SnackBar(` en todo `lib/`** siguen
en la suite y pasan.

**Medidas con las fuentes reales** (prueba de exploración, Carga, el panel fijo desde 1200 dp,
dp lógicos; el panel del buque incluye su borde de 12; «alto para la rejilla» es el alto de la
columna que se desplaza menos el panel del buque y la franja de la bahía, sin desplazar). Cada
celda dice **la mañana → la tarde** (después del ajuste de 10.40) cuando cambió:

| Ventana | Letra | Cabecera | Panel del buque (completo / compacto) | Franja de la bahía | Franja de cifras | Alto para la rejilla (completo / plegado) | Fase 0, «hoy» |
|---|---:|---:|---:|---:|---:|---:|---:|
| 1920 × 1000 | 1.0 | 64 | 185 / 110 | 56 | 64 | 631 / 816 | 521 |
| 1707 × 996 | 1.0 | 64 | 185 / 110 | 56 | 64 | 627 / 812 | 415 |
| 1536 × 793 | 1.0 | 64 | 185 / 110 | 108 → **56** | 64 | 372 / 557 → **424 / 609** | 212 |
| 1366 × 690 | 1.0 | 64 | 185 / 110 | 108 → **56** | 64 | 269 / 454 → **321 / 506** | 211 |
| 1280 × 720 | 1.0 | 64 | 185 / 110 | 108 → **56** | 64 | 299 / 484 → **351 / 536** | — |
| 960 × 1000 | 1.0 | 64 | 185 / 110 | 108 → **56** | 64 | 579 / 764 → **631 / 816** | — |
| 800 × 600 | 1.0 | 64 | 185 / 110 | 108 | 64 → 88 | 179 / 364 → 155 / 340 | — |
| 1920 × 1000 | 2.0 | 92 | 198 / 123 | 126 → 74 | 105 → 151 | 479 / 677 → 485 / 683 | — |
| 1366 × 690 | 2.0 | 92 | 198 / 123 | 178 (se va) → 126 (fijada) | 173 (tope) | 49 / 248 → 101 / 300 | — |
| 800 × 600 | 2.0 | 144 | 198 / 123 | 224 → 178 (se va) | 150 (tope) | la columna entera, 306, al desplazar | — |

- El panel del buque mide lo que dice 14.2: 173 completo y 98 compacto, más los 12 del borde.
- **Con la letra a 1.0 la franja de la bahía va en una línea de 960 a 1920 dp** y el alto para
  la rejilla gana 52 dp a 1536, 1366, 1280 y 960. A 1536 y a 1366 queda aún por debajo de lo que
  estimó la fase 0 (445 y 342): la fase 0 no contaba el borde del puente ni el aire de la franja.
  Con el panel oculto la columna gana 361 dp.
- **Lo que se paga:** la ficha de la bahía es más larga, y donde la franja de cifras ya era
  estrecha envuelve una línea más: a 800 × 600 con 1.0 pasa de 64 a 88 dp y la rejilla pierde
  24; a 1920 con 2.0, de 105 a 151 (la rejilla igual gana 6, porque la franja de la bahía baja
  52). Con la letra grande la franja de cifras sigue con su tope de un cuarto de la ventana.
- Las tarjetas cortas no salen en esta tabla: el buque de prueba no carga nada en GTSTC y en
  Carga no hay tarjetas. En Descarga sí, y la matriz las comprueba enteras.

**RNF-002 en Windows** (los instrumentos de T-98 y T-99, 10.26 y 10.27: `tool/t114_primera_windows.py`
sobre el banco r4 de `%TEMP%\t99-r4-e1`, compilado desde el árbol con el ajuste, almacén en
`%TEMP%`, el sintético de 977 (SHA-256 `9fb42622…`), sin perfil, tema del sistema oscuro, la
laptop a 1920 × 1080 al 125 %, el banco maximizado: la oficina a 1536 × 793). Con `SEMÁFORO:` al
empezar (15:50, el intento que no cuenta) y al terminar (15:55); las cinco corrieron de 15:54 a
15:55:

| Repetición | Ventana (s) | Clic (s) | Selector confirmado (s) | Rejilla quieta (s) | Reintentos | Al frente | ≤ 30 s |
|---:|---:|---:|---:|---:|---:|---|---|
| 1 | 0.458 | 1.087 | 2.274 | 2.679 | 0 | sí | sí |
| 2 | 0.458 | 0.897 | 1.872 | 2.166 | 0 | sí | sí |
| 3 | 0.478 | 1.090 | 2.008 | 2.350 | 0 | sí | sí |
| 4 | 0.478 | 0.898 | 1.911 | 2.261 | 0 | sí | sí |
| 5 | 0.456 | 0.881 | 1.906 | 2.204 | 0 | sí | sí |

- **Tres pasos del producto en las cinco** (abrir, «Seleccionar archivo», elegir el archivo),
  las cinco válidas; mediana **2.26 s**, incertidumbre 0.05 s. El botón que vio el detector, el
  de siempre: 704 × 59 px, relleno 0.97, rótulo 0.26.
- **Contra la última medida (8.3 de `REDISENO-RESULTADOS.md`, mediana 1.87 s):** lo que pone el
  producto, del selector confirmado a la rejilla quieta, pasa de 0.25 s a entre 0.29 y 0.41 s
  (la oficina arma más piezas: el puente, la franja y las variantes que se miden); el resto de
  la diferencia está entre el clic y el selector confirmado (de 0.78 a 0.92–1.19 s), que es el
  diálogo de Windows. Lejos de los 30 s en todo caso.
- **Un intento que no cuenta** (`rnf-002/windows-intento-foco/registro.json`): la primera
  corrida falló con «Más de 120 s sin rejilla». La ventana del banco abrió a los 1.3 s,
  maximizada, pero detrás de la consola de Claude: Windows niega `SetForegroundWindow` a un
  proceso que no recibió la última entrada mientras otra ventana tiene el foco, y el detector,
  que mira la pantalla, vio la consola los 120 s. Minimizar la consola no bastaba (PowerPoint
  de Carlos estaba abierto detrás). **El instrumento se corrigió:** `al_frente` manda una
  pulsación sin tecla (código 0), que ninguna app atiende y que cuenta como la última entrada,
  antes de traer el banco al frente, y el registro dice si quedó al frente (`alFrente`). Su
  imagen final no se guarda en la evidencia: muestra la consola, con los proyectos de Carlos.
- Evidencia: `docs/t117/entrega1/rnf-002/windows/` (`resumen.json` y, por repetición,
  `registro.json`, `inicio.png`, `rejilla.png` y `final.png`). La rejilla de la primera
  repetición muestra la oficina nueva con el plano en previo: la franja de la bahía en una línea
  y la de cifras con «Bahía 01: 2 contenedores, 23.2 t, tapas sin declarar» y «Viaje: …».

**Las capturas** (datos sintéticos: `T100_LLEGADA` publicado en GTSTC y `T100_CARGA`; nunca el
corpus ni «Nube y cuenta»):

| Cliente | Instrumento | Tamaños, temas y letras | Pantallas | PNG |
|---|---|---|---|---:|
| Windows | `tool/t114_capturas_windows.ps1 -Escenario plano -EscalaAnterior GTSTC -PorExplorer` (el conductor de T-99, reducción de movimiento) | 1920 × 1080 y 1366 × 768; claro y oscuro; letra 1.0 y 2.0 | el plano en Contenido, Descarga y Carga; el panel del buque compacto y plegado; el panel lateral oculto y flotante; la Lista y el Avance | 72 |
| Web | `tool/t117_capturas_web.py` (Playwright, Chrome visible, perfil temporal) | 1920 × 1080 y 1366 × 768; claro y oscuro | el plano en Contenido, Descarga y Carga (elegidos en la cabecera, en segmentos o en menú); el panel del buque plegado; el panel lateral oculto y flotante (el mouse en el borde) | 24 |

- **Windows:** el conductor anota por captura los textos que no caben, los desplazables
  horizontales y los errores de Flutter (`pasos.jsonl`): **ningún texto cortado y ningún error
  en las 72**, ninguna espera vencida. Los desplazables horizontales son los de diseño: la silueta
  del buque (198 dp a 1366 con 1.0; 159 a 1920 con 2.0) y la rejilla de la bahía a 1366 con 2.0
  (77 dp); y la tabla del Avance a 1920 con 2.0 (855 dp), que ya se desplazaba en la entrega 2
  (`docs/rediseno/fase3/entrega2/despues-windows/`) y que T-117 no toca.
- **El conductor de T-99 se amplió** para estas capturas (`_capturasDeLaOficina`, desde 1200 dp):
  la Carga, el puente compacto y plegado, el panel oculto y el flotante (un toque en su borde);
  deja la oficina como la encontró. Por eso el escenario `plano` da ahora 9 pantallas por tamaño
  de oficina en vez de 4.
- Evidencia: `docs/t117/entrega1/capturas/windows/` (72 PNG, `pasos.jsonl`, `anchos.jsonl`) y
  `docs/t117/entrega1/capturas/web/` (24 PNG).

**La ventana real** (el banco por `explorer.exe`, el viaje sintético abierto desde Recientes,
`docs/t117/entrega1/ventana-real/` con su `registro.tsv`):

| Paso | Cliente (px → dp al 125 %) | Lo que se ve |
|---|---|---|
| Maximizar (doble clic en la barra de título) | 1920 × 991 → 1536 × 793 | La oficina con el panel fijo; la franja de la bahía en una línea |
| Win + ← | 958 × 981 → 766 × 785 | Oficina sin panel fijo: el selector en menú, el botón del panel en la cabecera |
| Win + → (desde la mitad izquierda vuelve al tamaño normal) | 1582 × 853 → 1266 × 682 | Con panel fijo otra vez |
| Win + → otra vez | 958 × 981 → 766 × 785 | La mitad derecha, igual que la izquierda |
| El borde derecho, arrastrado | 1250 → 1000 dp | Una línea, «Colorear por» en segmentos |
| | 875 → 700 dp | La franja envuelve: el botón del panel baja a una segunda línea; nada se corta |
| | 700 → 560 dp | Pasa al teléfono: la barra de navegación abajo, el modo en menú y la leyenda que se desplaza a lo ancho |
| | 1600 → 1280 dp | Vuelve el panel fijo, la franja en una línea |

- **No hay un segundo monitor:** la laptop tiene una sola pantalla (`\\.\DISPLAY1`, 1920 × 1080
  al 125 %, área útil 1536 × 816), así que no se probó arrastrar de un monitor a otro.
- Maximizar y Win + ← y → se hicieron con el control del escritorio. El borde se arrastró
  desde la consola con el mouse real (`mouse_event`, botón abajo, 20 movimientos de 40 ms,
  botón arriba), porque el control del escritorio pide en cada vuelta una tarjeta de permiso que
  se quedó 33 minutos esperando sin que nadie la viera. Cada captura es de la ventana sola
  (`PrintWindow`, `tool/t100_windows.ps1`). Los cuatro arrastres llegaron al ancho pedido.

### E1.7 Las pruebas que cambian, una por una

La primera suite dio 78 fallidas en 20 archivos. Cuatro causas eran del producto y se
corrigieron en el código, no en las pruebas: el desborde de 44 dp del teléfono (E1.5, punto 10,
que explicaba 27 de las 78), el doble selector a 600 dp (punto 4), el aire negativo de los
avisos (punto 13) y el título repetido en el estado «sin geometría» de la oficina. Las demás
afirmaban el contrato de antes y se reescribieron sin bajar el conteo (ninguna se borró ni se
omitió):

| Archivo | Prueba | Qué cambió y por qué |
|---|---|---|
| `test/support/t91_toolbar_support.dart` | `checkT91Toggle` (las 2 de `t91_plan_toolbar_test`) | Lee el modo de `BsSelectorDeModo.elegido`, no del `value` del `DropdownButton` |
| `test/t105_drag_widget_test.dart` | el ayudante `mode` (lo usan T-105 y T-106) | En la oficina el selector va en la cabecera de la página, que estas pruebas no montan: el modo se elige en el mismo provider que usa la cabecera; en el teléfono, con el selector |
| `test/t106_plan_widget_test.dart` | «a 300 % con 1600 px» y «con 1920 px la rejilla abre a la vista» | El título de la bahía está en la franja de la bahía, encima de la rejilla |
| `test/t106_plan_widget_test.dart` | «el margen de 16 dp no se escala con el zoom» | El margen es un `Padding`, no el de un desplazable vertical propio; las medidas del margen no cambian |
| `test/t107_header_test.dart` | el ayudante `_mode`; «a 1280 dp, Carga» y «a 1280 dp, Descarga» (antes «el encabezado … es el de antes») | En la oficina los controles van en la franja de la bahía y «Acciones», y el resumen en la franja de cifras |
| `test/t107_texts_test.dart` | «Descarga a 360×780 dp con letra 1.0» y «… 1.45» | La escala se lee de la ficha (`BsFichaDeCifra.texto`); sigue terminando en «0 re‑estibas» |
| `test/t114_candidata_correccion2_test.dart` | «en la oficina, 1920 × 1080 …» | El aviso vive en la franja de cifras (14.5), no sobre la leyenda |
| `test/t114_fase3_entrega2_correccion_test.dart` | «H1 · … a 600 dp exactos» (letra 1.0, 1.45 y 2.0) | El selector de modo en lugar de `operar-segmentos` |
| `test/t114_fase3_plano_test.dart` | «la silueta elige la bahía y la rejilla la titula» | El título se busca como texto simple: las fichas también empiezan por «Bahía 02» |
| `test/t114_fase3_plano_test.dart` | «el detalle va al panel con sitio y al panel flotante sin él» (antes «… y a una hoja sin él») | A 800 dp el detalle va al panel flotante (14.3) |
| `test/t114_paquete_test.dart` | «el censo de lib/» | `orden` pasa a tener sitio (el modo Número de orden, 13.11) |
| `test/t74_loading_plan_test.dart` | «plano a 360 dp, OR y tabla» (con y sin listado) | «Importar listado» está en «Acciones», no en el resumen |
| `test/t75_discharge_test.dart` | «Descarga a 360 dp» (claro y oscuro) | El resumen se lee de las fichas, con sus frases nuevas |
| `test/t78_operation_progress_widget_test.dart` | «flujo, actualización y enlace» (las 4) | «Avance de la operación» está en «Acciones» en todos los anchos |
| `test/t81_office_widget_test.dart` | «Número de orden redibuja plan efectivo y cancelados» | El modo se elige en el provider (como `mode`) |
| `test/current_profile_parameters_test.dart` | «Recientes dice qué parámetro del perfil no se aplicó» | En la oficina el aviso tiene tope: sale el texto corto y «Ver» abre el entero (10.32) |
| `test/vessel_profile_view_test.dart` | «selecciona la bahía y abre su rejilla en Bay Plan» | El título se busca como texto simple |

### E1.8 Archivos

**`domain/` y `data/` — la excepción de 0.5.7 (10.38), 31 líneas, solo para las preferencias:**
- `lib/features/vessel/domain/repositories/local_vessel_repository.dart`: `enum UiPreference`
  y `getUiPreference` / `setUiPreference`.
- `lib/features/vessel/data/datasources/hive_vessel_data_source.dart`: la clave `ui.<nombre>`
  en la caja de ajustes, por la cola de escrituras.
- `lib/features/vessel/data/repositories/local_vessel_repository_impl.dart`: dos `_guard`.
- Sin migración. Los dobles de prueba con `noSuchMethod` compilan igual.

**Nuevos (11):** `lib/core/design/componentes/bs_ficha_de_cifra.dart`,
`bs_primera_que_cabe.dart`, `bs_selector_de_modo.dart`;
`lib/features/vessel/presentation/providers/oficina_providers.dart`;
`lib/features/vessel/presentation/widgets/franjas_del_plano.dart`, `puente_del_plano.dart`,
`resumen_del_modo.dart`; `test/support/t117_oficina_support.dart`, `test/t117_oficina_test.dart`,
`test/t117_preferencias_test.dart`, `test/t118_selector_test.dart`.

**Cambiados (32):** `DESIGN.md`; en `lib/core/design/`: `design.dart`, `vistas_previas.dart`,
`componentes/bs_tarjeta_cifra.dart`; los tres de `domain/` y `data/` de arriba; en la
presentación: `pages/parameters_page.dart`, `pages/vessel_overview_page.dart`,
`widgets/avisos_del_viaje.dart`, `widgets/bay_plan_view.dart`, `widgets/cifras_del_viaje.dart`,
`widgets/discharge_controls.dart`, `widgets/loading_controls.dart`,
`widgets/loading_plan_controls.dart`, `widgets/navegacion_del_viaje.dart`,
`widgets/plan_drag_confirmation.dart`; y las 15 pruebas de E1.7.

**No cambian:** `pubspec.yaml`, `pubspec.lock`, `lib/main.dart`, los congelados, Firebase, la
lista del piloto. Ninguna dependencia nueva. Los cuatro archivos que solo difieren en el fin de
línea (`test/t114_fase3_correccion_test.dart` y tres de `windows/flutter/`) no van en el bloque.

**La tarde (10.40), desde `096b8dc`** — solo presentación, pruebas, instrumentos y documentos;
`domain/` y `data/` no se tocaron:
- **Cambiados (9):** `DESIGN.md` (14.7, 14.8, 14.10 punto 13); en
  `lib/features/vessel/presentation/widgets/`: `bay_plan_view.dart` (las cifras van a la franja
  de cifras; en el muelle operando, a la de la bahía), `franjas_del_plano.dart` (la tercera
  variante, con el OR solo con su icono; `cifras` solo para el muelle), `loading_controls.dart`
  (`busquedaDeCarga(soloIcono:)`), `loading_plan_controls.dart` (`orSoloIcono`),
  `resumen_del_modo.dart` (`cifrasDeLaBahia`); `test/t117_oficina_test.dart` (la comprobación de
  la matriz y dos pruebas); `tool/t114_primera_windows.py` (`al_frente`, `alFrente`);
  `tool/t99_conductor.dart` (`_capturasDeLaOficina`).
- **Nuevos:** `tool/t117_capturas_web.py`; este informe cambia; y la evidencia en
  `docs/t117/entrega1/` (129 archivos, 12.6 MB: `rnf-002/` 22, `capturas/windows/` 74,
  `capturas/web/` 24, `ventana-real/` 9), ninguno ignorado.

### E1.9 Lo que no se pudo y por qué

- **RNF-002, las capturas y la ventana real,** que en la mañana esperaban la luz verde, quedaron
  hechos en la tarde (E1.6).
- **El segundo monitor:** no hay; la laptop tiene una sola pantalla. Arrastrar la ventana de un
  monitor a otro queda sin probar.
- **RNF-002 en la Web y en Android** no se pidieron ni se midieron: T-117 y T-118 cambian la
  oficina, y en el teléfono solo el menú del modo, «Acciones» y las fichas.
- No se usó el emulador: lo del teléfono que cambia está en las pruebas de widgets a 360 dp; la
  matriz de 18 casos de los avisos sigue en la suite.
- Las capturas de Windows con la letra a 1.45 no se tomaron (1.0 y 2.0, los extremos); la matriz
  de pruebas sí cubre 1.45.

### E1.10 Lo que cambia en la lista del piloto (`docs/piloto/LISTA-PILOTO.md`, de Yov)

- **1.3:** en la cabecera ya no hay un segmento «Carga»: está el selector de modo (segmentos con
  Contenido, Orden y Carga, o un botón con el modo y ⌄ si no caben).
- **1.5:** «Contenido → Carga» se elige en ese selector de la cabecera.
- **1.8:** la cabecera ofrece «Descarga» y «Carga» en el mismo selector.
- **1.10:** desde 1200 dp el panel con «En vivo» está fijo, salvo que se oculte con su botón de
  la cabecera; con menos ancho o oculto, sale flotante por el borde derecho, por el botón o al
  tocar una celda. Ya no es «con menos ancho no hay panel».
- **1.11:** «Acciones» (⋮) está en la franja de la bahía, encima de la rejilla.
- **2.x (el teléfono):** el resumen sobre la barra dice la bahía en una ficha; el menú del modo
  ofrece Contenido, Número de orden y el modo vigente; «Acciones» va solo con su icono. Los
  pasos de la lista no cambian.
- **5:** la observación O3 (el aviso de la oficina cruza el riel y «En vivo») queda cerrada con
  esta entrega; se puede quitar o anotar como corregida en la 3.2.0.
- **Desde la tarde (10.40):** donde la lista mire las cifras de la bahía («N contenedores, X t»)
  junto a su título en la oficina, ahora están al pie, al principio de la franja de cifras
  («Bahía 02: 20 contenedores, 244.7 t, …; …»). Con una ventana estrecha, «OR / últimos
  dígitos» puede ser solo la lupa, con su nombre al pasar el mouse.
- Nada de esto afecta al piloto del 25 y el 26, que es con la 3.1.0.

### E1.11 Horas

Unas **1.6 h** en la mañana (11:07 a 12:45): `DESIGN.md` 0.3 h; el código 0.6 h; las pruebas
nuevas 0.2 h; las corridas, los arreglos y las pruebas reescritas 0.4 h; el informe 0.1 h.

Unas **2 h** en la tarde (≈ 14:55 a 16:55): el ajuste de la franja con sus medidas, pruebas,
`DESIGN.md`, `analyze` y la suite 0.5 h; el banco r4 (la descarga del SDK de Firebase en la copia
nueva tomó 14 min) y RNF-002 con el arreglo del instrumento 0.5 h; las capturas de Windows y la
Web 0.3 h; la ventana real 0.2 h, más ≈ 0.5 h detenida en una tarjeta de permiso del control
del escritorio; el informe 0.2 h. La fase 0 estimó 22 a 27 h para T-117 y T-118; falta la
aceptación.

### E1.12 Git

El bloque de la mañana es `096b8dc` (44 rutas), ya subido. **Para Carlos, solo lo nuevo o
cambiado desde ese commit** (no incluye los cuatro archivos de fin de línea ni
`.claude/settings.local.json`):

```powershell
git add -- DESIGN.md
git add -- docs/T117-T121-RESULTADOS.md
git add -- lib/features/vessel/presentation/widgets/bay_plan_view.dart
git add -- lib/features/vessel/presentation/widgets/franjas_del_plano.dart
git add -- lib/features/vessel/presentation/widgets/loading_controls.dart
git add -- lib/features/vessel/presentation/widgets/loading_plan_controls.dart
git add -- lib/features/vessel/presentation/widgets/resumen_del_modo.dart
git add -- test/t117_oficina_test.dart
git add -- tool/t114_primera_windows.py
git add -- tool/t99_conductor.dart
git add -- tool/t117_capturas_web.py
```

**La evidencia, aparte y solo si la autorizas:** está bajo `docs/`, que `AGENTS.md` reserva salvo
autorización directa; es como la de T-114 en `docs/rediseno/fase3/` (129 archivos, 12.6 MB, ninguno
ignorado; las imágenes no muestran nada fuera del banco):

```powershell
git add -- docs/t117/entrega1
```

```powershell
git commit -m "Sprint 4: T-117 y T-118, entrega 1, la franja de la bahia en una linea con las cifras al pie, RNF-002 en Windows, capturas y la ventana real" --trailer "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
git push
git show --stat --format="%h %s" HEAD | Select-Object -Last 1
```

El último comando tiene que decir **11 files changed** sin la evidencia, o **140 files changed**
con ella. No cambian `pubspec.yaml` ni `pubspec.lock`, ni `domain/`, `data/`, `lib/main.dart`, los
congelados o `docs/piloto/LISTA-PILOTO.md`.

### E1.13 Mensaje para Yov

> Yov: la tarde de la entrega 1 de T-117 y T-118 (10.40) está en `docs/T117-T121-RESULTADOS.md`,
> sección «Entrega 1» (E1.2, E1.5 punto 14, E1.6, E1.8 a E1.12), y en `DESIGN.md` 14.7, 14.8 y
> 14.10. **El ajuste:** las cifras de la bahía bajaron a la franja de cifras, que empieza por
> ellas; con el panel fijo y la letra a 1.0 la franja de la bahía va en una línea (56 dp) de
> 960 a 1920 dp, también a 1536 × 793 y a 1366 × 690, y la rejilla gana 52 dp ahí. Si aun así no
> cabe, el OR queda solo con su icono (entra a 1366 con 1.45). La matriz de 0.5.5 lo comprueba
> en seis casos y hay dos pruebas más: **suite 1629, `analyze` en cero.** Lo que se paga: a
> 800 × 600 con 1.0 la franja de cifras envuelve (88 dp) y la rejilla pierde 24. **RNF-002 en
> Windows** con `t114_primera_windows.py` sobre el banco r4: 5 de 5, tres pasos, mediana 2.26 s
> (antes 1.87; 0.05 a 0.15 s son de la oficina, el resto del diálogo de Windows). El primer
> intento no contó: el banco nació detrás de la consola por el bloqueo de primer plano de
> Windows; corregí el instrumento (`al_frente`) y lo anoté. **Capturas:** 72 de Windows (con el
> conductor de T-99 ampliado a los estados de la oficina) sin textos cortados ni errores, y 24
> de la Web con `tool/t117_capturas_web.py`. **La ventana real:** maximizar, Win + ← y →, y el
> borde a 1000, 700, 560 y 1280 dp; nada se corta; no hay segundo monitor. El bloque de git
> tiene 11 rutas; la evidencia (`docs/t117/entrega1/`, 129 archivos) va aparte, a criterio de
> Carlos. La lista del piloto suma una nota (E1.10); no la toqué.

**ALTO: Codex acepta.**

## Corrección 1 de la entrega 1 (25-oct-2026)

Timonel (Claude Code, Claude Opus 5.5), rama `sprint-4`, carpeta del rediseño, sobre `80ae18b`
(decisión 10.42). Codex no aceptó la entrega 1 (`docs/t117/entrega1/aceptacion-codex.md`) por
dos P2 y un P3: H1, «Cerrar el panel lateral» fijaba el panel y guardaba `visible`; H2, Atrás no
cerraba el menú del modo en Android (y Esc tampoco, en la matriz); H3, a 700 dp el botón del
puente quedaba solo en una segunda línea de la franja de la bahía.

### C1.1 Resultado en tres líneas

- **H1:** con el flotante abierto, el botón de la cabecera solo cierra el flotante: el panel sigue
  oculto y la preferencia no cambia. **H2:** al abrirse, el menú del modo lleva el foco a la entrada
  elegida, y Esc lo cierra; además se anota en `cerrablesDeAtrasProvider`, así que el primer Atrás
  de Android lo cierra y no cuenta como el primero del doble Atrás. Comprobado en el emulador, en
  claro y en oscuro. **H3:** a 700 dp la franja va en una línea (56 dp), y cuando envuelve, el
  botón queda al final de la primera.
- Al medir aparecieron **dos desbordes**, y los corregí. Uno era viejo y la matriz de 0.5.5 no lo
  veía: con la letra a 2.0, en Carga, a 600 y 700 dp, los controles con rótulos se desbordaban (135
  y 35 dp). El otro lo traía la variante nueva: a 960 dp con 2.0 en Descarga entraba aunque medía
  0.08 dp más, porque `BsPrimeraQueCabe` daba medio dp de gracia.
- **Suite 1677 (piso 1629, más 48)**, sin fallidas ni omitidas, en una corrida, y `analyze` en
  cero. Las pruebas nuevas, corridas contra `80ae18b`: 38 fallan antes del arreglo y pasan todas
  después.

### C1.2 Lo que se corrió

- Leí la decisión 10.42, el informe de Codex con H1 a H3, y sus pruebas
  (`cerrar_panel_test.dart` y `matriz_codex_test.dart` de `baystream-qa-r4`, solo como receta: la
  carpeta es de Codex y no la toqué).
- **Sin Flutter,** escribí el código, las pruebas, `DESIGN.md` y el instrumento del emulador.
  Después, **con la luz verde de Carlos («Corre flutter»)**, corrí uno a la vez:
  - `analyze` (tres veces, siempre en cero);
  - las pruebas nuevas;
  - una prueba de exploración de la franja en ventanas angostas, que encontró los dos desbordes
    (C1.3, punto 5);
  - las pruebas nuevas contra `80ae18b`, en una copia de `%TEMP%`;
  - **dos suites completas,** porque el código cambió entre las dos (C1.3, punto 6). Las dos
    dieron 1677; la que vale es la segunda, con el código final;
  - el APK r4, dos veces, y H2 en el emulador.
- No se usó el Honor; el emulador solo con `-s emulator-5554`. Datos sintéticos de T-100, nunca el
  corpus ni «Nube y cuenta». No se tocaron las apps instaladas, «PRUEBA T-105» ni
  `C:\Proyectos\baystream-demo17\`. Nada se publicó.

### C1.3 Qué cambió y por qué

1. **H1 · el botón de la cabecera** (`vessel_overview_page.dart`). Desde 1200 dp el botón siempre
   hacía `mostrarPanel(!panelFijo)`, aunque con el flotante abierto dijera «Cerrar el panel
   lateral». Ahora, con el panel oculto y el flotante abierto, en cualquier ancho, solo cierra el
   flotante (y la celda que lo abrió, como «Cerrar»). Sin flotante sigue ocultando o mostrando el
   panel fijo. Para fijarlo desde el flotante está «Fijar». `DESIGN.md` 14.3.
2. **H2 · Esc** (`bs_selector_de_modo.dart`). `MenuAnchor` atiende Esc con los atajos de su panel,
   y esos atajos solo actúan con el foco dentro del panel. Al abrirse con el mouse o el dedo, el
   foco no entraba, así que Esc no llegaba. Ahora, al abrirse, el foco pasa a la entrada elegida (o
   a la primera), como en un menú del sistema. `DESIGN.md` 14.6.
3. **H2 · Atrás.** El menú no es una ruta y no se anotaba en `cerrablesDeAtrasProvider`. El
   componente no sabe nada del viaje: da a quien lo usa lo que lo cierra (`alAbrirElMenu` y
   `alCerrarElMenu`, con lo mismo que se dio al abrir; también al desmontarse abierto). Del lado del
   viaje, `SelectorDelModo` (`loading_plan_controls.dart`) y «Colorear por» (`bay_plan_view.dart`,
   el mismo menú) lo anotan. El registro se toma al construir, porque al desmontarse ya no se puede
   usar `ref`. `DESIGN.md` 8 y 14.6.
4. **H3 · el botón del puente** (`franjas_del_plano.dart`). Hay una cuarta variante de una línea
   con «Acciones» solo con su icono (⋮, como en el teléfono). En la que envuelve, el botón va fuera
   del `Wrap`, arriba a la derecha, al final de la primera línea. `DESIGN.md` 14.8.
5. **Lo que encontró la medida** (C1.5). En la variante que envuelve, «Colorear por» puede
   partirse de su menú, y los controles van con sus rótulos solo si caben en una línea entera (un
   `BsPrimeraQueCabe` dentro); si no, el OR y después «Acciones» quedan con su icono. Y
   `BsPrimeraQueCabe` acepta una variante con la tolerancia con que `RenderFlex` avisa de un
   desborde (`precisionErrorTolerance`), no con medio dp. `DESIGN.md` 14.8 y 14.11.
6. **El foco al cerrar, quitado tras el emulador.** La primera versión de H2 devolvía el foco al
   botón al cerrarse el menú. En el emulador, tras el Atrás, el botón quedaba con el sombreado del
   foco: Android pinta el foco después de una tecla (`android-intento-2-boton-sombreado/`). Ya no
   se devuelve a la fuerza; abierto con el teclado, el foco vuelve solo. La prueba del selector
   suelto comprueba ahora que el foco sale con el menú.

### C1.4 Las pruebas nuevas

| Archivo | Pruebas | Qué |
|---|---:|---|
| `test/t117_correccion1_test.dart` · H1 | 4 | Con la preferencia guardada (`oculto`), el flotante abierto por una celda y por el borde: «Cerrar el panel lateral» lo cierra, el panel no se fija, la preferencia sigue en `oculto`, la celda se limpia. Sin flotante, el botón oculta y muestra el fijo (`visible`). «Fijar» lo fija |
| ídem · H2 | 4 | Esc cierra el menú de la cabecera a 800 × 600. **Los dos casos de Codex** (800 × 600, letra 2.0, Descarga, panel fijo y oculto): con Esc el menú se cierra y «Deshacer» del aviso responde. El selector suelto da lo que lo cierra y lo recibe de vuelta al cerrarse (por eso, como Atrás, y por Esc), y el foco entra y sale con el menú |
| ídem · H3 | 39 | A 700 × 682 en Contenido, la franja de 56 dp o menos con el botón a la altura del título. Con 1.45 y 2.0, el botón en la primera línea. Y la **matriz angosta**: 600, 700, 800 y 960 dp × letra 1.0, 1.45 y 2.0 × los tres modos (36), sin desbordes ni textos cortados, con el botón en la primera línea |
| `test/t114_candidata_atras_test.dart` | 1 | Con el viaje publicado en Android (360 dp), el menú del modo se anota al abrirse; el primer Atrás lo cierra, el plano se queda, sin la advertencia; el siguiente es el primero del doble Atrás: advierte y no sale |

**Antes del arreglo** (las mismas pruebas en una copia de `80ae18b` en `%TEMP%`, hecha con
`tool/t99_copia.ps1`, que usa `git archive`; la del selector suelto se quitó solo en esa copia,
porque usa la API nueva y no compila contra el código de antes; `antes.py` en la evidencia):
**38 fallan y 25 pasan.**
- **Fallan:** H1 por una celda y por el borde («Found 1 widget with key `panel-lateral`»); Esc en
  la cabecera y los dos casos de Codex (siguen las 4 entradas del menú); Atrás (el registro tenía 0
  cosas abiertas en vez de 1); H3 a 700 en Contenido (108 dp contra 56,5); las dos de 1.45 y 2.0; y
  29 de las 36 de la matriz angosta (el botón cae a otra línea; y a 600 y 700 con 2.0 en Carga, los
  desbordes de 135 y 35 dp).
- **Pasan, como deben:** «sin flotante» y «Fijar», las 16 de Atrás que ya había y 7 casos de la
  matriz que ya iban en una línea.
- Después del arreglo pasan todas.

### C1.5 Cifras

- **`flutter analyze --no-pub`:** No issues found, sin `// ignore:`.
- **Suite:** **1677 aprobadas, 0 fallidas, 0 omitidas, en una corrida** (2:13 min; piso 1629, más
  48: 47 de `t117_correccion1_test.dart` y 1 de Atrás). Antes de quitar el foco al cerrar (C1.3,
  punto 6), otra corrida completa dio también 1677 (1:49 min); vale la segunda.
- **La franja de la bahía**, medida con las fuentes reales (`franja_angosta_test.dart`). Cada celda
  dice «alto de la franja · si "Acciones" lleva rótulo»; con 1.45 y 2.0 envuelve, como permite
  10.40, y en todos los casos el botón queda en la primera línea, sin desbordes:

| Ventana | Letra | Contenido | Descarga | Carga |
|---|---:|---|---|---|
| 600 × 800 | 1.0 | 108 · sí | 108 · sí | 108 · sí |
| 700 × 682 | 1.0 | **56 · no** (antes 108) | **56 · no** | 108 · sí |
| 700 × 682 | 1.45 | 114 | 114 | 166 |
| 700 × 682 | 2.0 | 178 | 178 | 178 (antes, desborde de 35) |
| 800 × 600 | 1.0 | 56 · sí | 56 · sí | 56 · no |
| 800 × 600 | 2.0 | 178 | 126 | 178 |
| 960 × 1000 | 1.0 | 56 · sí | 56 · sí | 56 · sí |
| 960 × 1000 | 2.0 | 126 | 126 | 126 |

- **A 700 dp en Carga la franja sigue en dos líneas** (108 dp), con el botón al final de la
  primera: con el OR no cabe ni con «Acciones» y el OR solo con sus iconos. A 600 dp no cabe en una
  línea en ningún modo. Ninguno de los dos casos lo pedía 10.42; quedan anotados (C1.8).

### C1.6 H2 en el emulador

**Banco:** r4 de `%TEMP%\t99-r4-c1`, copiado del árbol corregido (`t99_copia.ps1 -Arbol -Sufijo
r4`, con `T100_LLEGADA` y `T100_CARGA`). APK `gt.cmartinez.baystream.r4` con
`flutter build apk --release -t tool/t99_main.dart`, SHA-256 `749a54320e384dbc…`, instalado encima
del r4 anterior solo con `adb -s emulator-5554`.

**Emulador:** AVD `t99_api26`, Android 8 (API 26), 1080 × 1920 a 480 dpi (360 dp). Al terminar se
detuvo; no se usó el Honor.

**Instrumento:** `tool/t117_correccion1_android.py`, nuevo. Repite la reproducción de Codex:
1. reinicia los datos del banco y publica `T100_CARGA` confirmando su perfil (escala GTSTC);
2. abre `T100_LLEGADA`, que abre publicado en GTSTC;
3. elige Descarga en la banda del muelle y abre el menú del modo;
4. pulsa Atrás del sistema (`keyevent 4`) dos veces.

Lo hace en claro y en oscuro, con la letra a 1.0, y deja el tema en «Seguir al sistema».

| Tema | El menú se abre | 1.er Atrás: el menú se cierra | 1.er Atrás: sin advertencia | 1.er Atrás: sigue el plano | 2.º Atrás: advierte | 2.º Atrás: sigue el plano |
|---|---|---|---|---|---|---|
| Claro | sí | sí | sí | sí | sí | sí |
| Oscuro | sí | sí | sí | sí | sí | sí |

**Capturas** (`build/t117-correccion1/android/`, ocho PNG con `registro.jsonl` y `resultado.json`),
por tema:
- `01-plano-descarga`;
- `02-menu-abierto`: Contenido, Número de orden y Descarga, con la palomita;
- `03-primer-atras`: el plano sin menú, sin advertencia y sin sombreado en el botón;
- `04-segundo-atras`: «Toca Atrás otra vez para volver al inicio.».

**Dos intentos que no cuentan,** guardados aparte:
- `android-intento-1-la-captura-tarde/`: el producto ya cerraba el menú, pero el instrumento leía
  la pantalla antes de capturarla y la captura del segundo Atrás salió cuando la advertencia de
  2 s ya se había ido. Ahora captura primero.
- `android-intento-2-boton-sombreado/`: todo pasaba, pero el botón quedaba sombreado (C1.3, punto
  6). Se corrigió el código, se recompiló el APK y se repitió.

### C1.7 Archivos

- **Cambiados (10):**
  - `DESIGN.md`: 8 (Atrás), 14.3, 14.6 (y la firma del selector), 14.8, 14.10 (punto 14) y 14.11;
  - en `lib/core/design/componentes/`: `bs_selector_de_modo.dart` y `bs_primera_que_cabe.dart`;
  - `lib/features/vessel/presentation/pages/vessel_overview_page.dart`;
  - en `lib/features/vessel/presentation/widgets/`: `bay_plan_view.dart`,
    `franjas_del_plano.dart`, `loading_plan_controls.dart` y `navegacion_del_viaje.dart` (solo
    documentación);
  - `test/t114_candidata_atras_test.dart`;
  - y este informe.
- **Nuevos (2):** `test/t117_correccion1_test.dart` y `tool/t117_correccion1_android.py`.
- **Evidencia, fuera de Git:** `build/t117-correccion1/` (38 archivos):
  - las tres corridas del emulador;
  - las dos suites;
  - la corrida de antes del arreglo;
  - la medida de la franja y su prueba;
  - `antes.py`;
  - la versión de Flutter.
- **No cambian:** `domain/`, `data/`, `pubspec.yaml`, `pubspec.lock`, `lib/main.dart`, los
  congelados, Firebase y `docs/piloto/LISTA-PILOTO.md`. Ninguna dependencia nueva. Los cuatro
  archivos que solo difieren en el fin de línea no van en el bloque, ni la evidencia de ayer en
  `docs/t117/entrega1/`, que Carlos dejó sin versionar (10.41).

### C1.8 Lo que queda anotado

1. **A 700 dp en Carga** la franja va en dos líneas (108 dp), con el botón al final de la primera.
   Para que quepa en una habría que quitar algo más; por ejemplo, el rótulo «Colorear por», que
   seguiría en la descripción emergente y en la etiqueta. Se decide en la reaceptación.
2. **A 600 dp** la franja va en dos líneas en los tres modos (el ancho mínimo de la oficina; 10.42
   no lo pedía).
3. **Windows y la Web no se recompilaron** ni se repitieron RNF-002 ni las capturas: 10.42 pedía
   la suite, `analyze` y H2 en el emulador. El cambio de la franja y del selector está en las
   pruebas de widgets con las fuentes del producto, incluida la matriz angosta.
4. **La lista del piloto** (`docs/piloto/LISTA-PILOTO.md`, de Yov) no cambia por esta corrección:
   en la 3.2.0, el menú del modo se cierra con Atrás y con Esc, y con el flotante abierto el botón
   del panel solo lo cierra.

### C1.9 Horas

Unas **0.8 h**, de ≈ 11:30 a 12:15:
- la lectura y el código, sin Flutter;
- con Flutter: las pruebas, los desbordes y su arreglo, las dos suites, los dos APK, las tres
  corridas del emulador y este informe.

### C1.10 Git

**Para Carlos.** Un `git add` por ruta, 12 rutas. No incluye:
- los cuatro archivos que solo difieren en el fin de línea;
- la evidencia de `build/t117-correccion1/` (ignorada);
- la de `docs/t117/entrega1/` (sin versionar por 10.41).

```powershell
git add -- DESIGN.md
git add -- docs/T117-T121-RESULTADOS.md
git add -- lib/core/design/componentes/bs_primera_que_cabe.dart
git add -- lib/core/design/componentes/bs_selector_de_modo.dart
git add -- lib/features/vessel/presentation/pages/vessel_overview_page.dart
git add -- lib/features/vessel/presentation/widgets/bay_plan_view.dart
git add -- lib/features/vessel/presentation/widgets/franjas_del_plano.dart
git add -- lib/features/vessel/presentation/widgets/loading_plan_controls.dart
git add -- lib/features/vessel/presentation/widgets/navegacion_del_viaje.dart
git add -- test/t114_candidata_atras_test.dart
git add -- test/t117_correccion1_test.dart
git add -- tool/t117_correccion1_android.py
git commit -m "Sprint 4: T-117 y T-118, correccion 1 de la entrega 1 (10.42), cerrar el panel lateral no lo fija, Esc y Atras cierran el menu del modo y el boton del puente no queda solo en la franja" --trailer "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
git push
git show --stat --format="%h %s" HEAD | Select-Object -Last 1
```

El último comando tiene que decir **12 files changed**. No cambian `pubspec.yaml` ni
`pubspec.lock`.

### C1.11 Mensaje para Yov

> Yov: la corrección 1 de la entrega 1 de T-117 y T-118 (10.42) está en
> `docs/T117-T121-RESULTADOS.md`, sección «Corrección 1», y en `DESIGN.md` 8, 14.3, 14.6, 14.8,
> 14.10 y 14.11. **H1:** con el flotante abierto, el botón de la cabecera solo lo cierra; el panel
> sigue oculto y la preferencia no cambia. **H2:** al abrirse, el menú del modo lleva el foco a la
> entrada elegida, y Esc lo cierra; se anota en `cerrablesDeAtrasProvider` desde `SelectorDelModo`
> y «Colorear por», así que el primer Atrás lo cierra y no cuenta como el primero del doble Atrás.
> En el emulador pasa en claro y en oscuro, con capturas en `build/t117-correccion1/android/`.
> **H3:** a 700 dp en Contenido y Descarga la franja va en una línea (56 dp), y cuando envuelve el
> botón queda en la primera. Al medir apareció un desborde viejo que la matriz de 0.5.5 no veía (a
> 600 y 700 dp con la letra a 2.0 en Carga) y otro de 0.08 dp que traía la variante nueva a 960 dp,
> por la tolerancia de `BsPrimeraQueCabe`; los corregí, con una matriz angosta de 36 casos. Las pruebas nuevas, contra
> `80ae18b`: 38 fallan antes y pasan todas después. **Suite 1677, `analyze` en cero.** Quedan
> anotados Carga a 700 dp (dos líneas, con el botón en la primera) y 600 dp (dos líneas). Son 12
> rutas en el bloque; la evidencia no va a Git.

**ALTO: Codex reacepta.**

## Corrección 2 de la entrega 1 (25-oct-2026)

Timonel (Claude Code, Claude Opus 5.5), rama `sprint-4`, carpeta del rediseño, sobre `41f458d`
(decisión 10.44). La reaceptación de Codex (`docs/t117/entrega1/reaceptacion-codex.md`) no pasó
por un solo hallazgo, H4 · P2. «Acciones» solo con su icono no tenía nombre accesible en Windows, y
con su rótulo salía como texto, con el nombre repetido. O1 (Contenido a 800 × 600 con la letra a
2.0 pierde 52 dp al abrir) queda como P3 en 10.44 y no se toca.

### C2.1 Resultado en tres líneas

- **«Acciones» es el botón «Acciones»** para el lector de pantalla, con el icono y con el rótulo.
  La etiqueta lo nombra una vez, con la cuenta del distintivo cuando la muestra («Acciones, 1
  solicitud pendiente»); es botón y se puede tocar. La descripción emergente sigue al pasar el
  mouse, fuera de la semántica.
- **El mismo patrón aparece una vez más** en lo que tocaron T-117 y T-118: el resumen de una línea
  del teléfono (`PlanSummaryLine`), que se abre y se recoge con un `InkWell` sin rol de botón. Ahora
  también es un botón.
- **Suite 1685 (piso 1677, más 8)**, sin fallidas ni omitidas, en una corrida, y `analyze` en cero.
  Las 8 pruebas nuevas fallan contra `41f458d` y pasan después. **En el árbol accesible de Windows**,
  a 700, 600 y 560 dp, «Acciones» dice ahora «botón Acciones» en UIA y «botón de comando Acciones»
  en MSAA. Antes no estaba (700 y 560) o decía «texto Acciones. Acciones» (600).

### C2.2 Lo que se corrió

- Leí la decisión 10.44, el informe de Codex (H4 y O1) y su evidencia, solo como lectura:
  `nombre_acciones_test.dart` y los árboles `windows-real/18-h3-700-semantica.json` y
  `24-600-acciones-con-rotulo.json` de `baystream-qa-r4`. No toqué esa carpeta.
- **Sin Flutter,** escribí el código, la prueba, `DESIGN.md` y el instrumento del árbol de Windows,
  y preparé el banco «antes». Después, **con la luz verde de Carlos («Corre flutter»)**, corrí uno a
  la vez:
  1. `analyze`;
  2. las pruebas nuevas;
  3. las pruebas nuevas contra `41f458d`, en una copia de `%TEMP%`;
  4. **la suite completa, una vez**;
  5. los dos bancos de Windows, «antes» y «después», y su árbol accesible;
  6. `analyze` sobre la prueba, tras corregir uno de sus comentarios (C2.6).
- No se usaron el Honor, el emulador ni la Web. Datos sintéticos de T-100, nunca el corpus ni la
  página «Nube y cuenta». No se tocaron las apps instaladas, «PRUEBA T-105» ni
  `C:\Proyectos\baystream-demo17\`. Nada se publicó.

### C2.3 Qué cambió y por qué

**La causa, en el motor de Windows de Flutter 3.38.9**
(`engine/src/flutter/shell/platform/common/accessibility_bridge.cc` y
`third_party/accessibility/ax/platform/ax_platform_node_win.cc`):
- el nombre del nodo es la etiqueta, y la descripción emergente se le suma: en el árbol del banco
  «antes», UIA y MSAA dicen los dos «Acciones. Acciones», con la ayuda vacía;
- un nodo sin rol de botón y sin hijos es texto; si además no tiene etiqueta, se ignora y no entra
  al árbol.

«Acciones» era un `PopupMenuButton` con un hijo propio. Así, `PopupMenuButton` pone una
descripción emergente y un `InkWell`, pero no el rol de botón:
- solo con el icono no había etiqueta: el nodo era texto vacío y el motor lo ignoraba;
- con el rótulo, la etiqueta era el texto «Acciones» y la descripción emergente otra vez
  «Acciones»: «texto Acciones. Acciones».

En la Web, Chrome ya lo anunciaba como botón «Acciones» (Codex, `web-semantica/`).

**El arreglo** (`loading_plan_controls.dart`, `AccionesDelPlano`):
1. un `Semantics` de contenedor, con rol de botón y la etiqueta «Acciones», alrededor del
   `PopupMenuButton`. El toque del menú cae en ese mismo nodo;
2. lo que se dibuja (el icono, el distintivo y el rótulo) queda fuera de la semántica, para que la
   etiqueta no se arme con el texto suelto («1\nAcciones»);
3. la cuenta del distintivo va en la etiqueta cuando el distintivo la muestra: «Acciones, 1
   solicitud pendiente», «Acciones, 2 solicitudes pendientes»;
4. la descripción emergente «Acciones» es ahora un `Tooltip` por fuera, con `excludeFromSemantics`,
   y el `PopupMenuButton` va sin la suya (`tooltip: ''`, que no dibuja nada). Al pasar el mouse se
   ve igual; el lector de pantalla no oye el nombre dos veces. Es la regla que `DESIGN.md` 13.11 ya
   tenía para los iconos del contenedor.

El menú, sus entradas y sus claves de prueba no cambian. `DESIGN.md` 14.8 (una viñeta nueva) y
14.10 (punto 15).

### C2.4 El mismo patrón en lo que tocaron T-117 y T-118

Busqué en las 23 rutas de `lib/` que cambiaron de `48f941e` a `41f458d`: `PopupMenuButton`,
`InkWell`, `InkResponse`, `GestureDetector`, `MenuAnchor`, `Listener` y `MouseRegion`.

| Dónde | Qué es | Veredicto |
|---|---|---|
| `loading_plan_controls.dart`, `AccionesDelPlano` | `PopupMenuButton` con hijo propio | **H4, corregido** (C2.3) |
| `loading_controls.dart`, `PlanSummaryLine` | Tres `InkWell` con su hijo: el resumen de una línea del teléfono, que se abre y se recoge | **El mismo patrón, corregido.** Tenía nombre (el resumen y «Ver el resumen completo») pero no rol: Windows lo daba como «texto», sin Invoke. El `InkWell` viene de T-107, pero T-117 cambió lo que lleva dentro (las fichas) y lo usa en `_ResumenEnLinea`. Ahora cada uno va en un `Semantics` de contenedor con rol de botón; el nombre sigue siendo el que tenía |
| `bs_tarjeta_cifra.dart` | `InkWell` de la tarjeta que se toca (Alertas) | Bien: ya va en un `Semantics` con su etiqueta, rol de botón y toque |
| `vessel_overview_page.dart`, `_BordeDelPanel` | `GestureDetector` del borde del panel | Bien: queda fuera de la semántica a propósito; para el teclado y el lector está el botón de la cabecera (14.3) |
| `puente_del_plano.dart` | `GestureDetector` del asa del puente | Bien: el lector lo oye como el control deslizante «Alto del panel del buque» |
| `bs_selector_de_modo.dart`, `franjas_del_plano.dart` | `MenuAnchor` del modo, de «Colorear por» y de la lista de bahías | Sus botones ya son botones con nombre («Modo del plano: Descarga», «Colorear por: Estado», «Bahía 02»). Sus entradas son de Flutter (C2.9) |
| `plan_drag_confirmation.dart` | `GestureDetector` de la pulsación larga en la celda | Bien: la celda es su propio botón; la pulsación larga se suma a ese nodo |

El otro `PopupMenuButton` de `lib/` está en `vessel_geometry_page.dart`, que T-117 y T-118 no
tocaron; no lo toqué.

### C2.5 La prueba

`test/t117_correccion2_test.dart`, 8 pruebas, con las fuentes del producto:

| Prueba | Qué comprueba |
|---|---|
| A 700 dp en Contenido y en Descarga (2) | La cuarta variante de la franja, solo con el icono: el nodo de «Acciones» tiene la etiqueta «Acciones», es botón, tiene el toque, no lleva descripción emergente en la semántica, el nombre sale una sola vez y hay un solo nodo con ese nombre |
| A 600 dp en Descarga, con el rótulo | Lo mismo con el rótulo a la vista: ni «Acciones. Acciones» ni texto |
| En el teléfono (360 × 800) | Lo mismo, solo con el icono |
| El lector lo toca; el mouse ve la descripción | El toque por semántica (`tester.semantics.tap`) abre el menú; al pasar el mouse sale la descripción emergente «Acciones» |
| La cuenta del distintivo (2) | Con una solicitud de cambio pendiente (oficina con cuenta, operación publicada), con el icono y con el rótulo: el distintivo dice 1 y el nombre es «Acciones, 1 solicitud pendiente» |
| El resumen del teléfono | Cerrado y abierto, es botón y se toca; «Ver el resumen completo» y «Recoger el resumen» salen una sola vez |

**Antes del arreglo** (las mismas 8 en una copia de `41f458d` en `%TEMP%`, hecha con
`tool/t99_copia.ps1`, que usa `git archive`): **las 8 fallan**, cada una por lo que reproduce:
- a 700 dp y en el teléfono, la etiqueta es «» (vacía);
- a 600 dp no es botón;
- el lector no encuentra un nodo «Acciones» para tocar;
- con la cuenta, la etiqueta era «1» (con el icono) o «1\nAcciones» (con el rótulo);
- el resumen no era botón.

Después del arreglo pasan las 8.

### C2.6 Cifras

- **`flutter analyze`:** No issues found (42 s), sin `// ignore:`. Después de la suite solo cambió
  un comentario de la prueba; `analyze` sobre ese archivo, otra vez en cero.
- **Suite:** **1685 aprobadas, 0 fallidas, 0 omitidas, en una corrida** (2:08 min; piso 1677, más
  las 8 nuevas).
- **Las pruebas nuevas:** 8 de 8 después; contra `41f458d`, 0 de 8.

### C2.7 El árbol accesible de Windows, antes y después

**Bancos** (`build/t117-correccion2/bancos/bancos.json`):
- **«Antes»:** copia de `41f458d` (`t99_copia.ps1 -Commit 41f458d -Sufijo r4`). EXE SHA-256
  `F9143648…AD460`.
- **«Después»:** copia del árbol corregido (`-Arbol`); los dos archivos cambiados coinciden por
  SHA-256 con el árbol. EXE `F85BC8EB…25719`.
- Los dos se compilaron con `flutter build windows --release --no-pub -t tool/t99_main.dart` y su
  almacén en `%TEMP%\t117-c2\<antes|despues>\store-windows`.
- El almacén es una copia del sintético del banco de la entrega 1: `T100_LLEGADA` publicado en
  GTSTC.
- Para no bajar otra vez el SDK de Firebase (915 MB), la carpeta de compilación de cada uno llevó,
  antes de compilar, el zip de ese banco (como enlace duro) y su `extracted` copiado. CMake no
  bajó nada: 72 s y 66 s.
- Se abrieron con `explorer.exe`.

**Instrumento:** `tool/t117_correccion2_windows.ps1`, nuevo. Lee el árbol de la ventana de las dos
maneras que usan los lectores de pantalla:
- **UIA** (la vista de control): tipo de control, nombre, ayuda y patrones;
- **MSAA**: rol y nombre clásico.

No mueve el mouse ni toca el teclado:
- abre el viaje y elige el modo con Invoke de UIA, o con la acción por omisión de MSAA donde Flutter
  no da Invoke;
- fija el ancho de la ventana en dp con `SetWindowPos`.

La laptop está a 120 DPI: 700 dp son 875 px. La letra a 1.0 y el tema del sistema (oscuro). Las
capturas son las de `t100_windows.ps1` (`PrintWindow`).

| Estado (cliente) | Antes: UIA · MSAA | Después: UIA · MSAA |
|---|---|---|
| 1266 × 682 dp, Contenido (con el rótulo) | texto «Acciones. Acciones» · texto «Acciones. Acciones» | **botón «Acciones»** (Invoke) · **botón de comando «Acciones»** |
| 700 × 682, Contenido (solo el icono) | **no está**: entre «100 %» y «Plegar el panel del buque» no hay nada | **botón «Acciones»** (Invoke) · **botón de comando «Acciones»** |
| 700 × 682, Descarga (solo el icono) | **no está** | **botón «Acciones»** · **botón de comando «Acciones»** |
| 600 × 682, Descarga (con el rótulo) | texto «Acciones. Acciones», sin Invoke · texto «Acciones. Acciones» | **botón «Acciones»** (Invoke), sin ayuda · **botón de comando «Acciones»** |
| 560 × 682, Descarga (el teléfono, solo el icono) | **no está** | **botón «Acciones»** · **botón de comando «Acciones»** |
| 560 × 682, el resumen de una línea | texto «Bahía 02: … / Ver el resumen completo», sin Invoke | **botón** «Bahía 02: … / Ver el resumen completo» (Invoke); abierto, **botón «Recoger el resumen»**, con los textos del resumen dentro |

- **Nada más cambia en el árbol.** Por estado, antes y después (`windows/diferencias.txt`), las
  únicas diferencias en UIA y en MSAA son las de esta tabla. A 700 dp hay un nodo más («Acciones»),
  a 600 el mismo número de nodos (el texto pasa a botón) y a 560, uno más.
- **Se puede tocar:** activado por Invoke de UIA a 700 dp, «Acciones» abre su menú, con «Pendientes
  de descarga» y «Avance de la operación» como botones (`13-700-acciones-abierto`).
- **Un tropiezo del instrumento:** para cerrar ese menú busqué un nodo «Cerrar», y el primero era el
  botón «Cerrar» de la barra de título de Windows. Cerró el banco «después», que era mío y con su
  almacén en `%TEMP%`. Lo volví a abrir por `explorer.exe` y repetí 600 y 560 dp; lo de 700 dp ya
  estaba volcado.
- Evidencia: `build/t117-correccion2/windows/antes/` y `…/despues/`. Por estado hay un `.json` (el
  árbol entero, con la ventana, el DPI y el momento), un `.txt` (los dos árboles legibles) y un
  `.png`. Además, `diferencias.txt` y `diferencias.json`.

### C2.8 Archivos

- **Cambiados (4):**
  - `DESIGN.md`: 14.8 (una viñeta) y 14.10 (punto 15);
  - en `lib/features/vessel/presentation/widgets/`: `loading_plan_controls.dart` y
    `loading_controls.dart`;
  - y este informe.
- **Nuevos (2):** `test/t117_correccion2_test.dart` y `tool/t117_correccion2_windows.ps1`.
- **Evidencia, fuera de Git:** `build/t117-correccion2/` (56 archivos):
  - `analyze.log` y `suite.log`;
  - las pruebas nuevas antes y después;
  - los bancos (registros y huellas);
  - los árboles de Windows;
  - la versión de Flutter.
- **No cambian:** `domain/`, `data/`, `pubspec.yaml`, `pubspec.lock`, `lib/main.dart`, los
  congelados, Firebase y `docs/piloto/LISTA-PILOTO.md`. Ninguna dependencia nueva. Los cuatro
  archivos que solo difieren en el fin de línea no van en el bloque, ni la evidencia de
  `docs/t117/entrega1/`, que sigue sin versionar (10.41).

### C2.9 Lo que queda anotado

1. **La prueba de Codex de H4** (`nombre_acciones_test.dart`) pide la etiqueta «Acciones» y además
   `tooltip: "Acciones"` en el nodo. La etiqueta ya está. La descripción emergente queda fuera de la
   semántica **a propósito**: dejarla es lo que hace que Windows diga «Acciones. Acciones». Esa
   línea de su prueba va a seguir roja; la descripción se comprueba al pasar el mouse.
2. **Visto en el árbol de Windows, sin corregir.** No es el patrón de 10.44 (tienen nombre y rol, o
   son de Flutter); queda para que Carlos y Yov decidan:
   - **Los segmentos de `BsSelectorDeModo`** (T-118: «Colorear por» y el modo en segmentos) repiten
     el nombre: «botón Destino. Destino. El puerto de descarga de cada contenedor». Son
     `SegmentedButton` de Flutter con `tooltip`, y la descripción emergente empieza por el mismo
     nombre. Se arreglaría dejando la descripción fuera de la semántica y pasando la ayuda como
     pista (`hint`). Toca el componente compartido, así que no lo hice sin pedirlo.
   - **Las entradas de los menús de Flutter** (`MenuItemButton`: el menú del modo, el de «Colorear
     por» y la lista de bahías) salen como «texto Descarga, 30 por bajar en GTSTC». No son botón ni
     tienen Invoke en UIA, porque Flutter 3.38.9 las arma así (`isSemanticButton: null`). La acción
     por omisión de MSAA sí las activa: así eligió Descarga el instrumento.
   - **La barra lateral** dice «texto Plano / Pestaña 1 de 6»: es el `NavigationRail` de Flutter y
     viene de antes de T-117.
3. **La Web y Android no se miraron en su árbol nativo.** 10.44 pedía el de Windows. La semántica
   es la misma en los tres clientes y la cubren las pruebas de widgets, incluida la del teléfono.
   Codex ya había visto en Chrome el botón «Acciones», y ahora la etiqueta está explícita.
4. **El instrumento del piloto en Android** (`tool/t114_piloto_android.py`) busca «Acciones» con
   `^Acciones$`, y sin solicitudes pendientes el nombre sigue siendo exactamente ese. Con
   solicitudes pendientes, el nombre sigue con la cuenta. La lista del piloto no cambia.
5. **O1 no se tocó** (10.44).

### C2.10 Horas

Unas **0.7 h**, de ≈ 16:45 a 17:30:
- la lectura, la búsqueda del patrón, el código, la prueba y el instrumento, sin Flutter;
- con Flutter: `analyze`, las pruebas antes y después, la suite, los dos bancos, el árbol de
  Windows y este informe.

### C2.11 Git

**Para Carlos.** Un `git add` por ruta, 6 rutas. No incluye:
- los cuatro archivos que solo difieren en el fin de línea;
- la evidencia de `build/t117-correccion2/` (ignorada);
- la de `docs/t117/entrega1/` (sin versionar por 10.41).

```powershell
git add -- DESIGN.md
git add -- docs/T117-T121-RESULTADOS.md
git add -- lib/features/vessel/presentation/widgets/loading_controls.dart
git add -- lib/features/vessel/presentation/widgets/loading_plan_controls.dart
git add -- test/t117_correccion2_test.dart
git add -- tool/t117_correccion2_windows.ps1
git commit -m "Sprint 4: T-117 y T-118, correccion 2 de la entrega 1 (10.44), Acciones es un boton con su nombre para el lector de pantalla y el resumen del telefono tambien" --trailer "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
git push
git show --stat --format="%h %s" HEAD | Select-Object -Last 1
```

El último comando tiene que decir **6 files changed**. No cambian `pubspec.yaml` ni `pubspec.lock`.

### C2.12 Mensaje para Yov

> Yov: la corrección 2 de la entrega 1 de T-117 y T-118 (10.44) está en
> `docs/T117-T121-RESULTADOS.md`, sección «Corrección 2», y en `DESIGN.md` 14.8 y 14.10.
>
> **H4:** «Acciones» es ahora un botón con la etiqueta «Acciones», con el icono y con el rótulo, y
> con la cuenta del distintivo cuando la muestra («Acciones, 1 solicitud pendiente»). La descripción
> emergente sigue al pasar el mouse, fuera de la semántica, porque Windows la suma a la etiqueta en
> el nombre. **El mismo patrón** estaba en el resumen de una línea del teléfono
> (`PlanSummaryLine`), y ahora también es un botón. No hay otro en lo que tocaron T-117 y T-118.
>
> **Cifras:** las 8 pruebas nuevas fallan contra `41f458d` y pasan después; suite 1685 y `analyze`
> en cero.
>
> **Árbol accesible de Windows, en dos bancos propios abiertos con `explorer.exe`:** a 700, 600 y
> 560 dp dice «botón Acciones» en UIA y «botón de comando Acciones» en MSAA; antes no estaba, o era
> «texto Acciones. Acciones». Nada más del árbol cambia.
>
> **Anotado, sin corregir:**
> - los segmentos de `BsSelectorDeModo` repiten el nombre («Destino. Destino. …»);
> - las entradas de los menús de Flutter salen como texto, sin Invoke;
> - la prueba de Codex que pide `tooltip: "Acciones"` en el nodo seguirá roja a propósito.
>
> Son 6 rutas en el bloque; la evidencia no va a Git.

**ALTO: Codex reacepta.**
