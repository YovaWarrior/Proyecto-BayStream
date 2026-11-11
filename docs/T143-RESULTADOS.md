# T-143 · Los estados y los textos de la operación

Timonel · 10 y 11-nov-2026 · Base: `sprint-4` en `d45a839` (10.117) · Decisiones 10.105, 10.110
y 10.117. **La propuesta (sección 1) se aprobó el 11-nov con los ajustes de la sección 2; la
Fase 2 está entregada (secciones 3 a 12) para la aceptación de Codex.**

## 0. Paso 0

| Qué | Resultado |
|---|---|
| Punta de `sprint-4` (`git log --oneline`) | `d45a839` «decision 10.117», sobre `020bd57` «decision 10.116». Trae las dos |
| Árbol de trabajo (`git diff --stat`) | `test/t114_fase3_correccion_test.dart` y los tres `windows/flutter/generated_*` aparecen modificados, pero `git diff --stat` no da ninguna línea: solo cambia el fin de línea (LF frente a CRLF; fechas 21 y 23-oct). No son de T-143 y no los toco ni los incluyo en Git. Los demás sin seguimiento son de `docs/entrega-7nov/` y `docs/t117/` |
| `lib/`, `test/`, `pubspec.*` libres | Carlos dio la luz verde al paso 0 (11-nov, 00:00) |
| `flutter pub get` | «Got dependencies!» (SEMÁFORO 00:00:51 a 00:01:11). `pubspec.yaml` y `pubspec.lock` siguen sin cambios (`git diff --stat` vacío) |
| `flutter analyze` | **No da cero: «6 issues found»** (106.3 s; SEMÁFORO 00:01:15 a 00:03:07). Los seis son de nivel *info* y están en `tool/`, ninguno en `lib/` ni en `test/`: `unintended_html_in_doc_comment` en `tool/t140_volcado_test.dart:24` (T-140, `2a669dd`) y cinco `avoid_print` en `tool/t141_fuzz_baplie.dart:56, 66, 67, 71 y 73` (T-141, `820f66e`). Esas dos tareas no corrieron `analyze` porque no tocaban `lib/` ni `test/`. Me detuve; Carlos decidió corregirlos en un commit aparte (sección 2, decisión 1; sección 3.1) |
| Piso de la suite | **2107 de 2107**, sin omitidas, medido el 11-nov antes de tocar `lib/` (sección 3.2) |

## 1. Propuesta

### 1.1 Los estados: lo que se ve hoy y lo que propongo (O-139-7 y O-139-1)

**Dónde está cada texto hoy:**
- **La cabecera** es la píldora de `_CabeceraDeOficina` (`vessel_overview_page.dart:1476`):
  `publicado ? 'Publicado' : 'Sin confirmar'`, con `publicado = ui is Publicado`. Mira solo si el
  perfil se confirmó en este equipo; no mira la operación. **Solo existe con riel** (ancho ≥ el del
  riel), sea oficina o muelle: en el teléfono no hay píldora, y el previo lo dice la banda.
- **El chip de la nube** es `syncStatusText` (`sync_status_chip.dart`). Se ve como texto en «Nube y
  cuenta», en el panel «En vivo», en Avance y en Solicitudes; en la barra del plano es el ícono de
  la nube, con el texto en su descripción emergente.
- **«Nube y cuenta»** dice el estado de la operación local (`cloud_page.dart:223`):
  «Solo en este dispositivo», «Publicada» o «Publicada y cerrada», según `operation.published` y
  `operation.closed`.

**Lo que propongo: una sola regla, en una función pura** (`estadoDeLaOperacion`, en
`presentation/formatters/operation_text.dart`, junto a los otros textos de la operación), que
leen la píldora y «Nube y cuenta» en los tres clientes:

| Estado | Cuándo | Píldora de la cabecera | «Nube y cuenta» |
|---|---|---|---|
| Sin confirmar | `Previo` | «Sin confirmar» (igual) | igual que hoy |
| Confirmado en este equipo | `Publicado` y la operación no está publicada, o no hay operación (sin escala, o compilación sin nube) | **«Confirmado»** (hoy «Publicado») | «Solo en este dispositivo» (igual) |
| Publicada | operación publicada y abierta | **«Publicada»** | «Publicada» (igual) |
| Cerrada | operación publicada y cerrada (`operation.closed` **o** `SyncStatus.closed`) | **«Cerrada»** | «Publicada y cerrada» (igual; en el muelle, ahora también) |

- **La píldora usa la palabra de la nube solo cuando la operación está en la nube.** Antes de
  publicar habla del plano («Confirmado»); desde la publicación, de la operación, con la misma
  palabra que «Nube y cuenta». Así «Publicado» y «Publicada» dejan de convivir con dos
  significados.
- **La descripción emergente y la etiqueta accesible** de la píldora dicen la frase entera:
  «Confirmado en este equipo: la operación todavía no está en la nube», «Publicada en la nube»,
  «Operación cerrada por la oficina: ya no se registran movimientos».
- **Alternativa para Yov** si «Confirmado» le parece poco: «Solo en este equipo», el mismo sentido
  que el chip. La desaconsejo en la píldora porque es tres veces más ancha y la cabecera ya pliega
  por ancho (14.8); queda en la descripción emergente.
- El selector de modo, las tarjetas y el plano no cambian con el estado; el chip sigue diciendo la
  conexión. **Red y estado son dos cosas:** la píldora no cambia por quedarse sin red.

**La tabla completa, por momento, con red y sin red:**

| Momento | Cliente | Píldora | Chip | «Nube y cuenta» (estado · envío) |
|---|---|---|---|---|
| Previo | oficina y muelle | Sin confirmar | Solo este dispositivo | «Abre un plano con su escala confirmada…» (sin operación) |
| Confirmado aquí, con o sin red | oficina | **Confirmado** (hoy Publicado) | Solo este dispositivo | Solo en este dispositivo · Solo este dispositivo |
| Publicada, con red | oficina y muelle | **Publicada** (hoy Publicado) | Al día / Enviando N | Publicada · Al día |
| Publicada, sin red | oficina y muelle | Publicada | Sin conexión · N por enviar | Publicada · Sin conexión · N por enviar |
| Cerrada, vista por la oficina que cerró | oficina | **Cerrada** (hoy Publicado) | Al día · operación cerrada | Publicada y cerrada · Al día · operación cerrada |
| Cerrada, vista por el muelle con red | muelle | **Cerrada** (hoy Publicado) | **Al día · operación cerrada** (hoy Al día) | **Publicada y cerrada** · Al día · operación cerrada (hoy Publicada · Al día) |
| Cerrada mientras el muelle no tenía red | muelle | Publicada hasta que vuelva la red; entonces **cambia sola** a Cerrada | Sin conexión · N por enviar → Al día · operación cerrada | igual: cambia solo al volver la red |
| Cerrada, el muelle abre la app sin red y ya la había visto cerrada | muelle | Cerrada | Sin conexión · operación cerrada | Publicada y cerrada (el cierre quedó guardado en el equipo) |

Sin red, el muelle **no puede saber** que la oficina cerró: la tabla lo dice como es, y el cambio
llega solo con el primer contacto con el servidor.

### 1.2 Cómo se entera el muelle del cierre (O-139-1)

**Qué escucha hoy.** El motor (`sync_engine.dart`) tiene dos escuchas sobre la nube:
1. los movimientos (`operations/{op}/movements`);
2. **el documento de la operación**, por `watchSources` (`firestore_operation_sync.dart:647`), desde
   T-127, para bajar el listado y los planes agregados.

El cierre (`status: 'closed'`, `closedAt`) se escribe **en ese mismo documento**, pero
`watchSources` solo lee el campo `sources` y tira lo demás. El motor se entera del cierre por un
solo camino: cuando un movimiento suyo es rechazado (`_failed`, `permission-denied` → lee
`closedAt` del servidor → guarda la operación local cerrada). De ahí O-139-1: el muelle sigue en
«Publicada» y «Al día» hasta que registra algo. «Operaciones abiertas en la nube» sí cambia,
porque es otra consulta (`where status == 'open'`).

