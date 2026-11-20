# T-147 · Los defectos del piloto 4, entrega 1 — resultados

Timonel · 19-nov-2026 · carpeta `C:\Proyectos\baystream-t147`, rama `t147-piloto4`, desde `v1.0.1` (`37be8a5`). Es la candidata **1.0.2+11** (MSIX `1.0.2.0`). No compilé ninguna Release de publicación, no publiqué y no ejecuté ninguna escritura de Git.

El caso real (A09) se leyó desde la carpeta del corpus, fuera del repositorio. En este informe y en el repositorio van solo posiciones, códigos y conteos; las pruebas usan datos sintéticos.

## 0. En corto

- **La hoja «Vacíos del listado» ya no se traba.** Tocar una celda reservada pasaba de 1.3 s (5.6 a 5.7 s con la CPU frenada 4 veces, lo que se vio en el iPhone) a 35 ms (0.16 a 0.20 s frenada). Ofrece las mismas filas, en el mismo orden.
- **La causa de la 10.151 se confirma con un perfil de CPU, con una precisión:** rehacer la ocupación es el 71 % del tiempo, no todo; el otro 29 % solo se va si la hoja decide una vez por celda. Hacían falta las dos reglas de R1.
- **El plan con «NO» se lee como vino:** 438 contenedores y 271 celdas reservadas, con un solo aviso.
- **El listado del caso entra sin rodeos de puerto:** ninguna fila sin entender y ningún puerto pendiente; quedan los nueve tipos, como dice 5.1 del caso.
- **Las cifras de 5.1 del caso coinciden todas** con lo que da el lector del producto.
- **Suite 2280 de 2280** (2227 más 53 nuevas), sin omitidas, y `analyze` en cero, aquí y en una copia limpia.
- **Una prueba existente cambió a propósito** (T-132, el `LOC+13` del BAPLIE de salida): es consecuencia de R4 y la explico en 3.4. **Pido que Yov la mire.**
- **Dos frases del encargo no coinciden con el código,** y lo dejo dicho en vez de adivinar: una reserva sin asignar no se escribe en el BAPLIE de salida de ninguna forma (3.2), y `DESIGN.md` no lo edité porque `sprint-4` ya lo cambió (9.2).

## 1. Paso 0

| Comprobación | Resultado |
|---|---|
| Punta de la rama (`git log`, `git diff --stat`) | `37be8a5`, sin cambios en el árbol |
| `CORPUS_A09.edi` | 123 619 bytes, `450219fe…f07e`: la huella de la tabla del caso |
| `LISTADO_A09.xlsx` | 64 524 bytes, `df40cd6f…aad0`: la huella de la tabla del caso |
| Entrada de T-124 (`build\t124\entradas\t124_entradas.dart`) | copiada de `baystream-rediseno`, huella `d4384834…`; fuera de Git |
| `flutter pub get` (18:35) | pasa; `pubspec.lock` no cambia |
| `flutter analyze`, todo el paquete (18:36) | cero incidencias |
| Suite completa, una corrida (18:36 a 18:39) | **2227 de 2227**, sin omitidas |

Registros: `build/t147/e1/paso0/`.

**Lo que no estaba donde decía el encargo.** `CORPUS_A07.edi`, `CORPUS_A08.edi` y `LISTADO_A08.xlsx` no están en la carpeta del corpus: están sueltos en el escritorio de Carlos, como dejó la 10.123. Sus huellas son las de `baystream-rediseno\build\t140\resumen.json`. Los leí de ahí. `CLAUDE.md` todavía dice que están en la carpeta.

## 2. Antes de cambiar nada: reproducir y medir

### 2.1 El banco

- `tool/t147_main.dart` es la app del producto con tres cambios: los almacenes con el namespace `r4` (en Windows, en una carpeta de `%TEMP%`; en la Web, el IndexedDB de un perfil nuevo de Chrome), sin nube, y un conductor.
- `tool/t147_conductor.dart` recorre la app por dentro, con toques de verdad sobre sus controles, y deja en `pasos.jsonl` lo que la pantalla dice, las capturas y los tiempos. Es el mismo en la Web y en Windows.
- **El caso no va dentro del binario.** El conductor lo lee de fuera del repositorio: en Windows, de una carpeta de `%TEMP%`; en la Web, de `tool/t147_servidor.py`, que solo escucha en `127.0.0.1`.
- **El Chrome es de Playwright,** con perfil propio en `%TEMP%`. `tool/t147_web.py` corta todo lo que no sea `http://127.0.0.1:5947/` y lo anota en `red.json`: en todas las corridas, cero peticiones cortadas.
- El plan y el listado entran por la entrada del producto (`parseBaplieContent` y `loadBytes`), no por el selector de archivos del sistema.

### 2.2 El caso en la pantalla de la 1.0.1

Con la copia del plan con el número en blanco en las 271 líneas (`tool/t147_copia_en_blanco.py`: 271 reemplazos y el resto idéntico byte a byte), la Web y Windows muestran lo de 4.2 a 4.4 del caso:

| Lo que dice el caso | Lo que dice la pantalla del banco |
|---|---|
| 4.2 · 438 y 271 | «438 contenedores · 271 celdas reservadas» |
| 4.2 · Carga | «Carga: 408 pendientes, 135 llenos, 273 vacíos» |
| 4.2 · Bahía 01 | «Bahía 01 · tapas sin declarar» y «4 contenedores · 3 celdas reservadas · 116.0 t» |
| 4.3 · El listado | «448 filas en 3 agencias · 172 llenos · 276 vacíos» y «3 filas sin entender:» (5, 147 y 154) |
| 4.3 · Pendientes | trece: los nueve tipos y los puertos INMUN, BRPNG, COTRB y CNTAO |
| 4.4 · El cruce, con las trece | «135 de 172 llenos cruzan con el plan», «0 contenedores del plan no están en el listado», «276 de 276 vacíos en 23 grupos de reservas», «Llenos del listado que no están en el plan (37)», «Llenos con datos distintos (20)» y «94 llenos con VGM distinto del plan: el plan suma 4.6 t menos…» |

Los 23 grupos salen con las cuentas de la tabla de 4.4. Con el plan como vino (4.1), el lector de la 1.0.1 da 709 contenedores, ninguna celda reservada y ningún aviso.

