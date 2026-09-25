# T-41 · Fuentes para la segregación de mercancías peligrosas

Fecha: 25 de septiembre de 2026, Guatemala. Requerimiento: RF-027. Autor: Timonel.
**Investigación, sin código.** La implementación es del bloque 7.

---

## 1. Respuesta corta

**El texto del Código IMDG no lo conseguí.** Es una publicación de pago de la
OMI y no encontré ninguna edición distribuida legítimamente. Sí aparecen en
internet copias del capítulo 7.2 alojadas por terceros: una en el aula virtual
de una universidad sueca («incorporating Amendment 40-20», según su propio
encabezado) y otra en el sitio de una universidad china («Amdt. 35-10»). No las
usé ni las descargué, por tres razones:

- no hay constancia de que la OMI autorice esa redistribución;
- son enmiendas superadas;
- no se pueden citar en una tesis sin exponer esa procedencia.

**Lo que sí conseguí es una norma primaria, oficial y gratuita que regula lo
mismo, pero no es el IMDG.** Es el título 49 del Código de Reglamentos Federales
de Estados Unidos (**49 CFR**, *Hazardous Materials Regulations*), en su texto
oficial del eCFR. Como obra del gobierno federal está en dominio público, así
que se puede reproducir y citar. Las secciones usadas:

| Sección | Qué aporta | Última enmienda |
|---|---|---|
| §176.83(b) | Tabla general de segregación entre clases | 30-mar-2017 |
| §176.83(f) | Traducción de cada código a distancias en portacontenedores | 30-mar-2017 |
| §176.83(a), (d), (m) | Riesgo secundario, precedencia de la sustancia, mismo contenedor, grupos de segregación | 30-mar-2017 |
| §176.144 | Segregación dentro de la clase 1, por grupo de compatibilidad | 15-ago-2016 |
| §176.84 | Significado de los códigos de la columna 10B | 28-dic-2023 |
| §172.101 | Entrada de cada número ONU: clase, etiquetas, columna 10B | 8-sep-2026 |
| §176.2 | Definiciones: unidad de transporte abierta y cerrada | — |

Las fechas de enmienda salen de la API de versiones del eCFR. Las 17 entradas
de §172.101 que usa el corpus se compararon contra la última versión publicada
(al 23-sep-2026): son idénticas.

**Se tiene que citar como lo que es:** *norma primaria de otra jurisdicción
—transporte marítimo de mercancías peligrosas en EE. UU.—, no el Código IMDG*.
No es fuente secundaria de internet, pero tampoco es la norma aplicable en
Santo Tomás de Castilla, que es el IMDG por el capítulo VII de SOLAS. **No
verifiqué celda por celda que coincida con la enmienda vigente del IMDG**,
porque no tuve el IMDG. §176.83 no cambia desde 2017.

**Veredicto sobre los 28 pares:** los 28 tienen respuesta en 49 CFR. Pero
**una matriz por clase no alcanza**, y el corpus lo demuestra en los dos
sentidos (sección 5). La decisión de si esta fuente basta es de Carlos y Yov
(sección 9).

---

## 2. Qué trae el corpus

**34 segmentos `DGS` en 30 contenedores**, sobre los seis archivos primarios.
El brief decía 57, pero ese número cuenta también `CORPUS_A03v_VGM`, que repite
exactamente los 23 `DGS` de `A03`: es la misma escala en su versión VGM. Las
**siete clases** del brief son correctas; los conteos por clase son estos:

| Clase | 3 | 9 | 8 | 1.4 | 2.1 | 5.1 | 4.1 |
|---|---:|---:|---:|---:|---:|---:|---:|
| Segmentos `DGS` | 14 | 6 | 6 | 4 | 2 | 1 | 1 |

**Los 17 números ONU**, con lo que dice su entrada en §172.101:

| ONU | Clase | Etiquetas (secundario) | Columna 10B | Descripción abreviada |
|---|---|---|---|---|
| 0012 | **1.4S** | — | 25 | Cartuchos para armas, proyectil inerte |
| 0303 | **1.4G** | 1.4G | 25, 14E, 15E, 17E | Munición fumígena |
| 1950 | 2.1 | 2.1 | 25, 87, **126**, 157 | Aerosoles inflamables (≤ 1 L) |
| 1170 | 3 | 3 | — | Etanol |
| 1263 | 3 | 3 | — | Pintura |
| 1266 | 3 | 3 | — | Perfumería con disolventes inflamables |
| 1993 | 3 | 3 | — | Líquido inflamable, n.e.p. |
| 3065 | 3 | 3 | — | Bebidas alcohólicas |
| 3175 | 4.1 | 4.1 | — | Sólidos con líquido inflamable, n.e.p. |
| 3085 | 5.1 | 5.1, **8** | 13, 56, 58, 138 | Sólido comburente, corrosivo, n.e.p. |
| 1719 | 8 | 8 | 29, **52** | Líquido alcalino cáustico, n.e.p. |
| 2735 | 8 | 8 | **52** | Aminas líquidas corrosivas, n.e.p. |
| 2794 | 8 | 8 | **53**, 58, 146 | Baterías húmedas con ácido |
| 3084 | 8 | 8, **5.1** | — | Sólido corrosivo, comburente, n.e.p. |
| 3265 | 8 | 8 | 40, **53**, 58 | Líquido corrosivo, ácido, orgánico, n.e.p. |
| 3077 | 9 | 9 | — | Sustancia peligrosa para el medio ambiente, sólida |
| 3082 | 9 | 9 | — | Sustancia peligrosa para el medio ambiente, líquida |

Códigos 10B que pesan en la segregación (§176.84): **52** «*separated from*
acids»; **53** «*separated from* alkaline compounds»; **87** «*separated from*
Class 1 except Division 1.4»; **126** «Segregation same as for Class 9»; 56, 58
y 138, separados de compuestos de amonio, cianuros y peróxidos, respectivamente.
**25** («*protected from sources of heat*») y 14E, 15E y 17E son de **estiba**,
no de segregación.

Tres rasgos del corpus que condicionan el diseño:

- **`A03` concentra 20 de los 30 contenedores**, y es el único archivo donde
  conviven varias clases. Es el que ejercita las reglas.
- **29 de los 30 van en cubierta.** 28 son de grupo `G` o `T` (`22G1`, `45G1`,
  `22T0`, `22T1`), que la app ya clasifica como dry y tanque
  (`ContainerUnit.containerType`). Los otros 2 son `22K2`, que la app clasifica
  como `other` y cuyo tipo no pude confirmar; ver sección 4.
- **El `DGS` de `A03` no trae el elemento de etiquetas** (C236), y el de
  clase 1 dice «1.4» sin letra de compatibilidad. **El riesgo secundario y el
  grupo de compatibilidad solo se obtienen consultando el número ONU.**

---

## 3. Los 28 pares

Códigos de la tabla §176.83(b), extraídos celda por celda del XML oficial; la
submatriz es simétrica. Se conservan los términos en inglés porque son los
**términos definidos** de la norma:

- **1** — «*Away from*»: a distancia.
- **2** — «*Separated from*»: separado de.
- **X** — «*The segregation, if any, is shown in the §172.101 table*»: no hay
  regla por clase; la da cada sustancia.
- **\*** — «*See §176.144 for segregation within Class 1*».

|     | 1.4 | 2.1 | 3 | 4.1 | 5.1 | 8 | 9 |
|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| **1.4** | \* | 2 | 2 | 2 | 2 | 2 | X |
| **2.1** | 2 | X | 2 | 1 | 2 | 1 | X |
| **3**   | 2 | 2 | X | X | 2 | X | X |
| **4.1** | 2 | 1 | X | X | 1 | 1 | X |
| **5.1** | 2 | 2 | 2 | 1 | X | 2 | X |
| **8**   | 2 | 1 | X | 1 | 2 | X | X |
| **9**   | X | X | X | X | X | X | X |

**Balance de los 28:**

| Grupo | Pares | Cuántos | ¿Se sostiene? |
|---|---|---:|---|
| Código 2 | 1.4/2.1, 1.4/3, 1.4/4.1, 1.4/5.1, 1.4/8, 2.1/3, 2.1/5.1, 3/5.1, 5.1/8 | 9 | **Sí**, como regla general, con §176.83(b) y (f) |
| Código 1 | 2.1/4.1, 2.1/8, 4.1/5.1, 4.1/8 | 4 | **Sí**, como regla general |
| \* | 1.4/1.4 | 1 | **Sí, pero por grupo de compatibilidad (§176.144), no por clase** |
| X | todos los de la clase 9, más 2.1/2.1, 3/3, 3/4.1, 3/8, 4.1/4.1, 5.1/5.1, 8/8 | 14 | **No hay regla por clase.** Solo se sostienen consultando cada número ONU |