**Qué le falta y cómo queda:**
1. **La escucha del documento trae también `closedAt`.** `watchSources` pasa a emitir el manifiesto
   y la hora de cierre (un registro pequeño, `RemoteOperationDocument(sources, closedAt)`, en
   `source_revisions.dart`). Es **la misma escucha**: ni una lectura más, ni un índice, ni un cambio
   de reglas (las publicadas, `T130-firestore.rules.propuesta`, ya dejan leer el documento a quien
   escucha hoy sus fuentes).
2. **El motor, al ver `closedAt` por primera vez:** pone `_closed`, guarda la operación local con
   `closedAt` (lo mismo que ya hace en `_failed`; el cierre no se puede deshacer en la nube, así que
   un `closedAt` visto también desde la caché vale) y emite el estado con `closed: true`. El chip
   suma «operación cerrada», como ya pasa en la oficina.
3. **La escritura pendiente no cuenta:** la escucha ya descarta las instantáneas con
   `hasPendingWrites`, así que la oficina que acaba de cerrar sigue por su camino de T-129, que no
   cambia.
4. **La pantalla se entera:** un `AvisoDelCierre`, hermano de `AvisoDelPlan` y `AvisoDelListado`
   (mismo patrón: escucha `syncStatusProvider`, avisa una vez y pide
   `operationSourcesRevisionProvider.changed()` para que la operación local se vuelva a leer).
   El aviso, solo en quien no cerró: «La oficina cerró la operación de GTSTC. Lo que registres
   desde ahora se rechazará.» «Nube y cuenta» lee `operation.closed || status.closed`, para no
   depender del orden entre el aviso y la relectura.
5. **Sin red:** no cambia nada hasta que el servidor responda; en ese momento la instantánea trae
   `closedAt` y el estado cambia solo, sin registrar nada. Es la fila 7 de la tabla.

**Si el muelle tenía movimientos en la cola cuando la oficina cerró.** Las reglas publicadas aceptan
un movimiento si la operación está abierta **o** si se registró antes del cierre
(`d.createdAt <= op.closedAt`, `T130-firestore.rules.propuesta:376`). Hoy:
- lo registrado **antes** del cierre sube al volver la red y se confirma (lo prueba
  `t79_sync_engine_test.dart:346`);
- lo registrado **después** se rechaza con «La operación se cerró antes de este movimiento.», el
  motor guarda la operación cerrada y el chip dice «… · 1 rechazado por la nube, fuera del plan:
  regístralo de nuevo si hace falta · operación cerrada», con «Reintentar» en «Nube y cuenta».

Ese texto y ese botón invitan a algo que no sirve: con la operación cerrada, registrar de nuevo o
reintentar se rechaza otra vez. **Propongo:**
- **con la operación cerrada**, la cláusula del chip dice «1 rechazado: la operación ya estaba
  cerrada» / «N rechazados: la operación ya estaba cerrada», sin «regístralo de nuevo»;
- **«Reintentar» no aparece** si la operación está cerrada (sí, como hoy, si está abierta);
- la cola se vacía sola como hoy: nada de lo registrado antes del cierre se pierde.

**Lo que no propongo en T-143 (para que Yov decida):** impedir registrar en el muelle después de
saber del cierre. Hoy el toque se registra en el equipo y la nube lo rechaza; con esta propuesta el
planificador ya lo sabe antes (la píldora, el aviso, «Nube y cuenta»). Bloquear el registro toca
los cinco caminos que escriben en la bitácora (descarga, carga, vacío, re‑estiba y deshacer) y sería
otra tarea; si Yov la quiere aquí, la sumo a la Fase 2 con sus pruebas.

### 1.3 «sin operación» en la etiqueta de la silueta (O-139-3)

**De dónde sale.** `BsBahiaDeSilueta.etiqueta` (`bs_silueta_buque.dart:48`) escribe «sin
operación» **siempre que `avance` es nulo**. `SiluetaDelViaje._bahia` deja `avance` nulo en tres
casos que no son «sin operación»:
1. el plano no tiene escala: **ese sí** es sin operación;
2. la silueta no está mostrando avance en este modo: en un **plan de carga**, fuera de Carga y
   Orden, no se calcula la descarga (el plan no la ofrece) ni la carga (`porCarga` es falso). Es el
   caso de T-139: el plan de carga recién agregado, en «Contenido»;
3. la bahía no tiene nada que bajar o subir en esta escala (`total == 0`), también con la
   operación en marcha.

**La corrección.** La pieza deja de inventar el motivo: `BsBahiaDeSilueta` recibe
`String? sinAvance` y la etiqueta lo dice si lo hay, o no dice nada del avance si es nulo. Quien
sabe el motivo, `SiluetaDelViaje`, lo escribe:
- caso 1: «sin operación»;
- caso 2: nada (el rótulo de la silueta tampoco habla de avance en ese modo);
- caso 3: «sin movimientos en GTSTC».

**Lo visible no cambia.** Una alternativa sería mostrar las barras de carga del plan de carga en
«Contenido», como el plano de llegada muestra las de descarga; cambia lo que se ve y T-139 dijo que
lo visible está bien, así que no la propongo aquí. **Antes de corregir, una prueba roja** reproduce
la etiqueta de T-139 con el plan agregado: si el caso que vio T-139 resulta ser otro de los tres,
lo digo en el informe.

### 1.4 El límite de apilamiento (O-139-6) y los textos (O-139-2)

**O-139-6. Lo que encontré y no cuadra con T-139.** El código ya tiene una regla desde la
corrección 10.15 (`vessel_geometry_page.dart:172-181`): «No lo tengo» viene marcado si el perfil es
del mismo buque, lo declaró el usuario y no tiene límite; con un valor, el campo ya viene lleno con
el del perfil. Leyendo el flujo de T-139 (llegada confirmada con «No lo tengo» → publicada → plan
de carga en previo con la operación publicada → «Confirmar»), el perfil que llega a la página es el
guardado, `declaredByUser`, del mismo IMO y sin límite: **debería venir marcado.** Lo que sí está
desactualizado es `DESIGN.md` 7.2, paso 3 («“No lo tengo” sin marcar»), que T-139 citó. No tengo la
captura de esa pantalla (T-139 no la guardó). Por eso:
1. **Primero reproduzco** el flujo exacto en una prueba de widget con la nube falsa y los sintéticos
   de T-100, y en el banco Web si hace falta. Si sale sin marcar, busco la causa (sospechas, en
   orden: la clave del buque con que se compara `mismoBuque`, el origen del perfil después de
   publicar, el camino de «La carga excede el perfil guardado») y la corrijo ahí.
2. **Lo que decidió Yov, «lo trae resuelto y lo muestra»:** bajo el campo, una línea que dice de
   dónde viene: «Del perfil guardado: no lo tienes.» o «Del perfil guardado: 90 000 kg por pila.»
   Cambiarlo es escribir otro valor o desmarcar, como hoy. Con una plantilla de otro buque o con la
   propuesta del archivo sigue sin marcar y sin la línea (10.15, H1 de la corrección, que no
   cambia).
3. **`DESIGN.md` 7.2, paso 3,** pasa a: «Confirmar abre “Parámetros del buque” con la propuesta
   cargada. Si el perfil guardado de este buque ya resolvió el límite de apilamiento (con un valor
   o con “No lo tengo”), viene resuelto, con la línea “Del perfil guardado…”, y se puede cambiar;
   con la propuesta del archivo o con una plantilla de otro buque, “No lo tengo” empieza sin
   marcar.»

**O-139-2.** Tres textos, solo en pantalla:
- `voyage_summary_card.dart:151` y `:180`: «Peso Total» → **«Peso total»** (las dos, porque la
  primera mide el ancho del rótulo para decidir si las cifras se apilan);
