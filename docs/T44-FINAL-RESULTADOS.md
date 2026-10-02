# T-44 · Repetición final de los ocho RNF sobre los binarios finales

Timonel · 1-oct-2026 (noche) · TC-01 · Comparación con la medición de Capitán Codex sobre `1607263`
(`docs/T44-RESULTADOS.md`).

**No se tocó `lib/`, `test/`, `pubspec.*`, `android/` ni `.gitignore`.** Sin dependencias nuevas.
No se escribió en Firebase ni se tocó `baystream-h5-temporal-20260814`. La Web no se compiló ni
se desplegó. `android/key.properties` no se abrió.

## Versión medida

| | |
|---|---|
| Commit del repositorio | `3ac98f61bb4684c3e713903e10de586db1296c71` |
| `lib/` | idéntico a `ba7353a`: `git diff --stat ba7353a HEAD -- lib` y `git diff --stat -- lib` sin salida |
| Opciones de Firebase | `--dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json` (Windows y APK) |
| `flutter analyze` | **No issues found** (`build/t44-final/analyze.log`) |
| `flutter test` | **282/282**, `All tests passed!` (`build/t44-final/tests.log`) |

Compilación de Windows y APK en serie, de 22:42:06 a 22:42:26. Antes no había ningún comando de
Flutter en curso. Las dos compilaciones salieron con código 0 y el APK sin la advertencia de clave
de depuración.

| Binario | SHA-256 | Bytes |
|---|---|---:|
| Windows `build/windows/x64/runner/Release/data/app.so` | `C3097007EFF1538A12CB6F28297267F7143CE7A795032B8754B754C67D8DC513` | 8 569 776 |
| (lanzador `baystream.exe`, solo referencia) | `EE3294912D41C23359FDE6AC4AFC14CD6705FA6849EB1FA8A99E9D16A6AFAFAD` | 15 561 216 |
| Android `build/app/outputs/flutter-apk/app-release.apk` | `C9A91F86FCD163A23EF027311E5123CCD19421535D8F968D167C7884A169731E` | 58 127 678 |
| Web `main.dart.js` publicado en `https://baystream-app.web.app` | `4939E2641C53D75589103F4D27F087D262E93D277626A6F1658FD570A94E2C38`: **coincide** con el esperado | 3 970 998 |

- **`app.so`:** su fecha es 20:50 porque Flutter reutilizó el producto en caché. Las entradas
  (`lib/` y las definiciones) no cambiaron desde esa compilación. El hash es el del archivo que
  ejecutó la medición.
- **APK:** `apksigner verify --print-certs` muestra `CN=Carlos Martinez, OU=BayStream…`, con
  certificado SHA-256 `4cc0f6b1…a83020c4`. Es el mismo de subida que el `.aab` de T-49. **No es el
  APK que entrega Play:** Play lo vuelve a firmar con la clave de la aplicación.
- **Web:** el hash se calculó en el navegador con `crypto.subtle` sobre `/main.dart.js` descargado
  sin caché. Chrome 154.

## Cambios de método frente a `1607263`

1. **`tool/t44_honor_bay_plan.dart`:** solo se añadió la variable `T44_OUT`, para escribir en
   `build/t44-final/` sin pisar la evidencia de Codex en `build/t44/`. Mismo evento inicial y final,
   mismo detector y mismas cinco repeticiones.
2. **Memoria en Windows:** se registra el tamaño de la ventana, porque el número depende mucho de él
   (ver RNF-001). El informe de Codex no lo registra, así que **la comparación de RAM no es
   estricta**. Además de `WorkingSet64` (la métrica de Codex) se reporta `PrivateMemorySize64`.
3. **RNF-004:**
   - **Web:** traza de red nueva desde el depurador de la extensión de Chrome, con el seguimiento
     activo antes de recargar, más `performance.getEntriesByType('resource')` para los dominios.
   - **Honor:** sonda nueva `tool/t44_honor_red.ps1`. Lee `/proc/net/tcp` y `tcp6` por ADB cada
     250 ms y filtra por el UID de la app. No captura contenido.
   - Codex no capturó tráfico: citó T-45 y T-46.
