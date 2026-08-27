# Auditoría de calidad del Sprint 1 — respuesta de Yov

> ⚠️ **No abrir esto antes de que Codex entregue la suya.** La doble prueba solo vale si las dos son ciegas. El checklist común está en `CHECKLIST-DOBLE-PRUEBA-SPRINT1.md`.

**Auditor:** Yov (Claude, sesión de Cowork en la nube)
**Fecha:** 27 de agosto de 2026
**Commit auditado:** `713da5a`
**Método:** lectura del código fuente. Ninguna afirmación de `SPRINT-1.md` se dio por válida sin contrastarla contra el archivo.

## Limitación del entorno, declarada por delante

No pude compilar, ejecutar ni capturar pantalla. Lo verifiqué antes de empezar, no lo supuse:

- El VM Linux del puente no tiene `flutter`, `dart`, `adb`, `chromium` ni `firebase`.
- El contenedor de la nube tampoco.
- Intenté instalar el SDK: el egress bloquea `storage.googleapis.com` y `pub.dev` en los dos entornos, así que ni el SDK ni las dependencias se pueden descargar.

Por tanto **no respondí ninguna comprobación [D]**, y las once que dejé en `NO DETERMINABLE` son precisamente la medida de lo que aporta poder ejecutar. Tampoco pude leer el código fuente del paquete `pdf`: la caché de pub vive en `C:/Users/Giova/AppData/Local/Pub/Cache` y no está montada.

**Ni el corpus real está en el repositorio.** `CORPUS_A01.edi` (977 contenedores) no existe en el árbol; el único fixture es `test/fixtures/sample_baplie.edi`, con 7 contenedores, todos en bodega y todos en niveles pares. Varios de los hallazgos de abajo son invisibles con ese fixture, y eso es parte del problema.

---

## Veredicto en una línea

**El Sprint 1 hace lo que dice que hace en lo esencial, y las cinco funcionalidades están.** Encontré **19 defectos** y **12 puntos verificados como correctos**. Ninguno de los defectos invalida la entrega del 29-ago. Tres de ellos sí conviene que Carlos conozca antes de la revisión, porque son de los que se ven en una demostración en vivo o los pregunta un jurado.

| Severidad | Cantidad |
|---|---|
| Alta | 5 |
| Media | 14 |
| Baja / Observación | 8 |
| **Verificado, cumple** | **12** |

---

## Los tres que importan para el 29 de agosto

### 1 · Hay un segundo supuesto no documentado, hermano de `kStackWeightLimitKg`

Carlos ya tiene previsto declarar que el límite de apilamiento de 90 000 kg es provisional. **Hay otro exactamente igual y nadie lo ha declarado: la capacidad de las bahías.**

`Bay.occupancyRate` (`bay.dart:52-56`) calcula `containers.length / (maxRows × maxTiers) × 100`. Y `maxRows` y `maxTiers` **nunca se asignan**: el parser construye cada bahía solo con `bayNumber` e `is40FtBay` (`baplie_parser_service.dart:713-717`), así que quedan en los valores por defecto de la entidad, **12 y 10** (`bay.dart:37-38`). Lo comprobé en todo `lib/`: no hay un solo sitio que los establezca.

Resultado: **todos los porcentajes de ocupación del sistema se calculan contra una capacidad ficticia de 120 slots, idéntica para todas las bahías**, sin relación con la geometría que viene en el archivo. Y esa cifra se muestra en tres sitios: el encabezado del Bay Plan (`bay_plan_view.dart:120`) y las dos lecturas del perfil longitudinal (`vessel_profile_view.dart:349` y `:357`).

Por qué es exactamente el mismo caso que el límite de peso: el BAPLIE **no transmite la geometría del buque**. Igual que el límite de apilamiento vive en el manual de estabilidad, la capacidad real de cada bahía vive en el plano del buque, fuera del archivo. La diferencia es que uno está documentado como PROVISIONAL en el código con un comentario de cuatro líneas y el otro está en un valor por defecto de constructor con un comentario que dice `// 12 × 10 = 120 slots por defecto`, como si fuera una decisión de diseño y no un supuesto.

**Recomendación:** disclosurarlo el 29-ago junto al de peso, con el mismo argumento. Son la misma clase de limitación y la defensa es la misma: la aplicación no puede inventar datos que el formato no transmite. Declararlo es fuerte; que lo encuentre el jurado es débil.

### 2 · Las etiquetas de fila del Bay Plan se desalinean de las columnas

`_buildRowHeader` dibuja cada etiqueta de fila en `Container(width: 50)` **sin margen** (`bay_plan_view.dart:589`). `_ContainerCell` dibuja cada celda en `Container(width: 50, margin: EdgeInsets.all(2))` (`:753-755`), que ocupa **54 px** reales.

Las dos `Row` están centradas (`MainAxisAlignment.center`), así que la deriva es simétrica: se cancela en el centro y se acumula hacia los bordes, **2 px por columna en cada dirección**. Con 12 filas, las etiquetas de los extremos quedan ~24 px fuera de su columna; con 24 filas, ~48 px, casi una celda entera.

Por qué importa aquí más que en otra aplicación: en un plano de estiba el número de fila **es** la forma de identificar dónde está físicamente un contenedor. Una etiqueta que no cae sobre su columna no es un defecto cosmético, es una lectura equivocada de la posición.

Es **anterior al sprint** — no lo introdujeron T-01…T-04. Pero T-02 tenía como condición de terminada «la rejilla no se desalinea en las tres plataformas», así que estaba dentro del radar de la tarea y no se detectó. Lo mismo ocurre en el PDF (`pdf_report_service.dart:318-319` frente a `:392-394`), donde la deriva es 1,6 pt por columna y **no** se cancela porque no está centrada.

**Se ve en una captura.** Si Codex ejecuta, esto sale a la primera.

### 3 · La portada del PDF nunca muestra los puertos del viaje

`_portSummary` (`pdf_report_service.dart:693-702`) devuelve `voyage.portOfOrigin` si existe, y si no, arma una lista con todos los puertos distintos de los contenedores.

