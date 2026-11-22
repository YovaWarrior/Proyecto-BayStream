# Aceptación GLM · T-147, entrega 2, parte 2a

GLM 5.3 Flash, en Max, en el papel de Capitán Codex (10.137) · 21-nov-2026 ·
carpeta `C:\Proyectos\baystream-qa-r4`, con HEAD separado en la punta de
`t147-piloto4` (`1c2d86d`). La entrega la programó Timonel, la revisó Yov sin
correcciones (10.162) y este documento es su aceptación. La evidencia vive en
`build/t147/glm-e2a/`, fuera de Git. Los dos archivos del caso se leyeron
siempre de la carpeta del corpus y del Escritorio, nunca del repositorio; las
copias del caso que hubo en `%TEMP%` ya están borradas.

## 1. Dictamen

**PASA, sin hallazgos nuevos.**

Todos los puntos del encargo dieron lo esperado: la suite y `analyze`, las
rojas contra la 1.0.2, las cifras del caso A09 (leídas con el lector del
producto y contadas aparte por mi sonda), el corpus entre versiones, las
sondas de lo que el programador no pensó, la pantalla del teléfono (seis casos
que nadie había visto más los tres recorridos de Timonel), la medición de la
hoja y el banco de Windows. Lo que encontré fuera de lo esperado son sumas a
hallazgos ya conocidos (O-147-6, O-147-7 y O-147-8) y un comportamiento de la
edición de equivalencias que es coherente con lo aprobado y que anoto para la
2b (sección 5.3).

## 2. La tabla de los puntos

La evidencia citada en esta tabla vive en `build/t147/glm-e2a/` (rutas
relativas a esa carpeta), fuera de Git.

| Punto del encargo | Resultado | Evidencia |
|---|---|---|
| 0 · Punta, huellas, `pub get`, T-124 | conforme | este documento, §3.1 |
| A.1 · Dos copias limpias con `git archive` | conforme | `%TEMP%\t147-glm2a-{antes,despues}` |
| A.2 · `analyze` en la copia «después» (todo el paquete) | «No issues found!» | `A-analyze-despues.log` |
| A.2 · `analyze` aquí (lib test tool integration_test) | cero | `A-analyze-qa-r4.log` |
| A.3 · Suite en la copia «después», una corrida | `+2357: All tests passed!`, sin `~` ni `-` | `A-suite-despues.log` |
| A.4 · `pubspec.yaml` contra v1.0.2 | solo `version: 1.0.3+12` y `msix_version: 1.0.3.0`; `pubspec.lock` no cambia | este documento, §3.1 |
| B · Las rojas contra v1.0.2 | fallan 20, 11, 10, 11 y 8; pasan 4, 3, 3, 5 y 2 | `B-rojas-*.log` y `B-rojas-expanded-*.log` |
| C.6 · La orden del punto 1 de E2a-11 | todas las cifras del caso coinciden | `C-otra.json` |
| C.7 · La cuenta aparte con sonda propia | 709, 470 `LOC+83`, 0 `LOC+13`; 301 byte por byte; 137 y 271 códigos; 169 y 239 | `C-cuenta-aparte.txt` (sonda: `C-sonda-glm-salida.dart.txt`, `C-cuenta-aparte.py.txt`) |
| D · Los seis casos nuevos en pantalla (360×800) | conforme, captura por captura | `D-recorridos/glm-a3`, `glm-b`, `glm-c6`, `glm-d`, `glm-e2`, `glm-f3` |
| D · El recorrido `recorrido2a` de Timonel ×3 | conforme en los tres (29 capturas cada uno) | `D-recorridos/glm-r-360-dia`, `glm-r-360-noche`, `glm-r-1366-dia` |
| E · El corpus, antes y después, `--comparar` | «igual» en los trece `.edi` y en `LISTADO_A08.xlsx`; «DISTINTO» solo en `LISTADO_A09.xlsx` | `E-corpus/` |
| F · La medición de la hoja (3+3 alternadas, CPU÷4) | las tres «después» bajo 0.5 s; sin retroceso más allá del ruido propio | `F-medicion/` |
| G.13 · La expresión de la cancelación | las 12 reconocidas, las 5 no, `AB123456` marchamo, CONTENIDO cancela | `G-sondas-despues.txt` |
| G.14 · Versiones mezcladas | la 1.0.2 abre lo guardado por la punta; cifras de 4.4; la bitácora se deriva sin excepción | `G-sondas-despues.txt` |
| G.15 · La salida con planes sintéticos | los cinco casos, conforme | `G-sondas-despues.txt` |
| G.16 · «También llena» | conforme; una observación de la edición (§5.3) | `G-sondas-despues.txt` |
| H · Windows, banco «después», `recorrido2a` 360×800 día | «fin», 29 capturas, mismo orden de hoja que la Web | `D-recorridos/glm-win-360-dia` |

## 3. Las cifras

### 3.1 Paso 0

