# T-114 · Fase 3, entrega 2 · Aceptación de Capitán Codex

**Dictamen: NO PASA.** Fecha: 23 de octubre de 2026, Guatemala.

La suite, el análisis, la caché del tema y la verificación Web pasan. La entrega conserva cuatro problemas que impiden aceptarla: Buscar queda fuera de la pantalla a 600 dp con letra 2.0; las celdas de Carga no reciben el estado recién movido; el anuncio accesible de «En vivo» falta por debajo de 1200 dp; y los cuadros finales de RNF-002 en Android no muestran la rejilla. No se corrigió código del producto.

Trabajo realizado exclusivamente sobre el código de `C:\Proyectos\baystream-qa-r4`, HEAD `9522794e64a8a5f3bd39a2f91716a90539573f85`, comparado con `ccc8c2f`. Se leyeron AGENTS.md, las decisiones 10.14–10.20 de SPRINT-4.md y su marco de alcance, DESIGN.md 7–10 y 13, la entrega 2 de REDISENO-RESULTADOS.md y su traspaso. Se respetaron las excepciones de 10.20. Timonel estaba detenido y Carlos autorizó los comandos de Flutter, ejecutados uno a la vez.

Evidencia propia: [build/t114-entrega2-aceptacion/](../../../../build/t114-entrega2-aceptacion/). Los archivos de producto, pruebas del repositorio e instrumentos originales permanecen sin cambios. No se ejecutaron escrituras de Git, `git status`, publicaciones, inicio de sesión, Firebase, Honor ni emulador. La repetición Windows utilizó el banco T-99 sin Firebase, con almacén temporal propio, descrito más abajo.

## Hallazgos que deben resolverse

### H1 · Buscar queda inalcanzable a 600 dp con letra 2.0

La cabecera de oficina coloca título, estado, segmentos Descarga/Carga, Buscar y Nube en un `Row`. Los elementos de ancho fijo consumen más espacio del disponible. En la reproducción con las fuentes reales, ventana de 600 × 960 y letra 2.0, Buscar ocupa `x=624.9…672.9`: queda enteramente fuera de los 600 dp y no recibe el toque. Flutter informa un desbordamiento de 137 píxeles. A letra 1.45 aparece otro desbordamiento de 31 píxeles; Buscar aún se puede tocar, pero la cabecera ya se recorta.

Es visible también en la evidencia entregada: [600 dp, letra 2.0, claro](despues-windows/600x960_claro_letra2.0_plano.png). Falta Buscar y desaparece el título del buque. No hay otra entrada de búsqueda en «Más». Nube conserva la entrada del pie del riel. Esto incumple navegación y RNF-003; no está entre las cuatro excepciones de 10.20.

Origen: `lib/features/vessel/presentation/pages/vessel_overview_page.dart`, `_CabeceraDeOficina.build`, línea 1139. Reproducción: `comprobacion_propia_test.dart`, casos «Buscar visible 600.0», y `pruebas-propias.json`. Los mismos controles pasan a 360 y 1920 dp, con letra 1.0, 1.45 y 2.0; a 600 pasan con 1.0.

Corrección propuesta para la siguiente intervención: distribuir o replegar la cabecera según el ancho y la escala de texto, manteniendo Buscar accesible; conservar pruebas en el punto exacto de 600 dp.

### H2 · Una carga registrada no enciende su celda en naranja

La reproducción usa la bitácora en memoria que emite cambios de T-75 y la operación sintética de T-76. Primero descarga los dos ocupantes de llegada; después anexa una carga válida de `FULL0001234`, OR 1, en `0030282`. No se llama artificialmente a `marcar`.

El provider sí registra `FULL0001234` como recién movido. La celda pasa a «Cargado», pero su estado sigue siendo `BsEstadoDeCelda.ninguno`; hay **cero celdas recién movidas** a 360, 600 y 1920 dp. El reloj mantiene el provider antes de 1500 ms y lo apaga después: el problema es la conexión con la celda, no la duración.

