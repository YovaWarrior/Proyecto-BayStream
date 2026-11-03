# T-129 · El cierre que falla después de revisar el listado (O-128-2) · Resultados

Timonel (Claude Code, Claude Fable 5.1). Rama `sprint-4`, carpeta del rediseño
(`C:\Proyectos\baystream-rediseno`), punta `a52d203` («Sprint 4: decisiones 10.82 y 10.83…»).
La decisión 10.84, que encarga esta tarea, está escrita en `SPRINT-4.md` pero **todavía sin
confirmar en Git** (sección 2). Escrito el 30-oct-2026 de madrugada, antes de la Expo, sin
Flutter ni emulador: este informe trae el diagnóstico, la prueba roja y el arreglo **escritos**,
y deja las corridas para la ventana con luz verde (sección 6).

## 1. Resultado en tres líneas

- **La rama que falla es la de `closedAt`, no la de la operación local.** El primer «Cerrar
  operación» escribe `closedAt: serverTimestamp()` y vuelve a leer el documento «del servidor»;
  como la oficina ya **escucha** ese documento (el motor de T-127 lo sigue mientras muestra «Al
  día»), el SDK resuelve esa lectura con la última vista de la escucha, en la que la hora sigue
  **pendiente** y se lee como **nula**: `close()` contesta «No se encontró la operación…» sin
  guardar el cierre en el dispositivo, aunque la nube ya quedó cerrada. La segunda vez el eco del
  servidor ya llegó, `status` es `closed`, no se escribe nada y la hora se lee bien.
- **El defecto está en `close()` desde T-79, pero era inalcanzable antes de T-127:** `close()` es
  idéntico en la 0.4.0 (`be532ab`) y hoy; lo que cambió es que la oficina pasó a escuchar el
  documento de la operación (`watchList`). **Revisar el listado no es la condición:** basta que
  la oficina siga la operación publicada con el motor conectado. Medido solo en la Web (Codex, en
  Chrome, contra el emulador); por la arquitectura común de los SDK aplica igual en Windows y
  Android, sin medir.
- **Lo entregado:** cinco pruebas nuevas contra una nube falsa al nivel del SDK
  (`test/support/t129_fake_firestore.dart`), dos de ellas **rojas contra el código de hoy** por
  comportamiento; y el arreglo mínimo en `data/`: después de la escritura propia, `close()` espera
  la primera instantánea del servidor sin escrituras pendientes (18 líneas, una sola función
  nueva). No cambian las reglas, el contrato, los mensajes ni nada publicado. **El 2-nov, con
  luz verde (6.1 a 6.3):** la primera falsa no pasaba `analyze` (implementaba clases `@sealed`
  del SDK). Con la autorización de Carlos la rehice en la capa de plataforma, con una dependencia
  de desarrollo (`cloud_firestore_platform_interface` 8.0.6, la que ya traía el `.lock`). Con
  ella, el rojo da +3 −2 por comportamiento, el verde 5 de 5, la suite **1876 de 1876** en una
  sola corrida y sin omitidas, y `analyze` «No issues found!». El emulador no se corrió.

## 2. Base, luz verde y lo que se corrió

- **Paso 0.** `git log --oneline -3` da `a52d203`, `7a74c42` y `c893687`: **no** trae arriba la
  10.84. `git diff --stat` muestra que `SPRINT-4.md` (26 líneas, la 10.84 completa) y
  `docs/piloto/LISTA-PILOTO.md` están modificados sin confirmar. Como el contenido que el encargo
  manda leer existe en el árbol, seguí con la lectura y el diagnóstico, que no dependen del commit,
  y lo anoto aquí para Carlos y Yov. Los demás cambios ajenos (`test/t114_fase3_correccion_test.dart`
  y tres archivos de `windows/flutter/`, solo fin de línea; `docs/t117/entrega1/` sin seguimiento)
  no los toqué y no van en el bloque. **Nunca `git status`.**
