# T-79 · Sincronización: cuentas, Firestore, reglas y cola sin conexión, con la aceptación de T-78

Timonel · 8 y 9-oct-2026 · rama `sprint-3`, sobre `221b9f3`; C9 y C10 sobre `7806741` · carril de `lib/`, `test/`, `tool/` y `pubspec.*`

## 1. Resultado

| Tarea | Resultado |
|---|---|
| **Aceptación cruzada de T-78** (`1880266`, de Codex) | **PASA** en Windows a 1920×1080, en el Honor a 360 dp y en Chrome, antes de tocar `lib/` (sección 2). No se cambió su código |
| **T-79** (suite, reglas, motor y dos dispositivos contra el emulador) | **Hecha y aceptada contra el emulador**: 7.1 y 7.2 completas; de 7.3, C1, C2 y C5 a C8 pasan, y C4 pasa en su primera parte (sección 6) |
| **T-79 en producción** (C9 y C10, 9-oct) | **C9 PASA** en `baystream-app` con Windows, el Honor y dos pestañas de Chrome; el corte de red de Windows vuelve a «Al día» en **36 s**. **C10:** 23 escrituras, exactas, y 103 lecturas (sección 7) |

- **Pruebas:** **485/485** en dos corridas seguidas (piso 459 + 26 nuevas). `flutter analyze` en **cero**, sin `// ignore:`.
- **Reglas:** **54 de 54** en el emulador (los 51 casos de T-79a 5.4 y 3 nuevos), con 13 documentos en `movements`.
- **Corpus:** **50/50**: los 48 de T-68 a T-78, que dan lo mismo que antes, y los 2 nuevos de T-79.
- **Dependencias:** `firebase_auth` **6.5.7** y `crypto` **3.0.7** directas, con versión fija. **Cambian `pubspec.yaml` y `pubspec.lock`** (sección 3.6).
- **`lib/main.dart` no se tocó**: no hizo falta (sección 3.5). Tampoco los congelados de H5 ni `docs/T79a-firestore.rules.propuesta`, que queda igual y es el archivo final.

**Lo que quedó abierto el 9-oct en la madrugada, y cómo se cerró:**
1. **C9 y C10** esperaban los pasos de consola de Carlos. **Hechos el 9-oct por la tarde** (sección 7).
2. **C4, dos pestañas a la vez:** **pasa en producción** (7.4): nada se pierde ni se duplica, y la sesión sobrevive a recargar.
3. **El límite de 1000 expresiones** (5.2): en producción el cliente solo recibe «Missing or insufficient permissions», sin el detalle. No se puede ver desde la app; queda para T-80, como decidió 10.15 (7.6).
4. **Windows «Sin conexión» más de dos minutos** (6.5): **no se repite en producción**. Tras un corte real de red, vuelve a «Al día» en 36 s. No hizo falta tocar el código (7.3).

**Lo que sigue abierto:** las **48 eliminaciones** que muestra la pestaña Uso no salen de la app ni de Carlos (7.7), y dos textos menores para T-97 (7.8).

## 2. Aceptación cruzada de T-78

Hecha **antes de tocar el código**, sobre `221b9f3` (que incluye `1880266`):
- suite **459/459**;
- `analyze` en cero;
- corpus de T-68 a T-78 en **48/48**: los 6 de T-78 comparan 290 pasos contra el conteo independiente en cada orden.

**Banco privado:** el banco de Codex de T-78, sin cambiar su lógica, copiado con el código de `HEAD` en `%TEMP%\baystream_t79_acceptance\app`.
- **Namespace:** `t79acc`.
- **Variante del Honor:** `gt.cmartinez.baystream.t79`.
- **Corpus:** como assets del banco, fuera del repositorio.
- **Lo que no se copió:** `android/key.properties`, `local.properties` ni ajustes locales. El clasificador de permisos frenó la copia completa del árbol, con razón: llevaba la firma de Play.

| Criterio | Windows 1920×1080 (DPR 1.5) | Honor 360 dp | Chrome |
|---|---|---|---|
| Al empezar: descarga **114 (66/48)**, carga **176 (120/56)**, cero hechos, cero conflictos | PASA | PASA | PASA |
| Al final (290 pasos, 290/290 contra el conteo independiente): **0 pendientes**, 114/120/56 hechos y **2 conflictos** (014-01-02 y 014-01-08) | PASA | PASA | PASA |
| Con 90 t de límite de prueba, las pilas van **aparte**: «Conflictos · 2» y, en otra sección, «11 pilas sobre su límite» (014 bodega fila 01: 121.2 t / 90.0 t) | PASA | PASA | PASA |
| Tras «Corregir OR 1», el detalle dice **«Deshacer corrección»** (291 registros) | PASA | PASA | PASA |
| Límite quitado al terminar | Sí | Sí | Sí |

**Dónde se probó:**
- **Windows:** el almacén real, `%LOCALAPPDATA%\BayStream\vessel_store`. Abierta con `explorer.exe` y cerrada por PID (31604).
- **Honor:** 720×1600 a DPR 2.0. Al terminar, la variante quedó detenida y el teléfono en el inicio.
- **Chrome:** propio, con perfil aparte, servido en `127.0.0.1:8801`, con IndexedDB nuevo y manejado por el protocolo de depuración. La pestaña quedó visible durante la prueba.

