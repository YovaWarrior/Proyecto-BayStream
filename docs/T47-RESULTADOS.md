# T-47 · Firebase de producción y retiro de opciones del código

Capitán Codex · 1-oct-2026 · Base: `7c804cc`, más los cambios de T-47 aún sin commit. Decisión B de Carlos, conforme a SPRINT-2.md §2.2 y §10.32–10.34.

**Entrega completa para revisión.** Implementación y verificaciones terminadas. Windows y Android arrancan sin red. **Web sin red y sin caché queda en blanco**: se documenta el resultado conforme a la instrucción de Carlos, sin corregirlo en T-47. La decisión sobre ese comportamiento queda aparte.

## 1. Implementación

- `tool/t47_firebase_prod_opciones.ps1` lee el bloque Web y el cliente Android `gt.cmartinez.baystream`. Comprueba que ambos pertenecen a `baystream-app`, que coincide el emisor y que las once opciones tienen valor. Genera `C:\Proyectos\baystream-privado\firebase-prod.json`; solo imprime nombres de claves y su presencia. Rechaza entradas y destino dentro del repositorio. Se comprobó ese rechazo sin crear un JSON dentro del árbol.
- El archivo Web recibido tiene realmente el nombre `firebase-prod-web.txt.txt`. Se usó el parámetro `-WebConfig` para leerlo; no se renombró ni se copiaron los archivos privados al repositorio. `h5-temporal.json` quedó intacto.
- `lib/main.dart` lee seis opciones Web y cinco Android mediante `String.fromEnvironment`. Conserva `kIsWeb ? web : android`, también para Windows, y la inicialización con opciones explícitas. No quedan valores de Firebase escritos en duro ni valores de respaldo. Si falta una opción de la plataforma seleccionada, presenta el aviso antes de inicializar Firebase o el producto:

  > Falta la configuración de Firebase
  >
  > Esta versión de BayStream no tiene todas las opciones necesarias para iniciar. Solicita una compilación configurada al responsable.

- Android usa `gt.cmartinez.baystream` en `namespace`, `applicationId` y el paquete de `MainActivity.kt`, trasladado a `android/app/src/main/kotlin/gt/cmartinez/baystream/`. Se conserva el canal `baystream/local_store`.
- Los dos metadatos de Windows que llevaban `com.example` se ajustaron. La búsqueda posterior en Android y Windows no encontró ese identificador.
- `.gitignore` incorpora `firebase-prod*.json`, `*.jks`, `*.keystore` y `key.properties`.

No se agregaron dependencias ni el plugin `com.google.gms.google-services`. **`pubspec.yaml` y `pubspec.lock` no cambiaron.** No se modificaron las pantallas congeladas, los repositorios, el parser ni los validadores. La firma de Android sigue siendo la configuración de depuración preexistente; la firma propia y la publicación corresponden a T-49.

## 2. Compilación reproducible

Generación ejecutada, sin mostrar valores:

```powershell
& .\tool\t47_firebase_prod_opciones.ps1 -WebConfig 'C:\Proyectos\baystream-privado\firebase-prod-web.txt.txt'
```

Comandos equivalentes de los tres builds finales:

```powershell
flutter build windows --release --no-pub --dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json
flutter build web --release --no-pub --dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json
flutter build apk --release --no-pub --dart-define-from-file=C:\Proyectos\baystream-privado\firebase-prod.json
```

Se ejecutó el `flutter_tools.snapshot` del SDK mediante `C:\flutter\bin\cache\dart-sdk\bin\dart.exe`, equivalente a esos comandos. Los tres builds release terminaron. No hubo publicación en Firebase ni operaciones de escritura de Git.

| Cliente | Archivo final | SHA-256 |
|---|---|---|
| Windows | `build/windows/x64/runner/Release/data/app.so` | `C3097007EFF1538A12CB6F28297267F7143CE7A795032B8754B754C67D8DC513` |
| Web | `build/web/main.dart.js` | `4939E2641C53D75589103F4D27F087D262E93D277626A6F1658FD570A94E2C38` |
| Android | `build/app/outputs/flutter-apk/app-release.apk` | `2FC3B9BDBA883AD634DDAADDBE09D48DBD2AFB9B636830194FD56F3E6E66E039` |

El hash Windows corresponde a **`data/app.so`**, no al lanzador. Los hashes se volvieron a calcular tras las verificaciones. Web emitió los avisos preexistentes del ensayo Wasm y la fuente `CupertinoIcons`. El primer build Windows sin opciones emitió LNK4078 sobre `.voltbl`; el build final Windows no lo emitió.

## 3. Producto con opciones y archivos del corpus

Se cargaron `build/t44/CORPUS_A01.edi` y `CORPUS_A03.edi`, y se abrió «Alertas de estiba» con los binarios finales.

