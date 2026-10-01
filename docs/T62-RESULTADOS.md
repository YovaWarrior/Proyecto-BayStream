# T-62 · Preparar T-47: separar H5 de `main.dart` y analizar qué usa el producto de Firebase

Timonel · 1-oct-2026 · Base: `4f4fabc` · Codex fuera de sesión.

**No se tocó `lib/`, `main.dart`, los archivos congelados ni `pubspec.*`.** Sin dependencias
nuevas. Archivos nuevos: `tool/h5_main.dart`, `tool/t62_h5_opciones.ps1` y este informe.
Evidencia en `build/t62/`, ignorada por Git.

## 1. Punto de entrada de H5

`tool/h5_main.dart` abre `LatencyTestScreen` y `C3ReconciliationScreen` importándolas tal cual. Si
faltan opciones de Firebase, no se conecta a nada: muestra un aviso. Las
opciones se leen con `String.fromEnvironment`, desde `--dart-define-from-file`. La regla de
plataforma es la de `main.dart`: opciones Web en Web, Android en el resto.

La pantalla inicial tiene tres botones: las dos pantallas y **«Comprobar conexión (solo
lectura)»**. Ese botón hace un conteo de agregación sobre `latency_test` y un `get` de
`voyages/c3-measurement-voyage`, los dos contra el servidor, y escribe en consola
`H5_CHECK:<conteo>:<existe>`. No agrega, modifica ni borra nada.

**Archivo privado de opciones.** `C:\Proyectos\baystream-privado\h5-temporal.json`, fuera del
repositorio. Lo creó `tool/t62_h5_opciones.ps1`, que copia los valores de `lib/main.dart` sin
imprimirlos: solo muestra los nombres de las claves y si tienen valor. Además se niega a escribir
dentro del repositorio y comprueba que Web y Android comparten clave, proyecto y emisor. Las siete
claves quedaron con valor: `H5_API_KEY`, `H5_PROJECT_ID`, `H5_MESSAGING_SENDER_ID`,
`H5_STORAGE_BUCKET`, `H5_AUTH_DOMAIN`, `H5_WEB_APP_ID` y `H5_ANDROID_APP_ID`.

> **Antes de que T-47 retire las claves de `main.dart`, respalda ese JSON.** El script lo genera
> leyendo `main.dart`; después de T-47 ya no tendrá de dónde copiar.

**Comandos para lanzar H5:**

```
flutter run -d chrome -t tool/h5_main.dart --dart-define-from-file=C:\Proyectos\baystream-privado\h5-temporal.json
flutter run -d <dispositivo-android> -t tool/h5_main.dart --dart-define-from-file=C:\Proyectos\baystream-privado\h5-temporal.json
flutter build web --release -t tool/h5_main.dart --output build/t62/web --dart-define-from-file=C:\Proyectos\baystream-privado\h5-temporal.json
```

El tercero es el que se usó en esta verificación. Escribe en `build/t62/web` para no pisar el
`build/web` del producto. El `main.dart.js` compilado **lleva las opciones dentro**: así funciona
cualquier cliente Web de Firebase, y `build/` no se versiona.

`dart analyze tool/h5_main.dart`: **No issues found!**

## 2. Verificación en Chrome contra el proyecto temporal

**Qué escribe cada acción, leído antes de ejecutar nada:**

| Pantalla | Acción | Efecto en Firestore |
|---|---|---|
| Latencia | abrir | ninguno |
| Latencia | «Activar receptor» | **modifica** cada documento de `latency_test` con `respondido == false` |
| Latencia | «Ejecutar emisor» | **agrega** N documentos a `latency_test` |
| C3 | abrir | ninguno (crea `VesselRepositoryImpl`, sin red) |
| C3, solo Web | «Preparar ciclo» y «Aplicar cambio» | **escriben** `voyages/c3-measurement-voyage` |
| C3, fuera de Web | «Activar receptor C3» | solo lee ese documento (no aparece en Web) |

