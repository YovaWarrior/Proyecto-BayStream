# T-126 · La Expo de pruebas en la 3.2.0 — resultados y guion

**Estado (28-oct, 10:40): terminada; Yov revisa.** Todo se corrió con luz verde de Carlos, uno a la vez en la máquina:

- las dependencias;
- las 22 pruebas del curso;
- el rojo y el verde;
- el emulador con su consola y las dos baterías;
- la suite completa;
- `analyze`;
- la cobertura con su reporte;
- la prueba que se ve moverse, en la ventana real de Windows, en tres tamaños;
- las capturas.

Lo único que no se hizo es el extra en el emulador Android.

**El entorno:**

- **Carpeta y rama:** `C:\Proyectos\baystream-expo`, en `expo-pruebas` (la excepción de 10.70 a «no cambies de carpeta»).
- **Base:** `d41ad8c` (T-125, la 3.2.0) encima de `065ef68` (10.69 y 10.70) y de `9738be1`. Lo comprobé antes de empezar y otra vez al reanudar, con `git branch --show-current` y `git log --oneline -3`.
- **Material del curso:** nada de esta rama entra en `sprint-4` ni en `master`.
- **Versiones:** Flutter 3.38.9, Firebase CLI 15.32.1, Node 24.14.0 y Python 3.14.3. La laptop, hoy, a 1920 × 1080 y al 125 %.
- **No se tocó** `lib/`, `lib/main.dart`, las opciones de Firebase, Firebase de producción ni los scripts de T-80, T-99 y T-113.
- **Solo datos sintéticos;** nada del corpus. De `C:\Proyectos\baystream-pruebas` solo se leyó, y ninguna otra carpeta se abrió.
- **Un descuido:** antes de la luz verde corrí `flutter --version` una vez. Solo lee la versión; no compiló ni tocó `.dart_tool/`.

## 1. Lo que se entrega

| Archivo | Qué es |
|---|---|
| `test/curso/caja_blanca_iso6346_test.dart` | 16 pruebas de caja blanca de T-116, idénticas |
| `test/curso/funcional_sincronizacion_test.dart` | 3 pruebas de RF-032 con `fake_cloud_firestore`, idénticas |
| `test/curso/interfaz_buscador_test.dart` | 2 pruebas de interfaz del buscador, idénticas |
| `test/curso/expo_rojo_verde_test.dart` | nueva: ISO 6346, en rojo solo con un interruptor |
| `integration_test/expo_recorrido_test.dart` | nueva: la prueba que se ve moverse |
| `integration_test/expo_escala.dart` | nueva: el plano de llegada de T-100, armado en memoria |
| `integration_test/expo_ventana.dart` | nueva: fija el tamaño de la ventana antes del primer cuadro |
| `tool/cobertura_html.py` | el reporte HTML de cobertura de T-116, idéntico |
| `tool/expo_emulador.ps1` | nuevo: el emulador de Firestore con su consola en 127.0.0.1:4000 |
| `.gitignore` | una línea: `/coverage/` |
| `pubspec.yaml` | `fake_cloud_firestore: 4.2.0` fija en `dev_dependencies`, con su comentario |
| `pubspec.lock` | 9 paquetes nuevos y `equatable` 2.0.8 → 2.1.0 |
| `docs/T126-RESULTADOS.md` | este informe |

`git diff --stat` muestra solo `.gitignore`, `pubspec.yaml` y `pubspec.lock`, y los únicos archivos sin versionar son los diez nuevos de la tabla. Los tres archivos generados de `windows/flutter/` solo avisan del final de línea, como en T-125: no cambian.

## 2. Las 21 pruebas de T-116, en la 3.2.0

Se trajeron de `pruebas-curso` (`161d58e`) **byte por byte**: los tres archivos de `test/curso/` y `tool/cobertura_html.py` tienen el mismo SHA-256 que en `baystream-pruebas`, también al final de la tarea. Mismos casos, mismas expectativas.

**Adaptaciones de API: ninguna, y la corrida lo confirma** (22 de 22, con la de rojo → verde). Lo había comprobado antes contra el código:

- Todo lo que usan la caja blanca y RF-032 es igual en la v3.0 y en la 3.2.0, archivo por archivo: `iso6346_check_digit.dart`, `firestore_operation_sync.dart`, `sync_engine.dart`, `session_repository.dart`, `discharge_progress.dart`, `failures.dart`, `entities.dart` y los apoyos `t75_memory_log.dart`, `t82_fixture.dart` y `t76_fixture.dart`.
- El buscador (`container_search_delegate.dart`) cambió con el rediseño, pero no en lo que la prueba usa:
  - el parámetro opcional `tabController` pasó a ser `onIrAlPlano`;
  - «sin resultados» lleva la ilustración del paquete;
  - cada fila lleva `IconoDelContenedor`.

  El constructor, los dos textos, las filas `ListTile` y lo que hace al elegir siguen iguales.

**Dependencias (10.12).** Antes de tocar `pubspec.yaml` corrí `flutter pub add --dev fake_cloud_firestore:4.2.0 --dry-run`. Dijo «Would change 10 dependencies»: 9 paquetes nuevos y `equatable` 2.0.8 → 2.1.0, exactamente lo autorizado. (Salió con código 1 porque esta carpeta nueva no tenía `.dart_tool/package_config.json`; la resolución sí terminó.) Después escribí la línea en `pubspec.yaml`, con el comentario de T-116, y corrí `flutter pub get`, que dijo «Changed 10 dependencies!».

Comparé el lock bloque por bloque con la copia de antes (`build/expo/03-lock-comparado.txt`):

- había 117 paquetes y ahora hay 126; ninguno se retiró;
- el único que cambia es `equatable`, de 2.0.8 a 2.1.0;
- la sección `sdks` es igual;
- los 10 bloques nuevos o cambiados son idénticos, con su sha256, a los del lock de `pruebas-curso`: `antlr4` 4.13.2, `cel` 0.5.6, `fake_cloud_firestore` 4.2.0, `fake_firebase_security_rules` 0.5.4, `logger` 2.8.0, `mock_exceptions` 0.8.2, `more` 4.7.0, `rx` 0.5.0, `rxdart` 0.28.0 y `equatable` 2.1.0.

**`pubspec.yaml` y `pubspec.lock` cambian.**

## 3. La prueba que se ve moverse

```powershell
flutter test integration_test/expo_recorrido_test.dart -d windows --dart-define=EXPO_PAUSA_MS=1200
```

### 3.1 Cómo está hecha

**La app es la del producto**, `BayStreamApp` con sus temas y su página, abierta como en los bancos de `tool/` (`tool/t124_main.dart`), con tres cambios y nada más:

1. **El archivo:** el selector de archivos devuelve `T100_LLEGADA.edi`, el plano de llegada sintético de T-100: BUQUE MANUAL, viaje M100, de PAMIT a GTSTC, con 60 a bordo, 30 que se descargan en GTSTC y 30 de paso.
   - Los bytes entran por la entrada real del producto: el botón «Seleccionar archivo» del inicio, el lector y el previo.
   - `expo_escala.dart` lo arma en memoria con las piezas de `tool/t100_sintetico.dart` (la caja, la celda, el número y el mensaje) y solo repite el orden de las celdas, que en ese script vive dentro de `main()`.
   - **Es byte por byte el archivo de T-100:** generé `T100_LLEGADA.edi` con `dart tool/t100_sintetico.dart %TEMP%\expo\t100-001316` y lo comparé con el de memoria. Los dos tienen 8021 caracteres y son iguales (`build/expo/22-escala-comparada.log`).
   - La prueba lo pasa primero por el lector real y comprueba las cuentas de T-100: 60 leídos, 30 que bajan, 30 de paso y 0 que se cargan.
2. **Sin Firebase:** la sesión es la local (`LocalSessionRepository`), la de un solo dispositivo, y el repositorio de buques solo lee BAPLIE.
3. **El almacén:** una carpeta nueva en `%TEMP%\expo\almacen-*`, con namespace `expo`.
   - Nunca es el almacén real, y cada corrida empieza sin buques guardados, así que el recorrido es siempre el mismo.
   - Al terminar, la prueba cierra y borra su almacén.
   - Al empezar, barre los `almacen-*` que dejó una corrida cortada antes del cierre. Antes de ese barrido quedaron dos (de la corrida que falló en el paso 1 y de la que detuvimos); la corrida siguiente los borró.

**Los ocho pasos**, cada uno con `expect`. La consola anuncia cada paso y su tiempo («EXPO · paso 3 de 8 · …»).