Capturas: `build/t147/e1/capturas/antes/` (24). Pasos: `build/t147/e1/antes/web-preparar/` y `windows-preparar/`.

### 2.3 La causa, con un perfil

La causa de la 10.151 estaba leída. La confirmé de dos formas.

**En la máquina virtual de Dart** (`tool/t147_caso.dart --medir`, con la expresión de `_LoadingPickerState.build` de `37be8a5`): armar la hoja desde una celda tarda 1.30 a 1.31 s, y esa expresión lee la ocupación **74 254 veces**, a 15 µs por lectura: 1.10 s, el 85 %.

**En Chrome, con el perfil de CPU** (`tool/t147_web.py --perfil-cpu`, sobre una compilación `--profile -O 1`, que conserva los nombres de las funciones). En esa corrida la hoja se arma tres veces (el toque, el teclado y una tecla):

| Función | Tiempo total | Parte de `candidateSlots` |
|---|---:|---:|
| La lista de filas de la hoja | 4 861 ms | — |
| `candidateSlots`, llamada una vez por vacío del listado | 4 846 ms | 100 % |
| `OperationState.occupancy`, que rehace el mapa en cada lectura | 3 431 ms | 71 % |
| `free.contains(slot)`, que compara celdas campo por campo (Equatable) | 989 ms | 20 % |
| Ordenar las celdas, en cada llamada | 148 ms | 3 % |

- **La causa se confirma:** el 99.7 % del armado de la hoja es `candidateSlots` por fila, y dentro manda la ocupación.
- **La precisión:** guardar la ocupación no basta. Con solo eso quedaría un 29 %, unos 0.4 s por armado sin frenar y 1.6 s frenado. En la máquina virtual lo medí: con la ocupación ya guardada, la expresión vieja todavía tarda 91 a 94 ms; la nueva, 0.13 ms.
- Sin `-O 1`, la compilación `--profile` de este Flutter (3.38.9) sale minificada y el perfil no se puede leer.

Perfil y resumen: `build/t147/e1/antes/web-perfil-cpu/` (`cpu.cpuprofile`, `cpu-resumen.json` y `cpu-por-funcion.json`).

## 3. Lo que cambia, punto por punto

Las rojas corrieron en una **copia pura de `37be8a5`** fuera del repositorio (`git archive`), con solo las pruebas nuevas, su soporte y su accesorio copiados encima. Las tres pruebas compilan ahí: fallan por comportamiento. Registros: `build/t147/e1/rojas/`.

| Archivo de pruebas | Contra `37be8a5` | Con el cambio |
|---|---|---|
| `test/t147_hoja_vacios_test.dart` (R1) | 3 fallan, 19 pasan | 22 de 22 |
| `test/t147_lector_test.dart` (R2 y R3) | 12 fallan, 3 pasan | 15 de 15 |
| `test/t147_listado_test.dart` (R4, R5 y R6) | 10 fallan, 6 pasan | 16 de 16 |

Las que pasan en los dos lados son las que fijan lo que no debía cambiar.

### 3.1 R1 · La hoja de los vacíos no se traba

**La causa:** la de 2.3.

**La roja** (3 de 22):
- «la ocupación se calcula una vez por estado»: `identical(state.occupancy, state.occupancy)` da falso;
- la de escala, con 300 vacíos y 300 reservas sintéticos, **no mira el reloj: cuenta lecturas.** Las reservas del plan son de una clase de prueba que cuenta cuántas veces se le lee el tipo, que es por donde pasa cada comparación de grupo y cada igualdad campo por campo. Contra `37be8a5`, abrir la hoja lee **15 123 272 veces**; el tope de la prueba es 24 000 (40 por cada fila y cada reserva);
- lo mismo al abrirse el teclado y al escribir una tecla.

**El cambio:**
- `OperationState.occupancy` pasa de un getter que rehacía el mapa a un `late final`: se calcula una vez por estado, que no cambia después de derivarse.
- `LoadingOperation.admitsEmpty(slot)` decide, una vez, si la celda admite un vacío. `LoadingOperation.rowsFor(slot, consulta)` da las filas de la hoja. `_LoadingPickerState.build` usa `rowsFor` en vez de `candidateSlots` por fila.
- **Por qué ofrece lo mismo:** leí lo que `candidateSlots(row, otherGroups: true)` decide de una celda y no depende de la fila. La celda entra si es una reserva que el plan carga aquí, sigue planificada y está libre o la ocupa un contenedor que baja aquí sin marcar; las de su grupo entran por una rama y las de otro grupo por otra, con la misma condición. La fila solo tiene que ser un vacío por asignar. El `sort` de la hoja no lo toqué.
- `candidateSlots` busca las celdas libres por su clave, no campo por campo, y `slots` lee la ocupación una vez.
- `available` consulta un conjunto de lo ya operado, armado una vez por estado, en vez de recorrer todas las piezas por cada fila.
- `_before(correcting)` guarda el estado de la corrección en curso: «Corregir carga» de un vacío lo derivaba de nuevo por cada vacío del listado.

**Que nada cambió en lo que ofrece** lo fijan 19 pruebas que pasan también en `37be8a5`: la hoja en nueve estados (celda libre, de otro grupo por tipo y por puerto, ocupada por uno que baja aquí, ya asignada, cancelada, con la descarga del ocupante marcada, con el ocupante que se quedó a bordo), comparada fila por fila con la expresión de la 1.0.1; las celdas del diálogo «Asignar vacío» contra una réplica de los dos recorridos viejos, y la corrección de un vacío.

**En pantalla:** la medición de la sección 4, y las filas a la vista, que son las mismas antes y después en cada cliente (OR 250, 251, 252… en la Web; OR 269, 284, 250… en Windows).

**El mismo patrón en el resto de la carga y de la descarga.** Medido con el caso, en la máquina virtual de Dart (`build/t147/e1/caso/antes-en-blanco.json` y `despues-como-vino.json`, mediana de cinco corridas):

