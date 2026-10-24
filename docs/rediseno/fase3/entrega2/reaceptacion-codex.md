# T-114 · Fase 3, entrega 2 · Reaceptación de la corrección

**Dictamen: NO PASA el cierre completo de 10.21.** Capitán Codex, 23 de octubre de 2026.

H1, H2 y H3 están corregidos. También queda acreditado el hito de RNF-002 Android: los cinco finales nuevos muestran celdas dentro de tres pasos y menos de 30 segundos. El pendiente es más acotado: la entrega declara que Carga a 360 × 640 todavía necesita un gesto, mientras 10.21 pide la primera rejilla sin desplazar. El texto añadido a DESIGN.md describe esa excepción, pero no demuestra que se haya cumplido el requisito ni sustituye una decisión de Carlos sobre él. No rechazo las nuevas mediciones por este motivo.

La revisión se limita a `52dd1b6..74802b6`, en `C:\Proyectos\baystream-qa-r4`, HEAD `74802b62331a9f1dead051c97fce4053ecf8e643`. Se leyeron AGENTS.md, 10.21, la sección «Fase 3 · Entrega 2 · Corrección tras la aceptación de Codex» y las reglas pertinentes de DESIGN.md. Se aplicó la auditoría de la skill flutter-ui. Flutter se ejecutó de uno en uno con autorización de Carlos.

Evidencia propia: `build/t114-entrega2-reaceptacion/`. No se modificaron producto, pruebas versionadas ni instrumentos. No se ejecutaron escrituras de Git ni `git status`; no hubo sesión de Firebase, Honor ni emulador. Las pruebas de operación usan repositorios en memoria.

## 1. Alcance

`git diff --stat 52dd1b6..74802b6`: **66 archivos, 5457 inserciones y 241 eliminaciones**. Las rutas no incluyen `domain/`, `data/`, `lib/main.dart`, `pubspec.yaml`, `pubspec.lock`, `lib/latency_test_screen.dart` ni `lib/c3_reconciliation_screen.dart`.

`test/t114_fase3_correccion_test.dart`, la prueba de 10.15, es idéntica en ambos commits, contrastada con `git show`. La nueva prueba es otro archivo: `test/t114_fase3_entrega2_correccion_test.dart`. Hay 11 archivos de producto en `lib/` en el cambio. Evidencia: `alcance.txt`, `rutas.txt`, `producto.diff` y `comprobaciones-finales.json`.

## 2. H1–H3 y reproducciones propias

Se volvió a ejecutar la reproducción original de `build/t114-entrega2-aceptacion/comprobacion_propia_test.dart`, copiada a la carpeta de esta revisión. Solo se cambió la ruta del JSON de salida para conservar la evidencia anterior. **16 pruebas correctas**, sin fallos. Fuentes reales del producto cargadas en el ensayo.

| Punto | Resultado y evidencia |
|---|---|
| H1 | Buscar queda dentro de pantalla y recibe el toque a **360, 600 exactos y 1920 dp**, cada ancho con letra **1.0, 1.45 y 2.0**, sin excepciones de desbordamiento. La cabecera distribuye sus controles mediante `Wrap`. |
| H2 | La reproducción anexa una carga a la bitácora, observa el estado naranja en la celda y su extinción a los **1.5 s**, en los tres anchos. La prueba nueva de la entrega cubre además **llenos y reservas con vacío asignado**, siguiendo la bitácora, sin inyectar `recienMovidoProvider`. `LoadingCell` recibe el estado y la resolución de posición contempla las reservas `R:`. |
| Movimiento reducido | La prueba entregada mantiene la celda quieta al avanzar el reloj con `disableAnimations`, conservando la señal de color durante su plazo. Forma parte de las 1260 ejecutadas. |
| H3 | A 360 y 600 existe la región accesible del movimiento aunque no haya panel lateral. A 1920 queda una sola región, la del panel. El anuncio identifica al autor por **Muelle/Oficina**, sin nombre, correo ni UID. El contenedor y su posición siguen siendo datos operativos del movimiento. |

