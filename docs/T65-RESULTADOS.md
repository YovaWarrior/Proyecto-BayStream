# T-65 · Cerrar V1 y V2 de T-64: dependencias reales y red del Honor en todas las operaciones básicas

Timonel · 2-oct-2026 · Base: `f32008e` · **Honor X5d / Android 15**

**No se tocó código ni archivos versionados fuera de este informe, y no se compiló la app.** Gradle
solo imprimió su árbol de dependencias (ver 1.1). `git diff --stat HEAD -- lib test pubspec.yaml
pubspec.lock android web tool` salió vacío después de correrlo. En el Honor no se reinstaló ni se
desinstaló nada, y `com.example.baystream` no se tocó.

## Conclusión

| Duda de T-64 | Resultado |
|---|---|
| **V1** · ¿Hay Firebase Installations, Analytics o alguna biblioteca que transmita por su cuenta? | **No hay Installations, Analytics, Crashlytics, Messaging, Remote Config, Performance, anuncios ni ninguna biblioteca de transporte de datos de Google.** La única biblioteca que transmite por su cuenta es **Cloud Firestore** (gRPC sobre OkHttp, hacia `firestore.googleapis.com`), y solo cuando el código la usa. **V1 queda cerrada.** |
| **V2** · ¿Alguna operación básica transmite en Android? | **No apareció ningún tráfico.** En las 7 operaciones, con 4 instrumentos, la fila del UID de la app no existe en los contadores del sistema (0 bytes y 0 paquetes, UDP incluido), no hay ningún socket TCP ni UDP del UID y la sonda de T-44 registró 0 extremos remotos. **V2 queda cerrada para las operaciones de la lista**, con los límites de 2.5. |
| **V3** · ¿El respaldo automático de Android cuenta como «recopilar»? | **Sigue abierta.** Nada de esta medición la toca: el respaldo lo hace el sistema, no la app. |

**Un hallazgo que cambia cómo leer el tramo de segundo plano** (detalle en 2.5): mientras la app está en
segundo plano, Android marca su red como bloqueada (`blocked=APP_BACKGROUND`). Por eso un cero en ese
tramo no demuestra, por sí solo, que la app no intentaría transmitir. Se agregó un tramo de 5 minutos
**con la app en primer plano y sin tocarla**, en el que el sistema sí le permite usar la red; también dio cero.

---

## 1. V1 · El árbol de dependencias de la configuración release

### 1.1 Qué se corrió

```
set JAVA_HOME=C:\Program Files\Android\Android Studio\jbr
cd C:\Proyectos\proyecto-baystream\android
gradlew.bat :app:dependencies --configuration releaseRuntimeClasspath --console=plain
```

- **Resultado:** `BUILD SUCCESSFUL in 10s`, 11:23 del 2-oct-2026.
- **No compiló la app.** Las tareas fueron `:app:dependencies` y cuatro del módulo del complemento de
  Flutter para Gradle (`:gradle:*`), que salieron `UP-TO-DATE`, `NO-SOURCE` o `SKIPPED`. Gradle
  informó «5 actionable tasks: 1 executed, 4 up-to-date».
- **Es la configuración de la que salen el APK y el `.aab`:** la variante `release` del módulo `:app`.
- **Coherencia con T-64.** Coinciden los metadatos que T-64 leyó dentro del APK: `firebase-auth-interop 19.0.2`,
  `firebase-database-collection 18.0.1` y `play-services-base/basement 18.9.0`/`tasks 18.4.0`.

### 1.2 Lo que se buscó en el árbol

El árbol tiene 103 artefactos distintos en 43 grupos. Cada término se contó por separado:

| Se buscó | Apariciones | Qué sería |
|---|---:|---|
| `firebase-installations` | **0** | identificador por instalación (FID) |
| `firebase-analytics`, `play-services-measurement`, `play-services-analytics` | **0** | analítica |
| `firebase-crashlytics` | **0** | informes de fallos |
| `firebase-datatransport`, `datatransport`, `transport-runtime`, `transport-api` | **0** | envío de registros de Firebase |
| `firebase-messaging`, `firebase-config`, `firebase-perf` | **0** | mensajería, configuración remota, rendimiento |
| `play-services-ads`, `user-messaging-platform` | **0** | anuncios y consentimiento |
| `play-services-auth`, `com.google.android.play` | **0** | inicio de sesión, Play Core |
| `okhttp3` (de Square), `retrofit`, `volley`, `cronet`, `httpcomponents`, `androidx.work` | **0** | clientes HTTP y trabajo en segundo plano |
| `firebase-appcheck` | 1 | solo `firebase-appcheck-interop`: **interfaces**, sin código que transmita |
| `play-services-*` | 14 líneas | `base`, `basement` y `tasks`: bibliotecas cliente de Google Play services; no transmiten por su cuenta |

