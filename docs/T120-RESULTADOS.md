# T-120 · La Lista y el buscador: filtrar por destino y buscar por carga especial (RF-018) · Resultados

Timonel (Claude Code, Claude Opus 5.5). Rama `sprint-4`, carpeta del rediseño
(`C:\Proyectos\baystream-rediseno`). Ficha de la tarea: 10.146 de `SPRINT-4.md`. Lo acepta GLM 5.3
Flash, en Max (10.137).

- **Fase 1, la propuesta** (secciones 0 a 3), sobre `899e4e3`: subida en `9ec86b9` y revisada en la
  10.147. **Carlos la aprobó en la 10.148** con las ocho respuestas de la sección 2 y los cinco puntos
  de Yov (1.0).
- **Entrega 1, la Lista y el buscador** (secciones 6 a 15), sobre `732334d` (la 10.148): lo hecho, las
  validaciones, los archivos, el bloque de Git y el mensaje para Yov. Termina en «ALTO: Yov revisa y
  GLM acepta».
- **Corrección 1 de la entrega 1** (al final), sobre `d182649` (la 10.149): R1 a R4, D9 y D10.
- **La entrega 2, el plano y la oficina** (O-119-1, O-128-4, O2 y los dos monitores), empieza cuando
  GLM acepte la 1.

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
- La fuente de RF-018 es `docs/entrega-7nov/fuentes/DOC2.md`, la tabla «RF‑018» (escrita con el
  guion que no parte la línea; por eso no la encontré en la fase 1, 10.147, punto 4). Su historia:
  «Como planificador quiero listar todos los reefer o IMDG del viaje para hacer la ronda de
  revisión»; su criterio: «Los términos "reefer", "imo" y "oog" filtran los resultados del
  buscador». La carpeta no tiene seguimiento: solo la leí.

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

### 1.0 Lo aprobado (10.148)

Carlos la aprobó el 17-nov a las 21:50. Lo que cambió respecto de lo propuesto abajo, y manda:

- **D1:** sí a la fila «Carga especial» (1.3.6), con los nombres de la tarjeta al día.
- **D2:** O1 va con el frente de usabilidad; T-120 no lo toca (1.6.2).
- **D3:** las navieras, de más a menos, **con el orden fijo por el total del viaje**.
- **D4:** dos entregas, cada una con su aceptación; primero la Lista y el buscador.
- **D5:** no se mide en el Honor; el teléfono se mide en el bloque 3.
- **D6: un solo nombre, «Sin destino», en la Lista y en Estadísticas**, donde decía «Sin puerto»
  (cambia 1.1.6, punto 6).
- **D7:** varias cargas son «cualquiera de ellas», y el resto se cumple además.
- **D8:** el rediseño de la hoja de detalle de la Lista es O-120-1, del bloque 4. Aquí, solo dos
  renglones: las medidas del fuera de medida y «El archivo no trae temperatura» en vez de «N/A°C».
- **Los cinco puntos de Yov (10.147):** (1) el orden de los chips no cambia al elegir el otro filtro;
  (2) el elegido se distingue sin depender solo del color, de día y de noche; (3) `BsFichasEnLineas`
  entra como pieza de la biblioteca, con vista previa, documentación y prueba, y la vista previa de
  `BsBarraDeMagnitud` enseña la barra que se toca; (4) la fuente de RF-018 es `DOC2.md`; (5) la copia
  de «antes» con `git archive` vale.

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

## 2. Lo que decidió Carlos (10.148)

| | Pregunta | Recomendé | Decidió Carlos |
|---|---|---|---|
| **D1** | ¿La fila «Carga especial» en la Lista? | Sí | **Sí**, con los nombres de la tarjeta |
| **D2** | ¿O1 aquí o con el frente de usabilidad? | Con el frente | **Con el frente** |
| **D3** | ¿Las navieras de más a menos? | Sí | **Sí**, con el orden fijo |
| **D4** | ¿Dos entregas, la Lista primero? | Sí | **Sí** |
| **D5** | ¿Se mide en el Honor? | Si lo reservas | **No**: bloque 3 |
| **D6** | ¿«Sin destino» y «Sin puerto», cada uno en su pantalla? | Sí | **No: «Sin destino» en las dos** |
| **D7** | ¿Varias cargas son cualquiera de ellas? | Sí | **Sí** |
| **D8** | ¿La hoja de detalle de la Lista se deja? | Dejarla | **O-120-1, bloque 4; aquí, dos renglones** |

## 3. Horas de la fase 1

Del reloj: de las 21:25 a las 21:42 del 17-nov, unos 20 minutos. Su bloque de Git se subió en
`9ec86b9`.

---

## 6. Entrega 1 · La Lista y el buscador (17-nov)

### 6.1 Resultado en tres líneas

- **La Lista filtra por naviera, destino y carga especial**, con cuentas cruzadas en una pasada, el
  orden fijo por el total del viaje, «Sin destino», «Quitar filtros», «Ver los n» en el teléfono y el
  elegido que se distingue sin el color; desde Estadísticas, tocar un puerto abre la Lista filtrada y
  Atrás vuelve una vez.
- **RF-018:** el buscador entiende «reefer», «imo» y «oog» y sus equivalentes en español, la clase IMO
  y el número ONU; dice lo que entendió y por qué salió cada resultado, y el resto se busca como
  siempre.
- **La Lista es perezosa** (P10): con 977 contenedores construye unas decenas de tarjetas en vez de
  las 977; la memoria, medida antes y después con los instrumentos de T-99, está en 7.

### 6.2 Base, luz verde y lo que se corrió

- **La punta era `732334d`**, con la 10.147 y la 10.148 (`git log --oneline -5`, `git show --stat
  HEAD`). El árbol traía lo de siempre que no es mío: los cuatro archivos que solo difieren en el fin
  de línea y las carpetas sin seguimiento de `docs/`. No los toqué y no van en el bloque.
- **Carlos dio dos luces verdes:** una ventana de Flutter abierta mientras programaba (17-nov, hacia las 22:05)
  y la ventana de medición (hacia las 22:40). Cada una empezó y terminó con su línea `SEMÁFORO:`, y nunca corrí
  dos comandos de Flutter o de Dart a la vez.
- **No compilé ninguna Release de publicación, no cambié la versión (`1.0.1+10`) y no publiqué.** Los
  dos bancos de la medición son compilaciones del banco de T-99 en `%TEMP%` (7.1).
- No toqué Firebase, el almacén real, la MSIX de Carlos ni el Honor.

### 6.3 Lo hecho

**Los filtros de la Lista** (`DESIGN.md` 18.1 a 18.3):
- `CuentasDeLosFiltros` (`formatters/cuentas_de_los_filtros.dart`, Dart puro) recorre lo que va a
  bordo una sola vez y da, para cada chip, la cuenta con los otros dos filtros y el total del viaje,
  que fija el orden; también lo que pasa los tres filtros. `FiltrosDeLaLista` lleva lo elegido y la
  regla de «Sin destino» (sin `LOC+11` o con el código en blanco).
- `selectedDischargePortProvider` y `selectedSpecialCargoProvider` (`vessel_providers.dart`), con la
  forma de `selectedCarrierProvider`, que no cambia. Se sueltan donde se soltaba la naviera: el previo,
  abrir un viaje guardado y el salto de Alertas a una celda.
- `filtrosDeLaListaProvider`, `cuentasDeLosFiltrosProvider` y `filteredContainersProvider`, que ahora
  filtra por los tres (`loading_operation_provider.dart`). `carriersListProvider` se queda.
- `FilasDeFiltros` y `TituloDeLaLista` (`widgets/filtros_de_la_lista.dart`): las tres filas, en tabla en
  la oficina y en `BsFichasEnLineas` en el teléfono, la hoja de «Ver los n», el chip (borde de 2 dp en
  la tinta y texto en negrita cuando está elegido; un chip en cero, apagado), el título con lo que
  filtra, la concordancia de «1 lleno», y «Quitar filtros».
- **`BsFichasEnLineas`** (`lib/core/design/componentes/bs_fichas_en_lineas.dart`), una pieza de la
  biblioteca con su vista previa («Fichas en líneas»), su documentación (18.3) y su prueba.
- La tarjeta dice «Peligrosa IMDG», «Refrigerado» y «Fuera de medida» (D1); con el nombre más largo,
  su chip envuelve en vez de desbordarse a 360 dp con la letra a 2.0. Su hoja suma los dos renglones de
  D8.

**De Estadísticas a la Lista** (18.5):
- `BsBarraDeMagnitud` gana `alTocar` y `ayudaAlTocar`: la barra entera es un botón con zona táctil de
  48 dp, Intro y espacio, foco visible y su nombre una vez. Su vista previa enseña la barra de PAMIT
  como la que se toca.
- `VoyageStatsView` gana `onPuerto`; en el panel de puertos, cada puerto y «Sin destino» abren la
  Lista; «Otros N puertos» no. La página suelta la naviera y la carga especial, pone el destino, deja
  la Lista arriba y anota «volver a Estadísticas» para Atrás; lo olvida si cambia la pestaña o el
  filtro.
- **D6:** `EstadisticasDelViaje.sinPuerto` pasa a `sinDestino` («Sin destino»), y un código en blanco
  también cuenta ahí, como en la Lista. Cambia una línea de `t121_estadisticas_test.dart` y `DESIGN.md`
  15.5, 15.8 y 15.11.
- Las dos pantallas recuerdan dónde estaban: la Lista con su propio controlador (para que, desde
  Estadísticas, empiece arriba sin un cuadro en el lugar viejo) y Estadísticas con un `PageStorageKey`
  alrededor de su desplazable, que conserva la clave `estadisticas-scroll` que usan el conductor de
  T-99 y las pruebas de T-121.

**RF-018** (18.6):
- `ConsultaDeBusqueda` y `CargaEspecial` (`formatters/consulta_de_busqueda.dart`, Dart puro): los
  términos como palabras enteras, sin mayúsculas ni tildes; la frase «fuera de medida»; la clase («imo
  3», «imdg 3», «imo3», «clase 3»; «imo 2» da la 2.1) y el número ONU («un 1993», «onu 1993»); varias
  cargas, cualquiera de ellas; el resto, como siempre. También la línea de lo que se entendió y el
  motivo de cada resultado.
- En `ContainerSearchDelegate`: los resultados con su línea y sus motivos, el resaltado con el resto,
  la sección «Carga especial» sin escribir nada y los textos nuevos del campo y la ayuda. La línea de
  `t144_lector_volcado_test.dart` que buscaba la ayuda vieja se pone al día.

**La Lista perezosa** (18.4): la pestaña es un `CustomScrollView` con lo de arriba en un
`SliverToBoxAdapter` y las tarjetas en `ContainersSliverList` (`SliverList.builder`, cada tarjeta con
la clave de su matrícula y `findChildIndexCallback`). Declara `semanticChildCount`. `ContainersListView`
se queda para donde se monta sola.

**Lo que cambió respecto de la propuesta** (además de lo de 1.0):
1. **La carga especial no lleva «Todas»:** se eligen varias, y soltarlas todas es lo mismo que no
   filtrar.
2. **Estadísticas recuerda su desplazamiento con un `PageStorageKey` por fuera**, no en el
   desplazable: cambiarle la clave rompía el conductor de T-99 y las pruebas de T-121.
3. **La Lista recuerda el suyo con un controlador propio**, no con `PageStorage`: así, al llegar desde
   Estadísticas, empieza arriba en el mismo cuadro.
4. **Una prueba de T-114 gana una línea:** `t114_fase3_inicio_test.dart` desplazaba la Lista con
   `ensureVisible` y tocaba «Alertas de estiba» en el mismo cuadro. Con el `SingleChildScrollView` de
   antes eso alcanzaba, porque su desplazamiento se aplica al pintar; con los slivers de la Lista
   perezosa hay que dejar pasar el cuadro. Se suma un `pumpAndSettle` con su comentario.
5. **El contraste de los chips en la vista previa nocturna se mide aparte** (8.2).

### 6.4 Las pruebas nuevas (99)

| Archivo | Pruebas | Qué comprueba |
|---|---:|---|
| `t120_busqueda_carga_especial_test.dart` | 33 | Los 18 términos, tildes y mayúsculas, palabras enteras, la clase, el número ONU, varias cargas y el resto; lo que sale; que sin términos la búsqueda es la de antes; la línea de arriba y los motivos |
| `t120_buscador_test.dart` | 6 | En el buscador: «reefer», «imo» y «oog» filtran; la línea y los motivos; el resaltado del resto; nada resaltado con solo carga; las sugerencias; el campo |
| `t120_filtros_lista_test.dart` | 20 | Las cuentas a mano contra las cruzadas; el orden fijo; los chips en cero; la carga especial; «Sin destino»; en la Lista, las tres filas, el título, «Quitar filtros», el orden que no cambia, el elegido sin el color y su texto a 4.5:1 contra su fondo, de día y de noche (8.1), la semántica, el vacío con filtros; la tarjeta y la hoja (D1, D8) |
| `t120_fichas_en_lineas_test.dart` | 11 | `BsFichasEnLineas`: todas, las que caben, la fija, lo oculto fuera del toque y de la semántica, una línea, el alto en seco; las dos vistas previas con las tres pautas, de día y de noche, y el contraste de cada chip contra su fondo |
| `t120_filtros_matriz_test.dart` | 17 | 360, 599, 800, 1366 y 1920 dp con la letra a 1.0, 1.45 y 2.0, con las fuentes del producto: nada desbordado ni fuera de la pantalla, dos líneas en el teléfono, el elegido a la vista, la hoja |
| `t120_estadisticas_a_lista_test.dart` | 8 | GTSTC, «Sin destino» y «Otros»; Intro; Atrás una vez y el doble Atrás después; Atrás olvidado al cambiar el filtro; los dos desplazamientos recordados |
| `t120_lista_perezosa_test.dart` | 4 | Con 977, menos de 40 tarjetas construidas arriba y al final; `semanticChildCount`; un filtro no hace saltar lo de arriba |

Y el ayudante `test/support/t120_lista_support.dart`: un buque sintético del tamaño que se pida
(BUQUE LISTA, TSTU), leído por el lector del producto, con refrigerados con y sin `TMP`, peligrosas de
dos clases, fuera de medida y tres sin `LOC+11`.

**Rojas contra `899e4e3`** (`build/t120/e1/rojas-contra-899e4e3.txt`), en `%TEMP%\t120-antes`, una
copia de `899e4e3` hecha con `git archive` con las pruebas encima:
- **corren contra el código de antes** las de `t120_buscador_test.dart`, `t120_estadisticas_a_lista_test.dart`
  y `t120_lista_perezosa_test.dart` (18), porque solo usan el buscador, claves y textos que ya
  existían. **Fallan 17**, cada una en su comprobación: «reefer» no da nada, la barra no abre la Lista
  ni es un botón, no hay `lista-scroll`, se construyen las 977 tarjetas. **Pasa una:** «elegir un filtro
  no hace saltar lo de arriba», que ya se cumplía; es una guarda;
- **no compilan contra el código de antes** las otras 81, porque usan las piezas nuevas
  (`ConsultaDeBusqueda`, `CuentasDeLosFiltros`, `BsFichasEnLineas` y los providers del destino y la
  carga).

### 6.5 Validaciones y cifras

| Qué | Resultado | Registro |
|---|---|---|
| La suite completa, en una sola corrida, después del último cambio de `lib/` y `test/` | **2326 de 2326**, sin fallidas ni omitidas (el piso era 2227: +99) | `build/t120/e1/suite-4.txt` (de las 23:59 a las 00:01, después del último cambio) |
| Las corridas anteriores | La tercera, 2326 de 2326, antes de un cambio de comentario; la segunda, 2324 de 2324, antes de la corrección de 8.1; la primera, 2322 y 2 fallidas, las dos mías: el chip «Peligrosa IMDG» se desbordaba 20 px a 360 dp con la letra a 2.0, y la prueba del inicio de 6.3, punto 4. Corregidas | `build/t120/e1/suite-1.txt` |
| `flutter analyze --no-pub`, todo el paquete, en la carpeta | **«No issues found!»** | `build/t120/e1/analyze-6.txt` |
| La copia limpia (el árbol sin `build/`, `.dart_tool/` ni `docs/`), `pub get` y `analyze` | En la primera (`%TEMP%\t120-limpia-2231`), 3 errores, todos de `tool/t124_main.dart`, que importa la entrada generada de T-124 (`build/t124/entradas/`), O-143-3; con esa entrada copiada, **«No issues found!»**, y lo mismo con `dart analyze --cache` en una carpeta nueva (10.141). Con el código final, una copia nueva (`%TEMP%\t120-limpia-final-2355`, con la entrada de T-124): **«No issues found!»** con `flutter analyze` y con `dart analyze --cache` nueva | `analyze-copia-limpia*.txt` |
| `// ignore:` | Ninguno | |
| `pubspec.yaml`, `pubspec.lock`, `lib/main.dart`, los congelados, `domain/`, `data/`, `web/`, `windows/` | **No cambian** | `git diff --stat` |

Las sondas que usé para entender el contraste de los chips (8.2) vivieron en `build/t120/sonda/` y las
borré antes de la suite: llevaban `// ignore:` y `analyze` lee `build/`.

## 7. La memoria, antes y después (RNF-001 y RNF-007, solo la Lista)

### 7.1 Cómo se midió

- **El instrumento, sin tocarlo:** `tool/t114_ram_windows.ps1`, que abre el banco con `explorer.exe`
  desde un `.cmd` con las variables del conductor y llama a `tool/t99_ram_windows.ps1 -Accion seguir`
  (cinco lecturas de `WorkingSet64` tras 5 s de reposo en cada paso del escenario `ram` de
  `tool/t99_conductor.dart`: inicio, cargar, el plano, todas las bahías, Estadísticas, buscar y volver
  a la Lista); el resumen, `tool/t99_ram_resumen.dart`. Es lo mismo que midió los 510 MB de
  `REDISENO-RESULTADOS.md` 4.7.
