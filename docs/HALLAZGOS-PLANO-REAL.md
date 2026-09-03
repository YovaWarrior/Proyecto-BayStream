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
línea doble de separación, y bodega `14 · 12 · 10 · 08 · 06 · 04 · 02`. **Trece
niveles en total y ni uno más.**

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
  **30.2 %**, contra **21.4 %** medido sobre la geometría declarada de 13
  columnas × 13 niveles. Ver la corrección número 1 del registro al final: la
  primera versión de este documento daba **74.1 %** y ese número era erróneo.

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

**La regla de deducción se ancla en el máximo, no en la cuenta de valores
distintos.** La diferencia no es teórica y tiene una demostración exacta: el
plano impreso del MIZAR tiene **seis** niveles de cubierta —80, 82, 84, 86, 88
y 90— pero **el nivel 80 no aparece ocupado ni una sola vez en ninguno de los
siete archivos del corpus**. Contando valores distintos se deducirían cinco
niveles y el buque tiene seis. Anclando en el máximo, `(90 − 80) / 2 + 1 = 6`,
sale el número correcto y el nivel 80 aparece vacío, como en la hoja impresa.

Es la demostración concreta y verificable de por qué lo deducido es una cota
inferior. Hallazgo del segundo programador durante la implementación de C‑3.

**Qué se puede deducir y qué no:**

| Parámetro | ¿Deducible del archivo? | Cómo |
|---|---|---|
| Filas presentes | Sí, como mínimo | Conjunto de `RR` de las coordenadas |
| ¿Existe la fila 00? | Solo si viene ocupada | Presencia de `RR = 00` |
| Niveles de bodega | Sí, como mínimo | Conjunto de `TT` menores que 80 |
| Niveles de cubierta | Sí, como mínimo | Conjunto de `TT` mayores o iguales a 80 |
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

**Plano real:** trece niveles. Cubierta 80–90, bodega 02–14.

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
y sin construcción diferida. Al corregir C‑4 se cae a 169. **Verificar el ANR
en Android inmediatamente después de este cambio, antes de tocar nada más.**

### C‑5 · Lo que ocupa un slot sin ser carga de esta operación

Este cambio tiene **dos mitades independientes**, y las dos responden al punto
del tutor sobre mostrar las bahías completas. Se pueden implementar por
separado.

#### C‑5a · La carga que va de paso

**Plano real:** las equis a mano tachan la carga que no se opera en esta
escala. El planificador necesita verla —ocupa slots y condiciona el orden de
los movimientos— pero no la toca.

**Evidencia en el corpus: el dato ya está en el archivo.** El segmento `LOC+9`
declara el puerto de carga de cada contenedor, y en `CORPUS_A01` hay tres:

| Puerto de carga | Contenedores |
|---|---|
| HNPCR · Puerto Cortés, Honduras | 457 |
| GTPBR · Puerto Barrios, Guatemala | 325 |
| PAMIT · Manzanillo, Panamá | 195 |

Si la escala es Puerto Barrios, **325 se cargan ahí y 652 ya vienen a bordo**.
Esos 652 son exactamente lo que la equis tacha. `CORPUS_A05` da el mismo
patrón con GTPBR 382, HNPCR 348 y USHOU 6.

**BayStream ya parsea `LOC+9` y no lo usa para nada.** Los muestra todos
iguales, sin distinguir lo que se opera de lo que va de paso.

**Cambio:** atenuar o marcar en el plano los contenedores cuyo puerto de carga
no sea el de esta escala. **Falta un dato que el archivo no da: cuál es el
puerto de la operación en curso.** Encaja de forma natural en la pantalla de
parámetros de C‑3, como un campo más con los puertos del archivo como opciones.

#### C‑5b · Los slots ocupados por contenedores de 40 pies

**Plano real:** la bahía 07 aparece casi llena de celdas que dicen
`Occupied by 40'`, con solo dos contenedores propios y `2 MOVS` al pie.

**BayStream:** muestra la bahía 07 con 10 contenedores y **8 % de ocupación**.
Para el planificador esa cifra es falsa: la bahía está prácticamente llena.

**Evidencia en el corpus — la regla es absoluta:**

| Archivo | 20 pies en bahía impar | 40/45 pies en bahía par | Excepciones |
|---|---|---|---|
| A01 | 128 | 849 | **0** |
| A05 | 190 | 546 | **0** |

Un contenedor de 40 pies estibado en la bahía par `B` **ocupa físicamente los
slots de las bahías impares `B‑1` y `B+1`**. Por eso las bahías pares e impares
no son independientes.

