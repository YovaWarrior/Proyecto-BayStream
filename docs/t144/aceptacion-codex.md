# T-144 · Aceptación de Capitán Codex

**Estado vigente:** reaceptación NO PASA; T144-ACC-01 cerrado y T144-ACC-02 (P2) abierto. Véase la sección «Reaceptación» al final. El dictamen inmediato siguiente corresponde a la primera aceptación.

**Dictamen: NO PASA.** El paso 0 pasa completo, pero la sonda independiente del punto 4 encuentra un **P2: una consulta de solo espacios devuelve contenedores cuando tienen puerto o naviera**. Se detiene la aceptación al confirmar el primer fallo, conforme al encargo. No se corrigió código.

Fecha: **11-nov-2026**, horario de Guatemala (UTC−06:00). Carpeta: `C:\Proyectos\baystream-qa-r4`, HEAD separado en `2d91c54ae556f6a131c0b5c672b2419d03df1e1a`. Evidencia propia: `build/t144/aceptacion/`, ignorada por `/build/`.

## 1. Lecturas y preparación

Se leyeron los `CLAUDE.md` y `AGENTS.md` vigentes de `C:\Proyectos\baystream-rediseno`; SPRINT-4 10.109, 10.112, 10.117, 10.121, 10.123 y 10.124; y `docs/T144-RESULTADOS.md` completo, incluidas la propuesta y la fase 2. Se consultó la aceptación de T-143 para reproducir su preparación aislada. Se aplicó la skill `dart-run-static-analysis` únicamente para verificar, sin correcciones automáticas, exclusiones ni supresiones nuevas.

Carlos reservó **solo Windows**. El Honor no estaba disponible. No se utilizó ninguno de los dos y la reserva de Windows se liberó al detenerse. Se avisó con líneas `SEMÁFORO:` al ocupar y liberar el carril. Todos los comandos de Flutter/Dart de esta aceptación fueron consecutivos.

La copia nueva está en `build/t144/aceptacion/copia/`: **838/838 archivos cotejados por SHA-256**, con `lib/`, `test/`, `tool/`, integración, plataformas y recursos. Incluye los manifiestos y recursos Android que necesita la suite. Se omiten credenciales y artefactos de compilación anteriores.

Como en T-143, se recuperó la entrada **sintética** generada `build/t124/entradas/t124_entradas.dart` del banco anterior. Su SHA-256 es `d4384834fb9fc9cb18632b87180a7998cc3f91109edcbd33dbbf9787542d1162`. Es la preparación documentada para O-143-3 (10.121), todavía diferida; no se cambió el análisis para ocultarla. `manifiesto.json` identifica origen y huellas. No se reutilizaron resultados de pruebas anteriores.

Dos invocaciones iniciales del registrador tenían los argumentos en orden incorrecto y no llegaron a lanzar Flutter (`FileNotFoundError`). No cuentan como validaciones. La ejecución válida de `pub get` figura como `pub-get` en los registros.

## 2. Paso 0 — PASA

| Comprobación | Resultado propio | Evidencia relativa a `build/t144/aceptacion/` |
|---|---|---|
| `git log --oneline -3` | `2d91c54` (10.124), `35d88db` (T-144), `886fbb0` (10.123), en ese orden | `punta.json` |
| `git show --stat HEAD~1` | Título exacto «Sprint 4: T-144, el lector y el volcado»; 22 archivos, los de §2.7 del informe; 1748 inserciones y 52 eliminaciones | `punta.json` |
| `git show --stat HEAD` | Solo `SPRINT-4.md`, decisión 10.124; 37 inserciones y 1 eliminación | `punta.json` |
| Diff inicial de contenido | `git diff --stat` vacío; solo avisos LF→CRLF en los tres archivos generados de Windows | `punta.json` |
| HEAD separado | El archivo HEAD del worktree contiene el hash, sin referencia de rama | `manifiesto.json` |
| `flutter pub get` | Salida 0; «Got dependencies!»; sin cambios de pubspec | `pub-get.log`, `pub-get-ejecucion.json` |
| `flutter analyze --no-pub` desde la raíz de la copia, todo el paquete | Salida 0; «No issues found!» | `analyze.log`, `analyze-ejecucion.json` |
| `flutter test --no-pub --machine`, suite completa en una sola corrida | **2202 aprobadas, 0 fallidas, 0 omitidas**; salida 0 y evento final `success: true` | `suite.log`, `suite-resumen.json`, `suite-ejecucion.json` |
| `dart run tool/t141_fuzz_baplie.dart` | **180 mutantes, 0 fallas**: 68 leídos y 112 rechazados con mensaje; salida 0 | `fuzz.log`, `fuzz-ejecucion.json`, `copia/build/t141/fuzz-baplie.json` |
| Integridad al cerrar | Origen y copia mantienen los **838/838 archivos** del manifiesto sin diferencias, incluidos ambos pubspec | `integridad.json` |

