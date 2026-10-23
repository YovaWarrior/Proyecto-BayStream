# T-114 · Aceptación del paquete de íconos e ilustraciones

**Dictamen: NO PASA.**

Capitán Codex · 23-oct-2026 · copia `C:\Proyectos\baystream-qa-r4`.
Base: `77f7d1b`. Paquete revisado: `ac18025`.

La fuente, los dibujos, los contrastes, las compilaciones y las pruebas pasan las comprobaciones descritas abajo. El cierre queda pendiente por **H1: los íconos que comunican la condición del contenedor en los resultados de búsqueda carecen de etiqueta y de descripción emergente**. La suite entregada no comprueba ese contrato. También se documentan una discrepancia de aplicación de la regla única de contenedores y las salvedades de reproducción y de evidencia visual.

Se leyeron `AGENTS.md`, las decisiones 10.14, 10.18, 10.19 y 10.22 de `SPRINT-4.md`, el LEEME del paquete, `DESIGN.md` 13.7, 13.9 y 13.11 y la sección «Fase 3 · Paquete de íconos e ilustraciones (10.19)» del informe de Timonel. Se aplicó la auditoría de la skill `flutter-ui`. No se modificó código del producto, no se inició sesión, no se accedió a Firebase ni se usaron el Honor o el emulador. No se ejecutó `git status` ni Git de escritura.

Toda la evidencia nueva está en **`build/t114-paquete-aceptacion/`**. Las rutas de evidencia de las tablas siguientes son relativas a esa carpeta. Sus archivos quedan fuera de Git por `/build/`.

## H1 · La búsqueda pierde el significado accesible del ícono

**Incumple el punto 4 del encargo.** En `lib/features/vessel/presentation/widgets/container_search_delegate.dart:448`, `_buildLeadingIcon` devuelve `Icon(icon, color: foreground, size: 20)` sin `semanticLabel` ni `Tooltip`. El resultado tampoco aporta un texto equivalente para la carga peligrosa, el refrigerado, el fuera de medida o el vacío.

La reproducción independiente usó cuatro contenedores sintéticos con el mismo ID y tipo ISO, cambiando solo esa condición. El glifo cambia correctamente, pero los cuatro resultados exponen exactamente la misma etiqueta accesible:

```text
TSTU0000011
22G1
```

| Condición | Glifo dibujado | `semanticLabel` | Descripciones emergentes |
|---|---|---|---:|
| Peligrosa | U+E005 | `null` | 0 |
| Refrigerado | U+E004 | `null` | 0 |
| Fuera de medida | U+E006 | `null` | 0 |
| Vacío | U+E003 | `null` | 0 |

**Evidencia:** `comprobacion_test.dart`, `etiquetas-test.txt`, `etiquetas-busqueda.json`. El diagnóstico pasa porque registra el comportamiento real; no se presenta como una prueba de cumplimiento de etiquetas.

**Corrección propuesta, sin implementarla:** dar al ícono una etiqueta accesible o incorporar la condición al texto accesible del resultado; añadir una descripción emergente cuando corresponda. Verificar los cuatro casos desde el árbol de semántica, además de comprobar que el glifo existe. Las acciones con rótulo, los `IconButton` con `tooltip` y las insignias incluidas en la etiqueta de la celda no presentan este mismo problema en la muestra revisada.

## O1 · La Lista no aplica la regla única que documenta el paquete

`iconos_del_dominio.dart` declara que `iconoDeContenedor` aplica la misma prioridad en Lista, búsqueda y detalle: peligrosa → refrigerado → fuera de medida → vacío → tipo → tamaño. Sin embargo, el ícono principal de la tarjeta de Lista llama directamente a `iconoDeTipo` (`containers_list_view.dart:83`).

Con los cuatro contenedores anteriores, la búsqueda dibuja E005/E004/E006/E003 y el ícono principal de la Lista dibuja **E000 en los cuatro casos**. La Lista sí conserva los textos/chips de carga especial y el estado vacío: no se afirma que desaparezcan esos datos. La discrepancia es la promesa de un mismo glifo principal y una misma regla, documentada también en 13.11. Debe aplicarse la regla acordada o precisarse con Carlos qué concepto representa ese ícono de tipo. Evidencia: `etiquetas-busqueda.json` y las rutas de código indicadas. No se cambió ninguno de esos archivos.

