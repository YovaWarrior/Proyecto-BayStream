# T-120 · La Lista y el buscador: filtrar por destino y buscar por carga especial (RF-018) · Resultados

Timonel (Claude Code, Claude Opus 5.5). Rama `sprint-4`, carpeta del rediseño
(`C:\Proyectos\baystream-rediseno`), punta `899e4e3` («Sprint 4: decision 10.146, el bloque 2 abre
con T-120»). Ficha de la tarea: 10.146 de `SPRINT-4.md`. Lo acepta GLM 5.3 Flash, en Max (10.137).

Este documento lleva, por ahora, el paso 0 y la **propuesta** (fase 1). No toqué `lib/` ni `test/`.
Termina en «ALTO: Yov revisa y Carlos aprueba».

---

## 0. Paso 0

### 0.1 La punta y el árbol

- **La punta es `899e4e3`, y trae la 10.146** (`git log --oneline -10`, `git show --stat HEAD`: solo
  cambia `SPRINT-4.md`, 33 líneas). Las lecturas de Git fueron esas dos y `git diff --stat`; nunca
  `git status`.
- **Lo que el árbol trae y no es mío:** los cuatro archivos que `git diff --stat` marca
  (`test/t114_fase3_correccion_test.dart` y tres de `windows/flutter/`) solo avisan del fin de línea y
  no tienen cambios de contenido, como anotó Yov en la 10.37; y las carpetas sin seguimiento de
  `docs/entrega-7nov/` y `docs/t117/entrega1/`. No las toco y no van en ningún bloque.

### 0.2 Carlos, los carriles y Flutter

- **Carlos confirmó (17-nov, 21:34)** que ninguna otra tarea tiene abiertos `lib/`, `test/` ni
  `pubspec.*`, y dio luz verde para `pub get` y `analyze`. También dijo que **tiene un segundo
  monitor** (punto 7).
- **Ventana de Flutter, con su `SEMÁFORO:`**, de 21:34 a 21:35, un comando a la vez:
  - `flutter pub get`: salida 0. `pubspec.lock` tiene la misma huella antes y después
    (`B035F52C…62BCBD`);
  - `flutter analyze --no-pub` de todo el paquete: **«No issues found!»**, salida 0.
  - Los registros están en `build/t120/paso0/` (`pub-get.txt` y `analyze.txt`), fuera de Git.
- En la fase 1 no corrí nada más de Flutter ni de Dart.

### 0.3 Lo que leí

`CLAUDE.md` y `AGENTS.md`; de `SPRINT-4.md`, la sección 2 y las decisiones 10.6, 10.36 a 10.38, 10.44
a 10.46, 10.81 a 10.84, 10.117, 10.122, 10.141 y 10.144 a 10.146; de `docs/T117-T121-RESULTADOS.md`,
0.7, 0.8, C1.8 y C2.9; `docs/T119-RESULTADOS.md`; `docs/t117/entrega1/reaceptacion-codex.md`; de
`DESIGN.md`, 11, 13.4, 14 (sobre todo 14.6, 14.8 y 14.9), 15 (15.5 y 15.6), 16 y 17; de
`docs/T99-RESULTADOS.md`, B.3 y B.7, y de `docs/REDISENO-RESULTADOS.md`, 4.7 (la RAM antes y después
del plano nuevo). Y el código de la sección 1.4 del prompt con sus pruebas, más lo que esos archivos
usan: `loading_operation_provider.dart`, `estadisticas_del_viaje.dart`, `carga_especial.dart`,
`franjas_del_plano.dart`, `navegacion_del_viaje.dart`, `bs_barra_de_magnitud.dart`,
`bs_caja_de_codigo.dart`, `reserved_slots_list_view.dart`, el lector (`baplie_parser_service.dart`,
solo para saber de dónde sale cada bandera) y `tool/t99_conductor.dart`, `tool/t99_ram_windows.ps1`
y `tool/t114_ram_windows.ps1`.

**No encontré contradicciones** entre el prompt, `CLAUDE.md`, `AGENTS.md` y el código. Dos matices,
que no cambian nada:
- La sección 2 de `SPRINT-4.md` todavía dice «el piso es 1063»; el piso de hoy es el de la 10.141,
  **2227**, como dice el prompt.
- El prompt cita «la historia» de RF-018 («listar todos los reefer o IMDG del viaje para hacer la
  ronda de revisión»). En el repositorio solo encontré la fila de RF-018 en
  `docs/entrega-7nov/fuentes/DOC1.md` (SHOULD, OE3, «No»); el criterio y la historia los tomo del
  prompt.

### 0.4 La sección 0.8 (24-oct) contra el código de hoy

| Lo que decía 0.8.1 | Hoy | Estado |
|---|---|---|
| La Lista en `vessel_overview_page.dart:909-1048` | Es `_buildContainersListTab`, `vessel_overview_page.dart:1179-1319` | Igual, movida |
| «Filtrar por Naviera», con «N» mayúscula (regla 3 de `DESIGN.md` 11) | Sigue así (`:1242`) | **Igual** |
| Los chips en una línea con desplazamiento horizontal: en escritorio, sin barra | Siguen así (`:1246-1279`). La leyenda del plano sí se arregló (14.9) | **Igual** |
| Las cuentas por naviera se recorren una vez por chip en el `build` | Siguen así (`:1262-1264`), ahora sobre `aboardContainersProvider` | **Igual** |
| El filtro es solo por naviera, `filteredContainersProvider` en `vessel_providers.dart:734-748` | Sigue siendo solo por naviera. **El provider se mudó** a `loading_operation_provider.dart:108-114`, con `carriersListProvider` (`:96-106`): desde T-122 (H6) la Lista recorre lo que va a bordo, el archivo más los vacíos asignados a una reserva. La naviera elegida sigue en `vessel_providers.dart:752-770` | Cambió |
| `portDistributionProvider` escribe «N/A» (`vessel_providers.dart:892`) | Sigue escribiéndolo (`:919`), pero **ya nadie lo usa**, ni él ni `carrierDistributionProvider`, `specialCargoStatsProvider` y `bayStatsProvider`. Estadísticas cuenta en `EstadisticasDelViaje.de` (`formatters/estadisticas_del_viaje.dart`, T-121), con «Sin puerto» y con los vacíos asignados (T-125) | Cambió: ya no estorba. No lo borro: sería refactorizar de paso |
| La Lista construye todas las tarjetas (`containers_list_view.dart:28-37`, dentro de un `SingleChildScrollView`) | Sigue así (`containers_list_view.dart:29-37`; `vessel_overview_page.dart:1186`). El rediseño lo volvió a medir: la Lista sigue en 510.5 → 513.6 MB contra 190 de lo demás (`REDISENO-RESULTADOS.md` 4.7) | **Igual** |
| La naviera se limpia al abrir otro viaje (`vessel_providers.dart:408` y `613`) | Ahora en `:431` (el previo) y `:671` (abrir un guardado), y también en `vessel_overview_page.dart:698`, al saltar de Alertas a una celda | Cambió de línea |
| La ficha del puerto: relleno y contorno de su ranura (13.4) | **Ya existe la pieza:** `BsCajaDeCodigo` (T-121), con el rol de `BsColoresSemanticos.categorico`. La tabla de 13.4 se reordenó (`tonoDeRanura`) | Hecho, se reusa |
| «Sin destino», nunca «N/A» | Estadísticas ya dice «Sin puerto» (15.5). La Lista no tiene filtro de destino | Por hacer (ver 1.1.6) |
| Estadísticas: «Tocar un puerto para ir a la Lista es T-120» | `DESIGN.md` 15.5 lo deja anotado; `BsBarraDeMagnitud` no se toca | Por hacer |
| `Lleno`, `Vacío`, `Sin dato` en tipo oración | Hecho en T-143 (O-139-2) | Hecho |

