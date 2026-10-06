# T-70 · Resultados de la espiga de sincronización

**Autor:** Capitán Codex · **Fecha:** 6-oct-2026 · **Estado:** espiga completada con incidencias de Windows declaradas. **T-79 no queda implementada ni aceptada por este resultado.**

## 1. Resultado y alcance

Windows de escritorio, Android en el Honor y Web en Chrome crearon cuentas con correo, cerraron sesión, iniciaron sesión, escribieron documentos y recibieron los cambios de los otros clientes mediante listeners. En cada plataforma una escritura con la red de Firestore deshabilitada quedó pendiente y llegó a los otros dos clientes al reconectar.

**Nueve controles funcionales de nueve pasaron.** Los tres clientes observaron los mismos **16 documentos confirmados por el emulador**: tres escrituras normales, tres pendientes reconectadas y diez de medición. Esto acredita el flujo mínimo local; los errores del plugin nativo y las restricciones de soporte impiden recomendarlo directamente para producción en Windows.

La espiga completa está fuera del repositorio, en `C:\Proyectos\espiga-sync\`. Por parte de Codex, el único archivo creado o modificado en el repositorio es **`docs/T70-RESULTADOS.md`**. No se tocaron `lib/`, `test/`, `pubspec.yaml`, `pubspec.lock`, los archivos congelados, las opciones de Firebase ni los documentos de planificación. No se ejecutaron operaciones de Git de escritura, `git status` o publicaciones. El trabajo concurrente de Timonel queda fuera de esta declaración.

El control de entrada fue `git log --oneline -5`: el último commit era `51857ba Sprint 3: apertura con SPRINT-3.md, ola 1 y caso real anonimizado`. Se leyeron completos `AGENTS.md`, `SPRINT-3.md` y `docs/S3-CASO-MAGELLAN-STAR.md`; de Sprint 2 se leyeron las decisiones 10.46–10.49. Carlos autorizó la ventana de Flutter y reservó el Honor para T-70.

## 2. Entorno y versiones exactas

| Componente | Versión o entorno utilizado |
|---|---|
| Flutter / Dart | 3.38.9 stable / 3.10.8 |
| Windows | Windows 11 Home, 10.0.26300, compilación 26300, x64 |
| Android | Honor NAA-LX3, Android 15, dispositivo físico por USB |
| Chrome | 154.0.8037.98, ventana visible abierta por Carlos |
| Node / Firebase CLI | 24.14.0 / 15.32.1 |
| Java | OpenJDK 21.0.8, incluido en Android Studio |
| Emulador Firestore | 1.22.0, edición standard |
| Emulador Auth | Incluido en Firebase CLI 15.32.1; sin versión independiente observada |
| `firebase_core` / `firebase_auth` / `cloud_firestore` | **4.13.0 / 6.5.7 / 6.8.0**, fijadas en la espiga |
| Interfaces core / auth / firestore | 8.1.1 / 9.0.6 / 8.0.6 |
| Implementaciones Web core / auth / firestore | 3.12.0 / 6.2.6 / 5.7.2 |
| Firebase SDK de Windows / JavaScript | C++ 13.9.0 / JS 12.19.0, según los paquetes usados |
| `_flutterfire_internals` | 1.3.76 |

Java y ADB no estaban en `PATH`, pero sí instalados. Se usó ADB por su ruta absoluta y Java mediante variables de entorno del proceso de emuladores. **No se instaló ninguna herramienta global ni se actualizaron Flutter o los paquetes del repositorio.** El emulador descargó su JAR en `C:\Proyectos\espiga-sync\emulator-cache\` y la compilación descargó el SDK de C++ dentro del build de la espiga.

### Compatibilidad con BayStream

El manifiesto de BayStream pide `firebase_core ^4.4.0` y `cloud_firestore ^6.1.2`; su lock resolvía **4.13.0 y 6.8.0** al inspeccionarlo. Se eligió `firebase_auth 6.5.7`, cuyo manifiesto depende de `firebase_core ^4.13.0`.

Además de resolver el proyecto mínimo, se copiaron el manifiesto y el lock de BayStream a `C:\Proyectos\espiga-sync\evidence\compatibility\`, se fijaron allí core/firestore a las mismas versiones probadas y se añadió auth. **`flutter pub get` salió con código 0** junto con todas las demás dependencias de BayStream. Incorporó cuatro paquetes: auth, sus dos implementaciones y `http 1.6.0` transitivo. No es una compilación del producto ni autoriza cambios en sus manifiestos.

## 3. Aislamiento de Firebase y método

- Proyecto de emuladores: **`demo-baystream-t70`**, sin recursos reales. Auth escucha en `127.0.0.1:9099`; Firestore en `127.0.0.1:8080`. Hub: 4400; logging: 4500; websocket del emulador: 9150. Interfaz del emulador deshabilitada.
- Inicialización explícita: `Firebase.initializeApp(name: '[DEFAULT]', demoProjectId: 'demo-baystream-t70')`. La app conecta ambos servicios a los emuladores antes de registrar cuentas, abrir listeners o escribir.
- Honor accede a los puertos 9099, 8080 y 8765 mediante `adb reverse`, con `automaticHostMapping: false`. No se usa la IP especial de un emulador Android ni se expone el servicio a la LAN.
- Un controlador Node en `127.0.0.1:8765` ordena acciones a los clientes y guarda sus respuestas. El sitio Flutter se sirve localmente en `127.0.0.1:8877`.
- Solo se escriben documentos sintéticos en `t70_events`. Las reglas locales exigen sesión y limitan el acceso a esa colección. **No representan la lista de autorizados ni los roles de T-79/T-80.**
- Se crearon cuentas de prueba con dominio `example.test` y contraseñas efímeras, sin registrarlas. No se usaron archivos de configuración de proyectos reales, `firebase login` ni `flutterfire configure`.
- No se accedió a producción ni al proyecto de H5. Las descargas de paquetes y SDK públicos son distintas de acceder a un proyecto Firebase. Los proyectos `demo-` carecen de recursos reales y fallan al intentar usar servicios no emulados, según la [documentación del emulador](https://firebase.google.com/docs/emulator-suite/connect_firestore).

## 4. Matriz de aceptación

| Plataforma | Crear cuenta | Iniciar sesión después de salir | Escribir | Escuchar otro cliente | Sin conexión a Firestore | Reconectar |
|---|---|---|---|---|---|---|
| Windows escritorio | Pasa, con incidencias de Auth | Pasa, con incidencias de Auth | Pasa | Pasa; recibe Web y Honor | Pasa; evento local pendiente | Pasa; Web y Honor reciben y llega ACK |
| Android, Honor | Pasa | Pasa | Pasa | Pasa; recibe Windows y Web | Pasa; evento local pendiente | Pasa; Windows y Web reciben y llega ACK |
| Web, Chrome | Pasa | Pasa | Pasa | Pasa; recibe Windows y Honor | Pasa; evento local pendiente | Pasa; Windows y Honor reciben y llega ACK |

En cada prueba sin conexión:

1. Se espera la terminación de `disableNetwork()`.
2. Se escribe un documento nuevo y se observa localmente `hasPendingWrites: true`.
3. Durante **2.5 segundos**, los registros no muestran recepción en los otros clientes ni ACK de esa escritura.
4. Se ejecuta `enableNetwork()`; los otros dos reciben el documento con `hasPendingWrites: false` e `isFromCache: false`, y el emisor recibe ACK.

**Alcance preciso de «sin conexión»:** desconexión de Firestore mediante su SDK, manteniendo activo el enlace al controlador. No se cortó físicamente USB/Wi-Fi ni se certificó la pérdida total de red. `persistenceEnabled: false` fija la prueba a una cola en memoria. **No se probó que una escritura sobreviva a cerrar la app o recargar Chrome.** No se usó el almacén Hive de BayStream, por lo que no hay una prueba de persistencia de `%LOCALAPPDATA%\BayStream` ni de su variante bajo `Packages`.

### Compilación y revisión

| Verificación ejecutada en la espiga | Resultado |
|---|---|
| `flutter pub get` | Código 0; versiones fijadas |
| `flutter build windows --debug` | EXE generado; advertencias LNK4099 declaradas abajo |
| Recompilación Windows tras corregir nombre de app | EXE generado y flujo completo ejecutado |
| `flutter build web --debug` y recompilación | Sitio generado; flujo ejecutado en Chrome visible |
| `flutter build apk --debug` | APK generado e instalado con ADB; flujo ejecutado en Honor |
| `node run-matrix.mjs windows web android` | Código 0; nueve controles y diez repeticiones |
| Análisis estático final de la espiga | **Código 0, `No issues found!`** |
| Resolución con todas las dependencias de BayStream, fuera del repo | Código 0 |

El análisis final detectó primero dos fuentes que faltaban en la copia de compatibilidad; se copiaron esas dos fuentes a esa carpeta externa y se repitió hasta obtener cero. No se cambiaron los archivos de BayStream.

Se revisó la ventana de Windows con el error inicial, la captura de Chrome aportada por Carlos con cuenta/sesión/listo y la captura de Honor con recepciones confirmadas. La automatización visual de Chrome se detuvo por no poder verificar su URL; no se considera esa detención un fallo de Firebase. La captura de Carlos muestra `127.0.0.1:8877` y el modo emulador. Los resultados posteriores provienen de acciones reales del SDK y sus registros.

**No se ejecutó la suite ni el análisis de BayStream:** su carril pertenecía a Timonel. El piso de 282 pruebas procede del brief de apertura y no se presenta como una ejecución de Codex en esta tarea.

## 5. Diez repeticiones orientativas

Corrida `1791329135124`, **6-oct-2026, 17:25:35–17:25:47, America/Guatemala**. Un único proceso Node marca ambos extremos con su reloj monotónico: llegada del aviso `write_started` del emisor y llegada del aviso del listener remoto con documento confirmado. Esto evita comparar relojes de Windows y Honor. Incluye el retorno HTTP previo a `set`, la notificación local de cada cliente y su envío HTTP al controlador; **no es latencia pura del backend**.

Las diez mismas escrituras Windows fueron recibidas por Chrome y por Honor. No se ejecutaban comandos de Flutter en esa ventana, anunciada con `SEMÁFORO:` al comenzar y terminar.

| Repetición | Windows → Chrome, ms | Windows → Honor, ms |
|---:|---:|---:|
| 1 | 32.03 | 69.23 |
| 2 | 29.48 | 62.52 |
| 3 | 22.40 | 65.28 |
| 4 | 25.95 | 62.76 |
| 5 | 38.70 | 88.51 |
| 6 | 39.87 | 92.00 |
| 7 | 22.96 | 69.32 |
| 8 | 21.73 | 78.41 |
| 9 | 20.53 | 69.92 |
| 10 | 20.53 | 72.83 |
| **Media** | **27.42** | **73.08** |
| **Mediana** | **24.45** | **69.62** |
| **Mínimo–máximo** | **20.53–39.87** | **62.52–92.00** |

Es una espiga local en binarios debug, con Chrome y emulador en la misma máquina y Honor por USB. No demuestra rendimiento en Internet, TLS, sesiones prolongadas, concurrencia de operadores ni carga de 176 movimientos. **No es H5 ni satisface un RNF de producción.**

## 6. Incidencias, con mensajes exactos de Windows

### Inicialización: app con nombre demo

El primer EXE llamó `initializeApp(demoProjectId: ...)`, que creó una app con el nombre del proyecto demo. Firestore consultó la app por defecto al crear su delegado y falló antes de la creación de cuenta:

```text
[core/no-app] No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()
```

La espiga se corrigió indicando explícitamente `name: '[DEFAULT]'`, sin cambiar el ID demo. Se recompilaron los clientes y el flujo pasó. El stack completo queda en `evidence/windows-runtime-initial-error.txt`.

### Auth: mensajes desde un hilo incorrecto

El EXE corregido emitió ambos mensajes siguientes. **No se corrigió ni silenció el plugin.** Cuenta, sesión y sincronización pasaron en esta corrida; eso no prueba que los errores sean inocuos.

```text
[ERROR:flutter/shell/common/shell.cc(1178)] The 'firebase_auth_plugin/auth-state/[DEFAULT]' channel sent a message from native to Flutter on a non-platform thread. Platform channel messages must be sent on the platform thread. Failure to do so may result in data loss or crashes, and must be fixed in the plugin or application code creating that channel.
[ERROR:flutter/shell/common/shell.cc(1178)] The 'firebase_auth_plugin/id-token/[DEFAULT]' channel sent a message from native to Flutter on a non-platform thread. Platform channel messages must be sent on the platform thread. Failure to do so may result in data loss or crashes, and must be fixed in the plugin or application code creating that channel.
```

### Firestore: rechazo de keepalive gRPC durante la espera

El cliente Windows recibió este mensaje antes de la corrida de medición. Posteriormente completó los nueve controles y sus diez escrituras; no se observó pérdida de documentos en ellos. No se realizó una prueba prolongada de estabilidad.

```text
I0000 00:00:1791328802.813879   15628 chttp2_transport.cc:1204] ipv4:127.0.0.1:8080: Got goaway [11] err=UNAVAILABLE:GOAWAY received; Error code: 11; Debug Text: too_many_pings {file:"D:\\a\\firebase-cpp-sdk\\firebase-cpp-sdk\\out-sdk\\external\\src\\firestore-build\\external\\src\\grpc\\src\\core\\ext\\transport\\chttp2\\transport\\chttp2_transport.cc", file_line:1193, created_time:"2026-10-06T23:20:02.8010992+00:00", http2_error:11, grpc_status:14}
E0000 00:00:1791328802.815659   15628 chttp2_transport.cc:1232] ipv4:127.0.0.1:8080: Received a GOAWAY with error code ENHANCE_YOUR_CALM and debug data equal to "too_many_pings". Current keepalive time (before throttling): 30000ms
```

### Compilación de Windows

La primera compilación produjo **1321 advertencias LNK4099** por archivos PDB ausentes en bibliotecas del SDK Firebase. Terminó generando el EXE. Un mensaje representativo exacto:

```text
firebase_firestore.lib(7ba01613985f32fe50e0c125a0414f54_firebase_firestore.dir_Debug_aggregate_query.obj) : warning LNK4099: no se encontró PDB 'firebase_firestore.pdb' con 'firebase_firestore.lib(7ba01613985f32fe50e0c125a0414f54_firebase_firestore.dir_Debug_aggregate_query.obj)' o en 'C:\Proyectos\espiga-sync\build\windows\x64\runner\Debug\firebase_firestore.pdb'; se vinculará el objeto sin tener en cuenta información de depuración [C:\Proyectos\espiga-sync\build\windows\x64\runner\espiga_sync.vcxproj]
```

No se añadieron supresiones ni se modificaron paquetes para ocultarlas. El log completo está fuera del repositorio. La CLI también emitió una deprecación `DEP0169` de Node; Android emitió notas de Java por APIs deprecated/unchecked en sus dependencias. Ninguna impidió la compilación o el flujo probado.

## 7. Recomendación para T-79

**Continuar con cuentas por correo y Firestore para Android y Web, con una cola persistente propia detrás del contrato del repositorio. Para la oficina en Windows, la alternativa inmediata recomendada es ejecutar la Web en Chrome. No aprobar todavía Firebase nativo de Windows para producción.**

Las operaciones básicas comparten API y pasaron en los tres clientes, pero la [documentación oficial de Firebase para Flutter](https://firebase.google.com/docs/flutter/setup) marca Auth/Firestore en Windows como beta y limita Firebase en Windows a flujos de desarrollo local. A esto se suman los errores observados de Auth y keepalive. Un éxito con el emulador no elimina esa restricción.

Para abrir T-79:

1. Mantener dominio sin Firebase y un adaptador de sincronización en datos. Android y Web pueden usar el transporte Firestore probado. La propuesta de usar Chrome en la oficina requiere la decisión de Carlos: no cambia por sí sola el alcance de Windows escritorio.
2. Persistir cada movimiento y su identificador estable en el almacén local existente **antes** de enviarlo; conservarlo pendiente hasta confirmación remota. Diseñar reintentos e idempotencia para no duplicar movimientos. La cola en memoria probada aquí no protege un cierre o reinicio.
3. Probar al implementar T-79 cierre/reinicio sin red, rechazo de permisos, sesión vencida, escrituras concurrentes y recuperación. La lista de autorizados y los roles deben imponerse con reglas reales; las reglas sintéticas de esta espiga no sirven para producción.
4. Si Windows nativo conectado es indispensable, abrir y presupuestar una prueba de un adaptador de producción, por ejemplo mediante un backend autenticado que valide permisos y entregue cambios. Ese backend y su despliegue **no se implementaron** en T-70. No basta sustituir el listener por REST sin resolver entrega de cambios, tokens, cola y conflictos.
5. Mantener el punto de control del **14-oct**: si no hay sincronización aceptable, entregar el módulo de muelle en un dispositivo con exportación de bitácora, según Sprint 3. Carlos conserva la operación de las consolas y cualquier publicación futura.

La elección de versión aquí reproduce el lock inspeccionado y comprueba compatibilidad. No recomienda actualizar paquetes del producto ni añadir dependencias no autorizadas.

## 8. Evidencia y reproducción

Todo lo siguiente permanece en `C:\Proyectos\espiga-sync\`, fuera del repositorio público:

| Ruta dentro de la espiga | Contenido |
|---|---|
| `README.md` | Pasos de reproducción y reserva de recursos |
| `pubspec.yaml`, `pubspec.lock`, `lib/`, `windows/`, `android/`, `web/` | App mínima y plataformas |
| `firebase.json`, `firestore.rules`, `start-emulators.ps1` | Emuladores con ID demo y reglas locales |
| `control.mjs`, `serve-web.mjs`, `run-matrix.mjs`, `summarize.mjs` | Controlador, servidor local, controles y resumen |
| `evidence/matrix-1791329135124.json` | Nueve controles y diez muestras originales |
| `evidence/events.jsonl`, `evidence/summary.json` | Eventos con reloj monotónico y cálculo reproducible |
| `evidence/hashes.json` | SHA-256 de matriz, eventos, resumen y lock de la espiga |
| `evidence/windows-runtime-initial-error.txt`, `evidence/windows-runtime-final.txt` | Error inicial y mensajes del EXE probado |
| `evidence/windows-build.txt`, `evidence/windows-rebuild.txt` | Compilaciones de Windows y mensajes completos |
| `evidence/web-build.txt`, `evidence/web-rebuild.txt`, `evidence/android-build.txt` | Compilaciones Web/Android |
| `evidence/analyze-final.txt` | Análisis final en cero |
| `evidence/compatibility/` | Resolución con copia externa de dependencias de BayStream |
| `evidence/chrome-account-user.png`, `evidence/honor-app.png` | Captura de Carlos y revisión de recepciones en Honor |

No se versionan cuentas, datos del emulador, binarios ni capturas de la espiga. El informe no contiene credenciales ni datos del corpus. La operación de 176 movimientos y la aceptación de T-66/T-67 no se ejecutaron en esta tarea. **T-68 espera el anuncio de Carlos de que T-66/T-67 están en un commit; antes corresponde su aceptación cruzada.**

Al cerrar T-70 se detuvieron únicamente sus emuladores, controlador y servidor Web; se detuvo el paquete propio de la espiga en Honor y se retiraron sus tres `adb reverse`. Se verificó que los siete puertos locales de la espiga ya no estaban en escucha. Honor queda libre; el APK de prueba queda instalado para reproducir la espiga, con un identificador distinto de BayStream. Los procesos compartidos de Gradle/Kotlin no se tocaron.

## 9. Entrega a Carlos

**Archivo exacto modificado en el repositorio:** `docs/T70-RESULTADOS.md`.
**`pubspec.yaml` y `pubspec.lock` del repositorio:** sin cambios de Codex.

Bloque para que Carlos ejecute en la rama `sprint-3`, únicamente con este informe:

```powershell
git add -- docs/T70-RESULTADOS.md
git commit -m "T-70: espiga local de sincronizacion y recomendacion para T-79"
git push
```

Tres líneas de resumen:

- Se creó y probó la espiga fuera del repositorio, con cuentas y Firestore solo en emuladores.
- Los tres clientes pasaron escritura, listener, cola en memoria y reconexión; se midieron diez escrituras.
- Se documentaron los errores de Windows y se recomienda Chrome para la oficina y cola persistente propia para T-79.

Mensaje listo para Yov:

> T-70 completada como espiga local en C:\Proyectos\espiga-sync, sin acceder a proyectos Firebase reales ni tocar lib/test/pubspec del repo. Core 4.13.0, Auth 6.5.7 y Firestore 6.8.0 resuelven junto con todas las dependencias de BayStream. Windows, Chrome y Honor pasaron cuenta, sesión, escritura, listener, disableNetwork y reconexión: 9/9 controles y 16 documentos confirmados en cada cliente. Diez escrituras Windows dieron medias orientativas de 27.42 ms a Chrome y 73.08 ms a Honor por USB; no es H5. Windows emitió errores de hilo de Auth y too_many_pings; los mensajes exactos están en docs/T70-RESULTADOS.md. Firebase limita Windows a desarrollo local: recomiendo Android/Web para el transporte y Chrome en Windows para la oficina, con decisión de Carlos y cola persistente propia; Windows nativo de producción necesita otro adaptador o una decisión explícita de alcance. No se probó durabilidad al reiniciar, red física ni 176 movimientos. Análisis final de la espiga: cero. Commit propuesto: T-70: espiga local de sincronizacion y recomendacion para T-79. T-68 y la aceptación cruzada de T-66/T-67 esperan el aviso de Carlos.
