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

---

# Entrega 2 · Propuesta

Timonel · 20-nov-2026 · carpeta `C:\Proyectos\baystream-t147`, rama `t147-piloto4`, en `v1.0.2` (`99995db`). **Es solo la propuesta:** no cambié `lib/`, `test/`, `tool/` ni `pubspec.*` de la carpeta, no cambié la versión y no ejecuté ninguna escritura de Git. Lo que hizo falta para mirar o medir (dos sondas, un escenario más en el conductor y un prototipo de tres líneas) vive en dos copias limpias de `%TEMP%\t147-e2\`. La evidencia está en `build/t147/e2/propuesta/`, fuera de Git.

Las citas `archivo:línea` son del código de `v1.0.2`. Las cifras del caso salen de leer `CORPUS_A09.edi` y `LISTADO_A09.xlsx` con los lectores del producto (`sonda-caso.json`), salvo donde digo otra cosa. Lo de la entrega 1, de la sección 0 a la 15, queda como estaba.

> **Nota del 20-nov, 22:56 · Lo que cambió después de esta propuesta.** Carlos la aprobó con cuatro cambios (decisiones 10.159 a 10.161 de `SPRINT-4.md`). El texto de abajo queda como se entregó; donde diga otra cosa, manda esta nota, y lo hecho está en «Entrega 2 · Parte 2a», al final.
>
> | Qué cambió | Dónde lo decía la propuesta | Por qué decisión |
> |---|---|---|
> | La cancelación se reconoce por **tres** notas: la palabra CANCEL con sus formas, «ROLEADO» y «YA EMBARCADO». La propuesta daba «ROLEADO» solo como ejemplo de nota que se carga y se avisa | E2-P1, puntos 1 y 2, y D1 | 10.160, cambio 1 (D1 y D3) |
> | Una fila cancelada no se ofrece, **pero se puede cargar con motivo,** y queda como conflicto para la oficina. La propuesta la bloqueaba: ya no hay ningún «No se registra» por esto | E2-P1, punto 3 y su tabla, y D2 | 10.160, cambio 2 (D2) |
> | En el BAPLIE de salida **manda el código ISO del plan** cuando el tipo del listado lo llena, para llenos y vacíos. La propuesta dejaba el principal de su tipo, como hoy | E2-P4, «Lo que no cambia» | 10.160, cambio 3 (D16) |
> | **Un código del plan, un solo tipo del listado:** si dos lo declaran, la importación no sigue. La propuesta no lo decía | E2-P4 | 10.160, cambio 4 (D9) |
> | Las dos partes salen **juntas, en una sola 1.0.3.** La propuesta dejaba abierta una 1.0.4 | E2-9.2 y D15 | 10.160 (D15) |
> | «TRANSBORDOS» y «VACIOS» **son de la agencia de arriba.** Es de la parte 2b | E2-P7, O-147-4, y D13 | 10.161 (D13) |

## E2-0. En corto

- **Paso 0, limpio.** En una copia de `9d6c199`, con T-120 y T-147 juntos: `analyze` sin incidencias y **2393 de 2393** pruebas, sin omitidas.
- **Las 40 filas canceladas se reconocen por la palabra CANCEL** en MARCHAMO (o en CONTENIDO). Sin ellas, el caso da 408 filas, 135 de 135 llenos que cruzan y 273 vacíos para 273 celdas. No hace falta guardar nada nuevo: la nota ya viaja en el listado guardado.
- **El destino final sale en `LOC+83`,** llenos y vacíos, con el POD del Excel. Lo que sigue a bordo ya conserva el suyo: los 301 grupos de paso salen enteros, byte por byte.
- **Lo guardado deja de mandar.** Primero el plan; lo guardado solo vale si el plan no lo contradice, y los puertos ya no se guardan. Las del iPhone se ven y se quitan desde una tarjeta nueva.
- **Un hallazgo que cambia la lectura de P4:** las 16 celdas «de otro grupo» son exactamente lo que les sobra a siete grupos. Si la oficina declara qué códigos llena también cada tipo, los 23 grupos quedan en 14 y **los 14 cuadran.** Con P1 y P4 juntos, el cruce del caso sale limpio.
- **La matrícula repetida, mirada en pantalla:** la segunda celda se carga como cualquier lleno y la primera no responde nunca. Propongo que un plan así no entre a la nube, ni al publicar ni al agregar.
- **O-147-1 tiene un arreglo corto:** cinco líneas en `vessel_voyage.dart`. Medido con el instrumento de la entrega 1, quita entre el 42 y el 47 % de lo que queda al abrirse el teclado. No es lo que necesita el próximo piloto (10.158): lo pongo en la segunda parte.
- **Dos cosas que no sabía y la sonda enseñó:** la hoja abierta desde una celda de 20 pies ofrece 274 vacíos y **250 no caben**; y la importación del caso guarda en el dispositivo 16 equivalencias, no nueve.
- **Propongo dos partes en una rama:** la 2a con lo que necesita el próximo piloto (P1, P3, P4, P2 y la hoja) y la 2b con el resto. Quince decisiones para Carlos, en E2-9.7.

## E2-1. Paso 0

| Comprobación | Resultado |
|---|---|
| Punta de la rama (`git log`, `git show --stat`) | `99995db`, «Sprint 4: la 1.0.2, mezcla de t147-piloto4 a master» |
| `CORPUS_A09.edi` | 123 619 bytes, `450219fe…f07e`: la huella de la tabla del caso |
| `LISTADO_A09.xlsx` | 64 524 bytes, `df40cd6f…aad0`: la huella de la tabla del caso |
| Copia limpia de `9d6c199` (`git -c core.autocrlf=false archive`, en `%TEMP%\t147-e2\s4`) | 2 149 archivos cotejados con sus blobs: ninguno distinto |
| Entrada de T-124 | copiada de `build\t124\entradas\`, huella `d4384834…`; fuera de Git |
| `flutter pub get --offline --enforce-lockfile` (19:39) | pasa; `pubspec.lock` no cambia |
| `flutter analyze`, todo el paquete (19:40) | **«No issues found!»** |
| Suite completa, una corrida (20:09 a 20:11) | **`+2393: All tests passed!`**, sin omitidas ni fallidas |

- Es lo que se esperaba: las 2340 de `sprint-4` más las 53 de T-147. **T-120 y T-147 conviven.**
- Registros: `build/t147/e2/propuesta/paso0/` (`01-pub-get.log`, `02-analyze.log`, `03-suite.log` y `horas.txt`).
- La copia de `9d6c199` trae la versión `1.0.2+11`, como la rama.
- `origin/sprint-4` está hoy en `461f8e3` (la decisión 10.158, que solo cambia `SPRINT-4.md`). La suite corrió en `9d6c199`, que es lo que pedía el encargo.
- **Las rutas que separan a `sprint-4` de `v1.0.2` son 39** (`git diff --stat v1.0.2 origin/sprint-4`), no 38: la 10.157 sumó el manual de la 1.0.2. Las de `lib/` son 14; las nombro en E2-9.4.

## E2-P1. Las filas canceladas del listado

### Qué pasa hoy

- El lector guarda la nota como si fuera un marchamo (`export_list_parser_service.dart:289`), y la fila guardada la lleva en `seal` (`export_list.dart:245`). **Nadie la lee.**
- El resumen cuenta las 448 (`export_list_import_page.dart:200-201`; `ExportList.fulls` y `empties`, `export_list.dart:322-323`).
- Las equivalencias cuentan las 448 (`export_list_cross_checker.dart:294-301`).
- El cruce las recorre todas (`:409`): los 37 llenos caen en «Llenos del listado que no están en el plan» (`:421-423`) y los 3 vacíos, en su grupo (`:411-414`).
- La hoja de los vacíos y «Asignar vacío» las ofrecen (`loading_operation.dart:133-153` y `:395-402`). Con el caso, la hoja ofrece los OR 156, 168 y 182 desde cualquier celda.
- La carga por OR no ofrece los 37 llenos porque el plan no los trae (`:136-140`), no porque estén cancelados.
- En el BAPLIE de salida, «Filas del listado que no cargaron» busca CANCEL **en CONTENIDO** (`departure_baplie_writer.dart:186-189`), no en MARCHAMO. Con el caso, las 40 salen como «sin celda en el plan» (37) y «sin celda asignada en el plan» (3); ninguna, como «cancelado en el listado».
- En «Filas del listado», la fila dice «Marchamo ROLEADO - CANCEL» (`export_list_import_page.dart:603-607`).

### Lo que propongo

**1. Cómo se reconoce.** Una fila está cancelada si su MARCHAMO o su CONTENIDO trae la palabra CANCEL, entera, sin mirar mayúsculas ni tildes: CANCEL, CANCELADO, CANCELADA, sus plurales, CANCELLED y CANCELED.
- Es la expresión que T-132 ya usa sobre CONTENIDO. Las cuatro notas de Carlos la traen.
- En el caso, MARCHAMO trae algo en 40 filas y son esas 40; ninguna trae una cifra, y CONTENIDO no dice CANCEL en ninguna fila.
- **Se calcula de lo que ya está guardado** (`seal` y `contents`). No hay ninguna clave nueva en el listado.
- **Descarto** una lista cerrada con los cuatro textos exactos: un espacio de más la rompe, y «YA EMBARCADO -CANCEL» ya trae el guion pegado. **Descarto** el color de relleno: el lector no lee estilos, y un color no es un dato.

**2. Una nota parecida que no es una de las cuatro.**
- Si trae CANCEL («CANCELADO POR LA LÍNEA»), es una cancelación.
- Si no la trae y tampoco parece un marchamo, porque no tiene ninguna cifra («ROLEADO», «PENDIENTE», «NO EMBARCAR»): **la fila se sigue cargando y el resumen la avisa.**
- Un texto con cifras sigue siendo un marchamo.
- **Por qué no la doy por cancelada:** si me equivoco hacia «cancelada», el muelle no encuentra una fila que sí sube. Si me equivoco hacia «se carga», pasa lo de hoy, y la oficina lo arregla con el listado corregido, que ya entra en una operación publicada (T-127). Es la decisión D1.

**3. Qué ve el planificador.**

| Dónde | Texto |
|---|---|
| Resumen del listado | «448 filas en 5 agencias · 408 para cargar: 135 llenos y 273 vacíos» (dirá «2 agencias» cuando entre O-147-4) |
| | «40 canceladas en el listado, que no se cargan: 37 llenos y 3 vacíos» |
| | «ROLEADO - CANCEL 24 · YA EMBARCADO -CANCEL 7 · CANCELADO 7 · REEMPLAZO - CANCEL 2» |
| Su desplegable | «Canceladas en el listado (40)», con «OR 22 · ‹matrícula› · lleno · «ROLEADO - CANCEL»» |
| Una nota sin reconocer | «2 filas traen en MARCHAMO una nota que no se reconoce: «ROLEADO» (OR 12 y 31). Se cargan. Si no se cargan en este buque, pide a la agencia que diga CANCELADO y vuelve a importar el listado.» |
| Equivalencias | cuentan solo lo que se carga: «Tipo 40HC (125 filas)». Un código que solo traen filas canceladas no pide equivalencia |
| Cruce | «135 de 135 llenos cruzan con el plan» y «273 de 273 vacíos en 23 grupos de reservas». La sección de los llenos que no están en el plan no sale |
| Cruce, solo si pasa | «2 canceladas en el listado que el plan todavía carga», con «OR n · ‹matrícula› · 010-02-82» y «Cancela su embarque desde el detalle de la celda o pide el plan corregido.» En el caso son 0 |
| Filas del listado | «Cancelada en el listado: «ROLEADO - CANCEL»», donde hoy dice «Marchamo …» |
| Hoja de los vacíos y «Asignar vacío» | no las ofrecen. Si se busca su OR exacto, una fila apagada: «OR 156 · ‹matrícula› · Cancelado en el listado: no se carga» |
| Carga por OR | igual. Al tocar en el plano un lleno que el plan trae y el listado cancela: «No se registra: el listado lo marca cancelado («ROLEADO - CANCEL»). Si sí se carga, la agencia corrige el listado y la oficina lo vuelve a importar.» |
| Esa celda, en Carga | la marca «Revisar»; su etiqueta accesible dice «cancelado en el listado, revisar» |
| Avance | bajo las notas del encabezado: «Listado: 40 filas canceladas, que no se cargan (37 llenos y 3 vacíos).» Las columnas no cambian |
| BAPLIE de salida | en «Filas del listado que no cargaron»: «OR 22 · ‹matrícula› · cancelado en el listado («ROLEADO - CANCEL»)» |

Que el muelle no pueda cargar un lleno que el plan trae y el listado cancela es la decisión D2: Carlos dijo que esas filas no se cargan, y por eso propongo bloquear. La otra salida es dejarlo con motivo.

**4. Cómo convive con los cancelados que ya hay.** Son dos cosas distintas y la pantalla las nombra distinto, siempre igual:

| | Cancelado **en el listado** (nuevo) | Cancelado **en la operación** (T-81) |
|---|---|---|
| Quién | la agencia, en el Excel | la oficina, con «Cancelar embarque» y su motivo |
| Sobre qué | una fila del listado | una pieza del plan: un contenedor o una celda reservada |
| Cómo viaja | dentro del listado, que es una fuente | un movimiento de la bitácora |
| Dónde se ve | resumen, cruce, hoja, línea del avance y «Filas que no cargaron» | la marca «Cancel.» de la celda, la columna «Cancelados» del avance y «Cancelados vigentes» de la salida |

- **Ninguno se convierte en el otro solo.** La bitácora es de solo anexar y una cancelación es de la oficina, con su motivo: el listado no escribe movimientos.
- **Lo que los une es el cruce,** que nombra las canceladas del listado que el plan todavía carga. La oficina las cancela una por una, como hoy. Un botón para cancelarlas todas a la vez no entra: en el caso no hay ninguna.
- La columna «Cancelados» y «Cancelados vigentes» no cambian su cuenta. En el caso siguen en 0.
- Una fila con las dos cosas sale en las dos listas de la salida, cada una con su motivo. Ya pasa así desde T-132.

**5. Si la fila ya se cargó cuando llega la revisión que la cancela.**
- **La carga no se toca ni se anula sola.** Lo que subió, subió.
- Al importar, la tarjeta «Lo ya operado con el listado nuevo» (T-127; `export_list_cross_checker.dart:220-257`) gana una línea: «1 contenedor ya cargado queda cancelado en el listado nuevo», con su lista.
- En el plano, la celda pasa a «Revisar», y el avance la lista en Conflictos: «OR 156 · ‹matrícula› se cargó y el listado lo marca cancelado («CANCELADO»). Si el registro fue un error, deshazlo desde el detalle de la celda.»
- Es un conflicto que cada equipo deriva del listado, como ya hace con «vacío de otro grupo» (`operation.dart:333-336` y `operation_state_deriver.dart:481-491`). No es un movimiento ni se guarda.
- En la salida va a bordo, porque manda la posición física (T-82), con una línea en «Avisos de la salida»: «OR 156 · ‹matrícula›: está a bordo y el listado lo marca cancelado.»
- «Deshacer carga» la deja como cualquier cancelada: no se ofrece.

### Entre versiones

- **La forma del listado guardado no cambia.** La versión nueva lee como cancelada una fila que guardó la 1.0.1 o la 1.0.2, sin volver a importar.
- La 1.0.2 lee el listado que guarde la nueva y cuenta las 40 como carga, igual que hoy.
- **Con versiones mezcladas,** un muelle en la 1.0.2 puede asignar un vacío cancelado, y la oficina en la nueva lo ve como conflicto. No se pierde nada, pero no conviene: los tres clientes salen juntos.

### Las pruebas

Con listados sintéticos (`test/support/t147_listado_support.dart`). Las rojas corren contra una copia de `v1.0.2`, como en la entrega 1.

- Las cuatro notas, en minúsculas, con tilde, «CANCELLED» y en CONTENIDO: canceladas. «ROLEADO» solo: se carga y se avisa. «AB123456»: marchamo.
- El resumen cuenta «para cargar» y «canceladas»; las equivalencias cuentan sin las canceladas; un código que solo traen filas canceladas no queda pendiente.
- El cruce: un lleno cancelado que no está en el plan no sale en «no están en el plan»; un vacío cancelado no entra en su grupo; una cancelada que el plan carga sale en su lista.
- La hoja, «Asignar vacío» y «Corregir carga» no la ofrecen, y la carga armada a mano se rechaza con su texto.
- La fila ya cargada y la revisión que la cancela: la tarjeta la cuenta, el estado derivado da el conflicto, y «Deshacer carga» lo quita.
- La salida: el motivo con la nota; MARCHAMO vale igual que CONTENIDO; la cancelada que está a bordo sale con su aviso.
- Un listado guardado por la 1.0.2, con sus notas en `seal`, se lee cancelado sin reimportar.
- **Las que no deben cambiar:** un listado sin notas, como el del caso A08, da lo mismo que hoy.

### Lo que debe dar el caso A09

| | Hoy (1.0.2) | Con P1 |
|---|---|---|
| Filas | 448: 172 llenos y 276 vacíos | 408 para cargar, 135 y 273; 40 canceladas, 37 y 3 |
| Canceladas, por nota | no se cuentan | 24, 7, 7 y 2 |
| Llenos que cruzan | 135 de 172 | **135 de 135** |
| Llenos del listado que no están en el plan | 37 | **0** |
| Del plan que no están en el listado | 0 | 0 |
| Vacíos en grupos | 276 de 276 en 23 | **273 de 273** en 23 |
| Grupos que cuadran | 7 de 23 | 7 de 23 (con P4, 14 de 14) |
| Llenos con datos distintos | 17, por el tipo | 17, por el tipo (con P4, 0) |
| Tipos, en filas | 20ST 31, 40HC 156, 40RA 9, 40RH 62 | 20ST 30, 40HC 125, 40RA 6, 40RH 57 |
| POT, en filas | COTRB 231, JMKIN 123, COCTG 88, COBAQ 6 | COTRB 213, JMKIN 123, COCTG 66, COBAQ 6: **lo mismo que descarga el plan** |
| Pendientes | los nueve tipos | los nueve tipos |
| Canceladas que el plan trae | — | 0 de 40 |
| La hoja, desde 018-10-88 | 274 filas, con los OR 156, 168 y 182 | 271 filas, sin ellos |
| Salida sin cargas: «no cargaron» | 448: 137 «carga no registrada», 274 «sin celda asignada», 37 «sin celda en el plan» | 448: 137, 271, 0 y **40 «cancelado en el listado»** |

Los tres vacíos cancelados son 40HC · COTRB · `LGH`, de la sección «VACIOS». Las otras 37 son de «AGENCIA 1» (33) y «AGENCIA 2» (4).

**Los 23 grupos, con las 40 y sin ellas.** Cambia una sola línea:

| Grupo (ISO · descarga · línea) | Celdas | Vacíos, con las 40 | Vacíos, sin ellas |
|---|---:|---:|---:|
| 42G1 · COTRB · LNH | 62 | 63 | 63 |
| L5G1 · COTRB · LNH | 61 | 64 | 64 |
| 45R1 · JMKIN · LNH | 43 | 43 | 43 |
| **45G1 · COTRB · LNH** | 28 | **34** | **31** |
| 45G1 · JMKIN · LNJ | 24 | 24 | 24 |
| 22G1 · JMKIN · LNJ | 10 | 10 | 10 |
| 42U1 · JMKIN · LNH | 8 | 8 | 8 |
| 42R1 · JMKIN · LNH | 6 | 9 | 9 |
| 22U1 · JMKIN · LNH | 5 | 6 | 6 |
| 22K2 · COCTG · LNH | 4 | 8 | 8 |
| 42P3 · JMKIN · LNH | 3 | 3 | 3 |
| 42R0 · JMKIN · LNH | 3 | 0 | 0 |
| 45G0 · COTRB · LNH | 3 | 0 | 0 |
| L5G0 · COTRB · LNH | 3 | 0 | 0 |
| 22T4 · COCTG · LNH | 2 | 0 | 0 |
| 22P3 · JMKIN · LNH | 1 (ya con número) | 1 | 1 |
| 22R1 · JMKIN · LNH | 1 (ya con número) | 1 | 1 |
| 22T0 · COCTG · LNH | 1 | 0 | 0 |
| 22T1 · COCTG · LNH | 1 | 0 | 0 |
| 22U0 · JMKIN · LNH | 1 | 0 | 0 |
| 42G0 · COTRB · LNH | 1 | 0 | 0 |
| 45P3 · JMKIN · LNH | 1 | 2 | 2 |
| 45P4 · JMKIN · LNH | 1 | 0 | 0 |
| **Total** | **273** | **276** | **273** |

Coincide con 5.2 de `S4-CASO-A09.md` en todo.

## E2-P2. El destino final en el BAPLIE de salida

### Qué pasa hoy

- Una carga armada con su fila (`_loaded`, `departure_baplie_writer.dart:305-579`) escribe `LOC+9` (`:414-416`), `LOC+11` con el puerto de la fila, que desde la 1.0.2 es el POT (`:417-419`), y `LOC+13` solo con una fila guardada por la 1.0.1 (`:420-423`). **El POD del Excel, `listPod`, no se escribe en ninguna parte.**
- Lo que sigue a bordo conserva su grupo del plan (`_aboard`, `:243-303`), y si solo cambió de celda, sus bytes (`:140-155`).

**Lo comprobé con el caso** (`sonda-caso.json`, `p2Salida`):
- **Un contenedor que sigue a bordo conserva el `LOC+83` que traía.** Sin ninguna carga, la salida trae 301 contenedores y 301 `LOC+83`, y los 301 grupos del plan que lo traen están enteros en la salida, byte por byte.
- Con dos cargas cuyo POD es distinto de su POT, siguen siendo 301 `LOC+83` y ningún `LOC+13`:

| | En el plan | En la salida de la 1.0.2 |
|---|---|---|
| OR 1, lleno · POT COCTG · POD SAJED | `LOC+147`, `MEA+VGM`, `LOC+9+GTSTC`, `LOC+11+COCTG`, `LOC+76+GTSTC`, `RFF+BM`, `EQD`, `NAD` | lo mismo, con el VGM y la tara del listado. **Sin SAJED** |
| OR 400, vacío · POT JMKIN · POD CNTAO | no tiene grupo propio: va a una celda reservada | `LOC+147`, `MEA+WT`, `MEA+T`, `LOC+9+GTSTC`, `LOC+11+JMKIN`, `RFF+BM`, `EQD`, `NAD`. **Sin CNTAO** |

### Lo que propongo

**La regla.** Una carga armada con su fila lleva `LOC+83+<POD>:139:6` cuando se cumplen las tres:
1. la fila trae POT y POD distintos en el Excel (`potDiffersFromPod`, `export_list.dart:151`);
2. el POD tiene forma de UN/LOCODE (`formaDeUnLocode`, `un_locode.dart:17`: dos letras y tres letras o cifras);
3. el POD no es el código que ya sale en `LOC+11`.

**El POD va como viene en el Excel,** sin pasar por las equivalencias de puerto. Esas equivalencias llevan al puerto del plan donde el contenedor baja; el destino final no tiene contraparte en el plan. Con una equivalencia «destino final → trasbordo» de las que quedaron en el iPhone, traducirlo escribiría el trasbordo dos veces.

**Vale igual para los vacíos** (D4). El plan del caso lo hace: 40 de sus vacíos de paso traen `LOC+83`. En el caso son 60 vacíos: 52 con POT JMKIN y POD CNTAO, y 8 con COCTG y BRPNG.

**El lugar en el grupo:** justo después de `LOC+11`, o de `LOC+13` si lo hay, y antes de `LOC+76` y de `RFF`.
- Es el orden del plan del caso: en sus 301 grupos, `LOC+83` va detrás de `LOC+11`; después viene `LOC+76` en 198 y `RFF+BM` en 103 (`plan-a09-loc83.json`).
- EDIFACT no fija un orden entre los `LOC` repetidos del grupo. La inserción de hoy lo pondría detrás de `LOC+76`, porque trata igual a todos los `LOC` (`:384-399`): por eso va con su lugar explícito.
- **La forma, `:139:6`,** es la de `LOC+9` y `LOC+11` del escritor y la de los 301 del plan.

**Si el POD no tiene forma de UN/LOCODE,** no se escribe `LOC+83` y la página lo dice: «OR n · ‹matrícula›: el POD «XXX» del listado no tiene forma de UN/LOCODE; el destino final no se escribió.» (D5).
- No se inventa un código ni se escribe un texto libre con `139:6`, que declara la lista de UN/LOCODE.
- En el caso, los 36 POD del listado tienen la forma.
- El plan sí trae dos códigos que no la tienen, «CO» y «JM», en `LOC+83` de contenedores de paso. Se conservan como vienen: son del plan.
- Un carácter que no cabe en el juego del `UNB` ya impide guardar, con su fila (`:336-344`). El plan del caso es UNOA.

**Si el plan ya trae un `LOC+83` distinto del listado,** manda el listado y la página lo dice: «OR n · ‹matrícula›: destino final SAJED, del listado; el plan decía XXXXX.» (D6).
- El listado es lo que la agencia declara de lo que carga aquí. Ya manda así sobre el POD, el POT, el tipo, la línea y los pesos (T-132).
- Si el listado no da destino final (POT y POD iguales, o sin columna POT), el `LOC+83` del plan se conserva.
- No lo pongo como «Datos por confirmar», que es lo que T-132 hace con las peligrosas y la temperatura: aquello cambia cómo se estiba; esto es un dato comercial.
- **En el caso no pasa:** ninguno de los 408 que cargan en GTSTC trae `LOC+83` en el plan.

**Qué ve el planificador,** en la página del BAPLIE de salida:
- una línea con la cuenta: «169 cargas llevan su destino final (LOC+83), tomado del POD del listado.»;
- en «Avisos de la salida», los dos textos de arriba, cuando pasan.

### Con un listado guardado por la 1.0.1 y por la 1.0.2

La regla es una sola y da lo correcto en los dos casos, porque mira el POD del Excel, que las dos versiones guardan igual:

| La fila la guardó | `LOC+11` | `LOC+13` | `LOC+83` |
|---|---|---|---|
| La 1.0.2 o la nueva (el puerto de la fila es el POT) | el POT | no sale | **el POD** |
| La 1.0.1, sin equivalencia de puerto (el puerto de la fila es el POD) | el POD | el POT, por la regla de T-132 | no sale: ya está en `LOC+11` |
| La 1.0.1, con «destino final → trasbordo» elegida, como en el piloto 4 | el trasbordo | no sale | **el POD** |
| Cualquiera, sin columna POT | el POD | no sale | no sale |

### Lo que guarde la versión nueva

- **El listado guardado no cambia de forma.** La 1.0.1 y la 1.0.2 lo abren y generan su salida como hoy, sin `LOC+83` para lo cargado.
- **El BAPLIE de salida de la nueva lo abre cualquier versión.** La 1.0.1 y la 1.0.2 leen `LOC+83` (`baplie_parser_service.dart:642-645`) y lo enseñan como «Destino final» en el detalle del contenedor (`detalle_contenedor.dart:75-77`).
- La salida la genera la oficina: que la genere con la versión nueva.

### La prueba de fidelidad de T-132

- «T-132 POT igual al POD quita LOC+13; distinto lo escribe» (`test/t132_departure_fidelity_test.dart:219`) **gana esperas, no pierde ninguna:** con la fila de la 1.0.2, `LOC+11` con el POT, sin `LOC+13` y `LOC+83` con el POD justo detrás de `LOC+11`; con la fila de la 1.0.1, `LOC+11` con el POD, `LOC+13` con el POT y sin `LOC+83`; con POT igual al POD, ninguno de los dos.
- **`LOC+11` sigue siendo el POT** (10.153).
- Pruebas nuevas, rojas contra `v1.0.2`: el vacío asignado con POD distinto; el POD sin forma, con su aviso; el plan con un `LOC+83` distinto (manda el listado y avisa), igual (el grupo no cambia) y sin destino en el listado (se conserva); el contenedor de paso, entero; el lugar del segmento, con `LOC+76` y sin él; y la salida releída con el lector, que da el POD como destino final.

### Lo que debe dar el caso A09

- **169 de las 408 filas que se cargan** traen el POD distinto del POT: **109 llenos y 60 vacíos.** Los 36 POD tienen forma de UN/LOCODE.
- Sin cargas: 301 `LOC+83`, los del plan, enteros.
- Con el lleno OR 1 y el vacío OR 400 cargados: 303 `LOC+83`, con `LOC+83+SAJED:139:6` y `LOC+83+CNTAO:139:6` detrás de su `LOC+11`.
- **Con las 408 cargadas: 470 `LOC+83`** (301 más 169) y ningún `LOC+13`. Es lo que da la regla; la sonda no registró las 408 cargas.
- La fuente es el manual de BAPLIE 2.2.1 de SMDG, la cita de `BaplieConstants.locFinalDestination` (`baplie_constants.dart:81-84`).

## E2-P3. Las equivalencias guardadas

### Qué pasa hoy

- Al confirmar la importación se guarda en el dispositivo todo lo que no sea una identidad deducida o propuesta (`tableOf`, `export_list_cross_checker.dart:365-374`; `export_list_providers.dart:291-296`).
- Va a una sola tabla por dispositivo, sin buque ni viaje (`hive_vessel_data_source.dart:150-158`).
- En la importación siguiente, lo guardado manda sobre lo que digan los contenedores (`export_list_cross_checker.dart:305-315`). La pantalla solo le suma una frase en gris: «Guardada en este dispositivo, pero el plan dice …» (`export_list_import_page.dart:291-294`).
- **No hay dónde verlas ni quitarlas.** Solo el lápiz, una por una, y solo cuando sale en una importación.

**Con el caso** (`sonda-caso.json`, `p3` y `loQueSeGuardaEnElDispositivo`):
- **La importación del caso guarda 16, no nueve:** los nueve tipos elegidos, los seis que se deducen y traducen (40ST, 40RA, 40RC, 40RH, 20FF y 20RF) y la línea `LGH` → `LNH`. Ningún puerto.
- **Lo guardado manda aunque el plan diga otra cosa.** Con «COTRB → JMKIN» sembrada, la importación usa JMKIN aunque 55 contenedores del plan digan COTRB, y no pregunta. Con «40ST → 45G1», usa 45G1 aunque el plan diga 42G1.

### La regla nueva

**1. El orden de quién manda:**

| | De dónde sale | La pantalla dice |
|---|---|---|
| 1 | El plan: los contenedores que están en el listado y en el plan dan un solo código | «Propuesta: N contenedores están en el listado y en el plan.» (como hoy) |
| 2 | La revisión anterior del listado de **esta misma operación**. Ya viaja dentro del listado guardado (`export_list.dart:367`), así que es igual en todos los equipos | «De la revisión anterior de este listado.» |
| 3 | El dispositivo, **solo si el plan no lo contradice** | «Guardada en este dispositivo.» |
| 4 | El plan carga ese mismo código (T-147, regla 5) | «Propuesta: el plan carga … con ese mismo código.» (como hoy) |
| 5 | Nada de lo anterior | pendiente, con sus sugerencias (como hoy) |

«No lo contradice» quiere decir dos cosas: el plan carga ese código en la escala, y los contenedores no dan otro. Si lo contradice, no se usa, la fila queda pendiente y lo dice: «En este dispositivo estaba guardada 40ST → 45G1, y el plan dice 42G1 (1 contenedor): no se usó.»

**2. Qué se guarda en el dispositivo:** solo tipos y líneas, y solo lo que la importación confirmada usó. **Los puertos no se guardan nunca:** con el cruce por POT salen por identidad, y los que no, son de ese viaje.

**3. Atado a qué** (D7). Tres salidas:

| | Qué gana | Qué cuesta |
|---|---|---|
| **A · Al dispositivo, con la regla de no contradecir (la que propongo)** | el próximo listado de la misma agencia entra con cero o pocas pendientes | una equivalencia mala sigue guardada, pero ya no puede imponerse a un plan que dice otra cosa |
| B · Al buque | no pasa de un buque a otro | con un buque nuevo, la oficina elige otra vez los nueve tipos, que son de la agencia y no del buque |
| C · Al buque y al viaje | nada pasa de un viaje a otro | no ahorra nada: dentro de una operación ya lo cubre la fila 2 de la tabla |

**4. Lo que ya está guardado en los equipos.**
- **La versión nueva deja de leer y de escribir los puertos del dispositivo.** Las 33 del iPhone dejan de mandar en cuanto la Web se actualice.
- **Se ven y se quitan desde una tarjeta nueva,** al final de «Listado de la agencia», esté o no leído un listado:

| Texto |
|---|
| «Equivalencias guardadas en este dispositivo (16)» |
| «Tipo 40HC → 45G1», con «Quitar» en cada una |
| «De puerto, de versiones anteriores (33): ya no se usan.», con «Quitar las 33» |
| «Quitar todas» |
| «Quitar una equivalencia no cambia ningún listado ya importado.» |

- **No las borro solas** (D8): son datos que alguien eligió, y Carlos las quiere mirar (10.151).
- **Lo que no vi:** el iPhone y el almacén de la laptop. No abrí la BayStream instalada ni `%LOCALAPPDATA%\BayStream`. Por el código, si la prueba corta eligió los nueve tipos de 4.4, en la laptop quedaron las 16 de arriba.

### Entre versiones

- La tabla del dispositivo conserva su forma. La versión nueva no toca los puertos que encuentra: si se vuelve a la 1.0.2 en ese equipo, los vuelve a leer.
- El listado guardado ya trae sus equivalencias desde la 1.0.0. No hay clave nueva.

### Las pruebas

Rojas contra `v1.0.2`: lo guardado que el plan contradice no se usa y lo dice; lo guardado sin respaldo se usa si el plan carga ese código, y queda pendiente si no; los puertos guardados se ignoran; confirmar no guarda puertos; la revisión anterior de la operación manda sobre el dispositivo; quitar una y quitar todas; y una tabla guardada por la 1.0.2, con sus puertos, se lee sin fallar.

### Lo que debe dar el caso A09

- En un equipo limpio, lo mismo que hoy: nueve tipos pendientes y ningún puerto.
- Al confirmar: 16 guardadas, 15 tipos y una línea.
- En un equipo que ya importó el caso: ninguna pendiente; las nueve salen «Guardada en este dispositivo».
- Con «40ST → 45G1» o «COTRB → JMKIN» sembradas: 40ST queda pendiente, con su explicación, y COTRB sale por el plan.

## E2-P4. Un tipo del listado, varios códigos ISO en el plan

### Qué pasa hoy

- La equivalencia es de uno a uno (`EquivalenceProposal.planCode`; `tableOf`, `export_list_cross_checker.dart:365-374`).
- «El mismo grupo» compara el código exacto en seis sitios: el cruce (`:383-399` y `:412`), la diferencia de tipo de un lleno (`:429`), las celdas que se ofrecen (`loading_operation.dart:225-227` y `:344-346`), la revisión de la carga (`load_check.dart:208-219`), la hoja (`loading_controls.dart:780-783`) y el conflicto «otro grupo» (`operation_state_deriver.dart:481-491`).

**Con el caso** (`sonda-caso.json`, `p4`):
- **16 celdas reservadas en nueve códigos que ningún tipo del listado llena:** 45G0 3, L5G0 3, 42R0 3, 22T4 2, 22T0 1, 22T1 1, 22U0 1, 42G0 1 y 45P4 1. Piden motivo al cargar y quedan en «Revisar».
- **Los 17 «llenos con datos distintos» son por lo mismo:** 10 son 40HC que el plan trae como 45G0, 1 es 20ST como 22G0 y 6 son 20TK como 22T1 (3), 22T0 (2) y 22T6 (1).
- **Lo que no se había visto:** esas 16 celdas son exactamente lo que les sobra a siete grupos. A 45G1 · COTRB le sobran 3 vacíos y hay 3 celdas 45G0 · COTRB; a L5G1 le sobran 3 y hay 3 L5G0; a 42R1, 3 y 3 de 42R0; a 22K2, 4 y 4 de cisterna; a 42G1, 22U1 y 45P3, 1 y 1.

### Las tres salidas

| | Qué es | Por qué sí o por qué no |
|---|---|---|
| A · Uno a varios dentro de la equivalencia | «40HC → 45G1 y 45G0», y la fila deja de tener un solo tipo | **Descartada así.** Cambia el `type` de la fila guardada: la 1.0.2 ya no arma los mismos grupos |
| B · Una regla de códigos compatibles | dos códigos valen igual si empiezan con los mismos tres caracteres | **Descartada como regla.** Cubre 12 de las 16 celdas; las cisternas quedan fuera (22K2 contra 22T4, 22T0 y 22T1). Y mete un supuesto sobre los códigos ISO que no puedo respaldar. Sirve como sugerencia |
| C · «Aceptar con motivo» desde la oficina | un movimiento nuevo que da por buena una desviación | **No en esta entrega.** La 1.0.2 no lee una bitácora con un tipo de movimiento que no conoce (`movement.dart:176-179`), y hay que tocar las reglas de Firestore. Es su propia tarea |

### Lo que propongo: «también llena»

La oficina declara, al importar, **qué otros códigos del plan llena cada tipo del listado.** La equivalencia sigue siendo una, la principal; los demás códigos se guardan aparte, dentro del listado.

**Cómo se propone, sin trabajo de más para la oficina:**
1. **Con respaldo repartido** (40HC: 45G1 60 y 45G0 10). Hoy queda pendiente: «Los contenedores no coinciden… Elige el código del plan». Propongo que salga propuesta, con el más frecuente como principal y los demás como «también»: «Propuesta: 60 contenedores van a 45G1 y 10 a 45G0. 40HC llena los dos.» El lápiz la corrige (D10). En el caso, 20ST, 20TK y 40HC dejan de estar pendientes: **quedan seis de las nueve.**
2. **Sin respaldo,** una tarjeta nueva bajo las equivalencias: «Celdas reservadas que ningún tipo del listado llena (11)», con una línea por código: «L5G0 · 3 celdas. ¿Las llena 45HC (L5G1)?», con «Sí», «Otro tipo…» y «No: piden motivo».
   - La sugerencia sale de los tres primeros caracteres de los códigos que el tipo ya llena. En el caso alcanza a las 11 celdas: nueve por el código principal, y las dos de 22T4 porque 20TK ya llena 22T0 y 22T1 por sus llenos. Esto último lo leo de las cuentas: la sonda solo probó la sugerencia contra el código principal, que cubre 12 de las 16.
   - **No bloquea «Confirmar e importar».** Lo que no se declare sigue pidiendo motivo, como hoy.

**Lo que cambia:**

| Dónde | Hoy | Con «también llena» |
|---|---|---|
| El cruce, los grupos | 23, uno por código | uno por tipo principal: «45G1 · COTRB · LNH: 31 vacíos, 31 celdas (28 de 45G1 y 3 de 45G0)» |
| El cruce, los llenos | «tipo 45G1 en el listado, 45G0 en el plan» | no es una diferencia si el código del plan es uno de los declarados |
| La hoja, desde una celda 45G0 | los 40HC salen como «Otro grupo: pide motivo» | salen como de su grupo |
| «Asignar vacío» | «Pide motivo: La reserva … es de otro grupo (tipo 45G0)…» | «Revisado: tipo, celda y grupo coinciden con el plan.» |
| La celda ya cargada | «Revisar» | «Cargado» |
| El rótulo de esas celdas en Carga | «—» | su código, puerto y línea |

**Lo que no cambia:**
- **La fila guardada.** Su tipo sigue siendo el principal, así que la 1.0.2 arma con el listado nuevo los mismos 23 grupos. Lo declarado va en una clave nueva del listado, que la 1.0.2 no lee (`ExportList.fromJson`, `export_list.dart:372-387`).
- **El BAPLIE de salida.** El vacío asignado sale con el tipo de su fila, el principal (`departure_baplie_writer.dart:435`), aunque la celda fuera 45G0. Ninguna de las dos fuentes sabe el cuarto carácter del contenedor que subió.
- **No se guarda en el dispositivo:** viaja con el listado, como pide P3.

**Con el hallazgo 6 de la 10.85** (dos líneas con vacíos intercambiables): el mismo mecanismo serviría para la línea, pero no lo propongo aquí. Nadie lo pidió para el próximo piloto, y es otra pregunta para quien planifica. «Aceptar con motivo» queda para su tarea.

### Entre versiones

- La 1.0.2 abre el listado nuevo y no ve lo declarado: en esas 16 celdas pide motivo y marca «Revisar», como hoy. La versión nueva, no. **Los movimientos son los mismos.**
- La versión nueva abre un listado de la 1.0.2 sin nada declarado: todo como hoy, hasta que la oficina lo vuelva a importar.

### Las pruebas

Rojas contra `v1.0.2`: el respaldo repartido se propone con principal y «también»; un código sin dueño se sugiere por sus tres primeros caracteres y uno de cisterna no; el cruce une los grupos y no cuenta el tipo declarado como diferencia; la hoja, las celdas ofrecidas, la revisión y el estado derivado tratan el código declarado como del grupo; un listado con lo declarado, leído por el código de la 1.0.2, da los mismos 23 grupos; la salida no cambia.

### Lo que debe dar el caso A09

Con P1, y declarando los nueve códigos (seis por la sugerencia y los tres de cisterna a mano; así corrió la sonda):

| Grupo (tipo principal · descarga · línea) | Vacíos | Celdas | De qué códigos |
|---|---:|---:|---|
| 42G1 · COTRB · LNH | 63 | 63 | 42G1 62 y 42G0 1 |
| L5G1 · COTRB · LNH | 64 | 64 | L5G1 61 y L5G0 3 |
| 45R1 · JMKIN · LNH | 43 | 43 | |
| 45G1 · COTRB · LNH | 31 | 31 | 45G1 28 y 45G0 3 |
| 45G1 · JMKIN · LNJ | 24 | 24 | |
| 22G1 · JMKIN · LNJ | 10 | 10 | |
| 42U1 · JMKIN · LNH | 8 | 8 | |
| 42R1 · JMKIN · LNH | 9 | 9 | 42R1 6 y 42R0 3 |
| 22U1 · JMKIN · LNH | 6 | 6 | 22U1 5 y 22U0 1 |
| 22K2 · COCTG · LNH | 8 | 8 | 22K2 4, 22T4 2, 22T0 1 y 22T1 1 |
| 42P3 · JMKIN · LNH | 3 | 3 | |
| 22P3 · JMKIN · LNH | 1 | 1 | ya con número |
| 22R1 · JMKIN · LNH | 1 | 1 | ya con número |
| 45P3 · JMKIN · LNH | 2 | 2 | 45P3 1 y 45P4 1 |
| **14 grupos** | **273** | **273** | **los 14 cuadran** |

- Sin P1, con las 448 filas, cuadran 13 de 14: a 45G1 · COTRB le sobran los tres vacíos cancelados (34 para 31).
- Con P1 y P4, y con 22G0 y 22T6 declarados para los llenos: **ningún lleno con datos distintos, y el cruce queda limpio.** La sonda unió los grupos de los vacíos; lo de los llenos lo leo de sus cuentas (10, 1 y 6) y no lo corrió.
- Las 16 celdas dejan de pedir motivo.

## E2-P5. La matrícula repetida

### Qué pasa hoy, mirado en el banco

Un plan sintético que sale del caso cambiando un solo `EQD`: la misma matrícula en 018-01-82 (28.5 t) y en 018-00-82 (20.6 t), dos llenos que cargan en GTSTC. Son las mismas dos celdas que usó GLM; el generador es mío (`herramientas/plan_repetido_e2.py`). Banco Web de `v1.0.2`, a 360 × 800, de día, sin listado y sin cuenta. Diez capturas en `repetida-360-dia/capturas/`; ningún error de Flutter y ninguna petición fuera de `127.0.0.1`.

| Paso | Lo que se ve | Captura |
|---|---|---|
| El plan, en Lista | «438 contenedores · 271 celdas reservadas» y «Matrículas repetidas en EQD: 1 contenedor · revisa esas celdas con quien hizo el plan» | `rep-02` |
| Al tocar el aviso | «La misma matrícula viene en más de una celda. Un contenedor solo puede estar en una: pide el plan corregido antes de operar esas celdas.» y «‹matrícula›: 018-01-82 y 018-00-82» | `rep-03` |
| Bahía 18, en Contenido | «9 contenedores · 73 celdas reservadas · **148.2 t**»: lo que trae el archivo | `rep-04` |
| Bahía 18, en Carga | «9 contenedores · 73 celdas reservadas · **140.3 t**» y «Carga: **407** pendientes, **134** llenos, 273 vacíos» | `rep-05` |
| **Se toca la primera celda, 018-01-82** | **nada.** No abre ningún diálogo ni dice nada | `rep-06` |
| **Se toca la segunda celda, 018-00-82** | «Confirmar carga» · «‹matrícula› · sin OR en el listado» · «Posición planificada: 018-00-82» · «Revisado: tipo, celda y grupo coinciden con el plan.» | `rep-07` |
| Se confirma | «Carga registrada · ‹matrícula›», la celda dice «Cargado» y la de al lado queda vacía; «Carga: 406 pendientes, 133 llenos, 273 vacíos» | `rep-08` |
| Se toca otra vez la primera | nada | `rep-09` |

- **La segunda celda se opera como cualquier lleno,** sin ningún aviso. Era lo que faltaba mirar.
- **La primera no responde nunca.** El contenedor que el plan quería ahí no existe para la operación: no se puede cargar, ni buscar, ni cancelar.
- **Ningún conflicto,** ni antes ni después de cargar.
- **Las 7.9 t que faltan en Carga** son 28.5 menos 20.6: la proyección pone dos veces el contenedor de la última celda (`loading_operation.dart:52-62`), porque el plan combinado guarda una sola pieza por matrícula (`operation.dart:307-317`). Contenido lee el archivo y da 148.2 t.
- **Lo que no miré:** con el listado importado, en Windows y el BAPLIE de salida. Leído en el código: la salida escribe un solo grupo para esa matrícula (`departure_baplie_writer.dart:67` y `:670-702`).

### La regla, completa

**Un plan con una matrícula en más de una celda no entra a la nube.** Leerlo y mirarlo, sí.

| Dónde | Qué pasa | Qué dice |
|---|---|---|
| Abrir el plan | Se lee y se ve, con su aviso. No cambia | lo de hoy |
| **«Publicar operación»** (`cloud_page.dart:263-285`) | **Se detiene antes de subir nada.** El botón queda apagado, con el texto debajo | «No se publica: el plan de carga («‹archivo›») trae 1 matrícula en más de una celda: ‹matrícula› en 018-01-82 y 018-00-82. Un contenedor solo puede estar en una. Pide el plan corregido a quien lo hizo y ábrelo de nuevo.» |
| **«Agregar a la operación»** (T-130; `operation_sources.dart:235-253` y `dialogo_agregar_plan.dart`) | Igual: no se agrega. El diálogo muestra el motivo y su botón queda apagado | el mismo texto, con «No se agrega» |
| **El plano de llegada** | La misma regla. Se pierde una descarga por la misma causa (`operation.dart:295-305`) | el mismo texto, con «el plano de llegada» |
| La operación que vive solo en el dispositivo | **Se deja operar,** con el defecto a la vista (D11) | ver abajo |
| Una operación que ya se publicó así con la 1.0.2 | No se puede retirar. La versión nueva la enseña con su banda | la banda de abajo |

- Una matrícula que está una vez en el plano de llegada y una vez en el plan de carga **no es repetida:** es un contenedor de paso o una re-estiba.
- **En el dispositivo solo, no la bloqueo:** no hay otro equipo con quien divergir, y quitarle la operación a quien trabaja sin cuenta lo deja sin nada. A cambio, tres cosas:
  - una banda fija en Carga y en Descarga: «Plan con 1 matrícula repetida: una carga no se puede registrar. Pide el plan corregido.»;
  - la primera celda responde: «Matrícula repetida. El plan trae ‹matrícula› también en 018-00-82. Esta celda no se puede operar hasta abrir el plan corregido.»;
  - la ficha de la bahía en Carga da el peso del archivo, 148.2 t.
- **Abrir el plan corregido** reemplaza el anterior en la operación sin publicar (`operation_sources.dart:255-269`), y lo ya registrado sigue valiendo por su matrícula.
- **Descarto** cambiar la clave a `C:<matrícula>@<celda>` (3.3 de la entrega 1): toca los movimientos ya escritos y las reglas, y un contenedor en dos celdas es siempre un error del plan.

### Entre versiones, las pruebas y el caso

- No se guarda nada nuevo. La regla vive en el cliente de la oficina: una oficina en la 1.0.2 todavía puede publicar un plan así.
- Pruebas, rojas contra `v1.0.2`: publicar y agregar se rechazan con su texto, para el plan de carga y para el de llegada; la misma matrícula en llegada y en carga no bloquea; la operación local se guarda; la primera celda responde; el peso de la bahía es el del archivo.
- **El caso A09 no trae ninguna:** nada cambia con él.

## E2-P6. O-147-1, lo que queda al abrirse el teclado

Con el dato de Carlos (10.158): en el iPhone, por la Web y con el caso, la pantalla ya no se queda pegada. **No es lo que necesita el próximo piloto.** Lo que pidió saber es si hay un arreglo corto.

### Las opciones

| | Qué es | Archivos | Riesgo | Cuánto quita |
|---|---|---|---|---|
| **A · Guardar la huella del viaje** | `VesselVoyage` calcula su `hashCode` una vez, no en cada búsqueda del proveedor | uno: `vessel_voyage.dart`, cinco líneas | **bajo:** el viaje no cambia después de construirse, y no hallé en `lib/` ningún sitio que cambie sus listas | **medido, abajo** |
| B · Buscar el proveedor por el id del viaje | las tres familias (`loadingOperationProvider` y las de descarga y plan) dejan de usar el viaje como llave | 51 lecturas en 15 archivos; uno, `loading_operation_provider.dart`, está entre las rutas de `sprint-4` | **alto:** el id no cambia cuando cambian la geometría o la escala, así que el proveedor dejaría de rehacerse solo | no lo medí |
| C · Leer la operación una vez por plano, no por celda | la lectura sube de las celdas a la vista de la bahía | `bay_plan_view.dart` y sus celdas | medio | no lo medí |
| D · Que el plano no se rehaga al subir el teclado | la página de debajo no cambia de alto con una hoja abierta | `vessel_overview_page.dart`, que está entre las rutas de `sprint-4` | medio, y hay que mirarlo en el teléfono | no lo medí |

### La medida de A

El mismo instrumento de la entrega 1 (`medir`, sin tocarlo), el caso A09, la celda 018-10-88, 360 × 800, Chrome 157.0.8103.79, tres corridas de cada una y cada corrida con un arranque nuevo. La base es el banco de `v1.0.2`; el prototipo, el mismo con tres líneas más (`prototipo-huella.diff`). Milisegundos, de soltar el dedo a la pantalla dibujada:

| | Base (`v1.0.2`) | Con la huella guardada | Baja |
|---|---|---|---|
| Web · tocar la celda | 38.9 · 38.2 · 36.4 | 31.2 · 30.3 · 30.8 | 19 % |
| **Web · el teclado** | **152.9 · 153.8 · 154.5** | **80.7 · 81.0 · 82.8** | **47 %** |
| Web · una tecla | 22.6 · 22.0 · 23.3 | 16.2 · 18.4 · 15.9 | 26 % |
| Web, CPU ÷ 4 · tocar la celda | 158.9 · 155.6 · 156.9 | 132.5 · 132.7 · 137.7 | 15 % |
| **Web, CPU ÷ 4 · el teclado** | **693.4 · 656.3 · 687.5** | **391.0 · 391.1 · 391.8** | **42 %** |
| Web, CPU ÷ 4 · una tecla | 96.7 · 100.0 · 99.1 | 75.6 · 74.1 · 74.5 | 24 % |

- La base repite lo de la entrega 1 (145 a 148 ms y 698 a 735 ms).
- **Quita más del tercio que estimé:** casi la mitad de lo que queda al abrirse el teclado.
- Con el prototipo, la suite de la copia da **2280 de 2280.** `analyze` da una incidencia, `hash_and_equals`: pide que quien define `hashCode` defina también `==`. La versión de verdad lleva las dos líneas de `==`, que delegan en la de hoy, y queda en cero. Esa versión no la corrí.
- **No lo medí** en Windows, en un teléfono ni con un plan más grande que el del caso. El teclado del banco es simulado, como en la entrega 1.

### Mi respuesta

- **Sí hay un arreglo corto: A.** Un archivo, cinco líneas, medido, y no toca ninguna ruta de `sprint-4`.
- **«Sin riesgo» no lo puedo firmar yo.** Es la entidad que usa toda la app. Lo que tengo es la suite completa en verde y ningún sitio que cambie un viaje ya construido. Le falta su prueba propia y la mirada de quien acepte.
- **Recomiendo que A entre en la parte 2b,** no en lo que espera el piloto, con dos pruebas (la huella se calcula una vez; dos viajes iguales siguen siendo iguales) y la medida repetida por GLM.
- **B, C y D van con el frente de usabilidad del teléfono,** con su medida en el Honor. B no la recomiendo en ningún caso.
- Si Carlos prefiere no tocar la entidad ahora, no pasa nada: el teléfono del piloto ya no lo nota (D12).

## E2-P7. O-147-2 a O-147-5

### O-147-2 · La hoja ofrece vacíos que no caben

- **Hoy:** `rowsFor` no mira el largo (`loading_operation.dart:395-402`); el diálogo lo rechaza después (`load_check.dart:184-193`).
- **Es peor desde una celda de 20 pies.** Con el caso (`sonda-caso.json`, `p7`): desde 018-10-88, de 40 pies, la hoja ofrece 274 filas y 24 no caben; **desde 001-02-84, de 20 pies, ofrece 274 y no caben 250.** Solo ocho son de su grupo.
- **Propongo:** la hoja y la lista «Celda reservada» de «Asignar vacío» no ofrecen lo que no cabe por el largo, con la misma regla que ya usa la revisión (`nominalLength`, `load_check.dart:133-139`). Un tipo de largo desconocido se sigue ofreciendo.
- **El caso, con P1:** desde 018-10-88, 247 filas; desde 001-02-84, 24.
- **Costo:** una hora, con sus pruebas. Nada guardado.

### O-147-3 · El orden de la hoja no es el mismo en todos los clientes

- **Hoy:** el `sort` de la hoja ordena «su grupo primero» y no desempata (`loading_controls.dart:307-310`).
- **En la máquina virtual de Dart** (Windows), con el caso y desde 018-10-88, los primeros OR son 269, 284, 250, 251…: ni su grupo ni los demás van por OR. En la Web van 250, 251, 252… (entrega 1).
- **Android, no comprobado.** Hay cuatro emuladores en la máquina y compilé una app mínima que solo ordena el mismo patrón, pero no la pude instalar: el Pixel_8_Pro ya tiene una BayStream con otra firma, que no desinstalé, y en el Medium_Phone la instalación no terminó en ocho minutos. No quedó nada instalado. Lo que sé: Android corre el mismo `List.sort` de Dart que Windows, así que debería dar el orden de Windows.
- **Propongo:** desempatar por OR. Todos los clientes quedan con el orden de la Web, que es el que el muelle espera. Windows y Android cambian de orden, a mejor.
- **Costo:** media hora. Con P4, «su grupo» incluye los códigos declarados.

### O-147-4 · «448 filas en 5 agencias»

- **Hoy:** una sección («TRANSBORDOS», «VACIOS», «AGREGADOS») pisa el nombre de la agencia (`export_list_parser_service.dart:225-228`). Con el caso: AGENCIA 1 141, TRANSBORDOS 6, VACIOS 187, AGENCIA 2 53 y AGREGADOS 61.
- **Propongo:** la sección va en un campo aparte y no pisa la agencia. «AGREGADOS» sigue contándose sola, como decidió T-122 (10.50).
- **El caso:** «448 filas en 2 agencias» · «AGENCIA 1 S.A.: 334 (TRANSBORDOS 6, VACIOS 187)» · «AGENCIA 2 S.A.: 53» · «AGREGADOS: 61».
- **Lo que no sé y pregunto (D13):** si «TRANSBORDOS» y «VACIOS» son de la agencia de arriba. En el archivo están entre las dos agencias.
- **Entre versiones:** una clave nueva en la fila, que la 1.0.2 no lee. Con el listado nuevo, la 1.0.2 diría «3 agencias», que es más cierto que «5».
- **Costo:** una hora.

### O-147-5 · El grupo «sin número» con la posición mal formada

- **Hoy:** se pierde sin aviso (`baplie_parser_service.dart:593`). Lo probé cambiando una posición del caso por «01A0282»: 270 celdas reservadas en vez de 271, el aviso dice ««NO» en 270 celdas» y nada nombra la que falta.
- **Propongo:** el aviso de posición que ya existe, con otro sujeto: «Celda sin matrícula: «01A0282»». Es una clase de aviso que la 1.0.1 y la 1.0.2 ya leen.
- **Costo:** media hora.

O-147-6 no entra: va con el frente de usabilidad.

## E2-P8. El hallazgo 7 de la 10.151, evaluado

Son dos cosas distintas, con tamaños muy distintos.

### a) Una vez cerrada, no deja abrir otra con el mismo buque, viaje y puerto

- **Es un callejón, leído en el código.** `find` devuelve la operación publicada aunque esté cerrada (`operation_sources.dart:89-103`), y `save` contesta: «…ya está cerrada y sus BAPLIE no cambian. Para trabajar con este archivo, ábrelo como una operación nueva.» (`:208-218`). No hay cómo abrirla como nueva.
- **Y es la salida que la propia app recomienda:** «cierra la operación y publica una nueva con los planos correctos» (`:274-279`). Hoy esa instrucción no se puede seguir. En el piloto 3 se rodeó cambiando el viaje en el archivo.
- **Qué haría falta:** que una operación cerrada no cuente para un archivo nuevo. `find` prefiere la abierta; si solo hay una cerrada y el archivo es otro, nace una operación nueva, con otro id. Publicarla ya está permitido: la guarda de T-130 mira solo las abiertas, y las reglas de Firestore no cambian.
- **Qué arriesga:**
  - cuál operación se ve al abrir el archivo viejo: la cerrada, solo para mirar;
  - **un equipo en la 1.0.2 que tuvo la cerrada la sigue encontrando,** y no opera la nueva. Para esto, todos los equipos tienen que estar en la versión nueva;
  - la operación nueva empieza de cero: las marcas se quedan en la cerrada. El mensaje ya lo dice.
- **Costo:** de dos a tres horas, con sus pruebas. Lo leí; no lo ejecuté.

### b) Corregir el plan de una operación publicada y abierta

- Es «reemplazar un BAPLIE con revisión» de T-130 (3.2 de `docs/T130-RESULTADOS.md`): los trozos con revisión, una cláusula nueva en las reglas de Firestore, sus baterías en el emulador, la comprobación de que no haya movimientos vigentes de ese papel y el aviso al muelle.
- **Arriesga más que todo lo demás junto:** un BAPLIE es el contrato de las claves de los movimientos. Con versiones mezcladas, un equipo que no entiende la revisión se queda con el plan viejo y deriva otro estado.
- Es del tamaño de T-127. Toca Firebase de verdad, que publica Carlos.

### Mi recomendación

- **a) aquí, en la parte 2b.** Es un defecto, es chico y hace verdadera una instrucción que la app ya da.
- **b) en su propia tarea,** con su fase de diseño. Es lo que de verdad pide el muelle, porque el plan se corrige durante la escala, pero no cabe aquí.

## E2-P9. El conjunto

### 9.1 Una entrega o dos

**Dos partes, en la misma rama.** Primero lo que necesita el próximo piloto.

| Parte | Qué lleva, en este orden | Horas de reloj |
|---|---|---:|
| **2a · Lo que necesita el piloto** | P1, las filas canceladas | 2 |
| | P4, «también llena» | 2 |
| | P3, las equivalencias guardadas | 1.5 |
| | P2, el destino final | 1 |
| | O-147-2 y O-147-3, la hoja | 0.5 |
| | El banco, el caso en pantalla, las rojas, la suite, la copia limpia y el informe | 1.5 |
| | **Suma** | **8.5** |
| **2b · El resto** | P5, la matrícula repetida | 1.5 |
| | P8 a), abrir otra operación después de cerrar | 2.5 |
| | P6, la huella, con su medida | 1 |
| | O-147-4 y O-147-5 | 1.5 |
| | Las validaciones y el informe | 1 |
| | **Suma** | **7.5** |

- Son estimaciones. La referencia es la entrega 1, que me llevó unas dos horas y media de reloj con seis reglas.
- **Por qué P3 va en la 2a:** hoy no hay cómo quitar lo guardado, y las 33 del iPhone pueden mandar en el próximo listado si un puerto de trasbordo de ese viaje fue destino final en el anterior.
- **Por qué P2 va en la 2a:** el piloto termina con el BAPLIE de salida, y Carlos pidió que el destino salga.
- Cada parte tiene su revisión de Yov y su aceptación de GLM.

### 9.2 La versión

- De acuerdo con **`1.0.3+12`** y `msix_version: 1.0.3.0`. El último `versionCode` de Play es el 11.
- Si el piloto llega antes de que la 2b esté aceptada, la 2a se publica sola como 1.0.3 y la 2b sale como `1.0.4+13`. Si no, las dos van en la 1.0.3 (D15).

### 9.3 Entre versiones, punto por punto

| | La 1.0.2 abre lo que guarde la nueva | La nueva abre lo de la 1.0.2 | Con versiones mezcladas |
|---|---|---|---|
| P1 | Sí: el listado no cambia de forma. Cuenta las 40 como carga | Sí, y las lee canceladas sin reimportar | Un muelle en la 1.0.2 puede cargar una cancelada; la oficina lo ve como conflicto |
| P2 | Sí. Su salida no lleva `LOC+83` para lo cargado | Sí, también con filas de la 1.0.1 | La salida la genera la oficina, con la nueva |
| P3 | Sí: la tabla del dispositivo no cambia de forma | Sí; deja de usar los puertos | No aplica: es por dispositivo |
| P4 | Sí; no lee lo declarado y pide motivo en esas celdas | Sí; sin nada declarado, como hoy | Las mismas cargas; la 1.0.2 marca «Revisar» donde la nueva no |
| P5 | No guarda nada | Enseña la banda | Una oficina en la 1.0.2 todavía publica un plan con repetidas |
| P6 | No guarda nada | — | — |
| O-147-4 | Sí; no lee la sección | Sí; las filas viejas traen la sección como agencia, hasta reimportar | — |
| O-147-2, 3 y 5 | No guardan nada nuevo | — | — |
| P8 a) | **No:** quien tuvo la operación cerrada la sigue encontrando | Sí | **No se opera mezclado** |

**Lo que no se opera con versiones mezcladas:** un plan con «NO» (ya valía, 10.153) y, con P8 a), una operación publicada después de cerrar otra de la misma escala. Los tres clientes salen juntos.

### 9.4 Los archivos que voy a tocar

**Parte 2a:**
- `lib/features/vessel/domain/entities/export_list.dart`
- `lib/features/vessel/domain/entities/operation.dart`
- `lib/features/vessel/domain/services/export_list_cross_checker.dart`
- `lib/features/vessel/domain/services/loading_operation.dart`
- `lib/features/vessel/domain/services/load_check.dart`
- `lib/features/vessel/domain/services/loading_plan_progress.dart`
- `lib/features/vessel/domain/services/operation_state_deriver.dart`
- `lib/features/vessel/domain/services/departure_baplie_writer.dart`
- `lib/features/vessel/presentation/providers/export_list_providers.dart`
- `lib/features/vessel/presentation/pages/export_list_import_page.dart`
- `lib/features/vessel/presentation/pages/operation_progress_page.dart`
- `lib/features/vessel/presentation/pages/departure_baplie_page.dart`
- `lib/features/vessel/presentation/widgets/loading_controls.dart`
- `pubspec.yaml` (**cambia:** solo las dos líneas de la versión; `pubspec.lock` **no cambia**)
- `test/t132_departure_fidelity_test.dart` (gana esperas) y `test/support/t147_listado_support.dart`
- pruebas y accesorios nuevos, con el prefijo `t147e2_`, y el banco de `tool/t147_*`

**Parte 2b:**
- `lib/features/vessel/data/services/baplie_parser_service.dart`
- `lib/features/vessel/data/services/export_list_parser_service.dart`
- `lib/features/vessel/domain/entities/vessel_voyage.dart`
- `lib/features/vessel/domain/services/operation_sources.dart`
- `lib/features/vessel/presentation/pages/cloud_page.dart`
- `lib/features/vessel/presentation/widgets/dialogo_agregar_plan.dart`
- `lib/features/vessel/presentation/widgets/bay_plan_view.dart`
- `lib/features/vessel/presentation/widgets/resumen_del_modo.dart`

**Contra las 39 rutas que separan a `sprint-4` de `v1.0.2`: ninguno de esos archivos está entre ellas.**
- Las 14 de `lib/` son de la Lista, el buscador y las estadísticas de T-120, más `vessel_overview_page.dart`, `vessel_providers.dart` y `loading_operation_provider.dart`.
- **Esos tres son los que tengo cerca, y los evito a propósito.** P5 y P8 a) van en `operation_sources.dart` y en `cloud_page.dart`, no en `vessel_providers.dart`; y la opción B de P6, que tocaría `loading_operation_provider.dart`, no la propongo.
- `DESIGN.md` sí está entre las 39: no lo edito. Su texto va en mi informe, como en la entrega 1, y lo pone Yov al mezclar.
- Si al programar hace falta uno de esos tres, me detengo y lo digo antes.

No toco `lib/main.dart`, los dos archivos congelados, `SPRINT-4.md`, `AGENTS.md`, `CLAUDE.md`, `README.md`, `DESIGN.md`, el manual, las reglas de Firestore ni `.claude/`. Ninguna dependencia nueva.

### 9.5 Las pruebas y la aceptación

- **El piso es 2280** en esta rama y solo sube, sin omitidas. Cada punto trae las suyas, con su roja contra una copia de `v1.0.2`. `analyze`, en cero y sin ningún `// ignore:`.
- El corpus, antes y después, como en la entrega 1: de los trece `.edi` no debe cambiar la lectura de ninguno; de los dos listados, cambia el del caso.
- Al mezclar con `sprint-4`, el piso de la suma es 2393 más las nuevas.