- **Leí**, en el orden del encargo: `CLAUDE.md` con `AGENTS.md`; de `SPRINT-4.md`, 10.79, 10.83 y
  10.84; `docs/t128/aceptacion-codex.md` (P2, el paso 13, O-128-2 y los límites); la evidencia de
  Codex en `C:\Proyectos\baystream-qa-r4\build\t128-aceptacion\` (`LEEME.md`,
  `e2e/oficina-f/13-*.json`, `web-comandos-e2e-final.json`, `e2e/oficina-f/snapshots.json`,
  `e2e/resumen-validado.json`, el banco `banco-emu/` con `bancos/t128_emu_actual_main.dart`, y sus
  conductores `control_web.py` y `e2e_support.py`), sin cambiar nada; `docs/T127-RESULTADOS.md`
  3.4 a 3.6; y el código: `close()` y el resto de `firestore_operation_sync.dart`,
  `cloud_page.dart` (quien la llama), `sync_providers.dart`, `sync_engine.dart`,
  `movement_log_repository_impl.dart`, `hive_movement_data_source.dart`,
  `docs/T127-firestore.rules.propuesta` (la cláusula del cierre) y los fakes de `test/support/`.
- **El SDK.** Las fuentes del SDK de Firestore para la Web en la etiqueta `firebase@12.17.0` (la
  misma versión del paquete que la app sirve en `web/vendor/firebase/12.17.0/`), leídas desde
  GitHub por un agente de lectura: `core/view.ts`, `core/event_manager.ts`,
  `core/firestore_client.ts`, `core/sync_engine_impl.ts` y `core/view_snapshot.ts`. Las tres
  expresiones clave están también en el paquete minificado que sirve la Web
  (`build/t129/sdk-12.17.0-cotejo.json`). Del lado Dart: `cloud_firestore` 6.8.0,
  `cloud_firestore_web` 5.7.2 y `cloud_firestore_platform_interface` 8.0.6, en la caché de pub.
- **Lo que se corrió:** solo Python (`tool/t129_evidencia.py`, que extrae de la evidencia de Codex
  lo que este informe cita, sin identificadores de cuentas) y lecturas de Git (`git log`,
  `git diff --stat`, y `git show <commit>:<ruta>` de un archivo a una carpeta temporal, para
  comparar la 0.4.0 con hoy). **Ni Flutter, ni Dart, ni el emulador, ni ningún navegador:** 10.84
  lo deja para después de la Expo. Por eso no hubo líneas `SEMÁFORO:`.

## 3. El diagnóstico

### 3.1 Lo que dice el código (lo que leo)

`close()` (`firestore_operation_sync.dart`, 250–285 en `a52d203`) hace, en orden:

1. `_office()`: exige sesión de oficina autorizada.
2. `_serverGet(ref)`: lee el documento con `GetOptions(source: Source.server)`.
3. Si `status == 'open'`, `ref.update({status: 'closed', closedBy: uid, closedAt:
   FieldValue.serverTimestamp()})` y **vuelve a leer** con `_serverGet(ref)`.
4. `closedAt = (data['closedAt'] as Timestamp?)?.toDate()` y `local = _log.getOperation(id)`.
5. Si `local == null || closedAt == null`, devuelve `not_found` con el mensaje «No se encontró la
   operación para cerrarla en este dispositivo o en la nube…». Si no, guarda en local
   `local.copyWith(closedAt: closedAt)`.

Dos hechos del código alrededor:

- **La escritura no puede cambiar.** Las reglas (`docs/T127-firestore.rules.propuesta`, 132–136,
  igual que T-80) exigen `d.closedAt == request.time`: el cliente **tiene** que escribir
  `serverTimestamp()` y, por tanto, leer la hora de vuelta.
- **La oficina escucha el documento desde T-127.** `CloudPage._activeOperation` observa
  `syncStatusProvider`, que llama a `follow(operation)`; el motor (`SyncEngine.start` →
  `setOperator` → `_listen(true)`) abre `remote.watch` sobre `movements/` **y**
  `remote.watchList` sobre el documento de la operación:
  `doc.snapshots(includeMetadataChanges: true)` filtrado por `!hasPendingWrites`
  (`FirestoreRemoteMovementStore.watchList`, 488–500). Esa escucha existe mientras la oficina ve
  el estado de envío, con o sin listado, con o sin revisión. En la 0.4.0 (`git show be532ab:` del
  mismo archivo) las únicas escuchas son `watchOpenOperations` (la consulta `status == open`) y la
  de `movements/`: **ninguna sobre el documento.** Y el cuerpo de `close()` de `be532ab` es
  **idéntico** al de hoy, como dijo Codex.
- **Quien la llama** (`cloud_page.dart`, 280–305): `_close` confirma en un diálogo y hace
  `sync.close(operation.id)`; si devuelve `Left`, muestra el mensaje y **no** vuelve a intentar ni
  toca el almacén local. Nada más en la app guarda `closedAt` en la oficina.

### 3.2 Lo que dice la evidencia de Codex (lo que mido en su registro)

Todo sale del registro del conductor (`web-comandos-e2e-final.json`) y de la sonda local de su
banco (`e2e/oficina-f/snapshots.json`), extraídos a `build/t129/` con `tool/t129_evidencia.py`:

- **Antes del cierre, el motor estaba conectado:** en las lecturas 96, 99 y 104 el chip de la
  oficina dice «Nube y cuenta · Al día» (`codex-chip-antes-del-cierre.json`). «Al día» es
  `SyncState.upToDate`, que el motor solo emite con el listener recibiendo **del servidor**: la
  escucha sobre el documento estaba abierta y al día.
- **El primer cierre** (`codex-paso13-comandos.json`): 138 «Nube y cuenta»; 139 «Cerrar
  operación»; 140 el diálogo; 141 confirmar (0,38 s); 142 el conductor esperó 30 s a que
  apareciera «cerrada» y **no apareció**; 143 la lectura administrativa del emulador: el documento
  ya tenía `status: closed`, `closedAt: 2026-10-30T04:13:10.231Z` y `updateTime
  …04:13:10.242908Z`, con el listado en revisión 2; 146 la pantalla decía «No se encontró la
  operación para cerrarla en este dispositivo o en la nube. Vuelve a abrir «Nube y cuenta» e
  inténtalo de nuevo.». Es decir: la nube se cerró a las 04:13:10 UTC y la oficina mostró el
  `not_found` durante más de 30 segundos.
- **La bitácora local no cambió con ese cierre** (`codex-sonda-local.json`): la sonda, que lee
  `getOperations()` cada segundo e imprime solo cuando algo cambia, tiene la operación
  `published: true, closed: false` con el listado r2 (29 filas) y 4 movimientos en las
  instantáneas 7 y 8, y pasa a `closed: true` **solo en la 9**, la del segundo cierre (173–177:
  «Operación cerrada.», «Publicada y cerrada», «Al día · operación cerrada»).
- **Lo que esto descarta.** La rama `local == null` necesita que `_log.getOperation(id)` devuelva
  nulo o falle. `getOperation` es `_operations.get(id)` sobre una caja de Hive **en memoria**, y lo
  decodifica con el mismo `_decodeOperation` que `operations()`; la sonda de Codex decodificó ese
  mismo registro **cada segundo**, antes, durante y después del cierre, sin `T128_PROBE_ERROR`.
  La operación estaba, se leía y era la misma (`published: true`). Queda la otra rama:
  **`closedAt == null`** en la lectura que sigue a la escritura.
- **Límite de la medición.** El conductor de Codex no capturó `metadata.hasPendingWrites` de esa
  lectura (no estaba instrumentada) ni la consola más allá de `T128_SNAPSHOT`. La rama se
  determina por eliminación con la evidencia de arriba y por el mecanismo de 3.3; cómo medirla
  directamente está en 4.3.

### 3.3 Por qué `closedAt` llega nulo: lo que hace el SDK (lo que leo en su fuente, 12.17.0)

Cuatro hechos del SDK, cada uno en su archivo, y la cadena que forman:

1. **La lectura «del servidor» es una escucha de una sola vez sobre la misma consulta.**
   `firestore_client.ts`, `readDocumentViaSnapshotListener`: crea un `QueryListener` sobre
   `newQueryForPath(key.path)` con `{ includeMetadataChanges: true, waitForSyncWhenOnline: true }`
   y, en la primera instantánea, rechaza si `snap.fromCache` (sin red, o «Failed to get document
   from server…») y **resuelve en cualquier otro caso**. No mira `hasPendingWrites`. La propia
   documentación de `GetOptions` (`cloud_firestore_platform_interface`, `get_options.dart`) lo
   advierte para `Source.server`: «latency-compensation still takes effect, so any pending write
   operations will be visible in the returned data».
2. **Si la consulta ya tiene una escucha, la nueva recibe su última vista al instante.**
   `event_manager.ts`, `eventManagerListen`: con `queryInfo` existente no se crea vista ni se
   espera al servidor; se hace `queryInfo.listeners.push(listener)` y
   `listener.onViewSnapshot(queryInfo.viewSnap)`. `shouldRaiseInitialEvent` empieza con «Always
   raise the first event when we're synced: `if (!snap.fromCache) return true`». La vista de la
   escucha de T-127 está al día (`fromCache` falso): la lectura se resuelve con **esa** vista.
   `queryInfo.viewSnap` solo cambia cuando la vista emite (`eventManagerOnWatchChange`).
3. **Esa vista todavía lleva la hora pendiente, y el acuse no la cambia.** `sync_engine_impl.ts`:
   la escritura local (`syncEngineWrite`) emite una instantánea con `hasPendingWrites` y
   `closedAt` como centinela de hora pendiente; cuando llega el acuse
   (`syncEngineApplySuccessfulWrite`) el SDK **resuelve primero la promesa del `update()`**
   («we raise user callbacks first so that they consistently happen before listen events») y
   después intenta emitir; pero `view.ts`, `computeDocChanges`, **calla** ese cambio con
   `shouldWaitForSyncedDocument` («We suppress the initial change event for documents that were
   modified as part of a write acknowledgment (e.g. when the value of a server transform is
   applied) as Watch will send us the same document again»): no se registra el cambio, la vista
   **conserva el documento viejo** y la clave sigue en `mutatedKeys`, así que `viewSnap` sigue
   siendo la instantánea pendiente hasta que la escucha de Watch trae el eco del servidor.
4. **La hora pendiente se lee como nula.** `cloud_firestore_web` pide `data()` con
   `ServerTimestampBehavior.none` (`document_reference_web.dart`, 83, el valor por omisión de
   `GetOptions`), y con `none` el SDK devuelve `null` para un `serverTimestamp()` que el servidor
   aún no confirmó en la vista. En `close()`, `(data['closedAt'] as Timestamp?)` es nulo sin error.

**La cadena, en el orden del primer cierre:** `_serverGet` lee `status: open` de la vista de la
escucha → `update()` escribe; la vista pasa a `closed` con `closedAt` pendiente → el acuse llega
(la nube ya está cerrada) y resuelve `update()`, sin emitir → `_serverGet` se resuelve con la vista
pendiente → `closedAt` nulo → `not_found`, sin guardar nada local. Milisegundos después llega el
eco de Watch y la vista queda al día, pero `close()` ya devolvió el `Left`. **El segundo cierre:**
`_serverGet` lee la vista al día, `status: closed` y la hora real → no escribe → guarda → «Operación
cerrada.». Volver a abrir «Nube y cuenta» no es lo que lo arregla; es el tiempo.

### 3.4 ¿Es de T-127 o de antes? ¿Pasa igual sin revisar el listado?

- **De antes, pero destapado por T-127.** El defecto es de `close()` desde T-79: leer de vuelta
  una hora del servidor «del servidor» inmediatamente después de escribirla, sobre un documento
  que puede tener una escucha abierta. Antes de T-127 la oficina no escuchaba el documento, así
  que la lectura abría una vista nueva y, con `waitForSyncWhenOnline`, **esperaba** la
  instantánea del servidor: la hora venía resuelta. T-127 puso la escucha (`watchList`) en el
  motor, y el motor lo corre también la oficina.
- **Sin revisar el listado pasa igual (por el código).** `watchList` se suscribe en `_listen(true)`
  siempre, con o sin listado y con o sin revisión. La condición es: oficina 0.4.1, operación
  publicada, y el motor conectado («Al día», o cualquier estado con la escucha recibiendo del
  servidor). Es el estado normal de la oficina: la misma pantalla «Nube y cuenta» que tiene el
  botón mantiene el motor vivo. **Medido:** no. El único cierre de una oficina 0.4.1 en la
  evidencia de Codex es el de la operación revisada; la operación auxiliar sin revisión la cerró la
  oficina 0.4.0 (bien, como se espera: sin escucha). La prueba «pasa igual sin listado ni revisión»
  de 4.2 lo muestra en la nube falsa; 4.3 dice cómo medirlo en el emulador.
- **Depende del orden de dos mensajes del servidor.** Si el eco de Watch llegara **antes** que el
  acuse de la escritura, la vista ya tendría la hora real al resolverse `update()` y el primer
  cierre saldría bien. Normalmente el acuse llega primero (es la respuesta directa a la
  escritura), y así se vio en la aceptación. Por eso el fallo es «la primera vez» y no «siempre»;
  y por eso no se puede prometer que una repetición a mano lo reproduzca el 100 % de las veces.
- **Plataformas.** Medido en Chrome. Los SDK de Android y el de C++ que usa Windows comparten el
  mismo diseño (`View`, `EventManager`, la lectura «del servidor» como escucha de una vez) y el
  mismo contrato de `hasPendingWrites`; no lo medí.
- **Lo demás no está afectado.** `publish` y `replaceSource` no leen de vuelta después de escribir;
  `join` lee antes de escribir; `RemoteMovementStore.closedAt` (el muelle) lee «del servidor» pero
  no después de una escritura propia del mismo documento, así que la vista que recibe es la del
  servidor.

### 3.5 El cierre de la 26043X en Windows (10.87, 2-nov): cuadra, y no lo pone a prueba

**El dato.** El 2-nov Carlos cerró la 26043X en la laptop, con la cuenta de oficina, y salió
«Operación cerrada.» a la primera, con el chip «Al día» y sin haber revisado el listado después
de publicar.

**Con qué versión.** El piloto corrió con la **0.4.0** (10.85), y la 0.4.1 todavía no se publica:
la 10.84 la deja para después de la Expo y la 10.88 la mete en la candidata de antes del 7-nov.
En la lista del piloto, el paso 0.1 (instalar el MSIX 0.4.1.0) no consta como hecho. Así que la
laptop tenía, con toda probabilidad, la 0.4.0, aunque **no lo verifiqué**: Carlos lo confirma en
Configuración → Aplicaciones → BayStream.

**Con la 0.4.0, cuadra exactamente con el diagnóstico, y no por el listado.** La 0.4.0 no tiene
escucha sobre el documento de la operación (3.1: `be532ab` solo escucha la consulta
`status == open` y `movements/`). «Al día» lo da la escucha de `movements/`, que es otra consulta.
La lectura «del servidor» que sigue al `update` no encuentra una vista abierta del documento:
abre la suya y, con `waitForSyncWhenOnline`, espera la instantánea del servidor, que trae la hora
real. Es la prueba 3 («sin ninguna escucha abierta…»), en verde con y sin el arreglo. **Lo que
evitó el fallo no fue no revisar el listado, sino que la 0.4.0 no escucha el documento.** Por eso
este cierre no sirve como contraprueba de T-129: no se dio la condición.

**Si hubiera sido la 0.4.1,** también cuadraría, pero por la otra salida que deja 3.4: que el eco
del servidor llegue antes que el acuse de la escritura. Contra Firestore de producción, el acuse
llega por el canal de escrituras y el eco por el de escuchas, y el orden entre los dos no está
garantizado. Con el emulador (el caso de Codex) el acuse llegó primero. Un cierre bueno en
producción no muestra que el defecto no esté: muestra que esa vez el orden fue el otro. El SDK de
C++ que usa Windows tiene el mismo diseño que el de la Web (la lectura «del servidor» como escucha
de una vez, la vista compartida de `EventManager` y `ShouldWaitForSyncedDocument` en `View`). Lo
digo por el diseño común y **no lo medí**.

**El arreglo sigue haciendo falta igual.** En la 0.4.1 la oficina escucha el documento siempre que
sigue la operación publicada, con o sin listado. Que el primer cierre salga bien depende del orden
de dos mensajes del servidor. Con el arreglo, `close()` espera la instantánea sin escrituras
pendientes y la hora es la del servidor en los dos órdenes.

## 4. La prueba roja

### 4.1 Por qué no basta la nube falsa de T-79

`test/support/t79_fake_cloud.dart` falsifica **el puerto del motor** (`RemoteMovementStore`:
`put`, `watch`, `watchList`, `listParts`, `closedAt`). `close()` no pasa por ese puerto: habla con
`FirebaseFirestore` directamente (`collection().doc().get/update`). Hoy ninguna prueba construye
un `FirestoreOperationSync` (solo se usan sus estáticos `sourceHash` y `splitSource`). Hacía falta
una nube falsa **al nivel del SDK**, que es lo que falla.

### 4.2 `test/support/t129_fake_firestore.dart` y `test/t129_cierre_test.dart`

- **La falsa** (`T129FakeFirestore`; rehecha el 2-nov en la capa de plataforma, 6.2) extiende
  lo justo de `FirebaseFirestorePlatform`, `CollectionReferencePlatform`,
  `DocumentReferencePlatform` y `DocumentSnapshotPlatform` para `close()`, debajo de las clases
  reales de `cloud_firestore`: la app recibe `db.instance`, un `FirebaseFirestore` de verdad
  (`FirebaseFirestore.instanceFor` con una `FirebaseApp` falsa de nombre único), y
  `DocumentReference`, `DocumentSnapshot`, `SnapshotMetadata` y `FieldValue.serverTimestamp()`
  son los del SDK. Reproduce los cuatro hechos de 3.3: una lectura «del servidor» sobre un documento
  con escucha abierta devuelve la última instantánea de esa escucha; un `update` con
  `FieldValue.serverTimestamp()` entra primero en la vista local (`hasPendingWrites`, hora
  pendiente, que la plataforma entrega como nula, como `cloud_firestore_web` con
  `ServerTimestampBehavior.none`), el servidor la aplica con la hora de su reloj y el
  `update` termina **sin cambiar la vista**; el eco del servidor llega en una vuelta posterior del
  bucle de eventos y entonces la vista trae la hora real. Sin escucha, la lectura va al servidor.
  Simplificaciones declaradas en su comentario: toda instantánea de escucha es «al día»; una
  escucha nueva después del acuse espera el eco igual que una vieja (el caso más exigente para el
  arreglo); todo `FieldValue` es `serverTimestamp`, el único que la app escribe. Lo que no se usa
  lanza `UnimplementedError`, como la plataforma base. Expone `instance` (el `FirebaseFirestore`
  que recibe la app), `server` (los documentos), `readsFromListenedView` (cuántas lecturas «del
  servidor» se resolvieron con la vista de una escucha) y `document(ruta)`.
- **Las cinco pruebas**, con la bitácora en memoria de T-75 (más `getOperation`, que T-75 no
  necesitaba) y una sesión fija de oficina autorizada:
  1. **El primer «Cerrar operación» cierra la nube y también la copia local** — la prueba abre la
     misma escucha que `watchList` (`snapshots(includeMetadataChanges: true)`), llama a `close()`
     y comprueba que la nube quedó cerrada con la hora del servidor, que la lectura que siguió a la
     escritura fue la de la vista escuchada (`readsFromListenedView ≥ 1`), y que `close()`
     devolvió la operación cerrada, guardada en local con esa misma hora y con su listado r2.
     **Roja hoy:** falla en «close() contestó: not_found: No se encontró la operación para
     cerrarla en este dispositivo o en la nube…», con la nube ya cerrada: exactamente O-128-2.
  2. **Pasa igual sin listado ni revisión** — lo mismo con una operación que solo tiene el plan de
     carga. **Roja hoy**, por la misma razón: responde a la pregunta 2 del encargo.
  3. **Sin ninguna escucha abierta, el cierre llega al dispositivo a la primera** — verde hoy y con
     el arreglo: es la 0.4.0 y es lo que protege que el arreglo no rompa el caso simple
     (`readsFromListenedView == 0`).
  4. **El segundo intento, con la nube ya cerrada, cierra el dispositivo** — verde hoy y después:
     lo que Codex vio al repetir.
  5. **Sin la operación en el dispositivo sigue diciendo que no la encontró** — verde hoy y
     después: la otra rama del mensaje no cambia, y la nube queda cerrada igual.
- **Fallan por la razón correcta.** Las dos rojas no fallan por compilación (O-127-1) sino por
  comportamiento: el mensaje de la aserción trae el código y el texto que devolvió `close()`.
- **La primera versión (30-oct)** implementaba `FirebaseFirestore`, `CollectionReference`,
  `DocumentReference`, `DocumentSnapshot` y `SnapshotMetadata` con `noSuchMethod`, como
  `_NoCloud` de T-86. Compiló y dio el mismo rojo y el mismo verde, pero `analyze` la rechazó:
  tres de esas clases son `@sealed` (6.1). Escribí aquí que lo que marcara `analyze` sería de
  tipos o de lints y no del diseño: me equivoqué, era del diseño. La versión del 2-nov baja a la
  capa de plataforma (6.2) y deja las cinco pruebas como estaban; solo cambia que la app recibe
  `db.instance`.

### 4.3 Cómo reproducirlo contra el emulador, con el banco de Codex (solo con luz verde)

La nube falsa codifica **mi lectura** del SDK; la medición que la confirma es ésta, con los
instrumentos que Codex dejó en `C:\Proyectos\baystream-qa-r4\build\t128-aceptacion\`, sin
tocarlos (copias aparte):

1. **Emulador propio**, con `iniciar_emulador_e2e.py --nombre t129` o su equivalente: proyecto
   `demo-t128-acc` (o un `demo-t129`), `firebase.json` de Codex con Auth 9399, Firestore 8383, hub
   4498, logging 4598 y las reglas `reglas-t127.rules`. Ninguno de 8181, 4000 ni 4400.
2. **Banco Web** sobre una copia del banco `banco-emu/` (que es `c893687` sin instrumentar más que
   el punto de entrada `tool/t128_emu_main.dart`, con la sonda `T128_SNAPSHOT`): el comando que
   Codex registró en `web-emu-resultado.json`, `flutter build web --release --no-pub
   --no-web-resources-cdn -t tool/t128_emu_main.dart --output=build/web-emu`, servido con
   `servir.py --puerto 5937`.
3. **El recorrido mínimo**, con `control_web.py --luz-verde --nombre t129`: cuentas (`accounts`),
   un contexto de oficina, abrir `T100_CARGA.edi` (sin listado: así se mide la pregunta 2),
   iniciar sesión, publicar, esperar el chip «Al día», «Nube y cuenta», «Cerrar operación»,
   confirmar. **Esperado hoy:** el mensaje «No se encontró la operación…», `remote` con `status:
   closed` y la sonda con `closed: false`; al repetir, «Operación cerrada.».
4. **La medición directa de la rama:** en la copia del banco (nunca en `lib/`), un `debugPrint`
   justo después de la segunda lectura de `close()`:
   `T129_LECTURA hasPendingWrites=… isFromCache=… closedAt=…`, y que el conductor lo capture como
   captura `T128_SNAPSHOT`. **Esperado:** `hasPendingWrites=true isFromCache=false
   closedAt=null` en el primer cierre.
5. **El arreglo:** la misma copia con el `firestore_operation_sync.dart` de este informe, el mismo
   recorrido: «Operación cerrada.» a la primera y la sonda con `closed: true`.

Cada ventana con Flutter o el emulador se anuncia con una línea `SEMÁFORO:` al empezar y al
terminar, de a un comando.

## 5. El arreglo (chico, en `data/`)

- **Qué cambia** (`firestore_operation_sync.dart`, +18/−1): una función privada nueva,
  `_afterOwnWrite(ref)`, que devuelve la primera instantánea de
  `ref.snapshots(includeMetadataChanges: true)` con `!hasPendingWrites && !isFromCache`, con el
  mismo `_networkTimeout` de las demás lecturas; y en `close()`, después del `update`, se lee con
  ella en vez de con `_serverGet`. Es lo que el SDK documenta para leer de vuelta una hora del
  servidor: con `includeMetadataChanges` «you will receive another snapshot with
  `hasPendingWrites` equal to `false` once the writes have been committed to the backend»
  (`SnapshotMetadata`, `cloud_firestore`).
- **Cómo se comporta en los tres casos.** Con la escucha de T-127 abierta: recibe primero la vista
  pendiente, la deja pasar y toma el eco de Watch, con la hora real. Sin escucha (la 0.4.0 o una
  oficina que no sigue la operación): la escucha nueva recibe el documento ya confirmado y espera
  a que el servidor la marque al día; una vuelta más, la misma hora. Si el eco llegara antes que
  el acuse: la primera instantánea ya está limpia. En los tres, `closedAt` es la hora que puso el
  servidor, la misma que las reglas exigieron.
- **Qué no cambia.** La escritura (las reglas exigen `closedAt == request.time`), el contrato
  `OperationSyncRepository`, los mensajes, `publish`, `join`, `replaceSource`, el motor, la
  presentación, `pubspec.*`, `lib/main.dart`, las opciones de Firebase y las reglas publicadas.
- **Si el eco no llega** (la red cae justo después del acuse): a los 45 s `close()` devuelve el
  `timeout` de siempre («Sin respuesta de la nube: cerrar requiere red…»), la nube ya está
  cerrada y el siguiente intento la cierra en local, como hoy. Es el mismo límite que tienen
  publicar y unirse. **Corregido el 2-nov (6.4):** en `2d98f23` los 45 s se reiniciaban con cada
  instantánea descartada; ahora cuentan desde que empieza la espera.
- **Lo que descarté.** Leer con `ServerTimestampBehavior.estimate`: una línea, pero guardaría en
  local una hora **estimada con el reloj del cliente**, distinta de la del servidor. Escribir una
  hora del cliente: lo prohíben las reglas. Reintentar la lectura «del servidor» en bucle: volvería
  a recibir la misma vista hasta el eco; es lo mismo que esperar, pero a ciegas.

## 6. Validaciones: hechas y pendientes

**Hechas (sin Flutter):** el extractor de evidencia corrió y dejó los cuatro archivos de
`build/t129/`; la lectura del SDK en su etiqueta y el cotejo con el paquete minificado; la
comparación de `close()` y de las escuchas entre `be532ab` y hoy; la relectura del código escrito
contra las firmas del SDK instalado.

**Pendientes, con la luz verde de Carlos (después de la Expo), de a un comando y con `SEMÁFORO:`:**

1. `flutter analyze` → «No issues found!» (`build/t129/analyze.log`).
2. **Rojo contra el código de hoy:** apartar mi versión (`copy lib\...\firestore_operation_sync.dart
   build\t129\arreglo.dart`), poner la de `a52d203` (`git show a52d203:lib/features/vessel/data/repositories/firestore_operation_sync.dart > lib\...\firestore_operation_sync.dart`,
   una lectura de Git que escribe un archivo, no el índice), `flutter test
   test/t129_cierre_test.dart` → **las pruebas 1 y 2 fallan** con «close() contestó: not_found: No
   se encontró la operación…» y las otras tres pasan (`t129-rojo.log`); restaurar mi versión.
3. **Verde:** `flutter test test/t129_cierre_test.dart` → 5 de 5 (`t129-verde.log`).
4. **La suite completa en una sola corrida:** `flutter test` → 1876 de 1876, el piso 1871 más
   cinco, sin omitidas (`suite.log`).
5. `flutter analyze` otra vez → cero.
6. Si Yov lo pide, la repetición contra el emulador de 4.3 (`build/t129/emulador/`).

Hasta que eso esté, **el bloque de Git de la sección 9 no se ejecuta.**

### 6.1 Las corridas del 2-nov (luz verde después de la Expo, 10.88)

Este chat es nuevo y corre en Claude Opus 5.5, no en Fable 5.1 como dice la 10.88: leí este
informe completo antes de empezar.

- **Paso 0.** `git log --oneline -8`: la punta es `687d68d` («Sprint 4: decisiones 10.84 a
  10.88…»), con `a52d203` debajo: **la 10.84 ya está en Git.** `git show --stat HEAD` toca solo
  `SPRINT-4.md` y `docs/piloto/LISTA-PILOTO.md`, y `git log a52d203..HEAD -- lib test pubspec.*`
  no devuelve nada. `git diff --stat` solo muestra mi `firestore_operation_sync.dart` (+18/−1);
  los otros cuatro archivos ajenos difieren solo en el fin de línea (`--ignore-cr-at-eol` no
  devuelve nada). Ningún archivo de `lib/`, `test/` ni `pubspec.*` es más nuevo que este
  informe. Las huellas SHA-256 de mis archivos, antes de correr:
  `firestore_operation_sync.dart` `0ae18382…`, `t129_fake_firestore.dart` `223850ee…`,
  `t129_cierre_test.dart` `2127b28a…`, `t129_evidencia.py` `bbbfcef3…`. El archivo de
  `a52d203` y el de `HEAD` son el mismo (`fff1385d…`): el rojo corre contra el `close()` de hoy.
- **Antes de cada corrida** miré los procesos: solo los servidores MCP de Dart (`mcp-server`,
  `language-server`) y Maestro, ningún `flutter`. Las horas son las del reloj de la máquina, que
  quedaron en cada registro (en el chat anuncié primero 21:24 y 21:25 sin mirarlo; las buenas son
  éstas).

| # | Corrida (registro en `build/t129/`) | Hora | Resultado |
|---|---|---|---|
| 1 | `flutter analyze` (`analyze.log`) | 21:16:47–21:17:12 | **4 avisos, no cero**, todos en `test/support/t129_fake_firestore.dart`: `subtype_of_sealed_class` en las líneas 64 (`Query`, por `CollectionReference`), 89 (`DocumentReference`) y 221 (`DocumentSnapshot`), y `must_be_immutable` en 91 (`_pendingView` y `_lastEmitted`). Ninguno en `lib/`. `pubspec.lock` no cambió |
| 2 | El rojo: `flutter test test/t129_cierre_test.dart` con el `close()` de `a52d203` (`t129-rojo.log`) | 21:19:30–21:19:40 | **+3 −2**, como se esperaba. La 1 falla en `Expected: not null / Actual: <null>` y la 2 en `Expected: true / Actual: <false>`, las dos con «close() contestó: not_found: No se encontró la operación para cerrarla en este dispositivo o en la nube. Vuelve a abrir «Nube y cuenta» e inténtalo de nuevo.»: por comportamiento, no por compilación. Pasan la 3, la 4 y la 5. Mi versión, apartada en `build/t129/arreglo.dart` (`0ae18382…`), volvió a su sitio y su huella es **idéntica** |
| 3 | El verde: la misma prueba con el arreglo (`t129-verde.log`) | 21:19:45–21:19:50 | **5 de 5**, «All tests passed!» |
| 4 a 6 | La suite, el segundo `analyze` y el emulador | — | Esperaron la decisión de 6.2. Lo que se corrió después está en 6.3 |

Esta tabla es la de la **primera falsa**. Sus registros siguen en `build/t129/`, pero la falsa
cambió, así que valen las corridas de 6.3.

Los avisos de `analyze` no son de tipos ni de lints sueltos, como supuse en 4.2: son de diseño.
`cloud_firestore` 6.8.0 marca `@sealed` (de `package:meta`) `DocumentReference`, `DocumentSnapshot`,
`QueryDocumentSnapshot` y `Query`, y el analizador avisa a quien los implementa fuera del paquete,
también a través de `CollectionReference`. La falsa los implementa por diseño. La línea base no
admite `// ignore:` (`SPRINT-4.md`, 1: «`analyze` en cero, sin `// ignore:`»), así que no hay
retoque que lo arregle sin una decisión.

