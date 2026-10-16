# T-88 · Lo que pide Play: la política dentro de la app y en la Web, sin respaldo de Android

Timonel · 15-oct-2026 · rama `sprint-3`, sobre `3f29fc1` (decisión 10.45) · primera entrega (sin ícono)

**Resultado:** la política vive en una sola fuente de Dart puro. De ahí salen la pantalla, que se abre
desde Parámetros y desde el inicio de sesión sin viaje y sin sesión, y `web/privacidad.html`. Android
ya no respalda nada ni pasa datos a otro teléfono, y el nombre bajo el ícono es «BayStream». El
inventario del APK no encontró Installations, analítica ni anuncios, pero sí tres bibliotecas que
llegaron con `firebase-auth` (sección 5). Las cuatro sondas de T-93 siguen en 0 / 1 / 1 / 1.

**Me detuve en tres frases** que eran falsas en Windows o en la Web, como pide la ficha. Yov las
corrigió en 10.46 y Carlos me pasó el texto; las tres que corrigió son las mismas que reporté. **El
ícono (D5) no entra:** va en la segunda entrega (10.45).

## 1. La fuente y las dos entradas

| Pieza | Dónde |
|---|---|
| **Fuente única del texto** | `lib/core/constants/privacy_policy.dart`: título, fecha, 13 secciones (título, párrafos y puntos) y `kPrivacyContactEmail`. Dart puro, sin Flutter. Va en `core/constants` porque es un texto constante que comparten la app, la herramienta y la prueba, y no es dominio del buque |
| **Marcas dentro del texto** | solo `**negrita**` y `` `ruta` ``, las mismas de la ficha. `privacyRuns()` las separa en tramos |
| **Función del HTML** | `lib/core/utils/privacy_policy_html.dart`, `privacyPolicyHtml()` |
| **Herramienta** | `tool/t88_privacidad.dart`: `dart run tool/t88_privacidad.dart` escribe `web/privacidad.html`, y con `--comprobar` solo compara (código 1 si no coincide) |
| **Pantalla** | `lib/features/vessel/presentation/pages/privacy_policy_page.dart`, «Política de privacidad», con el texto seleccionable |
| **Entrada 1** | portada → icono **Parámetros** (barra superior) → **«Política de privacidad»**, debajo del tema (`parameters_page.dart`, `ValueKey('privacy-policy')`). No pide viaje |
| **Entrada 2** | portada → icono **Nube y cuenta** → formulario de inicio de sesión → **«Política de privacidad»**, junto a «Olvidé mi contraseña» (`cloud_page.dart`, `ValueKey('sign-in-privacy-policy')`). No pide sesión |

- **`lib/main.dart` no se tocó:** las dos pantallas ya se abrían desde la portada sin viaje.
- **Palabra por palabra.** Un script comparó la fuente con el bloque de la ficha en `SPRINT-3.md` (10.46): 25 líneas y una sola diferencia, la autorizada, en la ruta de Windows (ver abajo).
- **Correo (D2):** `giovannimartinezcrl2002@gmail.com`, como constante. Una prueba exige que sea la única dirección de correo del texto.
- **Las dos rutas de Windows (10.46), verificadas sin abrir su contenido.** Las listé con un `.bat` lanzado por `explorer.exe` (cadena `powershell ← cmd ← explorer ← svchost`), es decir, fuera del paquete:
  - `%LOCALAPPDATA%\BayStream` existe. **Queda como estaba.**
  - La caché de Firestore está en `%LOCALAPPDATA%\firestore\[DEFAULT]\baystream-app`. Al lado está `demo-t79`, del emulador. No hay ninguna carpeta llamada «BayStream» dentro de `firestore`.
  - **Ajuste:** `` `AppData\Local\firestore` `` pasa a `` `AppData\Local\firestore\[DEFAULT]` ``, y la frase dice «la de BayStream dentro de» esa carpeta. La de BayStream es `baystream-app`.
  - Sugerencia para Yov, sin tocarla: si se quiere sin ambigüedad, la frase podría nombrar `baystream-app` directamente.
- **Una mejora de forma, no de texto.** A letra 2.0, el título de la barra se cortaba («Política de privaci…»). Ahora se reduce con `FittedBox`, como el título de la portada desde T-97.

## 2. Los tres clientes y `/privacidad.html`

Banco `tool/t88_main.dart`: es la app real (`BayStreamApp` con la portada real), con su sesión de
Firebase, sobre el namespace **`t88acc`**. Lo compilé solo en una copia de `%TEMP%`
(`baystream-t88-clientes`, sin `docs`, `build`, `.dart_tool`, `android/key.properties` ni los enlaces
de `ephemeral`), con `--dart-define-from-file=…\firebase-prod.json` y sin abrir ese archivo. No abrí
ningún viaje ni registré movimientos.

| Cliente | Desde Parámetros | Desde el inicio de sesión | Claro / oscuro | Letra 2.0 |
|---|---|---|---|---|
| **Honor `.t88`**, NAA-LX3, 720×1600 a 320 dpi = **360×800 dp** | Sí | Sí, sin sesión (instalación nueva) | Sí: oscuro por el sistema y claro y oscuro por el ajuste de la app | Sí |
| **Windows**, `explorer.exe` → PID 12188, después 22376 | Sí | Sí, después de cerrar sesión (ver abajo) | Oscuro (el del sistema) | No aplica |
| **Web en Chrome** (Claude in Chrome), `http://localhost:8188` | Sí | Sí, sin sesión | Oscuro (el del sistema) | No aplica |

- **Honor.**
  - Comparé los volcados de `uiautomator` de toda la pantalla, desplazándola, con la fuente: **38 de 38 piezas**, a letra 1.0 y a letra 2.0.
  - Los volcados se tomaron en memoria y con los correos ocultos. Por eso el contacto aparece como `<correo>` en el volcado; en las capturas sale el de D2. No apareció ningún diálogo del sistema.
  - La letra estaba en 1.0. **Con permiso de Carlos**, la puse en 2.0 por adb y **la devolví a 1.0** (`font_scale` = 1.0).
  - En el Honor real, el selector de tema de Parámetros no se desborda a 360 dp, ni a 1.0 ni a 2.0 (ver la observación 3 de la sección 8).
  - Se instaló solo `gt.cmartinez.baystream.t88` y quedó cerrado con `force-stop`.
