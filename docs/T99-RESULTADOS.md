# T-99 · RNF segunda parte: rendimiento, escalabilidad, mantenibilidad y portabilidad

Timonel · rama `sprint-3` · **Fase A** el 18-oct-2026 sobre `d4253ff` (con T-108 y T-109) · **Fase B**
desde el 20-oct-2026 sobre `sprint3-cierre-2` (`33404a5`), en curso.

> **Aviso para Carlos antes de compilar Android.** Con `integration_test` entre las dependencias
> de desarrollo, **el APK o el AAB release se compilan sin `--no-pub`**. Con `--no-pub`, Flutter no
> regenera `GeneratedPluginRegistrant.java` para release, el registrante que dejó `pub get`
> incluye el plugin de desarrollo y la compilación falla («package
> dev.flutter.plugins.integration_test does not exist»; flutter#162649). Pasó en el ensayo, y sin
> `--no-pub` compila. El comando de `docs/T47-RESULTADOS.md` (línea 36) lleva `--no-pub`: para el
> release de Play hay que quitarlo. Windows y la Web no cambian.

**Vigencia.** La sección «Fase B» trae las mediciones sobre el cierre `33404a5`, con su
dictamen; B.10 trae las cuatro tablas y lo que quedó sin medir. La sección «Fase A» queda como estaba: **sus
cifras no son mediciones ni llevan dictamen**, porque los ensayos sobre HEAD solo comprobaban
que cada instrumento corre, que su salida está completa y que mide lo que dice T-63. Sus tablas
de la sección 8 son la hoja vacía que la Fase B llena en B.10.

## Fase B

Timonel · 20-oct-2026 · decisiones 10.86, 10.94, 10.95 y 10.96.

### B.1 Base y condiciones

- **Cierre:** etiqueta `sprint3-cierre-2` → commit `33404a5804be4fad85aab80dd923a7ae9e878ee9`
  (objeto de la etiqueta `f631efa8…`). `git log --oneline --decorate -3` la muestra en HEAD.
- **Copia limpia:** `%TEMP%\t99-fase-b-33404a5\copia2`, sacada con `git archive` sin
  conversión de finales de línea y **verificada contra el árbol de la etiqueta**: los 510
  archivos tienen el mismo hash de blob que `git ls-tree -r 33404a5` (0 distintos, 0
  sobrantes). Después, solo en la copia, la identidad Android `.t99`, las cuatro entradas como
  assets y `flutter pub get`.
- **Instrumentos de la copia:** los de la etiqueta, salvo cuatro archivos de T-99 que cambié en
  la Fase B y puse en la copia después de verificarla: `integration_test/t99_rendimiento_test.dart`
  (`6aaa03bf`; desde las 16:21, `2261a765`, con el rótulo de B.2 corregido), `integration_test/t99_ventana.dart` (`c1d09528`), `tool/t99_main.dart`
  (`5b906cb8`) y `tool/t99_copia.ps1` (`b428f613`). Van en mi bloque de git. **El producto es el
  del cierre:** a las 15:2x volví a cotejar `lib/`, `pubspec.*`, `windows/`, `web/` y
  `android/app/src` de la copia con `git ls-tree -r 33404a5`: 206 archivos, los 137 de `lib/`
  iguales; solo difieren el manifiesto Android (la identidad `.t99`) y `pubspec.yaml` (los
  assets de las entradas), que pone el script.
- **Entradas:** A01 (`3d793f80…`), A06 (`84b8c708…`) y los sintéticos de 5 000 (`1af59932…`) y
  10 000 (`0af17179…`), regenerados con el lector del cierre: cuenta exacta y cero avisos.
- **Pantalla:** Carlos la puso en **1920×1080 con la escala recomendada de 125 %** (10.86).
- **Servidor de T-112:** el `dart.exe` que servía `tool/t99_servidor.dart` desde las 13:03:25
  (PID 19352) se cerró a las 13:49:51, antes de medir.
- **Lo de Codex que quedó abierto por la tarde:** a las 16:20, al recibir la máquina, estaban
  abiertos la app de T-98 (PID 3940, binario de `%TEMP%\t98-b-33404a5-20oct`, abierta a las
  16:17:50; en reposo, 16 ms de CPU en 5 s y 125 MB) y su servidor Web (PID 30132,
  `python -m http.server 5898` en 127.0.0.1, desde las 16:03:41). Al principio no los toqué
  porque no eran míos. **Carlos pidió cerrarlos:** la app, a las 16:35:32, con
  `CloseMainWindow` (salió sola, sin forzarla; sus datos quedan en su namespace t98); el
  servidor, a las 16:35:35. Después no quedó ninguna otra BayStream ni nada escuchando en el
  5898. **Lo que corrió con la app T-98 abierta:** el arnés con 5 000 de las 16:24 a las 16:29.
  Se repitió con la máquina limpia; la corrida queda aparte como comparación
  (`con-t98-abierta-*`) y no da ninguna cifra. El `analyze` de las 16:21 no mide tiempos.
- **La limpieza de temporales se llevó dos entradas:** a las 15:37 (en la ventana de Codex)
  desaparecieron `CORPUS_A01.edi` y `CORPUS_A06.edi` de `copia2\t99_inputs`, las dos con la
  fecha vieja del corpus; los sintéticos, de hoy, siguieron ahí. El arnés con A01 de las 16:29
  falló al abrir el asset («Unable to load asset») y no midió nada. A las 16:36 las repuse desde
  la carpeta del corpus con la fecha de hoy, y su SHA-256 coincide con el manifiesto
  (`3d793f80…` y `84b8c708…`). La copia tiene los 510 archivos de la etiqueta. Lo más probable
  es que fuera el Sensor de almacenamiento de Windows; no lo comprobé.
- **Firebase para la RAM del producto:** Carlos aprobó (20-oct) inicializarlo como
  `lib/main.dart`, en una app de Firebase aparte llamada «t99», sin sesión y sin leer ni escribir
  datos (`T99_FIREBASE=true`). El almacén de Windows va en `%TEMP%` (10.88).

### B.2 Hallazgo del instrumento: el arnés se dibuja corrido al cambiarle el tamaño

Carlos lo vio a las 14:0x: con la pantalla a 1920×1080 y 125 %, la ventana del arnés
(`integration_test`, modo *profile*) se dibuja con la mitad de arriba en negro y el contenido
corrido, aplastado y cortado a la derecha («BayStream» y «CUBIERTA» cortados).
- Pasa **maximizada** (1938×1038 con bordes, DPI 120) y también **fija a 1920×1080 sin
  maximizar** (cliente 1902×1033; Flutter ve 1522×826 lógicos a 1.25). Las capturas están en
  `%TEMP%\t99-fase-b-33404a5\comprobacion\` (`ventana-1.png`, `ventana-2.png` y
  `ventana-fija.png`).
- **En el producto no se vio:** el binario release de RAM, abierto con `explorer.exe` y
  maximizado después de abrirlo (también cambia de tamaño), se dibuja bien en la misma pantalla
  (`ram\producto-maximizado.png`, la pantalla de inicio), y en las corridas de RAM no se vio
  nada raro. Por eso lo anoto como **hallazgo del instrumento**, no del producto. La causa
  dentro del arnés no la investigué (10.73). En el código del SDK, la vista del arnés
  (`IntegrationTestWidgetsFlutterBinding`, que extiende `LiveTestWidgetsFlutterBinding`)
  encaja un tamaño lógico en la ventana con `BoxFit.contain` (`TestViewConfiguration`): con
  eso se explicarían la franja negra y el contenido escalado, pero no lo comprobé.
- **Se reabrió y siguió igual** (lo pidió Carlos): cerrado por PID y abierto otra vez con la
  pantalla ya en 1920×1080 y 125 %, maximizado y fijo salió igual de mal.
- **Con qué ventana se mide el arnés en Windows** (10.86 y 10.96): la que abre el runner, sin
  cambiarle el tamaño (`--dart-define=T99_MAXIMIZAR=false`). Se dibuja bien
  (`comprobacion\ventana-sin-cambio.png`, a las 14:36). Exterior de 1600×900 píxeles
  (1280×720 lógicos a 1.25); **el área de Flutter es de 1582×853 físicos, 1266×682 lógicos**.
  Es una desviación declarada: en esa ventana caben menos bahías y menos tarjetas que en
  1920×1080. Lo que el arnés anota de cada ventana (`entorno` del JSON):

| Comprobación | Vista al abrir | Lo que se pidió | Vista medida (físicos) | Lógicos a 1.25 | ¿Se dibuja bien? |
|---|---|---|---|---|---|
| `comprobacion-a01` (13:5x) | 1582×853 | maximizar | 1920×991 | 1536×793 | No (`ventana-1.png`, `ventana-2.png`) |
| `comprobacion-fija` (14:06) | 1582×853 | 1920×1080 sin maximizar | 1902×1033 | 1522×826 | No (`ventana-fija.png`) |
| `comprobacion-sin-cambio` (14:36) | 1582×853 | nada (`T99_MAXIMIZAR=false`) | 1582×853 | 1266×682 | **Sí** (`ventana-sin-cambio.png`) |

- **Defecto del instrumento, de rótulo:** con `T99_MAXIMIZAR=false`, el campo `ventana_pedida`
  decía «maximizada» aunque no se tocó nada (`ventanas_propias_maximizadas` 0 y
  `ventana_maximizada` falso, que sí eran correctos). Corregido a las 16:21, antes de medir:
  ahora dice «sin cambio». `flutter analyze` de los instrumentos, en cero.
- **Se descartó** lo medido con la ventana mal dibujada: la corrida del arnés con A01
  (13:53–14:01) y la de A06, que se cortó.
- **Lo decidió Yov (10.97):** es un hallazgo del instrumento, no del producto, y corrige lo
  que decía 10.96. Los tiempos se miden con la ventana del arnés sin cambiarle el tamaño, y la
  RAM, con el producto maximizado (10.86), como ya se hizo.
- **El sesgo de esa ventana:** dibuja 1582×853 píxeles, el 71 % de los 1920×991 de la ventana
  maximizada, y caben menos bahías y menos tarjetas. Los tiempos de build y de raster pueden
  salir algo mejores que en la ventana real. Por eso, en los tiempos de Windows, **un «no
  cumple» es firme y un «cumple» lleva esta advertencia.**

### B.3 RNF-001 · RAM en Windows (el producto, 10.86)

Binario release de `33404a5` con `tool/t99_main.dart`, Firebase inicializado en la app «t99» y
sin sesión, almacén en `%TEMP%`, abierto con `explorer.exe` y maximizado a 1920×1080 al 125 %. El
escenario fijo de T-63 lo recorre el conductor, que carga el archivo desde los assets de la copia
(sin el diálogo nativo: se declara). Cinco lecturas de `WorkingSet64` tras 5 s sin tocar,
después de cada paso. Una corrida en frío, descartada, y cinco medidas. MB del SI.

| Archivo | Corridas válidas | Estable, mediana | Estable, máximo | Pico, mediana | Pico, máximo | Umbral | Dictamen |
|---|---:|---:|---:|---:|---:|---|---|
| A01 (977) | 5 de 5, 35 lecturas cada una | 466.3 MB | 473.8 MB | 466.3 MB | 473.8 MB | < 200 MB | **No cumple** |
| Sintético de 5 000 | 5 de 5, 35 lecturas cada una | 1 854.5 MB | 1 856.8 MB | 1 854.5 MB | 1 856.8 MB | < 200 MB | **No cumple** |
| A06 (717), RNF-007 | 5 de 5, 35 lecturas cada una | 363.3 MB | 400.8 MB | 363.3 MB | 400.8 MB | < 200 MB (7.1 a) | **No cumple** |
| Sintético de 10 000, RNF-007 | 5 de 5, 35 lecturas cada una | 3 580.8 MB | 3 588.0 MB | 3 580.9 MB | 3 588.1 MB | < 200 MB (7.1 a) | **No cumple** |

- Entorno (`ram\entorno-*.json`): Windows 11 Home 10.0.26300, pantalla física 1920×1080,
  escala de la ventana 125 % (`DpiValue` 0 del panel: la recomendada), maximizada, cliente
  1920×991 píxeles.
- Corridas en frío, descartadas: 467.7 MB (A01), 1 846.8 MB (5 000), 377.5 MB (A06) y 3 563.4 MB (10 000) al volver a Lista. A01 y 5 000, de las 14:08 a las 14:34; A06, de las 17:25 a las 17:35; 10 000, de las 17:36 a las 17:52, con la misma configuración (entorno: 1920×1080, 125 %, maximizada, cliente 1920×991).
- En la corrida 3 de A01, el muestreador dio un `IOException` al leer la línea `fin` del
  registro (el banco lo tenía abierto); sus 35 lecturas estaban completas. Se corrigió la
  lectura (`FileShare.ReadWrite` y reintento) antes de las corridas de 5 000.

**La RAM paso por paso** (análisis de `ram\ram-windows.csv` con Python, sin la máquina; corridas
2 a 6, 25 lecturas por celda; mediana y rango, MB del SI):

| Paso del escenario | A01 (977) | Sintético de 5 000 |
|---|---:|---:|
| inicio (antes de cargar; no entra en el pico) | 360.0 (103.8–456.5) | 201.1 (106.2–998.8) |
| cargar | 448.2 (446.2–456.4) | 1 826.9 (1 817.2–1 827.3) |
| Plano | 180.0 (178.0–184.0) | 242.0 (240.6–250.7) |
| todas las bahías | 157.0 (154.1–158.7) | 206.2 (192.4–208.0) |
| Estadísticas | 150.0 (144.9–154.6) | 204.2 (189.0–210.5) |
| buscar un ID | 153.1 (151.8–160.6) | 197.1 (192.9–202.4) |
| volver a Lista | **466.3** (466.2–473.8) | **1 854.5** (1 848.4–1 856.8) |

- **Lo que pasa de 200 MB es la pestaña Lista.** Con A01, el producto se queda entre 145 y
  184 MB en Plano, bahías, Estadísticas y búsqueda, y sube a 466 MB al volver a Lista. Con 5 000,
  entre 189 y 251 MB fuera de Lista, y 1 854 MB en ella.
- **En el código** (lectura, sin correr nada): la pestaña Lista es un `SingleChildScrollView`
  con una `Column` que lleva `ContainersListView`, un `ListView.builder` con `shrinkWrap: true` y
  `NeverScrollableScrollPhysics`
  (`lib/features/vessel/presentation/widgets/containers_list_view.dart`, línea 26). Así, la
  lista no se construye por partes: cada tarjeta del viaje se construye y se dispone aunque no
  se vea. Coincide con lo medido: Lista crece unos **0.35 MB por contenedor** ((1 854.5 − 466.3)
  / (5 000 − 977)), y Plano, unos 0.015. Es un resultado y no se corrige (10.73); para el Sprint 4
  lo decide Yov.
- **Las lecturas de «inicio» no están quietas** desde la segunda corrida: suben durante los
  2 s de lecturas (A01, de 105 a 456 MB; 5 000, de 106 a unos 1 000 MB). En la primera corrida de
  A01 se quedaron en 157–177 MB. Lo más probable es que sea lo que el producto lee al abrir del
  almacén de `%TEMP%`, que conserva lo de las corridas anteriores; no lo comprobé. No sería
  que lo muestre: en el Honor, con un viaje ya guardado, el banco abre en la pantalla de inicio
  (B.7).
  **No cambia el dictamen:** el resumen deja «inicio» fuera del pico, y volver a Lista da lo
  mismo con el almacén vacío (467.7 MB en la corrida en frío) que con él (466.3 MB).
- La memoria privada (`PrivateMemorySize64`, en el mismo CSV, corridas 2 a 6) sigue el mismo
  dibujo: con A01, 533.0–541.8 MB en Lista y 218.4–234.4 MB de Plano a la búsqueda; con 5 000,
  1 935.3–1 945.1 MB y 240.2–303.8 MB.

**La curva de memoria (RNF-007, informativa)**, medianas de Windows:

| Contenedores | Volver a Lista | Plano | Estadísticas |
|---:|---:|---:|---:|
| 717 (A06) | 363.3 MB | 191.9 MB | 161.5 MB |
| 977 (A01) | 466.3 MB | 180.0 MB | 150.0 MB |
| 5 000 | 1 854.5 MB | 242.0 MB | 204.2 MB |
| 10 000 | 3 580.8 MB | 289.9 MB | 245.2 MB |

La Lista crece en línea recta, unos 0.35 MB por contenedor (de 5 000 a 10 000:
(3 580.8 − 1 854.5) / 5 000 = 0.345). El resto de la app crece poco: unos 0.01 a 0.015 MB por
contenedor. Fuera de la Lista, A01 se queda por debajo del umbral (145–184 MB), y 5 000 ya lo
pasa en el Plano (242 MB).

### B.4 RNF-005 y RNF-007, la parte estática (mientras Codex aceptaba T-112)

Sobre la copia verificada de `33404a5`, con `dart.exe` (no Flutter) y git de solo lectura.

**Documentación (5.1 a).** `public_member_api_docs` sobre dos copias de `lib/` en `%TEMP%`
(`dart analyze --format=machine`, a las 14:37, antes de la pausa): 1 870 señales con la
documentación quitada (todo lo público) y 1 147 con la actual (lo que falta); ninguna fuera del
denominador.
- **Clases y métodos públicos: 549, sin documentar 225 → 59.02 %.** Umbral ≥ 80 %.
- Con las funciones de nivel superior (lectura alternativa): 609 y 244 → 59.93 %.
- Las dos pantallas de H5 entran, con un elemento sin documentar cada una.
- No hay código generado en `lib/`.

**Capas.** 137 archivos de `lib/` (dominio 46, datos 28, presentación 52 y otros 11). **11
violaciones, todas de la regla 2** (presentación → datos): `vessel_providers.dart` (3),
`voice_recognizer_provider.dart` (2), `vessel_overview_page.dart` (2: exportación y PDF),
`departure_baplie_page.dart`, `export_list_providers.dart`, `movement_log_provider.dart` y
`sync_providers.dart`. La regla 1 (dominio) da 0, y el dominio no importa Hive ni Firebase.
Umbral: 0.

**Código compartido (3.1 b).** 137 archivos Dart con 25 884 líneas: 25 784 compartidas (51 en
ramas por plataforma y 49 en archivos que no usan los tres clientes). Nativo escrito a mano: 197
líneas en 26 archivos (650 de plantilla, excluidas). **98.86 % de 26 081 líneas.** Umbral ≥ 95 %.
La lectura literal («compila en una sola») daría más.

**Módulos, retrospectivo (7.4 a).** Archivos que ya existían y que cada función modificó:

| Función | Commits de código | `lib/` nuevos | Existentes modificados del producto | Cuáles |
|---|---|---:|---:|---|
| T-85 | `ac72849` (por su informe) | 1 | 5 | el validador de peligrosas, las reglas, la página y el provider de segregación, y las alertas |
| T-95 | `6b209f1` | 2 | 1 | `vessel_overview_page.dart` |
| T-96 | `0011882`, `adc9ea4` | 2 | 2 | `vessel_overview_page.dart` y `departure_baplie_page.dart` |
| T-73 | `04ecbab` | 7 | 8 | `vessel_overview_page.dart`, `hive_vessel_data_source.dart`, el repositorio local y su interfaz, `entities.dart`, `exceptions.dart` y `pubspec.*` |

`8ef6da1` (la aceptación de T-110 con la ronda del Honor) también nombra T-85, pero solo agregó
documentos y herramientas: no cambia la cuenta. Umbral: ningún archivo existente.

**Módulos, prospectivo (7.4 a).** El módulo mínimo «Notas del viaje» en una copia temporal (no
en una rama): 2 archivos nuevos en `lib/features/notas/` y **1 existente modificado**,
`vessel_overview_page.dart`, para engancharlo en la barra. La copia compila: `flutter pub get` y
`flutter analyze --no-pub` dan «No issues found!» (16:22). Fuente: `modulos\modulos.json` (`tool/t99_modulos.ps1`) y
`git show --stat` de cada commit.

### B.5 RNF-001 · Los tiempos del arnés en Windows

Arnés `integration_test` en *profile* (`flutter drive`), copia verificada de `33404a5`, con la
ventana del runner sin cambiarle el tamaño (B.2 y 10.97): **1582×853 físicos, 1266×682 lógicos a
1.25**, en la pantalla de 1920×1080 al 125 %. Una repetición en frío descartada y cinco medidas
por escenario; mediana y máximo (T-63, 2). Latencia con la traza (`traceAction`) y, como cotejo,
la pasada sin traza con `FrameTiming`; el scroll se dictamina con `FrameTiming` (10.86). Cada
corrida dejó una captura de su ventana (`PrintWindow`), y las dos se dibujan enteras
(`rendimiento-b\a01-windows-ventana.png`, en Estadísticas, y `s5000-windows-ventana.png`, en el
Plano). Máquina limpia: sin la app de T-98 y sin su servidor (B.1). A01 de las 16:36 a las
16:38:37; 5 000, de las 16:38:38 a las 16:42:52. Cuentas exactas (977 y 5 000), las bahías de
cada viaje (34 y 72) y el SHA-256 de cada entrada, iguales al manifiesto. Dart informa el sistema
como «Windows 10 Home» con la compilación 26300, que es Windows 11.

| Submétrica (umbral) | A01, mediana (máx.) | 5 000, mediana (máx.) | Cotejo sin traza, 5 000 |
|---|---:|---:|---:|
| Parseo (< 5 s con 5 000) | 6.6 ms (8.6) | **47.4 ms** (50.0) | cronómetro: 47.4 ms |
| Navegación entre bahías (< 100 ms) | 43.1 ms (52.0) | **78.5 ms** (101.6) | 95.8 ms (102.7) |
| Búsqueda por carácter (< 200 ms) | 30.9 ms (33.9) | **32.4 ms** (32.7) | 34.1 ms (50.6) |
| Tablero de Estadísticas (< 1 s) | 686.7 ms (722.2) | **2 875.7 ms** (2 998.3) | 2 972.5 ms (2 985.5) |
| Scroll de Lista, p90 build / raster (`FrameTiming`, ≤ 16.67 ms) | 0.39 / 2.30 ms | **1.29 / 11.16 ms** | — |
| Scroll de Estadísticas, p90 build / raster (`FrameTiming`) | 0.30 / 0.90 ms | **0.31 / 1.06 ms** | — |

- **Tablero con 5 000: no cumple, y es firme** (10.97): 2.9 s, casi el triple del umbral, en las
  dos pasadas. Con A01, 0.69 s. Incluye la transición de pestañas de `TabBarView`, unos 300 ms
  por diseño (Fase A, sección 6, punto 5).
- **Navegación con 5 000: cumple en la mediana, al límite.** La mediana con traza da 78.5 ms,
  pero el máximo (101.6 ms) y la pasada sin traza (mediana 95.8, máximo 102.7 ms) rozan o pasan
  los 100 ms. Lleva además la advertencia de la ventana más chica (10.97).
- **Scroll:** con la traza, el build de Lista con 5 000 da p90 de 43.8 ms (19 cuadros perdidos);
  sin ella, 1.29 ms. Es el efecto del observador que llevó a 10.86, y el dictamen va con
  `FrameTiming`.
- La corrida con 5 000 de las 16:24, hecha con la app de T-98 abierta, queda aparte y no da
  cifras (B.1).

**A06 y 10 000 (RNF-007)**, con la misma ventana y la máquina limpia (sin emulador, sin
muestreos ni otras apps): A06 de las 17:52 a las 17:55; 10 000, de las 17:55 a las 18:03. Cuentas
exactas (717 y 10 000; 27 y 72 bahías) y SHA-256 iguales al manifiesto; las dos ventanas se
dibujan enteras (`a06-windows-ventana.png`, `s10000-windows-ventana.png`).

| Submétrica (umbral) | A06, mediana (máx.) | 10 000, mediana (máx.) | Sin traza, A06 / 10 000 |
|---|---:|---:|---:|
| Parseo (< 5 s con 5 000) | 3.5 ms (6.7) | 119.1 ms (122.0) | cronómetro: 3.4 / 119.1 ms |
| Navegación entre bahías (< 100 ms) | 35.7 ms (44.5) | **125.8 ms** (135.8) | 60.9 / 128.3 ms |
| Búsqueda por carácter (< 200 ms) | 32.2 ms (36.9) | 32.5 ms (33.0) | 25.1 / 26.4 ms |
| Tablero (< 1 s) | 587.6 ms (621.3) | **6 336.3 ms** (6 415.1) | 596.1 / 6 313.4 ms |
| Scroll de Lista, p90 build / raster (`FrameTiming`) | 0.33 / 1.74 ms | 2.54 / **21.85 ms** (máx. 27.14) | — |
| Scroll de Estadísticas, p90 build / raster (`FrameTiming`) | 0.28 / 0.85 ms | 0.32 / 1.09 ms | — |

- **A06: los tiempos cumplen**, con la advertencia de la ventana (10.97). La RAM no (B.3).
- **10 000: no cumplen** la navegación (126 ms), el tablero (6.3 s) ni el raster del scroll de
  Lista (p90 de 21.85 ms); el parseo y la búsqueda, sí.

### B.6 RNF-001 · Los tiempos del arnés en el Honor

El mismo arnés en el Honor NAA-LX3 (Android 15, compilación `NAA-L03 9.0.0.318`, 720×1600 a
densidad 320: **360×800 lógicos**, letra 1.0), como app aparte `gt.cmartinez.baystream.t99`
(10.88), en *profile*. **Con `--no-dds`:** sin esa opción, la traza no arranca, porque el arnés,
desde el teléfono, intenta conectarse al servicio de la VM en la dirección de DDS de la laptop
(`ws://localhost:43549`, «Connection refused»; corrida de las 16:44, apartada como
`descartado-sin-no-dds-*`). La guía de Flutter para medir con `integration_test` («Performance
profiling», en el *cookbook*) pide `--no-dds` en un dispositivo móvil o en un emulador. En
Windows no hizo falta. A01 de las 16:46 a las 16:51; 5 000, de las 16:51 a las 17:05.
Cuentas exactas (977 y 5 000), 34 y 72 bahías, SHA-256 iguales al manifiesto. Las capturas por
`adb` se dibujan bien (`a01-honor-pantalla.png`, `s5000-honor-pantalla.png`: el Plano a 360 dp).