4. **RNF-006:** se repitió el método de Codex (toque por ADB hasta la primera captura con el error) y
   además se leyó el texto exacto con un volcado de controles (`uiautomator dump`). El volcado es más
   lento, así que su cifra no se compara con la de Codex.
5. **RNF-002 en Web:** el origen `baystream-app.web.app` **ya tenía perfiles** (ALFA y CHARLIE, de
   T-42/T-48), así que no es un «origen Chrome nuevo» como el `127.0.0.1:8788` de Codex. La primera
   carga sin perfil se contó con **A02** (BRAVO), que no tenía perfil. Se usaron los mismos pasos que
   cuenta Codex.
6. **Honor:** para instalar el APK con la clave de subida hubo que desinstalar `gt.cmartinez.baystream`
   (firmado con depuración en T-47), con autorización de Carlos. Eso borró sus datos locales, así que
   la primera carga en el Honor es de **instalación limpia**. `com.example.baystream` no se tocó. El
   hash del `base.apk` instalado es igual al del APK compilado: `C9A91F86…`.

## Tabla comparativa: `1607263` frente a la medición final

Plataformas: **Windows** = Windows 11 Home 10.0.26200. **Honor** = Honor X5d / Android 15.
**Web** = Chrome 154 sobre `https://baystream-app.web.app`.

