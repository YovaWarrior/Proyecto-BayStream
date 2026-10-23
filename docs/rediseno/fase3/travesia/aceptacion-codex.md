# T-114 · Aceptación de la travesía del inicio (10.24)

**Dictamen: NO PASA.**

Capitán Codex · 23-oct-2026 · copia `C:\Proyectos\baystream-qa-r4`.
Commit **`f27de53`**, contra su padre **`f6e7932`** (`HEAD~1..HEAD`).

El dibujo, la geometría, la adaptación del inicio, la reducción de movimiento, la parada al abrir un plano y las verificaciones de suite/análisis pasan. No se cierra la entrega por **H1: el desplazamiento y el vaivén cambian coordenadas de layout, contrario a «solo Transform y opacidad»**, y porque **no quedó acreditada la corrida RNF-002 solicitada**. La revisión de esperas encontró además una suposición de reposo que debe adaptarse en el conductor T-99.

Se leyeron `AGENTS.md`, SPRINT-4 10.24, DESIGN 13.7 y 13.11 regla 7, la sección de entrega de Timonel y los archivos actuales afectados. Se repitieron la auditoría de la skill `flutter-ui` y los censos T-112. La evidencia nueva está en **`build/t114-travesia-aceptacion/`**; las rutas de evidencia siguientes son relativas a esa carpeta.

No se corrigió código del producto ni de instrumentos versionados. No se ejecutó Git de escritura ni `git status`, no se usaron Firebase, el Honor o el emulador. Flutter se ejecutó de uno en uno. Durante cada ventana de medición se anunció el semáforo y no se compilaron clientes ni se ejecutaron pruebas.

## H1 · El cruce modifica `Positioned.left/top`

En `lib/core/design/componentes/bs_travesia.dart:456`, el `ValueListenableBuilder` del buque crea un `Positioned` con `left: instante.x` y `top: … + instante.vaiven`. Cada tic cambia esas propiedades. Solo el cabeceo y las olas usan `Transform`; el desplazamiento horizontal y la flotación vertical cambian la posición de layout.

Esto contradice el mecanismo expresamente pedido en 10.24 y DESIGN 13.11, regla 7. Que el dibujo quede en un `RepaintBoundary` y no se repinte no evita ese cambio de layout.

El diagnóstico independiente montó la banda y leyó el `Positioned` real antes y un segundo después:

| Propiedad | Antes | Después |
|---|---:|---:|
| `left` | −377.596 | −329.595 |
| `top` | 75.242 | 76.628 |

El incremento horizontal fue **48.0005 dp**. El diagnóstico pasa porque demuestra ese comportamiento; no es una prueba de cumplimiento de «solo Transform». Los tiempos de cuadro medidos abajo son buenos en esta máquina, pero no sustituyen la regla de implementación.

**Corrección propuesta, sin implementarla:** conservar fija la colocación/tamaño de la caja y aplicar la traslación del cruce y del vaivén mediante `Transform.translate`, además de la rotación y opacidad ya existentes. Verificar que el buque sigue pintándose una sola vez y que no cambian sus coordenadas de layout por tic.

Evidencia: `posicion-layout.json`, `posicion-layout-test.txt`, `comprobacion_test.dart` y el código indicado.

## H2 · RNF-002 no acreditado; el detector confunde el dibujo con el botón

Se ejecutó **`tool/t114_primera_windows.py`**, sin modificarlo, con el sintético de **977 contenedores** de la aceptación anterior y un cliente Windows release nuevo, sin perfil y con almacén temporal `r4`.

La corrida con rutas normalizadas reconoció la ventana, pero el detector eligió el azul de la ilustración del muelle y pulsó **[204, 327]**, no el botón «Seleccionar archivo». Registró solo los pasos 1 y 2 y terminó con **«Más de 120 s sin rejilla»**. No abrió ni confirmó el selector; no hay un paso 3 ni una captura final de rejilla.

Sobre el mismo `inicio.png` se repitió únicamente la función de detección:

| Detector | Punto en la imagen | Qué señala |
|---|---|---|
| Original, prueba primero la marca clara | [213, 336] | El muelle del dibujo |
| Limitado al azul del tema oscuro observado | [420, 592] | El botón |

La diferencia entre el primer punto y la acción registrada es el origen de la ventana, [−9, −9]. La función original busca primero `#0D47A1`; ese azul existe en la ilustración incluso en tema oscuro. El detector no valida que el rectángulo pertenezca al botón.

Se conservó también un primer intento que no reconoció la ventana: se habían enviado rutas con separadores mezclados y el instrumento compara literalmente la ruta del ejecutable. Se repitió con rutas completas de Windows. Ese intento no se considera medición.

Como diagnóstico complementario, `rnf_tema_observado.py`, guardado solo en `build/`, importó el instrumento original y limitó `MARCAS` al azul oscuro observado. Conservó su recorrido, relojes, clic, selector y condición de cuadro quieto. Esta corrida registró el punto correcto **[411, 583]** en el escritorio, pero también terminó a 120 s sin registrar el paso 3. **No quedó demostrada la causa de este segundo bloqueo y no se atribuye a la travesía.** No se intentó producir una medición pasando por alto la elección real del archivo.

**Resultado:** no hay una corrida válida de tres pasos ni tiempo hasta la rejilla para esta entrega. No afirmo que la animación haya empeorado el RNF; afirmo que la aceptación pedida no quedó acreditada. Hace falta corregir/validar el instrumento y repetir el recorrido completo, revisando el PNG de la rejilla. El primer problema del detector puede existir desde la ilustración del paquete anterior; no se presenta como un cambio de este commit.

Evidencia: `rnf-windows.txt`, `rnf-primer-intento.txt`, `rnf-windows/sin01/registro.json`, sus PNG `inicio` y `ultimo`, `rnf-diagnostico-detector.json`, `rnf_tema_observado.py`, `rnf-tema.txt` y `rnf-tema/sin01/registro.json` con sus PNG.

## O1 · El conductor T-99 aún espera que el inicio se asiente

`tool/t99_conductor.dart:140` llama a `_asentar` antes del escenario. En la línea 591, `_asentar` espera mientras `hasScheduledFrame` sea verdadero, con un límite de 20 s, y al vencerlo retorna sin señalar que no hubo reposo. Con la travesía visible el inicio sigue pidiendo cuadros; la ventana de 60 s de los dos clientes lo confirma.

Por inspección de esa condición, el conductor puede consumir el límite y continuar como si la espera hubiera concluido normalmente. **No se cronometró aquí una ejecución de ese conductor:** no se inventa una medición de 20 s. Sí queda identificado el supuesto incompatible con el inicio animado. Los scripts de capturas de Windows que usan ese conductor heredan la espera.

**Propuesta:** para instrumentos que necesitan reposo, pedir reducción de movimiento o esperar un estado/elemento concreto con un resultado de timeout explícito. Los instrumentos que evalúan la animación deben usar una ventana de cuadros acotada. No se modificó el conductor.

## 1 · Alcance y pintura compartida

`git diff --stat HEAD~1..HEAD`: **27 archivos, 3192 inserciones y 60 eliminaciones**. Ningún cambio en `domain/`, `data/`, `lib/main.dart`, opciones de Firebase, `pubspec.yaml`, `pubspec.lock` ni los congelados. Ninguna dependencia nueva. Los archivos del paquete de Nube y los datos de sus seis ilustraciones tampoco cambian.

Se extrajo con `git show HEAD~1:…` el pintor anterior. En una biblioteca independiente bajo `build/` se conservaron su implementación y datos equivalentes, ajustando únicamente sus imports para poder ejecutarlo junto al actual. Se rasterizaron las seis ilustraciones con los dos pintores, en ambos temas y con/sin fondo: **24 comparaciones RGBA, cero píxeles distintos en todas**. Se guardaron los PNG antes/después con fondo. Esto verifica el resultado del cambio a `pintarFormaDeIlustracion`, no solo el parecido del diff.

