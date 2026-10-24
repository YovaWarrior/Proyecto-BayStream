# T-114 · Reaceptación de la corrección de la travesía (10.26)

**Dictamen: ACEPTADA con observaciones.** H1, H2 y O1 quedan cerrados para esta entrega. Las tres corridas nuevas de RNF-002 completaron el recorrido real, con rejilla y sin reintentos. La observación afecta a cómo interpretar futuras corridas que sí reintenten el clic; no invalida estas tres.

Capitán Codex · 23-oct-2026 · `C:\Proyectos\baystream-qa-r4`.
HEAD **`53838d75f43454dd05faffe87554bf365599ed1b`**, contra **`414568e69a7922f956c73d853a2781508416d0c8`** (`HEAD~1..HEAD`).

Se leyeron AGENTS.md, la decisión 10.26, la sección «Fase 3 · La travesía · Corrección tras la aceptación de Codex» y las versiones actuales de los archivos revisados. Esta aceptación se limita a la corrección; no repite la aceptación completa de la travesía ni la del paquete de ilustraciones.

Toda la evidencia nueva está en **`build/t114-travesia-reaceptacion/`**. Las rutas de evidencia siguientes son relativas a esa carpeta. No se corrigió código del producto ni de instrumentos versionados. No se ejecutó Git de escritura ni `git status`; no se tocaron Firebase, el Honor ni el emulador. Flutter se ejecutó de uno en uno y las ventanas RNF tuvieron semáforo, sin compilaciones ni pruebas simultáneas.

## 1 · Alcance: pasa

`git diff --stat HEAD~1..HEAD`: **48 archivos, 8367 inserciones y 101 eliminaciones**.

- Producto: solo `lib/core/design/componentes/bs_travesia.dart`.
- Pruebas: solo `test/t114_travesia_test.dart`.
- Instrumentos: `t114_primera_windows.py`, `t99_conductor.dart`, `t114_capturas_windows.ps1` y `t114_ram_windows.ps1`.
- El resto son DESIGN.md, documentación y evidencia de la corrección.

**Nada en `domain/`, `data/`, `lib/main.dart`, `pubspec.yaml`, `pubspec.lock`, los congelados, el paquete de Nube ni los instrumentos de T-98.** No hay dependencias nuevas. Se conserva el uso de las funciones de T-98 por importación, sin modificarlas.

Evidencia: `refs.txt`, `diff-stat.txt`, `rutas.txt`, `alcance.json` y `correccion.diff`.

## 2 · H1: caja fija y un solo Transform — pasa

El `Positioned` queda fuera del `ValueListenableBuilder`: `left: 0`, `top: geometria.arribaDeLaCaja`, ancho y alto fijos. Dentro, el constructor por tic cambia únicamente `Opacity` y un `Transform`; su hijo estable es el `RepaintBoundary` con el dibujo. La matriz traslada el cruce y el vaivén y gira alrededor del eje del cabeceo. Las olas conservan sus cajas fijas y sus transformaciones.

Se repitió el diagnóstico anterior, ampliado a **3305 cuadros simulados, a intervalos de 16 667 μs, durante dos ciclos completos** de una banda de 800 × 240. No son tiempos de rendimiento de un cliente.

| Lectura real del árbol | Resultado en todos los cuadros |
|---|---|
| `Positioned.left` | 0 |
| `Positioned.top` | 75.242292 dp |
| Ancho / alto | 377.595987 / 120 dp |
| `StackParentData.offset` | (0, 75.242292), constante |
| Identidad del widget `Positioned` | La misma |
| Transform bajo la opacidad | Uno; la matriz cambia en 2946 transiciones |
| Pintadas del buque | **Una** |

El seno del cabeceo leído de la matriz coincide con la regla de ±0.8° y 4.4 s, incluyendo el cabeceo cero durante los 3 s de pausa. La primera fórmula auxiliar de ese resumen omitía la pausa; se corrigió el comprobador, sin cambiar la prueba ni el producto. Los registros conservan cada matriz y la esquina transformada del dibujo.

Evidencia: `layout_test.dart`, `layout-test.txt`, `layout.json`, `layout-resumen.json`. La prueba nueva versionada y las restantes pruebas de la travesía pasan también dentro de la suite completa.