- `containers_list_view.dart:371` y `:373`: «LLENO» / «VACÍO» → **«Lleno» / «Vacío»**.

**En las exportaciones no salen estos textos:** el PDF ya dice «Peso total», «Lleno» y «Vacío»
(`pdf_report_service.dart:163`, `:459`, `:723`); el CSV, «lleno» y «vacío»
(`export_service.dart:97`); el JSON y el BAPLIE de salida llevan códigos. No cambia ninguna
exportación.

**Una más en la misma función, para que Yov decida:** el tercer caso de
`containers_list_view.dart:375` dice «N/A», contra la regla 4 de `DESIGN.md` 11. Propongo «Sin
dato». No la toco sin el sí de Yov.

**Las pruebas que cambian:** `test/t104_text_test.dart:145` y `test/t111_summary_test.dart:94` y
`:119` («Peso Total»), y la de aceptación `tool/t111acc_card_test.dart:81`. Nada en `test/` busca
«LLENO» ni «VACÍO».

**Los censos de T-112:** después de la Fase 2 corro `python -I tool/t112_censos.py` con la
referencia `5406e20` de `--antes` (la de las entregas del rediseño) y salida en
`build/t143/censos/`. Espero las mismas cifras de idioma de la última corrida
(`docs/rediseno/fase3/travesia/correccion/censos/tablas.md`: 1 950 visibles, 0 en inglés) más las
cadenas nuevas de esta tarea, todas en español, y ningún «PENDIENTE». Si el censo se detiene por un
fragmento que movió T-143, lo actualizo en la tabla de decisiones de `tool/t112_censos.py` y lo
declaro.

### 1.5 Las pruebas, las capturas y los archivos

**Pruebas nuevas** (`test/t143_*`; el piso es el de hoy, que mido en el paso 0, y solo sube, sin
omitidas):
1. `t143_estado_de_la_operacion_test.dart`: la función de 1.1, fila por fila de la primera tabla.
2. La cabecera de la oficina: «Sin confirmar», «Confirmado» (sin operación y con la operación sin
   publicar), «Publicada», «Cerrada», con su descripción emergente y su etiqueta; y que la cabecera
   sigue cabiendo en las formas de 14.8 con la letra a 2.0 (las pruebas de T-117 y T-131 siguen
   en verde).
3. **El cierre visto por el muelle, con la nube falsa** (`support/t79_fake_cloud.dart` aprende a
   emitir `closedAt` en la escucha del documento):
   - con red: la oficina cierra y el motor del muelle pasa a `closed` **sin registrar nada**, y
     guarda la operación local cerrada;
   - sin red: no cambia; al volver la red, cambia solo;
   - la escritura pendiente de la propia oficina no adelanta el cierre;
   - la cola: lo de antes del cierre se confirma, lo de después se rechaza, y el chip dice «… la
     operación ya estaba cerrada» sin «regístralo de nuevo»; sin «Reintentar».
4. El adaptador real sobre la Firestore falsa de plataforma de T-129
   (`support/t129_fake_firestore.dart`): la escucha del documento trae `closedAt` y no trae la
   escritura pendiente.
5. «Nube y cuenta» del muelle: «Publicada y cerrada» y el aviso, una sola vez.
6. La silueta: las tres etiquetas de 1.3, con el plan de carga agregado en «Contenido».
7. O-139-6: el flujo de T-139 de punta a punta, «No lo tengo» marcado con su línea; con un valor,
   el valor con su línea; con plantilla y con propuesta, sin marcar (las de 10.15 siguen).
8. O-139-2: la tarjeta con «Peso total» y la Lista con «Lleno» y «Vacío».

**Contra el emulador, si alcanza:** el banco Web de T-130/T-139 (`tool/t130_emu_main.dart`,
`tool/t139_emulador.py`, `tool/t139_control_web.py`; proyecto `demo-t143`, nunca `baystream-app`)
con la oficina a 1920 y el muelle a 360: la oficina cierra y el muelle cambia solo, con red y
después de cortarla y devolverla. Las reglas no cambian.

**Capturas, en `build/t143/`, con BUQUE MANUAL** (los sintéticos de T-100), en el mismo banco Web,
en claro y en oscuro. **Las del antes se toman con el código de hoy, antes de tocar `lib/`.** La
laptop a 1920 × 1080 y el teléfono a 360 × 800, como en T-139:
1. la cabecera confirmada sin nube («Publicado» → «Confirmado»), publicada y cerrada (1920);
2. «Nube y cuenta» del muelle después del cierre, y el aviso (360);
3. «Parámetros del buque» del plan de carga, con el límite (1920);
4. la tarjeta del viaje y la Lista (1920 y 360);
5. la etiqueta de la silueta no se ve: va como volcado de los nodos de semántica, antes y después
   (`build/t143/silueta-nodos-antes.json` y `-despues.json`).

**Archivos que voy a tocar:**
- `lib/`: `vessel_overview_page.dart` (solo la píldora de `_CabeceraDeOficina`),
  `formatters/operation_text.dart`, `pages/cloud_page.dart`, `widgets/sync_status_chip.dart`,
  `widgets/aviso_del_cierre.dart` (nuevo), `data/repositories/sync_engine.dart`,
  `data/repositories/firestore_operation_sync.dart`, `data/repositories/source_revisions.dart`,
  `core/design/componentes/bs_silueta_buque.dart`, `core/design/vistas_previas.dart`,
  `widgets/silueta_del_viaje.dart`, `pages/vessel_geometry_page.dart`,
  `widgets/voyage_summary_card.dart` y `widgets/containers_list_view.dart`; y la causa de O-139-6
  si la reproducción la pone en otro archivo, que declaro.
- `test/`: los `t143_*` nuevos, `support/t79_fake_cloud.dart`, `t114_piezas_test.dart` (su etiqueta
  de la silueta), `t114_fase3_entrega2_correccion_test.dart` si construye la pieza,
  `t104_text_test.dart` y `t111_summary_test.dart`.
- `tool/`: `t111acc_card_test.dart`, `tool/t112_censos.py` solo si el censo lo pide, y los scripts
  del banco con prefijo `t143_`.
- `DESIGN.md`: 7.2, 14.8 (la píldora) y 13.8 / 15.9 (los wireframes que dicen «(Publicado)»).
- **No cambian:** `lib/main.dart`, los dos congelados, `pubspec.*`, las reglas de Firestore y
  Firebase real. Los pasos del manual que cambian (3.3, 7.3 y 7.11) van como propuesta en este
  informe.

## 2. Las decisiones sobre la propuesta (11-nov)

La propuesta quedó como estaba en la Fase 1; Carlos la aprobó con los ajustes de Yov:

1. **Los seis avisos de `tool/` se corrigen en un commit aparte, antes del de T-143** (Carlos y
   Yov): «`analyze` en cero» es una restricción dura del sprint (sección 2 de `SPRINT-4.md`) y la
   punta no la cumple desde el 4-nov.
   - En `tool/t140_volcado_test.dart` solo cambia el comentario: el comando va en un bloque de
     código, sin `< >` sueltos.
   - En `tool/t141_fuzz_baplie.dart`, `print` pasa a `stdout.writeln`, con la misma salida y sin
     `// ignore:`.
   - No se vuelven a correr T-140 ni T-141.
   - El commit lleva solo esos dos archivos: «Sprint 4: analyze en cero otra vez, tool de T-140 y
     T-141».
2. **La píldora dice «Confirmado»** (Yov), con la frase entera en la descripción emergente y en
   la etiqueta accesible.
3. **«N/A» pasa a «Sin dato»** en la Lista (Yov).
4. **Bloquear el registro en el muelle después del cierre no entra en T-143** (Yov): queda como
   **O-143-1**, para el frente de usabilidad. Con la píldora, el aviso y «Nube y cuenta», el
   muelle ya se entera antes de registrar.