| Paso | Lo que hace la prueba | Lo que comprueba |
|---|---|---|
| 1 | Toca «Seleccionar archivo» en el inicio | Abre el previo de `T100_LLEGADA.edi`, que propone la escala PAMIT |
| 2 | «Confirmar» en la banda; en «Puerto de esta escala» cambia PAMIT por GTSTC; marca «No lo tengo» en el límite de apilamiento y toca «Confirmar y ver el plano» | Antes, el chip elegido es PAMIT; después, GTSTC, con «30 se descargan · 0 se cargan · 30 de paso». El viaje queda publicado con la escala GTSTC y 60 contenedores, y se queda en el Plano |
| 3 | Toca en la silueta las bahías 02, 06 y 10 | Sale la rejilla de cada una |
| 4 | Abre el buscador y escribe MNLU, MNLU00002 y MNLU0000200 | Queda un solo resultado. Al tocarlo, el plano va a la bahía 06 y resalta la celda 006-02-82 |
| 5 | Pasa al modo Descarga y toca 006-02-82 y 006-01-82 | Las dos quedan descargadas en la bitácora, cada una con su aviso «Descargado · …» |
| 6 | Toca otra vez 006-02-82, luego «Deshacer la descarga» y «Marcado por error» | MNLU0000200 vuelve a «por bajar» y MNLU0000196 sigue descargado. Sale el aviso «Deshecho · …» |
| 7 | Va al Avance | El total dice «1 descargado · 29 pendientes» y la bahía 06, «1 descargado · 9 pendientes» |
| 8 | Va a Estadísticas y desplaza la página | 60 contenedores a bordo: Estadísticas describe el plano tal como llegó |

**Sobre el paso 1:** sin historial en el equipo, la app propone el puerto de salida que declara el archivo (`proposedPortOfCall`). La escala de llegada se elige en los parámetros, que explican «para la salida, la escala es PAMIT; para la llegada, GTSTC». Mi primera versión de la prueba esperaba GTSTC en el previo y falló con «Expected: 'GTSTC' Actual: 'PAMIT'». Era mi suposición, no un defecto: la corregí con la regla del código. Para la Expo queda mejor, porque «confirmar la escala» es justo ese cambio. Con PAMIT, la app dice «0 se descargan · 30 se cargan · 30 de paso»; con GTSTC, «30 se descargan · 0 se cargan · 30 de paso».

**Sobre el contenedor buscado:** MNLU0000200 se eligió a propósito. Su suma ISO es 934, y 934 entre 11 deja residuo 10, que se escribe 0: el mismo camino del residuo 10 que cubre la caja blanca.

**La cruz naranja** que se ve en la app es de `integration_test`: marca dónde toca la prueba. Para la sala viene bien.

**La pausa y la ventana:**

- `EXPO_PAUSA_MS` es la pausa entre pasos: 0 por omisión, para correr rápido; la Expo usa unos 1200.
- Sin `EXPO_VENTANA` queda la ventana del runner de Windows, sin tocar: su área es de 1266 × 682 puntos en cualquier pantalla.
- Con `--dart-define=EXPO_VENTANA=1366x768`, el área de la app queda en esos puntos lógicos, exactos.

### 3.2 La ventana: un defecto al redimensionar y cómo se evita

Mi primera versión cambiaba el tamaño de la ventana ya visible, como `integration_test/t99_ventana.dart`. Así **la app se dibuja corrida y aplastada**: empieza a media altura y con el texto comprimido.

- Lo comprobé en la pantalla misma (copiando lo que mostraba la pantalla) y no solo en la captura de la ventana (`build/expo/41-defecto-ventana-redimensionada-visible.png`).
- Es lo que T-99 ya había visto (10.97 de `SPRINT-3.md`).
- La prueba pasaba igual, porque toca por dentro de Flutter, pero así no se lee.

**El arreglo,** sin tocar `t99_ventana.dart` ni el runner:

- `expo_ventana.dart` cambia el tamaño al principio de `main()`, cuando la ventana del runner todavía está oculta (el runner la muestra con el primer cuadro). Así el primer cuadro ya sale del tamaño nuevo.
- Desde ese cambio, la app se dibuja bien en los tres tamaños (capturas 33 a 40).
- En la ventana del runner y a 1366 × 768, comparé un cuadro con lo que mostraba la pantalla: misma imagen, diferencia media de 0,0 por píxel. A 1536 × 794 coinciden salvo el borde de abajo, que en la pantalla tapa la barra de tareas.
- **En la Expo no hay que redimensionar ni maximizar la ventana de la app con el mouse mientras corre:** sería el mismo defecto.