## 3 · H2: detector y reloj — pasa con una observación de interpretación

### Detector sobre las capturas anteriores

Se ejecutó el **`--detector` original del commit**, sin adaptar sus resultados:

| Capturas | Resultado |
|---|---|
| Inicio Windows anterior, claro y oscuro, 1280 × 720 | Botón en [258, 421], caja [16, 501, 398, 445] |
| Inicio Web anterior, claro y oscuro, 1280 × 720 | El mismo botón y caja |
| Los dos inicios de los intentos RNF anteriores, oscuros | Botón en [420, 592], caja [69, 772, 563, 621]; no el muelle |
| Captura entregada con hover | Botón en [420, 592], variante `hover` |
| Plano Windows anterior | Ningún botón |

**Ocho casos correctos.** El detector obtiene el tema del papel y valida color, forma, relleno y firma del rótulo. Esa firma es geométrica; no es OCR que lea el texto. En estas capturas corresponde al botón real. Evidencia: `detector.txt`, `detector-verificado.json`; los originales siguen en la evidencia de la aceptación anterior y en la entrega de Timonel.

### El reloj no se recorta

La comparación automática de ambos códigos confirma que son idénticos el bloque de inicio y el bloque que determina el fin:

- `t0 = time.perf_counter()` queda **antes de abrir el binario** por Explorer.
- Aparcar el cursor, maximizar, detectar dos veces el botón y guardar PNG ocurren después de `t0`: su tiempo cuenta.
- La variante hover solo amplía qué color reconoce el detector; no mueve el reloj ni transforma la imagen.
- Cada reintento conserva el mismo `t0`. Sus 4 s de espera y la pausa de 250 ms al recuperar el primer plano también cuentan; no se restan ni reinician.
- El fin sigue siendo el primer cuadro de la secuencia estable posterior a cerrar el selector, confirmada durante 0.6 s con diferencia media ≤ 0.35. Se informa el comienzo de esa secuencia, igual que antes; no se añadió una nueva deducción de tiempo.

Evidencia: `correccion.diff` y `reloj-comparacion.json`.

**Observación O2 · Una corrida con reintentos no acredita por sí sola tres pasos.** El instrumento anota cada clic en `acciones` y `clics`, y publica `reintentosDeClic`, pero sigue asignando literalmente `pasosDelProducto = 3`; `cumpleTiempo` comprueba únicamente ≤ 30 s. Con R reintentos hay **3 + R acciones del recorrido** según el mismo conteo del clic original. Su tiempo completo sirve para diagnóstico, pero **no la admitiría como evidencia limpia de RNF-002 en tres pasos**: hay que contabilizar esas acciones o repetir sin reintentos. No basta leer `pasosDelProducto` o `cumpleTiempo` aisladamente. Las tres corridas aceptadas aquí tienen R = 0 y sus listas de acciones son exactamente [1, 2, 3]. No se corrigió ese contador en esta tarea.

### RNF-002 en Windows: tres corridas válidas

Se compiló en release **el `tool/t99_main.dart` del commit**, con `T99_NAMESPACE=r4`, `T99_FIREBASE` desactivado por omisión y almacén **`C:\Users\Giova\AppData\Local\Temp\t114-travesia-reacc-store`**. El ejecutable se copió a `%TEMP%\t114-travesia-reacc\bin\baystream.exe`. El instrumento apartó solo ese almacén temporal antes de cada repetición «sin perfil». No se abrió el almacén de la app instalada ni el virtualizado de Codex.

Se usó el mismo sintético de **977 contenedores**, SHA-256 **`9fb42622c3a20aa1e3681c39f51563f0ac8ab99afaa5b38a596dee03fd7481ce`**.

| Corrida | Ventana (s) | Clic (s) | Confirmación del selector (s) | Rejilla quieta (s) | Reintentos | Acciones |
|---|---:|---:|---:|---:|---:|---|
| sin01 | 0.396 | 0.825 | 1.701 | **1.979** | 0 | 1, 2, 3 |
| sin02 | 0.436 | 0.833 | 1.632 | **1.907** | 0 | 1, 2, 3 |
| sin03 | 0.436 | 0.869 | 1.640 | **1.861** | 0 | 1, 2, 3 |

