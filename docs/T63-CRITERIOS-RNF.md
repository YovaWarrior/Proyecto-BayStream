# T-63 · Criterio operativo de cada RNF, a partir de las dos mediciones de T-44

Timonel · 2-oct-2026 · Base: `0ec164b` · Solo análisis.

**No se tocó código ni se midió nada nuevo.** Las dos fuentes de datos son:

- `docs/T44-RESULTADOS.md`: Capitán Codex, versión candidata `1607263`.
- `docs/T44-FINAL-RESULTADOS.md`: Timonel, binarios finales `3ac98f6`.

El texto de cada RNF sale de la matriz de `T44-RESULTADOS.md`, que transcribe las «Métricas» del
ERS aprobado (`docs/Primer Entregable.docx`). Cuando la **descripción** del mismo RNF en el ERS
precisa algo que la métrica deja abierto, se cita también, porque ese texto ya está aprobado y no
es una propuesta.

## Cómo leer este documento

- **Criterio operativo.** Define *cómo* se mide: métrica, instrumento, condición y procedimiento.
  No define *cuánto* se exige.
- **Umbral.** Es el del ERS. Donde el ERS no da número o usa un término sin definir, hay opciones
  con su fuente, y el punto queda marcado **«decide Carlos»**. Cuando una opción tiene una razón de
  método, independiente del resultado, la recomiendo y la marco como recomendación. Aun así, decide
  Carlos.
- **Cambia un dictamen de T-44.** Si una propuesta o una opción cambia un dictamen, aparece en una
  línea propia con ese rótulo, con la justificación de la condición sin apoyarse en el resultado.
- **Dictamen con los datos actuales.** Es lo que diría el criterio propuesto aplicado a las cifras
  de T-44, sin medir nada nuevo. Los dictámenes de T-44 siguen vigentes hasta que Carlos decida.
- **Estimaciones.** Son horas de un programador. No incluyen redactar el informe ni el tiempo de
  Carlos.

**Una advertencia antes de empezar.** Varias de estas decisiones las va a tomar Carlos **después de
haber visto los datos**. La regla contra el sesgo no se puede cumplir olvidando lo que ya se midió.
Se cumple justificando cada condición por el uso real o por una fuente, y dejando escrito qué
dictamen cambia. Por eso cada «decide Carlos» lleva al lado lo que esa opción haría con los datos
actuales.

---

## RNF-001 · Rendimiento y tiempo de respuesta

### 1. Texto y por qué hoy no cumple

> «Parsing BAPLIE (5,000 contenedores): < 5 segundos.» «Navegación entre bahías: < 100 ms.»
> «Búsqueda en tiempo real: < 200 ms por actualización.» «Scroll de lista: ≥ 60 fps.»
> «Renderizado de dashboard: < 1 segundo.» «Consumo de RAM: < 200 MB en operación normal.»

La descripción del ERS precisa dos condiciones:
- el parseo de 5 000 contenedores se mide «en dispositivos de gama media»;
- la RAM se mide «durante la operación normal con archivos de hasta 5,000 contenedores».

**Por qué hoy no cumple:**
- **RAM de Windows** (`WorkingSet64`, la métrica de Codex):
  - 314.8 MB en `1607263`, sin el tamaño de ventana registrado;
  - 416.7–422.0 MB con la ventana maximizada en `3ac98f6`;
  - con la ventana de 1280×720, 209.0 MB recién restaurada y 199.4 MB después de navegar.
- **No hay archivo de 5 000 contenedores.** El corpus llega a 979.
- **La apertura del plano en el Honor** solo tiene cotas superiores, de 703 a 813 ms en la mediana.
  El instrumento tarda de 594 a 742 ms en capturar, así que no resuelve 100 ms.
- **Búsqueda, scroll y dashboard** no se cronometraron.

### 2. Definición operativa

**Condición común a todas las submétricas:**
- **Binarios:** los release finales, identificados por hash, como en T-44.
- **Archivo:** A01 (977 contenedores) para las submétricas que el corpus real cubre, y un archivo
  de **5 000 contenedores** para el parseo y la RAM. Este último no existe en el corpus. Ver la
  decisión 1.4.
- **Perfil del buque:** guardado. Así se mide la operación, no el diálogo de primera carga, que
  pertenece a RNF-002.