### 6.2 Lo que decidió Carlos: dónde vive la nube falsa

**Carlos eligió la 1 el 2-nov («Sí, autorizo»), con la dependencia de desarrollo.** Lo que siguió
está en 6.3.

1. **Recomendado, y elegido: rehacer la falsa en la capa de plataforma.** `DocumentReferencePlatform`,
   `DocumentSnapshotPlatform`, `CollectionReferencePlatform` y `FirebaseFirestorePlatform`
   (`cloud_firestore_platform_interface` 8.0.6) **no** están sellados: están hechos para que los
   extienda una implementación, que es lo que hace `cloud_firestore_web`. La prueba usaría las
   clases reales de `cloud_firestore` (`FirebaseFirestore.instanceFor`, `DocumentReference`,
   `DocumentSnapshot`, `FieldValue.serverTimestamp()`) sobre una plataforma falsa con el mismo
   comportamiento de 3.3, así que queda **más cerca** del SDK que la de hoy. `FirebaseApp` no está
   sellada: basta una falsa con su nombre, sin `firebase_core_platform_interface`. **Pide una
   dependencia de desarrollo:** `cloud_firestore_platform_interface: 8.0.6` en
   `dev_dependencies`, la misma versión que ya fija el `.lock`, sin bajar nada. En
   `pubspec.lock` solo cambia su línea `dependency: transitive` a `"direct dev"`. Sin ella, la
   importación directa da `depend_on_referenced_packages`, que es el aviso que
   `tool/t98_firestore_bootstrap.dart` calla con su `ignore_for_file`. No toca el arreglo, ni
   `lib/`, ni la app compilada. Después: el rojo, el verde, la suite y `analyze` otra vez.