Evidencia en `%TEMP%\baystream_t79_acceptance\evidence\` (`windows/t78-*`, `honor/t78-*`, `chrome/t78-*`, `t78acc-*.txt`).

## 3. T-79: qué se construyó

El diseño es el de `docs/T79a-DISENO.md`, con los cuatro cambios de 10.14 y lo que salió al probar.

### 3.1 Dominio (Dart puro)

| Archivo | Qué |
|---|---|
| `domain/entities/operation.dart` | `Operation` gana `published`, `closedAt` y `profile`, que se leen con su valor por omisión en las operaciones guardadas antes. Tiene `copyWith` |
| `domain/entities/movement.dart` | `Movement.withReceivedAt` |
| `domain/repositories/session_repository.dart` (nuevo) | `Operator` (uid, nombre, rol, autorizado, de la copia local) y el contrato `SessionRepository`, sin registro |
| `domain/repositories/operation_sync_repository.dart` (nuevo) | `SyncState` y `SyncStatus` con sus contadores, `PublishedOperation` y el contrato: `publish`, `watchOpenOperations`, `join`, `close`, `follow` y `retry` |
| `domain/repositories/movement_log_repository.dart` | La parte de sincronización de T-79a 3.2: `pendingOf`, `acceptRemote`, `markConfirmed`, `markRejected` y `requeueRejected` |
| `domain/services/operation_sources.dart` | Entre una operación local y una publicada de la misma escala manda la publicada. Las fuentes de una publicada no cambian: el mismo texto no hace nada, y otro archivo da un aviso |

### 3.2 Datos

| Archivo | Qué |
|---|---|
| `data/repositories/sync_engine.dart` (nuevo) | **El motor de la cola, en Dart puro**, contra el puerto `RemoteMovementStore` (T-79a 4.1 a 4.6). Se detalla abajo |
| `data/repositories/firestore_operation_sync.dart` (nuevo) | Publicar en un solo lote: la operación, su perfil, el manifiesto y las fuentes en trozos de 300 000 caracteres. Unirse, comprobar la huella y guardar. Cerrar. El puerto sobre `movements` y el códec del sobre |
| `data/repositories/firebase_session_repository.dart` (nuevo) | Correo y contraseña, recuperar contraseña y cerrar sesión. El rol, el nombre y `active` salen de `authorized/{uid}` **en tiempo real**. Guarda el último operador en la caja `{ns}_session`: uid, nombre y rol, nunca el correo ni la contraseña |
| `data/repositories/local_only_operation_sync.dart` (nuevo) | Sin la nube configurada: el modo de un solo dispositivo, sin publicar ni unirse, y sin tocar Firebase Auth |
| `data/repositories/operation_sync_factory.dart` (nuevo) | **Los tres clientes usan Firestore y Firebase Auth (10.8).** Sin Firebase inicializado (las pruebas, o una compilación sin opciones) queda en un solo dispositivo |
| `data/repositories/movement_log_repository_impl.dart` | La regla de `pending` y `localOnly` al anexar, los métodos de la cola y `createdAt` en milisegundos |
| `data/datasources/hive_movement_data_source.dart` | `movement(id)` y `putMovements` con un solo `flush` |

**El motor:**
- **Envía en orden y sin duplicar.** Emite el `set()` de cada pendiente propio una sola vez, en orden de secuencia y sin esperar entre uno y otro. Lo confirma por el `set` o por el eco del listener: basta uno.
- **Reenvía al arrancar, al volver la sesión y en «Reintentar».** El mismo id es el mismo documento.
- **Clasifica los errores como T-79a 4.5:**
  - `unauthenticated` es sesión vencida;
  - un permiso denegado con la cuenta inactiva o fuera de la lista **pausa sin rechazar**;
  - con la cuenta activa, rechaza: «La operación se cerró antes de este movimiento.» si se registró después del cierre, y si no, «La nube rechazó este movimiento: …»;
  - los errores de red dejan el movimiento pendiente.
- **La salvaguarda de 10.5 (umbral PROVISIONAL de 5 minutos).** Si un movimiento propio lleva 5 minutos sin confirmar mientras el listener recibe del servidor, el estado pasa a `unconfirmed`: «Sin confirmar desde las HH:MM · inicia sesión de nuevo». El tiempo sin red no cuenta: el reloj corre desde que vuelve.

**Cuándo nace `pending` un movimiento** (lo decide `append`):
- solo si el autor tiene cuenta, la operación está publicada y no anula ni corrige algo que se quedó en el dispositivo;
- si no, nace `localOnly`, como en el modo de un solo dispositivo.

Así, «sin cuenta, esos movimientos no se suben», y lo registrado antes de publicar se queda local y la pantalla lo dice (10.14).

**`createdAt` en milisegundos.** La Web no guarda microsegundos, y el orden total por `createdAt` tiene que ser el mismo en los tres clientes.

### 3.3 Presentación

| Archivo | Qué |
|---|---|
| `providers/sync_providers.dart` (nuevo) | Sesión, operador y autor de cada movimiento (la cuenta o, sin ella, «Muelle (sin cuenta)»). Sincronización, operación activa, estado de envío, operaciones locales y abiertas |
| `pages/cloud_page.dart` (nuevo) | **«Nube y cuenta»** tiene tres partes: |
| | · **Cuenta:** iniciar sesión, «Olvidé mi contraseña» y cerrar sesión. **No hay registro.** |
| | · **La operación de la escala abierta:** publicar y cerrar, solo para la oficina, y «Reintentar». |
| | · **Las operaciones abiertas en la nube:** unirse y abrir el plano de llegada o el plan de carga, sin el archivo. |
| `widgets/sync_status_chip.dart` (nuevo) | El estado con texto e icono, no solo color: «Al día», «Enviando N», «Sin conexión · N por enviar», «Sesión vencida: inicia sesión para enviar N», «Tu cuenta no está autorizada · N esperan», «Sin confirmar desde las HH:MM», más «N rechazados», «operación cerrada» y lo que queda solo en el dispositivo |
| `pages/vessel_overview_page.dart` | Un botón de nube en la barra. Al mirar el estado, mantiene vivo el motor mientras la escala está abierta |
| `widgets/loading_plan_controls.dart` y `pages/operation_progress_page.dart` | El chip de estado en el plano y en «Avance de la operación» |
| `providers/discharge_provider.dart`, `widgets/discharge_controls.dart` y `widgets/loading_controls.dart` | `appendMovement` y `annulMovement` reciben el autor. El «Deshacer» de un aviso conserva el autor del registro |
| `formatters/vessel_error_message.dart` | Un `ValidationFailure` de dominio se muestra con su texto |

### 3.4 Lo que cambió del diseño de T-79a, y por qué

1. **Windows sincroniza (10.8).** La fábrica da Firestore a los tres clientes, y el adaptador sin nube queda para una compilación sin opciones y para las pruebas. **El apéndice 3.4-A ya no aplica.**
2. **`follow(operation)` en lugar de `status`, `start` y `stop`.** El motor corre mientras alguien mira el estado. El proveedor no se descarta mientras la escala está abierta.
3. **Un solo `SyncStatus` con contadores**, en lugar de una clase por estado. La pantalla siempre puede decir cuántos hay rechazados, de otra cuenta o solo locales.
4. **`closedAt` y `authorizationOf` se leen del servidor, no de la caché.** Salió en C7 (6.6): justo al reconectar, la caché del SDK seguía con la operación abierta, y un rechazo por cierre se clasificó como «la nube rechazó».
5. **El muelle guarda la operación como cerrada** cuando la nube rechaza un movimiento por el cierre, y lo recuerda al reiniciar.

### 3.5 `lib/main.dart`: sin cambios

`main.dart` ya inicializa Firebase antes de `runApp`. Auth y Firestore se obtienen de forma perezosa en `operation_sync_factory.dart`, y los proveedores cuelgan del `ProviderScope` que ya existe.

En Windows, `main.dart` usa las opciones de Android, como en T-70c. Funcionó contra el emulador; contra producción lo dirá C9.

### 3.6 Dependencias

| Paquete | Versión | Por qué esa |
|---|---|---|
| `firebase_auth` | **6.5.7**, fija | La que T-70 y T-70c probaron con `firebase_core` 4.13.0 y `cloud_firestore` 6.8.0. Autorizada en 2.7 |
| `crypto` | **3.0.7**, fija | La huella SHA-256 de las fuentes. Ya estaba en el lock como transitiva, en esa versión. Autorizada en 10.3 |

**En `pubspec.lock`** solo se agregan `firebase_auth`, `firebase_auth_platform_interface` 9.0.6, `firebase_auth_web` 6.2.6 y `http` 1.6.0 (transitiva de `firebase_auth_web`), y `crypto` pasa a directa.

**`flutter pub get` regeneró dos archivos de Windows** que Git sigue, `windows/flutter/generated_plugin_registrant.cc` y `generated_plugins.cmake`: el registro del plugin de `firebase_auth`. Van en el bloque.

## 4. La suite (T-79a 7.1)

**26 pruebas nuevas.**

**`test/t79_sync_engine_test.dart` (13)** usa el motor real sobre la bitácora real en Hive, en una carpeta temporal, contra la nube falsa `test/support/t79_fake_cloud.dart`. Esa nube imita las reglas (crear una vez, reenvío idéntico del autor, lista de autorizados, cierre) y la cola del SDK sin red.

| Prueba de 7.1 | Resultado |
|---|---|
| Nace pendiente con cuenta y operación publicada; sin cuenta, sin publicar o anulando algo local, `localOnly` | PASA |
| Confirma por el `set`, y por el eco cuando el `set` no contesta | PASA |
| Sin red queda pendiente; al volver sube cada id una vez | PASA |
| Reinicio: reenvía los mismos ids; el que ya había llegado es el no-op permitido (1 reenvío idéntico, 3 documentos) | PASA |
| Cuenta inactiva: pausa sin rechazar; al reactivar se envía todo | PASA |
| Permiso denegado con la cuenta activa: ese movimiento queda rechazado, con su motivo; «Reintentar» lo envía si se corrige | PASA |
| Sesión vencida: pausa, los pendientes siguen; al volver a entrar se envían | PASA |
| Operación cerrada: entra lo anterior al cierre; lo posterior, rechazado «La operación se cerró antes…», y el muelle recuerda el cierre | PASA |
| Cambio de usuario: lo pendiente de otra cuenta no se envía con la nueva y espera a su autor | PASA |
| **El falso deja de confirmar sin dar error:** a los 4 min 50 s, «enviando»; a los 5 min 10 s, `unconfirmed` desde la hora del registro | PASA |
| Sin red no cuenta para la salvaguarda | PASA |
| Sin la nube: `LocalOnly`; `publish` y `join` fallan con su mensaje; la sesión local no ofrece cuentas | PASA |

**`test/t79_cloud_codec_test.dart` (7)** prueba lo que viaja sin red:
- el sobre exacto de las reglas, con `Timestamp` y la hora del servidor;
- la ida y vuelta, aunque la tara vuelva entera desde la Web;
- que un documento ilegible se omite;
- la huella del texto tal cual (`3900` y `3900.0` son textos distintos, como vio 10.11);
- los trozos sin partir un par sustituto;
- la lectura de una operación guardada antes de T-79;
- que la operación publicada manda y sus fuentes no cambian.

**`test/t79_cloud_page_test.dart` (6)** prueba la pantalla a 360 dp, en claro y en oscuro:
- sin nube, lo dice y no ofrece registro;
- con cuenta posible, correo, contraseña y «Olvidé mi contraseña», y ningún «Registrar»;
- el error de contraseña, la entrada y la salida;
- el texto de cada estado;
- el chip a 360 dp sin desbordar.

**Las pruebas existentes no cambiaron.** Las tres implementaciones falsas de `MovementLogRepository` usan `noSuchMethod`, así que compilan sin tocarlas.

## 5. Las reglas en el emulador (T-79a 7.2)

### 5.1 La batería

**`tool/t79_reglas.mjs` (nuevo).** El guion de T-79a quedó en un scratchpad que ya no existe, así que lo reescribí con los mismos seis grupos de 5.4, más un grupo de T-79.
- Carga en el emulador `docs/T79a-firestore.rules.propuesta` **tal cual**.
- Borra los datos del emulador y siembra la lista de autorizados.
- Prueba cada caso por la API REST, con tokens sin firmar y la hora del servidor como transformación.
- Con `T79_DETALLE=1`, muestra el motivo de cada denegación.

**Resultado: 54 de 54**, en tres corridas (emulador de Firestore 1.22.0, Firebase CLI 15.32.1, proyecto `demo-t79`):

| Grupo | Casos |
|---|---:|
| Operación y fuentes | 5 |
| Lectura | 9 |
| Movimientos del muelle | 20 |
| Cambio de posición (T-80) | 6 |
| Anular | 5 |
| Cierre | 6 |
| **T-79:** una cuenta inactiva no escribe; `operatedAt` como texto se niega; la huella de una fuente es hexadecimal de 64 | 3 |

Al final, **13 documentos** en `movements`, uno por cada movimiento permitido. El reenvío idéntico no creó otro.

**Las reglas no cambiaron.** El archivo final es `docs/T79a-firestore.rules.propuesta`, igual que en T-79a. Carlos puede publicarlo desde la consola (T-79a 6.4), nunca con `firebase deploy`.

### 5.2 Hallazgo: las denegaciones agotan el máximo de 1000 expresiones

Con `T79_DETALLE=1`, **toda denegación de un movimiento** responde «Unable to evaluate the expression as the maximum of 1000 expressions to evaluate has been reached».

**Qué significa:**
- **El resultado es el correcto**, «denegado», y ninguna escritura válida se negó: entraron las 13 de la batería y **las 182 del SDK real** de la corrida 1 (C2 y C5 a C7).
- Pero el motor de reglas no corta pronto la cadena de `validPayload`.

**Lo que propongo:**
- mirar el mismo detalle en producción con C9;
- si Carlos o Yov lo prefieren, partir `validPayload` por tipo en una tarea aparte, con la batería como red.

No lo cambié: las reglas probadas son las que Carlos va a publicar.

## 6. Dos dispositivos contra el emulador (T-79a 7.3)

### 6.1 Cómo se probó

**El emulador:**
- Auth y Firestore en el proyecto `demo-t79`, con Auth en 9199 y Firestore en 8181.
- Configurado en el scratchpad de la sesión con la copia del JAR 1.22.0 de la espiga de T-70. Ningún proyecto en la nube.

**Las cuentas:** **tres cuentas sintéticas del emulador**, una de oficina y dos de muelle, de las que se usaron la de oficina y una de muelle.
- Las contraseñas son aleatorias y se guardan solo en el scratchpad.
- Ninguna entra al repositorio ni a este informe.

**El banco: `tool/t79_replay_main.dart` (nuevo, en el repositorio).**
- Es la app real (plano, «Nube y cuenta», bitácora, cola y motor) más una barra que prepara las fuentes y reproduce el caso **por `append`**: no escribe documentos a mano.
- Retoma donde quedó tras un cierre forzado y espera la aprobación antes de los OR 128 y 145.
- Sin un proyecto `demo-` no arranca.
- **La compilación privada** agrega el corpus como assets, fuera del repo, en `%TEMP%\baystream_t79_acceptance\app`. Activa `usesCleartextTraffic` en su propio manifiesto, como la espiga de T-70, para llegar al emulador por HTTP.

**Los clientes:**
- **El Honor:** variante `.t79`, con los puertos por `adb reverse`.
- **Chrome:** propio, con perfil aparte, servido en `127.0.0.1:8802`.
- **Windows:** el ejecutable del banco.

**Cómo se corta la red del Honor.** Quitar el `adb reverse` **no corta** la conexión ya abierta: el canal HTTP/2 de Firestore sigue vivo por el túnel. Así pasó en la primera corrida de C2.
- El corte real se hizo **deteniendo el servidor de adb**, que cierra el túnel con todas sus conexiones. Es el equivalente a desconectar la red del teléfono en este montaje.
- El modo avión no sirve aquí: el teléfono llega al emulador por el USB, no por la red.

### 6.2 Resultados

| # | Prueba | Resultado |
|---|---|---|
| **C1** | La oficina publica A08 con su listado; el muelle la ve, se une y abre el plan sin el archivo | **PASA**, dos veces. Windows publicó desde «Nube y cuenta»; el Honor dibujó **405 contenedores y 55 celdas reservadas**, «Al día». Chrome publicó también en C4 y C7 |
| **C2** | Los 177 eventos con corte de red y cierre forzado | **PASA** (6.3): **178 documentos, 178 ids distintos**, y en los dos dispositivos 178 confirmados y **460/460 posiciones** del CSV |
| C3 | Dos tarjadores sin red | Fuera de la ficha de T-79 |
| **C4** | Chrome sin red, recarga, red de vuelta; dos pestañas | **Primera parte PASA:** los 3 pendientes sobrevivieron a la recarga y llegaron **una vez** (3 documentos). **Dos pestañas: no se pudo** contra el emulador (6.4) |
| **C5** | `active = false` a mitad y luego `true` | **PASA:** «Tu cuenta no está autorizada · 2 esperan», con el icono de bloqueo; **0 rechazados** y nada en la nube (178); al reactivar, 180 y «Al día» |
| **C6** | Cuenta deshabilitada en el emulador de Auth | **PASA:** sin Firestore, «1 por enviar». Con la cuenta deshabilitada, «Verificar sesión» la cierra: **«Sesión vencida: inicia sesión para enviar 1»**. Con red y sin sesión no sube nada (180). Habilitada y con sesión: 181 y «Al día» |
| **C7** | Cierre con un pendiente anterior y otro posterior | **PASA tras una corrección** (6.6): A entra y B queda **rechazado** con «La operación se cerró antes de este movimiento.» y «operación cerrada» |
| **C8** | Windows como oficina: publica, ve el avance del Honor en tiempo real y sin los errores de hilo de `firebase_auth` | **PASA** (6.5) |

### 6.3 C2 en detalle

**Corrida 2** (namespace `t79run2`, corte real):
- La oficina, en Windows, enciende la aprobación automática. El Honor empieza a reproducir, y el servidor de adb se detiene a los 14 s.
- **En la nube había 45 documentos** al cortar. La oficina se quedó en 14 llenos y 29 vacíos mientras el muelle seguía.
- **Cierre forzado** (`am force-stop`) con pendientes. Al reabrir sin red: **«Sin conexión · 84 por enviar»**.
- Siguió sin red hasta **«133 por enviar»**: 45 + 133 = 178.
- Red de vuelta: en unos 50 s, la espera de reconexión del SDK, pasó a «Al día».
- Al final, **178 documentos y 178 ids distintos**: 121 `load_full` (120 llenos y el OR 85), 55 `assign_empty`, la solicitud y la aprobación.
- «Comprobar» dio en el Honor y en Windows: 178 registros, 178 ids, **178 confirmados**, **460/460** contra el CSV, 2 conflictos y 0 pendientes de carga.

**Corrida 1** (`t79run1`, sin el corte real antes del cierre) dio lo mismo: 178/178 y 460/460 en los dos.

**Los 2 conflictos** son los «fuera de plan» de 014-01-02 y 014-01-08. El cambio de posición aprobado está en la bitácora y en la nube, pero **lo deriva T-80**. Igual en los dos dispositivos.

### 6.4 C4: lo que se pudo y lo que no

**Primera parte.** Se bloqueó desde el protocolo de depuración el tráfico de la pestaña hacia el emulador, solo los puertos 8181 y 9199: con todo el navegador sin red no se podría recargar, porque la Web todavía no funciona sin conexión (T-92).
- Se registraron 3 movimientos y se recargó la pestaña: **los 3 pendientes siguieron** en IndexedDB.
- Con la red de vuelta y la sesión, llegaron **una vez**: 3 documentos, 3 ids.

**Lo que no se pudo: dos pestañas con sesión.** En la Web, **Auth contra el emulador no funciona si ya hay un usuario guardado**.
- El SDK valida al usuario guardado antes de quedar conectado al emulador. La conexión falla en silencio, y las peticiones van al servicio real con la clave falsa: «api-key-not-valid».
- Por eso, en el modo emulador, **recargar la página pierde la sesión** aunque no haya bloqueo, y una segunda pestaña no puede iniciar sesión («unknown» o «api-key-not-valid»).
- Es del banco contra el emulador, no del producto: en producción no hay emulador al que conectar.
- **Queda para producción**, en Chrome contra `baystream-app` en local: las dos pestañas, y que la sesión sobreviva a recargar.

### 6.5 C8 en detalle

**Corrida 1 (lanzamiento):**
- Windows inició sesión, preparó A08 con su listado y **publicó desde «Nube y cuenta»**.
- En «Avance de la operación» vio subir el avance del Honor **en tiempo real**: 11 y 17, luego 26 y 29, 58 y 56, hasta 120 y 56.
- Al terminar, **cerró la operación** desde la misma pantalla.
- **La sesión de oficina persistió** al reiniciar la app de Windows.

**Corrida 2 (depuración, con la salida capturada):**
- Hizo lo mismo y vio el avance congelarse durante el corte y completarse al volver.
- **Su salida no trae ningún error de hilo ni de canal:** `stderr` en 0 bytes, y en `stdout` solo la línea del servicio de la VM.

**El almacén:**
- la corrida 1 se abrió por `explorer.exe` y usó el **almacén real**, `%LOCALAPPDATA%\BayStream\vessel_store`, namespace `t79run1`;
- la corrida 2 se lanzó directo para capturar su salida y cayó en el del paquete, `%LOCALAPPDATA%\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Local\BayStream`, namespace `t79run2`.

**Observación abierta.** Relanzada después de vaciar el emulador, la oficina de Windows (depuración) se quedó **«Sin conexión» más de dos minutos, sin ningún error** en su salida. El emulador estaba vivo, el Honor y Chrome lo usaban, y la lista de operaciones abiertas mostraba la de su caché.
- No lo investigué a fondo. Puede ser la caché local del SDK de C++ frente a un emulador vaciado, algo que en producción no pasa.
- **Hay que mirarlo en C9**, porque Firebase no da Windows por plataforma de producción (10.2).

### 6.6 C7 y la corrección que salió de ella

**Primera corrida** (Windows cerró desde la pantalla):
- A, registrado sin red antes del cierre, entró: 182 documentos.
- B quedó rechazado, pero con «La nube rechazó este movimiento: …» y sin «operación cerrada».
- **La causa:** al reconectar, el motor preguntó `closedAt` y el SDK le contestó desde su caché, donde la operación seguía abierta.

**Corrección:** `closedAt` y `authorizationOf` se leen del servidor; sin red, el movimiento sigue pendiente. Al rechazar por cierre, el muelle guarda la operación como cerrada.

**Recomprobación** con el motor corregido:
- La oficina en Chrome publicó. El Honor se unió, registró 3 cargas y quedó sin red.
- Se registró A, la oficina cerró y se registró B. Para esta recomprobación, el cierre se hizo con la cuenta de oficina por la API del emulador, con las reglas aplicadas: Windows estaba en el caso de 6.5. El cierre desde la pantalla ya pasó en la primera corrida.
- Con la red de vuelta, **A entró** (4 documentos) y **B quedó rechazado con «La operación se cerró antes de este movimiento.»**. El estado dice «Al día · 1 rechazado · operación cerrada».

## 7. Producción (T-79a 7.4): C9 y C10

9-oct, de ≈ 12:20 a ≈ 13:15. Antes, Carlos hizo en la consola de `baystream-app`:
- Firestore en `northamerica-south1`, edición Standard y modo de producción;
- **dos cuentas, una de oficina y una de muelle**, cada una con su `authorized/{uid}`;
- las reglas de `docs/T79a-firestore.rules.propuesta`, publicadas desde la consola **sin cambios**.

**Carlos escribió las contraseñas** en la ventana de cada app (Windows, el Honor y Chrome). No vi ni anoté correos, UID ni contraseñas. Ninguna compilación lleva credenciales.

### 7.1 Cómo se probó

**El punto de entrada, `tool/t79_c9_main.dart` (nuevo, en el repositorio).**
- Inicializa Firebase **igual que `lib/main.dart`**: las mismas opciones, leídas de `--dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json`. Ese archivo no se abrió.
- **Solo cambia dos cosas**, por eso no es `lib/main.dart` tal cual:
  - **el namespace** del almacén local, `t79prod`. Con `lib/main.dart` la oficina habría anexado movimientos de prueba en el almacén de Carlos (`baystream`), y la bitácora no se borra (AGENTS, 10.11);
  - **un banco que se oculta**, para lo que la pantalla de T-79 todavía no ofrece: el intercambio, su aprobación y la aprobación forzada del muelle (T-80). Las cargas, la sesión, publicar y unirse se hicieron en la pantalla real.
- **Sin `baystream-app` como proyecto no arranca**: nunca el de H5.
- El banco **no lleva correos ni contraseñas**: las sesiones se abren en «Nube y cuenta».
- **La operación «PRUEBA T-79»** es A08 con el buque renombrado al leerlo: `BUQUE GOLF` pasa a `PRUEBA T-79`. Se publica como `PRUEBA T-79 · VIAJE007A · GTSTC`, con el listado de A08.

**Las compilaciones**, en la copia privada del banco (`%TEMP%\baystream_t79_acceptance\app`, corpus como assets, fuera del repo), todas en release:

| Cliente | Cómo | Almacén |
|---|---|---|
| **Windows (oficina)** | Abierta con `explorer.exe`, PID 19012, cerrada por PID | **El real**, `%LOCALAPPDATA%\BayStream\vessel_store`, namespace **`t79prod`** |
| **Honor (muelle)** | Variante **`.t79`**, instalada encima con `adb install -r` | Namespace `t79prod` de la variante |
| **Chrome (oficina, C4)** | Compilado en local y servido en `http://localhost:8803`. Chrome propio con perfil aparte (`%TEMP%\baystream_t79_acceptance\chrome-c9`), manejado por el protocolo de depuración. **Nada se publicó en la Web** | IndexedDB del origen local, namespace `t79prod` |