La prueba nueva inspecciona también la semántica accesible, no solo el widget decorativo. Esto acredita el árbol de semántica de Flutter; no se afirma haber escuchado TalkBack o un lector real, porque no se operó ningún dispositivo.

Las reproducciones también conservan las tres comprobaciones del menú Más y la de caché del tema: un rebuild idéntico mantiene ThemeData; cambiar tema o densidad lo sustituye. Evidencia: `reproducciones.txt`, `pruebas-propias.json` y el archivo de prueba propio.

## 3. H4: medición corregida y excepción pendiente de Carga

Se inspeccionaron **los 35 cuadros nuevos**, siete por corrida, incluidos los del selector. Los cinco finales muestran celdas de la rejilla. En algunos aún se aprecia la transición del selector, pero las celdas ya son visibles; no se tomó como hito una silueta sin rejilla. Los registros documentan tres acciones, sin desplazamiento adicional. Las marcas de acciones del host no se confundieron con la medición por PTS.

| Corrida | Cuadro final | Cotas recalculadas, segundos | Pasos |
|---|---:|---:|---:|
| sin01, primera tras instalación y borrado de datos según registro | 66 | 4.911–4.984 | 3 |
| sin02 | 53 | 2.954–3.202 | 3 |
| sin03 | 61 | 2.922–2.959 | 3 |
| sin04 | 65 | 2.956–2.997 | 3 |
| sin05 | 59 | 2.845–2.894 | 3 |

Coinciden con **4.91–4.98 s** en la primera y **2.85–3.20 s** en las restantes. Las cotas se recalcularon desde los PTS y los cuadros vecinos. Cumplen el umbral de tres pasos y 30 s para el recorrido medido, que termina en el **previo**. No se repitió una corrida en el emulador: se revisó la evidencia entregada, como pidió Carlos. Evidencia: `rnf-recalculado.json`, `imagenes.json` y cinco láminas `sin01-cuadros.png` a `sin05-cuadros.png`.

**La distinción sobre Carga es necesaria:**

- El H4 original de `aceptacion-codex.md` denunciaba una medición cuyo final no mostraba celdas. **Ese defecto está resuelto** en las cinco corridas nuevas.
- La decisión **10.21** pide además: «a 360 × 640 la primera rejilla se ve sin desplazar, dentro de los tres pasos».
- La nueva redacción de **DESIGN.md 13.8**, líneas 1162–1164, limita la visibilidad sin desplazar a previo y Descarga, y dice que en Carga «queda a un gesto, como antes». El informe de Timonel, sección 4c.7, declara que faltan 14 dp y deja la decisión a Carlos.

Por tanto, **un gesto en Carga cumple la excepción escrita en el DESIGN actual, pero no el requisito sin desplazamiento de 10.21**. Es el mismo problema de acceso inicial al plano en ese modo; no es el mismo fallo de validez de los nuevos tiempos RNF-002. Incorporar la excepción al documento en el propio commit corregido no acredita una aprobación específica de Carlos.

Como contraste independiente se ejecutaron dos diagnósticos de Carga a 360 × 640, letra 1.0 y barra de estado de 24 dp, sin gesto: un buque manual sintético de 288 contenedores y el sintético T-99 de 977. Se confirmó el modo Carga y la presencia de su resumen. En esos casos la primera celda horizontalmente dentro de pantalla sí cabe: **338.2–390.2** y **302.2–354.2**, respectivamente, en un área que termina en **403 dp**. **No reproduje los 14 dp faltantes declarados por Timonel**; esos dos casos no justifican afirmar que todas las configuraciones de Carga cumplen. Los diagnósticos registran geometría y no convierten la ausencia de un fallo en esos datos en una aceptación general. Evidencia: `complemento.json`, `complemento_test.dart` y `complemento.txt`.

