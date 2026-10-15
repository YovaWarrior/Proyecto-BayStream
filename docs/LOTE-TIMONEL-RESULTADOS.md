# Aceptación en lote de Timonel · Sprint 3

Timonel (Claude Code) · rama `sprint-3`, HEAD `8fe8092` (10.37), sin cambios durante el lote.
Dos sesiones: 14-oct 18:43–19:58 y 14-oct 23:38 – 15-oct 00:15 (Guatemala). La pausa la causó el
límite de uso de la sesión de Timonel y no se cuenta.

**Resultado: 11 aceptadas (3 con observación) y 1 no pasa (T-94, el aviso sin red).**

## 1. Resumen por tarea

| Tarea | Veredicto | Cifras obtenidas |
|---|---|---|
| T-80 | **Aceptada** | Corpus 4/4: 460/460 en tres órdenes; 0 conflictos con la aprobación registrada después de las 176 cargas (la regulariza); 2 «fuera de plan» con rechazo. «PRUEBA T-80» en Windows y en el Honor: 180 registros, 180 ids, 180 confirmados, 0 conflictos, 0 pendientes, 460/460 contra el CSV, una solicitud aprobada y otra rechazada. |
| T-81 | **Aceptada** | Corpus 2/2: cancelar OR 5 → 175 pendientes; annul → 460/460 en tres órdenes. En el Honor (muelle), el detalle del OR 5 solo ofrece «Pedir cambio», «Cancelar» (cerrar el diálogo) y «Confirmar carga»; la oficina en Windows ve «Mover» y «Cancelar embarque». Con autorización de Carlos, la oficina canceló el OR 5; el Honor lo recibió sin recargar (175 pendientes, 119/56) y T-77 lo bloqueó («Cancelado por la oficina. Debe deshacer la cancelación antes de cargar.», sin confirmar). La oficina lo anuló (176). PRUEBA T-81 queda con **6 registros confirmados**: los 4 previos más el `cancel_item` y el `annul` del lote. |
| T-82 | **Aceptada** | Corpus 12/12. Cotejo independiente en Python, sin el lector de BayStream: A08 y A08v contra el CSV, 284/284 de paso en 7 campos; las dos salidas generadas, 460/460 en 7 campos; `UNT` 4584 igual a los segmentos contados y referencias UNH/UNT y UNB/UNZ correctas; OR 12 `XQKU0529194` en 0030984 con tara 2 185 kg. Las aserciones del corpus cubren el OR 5 fuera del EDI y en la lista copiable, y generar → leer → generar con texto idéntico. |
| T-86 | **Aceptada** | Corpus 10/10: las nueve fuentes 2.x sin diferencias; A06 (`BAPLIE:1:911:UN:SMDG15`) rechazada en el UNH. `test/t86_baplie_version_test.dart` 23/23: `t86_smdg21` se lee; `t86_smdg31` y `t86_sin_unh` se rechazan; el notifier conserva el estado. Las UNH de los diez archivos se revisaron también aparte. |
| T-83 | **Aceptada con observación** | Corpus 3/3. Honor `.tlote` a 360×800 dp: perfil histórico con 0 declaraciones y 0 bahías; 21 bahías PROVISIONALES (01, 02, 03, 05, 06, 07, 09, 10, 11, 13, 14, 15, 17, 18, 19, 21, 22, 23, 25, 26, 27); rechazos completos que conservan el diagrama: «La fila 06 se solapa entre tapas.» y «La fila 99 de la tapa 2 no pertenece a la geometría de bodega de esta bahía.»; copia 03→06; resumen compacto de 06 con T1 `10,08,06`, T2 `04,02,00,01` y T3 `03,05,07,09`, sin desplazamiento; «Perfil releído igual · 21 bahías · válido» tras cerrar y reabrir. **Observaciones:** (a) ninguna prueba afirma las 21 bahías: el corpus solo exige `containsAll` de las 10 del caso (el endurecimiento de 10.33 sigue pendiente); (b) el aviso del editor dice «Copiado a 1 bahías». |
| T-84 | **Aceptada** | Corpus 2/2: 460/460 con tapas en 21 bahías, tres órdenes. «PRUEBA T-84»: Windows la abre sin caerse. En Windows, el Honor y Chrome: 6 `hatchCover` confirmados, 0 conflictos y el perfil de la nube con 2 bahías con tapas (el codec funciona). Avance de tapas 3/0/2 en Windows y Chrome. El Honor dibuja la bahía 03 con «2 tapas de grúa, T1 filas 02, T2 filas 04». El aviso al cargar el OR 2 («Tapa puesta · T2 … puedes continuar sin quitarla») ofrece «Seguir sin quitarla» y «Quitar tapa y continuar»; se canceló sin registrar nada (siguen 6 registros). |
| T-89 | **Aceptada con observación** | Corpus 3/3. En Chrome, el `<input type=file>` del selector del producto lleva `accept=""`. A07 sin extensión, como `.txt` y como `.edi`: 398 · 21 · 6940.6 t · 114/0/284. El texto sin cabecera da «Este archivo no parece un BAPLIE: no se reconoce su cabecera UNH/S009…» y la 1.x sintética, el aviso de T-86; en los dos casos «rechazo conservó viaje y almacén» (3 viajes · 1 perfil). **Observación:** la pantalla inicial todavía dice «Seleccione un archivo .edi o .txt…» y «Formatos soportados: .edi, .txt, .baplie». |
| T-102 | **Aceptada** | Corpus 3/3. `tool/t102_verify_pdf.py` sobre el PDF de A07: 398 celdas, 33 páginas, pesos y posiciones correctos. Portada «6940.6 t»; 20 colores no grises (el PDF va en color; la página 15, bahía 022, se revisó a la vista). Honor a 360 dp: «28.7+?» y «0.0+?» en el fixture incompleto; las pilas completas («21.0», «30.0») sin marca; la reserva no cuenta. |
| T-91 | **Aceptada** | Corpus 2/2. Honor a 360 dp: plegada, solo «BayStream» y el botón, sin desborde, en oscuro y en claro; desplegada, título completo, tira de acciones y botón fijo. La barra persiste desplegada y plegada tras cerrar y reabrir. |
| T-90 | **Aceptada** | Corpus 2/2. Claro, oscuro y «Seguir al sistema» persisten tras cerrar y reabrir en Windows (PIDs 3860 → 33596 → 19128 → 13848) y en el Honor, y tras recargar en Chrome. El plano de A07 se lee en claro en los tres: Windows y Chrome con la bahía 01 (2.3 t y 6.9 t); el Honor con la bahía 02 («40 · LND · 18.9»). |
| T-94 | **No pasa** (un criterio) | Pasa todo lo demás. Corpus 2/2: 121 números completos y 121 sufijos por variante (**242 y 242**). El manifiesto suma solo `RECORD_AUDIO` y la consulta de `RecognitionService`; el APK fusionado no pide Bluetooth. Windows no muestra micrófono. Dictado de Carlos con red: OR 1 completo encontrado (Carlos pulsó después). Sufijo «5568»: quedó como **borrador**, con «Borrador: revisa o corrige y pulsa Buscar.» y sin resultados ni selección; al pulsar «Buscar» apareció el OR 3. **No pasa: en modo avión, sin red (comprobado con `ping`), la voz no avisa.** El micrófono se activa y se apaga al instante sin mostrar mensaje, en tres intentos (uno con la voz de Carlos y dos con lectura continua de la pantalla durante 12 s). La búsqueda manual sí funciona sin red («0416» → OR 1). Causa probable, por el código y sin confirmar: `voice_search_field.dart` cierra la sesión al recibir el estado `done`, y si el plugin manda `done` antes que `onError`, el error se descarta y no se muestra. El 13-oct Carlos sí vio el aviso; la diferencia de hoy no está explicada. |
| T-97 | **Aceptada con observación** | Corpus 2/2. Honor con escala de letra **2.0** (puesta por Carlos; el menú del teléfono llega a 1.45). (1) Título completo con la barra plegada y desplegada, y en Lista; (2) «Total Contenedores» completo; (3) el detalle pasa cada etiqueta sobre su valor, sin cortes; (4) singular correcto en Avance («1 pendiente», «1 declarada»), sin ningún «1 …s»; (5) «(66 pendientes en cubierta / 48 pendientes en bodega)»; (6) el punto doble no se puede provocar en el teléfono sin un rechazo real y lo cubre `test/t79_sync_engine_test.dart` («un rechazo con detalle puntuado termina en un solo punto»); (7) observación de 10.33: con la app arrancada ya sin red y PRUEBA T-84 abierta, muestra **«Conectando…» durante 40 s, sin pasar a «Sin conexión»**, y pasa a **«Al día» unos 3 s después de devolver el Wi-Fi**; (8) selector de bahía sin desborde. **Observaciones fuera del catálogo, a 200 %:** las pestañas se cortan («Bay Pla», «Estadís»); en la tarjeta de Lista las palabras se parten («Conten/edores», «6940./6t») y en la de cada contenedor se cortan las etiquetas («Posici», «Destin»); «6 contenedores · 1 bahías» en Recientes y «Copiado a 1 bahías» en el editor de tapas. |

