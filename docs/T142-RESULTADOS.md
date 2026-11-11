# T-142 · Las cabeceras de seguridad del Hosting (T141-01)

**Timonel (Claude Code), 10-nov-2026, rama `sprint-4`, carpeta `C:\Proyectos\baystream-rediseno`.**
Brief: el prompt de Yov del 10-nov (`BayStream_Post_defensa_10nov.md`), con 10.105, 10.111 y 10.114 de `SPRINT-4.md`, la sección 4.3 y la fila T141-01 de `docs/T141-SEGURIDAD-RESULTADOS.md`, y T113-04 de `docs/T113-SEGURIDAD-RESULTADOS.md`.

## Resumen

- **Solo cambia `firebase.json`:** cinco cabeceras nuevas en el bloque `headers`, junto al `Cache-Control` que ya estaba: CSP, `X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy` y `Permissions-Policy`. No se compiló nada y no se tocó `lib/`, `test/`, `pubspec.*` ni `web/`. HSTS no se duplica, porque ya lo pone Firebase.
- **La CSP no necesita `'unsafe-eval'`.** Hacen falta tres concesiones, y cada una tiene su prueba de lo que se rompe sin ella:
  - `'wasm-unsafe-eval'`: sin ella, la página queda en blanco;
  - `'unsafe-inline'` en estilos: sin ella, el navegador bloquea las hojas del motor de Flutter y la de `privacidad.html`;
  - tres orígenes de Google en `connect-src`: Auth, el token y Firestore, sacados del SDK servido.
- **Las pruebas se hicieron en el emulador de Hosting, con la Web 1.0.0 publicada y la CSP aplicada:**
  - los 13 pasos sin sesión pasan con **0 violaciones**, 0 errores de consola y 0 orígenes externos;
  - el botón de voz pide el micrófono y la política no lo bloquea; el control negativo, con `microphone=()`, sí lo bloquea;
  - el service worker se registra y la app recarga sin red;
  - quien ya tenía la app en caché recibe las cabeceras nuevas en la primera recarga con red;
  - el tiempo de carga no cambia: mediana de 1760 ms antes y 1734 ms después, en 10 cargas en frío de cada lado.
- **Dos hallazgos del camino:**
  1. **El `build/web` de esta carpeta no es la Web publicada.** La publicada está en `C:\Proyectos\proyecto-baystream\build\web` (`master`), así que el canal y la producción tienen que salir de esa carpeta (sección 0).
  2. **En Windows, el emulador de Hosting no aplica ninguna cabecera con `"source": "**"`**, ni siquiera el `Cache-Control` de hoy (sección 1).
- **Falta lo que solo Carlos puede probar:** iniciar sesión, «Operaciones abiertas en la nube», abrir la operación y la voz con sesión, en un canal de vista previa (sección 5).

## 0. Paso 0

| Comprobación | Resultado |
|---|---|
| Punta de `sprint-4` (`git log`) | `a5530c2` «Sprint 4: documentos finales del 7-nov y decisiones 10.112 a 10.114»: **trae 10.112 a 10.114** |
| `build/web/version.json` de esta carpeta | `1.0.0+9`, igual al vivo (`2139f101…`) |
| `build/web/main.dart.js` de esta carpeta | `07c9111b…`, 5 880 965 B, armado el 3-nov a las 16:38 · **en vivo: `98a83241…`, 5 882 577 B** |
| `build/web/flutter_bootstrap.js` de esta carpeta | `6828d96b…` (`serviceWorkerVersion` 3821364758) · **en vivo: `3fcd39cc…` (2881856713)** |
| `C:\Proyectos\proyecto-baystream\build\web` (`master` `eddc388`, `v1.0.0`) | **coincide byte a byte con el vivo** en los dos archivos; armado el 3-nov a las 21:09, el minuto de la publicación (10.105) |

Una sola petición GET de cada archivo al sitio en vivo, como en T-141. **Me detuve y se lo dije a Carlos.** Carlos eligió «Copia de la publicada»:

- `proyecto-baystream/build/web` se copió a `build/t142/web` (57 archivos, la lista de huellas es idéntica: `build/t142/huellas-web.txt`). En esa carpeta solo se leyó.
- Todas las pruebas usan esa copia.

`firebase.json` y `web/` son idénticos en `master` y en `sprint-4`, así que el cambio vale igual para las dos ramas.

> **Consecuencia para la publicación:** `firebase deploy` publica el `build/web` de la carpeta desde la que se ejecuta. Desde `baystream-rediseno` subiría la compilación de las 16:38, otra 1.0.0+9, y eso es justo lo que este cambio no debe hacer. **El canal y la producción salen de `C:\Proyectos\proyecto-baystream`**, después de llevar el commit a `master` (secciones 5 y 6).

## 1. El banco de pruebas

- **El emulador de Hosting** (firebase-tools 15.32.1) sirve `build/t142/web` en `127.0.0.1:5942`, con el proyecto de demostración `demo-t142`: no habla con Firebase real.
  - `tool/t142_configs.py` escribe una variante de `firebase.json` por prueba en `build/t142/emu-<variante>/`.
  - `tool/t142_emulador.ps1` arranca y detiene el emulador. Solo detiene los procesos de node que llevan `demo-t142`.