- La punta es `1c2d86d`, «Sprint 4: T-147, entrega 2, parte 2a: …», y debajo
  está `adbbefd`, «Sprint 4: T-147, entrega 2: la propuesta».
  `git show --stat HEAD` trae las 29 rutas de E2a-13 y ninguna más.
- `CORPUS_A09.edi`: 123 619 bytes, SHA-256 `450219fe…f07e`.
  `LISTADO_A09.xlsx`: 64 524 bytes, `df40cd6f…aad0`. Coinciden con la tabla
  del encargo. `CORPUS_A07.edi`, `CORPUS_A08.edi` y `LISTADO_A08.xlsx` están
  sueltos en el Escritorio, como decía el encargo.
- `flutter pub get --offline --enforce-lockfile` en esta carpeta: salida 0.
- `build/t124/entradas/t124_entradas.dart`: SHA-256 `d4384834…1162`,
  copiado a las dos copias limpias con la misma huella.
- `pubspec.yaml` entre `99995db` y la punta: solo las dos líneas de la
  versión. `pubspec.lock`: sin diferencia.
- Las dos copias limpias (`git archive`, sin tuberías de PowerShell) quedan en
  `%TEMP%\t147-glm2a-despues` y `%TEMP%\t147-glm2a-antes`, con sus bancos Web
  compilados y el banco Windows de «después» en `%TEMP%\t147-glm2a-win`.

### 3.2 El caso A09, esperado contra lo que dio

| Cifra | Esperada | Dio |
|---|---|---|
| Filas del listado | 448 | 448 |
| Para cargar | 408 (135 llenos, 273 vacíos) | 408 · 135 · 273 |
| Canceladas | 40 (37 llenos, 3 vacíos) | 40 · 37 · 3 |
| Por nota | 24, 7, 7 y 2 | 24 · 7 · 7 · 2 |
| Vacíos cancelados | OR 156, 168 y 182 | 156 · 168 · 182 |
| Notas sin reconocer / filas sin entender | ninguna | 0 · 0 |
| Tipos pendientes | 45HC, 20OT, 40FF, 40HF, 40OT, 40RF | los seis |
| «También llena» propuesto | 20ST→22G0; 20TK→22T1, 22T0, 22T6; 40HC→45G0 | igual |
| Celdas sin dueño (elegidos los seis) | 11, las 11 con sugerencia: L5G0 3, 42R0 3, 22T4 2, 22U0 1, 42G0 1, 45P4 1; 22T4 para 20TK | igual |
| Llenos que cruzan | 135 de 135, ninguno fuera del plan | 135 · 0 |
| Vacíos en grupos | 273 de 273 en 14 grupos, los 14 cuadran | 273 · 14 · 14 |
| Llenos con datos distintos | 0 | 0 |
| Canceladas que el plan carga | 0 | 0 |
| Choques de un código en dos tipos | 0 | 0 |
| Hoja desde 018-10-88 | 247 filas, 64 de su grupo, ninguna cancelada, ninguna que no quepa, empieza 250, 251, 252 | igual |
| Hoja desde una celda de 20 pies | 24 filas, todas de 20 | 24, largos solo `2` |
| Cargas registradas | 408 (137 por su número, 271 vacíos asignados), sin conflictos, cero pendientes | igual |
| Salida | se puede guardar; 709 contenedores; 470 `LOC+83` y 0 `LOC+13`; 169 con destino final (109 llenos, 60 vacíos); 408 de 408 con el código ISO del plan, 16 vacíos en celda de otro código de su tipo; releída: 709, ninguna celda reservada, ningún aviso | igual |
| Dispositivo | 15 tipos, una línea, ningún puerto | 15 · 1 · 0 |

El único «dato por confirmar» de la salida es la temperatura de un
refrigerado que el plan y el listado traen distinta: es la regla de T-132, la
herramienta eligió el plan para poder contar, y lo dice su informe (E2a-4).

### 3.3 La cuenta aparte (C.7), con sonda propia y el Excel leído por mí

Sobre el texto de la salida con las 408 cargas, sobre `CORPUS_A09.edi` con
los bloques cortados en `LOC+147` y sobre el Excel leído con zipfile/XML, sin
el lector del producto:

- 709 bloques en el plan y 709 en la salida; 470 `LOC+83`; **0 `LOC+13`**.
- Los **301** contenedores que siguen a bordo traen su grupo del plan
  **entero, byte por byte** (301 de 301 iguales).
- En los **408** que cargan en GTSTC, el código del `EQD` es el que el plan
  trae para esa pieza: el de su grupo en los **137** con número (137 de 137),
  el de su celda reservada en los **271** asignados (271 de 271, todos en
  celda reservada del plan).
- **169** llevan `LOC+83` con el POD del Excel, justo detrás de `LOC+11`
  (ninguno con otro código ni en otro lugar), y los otros **239** no llevan
  ninguno.

