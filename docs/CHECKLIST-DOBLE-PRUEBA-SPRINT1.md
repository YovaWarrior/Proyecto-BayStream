# Doble prueba de calidad · Sprint 1 — checklist común

**Proyecto:** BayStream · Proyecto de Graduación II
**Commit auditado:** `713da5a` (HEAD del 27-ago-2026)
**Alcance:** los 5 elementos del Sprint 1 (RF-012, RF-020, RF-025, RF-026+, RF-033) más T-22 y T-23.

## Cómo se usa

Dos auditores responden **este mismo checklist por separado y sin ver la respuesta del otro**:

| Auditor | Entorno | Puede |
|---|---|---|
| **Yov** (Claude, Cowork) | contenedor en la nube + puente al VM Linux | leer y analizar código; **no** compilar, ejecutar ni capturar pantalla |
| **Capitán Codex** (ChatGPT) | Windows de Carlos, con Flutter instalado | todo lo anterior **más** compilar, ejecutar, probar y capturar |

Cada comprobación lleva una marca de quién puede responderla:

- **[E]** estática — se responde leyendo el código. **La responden los dos.** Son las que producen el contraste.
- **[D]** dinámica — exige compilar, ejecutar o mirar la pantalla. **Solo Codex.**

Las **[E]** son el corazón de la doble prueba: si los dos coinciden, el resultado se sostiene; donde discrepen, ahí hay algo que mirar de cerca. Las **[D]** son cobertura que Yov no puede dar.

**Regla de oro:** no se responde «cumple» porque `SPRINT-1.md` lo diga. Se responde citando **archivo y número de línea**. Una afirmación de la bitácora no es evidencia de sí misma — esa lección ya la dejó la auditoría de seguridad del 25-ago, donde dos hallazgos resultaron falsos por haber inferido las reglas de Firestore en vez de leerlas.

## Formato de respuesta

Una fila por comprobación:

| ID | Veredicto | Evidencia (archivo:línea) | Nota |
|---|---|---|---|

Veredictos permitidos: **CUMPLE** · **NO CUMPLE** · **CUMPLE CON RESERVA** · **NO DETERMINABLE**.

`NO DETERMINABLE` es una respuesta válida y preferible a adivinar. Si no se puede comprobar con las herramientas disponibles, se dice.

---

## Bloque 1 · RF-012 — Indicadores de peso por nivel

| ID | Comprobación | Tipo |
|---|---|---|
| 1.1 | `Bay.weightByTier` existe, es puro y no importa Flutter. | [E] |
| 1.2 | La suma de `weightByTier.values` iguala `totalWeight` — la Definición de Terminado de T-01 lo exige literalmente. ¿Se cumple **siempre**, o solo cuando todos los contenedores tienen posición? ¿Hay prueba que lo afirme? | [E] |
| 1.3 | Cada fila de nivel con contenedores muestra su peso en toneladas con un decimal. | [E] |
| 1.4 | Un nivel vacío no muestra nada (T-02 lo pide explícitamente: «un cero es ruido visual»). ¿Y un nivel **con** contenedores pero **sin** dato de peso — se distingue de uno vacío? | [E] |
| 1.5 | `kStackWeightLimitKg` está documentado como PROVISIONAL con el comentario íntegro que exige T-03. | [E] |
| 1.6 | El nivel que supera el límite se distingue visualmente usando el color de advertencia del `colorScheme`. | [E] |
| 1.7 | **La rejilla no se desalinea** — T-02 lo pone como condición de terminada. Comparar el ancho real de la etiqueta de fila con el ancho real de la celda, **incluyendo márgenes**. | [E] |
| 1.8 | La rejilla con la columna de peso se ve correcta en Windows, Android y Web. Capturar las tres. | [D] |
| 1.9 | Cargar un BAPLIE real de `corpus_m1/` y verificar a mano que el peso de un nivel coincide con la suma de sus contenedores. | [D] |

## Bloque 2 · RF-020 / T-21 — Estado vacío por frecuencia

| ID | Comprobación | Tipo |
|---|---|---|
| 2.1 | El orden es por conteo **descendente** y el `.take(5)` ocurre **después** de ordenar. | [E] |
| 2.2 | Los empates son deterministas — mismo resultado en cada ejecución y en cada plataforma. ¿De qué depende? | [E] |
| 2.3 | El doble recorrido de la lista se eliminó y el `avatar` reutiliza el conteo ya calculado. | [E] |
| 2.4 | `operatorCode` y `portOfDischarge` nulos o vacíos no producen fichas en blanco ni con el texto «null». | [E] |
| 2.5 | La prueba verifica el **orden**, no solo la presencia de las fichas. ¿Cubre el desempate? | [E] |
| 2.6 | Abrir el buscador sin escribir nada y confirmar que las cinco navieras mostradas son las de mayor carga del viaje real. Capturar. | [D] |
| 2.7 | Tocar una ficha rellena la búsqueda y muestra resultados — criterio de aceptación del ERS que ninguna prueba automatizada cubre. | [D] |