**Lo que sí hay y puede transmitir, y en qué condiciones:**

| Biblioteca | Para qué es | Condición para que transmita |
|---|---|---|
| `firebase-firestore 26.5.0` (por `firebase-bom 34.17.0`) con `grpc-okhttp`, `grpc-android` y `grpc-core 1.62.2` | acceso a Cloud Firestore | solo cuando el código llama a Firestore: **el flujo de usuario no lo hace** (T-64, 1.5) |
| `firebase-common 22.2.0`, `firebase-components 19.0.0` | inicialización y componentes | no abren conexiones |
| `play-services-base/basement/tasks` | clientes de Google Play services | los servicios los atiende la app de Google, con su propio UID |
| `okio 3.4.0` | entrada y salida | solo es una biblioteca de bytes |

**Dos huecos que el árbol no cubre**, para no leerlo de más:
- Es el árbol **resuelto de Gradle**, no las clases que R8 conserva en el APK final. T-64 ya cruzó las dos
  cosas con cadenas de texto del dex: solo aparece `firestore.googleapis.com`.
- No incluye el código nativo: `libflutter.so`, `libapp.so` y `libdatastore_shared_counter.so`. El primero
  trae el motor de Flutter, que puede abrir sockets si el código Dart se lo pide.

### 1.3 El árbol relevante (abreviado)

Se quitaron las líneas repetidas `(*)`, AndroidX, Kotlin y las anotaciones. El texto completo, de 457
líneas, queda en `build/t65/gradle-release-runtime.txt` (sin versionar).

```
releaseRuntimeClasspath
+--- org.jetbrains.kotlin:kotlin-stdlib:2.2.20
+--- io.flutter:armeabi_v7a_release | arm64_v8a_release | x86_64_release : 1.0.0-587c18f8…
+--- project :cloud_firestore
|    +--- project :firebase_core
|    |    +--- com.google.firebase:firebase-bom:34.17.0
|    |    +--- com.google.firebase:firebase-common -> 22.2.0
|    |    |    +--- org.jetbrains.kotlinx:kotlinx-coroutines-play-services:1.9.0
|    |    |    +--- com.google.android.gms:play-services-tasks -> 18.4.0
|    |    |    |    \--- com.google.android.gms:play-services-basement -> 18.9.0
|    |    |    +--- com.google.firebase:firebase-components:19.0.0
|    |    |    \--- com.google.firebase:firebase-annotations:17.0.0
|    |    \--- io.flutter:flutter_embedding_release:1.0.0-587c18f8…
|    +--- com.google.firebase:firebase-firestore -> 26.5.0
|    |    +--- com.google.firebase:protolite-well-known-types:18.0.1
|    |    |    \--- com.google.protobuf:protobuf-javalite:3.25.5
|    |    +--- com.google.firebase:firebase-appcheck-interop:17.0.0
|    |    +--- com.google.firebase:firebase-auth-interop:19.0.2
|    |    +--- com.google.firebase:firebase-database-collection:18.0.1
|    |    +--- com.google.android.gms:play-services-base -> 18.9.0
|    |    +--- com.google.android.gms:play-services-basement -> 18.9.0
|    |    +--- com.google.android.gms:play-services-tasks -> 18.4.0
|    |    +--- io.grpc:grpc-android:1.62.2
|    |    |    +--- io.grpc:grpc-api:1.62.2
|    |    |    \--- io.grpc:grpc-core:1.62.2   (gson, perfmark-api, grpc-context, guava)
|    |    +--- io.grpc:grpc-okhttp:1.62.2      (grpc-util, okio:3.4.0)
|    |    +--- io.grpc:grpc-protobuf-lite:1.62.2
|    |    +--- io.grpc:grpc-stub:1.62.2
|    |    \--- com.google.re2j:re2j:1.6
+--- project :file_picker
|    \--- project :flutter_plugin_android_lifecycle
+--- project :firebase_core (*)
\--- project :flutter_plugin_android_lifecycle (*)
```

