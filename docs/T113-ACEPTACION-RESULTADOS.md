# T-113 · Aceptación cruzada de las pruebas de seguridad

Capitán Codex · 21-oct-2026 · rama `sprint-3` · cabeza inspeccionada `664bf21f995e68b6f097a870a3b2cc24ce480689`.

**Dictamen: ACEPTADA para el alcance de T-113 y la entrega del 24-oct.** Reproduje **69/69** y **25/25** en una copia limpia, no encontré secretos nuevos respecto de H-04 y mi consulta independiente de dependencias no encontró avisos aplicables en las versiones cubiertas. **T113-01 está resuelto:** el texto aportado por Carlos coincide byte a byte con el blob del cierre y con las reglas probadas.

Los 13 hallazgos tienen respaldo y severidades razonables dentro del alcance declarado. No se demostró ninguna vulnerabilidad crítica ni alta. Esto no sustituye el pentest de 10.103 ni certifica ausencia de vulnerabilidades desconocidas. Quedan dos pendientes ya decididos: **T113-04**, para el pentest, y **T113-11**, comprobación de Carlos en consola o limitación declarada antes del 24. No bloquean esta aceptación conforme a 10.107–10.108.

## 1. Referencias, alcance y copia limpia

Leí `AGENTS.md`, la ficha completa de T-113, las decisiones 10.88, 10.102, 10.107 y su corrección posterior 10.108, y `docs/T113-SEGURIDAD-RESULTADOS.md` completo. La entrega inicial de Timonel es `af3f3ea`; la revisión incluye su cierre posterior del cotejo.

`git log --oneline -3` dio:

```text
664bf21 Sprint 3: decision 10.108, el cotejo cierra T113-01, las reglas de produccion son identicas a lo auditado
e491d76 Sprint 3: T-113 pruebas de seguridad, reglas publicadas identicas a la propuesta
13446b0 Sprint 3: decision 10.107, T-113 entregada sin vulnerabilidades criticas ni altas y decisiones de los 13 hallazgos
```

Preparé un archivo con `git -c core.autocrlf=false archive --format=tar --output=<temporal>/fuente.tar HEAD`, lo extraje con Python `tarfile` conservando UTF-8 y copié `.git` al temporal para que el detector pudiera consultar la historia sin modificar el repositorio original. No usé checkout, worktree, cambios de rama ni operaciones sobre el índice.

**Copia definitiva:** `%TEMP%\t113-aceptacion-20261021-172030\limpia-utf8`. Verifiqué los **888 archivos versionados**, ninguno ausente y **cero archivos sin versionar**, y comparé los bytes extraídos con cada archivo del archivo tar: todos iguales. La preparación quedó en `build/t113-aceptacion/preparacion.json`; `copia.txt` conserva la ruta absoluta. Las pruebas definitivas usan esta copia.

La comparación de solo lectura `git diff --name-only sprint3-cierre-2 HEAD -- lib pubspec.yaml pubspec.lock android/app/src web windows firestore.rules firebase.json` salió vacía. Los scripts de las dos baterías, el detector de secretos y el lock de trabajo coinciden con la copia limpia al normalizar CRLF. Tampoco aparecieron cambios de trabajo en `lib/`, `test/` ni `pubspec.*`.

**Límites respetados:** no modifiqué producto, dependencias ni configuración de Firebase. No consulté Firebase de producción, su consola, la Web publicada, las cuentas reales ni el almacén local. No ejecuté Flutter ni abrí clientes. RNF-004 sigue **no medible**, citado de T-98 y 10.105; no se repitió.

## 2. Reglas: repetición independiente

Usé Firestore Emulator **1.22.0**, Java de Android Studio y el lanzador de la copia limpia, con idioma inglés. El destino fue exclusivamente **`http://127.0.0.1:8281`**, proyecto **`demo-t113-acc`**. El emulador arrancó sin archivo de reglas configurado; cada batería carga explícitamente `docs/T80-firestore.rules.propuesta` por la API del emulador, comprueba esa carga y borra sus datos antes de sembrar sus cuentas ficticias.

Comandos sobre la copia limpia:

```powershell
powershell -NoProfile -File "$copia\tool\t113_emulador.ps1" -Proyecto demo-t113-acc -Puerto 8281
node "$copia\tool\t80_reglas.mjs" 8281 demo-t113-acc
$env:T113_DETALLE = '1'
node "$copia\tool\t113_reglas_abuso.mjs" 8281 demo-t113-acc
```

| Verificación | Resultado propio | Evidencia en `build/t113-aceptacion/` |
|---|---|---|
| Batería de T-80 | **69/69**, salida 0 | `reglas-bateria.log` |
| Idempotencia y cantidad final | **16/16 documentos** de movimientos | `reglas-bateria.log` |
| Abuso de T-113 | **25/25**, salida 0 | `reglas-abuso.log` |
| Denegaciones | Todas las esperadas devuelven **403**; ninguna se aceptó por un 404 o un error 500 | Ambos registros |
| Motivos de abuso | Denegaciones con detalle de las reglas; sin aviso del límite de expresiones | `reglas-abuso.log` |

Los casos respaldan la protección de la lista de autorizados, los roles tomados de esa lista, la autoría de operaciones y movimientos, la inmutabilidad y el cierre por defecto. El cambio directo de posición de la oficina sin solicitud se permite como requiere T-81. Revisé además las llamadas de `firebase_session_repository.dart`, los sobres de `firestore_operation_sync.dart` y las condiciones de las reglas: no encontré una contradicción con el cotejo de Timonel.

**Cierre del entorno:** detuve únicamente el Java del emulador de aceptación, PID 25532, tras comprobar su ejecutable, JAR y puerto. La CLI terminó y apagó el hub. No quedaron escuchas en 8281, 4400, 4500 ni 9150. El mensaje final de salida forzada del emulador corresponde a ese cierre intencional, después de las pruebas.

## 3. T113-01: cotejo cerrado y alcance de la procedencia

Repetí `tool/t113_reglas.mjs` desde la copia limpia contra `build/t113/reglas-publicadas.txt`: **salida 0, `equal: true`, sin diferencias**. Hice también una comparación propia de bytes, con `subprocess.check_output(['git', 'show', 'sprint3-cierre-2:docs/T80-firestore.rules.propuesta'])`, sin pasar el contenido por la codificación de PowerShell.

Los tres contenidos son idénticos: blob del cierre, propuesta en la copia limpia y texto aportado por Carlos. Cada uno tiene **13 258 bytes** y SHA-256:

```text
7E57F227BADC118F823265B0CFE9FF0E9A067F39F5AD387C932AD901F894F125
```

La referencia `21894B7F…` corresponde a la copia de trabajo con finales mezclados, no al blob LF. No hay discrepancia lógica pendiente. Evidencias: `cotejo/reglas-cotejo.json`, `reglas-cotejo.log` y `cotejo-independiente.json`.

**Procedencia:** el archivo local conserva el texto que Carlos pegó en el chat, según el informe y 10.108. Mi comprobación confirma ese texto; no realicé una exportación ni una consulta independiente a producción. Esta limitación está declarada y coincide con el cierre autorizado en 10.108.

## 4. Secretos: repetición y revisión de candidatos

Ejecuté sin modificar `tool/t113_secretos.py` de la copia limpia, con el corpus externo anonimizado y con los valores de revisión fuera del repositorio:

```powershell
python -I "$copia\tool\t113_secretos.py" --corpus <carpeta-anonimizada> --salida <repo>\build\t113-aceptacion\limpia-utf8 --privado <temporal>\revision-privada-limpia-utf8.json
```

Resultado propio: **888 archivos versionados, cero sin versionar, 1 852 blobs y 362 commits**, corpus de **18 archivos y 4 521 identificadores**. El crecimiento respecto de los 358 commits y 1 840 blobs de Timonel corresponde a las cuatro confirmaciones posteriores. El proceso sale con **1**, porque el detector marca candidatos conocidos, falsos positivos y contenido del corpus; no es una ejecución sin hallazgos que deba salir con 0.

