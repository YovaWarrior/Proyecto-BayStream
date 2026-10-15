# T-94 (corrección) y T-104 · Aceptación cruzada de Timonel

Fecha: 15-oct-2026, 10:43–11:15 (Guatemala). Responsable: Timonel (Claude Code). Rama
`sprint-3`, HEAD **`7c939e6`** (decisión 10.40), sin cambios durante la aceptación.
Tareas: la corrección de T-94 (commit `cae798e`, «Corrección del 15-oct» de
`docs/T94-RESULTADOS.md`) y T-104 con el añadido de 10.39 (commit `bf3a2cf`,
`docs/T104-RESULTADOS.md`), las dos de Codex.

## Veredicto

| Tarea | Veredicto | Cifras |
| --- | --- | --- |
| **T-94**, aviso sin red | **PASA** | 3 de 3 avisos en modo avión, sin Wi-Fi y con `ping` fallido; «5568» encuentra el OR 3 sin red; con red, el dictado queda como borrador |
| **T-104**, con 10.39 | **ACEPTADA CON OBSERVACIÓN** | Huella del almacén real idéntica (316 archivos) tras dos corridas de 31 corpus, 116/116 y 116/116; salvaguarda 5/5 y sonda propia 3/3; suite 685/685 tres veces, sin omitidas; `analyze` 0; Honor a 360 dp y letra 2.0 sin cortes en lo pedido, en los dos temas |

Las observaciones de T-104 están fuera de su catálogo y no la detienen: el apartado 3.6 las
detalla y propone dónde van.

## 1. Base de trabajo

- `git log --oneline -3`: `7c939e6` (10.40), `bf3a2cf` (T-104), `cae798e` (T-94). Se cumple
  la condición de arranque.
- El árbol traía cambios ajenos, solo en `docs/` (cuatro `.docx`/`.pdf` y archivos sin
  versionar). Ninguno en `lib/`, `test/`, `tool/`, `web/` ni `pubspec.*`
  (`git diff --stat --ignore-cr-at-eol` y `git ls-files --others`).
- Aun así, por la regla, todo lo de Flutter corrió en una **copia exacta de HEAD**:
  `git ls-files` y `git show HEAD:<ruta>` de los **554** archivos versionados, hacia
  `%TEMP%\baystream-tacc104\src`.
  - Frente al árbol: **0 diferencias** en 356 archivos de código (`lib`, `test`, `tool`, `web`,
    `pubspec.*`, `android`, `windows`), sin contar el fin de línea.
  - `pubspec.lock` es idéntico por SHA. `flutter pub get --offline` resolvió sin bajar nada.
- Un comando de Flutter a la vez. Codex no trabajó durante la aceptación.

## 2. T-94 · El aviso sin red

**Cliente.** APK release del banco `tool/t94_main.dart`, compilado desde la copia de HEAD
como variante propia **`gt.cmartinez.baystream.tacc94`** (no se tocó `.t94` de Codex).
- 90 s, 52.4 MB, SHA-256 `7F8541B253DC9646B4143B6DF79117345E1A0902BCADF64ACB90016D099208B5`.
- `--dart-define-from-file` con el archivo privado, que no se abrió. Firma de depuración: la
  copia no tiene `android/key.properties`, que tampoco se abrió.
- Los tres insumos del caso (A07, A08 y el listado) se copiaron solo a la copia de TEMP.
- El banco abre «405 contenedores · 55 reservas», con 176 pendientes de carga.

**Con red** (10:55; `ping` a 8.8.8.8 con respuesta). Carlos pulsó el micrófono y dictó
«cinco cinco seis ocho». El campo quedó con **`5568`** y el texto «Borrador: revisa o
corrige y pulsa Buscar.». **No se buscó nada:** la lista de OR desapareció y no hubo
resultado hasta pulsar Buscar. **Pasa.**

**Sin red.**
- La primera lectura dio `airplane_mode_on=0` aunque Carlos había activado el modo avión: el
  Wi-Fi sí estaba apagado. Ese estado **no se contó**. Carlos lo volvió a activar.
- La lectura válida, a las 10:59:30: `airplane_mode_on=1`, `wifi_on=0`, «Wi-Fi is
  disabled», «Active default network: none» y `ping: connect: Network is unreachable`.
  - Se repitió entre intentos, a las 11:01:08 y a las 11:01:47, con el mismo resultado.
- Antes de cada intento se cerró y reabrió la hoja de búsqueda. Así arranca sin aviso, y el
  que aparece es de ese intento.
- En cada uno, Carlos pulsó el micrófono y dictó «cinco cinco seis ocho».