| Submétrica (umbral) | A01, mediana (máx.) | 5 000, mediana (máx.) | Sin traza, A01 / 5 000 |
|---|---:|---:|---:|
| Parseo (< 5 s con 5 000) | 102.2 ms (153.3) | **558.4 ms** (571.1) | cronómetro: 102.2 / 558.4 ms |
| Navegación entre bahías (< 100 ms) | **117.2 ms** (126.3) | **286.1 ms** (334.8) | 103.5 / 293.2 ms |
| Búsqueda por carácter (< 200 ms) | 51.3 ms (54.6), n = 4 | **57.3 ms** (66.6), n = 4 | 41.2 / 44.6 ms |
| Tablero de Estadísticas (< 1 s) | sin dato con traza | 12 026.7 ms (12 144.4), n = 3 | **2 205.9 / 12 038.8 ms** |
| Scroll de Lista, p90 build / raster (`FrameTiming`, ≤ 16.67 ms) | 4.27 / 10.33 ms | **13.70 / 17.02 ms** (máx. 18.64 / 17.29) | — |
| Scroll de Estadísticas, p90 build / raster (`FrameTiming`) | 3.49 / 7.28 ms | **3.44 / 7.14 ms** | — |

- **Navegación: no cumple**, ni con A01 (117 ms con traza; 104 sin ella) ni con 5 000 (286 ms).
- **Tablero: no cumple:** 2.2 s con A01 y 12 s con 5 000, en la pasada sin traza. **Faltan datos
  con traza:** en A01, la traza no trajo el par de marcas del tablero en ninguna de las cinco
  repeticiones, y con 5 000 faltó en dos; en la búsqueda faltó una de cinco en cada archivo. El
  resumen las cuenta como «sin dato» y no las rellena. La pasada sin traza está completa (5 de 5)
  y es la que da el dictamen del tablero en el Honor. No investigué por qué se pierden; es un
  límite del instrumento en Android y queda declarado.