**Nada de T-120 está construido:** no hay filtro por destino, ni «Quitar filtros», ni cuentas
cruzadas, ni nada de carga especial en el buscador.

---

## 1. Propuesta

### 1.1 El filtro por destino, al día

#### 1.1.1 Qué se ve

- **«Filtrar por naviera»** (pasa a minúscula, regla 3) y debajo **«Filtrar por destino»**. Cada fila
  lleva primero «Todas» o «Todos» y después un chip por código.
- **El chip de un puerto** lleva su ficha (`BsCajaDeCodigo`: el relleno, el contorno y el código en
  Plex Mono, los mismos de la celda y de la leyenda) y su cuenta en cifras tabulares: `[GTSTC] 520`.
  El de una naviera, el código en Plex Mono sin caja (las navieras no tienen color, 15.5) y su cuenta.
- **El orden: de más a menos, y a igual cuenta por código,** como Estadísticas. Cambio pequeño: hoy
  las navieras van por orden alfabético (`carriersListProvider`). Propongo el mismo orden en las dos
  filas (decisión D3).
- **«Sin destino N»** al final de la fila de destinos, solo si hay alguno: el contenedor sin `LOC+11`
  o con el código en blanco. Nunca «N/A».
- **Las cuentas son cruzadas** (P10, aprobada en 10.38): con una naviera elegida, cada destino cuenta
  solo los de esa naviera, y al revés. «Todos» y «Todas» llevan el total del otro filtro. **Un chip
  en cero va apagado** y no se toca, con el lector de pantalla diciendo «sin contenedores con este
  filtro».
- **El elegido** va con el estilo de seleccionado de `FilterChip` de Material 3, sin la palomita
  (`showCheckmark: false`), para que el chip no cambie de ancho al elegirlo. Tocar otra vez el
  elegido lo suelta, como hoy con la naviera.
- **El título** dice qué filtra: «Contenedores (520)» sin filtros; «Contenedores (520), destino
  GTSTC»; «Contenedores (212), naviera LNA, destino GTSTC». Las dos cifras de llenos y vacíos siguen
  a su lado. **«Quitar filtros»** (un `TextButton`) va al final del título, solo con algún filtro.
- **Con filtros y sin resultados** (puede pasar si la operación suma vacíos asignados mientras se
  mira): «Ningún contenedor coincide con estos filtros» y «Quitar filtros» (regla 8). Sin filtros,
  el mensaje de hoy.
- **El lector de pantalla:** cada fila es un grupo con su nombre («Filtrar por destino»); cada chip,
  un botón conmutable con una etiqueta y nada más («GTSTC, 520 contenedores»), sin descripción
  emergente en la semántica: la lección de O2 (1.6).

#### 1.1.2 La oficina (desde 600 dp)

- **Las dos filas en una tabla de dos columnas:** el rótulo a la izquierda, con el ancho del más largo
  de los dos (`IntrinsicColumnWidth`), y los chips en un `Wrap` a la derecha, que envuelve en las
  líneas que pida. Así «Filtrar por naviera» y «Filtrar por destino» quedan alineados y nada se
  corta ni se desplaza a lo ancho.
- **Si el rótulo pasa del 30 % del ancho** (la letra a 2.0 en una ventana de 600 a 800 dp), va encima
  de sus chips, como en el teléfono.

```
1920 · la Lista con los dos filtros (la letra a 1.0)
┌──────────────────────────────────────────────────────────────────────────────────────────┐
│ [resumen del viaje] [Alertas de estiba] [Comparar con otro BAPLIE…] [Orden de descarga]  │
│ ▸ Celdas reservadas (55)                                                                 │
│                                                                                          │
│ Filtrar por naviera   (Todas 212) (LNA 120) (LNB 60) (LNC 32) (LND 0)                    │
│ Filtrar por destino   (Todos 977) ([GTSTC] 212) ([USHOU] 245) ([PAMIT] 130) (Sin destino 3)│
│                                                                                          │
│ Contenedores (212), naviera LNA, destino GTSTC   170 llenos  42 vacíos  [Quitar filtros] │
│ ┌──────────────────────────────────────────────────────────────────────────────────────┐ │
│ │ ▤  TSTU 000110 8   LNA   …                                                           │ │
└──────────────────────────────────────────────────────────────────────────────────────────┘
  [GTSTC] = la ficha del puerto (BsCajaDeCodigo). (LND 0) va apagado.
```

#### 1.1.3 El teléfono (menos de 600 dp)

- El rótulo arriba y los chips en **hasta dos líneas**. Si no caben todos, los que caben y un último
  chip **«Ver los 9 destinos»** («Ver las 6 navieras»), que abre una hoja (`BsHojaDeDetalle`, la de
  siempre) con todos, su ficha y su cuenta, en una lista que se desplaza. Elegir en la hoja la cierra
  y filtra.
- **Cuántos caben se mide, no se fija:** una pieza nueva, `BsFichasEnLineas` (en
  `lib/core/design/componentes/`), dispone los chips como un `Wrap` y, si pasan de dos líneas, deja
  los primeros que caben y el chip de «Ver los n», todo medido con las fuentes y la letra de ese
  momento. Los que quedan fuera no se pintan ni están en la semántica. Con la letra a 2.0 la hoja
  llega antes, sola.