| Recorrido | Antes | Después | Qué hice |
|---|---:|---:|---|
| La hoja desde una celda | 1 303 ms | 0.13 ms | corregido |
| Diálogo «Asignar vacío»: las celdas, con otros grupos | 4.5 ms | 0.37 ms | corregido |
| Diálogo «Asignar vacío»: «ocupada, baja aquí» en cada una de las 271 opciones | 8.7 ms | 0.39 ms | se arregla con la ocupación guardada |
| «Corregir carga» de un vacío: los vacíos que ofrece | 58 ms | 0.07 ms | corregido |
| Rearmar la operación por cada movimiento (`LoadingOperation.build`) | 4.4 ms | 4.0 ms | anotado: no se nota |
| Buscar por OR | 1.1 ms | 1.1 ms | anotado |
| La revisión de una carga (`LoadValidator`, que rehace el conjunto de bahías) | 0.2 a 0.4 ms | 0.2 a 0.4 ms | anotado |
| La huella del viaje en cada `ref.watch(loadingOperationProvider(voyage))` | 1.7 ms por lectura | 1.7 ms | **anotado: O-147-1** |

En la descarga no encontré el patrón: `DischargeProgress` y sus controles no cruzan filas con celdas.

### 3.2 R2 · «NO» es «sin número»

**La causa:** `finishGroup` (`baplie_parser_service.dart`) solo arma una celda reservada si el número del `EQD` viene en blanco. Con «NO» arma 271 contenedores llamados «NO».

**La roja** (12 de 15, con R3): un plan sintético con «NO» no se lee igual que el mismo plan con el número en blanco; no hay aviso; la tarjeta del viaje no lo dice.

**El cambio:**
- `_placeholderNumbers` recorre los `EQD` antes de leer y marca como «sin número» **«NO», siempre,** y cualquier otro texto **sin forma de matrícula** (cuatro letras y siete cifras) **que venga en más de una celda.**
- Un grupo así se lee como si el `EQD` viniera en blanco: celda reservada con su posición, tipo, puertos, línea, peso nominal, frío y peligrosas.
- Un número sin forma de matrícula que viene una sola vez sigue siendo un contenedor (T-144: «EU876»).
- **El aviso es uno solo, con la cuenta:** «Celdas sin matrícula en EQD: «NO» en 271 celdas · se leyeron como celdas reservadas». Al tocarlo explica que el vacío de cada una se asigna al cargar.
- Es un tipo nuevo de aviso (`noNumber`), al final del enum y guardado aparte (`extraReadNotices`): la 1.0.0 no lo lee y la 1.0.1 lo salta sin fallar.

**Ningún otro archivo del corpus cambia su lectura:** sección 6.

**El BAPLIE de salida.** El encargo pide dejar dicho que «escribe una reserva sin asignar con el número en blanco, no con «NO»». **En el código no es así, ni antes ni ahora:** una reserva sin asignar no se escribe; queda entre lo no cargado (`pendingLoads`). Lo que sí es cierto, y lo fija una prueba con un plan que trae «NO»: la salida no contiene `EQD+CN+NO` ni `EQD+CN++`, la reserva asignada sale con el número de su vacío y las dos que quedan sin asignar no salen. El escritor no lo toqué.

**En pantalla:** `…-03-lista-tarjeta-del-viaje.png` y `…-04-aviso-sin-matricula.png`, en las ocho combinaciones.

### 3.3 R3 · Una matrícula repetida se avisa

**El cambio:** si la misma matrícula, con forma de matrícula, viene en más de una celda, el lector lo dice con todas sus celdas: «Matrículas repetidas en EQD: 1 contenedor · revisa esas celdas con quien hizo el plan» y, al tocarlo, «TSTU…: 010-02-82 y 010-04-84». Tipo de aviso `duplicate`, guardado aparte como el anterior. La lectura no cambia: los dos grupos siguen siendo contenedores.

**Lo que la operación hace hoy con ellas** (leído en el código y fijado con una prueba de las piezas; **no lo miré en pantalla,** porque el caso no trae ninguna):
- `OperationPlan.build` guarda cada contenedor con la clave `C:<matrícula>`, así que las dos celdas quedan en **una sola pieza, la de la última celda,** sin avisar;
- en el modo Carga, la proyección del plan sustituye los dos contenedores por esa pieza: la primera celda se queda sin contenedor y no se puede operar;
- el avance cuenta una carga donde el plan trae dos, y el BAPLIE de salida escribe un solo grupo.

**Lo que propongo,** para que decida Carlos:
1. Lo de esta entrega: avisar, para que el plan se corrija antes de operar.
2. Para después: que un plan con matrículas repetidas no se pueda publicar sin corregir. Cambiar la clave para que quepan dos (`C:<matrícula>@<celda>`) toca los movimientos ya escritos y las reglas de Firestore, y un contenedor en dos celdas es siempre un error del plan.

### 3.4 R4 · El cruce va por el POT

**La causa:** `_listCode` (`export_list_cross_checker.dart`) y `ExportListRow.translated` usaban el POD. El lector ya guardaba el POT y nadie lo leía.

**La roja** (10 de 16, con R5 y R6): con un listado sintético con POT y POD, el puerto de la fila es el POD; quedan dos puertos pendientes; el vacío con destino final en otro puerto no cae en el grupo de su POT.

**El cambio:**
- `ExportListRow.pod`, el puerto con que la fila se cruza con el plan, sale del POT si la fila lo trae; si no, del POD, como hasta ahora (`listCrossPort`).
- La fila conserva los dos como vinieron, en `listPot` y `listPod`.
- `propose` arma las equivalencias de puerto sobre ese código.
- **La pantalla:** en el resumen del listado, «202 filas traen POT y POD distintos: el cruce con el plan usa el POT, donde el contenedor baja del buque.»; en cada fila con los dos distintos, «POT COCTG · POD INMUN»; y la misma línea en los diálogos «Confirmar carga» y «Asignar vacío».

**La forma del listado guardado no cambia.** Probado con una fuente guardada por la 1.0.1 (`test/fixtures/t147_listado_guardado_por_la_101.json`, generada con el código del listado de `37be8a5` antes de tocarlo; el generador está en `build/t147/e1/fuente101/generar.dart.txt`):
- la 1.0.2 la abre con los grupos que guardó la 1.0.1, sin recalcular, y la vuelve a guardar **byte por byte igual;**
- lo que guarda la 1.0.2 no trae ninguna clave que la 1.0.1 no lea, con los mismos tipos de dato, y lleva en `pod` el puerto con que la 1.0.1 arma los grupos.

**El caso A08 no cambia:** sección 6.