- **Los dos bancos:** «antes», de `899e4e3`, y «después», del árbol con T-120, cada uno en su copia
  de `%TEMP%\t120-ram\` hecha con `tool/t99_copia.ps1` (la de «antes», con `git archive`, que solo lee;
  10.147, punto 5), con la identidad `r4`, `-t tool/t99_main.dart`, `T99_NAMESPACE=r4` y su almacén en
  `%TEMP%\t120-ram\almacen-*` (`T99_ALMACEN`). Sin Firebase: la sesión queda en el modo de un solo
  dispositivo y no abre ningún almacén (10.135). **No son Releases de publicación.**
- **Un tropiezo:** la guarda de `t99_ram_windows.ps1` solo acepta un banco cuya ruta diga «t99», y
  los míos estaban en `t120-ram`. La primera serie se detuvo en la corrida 1; cerré ese banco por su
  PID, comprobando su ruta, y copié las dos carpetas `Release` a `%TEMP%\t99-t120\`. Las cuatro series
  válidas son de ahí.
- **Los archivos:** `T99_SINTETICO_977.edi` (164 312 bytes, 977 `EQD+CN`), el mismo del rediseño,
  sacado del Base64 de la entrada de T-124; y `T99_SINTETICO_5000.edi`, generado con
  `tool/t99_sintetico.dart` desde la estructura de `CORPUS_A01.edi` («5000 leídos de 5000, 72
  bahías»). Los dos en `%TEMP%`; nada del corpus entró al repositorio.
- **Las corridas:** seis por banco y por archivo, la primera en frío y descartada; ninguna espera de
  reposo vencida. De las 22:53 a las 23:46, la ventana maximizada en la pantalla de la laptop.
- **El almacén real:** su listado desde esta consola es igual antes y después
  (`build/t120/e1/ram/almacen-real-*.txt`). La consola de un agente empaquetado lo ve mezclado con la
  copia de su paquete (AGENTS.md), así que vale como comparación, no como huella del almacén de Carlos.
  Los bancos escribieron solo en sus carpetas `r4_*` de `%TEMP%`.

### 7.2 Lo que dio

**El estable y el pico** (`t99_ram_resumen.dart`; MB del SI; cinco corridas válidas por serie):

| Archivo | Banco | Estable, mediana | Estable, máximo | Pico, mediana | Pico, máximo | Umbral |
|---|---|---:|---:|---:|---:|---|
| 977 | antes | 512.1 MB | 541.4 MB | 512.1 MB | 541.4 MB | < 200 MB |
| 977 | **después** | **151.8 MB** | **165.1 MB** | **162.3 MB** | **170.8 MB** | < 200 MB |
| 5 000 | antes | 1 929.9 MB | 1 939.6 MB | 1 930.0 MB | 1 939.6 MB | < 200 MB |
| 5 000 | **después** | **214.2 MB** | **224.9 MB** | **224.8 MB** | **225.5 MB** | < 200 MB |

**Paso por paso** (mediana de las 25 lecturas de las corridas 2 a 6, con su mínimo y su máximo):

| Paso | 977, antes | 977, después | 5 000, antes | 5 000, después |
|---|---:|---:|---:|---:|
| inicio | 117.3 (110.9–137.6) | 114.5 (111.1–117.6) | 133.1 (120.3–145.0) | 131.8 (120.7–145.1) |
| cargar | 154.3 (150.4–172.9) | 151.9 (148.5–163.1) | 200.3 (190.4–216.2) | 200.4 (188.6–216.2) |
| el plano | 156.9 (151.3–175.0) | 154.9 (150.9–165.7) | 202.4 (193.8–215.4) | 202.4 (191.4–206.4) |
| todas las bahías | 156.5 (150.1–179.2) | 155.1 (151.2–166.9) | 215.4 (210.9–224.8) | 220.0 (212.2–225.5) |
| Estadísticas | 171.5 (151.1–191.9) | 156.9 (154.9–170.8) | 208.8 (196.6–213.8) | 204.8 (195.1–211.8) |
| buscar | 179.9 (172.1–201.8) | 162.3 (152.4–166.5) | 196.6 (192.7–210.0) | 210.2 (197.5–223.6) |
| **volver a la Lista** | **512.1 (502.0–541.4)** | **151.8 (149.7–165.1)** | **1 929.9 (1 917.3–1 939.6)** | **214.2 (202.1–224.9)** |

**Lectura:**
- **El salto de la Lista desaparece.** Con 977, la Lista pasa de 512 MB a 152, al nivel de los demás
  pasos y por debajo de los 200 MB del umbral; con 5 000, de 1 930 MB a 214. Antes, la Lista crecía
  unos 0.35 MB por contenedor ((1 929.9 − 512.1) / 4 023); después, ya no crece con ellos: queda
  donde están el plano y las bahías de ese mismo archivo.
- **Lo demás no cambia:** de inicio a buscar, las dos columnas de cada archivo quedan dentro del ruido
  entre corridas (± 15 MB). Lo que se ve más bajo en Estadísticas y buscar con 977 es ruido, no un
  efecto de T-120.
- **Con 5 000, la app entera pasa de 200 MB** desde que carga el archivo (200 MB al cargar, 220 con
  todas las bahías), igual antes y después: no es la Lista. **No dictamino RNF-001 ni RNF-007:** eso es
  del bloque 3, con sus buques sintéticos y el Honor (D5).
- **La corrección de 8.1 no cambia estas cifras:** cambia el estilo del texto de los chips, no qué se
  construye. Se midió con el banco anterior a ella.

Las lecturas, los resúmenes y los registros de cada serie están en `build/t120/e1/ram/`.

## 8. Lo que no se pudo, lo que se encontró al mirar y lo que queda anotado

### 8.1 Las capturas encontraron un defecto que las pruebas no vieron

Con el banco de «después», el escenario `anchos` del conductor de T-99 (con `T99_ID=reefer`) tomó la
Lista, el plano, Estadísticas y la búsqueda a 1366 × 690 y a 600 × 960 (y la Lista a 360 × 800). **De
noche, el chip elegido («Todas», «Todos») salía como una caja clara sin texto**
(`build/t120/e1/capturas/antes-de-la-correccion/1366x690_lista.png`):
- **la causa:** el chip le ponía a su texto el estilo `labelLarge` del tema, con su color, y eso pisaba
  el color que el tema le da al chip elegido (el texto de la selección; de noche, la noche sobre la
  tinta). Es justo lo que avisa el comentario del `chipTheme` en `bs_tema.dart`;
- **por qué no lo vieron las pruebas:** las de 6.4 miraban el grosor del borde y el peso del texto
  del elegido, no su color; y la del contraste de la vista previa medía chips con un `Text` sin estilo;
- **la corrección:** el texto del chip lleva solo el tamaño, el peso, la familia y las cifras
  tabulares, y toma el color del chip;
- **la prueba nueva** (en `t120_filtros_lista_test.dart`, de día y de noche): el texto de cada chip de
  la Lista, elegido o no, pasa 4.5:1 contra su fondo. **Contra el código anterior falla de noche con
  1.0:1** («Todas», elegido; `contraste-chip-contra-codigo-anterior.txt`); con la corrección pasa;
- **la vi en pantalla:** el banco recompilado con la corrección dice «Todas 977» y «Todos 977» en el
  chip elegido (`capturas/final/1366x690_lista.png`).

Las demás capturas se ven como deben: la búsqueda de «reefer» dice «50 refrigerados» y cada resultado
lleva su «Refrigerado, −20 °C» o «Refrigerado, el archivo no trae temperatura»; Estadísticas, las
barras de los puertos con su zona táctil. El conductor no informó textos que no caben ni errores de
Flutter en la Lista, Estadísticas ni la búsqueda.

### 8.2 Lo demás

- **A 360 dp el conductor de T-99 no llega a Estadísticas:** busca el destino «Estadísticas» y en la
  barra inferior su rótulo es corto. Es del instrumento y viene de antes. La Lista a 360 dp sí se
  capturó, sin textos que no caben. El teléfono lo cubren las pruebas de la matriz (17).
- **No miré la Web ni Android en un cliente.** La semántica es la misma en los tres clientes y la cubren
  las pruebas; lo mira quien acepte (sección 12).
- **El contraste de la vista previa nocturna de `BsFichasEnLineas`:** la pauta de Flutter compara los
  dos colores que más pintan en el rectángulo del nodo, y en un chip de 32 dp con zona táctil de 48
  esos son el papel del lienzo y la hoja del chip (4.29:1), no el texto. La prueba mide aparte el texto
  de cada chip contra su fondo; de día la pauta se aplica tal cual.
- **El texto de los llenos y los vacíos del título** ya concuerda («1 lleno»); antes decía «1 llenos».
- **Visto y fuera del alcance:** `portDistributionProvider`, `carrierDistributionProvider`,
  `specialCargoStatsProvider` y `bayStatsProvider` siguen sin usarse (0.4); no los borré. O-120-1 (la
  hoja de detalle de la Lista) es del bloque 4.
- **La entrega 2 no empezó:** espera la aceptación de esta (10.148).

## 9. Archivos de la entrega 1

**Cambiados (14):**
- `DESIGN.md`: la sección 18, nueva; 15.5, 15.8 y 15.11 («Sin destino» y el puerto que se toca); el
  estado de arriba.
- `lib/core/design/componentes/bs_barra_de_magnitud.dart`: `alTocar` y `ayudaAlTocar`.
- `lib/core/design/design.dart`: exporta `bs_fichas_en_lineas.dart`.
- `lib/core/design/vistas_previas.dart`: la vista previa «Fichas en líneas» y la barra que se toca en
  la de los paneles de Estadísticas.
- `lib/features/vessel/presentation/formatters/estadisticas_del_viaje.dart`: «Sin destino» (D6) y el
  código en blanco.
- `lib/features/vessel/presentation/pages/vessel_overview_page.dart`: la pestaña Lista
  (`CustomScrollView`, filas, título y vacío), el paso desde Estadísticas con Atrás, el desplazamiento
  recordado y la limpieza en `_openAlerts`.
- `lib/features/vessel/presentation/providers/loading_operation_provider.dart`: los filtros, las
  cuentas y el filtro triple.
- `lib/features/vessel/presentation/providers/vessel_providers.dart`: el destino y la carga elegidos, y
  su limpieza.
- `lib/features/vessel/presentation/widgets/container_search_delegate.dart`: RF-018.
- `lib/features/vessel/presentation/widgets/containers_list_view.dart`: `ContainersSliverList`, los
  nombres de los chips y los dos renglones de la hoja (D8).
- `lib/features/vessel/presentation/widgets/voyage_stats_view.dart`: `onPuerto` y el desplazamiento
  recordado.
- `test/t114_fase3_inicio_test.dart` (6.3, punto 4), `test/t121_estadisticas_test.dart` (D6) y
  `test/t144_lector_volcado_test.dart` (el texto de ayuda): una línea cada una, con su comentario.

**Nuevos (12):**
- `lib/core/design/componentes/bs_fichas_en_lineas.dart`
- `lib/features/vessel/presentation/formatters/consulta_de_busqueda.dart`
- `lib/features/vessel/presentation/formatters/cuentas_de_los_filtros.dart`
- `lib/features/vessel/presentation/widgets/filtros_de_la_lista.dart`
- `test/support/t120_lista_support.dart`
- `test/t120_buscador_test.dart`, `test/t120_busqueda_carga_especial_test.dart`,
  `test/t120_estadisticas_a_lista_test.dart`, `test/t120_fichas_en_lineas_test.dart`,
  `test/t120_filtros_lista_test.dart`, `test/t120_filtros_matriz_test.dart`,
  `test/t120_lista_perezosa_test.dart`

Y este informe. **`pubspec.yaml` y `pubspec.lock` no cambian.** Tampoco `domain/`, `data/`,
`lib/main.dart`, los congelados, las opciones de Firebase, `web/`, `windows/`, `tool/` ni el manual de
la 1.0.1.

**Evidencia, fuera de Git:** `build/t120/paso0/` y `build/t120/e1/` (los `analyze`, las dos suites,
las rojas y las corridas de cada archivo de pruebas) y, en `%TEMP%`, las copias y las lecturas de la
medición (7.1).

## 10. `DESIGN.md` y el manual

- **`DESIGN.md` 18** dice lo que se ve, las cuentas y el orden, la oficina y el teléfono con la API de
  `BsFichasEnLineas`, la Lista perezosa y el lector de pantalla, el paso desde Estadísticas y RF-018
  con su tabla de términos y su fuente. 15.5 deja de decir «es T-120».
- **El manual, en la versión siguiente** (el de la 1.0.1 no se tocó):
  - **5.1 La búsqueda:** los términos de carga especial, la clase y el número ONU, la línea de arriba,
    el motivo de cada resultado y la sección «Carga especial»; una figura con «reefer»;
  - **5.2 La Lista:** las tres filas, las cuentas cruzadas, «Sin destino», «Quitar filtros» y «Ver los
    n» en el teléfono; los nombres de los chips de la tarjeta; la figura de la Lista, nueva;
  - **6.1 Estadísticas:** «Sin destino», y tocar un puerto abre la Lista filtrada; Atrás vuelve;
  - **11 Glosario:** «OOG» y «fuera de medida», y que «reefer», «imo» y «oog» se buscan.

## 11. Horas

Del reloj, el 17-nov: de las 22:00 (la 10.148) a las 00:05 del 18-nov, unas 2 h. De ellas, la
medición ocupó la máquina de las 22:44 a las 23:46, con los dos bancos y las cuatro series. La
propuesta estimaba de 15.5 a 17 h para esta entrega.

## 12. Para quien acepte

1. **La suite y `analyze`** en una copia limpia de la punta con este bloque: 2326 aprobadas, sin
   omitidas; `analyze` en cero, con la entrada de T-124 copiada (O-143-3) y, si la copia marca algo
   que la carpeta no, otra vez con `dart analyze --cache` en una carpeta nueva (10.141).
2. **Las rojas:** las tres pruebas que compilan contra `899e4e3` (6.4), en una copia de ese commit.
3. **A la vista, en Windows y en la Web del banco** (perfil nuevo de Chrome, 10.142), con
   `T99_SINTETICO_977.edi`, de día y de noche, a 360 y a 1366 dp, con la letra a 1.0 y 2.0:
   - los tres filtros, las cuentas cruzadas, el orden que no cambia, el elegido legible, «Sin destino»,
     «Quitar filtros» y, en el teléfono, «Ver los n destinos» con su hoja;
   - de Estadísticas a la Lista por GTSTC (o el puerto que traiga el archivo) y «Sin destino», y Atrás
     en Android si hay emulador;
   - el buscador con «reefer», «imo 3», «oog» y «reefer USHOU».
4. **La memoria:** basta una corrida de cada banco con 977 para ver el mismo orden de magnitud (512
   contra 152 MB en la Lista); las 24 están en `build/t120/e1/ram/`.

## 13. Git

Para que lo ejecute Carlos. Fuera quedan los cuatro archivos que solo cambian el fin de línea
(`test/t114_fase3_correccion_test.dart` y tres de `windows/flutter/`) y las carpetas sin seguimiento de
`docs/`. **`pubspec.yaml` y `pubspec.lock` no cambian.**

```powershell
git add -- DESIGN.md
git add -- lib/core/design/componentes/bs_barra_de_magnitud.dart
git add -- lib/core/design/componentes/bs_fichas_en_lineas.dart
git add -- lib/core/design/design.dart
git add -- lib/core/design/vistas_previas.dart
git add -- lib/features/vessel/presentation/formatters/consulta_de_busqueda.dart
git add -- lib/features/vessel/presentation/formatters/cuentas_de_los_filtros.dart
git add -- lib/features/vessel/presentation/formatters/estadisticas_del_viaje.dart
git add -- lib/features/vessel/presentation/pages/vessel_overview_page.dart
git add -- lib/features/vessel/presentation/providers/loading_operation_provider.dart
git add -- lib/features/vessel/presentation/providers/vessel_providers.dart
git add -- lib/features/vessel/presentation/widgets/container_search_delegate.dart
git add -- lib/features/vessel/presentation/widgets/containers_list_view.dart
git add -- lib/features/vessel/presentation/widgets/filtros_de_la_lista.dart
git add -- lib/features/vessel/presentation/widgets/voyage_stats_view.dart
git add -- test/support/t120_lista_support.dart
git add -- test/t114_fase3_inicio_test.dart
git add -- test/t120_buscador_test.dart
git add -- test/t120_busqueda_carga_especial_test.dart
git add -- test/t120_estadisticas_a_lista_test.dart
git add -- test/t120_fichas_en_lineas_test.dart
git add -- test/t120_filtros_lista_test.dart
git add -- test/t120_filtros_matriz_test.dart
git add -- test/t120_lista_perezosa_test.dart
git add -- test/t121_estadisticas_test.dart
git add -- test/t144_lector_volcado_test.dart
git add -- docs/T120-RESULTADOS.md
git commit -m "Sprint 4: T-120, entrega 1: la Lista filtra por naviera, destino y carga especial con cuentas cruzadas, Estadisticas abre la Lista por puerto, el buscador entiende reefer, imo y oog (RF-018) y la Lista es perezosa"
git push
```

## 14. En tres líneas

- La Lista filtra por naviera, destino y carga especial, con cuentas cruzadas y el orden fijo; tocar
  un puerto en Estadísticas abre la Lista filtrada; «Sin destino» es un solo nombre.
- El buscador entiende «reefer», «imo» y «oog» (RF-018), con la clase IMO, el número ONU, lo que
  entendió y por qué salió cada resultado.
- La Lista es perezosa: con 977 contenedores baja de 512 a 152 MB, y con 5 000, de 1 930 a 214;
  suite 2326/2326, `analyze` en cero aquí y en la copia limpia.

## 15. Mensaje para Yov

> Yov, la entrega 1 de T-120 está en `docs/T120-RESULTADOS.md` (secciones 6 a 15), sobre `732334d`,
> sin commit. La Lista filtra por naviera, destino y carga especial, con cuentas cruzadas en una
> pasada y el orden fijo por el total del viaje; desde Estadísticas, un puerto abre la Lista filtrada
> y Atrás vuelve una vez; «Sin destino» en las dos pantallas; el buscador entiende RF-018 (fuente:
> `DOC2.md`). 99 pruebas nuevas; la suite da 2326 de 2326 en una corrida, sin omitidas; `analyze`,
> cero aquí y en una copia limpia (con la entrada de T-124, O-143-3, y repetido con caché nueva).
> Contra `899e4e3` corren 18 de las nuevas y fallan 17; la otra es una guarda. La memoria, con
> `t114_ram_windows.ps1` y seis corridas por serie: la Lista pasa de 512.1 a 151.8 MB con 977 y de
> 1 929.9 a 214.2 MB con 5 000; lo demás no cambia. Las capturas del banco encontraron un defecto que
> las pruebas no vieron: de noche, el chip elegido no se leía (1.0:1); está corregido, con su prueba
> roja, y visto en pantalla. Tres pruebas viejas cambian una línea cada una (6.3 y 6.4). No se
> compiló ninguna Release de publicación ni se tocó la versión. La entrega 2 espera la aceptación.

**ALTO: Yov revisa y GLM acepta.**

---

## Corrección 1 de la entrega 1 (18-nov; 10.149)

### C1.1 Resultado en tres líneas

- **R1, R2 y R3, confirmadas y corregidas, cada una con su roja:** de noche, el ícono del chip de
  carga elegido daba 1.0:1; dos motivos de un resultado repetían su clave («Duplicate keys found»); y
  el foco caía, con Tab, en un chip que no se ve. **D9 y D10** también, con sus pruebas.
- **R4, mirado:** el buque de las pruebas ya es un archivo (`tool/t120_buque.dart`) y un conductor
  propio (`tool/t120_conductor.dart`) recorre en el banco los cinco puntos, de día y de noche, a 1366 ×
  690 y a 360 × 800 con la letra a 1.0 y a 2.0: 94 capturas, ninguna con textos cortados ni errores.
- **Al mirar apareció una cosa más,** el texto de ayuda del buscador, que yo había alargado en la
  entrega y no cabía a 360 dp: corregido, con su roja. Suite 2340/2340; `analyze` en cero aquí y en
  una copia limpia.

### C1.2 Paso 0 y lo que se corrió

- **La punta es `d182649`** («decision 10.149»), encima de `02169fc`, el commit de la entrega 1
  (`git log --oneline -5`, `git show --stat HEAD`). Solo cambia `SPRINT-4.md`.
- **Carlos confirmó** (18-nov, hacia las 12:27) que nadie más tiene abiertos `lib/`, `test/` ni
  `pubspec.*`, y dio luz verde a una ventana de Flutter abierta mientras corregía. Empezó y terminó con
  su `SEMÁFORO:`; un comando a la vez.
- **Las rojas, contra el código de la entrega:** una copia de `02169fc` hecha con `git archive` en
  `%TEMP%\t120-e1c1-entrega`, con la entrada de T-124 (O-143-3) y la prueba nueva encima.
- **El banco:** copias del árbol con `tool/t99_copia.ps1 -Arbol -Sufijo r4`, compiladas con
  `-t tool/t120_main.dart`, `T99_NAMESPACE=r4` y el almacén en `%TEMP%\t99-t120-c1\almacen-*`, sin
  Firebase, abiertas con `explorer.exe`. **No son Releases de publicación.** No toqué el almacén real,
  la MSIX de Carlos, Firebase ni el Honor, ni cambié la versión.
- **La memoria no se repitió:** nada de esto cambia lo que la Lista construye (R1 y R2 son estilos y
  claves; R3 envuelve las fichas en `ExcludeFocus`, sin render propio; D9 desplaza; D10 es una línea
  en Estadísticas).

### C1.3 Cada punto

**R1 · De noche, el chip elegido de «Carga especial» perdía su ícono.**
- **Qué era:** el ícono iba en el rótulo del chip con el color de los íconos de la app
  (`iconTheme`, la tinta, `bs_tema.dart:113`), y de noche el relleno del elegido es la tinta
  (`:99`, `:187`). Es de la familia de 8.1: el texto ya tomaba el color del chip, el ícono no.
- **La roja:** la prueba de contraste ahora elige primero las tres cargas y después una naviera y un
  destino, de día y de noche, y mide cada texto a 4.5:1 y cada ícono a 3:1 contra el fondo de su
  chip. Contra la entrega, de noche: **«el ícono de filtro-carga-peligrosa, elegido» da 1.0:1**
  (`build/t120/e1c1/rojas-contra-la-entrega.txt`); de día pasa.
- **El cambio:** el ícono toma el color del texto del chip (`DefaultTextStyle.of(context)` dentro de un
  `Builder` en el rótulo), que el tema resuelve por estado. No hizo falta tocar el tema.
- **Cómo lo vi:** `capturas/final/1366x690_oscuro_letra1.0_1b_carga_elegida.png`: el copo de
  «Refrigerado 97», elegido, se lee de noche.

**R2 · Dos motivos de un mismo resultado con la misma clave.**
- **La roja:** un refrigerado peligroso con «reefer imo»: contra la entrega, **«Duplicate keys
  found»**.
- **El cambio:** cada motivo lleva su clave, `busqueda-motivo-0`, `-1`… (`container_search_delegate.dart`).
- **Cómo lo vi:** `capturas/final/*_5_buscar_reefer_imo.png`: «TSTU0000030» con «Peligrosa IMDG, IMO
  3, UN 1993» y «Refrigerado, el archivo no trae temperatura», sin errores en el registro.

**R3 · Los chips que no caben tomaban el foco.**
- **La roja, dos pruebas a 360 dp:** con Tab por toda la Lista, **en el octavo Tab el foco caía en un
  chip oculto**; y pedirle el foco a uno oculto (`filtro-destino-PAMIT`) **lo tomaba**. La hipótesis de
  Yov era cierta.
- **El cambio:** `BsFichasEnLineas` pasa a ser un widget con estado. Qué fichas caben solo se sabe al
  disponerlas: después de cada disposición que cambia lo que se ve, envuelve las que quedan fuera en
  `ExcludeFocus` (en el cuadro siguiente, porque durante la disposición no se puede reconstruir).
  `ExcludeFocus` no tiene render propio, así que la disposición no cambia, y si una ficha tenía el
  foco, lo suelta. Su API no cambia.
- **Ahora:** en 80 Tabs el foco nunca cae en un chip oculto y sí recorre los que se ven; el oculto no
  toma el foco, y ni Intro ni espacio lo activan.

**R4 · Lo que nadie había visto en una pantalla.**
- **El archivo:** `tool/t120_buque.dart` tiene ahora el generador de las pruebas (`t120Baplie`, que
  `test/support/t120_lista_support.dart` reexporta: uno solo) y un `main` que lo escribe en una
  carpeta nueva de `%TEMP%` y lo verifica con el lector: `T120_BUQUE_LISTA_977.edi`, **977 leídos de
  977, 9 puertos, 3 sin destino, 97 refrigerados, 81 peligrosos, 19 fuera de medida y 48 refrigerados
  peligrosos** (`build/t120/e1c1/buque.txt`). El corpus no se tocó.
- **El instrumento:** el escenario `anchos` del conductor de T-99 solo toca pestañas, y no llega a
  ninguno de los cinco estados. Escribí uno propio, sin tocar los de T-99:
  - `tool/t120_main.dart`: la app con los almacenes del banco (`t99App`, sin Firebase) y el conductor;
  - `tool/t120_conductor.dart`: publica el archivo y, por tema, tamaño y letra, elige con los chips (o
    con la hoja, si el chip no cabe), abre con los botones, escribe en el campo y guarda una captura de
    cada estado, con los textos que no caben y los errores de Flutter;
  - `tool/t120_capturas_windows.ps1`: abre el banco con `explorer.exe` desde un `.cmd`, espera el fin
    del recorrido y lo cierra por su PID.
- **Lo que se vio** (`build/t120/e1c1/capturas/final/`, 94 capturas; claro y oscuro; 1366 × 690 con la
  letra a 1.0, y 360 × 800 con la letra a 1.0 y a 2.0):
  1. las tres filas con PAMIT elegido y con «Refrigerado» elegido (`1a`, `1b`). Con PAMIT, las tres
     cargas en cero y apagadas: en este buque ningún contenedor de PAMIT trae carga especial;
  2. en el teléfono, «Ver los 10 destinos» y su hoja (`2a`, `2b`); la hoja cerrada sin elegir (`2c`);
     JMKCT, un destino chico elegido desde la hoja, a la vista (`2d`), también con la letra a 2.0;
  3. «Sin destino» en la Lista (`3a`); en Estadísticas, «Otros 3 puertos» y la línea de D10 (`3b`);
     «Sin destino» en «Ver como tabla», donde están todos (`3c`), porque en las barras cae dentro de
     «Otros 3 puertos»; y de la barra de PAMIT a la Lista, con el título arriba (`3d`, D9);
  4. la tarjeta de un fuera de medida, con «Refrigerado» y «Fuera de medida» (`4a`), su hoja (`4b`) y,
     bajando en la hoja, «Fuera de medida: Frente 30 cm · Alto 25 cm» (`4c`);
  5. el buscador con «oog», «imo 3», «reefer imo» y «reefer GTSTC» (`5_*`).
- **Lo que el instrumento no alcanza:** Windows y nada más. La Web y Android no se miraron en un
  cliente, Atrás de Android tampoco (está en las pruebas), y el teléfono es la ventana de Windows a
  360 × 800 lógicos, no un teléfono. Queda para quien acepte (C1.7).

**Al mirar · El texto de ayuda del buscador no cabía en el teléfono.** Lo encontró el registro del
conductor, no los ojos: la ayuda que puse en la entrega 1, «Buscar contenedor, puerto o carga…»,
excedía su línea a 360 dp.
- **La roja:** a 360 dp con las fuentes del producto, la ayuda se corta con la letra a 1.0 y a 1.45
  (`ayuda-del-buscador-roja.txt` y las rojas contra `02169fc`).
- **El cambio:** la ayuda es **«Matrícula, puerto o carga»**, que cabe a 360 dp con la letra a 1.0 y a
  1.45. Con la letra a 2.0 no cabe ninguna ayuda útil en un campo de una línea (tampoco la de antes de
  T-120), así que la página elige la que cabe: `ContainerSearchDelegate.ayudaPara` la mide con la letra
  del tema y el ancho del campo vacío, y si no cabe pone **«Buscar»**.
- **Cómo lo vi:** en las 94 capturas finales, ningún texto que no cabe.

**D9 · Desde Estadísticas, la Lista se abre con su título arriba.** Al llegar desde una barra, en el
cuadro siguiente la Lista lleva su título («Contenedores (98), destino PAMIT», con «Quitar filtros»)
arriba de lo que se ve, con las tarjetas debajo (`Scrollable.ensureVisible` del título). Por el riel o
la barra, la Lista sigue recordando dónde estaba. La prueba de la entrega que esperaba la Lista arriba
(`t120_estadisticas_a_lista_test.dart`) ahora pide el título arriba. **Visto:** `3d`, a 1366 y a 360 dp.
Va un cuadro con la Lista arriba antes del salto: la Lista todavía no está dispuesta cuando se toca la
barra.

**D10 · El panel de puertos dice que se toca.** Debajo de las barras, «Toca un puerto para verlo en la
Lista», con el estilo de la línea del panel de bahías. Sin `onPuerto`, no sale. **Visto:** `3b`.

**De paso:** el comentario de `consulta_de_busqueda.dart` dice ahora «17 peligrosos o refrigerados»,
como el código y `DESIGN.md` 18.6.

### C1.4 Las pruebas

**Nuevas, en `test/t120_correccion1_test.dart` (14):** R1 de día y de noche (2); R2 (1); R3 (2); la
ayuda del buscador a 360 dp con la letra a 1.0 y 1.45 (2) y desde la página a 1.0, 1.45 y 2.0 (3); D9
(1) y la guarda de la Lista que recuerda (1); D10 (1) y su guarda sin `onPuerto` (1). Solo usan piezas
que ya estaban en la entrega, así que compilan contra ella.

**Rojas contra `02169fc`** (`build/t120/e1c1/rojas-contra-02169fc.txt`): **fallan 11 de 14**, cada una
en su comprobación; pasan las tres que ya se cumplían: R1 de día y las dos guardas.

**Cambian:**
- `t120_estadisticas_a_lista_test.dart`: «empieza arriba» pasa a «se abre con su título arriba» (D9);
- `t120_buscador_test.dart`: la ayuda nueva;
- `test/support/t120_lista_support.dart`: el generador sale a `tool/t120_buque.dart` y se reexporta.

### C1.5 Validaciones y cifras

| Qué | Resultado | Registro (`build/t120/e1c1/`) |
|---|---|---|
| La suite completa, en una sola corrida, después del último cambio de `lib/` y `test/` | **2340 de 2340**, sin fallidas ni omitidas (2326 de la entrega + 14) | `suite-2.txt` (12:52:11 a 12:54:02) |
| `flutter analyze --no-pub`, todo el paquete, en la carpeta | **«No issues found!»** | `analyze-2.txt` |
| La copia limpia (`%TEMP%\t120-e1c1-limpia-1254`: el árbol sin `build/`, `.dart_tool/` ni `docs/`, con la entrada de T-124, O-143-3) | **«No issues found!»** con `flutter analyze` y con `dart analyze --cache` en una carpeta nueva (10.141) | `analyze-copia-limpia*.txt` |
| El banco final y sus capturas | 94 capturas, ningún texto que no cabe, ningún error de Flutter | `capturas/final/pasos.jsonl` |
| `// ignore:` | Ninguno | |
| `domain/`, `data/`, `pubspec.*`, `lib/main.dart`, los congelados, `web/`, `windows/` | **No cambian** | `git diff --stat` |

### C1.6 Lo que queda anotado

- **Visto al mirar, no es de esta corrección:**
  - con la letra a 2.0 en el teléfono, la matrícula del resultado del buscador se parte por la mitad
    («TSTU00000 / 10»): el título del resultado es un `RichText` que envuelve, y no usa
    `BsNumeroDeContenedor`, que nunca parte la matrícula (17.5). Viene de antes de T-120;
  - la hoja de detalle de la Lista lleva dos asas de arrastre, la suya y la de la hoja: va con O-120-1
    (bloque 4);
  - en el teléfono, «Ver los n» lleva el rótulo más chico que los chips (es `ActionChip`, con
    `labelMedium`). Se lee y no se corta.
- **D9 va con un cuadro de la Lista arriba** antes del salto (C1.3).
- La entrega 2 no empezó.

### C1.7 Para quien acepte (pone al día la sección 12)

1. **La suite y `analyze`** en una copia limpia de la punta con este bloque: 2340 aprobadas, sin
   omitidas; `analyze` en cero con la entrada de T-124 copiada (O-143-3) y, si la copia marca algo que
   la carpeta no, otra vez con `dart analyze --cache` en una carpeta nueva (10.141).
2. **Las rojas:** `t120_correccion1_test.dart` en una copia de `02169fc` (11 de 14 fallan); y las de la
   entrega, en una copia de `899e4e3` (17 de 18; 6.4).
3. **El archivo, que ahora es el que hay que mirar:**
   ```powershell
   dart tool/t120_buque.dart "$env:TEMP\t120-buque-glm" 977
   ```
   Escribe `T120_BUQUE_LISTA_977.edi` en esa carpeta nueva y dice lo que trae; se niega a escribir
   fuera de `%TEMP%` o dentro del repositorio. `T99_SINTETICO_977.edi` ya no sirve para esto: no trae
   «Sin destino», fuera de medida ni dos cargas en un contenedor.
4. **A la vista, en Windows y en la Web del banco** (perfil nuevo de Chrome, 10.142), con ese archivo,
   de día y de noche, a 360 y a 1366 dp, con la letra a 1.0 y a 2.0: lo de la sección 12, punto 3, y
   además el chip de carga elegido con su ícono de noche, Tab por las filas a 360 dp (el foco nunca
   en un chip que no se ve), «reefer imo» con dos motivos, la ayuda del campo vacío, D9 y D10. Atrás en
   Android, si hay emulador.
5. **El recorrido de capturas, si se quiere repetir en Windows:**
   ```powershell
   ./tool/t99_copia.ps1 -Destino "$env:TEMP\t99-glm-t120\copia" -Arbol -Sufijo r4 -Entradas "$env:TEMP\t120-buque-glm\T120_BUQUE_LISTA_977.edi"
   ```
   y, en esa copia, `flutter pub get` y `flutter build windows --release --no-pub -t
   tool/t120_main.dart --dart-define=T99_ALMACEN=$env:TEMP\t99-glm-t120\almacen
   --dart-define=T99_NAMESPACE=r4`; después
   ```powershell
   ./tool/t120_capturas_windows.ps1 -Exe "$env:TEMP\t99-glm-t120\copia\build\windows\x64\runner\Release\baystream.exe" -Salida "$env:TEMP\t99-glm-t120\capturas"
   ```
   Unos 3 minutos, con la máquina quieta.
6. **La memoria** no se repite (C1.2).

### C1.8 Archivos

**Cambiados (10):**
- `DESIGN.md`: 15.5 (D10) y 18.1, 18.3, 18.4, 18.5 y 18.6 (R1, R3, D9, D10, R2 y la ayuda).
- `lib/core/design/componentes/bs_fichas_en_lineas.dart`: R3.
- `lib/features/vessel/presentation/formatters/consulta_de_busqueda.dart`: el comentario.
- `lib/features/vessel/presentation/pages/vessel_overview_page.dart`: D9 y la ayuda que cabe.
- `lib/features/vessel/presentation/widgets/container_search_delegate.dart`: R2 y la ayuda.
- `lib/features/vessel/presentation/widgets/filtros_de_la_lista.dart`: R1.
- `lib/features/vessel/presentation/widgets/voyage_stats_view.dart`: D10.
- `test/support/t120_lista_support.dart`, `test/t120_buscador_test.dart` y
  `test/t120_estadisticas_a_lista_test.dart`.

**Nuevos (5):** `test/t120_correccion1_test.dart`, `tool/t120_buque.dart`, `tool/t120_conductor.dart`,
`tool/t120_main.dart` y `tool/t120_capturas_windows.ps1`.

Y este informe. **`pubspec.yaml` y `pubspec.lock` no cambian.**

### C1.9 Horas

Del reloj, el 18-nov: de las 12:27 a las 13:05, unos 40 minutos; de ellos, unos 10 de compilar el
banco y recorrerlo (tres veces).

### C1.10 Git

Para que lo ejecute Carlos. Fuera quedan los cuatro archivos que solo cambian el fin de línea y las
carpetas sin seguimiento de `docs/`.

```powershell
git add -- DESIGN.md
git add -- lib/core/design/componentes/bs_fichas_en_lineas.dart
git add -- lib/features/vessel/presentation/formatters/consulta_de_busqueda.dart
git add -- lib/features/vessel/presentation/pages/vessel_overview_page.dart
git add -- lib/features/vessel/presentation/widgets/container_search_delegate.dart
git add -- lib/features/vessel/presentation/widgets/filtros_de_la_lista.dart
git add -- lib/features/vessel/presentation/widgets/voyage_stats_view.dart
git add -- test/support/t120_lista_support.dart
git add -- test/t120_buscador_test.dart
git add -- test/t120_correccion1_test.dart
git add -- test/t120_estadisticas_a_lista_test.dart
git add -- tool/t120_buque.dart
git add -- tool/t120_capturas_windows.ps1
git add -- tool/t120_conductor.dart
git add -- tool/t120_main.dart
git add -- docs/T120-RESULTADOS.md
git commit -m "Sprint 4: T-120, entrega 1, correccion 1: el icono del chip elegido se lee de noche, una clave por motivo, el foco no cae en un chip oculto, la Lista se abre en su titulo desde Estadisticas, el panel de puertos dice que se toca, la ayuda del buscador cabe y el buque de las pruebas se mira en el banco"
git push
```

### C1.11 En tres líneas

- R1, R2 y R3 confirmadas con sus rojas y corregidas: el ícono del chip elegido se lee de noche, cada
  motivo lleva su clave y el foco no cae en un chip oculto; D9 y D10 hechos.
- El buque de las pruebas es un archivo y un conductor propio lo recorre en el banco: 94 capturas sin
  textos cortados; al mirar, la ayuda del buscador no cabía a 360 dp y se corrigió.
- Suite 2340/2340, `analyze` en cero aquí y en la copia limpia; 11 de las 14 pruebas nuevas fallan
  contra la entrega.

### C1.12 Mensaje para Yov

> Yov, la corrección 1 de la entrega 1 de T-120 está al final de `docs/T120-RESULTADOS.md`, sobre
> `d182649`, sin commit. Las tres se confirmaron: R1 daba 1.0:1 de noche en el ícono del chip de carga
> elegido (ahora toma el color del texto del chip, sin tocar el tema); R2, «Duplicate keys found»
> (una clave por motivo); R3, el foco caía en un chip oculto al octavo Tab (las fichas que no se ven
> van en `ExcludeFocus`). D9 y D10, hechos. R4: `tool/t120_buque.dart` escribe el buque de las
> pruebas (9 puertos, 3 sin destino, 19 fuera de medida, 48 con dos cargas) y un conductor propio lo
> recorre en el banco: 94 capturas, claro y oscuro, 1366 y 360 dp, letra 1.0 y 2.0, sin textos
> cortados ni errores. Al mirar apareció la ayuda del buscador, que yo había alargado y no cabía a
> 360 dp: ahora es «Matrícula, puerto o carga», y «Buscar» si no cabe. 14 pruebas nuevas, 11 rojas
> contra `02169fc`; suite 2340/2340; `analyze` en cero aquí y en una copia limpia. La memoria no se
> repitió. La entrega 2 espera.

**ALTO: Yov revisa y GLM acepta.**

---

## Entrega 2 · El plano y la oficina (21-nov; 10.168)

### E2.1 Resultado en tres líneas

- **El pellizco:** O-119-1 se confirmó con dos pruebas rojas antes de cambiar nada (0.562 dp en
  horizontal y 0.740 en vertical, con el touchpad) y se corrigió; O-128-4 también, y en la app de
  verdad: en Windows y en la Web, al perder el foco, el plano suelta el pellizco.
- **O2, O-120-4 y O-120-5:** cada segmento dice su nombre una vez en el árbol de Windows; el cuadro
  con la Lista arriba antes del salto se veía en Windows y en la Web, y ya no se pinta; en el
  teléfono, «Carga especial» enseña sus tres chips.
- **Suite 2558 de 2558** (2531 + 27), sin omitidas, y `analyze` en cero, aquí y en una copia
  limpia; 13 de las 27 pruebas nuevas fallan contra `261ee4b`. **Los dos monitores quedan
  pendientes** (Carlos no pudo en esta sesión).

### E2.2 Paso 0

- **La punta:** `git log --oneline -5` da `261ee4b` («Sprint 4: mezcla de t147-piloto4 a
  sprint-4, con la entrega 2 de T-147») y debajo `5f850e9` («decision 10.168»). Es la esperada.
- **La copia limpia:** `git -c core.autocrlf=false archive 261ee4b`, extraída en
  `%TEMP%\t120-e2\limpia` (2171 archivos, con su huella en `%TEMP%\t120-e2\copia-limpia-manifiesto.json`),
  más la entrada de T-124 (O-143-3). `flutter pub get --offline --enforce-lockfile` pasa y
  `pubspec.lock` no cambia.
- **Lo que nadie había corrido, T-120 y la entrega 2 de T-147 juntas:**

| Qué | Resultado | Registro (`build/t120/e2/paso0/`) |
|---|---|---|
| `flutter analyze --no-pub`, todo el paquete (22:17:05 a 22:17:23) | **«No issues found!»** | `analyze.txt` |
| La suite completa, en una sola corrida (22:17:23 a 22:19:48) | **`+2531: All tests passed!`**, sin omitidas ni fallidas | `suite.txt` |

  Las 2531 esperadas: 2393 de `sprint-4`, 77 de la parte 2a y 61 de la 2b. Nada de la mezcla.
- `pubspec.yaml` sigue en `1.0.3+12`; no lo toqué.
- **Semáforo:** Carlos dio la luz verde de cada ventana (el paso 0; las pruebas y `analyze` en
  la carpeta; los bancos de Windows y de la Web). Nadie más corrió Flutter.

### E2.3 Cada punto

#### A · O-119-1: el punto bajo el puntero, en el cruce de caber a no caber

- **La prueba, antes de cambiar nada** (`test/t120_pellizco_test.dart`, grupo O-119-1): en pasos
  chicos y cuadro por cuadro, el punto que estaba bajo el puntero tiene que seguir ahí, con
  0.25 dp de tolerancia, salvo donde no puede (16.3: la bahía cabe y va centrada, o el
  desplazamiento está en su tope). Cinco casos: el touchpad en pasos de 1 % del 100 % a no
  caber; el touchpad con la columna al fondo; el touchpad alejando, de no caber a caber; el
  pellizco de la Web (`PointerScaleEvent` de 1.01) y la Web en ráfagas de tres pasos por cuadro.
- **Mi primera versión medía mal,** y lo digo porque salió roja por eso: comparaba con la posición
  del inicio, y mientras la bahía cabe la celda se corre ~0.16 dp por cada 1 % por diseño (va
  centrada). La desglosé con una sonda (`build/t120/e2/rojas/sonda-desglose*.txt`) y reescribí la
  medida como el desvío del punto bajo el puntero, paso a paso.
- **Contra `261ee4b`, fallan dos de cinco, cada una en su comprobación**
  (`rojas/pellizco-contra-261ee4b.txt`):
  - el touchpad del 100 % a no caber: **0.562 dp en horizontal, en el paso siguiente al cruce**
    (a 1.40);
  - el touchpad con la columna al fondo: **0.740 dp en vertical** (a 1.14).
  - La Web, en pasos y en ráfagas, y alejar dan 0.000 (las ráfagas, 0.081): ya pasaban.
- **La hipótesis se confirmó en su mecanismo,** con un escucha del desplazamiento
  (`sonda-desglose-3.txt`): `jumpTo(5.294)` con el alcance medido todavía en 4.732 deja una
  `BallisticScrollActivity`; en el cuadro siguiente, en la fase `transientCallbacks`, **antes de
  medir el alcance nuevo**, la simulación lo devuelve a 4.732; después se mide 11.052, pero ya es
  tarde. **Difiere de lo que yo esperaba en dónde sale:** con el touchpad (y no con el
  `PointerScaleEvent` de la Web) y un paso después del cruce. Los 1.9 dp que midió Codex en
  Chrome no se reproducen en las pruebas de widgets (abajo, «Lo que no se pudo»).
- **El cambio** (`plan_drag_confirmation.dart`, `_llevarA`): dentro del alcance medido, `jumpTo`
  como siempre; fuera de él, hasta el tope medido con `jumpTo` y el resto con `correctPixels`,
  sin simulación. Al medirse el alcance nuevo, `correctForNewDimensions` lo acota a él (lo leí
  en `scroll_position.dart` del SDK antes de usarlo). Nadie escucha con `addListener` los
  controladores del plano: la barra va por notificaciones, que el SDK manda al cambiar las
  medidas.
- **Ahora:** los cinco casos, 0.000 dp (las ráfagas, 0.081), y las 11 de T-119 siguen pasando.
- **En la app de verdad, el instrumento no distingue esto,** y no lo cuento como visto: el
  conductor del banco manda los mismos eventos sintéticos y mide igual, y da 0.52 / 0.28 / 0.50
  dp **en el banco de la punta y en el de la entrega, las mismas cifras en los mismos pasos**
  (`windows/punta-pellizco`, `windows/final-pellizco` y `web/final-pellizco`). El peor es el
  primer paso del touchpad, en vertical, y no el cruce: es del instrumento (el desplazamiento
  redondeado a píxeles en la ventana real), no del código. La diferencia de O-119-1 la mide la
  prueba de widgets.

#### A · O-128-4: el plano suelta el pellizco cuando pierde el foco

- **Las pruebas** (grupo O-128-4, tres): un pellizco del touchpad sin su `panZoomEnd` y la app a
  `inactive`: la columna se suelta y la rueda la mueve; dos contactos de la pantalla sin `up`: se
  olvidan y la rejilla vuelve a desplazarse; un gesto del touchpad nuevo con el viejo abierto lo
  cierra al empezar.
- **Contra `261ee4b` fallan las tres.**
- **El cambio:** `_PlanZoomViewportState` crea un `AppLifecycleListener` (`onInactive`,
  `onHide`, `onPause`) que suelta todo: la escala del touchpad (la escala se queda donde quedó),
  `pellizcoDelPlanoProvider` y los contactos. `PointerPanZoomStart` cierra el gesto viejo.
- **Un matiz que la prueba fija como es:** el gesto nuevo que cierra al viejo **no desplaza** —
  la columna ya lo repartió cuando estaba congelada, sin su reconocedor de arrastre —; desplaza
  el siguiente. Es el respaldo: con el ciclo de vida, al volver el foco ya está todo suelto.
- **En la app de verdad, con una pérdida de foco real** (escenario `foco`: empieza un pellizco
  del touchpad sin su final y espera):
  - **Windows**, minimizando y restaurando la ventana del banco por su PID: en la punta
    (`windows/punta-foco-2`) el ciclo pasa por `hidden`, `inactive` y `resumed`, **el pellizco
    sigue abierto y la rueda no mueve la columna** (37.2 → 37.2); en la entrega
    (`windows/final-foco`) se suelta y la rueda la mueve (37.2 → 137.2).
  - **La Web:** la primera corrida (`web/final-foco`) no sirvió: Playwright emula el foco y la
    página nunca lo perdía. Con la emulación apagada y la ventana de Chrome minimizada de verdad
    (`web/final-foco-2`), la página pasa a `inactive` y vuelve a `resumed`, el pellizco se suelta
    y la rueda mueve la columna (37.2 → 137.2). En la Web, perder el foco **sí** llega como
    `inactive`. La Web de la punta no la corrí.
  - La primera corrida de la punta en Windows (`windows/punta-foco`) la cortó mi arnés al leer
    una línea a medio escribir; lo corregí y la repetí (`punta-foco-2`).

#### B · O2: los segmentos de `BsSelectorDeModo` dicen su nombre una vez

- **El cambio** (`bs_selector_de_modo.dart`): el segmento sin `tooltip`; el icono y el rótulo con
  su `Tooltip` fuera de la semántica; el nombre, el entero con su cuenta entera, una vez
  (`BsEntradaDeModo.nombreEntero`: «Descarga, 28 por bajar en GTSTC»), y la ayuda como pista.
  La geometría no cambia.
- **La prueba** (`test/t120_selector_nombre_test.dart`, cuatro): cada segmento, de día y de
  noche, con su nombre una vez, sin descripción emergente en la semántica y la ayuda como pista;
  la descripción emergente sigue con el mouse; y en la cabecera de la oficina a 1920 dp ningún
  segmento lleva la descripción emergente. **Contra `261ee4b` fallan las cuatro.**
- **El árbol de Windows, antes y después** (`build/t120/e2/o2/`, el instrumento de T-117
  `t117_correccion2_windows.ps1`, con el banco abierto en el Plano, sin tocar el mouse; la
  ventana quedó en 1539 dp, el ancho de la pantalla, y la cabecera lleva segmentos):

| | `261ee4b` | Entrega 2 |
|---|---|---|
| Modo del plano | «botón Contenido. Contenido. El destino de cada contenedor» | «botón Contenido» |
| | «botón Orden. Número de orden. Sin listado de la agencia. Los OR del listado de la agencia» | «botón Número de orden, Sin listado de la agencia» |
| | «botón Carga 977. Carga. 977 pendientes: … Toca un contenedor o busca su OR para cargarlo» | «botón Carga, 977 pendientes: 977 llenos, 0 vacíos» |
| Colorear por | «botón Destino. Destino. El puerto de descarga de cada contenedor» | «botón Destino» |

  Lo mismo en MSAA. El resto del árbol no cambia (224 nodos de UIA y 240 de MSAA en los dos).
- **Lo que contradice mi propuesta (1.6.1), y lo digo antes que nada:** escribí que Windows da
  la pista «como descripción y no como nombre». **No la da.** En los dos bancos, ni el
  `HelpText` de UIA ni `accDescription` ni `accHelp` de MSAA traen nada en ningún segmento
  (`o2/*/descripcion.txt`). Antes la ayuda llegaba solo porque iba pegada al nombre, repetida;
  **ahora, en Windows, el lector oye el nombre sin la ayuda**, que queda en la descripción
  emergente con el mouse. Es lo mismo que pasa con «Acciones» desde la 10.45. La propiedad
  `FullDescription` de UIA no la pude leer con la API administrada. Corregí el comentario del
  código, el de la prueba y `DESIGN.md` 14.6. **Decide Carlos** (abajo, «Para quien acepte»).

#### C · Los dos monitores: pendientes

Carlos no pudo en esta sesión. **No los doy por vistos.** Queda listo:
- `tool/t120_monitores.ps1`: abre el banco de depuración con el escenario `monitores` (el Plano
  con zoom a 150 % y la rejilla desplazada, quieto), y mientras Carlos arrastra, sondea cada
  medio segundo la ventana de ese proceso (por su PID): monitor, DPI, rectángulo del cliente,
  maximizada o minimizada, con una captura (`PrintWindow`) en cada cambio. El conductor anota el
  tamaño lógico, la densidad, el zoom, los desplazamientos y cada error de Flutter (en
  depuración, los desbordes).
- Los pasos de 1.7 y los comandos, abajo en «Para quien acepte». El banco de depuración no lo
  compilé, para no ocupar disco sin uso (unos 9 GB, por el SDK de Firebase).

#### D · Lo que dejó la aceptación de la entrega 1

**D9 precisada (`DESIGN.md` 18.5) y la prueba de la lista corta.**
- 18.5 dice ahora «con su título arriba de lo que se ve, o con toda la lista a la vista cuando no
  hay más que desplazar».
- `test/t120_e2_lista_test.dart`, ocho casos: «Sin destino» con una y con dos tarjetas, y un
  puerto (VELAG) con una y con dos, a 1366 × 690 y a 360 × 800, con la letra a 1.0. El título a
  la vista, cada tarjeta entera dentro de la vista (su cuerpo, sin el margen) y el título arriba
  o el desplazamiento en su tope. **Pasan con el código de hoy y contra `261ee4b`:** fijan lo
  que ya estaba bien. **La última tarjeta se ve entera:** se confirma la lectura de Yov de la
  10.154; los «40 a 48 dp cortados» eran de la sonda.
- **En pantalla** (`T120_LISTA_CORTA.edi`: 200 contenedores, dos de VELAG y dos sin destino), en
  Windows y en la Web, de día y de noche: el título queda a 272 dp a 1366 y a 178 o 240 dp a 360,
  con el desplazamiento en su tope, y las dos tarjetas enteras (la de abajo termina a 598 dp de
  una vista de 626, y a 636 de 664).

**La Lista con una matrícula repetida.**
- **Qué enseña** (`T120_REPETIDA.edi`: doce contenedores, el 3.º y el 5.º con TSTU0000003, en
  002-03-82 y 002-05-82):
  - arriba, en el resumen del viaje, el aviso del lector: «Matrículas repetidas en EQD: 1
    contenedor · revisa esas celdas con quien hizo el plan»;
  - el título **«Contenedores (12)»**: cuenta las celdas, no las matrículas (11);
  - **dos tarjetas, una por celda**, cada una con su naviera y su posición: «TSTU0000003 · LNB ·
    Bahía 002, Fila 03, Nivel 82» y «TSTU0000003 · LNC · Bahía 002, Fila 05, Nivel 82». Ninguna
    dice que la matrícula está repetida.
  - Las dos tarjetas llevan la misma clave (`tarjeta-TSTU0000003`), pero la lista se reconstruye
    bien con un filtro que deja una sola y al soltarlo, sin excepción.
- **No lo veo como un defecto:** la Lista enseña lo que trae el archivo, celda por celda; el
  aviso está arriba y el plano marca las dos celdas desde T-147. Lo dejo como observación,
  O-120-6.
- **Por qué la sonda de GLM daba 0 tarjetas:** con un buque chico, lo de arriba de la Lista llena
  la vista, y la lista perezosa no construye ninguna tarjeta hasta que se baja.
- **La prueba,** a 1366 y a 360: recorre la Lista entera y fija las doce tarjetas, las dos de la
  repetida con su posición, el título, el aviso y la reconstrucción con el filtro. Pasa también
  contra `261ee4b`.

**O-120-4: el cuadro con la Lista arriba.**
- **Se veía, en Windows y en la Web.** Escenario `capturas` con el buque de 977: el conductor
  toca la barra de PAMIT y captura, por dentro, los cuatro cuadros que siguen, sin esperar.
  - Por dentro: en el cuadro 1 la Lista se pinta con el título a 816 dp del borde de arriba de la
    vista a 1366, y a 1186 dp a 360; desde el cuadro 2, a 0 dp.
  - **En la pantalla de Windows** (`windows/977-antes-o1204/ventana.mkv`, `gdigrab` de la ventana
    a 60 cuadros por segundo; la hoja `hoja-claro1366-cuadros-16-17-26-29.png`): el cuadro 26 es
    Estadísticas, **el 27 es la Lista arriba, con el resumen del viaje, los botones y los
    filtros**, y el 28 ya es el título.
  - **En la pantalla de Chrome** (`web/977-antes-o1204`, el *screencast* de Chrome; la hoja
    `hoja-cuadros-2189-2194.png`): el 2189 es Estadísticas, **el 2190 es la Lista arriba** y el 2191,
    el título.
- **El cambio** (`vessel_overview_page.dart`): al llegar desde una barra, la Lista se dispone
  pero no se pinta (opacidad cero) hasta que salta a su título, en el cuadro siguiente. Por el
  riel o la barra se ve desde el primer cuadro.
- **La prueba** (tres): en el cuadro que sigue al toque, la Lista no se pinta o el título está
  arriba; en el siguiente, se ve con el título arriba (a 1366 y a 360); y por el riel se ve desde
  el primer cuadro. **Contra `261ee4b` fallan las dos primeras**: «se pinta la Lista con el
  título a 661 dp» (1029 a 360).
- **Después, en pantalla:**
  - por dentro, el cuadro 1 enseña la columna central vacía (el fondo), con la cabecera, el riel y
    el panel (`windows/final-977/capturas/*_o1204_cuadro1_*.png`);
  - en la pantalla de Windows (`windows/final-977/video/hoja-claro1366-cuadros-24-36.png`):
    Estadísticas, después la columna vacía y después el título. **La Lista arriba no sale en
    ningún cuadro.** El vacío ocupa dos cuadros grabados; el conductor, que captura por dentro en
    cada cuadro, los alarga, y sin esa captura no lo medí;
  - en Chrome (`web/final-977/hoja-cuadros-tras-el-toque.png`): Estadísticas y después el título,
    sin la Lista arriba ni el vacío. El *screencast* manda los cuadros cuando se le confirman y
    puede saltarse alguno: no afirmo que el vacío no exista en la Web.

**O-120-5 (aprobada por Carlos): «Carga especial» con sus tres chips en el teléfono.**
- **El cambio** (`filtros_de_la_lista.dart`): en el teléfono, esa fila envuelve como en la
  oficina, sin «Ver las 3 cargas». Los destinos y las navieras no cambian.
- **La prueba** (dos, a 360 × 800, con la letra a 1.0 y a 2.0): los tres chips se ven y se tocan,
  sin «Ver las 3 cargas», y los destinos y las navieras siguen con lo suyo. **Contra `261ee4b`
  fallan las dos.**
- **Cambia una prueba de la entrega 1,** `test/t120_filtros_matriz_test.dart`: en el teléfono
  esperaba tres filas en `BsFichasEnLineas` y ahora son dos. Lo demás no se afloja: dos líneas
  como mucho, «Ver los n destinos» y nada fuera de la pantalla; además pide los tres chips de
  carga. Contra `261ee4b` fallan sus seis casos del teléfono. Ese registro lo sobrescribió una
  corrida posterior y no quedó guardado.
- **En pantalla** (Windows y la Web, de día y de noche, a 360 con la letra a 1.0 y a 2.0): los
  tres chips enteros, uno por renglón, con su ícono y su cuenta; «Ver las 4 navieras» y «Ver los
  10 destinos» siguen. **Lo que se ve y anoto:** a 360 dp con la letra a 1.0, dos chips no
  caben juntos en 328 dp, así que la fila pasa de dos renglones a tres, y la Lista baja unos
  56 dp. Suma a O-120-2.

### E2.4 Los bancos y cómo se miró

- **Las entradas:** `tool/t120e2_buques.dart` escribe en `%TEMP%\t120-e2\caso` el buque de 977 de
  la entrega 1, la lista corta y la repetida, y las verifica con el lector (977/977; 200 con VELAG
  2 y sin destino 2; 12 contenedores con 11 matrículas y el aviso `duplicate`). Es carga de
  prueba sintética.
- **El banco:** `tool/t120e2_main.dart` y `tool/t120e2_conductor.dart`, con los helpers de
  plataforma de T-147 sin tocarlos. Namespace `r4`; en Windows, el almacén en `%TEMP%`, uno por
  corrida; sin nube. Copia del árbol con `t99_copia.ps1 -Arbol -Sufijo r4` en
  `%TEMP%\t120-e2\banco`, con `lib/` y el conductor iguales a la carpeta (comprobado con `diff`).
  Windows y Web en *release*.
- **Windows:** `tool/t120e2_windows.py` (el de T-147 con la salida en `build/t120/e2`, `--foco` y
  `--grabar`).
- **La Web:** `tool/t120e2_web.py` y `tool/t120e2_servidor.py` (los de T-147), solo contra
  `127.0.0.1:5948`, **cada corrida con su perfil nuevo de Chrome** (el arnés borra el perfil
  antes) y el *service worker* borrado antes de cargar. **Cómo comprobé que corrió el programa de
  la carpeta:** el arnés anota en `navegador.json` la huella del `main.dart.js` que cargó la
  página y la del que se sirve, y falla si son distintas. En las siete corridas de la Web son
  iguales: `809bcc6e…` en `977-antes-o1204` y `2f7ad0c3…` en las seis finales.
- **El banco de la punta** (para O-128-4 y O2 «antes»): la copia limpia de `261ee4b` más
  `t120e2_main.dart` y `t120e2_conductor.dart`; su `lib/` es el de `261ee4b` en sus 212 archivos,
  por la huella.
- **Las corridas** (todas terminan en «fin», sin errores de Flutter ni textos que no caben;
  `build/t120/e2/resumen-final.txt`, de `tool/t120e2_resumen.py`): en Windows y en la Web,
  `final-977` (30 capturas), `final-corta` (8), `final-repetida` (12), `final-pellizco` (8) y
  `final-foco`; además `977-antes-o1204` en los dos y `final-foco-2` en la Web.
- **Lo que miré con mis ojos,** imagen por imagen: los cuadros 1 y 2 de O-120-4 antes y después;
  las tres hojas de la grabación y del *screencast*; O-120-5 a 360 de día (letra 1.0) y de noche
  (letra 2.0); la lista corta de VELAG a 360 de día (Windows) y la de «Sin destino» a 1366 de
  noche (Web); la repetida a 360 de día (el aviso) y a 1366 (la segunda tarjeta, Web). Las demás
  capturas tienen sus cifras en los registros, pero no las abrí una por una.
- **El *screencast* de la Web** se recortó a los cuadros de 1 s antes a 1 s después de cada toque
  (`pantalla-conservada.json`); la evidencia queda en 243 MB.

### E2.5 Las pruebas nuevas (27) y las rojas

| Archivo | Pruebas | Contra `261ee4b` |
|---|---|---|
| `test/t120_pellizco_test.dart` | 5 de O-119-1 y 3 de O-128-4 | **fallan 5 de 8** (2 y 3); pasan la Web, las ráfagas y alejar |
| `test/t120_selector_nombre_test.dart` | 4 de O2 | **fallan 4 de 4** |
| `test/t120_e2_lista_test.dart` | 8 de la lista corta, 2 de la repetida, 2 de O-120-5 y 3 de O-120-4 | **fallan 4 de 15** (O-120-5 y O-120-4); pasan las 11 que fijan lo que ya estaba bien |

- **Rojas en total: 13 de 27, cada una en su comprobación.** Ninguna es de compilación: solo usan
  piezas que ya estaban. Registros en `build/t120/e2/rojas/`, corridos en la copia limpia de
  `261ee4b` con el archivo de prueba copiado.
- **Cambia:** `test/t120_filtros_matriz_test.dart` (O-120-5).

### E2.6 Validaciones

| Qué | Resultado | Registro (`build/t120/e2/`) |
|---|---|---|
| La suite completa en la carpeta, después del último cambio (23:26:13 a 23:28:08) | **2558 de 2558**, sin omitidas ni fallidas | `suite-carpeta.txt` |
| `flutter analyze --no-pub` en la carpeta | **«No issues found!»** | `analyze-carpeta.txt` |
| La copia limpia: `261ee4b` + las 17 rutas, iguales por su huella, + la entrada de T-124; `pub get --offline --enforce-lockfile` (el lock, igual al del commit) | `analyze` **«No issues found!»**; suite **2558 de 2558** | `copia-limpia-*.txt`, `copia-limpia-final-manifiesto.json` |
| `// ignore:` | Ninguno | |
| `pubspec.*`, `lib/main.dart`, los congelados, `domain/`, `data/`, `web/`, `windows/`, los archivos de T-147 | **No cambian** | `git diff --stat` |

- **Una corrida anterior de la suite dio 2559** con tres avisos de `analyze`: eran de mi sonda
  temporal (`test/t120_sonda977_test.dart`). La borré y repetí las dos.

### E2.7 Lo que no se pudo, y lo que queda anotado

- **Los dos monitores:** pendientes (C).
- **Los 1.9 dp de Codex en Chrome (O-119-1) no se reprodujeron.** El pellizco de la Web en las
  pruebas, sin el cambio, ya daba 0.000 (0.081 en ráfagas). Lo que arreglé es el touchpad. Si lo de
  Chrome viene de otra cosa, solo lo dice un pellizco de verdad en Chrome. El escenario `mano` del
  conductor mide los gestos de una persona, cuadro por cuadro; no lo corrí: hace falta la mano de
  Carlos.
- **O-119-1 en la app de verdad:** el banco no distingue la punta de la entrega (A).
- **Android:** no se tocó ni se miró. El pellizco de dos dedos y el ciclo de vida están en las
  pruebas.
- **O-120-6 (nueva, P3): la tarjeta de una matrícula repetida no lo dice.** La Lista enseña las
  dos celdas como dos contenedores cualesquiera; el aviso está solo arriba. Una marca en la
  tarjeta, como la celda del plano, ayudaría a encontrarlas desde la Lista.
- **O-120-5 hace la fila de carga más alta** en el teléfono con la letra a 1.0 (tres renglones en
  vez de dos): suma a O-120-2.
- **O2: en Windows, la ayuda del segmento ya no se oye** (B). Decide Carlos.

### E2.8 Archivos

**Cambiados (6):**
- `DESIGN.md`: 14.6 (O2), 16.2 (O-128-4), 16.3 (O-119-1), 18.3 (O-120-5) y 18.5 (D9 precisada y
  O-120-4). 18.3 no estaba en la lista de 1.11 de mi propuesta; es la sección de T-120 y dice
  cómo se ven las filas en el teléfono, que O-120-5 cambia. **14.9 (los monitores) no se toca**
  hasta que se vean.
- `lib/core/design/componentes/bs_selector_de_modo.dart`: O2.
- `lib/features/vessel/presentation/pages/vessel_overview_page.dart`: O-120-4.
- `lib/features/vessel/presentation/widgets/filtros_de_la_lista.dart`: O-120-5.
- `lib/features/vessel/presentation/widgets/plan_drag_confirmation.dart`: O-119-1 y O-128-4.
- `test/t120_filtros_matriz_test.dart`: O-120-5.

**Nuevos (11):** `test/t120_e2_lista_test.dart`, `test/t120_pellizco_test.dart`,
`test/t120_selector_nombre_test.dart`, `tool/t120_monitores.ps1`, `tool/t120e2_buques.dart`,
`tool/t120e2_conductor.dart`, `tool/t120e2_main.dart`, `tool/t120e2_resumen.py`,
`tool/t120e2_servidor.py`, `tool/t120e2_web.py` y `tool/t120e2_windows.py`.

Y este informe. **`pubspec.yaml` y `pubspec.lock` no cambian.** Fuera de Git: `build/t120/e2/`
(243 MB) y `%TEMP%\t120-e2\` (13 GB contando los enlaces del SDK de Firebase; se puede borrar
entera cuando se acepte, salvo `caso\` si se quieren los monitores).

### E2.9 Horas

Del reloj, el 21-nov: de las 22:10, más o menos (no anoté el inicio; la copia del paso 0 es de las
22:16), a las 23:40, una hora y media. El paso 0 terminó a las 22:19.
De ese tiempo, unos 25 minutos fueron de máquina: tres compilaciones de Windows, dos de la Web,
las corridas y cuatro suites completas.

### E2.10 Para quien acepte

1. **La suite y `analyze`** en una copia limpia de la punta con este bloque: 2558, sin omitidas,
   con la entrada de T-124.
2. **Las rojas:** los tres archivos nuevos en una copia de `261ee4b` (13 de 27; E2.5), y la
   matriz cambiada (seis del teléfono).
3. **El pellizco con el touchpad de verdad**, en Windows y en Chrome, sobre todo desde el 100 %
   hasta que la bahía deja de caber, y Alt + Tab a media seña. En el banco:
   ```powershell
   python -X utf8 tool/t120e2_windows.py --exe "$env:TEMP\t120-e2\banco\build\windows\x64\runner\Release\baystream.exe" --almacen "$env:TEMP\t120-e2\almacenes\mano-1" --caso "$env:TEMP\t120-e2\caso" --salida build/t120/e2/windows/mano-1 escenario=mano archivo=T120_BUQUE_LISTA_977.edi tope=180
   ```
   anota en `pasos.jsonl` cada gesto con su peor desvío, cuadro por cuadro.
4. **O2:** decidir si la ayuda va una vez detrás del nombre para que el lector de Windows la
   diga (hoy no la dice, B); y mirar en la Web qué hace el lector con la pista, que no medí.
5. **Los dos monitores, con Carlos** (1.7): compilar el banco de depuración y abrirlo con el script:
   ```powershell
   flutter build windows --debug --no-pub -t tool/t120e2_main.dart
   ```
   (en `%TEMP%\t120-e2\banco`), y después
   ```powershell
   ./tool/t120_monitores.ps1 -Exe "$env:TEMP\t120-e2\banco\build\windows\x64\runner\Debug\baystream.exe" -Almacen "$env:TEMP\t120-e2\almacenes\monitores-1" -Caso "$env:TEMP\t120-e2\caso" -Salida build/t120/e2/monitores/1
   ```
   Carlos: el Plano en la laptop → al otro monitor → maximizar allí (Win + Mayús + →) → media
   pantalla (Win + ← y →) → a medias entre los dos → de vuelta; y lo mismo en la Lista y en
   Estadísticas. Se mira `monitores.jsonl`, `pasos.jsonl` (los errores de Flutter) y las
   capturas.
6. **O-120-4 sin la captura por dentro:** si el cuadro vacío se nota en una pantalla real.

### E2.11 Git

Para que lo ejecute Carlos. Fuera quedan los cuatro archivos que solo cambian el fin de línea y las
carpetas sin seguimiento de `docs/`.

```powershell
git add -- DESIGN.md
git add -- lib/core/design/componentes/bs_selector_de_modo.dart
git add -- lib/features/vessel/presentation/pages/vessel_overview_page.dart
git add -- lib/features/vessel/presentation/widgets/filtros_de_la_lista.dart
git add -- lib/features/vessel/presentation/widgets/plan_drag_confirmation.dart
git add -- test/t120_filtros_matriz_test.dart
git add -- test/t120_e2_lista_test.dart
git add -- test/t120_pellizco_test.dart
git add -- test/t120_selector_nombre_test.dart
git add -- tool/t120_monitores.ps1
git add -- tool/t120e2_buques.dart
git add -- tool/t120e2_conductor.dart
git add -- tool/t120e2_main.dart
git add -- tool/t120e2_resumen.py
git add -- tool/t120e2_servidor.py
git add -- tool/t120e2_web.py
git add -- tool/t120e2_windows.py
git add -- docs/T120-RESULTADOS.md
git commit -m "Sprint 4: T-120, entrega 2: el plano suelta el pellizco al perder el foco y no salta en el cruce, los segmentos dicen su nombre una vez, la Lista no se pinta arriba antes del salto desde Estadisticas, carga especial con sus tres chips en el telefono y las pruebas de la lista corta y de la matricula repetida"
git push origin sprint-4
```

### E2.12 En tres líneas

- El pellizco: O-119-1 y O-128-4 confirmados con pruebas rojas y corregidos; O-128-4, además, visto
  en Windows y en la Web con una pérdida de foco real.
- O2, O-120-4 y O-120-5 hechos y mirados en pantalla; O2 dejó a la vista que Windows no lee la
  pista, y la ayuda del segmento ya no se oye ahí (decide Carlos).
- Suite 2558/2558 y `analyze` en cero aquí y en copia limpia; 13 de 27 rojas contra `261ee4b`;
  los dos monitores, pendientes.

### E2.13 Mensaje para Yov

> Yov, la entrega 2 de T-120 está al final de `docs/T120-RESULTADOS.md` («Entrega 2 · El plano y
> la oficina», E2.1 a E2.13), sobre `261ee4b`, sin commit. Paso 0: `analyze` cero y 2531/2531 con
> T-120 y T-147 juntas. O-119-1 salió rojo antes de tocar nada (0.562 dp en horizontal y 0.740 en
> vertical, con el touchpad: un `jumpTo` fuera del alcance medido arma una simulación que
> devuelve al tope viejo antes de medir el nuevo); se corrige con `correctPixels` fuera del
> alcance. Los 1.9 dp de Chrome no se reprodujeron en pruebas. O-128-4: el plano suelta el
> pellizco al perder el foco; visto en Windows (minimizando) y en la Web (con la emulación del
> foco de Playwright apagada). O2: en el árbol de Windows cada segmento dice su nombre una vez,
> pero **la pista no la expone Windows**, así que la ayuda ya no se oye ahí: lo decide Carlos.
> O-120-4 se veía en Windows y en la Web (grabación y *screencast*) y ya no se pinta; O-120-5,
> hecho. La lista corta y la repetida pasan también contra la punta: la última tarjeta se ve
> entera, y la repetida enseña dos tarjetas, una por celda (O-120-6, nueva, P3). 27 pruebas
> nuevas, 13 rojas; suite 2558/2558; `analyze` cero aquí y en copia limpia. Los monitores quedan
> pendientes, con el script listo.

**ALTO: Yov revisa y GLM acepta.**

---

## Corrección 1 de la entrega 2 (22-nov; 10.170)

### C2.1 Resultado en tres líneas

- **T120-E2-01:** la clave de cada tarjeta de la Lista lleva ahora su celda; con la matrícula en
  dos o en tres celdas, el filtro y su vuelta ya no rompen la Lista (rojo antes, en las dos).
- **O2 en Windows:** el nombre de cada segmento lleva la ayuda una vez detrás; en la Web se queda
  como pista, porque el lector de Chrome sí la recibe como descripción. Además, un hallazgo de D1
  corregido con la pista de Yov: un dedo vuelve a desplazar la rejilla tras dos contactos que
  nunca se levantaron.
- **Suite 2563 de 2563** (2558 + 5), sin omitidas, y `analyze` en cero, aquí y en una copia
  limpia; 8 de 32 pruebas rojas contra `1a7b03b`. **Los dos monitores y el pellizco de verdad
  siguen pendientes** (Carlos no pudo hoy).

### C2.2 Paso 0

- La punta: `1a7b03b` (10.170), debajo `b1d7dae` (la aceptación) y `fcc8302`. Es la esperada.
- La suite no se repitió al empezar (el piso es 2558, de GLM).
- **El disco**, antes de cada compilación: 45 GB libres (las dos de las 14:18 y las dos de las
  14:2x); 44 GB al terminar. No se extrajo otra vez el SDK de Firebase: se usó el banco de
  `%TEMP%\t120-e2\banco`, con `lib/` y `tool/` puestos al día y cotejados con `diff`.
- **Semáforo:** Carlos dio la luz verde de la ventana de desarrollo y de la de los bancos.

### C2.3 Cada punto

#### A · T120-E2-01: una clave por tarjeta, con su celda

- **La prueba, antes de cambiar nada** (`test/t120_e2c1_claves_test.dart`, dos casos): la
  matrícula en **tres** celdas (el caso de GLM: el 3.º, el 4.º y el 7.º) y en **dos** (el 3.º y el
  4.º, los dos de LNB, que es lo que traería un plan de verdad). El filtro de LNB deja dos
  tarjetas de la matrícula a la vista; al soltarlo, la Lista se rearma sin errores del framework,
  las 13 en el orden de antes, una clave por tarjeta, con la celda.
- **Contra `1a7b03b` fallan los dos** (`build/t120/e2c1/rojas/e201-contra-1a7b03b.txt`): con tres
  celdas, el error de GLM, `'child == null || indexOf(child) > index'`, y detrás «RenderSliverPadding
  expected a child of type RenderSliver but received … RenderErrorBox», un `type cast` y
  `'_dependents.isEmpty'`. **Con dos celdas falla igual:** no hace falta una matrícula en tres.
- **La prueba de la repetida de la entrega 2 se pone al día:** fijaba la reconstrucción con las
  dos tarjetas en la misma clave; ahora fija las doce claves distintas, y las de la repetida,
  `tarjeta-TSTU0000003-0020382` y `-0020582`. Contra `1a7b03b` falla (11 claves para 12 tarjetas).
- **El cambio** (`containers_list_view.dart`): `ContainersSliverList.claveDe`, «tarjeta-<matrícula>-
  <celda>» (`IsoCoordinate.toIsoCode()`; sin celda, el `id` del contenedor), en la clave y en
  `findChildIndexCallback`. Lo que se ve no cambia.
- **Quién más usaba la clave:** mi conductor (`t120e2_conductor.dart`, buscaba
  `tarjeta-TSTU0000003` exacta: ahora, por prefijo con la celda) y dos usos por el prefijo
  `tarjeta-`, que siguen valiendo (`t120e2_conductor.dart` y `t120_conductor.dart`). Ninguna prueba
  ni soporte del repositorio la usaba. La sonda de GLM, fuera del repositorio, busca
  `tarjeta-TSTU0000001` exacta: con esta corrección ya no la encuentra.
- **Una cosa de la prueba:** la puse primero en `t120_e2_lista_test.dart` y, contra el código de
  antes, el árbol roto dejaba un `Tooltip` con su ruta de puntero registrada que hacía fallar a las
  pruebas de O-120-4 que venían después en el mismo aislado (solas pasan: 3 de 3). Por eso
  T120-E2-01 va en su propio archivo.
- **En pantalla** (`T120_REPETIDA_TRES.edi`, escrito por `t120e2_buques.dart` en
  `%TEMP%\t120-e2\caso-c1`; Windows y la Web, de día y de noche, a 1366 y a 360): con el filtro de
  LNB, «Contenedores (4), naviera LNB», con las dos tarjetas de TSTU0000003 seguidas, en Fila 03 y
  Fila 04; al soltarlo, «Contenedores (13)» en su orden. Las claves en el orden en que se ven,
  `TSTU0000003-0020382`, `-0020482` … `-0020782`, y **ningún error de Flutter** en las 16
  capturas. Abrí 1366 de día con el filtro (Windows) y 360 de noche soltado (Web).

#### B · La ayuda de los segmentos en Windows (la opción 1 de la 10.169, aprobada por Carlos)

- **El cambio** (`bs_selector_de_modo.dart`): en Windows (la app: `!kIsWeb` y la plataforma del
  tema), el nombre es `BsEntradaDeModo.nombreConAyuda` —el entero, su cuenta y, detrás, la ayuda,
  una vez— y no hay pista. En las demás plataformas, como lo dejé: el nombre entero y la ayuda
  como pista.
- **Las pruebas** (`t120_selector_nombre_test.dart`): las dos de los temas y la de la cabecera
  de la oficina corren ahora en Android y en Windows (3 casos más). **Contra `1a7b03b` fallan las
  tres de Windows**; las de Android pasan.
- **El árbol de Windows, antes y después** (`build/t120/e2c1/o2/`, el instrumento de T-117, con el
  banco en el Plano a 1539 dp): contra el de la entrega 2 **cambian 10 renglones, y nada más**: los
  cinco segmentos, en UIA y en MSAA (`diferencia-con-la-entrega-2.txt`). Ahora: «botón Contenido.
  El destino de cada contenedor», «botón Número de orden, Sin listado de la agencia. Los OR del
  listado de la agencia», «botón Carga, 977 pendientes: 977 llenos, 0 vacíos. Toca un contenedor
  o busca su OR para cargarlo», «botón Destino. El puerto de descarga de cada contenedor» y «botón
  Tipo de vacío. El tipo ISO de los vacíos; los llenos en papel». 224 nodos de UIA y 240 de MSAA,
  como antes.
- **La Web (D2), antes de decidir:** el lector **sí** recibe la ayuda (abajo), así que ahí se
  queda como pista.
- `DESIGN.md` 14.6, al día.

#### C · Los dos monitores y el pellizco de verdad: pendientes

Carlos no pudo en esta sesión. **No los doy por vistos.** Sigue listo lo de E2.10, puntos 3 y 5;
el banco de depuración no lo compilé. `tool/t120_monitores.ps1` acepta la salida en
`build\t120\e2c1`.

#### D · Lo que dejaron las dos revisiones

**D1 · «Un dedo vuelve a desplazar la rejilla»: era un hallazgo, y se corrigió aquí.**
- **La prueba arrastra de verdad:** después de perder el foco con dos contactos puestos, un dedo
  nuevo arrastra la rejilla en seis pasos de 15 dp. **En el producto no se movía: 0.0 dp.**
- **No era del instrumento**, con una sonda de controles (`build/t120/e2c1/d1-sonda-dedo.txt`):
  un dedo sin nada antes, 60 dp; con los dos contactos **cancelados** (lo que suele mandar el
  sistema), 60 dp; con dos contactos sin levantar y pérdida de foco, 0.0 en la rejilla (y la
  columna, 90, sin el umbral del gesto); con un solo contacto viejo, la rejilla 60 y la columna
  0.0. Las arenas de gestos de los contactos viejos seguían abiertas.
- **Lo dije antes de corregirlo; Carlos pidió corregirlo aquí,** con tope de 30 minutos y la pista
  de Yov, para comprobar: de las 14:05 a las 14:07.
- **El cambio** (`plan_drag_confirmation.dart`, `_soltarTodo`): los contactos que siguen puestos
  al perder el foco se cancelan también en Flutter (`GestureBinding.instance.cancelPointer`, como
  el `Navigator`). Solo corre al perder el foco con contactos puestos; el pellizco normal no pasa
  por ahí.
- **Después:** los ocho casos de la sonda, 60 dp en la rejilla y en la columna
  (`d1-sonda-dedo-despues.txt`), y la prueba pasa (60.0 dp). Contra `1a7b03b` falla.
- **Lo que cambia, y lo digo:**
  - **un solo contacto viejo:** antes la columna no se movía después (0.0); ahora, sí;
  - **un arrastre de una celda a medias:** antes, si la ventana perdía el foco a medio arrastre, el
    arrastre seguía y al soltar salía la confirmación del movimiento; **ahora se cancela**: al
    soltar no sale nada y no se registra nada. Es lo mismo que si el sistema cancelara el
    contacto. Lo miré con una sonda sobre el arnés de T-105, aquí y en la copia de la entrega 2.
- **Siguen en verde** las de T-119, las del pellizco (O-119-1 y O-128-4) y las de arrastre
  (T-105, T-106, T-122 y T-123): 59 de 59 (`d1-pruebas-vecinas.txt`).

**D2 · Lo que recibe el lector en la Web** (`web/selector/arbol-chrome.json`, el árbol de
accesibilidad de Chrome con la semántica de Flutter encendida, a 1920 × 1000):

| Segmento | Rol | Nombre | Descripción |
|---|---|---|---|
| Contenido | `radio` | Contenido | El destino de cada contenedor |
| Número de orden | `radio` | Número de orden, Sin listado de la agencia | Los OR del listado de la agencia |
| Carga | `radio` | Carga, 977 pendientes: 977 llenos, 0 vacíos | Toca un contenedor o busca su OR para cargarlo |
| Destino («Colorear por») | `radio` | Destino | El puerto de descarga de cada contenedor |
| Tipo de vacío | `radio` | Tipo de vacío | El tipo ISO de los vacíos; los llenos en papel |

El nombre, una vez, y la ayuda como descripción: en la Web la pista llega. Es el árbol, no un
lector hablando.

**D3 · La descripción emergente con el mouse** (la Web, 1920 × 1000; `web/selector/raton/` y la
hoja `hoja-raton.png`, que miré):
- **sobre el icono:** sale («Contenido. El destino de cada contenedor»; «Carga. 977 pendientes:
  977 llenos, 0 vacíos. Toca un contenedor o busca su OR para cargarlo»);
- **sobre el rótulo:** sale la misma; en «Colorear por», «Destino. El puerto de descarga de cada
  contenedor»;
- **sobre el borde del segmento** (a 4 dp de su borde izquierdo): **no sale**; el segmento se
  resalta. No lo cambié.

**D4 · O-120-4 sin la captura por dentro** (escenario `parpadeo`, seis toques de la barra de
PAMIT, la ventana grabada con `gdigrab`; `windows/parpadeo/video/columna-vacia.json`):
- la grabación no es un 60 limpio: pierde cuadros (unos 45 por segundo efectivos). Cada cuadro
  extraído lleva su marca a 60 por segundo;
- **en los tres toques sin huecos, la columna vacía dura dos cuadros (≈ 33 ms)**; en los otros
  tres, uno o dos cuadros grabados con huecos al lado (entre 33 y 50 ms). No es uno solo, como
  esperaba el código: el cuadro siguiente, el del salto, construye las tarjetas y tarda más;
- lo vi en la hoja del toque 1 (`hoja-toque1-cuadros-46-51.png`): 46 y 47 Estadísticas, **48 y 49
  la columna vacía** con la cabecera, el riel y el panel, y desde el 50 el título y las tarjetas.

### C2.4 Las pruebas nuevas y las rojas

| Archivo | Qué | Contra `1a7b03b` |
|---|---|---|
| `test/t120_e2c1_claves_test.dart` (nuevo) | T120-E2-01, con dos y con tres celdas (2) | **fallan 2 de 2** |
| `test/t120_selector_nombre_test.dart` | los tres casos de Windows (3 nuevos) | **fallan 3**; pasan las 4 de antes |
| `test/t120_e2_lista_test.dart` | la repetida fija una clave por tarjeta (cambia) | **fallan las 2** |
| `test/t120_pellizco_test.dart` | los dos contactos arrastran de verdad (cambia) | **falla 1** |

- **8 de 32 rojas** en los cuatro archivos, cada una en su comprobación y ninguna de compilación
  (`rojas/correccion1-contra-1a7b03b.txt`, en una copia con el `lib/` de `1a7b03b`).
- La suite sube en 5: 2558 → 2563.

### C2.5 Validaciones

| Qué | Resultado | Registro (`build/t120/e2c1/`) |
|---|---|---|
| La suite en la carpeta, después del último cambio (hasta las 14:31:09) | **2563 de 2563**, sin omitidas | `suite-carpeta.txt` |
| `flutter analyze --no-pub` en la carpeta | **«No issues found!»** | `analyze-carpeta.txt` |
| La copia limpia: `git archive 1a7b03b` + las 13 rutas, iguales por su huella, + la entrada de T-124; `pub get --offline --enforce-lockfile`, el lock igual | `analyze` **«No issues found!»**; suite **2563 de 2563** | `copia-limpia-*.txt`, `copia-limpia-manifiesto.json` |
| La Web: el programa que cargó la página | En las dos corridas, `1dd1344c…`, el de la carpeta que se sirve; cada una con su perfil nuevo | `web/*/navegador.json` |
| `// ignore:` | Ninguno | |
| `pubspec.*`, `lib/main.dart`, los congelados, los archivos de T-147, `DESIGN.md` 17.7 | **No cambian** | `git diff --stat` |