- **El elegido siempre se ve:** si no es de los primeros (por ejemplo, un puerto chico elegido desde
  Estadísticas), toma el último lugar antes de «Ver los n».

```
360 dp · la Lista (la letra a 1.0)
┌──────────────────────────────────────┐
│ Filtrar por naviera                  │
│ (Todas 520) (LNA 212) (LNB 160)      │
│ (LNC 98) (Ver las 6 navieras)        │
│ Filtrar por destino                  │
│ (Todos 977) ([GTSTC] 520)            │
│ ([USHOU] 245) (Ver los 7 destinos)   │
│                                      │
│ Contenedores (520), destino GTSTC    │
│ 412 llenos  108 vacíos               │
│ [Quitar filtros]                     │
│ ┌──────────────────────────────────┐ │
│ │ ▤ TSTU 000110 8                  │ │
```

#### 1.1.4 Las capas

- **`selectedDischargePortProvider`** (`String?`), en `vessel_providers.dart`, junto a
  `selectedCarrierProvider` y con la misma forma (`select` y `clear`), para no tocar las tres pruebas
  ni `tool/block7_checks.dart`, que eligen una naviera con ella. `null` es «Todos»; la clave
  `FiltrosDeLaLista.sinDestino` (la cadena vacía) es «Sin destino».
- **Se limpia donde se limpia la naviera:** `vessel_providers.dart:431` (el previo) y `:671` (abrir
  un guardado), y `vessel_overview_page.dart:698` (saltar de Alertas a una celda).
- **`filteredContainersProvider`** (`loading_operation_provider.dart`) filtra por los dos.
- **`cuentasDeLosFiltrosProvider`**, nuevo, al lado: en **una sola pasada** por lo que va a bordo da
  las cuentas cruzadas de las dos filas, ya ordenadas. Sustituye el `where` por chip de hoy, que
  recorre los 977 contenedores una vez por naviera en cada `build`.
- **`domain/` y `data/` no cambian.**

#### 1.1.5 Las celdas reservadas

- **Siguen aparte**, en «Celdas reservadas (55)», encima de los filtros y sin filtrar: ese widget lo
  dice («Las reservas se consultan aparte de la lista y los filtros de contenedores») y no son
  contenedores. **No entran en las cuentas** de ninguna fila.
- **Los vacíos asignados a una reserva sí entran** (están en `aboardContainersProvider`, T-122): llevan
  el puerto y la naviera de su reserva, así que cuentan y se filtran como cualquier contenedor, igual
  que en Estadísticas (T-125).
- Filtrar también las reservas por destino es posible (una hora más), pero no lo recomiendo ahora:
  la regla de que se consultan aparte viene de T-69 y nadie lo pidió.

#### 1.1.6 Lo que cambia de 0.8.2, y por qué

1. **La ficha ya existe:** es `BsCajaDeCodigo`, la de Estadísticas. No hace falta otra.
2. **La oficina en una tabla de dos columnas,** no en dos `Wrap` sueltos: los rótulos quedan alineados
   y con la letra grande pasan encima.
3. **«Ver los n» se mide** (`BsFichasEnLineas`), no se fija en un número de chips, y el elegido siempre
   se ve.
4. **Las navieras, de más a menos** (D3), como los destinos y como Estadísticas.
5. **El título dice los dos filtros**, y con filtros sin resultados hay un vacío que invita a quitarlos.
6. **«Sin destino» en la Lista y «Sin puerto» en Estadísticas.** 0.8.2 dice «Sin destino», y la fila
   y la tarjeta hablan de «Destino»; 15.5 decidió «Sin puerto» porque el panel se llama «Por puerto
   de descarga». Propongo dejar cada uno en su pantalla (D6).
7. **«Sin naviera» no entra** como chip: 0.8.2 no lo tenía y cambiaría el tipo del provider de la
   naviera. El contenedor sin naviera sigue en «Todas».

### 1.2 De Estadísticas a la Lista

- **Qué se toca:** cada barra del panel «Por puerto de descarga». `BsBarraDeMagnitud` gana un
  `alTocar` opcional: con él, la barra entera es un botón (`InkWell` con el radio del panel y el foco
  visible), con la etiqueta de hoy («GTSTC: 520 contenedores, 53 %») como único nombre y la
  descripción emergente «Ver estos contenedores en la Lista» con el mouse, fuera de la semántica.
  Intro y espacio lo activan con el teclado.
- **«Sin puerto»** abre la Lista con «Sin destino». **«Otros N puertos»** no se toca: junta varios.
- **Qué pasa al tocar:** el destino elegido pasa a ese puerto, **la naviera se suelta** (la barra
  cuenta todas las navieras, y así la Lista dice la misma cifra que la barra) y se va a la pestaña
  Lista, arriba, con la fila de filtros a la vista.
- **La tabla de «Ver como tabla»** no se toca: sigue siendo de lectura.
- **En los tres clientes** es lo mismo, porque Estadísticas y la Lista son las mismas pantallas.
- **Cómo se vuelve:**
  - con el riel en la oficina y la barra inferior en el teléfono, como siempre;
  - **Atrás de Android vuelve a Estadísticas una vez:** al llegar desde una barra, la Lista se anota en
    `cerrablesDeAtrasProvider` (8) con «volver a Estadísticas»; se olvida si se cambia de pestaña o de
    filtro. No cuenta como el primero del doble Atrás;
  - **Estadísticas y la Lista recuerdan dónde estaban** (`PageStorageKey` en sus desplazables): hoy, al
    volver a una pestaña, empieza arriba.
- `DESIGN.md` 15.5 deja de decir «es T-120».

### 1.3 RF-018: el buscador entiende la carga especial

#### 1.3.1 Los términos

Se comparan como **palabras enteras**, sin mayúsculas ni tildes («Refrigerado», «PELIGROSA» e «imdg»
valen). Con los tres de la especificación y los que propongo en español:

| Categoría | Términos | De dónde sale en el dominio |
|---|---|---|
| **Refrigerado** | `reefer`, `reefers`, `refrigerado`, `refrigerados`, `refrigerada`, `refrigeradas` | `ContainerUnit.isReefer`: el lector lo marca si el tipo ISO es de refrigerado (`_isReeferIsoType`) o si trae `TMP` (la temperatura) |
| **Peligrosa** | `imo`, `imdg`, `peligrosa`, `peligrosas`, `peligroso`, `peligrosos` | `isDangerous`: el contenedor trae al menos un `DGS`. Las declaraciones, todas en orden, en `dangerousGoods` (T-144), con `declaracionesDe` para los registros viejos |
| **Fuera de medida** | `oog`, `sobredimensionado`, `sobredimensionados`, `sobredimensionada`, `sobredimensionadas`, y la frase `fuera de medida` | `isOverDimension`: un `DIM` 5 a 9 mayor que cero o ilegible (T-144). Las medidas, en `overLengthFront` … `overHeight` |