Las 47 pruebas entregadas de T-144 están incluidas en las 2202; esto no sustituye los recorridos independientes pendientes.

## 3. Puntos de aceptación

Se adelantó la sonda independiente de búsqueda después del paso 0. Al fallar, no se continuó con los demás puntos.

| Punto | Dictamen | Evidencia y límite |
|---|---|---|
| 1. Dos y tres DGS, detalle, Lista y CSV; una DGS como en 1.0.0 | **PENDIENTE** | Las pruebas entregadas pasaron en la suite; no se ejecutó la aceptación propia de este punto. |
| 2. «Destino final» solo con LOC+83, tal cual viene | **PENDIENTE** | Sin recorrido propio; no se acredita por la suite entregada. |
| 3. A06, 717 contenedores, puertos, escala GTPBR y movimientos locales | **PENDIENTE** | No se leyó A06 ni se registraron movimientos. No se abrió ningún almacén de Windows. |
| 4. Búsqueda «bysu 967» y consulta de solo espacios | **NO PASA** | La consulta de matrícula devuelve el contenedor correcto. Tres espacios devuelven 1 resultado en vez de 0: T144-ACC-01. |
| 5. DIM 5 a 9 en CMT e INH, interfaz y salida idéntica | **PENDIENTE** | Sin aceptación propia ni BAPLIE de salida propio. |
| 6. Avisos UN/LOCODE con causa y acción; excepciones XX y asteriscos | **PENDIENTE** | Sin recorrido propio del resumen. |
| 7. Lectura del viaje nuevo y lista de viajes con código v1.0.0 extraído aparte | **PENDIENTE** | No se extrajo v1.0.0 ni se ejecutó la compatibilidad real. La prueba entregada no se presenta como sustituto. |
| 8. Windows r4, Chrome visible y Honor a 360 dp, escalas 1.0/1.45/2.0 y español | **PENDIENTE** | No se compilaron ni abrieron clientes. Honor no disponible; no hay capturas de aceptación. |

## 4. T144-ACC-01 · P2 · Solo espacios encuentra contenedores con puertos

**Requisito incumplido:** punto 4 del encargo: «una consulta de solo espacios no encuentra nada».

**Reproducción independiente:**

1. La sonda `copia/build/t144acc/busqueda_test.dart` escribe dentro del propio archivo un BAPLIE 2.x sintético de un contenedor: `BYSU 9672095`, puerto de carga `GTSTC`, descarga `PAMIT`, buque `BUQUE SINTETICO`. La matrícula procede del ejemplo del encargo, no del corpus.
2. Lo interpreta con `BaplieParserService` real y comprueba matrícula `BYSU9672095` y ambos puertos.
3. Renderiza `ContainerSearchDelegate.buildResults` real, dentro de `ProviderScope` y del tema del producto, con la consulta `bysu 967`: obtiene **1 resultado**, correcto.
4. Renderiza la misma búsqueda con tres espacios ASCII (`[32, 32, 32]`): obtiene **1 resultado**, esperado **0**. No hubo excepción de renderizado; falla la expectativa funcional.

Comando para reproducir, con el carril de Flutter libre:

```powershell
# Desde C:\Proyectos\baystream-qa-r4\build\t144\aceptacion\copia
C:\flutter\bin\flutter.bat test --no-pub --machine build/t144acc/busqueda_test.dart
```

**Resultado ejecutado:** salida 1, un caso aprobado y uno fallido, ninguno omitido. `busqueda.log` contiene:

```text
T144ACC consulta=[98, 121, 115, 117, 32, 57, 54, 55] resultados=1 puertos=GTSTC/PAMIT
T144ACC consulta=[32, 32, 32] resultados=1 puertos=GTSTC/PAMIT
Expected: <0>
  Actual: <1>
Una consulta de solo espacios no debe encontrar nada.
```

