# Aceptación de T-136 · Candidata 1.0.0 · Capitán Codex

**Dictamen: ACEPTADA con reservas.** Pasan las dependencias, la suite completa,
el análisis, las compilaciones, el SDK de C++ 13.13.1 y el recorrido de cuentas
y sincronización de la Web. El banco nativo de Windows no completó la sesión
contra el emulador; Android repite O-134-2. Las cuentas y el recorrido nativo
pendientes quedan para después de publicar, según el encargo. Carlos decide
y publica; esta aceptación no acredita una publicación ni una sesión real.

3-nov-2026, hora de Guatemala. Carpeta exclusiva:
`C:\Proyectos\baystream-qa-r4`. HEAD separado:
`5ab830b9202f15a79078463cf4c23a7fc2b242c3`, «Sprint 4: T-136, el parche de
seguridad de Firestore en Windows y la candidata 1.0.0».
Se leyeron las decisiones 10.99, 10.100 y 10.101 de `SPRINT-4.md`, las
restricciones vigentes, `docs/T136-RESULTADOS.md`, el LEEME y la procedencia
de Firebase JS 12.19.0. T-137 y la carpeta de T-138 no se tocaron.

## Paso 0 y aislamiento

- Contra `8ea84bd988a2604186bca403709abb1cf6046349`, el diff sin detección de
  renombres contiene exactamente **20 rutas**: `SPRINT-4.md`, el informe de
  T-136 y sus **18 archivos declarados**. Evidencia: `paso0-diff.txt` y
  `head.txt`, bajo `build/t136acc/`.
- Al iniciar, `git diff --stat HEAD` no mostró cambios de contenido; solo
  avisos LF/CRLF de los tres generados de `windows/flutter/`.
- La copia limpia se materializó exclusivamente mediante `git show`:
  **811 archivos** de HEAD. El prerrequisito generado de T-124 se tomó de la
  copia limpia conservada de T-134 en esta misma carpeta; SHA-256
  `d4384834fb9fc9cb18632b87180a7998cc3f91109edcbd33dbbf9787542d1162`.
  Las **811 huellas** siguen idénticas después de suite y analyze.
- Luz verde de Carlos para toda la sesión. Los comandos de Flutter se
  ejecutaron secuencialmente. No son mediciones de los RNF.
- Las pruebas de Codex usaron Firebase local, proyecto **`demo-t136-acc`**. Auth 9399,
  Firestore 8383, websocket 9150, hub 4498 y registro 4598, todos en
  **127.0.0.1**. Se usaron las reglas propuestas de T-130, como en T-134,
  sin desplegarlas ni modificar reglas del repositorio.
- Cuentas y claves sintéticas se mantuvieron en memoria. No se leyeron
  opciones privadas de Firebase ni material de firma de Carlos. El Honor
  no recibió comandos. Carlos confirmó que cerró BayStream instalada.
- El banco parte de `HEAD:tool/t130_emu_main.dart`, con el namespace
  **`t136acc`**. Su entrada privada está en `build/t136acc/banco_main.dart`:
  añade, solo en nativo y después de las guardas, la app demo `[DEFAULT]`
  que necesita el delegado de Firestore (O-134-2). No cambia producto,
  Android ni políticas de red. En Windows exige una ruta TEMP explícita.

## Dependencias y versiones

`pubspec.yaml` coincide con HEAD: `1.0.0+9`, MSIX `1.0.0.0`,
`firebase_core: ^4.15.2`, `cloud_firestore: ^6.10.2`,
**`firebase_auth: 6.7.1` fija** y
**`cloud_firestore_platform_interface: 8.0.7` fija**, de desarrollo.

El cotejo de los lockfiles antes/después confirma diez paquetes de FlutterFire
y ningún otro cambio de paquete:

| Paquete | Antes | Candidata |
|---|---|---|
| cloud_firestore | 6.8.0 | 6.10.2 |
| firebase_core | 4.13.0 | 4.15.2 |
| cloud_firestore_platform_interface | 8.0.6 | 8.0.7 |
| cloud_firestore_web | 5.7.2 | 5.7.3 |
| firebase_core_platform_interface | 8.1.0 | 8.1.1 |
| firebase_core_web | 3.10.0 | 3.12.0 |
| _flutterfire_internals | 1.3.76 | 1.3.77 |
| firebase_auth | 6.5.7 | 6.7.1 |
| firebase_auth_platform_interface | 9.0.6 | 9.1.0 |
| firebase_auth_web | 6.2.6 | 6.3.0 |

