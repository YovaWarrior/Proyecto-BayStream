# T-92 · Aceptación cruzada de Timonel

Fecha: 15-oct-2026. Responsable: Timonel (Claude Code). Rama `sprint-3`.
Tarea aceptada: T-92, de Codex (commit `26bbfca`, informe `docs/T92-RESULTADOS.md`).
Base de la aceptación: **HEAD `5163654`** (decisión 10.38).

## Veredicto

**ACEPTADA CON OBSERVACIÓN.** Los seis criterios pasan. La observación es de
redacción y está en un entregable de T-92: `web/vendor/firebase/12.17.0/LEEME.md`
dice que la URL de `firebase-app.js` se reemplazó solo en comentarios, y en
`firebase-app.js` son dos literales de código (apartado 6). El efecto práctico es nulo
y el contenido servido es exactamente el original con esa sustitución. Se corrige
con una frase, en la tarea que Yov elija. No hace falta repetir la aceptación.

| # | Criterio | Resultado |
| --- | --- | --- |
| 1 | Verificador sobre compilación limpia de HEAD en `build/tlote92/` | **Pasa** · 48 archivos, 35 680 304 bytes |
| 2 | Inventario con red y A07: ningún código ni fuente fuera del sitio | **Pasa** · 18 URL, 0 externas |
| 3a | Arranque sin red, Chrome de la laptop | **Pasa** · 398 / 21 / 6940.6 t / 0-114-284 |
| 3b | Arranque sin red, Chrome del Honor | **Pasa** · las mismas cifras, en modo avión y sin Wi-Fi |
| 4 | «PRUEBA T-84»: Al día → Conectando… → Al día, sin movimientos | **Pasa** |
| 5 | Pruebas de T-92 dentro de la suite completa, piso vigente, analyze en 0 | **Pasa** |
| 6 | Plantilla y módulos: sin import a gstatic, versión, licencia, procedencia | **Pasa, con observación de redacción** |

## Cómo se aisló la aceptación del trabajo en curso

Al empezar, el árbol traía cambios sin commitear de Codex en `lib/` y `test/`
(corrección de T-94 y, más tarde, T-104). Para no compilar ni probar sobre trabajo
ajeno a medias, se reconstruyó **HEAD exacto** fuera del árbol compartido:

- `git ls-files -z` y `git show HEAD:<ruta>` para cada uno de los **546** archivos
  versionados, hacia `build/tlote92/src/` (ignorado por `/build/`). No se tocó el
  índice ni se cambió de rama.
- Comprobación: frente al árbol de trabajo, `lib/`, `test/`, `web/` y `tool/` solo
  difieren en los dos archivos que Codex tenía a medias en ese momento
  (`voice_search_field.dart` y `t94_voice_widget_test.dart`), sin contar los saltos de
  línea. `pubspec.lock` es idéntico y `pubspec.yaml` igual salvo CRLF.
- `flutter pub get --offline` en la copia: resolvió el mismo lock sin bajar nada.

Todo lo de Flutter corrió en esa copia, con semáforo de Carlos y uno a la vez.

## 1 · Verificador sobre compilación limpia

```powershell
flutter build web --release --no-pub --output=C:\Proyectos\proyecto-baystream\build\tlote92\web --build-number=920 --dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json
dart run tool/t92_verify.dart ..\web      # desde build/tlote92/src
```

- Compilación: **52.9 s** de dart2js, sin `--wasm`. El archivo de definiciones se pasó
  por ruta, sin abrirlo ni imprimirlo.
- Verificador: **«T-92: verificador correcto · 48 archivos · 35 680 304 bytes.»**,
  código de salida 0.