**Causa comprobada por lectura:** `lib/features/vessel/presentation/widgets/container_search_delegate.dart:77` solo comprueba `query.isEmpty` antes de normalizar. En las líneas 81–92, la consulta se convierte en `''`; `matchesId` sí exige texto, pero `matchesPod`, `matchesPol` y `matchesOperator` todavía usan `contains(normalizedQuery)` sin esa condición. Cualquier puerto o naviera no nulos coincide con `contains('')` y hace verdadero el filtro.

**Impacto y prioridad:** la búsqueda presenta coincidencias para una consulta que no contiene ningún término. Incumple un criterio explícito de aceptación; **P2**, sin evidencia de pérdida de datos ni de caída de la app. La suite verde no cubre esta condición.

**Corrección propuesta para Timonel, sin implementarla:** impedir la búsqueda con una consulta vacía tras normalizar, antes de evaluar cualquier campo, y fijar el caso con puertos y naviera declarados en una prueba permanente. Mantener el caso positivo de matrícula con espacios. Después, retomar esta aceptación y sus puntos pendientes.

Evidencia: `busqueda.log`, `busqueda-stderr.log`, `busqueda-resumen.json`, `busqueda-ejecucion.json` y la sonda completa citada. Es una prueba de widget ejecutada; no se afirma que sea una captura o un recorrido de Windows, Chrome u Honor.

## 5. Horas y límites de la ejecución

Todas las horas son del **11-nov-2026, Guatemala**; los JSON guardan UTC.

| Actividad | Inicio | Fin |
|---|---|---|
| Primera hora de preinspección registrada | 23:00:48 | — |
| `pub get` válido | 23:02:15 | 23:02:19 |
| Análisis completo | 23:02:25 | 23:03:21 |
| Suite completa | 23:03:32 | 23:07:58 |
| Fuzzing | 23:08:07 | 23:08:09 |
| Sonda independiente de búsqueda | 23:08:13 | 23:08:20 |
| Cotejo final de integridad | 23:08:47 | 23:08:47 |
| Cierre del informe | 23:10:44 | 23:10:44 |

Son horas de ejecución, **no mediciones H5**. La aceptación se detuvo al comprobar la falla de búsqueda; después solo se cerró la evidencia y se redactó este informe.

No se ejecutaron `git status`, escrituras de Git ni publicaciones. No se contactó Firebase real, no se abrió el corpus y no se copió ningún dato del corpus al repositorio. No se usó el almacén predeterminado, el real ni uno con namespace `t144acc`: la prueba fallida no requiere persistencia. No hay movimientos que limpiar. La aceptación de persistencia y su comprobación fuera del paquete siguen pendientes.

## 6. Archivos y Git para Carlos

**Único archivo versionable creado:** `docs/t144/aceptacion-codex.md`.

**Código de producto, pruebas permanentes y configuración:** sin cambios. **`pubspec.yaml` y `pubspec.lock` no cambian**, ni en el origen ni en la copia. No se tocaron los congelados, `lib/main.dart`, opciones Firebase ni `.claude/settings.local.json`.

El instrumental, la sonda, la copia y los registros nuevos están exclusivamente bajo `build/t144/aceptacion/`, excluido por `/build/`. Se conservan localmente para reproducir el hallazgo; no se propone forzar su incorporación a Git. Los manifiestos y registros citados identifican su contenido.

Este bloque versiona **solo el informe de NO PASA**; lo ejecuta Carlos desde `qa-r4`:

```powershell
Set-Location C:\Proyectos\baystream-qa-r4
git add -- docs/t144/aceptacion-codex.md
git commit -m "Sprint 4: aceptacion de T-144"
git push origin HEAD:sprint-4
```

## 7. Tres líneas

1. El paso 0 pasa: punta exacta, análisis cero, suite 2202/2202 sin omitidas y fuzzing 180/0.
2. T144-ACC-01 (P2): una búsqueda de solo espacios aún encuentra contenedores con puertos; no se corrigió código.
3. T-144 NO PASA; quedan pendientes los demás recorridos, la vuelta real a v1.0.0 y los tres clientes.

## 8. Mensaje para Yov