**Dos afinados, que propongo porque son los de la ronda:**
- **La clase IMO:** `imo 3`, `imdg 3`, `imo3` o `clase 3` dan las peligrosas con alguna declaración de
  esa clase; `imo 2` da también 2.1, 2.2 y 2.3.
- **El número ONU:** `un 1993` u `onu 1993` dan las que declaran ese número.

#### 1.3.2 Cómo convive con la búsqueda de hoy

- **La consulta se parte en dos:** los términos de carga especial que reconoce y **el resto**, que se
  busca **como hoy**: la matrícula sin espacios (T-144 y T-146), los dos puertos y la naviera.
- **Varias categorías juntas son «cualquiera de ellas»** («reefer imo» da los refrigerados **y** las
  peligrosas: es la historia, «los reefer o IMDG»). **El resto se cumple además** («reefer GTSTC»: los
  refrigerados que van a GTSTC o salen de ahí). D7.
- **Sin resto, la categoría sola** («imo» lista todas las peligrosas).
- **Una consulta sin ningún término** se comporta exactamente como hoy, con sus pruebas (T-144, T-146 y
  `container_search_delegate_test.dart`).
- **El roce:** un término reconocido es carga especial, aunque hubiera un puerto o una naviera con
  ese código (no los hay: los puertos tienen cinco letras y las matrículas once; una naviera «IMO»
  o «OOG» no aparece en el corpus, y lo cuento en la fase 2, sin copiar nada del corpus). Al teclear
  «IMOU…», mientras solo va «imo», se ven las peligrosas; con la cuarta letra ya no es el término.
- **La lógica vive en Dart puro,** `formatters/consulta_de_busqueda.dart` (nuevo): `interpretar` da las
  categorías, la clase, el número ONU y el resto; `coincide` lo aplica a un contenedor. Se prueba sin
  widgets.

#### 1.3.3 El resaltado de T-146

- **El resto se resalta como hoy:** la matrícula con la consulta sin espacios y el puerto con la
  consulta. Pero **con el resto, no con la consulta entera:** en «reefer GTSTC», hoy se buscaría
  «REEFER GTSTC» dentro de «POD: GTSTC» y no se resaltaría nada.
- **Los términos no se resaltan en el texto** (no están escritos en él): lo que explica por qué salió es
  la línea de 1.3.4.

#### 1.3.4 Qué dice el resultado

- **Arriba de los resultados, una línea con lo que se entendió:** «12 refrigerados»; «17 refrigerados
  o peligrosos»; «3 peligrosos de clase 3»; «5 refrigerados que coinciden con «GTSTC»». Con su
  concordancia (regla 7).
- **En cada resultado, la señal de su categoría,** solo la de las categorías pedidas, con los nombres
  del plano y de Estadísticas (15.5):
  - «Refrigerado, −18 °C», o «Refrigerado, el archivo no trae temperatura» (un refrigerado vacío o
    apagado: el tipo ISO lo marca y no hay `TMP`);
  - «Peligrosa IMDG, IMO 3, UN 1993», o con más: «Peligrosa IMDG, IMO 3 +1» (`etiquetaDePeligrosa`);
  - «Fuera de medida: Frente 30 cm, Alto 25 cm» (`medidasFueraDeGalibo`, con comas en vez del punto
    medio, regla 6).
- **El lector de pantalla** oye la matrícula, la posición y esa señal en una sola etiqueta.

```
360 dp · «reefer gtstc»
┌──────────────────────────────────────┐
│ ←  reefer gtstc                   ✕  │
├──────────────────────────────────────┤
│ 5 refrigerados que coinciden con     │
│ «GTSTC»                              │
│ ◉ TSTU 000110 8                45R1  │
│   LNA  POD: [GTSTC]           24.1 t │
│   Posición: 010-02-82                │
│   Refrigerado, −18 °C                │
```

- **El estado vacío** suma una sección **«Carga especial»** con un chip por categoría que haya
  («Refrigerado 12», «Peligrosa IMDG 5», «Fuera de medida 2»), que escribe el término y busca, como
  ya hacen las navieras y los puertos. Así se descubre sin leer el manual.
- **El texto de ayuda** pasa a «Busca por matrícula, puerto, naviera o carga especial», y el campo, a
  «Buscar contenedor, puerto o carga…». La consigna de abajo cambia su «Consejo: Escribe…» por una
  frase en tuteo y tipo oración (regla 1): «Escribe parte de la matrícula, como «MSKU123», o
  «reefer», «imo» u «oog»». La prueba de T-144 que busca el texto de ayuda
  (`t144_lector_volcado_test.dart:734`) se pone al día en esa línea.

#### 1.3.5 El dictado

- **El buscador general no tiene dictado propio.** `VoiceSearchField` solo vive en el campo de carga
  por OR (`loading_controls.dart:322`) y normaliza letras y dígitos para un OR; no sirve para palabras.
- **En el teléfono, el micrófono del teclado del sistema** escribe en el campo del buscador como
  cualquier texto, y los términos en español («refrigerado», «peligrosa») salen tal cual. No agrego
  variantes como «rífer» sin haberlas visto en una transcripción real: sería inventar.
- `VoiceSearchField` y la búsqueda por OR no cambian.

#### 1.3.6 Un filtro de carga especial en la Lista: mi recomendación

- **Recomiendo sí,** como tercera fila, **«Carga especial»**, con el mismo componente: «Peligrosa
  IMDG 5», «Refrigerado 12» y «Fuera de medida 2», cada una con su ícono del paquete (13.11), sus
  cuentas cruzadas con las otras dos filas y la misma regla que el buscador (varias, cualquiera de
  ellas). Solo las que tienen carga; sin ninguna, la fila no sale.
- **Por qué:** la ronda de revisión se hace mejor en la Lista que en el buscador: la Lista trae la
  tarjeta completa con la celda, se cruza con el destino («los refrigerados de GTSTC») y se vuelve a
  ella por la pestaña. El buscador queda para encontrar rápido.
- **El costo:** 1.5 h más, unas 10 pruebas, y una fila más de chips en el teléfono (con
  `BsFichasEnLineas` caben en una línea a 360 dp con la letra a 1.0; a 2.0, en dos).