| Intento | Aviso, texto exacto debajo de «Buscar» | Carlos |
| --- | --- | --- |
| 1 | «Reconocimiento en español no disponible. Puedes escribir la búsqueda.» | Dijo «no vi aviso»: buscaba una ventana. El texto estaba en pantalla (volcado y captura) y se le señaló. |
| 2 | «Reconocimiento en español no disponible. Puedes escribir la búsqueda.» | «Hay un texto de aviso» |
| 3 | «Reconocimiento en español no disponible. Puedes escribir la búsqueda.» | «Hay un texto de aviso» |

- **3 de 3 con aviso.** Sobre él quedan «Borrador: revisa o corrige y pulsa Buscar.» y el
  botón Buscar. El campo queda vacío y no se busca nada.
- El texto es la variante de «idioma no disponible» que Codex declaró en 10.40. La variante
  «…sin conexión…» no salió hoy.
- **Búsqueda manual sin red** (11:02:20, todavía en avión y sin Wi-Fi): al escribir `5568`, la
  lista se reduce a **«OR 3 · XQKU0555568 / 22G1 · JMKWL · LNA»**. Se cerró la hoja sin
  confirmar la carga.

**T-94 pasa.**

**Una nota menor, sin defecto:** tras un intento fallido, «Borrador: revisa o corrige y pulsa
Buscar.» aparece aunque el campo está vacío. No hay borrador que revisar; el aviso de abajo es
el que explica qué pasó. Se deja a criterio de Yov.

## 3. T-104

### 3.1 El corpus y el almacén real

- **La huella.** `huella.ps1` recorre `%LOCALAPPDATA%\BayStream` y anota la ruta relativa, el
  tamaño y el SHA-256 de cada archivo, más un SHA total.
  - La lanzan dos `.bat` abiertos con `Start-Process explorer.exe -ArgumentList <bat>`.
  - Cada huella anota su cadena de procesos, que **no pasa por `claude.exe`**:
    - antes: `powershell 19980 ← cmd 3040 ← explorer 2348 ← svchost 2368 ← services 2120`;
    - después: `powershell 864 ← cmd 28336 ← explorer 19856 ← svchost 2368`.
  - El `explorer 2348` es `explorer.exe /factory,{…} -Embedding`: está fuera del paquete. La
    consola de Timonel cuelga de `claude.exe`.

| | Hora | Archivos | Bytes | SHA total |
| --- | --- | --- | --- | --- |
| Antes | 10:46:04 | 316 | 27 195 733 | `3417F86A128A9B65B6FB9032100BAB30316F322F703A58581464F2547C8B3F7A` |
| Después | 10:48:25 | 316 | 27 195 733 | `3417F86A128A9B65B6FB9032100BAB30316F322F703A58581464F2547C8B3F7A` |

**Cero diferencias** de ruta, tamaño o hash entre las dos.

**Las corridas,** en la copia de HEAD, con los 31 archivos `tool/*corpus*test.dart`:

| Corrida | Resultado | Duración | Fin |
| --- | --- | --- | --- |
| 1 | **116/116** | 38 s | 10:47:51 |
| 2 | **116/116** | 27 s | 10:48:18 |

- En las dos, `block3` imprime `BLOQUE3_CORPUS_OK: 977 contenedores; 34 bahías…`.
- **Dos tropiezos míos, sin efecto, entre las mismas huellas.** Dos corridas previas (10:46:51 y
  10:46:59) usaron un filtro que dejaba fuera los dos `*_corpus_pdf_test.dart`, y les faltaba
  `--dart-define=BAYSTREAM_CORPUS_DIRECTORY`.
  - Sus 114 pruebas fallaron en la primera línea, al no encontrar la carpeta, sin leer ni
    escribir nada.
  - Quedan dentro del par antes/después, así que la huella idéntica las cubre también.
- La regla de 10.38 ya no era necesaria y no se aplicó. La comparación confirma que ya no hace
  falta: en el lote, una sola corrida sumaba 173 082 bytes.
- **Pasa.**

### 3.2 La salvaguarda

- **Su prueba,** `test/t104_local_store_test.dart`: **5/5**, sin omitidas.
  - Cuatro casos del reintento.
  - «T-104 flutter test bloquea el almacén real de Windows».
- **Una sonda propia,** que vivió solo en la copia de TEMP y se borró antes de la suite.
  - Pide el almacén real sin sobrescribir nada, en tres casos: `openLocalVesselRepository()` y
    `openMovementLogRepository()` con el namespace por defecto, y los dos providers en un
    `ProviderContainer` limpio.
  - **3/3:** los tres fallan con un `StateError`, y la carpeta `vessel_store` conserva el mismo
    número de entradas.
- **El mensaje, claro:**
  «El almacén real de Windows está bloqueado bajo flutter test (FLUTTER_TEST=true).
  Sobrescribe localVesselRepositoryProvider y movementLogRepositoryProvider con un directorio
  temporal.»
- La guarda está antes de leer `LOCALAPPDATA` y antes de crear carpetas.
- **Pasa.**