- **El navegador:** Chrome de Playwright, con ventana visible, en `tool/t142_control_web.py`. Registra:
  - cada evento `securitypolicyviolation`, por una función expuesta que sobrevive a las recargas;
  - la consola, los errores de página, cada petición y las que fallan;
  - las descargas;
  - los eventos del dictado: envuelve `webkitSpeechRecognition` y `getUserMedia` antes de que cargue la app.
- **Nada sale de 127.0.0.1:** Chrome arranca con `--host-resolver-rules` que resuelven cualquier otro nombre a «no existe». Así se ve a qué orígenes *intenta* llegar la app sin tocar Firebase real. Nunca se inicia sesión.
- **El recorrido** es siempre el mismo (`tool/t142_flujo.py`) y se corre con cada variante. `tool/t142_resumen.py` lo resume.

**El emulador de Hosting, en Windows, no aplica cabeceras con `"source": "**"`.** La primera respuesta del emulador no traía ni el `Cache-Control` de hoy. La causa está en el código de firebase-tools:

- superstatic pasa el patrón por `glob-slasher`, que usa el separador del sistema y vuelve `**` en `\**`;
- con eso, `minimatch('/', '\**')` es falso para toda ruta.

En Hosting de verdad no pasa: el `Cache-Control` llega en vivo (T-141). En las copias del emulador, `tool/t142_configs.py` traduce `"source": "**"` a `"regex": ".*"`, que es la misma regla. `firebase.json` sigue con `source`.

**Quien pruebe cabeceras con el emulador en esta máquina tiene que hacer lo mismo,** o creerá que la política no se aplica.

## 2. El inventario: qué carga la app y desde dónde

El método fue servir la Web con una CSP **de solo informe** `default-src 'none'` (variante `inventario`) y recorrer los 13 pasos. El navegador avisa de cada cosa que carga, sin bloquear nada. Datos completos en `build/t142/flujo-inventario.json`.

| Qué | Cómo llega | Directiva | Lo vio el navegador (70 avisos) |
|---|---|---|---|
| `flutter_bootstrap.js`, `main.dart.js`, `canvaskit/chromium/canvaskit.js` y los tres módulos de `vendor/firebase/12.19.0/` | `<script>` e `import()` del propio sitio | `script-src-elem` | 11, todos `'self'` |
| `canvaskit.wasm` | `WebAssembly.compileStreaming` | `script-src` (`wasm-eval`) | 1 → hace falta **`'wasm-unsafe-eval'`** |
| `main.dart.js`, `canvaskit.wasm`, `assets/` (fuentes Roboto, IBM Plex, Material Icons, los íconos propios, `FontManifest.json`, `AssetManifest.bin`) y la raíz `/` | `fetch()`: CanvasKit lee las fuentes como bytes, no por `@font-face` | `connect-src` | 48, todos `'self'` |
| Dos `<style>` que inserta el motor de Flutter (uno en el documento y otro en la sombra de `flt-glass-pane`) y el `<style>` de `privacidad.html` | texto en línea | `style-src-elem` | 3 → hace falta **`'unsafe-inline'`** |
| `favicon.png`, `icons/Icon-192.png` y `favicon.ico` (lo pide el navegador en `privacidad.html`) | `<link>` | `img-src` | 5, `'self'` |
| `manifest.json` | `<link rel=manifest>` | `manifest-src` | 1, `'self'` |
| `flutter_service_worker.js` | `navigator.serviceWorker.register` | `worker-src` | 1, `'self'` |
| Exportar PDF, CSV y JSON | `<a download href="blob:…">` | ninguna: una descarga no pasa por la CSP | 0: los tres archivos bajaron con `default-src 'none'` |
| Estilos en atributos, `data:`, `blob:` cargados como recurso, `font-src`, `frame-src`, `eval` | — | — | **0** |
| Orígenes externos, sin sesión | — | — | **ninguno**: ni Google Fonts ni gstatic (CanvasKit y las fuentes de respaldo se sirven del sitio, por `canvasKitBaseUrl` y `fontFallbackBaseUrl`) |

Fueron 26 peticiones, todas a `127.0.0.1:5942`. La app no intentó salir a ninguna parte.

**Con sesión.** Sin iniciar sesión no se puede ver; está sacado del SDK servido (`vendor/firebase/12.19.0/`):

| Origen | De dónde sale | Para qué |
|---|---|---|
| `https://identitytoolkit.googleapis.com` | `firebase-auth.js`: `apiHost:"identitytoolkit.googleapis.com"` | iniciar sesión con correo y contraseña, y leer la cuenta |
| `https://securetoken.googleapis.com` | `firebase-auth.js`: `tokenApiHost:"securetoken.googleapis.com"` | renovar el token de la sesión |
| `https://firestore.googleapis.com` | `firebase-firestore-pipelines.js`: `const gr="firestore.googleapis.com"` | lecturas, escrituras y escuchas (WebChannel por XHR o fetch) |

