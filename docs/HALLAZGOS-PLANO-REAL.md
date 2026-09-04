# Lo que enseña el plano de carga real

**Origen:** fotografías tomadas por Carlos el 31 de agosto de 2026 durante una
operación en Puerto Santo Tomás de Castilla, del plano impreso del buque
**MIZAR, viaje 260345**, generado por *Baplie Viewer* a partir de
`PRE STOWAGE BAPLIE 2.0 MIZAR 260345 GTSTC.edi`. Se fotografiaron las bahías 06
y 07, antes y después de la carga.

Este documento contrasta ese plano —que es la referencia de la industria y lo
que el planificador realmente usa— contra lo que BayStream muestra hoy, y
traduce las observaciones del tutor en cambios concretos.

**Es la primera vez que el proyecto tiene una referencia externa del formato de
salida.** Hasta ahora el plano de BayStream se diseñó por deducción del
estándar. Varias diferencias que la auditoría de calidad había clasificado como
defectos menores resultan ser, a la luz del plano real, decisiones equivocadas
de fondo.

**Decisiones tomadas el 1 de septiembre de 2026:** la posición de estiba es de
**siete dígitos** (`BBBRRTT`), y la pantalla de parámetros **propone la
geometría deducida del archivo para que el usuario la confirme o la corrija**.
Ambas están incorporadas en C‑3 y C‑6.

---

## 1 · Anatomía de la hoja impresa

Conviene leerla entera antes de tocar código, porque cada elemento tiene una
razón operativa.

**Cabecera.** Remitente, hora de preparación, número de viaje de carga y de
descarga, buque, indicativo de llamada, y el nombre del archivo EDI de origen.
Declara además el conteo: `20FT Units = 0, 40FT Units = 38`.

**Fila superior de números.** Dos líneas de pesos por **fila** (por *stack*, la
pila vertical), alineadas con las columnas de abajo: `0.0 · 0.0 · 19.8 · 62.7 ·
91.5 · 131.8 · 0.0 · 123.2 · 92.6 · 80.5 · 82.6 · 19.9 · 0.0`.

**Rótulos de columna.** `12 · 10 · 08 · 06 · 04 · 02 · 00 · 01 · 03 · 05 · 07 ·
09 · 11` — trece columnas. Las pares descienden hacia babor, las impares
ascienden hacia estribor, y **el 00 va en el centro**.

**Rótulos de fila (niveles).** Cubierta `90 · 88 · 86 · 84 · 82 · 80`, una
línea doble de separación, y bodega `14 · 12 · 10 · 08 · 06 · 04 · 02`.
**Corrección (Carlos, 3 de septiembre — ver corrección 5 del registro):** de
esas seis etiquetas de cubierta, el nivel realmente utilizable es el **82**,
no el 80. El 80 no aparece ocupado ni una sola vez en los 4584 slots del
corpus (seis archivos) y no corresponde a un nivel real de estiba del MIZAR.
**Doce niveles reales en total: cinco de cubierta y siete de bodega.**

**Columna derecha.** Peso acumulado por **nivel**: `159.3 · 123.8 · 145.3 ·
114.8 · 60.9` para los niveles con carga, `0.0` para el resto.

**Contenido de cada celda ocupada.** Cinco datos apilados:

```
0060810          <- posición de estiba, siete dígitos
KCT/STC          <- agente / condición
JKLU        F    <- prefijo del contenedor y el indicador Lleno
7834005          <- número de contenedor
19.9    45G1     <- peso en toneladas y tipo ISO
```

**Celdas de la bahía impar.** En la hoja de la bahía 07 casi todas las celdas
dicen **`Occupied by 40'`**. No están vacías: están físicamente ocupadas por
contenedores de 40 pies estibados en las bahías pares vecinas.

**Nota al pie, literal:** *«Baplie Viewer is not aware of vessel's dimensions.
It shows occupied slots on board the vessel.»* La herramienta comercial declara
que no conoce la geometría del buque. Esa frase es la que da sentido a la
sugerencia del tutor sobre parametrizar.

**Las equis grandes.** En la hoja de la bahía 14 hay equis trazadas a mano que
tachan zonas enteras del plano. **No son slots inexistentes ni celdas vacías:
marcan carga que no se opera en esta escala** — contenedores de otros puertos
que siguen a bordo y que la cuadrilla no debe tocar. Es una marca operativa,
no una propiedad del buque. (Ver la corrección número 3 del registro final.)

**Anotaciones a mano del planificador.** Números de secuencia de grúa dentro de
círculos sobre cada celda (139, 155, 144…), flechas de orden de movimiento, y
el total `26 MOVS` al pie. Es información que no viene en el EDI y que el
planificador añade encima.

---

## 2 · Los siete cambios

### C‑1 · TEU sin decimales

**Plano real:** la cabecera cuenta unidades enteras — `20FT Units = 0,
40FT Units = 38`.

**BayStream:** la portada del PDF reporta `TEU 1831.50`.

**Causa exacta:** `pdf_report_service.dart:683` calcula `size / 20`, y
`ContainerUnit.sizeInFeet` devuelve 45 para los tipos que empiezan en `L`. Con
`CORPUS_A01`: 827 contenedores de 40 pies a 2.0 + 128 de 20 pies a 1.0 + **22
contenedores `L5G1` a 2.25** = 1831.5. Todo el decimal sale de esos 22.