2. **Un `// ignore_for_file: subtype_of_sealed_class` en la falsa.** Una línea y nada más cambia,
   pero rompe la línea base sin `// ignore:` y Carlos tendría que revocarla para este archivo.
3. **Cambiar `lib/` para la prueba.** Por ejemplo, que `close()` lea el documento a través de un
   puerto propio. Es una refactorización de código que funciona solo para poder probarlo: no lo
   recomiendo.

El arreglo no cambió en ningún momento: ninguna corrida lo pidió.

### 6.3 Las corridas con la falsa en la capa de plataforma (2-nov)

**Lo que cambió:**
- `pubspec.yaml`: +4 líneas en `dev_dependencies`, con su comentario de autorización:
  `cloud_firestore_platform_interface: 8.0.6`.
- `pubspec.lock`: una sola línea, `dependency: transitive` → `"direct dev"`. La versión y la
  `sha256` son las mismas. Lo hizo `flutter pub get --offline` (21:36, `pub-get.log`; la copia
  de antes está en `pubspec.lock.antes`). **Ese `pub get` lo corrí sin anunciar el semáforo
  antes; lo anoté al terminar.**
- `test/support/t129_fake_firestore.dart`, rehecha (276 líneas). Las clases que extiende están en
  4.2.
  - Una `FirebaseApp` falsa, con un nombre único por nube, porque `FirebaseFirestore.instanceFor`
    guarda una instancia por app.
  - Una plataforma global que reparte cada app a su nube. Se asigna una vez y nunca se lee: leer
    `FirebaseFirestorePlatform.instance` crea la plataforma de canales, que pide
    `Firebase.app()`. Esto lo descubrió el primer intento del rojo (21:38:47, `t129-rojo-2.log`
    antes de reescribirse): las cinco fallaron en el `setUp` con
    `[core/no-app] No Firebase App '[DEFAULT]'`, sin llegar a `close()`.