### C2.6 Lo que no se pudo y lo que queda anotado

- **Los dos monitores y el pellizco de verdad:** pendientes (C). Los 1.9 dp de Chrome siguen sin
  verse ni descartarse.
- **D1 cambia el arrastre de una celda a medias:** se cancela si la ventana pierde el foco (arriba).
- **La descripción emergente no sale en el borde del segmento** (D3).
- **El vacío de O-120-4 dura dos cuadros, no uno** (D4).
- **Las sondas temporales** (`t120_sonda_dedo_test.dart` y `t120_sonda_arrastre_test.dart`) se
  borraron; sus salidas quedan en `build/t120/e2c1/`.

### C2.7 Archivos

**Cambian (12):** `DESIGN.md` (14.6 y 18.4), `lib/core/design/componentes/bs_selector_de_modo.dart`,
`lib/features/vessel/presentation/widgets/containers_list_view.dart`,
`lib/features/vessel/presentation/widgets/plan_drag_confirmation.dart`,
`test/t120_e2_lista_test.dart`, `test/t120_pellizco_test.dart`, `test/t120_selector_nombre_test.dart`,
`tool/t120e2_buques.dart`, `tool/t120e2_conductor.dart`, `tool/t120e2_servidor.py`,
`tool/t120e2_web.py` y `tool/t120e2_windows.py`.