- **Windows.** Ver la sección 3: almacén real, sesión y cierre de sesión.
- **Web.** Compilé `build/web` en la copia y lo serví con `tool/t92_server.dart … 8188 --block-external`. Carlos dejó Chrome a la vista: con la ventana oculta, las capturas expiran (AGENTS.md).
- **`/privacidad.html` directo en Chrome:**
  - estado 200, `lang="es"`, 0 `<script>`, 0 `<link>`, 13 `<h2>` y 10 `<li>`;
  - el texto de `get_page_text` es el de la app;
  - el único recurso extra que pidió la página es `/favicon.ico`, del mismo origen, que el navegador pide por su cuenta;
  - **después de abrir la app, con el service worker de T-92 ya en control** (`sw: true`), `/privacidad.html` sigue entregando la política y no la app.
  - El servidor (PID 27772) y la pestaña se cerraron al terminar.
- **El HTML en claro y en oscuro.** Lo revisé en el navegador integrado, emulando 375 px y el esquema de color:
  - claro: fondo `rgb(255,255,255)`;
  - oscuro: fondo `rgb(18,19,24)`;
  - sin desplazamiento horizontal (`scrollWidth` 375).
- **Firebase Hosting:** `firebase.json` reescribe `**` a `/index.html`, pero Hosting entrega primero los archivos que existen. No publiqué nada, así que eso se comprueba cuando Carlos publique.

## 3. Windows: el almacén real y cerrar sesión

- **Huella del almacén real**, tomada fuera del paquete con un `.bat` lanzado por `explorer.exe` (`powershell ← cmd ← explorer ← svchost`):
  - **340 archivos antes y 354 después**;
  - los 340 previos conservan su SHA-256;
  - **lo único nuevo son los 14 archivos `t88acc_*`**, con `t88acc_movements.hive` en **0 bytes**.
- **La app abrió con sesión.** En el Administrador de credenciales ya estaba `baystream-app.firebase.auth/[DEFAULT][0]` y `[1]` (solo leí los nombres de destino con `cmdkey /list`, filtrados). Así, «Nube y cuenta» mostró la cuenta de oficina de Carlos y la lista de operaciones abiertas, solo leída.
- **Cerrar sesión sí quita la sesión guardada en Windows.** Con permiso de Carlos pulsé «Cerrar sesión»:
  - las dos entradas `baystream-app.firebase.auth/[DEFAULT][0]` y `[1]` **desaparecieron** del Administrador de credenciales;
  - al cerrar la app por PID y volver a abrirla, arrancó sin sesión.
  - Quedan entradas de otros proyectos: `T70c-prod` de la espiga T-70c, y `demo-t79`, `demo-baystream-t70` y `demo-baystream-t70b` del emulador. No son de esta app ni se tocaron.
  - **Carlos tiene que volver a iniciar sesión en Windows** cuando la necesite.
- **Lo que no quita cerrar sesión** (observación, la frase de la política no lo niega): `t88acc_session.hive` quedó en 123 bytes. El código explica por qué: `FirebaseSessionRepository.signOut()` no borra la copia local del operador (`HiveLastOperatorStore`: uid, nombre y rol). No abrí el archivo.
- **La caché de Firestore** (`firestore\[DEFAULT]\baystream-app`) pudo cambiar al listar las operaciones con la sesión abierta. Está fuera de `%LOCALAPPDATA%\BayStream` y no tomé su huella.

## 4. D3: sin respaldo y sin transferencia, y D9