### 7.2 C9: resultados

| Paso | Resultado |
|---|---|
| **Las sesiones** | Oficina en Windows y muelle en el Honor: «Cuenta autorizada», cada una con su rol. La lista de operaciones abiertas se lee sin error |
| **Publicar** | Windows publicó «PRUEBA T-79» desde «Nube y cuenta»: «Operación publicada», «Al día» |
| **Unirse** | El Honor la vio, **se unió y abrió el plan sin el archivo**: 405 contenedores, 55 reservas, 176 movimientos por cargar, «Al día» |
| **Diez movimientos** | **3 cargas desde la pantalla real del Honor** (OR 1, 2 y 3, por «OR / últimos dígitos» → «Confirmar carga») y 6 con el banco. Las 9, confirmadas |
| **El mismo avance** | Windows, en «Avance de la operación»: 9 cargados, 111 llenos pendientes, último movimiento de la cuenta de muelle. «Comprobar» da lo mismo en los dos: 9 registros, 9 confirmados, 167 pendientes de carga |
| **El intercambio** | El muelle pidió el de las órdenes 128 ↔ 145 y la oficina lo aprobó al recibirlo. **Los dos movimientos, confirmados** y vistos por los dos clientes. Su efecto en el plano lo deriva T-80 |
| **El muelle no aprueba** | **La pantalla no se lo ofrece**: en T-79 ningún rol tiene un control de aprobar (lo trae T-80). **Forzada con el banco**, por el mismo camino de la app: la nube la negó, «La nube rechazó este movimiento: PERMISSION_DENIED: Missing or insufficient permissions». El muelle dice «Al día · 1 rechazado». **A la oficina no le llegó**: Windows siguió con un solo `changePosition`, el suyo |
| **Una cuenta fuera de la lista** | Carlos eligió comprobarlo **en el simulador de reglas**: un `get` de `operations/prueba`, autenticado con un UID inventado que no está en `authorized`, sale **denegado**. En la app no se probó con una tercera cuenta; la batería del emulador ya cubre los 9 casos de lectura (5.1) |