**Lo que debe repetir quien acepte, con el caso A09 y mirando la pantalla** (10.151), con el teléfono primero:
1. El listado: «408 para cargar: 135 llenos y 273 vacíos» y «40 canceladas…», con sus cuatro cuentas.
2. Las equivalencias: seis pendientes; 20ST, 20TK y 40HC, propuestas con sus códigos.
3. La tarjeta de las celdas sin dueño, y el cruce después de declararlas: 135 de 135, 273 de 273 en 14 grupos, los 14 con su marca de que cuadran, y ningún lleno con datos distintos.
4. La hoja desde 018-10-88: sin los OR 156, 168 y 182, por OR, y sin vacíos de 20. Desde una celda de 20, solo vacíos de 20.
5. Un vacío 40HC en una celda 45G0: sin motivo y sin «Revisar».
6. Con una segunda importación en el mismo equipo: las equivalencias guardadas, la tarjeta para quitarlas, y una sembrada que el plan contradice, que no se usa.
7. Un listado sintético que cancela una fila ya cargada: la tarjeta, el conflicto y la salida.
8. El BAPLIE de salida después de un lleno y un vacío con POD distinto: sus dos `LOC+83`, releídos con «Destino final» en el detalle; y las 40 con «cancelado en el listado».
9. En la 2b: el plan sintético con la matrícula repetida, al publicar; la medida de P6 con el mismo instrumento; y cerrar una operación y abrir otra del mismo viaje.

