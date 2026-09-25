# T-41 · Segregación de mercancías peligrosas: fuente y alcance

Fecha: 25 de septiembre de 2026, Guatemala. Requerimiento: RF-027.
Autor: Timonel. Decisión registrada en `SPRINT-2.md` §10.12.
**Documento sin código.** La implementación es del bloque 7, y la hace quien
tenga el árbol entonces.

> **Lo que va escrito sin ambigüedad, en este documento y en el código:**
>
> 1. Las reglas implementadas son **49 CFR Parte 176**, la normativa federal
>    de EE. UU. para transporte marítimo de mercancías peligrosas, en su texto
>    oficial del eCFR.
> 2. **No son el Código IMDG, y no se afirma equivalencia** con él.
> 3. **Para la operación real gobierna el Código IMDG**, aplicable por el
>    capítulo VII de SOLAS.
> 4. La alerta de BayStream es **apoyo a la decisión, no verificación de
>    cumplimiento**.

---

## 1. La fuente y por qué es esta

El Código IMDG es una publicación de pago de la OMI y no se consiguió ninguna
edición distribuida legítimamente. En internet hay copias del capítulo 7.2
alojadas por terceros (enmiendas 35-10 y 40-20, según sus encabezados). **No se
usaron ni se descargaron**, por su procedencia, porque son enmiendas superadas
y porque no se pueden citar.

49 CFR es una norma primaria y oficial, de dominio público (obra del gobierno
federal), con dirección estable. **Un examinador la puede abrir y verificar.**
Una copia del IMDG de procedencia incierta no se puede verificar, y eso la
hace peor evidencia aunque sea la norma que gobierna.

| Sección de 49 CFR | Qué aporta | Última enmienda |
|---|---|---|
| §176.83(b) | Tabla general de segregación entre clases | 30-mar-2017 |
| §176.83(f) | Cada código traducido a distancias en portacontenedores | 30-mar-2017 |
| §176.83(a), (d), (m) | Riesgo secundario, precedencia de la sustancia, mismo contenedor, grupos de segregación | 30-mar-2017 |
| §176.144 | Segregación dentro de la clase 1, por grupo de compatibilidad | 15-ago-2016 |
| §176.84 | Significado de los códigos de la columna 10B | 28-dic-2023 |
| §172.101 | Cada número ONU: clase, etiquetas, columna 10B | 8-sep-2026 |
| §176.2 | Definiciones: unidad de transporte abierta y cerrada | — |

Las fechas de enmienda salen de la API de versiones del eCFR. Las entradas de
§172.101 que usa el corpus se compararon contra la última versión publicada,
al 23-sep-2026, y son idénticas.

---

## 2. El hallazgo estructural: dos huecos del BAPLIE en el perfil de peligro de la carga

**La evaluación por clase falla en `CORPUS_A03` en los dos sentidos**, con
instancias reales verificadas en el archivo crudo:

| Segmento en `A03` | Lo que declara | Lo que dice la entrada ONU | Resultado si se evalúa por clase |
|---|---|---|---|
| `DGS+IMD+8+3084++I` (`0140784`) | clase 8 | clase 8 **con riesgo secundario 5.1** (§172.101). §176.83(a)(6) obliga a aplicar la segregación del secundario cuando es más restrictiva | Junto a los cuatro clase 3 de su bahía y nivel, por clase es X; por el secundario, 3/5.1 = 2. **Falso «conforme».** |
| `DGS+IMD+2.1+1950` (`0260186`) | clase 2.1 | código 10B **126**: «*segregation same as for Class 9*». La sustancia prevalece sobre la tabla general (§176.83(b)) | Justo encima de UN3085 (5.1): por clase, 2.1/5.1 = 2 prohíbe la misma vertical; por la sustancia, 9/5.1 = X. **Falsa alarma.** |

Decir que «el BAPLIE no trae la información» es impreciso, y un examinador
puede empujar justo ahí. **Son dos huecos distintos**, y la evaluación por
número ONU responde a los dos a la vez.