**Cambio:** un contenedor de 45 pies cuenta **2 TEU**, no 2.25. El total es
siempre entero y se muestra sin decimales, en todas las vistas y en el PDF.
Con `CORPUS_A01` el valor correcto es **1826 TEU**.

### C‑2 · La fila 00 tiene que existir siempre

**Plano real:** trece columnas, con el `00` en el centro entre el `02` y el `01`.

**BayStream:** la rejilla muestra `12 10 08 06 04 02 | 01 03 05 07 09 11` —
**doce columnas, sin el 00.**

**Evidencia en el corpus:** la fila 00 **existe de verdad**. Cuatro de los
siete archivos la usan:

| Archivo | Filas presentes | ¿Fila 00? |
|---|---|---|
| A01, A02, A04 | 01 – 12 | no |
| A03, A03v_VGM, A05, A06 | **00** – 10 | **sí** |

Hoy la rejilla se construye con `[minRow … maxRow]`, así que en los archivos
con fila 00 la dibuja, pero en el orden equivocado, y en los que no la traen
desaparece. Debe estar **siempre**, y **siempre en el centro**.

**Cambio:** el orden de columnas es fijo — pares descendentes, luego 00, luego
impares ascendentes. La fila 00 se dibuja aunque esté vacía.

### C‑3 · Parametrizar la geometría del buque antes de cargar el EDI

Es el cambio de fondo, y del que dependen C‑2, C‑4 y la ocupación.

**El problema:** el BAPLIE **no transmite las dimensiones del buque**. Lo dice
la nota al pie del plano comercial. BayStream hoy lo resuelve de dos maneras y
las dos están mal:

- Infiere la rejilla del contenido: `[minRow … maxRow]` y `[minTier … maxTier]`.
  Un buque medio vacío se dibuja pequeño.
- Supone la capacidad: `Bay` nace con `maxRows = 12` y `maxTiers = 10` y el
  parser **nunca los asigna**, así que toda la ocupación se calcula contra 120
  huecos ficticios. Sobre `CORPUS_A01` la ocupación media que se muestra es
  **30.2 %**, contra **23.2 %** medido sobre la geometría declarada de 13
  columnas × 12 niveles (156 huecos por bahía). Ver las correcciones número 1
  y número 5 del registro al final: la primera versión de este documento daba
  **74.1 %**, la segunda corrección lo bajó a 21.4 % pero con un denominador
  de 169 huecos que resultó tener un nivel de más; el número correcto es
  **23.2 %**.

**Cambio:** una pantalla de parámetros **previa a la carga del EDI**, donde se
declare la geometría: filas de babor y de estribor, si el buque tiene fila 00,
niveles de bodega, niveles de cubierta, y el límite de apilamiento. La rejilla
y la ocupación pasan a calcularse contra esos valores, no contra el contenido.

**Consecuencia que conviene subrayar:** esto convierte dos limitaciones
declaradas del proyecto —el límite de apilamiento provisional y la capacidad
ficticia de bahía— en **datos que el usuario aporta**. Deja de ser una
limitación y pasa a ser una función.

**Decisión de Carlos (1 de septiembre):** la aplicación **propone lo que deduce
del archivo y el usuario confirma o corrige**. La captura de los parámetros
enteramente a mano queda fuera de este alcance y se documentará aparte como
procedimiento manual.

Esa decisión tiene una consecuencia de diseño que hay que resolver bien:

**El archivo solo revela los slots ocupados, nunca la geometría.** Un buque de
catorce filas que este viaje solo carga en diez se ve, desde el EDI, como un
buque de diez filas. Por eso la propuesta que la aplicación calcule es siempre
una **cota inferior**: la geometría real es mayor o igual, nunca menor. Es
exactamente lo que declara la nota al pie del plano comercial. La pantalla
tiene que dejar claro que lo propuesto es un mínimo observado y no una medición.

**Corrección (ver corrección 5 del registro final).** La versión anterior de
este documento afirmaba aquí que el plano impreso del MIZAR tenía seis niveles
de cubierta —con el 80 como nivel real pero siempre vacío— y usaba ese caso
para argumentar que la regla de deducción debía anclarse en el valor máximo
observado y no en la cuenta de valores distintos. Carlos corrigió el dato de
origen: el nivel real más bajo de cubierta es el **82**, no el 80, así que la
cubierta tiene **cinco** niveles, no seis. Contando valores distintos en el
corpus se llega exactamente a esos cinco (82, 84, 86, 88, 90 — 2375
posiciones en los seis archivos), así que en este caso concreto contar
valores distintos ya da el número correcto. No hay una discrepancia que
anclar, y la demostración numérica anterior queda retirada.

Lo que sigue en pie, y sigue siendo la razón de fondo de C‑3, es que **un
corpus de seis viajes no prueba que esos sean todos los niveles reales del
buque**. Si el MIZAR tuviera un nivel adicional que en ninguno de estos seis
viajes se usó, el corpus jamás lo mostraría. La cota inferior sigue siendo
cota inferior aunque en este caso particular, ya verificado, coincida con la
realidad.

**Qué se puede deducir y qué no:**

| Parámetro | ¿Deducible del archivo? | Cómo |
|---|---|---|
| Filas presentes | Sí, como mínimo | Conjunto de `RR` de las coordenadas |
| ¿Existe la fila 00? | Solo si viene ocupada | Presencia de `RR = 00` |
| Niveles de bodega | Sí, como mínimo | Conjunto de `TT` menores que 50 |
| Niveles de cubierta | Sí, como mínimo | Conjunto de `TT` mayores o iguales a 50 |
| Bahías | Sí | Conjunto de `BBB` |
| **Límite de apilamiento** | **No** | Viene del manual de estabilidad del buque |

