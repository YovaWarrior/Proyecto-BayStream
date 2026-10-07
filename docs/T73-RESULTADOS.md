# T-73 · Importar el listado de la agencia, con equivalencias y peligrosas

Timonel · 7-oct-2026 · rama `sprint-3`, sobre `fe2f29a` · carril de `lib/`, `test/` y `pubspec.*`

## 1. Resultado

**T-73 hecha.** Todas las cifras de la ficha cuadran, por programa contra el corpus y en pantalla en los tres clientes.

| Criterio de la ficha | Esperado | Corpus (A08 y A08v_VGM) | Windows | Honor 360 dp | Chrome |
|---|---|---|---|---|---|
| Filas y agencias | 176 en 4 | 176 en 4 (40, 18, 27, 91) | PASA | PASA | PASA |
| Filas sin entender | 0 | 0 | PASA | PASA | PASA |
| Llenos que cruzan uno a uno | 120 | 120, ninguno con datos distintos | PASA | PASA | PASA |
| Vacíos en los 6 grupos | 20, 17, 9, 7, 2, 1 | 20, 17, 9, 7, 2, 1 · 56 de 56 | PASA | PASA | PASA |
| Equivalencias que se proponen solas | 40HC → 45G1, 20ST → 22G1, 40ST → 42G1, COMNG → COSPC, LNB → LINB | Las cinco, y ninguna más | PASA | PASA | PASA |
| Equivalencia que se pide | 40RF → 45R1 | Solo 40RF, con 45R1 como sugerencia | PASA (escrita a mano) | PASA (sugerencia) | PASA (sugerencia) |
| OR 127 | Clase 9, UN 3082 y 3077, aviso | Clase 9, UN 3082 y 3077; «el plan no trae UN 3082» | PASA | PASA | PASA |
| OR 130 | VGM 7 266.59 kg | 7 266.59 (el plan dice 7 200) | PASA | PASA | PASA |
| Persistencia | Equivalencias tras cerrar; la segunda importación no pide nada | Hive en carpeta temporal, cerrar y reabrir | PASA | PASA | PASA |

Además, el cruce dice lo que encontró Yov: **47 llenos con VGM distinto del plan, y el plan suma 2.4 t menos que el listado.**

**Validaciones:**
- **`flutter test`:** **405/405** (piso 383 + 22 nuevas), sobre el código final.
- **`flutter analyze`:** **cero**, sin `// ignore:`.
- **Corpus de T-73:** **2/2** (`tool/t73_corpus_test.dart`, con A08 y A08v_VGM).
- **Corpus anterior sin regresiones:** T-68, T-69 y T-72, **22/22**.
- No se tocó `lib/main.dart`, ninguna pantalla H5 ni nada fuera del carril.

## 2. Dependencias: lo único que cambia en `pubspec`

### 2.1 `excel_community 1.0.10` (el lector de Excel autorizado en 2.7)