**Pendiente para cerrar:** identificar y acreditar el caso de Carga de los 14 dp con rejilla visible sin gesto, o registrar una decisión explícita de Carlos que acote 10.21 a previo/Descarga y acepte la excepción de Carga. Este informe no cambia el diseño ni toma esa decisión. El bloqueo es la discrepancia de alcance y la falta de acreditación de ese caso, no una afirmación de que mis dos diagnósticos hayan fallado.

## 4. Riel y zoom

El riel utiliza `CustomScrollView` y `SliverFillRemaining`, con ancho calculado para sus rótulos. El diff elimina `IntrinsicHeight`; las pruebas nuevas cubren ventanas bajas. El chip de zoom vive en la línea de controles mediante `ZoomDelPlano`, fuera del lienzo.

La comprobación complementaria en **360, 600 y 1920 dp** confirma chip alcanzable y rectángulos sin intersección con la rejilla, sin excepciones de layout. La suite entregada añade los casos de letra 1.45 y 2.0 a 360 dp. Los cinco casos finales del complemento pasan: tres verifican zoom/riel y dos son los diagnósticos geométricos de Carga descritos arriba. No se presentan estos últimos como dos pruebas del requisito universal de H4.

El zoom ahora se conserva al cambiar de bahía y se reinicia al cerrar/cambiar el viaje, tal como declara la entrega. Se registra ese cambio de comportamiento, sin atribuirle un fallo no observado.

## 5. Suite, análisis y conservación de aserciones

- `flutter test --no-pub --reporter json`: **1260 éxitos, 0 fallos, 0 omitidas**; salida correcta. `suite.jsonl` y `suite-resumen.json`.
- Reproducción original contra el código nuevo: **16/16**. `reproducciones.txt`.
- Complemento final de esta revisión: **5/5**, con los límites del diagnóstico ya indicados. `complemento.txt`.
- `flutter analyze --no-pub`: **No issues found**, salida 0. `analyze.txt`.

El primer análisis incluyó las pruebas auxiliares generadas bajo `build/` y encontró **20 incidencias de los propios arneses**, no del producto: imports y funciones auxiliares sin uso. Se conserva en `analyze-con-arneses.txt`. Para analizar la entrega se creó temporalmente `build/analysis_options.yaml`, excluyendo únicamente ese árbol de evidencia generada; se repitió el comando y se retiró el archivo. No se cambió la configuración versionada ni se ocultaron incidencias de `lib/`, `test/` o `tool/`.

En la preparación del complemento hubo intentos no válidos por selectores del arnés y por su codificación; no se contaron como fallos de producto ni como validaciones. El archivo final y su log corresponden a la ejecución válida.

Se comparó `test/t114_fase3_plano_test.dart` antes y después mediante Git. La aserción `alto > altoAntes + 100` fue reemplazada por `alto > altoAntes + altoDeLaCabecera - 1`: ahora mide la altura real de la silueta compacta que se retira. Conserva las aserciones de salida y regreso de la cabecera y de presencia de banda y barra inferior. **No hay aserción perdida sin reemplazo**; el umbral fijo de 100 dejó de corresponder a la cabecera nueva. La prueba de 10.15 permanece idéntica.

## 6. Auditoría e idioma/Material 3

Se repitió `flutter_ui_audit.py . --all` y se comparó con una copia de lectura de `lib/` en `52dd1b6`.

| Resultado | Base | Corrección |
|---|---:|---:|
| Críticos globales del instrumento | 17 | 17 |
| Avisos globales | 249 | 248 |
| Informativos | 20 | 20 |

**Cero críticos nuevos y cero avisos nuevos en lo tocado.** Solo desaparece `PERF_INTRINSIC_SIZE` de `navegacion_del_viaje.dart`. No se afirma que el repositorio entero tenga cero críticos: persisten los hallazgos preexistentes del instrumento. Evidencia: `audit.txt`, `audit-base.txt`, `auditoria-delta.json`.