<details>
<summary>Grupos de artefactos del árbol completo (43)</summary>

```
androidx.*: activity, annotation, arch.core, collection, concurrent, core, customview, datastore (preferences),
            fragment, interpolator, lifecycle, loader, profileinstaller, savedstate, startup, tracing,
            versionedparcelable, viewpager, window
com.getkeepsafe.relinker: relinker
com.google.android: annotations
com.google.android.gms: play-services-base, play-services-basement, play-services-tasks
com.google.code.findbugs: jsr305 · com.google.code.gson: gson · com.google.errorprone: error_prone_annotations
com.google.firebase: firebase-annotations, firebase-appcheck-interop, firebase-auth-interop, firebase-bom,
                     firebase-common, firebase-components, firebase-database-collection, firebase-firestore,
                     protolite-well-known-types
com.google.guava: failureaccess, guava, listenablefuture · com.google.protobuf: protobuf-javalite
com.google.re2j: re2j · com.squareup.okio: okio, okio-jvm · commons-io: commons-io
io.flutter: arm64_v8a_release, armeabi_v7a_release, flutter_embedding_release, x86_64_release
io.grpc: grpc-android, grpc-api, grpc-context, grpc-core, grpc-okhttp, grpc-protobuf-lite, grpc-stub, grpc-util
io.perfmark: perfmark-api · javax.inject: javax.inject · org.apache.tika: tika-core
org.checkerframework: checker-qual · org.codehaus.mojo: animal-sniffer-annotations
org.jetbrains: annotations · org.jetbrains.kotlin: stdlib (+ jdk7, jdk8, common), parcelize-runtime
org.jetbrains.kotlinx: coroutines-android, -bom, -core, -core-jvm, -play-services · org.slf4j: slf4j-api
```

</details>

### 1.4 Qué cierra V1

- **No hay Firebase Installations** en la configuración release. La fila «Firebase Core (Installations)» de T-64,
  1.4, que describía un identificador por instalación (FID), **no aplica a este APK**.
- **No hay analítica, informes de fallos, mensajería, anuncios ni transporte de registros.** La
  inicialización de Firebase (`main.dart`) no puede, por sí misma, enviar nada a esos servicios.
- **Lo que queda de la página de Firebase:** Cloud Firestore recopila el *user agent* de Firebase, que Google no
  vincula a un usuario ni a un dispositivo, **cuando el SDK hace una petición**. Eso depende de V2, que no
  encontró ninguna.

---

## 2. V2 · La red del Honor en cada operación básica

### 2.1 Condiciones

| | |
|---|---|
| **Dispositivo** | **Honor X5d / Android 15** |
| **App** | `gt.cmartinez.baystream`, `versionName 1.0.0`, UID **10231** |
| **APK instalado** | SHA-256 del `base.apk` bajado del teléfono: **`C9A91F86FCD163A23EF027311E5123CCD19421535D8F968D167C7884A169731E`**, **coincide** con T-44. Firmado con el certificado de subida (SHA-256 `4cc0f6b1…a83020c4`) |
| **Instalación** | 1-oct-2026 22:46:16; el teléfono arrancó el 23-sep-2026, así que **no se reinició desde la instalación** y los contadores cubren todo ese tiempo |
| **Red** | Wi-Fi (`wlan0`); sin red móvil; modo avión apagado; `INTERNET` y `ACCESS_NETWORK_STATE` concedidos |
| **Estado de la app** | no estaba en ejecución al empezar; cinco viajes en Recientes (ALFA ×2, ECO ×2, DELTA); la app no está bloqueada por el ahorro de datos (`Restrict background: false`) |
| **Ventana** | 11:29:19 a 11:54:19 del 2-oct-2026; las operaciones ocurrieron entre las 11:29:30 y las 11:49:15 |

### 2.2 Los instrumentos

