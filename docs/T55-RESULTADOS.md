# T-55 · Revisión cruzada de RF-027 contra su fuente y contra el corpus

Timonel · 30-sep-2026 · Base: `1607263` · Trabajo en paralelo con T-44 (Codex).

**No se tocó `lib/` ni `test/`.** Cuatro scripts nuevos en `tool/`, evidencia en
`build/t55/` (ignorada por Git). Nada se corrigió: cada hallazgo queda clasificado
para que Carlos decida dónde entra (§9.1).

| # | Punto | Veredicto |
|---|---|---|
| 1 | Fila 00 que la geometría supone siempre | **Defecto confirmado** en el modelo · sin impacto hoy en el corpus |
| 2 | Paridad de bahía en las tomas de reefer | **Defecto confirmado** en el contrato: no hay convención · decide Carlos |
| 3 | Tabla de segregación contra la fuente | **Conforme** · un defecto confirmado de severidad baja · una duda |
| 4 | Un caso a mano por validador | **Conforme** en los cuatro · una duda sobre T-38 |

Corpus usado, SHA-256 (A03 coincide con `docs/BLOQUE7B-RESULTADOS.md`):

| Archivo | SHA-256 |
|---|---|
| A01 | `3D793F8056A3D8B96140E681B6C468EA49922658AFDEA4F7416A169A60A8CE5B` |
| A02 | `7A223FD0ED15480B39AFC5AB7A35207E494DD4B9C3C4294338E5D2DED62C92AD` |
| A03 | `8795D2F1E34B0A34DD88E0099C33BD524B8C523C0DE1B52140C6B9C4DB8C734C` |
| A04 | `C75BFA940B622CE8A1E5A02EEAF9C64A848872840793C5896B49FCEB64872F5A` |
| A05 | `12BDDA3360C65D6C559567A735DE7169E241AD91325716DFBB6D39D585036D38` |
| A06 | `84B8C708D03B99665BF21690EDCC0BC7FD48DD21242F8643A1DA05F683E3F1A6` |

Reproducir cualquier punto:

```
dart run tool/t55_<script>.dart "<directorio del corpus>"
```

---

## 1. La fila 00 — defecto confirmado

**Reproducción:** `tool/t55_fila_central.dart` → `build/t55/fila_central.json`.

`VesselGeometry.orderedRows` inserta siempre la fila 00 (`vessel_geometry.dart:110-111`),
`covers()` la acepta siempre (`:132-133`) y **no existe ningún parámetro para declarar
que el buque no la tiene**. `DangerousGoodsValidator` mide la separación transversal por
índice en esa lista (`dangerous_goods_validator.dart:168-169`).

**Caso controlado.** Par de código 2 (UN1170 clase 3 / UN0012 1.4S, §176.83(b)), dos 40 pies
en la misma bahía y nivel; solo cambia la fila:

| Caso | Filas | Índices | `lateralGap` | Resultado |
|---|---|---|---:|---|
| Cubierta, a los dos lados del eje | 02 / 01 | 5 / 7 | 1 | **conforme** |
| Bodega, a los dos lados del eje | 02 / 01 | 5 / 7 | 1 | **conforme** |
| Control, mismo lado | 01 / 03 | 7 / 8 | 0 | posible incumplimiento |
| Control, mismo lado | 02 / 04 | 5 / 4 | 0 | posible incumplimiento |
| Control, la 00 ocupada | 00 / 01 | 6 / 7 | 0 | posible incumplimiento |
| Bodega, control | 01 / 03 | 7 / 8 | 0 | no evaluado |

En un buque sin fila central, 01 y 02 son vecinas. El validador cuenta entre ellas un hueco
que no existe y declara **conforme** un par de código 2. Es exactamente el «conforme por
omisión» que la fuente de T-41 prohíbe (§7).

**Corpus.** Ocupación de la fila 00:

| Archivo | Buque | Contenedores | Fila 00 en cubierta | Fila 00 en bodega | Celdas con 01 y 02 en la misma bahía y nivel |
|---|---|---:|---:|---:|---:|
| A01 | ALFA | 977 | **0** | **0** | 98 |
| A02 | BRAVO | 806 | **0** | **0** | 76 |
| A03 | CHARLIE | 369 | 24 | **0** | 39 |
| A04 | DELTA | 979 | **0** | **0** | 97 |
| A05 | ECO | 736 | 34 | **0** | 76 |
| A06 | ECO | 717 | 33 | **0** | 74 |