- Frente a la compilación final de Codex (48 archivos, 35 678 053 bytes), la diferencia
  de 2 251 bytes está en archivos explicados: `assets/NOTICES` +2 369 (el lock de T-93
  suma paquetes), `index.html`, `manifest.json` y los dos `provenance.json` más chicos
  (mi copia trae LF del objeto de Git; el árbol de Codex, CRLF), `flutter_bootstrap.js`
  −1 byte (la versión del worker tiene un dígito menos) y `version.json` +1 (920
  frente a 92). `main.dart.js` y el service worker tienen el mismo tamaño.
- Un tropiezo de herramienta, no del producto: con `--output=../web` (ruta relativa
  que sube de carpeta), `impellerc` no pudo escribir los shaders. Con ruta absoluta
  compiló. El bloque de publicación de Codex usa `build/web` desde la raíz, que no
  tiene ese problema.

## 2 · Inventario con red y A07

Origen nuevo **`localhost:8921`**, servido con `tool/t92_server.dart --inventory`, en
el Chrome de la laptop (extensión de Claude, ventana visible). Recorrido:

1. Cargar A07 original. Geometría propuesta, **GTSTC**, «No lo tengo», confirmar.
2. Lista: **398 contenedores, 21 bahías, 6940.6 t; 114 se descargan · 0 se cargan ·
   284 de paso.**
3. Bay Plan (bahías 01, 14 y 17), Estadísticas y Avance de la operación (114
   pendientes, sin movimientos), en **tema oscuro** (Seguir al sistema).
4. Parámetros → tema **Claro**, y otra vez Lista, Bay Plan, Estadísticas y Avance.
5. Exportar viaje → **PDF**: 145 775 bytes, el mismo tamaño que en el informe de Codex.

Para cargar A07 sin el diálogo nativo, una línea de JavaScript en la página
interceptó el `click()` de los `<input type=file>` y la extensión puso el archivo en el
input. Es instrumentación de la prueba: no toca el sitio compilado. A07 se leyó de una
copia en la carpeta temporal de la sesión, fuera del repo.

**Resultado del observador del servidor (`#t92-inventory`): 18 registros, 18 URL
distintas, cero externas.** Las 18 son propias: `/`, `flutter_bootstrap.js`,
`manifest.json`, `favicon.png`, `icons/Icon-192.png`, CanvasKit chromium (`.js` y
`.wasm`), `main.dart.js`, los tres módulos de `vendor/firebase/12.17.0/`,
`FontManifest.json`, `MaterialIcons-Regular.otf`, las tres fuentes de `fonts/` y las
dos Roboto TTF del PDF.

**Contraprueba independiente del observador:** el registro de red de la propia
extensión de Chrome, activo desde la recarga de 8921 y durante 8922 y 8924, con 72
peticiones. Todas van a `localhost`, salvo las de datos de la sesión del criterio 4
(`firestore.googleapis.com`). Ninguna a `gstatic.com` ni a `fonts.gstatic.com`.

En el JavaScript compilado sí quedan las cadenas `https://www.gstatic.com/flutter-canvaskit`
(el valor por defecto del cargador `flutter.js`) y `fonts.gstatic.com` (el de
`main.dart.js`). La plantilla las sustituye con `canvasKitBaseUrl` y
`fontFallbackBaseUrl`. En tiempo de ejecución no se piden, como muestran los dos
registros.

## 3a · Arranque sin red en el Chrome de la laptop

- Origen nuevo **`localhost:8922`**, servido con **`--block-external`**. La cabecera
  CSP llegó a la página (leída con `fetch`: `default-src 'self'; connect-src 'self'; …`).
  La red de la máquina no se tocó.
- **Una sola visita con servidor:** los tres globales `firebase_core`, `firebase_auth` y
  `firebase_firestore` puestos, el worker controlando la página y A07 cargado (GTSTC,
  «No lo tengo»), con paso por Bay Plan y Estadísticas.
- Caché `flutter-app-cache` al terminar esa visita: `/`, `index.html`, el bootstrap,
  `main.dart.js`, los manifiestos de assets, CanvasKit chromium, los tres módulos de
  Firebase, MaterialIcons, Roboto, Noto Sans Symbols, Noto Sans Symbols 2 y `version.json`.