**Qué se ejecutó:** abrir la app, la comprobación de solo lectura, abrir la pantalla de latencia,
volver, abrir C3, volver. **No se pulsó ninguna de las acciones de la tabla que escriben.**

| Comprobación | Resultado |
|---|---|
| Proyecto mostrado | `baystream-h5-temporal-20260814` |
| `H5_CHECK` | **`103:true`**: 103 documentos en `latency_test`; `voyages/c3-measurement-voyage` existe |
| Pantalla de latencia | abre, con sus tres pasos y la tabla vacía |
| Pantalla C3 | abre, «Sin datos sincronizados», ningún ciclo preparado |

**103, no 99, es lo esperado:** §10.10 y §10.11 registran 99 de la serie de H5 (66 + 3 + 30)
más 4 de la verificación de T-45. La colección está como quedó el 25-sep.

**Límite de esta verificación:** la ventana de Chrome de la extensión se abrió oculta
(`visibilityState: hidden`), el caso que `AGENTS.md` ya describe. La primera lectura y las dos
aperturas se completaron. Los clics posteriores, una segunda lectura incluida, no avanzaron, y en
la recarga final no hubo ninguna petición a Firestore. No se repitió la verificación en el
Android de muelle.

## 3. Análisis para T-47 (sin decidir)

### Qué usa el producto de Firebase

- **Inicialización:** `lib/main.dart:26`, `Firebase.initializeApp` con opciones escritas en duro.
- **Uso efectivo:** ninguno. El único consumidor es `vesselRepositoryProvider`
  (`vessel_providers.dart:48-50`), y el producto solo llama a `parseBaplieFile`
  (`vessel_providers.dart:217`), que no va a la red. `saveVoyage`, `getVoyageById`,
  `watchVoyageById`, `getAllVoyages`, `deleteVoyage` y `searchContainers` no tienen llamadas en
  el producto.
- **Pero** el constructor de `VesselRepositoryImpl` evalúa `FirebaseFirestore.instance`
  (`vessel_repository_impl.dart:19`). Sin `initializeApp`, cargar un BAPLIE falla. Esa es la única
  razón por la que el producto necesita Firebase inicializado.
- **La pantalla C3 congelada usa `VesselRepositoryImpl()`** (`c3_reconciliation_screen.dart:21`)
  y sí escribe con él. Cambiar la clase rompería H5; si algo cambia, tiene que ser el *proveedor*.
- **Persistencia del producto:** completamente local (Hive, T-35 a T-37). Firestore no participa.
- **Pruebas:** ninguna inicializa Firebase ni llama a `main()`. Todas las que cargan un BAPLIE
  sustituyen `vesselRepositoryProvider` por `ParserOnlyRepository`.
- **Observado en red:** al iniciar, Firebase Web descarga `firebase-app.js` y el módulo de
  Firestore desde `www.gstatic.com`. Mientras nada use Firestore, no hay ninguna petición a
  Firestore.

### Opciones para `main.dart`