El límite de apilamiento no se propone: se escribe. Es el único campo que no
tiene un valor deducible, y por eso hasta hoy vivía como constante provisional
en el código.

**Sobre el orden del flujo.** El tutor dijo «parametrizar antes de cargar el
EDI». Con la opción elegida el archivo hay que **leerlo** primero para poder
proponer. No es una contradicción si se ordena así:

```
elegir archivo  →  parsear  →  pantalla de parámetros con la propuesta
                →  el usuario confirma o corrige  →  se construye el plano
```

Desde el punto de vista del usuario sigue siendo «antes del plano», que es lo
que importa. Lo que **no** debe pasar es que se dibuje una rejilla con la
geometría inferida y después se ofrezca ajustarla.

### C‑4 · Los niveles reales, sin el desierto de celdas vacías

**Plano real:** doce niveles. Cubierta 82–90 (cinco niveles: 82, 84, 86, 88,
90), bodega 02–14 (siete niveles).

**BayStream:** dibuja el rango continuo del mínimo al máximo. Como el corpus va
del nivel 02 al 90, genera **45 filas de nivel por bahía de las que solo 13
pueden tener carga**. Las capturas lo muestran: entre el 78 y el 16 no hay más
que celdas grises.

**Evidencia en el corpus:** los siete archivos usan **exactamente los mismos
niveles**, sin una sola excepción:

```
cubierta : 82, 84, 86, 88, 90
bodega   : 02, 04, 06, 08, 10, 12, 14
```

No existe ningún dato real en los niveles 16 a 78. La aplicación los inventa.

**Cambio:** los rangos de cubierta y de bodega se calculan **por separado** y
salen de los parámetros de C‑3, no de la interpolación. El generador de PDF ya
lo hace bien (`pdf_report_service.dart:305-310`, rangos separados); es la
pantalla la que está mal (`bay_plan_view.dart:478`, un solo rango).

**Esto es además la hipótesis principal de la detención en Android.** Con 45
filas × 13 columnas se construyen unas 585 celdas por bahía, la mayoría vacías
y sin construcción diferida. Al corregir C‑4 se cae a 156. **Verificar el ANR
en Android inmediatamente después de este cambio, antes de tocar nada más.**

### C‑5 · Lo que ocupa un slot sin ser carga de esta operación

Este cambio tiene **dos mitades independientes**, y las dos responden al punto
del tutor sobre mostrar las bahías completas. Se pueden implementar por
separado.

#### C‑5a · La carga que va de paso — ✓ cerrado (`ba73ac3`)

**Plano real:** las equis a mano tachan la carga que no se opera en esta
escala. El planificador necesita verla —ocupa slots y condiciona el orden de
los movimientos— pero no la toca.

**Evidencia en el corpus: el dato ya está en el archivo.** El segmento `LOC+9`
declara el puerto de carga de cada contenedor, y en `CORPUS_A01` hay tres,
reverificado directamente sobre el `.edi`:

| Puerto de carga | Contenedores |
|---|---|
| HNPCR · Puerto Cortés, Honduras | 457 |
| GTPBR · Puerto Barrios, Guatemala | 325 |
| PAMIT · Manzanillo, Panamá | 195 |

**La primera versión de esta sección asumía Puerto Barrios como la escala y
por lo tanto 325/652.** Es un ejemplo real, no hipotético, de por qué el
campo tiene que proponerse y confirmarse y no aplicarse solo: la propuesta
automática —el `LOC+9` más frecuente— da **HNPCR con 457, no GTPBR**. Con
GTPBR el reparto es 325 operados / 652 de paso; con HNPCR, 457 / 520. En
`CORPUS_A01` hay que corregir la propuesta a mano si la escala real es
Puerto Barrios, y el campo confirmable existe exactamente para eso.
Hallazgo del segundo programador al implementar el cambio, 3 de septiembre.

**Cambio, implementado:** `BayStream` ya parseaba `LOC+9` y no lo usaba para
nada; ahora el plano atenúa (sin perder el ícono de tipo) los contenedores
cuyo puerto de carga no coincide con el puerto de esta escala, con una
entrada propia y filtrable en la leyenda («De paso») que solo aparece si hay
puerto declarado. El campo de puerto vive en la pantalla de parámetros de
C‑3, propuesto desde el `LOC+9` más frecuente y confirmable, tal como se
decidió.

**Decisión de modelo, registrada:** el puerto de escala **no** entró en
`VesselGeometry` — el casco no cambia entre escalas del mismo viaje, así que
vive en `VesselVoyage` (campo `portOfCall`, más `proposedPortOfCall` y el
predicado `isInTransit`), y la pantalla de parámetros devuelve un registro
con las dos cosas (`({VesselGeometry geometry, String? portOfCall})`). La
regla de qué cuenta como «ir de paso» queda en el dominio, no en la vista:
`bay_plan_view.dart` recibe `isInTransit` como función y la llama, no la
reimplementa. Confirmado leyendo `vessel_voyage.dart` y
`bay_plan_view.dart:80,732`.