Origen: `bay_plan_view.dart:1334` construye `LoadingCell` sin transmitir el estado reciente; `loading_controls.dart:945` y su `BsCelda` en la línea 975 solo aplican categoría pendiente/hecho. La ruta normal de contenedor sí contempla `recienMovido`. La prueba entregada en `t114_fase3_plano_test.dart:363` inyecta directamente el provider y ejercita esa otra ruta; por eso no detecta el fallo de Carga.

Evidencia: `pruebas-propias.json`, entradas `carga-360.0`, `carga-600.0` y `carga-1920.0`, con estado de cada celda y reloj; log `pruebas-propias.txt`.

Corrección propuesta: propagar la identidad del movimiento real a `LoadingCell`, incluidos llenos y reservas asignadas, con una prueba de integración desde la bitácora hasta la celda. Mantener 1.5 s y la reducción de movimiento.

### H3 · El anuncio accesible del movimiento falta en teléfono y a 600 dp

Con la misma carga real, a 1920 dp hay una región en vivo que anuncia «Cargado, Muelle, FULL 000123 4 · 003-02-82, ahora». No contiene el nombre sintético del autor. A 360 y 600 dp no existe el panel ni ninguna región en vivo para ese movimiento.

`VesselOverviewPage` monta el panel lateral únicamente desde 1200 dp (`vessel_overview_page.dart:127` y `:262`). `EnVivoDelViaje` solo se incorpora dentro de ese panel (`:1277`). La etiqueta de una celda no sustituye un anuncio de región en vivo para una persona que tiene el foco en otro control.

Evidencia: `pruebas-propias.json`, campos `paneles` y `anuncios` de las tres cargas. La inspección también confirma `Semantics(liveRegion: …)` en las filas de `BsPanelEnVivo`.

Corrección propuesta: proporcionar el anuncio accesible también en los diseños sin panel lateral. No requiere inventar equipos ni mostrar nombres; el rol Muelle/Oficina basta. Esta observación exige el anuncio, no imponer un panel visual de escritorio en el teléfono.

### H4 · RNF-002 de Android termina antes de mostrar la rejilla

Se revisaron **los 35 JPEG**, no solo los cinco elegidos como fin. Los cuadros finales propuestos son 72, 58, 53, 55 y 48 de `sin01` a `sin05`. Muestran el previo, los avisos, los controles, la silueta y la leyenda; **no muestran ninguna celda de la rejilla de estiba**. Ejemplo: [sin01, cuadro 72](rnf-002/android/sin01/cuadro-00072.jpg).

Las cotas 3.06–3.88 s están bien calculadas a partir de los PTS, pero corresponden a que la imagen se parece al cuadro final, no a una rejilla visible. El propio `t114_primera_cuadros.py` entrega una propuesta que exige revisión visual. Poder desplazar después la cabecera, como se implementó para 360 × 640, no demuestra el límite de tres pasos: ese desplazamiento adicional debe contabilizarse y el reloj debe terminar con la rejilla visible.

No se afirma que Android tarde más de 30 s: **esa medición válida no está acreditada**. No se abrió el emulador, por instrucción de Carlos.

Corrección propuesta: hacer visible la primera rejilla dentro del recorrido permitido y repetir las cinco corridas de Android, conservando los cuadros que demuestren el hito real. Los datos personales no son la causa de este hallazgo.

## 1. Alcance y commits

`git diff --stat ccc8c2f..HEAD`: **272 archivos, 11228 inserciones y 1702 eliminaciones**. Los tres commits son:

| Commit | Contenido |
|---|---|
| `d1ce1db` | Entrega del plano y navegación; 53 archivos. |
| `f62f709` | Caché del tema; `lib/core/app.dart` y prueba nueva. |
| `9522794` | Evidencia y decisión 10.20 en SPRINT-4.md. |

No aparecen cambios en `domain/`, `data/`, `lib/main.dart`, `pubspec.yaml`, `pubspec.lock`, `lib/latency_test_screen.dart` ni `lib/c3_reconciliation_screen.dart`. Confirmado por rutas, no solo por el resumen estadístico. Evidencia: `commits.txt`, `diff-stat.txt`, `diff-nombres.txt`, `alcance.json`.

## 2. Suite, análisis y los 19 archivos de prueba