Dos trampas de mi propio instrumento, encontradas y corregidas antes de dar
nada por hallazgo (la regla de 10.152): un truncado de la posición a 6
dígitos que enfrentaba celdas de distinto nivel (las posiciones del caso son
de 7), y una fila de sección del Excel («TRANSBORDOS») que no trae OR.
El archivo con las matrículas que escribió la sonda se borró de `%TEMP%`.

### 3.4 Las rojas

| Archivo | Contra v1.0.2 | Con el cambio |
|---|---|---|
| `t147e2_canceladas_test.dart` | 20 fallan, 4 pasan | 24 de 24 |
| `t147e2_tambien_llena_test.dart` | 11 fallan, 3 pasan | 14 de 14 |
| `t147e2_equivalencias_test.dart` | 10 fallan, 3 pasan | 13 de 13 |
| `t147e2_salida_test.dart` | 11 fallan, 5 pasan | 16 de 16 |
| `t147e2_hoja_test.dart` | 8 fallan, 2 pasan | 10 de 10 |

Las 60 caen por lo que la 1.0.2 no tiene: no reconoce las tres notas ni
cuenta aparte las canceladas; no ofrece cargarlas con motivo; no tiene
«también llena» ni la tarjeta de las celdas sin dueño ni el choque de dos
tipos; lo guardado en el dispositivo manda y los puertos se leen; no escribe
`LOC+83` ni el código ISO del plan; y la hoja ofrece lo que no cabe y no va
por OR.

Las **17** que pasan en los dos lados fijan lo que no debía cambiar:

- canceladas (4): un listado sin notas dice lo de siempre; «Deshacer carga»
  quita el conflicto; una fila sin nota no pide motivo; la búsqueda por OR o
  por el final del número la encuentra;
- «también llena» (3): el empate se sigue preguntando; un puerto o una línea
  con respaldo repartido también; dos tipos con el mismo código principal son
  un solo grupo y no chocan;
- equivalencias (3): sin nada guardado no hay tarjeta y todo como hasta la
  1.0.2; lo guardado que el plan no contradice se sigue usando;
- salida (5): sin nada declarado sale el principal de su tipo; la fila de la
  1.0.1 con el POD como puerto lleva `LOC+11` con el POD y `LOC+13` con el
  POT sin `LOC+83`; POT igual al POD no escribe; el plan con el mismo destino
  no se toca ni avisa; lo que sigue a bordo conserva su grupo entero;
- hoja (2): un tipo de largo desconocido se sigue ofreciendo, y el caso A08
  se cruza por identidad igual que siempre.

### 3.5 La medición

Con el instrumento de la entrega 1 (escenario `medir`, caso A09, celda
018-10-88), a 360×800, Chrome 157.0.8103.79, CPU frenada ÷ 4 (`--cpu 4`),
preparar con perfil nuevo y las seis corridas alternadas con ese mismo
perfil, en este orden: antes, después, antes, después, antes, después.
Milisegundos desde soltar el dedo a la hoja dibujada (`dibujada_ms` del paso
«toque»):

| Corrida | Tocar la celda | El teclado | Una tecla |
|---|---|---|---|
| antes-1 | 205.6 | 785.6 | 116.7 |
| después-1 | 210.4 | 770.0 | 115.7 |
| antes-2 | 202.6 | 794.0 | 114.1 |
| después-2 | 200.8 | 898.9 | 120.5 |
| antes-3 | 187.1 | 794.9 | 118.4 |
| después-3 | 196.7 | 916.1 | 123.0 |

- **Criterio 1:** las tres de «después» quedan muy por debajo de medio
  segundo (196.7 a 210.4 ms).
- **Criterio 2:** «después» no es más lenta que «antes» más allá del ruido
  propio: mis «antes» varían 18.5 ms entre sí (187.1 a 205.6) y la mediana de
  «después» (200.8) es menor que la de «antes» (202.6); el máximo de
  «después» (210.4) supera al de «antes» en 4.8 ms, dentro de esa variación.
  Mis corridas corrieron más lentas que las de Timonel (151 a 159 ms), como
  esperaba en una máquina distinta y en otro momento; lo que importa es la
  diferencia, y es la misma: 2 a 4 ms, inseparable del ruido.
- La hoja ofreció las filas del listado guardado por la 1.0.2 en el preparar;
  las dos series midieron la misma hoja.
- La máquina: la computadora de Carlos (Windows 10.0.26300 x64). Durante la
  serie corrieron solo mi consola (esta sesión de ZCode) y el Chrome que el
  lanzador abre y cierra; ningún otro comando de Flutter o de Dart, por el
  semáforo. No puedo ver lo que haya de proceso de fondo del sistema.

### 3.6 El corpus, antes y después

`tool/t147_corpus.dart` en las dos copias, con la carpeta del corpus y la del
Escritorio, `LISTADO_A09.xlsx` con `CORPUS_A09.edi` y `LISTADO_A08.xlsx` con
`CORPUS_A08.edi`, ambas en GTSTC, y después `--comparar`:

- «**igual**» en los trece `.edi` (A01, A02, A03, A03v, A04, A05, A06, A07,
  A08, A08v, A09, `PRUEBA_NIVEL_78` y `PRUEBA_NIVEL_80`) y en
  `LISTADO_A08.xlsx`.
- «**DISTINTO**» solo en `LISTADO_A09.xlsx`: pendientes de 9 a 6, y el cruce
  pasa de 37 llenos fuera del plan a 0. Es lo que se buscaba; el lector de
  BAPLIE no se tocó.

### 3.7 Las sondas de G, con mis números

**13 · La expresión.** Reconoce las doce que pedía el encargo (las once de
MARCHAMO, incluida «YA  EMBARCADA» con dos espacios y «CANCEL 123», más
«Carga general cancelled» en CONTENIDO, que cancela la fila). No reconoce
«CANCELACION», «CANCELAR», «ENROLEADO», «EMBARCADO» ni «REEMPLAZO», que
quedan como notas sin reconocer con su OR. «AB123456» no cancela nada ni se
avisa: es un marchamo.

**14 · Versiones mezcladas.**
- El listado del caso guardado por la punta (con sus 11 códigos declarados en
  `typeFamilies`), abierto con el código de la 1.0.2 y cruzado con el plan:
  448 filas (172 llenos, 276 vacíos), 135 de 172 llenos cruzan, 37 fuera del
  plan, 276 de 276 vacíos en 23 grupos, cuadran 7 y 17 con datos distintos.
  Es exactamente lo que da hoy la 1.0.2.
- La bitácora que registró la punta (un vacío cancelado asignado con motivo a
  una celda de su grupo, y un vacío 40HC en una celda 45G0), derivada por la
  1.0.2: **sin excepción**, los dos quedan cargados en sus celdas
  (030-02-02 y 030-04-06). Los conflictos que enseña cada versión:
  - la 1.0.2: el 40HC en la celda 45G0 sale como **otro grupo** (`otherGroup`
    en `R:0300406`); la fila cancelada **no enseña ningún conflicto** (la
    1.0.2 no la conoce);
  - la punta: la fila cancelada sale como **cancelado en el listado**
    (`cancelledInList` en `R:0300202`) y el 40HC en la celda 45G0 **no
    enseña ninguno** (45G0 lo llena su tipo). Entre las dos versiones, el
    mismo registro mira distinto y ninguno se pierde.

**15 · La salida, con planes sintéticos.** Los cinco casos del encargo:
- el plan ya trae el mismo `LOC+83` que el listado: el grupo queda igual, sin
  aviso;
- el plan trae otro (`ITGOA` contra `ITLIV`): manda el listado, en el mismo
  lugar (detrás de `LOC+11`), con el aviso «OR 4 · ‹matrícula›: destino final
  ITLIV, del listado; el plan decía ITGOA.»;
- un POD sin forma de UN/LOCODE («SAJ»): no se escribe y se avisa con el
  texto «OR 5 · ‹matrícula›: el POD «SAJ» del listado no tiene forma de
  UN/LOCODE; el destino final no se escribió.»;
- una fila guardada por la 1.0.1, con el POD como puerto: `LOC+11` con el
  POD, `LOC+13` con el POT y sin `LOC+83`; con «destino final → trasbordo»
  elegida, `LOC+11` con el trasbordo, sin `LOC+13` y `LOC+83` con el POD
  justo detrás;
- el código ISO: sin nada declarado, un vacío en celda de otro grupo sale con
  el principal de su tipo (45G1) y el cruce lo cuenta como dato distinto,
  como en la 1.0.2; y un permute con motivo (cada lleno en la celda del otro)
  sale con **el código de su grupo del plan** en los dos, no con el de la
  celda de destino.

**16 · «También llena».**
- Cambiar el principal con el lápiz después de declarar (§5.3).
- Quitar en la segunda importación un «también» que salió de una sugerencia
  (L5G0 de 45HC): la tercera importación ya no lo trae y L5G0 vuelve a la
  tarjeta con sus 3 celdas. La clave `typeFamilies` de la segunda guardada ya
  no lo trae.
- Dos tipos del listado con el mismo principal y uno con un «también»: cero
  choques, y la hoja desde una celda del código declarado ofrece las filas de
  los dos tipos como de su grupo (2 de 2). **Confirma la lectura de E2a-3.2.**

## 4. Lo que vi en pantalla

Todo a 360×800 salvo donde digo otra cosa, con el banco Web de la punta
compilado con mi escenario `glm2a` (mis seis casos) y con el `recorrido2a` de
Timonel. Cada corrida con su perfil de Chrome nuevo en `%TEMP%` y su carpeta;
`red.json` no registró ninguna petición fuera de `127.0.0.1` en ninguna
(sirvió 116 por recorrido, 32 a 61 en los cortos), `consola.log` no trae
ningún error de Flutter y todas terminan en «fin». Los textos que cito los
tomé de las capturas, que abrí una por una.