**Corrección a una premisa de esta misma sección.** Más arriba se dijo
«falta un dato que el archivo no da: cuál es el puerto de la operación en
curso». **Es falso — el archivo sí lo da.** El segmento `LOC+5` (lugar de
salida) está en los siete archivos, una vez por archivo, a nivel de mensaje,
no por contenedor como `LOC+9`. Reverificado directo sobre los `.edi`:
`CORPUS_A01` trae `LOC+5+GTPBR`, exactamente Puerto Barrios — el puerto que
la propuesta por frecuencia de `LOC+9` **no** acertaba (proponía HNPCR con
457, no GTPBR con 325). C-5a funciona porque el campo se confirma a mano,
pero apostaba con `LOC+9` habiendo un dato duro al lado en `LOC+5`. El
parser no lee el calificador `5` de `LOC` hoy, y `portOfOrigin` en
`VesselVoyage` existe mapeado en `toJson`/`fromJson` pero nunca se asigna —
confirmado, se queda `null` siempre. Sin tocar todavía: la corrección
natural es proponer `LOC+5` primero y dejar el `LOC+9` más frecuente como
alternativa manual, no al revés. Hallazgo del segundo programador al cerrar
C‑7, 3 de septiembre.

**De paso, responde una duda operativa de Carlos: ¿el archivo es de carga o
de descarga?** Es de carga. Ninguno de los 977 contenedores de `CORPUS_A01`
descarga en GTPBR — reverificado por `LOC+11` contenedor por contenedor: 907
a USHOU, 40 a USMSY, 30 a XXVSL, cero a GTPBR. Viaje `V01N`, rumbo norte: los
325 que se cargan en Puerto Barrios y los 652 que ya vienen de Panamá y
Honduras siguen todos hacia Houston y puertos cercanos. Explica por qué los
20 pies enterrados en la bodega de la bahía 23 no se tocan en esta escala —
sería absurdo reestibar tanto para sacar tan poco, y en efecto no se saca
nada ahí. La duda de Carlos se resuelve con el dato, no con una suposición.

#### C‑5b · Los slots ocupados por contenedores de 40 pies — ✓ cerrado (`15cf140`)

**Plano real:** la bahía 07 aparece casi llena de celdas que dicen
`Occupied by 40'`, con solo dos contenedores propios y `2 MOVS` al pie.

**BayStream, antes:** mostraba la bahía 07 con 10 contenedores y **8 % de
ocupación**. Para el planificador esa cifra era falsa: la bahía está
prácticamente llena.

**Evidencia en el corpus — la regla es absoluta:**

| Archivo | 20 pies en bahía impar | 40/45 pies en bahía par | Excepciones |
|---|---|---|---|
| A01 | 128 | 849 | **0** |
| A05 | 190 | 546 | **0** |

Un contenedor de 40 pies estibado en la bahía par `B` **ocupa físicamente los
slots de las bahías impares `B‑1` y `B+1`**. Por eso las bahías pares e impares
no son independientes.

**Cambio, implementado.** `neighborOccupiedSlots()` vive en `VesselVoyage` y
se inyecta en cada `Bay` como `slotsOccupiedByNeighbors` — igual que la
geometría, sin serializarse porque es derivado, no un dato propio. La
ocupación cuenta la **unión** de slots propios y tomados, no la suma: hay
una prueba con datos deliberadamente inconsistentes (una bahía impar declara
carga en un hueco que su vecina par ya reclama) que fija que el resultado es
un slot, no dos. Verificado en dispositivo, con un matiz: el emulador API 36
tenía el gestor de paquetes roto tras instalar C‑5a; con otro AVD instaló a
la primera. La bahía 07 pasa de 8 % a 44 % con los mismos seis contenedores
propios, la cubierta se ve entera marcada `40'` como en el plano impreso, y
la leyenda trae las dos entradas nuevas. Confirmado también por dos pruebas
de widget que montan el plano completo (`test/bay_plan_grid_test.dart`,
incluida `find.text("40'")`).

**Caso raro, verificado.** En `CORPUS_A01` la bahía 41 tiene carga propia y
ninguna vecina par cargada — el algoritmo no asume que siempre existe la
vecina; confirmado que sigue así.

**Hallazgo nuevo, abierto — siete bahías impares invisibles.** El parser solo
crea una `Bay` cuando tiene contenedores propios. Reverificado directamente
sobre `CORPUS_A01`: hay **siete bahías impares con slots físicamente
ocupados por vecinas pares y cero contenedores propios**, que hoy no existen
en `voyage.bays` y por lo tanto no se dibujan en absoluto — no es que se vean
vacías, es que no aparecen:

| Bahía | Huecos tomados / 156 | % |
|---|---|---|
| 005 | 62 | 39.7 % |
| **013** | **92** | **59.0 %** |
| 015 | 92 | 59.0 % |
| 035 | 104 | 66.7 % |
| 039 | 98 | 62.8 % |
| 043 | 25 | 16.0 % |
| 045 | 25 | 16.0 % |

La 013, la más grave, está un 59 % físicamente llena y es invisible para el
planificador. No se tocó a propósito: crear bahías sin carga propia cambia
qué significa `voyage.bays` —de «bahías con contenedores del viaje» a «bahías
con cualquier evidencia de ocupación física»— y eso es alcance nuevo, más
allá de lo aprobado para C‑5b. `neighborOccupiedSlots()` ya calcula el dato
necesario, así que el arreglo es chico si se aprueba.

**Aprobado aquí para después de C‑7:** extender `voyage.bays` para incluir
toda bahía con evidencia física de ocupación —propia o de vecinas—, no solo
contenedores propios. Es la misma regla epistémica que ya rige la geometría
declarada desde C‑3: se muestra lo que el archivo permite deducir con
certeza, nunca menos. Una bahía sin ningún dato —ni propio ni de vecina—
sigue sin poder mostrarse, porque de esa no hay nada que deducir; el punto
es no ocultar la que sí tiene evidencia.