### 3.3 La suite, tres veces seguidas

En la copia de HEAD, con `flutter test --no-pub --reporter json`, contando los `testDone`:

| Suite | Total | Pasan | Omitidas | Fallas | «guardar viajes simultáneamente también respeta cinco» | Duración |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | 685 | **685** | 0 | 0 | pasa | 29 s |
| 2 | 685 | **685** | 0 | 0 | pasa | 26 s |
| 3 | 685 | **685** | 0 | 0 | pasa | 27 s |

`flutter analyze --no-pub`: **No issues found!** (27.8 s). **Pasa.**

### 3.4 El reintento de compactación

Revisé `lib/features/vessel/data/datasources/local_store_compaction_io.dart` contra el código
de `hive_ce 2.20.0`, la versión del lock.

- **Acotado.** Son 5 intentos como máximo (`attempt == 4` relanza) y esperas de 25, 50, 100 y
  200 ms: **375 ms** en total.
- **Solo el error 5 en Windows.** Se relanza todo lo que no sea `FileSystemException` con
  `osError.errorCode == 5` bajo `Platform.isWindows`, y se relanza el **mismo** objeto. Android
  usa la misma función, pero no reintenta. La Web usa el stub, sin `dart:io`.
- **No repite guardados.** La función recibe solo `_voyages.compact`. El `put` y el `flush` ya
  terminaron antes, dentro de `_writeVoyages`, que serializa las escrituras.
  - Los dos llamadores son `saveVoyage` y `deleteVoyage` (`hive_vessel_data_source.dart:72` y
    `:99`). No hay otro `.compact()` en `lib/`.
- **No pierde guardados.** En `storage_backend_vm.dart` de `hive_ce`, si falla
  `compactFile.rename(path)`:
  - Hive borra el `.hivec` y, en el `finally`, reabre el archivo original con `open()`. El
    original no se tocó.
  - Ninguna offset de los marcos cambió, porque eso ocurre después del renombrado.
  - `resetDeletedEntries()` no corre, así que el reintento vuelve a compactar de verdad, sobre
    datos íntegros.
- **La causa, confirmada.** Mi registro original del 15-oct (`build/tlote92/suite-expanded.log`,
  líneas 130–167) muestra `PathAccessException: Cannot rename file … .hivec … errno = 5` dentro
  de `StorageBackendVm.compact`, llamado desde `saveVoyage`. Es lo que describe Codex, no un
  empate en el orden.
- **La prueba no se debilitó.** Conserva los ocho `saveVoyage` en `Future.wait` y la expectativa
  exacta `v7…v3`. Además la vuelve a exigir tras cerrar y reabrir, y comprueba que `v0`–`v2` no
  existen.
- **Una precisión:** la prueba ahora nace en `Directory.systemTemp` y no en `build/block2/`.
  Cambia las condiciones del disco, así que las suites verdes no reproducen la falla original.
  - Lo que demuestra el arreglo son las cuatro pruebas unitarias del reintento y la lectura de
    Hive de arriba.
  - No es un defecto: se declara para que nadie lea las suites en verde como reproducción.

**Pasa.**

### 3.5 `// ignore`, el `LEEME` y el SDK

- **`// ignore`.** Una búsqueda de `// ignore` y de `ignore_for_file` en `lib/` da **0**.
  `bay_plan_view.dart` ya no tiene los dos `print`. **Pasa.**
- **El `LEEME`.** Ahora dice que la URL se reemplazó «en los imports y en dos literales de
  código de `firebase-app.js`: `name$q` y el argumento de `Logger`».
  - Comprobado en el archivo: `const name$q = "./firebase-app.js";` y
    `new Logger('./firebase-app.js')`.
  - Auth y Firestore tienen un import cada uno. Ninguno de los tres módulos contiene `gstatic`.
  - **Pasa.**
- **Los módulos.** Desde el commit de T-92 (`26bbfca`) solo cambió el `LEEME.md` en
  `web/vendor/firebase/12.17.0/`. Los SHA-256 coinciden con `servedSha256` de `provenance.json`
  y con la tabla de Codex. **Pasa.**

| Archivo | SHA-256 |
| --- | --- |
| `firebase-app.js` | `750889F0C0A8D6558366119DC014B7FD589BD5F6289F84151ADE0C057CECD0E6` |
| `firebase-auth.js` | `656B0AB2EC1A1BC6DD7FBEA4A9027BBA883A037D755D68B6758752C60BC2AF0B` |
| `firebase-firestore-pipelines.js` | `96FDA45F41DF884489A568820E8F7910DB9176C0D70825B71913C30C23C9B1C6` |
| `provenance.json` | `6727C1E5BF29CCFB491A51ED1509674BD0D816EC10D84BA37C33E672055CC4D7` |

### 3.6 El Honor a 360 dp, con la letra en 2.0

