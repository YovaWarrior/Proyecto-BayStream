# T-113 · Las pruebas de seguridad del Sprint 3

Timonel · 21-oct-2026 · rama `sprint-3`, cabeza `2272e8a` (10.106) · producto de `sprint3-cierre-2` (`f631efa`).

**Estado: entregada con un punto pendiente de evidencia.** Cinco de las seis partes tienen su evidencia y su dictamen. La parte 1 tiene la batería, pero le falta el cotejo del SHA-256 contra las reglas publicadas, porque **el archivo `%TEMP%\t113\reglas-publicadas.txt` no está en la máquina** (sección 1.1). Cuando Carlos lo deje ahí, el cotejo es un solo comando y no cambia nada más del informe.

**Lo que no toqué:** `lib/`, `test/`, `pubspec.*`, Firebase de producción (ni consola, ni CLI contra el proyecto real, ni lecturas; la Web publicada tampoco se consultó). Solo usé el emulador local, con el proyecto `demo-t113`.

Después de `sprint3-cierre-2` no cambió ningún archivo de producto: `git log sprint3-cierre-2..HEAD -- lib pubspec.yaml pubspec.lock android/app/src web windows firestore.rules firebase.json` sale vacío. Todo lo que dice este informe vale para el cierre.

## Resumen

| Parte | Dictamen | Evidencia |
|---|---|---|
| 1 · Reglas de Firestore | **Batería 69/69 y abuso 25/25 en el emulador. El código pide lo mismo que permiten las reglas. El cotejo con las publicadas, pendiente: falta el archivo** | 1.1 a 1.4 |
| 2 · Dependencias | **Cero avisos vigentes** en 117 paquetes (OSV y GitHub Advisory) y en los SDK nativos de Firebase que tienen ecosistema | 2 |
| 3 · Secretos | **Ningún secreto nuevo.** La única clave real en la historia es la del proyecto temporal de H5, ya conocida (H-04) | 3 |
| 4 · Permisos | **Coherentes** en Android (APK limpio, contra T-88), en el MSIX y en la Web | 4 |
| 5 · Hallazgos abiertos | Los 7 de la línea base y los 3 del Incremento 2, con su estado; **13 hallazgos de este sprint**, ninguno crítico ni alto | 5 y 6 |
| 6 · RNF-004 | Se cita de T-98: **no medible** (10.101 y 10.105) | 7 |

## 1. Las reglas de Firestore

### 1.1 El cotejo con las reglas publicadas: pendiente