| Detector | Comprobación propia | Dictamen |
|---|---|---|
| Clave de Google | Cero en el árbol; una clave distinta en dos blobs históricos de `lib/main.dart` | **H-04 conocido**, sin candidato nuevo |
| Claves privadas, cuentas de servicio, tokens GitHub/API, JWT, refresh tokens | Cero | Sin hallazgos |
| Archivos protegidos y archivos idénticos al corpus | Cero | Sin hallazgos |
| Firma de Android | `android/app/build.gradle.kts` y `android/key.properties.example`, cuatro coincidencias | Lecturas de propiedades y textos de sustitución; falsos positivos |
| Contraseña literal | Siete coincidencias en `web/vendor/firebase/12.17.0/firebase-auth.js` | Mismos candidatos del SDK que Timonel; falso positivo |
| Contenedores del corpus | Nueve archivos en árbol e historia | T113-07; aceptado en 10.107 |
| Rutas privadas y nombre del archivo de configuración | Solo referencias de ruta; sin su contenido | T113-08; informativo |

Comparé en privado los conjuntos de valores de los detectores de credenciales con la revisión original de Timonel: **cero valores nuevos** en todos ellos. Comprobé las rutas de H-04 y de los falsos positivos. Solo guardé las cuentas y rutas en la evidencia compartible: `secretos-revision-sin-valores.json`; no se reproducen valores sensibles en este informe.

También ejecuté el detector sobre el árbol original para cubrir sus archivos ajenos sin versionar: **7**, ninguno con un candidato nuevo de credenciales. Los valores de esa revisión quedaron en el temporal. Sus documentos no fueron modificados. Evidencias: `secretos-limpia.log`, `limpia-utf8/secretos.json`, `secretos-arbol.log` y `arbol/secretos.json`.