5. **O-139-6** (Yov): la línea dice «Del perfil guardado: “No lo tengo”.» o «Del perfil guardado:
   90 000 kg por pila.», con el valor que tenga. Si la reproducción muestra que ya venía marcado,
   se dice, y solo cambian la línea y `DESIGN.md` 7.2.
6. **Luz verde para la Fase 2 y para el emulador** con `demo-t143` (Carlos), un comando de
   Flutter a la vez y con SEMÁFORO.
7. **El ALTO de «Confirmado»** (Carlos y Yov, 11-nov, después de la sección 3.4). Se aceptan
   las dos líneas solo en «Confirmado» y solo cuando no cabe. Con «Publicada» y «Cerrada», T-131
   sigue exigiendo una línea de 92 dp. Se suman dos casos de «Confirmado» (1366 con la letra a
   2.0 en dos líneas de 144 dp; 1920 con la letra a 2.0 en una línea) y la prueba de que, al
   publicar, no se pierden la bahía, el zoom ni el desplazamiento. La excepción va en
   `DESIGN.md` 14.8, y el censo de T-112 queda como O-143-2.

## 3. Lo hecho (Fase 2, 11-nov, 00:00 a 01:25)

### 3.1 El commit aparte de `analyze`

- `tool/t140_volcado_test.dart`: el comando del comentario va en un bloque de código; solo
  cambia el comentario.
- `tool/t141_fuzz_baplie.dart`: `print` → `stdout.writeln` en las cinco líneas (56, 66, 67, 71 y
  73), con la misma salida y sin `// ignore:`. `dart:io` ya estaba importado.
- `flutter analyze`: **«No issues found!»** (SEMÁFORO 00:07:43 a 00:09:45). No se volvieron a
  correr T-140 ni T-141.

### 3.2 El antes, en el banco Web, con el código de la 1.0.0

El piso, antes de tocar `lib/`: **2107 de 2107**, sin omitidas, en 3 min 53 s
(`build/t143/suite-antes.log`).

El banco es el de T-139: `tool/t130_emu_main.dart` compilado en `build/t143/web-antes`, el
emulador `demo-t143` (Auth 9399, Firestore 8383, las reglas de T-130 y dos cuentas sintéticas)
y los sintéticos de T-100, con las huellas de T-139 (`T100_LLEGADA.edi` `9573cfd7…`,
`T100_CARGA.edi` `4acf7539…`). La oficina va a 1920 × 1080 y el teléfono a 360 × 800, en el
Chrome de Playwright, como en T-139. El recorrido reprodujo:

- **O-139-7:** la cabecera dice «Publicado» con la nube en «Solo este dispositivo» (`antes-01`).
  Sigue diciendo «Publicado» con la operación publicada (`antes-02`) y también **cerrada**
  (`antes-06`).
- **O-139-1:** con la operación cerrada por la oficina, el muelle sigue en «Publicada» · «Al
  día», con «No hay operaciones abiertas» (`antes-05`).
- **O-139-3:** con el plan de carga agregado y «Carga 30» en la cabecera, cada bahía dice «sin
  operación» (`silueta-nodos-antes-plan-de-carga.json`). En la llegada, las bahías sin descarga
  también lo dicen, por ejemplo «Bahía 03, sin carga, sin operación»
  (`silueta-nodos-antes-llegada.json`).
- **O-139-6 no se reproduce.** Al confirmar el plan de carga sobre la operación publicada, «No lo
  tengo» **ya venía marcado** (`aria-checked=true`, `antes-03`), por la regla de la corrección
  10.15. La prueba `t143_limite_del_perfil_test.dart`, escrita antes de tocar `lib/`, también
  pasó con el código de la 1.0.0. Lo que estaba mal era el texto de `DESIGN.md` 7.2 que citó
  T-139. Por la decisión 5, solo cambian la línea y 7.2.
- **O-139-2:** «Peso Total» y «LLENO» / «VACÍO», en la oficina y en el teléfono (`antes-04*`).

### 3.3 El código

| Archivo | Qué cambia |
|---|---|
| `presentation/formatters/operation_text.dart` | La regla única: `EstadoDeLaOperacion`, `estadoDeLaOperacion`, `textoDelEstado`, `fraseDelEstado`, `textoDeLaOperacionEnLaNube` y `operationIsClosed`. Cada frase empieza por la palabra visible, para que la etiqueta contenga lo que se ve. Por eso la de «Cerrada» es «Cerrada por la oficina: ya no se registran movimientos» y no «Operación cerrada…», como decía la propuesta |
| `pages/vessel_overview_page.dart` | La píldora (`cabecera-estado`), con la palabra, su descripción emergente y su etiqueta. `AvisoDelCierre`, junto a `AvisoDelPlan` |
| `data/repositories/sync_engine.dart` | `RemoteOperationDocument` (el manifiesto y `closedAt`) y `watchOperation` en lugar de `watchSources`: es la misma escucha. `_markClosed` guarda el cierre sobre la operación local de ahora. El camino del rechazo, que lo guardaba sobre la operación del arranque, ahora también lo usa, y así no se pierde un plan que llegó entretanto (lo prueba `t143_cierre_test.dart`) |
| `data/repositories/firestore_operation_sync.dart` | La escucha del documento trae `closedAt`. La vista con una escritura propia pendiente sigue sin contar |
| `widgets/aviso_del_cierre.dart` (nuevo) y `providers/sync_providers.dart` | El aviso, una vez: «La oficina cerró la operación de GTSTC. Lo que registres desde ahora se rechazará.». Pide releer la operación. No sale en el equipo que cerró (`operacionesCerradasAquiProvider`) ni con una operación que ya estaba cerrada al abrirse |
| `pages/cloud_page.dart` | Lee el cierre que vio el motor. Con la operación cerrada no ofrece «Cerrar operación» ni «Reintentar». Anota el cierre propio antes de escribir en la nube |
| `widgets/sync_status_chip.dart` | Con la operación cerrada: «N rechazados: la operación ya estaba cerrada» |
| `core/design/componentes/bs_silueta_buque.dart` y `widgets/silueta_del_viaje.dart` | La etiqueta dice el motivo real (`sinAvance`): «sin operación» sin escala, «sin movimientos en GTSTC» si la silueta muestra el avance y la bahía no tiene trabajo, y nada en un plan de carga en «Contenido» |
| `pages/vessel_geometry_page.dart` | «Del perfil guardado: “No lo tengo”.» o «Del perfil guardado: 90 000 kg por pila.», mientras lo que se ve sea lo del perfil |
| `widgets/voyage_summary_card.dart` y `widgets/containers_list_view.dart` | «Peso total», «Lleno», «Vacío» y «Sin dato» |

### 3.4 La excepción de «Confirmado» (el ALTO del 11-nov, resuelto)

A la letra 2.0, «Confirmado» mide 128.4 px y «Publicado» medía 109.5. A 1366 dp, la cabecera de
la oficina ya no cabe en la línea de 92 dp que fijó T-131 y pasa a dos líneas, de 144 dp.
«Publicada» (109.2 px) y «Cerrada» (87.3 px) siguen cabiendo. Carlos y Yov aceptaron las dos
líneas con cinco condiciones. Así quedaron:

1. **Solo en «Confirmado» y solo cuando no cabe.** La prueba de T-131 de la cabecera a 600 y a
   1366 dp, con la letra a 1.0 y a 2.0, corre ahora con la operación publicada y con la
   operación cerrada (8 casos, antes 4). Exige la línea de 92 dp sin cambios, y comprueba que la
   píldora dice «Publicada» o «Cerrada».
2. **Dos casos nuevos de «Confirmado»:** a 1366 con la letra a 2.0, dos líneas de 144 dp sin nada
   cortado; a 1920 con la letra a 2.0, una línea de 92 dp.
3. **Al publicar, la cabecera pasa de dos líneas a una** sin perder la bahía elegida (006), el zoom
   (200 %) ni el desplazamiento horizontal de la rejilla. La prueba los fija antes de publicar y
   los compara después.