| | |
|---|---|
| Paquete | [`excel_community`](https://pub.dev/packages/excel_community) **1.0.10**, versión fija |
| Licencia | MIT. Es una bifurcación de `excel` (justkawal), con su copyright en el archivo LICENSE |
| Publicador | decksplayer.com, verificado en pub.dev |
| Plataformas | Dart puro, sin código nativo. pub.dev lo marca Android, iOS, Windows, Linux, macOS y **Web**, y está listo para Wasm |
| Dependencias | `archive`, `xml`, `collection`, `equatable` y `web`. **Todas estaban ya en el lock**, en versiones compatibles |

**Por qué ese paquete y esa versión:**
- **`excel 4.0.6` y `spreadsheet_decoder 2.3.0`** piden `archive ^3`. El lock tiene `archive 4.0.9`, que exige `image` (dependencia de `pdf`). Para usarlos habría que bajar `archive` y también `image` a una versión vieja. Descartados.
- **`excel_community` 1.1 en adelante y `excel_plus`** piden `xml ^7`, y `pdf 3.12.0` exige `xml < 7`. No resuelven.
- **`excel_community 1.0.10`** es la última que resuelve con `archive 4.0.9` y `xml 6.6.1`.
- **Revisé su código antes de elegirla:**
  - lee `inlineStr`, que es como viene `LISTADO_A08.xlsx`, sin `sharedStrings.xml`;
  - lee `sharedStrings`, que es lo que escribe Excel;
  - las fórmulas llegan como `FormulaCellValue`, sin el valor guardado. Da igual, porque el neto se recalcula siempre;
  - lee `3900.0` como entero y las horas con formato de hora como `TimeCellValue`.
- **Fork joven (revisión de Yov):** la 1.0.0 salió en marzo de 2026 y hoy va por la 2.6.0. Por eso va con versión fija, y por eso el defecto de la sección 2.2 se corrige de nuestro lado y no esperando una versión nueva.

### 2.2 `archive 4.0.9`, ahora directa (autorizada por Carlos el 7-oct, opción A)

- **El defecto:** `excel_community` resuelve las rutas absolutas de `workbook.xml.rels` solo para `sharedStrings`. Para la hoja y los estilos arma `xl/` + destino.
- **Por qué importa:** `LISTADO_A08.xlsx` declara `Target="/xl/worksheets/sheet1.xml"`, que es OOXML válido y es lo que escribe openpyxl. El paquete busca `xl//xl/worksheets/sheet1.xml`, no la encuentra y falla con un *null check*.
- **No hay versión que lo arregle:** la 2.6.0 tiene el mismo código.
- **La corrección (`ExportListParserService.withRelativeTargets`):**
  - antes de entregar el libro, se vuelven relativos todos los destinos absolutos de `workbook.xml.rels`: hoja, estilos, `sharedStrings`, tema y rutas fuera de `xl/` (`/customXml/…` pasa a `../customXml/…`);
  - los enlaces externos y lo que ya es relativo no se tocan;
  - si no hay nada que corregir, el libro pasa intacto: es el mismo objeto, sin volver a comprimirlo.
- `LISTADO_A08.xlsx` no se tocó: es el caso de prueba.

### 2.3 Diff de `pubspec.lock`

Solo esto: `archive` pasa a directa (sigue en 4.0.9) y entra `excel_community`. **Ningún otro paquete cambia.**

```diff
@@ archive
-    dependency: transitive
+    dependency: "direct main"
@@ (después de equatable)
+  excel_community:
+    dependency: "direct main"
+    description:
+      name: excel_community
+      sha256: f80fb8bb07432cb184f96fdaac69bb7e55bada1ddbf374f41f59e4542bd5b9b0
+      url: "https://pub.dev"
+    source: hosted
+    version: "1.0.10"
```

En `pubspec.yaml`, debajo de `hive_ce`, con su comentario: `excel_community: 1.0.10` y `archive: 4.0.9`.

## 3. Qué se construyó

| Archivo | Capa | Contenido |
|---|---|---|
| `domain/entities/export_list.dart` (nuevo) | Dominio | `ExportList`, `ExportListRow` (códigos del Excel y códigos traducidos), `ExportListIssue` y `CodeEquivalences` (tipos, puertos y líneas, con JSON) |
| `domain/services/export_list_cross_checker.dart` (nuevo) | Dominio | `propose` (propuesta de equivalencias), `tableOf`, `crossCheck` (llenos por número, vacíos por grupo, lo que no cruza, peligrosas y VGM) |
| `domain/repositories/export_list_repository.dart` (nuevo) | Dominio | Contrato de lectura del listado |
| `data/services/export_list_parser_service.dart` (nuevo) | Datos | Lector por encabezado, rejilla neutra, CONTENIDO → clase y UN, rutas relativas |
| `data/repositories/export_list_repository_impl.dart` (nuevo) | Datos | Implementación del contrato |
| `presentation/providers/export_list_providers.dart` (nuevo) | Presentación | `movementLogRepositoryProvider` (la bitácora de T-72) y `ExportListImportNotifier` |
| `presentation/pages/export_list_import_page.dart` (nuevo) | Presentación | La pantalla de importación |

**Archivos existentes que cambian:**
- `local_vessel_repository.dart`, `local_vessel_repository_impl.dart` y `hive_vessel_data_source.dart`: `getCodeEquivalences` y `saveCodeEquivalences`, en la **caja de ajustes** del almacén local, junto al último puerto confirmado de T-68.
- `entities.dart`: exporta `export_list.dart`.
- `core/errors/exceptions.dart`: `ExportListParsingException`.
- `vessel_overview_page.dart`: el botón «Listado de la agencia», junto a «Alertas de estiba». Va en un `Wrap`, así que a 360 dp baja de línea. Solo aparece si el viaje tiene escala y algo que cargar en ella.

### 3.1 Lectura del Excel

- **Encabezados por nombre.** La primera fila que tenga OR y CONTENEDOR es la de encabezados. Se normalizan mayúsculas, tildes y espacios.
- **Columnas obligatorias:** OR, CONTENEDOR, TIPO, POD, TARA, PESO VGM, F, E, CONTENIDO y OPR. Las demás (POT, PESO NETO, REEFER TEMP, ORIG, HORA y MARCHAMO) son opcionales.
- Si falta una columna obligatoria, no se lee nada y el mensaje dice cuál falta.
- **Separadores de agencia:** una fila sin OR numérico que contiene «CODIGO». La agencia es el texto anterior a «CODIGO», y cada contenedor guarda la suya.
- **Filas sin entender:** se informan con su número de fila y su motivo. Son las que no marcan F ni E (o marcan las dos), las que no traen número, tipo, POD, línea o tara, un lleno sin VGM, un número de contenedor o de orden repetido, un OR con decimales o una fila de texto suelto.
- **PESO NETO se recalcula siempre** (VGM − TARA), aunque la celda traiga un valor guardado.
- **VGM exacto:** se guarda como `double`, sin truncar.
- **Peligrosas desde CONTENIDO:**
  - clase con `IMO|IMDG|CLASE|CLASS n[.n]`;
  - números ONU con `UN nnnn`, más los que sigan separados por coma, `/`, `&`, `Y` o `AND`.
  - Así, «IMO 9 UN 3082, 3077» da clase 9 y UN 3082 y 3077.

### 3.2 Equivalencias

- **Se proponen solas** desde los contenedores que están en el listado y en el plan a la vez. Para cada código del listado se mira qué código trae el plan para esos mismos contenedores.
- **Si un código del listado tiene equivalencia guardada**, manda la guardada. Si lo que dicen los contenedores la contradice, se avisa en la tarjeta.
- **Se pide** cuando ningún contenedor de ese código está en los dos, o cuando los contenedores no coinciden entre sí.
  - Como sugerencia se ofrecen los códigos que el plan carga en la escala y que ninguna otra equivalencia explica. En el caso es solo 45R1.
  - No se preselecciona: el usuario la elige o escribe otra con «Otro código…».
- **Toda equivalencia es editable** con el lápiz «Corregir».
- **Al confirmar se guardan** las inferidas que no son identidad, las elegidas y las corregidas. Las identidades inferidas no se guardan: se vuelven a deducir cada vez.

### 3.3 Cruce con el plan

- **Llenos:** cada uno se busca en el plan por su número. Si cruza, se comprueba que el plan lo cargue en la escala y que coincidan el estado, el tipo, el puerto de descarga y la línea, ya traducidos.
- **Vacíos:** van a su grupo (tipo, puerto de descarga y línea). Las celdas de un grupo son sus reservas sin número (T-69) **más los vacíos que el plan ya trae numerados en la escala**. Así el OR 85, que ya está en 006-02-04, cuenta en el grupo 42G1 · PAMIT · LNC, y salen los 6 grupos de la ficha.
- **Se informa:**
  - los llenos del listado que no están en el plan;
  - los contenedores numerados que el plan carga en la escala y no están en el listado;
  - los vacíos sin grupo;
  - los grupos con más o menos vacíos que celdas.
- **Peligrosas:**
  - UN que el plan no trae, UN que el listado no declara y clase distinta;
  - un DG declarado en un solo lado.
- **VGM:** cuántos llenos difieren del plan y cuánto suma la diferencia. Se guarda siempre el VGM del listado.

### 3.4 Guardado: la fuente `export_list` de la operación

- **Qué se guarda:** el listado **normalizado**, con los códigos traducidos y también los originales del Excel, la tabla de equivalencias aplicada, las filas sin entender y el VGM exacto. Se guarda como JSON (`format: baystream-listado`, `schema: 1`), en `OperationSource(kind: export_list)` de la bitácora de T-72 (T-79a 2.1).
- **Identidad de la operación, que T-74 debe reutilizar para no crear otra** (aceptada por Carlos y Yov el 7-oct):
  - Una operación es la misma si coinciden **`vesselName == plan.vessel.name`**, **`voyageNumber == plan.voyageNumber`** y **`portOfCall == plan.portOfCall`**. En el caso: BUQUE GOLF, VIAJE007A y GTSTC.
  - Si no existe, se crea con `id` UUID v4, que es lo que pide T-79a: lo crea quien publica.
  - Si existe, se conservan su `id`, su `createdAt` y sus demás fuentes, y **solo se reemplaza la `export_list`**.
  - **T-74 agrega la `loading_baplie` a esa misma operación** (decisión aceptada y anotada en su fila de SPRINT-3). T-73 no la guarda porque el texto del BAPLIE no se conserva después de leerlo.
- **La pantalla al reabrirse** busca esa operación y muestra «Guardado en la operación», con el resumen y el cruce recalculado.

## 4. Pruebas

**Nuevas en la suite (22):**

| Archivo | Casos |
|---|---|
| `test/t73_export_list_test.dart` (20) | **Lectura (6):** columnas por encabezado en otro orden y agencias; neto recalculado, VGM 7266.59, HORA y MARCHAMO; filas sin entender con su número (14 y 15); clase y UN de CONTENIDO en cuatro variantes; sin encabezados, con columnas faltantes o con bytes que no son un libro; número repetido y coma decimal. **Rutas absolutas (2):** cada fixture trae la forma que dice (absolutas en el de script, relativas en el de Excel); se corrigen la hoja, los estilos, `sharedStrings` (con comillas simples), el tema, `/customXml` y el enlace externo, y una segunda pasada no cambia nada. **Forma guardada desde Excel (3):** se lee igual, fila por fila, que la forma del script; el neto se recalcula aunque traiga valor en caché (desactualizado a propósito); el OR acepta `1.0` y un OR `2.5` se informa. **Equivalencias (4):** propuesta automática y lo que se pide, con su sugerencia; lo guardado ya no se pide; una guardada contradicha se marca; ida y vuelta por JSON. **Cruce (4):** llenos, lo que no cruza y los grupos con un vacío numerado; un vacío sin traducir queda sin grupo; el aviso de UN 3082; la diferencia de VGM. **Persistencia (1):** las equivalencias sobreviven a cerrar y abrir el almacén Hive |
| `test/t73_export_list_page_test.dart` (2) | **A 360 dp:** el resumen, las equivalencias y el 40RF pendiente con el botón desactivado; se elige 45R1; el cruce; se confirma; la fuente queda en la operación y las equivalencias en el almacén; al reabrir se ve lo guardado y la segunda importación no pide nada. **Sin plan con escala** no deja importar |

**Datos sintéticos** (ningún dato real):
- `test/fixtures/t73_listado_sintetico.xlsx` y `t73_listado_sintetico_excel.xlsx` los genera `tool/t73_listado_sintetico.py`, con los mismos datos en dos formas:
  - **la de script**, como `LISTADO_A08.xlsx`: `inlineStr`, fórmula sin valor guardado, enteros y rutas absolutas;
  - **la de Excel** (revisión de Yov): `sharedStrings.xml`, números como double, neto con valor en caché, HORA como fracción con formato `h:mm` y rutas relativas.
- Los contenedores `TSTU…` son inventados, con dígito de control ISO 6346 válido.
- `test/support/t73_export_list_support.dart` trae el plan BAPLIE sintético que los acompaña. Tiene las mismas rarezas que el caso real: VGM truncado, COSPC por COMNG, LINB por LNB, un solo UN y un vacío numerado.

**Fuera de la suite:** `tool/t73_corpus_test.dart` (2 casos), que lee `LISTADO_A08.xlsx`, `CORPUS_A08.edi` y `CORPUS_A08v_VGM.edi` desde la carpeta del corpus. Comprueba todas las cifras de la ficha, y además:
- ningún lleno con datos distintos y ninguna equivalencia contradicha;
- las 47 diferencias de VGM, con el plan 2.4 t por debajo;
- el guardado con el repositorio real sobre Hive y la reapertura.

```
flutter test tool/t73_corpus_test.dart --dart-define=BAYSTREAM_CORPUS_DIRECTORY="C:\Users\Giova\OneDrive\Documentos\OneDrive\Desktop\Archivos .EDI\Anonimizados\files"
```

## 5. Aceptación en los tres clientes

**La secuencia, la misma en los tres:**
1. Abrir A08 con la escala GTSTC.
2. «Listado de la agencia» → elegir `LISTADO_A08.xlsx`.
3. Revisar el resumen, las equivalencias, el cruce y las filas OR 127 y 130.
4. Elegir 40RF → 45R1 y confirmar.
5. Cerrar y reabrir: ver «Guardado en la operación».
6. Importar otra vez: no se pide nada.

| Cliente | Compilación y almacén | Particularidades |
|---|---|---|
| **Windows** | Lanzamiento (`flutter build windows --release` con las opciones privadas de T-47). **Almacén real de Carlos, `%LOCALAPPDATA%\BayStream`**, con la app lanzada mediante `explorer.exe` (PID 26492, luego 17476) | **Primero se quitó el límite de prueba de 90 000 kg de BUQUE GOLF** en «Perfiles guardados» («No lo tengo» → «Perfil guardado»). Después de reiniciar sigue sin límite. A08 abrió directo con el perfil conocido y la escala GTSTC. 40RF se resolvió con **el lápiz «Corregir», escribiendo `45r1` en minúsculas**: quedó «45R1 · Elegida por ti» |
| **Honor NAA-LX3, 360 dp** | Lanzamiento, variante propia **`gt.cmartinez.baystream.t73`** (Gradle con un script de inicialización, el método de T-72). Almacén nuevo y vacío | Archivos copiados tal cual a `Download/T73`. 40RF se resolvió con la sugerencia 45R1. Cierre forzado con `am force-stop` de la variante |
| **Chrome** (el de Carlos, con la extensión) | Web de lanzamiento servida en local en un origen nuevo, **`127.0.0.1:8783`**, con IndexedDB vacío | 40RF se resolvió con la sugerencia. Después de confirmar, **se recargó la página** y se recuperó el viaje desde «Viajes recientes» |

**En pantalla, en los tres:**
- «176 filas en 4 agencias · 120 llenos · 56 vacíos» y «Todas las filas se entendieron».
- «120 de 120 llenos cruzan con el plan», «0 contenedores del plan no están en el listado» y «56 de 56 vacíos en 6 grupos de reservas», con los seis grupos.
- El aviso «OR 127 · XQDU8614240: el listado declara clase 9 y UN 3082 y 3077; el plan no trae UN 3082».
- «47 llenos con VGM distinto del plan: el plan suma 2.4 t menos que el listado».
- En las filas: «OR 130 … VGM 7 266.59 kg · tara 3 900 kg · neto 3 366.59 kg».
- En la segunda importación, las seis equivalencias salen «Guardada en este dispositivo».

**Evidencia local en `build/t73/`** (ignorada por Git):
- `honor/` (jerarquías y capturas);
- `windows/` y `chrome/` (capturas);
- `suite.txt` y `corpus.txt`;
- `pubspec.lock.antes` y `pubspec.lock.diff`;
- los registros de compilación.

## 6. Incidencias

- **El paquete no podía abrir `LISTADO_A08.xlsx`**: la ruta absoluta de la sección 2.2. Lo detecté porque el corpus falló, y lo confirmé con una copia en el scratchpad, fuera del repo y ya borrada, donde solo cambié esa ruta: así pasaban todas las cifras. Carlos autorizó `archive` como dependencia directa. Mi primer fixture no lo vio porque usaba rutas relativas; ahora el de script las usa absolutas.
- **Windows abrió primero otro almacén.**
  - Lancé la app con `Start-Process` desde mi PowerShell, que corre dentro del paquete de Claude. Windows le redirigió el almacén a `%LOCALAPPDATA%\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Local\BayStream`, que no tiene BUQUE GOLF. Es el caso que advierte `AGENTS.md`.
  - Cerré esa instancia **por su PID (35360)**, con un cierre normal, sin cambiarle nada, y relancé mediante **`explorer.exe`**. Así el proceso queda fuera del paquete (su padre es `explorer.exe`) y usa el almacén real.
  - **Propuesta para `AGENTS.md`:** «Timonel abre la app de Windows con `Start-Process explorer.exe -ArgumentList <ruta del exe>`, no con `Start-Process <exe>`». Así queda dicho qué almacén usa.
- **El acceso de la herramienta de pantalla a `baystream.exe` se denegó la primera vez.** No usé otra vía; pregunté, y Carlos lo concedió.
- **Chrome:**
  - la ventana quedó oculta (`visibilityState: hidden`), las capturas expiraron y Flutter dejó de dibujar. Carlos la dejó visible y se siguió;
  - la rueda del ratón de la extensión no desplazaba la vista de Flutter, así que despaché un `WheelEvent` desde JavaScript;
  - para no abrir el diálogo nativo de archivos, **solo en mi pestaña** sustituí `HTMLInputElement.click` para los `input type=file` y usé la herramienta de subida;
  - esa herramienta solo lee las carpetas de la sesión, así que A08 y el listado se copiaron un momento al scratchpad (fuera del repo) y **se borraron al terminar**. Cerré mi pestaña y detuve el servidor local.
- **Textos corregidos durante la aceptación en el Honor.** La fecha de la cabecera salía en ISO con hora (`2025-01-31T00:00:00.000Z`) y ahora sale `2025-01-31`. «1 contenedores», «1 vacíos, 1 celdas» y «1 filas» ahora van en singular. Recompilé la variante y repetí el recorrido completo; la suite y analyze se volvieron a correr sobre ese código (405/405, cero).
- **Detalles observados, fuera de alcance:**
  - «Filas del listado (176)» se pliega si se desplaza fuera de la vista, porque la lista no conserva el estado de los hijos que salen de pantalla;
  - en Android, las 176 filas forman un solo nodo de accesibilidad.
  - Los dos son menores y se pueden ordenar cuando T-74 use esta pantalla.
- **El Honor:** la variante `.t73` queda instalada, junto a `.t68`, `.t69` y `.t72`. No se tocó la app de Play.
- **El almacén real de Windows queda con:**
  - BUQUE GOLF sin límite;
  - A08 en los viajes recientes;
  - la operación BUQUE GOLF · VIAJE007A · GTSTC con su `export_list`;
  - las seis equivalencias.
  - Todo eso es lo que se pidió probar, y puede quedarse.

## 7. Horas

- **Estimación de la ficha:** 4.5 h.
- **No medí las horas con precisión, así que no las afirmo.** Mi estimación es de ≈ 6 h de implementación y pruebas, más la aceptación en los tres clientes. Queda por debajo del doble de lo estimado.
- **Lo que no estaba previsto:**
  - la incompatibilidad de las versiones de los paquetes de Excel con `pdf` e `image`;
  - el defecto de las rutas absolutas y su corrección;
  - el segundo fixture, en la forma guardada desde Excel;
  - el almacén virtualizado de Windows y la ventana oculta de Chrome.
- Yov ajusta las horas con la bitácora del sprint.

## 8. Archivos

**Nuevos:**
- `lib/features/vessel/domain/entities/export_list.dart`
- `lib/features/vessel/domain/services/export_list_cross_checker.dart`
- `lib/features/vessel/domain/repositories/export_list_repository.dart`
- `lib/features/vessel/data/services/export_list_parser_service.dart`
- `lib/features/vessel/data/repositories/export_list_repository_impl.dart`
- `lib/features/vessel/presentation/providers/export_list_providers.dart`
- `lib/features/vessel/presentation/pages/export_list_import_page.dart`
- `test/t73_export_list_test.dart`
- `test/t73_export_list_page_test.dart`
- `test/support/t73_export_list_support.dart`
- `test/fixtures/t73_listado_sintetico.xlsx`
- `test/fixtures/t73_listado_sintetico_excel.xlsx`
- `tool/t73_corpus_test.dart`
- `tool/t73_listado_sintetico.py`
- `docs/T73-RESULTADOS.md` (este informe)

**Modificados:**
- `lib/core/errors/exceptions.dart`
- `lib/features/vessel/domain/entities/entities.dart`
- `lib/features/vessel/domain/repositories/local_vessel_repository.dart`
- `lib/features/vessel/data/repositories/local_vessel_repository_impl.dart`
- `lib/features/vessel/data/datasources/hive_vessel_data_source.dart`
- `lib/features/vessel/presentation/pages/vessel_overview_page.dart`
- `pubspec.yaml` y `pubspec.lock` (sección 2)