- `test/t129_cierre_test.dart`: la app recibe `db.instance` y las escuchas se abren sobre
  `db.instance.collection(…)`. Cambia también el comentario de la cabecera. Las cinco pruebas y
  sus aserciones no cambian.
- `build/t129/arreglo.dart` pasó a llamarse `arreglo.dart.txt`, con la misma huella: `analyze`
  lee los `.dart` de `build/` y la copia daba 129 avisos falsos (`analyze-2.log`, 0 fuera de la
  copia). En el rojo de 6.3 la copia se guardó en `%TEMP%` y se borró al restaurar.

**Las corridas.** Antes de cada una, ningún otro `flutter` en la máquina. Huellas finales:
arreglo `0ae18382…`, falsa `d2fe564c…`, prueba `1147d320…`.

| # | Corrida (registro en `build/t129/`) | Hora | Resultado |
|---|---|---|---|
| 1 | `flutter analyze` (`analyze-3.log`) | 21:38:32–21:38:41 | **«No issues found!»** |
| 2 | El rojo con el `close()` de `a52d203` (`fff1385d…`; `t129-rojo-2.log`) | 21:39:13–21:39:17 | **+3 −2.** La 1 falla en `Expected: not null / Actual: <null>` y la 2 en `Expected: true / Actual: <false>`, las dos con «close() contestó: not_found: No se encontró la operación para cerrarla en este dispositivo o en la nube…». Pasan la 3, la 4 y la 5. Restaurado: `0ae18382…`, **idéntico** |
| 3 | El verde (`t129-verde-2.log`) | 21:39:21–21:39:27 | **5 de 5** |
| 4 | La suite completa, una sola corrida (`suite.log`) | 21:39:34–21:42:16 | **+1876, «All tests passed!»**, sin `-` ni `~` |
| 4b | La suite otra vez, una sola corrida, con `--file-reporter json` (`suite-2.log`, `suite-2.json`) | 21:43:16–21:46:14 | **1876 de 1876** `success`, 0 fallas, 0 omitidas, 146 archivos; las 5 de `t129_cierre_test.dart` están entre ellas. La repetí porque el reportero `expanded` sin terminal no escribe una línea por prueba (2611 líneas para 1876) y en `suite.log` no se veían las de T-129. El JSON las cuenta por archivo |
| 5 | `flutter analyze` final (`analyze-final.log`) | 21:46:23–21:46:47 | **«No issues found!»**. Ningún `// ignore` en mis tres archivos |
| 6 | La repetición contra el emulador (4.3) | — | **No se corrió:** este encargo no trae luz verde para el emulador. Es lo único que mediría `hasPendingWrites` en el SDK real; la nube falsa codifica mi lectura del SDK, no la mide |

