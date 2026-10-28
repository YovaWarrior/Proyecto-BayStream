# ACEPTADA con observaciones · T-124 · Capitán Codex

27 de octubre de 2026. Aceptación de **e3ce0fc**, decisión 10.66, sobre **f4ec264**, implementación de T-124. Base de comparación: **2cce28f**, T-123 aceptada. El HEAD separado y los tres commits coinciden con el encargo. No corregí el producto ni ejecuté escrituras de Git.

**Dictamen:** se aceptan la ficha de la bahía y su grupo, la agrupación de Estadísticas, el singular de la salida y la corrección del conductor Android. Las regresiones exigidas pasan. Queda **O-124-1, P3 preexistente**, una aserción de claves duplicadas en debug con extensiones de veinte pies en filas distintas. No apareció un fallo de esa escena en el banco Web release; se conservan ambos resultados y no se atribuye esa aserción a T-124.

## 1. Método e identidad de la copia

Leí AGENTS.md, CLAUDE.md, las decisiones 10.53, 10.56 y 10.63–10.66, T124-RESULTADOS completo, DESIGN 14.7 y 15 y mi aceptación de T-123. Revisé el diff de T-124: quince rutas, más la decisión en SPRINT-4. El historial está en [historial.txt](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/historial.txt); el [diff completo](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/diff-completo.diff) y la [revisión de código](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/revision-codigo.json) conservan el alcance revisado.

Tomé huellas de **1893 archivos** del árbol, con exclusiones explícitas de compilaciones, Git, cachés y herramientas locales. Copié **783 originales**, sin docs, a `build/t124-aceptacion/banco/copia`. Antes de resolver paquetes, los 783 coincidían; después de `pub get --offline` y **antes de la primera suite**, solo difería el registrador Java generado, declarado en el cotejo. La instrumentación se añadió después de la suite y del análisis. Evidencia: [cotejo previo a la suite](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/cotejo-antes-suite.json).

El cotejo final exige conservar todos los originales cubiertos y permite únicamente este informe nuevo fuera de build. En la copia de ejecución, **lib/, los tests originales y pubspec.* siguen idénticos al árbol**; solo cambian los ajustes Android del banco y se agregan entradas y pruebas propias. Véanse [cotejo final](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/cotejo-final.json) y [cotejo del banco](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/cotejo-banco-final.json).

## 2. Suite, análisis y sondas propias

| Comprobación | Resultado y evidencia |
|---|---|
| Suite original, una sola corrida | **1832/1832**, cero omitidas, errores o fallos; 175.616 s. [Resumen](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/suite-resumen.json), [JSONL completo](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/suite.jsonl). No se repitió. |
| Análisis del producto | `flutter analyze --no-pub lib test`: **cero incidencias**, exit 0, antes de añadir el banco. [Registro](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/analyze.txt), [comando y resultado](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/analyze-resultado.json). |
| Regresión propia de T-122/T-123 | **30 casos funcionales aprobados**: 13 de operación/salida, 5 A1, 4 de arrastre del teléfono y 8 del rediseño/oficina. La invocación conjunta terminó en error al compilar mi archivo T-124; los treinta casos sí terminaron en éxito. No presento esa invocación como exitosa. [Desglose con nombres](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/pruebas-cierre.json), [registro original](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/propias.log). |
| Sondas propias de T-124 | **49 casos distintos aprobados**: 20 de ficha, 3 oráculos numéricos independientes, 24 de Estadísticas/tabla y 2 de singular/plural. Los resultados finales son **47/47** en [matriz-final.jsonl](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/matriz-final.jsonl) y **2/2** en [p3-propias-final.jsonl](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/p3-propias-final.jsonl). [Datos de la matriz](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/propias/t124-propias.json). |
| Conductor O1, sin emulador | `python -B tool/t124_conductor_prueba.py`: **3/3**, comprueba liberación, identificadores distintos y detección de que la celda se levantó. [Registro](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/conductor.txt). |
| Diagnóstico de O-124-1 | **1 reproducción positiva** de la aserción, separada de la matriz funcional; no cuenta como prueba de funcionamiento correcto. [Registro](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/claves-aislado.jsonl). |