**Lo que se descartó:**

- `https://baystream-app.firebaseapp.com/__/auth/iframe` (`authDomain`): el SDK solo lo carga para los inicios de sesión por ventana emergente o redirección. La app solo usa correo y contraseña, y en la carga no se pidió.
- `https://apis.google.com/js/api.js` y `https://www.google.com/recaptcha/…`: el SDK de Auth los carga solo si se usa ventana emergente o si el proyecto exige reCAPTCHA. Nada indica que lo exija: la sesión funcionó en 10.105 sin pasar por ahí.
- **Si el canal muestra alguno de los tres, se agrega con su línea exacta** (sección 5).
- `main.dart.js` nombra `baystream-app.firebasestorage.app`, pero solo como parte de las opciones de Firebase. La app no usa Storage.

**`eval`:** en los ocho scripts servidos no hay `eval(` global, `new Function` ni `Function(`. El único `eval(` está en `firebase-firestore-pipelines.js` y es un método propio (`Prefilter.eval`). Por eso **no hace falta `'unsafe-eval'`** ni compilar la próxima versión con `flutter build web --csp` por este motivo.

## 3. Las cabeceras finales

En el bloque `headers` de `firebase.json`, `"source": "**"`, después del `Cache-Control`. Valen para toda respuesta, también `flutter_service_worker.js` y `privacidad.html`, comprobado en el emulador.

```text
Content-Security-Policy: default-src 'self'; script-src 'self' 'wasm-unsafe-eval'; style-src 'self' 'unsafe-inline'; connect-src 'self' https://identitytoolkit.googleapis.com https://securetoken.googleapis.com https://firestore.googleapis.com; object-src 'none'; base-uri 'self'; form-action 'self'; frame-ancestors 'none'
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: microphone=(self), camera=(), geolocation=(), display-capture=(), payment=(), usb=(), serial=(), hid=(), bluetooth=(), midi=(), accelerometer=(), gyroscope=(), magnetometer=(), fullscreen=(), screen-wake-lock=(), idle-detection=(), local-fonts=(), xr-spatial-tracking=(), publickey-credentials-get=(), browsing-topics=(), clipboard-read=(self), clipboard-write=(self)
```

### Cada directiva de la CSP

| Directiva | Valor | Por qué |
|---|---|---|
| `default-src` | `'self'` | Todo lo que no se nombra aparte (imágenes, manifiesto, worker, fuentes, marcos) solo del propio sitio. El inventario no pidió nada más. |
| `script-src` | `'self' 'wasm-unsafe-eval'` | Scripts solo del sitio, sin `'unsafe-inline'` (el `index.html` no tiene scripts en línea) y sin `'unsafe-eval'`. Ver la concesión 1. |
| `style-src` | `'self' 'unsafe-inline'` | Ver la concesión 2. |
| `connect-src` | `'self'` y los tres orígenes de Google | `fetch` del sitio (fuentes, wasm, la raíz para el SW) y Auth, token y Firestore. Ver la concesión 3. |
| `object-src` | `'none'` | Sin `<object>` ni `<embed>`. |
| `base-uri` | `'self'` | El `<base href="/">` de `index.html` es del sitio. Impide que un `<base>` inyectado redirija las rutas relativas de los scripts. |
| `form-action` | `'self'` | La app no envía formularios HTML. |
| `frame-ancestors` | `'none'` | Nadie puede enmarcar la app (secuestro de clics). Es lo mismo que `X-Frame-Options: DENY`, en la versión que entienden los navegadores actuales. |

### Las concesiones y lo que se rompe sin ellas

Cada una se quitó por separado en el emulador. Variantes `sin-…` de `tool/t142_configs.py`; resultados en `build/t142/control-*.json` y `flujo-sin-style*.json`.

1. **`'wasm-unsafe-eval'` en `script-src`.**
   - **Sin ella, la página queda en blanco:** el primer cuadro nunca llega (60 s de espera agotados; captura `control-sin-script-src-wasmunsafeeval.png`).
   - El navegador lo dice así: `WebAssembly.compileStreaming(): Compiling or instantiating WebAssembly module violates the following Content Security policy directive…`.
   - CanvasKit es WebAssembly. Esta concesión permite *compilar wasm*, no ejecutar texto como JavaScript, así que no abre `eval`.
2. **`'unsafe-inline'` en `style-src`.** Sin ella, el navegador bloquea tres `<style>`:
   - **los dos que inserta el motor de Flutter**, desde `main.dart.js`. En Chrome, el recorrido pasa igual y las 12 pantallas salen idénticas, salvo las olas animadas del inicio. Esas hojas ocultan el cursor, la selección y el autocompletado del `<input>` que Flutter usa por debajo para escribir, quitan el resaltado de toque y ajustan el deslizador de la semántica. Lo que se vería roto es la edición de texto en algunos navegadores.
   - **el de `privacidad.html`, que pierde todo su diseño:** sin ancho de lectura, sin colores y sin modo oscuro (captura `privacidad-sin-style.png`).

   **¿Por qué no hashes en lugar de `'unsafe-inline'`?** El texto de esas hojas **cambia según el motor del navegador**: en `main.dart.js` hay reglas solo para WebKit, solo para Firefox, solo para Blink y solo para Edge (`Edg/`), con dos prefijos distintos. Serían unos ocho hashes, recalculados con cada versión de Flutter, y probados en navegadores que aquí no se probaron. Un *nonce*, que Flutter sí acepta, exige un valor nuevo en cada respuesta, y Hosting estático no puede generarlo.

   **El riesgo es bajo:** inyectar estilos exige antes inyectar HTML, y la app pinta en un lienzo. Queda como mejora posible, no como pendiente.