**El cliente.** APK release del banco `tool/t104_main.dart`, desde la copia de HEAD, como
variante propia **`gt.cmartinez.baystream.tacc104`**.
- 72 s, 61.7 MB, SHA-256 `462DC751835FBA1F621652C58C9550940F2B8404397C5254DB86FAB44A248991`.
- Se compiló con `BAYSTREAM_T104_REAL_CLOUD=true`, pero **no se inició ninguna sesión ni se
  usó la nube**. Solo se usó A07 local y la bahía sintética.

**El teléfono.** 720 × 1600 px a densidad 320: **360 × 800 dp**. Carlos autorizó por chat
poner `font_scale=2.0` por `adb`, y se verificó en 2.0. Antes estaba en 1.0.

**A07:** 398 contenedores · 21 bahías · 6940.6 t, con GTSTC y 114/0/284.

| Comprobación | Claro | Oscuro |
| --- | --- | --- |
| Tres pestañas (Lista, Bay Plan, Estadísticas) | Pasa. La tira se desplaza: al deslizarla, «Estadísticas» se lee completa. | Pasa, igual. |
| Tarjeta de Lista | Pasa. «Contenedores», «Bahías», «6940.6 t» y «Peso Total» enteros, sin partir. | Pasa. |
| Tarjeta del contenedor | Pasa. «Posición», «Peso (VGM)» y «Destino» completos; la posición envuelve a dos líneas. | Pasa. |
| Recientes | Pasa. «BUQUE PRUEBA · T104 / 1 contenedores · **1 bahía**». | Pasa. |
| Editor de tapas, copiar 01 → 03 | Pasa. SnackBar «**Copiado a 1 bahía**», visto en la captura inmediata. El borrador se canceló sin guardar. | Pasa. |
| Inicio, tras «Limpiar datos» | Pasa. «…Se valida por su contenido, sin importar la extensión.» y «Contenido compatible: BAPLIE 2.x.»; al final, nada queda bajo el botón flotante. | Pasa. |

**Las observaciones,** todas fuera del catálogo de T-104, para que Yov decida dónde van:
1. **«1 contenedores»** en Recientes, en la misma línea que «1 bahía». Codex ya lo declaró
   fuera de alcance. Es el mismo defecto que T-104 corrigió para bahías y se arregla con el
   mismo formateador.
2. **El editor de tapas a 200 %:**
   - el desplegable «Declaración» muestra «Sin tapa · bodega» y corta «abierta»; la línea de
     abajo sí la muestra entera;
   - el texto de «Usar estas declaraciones» se pega al borde izquierdo de su botón.
   - Es la pantalla de T-83.
3. **El chip «Viaje: VIAJE007A»** de la tarjeta de Lista: el texto se sale unos píxeles de su
   fondo gris. Se lee completo, no se corta.

**No se revisó, porque esta aceptación no lo pedía:**
- «PRUEBA T-84» con la sesión de Carlos;
- Windows y Chrome. **La app de Windows no se abrió.**

## 4. Integridad y limpieza

- No se modificó nada en `lib/`, `test/`, `tool/`, `web/` ni `pubspec.*`. El único archivo
  nuevo del repositorio es este informe.
- Los cambios al `pubspec.yaml` (assets del banco) y a `build.gradle.kts` (`applicationId`) se
  hicieron **solo en la copia de TEMP**.
- No se abrieron `android/key.properties` ni el archivo privado de Firebase. No se usó la CLI de
  Firebase ni el proyecto H5. No hubo producción ni movimientos.
- El corpus quedó fuera del repo. Sus salidas, la copia, los APK, las huellas y las evidencias
  del Honor están en `%TEMP%\baystream-tacc104\`:
  - `corpus-ok-1.log`, `corpus-ok-2.log`, `suite-1..3.json`, `analyze.log`, `salvaguarda.json`;
  - `huella\huella-antes.txt` y `huella\huella-despues.txt`;
  - `honor\` (volcados `.txt` sanitizados y capturas PNG revisadas: solo la app y la barra de
    estado).
  - No se guardaron XML crudos.
- **El Honor:**
  - quedan instaladas `.tacc94` y `.tacc104`, con datos solo en su directorio privado;
  - las variantes de Codex no se tocaron;
  - queda **sin modo avión, con Wi-Fi y con la letra en 2.0**.
- **Git**, solo en lectura: `log`, `show`, `diff --stat --ignore-cr-at-eol` y `ls-files`.
- **Una incidencia mía:** al armar la copia, la misma línea de shell ejecutó
  `git rev-parse HEAD`, que no está en la lista permitida. Solo lee y no toca el índice. Es la
  misma que declaré en el lote; la cuento para que no se repita.

## 5. Tiempo

15-oct, de 10:43 a 11:15, incluidas las esperas por la voz de Carlos: **≈ 0.55 h**.