**Fuente oficial:**
- [Android: Auto Backup](https://developer.android.com/identity/data/autobackup), actualizada el 26-feb-2026;
- [Android 12: cambios de copia y restablecimiento](https://developer.android.com/about/versions/12/backup-restore), actualizada el 1-oct-2026.
- Las dos dicen que, con `targetSdk` 31 o mayor, en algunos fabricantes `allowBackup="false"` apaga la copia en Google Drive pero **no la transferencia entre dispositivos**. Esa transferencia se controla con `<device-transfer>` dentro de `android:dataExtractionRules`. El formato antiguo sigue rigiendo en Android 11 o menor, y ahí `allowBackup="false"` apaga todo.

**Lo construido.** Es un atributo en el manifiesto y un XML nuevo, sin nada más: D3 no exigió más que
eso.
- `android/app/src/main/AndroidManifest.xml`: `android:allowBackup="false"` y `android:dataExtractionRules="@xml/data_extraction_rules"`.
- `android/app/src/main/res/xml/data_extraction_rules.xml`: excluye los nueve dominios de la documentación (`root`, `file`, `database`, `sharedpref`, `external` y los cuatro `device_*`, con `path="."`) en `<cloud-backup>` y en `<device-transfer>`, sin ningún `<include>`. Cita las dos fuentes.

**El manifiesto fusionado del APK release** (`merged_manifests/release/processReleaseManifest/AndroidManifest.xml`, y `aapt2 dump xmltree` del APK):
```
android:allowBackup="false"
android:dataExtractionRules="@xml/data_extraction_rules"     (0x7f0f0000 en el APK)
android:label="BayStream"
```
No hay `fullBackupContent`.

**En el Honor:**
- `dumpsys package gt.cmartinez.baystream.t88` da `flags=[ HAS_CODE ALLOW_CLEAR_USER_DATA ]`, **sin `ALLOW_BACKUP`**. La variante anterior `.t104` da `flags=[ HAS_CODE ALLOW_CLEAR_USER_DATA ALLOW_BACKUP ]`.
- **`bmgr` no sirve como prueba en este teléfono.** `bmgr enabled` dice «Backup Manager currently disabled», y `bmgr backupnow` responde «Backup is not allowed» **también para `.t104`**, que sí admite respaldo. Basta el manifiesto, como permite la ficha.

**D9.**
- El Honor muestra **«BayStream»** bajo el ícono de `.t88`, y ese ícono abre `gt.cmartinez.baystream.t88/.MainActivity`. Las otras variantes instaladas antes siguen con «baystream».
- `aapt2 dump badging` da `application-label:'BayStream'`.
- **Se reporta y no se cambia:** en Windows, la barra de título de la ventana dice «baystream» (`windows/runner/main.cpp:30`), y también `FileDescription` y `ProductName` en `windows/runner/Runner.rc`. En la Web (`index.html`, `manifest.json`) y en el MSIX (`display_name`) ya dice «BayStream».

## 5. El inventario para las declaraciones de Play

APK release compilado hoy en la copia, con `lib/main.dart` (el producto), `gt.cmartinez.baystream`,
`versionCode 1`, `versionName 1.0.0`, `targetSdk 36`, SHA-256
`5350B69DABE441FB45813950BCF4B3186A12D147CBEF42C81FF1AD28591E8BF8`. Lo firmó la clave de depuración,
porque la copia no lleva `key.properties`; la firma no cambia el manifiesto ni las dependencias.
Herramientas: `aapt2` (build-tools 36.1.0), el manifiesto fusionado de Gradle con su informe de
procedencia y `gradlew :app:dependencies --configuration releaseRuntimeClasspath` (532 líneas,
`BUILD SUCCESSFUL`).

### 5.1 Permisos del manifiesto fusionado

| Permiso | Origen (informe de fusión) | ¿Se esperaba? |
|---|---|---|
| `android.permission.RECORD_AUDIO` | manifiesto propio (T-94) | sí |
| `android.permission.INTERNET` | bibliotecas, al fusionar | sí |
| `android.permission.ACCESS_NETWORK_STATE` | bibliotecas, al fusionar | sí |
| `com.google.android.providers.gsf.permission.READ_GSERVICES` | **`com.google.android.recaptcha:recaptcha:18.6.1`** | **no estaba en la lista** |
| `gt.cmartinez.baystream.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` | `androidx.core:core:1.15.0`, permiso propio | ya estaba en T-64 |

- **Consultas (`<queries>`):** `android.speech.RecognitionService` (se esperaba), `PROCESS_TEXT` y `GET_CONTENT`. No hay `QUERY_ALL_PACKAGES` ni `AD_ID`.
- **Componentes de Firebase en el manifiesto:**
  - `ComponentDiscoveryService`, con los registradores de Core, Firestore y **Auth**;
  - `FirebaseInitProvider`;
  - de `firebase-auth`: `GenericIdpActivity`, `RecaptchaActivity`, `CredentialProviderMetadataHolder`, `HiddenActivity`, `SignInHubActivity` y `RevocationBoundService`.

### 5.2 Firebase y Play services en el árbol release

| Artefacto | Versión | Llega por |
|---|---|---|
| `firebase-bom` | 34.17.0 | `firebase_core` |
| `firebase-common` / `firebase-components` / `firebase-annotations` | 22.2.0 / 19.0.0 / 17.0.0 | `firebase_core` |
| `firebase-firestore` | 26.5.0 (gRPC 1.62.2 sobre OkHttp) | `cloud_firestore` |
| **`firebase-auth`** | **24.2.0** | `firebase_auth` (T-79) |
| `firebase-auth-interop` / `firebase-appcheck-interop` | 20.0.0 / 17.0.0 | solo interfaces |
| `play-services-base` / `basement` / `tasks` | 18.9.0 / 18.9.0 / 18.4.0 | Firebase |
| **`com.google.android.recaptcha:recaptcha`** | **18.6.1** | `firebase-auth` |
| **`com.google.android.play:integrity`** (+ `core-common` 2.0.3) | **1.3.0** | `firebase-auth` y `recaptcha` |
| **`play-services-auth`**, `auth-base`, `auth-api-phone`, `fido` | 20.7.0, 18.0.4, 18.0.2, 20.1.0 | `firebase-auth` |
| **`androidx.credentials`** (+ `credentials-play-services-auth`), **`googleid`** | 1.2.0-rc01, 1.1.0 | `firebase-auth` |

**Lo que se busca en el árbol, contado término por término:**

| Término | Apariciones |
|---|---:|
| `firebase-installations` | **0** |
| `firebase-analytics`, `play-services-measurement`, `play-services-analytics` | **0** |
| `firebase-crashlytics` | **0** |
| `firebase-messaging`, `firebase-config`, `firebase-perf` | **0** |
| `datatransport`, `transport-runtime`, `transport-api` | **0** |
| `play-services-ads`, `user-messaging-platform` | **0** |
| `firebase-appcheck` | 2, ambas `firebase-appcheck-interop`: interfaces sin código que transmita |
| `okhttp3`, `retrofit`, `volley`, `cronet`, `androidx.work` | **0** |

**Cadenas en el código del APK** (`classes.dex` y `lib/arm64-v8a/*.so`):

| Cadena | dex | nativo |
|---|---:|---:|
| `firestore.googleapis.com` | 1 | 0 |
| `identitytoolkit` | 2 | 0 |
| `securetoken` | 1 | 0 |
| `recaptcha.net` | 3 | 0 |
| `firebaseinstallations`, `app-measurement`, `crashlytics`, `firebaselogging`, `google-analytics`, `googleads`, `doubleclick`, `admob`, `fcm.googleapis.com`, `recaptchaenterprise`, `playintegrity` | 0 | 0 |

**Conclusión:**
- **No hay Installations, analítica, anuncios, informes de fallos ni mensajería.** La política no tiene que cambiar por eso, y no me detuve.
- **Pero T-65 cerró V1 en un árbol sin `firebase-auth`, y eso cambió con T-79.** Ahora hay tres familias que pueden transmitir por su cuenta cuando se usan:
  - **reCAPTCHA** (`recaptcha 18.6.1`), que además pide `READ_GSERVICES`;
  - **Play Integrity** (`integrity 1.3.0`);
  - **las de inicio de sesión de Google** (`play-services-auth`, `credentials`, `googleid`). La app no las usa: solo inicia sesión con correo y contraseña.
- La página oficial [Firebase: divulgación de datos de Google Play](https://firebase.google.com/docs/android/play-data-disclosure) (actualizada el 13-oct-2026) dice:
  - **Authentication recopila automáticamente la dirección IP**, «para dar seguridad adicional y prevenir abuso durante el registro y la autenticación»;
  - también recopila cadenas de *user agent* (versión del SDK y plataforma), el Firebase Android App ID y el Firebase user agent;
  - el token de **Play Integrity** solo si la app usa autenticación por teléfono. BayStream no la usa;
  - el token de **reCAPTCHA Enterprise** solo si el proyecto protege Authentication con reCAPTCHA Enterprise. **Eso se decide en la consola de Firebase, y no lo pude verificar desde el código.** Lo confirma Carlos.
  - **Cloud Firestore** recopila solo el Firebase user agent, que «nunca se vincula a un identificador de usuario o dispositivo».

## 6. Las sondas de T-93

`tool/t93_msix.ps1` suma un `elseif` para `UnknownError`, con el mensaje de la ficha, palabra por
palabra y en ASCII:
`La firma no es de confianza en este equipo o no se pudo validar. Si no ha importado BayStream.cer en Personas de confianza del equipo local, importelo primero.`
El `StatusMessage` sigue saliendo en `$detalle`. El script tiene 6 081 bytes y ninguno por encima de 127.

Las cuatro sondas corrieron con Windows PowerShell 5.1 y su módulo nativo
(`…\v1.0\Modules\Microsoft.PowerShell.Security\Microsoft.PowerShell.Security.psd1`), en un proceso
hijo con `-NoProfile -ExecutionPolicy Bypass -File`. Usé las copias de
`%TEMP%\baystream-t93-timonel\` del 1.0.2.0, con la huella de Carlos.

| Sonda | Código | Mensaje |
|---|---:|---|
| Original | **0** | `Firma: Valid \| CN=BayStream \| 60BEF8F4…278EC` |
| Un bit cambiado | **1** | `El paquete esta alterado o danado; no se distribuye. Status: HashMismatch.` |
| SHA que no coincide | **1** | `El SHA-256 del paquete no coincide con su .sha256. Status: Valid.` |
| Otra huella (`ABCDEF01…`) | **1** | `La huella del firmante no coincide con -Huella. Status: Valid.` |

**El camino de `UnknownError` no se ejecutó:** provocarlo exige una raíz que no esté en ningún almacén,
y no toqué almacenes de certificados. Lo fija una prueba sobre el texto del script. Ninguna copia se
instaló. Registro: `%TEMP%\t88-sondas-t93.log`.

## 7. Pruebas, analyze, corpus y SHA

| Validación | Resultado |
|---|---|
| `flutter test` | **709/709** (piso 697 + **12** nuevas), dos veces; la segunda, después del último cambio de `lib/` |
| `flutter test test/t88_privacy_policy_test.dart` | 12/12 |
| `flutter analyze` | **No issues found**, sin `// ignore:` |
| Corpus, `tool/*corpus*test.dart` con `BAYSTREAM_CORPUS_DIRECTORY` | **118/118 en 32 archivos**, 26 s. Corrió antes del cambio del título de la barra, que es de interfaz y no lo toca el corpus |
| `dart run tool/t88_privacidad.dart --comprobar` | coincide |

**Las 12 pruebas nuevas** (`test/t88_privacy_policy_test.dart`):
- `web/privacidad.html` es byte a byte lo que genera la fuente, salvo los finales de línea;
- el texto nombra el micrófono, la sincronización, la falta de respaldo y el contacto, y D2 es su único correo;
- el HTML es autocontenido: sin `<script>`, `<link>`, `<img>`, `@import`, `url(`, URL externas ni manejadores `on…`;
- las marcas se leen sin asteriscos ni comillas invertidas;
- la pantalla muestra todas las piezas a 360 dp, en claro y en oscuro, a letra 1.0 y 2.0 (4 pruebas);
- se llega desde Parámetros sin viaje, y desde el inicio de sesión sin sesión;
- D3 y D9 en el manifiesto, con los nueve dominios excluidos en las dos secciones;
- el mensaje de `UnknownError` del script de T-93, en ASCII.

**Sin cambio frente a HEAD** (`git diff --stat --ignore-cr-at-eol` vacío):

| Archivo | SHA-256 |
|---|---|
| `lib/main.dart` | `C5189B1D8711837A05C68306D424C9FDBCC977BA3BBB6C823089FFE4CA5339D5` |
| `lib/latency_test_screen.dart` | `599310DB13A713E82FC0D6A411BE2D7757CBC2B803D772C1CAA16C471725CDFF` |
| `lib/c3_reconciliation_screen.dart` | `3AF478364A8C5386E1F921E0142DC4F847594BECA00B6743563CB09A8A4112A5` |
| `firestore.rules` | `0112510984D9A16364F9752E243999C47306E0BCF82766E380DB380E8FE8E60A` |
| `docs/T80-firestore.rules.propuesta` (las publicadas) | `21894B7F43E59F856045473731B795D21F8373C5AC8A1D9FFF324334AC3C9000` |
| `firebase.json` | `9BCFD4D9B5A717BD4F044C0E67440C7A81D9858EDB1363CBD2CBA695D30852E9` |
| `pubspec.yaml` | `CDE9A4B132CB83898A9D1909898B89BD9380990CA8225FDFC776C342947DA716` |
| `pubspec.lock` | `577D742E04143131BC02A1BBB6C246D298C90396E08F6C9DFE393637A2617F53` |

- Los congelados tampoco difieren de `m2-baseline`.
- `windows/` no cambia.
- **`pubspec.yaml` y `pubspec.lock` no cambian:** no hay dependencias nuevas.

**Los archivos de esta entrega:**

| Archivo | Estado | SHA-256 |
|---|---|---|
| `lib/core/constants/privacy_policy.dart` | nuevo | `70EB5B97B5BDEF2127159235760BFCA16B5074EA3409FEED65F9AB0BDFD51FF2` |
| `lib/core/utils/privacy_policy_html.dart` | nuevo | `DCC2343DE7E11644FEB89F83B671EE5852B745C95E92DC9CB38EE88B01D11BF3` |
| `lib/features/vessel/presentation/pages/privacy_policy_page.dart` | nuevo | `4DB8020605C0F41D743D1EDA8BC944A1A14DF7A34F8F524DB3681CF3771264AB` |
| `lib/features/vessel/presentation/pages/parameters_page.dart` | +10 | `04E525D02F2A735E7E7A60000E741722C27E59E665D8ADD137B8DA620CFF6D06` |
| `lib/features/vessel/presentation/pages/cloud_page.dart` | +6 | `AF9F4854F35DBF56BF2D0BDBC11000E3C782838CCFC8F12167F83C7ABB59F476` |
| `test/t88_privacy_policy_test.dart` | nuevo | `A228666595EF6A35BF866CF16F35CFE26AE2EFC96D47EFBEE6046FB2D7A21481` |
| `tool/t88_privacidad.dart` | nuevo | `899541D41854AA12634A4FEADC03A91F6FB288B41462B036E41C902D1971C1A1` |
| `tool/t88_main.dart` | nuevo, banco | `EB015843193EE81CF25AC0717E9F2156CB7C748DF7EC56AB964FA4FA6DB683C0` |
| `tool/t93_msix.ps1` | +4 | `FBB9B6A4E86DE55A170CBA26F7ADE593923F8430E111CB787AA625CB0DB0040A` |
| `web/privacidad.html` | nuevo, generado | `8E27A91424F7BE6A5D34E4034E8669CB765B98C7F8A8CBA2B63E056D348CA583` |
| `android/app/src/main/AndroidManifest.xml` | +6 −2 | `1B1A559050F9FD35CFBE19359FBF805D45F5FDB6A8FEAB5FA2942F9C8B981243` |
| `android/app/src/main/res/xml/data_extraction_rules.xml` | nuevo | `30E2F9B55CE18D15C66623D5EF325397B57F5FDB27D19A25F7B88B45E36299DD` |

Calculados sobre el árbol de trabajo, con los finales de línea que tiene hoy.

## 8. Observaciones para Yov (no son frases falsas)

1. **Cada movimiento lleva también el UID de la cuenta** (`author.uid`), y la operación lo lleva en `createdBy` y `closedBy` (`firestore_operation_sync.dart`, `FirestoreMovementCodec.encode`). La frase «Cada movimiento lleva tu nombre, tu rol, la hora y un identificador aleatorio de la instalación» no lo menciona. Para el formulario de Seguridad de los datos, eso es un «ID de usuario».
2. **«Quién lo ve … según su rol».** En las reglas publicadas (`T80-firestore.rules.propuesta`), las dos cuentas, muelle y oficina, **leen lo mismo** (`allow get, list: if isAuthorized()`). El rol limita lo que cada una escribe, no lo que ve.
3. **El selector de tema de T-90 se desborda 2.5 px a 360 dp en `flutter test`**, con o sin la entrada nueva (`parameters_page.dart:22`). En el Honor real no se desborda, ni a 1.0 ni a 2.0: es la letra de pruebas. No se corrigió de paso. La prueba de la entrada desde Parámetros usa la superficie por defecto, y la razón está escrita en la prueba.
4. **«Cerrar sesión quita tu sesión del dispositivo» es cierta en Windows** (sección 3). La copia local del operador (uid, nombre y rol) se queda hasta desinstalar o borrar los datos. La frase del almacén ya dice que «los datos de tu cuenta» se guardan en el dispositivo.
5. **Authentication recopila la dirección IP** según Google (sección 5). La política la menciona para el alojamiento de la Web, pero no para iniciar sesión en ninguno de los tres clientes.
6. **reCAPTCHA, Play Integrity y las bibliotecas de inicio de sesión de Google** llegan con `firebase-auth 24.2.0`, y reCAPTCHA pide `READ_GSERVICES` (sección 5). Si el proyecto tiene reCAPTCHA Enterprise activo para Authentication, la declaración de Play lo tiene que reflejar.

## 9. Horas

De ≈ 13:22 (el primer comando, poco después de `3f29fc1`, 13:20) a ≈ 14:20 del 15-oct: **≈ 1.0 h de
pared, frente a 2.5**. Incluye la pausa hasta recibir el texto de 10.46. Compilaciones de la copia:
- APK de inventario, 93 s;
- APK `.t88`, 73 s, y una segunda de 68 s, después del ajuste del título;
- Web, 49 s;
- Windows, 173 s. El primer intento falló en 5 s por los enlaces de `ephemeral`, como en T-103, y se borraron solo en la copia.

**El ícono (D5)** va en la segunda entrega de T-88, con su paquete (10.45). Esta entrega no lleva horas
del diseño.

## 10. Evidencia y estado en que quedan las cosas

- **Evidencia** en `%TEMP%\baystream-t88-evidencia\` (35 archivos):
  - capturas `honor-*.png`;
  - los volcados comparados (`honor-textos*.txt`);
  - las huellas antes y después, con su `.bat` y su `.ps1`;
  - `merged-manifest-release.xml`, `gradle-release-runtime.txt` y el APK del inventario;
  - los registros de la suite, del corpus y de las sondas;
  - los dos scripts de cotejo.
- **La copia de compilación** queda en `%TEMP%\baystream-t88-clientes` para Codex.
- **El Honor:**
  - instalado `gt.cmartinez.baystream.t88`, cerrado;
  - letra en 1.0;
  - tema de `.t88` en oscuro, por el ajuste de la app.
- **Windows:**
  - ningún `baystream.exe` abierto;
  - **sesión cerrada:** Carlos la vuelve a iniciar cuando la necesite;
  - 14 archivos `t88acc_*` en el almacén real.
- **La Web:** el servidor y las pestañas están cerrados.
- **Git:** solo `log`, `show`, `diff --stat --ignore-cr-at-eol`, `ls-files` y `check-ignore`. No usé la CLI de Firebase, no toqué el proyecto de H5 y no publiqué nada.

## Corrección (10.47)

Timonel · 15-oct-2026 · sobre `7e55e12` (decisión 10.47), antes de la aceptación de Codex. ≈ 14:20–14:50.

**Qué cambió:**
- **Cinco cambios al texto**, copiados palabra por palabra de la ficha de T-88: «Tu cuenta», «Lo que se envía a la nube», «Quién lo ve», la ruta de Windows y «Cerrar sesión…».
- **El nombre en Windows:** «BayStream» en el título de la ventana y en el ejecutable.
- **Nada más de `windows/`.** 10.47 menciona también «el nombre del ejecutable»; lo resolví como `FileDescription` y `ProductName`, que es lo que pidió Carlos. `InternalName`, `OriginalFilename` (`baystream.exe`) y `CompanyName` no cambian.

### Las cinco frases, contra el código

Ninguna es falsa. Esta es la evidencia de cada una:

| Frase nueva | Evidencia |
|---|---|
| **Tu cuenta:** Authentication recibe la IP y datos técnicos para proteger contra el abuso | Página de Firebase de divulgación para Play, sección 5 de este informe |
| **Lo que se envía:** el identificador de la cuenta en cada movimiento, y quién publicó y quién cerró la operación | `FirestoreMovementCodec.encode` envía `author.uid`; `publish()` y `close()` escriben `createdBy` y `closedBy` (`firestore_operation_sync.dart`) |
| **Quién lo ve:** todas las cuentas autorizadas ven las operaciones; el rol decide qué registran o aprueban | `T80-firestore.rules.propuesta`: `get, list: if isAuthorized()` en operaciones, fuentes y movimientos; `dockTypes()` y `officeTypes()` limitan lo que cada rol escribe |
| **La ruta** `AppData\Local\firestore\[DEFAULT]\baystream-app` | Verificada fuera del paquete, sin abrir su contenido (sección 1) |
| **Cerrar sesión…** «Tu nombre y tu rol se quedan guardados con lo demás, y se borran de la misma forma» | `signOut()` no borra `HiveLastOperatorStore`. Esa copia vive en `vessel_store` (`<ns>_session`), con el resto del almacén, y se borra igual. Además del nombre y el rol, guarda el uid |

### Fuente y HTML

- **El cotejo con la ficha da 25 líneas y 0 diferencias.** La ruta de Windows ya viene en la ficha.
- `dart run tool/t88_privacidad.dart` regeneró `web/privacidad.html` (7 961 caracteres), y `--comprobar` termina con código **0**.

### Pruebas

- **Una prueba nueva:** «T-88 D9 en Windows: la ventana y el ejecutable dicen BayStream (10.47)».
- **Una reescrita, sin cambiar lo que exige.** Las cuatro de la pantalla a 360 dp ya no desplazan la lista con `scrollUntilVisible`. Con el texto más largo, ese desplazamiento fallaba en `dragUntilVisible` al buscar el desplazable. Ahora la superficie mide 360 dp de ancho y 60 000 de alto: la lista se arma completa y se comprueban las 38 piezas a 1.0 y 2.0, en claro y oscuro. Un desborde a ese ancho sigue saliendo como excepción.
- **Suite: 710/710** (709 + 1). T-88: 13/13. `analyze` en cero.
- **El corpus no se repitió.** De `lib/` solo cambió una constante de texto que no lee ningún corpus.

### Los clientes

Volví a compilar las tres variantes en la copia de `%TEMP%`, con los cinco archivos actualizados.

- **Honor `.t88`** (APK `4E590CA5…2B1B41`), a 360 dp y letra **2.0**:
  - en oscuro y en claro, los volcados dan **38 de 38 piezas**, con las frases nuevas;
  - la letra volvió a **1.0**;
  - el tema de `.t88` quedó en claro, y la app cerrada.
- **Chrome**, `/privacidad.html` servido desde `build/web`:
  - 13 secciones, 10 viñetas, sin scripts ni `<link>`;
  - las seis cadenas nuevas presentes;
  - el HTML servido es idéntico al del repo (`cmp`).
  - **Una observación de T-92.** El service worker quedó registrado en ese origen por la prueba anterior, y la primera carga entregó **la versión vieja** desde su caché. Después de `registration.update()`, la siguiente carga entregó la nueva. Esa actualización la forcé yo, así que no sé si se habría hecho sola en la siguiente visita.
  - Para Hosting: quien ya abrió el sitio puede ver la política anterior en la primera carga después de una publicación.
- **Windows con `t88acc`:**
  - la ventana dice **«BayStream»** (`MainWindowTitle` y la barra);
  - el `.exe` da `FileDescription` y `ProductName` = `BayStream`;
  - la política, abierta desde el inicio de sesión, muestra las cinco frases;
  - la app abrió sin sesión: no hay credencial `baystream-app.firebase.auth/[DEFAULT]`. Se cerró por PID.

### Almacén real y protegidos

- **El almacén real** (huella fuera del paquete, `powershell ← cmd ← explorer ← svchost`) tiene **354 archivos antes y 354 después**, todos con el mismo SHA.
- Los 340 de la huella original siguen iguales; los 14 restantes son `t88acc_*`.
- **Sin cambio frente a HEAD:** `lib/main.dart`, los congelados, `firestore.rules`, las reglas publicadas, `firebase.json`, `pubspec.yaml` y `pubspec.lock`.

### Archivos de la corrección

| Archivo | SHA-256 |
|---|---|
| `lib/core/constants/privacy_policy.dart` | `56FA53A3E4DE891D1F92036C6C915E37CFFBAC0CFEAF86E226C3851966BA9A06` |
| `web/privacidad.html` | `7B86F47CDD02019F0722A7C5C9A08DEF069684865EE05029D2E63A0311F3AADD` |
| `test/t88_privacy_policy_test.dart` | `E5573B07E48E3AD984F2E661862DF1F5B6B0AACF00F5336100298101F825D2D5` |
| `windows/runner/main.cpp` | `B9DA8EEA375B23C371D6F22C71C55CEFC2653937B3B98DDEAEC467B0F8F5BA1B` |
| `windows/runner/Runner.rc` | `9DAE39EF489533BDC20C5BD7F9067CDE7E24DB87F0DA9C8C0543A737634F8103` |

Calculados sobre el árbol de trabajo. En `main.cpp` y `Runner.rc`, el editor dejó finales LF donde había CRLF. En el índice son LF y `diff --ignore-cr-at-eol` muestra solo las tres líneas.

**Horas:** ≈ 0.5 h. T-88 suma ≈ 1.5 h frente a 2.5, sin el ícono.

## Ícono (10.48)

Timonel · 15-oct-2026 · sobre `956d802` (10.49; 10.48 en `ed84383`) · segunda entrega de T-88.

### El paquete

- **Dónde estaba.** No estaba en `C:\Proyectos\baystream-icono\`, que no existe. Lo encontré en `C:\Users\Giova\Downloads\BayStream_icono_v1.zip`: 260 712 bytes, SHA-256 `2677C8C2455E26233FE845A28F5C2178CA546536E3679FE424BB2F99B7F42343`.
  - Solo aparecía al buscar fuera del paquete de la consola, con un `.bat` lanzado por `explorer.exe`.
  - No lo modifiqué: lo descomprimí en `%TEMP%\baystream-t88-icono\`.
- **La integridad.** Trae 37 archivos. **Los 36 que tienen SHA-256 en su `LEEME.md` coinciden todos**, y el `LEEME.md` no lleva SHA propio, como él mismo dice.
- **Lo copié con sus rutas:**
  - `android/`, `web/` y `windows/`, tal cual;
  - `design/icono/` completo;
  - `play/` dentro de `design/icono/play/`.
  - Después de copiar, los 36 SHA se repiten en el repo.
- **Un aviso sobre el paquete.** El `LEEME.md` y `generar.py` siguen escribiendo `play/` en la raíz. Si se regenera, `generar.py` deja `play/` fuera de `design/icono/`. No los modifiqué.
- **`web/manifest.json`:** `background_color` y `theme_color` pasan de `#0175C2` a `#0D47A1`. No cambia nada más.
- **Íconos de Flutter sin usar: ninguno.** Los once que había los reemplaza el paquete:
  - los cinco `mipmap-*/ic_launcher.png`;
  - `web/favicon.png` y los cuatro de `web/icons/`;
  - `windows/runner/resources/app_icon.ico`.
- **Lo que no cambia:** el resto de `android/` y `windows/`, incluidos `AndroidManifest.xml`, `main.cpp`, `Runner.rc` y `CMakeLists.txt`; `lib/`, `test/`, `tool/` y `pubspec.*`; y las reglas.

### Los archivos y sus SHA

| Archivo | Estado | SHA-256 |
|---|---|---|
| `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml` | nuevo | `CEE3FF6C73E61072D4F99F71D5311DF6DE2540630951B0F9FBD4FC4BB010F62F` |
| `android/app/src/main/res/mipmap-hdpi/ic_launcher.png` | cambia | `7A997685A154D988F81C91F5D32AEAEE34ADFDD91908CE5E9768860315809489` |
| `android/app/src/main/res/mipmap-hdpi/ic_launcher_foreground.png` | nuevo | `209D2940B42B8E0DB5975F3BF4A6A86FC4F3D7A9D047789A1784E46D263E5C5F` |
| `android/app/src/main/res/mipmap-hdpi/ic_launcher_monochrome.png` | nuevo | `60C71C696B0E202A5F9EA54756FAA37B040AFF743BA70D4D528CC8D4708B222D` |
| `android/app/src/main/res/mipmap-mdpi/ic_launcher.png` | cambia | `A1403C046BCF62A7A142361C84CEE3AFDFAEEEDB6FD36EC0C3E45EC9C3971146` |
| `android/app/src/main/res/mipmap-mdpi/ic_launcher_foreground.png` | nuevo | `CDFE666FAF024CE164DE78A12FF240F958F0FB7144B804FBABB6F2D38120EEAF` |
| `android/app/src/main/res/mipmap-mdpi/ic_launcher_monochrome.png` | nuevo | `4FB0FC05798B8964EA496F7633F0D0E463813DF6FD4FF37EB7768103A3808D2E` |
| `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png` | cambia | `52E5F235E77A6CBF20F993889EAFA82699CED9BF1FC8CCC70052F98F7B01C1F8` |
| `android/app/src/main/res/mipmap-xhdpi/ic_launcher_foreground.png` | nuevo | `5876918D4EC5CDEF3D738F947841340D9DEC65EC328F5AD095F2812F28013F3D` |
| `android/app/src/main/res/mipmap-xhdpi/ic_launcher_monochrome.png` | nuevo | `B21C4950BB554B8938DDD865D9DB96BFD6A8047A58F760B82C0E2D2CE59B95E1` |
| `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png` | cambia | `6C51E6FD465BEE117AECBC4097CFA67A3F42E69C38DC5AF352289167D77ADB67` |
| `android/app/src/main/res/mipmap-xxhdpi/ic_launcher_foreground.png` | nuevo | `0EFAF9A9D795863EE71E40FD629894E61D4E4037F78633367627EB69CD8B6DEB` |
| `android/app/src/main/res/mipmap-xxhdpi/ic_launcher_monochrome.png` | nuevo | `28838371BC07E4BA7C6C85176919A856F648E653C1823325156FA275166FD8F4` |
| `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` | cambia | `21D7C9F1FAABFC13A0E17FA9E85220257620AA0E57E55533C28F78B1C5E75805` |
| `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_foreground.png` | nuevo | `79B4F0F6D7F925733448A47213BB3181D9810D5704A65DAFF26EC55BFF973EFB` |
| `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_monochrome.png` | nuevo | `276F8B3406CD8B81A9E9AF1D03A0BC77B18435EF25B43D4FA44B2B0134EDCDAF` |
| `android/app/src/main/res/values/ic_launcher_background.xml` | nuevo | `87C0FA5B1F64046F2577B8E1A03BF3AD8BD1BA7CFF3EB64A4A4BF50A46C17D27` |
| `design/icono/LEEME.md` | nuevo | `DF8A6F82745237BC7624B6843B4C61001A797E301AD4305F4A42DE7C8488DC3A` |
| `design/icono/baystream.svg` | nuevo | `4F12646124389F3C1EA36E94EF3DC1B4464370444A164B5E6C66C456032A39BE` |
| `design/icono/baystream_16.svg` | nuevo | `4BE5CF0511B35D26ECE415AA0465A0428316780141044F54004EB9DA64F4E012` |
| `design/icono/baystream_20.svg` | nuevo | `38C92A410021FB6836E40CE9780E633ACB1C1D5759D770F3A8B1FCE122DF480A` |
| `design/icono/baystream_24.svg` | nuevo | `06D68FF4E607A3BEFA3331943AFDDD883B9425D4419E82846AC1DA54BF0C5B19` |
| `design/icono/baystream_32.svg` | nuevo | `8C3C68A773592C59F815E8CF76D115984428B9E5DB1D485EDE1493A994A5CC70` |
| `design/icono/baystream_forma.svg` | nuevo | `04F4F1F089DCF25420FF205DA0F35E3565741C2BCEA6AC891B2CFD295A8FBAAF` |
| `design/icono/baystream_frente.svg` | nuevo | `B975968C040E944FBDE77C8325AFF0359030D41AD705A35AFED208551EA45478` |
| `design/icono/baystream_monocromo.svg` | nuevo | `58DF99FB9A3C51FCDC0B16B1939A138501CB40041D28648E61EAF7CFF8887AF6` |
| `design/icono/generar.py` | nuevo | `3EEBB673E65C7A64E738AB5FCEFDEAB8144334211FAFE4A8E75899BD831F81A9` |
| `design/icono/grafico_play.svg` | nuevo | `CEFAE8D0BD2BAA75CD1E4C7D5FBF6EF3018E3DB1DA098C7B3FE78174DD12D289` |
| `design/icono/play/grafico-1024x500.png` | nuevo | `EF24F425D256E472CB4D3000569885D61F7510DA417CA46E4D7D38DBDBAF0884` |
| `design/icono/play/icono-512.png` | nuevo | `1E860539D0828A7C158168FF8AE96E6BC7ADE0CD9B2000FA9309BB1202281865` |
| `design/icono/vista-previa.png` | nuevo | `F38744B47FC05C4CF7FFBF30A633A776B1B423DB1555BDFF364051DA955B7BF4` |
| `web/favicon.png` | cambia | `9D8DA6448207EB75902183DE44BB1A30816CD8345085250E52736FB29194BBDE` |
| `web/icons/Icon-192.png` | cambia | `21D7C9F1FAABFC13A0E17FA9E85220257620AA0E57E55533C28F78B1C5E75805` |
| `web/icons/Icon-512.png` | cambia | `37E29E43385B43A91446BCA6320A417C4583C4A525D44856C677E21DE8C22CF6` |
| `web/icons/Icon-maskable-192.png` | cambia | `B5BACAC546B7E80AF4D72D1DE4B167634E9247AA1C95B9C639B6802953ADB781` |
| `web/icons/Icon-maskable-512.png` | cambia | `1E860539D0828A7C158168FF8AE96E6BC7ADE0CD9B2000FA9309BB1202281865` |
| `web/manifest.json` | cambia | `9F1AE9CFABD15FE252060F7249916BEA2D493106900CCA55E3AB64315AFC2913` |
| `windows/runner/resources/app_icon.ico` | cambia | `1721C4752FA09CA07B9D3F5438AC99CCC6014AA9E72FD8EAF4703E050CA722BD` |

### Lo que se vio en cada cliente

**Honor `.t88`** (APK `A56775D7…CAA7AC`, compilado en la copia de `%TEMP%`):
- **En el lanzador está el ícono nuevo, con «BayStream» debajo.** El fondo azul, la cuadrícula y el contenedor naranja se ven con la máscara redondeada de MagicOS. Las variantes viejas siguen con el logo de Flutter.
- `aapt2` confirma el adaptativo dentro del APK: `adaptive-icon` con `background` (`#FF0D47A1`), `foreground` y **`monochrome`**.
- **El monocromo no se vio en el teléfono.** El Honor usa el lanzador de MagicOS 9 (`com.hihonor.android.launcher`, Android 15), que no ofrece los íconos temáticos de Material. No cambié ningún ajuste del tema.

**Chrome** (`build/web` de la copia, servido por `tool/t92_server.dart`):
- Los cinco archivos servidos tienen el mismo SHA que los del repo.
- Desde la página, pasando por el service worker (después de actualizarlo), comprobé:
  - el `<link rel="icon">` apunta a `favicon.png`, y su SHA es el nuevo (`9D8DA644…`);
  - el manifiesto trae `theme_color` y `background_color` en `#0D47A1`;
  - sus cuatro íconos (192 y 512, `any` y `maskable`) se decodifican sin error, a su tamaño real y con el SHA nuevo.
- **No vi la pestaña ni el panel Manifest de DevTools.** Carlos no autorizó mirar la ventana de Chrome, y la extensión no abre DevTools. Queda para la aceptación de Codex.

**Windows:**
- **`tool/t93_msix.ps1 -Version 1.0.3.0`**, con el semáforo de Carlos, terminó con código 0 en 64 s.
  - Compiló `baystream.exe` Release en el repo (35 s).
  - Armó y firmó `build/t93/BayStream_1.0.3.0.msix`, SHA-256 `46B30B6E2E32F9128DD82FBA1BF0A1509A64BB0AFA9F3A5007E93D2502419923`. La firma es `Valid`, de `CN=BayStream`, con la huella de Carlos.
  - **El MSIX no se instaló.**
- **Abrí el MSIX como zip:** 82 imágenes en `Images/`. Son las nuevas: el color dominante es `#0C47A1`/`#6E9DE6` y aparece el contenedor naranja.
  - **Pero salen pixeladas.** `msix 3.18.0` lee `logo_path` (`app_icon.ico`) con `decodeImage` de `image 4.9.2`. Para un `.ico` con varios cuadros, ese decodificador devuelve como primera imagen el cuadro 0, que es el de 16 px (`ico_decoder.dart`, líneas 38 a 61). `msix` amplía ese cuadro para todos los mosaicos, incluido el de 150×150 al 400 %.
  - **No lo corregí,** porque cambiarlo está fuera de mi carril. Hay dos salidas, y las decide Carlos o Yov:
    - apuntar `logo_path` a un PNG grande, como `web/icons/Icon-512.png` o `design/icono/play/icono-512.png`, lo que cambia `pubspec.yaml`;
    - o que el `.ico` traiga primero el cuadro de 256 px, lo que cambia el paquete del diseñador.
- **`baystream.exe` en el Explorador y en la barra de tareas.** Usé el banco con `t88acc` de la copia: lo abrí con `explorer.exe` (PID 36412) y lo cerré por PID. Las dos muestran el ícono azul nuevo, en su dibujo de tamaño pequeño.
  - Carlos no autorizó controlar el Explorador. La carpeta `Release` se abrió con `explorer.exe`, se vio en la captura y se cerró por COM.
- **Una trampa de compilación.** La primera recompilación incremental del banco **no volvió a enlazar el `.exe`**: siguió con el ícono de Flutter, porque CMake no vio el cambio del `.ico`. Tocar `Runner.rc` en la copia lo resolvió. El `.exe` del repo sí salió con el ícono nuevo. **Para Carlos:** si un `.exe` sigue con el ícono viejo, basta un `flutter clean` o tocar `Runner.rc`.
- **El almacén real** tiene 354 archivos antes y después, todos con el mismo SHA. La huella se tomó fuera del paquete.

### Validaciones

- **Suite 710/710** y `analyze` en cero. No hay pruebas nuevas: el ícono son recursos, y el nombre y el manifiesto ya los fijan las pruebas de T-88 y de T-92.
- `lib/`, `test/`, `tool/`, `pubspec.yaml`, `pubspec.lock`, `firestore.rules`, las reglas publicadas, `firebase.json`, `AndroidManifest.xml`, `main.cpp`, `Runner.rc` y `CMakeLists.txt` no cambian.
- **El corpus no se repitió:** `lib/` no cambia.
- No corrí `generar.py`. Es código del paquete, y no hacía falta: los SHA ya coinciden.

### Horas

≈ 0.5 h de trabajo: de 15:02 a 15:07 y de 16:41 a 17:05. En medio hubo una pausa larga por el límite de uso. **T-88 suma ≈ 2.0 h frente a 2.5.** El diseño del ícono lo hizo la sesión en la nube (10.45) y sus horas no están aquí.

## Mosaicos del MSIX (10.50)

Timonel · 15-oct-2026 · sobre `4723538` (decisión 10.50).

### El cambio

- **`pubspec.yaml`:** `msix_config.logo_path` pasa de `windows/runner/resources/app_icon.ico` a `web/icons/Icon-512.png`. También cambió el comentario de esa misma línea, que decía «Icono actual de Windows; el propio es de T-88» y dejaba de ser cierto. No cambia nada más del archivo.
- **`pubspec.lock` no cambia:** SHA `577D742E…` antes y después.
- **`test/t93_msix_config_test.dart`:** la prueba «T-93 msix_config identifica la app con el sujeto del certificado» espera la ruta nueva. No hay pruebas nuevas.
- **El `.ico` no cambia.** Es el que lleva `baystream.exe`.

### Validaciones

- Suite **710/710**, T-93 5/5 y `analyze` en cero.

### El MSIX

Lo rearmé con `tool/t93_msix.ps1 -Version 1.0.4.0 -SinCompilar`, con el semáforo de Carlos. El Release del repo no había cambiado desde la compilación de las 16:48. El script terminó con código 0 en 9 s.

- **Paquete:** `build/t93/BayStream_1.0.4.0.msix`, SHA-256 `FE430BD8A9E3D489DB855CF6AD590C6BAF306A24F6E186F7583ED3DFA93DE9D8`.
- **Firma `Valid`**, de `CN=BayStream`, con la huella `60BEF8F4D26ECF7AD25CC478E715CF9B26A278EC`. **No se instaló.**

### Las imágenes

Abrí el paquete como zip: tiene 82 imágenes en `Images/`. Las miré a tamaño real, sin escalar, y **son nítidas**: se ven el casco, las celdas, la tapa y el contenedor naranja, sin los bloques de 16 px ampliados de la versión 1.0.3.0.

| Imagen | Píxeles |
|---|---|
| `Square150x150Logo.scale-400.png` | 600 × 600 |
| `LargeTile.scale-100.png` | 310 × 310 |
| `Square44x44Logo.targetsize-48.png` | 48 × 48 |

Además, `Square44x44Logo.altform-unplated_targetsize-256.png` mide 256 × 256 y `StoreLogo.scale-100.png`, 50 × 50.

**Un matiz:** los tamaños chicos del paquete, de 16 a 48 px, salen reducidos del PNG de 512, no del dibujo a píxel de 16 a 32 px que trae el `.ico`. A 48 px se lee bien. En la barra de tareas y en el Explorador, el `.exe` sigue usando su `.ico`.

### Archivos

| Archivo | SHA-256 |
|---|---|
| `pubspec.yaml` | `1B40E5308D3D1594EAFBF48EE578ABB73A39DC2E3FE0A4551F0D1AC6956F38EA` |
| `test/t93_msix_config_test.dart` | `53D696BDD5905CDD2948AC6632323785B3E3C173DE5D177932BC2BCEB02BE551` |

**Horas:** ≈ 0.2 h. **T-88 suma ≈ 2.2 h frente a 2.5.**