## 1 · Alcance y dependencias

`git diff --stat 77f7d1b..HEAD` da **170 archivos, 11224 inserciones y 158 eliminaciones**. No hay cambios en `domain/`, `data/`, `lib/main.dart`, opciones de Firebase ni en los dos archivos congelados.

`pubspec.yaml` solo incorpora el comentario de procedencia y la familia `BayStreamIconos` con su TTF. **`pubspec.lock` no cambia; ninguna dependencia nueva.** `flutter pub get` terminó correctamente y no alteró ese contrato. La comprobación final contra HEAD dejó sin diferencias `lib/`, `test/`, `tool/`, `pubspec.yaml` y `pubspec.lock`.

Evidencia: `diff-stat.txt`, `rutas-paquete.txt`, `alcance.json`, `pub-get.txt`.

## 2 · Integridad y regeneración del paquete

Hay 85 archivos en las tres carpetas del paquete: **84 con huella en la tabla del LEEME y el propio LEEME**, que no se incluye a sí mismo. Los **84 SHA-256 coinciden con los bytes versionados de HEAD**. No hay `__pycache__` ni `.pyc` en esas carpetas antes ni después de las verificaciones.

La copia de trabajo convierte los 78 archivos de texto a CRLF: solo los seis binarios conservan directamente el SHA del LEEME. Al normalizar únicamente los textos a LF coinciden también los 78. Se verificó además cada blob con `git show HEAD:<ruta>` para no confundir la conversión de Git con una alteración del paquete. No se normalizaron ni reescribieron archivos del producto.

Se creó el entorno virtual `venv/` bajo esta evidencia. Se instalaron **resvg-py 0.5.0, Pillow, fonttools, skia-pathops y freetype-py** sin instalar nada en el Python del sistema. Versiones finales: Python 3.14, Pillow 12.3.0, fonttools 4.67.0, skia-pathops 0.9.2 y freetype-py 2.5.1.

**Salvedad reproducible:** `generar.py --verificar` no termina en verde byte a byte en este entorno. Sobre el checkout con CRLF da 26/84; sobre `paquete-canonico/`, construido con los bytes exactos del commit, da **80/84**. Difieren `comprobacion-fuente.png`, las dos `vista-previa.png` y el LEEME que registra sus tamaños y SHA. Las tres imágenes regeneradas tienen **dimensiones y píxeles RGBA idénticos** a las versionadas. El diff del LEEME contiene exclusivamente las tres filas de tamaños/huellas de esos PNG. La fuente, los SVG, los JSON y los códigos se reproducen byte a byte. Se repitió con Pillow 12.3.0 y permanecen las cuatro diferencias; la primera corrida usó Pillow 13.0.0.

Esto acredita el contenido gráfico y la integridad del commit, pero **no acredita un resultado 84/84 del verificador byte a byte en Windows**. Para conseguirlo hace falta reproducir el entorno de compresión del autor o acordar una verificación de píxeles para los PNG. No se modificó el generador ni se ocultó su salida fallida.

Evidencia: `sha256-leeme.json`, `pip-install.txt`, `pip-pillow123.txt`, `venv-versiones.txt`, `generar-verificar.txt`, `generar-canonico.txt`, `generar-canonico-pillow123.txt`, `generar-salida.txt`, `png-regeneracion.json`, `leeme-regeneracion.diff.txt`, `paquete-canonico/` y `regenerado/`.

## 3 · Ilustraciones y regla del alto

Se volvió a ejecutar la función del generador JSON → Dart, escribiendo la salida en la evidencia: coincide con `git show HEAD:lib/core/design/bs_ilustraciones.dart` después de normalizar finales de línea. También pasó `python -B tool/bs_ilustraciones_generar.py --verificar` con el Python del entorno virtual. No se reescribió `lib/`. Las pruebas de la suite contrastan también las 115 formas y las seis ilustraciones.

La inspección confirma `Semantics(label, image: true)` → tamaño/proporción → `RepaintBoundary` → `CustomPaint`. `colorDeIlustracion` resuelve nombres mediante los tokens del tema; el Dart generado no copia los hex de `paleta`. Los trazos usan puntas/uniones redondas y el punteado se descompone con las métricas del `Path`.