## Bloque 3 · RF-025 — Exportación de reporte en PDF

| ID | Comprobación | Tipo |
|---|---|---|
| 3.1 | El esquema cromático de las **celdas** del PDF coincide con el de `bay_plan_view.dart`, color por color. | [E] |
| 3.2 | El esquema cromático de **todo lo demás** también coincide: etiquetas cubierta/bodega, leyenda, separador. T-10 dice «el mismo esquema cromático», sin excepciones. | [E] |
| 3.3 | La separación cubierta/bodega usa el nivel 80 y lo hace igual que en pantalla. | [E] |
| 3.4 | El encabezado de la tabla se repite en cada página. | [E] |
| 3.5 | La tabla ordena por coordenada de estiba. ¿Compara `(bahía, fila, nivel)` numéricamente o compara cadenas? Si compara cadenas, ¿de qué invariante depende que salga bien? | [E] |
| 3.6 | `printing` no aparece en `lib/`, `test/`, `pubspec.yaml` ni `pubspec.lock` — ni siquiera como dependencia transitiva. | [E] |
| 3.7 | Las fuentes Roboto se cargan de forma compatible con Web (asíncrona, por `rootBundle`, sin `dart:io` ni rutas absolutas). | [E] |
| 3.8 | El PDF incluye todo lo que la pantalla muestra del plano de bahía. ¿Falta algún elemento? | [E] |
| 3.9 | La rejilla del PDF se construye con la **misma lógica** que la de pantalla (qué filas se dibujan, qué rango de niveles). Si difieren, describir el efecto visible. | [E] |
| 3.10 | Robustez: divisiones entre cero, `!` sobre nulos, `firstWhere` sin `orElse`, `int.parse` sin `tryParse`, listas vacías, nombre de buque vacío. | [E] |
| 3.11 | ¿Qué afirma la portada como «Puerto origen» y «Puerto destino»? ¿De dónde salen esos valores en un viaje cargado de un archivo real? | [E] |
| 3.12 | Generar el PDF del corpus real (977 contenedores, 27 bahías) y **medir cuánto tarda**. Reportar el número. | [D] |
| 3.13 | Abrir el PDF generado y comparar página a página contra la pantalla: colores, separación cubierta/bodega, alineación de la rejilla. Capturar ambas. | [D] |
| 3.14 | Confirmar que el encabezado de la tabla aparece en las páginas 2, 3 y siguientes — no solo en la primera. Capturar la página 2. | [D] |
| 3.15 | Guardar en las tres plataformas: diálogo nativo en Windows, selector del sistema en Android, descarga en Web. | [D] |
| 3.16 | Comprobar que los acentos y la ñ se ven bien en el PDF. | [D] |
| 3.17 | Durante la generación, ¿la aplicación responde o se congela? | [D] |

## Bloque 4 · RF-026+ — Perfil longitudinal

| ID | Comprobación | Tipo |
|---|---|---|
| 4.1 | Las bahías se dibujan **ordenadas de proa a popa**, no en orden de aparición en el archivo. | [E] |
| 4.2 | Cada modo usa **una escala de un solo tono** con su leyenda. T-18 lo exige y prohíbe el arcoíris. ¿Los dos extremos de la escala son del mismo tono? | [E] |
| 4.3 | La etiqueta numérica de cada bahía y el color de relleno **cuentan lo mismo**. ¿Puede una decir una cosa y el otro otra? | [E] |
| 4.4 | El texto sobre la celda es legible en **los dos extremos** de la escala, no solo en uno. ¿Qué color se usa y sobre qué fondo? | [E] |
| 4.5 | La escala de peso, ¿es absoluta o relativa a la bahía más pesada del viaje? Si es relativa, ¿lo dice la leyenda? | [E] |
| 4.6 | Tocar una bahía la abre en la pestaña Bay Plan, reutilizando `selectedBayProvider` y el `TabController`. | [E] |
| 4.7 | La ocupación se calcula contra la capacidad **real** de la bahía. ¿De dónde sale esa capacidad? ¿Quién la asigna? | [E] |
| 4.8 | Desplazamiento horizontal en tablet, redimensionado en escritorio y navegador, sin desbordes. Capturar a 360, 800 y 1440 px. | [D] |
| 4.9 | Con el corpus real (27 bahías), tocar tres bahías distintas y confirmar que se abre la correcta. Capturar. | [D] |
| 4.10 | Conmutar Ocupación ↔ Peso y capturar ambos modos con el mismo viaje. | [D] |