### 9.6 `DESIGN.md` y el manual

**`DESIGN.md`:** una sección 17.7, «Los defectos del piloto 4, entrega 2», con los textos de esta propuesta que queden aprobados: el resumen con las canceladas y la nota sin reconocer; las dos tarjetas nuevas de la importación (celdas sin dueño y equivalencias guardadas) y los dos orígenes nuevos de una equivalencia; el conflicto «cancelado en el listado»; la línea del destino final y los avisos de la salida; y la banda y los mensajes de la matrícula repetida. La pone Yov al mezclar.

**El manual de la 1.0.2** (`docs\MANUAL-USUARIO-1.0.2.md`, en `baystream-rediseno`; no lo edité):

| Sección | Qué cambia |
|---|---|
| 3.2 El archivo y el previo | Un plan con una matrícula repetida se abre y se ve, pero no se publica |
| 5.2 La Lista | El aviso «Matrículas repetidas en EQD» dice qué impide |
| 7.3 Publicar desde la oficina | El plan con una matrícula repetida no se publica; qué hacer |
| 7.6 El avance | La línea de las canceladas del listado y el conflicto nuevo |
| 7.7 Agregar el plan de carga | No se agrega un plan con una matrícula repetida |
| 7.8 El listado de la agencia | Las canceladas y la nota sin reconocer; quién manda en una equivalencia y cómo se quitan las guardadas; «también llena»; las agencias y sus secciones |
| 7.9 Cargar por OR desde el muelle | La hoja no ofrece canceladas ni lo que no cabe, y va por OR; las celdas del mismo tipo con otro código ya no piden motivo |
| 7.11 Cerrar la operación | Después de cerrar se puede abrir otra de la misma escala |
| 8.2 El BAPLIE de salida | `LOC+83` con el destino final; «Filas que no cargaron» con la nota de la agencia |
| 10. Mensajes y qué hacer | Los mensajes nuevos, con su acción |
| 11. Glosario | «Cancelada en el listado», «Cancelado en la operación», «Destino final» y «También llena» |