3. **Los tres orígenes de Google en `connect-src`.** Sin `identitytoolkit`, no se inicia sesión. Sin `securetoken`, la sesión muere al vencer el token (una hora). Sin `firestore`, no hay operaciones en la nube. **Aquí no se pudieron probar,** porque hacen falta sesión y Firebase real: los prueba Carlos en el canal.

**Lo que no se concede:**

- `'unsafe-eval'`: no hay `eval` (sección 2).
- `blob:` y `data:`: las descargas no pasan por la CSP y nada se carga desde ellos.
- `'unsafe-inline'` en scripts.
- Cualquier `https:` genérico.
- `gstatic` y Google Fonts: todo se sirve del sitio.

### Las otras cabeceras

| Cabecera | Valor | Por qué |
|---|---|---|
| `X-Content-Type-Options` | `nosniff` | El navegador no adivina tipos. Antes de ponerla se comprobó en vivo (`curl -sI`, `build/t142/vivo-tipos-antes.txt`) que Hosting manda el tipo correcto a todo: `text/javascript` a los `.js`, `application/wasm`, `application/json`, `font/otf`, `font/ttf`, `image/png` y `text/html`. |
| `X-Frame-Options` | `DENY` | Para los navegadores que no leen `frame-ancestors`. |
| `Referrer-Policy` | `strict-origin-when-cross-origin` | Hacia otros orígenes (Google) solo viaja el origen, nunca la ruta. Es el valor por defecto de los navegadores actuales, ahora fijado. |
| `Permissions-Policy` | ver arriba | `microphone=(self)`: la búsqueda por voz, solo en el propio sitio, nunca en un marco ajeno. Lo demás que la app no usa, apagado: cámara, ubicación, captura de pantalla, pagos, USB, serie, HID, Bluetooth, MIDI, sensores, pantalla completa, bloqueo de suspensión, inactividad, fuentes locales, XR, llaves de acceso y temas de navegación. El portapapeles queda en `(self)`, igual que hoy: la app copia el BAPLIE de salida (`departure_baplie_page.dart`, `Clipboard.setData`) y los campos de texto pegan. Chrome no dio ningún aviso de característica desconocida. |
| HSTS | — | **No se duplica:** Firebase ya manda `Strict-Transport-Security: max-age=31556926; includeSubDomains; preload` en `*.web.app` (`build/t142/vivo-cabeceras-antes.txt`). |

## 4. Las pruebas

Todas sobre la copia de la Web 1.0.0 publicada, en el emulador de Hosting, sin sesión. El navegador fue Chrome 157 de Playwright con ventana visible, a 1600 × 900.

### 4.1 El recorrido sin sesión: antes y después

`python tool/t142_flujo.py <variante>`, 13 pasos con su comprobación en la semántica de Flutter y una captura por paso (`build/t142/capturas/`):

| Paso | Inventario (sin bloquear) | **Después (CSP aplicada)** |
|---|---|---|
| 1. Abrir la app (primer cuadro y semántica) | OK | **OK** |
| 2. Abrir `T100_LLEGADA.edi` (sintético BUQUE MANUAL, de `tool/t100_sintetico.dart`): el plano | OK | **OK** |
| 3. Cambiar de bahía: «Bahía siguiente», de la 02 a la 03 | OK | **OK** |
| 4. Búsqueda escrita: `MNLU0000010` → «Posición: Bahía 002, Fila 01, Nivel 06» | OK | **OK** |
| 5. Lista | OK | **OK** |
| 6. Estadísticas | OK | **OK** |
| 7. Orden de descarga | OK | **OK** |
| 8. Confirmar el perfil («No lo tengo» para el límite de pila) | OK | **OK** |
| 9. Botón de voz: «Carga 30» → «OR / últimos dígitos» → «Dictar búsqueda en español» | OK | **OK** |
| 10–12. Exportar PDF, CSV y JSON | 45 811, 7 313 y 118 498 B | **45 811, 7 316 y 118 498 B** |
| 13. `privacidad.html` | OK | **OK, con su diseño** |
| **Violaciones de la CSP** | 70, todas de solo informe | **0** |
| Errores de consola o de página | 1 aviso del SW (el tiempo de espera del arranque) | **0** |
| Orígenes externos | ninguno | **ninguno** |

La diferencia de bytes del CSV es la fecha y la hora de la exportación, que van dentro del archivo.

**La voz, paso 9, con su control negativo:**