**Hueco 1 · El campo existe y viene vacío.** Es un problema de **calidad del
dato**. El segmento `DGS` tiene un elemento para las etiquetas (C236), incluida
la secundaria. En el corpus lo rellenan tres archivos en todos sus segmentos
(`A02`, `A04` y `A06`, con valores como `3:0:0` y `2.1:0:0`) y otros tres no lo
rellenan en ninguno (`A01`, `A03` y `A05`). **En `A03` viene vacío en los 23
segmentos**, y por eso el 5.1 de UN3084 no viaja. Con otro emisor se podría
leer, y la implementación debe leerlo cuando venga, pero no puede depender de
que venga.

La letra de compatibilidad de la clase 1 cae del mismo lado, aunque esto es
inferencia y no está verificado contra la especificación del segmento. La
letra forma parte de la notación de la división («1.4S») y el campo de clase es
texto, pero el corpus trae solo «1.4».

**Hueco 2 · No hay campo, y punto.** Es un **límite duro del formato**. Las
disposiciones propias de cada sustancia —la columna 10B: «segregación como
clase 9», «separado de ácidos»— **no tienen dónde ir** en un BAPLIE. Ninguna
implementación lo resuelve leyendo mejor. Solo se obtienen consultando el
número ONU contra la norma.

**RF-036 es un hueco del segundo tipo.** El BAPLIE no tiene campo para la
geometría del buque, ni para sus anclas de nivel, ni para su límite de
apilamiento. Por eso se declaran aparte y se recuerdan por buque. La
evaluación por número ONU cubre los dos tipos: el primero porque no depende de
que el emisor rellene un campo opcional, y el segundo porque es la única fuente
posible.

Son **dos instancias independientes de la misma limitación del formato**,
encontradas por rutas distintas y por agentes distintos. La primera salió de
comparar el plano de BayStream contra el plano impreso del MIZAR. La segunda,
de buscar la fuente normativa de la segregación. Las dos llevan al mismo
diseño: **el archivo describe la carga y su posición; lo que hace falta para
juzgarla viene de fuera, declarado y citado.** Ese es el argumento central de
la tesis, sostenido por dos lados.

---

## 3. Los 28 pares

El corpus trae siete clases: 1.4, 2.1, 3, 4.1, 5.1, 8 y 9. Con ellas hay 28
pares, contando los de cada clase consigo misma. Los códigos se extrajeron
celda por celda del XML oficial de la tabla §176.83(b), y la submatriz es
simétrica. Los términos van en inglés porque son los **términos definidos** de
la norma:

- **1** — «*Away from*».
- **2** — «*Separated from*».
- **X** — «*The segregation, if any, is shown in the §172.101 table*»: no hay
  regla por clase.
- **\*** — «*See §176.144 for segregation within Class 1*».

**Qué exige cada código entre dos unidades cerradas**, según la tabla
§176.83(f), portacontenedores:

- **1**: sin restricción, ni vertical ni horizontal.
- **2**: no en la misma línea vertical, salvo que las separe una cubierta
  resistente al fuego y a los líquidos. En cubierta, un espacio de contenedor a
  proa/popa y uno de costado. Bajo cubierta, a proa/popa un espacio o un
  mamparo; de costado, un espacio.

Un espacio de contenedor son al menos 6 m a proa/popa y 2,5 m de costado
(§176.83(f)(4)).