## Bloque 5 · RF-033 — Exportación CSV / JSON

| ID | Comprobación | Tipo |
|---|---|---|
| 5.1 | El CSV lleva BOM UTF-8 al inicio. | [E] |
| 5.2 | Están **todas** las columnas del modelo `ContainerUnit`. Contarlas contra los campos de la entidad. | [E] |
| 5.3 | El escapado cubre comillas, comas y saltos de línea dentro de los campos. | [E] |
| 5.4 | **Un campo que empieza por `=`, `+`, `-` o `@` — ¿qué hace Excel al abrirlo?** ¿El código lo neutraliza? Recordar que los valores vienen de un archivo BAPLIE externo. | [E] |
| 5.5 | El JSON reutiliza `VesselVoyage.toJson()` en vez de una serialización paralela. | [E] |
| 5.6 | Hay **un solo** punto de entrada de exportación para PDF, CSV y JSON. | [E] |
| 5.7 | El nombre de archivo se sanea para las tres plataformas. | [E] |
| 5.8 | Abrir el CSV del corpus real en Excel de Windows: acentos, separador de columnas, formato numérico. Capturar. | [D] |
| 5.9 | Validar el JSON exportado con un parser (`python -m json.tool` o similar) y confirmar que el número de contenedores coincide con el del viaje. | [D] |
| 5.10 | Comprobar que el CSV tiene tantas filas de datos como contenedores tiene el viaje, ni una más ni una menos. | [D] |

## Bloque 6 · Parser BAPLIE — la única entrada no confiable

| ID | Comprobación | Tipo |
|---|---|---|
| 6.1 | ¿Hay algún `int.parse` / `double.parse` sobre texto del archivo sin `tryParse` ni `try/catch`? | [E] |
| 6.2 | ¿Hay algún `substring` o índice de lista sin guarda de longitud? Un segmento truncado, ¿provoca `RangeError`? | [E] |
| 6.3 | ¿Existe algún límite de tamaño de archivo o de número de segmentos? | [E] |
| 6.4 | ¿Cómo se decodifican los bytes del archivo a texto? ¿Se decodifica UTF-8 de verdad? | [E] |
| 6.5 | ¿Qué pasa con un archivo binario, uno vacío y uno sin el separador de segmento? ¿El mensaje de error describe el problema real? | [E] |
| 6.6 | ¿Se pierde algún contenedor en silencio en algún camino del parseo? Buscar todos los `continue` y las sobrescrituras de mapa. | [E] |
| 6.7 | ¿El parseo corre en el hilo de interfaz o en un isolate? | [E] |
| 6.8 | ¿Llega texto crudo de excepción a la pantalla? (Hallazgo H-05 de la auditoría del 25-ago: verificar si sigue vigente y dónde.) | [E] |
| 6.9 | Cargar un archivo que no sea BAPLIE (un PDF renombrado a `.edi`) y anotar el mensaje que ve el usuario. Capturar. | [D] |
| 6.10 | Cargar el corpus real y medir el tiempo de parseo. ¿Se ve el indicador «Procesando archivo BAPLIE...» o la aplicación se congela? | [D] |

## Bloque 7 · Reglas de Firestore (T-22, T-23)

| ID | Comprobación | Tipo |
|---|---|---|
| 7.1 | `firestore.rules` en el repositorio coincide **exactamente** con la regla autorizada en `SPRINT-1.md` §10.7, con las cuatro condiciones íntegras. | [E] |
| 7.2 | `voyages` niega `delete`. La cláusula general `{document=**}` niega todo lo no declarado. | [E] |
| 7.3 | Ninguna regla lleva cláusula de expiración. | [E] |
| 7.4 | La regla de `latency_test` permite la transición que `latency_test_screen.dart` necesita, y **solo** esa. Contrastar contra las líneas 42-45 y 61-68 de ese archivo. | [E] |
| 7.5 | Las reglas publicadas en la consola de Firebase coinciden con las del repositorio. *(Solo Carlos — ni Yov ni Codex publican en Firebase.)* | [D] |

## Bloque 8 · Calidad general y regresión