Evidencia: `diff-stat.txt`, `rutas.txt`, `alcance.json`, `ilustracion_antes.dart`, `ilustraciones-comparacion.json`, `comprobacion_test.dart`, `comprobacion.txt` y los PNG `antes_*` / `despues_*`.

## 2 · Reglas del dibujo y de la travesía

La inspección de datos, código, pruebas y capturas confirma:

| Requisito | Resultado |
|---|---|
| Buque de `sin_conexion` | Reutiliza `casco_perfil`, `perfil_0_0` a `perfil_0_4`, `caseta` y `puente`; excluye nube y pausa |
| Proa a la derecha | El pintor refleja el lienzo con `scale(-1, 1)`; caseta/puente quedan en la popa izquierda |
| Agua y flotación | Obtiene relleno y trazo de los grupos `agua` y `flotacion` de esa ilustración |
| Colores por nombre | Se resuelven por `colorDeIlustracion` desde los tokens; no introduce hex en la travesía |
| Sin naranja | Cero píxeles naranjas en las bandas de las seis capturas nuevas de inicio/reducción de los clientes; el contenedor naranja del dibujo superior del inicio es la ilustración ya aprobada |
| Banda | Solo el alto sobrante, con umbral de 120 dp; el `SliverLayoutBuilder` queda después de ambos bloques |
| Agua | Tercio inferior, con mínimo de 32 dp |
| Buque | Mitad del alto de banda, acotada a 56–120 dp |
| Duración | `clamp((ancho + anchoBuque) / 48, 14, 40)` segundos; en el tramo no acotado, 48 dp/s. Al actuar los topes la velocidad efectiva cambia, conforme a la fórmula de DESIGN |
| Aparición y salida | Opacidad 0→1 en el primer 10 %, 1→0 en el último 12 % |
| Mar vacío | 3 s entre cruces; buque invisible durante esa pausa |
| Vaivén | ±1.5 dp, período 3.2 s |
| Cabeceo | ±0.8°, período 4.4 s, eje sobre el casco/flotación |
| Estela | Tres trazos detrás de la popa, con alfas 0.6, 0.4 y 0.2 del trazo original |
| Olas | Dos tiras a 8 y 16 dp/s hacia la izquierda; repetición de 48 dp |
| Solo Transform y opacidad | **No cumple: H1** |
| Decorativa | `ExcludeSemantics`, `IgnorePointer`, sin foco; lo comprueba también la prueba entregada |

Las 14 pruebas nuevas de `t114_travesia_test.dart` pasan dentro de la suite, incluidas las muestras temporales de aparición, salida, pausa, olas, vaivén, cabeceo y pintado único. La comprobación de esas reglas no subsana H1.

## 3 · Clientes Windows y Web: 60 s reales

Se compiló `client_main.dart` de esta evidencia en **release** para Windows y Web. Usa las pantallas reales de `BayStreamApp` mediante el banco existente `t99App`, sin inicializar Firebase. El área lógica del inicio fue **1280 × 720**. No se usaron widget tests para estos tiempos.

Windows se abrió con `explorer.exe`. Almacén utilizado: **`C:\Users\Giova\AppData\Local\Temp\t114-travesia-store-r4`**, namespace **`r4`**. No se abrió el almacén real ni el del paquete de Codex. La Web usó un perfil temporal de Chrome visible, origen `127.0.0.1:5919` e IndexedDB propio; cero solicitudes externas registradas.

Tras el arranque y cambio de tema se dejó una ventana de **60 s** sin interacción. Se registraron los `FrameTiming` entregados a **`SchedulerBinding.addTimingsCallback`** y los cuadros mediante un callback persistente que no programa cuadros.

Percentiles por rango más próximo, en milisegundos:

| Cliente | Muestras entregadas | Build p50 | Build p90 | Build p99 | Raster p50 | Raster p90 | Raster p99 |
|---|---:|---:|---:|---:|---:|---:|---:|
| Windows release | 1556 | 0.239 | 0.288 | 0.550 | 0.995 | 1.210 | 2.183 |
| Web release | 3600 | 0.599 | 0.700 | 1.000 | 0.000 | 0.100 | 0.101 |