| RNF · cifra | `1607263` (Codex) | Final (`3ac98f6`) | Binario y plataforma de la final |
|---|---|---|---|
| 001 · RAM Windows con A01, `WorkingSet64` | 314 798 080 B = **314.8 MB** (×5; ventana no registrada) | ventana maximizada: **416.7–422.0 MB**. Ventana 1280×720 recién restaurada: **209.0 MB** (×5). 1280×720 tras navegar tres bahías: **199.4 MB** (×5) | `app.so` C3097007 · Windows |
| 001 · RAM Windows, `PrivateMemorySize64` | no medida | maximizada **446.8 MB**; 1280×720 **211.9 MB** y **215.5 MB** | `app.so` C3097007 · Windows |
| 001 · RAM Android tras A06 | PSS **164 356 kB**, RSS **209 132 kB** | PSS **179 790 kB**, RSS **228 268 kB** (swap PSS 18 138 kB) | APK C9A91F86 · Honor |
| 001 · Bay Plan A01, mediana / máximo superior | 763 / 857 ms | **813 / 835 ms** | APK C9A91F86 · Honor |
| 001 · Bay Plan A02 | 823 / 880 ms | **784 / 818 ms** | APK C9A91F86 · Honor |
| 001 · Bay Plan A03 | 725 / 782 ms | **748 / 785 ms** | APK C9A91F86 · Honor |
| 001 · Bay Plan A03v_VGM | 771 / 903 ms | **756 / 764 ms** | APK C9A91F86 · Honor |
| 001 · Bay Plan A04 | 801 / 844 ms | **723 / 802 ms** | APK C9A91F86 · Honor |
| 001 · Bay Plan A05 | 747 / 827 ms | **710 / 781 ms** | APK C9A91F86 · Honor |
| 001 · Bay Plan A06 | 732 / 764 ms | **703 / 783 ms** | APK C9A91F86 · Honor |
| 001 · Captura y transferencia ADB (resolución efectiva) | 610–797 ms | **594–742 ms**; las 35 veces el plano estaba en la 1.ª captura | APK C9A91F86 · Honor |
| 001 · Parser auxiliar, mediana A01 | 10.111 ms | **8.928 ms** (máx. 38.506 ms en la 1.ª corrida, en frío) | Dart VM · Windows (no es un binario de producto) |
| 001 · Parser, medianas A02 / A03 / A03v / A04 / A05 / A06 | 4.912 / 1.718 / 1.652 / 4.634 / 3.613 / 3.189 ms | **5.080 / 1.623 / 1.575 / 4.420 / 3.300 / 2.808 ms** | Dart VM · Windows |
| 002 · Pasos hasta el plano en la primera carga | **6** (Web, origen nuevo, A01) | **6** (Web, A02 sin perfil, origen con perfiles); **5** (Honor, A01, instalación limpia, sin diálogo de plantilla) | Web 4939E264 · Chrome / APK C9A91F86 · Honor |
| 002 · Pasos con perfil ya guardado | no contado | **3** (Web, A01: abrir, Seleccionar archivo, elegir) | Web 4939E264 · Chrome |
| 002 · Mensajes visibles en inglés | 1 («Bad state») | **0** en el error de `T44_INVALID.edi` | APK C9A91F86 · Honor |
| 003 · Clientes que compilan y muestran A01 | 3/3 | **3/3**: Windows y APK compilados, Web publicada y verificada por hash | los tres |
| 003 · Archivos del corpus cargados en Honor | 7/7 | **7/7** | APK C9A91F86 · Honor |
| 003 · Web a 360×800 px CSS | plano visible con desplazamiento horizontal; título truncado | igual: plano visible con desplazamiento horizontal, título «Ba…» truncado; además, en Lista la pastilla «325 vacíos» queda cortada en el borde | Web 4939E264 · Chrome |
| 004 · Peticiones a `firestore.googleapis.com` | no medido (citó T-45/T-46) | **0** (Web: arranque, carga de A01, carga de A02, plano, estadísticas y búsqueda) | Web 4939E264 · Chrome |
| 004 · Conexiones TCP de la app en Honor | no medido | **0** en el arranque en frío (120 s) y **0** durante la carga de A01 (180 s); control positivo con GMS: 1 | APK C9A91F86 · Honor |
| 004 · Petición fallida del service worker (§10.38) | apareció en T-48 | **no apareció** en la traza de la pestaña (13 peticiones, todas 200) | Web 4939E264 · Chrome |
| 005 · `flutter analyze` | 0 (citado de T-43/BLOQUE7B) | **0**, ejecutado | `3ac98f6` |
| 005 · Pruebas | 260 (citadas, no ejecutadas) | **282/282**, ejecutadas | `3ac98f6` |
| 006 · Inválido hasta el error, cota superior | 819 ms | **[0, 710] ms** (método de Codex); 2 942 ms con volcado de controles, no comparable | APK C9A91F86 · Honor |
| 006 · Mensajes con causa / con acción | 1/1 / **0/1** | 1/1 / **1/1** | APK C9A91F86 · Honor |
| 007 · EDI cargados y rango de contenedores | 7/7, 369–979 | **7/7, 369–979**; 5/7 superan 500 | APK C9A91F86 · Honor |
| 008 · Fuente de mercancías peligrosas | 49 CFR Parte 176, sin equivalencia IMDG | **sin cambios**: `dangerous_goods_validator.dart` sigue citando 49 CFR §172.101/§176.2 y dice «no verifica cumplimiento IMDG» | `3ac98f6` |

## Detalle por RNF y dictamen

Los criterios literales son los de la matriz de `docs/T44-RESULTADOS.md` y no se transcriben de
nuevo. El dictamen se aplica a la ficha completa: que una submétrica se cumpla no aprueba el RNF.

### RNF-001 · Rendimiento: **No cumple**

**Windows, `app.so` C3097007.** Almacén y condiciones:
- **Almacén:** la app se lanzó desde la sesión de Claude Code (proceso empaquetado). El archivo de
  bloqueo `vessel_store\baystream_*.lock` se escribió a las 22:43:57 en
  `%LOCALAPPDATA%\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Local\BayStream`. Desde el mismo proceso
  empaquetado, `%LOCALAPPDATA%\BayStream` muestra los mismos archivos con las mismas fechas, así que
  **el almacén efectivo es el virtualizado del paquete de Claude**, que se ve también por la ruta
  normal. No se pudo comprobar desde un proceso sin empaquetar.