`portOfOrigin` y `portOfDestination` **son siempre nulos en producción**. Lo verifiqué con `grep -rn` en todo `lib/`: el parser BAPLIE no los asigna nunca, y el único sitio del proyecto que los rellena es `c3_reconciliation_screen.dart:92-93`, una pantalla de demostración con valores fijos.

Dos consecuencias. La rama principal de `:694` es **código muerto** para cualquier viaje cargado de un archivo real, y lo que se imprime bajo el rótulo «Puerto origen» es siempre una lista derivada. Con el corpus de 977 contenedores repartidos entre varios POD, esa celda contiene algo como `"CNSHA, CNQIN, KRPUS, USNYC, ..."` dentro de una `pw.Page` de **tamaño fijo** (`:72-74`) cuya `Column` termina en `pw.Spacer()` (`:175`): si el texto crece, el `Spacer` se colapsa y lo que sobra sale de la caja de página **sin excepción ni aviso**.

`SPRINT-1.md:418` menciona la derivación como caso de respaldo. En realidad es el único camino. Esto se ve abriendo el PDF del corpus real — otra que Codex confirma o descarta en un minuto.

---

## Respuestas al checklist

### Bloque 1 · RF-012

| ID | Veredicto | Evidencia | Nota |
|---|---|---|---|
| 1.1 | **CUMPLE** | `bay.dart:64-76` | Getter puro, sin importar Flutter (`bay.dart:1-3` solo importa `equatable` y entidades hermanas). |
| 1.2 | **CUMPLE CON RESERVA** | `bay.dart:67-68`, `test/baplie_parser_test.dart:327` | La prueba **sí** afirma la invariante: `expect(bay.weightByTier.values.reduce((a,b)=>a+b), bay.totalWeight)`. Pero solo se sostiene porque `weightByTier` descarta los contenedores sin posición (`:67-68`) mientras `totalWeight` los suma todos (`:59-60`), y el parser nunca mete en una bahía un contenedor sin posición (`baplie_parser_service.dart:706`). Por la vía `Bay.fromJson` o `addContainer` la invariante **se rompe** y ninguna prueba lo cubre. La especificación de T-01 se contradice a sí misma: pide ignorar los contenedores sin posición *y* que la suma iguale `totalWeight`. |
| 1.3 | **CUMPLE** | `bay_plan_view.dart:657` | `'${(tierWeight / 1000).toStringAsFixed(1)} t'`. |
| 1.4 | **CUMPLE CON RESERVA** | `bay_plan_view.dart:647` | La condición es `tierWeight == null \|\| tierWeight <= 0`. Un nivel **con** contenedores cuyo `grossWeight` es nulo da 0 y **se ve exactamente igual que un nivel vacío**. En un indicador de estabilidad, «sin datos» y «sin carga» no deberían ser indistinguibles. |
| 1.5 | **CUMPLE** | `baplie_constants.dart:113-117` | Comentario íntegro, literal a lo que pedía T-03. |
| 1.6 | **CUMPLE** | `bay_plan_view.dart:613`, `:653`, `:661-662` | `errorContainer` / `onErrorContainer` del `colorScheme`, más negrita. |
| 1.7 | **NO CUMPLE** | `bay_plan_view.dart:589` vs `:753-755` | Ver defecto 2 arriba. |
| 1.8 | NO DETERMINABLE | — | Requiere ejecución. |
| 1.9 | NO DETERMINABLE | — | Requiere el corpus real, que no está en el repositorio. |

### Bloque 2 · RF-020 / T-21

**Este bloque está limpio.** Es la tarea mejor resuelta del sprint, y son 0.25 h.

| ID | Veredicto | Evidencia | Nota |
|---|---|---|---|
| 2.1 | **CUMPLE** | `container_search_delegate.dart:135`, `:139-141` | `second.value.compareTo(first.value)` es descendente; el `..sort` va dentro del paréntesis, antes del `.take(5)`. |
| 2.2 | **CUMPLE** | `container_search_delegate.dart:136` | Desempate por `first.key.compareTo(second.key)`. Como las claves son claves de un `Map`, son únicas, así que el comparador es un orden **total**: nunca devuelve 0 para entradas distintas. No depende de la estabilidad de `List.sort` (que Dart no garantiza) ni del orden de iteración del mapa. Reproducible entre ejecuciones y plataformas — la captura de Codex debe salir idéntica a la mía. |
| 2.3 | **CUMPLE** | `container_search_delegate.dart:111-129`, `:206`, `:239` | Una sola pasada. La mejora es mayor que la pedida: el código anterior recorría la lista **una vez por chip** (O(n·k), hasta 10 pasadas), no dos. |
| 2.4 | **CUMPLE** | `container_search_delegate.dart:112-113`, `:121-122` | Nulos y vacíos filtrados. Matiz: el filtro es `isNotEmpty`, no `trim().isNotEmpty`; un valor de solo espacios daría una ficha en blanco. El parser no puede producirlo (`baplie_parser_service.dart:89-93` ya aplica `trim()`), así que solo sería alcanzable vía Firestore. Observación, no defecto. |
| 2.5 | **CUMPLE** | `test/container_search_delegate_test.dart:40-55` | Compara la lista completa de etiquetas **en secuencia**, e incluye el desempate (`NAV-C` antes que `NAV-Y`, ambas con 5). Las frecuencias sintéticas se declaran en un orden distinto del esperado, así que la prueba fallaría si el `.take(5)` volviera a operar sin ordenar. Buena prueba. |
| 2.6, 2.7 | NO DETERMINABLE | — | El criterio del ERS «al tocarlos rellena la búsqueda y muestra resultados» **no tiene cobertura automatizada**: la prueba invoca `buildSuggestions` directamente en vez de `showSearch`, así que el delegate no está montado en una ruta de búsqueda y `onPressed` no se ejercita. |

### Bloque 3 · RF-025