Las pruebas comparan cada nombre con los tokens reales de los dos temas y exigen 3:1 sobre el fondo. Como contraste adicional, el cálculo independiente sobre las paletas JSON mide **165 combinaciones de trazo y tema, con mínimo 6.086:1**, por encima de 3:1. La equivalencia de esas paletas con los tokens la acredita la prueba del producto.

La regla 4 de 13.11 limita el alto a `0.3 × altoVentana / escalaLetra` y oculta la ilustración por debajo de 120 dp. Se comprobó a **360 × 640**, letra **1.0, 1.45 y 2.0**, en claro y oscuro, en los bancos compilados de Windows y Web: **«Seleccionar archivo» permanece visible sin desplazar en los doce casos**. Con 2.0 no se dibuja la ilustración. Las pruebas entregadas cubren también la variante de 360 × 592 con barra de estado y el escritorio. No se extrapola este resultado a otras pantallas.

Evidencia: `regeneracion-dart.txt`, `ilustraciones-verificar.txt`, `bs_ilustraciones.regenerado.dart`, `trazos-contraste.json`, `flutter-test.txt`, `capturas/windows/registro.json`, `capturas/web/registro.json`, `inicios-lamina-1.png` e `inicios-lamina-2.png`.

## 4 · Glifos, tabla de sustitución y colisiones

La suite carga la TTF real, verifica el `cmap` y comprueba que las **35 constantes dibujan tinta y se distinguen entre sí** a 24 px. La muestra de 13 glifos se comparó con sus SVG a 16 y 24 px:

| Tamaño | Máximo de píxeles que cambian de estado | Máximo de diferencia media de alfa | Límite de la prueba |
|---|---:|---:|---|
| 16 px | 8/256, 3.125 % | 10.82/255 | 12 % y 16/255 |
| 24 px | 63/576, 10.938 % | 6.61/255 | 12 % y 16/255 |

No es igualdad de píxel: el contorno TrueType y el rasterizado de `Path` difieren en los bordes. Se conservó la tolerancia explícita del paquete.

| Colisión o concepto | Resultado de inspección y pruebas |
|---|---|
| Carga peligrosa / aviso | `peligrosa` para IMDG y carga peligrosa; `warning_amber` para avisos genéricos |
| Re-estiba / solicitud | `reestiba` y `pedirCambio` separados |
| «Paso» | `buque` en la marca y la celda |
| Secuencia | «sale» con `descarga`; «vuelve» con `carga` |
| Agencia / CSV | `listadoAgencia` en importación/listado; el único `table_view` queda en exportar CSV |
| Contenedores | Las funciones de tipo y tamaño cubren 20/40/45, tanque, refrigerado, plataforma y techo abierto; prioridad especial/vacío correcta en `iconoDeContenedor`, con la discrepancia de Lista de O1 |
| Sustituciones Material | El censo de `lib/`, fuera de los congelados y `main.dart`, no encuentra conceptos de la tabla pendientes de sustitución; conserva las excepciones explícitas de 13.11 |
| Genéricos junto a la familia nueva | Rellenos; riel y barra usan el mismo glifo activo y en reposo, con el indicador M3 |
| Catálogo sin sitio | 28 constantes con sitio en uso; siete reservadas sin uso, sumando los 35 glifos |
| Etiquetas | **No cumple globalmente: H1**. Las pautas de botones de la suite no detectan el significado ausente del ícono del resultado |

Evidencia: `flutter-test.txt` (bloques «muestra a 16 px» y «muestra a 24 px»), `producto-diff.txt`, `pruebas-diff.txt`, `etiquetas-busqueda.json` y las tres pruebas nuevas versionadas de T-114.

## 5 · Insignias de 12 px

Además de las pruebas entregadas, se renderizaron las tres insignias sobre las 24 fichas categóricas y los cinco estados adicionales, normales y atenuados, en ambos temas: **348 combinaciones**. Se leyó el color real del `Icon` y del relleno de `BsCelda`, componiéndolos sobre la superficie del tema. Todas dibujan a **12 px** y superan 3:1.

| Tema | Contraste mínimo compuesto |
|---|---:|
| Claro | 3.0326:1 |
| Oscuro | 3.0085:1 |