### 3.3 Las corridas en Windows

La primera compilación de Windows, desde cero, tarda unos 5 minutos (296 s). Ocupa 11 GB en `build\windows`, casi todo el SDK de C++ de Firebase.

- **El primer intento llenó el disco C:** falló con «LNK1116 … código de error 112» y quedaron 207 MB. Borré mi compilación y Carlos liberó espacio; con 67 GB libres, compiló bien.
- **Esos 11 GB tienen que seguir en esta carpeta hasta el sábado:** con ellos, cada corrida recompila solo lo que cambió (19 a 32 s).

Todas pasaron, 8 de 8 y «All tests passed!»:

| Corrida | Área de la app (puntos) | Recorrido | Reloj, con la compilación |
|---|---|---|---|
| Sin pausa, ventana del runner (código final) | 1266 × 682 | 23,6 s | 49 s |
| `EXPO_PAUSA_MS=1200`, ventana del runner | 1266 × 682 | 51,6 s | 83 s |
| `EXPO_PAUSA_MS=1200`, `EXPO_VENTANA=1366x768` | 1366 × 768 | 51,7 s | 83 s |
| `EXPO_PAUSA_MS=1200`, `EXPO_VENTANA=1536x794` | 1536 × 794 | 50,1 s | 75 s |

Detalles de las corridas:

- **Por paso, con pausa, a 1536 × 794:**

  | Paso | Tiempo |
  |---|---|
  | 1 · abrir el plano | 9,8 s |
  | 2 · confirmar el buque y la escala | 6,6 s |
  | 3 · recorrer las bahías | 5,1 s |
  | 4 · buscar y resaltar | 6,7 s |
  | 5 · registrar dos descargas | 7,4 s |
  | 6 · deshacer una | 6,0 s |
  | 7 · el Avance | 2,9 s |
  | 8 · Estadísticas | 5,1 s |

- **1536 × 794** es el área de una ventana maximizada en una pantalla de 1920 × 1080 al 125 %, la de esta laptop.
  - Pedí primero 1536 × 864, la pantalla entera: Windows no dejó pasar de 844 y el pie de la app quedó detrás de la barra de tareas.
- **1366 × 768 en puntos** es exactamente lo que ve la app en una pantalla de 1366 × 768 al 100 %.
  - En esa pantalla, la ventana del runner (1280 × 720 píxeles, a 10 px del borde) dejaría unos 10 px de su pie bajo la barra de tareas. No lo vi en una pantalla real de 1366 × 768: la laptop está a 1920 × 1080.
- **El motor de pruebas sin ventana** (`-d flutter-tester`, 800 × 600 puntos) también pasa los 8 pasos, en 17,7 s. Es el respaldo si Windows no compila.
- **El emulador Android, el extra, no se hizo.**

## 4. Rojo → verde

```powershell
flutter test test/curso/expo_rojo_verde_test.dart --dart-define=EXPO_ROJO=true
flutter test test/curso/expo_rojo_verde_test.dart
```

Una prueba de ISO 6346 sobre CSQU305438: busca cuál de los diez dígitos acepta el validador y lo compara con el esperado.

- **Sin el interruptor** espera el 3 y pasa: 6185 entre 11 deja residuo 3, calculado aparte, como en la caja blanca.
- **Con `EXPO_ROJO=true`** la prueba se llama «… es 4» y falla así:

```text
00:01 +0 -1: ISO 6346: el dígito de control de CSQU305438 es 4 [E]
  Expected: <4>
    Actual: <3>
  ROJO A PROPÓSITO (EXPO_ROJO=true): la prueba esperaba el dígito 4 y el validador calcula 3 para CSQU305438. Sin el interruptor, vuelve a verde.
```

Nunca se edita un archivo en vivo. Sin el interruptor es una prueba más de la suite. Cambiar de interruptor recompila la prueba: la primera corrida tras el cambio tardó 11,8 s de reloj, y la siguiente, 6,1 s.

## 5. Firebase en dos niveles

**Nivel 1, en memoria:** las 3 pruebas de RF-032 de T-116 (`test/curso/funcional_sincronizacion_test.dart`), con `FakeFirebaseFirestore` inyectado en `FirestoreOperationSync` y `FirestoreRemoteMovementStore`:

- la oficina publica, el muelle se une y la descarga llega por la escucha;
- sin sesión, falla con `no_session`;
- el muelle no publica: falla con `not_office`.

Pasan las tres. El falso no evalúa las reglas de seguridad.

**Nivel 2, el emulador con las reglas:**

```powershell
powershell -File tool/expo_emulador.ps1
node tool/t80_reglas.mjs 8181 demo-expo
node tool/t113_reglas_abuso.mjs 8181 demo-expo
```

`tool/expo_emulador.ps1` es copia de `tool/t113_emulador.ps1` (que no cambia), con estos ajustes:

- la consola del emulador encendida en `http://127.0.0.1:4000`;
- Firestore en 8181;
- el proyecto `demo-expo`, que no existe en la nube: la CLI dice «Detected demo project ID» y no inicia sesión;
- su `firebase.json` en `%TEMP%\expo\emu`.

Las dos baterías cargan en el emulador las reglas de `docs/T80-firestore.rules.propuesta`, borran sus datos y prueban cada caso por la API REST, con tokens sin firmar.

**Resultados:**

| Lo corrido | Resultado |
|---|---|
| `t80_reglas.mjs` | **69 de 69**, en unos 5 s |
| `t113_reglas_abuso.mjs` | **25 de 25**, en unos 2 s |
| El emulador | «All emulators ready» en 32,6 s, ya sin descargar nada |
| La consola | descargada: `ui-v1.15.0` y su zip de 3,5 MB, junto al JAR de Firestore 1.22.0, en `%USERPROFILE%\.cache\firebase\emulators`. Desde ahora arranca sin internet |

**Qué muestra la consola** (Firestore → Requests) mientras corren:

- Una fila por cada evaluación de las reglas, con la hora, el método (CREATE, UPDATE, DELETE, GET, LIST) y la ruta.
- El ícono de cada fila dice cómo terminó: **✔ verde, permitida; ⊖ rojo, negada; ⚠ triángulo, la regla dio error al evaluarse**, y Firestore la niega igual.
- Un lote o una escritura con la hora del servidor se ve como varias evaluaciones (crear y actualizar). Por eso hay más filas que casos.
- Al tocar una fila se abre su detalle: las reglas a la izquierda y, a la derecha, `request.auth` (el token, con `aud: "demo-expo"`), el método, la ruta y el documento.
- Las escrituras de siembra van como administrador y no aparecen («Admin SDK requests … bypass Security Rules»).
- **La consola hay que abrirla antes de correr las baterías y no recargarla.** Al recargar, la lista vuelve vacía y solo se rellena con las peticiones que llegan después.

**Cómo se apaga:** Ctrl+C en la consola del emulador, que es como lo cierra la CLI de Firebase. Ese camino no lo probé: el emulador corría en segundo plano en mi consola y ahí no se puede pulsar Ctrl+C. Lo que sí probé, dos veces, es el respaldo:

```powershell
Get-NetTCPConnection -LocalPort 8181,4000,4400,4500,9150 -State Listen | Select-Object -ExpandProperty OwningProcess -Unique
Stop-Process -Id <los PID que salieron>
```

- Salen dos procesos: `node`, la CLI con la consola en 4000, 4400 y 4500, y `java`, Firestore en 8181 y 9150.
- Con los dos detenidos, ningún puerto queda escuchando.

## 6. Las cifras sobre la 3.2.0

- **Suite completa, en una sola corrida:** **1863 de 1863**, «All tests passed!», sin fallos ni omitidas, en 02:26 (`build/expo/13-suite-completa.log`). Son las 1841 de T-125 más las 22 de `test/curso/`. Se repitió dos veces más con el mismo resultado: con cobertura, en 02:56, y en la consola de la captura, en 02:10. `integration_test/` no entra en `flutter test`; sus corridas son las de la sección 3.
- **`flutter analyze`:**
  - Completo da **3 errores, los tres en `tool/t124_main.dart`.** Ese banco importa `build/t124/entradas/t124_entradas.dart`, un archivo que se genera fuera de Git y que esta carpeta nueva no tiene.
  - Para generarlo, `tool/t124_entradas.py` pide `T99_SINTETICO_977.edi`, y ese sintético se arma con `CORPUS_A01.edi` como plantilla. T-126 no usa el corpus, así que no lo generé.
  - Sin ese banco da **cero**, ya con el código final: `lib/`, `test/`, `integration_test/` y los otros 121 archivos de `tool/` son 124 entradas, «No issues found!» (`build/expo/55-analyze-final.log`).
  - En la carpeta del rediseño, con el archivo generado, T-125 tenía cero.
