# T-125 · Aceptación de la candidata 3.2.0

**Dictamen: ACEPTADA con observaciones.** P1, P2, P3 y P4 cumplen las comprobaciones descritas abajo. No encontré un defecto nuevo que impida aceptar T-125. Se conserva una observación P3 del banco Web y se explicitan los límites de la comprobación nativa. Carlos decide la incorporación y cualquier publicación.

Capitán Codex · pruebas del 27 de octubre de 2026 y cierre del informe el 28 de octubre, Guatemala. Carpeta `C:\Proyectos\baystream-qa-r4`, HEAD separado `d41ad8cd63ecc2a02a931a56194f12ea540c67ec`. Modelo solicitado: GPT-6.1 Sol, esfuerzo high.

## 1. Identidad, aislamiento y cifras

El Paso 0 se cumple con la corrección expresa de Carlos: `d41ad8c` (T-125), `065ef68` (decisiones 10.69/10.70), `9738be1` (aceptación T-124). Se revisaron SPRINT-4, las restricciones vigentes y el cambio respecto de T-124. No se mezcló, etiquetó, publicó ni escribió en Git; tampoco se ejecutó `git status`.

La evidencia está en [build/t125-aceptacion](C:/Proyectos/baystream-qa-r4/build/t125-aceptacion), con [resumen.json](C:/Proyectos/baystream-qa-r4/build/t125-aceptacion/resumen.json), [suite-resumen.json](C:/Proyectos/baystream-qa-r4/build/t125-aceptacion/suite-resumen.json) y [manifest.json](C:/Proyectos/baystream-qa-r4/build/t125-aceptacion/manifest.json). El manifiesto contiene la huella SHA-256 de este informe y de los archivos de evidencia incluidos.

| Comprobación | Resultado ejecutado |
|---|---|
| Suite original completa, antes de instrumentar | **Una corrida: 1841/1841 aprobadas, 0 fallos, 0 omitidas**, exit 0; 176,54 s |
| `flutter analyze --no-pub lib test`, copia limpia | **Cero incidencias**, exit 0; 48,129 s |
| Sondas adicionales propias | **109 casos distintos aprobados**: 79 de regresión y 30 de T-125; llamadas enfocadas posteriores, sin repetir la suite original |
| Originales del repositorio | **1917 huellas iguales** al cierre; `cotejo-final-originales.json` |
| Copia antes de la suite | **799 originales iguales**; `cotejo-antes-suite.json` |
| Copia al cierre | De esos 799, solo difieren los dos archivos Android que aíslan applicationId y etiqueta del banco; **lib/, test/ originales y pubspec.* iguales** |

La primera invocación sin elevación quedó detenida antes de ejecutar casos y se interrumpió. La corrida completa es la única registrada en `suite.jsonl`; se cuentan los eventos `testDone` no ocultos, excluyendo los cierres internos del corredor. Los fallos iniciales de las sondas propias se preservan: importación ausente, montaje asíncrono del provider sin mantener una suscripción y selectores del conductor. La guarda final aprobó en una llamada enfocada, después de las otras 29 sondas T-125 aprobadas. No se corrigió ningún archivo del producto para conseguir esos resultados.

Se copiaron únicamente archivos versionados necesarios, sin los documentos de Carlos ni configuración privada. Las candidatas se compilaron **antes** de cambiar el identificador Android y de añadir el banco. Después se añadieron herramientas y pruebas únicamente bajo `build/t125-aceptacion/banco/copia`. En el repositorio, el único archivo nuevo destinado a Git es este informe. **No cambian `pubspec.yaml` ni `pubspec.lock`.**

Windows se abrió con `explorer.exe`. Los snapshots escritos desde el propio proceso acreditan `C:\Users\Giova\AppData\Local\BayStream\vessel_store`, namespace **t125acc**, PID 38684 y ruta del ejecutable del banco; no un almacén virtual de Packages. Android usó exclusivamente **emulator-5554**, paquete **gt.cmartinez.baystream.t125acc**, en su almacén privado. Chrome estuvo visible, con perfiles nuevos y temporales dentro de la evidencia. No se tocó el Honor, las apps instaladas, el piloto ni el corpus. Todas las entradas fueron T-122, T100, T99_SINTETICO_977 y el caso sintético propio O-124-1. El botón del banco «Publicar en este dispositivo» solo marcó la bitácora local; no accedió a Firebase.