Se cargó la fuente real para los atlas de insignias; se revisaron visualmente, además de los planos compilados. El rombo, el copo y la pieza fuera de medida se distinguen sobre las fichas. Los atlas son pruebas de componentes, no capturas de un cliente Android.

Evidencia: `comprobacion_test.dart`, `comprobacion-test.txt`, `insignias-matriz.json`, `insignias_claro.png`, `insignias_oscuro.png`.

## 6 · Windows, Web y evidencia Android

**Windows:** compilación release con `qa_main.dart` de esta evidencia como punto de entrada. Usa `BayStreamApp`, sus pantallas y sus repositorios locales, mediante el banco existente `t99App`; no inicializa Firebase. Se lanzó por `explorer.exe`. Almacén utilizado: **`C:\Users\Giova\AppData\Local\Temp\t114-paquete-almacen-r4`**, namespace **`r4`**; no se abrió el almacén real ni el del paquete de Codex. El banco se cerró al terminar.

**Web de producción:** se ejecutó exactamente `flutter build web --release --output=build/qa-r4-web`. Después, `dart run tool/t92_verify.dart build/qa-r4-web` terminó correctamente: **57 archivos, 37981033 bytes en la repetición aislada** (37981032 bytes en la primera compilación). Se compiló aparte el mismo banco visual, en `build/qa-r4-web-banco`, para recorrerlo sin Firebase ni cuenta. No se lanzó `lib/main.dart` contra servicios externos.

En ambos bancos hay **12 capturas por cliente**: inicio, plano de la bahía 06 con insignias y estado vacío de recientes, en claro/oscuro a 1280 × 720; más los seis inicios a 360 × 640 con las tres escalas. Se obtuvieron del `RenderRepaintBoundary` de las pantallas ejecutadas en cada motor; no son mockups ni capturas de widget tests. Las pantallas conservan su código y sus fuentes. No se ven cuadros vacíos en los glifos observados. La cobertura exhaustiva de las 35 constantes pertenece a las pruebas de fuente, no a estas seis pantallas de cada cliente.

Las compilaciones Web emiten un aviso sobre la familia `CupertinoIcons` ausente; `BayStreamIconos` sí aparece y se empaqueta. Su TTF compilada queda en 7776 bytes por eliminación de glifos sin uso, frente a 8864 del asset original. Este aviso se conserva en los registros y no se presenta como un fallo de `BayStreamIconos`.

**Sin conexión:** Chrome visible, perfil temporal nuevo, origen local `127.0.0.1:5917`. Se desactivó la red del contexto antes del recorrido; un `fetch` nuevo, sin caché, falló. El banco produjo sus doce capturas y registró cero errores Flutter. Tras completar la caché del service worker se repitió la navegación con la red desactivada: arrancó de nuevo y produjo otras doce capturas. Cero solicitudes externas. El sitio conserva el viaje sintético tras la recarga; por ello los archivos `recarga_vacio_*.png` muestran la lista con ese viaje y **no se cuentan como evidencia de estado vacío**. El vacío se acredita en la primera ronda. No se desactivó la red de la máquina ni se tocó un dispositivo.

**Android:** se revisaron las 31 capturas entregadas, sin volver a usar el emulador ni compilar/instalar en el Honor. Los glifos visibles se dibujan en ambas paletas. Esa revisión visual no sustituye una nueva ejecución Android, que no se pidió.

Evidencia: `qa_main.dart`, `qa_output_io.dart`, `qa_output_web.dart`, `sintetico_embebido.dart`, `sinteticos/`, `sinteticos.txt`, `build-windows.txt`, `build-web.txt`, `build-web-banco.txt`, `t92-verify.txt`, `capturar_web.py`, `capturar-web.txt`, `capturas/windows/`, `capturas/web/`, `capturas/web/red.json`, `capturas/web/recarga_offline.json` y sus láminas de revisión. El servidor local y el navegador del banco se cerraron al terminar.

## 7 · Suite, análisis y cinco pruebas modificadas