- **Condiciones de medición:** A01 se abrió desde Recientes y se midió en Bay Plan, con cinco
  lecturas separadas 0.5 s (`build/t44-final/windows-memory*.json`):

| Condición | `WorkingSet64` | `PrivateMemorySize64` |
|---|---|---|
| Ventana maximizada (tamaño en píxeles no registrado) | 422.0, 418.9, 418.9, 416.7, 416.7 MB | 446.8 MB ×5 |
| Ventana restaurada, 1280×720, recién restaurada | 209.0 MB ×5 | 211.9 MB ×5 |
| 1280×720, después de navegar tres bahías | 199.4 MB ×5 | 215.5 MB ×5 |

La memoria depende sobre todo del tamaño de la superficie de dibujo. Con la ventana maximizada se
supera el umbral de 200 MB por más del doble. Con la ventana de 1280×720 una serie quedó por debajo
(199.4 MB) y otra por encima (209.0 MB). No se puede saber en qué condición midió Codex sus 314.8 MB.

**Honor, APK C9A91F86.** Con `dumpsys meminfo` tras cargar los siete archivos y abrir A06: PSS
179 790 kB y RSS 228 268 kB. El RNF no dice qué métrica usar en Android: RSS (233.7 MB)
supera los 200 MB y PSS (184.1 MB) no.

**Apertura del plano.** Estas son las cotas superiores de la tabla. El instrumento tarda 594–742 ms
solo en capturar, así que **no resuelve el umbral de 100 ms** y no permite declarar cumplimiento ni
incumplimiento de esa submétrica. Crudos en `build/t44-final/honor-*-bayplan.json`.

**Web.** El plano, las estadísticas y la búsqueda de `WLDU5955140` respondieron (1 resultado), igual
que en `1607263`. No se cronometraron. Los umbrales de 5 000 contenedores, 100/200 ms, 60 fps y 1 s
siguen sin resolverse con estas pruebas.

**Dictamen:** no cumple por la RAM de Windows (416.7–422.0 MB maximizada y 209.0 MB en una de las
dos series a 1280×720). El resto queda sin medir, igual que en `1607263`.

### RNF-002 · Usabilidad: **No cumple**

Pasos contados como los cuenta Codex: abrir la app, Seleccionar archivo, elegir archivo, cada
decisión del flujo de perfil y Confirmar. Los desplazamientos no cuentan como pasos.

- **Web, A02 sin perfil:** abrir → Seleccionar archivo (barra) → elegir `CORPUS_A02.edi` →
  «Proponer desde el archivo» (el diálogo ofrecía además las plantillas ALFA y CHARLIE) →
  «No lo tengo» → «Confirmar y ver el plano». **6 pasos.** Resultado: BUQUE BRAVO, 806 contenedores.
  Tras confirmar, la app queda en la pestaña **Lista** con el resumen. Ver la rejilla pide un toque
  más en Bay Plan, que Codex tampoco contó.
- **Honor, A01, instalación limpia:** abrir → Seleccionar archivo → elegir `CORPUS_A01.edi` →
  «No lo tengo» → «Confirmar y ver el plano». **5 pasos.** Sin perfiles no aparece el diálogo de
  plantilla y se va directo a «Parámetros del buque».
- **Web, A01 con perfil guardado:** abrir → Seleccionar archivo → elegir. **3 pasos.**
- **Idioma:** el error del inválido ahora está íntegramente en español (ver RNF-006).

**Dictamen:** no cumple. La primera carga de un buque sin perfil requiere 5 pasos (Honor) o 6 (Web),
frente a ≤ 3. Los 30 s, los 10 minutos y el 100 % de Material 3 no se midieron.

### RNF-003 · Portabilidad: **No medible tal como está escrito** en su totalidad

Windows y APK compilaron en release. La Web publicada coincide por hash con la de T-48. Los tres
clientes mostraron A01 y el Honor cargó los 7/7 archivos.