## 2. P1 · Estadísticas con vacíos asignados — CUMPLE

Se recorrió la entrada real de T-122 y su listado: OR 12, OR 13 y anulación de OR 12 con **«Marcado por error»**. Se cotejó la lista efectiva de contenedores a bordo, incluido su filtro «Todas», con la protagonista de Estadísticas. La ficha del archivo en Lista conserva sus datos originales; no se tomó esa cifra fija como cuenta de la operación.

El oráculo propio recorre las unidades del archivo y suma directamente sus masas, tara y categorías. Agrupa explícitamente 21/22/23 en 22 y 25/26/27 en 26, sin llamar al formateador ni a su agrupador `referenceBay`. Después contrasta esos resultados con los providers reales y con Estadísticas. Código y registros: `codex_t125_test.dart`, `sondas-t125-final3.log`, `sondas-guardas-final.log` y `sondas-resumen.json`.

| Paso | Vacíos asignados | Lista = Estadísticas | Peso esperado, kg | Grupo 22: unidades / kg | Grupo 26: unidades / kg | 20 / 40 pies |
|---|---:|---:|---:|---:|---:|---:|
| Inicial | 0 | 25 | 380 000 | 21 / 309 000 | 4 / 71 000 | 11 / 14 |
| OR 12: TSTU0012123, 0210084, 22G1, tara 2185 | 1 | 26 | 382 185 | 22 / 311 185 | 4 / 71 000 | 12 / 14 |
| OR 13: TSTU0012139, 0220084, 45G1, tara 3900 | 2 | 27 | 386 085 | 23 / 315 085 | 4 / 71 000 | 12 / 15 |
| Deshacer OR 12 | 1 | 26 | 383 900 | 22 / 312 900 | 4 / 71 000 | 11 / 15 |

`45G1` corresponde aquí a **40 pies**, no a 45 pies. Todas estas unidades van a PAMIT y naviera LNX: sus cuentas son respectivamente 25, 26, 27 y 26. El archivo parte de 23 llenos, 1 vacío y 1 sin estado; los vacíos resultan 1, 2, 3 y 2, manteniendo los otros estados. Ambas taras suman **6085 kg**.

La ficha aparece debajo de la protagonista y sus textos completos son:

- «Incluye: 1 vacío asignado a una celda reservada, que el archivo no trae».
- «Incluye: 2 vacíos asignados a celdas reservadas, que el archivo no trae».

La tabla agrega **«Vacíos asignados»** con 1, 2 y 1. Con cero asignados se ocultan ficha y fila. La guarda adicional usa los providers reales tanto en llegada como en plan sin operación: operación activa nula, asignados vacíos, ficha y fila ausentes.

Las **dos alertas `twentyOverForty`** y la comparación de viajes se capturaron antes y después de cada movimiento en la sonda de dominio/providers y resultaron iguales. Los snapshots nativos de Windows con dos asignados y tras la anulación también conservan iguales las alertas y el resultado completo de comparación. No se incorporan los vacíos operativos a esas dos funciones.

| Cliente / nivel | Evidencia propia |
|---|---|
| Chrome release visible | Secuencia completa 0→1→2→1 en claro y oscuro; `web/p1-oscuro-resultado-final.json` contiene los ocho pasos; capturas de gráficos y tabla |
| Windows release nativo | Secuencia completa observada en pantalla; `windows/estadisticas-{0,1,2,deshacer}.jpg`, `lista-*`, formulario de anulación y `snapshot-*.json` |
| Android release, emulador | Secuencia completa en ambos temas; `android/p1-resultados.json`, ocho pasos, capturas de Lista/Estadísticas/tabla |
| Matriz de texto | 1920, 1366 y 360, letra 1 y 2, ambos temas: 24 sondas para singular/plural; sin excepción de diseño ni texto cortado. Chrome aporta capturas de las doce combinaciones, gráficos y tabla |

También se miró Windows nativo en ambos temas, con muestras de 1920/1366 y letra 1/2, incluida la ficha y fila a letra 2. Las vistas 1920/1366 son **anchos lógicos del banco**, ajustados a la pantalla disponible, no una afirmación sobre la resolución física del monitor. Android aporta las muestras de 360 y letra 2; las páginas se desplazan verticalmente. No se atribuye a cada captura aislada toda la matriz: la cobertura exhaustiva procede de widgets y Chrome, y las muestras nativas comprueban su representación en cada cliente.

