# T-136 · El parche de seguridad de Firestore en Windows, candidata 1.0.0

Timonel (Claude Code, Opus 5.5), 3-nov, en `C:\Proyectos\baystream-rediseno`, rama `sprint-4`, sobre `8ea84bd`.

## Resultado

Windows enlaza el SDK de C++ **13.13.1**. La versión es `1.0.0+9`. La suite da **2101 de 2101**, sin omitidas, `analyze` cero, y Windows, el AAB y la Web compilan. Sin el archivo privado de Firebase.

La tarea creció dos veces respecto a la 10.99, las dos con autorización de Carlos:

1. **`web/` sí cambia.** `firebase_core_web` 3.12.0 exige el SDK de JavaScript 12.19.0, y T-92 servía el 12.17.0. La 3.11.0 tampoco servía: pide el 12.18.0.
2. **`firebase_auth` sí cambia, de 6.5.7 a 6.7.1.** La 6.5.7 no compila en Android con `firebase_core` 4.15.2.

**Lo que no se probó y le toca a la aceptación de Codex:** ninguna app se abrió. El arranque y la sincronización de la Web y el inicio de sesión en los tres clientes no están probados. La suite no toca código nativo, y `firebase_auth` 6.6.0 reescribió en Kotlin las cuentas de Android. `tool/t93_msix.ps1` tampoco se corrió de punta a punta, porque no se firma ni se arma el MSIX.

## pubspec.yaml

```diff
-version: 0.4.2+8
+version: 1.0.0+9
-  firebase_core: ^4.4.0
-  cloud_firestore: ^6.1.2
+  firebase_core: ^4.15.2
+  cloud_firestore: ^6.10.2
-  # Cuentas de RF-034 (T-79, autorizada en 2.7). Fija en la versión que T-70
-  # y T-70c probaron con firebase_core 4.13.0 y cloud_firestore 6.8.0.
-  firebase_auth: 6.5.7
+  # Cuentas de RF-034 (T-79, autorizada en 2.7). Fija desde T-136 en la versión
+  # que FlutterFire publicó con firebase_core 4.15.x: la 6.5.7 no compila en
+  # Android con la 4.15.2, porque customAuthDomain cambió de clase en la 4.14.0.
+  firebase_auth: 6.7.1
-  # Fija en la versión que ya traía el lock como transitiva; solo de pruebas.
-  cloud_firestore_platform_interface: 8.0.6
+  # Fija y solo de pruebas. T-136 (10.99) la sube a 8.0.7, la única posible:
+  # cloud_firestore 6.10.2 pide ^8.0.7, y de la 8.0.8 en adelante piden
+  # firebase_core 5.
+  cloud_firestore_platform_interface: 8.0.7
-  msix_version: 0.4.2.0
+  msix_version: 1.0.0.0
```

## pubspec.lock

Cambian diez paquetes: los siete de la 10.99 y los tres que autorizó Carlos. Ninguno más, y Flutter sigue en la 3.38.9.

| Paquete | Antes | Después | Origen |
|---|---|---|---|
| `cloud_firestore` | 6.8.0 | 6.10.2 | 10.99 |
| `firebase_core` | 4.13.0 | 4.15.2 | 10.99 |
| `cloud_firestore_platform_interface` | 8.0.6 | 8.0.7 | 10.99 |
| `cloud_firestore_web` | 5.7.2 | 5.7.3 | 10.99 |
| `firebase_core_platform_interface` | 8.1.0 | 8.1.1 | 10.99 |
| `firebase_core_web` | 3.10.0 | 3.12.0 | 10.99 |
| `_flutterfire_internals` | 1.3.76 | 1.3.77 | 10.99 |
| `firebase_auth` | 6.5.7 | 6.7.1 | Carlos, tras el fallo del AAB |
| `firebase_auth_platform_interface` | 9.0.6 | 9.1.0 | Carlos, resuelto por pub |
| `firebase_auth_web` | 6.2.6 | 6.3.0 | Carlos, resuelto por pub |

## El SDK de C++

`windows/CMakeLists.txt` de `firebase_core` 4.15.2:

```
set(FIREBASE_SDK_VERSION "13.13.1")
```

La primera compilación (`build/t136/build-windows.log`):

```
-- [download 0% complete]
...
-- [download 100% complete]
-- Could NOT find PkgConfig (missing: PKG_CONFIG_EXECUTABLE)
-- Configuring done (66.2s)
```