### 7.3 El corte de red de Windows (10.15)

**Cómo.** Carlos apagó la red de la PC desde la barra de tareas, la dejó así algo más de un minuto y la devolvió. Mientras tanto, un guion en segundo plano (en el scratchpad, fuera del repo):
- cada 2 s anotó la hora y si la PC llegaba a `firestore.googleapis.com:443`;
- capturó la franja de estado de la ventana de BayStream, con `PrintWindow`, aunque estuviera tapada;
- 10 s después de la caída, hizo que el Honor, con su propia red, registrara 3 cargas.

| Hora | Qué |
|---|---|
| 12:54:23 | Se cae la red de la PC |
| 12:54:33 | El Honor registra 3 cargas |
| 12:55:03 | Windows pasa a **«Sin conexión»** (40 s después de la caída) |
| 12:55:49 | Vuelve la red |
| **12:56:25** | Windows vuelve a **«Al día»**: **36 s después** de que volviera la red |

- **PASA:** menos de un minuto, como pide 10.15.
- **Las 3 cargas del Honor llegaron:** al terminar, Windows tenía 14 registros, 14 confirmados.
- **No hizo falta corregir nada.** El caso de 6.5 (más de dos minutos sin conexión) fue contra un emulador vaciado y no se repite contra producción.
- Los 40 s hasta «Sin conexión» son del SDK, que tarda en dar por perdida la conexión. No es parte del criterio.

