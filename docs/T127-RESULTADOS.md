# T-127 · El listado en una operación publicada (H2 del piloto) · Resultados

Timonel (Claude Code, Claude Fable 5.1). Rama `sprint-4`, carpeta del rediseño
(`C:\Proyectos\baystream-rediseno`), punta `cf7cf3f` («Sprint 4: decision 10.78…»), con T-119
(`6106613`) y el arreglo de T-93 (`a0dc4b0`) debajo. Es la segunda parte de la 0.4.1 (10.76 y
10.78 de `SPRINT-4.md`), con el diseño de la sección 8.3 de `docs/T122-RESULTADOS.md` tal cual lo
aprobó Carlos. Este informe dice qué se hizo, cómo se comprobó, qué le pasa a un cliente 0.4.0 y
qué tiene que hacer Carlos con las reglas y con la prueba de punta a punta.

## 1. Resultado en tres líneas

- **La oficina agrega o reemplaza el listado de la agencia en una operación publicada y abierta.**
  El listado sube a la nube con una revisión (1, 2, 3…) en un solo lote, los BAPLIE no cambian, y si
  la nube no lo acepta nada local cambia. Antes de confirmar, el cruce dice con números «n
  contenedores ya cargados no están en el listado nuevo» y «m vacíos asignados cambian de grupo».
- **El muelle lo recibe solo:** el motor escucha también el documento de la operación, baja solo los
  trozos de la revisión nueva, comprueba las huellas como `join`, guarda la fuente en la operación
  local y la pantalla avisa «Listado actualizado por la oficina: n filas». Sin red, sigue con el
  listado que tenía hasta reconectar. Los movimientos no se pierden ni cambian: el estado se vuelve
  a derivar con el listado nuevo. `join` toma la última revisión; lo ya publicado se sigue uniendo.
- **Las reglas nuevas** son `docs/T127-firestore.rules.propuesta`: las de T-80 más las dos cláusulas
  de 8.3. Las publica Carlos desde la consola, después de la aceptación de Codex y antes de los
  clientes de la 0.4.1 (sección 7). La versión no cambia: `pubspec.*` queda como está. **Cifras:**
  19 pruebas nuevas en verde, que no compilan contra `cf7cf3f`; la suite, 1871 de 1871 en una
  corrida; `analyze` en cero. En el emulador, contra las reglas de T-127: las 69 de T-80, los 25
  abusos de T-113 y los 31 casos nuevos, todos lo esperado; contra las de T-80, las 69 y los 25
  siguen igual y de los 31 caen los cuatro que la revisión permite: el rojo de las reglas (5.4).

## 2. Base, luz verde y lo que se corrió

- **Leí**, en el orden del encargo: `CLAUDE.md` con `AGENTS.md`; de `SPRINT-4.md`, la sección 2 y
  las decisiones 10.49 a 10.52, 10.55 a 10.57 y 10.74 a 10.78; de `docs/T122-RESULTADOS.md`, 8,
  8bis y la O1 de 8ter; `docs/T80-firestore.rules.propuesta`, `tool/t80_reglas.mjs`,
  `tool/t113_reglas_abuso.mjs`, `tool/t113_emulador.ps1` y los informes de T-80 y T-113 (1.1 a
  1.4); y el código: `firestore_operation_sync.dart`, `operation_sources.dart`, el contrato
  `OperationSyncRepository`, `export_list_providers.dart`, `sync_engine.dart`,
  `operation_state_deriver.dart`, `departure_baplie_writer.dart` y las pruebas de T-79 con su nube
  falsa (`test/support/t79_fake_cloud.dart`).
- **La punta** era `cf7cf3f`. `git diff --stat` marcaba los mismos cuatro archivos de siempre
  (`test/t114_fase3_correccion_test.dart` y tres de `windows/flutter/`), que solo difieren en el
  fin de línea, y las carpetas sin seguimiento de `docs/t117/entrega1/`. No son míos, no los toqué
  y no van en el bloque.
- **Flutter y el emulador:** la entrega se escribió sin luz verde (10.78: «mientras no haya luz
  verde, lee, diseña y escribe código»), con Node como única herramienta (`node --check` de los
  cuatro `.mjs` y `tool/t113_reglas.mjs` sobre el archivo nuevo de reglas, para anotar su huella,
  7.2). Carlos dio la luz verde para Flutter y `analyze` el 29-oct a media mañana, **sin internet
  en la laptop y sin el emulador todavía**: con ella corrieron, de a un comando, `analyze`, las
  pruebas nuevas hasta que pasaron, las mismas contra una copia de `cf7cf3f` y la suite completa
  (sección 5). Hacia el mediodía dio la luz verde de la laptop para el emulador: las seis baterías
  corrieron de una vez con `tool/t127_baterias.ps1`, en 8282 y `demo-t127`, sin internet (el JAR
  1.22.0 estaba en la caché de `firebase-tools`), y el emulador se cerró al terminar (5.4).

## 3. Lo hecho (los cinco puntos de 8.3)

### 3.1 Las reglas: `docs/T127-firestore.rules.propuesta` (punto 1)

Parte de `docs/T80-firestore.rules.propuesta` (lo publicado, 10.108 de `SPRINT-3.md`), que no se
toca, y solo agrega las dos cláusulas; un `diff` entre los dos archivos muestra únicamente el
encabezado nuevo y estos bloques:

- **`operations/{id}`:** `allow update: if isOffice() && (validClosing() || validListRevision())`.
  `validListRevision()` exige que la operación siga `open`, que `affectedKeys()` sea solo
  `['sources']`, que dentro de `sources` solo cambie `export_list` (las entradas de los dos BAPLIE
  quedan iguales, `sources.diff(...)`), y que la entrada nueva traiga exactamente `fileName`,
  `sha256` (hex de 64), `parts` (1 a 20), `length` y un entero `revision` **mayor que el anterior**,
  o **igual a 1 si no había listado**. Un listado publicado con la operación, sin `revision`, cuenta
  como revisión 0.
- **`sources/{sourceId}`:** `validSource` acepta el trozo de siempre (`validPublishedPart`, el
  texto de T-80 sin cambios) **o** un trozo de revisión (`validRevisionPart`): el id
  `export_list-r{revision}-{i}`, `kind == 'export_list'`, un campo `revision` igual al que `getAfter`
  ve en el manifiesto, y la huella y el número de trozos del manifiesto. `update` y `delete` siguen
  en `false`: los trozos anteriores quedan como historia.
- **Los movimientos no cambian de reglas.** Cerrar sigue igual (`validClosing` no mira `sources`).

### 3.2 Cómo viaja el listado con revisión (`source_revisions.dart`, nuevo en `data/`)

Dart puro, compartido por `publish`, `join`, `replaceSource` y el motor:

- `packSource(source, revision:)` parte el texto (300 000 caracteres por trozo, sin cortar un par
  sustituto) y arma los trozos con la huella del texto entero y la entrada del manifiesto
  (`SourceManifestEntry`: `fileName`, `sha256`, `parts`, `length` y, con revisión, `revision`).
- `assembleSource(entry, parts)` une los trozos del tipo **y la revisión** que el manifiesto declara
  (sin revisión, los publicados con la operación; con ella, solo los de esa revisión, aunque queden
  los anteriores), comprueba el número, la huella de cada trozo y la del texto unido sobre el texto
  tal como se publicó (10.11), y devuelve la `OperationSource` con su `revision`, o `null`.
- `sourceHash` y `splitSource` viven aquí; `FirestoreOperationSync.sourceHash` y `splitSource`
  siguen existiendo y delegan, para no tocar las pruebas de T-79 que los usan.

### 3.3 El dominio

- `OperationSource.revision` (`int?`): nulo en los BAPLIE y en un listado publicado con la
  operación; 1, 2, 3… cuando la oficina lo agregó o lo reemplazó después. Va y vuelve en el JSON
  (`revision` solo si existe), así que las operaciones guardadas antes se leen igual.
  `Operation.exportListRevision` da 0 sin listado o con el publicado.
- `OperationSyncRepository.replaceSource(operation, source)`: el método nuevo del contrato.
  `SyncStatus.listArrival` (`ListArrival(revision, rows)`): el último listado que llegó por la nube
  en esta escucha, para que la pantalla avise.
- `OperationSources.save(…, sync:)`: en una operación publicada acepta un `export_list` nuevo o
  distinto, **solo ese tipo**, y lo sube por `sync.replaceSource`; si la nube no lo acepta, lanza
  su `Failure` y no cambia nada local. Un BAPLIE distinto sigue rechazado («…sus BAPLIE no cambian;
  solo el listado de la agencia se puede reemplazar»), una operación cerrada también, y sin nube
  (`sync` nulo) lo dice.
- `ExportListCrossChecker.revisionImpact(state, previous, next)` (`ExportListRevisionImpact`): lo
  ya operado contra el listado nuevo: los contenedores ya cargados (llenos por su número y vacíos
  asignados) que el listado nuevo no trae, y los vacíos asignados cuya fila cambia de grupo (tipo,
  puerto o línea) frente al listado anterior o, sin él, frente a su reserva.

### 3.4 La oficina (punto 2)

- `FirestoreOperationSync.replaceSource`: exige sesión de oficina autorizada, lee la operación del
  servidor (sin red falla enseguida), la rechaza si no existe o está cerrada, calcula la revisión
  siguiente a la del manifiesto (1 si no había listado o si venía sin revisión) y escribe **en un
  solo lote** los trozos `export_list-r{n}-{i}` (con `revision`) y la entrada
  `sources.export_list` del manifiesto (`FieldPath(['sources', 'export_list'])`, solo esa entrada).
  Si el lote pasa, guarda la fuente con su revisión en la operación local y la devuelve; si no,
  devuelve el fallo con causa y acción (permiso denegado: «…la operación está cerrada, la cuenta no
  es de oficina o alguien acaba de cambiar el listado…»; sin red; sin respuesta).
- `ExportListImportNotifier.confirm`: si la operación de la escala está publicada, pasa la nube a
  `OperationSources.save`; el listado se guarda **antes** que las equivalencias, para que un fallo
  de la nube no deje nada local cambiado. El mensaje final dice la revisión: «Listado guardado en la
  operación publicada de GTSTC: n filas, revisión r. El muelle lo recibe solo.» Un `Failure` de la
  nube se muestra con su propio texto.
- **El aviso del cruce, antes de confirmar:** al leer el Excel, el notificador deriva el estado de
  la operación con el listado que tiene hoy (`OperationStateDeriver`, los movimientos no
  rechazados) y, con cada equivalencia que se elige, recalcula el impacto sobre el listado
  normalizado. La página lo muestra en una tarjeta nueva, «Lo ya operado con el listado nuevo»,
  con dos líneas con número (`revision-loaded-missing`, `revision-empties-regrouped`) y la lista de
  contenedores de cada una. Si la bitácora no se puede leer, el cruce va sin este aviso: no impide
  leer el listado. Sin movimientos no hay tarjeta.

### 3.5 El muelle (punto 3)

