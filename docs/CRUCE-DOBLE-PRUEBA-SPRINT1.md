# Doble prueba de calidad del Sprint 1 — cruce de resultados

**Fecha:** 27 de agosto de 2026 · **Base auditada:** commit `713da5a`
**Auditores:** Yov (Claude) — estático, ciego · Capitán Codex (ChatGPT) — estático + dinámico, ciego
**Insumos:** `AUDITORIA-CALIDAD-SPRINT1-YOV.md` (congelada en `886280b`) y `AUDITORIA-CALIDAD-SPRINT1-CODEX.md` (`4714fe8`), sobre `CHECKLIST-DOBLE-PRUEBA-SPRINT1.md`

## Cómo se garantizó la ceguera

Dos mecanismos, uno fuerte y uno de confianza:

1. **Orden de commits.** La auditoría de Yov quedó congelada en `886280b` **antes** de que Codex empezara. El historial de git prueba que no se ajustó después de ver la de Codex.
2. **Aislamiento físico.** Codex trabajó en un `git worktree` separado anclado a `713da5a`, donde el archivo de Yov literalmente no existe. No dependió de que respetara una instrucción.

## Resultado en números

De las **78 comprobaciones**, 55 son estáticas —las respondieron los dos— y 23 exigen ejecución, que solo Codex pudo hacer.

| | |
|---|---|
| Comprobaciones estáticas comparables | 54 (se excluye 8.2, prosa en ambos) |
| **Veredicto idéntico** | **45 · 83 %** |
| Discrepancias | 9 |
| **Defectos confirmados por dos vías independientes** | **15** |
| Solo Codex pudo responder | 23 |
| Ni Codex pudo responder | 1 (la 7.5 es tuya) |

Un acuerdo del 83 % entre dos auditores que no se vieron, sobre 54 juicios técnicos, es un resultado sólido. **Lo valioso, sin embargo, son las 9 discrepancias**, y en tres de ellas Codex tenía razón y Yov estaba corto.

---

## A · Los 15 defectos que los dos encontramos por separado

Estos son los que van al informe con la mayor confianza posible: dos auditores, dos métodos, cero contacto, mismo veredicto.

| # | Comprobación | Defecto |
|---|---|---|
| 1 | 1.7 | La cabecera de filas del Bay Plan se desalinea de sus columnas (50 px sin margen contra 50 px + 2 px por lado) |
| 2 | 3.2 | Las etiquetas cubierta/bodega y la leyenda del PDF no usan el esquema cromático de pantalla |
| 3 | 3.8 | El PDF omite la columna de peso por nivel y la alerta de sobrepeso |
| 4 | 3.9 | La rejilla del PDF y la de pantalla se generan con lógicas distintas |
| 5 | 3.11 | La portada del PDF nunca muestra los puertos del viaje |
| 6 | 4.4 | El texto del perfil usa `onSurface` sobre toda la escala, sin contraste garantizado en los extremos |
| 7 | 4.7 | La ocupación se calcula contra una capacidad fija de 12×10, no contra la real |
| 8 | 5.4 | El CSV no neutraliza los prefijos `=`, `+`, `-`, `@` — inyección de fórmulas en Excel |
| 9 | 6.3 | El parser no tiene límite de bytes, segmentos ni contenedores |
| 10 | 6.4 | La decodificación usa `String.fromCharCodes`, no UTF-8 real |
| 11 | 6.5 | Un archivo binario o sin separador termina en un diagnóstico que no describe el problema |
| 12 | 6.6 | Hay caminos que descartan contenedores en silencio |
| 13 | 6.7 | El parseo corre síncrono en el hilo de interfaz |
| 14 | 6.8 | H-05 sigue vigente: texto crudo de excepción en pantalla |
| 15 | 8.3 | Hay pruebas que pasarían igual si el código estuviera mal |

El bloque 6 completo —los siete puntos del parser— coincidió al 100 %. Eso obliga a matizar la valoración previa de «control adecuado de validación de entrada»: es exacta en lo sintáctico y no lo es en recursos, codificación ni diagnóstico.