**Límite del detector:** PDF y otros binarios se revisan por nombre y huella, no mediante extracción íntegra de su contenido. Se mantiene ese alcance del informe original. Las claves de identificación de Firebase no equivalen por sí solas a credenciales de autorización; sus restricciones y los controles del proyecto importan, según la [documentación de Firebase](https://firebase.google.com/docs/projects/api-keys). No comprobé esas restricciones en producción.

## 5. Dependencias: método propio y fuentes actuales

No usé el comparador de rangos de Timonel para emitir mi dictamen. Preparé un script independiente de Python, solo con la biblioteca estándar: parseo del lock de la copia limpia, consulta por versión exacta a la [API OSV querybatch](https://google.github.io/osv.dev/post-v1-querybatch/), comprobación de cardinalidad de respuestas y de ausencia de páginas pendientes, y descarga paginada del catálogo público de GitHub Advisory para Pub. No usé credenciales.

| Cobertura | Resultado propio |
|---|---|
| Lock | **117** paquetes: 109 de pub.dev y 8 del SDK; 16 directos de producción, 4 de desarrollo y 97 transitivos |
| OSV por versión exacta | **109/109** paquetes de Pub consultados, cero afectados |
| Referencias nativas | npm `firebase` **12.17.0** y Maven `com.google.firebase:firebase-bom` **34.17.0**: cero avisos aplicables |
| Control vulnerable `http` 0.13.2 | Detectó **GHSA-4rgh-jx4f-qfcq** |
| Control vulnerable `archive` 3.3.7 | Detectó **GHSA-9v85-q87q-g4vg** y **GHSA-r285-q736-9v95** |
| GitHub Advisory | **14 avisos Pub** descargados; tres se refieren a paquetes del lock, todos fuera de rango |
| Red y estructura de respuestas | Sin fallos; las tres respuestas OSV dieron HTTP 200 |

El cruce de GitHub solo encuentra `archive <= 3.3.7`, frente a **4.0.9** del lock, y `http < 0.13.3`, frente a **1.6.0**. `intl` **0.20.2** está entre los 109 consultados y no tiene avisos aplicables. Los controles evitan interpretar una respuesta vacía por un método roto como un resultado favorable.

**Cobertura que no debe exagerarse:** los ocho paquetes del SDK, incluido `flutter_localizations`, se distribuyen con Flutter, sin una versión independiente de pub.dev que permita certificar su SDK mediante estas consultas. La referencia instalada declarada por Timonel es Flutter 3.38.9 / Dart 3.10.8. Firebase C++ **13.9.0** conserva la falta de cobertura declarada. Consultar la BoM y el paquete npm principal tampoco equivale a auditar todos los artefactos Maven/npm transitivos resueltos de una compilación. El resultado defendible es **cero avisos conocidos aplicables en las versiones consultadas**, con esas limitaciones.

Evidencia reproducible local: `dependencias_independiente.py`, `dependencias-independiente.json` —consultas, respuestas y catálogo— y `dependencias-salida.log`, bajo `build/t113-aceptacion/`. El script propio salió con **0**.

## 6. Cotejo de los 13 hallazgos y severidades

Contrasté los hallazgos con las fuentes y con las decisiones vigentes. La tabla siguiente actualiza los estados históricos de la sección 6 de Timonel sin modificar su informe ni los documentos mantenidos por Yov.

| Hallazgo | Evidencia contrastada y juicio de severidad | Estado vigente |
|---|---|---|
| **T113-01** | Comparación propia de bytes y SHA, sección 3; es evidencia pendiente, sin severidad de vulnerabilidad | **Resuelto**, 10.108 |
| **T113-02 · Media** | `allow get, list: if isAuthorized()` para operaciones, fuentes y movimientos, sin filtro por operación; la política y 10.47 declaran esa lectura común. La exposición potencial entre autorizados justifica Media | **Aceptado**; revisar el alcance antes de dar acceso a terceros/revisor de Play |
| **T113-03 · Baja** | La consulta de Carlos del 15-oct, documentada en 10.49 y `docs/T88-DECLARACIONES-PLAY.md`, confirma App Check y Fraud Defense inactivos. Las reglas siguen exigiendo la lista. Baja es razonable como protección adicional ausente; no se verificó de nuevo en producción | **Aceptado** |
| **T113-04 · Baja** | `firebase.json` solo configura `Cache-Control`. La ausencia de las cabeceras citadas es comprobable; no demuestra por sí sola un ataque. Baja es razonable para este hallazgo de endurecimiento | **Pendiente para el pentest**, A05 de 10.103; no cambiar antes del 24, 10.107 |
| **T113-05 · Informativa** | La búsqueda propia reproduce una clave de identificación de Firebase en dos blobs históricos y cero en el árbol. Es H-04, ya declarado; no hay credencial nueva demostrada | **Aceptado** |
| **T113-06 · Baja** | La exposición accidental por archivos generados sin ignorar estaba sustentada. Ahora `git check-ignore -v` confirma `output/` y `git ls-files -- <los dos PDF>` no devuelve rutas | **Resuelto** por 10.107; no mover ni borrar los PDF |
| **T113-07 · Informativa** | Se reproducen los nueve archivos; `docs/S3-CASO-MAGELLAN-STAR.md` explica la anonimización. 10.107 acepta esos identificadores y recuerda que el repositorio pasó a privado en 10.41 | **Aceptado**; documentos nuevos con sintéticos |
| **T113-08 · Informativa** | El detector reproduce referencias de rutas, no archivos protegidos ni sus contenidos. A esta cabeza son 56 archivos con la ruta privada y 46 con el nombre de configuración, frente a los 54/45 del informe inicial | **Aceptado**; variación documental de cuentas, sin secreto nuevo |
| **T113-09 · Informativa** | Cinco archivos y seis apariciones en el árbol del correo del autor; contacto publicado deliberadamente en política y material de trabajo | **Aceptado** |
| **T113-10 · Informativa** | Volví a extraer permisos y manifiesto del APK que Timonel compiló del cierre; coinciden los componentes exportados y las protecciones por permiso de los servicios indicados. Su presencia no demuestra explotación | **Aceptado**; revisar si cambia `firebase_auth` |
| **T113-11 · Baja** | Es una ausencia de verificación de H-06, no evidencia de que los logs estén desactivados. No se inventa evidencia de consola; Baja conserva el criterio de la línea base | **Pendiente** de Carlos: verificar Cloud Audit Logs o declarar la limitación antes del 24 |
| **T113-12 · Informativa** | Extraje `AppxManifest.xml` del MSIX existente: `internetClient` y `runFullTrust`. El YAML declara `internetClient`; el paquete Win32 declara además ejecución con permisos del usuario | **Aceptado**; no es aislamiento en AppContainer |
| **T113-13 · Baja** | `firestore.rules` de H5 permite operaciones concretas sin identidad, conforme al residual conocido. Está separado del texto de producción probado; no se halló una exposición nueva de datos sensibles | **Aceptado** dentro de ese uso temporal; retirarlo cuando H5 deje de necesitarlo |

**Balance vigente:** 2 resueltos, 9 aceptados y 2 pendientes. Se conservan las severidades originales: **0 críticas, 0 altas, 1 media, 5 bajas y 6 informativas**, más T113-01 sin severidad. El informe inicial llama público al repositorio y deja T113-06/T113-07 pendientes; **10.41 y 10.107 prevalecen**. Son actualizaciones documentales, no un hallazgo nuevo ni un motivo para reabrir el cotejo.

### Comprobaciones adicionales de permisos

Revisé el APK existente de `%TEMP%\t113\apk-f631efa\build\app\outputs\flutter-apk\app-release.apk`, sin recompilarlo. Su SHA-256 es `559C0A7BA8396A588C7C244FB4882A9606D12C9C1A31075F4CAED7F02F08C9C2`, coincidente con la huella abreviada de Timonel. `aapt` 36.1.0 confirma `RECORD_AUDIO`, `INTERNET`, `ACCESS_NETWORK_STATE`, `READ_GSERVICES` y el permiso propio de receptor; también `allowBackup=false` y `dataExtractionRules`, sin `debuggable` ni `usesCleartextTraffic` explícitos. La compilación sigue siendo evidencia de Timonel; la extracción y el cotejo son propios.

El MSIX revisado es `build/t93/BayStream_1.0.4.0.msix`, del 15-oct, como declara el informe original: no es una compilación nueva del cierre. En Web, el proveedor de voz y `SpeechToTextRecognizer.start()` respaldan la inicialización tras la acción del usuario, y `departure_baplie_page.dart` usa `Clipboard.setData` en su acción de copia. No hice una prueba nueva de permisos del navegador ni afirmo haber comprobado cabeceras en vivo. Evidencias: `apk-permisos.log`, `apk-manifest.log` y `cotejo-independiente.json`.

## 7. Entrega, archivos y bloque de Git

**Único archivo nuevo para versionar:** `docs/T113-ACEPTACION-RESULTADOS.md`.

Las salidas y el script independiente están en **`build/t113-aceptacion/`**, ignorado por `/build/` de `.gitignore`; son evidencia local y no entran en el bloque de Git. La copia limpia y los JSON con valores de revisión permanecen en el temporal, fuera del repositorio. No se modificaron los archivos ajenos. **No cambian `pubspec.yaml` ni `pubspec.lock`.** No se corrieron suite Flutter ni `analyze`: no hubo cambios de producto, y se ejecutaron las verificaciones Node/Python y de manifiestos que corresponden a esta aceptación.

Comandos para que **Carlos** los ejecute; Codex no los ejecutó:

```powershell
git add -- docs/T113-ACEPTACION-RESULTADOS.md
git commit -m "T-113: acepta las pruebas de seguridad y confirma el cierre del cotejo"
git push
```

### Tres líneas del cambio

Se documenta la aceptación cruzada con 69/69 y 25/25 reproducidos en una copia limpia.
Se confirma T113-01 y la ausencia de secretos nuevos y de avisos aplicables dentro de la cobertura consultada.
Se actualizan los 13 hallazgos según 10.107–10.108, con dos pendientes declarados y sin cambios de producto.

### Mensaje para Yov

> Yov: Capitán Codex acepta T-113 sobre `664bf21`, incluida la corrección de 10.108. En copia limpia repetí 69/69 y 25/25, sin secretos nuevos aparte del H-04 conocido; la consulta independiente a OSV y el cruce de GitHub no hallaron avisos aplicables en las versiones cubiertas. T113-01 queda confirmado con igualdad byte a byte y SHA `7E57F227…`, sobre el texto que aportó Carlos. Los 13 hallazgos tienen evidencia y severidades razonables: 2 resueltos, 9 aceptados y 2 pendientes. T113-04 sigue al pentest; T113-11 requiere que Carlos mire los logs o declare la limitación antes del 24. Quedan explícitas las limitaciones del SDK, C++, binarios y procedencia del texto. Informe: `docs/T113-ACEPTACION-RESULTADOS.md`. Sin cambios en `lib/`, `test/`, `pubspec.*` ni Firebase de producción; emulador apagado. Carlos conserva Git y las publicaciones.