**Nuevo (1):** `test/t120_e2c1_claves_test.dart`. Y este informe. **`pubspec.*` no cambia.**
`DESIGN.md` 14.9 espera a los monitores; 17.7 no se tocó.

**Fuera de Git:** `build/t120/e2c1/` (118 MB). En `%TEMP%\t120-e2\`, **13 GB en total** (los
enlaces del SDK de Firebase cuentan una vez): `banco\` (10 GB, el banco de Windows y su SDK; se
queda para los monitores), `limpia\` (11 GB contando el SDK enlazado: la copia de `261ee4b` con su
banco de la punta), `limpia-c1\` y `limpia-final\` (unos 210 MB cada una), `perfiles\` (374 MB),
`web-antes-o1204\`, `web-final\` y `web-c1\` (37 MB cada una), `caso\` y `caso-c1\` (las entradas
sintéticas) y `almacenes\` (6 MB). Cuando se acepte, todo menos `banco\` y `caso\` se puede borrar,
mejor desde el Explorador (traen enlaces).

### C2.8 Horas

Del reloj, el 22-nov: de las 13:35, más o menos (no anoté el inicio; la primera roja es de las
13:41), a las 14:40. D1, de las 14:05 a las 14:07. Los bancos, de las 14:18 a las 14:28.

### C2.9 Para quien acepte

1. La suite y `analyze` en una copia limpia de la punta con este bloque: 2563, sin omitidas, con
   la entrada de T-124.
2. Las rojas: los cuatro archivos en una copia con el `lib/` de `1a7b03b` (8 de 32).
3. A en pantalla: `T120_REPETIDA_TRES.edi` (`dart tool/t120e2_buques.dart <carpeta nueva en
   %TEMP%>`), el filtro de LNB y su vuelta, en Windows y en la Web.
4. B: el árbol de Windows de los segmentos; y, si se puede, un lector de pantalla hablando, en
   Windows y en Chrome (lo medido es el árbol).
5. D1: el arrastre de una celda a medias con pérdida de foco, que ahora se cancela.
6. Los monitores y el pellizco de verdad, con Carlos (E2.10, puntos 3 y 5).

### C2.10 Git

Para que lo ejecute Carlos. Fuera quedan los archivos que solo cambian el fin de línea
(`test/t114_fase3_correccion_test.dart` y tres de `windows/flutter/`) y las carpetas sin
seguimiento de `docs/`.

```powershell
git add -- DESIGN.md
git add -- lib/core/design/componentes/bs_selector_de_modo.dart
git add -- lib/features/vessel/presentation/widgets/containers_list_view.dart
git add -- lib/features/vessel/presentation/widgets/plan_drag_confirmation.dart
git add -- test/t120_e2_lista_test.dart
git add -- test/t120_e2c1_claves_test.dart
git add -- test/t120_pellizco_test.dart
git add -- test/t120_selector_nombre_test.dart
git add -- tool/t120e2_buques.dart
git add -- tool/t120e2_conductor.dart
git add -- tool/t120e2_servidor.py
git add -- tool/t120e2_web.py
git add -- tool/t120e2_windows.py
git add -- docs/T120-RESULTADOS.md
git commit -m "Sprint 4: T-120, correccion 1 de la entrega 2: la clave de la tarjeta lleva su celda, la ayuda de los segmentos en el nombre en Windows, el plano cancela los contactos al perder el foco y las mediciones de la Web, la descripcion emergente y la columna vacia"
git push origin sprint-4
```

### C2.11 En tres líneas

- T120-E2-01 corregido: la clave lleva la celda; rojo antes con la matrícula en dos y en tres
  celdas, y en pantalla sin errores en Windows y en la Web.
- O2 en Windows con la ayuda detrás del nombre (10 renglones del árbol, nada más); en la Web el
  lector ya la recibía como descripción. D1 era un hallazgo, corregido con `cancelPointer`; cambia
  el arrastre de una celda a medias.
- Suite 2563/2563 y `analyze` cero, aquí y en copia limpia; 8 de 32 rojas; monitores y pellizco
  de verdad, pendientes.

### C2.12 Mensaje para Yov

> Yov, la corrección 1 de la entrega 2 de T-120 está al final de `docs/T120-RESULTADOS.md` (C2.1 a
> C2.12), sobre `1a7b03b`, sin commit. A: la clave de la tarjeta lleva la celda; la prueba falla
> antes con tres celdas y **también con dos** (el caso de un plan de verdad), y va en su archivo
> porque el árbol roto arrastraba a las vecinas. B (aprobada por Carlos): en Windows la ayuda va
> detrás del nombre; el árbol cambia en los 10 renglones de los cinco segmentos y nada más; en la
> Web se queda como pista, porque el árbol de Chrome sí la trae como descripción. D1 era un
> hallazgo: tras dos contactos sin levantar y perder el foco, un dedo no movía la rejilla (0.0 dp;
> con los contactos cancelados, 60); Carlos pidió corregirlo, y tu pista se sostuvo
> (`cancelPointer`). Cambia una cosa: un arrastre de celda a medias se cancela al perder el foco.
> D3: la descripción emergente sale en el icono y en el rótulo, no en el borde. D4: la columna
> vacía dura dos cuadros de 60, no uno. Suite 2563/2563; `analyze` cero aquí y en copia limpia;
> 8 de 32 rojas. Monitores y pellizco de verdad, pendientes.

**ALTO: Yov revisa y GLM acepta.**

## Corrección 2 de la entrega 2 (22-nov; 10.172)

### E2c2.1 Resultado en tres líneas

- **O-120-7:** un arrastre de celda cancelado, lo cancele el sistema o el plano al perder el foco,
  ya no propone nada: ni la hoja ni el aviso, con el dedo y con el mouse, sobre una celda válida,
  una roja y la de origen (12 casos, rojos antes). Soltar de verdad no cambia.
- **Las claves, por contenedor:** en el Plano (T120-E2-03), la celda que resalta el buscador lleva
  la clave de su celda y su contenedor, y elegir una matrícula repetida ya no rompe el armado; en
  la Lista (B2), la clave de la tarjeta suma el identificador del contenedor, porque con la
  matrícula dos veces en la misma celda **sí fallaba** como T120-E2-01.
- **C (T120-E2-02) queda como observación, con su causa leída, y sale una nueva, O-120-8:** al
  100 %, en la oficina, el pellizco de dos dedos de la pantalla táctil no amplía si empieza en una
  celda vacía. Carlos eligió no tocar el código de C. Suite **2586 de 2586** (2563 + 23), sin
  omitidas, y `analyze` en cero, aquí y en una copia limpia; 19 de 48 rojas contra `f828860`.
  **Los monitores y el pellizco de verdad siguen pendientes** (D).

### E2c2.2 Paso 0

- La punta de `sprint-4`: `f828860` (10.172), debajo `6aaefa9` (la aceptación de GLM) y `ed1255e`.
  Es la esperada.
- La suite no se repitió al empezar: el piso es 2563.
- **El disco:** 43 GB libres al empezar y antes de cada compilación (las de las 19:38, 19:43 y
  19:46); 42 GB al terminar. No se extrajo otra vez el SDK de Firebase: se usó el banco de
  `%TEMP%\t120-e2\banco`, con `lib/` y `tool/` puestos al día y cotejados con `diff` (sin los `\r`
  de la laptop: el `lib/` del banco era el de la punta).
- **Semáforo:** Carlos dio la luz verde de tres ventanas: la de desarrollo (17:50 a 19:36), la de
  los bancos (19:38 a 19:50) y la de la suite y las rojas (19:51 a 19:58).

### E2c2.3 Cada punto

#### A · O-120-7: un arrastre de celda cancelado no propone nada

- **La prueba, antes de cambiar nada** (`test/t120_e2c2_arrastre_cancelado_test.dart`, 12 casos):
  sobre el arnés de T-105 (operación publicada y abierta, operador autorizado, la celda pendiente
  0030282), con el dedo y con el mouse, el arrastre a medias con el puntero sobre una celda válida
  (la reserva 0030382: intercambio), sobre una que no lo admite (0030182: «no cabe») y sobre la de
  origen; y en cada una, la cancelación del sistema (un `PointerCancelEvent`) y la pérdida de foco
  (`inactive`). En cada caso comprueba que el arrastre empezó y su vista previa; que al cancelarse
  desaparece la copia y no sale ni la hoja ni el aviso; que el `up` tardío no hace nada; que no se
  registra nada; y que un arrastre nuevo de la misma celda termina en su hoja. El modelo es la sonda
  de GLM.
- **Contra la punta fallan los 12** (`build/t120/e2c2/rojas/roja-arrastre.txt` y
  `punta-t120_e2c2_arrastre_cancelado.txt`), cada uno en su comprobación: sobre la válida sale **la
  hoja**, y sobre la roja y sobre la de origen sale **el aviso**, con las dos formas de cancelar y
  con los dos dispositivos. Es lo que midió GLM.
- **Cómo se sabe que se canceló, y por qué así.** `DraggableDetails` no dice si el arrastre se soltó
  o se canceló, y `wasAccepted` tampoco sirve: también es falso al soltar en el hueco entre celdas
  cuando el plano se movió bajo un dedo quieto, y ahí la regla de T-122 hace contar la celda que
  quedó bajo el puntero. Elegí la salida que proponía el prompt: la celda que se arrastra
  (`_PlanDragSource`) va dentro de un `Listener` que anota, en `_cancelado`, si el último contacto
  que terminó sobre ella se soltó (`onPointerUp`) o se canceló (`onPointerCancel`). Ese `Listener`
  está en el camino del contacto, por encima de la celda, así que recibe el `up` o el `cancel`
  **en el mismo evento** y antes que el reconocedor del arrastre. El reconocedor lo recibe al final,
  por la ruta de punteros, y entonces llama a `onDragEnd`. Si `_cancelado`, `_soltar` se detiene
  (detiene el desplazamiento automático) y no llama a `onDrop`. Vale igual para la cancelación del
  sistema y para la del plano al perder el foco: las dos llegan como `PointerCancelEvent` por el
  camino del contacto.
- **Después del cambio pasan los 12**: al cancelarse, ni hoja ni aviso, la copia desaparece, no se
  registra nada, y el arrastre nuevo termina en su hoja. **Soltar de verdad no cambia:** siguen en
  verde las pruebas de T-105 (`t105_*`), T-106, T-122 (la celda bajo el puntero aunque el plano se
  mueva) y T-123 (`build/t120/e2c2/vecinas.txt`, 167 de 167 con las del pellizco y las de T-119).
- **Lo que no entra, y se queda así:** soltar una celda sobre sí misma da el aviso rojo.
- **No se mira en el banco:** el banco no tiene una operación publicada; A se comprueba en pruebas
  de widgets.

#### B1 · T120-E2-03: la clave de la celda que resalta el buscador

- **La prueba, antes de cambiar nada** (`test/t120_e2c2_plano_repetida_test.dart`, 2 casos): el
  caso de GLM, el 3.º y el 7.º de `t120Baplie(13)` con la misma matrícula, en 0020382 y 0020782. El
  buscador da dos resultados (Fila 03 y Fila 07); por cada uno, se elige y se mira que el Plano se
  arme sin errores, en la bahía 2, y qué queda resaltado.
- **Contra la punta fallan los 2:** «Duplicate keys found.» y detrás las aserciones del framework
  (línea 6420 y `'_dependents.isEmpty'`). Corridas juntas, la del segundo resultado trae antes
  errores de `TooltipState` que deja la primera en el mismo aislado (como en la corrección 1); **sola
  da también «Duplicate keys found»** (`rojas/punta-t120_e2c2_plano_repetida-fila07-sola.txt`).
- **La causa** es la que leyó Yov: la celda resaltada va dentro de un `_RevealPosition` con la clave
  de la matrícula, y las celdas de un nivel son hijas de una misma fila.
- **El cambio** (`bay_plan_view.dart`, en `_celdasDeNivel`): la clave es
  `'revelar-<celda>-<matrícula>'`, de la celda y del contenedor. Se conserva lo que hacía: al
  cambiar lo resaltado (otra matrícula), la clave cambia, el `_RevealPosition` es nuevo y la vista
  va a la celda.
- **Después pasan los 2.** **Qué queda resaltado con cada resultado: las dos celdas**
  (`cell-3-82` y `cell-7-82`), con el de la Fila 03 y con el de la Fila 07, porque el buscador
  resalta por matrícula. Que cada resultado resalte solo su celda no entra (O-120-6, bloque 4).
- **Las demás claves por matrícula entre hermanas del Plano**, leídas en `_celdasDeNivel`:
  - `pending-discharge-<matrícula>` y `loading-<clave>` (con su `_RevealPosition` de la clave de
    carga, `C:<matrícula>`) solo salen en el modo Carga, y ahí cada celda va dentro de
    `PlanDragCell`, que lleva la clave de su celda (`plan-cell-<celda>`): no son hermanas entre sí,
    **no se pueden repetir**. Además, de una matrícula repetida la operación se queda con una celda
    y las demás salen como `repeated-<celda>` (T-147, 2b).
  - `reserved-R:<celda>`, `reserved-shadow-…-<celda>-…`, `cell-<fila>-<nivel>`, `repeated-<celda>`
    y `neighbor-twenty-<celda>` son de la celda.
  - La única que se podía repetir era la del `_RevealPosition` de los modos sin operación de carga
    (Contenido, Orden, Descarga): es la que cambió. No hay otra que corregir.
- **En pantalla** (`T120_PLANO_REPETIDA.edi`, escrito por `tool/t120e2_buques.dart` en
  `%TEMP%\t120-e2\caso-c2`: 13 contenedores, 12 matrículas, TSTU0000003 en 0020382 y 0020782). El
  escenario nuevo `buscador` del conductor abre el buscador con su botón, escribe la matrícula, toca
  cada resultado y captura el Plano, a 1366 × 690 y a 360 × 800, de día. Lo corrí **antes**
  (el banco con el `lib/` de la punta) y **después**, en Windows (release) y en la Web (release), y
  abrí cinco capturas:
  - **Antes, Windows, 1366, el primer resultado** (`windows/buscador-antes/capturas/
    1366x690_buscador_1_plano.png`): el Plano, «Bahía 02», Contenido, 100 %. En el nivel 82, de
    babor a estribor, las nueve celdas en su orden (08 USHOU 19.0, 06 GTSTC 24.0, 04 GTSTC 22.0, 02
    GTSTC 20.0, 00 vacía, 01 GTSTC 19.0, **03 GTSTC 21.0**, 05 GTSTC 23.0, **07 GTSTC 18.0**), con
    las dos de TSTU0000003 marcadas con el borde de resaltado. No falta ni sobra ninguna.
  - **Antes, Windows, 1366, el segundo resultado:** igual.
  - **Antes, la Web, 360, el segundo resultado:** el Plano del teléfono, la rejilla corrida a
    estribor (00 a 07), con las dos celdas marcadas a la vista.
  - **Después, la Web, 1366, el segundo resultado, y Windows, 360, el primero:** lo mismo que
    antes.
  - **Qué se ve antes y después en release:** lo mismo. Sin la aserción, la clave repetida no
    rompe nada a la vista en estas corridas, y el conductor no anotó ningún error de Flutter en las
    16 capturas (8 antes y 8 después). La diferencia está en depuración: la prueba de widgets daba
    «Duplicate keys found» y ya no.
  - La Web: cada compilación con su perfil nuevo de Chrome (`c2-buscador-antes-3` y
    `c2-buscador-despues`), el *service worker* borrado antes de cargar, y el `main.dart.js` que
    cargó la página es el de la carpeta que se sirve: `65d2e7bd…` antes y `155e65b7…` después
    (`web/*/navegador.json`). La consola, sin errores.
  - **Del instrumento:** la primera corrida de la Web dio «Hay 0 resultados»: en la Web en release,
    `runtimeType.toString()` sale minificado y el conductor no encontraba `_ContainerSearchResultTile`
    por su nombre. Ahora busca el `ListTile` con «Posición:». Volví a compilar el «antes» de las
    dos plataformas con ese conductor y repetí las dos corridas; las que valen son esas. Los
    perfiles de las corridas descartadas (`c2-buscador-antes` y `-2`) ya no están.

#### B2 · La tarjeta de la Lista, con la misma matrícula dos veces en la misma celda

- **La prueba** (`test/t120_e2c2_misma_celda_test.dart`): los 13 del buque sintético, con el 4.º en
  la celda del 3.º (0020382) y con su matrícula; el lector guarda los 13. El filtro de LNB (las dos
  son de LNB), puesto y quitado. **Las tarjetas se cuentan por elemento:** cada una por la altura a
  la que está en la lista, así que dos iguales cuentan como dos.
- **Contra la punta falla como T120-E2-01:** antes del filtro, la Lista enseña **13 tarjetas**, dos
  de TSTU0000003 en Bahía 002, Fila 03, Nivel 82, las dos con la clave
  `tarjeta-TSTU0000003-0020382`; con el filtro, 4; al quitarlo, `'child == null || indexOf(child) >
  index'`, «RenderSliverPadding expected a child of type RenderSliver but received … RenderErrorBox»
  y `'_dependents.isEmpty'` (`rojas/roja-misma-celda.txt`). El título no lo leí bien en esa corrida:
  el instrumento tomaba otro texto («Contenedores» a secas); lo corregí antes de la corrida verde.
- **El cambio** (`containers_list_view.dart`): `ContainersSliverList.claveDe` es ahora
  `tarjeta-<matrícula>-<celda>-<id>` (sin celda, `tarjeta-<matrícula>-<id>`), con `id` el
  identificador del contenedor. **Por qué es único en `aboardContainersProvider`:** el lector da a
  cada contenedor un identificador propio (`Uuid().v4()`, también a los que repiten matrícula y
  celda), y los vacíos asignados llevan `assigned-<matrícula>`, cada uno en la celda de su reserva.
  Dejé delante la matrícula y la celda para poder leer la clave.
- **Después pasa:** la Lista enseña **13 tarjetas** y dice **«Contenedores (13)»**; con el filtro,
  **«Contenedores (4), naviera LNB»**, con las dos de TSTU0000003 seguidas; al quitarlo, 13 en el
  mismo orden, sin errores, y 13 claves distintas, las dos de la repetida con su identificador.
- **Puestos al día:** `t120_e2_lista_test.dart` (la repetida fija las claves por su comienzo,
  `tarjeta-TSTU0000003-0020382-`), `t120_e2c1_claves_test.dart` (fija la clave con el
  identificador), el comentario del conductor (busca por el comienzo, `tarjeta-TSTU0000003-`, y sigue
  valiendo) y `DESIGN.md` 18.4.

#### C · T120-E2-02: queda como observación; y O-120-8

- **La prueba, primero, y el instrumento comprobado** (`test/t120_pellizco_test.dart`): uno y dos
  contactos sin levantar; el ciclo corto (`inactive` y de vuelta) y el entero (hasta `paused` y de
  vuelta); 500 ms entre el ciclo y el gesto; un pellizco del touchpad en cuatro pasos (1.05, 1.10,
  1.15 y 1.20), y un segundo gesto después (0.95 y 0.90).
  - **Con un contacto amplía** con los dos ciclos: 1.050, 1.100, 1.150, 1.200, y el segundo gesto
    lleva a 1.080. Es lo que arregló la corrección 1.
  - **Con dos no amplía**, con los dos ciclos: 1.000 en los cuatro pasos y en el segundo gesto, sin
    encender el pellizco. **Es del producto, no de la sonda:** pasa con varios pasos, con tiempo
    entre el ciclo y el gesto, y en el segundo gesto. Y pasa también con el ciclo corto (GLM lo decía
    sin haberlo medido; ahora está medido).
- **La causa, leída en el código y comprobada con dos sondas temporales** (`build/t120/e2c2/
  sondas/`, sus fuentes como `.dart.txt` y sus salidas):
  1. Con un rastreo temporal en `PlanZoomViewport`, el `Listener` del plano recibe el `down` del
     primer contacto (11), pero **ni el del segundo (12) ni el gesto del touchpad**.
  2. Por qué: al 100 % la bahía cabe y la rejilla no se desplaza (`rejilla-horizontal`, tope 0), así
     que en la arena del primer contacto el único reconocedor de arrastre es el de **la columna**
     (`columna-del-plano`). Gana sin rival en cuanto el dedo se apoya y la columna empieza a
     arrastrar (`DragScrollActivity`). Mientras arrastra, el `Scrollable` de la columna pone su
     `IgnorePointer` sobre todo lo de dentro. La prueba de acierto en cualquier punto del plano se
     corta ahí: de 88 entradas pasa a 55, sin el `Listener` del plano.
  3. El segundo contacto no llega al plano: lo toma la columna. Al perder el foco, `_soltarTodo`
     cancela solo el que conoce (11). El 12 sigue puesto en la columna, que se queda arrastrando y
     tapando el plano. El touchpad ya no llega al `Listener`, y tampoco llegarían los toques, hasta
     que ese contacto termine.
  4. Por eso GLM vio que, cancelando los dos directo con `cancelPointer`, sí amplía: así también se
     cancela el que tenía la columna. Con un solo contacto, el plano lo conoce y lo cancela.
  - **Lo que no sé:** si en Windows, tras un Alt + Tab con dos dedos puestos, el sistema llega a
    mandar el final del segundo contacto. Si lo manda, la columna se suelta sola. Pide la pantalla
    táctil de verdad.
- **O-120-8 (nueva), de la misma causa:** al 100 %, en la oficina, **el pellizco de dos dedos de la
  pantalla táctil no amplía** si el primer dedo cae donde solo se desplaza la columna (una celda
  vacía): el plano solo ve un dedo. Dos dedos a 40 dp que se separan a 160 dp dejan la escala en
  **1.000** (se esperaba llegar al tope).
  - Con la escala en 2, la rejilla también se desplaza, el arrastre de la columna no gana solo y
    el plano ve los dos dedos: amplía (2 → 3.000, el tope).
  - **En el teléfono no pasa:** a 360 × 800 y a 412 × 915, al 100 %, los mismos dos dedos amplían
    hasta el tope (3.000). Ahí el `Listener` del plano envuelve los desplazables de la rejilla, y no
    hay una columna por fuera que lo tape. Lo que no probé: una bahía que quepa entera en el
    teléfono, donde el único arrastre de la arena sería el de las pestañas.
  - Reproducción: la oficina a 1366 × 690, Plano al 100 %, la bahía 2 del buque de T-117; dos dedos
    sobre `cell-0-90` (una celda vacía) que se separan.
- **Carlos decidió no tocar el código de C.** Las pruebas que quedan en la suite y fijan el defecto
  lo dicen en su nombre: «T120-E2-02 (DEFECTO CONOCIDO, sin corregir)…» con dos contactos (2) y
  «O-120-8 (DEFECTO CONOCIDO, sin corregir)…» en la oficina al 100 % (1). Las demás fijan lo que se
  quiere: con un contacto (2), la oficina con la escala en 2 (1) y el teléfono (2). Cuando se
  arregle, las dos de defecto cambian.
- **El arreglo de fondo, para una entrega aparte (no programado):**
  - **Archivos:** `plan_drag_confirmation.dart` (`PlanZoomViewport`) y `bay_plan_view.dart` (la
    columna `columna-del-plano`); quizá `plano_providers.dart`.
  - **Cómo lo haría:** que el plano vea **todos** sus contactos aunque la columna los tape. Hay dos
    caminos. El primero, que `PlanZoomViewport` los siga con una ruta global de punteros
    (`GestureBinding.instance.pointerRouter.addGlobalRoute`): toma los `down` que caen dentro de su
    caja, y sus `move`, `up` y `cancel`, en vez de solo los que le entrega su `Listener`. El
    segundo, en la oficina, subir el `Listener` de los contactos por encima de la columna. Con dos
    contactos sobre el plano, la columna se congela como con el pellizco del touchpad
    (`NeverScrollableScrollPhysics`), y su arrastre ya empezado se suelta. Al perder el foco, el
    plano cancela todos sus contactos, también los que tenía la columna.
  - **Qué cambia en el gesto táctil:** al 100 % en la oficina, el primer dedo sigue desplazando la
    columna en cuanto se apoya. Si llega un segundo dedo, la columna se detiene (con lo poco que
    alcanzó a moverse) y empieza el pellizco, desde cualquier celda. Un dedo solo no cambia, y el
    teléfono no cambia.
  - **Cómo se mide con una pantalla táctil de verdad:** el escenario `mano`, extendido a los
    contactos táctiles, en Windows y en Chrome. Por cada gesto: dos dedos que empiezan en una celda
    vacía y en una llena, al 100 % y al 200 %, con la escala y lo que se movió la columna. Un dedo
    solo tiene que seguir desplazando la columna desde el primer cuadro. Y Alt + Tab con dos dedos
    puestos, con un pellizco del touchpad después. Y en el teléfono, que el pellizco no cambió.

#### D · Los dos monitores y el pellizco de verdad

**Pendientes.** Carlos no pudo en esta sesión. No los hice ni los doy por vistos; `DESIGN.md` 14.9
sigue esperando. Siguen como dice E2.10, puntos 3 y 5.

### E2c2.4 Las pruebas nuevas y las rojas

| Archivo | Qué | Contra `f828860` |
|---|---|---|
| `test/t120_e2c2_arrastre_cancelado_test.dart` (nuevo) | O-120-7 (12) | **fallan 12 de 12** |
| `test/t120_e2c2_plano_repetida_test.dart` (nuevo) | T120-E2-03 (2) | **fallan 2 de 2** |
| `test/t120_e2c2_misma_celda_test.dart` (nuevo) | B2 (1) | **falla 1 de 1** |
| `test/t120_pellizco_test.dart` | T120-E2-02, 2 de lo que se quiere y 2 de defecto conocido; O-120-8, 3 de lo que se quiere y 1 de defecto conocido (8 nuevas) | pasan 16 de 16: C no cambia código |
| `test/t120_e2c1_claves_test.dart` | la clave con el identificador (cambian 2) | **fallan 2 de 2** |
| `test/t120_e2_lista_test.dart` | la repetida, la clave por su comienzo (cambian 2) | **fallan 2 de 15** |

- **19 de 48 rojas**, cada una en su comprobación y ninguna de compilación, en una copia de
  `f828860` con solo estas seis pruebas (`%TEMP%\t120-e2\rojas-c2`; `build/t120/e2c2/rojas/punta-*`).
  Las cuatro de las claves de la Lista fallan por el texto de la clave (ahora lleva el
  identificador); las de A, B1 y B2, por el defecto.
- La suite sube en 23: 2563 → **2586**.

### E2c2.5 Validaciones

| Qué | Resultado | Registro (`build/t120/e2c2/`) |
|---|---|---|
| Las pruebas vecinas, después de A, B y C: el pellizco, T-119, T-105, T-106, T-122, T-123, T-76, T-78 y las alertas de estiba | **167 de 167** | `vecinas.txt` |
| La suite en la carpeta, después del último cambio (19:51 a 19:53) | **2586 de 2586**, sin omitidas | `suite-carpeta.txt` |
| `flutter analyze --no-pub` en la carpeta | **«No issues found!»** | `analyze-carpeta.txt` |
| La copia limpia: `git archive f828860` + las 14 rutas, iguales por su huella, + la entrada de T-124; `pub get --offline --enforce-lockfile`, el lock igual en contenido | `analyze` **«No issues found!»**; suite **2586 de 2586** | `analyze-limpia.txt`, `suite-limpia.txt`, `copias-manifiesto.json` |
| La Web: el programa que cargó la página | `65d2e7bd…` (antes) y `155e65b7…` (después), los de la carpeta que se sirve; cada uno con su perfil nuevo | `web/*/navegador.json` |
| `// ignore:` | Ninguno en el repositorio (la sonda temporal que lo usaba está fuera, como `.dart.txt`) | |
| `pubspec.*`, `lib/main.dart`, los congelados, los archivos de T-147, `DESIGN.md` 17.7 y 14.9 | **No cambian** | `git diff --stat` |