Duraciones observadas: **60.001259 s** en Windows y **60.002500 s** en Web. El contador de cuadros dentro de la ventana dio 1536 y 3596, respectivamente. Los tiempos se entregan por lotes: los percentiles corresponden a los callbacks recibidos durante la ventana, y el número de muestras no se fuerza a coincidir con el contador de cuadros. No se presenta el raster Web redondeado a cero como ausencia de trabajo ni como medición directa de la GPU.

Se capturó el inicio en claro y oscuro en cada cliente. En las capturas oscuras normales el buque puede estar en la pausa/desvanecimiento del ciclo; la captura oscura con reducción lo muestra quieto completo. El contador de pinturas del buque no aumentó durante la ventana continua de 60 s en ninguno de los dos clientes; cambiar tema, capturar una imagen o remontar la pantalla son operaciones diferentes de esa ventana.

Evidencia: `client_main.dart`, `qa_output_io.dart`, `qa_output_web.dart`, `build-windows.txt`, `build-web.txt`, `clientes/windows/medicion.json`, `clientes/web/medicion.json`, `resumen-clientes.json`, las capturas de `clientes/`, `medir_web.py`, `medir-web.txt`, `clientes/web/red.json`.

## 4 · Reducción, plano y regreso

| Ventana observada | Windows | Web |
|---|---:|---:|
| Movimiento reducido, 5 s | **0 cuadros** | **0 cuadros** |
| Plano abierto, 5 s tras estabilizarlo | **0 cuadros** | **0 cuadros** |
| Regreso al inicio, 5 s | 125 cuadros | 300 cuadros |

Con reducción, ambos clientes reportan **0 callbacks transitorios y `hasScheduledFrame: false`** antes y después; posición, tamaño y opacidad no cambian. El centro de la caja queda en **426.6667 dp = 1280/3**: `x = 242.5886`, ancho `368.1561`. Las olas quedan quietas, como corrobora la prueba de transformaciones entregada.

Al publicar el plano sintético desaparece `BsTravesia`; no hay cuadros ni callbacks activos en la ventana posterior. Al cerrar el viaje vuelve a montarse el inicio, reaparece la banda y avanzan las coordenadas del buque. No se afirma que al desmontar y remontar conserve el mismo instante del ciclo. Las pruebas entregadas cubren también ruta encima y ciclo de vida pausado/reanudado.

Evidencia: `resumen-clientes.json`, ambos `medicion.json`, `inicio_reducido.png`, `plano.png` y `regreso_inicio.png` de cada cliente.

## 5 · No tapa ni empuja el inicio

Se compararon las posiciones de «Seleccionar archivo» y «Perfiles guardados» antes y después del commit, con fuentes reales, en **48 combinaciones**: cuatro ventanas × tres escalas × dos temas × dos densidades (oficina/muelle). Ventanas: **360 × 640, 600 × 960, 1280 × 720 y 1920 × 1080**; letra **1.0, 1.45 y 2.0**. Se usó el inicio dentro de un `Scaffold` con barra superior. La reducción se activó solo para medir geometría estable; el movimiento real se comprobó en los clientes.

**Pasan los 48 casos:** el botón está dentro de la ventana sin desplazar, sus posiciones y las de perfiles son idénticas a las anteriores, y la banda queda debajo de los bloques. Donde aparece mide al menos 120 dp y termina al pie sin agregar desplazamiento. En **360 × 640 y 600 × 960 no aparece en ninguna de las tres escalas**, porque no sobra espacio. En los dos tamaños de escritorio sí aparece. No se extrapola esta matriz a ventanas de altura no especificada.

Evidencia: `inicio_antes.dart`, `inicio-matriz.json`, `comprobacion_test.dart`, `comprobacion.txt`. El archivo anterior se extrajo con `git show` y solo se ajustaron imports en la copia de evidencia, sin tocar `lib/`.