Las sondas se conservan como `codex_*_test.dart` en la evidencia. La suite original no recibió esos archivos. La regresión sintética importa tres fuentes, descarga 30, registra dos cargas netas, deshace, asigna un vacío, deja una solicitud pendiente y genera una salida de **32 contenedores exactos**, con 28 pendientes de carga y sin conflictos. Conserva el lleno sin fila en su celda real, sus datos del plan y la ausencia de VGM inventado; el movimiento sin OR no contiene la clave `order`. El vacío numerado y el estado desconocido esperan el listado, incluso si se suministra una fila al borrador. [Resultado funcional](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/propias/pruebas-propias.json), [A1](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/propias/a1-resultados.json).

## 3. P2: la bahía visible y el grupo de su par

**PASA.** En Carga y Contenido, con 21, 22 y 23 elegidas, la ficha comienza por la bahía visible y separa el grupo con **«grupo 22 (21, 22 y 23)»**. Coincide con DESIGN 14.7, incluidas las versiones compactas del teléfono. La 21 tiene 7 contenedores, una reserva y 57.7 t; la 22, **11 contenedores**, cinco reservas y 225.5 t; la 23, tres contenedores y 25.8 t. El grupo de carga tiene 27 pendientes, 20 llenos y siete vacíos. No se confunden las cifras físicas con las del grupo.

Se comprobaron las seis combinaciones en Windows y Web a 1920 × 1080 lógicos, y en Android a 360 × 800 lógicos. Las pruebas propias montan ambos tamaños y ambos modos. La bahía aislada 26 de mi fixture de un solo contenedor conserva el texto sin «grupo». No se usa como caso aislado la 26 del plan T-122, que sí se agrupa con la 25.

Evidencia: [Windows, 22 en Carga](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/windows/ficha-22-carga.png), [Android, 22 en Contenido](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/android/ficha-22-Contenido.png), [seis escenas Web](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/web/ficha124-claro-100-resultados.json) y la matriz propia citada arriba.

Para la par sin carga propia construí **T124_PAR_TRANSITO.edi**, enteramente sintético: dos veinte pies por cargar en 21 y 23, y un cuarenta de paso en 22. En release se probaron **12 escenas**: 1920 × 1080 y 360 × 800, los dos modos y las tres selecciones. La 22 conserva su propio contenedor de 20.6 t y el grupo nombra las tres bahías con dos cargas pendientes. Los dos veinte ocupan **filas diferentes**, el caso que activa la observación debug descrita después. [Resultado release](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/web/edge-resultados.json), [oficina](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/web/par-transito-release-1920-Carga-22.png), [teléfono](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/web/par-transito-release-360-Contenido-22.png).

## 4. Estadísticas, tabla y singular

**PASA.** Cada impar se suma a la par que la cubre. Mis oráculos calculan por separado los grupos esperados y contrastan contenedores, cubierta, bodega y peso efectivo; no llaman al mismo formateador para obtener las sumas esperadas.

| Entrada | Resultado |
|---|---|
| T100_LLEGADA | **Tres columnas: 02, 06 y 10**, veinte contenedores por grupo: dos en cubierta y dieciocho en bodega. Pesos exactos: 244650, 321650 y 398650 kg; total **964950 kg**. Cada columna mide su tope de **168 dp** a letra 1 en oficina y el casco queda centrado, sin desplazamiento. |
| T99_SINTETICO_977 | **24 columnas**, 02, 06…94; la suma sigue en **977**, peso total 8366089 kg. La tabla conserva las veinticuatro filas y los totales. |
| Plan T-122 | Las impares con carga propia aportan al grupo correcto; los grupos 22 y 26 suman 21 y cuatro contenedores. |

Las tablas coinciden fila por fila con las columnas, incluidos zona y peso. Tocar 02 abre 02 en el plano. Se probó en los tres clientes; las sondas cubren **1920, 1366 y 360**, letras **1 y 2**, y **ambos temas**, sin cortes de texto. Chrome visible comprueba además las dos entradas a **1366 con letra 2.0**, tabla y gráfico. Los redondeos de toneladas se contrastan con la suma en kg; sumar las cifras ya redondeadas de T100 no es el oráculo del total.