| # | Instrumento | Qué mide | Cómo |
|---|---|---|---|
| **A** | **Sonda de T-44**, `tool/t44_honor_red.ps1`, **sin cambios** | extremos remotos TCP del UID, con el instante en que aparecen | `-Uid 10231 -Segundos 1500`; lee `/proc/net/tcp` y `tcp6` por ADB |
| **B** | **Sondeo de sockets TCP y UDP** (guion propio, en la carpeta temporal de la sesión, **no versionado**) | **todo** socket del UID en `tcp`, `tcp6`, `udp` y `udp6`, también los sin destino | las mismas lecturas con `for f in tcp tcp6 udp udp6; do echo "==$f"; cat /proc/net/$f; done`, filtrando la columna del UID |
| **C** | **Contadores por UID del sistema** | bytes y paquetes recibidos y enviados por UID, **de todo el tráfico IP: TCP, UDP e ICMP**, sin muestreo | `adb shell dumpsys netstats --full --uid`, sección *BPF map content → `mAppUidStatsMap`* (contadores eBPF del kernel, en tiempo real); se leyó la fila del UID **antes y después de cada operación** |
| **D** | **Historial del servicio de estadísticas** | lo que el sistema registró por UID, interfaz y etiqueta | `dumpsys netstats --poll` (sondeo forzado) y después el volcado completo, buscando el UID en todas las secciones |

**Cómo se repite C**, que es el que cubre UDP:

```
adb shell dumpsys netstats --full --uid
  → en «mAppUidStatsMap», la fila   <uid> <rxBytes> <rxPackets> <txBytes> <txPackets>
  → si el UID no tiene fila, el sistema no contó ningún paquete suyo
```

### 2.3 Controles positivos: los instrumentos sí ven lo que dicen ver

Una medición que da cero necesita demostrar que no está ciega. Con el UID 2000 (el shell del teléfono):

| Instrumento | Estímulo | Lo que vio |
|---|---|---|
| **C** contadores | un datagrama UDP de 5 bytes a `8.8.8.8:53` | `txBytes` 1 700 → 1 733 (**+33** = 5 de datos + 28 de cabeceras IP y UDP) y `txPackets` 25 → 26 (**+1**) |
| **C** contadores | `ping -c 2` a `8.8.8.8` | +168 bytes y +2 paquetes en cada sentido (**ICMP**) |
| **B** sondeo TCP/UDP | el mismo datagrama UDP | `udp <local> → 08080808:0035` (8.8.8.8:53) a los 3 055 ms |
| **A** sonda de T-44 | una conexión TCP a `8.8.8.8:53` | `8.8.8.8:53` a los 2 991 ms |
| **D** historial | `dumpsys netstats --poll` | el volcado sí lista al UID 2000 (historial y mapa por app); al UID 10231, no |

### 2.4 Resultado, operación por operación

Cada fila tiene una foto de contadores justo antes y otra justo después (31 fotos en total, en
`build/t65/contadores.csv`). Las marcas de tiempo están en `build/t65/marcas.csv`.

| # | Operación (lo que se hizo exactamente) | Ventana | Contadores (UID 10231) antes → después | Sockets del UID |
|---|---|---|---|---:|
| 0 | **Arranque en frío** de la app | 11:29:30–11:29:42 | sin fila → sin fila: **0 B / 0 paquetes** | 0 |
| 1 | **Abrir un viaje desde Recientes**: «Viajes recientes» → BUQUE ALFA, V01N, 977 contenedores | 11:29:52–11:30:15 | sin fila → sin fila: **0 / 0** | 0 |
| 2a | **Búsqueda**: «Buscar contenedor», se escribió `EDUU0994165` en dos tramos; 1 resultado | 11:30:23–11:30:40 | sin fila → sin fila: **0 / 0** | 0 |
| 2b | **Estadísticas**: pestaña Estadísticas (977 contenedores, 34 bahías, 50 reefers) y dos desplazamientos | 11:31:08–11:31:30 | sin fila → sin fila: **0 / 0** | 0 |
| 3 | **Panel de validación** («Alertas de estiba»): se abrió, se desplazó y se siguió el enlace «Ver» hasta el Bay Plan | 11:31:37–11:32:30 | sin fila → sin fila: **0 / 0** | 0 |
| 4 | **Editar el perfil del buque** (ALFA): filas a babor 6 → 7 y «Confirmar y ver el plano» (guarda) | 11:32:38–11:33:38 | sin fila → sin fila: **0 / 0** | 0 |
| 4b | **Restaurar el perfil**: filas a babor 7 → 6 y guardar (para dejar el dato de prueba como estaba) | 11:33:46–11:34:24 | sin fila → sin fila: **0 / 0** | 0 |
| 5 | **Exportar el PDF**: «Exportar viaje» → PDF → selector de archivos del sistema → «Guardar» en Descargas (268 508 bytes) | 11:34:30–11:35:27 | sin fila → sin fila: **0 / 0** | 0 |
| 6 | **Eliminar un viaje guardado de prueba**: el segundo «BUQUE ALFA · V01N» de Recientes (un duplicado de A01); Recientes pasó de 5 a 4 | 11:35:37–11:36:08 | sin fila → sin fila: **0 / 0** | 0 |
| 7 | **Segundo plano, 5 minutos**: botón Inicio; una foto por minuto; el proceso (pid 13145) siguió vivo | 11:36:25–11:41:27 | sin fila en las 6 fotos: **0 / 0** | 0 |
| 7b | **Primer plano en reposo, 5 minutos**, sin tocar la app (pantalla encendida y la app arriba en cada foto) | 11:44:11–11:49:15 | sin fila en las 7 fotos: **0 / 0** | 0 |