| | `microphone=(self)` (la de T-142) | `microphone=()` (control negativo, variante `mic-apagado`) |
|---|---|---|
| La política permite el micrófono (`document.featurePolicy.allowsFeature`) | **sí** | no |
| Permiso del micrófono al pulsar | **`prompt`: el navegador lo pide** | `denied` |
| Eventos del dictado | `creado` → `start() llamado` → espera la respuesta de la persona, sin error | `creado` → `start() llamado` → **`error: not-allowed`** → `end` |

El globo de permiso es parte del navegador, no de la página, así que no sale en las capturas de Playwright. Lo prueba el estado `prompt` sin error, frente al `not-allowed` inmediato del control. **No se concedió el micrófono ni se dictó:** el reconocimiento de Chrome manda el audio a Google. El dictado completo es el paso 5 de la lista de Carlos.

### 4.2 El service worker y quien ya tenía la app en caché

`python tool/t142_sw.py` → `build/t142/sw.json`. La «sonda» es un `fetch` a `https://t142-sonda.invalid/`: si rige una CSP, la bloquea `connect-src` y sale una violación; si no, solo falla el DNS.

| Caso | Resultado |
|---|---|
| 1. Cabeceras de hoy, perfil nuevo | El SW se registra (alcance `/`, `flutter_service_worker.js?v=2881856713`) y toma la página; la recarga la sirve el SW. **Sin CSP.** |
| 2. **Despliegue:** el emulador pasa a las cabeceras nuevas y el mismo perfil recarga con red | La raíz llega por el SW, que la pide primero a la red (`onlineFirst`). **Trae las cinco cabeceras nuevas y la CSP rige.** No hace falta borrar la caché. |
| 3. El mismo perfil, sin red (Playwright corta la red y `fetch('/version.json')` falla) | **La app pinta desde el SW** y la copia guardada de la raíz ya trae las cabeceras nuevas: la CSP rige también sin red. |
| 4. Perfil nuevo con las cabeceras nuevas | El SW se registra con la CSP puesta, la recarga sin red pinta y la CSP rige. |
| Violaciones que bloquean (sin contar la sonda) y errores de página | **0 y 0** |

Queda un caso: quien abrió la app antes del despliegue y desde entonces solo la usa sin red. Sigue con la copia vieja de la raíz, sin las cabeceras nuevas, hasta su primera carga con red. No pierde nada: es la 1.0.0 de hoy.

### 4.3 El tiempo de carga

Carga en frío: navegador nuevo, sin caché ni SW. Se mide de la navegación al primer cuadro del motor (`performance.now()` cuando aparece el lienzo de `flt-glass-pane`). Cinco cargas por ronda y dos rondas alternadas, antes, después, antes, después, a las 19:00–19:03 (`build/t142/tiempos-*.json`):

| | Ronda 1 | Ronda 2 | **Mediana de las 10** |
|---|---|---|---|
| Antes (solo `Cache-Control`) | 1796 (1796, 1891, 1751, 1718, 1824) | 1743 (1743, 1769, 1711, 1735, 1796) | **1760 ms** |
| Después (las cinco cabeceras) | 1752 (1752, 1706, 1728, 1808, 1755) | 1733 (1801, 1694, 1735, 1733, 1732) | **1734 ms** |

**La diferencia es de −26 ms, menor que la dispersión de una sola ronda (unos 170 ms).** Las cabeceras no cuestan tiempo de carga. Es en el emulador local, sin la red de producción: lo que mide es que la política no añade trabajo al navegador.

> **SEMÁFORO (tarde):** esa ventana de medición, de las 19:00 a las 19:03, **no la anuncié antes**, como pide la regla 4 de «Trabajo en paralelo». Si Codex compiló o corrió la suite en esa máquina en ese rato, las dos rondas se repiten. El comando está en la sección 7.

### 4.4 Las cabeceras con `curl -sI`

- **En vivo, antes** (`build/t142/vivo-cabeceras-antes.txt`, 10-nov 18:43): `Cache-Control` y `Strict-Transport-Security`. No hay CSP, `X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy` ni `Permissions-Policy`: es T141-01, otra vez.
- **Emulador, antes** (`emu-cabeceras-antes.txt`): solo `Cache-Control`.
- **Emulador, después** (`emu-cabeceras-despues.txt`): `Cache-Control` y las cinco nuevas, también en `/privacidad.html` y en `/flutter_service_worker.js`.
- **En vivo, después:** lo comprueba Carlos tras publicar (sección 5, paso 9).

## 5. Lo que prueba Carlos: el canal de vista previa

No lo puedo probar yo: iniciar sesión, la lista de operaciones, unirse y registrar contra Firebase real. **Todo se hace en `C:\Proyectos\proyecto-baystream`**, la carpeta de `master` con la compilación publicada, nunca en `baystream-rediseno`.

**Paso 1. Llevar el commit a `master` sin subirlo todavía** (sección 6, comandos 1 a 3).

**Paso 2. Comprobar que la compilación es la publicada.** En PowerShell, en `C:\Proyectos\proyecto-baystream`:

```powershell
Get-Content build\web\version.json
Get-FileHash build\web\main.dart.js, build\web\flutter_bootstrap.js -Algorithm SHA256 | Format-List Hash, Path
```

Esperado:

- `"version":"1.0.0","build_number":"9"`;
- `main.dart.js` → `98A83241F999FB23D89E21F1825B4879088972A0E3DB789504A6B649615CF91C`;
- `flutter_bootstrap.js` → `3FCD39CC2D3D9383BD2B6E0461F84AA0849340F692D43A6B63448FF0B8ABEC41`.

Si no coinciden, **no se publica:** alguien recompiló esa carpeta.

**Paso 3. El canal**, en la misma carpeta:

```powershell
firebase hosting:channel:deploy t142-cabeceras --expires 7d
```

- Al final imprime `Channel URL (baystream-app): https://baystream-app--t142-cabeceras-XXXXXXXX.web.app [expires …]`.
- El comando agrega solo ese dominio a los **dominios autorizados de Authentication**. Si en cambio avisa «Unable to add channel domain to Firebase Auth», o si al iniciar sesión sale `auth/unauthorized-domain`, se agrega a mano: consola de Firebase → **Authentication → Configuración → Dominios autorizados → Agregar dominio**, con el dominio del canal sin `https://`. Se quita al terminar la prueba; los de canales vencidos los limpia el propio comando en el siguiente despliegue de canal.
- Si el error menciona la clave de API o el *referer* (`requests-from-referer-…-are-blocked`), la clave del navegador tiene restricción de sitios en Google Cloud y hay que añadir el dominio del canal ahí. Es poco probable.

**Paso 4. Las cabeceras del canal:**

```powershell
curl.exe -sI https://baystream-app--t142-cabeceras-XXXXXXXX.web.app/
```

Tienen que salir las cinco nuevas, `Cache-Control` y **un solo** `Strict-Transport-Security`.

**Paso 5. En la laptop, con Chrome, la cuenta de oficina:**