### E2c2.6 Lo que no se pudo y lo que queda anotado

- **D, los monitores y el pellizco de verdad:** pendientes.
- **T120-E2-02 y O-120-8:** observaciones, sin corregir (decisión de Carlos), con su causa, su
  reproducción y las pruebas que fijan el defecto. Sin medir: si Windows manda el final del
  segundo contacto tras un Alt + Tab, y una bahía que quepa entera en el teléfono.
- **A y C solo en pruebas de widgets:** el banco no tiene una operación publicada, y C pide un
  equipo con pantalla táctil y touchpad.
- **B1 en release se ve igual antes y después;** la diferencia es de depuración.
- **Las sondas temporales** (`t120c2_sonda_c_test.dart`, `t120c2_sonda_c2_test.dart` y
  `t120c2_sonda_telefono_test.dart`) se sacaron de `test/`; sus fuentes y salidas quedan en
  `build/t120/e2c2/sondas/`. El rastreo temporal de `plan_drag_confirmation.dart` se quitó: el
  archivo volvió a su huella de antes (`9b0b0dfc…`) antes del arreglo de A.

### E2c2.7 Archivos

**Cambian (11):** `DESIGN.md` (16.2 y 18.4),
`lib/features/vessel/presentation/widgets/bay_plan_view.dart`,
`lib/features/vessel/presentation/widgets/containers_list_view.dart`,
`lib/features/vessel/presentation/widgets/plan_drag_confirmation.dart`,
`test/t120_e2_lista_test.dart`, `test/t120_e2c1_claves_test.dart`, `test/t120_pellizco_test.dart`,
`tool/t120e2_buques.dart`, `tool/t120e2_conductor.dart`, `tool/t120e2_servidor.py` y
`tool/t120e2_windows.py`.