4. **La excepción está escrita en `DESIGN.md` 14.8.**
5. **El censo de T-112 queda como O-143-2** (sección 4).

`test/support/t131_cabeceras_support.dart` acepta ahora la operación de la escala
(`operacion:`), que se vuelve a leer con `operationSourcesRevisionProvider`, como en la app al
publicar. La nueva función `t131Operacion` la construye.

### 3.5 Las pruebas

- **Nuevas, 38:**
  - `t143_estados_test.dart` (16): la regla, el chip, la píldora en los cuatro casos, la cabecera
    a 1024 dp con la letra a 1.0 y a 2.0, la silueta y los textos;
  - `t143_cierre_test.dart` (12): el motor con red, sin red y con la cola; el plan que no se
    pierde; el adaptador real sobre la Firestore falsa de T-129, también desde la caché; el aviso
    una vez, en el equipo que cerró y con una operación ya cerrada; «Nube y cuenta» del muelle
    en claro y en oscuro; la oficina;
  - `t143_limite_del_perfil_test.dart` (3): el recorrido de 7.7 con «No lo tengo», con un valor
    y con la propuesta;
  - `t131_cabeceras_test.dart` (+7): los 4 casos de «Cerrada» y los 3 de «Confirmado».
- **Cambiaron, por decisión de la propuesta:**
  - `t79_cloud_page_test.dart`: el chip con un rechazado y la operación cerrada;
  - `t114_piezas_test.dart`: la pieza ya no inventa «sin operación» y dice el motivo que le dan;
  - `t104_text_test.dart`, `t111_summary_test.dart` y `tool/t111acc_card_test.dart`: «Peso total»;
  - `support/t79_fake_cloud.dart`: aprende `watchOperation` y `closeOperation`.

### 3.6 `DESIGN.md`

- 7.2, paso 3: la regla del límite.
- 11, regla 3: los tres textos y «Sin dato».
- 14.8: la regla del estado, con su tabla, y la excepción de «Confirmado».
- La tabla de 13.1 («chips de estado («Publicada»)») y los wireframes de 13.8 y 15.9
  («(Publicada)»).

## 4. Las validaciones

| Qué | Resultado |
|---|---|
| `flutter analyze` | **«No issues found!»** (01:13:21) |
| La suite | **2145 de 2145, sin omitidas** (`build/t143/suite-despues.log`, 2 min 24 s): el piso de 2107 más 38 |
| Las pruebas de T-131 | 59 de 59 (`build/t143/t131.log`) |
| El banco del después | `build/t143/web-despues` (`main.dart.js` `5fd6442c…`; el del antes era `85f03870…`) |
| El censo de T-112 | **O-143-2.** En la punta de hoy, antes de T-143, el censo se detiene con **143 cadenas sin decisión**, todas de tareas posteriores a su última corrida (la travesía, `f27de53`): 55 de `resumen_del_modo.dart`, 15 de `departure_baplie_review.dart`, 12 de `fecha_corta.dart`, 10 de `aviso_del_plan.dart` y las demás de T-117 a T-131 (`build/t143/censos-antes.txt`). Queda para el bloque de calidad. **T-143 suma dos cadenas, las dos en español**, en el archivo nuevo `aviso_del_cierre.dart`: «La oficina cerró la operación de {port}. Lo que registres desde ahora se rechazará.» y su forma corta «La oficina cerró la operación de {port}.». No desaparece ninguna (`build/t143/censos-despues.txt`) |

**El cierre visto por el muelle, contra el emulador** (`demo-t143`, 01:17 a 01:24). Había dos
teléfonos unidos a la misma operación: «muelle», con red y sin registrar nada, y «muelle2», sin
red y con una descarga registrada antes del cierre.

1. La oficina cerró. En segundos, **«muelle» cambió solo**: el aviso «La oficina cerró la
   operación de GTSTC. Lo que registres desde ahora se rechazará.», el chip «Al día · operación
   cerrada» y «Nube y cuenta» en «Publicada y cerrada» (`despues-05`). En la oficina no salió el
   aviso.
2. «muelle2», sin red, siguió en «Sin conexión · 1 por enviar», sin saberlo. Después del cierre
   registró otra descarga: «2 por enviar».
3. Al devolverle la red, **«muelle2» cambió solo**: el aviso (`despues-07`); la descarga de antes
   del cierre se confirmó (MNLU0000107, «descargado»); la de después se rechazó y la celda volvió
   a «por descargar» (MNLU0000093); y el chip quedó en «Al día · 1 rechazado: la operación ya
   estaba cerrada · operación cerrada», sin «Reintentar» (`despues-08`).

**Lo que el banco mostró del resto:**

- la cabecera dice «Confirmado» con la nube en «Solo este dispositivo» (`despues-01`), «Publicada»
  (`despues-02`) y «Cerrada» (`despues-06`);
- el plan de carga llega con «No lo tengo» marcado y la línea «Del perfil guardado: “No lo
  tengo”.» (`despues-03`);
- con el plan agregado en «Contenido», ninguna bahía dice «sin operación»
  (`silueta-nodos-despues-plan-de-carga.json`); en la llegada, la 03 dice «sin movimientos en
  GTSTC» (`silueta-nodos-despues-llegada.json`);
- la Lista dice «Peso total», «Lleno» y «Vacío» (`despues-04*`).

### 4.1 Las capturas

Están en `build/t143/capturas/`, fuera de Git, con sus huellas SHA-256 en
`build/t143/capturas-huellas.txt`. Son 35 PNG a escala 2: la oficina a 1920 px y el teléfono a
360 dp, en claro y en oscuro.

| Antes | Después | Qué |
|---|---|---|
| `antes-01-cabecera-confirmado-*` | `despues-01-cabecera-confirmado-*` | «Publicado» → «Confirmado», con la nube en «Solo este dispositivo» |
| `antes-02-cabecera-publicada-*` | `despues-02-cabecera-publicada-*` | «Publicado» → «Publicada» |
| `antes-06-cabecera-cerrada-*` | `despues-06-cabecera-cerrada-*` | «Publicado» → «Cerrada» |
| `antes-03-limite-plan-de-carga-*` | `despues-03-limite-plan-de-carga-*` | «No lo tengo» ya marcado; después, con su línea |
| `antes-04-lista-*`, `antes-04-lista-muelle-*`, `antes-04b-lista-filas-muelle-*` | los mismos con `despues-` | «Peso total», «Lleno», «Vacío» |
| `antes-05-nube-muelle-cerrada-*` | `despues-05-nube-muelle-cerrada-*` | El muelle después del cierre: «Publicada» · «Al día» → «Publicada y cerrada» · «Al día · operación cerrada» |
| — | `despues-07-aviso-cierre-muelle-claro` | El aviso del cierre en el teléfono |
| — | `despues-08-nube-muelle-rechazado-*` | El muelle que tenía cola: un rechazado, sin «Reintentar» |

La etiqueta de la silueta no se ve: va como volcado de los nodos, antes y después, en
`build/t143/silueta-nodos-*.json`.

## 5. Lo que no se pudo, y por qué

- **El aviso del cierre solo en claro.** Sale una vez y dura 8 s. En «muelle» se fue antes de la
  captura, y queda su nodo en el volcado; en «muelle2» lo capturé en claro, y para el oscuro
  habría hecho falta otro cierre.
- **Ni Windows ni el Honor.** El teléfono se recorrió en la Web a 360 dp y la laptop en la Web a
  1920 px, como en T-139: es el mismo código de `lib/` y no se usaron el almacén real ni un
  dispositivo físico. Cuando se arme la versión de los tres clientes, una vuelta corta por
  Windows y el Honor confirma la píldora y el aviso.
- **La cabecera de dos líneas** (1366 dp con la letra a 2.0) está probada en `t131`, sin captura
  en el banco.
- **El censo de T-112** no se pone al día aquí (O-143-2).

## 6. Las observaciones