Flutter **3.38.9**, Dart **3.10.8**, registrados por el compilador.
Los `pubspec.*` del árbol no se modificaron en esta aceptación.
Evidencia: `dependencias.json`, `pub-get.log` y `copia-manifiesto.json`.

## Suite y análisis en copia limpia

| Comando ejecutado | Resultado |
|---|---|
| `flutter test --reporter json`, una sola corrida | **2101/2101**, cero fallos, cero omitidas, salida 0 |
| `flutter analyze lib test` | **Cero incidencias**, salida 0 |
| Huellas de los archivos de la copia | **811/811** idénticas a HEAD |

La suite duró 151,989 s de comando; el reportero registró 147724 ms.
Analyze informó 12,3 s. Son tiempos informativos de las herramientas.
Registros: `suite.log`, `suite-resumen.json`, `suite-ejecucion.json`,
`analyze.log`, `analyze-ejecucion.json` e `integridad-copia.json`.

## Windows: SDK, compilaciones y banco

Había **64,6 GiB libres** al empezar. `version.h` inicial declaraba 13.9.0.
El primer `-Apartar` no movió nada porque `.dart_tool` todavía resolvía
`firebase_core 4.13.0`. Después de `flutter pub get`, el comando exacto
`powershell -NoProfile -ExecutionPolicy Bypass -File tool\t136_sdk_firebase.ps1 -Apartar`
apartó el SDK a `build\windows\x64\extracted-13.9.0`, sin borrarlo.
Es la ejecución del script en la carpeta de aceptación, sin `-Proyecto`.

La compilación release desde `lib/main.dart` original terminó con salida 0.
El CMake de esa primera compilación registra descarga hasta el 100 %, no
contiene **«Using cached extracted Firebase SDK»** y no enlaza
`extracted-13.9.0`. El ZIP nuevo es
`firebase_cpp_sdk_windows_13.13.1.zip`, de **963.835.368 bytes**.
La nueva cabecera declara MAJOR **13**, MINOR **13**, REVISION **1**.
`t136_sdk_firebase.ps1 -Verificar` termina correctamente:
**«pedida 13.13.1, extraida 13.13.1»**.

El `.exe` original conservado en `candidata/windows/` declara FileVersion y
ProductVersion **1.0.0+9**. El banco se recompiló después desde esta misma
punta, con `T130_PROJECT=demo-t136-acc`, host 127.0.0.1 y
`T130_WINDOWS_STORE=C:\Users\Giova\AppData\Local\Temp\t136acc-windows`.
Su salida completa está en `bancos/windows/`.
El Release habitual de Windows de esta copia quedó con el banco; el `.exe`
original de producto está conservado en `candidata/windows/`. No se empaquetó MSIX.

**Excepción a O-134-1, autorizada expresamente por Carlos en esta sesión.**
Carlos estaba fuera de casa y autorizó a Codex a abrir esta ruta exacta con
`Start-Process explorer.exe -ArgumentList 'C:\Proyectos\baystream-qa-r4\build\t136acc\bancos\windows\baystream.exe'`,
tras comprobar con `Get-Process baystream` que no había ninguna instancia.
La comprobación inmediata dio **Id 37176**, la ruta exacta del banco y
padre **explorer.exe**. El ayudante no lanzó aplicaciones; para interactuar
se seleccionó exclusivamente la ventana de ese ejecutable comprobado.

El banco dibujó el inicio y Nube y cuenta. Se introdujo la cuenta sintética
de oficina y se intentó la sesión. La interfaz respondió:

> No se pudo iniciar sesión: el servicio de cuentas respondió con un error
> que BayStream no reconoce; el código quedó en el registro. Inténtalo de
> nuevo y, si se repite, avisa al responsable.