> Yov, T-144 NO PASA sobre 2d91c54 en qa-r4. Paso 0 completo: 22 archivos exactos de 35d88db y solo 10.124 encima; analyze cero, 2202/2202 sin omitidas y fuzzing 180/0. La sonda propia confirma T144-ACC-01, P2: «bysu 967» encuentra BYSU9672095, pero tres espacios devuelven 1 resultado cuando hay puertos, esperado 0; los filtros de puertos/naviera hacen contains('') sin protección. Me detuve sin corregir código ni abrir clientes, corpus o almacenes. Informe: docs/t144/aceptacion-codex.md; evidencia local: build/t144/aceptacion/. Windows liberado; Honor no estaba disponible. Quedan pendientes los demás recorridos y la lectura real con v1.0.0.

---

## Reaceptación · Corrección 1 (10.125 y 10.126)

**Dictamen: NO PASA. T144-ACC-01 queda CERRADO; aparece T144-ACC-02 (P2).** El paso 0 pasa con `analyze` en cero y **2213/2213 sin omitidas**. La búsqueda supera la sonda propia ampliada. La prueba Android nativa a 360 dp confirma que, con letra 2.0, **la matrícula del título del detalle se corta con puntos suspensivos**. Se detiene la aceptación al primer fallo de producto confirmado, sin corregir código.

Ejecución: **11-nov-2026**; cierre del informe: **12-nov-2026**, horario de Guatemala. HEAD separado: `e488802b57f2acc1bf9adbc9adf52c91070965db`. Evidencia nueva: `build/t144/aceptacion/reaceptacion1/` (en adelante, **R1**). Se conserva intacta la evidencia de la primera aceptación.

### R1.1 · Base y paso 0 — PASA

Se releen los acuerdos vigentes de `baystream-rediseno`, las decisiones 10.125 y 10.126, la sección «Corrección 1» de `docs/T144-RESULTADOS.md` y este informe. Siguen vigentes el encargo original y sus lecturas de 10.109, 10.112, 10.117, 10.121, 10.123 y 10.124. O-144-1 se excluye expresamente de los hallazgos de esta aceptación.

| Comprobación propia | Resultado | Evidencia en R1 |
|---|---|---|
| Punta y commits | `e488802` (10.126) sobre `dbc3d57` («Sprint 4: T-144, correccion 1, la busqueda con solo espacios»), sobre `28438f0` (10.125) | `punta.json` |
| Alcance de la corrección | Los cuatro archivos exigidos: los dos de búsqueda, `test/t144_lector_volcado_test.dart` y `docs/T144-RESULTADOS.md`; 179 inserciones, 3 eliminaciones | `punta.json` |
| Commit superior | Solo `SPRINT-4.md`, 16 inserciones y 1 eliminación | `punta.json` |
| Árbol de contenido al empezar | Diff vacío, con los avisos de fin de línea conocidos en los tres generados de Windows | Lectura inicial y `punta.json` |
| Copia limpia nueva | 838 archivos cotejados por SHA-256; HEAD separado comprobado leyendo el HEAD del worktree | `manifiesto.json`, `preparar.py` |
| `flutter pub get` | Salida 0; sin cambios de pubspec | `pub.log`, `pub-ejecucion.json` |
| `flutter analyze --no-pub`, todo el paquete | **Cero incidencias**, salida 0 | `analyze.log`, `analyze-ejecucion.json` |
| Suite completa, una sola corrida | **2213 aprobadas, 0 fallidas, 0 omitidas**, salida 0; incluye las 58 de T-144 | `suite.log`, `suite-resumen.json`, `suite-ejecucion.json` |
| Fuzzing | No se repite: exento por el encargo de reaceptación, el lector no cambió | — |
| Integridad del origen al cerrar | **838/838 sin diferencias**; incluidos `pubspec.yaml` y `pubspec.lock` | `integridad.json` |

La copia vuelve a incluir la entrada sintética generada de T-124, con la misma huella de la primera aceptación. No se añaden exclusiones ni supresiones al análisis. Las sondas nuevas se ejecutan aparte y **no se suman a las 2213**.

### R1.2 · T144-ACC-01 — CERRADO

Se reutilizó la sonda propia original `build/t144acc/busqueda_test.dart` dentro de la copia nueva, ampliándola con tabulación y espacio duro, y con la comprobación del estado inicial. No se sustituyó por la prueba entregada por Timonel.