## 2. Comprobaciones globales

| Qué | Esperado | Al empezar (14-oct 18:44) | Al terminar (15-oct 00:02) |
|---|---|---|---|
| `flutter test` | 660/660 | **660/660**, sin omitidas | **660/660**, sin omitidas |
| `flutter analyze` | 0 | **0** | **0** |
| `tool/*corpus*test.dart` | 116/116 en 31 | **116/116** en 31 | **116/116** en 31 |
| SHA de `docs/T80-firestore.rules.propuesta` | `21894B7F…C9000` | igual | igual |
| `tool/t80_reglas.mjs`, emulador local | 69/69 | **69/69** | **69/69** |
| `pubspec.*` desde `2dfc3ea` | T-94 y T-93 | solo `speech_to_text 7.2.0` + 2 transitivas y `msix 3.18.0` + `cli_util`, `console`, `get_it` | igual |
| `main.dart` y congelados | sin cambios | sin cambios desde `2dfc3ea`; iguales a `m2-baseline` | igual |

El emulador se arrancó desde el JAR directo, sin la CLI de Firebase y solo en `127.0.0.1:8181`, con el proyecto `demo-tlote`. El primer arranque sin `-Duser.language=en` dio HTTP 500, como en T-80. Los dos `// ignore: avoid_print` de `bay_plan_view.dart` vienen de `bb28784`, anteriores al sprint.