Evidencia: [Windows T100](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/windows/estadisticas-t100.png), [Windows tabla 977](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/windows/estadisticas-977-tabla-bahias.png), [Web T100](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/web/estadisticas124-claro-final-100-resultados.json), [Web 977](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/web/estadisticas124-claro-final-977-resultados.json), [Android](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/android/estadisticas-resultados.json).

**P3 del encargo, PASA:** la salida muestra «**1 contenedor a bordo en la salida.**» y, para dos, «2 contenedores…». Hay dos pruebas propias y comprobación nativa del singular en Windows y Android después de cargar el lleno sin listado. [Windows](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/windows/salida-singular.png), [Android](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/android/salida-singular.png).

## 5. O1 y regresiones en los tres clientes

**O1 se cierra.** El conductor nuevo importa el `dedo` del HEAD, garantiza UP en `finally`, cambia el trackingId y exige que la celda esté levantada. El banco conserva sus bytes; respecto de Git solo hay la conversión preexistente LF/CRLF, sin cambio de contenido. [Identidad del conductor](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/conductor-identidad.json).

En **emulator-5554**, el gesto nuevo levanta el contenedor, desplaza al borde y confirma **022-10-82 → 022-09-84**, la celda observada bajo el dedo. Cancelé el cambio. Además provoqué una excepción dentro del contexto real de contacto: la traza muestra DOWN seguido de UP, con un identificador nuevo. Ese control falla inmediatamente después de DOWN; no lo presento como un arrastre completo. [Traza y resultado](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/android/h7-resultados.json), [confirmación observada](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/android/conductor-nuevo_h7_al_soltar.png).

| Cliente | Regresiones observadas |
|---|---|
| Windows release, abierto mediante `explorer.exe` | H4: lleno TSTU0220071 sin fila; aviso de la salida. H6: vacío TSTU0012123 asignado a 0210084, disponible en OR, búsqueda con celda, Lista y resaltado. H7 con mouse al 150 %, feedback y autodesplazamiento, destino **022-09-82**, cancelado. Fichas, variante de solo icono y botón **Acciones**, nombre MSAA único y menú abierto. |
| Chrome release visible, perfil temporal propio | H4 y sus bloqueos A1, H6 completo y salida. H7 con mouse al **100 y 150 %**, levantamiento, borde y confirmación **022-09-82**, cancelada. Las fichas se verifican a 1920; el caso especial añade 360 × 800. |
| Android, paquete aislado t124acc | H4 lleno sin fila y vacío no ofrecido sin listado; singular. H6 en OR, búsqueda con celda y resaltado. H7 y liberación del conductor descritos arriba; las seis fichas a 360 × 800. La Lista nativa de H6 se documenta en Windows/Web; no atribuyo una captura de esa tarjeta al Android de esta ronda. |

Evidencia: [Windows H4](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/windows/h4-confirmacion.png), [H6 en Lista](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/windows/h6-lista-vacio.png), [H7](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/windows/h7-confirmacion.png), [Acciones](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/windows/acciones-con-nombre.txt), [regresión Web](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/web/carga-claro-verificado-100-resultados.json), [H7 Web 100](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/web/h7-claro-sin-captura-100-resultados.json), [H7 Web 150](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/web/h7-claro-sin-captura-150-resultados.json), [Android H6](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/android/h6fin-resultados.json).

Las sondas widget conservan H7 en teléfono y oficina, con dedo y mouse, 100/150 %, borde horizontal y vertical de la columna completa, hit test, feedback y destino exacto. También verifican las fichas y la variante de icono con letra ampliada. [Resultados del rediseño](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/propias/mezcla-propia.json).

## 6. Las siete expectativas de T-121

**No se aflojaron.** Revisé las aserciones, no solo el número de pruebas:

1. El 977 conserva sus sumas por estado, puerto, naviera, tamaño y peso; bahías pasa de 72 físicas a la **lista exacta de 24 referencias**.
2. T-117 pasa de contener vecinas a exigir **exactamente 02 y 06**.
3. Oficina en ambos temas conserva protagonista, paneles, semántica, contraste, texto, barra y desplazamiento; cambia el número de referencias.
4. El extremo del 977 pasa de 95 a **94**, con rectángulo completo, ancho mínimo y selección todavía medidos.
5. El caso de nueve columnas usa nueve pares independientes: conserva ancho útil, dos temas/magnitudes, 1366, letra 2 y ausencia de cortes.
6. El caso de altura conserva **1.5 veces**, base de 56 dp, teléfono y barra. Sus 72 pares independientes evitan reducir inadvertidamente la muestra a 24.
7. El caso de 72 columnas mantiene desplazamiento, extremo alcanzable y selección; la nueva cola es **286**.

La relación exacta está en `expectativasT121` de la revisión de código. Las siete se ejecutaron dentro de la única suite original aprobada.

## 7. Observación y límites de la evidencia

### O-124-1 · P3 · Claves duplicadas preexistentes en el plano debug

**Reproducción:** montar el plano de oficina con veinte pies por cargar en **0210282** y **0230482**, y un cuarenta de paso en **0220682**. Los dos marcadores de ocupación vecina comparten `ValueKey('neighbor-twenty')` dentro del mismo Row; Flutter debug informa **Duplicate keys** y después errores de desmontaje. La clave está en `bay_plan_view.dart`, línea 1916. El archivo es idéntico en Git entre 2cce28f y e3ce0fc: **no lo introdujo T-124**.

**Impacto y prioridad:** P3 para corregir por separado la identidad de los marcadores en debug. La escena sintética con esas mismas posiciones pasa las doce comprobaciones release de este informe; esa comprobación limita el alcance observado, sin demostrar que toda combinación release sea inmune. No modifiqué el código. Evidencia: [errores capturados](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/propias/claves-duplicadas.json), [origen comprobado](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/observacion-claves-origen.json), [sonda reproducible](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/codex_t124_claves_test.dart) y el caso release de la sección 3. La matriz debug funcional usa ambos veinte en la misma fila; conserva el requisito de par solo de paso con carga en las dos impares, sin ocultar la variante que falla.

**Transparencia del instrumento.** Se preservan los intentos fallidos. Mis archivos nuevos necesitaron corregir importaciones y montaje del tema; una llamada enfocada desde la raíz apuntó a un test inexistente y ejecutó **cero casos**, sin alterar los originales. Hubo un primer montaje del caso de claves duplicadas que produjo errores en cascada, después aislados. Los dos casos de singular se ejecutaron finalmente con el tema correcto. Nada de esto repitió la suite original ni cambió el producto.

En Chrome, las capturas realizadas con el botón pulsado intercalaban movimientos de puntero con **buttons=0** y perturbaban el arrastre. Las trazas conservan ese contraste: al suprimir las capturas intermedias no hubo esos movimientos y H7 pasó en ambos zooms. En los gestos finales se guardan imágenes antes/después y metadatos durante el contacto; **no hay PNG intermedio de esos dos éxitos**. También se corrigieron el conteo duplicado de nodos ARIA, la escala propuesta y un servidor auxiliar bloqueado al llenar su pipe de registros. No cuento esos fallos como defectos del producto.

En Android, la vista **360 × 800 lógica** de las fichas se obtuvo con `wm size`; la imagen física seguía letterboxed en 1080 × 1920. Ese desfase invalidó la primera comparación de píxeles del conductor. Restauré el tamaño físico original antes del H7 aprobado, realizado a **360 × 640**. La fuente, densidad y tamaño finales coinciden con los iniciales. En Windows, la ventana física capturada mide 1582 × 853 y contiene mediante FittedBox la vista lógica 1920 × 1080; para H7 se usó la vista corta del banco. No presento los píxeles de esas capturas como resolución física 1920 × 1080.

El control de escritorio no pudo inicializar su kernel; utilicé el permiso 10.41 para scripts con guarda de PID/ruta y límites de la ventana del banco. El padre Explorer ya no existía al inspeccionarlo: se acredita el comando de apertura con `explorer.exe`, sin inventar una identificación viva del padre. Los bancos Web con el panel T-122 conservan el **Error inicial** ya documentado en O2 de T-123. No repetí el control T-99 en T-124 ni afirmo haber aislado ahora la instrucción del panel que lo origina.