### 9.7 Las decisiones que le tocan a Carlos

| | La decisión | Mi recomendación |
|---|---|---|
| D1 | Una nota en MARCHAMO que no dice CANCEL y no parece un marchamo | Se carga y se avisa; no se da por cancelada |
| D2 | Un lleno que el plan trae y el listado cancela, en el muelle | No se registra; la agencia corrige el listado |
| D3 | Reconocer la cancelación también en CONTENIDO | Sí: T-132 ya lo hace |
| D4 | `LOC+83` también para los vacíos | Sí: el plan del caso lo hace con 40 de los suyos |
| D5 | Un POD sin forma de UN/LOCODE | No se escribe, y se avisa |
| D6 | El plan trae un `LOC+83` distinto del listado | Manda el listado, con un aviso; sin pedir que se elija |
| D7 | A qué se atan las equivalencias guardadas | Al dispositivo, solo tipos y líneas, y nunca contra el plan (opción A) |
| D8 | Las 33 de puerto del iPhone | Dejan de usarse y se quitan desde la tarjeta; no se borran solas |
| D9 | Un tipo con varios códigos | «También llena», declarado al importar; «Aceptar con motivo», en su tarea |
| D10 | Con el respaldo repartido (40HC: 60 y 10) | Se propone sola, con el más frecuente como principal |
| D11 | La matrícula repetida | No entra a la nube, ni al publicar ni al agregar, llegada incluida; en el dispositivo solo, se opera con la banda |
| D12 | O-147-1 | La huella guardada, en la parte 2b; lo demás, con el frente de usabilidad |
| D13 | ¿«TRANSBORDOS» y «VACIOS» son de la agencia de arriba? | Sí, y «AGREGADOS» se cuenta sola. Lo sabe Carlos, no yo |
| D14 | El hallazgo 7 | Abrir otra después de cerrar, en la 2b; corregir el plan de una operación abierta, en su propia tarea |
| D15 | Una versión o dos | Dos partes en la rama; una sola 1.0.3 si el piloto da tiempo, y 1.0.4 para la 2b si no |

## E2-10. Lo que no hice o no pude comprobar

- **Android:** el orden de la hoja en un emulador (E2-P7). No toqué el Honor: no estaba conectado.
- **Los equipos de Carlos:** no vi lo guardado en el iPhone ni en la laptop.
- **Los prototipos:** solo el de la huella. Las reglas de P1 a P5 están probadas como cuentas sobre el caso, no como código del producto.
- **P2 con las 408 cargas** y **P4 en los llenos:** son lo que da la regla; la sonda no los corrió.
- **P8:** leído en el código, sin ejecutar.
- **Windows:** no compilé el banco de Windows en esta fase. Todo lo de pantalla es de la Web del banco.
- No abrí la BayStream instalada, `%LOCALAPPDATA%\BayStream` ni ningún paquete MSIX. No usé Firebase.

**Lo que queda en `%TEMP%\t147-e2\`:** las dos copias limpias, `s4` (`9d6c199`, intacta) y `v102` (`v1.0.2` más dos sondas, una app mínima y el escenario `repetida` en `tool/`; `vessel_voyage.dart` volvió a su estado y lo cotejé con el commit). Son 2.9 GB y se pueden borrar después de la revisión. Borré el plan sintético y los tres perfiles de Chrome. En `build/t147/e2/propuesta/` hay 2.4 MB, sin ningún archivo del caso.

## E2-11. Git (lo ejecuta Carlos)

```powershell
git add -- docs/T147-RESULTADOS.md
git commit -m "Sprint 4: T-147, entrega 2: la propuesta"
git push origin t147-piloto4
```

Es una sola ruta. `windows/flutter/generated_plugin_registrant.*` y `generated_plugins.cmake` siguen como en la entrega 1, con otros saltos de línea y el mismo contenido: no van.

## E2-12. En tres líneas

1. El paso 0 sale limpio (`analyze` en cero y 2393 de 2393 en `9d6c199`), y la propuesta cubre los nueve puntos con sus cifras del caso A09, leídas con el lector del producto.
2. Las 40 canceladas se reconocen por la palabra CANCEL, el destino final sale en `LOC+83`, lo guardado deja de mandar y, declarando qué códigos llena cada tipo, los 23 grupos del caso quedan en 14 que cuadran.
3. Propongo dos partes en la rama, 15 decisiones para Carlos y la versión `1.0.3+12`; no cambié código.

## E2-13. Para Yov

> Yov: la propuesta de la entrega 2 de T-147 está al final de `docs/T147-RESULTADOS.md`, sin commit; la evidencia, en `build/t147/e2/propuesta/`. No toqué `lib/`, `test/`, `tool/` ni `pubspec.*`.
>
> Paso 0: en una copia limpia de `9d6c199`, `analyze` da «No issues found!» y la suite, `+2393: All tests passed!`, sin omitidas. Las rutas que separan a `sprint-4` de `v1.0.2` son 39, no 38; ninguno de los archivos que propongo tocar está entre ellas.
>
> Cinco cosas para que mires:
> 1. **P4 cambia de lectura:** las 16 celdas «de otro grupo» son exactamente lo que les sobra a siete grupos. Con «también llena», los 23 grupos quedan en 14 y los 14 cuadran; con P1, el cruce del caso sale limpio. Lo de los llenos (17 → 0) lo leo de las cuentas, no lo corrió la sonda.
> 2. **La importación del caso guarda 16 equivalencias, no nueve:** también las seis deducidas que traducen y `LGH` → `LNH`. Y lo guardado manda aunque el plan lo contradiga: lo sembré y no pregunta.
> 3. **La matrícula repetida:** la segunda celda se carga como cualquier lleno y la primera no responde nunca. Las 7.9 t que faltan son la proyección, que pone dos veces el contenedor de la última celda.
> 4. **P6:** guardar la huella quita del 42 al 47 % de lo que queda al abrirse el teclado (153 → 81 ms; 679 → 391 ms con la CPU ÷ 4), con la suite en 2280. La dejo en la 2b, por la 10.158.
> 5. **O-147-2 es peor de lo anotado:** desde una celda de 20 pies, la hoja ofrece 274 vacíos y 250 no caben.
>
> Lo que no pude: el orden de la hoja en Android (la app mínima no se instaló en el emulador) y ver lo guardado en el iPhone y en la laptop. P8 a), que una operación cerrada bloquea abrir otra de la misma escala, lo leí en el código y propongo arreglarlo en la 2b; corregir el plan de una operación abierta va en su tarea.

## E2-14. Las horas del reloj

| Tramo | Horas | Qué |
|---|---|---|
| 1 | hasta las 19:28 (no anoté el inicio; el primer registro del reloj es de las 19:26) | La punta, las huellas, las decisiones 10.85 a 10.158, los informes y el código |
| 2 | 19:28 a 19:39 | Las dos copias limpias, cotejadas, y el conteo de `LOC+83` en el plan |
| 3 | 19:39 a 19:40 | Ventana 1: `pub get` y `analyze` de `9d6c199` |
| — | 19:40 a 20:09 | Sin trabajo: la sesión quedó detenida hasta que Carlos pidió seguir |
| 4 | 20:09 a 20:12 | La suite de `9d6c199` y la ventana 2, la sonda del caso |
| 5 | 20:14 a 20:26 | Ventana 3: el banco, la matrícula repetida, la medida de O-147-1 (20:16 a 20:23) y la suite con el prototipo |
| 6 | 20:26 a 20:44 | El intento en los emuladores de Android, mientras redactaba |
| 7 | 20:44 a 20:48 | El resto de este informe y la limpieza de `%TEMP%` |

Cada ventana de Flutter y de Dart corrió con la luz verde de Carlos, que dio las tres de una vez, y con su línea `SEMÁFORO:` al empezar y al terminar.

---

# Entrega 2 · Parte 2a

Timonel · 20-nov-2026 · carpeta `C:\Proyectos\baystream-t147`, rama `t147-piloto4`, sobre `adbbefd` («Sprint 4: T-147, entrega 2: la propuesta»). Es la primera parte de la candidata **1.0.3+12** (MSIX `1.0.3.0`). No compilé ninguna Release de publicación, no publiqué y no ejecuté ninguna escritura de Git. No empecé la 2b.

El caso real (A09) se leyó desde la carpeta del corpus, fuera del repositorio. En el informe y en el repositorio van solo posiciones, códigos, números de orden y conteos; las pruebas usan datos sintéticos. La evidencia está en `build/t147/e2a/`, fuera de Git.

## E2a-0. En corto

- **Las cifras del caso coinciden todas con la propuesta,** leídas con el lector del producto y miradas en pantalla.
- **Lo que era cuenta, ahora está corrido:** las 408 cargas registradas, **470 `LOC+83`**, **408 de 408** con el código ISO que el plan trae para esa pieza, los llenos con datos distintos de 17 a **0**, y la sugerencia de 22T4, que es 20TK.
- **Con el caso, el cruce queda limpio:** 135 de 135 llenos, 273 de 273 vacíos en 14 grupos, y los 14 cuadran.
- **Suite 2357 de 2357** (2280 más 77 nuevas), sin omitidas, y `analyze` en cero, aquí y en una copia limpia.
- **Las rojas contra `v1.0.2`:** de las 77 nuevas, 60 fallan ahí y 17 pasan en los dos lados.
- **La hoja no quedó más lenta:** con la CPU frenada, 151 a 156 ms antes y 153 a 159 ms después.
- **Cuatro pruebas que ya existían cambian a propósito,** tres más de las que anuncié. Las explico en E2a-3.7. **Pido que Yov las mire.**
- **Dos lecturas mías del encargo que conviene confirmar:** qué quiere decir «dos tipos declaran el mismo código» (E2a-3.2) y cuándo sale «Guardada en este dispositivo» (E2a-3.3).

## E2a-1. Paso 0

| Comprobación | Resultado |
|---|---|
| Punta de la rama (`git log`, `git show --stat`) | `adbbefd`, «Sprint 4: T-147, entrega 2: la propuesta» |
| Decisiones 10.159, 10.160 y 10.161 | leídas en `baystream-rediseno\SPRINT-4.md` |
| Luz verde de Carlos | una sola ventana para toda la 2a, de las 21:45 a las 22:56 |

## E2a-2. Las rojas

Las cinco pruebas nuevas corrieron en una **copia pura de `v1.0.2`** (`git archive 99995db`, en `%TEMP%\t147-e2a\rojas`), con solo esos cinco archivos, su soporte y su accesorio copiados encima. **Compilan ahí:** lo que la 1.0.2 no tiene se lee con `dynamic`, así que fallan por comportamiento. Registros: `build/t147/e2a/rojas/`.

| Archivo de pruebas | Contra `v1.0.2` | Con el cambio |
|---|---|---|
| `test/t147e2_canceladas_test.dart` (P1) | 20 fallan, 4 pasan | 24 de 24 |
| `test/t147e2_tambien_llena_test.dart` (P4 y el cambio 4) | 11 fallan, 3 pasan | 14 de 14 |
| `test/t147e2_equivalencias_test.dart` (P3) | 10 fallan, 3 pasan | 13 de 13 |
| `test/t147e2_salida_test.dart` (P2 y el cambio 3) | 11 fallan, 5 pasan | 16 de 16 |
| `test/t147e2_hoja_test.dart` (O-147-2 y O-147-3) | 8 fallan, 2 pasan | 10 de 10 |
| **Suma** | **60 fallan, 17 pasan** | **77 de 77** |

Las 17 que pasan en los dos lados son las que fijan lo que no debía cambiar: un listado sin notas, un empate que se sigue preguntando, dos tipos con el mismo código principal, lo guardado que el plan no contradice, una fila guardada por la 1.0.1, el contenedor de paso con su grupo entero y un tipo de largo desconocido.

El listado guardado que usa la prueba de P1, `test/fixtures/t147e2_listado_guardado_por_la_102.json`, lo generó el código de `v1.0.2` en esa misma copia (`build/t147/e2a/fuente102/generar.dart.txt`).

## E2a-3. Lo que cambia, punto por punto

### 3.1 P1 · Las filas canceladas

**La expresión,** que es `ExportListRow.cancellationNote` (`export_list.dart`):

```
\bCANCEL(?:AD[OA]S?|LED|ED)?\b|\bROLEAD[OA]S?\b|\bYA EMBARCAD[OA]S?\b
```

- Se busca sobre el texto en mayúsculas, sin tildes y con un solo espacio, en MARCHAMO y, si no está, en CONTENIDO.
- **Reconoce:** CANCEL, CANCELADO, CANCELADA, CANCELADOS, CANCELADAS, CANCELLED y CANCELED; ROLEADO, ROLEADA, ROLEADOS y ROLEADAS; YA EMBARCADO, YA EMBARCADA, YA EMBARCADOS y YA EMBARCADAS.
- **No reconoce,** porque no es la palabra entera o no es ninguna de las tres: «CANCELACION», «ENROLEADO», «EMBARCADO» sin «YA», «REEMPLAZO» sin CANCEL. Sin cifras, esas se cargan y se avisan; con cifras, son un marchamo.
- De MARCHAMO sale la nota entera, como la escribió la agencia. De CONTENIDO sale solo la palabra, porque el resto es la descripción de la carga.

**El cambio:**
- La nota se calcula de lo que la fila ya guarda (`seal` y `contents`). **No hay clave nueva** en el listado.
- El resumen, las equivalencias y el cruce cuentan solo lo que se carga. El cruce lleva aparte las canceladas y, de ellas, las que el plan todavía carga.
- **No se ofrece:** `LoadingOperation.search` deja fuera la fila cancelada, salvo que se la busque por su OR o por su número. Con eso quedan fuera de la hoja, de «Asignar vacío», de la carga por OR y de «Corregir carga».
- **Se carga con motivo:** la revisión de la carga gana un aviso que no bloquea (`LoadIssueKind.listCancelled`).
- **Queda como conflicto** (`ConflictKind.cancelledInList`): cada equipo lo deriva del listado, igual que «otro grupo». Por eso sale solo cuando llega la revisión que cancela algo ya cargado, y se va con «Deshacer carga».
- El BAPLIE de salida dice la nota en «Filas que no cargaron», venga de MARCHAMO o de CONTENIDO, y avisa de la cancelada que está a bordo.

**Los textos, ya sin ningún «No se registra»:**

| Dónde | Texto |
|---|---|
| Resumen del listado | «448 filas en 5 agencias · 408 para cargar: 135 llenos y 273 vacíos» |
| | «40 canceladas en el listado, que no se cargan: 37 llenos y 3 vacíos» |
| | «ROLEADO - CANCEL 24 · YA EMBARCADO -CANCEL 7 · CANCELADO 7 · REEMPLAZO - CANCEL 2» |
| Su desplegable | «Canceladas en el listado (40)», con «OR 22 · ‹matrícula› · lleno · «ROLEADO - CANCEL»» |
| Una nota sin reconocer | «1 fila trae en MARCHAMO una nota que no se reconoce: «PENDIENTE» (OR 12). Se carga. Si no se carga en este buque, pide a la agencia que diga CANCELADO y vuelve a importar el listado.» |
| Cruce | «40 canceladas en el listado: el plan no carga ninguna» |
| Cruce, si el plan carga alguna | «1 cancelada en el listado que el plan todavía carga», su lista «OR 1 · ‹matrícula› · 015-03-02» y «Cancela su embarque desde el detalle de la celda o pide el plan corregido. Si alguna sube, el muelle la registra con motivo.» |
| Filas del listado | «Cancelada en el listado: «ROLEADO - CANCEL»», donde decía «Marchamo …» |
| La hoja, al buscarla | bajo la fila, «Cancelado en el listado: pide motivo» |
| «Confirmar carga» y «Asignar vacío» | «Pide motivo: el listado lo marca cancelado («ROLEADO - CANCEL»). Si sube a bordo, escribe el motivo: la oficina lo verá como conflicto.» |
| La celda del lleno que el plan trae y el listado cancela | la marca «Revisar»; etiqueta accesible, «cancelado en el listado, revisar» |
| Importar una revisión | «1 contenedor ya cargado queda cancelado en el listado nuevo» y «Ya cargados que el listado nuevo cancela (1)» |
| Avance | «Listado: 40 filas canceladas, que no se cargan (37 llenos y 3 vacíos).» |
| Avance, en Conflictos | «OR 1 · ‹matrícula› se cargó y el listado lo marca cancelado («CANCELADO»). Si el registro fue un error, deshazlo desde el detalle de la celda.» |
| Salida, «Filas que no cargaron» | «OR 22 · ‹matrícula› · cancelado en el listado («ROLEADO - CANCEL»)» |
| Salida, «Avisos de la salida» | «OR 1 · ‹matrícula›: está a bordo y el listado lo marca cancelado («CANCELADO»).» |

**En pantalla,** con el caso: el resumen (`…-01-listado-resumen.png`), el cancelado que solo sale al buscarlo (`…-09-hoja-al-buscar-un-cancelado.png`), la revisión (`…-23-revision-lo-ya-operado.png`), la celda en «Revisar» (`…-25-…`), el avance (`…-27-avance-conflictos.png`) y la salida (`…-28-…`).

**Un detalle que conviene saber:** una fila cancelada que ya se cargó sí se ve en la hoja, como «Ya cargado»: está a bordo.

### 3.2 P4 · «También llena», con los cambios 3 y 4

**El cambio:**
- El listado guarda, en una clave nueva, `typeFamilies`, cada código de más con el principal de su tipo: `{45G0: 45G1}`. **La fila no cambia:** su tipo sigue siendo el principal.
- **La clave solo se escribe si hay algo declarado.** Un listado sin «también llena» se guarda byte por byte como lo guardaba la 1.0.2.
- El grupo de un código es el de su tipo principal en los seis sitios que nombraba la propuesta: el cruce, la diferencia de tipo de un lleno, las celdas que se ofrecen, la revisión de la carga, la hoja y el conflicto «otro grupo». Todos preguntan a un solo lugar, `OperationPlan.sameGroup` y `groupType`.
- **Con el respaldo repartido se propone sola** (D10): el más repetido es el principal y los demás van a «también llena». **Con un empate se sigue preguntando,** como hasta la 1.0.2.
- **Las celdas sin dueño** se enseñan en una tarjeta, con su sugerencia: el grupo que ya llena un código con los mismos tres primeros caracteres. Mira todos los códigos del tipo, no solo el principal: por eso 22T4 se sugiere para 20TK, que ya llena 22T0 y 22T1 por sus llenos.
- Declarar no es obligatorio y no detiene la importación.
- **No se guarda en el dispositivo:** viaja con el listado, y la revisión siguiente lo recuerda.

**El cambio 4, «un código del plan, un solo tipo del listado».** Si dos tipos declaran el mismo código, «Confirmar e importar» queda apagado y la pantalla dice cuáles, arriba de las equivalencias y al pie:

> «45G0 lo declaran dos tipos: 40HC (45G1) y 45HC (45G0). Un código del plan lo llena un solo tipo: corrige uno con el lápiz o quita el «también llena» que sobra.»

**Mi lectura, para que Yov la confirme:** chocan dos tipos cuando sus códigos **principales son distintos.** Dos tipos del listado con el mismo principal son un solo grupo y no chocan. Si chocaran, un listado que dice «40HC» y «40HQ» para el mismo 45G1 no se podría importar, y hoy sí se puede. Lo fija una prueba.

**El cambio 3, el código ISO en la salida** (`OperationPlan.shippedType`): una carga sale con el código que el plan trae para esa pieza, el de su grupo de segmentos si es un lleno y el de su celda si es un vacío asignado, cuando el tipo de su fila lo llena. Si no, sale el de la fila, como hasta la 1.0.2, y el cruce lo cuenta como dato distinto. **La Lista enseña el vacío asignado con ese mismo código,** para que diga lo que dirá la salida.

**Los textos:**

| Dónde | Texto |
|---|---|
| La propuesta repartida | «Propuesta: 60 contenedores van a 45G1 y 10 a 45G0. 40HC llena los dos.» Con más de dos: «…20TK llena todos.» |
| Bajo la equivalencia | «También llena:» y una ficha por código, que se quita con su «✕» |
| La tarjeta | «Celdas reservadas que ningún tipo del listado llena (11)» y «Al cargar piden motivo, salvo que digas qué tipo del listado las llena. No detiene la importación.» |
| Cada código | «L5G0 · 3 celdas. ¿Las llena 45HC (L5G1)?», con «Sí», «Otro tipo…» y «No: piden motivo» |
| Sin sugerencia | «49P9 · 1 celda. Ningún tipo del listado se le parece.» |
| El cruce | «45G1 · COTRB · LNH: 31 vacíos, 31 celdas (28 de 45G1 y 3 de 45G0)» |

**En pantalla,** con el caso: las tres propuestas repartidas (`…-02-equivalencias.png`), la tarjeta con sus seis sugerencias (`…-03-celdas-sin-duenio.png`), el cruce (`…-05-cruce.png`) y un vacío 40HC en una celda 45G0, la 030-04-06, con «Revisado: tipo, celda y grupo coinciden con el plan.» y sin «Revisar» después (`…-12-…` y `…-13-…`).

### 3.3 P3 · Las equivalencias guardadas

**El cambio** (`ExportListCrossChecker.propose`):

| Quién manda | Origen | La pantalla dice |
|---|---|---|
| 1. El plan, con un solo código o con uno más repetido | `inferred` | «Propuesta: …» |
| 2. La revisión anterior del listado de esta operación | `previous` (nuevo) | «De la revisión anterior de este listado.» |
| 3. El dispositivo, solo tipos y líneas | `saved` | «Guardada en este dispositivo.» |
| 4. El plan carga ese mismo código | `samePlanCode` | «Propuesta: el plan carga … con ese mismo código.» |
| 5. Nada de lo anterior | `pending` | pendiente |

- Lo de 2 y 3 **solo vale si el plan no lo contradice:** el plan carga ese código en la escala y los contenedores no dan otro.
- **Los puertos del dispositivo ya no se leen ni se escriben.** Los que haya de versiones anteriores no se tocan: se quitan desde la tarjeta.
- Lo guardado que no se usó se dice, con el porqué, en tres formas:
  - «En este dispositivo estaba guardada 40ST → 45G1, y el plan dice 42G1 (1 contenedor): no se usó.»
  - «…estaba guardada 45HC → L5G9, y el plan no carga L5G9 en esta escala: no se usó.»
  - «…estaba guardada 45HC → L5G0, y la revisión anterior de este listado usa L5G1: no se usó.»
- **La tarjeta,** al final de «Listado de la agencia», esté o no leído un listado: «Equivalencias guardadas en este dispositivo (16)», cada una con «Quitar»; «De puerto, de versiones anteriores (33): ya no se usan.», con «Quitar las 33»; «Quitar todas», y «Quitar una equivalencia no cambia ningún listado ya importado.» Recogida dice «Se usan en el próximo listado, si el plan no dice otra cosa.»
- Quitar una con un listado leído vuelve a proponer, sin perder lo que la oficina ya eligió.
- **Con un equipo sin nada guardado no hay tarjeta.**

**Una consecuencia de la fila 2, para que Yov la confirme.** Al importar otra vez **en la misma operación,** lo elegido sale como «De la revisión anterior de este listado.», no como «Guardada en este dispositivo.»: la revisión anterior va antes. «Guardada en este dispositivo» sale con otra operación, es decir, en el próximo viaje. Con el caso, la segunda importación da cero pendientes de las dos formas. El punto 6 de E2-9.5 lo decía con «guardadas»; en pantalla, la segunda importación del recorrido dice «revisión anterior», y lo guardado se ve en su tarjeta.

**En pantalla,** con el caso: la segunda importación (`…-19-…`), la tarjeta con sus 16 (`…-20-guardadas-en-este-dispositivo.png`) y una guardada que el plan contradice, sembrada por el conductor (`…-21-…`).

### 3.4 P2 · El destino final en `LOC+83`

**El cambio** (`DepartureBaplieWriter._loaded`), como en la propuesta:
- `LOC+83+<POD del Excel>:139:6` cuando la fila trae POT y POD distintos, el POD tiene forma de UN/LOCODE (`formaDeUnLocode`) y no es el código que ya sale en `LOC+11`.
- Va como viene en el Excel, sin pasar por las equivalencias de puerto. Vale igual para los vacíos.
- Su lugar es justo detrás de `LOC+11`, o de `LOC+13` si lo hay. Si el plan ya traía uno, se cambia en su mismo lugar.
- Si el plan trae el mismo destino, el grupo no cambia. Si trae otro, manda el listado y se avisa. Si el POD no tiene la forma, no se escribe, se avisa, y lo del plan se conserva.
- **`LOC+11` sigue siendo el POT** (10.153), y lo que sigue a bordo conserva su grupo entero.

| Dónde | Texto |
|---|---|
| La página de la salida | «169 cargas llevan su destino final (LOC+83), tomado del POD del listado.» |
| Avisos de la salida | «OR 4 · ‹matrícula›: destino final ITLIV, del listado; el plan decía ITGOA.» |
| | «OR 5 · ‹matrícula›: el POD «SAJ» del listado no tiene forma de UN/LOCODE; el destino final no se escribió.» |

**En pantalla,** con el caso: el lleno OR 1 con «POT COCTG · POD SAJED» (`…-14-confirmar-lleno.png`), el vacío OR 148 con «POT COCTG · POD BRPNG» (`…-16-…`) y la página de la salida con «2 cargas llevan su destino final…» (`…-17-salida.png`). **El «Destino final» en el detalle del contenedor no lo miré en pantalla:** lo comprobé con el lector, que relee la salida del caso y da el POD del listado en las 169 (E2a-4).

### 3.5 O-147-2 · La hoja no ofrece lo que no cabe

**El cambio:** `LoadingOperation.fits` usa la misma regla que la revisión de la carga, y la aplican `rowsFor`, `slots` y `candidateSlots`: la hoja y la lista «Celda reservada» no ofrecen un vacío donde no cabe por su largo. Un tipo de largo desconocido se sigue ofreciendo. Una prueba recorre todo lo que la hoja ofrece y comprueba que nada queda bloqueado por el largo.

### 3.6 O-147-3 · El orden de la hoja

**El cambio:** `rowsFor` entrega las filas ya en su orden, primero las del grupo de la celda y después las demás, y dentro de cada parte, por OR. La hoja deja de ordenar por su cuenta. **Es el mismo orden en la Web y en Windows:** con el caso y desde 018-10-88, los dos empiezan 250, 251, 252…, donde Windows daba 269, 284, 250 con la 1.0.2.

### 3.7 Las pruebas que ya existían y cambian a propósito

Anuncié una, la de fidelidad de T-132. Son cuatro archivos. **Pido que Yov los mire.**

| Archivo | Qué cambia | Por qué |
|---|---|---|
| `test/t132_departure_fidelity_test.dart` | «POT igual al POD quita LOC+13; distinto lo escribe» **gana tres esperas** de `LOC+83` y no pierde ninguna. Y una línea esperada de «filas no cargadas» lleva la nota: «cancelado en el listado («CANCEL»)» | P2 y P1 |
| `test/t132_departure_page_test.dart` | la misma línea, con la nota | P1 |
| `test/t147_hoja_vacios_test.dart` | las dos referencias «como la 1.0.1» llevan, y lo dicen arriba, el desempate por OR y el largo. Lo demás sigue comparándose con la expresión de la 1.0.1 | O-147-2 y O-147-3: la entrega 1 pedía no cambiar lo que la hoja ofrece, y esta lo cambia a propósito |
| `test/t73_export_list_test.dart` | «una guardada que el plan contradice se marca» pasa a «…no se usa, y se dice» | P3: era justo el comportamiento que el hallazgo 3 de la 10.85 pide quitar |

### 3.8 La versión

`pubspec.yaml` cambia solo sus dos líneas: `version: 1.0.3+12` y `msix_version: 1.0.3.0`. `pubspec.lock` no cambia.

## E2a-4. El caso A09

`tool/t147e2_caso.dart` lee los dos archivos del caso con el lector del producto, declara las sugerencias, registra las 408 cargas y genera la salida (`build/t147/e2a/caso/caso-2a.json`).

| Lo que decía la propuesta | Lo que da el código | |
|---|---|---|
| 408 para cargar, 135 y 273; 40 canceladas, 37 y 3 | 408, 135 y 273; 40, 37 y 3 | coincide |
| Por nota: 24, 7, 7 y 2 | 24, 7, 7 y 2 | coincide |
| Los vacíos cancelados son los OR 156, 168 y 182 | 156, 168 y 182 | coincide |
| Tipos: 20ST 30, 40HC 125, 40RA 6 y 40RH 57 | los mismos | coincide |
| POT: COTRB 213, JMKIN 123, COCTG 66 y COBAQ 6 | los mismos | coincide |
| Seis tipos pendientes; 20ST, 20TK y 40HC, propuestos | 45HC, 20OT, 40FF, 40HF, 40OT y 40RF pendientes; los otros tres, propuestos con su «también llena» | coincide |
| 11 celdas sin dueño, las 11 con sugerencia | L5G0 3, 42R0 3, 22T4 2, 22U0 1, 42G0 1 y 45P4 1; **22T4 se sugiere para 20TK** | coincide, ya corrido |
| 135 de 135 llenos; ninguno fuera del plan | 135 de 135; 0 | coincide |
| 273 de 273 vacíos en 14 grupos, y los 14 cuadran | 273 de 273 en 14; cuadran 14 | coincide |
| Llenos con datos distintos: de 17 a 0 | **0** | coincide, ya corrido |
| Ninguna cancelada que el plan cargue | 0 de 40 | coincide |
| La hoja desde 018-10-88: 247 filas, sin los cancelados, por OR | 247; ninguna cancelada; 250, 251, 252… | coincide |
| La hoja desde una celda de 20 pies: 24 filas | 24, todas de 20 pies | coincide |
| Con las 408 cargadas: 470 `LOC+83` y ningún `LOC+13` | **470 y 0** | coincide, ya corrido |
| 169 cargas con destino final, 109 llenos y 60 vacíos | 169, 109 y 60 | coincide |
| Las 408 cargas, con el código ISO del plan (10.160) | **408 de 408;** 16 son vacíos en una celda de otro código de su tipo | coincide |
| Al dispositivo, 16: 15 tipos y una línea; ningún puerto | 15, 1 y 0 | coincide |

Los 14 grupos son los de la tabla de E2-P4, uno por uno, con sus códigos.

**Además, con las 408 cargas registradas:**
- 137 se registran como carga por su número (los 135 llenos y los dos vacíos que el plan trae con matrícula) y 271 como vacío asignado. **Ningún conflicto,** y cero pendientes al final.
- La salida trae 709 contenedores y se puede guardar. Releída con el lector: 709 contenedores, ninguna celda reservada, ningún aviso, y **en las 169 el destino final es el POD del listado.**
- «Filas que no cargaron»: 40, las 40 «cancelado en el listado».
- **Un dato por confirmar,** de una temperatura que el plan y el listado traen distinta. Es la regla de T-132; la herramienta eligió el plan para poder contar.

**En el dispositivo:** en la segunda importación, ninguna pendiente. Con «40ST → 45G1», «45HC → L5G9», «COTRB → JMKIN» y «`LGH` → `LNK`» sembradas: 40ST y la línea salen por el plan, 45HC queda pendiente y el puerto ni se lee.

**Lo que guarda el código nuevo lo abre la 1.0.2, corrido de verdad:** el listado del caso, guardado con sus 11 códigos declarados, lo abrió el código de `v1.0.2` en su copia y lo cruzó con el plan. Da las cifras de 4.4 del caso, las de hoy: 448 filas, 135 de 172, 37 fuera del plan, 276 de 276 en 23 grupos, cuadran 7 y 17 con datos distintos (`build/t147/e2a/caso/leido-por-la-102.json`).

## E2a-5. El caso en pantalla

**Seis recorridos de 29 capturas, 174 en total,** en `build/t147/e2a/recorrido/`. Los seis terminan en «fin», sin errores de Flutter, y registran lo mismo en sus pasos.

| Cliente | Tamaño | Tema | Peticiones fuera de `127.0.0.1` |
|---|---|---|---|
| Web | 360 × 800 | día y noche | 0 de 116 en cada uno |
| Web | 1366 × 690 | día y noche | 0 de 116 en cada uno |
| Windows | 360 × 800 | noche | no aplica |
| Windows | 1366 × 690 | día | no aplica |

El escenario es `recorrido2a`, nuevo en `tool/t147_conductor.dart`. `_medir`, `_cronometrar` y `_celdaReservada` no se tocaron. Recorre los puntos 1 a 8 de E2-9.5:

| Punto | Lo que se lee en la pantalla |
|---|---|
| 1. El listado | «448 filas en 5 agencias · 408 para cargar: 135 llenos y 273 vacíos», «40 canceladas…: 37 llenos y 3 vacíos» y las cuatro cuentas |
| 2. Las equivalencias | seis pendientes; 20ST, 20TK y 40HC, con «Propuesta: … llena los dos» o «…llena todos» |
| 3. Las celdas sin dueño y el cruce | «Celdas reservadas que ningún tipo del listado llena (11)», con sus seis sugerencias; aceptadas, «135 de 135 llenos cruzan con el plan», «273 de 273 vacíos en 14 grupos de reservas» y ningún «Llenos con datos distintos» |
| 4. La hoja | desde 018-10-88, 247 filas que empiezan 250, 251, 252…; al buscar «156», el OR 156 con «Otro grupo: pide motivo» y «Cancelado en el listado: pide motivo»; desde una celda de 20 pies, 24 filas, todas de 20 |
| 5. Un vacío 40HC en una celda 45G0 | «Reservas libres del mismo tipo, puerto y línea.» y «Revisado: tipo, celda y grupo coinciden con el plan.»; queda «Cargado», sin conflicto |
| 6. La segunda importación | ninguna pendiente; «Equivalencias guardadas en este dispositivo (16)»; con una sembrada, «…estaba guardada 40ST → 45G1, y el plan dice 42G1 (1 contenedor): no se usó.» |
| 7. La revisión que cancela el OR 1, ya cargado | «1 contenedor ya cargado queda cancelado en el listado nuevo»; la celda, en «Revisar»; en el avance, «Conflictos · 1» con su línea, y «Listado: 41 filas canceladas…» |
| 8. La salida | «2 cargas llevan su destino final (LOC+83)…»; «Filas del listado que no cargaron (445)», 40 de ellas «cancelado en el listado»; y, después de la revisión, «OR 1 · ‹matrícula›: está a bordo y el listado lo marca cancelado («CANCELADO»).» |

**Miré once capturas.** Seis son de una corrida de prueba a 360 × 800 de día, con el mismo banco, que después borré: el resumen, las celdas sin dueño, el cancelado al buscarlo, el vacío en la celda 45G0, la revisión y lo guardado. Cinco son de las corridas definitivas: el cruce a 1366 × 690 de noche, la celda en «Revisar» a 360 × 800 de noche, el avance y la salida a 360 × 800 de día, y la hoja en Windows. Dicen lo que dice la tabla.

**La revisión del punto 7** no es un listado inventado: es el del caso con una sola celda cambiada, «CANCELADO» en el MARCHAMO del OR 1. La hace `tool/t147e2_listado_revisado.py`, fuera del repositorio, y la borré al terminar.

## E2a-6. La medición

El instrumento de la entrega 1, sin tocar: el escenario `medir`, el caso A09, la celda 018-10-88, 360 × 800, Chrome 157.0.8103.79, y cada corrida con un arranque nuevo. «Antes» es el banco de `v1.0.2`; «después», el de esta entrega. Milisegundos, de soltar el dedo a la pantalla dibujada (`build/t147/e2a/medicion.json`).

| | Antes (`v1.0.2`) | Después (2a) |
|---|---|---|
| Web · tocar la celda | 44.6 · 43.0 · 43.6 | 40.8 · 43.2 · 43.7 |
| Web · el teclado | 183.4 · 172.1 · 175.7 | 162.3 · 182.8 · 164.0 |
| Web · una tecla | 29.2 · 27.5 · 27.7 | 24.7 · 28.4 · 24.0 |
| Web, CPU ÷ 4 · tocar la celda | 160.8 · 206.5 · 206.0 | 159.4 · 220.7 · 208.7 |
| Web, CPU ÷ 4 · el teclado | 672.2 · 994.2 · 1001.2 | 674.3 · 1039.5 · 980.6 |
| Web, CPU ÷ 4 · una tecla | 99.3 · 136.4 · 138.5 | 91.4 · 141.9 · 140.2 |
| **Web, CPU ÷ 4, alternadas · tocar la celda** | **151.4 · 151.5 · 155.7** | **153.0 · 153.8 · 158.8** |
| Web, CPU ÷ 4, alternadas · el teclado | 647.6 · 667.1 · 666.2 | 654.2 · 664.2 · 661.1 |
| Web, CPU ÷ 4, alternadas · una tecla | 91.9 · 94.5 · 95.8 | 94.7 · 96.9 · 97.2 |

- **La 2a no deja la hoja más lenta.** Con la CPU frenada, la hoja sigue dibujada muy por debajo de medio segundo.
- **En la primera serie, la máquina cambió de paso** entre la primera corrida y las otras dos, igual en «antes» y en «después» (de 160 a 206 ms). Por eso corrí tres más de cada una, **alternando antes y después.** En esa serie la diferencia es de 2 a 3 ms al tocar la celda, del 1 al 2 %: no la puedo separar del ruido.
- La hoja ofrece ahora 247 filas donde ofrecía 274.
- No medí en Windows ni en un teléfono, y el teclado es simulado, como en la entrega 1.

## E2a-7. El corpus, antes y después

`tool/t147_corpus.dart`, con el lector de `v1.0.2` y con el de la entrega (`build/t147/e2a/corpus/comparacion.txt`):

| Archivo | Lectura |
|---|---|
| Los trece `.edi`: A01, A02, A03, A03v, A04, A05, A06, A07, A08, A08v, A09, `PRUEBA_NIVEL_78` y `PRUEBA_NIVEL_80` | **igual** |
| `LISTADO_A08.xlsx` contra A08 | **igual** |
| `LISTADO_A09.xlsx` | distinto: de 9 a 6 pendientes, y ningún lleno fuera del plan donde había 37 |

Cambia solo el listado del caso, que es lo que se buscaba. El lector de BAPLIE no se tocó.

## E2a-8. Las validaciones

Todo después del último cambio de `lib/`, `test/` y `tool/`. Registros: `build/t147/e2a/final/`.

| Dónde | `flutter analyze`, todo el paquete | Suite completa, una corrida |
|---|---|---|
| Aquí (22:50 a 22:52) | **«No issues found!»** | **`+2357: All tests passed!`**, sin omitidas ni fallidas |
| Copia limpia en `%TEMP%\t147-e2a\limpia` (22:52 a 22:55) | **«No issues found!»** | **`+2357: All tests passed!`**, sin omitidas ni fallidas |

- La copia limpia es `git -c core.autocrlf=false archive adbbefd`, más los 19 archivos cambiados y los 9 nuevos, copiados de la carpeta y cotejados por su huella (`copia-limpia-manifiesto.json`), más la entrada de T-124. Ahí corrí `flutter pub get --offline --enforce-lockfile`: su `pubspec.lock` queda igual al del commit.
- **El piso sube de 2280 a 2357:** 77 pruebas nuevas, ninguna quitada ni omitida.
- Ningún `// ignore:`. Ninguna dependencia nueva.
- Después de esas corridas escribí solo este informe.
- Nunca `flutter test --platform chrome`.
- **Una trampa que encontré:** `analyze` lee los `.dart` de `build/`. Tres copias que dejé en la evidencia de la propuesta daban dos errores falsos; las renombré a `.dart.txt`. No son del repositorio.