**Ningún par del corpus cae en los códigos 3 o 4.** Esos son los que exigen
compartimentos completos y mamparos, que no se pueden evaluar sin datos del
buque (sección 4).

**La clase 1.4, que era la candidata a no poder sostenerse, se sostiene.**
Frente a las otras clases basta la fila «1.4, 1.6» de la tabla general. Entre
sí, §176.144 resuelve por grupo de compatibilidad, y la letra la da la entrada
ONU: UN0012 es 1.4**S** y UN0303 es 1.4**G**. En la tabla §176.144(a) la celda
G/S está vacía. La leyenda dice que una «X» prohíbe la estiba conjunta, así que
**S y G pueden ir juntos**, incluso en el mismo contenedor. Lo que no se puede
hacer es evaluar 1.4 contra 1.4 solo con la clase: hace falta la letra.

---

## 4. De código a posición: tabla §176.83(f), portacontenedores

Una **unidad cerrada** es aquella «*in which the contents are totally enclosed
by permanent structures*»; las que tienen lados o techo de lona no lo son
(§176.2). Según esa definición, los dry (`G`) y los tanques (`T`) del corpus
son **cerrados**. Esto es lectura directa de la definición: la norma no trae una
tabla de tipos ISO, y no tuve la ISO 6346 para contrastarla. Un `U` (techo
abierto, normalmente con lona) o un `P` (plataforma o *flat rack*) serían
abiertos. **Los dos `22K2` del corpus no se pueden clasificar sin la ISO 6346,
así que sus pares salen «no evaluado»** hasta que alguien confirme el tipo.

**Un espacio de contenedor** es «*a distance of not less than 6 m fore and aft
or not less than 2.5 m athwartship*» (§176.83(f)(4)). La norma lo define en
metros, no en huecos.

Para los códigos que aparecen en los 28 pares, **entre dos unidades cerradas**:

| Código | Vertical | Horizontal, en cubierta | Horizontal, bajo cubierta |
|---|---|---|---|
| 1 «*away from*» | Una encima de otra, permitido | Sin restricción | Sin restricción |
| 2 «*separated from*» | No en la misma línea vertical, salvo que las separe una cubierta | 1 espacio a proa/popa y 1 de costado | Proa/popa: 1 espacio **o un mamparo**. Costado: 1 espacio |

(Con unidades abiertas la tabla es más exigente. Entre dos abiertas, el
código 2 bajo cubierta pide **un mamparo**, sin alternativa en distancia.)

**Qué se puede evaluar con el BAPLIE y qué no:**

| Condición | Evaluable | Por qué |
|---|---|---|
| Cubierta o bodega | Sí | El nivel ≥ 80 es cubierta (`VesselGeometry.isDeckTier`) |
| Misma línea vertical | Sí | Misma bahía física y misma fila (un 40 pies ocupa dos bahías de 20, lógica de C‑5b) |
| «1 espacio de contenedor» | **Con una aproximación** | La norma da metros. Usar «un hueco completo entre ambos» es una derivación, no texto de la norma, y se tiene que rotular así |
| «o un mamparo» | **No** | Ni el BAPLIE ni `VesselGeometry` saben dónde están los mamparos. Si se cumple la distancia, se cumple; si no, queda «no evaluado» |
| «salvo que las separe una cubierta» entre cubierta y bodega | **No** | La norma exige cubiertas resistentes al fuego y a los líquidos (nota de la tabla §176.83(f)), y el BAPLIE no dice si la tapa de escotilla lo es. Queda «no evaluado» |
| Dos mercancías en el **mismo contenedor** (§176.83(d)) | Sí | Si entre ellas se exige cualquier segregación, está prohibido. En el corpus los cuatro contenedores con más de un `DGS` son compatibles: 3 con 3 y 8 con 8 |

---

## 5. Por qué una matriz por clase no alcanza: casos reales de `A03`