---

## B · Las 9 discrepancias, resueltas

Resueltas leyendo el código otra vez. **En tres, Codex tenía razón y Yov se quedó corto.**

### B.1 · Codex tenía razón (tres casos)

**1.2 — La prueba de `weightByTier` aparenta cubrir el caso y no lo cubre.**
Yov dijo CUMPLE CON RESERVA anotando que ninguna prueba cubre la ruptura de la invariante. **Codex dijo NO CUMPLE y afinó más.** Al releer `test/baplie_parser_test.dart:308-327`: la prueba **sí construye** un `containerWithoutPosition` (id `'5'`, `containerId: 'NO_POSITION'`) y lo mete en la bahía. Pero ese contenedor **no tiene `grossWeight`**, así que aporta 0 a `totalWeight` y la aserción `weightByTier.values.reduce(...) == totalWeight` pasa **por vacío**.

Es peor que no tener prueba: hay una que *parece* cubrir el caso exacto y no lo cubre. Basta añadirle un peso a ese contenedor para que falle. **Veredicto del cruce: NO CUMPLE.**

**7.4 — La regla de `latency_test` protege la actualización pero deja la creación abierta.**
Yov dio CUMPLE y llamó a la inmutabilidad de `t0`, `condicion` y `evento` «el argumento fuerte de la defensa». **Codex dio CUMPLE CON RESERVA y señaló lo que Yov no vio:** `allow create: if true`. Cualquiera puede crear un documento en `latency_test` ya con `respondido: true` y un `proceso_b_ms` arbitrario.

Es material para una tesis: la regla impide **alterar** una medición existente, pero no impide **sembrar** mediciones falsas. El argumento de integridad hay que enunciarlo con esa precisión, no más fuerte de lo que es. **Veredicto del cruce: CUMPLE CON RESERVA.** Va a TC-03.

**8.4 — La presentación sí accede a la capa de datos.**
Yov dio CUMPLE tras verificar que el dominio no importa Flutter. **Codex dio NO CUMPLE y tiene razón:** `vessel_providers.dart:3-4` importa `../../data/repositories/vessel_repository_impl.dart` y `../../data/services/baplie_parser_service.dart`, y construye las dos implementaciones directamente. Presentación depende de implementaciones de datos, no solo de la abstracción `VesselRepository` del dominio.

Yov comprobó una dirección de la regla y no la otra. **Veredicto del cruce: NO CUMPLE.** Es refactor de TC-01, no urgente.

### B.2 · Yov fue más estricto (un caso)

**4.3 — Etiqueta y color del perfil pueden contradecirse.**
Codex dio CUMPLE CON RESERVA; Yov dio NO CUMPLE. La diferencia es de grado sobre el mismo hecho: el relleno aplica `.clamp(0,1)` y la etiqueta no. Los dos lo describen igual. Se mantiene **CUMPLE CON RESERVA** porque, verificado sobre el corpus real, la bahía más cargada tiene 105 contenedores de 120: el caso **no se dispara hoy**. Queda como latente.

### B.3 · Codex cerró con evidencia lo que Yov no podía (un caso)

**3.4 — Repetición del encabezado de la tabla.**
Yov dejó CUMPLE CON RESERVA porque no pudo leer el fuente del paquete `pdf` ni ejecutar nada. Codex lo confirmó con capturas de las páginas globales 29, 30 y 31. **Veredicto del cruce: CUMPLE**, sin reserva. Es un ejemplo limpio de lo que aporta la mitad dinámica.

### B.4 · Diferencias de etiqueta, no de hecho (cuatro casos)

En 1.3, 2.4, 3.10 y 4.5 los dos describen exactamente el mismo comportamiento y lo clasifican en cubos distintos: nivel ocupado sin dato de peso, cadena de solo espacios, nombre de buque vacío en una entidad construida a mano, y si la leyenda declara que la escala es relativa. Ninguna cambia una decisión. Se adopta el veredicto más conservador de los dos.

---

## C · Lo que solo la mitad dinámica pudo encontrar