| ID | Veredicto | Evidencia | Nota |
|---|---|---|---|
| 3.1 | **CUMPLE** | `pdf_report_service.dart:424-438` vs `bay_plan_view.dart:705-746` | Los 7 casos de celda coinciden uno a uno: sin contenedor, IMO, reefer, OOG, lleno, vacío, desconocido. **Reserva honesta:** los valores hexadecimales de `PdfColors` no los pude leer (paquete no montado); afirmo la equivalencia por conocimiento del paquete. Codex sí puede confirmarlo. |
| 3.2 | **NO CUMPLE** | `pdf_report_service.dart:331-344` vs `bay_plan_view.dart:518-531`, `:555-568` | Las etiquetas cubierta/bodega **sí divergen**. En pantalla son azul y marrón deliberadamente; en el PDF `_deckLabel()` es una sola función que pinta ambas con `blueGrey50` y texto negro. T-10 dice «el mismo esquema cromático» y añade «un PDF que coloree distinto que la pantalla es un PDF que confunde». La leyenda también difiere (`:440-453` vs `:183-193`), pero ahí **el PDF es el que está bien** — ver el defecto de leyenda en el bloque de hallazgos. |
| 3.3 | **CUMPLE** | `pdf_report_service.dart:243` vs `bay_plan_view.dart:479` | `tier >= 80` en ambos, misma dirección. El separador `brown400` coincide con `Colors.brown.shade400` y solo se dibuja si existen las dos bandas. |
| 3.4 | **CUMPLE CON RESERVA** | `pdf_report_service.dart:479-501`, `:504-518` | El título de sección va en el callback `header:` de `pw.MultiPage`, que sí se invoca por página. La fila de columnas se apoya en el `repeat: true` que `TableHelper.fromTextArray` pone en el `TableRow` de cabecera — mecanismo correcto, pero **no lo pude confirmar leyendo el paquete y ninguna prueba lo verifica**. Es de las que Codex debe cerrar (3.14). |
| 3.5 | **CUMPLE CON RESERVA** | `pdf_report_service.dart:46-57` | Compara **cadenas** (`rawCode`), no `(bahía, fila, nivel)`. Hoy da el orden correcto, pero **por coincidencia**: `rawCode` siempre son 7 dígitos con relleno (`iso_coordinate_parser.dart:101`, `:113`, `:149-151`), y para cadenas de dígitos de ancho fijo el orden lexicográfico coincide con el numérico. Nada en el archivo del PDF documenta ni protege ese invariante, y `IsoCoordinate.fromJson` (`:60-65`) lee `rawCode` **sin validar**, así que un documento de Firestore con `rawCode: "10206"` desordenaría el PDF sin error. |
| 3.6 | **CUMPLE** | `grep -rn "printing"` en `lib/`, `test/`, `pubspec.yaml`, `pubspec.lock` | Cero ocurrencias, ni siquiera transitiva. Tampoco hay `dart:io` ni `dart:html` en `lib/`. |
| 3.7 | **CUMPLE** | `pdf_report_service.dart:15-21` | `await rootBundle.load(...)`, asíncrona y relativa al bundle — la única forma que funciona en Web. Los dos `.ttf` existen y están declarados en `pubspec.yaml:45-47`. |
| 3.8 | **NO CUMPLE** | `pdf_report_service.dart:346-373` vs `bay_plan_view.dart:645-667` | El PDF **omite la columna de peso por nivel y la alerta de sobrepeso**. Un plano impreso pierde la única alerta visual de estabilidad de apilamiento del sistema. No es incumplimiento literal de T-10 (que habla de color), pero es la divergencia funcional más relevante entre las dos vistas. |
| 3.9 | **NO CUMPLE** | `pdf_report_service.dart:298-310` vs `bay_plan_view.dart:461-484` | Dos algoritmos distintos. **Filas:** el PDF parte del conjunto de filas que tienen contenedor; la pantalla genera todos los enteros de `minRow` a `maxRow`. **Niveles:** el PDF calcula rangos separados para cubierta y bodega; la pantalla hace un solo rango y lo reparte. Con bodega en 02-08 y cubierta en 82-86, la pantalla genera **43 niveles** de los que ~36 quedan vacíos y el PDF genera 7. Aquí **el PDF es el que está bien**; el defecto está en pantalla. |
| 3.10 | **CUMPLE** | `pdf_report_service.dart` completo | Revisé una por una las divisiones (`:250` protegida por el retorno temprano de `:226-233`; `:253` por `max(1, ...)` de `:249`), los `!` (`:240` protegido por el `where` de `:223-225`; `:414` por la guarda de `:412`) y los `reduce` (`:307-308`, protegidos por `:306`). **No hay ningún `firstWhere` ni ningún `int.parse` en el archivo.** Este apartado está sólido. |
| 3.11 | **NO CUMPLE** | `pdf_report_service.dart:63-70`, `:693-702` | Ver defecto 3 arriba. |
| 3.12 – 3.17 | NO DETERMINABLE | — | Seis comprobaciones que solo Codex puede cerrar. |

### Bloque 4 · RF-026+