| # | Par | Código | Cita | En el corpus |
|---:|---|:-:|---|---|
| 1 | 1.4 / 1.4 | \* | §176.144(a); en cubierta, §176.144(e) | UN0012 es 1.4**S** y UN0303 es 1.4**G**: la celda G/S vacía los autoriza juntos. La letra sale del número ONU, no del `DGS` |
| 2 | 1.4 / 2.1 | 2 | §176.83(b) | UN1950 lleva el 87 («*separated from Class 1 except Division 1.4*») y el 126 (como clase 9): **por número ONU, nada que cumplir** frente a UN0303 en la bahía 027 |
| 3 | 1.4 / 3 | 2 | §176.83(b) | — |
| 4 | 1.4 / 4.1 | 2 | §176.83(b) | — |
| 5 | 1.4 / 5.1 | 2 | §176.83(b) | — |
| 6 | 1.4 / 8 | 2 | §176.83(b) | — |
| 7 | 1.4 / 9 | X | §176.83(b) → §172.101 | UN0012 y UN3082 no llevan disposiciones de segregación |
| 8 | 2.1 / 2.1 | X | §176.83(b) → §172.101 | — |
| 9 | 2.1 / 3 | 2 | §176.83(b) | Todo 2.1 del corpus es UN1950, que se segrega como clase 9: por número ONU es X |
| 10 | 2.1 / 4.1 | 1 | §176.83(b) | Ídem: UN1950 como clase 9 |
| 11 | 2.1 / 5.1 | 2 | §176.83(b) | **Falsa alarma de `A03`**: UN1950 sobre UN3085 (sección 2) |
| 12 | 2.1 / 8 | 1 | §176.83(b) | Ídem: UN1950 como clase 9 |
| 13 | 2.1 / 9 | X | §176.83(b) → §172.101 | — |
| 14 | 3 / 3 | X | §176.83(b) → §172.101 | Los clase 3 del corpus no llevan disposiciones de segregación; en el mismo contenedor son compatibles (§176.83(d)) |
| 15 | 3 / 4.1 | X | §176.83(b) → §172.101 | — |
| 16 | 3 / 5.1 | 2 | §176.83(b) | También se aplica a UN3084, por su secundario 5.1 |
| 17 | 3 / 8 | X | §176.83(b) → §172.101 | **Falso «conforme» de `A03`**: UN3084 se segrega también como 5.1, así que 3/5.1 = 2 (sección 2) |
| 18 | 3 / 9 | X | §176.83(b) → §172.101 | — |
| 19 | 4.1 / 4.1 | X | §176.83(b) → §172.101 | — |
| 20 | 4.1 / 5.1 | 1 | §176.83(b) | — |
| 21 | 4.1 / 8 | 1 | §176.83(b) | — |
| 22 | 4.1 / 9 | X | §176.83(b) → §172.101 | — |
| 23 | 5.1 / 5.1 | X | §176.83(b) → §172.101 | — |
| 24 | 5.1 / 8 | 2 | §176.83(b) | UN3085 (5.1 con secundario 8) y UN3084 (8 con secundario 5.1): aplican §176.83(a)(6) y (a)(8) |
| 25 | 5.1 / 9 | X | §176.83(b) → §172.101 | — |
| 26 | 8 / 8 | X | §176.83(b) → §172.101 | **Ácidos contra álcalis: no evaluado** (sección 5) |
| 27 | 8 / 9 | X | §176.83(b) → §172.101 | — |
| 28 | 9 / 9 | X | §176.83(b) → §172.101 | — |

**Balance:** 9 pares de código 2, 4 de código 1, 1 de «\*» y **14 de «X»**, que
solo se resuelven por número ONU. **Ningún par cae en los códigos 3 o 4**, que
exigirían compartimentos completos y mamparos.

**La clase 1.4 se sostiene, pero solo por número ONU.** Frente a las otras
clases basta la fila «1.4, 1.6» de la tabla general. Entre sí, la resuelve
§176.144 por grupo de compatibilidad, y el `DGS` del corpus dice «1.4» sin la
letra.

---

## 4. Los 17 números ONU del corpus

Cada fila es la entrada de §172.101 (columnas 3, 6 y 10B), con los códigos
interpretados por §176.84.