Mediana **1.907 s**. La tercera está dentro de 1.84–1.89 s; las otras dos son algo mayores y del mismo orden, todas muy por debajo de 30 s. No se afirma igualdad exacta con la serie de Timonel. El instrumento declara un intervalo nominal de 0.05 s; los intervalos registrados después de confirmar estuvieron entre aproximadamente **0.050 y 0.072 s**. No se interpreta la precisión decimal del JSON como exactitud de un milisegundo.

Se inspeccionaron las rejillas: muestran **T99 SINTÉTICO 977**, bahía y contenedores, en previo sin confirmar. Las tres `rejilla.png` tienen la misma huella SHA-256. Cada repetición guarda `inicio.png`, `rejilla.png`, `final.png`, acciones y cuadros; no basta una ventana quieta vacía.

**Tentativa excluida:** la primera ejecución desde la consola empaquetada llegó a 120 s sin clic. La captura mostraba otra aplicación cubriendo BayStream. Se conserva el registro y la huella, y se retiró ese PNG ajeno al producto. Se repitió el instrumento sin cambiarlo, lanzando Python mediante un `.cmd` abierto por Explorer; así completó las tres corridas anteriores. El lanzador no altera el `t0` interno ni automatiza pasos adicionales del producto. No se descontaron 120 s de una misma corrida ni se presentó la tentativa como éxito. Este resultado no demuestra retrospectivamente a qué ventana fue el clic de la aceptación anterior: esa causa histórica sigue sin medición directa.

Evidencia: `build-windows.txt`, `banco-huellas.json`, `rnf-lanzador.cmd`, `rnf-explorer.txt`, `rnf-explorer/`, `rnf-resumen-verificado.json`, `rnf-lamina-*`; para la tentativa, `rnf-windows.txt`, `rnf-windows/sin01/registro.json` e `intento-ocluido.json`.

## 4 · O1: reducción, resultado de reposo y avisos — pasa

El conductor original pide reducción salvo `T99_MOVIMIENTO=completo`. `_asentar` devuelve `Future<bool>`: `true` cuando ya no hay cuadro programado, y `false` al vencer, después de registrar un paso `aviso` con `asentar: vencido` y los ms. El límite por omisión es 20 000 ms. Los llamadores pueden continuar, pero ahora el registro declara expresamente que lo siguiente se tomó sin reposo.

Comprobaciones independientes:

- **Sin definir `T99_MOVIMIENTO`:** una prueba montó el `envoltorio` original sobre `BsTravesia`. Obtuvo `disableAnimations: true`, reposo en un cuadro de `pumpAndSettle`, cero callbacks transitorios, ningún cuadro programado y el buque quieto al avanzar 5 s.
- **Script original `t114_capturas_windows.ps1`, parámetros por omisión para movimiento:** escenario inicio, 1920 × 1080, letra 1.0, por Explorer: cuatro PNG, **0 avisos**, último paso `fin` y ningún error de Flutter registrado.
- **Conductor original con movimiento completo:** ejecución adicional del mismo binario, con `T99_ASENTAR_MS=500` solo para el diagnóstico: cuatro PNG, **11 avisos de 500–540 ms**, último paso `fin`. Comprueba el camino de vencimiento sin esperar 20 s once veces. No se presenta como medición con el límite por omisión.

Se revisaron ambos scripts: el de capturas transmite `T99_MOVIMIENTO` incluso por Explorer y cuenta los pasos `aviso`; el de RAM fija `reducido` en su lanzador y cuenta esos mismos pasos **por corrida**. El criterio de conteo reconoce los 11 avisos del registro diagnóstico. No se repitió una campaña de RAM: en esta corrección se verificó su manejo de avisos y su configuración.

La Web y Android se verificaron **por lectura de sus instrumentos**, sin ejecutarlos ni tocar dispositivos:

| Instrumentos | Condición de avance / fin |
|---|---|
| `t114_primera_web.js` / `.py` | Primer lienzo, semántica del botón y bahía; esperas con límite/error. No espera reposo del inicio ni busca un color |
| `t114_capturas_web.py` / `_plano.py` | Elementos de semántica con timeout y pausas fijas |
| `t114_primera_android.py` | Texto del botón en uiautomator, selector y bahía; intentos acotados |
| `t114_primera_cuadros.py` | Fin propuesto desde los cuadros del plano final, con candidatos para revisión; no espera que el inicio se inmovilice |
| `t114_capturas_android.py` / `_plano.py` | Texto/estado con intentos acotados y screencap |