| ID | Veredicto | Evidencia | Nota |
|---|---|---|---|
| 4.1 | **CUMPLE** | `vessel_profile_view.dart:41-42` | `..sort((a,b) => a.bayNumber.compareTo(b.bayNumber))`. No hereda el orden de iteración del mapa. Correcto y explícito. |
| 4.2 | **CUMPLE** | `vessel_profile_view.dart:53-59`, `:317` | `baseColor` es `colorScheme.primary` (ocupación) o `tertiary` (peso); `lowColor` se deriva **del mismo `baseColor`** al 12 % mezclado sobre la superficie. `Color.lerp(lowColor, baseColor, v)` recorre un solo tono. Cumple T-18 sin reservas: no hay arcoíris ni dos matices distintos. |
| 4.3 | **NO CUMPLE** | `vessel_profile_view.dart:349` vs `:357` | El color aplica `.clamp(0.0, 1.0)`; la etiqueta imprime `occupancyRate` **sin clamp**. Una bahía por encima del 100 % mostraría el texto «142 %» sobre una celda cuyo color ya está saturado en 100 % — el número y el color dicen cosas distintas. **Latente con el corpus actual** (977/27 ≈ 36 contenedores por bahía, muy por debajo de los 120 ficticios), alcanzable con un buque más denso. Es el mismo defecto que el punto 1 visto desde otro ángulo. |
| 4.4 | **NO CUMPLE** | `vessel_profile_view.dart:138`, `:317`, `:333-337` | `textColor` es `colorScheme.onSurface`, fijo, y se pinta **encima** del relleno de la celda. En el extremo alto de la escala el relleno es `colorScheme.primary`, que en Material 3 está pensado para llevar `onPrimary` encima, no `onSurface`. En tema claro eso es texto casi negro sobre un primario saturado; en oscuro, casi blanco sobre un primario claro. **La bahía más llena o más pesada es la que peor se lee** — justo la que más importa. Se ve en una captura. |
| 4.5 | **CUMPLE** | `vessel_profile_view.dart:60-63`, `:230-231`, `:349-352` | La escala de peso es **relativa** a la bahía más pesada del viaje, y la leyenda lo declara imprimiendo el tonelaje real del extremo (`'${(maxWeight/1000).toStringAsFixed(1)} t'`). Honesto. Consecuencia que conviene tener presente: dos viajes distintos no son comparables por color. |
| 4.6 | **CUMPLE** | `vessel_overview_page.dart:182`, `:220-221` | `onBaySelected: _openBayPlan` → `selectedBayProvider.select(bayNumber)` + `_tabController.animateTo(1)`. Reutiliza los dos, como pedía T-19. Y hay prueba de integración real (`test/vessel_profile_view_test.dart:84-140`) que recorre perfil → provider → pestaña → `FilterChip`, incluida la reapertura. Es la mejor prueba del sprint. |
| 4.7 | **NO CUMPLE** | `bay.dart:52-56`, `:37-38`, `baplie_parser_service.dart:713-717` | Ver defecto 1 arriba. La capacidad es la constante 12×10, no la geometría del archivo. |
| 4.8 – 4.10 | NO DETERMINABLE | — | Nota a favor de lo que sí se hizo: T-20 dejó `Scrollbar` con `thumbVisibility` condicional, `Semantics` con etiqueta descriptiva, `Tooltip` por bahía y `ValueKey` por celda (`:117-176`), y la prueba cubre los tres anchos con `maxScrollExtent` (`:34-80`). Es trabajo cuidadoso. |

### Bloque 5 · RF-033

| ID | Veredicto | Evidencia | Nota |
|---|---|---|---|
| 5.1 | **CUMPLE** | `export_service.dart:54`, `test/export_service_test.dart:51`, `:69` | BOM escrito y probado en los dos niveles: `codeUnitAt(0) == 0xfeff` en el texto y `[0xef,0xbb,0xbf]` en los bytes. |
| 5.2 | **CUMPLE** | `export_service.dart:23-48` vs `container_unit.dart:176-201` | 24 columnas contra 24 campos de `props`, en el mismo orden. Los getters derivados (`sizeInFeet`, `height`, `containerType`, `netWeight`) no se exportan; son calculados, no del modelo. Defendible. |
| 5.3 | **CUMPLE** | `export_service.dart:140-148`, `test/export_service_test.dart:54-56` | Comillas dobladas, campos entrecomillados ante coma/comilla/CR/LF. La prueba lo ejercita con `"Línea ""Águila"", S.A."`. |
| 5.4 | **NO CUMPLE** | `export_service.dart:140-148` | **Inyección de fórmulas.** `_escapeCsvField` entrecomilla solo ante `,`, `"`, `\r` y `\n`. Un campo que empiece por `=`, `+`, `-`, `@`, tabulador o CR se escribe tal cual, y Excel lo interpreta como fórmula al abrir el archivo — CWE-1236. Los valores vienen de un archivo BAPLIE externo: `containerId`, `operatorCode`, `portOfDischarge` y `finalDestination` son todos texto no controlado. Y el criterio de aceptación de RF-033 es literalmente «el CSV abre correctamente en Excel», que es el escenario del ataque. Mitigación estándar: anteponer un apóstrofo o un tabulador al campo cuando empieza por uno de esos caracteres. **Ninguna prueba lo cubre.** |
| 5.5 | **CUMPLE** | `export_service.dart:95`, `test/export_service_test.dart:60-64` | `voyage.toJson()` directo, sin serialización paralela. La prueba compara el objeto decodificado contra `voyage.toJson()`. |
| 5.6 | **CUMPLE** | `vessel_overview_page.dart:59-90` | Un solo `PopupMenuButton<VoyageExportFormat>` con PDF, CSV y JSON. No hay segundo botón de exportar. Cumple T-15 exactamente como estaba escrito. |
| 5.7 | **CUMPLE CON RESERVA** | `export_service.dart:150-153` | Sanea `<>:"/\\|?*` y sustituye por `sin_dato` si queda vacío. No cubre saltos de línea internos, caracteres de control ni nombres reservados de Windows (`CON`, `PRN`, `AUX`, `NUL`, `COM1`…). El nombre generado conserva espacios (`BayStream_Buque Águila_V_001.csv`), lo cual funciona pero incomoda en línea de comandos. Riesgo bajo. |
| 5.8 – 5.10 | NO DETERMINABLE | — | 5.8 es la que cierra el criterio de aceptación de RF-033 y también la que confirma o descarta 5.4. |

### Bloque 6 · Parser BAPLIE

**La valoración previa de «control adecuado (validación de entrada)» hay que matizarla.** Es exacta en lo sintáctico y falsa en lo demás.