## E2a-9. Entre versiones

- **El listado guardado:** una sola clave nueva, `typeFamilies`, y solo si hay algo declarado. **La 1.0.2 lo abre y arma sus grupos de siempre:** lo corrí con el caso (E2a-4).
- **La versión nueva lee como cancelada** una fila que guardó la 1.0.1 o la 1.0.2, sin volver a importar: lo fija una prueba con un listado que generó el código de `v1.0.2`.
- **La tabla del dispositivo** no cambia de forma, y sus puertos no se tocan.
- **Lo demás no se guarda:** el conflicto «cancelado en el listado», el aviso de la revisión de la carga y el origen «revisión anterior» los deriva cada equipo.
- **Con versiones mezcladas:** un muelle en la 1.0.2 ofrece las canceladas y pide motivo en las 16 celdas de otro código, donde el nuevo no. Los movimientos son los mismos. La salida la genera la oficina, con la versión nueva. Los tres clientes salen juntos.

## E2a-10. `DESIGN.md` y el manual

### 10.1 `DESIGN.md`

**No lo edité:** está entre las rutas que separan a `sprint-4` de `v1.0.2`. El texto, para que Yov lo ponga al mezclar, como 17.7:

> **17.7 Los defectos del piloto 4, entrega 2, parte 2a (T-147; 10.159 a 10.161)**
>
> **El listado de la agencia.** El resumen separa lo que se carga de lo que la agencia cancela: «N filas en M agencias · P para cargar: X llenos y Y vacíos»; debajo, «C canceladas en el listado, que no se cargan: …», sus cuentas por nota y un desplegable «Canceladas en el listado (C)». Sin canceladas, el resumen es el de siempre. Una nota de MARCHAMO que no se reconoce va en el color de error, con su OR y qué hacer.
>
> **Las equivalencias.** Dos orígenes más: «De la revisión anterior de este listado.» y, con el respaldo repartido, «Propuesta: 60 contenedores van a 45G1 y 10 a 45G0. 40HC llena los dos.» Bajo la equivalencia, «También llena:» y una ficha por código, con su «✕». Lo guardado que no se usó se dice en una línea más: «En este dispositivo estaba guardada … : no se usó.» Un código que dos tipos declaran va en el color de error, arriba de las equivalencias y al pie, y apaga «Confirmar e importar».
>
> **Dos tarjetas nuevas.** «Celdas reservadas que ningún tipo del listado llena (N)», bajo las equivalencias, con una línea por código y tres fichas: «Sí», «Otro tipo…» y «No: piden motivo». Y «Equivalencias guardadas en este dispositivo (N)», al final de la página y recogida, con «Quitar» en cada una, «Quitar las N» para las de puerto y «Quitar todas». Sin nada guardado, no sale.
>
> **El cruce.** Con «también llena», la línea de un grupo dice de qué códigos son sus celdas: «…31 vacíos, 31 celdas (28 de 45G1 y 3 de 45G0)». Las canceladas van en su línea: «40 canceladas en el listado: el plan no carga ninguna», o, en el color de error, las que el plan todavía carga.
>
> **La carga.** Una fila cancelada no sale en la hoja «Vacíos del listado» ni en la carga por OR; si se la busca, sale con «Cancelado en el listado: pide motivo». El diálogo dice «Pide motivo: el listado lo marca cancelado («…»). …» y registra con el motivo. La celda queda con la marca «Revisar» (13.3), y el avance la lista en Conflictos. Bajo las notas del avance, «Listado: N filas canceladas, que no se cargan (…).»
>
> **La hoja «Vacíos del listado».** No ofrece un vacío donde no cabe por su largo. Primero los del grupo de la celda y después los demás; dentro de cada parte, por OR, igual en todos los clientes. Una celda de un código que su tipo también llena es de su grupo: no dice «Otro grupo: pide motivo».
>
> **El BAPLIE de salida.** Una línea con la cuenta, «N cargas llevan su destino final (LOC+83), tomado del POD del listado.», y en «Filas del listado que no cargaron», el motivo con la nota: «cancelado en el listado («…»)».

### 10.2 Los pasos del manual de la 1.0.2 que cambian (no lo edité)

| Sección | Qué cambia con la 2a |
|---|---|
| 7.6 El avance | La línea de las canceladas del listado, y el conflicto «se cargó y el listado lo marca cancelado» |
| 7.8 El listado de la agencia | Lo que se carga y lo que la agencia cancela, con las tres notas; la nota sin reconocer; quién manda en una equivalencia; «también llena» y la tarjeta de las celdas sin dueño; que dos tipos no declaren el mismo código; la tarjeta de lo guardado y cómo se quita; importar una revisión que cancela algo ya cargado |
| 7.9 Cargar por OR desde el muelle | La hoja no ofrece canceladas ni lo que no cabe, y va por OR; cargar una cancelada con motivo; las celdas de otro código de su tipo ya no piden motivo |
| 8.2 El BAPLIE de salida | `LOC+83` con el destino final; el código ISO es el del plan cuando su tipo lo llena; «Filas que no cargaron» con la nota de la agencia |
| 10. Mensajes y qué hacer | Los mensajes nuevos, con su acción |
| 11. Glosario | «Cancelada en el listado», «Cancelado en la operación», «Destino final» y «También llena» |

Las secciones 3.2, 5.2, 7.3, 7.7 y 7.11 cambian con la 2b.

## E2a-11. Para quien acepte

Todo corre con el semáforo. `<corpus>` es la carpeta del corpus; el caso nunca se copia al repositorio.

**1. Las cifras del caso (E2a-4):**

```powershell
dart run tool/t147e2_caso.dart --plan "<corpus>\CORPUS_A09.edi" --listado "<corpus>\LISTADO_A09.xlsx" --salida build/t147/e2a/caso/otra.json
```