La misma cuenta y contraseña fueron aceptadas mediante Auth REST local.
Eso acredita la fixture, pero **la sesión nativa no se completó**.
El ejecutable abierto desde Explorador no tenía consola capturada: no se
dispone del código nativo ni se atribuye una causa al rechazo. **No quedan
acreditadas publicación, recepción del movimiento ni cierre desde Windows.**
Este límite queda para la prueba corta posterior, conforme al permiso
explícito del encargo si el banco no llega al emulador.

El ayudante rechazó dos índices de accesibilidad; se continuó por coordenadas
de una captura actual y teclado, exclusivamente dentro del banco. La primera
captura sin activación mostraba la ventana Chrome que lo cubría; se activó
solo el banco y se guardó como evidencia su captura nativa correcta.
No se repitió el incidente de apertura de la app instalada de O-134-1.

El almacén efectivo del banco fue
**`C:\Users\Giova\AppData\Local\Temp\t136acc-windows`**, namespace
**`t136acc`**, con ocho archivos de Hive/locks al cerrar. No se registraron
movimientos Windows. Al terminar se cerró el banco con `Stop-Process -Id 37176`.

**Huella del almacén real antes y después, idéntica:**
`C:\Users\Giova\AppData\Local\BayStream`, **592 archivos, 39.020.174 bytes**,
SHA-256 agregado
`4D2286C0E2BA350B057E94D04867A887B8A56EB9B2F33149A2FA229F25AE94D6`.
Las dos lecturas se ejecutaron con BAT lanzado mediante Explorador,
PowerShell hijo de `cmd.exe`, nieto de `explorer.exe`.
`GetCurrentPackageFullName` devolvió **15700**, sin identidad de paquete,
en ambas: se evita la vista mezclada de T-93. La huella agrega, en orden,
ruta relativa, longitud y SHA-256 de cada archivo; no guarda su contenido.

Evidencia: `sdk-apartar-resuelto.log`, `sdk-version.h`, `sdk-verificar.log`,
`sdk-cmake-resumen.json`, `candidata-windows-real.log`,
`candidata-windows-version.json`, `banco-windows-ejecucion.json`,
`windows-proceso.json`, `windows-auth-resumen.json`, `windows-cierre.json`,
`windows-almacen-banco.json`, `almacen-real-antes.json`,
`almacen-real-despues.json`, `almacen-real-comparacion.json` y
`e2e/windows/00-inicio.{png,txt}`.
Un primer intento del envoltorio de comandos falló antes de ejecutar Flutter
por la posición de `--cwd`; se corrigió la invocación. No se cuenta como
compilación ni como fallo del producto.

## Web: procedencia, arranque y sincronización

La Web release original compiló con salida 0. Su `version.json` declara
**1.0.0**, compilación **9**. `build/web/vendor/firebase/` contiene únicamente
**12.19.0**. `dart run tool/t92_verify.dart build/web` pasa:
**57 archivos, 38.138.364 bytes**.

Se descargó el tarball oficial de **npm `firebase@12.19.0`**, se verificó su
integridad SHA-512 contra el registro y se calcularon los SHA-256 de sus
tres módulos. Coinciden con los originales de `provenance.json`. La única
transformación de los módulos originales es el reemplazo de URL descrito
en el LEEME. Las huellas del build y de las respuestas HTTP del banco
también coinciden con las servidas:

| Módulo | Original npm | Servida por HTTP |
|---|---|---|
| app | `39A50952B5DEF557337B2290069C7D7371F3515AD46C44A43B9C520F734D8D14` | `6831B388C680B3335204FC1EFBCA6D494841949600DF6B6BA3829B3534CBFA1B` |
| auth | `59F60CE3ADCB4C85A5260E963FD14134EEC088DE5B18DDFB9E95771C72F65264` | `0F99FC82C189CC62A37EF58558BBE91A54B83D47A8592B03144E3DC15C678B5C` |
| firestore-pipelines | `E9BB207298105253EB73336C2478A0C30BC31631960EA1BF7CB4B6C87CE05F05` | `0C4E645F0CF31B5553E71922C29EB0314A998940A7949141A668340FBE749A98` |

Chrome **156.0.8078.80**, visible, con contextos nuevos. El banco Web usa
la misma fuente de producto y las mismas dependencias de HEAD. Se sirvió
en `http://127.0.0.1:5942/`, sin acceso a cuentas ni proyectos reales.