El piso queda en **1876** (1871 + 5).

### 6.4 La revisión de Codex: el plazo del cierre se reiniciaba (P2, 10.91; 2-nov, noche)

**El P2** (`docs/t129/revision-codex.md`, 4). En `_afterOwnWrite`, el `.timeout(_networkTimeout)`
iba antes del `firstWhere`. `Stream.timeout` reinicia los 45 s con **cada** evento de su fuente,
también con los que el filtro descarta después: instantáneas pendientes o de la caché que llegan
cada menos de 45 s dejaban el cierre sin plazo total. La sonda de Codex lo tenía esperando a los
160 s. Codex tiene razón; lo comprobé con el rojo de abajo.

**Base.** `733a8ab` («T-130, fase 1…»), con T-132 integrada (`7cb96ec`), la revisión de Codex
(`b08bd7f`) y la 10.91 (`fb8be28`). `git log 2d98f23..HEAD` no toca mis archivos, y
`git diff --stat` no tenía cambios sin confirmar. El `lib/` del árbol era el de `2d98f23`: sin los
`\r` (la laptop escribe CRLF), los dos dan `1b08bf20…`. Por eso el rojo corrió sobre el árbol tal
cual, sin sustituir ningún archivo.

**Los cuatro archivos** (Carlos autorizó el cuarto, la falsa, el 2-nov: la contradicción del
encargo, que limitaba a dos archivos, era de Yov):
- `lib/features/vessel/data/repositories/firestore_operation_sync.dart` (+7/−4): el filtro va
  antes del plazo,
  `snapshots(includeMetadataChanges: true).where(criterio).timeout(_networkTimeout).first`, con
  el comentario del porqué. El plazo cuenta desde que empieza la espera y solo lo reinicia una
  instantánea aceptada, que es la que termina la espera. `.first` cancela la escucha con la
  instantánea buena o con el error del plazo. El criterio, la escritura y lo demás de `close()`
  no cambian.
- `test/support/t129_fake_firestore.dart` (+25/−4): dos controles.
  - `holdEcho`: retiene el eco tras el acuse; el servidor aplica la escritura y las escuchas se
    quedan con la vista pendiente.
  - `T129FakeDocument.emitRejected({fromCache})`: entrega a las escuchas abiertas una instantánea
    que hay que descartar, la vista pendiente o el documento leído de la caché. Para eso `_snapshot`
    acepta `isFromCache`.

  Con los dos apagados, la falsa se comporta como antes: las cinco pruebas de siempre dan lo mismo
  en el rojo y en el verde.
- `test/t129_cierre_test.dart` (+90): un grupo nuevo con dos pruebas en `testWidgets`, cuyo
  `tester.pump(d)` es el reloj simulado (sin `fake_async`, que es transitiva). Las dos comprueban,
  al terminar: código `timeout`, la nube cerrada, ninguna escucha abierta y la copia local abierta.
  1. **En silencio**: con el eco retenido, a los 44 s `close()` sigue esperando y a los 46 s
     contestó `timeout`.
  2. **Con instantáneas rechazadas sostenidas**: una pendiente a los 40 s; a los 44 s sigue
     esperando y a los 46 s contestó `timeout`. Después, más rechazos a los 80, 120 y 160 s (de la
     caché, pendiente y de la caché), sin nadie escuchando y sin cambiar el resultado.
- Este informe.