**2. Las rojas (E2a-2):** en una copia de `v1.0.2` de fuera del repositorio, copiar `test/t147e2_*_test.dart`, `test/support/t147e2_support.dart` y `test/fixtures/t147e2_listado_guardado_por_la_102.json`, y correr cada archivo. Tienen que fallar 20, 11, 10, 11 y 8. La copia que usé sigue en `%TEMP%\t147-e2a\rojas`.

**3. El corpus (E2a-7):** `tool/t147_corpus.dart` como en la entrega 1, con las dos carpetas y los dos listados, en la copia de `v1.0.2` y aquí, y después `--comparar`. Tiene que decir «igual» en todo menos en `LISTADO_A09.xlsx`.

**4. El banco y el recorrido en pantalla (E2a-5):**

```powershell
flutter build web --release --no-pub --no-web-resources-cdn -t tool/t147_main.dart --output=build/t147/e2a/banco/web
```

```powershell
python -X utf8 tool/t147e2_listado_revisado.py --origen "<corpus>\LISTADO_A09.xlsx" --salida "$env:TEMP\t147-e2a\caso\LISTADO_A09_REVISADO.xlsx" --orden 1
```

```powershell
python -X utf8 tool/t147_web.py --web build/t147/e2a/banco/web --caso "<corpus>" --caso2 "$env:TEMP\t147-e2a\caso" --salida build/t147/e2a/recorrido/otra-360-dia --perfil otra-360-dia --perfil-nuevo --ancho 360 --alto 800 --consulta "escenario=recorrido2a&plan=CORPUS_A09.edi&listado=LISTADO_A09.xlsx&listado2=LISTADO_A09_REVISADO.xlsx&escala=GTSTC&tema=dia&bahia=18&prefijo=otra-&elegir=tipo:45HC=L5G1,tipo:20OT=22U1,tipo:40FF=42P3,tipo:40HF=45P3,tipo:40OT=42U1,tipo:40RF=42R1"
```

- Cada corrida va en su carpeta de salida y con su perfil: el lanzador se niega a pisar una.
- Cambiar `--ancho 1366 --alto 690` y `tema=noche` para las otras combinaciones.
- En Windows, como en la entrega 1: `flutter build windows --release --no-pub -t tool/t147_main.dart`, copiar la Release a `%TEMP%` y usar `tool/t147_windows.py`, con una carpeta de `%TEMP%` que tenga los dos archivos del caso y la revisión.
- Sin `escenario`, el banco es la app para recorrerla a mano.

**5. La medición (E2a-6):** `escenario=preparar` y después `escenario=medir`, como en la sección 10 de la entrega 1. Los dos guiones que usé están en `build/t147/e2a/herramientas/`.

**Lo que conviene mirar con ojos propios:**
- las dos lecturas de E2a-3.2 y E2a-3.3;
- las cuatro pruebas de E2a-3.7;
- la tarjeta de las celdas sin dueño a 360 dp: con seis códigos ocupa más de una pantalla, porque las tres fichas de cada uno no caben en una línea.

## E2a-12. Lo que no hice o no pude

- **No lo probé en un iPhone ni en el Honor,** ni en un emulador de Android.
- **El «Destino final» en el detalle del contenedor,** releyendo la salida, no lo miré en pantalla: lo comprobé con el lector.
- **Windows:** dos recorridos de los cuatro tamaños y temas, y ninguna medición.
- **Miré once capturas;** de las 174 definitivas, cinco.
- La revisión del listado del recorrido es el del caso con una celda cambiada, no un listado sintético entero.
- No abrí la BayStream instalada, `%LOCALAPPDATA%\BayStream` ni ningún paquete MSIX. No usé Firebase.
- No toqué `vessel_overview_page.dart`, `vessel_providers.dart` ni `loading_operation_provider.dart`: no hizo falta.

## E2a-13. Los archivos

**Cambian (19):**
- `lib/features/vessel/domain/entities/export_list.dart`
- `lib/features/vessel/domain/entities/operation.dart`
- `lib/features/vessel/domain/services/departure_baplie_writer.dart`
- `lib/features/vessel/domain/services/export_list_cross_checker.dart`
- `lib/features/vessel/domain/services/load_check.dart`
- `lib/features/vessel/domain/services/loading_operation.dart`
- `lib/features/vessel/domain/services/loading_plan_progress.dart`
- `lib/features/vessel/domain/services/operation_state_deriver.dart`
- `lib/features/vessel/presentation/pages/departure_baplie_page.dart`
- `lib/features/vessel/presentation/pages/export_list_import_page.dart`
- `lib/features/vessel/presentation/pages/operation_progress_page.dart`
- `lib/features/vessel/presentation/providers/export_list_providers.dart`
- `lib/features/vessel/presentation/widgets/loading_controls.dart`
- `pubspec.yaml` (**cambia:** solo las dos líneas de la versión; `pubspec.lock` **no cambia**)
- `test/t132_departure_fidelity_test.dart`, `test/t132_departure_page_test.dart`, `test/t147_hoja_vacios_test.dart` y `test/t73_export_list_test.dart` (a propósito; E2a-3.7)
- `tool/t147_conductor.dart` (el escenario `recorrido2a`)

Los trece de `lib/` son los trece que anuncié en E2-9.4 para la 2a. **Ninguno está entre las 39 rutas** que separan a `sprint-4` de `v1.0.2`.

**Nuevos (9), más esta parte del informe:**
- `test/t147e2_canceladas_test.dart`, `test/t147e2_tambien_llena_test.dart`, `test/t147e2_equivalencias_test.dart`, `test/t147e2_salida_test.dart` y `test/t147e2_hoja_test.dart`
- `test/support/t147e2_support.dart`
- `test/fixtures/t147e2_listado_guardado_por_la_102.json`
- `tool/t147e2_caso.dart` y `tool/t147e2_listado_revisado.py`

No toqué `lib/main.dart`, los dos archivos congelados, `SPRINT-4.md`, `AGENTS.md`, `CLAUDE.md`, `README.md`, `DESIGN.md`, el manual, las reglas de Firestore ni `.claude/`.

**Fuera de Git, en la carpeta:** `build/t147/e2a/` (la evidencia, 65 MB, sin ningún archivo del caso) y `build/windows` (el banco de Windows; se puede borrar).

**En `%TEMP%`:** borré las copias del caso, la revisión del listado, los dos almacenes de Windows, la copia del banco y los ocho perfiles de Chrome. Quedan `%TEMP%\t147-e2a\rojas` y `limpia` (410 MB), sin nada del caso; se pueden borrar después de la revisión.

## E2a-14. Git (lo ejecuta Carlos)

```powershell
git add -- lib/features/vessel/domain/entities/export_list.dart
git add -- lib/features/vessel/domain/entities/operation.dart
git add -- lib/features/vessel/domain/services/departure_baplie_writer.dart
git add -- lib/features/vessel/domain/services/export_list_cross_checker.dart
git add -- lib/features/vessel/domain/services/load_check.dart
git add -- lib/features/vessel/domain/services/loading_operation.dart
git add -- lib/features/vessel/domain/services/loading_plan_progress.dart
git add -- lib/features/vessel/domain/services/operation_state_deriver.dart
git add -- lib/features/vessel/presentation/pages/departure_baplie_page.dart
git add -- lib/features/vessel/presentation/pages/export_list_import_page.dart
git add -- lib/features/vessel/presentation/pages/operation_progress_page.dart
git add -- lib/features/vessel/presentation/providers/export_list_providers.dart
git add -- lib/features/vessel/presentation/widgets/loading_controls.dart
git add -- pubspec.yaml
git add -- test/t132_departure_fidelity_test.dart
git add -- test/t132_departure_page_test.dart
git add -- test/t147_hoja_vacios_test.dart
git add -- test/t73_export_list_test.dart
git add -- test/t147e2_canceladas_test.dart
git add -- test/t147e2_tambien_llena_test.dart
git add -- test/t147e2_equivalencias_test.dart
git add -- test/t147e2_salida_test.dart
git add -- test/t147e2_hoja_test.dart
git add -- test/support/t147e2_support.dart
git add -- test/fixtures/t147e2_listado_guardado_por_la_102.json
git add -- tool/t147_conductor.dart
git add -- tool/t147e2_caso.dart
git add -- tool/t147e2_listado_revisado.py
git add -- docs/T147-RESULTADOS.md
git commit -m "Sprint 4: T-147, entrega 2, parte 2a: las canceladas no se cargan, tambien llena, lo guardado no manda, el destino final en LOC+83 y la hoja por OR"
git push origin t147-piloto4
```

Son 29 rutas. `windows/flutter/generated_plugin_registrant.*` y `generated_plugins.cmake` siguen con otros saltos de línea y el mismo contenido: no van.

## E2a-15. En tres líneas

1. Las filas que la agencia cancela ya no cuentan como carga y, si suben, se registran con motivo y quedan como conflicto; un tipo del listado llena varios códigos del plan, y lo guardado en el dispositivo ya no manda sobre el plan.
2. El BAPLIE de salida lleva el destino final en `LOC+83` y el código ISO del plan; la hoja no ofrece lo que no cabe y va por OR en todos los clientes.
3. La versión es 1.0.3+12; la suite da 2357 de 2357 y `analyze` cero, aquí y en una copia limpia, y las cifras del caso A09 coinciden todas, con las 408 cargas registradas.

## E2a-16. Para Yov

> Yov: la parte 2a de la entrega 2 de T-147 está en `baystream-t147`, sin commit; el informe es la parte «Entrega 2 · Parte 2a» de `docs/T147-RESULTADOS.md`, y la evidencia, `build/t147/e2a/`. Arriba de «Entrega 2 · Propuesta» hay una nota con lo que cambió y por qué decisión.
>
> Las cifras del caso coinciden todas con las tuyas, con el lector del producto y en pantalla. Lo que era cuenta ya está corrido: 408 cargas registradas sin ningún conflicto, 470 `LOC+83`, 408 de 408 con el código ISO del plan, los llenos con datos distintos de 17 a 0, y 22T4 sugerido para 20TK. El cruce del caso queda limpio: 135 de 135, 273 de 273 en 14 grupos, cuadran los 14.
>
> Suite 2357 de 2357 (2280 más 77) y `analyze` cero, aquí y en copia limpia. Rojas en una copia pura de `v1.0.2`: fallan 20, 11, 10, 11 y 8; pasan 17 en los dos lados. Corpus: los trece `.edi` y `LISTADO_A08.xlsx` iguales; cambia solo el listado del caso. La hoja no quedó más lenta: con la CPU ÷ 4 y alternando, 151–156 ms antes y 153–159 ms después. Seis recorridos de 29 capturas, cuatro en la Web y dos en Windows.
>
> Cuatro cosas para que mires:
> 1. **«Un código del plan, un solo tipo»:** lo leí como dos tipos con principales distintos. Dos tipos con el mismo principal son un solo grupo y no chocan; si chocaran, un listado con «40HC» y «40HQ» para el mismo 45G1 no se podría importar. E2a-3.2.
> 2. **«Guardada en este dispositivo» sale en el próximo viaje, no en la segunda importación de la misma operación:** ahí manda «De la revisión anterior de este listado.», que va antes. E2a-3.3.
> 3. **Cuatro pruebas que ya existían cambian a propósito,** tres más de las que anuncié: las dos de T-132 por la nota en «no cargaron», las referencias de la hoja de la entrega 1 por el orden y el largo, y la de T-73 que fijaba que lo guardado mandaba. E2a-3.7.
> 4. **La 1.0.2 abre lo que guarda la nueva, corrido de verdad:** con el listado del caso y sus 11 códigos declarados, da las cifras de 4.4.
>
> No lo probé en un teléfono; en Windows corrí dos recorridos y ninguna medición; el «Destino final» en el detalle lo comprobé con el lector, no en pantalla. La tarjeta de las celdas sin dueño ocupa más de una pantalla a 360 dp con seis códigos. No empecé la 2b.

## E2a-17. Las horas del reloj

| Tramo | Horas | Qué |
|---|---|---|
| 1 | 21:42 a 21:48 | La punta, las decisiones 10.159 a 10.161 y la luz verde |
| 2 | 21:48 a 22:20 | P1, P4, P3, P2, la hoja y la versión, con sus pruebas |
| 3 | 22:20 a 22:25 | `analyze`, la suite y las rojas contra `v1.0.2` |
| 4 | 22:25 a 22:29 | El caso con el lector, con las 408 cargas |
| 5 | 22:29 a 22:36 | El banco Web y los cuatro recorridos |
| 6 | 22:36 a 22:47 | La medición, antes y después, y la serie alternada |
| 7 | 22:47 a 22:51 | El corpus y los dos recorridos de Windows |
| 8 | 22:50 a 22:56 | Las validaciones finales, la copia limpia y el listado abierto por la 1.0.2 |
| 9 | 22:56 a 23:02 | La limpieza de `%TEMP%` y este informe |

Toda la parte corrió en una sola ventana de Flutter y de Dart, con la luz verde de Carlos y su línea `SEMÁFORO:` al empezar (21:45) y al terminar (22:56). Una prueba se quedó colgada una vez, por una espera mía mal escrita: la detuve, cerré el proceso que dejó y la corregí.

# Entrega 2 · Parte 2b

21 de noviembre de 2026. Timonel (Claude Code), en `C:\Proyectos\baystream-t147`, rama `t147-piloto4`, sobre `912daac`. Sin commit: lo ejecuta Carlos (E2b-14).

Lo anterior de este informe no se reescribe. Donde la 2b cambia algo que la propuesta o la 2a decían, va dicho aquí.

## E2b-0. En corto

- **Los nueve puntos están programados,** en el orden del encargo, cada uno con su roja guardada.
- **Suite 2412 de 2412** (2357 más 55 nuevas), sin omitidas, en una sola corrida, y `analyze` en cero, aquí y en una copia limpia, después del último cambio.
- **Las rojas:** de las 40 pruebas de P5, P8 a), P6, O-147-4 y O-147-5, **26 fallan contra `v1.0.2`**; de las 15 de O-147-7 a O-147-10, **12 fallan contra la punta de la 2a**. Las que pasan en los dos lados son los controles.
- **La huella quita la mitad de lo que tardaba el teclado:** con la CPU frenada, de 664 a 379 ms en una serie y de 999 a 498 ms en la otra.
- **La 2a no dejó el teclado más lento que la 1.0.2:** 664 contra 666 ms, y 999 contra 1005 ms. Lo que vio GLM es el ruido de la máquina, que también me salió (E2b-6).
- **La hoja, al tocar la celda, no quedó más lenta:** 159 ms con la 1.0.2 y 134 ms con la 2b.
- **El caso da las mismas cifras que en la 2a,** todas, y suma las de la 2b: «448 filas en 2 agencias», 334 (141, más 6 y 187), 53 y 61 en «AGREGADOS»; 169 filas que se cargan con POT y POD distintos.
- **P8 a) cupo sin tocar ninguno de los tres archivos que evito y en menos de una hora.** Dónde va y cómo se llama, en E2b-3.2, con tres decisiones mías que Carlos confirmó al recibir la entrega.
- **O-147-10 lleva una salvedad que Carlos aprobó** antes de programarla (E2b-3.9).
- **La nube se miró contra el emulador de Firebase:** no se publica ni se agrega un plan con una matrícula repetida, y después de cerrar se abrió y se publicó otra operación, con el mismo archivo y con otro.
- **Tres pruebas de la entrega 1 cambian a propósito** (E2b-3.10). **Pido que Yov las mire.**
- **Lo que no hice,** en E2b-12: Descarga con la matrícula repetida en pantalla, el teléfono de verdad, y la operación nueva vista desde un muelle en la 1.0.2.

## E2b-1. Paso 0

- La punta de la rama era `912daac`, «Sprint 4: aceptacion de la parte 2a de la entrega 2 de T-147», y debajo, `1c2d86d`. El árbol, limpio, salvo los tres archivos de `windows/flutter/`, que cambian solo de fin de línea y no entran al bloque de Git.
- Leí las decisiones 10.161, 10.162 y 10.163 de `SPRINT-4.md`, en `C:\Proyectos\baystream-rediseno`. No lo edité.
- **El semáforo:** Carlos dio luz verde a toda la 2b. Corrí un comando de Flutter o de Dart a la vez, y avisé al empezar y al terminar la ventana de medición.
- **Dos preguntas en el camino:** la luz verde, y el lápiz (E2b-3.9), que el encargo pedía decir antes de programar.

## E2b-2. Las rojas

Los registros están en `build/t147/e2b/registros/`.

| Contra | Archivo de pruebas | Pruebas | Fallan ahí | Registro |
|---|---|---:|---:|---|
| `v1.0.2` (`99995db`) | `t147e2b_repetida_test.dart` (P5) | 17 | 10 | `rojas-contra-v102.log` y `.json` |
| | `t147e2b_otra_operacion_test.dart` (P8 a) | 11 | 9 | |
| | `t147e2b_huella_test.dart` (P6) | 2 | 1 | |
| | `t147e2b_listado_test.dart` (O-147-4 y O-147-5) | 10 | 6 | |
| | **Suma** | **40** | **26** | |
| La punta de la 2a (`912daac`) | `t147e2b_revision_test.dart` (O-147-7 a O-147-10) | 15 | 12 | `rojas-contra-la-2a.log` y `.json` |

- Las dos copias salen de `git archive`, fuera del repositorio, con `pub get --offline --enforce-lockfile`. A la de `v1.0.2` le copié el soporte de la 2a (`test/support/t147e2_support.dart`) y los cuatro archivos; a la de la 2a, el quinto.
- **Ninguna roja es de compilación.** Lo que la versión anterior no tiene se lee a través de `dynamic`, o se mira en la pantalla.
- **Las que pasan en los dos lados son controles:** el plan corregido sí se publica y sí se agrega; una vez en la llegada y una vez en la carga no es repetida; con el mismo archivo se sigue viendo la cerrada; la copia local de antes del cierre no la tapa; dos viajes iguales siguen siendo iguales; un listado guardado por la 1.0.2 se lee como entonces; sin nada que pida motivo, el diálogo queda como estaba.

## E2b-3. Lo que cambia, punto por punto

### 3.1 P5 · La matrícula repetida (D11)

**La regla.** Un plan con una matrícula en más de una celda no entra a la nube; en el equipo que opera solo se deja operar, con el defecto a la vista. «Repetida» es lo mismo que ya avisa el lector: con forma de matrícula ISO 6346 y en más de una celda **del mismo archivo**. Una vez en la llegada y una vez en la carga no es repetida.

| Dónde | Qué pasa ahora | Dónde está |
|---|---|---|
| «Publicar operación» | El botón queda apagado y debajo dice: «No se publica: el plan de carga («‹archivo›») trae 1 matrícula en más de una celda: ‹matrícula› en 018-01-82 y 018-00-82. Un contenedor solo puede estar en una. Pide el plan corregido a quien lo hizo y ábrelo de nuevo.» Si aun así se llega a publicar, se detiene antes de subir nada | `publishRefusalProvider` (`sync_providers.dart`) y `cloud_page.dart` |
| «Agregar a la operación» (T-130) | El diálogo dice el mismo motivo, con «No se agrega», y su botón queda apagado. La regla está también en el dominio: `OperationSources.save` lo rechaza | `dialogo_agregar_plan.dart` y `operation_sources.dart` |
| El plano de llegada | Lo mismo, con «el plano de llegada» | los mismos |
| Carga y Descarga, en el equipo solo | Una ficha fija, en el color de Revisar: «Plan con 1 matrícula repetida: una carga no se puede registrar. Pide el plan corregido.» (en Descarga, «una descarga»). **En el teléfono va en una línea propia, encima del resumen recogido:** la primera versión la dejaba dentro del resumen, y a 360 dp no se veía sin abrirlo; lo vi en la captura y lo cambié | `resumen_del_modo.dart`, `PlanSummaryLine` |
| La primera celda | Se ve con su contenedor, como la trae el archivo, y al tocarla responde: «Matrícula repetida» · «El plan trae ‹matrícula› también en 018-00-82. Esta celda no se puede operar hasta abrir el plan corregido.» | `bay_plan_view.dart` |
| La bahía | Pesa lo del archivo: 148.2 t donde la 1.0.2 decía 140.3 t | `LoadingOperation.build` |
| El BAPLIE de salida | «Avisos de la salida» dice: «‹matrícula›: el plan de carga lo trae en 2 celdas (018-01-82 y 018-00-82). Un contenedor solo puede estar en una: la salida escribe un solo grupo para esa matrícula. Pide el plan corregido.» | `departure_baplie_writer.dart` |

- La regla de dominio es `RepeatedContainers` (`repeated_containers.dart`, nuevo): de cada repetida, la operación se queda con la última celda del archivo, que es la que ya guardaba, y las demás no se pueden operar.
- **No cambia nada guardado** ni la clave de ninguna pieza.
- **Lo que la propuesta no miró, ahora mirado:**
  - **con el listado importado:** igual que sin él. La ficha, la primera celda y la salida dicen lo mismo, y la otra celda se carga como cualquier lleno (`rep-360-dia`, con listado; `rep-1366-noche`, sin él);
  - **el BAPLIE de salida:** escribe un solo grupo, y ahora lo avisa con las dos celdas;
  - **Windows:** E2b-5.
- **Una operación que ya se publicó así con la 1.0.2** no se puede retirar. La versión nueva la enseña con su ficha y con la primera celda que responde.

### 3.2 P8 a) · Abrir otra operación después de cerrar (D14), también con el mismo archivo

**Cupo sin tocar ninguno de los tres archivos que evito, y en menos de una hora.** La regla vive en `operation_sources.dart` y el botón, en `cloud_page.dart`.

| Caso | Hasta la 1.0.2 | Ahora |
|---|---|---|
| Se abre **otro archivo** del mismo buque, viaje y puerto, con la operación cerrada | «…ya está cerrada y sus BAPLIE no cambian. Para trabajar con este archivo, ábrelo como una operación nueva.» No había cómo | **Nace una operación nueva,** en este equipo y sin publicar, con ese archivo. La cerrada no cambia |
| Se abre **el mismo archivo** | Se veía la cerrada, y no había salida | Se sigue viendo la cerrada, solo para mirar. En «Nube y cuenta» dice «Se sigue viendo, solo para mirar. Para trabajar esta escala otra vez, empieza una operación nueva con sus planos.» y hay un botón: **«Empezar una operación nueva»** |
| Otro listado en la cerrada | «…abre el plan de carga como una operación nueva» | Se rechaza igual, y dice por dónde: «…empieza una operación nueva desde «Nube y cuenta».» |

**Dónde va y cómo se llama (mi propuesta, ya programada).**

- **«Empezar una operación nueva»,** en «Nube y cuenta», en «Operación de la escala abierta», en el sitio donde estaba «Cerrar operación». Es la misma página donde se publica y se cierra.
- Pide confirmar: «Empieza de cero con los planos de la operación cerrada: el plano de llegada («‹archivo›») y el plan de carga («‹archivo›»). El listado de la agencia se importa de nuevo. Lo registrado se queda en la operación cerrada, que deja de verse en este equipo.» · «Cancelar» · «Empezar».
- Después dice «Operación nueva, en este dispositivo. Publícala para que el muelle la reciba.», aparece «Publicar operación» y una línea: «Es una operación nueva: la anterior de esta escala se cerró el ‹fecha› y lo registrado se quedó en ella.»
- **No la ofrece al muelle,** que no publica: a él le dice «Si la oficina publica otra operación de esta escala, únete a ella desde «Operaciones abiertas en la nube».» Sin cuenta sí se ofrece: es el equipo que opera solo.