| Cliente | A01: posibles / no evaluados / conformes | A03: posibles / no evaluados / conformes | Evidencia local |
|---|---|---|---|
| Windows release | **0/0/6** | **2/100/151** | `build/t47/windows-a01.png`, `windows-a03.png` |
| Google Chrome, origen `http://127.0.0.1:8848/` | **0/0/6** | **2/100/151** | `build/t47/chrome-a01.jpg`, `chrome-a03.jpg` |
| **Honor X5d / Android 15**, APK release | **0/0/6** | **2/100/151** | `build/t47/honor-a01.png` y `.xml`, `honor-a03.png` y `.xml` |

A01 muestra 0/0/6 porque estos perfiles no declaran límite de peso. No se introdujo un umbral para forzar 47/0/6. En Chrome y la instalación Android nueva se aceptaron los mínimos observados del viaje y «No lo tengo» para ese límite. A03 conserva el total solicitado.

**Almacén Windows efectivamente usado:**

```text
C:\Users\Giova\AppData\Local\Packages\OpenAI.Codex_2p2nqsd0c76g0\LocalCache\Local\BayStream\vessel_store
```

Se contrastaron las fechas de los archivos Hive tras importar los viajes. La ejecución desde Codex usa ese almacén del paquete, en lugar del almacén ordinario `%LOCALAPPDATA%\BayStream\vessel_store`. No se migraron ni vaciaron datos.

**Instalación del Honor:** `gt.cmartinez.baystream` es otra app y tiene almacenamiento separado. La anterior `com.example.baystream` quedó instalada; no se desinstaló ni se migró su almacén. También existe la variante de pruebas `com.example.baystream.block5qa`.

El producto conserva la inicialización de Firebase y la construcción de `FirebaseFirestore.instance`, pero su flujo de carga solo llama al parser. No se crearon bases de datos, ni se hicieron lecturas o escrituras de Firestore de producción. La ausencia deliberada de Firestore en `baystream-app` no impidió cargar los dos viajes.

## 4. Arranque sin opciones y sin red

### Falta de opciones

Se compilaron variantes release sin `--dart-define-from-file` **antes** de los builds finales. Las variantes se conservaron en `build/t47/windows-sin-opciones/`, `web-sin-opciones/` y `app-sin-opciones.apk`. Los tres clientes mostraron el aviso español citado en §1; no se mostró un error crudo de Firebase.

Evidencia: `windows-sin-opciones.txt`, `chrome-sin-opciones.jpg`, `honor-sin-opciones.xml` y `.png`. Chrome se verificó en `http://127.0.0.1:8847/`. La URL inicial `/web-sin-opciones/` servía desde una raíz incorrecta y daba 404 para `flutter_bootstrap.js`; se corrigió el servidor local y se verificó el aviso. Esa pantalla en blanco inicial fue un error de la preparación de la prueba.

### Sin red con las opciones de producción

| Cliente | Procedimiento y condición comprobada | Resultado |
|---|---|---|
| Windows release | Proceso cerrado; lanzamiento nuevo durante una desconexión de Wi-Fi. `externalTcpReachable: false` para `www.gstatic.com:443`; la única ruta predeterminada seguía asociada a la interfaz Wi-Fi desconectada. El adaptador VirtualBox activo es solo de host. | **Arranca** y muestra la página de carga. `windows-offline.png` y `.txt`; `windows-chrome-red.json`. Captura a las 21:24:38, dentro de la ventana 21:24:33–21:25:24, hora de Guatemala. |
| **Honor X5d / Android 15** | `am force-stop` y lanzamiento nuevo con modo avión activado, Wi-Fi en 0 y `Active default network: none`. | **Arranca** y muestra la página de carga. `honor-offline.png`, `.xml` y `honor-offline-estado.json`; captura del arranque a las 21:22:51. |
| Google Chrome | Carlos confirmó «Recargué con Wi-Fi desconectado y caché desactivada» y aportó las capturas de Network y Console del origen `http://127.0.0.1:8848/`. Network muestra «Disable cache» marcado y los archivos locales con respuesta 200. | **No arranca: queda en blanco.** Fallan `canvaskit.wasm`, `canvaskit.js` y la fuente Roboto con `net::ERR_INTERNET_DISCONNECTED`. Evidencia: `chrome-offline-manual-network.png` y `chrome-offline-manual-console.png`. |

Se restauraron Wi-Fi y el estado de modo avión tras las pruebas automatizadas. El primer intento Android con `svc data disable` dejó el indicador de datos en 1, por lo que **no se usó como prueba concluyente**: se repitió con modo avión y comprobación de red predeterminada. Los intentos automatizados de Chrome se ejecutaron al volver Internet; sus capturas de la página de inicio **no acreditan arranque sin red**. Las órdenes del control de Chrome se entregaron después de reconectar. La evidencia válida de Chrome es la prueba manual de Carlos, recibida el 1-oct, con su declaración de la condición sin red y los errores de desconexión visibles en las capturas.

