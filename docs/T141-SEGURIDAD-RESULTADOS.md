# T-141 · Las pruebas finales de seguridad de la 1.0.0

GLM (auditoría, decisión 10.103) · 4-nov-2026 · carpeta `C:\Proyectos\baystream-rediseno`, rama `sprint-4`, cabeza `63b5ac8` · **base auditada: la 1.0.0, commit `eddc388` («Sprint 4: la 1.0.0, mezcla de sprint-4 a master», etiqueta `v1.0.0` sobre el objeto `d16e410`), código de la app revisado en `32eac61` (10.105)** · `pubspec.yaml`: `version: 1.0.0+9`, `msix_version: 1.0.0.0`. Entre `eddc388` y la cabeza no cambió ningún archivo de producto (`git log eddc388..HEAD -- lib test pubspec.yaml pubspec.lock web android windows firebase.json firestore.rules docs/T130-firestore.rules.propuesta` sale vacío); lo que dice este informe vale para lo publicado.

**Estado: completa.** Las cinco partes tienen su evidencia y su dictamen. **Lo publicado coincide con lo auditado**: las reglas de Firestore son idénticas a la propuesta de T-130 (`8B903949…`), el MSIX verificado es el publicado (`BA01DED7…`), el instalador publicado es el de la 10.106 (`EF8F2BBB…`) y el SDK que sirve la Web tiene la huella de `provenance.json`.

**Lo que no toqué:** `lib/`, `test/`, `pubspec.*`, `web/`, `android/`, `windows/`, `firebase.json`, las reglas y `firestore.rules`. Firebase de producción: ninguna escritura, ninguna CLI contra el proyecto real, ningún inicio de sesión; solo la Web en vivo en lectura (una petición de cada cosa) y el emulador con `demo-t141`. El proyecto temporal de H5, ni mirarlo. Los cambios ajenos del árbol (`test/t114_fase3_correccion_test.dart`, los tres generados de `windows/flutter/`, `docs/entrega-7nov/fuentes/`, `docs/t117/`) no son de esta tarea y quedan fuera del bloque. No ejecuté `git status` ni ninguna escritura de Git.

**Herramientas que corrí:** node v24.14.0, python 3.14.3 (`-I`), openjdk 21.0.12.1 (emulador), firebase-tools 15.32.1, aapt 36.1.0, signtool 10.0.26100.0, curl.exe 8.17.0, openssl 3.5.4, ISCC 7.1.1 (lectura de versión), flutter 3.38.9 / dart 3.10.8 (dos comandos, cada uno con su `SEMÁFORO:`). **No encontré** `bundletool`: el AAB firmado que subió Carlos no se abrió; lo que revisé en Android es el APK de la copia limpia (4.1).

## Resumen

| Parte | Dictamen | Evidencia |
|---|---|---|
| 1 · Reglas de Firestore | **Lo publicado es la propuesta de T-130** (`equal: true`, `8B903949…`). Baterías contra el texto publicado: T-80 **69/69**, T-113 **25/25**, T-127 **31/31**, T-130 **38/38**; abuso nuevo **18/18**, con cada denegación en su regla. El código de la 1.0.0 pide exactamente lo que permiten las reglas | 1.1 a 1.4 |
| 2 · Dependencias | **Cero avisos vigentes** en 117 paquetes (OSV + GitHub Advisory, por versión exacta). SDK web 12.19.0 (huella cotejada con npm y con lo servido), BoM 34.19.0, C++ 13.13.1 (corrige la confianza en las CA intermedias de eMudhra), Flutter 3.38.9/Dart 3.10.8, Inno Setup 7.1.1 | 2 |
| 3 · Secretos | **Ningún secreto nuevo** (árbol 2 031 archivos, sin versionar 159, historia 520 commits y 3 557 blobs). La única clave real sigue siendo H-04 en la historia. T113-06 **cerrado** (`output/` ignorado). Los contenedores del corpus llegaron a un archivo versionado más (el Documento 1) y a una fuente sin versionar | 3 |
| 4 · Permisos y empaquetado | **Coherentes**: APK limpio de la 1.0.0 contra las declaraciones de T-88; MSIX firmado, `internetClient` + `runFullTrust`; instalador por usuario sin administrador, sin firma (SmartScreen, informativo). Web: TLS 1.3, HSTS con preload, **sin** las demás cabeceras (T113-04 confirmado en vivo) | 4.1 a 4.3 |
| 5 · Caja blanca OWASP | La autorización vive en las reglas; el almacenamiento local no guarda credenciales; el lector BAPLIE aguantó **180/180 mutaciones** sin excepciones sin capturar ni cuelgues; 8 hallazgos nuevos, **ninguno crítico ni alto** | 5 y 6 |

## 1. Las reglas de Firestore de la 1.0.0

### 1.1 El cotejo con lo publicado: coincide con T-130

| | Bytes | Líneas | CRLF | SHA-256 normalizada |
|---|---:|---:|---:|---|
| `docs/T130-firestore.rules.propuesta` | 23 446 | 485 | 0 | `8B9039496CCCDA9FBC1412CC1F8610B3183D58FB4BA779EFB0C0C7D920EEFF71` |
| **Texto publicado** (`build/t141/reglas-publicadas-4nov.txt`, copiado de la consola el 4-nov a las 20:03) | 23 930 | 485 | 484 | **`8B903949…`** |

- `node tool/t113_reglas.mjs build/t141/reglas-publicadas-4nov.txt build/t141 docs/T130-firestore.rules.propuesta`: **`equal: true`**, salida **0** (`reglas-cotejo.json`, la corrida de las 20:05).
- Contra T-127 (`FC17842C…`) y contra T-80 (`7E57F227…`): **distintos**, salida 1, con las líneas señaladas (`cotejo-contra-t127.log`, `cotejo-contra-t80.log`). Es lo esperado: lo publicado es la de T-130, la que los clientes de la 1.0.0 necesitan. **No hay hallazgo crítico.**
- La copia de hoy es idéntica byte a byte a la que dejó Carlos el 3-nov tras publicar (misma huella cruda, `133CCBEC…`), contra la que corrieron las baterías y el abuso: todo lo de 1.3 y 1.4 vale para el mismo texto.