**Una prueba existente cambia a propósito, y pido que Yov la mire.** `test/t132_departure_fidelity_test.dart`, «T-132 POT igual al POD quita LOC+13; distinto lo escribe»:
- T-132 escribía `LOC+11` con el POD y `LOC+13` con el POT cuando eran distintos. Con el caso A08 nunca se vio, porque ahí son iguales.
- Con R4, el puerto de la fila es el POT: sale en `LOC+11`, que es lo que trae el plan, y `LOC+13` ya no sale. Es lo mismo que salió en el piloto con las equivalencias dictadas a mano.
- No es una decisión libre del escritor: la 1.0.1 tiene que abrir lo que guarda la 1.0.2 y armar los mismos grupos, así que `pod` tiene que ser el puerto del cruce, y el escritor de la 1.0.1 lee ese mismo `pod`.
- El escritor no lo toqué. La regla de T-132 sigue viva para una fila cuyo puerto no es su POT, y la prueba lo conserva con una fila como las que guardó la 1.0.1.
- **Lo que queda sin escribir:** el destino final (el POD del listado) no va a ninguna parte de la salida. Si la línea lo espera en `LOC+83`, es trabajo nuevo.

### 3.5 R5 · La identidad se propone

**El cambio:** en `propose`, un código del listado sin ningún contenedor que lo respalde, igual a un código que el plan carga en la escala, se propone como identidad (`EquivalenceOrigin.samePlanCode`), no como pendiente.
- **La pantalla dice de dónde sale:** «Propuesta: el plan carga COTRB en esta escala con ese mismo código. Ningún contenedor de COTRB está en el listado y en el plan (2 filas).» El lápiz la corrige.
- Con respaldo manda el respaldo, y lo guardado en el dispositivo, sobre todo.
- **No se guarda en el dispositivo** (`tableOf`), igual que las identidades deducidas.
- Lo que ya explica una identidad no se ofrece como sugerencia a las pendientes.

**Con el caso A09 no hace falta:** con el cruce por POT, los cuatro puertos ya salen por identidad con respaldo. Cubre el listado sin POT, o el vacío cuyo tipo ya viene con el código del plan.

### 3.6 R6 · Los separadores

**El cambio** (`export_list_parser_service.dart`): «COD.», como palabra y con su punto, vale como «CODIGO»; «TRANSBORDOS» y «VACIOS» son encabezados de sección, como «AGREGADOS» (también en singular y con tilde). Una fila que solo se parece («VACIOS PENDIENTES DE CONFIRMAR») se sigue informando.

**Con el caso:** «448 filas en 5 agencias», con AGENCIA 1 141, TRANSBORDOS 6, VACIOS 187, AGENCIA 2 53 y AGREGADOS 61, y «Todas las filas se entendieron.»

### 3.7 La versión

`pubspec.yaml` cambia solo sus dos líneas: `version: 1.0.2+11` y `msix_version: 1.0.2.0`. `pubspec.lock` no cambia.

## 4. La medición, antes y después

**El instrumento** es el escenario `medir` del conductor, igual antes y después: `_medir`, `_cronometrar`, `_celdaReservada` y los toques son idénticos carácter por carácter entre la copia que midió «antes» (`build/t147/e1/antes/herramientas/`) y la de la entrega.
- **Un solo reloj** (`Stopwatch`), dentro de la app. El tiempo va de soltar el dedo a que empieza el cuadro siguiente al primero que ya trae la hoja. Queda además el cuadro más largo que informa el motor (`FrameTiming`), que coincide.
- **Tocar la celda:** un toque de verdad sobre la celda reservada 018-10-88, hasta que el título «Vacíos del listado» está en pantalla.
- **El teclado:** con la hoja abierta, el banco cambia de una vez la altura que el teclado le quita a la pantalla (`viewInsets.bottom` a 300). **No es un teclado real de iOS.**
- **Una tecla:** un carácter en el campo de búsqueda de la hoja.
- A 360 × 800. En la Web, con esa ventana real y escala 2; en Windows, con ese tamaño lógico dentro de la ventana del banco.
- La CPU frenada es `Emulation.setCPUThrottlingRate` de Chrome, a 4.
- Tres corridas de cada una; cada corrida es un arranque nuevo de la app. Chrome 157.0.8103.79; Windows 11, release.
- La celda pedida, 018-00-84, no quedaba al alcance del dedo a 360 × 800; el conductor tocó la primera que sí, la misma en las 24 corridas.

**De soltar el dedo a la hoja dibujada, en milisegundos** (las tres corridas):

| | Antes (`37be8a5`) | Después |
|---|---|---|
| **Web** · tocar la celda | 1 364 · 1 365 · 1 331 | 37 · 34 · 35 |
| **Web** · el teclado | 1 474 · 1 498 · 1 427 | 148 · 145 · 145 |
| **Web** · una tecla | 140 · 152 · 149 | 23 · 20 · 21 |
| **Web, CPU ÷ 4** · tocar la celda | 5 577 · 5 734 · 5 735 | 198 · 160 · 171 |
| **Web, CPU ÷ 4** · el teclado | 6 146 · 6 164 · 6 336 | 698 · 730 · 735 |
| **Web, CPU ÷ 4** · una tecla | 601 · 614 · 611 | 98 · 112 · 128 |
| **Windows** · tocar la celda | 1 486 · 1 500 · 1 445 | 21 · 18 · 51 |
| **Windows** · el teclado | 1 492 · 1 525 · 1 490 | 84 · 79 · 101 |
| **Windows** · una tecla | 343 · 162 · 163 | 71 · 49 · 47 |

- **Tocar la celda:** unas 38 veces menos en la Web y unas 50 en Windows.
- **Después de tocar,** la hoja termina de subir a los 375 a 436 ms: es su animación, que antes no se veía porque el cuadro trabado se la comía.
- **Lo que queda en «el teclado» no es de la hoja.** En el perfil de «después», `candidateSlots` y la ocupación ya no salen en ninguna muestra. Lo que queda es redibujar el plano de debajo cuando cambia la altura útil, y eso ya estaba en la 1.0.1: es la diferencia entre «el teclado» y «tocar la celda» de la columna «antes». Va como O-147-1.

Datos: `build/t147/e1/medicion.json`; cada corrida, en `build/t147/e1/antes/` y `build/t147/e1/despues/` (`web-medir-cpu1-N`, `web-medir-cpu4-N`, `windows-medir-N`).