**Nuevos (3):** `test/t120_e2c2_arrastre_cancelado_test.dart`,
`test/t120_e2c2_misma_celda_test.dart` y `test/t120_e2c2_plano_repetida_test.dart`. Y este informe.
**`pubspec.*` no cambia.**

**Fuera de Git:** `build/t120/e2c2/` (3.5 MB). En `%TEMP%\t120-e2\`, **unos 14 GB en total** (los
enlaces del SDK de Firebase cuentan una vez):
- `banco\` (11 GB, el banco de Windows con su SDK, ya con el `lib/` de esta corrección): se queda
  para los monitores;
- `limpia\` (11 GB contando el SDK enlazado; la copia de `261ee4b`);
- `limpia-c1\`, `limpia-final\`, `limpia-c2\` y `rojas-c2\`, de 209 a 215 MB cada una;
- `perfiles\` (374 MB; los cuatro de esta corrección ya están borrados);
- `web-antes-o1204\`, `web-c1\`, `web-final\`, `web-c2-antes\` y `web-c2\`, de 37 MB cada una;
- `caso\`, `caso-c1\` y `caso-c2\` (las entradas sintéticas) y `almacenes\` (6 MB).

Cuando se acepte, todo menos `banco\` y `caso\` se puede borrar, mejor desde el Explorador
(traen enlaces).

### E2c2.8 Horas

Del reloj, el 22-nov:
- **Inicio:** poco después de las 17:40. No lo anoté; la primera roja es de las 17:50.
- **Las rojas,** de las 17:50 a las 17:51.
- **La causa de C,** de las 17:51 a las 17:54. Ahí pregunté, y la respuesta de Carlos llegó antes
  de las 19:33.
- **La sonda del teléfono, y A, B1 y B2,** de las 19:32 a las 19:34. Las vecinas, a las 19:34.
  `analyze`, a las 19:36.
- **Los bancos,** de las 19:38 a las 19:50.
- **La suite, la copia limpia y las rojas,** de las 19:51 a las 19:58.
- **El informe,** a las 20:03.

### E2c2.9 Para quien acepte

1. La suite y `analyze` en una copia limpia de la punta con este bloque: 2586, sin omitidas, con la
   entrada de T-124.
2. Las rojas: las seis pruebas en una copia de `f828860` (19 de 48), cada una en su motivo.
3. A: la sonda de O-120-7 de GLM contra esta corrección (los 16 escenarios, también «fuera de las
   celdas»), y que soltar de verdad sigue igual, con el T-122 de la celda bajo un dedo quieto.
4. B1 en pantalla: `T120_PLANO_REPETIDA.edi` (`dart tool/t120e2_buques.dart <carpeta nueva en
   %TEMP%>`) y el escenario `buscador`, en Windows y en la Web; mejor también en depuración, que es
   donde se veía el fallo.
5. B2: la sonda de claves de GLM contando por elemento, y la Lista con un archivo que repita
   matrícula y celda.
6. C: leer la causa de E2c2.3 en el código de Flutter (`scroll_activity.dart`,
   `DragScrollActivity.shouldIgnorePointer`; `scrollable.dart`, `IgnorePointer`) y las salidas de las
   sondas. Que las pruebas de defecto conocido lo digan en su nombre.
7. D: los monitores y el pellizco de verdad, con Carlos.

### E2c2.10 Git

Para que lo ejecute Carlos. Fuera quedan los archivos que solo cambian el fin de línea
(`test/t114_fase3_correccion_test.dart` y tres de `windows/flutter/`) y las carpetas sin
seguimiento de `docs/`.

```powershell
git add -- DESIGN.md
git add -- lib/features/vessel/presentation/widgets/bay_plan_view.dart
git add -- lib/features/vessel/presentation/widgets/containers_list_view.dart
git add -- lib/features/vessel/presentation/widgets/plan_drag_confirmation.dart
git add -- test/t120_e2_lista_test.dart
git add -- test/t120_e2c1_claves_test.dart
git add -- test/t120_e2c2_arrastre_cancelado_test.dart
git add -- test/t120_e2c2_misma_celda_test.dart
git add -- test/t120_e2c2_plano_repetida_test.dart
git add -- test/t120_pellizco_test.dart
git add -- tool/t120e2_buques.dart
git add -- tool/t120e2_conductor.dart
git add -- tool/t120e2_servidor.py
git add -- tool/t120e2_windows.py
git add -- docs/T120-RESULTADOS.md
git commit -m "Sprint 4: T-120, correccion 2 de la entrega 2: un arrastre de celda cancelado no propone nada, las claves del plano y de la tarjeta por contenedor, y T120-E2-02 y O-120-8 como observaciones con su causa"
git push origin sprint-4
```

### E2c2.11 En tres líneas

- O-120-7 corregido: un arrastre de celda cancelado ya no propone nada (12 casos, rojos antes);
  soltar de verdad no cambia.
- Las claves por contenedor: el Plano ya no se rompe con una matrícula repetida en el buscador, y
  la tarjeta suma el identificador porque la misma matrícula en la misma celda sí fallaba.
- T120-E2-02 queda como observación, con su causa (la columna tapa el plano mientras arrastra), y
  sale O-120-8 (el pellizco táctil al 100 % en la oficina); suite 2586/2586, `analyze` cero; D
  pendiente.

### E2c2.12 Mensaje para Yov

> Yov, la corrección 2 de la entrega 2 de T-120 está al final de `docs/T120-RESULTADOS.md` (E2c2.1
> a E2c2.12), sobre `f828860`, sin commit. **A:** un arrastre de celda cancelado ya no propone nada.
> La celda que se arrastra va dentro de un `Listener` que ve el `cancel` antes que el reconocedor;
> `wasAccepted` no servía por la regla de T-122. Son 12 casos, rojos antes. **B1:** la clave del
> `_RevealPosition` es de la celda y el contenedor; las demás claves del Plano no se pueden
> repetir. En release se ve igual antes y después; la diferencia era de depuración. **B2 sí
> fallaba** con la matrícula dos veces en la misma celda: la clave suma el identificador del
> contenedor. **C:** la causa no era el ciclo de vida. Al 100 %, el primer dedo hace ganar al
> arrastre de la columna, que tapa el plano con su `IgnorePointer`, y el segundo dedo nunca llega
> al plano. Carlos lo dejó como observación, y sale **O-120-8**: el pellizco táctil al 100 % en la
> oficina no amplía si empieza en una celda vacía (en el teléfono, sí). Las pruebas que fijan el
> defecto lo dicen en su nombre. Suite 2586/2586 y `analyze` cero, aquí y en copia limpia; 19 de
> 48 rojas. D, pendiente.

**ALTO: Yov revisa y GLM acepta.**