| Comando ejecutado | Resultado | Evidencia |
|---|---|---|
| `flutter pub get` | Correcto. | `pub-get.txt` |
| `flutter test --no-pub --reporter json` | **1242 éxitos, 0 fallos, 0 omitidas**. | `suite.jsonl`, `suite-resumen.json` |
| `flutter analyze --no-pub` | **No issues found**. | `analyze.txt` |
| `flutter test --no-pub build/t114-entrega2-aceptacion/comprobacion_propia_test.dart --reporter expanded` | **11 éxitos y 5 fallos de contrato**: dos escalas a 600 dp y tres casos de carga/anuncio. | `pruebas-propias.txt`, `pruebas-propias.json` |

La última fila es un arnés propio y separado: no altera ni sustituye los 1242 resultados del repositorio. Sus fallos reproducen H1–H3. La caché y las tres comprobaciones de «Más» pasan en ese arnés. Los primeros borradores del arnés se corrigieron antes de esta ejecución final; no se atribuyeron sus errores de preparación al producto.

Se leyó el `git show` de cada archivo modificado; las 19 diferencias están guardadas individualmente en `revision-pruebas/`. Se revisaron también las dos pruebas nuevas, del plano y de la caché.

| Archivo bajo `test/` | Revisión de aserciones |
|---|---|
| `bay_plan_grid_test.dart` | Sustituye representación anterior por estados/roles de `BsCelda`, claves y datos de peso. Conserva comprobaciones de bahía, reserva y selección. |
| `effective_weight_test.dart` | Comprueba el peso efectivo mediante `linea2` y formato actual; conserva la identidad y los valores. |
| `profile_loading_page_test.dart` | Cambia el acceso a perfiles por «Más»; conserva las comprobaciones de carga. |
| `recent_voyages_test.dart` | Cambia la ruta de entrada al historial; conserva las comprobaciones del historial. |
| `support/t91_toolbar_support.dart` | El ayudante abre/cierra «Más» en lugar del plegado; conserva modo, selección y desplazamiento del plano. |
| `t102_weight_display_test.dart` | Lee las cuatro cifras desde `BsCelda.linea2`; mantiene valores y cantidad. |
| `t104_text_test.dart` | Cambia `TabBar` por destinos de `NavigationBar` y comprueba rótulos/líneas; ya no prueba las pestañas retiradas. |
| `t106_plan_widget_test.dart` | Actualiza título, Baja y 40′; hace visible la celda ampliada antes del toque. Conserva operación y contenido. |
| `t107_tabs_test.dart` | Sustituye selección de pestañas por destino compartido, toque/ratón y contenido real; conserva los recorridos. |
| `t110_bays_test.dart` | Elimina el porcentaje textual del selector anterior; lo reemplaza por ocupación/datos de la silueta y selección. |
| `t114_fase3_inicio_test.dart` | Exportación y cierre pasan por «Más»; conserva las restricciones del previo. |
| `t114_fuentes_test.dart` | Admite LF y CRLF en licencias mediante longitudes y hashes explícitos; los TTF siguen comprobándose exactamente. |
| `t69_reserved_slots_view_test.dart` | Ajusta el rol de reserva y el borde al rediseño. La igualdad de grosor anterior se relaja a un mínimo; conserva conteos, peso, reserva y sombra. |
| `t75_discharge_test.dart` | Sustituye textos DESC/PASO por claves/estado; retira una comprobación redundante de BAJA. La clave de pendientes y las comprobaciones operativas siguen. |
| `t81_office_widget_test.dart` | Actualiza «Cancelado» a la etiqueta vigente; mantiene el estado de cancelación. |
| `t90_theme_test.dart` | Conserva el umbral 4.5:1 y mide el texto/peso dibujado por la celda actual. |
| `t91_plan_toolbar_test.dart` | Retira aserciones del plegado y distribución antiguos; incorpora navegación por «Más». **Las cuatro pruebas de almacén/provider permanecen idénticas.** |
| `t97_text_test.dart` | Cambia título, detalle y navegación. **Retira sin equivalente horizontal** los límites del chip anterior: la silueta se desplaza. Conserva límites verticales y ausencia de truncamiento de sus textos. |
| `vessel_profile_view_test.dart` | Sustituye `FilterChip.selected` por selección semántica y claves; mantiene la transición antes/después. |

