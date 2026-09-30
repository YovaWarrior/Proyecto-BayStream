# T-59 · Cómo se documentan las tomas de reefer y qué bahía lleva una toma

Timonel · 30-sep-2026 · Base: `1607263` y lo que haya en el árbol · En paralelo con T-57 (Codex).

**No se tocó `lib/` ni `test/`.** Un script nuevo, `tool/t59_bahias_tomas.dart`, con su
salida en `build/t59/bahias_tomas.json` (ignorada por Git). `dart analyze` sobre el script:
sin incidencias. No se corrió `flutter analyze` del proyecto ni la suite, por la regla de
paralelo.

## Resumen

1. **La pregunta no tiene respuesta pública.** No encontré ninguna fuente pública que diga si
   una toma pertenece a un hueco de 20, a uno de 40 o a un extremo, ni de qué extremo toma
   corriente un reefer de 40 en un buque dado. SMDG dice por escrito que **no hay estándar de
   perfil de buque**, y sus propios códigos admiten el motor del reefer **hacia proa o hacia
   popa**. La respuesta es propia de cada buque.
2. **Corpus.** En los cinco buques, cada bahía par cubre sus dos impares vecinas, sin un solo
   choque. Pero **qué pares existen es del buque**: ALFA y DELTA tienen una **041 sola**, sin
   par, y la **044** cubre 043 y 045. Los únicos reefers de 20 del corpus son 9 de ALFA, **los 9
   en el extremo de proa** del par 022, con un 20 seco en la mitad de popa de la misma celda.
   Es un indicio en un solo par de un solo buque, no una regla.
3. **Propuesta para T-56.** Guardar cada toma como **celda + extremo**, con el extremo
   pudiendo ser «proa», «popa», «ambos» o «sin especificar», y la **tabla de pares del buque en
   el perfil**. El validador busca por celda física. El código de siete dígitos de hoy se
   traduce a ese modelo sin perder nada, y un extremo desconocido da aviso, nunca error.

---

## 1. Fuentes públicas