## 3. P2 · O-124-1 — CUMPLE

Caso propio exacto: veinte por cargar en **0210282** y **0230482**, cuarenta de paso en **0220682**. En 22 deben aparecer sombras distintas en 0220282 y 0220482, con `neighbor-twenty-0220282` y `neighbor-twenty-0220482`. La revisión de lib/ y las sondas confirman una clave derivada de cada posición.

- **Debug:** cuatro sondas de widget, oficina 1920 y teléfono 360, Contenido/Carga; exigen ambas claves, rótulo `20′`, ausencia de errores y desmontaje limpio. En el emulador se repitieron ambos modos en APK debug; logcat del PID: sin «Duplicate keys» y sin `E/flutter`.
- **Release:** cuatro escenas Chrome, ambos anchos y modos, con montaje/desmontaje y cero errores JS dentro de esas escenas. Android APK release repite ambos modos y desmontaje, sin duplicados ni errores Flutter en logcat. Windows release se observó en pantalla en ambos modos, con las dos sombras, salida a Lista y retorno al plano sin fallo visible.
- **T-106:** el test original mantiene **exactamente tres sombras** en la 04, cada una con su clave y rótulo dentro de su celda: `0040282` → `2×20′`, `0040682` → `2×20′`, `0040882` → `20′`. Mantiene la exclusión de `0040482`, ambas leyendas y `takeException() == null`. Se ejecutó en la suite de 1841 y su archivo conserva su huella.

Evidencia: `android/edge-{debug,release}-resultados.json` y logcat, `web/edge-resultados.json`, `windows/edge-22-{carga,contenido}.jpg`, `edge-desmontaje-lista`, `edge-remontado` y las sondas propias. El error de arranque Web se registra aparte en O1; no se oculta bajo el resultado de las escenas.

## 4. P3 · Versiones y candidata — CUMPLE

`pubspec.yaml` declara **3.2.0+6** y `msix_version: 3.2.0.0`. `pubspec.lock` no cambia respecto de T-124, de la huella inicial ni en la copia. Se compilaron los tres destinos en release desde **lib/main.dart original**, sin configuración privada, sin `key.properties` y sin publicar. Las salidas se conservaron antes de compilar los bancos instrumentados.

| Destino | Comprobación del artefacto propio |
|---|---|
| Web | `candidata/web/version.json`: versión 3.2.0, build 6. `dart run tool/t92_verify.dart build/candidata-web` aprobó **57 archivos**, exit 0. Marcador `flutter-fire-auth` presente |
| Windows | `candidata/windows/baystream.exe`: FileVersion y ProductVersion **3.2.0+6**, leídos del ejecutable generado |
| Android | `candidata/app-release-3.2.0-6.aab`: manifiesto protobuf **dentro del AAB**, package `gt.cmartinez.baystream`, **versionCode 6**, **versionName 3.2.0**; firma de depuración permitida para esta aceptación |

Registros `candidata-*-resultado.json`, `candidata-*.log`, `t92-verify.log`, `windows-version.json`, `aab-manifest.json` y `candidata-metadatos.json`. El manifiesto de evidencia incluye sus SHA-256. No se generó ni instaló un MSIX nuevo; el punto pedido aquí fue comprobar el exe y la versión declarada de MSIX. Los avisos de compilación del SDK/plugins permanecen en los logs y no se convierten en un resultado distinto del análisis limpio.

## 5. P4 · Lista del piloto — CUMPLE

Se leyó [LISTA-PILOTO.md](C:/Proyectos/baystream-qa-r4/docs/piloto/LISTA-PILOTO.md). El cotejo **comando por comando de toda la sección 4**, incluida 4.5, está en [piloto-revision.md](C:/Proyectos/baystream-qa-r4/build/t125-aceptacion/piloto-revision.md). Los bloques PowerShell se analizaron sintácticamente sin ejecutarlos: cero errores. Las operaciones de mezcla, commit, etiquetas, publicación, cambio de rama, limpieza de salida, instalación y reversión se revisaron solamente como texto.

Se comprobaron estos supuestos:

- `master`, `origin/master` y `v3.1.1^{commit}` apuntan a **34d88380bd1b6de906d984c6e0302436a8d2c10b**; master es ancestro de sprint-4. La rama del árbol del piloto es master. No se cambió su estado.
- Los **cinco documentos modificados de Carlos** no aparecen en las rutas entrantes de `master..sprint-4`; se conservan los nombres en `piloto-documentos-modificados.txt`. No se abrieron ni editaron sus contenidos.
- `firebase.json` sirve `build/web` y el proyecto coincide con baystream-app. La instrucción de publicación es exclusivamente **`firebase deploy --only hosting --project baystream-app`**. Se verificaron las guardas de versión, build, Auth, ruta de limpieza y T-92; no se ejecutó Firebase.
- La vuelta Windows dispone del MSIX anterior con manifiesto **3.1.1.0**, publisher CN=BayStream y SHA-256 **7617CC8889BCDD44C46964772B2DF48D50D0D8C2EA1E335E5F7E134CCE20D73E**, igual a su archivo de huella. Se contó un certificado con ese sujeto, sin exportar ni leer claves privadas.
- La vuelta Android exige compilar/subir un **AAB 3.1.2 con versionCode 7**; el mapeo de esos argumentos a Gradle se revisó. La siguiente versión debe usar código al menos 8. No se construyó ni publicó esa reversión.

Se hizo una **muestra dirigida justificada** de rótulos de las secciones 0–3 y 5, y el paso **1.16 completo**. El censo registra 194 apariciones por sección y 136 coincidencias literales en lib/; una coincidencia no se tomó por sí sola como prueba de disponibilidad del control. La muestra cubre los flujos cambiados y aquellos cuyo rótulo podría desviar al piloto: identidad/escala, listado, modo, cuenta/publicación, solicitudes, salida, deshacer, navegación, sincronización y Estadísticas. La tabla de `piloto-revision.md` identifica los archivos y construcciones con variables. No se afirma una comprobación de todos los rótulos ni una ejecución de nube/cuentas/Honor. No se encontró discrepancia que obligue a corregir la lista.

## 6. Regresiones de los tres clientes

| Área | Windows nativo | Chrome visible | Android emulador |
|---|---|---|---|
| T-124, ficha de bahía y grupo | Bahías 21/22 durante asignación; 22 muestra su grupo 21/22/23 | 21/22/23 en Contenido y Carga | Las seis combinaciones; `completo-resultados.json` |
| T100_LLEGADA | 60 unidades; tres columnas 02/06/10; snapshot exacto **964 950 kg**; gráficos y tabla | Tres columnas y apertura de la bahía 02 desde Estadísticas | Tres columnas, gráficos y tabla |
| T99_SINTETICO_977 | 977, **24 columnas**, desplazamiento de proa a popa y tabla | 24 columnas y navegación | 24 columnas y tabla |
| H4 / 3.1.1 | Lleno TSTU0220071 sin OR confirmado por número; salida advierte el lleno sin fila | Carga sin OR, bloqueo de vacío sin listado y salida | Lleno sin fila y salida singular |
| H6 / 3.1.1 | Vacío OR 13 hallado por últimos dígitos; destino 0220084 y resaltado | OR/asignados y búsqueda general | OR 12, búsqueda general y resaltado 0210084 |
| H7 / T-123 | Carlos ejecutó el gesto; Codex observó y capturó **022-10-82 → 022-09-82**, intercambio correcto bajo el puntero tras desplazarse; cancelado | Mouse a 100 y 150 %, destino 0220982, cancelado y contacto liberado | Conductor actual, destino **0220984**, cancelado; `finally` libera también tras fallo sintético |
| Entregas 1 y 2 | Navegación, selector, ficha, acciones, Lista, Estadísticas y tabla observadas | Recorrido de carga y ambas vistas de estadísticas | Ficha, carga, búsqueda y ambas vistas |

La suite completa conserva la cobertura de las entregas 1 y 2 y las sondas adicionales amplían fichas, sumas, matriz de diseño, salida singular/plural y H1/H3–H7. Los recorridos de pantalla son regresiones dirigidas, no una nueva ejecución del piloto con cuentas o corpus. Las sumas sintéticas de T100 y 977 se recalcularon en las sondas propias de T-124. El total visible de T100 es **965.0 t**, redondeado; no se confundió con 965 000 kg.