| ID | Veredicto | Evidencia | Nota |
|---|---|---|---|
| 6.1 | **CUMPLE** | `baplie_parser_service.dart:597`, `:603`, `:687`, `:477`; `:249-266`; `iso_coordinate_parser.dart:96`, `:101` | Inventario completo de `lib/`: todos los valores numéricos del archivo usan `tryParse`. Los cinco `int.parse` de `:257-261` llevan **doble** protección (longitud `== 12` en `:254` y `try/catch` en `:250`/`:264`). Los tres de `iso_coordinate_parser.dart:105-107` van tras `length == 7` y `RegExp(r'^\d{7}$')`. **No hay un solo `parse` sin red.** |
| 6.2 | **CUMPLE** | `baplie_parser_service.dart:451-458`, `:89-100` | Guarda de longitud antes de cada `substring`. Revisé los 17 accesos por índice a listas y **todos** tienen su guarda inmediatamente encima. Un segmento truncado devuelve `null` y se ignora: **no provoca `RangeError`**. Esto es genuinamente robusto y merece decirse. |
| 6.3 | **NO CUMPLE** | `vessel_providers.dart:60-87` | **No existe ningún límite** de tamaño ni de número de segmentos en toda la base de código. `withData: true` (`:63`) carga el archivo entero en memoria; `String.fromCharCodes` hace otra copia; `_normalizeContent` (`baplie_parser_service.dart:61-67`) encadena cuatro `replaceAll`, cada uno creando una cadena nueva completa. El pico es varias veces el tamaño del archivo. En Android eso es muerte por OOM sin mensaje. |
| 6.4 | **NO CUMPLE** | `vessel_providers.dart:83` | `String.fromCharCodes(file.bytes!)` interpreta **cada byte como una unidad de código UTF-16** — Latin-1 de facto. No decodifica UTF-8 y **nunca lanza**. Un nombre de buque con ñ o acento codificado en UTF-8 llega corrupto a `Vessel.name` y de ahí a la pantalla y al PDF. Con puertos latinoamericanos en el corpus, es un escenario realista, no teórico. |
| 6.5 | **NO CUMPLE** | `baplie_parser_service.dart:70-76`, `:163-167`; `vessel_providers.dart:75` | Vacío sí se detecta bien y temprano. **Binario y sin separador, no.** Un binario atraviesa la decodificación sin error, pasa por `_splitSegments` y se detiene mucho después con `'No se encontró el nombre del buque en el segmento TDT'` — un diagnóstico que no describe el problema del usuario, que arrastró un PDF por error. Un archivo sin `'` produce **un solo segmento**, así que la guarda `if (segments.isEmpty)` de `:31` no lo captura y termina en el mismo mensaje. |
| 6.6 | **NO CUMPLE** | `baplie_parser_service.dart:706`, `:366-386`, `:241` | **Tres vías de pérdida silenciosa.** (a) `:706` `if (position == null) continue;` — un contenedor con coordenada malformada existe en `voyage.containers` pero desaparece de las bahías, así que el total del viaje y la suma por bahías **no cuadran** y nada lo explica. (b) `:366-386` — un `EQD` que llegue sin `LOC+147` intermedio **sobrescribe** el contenedor en curso sin volcarlo; el volcado solo ocurre en `LOC+147`, `UNT` y fin de bucle. (c) `pdf_report_service.dart:241` y `bay_plan_view.dart:455` — dos contenedores en la misma coordenada se pisan en el mapa de posiciones, y la cabecera sigue imprimiendo `bay.containers.length`, o sea «N contenedores» sobre un plano que dibuja N-1. Para una aplicación de planificación de estiba, perder carga sin avisar es peor que fallar ruidosamente. |
| 6.7 | **NO CUMPLE** | `vessel_repository_impl.dart:26`, `vessel_providers.dart:80-87` | Hilo de interfaz. `parseBaplieFile` es `async` pero **su cuerpo no tiene un solo `await`**, así que `_parserService.parse(content)` corre síncrono. Verifiqué: **cero `compute(`, `Isolate.` o `spawn(` en todo `lib/`**. Efecto colateral: el indicador `'Procesando archivo BAPLIE...'` (`vessel_overview_page.dart:128`) **nunca llega a pintarse**, porque entre `state = AsyncValue.loading()` y el fin del parseo no se cede el control al bucle de eventos. El usuario ve la aplicación congelada, no un spinner. |
| 6.8 | **NO CUMPLE — H-05 sigue vigente** | `vessel_repository_impl.dart:34-38`, `vessel_providers.dart:99-103`, `vessel_overview_page.dart:146-147`, `:282-287` | Dos puntos de fuga, no uno. Matiz justo: la ruta **esperada** está bien encapsulada — `BaplieParsingException` se captura por tipo y solo se propaga `e.message`, que son cadenas redactadas en español. El problema es el `catch (e)` genérico: cualquier excepción no prevista llega íntegra a pantalla completa con nombre de clase. En un proyecto de graduación el impacto es de presentación, no de divulgación, pero un `_TypeError: type 'Null' is not a subtype of...` en la demostración del 29-ago sería feo. |
| 6.9, 6.10 | NO DETERMINABLE | — | 6.10 mide directamente el efecto de 6.3 y 6.7. |

### Bloque 7 · Reglas de Firestore

**Bloque limpio.** Es el único que verifiqué al 100 % en lo estático y no encontré nada.

| ID | Veredicto | Evidencia | Nota |
|---|---|---|---|
| 7.1 | **CUMPLE** | `firestore.rules:19-25` | Las cuatro condiciones íntegras: `resource.data.respondido == false`, `request.resource.data.respondido == true`, `proceso_b_ms is number` y `affectedKeys().hasOnly(['respondido','proceso_b_ms'])`. Coincide literalmente con §10.7. |
| 7.2 | **CUMPLE** | `firestore.rules:11`, `:26`, `:28-30` | `allow delete: if false` en las dos colecciones; `match /{document=**}` con `read, write: if false`. |
| 7.3 | **CUMPLE** | `firestore.rules` completo | Cero apariciones de `timestamp.date` o `request.time`. La alarma de septiembre está efectivamente cerrada. |
| 7.4 | **CUMPLE** | `firestore.rules:19-25` vs `latency_test_screen.dart:42-45`, `:61-68` | La fase 2 (receptor: `respondido: true` + `proceso_b_ms`) toca exactamente las dos claves que `hasOnly` permite. `t0`, `condicion` y `evento` quedan inmutables desde su creación y una medición cerrada no se puede reabrir. **La regla garantiza más que la versión errónea de solo-anexar**, y ese es el argumento fuerte que ya está registrado. |
| 7.5 | NO DETERMINABLE | — | Solo Carlos, desde la consola. |