Los censos T-112 se volvieron a ejecutar: **1932 cadenas visibles**, 1801 en español y 131 sin idioma; **0 en inglés**. Material 3: **250/7/3**, sin excepciones nuevas. Mensajes: **217**, todos con causa y acción; los 12 de parseo EDIFACT identifican segmento. El diff del instrumento añade el nuevo archivo de zoom y clasifica sus textos, sin sustituir las reglas de medición. Evidencia: `censos-ejecucion.txt` y `censos/`.

## 7. Capturas y datos

El cambio incorpora **35 imágenes JPEG de RNF-002 Android**; no incorpora una nueva matriz PNG de Windows/Web/Android del plano. Se revisaron visualmente todas las imágenes nuevas, no solo los finales, y se inventariaron con SHA-256. Las comprobaciones de tamaños restantes se sustentan en las pruebas de widgets y código, no en capturas nuevas inexistentes.

En los 35 cuadros no se observan correos, UID, cuentas ni archivos del corpus. El selector muestra `T99_SINTETICO_977.edi`; no aparece `CORPUS_A01.edi` ni otro archivo del corpus. Buque y contenedores visibles son sintéticos. No aparece la pantalla «Nube y cuenta» en esos cuadros.

Precisión sobre los registros: `captura.json` sí contiene la etiqueta semántica **«Nube y cuenta · Solo este dispositivo»** en su inventario de interfaz. Eso no es un correo/UID ni evidencia de haber abierto una cuenta, pero impide afirmar que esa cadena no existe en ningún archivo nuevo. La revisión de privacidad visual no se confundió con una búsqueda literal en JSON.

## Entrega

Único archivo nuevo para versionar: **`docs/rediseno/fase3/entrega2/reaceptacion-codex.md`**. Evidencia propia, pruebas auxiliares y referencias de lectura: `build/t114-entrega2-reaceptacion/`, enumeradas en `manifiesto-evidencia.csv`. `build/` está ignorado; no se propone forzarlo a Git. **`pubspec.yaml` y `pubspec.lock` no cambiaron.** El diff final de archivos versionados permanece vacío; Git solo avisa sobre conversión LF/CRLF de los generados Windows, sin diferencia de contenido.

Tres líneas para Carlos:

1. NO PASA el cierre completo de 10.21: queda por acreditar o decidir la excepción de Carga a 360 × 640.
2. H1–H3 y RNF-002 corregidos; suite 1260/0/0, análisis 0, auditoría sin hallazgos nuevos y M3 250/7/3.
3. Producto intacto; informe en docs y evidencia propia en build/t114-entrega2-reaceptacion/.

Mensaje para Yov:

> Yov: Capitán Codex revisó 74802b6 contra 52dd1b6 en la copia limpia. H1–H3 pasan con las reproducciones originales; los 35 cuadros nuevos y los registros acreditan RNF-002 Android en tres pasos, 4.911–4.984 s la primera y 2.845–3.202 s las demás. Suite 1260/0/0, analyze 0, sin hallazgos nuevos de auditoría y M3 250/7/3. Dictamen NO PASA para cerrar íntegramente 10.21: DESIGN 13.8 ahora admite un gesto en Carga, contrario al requisito sin desplazar; el informe de Timonel declara 14 dp pendientes. Mis dos diagnósticos de Carga sí caben y no reproducen esos 14 dp, por lo que no afirmo un fallo universal: falta acreditar aquel caso o una decisión explícita de Carlos sobre la excepción. RNF-002 en previo sí queda resuelto. Informe: docs/rediseno/fase3/entrega2/reaceptacion-codex.md. No modifiqué producto ni ejecuté Git de escritura.

Comandos para que **Carlos** versione únicamente el informe:

```powershell
git add -- docs/rediseno/fase3/entrega2/reaceptacion-codex.md
git commit -m "Sprint 4: reaceptacion de correcciones T114 entrega 2"
git push
```