- **Servidor detenido**, sin ningún proceso escuchando en 8920–8929 (`netstat`).
- **Recarga:** la app abre. Chrome registra todo servido por el worker con 200, salvo
  `manifest.json` con 503: ya declarado por Codex, no impide el arranque.
- Recientes → BUQUE GOLF · VIAJE007A: **398 contenedores, 21 bahías, 6940.6 t;
  114 se descargan · 0 se cargan · 284 de paso**. Lista, Bay Plan y Estadísticas
  completos, sin recuadros. El símbolo de peligro de la bahía 01 se dibuja.
- **Consola después de la recarga:** diez mensajes, todos normales (carga desde el
  worker y apertura de los almacenes IndexedDB). Ninguno de fuentes, glifos o
  caracteres sin fuente.

## 3b · Arranque sin red en el Chrome del Honor

**Pasa.** Así se hizo:

- SEMÁFORO y reserva del Honor con Carlos. Servidor en **`localhost:8923`** con
  `--block-external` y `adb reverse tcp:8923 tcp:8923`.
- Copia temporal `/sdcard/Download/TLOTE92_A07.edi`, la misma huella que A07.
- El teléfono estaba en modo avión y sin Wi-Fi. Carlos los quitó para la primera
  visita (`airplane_mode_on=0`, `wifi_on=1`). Abrió Chrome en `localhost:8923`,
  cargó A07 con GTSTC y «No lo tengo» y entró a Bay Plan. Captura revisada antes de
  guardarla: A07 en Bay Plan y nada sensible.
- Servidor detenido, sin listeners. Carlos activó el modo avión, recargó y abrió A07
  desde Recientes.
- **Al comprobar, el teléfono tenía al frente la app de aceptación de T-104 de Codex**
  (`gt.cmartinez.baystream.t104`), no Chrome. No se tocó esa app. Carlos le dio el
  Honor a Codex. Timonel retiró su `reverse` y **borró la copia de A07, comprobado**
  (`No such file or directory`).
- **Cuando Codex soltó el Honor (01:25),** Chrome seguía en `localhost:8923`. Recargado
  sin servidor, ya arrancaba en la pantalla inicial. Pero la barra de estado mostraba
  **Wi-Fi encendido** junto al modo avión: `wifi_on=2`, el Wi-Fi que sobrevive al modo
  avión. Esa comprobación no se cuenta.
- **La comprobación válida (01:26):** Carlos apagó el Wi-Fi, recargó y abrió A07 desde
  Recientes. Lectura por `adb`: `airplane_mode_on=1`, `wifi_on=0`, «Wi-Fi is
  disabled», «Active default network: none». Chrome al frente, sin `reverse` y sin
  listeners en la laptop. En pantalla, BUQUE GOLF · VIAJE007A: **398 contenedores,
  21 bahías, 6940.6 t; 114 se descargan · 0 se cargan · 284 de paso**, con el texto
  completo y sin recuadros (con la letra del sistema en 2.0, como la dejó 10.38).
- Las capturas se revisaron antes de guardarlas: solo la app y la barra de estado. Se
  quedan en la carpeta temporal de la sesión, fuera del repo.
- La consola de Chrome del teléfono no se inspeccionó, igual que en el informe de
  Codex. No se da por revisada.
- El Honor queda en modo avión y sin Wi-Fi, como lo dejó Carlos, que controla esos
  ajustes. La pestaña `localhost:8923` conserva la caché del worker y el viaje; Carlos
  puede cerrarla o borrar los datos de ese sitio cuando quiera.

## 4 · Sincronización con el SDK servido

Origen nuevo **`localhost:8924`**, en el Chrome de la laptop. **Carlos inició la
sesión de muelle.** Timonel no vio ni anotó correo, UID ni contraseña. Con la
autorización de Carlos en ese momento, Timonel pulsó «Unirse» en «PRUEBA T-84 · T84 ·
GTSTC», solo en esa, y abrió el plano de llegada.