- **Descarga:** unos 38 s. El zip `firebase_cpp_sdk_windows_13.13.1.zip` pesa 963.835.368 bytes (919 MiB).
- **Extracción:** CMake no imprime nada al extraer. La evidencia es que «Using cached extracted Firebase SDK» no aparece, la pausa de unos 28 s después del 100 % y la carpeta `extracted` nueva, de 8,5 GB, con hora 16:11:44.
- **Enlazado:** `..\extracted\firebase_cpp_sdk_windows\libs\windows\VS2019\MD\x64\Release\…`. `extracted-13.9.0` no aparece en el registro.

`build\windows\x64\extracted\firebase_cpp_sdk_windows\include\firebase\version.h`:

```
#define FIREBASE_VERSION_MAJOR 13
#define FIREBASE_VERSION_MINOR 13
#define FIREBASE_VERSION_REVISION 1
```

La compilación final ya dice «Using cached extracted Firebase SDK», que ahora es correcto: `-Verificar` da `pedida 13.13.1, extraida 13.13.1`.

## tool/t136_sdk_firebase.ps1

Hace lo que pide el encargo, con `-Apartar`, `-Verificar` y `-Proyecto`. Dos decisiones propias:

- Si `extracted` existe sin `version.h`, `-Apartar` lo renombra a `extracted-desconocida`: es una extracción a medias, y CMake la daría por buena.
- Si el destino ya existe, se detiene. No borra nada.

**Un fallo mío, corregido.** La primera versión ponía `Split-Path -Parent $PSScriptRoot` como valor por defecto del parámetro. Con `-File`, PowerShell 5.1 deja `$PSScriptRoot` vacío ahí, y el script se cayó al correrlo sin `-Proyecto`. Mi ensayo no lo vio porque siempre pasaba `-Proyecto`. Pasó al cuerpo del script. En ese intento no se renombró nada.

Ensayo en una copia temporal fuera de `build\` (`build/t136/script-copia-temporal.log`):

| Caso | Resultado |
|---|---|
| `version.h` real de 13.9.0, `-Verificar` | Se detiene: «Pedida: 13.13.1. Extraida: 13.9.0.» |
| 13.9.0, `-Apartar` | Lo renombra a `extracted-13.9.0` |
| Sin `extracted`, `-Verificar` | Se detiene: falta `version.h` |
| Sin `extracted`, `-Apartar` | No hace nada |
| 13.13.1, `-Verificar` | Pasa |
| 13.13.1, `-Apartar` | No lo mueve |
| Sin `version.h`, `-Verificar` | Se detiene |
| Sin `version.h`, `-Apartar` | `extracted-desconocida` |
| Destino ocupado, `-Apartar` | Se detiene sin borrar |
| Llamado con `&` desde otro script | El `throw` detiene al que llama |
| `rootUri` relativa | Pasa |

**En `tool/t93_msix.ps1` (+6 líneas):** antes de compilar, `flutter pub get` y `-Apartar`. `-Verificar` queda fuera del bloque de compilar, así que corre también con `-SinCompilar`, y siempre antes de `msix:create`.

**La prueba nueva** (`T-136 el script comprueba el SDK de Firebase antes de empaquetar`) busca los comandos de verdad, porque el encabezado del script también nombra `flutter build windows` y `dart run msix:create`. Corrida por nombre, pasa: 13 de 13 entre `t92_web_test.dart` y `t93_msix_config_test.dart`. Con el `-Verificar` movido dentro del bloque de compilar, falla (`Expected: not null`). El script se restauró y su huella es igual a la del respaldo.

## web/vendor/firebase/12.19.0

Con el procedimiento del LEEME de T-92:

- tres módulos de `https://www.gstatic.com/firebasejs/12.19.0/`;
- `https://www.gstatic.com/firebasejs/12.19.0/firebase-app.js` pasa a `./firebase-app.js` en los imports de auth y pipelines, y en `name$q` y `Logger` de `firebase-app.js`, los mismos sitios que en la 12.17.0. Cada reemplazo acorta 41 bytes, lo que cuadra con los tamaños, y no queda ninguna referencia a `gstatic`;
- auth y pipelines solo importan `./firebase-app.js`;
- `firebase-firestore-pipelines.js` sigue siendo el que inyecta `firebase_core_web` 3.12.0;
- `LICENSE.txt` es igual al de la 12.17.0, salvo por el fin de línea.

**El cotejo con npm.** Yov dio las huellas de `firebase@12.19.0` y las tres coinciden con lo descargado. También está en el LEEME de la carpeta.