**Cambio:** al dibujar una bahía impar, marcar como *ocupado por 40 pies* todo
slot cuya fila y nivel estén tomados por un contenedor de 40/45 pies de las
bahías vecinas. Esos slots cuentan para la ocupación y **no** cuentan como
contenedores del viaje. Necesitan su propio color en la leyenda.

**Ojo con el caso raro:** en `CORPUS_A01` la bahía 41 tiene carga y ninguna
bahía par vecina cargada. Conviene que el algoritmo no dé por hecho que siempre
existe la vecina.

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

### C‑7 · Falta el peso por fila, que es donde el límite de apilamiento aplica

**Plano real:** muestra **las dos** magnitudes. Arriba, el peso de cada fila —
la pila vertical. A la derecha, el peso de cada nivel.

**BayStream:** solo muestra el peso por nivel.

**El problema de fondo:** la constante se llama `kStackWeightLimitKg`, que
significa *límite de la pila*, pero se compara contra la suma horizontal de las
doce filas de ese nivel (`bay_plan_view.dart:613`). Son magnitudes distintas.
Por eso en la bahía 22 salen tres de cinco niveles en rojo: doce contenedores de
18 toneladas ya suman 216, y el umbral es 90. **Una alerta que se dispara casi
siempre no informa nada.**

**Cambio:** añadir el peso acumulado **por fila** en la cabecera, como el plano
real, y aplicar ahí el límite de apilamiento. El peso por nivel se queda donde
está, como dato informativo, sin alerta o con un umbral propio y distinto.

---

## 3 · Lo que sigue abierto del Sprint 1

Dos defectos ya diagnosticados, con la prueba hecha, que no se corrigieron
antes de la revisión del 29 por decisión deliberada:

- **El indicador lleno/vacío se lee mal.** `_parseEQD` recorre los elementos
  desde el índice 4 y toma el primero que valga `'4'` o `'5'`; el índice 5 es
  otro código EDIFACT que en 158 segmentos vale `'4'`, así que nunca llega al
  índice 6, que es el campo real. El archivo declara 242 llenos y 735 vacíos;
  la aplicación muestra 84 y 893. La corrección es leer el elemento 6 por su
  posición. **Encaja con este trabajo:** el plano real muestra la `F` de Lleno
  en cada celda, y hoy esa letra saldría mal en 158 casos.
- **Los refrigerados no se detectan.** El corpus trae 43 segmentos `TMP` y 50
  contenedores con tipo ISO de refrigerado; la aplicación reporta 0.

---

## 4 · Orden recomendado

`C‑3` es la base: sin la geometría parametrizada, `C‑2` y `C‑4` se quedan en
parches sobre una rejilla inferida.

1. **C‑3** — parámetros del buque. Habilita todo lo demás.
2. **C‑4** — rangos de nivel reales. **Probar el ANR en Android aquí mismo.**
3. **C‑2** — fila 00 y orden fijo de columnas.
4. **EQD** — el indicador lleno/vacío. Pequeño, aislado y de alto impacto.
5. **C‑1** — TEU entero.
6. **C‑5a** — la carga que va de paso. Pequeño, y necesita el campo de puerto
   de escala en la pantalla de C‑3.
7. **C‑5b** — slots ocupados por 40 pies. Es el de más diseño.
8. **C‑7** — peso por fila y el límite donde corresponde.
9. **C‑6** — posición en el CSV, junto con la neutralización de fórmulas.

## 5 · Lo que no hay que hacer todavía

- No adelantar RF‑027 ni la validación a pie de muelle.
- No rediseñar la vista de estadísticas ni el perfil longitudinal.
- No tocar los archivos congelados de H5 ni `lib/main.dart`.
- No modelar las anotaciones a mano del planificador —secuencia de grúa,
  flechas, `26 MOVS`—. Es información valiosa y no está en el EDI; se discute
  como alcance nuevo, no se improvisa.


---

## 6 · Registro de correcciones a este documento

Se anotan porque el proyecto ya lleva cuatro casos en que un segundo revisor
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

**La cifra honesta baja de 30.2 % a 21.4 %, no sube.** Y seguirá baja hasta que
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

**Sobre la corrección 3 conviene ser explícito:** el error se cometió por
inferir el significado de una marca en vez de preguntar a quien trabaja en el
muelle. Es la misma clase de fallo que la auditoría de seguridad del 25 de
agosto documentó al inferir las reglas de Firestore en lugar de leerlas. Con
tres apariciones ya no es una anécdota, y la lección operativa es la misma:
**cuando el dato viene del mundo y no del código, se observa o se pregunta; no
se deduce.**