| Paso | Estado | Cifras |
| --- | --- | --- |
| Servidor sin bloqueo | **Al día** | 4 contenedores · 3 bahías · 20.0 t · 0 cargan / 3 descargan / 1 de paso |
| Reinicio con `--block-external`, recarga, Recientes | **Conectando…** | las mismas |
| Reinicio sin bloqueo, recarga, Recientes | **Al día** | las mismas |

- La sesión se conservó en las dos recargas. Solicitudes de cambio: 0.
- Avance: el último movimiento sigue siendo «Reponer tapa», 13/10/2026 00:16 (de la
  aceptación de T-84). **No se registró ningún movimiento.**
- Externos observados: solo `firestore.googleapis.com` (datos de Firestore). El
  registro de la extensión no mostró la petición de inicio de sesión de Auth: no se
  afirma nada sobre `identitytoolkit` desde esta captura.
- No se usó la CLI de Firebase ni se publicó nada.

## 5 · Suite completa y analyze

En `build/tlote92/src` (HEAD exacto):

| Corrida | Resultado |
| --- | --- |
| `flutter test --no-pub` | **660/660**, 46 s |
| `flutter test --no-pub --reporter expanded` | 659 / **1 falla** (ver abajo) |
| `flutter test --no-pub --reporter json` | **660/660**, con las siete de T-92 en `success` |
| `flutter analyze --no-pub` | **No issues found!** (16.9 s) |

Las siete de T-92, dentro de la corrida completa: «SDK servido coincide con los
paquetes resueltos», «todos los imports del SDK son relativos y existen», «publica los
tres módulos antes de inicializar el motor», «plantilla fija motor y fuentes propios
con SW de Flutter», «terceros conservan licencia y huellas de procedencia», «primera
visita guarda la URL raiz mediante el SW original» y «nombre y lengua de la Web son
BayStream y español».

**Una prueba intermitente, ajena a T-92:**
`test/local_vessel_repository_test.dart` · «guardar viajes simultáneamente también
respeta cinco» falló una vez de tres corridas completas, con `Bad state: No se pudo
acceder al almacén local`. Sola, pasó **10 de 10**. Ocho `saveVoyage` concurrentes
sobre Hive, bajo la carga de la suite. T-92 no toca Dart de `lib/` ni esa prueba. Se
declara para que Yov decida si va a T-104 o al cierre.

## 6 · Revisión del código servido

- **Versión.** `pubspec.lock` resuelve `firebase_core_web 3.10.0`. En el caché de pub,
  `lib/src/firebase_sdk_version.dart` dice `supportedFirebaseJsSdkVersion = '12.17.0'`.
  La carpeta servida y la plantilla usan `vendor/firebase/12.17.0/`. **Coinciden.**
- **Sin import absolutos.** Ni `web/flutter_bootstrap.js` ni los tres módulos contienen
  `gstatic`. Cada uno importa solo `./firebase-app.js`, que existe. Las únicas
  apariciones de `gstatic` en `web/` están en `LEEME.md` y en los `provenance.json`,
  como URL de origen.
- **Procedencia, contrastada con el origen.** Con permiso de Carlos, se bajaron los
  tres módulos de `www.gstatic.com/firebasejs/12.17.0/` a la carpeta temporal de la
  sesión, fuera del repo:
  - sus SHA-256 son **exactamente** los `originalSha256` de `provenance.json`;
  - aplicar a cada original una sola sustitución,
    `https://www.gstatic.com/firebasejs/12.17.0/firebase-app.js` → `./firebase-app.js`,
    da un archivo **idéntico byte a byte** al servido;
  - los SHA servidos coinciden con `servedSha256`.