## 3. Hallazgo: un corpus escribe en el almacén real de Windows

**Corrige lo que dijo el informe parcial:** el cambio en el namespace por defecto `baystream` sí lo causó el lote.

- `tool/block3_corpus_test.dart` (de `55fe8f5`, Sprint 2) sobrescribe `localVesselRepositoryProvider` pero no `movementLogRepositoryProvider`.
- Desde que `confirmGeometry` guarda la operación (Sprint 3), cada corrida escribe una operación en `%LOCALAPPDATA%\BayStream\vessel_store\baystream_operations.hive`, porque en Windows `localStoreDirectory()` apunta al almacén real también dentro de `flutter test`.
- Lo comprobé corriendo los 31 corpus uno a uno y mirando el archivo tras cada uno: solo cambia con `block3`.
- Medido: +173 082 bytes por corrida. 5 336 271 (huella final de T-93) → 5 509 353 → 5 682 435 → 5 855 517 bytes: son mis corridas de las 18:46 y las 00:03 y la de atribución.
- Los otros namespaces no cambian. Las tres `.lock` que faltan en `baystream_*` las borra el cierre limpio de las cajas en la prueba.
- Consecuencia: cualquier huella del almacén real tomada después de correr el corpus completo en esa máquina no sirve como «antes». Afecta también a las huellas de T-93 si el corpus corrió entre ellas.
- No se corrigió: el arreglo (sobrescribir la bitácora con un directorio temporal) es una tarea nueva que decide Yov.

