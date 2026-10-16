# T-88 · Aceptación cruzada con ícono — aceptada con sustitución autorizada

## Veredicto final · 15-oct-2026

**T-88 pasa la aceptación con la sustitución de navegador autorizada por Carlos.** Honor y Windows pasan las pruebas completas. Chrome ya había pasado ambas entradas y el HTML directo; Carlos autorizó completar sus tres comprobaciones restantes en el **navegador integrado**. Las comprobaciones alternativas de favicon, manifiesto, imágenes y recursos observados pasan.

La sustitución se declara expresamente: **no se inspeccionaron visualmente la pestaña ni el panel Manifest de Chrome**. Se verificaron el favicon efectivamente descargado por el navegador integrado, el manifiesto real servido y sus cuatro imágenes renderizadas. La comprobación de red se hizo con el inventario de recursos observados del navegador; no se generó un HAR ni se usó el panel Network de Chrome. Los pendientes históricos que aparecen más abajo quedan resueltos por esta sustitución autorizada, no por una supuesta ejecución de esas vistas de Chrome.

### Cierre en el navegador integrado

Se mantuvo visible el navegador integrado y se sirvió el mismo `build/web` de la copia de aceptación, en `http://localhost:8189/`, mediante `tool/t92_server.dart`. No se recompiló ni se alteró el producto, no se inyectaron sondas y no se bloquearon terceros con CSP.

| Comprobación alternativa | Resultado propio |
|---|---|
| `/privacidad.html` directo | Pasa: política legible y completa, sin pasar por la app |
| Recursos observados en la primera carga | Solo `http://localhost:8189/favicon.ico`, solicitado automáticamente por el navegador. **Cero recursos de otro origen** |
| Regreso a la política después de abrir la app | Inventario de **cero recursos adicionales**; sigue mostrando la política |
| Favicon de la app | El DOM declara `rel="icon" href="favicon.png"`; el inventario registra su descarga. Se exportó el recurso observado, se inspeccionó visualmente y su SHA coincide con el paquete aprobado |
| Manifiesto servido | El DOM apunta a `manifest.json`. Su JSON leído en el navegador es igual al JSON de `build/web/manifest.json`; nombre BayStream y ambos colores `#0D47A1` |
| Imágenes del manifiesto | **4/4** se muestran con el ícono propio y `complete=true`; tamaño natural igual al declarado: 192×192 y 512×512, en formatos `any` y `maskable` |
| Integridad de los recursos de la compilación servida | **5/5 SHA** coinciden con `design/icono/LEEME.md`: favicon y los cuatro PNG. Además, el favicon exportado desde el navegador coincide byte a byte |

El inventario se obtuvo mediante la capacidad `pageAssets` del navegador, que enumera recursos observados, incluidos los de tipo `fetch`. En esta prueba de la política sin scripts, el único recurso adicional inicial fue el favicon del mismo origen. Se informa ese alcance de observación; no se presenta una auditoría de todo el tráfico del sistema ni de otros sitios.

SHA-256 del favicon descargado por el navegador: `9D8DA6448207EB75902183DE44BB1A30816CD8345085250E52736FB29194BBDE`.

Evidencia adicional dentro de la misma carpeta externa de la aceptación:

- `iab-privacy-assets.json` y `iab-privacy-after-app-assets.json`: inventarios de recursos de la política.
- `iab-app-assets.json`: recursos observados de la app, incluido `favicon.png`.
- `iab-manifest.json`, `iab-manifest.jpg`: manifiesto real leído y su captura.
- `iab-icon-checks.json`: cuatro decodificaciones con sus URL, dimensiones y estado.
- `iab-served-favicon.png`, `iab-hashes.json`: favicon exportado y cotejo de los cinco SHA.
- `iab-Icon-192.png.jpg`, `iab-Icon-512.png.jpg`, `iab-Icon-maskable-192.png.jpg`, `iab-Icon-maskable-512.png.jpg`: capturas de las imágenes servidas.
- `iab-icono-verificado.jpg`: recorte de la imagen observada en el navegador, sin alterar sus recursos.
- `iab-summary.json`: resumen de esta última comprobación.

### Resultado conjunto y horas

- Política: cotejo exacto de 25 líneas, correo único y `--comprobar` en 0.
- Honor: ambas entradas a 360 dp, claro/oscuro y letra 1.0/2.0, **38/38 piezas** en cada combinación; D3, nombre e ícono correctos. Letra restaurada a 1.0 y variante cerrada.
- Windows: ambas entradas, **38/38 piezas**, nombre e ícono correctos. Almacén real tomado fuera del paquete: **354 archivos previos idénticos y solo ocho añadidos de `t88cx`**. App cerrada por PID.
- Web: entradas ya verificadas en Chrome y cierre alternativo en el integrado, autorizado por Carlos, con los resultados anteriores.
- Inventario release sin Installations, analítica, anuncios, Crashlytics ni mensajería; presentes reCAPTCHA, Play Integrity y READ_GSERVICES.
- Ícono: 36/36 SHA del paquete, MSIX 1.0.4.0 con mosaicos nítidos y firma válida, sin instalarlo; sondas T-93 **0/1/1/1**.
- Validaciones de la misma copia de producto: **710/710**, analyze **cero**, corpus **118/118**. No hubo cambios que justificaran repetirlas.
- Reglas, `lib/main.dart`, archivos congelados y `pubspec.lock` sin cambios de T-88; en `pubspec.yaml`, T-88 solo había cambiado `logo_path` y su comentario, conforme a 10.50. **Esta aceptación no modifica ningún archivo de producto ni `pubspec.*`.**