- **Licencias.** `LICENSE.txt` del SDK: Apache 2.0, más BSD-3 de protobuf. Core
  conserva su cabecera `@license`. Fuentes: Roboto con Apache 2.0, y las dos Noto con
  SIL OFL 1.1. Cada entrada de procedencia apunta a su licencia.
- **Rutas del motor.** `engine.stamp` = `587c18f8…`. La ruta de Roboto en
  `canvaskit/fonts.dart` y la de Noto Sans Symbols en `font_fallback_data.dart` son
  las servidas. Noto Sans Symbols 2 tiene **seis** subconjuntos en el motor y se sirve
  uno (`-vrgfE71`), el que pidió el recorrido. Un carácter de los otros cinco saldría
  como recuadro: es la consecuencia aceptada en 10.36.

**Observación de redacción (no es defecto):** `LEEME.md` del SDK dice que la URL se
reemplazó «también en comentarios: no hay otros cambios». En `firebase-app.js`, las
dos apariciones no están en comentarios: son literales de código, el nombre de la
biblioteca (`name$q`) y el del `Logger`. El efecto práctico es nulo, porque el mapa de
`PLATFORM_LOG_STRING` usa la misma variable. Pero la frase debería decir «dos literales
de código (el nombre de la biblioteca y del registrador) y, en Auth y Firestore, el
`import`».

## Otras observaciones

- Auth trae cargadores dinámicos de `www.google.com/recaptcha` y `apis.google.com`
  (teléfono y ventanas emergentes). BayStream solo usa
  `signInWithEmailAndPassword` (`firebase_session_repository.dart:144`), así que no se
  ejercitan. Si algún día se agrega otro proveedor, volverían a pedir código de fuera.
- Los tres módulos terminan en `sourceMappingURL=*.map`, y los `.map` no se sirven. Solo
  los pide DevTools abierto (404 inofensivo).
- Proceso: `TaskStop` de Claude Code cerró la consola pero **no** el `dartvm.exe`
  del servidor. Después del primer intento, 8921 y 8922 seguían escuchando. Se detuvieron
  por PID, comprobando antes en la línea de comandos que eran `t92_server.dart` de
  `tlote92`, y desde ahí cada «servidor detenido» se confirmó con `netstat`. La prueba
  sin red de 8922 se hizo con cero listeners.
- Fuera de T-92: `lib/features/vessel/presentation/widgets/bay_plan_view.dart:343`
  y `:348` tienen `// ignore: avoid_print` desde `bb28784` (12-may). `CLAUDE.md` dice
  que la línea base no tiene ninguno. Se avisa a Yov; no se toca.

## Integridad y limpieza

- No se modificó nada en `lib/`, `test/`, `web/`, `tool/` ni `pubspec.*`. El único
  archivo nuevo del repo es este informe.
- Git solo en lectura: `log`, `show`, `ls-files` y `diff --stat --ignore-cr-at-eol`.
- Corpus: A07 se copió a la carpeta temporal de la sesión (fuera del repo) para
  subirlo a Chrome. La copia del Honor se borró y se comprobó.
- Servidores: cero listeners en 8920–8929 al terminar. Sin `adb reverse` propios.
- Almacenes: IndexedDB de los orígenes 8921, 8922 y 8924 en el Chrome de la laptop,
  y 8923 en el Chrome del Honor. No se usó el almacén de Windows ni la app Android
  nativa.
- Artefactos locales, en `build/tlote92/` (ignorado): `src/`, `web/`, `build.log`,
  `suite.log`, `suite-expanded.log`, `suite.json`, `analyze.log`, `flaky-*.log` y
  `HEAD.txt`.
- PDF exportado: `Descargas\BayStream_BUQUE GOLF_VIAJE007A (3).pdf`, derivado del corpus.
  Carlos decide si lo borra.

## Tiempo

15-oct, de 00:16 a 01:30, contando las esperas de semáforo y el préstamo del Honor a
Codex (≈ 00:45–01:25). Trabajo activo: ≈ 0.8 h.