| # | Afirmación | Fuente |
|---|---|---|
| F1 | *«There is no standard for vessel profiles, profile depends on software of owner»*; los formatos (MACS3, nsd de Kaleris N4) *«cannot easily be converted»*; los terminales reciben el perfil *«mostly via PDF in a mail»* | SMDG, [Panel Discussion on «Vessel Profiles», SMDG #79](https://smdg.org/wp-content/uploads/Plenary_Meetings/79th_meeting/Minutes/Panel-Discussion-Vessel-Profiles-SMDG79.pdf), abril de 2025 |
| F2 | Códigos de manejo **RFA** *«Reefer engine facing aft»*, **RFF** *«Reefer engine facing forward»* y **RPP** *«Requires a power plug»* | SMDG, [Code list HANDLING 2020A](https://smdg.org/wp-content/uploads/2020/Documents/SMDG-CodeList/SMGD-Codes-2020A-Code-list-HANDLING.pdf) |
| F3 | Una celda *«normally either can hold one 40' container or two 20' containers»*; *«Some cells have power plugs for refrigerated containers»*; *«Since reefer plugs typically are at bottom of stacks, a 40' reefer kills 20' capacity»* | van Twiller, Sivertsen, Pacino y Jensen, [Literature Survey on the Container Stowage Planning Problem](https://arxiv.org/html/2307.07573v1), arXiv 2307.07573 |
| F4 | *«The unit mounts in the front wall of the container»*; cable de *«18.3 m (60 ft.)»* | Thermo King, [Marine Reefer Units with MP-5000, manual de operación](https://elibrary.tranetechnologies.com/etech-emea-public//thermoking-emea/Minneapolis%20-%20Container%20-%20Generator%20Sets/Literature/Operation%20or%20Owners/0006155480.xml/$/0006156174) |

**Qué se sigue de ellas:**

- **Fuente:** la toma es un atributo de la **celda** (F3), y la industria no tiene un
  formato común para declararla (F1).
- **Fuente:** un reefer se puede estibar con el motor en cualquiera de los dos sentidos
  (F2). Que exista un código para cada sentido implica que el sentido es una instrucción del
  embarque, no una constante.
- **Inferencia, sin fuente:** si el motor de un 40 puede ir a proa o a popa (F2 y F4), un
  reefer de 40 no tiene un extremo fijo del que toma corriente: se orienta hacia la toma.
  **Ninguna fuente dice de qué extremo toma corriente un reefer de 40 en un buque concreto.**
- **Inferencia, sin fuente:** con 18,3 m de cable (F4), un 40 podría llegar a una toma del
  otro extremo de su celda. Un cable largo no prueba que la práctica lo permita, y eso no
  lo encontré escrito.
- **Sin respuesta pública:** si una celda con toma tiene corriente en un extremo o en los
  dos, y por tanto si admite uno o dos reefers de 20. Eso lo dicen el plano de tomas del
  buque o su programa de estabilidad (OSP), que según F1 los armadores no siempre comparten.

**Buscado sin resultado:** la enciclopedia de Wärtsilä (reefers y estiba en bodegas), el
índice del Container Handbook (cap. 7) y guías de divulgación: ninguna trata la posición de
la toma dentro de la celda. Una página que el buscador asoció a «puertas a proa, maquinaria a
popa» (maritimepage.com) **no lo dice** al leerla, así que no se usa.

## 2. Corpus

**Reproducción:** `dart run tool/t59_bahias_tomas.dart "<directorio del corpus>"`.
Las bahías se numeran de proa a popa, así que la impar menor de un par es el extremo de proa.
Una **correspondencia se contradice** si un 40 en la par y un 20 en la impar comparten fila y
nivel: esa impar no sería parte del par.

### Tabla de correspondencia por buque

| Buque | Archivo | Pares con carga de 40 | Impares que cubre cada par | Choques | Particularidad |
|---|---|---|---|---:|---|
| ALFA | A01 | 002 006 010 014 018 022 026 030 034 038 **044** | par − 1 y par + 1 | 0 | **041 sola** (1 contenedor de 20, sin 040 ni 042); **044 → 043 y 045** (25 de 40) |
| BRAVO | A02 | 002 010 014 018 022 026 030 034 038 042 | par − 1 y par + 1 | 0 | La 006 no trae carga de 40 en este viaje |
| CHARLIE | A03 | 002 006 … 034 | par − 1 y par + 1 | 0 | — |
| DELTA | A04 | 002 006 010 014 018 022 026 030 034 038 **044** | par − 1 y par + 1 | 0 | **041 sola** (29 contenedores de 20, cubierta 82–86); **044 → 043 y 045** (50 de 40) |
| ECO | A05, A06 | 002 006 … 034 | par − 1 y par + 1 | 0 | — |

Las **50 posiciones de DELTA fuera del patrón** que señaló T-55 son exactamente los 50 de 40
de la 044. En los seis archivos, **todos** los 20 están en impar y **todos** los 40 y 45, en par.

**Lo que esto dice:** la regla «una par cubre sus dos impares vecinas» se cumple sin
excepción. Lo que **no** sigue una fórmula es **qué pares existen**: ALFA y DELTA saltan de la
038 a la 044, con una 041 de solo 20 en medio. Un generador por rangos que calcule «la par de
esta impar» con aritmética —por ejemplo, «la vecina par ≡ 2 (mód 4)», que vale para
BRAVO, CHARLIE y ECO— asignaría la 041 a la 042 y la 043 a la
042, las dos inexistentes.

*Inferencia, sin fuente:* ALFA y DELTA comparten la misma secuencia de bahías, así que
podrían ser gemelos. Están anonimizados y no se puede comprobar.

### Dónde van los refrigerados

| Buque | Reefers de 20 | Extremo | La otra mitad de la celda | Reefers de 40 por par |
|---|---:|---|---|---|
| ALFA | 9 | **9 en proa** (021, par 022) | **9 de 9: 20 seco lleno (22G1)** | 030: 23 · 022: 12 · 038: 5 · 014: 1 |
| BRAVO | 0 | — | — | 034: 6 · 018: 5 · 014: 3 |
| CHARLIE | 0 | — | — | 014: 10 |
| DELTA | 0 | — | — | 010: 24 · 014: 14 · 030: 13 · 034: 13 · 044: 3 · 038: 2 · 022: 1 · 006: 1 |
| ECO | 0 | — | — | 91 en nueve pares; A05 y A06 idénticos (T-55) |

Ninguna celda del corpus tiene reefers de 20 en los dos extremos.

**Lo que esto dice, con cautela:** en ALFA, los nueve reefers de 20 están en bodega (0210704
a 0211006), siempre en el extremo de proa del par 022, y la mitad de popa de cada una de esas
nueve celdas lleva un 20 seco lleno. **Es compatible** con que esas celdas tengan la toma
solo en proa. **También es compatible** con una elección del planificador en celdas con toma
en los dos extremos. Una sola bahía de un solo buque no distingue entre las dos. Los otros
cuatro buques no traen reefers de 20, así que el corpus **no contesta** la pregunta del
extremo.

## 3. Propuesta para T-56

### Las respuestas posibles, que el modelo tiene que admitir todas

| Si la documentación del buque dice… | Ejemplo |
|---|---|
| A. La toma es de la celda de 40, sin extremo | «Bahía 22, fila 07, nivel 04: 1 toma» |
| B. La toma está en un extremo de la celda | «22/07/04, toma a proa» |
| C. Cada mitad de 20 tiene su toma | «21/07/04 y 23/07/04» |
| D. No se sabe | El caso de hoy |

### Cómo guardar el inventario

Una toma se guarda como **celda física + extremo**:

- **Celda:** la bahía par del par (o la impar, si la bahía no tiene par, como la 041), más
  la fila y el nivel.
- **Extremo:** `proa`, `popa`, `ambos` o `sinEspecificar`.

Y el perfil guarda además la **tabla de pares del buque**, la de la sección 2: qué impares
cubre cada par, qué bahías van solas. Se propone desde el archivo con la misma relación que
ya usa `neighborOccupiedSlots()`, y el usuario la corrige. La 041 y la 044 de ALFA muestran
que no se puede calcular.

**Compatibilidad con lo que ya existe:** el código de siete dígitos que se escribe hoy se
traduce sin pérdida:

| Código que llega | Se guarda como |
|---|---|
| Bahía impar dentro de un par (`0210704`) | celda 022/07/04, extremo **proa** (porque 021 < 022) |
| Bahía impar dentro de un par (`0230704`) | celda 022/07/04, extremo **popa** |
| Bahía impar sola (`0410382` en ALFA/DELTA) | celda 041/03/82, extremo **ambos** (no tiene mitades) |
| Bahía par (`0220704`) | celda 022/07/04, extremo **sinEspecificar** |

La **propuesta desde el archivo** sigue igual en espíritu: un reefer de 40 propone su celda
con extremo `sinEspecificar`, y uno de 20 propone su celda con el extremo que ocupó. En A01,
las 50 tomas propuestas quedan como 41 celdas `sinEspecificar` y 9 celdas del par 022 con
extremo `proa`.

### Cómo debe buscar el validador

| Carga | Hay toma si… | Si la celda tiene toma pero el extremo no consta |
|---|---|---|
| Reefer de 40 en la par E | existe una toma en la celda (E, fila, nivel), **con cualquier extremo** | — |
| Reefer de 20 en la impar b del par E | existe una toma en la celda con extremo **igual al de b** o `ambos` | extremo `sinEspecificar`: **aviso** «la celda tiene toma, confirmar el extremo», nunca error |
| Reefer de 20 en una impar sola | existe una toma en la celda (b, fila, nivel) | — |

La severidad sigue la regla de T-39: la ausencia de toma en un inventario **declarado** es
error, y en uno **propuesto** o de plantilla es aviso. Solo cambia la unidad de búsqueda: de
código exacto a **celda física**. Con esto, los 91 errores del escenario de T-55
desaparecen cuando la celda tiene toma. Quedan como aviso si el extremo no consta, y como
error solo si la toma declarada está en el otro extremo.

**Por qué el 40 acepta cualquier extremo:** F2 muestra que el sentido del motor es una
instrucción del embarque (RFA o RFF), así que un 40 se orienta hacia su toma. Es una
inferencia, no una regla escrita. Si Carlos sabe que en ALFA un 40 solo puede tomar
corriente de un extremo, la tabla admite exigirlo sin cambiar el modelo.

**Para el generador por rangos:** genera **celdas**, no códigos, a partir de la tabla de
pares del perfil, y pide el extremo una vez para todo el rango. El conteo de la vista previa
es de celdas, y así coincide con el perfil guardado.

### Lo que Carlos tendría que confirmar para ALFA

1. **La tabla de pares.** Que la 041 es una bahía de solo 20 sin par, que la 044 cubre 043 y
   045, y que no existen 040 ni 042. Se ve en el Baplie Viewer o en el plano general del buque.
2. **El extremo de las tomas.** Con una sola celda basta para decidir la convención: **en la
   bodega del par 022, fila 07, nivel 04, ¿hay toma solo a proa (021) o también a popa
   (023)?** El archivo pone el reefer en 021 y un 20 seco en 023 en las nueve celdas de ese
   grupo. Si la respuesta es «solo a proa», la convención de ALFA es B con extremo proa; si
   es «en las dos», es C.
3. **Dónde mirarlo, si no se sabe de memoria:** en el plano de tomas de reefer del buque
   («reefer plug arrangement»), en el programa de estabilidad a bordo (OSP) o en el perfil
   del buque del software de planificación del armador.

Si ninguna de las tres cosas se consigue, el modelo propuesto funciona igual: las tomas
quedan en `sinEspecificar`, los 40 validan por celda y los 20 dan aviso en vez de error.
Esa es la respuesta honesta de lo que hoy se sabe.

---

## Verificación

- `dart analyze tool/t59_bahias_tomas.dart`: sin incidencias.
- `dart run` sobre A01 a A06 (hashes en `docs/T55-RESULTADOS.md`): salida en
  `build/t59/bahias_tomas.json`. Los nueve 20 secos de la 023 se contrastaron también a mano
  contra el EDI crudo de A01 (0230704 a 0231006, todos 22G1 de entre 27 160 y 27 360 kg).
- Las cuatro fuentes se leyeron en el documento original: dos PDF de SMDG, con el texto
  extraído localmente; el HTML de arXiv; y el manual de Thermo King. Las citas son textuales.
- Sin `lib/`, `test/`, Git, Firebase ni dependencias.

**Tiempo:** alrededor de 1.1 h, contra 1.0 h estimada.

## Archivos

Nuevos: `tool/t59_bahias_tomas.dart`, `docs/T59-RESULTADOS.md`.
Evidencia sin versionar: `build/t59/bahias_tomas.json`.