- El puerto del motor (`RemoteMovementStore`) suma `watchList(operationId)` (la entrada
  `sources.export_list` del manifiesto, al suscribirse y cada vez que el servidor la cambia; una
  escritura propia pendiente no cuenta) y `listParts(operationId, revision)` (solo los trozos de esa
  revisión, del servidor, por un índice de un solo campo que Firestore crea solo).
- `SyncEngine` escucha el manifiesto junto con los movimientos. Cuando la revisión remota es mayor
  que la local, relee la operación local (lo que el dispositivo ya guardó manda: la oficina que
  acaba de revisar no recibe su propio listado como novedad), baja los trozos, los arma y comprueba
  como `join`, cuenta las filas, guarda la fuente en la operación local **sin tocar los
  movimientos** y emite `listArrival`. Sin red, `listParts` falla y el motor se queda con el listado
  anterior; lo reintenta con el siguiente contacto con el servidor (un movimiento que llega, el
  reloj de 15 s, «Reintentar»). Una revisión cuyos trozos no cuadran se anota y no se vuelve a
  pedir: el muelle sigue con su listado.
- `AvisoDelListado` (`widgets/aviso_del_listado.dart`, nuevo), dentro de la página del viaje:
  escucha `syncStatusProvider`, avisa una vez por revisión con `avisoDelViaje` («Listado actualizado
  por la oficina: n filas.», 6 s, flota como los demás avisos) y llama a
  `operationSourcesRevisionProvider.changed()`, con lo que el plano, el avance y la operación se
  vuelven a derivar con el listado nuevo. Lo que llegó antes de armarse la página no es noticia.

### 3.6 `join` toma la última revisión (punto 4) y los movimientos (punto 5)

- `join` lee todos los trozos y, por cada tipo del manifiesto, arma la fuente con
  `assembleSource`: con `revision`, solo los `export_list-r{n}-{i}` de esa revisión; sin ella,
  los `export_list-{i}` de siempre. La `OperationSource` guardada lleva la revisión, así el motor
  arranca sabiendo cuál tiene. `publish` no cambia: los trozos de las fuentes publicadas siguen sin
  revisión, y un cliente 0.4.0 puede unirse a una operación recién publicada por la 0.4.1.
- Los movimientos viven en `movements/` con claves naturales (`C:número`, `R:posición`) y no se
  tocan: ni `replaceSource` ni el motor los escriben. `OperationStateDeriver` los vuelve a aplicar
  con el listado nuevo: lo que cambia es lo que el listado les da (los OR, los pesos exactos, los
  grupos de los vacíos y, con ellos, los avisos «vacío de otro grupo»). `DepartureBaplieWriter` no
  cambia: lee el listado de la operación, el que esté.

## 4. Compatibilidad con la 0.4.0 (obligatoria)

Un cliente 0.4.0 (`v0.4.0`, lo publicado el 28-oct) no sabe de revisiones: `join` recorre los
tipos del manifiesto y, para cada uno, toma **todos** los trozos de ese `kind`; `follow` solo
escucha `movements`; `OperationSources.save` rechaza cualquier fuente nueva o distinta en una
operación publicada.

| Caso | Lo que hace un cliente 0.4.0 | Daño |
|---|---|---|
| **Se une** a una operación que ya tiene una revisión | Toma los trozos `export_list-{i}` publicados (si los hay) **y** los `export_list-r{n}-{i}` de todas las revisiones, así que el número de trozos o la huella no cuadran con el manifiesto: `join` falla con `source_mismatch` («La fuente «listado de la agencia» llegó incompleta o distinta de la publicada. No se guardó nada: vuelve a intentarlo») y no guarda nada. Único caso en que pasaría: una operación publicada sin listado con **una sola** revisión (solo hay trozos `r1`): la 0.4.0 se une y toma ese listado, sin saber que es la revisión 1 | Ninguno. No puede seguir, y lo dice |
| **Ya estaba unido** y la oficina revisa el listado | No se entera: sigue con el listado que tenía (o sin listado), registra movimientos y los sube; las reglas de los movimientos no cambian, así que la nube los acepta igual. Sus OR y sus pesos exactos son los del listado viejo; una carga de un lleno sin fila sigue funcionando por su número (H4) | Ninguno sobre la operación ni sus movimientos. Solo ve el listado viejo hasta que pase a la 0.4.1 y se vuelva a unir, o hasta que la 0.4.1 le baje la revisión al arrancar |
| **Oficina 0.4.0** con una operación revisada | No puede revisar ni cambiar nada: su `save` rechaza el listado y su código nunca escribe `sources`. Cierra la operación igual que siempre | Ninguno |
| **Oficina 0.4.1 publica** y un muelle 0.4.0 se une antes de cualquier revisión | `publish` no cambió: los trozos van sin revisión y la 0.4.0 se une como siempre | Ninguno |

**La regla de uso:** las reglas nuevas se publican primero; la laptop y el Honor pasan a la 0.4.1
antes de usar la función. Mientras las reglas publicadas sigan siendo las de T-80, la 0.4.1 que
intente revisar recibe «La nube no aceptó el listado…» y no cambia nada local; con las reglas de
T-127 publicadas, la 0.4.0 sigue trabajando como hasta hoy.

## 5. Pruebas

**19 pruebas nuevas** en dos archivos, de a un comando y con la evidencia en `build/t127/`:

1. `flutter analyze lib test integration_test` antes de correr nada: **No issues found** en los
   tres directorios (`01-analyze-primero.log`, 61 s).