| Consulta | Resultados | Comprobación |
|---|---|---|
| `bysu 967` | 1 | `BYSU9672095`, leído del BAPLIE sintético propio |
| Tres espacios ASCII | 0 | Estado inicial y sugerencias; sin «Sin resultados» |
| Una tabulación | 0 | Estado inicial y sugerencias; sin «Sin resultados» |
| Un espacio duro U+00A0 | 0 | Estado inicial y sugerencias; sin «Sin resultados» |

**4/4 casos pasan**, ninguno omitido, salida 0. Evidencia: `busqueda.log`, `busqueda-resumen.json`, `busqueda-ejecucion.json` y `copia/build/t144acc/busqueda_test.dart`.

### R1.3 · Puntos pendientes del encargo original

Se escribió un BAPLIE propio de seis contenedores, sin leer el corpus: DGS 2/3/1, LOC+83 con texto libre, DIM 5 a 9 en CMT y en INH, dos puertos erróneos, `XXVSL` y asteriscos. Está en `copia/build/t144acc/sintetico.edi`, con su versión Dart y los identificadores en `sinteticos.json`.

La sonda propia `copia/build/t144acc/sintetico_test.dart` ejecuta el lector y el CSV reales y renderiza los widgets de producto en una página de prueba. La ejecución válida es `sintetico-valido`: **1/1, salida 0**. Una ejecución anterior de la sonda esperaba dos líneas por los dos puertos inválidos de un mismo contenedor; el lector agrupa correctamente ambas causas en una línea. También agrupa los cinco avisos INH de ese contenedor. Se corrigió **solo la expectativa del instrumento** para comprobar las causas conservadas, no su número de líneas. No es un hallazgo de producto.

| Punto | Resultado propio y límites | Evidencia en R1 |
|---|---|---|
| 1. Peligrosas | **PASA en la sonda funcional**: detalle con títulos de 2 y 3 declaraciones y líneas en orden; Lista «IMO 3 +1»/«IMO 3 +2», hoja con 2/3 filas; CSV `3 \| 8` y `3 \| 8 \| 2.1`, números ONU emparejados y «DGS declarados» 2/3. Con una DGS, título, filas y celdas anteriores. No se acreditan recorridos completos de Windows o Chrome. | `sintetico-valido.log`, sonda y entrada propias |
| 2. Destino final | **PASA en la sonda funcional**: «PA - DESTINO SINTETICO» aparece tal cual en detalle y CSV; «Destino final» no aparece en los contenedores sin LOC+83. | Misma sonda |
| 3. A06 y operación local | **PENDIENTE**. No se abrió A06 ni se registraron descarga/carga. | Detención por T144-ACC-02 |
| 5. DIM | **PARCIAL, no aceptado completo**. CMT: frente/atrás/derecha/izquierda/alto = 31/12/9/7/19 cm. INH 2/3/4/5/6 = 5/8/10/13/15 cm, ambos OOG, con los cinco avisos de conversión y acción visible. Quedan pendientes insignia, línea de medidas y BAPLIE de salida idéntico. | Misma sonda |
| 6. UN/LOCODE | **PASA en la sonda funcional**: país ZZ inexistente y GT-PB mal formado, ambas causas y acción en resumen; el archivo abre. XXVSL y asteriscos no generan aviso. No se atribuye un recorrido nativo completo. | Misma sonda, toque real del aviso del widget |
| 7. Vuelta a 1.0.0 | **PENDIENTE**. Se extrajo `v1.0.0` mediante `git archive` a TEMP, fuera de los árboles; no se ejecutó la lectura con ese código ni la lista de viajes. | `legacy-path.txt` |
| 8. Tres clientes y 360 dp | **NO PASA** en Android nativo por T144-ACC-02. La Lista pasa las escalas 1.0, 1.45 y 2.0; el detalle pasa 1.0 y 1.45, pero corta su matrícula en 2.0. Windows r4, Chrome y la comprobación íntegra del español quedan pendientes. | `android.log`, `android-ejecucion.json`, seis capturas PNG |

La disponibilidad se coordinó de nuevo con Carlos: **Windows reservado; usar emulador**. No se usó el Honor; queda explícitamente en la **lista de comprobación de la versión**, conforme a 10.126. Windows no llegó a abrirse y su reserva se liberó al detenerse.

### R1.4 · Android: entorno y evidencia nativa