- **Cobertura** (`flutter test --coverage` y `python tool/cobertura_html.py`, que tarda 1,7 s):

| Archivo o conjunto | Líneas instrumentadas | Cubiertas | Porcentaje |
|---|---:|---:|---:|
| Total instrumentado de `lib/` | 18562 | 16853 | **90.79 %** |
| `lib/features/vessel/domain/services/iso6346_check_digit.dart` | 8 | 8 | **100.00 %** |
| `lib/features/vessel/data/repositories/firestore_operation_sync.dart` | 287 | 178 | **62.02 %** |
| `lib/features/vessel/presentation/widgets/container_search_delegate.dart` | 223 | 211 | **94.62 %** |

  El índice lista los 193 archivos Dart de `lib/`. Los 19 sin datos no entran en el denominador, como en T-116, y el reporte lo dice en su encabezado. Es cobertura de líneas, no de ramas. Las cifras son de toda la suite, no solo de las pruebas del curso. No se compara uno a uno con T-116 (89.28 %, buscador 88.89 %): la 3.2.0 tiene otro `lib/` (193 archivos contra 137) y 779 pruebas más.

## 7. El guion de la Expo

**Antes de la clase,** en `C:\Proyectos\baystream-expo`:

- `flutter pub get`;
- una corrida de cada comando, en este orden: deja compiladas la prueba de Windows y el rojo, y ya generado `coverage/html/index.html`;
- que `build\windows` siga ahí y que haya disco.

La suite completa y la cobertura tardan 2 a 3 minutos: en clase se muestra el reporte ya generado y la captura. Ningún comando de la tabla descarga nada (la consola del emulador ya está en caché), pero no se probó con la red cortada.

| # | Comando | Tarda | Qué se ve | Si falla |
|---|---|---|---|---|
| 1 | `flutter test test/curso --reporter expanded --concurrency=1` | ~11 s | Los 22 nombres, uno por línea, y «+22: All tests passed!». Sin `--concurrency=1` corren a la vez y el reporte no alcanza a mostrar todos los nombres, aunque los cuenta | Repetirlo; si sigue, mostrar `24-consola-curso-verde.png` |
| 2 | `flutter test test/curso/expo_rojo_verde_test.dart --dart-define=EXPO_ROJO=true` | ~12 s (recompila) | «… es 4 [E]», «Expected: <4> Actual: <3>» y el motivo «ROJO A PROPÓSITO» | Mostrar `25-consola-rojo.png` |
| 3 | `flutter test test/curso/expo_rojo_verde_test.dart` | ~6 s | La misma prueba, «… es 3», en verde | Mostrar `26-consola-verde.png` |
| 4 | `flutter test integration_test/expo_recorrido_test.dart -d windows --dart-define=EXPO_PAUSA_MS=1200`, y para llenar la pantalla `--dart-define=EXPO_VENTANA=1536x794` | ~75 a 85 s: ~20 a 30 de compilación y ~50 de recorrido | La app se abre sola y recorre los ocho pasos; la consola los anuncia; la cruz naranja marca dónde toca | No mover ni maximizar la ventana mientras corre. Si un paso falla, el mensaje dice cuál («La app no llegó en 20 s a: …»). Si no compila: `-d flutter-tester` corre los mismos pasos sin ventana, en ~18 s. Y las capturas 33 a 38 |
| 5 | `powershell -File tool/expo_emulador.ps1` | ~33 s hasta «All emulators ready» | La tabla de emuladores: Firestore en 127.0.0.1:8181 | Si dice que el puerto está ocupado: el respaldo de apagado de la sección 5 |
| 6 | Abrir `http://127.0.0.1:4000/firestore/requests` en el navegador | — | La consola, vacía | No recargarla después |
| 7 | `node tool/t80_reglas.mjs 8181 demo-expo` | ~5 s | «Resultado: 69 de 69», y en la consola las filas ✔ ⊖ ⚠ | Si dice que no conecta: el emulador no está listo |
| 8 | `node tool/t113_reglas_abuso.mjs 8181 demo-expo` | ~2 s | «Resultado: 25 de 25» | Igual que el 7 |
| 9 | Ctrl+C en la consola del emulador | — | La CLI dice que se detuvo | El respaldo de la sección 5 |
| 10 | Abrir `coverage\html\index.html` (generado antes) | — | El total, 90.79 %, y cada archivo con su página; ISO 6346 con sus 8 líneas en verde | Mostrar `17c-cobertura-indice-tres-archivos.png` |