2. `flutter test --no-pub` de los dos archivos: en la primera corrida pasaron 17 de 19
   (`02-pruebas-nuevas.log`); las dos que fallaron eran defectos de la prueba, no del producto, y
   se corrigieron sin tocar `lib/`: la oficina buscaba el aviso de arriba con la lista todavía
   desplazada hasta la tarjeta del cruce (un `ListView` no construye lo que quedó atrás: ahora
   comprueba el mensaje en el estado y vuelve arriba), y el muelle contaba los 6 s del aviso antes
   de que terminara de entrar (ahora `pumpAndSettle` y después los 7 s). Con eso, **19 de 19**
   (`03-pantallas-corregidas.log`, 5 de 5; `04-pruebas-nuevas-verde.log`, los dos archivos juntos,
   «+19: All tests passed!»).
3. **Las mismas contra el código de antes:** una copia del árbol en `%TEMP%\t127-antes\copia`
   (robocopy sin `.git`, `build`, `docs` ni `.dart_tool`; con `package_config.json`,
   `package_graph.json`, `version` y `.flutter-plugins-dependencies` del árbol, como en T-119), con
   los diez archivos de `lib/` que toca T-127 repuestos desde `HEAD` con `git show` y los dos nuevos
   de `lib/` borrados; los dos archivos de prueba y `test/support/t79_fake_cloud.dart` quedaron
   como están. `flutter test --no-pub` de los dos archivos ahí: **ninguno compila** («Failed to
   load»; `05-rojo-contra-cf7cf3f.log`): 136 errores en el del motor, 38 en el de pantallas y 28 en
   la nube falsa, todos por el contrato que no existe en `cf7cf3f` (`exportListRevision`,
   `assembleSource`, `SyncStatus.listArrival`, `save(sync:)`, `OperationSource.revision`,
   `revisionImpact`, `SourceManifestEntry`, `ExportListImportState.impact`, `ListArrival`,
   `packSource`…). Es la prueba roja que admite un contrato nuevo: no es «cada una en su
   comprobación», y se dice así. Las reglas sí tienen su rojo caso por caso (5.4).
4. La suite completa en una sola corrida, `flutter test --no-pub --reporter expanded`: **1871 de
   1871**, sin fallas ni omitidas, en 1 min 56 s (`06-suite-completa.log`); son las 1852 del piso
   más las 19 nuevas, **el piso de `sprint-4` sube a 1871**. El reportero `expanded` en paralelo no
   imprime el nombre de todas las pruebas (nombra 65 de los 145 archivos; el recuento final sí es
   de todas), por eso los dos archivos nuevos se corrieron también solos (`04-…`). `analyze` de
   nuevo al final, con la prueba de pantallas ya corregida: **No issues found**
   (`07-analyze-final.log`).
5. Las baterías en el emulador (5.4): **todas dieron lo esperado**, y la de T-127 contra las
   reglas de T-80 cae exactamente donde tiene que caer.

### 5.1 El motor (`test/t127_listado_revision_test.dart`, contra la nube falsa de T-79)

`FakeServer` suma el manifiesto del listado (`listManifest`) y los trozos de todas las revisiones
(`sourceParts`), con `publishList` (sin revisión, como `publish`) y `reviseList` (la revisión
siguiente, en un lote, como `replaceSource`); `FakeCloud` suma `watchList` (con red, el servidor;
sin red, lo último visto, como la caché del SDK) y `listParts` (sin red falla; `listPartsFailures`
hace fallar las primeras bajadas). Sobre la bitácora real en Hive, en una carpeta temporal por
prueba que se borra al terminar:

- la revisión 1 llega al muelle sin movimientos previos: la operación local guarda el listado con
  su revisión, el plan de carga no cambia, `listArrival(1, 2 filas)`, y el mismo manifiesto repetido
  no vuelve a bajar nada;
- la revisión 2 llega con movimientos: un lleno cargado y un vacío asignado, confirmados, siguen
  con los mismos ids y estados, la nube no recibió ni perdió movimientos, y el estado derivado con
  el listado nuevo tiene el lleno en su celda, el vacío asignado y, como el listado nuevo lo pone en
  otra línea, el aviso «vacío de otro grupo»;
- sin red, el muelle se queda con el listado anterior (ni aviso ni bajada) y baja el nuevo al
  reconectar;
- si los trozos no bajan a la primera, el motor lo reintenta con el siguiente contacto con el
  servidor (un movimiento de otro dispositivo);
- una revisión cuyos trozos no cuadran con el manifiesto se ignora y no se vuelve a pedir;
- el dispositivo que acaba de revisar el listado (la oficina) no lo recibe como novedad.

### 5.2 Unirse, la oficina y el cruce (mismo archivo)

- `join` toma la última revisión: con `export_list-0`, `r1` y `r2` en `sources/`, el manifiesto con
  `revision: 2` arma solo la 2; un manifiesto sin revisión arma los trozos publicados con la
  operación aunque ya haya revisiones; trozos que no cuadran (texto, huella, faltan o sobran) dan
  `null`; la fuente guarda su revisión en JSON y una guardada antes se lee sin ella; los ids
  `export_list-r2-0` y `loading_baplie-1`; `packSource` escribe `revision` solo cuando la hay.
- `OperationSources.save` en una operación publicada: el listado nuevo sube por `replaceSource` y
  lo que la nube devuelve queda en la operación (revisión 1, luego 2; el mismo listado no sube);
  si la nube no acepta, se lanza su `FirestoreFailure` y la operación local queda idéntica; un
  BAPLIE distinto, una operación cerrada o una compilación sin nube siguen sin cambiar nada.
- `revisionImpact`: con un lleno cargado por su fila, otro cargado sin fila (H4) y un vacío
  asignado, un listado nuevo sin el segundo y con el vacío en otra línea da `['TSTU0000035']` y
  `['TSTU0000020']`; con todas las filas y el mismo grupo, nada; sin listado anterior, el grupo se
  compara con el de la reserva; un vacío asignado que el listado nuevo no trae cuenta como cargado
  sin fila.