### C‑6 · La posición nunca puede perder los ceros a la izquierda

**Plano real:** `0060810`, siete dígitos con relleno.

**BayStream, en la aplicación:** correcto. `displayFormat`
(`iso_coordinate_parser.dart:25`) usa `padLeft` y produce `Bay 006, Row 08,
Tier 10`.

**BayStream, en el CSV abierto en Excel:** **incorrecto**. La columna
`stowagePosition` exporta `rawCode`, que es la cadena de siete dígitos, pero
Excel la interpreta como número y le come los ceros: `0030410` se convierte en
`30410`, `0060688` en `60688`. Se ve en la captura de Excel.

**Cambio:** forzar que la columna de posición se lea como texto en Excel.
**Cuidado al elegir cómo:** el truco habitual de escribir `="0030410"` es
exactamente el patrón de inyección de fórmulas que la auditoría marcó como
defecto 5.4. La solución tiene que ser compatible con neutralizar ese riesgo,
no empeorarlo. Resolver los dos juntos, no por separado.

**Confirmado por Carlos (1 de septiembre): siete dígitos.** El formato válido
es `BBBRRTT`, como en el plano impreso: `0060810` es bahía 006, fila 08, nivel
10. Coincide con el estándar ISO 9711 y con lo que ya valida el parser
(`iso_coordinate_parser.dart:101`, `^\d{7}$`). Ningún componente puede mostrar
la posición con menos de siete dígitos ni recortar los ceros de la izquierda.

### C‑7 · Falta el peso por fila, que es donde el límite de apilamiento aplica — ✓ cerrado (`71ad205`)

**Plano real:** muestra **las dos** magnitudes. Arriba, el peso de cada fila —
la pila vertical. A la derecha, el peso de cada nivel.

**BayStream, antes:** solo mostraba el peso por nivel.

**El problema de fondo, ya corregido:** la constante se llamaba
`kStackWeightLimitKg`, que significa *límite de la pila*, pero se comparaba
contra la suma horizontal de las doce filas de ese nivel
(`bay_plan_view.dart:613`). Son magnitudes distintas. Por eso en la bahía 22
salían tres de cinco niveles en rojo: doce contenedores de 18 toneladas ya
sumaban 216, y el umbral era 90. Una alerta que se disparaba casi siempre no
informaba nada.

**Cambio, implementado.** Peso acumulado **por fila** en la cabecera, como el
plano real (`Bay._weightByRow`, separado en bodega y cubierta con el mismo
corte que usa la geometría —`tier >= VesselGeometry.firstDeckTier`—); el
límite de apilamiento se aplica ahí. El peso por nivel queda como dato
informativo, sin la alerta que no informaba nada.

**Verificado en la aplicación**, no solo en pruebas —Carlos lo corrió en
Windows porque el emulador seguía inservible. La bahía 22 muestra las tres
pilas de bodega marcadas (113.0, 101.3, 128.8), ninguna de cubierta, y los
pesos por nivel ya sin alerta — coincide exacto con la medición previa que
motivó el cambio. 109 `test(`/`testWidgets(` en total.

---

## 3 · Lo que sigue abierto del Sprint 1

**El indicador lleno/vacío. ✓ cerrado (`09599c8`), verificado contra los seis
archivos.** Ahora se lee el elemento 6 por su posición, no el primer valor
que coincida desde el índice 4. Reproduje el parseo viejo y el nuevo en
Python sobre el corpus completo: `CORPUS_A01` pasa de 84/893 a 242/735
(exacto a lo reportado); `CORPUS_A03` pasa de 46/323 a 315/54 — **269 de 315
llenos se perdían, el 85 %**, y el documento hasta hoy solo tenía registrados
los 158 de A01. En `A02`, `A04`, `A05` y `A06` el resultado no cambia,
porque en esos archivos el elemento 5 nunca vale `'4'` ni `'5'`, así que el
parser viejo llegaba al 6 igual, por casualidad de los datos y no por
diseño. Cero estados desconocidos en los seis archivos con el parseo nuevo.

Ocho de los fixtures EQD de `test/baplie_parser_test.dart` tenían un `+` de
más, que ponía el indicador en el elemento 7 en vez del 6 — con el parser
viejo pasaban igual, porque la búsqueda por valor no distingue la posición.
Es una instancia concreta, con nombre y apellido, del defecto 15 del cruce
de auditorías (*«hay pruebas que pasarían igual si el código estuviera
mal»*, `CRUCE-DOBLE-PRUEBA-SPRINT1.md`, checklist 8.3). Corregidos sin tocar
ninguna aserción existente; se agregó además un grupo de pruebas nuevo con
segmentos reales del corpus. Hallazgo y corrección del segundo programador,
3 de septiembre.

- **Los refrigerados no se detectan.** El corpus trae 43 segmentos `TMP` y 50
  contenedores con tipo ISO de refrigerado; la aplicación reporta 0.