## 5. El caso A09 contra 5.1

`tool/t147_caso.dart` lee los dos archivos del caso con el lector del producto. Con el plan **como vino** y los nueve tipos de 4.4 (`build/t147/e1/caso/despues-como-vino.json`):

| 5.1 del caso | Lo que da el código | |
|---|---|---|
| 438 contenedores y 271 celdas reservadas | 438 y 271 | coincide |
| Un solo aviso que dice cuántas traían «NO» | uno: «NO» en 271 celdas | coincide |
| En Carga, 408 pendientes: 135 llenos y 273 vacíos | 408, 135 y 273 | coincide |
| 448 filas, ninguna «sin entender» | 448 y ninguna | coincide |
| Las siete filas sin OR se reconocen | cinco secciones: 141, 6, 187, 53 y 61 (58 + 1 + 2) | coincide |
| Ningún puerto pendiente; los cuatro por identidad, con respaldo | COCTG (58), COTRB (55), JMKIN (18) y COBAQ (6) | coincide |
| Siguen pendientes los nueve tipos de 4.3 | 20ST, 20TK, 40HC, 45HC, 20OT, 40FF, 40HF, 40OT y 40RF | coincide |
| El cruce de 4.4, salvo «datos distintos», que baja a 17, todos por el tipo | 135 de 172; 0 del plan fuera; 276 de 276 en 23 grupos; 37 fuera del plan; **17, los 17 por el tipo;** 94 con VGM distinto, −4.6 t | coincide |
| Los 23 grupos | las mismas 23 líneas de la tabla de 4.4; cuadran 7 | coincide |
| La hoja abre sin trabarse | sección 4 | coincide |

Además: bahía 01 con 4 contenedores, 3 reservas y 116.0 t; seis tipos deducidos (40ST, 40RA, 40RC, 40RH, 20FF y 20RF) y `LGH` → `LNH`, como en 4.3.

**Mirado en pantalla,** en el banco «después», en la Web y en Windows, a 360 × 800 y a 1366 × 690, de día y de noche: ocho recorridos de 22 capturas, 176 en total, en `build/t147/e1/capturas/despues/`. Ninguno dejó errores de Flutter.

| Paso | Lo que se lee en la pantalla |
|---|---|
| El plan como vino | «438 contenedores · 271 celdas reservadas» y el aviso «Celdas sin matrícula en EQD: «NO» en 271 celdas · se leyeron como celdas reservadas» |
| El listado | «448 filas en 5 agencias · 172 llenos · 276 vacíos», «202 filas traen POT y POD distintos…» y «Todas las filas se entendieron.» |
| Las equivalencias | nueve pendientes, todas de tipo; ningún puerto |
| El cruce | las cifras de arriba |
| Un vacío en su grupo | tocar la celda, la hoja, «Asignar vacío» con «Revisado: tipo, celda y grupo coinciden con el plan.», «Carga registrada» y 407 pendientes |
| Un vacío en otro grupo | «Otro grupo: pide motivo» en la hoja; «Pide motivo: La reserva 018-08-88 es de otro grupo (tipo L5G1)…»; el motivo escrito; la celda queda en «Revisar» y 406 pendientes |
| Un lleno | «Confirmar carga», con «POT JMKIN · POD BSNAS» y «Posición planificada: 018-02-82»; 405 pendientes, 134 llenos |

## 6. El corpus, antes y después

`tool/t147_corpus.dart` lee cada `.edi` y guarda dos huellas por archivo: la de lo leído (contenedores y reservas, campo por campo, sin el `id`) y la de los avisos. Con el lector de `37be8a5` y con el de la entrega (`build/t147/e1/corpus/comparacion.txt`):

| Archivo | Lectura | Avisos |
|---|---|---|
| A01, A02, A03, A03v, A04, A05, A06, A07, A08, A08v, `PRUEBA_NIVEL_78` y `PRUEBA_NIVEL_80` | igual | iguales |
| `CORPUS_A09.edi` | 709 y 0 → 438 y 271 | ninguno → `noNumber` |
| `LISTADO_A08.xlsx` contra A08 | iguales las equivalencias, las filas guardadas y el cruce | — |
| `LISTADO_A09.xlsx` | 3 → 0 filas sin entender; 3 → 5 secciones; 13 → 9 pendientes | — |

Cambian solo los dos archivos del caso, que es lo que se buscaba.

## 7. Las validaciones

Todo después del último cambio de `lib/`, `test/` y `tool/*.dart`. Registros: `build/t147/e1/final/`.

| Dónde | `flutter analyze`, todo el paquete | Suite completa, una corrida |
|---|---|---|
| Aquí (20:17 a 20:19) | cero incidencias | **2280 de 2280**, sin omitidas ni fallidas |
| Copia limpia en `%TEMP%\t147\copias\limpia` (20:19 a 20:22) | cero incidencias | **2280 de 2280**, sin omitidas ni fallidas |

- La copia limpia es `git -c core.autocrlf=false archive 37be8a5`, más los 12 archivos cambiados y los 16 nuevos de entonces, copiados de la carpeta y cotejados por su huella (`copia-limpia-manifiesto.json`), más la entrada de T-124. Ahí corrí `flutter pub get --offline`: su `pubspec.lock` queda igual al de la carpeta.
- Ningún `// ignore:`. Ninguna dependencia nueva.
- **Después de esas corridas** agregué `tool/t147_copia_en_blanco.py` y este informe. Ninguno es Dart: no entran en `analyze` ni en la suite.
- Nunca `flutter test --platform chrome`.

## 8. Lo que encontré y no cambié

**O-147-1 · Redibujar el plano en Carga calcula la huella del viaje entero muchas veces.** Cada `ref.watch(loadingOperationProvider(voyage))` busca el proveedor por su viaje, y eso calcula el `hashCode` de `VesselVoyage`: todos sus contenedores, reservas y bahías. Con el caso son 1.7 ms por lectura, y hay lecturas en 15 archivos, algunas por celda.
- En el perfil de «después» es un tercio del trabajo de los cuadros (628 de 1 732 ms).
- Es lo que queda en «el teclado» de la sección 4: 0.15 s, y 0.7 s con la CPU frenada.
- **Ya estaba en la 1.0.1** y crece con el tamaño del plan, no con el listado.
- No lo toqué: el arreglo natural (guardar la huella en `VesselVoyage`, o buscar el proveedor por el `id` del viaje) toca una entidad que usa toda la app, y no es el recorrido por fila de la 10.151. **Lo dejo a decisión de Yov:** si se quiere en la 1.0.2, es una corrección corta con su propia medición.