### Bloque 8 · Calidad general

| ID | Veredicto | Evidencia | Nota |
|---|---|---|---|
| 8.1 | **CUMPLE** | conteo sobre `test/` | 26 `test(` + 5 `testWidgets(` = **31 funciones declaradas**. Desglose: `baplie_parser_test` 21, `export_service_test` 3, `pdf_report_service_test` 2, `vessel_profile_view_test` 3, `container_search_delegate_test` 1, `widget_test` 1. **La cifra de la tesis reconcilia.** Reserva: cuento declaraciones, no ejecuciones — la cifra que vale es la de `flutter test` (8.7). |
| 8.2 | — | ver abajo | Respuesta larga, va en su propia sección. |
| 8.3 | **HALLAZGO** | `test/pdf_report_service_test.dart:61-68` | **La prueba de ordenamiento del PDF no discrimina nada.** Los `rawCode` del fixture son `'0010182'` y `'0010206'`: ordenados como texto o como `(bahía, fila, nivel)` dan **el mismo resultado**. La prueba pasa igual si el comparador estuviera bien o mal. No hay ningún caso con anchos distintos, ni con el centinela `'9999999'` (ningún contenedor del fixture tiene posición nula), ni con el desempate por `containerId`. Es la prueba que da la falsa sensación de que 3.5 está cubierto. |
| 8.4 | **CUMPLE** | `bay.dart:1-3`, `export_service.dart:1-6`, `vessel_repository_impl.dart` | El dominio no importa Flutter. `export_service.dart` importa `file_picker`, que es infraestructura en capa de datos — correcto. La presentación no accede a datos directamente: pasa por providers y repositorio. |
| 8.5 | **CUMPLE** | `pubspec.yaml:26`, `pubspec.lock` | Solo `pdf: 3.12.0`, con pin exacto. `printing` ausente. Las fuentes Roboto entraron como **asset**, no como dependencia (`pubspec.yaml:45-47`), tal como se decidió. `pubspec.lock` no se tocó por ese lado. Argumento a favor de H4 intacto. |
| 8.6 | **CUMPLE** | `git log --oneline -- lib/latency_test_screen.dart lib/c3_reconciliation_screen.dart lib/main.dart` | Ninguno de los 7 commits del sprint los toca. `git show --stat` de cada commit lo confirma: los archivos tocados son exactamente los que declara la bitácora. |
| 8.7 – 8.10 | NO DETERMINABLE | — | Las cuatro que cierran la mitad dinámica. |

---

## 8.2 · Qué no cubren las pruebas

Es el apartado más útil para TC-01 (revisión de calidad de octubre), así que va con detalle.

**RF-012.** Sí hay prueba de `weightByTier` con dos niveles y con la invariante contra `totalWeight` (`baplie_parser_test.dart:324-327`). No hay: bahía con contenedores sin posición (que es donde la invariante se rompe), nivel con todos los pesos nulos (el caso 1.4), ni nada del renderizado — el resaltado por exceso de `kStackWeightLimitKg` no tiene una sola prueba.

**RF-020.** Bien cubierta en su punto exacto. Falta: lista vacía y menos de cinco navieras (las ramas `if (operators.isNotEmpty)` y `if (ports.isNotEmpty)` nunca se ejercitan en falso), cadenas vacías frente a nulas, y la interacción del chip.

**RF-025.** Es la peor cubierta y la que más código tiene (728 líneas, 2 pruebas). No se verifica **nada del contenido del PDF** más allá de la firma `%PDF-` y el tamaño: ni la repetición de cabecera (el criterio central de T-11), ni los colores (T-10), ni las cifras de portada (T-09). No hay prueba de comparación con `bay_plan_view.dart`, que es lo único que impediría que las dos vistas se separen — y es la prueba que habría detectado el defecto de las etiquetas cubierta/bodega. Casos límite ausentes: viaje sin contenedores, viaje sin bahías, bahía cuyos contenedores no tienen posición (la rama de `:226-233` **nunca se ejecuta**), `isoSizeType` nulo o desconocido, niveles de paridad mixta, posiciones duplicadas, nombre de buque vacío. Y sobre todo **escala**: el fixture tiene 2 contenedores y 1 bahía; nada ejercita las 55 páginas, ni la paginación, ni el `maxPages: 100`.

**RF-026+.** La mejor cubierta de las cinco. Prueba la selección, los tres anchos con `maxScrollExtent` y la integración completa perfil → provider → pestaña → chip. Falta: el contraste del texto (4.4 — no es fácil de probar automáticamente, pero una captura lo resuelve), el comportamiento por encima del 100 % (4.3), y el caso de todas las bahías con peso cero.

**RF-033.** Buena cobertura de BOM, escapado, acentos y saneado de nombre. Falta: la inyección de fórmulas (5.4), contenedor con `stowagePosition` nulo, campo con salto de línea interno, y viaje vacío.

**Parser.** De los 21 `test(` de `baplie_parser_test.dart`, el grupo del parser tiene cinco y solo dos atacan entradas inválidas: contenido vacío y ausencia de TDT. No hay prueba para archivo binario, archivo sin separador, segmento truncado, pesos con `NaN` o negativos, `EQD` consecutivos, ni coordenada malformada dentro de un `LOC+147`. Los cinco hallazgos del bloque 6 son exactamente los que esa ausencia deja pasar.

**Las tres pruebas de mayor rendimiento por esfuerzo**, si en TC-01 hay tiempo para tres:

1. El comparador del PDF con `rawCode` de anchos distintos y con posiciones nulas. Cierra 3.5 y 8.3 de una vez.
2. Una tabla comparativa color a color entre `_containerColors` y `_ContainerCell`. Congela el criterio de T-10 y evita que las vistas se separen en el futuro.
3. Un viaje sintético de ~1000 contenedores en ~27 bahías que solo afirme que `generate()` completa. Es la única forma barata de que la escala real entre en la suite.

---

## Hallazgos que no encajan en ninguna casilla del checklist