Tres de los cinco buques nunca cargan la 00, y **ninguno la usa en bodega**. El patrón de
CHARLIE y ECO —00 en cubierta, nunca en bodega— es el de un buque con número impar de
filas en cubierta y par en bodega. Tampoco eso se puede declarar: la geometría es una
sola lista de filas para las dos zonas. Que ALFA, BRAVO o DELTA tengan fila central es algo
que el archivo no dice, y que la ausencia en 977 posiciones no prueba. **Pregunta para
Carlos como planificador: ¿el buque de ALFA tiene fila 00, y en qué zonas?**

**Impacto hoy: ninguno.** En A01, A02 y A04 ninguno de los 10 resultados es de código 2. En A03 hay 3 pares de código 2 en filas 01/02, los tres **no evaluados** por los
grupos de UN3085. Dos están en la cubierta de la bahía 026, donde la 0260084 **sí está
ocupada**: el hueco existe. El tercero (0140284 / 0260184) está a 12 bahías, así que cumple
por el eje longitudinal. Ningún resultado real cambia. El defecto es latente, y se activaría
con el primer par de código 2 en 01/02 de un buque sin 00, o en la bodega de CHARLIE o de ECO.

**Fuera de RF-027, anotado:** la misma fila fantasma entra en `slotsPerBay`, el
denominador de la ocupación, y en la columna 00 vacía del plano y del PDF («fila 00 en
34 de 34», §10.15).

## 2. Tomas de reefer y paridad de bahía — defecto confirmado en el contrato

**Reproducción:** `tool/t55_tomas_paridad.dart` → `build/t55/tomas_paridad.json`.

`ReeferSocketValidator` busca el código exacto (`profile.hasReeferSocket(p.toIsoCode())`),
y el inventario no tiene una convención escrita sobre qué número de bahía lleva una toma.

**Las 50 tomas propuestas de A01:** **41 vienen de un 40 pies** (bahía par) y **9 de un
20 pies** (bahía impar, todas en la 021). Con la propuesta tal cual hay cero alertas.

**El mismo hueco físico en otro viaje**, con el inventario marcado como declarado:

| Escenario | Simulados | Alertas | Severidad | En un hueco físico que el inventario lista |
|---|---:|---:|---|---:|
| Un 20 en cada impar vecina de las 41 tomas de 40 | 82 | **82** | error | 82 |
| Un 40 en la par que cubre las 9 tomas de 20 | 9 | **9** | error | 9 |

Ejemplo: *«Refrigerado … en 0290504 sin toma en el inventario declarado por el usuario»*,
con la toma declarada en 0300504. Con un inventario declarado, cada una de las 91 es un
**error**, el nivel más alto del panel.

**Cuántas son falsas no lo decide el código.** Depende de a qué extremo del hueco de 40
sirve el enchufe: si sirve a un solo 20, la mitad de las 82 son legítimas. Es la pregunta
de planificador de §10.21: **cómo lista las tomas la documentación del buque.**

**Hallazgo nuevo, importante para T-56: la correspondencia par ↔ impares es del buque, no
de una fórmula.** En A02, A03, A05 y A06, las 40 caen siempre en pares ≡ 2 (mód 4): 002, 006,
010… En A01 hay **25 en la bahía 044** (cubre 043 y 045, las sombras de T-53) y en A04 hay
**50** fuera de ese patrón. Un generador por rangos que calcule «la par de esta impar» con
aritmética se equivocaría en ALFA. La relación sale de la numeración de cada buque.

**Intento con datos reales, no concluyente:** A05 y A06 son los dos «BUQUE ECO», con claves
de perfil distintas (`callSign:ZZC5603` e `imo:9000039`). Sus 91 posiciones reefer son
**idénticas**, así que cruzar el inventario de uno contra la carga del otro da 0 alertas y
no mide nada. No se usó como evidencia.

## 3. Tabla de segregación contra la fuente — conforme, con un defecto y una duda

**Reproducción:** `tool/t55_tabla_segregacion.dart` → `build/t55/tabla_segregacion.json`.
Las tablas del script se copiaron de `docs/T41-SEGREGACION-FUENTE.md` (§3 y §4), no del
código.

- **28 pares:** cero discrepancias, en los dos órdenes. Las clases fuera de la matriz (1.1,
  1.4S, 2.2, 6.1, 7, 4.3, vacía) no tienen regla.