## 6 · Suite, análisis y revisión de esperas

- **`flutter test --no-pub --reporter expanded`: 1311 éxitos, cero fallos y cero omitidas**, 56 s según el registro.
- **`flutter analyze --no-pub`: cero incidencias**, en una extracción limpia de HEAD bajo `arbol-analisis/`, después de su `pub get`.
- **`flutter analyze --no-pub lib test tool integration_test`: cero incidencias**, sobre la copia de trabajo. El análisis completo sobre el snapshot evita incluir como producto las evidencias Dart de aceptaciones anteriores en `build/`; no se cambió la configuración del proyecto.
- Pruebas propias: dos correctas para pintura y geometría, y un diagnóstico focalizado correcto que demuestra H1. No se suman al piso de 1311. El primer intento de la prueba propia falló por un import de la biblioteca anterior que faltaba ajustar; se corrigió solo esa copia de evidencia y se conserva la salida.

**`profile_loading_page_test.dart`:** se guardaron ambas versiones con `git show`. Al retirar únicamente las cinco líneas nuevas de configuración/comentario/limpieza de reducción, el resto es idéntico. **42 aserciones `expect` antes y 42 después; ninguna perdida ni reemplazada.**

Se buscaron referencias al inicio y esperas de reposo. Se inventariaron **21 archivos de prueba candidatos**. La suite completa pasa: no se observó ninguna prueba colgada ni omitida. Los casos de inicio de 360 dp y tamaño predeterminado no montan la banda; los de plano ya tienen viaje; `profile_editor_test` entra en perfiles antes de asentarse; las pruebas de tema con `home` sustituido no abren el inicio; los casos grandes de inicio que necesitan reposo solicitan reducción. Las pruebas de la travesía usan avances acotados de reloj para la banda activa y reposo solo con reducción.

En instrumentos, los Web de primera visualización esperan el primer lienzo/semántica y luego la bahía, no un inicio quieto. El instrumento RNF Windows espera quietud después de elegir archivo, por lo que la travesía desmontada no debería impedir esa condición; **su corrida falló antes del paso 3**, como consta en H2. El conductor T-99 sí conserva la espera problemática descrita en O1. Por ello **no se afirma que todos los instrumentos estén adaptados**.

Evidencia: `flutter-test.txt`, `flutter-analyze.txt`, `flutter-analyze-producto.txt`, `analisis-pub-get.txt`, `profile_loading_page_test.antes.txt`, `profile_loading_page_test.despues.txt`, `profile-test-verificacion.json`, `inventario-esperas.json`, `pruebas-inicio-candidatas.txt`, `comprobacion-import-instrumento.txt`, `comprobacion.txt` y `posicion-layout-test.txt`.

## 7 · Auditoría y censos

La auditoría `flutter_ui_audit.py . --all` se repitió contra `lib/` del padre del commit. Ambos resultados son **17 críticos / 248 avisos / 20 informativos**. La correspondencia de regla, archivo y líneas anteriores/actuales da **cero hallazgos nuevos**, también en los archivos tocados. Los 17 críticos totales son anteriores; no se declaran cero críticos absolutos del repositorio. Este escáner no detecta por sí mismo el incumplimiento de H1.

El censo T-112, con referencia de decisiones `5406e20`, da **1950 visibles: 1819 español, 131 sin idioma y 0 inglés**; M3 **250 incluidos / 7 excluidos / 3 excepciones**; **217/217** mensajes con causa y acción. Sin cambios respecto de la corrección anterior.

Evidencia: `audit.txt`, `audit-base.txt`, `auditoria-delta.json`, `censos.txt`, `censos/` con sus CSV, tablas, resumen y huellas.

## 8 · Capturas y datos

Se revisaron las **12 capturas entregadas**, que son de widget test con fuentes reales y reloj controlado; no se cuentan como clientes compilados. Se revisaron también las **15 capturas nuevas de clientes/intentos RNF**: cinco Windows, seis Web y cuatro PNG de los dos intentos RNF que llegaron a capturar la ventana. Total inventariado: **27 PNG**, con dimensiones y SHA-256.