No dependen de que el inicio se quede quieto. Tampoco se alteraron los instrumentos T-98.

Evidencia: `conductor_test.dart`, `conductor-test.txt`, `conductor-omision.json`, `capturas-reposo.txt`, `capturas-reposo/`, `conductor-completo/`, `conductor-resultados.json`, `esperas-web-android.txt` y el diff de los instrumentos.

## 5 · Suite e integridad — pasa

- **`flutter test --no-pub --reporter expanded`: 1312 éxitos, cero fallos y cero omitidas**, 58 s según el registro. El piso sube en una prueba, como se pidió.
- **`flutter analyze --no-pub`: cero incidencias**, 36.5 s. Se ejecutó sobre una extracción limpia de las fuentes de HEAD en `arbol-analisis/`, con su propio `flutter pub get`, para no analizar como producto los instrumentos Dart de las aceptaciones acumulados en `build/`. No se alteró la configuración de análisis del repositorio.
- Las dos pruebas independientes de esta aceptación también pasan; no se suman a 1312.
- Huellas antes/después de **650 archivos** de producto, pruebas, herramientas, assets, diseño, Windows y configuración: **ningún cambio de bytes**. Ningún diff versionado respecto de HEAD al terminar las comprobaciones.

Evidencia: `flutter-test.txt`, `flutter-analyze.txt`, `analisis-pub-get.txt`, `huellas-antes.json`, `integridad-final.json` y las salidas de las dos pruebas independientes.

Se inventariaron **17 PNG nuevos válidos**: nueve RNF y ocho del conductor. Se revisaron mediante originales/láminas; solo contienen los sintéticos 977 y T-100 (BUQUE MANUAL, M100/R00), sin datos del corpus ni cuentas. La captura ajena de la tentativa ocluida fue excluida y retirada, como se explica arriba. Evidencia: `capturas-inventario.json`, `rnf-lamina-*` y `conductor-lamina-*`.

## Entrega

Único archivo nuevo para versionar: **`docs/rediseno/fase3/travesia/reaceptacion-codex.md`**. La evidencia, pruebas de aceptación, copia de análisis y binarios quedan bajo `build/` o en TEMP. **`pubspec.yaml` y `pubspec.lock` no cambian.** El banco cerró al terminar. No hay correcciones de producto pendientes dentro de esta reaceptación; para futuras mediciones, aplicar la salvedad O2 sobre reintentos.

### Tres líneas

1. ACEPTADA con observaciones: H1, H2 y O1 cerrados; los reintentos exigen revisar el conteo real de acciones.
2. RNF Windows: 1.979 / 1.907 / 1.861 s, tres pasos y cero reintentos; suite 1312/0/0 y análisis cero.
3. Solo se añade este informe; producto y pubspec intactos, evidencia en build, sin Git de escritura ni dispositivos/Firebase.

### Mensaje para Yov

Yov: Capitán reaceptó solo la corrección 10.26, commit 53838d7 contra 414568e: ACEPTADA con observaciones. H1 cerrado: 3305 cuadros de dos ciclos con Positioned/offset/tamaño fijos, un Transform y una pintada. H2 cerrado: detector correcto en claro, oscuro y hover; tres corridas Windows por Explorer con rejilla, tres pasos y cero reintentos, 1.979/1.907/1.861 s. El reloj conserva sus extremos y cuenta todas las esperas. O2: pasosDelProducto sigue siendo el literal 3; una corrida con R reintentos tiene 3+R acciones y no debe acreditar tres pasos solo por ese campo. O1 cerrado: reducción por omisión probada, captura con cero avisos y diagnóstico completo con 11 vencimientos explícitos; scripts de capturas/RAM cuentan avisos y Web/Android no esperan reposo del inicio. Suite 1312/0/0 y análisis cero. No se corrigió código. Informe: docs/rediseno/fase3/travesia/reaceptacion-codex.md; evidencia: build/t114-travesia-reaceptacion/.

### Git para Carlos

```powershell
git add -- docs/rediseno/fase3/travesia/reaceptacion-codex.md
git commit -m "Sprint 4: reaceptacion de la correccion de la travesia"
git push
```