### 5.3 Las pantallas (`test/t127_listado_pantallas_test.dart`)

- **La oficina**, a 360 dp, con el plan y el listado sintéticos de T-73 y una operación publicada
  con un listado anterior, un lleno cargado por su número (`TSTU0000090`, que el listado nuevo no
  trae) y un vacío asignado (`TSTU0000040`, que el listado anterior ponía en la línea LNA y el
  nuevo en LNX): la tarjeta dice «1 contenedor ya cargado no está en el listado nuevo» y «1 vacío
  asignado cambia de grupo»; «Confirmar e importar» llama a `replaceSource` una vez, la operación
  queda con el listado de 7 filas en la revisión 1, el plan de carga y los dos movimientos
  intactos, las equivalencias guardadas y el mensaje con «revisión 1».
- Si la nube no acepta: `replaceSource` se llamó una vez, el listado anterior sigue sin revisión,
  las equivalencias no se guardaron, el mensaje de la nube se ve y el listado leído sigue en
  pantalla para volver a intentarlo.
- Sin movimientos, no hay tarjeta.
- **El muelle:** `textoDelListadoActualizado` («7 filas», «1 fila»); `AvisoDelListado` con un
  `syncStatusProvider` falso: sin llegada no avisa; con `listArrival(2, 7)` muestra «Listado
  actualizado por la oficina: 7 filas.» y `operationSourcesRevisionProvider` pasa a 1; la misma
  llegada en el siguiente estado no repite ni vuelve a derivar; otra revisión, otro aviso.

### 5.4 Las reglas en el emulador (`tool/t127_reglas_revision.mjs`, nuevo)

Solo con un proyecto `demo-` y en el puerto 8282, para no chocar con el de la Expo (8181 y 4000):

```powershell
powershell -File tool/t113_emulador.ps1 -Proyecto demo-t127 -Puerto 8282
node tool/t80_reglas.mjs 8282 demo-t127 docs/T127-firestore.rules.propuesta
node tool/t113_reglas_abuso.mjs 8282 demo-t127 docs/T127-firestore.rules.propuesta
node tool/t127_reglas_revision.mjs 8282 demo-t127
node tool/t80_reglas.mjs 8282 demo-t127
node tool/t113_reglas_abuso.mjs 8282 demo-t127
node tool/t127_reglas_revision.mjs 8282 demo-t127 docs/T80-firestore.rules.propuesta
```

`tool/t127_baterias.ps1` (nuevo) hace las siete líneas de una vez: levanta el emulador con
`tool/t113_emulador.ps1`, espera el puerto, corre las seis baterías con un registro cada una en
`build/t127/` y cierra el emulador por su árbol de procesos y por lo que siga escuchando en el
puerto. `tool/t80_reglas.mjs` y `tool/t113_reglas_abuso.mjs` aceptan ahora un tercer argumento con
el archivo de reglas; sin él siguen cargando el de T-80, como siempre. Lo esperado: las 69 y los 25
dan lo de siempre contra las dos propuestas; los casos nuevos (31: 30 casos y una comprobación de
lectura) dan lo esperado contra la de T-127 y, contra la de T-80, fallan los que esperan
«permitido» (la prueba roja de las reglas). Los casos nuevos:

- una revisión del muelle no; la oficina agrega el listado a una operación publicada sin listado
  (revisión 1) y lo reemplaza (revisión 2), y los trozos de la 1 quedan;
- una revisión que no sube no pasa (la misma, una menor, la 0; sin listado antes, empezar en 2);
- un trozo con otra revisión que la del manifiesto (en el campo o en el id), un trozo de revisión
  sin su manifiesto, con otra huella o con otro número de partes, no;
- la revisión no cambia el plan de carga ni agrega un plano de llegada ni toca otro campo; la
  entrada sin `length`, con un campo de más o con la revisión como texto, no;
- sobre un listado publicado con la operación sin revisión, la 0 no y la 1 sí;
- el muelle lee los trozos de todas las revisiones (quedan `export_list-r1-0`, `export_list-r2-0` y
  `loading_baplie-0`); sigue registrando movimientos; un trozo anterior no se actualiza ni se borra;
- la oficina cierra la operación revisada; cerrada, no hay revisión ni trozo nuevo;
- publicar una operación nueva con su listado, sin revisión, sigue igual; un trozo de revisión con
  un manifiesto sin revisión, no.

**Resultado (29-oct, con la luz verde de la laptop, una sola corrida del lanzador):**

| Batería | Contra T-127 | Contra T-80 | Registros en `build/t127/` |
|---|---|---|---|
| T-80, `tool/t80_reglas.mjs` | **69 de 69**, 16 documentos en `movements` | **69 de 69**, 16 documentos | `reglas-t80-contra-t127.log`, `reglas-t80-contra-t80.log` |
| T-113, `tool/t113_reglas_abuso.mjs` | **25 de 25** | **25 de 25** | `reglas-t113-contra-t127.log`, `reglas-t113-contra-t80.log` |
| T-127, `tool/t127_reglas_revision.mjs` | **31 de 31** | **27 de 31**: caen «la oficina agrega el listado… revisión 1», «la oficina reemplaza el listado: revisión 2», «sobre un listado publicado con la operación, la revisión 1 pasa» (403 las tres) y la lectura, que solo encuentra `loading_baplie-0` | `reglas-t127-contra-t127.log`, `reglas-t127-contra-t80.log` |