### 4.1 Los seis casos que nadie había visto

**a · Un vacío cancelado, cargado con motivo** (`glm-a3`, 11 capturas).
La hoja desde una celda de su grupo (030-02-02, de 45G1 · COTRB · LNH)
ofrece 247 filas, 31 de su grupo, **ninguna cancelada**. Al buscar «156» sale
«OR 156 · ‹matrícula› · 45G1 · COTRB · LNH · Tara 3700 kg · **Cancelado en el
listado: pide motivo**». Al elegirlo, «Asignar vacío» dice en color de aviso
«**Pide motivo: el listado lo marca cancelado («CANCELADO»). Si sube a
bordo, escribe el motivo: la oficina lo verá como conflicto.**», pide
«Motivo (obligatorio)» y «Confirmar carga» está apagado (lo comprobé en el
widget, no solo a la vista); con el motivo escrito se enciende. Registrado:
«Carga registrada · OR 156», 407 pendientes. La celda queda en «**Revisar**»,
su detalle muestra la línea «OR 156 · ‹matrícula› se cargó y el listado lo
marca cancelado («CANCELADO»). Si el registro fue un error, deshazlo desde el
detalle de la celda.» y el botón «Deshacer carga». En el avance,
«**Conflictos · 1**» con esa línea y su motivo. La salida lo lleva a bordo:
«302 contenedores a bordo…», y en «Avisos de la salida», «OR 156 ·
‹matrícula›: está a bordo y el listado lo marca cancelado («CANCELADO»).»
«Filas del listado que no cargaron (447)», 39 de ellas canceladas y las
cuatro notas. «Deshacer carga» pide su motivo («Deshacer · ‹matrícula»» /
«Deshacer con este motivo»): quedan **0 conflictos** y la celda vuelve a
`planned`; la hoja vuelve a ofrecer 247 filas y **la fila vuelve a no
ofrecerse** (empieza en el OR 157). En mi primera corrida cargué el OR 156
desde una celda de otro grupo (L5G1): la hoja mostró las dos razones («Otro
grupo: pide motivo» y «Cancelado en el listado: pide motivo») y el avance
contó «Conflictos · 2»; es correcto, y es el escenario del propio recorrido
de Timonel, que muestra las dos líneas.

**b · Un lleno que el plan trae y el listado cancela, antes de cargarlo**
(`glm-b`, 6 capturas). En una operación nueva, importando como primer listado
la revisión que cancela el OR 1: el cruce dice «**1 cancelada en el listado
que el plan todavía carga**», con la tarjeta «Canceladas en el listado que el
plan todavía carga (1)» y el texto «Cancela su embarque desde el detalle de
la celda o pide el plan corregido. Si alguna sube, el muelle la registra con
motivo.» En Carga, la celda 015-03-02 lleva la marca «**Revisar**» sin
haberse cargado (el registro anota estado `planned`). Al tocarla,
«Confirmar carga» con «POT COCTG · POD SAJED», «Posición planificada:
015-03-02» y el mismo «Pide motivo: el listado lo marca cancelado
(«CANCELADO»)…», con «Confirmar carga» apagado hasta el motivo. Con el
motivo queda cargado y el avance lo lista en «Conflictos · 1».

**c · El «Destino final» en el detalle** (`glm-c6`, 4 capturas). Con la
salida que mi sonda armó con solo el lleno OR 1 y el vacío OR 148 cargados
(303 contenedores), abierta en el banco como un plan: el detalle del lleno
(tocado su celda 015-03-02 en el plano, bahía 15) dice «Destino final» con
**SAJED**, y el del vacío (001-02-84, bahía 01) «Destino final» con
**BRPNG**. La primera captura de cada uno muestra la hoja del detalle desde
arriba (celda, tipo, estado, puertos) y la segunda, con la hoja bajada, el
valor del destino final junto a «Naviera».

**d · Un código que dos tipos declaran** (`glm-d`, 3 capturas). En la
importación del caso, con el lápiz puse 45HC → 45G0 (40HC ya llena 45G0):
arriba de las equivalencias sale el aviso en color de error «**45G0 lo
declaran dos tipos: 40HC (45G1) y 45HC (45G0). Un código del plan lo llena un
solo tipo: corrige uno con el lápiz o quita el «también llena» que sobra.**»,
al pie «**No se puede importar: 45G0 lo declaran dos tipos: 40HC (45G1) y
45HC (45G0). …**» y «Confirmar e importar» queda apagado (comprobado en el
widget). Al corregir con el lápiz (45HC → L5G1), el aviso desaparece, cero
conflictos y «Confirmar e importar» se enciende.