### 7.4 Chrome: dos pestañas y recarga (C4)

| Paso | Resultado |
|---|---|
| Inicio de sesión de oficina en la pestaña A, unirse y abrir el plan | «Al día», 14 registros, igual que Windows y el Honor |
| **Recargar la pestaña A** | **La sesión sobrevive**: «Carlos Oficina · office» sin volver a escribir nada |
| **Pestaña B**, en el mismo origen | Entra **con la sesión ya abierta**, se une y ve los mismos 14 |
| A registra 3 | B los recibe: **17 registros, 17 ids distintos, 17 confirmados** |
| B registra 3 | A los recibe: **20, 20 y 20** en las dos |
| Recargar la pestaña B | Sesión intacta; al reabrir el plan, otra vez 20, 20 y 20 |

**Al final, los cuatro clientes cuadran:** Windows, las dos pestañas y el Honor tienen **20 registros con 20 ids distintos, todos confirmados**: 18 cargas, la solicitud y la aprobación. El Honor guarda, además, su aprobación forzada como rechazada (21 en su bitácora). Nada se perdió ni se duplicó.

**Lo que no se probó:** las dos pestañas registrando **en el mismo instante**. Las dos escogerían los mismos contenedores, porque el banco toma los siguientes del caso que cada una conoce; en el dominio serían repetidos, no conflictos (T-79a 4.6). Se registró por turnos.