Respuesta precisa sobre aserciones retiradas: **sí hay eliminaciones sin reemplazo literal**, principalmente las de la barra plegable autorizadamente retirada, los límites horizontales del selector de T-97 y la comprobación redundante BAJA; también se flexibiliza el grosor en T-69. No se presentan como conservación exacta de todas las aserciones. No se encontró una eliminación de la cobertura de persistencia. La nueva cobertura deja fuera el ancho exacto de 600 con letra grande y la carga real hasta su celda/anuncio; H1–H3 demuestran esos huecos.

Las cuatro pruebas de T-91 conservan reapertura, retención/borrado de viajes, separación de namespaces, persistencia tras toques rápidos y fallos de lectura/escritura. El bloque se comparó byte a byte normalizando fin de línea y tiene el mismo SHA-256: `t91-almacen-conservado.json`. Su almacén es el directorio temporal de `testProfileStore`, no el almacén operativo de Carlos.

## 3. Dirección C, datos, naranja y contadores

Las celdas usan `BsCelda`, los roles semánticos, esquinas del casco y las vistas **Estado, Destino y Tipo de vacío**. La última es el rótulo completo de «Tipo». Las fichas oscuras y las vistas Estado/Destino se observan en las capturas de los tres clientes. Las tarjetas y la silueta obtienen valores del viaje, geometría y progreso real de la operación; no se encontró una grúa, superestructura o equipo ficticio añadido a la pantalla.

El provider recibe los movimientos de la operación, aprende la lectura inicial y no la reproduce como eventos recién llegados. La duración es 1500 ms. La suite ejecutada incluye `t114_piezas_test.dart` para celda naranja inmóvil con `disableAnimations`, posición estable y sin animaciones; también la reducción del destello de la silueta. Esto pasa como componente, pero la conexión de Carga falla según H2.

`eventosEnVivo` transforma `author.role` a Muelle/Oficina. No usa el nombre, correo, UID ni ID de dispositivo como identidad visible. El contenedor y su posición sí se muestran: son datos operativos, no identificadores personales. El arnés añade deliberadamente un nombre sintético y comprueba que no aparece en el anuncio. El anuncio funciona con el panel de oficina; H3 documenta la omisión en tamaños inferiores.

La observación 2 de 10.19 queda resuelta en el tema: `bs_tema.dart:269` configura `BadgeThemeData` con `semanticos.revisar.contorno/relleno`. El `Badge` de «Acciones» en `loading_plan_controls.dart:378` hereda ese tema y no introduce grúa. «Más» utiliza aviso o error según la severidad. No se encontró un contador nuevo en grúa.

## 4. Navegación después de T-91

| Función | Teléfono, 360 dp | Desde 600 dp y a 1920 dp |
|---|---|---|
| Buscar | Cabecera o acción de la banda del muelle. | Cabecera; **H1 a 600 con letra 2.0**. |
| Nube | Cabecera/banda y «Más». | Pie del riel; también cabecera cuando cabe. |
| Parámetros | «Más». | Pie del riel. |
| Cargar archivo | «Más». | «Más». |
| Viajes recientes | «Más». | «Más». |
| Perfiles guardados | «Más». | «Más». |
| Cerrar el plano | «Más». | «Más». |
| Exportar PDF, CSV, JSON | «Más», para el viaje publicado. | «Más», para el viaje publicado. |
| Exportar previo | «Más», en el estado previo. | «Más», en el estado previo. |
| Generar BAPLIE de salida | Destino Lista. | Destino Lista. |

El arnés comprueba las entradas de «Más» a 360, 600 y 1920, las desplaza a la vista y verifica que admiten toque; se leyeron sus callbacks y las condiciones de publicación. Las pruebas de inicio conservan la distinción previo/publicado. Lista y sus acciones se ven en las capturas de los tres clientes. No se abrió Nube ni se produjeron exportaciones o borrados durante esta aceptación. Las funciones conservan sus rutas; Buscar tiene la excepción bloqueante H1.