**Tres decisiones mías. Carlos las confirmó el 21-nov, al recibir la entrega («Sí, así quedan»):**

1. **La operación nueva lleva los planos y no el listado.** El encargo dice «con esos planos». El listado se importa de nuevo, y sus equivalencias salen de lo guardado en el dispositivo. Llevarlo también es una línea.
2. **Al empezar la nueva, la cerrada deja de verse en ese equipo.** Sus datos siguen guardados, pero la app enseña una operación por escala y no tiene un selector. El diálogo lo dice antes de confirmar. Un selector de operaciones de la misma escala es otra tarea.
3. **Cómo sabe la app cuál se ve** (`OperationSources.current`): la publicada y abierta; si no hay, la que se empezó después del cierre; si no, la cerrada más reciente; sin ninguna publicada, la local, como siempre. La nueva nace con una fecha posterior al cierre aunque el reloj del equipo vaya atrasado. **No se guarda nada nuevo.** Así se distingue de la copia local que el muelle abrió antes de unirse, que es anterior al cierre y no tapa a la cerrada.

- **Un borde que encontré con la suite:** la oficina confirma «Agregar a la operación» y, mientras tanto, la operación se cierra. Ahí no se abre otra a sus espaldas: se rechaza con «…ya está cerrada y sus BAPLIE no cambian: el plan no se agregó. Vuelve a abrir este archivo y empezará una operación nueva.» La prueba de T-130 que lo cubría sigue igual.
- Publicar la nueva ya estaba permitido: la guarda de T-130 mira solo las abiertas. Las reglas de Firestore no se tocan.

### 3.3 P6 · La huella del viaje (D12)

- `VesselVoyage.hashCode` se calcula una vez por objeto y se guarda fuera de él, en un `Expando`, porque el constructor es `const`. El `==` sigue siendo el de siempre, campo por campo.
- Dos pruebas: la huella no vuelve a recorrer los contenedores (una lista que cuenta sus lecturas), y dos viajes iguales siguen siendo iguales, uno distinto no, y la copia con un cambio nace con otra huella.
- La medida, en E2b-6.

### 3.4 O-147-4 · Las secciones son de la agencia de arriba (10.161)

- **Cómo distingue el lector una sección de una agencia:** el separador de agencia trae su código («CODIGO» o «COD.»); el título de una sección es una de tres palabras, sola en una fila sin OR: «TRANSBORDOS», «VACIOS» o «AGREGADOS», en singular o plural, con o sin tilde.
- «TRANSBORDOS» y «VACIOS» ya no pisan la agencia: la fila guarda su sección aparte (`ExportListRow.section`, clave nueva `section`) y conserva su agencia. Una agencia nueva cierra la sección de la anterior.
- «AGREGADOS» se sigue contando sola (10.50): va en el lugar de la agencia, como hasta hoy, y no cuenta como agencia.
- **Un título que no conoce:** se informa como hoy, «No es un contenedor ni un separador de agencia: «…»», y **no cambia ni la agencia ni la sección** de las filas de debajo. El lector no sabe si esa fila es un título o una nota. Lo que sí cambia: en la 1.0.2 esas filas quedaban en la «agencia» de la sección; ahora quedan en su agencia de verdad.
- **Un listado guardado por la 1.0.2** no trae secciones: se lee como entonces, cinco «agencias», hasta que se vuelve a importar. No se migra nada.
- En pantalla: «448 filas en 2 agencias · …» y, debajo, «‹agencia 1›: 334 (TRANSBORDOS 6, VACIOS 187)», «‹agencia 2›: 53» y «AGREGADOS: 61». En la lista de filas, la sección va después de la agencia.

### 3.5 O-147-5 · El grupo sin matrícula con la posición mal formada

- Ya no se pierde sin aviso. El lector suma un aviso de posición: «Celda reservada sin matrícula: «01A0282»».
- Empieza por «Celda reservada» a propósito: así el resumen lo cuenta como «1 caso» y no como «1 contenedor», **también en la 1.0.1 y la 1.0.2,** que ya leen esa clase de aviso. En la propuesta decía «Celda sin matrícula»; lo cambié por esto.
- La celda sigue sin poder dibujarse: no hay dónde ponerla.

### 3.6 O-147-7 · La tarjeta de las celdas sin dueño

- **Sale cuando ya no queda ningún tipo por elegir** (`orphanTypeCodes`). Con el caso: sin tarjeta mientras faltan los seis; elegidos, 11 celdas en 6 códigos.
- **A 360 dp las tres fichas van en una línea:** «Sí», «Otro tipo…» y **«No»**. «No: piden motivo» no cabía; lo que pasa después lo dice la tarjeta arriba, la ayuda de la ficha y la línea del código al elegirlo («… pide motivo al cargar.»).

### 3.7 O-147-8 · Cuatro textos

| | Antes | Ahora |
|---|---|---|
| (a) El resumen del listado | «202 filas traen POT y POD distintos…» | «169 filas que se cargan traen POT y POD distintos (y 33 canceladas): el cruce con el plan usa el POT…». Sin canceladas, la frase de antes |
| (b) El avance | «Listado: 41 filas canceladas, que no se cargan (…).», con una a bordo | «Listado: 41 filas canceladas (38 llenos y 3 vacíos): 40 no se cargan y 1 está a bordo.» Sin ninguna a bordo, la frase de antes |
| (c) La salida | «1 conflictos vigentes.» | «1 conflicto vigente.» |
| (d) El detalle de la celda | «…lo marca cancelado («…»). Si el registro fue un error, deshazlo desde el detalle de la celda.» | «…lo marca cancelado («…»).» El avance lo sigue diciendo entero: el mensaje derivado no cambia |

### 3.8 O-147-9 · El motivo, a la vista

- Cuando la revisión de la carga pide motivo, su campo va **justo debajo del panel que lo pide,** antes de la hora, la fecha y el marchamo. Sin nada que pida motivo, el diálogo queda como estaba; en una corrección, el «Motivo de la corrección» sigue al final.
- **Dos cosas más, mías,** para que quepan el aviso, el campo y «Confirmar carga»:
  - en cuanto la carga empieza a pedir motivo, el diálogo lleva el campo a la vista. Solo desplaza si hace falta;
  - la ayuda del campo pasa de «Viaja con el movimiento y deja el conflicto a la vista.» a **«Viaja con el movimiento.»**, en una línea. Lo del conflicto ya lo dice el aviso de encima.
- **El diálogo de la descarga no tiene ese orden:** el de motivo (`_ReasonDialog`, `discharge_controls.dart`) trae solo el mensaje, la razón rápida y el campo, que queda justo debajo. No lo cambié.

### 3.9 O-147-10 · El lápiz, con la salvedad que aprobó Carlos

- Al cambiar el código principal de un tipo, el que deja de serlo **se queda como «también llena» si el plan lo respalda** (está en `observed`). Si no lo respalda, se pierde y sus celdas vuelven a la tarjeta, como en la 2a.
- **El caso en que estorbaba, dicho antes de programarlo:** la oficina usa el lápiz para separar dos tipos que compartían código. Si el anterior se quedara siempre, lo reclamarían dos tipos con principales distintos, y la importación se detendría con «un código del plan, un solo tipo». **Salvedad:** no se queda si otro tipo del listado ya lo tiene de principal. Carlos eligió «Con la salvedad».
- Con el caso: 40HC, de 45G1 (también 45G0) a 45G0 (también 45G1); 14 de 14 grupos cuadran antes y después, ningún choque y ninguna celda sin dueño.

### 3.10 Las pruebas que ya existían y cambian a propósito

Tres, en `test/t147_listado_test.dart`, de la entrega 1. Afirmaban la regla que la 10.161 cambia:

| Prueba | Decía | Dice |
|---|---|---|
| «COD. vale como CODIGO, y TRANSBORDOS y VACIOS son secciones» | cinco agencias; la fila de «TRANSBORDOS» tiene esa «agencia» | tres entradas (dos agencias y «AGREGADOS»); la fila conserva su agencia y lleva `section` |
| «el separador se reconoce con espacios, punto y tilde» | bajo una sección, la agencia deja de ser la de arriba | la agencia es la de arriba, salvo «AGREGADOS», y la fila lleva su sección |
| «lo que guarda la 1.0.2 tiene las mismas claves» | ninguna clave que la 1.0.1 no lea | una sola clave nueva, `section`, que la 1.0.1 y la 1.0.2 ignoran |

Ninguna se afloja en lo demás. **Pido que Yov las mire,** como las de la 2a.

## E2b-4. El caso A09

`tool/t147e2_caso.dart`, con el lector del producto (`build/t147/e2b/caso/caso-2b.json`):

- **Las 184 cifras de la 2a salen iguales, una por una.** Comparé los dos archivos clave por clave: ninguna distinta.
- La herramienta suma un bloque, `parte2b`, con lo de esta parte:

| Qué | Cifra |
|---|---|
| Agencias | **2**, y «AGREGADOS» aparte |
| La primera agencia | **334**: 141 sin sección, 6 de «TRANSBORDOS» y 187 de «VACIOS» |
| La segunda | **53** |
| «AGREGADOS» | **61** |
| Filas con POT y POD distintos | **169** que se cargan y 33 canceladas (las 202 de antes) |
| Con los seis tipos por elegir | 0 códigos y 0 celdas sin dueño |
| Elegidos los seis | 11 celdas en 6 códigos, como en la 2a |
| El lápiz, 40HC de 45G1 a 45G0 | queda 45G0 con «también» 45G1; **14 de 14 grupos cuadran,** antes y después; ningún choque y ninguna celda sin dueño |
| Matrículas repetidas en el plan del caso | 0: el caso no trae ninguna |

## E2b-5. En pantalla

### 5.1 El recorrido del banco

Dos escenarios nuevos en el conductor (`tool/t147_conductor.dart`), con toques de verdad: `recorrido2b` y `repetida2b`. El instrumento de la medición no se tocó. Cada corrida deja sus capturas y, en `pasos.jsonl`, lo que el banco leyó en cada paso. Todo en `build/t147/e2b/recorrido/`.

| Corrida | Escenario | Capturas | Errores de Flutter |
|---|---|---:|---:|
| Web · 360 × 800 · día | `recorrido2b` | 10 | 0 |
| Web · 360 × 800 · noche | `recorrido2b` | 10 | 0 |
| Web · 1366 × 690 · día | `recorrido2b` | 10 | 0 |
| Web · 1366 × 690 · noche | `recorrido2b` | 10 | 0 |
| Windows · 1366 × 690 · día | `recorrido2b` | 10 | 0 |
| Web · 360 × 800 · día, con el listado | `repetida2b` | 7 | 0 |
| Web · 1366 × 690 · noche, sin listado | `repetida2b` | 7 | 0 |
| Windows · 360 × 800 · noche, con el listado | `repetida2b` | 7 | 0 |

- Las cuatro corridas Web de `recorrido2b` son del banco final: las repetí después del último cambio.
- Chrome, solo contra `127.0.0.1`, con un perfil nuevo por corrida. Windows, con la compilación del banco copiada a `%TEMP%` y su almacén ahí.

**Lo que dicen las ocho, igual en todas:**

| Paso | Lo que se ve |
|---|---|
| El resumen | «448 filas en 2 agencias · 408 para cargar: 135 llenos y 273 vacíos» · «AGENCIA 1 S.A.: 334 (TRANSBORDOS 6, VACIOS 187)» · «AGENCIA 2 S.A.: 53» · «AGREGADOS: 61» · «169 filas que se cargan traen POT y POD distintos (y 33 canceladas): el cruce con el plan usa el POT…» |
| Con seis tipos por elegir | La tarjeta de las celdas sin dueño **no está** |
| Elegidos | «Celdas reservadas que ningún tipo del listado llena (11)», seis códigos, y en los seis las tres fichas van en una línea, también a 360 dp |
| El lápiz | 40HC queda «45G0», «También llena: 45G1»; 14 de 14 grupos cuadran; ningún choque |
| El vacío cancelado | «Asignar vacío»: el aviso «Pide motivo: el listado lo marca cancelado («CANCELADO»)…», «Motivo (obligatorio)» y «Confirmar carga», a la vista sin desplazar |
| Una celda de otro grupo | lo mismo, con «Pide motivo: La reserva 018-10-88 es de otro grupo…» |
| El lleno cancelado | «Confirmar carga»: lo mismo. Se escribe el motivo y se confirma |
| El detalle de la celda | «OR 1 · ‹matrícula› se cargó y el listado lo marca cancelado («CANCELADO»).», sin la frase del detalle |
| El avance | «Listado: 41 filas canceladas (38 llenos y 3 vacíos): 40 no se cargan y 1 está a bordo.» |
| La salida | «1 conflicto vigente. Revisa el avance de la operación…» |

**El motivo, a 360 × 800, en píxeles desde arriba** (`pasos.jsonl`, pasos `motivo-…`):

| Caso | El aviso | El motivo | La hora | «Confirmar carga» |
|---|---|---|---|---|
| El vacío cancelado | 266 a 350 | 555 a 632 | 644 | 704 a 752 |
| Una celda de otro grupo | 341 a 467 | 538 a 615 | 627 | 704 a 752 |
| El lleno cancelado | 277 a 361 | 432 a 509 | 521 | 704 a 752 |

- En los tres, el banco comprueba que el aviso se ve y que el dedo alcanza el campo y el botón. A 1366 × 690 y en Windows, igual.
- En la captura del vacío cancelado hay **dos avisos:** la celda de la que partió la hoja era de otro grupo. El campo queda debajo de los dos. Entre los avisos y el campo va la línea del peso de la pila, que es parte del mismo panel.
- **Las capturas de GLM** (`glm-a-03` y `glm-b-04`) son el «antes»: el aviso y «Confirmar carga» apagado, sin el campo.

**La matrícula repetida, en el equipo que opera solo** (`repetida2b`):

| Paso | Lo que se ve |
|---|---|
| Lista | «Matrículas repetidas en EQD: 1 contenedor…», como en la 1.0.2 |
| Carga, bahía 18 | La ficha «Plan con 1 matrícula repetida: una carga no se puede registrar. Pide el plan corregido.», en su línea, sobre el resumen. «9 contenedores · 73 celdas reservadas · **148.2 t**». 407 pendientes |
| La primera celda, 018-01-82 | «Matrícula repetida» · «El plan trae ‹matrícula› también en 018-00-82. Esta celda no se puede operar hasta abrir el plan corregido.» · «Entendido» |
| La segunda, 018-00-82 | «Confirmar carga», como cualquier lleno. Se confirma: cargado, 406 pendientes, ningún conflicto |
| La salida | «‹matrícula›: el plan de carga lo trae en 2 celdas (018-01-82 y 018-00-82). Un contenedor solo puede estar en una: la salida escribe un solo grupo para esa matrícula. Pide el plan corregido.» |

- **Con el listado importado y sin él dice lo mismo.** En Windows, también.
- El plan repetido es sintético: sale del caso cambiando un solo `EQD`, y vive en `%TEMP%`.

### 5.2 La nube, contra el emulador de Firebase

El emulador de T-143 (`tool/t143_emulador.py`: proyecto `demo-t143`, Auth 9399 y Firestore 8383, las reglas de T-130 sin tocar, dos cuentas sintéticas) y el banco de T-130 (`tool/t130_emu_main.dart`), compilado desde la 2b y servido en `127.0.0.1:5943` desde `%TEMP%`. Lo conduje con `tool/t143_control_web.py`, como oficina, a 1920 × 1080. **Nunca producción ni `baystream-privado`.** Diez capturas en `build/t147/e2b/nube/`.

| Paso | Lo que se ve | Captura |
|---|---|---|
| Se abre el plan repetido y se va a «Nube y cuenta» | «Publicar operación» apagado, y debajo: «No se publica: el plan de carga («PLAN_REPETIDO.edi») trae 1 matrícula en más de una celda: ‹matrícula› en 018-01-82 y 018-00-82. Un contenedor solo puede estar en una. Pide el plan corregido a quien lo hizo y ábrelo de nuevo.» | `01` |
| Se abre el plan corregido (el del caso) | Reemplaza al anterior en la misma operación; «Publicar operación» se enciende; «Operación publicada.» | `02` |
| «Cerrar operación» | «Publicada y cerrada» · «Se sigue viendo, solo para mirar. Para trabajar esta escala otra vez, empieza una operación nueva con sus planos.» · **«Empezar una operación nueva»** | `03` |
| Se pulsa | El diálogo: «…los planos de la operación cerrada: el plan de carga («CORPUS_A09.edi»). El listado de la agencia se importa de nuevo. Lo registrado se queda en la operación cerrada, que deja de verse en este equipo.» | `04` |
| «Empezar» | «Operación nueva, en este dispositivo. Publícala para que el muelle la reciba.» · «Solo en este dispositivo» · «Es una operación nueva: la anterior de esta escala se cerró el 21-nov, 11:09 y lo registrado se quedó en ella.» · «Publicar operación» | `05` |
| «Publicar operación» | **«Operación publicada.»:** la nube acepta la segunda operación del mismo buque, viaje y puerto | `06` |
| Se cierra esa, y se abre **otro archivo:** un plano de llegada del mismo buque y viaje | Entra sin preguntar, como operación nueva: «Solo en este dispositivo» · «Es una operación nueva: la anterior de esta escala se cerró el 21-nov, 11:10…» · «Fuentes: llegada» | `07` |
| Se publica | «Operación publicada.» | `08` |
| Se abre el plan repetido, que es el plan de carga que le falta | El previo, con «Confirmar» | `09` |
| «Confirmar» y «Confirmar y ver el plano» | «Agregar el plan de carga a la operación publicada» · «Se cargan 137 contenedores y 271 celdas reservadas; se descargan 0.» · **«No se agrega: el plan de carga («PLAN_REPETIDO.edi») trae 1 matrícula en más de una celda…»** · «Agregar a la operación VIAJE009A», apagado | `10` |

- Con esto quedan a la vista los dos casos de P8 a): **con el mismo archivo** (pasos 3 a 6) y **con otro** (pasos 7 y 8).
- El plano de llegada es sintético: la cabecera del caso y tres de sus llenos, con los puertos cambiados. Vive en `%TEMP%`.
- Al terminar apagué el emulador y el control. Lo de `%TEMP%` que sale del caso lo borro al cerrar la entrega.

## E2b-6. La medición

El instrumento de la entrega 1 (`escenario=medir`, sin tocarlo), el caso A09, la celda 018-10-88, 360 × 800, Chrome y **la CPU frenada ÷ 4**. Tres bancos Web, compilados con el mismo comando, cada uno en su copia: `v1.0.2` (`99995db`), la punta de la 2a (`912daac`) y la 2b. Milisegundos, de soltar el dedo a la pantalla dibujada. Cinco corridas de cada uno, **alternadas** (1.0.2, 2a, 2b, 1.0.2, …). `build/t147/e2b/medicion.json`.

**Serie 1 · El mismo perfil de Chrome para los tres,** con la operación preparada una vez, con la 1.0.2:

| | 1.0.2 | 2a | 2b |
|---|---|---|---|
| Tocar la celda | 161 · 159 · 154 · 160 · 153 | 213 · 158 · 155 · 156 · 160 | 135 · 134 · 132 · 130 · 142 |
| mediana | **159** | **158** | **134** |
| El teclado | 664 · 673 · 661 · 705 · 656 | 985 · 666 · 666 · 642 · 694 | 381 · 378 · 379 · 367 · 384 |
| mediana | **664** | **666** | **379** |
| Una tecla | 95 · 96 · 98 · 97 · 94 | 138 · 131 · 97 · 93 · 100 | 84 · 74 · 74 · 72 · 74 |
| mediana | **96** | **100** | **74** |

**Serie 2 · Un perfil propio por banco,** cada uno con la operación que preparó su propio código:

| | 1.0.2 | 2a | 2b |
|---|---|---|---|
| Tocar la celda | 222 · 208 · 229 · 215 · 203 | 211 · 211 · 209 · 209 · 214 | 168 · 186 · 168 · 165 · 163 |
| mediana | **215** | **211** | **168** |
| El teclado | 1006 · 999 · 1002 · 978 · 989 | 1024 · 1010 · 1005 · 1001 · 996 | 502 · 498 · 491 · 501 · 491 |
| mediana | **999** | **1005** | **498** |
| Una tecla | 142 · 141 · 140 · 138 · 140 | 136 · 139 · 144 · 138 · 137 | 98 · 96 · 98 · 98 · 98 |
| mediana | **140** | **138** | **98** |

**Las dos respuestas.**

1. **Cuánto baja el teclado con la huella:** de 664 a 379 ms en la serie 1 (**43 %**) y de 999 a 498 ms en la serie 2 (**50 %**). Es lo que midió el prototipo de la propuesta (42 %).
2. **Si la 2a lo dejó más lento que la 1.0.2: no.** 664 contra 666 ms, y 999 contra 1005 ms: menos del 1 %, dentro de lo que varía cada banco de una corrida a otra.

**Lo que explica lo que midió GLM.**

- La máquina tiene dos pasos. **La serie 2 entera salió una vez y media más lenta que la serie 1,** para los tres bancos por igual: la 1.0.2, preparada igual en las dos, dio 664 ms en una y 999 ms en la otra.
- En la serie 1, la primera corrida de la 2a cayó en el paso lento: 985 ms, donde las otras cuatro dieron de 642 a 694.
- Los 770, 899 y 916 ms que GLM midió con la 2a, contra 786 a 795 con la 1.0.2, tienen esa forma: unas corridas en un paso y otras en el otro. **Por eso hay que alternar** y mirar la mediana.
- **No sé qué cambia el paso de la máquina.** La serie 1 la lancé en primer plano y la serie 2, en segundo; no lo comprobé más allá de eso.

**La hoja, al tocar la celda, no quedó más lenta que en la 1.0.2:** 159 ms contra 134 ms en la serie 1 y 215 contra 168 ms en la serie 2. Con la 2a, 158 y 211.

- **No lo medí** en Windows, en un teléfono ni con un plan más grande que el del caso. El teclado del banco es simulado, como en la entrega 1.

## E2b-7. El corpus, antes y después

`tool/t147_corpus.dart`, con las dos carpetas y los dos listados. Comparé la lectura de la 2b con la de la 2a y con la de `v1.0.2` (`build/t147/e2b/corpus/`):

| Archivo | Contra la 2a | Contra `v1.0.2` |
|---|---|---|
| Los trece `.edi` | **igual** | **igual** |
| `LISTADO_A08.xlsx` contra A08 | **igual** | **igual** |
| `LISTADO_A09.xlsx` | distinto: de 5 «agencias» a 3 entradas (dos agencias y «AGREGADOS»), y las filas guardadas, que ahora llevan `section` | lo de la 2a, más esto |

- Del listado del caso **no cambian** ni las equivalencias ni el cruce: su huella es la de la 2a.
- **O-147-5 no cambia la lectura de ningún `.edi` del corpus:** ninguno trae un grupo sin matrícula con la posición mal formada.
- `LISTADO_A08.xlsx` no trae secciones.