| Paso observado | Resultado |
|---|---|
| Arranque, service worker permitido | Cero errores de consola, cero `pageerror`, cero avisos de nivel warning y cero solicitudes bloqueadas; sin aviso de versiones mezcladas |
| Oficina | Inicio de sesión y publicación de la llegada M100, GTSTC |
| Muelle en Chrome | Inicio de sesión, Unirse y apertura de la llegada |
| Movimiento | Una descarga en 002-02-82; **29 por bajar, 1 bajado**; la oficina la recibe en Avance |
| Plan faltante | M100N agregado a la operación M100; diálogo con fecha de publicación y **30 contenedores, 0 reservas, 0 descargas** |
| Recepción del plan | Aviso automático del muelle: **30 contenedores y 0 reservas**, sin Reintentar |
| Listado | **30 filas, revisión 1**; aviso de guardado en oficina y recepción automática en muelle |
| Cierre | **«Operación cerrada.» al primer intento**, después del listado y con el motor siguiendo la operación |
| Lectura independiente del emulador | Operación cerrada, **1 movimiento**, **3 fuentes/3 trozos**; tres huellas y longitudes correctas |

Los contextos del E2E bloqueaban service workers para aislar la caché; eso
produjo dos avisos del instrumental al arrancar. La comprobación adicional
`arranque_limpio.py`, con service worker permitido, elimina esa interferencia
y acredita la consola indicada en la tabla. El aviso informativo normal de
Auth Emulator no corresponde a mezcla de versiones.
Se corrigieron dos patrones del conductor: `1 bajado` en singular y Avance
con una segunda línea accesible. No se repitió el movimiento por esos tiempos
de espera ni se modificó producto.

Evidencia: `npm-huellas.json`, `web-huellas-build.json`, `t92-verificar.log`,
`arranque-limpio.json`, `arranque-limpio.png`,
`web-comandos-t136-e2e.json`, las capturas y árboles de `e2e/oficina/` y
`e2e/muelle/`, y `e2e/remoto-resumen-web-cerrada.json`.
El aviso preexistente de fuente Cupertino apareció durante la compilación;
Android informó operaciones sin comprobar en una dependencia. No se
presentan como advertencias nuevas del analizador.

## Android: compilación y límite O-134-2

`flutter build appbundle --release --build-name=1.0.0 --build-number=9`
terminó con salida 0. El AAB conservado pesa **53.977.878 bytes**.
El manifiesto protobuf dentro del AAB confirma **versionName 1.0.0** y
**versionCode 9**. `jarsigner` confirma el firmante **CN=Android Debug**.
No se armó un AAB publicable ni se subió nada.

El APK debug del banco compiló con salida 0 y se instaló únicamente con
`adb -s emulator-5554` en **BayStream_Tablet**, Pixel Tablet, API 36,
2560 × 1600, 320 dpi. Los reverse fueron solo 8383 y 9399.
La app salió del splash y dibujó el inicio, con Seleccionar archivo y
Nube y cuenta; se abrió el formulario y se intentó la sesión de muelle.
**El proceso siguió vivo, sin FATAL EXCEPTION.**

El código registrado por BayStream es **`unknown`**. El diagnóstico nativo:

```text
Initial task failed for action RecaptchaAction(action=signInWithPassword)with exception - An internal error has occurred. [ Cleartext HTTP traffic to 127.0.0.1 not permitted ]
Inicio de sesión rechazado por Firebase: unknown
```

Se repite el bloqueo HTTP conocido del banco, **O-134-2**. No se alteró
`android/`, el cortafuegos ni la política de red para hacerlo pasar.
El arranque observado no acredita autenticación ni sincronización nativa.
La primera comprobación de cuentas Android reales queda para el Honor
después de Play, según 10.101.

Evidencia: `candidata-aab-ejecucion.json`, `candidata-metadatos.json`,
`aab-firma.log`, `banco-apk-ejecucion.json`,
`tablet-auth-resumen.json`, `tablet-auth-diagnostico.log` y
`e2e/tablet/01-inicio.{png,json}`.

## Reservas y prueba corta después de publicar