| | A · El producto sin Firebase | B · Firebase con opciones de un archivo, contra un proyecto de producción | C · Seguir contra el proyecto temporal, con las opciones fuera del código |
|---|---|---|---|
| Cambio | `main.dart` sin `initializeApp`; `vesselRepositoryProvider` usa un repositorio solo de parser (no `VesselRepositoryImpl`, para no tocar C3) | `main.dart` lee las opciones con `--dart-define-from-file`; crear proyecto y apps Web/Android | como B, pero apuntando a `baystream-h5-temporal-20260814` |
| **H-04** | cerrado: el producto no lleva ninguna clave | cerrado en el código fuente; el binario Web lleva las opciones, como cualquier cliente de Firebase | cerrado en el código fuente; el producto queda atado al proyecto de la evidencia |
| **RNF-004** («100 % de operaciones básicas sin transmisión») | el producto no descarga el SDK de Firebase. Quedan CanvasKit y fuentes de `gstatic`, que no son datos del usuario | sigue bajando el SDK al iniciar en Web; no transmite datos, pero la medición tiene que distinguirlo | igual que B |
| **Arranque en frío sin conexión, Web** | sin dependencia de Firebase | **riesgo por verificar:** si el SDK no se puede descargar, `initializeApp` podría fallar antes de `runApp`. Es una inferencia, no lo medí | igual que B |
| **H-06** | el producto no tiene servidor que registre; el registro sería local, o H-06 se declara no aplicable a una app local-first | solo habría Cloud Audit Logs si el producto usara Firestore, y no lo usa | sigue el problema de §10.13: con la variante B todo acceso es anónimo |
| **Pruebas existentes** | no cambian; conviene una nueva para el proveedor por omisión | no cambian | no cambian |
| **`pubspec.yaml`** | sin cambios: `tool/h5_main.dart` sigue usando `firebase_core` y `cloud_firestore` | sin cambios | sin cambios |
| **Riesgo para H5** | ninguno: H5 corre por `tool/h5_main.dart` | ninguno | mezcla clientes del producto con el proyecto de la evidencia |

### ¿El proyecto de producción necesita Firestore?

**No, con el producto de hoy.** El único Firestore que se usa es el de H5, y se queda en el
proyecto temporal. Con A, el proyecto de producción solo hace falta para **Hosting** (T-48), y ni
eso si la Web se publica en otro servicio. Con B, hace falta un proyecto de Firebase con apps Web
y Android registradas para que `initializeApp` funcione, pero sin habilitar Firestore.

## 4. Inventario del identificador `com.example.baystream`

Buscado en todo el árbol, sin contar `build/`, `.dart_tool/`, `docs/` ni `.git/`:

| Archivo | Línea | Qué cambia | Nota |
|---|---:|---|---|
| `android/app/build.gradle.kts` | 9 | `namespace = "com.example.baystream"` | debe coincidir con el paquete de `MainActivity` |
| `android/app/build.gradle.kts` | 24 | `applicationId = "com.example.baystream"` | el que ve Google Play; la línea 23 es un comentario TODO |
| `android/app/src/main/kotlin/com/example/baystream/MainActivity.kt` | 1 | `package com.example.baystream` | además hay que **mover el archivo** a la carpeta del paquete nuevo |
| `windows/runner/Runner.rc` | 92 | `CompanyName "com.example"` | metadatos del ejecutable, no identificador |
| `windows/runner/Runner.rc` | 96 | `LegalCopyright "… com.example …"` | ídem |

**Confirmado que no aparece** en:

- `AndroidManifest.xml` (usa `.MainActivity` relativo y `${applicationName}`), ni en los manifiestos
  `debug` y `profile`;
- `GeneratedPluginRegistrant.java`, que vive en `io.flutter.plugins`;
- `web/`, ni en un `google-services.json`, que no existe;
- iOS, macOS y Linux, que no existen en el proyecto.

El canal `baystream/local_store` y el nombre del paquete Dart (`baystream`) no dependen del
identificador.

**Consecuencias que conviene saber antes de cambiarlo:**

- En Android, un `applicationId` nuevo es **otra aplicación**. Las instalaciones de
  `com.example.baystream` (el Honor) conservan su almacén aparte, y no se migran: hoy solo tienen
  datos de prueba.
- En Windows, el almacén está fijo en `%LOCALAPPDATA%\BayStream` y no depende de `CompanyName`.
- En Web, el almacén depende del origen, no del identificador.

**Hallazgo para T-49:** el `release` de Android firma con la clave de depuración
(`build.gradle.kts:34-36`, `signingConfig = signingConfigs.getByName("debug")`). Hay que agregar
la configuración de firma propia.

## Archivos

Nuevos: `tool/h5_main.dart`, `tool/t62_h5_opciones.ps1`, `docs/T62-RESULTADOS.md`.

Fuera del repositorio, **no se versiona**: `C:\Proyectos\baystream-privado\h5-temporal.json`.