| Módulo | Original y npm | Servida |
|---|---|---|
| `firebase-app.js` | `39A50952B5DEF557337B2290069C7D7371F3515AD46C44A43B9C520F734D8D14` | `6831B388C680B3335204FC1EFBCA6D494841949600DF6B6BA3829B3534CBFA1B` |
| `firebase-auth.js` | `59F60CE3ADCB4C85A5260E963FD14134EEC088DE5B18DDFB9E95771C72F65264` | `0F99FC82C189CC62A37EF58558BBE91A54B83D47A8592B03144E3DC15C678B5C` |
| `firebase-firestore-pipelines.js` | `E9BB207298105253EB73336C2478A0C30BC31631960EA1BF7CB4B6C87CE05F05` | `0C4E645F0CF31B5553E71922C29EB0314A998940A7949141A668340FBE749A98` |

`web/flutter_bootstrap.js:39` apunta a 12.19.0, y `web/vendor/firebase/12.17.0/` salió entera para que se publique un solo SDK.

**Se quedan como están,** por decisión de Carlos: `tool/t129_evidencia.py`, que es la evidencia de T-129, corrió con la 12.17.0 y ya no encuentra esa carpeta en el árbol; la mención de `test/t99_instrumentos_test.dart:85` y la de `test/support/t129_fake_firestore.dart:29`.

## Las corridas

Una a la vez, con la luz verde de Carlos y su línea `SEMÁFORO:`. Los registros están en `build/t136/`.

| # | Corrida | Resultado | Tiempo | ¿Vale? |
|---|---|---|---|---|
| 1 | `flutter pub get` | Siete paquetes | 4 s | No: faltaba `firebase_auth` |
| 2 | Suite | **2098 de 2101, 3 en rojo**: las tres de T-92 | 140 s | No |
| 3 | Suite, con la 12.19.0 | 2101 de 2101 | 114 s | No: `firebase_auth` 6.5.7 |
| 4 | `flutter analyze` | Cero | 43 s | No: ídem |
| 5 | T-92 y T-93 por nombre | 13 de 13, y el rojo de T-136 | Menos de un minuto | Sí: no dependen de `firebase_auth` |
| 6 | `flutter build windows --release --no-pub -v` | Salida 0; baja y extrae el 13.13.1 | 125 s | Solo para el SDK |
| 7 | `flutter build appbundle` | **Falló**: `firebase_auth` 6.5.7 | 66 s | No |
| 8 | `flutter build web` | Salida 0 | 51 s | No: ídem |
| 9 | `t92_verify.dart build/web` | Correcto: 57 archivos, 38.137.915 bytes | 1 s | No: ídem |
| 10 | `flutter pub get` | Tres paquetes más | 4 s | **Sí** |
| 11 | Suite | **2101 de 2101**, sin omitidas | 135 s | **Sí** |
| 12 | `flutter analyze` | **Cero** (`No issues found!`) | 35 s | **Sí** |
| 13 | `flutter build windows --release --no-pub -v` | Salida 0 | 46 s | **Sí** |
| 14 | `t136_sdk_firebase.ps1 -Verificar` | Pasa | Menos de 1 s | **Sí** |
| 15 | `flutter build appbundle --release --build-name=1.0.0 --build-number=9` | Salida 0; 53.977.619 bytes | 86 s | **Sí** |
| 16 | `flutter build web --release --build-name=1.0.0 --build-number=9` | Salida 0 | 57 s | **Sí** |
| 17 | `dart run tool/t92_verify.dart build/web` | Correcto: 57 archivos, 38.138.088 bytes | 2 s | **Sí** |

**El error de la corrida 7:**

```
firebase_auth-6.5.7\android\...\FlutterFirebaseAuthPlugin.java:140: error: cannot find symbol
  String customDomain = FlutterFirebaseCorePlugin.customAuthDomain.get(pigeonApp.getAppName());
  symbol:   variable customAuthDomain
Execution failed for task ':firebase_auth:compileReleaseJavaWithJavac'.
```

`firebase_core` 4.14.0 migró Android a Kotlin y movió `customAuthDomain` a `FlutterFirebasePlugin`. El pubspec de `firebase_auth` 6.5.7 pide `^4.13.0`, así que pub lo acepta y el error solo sale al compilar.

**Lo comprobado en las compilaciones finales:**

- Windows: `version.h` 13.13.1.
- AAB: `versionCode="9"`, `versionName="1.0.0"`, firmado con `CN=Android Debug`, no se sube. Compiló con Kotlin 2.2.20 y sin cambiar `android/`. No hay `android/key.properties` en esta carpeta.
- Web: `version.json` dice 1.0.0 y 9, y `build/web/vendor/firebase/` solo trae el 12.19.0.
- `// ignore:` nuevos: ninguno.
- `windows/flutter/`, `android/` y `lib/`: sin cambios.