La propia norma lo dice: las propiedades dentro de una clase «*may vary greatly
and may require greater segregation than is reflected in this table*», y «*if
the §172.101 Table sets forth particular requirements for segregation, they
take precedence*» (§176.83(b)). En `A03` eso se ve en los dos sentidos.

**1 · Falso «conforme»: el riesgo secundario.** UN3084 es clase 8 **con
secundario 5.1**. §176.83(a)(6) obliga a aplicar la segregación del secundario
cuando es más restrictiva. Frente a clase 3, por la clase principal sería X y
por el secundario es **2**. En `A03`, UN3084 (`0140784`) comparte bahía y
nivel con cuatro contenedores clase 3 (`0140084`, `0140284`, `0140384`,
`0140484`). **Una matriz por clase ni siquiera revisaría ese par.** Y el `DGS`
de `A03` no declara la etiqueta secundaria: solo se sabe por la entrada ONU.

**2 · Falsa alarma: la disposición de la sustancia manda.** UN1950 (aerosoles,
2.1) lleva el código **126**, «*segregation same as for Class 9*». En `A03`
está en `0260186`, **justo encima** de UN3085 (5.1) en `0260184`. Por clase,
2.1/5.1 = 2 prohíbe la misma línea vertical: incumplimiento. Por la sustancia
se segrega como clase 9 frente a 5.1, que es X: **no hay incumplimiento**. Lo
mismo con los tres UN0303 (1.4) de la bahía 027: por clase 2.1/1.4 = 2, pero el
código 87 excluye justamente la división 1.4.

**3 · Lo que la norma deja fuera del alcance de un tercero.** La clase 8 del
corpus mezcla sustancias con código 52 («separado de ácidos»: UN1719, UN2735) y
con código 53 («separado de compuestos alcalinos»: UN2794, UN3265). Hay dos
problemas:

- **Quién es «ácido» o «alcalino» no lo define 49 CFR.** §176.83(m)(1) remite a
  la **sección 3.1.4 del Código IMDG, incorporada por referencia**. Es decir,
  la propia norma estadounidense depende del texto que no conseguí.
- **Para las entradas n.e.p., decide el embarcador.** §176.83(m)(2) dice que
  quien ofrece la carga «*must decide whether allocation under a segregation
  group is appropriate*», y el BAPLIE no transmite esa decisión.

Lo más que puede decir la aplicación es «posible incompatibilidad ácido/álcali:
confirmar con el embarcador». En el corpus, de todas formas, esos contenedores
están a **8 bahías o más** entre sí.

**Consecuencia de diseño:**

- La evaluación es **por número ONU**, con una tabla de entradas evaluadas.
  Cada entrada cita su fila de §172.101 y los códigos de §176.84.
- La tabla general §176.83(b) es la regla **por defecto** dentro de esa
  evaluación, no un sustituto de ella.
- Para los 17 números ONU del corpus, todo lo necesario está en 49 CFR, salvo
  la pertenencia a los grupos de segregación.

---

## 6. Qué dice y qué no dice la fuente

**Dice** (texto oficial, verificable en las URL del final):

- La tabla general entre todas las clases, con sus cuatro términos definidos.
- Cómo se traduce cada término a distancias en un portacontenedores, y qué es
  un espacio de contenedor.
- Que la segregación del riesgo secundario se aplica cuando es más restrictiva.
- Que la disposición de la sustancia prevalece sobre la tabla general.
- La compatibilidad dentro de la clase 1, por grupo.
- La clase, las etiquetas y las disposiciones de estiba en buque de cada número
  ONU.
- Que dos mercancías que requieren segregación no pueden ir en la misma unidad.

**No dice:**

- **El Código IMDG.** Es otra norma, de otra jurisdicción, sin
  correspondencia verificada celda por celda.
- **Qué sustancias pertenecen a cada grupo de segregación.** Remite al IMDG
  3.1.4, y para las entradas n.e.p. decide el embarcador.
- **Nada sobre el buque concreto:** dónde están los mamparos, si las tapas de
  escotilla son resistentes al fuego y a los líquidos, el paso real entre
  huecos en metros.
- **La estiba**, que es otro requisito, distinto de la segregación: las
  categorías de la columna 10A y el «*protected from sources of heat*», que pide
  2,4 m de estructuras calientes que el BAPLIE no ubica. RF-027, tal como está,
  habla de segregación.

---

## 7. Advertencia de muestreo