Esta última ventana instrumentada fue **18:44:03–18:48:09**, Guatemala (UTC−06:00): **0.069 h**. Sumada a los intervalos anteriores de 0.135 h y aproximadamente 0.23 h: **≈0.43 h de comprobaciones instrumentadas**. No incluye las pausas entre turnos ni atribuye una duración exacta a la lectura y redacción no cronometradas. Los SHA y horarios detallados de las etapas previas se conservan en el registro de abajo.

### Entrega final para Carlos

Único archivo modificado en el repositorio en este cierre: `docs/T88-ACEPTACION-RESULTADOS.md`. `pubspec.yaml` y `pubspec.lock` no cambian. El servidor de aceptación se cierra al finalizar; no se publica nada ni se instala el MSIX.

```powershell
git add -- docs/T88-ACEPTACION-RESULTADOS.md
git commit -m "Sprint 3: T-88 cierra aceptacion con navegador integrado"
git push
```

Tres líneas:
- T-88 pasa con la sustitución del navegador autorizada por Carlos.
- Política, Honor, Windows, ícono, MSIX, inventario y validaciones cumplen las comprobaciones documentadas.
- El integrado confirma favicon, manifiesto, cuatro imágenes y cero recursos externos observados de la política; el producto queda intacto.

**Mensaje para Yov:** Capitán Codex cierra la aceptación de T-88 sobre la copia de producto de `d6c0228`. Carlos autorizó sustituir las tres verificaciones restantes de Chrome por el navegador integrado: pasan el favicon realmente descargado (SHA correcto), el manifiesto servido (BayStream y #0D47A1), sus cuatro imágenes decodificadas al tamaño correcto y el inventario de recursos de `/privacidad.html` sin otros orígenes (solo favicon.ico propio en la primera carga y cero recursos adicionales al regresar). No se afirma haber visto la pestaña o el panel Manifest de Chrome ni haber generado un HAR. Se conservan Honor completo, Windows completo, los 354 archivos previos intactos y solo ocho nuevos t88cx, 710/710, analyze cero, corpus 118/118, 36 SHA, MSIX nítido y sondas 0/1/1/1. Sin cambios de código o pubspec.*. Informe final: docs/T88-ACEPTACION-RESULTADOS.md.

---

## Registros históricos anteriores al cierre autorizado

Los veredictos parciales y sus comandos de entrega de las sesiones anteriores se conservan como evidencia histórica. El veredicto y el bloque Git vigentes son los de arriba.

## Estado de la segunda sesión, antes de autorizar la sustitución

**Honor y Windows pasan. Chrome pasa las dos entradas y el HTML directo; quedan tres comprobaciones pendientes. T-88 aún no se da por aceptada completa.** No se corrigió código ni se modificó `pubspec.yaml` o `pubspec.lock`.

Al retomar, `git log --oneline -3` mostró `35f0058`, `d6c0228` y `1e872af`. `git show --stat HEAD` confirmó que `35f0058` solo cambia `SPRINT-3.md` y el tablero de T-56. Se mantuvo la misma copia del producto de `d6c0228`, ya validada en el primer turno. Carlos pidió continuar y confirmó Chrome abierto y celular disponible.

### Honor: aceptación completa

Se instaló el APK `.t88cx` ya compilado, sin iniciar sesión ni abrir viajes. Pantalla física 720×1600 a 320 dpi: **360×800 dp**. No se cambió tamaño ni densidad.

| Tema | Letra | Texto cotejado | Desde Parámetros | Desde inicio de sesión |
|---|---:|---:|---|---|
| Claro | 1.0 | **38/38** | Pasa | Pasa |
| Oscuro | 1.0 | **38/38** | Pasa | Pasa |
| Claro | 2.0 | **38/38** | Pasa | Pasa |
| Oscuro | 2.0 | **38/38** | Pasa | Pasa |

- Cotejo propio de las 38 piezas de las constantes contra los volcados de `uiautomator`. Los correos se ocultan como `<correo>`; los XML guardan esa marca escapada para seguir siendo válidos. Resultado consolidado: `honor-matrix.json`.
- Se inspeccionaron capturas del texto en ambos temas y tamaños: título adaptado, párrafos envueltos al ancho y lectura hasta Contacto. En claro 2.0, el recorrido inicial con pasos grandes omitió un encabezado; se recuperó con desplazamiento fino y el cotejo conjunto quedó en 38/38. No se cambió la app.
- Las capturas `honor-sign-in-*.png` y `honor-login-policy-*.png` muestran el formulario vacío y la política abierta desde su enlace. A letra 2.0 también se comprobaron ambas entradas expresamente.
- `honor-package-flags.txt`: `flags=[ HAS_CODE ALLOW_CLEAR_USER_DATA ]`, sin `ALLOW_BACKUP`.
- `honor-launcher.png` muestra el ícono azul propio, su contenedor naranja y **BayStream** debajo. Se pulsó el ícono de la segunda fila; `honor-launcher-target.txt` confirmó `topResumedActivity` de `gt.cmartinez.baystream.t88cx/gt.cmartinez.baystream.MainActivity`.
- La letra inicial era **1.0**. Se restauró y verificó **1.0** al terminar. La variante queda instalada, en tema claro y cerrada con `force-stop`. No se cambiaron red, permisos ni ajustes de otras variantes.
- Se anunció el comienzo y el cierre con `SEMÁFORO:`.

### Windows: aceptación completa

- Compilación release del banco desde la copia, código 0: `build-windows.log`, **18:26:14–18:29:02**.
- Se abrió exclusivamente mediante `explorer.exe`. **PID 13020**, ruta de la copia comprobada; se cerró por ese PID al terminar.
- `windows-home.jpg`: portada sin viaje, estado «Solo este dispositivo», título **BayStream** e ícono propio visible en la barra de título.
- Parámetros → Política: pasa. Evidencias: `windows-parameters.jpg`, `windows-policy-parameters.jpg`.
- Nube y cuenta muestra correo y contraseña vacíos, sin sesión. Desde su enlace abre la política: pasa. Evidencias: `windows-sign-in.jpg`, `windows-policy-sign-in.jpg`. No se pulsó «Iniciar sesión» ni se modificaron credenciales.
- Texto completo: **38/38 piezas**, cotejadas contra la exportación de las constantes. Evidencias: `windows-policy-all.txt`, `windows-policy-middle.jpg`, `windows-policy-end.jpg`.
- `FileDescription` y `ProductName`: **BayStream**. SHA-256 del ejecutable: `CCE52E174914EA80D01D030BB3E351F5C22DCDD2C47B73862B17EEF4594E8101`.
- Huella del almacén real: **354 → 362 archivos**. Los 354 anteriores conservan tamaño y SHA; no se eliminó ninguno. Solo se añadieron estos ocho archivos dentro de `vessel_store`: `t88cx_profiles.hive`, `t88cx_profiles.lock`, `t88cx_session.hive`, `t88cx_session.lock`, `t88cx_settings.hive`, `t88cx_settings.lock`, `t88cx_voyages.hive` y `t88cx_voyages.lock`.
- Ambas huellas se tomaron fuera del paquete mediante `.bat` lanzado por `explorer.exe`, sobre `%LOCALAPPDATA%\BayStream`, anotando sus procesos padres. La cadena final fue `powershell → cmd → explorer → svchost`. Evidencias: `store-before-windows.json`, `store-after-windows.json`, `store-windows-comparison.json`.
- No se abrieron viajes ni se registraron movimientos. La app queda cerrada. Se anunció el uso con `SEMÁFORO:`.

### Chrome: comprobaciones realizadas y pendientes

- Se compiló `build/web` en la copia, código 0: `build-web.log`, **18:25:02–18:25:59**. Se sirvió con `dart tool/t92_server.dart build/web 8189`, **sin `--inventory` ni `--block-external`**: no se inyectó código ni se bloquearon terceros para aparentar una prueba de red.
- `/privacidad.html` abrió directamente y mostró el texto completo y el contacto vigente. Inspección del DOM: `lang="es"`, 13 `<h2>`, 10 `<li>`, cero `<script>` y cero `<link>`.
- App Web sin viaje: Parámetros → Política, pasa. Se recorrió el texto hasta Contacto.
- Portada → Nube y cuenta: formulario vacío y texto de uso sin cuenta. Su enlace → Política, pasa. No se inició sesión ni se introdujeron datos en los campos.
- Carlos dejó abierta una pestaña nueva. Se navegó esa pestaña a `http://localhost:8189/` mediante el control de pestañas de Chrome. La lista de ventanas de Windows confirmó `BayStream - Google Chrome` antes de intentar la captura.
- **Computer Use volvió a detener la captura nativa** porque no pudo verificar la URL de Chrome con suficiente confianza para aplicar sus controles. Ordenó detener el trabajo y finalizar el turno. No se atribuye ese fallo de herramienta a BayStream.
- **Pendientes:** ver el ícono en la pestaña, verlo en DevTools → Application → Manifest y observar la red de `/privacidad.html` para descartar peticiones a otro origen.
- El evaluador del navegador no expone `performance`; el intento de leerlo no produjo un registro de red. **La ausencia de scripts o recursos declarados no se presenta como prueba de cero peticiones externas.**
- El servidor se cerró al terminar. No se publicó nada ni se instaló el MSIX.

### Validaciones, horas y entrega actual

Las validaciones del primer turno siguen siendo las de la misma copia de producto: **710/710, analyze cero y corpus 118/118**, sin correcciones posteriores de código. Se conservan el cotejo de la política, los 36 SHA, el inventario release, el MSIX nítido y las sondas 0/1/1/1. No se repitieron pruebas sin una modificación que lo justificara.

La compilación de Windows incluye `MSB8029` por trabajar en TEMP, como exige la aceptación. La Web informa advertencias de compatibilidad Wasm y fuentes. Ambos comandos terminaron en 0; no se tocaron dependencias ni código para silenciar esos avisos.

Horas de Guatemala, UTC−06:00: continuación instrumentada desde **18:25:02**, hasta la segunda interrupción a aproximadamente **18:38:50**: **≈0.23 h**, más **0.135 h** del primer intervalo. La actualización de este informe ocurre después de esa interrupción; no se atribuye una duración exacta sin cronómetro a su redacción. La pausa entre turnos queda fuera.

Único archivo creado/modificado por Capitán Codex en el repositorio: `docs/T88-ACEPTACION-RESULTADOS.md`. **`pubspec.yaml` y `pubspec.lock` no cambian en esta aceptación.**

```powershell
git add -- docs/T88-ACEPTACION-RESULTADOS.md
git commit -m "Sprint 3: T-88 verifica Honor y Windows y registra pendientes de Chrome"
git push
```

Tres líneas:
- Honor pasa ambas entradas a 360 dp, claro/oscuro y letra 1.0/2.0; 38/38 piezas por combinación, D3 e ícono correctos.
- Windows pasa ambas entradas, 38/38, nombre e ícono; 354 archivos previos intactos y solo ocho nuevos de t88cx.
- Chrome pasa ambas entradas y el HTML directo; quedan pestaña, Manifest y red por el bloqueo de Computer Use.

**Mensaje para Yov:** Capitán Codex retomó T-88 en la copia de `d6c0228`; `35f0058` solo cambia la ficha y el tablero de T-56. Honor `.t88cx` pasa ambas entradas en las cuatro combinaciones (360 dp, claro/oscuro, letra 1.0/2.0), con 38/38 piezas, sin ALLOW_BACKUP y con nombre e ícono propios. Letra restaurada a 1.0 y app cerrada. Windows `t88cx`, abierto con explorer y cerrado por PID, pasa ambas entradas, 38/38, título e ícono; conserva los 354 archivos del almacén real y solo suma ocho de t88cx. Chrome pasa las dos entradas y `/privacidad.html` directo. Siguen pendientes el favicon en la pestaña, el panel Manifest y la red del HTML: Computer Use volvió a bloquear la captura por no poder verificar la URL, incluso con localhost abierto. No se corrigió código ni se modificó pubspec.*. Siguen las validaciones 710/710, analyze cero y corpus 118/118. T-88 aún no se acepta completa. Informe: docs/T88-ACEPTACION-RESULTADOS.md.

---

## Registro histórico del primer turno

Lo que sigue documenta el estado al cerrar el primer turno. Sus pendientes y su bloque de entrega históricos quedan sustituidos por el estado actual de arriba.

Capitán Codex · 15-oct-2026 · rama `sprint-3` · HEAD `d6c0228f57d8064bf6e096450da396cb5b6d06b4`.

## Veredicto

**PENDIENTE: T-88 todavía no está aceptada completa.** Pasan las comprobaciones estáticas, la suite, analyze, el corpus, el inventario release, la integridad del ícono, los mosaicos del MSIX y las sondas de T-93. Faltan las comprobaciones funcionales y visuales en Honor, Chrome y Windows.

**Bloqueo de la herramienta:** al pedir la primera captura de la ventana de Chrome de aceptación, Computer Use detuvo su uso porque no pudo determinar la URL del navegador con suficiente confianza para aplicar sus controles de seguridad. Su respuesta indicó detener el trabajo y finalizar el turno. No se probó otro mecanismo de control para eludir ese bloqueo. No es evidencia de un fallo de BayStream; tampoco permite dar por hechas las comprobaciones pendientes.

## Base, autorización y aislamiento

- Se leyó completo `AGENTS.md`, la ficha de T-88 de la Ola 5, las decisiones 10.44–10.51, `docs/T88-RESULTADOS.md` y `design/icono/LEEME.md`.
- La condición previa pasó: `git log --oneline -3` mostró `d6c0228` (10.51), `1e872af` (corrección 10.50) y `4723538` (decisión 10.50).
- Carlos reservó expresamente Flutter, Honor y Windows para T-88 mediante su respuesta al semáforo.
- Copia inicial exacta de **600 archivos de HEAD**, extraídos con `git ls-files` y `git show HEAD:<ruta>` a `C:\Users\Giova\AppData\Local\Temp\baystream-t88cx-20261015-181507\head`. `head-files.json` registra los SHA de todos los archivos. La referencia fue `HEAD -> sprint-3, origin/sprint-3`.
- Suite, analyze, corpus y APK del producto corrieron sobre los archivos de HEAD. El cotejo tras las validaciones dio **cero archivos versionados alterados** en la copia.
- Después se creó exclusivamente en la copia `tool/t88cx_main.dart`, derivado de `tool/t88_main.dart` cambiando `t88acc` por `t88cx`. En el Gradle de la copia solo se cambió `applicationId` a `gt.cmartinez.baystream.t88cx`. No se corrigió código del producto.
- Se usó `--dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json` sin abrir ni imprimir ese archivo. La copia no contiene `android/key.properties`: no se abrió el del repositorio. Los APK de la copia llevan la firma de depuración prevista cuando no está ese archivo; no son paquetes para subir a Play.
- No se usó la CLI de Firebase, no se accedió al proyecto H5, no se inició sesión, no se instaló el MSIX y no se ejecutó `flutter test --platform chrome`.
- En el árbol principal había cuatro documentos ajenos modificados, observados mediante `git diff --stat --ignore-cr-at-eol`; no se tocaron ni se incluyen en la entrega.

## Comprobaciones ejecutadas

| Comprobación | Resultado y evidencia propia |
|---|---|
| Texto de fuente contra ficha | **Pasa.** Exportación directa de las constantes Dart y comparación por script: 25 líneas, cero diferencias. Solo se quitaron marcas de presentación y se sustituyó `[correo de D2]` por la constante de contacto; se conservaron palabras, puntuación y rutas. `policy-export.dart`, `policy-export.json`, `policy-comparison.json` |
| Correo único | **Pasa.** Una aparición de correo en el texto, igual a `kPrivacyContactEmail`. No se buscó en documentos de terceros ni en archivos privados |
| HTML generado | **Pasa.** `dart run tool/t88_privacidad.dart --comprobar`, código 0. `privacidad-check.log` |
| Pruebas de las entradas y pantalla | **Pasa como prueba automatizada**, dentro de la suite 710/710. No reemplaza la aceptación de los tres clientes reales |
| Suite completa | **710/710**, código 0. `flutter test --reporter expanded`; `suite.log` |
| Analyze | **No issues found**, código 0. `flutter analyze`; `analyze.log` |
| Corpus completo | **118/118 en 32 archivos**, código 0. Todos los `tool/*corpus*test.dart`, con `BAYSTREAM_CORPUS_DIRECTORY` apuntando a la carpeta externa; `corpus.log`. No se copió el corpus al repo ni a la copia |
| APK release del producto | **Compilación pasa**, código 0, con `lib/main.dart` de HEAD; `build-apk-producto.log` y `producto-release.apk` |
| APK de aceptación `.t88cx` | **Compilación pasa**, código 0; `build-apk-t88cx.log` y `t88cx-release.apk`. No se instaló ni abrió |
| D3 en manifiesto fusionado y APK | **Pasa.** `allowBackup="false"`, `dataExtractionRules="@xml/data_extraction_rules"`, targetSdk 36. `merged-manifest-release.xml` y `apk-manifest.txt` |
| D3 en XML empaquetado | **Pasa.** Nueve exclusiones con `path="."` en `cloud-backup` y nueve en `device-transfer`, sin `include`. `aapt2 dump resources` resolvió `xml/data_extraction_rules` a `res/4j.xml`; se inspeccionó ese recurso compilado con `aapt2 dump xmltree`. `apk-resources.txt`, `apk-extraction-rules.txt` |
| D9 declarado | **Pasa en fuentes y manifiesto.** Android declara `BayStream`; la prueba de Windows fija el título y los metadatos. Su visibilidad en ambos clientes queda pendiente |
| Inventario release | **Pasa.** Se repitió `gradlew :app:dependencies --configuration releaseRuntimeClasspath`, código 0. Conteos propios en la tabla siguiente |
| Ícono del repositorio | **36/36 SHA idénticos** a `LEEME.md`, usando `design/icono/play/` para sus dos rutas `play/`, como ordena 10.48. `icon-sha.json` |
| Colores Web | **Pasa.** `web/manifest.json` de HEAD usa `#0D47A1` en `theme_color` y `background_color`; su integridad se conserva en el inventario de HEAD |
| `msix_config.logo_path` | **Pasa.** Apunta a `web/icons/Icon-512.png` |
| MSIX existente 1.0.4.0 | **Pasa.** Se abrió como ZIP, tiene 82 PNG en `Images/`, SHA idéntico al declarado por Timonel y firma `Valid`. No se instaló ni reconstruyó |
| Nitidez de mosaicos | **Pasa visualmente.** Se inspeccionaron los PNG extraídos a tamaño real: 600×600 (`Square150x150Logo.scale-400`), 310×310 (`LargeTile.scale-100`) y 48×48 (`Square44x44Logo.targetsize-48`). Se distinguen casco, celdas y contenedor naranja, sin bloques de 16 px ampliados. `msix.json` registra las 82 dimensiones y SHA |
| Mensaje de `UnknownError` | **Pasa.** Comparación del mensaje con la ficha: idéntico, en ASCII; `StatusMessage` sigue presente. `t93-message.json`. No se provocó `UnknownError` ni se tocaron almacenes de certificados |
| Cuatro sondas T-93 | **0 / 1 / 1 / 1**, ejecutando el script de HEAD en Windows PowerShell 5.1: original válido, un bit alterado (HashMismatch), SHA incorrecto y huella incorrecta. Se usaron cuatro copias del MSIX en `evidencia/sondas/`; ninguna se instaló |
| Huella real de Windows | **354 antes / 354 después**, mismos tamaños y SHA de todos los archivos. Cero añadidos, eliminados o modificados. Ambas huellas se tomaron mediante `.bat` abierto con `explorer.exe`, cadena `powershell → cmd → explorer → svchost`; `store-before.json`, `store-after.json`, `store-comparison.json`. Aún no hay archivos de `t88cx`, porque no se abrió BayStream |

## Inventario release: conteos propios

El árbol contiene `firebase-auth:24.2.0`, `recaptcha:18.6.1` y `integrity:1.3.0`. El manifiesto fusionado contiene `RECORD_AUDIO`, `INTERNET`, `ACCESS_NETWORK_STATE`, `READ_GSERVICES` y el permiso propio `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`. Contiene también la consulta de `android.speech.RecognitionService`.

| Término literal | Apariciones en el árbol |
|---|---:|
| `firebase-installations` | 0 |
| `firebase-analytics` | 0 |
| `play-services-measurement` | 0 |
| `play-services-analytics` | 0 |
| `firebase-crashlytics` | 0 |
| `firebase-messaging` | 0 |
| `firebase-config` | 0 |
| `firebase-perf` | 0 |
| `datatransport` | 0 |
| `transport-runtime` | 0 |
| `transport-api` | 0 |
| `play-services-ads` | 0 |
| `user-messaging-platform` | 0 |
| `firebase-appcheck` | 2 |
| `firebase-appcheck-interop` | 2 |
| `com.google.android.recaptcha:recaptcha` | 1 |
| `com.google.android.play:integrity` | 2 |
| `okhttp3` | 0 |
| `retrofit` | 0 |
| `volley` | 0 |
| `cronet` | 0 |
| `androidx.work` | 0 |

Las dos apariciones de `firebase-appcheck` son exclusivamente `firebase-appcheck-interop`; no son una dependencia del servicio App Check. Estos conteos verifican presencia de bibliotecas; no implican que se activaran reCAPTCHA o Play Integrity ni se hizo una prueba de autenticación.

## Pendientes necesarios para cerrar la aceptación

| Cliente o comprobación | Estado |
|---|---|
| Honor `.t88cx`: Parámetros e inicio de sesión, sin viaje y sin sesión | **Pendiente** |
| Honor: 360 dp, letra 1.0 y 2.0, claro y oscuro; lectura completa | **Pendiente** |
| Honor: `dumpsys package` sin `ALLOW_BACKUP` | **Pendiente** |
| Honor: nombre e ícono visibles en el lanzador | **Pendiente** |
| Chrome: las dos entradas desde la app compilada | **Pendiente** |
| Chrome: `/privacidad.html` directo desde `build/web`, con registro de red sin otro origen | **Pendiente**. No se compiló Web ni se abrió esa dirección en este turno |
| Chrome: ícono visible en la pestaña y en DevTools → Application → Manifest | **Pendiente**. El bloqueo ocurrió al capturar una ventana `about:blank` del perfil de aceptación, antes de estas comprobaciones |
| Windows `t88cx`: las dos entradas, sin viaje y sin sesión | **Pendiente** |
| Windows: título BayStream e ícono de `baystream.exe` visibles | **Pendiente** |
| Windows: huella tras usar la app, conservando todo lo previo y sumando solo `t88cx` | **Pendiente**. La huella de este turno cubre las validaciones, no una apertura de la app |

No se modificó la letra del Honor ni se instalaron variantes; por tanto no hubo ajuste de letra que restaurar. No se usó su app. La consulta `adb devices` solo confirmó que estaba disponible. No se abrió ninguna app BayStream de Windows. El Chrome de perfil temporal se cerró por sus PID al detener la aceptación; la ventana previa de Carlos no se cerró. Flutter terminó sin comandos pendientes y se anunció la liberación del semáforo.

## Archivos protegidos y alcance de pubspec

`git diff --stat --ignore-cr-at-eol 3f29fc1 HEAD -- <rutas protegidas y pubspec.*>` solo mostró `pubspec.yaml`. En ese archivo, T-88 cambia **la ruta `logo_path` y su comentario explicativo**, sin dependencias ni otras claves; `pubspec.lock` no cambia. Se inspeccionó el diff de `1e872af` con `git show`. Las reglas y `lib/main.dart` permanecen sin cambio respecto a la base anterior a T-88.

**En esta aceptación no se modifica `pubspec.yaml` ni `pubspec.lock`**, ni código, reglas o recursos del repo principal. El único archivo creado allí es este informe.

Los siguientes SHA corresponden a los bytes exactos de HEAD (finales LF); pueden diferir de los SHA de una copia de trabajo CRLF sin que difiera su contenido normalizado.

| Archivo | SHA-256 de HEAD |
|---|---|
| `lib/main.dart` | `C5189B1D8711837A05C68306D424C9FDBCC977BA3BBB6C823089FFE4CA5339D5` |
| `lib/latency_test_screen.dart` | `599310DB13A713E82FC0D6A411BE2D7757CBC2B803D772C1CAA16C471725CDFF` |
| `lib/c3_reconciliation_screen.dart` | `3AF478364A8C5386E1F921E0142DC4F847594BECA00B6743563CB09A8A4112A5` |
| `firestore.rules` | `0112510984D9A16364F9752E243999C47306E0BCF82766E380DB380E8FE8E60A` |
| `docs/T80-firestore.rules.propuesta` | `7E57F227BADC118F823265B0CFE9FF0E9A067F39F5AD387C932AD901F894F125` |
| `firebase.json` | `9BCFD4D9B5A717BD4F044C0E67440C7A81D9858EDB1363CBD2CBA695D30852E9` |
| `pubspec.yaml` | `6CAFA52D781B95B33CADBDF286B95DC989CDF9DBF530BBBB216AC613F09A29B0` |
| `pubspec.lock` | `577D742E04143131BC02A1BBB6C246D298C90396E08F6C9DFE393637A2617F53` |
| `lib/core/constants/privacy_policy.dart` | `56FA53A3E4DE891D1F92036C6C915E37CFFBAC0CFEAF86E226C3851966BA9A06` |
| `web/privacidad.html` | `7B86F47CDD02019F0722A7C5C9A08DEF069684865EE05029D2E63A0311F3AADD` |
| `tool/t93_msix.ps1` | `FBB9B6A4E86DE55A170CBA26F7ADE593923F8430E111CB787AA625CB0DB0040A` |
| `web/manifest.json` | `9F1AE9CFABD15FE252060F7249916BEA2D493106900CCA55E3AB64315AFC2913` |

## SHA del ícono: 36 coincidencias

| Ruta real | SHA-256 comprobado |
|---|---|
| `design/icono/baystream.svg` | `4F12646124389F3C1EA36E94EF3DC1B4464370444A164B5E6C66C456032A39BE` |
| `design/icono/baystream_frente.svg` | `B975968C040E944FBDE77C8325AFF0359030D41AD705A35AFED208551EA45478` |
| `design/icono/baystream_monocromo.svg` | `58DF99FB9A3C51FCDC0B16B1939A138501CB40041D28648E61EAF7CFF8887AF6` |
| `design/icono/baystream_forma.svg` | `04F4F1F089DCF25420FF205DA0F35E3565741C2BCEA6AC891B2CFD295A8FBAAF` |
| `design/icono/baystream_32.svg` | `8C3C68A773592C59F815E8CF76D115984428B9E5DB1D485EDE1493A994A5CC70` |
| `design/icono/baystream_24.svg` | `06D68FF4E607A3BEFA3331943AFDDD883B9425D4419E82846AC1DA54BF0C5B19` |
| `design/icono/baystream_20.svg` | `38C92A410021FB6836E40CE9780E633ACB1C1D5759D770F3A8B1FCE122DF480A` |
| `design/icono/baystream_16.svg` | `4BE5CF0511B35D26ECE415AA0465A0428316780141044F54004EB9DA64F4E012` |
| `design/icono/grafico_play.svg` | `CEFAE8D0BD2BAA75CD1E4C7D5FBF6EF3018E3DB1DA098C7B3FE78174DD12D289` |
| `design/icono/generar.py` | `3EEBB673E65C7A64E738AB5FCEFDEAB8144334211FAFE4A8E75899BD831F81A9` |
| `design/icono/vista-previa.png` | `F38744B47FC05C4CF7FFBF30A633A776B1B423DB1555BDFF364051DA955B7BF4` |
| `android/app/src/main/res/mipmap-mdpi/ic_launcher_foreground.png` | `CDFE666FAF024CE164DE78A12FF240F958F0FB7144B804FBABB6F2D38120EEAF` |
| `android/app/src/main/res/mipmap-mdpi/ic_launcher_monochrome.png` | `4FB0FC05798B8964EA496F7633F0D0E463813DF6FD4FF37EB7768103A3808D2E` |
| `android/app/src/main/res/mipmap-mdpi/ic_launcher.png` | `A1403C046BCF62A7A142361C84CEE3AFDFAEEEDB6FD36EC0C3E45EC9C3971146` |
| `android/app/src/main/res/mipmap-hdpi/ic_launcher_foreground.png` | `209D2940B42B8E0DB5975F3BF4A6A86FC4F3D7A9D047789A1784E46D263E5C5F` |
| `android/app/src/main/res/mipmap-hdpi/ic_launcher_monochrome.png` | `60C71C696B0E202A5F9EA54756FAA37B040AFF743BA70D4D528CC8D4708B222D` |
| `android/app/src/main/res/mipmap-hdpi/ic_launcher.png` | `7A997685A154D988F81C91F5D32AEAEE34ADFDD91908CE5E9768860315809489` |
| `android/app/src/main/res/mipmap-xhdpi/ic_launcher_foreground.png` | `5876918D4EC5CDEF3D738F947841340D9DEC65EC328F5AD095F2812F28013F3D` |
| `android/app/src/main/res/mipmap-xhdpi/ic_launcher_monochrome.png` | `B21C4950BB554B8938DDD865D9DB96BFD6A8047A58F760B82C0E2D2CE59B95E1` |
| `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png` | `52E5F235E77A6CBF20F993889EAFA82699CED9BF1FC8CCC70052F98F7B01C1F8` |
| `android/app/src/main/res/mipmap-xxhdpi/ic_launcher_foreground.png` | `0EFAF9A9D795863EE71E40FD629894E61D4E4037F78633367627EB69CD8B6DEB` |
| `android/app/src/main/res/mipmap-xxhdpi/ic_launcher_monochrome.png` | `28838371BC07E4BA7C6C85176919A856F648E653C1823325156FA275166FD8F4` |
| `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png` | `6C51E6FD465BEE117AECBC4097CFA67A3F42E69C38DC5AF352289167D77ADB67` |
| `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_foreground.png` | `79B4F0F6D7F925733448A47213BB3181D9810D5704A65DAFF26EC55BFF973EFB` |
| `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_monochrome.png` | `276F8B3406CD8B81A9E9AF1D03A0BC77B18435EF25B43D4FA44B2B0134EDCDAF` |
| `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` | `21D7C9F1FAABFC13A0E17FA9E85220257620AA0E57E55533C28F78B1C5E75805` |
| `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml` | `CEE3FF6C73E61072D4F99F71D5311DF6DE2540630951B0F9FBD4FC4BB010F62F` |
| `android/app/src/main/res/values/ic_launcher_background.xml` | `87C0FA5B1F64046F2577B8E1A03BF3AD8BD1BA7CFF3EB64A4A4BF50A46C17D27` |
| `web/favicon.png` | `9D8DA6448207EB75902183DE44BB1A30816CD8345085250E52736FB29194BBDE` |
| `web/icons/Icon-192.png` | `21D7C9F1FAABFC13A0E17FA9E85220257620AA0E57E55533C28F78B1C5E75805` |
| `web/icons/Icon-512.png` | `37E29E43385B43A91446BCA6320A417C4583C4A525D44856C677E21DE8C22CF6` |
| `web/icons/Icon-maskable-192.png` | `B5BACAC546B7E80AF4D72D1DE4B167634E9247AA1C95B9C639B6802953ADB781` |
| `web/icons/Icon-maskable-512.png` | `1E860539D0828A7C158168FF8AE96E6BC7ADE0CD9B2000FA9309BB1202281865` |
| `windows/runner/resources/app_icon.ico` | `1721C4752FA09CA07B9D3F5438AC99CCC6014AA9E72FD8EAF4703E050CA722BD` |
| `design/icono/play/icono-512.png` | `1E860539D0828A7C158168FF8AE96E6BC7ADE0CD9B2000FA9309BB1202281865` |
| `design/icono/play/grafico-1024x500.png` | `EF24F425D256E472CB4D3000569885D61F7510DA417CA46E4D7D38DBDBAF0884` |

## SHA de los artefactos

| Artefacto | SHA-256 |
|---|---|
| `producto-release.apk` | `490D0048CA3C9EF7F7DC2BF78BB769FAF6EBE13A4DDD03BDCC119B425198D8A6` |
| `t88cx-release.apk` | `E8110760AB542645E9FAACF11FDA4C8C6A4DA62E05B63130FB88A14CF8466BD1` |
| `BayStream_1.0.4.0.msix` (repo, solo lectura) | `FE430BD8A9E3D489DB855CF6AD590C6BAF306A24F6E186F7583ED3DFA93DE9D8` |

La firma del MSIX es `Valid`, sujeto `CN=BayStream`, huella `60BEF8F4D26ECF7AD25CC478E715CF9B26A278EC`. El texto plano cotejado de la política (25 líneas, sin marcas) tiene SHA-256 `E5D52280FCF37882712BFD5B6B2A69510A99C11F6DA7E862BA020875EB8F8AD4`.

## Horas y evidencias

Todas las horas siguientes son de Guatemala, UTC−06:00. Inicio instrumentado de la copia: **18:15:07**; cierre del informe: **18:23:11**. Intervalo instrumentado: **0.135 h**. La lectura inicial de instrucciones ocurrió antes de ese intervalo y no tiene cronómetro; no se atribuye una duración inventada. No se contabilizan aquí las horas de Timonel ni del diseñador.

| Ejecución | Inicio | Fin | Código |
|---|---|---|---:|
| Suite | 18:15:23 | 18:16:05 | 0 |
| Analyze | 18:16:24 | 18:16:35 | 0 |
| Corpus | 18:16:35 | 18:17:13 | 0 |
| APK producto | 18:17:50 | 18:19:42 | 0 |
| APK .t88cx | 18:20:23 | 18:21:41 | 0 |

- Huella inicial del almacén real: `2026-10-15T18:16:10.6798065-06:00`.
- Huella final del almacén real: `2026-10-15T18:21:39.8926647-06:00`.
- Evidencia y scripts propios, fuera del repo: `C:\Users\Giova\AppData\Local\Temp\baystream-t88cx-20261015-181507\evidencia`.
- Copia y APK `.t88cx` conservados para retomar: `C:\Users\Giova\AppData\Local\Temp\baystream-t88cx-20261015-181507`.
- Los logs del compilador incluyen avisos existentes de dependencias Java sobre API obsoleta y operaciones sin comprobar. `flutter analyze` dio cero incidencias; no se cambió código para silenciarlos.

## Entrega para Carlos

Única ruta creada en el repositorio: `docs/T88-ACEPTACION-RESULTADOS.md`.

```powershell
git add -- docs/T88-ACEPTACION-RESULTADOS.md
git commit -m "Sprint 3: T-88 registra aceptacion parcial y comprobaciones pendientes"
git push
```

Tres líneas:
- Pasan 710/710, analyze cero, corpus 118/118 y el cotejo exacto de la política.
- Pasan inventario release, 36 SHA del ícono, mosaicos del MSIX y sondas 0/1/1/1.
- Faltan los tres clientes reales; Computer Use detuvo la aceptación por no poder verificar la URL de Chrome.

**Mensaje para Yov:** Capitán Codex inició la aceptación cruzada de T-88 sobre `d6c0228`, en una copia exacta de 600 archivos de HEAD en TEMP. Pasan suite 710/710, analyze cero, corpus 118/118, texto 25 líneas sin diferencias y correo único, --comprobar en 0, D3 empaquetado con 18 exclusiones, inventario sin Installations/analítica/anuncios/Crashlytics/mensajería, 36 SHA del ícono, MSIX 1.0.4.0 nítido y firmado Valid y sondas T-93 0/1/1/1. El almacén real conserva sus 354 archivos idénticos. La aceptación queda parcial: Computer Use bloqueó la primera captura de Chrome por no poder verificar su URL. Faltan Honor, Chrome y Windows; el APK `.t88cx` está compilado y no instalado. No se corrigió código ni se modificó pubspec.*. Detalle en docs/T88-ACEPTACION-RESULTADOS.md.