- **Scroll de Lista con 5 000: no cumple:** el p90 de raster da 17.02 ms (máximo 17.29), por encima
  de 16.67; el de build, 13.70 ms, aunque una repetición llegó a 18.64. Con A01 cumple.
- **Cumplen:** el parseo (0.56 s con 5 000), la búsqueda y el scroll de Estadísticas.

### B.7 Android: la RAM en el Honor y en el emulador, y Android 8.0 (RNF-001 y RNF-003)

**La RAM del producto en Android** (10.86): APK release de `33404a5` con `tool/t99_main.dart`,
**compilado sin `--no-pub`**, Firebase inicializado en la app «t99» sin sesión, paquete aparte
`gt.cmartinez.baystream.t99` (10.88), escenario fijo de T-63 recorrido por el conductor
(`T99_ESCENARIO=ram`, carga desde el asset de la copia, pausa de 9 s). `t99_ram_honor.ps1` sigue
los pasos en el logcat del banco. Cada corrida es un arranque nuevo (`am force-stop` y
lanzador); la primera se descarta. MB del SI.

| Dispositivo | Archivo | Fuente del RSS | Estable, mediana (máx.) | Pico, mediana (máx.) | Umbral | Dictamen |
|---|---|---|---:|---:|---|---|
| Honor (Android 15, 360×800 lógicos, letra 1.0) | A01 | `dumpsys` TOTAL RSS | 454.8 MB (455.3) | 455.2 MB (455.8) | < 200 MB | **No cumple** |
| Honor | 5 000 | `dumpsys` TOTAL RSS | 1 520.8 MB (1 536.3) | 1 521.3 MB (1 536.8) | < 200 MB | **No cumple** |
| Emulador API 26 (Android 8.0.0, 1080×1920 a 420) | A01 | `/proc` VmRSS (Android 8 no trae TOTAL RSS) | 418.9 MB (425.3) | 419.0 MB (425.4) | < 200 MB | Informativo (RNF-001 se dictamina en Windows y en el Honor) |