### 7.5 C10: la pestaña Uso

Carlos leyó en Firestore → Uso, al terminar C9:

| Métrica | En la consola | Lo que explica la app |
|---|---:|---|
| **Escrituras** | **23** | **Exacto:** 1 operación + 2 fuentes (el plan y el listado, un trozo cada una) + 20 movimientos. La aprobación forzada no se escribió |
| **Lecturas** | **103** | Cuatro clientes con sus listeners, la lista de operaciones, `authorized` de cada sesión, las lecturas del servidor del motor y los `get()` de las reglas (hasta tres por escritura de movimiento, 5.3) |
| **Eliminaciones** | **48** | **Ninguna:** las reglas niegan todo borrado y el código no borra. Ver 7.7 |

**Frente a la estimación de T-79a 5.3** (el caso entero: 178 movimientos, dos dispositivos, ≈ 200 escrituras y menos de 2 000 lecturas al día):
- **Escrituras:** una por movimiento, como se diseñó. El caso entero daría 178 + 3.
- **Lecturas:** 103 para 20 movimientos con **cuatro** clientes y varias recargas. Es del orden de cinco por movimiento; llevado a 178, **orientativamente**, queda dentro de las 2 000.
- **La cuota sin costo** (20 000 escrituras y 50 000 lecturas al día) queda muy lejos.