A 360×800 px CSS, con la barra de dispositivo de DevTools (`innerWidth` 360 y `innerHeight` 800,
comprobados por JS):
- la Lista se ve, pero el título se trunca a «Ba…» y la pastilla «325 vacíos» queda cortada;
- el Bay Plan muestra el selector de bahías, la rejilla con desplazamiento horizontal y la leyenda
  (`build/t44-final/web-360-lista.jpg`, `web-360-bayplan.jpg`).

Faltan Android 8.0, las diagonales físicas de 5" y 27" y una regla de cómputo para el ≥ 95 %.

### RNF-004 · Seguridad de los datos: **No medible tal como está escrito** en su totalidad

**Web, arranque** (recarga con el seguimiento activo): 13 peticiones, todas `GET` con `200`.

| Dominio | Peticiones | Qué es |
|---|---|---|
| `baystream-app.web.app` | `/`, `flutter_bootstrap.js`, `manifest.json`, `main.dart.js`, `icons/Icon-192.png`, `assets/FontManifest.json`, `assets/fonts/MaterialIcons-Regular.otf` | la propia app |
| `www.gstatic.com` | `flutter-canvaskit/587c18f8…/chromium/canvaskit.wasm` y `canvaskit.js` | **motor** de Flutter |
| `www.gstatic.com` | `firebasejs/12.17.0/firebase-app.js` y `firebase-firestore-pipelines.js` | **SDK** de Firebase (descarga de código) |
| `fonts.gstatic.com` | Roboto v32 y Noto Sans Symbols v43 (`.woff2`) | fuentes |

**Web, carga de A01:** **ninguna** petición de red; la traza solo registró una URL `data:` local. A01
entró directo con el perfil guardado (977 contenedores, 34 bahías). Con la carga de A02 (flujo de
perfil completo) y con el plano, las estadísticas y la búsqueda tampoco hubo peticiones: solo cinco
`data:`.

En toda la sesión, `performance.getEntriesByType('resource')` reúne tres dominios
(`baystream-app.web.app`, `www.gstatic.com` y `fonts.gstatic.com`) y **0** entradas de
`firestore.googleapis.com`. Ninguna petición sale con datos del usuario: todas son descargas `GET` de
código, motor o fuentes.

La consola registra `Initializing Firebase firebase_firestore`, lo que muestra que el SDK se
inicializa pero no abre canal con Firestore en estas operaciones.

**Petición fallida del service worker (§10.38):** no apareció. El service worker
`flutter_service_worker.js?v=1185262547` está registrado con alcance `/` y controla la página.

Límites de la observación:
- El rastreador de la pestaña no ve las peticiones que el propio service worker hace en su contexto,
  así que una petición fallida de ese tipo podría no salir en esta traza.
- DevTools tenía **Disable cache** y **Keep log** activados (los dejó Carlos), así que el arranque
  descargó todo sin caché HTTP.

**Honor, APK C9A91F86, UID 10231:**

| Ventana | Duración | Extremos remotos TCP de la app |
|---|---|---|
| Arranque en frío | 120 s | **0** |
| Carga de A01 (instalación limpia, flujo de perfil completo) | 180 s | **0** |
| Control positivo: GMS, UID 10041 | 20 s | 1 (`173.194.212.188:5228`, PTR `vq-in-f188.1e100.net`) |

El control demuestra que la sonda ve conexiones reales. La sonda **no ve UDP ni QUIC** y muestrea
cada 250 ms: una conexión TCP que abra y cierre dentro de ese intervalo podría escaparse. JSON en
`build/t44-final/honor-red-*.json`.

**Dictamen:** en las operaciones básicas probadas, en Web y en el Honor, **no hubo ninguna
transmisión de datos del usuario ni ninguna petición a Firestore**. El «100 %» de las operaciones, el
TLS 1.2+ de la sincronización y el almacén de credenciales no se miden con esto.

### RNF-005 · Mantenibilidad: **No medible tal como está escrito** en su totalidad