## 8. Capturas

En `build/expo/` (fuera de Git), junto con los registros de cada corrida y los cuadros completos de cada ensayo (`app-runner/`, `app-1366x768-b/`, `app-1536x794/`):

| Captura | Qué muestra |
|---|---|
| `24-consola-curso-verde.png` | Las 22 pruebas del curso, una por línea, en verde |
| `25-consola-rojo.png` | La prueba en rojo, con «Expected: <4> Actual: <3>» y el motivo |
| `26-consola-verde.png` | La misma, en verde |
| `27-consola-suite-completa.png` | El final de la suite: «02:10 +1863: All tests passed!» |
| `28-consola-analyze.png` | `flutter analyze lib test integration_test`: «No issues found!» |
| `31-consola-t80-69.png` | La batería de reglas: «Resultado: 69 de 69» |
| `32-consola-t113-25.png` | La de abuso: «Resultado: 25 de 25» |
| `11-consola-emulador-peticiones.png` | La consola del emulador con las peticiones ✔ ⊖ ⚠, a 1600 px |
| `12-consola-emulador-detalle-negada.jpg` | El detalle de una petición negada: las reglas y `request.auth` (800 px, la del panel del navegador) |
| `17-cobertura-indice.png` | El encabezado del índice, con el total |
| `17b-cobertura-indice-completo.png` | El índice entero, los 193 archivos |
| `17c-cobertura-indice-tres-archivos.png` | El encabezado y las tres filas del curso, recortados del índice entero |
| `18-cobertura-iso6346.png`, `19-cobertura-sincronizacion.png`, `20-cobertura-buscador.png` | La página de cada archivo del curso, línea por línea |
| `33-app-escala-propuesta-pamit.png` | Paso 2: los parámetros con PAMIT propuesto, «0 se descargan · 30 se cargan · 30 de paso» |
| `34-app-busqueda-resaltada.png` | Paso 4: la bahía 06 con MNLU0000200 resaltado en naranja |
| `35-app-dos-descargas.png` | Paso 5: «Descarga 2 de 30», «Por bajar 28», «En vivo» y el aviso con «Deshacer» |
| `36-app-deshacer.png` | Paso 6: «Deshacer · MNLU0000200 — El movimiento no se borra: queda en la bitácora…» |
| `37-app-avance.png` | Paso 7: el Avance, total «1 descargado · 29 pendientes» y la bahía 06 con 1 y 9 |
| `38-app-estadisticas.png` | Paso 8: Estadísticas, por puerto, llenos y vacíos, carga especial, navieras |
| `39-app-1366x768-plano.png` | El plano a 1366 × 768 puntos |
| `40-app-ventana-runner-plano.png` | El plano en la ventana del runner, 1266 × 682 puntos |
| `41-defecto-ventana-redimensionada-visible.png` | El defecto de la sección 3.2, para no repetirlo |

Cómo se tomaron:

- **Las de la app (33 a 40):** se capturó la ventana real mientras corría la prueba con pausa, un cuadro cada 1,2 a 1,5 s. Para cada tamaño guardé también lo que mostraba la pantalla, y comparé con ella (sección 3.2).
- **Las de consola:** la ventana real (`conhost`), capturada mientras corría el comando.
- **Las del reporte:** Chrome sin ventana, con el reporte servido desde 127.0.0.1.

## 9. Límites declarados

- **El falso de Firestore no evalúa las reglas;** eso lo hacen las baterías en el emulador.
- **La cobertura es de líneas,** no de ramas.
- **El recorrido usa una sesión local:** prueba la app de un solo dispositivo, no la sincronización.
- **Estadísticas cuenta el plano tal como llegó** (60). Las descargas se ven en el Avance.
- **Las reglas que prueba el emulador** son `docs/T80-firestore.rules.propuesta`, la propuesta de T-80. No es el `firestore.rules` de la raíz, que es del proyecto de H5.
- **1366 × 768 se probó en puntos** dentro de la pantalla de 1920 × 1080 de la laptop, no en una pantalla real de esa resolución.
- **El emulador Android no se probó.**