- **De paso, la tarjeta de la Lista** dice «Peligrosa IMDG», «Refrigerado» y «Fuera de medida» en sus
  chips de abajo, en vez de «IMDG» y «OOG»: 15.5 ya dice que son los nombres de la Lista, y el
  buscador los usa. Son tres cadenas. Decide Carlos (D1).

### 1.4 La Lista perezosa (P10)

#### 1.4.1 El diseño

- **La pestaña pasa de `SingleChildScrollView` + `Column` a un `CustomScrollView`** con el mismo
  relleno de 16 dp:
  1. un `SliverToBoxAdapter` con lo de arriba, igual que hoy: el resumen del viaje, los botones, las
     celdas reservadas, las filas de filtros y el título con sus cifras y «Quitar filtros»;
  2. un **`SliverList.builder`** con las tarjetas, que solo construye las que se ven y las de su
     margen de caché.
- **Las tarjetas no cambian.** `ContainersListView` se queda como está para los lugares que la
  montan sola (las pruebas de T-90, T-104, T-114, T-143 y T-144, y `tool/t90_main.dart`), y suma
  `ContainersSliverList`, en el mismo archivo y con la misma `_ContainerCard`. Cada tarjeta lleva la
  clave de su matrícula, para que al cambiar el filtro Flutter no confunda una con otra.
- **Lo de arriba no se fija:** se desplaza con la lista, como hoy. Fijar el título con «Quitar filtros»
  pediría una cabecera de alto fijo, y con la letra a 2.0 no lo tiene. Queda como mejora posible.
- **El desplazamiento:** el mismo de siempre, una sola columna; en escritorio, con su barra (la de
  Flutter para un desplazable principal) y con las teclas de página. Al cambiar un filtro, la lista
  no salta: lo de arriba se queda donde estaba.
- **El vacío** (1.1.1) es un `SliverFillRemaining` con el mensaje.

#### 1.4.2 Lo que cambia para el lector de pantalla

- **Hoy las 977 tarjetas están en el árbol accesible a la vez.** Con la lista perezosa, solo las que
  se ven y las de la caché. El desplazable declara cuántas son (`semanticChildCount`), así que
  TalkBack dice «elemento 3 de 977» y se desplaza solo al avanzar; en Windows, el desplazable expone
  las acciones de desplazar.
- **Lo que se pierde:** en el modo de lectura de Narrador, saltar a la tarjeta 900 sin desplazarse.
  Para eso están los filtros, el buscador y RF-018.
- Lo compruebo en el árbol de Windows y en la Web (Chrome) del banco, arriba y al final de la lista.

#### 1.4.3 Cómo se mide, antes y después

- **El instrumento, sin tocarlo:** `tool/t114_ram_windows.ps1`, que orquesta `tool/t99_ram_windows.ps1`
  (acción `seguir`: cinco lecturas de `WorkingSet64` tras 5 s de reposo en cada paso) con el
  escenario `ram` de `tool/t99_conductor.dart` (cargar, el plano, cada bahía, Estadísticas, buscar y
  volver a la Lista), y `tool/t99_ram_resumen.dart`. Es el mismo con que se midieron los 510 MB en
  `REDISENO-RESULTADOS.md` 4.7, así que las cifras se comparan. El conductor no depende de lo que
  muestra la Lista, solo toca su pestaña.
- **Los dos bancos:** «antes», compilado de `899e4e3` (una copia hecha con `git archive`, que solo
  lee); «después», del árbol con T-120 (`tool/t99_copia.ps1`). Los dos con `-t tool/t99_main.dart`,
  en `%TEMP%`, con la identidad `r4` y sus almacenes en `%TEMP%`, abiertos con `explorer.exe`.
  **No son Releases de publicación:** son bancos, como los de T-99 y T-114. Antes de medir compruebo
  que el banco redirige todos los almacenes, también el de la sesión (10.135).
- **Los archivos sintéticos:** `T99_SINTETICO_977.edi` (el tamaño de A01) y el de **5 000**, para ver
  si la Lista sigue creciendo unos 0.35 MB por contenedor (T-99, B.3). Los genera
  `tool/t99_sintetico.dart` en `%TEMP%`; nada del corpus.
- **Las corridas:** seis por banco y por archivo; la primera, en frío, se descarta. Cuatro series,
  unos 75 minutos de máquina.
- **El umbral y lo que digo:** el de RNF-001, < 200 MB (SI), estable, en el paso de la Lista. Lo
  que espero, y lo diré con lo que salga: que la Lista quede al nivel de los demás pasos (≈ 190 MB
  con 977, dentro del ruido de ± 15 MB), y que con 5 000 deje de crecer con el número de
  contenedores. **No dictamino RNF-001 ni RNF-007:** eso es del bloque 3, con sus buques sintéticos.
- **Además, una prueba de widgets** que cuenta cuántas tarjetas se construyen con 977 contenedores a
  1366 × 690: arriba, y después de saltar al final. Hoy son 977; con la lista perezosa, unas decenas.
  Es la prueba de estructura; la RAM es la del efecto.
- **SEMÁFORO:** las cuatro series van en una ventana propia, sin otro Flutter en la máquina.
- **El Honor solo si Carlos lo reserva** (con `tool/t99_ram_honor.ps1`, A01 y 5 000, sin
  `flutter run`, `install` ni `adb install`: el APK lo instala Carlos). Si no, queda anotado.

### 1.5 El pellizco

#### 1.5.1 O-119-1: una prueba que hoy falle

- **Lo que dice Codex (10.81):** al pellizcar desde el 100 %, justo cuando la bahía deja de caber
  centrada, la celda se corre hasta 1.9 dp en Chrome y 1.4 en Edge; ya desbordada, 0.06; con
  Ctrl + rueda en el mismo cruce, 0.43.
- **Por qué la prueba de T-119 no lo vio:** cubre el pellizco del touchpad solo con la bahía ya
  desbordada (`t119_mouse_touchpad_test.dart:361`), y el cruce solo con un paso grande de Ctrl + rueda
  (`:337`) y una tolerancia de 1 dp.
- **La hipótesis, que la prueba confirma o tumba:** en `_dejarQuieto`
  (`plan_drag_confirmation.dart:127-161`), el destino nuevo del desplazamiento horizontal se pone con
  `jumpTo` **antes** del cuadro con la escala nueva. En el cruce, el alcance de antes es 0 (la bahía
  cabía), así que el destino queda fuera de él. `jumpTo` termina en `goBallistic(0)`, y la física de
  escritorio (`ClampingScrollPhysics`) arma un resorte de vuelta al borde viejo: en el cuadro
  siguiente el resorte avanza un poco **antes** de que se mida el alcance nuevo. El pellizco de Chrome
  llega en muchos pasos chicos (`PointerScaleEvent`), y cada uno empuja otra vez. La columna, en
  vertical, puede tener lo mismo cuando el destino pasa de su alcance de antes.