## 5. Reaceptación de la caché del tema

**Pasa.** Se repitió el criterio del arnés de la reaceptación anterior: construir una **instancia nueva y no constante** de `BayStreamApp`, mantener el `ProviderScope`, y comparar la identidad de `MaterialApp.theme` antes/después. El mismo tema conserva identidad; `hasRunningAnimations` es falso al inicio y después de los incrementos de 150, 49, 1 y 16 ms. Cambiar de claro a oscuro y de densidad oficina a muelle sí cambia el tema efectivo y arranca la transición correspondiente.

Evidencia: caso «cache: reconstruccion real, tema y densidad» y entrada `cache` de `pruebas-propias.json`. La prueba nueva del repositorio usa un hijo `const BayStreamApp` dentro de `StatefulBuilder`, por lo que reconstruir solo ese padre no demuestra por sí solo un rebuild del hijo. Es una limitación de esa prueba, **no un fallo de la caché**: el arnés independiente fuerza la reconstrucción real y pasa.

## 6. RNF-002 e integridad de los instrumentos

Umbral evaluado: **máximo tres pasos y 30 s hasta la primera rejilla visible**.

| Condición entregada | Tiempos de las cinco corridas, segundos | Comprobación |
|---|---|---|
| Windows sin perfil | 2.188; 1.942; 1.844; 1.869; 1.859 | Coinciden con los registros y el intervalo publicado 1.84–2.19. Cuadro de rejilla válido. |
| Web, caché caliente | 0.478; 0.354; 0.367; 0.334; 0.302 | Coinciden con 0.30–0.48; tres pasos. |
| Web, primera visita | 1.598; 1.489; 1.280; 1.350; 1.362 | Coinciden con 1.28–1.60; tres pasos. |
| Android, cotas por video | 3.837–3.879; 3.364–3.419; 3.061–3.138; 3.139–3.193; 3.057–3.114 | Aritmética correcta; hito visual inválido por H4. |

Se recalcularon las cotas de Android con `pts`, `inicio`, `fin` y los cuadros vecinos, y se compararon con cada `cuadros.json`: `rnf-002-recalculado.json`. Los registros Windows/Web se contrastaron individualmente con el informe; no se mezclaron caché caliente y primera visita.

**Repetición propia de Windows: 1.929 s, tres pasos, incertidumbre nominal de 0.050 s.** La imagen [rejilla.png](../../../../build/t114-entrega2-aceptacion/rnf-002-windows/sin01/rejilla.png) muestra las celdas en previo, sin exigir confirmar el perfil para verlas. Resultado e instantes en `rnf-002-windows/sin01/registro.json`; resumen en `rnf-002-windows/resumen.json`.

Se compiló desde esta copia con:

```powershell
flutter build windows --release --no-pub -t tool/t99_main.dart "--dart-define=T99_ALMACEN=$env:TEMP/t114-entrega2-codex/store-windows"
```

Se copió el Release al banco temporal propio y se ejecutó, con rutas absolutas normalizadas:

```powershell
python tool/t114_primera_windows.py --exe "$env:TEMP\t114-entrega2-codex\banco\baystream.exe" --archivo "$env:TEMP\t114-entrega2-codex\T99_SINTETICO_977.edi" --almacen "$env:TEMP\t114-entrega2-codex\store-windows" --salida "$env:TEMP\t114-entrega2-codex\rnf-002-despejado" --perfil sin --repeticiones 1
```

Almacén usado: **`C:\Users\Giova\AppData\Local\Temp\t114-entrega2-codex\store-windows`, namespace `t99`**. El instrumento apartó solo ese almacén para la condición sin perfil y abrió el ejecutable mediante `explorer.exe`. No abrió `%LOCALAPPDATA%\BayStream` ni su copia virtualizada; no es una prueba de persistencia de ese almacén real. `T99_FIREBASE` quedó desactivado. El banco terminó cerrado.