Las 23 comprobaciones [D] son la medida exacta de lo que aporta poder ejecutar. Tres resultados que ningún análisis estático habría dado:

**El ANR de Android es el hallazgo dinámico principal.** Abrir Bay Plan con `CORPUS_A01.edi` en Android API 36 produce un ANR persistente que no se recupera ni eligiendo «Wait» y esperando ocho segundos más. Windows y Web muestran la misma vista sin problema. La comprobación 1.8 pasa a NO CUMPLE: no se puede afirmar que RF-012 funcione en los tres clientes.

**El corpus real solo tiene dos navieras.** NV1 con 945 contenedores y NV6 con 32; y tres puertos de descarga: USHOU 907, USMSY 40, XXVSL 30. Consecuencia incómoda: **el criterio de aceptación de RF-020 —«las cinco navieras más frecuentes»— no se puede demostrar con `CORPUS_A01`**, porque no hay cinco. Para la demostración del 29 conviene tenerlo previsto.

**Los números de rendimiento, que hasta ahora no existían.** PDF en frío 5,464 s y en caliente 1,473 s en Windows; 55 páginas y 217 226 bytes. Carga y parseo del corpus 3,111 s sin que aparezca el indicador «Procesando archivo BAPLIE...». En Web el PDF tardó ~4,2 s; en Android el selector apareció a los ~12 s.

**Y una corrección de vocabulario que conviene adoptar.** `flutter analyze` reporta **49 issues: 4 `warning` y 45 `info`**, no «49 advertencias». Tres de los cuatro warnings son lints retirados en Dart 3.3 declarados en `analysis_options.yaml:9,21,22`, y el cuarto es un import sin usar en `test/widget_test.dart:1`. Los cuatro se arreglan en minutos. La bitácora venía diciendo «49 advertencias preexistentes»; la cifra es correcta pero la palabra no.

---

## D · La hipótesis que une las dos mitades

Yov encontró leyendo que `bay_plan_view.dart:478` genera **un solo rango** de niveles de `minTier` a `maxTier` de dos en dos, y verificó sobre el corpus que los niveles van **de 2 a 90**. Eso son **45 filas de nivel por bahía, de las cuales solo 12 tienen carga**: del orden de 540 celdas construidas por bahía, la mayoría vacías, sin construcción diferida. El PDF no sufre porque calcula cubierta y bodega por separado — que es justo la comprobación 3.9, donde los dos coincidimos en NO CUMPLE.

Codex encontró ejecutando que **esa misma vista provoca un ANR en Android**.

**Es la hipótesis principal sobre la causa del ANR: el mecanismo predicho estáticamente y el síntoma observado dinámicamente coinciden en la misma línea de código.** No está probada. Se prueba barato, y conviene hacerlo antes de decidir la corrección:

1. Abrir Bay Plan en Android con el fixture de 7 contenedores (niveles 2-6, rango corto). Si no hay ANR, el tamaño del rango es sospechoso principal.
2. Abrir con el corpus una bahía cuyos contenedores estén **solo** en bodega. Si tampoco hay ANR, queda confirmado: el problema es el hueco entre el nivel 14 y el 82.

Si se confirma, la corrección es la misma que ya usa el PDF —rangos separados para cubierta y bodega— y cierra el ANR y la comprobación 3.9 de una vez.

---

## E · Una advertencia sobre las citas del informe de Codex

Sus **veredictos son sólidos** —ganó tres discrepancias sobre puntos que exigían leer el código con cuidado— pero **sus referencias de archivo y línea no son fiables**, y eso importa porque este material va a un tribunal.

Verificado sobre el árbol real:

| Cita de Codex | Realidad |
|---|---|
| `lib/features/vessel/data/parsers/baplie_parser_service.dart` | **Ese directorio no existe.** Es `data/services/` |
| `lib/features/vessel/data/parsers/iso_coordinate_parser.dart` | **No existe.** Es `lib/core/utils/` |
| `kStackWeightLimitKg` en `bay_plan_view.dart:113-117` | Está en `baplie_constants.dart:117`; esas líneas de `bay_plan_view` son un `ListView.builder` |
| `fromCharCodes` en `vessel_providers.dart:315-321` | Está en la línea **83** |
| `test/export_service_test.dart:1-146` | El archivo tiene **75** líneas |
| `test/vessel_profile_view_test.dart:1-108` | El archivo tiene **165** líneas |