**e · Una nota que no se reconoce** (`glm-e2`, 2 capturas). Con la copia del
listado que trae «TRANSBORDOS» (un título de sección que el libro ya usa) en
el MARCHAMO del OR 12, el resumen dice en el color de error: «**1 fila trae
en MARCHAMO una nota que no se reconoce: «TRANSBORDOS» (OR 12). Se carga. Si
no se carga en este buque, pide a la agencia que diga CANCELADO y vuelve a
importar el listado.**» El registro anota que la fila no está cancelada y
**se sigue ofreciendo** (sigue entre las filas que se cargan: «para cargar»
sigue en 408, porque el OR 12 ya contaba como carga).

**f · Lo guardado en el dispositivo** (`glm-f3`, 5 capturas). Después de
importar el caso: la tarjeta «**Equivalencias guardadas en este dispositivo
(16)**» al final de la página, recogida; expandida, una fila por equivalencia
con su «Quitar». «Quitar» en una la deja en **15**. Con un puerto sembrado
(COTRB → JMKIN, puesto en el almacén del banco), el subtítulo pasa a «**Y 1
de puerto, que ya no se usa.**» y dentro sale «De puerto, de versiones
anteriores (1): ya no se usa.» con su «**Quitarla**». «Quitar todas» vacía la
tarjeta: desaparece de la página y el almacén queda en cero equivalencias de
tipo (lo comprobé leyendo el almacén del banco).

### 4.2 El recorrido `recorrido2a` de Timonel, tres corridas

`glm-r-360-dia` (360×800, día), `glm-r-360-noche` (360×800, noche) y
`glm-r-1366-dia` (1366×690, día): 29 capturas cada uno, «fin», sin errores de
Flutter y sin peticiones fuera de `127.0.0.1`. Leí las capturas de la de día
a 360 y los registros de las tres; **los siete puntos se cumplen igual en las
tres**:

1. **El listado**: «448 filas en 5 agencias · 408 para cargar: 135 llenos y
   273 vacíos»; «40 canceladas en el listado, que no se cargan: 37 llenos y 3
   vacíos»; «ROLEADO - CANCEL 24 · YA EMBARCADO -CANCEL 7 · CANCELADO 7 ·
   REEMPLAZO - CANCEL 2»; el desplegable «Canceladas en el listado (40)».
2. **Las equivalencias**: seis pendientes (45HC, 20OT, 40FF, 40HF, 40OT,
   40RF); 20ST, 20TK y 40HC con «Propuesta: 19 contenedores van a 22G1 y 1 a
   22G0. 20ST llena los dos.», «…5 a 22K2, 3 a 22T1, 2 a 22T0 y 1 a 22T6.
   20TK llena todos.», «…60 a 45G1 y 10 a 45G0. 40HC llena los dos.» y su
   «También llena:» con las fichas.
3. **La tarjeta** «Celdas reservadas que ningún tipo del listado llena (11)»
   con las seis sugerencias («22T4 · 2 celdas. ¿Las llena 20TK (22K2)?» con
   «Sí / Otro tipo… / No: piden motivo»). Aceptadas las seis: «135 de 135
   llenos cruzan con el plan», «273 de 273 vacíos en 14 grupos de reservas»,
   los 14 grupos con su marca y sus códigos entre paréntesis («45G1 · COTRB ·
   LNH: 31 vacíos, 31 celdas (28 de 45G1 y 3 de 45G0)», entre otros),
   «40 canceladas en el listado: el plan no carga ninguna» y **ningún**
   «Llenos con datos distintos».
4. **La hoja** desde 018-10-88: 247 filas, 64 de su grupo, empieza en los OR
   250, 251 y 252, ninguna cancelada y ningún largo que no quepa; al buscar
   «156», el OR 156 con «Otro grupo: pide motivo» y «Cancelado en el listado:
   pide motivo»; desde una celda de 20 pies (001-02-86, de 22T4 · COCTG ·
   LNH), 24 filas y solo largos de 20.
5. **El vacío 40HC en la celda 030-04-06** (45G0): «Asignar vacío» dice
   «Reservas libres del mismo tipo, puerto y línea.» y «**Revisado: tipo,
   celda y grupo coinciden con el plan.**», sin pedir motivo; queda
   «Cargado», sin conflicto (el registro: `moved`, `en_conflicto: false`,
   0 conflictos).
6. **La segunda importación**: cero pendientes; las que la oficina eligió
   dicen «**De la revisión anterior de este listado.**» (las seis con origen
   `previous` en el registro); con la 40ST → 45G1 sembrada, «**En este
   dispositivo estaba guardada 40ST → 45G1, y el plan dice 42G1 (1
   contenedor): no se usó.**» Y la tarjeta «Equivalencias guardadas en este
   dispositivo (16)» sale aparte, con «Y 1 de puerto, que ya no se usa.»
   después de la siembra.