Se conservan dos intentos fallidos en los logs: el primero no abrió el banco por una ruta con separadores mezclados; el segundo abrió el banco pero el Explorador tapó su imagen y el instrumento agotó 120 s sin ver la entrada. No se cuentan como mediciones del producto. Carlos despejó el escritorio y autorizó repetir; la corrida válida terminó sin intervención durante el reloj. Se avisó el inicio y final de cada ventana con SEMÁFORO.

Integridad y significado:

- **T-98 sin cambios**, confirmado por `git diff ccc8c2f..HEAD -- 'tool/t98*'`; `t98-sin-cambios.diff` está vacío.
- En **T-99** cambia el conductor: localiza destinos de barra/riel en vez de pestañas y bahías por la clave de la silueta. El escenario RAM conserva cargar, Plano, todas las bahías, Estadísticas, buscar y Lista; hace `ensureVisible` antes del toque de bahía y comprueba el hit test. No cambian el muestreador RAM, la métrica ni su resumen. El escenario nuevo `plano` sirve para capturas y no redefine el reloj de RNF-002.
- Límite del conductor T-99: `_pestana('Estadísticas')` sigue buscando el texto exacto, mientras la barra inferior muestra «Estad.». La adaptación del escenario RAM/anchos no debe darse por validada para teléfono; la RAM revisada aquí usa el riel de Windows. No se ejecutó ese escenario en Android.
- **T-114 primera Windows** cambia únicamente el color de búsqueda de la marca oscura, de `#8FB4F2` a `#4F8EF7`; mantiene acciones, reloj, umbral de quietud e incertidumbre. Los instrumentos de primera Web, Android y cuadros no cambiaron. Los nuevos scripts de capturas preparan datos sintéticos y recorren la presentación; el nuevo orquestador RAM invoca el muestreador existente.
- La medida numérica mantiene su definición; en Android cambió la pantalla y dejó de cumplirse la premisa de que el cuadro final ya mostraba la rejilla. No se puede conservar el dictamen solo porque el instrumento no cambió.

## 7. RAM

Se recalcularon los dos CSV originales: **210 lecturas cada uno**, seis corridas × siete hitos × cinco lecturas. Se descarta la primera corrida. La unidad es MB del SI, `WorkingSet64 / 10^6`; cinco lecturas tras cinco segundos de reposo por hito, separadas aproximadamente 0.5 s. Para cada hito se toma la mediana de sus lecturas por corrida y luego la mediana entre las cinco corridas conservadas.

| Hito | Antes, mediana MB | Después, mediana MB |
|---|---:|---:|
| Inicio | 133.6 | 128.8 |
| Cargar | 154.2 | 150.1 |
| Plano | **156.2** | **155.7** |
| Todas las bahías | 161.3 | 155.0 |
| Estadísticas | 182.7 | 171.9 |
| Buscar | 189.5 | 189.7 |
| Lista | **510.5** | **513.6** |

Coinciden con el informe. El rango de medianas del Plano pasa de 129.7–159.3 a 141.5–177.5 MB; Lista, de 495.4–524.9 a 484.1–519.7 MB. Estos datos no prueban una mejora estadística, pero no muestran el salto de RAM atribuido al plano. El «estable» de T-99 es el último hito, Lista, y no debe confundirse con la cifra del Plano. **Lista permanece como observación no bloqueante**, según lo autorizado. Evidencia: `ram-recalculada.json`; no se hizo una nueva campaña RAM.

## 8. Capturas y privacidad

Revisión visual completa de **182 imágenes entregadas**: 72 Windows, 40 Web, 28 emulador y 42 de RNF-002 (35 JPEG Android, 3 PNG Windows y 4 PNG Web). `imagenes-inventario.json` conserva ruta, tamaño y SHA-256; `revision-visual.csv` registra cada revisión. Las 31 hojas en `hojas-visuales/` permiten recorrer el conjunto; los detalles problemáticos se contrastaron con los originales.

Solo se observaron datos sintéticos de los bancos, como BUQUE MANUAL/M100, MNLU/TSTU y T99 SINTETICO 977. No se observaron correos, UID, identidades de operadores ni una pantalla de cuenta abierta. **El texto «Nube y cuenta» sí aparece como opción de «Más»**: no sería correcto afirmar que esa cadena está ausente de todas las capturas. Es la ruta requerida hacia Nube y no revela una cuenta.