**Los otros tres instrumentos, sobre toda la ventana de 25 minutos:**

| Instrumento | Resultado |
|---|---|
| **A** sonda de T-44 (1 500 s) | **0 extremos remotos distintos** (`build/t65/honor-red-ops.json`: `"extremos": []`) |
| **B** sondeo TCP/UDP | **3 646 lecturas** (una cada ≈0.41 s, que incluye el tiempo de ADB) y **0 sockets distintos** del UID, de ningún protocolo |
| **D** historial, tras `dumpsys netstats --poll` a las 11:42:51 | **0 menciones del UID 10231** en las 2 854 líneas del volcado: ni en el historial de 2 horas, ni en las etiquetas, ni en los mapas BPF |

**Una observación que sale de D:** que la fila del UID **no exista** significa que, según el sistema, no
contó ni un paquete suyo desde que se instaló el APK el 1-oct a las 22:46. Eso abarca las siete cargas de
EDI, el archivo inválido y las mediciones de T-44, además de las de hoy; pero el mapa no registra *cuándo*
ocurrió algo, así que solo las ventanas de esta sesión tienen foto antes y después.

### 2.5 Lo que cada instrumento no puede ver

| Límite | Instrumentos afectados | Cómo se mitiga | Lo que queda |
|---|---|---|---|
| **El tramo de segundo plano está bloqueado por el sistema.** Con la app en segundo plano, `dumpsys netpolicy` la muestra con `proc_state=LAST` y `blocked=APP_BACKGROUND`; «Background firewall chain enabled: true». Al pasar a primer plano, las reglas cambian a `background-allow` y `proc_state=TOP`. Un cero en ese tramo se explica, en parte, por el bloqueo | C y D | **7b**: 5 minutos en primer plano y en reposo, con la red permitida; los tres instrumentos dieron cero. Además, un intento de conexión TCP bloqueado normalmente deja un socket que A y B habrían visto (**no se comprobó en este teléfono**) | un datagrama UDP de menos de ≈0.4 s en el tramo bloqueado podría no verse |
| **Sockets de vida muy corta.** Un socket que se abra y se cierre entre dos lecturas no se ve | A y B | C lo cubre en primer plano: cuenta cada paquete, no depende del muestreo | ninguno, mientras el tráfico no esté bloqueado |
| **Sin UDP ni QUIC** | A | B, C y D sí los cuentan | ninguno |
| **Consultas DNS.** Las atiende el sistema; la tabla de sockets del UID no las ve, y no hay evidencia aquí de a quién se las atribuye el contador | A, B y C | si la app hubiera ido a conectarse, habría un socket o paquetes en su UID | una app que solo resolviera nombres, sin conectar, no se distinguiría |
| **Trabajo hecho por otras apps en nombre de la app.** Google Play services y el selector de archivos del sistema tienen su propio UID | todos | el árbol de V1 muestra que solo hay clientes de Google Play services; el PDF se guardó en Descargas | no se probó exportar hacia Google Drive u otro destino en la nube: ahí quien transmite es la app de destino, por acción del usuario |
| **Solo Wi-Fi.** El Honor no tiene red móvil | todos | — | — |
| **Cobertura de operaciones.** Solo las de la lista de la ficha. Falta medir **Perfiles guardados**, exportar **CSV y JSON**, recorrer todas las bahías del Bay Plan, **Limpiar datos** y la carga de archivos que no sean A01 | todos | T-44 midió el arranque en frío y la carga de A01 | cubrir lo que falta: ≈0.5 h (**V10**, nueva) |