Se utilizó `t99_api26`, Android **8.0.0**, `emulator-5554`. Resolución de prueba **1080 × 2400 px**, densidad **480 dpi** (3 píxeles por dp): el `Scaffold` midió **360 dp**. Las escalas **1.0, 1.45 y 2.0** se aplicaron mediante `MediaQuery`/`TextScaler.linear` en el banco; `font_scale` del emulador quedó en 1.0 como base. Esto no se presenta como una medición del escalado no lineal de Android moderno ni como una prueba del Honor.

Se compilaron y ejecutaron los widgets **reales** `ContainersListView` y `DetalleContenedor`, dentro de una página de integración con el tema de muelle `BayStreamTema.claro` y las fuentes empaquetadas. Es un banco nativo de los componentes; **no** se presenta como navegación completa de `BayStreamApp`. El APK tiene identidad aislada `gt.cmartinez.baystream.t144acc`; solo en la copia se añadieron el sufijo de aplicación y el rótulo de prueba a los dos archivos Android. El código bajo `lib/` es idéntico a la punta.

La prueba captura la pantalla antes de evaluar todos sus `RenderParagraph.didExceedMaxLines`. El registro nativo da:

```text
android-lista-1.0    ancho=360.0 cortados=[]
android-detalle-1.0  ancho=360.0 cortados=[]
android-lista-1.45   ancho=360.0 cortados=[]
android-detalle-1.45 ancho=360.0 cortados=[]
android-lista-2.0    ancho=360.0 cortados=[]
android-detalle-2.0  ancho=360.0 cortados=[TSTU 144000 2]
```

Capturas recuperadas desde los archivos privados de la app de prueba a R1:

- `android-lista-1.0.png`, `android-lista-1.45.png`, `android-lista-2.0.png`;
- `android-detalle-1.0.png`, `android-detalle-1.45.png`, **`android-detalle-2.0.png`**.

`android-dispositivo.json` conserva resolución, densidad, versión y huellas de las capturas. `metricas.json` conserva la salida del banco. `android.log` contiene el fallo de expectativa; la compilación y la instalación sí terminaron. El aviso Java de operaciones unchecked del plugin Firestore y un intento de Flutter de desinstalar el identificador base inexistente en el emulador están en stderr: no impidieron ejecutar las seis pantallas ni causan el fallo de texto.

### R1.5 · T144-ACC-02 · P2 · La matrícula se corta en el título del detalle con letra 2.0

**Criterio incumplido:** punto 8: Lista y detalle a 360 dp con letra 1.0, 1.45 y 2.0, **sin textos cortados**. O-144-1 no interviene.

**Cómo reproducir:**

1. Abrir el detalle del contenedor sintético `TSTU1440002`, con naviera `TEST`, en un cliente Android de 360 dp y tema de muelle.
2. Aplicar escala de texto lineal 2.0, como en la matriz de aceptación.
3. Observar el título: muestra **`TSTU 1440…`** en lugar de **`TSTU 144000 2`**. La naviera sigue ocupando el lado derecho.

**Evidencia ejecutada:** `copia/integration_test/t144acc_mobile_test.dart`, salida 1; `android-detalle-2.0.png`, inspeccionada visualmente; y la detección `didExceedMaxLines == true` únicamente para la matrícula. Las otras cinco combinaciones no detectan párrafos cortados.

**Causa comprobada:** el encabezado de `detalle_contenedor.dart:128` es un `Row` con icono, matrícula en `Expanded` y naviera a su derecha. `bs_numero_de_contenedor.dart:34` fija `maxLines: 1` y `TextOverflow.ellipsis`. Al crecer la letra se consume el ancho disponible y se oculta parte de la identificación. No se demuestra que sea una regresión de la corrección 1; es un incumplimiento reproducido del criterio actual.

**Prioridad P2:** el identificador operativo no se ve completo en un tamaño de texto exigido. No hay evidencia de pérdida del identificador almacenado ni de caída de la app.

**Propuesta para Timonel, sin implementar:** adaptar el encabezado estrecho/con letra grande para conservar la matrícula completa, incluida la naviera, y fijar esta combinación con las fuentes reales. Mantener las combinaciones que ya pasan. Después se retoma la aceptación, incluidos A06, DIM de salida, lectura real con v1.0.0 y los clientes pendientes.

Comando del instrumento, con un emulador reservado y configurado como arriba y el carril libre:

```powershell
# Desde C:\Proyectos\baystream-qa-r4\build\t144\aceptacion\reaceptacion1\copia
C:\flutter\bin\flutter.bat test integration_test/t144acc_mobile_test.dart -d emulator-5554
```