- **`CORPUS_A06` no abre.** Lanza «No se encontró el nombre del buque en el
  segmento TDT». El parser busca el bloque `c222` (nombre del buque) en el
  elemento 8 del segmento `TDT`, posición válida en los otros seis archivos;
  en `A06` ese mismo bloque está en el elemento 4, porque el segmento omite
  los campos vacíos intermedios que sí trae el resto del corpus. **Es el
  mismo error de método que el indicador lleno/vacío, en otro segmento:
  confiar en una posición fija cuando la fuente real varía.** La diferencia
  es que en EQD la corrección fue anclarse en la posición correcta; acá no
  hay una posición fija que sirva para los siete archivos a la vez, así que
  el arreglo tendría que buscar el bloque `c222` por forma —tres o cuatro
  componentes separados por `:`, con texto reconocible como nombre en uno de
  ellos— en vez de por índice. No entra como tarea activa todavía: afecta a
  uno de siete archivos, no bloquea nada de lo que sigue en la lista, y el
  diseño de una búsqueda robusta merece pensarse aparte en vez de
  improvisarse. Hallazgo del segundo programador, 3 de septiembre; queda
  registrado para cuando se decida tomarlo.
- **`LOC+5` sin usar para proponer el puerto de escala.** El campo existe en
  los siete archivos, una vez por mensaje, con el puerto de salida real —no
  una frecuencia deducida. `C‑5a` propone hoy el `LOC+9` más frecuente entre
  contenedores, que en `CORPUS_A01` da HNPCR y no acierta; `LOC+5` da GTPBR
  directo, el correcto. Detalle completo en la sección 2, C‑5a. No entra
  como tarea activa: la corrección natural es proponer `LOC+5` y dejar
  `LOC+9` como alternativa manual, y merece su propio cambio en vez de un
  parche apurado sobre C‑5a recién cerrado.
- **Siete bahías impares invisibles en el plano.** Aprobado para
  implementarse; detalle y tabla completa en la sección 2, C‑5b.

**Estado verificado en código, no solo reportado.** `C‑2`, `C‑3`, `C‑4`,
`C‑5a`, `C‑5b`, `C‑6`, `C‑7` y `EQD` están cerrados. **`C‑1` (TEU sin decimales) en curso con Codex.** Diagnóstico
reverificado directo sobre el corpus, coincide exacto con el de Codex: 22
contenedores `L5G1` en `CORPUS_A01`, TEU con la regla vieja (`size / 20`)
1831.5, con la regla correcta (45 pies = 2.0) 1826.0 — los 5.5 de más son
justo esos 22 contenedores. Cambio aislado, un solo archivo
(`pdf_report_service.dart`), y `_formatTeu` puede simplificarse a entero
porque la suma de valores siempre enteros (1.0 ó 2.0 por contenedor) da
siempre un entero. Del resto quedan tres pendientes sin urgencia: `LOC+5`,
las bahías invisibles y el TDT de `CORPUS_A06`.

---

## 4 · Orden recomendado

`C‑3` es la base: sin la geometría parametrizada, `C‑2` y `C‑4` se quedan en
parches sobre una rejilla inferida.

1. **C‑3** — parámetros del buque. Habilita todo lo demás. ✓ cerrado
   (`45ff509`).
2. **C‑4** — rangos de nivel reales. **Probar el ANR en Android aquí mismo.**
   ✓ cerrado (`3f2ced5`); ANR verificado sin reproducir en emulador API 36,
   APK release, bahía 038, dieciocho cambios rápidos.
3. **C‑2** — fila 00 y orden fijo de columnas. ✓ cerrado (`3f2ced5`).
4. **EQD** — el indicador lleno/vacío. Pequeño, aislado y de alto impacto.
   ✓ cerrado (`09599c8`); ver el detalle completo en la sección 3.
5. **C‑1** — TEU entero. **Abierto** — quedó con Codex; sin confirmar.
6. **C‑5a** — la carga que va de paso. ✓ cerrado (`ba73ac3`); ver el
   detalle completo en la sección 2, C‑5a.
7. **C‑5b** — slots ocupados por 40 pies. ✓ cerrado (`15cf140`); ver el
   detalle en la sección 2, C‑5b, incluido el hallazgo abierto de las siete
   bahías impares invisibles.
8. **C‑7** — peso por fila y el límite donde corresponde. ✓ cerrado
   (`71ad205`); ver el detalle en la sección 2, C‑7.
8b. **Bahías invisibles** — extender `voyage.bays` a toda bahía con
   evidencia física de ocupación, no solo contenedores propios. Aprobado
   para después de C‑7; el cálculo ya existe en `neighborOccupiedSlots()`.
9. **C‑6** — posición en el CSV, junto con la neutralización de fórmulas.
   ✓ cerrado (`36f369b`).

**Estado al 3 de septiembre.** C‑3, C‑4, C‑2 y C‑6 quedan cerrados y
verificados en código y en el corpus por Yov, no solo reportados por el
segundo programador. Antes de dar C‑3 por completo cerrado falta una
extensión: `deckTiers` (y `holdTiers`) eran un entero con ancla y paso
fijos —no una lista— así que un buque con un arranque de cubierta distinto
o con un hueco no se podía expresar. ✓ cerrada (`17d9d49`), verificada más
abajo en esta misma sección. Hallazgo y corrección del segundo programador,
3 de septiembre.