**Causa observada en Web y límite del diagnóstico:** Console registra solicitudes fallidas a `www.gstatic.com/flutter-canvaskit/.../chromium/canvaskit.wasm`, `canvaskit.js` y a `fonts.gstatic.com` para Roboto. También muestra `TypeError: Failed to fetch` en `flutter_bootstrap.js` y el fallo de importación dinámica del módulo CanvasKit. Los recursos locales `flutter_bootstrap.js`, `main.dart.js` y los manifiestos respondieron 200, por lo que esta pantalla en blanco no reproduce el error de raíz del servidor de la variante sin opciones. El arranque observado falla durante la carga del motor Web. **Las capturas no muestran un fallo de descarga del SDK de Firebase:** su riesgo específico de §10.32 no quedó aislado de este fallo previo de CanvasKit. No se atribuye a Firebase el error observado, ni se afirma que Firebase pueda arrancar sin red. La prueba es una recarga completa de la aplicación Web con caché desactivada, no un reinicio del proceso de Chrome.

No se cambió el bootstrap, la ubicación de CanvasKit, las fuentes ni el manejo de errores de Firebase para corregirlo. Se entrega el resultado tal como salió, para una decisión posterior de Carlos.

El helper de desconexión y reconexión automática vive únicamente en `build/t47/offline-window.ps1`, con registros de estado y tiempos. No guarda el nombre del perfil Wi-Fi ni claves, y no se versiona. Estas verificaciones son de arranque; no constituyen una nueva medición completa de RNF-004.

## 5. H5 sigue separado y sin escrituras

Se recompiló **`tool/h5_main.dart` sin modificarlo**, con `h5-temporal.json` y salida independiente `build/t47/h5-web`, para no sobrescribir el Web de producción:

```powershell
flutter build web --release --no-pub -t tool/h5_main.dart --output build/t47/h5-web --dart-define-from-file=C:\Proyectos\baystream-privado\h5-temporal.json
```

Se abrió en Chrome visible, origen `http://127.0.0.1:8849/`. «Comprobar conexión (solo lectura)» devolvió **`H5_CHECK:103:true` antes y después** de abrir las dos pantallas congeladas. `latency_test` sigue en **103 documentos** y `voyages/c3-measurement-voyage` existe.

Latencia abre con la tabla vacía; C3 abre con «Sin datos sincronizados» y sin ciclo preparado. No se pulsaron «Activar receptor», «Ejecutar emisor», «Preparar ciclo» ni «Aplicar cambio». No se borró ni vació `baystream-h5-temporal-20260814`.

Evidencia: `h5-check-antes.jpg`, `h5-latencia.jpg`, `h5-c3.jpg`, `h5-check-despues.jpg`, en `build/t47/`.

## 6. Suite y análisis

- Suite completa, `flutter test --no-pub --reporter expanded`: **`00:11 +282: All tests passed!`**.
- `flutter analyze --no-pub`: **`No issues found! (ran in 25.3s)`**.
- Nueva prueba `test/firebase_configuration_test.dart`: llama al punto de entrada sin defines, comprueba la causa y la acción sugerida en español, ausencia de `BayStreamApp` y ausencia de excepciones. Sube el piso de 281 a **282**.

## 7. Repositorio público y alcance de H-04

El repositorio es **público**. Las opciones del proyecto temporal que antes estaban en `main.dart` **siguen en el historial de Git**; retirarlas del archivo actual no las borra de ese historial. Durante la primera lectura del código antiguo se mostraron opciones temporales ya presentes en esa fuente pública; no se repitieron sus valores. Las configuraciones privadas de producción no se imprimieron ni se incluyeron en este informe o en el árbol del repositorio.

Las claves Web de Firebase **no son secretas** y las opciones quedan incorporadas al binario al compilar. Lo que protege los datos de Firestore son las reglas. Sacar las opciones de la fuente cumple la decisión de T-47; no convierte el binario en un almacén de secretos ni modifica las reglas del proyecto temporal.

## 8. Archivos de la entrega

Modificados: `.gitignore`, `lib/main.dart` (autorización específica T-47), `android/app/build.gradle.kts`, `windows/runner/Runner.rc`.

Movimiento: `android/app/src/main/kotlin/com/example/baystream/MainActivity.kt` → `android/app/src/main/kotlin/gt/cmartinez/baystream/MainActivity.kt`.

Nuevos: `tool/t47_firebase_prod_opciones.ps1`, `test/firebase_configuration_test.dart`, `docs/T47-RESULTADOS.md`.

Los binarios, capturas y helpers bajo `build/t47/` son evidencia local ignorada. Los archivos de `C:\Proyectos\baystream-privado\` **no pertenecen a la entrega Git**. `SPRINT-2.md`, `AGENTS.md`, `tool/h5_main.dart`, los archivos H5 congelados y `pubspec.*` no se modificaron.