**Una trampa del reloj simulado, que Codex también encontró.** `Stream.timeout` cancela su fuente
devolviendo `subscription.cancel()`, que es `Future._nullFuture`, de la zona **raíz**. Con
`cancelOnError`, el error del plazo se entrega cuando esa cancelación termina, y esa continuación no
corre bajo el reloj simulado de `testWidgets`. El plazo vence y la escucha se suelta, pero `close()`
no termina nunca. Lo vi en dos corridas de diagnóstico: una sonda temporal mostró `listeners=0` y
`result=null` a los 46 s y cinco minutos después. La prueba lo resuelve con `pasa()`, que tras cada
`pump` da tres vueltas del bucle real con `tester.runAsync`. Es lo mismo que Codex anotó en su
revisión (2: «ajustar la espera de continuaciones asíncronas fuera del reloj simulado»). Mientras lo
buscaba probé a cambiar el `onCancel` de la falsa y lo revertí: no era la causa. La sonda ya no está
en la prueba.

**Las corridas** (registros en `build/t129/plazo/`; de a una y con `SEMÁFORO:`; antes de la
suite, ningún otro `flutter` en la máquina). Huellas finales: `lib` `f2256e5a…`, falsa
`a1aaee9b…`, prueba `8c0f4364…`.

| # | Corrida | Hora | Resultado |
|---|---|---|---|
| — | Diagnóstico de las pruebas nuevas, sin `pasa()` (`diagnostico.log`, y una sonda de silencio sin registro) | 23:02–23:05 | Las dos nuevas cuelgan también en silencio, por la trampa de arriba. **No cuentan como rojo** |
| 1 | **El rojo**: `flutter test test/t129_cierre_test.dart` con el `lib/` de `2d98f23` (`1b08bf20…` sin `\r`) y la falsa nueva (`rojo.log`) | 23:06:20–23:06:26 | **+6 −1.** Pasan las cinco de siempre y la de silencio, como en la sonda de Codex. Falla la de rechazos sostenidos, en la línea 267, la comprobación de los 46 s: «Expected: not null / Actual: <null> / close() sigue esperando». El evento de los 40 s reinició el plazo |
| 2 | **El verde**, con la corrección (`verde.log`) | 23:06:48–23:06:52 | **7 de 7** |
| 3 | **La suite completa**, una sola corrida, con `--file-reporter json` (`suite.log`, `suite.json`) | 23:07:01–23:09:24 | **1914 de 1914** `success`, 0 fallas, 0 omitidas, 149 archivos; las 7 de `t129_cierre_test.dart` están entre ellas. Es el piso de 1912 (sprint-4 con T-132) más las 2 nuevas |
| 4 | **`flutter analyze`** (`analyze.log`) | 23:09:34–23:10:06 | **«No issues found!»**. Ningún `// ignore` ni `print` en los tres archivos de código |

El piso queda en **1914**. El emulador no se corrió: la 10.91 lo deja para la revisión de la
corrección o para la aceptación de la candidata.

## 7. Lo que no entra y los límites

- No medí `hasPendingWrites` de la lectura que falló: Codex no la instrumentó. La rama sale por
  eliminación (3.2) y por la fuente del SDK (3.3); 4.3 dice cómo medirla.
- No medí el caso sin listado en el emulador, ni Windows ni Android. El código dice que es igual.
- No toqué `cloud_page.dart`: el mensaje «No se encontró la operación…» sigue sirviendo para las
  dos ramas que quedan (sin operación local; sin hora tras el eco), que ahora sí son raras.
- La 10.84 sigue sin confirmar en Git al escribir esto; `SPRINT-4.md` y `LISTA-PILOTO.md` son de
  Yov y no van en mi bloque.
- `build/t129/` está en `.gitignore` (`/build/`): la evidencia se queda en el disco, como la de
  T-127, y el informe la describe.

## 8. Archivos tocados

**Nuevos**

- `test/support/t129_fake_firestore.dart` — la nube falsa al nivel del SDK (4.2).
- `test/t129_cierre_test.dart` — las cinco pruebas (4.2).
- `tool/t129_evidencia.py` — extrae de la evidencia de Codex lo que cita el informe y coteja el
  SDK empaquetado; escribe en `build/t129/`.
- `docs/T129-RESULTADOS.md` — este informe.
- `build/t129/` (no se versiona): `LEEME.md`, `codex-paso13-comandos.json`,
  `codex-chip-antes-del-cierre.json`, `codex-sonda-local.json`, `sdk-12.17.0-cotejo.json`; y,
  del 2-nov, los registros de 6.1 y 6.3 (`analyze*.log`, `t129-rojo*.log`, `t129-verde*.log`,
  `pub-get.log`, `suite.log`, `suite-2.log`, `suite-2.json`), `pubspec.lock.antes` y
  `arreglo.dart.txt` (la copia de mi versión del primer rojo, `0ae18382…`).

**Modificados**

- `lib/features/vessel/data/repositories/firestore_operation_sync.dart` — `_afterOwnWrite` y su
  uso en `close()` (+18/−1); el 2-nov por la noche, el filtro antes del plazo (6.4, +7/−4).
- La corrección del P2 (6.4) toca también la falsa (`holdEcho`, `emitRejected`) y la prueba (dos
  pruebas nuevas), además de este informe.

- `pubspec.yaml` — **sí cambia** (2-nov, autorizado por Carlos): `cloud_firestore_platform_interface:
  8.0.6` en `dev_dependencies`, +4 líneas con su comentario.
- `pubspec.lock` — **sí cambia**: una línea, `transitive` → `"direct dev"`; la misma versión.

No cambian `lib/main.dart`, las opciones de Firebase, las reglas, el contrato, la presentación ni
los archivos congelados. La dependencia es solo de pruebas y no entra en la app compilada.

## 9. Bloque de Git para Carlos

**La corrección del P2 (6.4), lista para ejecutarse (2-nov, 23:10):** rojo +6 −1, verde 7 de 7,
suite 1914 de 1914 y `analyze` en cero. Son cuatro archivos y **no cambian `pubspec.yaml` ni
`pubspec.lock`**. No van los cambios ajenos que haya en el árbol. Después, Codex la vuelve a
revisar (10.91), y la fase 2 de T-130 empieza sobre este commit.

```powershell
Set-Location -LiteralPath C:\Proyectos\baystream-rediseno
git add -- lib/features/vessel/data/repositories/firestore_operation_sync.dart
git add -- test/support/t129_fake_firestore.dart
git add -- test/t129_cierre_test.dart
git add -- docs/T129-RESULTADOS.md
git commit -m "Sprint 4: T-129, el plazo del cierre no se reinicia con instantaneas rechazadas" --trailer "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
git push origin sprint-4
git log --oneline -1
```

**El bloque anterior, ya ejecutado por Carlos (`2d98f23`), queda como registro:**

**Listo para ejecutarse (2-nov, 21:46):** rojo +3 −2, verde 5 de 5, suite 1876 de 1876 y
`analyze` en cero (6.3). **Cambian `pubspec.yaml` y `pubspec.lock`** (8). Los cambios ajenos del
árbol no van: `test/t114_fase3_correccion_test.dart` y los tres de `windows/flutter/` solo
difieren en el fin de línea, y `docs/t117/entrega1/…` no es mío. La revisión corta de Codex
(10.84, 10.88) va después de este commit. Si el arreglo no entra antes de publicar, el mismo
bloque vale para la 0.4.2.

```powershell
Set-Location -LiteralPath C:\Proyectos\baystream-rediseno
git add -- pubspec.yaml
git add -- pubspec.lock
git add -- lib/features/vessel/data/repositories/firestore_operation_sync.dart
git add -- test/support/t129_fake_firestore.dart
git add -- test/t129_cierre_test.dart
git add -- tool/t129_evidencia.py
git add -- docs/T129-RESULTADOS.md
git commit -m "Sprint 4: T-129, el cierre que falla despues de revisar el listado (O-128-2)" --trailer "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
git push origin sprint-4
git log --oneline -1
```

