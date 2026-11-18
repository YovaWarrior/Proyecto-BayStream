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