### 2.6 Estado en que queda el Honor

- La app está en segundo plano; no estaba en ejecución cuando empecé.
- El PDF de prueba `BayStream_BUQUE ALFA_V01N (2).pdf` **se borró**. Quedan los dos de T-42, del 27-sep,
  `…V01N.pdf` y `…V01N (1).pdf`.
- El perfil de ALFA quedó como estaba (13 columnas × 12 niveles = 156 huecos por bahía).
- Recientes tiene **4** viajes en vez de 5: se eliminó un duplicado de A01 (el archivo sigue en Descargas).
- No se cambió ningún ajuste del teléfono.

---

## 3. Qué cambia en T-64

| Parte de T-64 | Cambio |
|---|---|
| **1.3** (bibliotecas dentro del APK) | se confirma con el árbol de Gradle: 103 artefactos, **ninguna** biblioteca de analítica, Installations, informes de fallos o anuncios |
| **1.4** (página de Firebase) | la fila **Installations no aplica**; el *user agent* de Firestore solo viaja si el SDK hace una petición, y V2 no encontró ninguna |
| **1.6** (lo que midió RNF-004) | la tabla gana la **mitad Android que le faltaba** a RNF-004 en T-63: las 7 operaciones, con 4 instrumentos, dieron cero. La sonda ya no es el único instrumento |
| **1.7** (verificaciones pendientes) | **V1 y V2 se cierran.** V3 sigue abierta. Nueva **V10**: medir lo que no entró en la lista (2.5). V4 a V9 no cambian |
| **2.6** (Seguridad de los datos) | la respuesta propuesta, «**no recopila ni comparte**», **no cambia**. De las tres dudas que T-64 daba como bloqueantes (V1, V2, V3), **solo queda V3**. Sigue sin declararse hasta que Carlos resuelva D3 |
| **3.3** (borrador de la política) | cambia solo la nota: la sección «Qué envía» **ya no depende de V1 ni de V2**, que están cerradas. El párrafo del respaldo de Android sigue dependiendo de D3 (V3) |
| **2.3 y 3.1 a 3.4** | no cambian |

**Lo que esta medición no dice.** No dice que la app *nunca* transmitirá. Dice que, en esta versión
(`C9A91F86…`), en las operaciones listadas y en las condiciones de 2.1, el sistema no contó ningún
paquete del UID de la app, y que el código tampoco usa Firestore en el flujo de usuario. Si cambia
`lib/`, hay que repetirlo.

## 4. Evidencia (sin versionar, en `build/t65/`)

- **V1:** `gradle-release-runtime.txt` (salida completa), `gradle-arbol-relevante.txt` y `gradle-artefactos.txt`.
- **Contadores:** `contadores.csv` (31 fotos del UID 10231 y 2 del control), `marcas.csv` (ventana de cada
  operación), `netstats-full-final.txt` (volcado completo tras el sondeo forzado).
- **Sondeos:** `honor-red-ops.log` y `honor-red-ops.json` (sonda de T-44), `sockets-udp-tcp.log` (sondeo B),
  y los controles `control-sockets-*.log` y `control-sonda-uid2000.log`.
- **Capturas** de cada operación: `op1-viaje-abierto.png` a `op6-eliminado.png`.

Los guiones del sondeo B y de la foto de contadores viven en la carpeta temporal de la sesión y no se
versionan. Todo lo que hacen está en las órdenes de 2.2.

## 5. Archivos

- Nuevo: `docs/T65-RESULTADOS.md`.
- No se tocó `lib/`, `test/`, `pubspec.*`, `android/`, `web/`, `tool/` ni ningún archivo versionado más. `tool/t44_honor_red.ps1`
  se usó sin cambios.
- Sin versionar: `build/t65/`.