- **Las pruebas nuevas** (`test/t120_pellizco_test.dart`), en Windows con las fuentes del producto y el
  plano sintético de T-117, como T-119:
  1. al 100 % la bahía cabe centrada; un pellizco del touchpad en pasos de 1 % (de 1.00 a 1.30)
     sobre una celda; tras **cada** paso, un cuadro, y al final, que se asiente todo: la celda,
     a menos de **0.25 dp** de donde estaba, en cada cuadro y al final;
  2. lo mismo con `PointerScaleEvent` de 1.02 (el pellizco de la Web);
  3. lo mismo alejando, de vuelta al cruce desde el otro lado.
  Las corro contra el código de hoy en una copia de `%TEMP%`, como en T-119. **Si no salen rojas,
  me detengo y lo digo** antes de cambiar nada: querría decir que lo de Chrome no está en el código
  de Dart, y la prueba en el navegador manda.
- **El cambio, si la hipótesis se confirma:** el destino no se pone con `jumpTo` fuera del alcance de
  ese momento. Queda pendiente y se aplica cuando el desplazamiento ya midió el alcance nuevo, con
  `correctPixels`, sin animación ni resorte (en el `ScrollPosition` del controlador de la rejilla, que
  ya es de la barra, y en la columna). Lo que ya está dentro del alcance sigue como hoy.

#### 1.5.2 O-128-4: que el plano suelte el pellizco cuando pierde el foco

- **El riesgo:** si un pellizco del touchpad empieza y la ventana pierde el foco antes de su
  `PointerPanZoomEnd` (Alt + Tab, un aviso del sistema), `_pellizcando` se queda en verdadero y la
  rejilla y la columna, congeladas (`NeverScrollableScrollPhysics` y `pellizcoDelPlanoProvider`).
  Lo mismo con dos dedos en la pantalla si nunca llega su `PointerUp`.
- **El cambio:** `_PlanZoomViewportState` escucha el ciclo de vida (`AppLifecycleListener`). Al pasar a
  `inactive`, `hidden` o `paused` (en Windows, perder el foco de la ventana es `inactive`) **suelta
  todo:** la escala del touchpad, el pellizco de la columna (`terminar()`) y los contactos de la
  pantalla. Y un `PointerPanZoomStart` nuevo con un gesto viejo abierto lo cierra antes de empezar.
- **Cómo se prueba sin su evento final:** se manda el `panZoomStart` y un `panZoomUpdate` de 1.2 (el
  pellizco empieza y la columna queda congelada), y **no** el `panZoomEnd`; después,
  `tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive)`. Se espera que
  `pellizcoDelPlanoProvider` quede apagado, que la rueda vuelva a mover la columna y que los dos
  dedos vuelvan a desplazar la rejilla. Lo mismo con dos contactos sin `up`. Y, contra el código de
  hoy, la columna sigue congelada: la prueba sale roja.
- **En la Web**, que perder el foco de la pestaña llegue como `inactive` lo compruebo en Chrome, en el
  banco Web con un perfil nuevo (10.142). Si no llega, lo digo y lo anoto; no invento otra señal.

### 1.6 O1 y O2

#### 1.6.1 O2: los segmentos de `BsSelectorDeModo` repiten su nombre en Windows

- **La causa** (C2.9): cada `ButtonSegment` lleva `tooltip: entrada.descripcion`, que empieza por el
  mismo nombre (`bs_selector_de_modo.dart:148` y `:56-60`). En Windows el nombre es la etiqueta más
  la descripción emergente: «botón Destino. Destino. El puerto de descarga…».
- **El cambio:** el segmento sin `tooltip`; su rótulo envuelto en un `Tooltip` con
  `excludeFromSemantics` (la misma descripción con el mouse) y en un `Semantics` con la etiqueta
  entera («Descarga, 28 por bajar en GTSTC»: el nombre y la cuenta completa, no la corta) y la ayuda
  como **pista** (`hint`), que Windows da como descripción y no como nombre. Es lo que se hizo con
  «Acciones» en la 10.45.
- **El riesgo sobre lo aceptado:** solo cambia la semántica del componente; la geometría no se mueve,
  así que la matriz de 90 combinaciones no cambia. En el árbol de Windows cambian los segmentos y nada
  más: lo compruebo comparando el árbol antes y después en un banco `r4` abierto con `explorer.exe`,
  como en C2.7. La prueba nueva exige que cada segmento diga su nombre una sola vez (el patrón de
  `t117_correccion2_test.dart`) y que la ayuda no esté en el nombre.
- **Recomiendo hacerlo aquí:** es chico, está aislado y sus pruebas son las de la 10.45.

#### 1.6.2 O1: a 800 × 600 con la letra a 2.0, en Contenido, la franja pasa de 126 a 178 dp

- **La causa,** en la variante que envuelve de `franjas_del_plano.dart:163-198`: la navegación con las
  cifras, «Colorear por» con su menú y los controles van como tres piezas del `Wrap`, y a ese ancho
  caen en tres líneas; antes de T-117 eran dos.
- **Lo que haría:** en esa variante, probar primero sin el rótulo «Colorear por» (que seguiría en la
  etiqueta y en la descripción emergente del selector, como sugería C1.8) y quedarse con la que dé
  menos líneas.
- **El riesgo:** cambia la elección de la franja en algunas de las 90 combinaciones de la matriz de
  Codex, que hay que volver a medir y a aceptar entera, junto con el árbol de Windows, porque el
  rótulo desaparece en esas combinaciones. Es P3: se trabaja desplazando la columna o plegando el
  puente.
- **Recomiendo dejarlo para el frente de usabilidad** (10.117), que rehace la cabecera y la franja
  (14.8 ya lo anuncia): arreglarlo aquí y otra vez allá es dos vueltas de la matriz. Si Carlos lo
  quiere aquí, son 3 h más en la entrega 2 (D2).

### 1.7 Los dos monitores

Carlos tiene el segundo monitor. Nunca se probó (10.46).

- **Qué se prueba:** que al arrastrar la ventana de la laptop (1920 × 1080 al 125 %) al otro monitor,
  y de vuelta, **nada se corta ni se deforma**, y que el estado se queda: el puente en su altura, el
  panel lateral (fijo, oculto o flotante, según el ancho que resulte), la bahía, el zoom y los
  desplazamientos de la rejilla, de la Lista y de Estadísticas. Sobre todo si el otro monitor tiene
  otra escala (100 %): Flutter cambia la relación de píxeles y vuelve a disponer todo.