- **17 números ONU:** cero discrepancias en clase, secundario, grupo de compatibilidad,
  «como clase 9» y códigos de grupo 52/53/56/58/138.
- **Barrido de 17 × 17** en cinco configuraciones (contiguas en cubierta y en bodega, misma
  vertical, bodega bajo cubierta, una fila de por medio): **cero violaciones**. Ningún par
  con «2» en la fuente sale conforme sin un hueco, y ningún par con grupos (§176.83(m))
  sale conforme.
- **Casos sin regla, frente a un compañero con el que el par sería conforme:** ONU fuera
  de los 17, ONU ausente, clase contradictoria o ausente, etiqueta 6.1, regulación distinta
  de IMD, 42U1, 42P1, 22K2, 22V1, sin tipo ISO, 20 en bahía par, 40 en bahía impar, fuera
  de la geometría, sin posición: **los 15 salen «no evaluado»**. El control sale conforme.

**Contraste con la edición oficial 2024 de §176.83 (XML de GovInfo).** El eCFR vigente
redirige a una página antibots, igual que le pasó a Codex, así que esto tampoco certifica
vigencia a 2026:

- **(a)(6)**, segregación del secundario cuando es más restrictiva: el código toma el
  máximo sobre primario, secundarios y etiquetas. **Conforme.**
- **(a)(8)**, misma clase sin considerar el secundario *«provided the substances do not
  react dangerously»*: el código no lo presume y da «no evaluado». **Conforme.**
- **(a)(10)**, *«Segregation as for…»*: UN1950 como clase 9. **Conforme.**
- **(d)**, *«any segregation»* impide la misma unidad: el código lo aplica a los códigos 1
  y 2. **Conforme.**
- **(f), «cerrado contra cerrado»:** vertical *«Not in the same vertical line unless
  segregated by a deck»*. En cubierta, 1 espacio a proa y popa y de costado. Bajo cubierta,
  1 espacio o 1 mamparo a proa y popa, y 1 espacio de costado. El código exige un hueco en
  cualquiera de los dos ejes y deja el mamparo como «no evaluado». **Conforme.** Una primera
  lectura automática atribuyó «Two container spaces» a esta columna; al leer la fila celda
  por celda, eso es de «cerrado contra abierto».

**Defecto confirmado, severidad baja: el código «\*» gana al «2».** `SegregationCode.compatibility`
es el último valor del enum, y el validador se queda con el índice mayor
(`dangerous_goods_validator.dart:83`). Si una unidad 1.4 trae además una etiqueta C236 de
otra clase, el par con otro 1.4 se resuelve por §176.144, como si las dos fueran solo 1.4:

| Caso (posiciones contiguas en cubierta) | Resultado |
|---|---|
| UN0012 / UN0303 (control) | conforme, §176.144 |
| UN0012 con etiqueta 3 / UN1170 (control: la etiqueta cuenta) | posible incumplimiento |
| UN1170 / UN0303 (control: 3 frente a 1.4 = 2) | posible incumplimiento |
| **UN0012 con etiqueta 3 / UN0303** | **conforme** |
| **UN0012 con etiqueta 5.1 / UN0303** | **conforme** |

La etiqueta se respeta en todos los pares salvo cuando existe la combinación 1.4/1.4. Para
llegar aquí hace falta una etiqueta que contradiga la entrada ONU. **Impacto en el corpus:
ninguno**, porque las cuatro unidades 1.4 son de A03 y ahí C236 viene vacío.

**Duda: los tanques cuentan como unidad cerrada.** El patrón `^[24LM][0-9A-Z][GRT][0-9]$`
admite `T`, y el corpus trae 3 unidades peligrosas en tanque (22T1 y dos 22T0). §176.2 dice
que *«Cargo transport unit means … a freight container, a portable tank…»* y que es cerrada
si su contenido queda *«totally enclosed by permanent structures»*, pero no nombra al
tanque como cerrado. La lectura es razonable, pero es una inferencia, y hoy no está escrita
como tal. Para resolverla: que Carlos la acepte y que quede en el comentario de `_problem`.

## 4. Un caso a mano por validador — conforme

**Reproducción:** `tool/t55_trazas.dart` → `build/t55/trazas.json`. El script lee LOC+147,
MEA y EQD del texto crudo con expresiones propias, **sin el parser de la app**, y compara.
Los paneles son las capturas de Codex en `build/block7b/`.