## Lo que queda abierto

- **Codex, en la aceptación:** arranque y sincronización de la Web; inicio de sesión en Android, Windows y la Web. En su carpeta, `extracted` sigue siendo el 13.9.0: necesita `-Apartar` antes de compilar.
- **Android cambia más de lo que dice la 10.99:** el BoM de Firebase pasa de 34.17.0 a 34.19.0, y las cuentas pasan a Kotlin.
- **Carlos, después de publicar la 1.0.0:** borrar `build\windows\x64\extracted-13.9.0` (8,5 GB) y `firebase_cpp_sdk_windows_13.9.0.zip` en cada carpeta. Quedan 65 GB libres.
- **La lista de la 1.0.0:** la comprobación del SDK en `proyecto-baystream` la hace ahora `tool/t93_msix.ps1`.

## Archivos

`pubspec.yaml` y `pubspec.lock` **sí cambian**.

- Modificados: `pubspec.yaml`, `pubspec.lock`, `tool/t93_msix.ps1`, `test/t93_msix_config_test.dart`, `web/flutter_bootstrap.js`.
- Nuevos: `tool/t136_sdk_firebase.ps1`, `docs/T136-RESULTADOS.md`, y en `web/vendor/firebase/12.19.0/`: `LEEME.md`, `LICENSE.txt`, `firebase-app.js`, `firebase-auth.js`, `firebase-firestore-pipelines.js` y `provenance.json`.
- Borrados, en `web/vendor/firebase/12.17.0/`: los mismos seis nombres.

## Bloque de Git

Para Carlos, en `C:\Proyectos\baystream-rediseno`:

```bash
git add -- pubspec.yaml
git add -- pubspec.lock
git add -- tool/t93_msix.ps1
git add -- tool/t136_sdk_firebase.ps1
git add -- test/t93_msix_config_test.dart
git add -- web/flutter_bootstrap.js
git add -- web/vendor/firebase/12.19.0/LEEME.md
git add -- web/vendor/firebase/12.19.0/LICENSE.txt
git add -- web/vendor/firebase/12.19.0/firebase-app.js
git add -- web/vendor/firebase/12.19.0/firebase-auth.js
git add -- web/vendor/firebase/12.19.0/firebase-firestore-pipelines.js
git add -- web/vendor/firebase/12.19.0/provenance.json
git add -- web/vendor/firebase/12.17.0/LEEME.md
git add -- web/vendor/firebase/12.17.0/LICENSE.txt
git add -- web/vendor/firebase/12.17.0/firebase-app.js
git add -- web/vendor/firebase/12.17.0/firebase-auth.js
git add -- web/vendor/firebase/12.17.0/firebase-firestore-pipelines.js
git add -- web/vendor/firebase/12.17.0/provenance.json
git add -- docs/T136-RESULTADOS.md
git commit -m "Sprint 4: T-136, el parche de seguridad de Firestore en Windows y la candidata 1.0.0"
git push
```

`test/t114_fase3_correccion_test.dart` y los generados de `windows/flutter/` aparecen modificados solo por el fin de línea: no entran.

## Tres líneas

1. Windows enlaza el SDK de C++ 13.13.1, y `tool/t93_msix.ps1` no deja empaquetar otro.
2. La versión es `1.0.0+9`, con diez paquetes de FlutterFire movidos, `firebase_auth` 6.7.1 y el SDK web 12.19.0.
3. Suite 2101 de 2101, `analyze` cero y los tres clientes compilan; falta que Codex pruebe el inicio de sesión y la Web.

## Para Yov

> T-136 lista para la aceptación de Codex: SDK de C++ 13.13.1 en Windows, `1.0.0+9`, suite 2101/2101, `analyze` cero, Windows, AAB y Web compilan, `t92_verify` correcto. Dos cambios sobre la 10.99, autorizados por Carlos: el SDK web pasó a 12.19.0 (cotejado con npm; salió la 12.17.0) y `firebase_auth` a 6.7.1, con `platform_interface` 9.1.0 y `web` 6.3.0, porque la 6.5.7 no compila en Android con `firebase_core` 4.15.2. Aceptación: arranque y sincronización de la Web, e inicio de sesión en los tres clientes, que nadie probó todavía; las cuentas de Android pasaron a Kotlin. Codex debe apartar el 13.9.0 en su carpeta. Informe: `docs/T136-RESULTADOS.md`.