## 10. Entrega

**Archivos (13 rutas):**

- modificados: `.gitignore`, `pubspec.yaml` y `pubspec.lock`;
- nuevos: los cuatro de `test/curso/`, los tres de `integration_test/` (`expo_recorrido_test.dart`, `expo_escala.dart` y `expo_ventana.dart`), `tool/cobertura_html.py`, `tool/expo_emulador.ps1` y este informe.

**Sí cambian `pubspec.yaml` y `pubspec.lock`.**

**Git, para Carlos, en `expo-pruebas`:**

```powershell
git add -- .gitignore
git add -- pubspec.yaml
git add -- pubspec.lock
git add -- test/curso/caja_blanca_iso6346_test.dart
git add -- test/curso/funcional_sincronizacion_test.dart
git add -- test/curso/interfaz_buscador_test.dart
git add -- test/curso/expo_rojo_verde_test.dart
git add -- integration_test/expo_recorrido_test.dart
git add -- integration_test/expo_escala.dart
git add -- integration_test/expo_ventana.dart
git add -- tool/cobertura_html.py
git add -- tool/expo_emulador.ps1
git add -- docs/T126-RESULTADOS.md
git commit -m "Sprint 4: T-126, la Expo de pruebas en la 3.2.0 (10.70): las 21 pruebas de T-116 sin adaptar, el recorrido de la app en Windows con integration_test, rojo a verde con EXPO_ROJO, el emulador de Firestore con su consola y fake_cloud_firestore 4.2.0"
git push -u origin expo-pruebas
```

**Tres líneas:**

1. Las 21 pruebas de T-116 corren sin cambios en la 3.2.0, más una de rojo → verde por interruptor: la suite da 1863 de 1863, `analyze` cero sin el banco de T-124 y la cobertura 90.79 %.
2. `integration_test/expo_recorrido_test.dart` maneja sola la app real en Windows, sin nube y con el plano sintético de T-100: abre, cambia la escala a GTSTC, recorre, busca, descarga, deshace, y mira el Avance y Estadísticas, en verde a 1266 × 682, 1366 × 768 y 1536 × 794.
3. El emulador de Firestore corre con su consola descargada (69/69 y 25/25, con las peticiones permitidas y negadas a la vista), y el guion trae los comandos, tiempos, qué se ve, qué hacer si falla y 24 capturas.

**Mensaje para Yov:**

> T-126 terminada en `expo-pruebas` (sobre `d41ad8c`); informe y guion en `docs/T126-RESULTADOS.md`, capturas en `build/expo/`.
>
> - **Las 21 de T-116:** byte por byte, sin adaptar. Con la de rojo → verde (`EXPO_ROJO`) son 22/22. `fake_cloud_firestore` 4.2.0 movió solo `equatable` a 2.1.0, con los mismos bloques del lock que `pruebas-curso`.
> - **Las cifras:** suite 1863/1863 en una corrida. `analyze`: 3 errores de `tool/t124_main.dart` (le falta un archivo generado que pide el corpus); sin ese banco, cero. Cobertura 90.79 %: ISO 100 %, sincronización 62.02 %, buscador 94.62 %.
> - **El recorrido en Windows:** la app real, sin nube, con `T100_LLEGADA.edi` (comprobado byte por byte contra `t100_sintetico.dart`). Son 8 pasos con `expect`; con `EXPO_PAUSA_MS=1200`, unos 50 s. Pasa en verde a 1266 × 682 (el runner), 1366 × 768 y 1536 × 794.
> - **Dos hallazgos:**
>   - el previo propone PAMIT, el puerto de salida, y la escala se cambia en los parámetros; para la Expo es el mejor momento;
>   - cambiar el tamaño de la ventana ya visible la dibuja corrida (10.97). Lo evité fijándolo antes del primer cuadro, con `expo_ventana.dart`; en la Expo no hay que tocar la ventana mientras corre.
> - **El emulador:** 69/69 y 25/25. La consola, en caché, muestra ✔ ⊖ ⚠ por petición; hay que abrirla antes de correr y no recargarla.
> - **Para Carlos:** la primera compilación de Windows llenó el disco (9,8 GB del SDK de Firebase); la carpeta necesita sus 11 GB hasta el sábado. Android, el extra, no se hizo.

**ALTO: Yov revisa.**