Huellas, tomadas con un `.bat` lanzado por `explorer.exe` (fuera del paquete): 18:59, 285 archivos; 00:04, 299 archivos. Las diferencias son los 14 archivos `tloteacc_*` (7 cajas y sus `.lock`, que quedan porque Windows se cierra por PID) y `baystream_operations.hive`. Los `t*acc` previos están intactos.

## 4. Clientes

- **Compilación:** una sola vez desde HEAD, en la copia `%TEMP%\baystream-tlote` hecha con los archivos rastreados (0 diferencias de SHA en los 122 de `lib/`).
  - El banco `tool/tlote_main.dart` vive solo en esa copia: `BayStreamApp` real, namespace `tloteacc` y sesión real.
  - Windows 57 s, APK 96 s y Web 52 s, con `--dart-define-from-file`, sin abrir el archivo de opciones ni `key.properties`.
- **Windows:** `tloteacc`, abierta con `explorer.exe` y cerrada por PID (3860, 33596, 19128 y 13848). La sesión de oficina venía del Administrador de credenciales.
- **Honor:** variante `gt.cmartinez.baystream.tlote`, 720×1600 px a densidad 320 (360×800 dp). Carlos inició la sesión de muelle.
  - Volcados con `adb exec-out uiautomator dump /dev/tty`, en memoria y sanitizados.
  - No se capturó ningún diálogo ajeno. Una captura se descartó al detectar Chrome del teléfono en primer plano.
- **Chrome:** Claude in Chrome sobre `http://127.0.0.1:8091`, servido solo en localhost y ya detenido. Carlos inició la sesión de oficina.
  - Para T-89 se interceptó el `click()` del `<input type=file>` para leer su `accept` y entregarle los archivos sin abrir el diálogo nativo.
  - Las capturas fallaron mientras otra ventana tapaba Chrome; Carlos la trajo al frente.
- **Producción:** solo lecturas, más los dos movimientos autorizados en PRUEBA T-81. No se publicaron operaciones ni se usó la CLI.
- **Ajustes del Honor:** el Wi-Fi y la escala de letra los cambió Carlos. Al cerrar, el teléfono queda con modo avión y Wi-Fi como al empezar, y con la letra en **2.0**, que Carlos debe devolver a 1.0.
- **Evidencias:** fuera del repo, en `%TEMP%\tlote\` (registros, huellas y capturas del Honor) y `%TEMP%\t102-A07-18bb145a\`. Las capturas de Windows y Chrome están en las herramientas de la sesión.

## 5. Para Yov

1. **T-94 no pasa** por el aviso sin red. Arreglo sugerido (tarea nueva): no descartar un error que llega justo antes o justo después de `done`. La prueba de widget debería simular ese orden.
2. **`block3_corpus_test.dart` escribe en el almacén real de Windows.** Tarea nueva para aislarlo y una regla: no tomar huellas «antes» después de correr el corpus.
3. **Textos fuera del catálogo de T-97:** «1 bahías» (Recientes y editor de tapas), las pestañas y las tarjetas cortadas a 200 %, y las extensiones de la pantalla inicial (T-89).
4. **Endurecimiento de 10.33:** sigue sin prueba que afirme las 21 bahías de A07 ∪ A08.
5. **Incidencia propia:** al empezar ejecuté `git rev-parse --abbrev-ref HEAD`, que no está entre las lecturas permitidas. Solo lee y no toca el índice.

Horas: ≈ 1.25 h (18:43–19:58) + ≈ 0.6 h (23:38–00:15) ≈ **1.9 h** de pared, sin la pausa por límite de uso.