| Submétrica | Métrica | Instrumento | Evento inicial → evento final |
|---|---|---|---|
| Parseo | duración de la llamada al parser, en el binario release del dispositivo | prueba de integración en modo *profile* con marca de `Timeline` alrededor del parseo (`integration_test` y `traceAction`, [Flutter: profiling integration tests](https://docs.flutter.dev/cookbook/testing/integration/profiling)) | entrada al parser → modelo de viaje construido |
| Navegación entre bahías | tiempo hasta el primer cuadro con la bahía nueva | igual: `traceAction` sobre el toque en el selector de bahías | toque en la bahía siguiente → primer cuadro rasterizado con la rejilla nueva |
| Búsqueda | tiempo por actualización | `traceAction` al escribir un carácter | carácter escrito → cuadro con la lista filtrada |
| Scroll | tiempo de cuadro | `TimelineSummary` del mismo paquete: tiempos de *build* y *raster* por cuadro y cuadros perdidos | desplazamiento continuo de la Lista de A01 y del archivo de 5 000 |
| Dashboard | tiempo hasta el último gráfico pintado | `traceAction` al tocar «Estadísticas» | toque → cuadro con todos los gráficos |
| RAM | ver 1.4 | `Get-Process` en Windows; `adb shell dumpsys meminfo <paquete>` en Android ([dumpsys](https://developer.android.com/tools/dumpsys)) | cinco lecturas separadas 0.5 s, tras 5 s sin interacción |

**«Operación normal»** para la RAM, como escenario fijo:
1. cargar el archivo;
2. abrir el Bay Plan;
3. recorrer todas las bahías;
4. abrir Estadísticas;
5. buscar un ID;
6. volver a Lista.

Se reportan el valor **estable**, al final del escenario, y el **pico**, como máximo de las lecturas
tomadas después de cada paso.

**Procedimiento repetible.** Cinco repeticiones por submétrica, en un dispositivo y una ventana
fijados de antemano (1.4). Se reportan la mediana y el máximo, como en T-44. Se descarta la primera
corrida en frío, declarándolo. Flutter pide medir en dispositivo físico y en modo *profile*
([Flutter: UI performance](https://docs.flutter.dev/perf/ui-performance)).

**Por qué cambia el instrumento.** Con ADB y una captura PNG, la resolución efectiva es de unos
600–740 ms, más de seis veces el umbral de 100 ms. Las marcas de `Timeline` tienen resolución de
microsegundos. Es un cambio de método y se declara: las cotas de T-44 no se comparan con las
cifras nuevas.

### 3. Umbral

Se conservan todos los del ERS: 5 s, 100 ms, 200 ms, 60 fps, 1 s y 200 MB. Lo que el ERS no
define:

**1.1 · «Gama media» — decide Carlos.**
- (a) El **Honor X5d**. Es el único dispositivo Android con el que se midió; si representa la
  gama media del planificador lo decide Carlos.
- (b) Una clase objetiva: la [Android performance class](https://developer.android.com/topic/performance/performance-class)
  que el dispositivo declare, según el CDD.

Recomiendo fijarlo por el teléfono que usa el planificador, no por cuál da mejor cifra.

**1.2 · «≥ 60 fps» — decide Carlos.** Flutter da un presupuesto de unos 16 ms por cuadro a 60 fps
([Flutter: UI performance](https://docs.flutter.dev/perf/ui-performance)).
- (a) **Promedio:** tiempo medio de cuadro ≤ 16.67 ms.
- (b) **Percentil:** p90 o p99 del tiempo de cuadro ≤ 16.67 ms.

**Recomendación: (b) con p90.** Un promedio esconde los tirones que el usuario sí ve. Leerlo como
promedio sería la lectura más blanda.

**1.3 · Unidad del «MB» — decide Carlos.** El ERS escribe «MB». En el SI, 1 MB = 10⁶ bytes.
Windows, en el Administrador de tareas, y `dumpsys`, en kB, usan múltiplos de 1024.
- **Recomendación: MB del SI (10⁶ bytes),** porque es el significado normalizado de «MB». Las cifras
  de T-44 ya están en esa unidad.
- **Cambia un dictamen de T-44 si se elige MiB:** los 209 031 168 bytes de Windows a 1280×720
  serían 199.3 MiB, por debajo de 200. Elegir MiB por ese motivo bajaría el umbral un 4.9 %.

**1.4 · Métrica, ventana y archivo de RAM — decide Carlos.**

- **Métrica.** El ERS no la nombra.
  - Opción A: **memoria residente incluidas las páginas compartidas** en ambas plataformas:
    `WorkingSet64` en Windows ([Microsoft: Working Set](https://learn.microsoft.com/en-us/windows/win32/memory/working-set))
    y **RSS** en Android ([Android: memory management](https://developer.android.com/topic/performance/memory-management)).
  - Opción B: **memoria propia del proceso**: `PrivateMemorySize64` en Windows y **PSS** en Android.
    La documentación de `dumpsys` dice que PSS es «una buena medida del peso real en RAM de un
    proceso».
  - **Recomendación: A.** Es el único par en que las dos plataformas miden lo mismo: páginas
    residentes, compartidas incluidas. PSS no tiene equivalente exacto en Windows, y
    `PrivateMemorySize64` no es lo mismo que PSS.
- **Ventana de Windows.**
  - Opciones: (a) maximizada en el monitor que usa el planificador; (b) 1920×1080 maximizada, como
    escritorio típico; (c) la ventana inicial de la app, 1280×720.
  - Se fija por el uso real del planificador. No por cuál da menos de 200 MB.
  - En T-44, maximizada pesó el doble que a 1280×720: la superficie de dibujo domina.
- **Archivo.** El ERS dice «hasta 5,000 contenedores», y el corpus real llega a 979.
  - (a) Archivo **sintético** de 5 000 contenedores, construido a partir de A01 y declarado como
    sintético.
  - (b) Medir solo con el corpus real y declarar que la condición de 5 000 no se probó.
  - Un archivo sintético no es evidencia de un viaje real. Sirve solo como carga de prueba
    (`AGENTS.md`: no inventar datos).

### 4. Dictamen con los datos actuales y medición que falta

Con cualquier combinación de métrica y ventana que dejan las opciones de 1.4, la RAM sigue sin
cumplir:

| Combinación | Datos de T-44 | Resultado |
|---|---|---|
| A, ventana (a) o (b) (maximizada) | `WorkingSet64` 416.7–422.0 MB | > 200 MB |
| A, ventana (c) (1280×720) | 209.0 MB recién restaurada, 199.4 MB tras navegar | mixto: una serie por encima y otra por debajo |
| A, Android | RSS 233.7 MB | > 200 MB |
| B, Windows, cualquier ventana medida | privada 211.9–446.8 MB | > 200 MB |
| B, Android | PSS 184.1 MB | < 200 MB |

**Dictamen: No cumple**, el mismo de T-44. Las demás submétricas siguen sin medirse.

| Medición nueva | Horas |
|---|---|
| Prueba de integración de rendimiento en `integration_test/`, con cinco escenarios | 5 |
| Generador del archivo sintético de 5 000 contenedores, en `tool/` | 2 |
| Corridas en el Honor y en Windows, más RAM con el escenario fijo | 3 |
| **Total** | **≈ 10** |

### 5. Sprint 3

**Cabe**, si Carlos decide 1.1 a 1.4 antes de empezar. La prueba de integración toca `test/` o
`integration_test/`, no `lib/`.

---

## RNF-002 · Usabilidad y experiencia de usuario

### 1. Texto y por qué hoy no cumple

> «Tiempo para primera visualización desde apertura: ≤ 3 pasos / 30 segundos.» «Curva de
> aprendizaje: usuario productivo en < 10 minutos sin capacitación.» «Consistencia visual: 100%
> adherencia a Material Design 3.» «Idioma de interfaz: español.»

La descripción del ERS enumera los tres pasos:
> «El usuario deberá poder cargar un archivo BAPLIE y visualizar el plano de estiba en un máximo
> de 3 pasos (abrir app, presionar botón de carga, selecciónar archivo).»

**Por qué hoy no cumple:**
- **Primera carga de un buque sin perfil:**
  - 6 pasos en `1607263` (Web, A01, origen nuevo);
  - 6 en `3ac98f6` (Web, A02, origen con otros perfiles);
  - 5 en `3ac98f6` (Honor, A01, instalación limpia).
- **Con el perfil guardado:** 3 pasos (Web, A01).
- **Idioma:** `1607263` tenía un «Bad state» en inglés. En `3ac98f6` el error observado está en
  español.
- **Sin medir:** los 30 s, los 10 minutos y el 100 % de Material 3.

### 2. Definición operativa

**Pasos.** Un paso es cada acción del usuario que la app exige antes de mostrar el plano:
- **Cuentan:** cada toque o clic en un control propio, y cada decisión en un diálogo.
- **No cuentan:** los desplazamientos.
- **El selector de archivos del sistema cuenta como un solo paso,** «seleccionar archivo», aunque
  haya que navegar carpetas. Así lo enumera el ERS y así contaron T-44 y Codex.

**«Visualizar el plano de estiba».** Ver la decisión 2.2.

**Procedimiento.** Cronómetro y conteo a la vez, con grabación de pantalla:
- en Android, `adb shell screenrecord` ([Android: adb](https://developer.android.com/tools/adb));
- en Windows y Web, una grabación de pantalla.

El evento inicial es el toque en el ícono de la app y el final es el primer cuadro con el plano. Se
hacen cinco repeticiones por condición.

**Condiciones.** Se miden y reportan las dos:
- **(i)** primera carga de un buque sin perfil;
- **(ii)** carga de un buque con perfil guardado.

Qué condición rige el dictamen lo decide Carlos (2.1).

**Curva de aprendizaje.** Prueba con usuarios:
1. Participantes del perfil del ERS: personal marítimo-portuario sin experiencia técnica avanzada.
2. Sin capacitación previa.
3. Lista fija de tareas: cargar A01, ver una bahía, encontrar un contenedor por ID, identificar un
   refrigerado y leer una alerta de estiba.
4. «Productivo» = completa todas las tareas sin ayuda.
5. Se mide el tiempo desde que recibe la app hasta que completa la última tarea.

Marco de referencia:
- ISO 9241-11:2018, que define la usabilidad por eficacia, eficiencia y satisfacción
  ([ISO 9241-11](https://www.iso.org/standard/63500.html); la página de ISO no admite lectura
  automática y el enlace se comprobó por búsqueda).
- Nielsen Norman Group: cinco usuarios bastan para encontrar cerca del 85 % de los problemas
  ([NN/g](https://www.nngroup.com/articles/why-you-only-need-to-test-with-5-users/)).

**Material Design 3.** Desde Flutter 3.16, `useMaterial3` es `true` por defecto
([Flutter: Material 3 por defecto](https://docs.flutter.dev/release/breaking-changes/material-3-default)).
Se propone una lista verificable, pantalla por pantalla:
- cada control es un componente de la biblioteca Material de Flutter;
- cada color sale de `Theme.of(context).colorScheme`, regla ya vigente en `AGENTS.md`;
- se cuentan las excepciones.

**Idioma.**
- Inventario de las cadenas visibles de `lib/` y recorrido de todas las rutas de error.
- Métrica: cadenas visibles en español / cadenas visibles totales.

### 3. Umbral

Se conservan ≤ 3 pasos, 30 s, < 10 min, 100 % y «español».

**2.1 · Condición de la primera visualización — decide Carlos.**
- (i) Buque sin perfil, el caso más exigente.
- (ii) Buque con perfil.

El ERS no distingue entre las dos: dice «cargar un archivo BAPLIE», cualquiera. RF-036, que pide
confirmar la geometría, es posterior al ERS. **Recomendación: (i).** Es la lectura literal y es la
primera experiencia del usuario, que es lo que mide «primera visualización».

**Cambia un dictamen de T-44 si se elige (ii):** el conteo con perfil guardado son 3 pasos, dentro
del límite, salvo lo que diga 2.2. Para elegir (ii), la justificación tiene que venir del uso real:
por ejemplo, que el planificador trabaja siempre con la misma flota y la primera carga ocurre una
vez por buque. No del resultado.

**2.2 · Qué es «el plano de estiba» — decide Carlos.**
- (a) La **rejilla del Bay Plan**.
- (b) La vista del viaje cargado, aunque abra en Lista.

**Dato que ya existe** (`build/t44-final/web-a01-cargado.jpg` y `web-a02-cargado.jpg`): en la Web,
después de cargar, la app abre en la pestaña **Lista**, incluso tras pulsar «Confirmar y ver el
plano». En el Honor no quedó registrado en qué pestaña abre.

**Cambia un dictamen de T-44 si se elige (a):** en la Web hace falta un toque más en «Bay Plan», así
que la carga con perfil pasaría de 3 a 4 pasos y tampoco cumpliría. Elegir (b) para que la carga
con perfil quepa en 3 sería elegir por el resultado.

Recomiendo decidirlo por el texto: el ERS dice «visualizar el plano de estiba» y la app llama
«Bay Plan» a la rejilla. Que el botón diga «ver el plano» y abra Lista es una observación de
interfaz para el Sprint 3, no un defecto medido aquí.

**2.3 · «≤ 3 pasos / 30 segundos».** Se lee como **las dos condiciones a la vez**. Leer la barra como
«o» bajaría el umbral.

**2.4 · Denominador del 100 % de Material 3 — decide Carlos.**
- (a) Todos los controles interactivos.
- (b) Todos los widgets visibles, incluidas las visualizaciones propias del dominio, como la rejilla
  de bahías.

No hay una norma que fije este denominador. Si la rejilla se excluye, el informe tiene que decir
por qué: es una visualización sin componente equivalente en Material 3. No puede excluirse porque
haga bajar el porcentaje.

**2.5 · Participantes de la prueba con usuarios — decide Carlos.** Cuántos (NN/g recomienda cinco)
y de dónde salen. Que estén disponibles es la condición de la que depende 2.5.

### 4. Dictamen con los datos actuales y medición que falta

**No cumple** con (i): 5 y 6 pasos, frente a 3. Con (ii) y (a), también: 4 pasos en la Web. Solo
(ii) y (b) dan 3. Los 30 s, los 10 minutos y el 100 % de Material 3 no se midieron.

| Medición nueva | Horas |
|---|---|
| Pasos y tiempo cronometrado en las dos condiciones y tres clientes | 2 |
| Inventario de idioma | 2 |
| Lista de Material 3 | 3 |
| Prueba con cinco usuarios: preparación, sesiones y análisis | 8–10, sin contar el tiempo de los participantes |

### 5. Sprint 3

**Caben** los pasos, el tiempo, el idioma y Material 3 (≈ 7 h). **La prueba con usuarios** cabe
solo si Carlos consigue participantes del perfil del ERS. Si no, queda **fuera del alcance de la
tesis** y se declara como limitación.

---

## RNF-003 · Portabilidad y compatibilidad multiplataforma

### 1. Texto y por qué hoy no se puede medir

> «Plataformas soportadas: Windows 10+, Android 8.0+, Web (opcional).» «Base de código
> compartida: ≥ 95%.» «Adaptación responsiva: funcional en pantallas de 5" a 27".»

La descripción del ERS añade que los controles deben funcionar «tanto con mouse/teclado
(escritorio) como con gestos táctiles (móvil)».

**Por qué hoy no se puede medir:**
- Se probaron Windows 11, Android 15 (Honor) y Chrome; no hay prueba en Windows 10 ni en
  Android 8.0.
- El 95 % no tiene denominador.
- 5" y 27" son diagonales físicas, sin traducción a píxeles lógicos.
- A 360×800 px CSS (`3ac98f6`):
  - el plano se ve, con desplazamiento horizontal;
  - el título se trunca a «Ba…»;
  - la pastilla «325 vacíos» queda cortada en el borde.

### 2. Definición operativa

**Plataformas.**
- **Android 8.0:** es la API 26. El APK declara `minSdk=24` (T-44, `dumpsys package`), y Flutter
  soporta de la API 24 a la 37 ([Flutter: supported platforms](https://docs.flutter.dev/reference/supported-platforms)).
  Prueba: instalar el APK release en un emulador con imagen API 26, cargar A01 y recorrer las
  tareas de 2.
- **Windows 10:** Flutter lo soporta y es la versión que prueba en su CI (misma fuente). Prueba: el
  mismo recorrido con el `.exe` release en Windows 10, en un equipo o una máquina virtual.

**Base de código compartida.**
- Métrica: líneas de código Dart sin comentarios ni líneas en blanco, contadas con un script en
  `tool/`.
- Fórmula: líneas compartidas / líneas totales.
- Es «no compartida» toda línea dentro de una rama condicionada por plataforma (`kIsWeb`,
  `Platform.isX`, importaciones condicionales) y todo archivo que solo compila en una plataforma.

**Pantallas de 5" a 27".**
- Se traducen a anchos lógicos con las clases de tamaño de ventana de Android
  ([Android: window size classes](https://developer.android.com/develop/ui/compose/layouts/adaptive/use-window-size-classes)):
  compacta < 600 dp, mediana 600–840, expandida 840–1200, grande 1200–1600 y extragrande ≥ 1600.
- 5" es un teléfono en vertical: 360 dp, clase compacta. 27" es un monitor de escritorio: clase
  extragrande.
- Se prueba un ancho por clase: 360, 600, 840, 1200 y el de 27" (3.2).
- «Funcional» se define en 3.3.

**Entrada.** El mismo recorrido con mouse y teclado en Windows y con toque en Android.

### 3. Umbral

Se conservan Windows 10+, Android 8.0+, ≥ 95 % y de 5" a 27".

**3.1 · Denominador del 95 % — decide Carlos.**
- (a) Solo Dart de `lib/`.
- (b) Dart de `lib/` más el código nativo escrito a mano (`windows/runner`, `android/app/src`,
  `web/`), sin lo generado por `flutter create`.

No hay norma; ninguna opción tiene fuente externa. (b) es la lectura más exigente, porque
«reescribir código» incluye el nativo.

**3.2 · Qué representa 27" — decide Carlos.** Opciones: 1920×1080 al 100 %, 2560×1440 al 100 % o
3840×2160 al 150 %. Se fija por el monitor del planificador.

**3.3 · Qué es «funcional» — decide Carlos.**
- (a) Las tareas críticas se completan, **ningún texto ni control queda cortado o tapado**, y solo
  la rejilla de bahías puede desplazarse en horizontal.
- (b) Solo que las tareas críticas se completen.

(b) coincide con el nivel más básico de la guía de calidad de Android para pantallas grandes: «los
usuarios pueden completar los flujos de tareas críticos» ([Android: adaptive app quality](https://developer.android.com/docs/quality-guidelines/large-screen-app-quality)).
(a) es más exigente.

**Cambia un dictamen de T-44 si se elige (a):** a 360 px la pastilla «325 vacíos» queda cortada, así
que la adaptación responsiva pasaría de «no medible» a **no cumple** en ese ancho. Si el título
truncado con puntos suspensivos cuenta como «cortado» también es parte de esta decisión.

### 4. Dictamen con los datos actuales y medición que falta

**No medible.** Con 3.3 (a): **no cumple** la parte responsiva a 360 px. El resto no está medido.

| Medición nueva | Horas |
|---|---|
| Emulador API 26 | 1.5 |
| Windows 10 en máquina virtual (sin contar la licencia ni la imagen) | 2 |
| Script de conteo de código compartido | 1.5 |
| Cinco anchos por tres clientes, con capturas | 2 |
| Entrada con mouse, teclado y toque | 1 |
| **Total** | **≈ 8** |

### 5. Sprint 3

**Cabe.** Si no hay un Windows 10 disponible, esa plataforma se declara no probada; no se sustituye
por Windows 11.

---

## RNF-004 · Seguridad de los datos

### 1. Texto y por qué hoy no se puede medir

> «Procesamiento local: 100% de operaciones basicas sin transmisión de datos.» «Cifrado en
> tránsito: TLS 1.2+ para sincronización en la nube.» «Almacenamiento de credenciales: mecanismos
> nativos seguros de cada plataforma.»

La descripción del ERS precisa:
> «Los archivos se procesan exclusivamente en el dispositivo local sin transmisión a servidores
> externos (excepto la sincronización opcional a Firebase). En caso de implementar la
> sincronización en la nube (RF-032), los datos deben transmitirse cifrados mediante HTTPS/TLS.»

**Por qué hoy no se puede medir:** la lista de operaciones básicas no está definida, y por eso el
«100 %» no tiene denominador. Lo que hay en `3ac98f6`:
- **Web:** 0 peticiones a `firestore.googleapis.com`, solo descargas `GET` del sitio, del motor y del
  SDK, y de las fuentes.
- **Honor:** 0 conexiones TCP al arrancar y al cargar A01.
- **Windows:** sin medir.
- **La sonda del Honor** no ve UDP ni QUIC. **El rastreador de la pestaña** no ve las peticiones del
  service worker.
- **TLS y credenciales:** sin evaluar.

### 2. Definición operativa

**Operaciones básicas** (decisión 4.1): cargar un BAPLIE, confirmar el perfil, ver el Bay Plan y
navegar bahías, Lista y filtros, búsqueda, Estadísticas, Alertas de estiba, exportar, reabrir un
viaje reciente y Parámetros del buque.

**Métrica:** operaciones básicas sin ninguna transmisión de datos del usuario / operaciones básicas
totales, en cada plataforma.

**Instrumento por plataforma:**
- **Web:**
  - Chrome DevTools, pestaña Network, con «Preserve log» y exportación HAR
    ([Chrome DevTools: Network reference](https://developer.chrome.com/docs/devtools/network/reference)).
  - Para no perder lo que hace el service worker, además un registro de red de todo el navegador
    con `chrome://net-export` ([Chromium: NetLog](https://www.chromium.org/for-testers/providing-network-details/)).
    La página de Chromium no dice expresamente que incluya al service worker: hay que comprobarlo
    en la primera corrida.
- **Android:**
  - Los contadores de bytes por UID que mantiene Android (`dumpsys netstats detail`), leídos antes
    y después de cada operación.
  - Cuentan todo el tráfico del UID, UDP y QUIC incluidos, y cubren el hueco de la sonda TCP de
    T-44, que se conserva como segunda fuente.
- **Windows:** `Get-NetTCPConnection` y `Get-NetUDPEndpoint` filtrados por el PID de `baystream.exe`
  y muestreados durante cada operación, como la sonda del Honor.

**Qué es «transmisión de datos»** (decisión 4.2): toda petición que lleve contenido del archivo o
derivado de él (contenedores, posiciones, pesos, puertos, nombre del buque) o que escriba en un
servicio remoto (`POST`, `PUT`, `PATCH`, canal de Firestore).

**TLS.** Si RF-032 se considera implementado (4.3):
- versión negociada en el panel Security de Chrome;
- intento de conexión forzando TLS 1.1 con `openssl s_client -tls1_1`, que tiene que fallar.

**Credenciales.** Inventario de lo que la app guarda y dónde.

### 3. Umbral

Se conservan el 100 %, TLS 1.2+ y «mecanismos nativos».

**4.1 · Lista de operaciones básicas — decide Carlos.** La de arriba es una propuesta tomada de los RF
implementados. Ninguna operación puede quitarse porque transmita.

**4.2 · ¿La descarga del motor y del SDK es «transmisión de datos»? — decide Carlos.**
- (a) **No:** son `GET` de código público y no llevan datos del archivo.
- (b) **Sí:** cualquier petición externa durante el uso cuenta.

El ERS dice «sin transmisión de datos» y su descripción habla de «archivos» y de «información
comercial sensible». Eso apoya (a). Con (b), la Web no cumpliría nunca, porque descarga su propio
código.

**4.3 · TLS y credenciales cuando RF-032 y la autenticación no existen — decide Carlos.**
- (a) **«No aplica»**, porque el ERS condiciona el TLS a «en caso de implementar la sincronización».
  `AGENTS.md` excluye la autenticación, así que no hay credenciales de usuario.
- (b) **«No medible»** hasta que existan.

**Cambia un dictamen de T-44 si se elige (a):** las dos submétricas dejarían de contar como «no
medibles». La justificación es el texto condicional del ERS, no el resultado.

Dos hechos que hay que verificar, no decidir:
- Que ninguna operación básica use Firestore. T-45 y la traza de T-44 apuntan a que no.
- Que la clave de API de Firebase que viaja en la Web no es una credencial. Firebase dice que las
  claves restringidas a sus servicios «no necesitan tratarse como secretos»
  ([Firebase: API keys](https://firebase.google.com/docs/projects/api-keys)).

### 4. Dictamen con los datos actuales y medición que falta

**No medible.** Con 4.2 (a), las operaciones observadas en Web y Honor (cargar, plano, estadísticas,
búsqueda) no transmitieron nada. Faltan Windows, el resto de la lista de 4.1, el tráfico UDP/QUIC
del Honor y el del service worker.

| Medición nueva | Horas |
|---|---|
| Lista completa por tres plataformas, con HAR, NetLog, `netstats` y sonda de Windows | 4 |
| Script de la sonda de Windows en `tool/` | 1 |
| **Total** | **≈ 5** |

### 5. Sprint 3

**Cabe.**

---

## RNF-005 · Mantenibilidad y calidad del código

### 1. Texto y por qué hoy no se puede medir

> «Cobertura de documentación: ≥ 80% de clases y métodos públicos.» «Análisis estático: 0
> errores, 0 advertencias críticas en flutter analyze.» «Separación de capas: dominio, datos y
> presentación independientes.» «Patron de estado: Riverpod con providers granulares.»

**Por qué hoy no se puede medir:**
- `flutter analyze` da 0 incidencias, ejecutado en `3ac98f6`.
- La cobertura documental no tiene denominador.
- La separación de capas no tiene comprobación definida.
- «Granulares» no tiene umbral.

### 2. Definición operativa

**Documentación.**
- La regla `public_member_api_docs` del analizador de Dart señala todo miembro público que no
  sobrescribe a otro y no tiene `///` ([Dart: public_member_api_docs](https://dart.dev/tools/linter-rules/public_member_api_docs)).
- Procedimiento: ejecutar el análisis con esa regla activada **sobre una copia temporal del
  proyecto fuera del repositorio**, sin cambiar el `analysis_options.yaml` versionado.
- Métrica: 1 − (declaraciones señaladas / declaraciones públicas del denominador de 5.1).
- Se excluye el código generado (`*.g.dart`), declarándolo.

**Análisis estático.** `flutter analyze` sobre el commit medido.

**Capas.** Un script de importaciones en `tool/` cuenta las violaciones de las reglas ya escritas en
`AGENTS.md`:
1. ningún archivo de dominio importa `package:flutter`, la capa de datos ni la de presentación;
2. la presentación no importa la capa de datos.

**Providers.** Ver la decisión 5.3.

### 3. Umbral

Se conservan ≥ 80 % y 0 errores. Para las capas, «independientes» se traduce en **0 violaciones**.
No es un umbral nuevo: es la lectura literal.

**5.1 · Denominador de la documentación — decide Carlos.**
- (a) **Clases y métodos públicos**, como dice el ERS: sin campos, sin *getters* y sin
  constructores.
- (b) **Todo lo que señala** `public_member_api_docs`.

Recomiendo (a), por el texto. Hay que decidir también si cuentan
`lib/latency_test_screen.dart` y `lib/c3_reconciliation_screen.dart`: son instrumentos de H5, pero
están en `lib/` y se compilan. La decisión no puede depender de si están documentados.

**5.2 · «Advertencias críticas».** El analizador clasifica en *error*, *warning* e *info*.
- (a) Críticas = *error* + *warning*.
- (b) Todas.

Con 0 incidencias de cualquier tipo, el dictamen es el mismo con las dos opciones.

**5.3 · Providers «granulares» — decide Carlos.** El ERS no da número. Riverpod recomienda `select`
para escuchar solo la parte del estado que interesa ([Riverpod: refs](https://riverpod.dev/docs/concepts2/refs)).
- (a) **Conteo:** widgets que observan el estado completo del viaje frente a los que usan `select`
  o un provider derivado.
- (b) **Reconstrucciones:** al cambiar de bahía, con la herramienta de seguimiento de
  reconstrucciones de Flutter DevTools, solo se reconstruye la rejilla, no Lista ni Estadísticas.
- (c) Declararlo **cualitativo**, con evidencia de diseño y sin dictamen numérico.

(b) mide el efecto que el ERS busca: «minimizar reconstrucciones innecesarias».

### 4. Dictamen con los datos actuales y medición que falta

- **Análisis estático: cumple** (0 incidencias).
- **Resto:** no medido. **RNF-005 completo: No medible**, igual que en T-44.

| Medición nueva | Horas |
|---|---|
| Cobertura documental | 1.5 |
| Script de capas | 1.5 |
| Providers, con la opción (b) | 2 |
| **Total** | **≈ 5** |

### 5. Sprint 3

**Cabe.** No toca `lib/`: el análisis de documentación corre sobre una copia temporal del proyecto.

---

## RNF-006 · Disponibilidad y tolerancia a fallos

### 1. Texto y por qué hoy no se puede medir

> «Tasa de disponibilidad: 99.9% (sin dependencias externas para función básica).» «Recuperación
> de error: < 3 segundos para volver a estado operativo.» «Mensajes de error: 100% descriptivos
> con causa y acción sugerida.»

La descripción del ERS nombra las tres clases de entrada que deben manejarse:
> «archivos corruptos, incompletos o en formatos no soportados»

Además pide que los errores de parseo «indiquen el segmento y la causa».

**Por qué hoy no se puede medir:**
- Hay **un solo** archivo inválido probado: `T44_INVALID.edi`, de 7 bytes.
- Ese mensaje trae causa y acción en `3ac98f6`, cota de [0, 710] ms. En `1607263` le faltaba la
  acción.
- Un caso no demuestra el 100 %.
- El 99.9 % no tiene ventana ni fuente de incidentes.

### 2. Definición operativa

**Mensajes.** Catálogo de entradas inválidas, con al menos un archivo por clase del ERS:

| Clase del ERS | Archivos de prueba |
|---|---|
| Corrupto | bytes aleatorios; texto sin estructura EDIFACT (el actual `T44_INVALID.edi`) |
| Incompleto | A01 cortado a mitad de un segmento; A01 sin `UNT`/`UNZ`; A01 sin `TDT` |
| Formato no soportado | otro mensaje EDIFACT (por ejemplo, un `COPRAR`); un BAPLIE de otra versión; un archivo vacío |

Todos son sintéticos y derivados del corpus, y se declaran así.

Se añade un **inventario de todas las cadenas de error que `lib/` puede mostrar**, porque el «100 %»
abarca todos los mensajes, no solo los de parseo.

Por cada mensaje se marca si dice la **causa**, si dice la **acción** y, si es de parseo, si dice el
**segmento**.

**Recuperación.**
- Evento inicial: confirmar el archivo inválido en el selector.
- Evento final: el error está visible **y** la app está operativa: el viaje anterior se ve y el botón
  de carga responde.
- Instrumento: `adb shell screenrecord` en Android, cuadro a cuadro, y grabación de pantalla en
  Windows y Web. La documentación de `screenrecord` no fija la tasa de cuadros
  ([Android: adb](https://developer.android.com/tools/adb)): hay que leer la resolución real de cada
  video y reportarla.
- Una medición por archivo del catálogo y por plataforma.

**Disponibilidad.** Ver la decisión 6.1.

### 3. Umbral

Se conservan 99.9 %, < 3 s y 100 %.

**6.1 · Qué es el 99.9 % de disponibilidad — decide Carlos.**
- (a) **Funcional**, según el paréntesis del ERS: «sin dependencias externas para función básica».
  Proporción de las operaciones básicas de RNF-004 que funcionan **sin red** (modo avión en el
  Honor, red desconectada en Windows y Web después de cargar la app).
- (b) **Por tiempo o por solicitudes**, como lo define la ingeniería de confiabilidad de Google:
  proporción del tiempo en servicio, o de solicitudes con éxito, en una ventana
  ([Google SRE: Embracing risk](https://sre.google/sre-book/embracing-risk/)).
  - En una app local, el equivalente es la **proporción de sesiones sin cierre inesperado**.
  - Fuente práctica: Android vitals de Play, que marca como mal comportamiento una tasa de cierres
    percibida por el usuario por encima del **1.09 %** ([Android vitals](https://developer.android.com/topic/performance/vitals)).
  - Ese umbral es más laxo que el 99.9 % y **no lo sustituye**: solo sirve como fuente de datos.
- (c) Declararlo **fuera del alcance**: hacen falta datos de uso longitudinal que la tesis no tiene.

(b) solo es posible con usuarios reales durante semanas: la prueba cerrada de Play del Sprint 3
podría darlos.

### 4. Dictamen con los datos actuales y medición que falta

- **Recuperación:** < 3 s en el único caso medido.
- **Mensajes:** 1/1 con causa y acción, pero el catálogo tiene al menos 8 casos.
- **Disponibilidad:** sin medir.
- **RNF-006 completo: No medible**, el mismo de `3ac98f6`.

| Medición nueva | Horas |
|---|---|
| Catálogo de archivos | 1.5 |
| Inventario de cadenas | 1.5 |
| Corridas en tres plataformas con grabación | 2 |
| Prueba sin red (6.1 a) | 1 |
| **Total** | **≈ 6** |
| Con 6.1 (b), además la recolección longitudinal | semanas de calendario |

### 5. Sprint 3

**Caben** los mensajes, la recuperación y 6.1 (a). **6.1 (b) queda fuera del alcance de la tesis**
salvo que la prueba cerrada de Play dé datos suficientes.

---

## RNF-007 · Escalabilidad

### 1. Texto y por qué hoy no se puede medir

> «Capacidad mínima: 500 contenedores sin degradación.» «Capacidad objetivo: 10,000 contenedores
> con rendimiento aceptable.» «Extensión de módulos: agregar nuevo módulo sin modificar
> existentes.»

La descripción del ERS habla de archivos «desde buques feeder con 500 contenedores hasta buques
Ultra Large Container Ships (ULCS) con más de 20,000 TEU». Mezcla contenedores y TEU.

**Por qué hoy no se puede medir:**
- Se cargaron 7/7 archivos reales, de 369 a 979 contenedores.
- «Sin degradación» y «aceptable» no tienen definición.
- No hay archivo de 10 000.
- No se agregó ningún módulo.

### 2. Definición operativa

**Capacidad.**
- Las submétricas de tiempo y RAM de RNF-001, con su instrumento, en tres tamaños:
  - **500 contenedores:** el archivo real más cercano por encima es A06, con 717. Ver 7.3.
  - **5 000 contenedores:** el sintético de RNF-001.
  - **10 000 contenedores:** sintético, con una geometría de buque que los admita.
- Con eso se ve la curva tiempo/tamaño y memoria/tamaño.

**Extensión de módulos.** Dos procedimientos complementarios:
- **Retrospectivo,** sin código nuevo: para cada funcionalidad agregada después de fijar la
  arquitectura (por ejemplo, la segregación de T-41 o las alertas de estiba), contar con
  `git show --stat` los archivos modificados **fuera** de la carpeta nueva de la funcionalidad.
- **Prospectivo:** agregar en una rama un módulo mínimo y contar lo mismo.

### 3. Umbral

**7.1 · Qué es «sin degradación» y «rendimiento aceptable» — decide Carlos.**
- (a) **Absoluto, con los umbrales de RNF-001:** con N contenedores se cumplen todas las submétricas
  de RNF-001. La fuente es el propio ERS.
- (b) **Relativo:** con N contenedores, cada métrica empeora menos de un X % respecto de un archivo
  de referencia. No hay fuente para X: la decide Carlos.
- (c) **Límites de percepción** para «aceptable»: 0.1 s se percibe como instantáneo, 1 s mantiene el
  hilo del pensamiento y 10 s es el máximo de atención
  ([NN/g: response times](https://www.nngroup.com/articles/response-times-3-important-limits/)).
  Por ejemplo, navegación < 1 s y carga < 10 s con 10 000.

Recomiendo (a) para «sin degradación», porque usa umbrales ya aprobados y no inventa uno nuevo.
Para «aceptable» con 10 000, (a) o (c).

**Cambia un dictamen de T-44 si se elige (a):** la RAM de RNF-001 ya no cumple con A01 (977) en
Windows maximizado, así que la capacidad mínima pasaría de «no medible» a **no cumple**. La
justificación es que el ERS no da otra referencia de rendimiento que la de RNF-001, no el
resultado.

**7.2 · ¿10 000 contenedores o 10 000 TEU? — decide Carlos.** La métrica dice contenedores y la
descripción habla de TEU. Leer «10 000 TEU» como unos 5 000 contenedores de 40 pies bajaría la
exigencia: se recomienda la lectura literal de la métrica, contenedores.

**7.3 · Qué archivo representa 500 — decide Carlos.**
- (a) A06 (717), real.
- (b) Un recorte sintético de A01 a exactamente 500.

**7.4 · Qué es «modificar existentes» — decide Carlos.**
- (a) Ningún archivo fuera de la carpeta nueva.
- (b) Se permiten los puntos de registro (rutas, proveedores raíz, menú), contados y declarados.

(a) es la lectura literal.

### 4. Dictamen con los datos actuales y medición que falta

**No medible.** Con 7.1 (a): **no cumple** por la RAM de RNF-001.

| Medición nueva | Horas |
|---|---|
| Sintético de 10 000 (el de 5 000 sale de RNF-001) | 1.5 |
| Corridas de tres tamaños | 3 |
| Retrospectiva de módulos con git | 1.5 |
| Módulo prospectivo | 2 |
| **Total** | **≈ 8** |

### 5. Sprint 3

**Cabe**, compartiendo el arnés de RNF-001. Un archivo **real** de un ULCS queda **fuera del
alcance**: el corpus no lo tiene, así que la capacidad objetivo solo se prueba con datos sintéticos
declarados.

---

## RNF-008 · Compatibilidad con estándares de la industria

### 1. Texto y por qué hoy no cumple

> «Formato BAPLIE: compatible con versión 2.2.1 SMDG/EDIFACT.» «Coordenadas de estiba: formato
> ISO BBBRRTT.» «Códigos de contenedor: ISO 6346 (BIC code).» «Códigos de puerto: UN/LOCODE.»
> «Mercancías peligrosas: código IMDG.» «Pesos: kilogramos (SOLAS VGM).»

**Por qué hoy no cumple:** la segregación declara 49 CFR Parte 176 y niega expresamente la
equivalencia con el Código IMDG. Esto no cambió entre `1607263` y `3ac98f6`. Las otras cinco normas
no tienen prueba de conformidad: parsear 7/7 archivos no certifica.

### 2. Definición operativa

Una batería de conformidad por norma, con casos que la cumplen y casos que no. Cada caso es una
prueba automatizable en `test/`.

| Norma | Fuente | Casos positivos | Casos negativos |
|---|---|---|---|
| BAPLIE 2.2.1 | Guía de implementación de SMDG ([Baplie221-03.pdf](https://smdg.org/wp-content/uploads/MIGs/BAPLIE/Baplie221-03.pdf)) | los 7 archivos del corpus; cada segmento y grupo de la guía presente en alguno | segmentos obligatorios ausentes y calificadores fuera de lista |
| BBBRRTT | la misma guía, `LOC+147` | toda posición del corpus se descompone en bahía, fila y nivel | posiciones con longitud o dígitos inválidos |
| ISO 6346 | registro BIC, designado por ISO ([BIC](https://www.bic-code.org/)) | IDs con dígito de control válido | IDs con el dígito alterado |
| UN/LOCODE | lista de UNECE (descripción en [UN Statistics Division](https://unstats.un.org/unsd/classifications/Family/Detail/1042); UNECE bloquea la lectura automática de su página) | puertos del corpus presentes en la lista | código inexistente |
| IMDG | IMO; obligatorio bajo SOLAS desde el 1-ene-2004 ([IMO: dangerous goods](https://www.imo.org/en/ourwork/safety/pages/dangerousgoods-default.aspx)) | — | — |
| Pesos en kg y VGM | SOLAS VI/2 y [MSC.1/Circ.1475](https://wwwcdn.imo.org/localresources/en/OurWork/Safety/Documents/MSC.1%20Circ.1475.pdf) | pesos `KGM`; A03v_VGM con su VGM | unidad distinta de `KGM` |

**Cuidado con ISO 6346 sobre el corpus.** Los archivos están **anonimizados**, y la anonimización
puede haber roto el dígito de control de los IDs reales. La conformidad del validador se prueba con
IDs de prueba válidos e inválidos conocidos, no con el porcentaje de IDs válidos del corpus. Si se
reporta ese porcentaje, va aparte y con esa advertencia.

### 3. Umbral

Se conserva cada norma tal como está escrita. Umbral: **0 casos de la batería fallidos** por norma.

**8.1 · IMDG — decide Carlos.**
- (a) Implementar la segregación según el Código IMDG. Es una publicación de pago de la IMO, y
  cambiar la fuente toca `lib/`.
- (b) Mantener 49 CFR y declarar el **incumplimiento** de esta métrica como limitación de la tesis.

No existe una opción (c) que declare 49 CFR «equivalente»: sería bajar el umbral, y el propio
producto niega esa equivalencia.

### 4. Dictamen con los datos actuales y medición que falta

**No cumple** por IMDG, el mismo de T-44. Las otras cinco normas: no medidas.

| Medición nueva | Horas |
|---|---|
| Batería para BAPLIE, BBBRRTT, ISO 6346, UN/LOCODE y VGM | ≈ 8, más obtener la lista UN/LOCODE |
| IMDG (8.1 a) | estimación no posible sin el Código; claramente mayor que un sprint de holgura |

### 5. Sprint 3

**Cabe** la batería de las cinco normas. **IMDG (8.1 a) queda fuera del alcance de la tesis** salvo
que Carlos decida adquirir el Código y dedicarle el sprint.

---

## Tabla final

| RNF | Criterio propuesto, en una línea | Dictamen con los datos actuales | Medición que falta (h) | Decisión pendiente de Carlos |
|---|---|---|---|---|
| 001 | Marcas de `Timeline` en modo *profile* en el dispositivo de referencia y RAM por escenario fijo, cinco repeticiones, mediana y máximo | **No cumple** (RAM de Windows con cualquier ventana y métrica de las opciones; el resto sin medir) | arnés de rendimiento, archivo de 5 000 y corridas (≈ 10) | 1.1 gama media · 1.2 promedio o p90 · 1.3 MB o MiB · 1.4 métrica, ventana y archivo |
| 002 | Pasos y tiempo grabados en las dos condiciones de perfil; prueba de tareas sin capacitación; lista de Material 3 e inventario de idioma | **No cumple** (5 y 6 pasos sin perfil; 4 con perfil si el plano es la rejilla) | pasos, tiempo, idioma y M3 (≈ 7); usuarios (8–10) | 2.1 con o sin perfil · 2.2 qué es «el plano» · 2.4 denominador de M3 · 2.5 participantes |
| 003 | Emulador API 26 y Windows 10; Dart compartido por script; cinco anchos lógicos por clase de ventana; mouse, teclado y toque | **No medible**; **no cumple** a 360 px si «funcional» = sin contenido cortado | ≈ 8 | 3.1 denominador del 95 % · 3.2 qué es 27" · 3.3 qué es «funcional» |
| 004 | Lista de operaciones básicas por plataforma con HAR + NetLog (Web), `netstats` por UID (Android) y sonda TCP/UDP (Windows) | **No medible** (lo observado en Web y Honor: 0 transmisiones; falta Windows y el resto de la lista) | ≈ 5 | 4.1 lista de operaciones · 4.2 ¿cuenta la descarga del SDK? · 4.3 TLS y credenciales: «no aplica» o «no medible» |
| 005 | `public_member_api_docs` con configuración temporal; script de importaciones por capa; reconstrucciones en DevTools | **No medible** (análisis estático: cumple, 0) | ≈ 5 | 5.1 denominador y archivos H5 · 5.3 cómo se mide «granular» |
| 006 | Catálogo de entradas inválidas por clase del ERS más inventario de cadenas; recuperación por video; disponibilidad según 6.1 | **No medible** (1/1 mensaje con causa y acción; [0, 710] ms) | ≈ 6 (más semanas si 6.1 b) | 6.1 qué es el 99.9 % |
| 007 | Las métricas de RNF-001 a 500, 5 000 y 10 000 contenedores; extensión contada con git, retrospectiva y prospectiva | **No medible**; **no cumple** si «sin degradación» = umbrales de RNF-001 | ≈ 8 | 7.1 degradación y aceptable · 7.2 contenedores o TEU · 7.3 archivo de 500 · 7.4 qué es «modificar» |
| 008 | Batería de conformidad positiva y negativa por norma; ISO 6346 con IDs de prueba, no con el corpus anonimizado | **No cumple** (IMDG) | ≈ 8 + lista UN/LOCODE | 8.1 implementar IMDG o declararlo limitación |

**Total de medición nueva,** sin la prueba con usuarios ni IMDG: **≈ 57 h.** Con la prueba con
usuarios: ≈ 66 h.

### Dictámenes que alguna opción cambiaría

Ninguna recomendación de este documento convierte un «no cumple» en «cumple». Las opciones que
cambiarían un dictamen de T-44 son estas:

| RNF | Opción | Efecto | Recomendación y razón, independiente del resultado |
|---|---|---|---|
| 001 | 1.3 en MiB | una serie de Windows (1280×720) pasa por debajo de 200; el RNF sigue en «no cumple» | MB del SI: es el significado normalizado de «MB» |
| 002 | 2.1 (ii) y 2.2 (b) | la primera visualización cumple con 3 pasos | (i) y (a): es la lectura literal del ERS |
| 003 | 3.3 (a) | la parte responsiva pasa de «no medible» a **no cumple** | decide Carlos; (a) es la más exigente |
| 004 | 4.3 (a) | TLS y credenciales pasan a «no aplica» | el condicional está en el propio texto del ERS |
| 007 | 7.1 (a) | la capacidad mínima pasa a **no cumple** | (a): usa un umbral ya aprobado |

## Archivos

- Nuevo: `docs/T63-CRITERIOS-RNF.md`.
- No se tocó `lib/`, `test/`, `tool/`, `android/` ni `pubspec.*`. No se compiló ni se midió nada.
- Los enlaces se comprobaron el 2-oct-2026. Excepciones:
  - ISO y UNECE bloquean la lectura automática: el enlace de ISO se confirmó por búsqueda, y para
    UN/LOCODE se cita la página de la División de Estadística de la ONU.
  - Dos páginas abrieron pero no confirman el dato para el que se citan; el texto lo dice donde
    corresponde: `chrome://net-export` no dice si incluye al service worker, y la de `adb` no fija
    la tasa de cuadros de `screenrecord`.