### R1.6 · Horas, integridad y límites

Horas de Guatemala, **11-nov-2026**; los JSON guardan UTC:

| Actividad | Inicio | Fin |
|---|---|---|
| Primera preinspección registrada | 23:46:14 | — |
| `pub get` válido | 23:47:02 | 23:47:07 |
| Análisis completo | 23:47:15 | 23:48:25 |
| Suite completa | 23:48:50 | 23:51:57 |
| Sonda de búsqueda | 23:52:21 | 23:52:26 |
| Sonda sintética, expectativa de agrupación incorrecta | 23:52:31 | 23:52:35 |
| Sonda sintética válida | 23:53:07 | 23:53:11 |
| Compilación, instalación y prueba Android | 23:55:14 | 23:57:14 |
| Detención y cierre de evidencia/ emulador | 23:57–23:58 | 23:58:37 |
| Informe y cotejo del cierre (12-nov) | 00:00:45 | 00:01:39 |

No son mediciones H5. Los comandos Flutter fueron consecutivos. Tras el fallo solo se recuperaron capturas, se documentó la causa y se cerró la evidencia; no se continuaron los recorridos de aceptación. Se restablecieron tamaño y densidad del emulador y se cerró el proceso de prueba.

`integridad.json`: **838/838 archivos de origen intactos**. En la copia solo difieren los dos archivos Android de identidad aislada, modificados después de la suite. El índice final identifica las sondas añadidas por sus rutas; no forman parte del código entregado por Timonel.

No se ejecutaron `git status`, escrituras de Git ni publicaciones. No se contactó Firebase real; no se inicializó Firebase en el banco nativo. No se abrió ni se copió el corpus. No se abrió el almacén de Windows, ni el predeterminado ni el real; tampoco se registraron movimientos en `t144acc`. Android escribió exclusivamente capturas y métricas en su directorio privado de prueba. La aceptación del almacén de movimientos sigue pendiente.

### R1.7 · Archivos y Git para Carlos

**Único archivo versionable modificado por Codex:** `docs/t144/aceptacion-codex.md` (esta reaceptación). **`pubspec.yaml` y `pubspec.lock` no cambian**, ni en el origen ni en la copia. Tampoco cambia código del producto, pruebas permanentes ni archivos restringidos.

El instrumental nuevo está solo bajo R1, ignorado por `/build/`: preparación, sonda ampliada, sintético propio, prueba de integración, registros, manifiestos y capturas. La extracción de v1.0.0 está en TEMP, fuera del repositorio. No se propone incorporar estas copias ni forzar archivos ignorados.

El bloque versiona **el informe de NO PASA**, con T144-ACC-01 cerrado y T144-ACC-02 abierto. Lo ejecuta Carlos desde qa-r4:

```powershell
Set-Location C:\Proyectos\baystream-qa-r4
git add -- docs/t144/aceptacion-codex.md
git commit -m "Sprint 4: reaceptacion de T-144"
git push origin HEAD:sprint-4
```

### R1.8 · Tres líneas

1. La corrección 1 cierra T144-ACC-01; analyze cero y suite 2213/2213 sin omitidas.
2. T144-ACC-02 (P2): Android real en emulador, a 360 dp y letra 2.0, corta la matrícula en el título del detalle; hay captura nativa.
3. T-144 NO PASA; no se corrigió código y quedan pendientes A06, la salida DIM, la vuelta real a v1.0.0, Windows y Chrome; Honor va a la lista de la versión.

### R1.9 · Para Yov

> Yov, reaceptación de T-144 NO PASA sobre e488802. Paso 0 correcto: cuatro archivos de dbc3d57 y solo 10.126 encima, analyze cero y 2213/2213 sin omitidas. T144-ACC-01 cerrado con sonda propia: tres espacios, tabulación y espacio duro dan cero y estado inicial; «bysu 967» funciona. DGS 2/3/1, LOC+83 y avisos pasan la sonda funcional. Nuevo T144-ACC-02, P2: en Android nativo (emulador autorizado), a 360 dp y letra 2.0, el título del detalle muestra «TSTU 1440…»; captura android-detalle-2.0.png en build/t144/aceptacion/reaceptacion1/. Me detuve sin corregir código. Quedan A06, salida DIM, lectura real con v1.0.0, Windows y Chrome. Honor va a la lista de la versión. Informe: docs/t144/aceptacion-codex.md.