## E2b-8. Las validaciones

Todo después del último cambio (`build/t147/e2b/registros/`):

| Dónde | `flutter analyze` | `flutter test`, en una sola corrida |
|---|---|---|
| Esta carpeta | **0** incidencias (`final-analyze.log`) | **2412 de 2412,** sin omitidas (`final-suite.log`) |
| Copia limpia: `912daac` más los 31 archivos de la 2b, en `%TEMP%\t147-e2b\limpia` | **0** (`limpia-analyze.log`) | **2412 de 2412** (`limpia-suite.log`) |

- El piso era 2357. Suben 55: 17 de P5, 11 de P8 a), 2 de P6, 10 de O-147-4 y O-147-5, y 15 de O-147-7 a O-147-10.
- Ningún `// ignore:`, ninguna dependencia nueva. **`pubspec.yaml` y `pubspec.lock` no cambian:** la versión sigue en `1.0.3+12`.
- No toqué `lib/main.dart`, los congelados, ni `vessel_overview_page.dart`, `vessel_providers.dart` o `loading_operation_provider.dart`.
- Una corrida intermedia de la suite dio 2411 de 2412: falló una prueba de T-130 que cubre agregar un plan a una operación que se cerró mientras tanto. Tenía razón ella; lo corregí en el código (E2b-3.2) y la prueba quedó como estaba.

## E2b-9. Entre versiones

**La 1.0.2 abre lo que guarda la 2b.** Dos comprobaciones, corridas de verdad (`build/t147/e2b/entre-versiones/`):

- **En pantalla:** el banco de `v1.0.2` abrió el perfil de Chrome en que el banco de la 2b había guardado la operación con su listado. Entró a Carga, tocó la celda y la hoja ofreció sus filas (OR 250, 251, 252…), sin ningún error de Flutter.
- **Con el código:** el listado del caso, guardado por la 2b con «también llena» declarado, leído con el código de `v1.0.2`. Da **lo mismo que dio con la 2a,** cifra por cifra: 448 filas, 135 llenos que cruzan, 23 grupos.
- **Lo único nuevo que se guarda es la clave `section`,** en 254 filas del caso. La 1.0.2 la ignora y ve **3** entradas en el lugar de las agencias (334, 61 y 53), donde antes veía 5.
- **La operación nueva no guarda nada distinto:** es una operación como las demás, con otro identificador.

**Lo que no se opera con versiones mezcladas:**

| Qué | Por qué |
|---|---|
| **La operación nueva de una escala que ya se cerró** | Un equipo en la 1.0.2 que tuvo la cerrada puede seguir encontrándola a ella y no a la nueva, aunque se una. Para trabajar la nueva, todos los equipos en la 1.0.3. **Leído en el código de la 1.0.2; no lo corrí** con un muelle en la 1.0.2 contra el emulador |
| **El plan con una matrícula repetida** | La regla vive en el cliente: una oficina en la 1.0.2 todavía puede publicarlo o agregarlo. La 1.0.3 que se une lo enseña con su ficha |
| Lo de la 2a | Sigue igual: lo que la 1.0.2 no lee de «también llena» y de las canceladas (E2a-9) |

## E2b-10. `DESIGN.md` y el manual

### 10.1 `DESIGN.md`

**No lo edité.** El texto que suma la 2b a 17.7, para que Yov lo ponga al mezclar:

> **17.7, parte 2b (T-147; 10.161 a 10.163)**
>
> **La matrícula repetida.** Un plan con una matrícula en más de una celda no entra a la nube. En «Nube y cuenta», «Publicar operación» queda apagado y debajo va el motivo, en el color del texto: «No se publica: el plan de carga («…») trae 1 matrícula en más de una celda: … en 018-01-82 y 018-00-82. Un contenedor solo puede estar en una. Pide el plan corregido a quien lo hizo y ábrelo de nuevo.» El diálogo «Agregar el plan…» dice lo mismo con «No se agrega» y apaga su botón. En Carga y en Descarga, una ficha en el color de Revisar (14.7): «Plan con 1 matrícula repetida: una carga no se puede registrar. Pide el plan corregido.» En el teléfono va en una línea propia, encima del resumen recogido. La celda que la operación no guarda se dibuja con su contenedor y, al tocarla, abre un diálogo «Matrícula repetida» con «Entendido». El BAPLIE de salida lo dice en «Avisos de la salida».
>
> **Después de cerrar.** La operación cerrada se sigue viendo, solo para mirar. En «Nube y cuenta» dice «Se sigue viendo, solo para mirar. Para trabajar esta escala otra vez, empieza una operación nueva con sus planos.» y ofrece un botón lleno, «Empezar una operación nueva», que pide confirmar. La operación nueva lo dice con una línea: «Es una operación nueva: la anterior de esta escala se cerró el … y lo registrado se quedó en ella.» Al muelle no se le ofrece: se le dice que se una a la que publique la oficina. Abrir otro archivo de la misma escala, con la operación cerrada, empieza una nueva sin preguntar.
>
> **El listado de la agencia.** Las secciones no son agencias: «N filas en M agencias», y cada agencia con las suyas entre paréntesis, «AGENCIA: 334 (TRANSBORDOS 6, VACIOS 187)». «AGREGADOS» va en su línea y no cuenta como agencia. Con filas canceladas, la línea del POT dice «169 filas que se cargan traen POT y POD distintos (y 33 canceladas)». La tarjeta «Celdas reservadas que ningún tipo del listado llena» sale cuando ya no queda ningún tipo por elegir, y sus tres fichas son «Sí», «Otro tipo…» y «No», en una línea a 360 dp. Con el lápiz, el código que deja de ser el principal de un tipo se queda en «También llena» si el plan lo respalda y ningún otro tipo lo tiene de principal.
>
> **La carga que pide motivo.** El campo «Motivo (obligatorio)» va justo debajo del aviso que lo pide, antes de la hora, la fecha y el marchamo, y el diálogo lo lleva a la vista. Su ayuda es «Viaja con el movimiento.» En el detalle de la celda, la línea del conflicto no manda al detalle de la celda.
>
> **El avance y la salida.** Con una cancelada a bordo: «Listado: 41 filas canceladas (38 llenos y 3 vacíos): 40 no se cargan y 1 está a bordo.» En la salida, «1 conflicto vigente», en singular.
>
> **El lector de BAPLIE.** Un grupo sin matrícula con la posición mal formada suma un aviso de posición: «Celda reservada sin matrícula: «…»».

### 10.2 Los pasos del manual que cambian (no lo edité)

| Sección | Qué cambia con la 2b |
|---|---|
| 3.2 Abrir un BAPLIE | El aviso «Celda reservada sin matrícula» entre las posiciones mal formadas; qué quiere decir «Matrículas repetidas» para la operación |
| 5.2 Nube y cuenta | Un plan con una matrícula repetida no se publica ni se agrega; «Empezar una operación nueva» después de cerrar, y qué pasa al abrir otro archivo de una escala cerrada |
| 7.3 El modo Carga y 7.7 El modo Descarga | La ficha del plan con una matrícula repetida y la celda que responde |
| 7.8 El listado de la agencia | Las agencias con sus secciones; la tarjeta de las celdas sin dueño, que sale al elegir el último tipo, con «Sí», «Otro tipo…» y «No»; el lápiz, que conserva el código anterior como «también llena» |
| 7.9 Cargar por OR desde el muelle | El motivo, justo debajo del aviso que lo pide |
| 7.11 Cerrar la operación | La cerrada se sigue viendo; cómo se empieza otra |
| 8.2 El BAPLIE de salida | El aviso de la matrícula repetida; «1 conflicto vigente» |
| 10. Mensajes y qué hacer | Los mensajes nuevos, con su acción |

## E2b-11. Para quien acepte

Todo corre con el semáforo. `<corpus>` es la carpeta del corpus; el caso nunca se copia al repositorio.

**1. Las rojas (E2b-2).** En una copia de `v1.0.2` de fuera del repositorio, copiar `test/support/t147e2_support.dart` y los cuatro archivos `test/t147e2b_repetida_test.dart`, `test/t147e2b_otra_operacion_test.dart`, `test/t147e2b_huella_test.dart` y `test/t147e2b_listado_test.dart`, y correrlos: fallan 26 de 40. En una copia de `912daac`, copiar `test/t147e2b_revision_test.dart`: fallan 12 de 15. Las dos copias que usé siguen en `%TEMP%\t147-e2b\v102` y `%TEMP%\t147-e2b\p2a`.

**2. Las cifras del caso (E2b-4):**

```powershell
dart run tool/t147e2_caso.dart --plan "<corpus>\CORPUS_A09.edi" --listado "<corpus>\LISTADO_A09.xlsx" --salida build/t147/e2b/caso/otra.json
```

Todo menos `parte2b` tiene que ser igual a `build/t147/e2a/caso/caso-2a.json`.

**3. El corpus (E2b-7):** `tool/t147_corpus.dart` como en la entrega 1, y `--comparar` contra `build/t147/e2a/corpus/despues.json`. Solo cambia `LISTADO_A09.xlsx`.

**4. El banco y los dos recorridos (E2b-5):**

```powershell
flutter build web --release --no-pub --no-web-resources-cdn -t tool/t147_main.dart --output=build/t147/e2b/banco/web
```

```powershell
python -X utf8 tool/t147e2_listado_revisado.py --origen "<corpus>\LISTADO_A09.xlsx" --salida "$env:TEMP\t147-e2b\caso\LISTADO_A09_REVISADO.xlsx" --orden 1
```

```powershell
python -X utf8 tool/t147_web.py --web build/t147/e2b/banco/web --caso "<corpus>" --caso2 "$env:TEMP\t147-e2b\caso" --salida build/t147/e2b/recorrido/otra-360-dia --perfil otra-360-dia --perfil-nuevo --ancho 360 --alto 800 --consulta "escenario=recorrido2b&plan=CORPUS_A09.edi&listado=LISTADO_A09.xlsx&listado2=LISTADO_A09_REVISADO.xlsx&escala=GTSTC&tema=dia&bahia=18&prefijo=otra-&elegir=tipo:45HC=L5G1,tipo:20OT=22U1,tipo:40FF=42P3,tipo:40HF=45P3,tipo:40OT=42U1,tipo:40RF=42R1"
```

- `escenario=repetida2b` con `plan=` un plan con una matrícula en dos celdas, en la carpeta de `--caso2`. El mío sale del caso cambiando un solo `EQD` (`build/t147/e2b/herramientas/plan_repetido.py.txt`). Con `listado=` vacío, lo corre sin listado.
- Cada corrida va en su carpeta y con su perfil. Cambiar `--ancho 1366 --alto 690` y `tema=noche` para las otras combinaciones.
- `pasos.jsonl` dice, en cada paso, lo que el banco leyó: las agencias, si la tarjeta sale, si las tres fichas van en una línea, el lápiz, y si el aviso, el motivo y «Confirmar carga» están a la vista.

**5. La medición (E2b-6):** los tres bancos se compilan con el mismo comando, en la copia de cada versión. El guion que usé está en `build/t147/e2b/herramientas/medir2b.sh.txt`: prepara y después alterna `escenario=medir` con `--cpu 4`.

**6. La nube (E2b-5):** contra el emulador, nunca contra producción.

```powershell
python -I tool/t143_emulador.py iniciar
```

```powershell
flutter build web --release --no-pub --no-web-resources-cdn -t tool/t130_emu_main.dart --dart-define=T130_HOST=127.0.0.1 --dart-define=T130_PROJECT=demo-t143 --output=build/t147/e2b/web-emu
```

Servir esa carpeta en `127.0.0.1:5943`, levantar `python tool/t143_control_web.py servidor` y conducirlo con `tool/t143_banco.py`, como en T-143.

**Lo que conviene mirar con ojos propios:**
- las tres decisiones de E2b-3.2: el listado no viaja a la operación nueva, la cerrada deja de verse al empezar otra, y cómo se elige la que se ve;
- las tres pruebas de la entrega 1 que cambian (E2b-3.10);
- la ayuda del motivo, que acorté (E2b-3.8);
- el texto de O-147-5, que no es el de la propuesta (E2b-3.5).

## E2b-12. Lo que no hice o no pude

- **Descarga con la matrícula repetida, en pantalla.** Está probada con sus pruebas de widget (la ficha y la primera celda que responde, a 360 dp), pero no la recorrí en el banco: el caso no trae plano de llegada.
- **El teléfono de verdad.** Todo lo de 360 × 800 es la Web del banco en Chrome y la app de Windows a ese tamaño. No toqué el Honor.
- **Un muelle en la 1.0.2 frente a la operación nueva.** Lo que digo en E2b-9 sale de leer su código.
- **La nube, a 360 × 800 y de noche.** El recorrido del emulador fue como oficina, a 1920 × 1080 y de día.
- **La medición en Windows, en un teléfono y con un plan más grande.**
- **Qué cambia el paso de la máquina entre una serie y otra** (E2b-6). Lo vi y lo cuento; no lo expliqué.
- **Un selector de operaciones de la misma escala.** Al empezar una operación nueva, la cerrada deja de verse en ese equipo (E2b-3.2).
- **`DESIGN.md`, el manual, `SPRINT-4.md`, `AGENTS.md`, `CLAUDE.md` y `README.md`:** no los edité. El texto para `DESIGN.md` y los pasos del manual están en E2b-10.
- **Git, las Release de publicación y publicar:** no ejecuté ninguna escritura de Git ni `git status`, no compilé ninguna Release de publicación y no publiqué nada.
- En la cuenta de Carlos no abrí la BayStream instalada ni toqué `%LOCALAPPDATA%\BayStream` ni la carpeta de la MSIX.

**Una cosa que vi y no es de esta parte:** en «Asignar vacío», a 360 dp, la línea «Reservas libres: primero las de su grupo.» se monta sobre el rótulo de «Celda reservada». Ya estaba en la 2a. No lo toqué.

## E2b-13. Los archivos

**`lib/`, modificados (22):**

- `lib/features/vessel/data/services/baplie_parser_service.dart`
- `lib/features/vessel/data/services/export_list_parser_service.dart`
- `lib/features/vessel/domain/entities/export_list.dart`
- `lib/features/vessel/domain/entities/vessel_voyage.dart`
- `lib/features/vessel/domain/services/departure_baplie_writer.dart`
- `lib/features/vessel/domain/services/discharge_progress.dart`
- `lib/features/vessel/domain/services/export_list_cross_checker.dart`
- `lib/features/vessel/domain/services/loading_operation.dart`
- `lib/features/vessel/domain/services/operation_sources.dart`
- `lib/features/vessel/domain/services/operation_state_deriver.dart`
- `lib/features/vessel/presentation/pages/cloud_page.dart`
- `lib/features/vessel/presentation/pages/departure_baplie_page.dart`
- `lib/features/vessel/presentation/pages/export_list_import_page.dart`
- `lib/features/vessel/presentation/pages/operation_progress_page.dart`
- `lib/features/vessel/presentation/providers/discharge_provider.dart`
- `lib/features/vessel/presentation/providers/export_list_providers.dart`
- `lib/features/vessel/presentation/providers/sync_providers.dart`
- `lib/features/vessel/presentation/widgets/bay_plan_view.dart`
- `lib/features/vessel/presentation/widgets/dialogo_agregar_plan.dart`
- `lib/features/vessel/presentation/widgets/loading_controls.dart`
- `lib/features/vessel/presentation/widgets/loading_plan_controls.dart`
- `lib/features/vessel/presentation/widgets/resumen_del_modo.dart`

**`lib/`, nuevo (1):** `lib/features/vessel/domain/services/repeated_containers.dart`

**`test/`, nuevos (5):** `test/t147e2b_repetida_test.dart`, `test/t147e2b_otra_operacion_test.dart`, `test/t147e2b_huella_test.dart`, `test/t147e2b_listado_test.dart` y `test/t147e2b_revision_test.dart`

**`test/`, modificado a propósito (1):** `test/t147_listado_test.dart` (E2b-3.10)

**`tool/`, modificados (2):** `tool/t147_conductor.dart` (los escenarios `recorrido2b` y `repetida2b`; `medir` no se tocó) y `tool/t147e2_caso.dart` (el bloque `parte2b`)

**`docs/`:** este informe, `docs/T147-RESULTADOS.md`

- **`pubspec.yaml` y `pubspec.lock` no cambian.**
- La evidencia, en `build/t147/e2b/` (no se versiona): `registros/`, `caso/`, `corpus/`, `recorrido/`, `nube/`, `medicion/` con `medicion.json`, `entre-versiones/`, `herramientas/` y los bancos.
- Fuera del repositorio quedan `%TEMP%\t147-e2b\v102` y `%TEMP%\t147-e2b\p2a`, las copias de las rojas, y `%TEMP%\t147-e2b\limpia`. Lo que salía del caso (la revisión del listado, el plan repetido, el plano de llegada, el listado guardado y los perfiles de Chrome) lo borré.

## E2b-14. Git (lo ejecuta Carlos)

```powershell
git add -- lib/features/vessel/data/services/baplie_parser_service.dart
git add -- lib/features/vessel/data/services/export_list_parser_service.dart
git add -- lib/features/vessel/domain/entities/export_list.dart
git add -- lib/features/vessel/domain/entities/vessel_voyage.dart
git add -- lib/features/vessel/domain/services/departure_baplie_writer.dart
git add -- lib/features/vessel/domain/services/discharge_progress.dart
git add -- lib/features/vessel/domain/services/export_list_cross_checker.dart
git add -- lib/features/vessel/domain/services/loading_operation.dart
git add -- lib/features/vessel/domain/services/operation_sources.dart
git add -- lib/features/vessel/domain/services/operation_state_deriver.dart
git add -- lib/features/vessel/domain/services/repeated_containers.dart
git add -- lib/features/vessel/presentation/pages/cloud_page.dart
git add -- lib/features/vessel/presentation/pages/departure_baplie_page.dart
git add -- lib/features/vessel/presentation/pages/export_list_import_page.dart
git add -- lib/features/vessel/presentation/pages/operation_progress_page.dart
git add -- lib/features/vessel/presentation/providers/discharge_provider.dart
git add -- lib/features/vessel/presentation/providers/export_list_providers.dart
git add -- lib/features/vessel/presentation/providers/sync_providers.dart
git add -- lib/features/vessel/presentation/widgets/bay_plan_view.dart
git add -- lib/features/vessel/presentation/widgets/dialogo_agregar_plan.dart
git add -- lib/features/vessel/presentation/widgets/loading_controls.dart
git add -- lib/features/vessel/presentation/widgets/loading_plan_controls.dart
git add -- lib/features/vessel/presentation/widgets/resumen_del_modo.dart
git add -- test/t147_listado_test.dart
git add -- test/t147e2b_repetida_test.dart
git add -- test/t147e2b_otra_operacion_test.dart
git add -- test/t147e2b_huella_test.dart
git add -- test/t147e2b_listado_test.dart
git add -- test/t147e2b_revision_test.dart
git add -- tool/t147_conductor.dart
git add -- tool/t147e2_caso.dart
git add -- docs/T147-RESULTADOS.md
git commit -m "Sprint 4: T-147, entrega 2, parte 2b: la matricula repetida no entra a la nube, otra operacion despues de cerrar, la huella del viaje, las secciones del listado, el motivo a la vista y el lapiz"
git push origin t147-piloto4
```

- Los tres archivos de `windows/flutter/` siguen modificados solo de fin de línea: no entran.
- `docs/T147-RESULTADOS.md` es mi informe de la tarea, por su nombre exacto.

## E2b-15. En tres líneas

1. Un plan con una matrícula en dos celdas ya no entra a la nube, y en el equipo solo se opera con el defecto a la vista; después de cerrar una operación se puede empezar otra de la misma escala, con el mismo archivo o con otro.
2. La huella del viaje se calcula una vez y el teclado tarda la mitad; el listado cuenta dos agencias y no cinco; el motivo queda a la vista en el teléfono; el lápiz conserva el código anterior, con una salvedad.
3. Suite 2412 de 2412 y `analyze` en cero, aquí y en copia limpia; 26 de 40 rojas contra `v1.0.2` y 12 de 15 contra la 2a; el caso, igual que en la 2a.

## E2b-16. Para Yov

> Yov: está la parte 2b de la entrega 2 de T-147, en `docs/T147-RESULTADOS.md` («Entrega 2 · Parte 2b», E2b-0 a E2b-17), sin commit. Los nueve puntos, en orden, cada uno con su roja guardada: 26 de 40 contra `v1.0.2` y 12 de 15 contra `912daac`. Suite 2412 de 2412 (2357 más 55) y `analyze` en cero, aquí y en copia limpia. `pubspec` no cambia.
>
> La medición, alternada y con la CPU ÷ 4: el teclado baja de 664 a 379 ms con la huella (y de 999 a 498 en la otra serie), y la 2a no quedó más lenta que la 1.0.2 (664 contra 666; 999 contra 1005). Lo de GLM es el paso de la máquina: una serie entera me salió una vez y media más lenta para los tres bancos, y una corrida suelta de la 2a, también (E2b-6).
>
> Cuatro cosas para que mires:
> 1. **P8 a)** (E2b-3.2): el botón es «Empezar una operación nueva», en «Nube y cuenta». Tres decisiones mías, que Carlos ya confirmó: la operación nueva lleva los planos y no el listado; al empezarla, la cerrada deja de verse en ese equipo; y se distingue por una fecha posterior al cierre, sin guardar nada nuevo. Con otro archivo, la nueva nace sola.
> 2. **O-147-10** (E2b-3.9): vi un caso en que la regla estorbaba, lo pregunté antes de programar y Carlos eligió «con la salvedad»: el código anterior no se queda si otro tipo ya lo tiene de principal.
> 3. **Tres pruebas de la entrega 1 cambian a propósito** (E2b-3.10), por la 10.161.
> 4. **Dos textos que no son los de la propuesta:** el aviso de O-147-5 es «Celda reservada sin matrícula: «…»», para que la 1.0.2 lo cuente como caso; y la ayuda del motivo quedó en «Viaja con el movimiento.» (E2b-3.5 y 3.8).
>
> La nube se miró contra el emulador (`demo-t143`), con diez capturas en `build/t147/e2b/nube/`. Lo que no hice está en E2b-12: Descarga con la repetida en pantalla, el Honor, y un muelle en la 1.0.2 frente a la operación nueva.

## E2b-17. Las horas del reloj

| Tramo | De | A |
|---|---|---|
| Paso 0, lectura y diseño de P5 y P8 a) | 09:23 | 09:32 |
| Programar los nueve puntos, con sus pruebas | 09:32 | 10:19 |
| La suite, las copias, las rojas, el corpus y el caso | 10:19 | 10:29 |
| Los bancos y los recorridos Web | 10:29 | 10:40 |
| La medición, dos series | 10:40 | 11:02 |
| Windows, el emulador y la nube | 11:02 | 11:12 |
| Las validaciones finales y el informe | 11:12 | 11:23 |

**Unas dos horas de reloj,** contra las 7.5 que estimé en la propuesta para menos puntos. P8 a), que estimé en 2.5 horas, salió en menos de una.