## 8. Aislamiento, huellas y entrega

El almacén Windows es **`build/t124-aceptacion/banco/almacen`**, namespace **t124acc**, con ruta explícita y guarda en la entrada del banco. No usa el almacén de la app instalada. Android usa el paquete separado `gt.cmartinez.baystream.t124acc`; Chrome, perfiles temporales propios y servidores localhost. Los roles, sesión y publicación del banco son simulados localmente; no hubo inicio de sesión ni Firebase. Solo se usaron T-122, T100, T99_SINTETICO_977 y el caso sintético adicional; no se accedió ni copió el corpus. No se tocaron Honor, piloto, otras carpetas de producto, apps instaladas ni publicaciones.

Los binarios Windows, Web y APK se compilaron en serie dentro de la copia. La versión Web sigue **3.1.1+5**. Para comprobar letra 2 se añadió ese control **solo al panel Web privado** y se generó otro directorio de salida; el caso especial tiene su tercera entrada Web. Se conservan fuentes y huellas distintas. El banco Windows quedó cerrado por su PID verificado; Chrome y servidores propios quedaron cerrados; el emulador que se había iniciado para esta aceptación quedó apagado sin guardar snapshot, con sus ajustes restituidos. El APK de banco y la evidencia se conservan.

**Reglas comprobadas:** el diff de T-124 no cambia domain/, data/, lib/main.dart, opciones de Firebase, reglas, congelados, lista del piloto ni pubspec.*; no agrega `// ignore:`. **Codex tampoco modifica pubspec.yaml ni pubspec.lock.** El punto 5 de Timonel sobre vacíos asignados es una propuesta: no se implementó ni se aceptó como comportamiento nuevo. H6 se verificó únicamente como regresión existente.

El [resumen.json](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/resumen.json) identifica los resultados finales. El [manifest.json](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/manifest.json) enumera tamaño y SHA-256 de la evidencia y la huella externa de este informe. Excluye `banco/` y `__pycache__/`, que contienen copias, perfiles, almacenes y compilaciones; los binarios usados tienen huellas separadas en [binarios-huellas.json](C:/Proyectos/baystream-qa-r4/build/t124-aceptacion/binarios-huellas.json). El manifiesto no se incluye a sí mismo. El cotejo de originales cubre las fuentes del producto aunque la copia de ejecución quede fuera del manifiesto.

**Archivo de entrega fuera de build:** únicamente `docs/t124/aceptacion-codex.md`, nuevo. Carlos lo copia a la misma ruta del rediseño. No lo añadí a Git. Evidencia y scripts propios quedan bajo `build/t124-aceptacion/`, ignorado por Git; no se propone forzarlo.

**Tres líneas para Carlos:**

T-124 ACEPTADA con observaciones: ficha, grupos de Estadísticas, singular y conductor comprobados.
Suite 1832/1832 una vez, cero omitidas; análisis cero y regresión sintética en los tres clientes.
Producto intacto; queda O-124-1 P3 preexistente en debug, con release del caso comprobado.

**Mensaje para Yov:** «T-124 aceptada con observaciones sobre e3ce0fc. Suite 1832/1832 una vez y análisis cero en copia cotejada; P2, Estadísticas, singular y O1 pasan, con H4/H6/H7 en los tres clientes. Queda P3 preexistente de claves neighbor-twenty duplicadas en debug; la misma escena release pasa. Informe, matriz y manifiesto en qa-r4, sin correcciones del producto ni escrituras de Git. Carlos decide.»

**Bloque para Carlos, después de copiar el informe al rediseño**, para integrar con su siguiente decisión. Solo se incluye mi ruta; Carlos añade por separado su decisión si corresponde:

```powershell
Set-Location -LiteralPath C:\Proyectos\baystream-rediseno
git add -- docs/t124/aceptacion-codex.md
git commit -m "Sprint 4: aceptacion de T-124 con observaciones"
git push origin sprint-4
```

ALTO: Carlos decide