| Reserva | Prueba pendiente de Carlos |
|---|---|
| Windows: sesión nativa no completada en el banco | Con BayStream 1.0.0 instalada, cuenta de oficina y un viaje de prueba propio: iniciar sesión, publicar, recibir un movimiento del muelle desde Chrome y cerrar |
| Android: O-134-2, HTTP del banco bloqueado | Apenas llegue el AAB firmado a Play: en el Honor, arranque, sesión de muelle, Unirse y sincronización de un movimiento, plan y listado; comprobar el cierre |
| Entorno publicado | Comprobar 1.0.0 (9), MSIX 1.0.0.0 y el SDK Web 12.19.0 servido; el AAB de esta aceptación tiene firma debug y no se publica |

No se encontró un fallo de producto que obligue a rechazar la candidata en
las pruebas completadas. Los dos clientes nativos conservan reservas de
integración: no se dan por aprobados por la suite ni por compilar.
Si Android falla después de Play, sigue vigente la vuelta a 0.4.2 con el
`versionCode` siguiente disponible, según 10.101 y la sección 4.5 de la lista.
**O-136-1** permanece diferida según 10.99.

## Cierre y entrega

El banco Windows quedó cerrado por su Id, la tablet con el banco detenido
y los reverse 8383/9399 retirados; al final se cerró el emulador Android que
Codex había iniciado para esta aceptación. Se cerraron los contextos Chrome
propios, el conductor 5941, el servidor 5942 y el árbol propio de Firebase.
La operación sintética final permanece cerrada, con **1 movimiento** y sus
**3 fuentes**, todas con longitud y huella correctas. No se borró ni reescribió
ese movimiento. La copia limpia conserva **811/811 huellas** y el diff final
de archivos rastreados no muestra cambios de contenido. Solo este informe
es nuevo; se mantienen los avisos preexistentes de fin de línea de Windows.
El cierre final se comprobó a las **17:22:34, Guatemala**, sin escuchas en
5941, 5942, 8383, 9399, 4498, 4598 o 9150 y sin procesos `baystream`.

Evidencia de cierre y verificación final: `cierre-final.json`,
`evidencia-indice.json`, `integridad-copia.json`, `git-final.txt` y
`e2e/remoto-resumen-final.json`.

Único archivo previsto para Git: **`docs/t136/aceptacion-codex.md`**.
Las evidencias e instrumentos están en **`build/t136acc/`**, ignorado por
`/build/`; no se propone forzarlos a Git. **No cambian `pubspec.yaml` ni
`pubspec.lock`**, ni código, opciones Firebase, archivos H5 o configuración local.

Bloque para Carlos, desde `C:\Proyectos\baystream-qa-r4`, con HEAD separado:

```powershell
git add -- docs/t136/aceptacion-codex.md
git commit -m "Sprint 4: aceptacion de la candidata 1.0.0"
git push origin HEAD:sprint-4
```

No se ejecutaron esos comandos ni ninguna otra escritura de Git.

Tres líneas:

1. **ACEPTADA con reservas:** 2101/2101, analyze cero, seis compilaciones correctas y C++ 13.13.1 comprobado.
2. Web 12.19.0 cotejada con npm y por HTTP; cuentas, movimiento, plan, listado y cierre pasan en Chrome.
3. Windows y Android requieren la prueba nativa posterior; almacén real idéntico y bancos cerrados, sin publicar.

Mensaje para Yov:

> Yov: aceptación de T-136 terminada, ACEPTADA con reservas. Suite 2101/2101,
> sin omitidas, analyze lib/test cero, C++ 13.13.1 comprobado, Web 12.19.0
> cotejada con npm/HTTP y E2E completo en Chrome. AAB 1.0.0 (9), firma debug.
> Android arranca y repite O-134-2; Windows dibuja pero no completa la sesión
> del banco, así que sus cuentas/publicación/recepción/cierre van a la prueba
> corta posterior. Carlos autorizó abrir el banco vía Explorador como excepción
> a O-134-1: ruta y PID verificados, cerrado por Id; almacén real idéntico antes
> y después (592 archivos). Solo va a Git docs/t136/aceptacion-codex.md;
> instrumental cerrado, sin publicaciones ni cambios de producto.