- **O-143-1** (Yov, decisión 4): bloquear el registro en el muelle después de saber del cierre.
  Queda para el frente de usabilidad. Hoy, el toque se registra en el equipo y la nube lo rechaza
  con el texto nuevo.
- **O-143-2** (Carlos, 11-nov): poner al día el censo de T-112, que se detiene en 143 cadenas sin
  decisión de las tareas posteriores a la travesía. Es para el bloque de calidad.
- **Lo que el informe de T-139 dijo de O-139-6** («Es lo que dice `DESIGN.md` 7.2») venía del
  texto de `DESIGN.md`, no de la pantalla. Con la 1.0.0, el banco y la prueba muestran «No lo
  tengo» marcado. El arreglo de 7.2 lo deja dicho.

## 7. Los pasos del manual que cambian (propuesta para Yov)

`docs/MANUAL-USUARIO-1.0.0.md`:

- **3.3, paso 9 (líneas 215 a 220):** «… se crea la operación de la escala y la cabecera dice
  **«Confirmado»**: confirmado en este equipo, todavía no en la nube. Subirla a la nube es
  «Publicar operación», en «Nube y cuenta» (7.3); desde entonces la cabecera dice «Publicada».»
  Así sobra la aclaración entre «Publicado» y «Publicada».
- **3.3, paso 7:** al final, «Si el perfil guardado del buque ya lo tiene resuelto, viene
  resuelto y lo dice: “Del perfil guardado: …”».
- **El pie de la figura 13:** «El plano confirmado: «Confirmado», la escala GTSTC en la cabecera…».
  Las figuras 13, 24, 28 y 41 muestran la píldora de antes y se pueden volver a tomar con el
  banco de T-143.
- **4.1 (línea 292):** «el estado («Sin confirmar», «Confirmado», «Publicada» o «Cerrada»)».
- **7.3:** «… el estado pasa a «Publicada» con «Al día», y la cabecera también dice «Publicada»».
- **7.7:** «revisa los parámetros (la escala ya viene en GTSTC y el límite, del perfil guardado)».
- **7.10, la tabla del chip:** una fila más: «N rechazados: la operación ya estaba cerrada» · «La
  oficina cerró la operación antes de esos movimientos: no se registran de nuevo».
- **7.11, el párrafo del muelle (líneas 648 a 653):** «En el muelle, el cierre llega solo: sale el
  aviso «La oficina cerró la operación de GTSTC. Lo que registres desde ahora se rechazará.»,
  «Nube y cuenta» dice «Publicada y cerrada» y el chip «Al día · operación cerrada». Sin red, el
  muelle se entera al volver la red. Lo registrado antes del cierre sube igual; lo registrado
  después se rechaza: «1 rechazado: la operación ya estaba cerrada».» Así sobra el «(no
  recorrido en esta edición)».
- **5.2, la Lista:** si alguna figura o texto cita «LLENO» o «VACÍO», pasa a «Lleno» y «Vacío». En
  el texto no hay ninguna; se ve en la figura 23.

## 8. Archivos

**Commit 1, `tool/`** (solo estos dos):

- `tool/t140_volcado_test.dart`
- `tool/t141_fuzz_baplie.dart`

**Commit 2, T-143:**

- `lib/`, modificados: `core/design/componentes/bs_silueta_buque.dart`,
  `features/vessel/data/repositories/firestore_operation_sync.dart`,
  `features/vessel/data/repositories/sync_engine.dart`,
  `features/vessel/presentation/formatters/operation_text.dart`,
  `features/vessel/presentation/pages/cloud_page.dart`,
  `features/vessel/presentation/pages/vessel_geometry_page.dart`,
  `features/vessel/presentation/pages/vessel_overview_page.dart`,
  `features/vessel/presentation/providers/sync_providers.dart`,
  `features/vessel/presentation/widgets/containers_list_view.dart`,
  `features/vessel/presentation/widgets/silueta_del_viaje.dart`,
  `features/vessel/presentation/widgets/sync_status_chip.dart` y
  `features/vessel/presentation/widgets/voyage_summary_card.dart`.
- `lib/`, nuevo: `features/vessel/presentation/widgets/aviso_del_cierre.dart`.
- `test/`, nuevos: `t143_estados_test.dart`, `t143_cierre_test.dart` y
  `t143_limite_del_perfil_test.dart`.
- `test/`, modificados: `support/t79_fake_cloud.dart`, `support/t131_cabeceras_support.dart`,
  `t131_cabeceras_test.dart`, `t114_piezas_test.dart`, `t79_cloud_page_test.dart`,
  `t104_text_test.dart` y `t111_summary_test.dart`.
- `tool/`, modificado: `t111acc_card_test.dart`.
- `tool/`, nuevos: `t143_emulador.py` y `t143_control_web.py` (los de T-139 con el proyecto
  `demo-t143` y sus rutas) y `t143_banco.py` (los ayudantes para conducirlo).
- `DESIGN.md`.
- `docs/T143-RESULTADOS.md` (este informe).

**Sin cambios:** `lib/main.dart`, `lib/latency_test_screen.dart`,
`lib/c3_reconciliation_screen.dart`, **`pubspec.yaml` y `pubspec.lock`**, las reglas de Firestore
y Firebase real. `test/t114_fase3_correccion_test.dart` y los `windows/flutter/generated_*`
siguen apareciendo modificados solo por el fin de línea (paso 0): no son de T-143 y no van en
ningún bloque.

**Evidencias, fuera de Git** (`build/t143/`):

- `semaforo.log`;
- `suite-antes.log` y `suite-despues.log`;
- `pruebas-t143.log`, `pruebas-tocadas.log` y `t131.log`;
- `01-build-web-antes.log` y `02-build-web-despues.log`;
- `web-antes/` y `web-despues/`;
- `capturas/` y `capturas-huellas.txt`;
- `silueta-nodos-*.json`;
- `censos-antes.txt` y `censos-despues.txt`.

