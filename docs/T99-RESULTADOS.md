# T-99 · RNF segunda parte: rendimiento, escalabilidad, mantenibilidad y portabilidad

Timonel · 18-oct-2026 · rama `sprint-3` · base `d4253ff` (con T-108 y T-109) · **Fase A**.

> **Aviso para Carlos antes de compilar Android.** Con `integration_test` entre las dependencias
> de desarrollo, **el APK o el AAB release se compilan sin `--no-pub`**. Con `--no-pub`, Flutter no
> regenera `GeneratedPluginRegistrant.java` para release, el registrante que dejó `pub get`
> incluye el plugin de desarrollo y la compilación falla («package
> dev.flutter.plugins.integration_test does not exist»; flutter#162649). Pasó en el ensayo, y sin
> `--no-pub` compila. El comando de `docs/T47-RESULTADOS.md` (línea 36) lleva `--no-pub`: para el
> release de Play hay que quitarlo. Windows y la Web no cambian.

**Vigencia.** Solo está la sección «Fase A». **Ninguna cifra de este informe es una medición
ni lleva dictamen**: los ensayos sobre HEAD comprueban que cada instrumento corre, que su
salida está completa y que mide lo que dice T-63. Donde se citan números del ensayo es para
mostrar un defecto del instrumento o una decisión de método. Las tablas de la sección 8 son la
hoja de la Fase B, vacía.

## Fase A

### 1. Base, aislamiento y carril

- **Base:** `d4253ff`, sacada con `git archive` (solo lectura) a `%TEMP%\t99-fase-a-d4253ff`.
  Empecé sobre `25b3efd`; al llegar T-108 y T-109 rehíce las copias sobre el HEAD nuevo y
  regeneré los sintéticos con el lector de T-108.
- **No se tocó** `lib/`, el codec, las reglas, `lib/main.dart` ni los congelados.
- **El pase al árbol** se hizo de una vez, con luz verde de Carlos: 26 archivos, `pubspec.yaml`
  y `pubspec.lock`, con `flutter pub get` y `flutter analyze` en la carpeta real. Después,
  con el semáforo completo de Carlos (Codex fuera hasta el 19-oct), los ensayos con Flutter se
  corrieron uno a la vez. Los arreglos que salieron de los ensayos se hicieron en el árbol y se
  copiaron a `%TEMP%`.
- **Clientes:** namespace `t99`. En Android, la identidad `gt.cmartinez.baystream.t99` y el
  rótulo «BayStream T99», **solo en la copia de compilación**. Nunca las apps reales ni las de
  `demo17`. «PRUEBA T-105» no se tocó. **Sin Firebase y sin sesión.**
- **El Honor:** no se usó. Estaba conectado por USB (`adb devices` lo lista); no recibió
  ningún comando. Todo lo de Android fue con `-s emulator-5554`, y Flutter con `-d` explícito.
- **Git:** solo lectura (`git log`, `git show`, `git ls-tree`, `git archive`, `git diff
  --stat`).

### 2. `pubspec.yaml` y `pubspec.lock`

`integration_test` (sdk: flutter) en `dev_dependencies`, con su comentario, como pide 2.7. El
lock **solo agrega** siete paquetes y **no mueve ninguno** (47 líneas nuevas, 0 quitadas;
idéntico en la copia y en el árbol):

| Paquete | Versión | Origen | Por qué entra |
|---|---|---|---|
| `integration_test` | 0.0.0 | SDK de Flutter | directo, de desarrollo |
| `flutter_driver` | 0.0.0 | SDK de Flutter | lo usa `integration_test` |
| `fuchsia_remote_debug_protocol` | 0.0.0 | SDK de Flutter | lo usa `flutter_driver` |
| `platform` | 3.1.6 | pub.dev | lo usa `flutter_driver` |
| `process` | 5.0.6 | pub.dev | lo usa `flutter_driver` |
| `sync_http` | 0.3.1 | pub.dev | lo usa `webdriver` |
| `webdriver` | 3.2.0 | pub.dev | lo usa `flutter_driver` |

`integration_test` es un plugin con parte Android: no cambió ningún archivo nativo
versionado (`windows/flutter/generated_*` sigue igual). No entra en la app compilada.

### 3. Los instrumentos

| Archivo | RNF y submétrica | Qué hace |
|---|---|---|
| `integration_test/t99_rendimiento_test.dart` | 001 parseo, navegación, búsqueda, tablero y scroll; 007 capacidad | Arnés en modo *profile* sobre la interfaz real. Una repetición en frío, que se descarta, y cinco medidas por escenario |
| `integration_test/t99_driver.dart` | 001, 007 | Driver de `flutter drive`: escribe la respuesta en `%TEMP%` sin pisar otra |
| `integration_test/t99_ventana.dart` | 001 (1.4) | Maximiza la ventana del propio proceso en Windows y comprueba `IsZoomed`, con `dart:ffi` del SDK |
| `tool/t99_resumen.dart` | 001, 007 | Resume la respuesta: reglas de `TimelineSummary`, latencias con y sin traza y cotejo de relojes |
| `tool/t99_app.dart` | todos | La app del producto con almacenes inyectados y sin Firebase; `t99Publicar` acepta lo que propone la app |
| `tool/t99_main.dart` | 001 RAM, 003 | Banco `t99` para compilar en release desde la copia |
| `tool/t99_conductor.dart` | 001 RAM, 003 anchos | Recorre la interfaz real en release, sin `flutter_test`: el escenario de RAM de T-63 o los anchos con capturas |
| `tool/t99_plataforma*.dart` | 001, 003 | Dónde deja el banco sus registros: archivo en Windows y Android, servidor local en la Web |
| `tool/t99_servidor.dart` | 003 Web | Sirve el banco Web en `127.0.0.1` y guarda sus capturas en `%TEMP%` |
| `tool/t99_ram_windows.ps1` | 001 RAM | `WorkingSet64`: abre por `explorer.exe`, anota el PID, maximiza, registra entorno y escala, mide por paso y cierra por PID |
| `tool/t99_ram_honor.ps1` | 001 RAM | RSS de `dumpsys meminfo`, o `VmRSS` si la versión no lo trae; solo el paquete `.t99`; de los volcados solo guarda cifras |
| `tool/t99_ram_resumen.dart` | 001 RAM, 007 | Estable y pico por corrida y por archivo, en MB del SI |
| `tool/t99_sintetico.dart` | 001, 007 | Sintéticos de 5 000 y 10 000 desde la estructura de A01, solo a `%TEMP%`, verificados con el lector |
| `tool/t99_capas.dart` | 005 capas | Violaciones de las dos reglas de `AGENTS.md` |
| `tool/t99_documentacion.dart` | 005 documentación | Dos copias de `lib/` en `%TEMP%` y la clasificación de lo que señala `public_member_api_docs` |
| `tool/t99_codigo_compartido.dart` | 003 (3.1 b) | Líneas compartidas sobre Dart de `lib/` más el nativo a mano, con las plantillas de `flutter create` del SDK |
| `tool/t99_fuente.dart`, `tool/t99_comun.dart` | 003, 005 | Lectura ligera de fuentes; `%TEMP%`, SHA-256, CSV y percentiles |
| `tool/t99_modulos.ps1` | 007 módulos, retrospectivo | `git log` y `git show` (solo lectura): archivos existentes que tocó cada función |
| `tool/t99_modulo_prospectivo.ps1` | 007 módulos, prospectivo | Un módulo mínimo en una copia temporal, no en una rama, y la comparación con su base |
| `tool/t99_copia.ps1` | todos | Copia de compilación de un commit en `%TEMP%`, con la identidad `.t99` y las entradas como assets |
| `tool/t99_emulador.ps1` | 003 Android 8.0 | Imagen API 26, AVD `t99_api26`, arranque, APK y parada, sin activar nada de Windows |
| `test/t99_fuente_test.dart`, `test/t99_instrumentos_test.dart` | — | 22 autopruebas de los scripts, con textos sintéticos, nunca el corpus |

### 4. Cómo se corren

Los comandos de Flutter piden semáforo, uno a la vez. En la Fase B, `<sha>` es el commit de
cierre y `$r` una carpeta nueva de `%TEMP%`.

**La copia de compilación** (sin Flutter salvo el `pub get`, que crea los enlaces de plugins
que hacen falta para compilar):

```powershell
$c = 'C:\Users\Giova\OneDrive\Documentos\OneDrive\Desktop\Archivos .EDI\Anonimizados\files'
$r = "$env:TEMP\t99-b-<sha>"
dart tool/t99_sintetico.dart "$c\CORPUS_A01.edi" "$r\sinteticos" 5000 10000
./tool/t99_copia.ps1 -Destino "$r\copia" -Commit <sha> `
  -Entradas "$c\CORPUS_A01.edi,$c\CORPUS_A06.edi,$r\sinteticos\T99_SINTETICO_5000.edi,$r\sinteticos\T99_SINTETICO_10000.edi"
cd "$r\copia"; flutter pub get
```

La suite por defecto se corre en una copia **sin** la identidad `.t99`: la prueba de T-88
exige el rótulo `BayStream` del manifiesto, y la copia de compilación lo cambia a propósito.

**El arnés** (semáforo), una corrida por archivo:

```powershell
$env:T99_SALIDA = "$r\rendimiento"; $env:T99_NOMBRE = 'a01-windows'
flutter drive --profile --no-pub -d windows --driver integration_test/t99_driver.dart `
  --target integration_test/t99_rendimiento_test.dart `
  --dart-define=T99_ARCHIVO=t99_inputs/CORPUS_A01.edi --dart-define=T99_CONTENEDORES=977
dart tool/t99_resumen.dart "$r\rendimiento\a01-windows.json" "$r\rendimiento\a01-windows-resumen"
```

Con `CORPUS_A06.edi` y 717, `T99_SINTETICO_5000.edi` y 5000, y `T99_SINTETICO_10000.edi` y
10000, sale la curva de RNF-007. En el Honor, `-d <serie>`. Si la cuenta no es la esperada,
la prueba falla con «El lector dio otra cuenta: detente y avisa».

**La RAM** (semáforo para compilar; medir no es un comando de Flutter). Cada corrida es un
arranque nuevo; la primera de cada archivo se descarta:

```powershell
flutter build windows --release --no-pub -t tool/t99_main.dart --dart-define=T99_ESCENARIO=ram `
  --dart-define=T99_ARCHIVO=CORPUS_A01.edi "--dart-define=T99_PASOS=$r\ram\pasos.jsonl"
$s = './tool/t99_ram_windows.ps1'; $exe = "$r\copia\build\windows\x64\runner\Release\baystream.exe"
& $s -Accion abrir -Exe $exe -Salida "$r\ram\abrir-1.json"          # anota el PID
& $s -Accion entorno -AppPid <pid> -Salida "$r\ram\entorno-1.json"
& $s -Accion seguir -AppPid <pid> -Pasos "$r\ram\pasos.jsonl" -Salida "$r\ram\ram.csv" -Archivo A01 -Corrida 1
& $s -Accion cerrar -AppPid <pid>
dart tool/t99_ram_resumen.dart "$r\ram\ram.csv" "$r\ram\resumen"
```

En Android, el APK con las mismas definiciones, instalado en el emulador
(`./tool/t99_emulador.ps1 -Accion apk …`) o en el Honor cuando Carlos lo autorice, y
`./tool/t99_ram_honor.ps1 -Accion seguir -Serial <serie> -Salida "$r\ram\ram-android.csv"
-Archivo A01 -Corrida 1`, que lee los pasos del logcat del banco.

**Los anchos** (semáforo para compilar). El banco con `T99_ESCENARIO=anchos`; cada captura
deja su PNG y una línea en `anchos.jsonl`:

```powershell
# Windows, abierto maximizado con explorer.exe:
flutter build windows --release --no-pub -t tool/t99_main.dart --dart-define=T99_ESCENARIO=anchos `
  --dart-define=T99_ARCHIVO=CORPUS_A01.edi "--dart-define=T99_CAPTURAS=$r\anchos-windows" `
  "--dart-define=T99_PASOS=$r\anchos-windows\pasos.jsonl" --dart-define=T99_PAUSA_MS=1500
# Web, servida por el servidor de T-99:
flutter build web --release --no-pub -t tool/t99_main.dart --dart-define=T99_ESCENARIO=anchos `
  --dart-define=T99_ARCHIVO=CORPUS_A01.edi --dart-define=T99_CAPTURAS=web --dart-define=T99_PASOS=pasos.jsonl
dart tool/t99_servidor.dart "$r\copia\build\web" "$r\anchos-web" 8099
& 'C:\Program Files\Google\Chrome\Application\chrome.exe' --headless=new --user-data-dir="$r\chrome" `
  --window-size=1920,1080 http://127.0.0.1:8099/     # se cierra por PID al ver «fin»
```

Chrome tiene que dibujar: en una ventana minimizada o en un panel oculto, Flutter deja de
pintar y el conductor se queda esperando (pasó en el ensayo con el panel del navegador
integrado). Por eso el ensayo usó Chrome sin interfaz, con un perfil propio en `%TEMP%`.

**Mantenibilidad y portabilidad:**

```powershell
dart tool/t99_capas.dart <copia> "$r\capas"
dart tool/t99_codigo_compartido.dart <copia> C:\flutter "$r\codigo"
dart tool/t99_documentacion.dart preparar <copia> "$r\documentacion"
# semáforo, en con-docs y en sin-docs:  dart analyze --format=machine lib > analisis.txt
dart tool/t99_documentacion.dart resumir "$r\documentacion" "$r\documentacion-resumen"
./tool/t99_modulos.ps1 -Salida "$r\modulos" -Hasta <sha>
./tool/t99_modulo_prospectivo.ps1 -Base "$r\copia" -Destino "$r\modulo"
# semáforo, en el módulo:  flutter pub get; flutter analyze --no-pub
```

### 5. Lo que encontraron los ensayos en los instrumentos

Para esto sirve la Fase A. Cada punto se corrigió en el instrumento y se volvió a ensayar,
salvo los dos primeros, que son para decidir.

1. **Efecto observador de `traceAction` en el scroll (para decidir, sección 6.1).** Grabar la
   línea de tiempo vuelve lentos los cuadros de la interfaz cuando la lista es grande. En la
   pasada con traza, `Animator::BeginFrame` dura lo mismo que «Frame», así que es tiempo real
   del hilo de la interfaz, no un error de cuenta. Con 5 000 contenedores, el p90 de build del
   scroll de Lista da unos 48 ms con traza y unos 2 ms con `FrameTiming` del mismo arrastre.
   Invertí el orden de las dos pasadas en una corrida aparte y la diferencia siguió a la traza,
   no al orden. El raster no cambia. **Las latencias de un solo cuadro no lo sufren:** con y
   sin traza dan lo mismo en los cuatro archivos.
2. **La pantalla de esta laptop no es de 1920×1080 (para decidir, sección 6.2).** El entorno
   registra 2560×1600 físicos al 150 % (el panel interno, con `DpiValue` 0, es decir, la escala
   recomendada); maximizada, la ventana deja 1707×996 lógicos. La decisión 1.4 pide «una laptop
   de 1920×1080 con la escala que Windows recomienda en esa pantalla».
3. **El búfer de la línea de tiempo se llenaba.** Con todos los flujos (`all`), el tablero
   perdía su marca inicial y el scroll de Lista se quedaba con 8 eventos. Ahora se graban solo
   `Dart` y `Embedder`.
4. **La navegación esperaba a que todo quedara quieto**, con la animación del chip incluida. La
   ficha pide el primer cuadro con la rejilla nueva: ahora la marca final se pone ahí. Lo mismo
   en la búsqueda. El tablero sí espera a que todo esté pintado y quieto.
5. **El selector de bahías es perezoso y se desplaza al elegir.** El arnés y el conductor traen
   cada chip a la vista antes de tocarlo. En el ensayo, las 34 bahías de A01 tuvieron su chip.
6. **El scroll de Lista arrastraba un desplazable que no se mueve** (el `ListView` anidado). Ahora
   se toma el vertical con más recorrido.
7. **La ventana no se maximizaba:** el runner de Windows la muestra con el primer cuadro.
   El arnés espera a que haya una ventana visible del propio proceso y anota `IsZoomed`.
8. **El almacén temporal no se puede borrar** con las cajas de Hive abiertas: queda en `%TEMP%`
   y se anota su ruta.
9. **Para compilar hace falta `flutter pub get` en la copia** (los enlaces de
   `windows/flutter/ephemeral/.plugin_symlinks`); reutilizar el `package_config.json` solo
   alcanza para `analyze`, `test` y los scripts de Dart. El módulo prospectivo copia sin seguir
   esos enlaces (`robocopy /XJ`) y compara solo lo que forma el producto.
10. **El muestreador de RAM** leyó una línea a medio escribir del registro del conductor: ahora
    solo lee líneas completas, e ignora las anteriores al arranque del proceso medido.
11. **`dart analyze --format=machine`** escapa `\` y `|`; el lector de la documentación los
    desescapa (hay autoprueba con una línea real).
12. **Windows PowerShell 5.1:** `$PSScriptRoot` llega vacío en los valores por defecto de
    `param()`, una lista llega como «a,b» con `powershell -File`, y los acentos de un `.ps1`
    sin BOM salen mal. Los `.ps1` van con BOM y resuelven las dos cosas.
13. **Los sintéticos y T-108:** la verificación del generador ahora exige además cero avisos
    del lector. Los de 5 000 y 10 000 salen limpios y con el mismo SHA-256 antes y después de
    T-108.
14. **Las pistas de los desplazables horizontales** decían «otro» para casi todo. Ahora nombran
    la vista: las páginas de `TabBarView`, el selector, la rejilla, las acciones de la barra o
    el tipo de la vista.

### 6. Decisiones de método que hay que revisar

Ninguna cambia un umbral. Están en el código, citadas, y Yov puede corregirlas antes de la
Fase B.

1. **El scroll se dictamina con `FrameTiming`** (`watchPerformance`), que la documentación de
   `integration_test` da como el reemplazo de `traceAction` con `TimelineSummary`, y **las
   latencias con las dos pasadas**, que coinciden. La traza del scroll queda como evidencia,
   con la nota del efecto observador. Recomiendo esta lectura; la alternativa es dictaminar el
   scroll con la traza y declarar que la medición lo altera.
2. **La pantalla para la Fase B.** Tres opciones: (a) Carlos pone la resolución de Windows en
   1920×1080 durante las corridas de Windows y se anota (es un ajuste del sistema: lo hace
   Carlos); (b) se mide así, a 2560×1600 al 150 % con 1707×996 lógicos, y se declara; (c) otra
   laptop de 1920×1080. Recomiendo (a), porque es la condición de 1.4.
3. **`TimelineSummary` no se importa.** Vive en `flutter_driver`, que llega con
   `integration_test` pero no es dependencia directa; importarla exige declararla, porque
   `depend_on_referenced_packages` está en `lints/core.yaml`, y no se usa `// ignore`.
   `tool/t99_resumen.dart` aplica sus mismas reglas, citadas de `flutter_driver` 3.38.9
   (eventos «Frame» y «GPURasterizer::Draw», `findPercentile` sin interpolar y presupuesto de
   16 ms). Si se quiere la clase literal, Carlos tendría que autorizar `flutter_driver` del SDK
   como dependencia de desarrollo; no agrega paquetes al lock.
4. **El arnés no corre en la Web:** `traceAction` necesita el VM service, que la Web no expone.
   RNF-001 se mide en Windows y en el Honor (1.1 y 1.4).
5. **Latencias:** de la marca puesta justo antes del toque o del carácter al fin del raster del
   cuadro que construyó el estado final. Las dos pasadas usan el mismo criterio; el cotejo de
   relojes (`Animator::BeginFrame` contra el `buildStart` del motor) dio de 0 a 1 µs. El
   tablero incluye la transición de pestañas de `TabBarView` (unos 300 ms por diseño), porque
   el usuario no ve los gráficos antes.
6. **Scroll:** p90 de build y p90 de raster por separado; cumplir pide los dos ≤ 16.67 ms.
7. **Búsqueda:** cada repetición agrega un carácter del mismo ID (1 a 6); la de un carácter se
   descarta.
8. **RAM, la carga.** El conductor publica el archivo desde un asset de la copia
   (`T99_CARGA=asset`) o toca «Cargar archivo BAPLIE» y espera a que una persona lo elija
   (`selector`). En Windows el diálogo nativo se carga **dentro** del proceso y suma memoria;
   **recomiendo `selector` en Windows** para medir el camino real. En Android el selector es
   otro proceso.
9. **RAM y Firebase.** El banco no inicializa Firebase; el producto sí lo hace al arrancar
   (`lib/main.dart`). La RAM del banco puede quedar por debajo de la del binario real. Hay que
   decidir: medir así y declararlo, o agregar al banco Firebase inicializado y sin sesión,
   como `T98_FIREBASE`.
10. **Estable y pico:** estable es la mediana de las cinco lecturas al volver a Lista; pico, la
    mayor tras los pasos del escenario. La lectura `inicio`, antes de cargar, queda como
    referencia y no entra.
11. **Documentación (5.1 a):** el denominador son clases, enums, mixins y extensiones, más los
    métodos; sin campos, *getters*, *setters*, constructores ni constantes de enum. Las
    funciones de nivel superior se informan aparte, como lectura alternativa, porque el ERS no
    las nombra.
12. **Código compartido:** un archivo que no se usa en los tres clientes no se comparte; eso
    incluye los `*_io.dart`, que usan Windows y Android. Leído al pie de la letra («compila en
    una sola») esos casos contarían como compartidos; la columna `clientes` del CSV permite las
    dos cuentas. Una línea de la plantilla con un marcador `{{…}}` cuenta como generada aunque
    su valor cambie. `web/vendor` (el SDK de Firebase copiado) y `web/fonts` no son código
    propio.
13. **Capas:** `flutter_riverpod` cuenta como Flutter en el dominio; se cuentan `import` y
    `export`; `lib/core/` y la raíz de `lib/` no están en ninguna de las dos reglas.
14. **Módulos:** el proyecto no tiene carpeta por función; «modificar existentes» es tocar un
    archivo que ya estaba antes del primer commit de la función. Los commits salen del mensaje,
    del informe `docs/<T##>-RESULTADOS.md` (así aparece `ac72849`, de T-85, que no la nombra) o
    de `-Indicados`.
15. **Anchos:** el conductor impone el tamaño lógico dentro de la app (`MediaQuery` y
    `FittedBox`), así se prueban los seis anchos en Windows y en la Web aunque la pantalla no
    llegue a 2560×1440. «real» es la ventana maximizada (en Windows, 1707×996 en esta laptop;
    en Chrome sin interfaz, 1898×982). Las alturas (800, 960, 1200, 800, 1440) son mías: el
    criterio es el ancho. Los desbordes de `RenderFlex` solo se informan en debug; en release
    los ve la persona en la captura.
16. **Sintéticos:** geometría de portacontenedores grande, 24 bahías de 40 con sus impares de
    20, filas 01–22, bodega 02–20 y cubierta 82–98: unos 20 000 TEU, que es lo que el ERS llama
    ULCS. El plano tiene 72 bahías. Los números son `SNTU` con su dígito ISO 6346 y el IMO es
    sintético con su dígito.

### 7. Ensayos sobre `d4253ff`

Lo que dice la última columna comprueba el instrumento; no es una medición.

| Instrumento | Dónde | Qué se comprobó |
|---|---|---|
| `t99_sintetico.dart` | Windows, Dart | 5 000 y 10 000 leídos con la cuenta exacta, posiciones únicas, la geometría propuesta cubre todo y **cero avisos del lector**. SHA-256 `1af59932…` y `0af17179…`, iguales antes y después de T-108 |
| Arnés `t99_rendimiento_test.dart` | Windows 11, *profile*, `flutter drive` | A01, A06, 5 000 y 10 000: «All tests passed», cuenta exacta (977, 717, 5 000 y 10 000), ventana maximizada (`IsZoomed`), seis escenarios con la repetición en frío y cinco medidas, sin datos vacíos. Relojes: 0 a 1 µs |
| `t99_resumen.dart` | Windows, Dart | Las cuatro respuestas resumidas en CSV y MD, con las dos fuentes de latencia y de scroll |
| `t99_ram_windows.ps1` y conductor `ram` | Windows 11, banco release | Dos corridas con A01: abre por `explorer.exe` (padre `explorer`), maximiza, registra el entorno, 35 lecturas por corrida en los seis pasos más `inicio`, cierra por PID. Las 34 bahías tuvieron su chip |
| `t99_ram_honor.ps1` y conductor `ram` | Emulador API 26, APK release `.t99` | Sigue los pasos del logcat del banco; 30 lecturas en los seis pasos; RSS por `/proc VmRSS`, porque Android 8 no trae «TOTAL RSS» en `dumpsys`. La lectura `inicio` no quedó: el banco la escribe antes de que arranque el muestreador; es solo referencia |
| `t99_ram_resumen.dart` | Windows, Dart | Estable y pico por corrida, con la primera descartada; sin pasos faltantes |
| Conductor `anchos` | Windows 11, banco release | 24 capturas (6 tamaños × 4 pantallas) con su línea en `anchos.jsonl`; «real» = 1707×996 lógicos |
| Conductor `anchos` y `t99_servidor.dart` | Chrome 155 sin interfaz, perfil en `%TEMP%` | 24 capturas con sus metadatos; «real» = 1898×982. En el panel oculto del navegador integrado no avanzaba (sección 4) |
| `t99_emulador.ps1` | Emulador | Imagen `android-26;google_apis;x86_64` rev. 16 con el `sdkmanager` instalado, sin licencias nuevas ni nada de Windows (WHPX ya estaba); ocupa 3.4 GB. AVD `t99_api26`: **Android 8.0.0, API 26**. El APK release (62.6 MB) se instaló como `gt.cmartinez.baystream.t99` y **abrió A01 con el selector real del sistema**: 977 contenedores, 34 bahías, plano en pantalla |
| `t99_capas.dart` | Windows, Dart | Los 136 archivos de `lib/` por capa, con cada importación y su línea |
| `t99_codigo_compartido.dart` | Windows, Dart | 136 archivos Dart clasificados por cliente y 26 nativos cotejados con su plantilla del SDK |
| `t99_documentacion.dart` | Windows, `dart analyze` | 1 862 señales clasificadas, ninguna sin clase, ninguna fuera del denominador. Revisé a mano dos por clase contra la fuente: todas bien |
| `t99_modulos.ps1` | git de lectura | T-85 (`ac72849`, hallado por su informe), T-95, T-96 y T-73, con sus commits de código; descarta los de solo documentos |
| `t99_modulo_prospectivo.ps1` | Windows | Dos archivos nuevos en `lib/features/notas/` y uno existente modificado (el enganche en `vessel_overview_page.dart`); la copia compila (`flutter analyze` en 0) |
| `t99_copia.ps1` | Windows | Copia de `d4253ff` con la identidad `.t99`, las cuatro entradas y los instrumentos del árbol |
| Suite y análisis | árbol | `flutter analyze` 0, sin `// ignore`; suite **1016/1016** (994 + 22) |

**Lo que el ensayo ya deja ver, sin cifras ni dictamen** (para planear la Fase B):
- la presentación importa datos en once lugares (sobre todo los providers, que arman las
  implementaciones), así que la regla 2 de capas no da cero en HEAD;
- volver a Lista es el paso más pesado del escenario de RAM, y el tablero tarda más cuanto más
  grande es el archivo: la Lista construye todas sus tarjetas a la vez;
- en el emulador, la pastilla de zoom tapa parte de la cabecera de la rejilla («BAY 4…»,
  «0 conte…»), y a 360×800 hay un texto de la cabecera del plano que no cabe;
- 10.85 pide declarar en RNF-003 el desborde vertical de 0.23 dp de dos gráficos a 1280 dp.

Nada de esto se corrige en T-99 (fuera de alcance): va a Yov.

**Dónde quedó cada cosa (todo en `%TEMP%`, nada en el repositorio):** las copias y salidas en
`%TEMP%\t99-fase-a-d4253ff\`; los almacenes temporales del arnés en `%TEMP%\t99_almacen_*`; el
banco de Windows, abierto con `explorer.exe`, guardó su perfil y su viaje en el almacén real con
el namespace `t99` (`%LOCALAPPDATA%\BayStream\vessel_store`), sin tocar el de `baystream` ni los
de otras tareas; el del emulador, en su carpeta privada.

### 8. Hoja de la Fase B

Las tablas que pide la ficha, vacías. Se llenan sobre los binarios de cierre.

**RNF-001 · Rendimiento**

| Submétrica | Umbral | Instrumento | Clientes | Medición | Dictamen |
|---|---|---|---|---|---|
| Parseo de 5 000 | < 5 s | arnés, `t99_parseo` | Windows, Honor | Pendiente | Pendiente |
| Navegación entre bahías | < 100 ms | arnés, dos pasadas | Windows, Honor | Pendiente | Pendiente |
| Búsqueda por carácter | < 200 ms | arnés, dos pasadas | Windows, Honor | Pendiente | Pendiente |
| Scroll de Lista y Estadísticas | p90 ≤ 16.67 ms, build y raster | arnés, `FrameTiming` (6.1) | Windows, Honor | Pendiente | Pendiente |
| Tablero | < 1 s | arnés, dos pasadas | Windows, Honor | Pendiente | Pendiente |
| RAM, estable y pico | < 200 MB (SI) | banco `ram` y muestreadores | Windows, Honor | Pendiente | Pendiente |

**RNF-007 · Escalabilidad**

| Submétrica | Umbral | Instrumento | Medición | Dictamen |
|---|---|---|---|---|
| 500 sin degradación (A06, 717) | umbrales de RNF-001 (7.1 a) | arnés y RAM | Pendiente | Pendiente |
| 10 000 aceptable | umbrales de RNF-001 | arnés y RAM con 5 000 y 10 000 | Pendiente | Pendiente |
| Curva tiempo/tamaño y memoria/tamaño | — | A06, A01, 5 000 y 10 000 | Pendiente | Informativa |
| Módulos, retrospectivo | 0 archivos existentes (7.4 a) | `t99_modulos.ps1` | Pendiente | Pendiente |
| Módulos, prospectivo | 0 archivos existentes | `t99_modulo_prospectivo.ps1` | Pendiente | Pendiente |

**RNF-005 · Mantenibilidad**

| Submétrica | Umbral | Instrumento | Medición | Dictamen |
|---|---|---|---|---|
| Documentación (5.1 a) | ≥ 80 % | `t99_documentacion.dart` | Pendiente | Pendiente |
| Análisis estático | 0 errores y 0 advertencias | `flutter analyze` sobre el cierre | Pendiente | Pendiente |
| Capas | 0 violaciones | `t99_capas.dart` | Pendiente | Pendiente |
| Providers (5.3 b) | solo se reconstruye la rejilla | DevTools, sección 9 | Pendiente | Pendiente |

**RNF-003 · Portabilidad**

| Submétrica | Umbral | Instrumento | Medición | Dictamen |
|---|---|---|---|---|
| Windows 11 | funciona | banco release | Pendiente | Pendiente |
| Windows 10 | — | — | **No probado (10.83)** | No se da por cumplido |
| Android 8.0 | funciona | emulador API 26, APK release, recorrido de RNF-002 | Pendiente | Pendiente |
| Web | funciona | banco Web | Pendiente | Pendiente |
| Código compartido (3.1 b) | ≥ 95 % | `t99_codigo_compartido.dart` | Pendiente | Pendiente |
| Anchos 360, 600, 840, 1200, 2560×1440 y 1920×1080 | 3.3 (a) | conductor `anchos`, Windows y Web | Pendiente | Pendiente |
| Entrada | mouse, teclado y toque | sección 9 | Pendiente | Pendiente |

### 9. Procedimientos escritos para la Fase B

**Reconstrucciones con DevTools (5.3 b).** DevTools agregó en la 2.36.0 el ajuste «Track widget
build counts» y la herramienta «Rebuild Stats», en la página de rendimiento (notas de la
versión 2.36.0). La documentación no dice en qué modo funciona; se apoya en la instrumentación
de creación de widgets, que es de debug. El procedimiento usa debug porque cuenta qué se
reconstruye, no cuánto tarda. Con DevTools 2.51.1 (el de Flutter 3.38.9):

1. En la copia del cierre, `flutter run -d windows --debug -t tool/t99_main.dart` (semáforo).
2. Abrir DevTools desde la URL que imprime `flutter run`, en el navegador, con la ventana
   visible. Cargar A01 a mano y abrir Bay Plan.
3. Activar «Track widget build counts» y limpiar los contadores.
4. Tocar el chip de la bahía siguiente una vez y esperar a que no haya cuadros.
5. Anotar en «Rebuild Stats» qué widgets se reconstruyeron y cuántas veces. Cumple si solo se
   reconstruye la rejilla y su selector (`BayPlanView` y lo que cuelga de ella), no
   `ContainersListView` ni `VoyageStatsView`.
6. Repetir con cinco bahías y guardar una captura de cada una en `%TEMP%`.

Si el contador no aparece, se declara y se usa la opción de T-63 que Yov elija. Nota:
`TabBarView` solo construye la pestaña visible, así que Lista y Estadísticas no están montadas
mientras se ve Bay Plan. Que no aparezcan es correcto, pero no prueba granularidad; conviene
repetirlo con la búsqueda abierta sobre la Lista.

**Entrada (RNF-003).** El recorrido de RNF-002 (cargar A01, ver una bahía, encontrar un ID,
identificar un refrigerado y leer una alerta) con mouse y teclado en Windows, con el banco sin
escenario abierto por `explorer.exe`. Cada tarea se anota como completada o no, sin tiempos.
Con toque, el mismo recorrido en el Honor y en el emulador API 26.

### 10. Qué queda para la Fase B

1. Las decisiones de la sección 6 que Yov quiera cambiar, sobre todo la 1 (scroll con
   `FrameTiming`), la 2 (la pantalla de 1920×1080), la 8 (`selector` en Windows) y la 9
   (Firebase en el banco).
2. La copia limpia del commit de cierre con `tool/t99_copia.ps1`, los sintéticos regenerados
   con sus SHA y `flutter pub get` en la copia.
3. El arnés en Windows y en el Honor con los cuatro archivos y la curva de RNF-007.
4. La RAM con el escenario fijo: una corrida en frío y cinco medidas por archivo, en Windows y
   en el Honor, con su entorno y su escala.
5. Documentación, capas, `flutter analyze`, código compartido y módulos sobre el cierre.
6. Las reconstrucciones con DevTools y la entrada con mouse, teclado y toque.
7. Los anchos en Windows y en la Web, con dictamen por captura; Android 8.0 en el emulador con
   el recorrido completo de RNF-002.
8. Windows 10: no probado (10.83).
9. **El Honor:** el arnés, la RAM y el toque, cuando Carlos lo permita, en 1.0 al terminar y con
   volcados reducidos a cifras.
10. La aceptación de Codex: una fila de cada RNF por su cuenta.

### 11. Archivos

Nuevos: los 26 instrumentos y autopruebas de la sección 3 y este informe. Modificados:
`pubspec.yaml` (+4 líneas) y `pubspec.lock` (+47 líneas, solo los siete paquetes de la
sección 2). No se tocó `lib/`, `lib/main.dart`, el codec, las reglas, los congelados,
`.claude/settings.local.json` ni los documentos rectores. Los `.docx` y el `.pdf` modificados de
`docs/` que aparecen en el árbol no son de esta tarea.

El emulador queda apagado; su imagen y el AVD `t99_api26` quedan instalados para la Fase B. El
Honor no recibió ningún comando.

### 12. Git para Carlos

Versiona la Fase A; **no cierra T-99**. Cambian `pubspec.yaml` y `pubspec.lock` (sección 2).
Ninguna ruta está ignorada, así que no hace falta `-f`.

```powershell
git add -- pubspec.yaml
git add -- pubspec.lock
git add -- integration_test/t99_driver.dart
git add -- integration_test/t99_rendimiento_test.dart
git add -- integration_test/t99_ventana.dart
git add -- test/t99_fuente_test.dart
git add -- test/t99_instrumentos_test.dart
git add -- tool/t99_app.dart
git add -- tool/t99_capas.dart
git add -- tool/t99_codigo_compartido.dart
git add -- tool/t99_comun.dart
git add -- tool/t99_conductor.dart
git add -- tool/t99_copia.ps1
git add -- tool/t99_documentacion.dart
git add -- tool/t99_emulador.ps1
git add -- tool/t99_fuente.dart
git add -- tool/t99_main.dart
git add -- tool/t99_modulo_prospectivo.ps1
git add -- tool/t99_modulos.ps1
git add -- tool/t99_plataforma.dart
git add -- tool/t99_plataforma_io.dart
git add -- tool/t99_plataforma_web.dart
git add -- tool/t99_ram_honor.ps1
git add -- tool/t99_ram_resumen.dart
git add -- tool/t99_ram_windows.ps1
git add -- tool/t99_resumen.dart
git add -- tool/t99_servidor.dart
git add -- tool/t99_sintetico.dart
git add -- docs/T99-RESULTADOS.md
git commit -m "Sprint 3: T-99 fase A, instrumentos de RNF-001, 007, 005 y 003 con integration_test"
git push
```

### 13. Mensaje para Yov

T-99 Fase A, sin commit: 26 instrumentos en integration_test/, tool/ y test/, más docs/T99-RESULTADOS.md; analyze 0 y suite 1016/1016 (994 + 22).
integration_test solo agrega 7 paquetes al lock (3 del SDK, platform 3.1.6, process 5.0.6, sync_http 0.3.1, webdriver 3.2.0) y no mueve ninguno.
Aviso: con integration_test, el APK/AAB release se compila sin --no-pub; con --no-pub falla (flutter#162649). El comando de T-47 lo lleva.
Ensayado sobre d4253ff: arnés en Windows con A01, A06, 5 000 y 10 000 (cuenta exacta, sin avisos de T-108); RAM en Windows y en el emulador; anchos en Windows y Web; documentación, capas, código compartido y módulos.
Emulador API 26 (Android 8.0.0) instalado: el APK release .t99 abrió A01 con el selector real. El Honor, sin tocar.
Para decidir: traceAction infla el build del scroll con listas grandes (2 → 48 ms con 5 000); las latencias no cambian. Propongo dictaminar el scroll con FrameTiming.
Para decidir también: la laptop es 2560×1600 al 150 %, no 1920×1080 (1.4); y el banco no inicializa Firebase, que el producto sí.
Nada son mediciones; la Fase B y el Honor quedan pendientes.