| ONU | Clase | Etiquetas | 10B | Qué pesa en la segregación |
|---|---|---|---|---|
| 0012 | 1.4S | — | 25 | Grupo de compatibilidad S |
| 0303 | 1.4G | 1.4G | 25, 14E, 15E, 17E | Grupo de compatibilidad G |
| 1950 | 2.1 | 2.1 | 25, 87, 126, 157 | **126**: segregación como clase 9. **87**: separada de clase 1, salvo 1.4 |
| 1170 | 3 | 3 | — | Tabla general |
| 1263 | 3 | 3 | — | Tabla general |
| 1266 | 3 | 3 | — | Tabla general |
| 1993 | 3 | 3 | — | Tabla general |
| 3065 | 3 | 3 | — | Tabla general |
| 3175 | 4.1 | 4.1 | — | Tabla general |
| 3085 | 5.1 | 5.1, **8** | 13, 56, 58, 138 | Secundario 8 (§176.83(a)(6)); 56, 58 y 138: separada de compuestos de amonio, cianuros y peróxidos, grupos que define el IMDG 3.1.4 |
| 1719 | 8 | 8 | 29, **52** | **52**: separada de ácidos |
| 2735 | 8 | 8 | **52** | **52**: separada de ácidos |
| 2794 | 8 | 8 | **53**, 58, 146 | **53**: separada de compuestos alcalinos |
| 3084 | 8 | 8, **5.1** | — | Secundario 5.1 (§176.83(a)(6)) |
| 3265 | 8 | 8 | 40, **53**, 58 | **53**: separada de compuestos alcalinos |
| 3077 | 9 | 9 | — | Tabla general |
| 3082 | 9 | 9 | — | Tabla general |

Los códigos 25 («*protected from sources of heat*»), 14E, 15E, 17E, 40, 146 y
157 son de **estiba**, no de segregación. Quedan fuera de T-41.

---

## 5. Ácidos contra álcalis: no evaluado

En la clase 8 del corpus hay sustancias con el código 52 (UN1719, UN2735) y
con el 53 (UN2794, UN3265). **BayStream no decide ese par, y sale como «no
evaluado»** por dos razones escritas en la propia norma:

- **Quién pertenece al grupo «ácidos» o «álcalis» no lo define 49 CFR.**
  §176.83(m)(1) remite a la **sección 3.1.4 del Código IMDG, incorporada por
  referencia**, que es precisamente el texto que no se tiene.
- **En las entradas n.e.p. decide el embarcador.** §176.83(m)(2) dice que quien
  ofrece la carga «*must decide whether allocation under a segregation group is
  appropriate*», y el BAPLIE no transmite esa decisión.

UN1719, UN2735 y UN3265 son entradas n.e.p. Lo más que la aplicación puede
decir es: «posible incompatibilidad ácido/álcali: confirmar con el
embarcador». En el corpus esos contenedores están a 8 bahías o más entre sí.
Lo mismo vale para los grupos de los códigos 56, 58 y 138.

---

## 6. Qué cubre y qué no cubre 49 CFR

**Cubre**, con texto oficial:

- La tabla general entre todas las clases y sus cuatro términos definidos.
- Su traducción a distancias en portacontenedores y la definición de espacio
  de contenedor.
- La regla del riesgo secundario y la precedencia de la sustancia sobre la
  tabla general.
- La compatibilidad dentro de la clase 1.
- La clase, las etiquetas y las disposiciones de cada número ONU.
- La prohibición de llevar en la misma unidad dos mercancías que requieran
  segregación (§176.83(d)).
- Qué es una unidad abierta o cerrada (§176.2).

**No cubre:**

| Lo que falta | Por qué | En la implementación |
|---|---|---|
| Equivalencia con el IMDG | Es otra norma, de otra jurisdicción, sin contraste celda por celda | Se declara, no se afirma |
| Pertenencia a los grupos de segregación | Remite al IMDG 3.1.4; en las n.e.p. decide el embarcador | «No evaluado» |
| Dónde están los mamparos del buque | Dato del buque; no está en el BAPLIE ni en `VesselGeometry` | La alternativa «o un mamparo» no se evalúa: si no se cumple la distancia, «no evaluado» |
| Si la tapa de escotilla es cubierta resistente al fuego y a los líquidos | Dato del buque | La misma vertical entre cubierta y bodega, «no evaluado» |
| El paso real entre huecos, en metros | La norma habla de 6 m y 2,5 m; el BAPLIE, de huecos | «Un hueco completo entre ambos» es una **derivación, no texto de la norma**, y se rotula así |
| El tipo de dos contenedores `22K2` | La app los clasifica como `other`, y sin la ISO 6346 no se sabe si son abiertos o cerrados | «No evaluado» |
| La estiba (columna 10A, fuentes de calor) | Es otro requisito, no segregación | Fuera de T-41 |