1. Abre una **ventana de incógnito**, abre DevTools con **F12 → Consola**, marca **«Conservar registro»** (Preserve log), y solo entonces carga la URL del canal.
2. Inicia sesión con **oficina-prueba**, que vale hasta el 14-nov. La contraseña la tienes tú; no va en ningún archivo.
3. **Nube y cuenta → «Operaciones abiertas en la nube»:** la lista tiene que cargar. Si no hay ninguna abierta, que cargue vacía sin error ya prueba la consulta.
4. **Abre la operación** (la de demostración, si sigue abierta): el plano con sus movimientos.
5. **La búsqueda por voz:** en el plano de la operación, **«Carga» → «OR / últimos dígitos» → el micrófono** («Dictar búsqueda en español»). Chrome pregunta por el micrófono: **Permitir**. Dicta los últimos dígitos de un contenedor: el texto tiene que aparecer en el campo. Si la operación no tiene plan de carga y no aparece «Carga», abre sin nube el sintético `T100_LLEGADA.edi` (en `%TEMP%\t139\sinteticos\`), confirma el perfil y sigue el mismo camino. El permiso del micrófono es del sitio, no de la operación.
6. **F5:** la sesión sigue y la operación vuelve a abrir.
7. Cierra sesión.

**Paso 6. En el Honor, con Chrome, la cuenta de muelle (si se puede):** la URL del canal, iniciar sesión con **muelle-prueba**, «Operaciones abiertas en la nube», unirse o abrir la operación y la voz igual que arriba. Registrar no hace falta. Si lo haces, que sea en una operación de prueba.

**Paso 7. Qué mirar en la consola, en la laptop y, si se puede, en el Honor** (con `chrome://inspect`):

- **Que no aparezca ninguna línea que empiece con `Refused to…`**, por ejemplo `Refused to connect to 'https://…' because it violates the following Content Security Policy directive: "connect-src …"`, ni `Refused to load the script`, `Refused to frame` o `Refused to apply inline style`.
- Que no aparezca ninguna con `Permissions policy violation`.
- Escribir `Refused` en el filtro de la consola las deja solas.
- **Si aparece una:** no publiques. Copia la línea completa y pásala a Yov o a mí. Lo más probable es un origen de Google que el SDK pide con sesión y no está en `connect-src`, o el marco de Auth (`frame-src https://baystream-app.firebaseapp.com`). Se agrega ese origen exacto, con su razón, y se repite el canal.

**Paso 8. Si todo pasa, la producción**, en `C:\Proyectos\proyecto-baystream`:

```powershell
firebase deploy --only hosting
curl.exe -sI https://baystream-app.web.app/
git push origin master
```

Después, una vuelta corta en la Web de producción: abrir, iniciar sesión, «Operaciones abiertas en la nube» y mirar la consola. **Quien ya tenía la Web abierta recibe las cabeceras en su siguiente recarga con red** (4.2), sin borrar nada.

**Paso 9. Cómo volver atrás:**

- **Lo más rápido:** consola de Firebase → **Hosting → el sitio `baystream-app` → Historial de versiones**. En la versión del **3-nov, 21:09** (la 1.0.0 de 10.105, la que hoy está publicada), menú **⋮ → «Revertir»**. Repone los mismos archivos y la configuración anterior, con las cabeceras de antes.
- **O por Git:** en `proyecto-baystream`, `git revert <hash del cherry-pick>` (deja `firebase.json` como en `eddc388`) y `firebase deploy --only hosting` desde esa carpeta.

## 6. Cómo llega el cambio a `master`

`master` está en `eddc388` y su `firebase.json` es idéntico al de `sprint-4` antes de este cambio. El commit de T-142 solo toca archivos que en `master` no existen o no cambiaron, así que **un cherry-pick entra limpio**. En `C:\Proyectos\proyecto-baystream`, después de subir `sprint-4`:

```bash
git fetch origin
git log --oneline -1 origin/sprint-4
git cherry-pick -x <hash de "Sprint 4: T-142, cabeceras de seguridad del Hosting (T141-01)">
git show --stat HEAD
```

1. `git log` tiene que mostrar el commit de T-142 en la punta de `origin/sprint-4`. Su hash va en el cherry-pick.
2. `-x` deja en el mensaje la línea `(cherry picked from commit …)`.
3. `git show --stat HEAD` tiene que listar solo `firebase.json`, `docs/T142-RESULTADOS.md` y los seis `tool/t142_*`.
4. **El `git push origin master` va al final del paso 8 de la sección 5, después de la producción.**
5. Si el canal falla y no se publica, el cherry-pick local se deshace con `git reset --hard origin/master`. Borra solo ese commit sin subir; **antes, mira con `git log --oneline -3` que no haya otro tuyo encima.**

Si Carlos prefiere que `master` reciba solo `firebase.json`, sin los scripts ni el informe: `git checkout origin/sprint-4 -- firebase.json` y un commit propio en `master`, «Sprint 4: T-142, cabeceras de seguridad del Hosting en master». Recomiendo el cherry-pick: la huella queda enlazada al informe.

## 7. Lo que no se pudo y por qué

- **Iniciar sesión, Firestore y la voz con sesión:** hacen falta Firebase real y las cuentas. Por regla no los toco; están en la sección 5. Por eso `connect-src` con los tres orígenes de Google está sacado del SDK, no observado.
- **El dictado completo,** con permiso concedido y texto reconocido: el reconocimiento de Chrome manda el audio a Google. Se probó hasta el punto de la política (el `prompt` frente al `not-allowed` del control). El resto, en el canal.
- **Otros navegadores (Firefox, Safari y Edge) y Chrome de Android:** solo se probó Chrome de escritorio. La CSP no usa nada que dependa del navegador. Las hojas de Flutter, que sí cambian según el motor, están cubiertas por `'unsafe-inline'`. El Honor entra en el paso 6 del canal.
- **Copiar al portapapeles en la Web** (`departure_baplie_page.dart`): esa página pide una operación con plan de salida. Su política queda en `(self)`, igual que el valor por defecto del navegador, así que no cambia nada.
- **Las cabeceras en producción:** solo después del despliegue de Carlos (paso 8).
- **La ventana de medición sin anunciar** (4.3). Si hay que repetir las dos rondas: arrancar `python -X utf8 tool/t142_control_web.py servidor` en una consola y, en otra, para cada variante (`antes` y `despues`):

  ```powershell
  powershell -File tool/t142_emulador.ps1 -Variante antes
  python -X utf8 tool/t142_control_web.py '{\"accion\":\"tiempos\",\"n\":5,\"etiqueta\":\"antes\"}'
  ```

## Validaciones ejecutadas

| Validación | Resultado |
|---|---|
| Paso 0: punta de `sprint-4` y huellas contra el vivo (una GET de cada archivo) | `a5530c2`; `build/web` local ≠ vivo; `proyecto-baystream/build/web` = vivo; copia de 57 archivos idéntica |
| `firebase.json` válido (`json.load`) | sí |
| Recorrido de 13 pasos con la CSP de solo informe `default-src 'none'` | 13/13; 70 avisos que forman el inventario |
| **Recorrido de 13 pasos con las cabeceras nuevas** | **13/13; 0 violaciones; 0 errores; 0 orígenes externos** |
| Sin `'wasm-unsafe-eval'` | página en blanco: la concesión es necesaria |
| Sin `'unsafe-inline'` en estilos | 13/13 en Chrome, con 3 `<style>` bloqueados; `privacidad.html` sin diseño |
| Control negativo `microphone=()` | `denied` y `not-allowed`: la prueba de la voz distingue |
| Service worker: 4 casos | registra, cambia de cabeceras en línea y pinta sin red con la CSP: 4/4 |
| Tiempo de carga, 2 × 5 en frío por lado | mediana de 1760 frente a 1734 ms |
| `curl -sI`: en vivo antes, emulador antes y emulador después | ver 4.4 |
| `eval` y `new Function` en los 8 scripts servidos | 0 |
| `flutter analyze` y `flutter test` | **no se corrieron:** esta tarea no toca `lib/` ni `test/` |

## Horas

10-nov, hora de Guatemala: de **18:21 a 19:30** aproximadamente, **≈ 1.2 h**. La primera evidencia es la GET al vivo del paso 0, a las 18:21:59 (`Date` de la respuesta). Incluye la pausa en el paso 0 hasta la respuesta de Carlos.

## Archivos de la tarea

Modificado:

```text
firebase.json
```

Nuevos:

```text
docs/T142-RESULTADOS.md
tool/t142_configs.py
tool/t142_control_web.py
tool/t142_emulador.ps1
tool/t142_flujo.py
tool/t142_resumen.py
tool/t142_sw.py
```

**Evidencia, fuera del repositorio** (`build/` está ignorado): `build/t142/`, con la copia de la Web (`web/`, `huellas-web.txt`), las variantes del emulador (`emu-*/`), los informes (`flujo-*.json`, `control-*.json`, `sw.json`, `tiempos-*.json`), las cabeceras (`vivo-*.txt`, `emu-cabeceras-*.txt`), las descargas, los sintéticos (`datos/`) y 70 capturas. Los perfiles de Chrome del banco están en `%TEMP%\t142\` y se pueden borrar.

**No cambian:** `pubspec.yaml`, `pubspec.lock`, `lib/`, `test/`, `web/`, `build/web` ni las reglas. En el árbol hay cambios que no son de esta tarea (`test/t114_fase3_correccion_test.dart`, `windows/flutter/generated_*` y carpetas de `docs/` sin seguir): no los toqué y no van en el bloque.

## Bloque de Git (lo ejecuta Carlos)

En `C:\Proyectos\baystream-rediseno`, rama `sprint-4`:

```bash
git add -- firebase.json
git add -- docs/T142-RESULTADOS.md
git add -- tool/t142_configs.py
git add -- tool/t142_control_web.py
git add -- tool/t142_emulador.ps1
git add -- tool/t142_flujo.py
git add -- tool/t142_resumen.py
git add -- tool/t142_sw.py
git commit -m "Sprint 4: T-142, cabeceras de seguridad del Hosting (T141-01)"
git push
```

Después, el cherry-pick a `master`, el canal y la producción salen de `C:\Proyectos\proyecto-baystream` (secciones 5 y 6).

## Tres líneas

1. `firebase.json` gana CSP, `nosniff`, `X-Frame-Options: DENY`, `Referrer-Policy` y `Permissions-Policy` (micrófono solo para el sitio). La CSP no necesita `'unsafe-eval'`: concede `'wasm-unsafe-eval'` (CanvasKit), `'unsafe-inline'` en estilos (Flutter y la privacidad) y tres orígenes de Google, y cada concesión tiene su prueba de lo que se rompe sin ella.
2. Con la Web 1.0.0 publicada en el emulador: 13/13 pasos sin sesión con 0 violaciones, la voz pide el micrófono y la política no lo bloquea, el SW funciona sin red y entrega las cabeceras nuevas a quien ya tenía la app, y la carga no cambia (1760 frente a 1734 ms).
3. El canal y la producción salen de `proyecto-baystream` (`master`), porque el `build/web` de `baystream-rediseno` no es el publicado. Falta que Carlos pruebe la sesión, Firestore y la voz con sesión en el canal `t142-cabeceras`.

## Para Yov

> Yov: T-142 entregada, solo `firebase.json` y sin compilar. Paso 0: la punta trae 10.112–10.114, pero el `build/web` de `baystream-rediseno` NO es el publicado (otra 1.0.0+9, de las 16:38). El publicado es `proyecto-baystream/build/web` (`master`, 21:09); Carlos eligió probar con una copia de ese, y por eso el canal y la producción salen de `proyecto-baystream` después de un cherry-pick a `master`. CSP: `default-src 'self'`, `object-src 'none'`, `base-uri` y `form-action 'self'`, `frame-ancestors 'none'`; concesiones `'wasm-unsafe-eval'` (sin ella, la página en blanco), `'unsafe-inline'` en estilos (las hojas de Flutter cambian según el motor y no admiten hash sostenible; la privacidad pierde el diseño sin ella) e identitytoolkit, securetoken y firestore en `connect-src` (del SDK servido). Sin `'unsafe-eval'`: no hay `eval` en ningún script. Más `nosniff`, `XFO DENY`, `strict-origin-when-cross-origin` y `Permissions-Policy` con `microphone=(self)`. Emulador: 13/13 con 0 violaciones; voz `prompt` frente a `not-allowed` del control; SW 4/4 (entrega las cabeceras nuevas a quien tenía caché y la CSP rige sin red); carga 1760 frente a 1734 ms. Hallazgo de herramienta: en Windows, el emulador de Hosting no aplica cabeceras con `source: "**"` (glob-slasher vuelve `\**`); en las copias se usa `regex: ".*"`. Mea culpa: medí tiempos de 19:00 a 19:03 sin SEMÁFORO previo. Falta el canal `t142-cabeceras` de Carlos (sesión, Firestore y voz). Informe: docs/T142-RESULTADOS.md.