- **T-38 · A01, pila de bodega 002/01.** Del EDI, a mano: FICU2155340 (0020108, 24 810 kg),
  ZKPU3030825 (0020110, 24 756 kg) y GRDU6972450 (0020112, 23 886 kg), que suman
  **73 452 kg**. El panel de Windows con 62 500.5 kg muestra lo mismo. Conteo crudo contra
  la app: A01 33 = 33 (75 000 kg) y 47 = 47 (62 500.5, igual que el panel); A03 41 = 41 y
  50 = 50. **Conforme.**
- **T-39 · A01, ZKPU3575466**, 22R1, −20 °C, en 0210804. Su toma está en la propuesta, cero
  alertas, igual que el 47/0/6 del panel. Además, 43 `TMP` contra 50 refrigerados: 7 se
  detectan solo por el tipo ISO, coherente con `c101fb5`. **Conforme.** Aviso: es el mismo
  contenedor que usó Codex, porque es el primer refrigerado del archivo. La elección no es
  independiente; la suma sí lo es.
- **T-40 · A01 y A03, recalculado desde el crudo** por columna física de 20 pies y zona:
  **0 casos de 20 sobre 40** en los dos, igual que la app y el panel. El conteo discrimina:
  encuentra 42 casos de 40 sobre 20 en A01 y 23 en A03, que la regla no señala.
  **Conforme.**
- **T-41 · A03, par 1.** PLNU9223134 es UN1170, 45G1, en 0020386, y HXTU0749681 es UN0012,
  22G1, en 0030586, los dos en cubierta, nivel 86. A mano: centros separados |2 − 3| / 2 = 0.5,
  bordes 0.5 − (40 + 20) / 40 = −1.0, filas 03 y 05 contiguas del mismo lado (sin hueco),
  3/1.4 = código 2 por §176.83(b), así que es un posible incumplimiento. La tarjeta de Chrome
  (`chrome-final-panel.png`) muestra los mismos contenedores, estado, texto y las cuatro
  referencias. **Conforme.**

**Duda sobre T-38: las columnas mixtas se parten en dos pilas.** El peso se suma por número
de bahía. En A01, **42 columnas físicas** mezclan 20 y 40 (en A03, 23), todas con 40 sobre 20.
En la misma 002/01, la bodega tiene debajo dos 20 en 0030104 y 0030106 (2 210 y 2 170 kg),
que suman en la pila 003/01 y no en la 002/01. Si eso está bien depende de cómo da el
manual los límites (por pila de 20, por pila de 40 o por columna). Es la misma limitación
que §10.20 ya manda a la tesis, con un número concreto encima.

---

## Qué necesita decisión

1. **Fila 00:** ¿ALFA tiene fila central, y en qué zonas? Si el perfil ha de declararla,
   debería poder hacerlo **por zona**: el corpus muestra buques con 00 en cubierta y no en
   bodega.
2. **Tomas:** ¿la documentación del buque lista las tomas por hueco de 20, por hueco de 40
   o por extremo? Esto fija la convención de T-56. El generador por rangos no puede
   deducir la bahía par con aritmética (ALFA 044, DELTA).
3. **Precedencia de «\*»:** severidad baja, sin impacto en el corpus. Se decide si entra.
4. **Tanques como cerrados:** aceptar la inferencia de §176.2 y dejarla escrita, o volverlos
   «no evaluado».

## Verificación

- 4 scripts ejecutados con `dart run` contra el corpus real, salida en `build/t55/`. Los dos
  corregidos por el análisis se reejecutaron con salida idéntica.
- `flutter analyze`: **No issues found**. La primera corrida dio 5 incidencias, todas en
  mis scripts (un `const` y cuatro `!` innecesarios); quedaron corregidas.
- `flutter test` **no se ejecutó**: la tarea no toca `lib/` ni `test/`, y la suite completa
  habría cargado la máquina de las mediciones de T-44. El piso sigue en 260 según el último
  informe; no lo afirmo como medido hoy.
- Sin Git, sin Firebase, sin dependencias, sin cambios en `pubspec.*`.

**Tiempo:** unas 2.0 h, contra 1.5 h estimadas y el tope de 3 h.

## Archivos

Nuevos: `tool/t55_fila_central.dart`, `tool/t55_tomas_paridad.dart`,
`tool/t55_tabla_segregacion.dart`, `tool/t55_trazas.dart`, `docs/T55-RESULTADOS.md`.
Evidencia sin versionar: `build/t55/*.json`, `build/t55/analyze.log`.