**C‑6, verificado.** El CSV protege el campo con una tabulación al inicio
(`_excelTextGuard`), no con `="0030410"` — esa forma habría resuelto los
ceros creando el defecto 5.4 en el mismo cambio. Un solo predicado cubre los
dos casos porque son el mismo mecanismo: campo vacío no se toca; empieza en
`0` seguido de otro dígito → protegido (pierde los ceros si no); empieza en
`=`, `+`, `@`, tabulación, retorno de carro o salto de línea → protegido
(carácter de fórmula); empieza en `-` y lo que sigue **no** forma un número
→ protegido (fórmula disfrazada de resta); empieza en `-` y sí forma un
número → **no** se toca, es una temperatura real. Reverificado contra el
corpus completo: de las 4584 posiciones de estiba de los seis archivos,
4584 quedan protegidas (todas empiezan en `0`), y las temperaturas reales
del corpus (`-18`, `-18.0`, `-04.4`, `-22.0`…) pasan la prueba `double.
tryParse` y se quedan como número. Sobre `CORPUS_A01` en particular: 977
posiciones, las 977 protegidas, cero campos con forma de fórmula — coincide
exacto con lo reportado. Hay pruebas para las dos ramas del signo menos en
`test/export_service_test.dart` (grupo «Defecto 5.4 · inyección de
fórmulas»), incluida una que confirma explícitamente que `="..."` no
aparece en la salida. Carlos abrió el CSV de verdad en Excel y lo confirmó
a ojo.

**Por decisión del segundo programador, confirmada aquí: `C‑6` se adelantó y
fue antes que `C‑5a`.** No tenía ninguna decisión pendiente, y compartía
código con el defecto 5.4 de la auditoría de seguridad. Resuelto en el mismo
cambio, como estaba previsto.
`C‑5a` sigue detrás en el orden: depende de una decisión de operación ya
resuelta con Carlos —el campo de puerto de esta escala propone el `LOC+9`
más frecuente entre los contenedores del archivo, mismo patrón que el resto
de C‑3—, pero vuelve a tocar la pantalla de parámetros.

**Con EQD cerrado (`09599c8`, verificado: `CORPUS_A01` 242/735, `CORPUS_A03`
315/54 con 269 llenos rescatados — el 85 % que se perdía ahí —, sin cambios
en A02/A04/A05/A06, cero desconocidos), lo siguiente es la extensión de
`deckTiers`/`holdTiers` a `List<int>`, no `C‑1` ni `C‑5a`.** Razón del
segundo programador, confirmada aquí: `C‑5a` va a tocar la misma pantalla de
parámetros para agregar el campo de puerto de escala; conviene hacerlo una
sola vez con la lista editable ya en su lugar, no abrir esa pantalla dos
veces por separado. `C‑1` (TEU entero) queda disponible para hacerse en
paralelo o inmediatamente después — es independiente y no toca la pantalla
de parámetros.

**Extensión de C‑3, cerrada y verificada (`17d9d49`).** `deckTiers` y
`holdTiers` pasan de entero a `List<int>`, con chips quitables y uno para
agregar; la propuesta inicial sigue anclada en el máximo y contigua, como
quedó decidido — solo la edición manual admite huecos. El contrato
`isAtLeast` (comparaba cuentas) se retira porque con listas habría prohibido
quitar cualquier nivel, incluidos los vacíos — lo contrario de la función.
Lo reemplaza `coversAll(positions)`: el invariante pasa de «declarar al
menos tanto» a «no dejar carga fuera», que es el que importaba desde el
principio. Confirmado leyendo `vessel_geometry.dart:122` y su uso en
`vessel_geometry_page.dart:115`.

Se encontró y corrigió además un error de comparación: el resumen de la
pantalla rotulaba «geometría corregida por el usuario» sin que nadie
tocara nada, porque comparaba las listas propuesta/actual con `==`, que en
Dart compara **identidad de referencia**, no contenido — y la pantalla
trabaja sobre copias. Es el riesgo específico de convertir un campo de
`int` a `List<int>`: la semántica de la comparación cambia sin que el
compilador avise nada. Corregido con un `_sameTiers` elemento por elemento;
dos pruebas nuevas cubren las dos ramas (`vessel_geometry_page_test.dart`:
«la propuesta sin tocar no se rotula como corregida» y «al quitar un nivel
sí se rotula como corregida»). Vale la pena recordarlo si se migra algún
otro campo de conteo a lista más adelante en el proyecto.

Con `CORPUS_A01` ningún chip aparece removible por falta de carga: los doce
niveles reales tienen contenedores en alguna bahía de ese archivo — ya
verificado en la sección 3 (`n_unique_tiers = 12` en los seis archivos por
separado, no solo en el agregado). El caso de un nivel intermedio vacío en
todo el buque solo se ejercita hoy con los fixtures de prueba, no con el
corpus real; ahí está cubierto igual.

## 5 · Lo que no hay que hacer todavía

- No adelantar RF‑027 ni la validación a pie de muelle.
- No rediseñar la vista de estadísticas ni el perfil longitudinal.
- No tocar los archivos congelados de H5 ni `lib/main.dart`.
- No modelar las anotaciones a mano del planificador —secuencia de grúa,
  flechas, `26 MOVS`—. Es información valiosa y no está en el EDI; se discute
  como alcance nuevo, no se improvisa.


---

## 6 · Registro de correcciones a este documento

Se anotan porque el proyecto ya lleva cinco casos en que un segundo revisor
encontró algo que el primero había dado por bueno, y ese patrón es material
para el apartado de método. Ocultar las correcciones lo desperdiciaría.

**1 · La cifra de ocupación «real» del 74.1 % era errónea.**
*Detectada por el segundo programador, 3 de septiembre.* La primera versión de
este documento afirmaba que la ocupación media de `CORPUS_A01` era 30.2 %
mostrada contra 74.1 % «sobre la extensión real». El 74.1 % se calculó con un
denominador que se mueve con la carga —filas presentes × niveles presentes en
esa misma bahía—, lo que premia a las bahías casi vacías: **seis bahías
puntuaban exactamente 100 %**, entre ellas la 041, que tiene un solo contenedor
en una caja de 1 × 1. No servía como objetivo.

