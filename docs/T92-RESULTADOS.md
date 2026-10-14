# T-92 · Web sin conexión con motor, fuentes y Firebase locales

Fecha: 14-oct-2026. Responsable: Capitán Codex. Rama de trabajo: `sprint-3`.
Base inspeccionada: `45fc3c3`, seguida de `11e09c3` y `ad4ac43`.

## Resultado

Implementación y comprobación de Codex completas. La Web arranca tras una visita
con red, con el servidor detenido: Chrome de la laptop (también incógnito) y Chrome
del Honor reabren A07 desde Recientes. La aceptación independiente del lote por
Timonel sigue correspondiendo a su revisión; este informe no la sustituye.

El recorrido completo de A07 en Chrome visible pidió ocho recursos de código o
fuentes externos con HEAD y cero con T-92. La sincronización real de «PRUEBA T-84»
conservó los conteos y pasó de «Al día» a «Conectando…» al bloquear terceros, y a
«Al día» al permitirlos otra vez. La compilación 93 sustituyó a la 92 y volvió a
abrir A07 sin servidor. No se publicó nada.

Validaciones: **655 pruebas = piso 648 + 7 nuevas; analyze en cero; corpus 116/116;
verificadores correctos sobre final y actualización; 126 archivos protegidos sin
diferencias SHA-256**. `pubspec.yaml` y `pubspec.lock` no cambian.

## Implementación y mecanismos comprobados

Se inspeccionaron el motor de Flutter **3.38.9**, revisión
`587c18f873b8ab57330422bce09047420d9c7f42`, y los paquetes resueltos del caché de
pub. `firebase_core_web 3.10.0` exige **Firebase JS 12.17.0**. Su `_initializeCore`
retorna si ya existe `window.firebase_core`; las inicializaciones de Auth y
Firestore registran `firebase_auth` y `firebase_firestore`. Firestore utiliza
`firebase-firestore-pipelines.js`, no un nombre supuesto de memoria.

La nueva plantilla `web/flutter_bootstrap.js`:

1. Usa `canvasKitBaseUrl` hacia `canvaskit/` y `fontFallbackBaseUrl` hacia `fonts/`,
   relativas a `document.baseURI`. El motor instalado admite ambas opciones.
2. Conserva los tokens de generación de Flutter y su versión de service worker.
3. Espera que el service worker controle el primer cliente antes de importar el
   SDK; tiene un límite de cuatro segundos para no esperar indefinidamente en
   entornos donde el controlador no llega.
4. Pide una vez la raíz `./` mediante el service worker original. Luego importa
   core y, después, Auth/Firestore; asigna los tres globales antes de
   `initializeEngine` y `runApp`.

Los tres bundles oficiales de Firebase se sirven bajo
`web/vendor/firebase/12.17.0/`. Sus únicas dependencias de módulo son
`firebase-app.js`. La URL absoluta de ese módulo se reemplazó por
`./firebase-app.js`, incluidas sus apariciones en comentarios. Los tres servicios
comparten la misma instancia de app. No se modificaron opciones de Firebase,
autenticación, reglas ni código Dart de la aplicación.

Se sirven Roboto v32, Noto Sans Symbols v43 y Noto Sans Symbols 2 v24, en las rutas
del motor y del inventario observado. Las fuentes del PDF siguen siendo sus TTF
existentes. No se declara ninguna familia en `pubspec.yaml`; Android y Windows no
se recompilaron ni cambiaron de tipografía.

Cada tercero tiene URL, SHA original/servido y referencia a su licencia en
`provenance.json`; los dos `LEEME.md` explican la actualización. Core conserva su
cabecera de licencia. Los bundles originales de Auth y Firestore no traían esa
cabecera; se les asocia el `LICENSE.txt` oficial del proyecto, con sus avisos.

El título, título de Apple, nombre corto, nombre y descripción de la Web quedan
como BayStream y en español; `lang` es `es`. Los íconos conservan sus bytes.

El verificador compara el service worker generado con la plantilla instalada de
Flutter, sustituyendo exclusivamente `RESOURCES` y `CORE`. También comprueba sus
hashes, los módulos, las fuentes, las rutas del motor y la ausencia de archivos
sobrantes, incluidos `t54-format.*`. No se agregó service worker propio, Workbox,
npm ni dependencia de producción. `firebase.json` permanece intacto.