- **Cómo:**
  1. un banco `r4` de Windows en **depuración** (para que un desborde salga en la consola), con sus
     almacenes en `%TEMP%`, abierto con `explorer.exe` y con el plano sintético `T100_LLEGADA`;
  2. un script, `tool/t120_monitores.ps1`, que en cada paso anota de la ventana del banco (por su PID,
     nada más) el monitor, el DPI (`GetDpiForWindow`), el rectángulo del cliente y una captura
     (`PrintWindow`);
  3. **Carlos arrastra**, porque es un gesto físico: el Plano maximizado en la laptop con el zoom a
     150 % y la rejilla desplazada → al otro monitor → maximizar allí (Win + Mayús + →) → media
     pantalla (Win + ← y →) → a medias entre los dos → de vuelta. Lo mismo en la Lista desplazada a
     la mitad y en Estadísticas;
  4. yo anoto, comparo y reviso la consola.
- **Unos 30 minutos de Carlos,** en la entrega 2, cuando él diga. La evidencia va a `build/t120/`.

### 1.8 Las entregas

**Recomiendo dos entregas, cada una con su aceptación, en este orden** (un carril de `lib/` a la vez):

| Entrega | Qué lleva | Horas |
|---|---|---|
| **1 · La Lista y el buscador** | El filtro por destino con sus cuentas cruzadas (4.5 h); de Estadísticas a la Lista (1.5); RF-018 (3); la fila de carga especial y los nombres de la tarjeta, si se aprueban (1.5); la Lista perezosa (1.5); la medición antes y después (2.5, casi todo de máquina); la matriz de pruebas, la suite, `analyze` en las dos copias, `DESIGN.md` y el informe (3) | **15.5 a 17** |
| **2 · El plano y la oficina** | O-119-1 (2 h); O-128-4 (1.5); O2 con el árbol de Windows (1.5); los dos monitores (1, con Carlos); la suite, `analyze`, `DESIGN.md` y el informe (2) | **8** (11 con O1) |

- **Por qué en dos:** son pantallas distintas, con riesgos distintos. La 1 es lo grande del requisito y
  lleva la medición; la 2 toca el plano aceptado en T-119 y la oficina aceptada en la entrega 1. Si van
  juntas, un hallazgo en una detiene la otra.
- **Por qué la Lista primero:** RF-018 es el requisito y la Lista es la que pasa del umbral de memoria;
  y la entrega 2 es la que necesita a Carlos (los monitores).

### 1.9 Las pruebas

**Lo nuevo** (calculo unas 70):

| Archivo | Qué comprueba |
|---|---|
| `test/t120_filtros_lista_test.dart` | Las cuentas cruzadas en una pasada (con vacíos asignados y sin destino); los dos filtros juntos; «Quitar filtros»; el título; el vacío con filtros; el orden; los chips en cero; que se limpie al abrir otro viaje, en el previo y al venir de Alertas; la semántica de los chips |
| `test/t120_filtros_matriz_test.dart` | Con las fuentes del producto: 360 y 600 dp (el teléfono), 800, 1366 y 1920 (la oficina), con la letra a 1.0, 1.45 y 2.0: nada desbordado ni cortado, las dos líneas y «Ver los n» en el teléfono, el elegido a la vista, la hoja |
| `test/t120_estadisticas_a_lista_test.dart` | Tocar un puerto, «Sin puerto» y «Otros» (que no se toca); la naviera se suelta; Atrás vuelve una vez; el teclado; la etiqueta, una sola vez; los desplazamientos recordados |
| `test/t120_busqueda_carga_especial_test.dart` | `interpretar` y `coincide` en Dart puro: cada término, las tildes y mayúsculas, la frase, la clase IMO, el número ONU, la unión de categorías, el resto; y en el buscador: la línea de arriba, la señal de cada resultado, el resaltado del resto, las sugerencias; una consulta sin términos, igual que hoy |
| `test/t120_lista_perezosa_test.dart` | Cuántas tarjetas se construyen con 977 (arriba y al final); el desplazamiento; `semanticChildCount`; que un filtro no haga saltar la lista |
| `test/t120_pellizco_test.dart` | O-119-1 (las tres de 1.5.1) y O-128-4 (las dos de 1.5.2) |
| `test/t120_selector_nombre_test.dart` | O2: cada segmento dice su nombre una vez y la ayuda va como pista |

- **Rojas antes:** las de comportamiento nuevo se corren contra `899e4e3` en una copia de `%TEMP%`, con
  los archivos de `lib/` devueltos a `HEAD` por `git show` (que solo lee), como en T-119; cada una
  tiene que fallar en su comprobación, no al compilar. Las de estructura que no compilan contra el
  código de antes (porque usan piezas nuevas) se dicen aparte.
- **La suite completa,** en una sola corrida, al final de cada entrega: **el piso es 2227 y solo sube,
  sin omitidas ni fallidas.** Nunca `flutter test --platform chrome`.
- **`analyze` en cero** en todo el paquete, en la carpeta y en una copia limpia, sin `// ignore:`; si la
  copia marca algo que la carpeta no, se repite con `dart analyze --cache` en una carpeta nueva y se
  guardan los dos registros (10.141).
- **Lo que repite quien acepte,** con su evidencia guardada:
  - la suite y `analyze` en una copia limpia;
  - los archivos `t120_*` y las rojas contra `899e4e3`;
  - entrega 1: la Lista y el buscador **a la vista** en la Web del banco (perfil nuevo de Chrome) y en
    Windows, a 360 y a 1366 dp, con la letra a 1.0 y 2.0: los filtros, «Ver los n», de Estadísticas a
    la Lista y atrás, «reefer», «imo 3» y «oog»; y los resúmenes de RAM (no hace falta repetir las 24
    corridas: basta una por banco con 977 para ver el mismo orden de magnitud);
  - entrega 2: el pellizco y Alt + Tab con el touchpad en Windows y en Chrome; el árbol de Windows de
    los segmentos; las capturas y el registro de los monitores.

### 1.10 Los archivos

**Entrega 1:**
- `lib/features/vessel/presentation/pages/vessel_overview_page.dart`: la pestaña de la Lista
  (`CustomScrollView`), las filas, el título, «Quitar filtros», el paso desde Estadísticas, Atrás y
  la limpieza en `_openAlerts`.
- `lib/features/vessel/presentation/widgets/containers_list_view.dart`: `ContainersSliverList`, el
  vacío con filtros y los nombres de los chips de la tarjeta (si D1).