Ninguna denegación agotó las 1 000 expresiones. Los 27 que sí pasan contra T-80 son los que
esperan «denegado» (que T-80 también deniega, por otra regla), los movimientos, el cierre, la
publicación con listado y la lectura de la subcolección; lo que T-127 **habilita** es exactamente lo
que T-80 niega. El emulador arrancó solo con Firestore en `127.0.0.1:8282` (su concentrador
tomó el 4400 por omisión, así que el lanzador no debe correr a la vez que el emulador de la Expo),
y al terminar quedó cerrado: el puerto 8282 libre y ningún proceso del emulador vivo. El resumen
del lanzador está en `baterias-resumen.json`; la consola del emulador, en `emulador-salida.log`.

### 5.5 Resultados

| Qué | Resultado | Registro |
|---|---|---|
| Pruebas nuevas (motor 6, unirse 4, oficina 3, cruce 1, pantallas 5) | **19 de 19** | `04-pruebas-nuevas-verde.log` |
| Las mismas contra `cf7cf3f` | **no compilan** los dos archivos (136 + 38 errores, y 28 en la nube falsa) | `05-rojo-contra-cf7cf3f.log` |
| Suite completa, una corrida (piso 1852, sin omitidas) | **1871 de 1871** («All tests passed!», sin fallas ni omitidas): el piso más las 19 nuevas; `pubspec.lock` sin cambios | `06-suite-completa.log` |
| `flutter analyze lib test integration_test` | **No issues found**, antes de las pruebas y al final | `01-analyze-primero.log`, `07-analyze-final.log` |
| T-80 (69) y T-113 (25) contra T-127 y contra T-80 | **69 de 69 y 25 de 25** contra cada una, sin cambiar lo que esperan | `reglas-t80-contra-*.log`, `reglas-t113-contra-*.log` |
| T-127 (31) contra T-127 y contra T-80 | **31 de 31** contra T-127; contra T-80, 27 de 31: caen los cuatro que la revisión permite | `reglas-t127-contra-*.log` |

## 6. Lo que no entra

Cambiar los BAPLIE de una operación publicada, borrar trozos, T-120, el gesto del touchpad
(O-040-1), la versión (`pubspec.*` no cambia; la candidata va aparte) y publicar cualquier cosa.
Ninguna dependencia nueva; `lib/main.dart` y las opciones de Firebase no se tocan.

## 7. Para Carlos: publicar las reglas nuevas y cotejarlas

### 7.1 Publicar desde la consola (nunca `firebase deploy`)

1. Antes de la publicación, Codex acepta T-127 y la 0.4.1 está lista para compilar. Las reglas van
   **antes** que los clientes.
2. En Chrome, `https://console.firebase.google.com` → proyecto **baystream-app** → **Firestore
   Database** → pestaña **Reglas**.
3. **Respaldo de lo publicado:** en el editor de reglas, seleccionar todo (Ctrl + A), copiar y
   pegar en un archivo nuevo `build\t127\reglas-antes.txt` (VS Code, «Guardar como», UTF-8). En
   una consola, desde la carpeta del rediseño:
   `node tool/t113_reglas.mjs build/t127/reglas-antes.txt build/t127` → tiene que decir
   `"equal": true` con `7E57F227…`: lo publicado sigue siendo T-80, como en 10.108.
4. Abrir `docs\T127-firestore.rules.propuesta` en VS Code, seleccionar todo, copiar.
5. En el editor de reglas de la consola, seleccionar todo y pegar encima. El editor valida la
   sintaxis mientras se escribe: no debe quedar ninguna marca roja. La primera línea sigue siendo
   `rules_version = '2';`.
6. **Publicar.** La consola anota la hora; las reglas nuevas rigen en menos de un minuto.
7. No hace falta tocar índices: la consulta nueva (`where('revision', isEqualTo: n)` en
   `sources/`) usa el índice de un solo campo que Firestore crea solo.

### 7.2 Cotejar que lo publicado es idéntico al archivo (como en 10.108)

1. En la misma pestaña, después de publicar: seleccionar todo el texto del editor de reglas, copiar
   y guardarlo en `build\t127\reglas-publicadas.txt` (UTF-8).
2. `node tool/t113_reglas.mjs build/t127/reglas-publicadas.txt build/t127 docs/T127-firestore.rules.propuesta`
   (el tercer argumento es nuevo: coteja contra la propuesta de T-127; sin él, contra la de T-80).
3. Tiene que decir `"equal": true` y salir con 0, con la huella normalizada
   **`FC17842C227120C8F5AF6AAF732E306290A4071B0383E2BA14455E2F13E566DB`** (390 líneas, 18 207 bytes
   en LF; la huella cruda del archivo en el árbol es la misma porque está en LF). Si no coincide, el
   script lista las líneas distintas: se corrige en la consola y se vuelve a cotejar. El resultado
   queda en `build\t127\reglas-cotejo.json`.
4. Si el texto llega pegado en el chat en vez de por archivo, se guarda tal cual y se coteja igual,
   como en T-113 (1.1).

### 7.3 Volver atrás

Si algo falla con las reglas nuevas, se pega `build\t127\reglas-antes.txt` (T-80) en la consola y
se publica: la 0.4.1 vuelve a decir «La nube no aceptó el listado…» al revisar y no cambia nada
local; todo lo demás sigue igual.

## 8. Para Carlos: la prueba de punta a punta (laptop y Honor)

Después de publicar las reglas (7) y los tres clientes de la 0.4.1. **Datos sintéticos, nunca el
corpus:** los de T-100 (`T100_CARGA.edi` y `T100_LISTADO.xlsx`, BUQUE MANUAL, viaje M100, escala
GTSTC, 30 OR en dos agencias), que se generan con `dart tool/t100_sintetico.dart <salida en %TEMP%>`
y `python -I tool/t100_listado.py <esa salida>`. Antes de empezar, una copia del Excel con el
**OR 1 borrado** (abrir en Excel, eliminar su fila, «Guardar como» `T100_LISTADO_v2.xlsx`): será la
revisión 2. Es una operación de prueba que se cierra al terminar; nada del piloto. Las cuentas: la
de oficina en la laptop (Windows o la Web) y la de muelle en el Honor, las dos autorizadas.