El inicio vacío contiene solo los dibujos. El plano y los recientes nuevos contienen **BUQUE MANUAL, viaje M100**, procedentes del sintético T-100. El archivo preparado para RNF fue el sintético de 977, SHA-256 `9fb42622c3a20aa1e3681c39f51563f0ac8ab99afaa5b38a596dee03fd7481ce`; los intentos no llegaron a cargarlo. No se observaron datos personales ni corpus en las capturas. Los PNG antes/después de ilustraciones son arte del paquete, sin texto ni datos de operación.

Evidencia: `capturas-inventario.json`, `entrega-lamina-1.png` a `entrega-lamina-3.png`, `windows-lamina-*`, `web-lamina-*`, `banda-colores.json` y los originales inventariados.

## Entrega y siguiente paso

Archivo nuevo para versionar: **`docs/rediseno/fase3/travesia/aceptacion-codex.md`**. Instrumentos, registros, capturas, referencias anteriores y copia de análisis quedan en `build/t114-travesia-aceptacion/`, ignorado por `/build/`. Las compilaciones quedan en `build/windows/` y `build/t114-travesia-web/`. La copia temporal de ejecutable y almacenes de RNF queda en TEMP, aislada de la app instalada. El servidor, navegador y banco cerraron; se retiró el marcador temporal de modo RNF creado para esta aceptación.

**Codex no cambió `pubspec.yaml`, `pubspec.lock` ni fuentes de producto/pruebas/herramientas versionadas**; `integridad-final.json` conserva las huellas antes/después. Para cerrar: resolver H1, adaptar/verificar las esperas de instrumentos y acreditar una corrida RNF-002 completa con tres pasos y rejilla final, conservando las verificaciones que ya pasan. No se propone una limpieza general del proyecto.

### Tres líneas

1. NO PASA: el cruce y el vaivén cambian `Positioned.left/top`; RNF-002 no quedó acreditado y el conductor T-99 mantiene una espera de reposo incompatible.
2. Pasan 1311/0/0, análisis cero, comparación de las seis ilustraciones, 48 casos de inicio, dos ventanas reales de 60 s, reducción/parada/regreso, auditoría sin nuevos y censos sin cambios.
3. Solo se añade este informe; producto y pubspec intactos, evidencia en build, sin Git de escritura, Firebase, Honor o emulador.

### Mensaje para Yov

Yov: Capitán Codex revisó f27de53 contra f6e7932, travesía 10.24. Dictamen NO PASA: H1, el cruce y el vaivén modifican Positioned.left/top por tic, contrario a solo Transform y opacidad; diagnóstico propio guardado. RNF-002 no acreditado: el instrumento original pulsa el muelle azul del dibujo en vez del botón; el complemento limitado al tema observado tampoco registró el paso 3 y terminó a 120 s, causa adicional no demostrada. No atribuyo eso a la animación. T99Conductor._asentar conserva el límite de 20 s y puede continuar sin reposo. Pasan suite 1311/0/0, análisis cero, 24 comparaciones RGBA de las seis ilustraciones, 48 casos de geometría, clientes release Windows/Web durante 60 s (p99 build/raster: Windows 0.550/2.183 ms, Web 1.000/0.101 ms), reducción sin cuadros, plano sin cuadros y regreso activo, auditoría sin nuevos y censo 0 inglés/M3 250/7/3. Las 42 aserciones de profile_loading_page_test se conservan. Informe: docs/rediseno/fase3/travesia/aceptacion-codex.md; evidencia: build/t114-travesia-aceptacion/. Producto intacto; sin Git de escritura, Firebase ni dispositivos.

### Git para Carlos

Solo el informe de esta aceptación, por su ruta exacta:

```powershell
git add -- docs/rediseno/fase3/travesia/aceptacion-codex.md
git commit -m "Sprint 4: aceptacion de la travesia con hallazgos pendientes"
git push
```