**O-147-2 · La hoja ofrece vacíos que no caben.** Desde una celda de 40 pies, la hoja ofrece como «Otro grupo: pide motivo» también los vacíos de 20, y al elegirlos el diálogo dice «No se registra: Un contenedor de 20 pies… no cabe». Es de la 1.0.1; R1 pide no cambiar lo que ofrece.

**O-147-3 · El orden de la hoja no es el mismo en la Web y en Windows.** Dentro de un grupo, la Web conserva el orden por OR y Windows no: el `sort` de la hoja no es estable en la máquina virtual de Dart y sí en JavaScript. Es de la 1.0.1, y cada cliente queda con el orden que ya tenía. Android usa la misma máquina virtual que Windows, así que debería ordenar igual; no lo comprobé.

**O-147-4 · «448 filas en 5 agencias».** El resumen cuenta como agencias las secciones «TRANSBORDOS», «VACIOS» y «AGREGADOS». Ya pasaba con «AGREGADOS» desde T-122.

**O-147-5 · Un grupo «sin número» con la posición mal formada se pierde sin aviso,** como ya pasaba con el número en blanco: el aviso de posición nombra un contenedor y aquí no lo hay.

**O-147-6 · Textos que no caben en las celdas de carga.** El conductor anota los grupos de las celdas («45G1 COTRB LNH») recortados a 360 dp. Ya pasaba en la 1.0.1 y no lo toca esta entrega.

**De la entrega 2, visto al trabajar y no tocado:**
- Las 40 filas canceladas siguen contando como carga: son los 37 llenos fuera del plan y 3 de los vacíos de 45G1 · COTRB.
- Las equivalencias elegidas se siguen guardando en el dispositivo: aquí, los nueve tipos. Con el cruce por POT ya no se guarda ninguna de puerto con este caso.
- Las 16 celdas con otro código ISO del mismo tipo siguen pidiendo motivo.

## 9. Compatibilidad, el manual y `DESIGN.md`

### 9.1 Entre versiones

- **Una operación publicada con un plan que trae «NO»** la leen distinto la 1.0.1 (una pieza `C:NO`) y la 1.0.2 (271 reservas): los movimientos de una no los reconoce la otra. Los tres clientes se publican juntos, y un plan con «NO» no se opera con versiones mezcladas. La operación del piloto usó la copia en blanco: no le afecta.
- **Un viaje guardado en «Recientes» por la 1.0.1** desde un plan con «NO» conserva sus 709 contenedores hasta que se vuelva a abrir el archivo: el almacén guarda el viaje ya leído.
- **El listado guardado** se abre en los dos sentidos (3.4).
- **Los avisos nuevos** no rompen la 1.0.0 ni la 1.0.1 (3.2).

### 9.2 Los pasos del manual de la 1.0.1 que cambian (no lo edité)

| Sección | Qué cambia |
|---|---|
| 3.2 El archivo y el previo | Un plan que trae «NO» (u otro texto repetido) donde va la matrícula se abre con sus celdas reservadas y un aviso; ya no hace falta corregir el archivo |
| 5.2 La Lista | Dos avisos de lectura nuevos en la tarjeta del viaje: «Celdas sin matrícula en EQD» y «Matrículas repetidas en EQD» |
| 7.8 El listado de la agencia | «COD.», «TRANSBORDOS» y «VACIOS» se reconocen; con POT y POD distintos, el cruce usa el POT y el resumen y cada fila lo dicen; una equivalencia puede salir «Propuesta: el plan carga… con ese mismo código» |
| 7.9 Cargar por OR desde el muelle | Los diálogos «Confirmar carga» y «Asignar vacío» enseñan «POT … · POD …» cuando son distintos |
| 8.2 El BAPLIE de salida | Con POT en el listado, `LOC+11` lleva el POT y no sale `LOC+13` |
| 10. Mensajes y qué hacer | Los dos avisos nuevos, con su acción |
| 11. Glosario, «Celda reservada» | También la que el plan marca con «NO» |

### 9.3 `DESIGN.md`

**No lo edité.** `sprint-4` ya lo cambió (T-120, 151 líneas más) y la 10.151 cuenta con que T-147 no toque ninguna ruta de las que separan a `sprint-4` de `master`. Lo que cambia, para que Yov lo ponga al mezclar, como 17.6:

> **17.6 Los defectos del piloto 4 (T-147; 10.151)**
>
> Dos avisos de lectura más, con el aspecto de los de 17.4 y guardados aparte como ellos:
>
> | Tipo | Línea de resumen | Al tocarla |
> |---|---|---|
> | `noNumber` | «Celdas sin matrícula en EQD: «NO» en 271 celdas · se leyeron como celdas reservadas» | Una frase que lo explica y una línea por texto: ««NO» en 271 celdas» |
> | `duplicate` | «Matrículas repetidas en EQD: 1 contenedor · revisa esas celdas con quien hizo el plan» | Una frase que lo explica y «MSCU1234567: 010-02-82 y 010-04-84» |
>
> En el listado de la agencia: bajo las agencias, «N filas traen POT y POD distintos: el cruce con el plan usa el POT, donde el contenedor baja del buque.»; en cada fila con los dos distintos, una línea «POT … · POD …»; una identidad propuesta dice «Propuesta: el plan carga X en esta escala con ese mismo código. Ningún contenedor de X está en el listado y en el plan (N filas).»
>
> En los diálogos «Confirmar carga» y «Asignar vacío», bajo el grupo de la fila, «POT … · POD …» cuando son distintos.
>
> La hoja «Vacíos del listado» no cambia lo que ofrece ni su orden.

## 10. Para quien acepte

Todo corre con el semáforo: un comando de Flutter o de Dart a la vez en la máquina. `<corpus>` es la carpeta del corpus; el caso nunca se copia al repositorio.

**1. Las cifras del caso (sección 5):**