- Honor con 5 000, de las 17:19 a las 17:40 (APK `015711F2…`): 1 517.6 MB al cargar y 1 520.8 al volver a Lista, contra 232.9–276.4 MB en Plano, bahías, Estadísticas y búsqueda. El resumen se rehízo en `resumen-honor-b` porque el instrumento no escribe sobre una carpeta que ya existe.
- Honor con A01, de las 17:05 a las 17:19; emulador con A01, de las 17:09 a las 17:21, con el
  mismo APK (`F431DCCE…`), cada uno en su CSV. Medir los dos a la vez no altera el RSS de cada
  dispositivo; en ese rato no se midió ningún tiempo.
- **Lo que más pesa, igual que en Windows, son la carga y la Lista:** con A01 en el Honor
  (corridas 2 a 6, medianas), 437.3 MB al cargar y 454.8 al volver a Lista, contra 228.6 en el
  Plano, 191.8 al recorrer las bahías, 193.5 en Estadísticas y 203.3 en la búsqueda
  (`ram-android\ram-honor.csv`).

**Android 8.0 · el recorrido de RNF-002 con el selector real** (RNF-003, emulador API 26,
17:22–17:25). APK release sin escenario (`3865A230…`), con Firebase en la app «t99» y sin
sesión. A01 se puso con `adb push` en `Download/t99/`, indexado con `MEDIA_SCANNER_SCAN_FILE`.
Los toques son `adb shell input tap`, que llegan como eventos de pantalla táctil. Capturas en
`%TEMP%\t99-fase-b-33404a5\recorrido-emulador\`.

| Tarea de RNF-002 | Cómo | Resultado |
|---|---|---|
| Cargar A01 | «Seleccionar archivo» → el selector del sistema (DocumentsUI) → `Download/t99/CORPUS_A01.edi` → «Parámetros del buque»: «No lo tengo» en el límite de apilamiento → «Confirmar y ver el plano» | **Completada:** 977 contenedores, 34 bahías, escala GTPBR |
| Ver una bahía | Pestaña Plano → chip «BAHÍA 02 (3%)» | **Completada:** «BAHÍA 02 · tapas sin declarar» |
| Encontrar un ID | Lista → «Buscar contenedor» → `ANXU6350869` | **Completada:** bahía 006, fila 04, nivel 84 |
| Identificar un refrigerado | Buscar `ZKPU3575466` (22R1) y tocar el resultado | **Completada:** abre el Plano en su bahía, con la celda resaltada; los refrigerados llevan el copo ❄ |
| Leer una alerta | Lista → «Alertas de estiba» | **Completada:** «Aviso · No evaluado · Segregación · IMDG 42-24», TSTU4419842 / DEMU5237232, UN3077 (clase 9) / UN1993 (clase 3) |

- **Observación (no se corrige, 10.73):** «Confirmar y ver el plano» deja la app en la pestaña
  **Lista**, no en el Plano (`recorrido-emulador\04-plano.png`). T-63 (2.2) anotaba ese
  comportamiento como un defecto de interfaz que se corregiría en el Sprint 3; en `33404a5` sigue
  igual.
- En el Plano, las acciones de la barra se pliegan y «Buscar contenedor» no está a la vista: la
  búsqueda se abrió desde Lista.

**Entrada con mouse y teclado en Windows** (RNF-003, 18:04–18:08). Banco release sin escenario,
con Firebase en la app «t99», sin sesión y con el almacén en `%TEMP%`, abierto con `explorer.exe`
y maximizado (1920×1080 al 125 %, área de 1920×991); cerrado por PID (13228). El mouse es real
(`SetCursorPos` y `mouse_event`, clic y rueda) sobre coordenadas leídas de una captura; el
teclado, `SendKeys`. Capturas en `entrada-windows\`.

| Tarea de RNF-002 | Cómo | Resultado |
|---|---|---|
| Cargar A01 | Clic en «Seleccionar archivo» → el **diálogo nativo** «Seleccionar archivo BAPLIE» (del mismo proceso) → la ruta escrita con el teclado y Enter → rueda hasta el límite de apilamiento, clic en «No lo tengo» y en «Confirmar y ver el plano» | **Completada:** 977 contenedores, 34 bahías |
| Ver una bahía | Clic en Plano y en «BAHÍA 02 (3%)» | **Completada** |
| Encontrar un ID | Clic en Lista y en la lupa; `ANXU6350869` con el teclado | **Completada:** bahía 006, fila 04, nivel 84 |
| Identificar un refrigerado | Buscar `ZKPU3575466` y clic en el resultado, que lleva el copo ❄ | **Completada:** el Plano abre en su bahía con la celda resaltada |
| Leer una alerta | Clic en Lista y en «Alertas de estiba» | **Completada:** «0 posibles incumplimientos · 6 no evaluados · 0 conformes»; la primera, TSTU4419842 / DEMU5237232 |

- **Límite del instrumento:** con `SendKeys`, las **mayúsculas no llegaron** al campo de búsqueda
  (de `ANXU6350869` quedó «6350869», y de `ZKPU3575466`, «3575466»); los dígitos sí, y las
  minúsculas también («zkpu» llegó entero). La búsqueda no distingue mayúsculas y encontró los dos
  contenedores igual. `SendKeys` escribe una mayúscula simulando Shift; no comprobé si una persona
  con el Shift físico lo vería. Queda declarado, no como defecto del producto: en Android, el
  mismo ID con mayúsculas llegó entero.

**Entrada táctil en el Honor** (RNF-003, 17:41–17:46): el mismo APK sin escenario
(`3865A230…`), instalado como `.t99`, con A01 en `Download/t99/` y el mismo recorrido por
`adb shell input tap`, a 360 dp y con letra 1.0. **Las cinco tareas, completadas:** A01 por el
selector del sistema (DocumentsUI: raíces → Descargas → `t99`), con «No lo tengo» y «Confirmar y
ver el plano» (977 contenedores, 34 bahías); la BAHÍA 02 en el Plano; `ANXU6350869` en la
búsqueda (bahía 006, fila 04, nivel 84); `ZKPU3575466` (22R1) resaltado en el Plano con su copo ❄;
y la primera alerta de segregación IMDG 42-24. Capturas en `recorrido-honor\`. Lo que pasó por el
camino:
- La tecla «atrás» (`keyevent 4`) cerró el banco y dejó al frente la app de T-98 de Codex, que
  estaba detrás en el teléfono. No se tocó: ningún toque ni texto sobre ella. Se volvió a abrir
  el banco con el lanzador, y **el banco abrió en la pantalla de inicio, sin el viaje**: hubo que
  cargar A01 otra vez (el perfil ya estaba guardado y no volvió a preguntar).
- A 360 dp, «Alertas de estiba» queda debajo del borde de la pantalla en Lista: se llega
  desplazando.
- La primera captura del selector mostraba cuentas y archivos recientes del teléfono; la borré y
  no la cito.

### B.8 RNF-003 · Los anchos (3.3 a)

Banco release con `T99_ESCENARIO=anchos` y A01. El conductor impone cada tamaño lógico dentro de
la app y guarda la captura de Lista, Plano, Estadísticas y búsqueda, con lo que encontró: textos
que no caben, desplazables horizontales con contenido oculto y errores de Flutter. «real» es la
ventana del producto maximizada. Criterio 3.3 (a): ningún texto ni control cortado o tapado.

**Windows** (17:10–17:11): binario release sin Firebase, almacén en `%TEMP%`, abierto con
`explorer.exe`, maximizado (Windows 11, 1920×1080 al 125 %, `DpiValue` 0) y cerrado por PID.
24 capturas en `%TEMP%\t99-fase-b-33404a5\anchos-windows\`, **cero errores de Flutter**.

| Tamaño lógico | Lo que dice el conductor | Lo que se ve en las capturas | Dictamen |
|---|---|---|---|
| 360×800 | 1 texto que no cabe (el resumen de pendientes de la bahía, con «…»); 72 px ocultos en las acciones de la barra | En el Plano, la etiqueta de zoom «100 %» **tapa el título de la bahía**; la leyenda corta «Refrigerado» en el borde; en Lista, las acciones que no caben quedan fuera de la vista, en un desplazable de la barra (72 px) | **No cumple** |
| 600×960 | sin textos que no caben | En el Plano, la etiqueta «100 %» **tapa en parte el final del título** («tapas sin declarar»); la leyenda corta «Ocupado» en el borde | **No cumple** |
| 840×1200 | sin textos que no caben | Todo a la vista | Cumple |
| 1200×800 | sin textos que no caben | Sin revisión visual; el conductor no marca nada | Cumple (por el conductor) |
| 2560×1440 | sin textos que no caben | Sin revisión visual; el conductor no marca nada | Cumple (por el conductor) |
| real, 1536×793 (1920×1080 al 125 %) | sin textos que no caben | Todo a la vista | Cumple |

- Los desplazables horizontales que marca el conductor por encima de 600 son el selector de
  bahías y la rejilla, que se desplazan por diseño, y las páginas de `TabBarView`, que el
  conductor cuenta aunque no se vean. No los cuento como cortes.
- **Que la etiqueta «100 %» tape el título no lo detecta el conductor**, que solo mira el texto
  que no cabe: sale de mirar la captura. La leyenda desplazable a 360 dp ya está en la lista del
  rediseño (10.94).

**Web** (17:13–17:15): build release de la Web, servido por `tool/t99_servidor.dart` en
127.0.0.1:8099 y abierto en Chrome sin interfaz, a 1920×1080 y con un perfil propio en `%TEMP%`;
los dos se cerraron por PID y no quedó nada escuchando en el 8099. «real» = 1902×984 lógicos.
24 capturas en `%TEMP%\t99-fase-b-33404a5\anchos-web\`, **cero errores de Flutter**. El primer
intento (17:13) no capturó nada: el script cerró Chrome antes de tiempo porque el registro de
pasos aún no existía. Se corrigió la espera y se repitió con el mismo build.

| Tamaño lógico | Lo que dice el conductor | Lo que se ve | Dictamen |
|---|---|---|---|
| 360×800 | el mismo texto que no cabe; 72 px ocultos en las acciones de la barra | Igual que en Windows: «100 %» tapa el título de la bahía; la leyenda corta «Refrigerado» | **No cumple** |
| 600×960 | sin textos que no caben | Sin revisión visual; en Windows, el mismo tamaño tiene el título tapado en parte | **No cumple** (como en Windows; mismo código y mismo tamaño lógico) |
| 840×1200, 1200×800, 2560×1440 | sin textos que no caben | Sin revisión visual | Cumple (por el conductor) |
| real, 1902×984 | sin textos que no caben | Todo a la vista | Cumple |

- **El dictamen de 3.3 (a), en los dos clientes: no cumple a 360 ni a 600; cumple de 840 en
  adelante y en la pantalla real de 1920×1080.**

### B.9 RNF-005 · Las reconstrucciones (5.3 b)

**Método, declarado:** la sección 9 pedía DevTools con «Track widget build counts». Se usó la misma
extensión que activa DevTools (`ext.flutter.inspector.trackRebuildDirtyWidgets`, eventos
`Flutter.RebuiltWidgets` del stream `Extension`), leída con un cliente del servicio de la VM
escrito para esto, `tool/t99_reconstrucciones_vm.dart`. **Vive solo en la copia de `%TEMP%`:**
importa `vm_service`, que no es dependencia directa, y en el repositorio rompería el `analyze`
(`depend_on_referenced_packages`). Los conteos son los mismos que vería DevTools, pero sin su
interfaz, y quedan agrupados por fase (un archivo de control marca la fase vigente).

App en **debug** (`flutter run -d windows --debug --no-pub -t tool/t99_main.dart`, almacén en
`%TEMP%`), ventana de 1600×900. A01 cargado con mouse y teclado, por el diálogo nativo. 18:11–18:17;
cerrada por PID (1220). Resultados en `%TEMP%\t99-fase-b-33404a5\reconstrucciones\`.

**Cinco toques en chips de bahía** (Plano; BAHÍA 02, 03, 05, 06 y 07), con el mouse, una fase por
toque y 2 s de pausa entre fases (las pausas no registran ninguna reconstrucción):

| Toque | Cuadros | Reconstrucciones | En `bay_plan_view.dart` | Fuera de ese archivo |
|---|---:|---:|---:|---|
| BAHÍA 02 | 18 | 544 | 522 | `LoadingPlanControls` 11 y `PlanDragConfirmation` 8, hijos de `BayPlanView`; el propio `BayPlanView` 1; Riverpod 2 |
| BAHÍA 03 | 17 | 564 | 542 | lo mismo |
| BAHÍA 05 | 20 | 566 | 544 | lo mismo |
| BAHÍA 06 | 18 | 781 | 759 | lo mismo |
| BAHÍA 07 | 20 | 596 | 574 | lo mismo |

- Lo más reconstruido es la rejilla: `_ContainerCell` 156 veces por toque (13 columnas × 12
  niveles) y sus `Container` y `Text`, más los 11 `FilterChip` del selector.
- **Fuera de `BayPlanView` solo se reconstruyen dos widgets internos de Riverpod**
  (`UncontrolledProviderScope` y `_UncontrolledProviderScope`, uno por toque), sin arrastrar a
  sus hijos. `ContainersListView` y `VoyageStatsView`: cero. Pero, como advertía la sección 9,
  `TabBarView` no las monta mientras se ve el Plano, así que eso solo no prueba granularidad.
- **Por eso se repitió con la búsqueda abierta sobre la Lista:** tres caracteres («z», «k», «p»),
  una fase por carácter: 134, 133 y 133 reconstrucciones, **todas en
  `container_search_delegate.dart`**. Nada en `containers_list_view.dart`, que sí está montada
  debajo.
- **Dictamen 5.3 (b): cumple.** Navegar entre bahías solo reconstruye la rejilla y su selector, y
  buscar solo reconstruye la búsqueda.
- **De paso, una confirmación de B.3:** al activar el conteo, Flutter fuerza una reconstrucción
  de todo lo montado. Sobre la Lista, eso dio 33 705 reconstrucciones en `containers_list_view.dart`:
  las 977 tarjetas están montadas aunque no se vean.

### B.10 Las cuatro tablas, con su dictamen

Todo sobre `33404a5` (`sprint3-cierre-2`). Basta un cliente fuera del umbral para «no cumple». En
los tiempos de Windows, un «cumple» lleva la advertencia de la ventana más chica (10.97).

**Dictamen por RNF:**
- **RNF-001 · Rendimiento: no cumple.** La RAM pasa de 200 MB en los dos clientes (unos 455–466 MB
  con A01; 1 520–1 855 MB con 5 000); el tablero pasa de 1 s con 5 000 en los dos, y en el Honor
  también con A01; en el Honor, la navegación pasa de 100 ms y el raster del scroll de Lista con
  5 000, de 16.67 ms. Cumplen el parseo y la búsqueda.
- **RNF-007 · Escalabilidad: no cumple.** Por la RAM, ni A06 ni 10 000 cumplen los umbrales de
  RNF-001 (7.1 a); con 10 000 tampoco la navegación, el tablero ni el scroll. Los dos criterios de
  módulos (7.4 a) tampoco: ninguna función se agregó sin tocar archivos existentes.
- **RNF-005 · Mantenibilidad: no cumple.** Documentación 59.02 % (umbral 80 %) y 11 violaciones de
  capas. Cumplen el análisis estático (cero) y las reconstrucciones (5.3 b).
- **RNF-003 · Portabilidad: no cumple.** A 360 y a 600 dp hay texto tapado (3.3 a), y Windows 10 no
  se probó (10.83). Cumplen Windows 11, Android 8.0, la Web (con la carga desde el asset), el
  código compartido (98.86 %) y la entrada con mouse, teclado y toque.

**RNF-001 · Rendimiento**

| Submétrica | Umbral | Medición | Dictamen |
|---|---|---|---|
| Parseo de 5 000 | < 5 s | Windows 47.4 ms; Honor 558.4 ms (medianas; B.5 y B.6) | **Cumple** (en Windows, con la advertencia de la ventana) |
| Navegación entre bahías | < 100 ms | Windows: A01 43.1 ms, 5 000 78.5 ms (máx. 101.6). Honor: A01 117.2 ms, 5 000 286.1 ms | **No cumple** (Honor) |
| Búsqueda por carácter | < 200 ms | Windows: 30.9 y 32.4 ms. Honor: 51.3 y 57.3 ms (n = 4 con traza; sin traza, 41.2 y 44.6) | **Cumple** (en Windows, con la advertencia de la ventana) |
| Scroll de Lista y Estadísticas | p90 ≤ 16.67 ms, build y raster (`FrameTiming`, 10.86) | Windows: todo ≤ 11.16 ms. Honor: Lista con 5 000, raster 17.02 ms y build 13.70; lo demás ≤ 10.33 | **No cumple** (Honor, Lista con 5 000) |
| Tablero | < 1 s | Windows: A01 686.7 ms, 5 000 2 875.7 ms. Honor, sin traza: A01 2 205.9 ms, 5 000 12 038.8 ms | **No cumple** (los dos clientes con 5 000; el Honor también con A01) |
| RAM, estable y pico | < 200 MB (SI) | Windows: A01 466.3 / 473.8 MB; 5 000, 1 854.5 / 1 856.8 MB (estable, mediana / máximo; el pico es igual). Honor: A01 454.8 / 455.3 MB; 5 000, 1 520.8 / 1 536.3 MB (B.3 y B.7) | **No cumple** (los dos clientes) |

**RNF-007 · Escalabilidad**

| Submétrica | Umbral | Medición | Dictamen |
|---|---|---|---|
| 500 sin degradación (A06, 717) | umbrales de RNF-001 (7.1 a) | RAM en Windows: 363.3 MB (máx. 400.8). Tiempos en Windows, dentro de los umbrales: navegación 35.7 ms, búsqueda 32.2, tablero 587.6, scroll ≤ 1.74 (B.5) | **No cumple** (RAM; los tiempos cumplen, con la advertencia de la ventana) |
| 10 000 aceptable | umbrales de RNF-001 | RAM en Windows: 3 580.8 MB (máx. 3 588.0). Tiempos en Windows: navegación 125.8 ms, tablero 6 336.3 ms, raster del scroll de Lista p90 21.85 ms; parseo 119.1 ms y búsqueda 32.5, dentro (B.5) | **No cumple** |
| Curva memoria/tamaño | — | Windows, volver a Lista: 363.3 MB (717), 466.3 (977), 1 854.5 (5 000) y 3 580.8 (10 000): una recta de unos 0.35 MB por contenedor; fuera de Lista, de 0.01 a 0.015 (B.3) | Informativa |
| Curva tiempo/tamaño | — | Windows, medianas con traza para 717 / 977 / 5 000 / 10 000: parseo 3.5 / 6.6 / 47.4 / 119.1 ms; navegación 35.7 / 43.1 / 78.5 / 125.8 ms; tablero 587.6 / 686.7 / 2 875.7 / 6 336.3 ms; búsqueda, plana (31–33 ms) (B.5) | Informativa |
| Módulos, retrospectivo | 0 archivos existentes (7.4 a) | T-85 5, T-95 1, T-96 2, T-73 8 (B.4) | **No cumple** |
| Módulos, prospectivo | 0 archivos existentes | 1 existente modificado, `vessel_overview_page.dart` (B.4). La copia con el módulo compila: `flutter pub get` y `flutter analyze --no-pub`, «No issues found!» (16:22) | **No cumple** |

**RNF-005 · Mantenibilidad**

| Submétrica | Umbral | Medición | Dictamen |
|---|---|---|---|
| Documentación (5.1 a) | ≥ 80 % | 59.02 % (225 de 549 sin documentar) | **No cumple** |
| Análisis estático | 0 errores y 0 advertencias | **«No issues found!»** (16:21, 14.0 s), `flutter analyze --no-pub` sobre una copia pura de `33404a5` sacada con `git archive` y cotejada con `git ls-tree` (742 archivos iguales; 3 documentos con acentos en el nombre sin cotejar), con el `package_config` de la copia de compilación (mismo `pubspec.lock`). Coincide con la aceptación de T-112 (10.96) | **Cumple** |
| Capas | 0 violaciones | 11, todas de presentación → datos, en 7 archivos (B.4) | **No cumple** |
| Providers (5.3 b) | solo se reconstruye la rejilla | En debug, con la extensión de DevTools: cada toque de bahía reconstruye solo `BayPlanView` y lo que cuelga de ella (más dos widgets internos de Riverpod); cada carácter de la búsqueda, solo la búsqueda, con la Lista montada debajo (B.9) | **Cumple** |

**RNF-003 · Portabilidad**

| Submétrica | Umbral | Medición | Dictamen |
|---|---|---|---|
| Windows 11 | funciona | El banco release recorrió completo el escenario de RAM 24 veces (A01, A06, 5 000 y 10 000) a 1920×1080 y 125 %, sin errores; los anchos, sin errores de Flutter (B.8); el arnés, completo con los cuatro archivos (B.5); las cinco tareas de RNF-002 con mouse y teclado, con el diálogo nativo (B.7) | **Cumple** |
| Windows 10 | — | **No probado (10.83)** | No se da por cumplido |
| Android 8.0 | funciona | Emulador API 26 (8.0.0), APK release: las cinco tareas de RNF-002 completadas con el selector real del sistema y toques; la RAM con A01, completa (B.7) | **Cumple** |
| Web | funciona | Build release en Chrome sin interfaz: cargó A01 y recorrió Lista, Plano, Estadísticas y la búsqueda en los seis tamaños, sin errores de Flutter (B.8). Sin el selector de archivos del navegador: la carga fue desde el asset | **Cumple** (con esa salvedad) |
| Código compartido (3.1 b) | ≥ 95 % | 98.86 % de 26 081 líneas (B.4) | **Cumple** |
| Anchos 360, 600, 840, 1200, 2560×1440 y 1920×1080 | 3.3 (a) | Windows y Web: a 360 y 600, la etiqueta «100 %» tapa el título de la bahía (y a 360 la leyenda corta etiquetas); de 840 en adelante y a 1920×1080, nada cortado (B.8) | **No cumple** (360 y 600) |
| Entrada | mouse, teclado y toque | Toque: las cinco tareas de RNF-002 en el Honor y en el emulador. Mouse y teclado: las cinco en Windows; con `SendKeys` no llegaron las mayúsculas, sí las minúsculas y los dígitos, y la búsqueda no distingue mayúsculas (B.7) | **Cumple** (con esa salvedad del instrumento) |

**Lo que no se midió o queda con salvedad** (declarado):
- **Windows 10:** no probado (10.83).
- **RNF-007 en el Honor:** A06 y 10 000 se midieron solo en Windows (arnés y RAM). En el Honor, A01 y
  5 000.
- **La ventana del arnés en Windows** es la del runner sin cambiarle el tamaño (B.2, 10.97).
- **El arnés en el Honor** necesitó `--no-dds`, y su traza perdió datos del tablero y de una búsqueda;
  el tablero se dictamina con la pasada sin traza (B.6).
- **La carga en los bancos de RAM, anchos y Web** es desde el asset de la copia, sin el diálogo nativo
  ni el selector del navegador. El selector real se probó en el emulador, en el Honor y en Windows
  (B.7).
- **`SendKeys`** no entregó las mayúsculas (B.7).
- **Las reconstrucciones** se contaron con la extensión de DevTools, sin su interfaz (B.9).
- Los comandos y ayudantes de esta fase quedan en `%TEMP%\t99-fase-b-33404a5\hoja\` (no en el
  repositorio).

### B.11 Archivos de la Fase B y cierre de la ventana

- **En el repositorio** (solo instrumentos de T-99 y este informe; `lib/` sin tocar):
  `integration_test/t99_rendimiento_test.dart` (ventana fija o sin cambio, y su rótulo),
  `integration_test/t99_ventana.dart` (`fijarVentanaPropia`), `tool/t99_main.dart` (almacén en
  `%TEMP%` y Firebase en la app «t99» para la RAM del producto), `tool/t99_copia.ps1` (cotejo con el
  árbol de la etiqueta), `tool/t99_ram_windows.ps1` (lectura compartida del registro) y este
  informe. `pubspec.yaml` y `pubspec.lock` no cambian.
- **Al cerrar (18:19):** el emulador apagado (17:25); ningún banco abierto en Windows; Chrome sin
  interfaz y el servidor del 8099 cerrados; el Honor con la letra en 1.0 y el banco `.t99` detenido
  (la app sigue instalada, aparte de la real). Quedan copias de `CORPUS_A01.edi` en
  `Download/t99/` del Honor y del emulador, puestas para el selector. La pantalla de Windows se
  queda en 1920×1080 por decisión de Carlos (20-oct): Codex mide Windows esa noche (10.97).

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
   visible. Cargar A01 a mano y abrir la pestaña «Plano» (antes «Bay Plan», T-112).
3. Activar «Track widget build counts» y limpiar los contadores.
4. Tocar el chip de la bahía siguiente una vez y esperar a que no haya cuadros.
5. Anotar en «Rebuild Stats» qué widgets se reconstruyeron y cuántas veces. Cumple si solo se
   reconstruye la rejilla y su selector (`BayPlanView` y lo que cuelga de ella), no
   `ContainersListView` ni `VoyageStatsView`.
6. Repetir con cinco bahías y guardar una captura de cada una en `%TEMP%`.

Si el contador no aparece, se declara y se usa la opción de T-63 que Yov elija. Nota:
`TabBarView` solo construye la pestaña visible, así que Lista y Estadísticas no están montadas
mientras se ve «Plano». Que no aparezcan es correcto, pero no prueba granularidad; conviene
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

## Preparación de la Fase B (20-oct, 10.94)

Timonel · sobre HEAD `6a2962d`, con T-112. **No se midió nada**: T-99 se mide sobre el cierre
nuevo, `sprint3-cierre-2`.

- **T-112 cambió dos textos que tocan los instrumentos**, comprobados en `lib/`: la pestaña
  «Bay Plan» ahora es «Plano» y el chip «BAY nn (» ahora es «BAHÍA nn (». Se cambiaron en
  `tool/t99_conductor.dart` y en `integration_test/t99_rendimiento_test.dart`, cada uno con sus
  textos en una constante y una nota, para que el próximo cambio sea en un solo lugar.
- **Siguen igual** los tooltips que se tocan («Buscar contenedor», «Cargar archivo BAPLIE» y
  «Volver» de la búsqueda), las pestañas «Lista» y «Estadísticas», y las claves
  `bay-selector`, `plan-zoom-<bahía>` y `plan-toolbar-actions`. Ningún instrumento busca
  «Reefer»/«Refrigerado» ni el «Back»/«Atrás» de Flutter.
- **No cambian** los identificadores internos: el paso `bay_plan` del escenario de RAM y los
  nombres de las capturas de anchos.
- `flutter analyze` de los archivos cambiados, en 0; `test/t99_*`, 22/22. No se corrió la
  suite completa ni el arnés.