### 7.6 El límite de 1000 expresiones en producción

- **Desde la app no se ve.** La aprobación forzada recibió solo «PERMISSION_DENIED: Missing or insufficient permissions». Producción no manda al cliente el motivo de una denegación, que el emulador sí da.
- **El simulador tampoco lo mostró** en el `get` de 7.2, que no pasa por `validPayload`. Probar una escritura de movimiento en el simulador pide armar el sobre completo a mano, y no se hizo.
- **Lo que sí se ve:** las escrituras válidas pasaron todas (20 de 20) y la inválida se negó.
- **Queda como decidió 10.15:** T-80 parte `validPayload` por tipo. Las reglas no se cambiaron.

### 7.7 Las 48 eliminaciones

- Carlos dice que **no borró nada** en la consola.
- **La app no puede borrar**: las reglas niegan `delete` en todo, y el código no lo intenta.
- No sé de dónde salen. **No lo invento:** queda por aclarar en la consola (la métrica de borrados del día, o si la cifra es de otra columna).

### 7.8 Dos textos para T-97

- **El rechazo termina con un punto doble:** «…insufficient permissions..». El detalle del SDK ya trae su punto y el motor agrega otro.
- **Al abrir un plano, la Web dice «Sin conexión» unos segundos**, hasta la primera respuesta del servidor. Sería más exacto «Conectando…».

### 7.9 Lo que queda en la nube y en los dispositivos

- **En `baystream-app`:** la operación «PRUEBA T-79», **abierta**, con sus 2 fuentes y 20 movimientos. No la cerré: cerrar no se deshace y C9 no lo pedía. Carlos puede borrarla desde la consola si quiere (T-79a 7.4).
- **Windows, almacén real:** namespace `t79prod` y su caja `t79prod_session`, con uid, nombre y rol de la cuenta de oficina; nunca correo ni contraseña.
- **Honor:** la variante `.t79` con `t79prod`. Quedó detenida y el teléfono en el inicio.
- **Chrome:** el perfil aparte del temporal. El origen `localhost:8803` es solo de esta prueba.

**Cuentas, sin correos ni UID:**
- **Emulador:** 3 sintéticas, 1 de oficina y 2 de muelle.
- **Producción:** 2, una de oficina y una de muelle, cada una en `authorized/{uid}`.

## 8. Pruebas, analyze y corpus

```
flutter test                     → 485/485 (dos corridas)
flutter analyze --no-pub         → No issues found!
node tool/t79_reglas.mjs 8181 demo-t79    → 54 de 54 (con el emulador corriendo)
flutter test tool/t68_corpus_test.dart … tool/t79_corpus_test.dart --dart-define=BAYSTREAM_CORPUS_DIRECTORY=…   → 50/50
```

**El corpus nuevo, `tool/t79_corpus_test.dart` (2), es C2 en memoria** con A08 y con A08v_VGM:
- dos dispositivos, cada uno con su Hive y su motor, y un servidor falso compartido;
- la oficina aprueba la solicitud y el muelle espera la aprobación;
- sin red del evento 60 al 100, con cierre forzado en el 80;
- **178 documentos, cada id una vez; 20 pendientes al reabrir; 460/460 en los dos; 2 «fuera de plan» hasta T-80.**

**El modo de un solo dispositivo sigue igual.** Los 48 corpus de T-68 a T-78 dan lo mismo que antes: sin cuenta, todo nace `localOnly`.

**Con C9 (9-oct):** solo se agregó `tool/t79_c9_main.dart`; `lib/`, `test/` y `pubspec.*` no cambiaron, así que la suite y los corpus no se repitieron. `flutter analyze --no-pub` sigue en **cero**, con el archivo nuevo.

## 9. Incidencias y lo que queda anotado