En los 35 cuadros Android no se lee `CORPUS_A01.edi` ni otro nombre de archivo del corpus. El selector muestra nombres sintéticos; algunos cuadros son transiciones semitransparentes. La conclusión se refiere a contenido visible y legible, no a lo que pudiera existir oculto en el dispositivo. No se examinó ni alteró el dispositivo.

## 9. Auditoría flutter-ui y censos T-112

Se repitió `flutter_ui_audit.py . --all` y también se auditó una copia de solo lectura de `lib/` obtenida con `git show ccc8c2f:<ruta>`. No hubo cambio de rama ni checkout.

| Medida | Base `ccc8c2f` | HEAD |
|---|---:|---:|
| Críticos globales del escáner | 17 | 17 |
| Avisos globales | 272 | 249 |
| Informativos globales | 19 | 20 |

**La condición literal «cero críticos y cero avisos en archivos tocados» no se cumple.** En esos archivos el escáner devuelve 2 críticos y 10 avisos: los dos críticos son falsos positivos preexistentes al reconocer los nombres `ReservedSlotsListView` y `ContainersListView` como si fueran un `ListView(children:)`; nueve avisos son preexistentes y uno es nuevo, `PERF_INTRINSIC_SIZE` en `navegacion_del_viaje.dart:186`. También aparece un informativo nuevo `NAV_NO_POP_SCOPE`.

La comparación por archivo, regla y código confirma cero críticos nuevos, 24 avisos de tamaño de fuente retirados y **un aviso nuevo de `IntrinsicHeight`**. El informe de entrega sí lo declara como solución para desplazar un riel corto en ventanas bajas. Su uso está acotado a la navegación, no a las celdas. Se deja como observación explícita; no se falsea un resultado 0/0 ni se amplía la tarea para limpiar avisos históricos. Evidencia: `flutter-ui-audit.txt`, `flutter-ui-audit-base.txt`, `auditoria-comparada.json`.

Los censos se ejecutaron con `tool/t112_censos.py`, salida temporal propia y referencia de T-112 `5406e20` obtenida mediante `git show`. Resultados:

- **1931 textos visibles**: 1800 españoles y 131 sin idioma, **0 ingleses o mixtos**.
- Material 3: **251 incluidos / 7 exclusiones / 3 excepciones**, sin excepción nueva.
- **217 mensajes**, con causa y acción; los 12 EDIFACT conservan referencia al segmento.

El diff del instrumento agrega clasificación de los componentes y textos nuevos y retira el mensaje de guardar el plegado, ya sin control visible. No agrega una dispensa Material 3. Se contrastaron los textos con código/capturas; los rótulos nuevos están en español. Evidencia completa en `censos/` e `instrumentos.diff`.

## 10. Texto grande y observaciones que no bloquean

Se confirman las cuatro decisiones de 10.20: el chip de zoom tapa la última columna a 360 con letra 1.45 y 2.0; «re-estibas» se parte a 2.0; la barra dice «Estad.»; la banda elide el nombre del buque («BUQUE MAN…», o menos caracteres al crecer la letra). No se convierten en motivos nuevos de rechazo.

El corte adicional confirmado es **H1 a 600 dp**, fuera de esas excepciones. A 360 × 640 y letra 2.0, las capturas del plano pueden quedar sin celdas visibles hasta desplazar; las de RNF-002 tampoco demuestran ese desplazamiento, tratado en H4. El desplazamiento horizontal deliberado de rejilla/leyenda no se contó como un texto truncado dentro de su celda. No se identificó otro corte nuevo de código de cinco letras en las celdas revisadas.

Observación visual adicional, preexistente: en Lista oscura, el chip seleccionado «Todas (60)» aparece claro sin rótulo legible. El `FilterChip` y la configuración de selección de `chipTheme` ya están en `ccc8c2f`; la entrega solo cambia el Badge en ese tema. Se registra para seguimiento, sin atribuirlo a esta entrega ni usarlo como bloqueo nuevo.