- `flutter pub get`: correcto.
- `flutter test --no-pub --reporter expanded`: **1290 éxitos, cero fallos y cero omitidas**, 61 segundos según el registro. Los mensajes de error de escenarios negativos no se cuentan como fallos de pruebas.
- `flutter analyze --no-pub lib test tool integration_test`: **cero incidencias**.
- `flutter analyze --no-pub` sobre un snapshot de solo lectura de HEAD, extraído con `git archive` dentro de `arbol-analisis/`, después de su `pub get`: **cero incidencias**.
- La primera ejecución completa sobre la carpeta de trabajo dio 453 incidencias al incorporar Dart de aceptaciones anteriores que ya existían en `build/` y las copias de evidencia nuevas. Se conserva ese registro. No se atribuyen al producto ni se oculta esa primera salida. No se tocaron las evidencias antiguas ni `analysis_options.yaml` del proyecto; la exclusión local de `analysis_options.yaml` dentro de esta evidencia afecta solo a esta carpeta.
- Diagnósticos adicionales propios: dos pruebas correctas, más una repetición focalizada de la de etiquetas al añadir el cotejo con la Lista. No se suman al piso de 1290.

**Incidencia de procedimiento:** la primera invocación del build Web se lanzó mientras la primera llamada a `analyze` todavía estaba abierta. Fue un error del ejecutor frente a la regla de un Flutter a la vez. El análisis se repitió aislado sobre el producto y sobre HEAD, con cero incidencias; el build Web de producción y T-92 se repitieron después, secuencialmente. Se conservan ambas salidas de compilación. No se hicieron mediciones de rendimiento durante esta aceptación.

Se guardó el **antes y después mediante `git show`** de cada prueba existente modificada:

| Prueba | Sustitución | Contrato conservado |
|---|---|---|
| `t114_componentes_test.dart` | `south`, `swap_vert`, aviso Material → descarga, reestiba e insignia peligrosa | Glifo correcto, rótulos y ausencia de `Opacity` |
| `t114_piezas_test.dart` | `check_circle_outline` → `check_circle` | Estado Hecho, rótulo y marca |
| `t96_comparison_page_test.dart` | `south`/`north` → descarga/carga | Cada sección mantiene ícono, rótulo y conteo |
| `t114_fuentes_test.dart` | 9 → 10 assets | Comprueba existencia de todos los assets, incluyendo la familia nueva |
| `t114_celda_contraste_test.dart` | Reconoce también `BayStreamIconos` como ícono | Conserva 4.5:1 para texto y 3:1 para ícono/contorno; no trata un glifo privado como letra |

**Ninguna aserción perdida sin reemplazo.** La ampliación de la detección de íconos aplica el umbral correcto a la familia nueva; no rebaja el contraste exigido al texto.

Evidencia: `flutter-test.txt`, `flutter-analyze.txt`, `flutter-analyze-producto.txt`, `flutter-analyze-copia-head.txt`, `analisis-copia-pub-get.txt`, `build-web-repeticion-aislada.txt`, `t92-verify-repeticion-aislada.txt`, `pruebas-diff.txt` y los diez archivos `*.dart.antes.txt` / `*.dart.despues.txt`.

## 8 · Auditoría y censos

Se ejecutó `flutter_ui_audit.py . --all` y el mismo instrumento sobre `lib/` de `77f7d1b`. Ambos dan **17 críticos / 248 avisos / 20 informativos**. La comparación por regla, archivo y correspondencia de líneas da **cero críticos nuevos, cero avisos nuevos y cero informativos nuevos**. También es cero en los archivos tocados. Persisten hallazgos anteriores en archivos tocados: nueve críticos, 21 avisos y once informativos. No sería correcto afirmar que el repositorio o todos esos archivos tienen cero críticos totales.

El censo T-112, usando como referencia de decisiones `5406e20`, reproduce:

| Medida | Resultado |
|---|---:|
| Cadenas visibles | 1940 |
| Español | 1809 |
| Sin idioma, siglas/nombres/unidades | 131 |
| Inglés | **0** |
| M3 incluidos / excluidos / excepciones | **250 / 7 / 3** |
| Mensajes con causa y acción | **217 / 217** |

Evidencia: `audit.txt`, `audit-base.txt`, `auditoria-delta.json`, `auditoria-lineas.json`, `censos.txt` y `censos/` (CSV, resumen, tablas y huellas).

## 9 · Revisión de las capturas