- **La copia del banco.** El clasificador de permisos no dejó copiar el árbol completo al temporal, porque llevaba `android/key.properties`. Copié solo lo necesario. El corpus va como assets del banco, en el temporal, como en T-76 a T-78.
- **Lecturas viejas del Honor.** Si `uiautomator dump` fallaba, mi ayudante bajaba el XML anterior: así salió un «Al día» falso en la corrida 2. Ahora borra el archivo antes de cada lectura. Las cifras de C2 son las de después de la corrección o las del emulador.
- **El Honor pidió autorizar la depuración USB** al reiniciar el servidor de adb. Lo aceptó Carlos.
- **A 360 dp, la barra del banco y de la app** pierde el título con el botón de nube nuevo. Es el caso de T-97 (título sin truncar a 360 px).
- **Lo que queda en los almacenes de prueba**, todo de solo anexar y de prueba:
  - **Windows, almacén real:** `t79acc` (aceptación de T-78, 291 registros) y `t79run1` (C1, C2, C5 a C7 con el emulador), con su caja `t79run1_session`: uid, nombre y rol de la cuenta sintética del emulador.
  - **Windows, almacén del paquete:** `t79run2`.
  - **Honor:** la variante `.t79`, con `t79acc`, `t79run1` y `t79run2`.
  - **Desde C9:** `t79prod` en el almacén real de Windows, en la variante `.t79` del Honor y en el Chrome aparte (7.9).
  - El perfil de BUQUE GOLF de Carlos no se tocó.
- **C9: la variante `.t79` se reinstaló encima** con la compilación de producción. El banco no tiene `android/key.properties`, así que va firmada con la clave de depuración, como antes, y conserva el `usesCleartextTraffic` de su manifiesto del emulador; contra producción no se usa.
- **C9: la captura de pantalla de Windows** tomaba primero la ventana de Claude, que estaba encima. El guion del corte pasó a capturar la ventana de BayStream con `PrintWindow`.

## 10. Horas

Hora de Guatemala, del reloj de la máquina. Excluye la pausa del 8-oct, ≈ 21:01, al 9-oct, ≈ 01:08, por el límite de uso.

| Trabajo | Ventana | Horas |
|---|---|---:|
| Lecturas de CLAUDE.md, AGENTS.md, SPRINT-3, T-79a y los informes | antes de 19:30 | no cronometrada |
| **Aceptación de T-78** (suite, corpus, banco y tres clientes) | 19:30 – 19:49 | **≈ 0.32 h** |
| **T-79** (código, suite, reglas, corpus, dispositivos contra el emulador e informe) | 19:49 – 21:01 y 01:08 – 01:25 | **≈ 1.5 h** |
| **C9 y C10** (punto de entrada, tres compilaciones, Windows, Honor, corte de red, Chrome e informe), 9-oct | ≈ 12:20 – 13:20 | **≈ 1.0 h** |

**T-79 suma ≈ 2.5 h frente a las 10.0 estimadas.** 10.15 contaba ≈ 0.5 h para C9 y C10; tomaron ≈ 1.0, por las tres compilaciones y el corte de red. Son horas de reloj con compilaciones y dispositivos, e incluyen las esperas de Carlos para las contraseñas y la red.

## 11. Archivos

**Nuevos:**
- `lib/features/vessel/data/repositories/firebase_session_repository.dart`
- `lib/features/vessel/data/repositories/firestore_operation_sync.dart`
- `lib/features/vessel/data/repositories/local_only_operation_sync.dart`
- `lib/features/vessel/data/repositories/operation_sync_factory.dart`
- `lib/features/vessel/data/repositories/sync_engine.dart`
- `lib/features/vessel/domain/repositories/operation_sync_repository.dart`
- `lib/features/vessel/domain/repositories/session_repository.dart`
- `lib/features/vessel/presentation/pages/cloud_page.dart`
- `lib/features/vessel/presentation/providers/sync_providers.dart`
- `lib/features/vessel/presentation/widgets/sync_status_chip.dart`
- `test/support/t79_fake_cloud.dart`
- `test/t79_cloud_codec_test.dart`
- `test/t79_cloud_page_test.dart`
- `test/t79_sync_engine_test.dart`
- `tool/t79_corpus_test.dart`
- `tool/t79_reglas.mjs`
- `tool/t79_replay_main.dart`
- `tool/t79_c9_main.dart` (C9, 9-oct)
- `docs/T79-RESULTADOS.md` (este informe)

**Modificados:**
- `lib/features/vessel/data/datasources/hive_movement_data_source.dart`
- `lib/features/vessel/data/repositories/movement_log_repository_impl.dart`
- `lib/features/vessel/domain/entities/movement.dart`
- `lib/features/vessel/domain/entities/operation.dart`
- `lib/features/vessel/domain/repositories/movement_log_repository.dart`
- `lib/features/vessel/domain/services/operation_sources.dart`
- `lib/features/vessel/presentation/formatters/vessel_error_message.dart`
- `lib/features/vessel/presentation/pages/operation_progress_page.dart`
- `lib/features/vessel/presentation/pages/vessel_overview_page.dart`
- `lib/features/vessel/presentation/providers/discharge_provider.dart`
- `lib/features/vessel/presentation/widgets/discharge_controls.dart`
- `lib/features/vessel/presentation/widgets/loading_controls.dart`
- `lib/features/vessel/presentation/widgets/loading_plan_controls.dart`
- `pubspec.yaml` y `pubspec.lock`
- `windows/flutter/generated_plugin_registrant.cc` y `windows/flutter/generated_plugins.cmake` (generados por `pub get`)

**No van en el bloque:** los `.docx` y el `.pdf` modificados de `docs/` y los no rastreados `android/build/`, `output/` y los dos de `docs/`. No son míos.

**Evidencia, fuera del repositorio,** en `%TEMP%\baystream_t79_acceptance\evidence\`:
- registros de suite, corpus, reglas y compilaciones;
- `c2-timeline*.txt` y `c8-windows-*.txt`;
- capturas en `windows/`, `honor/` y `chrome/`;
- **C9:** `c9-*-build.txt`, `windows/c9-*.jpg`, `windows/corte1/` (registro `corte.log` y 239 capturas del corte), `honor/c9-*.png` y `chrome/c9-*.png`.