El H7 de Windows fue manual porque la API de escritorio disponible hace un arrastre inmediato y no permite mantener DOWN durante la pulsación larga. Carlos soltó en nivel **82**, no en el nivel 84 propuesto; se informa el destino real. El diálogo de intercambio acredita el objeto situado bajo el puntero y no se confirmó ningún cambio. La comprobación automatizada de destino libre 84 corresponde al emulador. No se presenta el intento inmediato fallido del instrumento como fallo del producto.

## 7. Observaciones por prioridad y límites

**O1 · P3 · Error inicial conocido del banco Web T-122.** Con perfil temporal nuevo se conserva un `Error` de arranque; la pila alcanza la guarda «RenderBox was not laid out» del JS generado. O2 de las aceptaciones T-123 y T-124 ya registra ese síntoma del banco. Aquí no se repitió el control independiente T-99 de T-123 ni se aisló la instrucción que lo origina; por eso no se afirma una nueva demostración de causalidad. Las cuatro escenas O-124-1 tienen cero errores posteriores de montaje/desmontaje, y no hay duplicados. Los recorridos finales de P1 cumplen sus aserciones pero mantienen ese error de inicio en su JSON. Seguimiento recomendado para el banco en una tarea separada; no se corrigió.

**O2 · P3 · Alcance de la evidencia nativa y del instrumento.** La matriz completa de anchos/temas/letra se ejecutó en widgets y Chrome; Windows y Android aportan muestras nativas y secuencias funcionales. Windows debug se cubre mediante widgets de oficina y teléfono; el ejecutable Windows observado es release. H7 nativo incluye el gesto de Carlos, identificado arriba. El campo histórico `altoDp: 800` de `android/completo-resultados.json` es una etiqueta heredada del conductor: las condiciones reales fueron 1080×1920 píxeles, densidad efectiva 480, **360×640 dp**. Se conserva el registro original y la corrección se declara en `android/condiciones-finales.json`. Ninguno de estos límites se oculta como una ejecución distinta.

Los logs fallidos de los conductores, el intento de arrastre sin pulsación larga, los reintentos de selectores y las sondas fallidas quedan incluidos en el manifiesto. Las compilaciones y pruebas definitivas tienen sus salidas explícitas; no se sumaron intentos como casos distintos ni se repitió la suite para mejorar el resultado.

## 8. Entrega y decisión

Único archivo para versionar: **`docs/t125/aceptacion-codex.md`**. Evidencia local ignorada por Git bajo `build/t125-aceptacion/`; no se propone forzar su inclusión. El manifiesto excluye expresamente la copia de trabajo, sus cachés/compilaciones y los perfiles de Chrome; incluye los artefactos candidatos conservados, scripts, logs, resúmenes, capturas y el código final del banco. Las huellas históricas de instrumentación se conservan y `instrumentacion-final.json` identifica las fuentes finales.

El bloque siguiente es para **Carlos**, desde su árbol de **sprint-4** una vez incorporado únicamente este informe allí. Esta aceptación permanece en HEAD separado; Codex no ejecutó estos comandos:

```powershell
git add -- docs/t125/aceptacion-codex.md
git commit -m "Sprint 4: aceptacion de T-125 y candidata 3.2.0"
git push origin sprint-4
```

Tres líneas para Carlos:

1. P1–P4 cumplen; 3.2.0+6 compilada en los tres destinos y T-92 aprobado.
2. Suite única 1841/1841, sin omitidas; análisis cero; producto y pubspec.* intactos.
3. Aceptada con observaciones del banco y alcance nativo documentado; nada publicado.

Mensaje para Yov: «Capitán Codex cerró T-125 sobre d41ad8c: ACEPTADA con observaciones. P1–P4 comprobados, secuencia 25→26→27→26 con masas propias y sin cambios en alertas/comparación; O-124-1 aprobado; candidata release Windows/Web/AAB 3.2.0+6 verificada. Suite original única 1841/1841, cero omitidas y analyze cero. Regresiones sintéticas en los tres clientes; H7 Windows con gesto de Carlos y observación/cancelación de Codex. Se conserva el Error inicial conocido del banco Web y se declaran los límites nativos. Informe docs/t125/aceptacion-codex.md y evidencia build/t125-aceptacion, con huella del informe en manifest.json. No hubo cambios de producto, Git ni publicaciones».

**ALTO: Carlos decide**