## 10. Tres líneas

**La corrección del P2 (6.4):**

- El plazo de 45 s del cierre ya no se reinicia con instantáneas descartadas: el filtro va antes
  del plazo (`where(…).timeout(…).first`) y cuenta desde que empieza la espera.
- Dos pruebas nuevas con reloj simulado, en silencio y con rechazos cada 40 s hasta los 160 s; la
  falsa gana `holdEcho` y `emitRejected`. Rojo contra `2d98f23`: +6 −1, falla la de rechazos a los
  46 s.
- Verde 7 de 7, suite 1914 de 1914 en una corrida y sin omitidas, y `analyze` en cero. Cuatro
  archivos, sin `pubspec.*`.

**Las del 2-nov, antes de la revisión:**

- El primer cierre fallaba porque, con la oficina escuchando el documento desde T-127, la lectura
  «del servidor» que sigue a la escritura devuelve la vista local con `closedAt` todavía
  pendiente, que se lee como nulo: la nube se cerraba y el dispositivo no; `close()` es el mismo
  desde T-79 y revisar el listado no es la condición.
- Cinco pruebas nuevas contra una nube falsa al nivel del SDK, dos rojas hoy por comportamiento
  (con y sin listado); el arreglo son 18 líneas en `data/`: después de escribir, `close()` espera
  la primera instantánea del servidor sin escrituras pendientes. Nada cambia en reglas, contrato
  ni mensajes.
- El 2-nov, con luz verde, todo corrió. La falsa pasó a la capa de plataforma, con una
  dependencia de desarrollo autorizada, porque las clases del SDK son `@sealed`. Rojo +3 −2 por
  comportamiento, verde 5 de 5, suite 1876 de 1876 y `analyze` en cero. El cierre bueno de la
  26043X (10.87) era con la 0.4.0: cuadra con el diagnóstico, no lo pone a prueba y el arreglo
  sigue haciendo falta (3.5).

## 11. Mensaje para Yov

**El de la corrección del P2 (2-nov, noche):**

> T-129, el P2 de Codex corregido sobre `733a8ab` (sprint-4 con T-132). En `_afterOwnWrite` el
> filtro va ahora antes del plazo: `where(criterio).timeout(45 s).first`. Las instantáneas
> descartadas ya no reinician los 45 s, y `.first` suelta la escucha con la buena o con el plazo.
> Dos pruebas nuevas en `t129_cierre_test.dart`, con reloj simulado (`testWidgets`), en silencio y
> con rechazos a los 40, 80, 120 y 160 s: `timeout` a los 46 s, la nube cerrada, ninguna escucha y
> la copia local abierta. La falsa gana `holdEcho` y `emitRejected` (Carlos autorizó el cuarto
> archivo; el encargo decía dos), y las cinco de siempre no cambian. Rojo contra el `lib/` de
> `2d98f23`: +6 −1, como la sonda de Codex (silencio pasa, rechazos sostenidos fallan a los 46 s).
> Verde 7 de 7; suite 1914/1914 en una corrida, sin omitidas, con las 7 adentro; `analyze` cero;
> sin `pubspec.*`. Una trampa del reloj simulado: la cancelación de `Stream.timeout` pasa por
> `Future._nullFuture`, de la zona raíz, y hay que darle vueltas reales con `runAsync`, como anotó
> Codex. Lo cuenta 6.4. Emulador sin correr. Bloque de Git en la sección 9, con cuatro archivos.
> Después: la nueva revisión de Codex y la fase 2 de T-130.

**El del 2-nov, con las corridas:**

> T-129, corridas hechas sobre `687d68d` (la 10.84 a la 10.88 ya están en Git; no toqué nada
> ajeno). La primera falsa no pasaba `analyze`: 4 avisos, porque implementaba `DocumentReference`,
> `DocumentSnapshot` y `Query`, que son `@sealed`. Carlos autorizó rehacerla en la capa de
> plataforma, con `cloud_firestore_platform_interface 8.0.6` como dependencia de desarrollo. Ya
> estaba en el `.lock`, que cambia una sola línea (`transitive` → `"direct dev"`). Ahora la prueba
> corre sobre las clases reales de `cloud_firestore`. Las cinco pruebas y el arreglo no cambiaron.
> Resultados: rojo contra el `close()` de `a52d203`, +3 −2 por comportamiento («not_found…»), con
> la huella restaurada idéntica; verde 5 de 5; suite 1876 de 1876 en una sola corrida y sin
> omitidas, con el JSON del reportero mostrando las 5 de T-129 adentro; `analyze` «No issues
> found!». El emulador no se corrió: no había luz verde para él. El cierre de la 26043X en Windows
> (10.87) era con la 0.4.0, que no escucha el documento: cuadra con el diagnóstico, no lo pone a
> prueba y el arreglo sigue haciendo falta. Con la 0.4.1, un cierre bueno solo diría que esa vez
> el eco llegó antes que el acuse (3.5). Carlos confirma la versión de la laptop. Bloque de Git
> en la sección 9, con `pubspec.*`. Sigue la revisión corta de Codex. Informe en
> `docs/T129-RESULTADOS.md`, evidencia en `build/t129/`.

**El del 30-oct, sin corridas:**

> T-129 escrita sin luz verde (10.84), sobre `a52d203` (la 10.84 está en el árbol sin confirmar;
> no toqué nada ajeno). Diagnóstico: falla la rama de `closedAt`, no la de la operación local. La
> sonda de Codex muestra la operación local leída cada segundo, publicada y abierta, hasta el
> segundo cierre; la nube quedó cerrada a las 04:13:10 UTC y la pantalla dijo `not_found` más de
> 30 s. La causa está en el SDK, leído en su etiqueta 12.17.0 y cotejado con el paquete que sirve
> la Web: la lectura «del servidor» es una escucha de una vez sobre la misma consulta; como la
> oficina ya escucha el documento desde T-127 (`watchList`, el motor que corre también la
> oficina), recibe la última vista de esa escucha, que tras el `update` lleva `closedAt` pendiente
> (se lee como nulo con `ServerTimestampBehavior.none`); el acuse resuelve el `update()` antes de
> emitir y el SDK calla la instantánea del acuse hasta el eco de Watch
> (`shouldWaitForSyncedDocument`). La segunda vez el eco ya llegó. `close()` es idéntico en
> `be532ab`; en la 0.4.0 no había escucha sobre el documento, por eso cerraba bien. Revisar el
> listado no es la condición: basta la oficina siguiendo la operación («Al día»). Prueba roja:
> una nube falsa al nivel del SDK (`test/support/t129_fake_firestore.dart`, la de T-79 no llega a
> `close()`) y cinco pruebas en `test/t129_cierre_test.dart`, dos rojas hoy por comportamiento
> (con y sin listado) y tres de protección. Arreglo: `_afterOwnWrite` en `data/`, +18/−1, espera
> la primera instantánea del servidor sin escrituras pendientes, con el mismo tiempo límite; nada
> en reglas, contrato, mensajes ni `pubspec.*`. Pendiente con la luz verde: `analyze`, el rojo
> contra `a52d203`, el verde, la suite en 1876 y, si lo quieres, la repetición contra el emulador
> con el banco de Codex (4.3, con la medición directa de `hasPendingWrites`). Informe en
> `docs/T129-RESULTADOS.md`, evidencia en `build/t129/`. ALTO: Yov revisa.

**ALTO: Yov revisa.**