```powershell
dart run tool/t147_caso.dart --plan "<corpus>\CORPUS_A09.edi" --listado "<corpus>\LISTADO_A09.xlsx" --elegir "tipo:20ST=22G1,tipo:20TK=22K2,tipo:40HC=45G1,tipo:45HC=L5G1,tipo:20OT=22U1,tipo:40FF=42P3,tipo:40HF=45P3,tipo:40OT=42U1,tipo:40RF=42R1" --medir
```

**2. El corpus (sección 6):** `dart run tool/t147_corpus.dart --salida build/t147/e1/corpus/otra.json --carpeta "<corpus>" --carpeta "<carpeta con A07, A08 y LISTADO_A08>"`, y después `--comparar build/t147/e1/corpus/antes.json build/t147/e1/corpus/otra.json`. Tiene que decir «igual» en todo menos en `CORPUS_A09.edi`.

**3. Las rojas (sección 3):** en una copia de `37be8a5` de fuera del repositorio, copiar `test/t147_*_test.dart`, `test/support/t147_listado_support.dart` y `test/fixtures/t147_listado_guardado_por_la_101.json`, y correr cada archivo. Tienen que fallar 3, 12 y 10. La copia que usé sigue en `%TEMP%\t147\copias\rojas`.

**4. El banco y el recorrido en pantalla (sección 5):**

```powershell
flutter build web --release --no-pub --no-web-resources-cdn -t tool/t147_main.dart --output=build/t147/e1/despues/web
```

```powershell
python -X utf8 tool/t147_web.py --web build/t147/e1/despues/web --caso "<corpus>" --salida build/t147/e1/despues/otra-360-dia --perfil otra-360-dia --perfil-nuevo --ancho 360 --alto 800 --consulta "escenario=recorrido&plan=CORPUS_A09.edi&listado=LISTADO_A09.xlsx&escala=GTSTC&tema=dia&bahia=18&prefijo=otra-&elegir=tipo:20ST=22G1,tipo:20TK=22K2,tipo:40HC=45G1,tipo:45HC=L5G1,tipo:20OT=22U1,tipo:40FF=42P3,tipo:40HF=45P3,tipo:40OT=42U1,tipo:40RF=42R1"
```

- Cambiar `--ancho 1366 --alto 690` y `tema=noche` para las otras combinaciones. Cada corrida, en su carpeta de salida y con su perfil.
- En Windows: `flutter build windows --release --no-pub -t tool/t147_main.dart`, copiar `build\windows\x64\runner\Release` a `%TEMP%` y usar `tool/t147_windows.py` con `--exe`, `--almacen` (en `%TEMP%`), `--caso` (una carpeta de `%TEMP%` con los dos archivos) y los mismos parámetros como `nombre=valor`, más `tamano=360x800`.
- Sin `escenario`, el banco es la app para recorrerla a mano.

**5. La medición (sección 4):** primero `escenario=preparar` con el mismo perfil de Chrome, sin `--perfil-nuevo` después, y luego `escenario=medir&plan=CORPUS_A09.edi&escala=GTSTC&tema=dia&celda=0180084`, con `--cpu 4` para frenar la CPU. Para «antes» hace falta un banco de `37be8a5` y la copia en blanco del plan: `python -X utf8 tool/t147_copia_en_blanco.py "<corpus>" %TEMP%\t147\caso`, que se pasa con `--caso2`.

**6. El perfil (2.3):** compilar con `--profile -O 1` y agregar `--perfil-cpu`, con un perfil de Chrome nuevo. Después, `python -X utf8 tool/t147_perfil.py <cpu.cpuprofile> candidateSlots 'get$occupancy' 'contains$1'` (con comillas simples: en PowerShell, las dobles se comen el `$`).

**Lo que no hice y queda para quien acepte:**
- **No lo probé en un iPhone ni en el Honor.** La CPU frenada 4 veces es una aproximación del teléfono, no una medición en él.
- El teclado está simulado (sección 4).
- No abrí la BayStream instalada, `%LOCALAPPDATA%\BayStream` ni ningún paquete MSIX. No usé Firebase.
- La matrícula repetida en la operación no la miré en pantalla (3.3).

## 11. Los archivos

**Cambian (12):**
- `lib/features/vessel/data/services/baplie_parser_service.dart`
- `lib/features/vessel/data/services/export_list_parser_service.dart`
- `lib/features/vessel/domain/entities/export_list.dart`
- `lib/features/vessel/domain/entities/operation.dart`
- `lib/features/vessel/domain/entities/vessel_voyage.dart`
- `lib/features/vessel/domain/services/export_list_cross_checker.dart`
- `lib/features/vessel/domain/services/loading_operation.dart`
- `lib/features/vessel/presentation/pages/export_list_import_page.dart`
- `lib/features/vessel/presentation/widgets/loading_controls.dart`
- `lib/features/vessel/presentation/widgets/voyage_summary_card.dart`
- `pubspec.yaml` (**cambia:** solo las dos líneas de la versión; `pubspec.lock` **no cambia**)
- `test/t132_departure_fidelity_test.dart` (a propósito; 3.4)

**Nuevos (18):**
- `test/t147_hoja_vacios_test.dart`, `test/t147_lector_test.dart` y `test/t147_listado_test.dart`
- `test/support/t147_listado_support.dart`
- `test/fixtures/t147_listado_guardado_por_la_101.json`
- `tool/t147_caso.dart`, `tool/t147_corpus.dart`, `tool/t147_main.dart`, `tool/t147_conductor.dart`, `tool/t147_plataforma.dart`, `tool/t147_plataforma_io.dart` y `tool/t147_plataforma_web.dart`
- `tool/t147_servidor.py`, `tool/t147_web.py`, `tool/t147_windows.py`, `tool/t147_perfil.py` y `tool/t147_copia_en_blanco.py`
- `docs/T147-RESULTADOS.md`

No toqué `lib/main.dart`, los dos archivos congelados, `SPRINT-4.md`, `AGENTS.md`, `CLAUDE.md`, `README.md`, `DESIGN.md`, el manual ni `.claude/`.

**Fuera de Git, en la carpeta:** `build/t147/e1/` (la evidencia, 280 MB), `build/t124/entradas/` y `build/windows` (9.6 GB, el banco de Windows; se puede borrar).