El corpus son **seis archivos anonimizados**, y la variedad está concentrada en
uno solo (`A03`). **Las siete clases y los 17 números ONU que aparecen acotan lo
que podemos verificar, no lo que la aplicación va a encontrar en un muelle
real.** Consecuencias que el diseño tiene que respetar:

- **Una clase o un número ONU fuera de la tabla evaluada sale como «no
  evaluado», nunca como «conforme» por omisión.** Un falso «conforme» en
  mercancías peligrosas es peor que no decir nada.
- **Lo mismo vale para una clase que sí está en la matriz pero cuyo número ONU
  no está en la tabla.** El caso 1 de la sección 5 muestra que la regla por
  clase puede dar «conforme» donde la sustancia exige segregación.
- **Un incumplimiento según la regla por clase se reporta como «posible
  incumplimiento según la regla general»**, no como incumplimiento. El caso 2
  muestra que la sustancia puede relajarlo.
- Lo que depende de datos del buque (mamparos, tapas de escotilla) sale como
  «no evaluado», con el motivo.

Son **tres estados**, y ninguno de los dos extremos se da por omisión:
**conforme**, **posible incumplimiento** y **no evaluado**.

---

## 8. Postura

**BayStream ofrece apoyo a la decisión del planificador, no verificación
certificada de cumplimiento del Código IMDG.** Señala pares que la regla general
de una norma primaria —49 CFR, citada como tal— marca como problemáticos o que
no pudo evaluar. No sustituye la revisión del plano de mercancías peligrosas
por la persona responsable ni la declaración del embarcador. Es la misma
postura que tuvo `kStackWeightLimitKg` mientras existió. **La tesis no puede
afirmar que BayStream valida cumplimiento normativo**, y el código tiene que
rotular así cada resultado.

---

## 9. Decisión pendiente (Carlos y Yov)

1. **Aceptar 49 CFR como fuente citada**, con la limitación de la sección 1
   escrita en el código y en el documento. **Es mi recomendación:** es
   primaria, oficial, gratuita y reproducible, y cubre los 28 pares y los 17
   números ONU del corpus.
2. **Comprar el Código IMDG** para contrastar las tablas 7.2.4 y 7.4.3 y la
   sección 3.1.4 antes de la defensa. Resolvería la pertenencia a grupos de
   segregación y la jurisdicción. Tiene costo y demora de entrega.
3. **Sacar la segregación de RF-027.** Es lo que queda si ni 1 ni 2 son
   aceptables.

Si se elige 1, **el alcance implementable para el bloque 7** es:

- tabla de los 17 números ONU con su cita;
- §176.83(b) como regla por defecto;
- §176.83(f) para los códigos 1 y 2 con unidades cerradas;
- §176.83(d) para el mismo contenedor;
- §176.144 para 1.4 contra 1.4.

Todo lo demás, «no evaluado».

---

## Fuentes

Texto oficial del eCFR, versión al 1 de septiembre de 2026 (§172.101
contrastada además con la versión al 23 de septiembre), consultado el 25 de
septiembre de 2026:

- 49 CFR §176.83 — <https://www.ecfr.gov/api/versioner/v1/full/2026-09-01/title-49.xml?part=176&section=176.83>
- 49 CFR §176.144 — <https://www.ecfr.gov/api/versioner/v1/full/2026-09-01/title-49.xml?part=176&section=176.144>
- 49 CFR §176.84 — <https://www.ecfr.gov/api/versioner/v1/full/2026-09-01/title-49.xml?part=176&section=176.84>
- 49 CFR §176.2 — <https://www.ecfr.gov/api/versioner/v1/full/2026-09-01/title-49.xml?part=176&section=176.2>
- 49 CFR §172.101 — <https://www.ecfr.gov/api/versioner/v1/full/2026-09-23/title-49.xml?part=172&section=172.101>
- Fechas de enmienda — <https://www.ecfr.gov/api/versioner/v1/versions/title-49.json>

Lectura cómoda de las mismas secciones: <https://www.ecfr.gov/current/title-49/section-176.83>.

Código IMDG: publicación de pago de la OMI, no consultado. Se encontraron copias
de terceros del capítulo 7.2 (enmiendas 35-10 y 40-20, según sus encabezados)
que no se usaron por las razones de la sección 1.