`flutter analyze`: **0** incidencias. `flutter test`: **282/282**, ambos ejecutados en esta
medición. `dart analyze tool/t44_honor_bay_plan.dart`: sin incidencias. Igual que en `1607263`, la
cobertura documental ≥ 80 % no se calculó y la granularidad de los proveedores no tiene umbral.

### RNF-006 · Tolerancia a fallos: **No medible tal como está escrito** en su totalidad

`T44_INVALID.edi` (7 bytes, `INVALID`) se eligió desde A06 abierto en el Honor.

> El archivo no trae el nombre del buque en el segmento TDT. Revisa que sea un BAPLIE completo o
> pide una nueva exportación.

El mensaje trae causa y acción sugerida (**1/1**, antes 0/1). Con el método de Codex el error salió en
la primera captura, cota **[0, 710] ms**; antes del toque la pantalla no tenía el error. Tras el
error, el plano de A06 siguió operativo y A01 volvió a cargar sin reiniciar la app (BUQUE ALFA, 977
contenedores). Captura en `build/t44-final/honor-invalido-mensaje.png`.

El caso observado cumple las dos condiciones del mensaje y la recuperación por debajo de 3 s. Con un
solo tipo de archivo corrupto no se puede afirmar «100 %», y el 99.9 % de disponibilidad no se
infiere de una sesión.

### RNF-007 · Escalabilidad: **No medible tal como está escrito**

7/7 EDI cargados en el Honor, de 369 a 979 contenedores; 5/7 superan 500. No hay archivo de
10 000 contenedores ni se agregó un módulo.

**Observación sobre las bahías:** el parser auxiliar cuenta 27 bahías en A01, y la app (Web y Honor),
igual que Codex, muestra **34**. En A02 son 20 frente a 30. La diferencia es la misma que ya mostraba
`1607263`, y los contenedores coinciden en los siete archivos. No se investigó qué cuenta cada
instrumento como «bahía»: queda anotado, no diagnosticado.

### RNF-008 · Estándares: **No cumple** el criterio literal IMDG

Sin cambios respecto de `1607263`: el validador de mercancías peligrosas sigue declarando 49 CFR
§172.101/§176.2 y «no verifica cumplimiento IMDG». Parsear 7/7 archivos no certifica las demás
normas.

## Resumen de dictámenes

| RNF | `1607263` | Final |
|---|---|---|
| 001 | No cumple | **No cumple** |
| 002 | No cumple | **No cumple** |
| 003 | No medible | **No medible** |
| 004 | No medible | **No medible** (0 peticiones a Firestore y 0 conexiones TCP en lo probado) |
| 005 | No medible | **No medible** |
| 006 | No cumple | **No medible** en su totalidad (el caso observado ya trae causa y acción) |
| 007 | No medible | **No medible** |
| 008 | No cumple | **No cumple** |

## Evidencia (sin versionar, `build/t44-final/`)

- Registros: `build-windows.log`, `build-apk.log`, `analyze.log` y `tests.log`.
- Datos medidos: `corpus-parse.json`, `windows-memory.json`, `windows-memory-restaurada.json`,
  `windows-memory-restaurada-navegada.json`, `honor-*-bayplan.json` (7),
  `honor-meminfo-tras-a06.txt` y `honor-red-arranque.json`, `honor-red-carga-a01.json`,
  `honor-red-control-gms.json`.
- Capturas del Honor: `honor-00…03-*.png`, `honor-a06-estado.png` y `honor-invalido-mensaje.png`.
- Capturas de la Web: `web-a01-cargado.jpg`, `web-a02-cargado.jpg`, `web-bayplan.jpg`,
  `web-estadisticas.jpg`, `web-busqueda.jpg`, `web-360-lista.jpg` y `web-360-bayplan.jpg`.
- Copias del corpus (A01 y A02) usadas en la Web.

## Archivos

- Modificado: `tool/t44_honor_bay_plan.dart` (solo `T44_OUT`, +3 líneas).
- Nuevos: `tool/t44_honor_red.ps1` y `docs/T44-FINAL-RESULTADOS.md`.
- **`pubspec.yaml` y `pubspec.lock` no cambian.**