La leyenda en el panel lateral a 1920 y Atrás en Android siguen aplazados por 10.20. No se probaron pulsaciones Atrás en el dispositivo.

## 11. Web sin conexión

Se ejecutaron, en secuencia:

```powershell
flutter build web --release --output=build/qa-r4-web
dart run tool/t92_verify.dart build/qa-r4-web
```

Ambos terminaron correctamente. T-92: **56 archivos, 37911467 bytes**, verificador correcto. Evidencia: `build-web.txt` y `t92-verify.txt`. La compilación emite un aviso sobre la familia CupertinoIcons; se conserva en el log y no se confunde con una incidencia del analizador. Esta validación acredita el paquete y los requisitos comprobados por T-92; no se ejecutó una sesión manual de navegador desconectado.

## Entrega y siguiente paso

Único documento nuevo para versionar: **`docs/rediseno/fase3/entrega2/aceptacion-codex.md`**. Los archivos propios de comprobación, registros, referencias de solo lectura y capturas están en `build/t114-entrega2-aceptacion/`; su lista exacta y hashes constan en `manifiesto-evidencia.csv`. El Release Web solicitado está en `build/qa-r4-web/` y el banco Windows generado en `build/windows/`. `build/` está ignorado por diseño; no se propone forzarlo a Git.

**`pubspec.yaml` y `pubspec.lock` no cambiaron.** `producto-sin-cambios.txt` y `arbol-final.txt` están vacíos: no hay diferencias de contenido en archivos ya versionados. Flutter advierte sobre LF/CRLF de los tres generados de Windows, sin diff de contenido; no se incluyen en el bloque de Git.

Para reaceptar: resolver H1–H3 y acreditar el hito correcto de H4; repetir los casos aislados, la suite/análisis proporcionales al cambio y RNF-002 Android. Registrar la decisión sobre el aviso de auditoría sin declararlo inexistente. Las observaciones ya autorizadas por Carlos permanecen fuera de los bloqueos.

Tres líneas para Carlos:

1. NO PASA: Buscar a 600 dp/letra 2.0, naranja de Carga, anuncio accesible en tamaños menores y evidencia RNF-002 Android.
2. Pasan suite 1242/0/0, análisis, caché real del tema, Windows 1.929 s/3 pasos y verificador Web T-92; RAM del plano permanece ≈156 MB.
3. Producto y pubspec intactos; solo se entrega este informe y evidencia propia en build/.

Mensaje para Yov:

> Yov: Capitán Codex terminó la aceptación de T-114 Fase 3, entrega 2 en la copia limpia, HEAD 9522794 contra ccc8c2f. Dictamen NO PASA. H1: a 600 dp con letra 2.0 Buscar queda fuera de pantalla (624.9–672.9 dp; overflow 137). H2: una carga real actualiza recienMovido, pero LoadingCell mantiene estado ninguno y no pinta naranja. H3: el anuncio de En vivo solo existe desde 1200 dp; a 360/600 no hay live region para el movimiento. H4: los cinco finales RNF Android no muestran la rejilla, aunque las cotas PTS están bien calculadas. Suite 1242/0/0 y analyze 0; caché comprobada con rebuild real; Windows repetido en 1.929 s y 3 pasos; T-92 correcto. Los 19 diffs de pruebas están revisados y las cuatro pruebas de almacén T-91 son idénticas. Revisadas las 182 imágenes, incluidos los 35 cuadros Android: sin datos personales ni corpus visibles; Nube y cuenta solo como opción de menú. RAM y censos coinciden. Auditoría: cero críticos nuevos, pero un aviso nuevo IntrinsicHeight; no equivale a 0/0 en archivos tocados. Se respetan las excepciones 10.20. Informe en docs/rediseno/fase3/entrega2/aceptacion-codex.md; no corregí producto ni ejecuté Git de escritura.

Comandos para que **Carlos** versione únicamente el informe:

```powershell
git add -- docs/rediseno/fase3/entrega2/aceptacion-codex.md
git commit -m "Sprint 4: auditoria de aceptacion de T114 fase 3 entrega 2"
git push
```