La ficha dice que Carlos dejó el texto de la consola en `%TEMP%\t113\reglas-publicadas.txt`. **No está.** Lo busqué:
- en `C:\Users\Giova\AppData\Local\Temp\t113\`, que no existía antes de esta tarea (ahora solo tiene mis carpetas `emu`, `apk-f631efa` y archivos de trabajo);
- con el nombre `*reglas-publicadas*`, en Temp, el Escritorio, Descargas, `C:\Proyectos` y las carpetas de paquetes de Claude y de Codex en `%LOCALAPPDATA%\Packages`.

No aparece en ninguna parte. Puede ser que se guardara en otra ruta o que la consola de Claude vea un %TEMP% distinto (AGENTS.md describe la virtualización de los agentes empaquetados), así que **no lo doy por inexistente: lo declaro no encontrado.**

**Lo que queda listo:** `tool/t113_reglas.mjs` compara el texto publicado con la propuesta y da tres huellas de cada uno: la cruda, la de finales LF y la normalizada (sin BOM, sin espacios al final de línea ni líneas vacías al final, que es lo que cambia al copiar desde un navegador). Si la normalizada no coincide, lista las líneas distintas. Lo probé:
- contra el blob versionado de `sprint3-cierre-2`: **iguales**, salida 0;
- contra una copia con una regla alterada (`allow delete: if true`): **distintos**, salida 1, con las líneas señaladas.

**Una precisión sobre la huella de referencia.** `21894B7F…` es la huella **cruda de la copia de trabajo**, que mezcla CRLF y LF (235 CRLF; `git ls-files --eol` da `i/lf w/mixed`). El blob versionado es LF y su huella es `7E57F227BADC118F823265B0CFE9FF0E9A067F39F5AD387C932AD901F894F125`. Las dos tienen la misma huella normalizada (`7E57F227…`). Un texto copiado de la consola casi seguro no tendrá la mezcla, así que **lo que se compara es la normalizada**, no la cruda.

### 1.2 Lo que pide el código del sprint

Revisé todas las escrituras y lecturas de Firestore de `lib/` contra `docs/T80-firestore.rules.propuesta`:

| Lo que hace el código | Archivo | Lo que exige la regla | Coincide |
|---|---|---|---|
| Lee su propio `authorized/{uid}` (escucha y `get` del servidor) | `firebase_session_repository.dart:110, 150`; `firestore_operation_sync.dart:407` | `get` solo del propio uid | Sí |
| Publica la operación y sus fuentes en un lote, con `createdAt` del servidor | `firestore_operation_sync.dart:84-120` | 10 campos exactos de la operación y 8 de cada fuente; `createdBy` = uid; `getAfter` ve la operación | Sí, los mismos campos |
| Cierra: `status`, `closedBy`, `closedAt` del servidor | `firestore_operation_sync.dart:266-275` | solo esos tres, abierta → cerrada | Sí |
| Escribe un movimiento con el sobre de T-79a y `receivedAt` del servidor | `firestore_operation_sync.dart:381, 474-497` | 11 campos exactos; `author.role` igual al de la lista | Sí |
| Los 9 tipos de `MovementType` | `movement.dart:13-26` | `officeTypes()` tiene los 9; `dockTypes()` 6 | Sí |
| Los campos de cada `payload` | `movement.dart:212-313` (los `MovementDraft`) | `hasOnly` de cada validador | Sí; el constructor quita los nulos (`movement.dart:207`), así que un opcional vacío no viaja como `null` |
| `voyages` y `latency_test` | solo `c3_reconciliation_screen.dart` y `latency_test_screen.dart` (H5, congelados) | cerradas en producción | Sí: ninguna pantalla del producto las usa |

El validador del cliente (`MovementDraft.validate`, `movement.dart:316-386`) replica las reglas. Una diferencia menor, sin efecto en la seguridad: el cliente no limita a 300 caracteres el motivo opcional de una descarga o una carga, y la regla sí; un motivo más largo lo rechazaría el servidor.

### 1.3 La batería de T-80, de nuevo en el emulador

- **Emulador:** Firestore 1.22.0 (el mismo JAR que T-79 y T-80), descargado por `firebase-tools` 15.32.1 al primer arranque; Java 21.0.8 de Android Studio; `127.0.0.1:8181`; proyecto **`demo-t113`**, que no existe en la nube. Con `-Duser.language=en`, como pide T-80 (sección 1).
- **El lanzador:** `tool/t113_emulador.ps1`, con su `firebase.json` en `%TEMP%\t113\emu`, no el de la raíz.
- **El comando:** `node tool/t80_reglas.mjs 8181 demo-t113`, sin cambiar el script de Codex.

**Resultado: 69 de 69, dos corridas**, y la subcolección con los 16 documentos esperados (el reenvío idéntico no duplica). Evidencia: `build/t113/reglas-bateria.log` y `reglas-bateria-2.log`.

### 1.4 Casos de abuso que la batería no cubría

La batería de T-80 prueba bien la forma de cada movimiento, pero no prueba la escalada de rol sobre la lista de autorizados ni el cambio directo de la oficina sin solicitud, que T-81 usa en el producto. `tool/t113_reglas_abuso.mjs` los agrega, contra las mismas reglas y en el mismo emulador:

| Grupo | Casos | Lo que prueba |
|---|---:|---|
| Escalada | 7 | el muelle no se cambia el rol, ni reescribe su registro; una cuenta fuera de la lista no se da de alta; la oficina no da de alta ni borra a nadie; nadie lista `authorized`; **un token con `role: office` y `admin: true` no sirve: el rol sale de la lista, no del token** |
| Operación | 6 | fuera de la lista no crea; la oficina no crea a nombre de otro, no edita el buque, no cuela otro campo al cerrar; el muelle no escribe fuentes; nadie borra una fuente |
| Movimiento | 10 | **T-81: la oficina cambia el plan sin solicitud (permitido)**; el muelle no; el muelle no anula un cambio de la oficina y la oficina sí anula uno del muelle; sin sesión no escribe; nada en una operación que no existe; motivo de 301 caracteres, no; tapa con un campo de más, no; la oficina no edita un movimiento ajeno |
| Cerrado | 2 | una colección inventada no se lee ni se escribe |

**Resultado: 25 de 25.** Con `T113_DETALLE=1`, cada denegación cae en la regla esperada (L76 `authorized`, L85 operaciones, L145 movimientos). Evidencia: `build/t113/reglas-abuso.log`.

**AVANCE del bloque 1:** batería y abuso en verde; el cotejo de la huella, pendiente del archivo.

## 2. Las dependencias

`tool/t113_dependencias.mjs` lee `pubspec.lock` y consulta, sin credenciales:
- **OSV** (`api.osv.dev`, ecosistema Pub), por versión exacta; OSV ya evalúa los rangos;
- **GitHub Advisory Database**: la lista completa de pub (**14 avisos revisados; 0 sin revisar**), cruzada por nombre y por rango.

Cada paquete se consulta además sin versión, para ver los avisos históricos. **Las dos fuentes respondieron.**

| Conjunto | Paquetes | Avisos vigentes |
|---|---:|---:|
| Directos (`direct main`) | 16 | 0 |
| De desarrollo (`direct dev`) | 4 | 0 |
| Transitivos | 97 | 0 |
| **Total del lock** (109 de pub.dev, 8 del SDK) | **117** | **0** |

- **`intl` 0.20.2** (transitivo, lo fija `flutter_localizations`): sin avisos.
- **`flutter_localizations`** y los otros 7 paquetes del SDK no viven en pub.dev: no tienen avisos en OSV ni en GitHub. Se declaran con su SDK: **Flutter 3.38.9 stable, Dart 3.10.8**.
- **Históricos, ya fuera de rango** (las mismas dos fuentes los reportan con el mismo id):
  - `archive` 4.0.9: GHSA-9v85-q87q-g4vg y GHSA-r285-q736-9v95 (altos), afectaban hasta 3.3.7;
  - `http` 1.6.0: GHSA-4rgh-jx4f-qfcq (medio), afectaba antes de 0.13.3.

**Los SDK nativos de Firebase** no están en el lock; los fijan los plugins:

| Componente | Versión | Avisos |
|---|---|---|
| Firebase JS de la Web (`web/vendor/firebase/12.17.0`, npm `firebase`) | 12.17.0 | ninguno en OSV |
| BoM de Firebase en Android (Maven `com.google.firebase:firebase-bom`) | 34.17.0 | ninguno en OSV |
| SDK de C++ en Windows (`firebase_cpp_sdk_windows`) | 13.9.0 | **sin cobertura**: OSV no tiene ese ecosistema |

**Dictamen: cumple.** H-07 sigue cerrado con 117 paquetes (el Incremento 2 contó 113 de pub.dev antes de T-43). Evidencia: `build/t113/dependencias.md` y `dependencias.json`.

**AVANCE del bloque 2:** cerrado.

## 3. Secretos en el árbol y en la historia

`tool/t113_secretos.py`, solo con lecturas de Git que no tocan el índice (`ls-files`, `rev-list --objects`, `cat-file`), recorre:

| Fuente | Qué | Cuántos |
|---|---|---:|
| Árbol | archivos versionados, como están en la copia de trabajo | 882 |
| Sin versionar | ni versionados ni ignorados (podrían entrar en el próximo commit) | 17 |
| Historia | cada blob alcanzable desde `sprint-3`, en 358 commits | 1 840 |

Las 358 confirmaciones de `sprint-3` son **toda la historia del repositorio**: `git rev-list --all --count` da 358. Los `.docx`, `.xlsx` y `.pptx` se abren y se revisa su XML (67 archivos); los binarios (370) solo se revisan por nombre y por huella.

**Lo que busca:** claves de Google (`AIza…`), claves privadas, cuentas de servicio, tokens de GitHub y de API, JWT literales, la firma de Android, contraseñas literales, correos, UID de Firebase, rutas de `baystream-privado`, los archivos que protege el `.gitignore` y el contenido del corpus. Para el corpus, toma las huellas de los 18 archivos de la carpeta anonimizada y sus **4 521 números de contenedor**, y marca un archivo si es idéntico a uno del corpus o si trae tres o más de esos contenedores.

**Lo que encontró**, en cuentas y rutas (los valores van solo a `%TEMP%\t113\revision-privada.json`, fuera del repo):

| Detector | Árbol | Historia | Revisado a mano |
|---|---|---|---|
| Clave de Google | 0 | **1 archivo, 2 apariciones**: `lib/main.dart`, de `cdc3830` (18-ago) a `ba7353a` (1-oct) | Las opciones del proyecto temporal de H5. **Es H-04**, ya conocido: T-47 lo declaró (sección 7) y el Incremento 2 también. Firebase dice que esas claves no son secretas; lo que protege los datos son las reglas. **No es un secreto nuevo**, y por eso no detuve la tarea |
| Id de app de Firebase | 0 | 1 archivo, `lib/main.dart` | El mismo bloque de H-04 |
| Claves privadas, cuentas de servicio, tokens, JWT, refresh tokens | 0 | 0 | — |
| Firma de Android | 2 archivos | 2 | Falsos positivos: `android/app/build.gradle.kts` lee las propiedades, y `key.properties.example` trae los textos `CAMBIAR_POR_…` |
| Contraseña literal | 1 archivo | 1 | Falso positivo: los códigos de error de `web/vendor/firebase/12.17.0/firebase-auth.js` (`auth/wrong-password`…) |
| Archivos protegidos (`key.properties*`, `*.jks`, `google-services.json`, `firebase_options.dart`, `firebase-prod*.json`, `.env`) | 0 | 0 | — |
| Idéntico a un archivo del corpus | 0 | 0 | — |
| UID de Firebase | 2 archivos | 2 | Falsos positivos: un identificador de 28 letras en `tool/t55_fila_central.dart` y un fragmento del SDK minificado |
| Correo de un autor de commits | 5 archivos, 6 apariciones | 5 | El contacto de la política de privacidad (D2), publicado a propósito, y la guía de commits. El mismo correo ya está en los metadatos de cada commit |
| Correo neutro (`*.test`) | 2 | 2 | Cuentas inventadas de pruebas y del plan del pentest |
| Otro correo | 1 archivo | 1 | `prototipos/js/screens-3.js`: el valor de ejemplo de un campo de correo en un formulario del prototipo, con un dominio institucional (`empornac.gob.gt`). No es una cuenta del proyecto; no comprobé si esa casilla existe |
| Correo personal de otra persona | 0 | 0 | — |
| Ruta de `baystream-privado` | 54 archivos, 108 apariciones | 54 | Solo la ruta (`--dart-define-from-file=…`), nunca el contenido |
| Nombre `firebase-prod*.json` | 45 archivos | 45 | Igual: la ruta del archivo, no el archivo |
| Contenedores del corpus | **9 archivos** | 9 | Ver abajo |
| Sin versionar, con nombre del corpus | **2 archivos** | — | Ver abajo |

**Los contenedores del corpus en el repo** (9 archivos, en el árbol y en la historia):
- 6 informes de `docs/` (BLOQUE7B, T42-ACEPTACION, T55, T58, T72 y T99), con 3 a 15 números cada uno: los contenedores que cita la evidencia;
- `test/baplie_parser_test.dart`, con 5;
- los dos registros de mediciones de H5 en `outputs/latencia-h5-20260814/` (`.xlsx`), con **150 cada uno**.

Los números son los del corpus **anonimizado** (prefijos inventados como `TSTU`, `DEMU`, `XQDU`, `ZKPU`); la anonimización no dejó números reales (`docs/S3-CASO-MAGELLAN-STAR.md`, «Cómo se anonimizó»). No es un secreto, pero sí es contenido del corpus en un repositorio público. Es el hallazgo T113-07.

**Sin versionar:** `output/pdf/T52-CORPUS_A01.pdf` y `output/pdf/T53-CORPUS_A01.pdf` son informes generados del corpus A01. La carpeta `output/` no está en el `.gitignore`, así que un `git add .` los publicaría. La regla de AGENTS.md prohíbe ese comando, pero el `.gitignore` no lo respalda. Es el hallazgo T113-06.

**Dictamen: ningún secreto real nuevo.** Los dos puntos del corpus quedan en la tabla para que Carlos decida.

**AVANCE del bloque 3:** cerrado, sin detener la tarea.

## 4. Los permisos

### 4.1 Android, contra las declaraciones de Play (T-88)

Las copias de `%TEMP%` de otras tareas tienen el `android/` modificado (otro `applicationId`, otra etiqueta), así que compilé uno limpio:
- `git -c core.autocrlf=false archive sprint3-cierre-2` en `%TEMP%\t113\apk-f631efa`;
- `flutter build apk --release`, sin cambiar nada, en 139 s;
- APK de 65.3 MB, huella `559c0a7ba8396a58…`. Va firmado con la clave de depuración, porque la copia no tiene `key.properties`; la firma no cambia los permisos.

**El manifiesto fusionado** (`aapt dump permissions` y `xmltree`, build-tools 36.1.0):

| Permiso o atributo | Origen | En T-88 | Coincide |
|---|---|---|---|
| `RECORD_AUDIO` | `main/AndroidManifest.xml` (T-94, el dictado) | Sí: «en tiempo de ejecución, sin formulario» | Sí |
| `INTERNET`, `ACCESS_NETWORK_STATE` | los plugins de Firebase | permisos normales | Sí |
| `READ_GSERVICES` | reCAPTCHA, que trae `firebase-auth` | Sí: «lo agrega reCAPTCHA y es normal» | Sí |
| `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` | AndroidX, propio del paquete | — | Normal, de firma |
| Ubicación, cámara, contactos, almacenamiento, `AD_ID` | — | «la app no los pide» | **Ninguno**, sí |
| `allowBackup` | `false`, con `dataExtractionRules` | D3 | Sí |
| `debuggable`, `usesCleartextTraffic` | ausentes | — | Sí |
| `minSdk` / `targetSdk` | 24 / 36 | — | — |

**Componentes exportados (5 de 13):**
- `MainActivity`, el lanzador;
- de Firebase Auth, `GenericIdpActivity` y `RecaptchaActivity`, que existen para volver del navegador en un inicio de sesión federado o un reCAPTCHA (la app no usa ninguno de los dos);
- `RevocationBoundService` de Google Sign-In, protegido por su permiso;
- `ProfileInstallReceiver`, protegido por `DUMP`.

Son del SDK, como ya registró el inventario de T-88.

### 4.2 Windows: el MSIX

- **`pubspec.yaml`** (`msix_config`, sin cambios después del cierre): `capabilities: internetClient`, solo red saliente, y sin micrófono porque en Windows no hay voz (T-94).
- **El paquete ya armado** (`build/t93/BayStream_1.0.4.0.msix`, del 15-oct; el de la entrega se rearma desde el cierre): su `AppxManifest.xml` declara **`internetClient` y `runFullTrust`**.
- **`runFullTrust`** lo pone `msix` en toda app Win32 empaquetada: la app corre con los permisos del usuario y fuera del contenedor de la tienda. Es lo que ya observó T-93 (el MSIX escribe en el almacén real). Se declara, no es un defecto (T113-12).

### 4.3 La Web

- **El único permiso del navegador es el micrófono:** Web Speech (`SpeechRecognition`), solo después de tocar el micrófono (`voice_recognizer_provider.dart`: «No inicializa el micrófono al construir la pantalla»).
- **Portapapeles:** solo escribe, con `Clipboard.setData` y dentro de un gesto (`departure_baplie_page.dart:131`), así que no pide permiso.
- **Ni ubicación, ni notificaciones, ni cámara.** Ningún `getUserMedia` propio.
- **El service worker** guarda la app para trabajar sin red (T-92). El SDK de Firebase y las fuentes se sirven desde el propio sitio (`web/vendor`, `web/fonts`), con su procedencia y sus huellas en `provenance.json`.
- **Las cabeceras de Hosting** (`firebase.json`) solo declaran `Cache-Control`. **No hay** `Content-Security-Policy`, `X-Content-Type-Options`, `X-Frame-Options` ni `frame-ancestors`, `Referrer-Policy` ni `Permissions-Policy`. HSTS lo pone Firebase Hosting en `*.web.app`, según su documentación; no lo comprobé en la Web publicada, porque esta tarea no la consulta. Es el hallazgo T113-04, y el pentest de 10.103 lo verifica en vivo (A05).

**Dictamen: coherentes en las tres plataformas.** Lo que piden coincide con lo que se declara.

**AVANCE del bloque 4:** cerrado.

## 5. Los hallazgos del Incremento 2, al cierre del Sprint 3

| # | Hallazgo | Sev. | Estado al cierre del Sprint 2 | **Estado al cierre del Sprint 3** | Evidencia |
|---|---|---|---|---|---|
| H-01 | Reglas fuera del control de versiones | Crítica | Resuelto | **Resuelto.** Las de producción están en `docs/T80-firestore.rules.propuesta`; las de H5, en `firestore.rules`. Falta el cotejo con las publicadas (T113-01) | 1.1, 1.3 |
| H-02 | Creación y actualización anónimas | Alta | Reacotado, con riesgo residual | **Resuelto en producción:** sesión, lista de autorizados y roles (T-79, T-80); 69 + 25 casos. **Aceptado** el residual del proyecto temporal de H5, que sigue con reglas sin identidad (T113-13) | 1.3, 1.4 |
| H-03 | Reglas de prueba expiradas | Crítica | Resuelto | **Resuelto** | — |
| H-04 | Credenciales en el código | Media | Cerrado en el código; las del temporal, en el historial | **Cerrado en el código:** cero claves en el árbol. **Aceptado** el residual: las opciones del temporal, en 2 apariciones de la historia (T113-05) | 3 |
| H-05 | Texto crudo de excepciones | Baja | Atendido | **Resuelto:** los 218 mensajes con causa y acción (T-112, censo de T-98; RNF-006 «mensajes» 218/218, 10.105) | 10.105 |
| H-06 | Sin registro ni alertas | Baja | Limitación declarada (proyecto temporal) | **Pendiente para `baystream-app`:** el Sprint 3 no verificó registro ni alertas en el proyecto de producción (T113-11) | — |
| H-07 | Sin análisis de dependencias | Baja | Cerrado (113 paquetes) | **Cerrado y repetido:** 117 paquetes, 0 avisos | 2 |

**Los tres hallazgos nuevos del Incremento 2:**

| Hallazgo | Estado al cierre del Sprint 3 | Evidencia |
|---|---|---|
| La contraseña de la firma en un `.txt` oculto | **Resuelto:** `key.properties*` ignorado; ningún archivo protegido en el árbol ni en los 1 840 blobs de la historia | 3 |
| Las opciones del temporal en el historial | **Aceptado**: es H-04 (T113-05) | 3 |
| El respaldo automático de Android | **Resuelto:** `allowBackup=false` y `dataExtractionRules` (T-88), comprobado en el APK de cierre | 4.1 |

**La auditoría de Gru** (10.56, tarea 2) no se entregó; la reemplaza el pentest de 10.103, que va al cierre del proyecto, fuera del sprint.

## 6. Los hallazgos de este sprint

Severidad con la escala de la línea base (Crítica, Alta, Media, Baja), más **Informativa** para lo que no es una vulnerabilidad pero conviene dejar escrito.

| # | Hallazgo | Sev. | Estado | Qué hace falta |
|---|---|---|---|---|
| **T113-01** | El cotejo de las reglas publicadas no se hizo: falta el archivo de la consola | — (evidencia) | **Pendiente** | Carlos deja el texto en `%TEMP%\t113\reglas-publicadas.txt` (o dice la ruta) y Timonel corre `node tool/t113_reglas.mjs <ruta>` |
| **T113-02** | Cualquier cuenta autorizada lee **todas** las operaciones, con sus fuentes y movimientos; el rol solo limita lo que se escribe. No hay alcance por operación | Media | **Aceptado** (10.47, punto 2; la política lo dice). Abierto para el revisor de Play (T-88, 4.1) | Si se da una cuenta a terceros, otra regla o solo operaciones de prueba |
| **T113-03** | App Check sin apps registradas y Fraud Defense (reCAPTCHA) de Authentication apagado | Baja | **Aceptado** (10.49). Las reglas siguen exigiendo una cuenta de la lista | Al abrir la app a más usuarios |
| **T113-04** | Hosting sin cabeceras de seguridad (CSP, `X-Content-Type-Options`, `frame-ancestors`, `Referrer-Policy`, `Permissions-Policy`) | Baja | **Pendiente** | El pentest (10.103, A05) lo verifica en vivo; el cambio en `firebase.json` lo decide Carlos |
| **T113-05** | Las opciones de Firebase del proyecto temporal de H5 siguen en la historia pública (`lib/main.dart`, `cdc3830`…`ba7353a`) | Informativa | **Aceptado** (H-04; T-47, sección 7) | Nada: no son secretas, y borrar la historia exige reescribirla |
| **T113-06** | `output/pdf/T52-CORPUS_A01.pdf` y `T53-CORPUS_A01.pdf`, generados del corpus, están sin versionar y **sin ignorar** | Baja | **Pendiente** | Agregar `output/` al `.gitignore` (es de Yov y Carlos, no de este carril) |
| **T113-07** | Números de contenedor del corpus anonimizado en 9 archivos versionados: 6 informes, una prueba y los dos registros de H5 (150 cada uno) | Informativa | **Pendiente de decisión** | Carlos decide si se aceptan, con el argumento de la anonimización, o se retiran de lo que se agregue en adelante |
| **T113-08** | Rutas de `baystream-privado` y de `firebase-prod.json` en 54 archivos versionados | Informativa | **Aceptado** | Nada: es la ruta, nunca el contenido |
| **T113-09** | El correo del autor en 5 archivos (la política y su prueba, la guía de commits) | Informativa | **Aceptado** (D2: es el contacto público de la política) | — |
| **T113-10** | Componentes exportados de Firebase Auth y Google Sign-In, que la app no usa | Informativa | **Aceptado** (inventario de T-88) | Revisarlo si cambia `firebase_auth` |
| **T113-11** | H-06 no verificado en el proyecto de producción | Baja | **Pendiente** | Comprobar los Cloud Audit Logs de `baystream-app` (Carlos, consola), o declararlo como limitación |
| **T113-12** | El MSIX corre con `runFullTrust`, fuera del contenedor | Informativa | **Aceptado**: es propio de una app Win32 empaquetada | — |
| **T113-13** | El proyecto temporal de H5 conserva reglas sin identidad | Baja | **Aceptado** (riesgo residual del Incremento 2) | Retirarlo cuando H5 ya no necesite el proyecto |

**Lo que T-113 cerró por su cuenta:** la batería de T-80 no cubría la escalada de rol sobre la lista de autorizados ni el cambio directo de la oficina. Ahora sí, con `tool/t113_reglas_abuso.mjs`, 25/25 (sección 1.4). **Resuelto**, solo en `tool/`.

**Por severidad:** ninguna crítica ni alta; 1 media (aceptada); 5 bajas (2 aceptadas, 3 pendientes); 6 informativas (5 aceptadas, 1 pendiente de decisión); y el pendiente de evidencia T113-01.

**AVANCE del bloque 5:** cerrado.

## 7. RNF-004, citado de T-98

No se repitió. El dictamen vigente es **no medible** (10.101; se sostiene en 10.105):
- la condición A (sin sesión) se recorrió 11/11 en los tres clientes, y el Honor la cumple (aceptación de Timonel, `docs/T98-ACEPTACION-RESULTADOS.md`, «RNF-004 · La condición A en el Honor»);
- el TLS se infiere ≥ 1.3 en Chrome por las sesiones QUIC (RFC 9001); en Windows no apareció un ServerHello atribuible, y en el Honor se declara;
- las credenciales no se pueden verificar sin abrir secretos.

Medición de Codex en `f9a0096` (`docs/T98-RESULTADOS.md`, «RNF-004 · Tabla vigente»).

## 8. Validaciones ejecutadas

| Comando | Resultado |
|---|---|
| `powershell -File tool/t113_emulador.ps1` | Emulador 1.22.0 en `127.0.0.1:8181`, `demo-t113` |
| `node tool/t80_reglas.mjs 8181 demo-t113` (dos veces) | **69/69**, salida 0 |
| `node tool/t113_reglas_abuso.mjs 8181 demo-t113` | **25/25**, salida 0 |
| `node tool/t113_reglas.mjs <blob LF de sprint3-cierre-2>` | iguales, salida 0 (autoprueba) |
| `node tool/t113_reglas.mjs <copia alterada>` | distintos, salida 1 (autoprueba) |
| `node tool/t113_dependencias.mjs` | 117 paquetes, 0 vigentes, salida 0 |
| `python -I tool/t113_secretos.py --corpus <carpeta anonimizada>` | salida 1 por H-04 en la historia y por los falsos positivos de la tabla; revisados uno por uno |
| `flutter build apk --release` en la copia limpia | correcto, 139 s |
| `aapt dump permissions / badging / xmltree` | sección 4.1 |

No corrí la suite ni `analyze`: esta tarea no toca `lib/` ni `test/`, y los scripts nuevos son de Node, Python y PowerShell, fuera de `flutter analyze`.

**Evidencia local, ignorada por Git** (`build/t113/`): `reglas-bateria.log`, `reglas-bateria-2.log`, `reglas-abuso.log`, `dependencias.md`, `dependencias.json`, `dependencias-salida.json` y `secretos.json` (cuentas y rutas, sin valores). **Fuera del repo** (`%TEMP%\t113\`): `revision-privada.json` (los valores, para la revisión a mano; no se comparte), `apk-f631efa\` (la copia y su APK), `apk-manifest.txt`, `apk-build.log` y `emu\`.

**Lo que dejé corriendo y apagué:** el emulador, cerrado por su PID (`java`, 34812); la CLI terminó con él. También cerré los demonios de Gradle (19488) y de Kotlin (4848) que dejó la compilación del APK. El JAR queda en `%USERPROFILE%\.cache\firebase\emulators\cloud-firestore-emulator-v1.22.0.jar`, donde lo guarda `firebase-tools`. No usé ningún cliente, ni el Honor, ni Chrome.

## 9. Horas

21-oct, hora de Guatemala: de **≈ 16:25 a 17:05**, ≈ **0.7 h** observadas contra 3.0 h estimadas. Incluye la compilación del APK (≈ 2.5 min) y la descarga del JAR del emulador.

## 10. Archivos de la tarea

Nuevos:

```text
tool/t113_emulador.ps1
tool/t113_reglas.mjs
tool/t113_reglas_abuso.mjs
tool/t113_dependencias.mjs
tool/t113_secretos.py
docs/T113-SEGURIDAD-RESULTADOS.md
```

**No cambian:** `pubspec.yaml`, `pubspec.lock`, `lib/`, `test/`, `firebase.json`, `firestore.rules`, `.gitignore` ni `tool/t80_reglas.mjs`. Los cambios ajenos del árbol (los `.docx` y `.pdf` de `docs/`, `docs/T99-RESULTADOS.md`, `docs/RELEVO-Yov-GLM.md`, `output/`, `android/build/`) no son de esta tarea y quedan fuera del bloque.