7. **La revisión** que cancela el OR 1, ya cargado: «1 contenedor ya cargado
   queda cancelado en el listado nuevo», «Ya cargados que el listado nuevo
   cancela (1)»; la celda en «Revisar» con su conflicto (`cancelledInList` y
   `en_conflicto: true`); el avance con «Listado: 41 filas canceladas, que no
   se cargan (38 llenos y 3 vacíos).» y «**Conflictos · 1**» con su línea; y
   la salida con «2 cargas llevan su destino final (LOC+83), tomado del POD
   del listado.», «Filas del listado que no cargaron (445)» con 40
   «cancelado en el listado» y las cuatro notas, y «OR 1 · ‹matrícula›: está
   a bordo y el listado lo marca cancelado («CANCELADO»).»

Ningún texto que no cabe ni pisado, fuera de los conocidos de la sección 5.

### 4.3 Windows

El banco de Windows «después» (Release compilada con `-t tool/t147_main.dart`
en la copia de `%TEMP%`, copiada a `%TEMP%\t147-glm2a-win`, almacén propio en
`%TEMP%` con el namespace r4 —ya borrado—): el recorrido `recorrido2a` a
360×800 de día terminó en «fin», con sus 29 capturas, sin errores de Flutter.
Las pantallas dicen lo mismo que en la Web, y el orden de la hoja es el
mismo: desde 018-10-88, 247 filas que empiezan 250, 251, 252; desde la celda
de 20 pies, 24 que empiezan 148. No es una Release de publicación: es un
banco.

## 5. Hallazgos, observaciones y lo que no se pudo

### 5.1 Hallazgos nuevos

**Ninguno.**

### 5.2 Sumas a hallazgos conocidos

- **O-147-6** (recortes a 360 dp), datos que sumo: además de los textos de
  las celdas del plano («42G1 COTRB LNH», «L5G1 COTRB LNH», que la captura
  registra recortados), también se recortan las líneas de resumen del modo
  («Carga: 408 pendientes, 135 llenos, 273 vacíos» y «Bahía 18: grupo 18 (17,
  18 y 19), cub. 44, bod. 62») y el encabezado del plano bajo el detalle
  («Bahía 15, carga del grupo 14 (13, 14 y 15): cu…»). Son líneas que ya
  estaban en la 1.0.2: no nacen con la 2a. El roce «…puerto y línea.» con el
  rótulo «Celda reservada» se ve en «Asignar vacío» (capturas `glm-a-03` y
  `glm-r-12`), y el rótulo «Motivo (obligatorio)» toca el borde del campo
  «Marchamo» (`glm-a-04`), como estaba anotado.
- **O-147-7**, confirmada en pantalla: la tarjeta de las celdas sin dueño con
  las 11 y sus seis sugerencias pasa de una pantalla a 360 dp (`glm-r-03`
  muestra hasta 45P4; L5G0 queda bajo el pliegue).
- **O-147-8**, las tres vistas presentes: el resumen dice «202 filas traen
  POT y POD distintos» contando las canceladas (`glm-r-01`); el avance dice
  «41 filas canceladas, que no se cargan» con una a bordo (`glm-r-26`); la
  salida dice «1 conflictos vigentes» (`glm-a-08`).

### 5.3 Una observación para la 2b (no es defecto)

Al **cambiar el principal con el lápiz después de declarar**, lo declarado en
«también llena» queda vacío: si la oficina declara 45G0 como «también» de
40HC (principal 45G1) y después cambia el principal a 45G0, el «también» no
se muda — queda vacío, y las celdas del principal anterior (45G1) vuelven a
la tarjeta de las celdas sin dueño, con su sugerencia. Es coherente: el
principal cubre su propio código, y la declaración del viejo principal sobró;
con un toque en «Sí» se recupera. Lo anoto porque la oficina puede esperar
que el lápiz mude solo el que sobra, y porque la tarjeta vuelve a aparecer
sin ninguna advertencia nueva.

### 5.4 Lo que no se pudo, y las condiciones

- **No se probó en un iPhone ni en el Honor**, tal como dice el encargo; el
  Honor no se tocó (ningún `flutter run`, `flutter install` ni `adb install`
  contra él).
- La medición fue solo de la hoja en la Web, como pide el encargo F; no medí
  en Windows ni en un teléfono, y el teclado es simulado.
- De los cuatro tamaños y temas de Timonel en Windows, yo corrí solo 360×800
  de día (él había corrido 360 de noche y 1366 de día).
- La máquina estuvo quieta durante las ventanas de medición salvo mi consola
  y el Chrome del banco; no puedo ver procesos de fondo del sistema.

### 5.5 Las horas del reloj (21-nov, hora local UTC−6)

Los tramos donde quedó archivo se pueden seguir por la hora de sus archivos y
por `pasos.jsonl` (que anota en UTC); donde no quedó archivo, el tramo es
aproximado.