---

## 7. Diseño de tres estados

| Estado | Cuándo | Qué no puede pasar |
|---|---|---|
| **Conforme** | Los dos números ONU están en la tabla evaluada, las dos unidades son cerradas confirmadas, y la distancia cumple el código de §176.83(f) aplicado tras el riesgo secundario (§176.83(a)(6)) y las disposiciones de la sustancia (§172.101) | **Nunca por omisión.** Sin evaluación completa no hay «conforme» |
| **Posible incumplimiento** | La regla evaluada no se cumple. Si alguno de los dos números ONU no está en la tabla, se rotula «según la regla general por clase»; el caso de UN1950 muestra que la sustancia puede relajarla | Nunca «incumplimiento» a secas: es apoyo a la decisión |
| **No evaluado** | Clase o número ONU fuera de la tabla; grupos de segregación; alternativa de mamparo; cubierta entre bodega y cubierta; tipo de unidad no confirmado | Siempre con el motivo escrito |

La tabla evaluada arranca con los **17 números ONU del corpus**. Cada entrada
cita su fila de §172.101 y los códigos de §176.84 que aplican. Crece número por
número, cada uno con su cita. **Lo que no está en la tabla no se infiere.**

---

## 8. Advertencia de muestreo

El corpus son **seis archivos anonimizados, y la variedad está en uno solo**
(`A03`: 20 de los 30 contenedores con mercancías peligrosas). **Las siete
clases y los 17 números ONU que aparecen acotan lo que podemos verificar, no lo
que la aplicación va a encontrar en un muelle real.**

Por eso, una clase o un número ONU fuera de la tabla evaluada sale **«no
evaluado», nunca «conforme» por omisión.** Lo mismo vale para una clase que sí
está en la matriz cuando su número ONU no está en la tabla: el caso de UN3084
muestra que la regla por clase puede dar «conforme» donde la sustancia exige
segregación. **Un falso «conforme» en mercancías peligrosas es peor que no
decir nada.**

**Conteo verificado:** 34 segmentos `DGS` en 30 contenedores, sobre los seis
archivos primarios. `CORPUS_A03v_VGM` repite byte a byte los 23 de `A03` y no
se cuenta. Por clase: 3 (14) · 9 (6) · 8 (6) · 1.4 (4) · 2.1 (2) · 5.1 (1) ·
4.1 (1).

---

## 9. Postura

**BayStream ofrece apoyo a la decisión del planificador, no verificación de
cumplimiento.** Señala pares que la regla de 49 CFR Parte 176 marca como
problemáticos, y los que no pudo evaluar. **No valida cumplimiento del Código
IMDG**, que es el que gobierna la operación real, ni sustituye la revisión del
plan de mercancías peligrosas por la persona responsable ni la declaración del
embarcador.

Es la misma postura que tuvo `kStackWeightLimitKg` mientras existió. **La tesis
no puede afirmar que BayStream valida cumplimiento normativo.** El código tiene
que rotular así cada resultado, y citar la sección de 49 CFR de la que sale.

---

## Fuentes

Texto oficial del eCFR, consultado el 25 de septiembre de 2026 (versión al
1-sep-2026; §172.101 contrastada con la versión al 23-sep-2026):

- 49 CFR §176.83 — <https://www.ecfr.gov/current/title-49/section-176.83>
- 49 CFR §176.144 — <https://www.ecfr.gov/current/title-49/section-176.144>
- 49 CFR §176.84 — <https://www.ecfr.gov/current/title-49/section-176.84>
- 49 CFR §176.2 — <https://www.ecfr.gov/current/title-49/section-176.2>
- 49 CFR §172.101 — <https://www.ecfr.gov/current/title-49/section-172.101>
- Texto XML y fechas de enmienda: API del eCFR,
  <https://www.ecfr.gov/api/versioner/v1/>

El Código IMDG no se consultó (publicación de pago de la OMI).