Referencia del mecanismo de plantilla:
[inicialización Web de Flutter](https://docs.flutter.dev/platform-integration/web/initialization).
El problema conocido al servir imports absolutos se contrastó con
[flutterfire #12204](https://github.com/firebase/flutterfire/issues/12204) y con
los bundles/paquetes realmente resueltos; la implementación no depende solamente
de la descripción de ese issue.

## Primer intento y corrección de la raíz

La primera aceptación en el Honor, puerto 8195, falló al recargar sin servidor
(`ERR_FAILED`). El worker original precarga `index.html`, pero su `onlineFirst`
busca la URL de navegación `/`. La primera navegación aún no tenía controlador,
por lo que la entrada `/` no existía aunque los módulos sí estaban guardados.

La corrección fue la única petición a `./` descrita arriba, después de obtener el
controlador. La respuesta queda guardada por el mismo worker de Flutter. No hay
acceso directo a `caches`, precarga de todo el sitio ni worker modificado. Se
recompiló y repitió la aceptación desde un origen nuevo, 8196 en el Honor y 8197
en Chrome. Después pasó también en incógnito, 8198.

Una visita con red fue suficiente en esos orígenes limpios con T-92. En el origen
8193 usado primero con HEAD, migrar desde su bootstrap anterior necesitó una
segunda recarga con red para dejar de servir el anterior. Esa migración de caché
existente no se presenta como la prueba desde almacenamiento vacío.

## Inventario antes y después

El recorrido comparable se repitió en **Chrome de la laptop visible**, HEAD en
8200 y final en 8197: cargar el original A07, GTSTC, «No lo tengo», Lista, Bay Plan,
Estadísticas y Avance, ambos temas, y exportar PDF. Las observaciones previas del
navegador integrado se conservaron como apoyo. Los PDF de ambos recorridos Chrome
se generaron: **145 775 bytes cada uno**; igualdad de tamaño no implica igualdad
binaria del PDF.

La instrumentación es solo del servidor de aceptación: un `PerformanceObserver`
registra recursos en un nodo DOM oculto. No altera el sitio compilado. Elimina
consultas y fragmentos; para servicios externos conserva solo dominio y la etiqueta
`/[servicio]`. No registra cuentas, UID, contraseñas, cuerpos ni tokens.

| Recurso | HEAD | T-92 | Bytes del contenido sin comprimir, HEAD → T-92 |
| --- | --- | --- | ---: |
| CanvasKit JS chromium | `www.gstatic.com/flutter-canvaskit/<motor>/chromium/canvaskit.js` | `/canvaskit/chromium/canvaskit.js` | 86 256 → 86 256 |
| CanvasKit WASM chromium | mismo origen Google, `canvaskit.wasm` | `/canvaskit/chromium/canvaskit.wasm` | 5 708 955 → 5 708 955 |
| Roboto v32 | `fonts.gstatic.com/s/roboto/v32/…woff2` | `/fonts/roboto/v32/…woff2` | 63 464 → 63 464 |
| Noto Sans Symbols v43 | `fonts.gstatic.com/s/notosanssymbols/v43/…woff2` | `/fonts/notosanssymbols/v43/…woff2` | 69 116 → 69 116 |
| Noto Sans Symbols 2 v24 | `fonts.gstatic.com/s/notosanssymbols2/v24/…woff2` | `/fonts/notosanssymbols2/v24/…woff2` | 382 716 → 382 716 |
| Firebase core 12.17.0 | `www.gstatic.com/firebasejs/12.17.0/firebase-app.js` | `/vendor/firebase/12.17.0/firebase-app.js` | 104 893 → 104 811 |
| Firebase Auth 12.17.0 | mismo origen Google, `firebase-auth.js` | `/vendor/firebase/12.17.0/firebase-auth.js` | 156 871 → 156 830 |
| Firebase Firestore 12.17.0 | mismo origen Google, `firebase-firestore-pipelines.js` | `/vendor/firebase/12.17.0/firebase-firestore-pipelines.js` | 751 269 → 751 228 |
| Aplicación Dart | `/main.dart.js` | `/main.dart.js` | 4 798 729 → 4 798 729 |
| Bootstrap | `/flutter_bootstrap.js` | `/flutter_bootstrap.js` | 9 739 → 11 695 |
| Manifiesto web | `/manifest.json` | `/manifest.json` | 949 → 1 005 |
| FontManifest | `/assets/FontManifest.json` | igual | 82 → 82 |
| MaterialIcons | `/assets/fonts/MaterialIcons-Regular.otf` | igual | 16 484 → 16 484 |
| Roboto del PDF, regular/medium | `/assets/assets/fonts/Roboto-*.ttf` | igual | 171 676 / 172 064, sin cambio |
| Favicon / icono 192 | origen propio | origen propio | 917 / 5 292, sin cambio |
| Petición explícita a `/` | no existe | origen propio | 2 334 en servidor instrumentado |

HEAD: **18 registros, 17 URLs distintas, ocho externas de código/fuentes** (el
favicon se pidió dos veces). Final: **18 registros, 18 URLs distintas, cero
externas**. La petición explícita a la raíz explica la URL distinta adicional.

Estos recursos representan **12 499 472 bytes antes y 12 503 654 después** de
contenido distinto sin comprimir del recorrido. Se sumaron tamaños de archivos
oficiales/compilados para los recursos que el navegador no expone; la raíz usa
el tamaño observado de la respuesta instrumentada. Son una comparación de
contenido solicitado, no una medición de bytes que cruzaron la red en una primera
visita totalmente fría. No incluyen encabezados, tráfico de instalación del SW ni
la navegación inicial. El observador devolvió numerosos `transferSize=0` por
caché/SW y restricciones entre orígenes; sus sumas parciales (401 113 frente a
20 109) **no** demuestran ahorro de red y no se usan como tal. Aproximadamente
12.5 MB de recursos distintos pasan a poder obtenerse del propio sitio; el
contenido necesario sigue siendo casi el mismo. Queda explícita esta limitación
de la medición de transferencia de primera visita.

### Servicios externos que permanecen

El recorrido local de A07 sin sesión no produjo solicitudes de servicios externos.
En la sesión real de muelle, antes y después, se observaron:

| Dominio | Clasificación y propósito |
| --- | --- |
| `identitytoolkit.googleapis.com` | Datos de Firebase Auth: validación/recuperación de la sesión de cuenta existente. |
| `firestore.googleapis.com` | Datos de Firestore: lectura y escucha de la operación compartida. |

No son módulos de código ni fuentes. No se observó `securetoken.googleapis.com`
en estas capturas; no se afirma que el servicio nunca pueda usarse. La voz no se
ejercitó en T-92: este resultado no cambia las limitaciones del micrófono/servicio
de voz de T-88.

## Arranque sin red

La cifra exacta esperada de A07 es **6 940 578 kg**. La pantalla la redondea a
**6940.6 t**; no se atribuye a la interfaz una precisión que no muestra. El corpus
116/116 confirma los datos exactos. En GTSTC: **0 cargan / 114 descargan / 284 de
paso**, con **398 contenedores y 21 bahías**.

| Prueba | Procedimiento | Resultado y evidencia |
| --- | --- | --- |
| Chrome laptop, origen vacío 8197 | Una visita; recorrido A07 completo; respuesta con CSP que bloquea terceros; detener servidor y comprobar ausencia de listener; recargar y abrir Recientes. | Abrió A07 con las cifras anteriores, texto e iconos completos; consola sin avisos de fuentes/caracteres. Captura y árbol de accesibilidad guardados. Es el perfil habitual con un origen nuevo, no se confunde con un perfil limpio completo. |
| Chrome laptop, incógnito 8198 | Carlos abrió incógnito y A07 en una visita. CSP de aceptación activa. Codex detuvo el servidor y confirmó cero listeners; Carlos recargó y reabrió A07 desde Recientes, revisando Lista/Bay Plan. | Carlos confirmó que abre bien, conserva todas las cifras y no presenta recuadros. Su captura muestra el indicador Incógnito. La extensión no expuso esa pestaña a Codex: interacción manual de Carlos, no automatizada. |
| Chrome Honor, origen nuevo 8196 | Honor reservado con Carlos; `adb reverse`; una visita al servidor y A07, GTSTC/«No lo tengo». Detener servidor; Carlos activa modo avión y apaga Wi-Fi; recarga, Recientes y abre A07. | A07 completo observado por Codex en captura/XML sanitizado, con 398/21, 6940.6 t y 0/114/284. Ajustes leídos: modo avión 1, Wi-Fi 0. El servidor no escuchaba. Sin recuadros visibles; consola del teléfono no accesible por estas herramientas, no se declara revisada. |
| Navegador integrado, 8196 | Visita nueva, detener servidor, recargar. | Abrió la pantalla inicial con cero avisos de consola; comprobación adicional del defecto de la raíz. |

La CSP de prueba se establece únicamente en `tool/t92_server.dart
--block-external`: conexiones, módulos, fuentes y frames externos quedan bloqueados
en esa página. La respuesta guardada conserva la cabecera. No se modifican DNS,
proxy, cortafuegos ni red de la laptop. La cabecera fue comprobada antes de detener
8198 (`build/t92/incognito-csp.json`). No es una política de producción;
[MDN: connect-src](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Content-Security-Policy/connect-src)
documenta el bloqueo de fetch/XHR.

Carlos revisó y copió la consola de incógnito tras la recarga: **ningún aviso de
fuentes, glyph o caracteres sin fuente**. Sí aparecieron `ERR_FAILED` del favicon
y rechazo de `manifest.json` en el fetch del worker, además de registros normales
de apertura de los almacenes IndexedDB. Esos dos recursos decorativos/metadatos se
piden inicialmente antes de que el SW controle el cliente y no forman parte de
CORE; no quedaron guardados en esa primera visita. La app y A07 sí arrancaron.
Se conserva el resultado tal cual: no se promete instalación/PWA completa offline
ni se introduce precarga adicional para ocultar estos errores.

El almacén de estas pruebas Web fue **IndexedDB del origen de cada navegador**,
con almacenes `baystream_profiles`, `baystream_voyages`, `baystream_settings` y los
de operación/sesión/movimientos/dispositivo. No se usó el almacén de Windows ni la
app Android nativa. Incógnito es temporal: cerrar todas sus ventanas elimina sus
datos; la recarga se hizo sin cerrarlas.

### Honor: privacidad y limpieza

Los ajustes de red y las navegaciones fueron realizados por Carlos. La revisión
automática rechazó el comando ADB combinado de preparación y el lanzamiento de
Chrome (`am start`) con motivo «blocked by policy»; no dio un motivo más específico.
Se entregaron esas acciones a Carlos. Los volcados posteriores se filtraron antes
de guardar/capturar: si aparecían contraseña, diálogos de guardado, cuentas/Drive o
correo, no se guardaba el volcado ni se capturaba la pantalla.

La única copia del corpus en el teléfono fue
`/sdcard/Download/T92_CORPUS_A07.edi`; se eliminó y se comprobó que ya no existe.
Los reverse añadidos por T-92 (8195 y 8196) se retiraron: cero mapas propios restantes.
Se apagaron todos los servidores propios: cero listeners en los puertos de T-92.
No se afirma haber
restaurado Wi-Fi a un valor inicial desconocido; Carlos conserva el control de esos
ajustes. No se copiaron corpus ni sus salidas al repositorio.

## Sincronización y actualización

Carlos inició personalmente la sesión de muelle en el navegador integrado 8193.
No se leyeron ni anotaron correo, UID o contraseña. Solo se abrió la operación
autorizada **PRUEBA T-84**, en `baystream-app`; no se registraron movimientos.

HEAD y SDK local: **4 contenedores, 3 bahías, 20.0 t; GTSTC 0 cargan / 3 descargan /
1 de paso**, estado **Al día**. Para comprobar pérdida de conexión de Firebase se
reinició únicamente el servidor local con la CSP de aceptación y se recargó la
página, conservando la sesión y el viaje: **Conectando…**, mismos conteos. Al quitar
la CSP y recargar, volvió a **Al día**, con los mismos datos. La sesión se conservó;
la red de la máquina permaneció intacta. Evidencia: `sync-blocked-start.txt/.png` y
`sync-restored.txt/.png` en TEMP.

Actualización en Chrome 8197: compilación final **92**, versión de worker
`4111659844`; se sirvió después la compilación **93**, versión de generación
`4190289952`, y una recarga con servidor dejó `version.json` con `build_number=93`.
Se detuvo ese servidor; `version.json` recargado sin servidor seguía mostrando 93,
y la app volvió a abrir A07 desde Recientes con sus cifras. No se afirma que el
query del controlador activo cambie en el mismo instante: el worker puede empezar
su actualización usando la URL que traía el bootstrap guardado.

La consola de la recarga de 93 sin servidor registró un aviso de que no pudo
registrar/actualizar el script del worker `?v=4190289952`, esperable sin servidor.
No hubo avisos de fuentes. La captura de la app 93 expiró porque Chrome quedó
oculto al abrir la ventana manual; se conserva su árbol de accesibilidad y el
`version.json` visible, sin atribuirle una captura que no se obtuvo.

## Tamaños y validaciones

| Medida | Resultado |
| --- | ---: |
| HEAD, sitio limpio de referencia | 34 archivos; 34 106 992 bytes |
| Final 92 | 48 archivos; 35 678 053 bytes |
| Actualización 93 | 48 archivos; 35 678 053 bytes |
| Diferencia del sitio final frente a HEAD | +1 571 061 bytes |
| Archivos nuevos bajo `web/`, incluida plantilla, licencias y procedencia | 15 archivos; 1 569 977 bytes |
| Incremento neto de fuentes de esta entrega, incluido este informe | 1 616 612 bytes |
| Bundles Firebase servidos | 1 012 869 bytes |
| Tres WOFF2 | 515 296 bytes |

CanvasKit ya existía en la compilación: ahora se usa esa copia, no se duplica en el
repositorio. Los tamaños son bytes sin compresión; no representan tamaño del pack
Git ni transferencia comprimida de Hosting. El incremento total versionado también
incluye herramientas, pruebas, este informe y los cambios pequeños a index/manifest.

Comandos ejecutados, una operación de Flutter a la vez y con semáforos:

```powershell
flutter test --no-pub --reporter expanded
flutter analyze --no-pub
dart format --output=none --set-exit-if-changed tool/t92_server.dart tool/t92_verify.dart test/t92_web_test.dart
dart run tool/t92_verify.dart build/t92/final
dart run tool/t92_verify.dart build/t92/update

$t92CorpusTests = @(rg --files tool -g '*corpus*test.dart')
flutter test @t92CorpusTests --no-pub '--dart-define=BAYSTREAM_CORPUS_DIRECTORY=C:\Users\Giova\OneDrive\Documentos\OneDrive\Desktop\Archivos .EDI\Anonimizados\files' --reporter expanded

flutter build web --release --no-pub --output=build/t92/final --build-number=92 --dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json
flutter build web --release --no-pub --output=build/t92/update --build-number=93 --dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json
```

Suite final: **655/655**, 25 s. Corpus: **116/116**, 27 s, 31 archivos reales.
Analyze final: **No issues found**, 7.6 s. Format: tres archivos, cero cambios.
Build HEAD: 55.5 s; final corregido: 38.7 s; actualización: 39.9 s. No se usó
`--wasm` ni `flutter test --platform chrome`. El archivo privado de definiciones
se pasó por ruta, sin abrirlo ni imprimirlo.

Los siete tests cubren versión resuelta, imports relativos existentes, orden de
los tres globales, rutas propias/configuración original de SW, licencias/huellas,
petición de la raíz después del controlador y nombre/idioma. No dependen de una
compilación ni del motor instalado; esas comprobaciones van en el verificador.
Hubo un fallo durante el desarrollo al exigir una cabecera que los bundles
oficiales de Auth/Firestore no traen; se corrigió la comprobación para exigir su
licencia asociada real y todas las pruebas finales pasaron.

Los dos verificadores finales dan **48 archivos / 35 678 053 bytes**, sin sobrantes
y con el SW original. El servidor dio HTTP 200 y MIME correcto para JS
(`application/javascript`), WASM (`application/wasm`) y WOFF2 (`font/woff2`), con
`no-cache, max-age=0, must-revalidate`. Un recurso ausente devuelve 404, nunca HTML
disfrazado de módulo. No se modificaron los avisos preexistentes de build sobre
CupertinoIcons ni la sugerencia del dry run de WASM; analyze final está en cero.

### Integridad del carril protegido

Se compararon 126 archivos antes/después: **122 de `lib/` más pubspec.yaml,
pubspec.lock, propuesta de reglas T-80 y firebase.json; cero diferencias**. Las
huellas completas están en `build/t92/integrity-before.json` y
`build/t92/integrity-after.json` (artefactos locales ignorados).

| Archivo o conjunto | SHA-256, idéntico antes y después |
| --- | --- |
| `lib/main.dart` | `C5189B1D8711837A05C68306D424C9FDBCC977BA3BBB6C823089FFE4CA5339D5` |
| `lib/latency_test_screen.dart` | `599310DB13A713E82FC0D6A411BE2D7757CBC2B803D772C1CAA16C471725CDFF` |
| `lib/c3_reconciliation_screen.dart` | `3AF478364A8C5386E1F921E0142DC4F847594BECA00B6743563CB09A8A4112A5` |
| `pubspec.yaml` | `AEF5DF33B957708569646C4F751DD6D0B7E4CC91BD4B715871276EBC5F5F808A` |
| `pubspec.lock` | `E192B61FD5917159DB6D9FBFD0C6449586885F88A86738B3074E532E1720B5CC` |
| `docs/T80-firestore.rules.propuesta` | `21894B7F43E59F856045473731B795D21F8373C5AC8A1D9FFF324334AC3C9000` |
| `firebase.json` | `9BCFD4D9B5A717BD4F044C0E67440C7A81D9858EDB1363CBD2CBA695D30852E9` |
| Manifiesto agregado de los 122 archivos de `lib/` | `437E3C4402CB01590ED132982DB678C4E9C11333195472437EE8181DEE316776` |

El agregado es SHA-256 de UTF-8 sin BOM de líneas `ruta-con-/ SHA256`, ordenadas por
la ruta original y unidas con LF, sin LF final; no sustituye la comparación de
cada archivo. Se dejaron intactos los cambios ajenos en cuatro entregables de
tesis observados por `git diff --stat --ignore-cr-at-eol`.

## Archivos propios de esta entrega

Se modifican index/manifest y se agregan los otros 19 archivos: **21 rutas**.

```text
web/index.html
web/manifest.json
web/flutter_bootstrap.js
web/vendor/firebase/12.17.0/firebase-app.js
web/vendor/firebase/12.17.0/firebase-auth.js
web/vendor/firebase/12.17.0/firebase-firestore-pipelines.js
web/vendor/firebase/12.17.0/LICENSE.txt
web/vendor/firebase/12.17.0/LEEME.md
web/vendor/firebase/12.17.0/provenance.json
web/fonts/roboto/v32/KFOmCnqEu92Fr1Me4GZLCzYlKw.woff2
web/fonts/notosanssymbols/v43/rP2up3q65FkAtHfwd-eIS2brbDN6gxP34F9jRRCe4W3gfQ8gb_VFRkzrbQ.woff2
web/fonts/notosanssymbols2/v24/I_uyMoGduATTei9eI8daxVHDyfisHr71-vrgfE71.woff2
web/fonts/LICENSE-Roboto.txt
web/fonts/LICENSE-NotoSansSymbols.txt
web/fonts/LICENSE-NotoSansSymbols2.txt
web/fonts/LEEME.md
web/fonts/provenance.json
tool/t92_server.dart
tool/t92_verify.dart
test/t92_web_test.dart
docs/T92-RESULTADOS.md
```

No cambian `lib/`, `pubspec.*`, reglas, íconos ni `firebase.json`. No se tocan
AGENTS, CLAUDE, README, SPRINT ni `.claude/settings.local.json`. No se ejecutaron
operaciones Git de escritura, `git status`, Firebase CLI, emuladores ni publicación.

Logs y compilaciones: `build/t92/`, ignorado por la regla `/build/`. No se propone
forzar esa carpeta a Git. Inventarios, capturas y PDF derivados del corpus están
exclusivamente en `%TEMP%/baystream-t92-evidence/`, fuera del repo. Las capturas de
incógnito aportadas por Carlos permanecen en sus rutas temporales de adjunto.

## Publicación: solo Carlos, después del 17-oct

Después de la aceptación del lote y la decisión de Carlos, sobre la rama que él
publique. No ejecutar mientras Timonel esté usando Flutter o sus binarios. El
siguiente bloque **no fue ejecutado por Codex**. Verifica la ruta absoluta antes
de limpiar únicamente el destino de Hosting; elimina los viejos `t54-format.*`
junto con esa compilación anterior. El número 94 es un ejemplo posterior a las
pruebas 92/93: Carlos usa el número de publicación acordado.

```powershell
Set-Location -LiteralPath C:\Proyectos\proyecto-baystream
$t92HostingOutput = [IO.Path]::GetFullPath('C:\Proyectos\proyecto-baystream\build\web')
if ($t92HostingOutput -ne 'C:\Proyectos\proyecto-baystream\build\web') {
  throw 'Destino de Hosting inesperado'
}
if (Test-Path -LiteralPath $t92HostingOutput) {
  Remove-Item -LiteralPath $t92HostingOutput -Recurse -Force
}
flutter build web --release --no-pub --output=build/web --build-number=94 --dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json
if ($LASTEXITCODE -ne 0) { throw 'No publicar: build fallido' }
dart run tool/t92_verify.dart build/web
if ($LASTEXITCODE -ne 0) { throw 'No publicar: verificacion fallida' }
firebase deploy --only hosting --project baystream-app
```

El destino de T-48 sigue siendo `baystream-app`; `firebase.json` ya tiene no-cache
y la reescritura de navegación. Nunca el proyecto de H5. Las reglas no se incluyen
en el deploy de Hosting. No imprimir el archivo privado de definiciones.

Comprobación breve prevista sobre
[baystream-app.web.app](https://baystream-app.web.app/), unos cinco minutos sin
medir H5:

1. Con red, laptop Chrome visible en origen limpio: abrir, comprobar el número
   publicado de `version.json`, cargar A07 original, GTSTC y «No lo tengo», visitar
   Lista/Bay Plan. En Network, código y fuentes deben proceder del propio sitio.
2. Recargar con esa pestaña sin red mediante DevTools Offline, abrir Recientes y
   confirmar 398/21, 6940.6 t y 0/114/284; revisar ausencia de avisos de fuentes.
   Reponer Online. No cortar la red general de la laptop.
3. Honor Chrome: primera visita con red y A07/plano; luego modo avión y Wi-Fi
   apagado, recargar y reabrir Recientes con las mismas cifras. Carlos repone la red.
4. En la sesión autorizada por Carlos, PRUEBA T-84 debe estar Al día, perder conexión
   debe mostrar Conectando… y recuperar red debe volver a Al día. Sin movimientos.
   Si un paso falla, conservar el error y decidir antes de continuar el piloto.

## Límites y tiempo

Las fuentes locales cubren el recorrido español probado. Un carácter no cubierto,
por ejemplo un emoji introducido en un motivo, puede aparecer como recuadro también
con red; es la consecuencia aceptada por la ficha y queda declarada para T-98.
No se probó iPhone; corresponde al piloto. El primer arranque siempre requiere
visitar con red y permitir SW/almacenamiento del navegador; limpiar ese almacén
elimina la disponibilidad offline. No se promete voz ni datos nuevos de Firebase
sin conexión. Los errores de favicon/manifiesto tras primera visita se documentan
arriba, sin ampliar el alcance a instalación de PWA.

Estimación original: **3.0 h**. Tiempo de trabajo aproximado hasta el cierre:
**1.2 h activas**, con inicio alrededor de 14:48 y cierre alrededor de 16:27
(Guatemala), descontando la pausa aproximada 15:23–15:49 por límite de sesión.
Son horas aproximadas de esta colaboración, incluidas las aceptaciones manuales;
no una medición H5 ni un registro de tiempo de terceros.

Tres líneas para el tablero:

- Motor, fuentes y Firebase JS 12.17.0 se sirven desde el sitio; el SW de Flutter sigue original.
- A07 reabre offline en Chrome laptop/incógnito y Honor; T-84 recupera Al día y la versión 93 reemplaza a 92.
- 655 pruebas, analyze cero, corpus 116/116 e integridad intacta; entrega local para aceptación, sin publicación.

Mensaje para Yov:

> T-92 implementada y comprobada por Codex sobre 45fc3c3, pendiente de tu aceptación independiente del lote. Bootstrap propio con CanvasKit/fuentes/Firebase 12.17.0 locales; imports relativos y globales antes del motor; SW original. Se corrigió el fallo inicial de raíz no guardada con una única petición a ./ bajo el controlador. Una visita permite A07 offline en Chrome laptop (incluido incógnito manual con Carlos) y Honor: 398/21, 6940.6 t, GTSTC 0/114/284. T-84 conserva 4/3/20 t, pasa Al día → Conectando… → Al día; versión 93 queda offline. 655/655, analyze 0, corpus 116/116; 126 SHA protegidos iguales. Informe docs/T92-RESULTADOS.md con inventarios, tamaños y publicación para Carlos después del 17-oct. Quedan declarados favicon/manifiesto no guardados en primera visita, límites de transferencia observada, consola Honor no inspeccionada y caracteres fuera de las tres fuentes. Sin cambios en lib, pubspec, reglas o firebase.json; sin publicar.