Sobre la geometría declarada de 13 × 13 = 169 huecos, las cifras correctas de
`CORPUS_A01` son:

| | Ocupación media |
|---|---|
| Bahías pares (11) | 45.7 % |
| Bahías impares (16) | 4.7 % |
| Todas (27) | **21.4 %** |

*(Nota, 3 de septiembre: este 21.4 % usaba un denominador de 169 huecos por
bahía que resultó tener un nivel de más. Ver la corrección número 5: el
número final correcto es 49.5 % / 5.1 % / 23.2 %.)*

**La cifra honesta baja de 30.2 % a 23.2 %, no sube.** Y seguirá baja hasta que
entre C‑5b, porque las 16 bahías impares están físicamente llenas de
contenedores de 40 pies que todavía no se cuentan. Al presentarlo hace falta esa
frase de contexto: el número anterior estaba inflado porque el denominador se
ajustaba a la carga.

**2 · El nivel 80 y la regla de deducción.**
*Aportada por el segundo programador, 3 de septiembre.* La regla debe anclarse
en el valor máximo observado y no en la cuenta de valores distintos. El plano
del MIZAR tiene seis niveles de cubierta y el nivel 80 no aparece ocupado en
ningún archivo del corpus. Incorporada a C‑3.

**3 · El significado de las equis del plano.**
*Corregida por Carlos, 3 de septiembre.* La primera lectura de la hoja de la
bahía 14 interpretó las equis como slots que no existen físicamente, y de ahí
dedujo que el casco se estrecha hacia proa y popa. **Es falso.** Las equis son
marcas a mano del planificador sobre carga que no se opera en esa escala. La
deducción sobre la forma del casco queda retirada por completo.

**4 · `LOC+9` ya trae con qué resolver el punto 2 del tutor.**
*Hallada al investigar la corrección 3, 3 de septiembre.* El puerto de carga de
cada contenedor está en el archivo y BayStream lo parsea sin usarlo. Eso parte
C‑5 en dos mitades independientes, C‑5a y C‑5b.

**5 · El nivel 80 no era un nivel real, y eso también arrastraba mal la cifra
de la corrección 1.**
*Corregido por Carlos vía el segundo programador, 3 de septiembre.* La
corrección número 2 de este mismo registro decía que el plano del MIZAR tiene
seis niveles de cubierta, con el 80 como nivel real que solo aparece vacío.
Era la lectura equivocada. Carlos aclaró que el nivel real más bajo de
cubierta es el **82**: la cubierta tiene **cinco** niveles (82, 84, 86, 88,
90), no seis, y el 80 no corresponde a ningún nivel real de estiba del buque.

Se reverificó contra los seis archivos primarios del corpus (excluyendo
`CORPUS_A03v_VGM`, idéntico a `A03`): **4584 posiciones ocupadas en total**.
El nivel 80 no aparece ni una sola vez; el 82 aparece 386 veces, en 45 de las
130 combinaciones bahía‑archivo del corpus. Doce niveles reales en total, no
trece: siete de bodega (02–14, en 66 combinaciones bahía‑archivo para el
nivel 02) y cinco de cubierta (82–90). Eso arrastraba dos números más:

- La geometría declarada pasa de **13 × 13 = 169** huecos por bahía a
  **13 × 12 = 156**.
- Las cifras de la corrección 1, calculadas sobre el denominador de 169,
  quedan a su vez corregidas: sobre `CORPUS_A01`, bahías pares **49.5 %** (no
  45.7 %), impares **5.1 %** (no 4.7 %), todas **23.2 %** (no 21.4 %).

Es la tercera cifra que se corrige en este documento, y la segunda vez que se
corrige una corrección anterior. La demostración original del punto 2 —anclar
la deducción en el máximo, no en la cuenta de valores distintos, usando el 80
como ejemplo— queda retirada: contando valores distintos en este corpus ya se
llega a los cinco niveles reales de cubierta, sin discrepancia que anclar. El
principio general, que lo deducido del EDI es siempre una cota inferior y
nunca una medición, sigue siendo válido y sigue siendo la razón de C‑3;
simplemente ya no tiene, en este documento, un ejemplo numérico que lo
demuestre con este corpus.

**Sobre la corrección 3 conviene ser explícito:** el error se cometió por
inferir el significado de una marca en vez de preguntar a quien trabaja en el
muelle. Es la misma clase de fallo que la auditoría de seguridad del 25 de
agosto documentó al inferir las reglas de Firestore en lugar de leerlas. Con
la corrección 5 ya son cuatro apariciones del mismo patrón, y la lección
operativa es la misma: **cuando el dato viene del mundo y no del código, se
observa o se pregunta; no se deduce.**

**Sobre la corrección 5 conviene añadir algo distinto:** no fue un error de
inferencia sino de no volver a confirmar contra la fuente primaria antes de
escribirlo como una demostración cerrada. El segundo programador aportó el
dato del nivel 80 de buena fe y con un argumento que sonaba completo; quedó
incorporado a este documento sin que nadie —ni Yov, que lo redactó, ni Carlos,
hasta que lo contrastó con lo que sabe del buque— lo verificara de nuevo. La
lección no cambia, solo se extiende: se observa o se pregunta, incluso cuando
el dato ya llega envuelto en la demostración de otra persona.