**La leyenda del Bay Plan tiene dos entradas para OOG, con dos colores distintos, y ninguno es el de la celda.** `bay_plan_view.dart:185` pinta «Vacío / OOG» en `Colors.orange` y `:191` pinta «OOG» en `Colors.deepOrange`. La celda OOG real se pinta `Colors.orange` (`:734-735`). Así que `deepOrange` **no corresponde a ningún color que la aplicación dibuje jamás**, y OOG aparece dos veces con dos colores. Curiosamente **la leyenda del PDF es la correcta**, así que la corrección va en pantalla, no en el reporte. Severidad media y se ve en cualquier captura del Bay Plan.

**El umbral 80 de cubierta/bodega es un número mágico duplicado** en `pdf_report_service.dart:243` y `bay_plan_view.dart:479`, sin constante. Existe `BayLocation.deck/hold` en `bay.dart:188-192` pero no se usa para esto. Si mañana se ajusta el criterio hay que tocar dos archivos y nada avisa si se olvida uno.

**`_tierRange` pierde contenedores con niveles de paridad mixta.** `pdf_report_service.dart:305-310` avanza `tier -= 2` asumiendo que todos los niveles del conjunto comparten paridad. Con `{82, 84, 85}` genera `[85, 83]`: los niveles 82 y 84 **no se dibujan y sus contenedores desaparecen del plano sin aviso**, mientras la cabecera sigue contando el total correcto. `bay_plan_view.dart:478` tiene el mismo defecto. BAPLIE 2.2.1 usa niveles pares por convención, pero el parser no la impone (`iso_coordinate_parser.dart:107` acepta 00-99), así que el invariante es de datos, no de código.

**Los pesos admiten `NaN`, `Infinity` y negativos.** `baplie_parser_service.dart:597`, `:603`, `:609` validan solo contra `null`, y `double.tryParse` acepta esos literales por gramática. Un `MEA+AAE+WT+KGM:NaN'` contamina `Bay.totalWeight` entero (es un `fold` con suma) y se mostraría literalmente «NaN» en pantalla y en el PDF. Un peso negativo falsearía el control de `kStackWeightLimitKg`. No lo pude ejecutar; la afirmación se apoya en la gramática documentada de `double.parse`.

**La generación del PDF bloquea el hilo de interfaz.** `vessel_overview_page.dart:230-241` no usa `compute()` ni `Isolate.run()`. El `await Future.delayed(Duration.zero)` de `:240` es un truco para que el SnackBar alcance a pintarse antes del bloqueo, y el `duration: Duration(minutes: 2)` de `:236` es la confesión de cuánto se espera que tarde. Nota positiva del mismo bloque: el manejo de `context.mounted` tras los `await` es correcto (`:249`, `:260`), y `:251` `if (path == null && !kIsWeb) return;` distingue bien la cancelación del diálogo nativo del caso Web, donde `saveFile` devuelve `null` tras disparar la descarga. Está pensado.

**Detalles menores, sin urgencia.** Las fuentes Roboto se releen y re-parsean (~172 KB × 2) en cada exportación (`pdf_report_service.dart:15-21`). `maxPages: 100` (`:478`) es un techo sin documentar que un viaje de ~3600 contenedores alcanzaría. Los contenedores de 45 pies computan 2,25 TEU (`45/20`, `:683`) cuando la convención de industria es 2,0 — es una decisión, no un error, pero conviene que sea consciente si se la preguntan. La indentación de `occupancyRate` (`bay.dart:53-56`) está fuera de estilo.

---

## Lo que quedó verificado como correcto

Un «cumple» con evidencia vale tanto como un hallazgo, y este sprint tiene doce:

1. **T-21 (RF-020) impecable** — orden descendente real, desempate determinista por clave única, doble recorrido eliminado con mejora de O(n·k) a O(n), nulos y vacíos filtrados, y prueba que verifica el orden **y** el desempate.
2. **T-15, punto único de exportación** — un solo `PopupMenuButton` para los tres formatos, exactamente como se pidió.
3. **T-19, navegación perfil → Bay Plan** — con prueba de integración de extremo a extremo, la mejor prueba del sprint.
4. **T-18, escala monocromática** — `lowColor` derivado del propio `baseColor`, un solo tono en toda la rampa. Sin arcoíris.
5. **T-01 / T-04, `weightByTier`** — getter puro, sin Flutter, con la invariante contra `totalWeight` afirmada en la prueba.
6. **T-12, sin `printing`** — cero ocurrencias en `lib/`, `test/`, `pubspec.yaml` y `pubspec.lock`, ni transitivas.
7. **Fuentes Roboto compatibles con Web** — carga asíncrona por `rootBundle`, sin `dart:io` ni rutas absolutas. Y no hay `dart:io` ni `dart:html` en todo `lib/`.
8. **Colores de celda PDF ↔ pantalla** — los 7 casos coinciden.
9. **Separación cubierta/bodega en el nivel 80** — idéntica en las dos vistas, incluido el color del separador.
10. **Robustez sintáctica del parser** — ni un `parse` sin protección, ni un `substring` o índice de lista sin guarda, en 836 líneas. Un segmento truncado no provoca `RangeError`.
11. **BOM UTF-8 y escapado CSV** — correctos y probados con acentos y comillas anidadas.
12. **Las reglas de Firestore** — bloque limpio al 100 %, y la de `latency_test` garantiza la inmutabilidad de `t0`, `condicion` y `evento`, que es el argumento fuerte de la defensa.

Y un punto de método que merece decirse: el protocolo de git (Codex redacta, Carlos ejecuta) se sostiene en los siete commits. Cada uno toca exactamente los archivos que la bitácora declara, ni uno más. Los archivos congelados de H5 están intactos.

---

## Recomendación

**Nada de esto bloquea la entrega del 29 de agosto.** Las cinco funcionalidades están y hacen lo que dicen.

Para la revisión, tres cosas:

1. **Añadir la capacidad de bahía a los disclosures**, junto al límite de apilamiento. Son la misma clase de supuesto y declararlos juntos es más fuerte que declarar uno solo.
2. **Si Codex confirma la desalineación de las etiquetas de fila y las etiquetas cubierta/bodega del PDF**, son dos correcciones pequeñas que caben antes del 29 y que se ven en la demostración.
3. **Todo lo demás va a TC-01** (revisión de calidad, octubre), donde ya está reservado el tiempo. La inyección de fórmulas del CSV y el límite de tamaño de archivo son los dos que yo pondría primero en esa lista, porque son de seguridad y ya hay un apartado de seguridad donde encajan.

Lo que más me gustaría que Codex resolviera son las **once comprobaciones que dejé en NO DETERMINABLE**, y en particular las cuatro que confirman o descartan hallazgos míos: 3.13 (alineación y colores del PDF), 3.14 (repetición de cabecera), 5.8 (el CSV en Excel, que también decide 5.4) y 8.8 (si las advertencias de `flutter analyze` siguen en 49).

---

# ADENDA · verificación empírica sobre el corpus real (27-ago, posterior a la entrega)

> Esta adenda se añadió **después** de commitear la auditoría en `886280b`, al recibir acceso a la carpeta del corpus. El texto original queda intacto en el historial de git; nada de lo de arriba se modificó. Se separa así para que el orden de lo que se sabía y cuándo quede auditable.

Conté los segmentos EDI de `CORPUS_A01.edi` y `CORPUS_A04.edi` directamente sobre el archivo, con un script, sin pasar por la aplicación. Eso permite calibrar cuáles de mis hallazgos son **reales hoy** y cuáles son **latentes**.

## Lo que se confirma

**Las cifras de la tesis son correctas.** `CORPUS_A01.edi` tiene exactamente **977 contenedores** (`EQD+CN`) en **27 bahías distintas**. Verificado de forma independiente. `CORPUS_A04.edi` da 979 y 27.

## Hallazgos que resultan LATENTES, no activos

Sobre el corpus real no se disparan. Siguen siendo defectos reales del código, pero no producen daño hoy, y decirlo así es más honesto que dejarlos sonando a alarma:

| Hallazgo | Evidencia en el corpus |
|---|---|
| Pérdida de contenedores sin `stowagePosition` | 977 `EQD` y 977 `LOC+147`: **ninguno sin posición** |
| `_tierRange` con paridad mixta | **0 niveles impares**, 0 bahías con paridad mixta |
| Contenedores duplicados en la misma coordenada | **0 coordenadas repetidas** |
| Mojibake por `String.fromCharCodes` | **0 bytes no ASCII** — el corpus está anonimizado a ASCII puro |
| Inyección de fórmulas en el CSV | **0 campos que abran con `=` o `@`** |
| Etiqueta de ocupación por encima del 100 % | bahía más cargada 105 contenedores, por debajo de los 120 |

Los seis siguen en la lista de TC-01, pero como endurecimiento, no como corrección urgente.

## El hallazgo que SUBE de gravedad

**La ocupación que muestra la aplicación está mal por un factor de ~2,5 en promedio, hoy, con el corpus real.**

`maxTiers = 10` no es solo un supuesto: **el archivo lo contradice**. Los niveles presentes en `CORPUS_A01` son

```
[2, 4, 6, 8, 10, 12, 14,  82, 84, 86, 88, 90]
```

Doce valores distintos —siete de bodega y cinco de cubierta— que llegan hasta el 90. `maxRows = 12` sí coincide con el dato (fila máxima 12), pero `maxTiers = 10` no describe nada de lo que hay en el archivo.

Comparando la ocupación que se muestra contra la ocupación calculada sobre la extensión real de cada bahía:

| Bahía | Contenedores | Extensión real | Ocupación MOSTRADA | Ocupación real |
|---|---|---|---|---|
| B030 | 105 | 12×10 = 120 | 88 % | 88 % |
| B026 | 97 | 12×11 = 132 | 81 % | 73 % |
| B014 | 92 | 12×9 = 108 | 77 % | 85 % |
| B022 | 92 | 12×11 = 132 | 77 % | 70 % |
| B018 | 88 | 12×9 = 108 | 73 % | 81 % |
| **Promedio de las 27** | | | **30,2 %** | **74,1 %** |

La media se hunde porque el divisor es 120 para **todas** las bahías, también para las pequeñas, y a esas la constante las aplasta contra cero. Las bahías grandes coinciden por casualidad; el resto, no.

**Esto se ve en la demostración del 29-ago**, porque el modo Ocupación del perfil longitudinal es una de las tres cosas que se van a enseñar en vivo. Un perfil que dice 30 % de ocupación media sobre un buque que va al 74 % es una cifra que un jurado con experiencia portuaria puede cuestionar en el momento.

Sigue siendo cierto que **la capacidad real no se puede derivar del archivo** — el BAPLIE no transmite la geometría del buque, igual que no transmite el límite de apilamiento. La extensión observada de coordenadas es un piso, no la capacidad verdadera. Pero eso refuerza el argumento en vez de debilitarlo: el número correcto no se conoce, así que **presentar 30 % como si se conociera es la parte que hay que corregir**, no el cálculo.

## Un segundo efecto del mismo dato

Los niveles van de 2 a 90 con un hueco enorme entre el 14 y el 82. `bay_plan_view.dart:478` genera **un solo rango** de `minTier` a `maxTier` de dos en dos: de 2 a 90 son **45 filas de nivel**, de las cuales solo 12 tienen contenedores. **La rejilla en pantalla dibuja 33 filas vacías** en cada bahía del corpus real. El PDF no, porque calcula los rangos de cubierta y bodega por separado.

Esto confirma sobre datos reales el hallazgo 3.9, que hasta ahora era un razonamiento. Y también es visible en la demostración.

## Sobre la reproducibilidad del corpus

Los siete archivos suman ~790 KB y están anonimizados. **Hoy la evidencia empírica central del Incremento 1 no es reproducible desde el repositorio**: nadie que clone `Proyecto-BayStream` puede repetir la validación de las 55 páginas ni el conteo de 977 contenedores. Es una decisión de Carlos —versionarlos o declarar por qué no—, pero no debería quedar implícita.