| Tramo | Horas | Qué quedó |
|---|---|---|
| Lecturas y paso 0 | 00:05 a 00:20 | punta, huellas, `pub get`, T-124 |
| A · copias, `analyze` ×2, suite, `pubspec` | 00:20 a 00:26 | `A-*.log` |
| B · las rojas, dos pasadas | 00:26 a 00:32 | `B-rojas-*.log` |
| C · el caso con el lector y la cuenta aparte | 00:32 a 00:40 | `C-otra.json`, `C-cuenta-aparte.txt` |
| E · el corpus en las dos copias | 00:40 a 00:44 | `E-corpus/` |
| G · las sondas 13 a 16 | 00:44 a 01:07 | `G-sondas-despues.txt` |
| D · banco Web y las 9 corridas | 01:07 a 01:31 | `D-recorridos/` |
| Leer capturas y registros | 01:31 a 01:52 | (revisión, sin archivo) |
| F · la medición | 01:52 a 01:59 | `F-medicion/` |
| H · banco Windows y su recorrido | 02:00 a 02:07 | `D-recorridos/glm-win-360-dia` |
| Limpieza de `%TEMP%` y este informe | 02:07 en adelante | — |

## 6. Cómo trabajé

Modelo GLM 5.3 Flash, con el esfuerzo en **Max** (10.137). La consola corre
desde la aplicación de escritorio **ZCode** (ZCode.exe), con el proyecto
`baystream-qa-r4` abierto; no corrí dentro de ningún editor. Un comando de
Flutter o de Dart a la vez, con su línea `SEMÁFORO:` al empezar y al cerrar
cada ventana; mientras medí, la máquina quieta.

## 7. Git (lo ejecuta Carlos)

```powershell
cd C:\Proyectos\baystream-qa-r4
git add -- docs/t147/entrega2a/aceptacion-glm.md
git commit -m "Sprint 4: aceptacion de la parte 2a de la entrega 2 de T-147"
git push origin HEAD:t147-piloto4
```

Solo el informe entra a Git: la evidencia vive en `build/t147/glm-e2a/`
(ignorada), y de `%TEMP%` quedan las dos copias limpias
(`t147-glm2a-antes` con v1.0.2 y `t147-glm2a-despues` con la punta, cada una
con su banco Web compilado) y el banco Windows en `t147-glm2a-win`, sin
almacén. Todas las copias del caso, los perfiles de Chrome y los archivos con
matrículas de `%TEMP%` ya están borrados, y no quedó ningún proceso del banco
abierto.

## 8. En tres líneas

1. La parte 2a de la entrega 2 de T-147 **pasa**: la suite da 2357 de 2357 y
   `analyze` cero aquí y en copia limpia; las rojas caen 60 y pasan 17 contra
   la 1.0.2; las cifras del caso A09 coinciden todas, leídas con el lector
   del producto y contadas aparte con mi sonda sobre el Excel leído por mí.
2. En pantalla, los seis casos que nadie había visto y los tres recorridos de
   Timonel dicen lo que dice el informe, captura por captura, en la Web a
   360 y a 1366, de día y de noche, y en Windows; la hoja no quedó más lenta
   (187–206 ms antes contra 197–210 ms después, con la CPU frenada y
   alternando).
3. Sin hallazgos nuevos: solo sumas a O-147-6, O-147-7 y O-147-8, y una
   observación para la 2b sobre el lápiz de las equivalencias (el «también»
   declarado no se muda cuando cambia el principal).

### Mensaje para Yov

> Yov: acepté la parte 2a de la entrega 2 de T-147 — **PASA, sin hallazgos
> nuevos**. Todo el guion de E2a-11 dio lo esperado: suite 2357 y `analyze`
> cero aquí y en copia limpia; rojas 60/17 contra la 1.0.2 (las 17 nombradas,
> fijan lo que no debía cambiar); las cifras del caso con el lector y aparte
> con mi sonda (709 bloques, 470 `LOC+83`, 0 `LOC+13`, los 301 de paso byte
> por byte, 137 y 271 con el código del plan, 169 con `LOC+83` detrás de
> `LOC+11` y 239 sin él); corpus iguales salvo el listado del caso; los seis
> casos nuevos en pantalla y tus tres recorridos, más Windows a 360 de día;
> medición alternada con CPU÷4: 187–206 ms antes y 197–210 ms después. Tus
> dos lecturas quedan confirmadas con sondas: dos tipos con el mismo
> principal son un grupo (0 choques, y la hoja los trata como su grupo), y
> «Guardada en este dispositivo» sale en otra operación. De conocimiento:
> sumé datos a O-147-6 (las líneas de resumen también se recortan a 360 dp),
> O-147-7 y O-147-8. Una observación para la 2b: el lápiz que cambia el
> principal deja «también llena» vacío y las celdas del principal viejo
> vuelven a la tarjeta con su sugerencia; es coherente, pero tal vez quieras
> que mude el que sobra solo. El informe está en
> `docs/t147/entrega2a/aceptacion-glm.md` y la evidencia en
> `build/t147/glm-e2a/`.