| ID | Comprobación | Tipo |
|---|---|---|
| 8.1 | Contar las funciones de prueba declaradas: `test(` + `testWidgets(` por archivo. ¿Suman las 31 que reporta la bitácora? | [E] |
| 8.2 | Por cada elemento del sprint, ¿qué **no** cubren sus pruebas? Nombrar los casos límite ausentes. | [E] |
| 8.3 | ¿Alguna prueba pasaría igual si el código estuviera mal? (Pruebas que no discriminan.) | [E] |
| 8.4 | La presentación no accede a datos y el dominio no importa Flutter. | [E] |
| 8.5 | Dependencias: solo se añadió `pdf: 3.12.0`. Verificar en `pubspec.yaml` y `pubspec.lock`. | [E] |
| 8.6 | Los archivos congelados (`latency_test_screen.dart`, `c3_reconciliation_screen.dart`) y las credenciales de Firebase no se tocaron. Verificar con `git log --follow`. | [E] |
| 8.7 | `flutter test` — pegar la salida completa y el conteo final. | [D] |
| 8.8 | `flutter analyze` — pegar el conteo. La bitácora dice 49 advertencias preexistentes y «sin advertencias nuevas». ¿Sigue en 49? Si subió, decir cuáles son nuevas. | [D] |
| 8.9 | `flutter build windows --debug`, `flutter build apk --debug`, `flutter build web` — las tres en verde. | [D] |
| 8.10 | Ejecutar la aplicación y recorrer las tres pestañas con el corpus real. Capturar cada una. | [D] |

---

## Comandos para el bloque dinámico

Desde `C:\Proyectos\proyecto-baystream`:

```
flutter --version
flutter pub get
flutter analyze
flutter test --reporter expanded
flutter build windows --debug
flutter build apk --debug
flutter build web
flutter run -d windows
```

Para el conteo de pruebas, la cifra que cuenta es la de `flutter test`, no la de `grep`.

Para medir la generación del PDF, envolver la llamada en un `Stopwatch` o cronometrar a mano desde que se pulsa Exportar hasta que aparece el diálogo de guardado.

**Ninguno de los dos auditores ejecuta git ni publica en Firebase.** Si hace falta un commit, se redacta el bloque de comandos y lo corre Carlos.

---

## Cierre

Cuando los dos hayan respondido, se cruzan los resultados en una sola tabla:

| ID | Yov | Codex | ¿Coinciden? |
|---|---|---|---|

Lo que interesa de verdad son las tres columnas de la derecha:

1. **Coincidencias en NO CUMPLE** — hallazgos confirmados por dos vías independientes. Van al informe con la mayor confianza.
2. **Discrepancias** — uno dice cumple y el otro no. Cada una se resuelve mirando el código juntos. Son las más valiosas: ahí está lo que un solo auditor habría dado por bueno.
3. **NO DETERMINABLE de Yov que Codex sí resolvió** — mide exactamente cuánto aporta poder ejecutar. Ese número es material para el apartado de método del entregable.

---

## Nota añadida el 27-ago · dónde está el corpus real

Los archivos BAPLIE reales **no están en el repositorio**. `corpus_m1/` no existe: ni rastreado, ni en el árbol de trabajo, ni listado en `.gitignore`. El único `.edi` versionado es `test/fixtures/sample_baplie.edi`, con 7 contenedores, todos en bodega y todos en niveles pares — con ese fixture varias comprobaciones de este checklist no se pueden ver.

El corpus vive fuera del repositorio, ya anonimizado:

```
C:\Users\Giova\OneDrive\Documentos\OneDrive\Desktop\Archivos .EDI\Anonimizados\files\
```

Siete archivos: `CORPUS_A01.edi` … `CORPUS_A06.edi` más `CORPUS_A03v_VGM.edi`. Ojo con la ruta: lleva espacios y un punto en `Archivos .EDI`, así que hay que entrecomillarla. Y al estar en OneDrive, conviene confirmar que los archivos están descargados en el disco (marca verde, no icono de nube) antes de cargarlos.

**Usar `CORPUS_A01.edi`** salvo que la comprobación pida otra cosa: es el de referencia del Incremento 1.

### Cifras del corpus verificadas por conteo directo de segmentos EDI (Yov, 27-ago)

| Magnitud | CORPUS_A01 | CORPUS_A04 |
|---|---|---|
| Contenedores (`EQD+CN`) | **977** | 979 |
| Posiciones (`LOC+147`) | 977 | 979 |
| Contenedores sin posición | 0 | 0 |
| Bahías distintas | **27** | 27 |
| Bahía más cargada | B030, 105 contenedores | B026, 108 |
| Fila máxima | 12 | 12 |
| Nivel máximo | 90 | 90 |
| Niveles impares | 0 | 0 |
| Coordenadas duplicadas | 0 | 0 |
| Bytes no ASCII | 0 | 0 |

Las cifras de 977 contenedores y 27 bahías que reporta el documento del Incremento 1 **quedan confirmadas de forma independiente**, contando segmentos sobre el archivo, sin pasar por la aplicación.