En `%TEMP%\t143\` quedan los perfiles de Chrome, el emulador y la copia de `5406e20`: se pueden
borrar.

## 9. Para Carlos: los comandos de Git

Primero el commit de `tool/`, después el de T-143. Un `git add` por ruta.

```
git add tool/t140_volcado_test.dart
git add tool/t141_fuzz_baplie.dart
git commit -m "Sprint 4: analyze en cero otra vez, tool de T-140 y T-141"
```

```
git add lib/core/design/componentes/bs_silueta_buque.dart
git add lib/features/vessel/data/repositories/firestore_operation_sync.dart
git add lib/features/vessel/data/repositories/sync_engine.dart
git add lib/features/vessel/presentation/formatters/operation_text.dart
git add lib/features/vessel/presentation/pages/cloud_page.dart
git add lib/features/vessel/presentation/pages/vessel_geometry_page.dart
git add lib/features/vessel/presentation/pages/vessel_overview_page.dart
git add lib/features/vessel/presentation/providers/sync_providers.dart
git add lib/features/vessel/presentation/widgets/aviso_del_cierre.dart
git add lib/features/vessel/presentation/widgets/containers_list_view.dart
git add lib/features/vessel/presentation/widgets/silueta_del_viaje.dart
git add lib/features/vessel/presentation/widgets/sync_status_chip.dart
git add lib/features/vessel/presentation/widgets/voyage_summary_card.dart
git add test/t143_estados_test.dart
git add test/t143_cierre_test.dart
git add test/t143_limite_del_perfil_test.dart
git add test/support/t79_fake_cloud.dart
git add test/support/t131_cabeceras_support.dart
git add test/t131_cabeceras_test.dart
git add test/t114_piezas_test.dart
git add test/t79_cloud_page_test.dart
git add test/t104_text_test.dart
git add test/t111_summary_test.dart
git add tool/t111acc_card_test.dart
git add tool/t143_emulador.py
git add tool/t143_control_web.py
git add tool/t143_banco.py
git add DESIGN.md
git add docs/T143-RESULTADOS.md
git commit -m "Sprint 4: T-143, los estados y los textos de la operacion"
git push
```

`pubspec.yaml` y `pubspec.lock` no cambian.

## 10. Horas

Fase 1: 1.5 h (lecturas, código y propuesta). Fase 2: 1.5 h (el commit de `tool/`, el antes,
el código, las pruebas, el ALTO, el después y el emulador). Total: 3.0 h.

## 11. En tres líneas

- La cabecera dice «Confirmado», «Publicada» o «Cerrada» con una sola regla para los tres
  clientes, y el muelle se entera del cierre sin registrar nada, también al volver la red.
- La silueta dice el motivo real; el límite dice que viene del perfil guardado (O-139-6 ya venía
  marcado); y la tarjeta y la Lista van en tipo oración.
- `analyze` cero, suite 2145 de 2145 y el cierre comprobado contra el emulador; la cabecera de
  dos líneas solo en «Confirmado» cuando no cabe (14.8).

## 12. Para Yov

> T-143 entregada en `docs/T143-RESULTADOS.md`. `analyze` cero y suite 2145 de 2145, sin
> omitidas (piso 2107). Contra el emulador, el muelle con red se enteró solo del cierre, y el
> que no tenía red cambió al volver la red: lo de antes del cierre entró y lo de después se
> rechazó con «1 rechazado: la operación ya estaba cerrada». O-139-6 ya venía marcado en la
> 1.0.0: solo cambian la línea «Del perfil guardado…» y 7.2. La excepción de «Confirmado» quedó
> con tus cinco condiciones en `t131` y en 14.8. En la sección 7 van los pasos del manual que
> cambian (3.3, 4.1, 7.3, 7.7, 7.10 y 7.11) y las figuras que se pueden volver a tomar. Quedan
> O-143-1 (bloquear el registro después del cierre) y O-143-2 (el censo de T-112). Dos commits:
> primero `tool/` y después T-143.

## 13. Corrección 1 (T143-ACC-01 y -02)

11-nov, de 02:25 a 02:40 según el reloj de la máquina (las líneas de SEMÁFORO de `build/t143/semaforo.log`), sobre `e5eff4e` (10.119). La aceptación de Codex
(`docs/t143/aceptacion-codex.md`) no pasó por un P2.

### 13.1 T143-ACC-01 (P2): el cierre se guarda una sola vez

**La causa,** la que describió Codex. `_markClosed` se llamaba desde el documento y desde cada
rechazo. La guarda `!_closed` solo protegía el camino del documento, y cada llamada leía la
operación local antes de que otra terminara de guardar: todas la veían abierta y todas la
guardaban. Además, `_syncList` y `_syncPlans` leían y guardaban la operación local por su cuenta,
así que una copia vieja podía caer encima del cierre, o al revés.

**La corrección,** solo en `lib/features/vessel/data/repositories/sync_engine.dart`:
- **Una sola persistencia del cierre.** `_markClosed` marca `_closed` y devuelve la persistencia
  memorizada en `_closing`. La primera llamada la crea; las siguientes (el documento y los demás
  rechazos) esperan esa misma y no vuelven a guardar. Si el motor arrancó con la operación ya
  cerrada, la persistencia relee, la ve cerrada y no guarda.
- **Una cola para las escrituras del motor sobre la operación local** (`_enCola`): el cierre, el
  listado (T-127) y el plan agregado (T-130). Cada escritura relee la operación dentro de su turno
  y guarda sobre esa lectura. Bajar los trozos de la nube va fuera de la cola; solo la lectura y
  el guardado esperan su turno.
- El aviso, los textos y la regla del estado no cambian.

**Las pruebas permanentes,** `test/t143_cierre_una_vez_test.dart` (4), contra la nube falsa de
T-79 y Hive real. La bitácora cuenta los guardados de la operación cerrada y, en tres de las
pruebas, demora 15 ms la lectura de la operación para abrir la ventana de la carrera; no cambia
lo que lee ni lo que guarda.
1. **La sonda de Codex:** sin red, el documento cerrado y dos rechazos al volver la red dan **un
   solo guardado**.
2. Lo mismo con tres rechazos y las lecturas lentas: un guardado.
3. **El plan de carga agregado llega a la vez que el cierre:** quedan guardados el cierre, el plan
   y la llegada.
4. **Una revisión del listado llega a la vez que el cierre:** quedan guardados el cierre, el
   listado y la llegada.

**En rojo contra el motor de la entrega** (`04cd717`, puesto un momento en el árbol y restaurado
después; se comprobó idéntico con `cmp`): las cuatro fallan. La sonda da 3 guardados del cierre
(lo que midió Codex), 4 con lecturas lentas, y 3 en cada prueba de la fuente. En esas corridas no
se perdió el cierre ni la fuente: el defecto observado son los guardados de más
(`build/t143/correccion1-rojo-04cd717.log`).

### 13.2 T143-ACC-02 (P3): la frase en 14.8

Como decidió Yov, `DESIGN.md` 14.8 suma al final de la excepción de «Confirmado»: todo vale para
la identidad de referencia de T-131 (BUQUE MANUAL con un viaje de cuatro caracteres). Con un
nombre o un viaje más largos, la cabecera puede ir en dos líneas también con «Publicada» o
«Cerrada», por la regla general, sin nada cortado. La cabecera se rehace en el frente de
usabilidad. No se agregó cobertura.

### 13.3 Las validaciones

| Qué | Resultado |
|---|---|
| `flutter analyze`, todo el paquete | **«No issues found!»** (02:34:12 a 02:35:06). En esta carpeta existe `build/t124/entradas/t124_entradas.dart`; en una copia limpia sin ese archivo, `tool/t124_main.dart` no compila: es O-143-3 (10.119), del bloque de calidad |
| Las pruebas del motor y del cierre | 71 de 71: las 4 nuevas, `t143_cierre`, `t79_sync_engine`, `t127_listado_revision`, `t130_plan_agregado` y `t129_cierre` (`build/t143/correccion1-pruebas.log`) |
| **La suite, en una sola corrida** | **2149 de 2149, sin omitidas**, en 2 min 42 s (02:35:12 a 02:37:58; `build/t143/suite-correccion1.log`): las 2145 de la entrega más las 4 nuevas |

No hizo falta volver al emulador ni a las capturas: la corrección no cambia nada de lo que se ve.

### 13.4 Archivos de la corrección

- `lib/features/vessel/data/repositories/sync_engine.dart`, modificado;
- `test/t143_cierre_una_vez_test.dart`, nuevo;
- `DESIGN.md`, 14.8;
- `docs/T143-RESULTADOS.md`, esta sección.

`pubspec.yaml` y `pubspec.lock` no cambian; tampoco `lib/main.dart` ni los congelados.

### 13.5 Para Carlos: el bloque de Git de la corrección

```
git add lib/features/vessel/data/repositories/sync_engine.dart
git add test/t143_cierre_una_vez_test.dart
git add DESIGN.md
git add docs/T143-RESULTADOS.md
git commit -m "Sprint 4: T-143, correccion 1, el cierre se guarda una vez"
git push
```

### 13.6 Horas

Corrección 1: 0.5 h. Total de T-143: 3.5 h.

### 13.7 En tres líneas

- El cierre se guarda una sola vez: el documento y los rechazos comparten una persistencia
  memorizada.
- El cierre, el listado y el plan escriben la operación local en una sola cola del motor, sin
  copias viejas; cuatro pruebas permanentes, rojas contra la entrega.
- `analyze` cero, la suite 2149 de 2149 en una corrida, y la frase de ACC-02 en 14.8.

### 13.8 Para Yov

> T-143, corrección 1, en la sección 13 de `docs/T143-RESULTADOS.md`. ACC-01: el cierre se guarda
> una vez (una persistencia memorizada que comparten el documento y los rechazos), y el cierre,
> el listado y el plan escriben la operación local en una sola cola del motor. Hay cuatro pruebas
> permanentes en `test/t143_cierre_una_vez_test.dart`: la sonda de Codex y el plan o el listado
> que llegan a la vez que el cierre. Las cuatro fallaban contra `04cd717` (3 y 4 guardados, sin
> pérdida de datos). ACC-02: la frase va en 14.8. `analyze` cero y suite 2149 de 2149 en una
> corrida. Un commit: «Sprint 4: T-143, correccion 1, el cierre se guarda una vez».

## 14. Corrección 2 (T143-ACC-03)

11-nov, de 03:00 a 03:15 según el reloj de la máquina (las líneas de SEMÁFORO de
`build/t143/semaforo.log`), sobre `ba79d10` (10.120). La reaceptación de Codex (sección 11 de
`docs/t143/aceptacion-codex.md`) no pasó por un P2 nuevo, introducido por la corrección 1.

### 14.1 La causa

`saveOperation` avisa los errores con un `Left`, no con una excepción: el `await` termina
normalmente. `_markClosed` no miraba el resultado. Un primer guardado fallido quedaba memorizado
en `_closing` como hecho:
- el rechazo siguiente esperaba ese mismo futuro ya resuelto y no volvía a guardar;
- el documento no lo intentaba, por la guarda `!_closed`;
- `retry()` no tocaba el cierre.

El motor quedaba «Al día · operación cerrada» con la operación local abierta.

### 14.2 La corrección

Solo en `lib/features/vessel/data/repositories/sync_engine.dart`:
- **Se distinguen el cierre conocido y el guardado.** `_closed` es el cierre que el motor
  conoce, el que dice `SyncStatus.closed`. `_closedSaved` es el que guardó en la operación local:
  al arrancar vale lo mismo que `operation.closed`, y después solo cambia con un guardado que
  devuelve `Right`. `_knownClosedAt` recuerda la hora del cierre para volver a intentarlo.
- **Un guardado fallido no se memoriza.** Dentro de la cola, la persistencia devuelve si guardó:
  `true` con `Right` o si la operación ya estaba cerrada; `false` con `Left`, con una excepción o
  si el motor se detuvo. Con `true` se marca `_closedSaved`; con `false` se libera `_closing`.
- **Se vuelve a intentar** con el siguiente rechazo, con el documento (la guarda pasa de
  `!_closed` a `!_closedSaved`) y con `retry()`, que con un cierre conocido y sin guardar lo
  intenta otra vez. El guardado es local, así que también funciona sin red.
- **Se mantiene la corrección 1.** Las llamadas que llegan mientras un guardado está en curso
  esperan ese mismo guardado y no guardan de nuevo. Ya guardado, `_markClosed` vuelve enseguida.
  La cola de escrituras no cambia.

**El listado y el plan no tienen el problema.** Ninguno de los dos memoriza su guardado:
- el listado actualiza `_localListRevision` solo si el guardado devolvió `Right`;
- el plan agrega su tipo a `_localPlans` solo si el guardado devolvió `Right`;
- con un `Left` no se anota nada, y el siguiente `_syncSources` lo vuelve a bajar y a guardar.
  Ese `_syncSources` llega con el reloj del motor, con la siguiente instantánea del servidor o
  con el documento;
- una excepción la recoge el `catch` de cada uno, y su `finally` libera `_fetchingList` o
  `_fetchingPlan`.

No los toqué.

### 14.3 Las pruebas permanentes

El grupo «corrección 2» de `test/t143_cierre_una_vez_test.dart` suma 6 pruebas. La bitácora de
prueba ahora puede hacer fallar los primeros guardados de la operación cerrada, con un `Left` o
con una excepción, y separa los intentos de los guardados buenos.

1. **La sonda de Codex** (`save_failure_test.dart`): el primer guardado da `Left`. El motor conoce
   el cierre y la operación local sigue abierta. Después, un rechazo y `retry()`: la operación
   local queda cerrada, con un solo guardado bueno.
2. El rechazo siguiente, solo, basta para guardarlo.
3. `retry()`, solo y sin red, basta.
4. El documento, cuando vuelve a llegar (se va la red y vuelve), basta.
5. Una excepción al guardar tampoco queda como hecho.
6. **El fallo con llamadas concurrentes:** sin red, el documento cerrado y tres rechazos llegan
   juntos al volver la red, con lecturas lentas. El primer guardado falla. Al final, un solo
   fallido, **un solo guardado bueno** y la operación local cerrada.

Las cuatro de la corrección 1 siguen en verde.

**En rojo contra `b336117`** (el motor de la corrección 1, puesto un momento en el árbol y
restaurado después; se comprobó idéntico con `cmp`): **las 6 nuevas fallan y las 4 de la
corrección 1 pasan** (`build/t143/correccion2-rojo-b336117.log`).

### 14.4 Las validaciones

| Qué | Resultado |
|---|---|
| `flutter analyze`, todo el paquete | **«No issues found!»** (03:06:14 a 03:07:07). Sigue O-143-3: en esta carpeta existe el archivo generado de T-124 |
| Las pruebas del motor y del cierre | **77 de 77**: `t143_cierre_una_vez` (10), `t143_cierre`, `t79_sync_engine`, `t127_listado_revision`, `t130_plan_agregado` y `t129_cierre` (`build/t143/correccion2-pruebas.log`) |
| **La suite, en una sola corrida** | **2155 de 2155, sin omitidas**, en 2 min 59 s (03:07:07 a 03:10:11; `build/t143/suite-correccion2.log`): las 2149 de la corrección 1 más las 6 nuevas |

No hizo falta volver al emulador ni a las capturas: la corrección no cambia nada de lo que se ve.

### 14.5 Archivos de la corrección 2

- `lib/features/vessel/data/repositories/sync_engine.dart`, modificado;
- `test/t143_cierre_una_vez_test.dart`, modificado (la bitácora de prueba y el grupo nuevo);
- `docs/T143-RESULTADOS.md`, esta sección.

`DESIGN.md`, `pubspec.yaml` y `pubspec.lock` no cambian; tampoco `lib/main.dart` ni los
congelados.

### 14.6 Para Carlos: el bloque de Git de la corrección 2

```
git add lib/features/vessel/data/repositories/sync_engine.dart
git add test/t143_cierre_una_vez_test.dart
git add docs/T143-RESULTADOS.md
git commit -m "Sprint 4: T-143, correccion 2, un guardado fallido del cierre se reintenta"
git push
```

### 14.7 Horas

Corrección 2: 0.4 h. Total de T-143: 3.9 h.

### 14.8 En tres líneas

- El motor distingue el cierre que conoce del que guardó, y un guardado fallido (`Left` o
  excepción) ya no queda como hecho.
- Se vuelve a intentar con el rechazo siguiente, con el documento y con «Reintentar», con un
  solo guardado entre llamadas concurrentes; el listado y el plan no tenían el problema.
- Seis pruebas permanentes, rojas contra `b336117`; `analyze` cero y la suite 2155 de 2155 en
  una corrida.

### 14.9 Para Yov

> T-143, corrección 2, en la sección 14 de `docs/T143-RESULTADOS.md`. ACC-03: el motor separa el
> cierre conocido (`_closed`) del guardado (`_closedSaved`). Un `Left` o una excepción ya no se
> memorizan: el siguiente rechazo, el documento o «Reintentar» lo vuelven a intentar, con un
> solo guardado entre llamadas concurrentes. El listado y el plan no tenían el problema, porque
> solo anotan su guardado con `Right`. Seis pruebas nuevas en `t143_cierre_una_vez_test.dart`:
> la sonda de Codex, cada camino de reintento, la excepción y el fallo con llamadas concurrentes.
> Las seis son rojas contra `b336117`, y las cuatro de la corrección 1 siguen en verde.
> `analyze` cero y suite 2155 de 2155 en una corrida. Un commit: «Sprint 4: T-143, correccion 2,
> un guardado fallido del cierre se reintenta».