| Paso | Dónde | Qué hacer | Lo que se tiene que ver |
|---|---|---|---|
| 1 | Laptop (oficina) | Abrir `T100_CARGA.edi`, confirmar el perfil y la escala GTSTC, **sin importar el listado**; «Nube y cuenta» → «Publicar operación» | «Publicada» y, en la cabecera, «Al día» |
| 2 | Honor (muelle) | «Nube y cuenta» → «Unirse» → «Abrir plan de carga» | El plano, sin OR en las celdas; «OR / últimos dígitos» no ofrece OR |
| 3 | Honor | Cargar el lleno del OR 1 por sus últimos dígitos (H4), en su celda del plan. Anotar su número | «Cargado»; la celda en verde; «Al día» |
| 4 | Laptop | «Listado de la agencia» → elegir `T100_LISTADO.xlsx` | La tarjeta «Lo ya operado con el listado nuevo»: «0 contenedores ya cargados no están en el listado nuevo» y «0 vacíos asignados cambian de grupo» (el OR 1 sí viene). «Confirmar e importar» → «Listado guardado en la operación publicada de GTSTC: 30 filas, revisión 1. El muelle lo recibe solo.» |
| 5 | Honor, con red | Esperar unos segundos, sin tocar nada | El aviso «Listado actualizado por la oficina: 30 filas.»; los OR aparecen en las celdas; la carga del paso 3 sigue en su celda y ahora muestra su OR; «OR / últimos dígitos» ofrece los OR |
| 6 | Honor | Asignar un vacío a una celda reservada (un OR vacío del listado) | «Cargado», con su OR |
| 7 | Honor | **Modo avión con el Wi-Fi apagado** (10.39; comprobar con un ping que falla) | «Sin conexión» |
| 8 | Laptop | «Listado de la agencia» → «Importar otro listado» → `T100_LISTADO_v2.xlsx` | La tarjeta: «1 contenedor ya cargado no está en el listado nuevo» (el del paso 3), con su número desplegable; «0 vacíos asignados cambian de grupo». Confirmar → «…29 filas, revisión 2…» |
| 9 | Honor, sin red | Cargar otro lleno por sus dígitos | «Cargado»; el chip dice «Sin conexión · 1 por enviar»; **sin** aviso de listado: sigue con el de 30 filas |
| 10 | Honor | Quitar el modo avión | «Al día»; el aviso «Listado actualizado por la oficina: 29 filas.»; el lleno del paso 3 sigue cargado en su celda, ahora sin OR (su fila ya no está); el del paso 9 y el vacío del paso 6 siguen con los suyos |
| 11 | Laptop | Mirar el plano y «En vivo» | Los tres movimientos del Honor, con sus celdas; el avance los cuenta |
| 12 | Laptop | «BAPLIE de salida» | El lleno sin fila sale con los datos del plan (8bis); los demás, con el listado |
| 13 | Laptop | «Nube y cuenta» → «Cerrar operación». Después, «Listado de la agencia» → «Importar otro listado» → cualquiera | «La operación de esta escala ya está cerrada y su listado no cambia…»: nada sube |
| 14 | Consola de Firebase | `operations/{id}`: `sources.export_list.revision` = 2; en `sources/`: `loading_baplie-0`, `export_list-r1-0` y `export_list-r2-0` | Los trozos viejos siguen; ninguno se borró |

Si en el paso 5 el aviso no llega en medio minuto: abrir «Nube y cuenta» y «Reintentar», o cerrar
y abrir el plano; en el informe de la prueba se anota. La operación cerrada se queda en la nube
con el viaje M100: no es del piloto.

## 9. Archivos tocados

**Nuevos**

- `docs/T127-firestore.rules.propuesta` — las reglas de T-80 más las dos cláusulas (3.1).
- `lib/features/vessel/data/repositories/source_revisions.dart` — huella, trozos, manifiesto,
  revisión; `packSource` y `assembleSource` (3.2).
- `lib/features/vessel/presentation/widgets/aviso_del_listado.dart` — el aviso del muelle (3.5).
- `test/t127_listado_revision_test.dart` — el motor, unirse, la oficina y el cruce (5.1, 5.2).
- `test/t127_listado_pantallas_test.dart` — la oficina y el muelle en pantalla (5.3).
- `tool/t127_reglas_revision.mjs` — los casos nuevos de las reglas (5.4).
- `tool/t127_baterias.ps1` — las seis baterías en el emulador, de una vez (5.4).
- `docs/T127-RESULTADOS.md` — este informe.

**Modificados**

- `lib/features/vessel/domain/entities/operation.dart` — `OperationSource.revision`,
  `withRevision`, `Operation.exportListRevision`.
- `lib/features/vessel/domain/repositories/operation_sync_repository.dart` — `ListArrival`,
  `SyncStatus.listArrival`, `replaceSource`.
- `lib/features/vessel/domain/services/operation_sources.dart` — `save` con `sync`.
- `lib/features/vessel/domain/services/export_list_cross_checker.dart` —
  `ExportListRevisionImpact`, `revisionImpact`.
- `lib/features/vessel/data/repositories/sync_engine.dart` — el puerto y el motor (3.5).
- `lib/features/vessel/data/repositories/firestore_operation_sync.dart` — `publish` y `join` por
  `source_revisions.dart`, `replaceSource`, `watchList`, `listParts`.