**En `%TEMP%`:** borré las copias del caso, los almacenes, los perfiles de Chrome y los bancos. Quedan `%TEMP%\t147\copias\rojas` y `limpia`, sin nada del caso; se pueden borrar después de la revisión.

## 12. Git (lo ejecuta Carlos)

```powershell
git add -- lib/features/vessel/data/services/baplie_parser_service.dart
git add -- lib/features/vessel/data/services/export_list_parser_service.dart
git add -- lib/features/vessel/domain/entities/export_list.dart
git add -- lib/features/vessel/domain/entities/operation.dart
git add -- lib/features/vessel/domain/entities/vessel_voyage.dart
git add -- lib/features/vessel/domain/services/export_list_cross_checker.dart
git add -- lib/features/vessel/domain/services/loading_operation.dart
git add -- lib/features/vessel/presentation/pages/export_list_import_page.dart
git add -- lib/features/vessel/presentation/widgets/loading_controls.dart
git add -- lib/features/vessel/presentation/widgets/voyage_summary_card.dart
git add -- pubspec.yaml
git add -- test/t132_departure_fidelity_test.dart
git add -- test/t147_hoja_vacios_test.dart
git add -- test/t147_lector_test.dart
git add -- test/t147_listado_test.dart
git add -- test/support/t147_listado_support.dart
git add -- test/fixtures/t147_listado_guardado_por_la_101.json
git add -- tool/t147_caso.dart
git add -- tool/t147_corpus.dart
git add -- tool/t147_main.dart
git add -- tool/t147_conductor.dart
git add -- tool/t147_plataforma.dart
git add -- tool/t147_plataforma_io.dart
git add -- tool/t147_plataforma_web.dart
git add -- tool/t147_servidor.py
git add -- tool/t147_web.py
git add -- tool/t147_windows.py
git add -- tool/t147_perfil.py
git add -- tool/t147_copia_en_blanco.py
git add -- docs/T147-RESULTADOS.md
git commit -m "Sprint 4: T-147, entrega 1: la hoja de los vacios no se traba, NO es sin numero, el cruce va por el POT y la candidata 1.0.2"
git push -u origin t147-piloto4
```

Son 30 rutas. `windows/flutter/generated_plugin_registrant.*` y `generated_plugins.cmake` los reescribió `pub get` con otros saltos de línea y sin cambios de contenido: no van.

## 13. En tres líneas

1. La hoja «Vacíos del listado» decide una vez por celda y la ocupación se calcula una vez por estado: tocar una celda reservada con el caso A09 pasa de 1.3 s a 35 ms (de 5.7 a 0.2 s con la CPU frenada), y ofrece lo mismo.
2. El lector lee «NO» como celda reservada y avisa una vez, y avisa la matrícula repetida; el listado cruza por el POT, propone la identidad y reconoce «COD.», «TRANSBORDOS» y «VACIOS».
3. La versión es 1.0.2+11; la suite da 2280 de 2280 y `analyze` cero, aquí y en una copia limpia, y las cifras de 5.1 del caso coinciden todas.

## 14. Para Yov

> Yov: T-147, entrega 1, está en `baystream-t147` sin commit; el informe es `docs/T147-RESULTADOS.md` y la evidencia, `build/t147/e1/`.
>
> La causa de la 10.151 se confirma con un perfil de Chrome: `candidateSlots` por fila es el 99.7 % del armado de la hoja, y dentro la ocupación es el 71 % y `free.contains` (Equatable) el 20 %. Hacían falta las dos reglas de R1. Tocar la celda con el caso A09: Web 1 331–1 365 → 34–37 ms; Web con la CPU ÷ 4, 5 577–5 735 → 160–198 ms; Windows 1 445–1 500 → 18–51 ms. La hoja ofrece las mismas filas en el mismo orden (19 pruebas que también pasan en `37be8a5`).
>
> Las cifras de 5.1 del caso coinciden todas, incluido «datos distintos» en 17, todos por el tipo. Del corpus solo cambia `CORPUS_A09.edi`; `LISTADO_A08.xlsx` da lo mismo. Suite 2280 de 2280 y `analyze` cero, aquí y en copia limpia. Rojas en una copia pura de `37be8a5`: fallan 3, 12 y 10.
>
> Cuatro cosas para que mires:
> 1. **Cambié a propósito una prueba de T-132** (`LOC+13`): con R4 el puerto de la fila es el POT, sale en `LOC+11` y `LOC+13` ya no sale. Lo fuerza la compatibilidad con la 1.0.1, que lee el grupo de `pod`. Sección 3.4.
> 2. **Una reserva sin asignar no se escribe en el BAPLIE de salida,** ni en blanco ni con «NO»; el encargo decía que salía en blanco. Lo fija una prueba. Sección 3.2.
> 3. **No edité `DESIGN.md`:** `sprint-4` ya lo cambió y habría conflicto al mezclar. El texto propuesto está en 9.3.
> 4. **O-147-1:** lo que queda al abrirse el teclado (0.15 s; 0.7 s con la CPU frenada) es redibujar el plano, donde un tercio se va en la huella del viaje por cada `ref.watch` de la operación. Ya estaba en la 1.0.1 y no lo toqué; tú decides si entra en la 1.0.2.
>
> A07, A08 y `LISTADO_A08.xlsx` no están en la carpeta del corpus sino en el escritorio de Carlos (10.123); `CLAUDE.md` todavía dice lo contrario. No lo probé en un iPhone ni en el Honor, y el teclado de la medición está simulado.

## 15. Las horas del reloj

| Tramo | Horas | Qué |
|---|---|---|
| 1 | hasta las 18:35 (no anoté el inicio; fueron unos 30 minutos) | Lecturas, huellas, entrada de T-124 y la copia en blanco |
| 2 | 18:35 a 18:48 | La línea base y el script del caso |
| 3 | 19:01 a 19:31 | El banco, la reproducción, la medición «antes» y el perfil |
| 4 | de las 19:35, más o menos, a las 20:24 | R1 a R6, la versión, el banco «después», la medición, las rojas, la suite y la copia limpia |
| 5 | 20:24 a 20:30 | Este informe |

Entre tramos esperé la luz verde de Carlos. Un descuido: a las 18:43 corrí un `dart run` de 8 segundos fuera de una ventana anunciada; se lo dije a Carlos en el mensaje siguiente.