### 1.2 Lo que pide el código de la 1.0.0

Toda lectura y escritura de Firestore de `lib/` (busqué `FirebaseFirestore`/`firestore` en todo `lib/`), contra el texto publicado:

| Lo que hace el código | Archivo y línea | Lo que exige la regla (líneas del texto publicado) | Coincide |
|---|---|---|---|
| Lee su propio `authorized/{uid}`: escucha, `get` tras iniciar sesión y `get` del servidor (motor) | `firebase_session_repository.dart:110, 150`; `firestore_operation_sync.dart:617-620` | `get` solo del propio uid (L124) | Sí |
| Publica la operación y sus fuentes en un lote, con `createdAt` del servidor; antes consulta las abiertas (`where status == open`) por lo de T-130 | `firestore_operation_sync.dart:103-168, 172-188` | `create` de oficina con `validNewOperation` (10 campos exactos, L141-156); trozos `validPublishedPart` (8 campos, L267-279); `list` para `isAuthorized()` (L133) | Sí; el manifiesto es un mapa por tipo (`fileName`, `sha256`, `parts`, `length`, `voyage` opcional: `source_revisions.dart:91-98`) |
| Cierra: `status`, `closedBy`, `closedAt` del servidor | `firestore_operation_sync.dart:312-327` | `validClosing` (solo esos tres, abierta → cerrada, L159-166) | Sí |
| Escribe un movimiento con el sobre de T-79a y `receivedAt` del servidor; escucha la subcolección | `firestore_operation_sync.dart:589-611, 745-771` | `validMovement`: 11 campos exactos, `author.role` igual al de la lista, rangos de `createdAt` (L330-380) | Sí |
| Los 9 tipos de `MovementType` y sus `payload` | `movement.dart:13-27, 212-313` | `officeTypes()` 9 y `dockTypes()` 6 (L342-351); `hasOnly` de cada validador | Sí; el constructor quita los nulos, igual que en T-113 |
| Reemplaza el listado con revisión (T-127): lote de trozos `export_list-r{n}-{i}` + entrada del manifiesto | `firestore_operation_sync.dart:356-414, 496-521` | `validListRevision` + `validListEntry` (revisión ascendente, L174-205) y `validRevisionPart` (revisión, huella y partes del manifiesto, L285-302) | Sí |
| **Nuevo (T-130):** agrega el BAPLIE que falta: trozos `{tipo}-{i}` + entrada con `voyage` opcional | `firestore_operation_sync.dart:423-489, 496-521` | `validPlanAddition` + `validAddedPlan` (solo si el tipo no estaba, L212-228), `validPlanEntry` (L232-242) y `validAddedPart` (huella y partes del manifiesto, `createdBy` propio, L311-326) | Sí; el cliente rechaza el tipo existente y el cierre antes de escribir (`addSource`, 437-451) |
| Lee fuentes: manifiesto por escucha, trozos por `where kind`/`where revision`, unión por `get` del servidor | `firestore_operation_sync.dart:245-309, 647-703` | `get, list: if isAuthorized()` (L133, L249) | Sí |
| `voyages` y `latency_test` | solo `c3_reconciliation_screen.dart` y `latency_test_screen.dart` (H5, congelados) | cerradas por el comodín (L480-482) | Sí: ninguna pantalla del producto las escribe; las pantallas de la 1.0.0 usan `VesselRepositoryImpl` solo para parsear |

La diferencia menor de T-113 sigue y sigue sin efecto: el validador del cliente (`MovementDraft.validate`, `movement.dart:320`) no limita a 300 caracteres el motivo de una descarga o carga; la regla (`isReason`, L108-110) sí, y el servidor lo rechaza.

### 1.3 Las cuatro baterías contra el texto publicado

`tool/t141_baterias.ps1` (adaptación de `tool/t130_baterias.ps1`) levanta el emulador con `tool/t113_emulador.ps1`, proyecto **`demo-t141`**, puerto **8383** (comprobado libre antes: nada escucha en 8181, 8282, 8383 ni 4000), carga el texto publicado y corre las cuatro baterías; cierra el emulador por su árbol de procesos. Corrida con la luz verde de Carlos (línea `SEMÁFORO:` antes y después).

| Batería | Contra el texto publicado | Registro |
|---|---|---|
| T-80, `tool/t80_reglas.mjs` | **69 de 69** | `reglas-t80-contra-publicadas.log` |
| T-113, `tool/t113_reglas_abuso.mjs` | **25 de 25** | `reglas-t113-contra-publicadas.log` |
| T-127, `tool/t127_reglas_revision.mjs` | **31 de 31** | `reglas-t127-contra-publicadas.log` |
| T-130, `tool/t130_reglas_plan.mjs` | **38 de 38** | `reglas-t130-contra-publicadas.log` |

Salida **0**, resumen en `baterias-resumen.json`; el emulador quedó cerrado (puerto 8383 libre al terminar).

### 1.4 Casos de abuso nuevos para lo que T-130 abrió

`tool/t141_reglas_abuso.mjs` (patrón del de T-113, contra el texto publicado, mismo emulador), **18 casos, 18 como se esperaba**, salida 0 (`reglas-t141-abuso.log`, con `T141_DETALLE=1`). Denegaciones con la línea de la regla en la que caen:

| Grupo | Caso | Esperado | Regla donde cae |
|---|---|---|---|
| Agregar | El muelle no agrega una fuente | Denegado | `update` de `operations` exige `isOffice()` (L137) |
| Agregar | La oficina no agrega un tipo que ya está | Denegado | `validAddedPlan`: `!(kind in b)` (L225) |
| Agregar | Ni a una operación cerrada | Denegado | `validPlanAddition`: `before.status == 'open'` (L216) |
| Agregar | Ni a nombre de otro (trozo con `createdBy` ajeno) | Denegado | `validAddedPart`: `createdBy == request.auth.uid` (L324) |
| Trozos | Trozo con otra huella que el manifiesto | Denegado | `validAddedPart`: `sha256 == op.sources[kind].sha256` (L320) |
| Trozos | Ni con otro número de partes | Denegado | `validAddedPart`: `parts == op.sources[kind].parts` (L321) |
| Trozos | **Un manifiesto sin sus trozos** | **Permitido** (esperado) | La regla no lo puede exigir: `validPlanAddition` solo mira el documento de la operación; ver T141-04 |
| Listado | Una revisión no borra la anterior (delete del trozo r1) | Denegado | `sources`: `allow delete: if false` (L251) |
| Listado | Ni la reescribe (update del trozo r1) | Denegado | `sources`: `allow update: if false` (L251) |
| Listado | No se reescribe la revisión vigente (r2 otra vez) | Denegado | `validListEntry`: `revision > previous` (L204) |
| Listado | Ni se vuelve atrás (r1 con r2 vigente) | Denegado | ídem (L204) |
| Lectura | Fuera de la lista no lee la operación | Denegado | `operations`: `allow get, list: if isAuthorized()` (L133) |
| Lectura | Ni sus fuentes | Denegado | `sources`: `isAuthorized()` (L249) |
| Lectura | Una cuenta inactiva tampoco lee | Denegado | `isAuthorized`: `active == true` (L85) |
| Lectura | El muelle no lee `authorized` ajeno | Denegado | `authorized`: `request.auth.uid == uid` (L124) |
| Cierre | Tras el cierre, ningún movimiento del muelle | Denegado | `validMovement`: abierta o `createdAt <= closedAt` (L376) |
| Cierre | Ni de la oficina | Denegado | ídem (L376) |
| Cierre | El registrado sin red antes del cierre sí entra | Permitido | ídem (L376, límite declarado de la cola) |

## 2. Las dependencias después de T-136

`node tool/t113_dependencias.mjs pubspec.lock build/t141`, salida **0**: **117 paquetes** del lock (16 directos, 5 de desarrollo, 96 transitivos; 109 de pub.dev y 8 del SDK), consultados por versión exacta en **OSV** y en **GitHub Advisory** (14 avisos de pub, 0 sin revisar). **Cero avisos vigentes**; los dos históricos de siempre, ya fuera de rango (`archive` 4.0.9 y `http` 1.6.0). Evidencia: `dependencias.md` y `dependencias.json`.

Los SDK que el lock no lista:

| Componente | Versión | Avisos |
|---|---|---|
| Firebase JS servido por la Web (`web/vendor/firebase/12.19.0`) | 12.19.0 | ninguno en OSV; huella de los tres módulos cotejada con `provenance.json` en local (2) y con lo servido en vivo (4.3) |
| BoM de Firebase en Android (el que fijan los plugins) | 34.19.0 | ninguno en OSV (subió de 34.17.0 con T-136, 10.101) |
| SDK de C++ de Windows | **13.13.1** | OSV no cubre ese ecosistema. **Es el motivo de T-136**: corrige la confianza de raíces del SDK tras el compromiso de las CA intermedias de eMudhra (guía `compromised-emudhra-intermediate-ca` de Firebase, 3-nov): con las claves filtradas se podían falsificar certificados HTTPS, y el SDK de C++ trae sus propias raíces, por lo que actualizar el sistema no arreglaba las compilaciones instaladas |
| Flutter / Dart | 3.38.9 / 3.10.8 | sin avisos aplicables; la subida a 3.47.8 que pedía la guía quedó como O-136-1, para después del 7-nov |
| Inno Setup | 7.1.1 | la 7.1.1 corrige un recorrido de ruta al extraer archivos `.cab/.vhd/.vhdx/.vmdk` maliciosos ([is7-whatsnew](https://jrsoftware.org/files/is7-whatsnew.htm)); el secuestro de DLL registrado es de la **6.2.1** ([OpenCVE](https://app.opencve.io/cve/?product=inno_setup&vendor=jrsoftware)), y la línea 7 trae la mitigación activa: al arrancar, Setup quita del PATH de búsqueda de DLL todo directorio que no sea el del sistema ([Security Measures](https://jrsoftware.org/ishelp/topic_securitymeasures.htm)) |

**Dictamen: cumple.** H-07 sigue cerrado y ahora incluye el SDK web 12.19.0 y el BoM 34.19.0.

## 3. Secretos en el árbol y en la historia

`python -I tool/t113_secretos.py --corpus <carpeta anonimizada> --rama sprint-4 --salida build\t141 --privado %TEMP%\t141\revision-privada.json`, salida 1 como en T-113 (H-04 en la historia y falsos positivos revisados). La historia creció: **520 commits y 3 557 blobs** (358 y 1 840 en T-113); árbol 2 031 archivos, sin versionar 159. Corpus: 18 archivos, 4 521 contenedores, iguales.

| Detector | Árbol | Historia | Revisado a mano |
|---|---|---|---|
| Clave de Google | 0 | 1 archivo, 2 apariciones (`lib/main.dart`, `cdc3830`…`ba7353a`) | **H-04, ya conocido, aceptado.** Sin cambios |
| Claves privadas, cuentas de servicio, tokens, JWT | 0 | 0 | — |
| Archivos protegidos (`key.properties*`, `*.jks`, `google-services.json`, `firebase_options.dart`, `firebase-prod*.json`, `.env`) | 0 | 0 | — |
| Firma de Android / contraseña literal / UID de Firebase | 4 archivos | 5 | Falsos positivos de siempre, ahora también en `web/vendor/firebase/12.19.0` (códigos `auth/wrong-password` del SDK y un fragmento minificado) |
| Contenedores del corpus | **10 archivos** (9 en T-113) | 10 | Ver abajo |
| Sin versionar con contenedores | **1 archivo** | — | Ver abajo |
| Rutas de `baystream-privado` / `firebase-prod.json` | 62 archivos | 62 | Solo la ruta, nunca el contenido (T113-08) |
| Correos (autor, neutros, otro) | 17 archivos | 18 | Los mismos de T-113: contacto público de la política (D2), cuentas inventadas y un valor de ejemplo de un prototipo |

**Lo nuevo desde T-113, a mano:**

- **El script del instalador y lo que empaqueta.** El manifiesto del instalador publicado (`C:\Users\Public\BayStream-T137\1.0.0.9\BayStream_Setup_1.0.0.9.manifiesto.json`, 93 entradas con huella) no trae ningún `key.properties`, `google-services.json`, `firebase_options.dart`, `.jks` ni archivo del privado: la carga son el `.exe` de la app, el motor de Flutter, las tres DLL del runtime, las fuentes y los recursos. El `.iss` (en `C:\Proyectos\baystream-t137`) copia `{#T137AppDir}\*` y nada más.
- **`docs/entrega-7nov/` y `docs/manual-1.0.0/`.** Los dos `.docx` del 7-nov no traen ningún correo ni ningún UID (XML interno revisado). El manual de la 1.0.0 (45 capturas) se tomó contra el **emulador** con cuentas sintéticas (`docs/T139-RESULTADOS.md`: «Oficina de prueba» y «Muelle de prueba», claves solo en `%TEMP%`); revisé a mano la captura de «Nube y cuenta» publicada (`27-nube-publicada.png`): cuenta genérica «office», sin correo ni UID reales. **Pero** los contenedores del corpus llegaron a un archivo versionado más: `docs/entrega-7nov/BayStream_Documento1_Investigacion.docx` (4 números, ya en `master` con `63b5ac8`) y a la fuente sin versionar `docs/entrega-7nov/fuentes/DOC1.md` (los mismos 4). Es T113-07 crecido: T141-07.
- **`build/` y `output/` contra el `.gitignore`.** **T113-06 se cerró**: `.gitignore` trae `output/` («no van al repo; T113-06») y la carpeta ya no existe en este árbol. `build/` sigue ignorado.
- **Los dos repos.** El privado es `origin` (`YovaWarrior/Proyecto-BayStream`). El portafolio público **`YovaWarrior/BayStream`** tiene solo `README.md` y 4 capturas: el README no trae números de contenedor, buques, viajes ni correos, y declara que el corpus vive fuera y anonimizado; las 4 capturas revisadas a mano (`avance`, `muelle`, `pdf`, `plano`) muestran agregados del buque sintético de pruebas, sin números de contenedor, sin cuentas, sin «Nube y cuenta» con datos. **Nada del corpus ni del piloto está en el público.**

## 4. Permisos y empaquetado de lo publicado

### 4.1 Android

Copia limpia de `eddc388` (`git -c core.autocrlf=false archive`, en `%TEMP%\t141\apk-1.0.0`; `pubspec.yaml` dice `1.0.0+9` y no trae `key.properties`), `flutter build apk --release` en 270 s, salida 0 (con su `SEMÁFORO:`). APK de 68.0 MB, huella `541EA497173FC518…`, firmado con la clave de depuración (la firma no cambia los permisos). **Cuál revisé: este APK; no el AAB firmado que subió Carlos** (no hay `bundletool` instalado); el manifiesto y los permisos no dependen de los `--dart-define`.

| Permiso o atributo | Valor | En T-88 | Coincide |
|---|---|---|---|
| `RECORD_AUDIO` | sí (T-94, el dictado) | «en tiempo de ejecución, sin formulario» | Sí |
| `INTERNET`, `ACCESS_NETWORK_STATE` | sí | permisos normales | Sí |
| `READ_GSERVICES` | sí | «lo agrega reCAPTCHA y es normal» | Sí |
| Ubicación, cámara, contactos, almacenamiento, `AD_ID` | **ninguno** | «la app no los pide» | Sí |
| `allowBackup` | `false`, con `dataExtractionRules` | D3 | Sí |
| `debuggable`, `usesCleartextTraffic` | ausentes | — | Sí |
| `minSdk` / `targetSdk` | 24 / 36 | — | — |
| `versionCode` / `versionName` | 9 / 1.0.0 | la publicación de la 10.105 | Sí |

**Componentes exportados: 5 de 13** (igual que T-88 y T-113, ahora con `firebase_auth` 6.7.1): `MainActivity` (lanzador), `GenericIdpActivity` y `RecaptchaActivity` de Firebase Auth (que la app no usa), `RevocationBoundService` de Google Sign-In (protegida por `REVOCATION_NOTIFICATION`) y `ProfileInstallReceiver` (protegida por `DUMP`). Evidencia: `apk-permissions.txt`, `apk-badging.txt`, `apk-manifest.txt`.

### 4.2 Windows

- **El MSIX 1.0.0.0** (`proyecto-baystream\build\t93\BayStream_1.0.0.0.msix`): huella **`BA01DED7…`**, igual a la publicada (10.105); **firma verificada** (`signtool verify /pa /all`, salida 0). Su `AppxManifest.xml` declara `internetClient` y `runFullTrust`, y nada más: `runFullTrust` es lo propio de una app Win32 empaquetada (T113-12, aceptado).
- **El instalador de T-137** (`C:\Users\Public\BayStream-T137\1.0.0.9\BayStream_Setup_1.0.0.9.exe`): huella **`EF8F2BBB…`**, la misma que armó Timonel (10.106). **Sin firma** (`signtool`: «No signature found», salida 1): copiado a la laptop no avisa; descargado de internet, SmartScreen muestra «Windows protegió su PC» — hallazgo **informativo** (T141-02, declarado como límite en T-137).
  - `PrivilegesRequired=lowest`: por usuario, **sin administrador**; instala en `{localappdata}\Programs\BayStream` y rechaza como destino el almacén y sus parientes;
  - escribe solo `{app}`, accesos de usuario y la clave de desinstalación en HKCU: **nada en rutas de sistema**;
  - el desinstalador **no borra el almacén** y lo dice cuatro veces (confirmación, final y dos variantes de cierre); `[UninstallDelete]` solo retira `{app}` vacía; ante la MSIX, se detiene sin copiar y explica dónde están los datos (10.104);
  - mitigación de secuestro de DLL: la de la línea 7 de Inno Setup (quita del PATH de búsqueda todo directorio no del sistema al arrancar) más la auditoría de DLL de `t137_instalador.dart` con `dumpbin`.

### 4.3 La Web en vivo, solo lectura (una petición de cada cosa)

| Comprobación | Resultado |
|---|---|
| Cabeceras de `/` (`curl.exe -sI`) | `Strict-Transport-Security: max-age=31556926; includeSubDomains; preload` **sí**; **no hay** `Content-Security-Policy`, `X-Content-Type-Options`, `X-Frame-Options` ni `frame-ancestors`, `Referrer-Policy` ni `Permissions-Policy` — **T113-04 confirmado en vivo** (T141-01) |
| TLS (`openssl s_client`) | **TLS 1.3** por defecto (TLS 1.2 aceptado), cifre `TLS_AES_128_GCM_SHA256`, certificado `CN=web.app` de Google Trust Services (`WR3`), verificación `0 (ok)` |
| Service worker | `/flutter_service_worker.js` se sirve con `no-cache` (las actualizaciones llegan); registrado en el alcance raíz `/`; nada de `Service-Worker-Allowed` raro |
| SDK servido | los tres módulos de `/vendor/firebase/12.19.0/` tienen **exactamente** las huellas `servedSha256` de `provenance.json` (`6831B388…`, `0F99FC82…`, `0C4E645F…`) |
| Listado y archivos de más | **sin listado**: toda ruta desconocida devuelve la app (rewrite `** → /index.html` de `firebase.json`, T141-05); `/.git/config` y `/build/` devuelven el `index.html` de Flutter, no contenido; `privacidad.html` y `version.json` son lo esperado |

`Last-Modified: 4-nov 03:09 UTC` en `/`, la publicación de la 1.0.0 (21:09 del 3-nov en Guatemala). Evidencia: `web-cabeceras.txt`, `web-tls.txt`, `web-sdk-huellas.txt`.

## 5. Lo latente: revisión OWASP de caja blanca sobre la 1.0.0

Con el código de `eddc388` y las reglas publicadas a la vista, por superficie y lista. **Una aclaración de método:** el OWASP Desktop App Security Top 10 es un **proyecto comunitario, no una norma** como las otras tres listas; se usa como referencia y así se cita en el documento técnico.

**Web — OWASP Top 10:2025.** *Control de acceso (A01) y diseño (A04):* la autorización vive en las reglas, no en la interfaz: los botones se esconden por rol, pero lo que manda es `isAuthorized()`/`isOffice()` en el servidor; un cliente modificado no gana nada (1.4). *Criptografía (A02):* TLS 1.3 en vivo; en el navegador queda el almacén en IndexedDB, sin credenciales (abajo). *Entrada (A03):* el lector BAPLIE aguantó el fuzzing completo (abajo) y los campos de búsqueda solo filtran listas ya cargadas. *Configuración (A05):* T141-01, las cabeceras. *Autenticación (A07):* ver abajo. *Integridad (A08):* el SDK se sirve del propio sitio con huella verificada en vivo; `flutter_bootstrap.js` es el único punto de entrada. *Registro (A09):* los 35 `debugPrint` de `lib/` registran códigos y errores del servicio, no datos del usuario ni contenedores; el único volcado de datos (`LATENCY_CSV`) vive en la pantalla congelada de H5.

**API (Firestore y Authentication) — OWASP API Security Top 10 2023.** *API1 BOLA/IDOR:* toda operación publicada es legible por cualquier cuenta autorizada, y el rol solo limita escrituras: **T113-02 sigue exactamente igual** (aceptado en 10.47; ahora con el matiz de T-130 de que las fuentes nuevas también son legibles por el muelle, que es su trabajo). *API2 autenticación:* sesión por Firebase Auth; el token lo renueva el SDK; `verify()` recarga el usuario y cierra la sesión ante `user-token-expired` (`firebase_session_repository.dart:232-243`); la expiración no depende del código de la app. *API3 BOPLA:* los `hasOnly`/`hasAll` del movimiento, la operación y las fuentes dejan escribir exactamente lo declarado (1.2); el muelle no coloca el rol en `author`: la regla lo exige igual al de la lista (L367). *API5 autorización por rol:* la matriz completa probada en 1.3 y 1.4, incluido el «tras el cierre, nadie». *API8 configuración:* lo de la Web en 4.3.

**Android — OWASP Mobile Top 10 2024 y MASVS 2.1 (MASTG).** *Almacenamiento (MASVS-STORAGE-1/2):* Hive en el directorio privado de la app (`local_store_directory_io.dart`, por `MethodChannel`), `allowBackup=false` con reglas de extracción, sin credenciales en el almacén (abajo). *Plataforma (MASVS-PLATFORM):* permisos contra T-88 (4.1); los 5 exportados son del SDK, dos protegidos por permisos (T113-10 revalidado con `firebase_auth` 6.7.1). *Criptografía (MASVS-CRYPTO):* sin credenciales que proteger; la sesión de Firebase la guarda el SDK fuera de Hive. *Red (MASVS-NETWORK):* TLS del sistema; **sin fijación de certificados** (T141-08, informativo, como pide el plan). *Resistencia (MASVS-RESILIENCE):* el APK va con R8 (hay `mapping.txt`: el bytecode queda ofuscado y encogido) y el Dart compilado AOT en `libapp.so`; sin ofuscación deliberada del Dart — estándar de Flutter y suficiente para el piloto.

**Windows (MSIX, instalador, almacén) — Desktop App Security Top 10 (referencia comunitaria).** *D01 inyección:* los datos del BAPLIE nunca se evalúan; el fuzzing no encontró caídas. *D02 almacenamiento:* `%LOCALAPPDATA%\BayStream\vessel_store`, sin cifrar (T141-03), sin credenciales; la caja de sesión guarda uid, nombre y rol, **nunca** el correo ni la contraseña (`firebase_session_repository.dart:14-51`). *D03 protección de comunicación:* el SDK de C++ 13.13.1 con las raíces corregidas (T-136). *D04/5 permisos y actualizaciones:* MSIX con firma verificada y capacidades mínimas (4.2); el instalador sin firma (T141-02); no hay mecanismo de actualización automática (Play, Tienda o manual). *D06 registro:* como en la Web. *D08 firma:* el binario publicado está firmado; el instalador no.

**Entrada: el fuzzing del lector BAPLIE.** `tool/t141_fuzz_baplie.dart` (Dart puro, sin Flutter) toma los 4 archivos sintéticos de `test/fixtures/` y genera **180 mutantes** deterministas: truncados (4), segmentos duplicados (3), separadores rotos (4), caracteres fuera de ASCII (5: emoji, NUL, 0xFF, acentos, CJK), campos vacíos (3), longitudes absurdas (5: contenedor de 10 000 caracteres, segmento de 1 MB, 5 000 LOC, viaje de 100 000, fixture repetido hasta 2 MB) y 20 de azar con semilla fija por archivo. `dart run` con la luz verde (con su `SEMÁFORO:`): **salida 0. Ninguna excepción sin capturar, ningún cuelgue** (el caso más lento: 47 ms con 2 MB); 68 mutantes se leyeron (el lector es tolerante por diseño) y 112 se rechazaron con **20 mensajes distintos** con causa y acción («Versión BAPLIE no admitida… Pide una exportación compatible», «No se encontró el nombre del buque…»). Los cuatro controles se comportaron como la suite espera (los dos fixtures negativos, `t86_sin_unh` y `t86_smdg31`, rechazados). El lector de Excel (`export_list_parser_service.dart`) envuelve cada paso en `try/catch` con su excepción propia y acumula errores por fila: mismo estilo defensivo. Una nota sin severidad: los mensajes de versión citan el valor de la cabecera UNH mutada (p. ej. `BAPL�E`); es texto plano en Flutter, sin riesgo de inyección.

**Autenticación.** La política de contraseñas es la que imponga Firebase (las cuentas las crea Carlos en la consola; la app no llama a `validatePassword`). *Enumeración de correos:* los mensajes de inicio de sesión **no distinguen** cuenta inexistente de contraseña errada (`user-not-found`, `wrong-password` e `invalid-credential` caen en el mismo «Correo o contraseña incorrectos», `firebase_session_repository.dart:169-182`); «Olvidé mi contraseña» también responde igual para cualquier correo. La **protección de enumeración de la consola** está **activa** (Carlos la verificó en la consola el 4-nov; T141-06, resuelto). El mensaje «Esta cuenta está deshabilitada» sí revela que la cuenta existe (comportamiento de Firebase con `user-disabled`), menor y ligado al mismo ajuste.

**Integridad y registro.** App Check sigue sin apps registradas (T113-03, aceptado; no se puede ver desde el árbol). Lo que la app registra son códigos y mensajes de error del servicio, con el detalle técnico en el registro y no en pantalla (T-112); ningún registro filtra contenedores, correos ni UID.

## 6. Hallazgos y parches

Severidad con la escala de siempre (Crítica, Alta, Media, Baja, Informativa) y base CVSS aproximada. **Ninguno crítico ni alto.** Ninguno exige tocar código antes del 7-nov; los parches son de configuración o de decisión, y Carlos decide.

| # | Hallazgo | Lista OWASP | Sev. (CVSS≈) | Estado | Parche propuesto | ¿Antes del 7-nov? |
|---|---|---|---|---|---|---|
| **T141-01** | Hosting sin cabeceras de seguridad: sin CSP, `X-Content-Type-Options`, `X-Frame-Options`/`frame-ancestors`, `Referrer-Policy` ni `Permissions-Policy`. HSTS sí (con preload). **T113-04 confirmado en vivo** | Web A05 (Top 10:2025) | Baja (≈3.7) | **Pendiente** | En `firebase.json` (bloque `headers`, junto al de `Cache-Control`): `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY`, `Referrer-Policy: strict-origin-when-cross-origin`, `Permissions-Policy: microphone=(self)` y una CSP que permita `self`, `gstatic` (no: el SDK ya se sirve local), `firebaseio.com`/`googleapis.com` para Firestore/Auth, `unsafe-eval`/`unsafe-inline` solo si Flutter Web los pide (probarla primero en el emulador de Hosting) | **Después**: es un despliegue de Hosting y la demostración va con la Web ya publicada; si se toca, medir la carga de la app después |
| **T141-02** | El instalador con asistente va sin firma: descargado de internet, SmartScreen avisa «Windows protegió su PC» | Escritorio, firma (referencia comunitaria) | Informativa (≈3.3 con interacción social) | **Aceptado** (límite declarado de T-137) | Certificado de firma de código (cuesta dinero; proyecto de graduación) o repartir el MSIX firmado como vía principal, como ya hace la lista de la 1.0.0 | Después |
| **T141-03** | El almacén local (Hive) guarda planos, movimientos y perfil **sin cifrar** (Windows `%LOCALAPPDATA%\BayStream`, Android privado, IndexedDB en la Web). Sin credenciales: la caja de sesión guarda uid/nombre/rol, nunca correo ni contraseña | Móvil MASVS-STORAGE; Escritorio D02 | Informativa (≈2.3, acceso local) | **Pendiente de decisión** | Cifrar las cajas exige una dependencia nueva o un adaptador propio (fuera del alcance actual); la protección del equipo la da el SO y la carpeta es del usuario. La política de privacidad ya describe dónde se guarda | Después, si el piloto pide equipo compartido |
| **T141-04** | Un manifiesto puede declarar una fuente sin escribir sus trozos: la regla valida el documento de la operación, no el lote inverso. Solo la oficina puede hacerlo; el muelle que lee recibe «La fuente llegó incompleta o distinta» y no se guarda nada (fallo a favor del rechazo) | API API3 BOPLA | Informativa (≈2.7, requiere oficina maliciosa) | **Aceptado** (diseño de T-130: exigirlo costaría accesos por trozo) | Ninguno necesario; si se quiere, un `getAfter` del primer trozo en `validPlanAddition` (cuesta un acceso por adición) | No |
| **T141-05** | La Web devuelve `200` con la app para **cualquier** ruta desconocida (`rewrites: ** → /index.html`), incluidas `/.git/config` o `/build/`. No filtra contenido ni hay listado; solo confunde a escáneres y hace difícil ver 404 reales | Web A05 | Informativa | **Aceptado** (patrón normal de Flutter Web en Hosting) | Ninguno; si se quisera, un `trailingSlash`/404 propio, con el costo de romper rutas profundas de la SPA | No |
| **T141-06** | La protección de enumeración de correos de Authentication es un ajuste de la consola; no se probó en vivo, por regla. El cliente ya responde igual para cuenta inexistente y contraseña errada; «Esta cuenta está deshabilitada» sí delata que la cuenta existe | Web A07; API API2 | — | **Resuelto: activa, verificado por Carlos en la consola el 4-nov** | Ninguno | No hace falta |
| **T141-07** | Contenedores del corpus **anonimizado** en un archivo versionado más (`docs/entrega-7nov/BayStream_Documento1_Investigacion.docx`, 4 números, ya en `master`) y en la fuente sin versionar `docs/entrega-7nov/fuentes/DOC1.md`. T113-07 creció | — (higiene de datos) | Informativa | **Aceptado (Carlos, 4-nov)** | Ninguno: aceptados con el argumento de la anonimización (prefijos inventados y dígito de control recalculado; la figura del Documento 1 declara su origen y los otros tres números son las tareas del protocolo del Anexo B); `docs/entrega-7nov/fuentes/` no entra al repositorio | Decidida |
| **T141-08** | Sin fijación de certificados (certificate pinning) en Android | Móvil MASVS-NETWORK | Informativa | **Aceptado** (declarado en el plan) | Firebase no lo trae; implantarlo rompería las actualizaciones de certificado del backend. Declararlo en el documento técnico | No |

**Lo que esta tarea cerró o revalidó por sí misma:** T113-06 (resuelto: `output/` ignorado); T113-01 (el cotejo de las reglas de la 1.0.0, otra vez exacto); T113-10 (exportados revalidados tras el cambio a `firebase_auth` 6.7.1: los mismos cinco); H-07 (117 paquetes, 0 avisos, ahora con los SDK web y BoM).

### Los 13 de T-113, al 4-nov

| # | Hallazgo | Estado en T-141 |
|---|---|---|
| T113-01 | Cotejo de reglas publicadas | **Resuelto de nuevo**: la 1.0.0 publica la de T-130, `equal: true` (1.1) |
| T113-02 | Cualquier autorizada lee todas las operaciones | **Aceptado, sigue igual** (10.47); revalidado en las reglas de hoy (L133) |
| T113-03 | App Check sin registrar | **Aceptado, sigue igual** (10.49) |
| T113-04 | Hosting sin cabeceras de seguridad | **Pendiente, confirmado en vivo**; ahora T141-01, con el parche escrito |
| T113-05 | Opciones del temporal de H5 en la historia | **Aceptado** (H-04); hoy también: 520 commits revisados, sin claves nuevas |
| T113-06 | `output/pdf` sin ignorar | **RESUELTO**: `output/` en `.gitignore`, la carpeta ya no existe |
| T113-07 | Contenedores del corpus en archivos versionados | **Aceptado (Carlos, 4-nov)**, con el argumento de la anonimización; `docs/entrega-7nov/fuentes/` no entra al repositorio |
| T113-08 | Rutas de `baystream-privado` | **Aceptado** (62 archivos hoy; nunca el contenido) |
| T113-09 | Correo del autor en la política | **Aceptado** (contacto público, D2) |
| T113-10 | Exportados de Firebase Auth/Sign-In | **Aceptado y revalidado** con `firebase_auth` 6.7.1 (4.1) |
| T113-11 | Cloud Audit Logs sin verificar en producción | **Pendiente** (consola; fuera del alcance de esta tarea, como en T-113) |
| T113-12 | `runFullTrust` en el MSIX | **Aceptado**, verificado otra vez en el manifiesto 1.0.0.0 (4.2) |
| T113-13 | Reglas sin identidad en el temporal de H5 | **Aceptado** (riesgo residual; el proyecto no se tocó) |

### Los 7 de la línea base, al 4-nov

| # | Hallazgo | Estado en T-141 |
|---|---|---|
| H-01 | Reglas fuera de control de versiones | **Resuelto**: la 1.0.0 publica `docs/T130-firestore.rules.propuesta`, idéntica (1.1) |
| H-02 | Creación y actualización anónimas | **Resuelto en producción** (sesión + lista + roles); residual del temporal aceptado (T113-13) |
| H-03 | Reglas de prueba expiradas | **Resuelto** |
| H-04 | Credenciales en el código | **Cerrado en código** (cero claves en el árbol de la 1.0.0); residual de la historia aceptado |
| H-05 | Texto crudo de excepciones | **Resuelto** (T-112; el fuzzing volvió a ver solo mensajes con causa y acción) |
| H-06 | Sin registro ni alertas | **Pendiente para `baystream-app`** (T113-11; consola de Carlos) |
| H-07 | Sin análisis de dependencias | **Cerrado y repetido**: 117 paquetes, 0 avisos, más los SDK nativos (2) |

## Validaciones ejecutadas

| Comando | Resultado | Salida |
|---|---|---|
| `git log --oneline -8` / `git show --stat HEAD` | base confirmada (`63b5ac8`, solo docs después de `eddc388`) | 0 |
| `node tool/t113_reglas.mjs build/t141/reglas-publicadas-4nov.txt build/t141 docs/T130-firestore.rules.propuesta` | **`equal: true`**, `8B903949…` (copia fresca del 4-nov, pegada a las 20:03) | **0** |
| ídem contra `docs/T127-…` y `docs/T80-…` | distintos, con líneas señaladas | 1 y 1 |
| `powershell -File tool/t141_baterias.ps1` | emulador `demo-t141`:8383; **69/69, 25/25, 31/31, 38/38**; emulador cerrado | **0** |
| `node tool/t141_reglas_abuso.mjs 8383 demo-t141 build/t141/reglas-publicadas.txt` (con `T141_DETALLE=1`, emulador aparte) | **18/18**, con la regla de cada denegación | **0** |
| `node tool/t113_dependencias.mjs pubspec.lock build/t141` | 117 paquetes, 0 vigentes | **0** |
| `python -I tool/t113_secretos.py --corpus <anonimizados> --rama sprint-4 --salida build\t141 --privado %TEMP%\t141\revision-privada.json` | H-04 en historia + falsos positivos, revisados a mano (3) | 1 (esperada) |
| `flutter build apk --release` (copia limpia de `eddc388`, con `SEMÁFORO:`) | APK 68.0 MB, 270 s | **0** |
| `aapt dump permissions / badging / xmltree` | sección 4.1 | 0 |
| `signtool verify /pa /all` (instalador) | «No signature found» | 1 (esperada: sin firma) |
| `signtool verify /pa /all` (MSIX 1.0.0.0) | «Successfully verified» | **0** |
| `curl.exe -sI https://baystream-app.web.app/` | cabeceras (4.3) | 0 |
| `openssl s_client` (por defecto, `-tls1_2`, `-tls1_3`) | TLS 1.3 por defecto; certificado OK | 0 |
| descarga de los 3 módulos del SDK y `sha256sum` | iguales a `provenance.json` | 0 |
| `dart run tool/t141_fuzz_baplie.dart` (con `SEMÁFORO:`) | **180 mutantes: 0 fallas**, 68 leídos, 112 con mensaje | **0** |

No corrí la suite ni `analyze`: esta tarea no toca `lib/` ni `test/`; los scripts nuevos son de Node, PowerShell y un Dart de `tool/` que ya compiló y corrió.

**Evidencia local, ignorada por Git** (`build/t141/`): `reglas-publicadas-4nov.txt`, `reglas-publicadas.txt`, `reglas-cotejo.json`, `cotejo-contra-t130/t127/t80.log`, los cuatro `reglas-*-contra-publicadas.log`, `reglas-t141-abuso.log`, `baterias-resumen.json`, `emulador-salida/error.log`, `abuso-emulador.log`, `dependencias.md/json`, `secretos.json`, `apk-build.log`, `apk-permissions.txt`, `apk-badging.txt`, `apk-manifest.txt`, `msix-appxmanifest.xml`, `web-cabeceras.txt`, `web-tls.txt`, `web-sdk-huellas.txt`, `fuzz-baplie.json`. **Fuera del repo** (`%TEMP%\t141\`): `revision-privada.json` (los valores, para la revisión a mano; no se comparte), `apk-1.0.0\` (la copia limpia y su APK), `msix\`, `web\` (lo descargado) y `portafolio\` (las 4 capturas del público).

**Lo que dejé corriendo y apagué:** los dos emuladores (el de las baterías, cerrado por `taskkill /T` desde el script; el del abuso, detenido y con el puerto 8383 comprobado libre). Ningún cliente, ni el Honor, ni Chrome, ni la app.

## Horas

4-nov, hora de Guatemala: de **19:26 a 19:52**, ≈ **0.4 h** (primera y última evidencia en `build\t141\`: `reglas-publicadas.txt`, 19:26:17; `web-sdk-huellas.txt`, 19:52:24).

## Archivos de la tarea

Nuevos:

```text
tool/t141_baterias.ps1
tool/t141_reglas_abuso.mjs
tool/t141_fuzz_baplie.dart
docs/T141-SEGURIDAD-RESULTADOS.md
```

**No cambian:** `pubspec.yaml`, `pubspec.lock`, `lib/`, `test/`, `web/`, `android/`, `windows/`, `firebase.json`, las reglas ni ningún archivo de otro carril.

## Párrafo para el documento técnico

La auditoría final de seguridad de la versión 1.0.0 (compilación 9, publicada el 3 de noviembre de 2026) cubrió las reglas de Firestore, las dependencias, los secretos del repositorio, el empaquetado de los tres clientes y una revisión de caja blanca contra las listas OWASP vigentes. Las reglas publicadas resultaron idénticas a la propuesta auditada (huella SHA-256 `8B903949…`) y soportaron 181 casos de prueba en el emulador —las cuatro baterías heredadas (69 de forma, 25 y 18 de abuso, 31 de revisión del listado y 38 del plan agregado)—, todos con el resultado esperado. Las 117 dependencias y los SDK nativos no presentan avisos de vulnerabilidad vigentes, y el lector BAPLIE procesó 180 archivos mutados sin excepciones sin capturar ni bloqueos, respondiendo siempre con mensajes orientados al usuario. Los hallazgos abiertos son de severidad baja o informativa — cinco aceptados o sin parche necesario, dos pendientes de decisión y uno de configuración — y ninguno compromete la confidencialidad ni la integridad de los datos de una operación. La conclusión es que la versión 1.0.0 se encuentra en condiciones de presentarse el 7 de noviembre.

## Bloque de Git (lo ejecuta Carlos)

```bash
git add -- docs/T141-SEGURIDAD-RESULTADOS.md
git add -- tool/t141_baterias.ps1
git add -- tool/t141_reglas_abuso.mjs
git add -- tool/t141_fuzz_baplie.dart
git commit -m "Sprint 4: T-141, pruebas finales de seguridad de la 1.0.0"
git push
```

## Tres líneas

1. Lo publicado es lo auditado: reglas idénticas a la propuesta de T-130, MSIX e instalador con la huella de la 10.105/10.106, y el SDK de la Web con la huella de `provenance.json`.
2. 181 casos de reglas en el emulador (las cuatro baterías: 69/25/31/38, y 18 de abuso nuevos de T-130), 117 dependencias sin avisos y 180 mutaciones del lector BAPLIE: todo en verde, sin hallazgos críticos ni altos.
3. Queda T141-01 (cabeceras de Hosting, parche escrito en `firebase.json`); la protección de enumeración de correos está activa (T141-06, verificada por Carlos en la consola el 4-nov) y los contenedores del corpus del Documento 1 quedaron aceptados (T141-07, decisión de Carlos del 4-nov).

## Para Yov

> Yov: T-141 completa y cerrada. Las reglas publicadas son la de T-130, cotejadas contra una copia fresca de la consola del 4-nov (equal, `8B903949…`). Contra ese texto: 69/25/31/38 y 18 de abuso nuevos, todo esperado; la única holgura nueva documentada es el manifiesto sin trozos (solo oficina, lector a prueba de fallos, T141-04). Dependencias 0 avisos; C++ 13.13.1 y su motivo; Inno 7.1.1: corrige path-traversal de .cab/.vhd y trae el endurecimiento de PATH de DLL de la línea 7 (el DLL-hijack era de la 6.2.1). Secretos: T113-06 cerrado, los contenedores del corpus del Documento 1 aceptados por Carlos (T141-07, 4-nov; `fuentes/` no entra al repo), portafolio público limpio. La enumeración de correos quedó resuelta: Carlos verificó la protección activa en la consola (T141-06). APK limpio contra T-88, MSIX firmado, instalador sin firma (SmartScreen), Web con TLS 1.3 y HSTS pero sin CSP (T141-01, parche listo; única pendiente). Fuzz del lector: 180/180. Informe: docs/T141-SEGURIDAD-RESULTADOS.md.