- `lib/features/vessel/data/repositories/local_only_operation_sync.dart` — `replaceSource` sin nube.
- `lib/features/vessel/presentation/providers/export_list_providers.dart` — el impacto, la
  revisión al confirmar, el mensaje.
- `lib/features/vessel/presentation/pages/export_list_import_page.dart` — la tarjeta «Lo ya operado
  con el listado nuevo».
- `lib/features/vessel/presentation/pages/vessel_overview_page.dart` — `AvisoDelListado` en la
  página del viaje (una línea y su importación).
- `test/support/t79_fake_cloud.dart` — el manifiesto y los trozos por revisión en la nube falsa.
- `tool/t80_reglas.mjs`, `tool/t113_reglas_abuso.mjs`, `tool/t113_reglas.mjs` — un tercer argumento
  opcional con el archivo de reglas; por omisión, el de T-80.

No cambian `pubspec.yaml` ni `pubspec.lock`, ni `lib/main.dart`, ni las opciones de Firebase, ni
`docs/T80-firestore.rules.propuesta`, ni los archivos congelados.

## 10. Bloque de Git para Carlos

(Todas las validaciones de la sección 5 están hechas.)

```powershell
Set-Location -LiteralPath C:\Proyectos\baystream-rediseno
git add -- docs/T127-firestore.rules.propuesta
git add -- lib/features/vessel/data/repositories/source_revisions.dart
git add -- lib/features/vessel/data/repositories/sync_engine.dart
git add -- lib/features/vessel/data/repositories/firestore_operation_sync.dart
git add -- lib/features/vessel/data/repositories/local_only_operation_sync.dart
git add -- lib/features/vessel/domain/entities/operation.dart
git add -- lib/features/vessel/domain/repositories/operation_sync_repository.dart
git add -- lib/features/vessel/domain/services/operation_sources.dart
git add -- lib/features/vessel/domain/services/export_list_cross_checker.dart
git add -- lib/features/vessel/presentation/providers/export_list_providers.dart
git add -- lib/features/vessel/presentation/pages/export_list_import_page.dart
git add -- lib/features/vessel/presentation/pages/vessel_overview_page.dart
git add -- lib/features/vessel/presentation/widgets/aviso_del_listado.dart
git add -- test/support/t79_fake_cloud.dart
git add -- test/t127_listado_revision_test.dart
git add -- test/t127_listado_pantallas_test.dart
git add -- tool/t127_reglas_revision.mjs
git add -- tool/t127_baterias.ps1
git add -- tool/t80_reglas.mjs
git add -- tool/t113_reglas_abuso.mjs
git add -- tool/t113_reglas.mjs
git add -- docs/T127-RESULTADOS.md
git commit -m "Sprint 4: T-127, el listado en una operacion publicada (10.78): la oficina lo agrega o lo reemplaza con revision, el muelle lo recibe solo y avisa, join toma la ultima revision, las reglas de T-127 y sus baterias" --trailer "Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
git push origin sprint-4
git log --oneline -1
```

## 11. Tres líneas

- La oficina agrega o reemplaza el listado de una operación publicada y abierta: sube con revisión
  en un lote, los BAPLIE no cambian, y el cruce dice antes cuántos cargados se quedan sin fila y
  cuántos vacíos cambian de grupo.
- El muelle lo recibe solo y avisa «Listado actualizado por la oficina: n filas»; sin red sigue con
  el anterior; los movimientos no se tocan y el estado se vuelve a derivar; `join` toma la última
  revisión y un cliente 0.4.0 no puede dañar nada.
- 19 pruebas nuevas en verde (y rojas contra `cf7cf3f`: no compilan), la suite en 1871 de 1871,
  `analyze` en cero, y en el emulador 69 de 69, 25 de 25 y 31 de 31 contra las reglas nuevas
  (`docs/T127-firestore.rules.propuesta`); contra las de T-80 caen solo los cuatro casos de
  revisión, como debe ser.

## 12. Mensaje para Yov

> T-127 escrita sin luz verde (10.78): el listado con revisión en una operación publicada, con el
> diseño de 8.3 tal cual. Reglas en `docs/T127-firestore.rules.propuesta` (T-80 más las dos
> cláusulas; `diff` limpio), `source_revisions.dart` para armar y comprobar trozos por revisión,
> `replaceSource` en el contrato y en Firestore (lote: trozos `export_list-r{n}-{i}` + manifiesto),
> el motor escucha el manifiesto y baja solo la revisión nueva (sin red, se queda con la anterior),
> `join` arma la última revisión, la oficina avisa en el cruce con números y el muelle con
> «Listado actualizado por la oficina: n filas». Compatibilidad 0.4.0 en la sección 4: no daña
> nada; si no puede unirse, falla con `source_mismatch`. Con la luz verde de Flutter: 19 pruebas
> nuevas (motor con la nube falsa, unirse, oficina, cruce, pantallas) en verde, y contra `cf7cf3f`
> no compilan (es el contrato nuevo); la suite 1871 de 1871 en una corrida (piso 1852 + 19);
> `analyze` en cero antes y después. En el emulador (8282, `demo-t127`, sin internet, con
> `tool/t127_baterias.ps1` que lo levanta, corre las seis baterías y lo cierra): 69 de 69, 25 de
> 25 y 31 de 31 contra T-127; contra T-80, 69, 25 y 27 de 31, con los cuatro que caen donde deben
> (las revisiones permitidas y la lectura de sus trozos). Para Carlos: cómo publicar y cotejar las
> reglas (7, huella `FC17842C…`) y la prueba de punta a punta con los sintéticos de T-100 (8).