No es que no leyera el código —para acertar en 1.2 y 8.4 tuvo que leerlo— sino que **reconstruyó las citas de memoria en vez de copiarlas**. Es la misma clase de error que la auditoría de seguridad del 25-ago, donde dos hallazgos resultaron falsos por inferir las reglas en vez de leerlas; solo que aquí afecta a las referencias y no a las conclusiones.

**Antes de que una sola de esas rutas entre en un entregable hay que corregirlas.** Las de este documento y las del informe de Yov sí están verificadas contra el árbol.

Nota menor sobre el Anexo B: el total final (`+31: All tests passed!`, exit 0) es creíble y coincide con el conteo estático de los dos auditores. Pero las líneas intermedias no enumeran 31 pruebas distintas —repiten nombres y no mencionan `export_service_test` ni `pdf_report_service_test`—, cosa que el reportero `expanded` puede producir al ejecutar suites en paralelo. La cifra se sostiene; la transcripción no prueba por sí sola *cuáles* 31 corrieron.

---

## F · Qué hacer antes del 29 de agosto

**Nada de esto impide entregar.** Las cinco funcionalidades del Sprint 1 están, compilan en las tres plataformas y las 31 pruebas pasan.

### Bloqueante para la demostración

1. **Decidir qué se hace con el ANR de Android.** Es lo único con impacto real en la revisión. Dos caminos honestos: correr el diagnóstico de la sección D y arreglarlo si se confirma la causa, o **no demostrar Bay Plan en Android** y declararlo como limitación conocida junto a los otros disclosures. Lo que no conviene es abrir esa vista en vivo sin saber.
2. **Prever que RF-020 no se puede lucir con `CORPUS_A01`**: solo hay dos navieras, no cinco.

### Añadir a los disclosures

3. **La capacidad de bahía**, junto al límite de apilamiento. Los dos auditores coincidieron en 4.7. Con el corpus real la ocupación media mostrada es **30,2 %** contra **74,1 %** sobre la extensión real de cada bahía.
4. **Decir «49 issues: 4 warnings y 45 infos»**, no «49 advertencias».

### Correcciones baratas, si hay tiempo

5. Los cuatro `warning` de `analyze`: tres lints retirados en `analysis_options.yaml:9,21,22` y un import sin usar en `test/widget_test.dart:1`.
6. La desalineación de la cabecera de filas (1.7) y la leyenda OOG en `deepOrange` que no corresponde a ninguna celda.

### A TC-01 y TC-03 (octubre)

Los quince defectos confirmados que no estén arriba, más las tres discrepancias resueltas a favor de Codex. En orden de prioridad: inyección de fórmulas del CSV (5.4), límite de tamaño y parseo fuera del hilo de UI (6.3, 6.7), la prueba vacía de `weightByTier` (1.2), la creación abierta en `latency_test` (7.4) y la violación de capas (8.4).

---

## G · Lo que este ejercicio demuestra sobre el método

Para el apartado metodológico del entregable, tres resultados objetivos:

1. **83 % de acuerdo** entre dos auditores independientes sobre 54 juicios técnicos, con ceguera garantizada por el orden de commits y por aislamiento físico en un worktree.
2. **La redundancia sirvió:** tres defectos reales aparecieron solo porque hubo un segundo auditor (1.2, 7.4 y 8.4), y uno de ellos —la prueba que aparenta cubrir un caso sin cubrirlo— es de los que un solo revisor no encuentra nunca, porque la prueba existe y pasa.
3. **Las dos mitades se necesitan.** El análisis estático predijo un mecanismo (45 filas de nivel por bahía) que la ejecución encontró como síntoma (ANR en Android) sin que ninguno viera al otro. Ni leyendo solo, ni ejecutando solo, se llega a esa conexión.