- `lib/features/vessel/presentation/widgets/filtros_de_la_lista.dart` (nuevo): las filas, los chips y la
  hoja.
- `lib/features/vessel/presentation/providers/vessel_providers.dart`: `selectedDischargePortProvider` y
  su limpieza.
- `lib/features/vessel/presentation/providers/loading_operation_provider.dart`: el filtro doble (o
  triple) y `cuentasDeLosFiltrosProvider`.
- `lib/features/vessel/presentation/formatters/consulta_de_busqueda.dart` (nuevo).
- `lib/features/vessel/presentation/widgets/container_search_delegate.dart`: RF-018 y los textos.
- `lib/features/vessel/presentation/widgets/voyage_stats_view.dart`: el puerto que se toca y el
  `PageStorageKey`.
- `lib/core/design/componentes/bs_barra_de_magnitud.dart`: `alTocar`.
- `lib/core/design/componentes/bs_fichas_en_lineas.dart` (nuevo) y `lib/core/design/design.dart` (su
  exportación).
- Las pruebas `t120_*` de la entrega 1, y una línea de `test/t144_lector_volcado_test.dart` (el texto de
  ayuda).
- `DESIGN.md` y este informe.

**Entrega 2:**
- `lib/features/vessel/presentation/widgets/plan_drag_confirmation.dart` (`PlanZoomViewport`).
- `lib/core/design/componentes/bs_selector_de_modo.dart`.
- `test/t120_pellizco_test.dart`, `test/t120_selector_nombre_test.dart`, `tool/t120_monitores.ps1`.
- `DESIGN.md` y este informe.

**No cambian:** `domain/`, `data/`, `pubspec.yaml`, `pubspec.lock`, `lib/main.dart`, los congelados,
las opciones de Firebase, `firestore.rules`, `web/`, `windows/`, la versión (`1.0.1+10`) y el manual de
la 1.0.1. Nada de esto exige tocar `domain/` ni `data/`: las tres banderas y las medidas ya están en
`ContainerUnit`.

### 1.11 `DESIGN.md` y el manual

**`DESIGN.md`:**
- **una sección nueva, 18, «La Lista y el buscador (T-120)»:** los filtros (lo de 1.1, con los
  wireframes), `BsFichasEnLineas` y su API, la Lista perezosa y lo que cambia para el lector de
  pantalla, los términos de RF-018 con su tabla, lo que dice el resultado y la fila de carga especial;
- **15.5:** tocar un puerto abre la Lista, y `BsBarraDeMagnitud` gana `alTocar` (15.10);
- **14.6** (entrega 2): la semántica de los segmentos (O2);
- **16.2 y 16.3** (entrega 2): el destino pendiente en el cruce (O-119-1) y el ciclo de vida (O-128-4);
- **14.9** (entrega 2): lo que se vio con los dos monitores.

**El manual, en la versión siguiente** (el de la 1.0.1 no se toca):
- **5.1 La búsqueda:** los términos de carga especial, la línea de arriba, la señal de cada resultado y
  la sección «Carga especial» del estado vacío; una figura nueva con «reefer».
- **5.2 La Lista:** los dos filtros (o tres), las cuentas cruzadas, «Quitar filtros», «Ver los n» en el
  teléfono; la figura de la Lista, nueva.
- **6.1 Estadísticas:** tocar un puerto abre la Lista filtrada; Atrás vuelve.
- **11 Glosario:** «OOG» y «fuera de medida», y que «reefer», «imo» y «oog» se buscan.

---

## 2. Lo que decide Carlos

| | Pregunta | Recomiendo |
|---|---|---|
| **D1** | ¿La fila «Carga especial» en la Lista (1.3.6), con los nombres de la tarjeta al día? | **Sí** (1.5 h) |
| **D2** | ¿O1 aquí o con el frente de usabilidad (1.6.2)? | **Con el frente de usabilidad** |
| **D3** | ¿Las navieras, de más a menos, como los destinos (1.1.1)? | **Sí** |
| **D4** | ¿Dos entregas, la Lista primero (1.8)? | **Sí** |
| **D5** | ¿Se mide también en el Honor (1.4.3)? | Solo si lo reservas; si no, queda anotado |
| **D6** | ¿«Sin destino» en la Lista y «Sin puerto» en Estadísticas, cada uno en su pantalla (1.1.6)? | **Sí** |
| **D7** | ¿Varias categorías en el buscador son «cualquiera de ellas», y el resto se cumple además (1.3.2)? | **Sí** |
| **D8** | Visto y **fuera del alcance**: la hoja de detalle de la Lista (`containers_list_view.dart:416-540`) dice «N/A», «Puerto Carga» y «MERCANCÍA PELIGROSA», contra las reglas 3 y 4. ¿Se deja para el rediseño de oro? | **Sí, dejarla:** no es de T-120 |

## 3. Horas de esta fase

Del reloj: de las 21:25 a las 21:42 del 17-nov, unos 20 minutos (las lecturas, el paso 0 con su
ventana de Flutter de un minuto y esta propuesta).

## 4. Git

Para que lo ejecute Carlos. Solo este informe; nada de `lib/`, `test/` ni `pubspec.*` cambió.

```powershell
git add -- docs/T120-RESULTADOS.md
git commit -m "Sprint 4: T-120, la propuesta de la Lista y el buscador"
git push
```

## 5. Mensaje para Yov

> Yov, la propuesta de T-120 está en `docs/T120-RESULTADOS.md` (paso 0 y fase 1). La punta es
> `899e4e3`, con la 10.146; `pub get` no movió el lock y `analyze` dio cero. De la 0.8 casi todo sigue
> igual: la Lista, los chips con desplazamiento horizontal, «Filtrar por Naviera», las cuentas por chip
> y el `ListView` con `shrinkWrap`; cambió dónde vive el filtro (`loading_operation_provider.dart`,
> sobre lo que va a bordo desde T-122) y ya existe la ficha del puerto (`BsCajaDeCodigo`). Propongo
> dos entregas: la Lista y el buscador (15.5 a 17 h), con RF-018 en Dart puro y la Lista perezosa
> medida con `t114_ram_windows.ps1` y 977 y 5 000 contenedores; y el plano y la oficina (8 h), con
> una hipótesis para O-119-1 (un `jumpTo` fuera del alcance arma un resorte) que una prueba roja tiene
> que confirmar antes de cambiar nada. Recomiendo O2 aquí y O1 con el frente de usabilidad. Carlos
> tiene el segundo monitor. Quedan ocho decisiones para Carlos en la sección 2.

**ALTO: Yov revisa y Carlos aprueba.**