Se inventariaron con dimensiones y SHA-256 las **31 PNG Android entregadas y las 37 PNG nuevas**: doce Windows, doce Web, doce de recarga Web y una captura de la ventana Web offline. Se revisaron visualmente mediante las láminas de contacto y los originales necesarios.

El contenido es sintético: `BUQUE MANUAL`, viaje M100 y los contenedores del generador T-100. No se observaron correos, UID ni archivos del corpus, y el banco nuevo solo incorpora `T100_LLEGADA.edi`. Ninguna captura nueva abre «Nube y cuenta».

**Salvedad del requisito literal:** las capturas Android de «Más» a letra 1.0 en claro y oscuro muestran la entrada «Nube y cuenta»; también se alcanza a ver en la de claro a 1.45. No muestran la pantalla de cuenta ni una sesión. Si el punto 9 excluye también el rótulo del menú, esas imágenes no cumplen esa condición y deben recapturarse o retirarse por quien prepara la entrega. Se conservan intactas. No se declara una filtración de datos por la presencia de ese rótulo.

Evidencia: `capturas-inventario.json`, `android-lamina-1.png` a `android-lamina-4.png`, las láminas Windows/Web/inicio/recarga y los originales en sus rutas.

## Entrega y siguiente revisión

Archivo de la entrega que debe versionarse: **`docs/rediseno/fase3/paquete/aceptacion-codex.md`**. No existía antes de esta aceptación. Los instrumentos, copias de lectura, resultados y capturas nuevos están únicamente bajo `build/t114-paquete-aceptacion/`; no se proponen para Git. Las salidas de compilación Web quedan en `build/qa-r4-web/` y `build/qa-r4-web-banco/`; Windows, en `build/windows/`. **Esta aceptación no cambia `pubspec.yaml` ni `pubspec.lock`.**

Para la reaceptación: resolver H1 y contrastar el árbol semántico de los cuatro resultados; resolver o precisar O1; conservar las salvedades documentadas de reproducción PNG y capturas. No hacen falta correcciones ajenas a esos hallazgos para explicar este dictamen.

### Tres líneas

1. NO PASA: la búsqueda dibuja los glifos correctos, pero cuatro condiciones quedan sin significado accesible; la Lista tampoco aplica la prioridad única documentada.
2. Pasan 1290/0/0, análisis de HEAD limpio, Windows/Web, T-92, recarga Web sin red, contrastes y censos; quedan explícitas las diferencias de compresión y el rótulo de cuenta en «Más» de Android.
3. Solo se añade este informe; producto, pubspec y lock intactos, evidencia en build, sin Git de escritura, Firebase ni dispositivos.

### Mensaje para Yov

Yov: Capitán Codex revisó ac18025 contra 77f7d1b en la copia limpia. Dictamen NO PASA por H1: los resultados de búsqueda de peligrosa, refrigerado, fuera de medida y vacío cambian de glifo pero exponen solo ID y tipo ISO al lector de pantalla, con semanticLabel null y cero tooltips. Diagnóstico propio en build/t114-paquete-aceptacion/etiquetas-busqueda.json. O1: la Lista usa iconoDeTipo para el ícono principal y no la prioridad única declarada. Pasan 1290/0/0, analyze del HEAD limpio, compilaciones Windows/Web, T-92 (57 archivos), recarga Web offline, 348 contrastes de insignias (mínimos 3.03/3.01), censos 0 inglés y M3 250/7/3. Las 84 huellas coinciden con los blobs del commit; generar.py da 80/84 sobre bytes canónicos por tres PNG con píxeles idénticos y sus filas SHA del LEEME. Auditoría 17/248/20 preexistentes, cero nuevos por regla/archivo/línea. Las capturas Android de Más incluyen el rótulo Nube y cuenta, sin sesión ni datos personales. Informe: docs/rediseno/fase3/paquete/aceptacion-codex.md. Producto y pubspec intactos; no se ejecutó Git de escritura ni se usaron Firebase, Honor o emulador.

### Git para Carlos

El informe no está ignorado. Solo esta ruta, autorizada expresamente para la aceptación:

```powershell
git add -- docs/rediseno/fase3/paquete/aceptacion-codex.md
git commit -m "Sprint 4: aceptacion del paquete de iconos con hallazgos pendientes"
git push
```
